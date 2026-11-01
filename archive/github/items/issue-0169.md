# Issue #169: G03 - Compare xpact and Expat 2.8.1 across chunks (G01 subset, XML_Parse and XML_ParseBuffer)

Archived from <https://github.com/andersoxie/xpact/issues/169> on 2026-11-01 03:16 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 05:58 |
| Closed | 2026-10-31 14:13 |
| Labels | `type:task`, `D2-guided`, `P0`, `test`, `group:G-verification` |
| Milestone | Week 7 - Comparison |

## Description

Student guide task **G03** ([student/github/issues/17-G03.md](../blob/student-Mass/student/github/issues/17-G03.md)), week 7.

## Goal
The G01 subset (93 reviewed W3C cases, #118) through **xpact.dll and Expat 2.8.1** (`libexpat.dll`, built from the R_2_8_1 source), both driven by the same code through the Expat C API, through **`XML_Parse` and `XML_ParseBuffer`**, whole and in selected chunk sizes.

## Done when
- [x] The G01 subset run through xpact and Expat 2.8.1 (whole input and selected chunk sizes, both API calls)
- [x] A table of matches, differences and untested cases, with totals that reconcile (expected vs xpact vs Expat, per configuration)
- [x] Traces saved for every difference; results in `student/results/G03-comparison/`
- [x] Every difference that is a bug filed as its own finding

## Discussion

### CodTanium, 2026-10-31 06:16: comment

G03 done in PR #178 (into `student-Mass`, waiting for review).

| | |
|---|---|
| ✅ Verdict | the same as Expat 2.8.1 in **all 1,302** pairs (93 G01 cases × `XML_Parse`/`XML_ParseBuffer` × whole, 1, 2, 3, 7, 64, 1024 bytes) |
| ✅ W3C expectation (83 counted) | xpact 81, Expat 81 (the same 2 misses: 5th-edition names) |
| ✅ Totals | 48 ACCEPT + 45 REJECT = 93 in every configuration, both engines; 0 crashes; no missing row |
| 🟡 Identical in everything | 59 / 93 |
| 🔴 Differences | 34 cases, filed as #170-#176 |
| ✅ Builds | assertions and normal identical |

Commands (assertions first): `python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll`, then `--tag normal --xpact-dll build\native-eiffel\xpact.dll`; both exit 0. Harness regression (test 1): 399/432, row for row unchanged. Environment: `f985102`, Windows 11, Python 3.14.0.

The issue stays open until the PR is merged.

### CodTanium, 2026-10-31 14:13: comment

Closing: G03 done and merged into `student-Mass` (PR #178, `9fc6f85`). All four boxes met: 93 G01 cases through xpact and Expat 2.8.1 in 14 ways (whole and chunked, `XML_Parse` and `XML_ParseBuffer`); totals reconcile (48 ACCEPT + 45 REJECT = 93 in every configuration); traces for all 34 differences in `student/results/G03-comparison/`; every bug filed (#170-#176). Student decision 2026-10-31: no Jenkins run needed.
