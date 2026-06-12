# PowerShell Compatibility

Each script contains authoritative `#Requires` directives. This matrix is a navigation aid.

## Windows PowerShell 5.1 / Desktop

These scripts retain Windows PowerShell 5.1 because they depend on Windows-only providers, local server components, or modules commonly hosted in the Desktop edition:

- `cloud/azure-files/set-storage-sync-network-limit.ps1`
- `hybrid/entra-id/export-disabled-ad-users.ps1`
- `hybrid/entra-id/export-hybrid-user-inventory.ps1`
- `hybrid/entra-id/get-ad-cloud-anchor.ps1`
- `onpremise/active-directory/export-group-members.ps1`
- `onpremise/active-directory/export-nested-group-membership.ps1`
- `onpremise/active-directory/move-disabled-users.ps1`
- `onpremise/active-directory/set-accidental-deletion-protection.ps1`
- `onpremise/active-directory/test-ad-replication.ps1`
- `onpremise/filesystem/invoke-robocopy.ps1`
- `onpremise/filesystem/new-directory-symbolic-link.ps1`
- `onpremise/vmware/new-vm-snapshots.ps1`
- `onpremise/vmware/remove-old-vm-snapshots.ps1`
- `onpremise/windows-client/reset-group-policy-cache.ps1`
- `onpremise/windows-client/set-outlook-data-file-limit.ps1`
- `onpremise/windows-client/set-removable-storage-write-protection.ps1`
- `onpremise/windows-server/export-server-health.ps1`
- `onpremise/wsus/invoke-wsus-cleanup.ps1`
- `onpremise/wsus/test-wsus-connection.ps1`

## PowerShell 7.4 / Core

These scripts use current cloud modules and are intentionally isolated from Windows PowerShell:

- `cloud/entra-id/export-app-credential-expiry.ps1`
- `cloud/entra-id/remove-disabled-user-licenses.ps1`
- `cloud/entra-id/reset-user-phone-authentication.ps1`
- `cloud/entra-id/set-managed-device-category.ps1`
- `cloud/microsoft-365/exchange/enable-auto-expanding-archive.ps1`
- `cloud/microsoft-365/exchange/new-room-mailbox.ps1`
- `cloud/microsoft-365/exchange/start-archive-assistant.ps1`
- `cloud/microsoft-365/sharepoint/export-site-template.ps1`
- `cloud/microsoft-365/sharepoint/new-team-sites-from-csv.ps1`

## Policy

- Do not remove or weaken a `#Requires` directive only to bypass a runtime error.
- Test module imports in the declared edition before execution.
- When modernizing a 5.1 script, create and validate a separate 7.x replacement before changing its declared edition.

