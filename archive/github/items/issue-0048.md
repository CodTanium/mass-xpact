# Issue #48: Finding: assertions-on Finalized test lane does not check assertions (missing -keep)

Archived from <https://github.com/andersoxie/xpact/issues/48> on 2026-10-26 20:05 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 07:00 |
| Closed | 2026-10-22 07:04 |
| Labels | `type:finding`, `group:B-reliable-results`, `D2-guided`, `P0` |
| Milestone | Week 2 - Baseline |

## Description

﻿## Steps to reproduce
1. `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Finalized`
2. Compare with `ec -batch -clean -finalize -keep -config tests\xpact_tests.ecf -target xpact_tests_assertions`, then `finish_freezing` and run `xpact_tests.exe`

## Expected
Both runs check assertions and give the same result.

## Actual
In the baseline from 2026-10-14, step 1 reported "ok" (exit 0). Step 2, with `-keep`, failed with the same postcondition violation as the workbench lane. `run_eiffel_test_matrix.ps1` calls `ec -finalize` **without `-keep`**, so the finalized binary has no assertions compiled in. The green result is misleading, also in CI.

## Logs
Original logs: `student/baseline/logs/matrix-finalized.log`, `matrix-finalized-keep.log`.
Attach `matrix-finalized.log` and `matrix-finalized-keep.log` from a rerun in this checkout.

## Proposed next step
Add `-keep` to the finalized lane, as `build_native_eiffel.ps1` already does. **This changes what CI reports, so discuss it with the supervisor before changing it.**

## Discussion

### CodTanium, 2026-10-22 07:04: comment

Fixed in `ccd30ab` (PR #49). The assertions-on / Finalized lane now fails on #28, like the Workbench lane, until #28 is repaired.
