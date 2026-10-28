# Issue #132: Remove the unused old copy tests/python/run_w3c_conformance.py

Archived from <https://github.com/andersoxie/xpact/issues/132> on 2026-10-28 21:36 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 19:57 |
| Closed | 2026-10-26 20:00 |
| Labels | `type:task`, `group:B-reliable-results`, `test` |
| Milestone | Week 5 - Regressions |

## Description

## Task
Remove `tests/python/run_w3c_conformance.py`. It is an old copy of `scripts/run_w3c_conformance.py` (361 lines against 459) and nothing uses it.

## Evidence
- Added by the student in #30 (`8850dab`) and last changed in `492c6eb`.
- The Python tests import the runner from `scripts/` (`tests/python/test_w3c_conformance.py:27`).
- `grep -rn run_w3c_conformance` finds no other user of the copy.
- Found in the full check of 2026-10-26 (#104).

## Why it matters
A second copy with older verdict rules can be run by mistake. The xmlconf work (#117) showed what wrong rules do to the numbers.

## Done when
- [ ] File removed
- [ ] Python tests still pass (178 on 2026-10-26)
- [ ] PLAN.md "Known problems" row moved to Solved

## Discussion

### CodTanium, 2026-10-26 20:00: comment

Done in e847813 (PR #133). Verified: Python tests 178 OK (7 skipped) before and after the removal. Report: reports/issue-0132/report.md.
