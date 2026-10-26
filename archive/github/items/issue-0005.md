# Issue #5: Task: versioning workflow for fixes on student-Mass

Archived from <https://github.com/andersoxie/xpact/issues/5> on 2026-10-26 16:48 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-19 22:20 |
| Closed | 2026-10-19 23:13 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

## Goal
Many fixes (several hundred pushes) will go to `student-Mass`. Each fix must be:
- **traceable**: linked to an issue, with the reason recorded
- **tested**: the evidence is committed next to the fix
- **easy to revert**: one commit undoes it, without rewriting history

## Plan
- `student/VERSIONING.md`: the rules and the step-by-step workflow
- `student/tools/fix.ps1`: `start`, `finish`, `merge`, `revert`, `status`
  - one branch per fix, `fix/<issue>-<name>`, from the latest `student-Mass`
  - `finish` checks that every commit names the issue and that `reports/fix-report-issue-<n>.md` has a `## Verification` section, then opens a pull request
  - `merge` squash-merges, so each fix is one commit on `student-Mass`
- `student/git/commit-template.txt`: commit message template asking for `Refs #<issue>`
