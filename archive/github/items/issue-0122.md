# Issue #122: Finding: malformed UTF-8 error is reported at 1:0, not at the bad byte (Expat 2.8.1 comparison)

Archived from <https://github.com/andersoxie/xpact/issues/122> on 2026-10-28 21:36 UTC.

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
For malformed UTF-8, xpact reports the error at **line 1, column 0, byte 0**. Expat reports the position of the bad byte.

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
The same position as Expat 2.8.1, the first byte of the bad sequence. For example, `<r>\xFF</r>` gives **1:3 (byte 3)**.

## Actual result
**1:0 (byte 0)** for every malformed-UTF-8 input: 7 bad sequences (`C3 28`, `C0 AF`, `ED A0 80`, `F4 90 80 80`, `80`, `FF`) in text, attribute, name, comment, PI and CDATA, with every callback set and every chunking. That is 3,096 cases. The error code is the same as Expat's (4, invalid token).

| Input | Expat 2.8.1 | xpact |
|---|---|---|
| `<r>\xC3(</r>` | 4 at 1:3 | 4 at 1:0 |
| `<r a='\xFF'/>` | 4 at 1:6 | 4 at 1:0 |
| `<r><![CDATA[\x80]]></r>` | 4 at 1:12 | 4 at 1:0 |

Byte-exact fixtures: `student/results/C10-utf8/fixtures/`. Every case: `student/results/expat-2.8.1/cases.tsv`.

## Investigation
Read `src/xp_parser.e`: `normalized_input` checks every character of the whole input (`utf8_character_length`, added in #80) **before** tokenizing. It calls `set_error ("invalid XML character")` without a position.

## Cause
**Suspected** (from reading the code, not traced): the whole-input check runs before any position is recorded.

## Fix
None. Parser repairs (C08) stay with the experienced developers.
