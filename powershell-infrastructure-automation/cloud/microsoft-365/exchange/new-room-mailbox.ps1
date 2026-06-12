#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules ExchangeOnlineManagement

<#
.SYNOPSIS
Creates and configures an Exchange Online room mailbox.
.DESCRIPTION
Creates a room mailbox account, configures automatic meeting acceptance and privacy behavior, and records the room capacity.
.NOTES
Creates a cloud identity and mailbox. Use -WhatIf, then test in a controlled non-production tenant and validate cleanup before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [ValidatePattern('^[a-zA-Z0-9._-]+$')]
    [string]$Alias,

    [Parameter(Mandatory)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory)]
    [securestring]$Password,

    [ValidateRange(1, 1000)]
    [int]$Capacity = 10
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-ExchangeOnline -ShowBanner:$false

if ($PSCmdlet.ShouldProcess($UserPrincipalName, "Create room mailbox '$Name'")) {
    New-Mailbox `
        -Name $Name `
        -Alias $Alias `
        -UserPrincipalName $UserPrincipalName `
        -Room `
        -EnableRoomMailboxAccount $true `
        -RoomMailboxPassword $Password

    Set-CalendarProcessing `
        -Identity $UserPrincipalName `
        -AutomateProcessing AutoAccept `
        -AddOrganizerToSubject $false `
        -AllowConflicts $false `
        -DeleteComments $false `
        -DeleteSubject $false `
        -RemovePrivateProperty $false

    Set-Place -Identity $UserPrincipalName -Capacity $Capacity
}
