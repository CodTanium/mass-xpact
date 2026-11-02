# Issue #125: Finding: default handler receives the mismatched end tag before the error

Archived from <https://github.com/andersoxie/xpact/issues/125> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 19:30 |
| Closed | 2026-10-31 18:47 |
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

## Discussion

### CodTanium, 2026-10-31 18:46: comment

Fixed in #199 (`32bc80a` on `student-Mass`; the merge adds exactly the tested change). With only a default handler, a mismatched end tag is now an error before it reaches the handler, as Expat 2.8.1. Verified on both builds (`reports/issue-0125/report.md`): probe 16/16 = Expat (was 8/16); C# DLL tests events 4,114 → 4,135, the 21 cases of this issue, 0 worse; G03, W3C verdicts, output test and W3C in pieces unchanged per case; Expat runtests same 38; Eiffel matrix 4/4; Python 210 OK (also after the merge). Benchmark stage: in the next batch run.
