# Issue #125: Finding: default handler receives the mismatched end tag before the error

Archived from <https://github.com/andersoxie/xpact/issues/125> on 2026-10-28 19:58 UTC.

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
With a default handler, xpact passes the **mismatched end tag** `</root>` to the default handler before it reports the error. Expat does not.

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
`<root><child></root>` with a default handler gives `default:<root> · default:<child>`, then error 7 at 1:15 (Expat 2.8.1).

## Actual result
`default:<root> · default:<child> · default:</root>`, then error 7 at 1:15. This happens in 21 cases: whole, every split and byte by byte. The faulty token is reported as if it were fine.

Fixture: `student/results/C03-chunks/fixtures/c02-mismatched.xml`.

## Cause
**Unknown.**

## Fix
None.
