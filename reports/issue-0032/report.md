# Fix report: issue #32, Python harness fails on Python 3.10 (csv cannot write NUL)

Issue: [#32](https://github.com/andersoxie/xpact/issues/32) (from draft `student/github/issues/08-finding-python310.md`)   Branch: `student-Mass`   Base: `1ea242e`   Date: 2026-10-22

## Why

`python -m unittest discover -s tests/python -p test_w3c_conformance.py`
passes on Python 3.11+ but has 1 error on 3.10:
`test_junit_and_summary_reconcile_failure_error_skip_and_verdict_counts`
stops in `write_reports` with `_csv.Error: need to escape, but no escapechar set`.

Cause: a result message can contain NUL (the test uses `"wrong\x00verdict"`;
a real parser diagnostic can too). Python's `csv` module can only write NUL
from 3.11 on. The JUnit writer already replaces such characters with `?`
(`xml_text`); the TSV writer did not.

CI was not affected: `.github/workflows/python-harness.yml` pins 3.12. But
anyone running the harness on 3.10 (this PC had 3.10.6 in week 2; Jenkins'
version is unknown) gets a failing test that says nothing about xpact.

## Options

| Option | Result |
|---|---|
| Document "Python 3.11 or newer" | Nothing breaks, but 3.10 users still see a red test |
| **Replace NUL with `?` in the TSV, like the JUnit file** (chosen) | Works on every version; the TSV and JUnit files show the same text |

## What changed

| File | Change |
|---|---|
| `scripts/run_w3c_conformance.py` | New `tsv_row`: NUL in text fields becomes `?`; `write_reports` uses it for `results.tsv` |
| `tests/python/run_w3c_conformance.py` | The same change (this copy is kept identical apart from line 1, see #29) |
| `tests/python/test_w3c_conformance.py` | The test also checks the TSV message is `wrong?verdict`, so it now fails on **every** Python version if NUL leaks into the TSV, not only on 3.10 |

Behaviour change on 3.11+: a NUL in `results.tsv` is now `?` instead of a raw
NUL byte. Other control characters are unchanged.

## Verification

Python 3.10.22 and 3.15.0 (both installed with uv), Windows PowerShell 5.1.

| # | Command | Actual | Exit | Log |
|---|---|---|---|---|
| 1 | Before: 3.10, `python -m unittest discover -s tests/python -p test_w3c_conformance.py` | `Ran 22 tests`, `FAILED (errors=1)`, `_csv.Error: need to escape` | 1 | [before-py310.txt](before-py310.txt) |
| 2 | Before: 3.15, same | `Ran 22 tests`, `OK` | 0 | [before-py315.txt](before-py315.txt) |
| 3 | After: 3.10, same with `-v` | `Ran 22 tests`, `OK` | 0 | [after-py310.txt](after-py310.txt) |
| 4 | After: 3.15, same with `-v` | `Ran 22 tests`, `OK` | 0 | [after-py315.txt](after-py315.txt) |
| 5 | 3.15, new test with the fix removed again | `AssertionError: 'wrong\x00verdict' != 'wrong?verdict'`, `FAILED (failures=1)`: the test catches the bug on 3.11+ too | 1 | [check-test-without-fix-py315.txt](check-test-without-fix-py315.txt) |
| 6 | `scripts/` copy without line 1 compared with `tests/python/` copy | 0 differences | - | - |

## How to revert

```powershell
git revert <sha of this commit>
```