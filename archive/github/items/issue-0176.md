# Issue #176: Finding: in pieces, "]]" of a forbidden "]]>" is delivered as text before the error (G03-7)

Archived from <https://github.com/andersoxie/xpact/issues/176> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-31 06:04 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
`o-p14fail3` is `<doc>a]]>b</doc>` (`]]>` is not allowed in content). Fed in small pieces, xpact delivers the text **`a]]`** and then the error; Expat delivers **`a`**. Parsed whole, both deliver only `start doc`.

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/169-g03-expat-chunk-comparison` @ `f985102` (= `student-Mass`, = `main` + #166). `xpact_assertions.dll` (SHA-256 `9d1f30aa84eec3da…`) and `xpact.dll` (`aaf5d1d297b083de…`), MSVC finalized builds, **identical results**. Reference: `libexpat.dll` Expat 2.8.1 (`R_2_8_1`, MSVC Release, `36a2532e2181ab8b…`). Python 3.14.0. Both DLLs driven by the same ctypes harness, same settings (namespaces as in the catalog, local external entities, `XML_PARAM_ENTITY_PARSING_ALWAYS`). |
| **Found by** | G03 (#169): the 93 G01 cases (#118) through xpact and Expat 2.8.1, `XML_Parse` and `XML_ParseBuffer`, whole and in chunks of 1, 2, 3, 7, 64, 1024 bytes |
| **Expected** | in pieces: `start doc`, `chars "a"`, error 4 at 1:8 (Expat) |
| **Actual** | in pieces: `start doc`, `chars "a]]"`, error 4 at 1:6. Trace: [o-p14fail3](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/o-p14fail3.json) |
| **Error output** | none; the verdict is right |
| **Investigation** | 6 of 14 configurations differ (the small chunk sizes). Both engines differ from their own whole parse here, which the API allows; the difference with Expat is the text content. |
| **Cause** | ❔ **unknown**. 🟡 suspected: text in front of a chunk boundary is delivered before `]]>` is recognised. |
| **Fix** | none yet |
| **Verification** | not yet; rerun `compare.py` and check that these cases become `match` and nothing else changes |

**Command:**
```powershell
python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll
python -I student\results\G03-comparison\compare.py --tag normal --xpact-dll build\native-eiffel\xpact.dll
```

Related: G03-2 (position). Results: [G03 README](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/README.md).
