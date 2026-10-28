# Issue #14: Task: one folder per fix under reports/

Archived from <https://github.com/andersoxie/xpact/issues/14> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-19 23:25 |
| Closed | 2026-10-19 23:29 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

## Goal

Give every fix its own folder under `reports/` so the folder stays readable for the ~500 fixes planned:

```
reports/
  README.md            index of all fixes: issue, title, pull request, merged commit
  error-reports/       dated error reports (not tied to one fix)
  issue-0007/
    report.md          the fix report, with ## Verification
    *.txt              logs and test scripts for that fix
```

## Why

`reports/` is a flat list today: 18 files for 5 fixes (`fix-report-issue-N.md` plus `fix-issue-N-*.txt`).

- Names sort as text, so issue 10 is listed before issue 2.
- At ~4 files per fix, 500 fixes would be ~2,000 files in one folder. GitHub's folder view truncates at 1,000 entries.
- Nothing groups one fix's report with its evidence except a name prefix.

## Done when

- [x] Existing files moved with `git mv` (history kept), links inside the reports updated _(verified 2026-10-22 at `76ac272`)_
- [x] `student/tools/fix.ps1`: `finish` checks `reports/issue-NNNN/report.md`; `start` creates the folder _(verified 2026-10-22 at `76ac272`)_
- [x] `student/VERSIONING.md` rule 5 and the examples use the new paths _(verified 2026-10-22 at `76ac272`)_
- [x] `reports/README.md` lists every fix _(verified 2026-10-22 at `76ac272`)_
- [x] Verification in `reports/issue-NNNN/report.md` for this issue _(verified 2026-10-22 at `76ac272`)_

## Discussion

### CodTanium, 2026-10-19 23:29: comment

Done on `student-Mass` in 4a957b1 (pull request #15). Each fix now has `reports/issue-NNNN/` with `report.md` and its logs, indexed in [reports/README.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/README.md). Verification: [reports/issue-0014/report.md](https://github.com/andersoxie/xpact/blob/4a957b1/reports/issue-0014/report.md).
