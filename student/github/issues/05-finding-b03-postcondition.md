---
title: "Finding: postcondition final_finished_or_suspended fails in GC-suspension test (B03)"
labels: group:B-reliable-results, D3-advanced, P0, type:finding
milestone: Week 2 - Baseline
---
## Steps to reproduce
1. `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Workbench`

## Expected
All tests pass with assertions on.

## Actual
In the baseline from 2026-10-14: `XP_NATIVE_PARSER.parse @10 final_finished_or_suspended: Postcondition violated`, raised from `XP_TEST_ROOT.test_garbage_collection_suspension`. It fails in workbench **and** in finalized-with-`-keep`.

## Logs
Original log: `student/baseline/logs/matrix-workbench.log`. Also seen 4 times in `student/results/xmlconf-crashes-2026-10-14/exception_trace.log`, and before the baseline (error report, section 5.1).
Seen again on 2026-10-19 (assertions-on / Workbench, via `run_phase1.ps1`): `student/results/error-report-2026-10-19/` (error 2, with `exception_trace.log`).
Attach `matrix-workbench.log` from a rerun in this checkout.

## Notes
This is task register B03 (D3): "Determine whether code, contract or test is wrong without suppressing the check." The student's part is a minimized reproduction and verifying the reviewed fix.
