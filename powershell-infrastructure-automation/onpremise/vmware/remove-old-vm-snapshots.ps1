#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules VMware.VimAutomation.Core

<#
.SYNOPSIS
Removes VMware snapshots older than a configured retention period.
.DESCRIPTION
Connects to vCenter, finds old snapshots across selected or all VMs, removes approved snapshots, and writes an audit CSV.
.NOTES
Destructive VMware operation. Use -WhatIf, then test on controlled non-production VMs and validate recovery and consolidation before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [string]$Server,

    [Parameter(Mandatory)]
    [pscredential]$Credential,

    [ValidateRange(1, 3650)]
    [int]$OlderThanDays = 30,

    [string[]]$VmName = @(),

    [Parameter(Mandatory)]
    [string]$AuditPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$cutoff = (Get-Date).AddDays(-$OlderThanDays)
$audit = [System.Collections.Generic.List[object]]::new()
$connection = Connect-VIServer -Server $Server -Credential $Credential

try {
    $virtualMachines = if ($VmName.Count -gt 0) {
        Get-VM -Name $VmName
    }
    else {
        Get-VM
    }

    $snapshots = $virtualMachines |
        Get-Snapshot |
        Where-Object Created -LT $cutoff |
        Sort-Object Created

    foreach ($snapshot in $snapshots) {
        $status = 'WhatIf'
        if ($PSCmdlet.ShouldProcess($snapshot.VM.Name, "Remove snapshot '$($snapshot.Name)' created at $($snapshot.Created)")) {
            Remove-Snapshot -Snapshot $snapshot -Confirm:$false | Out-Null
            $status = 'Removed'
        }

        $audit.Add([pscustomobject]@{
            TimestampUtc   = (Get-Date).ToUniversalTime()
            VmName         = $snapshot.VM.Name
            SnapshotName   = $snapshot.Name
            SnapshotCreated = $snapshot.Created
            Status         = $status
        })
    }
}
finally {
    Disconnect-VIServer -Server $connection -Confirm:$false
}

$auditDirectory = Split-Path -Parent $AuditPath
if ($auditDirectory) {
    New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null
}
$audit | Export-Csv -LiteralPath $AuditPath -NoTypeInformation -Encoding utf8
