# Issue #55: Finding: run_eiffel_test_matrix.ps1 started outside the repository root runs a stale xpact_tests.exe and reports ok

Archived from <https://github.com/andersoxie/xpact/issues/55> on 2026-10-26 11:49 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 07:30 |
| Closed | 2026-10-22 07:41 |
| Labels | `type:finding`, `group:B-reliable-results`, `P1` |
| Milestone | Week 3 - Failure reporting |

## Description

## Steps to reproduce
1. Have an old `EIFGENs\xpact_tests\W_code\xpact_tests.exe` in the repository root (any earlier Workbench run leaves one).
2. From **another folder**, run the script by its full path, e.g. `cd C:\somewhere; C:\...\xpact\scripts\run_eiffel_test_matrix.ps1 -AssertionMode Off -BuildMode Workbench`

## Expected
The lane compiles and tests the current sources, or stops with an error.

## Actual
`ec -config tests\xpact_tests.ecf` resolves the ECF from the repository root (`$ConfigPath`), but writes `EIFGENs` into the **current folder**. The script then looks for `Makefile.SH` and `xpact_tests.exe` under `$RepoRoot\EIFGENs\...`: `finish_freezing` is skipped (no `Makefile.SH` there), the **old** `xpact_tests.exe` is run, and the script prints `xpact Eiffel test matrix: ok`, exit 0. A false pass, like #48. Seen on 2026-10-22 while testing #53 (`reports/issue-0053/report.md`, "Found while testing", item 2).

## Proposed next step
Pass `-project_path $RepoRoot` to `ec` (or `Push-Location $RepoRoot` around the lane), so the build, `finish_freezing` and the executable all use the same folder.

## Discussion

### CodTanium, 2026-10-22 07:41: comment

Fixed in `920ffba` (PR #58).
