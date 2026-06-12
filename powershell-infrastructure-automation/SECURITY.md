# Project Security

Do not commit credentials, exported inventories, production reports, tenant identifiers, internal DNS names, IP addresses, distinguished names, or user data.

Use certificate-based authentication, managed identity, a secret manager, or an interactive login protected by MFA. Do not add plaintext client secrets to scripts or example files.

Run destructive commands with `-WhatIf`, test against a non-production scope, and retain an export of the affected objects before applying changes.

Never treat a successful `-WhatIf` as sufficient production validation. Execute the real change in a controlled non-production environment, inspect the outcome, and test the rollback procedure first.

Follow the repository-level [security policy](../SECURITY.md) when reporting a vulnerability.
