#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Exports Active Directory group membership for every user under a search base.
.DESCRIPTION
Enumerates users, resolves their effective principal group memberships, and writes one CSV row for each user and group relationship.
.NOTES
Read-only operation. Large search bases can generate substantial directory load and sensitive output.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SearchBase,

    [Parameter(Mandatory)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rows = foreach ($user in Get-ADUser -Filter * -SearchBase $SearchBase -Properties DisplayName) {
    $groups = Get-ADPrincipalGroupMembership -Identity $user |
        Sort-Object Name

    foreach ($group in $groups) {
        [pscustomobject]@{
            SamAccountName = $user.SamAccountName
            DisplayName    = $user.DisplayName
            GroupName      = $group.Name
            GroupScope     = $group.GroupScope
            GroupCategory  = $group.GroupCategory
        }
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8
