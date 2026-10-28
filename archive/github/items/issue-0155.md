# Issue #155: Finding: Attribute defaults are not applied to elements inside an external general entity (F01-2)

Archived from <https://github.com/andersoxie/xpact/issues/155> on 2026-10-28 21:36 UTC.

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
| **1. Problem** | Attribute defaults are not applied to elements inside an external general entity. 1 W3C case(s). Expat gives the expected output on the same cases, so the difference is in xpact. |
| **2. Environment** | Windows 11 (student PC); `student-Mass` @ `293918f`; `xpact.dll` and `xpact_assertions.dll` (EiffelStudio 25.12, MSVC); Python 3.14; Expat control = `pyexpat` 2.7.3. Both builds give the same result. |
| **3. Command** | `python -I reports\issue-0154\tools\run.py --dll build\native-eiffel-assertions\xpact_assertions.dll --out <folder>` from the repository root (the same with `build\native-eiffel\xpact.dll`) |
| **4. Expected** | the W3C catalog's `OUTPUT` file, byte for byte (James Clark canonical XML) |
| **5. Actual** | expected `<doc><e a1="a1 default" a2="a2 default"></e></doc>`, xpact `<doc><e></e></doc>` |
| **6. Error output** | no error: the document is accepted with wrong content. Diffs: [logs/before/diffs/](https://github.com/andersoxie/xpact/tree/student-Mass/reports/issue-0154/logs/before/diffs); per case: [results.tsv](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/logs/before/results.tsv) |
| **7. Investigation** | Expat as control on every case; both builds; the rerun gave the identical result. Small repro: [mini/ext-ent.xml](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/mini/ext-ent.xml) + [mini/e.ent](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/mini/e.ent): the first `<e>` (from the file) gets no attribute, the second gets `a="dflt"`. |
| **8. Cause** | ✅ confirmed by the fix (same root as F01-1). The child parser for an external general entity starts with an empty `attribute_decl_table`: `import_entity_context` (`src/xp_parser.e`) copies the parent's entity tables but not its attribute declarations. Same root as F01-1. |
| **9. Fix** | [reports/issue-0154/report.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0154/report.md): `src/xp_parser.e` copies `attribute_decl_table` between parent and child parser (import, merge, replay snapshot). branch `fix/154-attribute-defaults-external` |
| **10. Verification** | ✅ verified locally, both builds: test 1 359 → 393/432 with 0 cases worse; W3C verdicts, 247 external-entity cases, Python 206, C# vs Expat, Jenkins W3C stage (local), dual lane 910/910, Eiffel matrix 4/4 all unchanged. ⬜ Jenkins |

**Cases:** `valid-ext-sa-013`

**How the test works:** for the 432 W3C cases that have an expected `OUTPUT` file, the document is parsed through the DLL with the Expat C API, the events are written as canonical XML and compared byte for byte. Expat (`pyexpat`) runs the same way as a control.

Related: #154 (F01-1), #155 (F01-2), #156 (F01-3), #157 (F01-4), #158 (F01-5), #159 (F01-6).

## Discussion

### CodTanium, 2026-10-28 19:48: comment

Fix in PR #160 (into `student-Mass`): attribute declarations now pass between the parent and the external-entity child parser. W3C output test 359 -> 393 of 432, 0 worse; all old lanes unchanged, both builds. Report: [reports/issue-0154/report.md](https://github.com/andersoxie/xpact/blob/bca7d9d/reports/issue-0154/report.md). Stays open until the PR is merged and Jenkins has run.
