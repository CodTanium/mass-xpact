# Issue #180: Finding: run_benchmarks.ps1 -Repetitions 1 fails in AddRange (A04-2)

Archived from <https://github.com/andersoxie/xpact/issues/180> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 09:19 |
| Closed | 2026-10-31 13:41 |
| Labels | `bug`, `type:finding`, `group:B-reliable-results`, `build` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
`scripts/run_benchmarks.ps1` stops with a PowerShell error when `-Repetitions 1` is given. Jenkins is **not** affected (it uses the default, 3).

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/168-a04-loaded-library` @ `f985102` (= `student-Mass`), Visual Studio 18 Community (MSVC, bundled CMake), Expat 2.8.1 sources (`R_2_8_1`), PowerShell 5.1. |
| **Found by** | A04 (#168), running the Benchmarks stage once with the smallest settings |
| **Expected** | one timed row per benchmark, the run continues |
| **Actual** | the script stops after the first benchmark (exit 1, 1.8 s) |
| **Error output** | `Cannot convert argument "collection", with value: "@{Benchmark=catalog-100-items; …}", for "AddRange" to type "System.Collections.Generic.IEnumerable`1[System.Object]"` … `MethodArgumentConversionInvalidCastArgument,run_benchmarks.ps1` |
| **Investigation** | `Invoke-TimedCommand` returns `$Rows`, a `List[object]`; with one repetition PowerShell unrolls the one-element list into a single `PSCustomObject`, and `$AllRows.AddRange(...)` does not accept it. With `-Repetitions 2` the same command runs. |
| **Cause** | ✅ **confirmed** by the error type (a single `PSCustomObject` where a collection is expected) and by `-Repetitions 2` working. |
| **Fix** | none yet; e.g. `return ,$Rows` in `Invoke-TimedCommand`, or wrap the calls as `@(Invoke-TimedCommand ...)` |
| **Verification** | not yet; rerun with `-Repetitions 1` |

**Command:**
```powershell
.\scripts\run_benchmarks.ps1 -Iterations 1 -Repetitions 1 -SkipBuild -SkipWslC -W3cAllCases -OutputDir build\a04\benchmarks
```
Related: #168 (A04).

## Discussion

### CodTanium, 2026-10-31 13:13: comment

Fix merged into `student-Mass`: #186 (`647b99c`, identical tree to the tested `412b09d`); plan updated in #187 (`e20d3d1`).

`Invoke-TimedCommand` now returns `,$Rows` (same idiom as `run_large_xml_benchmarks.ps1`).
- Before: `-Repetitions 1` exit 1, AddRange error
- After: `-Repetitions 1` exit 0, 10 rows; `-Repetitions 3` exit 0, 30 rows; W3C 2585/2585 both builds
- Separate finding (local only): `-SkipBuild` with benchmark exes older than `eae4529` gives 2509 W3C errors (`usage: --conformance-file PATH [--namespaces]`); a rebuild fixes it. Details in `reports/issue-0180/report.md`.

Leaving open until a Jenkins run includes the fix.

### CodTanium, 2026-10-31 13:41: comment

Closing: fixed in #186 (`647b99c`), verified locally (`-Repetitions 1` and `3` exit 0; W3C 2585/2585 both builds). Student decision 2026-10-31: no Jenkins run needed for this script fix. Plan row moved to Solved in #190 (`5af2321`).
