# Issue #174: Finding: #FIXED attribute default reported with isrequired = 0 (G03-5)

Archived from <https://github.com/andersoxie/xpact/issues/174> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 06:04 |
| Closed | 2026-10-31 18:00 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
For `<!ATTLIST doc a CDATA #FIXED "v">` the `AttlistDeclHandler` gets **`isrequired = 0`**. Expat's documented behaviour (expat.h): for `#FIXED` the default is passed **and `isrequired` is true**.

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/169-g03-expat-chunk-comparison` @ `f985102` (= `student-Mass`, = `main` + #166). `xpact_assertions.dll` (SHA-256 `9d1f30aa84eec3da…`) and `xpact.dll` (`aaf5d1d297b083de…`), MSVC finalized builds, **identical results**. Reference: `libexpat.dll` Expat 2.8.1 (`R_2_8_1`, MSVC Release, `36a2532e2181ab8b…`). Python 3.14.0. Both DLLs driven by the same ctypes harness, same settings (namespaces as in the catalog, local external entities, `XML_PARAM_ENTITY_PARSING_ALWAYS`). |
| **Found by** | G03 (#169): the 93 G01 cases (#118) through xpact and Expat 2.8.1, `XML_Parse` and `XML_ParseBuffer`, whole and in chunks of 1, 2, 3, 7, 64, 1024 bytes |
| **Expected** | `attlistdecl doc a CDATA "v" isrequired=1` |
| **Actual** | `attlistdecl doc a CDATA "v" isrequired=0`, every chunking. Trace: [valid-sa-079](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/valid-sa-079.json) |
| **Error output** | none; the document is accepted |
| **Investigation** | Same in both builds and in all 14 configurations; seen before in the AlotOfTests run (F04-1: 98k generated documents, 11 libxml2 files). |
| **Cause** | ❔ **unknown** (the code has not been looked at yet). |
| **Fix** | none yet |
| **Verification** | not yet; rerun `compare.py` and check that these cases become `match` and nothing else changes |

**Command:**
```powershell
python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll
python -I student\results\G03-comparison\compare.py --tag normal --xpact-dll build\native-eiffel\xpact.dll
```

Related: AlotOfTests F04-1. Results: [G03 README](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/README.md).

## Discussion

### CodTanium, 2026-10-31 18:00: comment

Fixed in #195 (`2ed37c5` on `student-Mass`). The attlist declaration event now gets `isrequired = 1` for `#FIXED`, as Expat's `expat.h` documents; the parser's own declaration table keeps its `#REQUIRED` meaning. Verified on both builds (`reports/issue-0174/report.md`): probe 5/5 = Expat (was 3/5); G03 59 → 60 match (`valid-sa-079`), nothing else changed; W3C verdicts, output test, C# DLL tests and W3C in pieces unchanged per case; Expat runtests same 38; Eiffel matrix 4/4; Python 210 OK (also after the merge); benchmark stage 2,283 + 302, 0 failed.
