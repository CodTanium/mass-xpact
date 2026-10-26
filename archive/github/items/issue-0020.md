# Issue #20: Task: bring the student docs in line with the week 3 workflow

Archived from <https://github.com/andersoxie/xpact/issues/20> on 2026-10-26 18:53 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-20 00:18 |
| Closed | 2026-10-20 00:22 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

## Goal
Week 3 moved every fix to `reports/issue-NNNN/` with the `fix.ps1` workflow, but several documents still describe the week 2 setup, and some week 3 results are missing. Nothing should be in one place and missing from another.

## Missing
- `student/notes/weekly/week-03.md` (PLAN.md lists it as a to-do)
- `reports/error-reports/2026-10-19.md`: no outcome section; errors 2 and 3 still say "not confirmed" although #4 fixed error 3 and #3 found error 2's cause
- `reports/README.md`: #18 row has no commit (`df189d9`)

## Out of date
- `student/README.md`: "PLAN.md is the empty version"; layout without `reports/`, `VERSIONING.md`, `tools/`; branch names and steps from before `fix.ps1`; "Closes #N" (does not close issues for pull requests into `student-Mass`)
- `student/results/README.md`: "one folder per issue" competes with `reports/issue-NNNN/`
- `.github/pull_request_template.md`: evidence in `student/results/`, "Closes #"
- `student/baseline/BASELINE.md`: K1 status (B03 root cause #3, #12, #13); §1 points at the deleted `student-test` branch
- `student/baseline/README.md` and `student/history/README.md`: "apply the patches" (most of patch 01 is now in git as #2, #7, #10); wrong clone path
- `student/github/README.md`: wrong clone path; drafts that are already issues
- `student/PLAN.md`: last-updated commit

## Risk
`student/github/setup-github.ps1` skips a draft only if an issue with exactly the same title exists. Draft `05-finding-b03-postcondition.md` has a different title from #3, so running the script would create a duplicate B03 issue.

## Discussion

### CodTanium, 2026-10-20 00:22: comment

Fixed in `4df05be` (PR #21). Report: [reports/issue-0020/report.md](https://github.com/andersoxie/xpact/blob/4df05be96046e043a0034a09852a6ccf7eb63ef7/reports/issue-0020/report.md). Documentation only; 106 relative links checked, 0 broken.
