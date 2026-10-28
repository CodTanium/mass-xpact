# Issue #46: B02 - Deliberately failing meta-tests

Archived from <https://github.com/andersoxie/xpact/issues/46> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 00:23 |
| Closed | 2026-10-22 12:44 |
| Labels | `type:task`, `group:B-reliable-results`, `D2-guided`, `P0`, `test` |
| Milestone | Week 3 - Failure reporting |

## Description

## Goal
Add deliberately failing meta-tests. Verify failure propagation through every supported build and assertion configuration and its CI wrapper.

## Why
Student guide, task register B02. Proves that B01 holds, and keeps holding.

## Done when
- [x] A meta-test that must fail, which can be switched on without changing real tests _(verified 2026-10-22 at `76ac272`)_
- [x] Each configuration (assertions on/off, workbench/finalized) reports the failure with a nonzero exit _(verified 2026-10-22 at `76ac272`)_
- [x] The CI wrapper `run_eiffel_test_matrix.ps1` turns red (all 4 lanes exit 1) _(verified 2026-10-22 at `76ac272`)_
- [ ] ~~The Jenkins stage turns red~~: **dropped** 2026-10-22, not checked (#64)
- [x] Results table in `student/results/B02-meta-tests/` _(verified 2026-10-22 at `76ac272`)_

## Discussion

### CodTanium, 2026-10-22 12:29: comment

Merged in `c82ef6e` (PR #63). Verified locally: with XPACT_META_FAIL=assert or exception every matrix lane and both native smoke builds exit 1 (student/results/B02-meta-tests/). **Left open** for the last done-when item: set XPACT_META_FAIL=assert on one Jenkins run and check that the stage turns red.

### CodTanium, 2026-10-22 12:44: comment

Closed: the last done-when item (Jenkins check) was dropped by the student on 2026-10-22 (#64, `1af577b`). B02 is verified on the student PC (student/results/B02-meta-tests/); the report keeps its 'Not tested: Jenkins' note.
