# Issue #171: Finding: error column is 0 (start of the line) where Expat points at the bad token (G03-2)

Archived from <https://github.com/andersoxie/xpact/issues/171> on 2026-11-01 03:16 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-31 06:04 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test`, `investigation` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
When xpact rejects a document it often reports **column 0**: in **22 of the 32** G01 rejections with a trace, Expat reports a column > 0 and xpact 0. The **line** is the same in 29 of 32. 14 cases differ **only** in the position.

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/169-g03-expat-chunk-comparison` @ `f985102` (= `student-Mass`, = `main` + #166). `xpact_assertions.dll` (SHA-256 `9d1f30aa84eec3da…`) and `xpact.dll` (`aaf5d1d297b083de…`), MSVC finalized builds, **identical results**. Reference: `libexpat.dll` Expat 2.8.1 (`R_2_8_1`, MSVC Release, `36a2532e2181ab8b…`). Python 3.14.0. Both DLLs driven by the same ctypes harness, same settings (namespaces as in the catalog, local external entities, `XML_PARAM_ENTITY_PARSING_ALWAYS`). |
| **Found by** | G03 (#169): the 93 G01 cases (#118) through xpact and Expat 2.8.1, `XML_Parse` and `XML_ParseBuffer`, whole and in chunks of 1, 2, 3, 7, 64, 1024 bytes |
| **Expected** | `XML_GetCurrentLineNumber` / `XML_GetCurrentColumnNumber` after the error = Expat's (the offending token) |
| **Actual** | examples: [rmt-ns10-014](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/rmt-ns10-014.json) 3:0 vs Expat 3:5, [ibm-not-wf-P80-ibm80n06.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P80-ibm80n06.xml.json) 1:0 vs Expat 1:20, [o-p73fail1](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/o-p73fail1.json) 5:0 vs Expat 5:12, [ibm-not-wf-P66-ibm66n14.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P66-ibm66n14.xml.json) 7:0 vs Expat 7:40, [not-wf-sa-013](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-013.json) 1:0 vs Expat 1:13, [content03](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/content03.json) 3:4 vs Expat 3:25; the line differs in 3 (e.g. `not-wf-sa-001` 2:0 vs 3:0, `ibm-not-wf-P51-ibm51n06.xml` 2:0 vs 7:33) |
| **Error output** | none; the verdict is right |
| **Investigation** | Counted over all traces of the assertions run (the normal run is identical). Each engine gives the same position in all chunkings. |
| **Cause** | ❔ **unknown**. 🟡 suspected: the position is taken from the start of the line or token group, not from the token itself. |
| **Fix** | none yet |
| **Verification** | not yet; rerun `compare.py` and check that these cases become `match` and nothing else changes |

**Command:**
```powershell
python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll
python -I student\results\G03-comparison\compare.py --tag normal --xpact-dll build\native-eiffel\xpact.dll
```

Related: #122 (malformed UTF-8 reported at 1:0; another input). Results: [G03 README](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/README.md).
