# Issue #70: Task: close the doc gaps found in the 2026-10-22 checklist audit

Archived from <https://github.com/andersoxie/xpact/issues/70> on 2026-10-26 16:48 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 21:23 |
| Closed | 2026-10-26 12:14 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

## Problem
A check of every closed issue's "Done when" list on 2026-10-22 (at `76ac272`) found two documentation items that were ticked in practice but not actually true:

- #43: "Every page states its date and the commit it describes" — `student/README.md`, `student/VERSIONING.md`, `student/github/README.md` and `student/report/README.md` do not. `student/README.md` also still says "week 3 🟡 (B01/B02 to do)".
- #35: "`student/github/README.md` describes the labels, milestones and which issue has which" — the issue tables stop at #46; #48–#68 are missing, and the board table still shows #45/#46 as Todo.

## Done when
- [ ] The four pages state their date and the commit they describe
- [ ] `student/github/README.md`: issue count, milestone table and "created outside the drafts" list cover #2–#68; board table no longer shows closed issues as Todo
- [ ] `student/PLAN.md` records the checklist audit and what is still open from it
- [ ] Report with verification in `reports/issue-NNNN/report.md`

Not in scope: the 6 labels missing on GitHub (#35, needs the supervisor).

## Discussion

### CodTanium, 2026-10-26 12:14: comment

Fixed in `82ad4cb` (PR #71). Verified 2026-10-26 in #104 (https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/report.md): the four pages state their date and commit, `reports/issue-0070/report.md` is on `student-Mass`. Closing.
