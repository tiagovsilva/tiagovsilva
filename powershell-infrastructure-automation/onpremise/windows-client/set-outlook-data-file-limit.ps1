#Requires -Version 5.1
#Requires -PSEdition Desktop

<#
.SYNOPSIS
Configures Outlook Unicode PST and OST size limits for the current user.
.DESCRIPTION
Writes the maximum and warning size values to the selected Office version registry path under the current user profile.
.NOTES
Changes Outlook registry settings. Use -WhatIf, then test on a controlled non-production profile and validate rollback before production.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('15.0', '16.0')]
    [string]$OfficeVersion = '16.0',

    [ValidateRange(1024, 102400)]
    [uint32]$MaximumSizeMb = 51200,

    [ValidateRange(512, 102399)]
    [uint32]$WarningSizeMb = 48640
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($WarningSizeMb -ge $MaximumSizeMb) {
    throw 'WarningSizeMb must be smaller than MaximumSizeMb.'
}

$registryPath = "HKCU:\Software\Microsoft\Office\$OfficeVersion\Outlook\PST"
if ($PSCmdlet.ShouldProcess($registryPath, 'Configure Outlook PST and OST limits')) {
    New-Item -Path $registryPath -Force | Out-Null
    foreach ($entry in @{
        MaxLargeFileSize  = $MaximumSizeMb
        WarnLargeFileSize = $WarningSizeMb
    }.GetEnumerator()) {
        New-ItemProperty -Path $registryPath -Name $entry.Key -PropertyType DWord -Value $entry.Value -Force | Out-Null
    }
}
