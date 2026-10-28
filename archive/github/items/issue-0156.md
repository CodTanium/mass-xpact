# Issue #156: Finding: Tokenized attribute values (NMTOKENS, ID, IDREFS, ENTITIES, ...) are not normalized (F01-3)

Archived from <https://github.com/andersoxie/xpact/issues/156> on 2026-10-28 19:58 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-28 19:34 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test`, `investigation` |
| Milestone | - |

## Description

> Found by test 1 of the extra test round, the W3C output comparison ([report](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/report.md)). 🟡 Partly fixed: 3 of 4 cases pass with the F01-1 fix; `valid-sa-096` (internal DTD) remains.

| Field | |
|---|---|
| **1. Problem** | Tokenized attribute values (NMTOKENS, ID, IDREFS, ENTITIES, ...) are not normalized. 4 W3C case(s). Expat gives the expected output on the same cases, so the difference is in xpact. |
| **2. Environment** | Windows 11 (student PC); `student-Mass` @ `293918f`; `xpact.dll` and `xpact_assertions.dll` (EiffelStudio 25.12, MSVC); Python 3.14; Expat control = `pyexpat` 2.7.3. Both builds give the same result. |
| **3. Command** | `python -I reports\issue-0154\tools\run.py --dll build\native-eiffel-assertions\xpact_assertions.dll --out <folder>` from the repository root (the same with `build\native-eiffel\xpact.dll`) |
| **4. Expected** | the W3C catalog's `OUTPUT` file, byte for byte (James Clark canonical XML) |
| **5. Actual** | `valid-sa-096`: expected `a1="1 2"`, xpact `a1=" 1   2  "`. `not-sa02`: `id="  number99 "` instead of `id="number99"`. |
| **6. Error output** | no error: the document is accepted with wrong content. Diffs: [logs/before/diffs/](https://github.com/andersoxie/xpact/tree/student-Mass/reports/issue-0154/logs/before/diffs); per case: [results.tsv](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/logs/before/results.tsv) |
| **7. Investigation** | Expat as control on every case; both builds; the rerun gave the identical result. Small repro: - |
| **8. Cause** | ❔ unknown. Not investigated. `apply_default_attributes` already calls `collapse_spaces` for non-CDATA types, so it is not simply missing. Possibly the declared default value itself, or declarations from an external file (F01-1). |
| **9. Fix** | partly: the [F01-1 fix](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/report.md) fixes `ibm-invalid-P32-ibm32i03`, `not-sa02`, `not-sa03` (declarations from an external file). `valid-sa-096` still fails: there the **declared default value** `" 1  	2 	"` itself is not normalized |
| **10. Verification** | ⬜ after a fix: rerun `run.py` with the assertions build, then the old test lanes |

**Cases:** `valid-sa-096`, `ibm-invalid-P32-ibm32i03`, `not-sa02`, `not-sa03`

**How the test works:** for the 432 W3C cases that have an expected `OUTPUT` file, the document is parsed through the DLL with the Expat C API, the events are written as canonical XML and compared byte for byte. Expat (`pyexpat`) runs the same way as a control.

Related: #154 (F01-1), #155 (F01-2), #156 (F01-3), #157 (F01-4), #158 (F01-5), #159 (F01-6).

## Discussion

### CodTanium, 2026-10-28 19:48: comment

3 of the 4 cases (`ibm-invalid-P32-ibm32i03`, `not-sa02`, `not-sa03`) pass with the #154 fix (PR #160): their declarations are in an external file. `valid-sa-096` is left: the declared default value of an NMTOKENS attribute is not normalized.
