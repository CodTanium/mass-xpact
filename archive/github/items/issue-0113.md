# Issue #113: Task: record the student PC environment changes of 2026-10-26 (MSVC backend, Python 3.14, long paths)

Archived from <https://github.com/andersoxie/xpact/issues/113> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 17:01 |
| Closed | 2026-10-26 17:03 |
| Labels | `documentation`, `type:task`, `workflow`, `build` |
| Milestone | Week 4 - Input matrix |

## Description

## Task
Record the changes made to the student PC on 2026-10-26 to get closer to the supervisor's setup, with before/after values, test evidence and the remaining differences; update the setup guide and `student/PLAN.md`.

| Setting | Before | After |
|---|---|---|
| `ISE_C_COMPILER` (user) | not set → MinGW gcc for the matrix and W3C | `msc_vc140` (MSVC) |
| `python` | 3.10.6 | 3.14.0 (per-user install, first on the user PATH) |
| git `core.longpaths` (global) | not set | `true` |
| Windows `LongPathsEnabled` | 0 | 1 (set by the student as administrator) |

Remaining differences (not changed, decided by the student): EiffelStudio 25.12.9.8922 Standard vs 25.02.9.8723 Enterprise; MSVC 19.51 (VS 2026) vs 19.44 (VS 2022 Build Tools).

## Done when
- [ ] Report `reports/issue-NNNN/` with before/after, logs of the MSVC matrix + W3C run and the Python run with long paths on
- [ ] `student/report/setup-guide.md`: Python 3.11+ (3.14 used), `ISE_C_COMPILER`, long paths, supervisor's versions
- [ ] `student/PLAN.md`: the Python 3.10 and long-path rows moved to Solved

## Discussion

### CodTanium, 2026-10-26 17:03: comment

Done in `97795fb` (PR #114), verified 2026-10-26 — report: https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0113/report.md

- [x] Report with before/after and logs: matrix 4/4 and W3C 1,727/1,727 built with MSVC; Python 3.14 with long paths on: 178 tests OK (7 skipped)
- [x] Setup guide: supervisor column, Python 3.11+, long paths (section 2b), troubleshooting rows
- [x] PLAN.md: the Python 3.10 and long-path rows moved to Solved

Remaining differences kept on purpose: EiffelStudio 25.12 Standard vs 25.02 Enterprise, MSVC 19.51 vs 19.44.
