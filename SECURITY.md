# Security Policy

## Reporting a vulnerability

Do not open a public issue containing credentials, tenant data, user data, internal infrastructure details, or an exploitable security finding.

Use GitHub private vulnerability reporting when available. If it is unavailable, contact the repository owner through the public profile without including sensitive evidence in the first message.

## Repository safety rules

- Never commit secrets or real environment identifiers.
- Generated reports, inventories, credentials, and logs must remain outside Git.
- Run modifying scripts with `-WhatIf` and test in a non-production scope.
- Validate results, side effects, failure behavior, and rollback in a controlled environment before production execution.
- Review requested Microsoft Graph and service permissions before granting consent.
- Treat exported identity and infrastructure data as sensitive.

Supported security fixes target the current default branch.
