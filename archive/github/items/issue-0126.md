# Issue #126: Finding: default handler receives normalized line ends, not the raw CR (Expat passes raw text)

Archived from <https://github.com/andersoxie/xpact/issues/126> on 2026-10-28 01:33 UTC.

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
xpact's default handler receives **normalized line ends** (LF). Expat's default handler receives the document's raw bytes (CR, CR LF). For `<r/>\r` xpact also delivers an extra event.

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
As Expat 2.8.1, where the default handler gets the raw text:

| Input | Expat 2.8.1, default handler |
|---|---|
| `<r>\r\n</r>` | `default:<r> · default:\x0d\x0a · default:</r>` |
| `<r>\r</r>` | `default:<r> · default:\x0d · default:</r>` |
| `<r/>\r` | `default:<r/> · default:\x0d` |
| `<r a='x\ry'/>` | `default:<r a='x\x0dy'/>` |

## Actual result
| Input | xpact, default handler |
|---|---|
| `<r>\r\n</r>` | `default:<r> · default:\x0a · default:</r>` |
| `<r>\r</r>` | `default:<r> · default:\x0a · default:</r>` |
| `<r/>\r` | `default:<r/> · default:\x0a · default:\x0d` (two events) |
| `<r a='x\ry'/>` | `default:<r a='x\x0ay'/>` |

This happens in 38 cases. The verdict and the character-data handler are right: #28 normalizes character data to LF, as the XML spec requires.

Fixtures: `student/results/C03-chunks/fixtures/cr-*.xml`.

## Cause
**Suspected:** the default handler is fed from the normalized input of #28, not from the raw bytes. This comes from the observed output, not from the code.

## Fix
None.
