# Issue #39: Finding: invalid UTF-8 is accepted in text, attributes, names, comments, PIs and CDATA

Archived from <https://github.com/andersoxie/xpact/issues/39> on 2026-10-26 20:05 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 23:57 |
| Closed | 2026-10-26 12:13 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `D3-advanced`, `P0`, `test` |
| Milestone | Week 5 - Regressions |

## Description

**1. Problem:** xpact accepts invalid UTF-8 in text, attribute values, element names, comments, processing instructions and CDATA. K4 of the week 2 baseline (`C3 28` in text) is one case of it.

**2. Environment:** Windows 11, `student-Mass` @ `42d6b40`, `xpact.dll` (assertions off, SHA-256 `62a2706b…`); the same on `xpact_assertions.dll` with the B03 fix (`38c2b2c7…`) wherever the case does not crash first.

**3. Command:**
```powershell
build\dotnet\XpactDllTests\bin\Release\net10.0\XpactDllTests.exe --dll build\native-eiffel\xpact.dll --group utf8
```
Program from #37. The inputs are exact bytes in the program (`Catalog.cs`), for example `<r>` `C3 28` `</r>`.

**4. Expected:** REJECT for `C3 28` (no continuation byte), `C0 AF` (overlong), `ED A0 80` (surrogate) and `F4 90 80 80` (above U+10FFFF), in each of the six places. ACCEPT for the control `C3 A9` (é).

**5. Actual:** **2,106 of 2,148** bad-sequence cases are ACCEPTED, with every callback set and chunking. The 42 rejected ones are all `C3 28` in an element name. The control `C3 A9` is accepted everywhere ✅.

| | text | attribute | name | comment | PI | CDATA |
|---|---|---|---|---|---|---|
| `C3 28` | ACCEPT | ACCEPT | reject | ACCEPT | ACCEPT | ACCEPT |
| `C0 AF` | ACCEPT | ACCEPT | ACCEPT | ACCEPT | ACCEPT | ACCEPT |
| `ED A0 80` | ACCEPT | ACCEPT | ACCEPT | ACCEPT | ACCEPT | ACCEPT |
| `F4 90 80 80` | ACCEPT | ACCEPT | ACCEPT | ACCEPT | ACCEPT | ACCEPT |

**6. Error output:** none: `XML_Parse` returns `XML_STATUS_OK`, and the text callback receives the bad bytes unchanged (e.g. `text:\xc3(`).

**7. Investigation:** `C3 28` in a name is rejected because `(` is not a name character, so even that case does not show a UTF-8 check. The assertions DLL behaves the same: no contract checks UTF-8.

**8. Cause:** **suspected:** there is no strict UTF-8 decoder (task C08: "Reject bad continuations, overlong encodings, surrogates and values above U+10FFFF"). Not confirmed in the code.

**9. Fix:** none. Parser change (C08/C09, D3-D4), for the parser's developers.

**10. Verification:** a fix is verified when every bad-sequence case in the `utf8` group is REJECT and every `valid-e9` case still passes. A rerun gave the same result for every case.

**Logs:** [results README, finding 2](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/README.md#findings) · [production/results.tsv](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/production/results.tsv)

## Discussion

### CodTanium, 2026-10-26 12:13: comment

**Verified fixed, 2026-10-26** (#104, report: https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/report.md).

- Fix: PR #80 (strict UTF-8), on `student-Mass` @ `41731c8`.
- Command: `XpactDllTests.exe` (C# DLL test program, #37) on `xpact_assertions.dll` and `xpact.dll`, both built 2026-10-26 with `build_native_eiffel.ps1`.
- Expected (written first): 0 failures.
- Actual: the `utf8` group — whole 180, split 2,298, byte by byte 180 = **2,658 cases — all pass on both DLLs**; total 3,360/3,360, 0 crash ([assertions DLL](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/logs/10-dll-tests-assertions.txt), [production DLL](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/logs/11-dll-tests-production.txt)). Before: 2,106 of 2,148 malformed inputs accepted.
- W3C, both finalized builds: 1,727 passed, 0 failed ([log](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/logs/12-benchmarks-w3c.txt)).

Closing.
