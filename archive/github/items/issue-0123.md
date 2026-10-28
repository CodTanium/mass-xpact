# Issue #123: Finding: no events before a malformed-UTF-8 error (Expat delivers them)

Archived from <https://github.com/andersoxie/xpact/issues/123> on 2026-10-28 19:58 UTC.

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
For malformed UTF-8 after a complete start tag, xpact delivers **no events**. Expat delivers the events from before the error.

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
As Expat 2.8.1: the events before the bad byte. For example, `<r>\xFF</r>` with a start handler gives `start:r`, then the error. The student guide's rule for rejected documents is "no events **after** the error"; events before it are expected.

## Actual result
No events at all: 598 cases in text, comment, PI and CDATA, with the start, start+end and default callback sets.

| Input | Callbacks | Expat 2.8.1 | xpact |
|---|---|---|---|
| `<r>\xC3(</r>` | start | `start:r` | none |
| `<r><![CDATA[\xFF]]></r>` | default | `default:<r> · default:<![CDATA[` | none |

## Investigation
Same place as #122: the whole input is checked for valid characters before tokenizing, so the error comes before the first event.

## Cause
**Suspected**, from reading the code (not traced). It may have the same cause as #122, but it is reported separately because it is a different behaviour.

## Fix
None.
