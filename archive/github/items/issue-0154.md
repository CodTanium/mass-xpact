# Issue #154: Finding: attribute defaults from an external DTD or external parameter entity are not applied (F01-1)

Archived from <https://github.com/andersoxie/xpact/issues/154> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-28 19:34 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test` |
| Milestone | - |

## Description

> Found by test 1 of the extra test round, the W3C output comparison ([report](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/report.md)). ✅ Fixed on the branch for #154, see the report.

| Field | |
|---|---|
| **1. Problem** | Attribute defaults from an external DTD or external parameter entity are not applied. 30 W3C case(s). Expat gives the expected output on the same cases, so the difference is in xpact. |
| **2. Environment** | Windows 11 (student PC); `student-Mass` @ `293918f`; `xpact.dll` and `xpact_assertions.dll` (EiffelStudio 25.12, MSVC); Python 3.14; Expat control = `pyexpat` 2.7.3. Both builds give the same result. |
| **3. Command** | `python -I reports\issue-0154\tools\run.py --dll build\native-eiffel-assertions\xpact_assertions.dll --out <folder>` from the repository root (the same with `build\native-eiffel\xpact.dll`) |
| **4. Expected** | the W3C catalog's `OUTPUT` file, byte for byte (James Clark canonical XML) |
| **5. Actual** | `valid-not-sa-003`: expected `<doc a1="v1">`, xpact `<doc>`. `valid-sa-097` (first declaration must win): expected `<doc a1="v1">`, xpact `<doc a1="v1" a2="v2">`. `valid-not-sa-026`: expected `a1="w1"`, xpact `a1="x1"`. |
| **6. Error output** | no error: the document is accepted with wrong content. Diffs: [logs/before/diffs/](https://github.com/andersoxie/xpact/tree/student-Mass/reports/issue-0154/logs/before/diffs); per case: [results.tsv](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/logs/before/results.tsv) |
| **7. Investigation** | Expat as control on every case; both builds; the rerun gave the identical result. Small repro: [mini/ext-dtd.xml](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/mini/ext-dtd.xml) + [mini/ext.dtd](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/mini/ext.dtd): `<d>` gets no `a="default-from-dtd"` (Expat: it does). |
| **8. Cause** | ✅ confirmed by the fix (see Fix). Each parser has its own `attribute_decl_table` (`src/xp_parser.e`). An external DTD or parameter entity is read by a child parser (`XML_ExternalEntityParserCreate`). When it finishes, `merge_entity_context_from` copies only the **entity** tables back to the parent, not the attribute declarations. The replay snapshot (`entity_context_snapshot`) has the same gap. |
| **9. Fix** | [reports/issue-0154/report.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/report.md): `src/xp_parser.e` copies `attribute_decl_table` between parent and child parser (import, merge, replay snapshot). branch `fix/154-attribute-defaults-external` |
| **10. Verification** | ✅ verified locally, both builds: test 1 359 → 393/432 with 0 cases worse; W3C verdicts, 247 external-entity cases, Python 206, C# vs Expat, Jenkins W3C stage (local), dual lane 910/910, Eiffel matrix 4/4 all unchanged. ⬜ Jenkins |

**Cases:** `invalid-not-sa-022`, `valid-sa-097`, `valid-not-sa-003` to `029` (25 cases), `ibm-invalid-P32-ibm32i01`, `ibm-valid-P32-ibm32v01` `v03` `v04`

**How the test works:** for the 432 W3C cases that have an expected `OUTPUT` file, the document is parsed through the DLL with the Expat C API, the events are written as canonical XML and compared byte for byte. Expat (`pyexpat`) runs the same way as a control.

Related: #154 (F01-1), #155 (F01-2), #156 (F01-3), #157 (F01-4), #158 (F01-5), #159 (F01-6).

## Discussion

### CodTanium, 2026-10-28 19:48: comment

Fix in PR #160 (into `student-Mass`): attribute declarations now pass between the parent and the external-entity child parser. W3C output test 359 -> 393 of 432, 0 worse; all old lanes unchanged, both builds. Report: [reports/issue-0154/report.md](https://github.com/andersoxie/xpact/blob/bca7d9d/reports/issue-0154/report.md). Stays open until the PR is merged and Jenkins has run.
