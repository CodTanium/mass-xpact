# Issue #32: Finding: Python harness test fails on Python 3.10 (csv cannot write NUL)

Archived from <https://github.com/andersoxie/xpact/issues/32> on 2026-10-24 20:26 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 22:38 |
| Closed | 2026-10-21 22:48 |
| Labels | `bug`, `type:finding`, `P1`, `test` |
| Milestone | Week 3 - Failure reporting |

## Description

Created from the draft `student/github/issues/08-finding-python310.md`.

## Steps to reproduce
1. With Python 3.10: `python -m unittest discover -s tests/python -p test_w3c_conformance.py`

## Expected
All 22 tests pass.

## Actual
On 2026-10-15, with Python 3.10.6 on `main` @ `fee611a`: 21 tests passed and 1 had an error.
`test_junit_and_summary_reconcile_failure_error_skip_and_verdict_counts` fails in `write_reports` with `_csv.Error: need to escape, but no escapechar set`. The test message contains `\x00`. Python's `csv` module can write NUL characters only from Python 3.11.

First seen during weeks 1–2 (error report, section 7.2) without a known cause. The cause above was found on 2026-10-15.

## Proposed next step
Either document "Python 3.11 or newer", or make `write_reports` work on every Python version, e.g. by escaping control characters before writing the TSV. Check which Python version Jenkins uses.

## Discussion

### CodTanium, 2026-10-21 22:48: comment

Fixed on student-Mass in 492c6eb: NUL becomes ? in results.tsv. 22 tests OK on Python 3.10.22 and 3.15.0. Report: reports/issue-0032/report.md
