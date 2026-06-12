#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules PnP.PowerShell

<#
.SYNOPSIS
Creates SharePoint Online team sites from a CSV file.
.DESCRIPTION
Reads Title and Alias columns, normalizes each alias, creates the corresponding team site, and writes a creation audit CSV.
.NOTES
Creates SharePoint sites. Use -WhatIf, then test the CSV in a controlled non-production tenant and validate site cleanup before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [uri]$AdminUrl,

    [Parameter(Mandatory)]
    [guid]$ClientId,

    [Parameter(Mandatory)]
    [string]$InputPath,

    [Parameter(Mandatory)]
    [string]$Owner,

    [ValidateRange(1, 65535)]
    [uint32]$LocaleId = 1033,

    [Parameter(Mandatory)]
    [string]$AuditPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-PnPOnline -Url $AdminUrl.AbsoluteUri -Interactive -ClientId $ClientId
$rows = Import-Csv -LiteralPath $InputPath
$audit = [System.Collections.Generic.List[object]]::new()

foreach ($row in $rows) {
    if (-not $row.Alias -or -not $row.Title) {
        throw "The input CSV must contain non-empty Alias and Title columns."
    }

    $alias = $row.Alias.ToLowerInvariant() -replace '[^a-z0-9-]', '-'
    $status = 'WhatIf'

    if ($PSCmdlet.ShouldProcess($alias, "Create TeamSite '$($row.Title)'")) {
        New-PnPSite -Type TeamSite -Title $row.Title -Alias $alias -Owners $Owner -Lcid $LocaleId -Wait
        $status = 'Created'
    }

    $audit.Add([pscustomobject]@{
        TimestampUtc = (Get-Date).ToUniversalTime()
        Title        = $row.Title
        Alias        = $alias
        Status       = $status
    })
}

$auditDirectory = Split-Path -Parent $AuditPath
if ($auditDirectory) {
    New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null
}
$audit | Export-Csv -LiteralPath $AuditPath -NoTypeInformation -Encoding utf8
