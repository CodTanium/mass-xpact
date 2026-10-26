# Issue #29: Task: run the W3C suite with assertions off and on, and record the results

Archived from <https://github.com/andersoxie/xpact/issues/29> on 2026-10-26 20:05 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 16:11 |
| Closed | 2026-10-21 16:17 |
| Labels | `type:task`, `D2-guided`, `P1`, `test` |
| Milestone | Week 3 - Failure reporting |

## Description

## Goal

Run the W3C XML conformance suite (20130923) with the Python runner `scripts/run_w3c_conformance.py` against two builds of `xpact_benchmarks.exe`, assertions **off** (`Finalized`) and assertions **on** (`FinalizedAssertions`, `-finalize -keep`), and record the results in the repository.

## Why

- The guide (week 2 and "Comparing engines") asks for assertions-enabled results. The 2026-10-14 xmlconf baseline used the old PowerShell runner with different verdict rules (draft 12), so its numbers cannot be compared with the Python runner.
- The reports are written under `build/`, which is gitignored, so nothing from the run is in the repository yet.
- With assertions on, 1,360 of 1,727 cases crash; 1,357 of them in `XP_PARSER.normalized_input` on a CR byte. That is reported as a separate finding.

## Done when

- [x] Results under `student/results/w3c-conformance-2026-10-21/`: README (revision, configuration, commands, both builds, breakdown), summaries, failures and crashes, byte-exact 9-byte repro of the CR crash _(verified 2026-10-22 at `76ac272`)_
- [x] Error report `reports/error-reports/2026-10-21.md` _(verified 2026-10-22 at `76ac272`)_
- [x] Drafts 12 and 21 updated; draft for the CR finding added (the CR finding was filed directly as issue #28 instead of a draft) _(verified 2026-10-22 at `76ac272`)_
- [x] `student/PLAN.md` and `student/PLAN2.md` updated _(verified 2026-10-22 at `76ac272`)_
- [x] `tests/python/run_w3c_conformance.py` added (copy of the runner next to its tests) _(verified 2026-10-22 at `76ac272`)_
- [x] Report with verification in `reports/issue-NNNN/report.md` _(verified 2026-10-22 at `76ac272`)_

## Discussion

### CodTanium, 2026-10-21 16:17: comment

Done in #30, squash-merged as 8850dab on student-Mass. Results: student/results/w3c-conformance-2026-10-21/README.md, report: reports/issue-0029/report.md, error report: reports/error-reports/2026-10-21.md.
