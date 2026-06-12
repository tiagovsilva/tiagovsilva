#Requires -Version 5.1
#Requires -PSEdition Desktop

<#
.SYNOPSIS
Configures an upload bandwidth schedule for the local Azure File Sync agent.
.DESCRIPTION
Loads the Storage Sync agent cmdlets and creates a day, time, and bandwidth limit for outbound synchronization traffic.
.NOTES
Changes the local Azure File Sync configuration. Use -WhatIf, then test the real change in a controlled non-production environment and validate rollback before production.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
    [string[]]$Day = @('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'),

    [ValidateRange(0, 23)]
    [int]$StartHour = 6,

    [ValidateRange(1, 24)]
    [int]$EndHour = 23,

    [ValidateRange(1, 10485760)]
    [Parameter(Mandatory)]
    [int]$LimitKbps,

    [string]$ModulePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($StartHour -ge $EndHour) {
    throw 'StartHour must be smaller than EndHour.'
}

if ($ModulePath) {
    Import-Module -Name $ModulePath -ErrorAction Stop
}
else {
    $standardModulePath = Join-Path $env:ProgramFiles 'Azure\StorageSyncAgent\StorageSync.Management.ServerCmdlets.dll'
    if (Test-Path -LiteralPath $standardModulePath) {
        Import-Module -Name $standardModulePath -ErrorAction Stop
    }
    else {
        Import-Module -Name 'StorageSync.Management.ServerCmdlets' -ErrorAction Stop
    }
}

$description = "Limit upload to $LimitKbps Kbps on $($Day -join ', ') from $StartHour`:00 to $EndHour`:00"
if ($PSCmdlet.ShouldProcess('Azure File Sync agent', $description)) {
    New-StorageSyncNetworkLimit `
        -Day $Day `
        -StartHour $StartHour `
        -EndHour $EndHour `
        -LimitKbps $LimitKbps
}
