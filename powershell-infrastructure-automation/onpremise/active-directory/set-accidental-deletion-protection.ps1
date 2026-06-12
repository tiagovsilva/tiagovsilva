#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Enables or disables accidental-deletion protection on selected Active Directory objects.
.DESCRIPTION
Finds supported object classes under a search base whose current protection differs from the requested state and updates the matching objects.
.NOTES
Changes directory protection. Use -WhatIf, then test with controlled non-production objects and validate reversal before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [string]$SearchBase,

    [ValidateSet('organizationalUnit', 'group', 'user', 'computer')]
    [string[]]$ObjectClass = @('organizationalUnit'),

    [bool]$Protected = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$objects = Get-ADObject `
    -SearchBase $SearchBase `
    -SearchScope Subtree `
    -LDAPFilter '(|(objectClass=organizationalUnit)(objectClass=group)(objectClass=user)(objectClass=computer))' `
    -Properties ObjectClass, ProtectedFromAccidentalDeletion |
    Where-Object {
        $_.ObjectClass -in $ObjectClass -and
        $_.ProtectedFromAccidentalDeletion -ne $Protected
    }

foreach ($object in $objects) {
    if ($PSCmdlet.ShouldProcess($object.DistinguishedName, "Set ProtectedFromAccidentalDeletion to '$Protected'")) {
        Set-ADObject -Identity $object -ProtectedFromAccidentalDeletion $Protected
    }
}
