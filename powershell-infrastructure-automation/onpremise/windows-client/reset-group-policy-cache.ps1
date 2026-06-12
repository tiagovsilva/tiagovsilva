#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Resets the local Group Policy history cache while preserving a backup.
.DESCRIPTION
Moves the existing Group Policy history to a timestamped backup directory and runs gpupdate to rebuild local policy state.
.NOTES
Administrative recovery operation. Use -WhatIf, then test on a controlled non-production device and validate backup restoration before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [string]$BackupDirectory = (Join-Path $env:ProgramData 'GroupPolicyCacheBackup')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$cachePath = Join-Path $env:ProgramData 'Microsoft\Group Policy\History'
if (-not (Test-Path -LiteralPath $cachePath)) {
    Write-Information "Group Policy cache '$cachePath' does not exist." -InformationAction Continue
    return
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupPath = Join-Path $BackupDirectory $timestamp

if ($PSCmdlet.ShouldProcess($cachePath, "Move cache to '$backupPath' and run gpupdate")) {
    New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
    Move-Item -LiteralPath $cachePath -Destination $backupPath

    & gpupdate.exe /force
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "gpupdate returned exit code $LASTEXITCODE. Restore from '$backupPath' if required."
    }
}
