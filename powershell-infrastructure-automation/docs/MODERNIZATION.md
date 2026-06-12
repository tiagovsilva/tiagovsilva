# Modernization Basis

The collection follows current vendor guidance:

- PowerShell `#Requires -Version` and `#Requires -PSEdition` are used to enforce runtime compatibility:
  https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/7.7/Microsoft.PowerShell.Core/About/about_Requires.md
- Microsoft Graph PowerShell replaces deprecated AzureAD and MSOnline modules:
  https://learn.microsoft.com/powershell/microsoftgraph/migration-steps
- Microsoft Graph unattended authentication uses an application certificate:
  https://learn.microsoft.com/powershell/microsoftgraph/app-only
- Microsoft Graph delegated and app-only authentication patterns:
  https://learn.microsoft.com/powershell/microsoftgraph/authentication-commands
- PnP PowerShell interactive authentication requires an Entra application client ID:
  https://pnp.github.io/powershell/cmdlets/Connect-PnPOnline.html
- PnP PowerShell 3 uses PowerShell 7.4 and .NET 8:
  https://pnp.github.io/blog/pnp-powershell/pnp-powershell-v3-0-0/
- VMware PowerCLI snapshot command reference:
  https://developer.broadcom.com/powercli/latest/products/vmwarevsphereandvsan/commands-index

API permissions and module versions must still be reviewed at deployment time because tenant policy and vendor behavior can change.

PowerShell compatibility guidance and Microsoft Graph authentication examples were also checked through Context7 against the official Microsoft documentation repositories.
