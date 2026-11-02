# Issue #170: Finding: error code differs from Expat on 14 W3C cases (G03-1)

Archived from <https://github.com/andersoxie/xpact/issues/170> on 2026-11-02 15:47 UTC.

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
On 14 of the 93 G01 cases (13 counted, 1 marked) xpact rejects the document, as Expat does, but with **another error code**. The code is the same in all 14 chunkings, so it does not depend on how the input arrives.

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/169-g03-expat-chunk-comparison` @ `f985102` (= `student-Mass`, = `main` + #166). `xpact_assertions.dll` (SHA-256 `9d1f30aa84eec3da…`) and `xpact.dll` (`aaf5d1d297b083de…`), MSVC finalized builds, **identical results**. Reference: `libexpat.dll` Expat 2.8.1 (`R_2_8_1`, MSVC Release, `36a2532e2181ab8b…`). Python 3.14.0. Both DLLs driven by the same ctypes harness, same settings (namespaces as in the catalog, local external entities, `XML_PARAM_ENTITY_PARSING_ALWAYS`). |
| **Found by** | G03 (#169): the 93 G01 cases (#118) through xpact and Expat 2.8.1, `XML_Parse` and `XML_ParseBuffer`, whole and in chunks of 1, 2, 3, 7, 64, 1024 bytes |
| **Expected** | the same `XML_GetErrorCode` as Expat 2.8.1 |
| **Actual** | see the table below |
| **Error output** | none: the verdict (REJECT) is right in all 14 and equals Expat's; only the code differs |
| **Investigation** | Compared per case and per chunking; both DLL builds agree; each engine gives the same code in every chunking. No single pattern: xpact gives a more general code in some cases (2, 4) and a more specific one in others (5, 18). |
| **Cause** | ❔ **unknown**. Probably several code paths, not one cause; to be split when investigated. |
| **Fix** | none yet |
| **Verification** | not yet; rerun `compare.py` and check that these cases become `match` and nothing else changes |

**Command:**
```powershell
python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll
python -I student\results\G03-comparison\compare.py --tag normal --xpact-dll build\native-eiffel\xpact.dll
```

Related: #124 (another input: junk after the root element gives 4, not 9); AlotOfTests F05-3. Results: [G03 README](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/README.md).

| case | xpact | Expat 2.8.1 |
|---|---|---|
| [not-wf-sa-101](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-101.json) | 18 unknown encoding | 30 XML declaration not well-formed |
| [not-wf-sa-007](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-007.json) | 5 unclosed token | 4 invalid token |
| [not-wf-sa-121](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-121.json) | 4 invalid token | 2 syntax error |
| [ibm-not-wf-P72-ibm72n06.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P72-ibm72n06.xml.json) | 4 invalid token | 2 syntax error |
| [not-wf-sa-055](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-055.json) | 5 unclosed token | 2 syntax error |
| [o-p56fail2](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/o-p56fail2.json) | 4 invalid token | 2 syntax error |
| [ibm-not-wf-P29-ibm29n02.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P29-ibm29n02.xml.json) | 2 syntax error | 10 illegal parameter entity reference |
| [not-wf-sa-020](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-020.json) | 5 unclosed token | 4 invalid token |
| [attlist11](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/attlist11.json) | 2 syntax error | 4 invalid token |
| [ibm-not-wf-P40-ibm40n04.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P40-ibm40n04.xml.json) | 4 invalid token | 2 syntax error |
| [not-wf-sa-051](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-051.json) | 4 invalid token | 2 syntax error |
| [ibm-not-wf-P17-ibm17n02.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P17-ibm17n02.xml.json) | 2 syntax error | 4 invalid token |
| [ibm-not-wf-P10-ibm10n06.xml](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/ibm-not-wf-P10-ibm10n06.xml.json) | 5 unclosed token | 4 invalid token |
| [not-wf-sa-081](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/not-wf-sa-081.json) | 2 syntax error (marked case, not counted) | 16 reference to external entity in attribute |
