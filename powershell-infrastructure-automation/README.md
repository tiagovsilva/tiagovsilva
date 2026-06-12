# PowerShell Infrastructure Automation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)

Documented PowerShell automation for identity, Microsoft cloud services, Windows infrastructure, WSUS, and VMware.

> [!WARNING]
> Do not execute these scripts directly in production. Test first in a controlled lab, sandbox, test tenant, test OU, or limited non-production scope. Review the results and confirm a rollback path before production use.

## Find a script

| Area | Includes |
|---|---|
| [Cloud](cloud/) | Microsoft Entra ID, Microsoft Graph, Exchange Online, SharePoint Online, Azure File Sync |
| [Hybrid](hybrid/) | Active Directory and Microsoft cloud correlation workflows |
| [On-premises](onpremise/) | Active Directory, Windows, filesystem, WSUS, and VMware |

Use the [script catalog](docs/SCRIPT-CATALOG.md) for a one-line description of every script.

## Quick start

1. Open the [compatibility matrix](docs/COMPATIBILITY.md).
2. Review the comment-based help at the top of the script.
3. Check the [safe examples](docs/EXAMPLES.md).
4. Install only the modules listed in the script's `#Requires` statements.
5. Run modifying scripts with `-WhatIf` against a lab or limited scope first.
6. Follow the [testing-before-production policy](docs/TESTING.md).

## Safety

- Scripts do not contain tenant IDs, domains, hostnames, credentials, email addresses, internal paths, or organization names.
- Destructive scripts implement `SupportsShouldProcess`; run with `-WhatIf` first.
- Unattended Microsoft Graph automation uses certificate-based authentication.
- Interactive scripts use delegated authentication with explicit scopes.
- Generated reports and credentials are ignored by Git.

## PowerShell compatibility

- Windows PowerShell 5.1 / Desktop is retained for scripts that depend on Windows-only management components such as ActiveDirectory, WSUS, Azure File Sync agent cmdlets, registry providers, and legacy server tooling.
- PowerShell 7.4 / Core is used for current cloud administration with Microsoft Graph, Exchange Online, and PnP PowerShell.
- Every PowerShell file declares its minimum version and edition with `#Requires`.

Review [docs/COMPATIBILITY.md](docs/COMPATIBILITY.md) before selecting a runtime.

Use [docs/SCRIPT-CATALOG.md](docs/SCRIPT-CATALOG.md) to find scripts by platform and purpose.

## Support

- Read [SECURITY.md](SECURITY.md) before reporting a security issue.
- These scripts are provided under the [MIT License](../LICENSE).

Scripts must be reviewed and tested in a controlled non-production environment before production use.
