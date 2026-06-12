#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Moves disabled Active Directory users to a destination organizational unit.
.DESCRIPTION
Finds disabled users under a search base, optionally removes their group memberships, moves them to the target OU, and writes an audit CSV.
.NOTES
Destructive directory operation. Use -WhatIf, then test with controlled non-production objects and validate restoration before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [string]$SearchBase,

    [Parameter(Mandatory)]
    [string]$DestinationOu,

    [switch]$RemoveGroupMembership,

    [Parameter(Mandatory)]
    [string]$AuditPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Get-ADOrganizationalUnit -Identity $DestinationOu | Out-Null
$audit = [System.Collections.Generic.List[object]]::new()
$users = Get-ADUser -Filter 'Enabled -eq $false' -SearchBase $SearchBase -Properties MemberOf, DistinguishedName

foreach ($user in $users) {
    $status = 'WhatIf'
    try {
        if ($RemoveGroupMembership) {
            foreach ($groupDn in $user.MemberOf) {
                if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Remove from group '$groupDn'")) {
                    Remove-ADGroupMember -Identity $groupDn -Members $user -Confirm:$false
                }
            }
        }

        if ($PSCmdlet.ShouldProcess($user.SamAccountName, "Move to '$DestinationOu'")) {
            Move-ADObject -Identity $user.DistinguishedName -TargetPath $DestinationOu
            $status = 'Moved'
        }
    }
    catch {
        $status = "Failed: $($_.Exception.Message)"
    }

    $audit.Add([pscustomobject]@{
        TimestampUtc  = (Get-Date).ToUniversalTime()
        SamAccountName = $user.SamAccountName
        Status         = $status
    })
}

$auditDirectory = Split-Path -Parent $AuditPath
if ($auditDirectory) {
    New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null
}
$audit | Export-Csv -LiteralPath $AuditPath -NoTypeInformation -Encoding utf8
