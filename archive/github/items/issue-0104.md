# Issue #104: Task: full check of student-Mass @ 41731c8 and PLAN.md update (2026-10-26)

Archived from <https://github.com/andersoxie/xpact/issues/104> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 12:09 |
| Closed | 2026-10-26 12:14 |
| Labels | `documentation`, `type:task`, `workflow`, `test` |
| Milestone | Week 4 - Input matrix |

## Description

## Task
Full check of the student working folder and of `student-Mass` @ `41731c8` after the sync with `main` (#102, #103), on 2026-10-26: folder vs git, every build and test with assertions on, every open issue against the result. Record it as a report with logs, and bring `student/PLAN.md` up to date (last updated 2026-10-22; most known-problem rows are out of date).

## Done when
- [ ] `reports/issue-NNNN/`: report with expected results written before the runs, the actual results, and the complete logs
- [ ] `student/PLAN.md`: header, "At a glance", known problems (moved to "Solved" where verified), "Next"
- [ ] `reports/README.md` row
- [ ] Issues whose fix is verified by this check get the evidence as a comment

Not in scope (listed in the report, no issues filed yet): Python 3.10 vs `hashlib.file_digest`, Jenkins "Eiffel Tests" stage without output, SonarQube 401, old runner copy in `tests/python/`.

## Discussion

### CodTanium, 2026-10-26 12:14: comment

Done in `7bb51c0` (PR #105), checked 2026-10-26:

- [x] `reports/issue-0104/`: report (expected results first, actual results, investigation) and 19 logs
- [x] `student/PLAN.md`: header, "At a glance", known problems (8 moved to Solved, 5 found without an issue added), "Merged since 2026-10-22", "Next"
- [x] `reports/README.md` row
- [x] Evidence posted and issues closed: #3, #39, #40, #68, #70. #73, #74, #79 stay open for the Jenkins rerun; PR #76 updated twice today and mergeable.

Link check: 0 broken.
