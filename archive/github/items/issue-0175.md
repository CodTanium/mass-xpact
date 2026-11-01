# Issue #175: Finding: an empty system literal (SYSTEM '') is reported as NULL, Expat passes "" (G03-6)

Archived from <https://github.com/andersoxie/xpact/issues/175> on 2026-11-01 03:16 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 06:04 |
| Closed | 2026-10-31 17:28 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
For `<!ENTITY unref SYSTEM ''>` the `EntityDeclHandler` gets **`systemId = NULL`**. Expat passes an **empty string**. With NULL an application cannot tell an external entity with an empty system ID from an internal entity.

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/169-g03-expat-chunk-comparison` @ `f985102` (= `student-Mass`, = `main` + #166). `xpact_assertions.dll` (SHA-256 `9d1f30aa84eec3da…`) and `xpact.dll` (`aaf5d1d297b083de…`), MSVC finalized builds, **identical results**. Reference: `libexpat.dll` Expat 2.8.1 (`R_2_8_1`, MSVC Release, `36a2532e2181ab8b…`). Python 3.14.0. Both DLLs driven by the same ctypes harness, same settings (namespaces as in the catalog, local external entities, `XML_PARAM_ENTITY_PARSING_ALWAYS`). |
| **Found by** | G03 (#169): the 93 G01 cases (#118) through xpact and Expat 2.8.1, `XML_Parse` and `XML_ParseBuffer`, whole and in chunks of 1, 2, 3, 7, 64, 1024 bytes |
| **Expected** | `entitydecl unref, systemId ""` |
| **Actual** | `entitydecl unref, systemId NULL`, every chunking. Trace: [ibm-valid-P11-ibm11v02.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-valid-P11-ibm11v02.xml.json) |
| **Error output** | none; the document is accepted |
| **Investigation** | Same in both builds and in all 14 configurations. |
| **Cause** | ❔ **unknown** (the code has not been looked at yet). |
| **Fix** | none yet |
| **Verification** | not yet; rerun `compare.py` and check that these cases become `match` and nothing else changes |

**Command:**
```powershell
python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll
python -I student\results\G03-comparison\compare.py --tag normal --xpact-dll build\native-eiffel\xpact.dll
```

Related: AlotOfTests F04-2 (the opposite case: `xmlns=""` gives `""` where Expat gives NULL). Results: [G03 README](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/README.md).

## Discussion

### CodTanium, 2026-10-31 17:28: comment

Fixed in #194 (`38aa67a` on `student-Mass`, identical to the tested `ee27feb`). The entity declaration and the DOCTYPE now pass an empty system literal as `""`, as Expat; it was NULL. Verified on both builds (`reports/issue-0175/report.md`): probe 7/7 = Expat (was 2/7; the DOCTYPE `SYSTEM ''` had the same mistake); G03 59 → 60 match (`ibm-valid-P11-ibm11v02.xml`), nothing else changed; W3C verdicts, output test, C# DLL tests and W3C in pieces unchanged per case; Expat runtests same 38; Eiffel matrix 4/4; Python 210 OK (also after the merge); benchmark stage 2,283 + 302, 0 failed.
