# Issue #45: B01 - Failing tests must return a nonzero exit status

Archived from <https://github.com/andersoxie/xpact/issues/45> on 2026-10-28 19:58 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 00:23 |
| Closed | 2026-10-22 12:21 |
| Labels | `type:task`, `group:B-reliable-results`, `D2-guided`, `P0`, `test` |
| Milestone | Week 3 - Failure reporting |

## Description

## Goal
Accumulated failures in the main and native runtime test runners must make the process exit nonzero, independently of Eiffel `check` instructions.

## Why
Student guide, "P0 reliable test and benchmark outcomes". A run that reports failures but exits 0 shows up as green in CI.

## Done when
- [x] A deliberately failing test makes `xpact_tests.exe` exit nonzero _(verified 2026-10-22 at `76ac272`)_
- [x] Holds for workbench and finalized (with `-keep`) builds _(verified 2026-10-22 at `76ac272`)_
- [x] `run_eiffel_test_matrix.ps1` reports the failure _(verified 2026-10-22 at `76ac272`)_
- [x] Before/after logs in `student/results/B01-nonzero-exit/` _(verified 2026-10-22 at `76ac272`)_

## Evidence / notes
Related findings: the missing `-keep` in the finalized lane, and the runner stopping at the first failure.

## Discussion

### CodTanium, 2026-10-22 12:21: comment

Fixed in `f777826` (PR #62). A failing test now exits 1 in all four matrix lanes and both native smoke builds; logs in student/results/B01-nonzero-exit/.
