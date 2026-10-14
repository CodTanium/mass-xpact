---
title: "Finding: assertions-on Finalized test lane does not check assertions (missing -keep)"
labels: group:B-reliable-results, D2-guided, P0, type:finding
milestone: Week 2 - Baseline
---
## Steps to reproduce
1. `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Finalized`
2. Compare with `ec -batch -clean -finalize -keep -config tests\xpact_tests.ecf -target xpact_tests_assertions`, then `finish_freezing` and run `xpact_tests.exe`

## Expected
Both runs check assertions and give the same result.

## Actual
In the baseline from 2026-10-14, step 1 reported "ok" (exit 0). Step 2, with `-keep`, failed with the same postcondition violation as the workbench lane. `run_eiffel_test_matrix.ps1` calls `ec -finalize` **without `-keep`**, so the finalized binary has no assertions compiled in. The green result is misleading, also in CI.

## Logs
Attach `matrix-finalized.log` and `matrix-finalized-keep.log` from a rerun in this checkout.

## Proposed next step
Add `-keep` to the finalized lane, as `build_native_eiffel.ps1` already does. **This changes what CI reports, so discuss it with the supervisor before changing it.**
