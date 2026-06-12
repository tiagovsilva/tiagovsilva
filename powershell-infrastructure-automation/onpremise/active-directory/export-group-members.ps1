#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Exports the user members of an Active Directory group.
.DESCRIPTION
Reads direct or recursive group membership, resolves user account details, and writes account name, display name, email, and enabled status to CSV.
.NOTES
Read-only operation. The generated CSV can contain personal data and must remain outside Git.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$GroupIdentity,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [switch]$Recursive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$parameters = @{
    Identity = $GroupIdentity
}
if ($Recursive) {
    $parameters.Recursive = $true
}

$rows = foreach ($member in Get-ADGroupMember @parameters) {
    if ($member.ObjectClass -eq 'user') {
        $user = Get-ADUser -Identity $member.DistinguishedName -Properties DisplayName, Mail, Enabled
        [pscustomobject]@{
            SamAccountName = $user.SamAccountName
            DisplayName    = $user.DisplayName
            Mail           = $user.Mail
            Enabled        = $user.Enabled
        }
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$rows | Sort-Object SamAccountName | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
