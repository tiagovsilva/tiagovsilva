#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Collects Active Directory replication and optional DNS diagnostic reports.
.DESCRIPTION
Runs repadmin and dcdiag checks and writes timestamped text reports to the selected output directory.
.NOTES
Read-only diagnostics. Review report contents before sharing because they can expose domain topology.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$OutputDirectory,

    [switch]$IncludeDnsDiagnostics
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

$commands = @(
    @{
        Name      = 'repadmin-summary'
        Executable = 'repadmin.exe'
        Arguments = @('/replsummary')
    },
    @{
        Name      = 'repadmin-replicas'
        Executable = 'repadmin.exe'
        Arguments = @('/showrepl', '*', '/csv')
    },
    @{
        Name      = 'dcdiag-replications'
        Executable = 'dcdiag.exe'
        Arguments = @('/test:replications', '/e', '/v')
    }
)

if ($IncludeDnsDiagnostics) {
    $commands += @{
        Name      = 'dcdiag-dns'
        Executable = 'dcdiag.exe'
        Arguments = @('/test:dns', '/e', '/v')
    }
}

foreach ($command in $commands) {
    $commandInfo = Get-Command $command.Executable -ErrorAction Stop
    $outputPath = Join-Path $OutputDirectory "$($command.Name)-$timestamp.txt"
    $arguments = $command.Arguments
    & $commandInfo.Source @arguments 2>&1 |
        Out-File -LiteralPath $outputPath -Encoding UTF8

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "$($command.Executable) returned exit code $LASTEXITCODE. Review '$outputPath'."
    }
}
