# Issue #146: Option A: run all 2,585 W3C cases (no skips) and fix the 7 parser bugs they expose (F1-F7)

Archived from <https://github.com/andersoxie/xpact/issues/146> on 2026-10-28 21:36 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-27 02:01 |
| Closed |  |
| Labels | `bug`, `type:task`, `group:C-correctness`, `test` |
| Milestone | - |

## Description

**Option A** for "no skipped W3C cases": run every case of the W3C suite (xmlts20130923) instead of skipping 858 per build, and fix the parser bugs this exposes. Other options may follow; this issue records option A only.

## Problem
Jenkins build #70 reports 3,500 passed and **1,716 skipped** (858 per build). The skipped cases have reasons (old XML editions, XML 1.1, external entities, optional errors), but some of them can be judged, and the external-entity path of the DLL had never been tested.

## Environment
Student PC, Windows 11, EiffelStudio 25.12.9.8922, MSVC 19.51 (`msc_vc140`), Python 3.14. Finalized builds with assertions off and on. Base `student-Mass` @ `ec1705d`.

## Option A: what changes
1. **Runner** `scripts/run_w3c_conformance.py`: opt-in `--all-cases`. Without it, nothing changes (Jenkins keeps 1,727 run, 858 skipped). With it, the 858 cases run in lanes:
   - `legacy-names`, 309: W3C verdict with the 4th-edition name tables that `XP_NATIVE_PARSER` uses;
   - `external-entities`, 247: W3C verdict through the DLL, with files loaded like Expat programs;
   - `optional-error`, 28: either verdict passes, a crash fails;
   - `xml-1.1`, 274: either verdict passes, a crash fails.
2. **Eiffel harness** `benchmarks/xp_benchmark_root.e`: `--legacy-names`.
3. **DLL checker** `tests/native/xpact_w3c_case.c` (new).
4. **Parser fixes**, found by the new lanes. One problem each:

| | Problem | Before | After |
|---|---|---|---|
| F1 | an external entity that references itself | crash `0xC00000FD` / `0xC0000005` | REJECT "recursive entity reference" |
| F2 | `%pe;` inside ELEMENT/ATTLIST/NOTATION in an external DTD (48 cases, incl. the XML spec document) | REJECT | ACCEPT; still REJECT in the internal subset |
| F3 | the assertions DLL with two top-level elements in an external entity | silent exit `0xC00000FF` (invariant `document_element_count <= 1`) | ACCEPT |
| F4 | `standalone="yes"` + an entity declared only externally (3 cases) | ACCEPT | REJECT, `XML_ERROR_ENTITY_DECLARED_IN_PE` |
| F5 | a text declaration without `encoding=` (2 cases) | ACCEPT | REJECT, `XML_ERROR_TEXT_DECL` |
| F6 | a misplaced `<?xml?>` from an internal PE; a 1.0 document including a 1.1 entity (2 cases) | ACCEPT | REJECT |
| F7 | `ExternalEntityRefHandler` got `base = NULL` | NULL | the parser's base from `XML_SetBase` |

## Command
`python scripts/run_w3c_conformance.py --all-cases --timeout 30 --engine ... --entity-engine ...` (full command in the report).

## Expected
0 skipped, and every case gives its lane's expected result, in both builds. No regression in the other suites.

## Actual
| | Passed | Failed | Errors | Skipped |
|---|---:|---:|---:|---:|
| before (Jenkins #70, per build) | 1,727 | 0 | 0 | 858 |
| `--all-cases`, before fixes (off / on) | 2,533 / 2,527 | 51 / 51 | 1 / 7 | 0 |
| **`--all-cases`, after fixes, 30 s** (both builds) | **2,585** | **0** | **0** | **0** |

With 10 s per case, the assertions build times out on the 3 `pr-xml-*` documents. They take about 16 s each and are accepted at 30 s.

## Cause
Confirmed per fix; see the report.

## Verification
Done locally, logs in the report:
- smoke tests: both DLLs ok;
- Eiffel test matrix: 4/4;
- Python: 178 OK;
- runtime smoke, ABI, chunked CRC (7/7), shim audit: all ok;
- C# DLL tests against Expat 2.8.1: 4,308 inputs, the same verdicts, and the difference table identical to before;
- runner without `--all-cases`: unchanged.

**Jenkins: not run yet.** Keep this issue open until it is.

## Limitations
- The Eiffel API resolver path is not covered by the W3C run.
- The xml-1.1 and optional-error lanes prove "no crash" only.
- Canonical output (`OUTPUT`) is not compared.
- F7 passes the reading parser's base, not the declaring one.

## Discussion

### CodTanium, 2026-10-27 12:45: comment

Integrated with `main` (#150) in #151 / PR #152. The full decision per fix is in the [#151 report](https://github.com/andersoxie/xpact/blob/fix/151-integrate-146-148-with-main/reports/issue-0151/report.md#3-which-fix-was-kept-and-why) (short version: [summary](https://github.com/andersoxie/xpact/blob/fix/151-integrate-146-148-with-main/reports/issue-0151/summary.md)).

On `main`, F1 and F3 are still needed (DLL crashes on `not-wf-ext-sa-001`, `valid-ext-sa-005/006` and `ext01`). F2, F4, F5 and F6a were already done in #150, so the teacher's code is kept. F6b is removed (erratum E10 reverses E38).

### CodTanium, 2026-10-28 01:28: comment

Merged into `student-Mass` as 293918f (PR #152) on 2026-10-28. Local Jenkins Benchmarks stage (10 s per case, both builds): all 2,585 W3C cases, 0 failed, 0 errors, 0 skipped. Details: [reports/latest-2026-10-28](https://github.com/andersoxie/xpact/blob/student-Mass/reports/latest-2026-10-28/README.md). **Kept open until a Jenkins run on `student-Mass` confirms it.**
