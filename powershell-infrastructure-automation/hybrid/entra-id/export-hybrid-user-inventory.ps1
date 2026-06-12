#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory, Microsoft.Graph.Authentication, Microsoft.Graph.Users

<#
.SYNOPSIS
Builds a combined inventory of on-premises AD and Microsoft cloud users.
.DESCRIPTION
Matches Active Directory users with Microsoft Entra records and optionally Exchange Online mailboxes, then exports identity, synchronization, licensing, and mailbox status to CSV.
.NOTES
Read-only operation. The generated inventory contains directory and personal data and must remain outside Git.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SearchBase,

    [string]$DomainController,

    [Parameter(Mandatory)]
    [string]$OutputPath,

    [switch]$IncludeExchange
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-MgGraph -Scopes 'User.Read.All', 'Directory.Read.All' -NoWelcome

$cloudUsers = @{}
foreach ($cloudUser in Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, AccountEnabled, AssignedLicenses, OnPremisesSyncEnabled, OnPremisesImmutableId) {
    if ($cloudUser.UserPrincipalName) {
        $cloudUsers[$cloudUser.UserPrincipalName.ToLowerInvariant()] = $cloudUser
    }
}

$mailboxes = @{}
if ($IncludeExchange) {
    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        throw 'ExchangeOnlineManagement is required when IncludeExchange is used.'
    }

    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline -ShowBanner:$false
    foreach ($mailbox in Get-EXOMailbox -ResultSize Unlimited -Properties UserPrincipalName, RecipientTypeDetails) {
        if ($mailbox.UserPrincipalName) {
            $mailboxes[$mailbox.UserPrincipalName.ToLowerInvariant()] = $mailbox
        }
    }
}

$adParameters = @{
    LDAPFilter = '(userPrincipalName=*)'
    SearchBase = $SearchBase
    Properties = @(
        'DisplayName'
        'UserPrincipalName'
        'Mail'
        'Department'
        'Title'
        'Company'
        'Manager'
        'Enabled'
        'LastLogonTimestamp'
        'ObjectGuid'
        'mS-DS-ConsistencyGuid'
    )
}
if ($DomainController) {
    $adParameters.Server = $DomainController
}

$rows = foreach ($adUser in Get-ADUser @adParameters) {
    $key = $adUser.UserPrincipalName.ToLowerInvariant()
    $cloudUser = $cloudUsers[$key]
    $mailbox = $mailboxes[$key]
    $lastLogon = $null
    if ($adUser.LastLogonTimestamp) {
        $lastLogon = [datetime]::FromFileTime($adUser.LastLogonTimestamp)
    }

    [pscustomobject]@{
        DisplayName              = $adUser.DisplayName
        UserPrincipalName        = $adUser.UserPrincipalName
        Mail                     = $adUser.Mail
        Department               = $adUser.Department
        Title                    = $adUser.Title
        Company                  = $adUser.Company
        ManagerDistinguishedName = $adUser.Manager
        AdEnabled                = $adUser.Enabled
        AdLastLogon              = $lastLogon
        AdObjectGuid             = $adUser.ObjectGuid
        CloudObjectId            = if ($cloudUser) { $cloudUser.Id } else { $null }
        CloudEnabled             = if ($cloudUser) { $cloudUser.AccountEnabled } else { $null }
        CloudLicenseCount        = if ($cloudUser) { $cloudUser.AssignedLicenses.Count } else { 0 }
        OnPremisesSyncEnabled    = if ($cloudUser) { $cloudUser.OnPremisesSyncEnabled } else { $null }
        MailboxRecipientType     = if ($mailbox) { $mailbox.RecipientTypeDetails } else { $null }
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8

Write-Warning 'The exported CSV contains personal and directory data. Keep it outside Git.'
