## Summary

Describe the script or documentation change.

## Runtime

- [ ] Windows PowerShell 5.1 / Desktop
- [ ] PowerShell 7.4 / Core
- [ ] Documentation only

## Safety

- [ ] No credentials, real identifiers, user data, inventory, or internal paths are included.
- [ ] Modifying operations implement `SupportsShouldProcess`.
- [ ] I tested the modifying command with `-WhatIf`.
- [ ] I tested the result in a controlled non-production environment.
- [ ] I reviewed side effects, failure behavior, and the rollback path.
- [ ] Required permissions and modules are documented.

## Validation

- [ ] `tests/Test-Repository.ps1` passes.
- [ ] PSScriptAnalyzer passes.
- [ ] The script catalog and examples were updated when applicable.
