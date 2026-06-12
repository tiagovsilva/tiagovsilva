# Contributing

Contributions that improve correctness, safety, documentation, and compatibility are welcome.

## Requirements

- Keep scripts organized under `cloud`, `hybrid`, or `onpremise`.
- Declare the minimum version and edition with `#Requires -Version` and `#Requires -PSEdition`.
- Add `.SYNOPSIS`, `.DESCRIPTION`, and `.NOTES`.
- Add a safe example to `docs/EXAMPLES.md` or an `.EXAMPLE` section in the script.
- Use explicit parameters instead of organization-specific constants.
- Use `SupportsShouldProcess` for operations that create, update, move, remove, or enable resources.
- Do not install modules automatically from operational scripts.
- Preserve Windows PowerShell 5.1 compatibility when a script depends on Windows-only modules.

## Sensitive information

Never submit:

- Credentials, secrets, tokens, certificates, or private keys
- Tenant, subscription, application, or object identifiers
- Real domains, hostnames, IP addresses, email addresses, distinguished names, or share paths
- User exports, server inventories, logs, reports, or production output
- Proprietary scripts or code without redistribution permission

Use placeholders such as `contoso.example`, `server.example`, and non-routable documentation addresses when examples require values.

## Validation

Before opening a pull request:

```powershell
pwsh -File ./powershell-infrastructure-automation/tests/Test-Repository.ps1
Invoke-ScriptAnalyzer -Path ./powershell-infrastructure-automation -Recurse -Settings ./powershell-infrastructure-automation/PSScriptAnalyzerSettings.psd1
```

For modifying scripts, include the `-WhatIf` command used during validation and describe the lab or limited scope tested.
Do not claim production readiness without documenting controlled-environment results, known side effects, and the rollback approach.
