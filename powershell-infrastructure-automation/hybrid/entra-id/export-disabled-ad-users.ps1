#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Exports disabled on-premises Active Directory users for a cloud review workflow.
.DESCRIPTION
Reads disabled users under an AD search base and writes their user principal name, email address, and change date to CSV.
.NOTES
Read-only operation. The generated CSV contains personal data and must remain outside Git.
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

$users = Get-ADUser `
    -Filter 'Enabled -eq $false' `
    -SearchBase $SearchBase `
    -Properties UserPrincipalName, Mail, WhenChanged |
    Where-Object UserPrincipalName |
    Select-Object UserPrincipalName, Mail, WhenChanged

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$users | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8

Write-Warning 'The exported CSV contains personal data. Keep it outside Git and delete it after the review workflow.'
