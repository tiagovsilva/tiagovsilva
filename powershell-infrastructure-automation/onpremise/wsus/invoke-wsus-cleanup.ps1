#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Runs WSUS cleanup against an upstream server and optional replicas.
.DESCRIPTION
Connects through the WSUS administration API and removes obsolete computers, updates, and content while declining expired and superseded updates.
.NOTES
High-impact maintenance operation. Use -WhatIf, then test on controlled non-production WSUS infrastructure and validate backups before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [string]$Server,

    [ValidateRange(1, 65535)]
    [int]$Port = 8531,

    [switch]$UseSsl,

    [switch]$IncludeDownstreamServers
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName 'Microsoft.UpdateServices.Administration'

function Invoke-Cleanup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Microsoft.UpdateServices.Administration.IUpdateServer]$Wsus
    )

    $scope = New-Object Microsoft.UpdateServices.Administration.CleanupScope
    $scope.CleanupObsoleteComputers = $true
    $scope.CleanupObsoleteUpdates = $true
    $scope.CleanupUnneededContentFiles = $true
    $scope.CompressUpdates = $true
    $scope.DeclineExpiredUpdates = $true
    $scope.DeclineSupersededUpdates = $true

    $result = $Wsus.GetCleanupManager().PerformCleanup($scope)
    [pscustomobject]@{
        Server = $Wsus.Name
        Result = $result
    }
}

if ($PSCmdlet.ShouldProcess($Server, 'Run WSUS cleanup')) {
    $parent = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer(
        $Server,
        [bool]$UseSsl,
        $Port
    )
    Invoke-Cleanup -Wsus $parent

    if ($IncludeDownstreamServers) {
        foreach ($downstream in $parent.GetDownstreamServers()) {
            if ($downstream.IsReplicaServer -and $PSCmdlet.ShouldProcess($downstream.FullDomainName, 'Run WSUS cleanup')) {
                $replica = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer(
                    $downstream.FullDomainName,
                    [bool]$UseSsl,
                    $Port
                )
                Invoke-Cleanup -Wsus $replica
            }
        }
    }
}
