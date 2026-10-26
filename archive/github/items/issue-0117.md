# Issue #117: Task: xmlconf verdict rules - re-score the 2026-10-14 baseline with the runner's rules (draft 12)

Archived from <https://github.com/andersoxie/xpact/issues/117> on 2026-10-26 20:59 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 17:27 |
| Closed | 2026-10-26 17:30 |
| Labels | `type:task`, `D2-guided`, `P1`, `test`, `group:G-verification` |
| Milestone | Week 4 - Input matrix |

## Description

## Task (draft 12, "Fix xmlconf verdict rules")
The draft asks to fix the verdict rules of `scripts/run_xmlconf_conformance.ps1`. That script was a weeks 1-2 local script and **never entered git** (`git log --all` has no trace; it survives only in `student/history/patches/01-…` and `02-…`). The correct non-validating rules already live in the supervisor's runner `scripts/run_w3c_conformance.py` (#29), which Jenkins uses. Three of the draft's four boxes were ticked through that runner.

Remaining box: *before/after summary compared with the Python runner in `student/results/xmlconf-verdicts/`*.

## Plan
Re-score the **same observations** of the 2026-10-14 baseline (`student/baseline/logs/xmlconf-results.tsv`, 2,168 cases, 854 "mismatches") with the runner's rules (`expectation()` / `load_catalog()` from `scripts/run_w3c_conformance.py`), and compare: old rules vs correct rules vs today's runner (2026-10-26, both builds). Show how many of the 854 were wrong rules and how many were real parser bugs, with crashes counted separately. No change to any runner.

## Done when
- [ ] `student/results/xmlconf-verdicts/`: script, per-case TSV, summary with the three columns, reconciled totals
- [ ] Draft 12's last box ticked; the old PowerShell runner recorded as superseded (not revived)
- [ ] Report with verification

## Discussion

### CodTanium, 2026-10-26 17:30: comment

Done in `c532e81` (PR #119), verified 2026-10-26 — results: https://github.com/andersoxie/xpact/blob/student-Mass/student/results/xmlconf-verdicts/README.md
- [x] `student/results/xmlconf-verdicts/`: `rescore.py`, `cases.tsv` (2,168 cases), `summary.md`; totals reconcile (1,086 + 186 + 47 + 848 + 1 = 2,168)
- [x] Draft 12's last box ticked; `run_xmlconf_conformance.ps1` recorded as superseded (never in git), not revived
- [x] Report: `reports/issue-0117/report.md`

676 of the 854 old failures were wrong rules; the 233 real problems all pass today in both builds.
