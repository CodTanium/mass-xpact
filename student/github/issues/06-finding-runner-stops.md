---
title: "Finding: the test runner stops at the first failure, so later tests do not run"
labels: group:B-reliable-results, D2-guided, P0, type:finding
milestone: Week 2 - Baseline
---
## Steps to reproduce
1. Run the assertions-on workbench lane (see the B03 finding).
2. Compare the tests reported before the failure in `test_garbage_collection_suspension` with the list of all tests.

## Expected
Every test runs. Failures are counted and reported at the end.

## Actual
In the baseline from 2026-10-14, the run stopped at the B03 contract violation, so the tests after it did not run in the assertions-on lanes. Their status is unknown.

## Logs
Original logs: `student/baseline/logs/matrix-workbench.log`, `matrix-finalized-keep.log`.
Attach the list of tests that ran and the list of tests that exist.

## Notes
Related to B01 / B02 (failure reporting) and B04 (report crashes and incomplete runs separately).
