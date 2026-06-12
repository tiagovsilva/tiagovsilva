#Requires -Version 5.1

<#
.SYNOPSIS
Validates the public PowerShell automation collection.
.DESCRIPTION
Checks syntax, runtime declarations, comment-based help, catalog coverage, relative Markdown links, and common sensitive-value patterns.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]
$scriptRoots = @(
    Join-Path $projectRoot 'cloud'
    Join-Path $projectRoot 'hybrid'
    Join-Path $projectRoot 'onpremise'
)
$scripts = Get-ChildItem -Path $scriptRoots -Recurse -File -Filter '*.ps1'

foreach ($script in $scripts) {
    $relativePath = $script.FullName.Substring($projectRoot.Length + 1)
    $tokens = $null
    $parseErrors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $script.FullName,
        [ref]$tokens,
        [ref]$parseErrors
    )

    foreach ($parseError in $parseErrors) {
        $failures.Add("$relativePath`: $($parseError.Message)")
    }

    $content = Get-Content -LiteralPath $script.FullName -Raw
    foreach ($requiredPattern in @(
        '(?m)^#Requires -Version (5\.1|7\.4)$'
        '(?m)^#Requires -PSEdition (Desktop|Core)$'
        '(?m)^\.SYNOPSIS\s*$'
        '(?m)^\.DESCRIPTION\s*$'
        '(?m)^\.NOTES\s*$'
    )) {
        if ($content -notmatch $requiredPattern) {
            $failures.Add("$relativePath`: missing required metadata matching $requiredPattern")
        }
    }

    if ($content -match 'SupportsShouldProcess') {
        if ($content -notmatch '(?i)controlled non-production|controlled non-production|non-production') {
            $failures.Add("$relativePath`: modifying scripts must require controlled non-production testing")
        }
        if ($content -notmatch '(?i)before production') {
            $failures.Add("$relativePath`: modifying scripts must require validation before production")
        }
    }
}

$catalogPath = Join-Path $projectRoot 'docs\SCRIPT-CATALOG.md'
$catalog = Get-Content -LiteralPath $catalogPath -Raw
$examplesPath = Join-Path $projectRoot 'docs\EXAMPLES.md'
$examples = Get-Content -LiteralPath $examplesPath -Raw
foreach ($script in $scripts) {
    $relativePath = $script.FullName.Substring($projectRoot.Length + 1).Replace('\', '/')
    if ($catalog -notmatch [regex]::Escape($relativePath)) {
        $failures.Add("docs/SCRIPT-CATALOG.md: missing $relativePath")
    }

    $examplePath = $relativePath.Replace('/', '\')
    if ($examples -notmatch [regex]::Escape($examplePath)) {
        $failures.Add("docs/EXAMPLES.md: missing $examplePath")
    }
}

$sensitivePatterns = @{
    EmailAddress         = '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b'
    IPv4Address          = '(?<!\d)(?:\d{1,3}\.){3}\d{1,3}(?!\d)'
    GuidLiteral          = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\b'
    InternalDomain       = '(?i)\b[a-z0-9-]+\.(?:local|corp|internal)\b'
    PlainSecretAssignment = '(?i)(clientsecret|password|passwd|apikey|api_key)\s*=\s*[''"][^''"]+[''"]'
}

$textFiles = Get-ChildItem -LiteralPath $projectRoot -Recurse -File |
    Where-Object Extension -In @('.ps1', '.psd1', '.md')

foreach ($file in $textFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($pattern in $sensitivePatterns.GetEnumerator()) {
        if ($content -match $pattern.Value) {
            $relativePath = $file.FullName.Substring($projectRoot.Length + 1)
            $failures.Add("$relativePath`: matched sensitive pattern $($pattern.Key)")
        }
    }
}

$markdownFiles = Get-ChildItem -LiteralPath $projectRoot -Recurse -File -Filter '*.md'
foreach ($markdownFile in $markdownFiles) {
    $content = Get-Content -LiteralPath $markdownFile.FullName -Raw
    $linkMatches = [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')

    foreach ($match in $linkMatches) {
        $target = $match.Groups[1].Value
        if ($target -match '^(?:https?://|#|mailto:)' -or $target.Contains('#')) {
            continue
        }

        $decodedTarget = [uri]::UnescapeDataString($target)
        $resolvedTarget = Join-Path $markdownFile.DirectoryName $decodedTarget
        if (-not (Test-Path -LiteralPath $resolvedTarget)) {
            $relativePath = $markdownFile.FullName.Substring($projectRoot.Length + 1)
            $failures.Add("$relativePath`: broken relative link $target")
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "Repository validation failed with $($failures.Count) issue(s)."
}

Write-Output "Repository validation passed for $($scripts.Count) scripts."
