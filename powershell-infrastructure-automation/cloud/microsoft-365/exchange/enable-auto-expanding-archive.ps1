#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules ExchangeOnlineManagement

<#
.SYNOPSIS
Enables archive and auto-expanding archive for Exchange Online mailboxes.
.DESCRIPTION
Processes specified users or all user mailboxes, enables a missing archive mailbox, and then enables auto-expanding archive when required.
.NOTES
Changes mailbox configuration. Use -WhatIf, then test with controlled non-production mailboxes and review the result before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [string[]]$UserPrincipalName
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-ExchangeOnline -ShowBanner:$false

$mailboxes = if ($UserPrincipalName) {
    foreach ($identity in $UserPrincipalName) {
        Get-Mailbox -Identity $identity
    }
}
else {
    Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited
}

foreach ($mailbox in $mailboxes) {
    if ($mailbox.ArchiveStatus -ne 'Active' -and $PSCmdlet.ShouldProcess($mailbox.UserPrincipalName, 'Enable archive mailbox')) {
        Enable-Mailbox -Identity $mailbox.UserPrincipalName -Archive
    }

    $refreshedMailbox = Get-Mailbox -Identity $mailbox.UserPrincipalName
    if (-not $refreshedMailbox.AutoExpandingArchiveEnabled -and $PSCmdlet.ShouldProcess($mailbox.UserPrincipalName, 'Enable auto-expanding archive')) {
        Enable-Mailbox -Identity $mailbox.UserPrincipalName -AutoExpandingArchive
    }
}
