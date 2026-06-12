# Test Before Production

These scripts are examples and operational building blocks, not environment-independent guarantees.

Before using any script in production:

1. Read the complete script and its requirements.
2. Replace example values with reviewed environment-specific parameters.
3. Use `-WhatIf` when the script supports it.
4. Run the script in a controlled lab, sandbox, test tenant, test OU, or limited non-production scope.
5. Review logs, output, affected objects, permissions, performance impact, and failure behavior.
6. Confirm that backups, exports, or another tested rollback path exist.
7. Obtain the required change approval before production execution.

A successful test only validates the tested version, parameters, permissions, modules, and environment. Repeat testing after changing any of them.

