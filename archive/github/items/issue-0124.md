# Issue #124: Finding: <root/>junk gives error 4, not 9 (junk after document element); position depends on callbacks and chunks

Archived from <https://github.com/andersoxie/xpact/issues/124> on 2026-10-28 21:36 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-26 19:30 |
| Closed |  |
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
