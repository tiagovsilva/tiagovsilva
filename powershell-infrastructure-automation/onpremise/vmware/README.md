# VMware

| Script | Purpose |
|---|---|
| [`new-vm-snapshots.ps1`](new-vm-snapshots.ps1) | Creates timestamped VM snapshots. |
| [`remove-old-vm-snapshots.ps1`](remove-old-vm-snapshots.ps1) | Removes snapshots older than the retention period. |

Snapshot operations can create storage and consolidation load. Use `-WhatIf` and an approved maintenance window.

