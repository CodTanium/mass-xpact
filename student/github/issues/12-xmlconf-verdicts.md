---
title: Fix xmlconf verdict rules (invalid -> accept; skip error, external entities, XML 1.1)
labels: group:G-verification, D2-guided, P1, type:task
milestone: Week 4 - Input matrix
---
## Goal
Make `scripts/run_xmlconf_conformance.ps1` use the same non-validating verdict rules as the teacher's Python runner (`scripts/run_w3c_conformance.py`).

## Why
In the baseline from 2026-10-14, 854 of 2,168 cases mismatched. But the runner expects REJECT for `invalid` cases, which a non-validating parser should accept (guide, "Read the expected outcome correctly"). It also runs cases that need external entities and XML 1.1. So the 854 figure cannot be compared with the Python runner.

Breakdown: not-wf 527 (129 need external entities), invalid 197, valid 115 (86 need external entities), error 15.

## Done when
- [ ] `invalid` -> expected ACCEPT; `error` -> no required verdict (reported, not counted as a failure)
- [ ] Cases that need external entities or XML 1.1 are skipped and counted separately
- [ ] Totals reconcile: passed + failed + skipped = cases
- [ ] Before/after summary compared with the Python runner in `student/results/xmlconf-verdicts/`
