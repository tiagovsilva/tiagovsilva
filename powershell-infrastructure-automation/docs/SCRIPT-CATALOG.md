# Script Catalog

## Cloud

### Azure Files

| Script | Runtime | Purpose |
|---|---|---|
| [`set-storage-sync-network-limit.ps1`](../cloud/azure-files/set-storage-sync-network-limit.ps1) | Windows PowerShell 5.1 | Configures an upload bandwidth schedule for the local Azure File Sync agent. |

### Microsoft Entra ID

| Script | Runtime | Purpose |
|---|---|---|
| [`export-app-credential-expiry.ps1`](../cloud/entra-id/export-app-credential-expiry.ps1) | PowerShell 7.4 | Exports expired or expiring application credentials. |
| [`remove-disabled-user-licenses.ps1`](../cloud/entra-id/remove-disabled-user-licenses.ps1) | PowerShell 7.4 | Removes eligible directly assigned licenses from disabled users. |
| [`reset-user-phone-authentication.ps1`](../cloud/entra-id/reset-user-phone-authentication.ps1) | PowerShell 7.4 | Removes selected phone authentication methods from users. |
| [`set-managed-device-category.ps1`](../cloud/entra-id/set-managed-device-category.ps1) | PowerShell 7.4 | Assigns an Intune category to managed devices. |

### Exchange Online

| Script | Runtime | Purpose |
|---|---|---|
| [`enable-auto-expanding-archive.ps1`](../cloud/microsoft-365/exchange/enable-auto-expanding-archive.ps1) | PowerShell 7.4 | Enables archive and auto-expanding archive for mailboxes. |
| [`new-room-mailbox.ps1`](../cloud/microsoft-365/exchange/new-room-mailbox.ps1) | PowerShell 7.4 | Creates and configures a room mailbox. |
| [`start-archive-assistant.ps1`](../cloud/microsoft-365/exchange/start-archive-assistant.ps1) | PowerShell 7.4 | Starts archive processing for mailboxes above a usage threshold. |

### SharePoint Online

| Script | Runtime | Purpose |
|---|---|---|
| [`export-site-template.ps1`](../cloud/microsoft-365/sharepoint/export-site-template.ps1) | PowerShell 7.4 | Exports a site as a PnP provisioning template. |
| [`new-team-sites-from-csv.ps1`](../cloud/microsoft-365/sharepoint/new-team-sites-from-csv.ps1) | PowerShell 7.4 | Creates team sites from a CSV file. |

## Hybrid

| Script | Runtime | Purpose |
|---|---|---|
| [`export-disabled-ad-users.ps1`](../hybrid/entra-id/export-disabled-ad-users.ps1) | Windows PowerShell 5.1 | Exports disabled AD users for cloud review. |
| [`export-hybrid-user-inventory.ps1`](../hybrid/entra-id/export-hybrid-user-inventory.ps1) | Windows PowerShell 5.1 | Combines AD, Entra ID, licensing, and optional mailbox status. |
| [`get-ad-cloud-anchor.ps1`](../hybrid/entra-id/get-ad-cloud-anchor.ps1) | Windows PowerShell 5.1 | Displays AD cloud-anchor values for synchronization troubleshooting. |

## On-Premises

### Active Directory

| Script | Runtime | Purpose |
|---|---|---|
| [`export-group-members.ps1`](../onpremise/active-directory/export-group-members.ps1) | Windows PowerShell 5.1 | Exports direct or recursive user members of an AD group. |
| [`export-nested-group-membership.ps1`](../onpremise/active-directory/export-nested-group-membership.ps1) | Windows PowerShell 5.1 | Exports effective group relationships for users under a search base. |
| [`move-disabled-users.ps1`](../onpremise/active-directory/move-disabled-users.ps1) | Windows PowerShell 5.1 | Moves disabled users to a target OU with optional group removal. |
| [`set-accidental-deletion-protection.ps1`](../onpremise/active-directory/set-accidental-deletion-protection.ps1) | Windows PowerShell 5.1 | Changes accidental-deletion protection on selected AD objects. |
| [`test-ad-replication.ps1`](../onpremise/active-directory/test-ad-replication.ps1) | Windows PowerShell 5.1 | Collects repadmin, dcdiag, and optional DNS reports. |

### Filesystem

| Script | Runtime | Purpose |
|---|---|---|
| [`invoke-robocopy.ps1`](../onpremise/filesystem/invoke-robocopy.ps1) | Windows PowerShell 5.1 | Copies or mirrors directories with controlled Robocopy options. |
| [`new-directory-symbolic-link.ps1`](../onpremise/filesystem/new-directory-symbolic-link.ps1) | Windows PowerShell 5.1 | Creates a directory symbolic link to an existing target. |

### VMware

| Script | Runtime | Purpose |
|---|---|---|
| [`new-vm-snapshots.ps1`](../onpremise/vmware/new-vm-snapshots.ps1) | Windows PowerShell 5.1 | Creates timestamped snapshots for selected VMs. |
| [`remove-old-vm-snapshots.ps1`](../onpremise/vmware/remove-old-vm-snapshots.ps1) | Windows PowerShell 5.1 | Removes snapshots older than the retention period. |

### Windows Client

| Script | Runtime | Purpose |
|---|---|---|
| [`reset-group-policy-cache.ps1`](../onpremise/windows-client/reset-group-policy-cache.ps1) | Windows PowerShell 5.1 | Backs up and resets the local Group Policy cache. |
| [`set-outlook-data-file-limit.ps1`](../onpremise/windows-client/set-outlook-data-file-limit.ps1) | Windows PowerShell 5.1 | Configures Outlook Unicode PST and OST limits. |
| [`set-removable-storage-write-protection.ps1`](../onpremise/windows-client/set-removable-storage-write-protection.ps1) | Windows PowerShell 5.1 | Controls write protection for removable storage. |

### Windows Server and WSUS

| Script | Runtime | Purpose |
|---|---|---|
| [`export-server-health.ps1`](../onpremise/windows-server/export-server-health.ps1) | Windows PowerShell 5.1 | Exports a local Windows server health snapshot as JSON. |
| [`invoke-wsus-cleanup.ps1`](../onpremise/wsus/invoke-wsus-cleanup.ps1) | Windows PowerShell 5.1 | Runs WSUS cleanup against an upstream server and optional replicas. |
| [`test-wsus-connection.ps1`](../onpremise/wsus/test-wsus-connection.ps1) | Windows PowerShell 5.1 | Tests TCP and HTTP connectivity to WSUS. |

