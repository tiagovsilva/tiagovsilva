# Safe Usage Examples

Run commands from the `powershell-infrastructure-automation` directory. Replace placeholders with reviewed environment values. Modifying examples use `-WhatIf` where supported.

> [!CAUTION]
> Examples are not production runbooks. Execute them first in a controlled non-production environment, inspect the result and side effects, and verify a tested rollback path.

## Cloud

### Azure File Sync

```powershell
.\cloud\azure-files\set-storage-sync-network-limit.ps1 `
    -Day Monday, Tuesday, Wednesday, Thursday, Friday `
    -StartHour 8 `
    -EndHour 18 `
    -LimitKbps 1024 `
    -WhatIf
```

### Microsoft Entra ID

```powershell
.\cloud\entra-id\export-app-credential-expiry.ps1 `
    -ExpiresWithinDays 45 `
    -OutputPath .\output\app-credential-expiry.csv
```

```powershell
$tenantId = Read-Host 'Tenant ID'
$clientId = Read-Host 'Application client ID'
$thumbprint = Read-Host 'Certificate thumbprint'

.\cloud\entra-id\remove-disabled-user-licenses.ps1 `
    -TenantId $tenantId `
    -ClientId $clientId `
    -CertificateThumbprint $thumbprint `
    -ExcludedSkuPartNumber 'SKU_TO_KEEP' `
    -AuditPath .\output\license-removal-audit.csv `
    -WhatIf
```

```powershell
.\cloud\entra-id\reset-user-phone-authentication.ps1 `
    -UserId 'user-principal-name' `
    -PhoneType mobile `
    -AuditPath .\output\authentication-reset-audit.csv `
    -WhatIf
```

```powershell
.\cloud\entra-id\set-managed-device-category.ps1 `
    -CategoryName 'Shared devices' `
    -DeviceName 'DEVICE-001', 'DEVICE-002' `
    -WhatIf
```

### Exchange Online

```powershell
.\cloud\microsoft-365\exchange\enable-auto-expanding-archive.ps1 `
    -UserPrincipalName 'user-principal-name' `
    -WhatIf
```

```powershell
$password = Read-Host 'Temporary room mailbox password' -AsSecureString

.\cloud\microsoft-365\exchange\new-room-mailbox.ps1 `
    -Name 'Training Room' `
    -Alias 'training-room' `
    -UserPrincipalName 'room-principal-name' `
    -Password $password `
    -Capacity 12 `
    -WhatIf
```

```powershell
.\cloud\microsoft-365\exchange\start-archive-assistant.ps1 `
    -MinimumMailboxUsagePercent 85 `
    -WhatIf
```

### SharePoint Online

```powershell
$siteUrl = Read-Host 'SharePoint site URL'
$clientId = Read-Host 'PnP application client ID'

.\cloud\microsoft-365\sharepoint\export-site-template.ps1 `
    -SiteUrl $siteUrl `
    -ClientId $clientId `
    -OutputPath .\output\site-template.xml
```

The CSV for site creation must contain `Title` and `Alias` columns.

```powershell
$adminUrl = Read-Host 'SharePoint admin URL'
$clientId = Read-Host 'PnP application client ID'
$owner = Read-Host 'Site owner principal name'

.\cloud\microsoft-365\sharepoint\new-team-sites-from-csv.ps1 `
    -AdminUrl $adminUrl `
    -ClientId $clientId `
    -InputPath .\input\sites.csv `
    -Owner $owner `
    -LocaleId 1033 `
    -AuditPath .\output\site-creation-audit.csv `
    -WhatIf
```

## Hybrid

```powershell
.\hybrid\entra-id\export-disabled-ad-users.ps1 `
    -SearchBase 'OU=Disabled,DC=example,DC=test' `
    -OutputPath .\output\disabled-users.csv
```

```powershell
.\hybrid\entra-id\export-hybrid-user-inventory.ps1 `
    -SearchBase 'OU=Users,DC=example,DC=test' `
    -DomainController 'dc01.example.test' `
    -OutputPath .\output\hybrid-user-inventory.csv `
    -IncludeExchange
```

```powershell
.\hybrid\entra-id\get-ad-cloud-anchor.ps1 `
    -Identity 'sample.user' `
    -DomainController 'dc01.example.test'
```

## On-Premises

### Active Directory

```powershell
.\onpremise\active-directory\export-group-members.ps1 `
    -GroupIdentity 'Sample Group' `
    -OutputPath .\output\group-members.csv `
    -Recursive
```

```powershell
.\onpremise\active-directory\export-nested-group-membership.ps1 `
    -SearchBase 'OU=Users,DC=example,DC=test' `
    -OutputPath .\output\user-group-membership.csv
```

```powershell
.\onpremise\active-directory\move-disabled-users.ps1 `
    -SearchBase 'OU=Users,DC=example,DC=test' `
    -DestinationOu 'OU=Disabled,DC=example,DC=test' `
    -AuditPath .\output\disabled-user-move-audit.csv `
    -WhatIf
```

```powershell
.\onpremise\active-directory\set-accidental-deletion-protection.ps1 `
    -SearchBase 'OU=Managed,DC=example,DC=test' `
    -ObjectClass organizationalUnit `
    -Protected $true `
    -WhatIf
```

```powershell
.\onpremise\active-directory\test-ad-replication.ps1 `
    -OutputDirectory .\output\ad-replication `
    -IncludeDnsDiagnostics
```

### Filesystem

```powershell
.\onpremise\filesystem\invoke-robocopy.ps1 `
    -Source 'D:\Source' `
    -Destination 'E:\Destination' `
    -CopySecurity `
    -LogPath .\output\robocopy.log `
    -WhatIf
```

```powershell
.\onpremise\filesystem\new-directory-symbolic-link.ps1 `
    -LinkPath 'C:\Links\SharedData' `
    -TargetPath 'D:\SharedData' `
    -WhatIf
```

### VMware

```powershell
$credential = Get-Credential

.\onpremise\vmware\new-vm-snapshots.ps1 `
    -Server 'vcenter.example.test' `
    -Credential $credential `
    -VmName 'VM-001', 'VM-002' `
    -NamePrefix 'maintenance' `
    -WhatIf
```

```powershell
$credential = Get-Credential

.\onpremise\vmware\remove-old-vm-snapshots.ps1 `
    -Server 'vcenter.example.test' `
    -Credential $credential `
    -OlderThanDays 30 `
    -AuditPath .\output\snapshot-removal-audit.csv `
    -WhatIf
```

### Windows Client

```powershell
.\onpremise\windows-client\reset-group-policy-cache.ps1 `
    -BackupDirectory 'C:\ProgramData\GroupPolicyCacheBackup' `
    -WhatIf
```

```powershell
.\onpremise\windows-client\set-outlook-data-file-limit.ps1 `
    -OfficeVersion '16.0' `
    -MaximumSizeMb 51200 `
    -WarningSizeMb 48640 `
    -WhatIf
```

```powershell
.\onpremise\windows-client\set-removable-storage-write-protection.ps1 `
    -WriteProtected $true `
    -WhatIf
```

### Windows Server and WSUS

```powershell
.\onpremise\windows-server\export-server-health.ps1 `
    -OutputPath .\output\server-health.json
```

```powershell
.\onpremise\wsus\invoke-wsus-cleanup.ps1 `
    -Server 'wsus.example.test' `
    -Port 8531 `
    -UseSsl `
    -IncludeDownstreamServers `
    -WhatIf
```

```powershell
.\onpremise\wsus\test-wsus-connection.ps1 `
    -Server 'wsus.example.test' `
    -Port 8531 `
    -UseTls
```
