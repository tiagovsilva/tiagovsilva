#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
Creates VMware snapshots for selected virtual machines.
.DESCRIPTION
Connects to vCenter, resolves the requested VMs, creates timestamped disk-only snapshots, and disconnects from the server.
.NOTES
Snapshots affect storage and VM operations. Use -WhatIf, then test on controlled non-production VMs and validate removal before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [string]$Server,

    [Parameter(Mandatory)]
    [pscredential]$Credential,

    [Parameter(Mandatory)]
    [string[]]$VmName,

    [string]$NamePrefix = 'maintenance',

    [string]$Description = 'Snapshot created by infrastructure automation'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$connection = Connect-VIServer -Server $Server -Credential $Credential
try {
    foreach ($name in $VmName) {
        $vm = Get-VM -Name $name -ErrorAction Stop
        $snapshotName = '{0}-{1:yyyyMMdd-HHmmss}' -f $NamePrefix, (Get-Date)

        if ($PSCmdlet.ShouldProcess($name, "Create snapshot '$snapshotName'")) {
            New-Snapshot `
                -VM $vm `
                -Name $snapshotName `
                -Description $Description `
                -Memory:$false `
                -Quiesce:$false `
                -Confirm:$false | Out-Null
        }
    }
}
finally {
    Disconnect-VIServer -Server $connection -Confirm:$false
}
