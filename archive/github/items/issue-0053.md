# Issue #53: Finding: run_eiffel_test_matrix.ps1 -BuildMode Workbench does not load MSVC, finish_freezing fails with msc_vc140

Archived from <https://github.com/andersoxie/xpact/issues/53> on 2026-10-26 20:59 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 07:17 |
| Closed | 2026-10-22 07:30 |
| Labels | `type:finding`, `group:B-reliable-results`, `P1`, `build` |
| Milestone | Week 3 - Failure reporting |

## Description

## Steps to reproduce
1. Set `ISE_C_COMPILER=msc_vc140` (as the setup guide, section 2, says to) and open Windows PowerShell 5.1 without the MSVC environment loaded.
2. `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode Off -BuildMode Workbench`

## Expected
The Workbench lane compiles, runs the tests and prints `xpact Eiffel test matrix: ok`.

## Actual
`run_eiffel_test_matrix.ps1` loads MSVC only when a Finalized lane is selected (lines 86-88). A Workbench lane still runs `finish_freezing`, which with `msc_vc140` needs `cl`/`link`, so it fails: `finish_freezing failed for assertions-off / Workbench`, with no other explanation. First noted in `reports/issue-0028/report.md` ("How the lanes were run"); today worked around by loading MSVC by hand first (setup guide, section 3).

## Proposed next step
Load MSVC when a Finalized lane is selected (as now) **or** when `ISE_C_COMPILER` is an MSVC backend (`msc*`). Not unconditionally: with the default mingw backend the Workbench lane needs no MSVC, and machines without Visual Studio would otherwise fail.

## Discussion

### CodTanium, 2026-10-22 07:30: comment

Fixed in `ec3c3e6` (PR #54).
