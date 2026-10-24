# Issue #38: Finding: with a start handler, the rest of the document is not parsed: <root> is accepted and end events are lost (C01)

Archived from <https://github.com/andersoxie/xpact/issues/38> on 2026-10-24 20:26 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 23:57 |
| Closed | 2026-10-23 17:19 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `D3-advanced`, `P0`, `test` |
| Milestone | Week 5 - Regressions |

## Description

**1. Problem:** with a start-element handler set, xpact accepts documents that are not well-formed, and with start and end handlers set it does not deliver the end event of a valid document. The expected behaviour is C01 in the task register: "An emitted start event must never substitute for parsing the remaining input."

**2. Environment:** Windows 11, `student-Mass` @ `42d6b40` (parser), `xpact.dll` (assertions off, SHA-256 `62a2706b…`), `xpact_assertions.dll` (`8cc96794…`) and the same with the B03 fix (`38c2b2c7…`). Same result on all three.

**3. Command:**
```powershell
dotnet build tests\dotnet\XpactDllTests -c Release
build\dotnet\XpactDllTests\bin\Release\net10.0\XpactDllTests.exe --dll build\native-eiffel\xpact.dll --group c02 --verbose
```
Program from #37. One case: `--only c02-incomplete/start/whole --verbose --isolate`.

**4. Expected:** `<root>` and `<root><child></root>` REJECT with every callback set; `<root></root>` ACCEPT with the events `start:root`, `end:root`.

**5. Actual** (`xpact.dll`):

| Case | Result | Events |
|---|---|---|
| `c02-incomplete/start/whole` (`<root>`) | **ACCEPT** | `start:root` |
| `c02-mismatched/start+end/whole` (`<root><child></root>`) | **ACCEPT** | `start:root` |
| `c02-valid-pair/start+end/whole` (`<root></root>`) | ACCEPT | `start:root` (**no** `end:root`) |
| the same inputs with `none`, `end`, `chardata`, `default` | right | right |
| the same inputs, `start+end/bytes` (byte by byte) | right | right |

24 wrong ACCEPTs and 30 missing end events in 3,360 cases.

**6. Error output:** none: `XML_Parse` returns `XML_STATUS_OK`.

**7. Investigation:** wrong only when (a) a start handler is set **and** (b) the **final** `XML_Parse` call is the one that completes the first start tag (whole document, or a split before the end of `<root>`). When the start tag is complete before the final call (byte by byte, later split points), the result is right. The assertions DLLs give the same wrong results, so no contract notices it.

**8. Cause:** **suspected:** the final-input prefix shortcut described in C01 (emit the start event, then return without validating the rest). Not confirmed in the code.

**9. Fix:** none. Parser change, for the parser's developers (task C01, D3).

**10. Verification:** a fix is verified when the `c02` group passes on `xpact_assertions.dll` for every callback set and chunking. A rerun gave the same result for every case.

**Logs:** [results README, finding 1](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/README.md#findings) · [production/results.tsv](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/production/results.tsv) · [production/summary.txt](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/production/summary.txt)
