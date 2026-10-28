# Issue #60: Finding: the test runner stops at the first failure, so later tests do not run

Archived from <https://github.com/andersoxie/xpact/issues/60> on 2026-10-28 21:36 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 12:09 |
| Closed | 2026-10-22 12:14 |
| Labels | `type:finding`, `group:B-reliable-results`, `D2-guided`, `P0`, `test` |
| Milestone | Week 3 - Failure reporting |

## Description

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

## Update 2026-10-22
Still true after the #28 repair: with assertions on, the run stops in `test_garbage_collection_suspension` (B03, #3), test 35 of 42 in `XP_TEST_ROOT.make`, so the last 7 tests do not run.

## Discussion

### CodTanium, 2026-10-22 12:14: comment

Fixed in `aff0584` (PR #61). With assertions on, all 42 tests run; B03 is recorded with its trace.
