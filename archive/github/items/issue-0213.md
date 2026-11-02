# Issue #213: Add the AlotOfTests results (11 tests, 2026-10-28) to the repo with their sources

Archived from <https://github.com/andersoxie/xpact/issues/213> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-11-02 14:04 |
| Closed | 2026-11-02 14:07 |
| Labels | `documentation`, `test` |
| Milestone | - |

## Description

## Problem
The 11 extra tests run locally on 2026-10-28 (`AlotOfTests`: W3C output, W3C in pieces, fuzzing, differential vs Expat, security, Expat's C tests, libxml2, encodings, memory, CPython, large files) and their numbers exist only on the student PC. The supervisor and the report can't link to them.

## Change
- Add the tools, READMEs and result files (TSV/JSON/text) under `student/results/AlotOfTests-2026-10-28/`.
- Leave out downloads (libxml2, CPython), generated inputs (466 MB), build output and binaries.
- Add a sources table with the online link of every downloaded suite (W3C, libxml2, Expat, CPython, CVEs).
- Add a numbers summary and link it from `student/results/README.md`.

## Limits
The numbers were measured on `student-Mass` @ `293918f` (2026-10-28), **before** the fixes #154-#175. They are not rerun; the README says so.

## Discussion

### CodTanium, 2026-11-02 14:07: comment

Done in 1b3c862 (PR #214). Verified on student-Mass: all 1,699 files under student/results/AlotOfTests-2026-10-28/, the sources table and the numbers summary are in the README, and the row in student/results/README.md is there. The numbers are from 293918f (2026-10-28), not rerun.
