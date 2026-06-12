#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
Assigns an Intune device category to managed devices.
.DESCRIPTION
Finds or creates the requested device category and assigns it to managed devices matched by device name through Microsoft Graph.
.NOTES
Uses Microsoft Graph beta endpoints and changes Intune metadata. Use -WhatIf, then test with controlled non-production devices before production.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$CategoryName,

    [Parameter(Mandatory)]
    [string[]]$DeviceName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-MgGraph -Scopes 'DeviceManagementManagedDevices.ReadWrite.All' -NoWelcome

$categories = Invoke-MgGraphRequest -Method GET -Uri '/beta/deviceManagement/deviceCategories'
$category = $categories.value | Where-Object displayName -EQ $CategoryName | Select-Object -First 1

if (-not $category) {
    if (-not $PSCmdlet.ShouldProcess($CategoryName, 'Create Intune device category')) {
        return
    }
    $category = Invoke-MgGraphRequest -Method POST -Uri '/beta/deviceManagement/deviceCategories' -Body @{
        displayName = $CategoryName
        description = "Managed by automation: $CategoryName"
    }
}

$devices = (Invoke-MgGraphRequest -Method GET -Uri '/beta/deviceManagement/managedDevices?$select=id,deviceName').value
foreach ($name in $DeviceName) {
    $device = $devices | Where-Object deviceName -EQ $name | Select-Object -First 1
    if (-not $device) {
        Write-Warning "Managed device '$name' was not found."
        continue
    }

    if ($PSCmdlet.ShouldProcess($name, "Assign device category '$CategoryName'")) {
        $uri = "/beta/deviceManagement/managedDevices/$($device.id)/deviceCategory/`$ref"
        Invoke-MgGraphRequest -Method PUT -Uri $uri -Body @{
            '@odata.id' = "https://graph.microsoft.com/beta/deviceManagement/deviceCategories/$($category.id)"
        }
    }
}
