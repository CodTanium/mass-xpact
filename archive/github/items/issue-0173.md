# Issue #173: Finding: an error in the internal DTD subset is reported at the DOCTYPE line, before the declarations in front of it (G03-4)

Archived from <https://github.com/andersoxie/xpact/issues/173> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 06:04 |
| Closed | 2026-10-31 18:32 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test`, `investigation` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
`ibm-not-wf-P51-ibm51n06.xml` has three good `<!ELEMENT>` declarations, then a bad one on line 7. Expat delivers the three `elementdecl` events and reports the error at **7:33**. xpact delivers **none** of them and reports the error at **2:0**, the `<!DOCTYPE` line. Unlike G03-3 this does not change with chunking.

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/169-g03-expat-chunk-comparison` @ `f985102` (= `student-Mass`, = `main` + #166). `xpact_assertions.dll` (SHA-256 `9d1f30aa84eec3da…`) and `xpact.dll` (`aaf5d1d297b083de…`), MSVC finalized builds, **identical results**. Reference: `libexpat.dll` Expat 2.8.1 (`R_2_8_1`, MSVC Release, `36a2532e2181ab8b…`). Python 3.14.0. Both DLLs driven by the same ctypes harness, same settings (namespaces as in the catalog, local external entities, `XML_PARAM_ENTITY_PARSING_ALWAYS`). |
| **Found by** | G03 (#169): the 93 G01 cases (#118) through xpact and Expat 2.8.1, `XML_Parse` and `XML_ParseBuffer`, whole and in chunks of 1, 2, 3, 7, 64, 1024 bytes |
| **Expected** | `xmldecl, startdoctype, elementdecl root, elementdecl a, elementdecl b`, then error 2 at 7:33 |
| **Actual** | `xmldecl, startdoctype`, then error 2 at 2:0 (every chunking). Trace: [ibm-not-wf-P51-ibm51n06.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P51-ibm51n06.xml.json) |
| **Error output** | none; the verdict and the error code are right |
| **Investigation** | Same in both builds and in all 14 configurations. |
| **Cause** | ❔ **unknown**. 🟡 suspected: the internal subset is checked as a whole before its declarations are delivered. |
| **Fix** | none yet |
| **Verification** | not yet; rerun `compare.py` and check that these cases become `match` and nothing else changes |

**Command:**
```powershell
python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll
python -I student\results\G03-comparison\compare.py --tag normal --xpact-dll build\native-eiffel\xpact.dll
```

Related: G03-3 (another case of reporting the error before delivering earlier events); G03-2 (position). Results: [G03 README](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/README.md).

## Discussion

### CodTanium, 2026-10-31 18:32: comment

Fixed in #196 (`391df71` on `student-Mass`, identical to the tested `00981fb`). A `]` that does not end the DOCTYPE no longer stops the subset before its declarations: the complete declarations in front of it are delivered, then error 2 at the `]` (inside a declaration) or at the content after it (between declarations), as Expat. Verified on both builds (`reports/issue-0173/report.md`): probe 10/10 = Expat (was 2/10), whole and byte by byte; G03 `ibm-not-wf-P51-ibm51n06.xml` now matches (declarations, then 2 at 7:33); W3C verdicts, output test and C# DLL tests unchanged per case; Expat runtests same 38; Eiffel matrix 4/4; Python 210 OK (also after the merge); benchmark stage 2,283 + 302, 0 failed. W3C-in-pieces test skipped (student decision 2026-10-31).
