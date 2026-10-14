---
title: "Finding: Python harness test fails on Python 3.10 (csv cannot write NUL)"
labels: group:G-verification, D1-beginner, P1, type:finding
milestone: Week 2 - Baseline
---
## Steps to reproduce
1. With Python 3.10: `python -m unittest discover -s tests/python -p test_w3c_conformance.py`

## Expected
All 22 tests pass.

## Actual
On 2026-10-15, with Python 3.10.6 on `main` @ `fee611a`: 21 tests passed and 1 had an error.
`test_junit_and_summary_reconcile_failure_error_skip_and_verdict_counts` fails in `write_reports` with `_csv.Error: need to escape, but no escapechar set`. The test message contains `\x00`. Python's `csv` module can write NUL characters only from Python 3.11.

## Proposed next step
Either document "Python 3.11 or newer", or make `write_reports` work on every Python version, e.g. by escaping control characters before writing the TSV. Check which Python version Jenkins uses.
