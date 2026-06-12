#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Enables or disables write protection for removable storage.
.DESCRIPTION
Sets the Windows StorageDevicePolicies WriteProtect registry value to control write access to removable storage devices.
.NOTES
Administrative security change. Use -WhatIf, then test on a controlled non-production device and validate reversal before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [bool]$WriteProtected
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies'
$value = if ($WriteProtected) { 1 } else { 0 }

if ($PSCmdlet.ShouldProcess($registryPath, "Set WriteProtect to $value")) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty `
        -Path $registryPath `
        -Name 'WriteProtect' `
        -PropertyType DWord `
        -Value $value `
        -Force | Out-Null
}
