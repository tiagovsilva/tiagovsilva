#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules ExchangeOnlineManagement

<#
.SYNOPSIS
Starts Exchange Online archive processing for mailboxes above a usage threshold.
.DESCRIPTION
Calculates mailbox usage against the send quota and invokes the Managed Folder Assistant for active archives that meet the configured percentage.
.NOTES
Triggers mailbox processing. Use -WhatIf, then test with controlled non-production mailboxes and review archive behavior before production.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateRange(1, 100)]
    [double]$MinimumMailboxUsagePercent = 80
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-ExchangeOnline -ShowBanner:$false

$mailboxes = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited |
    Where-Object ArchiveStatus -EQ 'Active'

foreach ($mailbox in $mailboxes) {
    $statistics = Get-MailboxStatistics -Identity $mailbox.UserPrincipalName
    if (-not $statistics.TotalItemSize -or $mailbox.ProhibitSendQuota.IsUnlimited) {
        continue
    }

    $usedBytes = $statistics.TotalItemSize.Value.ToBytes()
    $quotaBytes = $mailbox.ProhibitSendQuota.Value.ToBytes()
    $usagePercent = [math]::Round(($usedBytes / $quotaBytes) * 100, 2)

    if ($usagePercent -ge $MinimumMailboxUsagePercent -and $PSCmdlet.ShouldProcess($mailbox.UserPrincipalName, "Start Managed Folder Assistant at $usagePercent% usage")) {
        Start-ManagedFolderAssistant -Identity $mailbox.UserPrincipalName
    }
}
