# Issue #124: Finding: <root/>junk gives error 4, not 9 (junk after document element); position depends on callbacks and chunks

Archived from <https://github.com/andersoxie/xpact/issues/124> on 2026-11-01 03:16 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 19:30 |
| Closed | 2026-10-31 18:42 |
| Labels | `type:finding`, `group:C-correctness`, `investigation` |
| Milestone | Week 5 - Regressions |

## Description

## Problem
For text after the root element, xpact reports error **4 (invalid token)**. Expat reports **9 (junk after document element)**. The column also changes with the callback set and the chunking.

**Environment:** Windows 11, `student-Mass` @ `e30f0e6`. `xpact.dll` (SHA-256 `75a8bf14…`) and `xpact_assertions.dll` (`f4f75bdd…`) are MSVC 19.51 finalized builds, and they give identical results. The reference `libexpat.dll` is Expat 2.8.1 (`R_2_8_1`), built with MSVC and CMake (`36a2532e…`).

**Command:**
```powershell
$t = "build\dotnet\XpactDllTests\bin\Release\net10.0\XpactDllTests.exe"
& $t --dll build\libexpat-R_2_8_1\build\libexpat.dll --out build\w5-121\libexpat
& $t --dll build\native-eiffel\xpact.dll --out build\w5-121\xpact
python -I student\results\expat-2.8.1\compare.py --expat build\w5-121\libexpat --xpact build\w5-121\xpact
```
Found in #121 (week 5, C03/C10 Expat comparison). The verdict (accept/reject) is the same as Expat in every case; this issue is only about the property below.

## Expected result
`<root/>junk` gives error 9 at **1:7** (byte 7), as Expat 2.8.1 does with every callback set and every chunking. The catalog (`Catalog.cs`) already expects 9 for libexpat.

## Actual result
Error **4** in all 72 cases (6 callback sets, 12 chunkings). The position is **1:7 with no callbacks** but **1:10 with any callback** on the whole document; across chunkings it is 1:7, 1:8, 1:9 or 1:10. Expat gives 1:7 in every case.

Fixture: `student/results/C03-chunks/fixtures/c02-trailing-junk.xml`.

## Investigation
None yet beyond the comparison.

## Cause
**Unknown.**

## Fix
None.

## Discussion

### CodTanium, 2026-10-31 18:42: comment

Fixed in #198 (`b7b6f69` on `student-Mass`; the merge adds exactly the tested change, 51 lines in, 10 out). Text or `]]>` after the document element is now "junk after document element", code 9, at its first non-space character, with or without callbacks, as Expat 2.8.1. Verified on both builds (`reports/issue-0124/report.md`): C# DLL tests error code **4,308/4,308** = Expat (the 72 cases of this issue), column and byte index 4,308/4,308, 0 worse; probe 9/52 → 30/52 (one row worse where Expat itself differs between whole and pieces); G03, W3C verdicts, output test and W3C in pieces unchanged per case; Expat runtests same 38; Eiffel matrix 4/4 with new assertions; Python 210 OK (also after the merge). Benchmark stage: in the next batch run. Left for #171: the position of text **before** the root (Expat points at its end).
