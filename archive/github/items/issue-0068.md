# Issue #68: Task: complete the A01 evidence (tests linked, change-and-predict, notes)

Archived from <https://github.com/andersoxie/xpact/issues/68> on 2026-11-01 03:16 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 21:19 |
| Closed | 2026-10-26 12:14 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 1 - Setup |

## Description

## Problem
A01 is ticked as done in `student/PLAN.md` (#18), but three items in its "Done when" list (`student/github/issues/01-A01.md`) have no evidence in the repository:

- [x] The test that checks each result is located and linked (file and line)
- [x] A small input was changed and the outcome predicted before running it
- [x] Notes in `student/results/A01-orientation/`

`student/results/A01-orientation/` does not exist.

## Plan
1. Link `ok.xml` and `rejected.xml` to the tests that check them and to the parser routine that rejects the mismatched tag.
2. Change-and-predict: write the predicted outcome of small changed inputs **and commit it before running** (git history shows the order), then run `xpact_event_trace.exe` (assertions on) and record the actual output next to the prediction.
3. Notes in `student/results/A01-orientation/README.md`; tick the A01 draft and update `student/PLAN.md`.

## Done when
- [x] `student/results/A01-orientation/README.md`: tests and parser path linked (file and line), predictions, actual output, comparison
- [x] Predictions committed before the run
- [x] `student/github/issues/01-A01.md` ticked with evidence; `student/PLAN.md` A01 line points to the notes
- [x] Report with verification in `reports/issue-NNNN/report.md`

> ✅ Boxes ticked on 2026-10-30, after checking each item against the closing comment and `main`.

## Discussion

### CodTanium, 2026-10-26 12:14: comment

Fixed in `2fdc61a` (PR #69). Verified 2026-10-26 in #104 (https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/report.md): `student/results/A01-orientation/` (README, predictions, actual output), `reports/issue-0068/report.md` on `student-Mass`; the A01 draft has no unticked items. Closing.
