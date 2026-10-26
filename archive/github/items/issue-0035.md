# Issue #35: Task: GitHub labels and week milestones from CLAUDE.md

Archived from <https://github.com/andersoxie/xpact/issues/35> on 2026-10-26 18:53 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 23:20 |
| Closed | 2026-10-22 00:19 |
| Labels | `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

`CLAUDE.md` asks for the labels `bug`, `test`, `build`, `documentation`, `regression`, `investigation`, and for milestones per project week.

**Done on GitHub on 2026-10-22** (agreed with the student before doing it):
- [x] New labels: `test`, `build`, `regression`, `investigation` (`bug` and `documentation` already existed)
- [x] Milestones `Week 1 - Setup` … `Week 10 - Handover` (numbers 1-10), due on the Friday of each week, week 1 = 2026-10-05. There were no milestones before
- [x] Every issue #2-#33 has a milestone and the matching new labels

**To do in the repository:**
- [x] `student/github/labels.json` and `milestones.json` match what is on GitHub _(verified 2026-10-26 after #108: 21/21 labels, 10/10 milestones)_
- [x] `student/github/README.md` describes the labels, milestones and which issue has which _(verified 2026-10-26: issue tables in #70, labels and board in #108)_

**Not done:** the project board (Todo → In progress → In review → Done). `gh` is logged in without the `project` scope; `gh auth refresh -s project` needs the browser, so the student has to run it once.

## Discussion

### CodTanium, 2026-10-22 00:19: comment

Fixed in `c01f743` (PR #42). Verified: 4 labels and 10 milestones on GitHub, no issue without a milestone, `labels.json`/`milestones.json` match. Still open: the project board, which needs `gh auth refresh -s project` in the browser (by the student). Report: `reports/issue-0035/report.md`.

### CodTanium, 2026-10-22 00:27: comment

Project board done: https://github.com/users/CodTanium/projects/3 (Todo / In progress / In review / Done, every issue on it). It cannot be linked to this repository (GitHub: only projects of the same owner). Recorded in PR #47.
