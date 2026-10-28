# Issue #151: Integrate the #146 and #148 fixes with main (#150): DLL crashes and pr-xml timeouts on main

Archived from <https://github.com/andersoxie/xpact/issues/151> on 2026-10-28 21:36 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-27 12:39 |
| Closed |  |
| Labels | `type:task`, `group:C-correctness`, `test`, `regression` |
| Milestone | Week 6 - One improvement |

## Description

## Problem
`main` (#150, external resources) and the student branches #146 (Option A, F1-F7) and #148 (entity position speed) change the same external-entity code in `src/xp_parser.e`, and they conflict. On the student PC, `main` alone still **crashes or times out** on some W3C cases:

- in the **native DLL** path (Expat-compatible child parsers), and
- in the **assertions build** of the Eiffel harness.

The supervisor asked (2026-10-27) to reproduce the failing cases locally and fix them, to check which more cases can be run as XML 1.0, and to look into which XML version to support long term.

## Environment
Student PC, Windows 11 Home 10.0.26200, EiffelStudio 25.12.9.8922 (`msc_vc140`), MSVC (VS 18 Community), Python 3.15.0 (uv). Finalized `-keep` builds with assertions **off and on**, and `xpact.dll` / `xpact_assertions.dll`.
- `main` @ `1714f31`
- #146 @ `d4a3299`
- #148 @ `ee51655`

## Command
```powershell
# main (separate worktree)
.\scripts\run_benchmarks.ps1 -OutputDir build\w3c-main-20261027 -Iterations 100 -Repetitions 3 -SkipWslC -SkipNativeXpactC
# the native DLL checker (tests/native/xpact_w3c_case.c from #146) on the 247 in-profile external-entity cases, 30 s per case
python dll_entity_lane.py <runner> <suite> <out> Finalized=<checker> FinalizedAssertions=<checker>
```

## Expected
All 1,974 profile cases pass in both builds, through both the Eiffel harness and the DLL.

## Actual (`main` @ `1714f31`)
| Path | Assertions off | Assertions on |
|---|---|---|
| Eiffel harness, 1,974 cases | ✅ 1,974 | ⚠️ 1,971 + 3 **timeouts** (`pr-xml-little`, `pr-xml-utf-16`, `pr-xml-utf-8`) |
| native DLL, 247 external-entity cases | ⚠️ 246 + 1 **crash** (`not-wf-ext-sa-001`, `0xC00000FD` stack overflow) | ⚠️ 240 + 4 **crashes** (`not-wf-ext-sa-001`; `valid-ext-sa-005`, `valid-ext-sa-006`, `ext01`: `0xC0000028`) + the 3 `pr-xml-*` **timeouts at 30 s** |

## Investigation
- #150 fixes the **Eiffel resolver** path. #146 F1-F7 were written for the **native DLL** path. They overlap only partly.
- On `main`, the DLL crash and timeout cases match #146 **F1** (recursion through a child parser), **F3** (element count in an external entity) and **#148** (slow internal entity references).
- #146 F2, F4, F5 and F6a are already done in #150, in a more general form.
- #146 **F6b** (reject `version="1.1"` in an external entity, erratum E38) contradicts the 5th edition: 4th-edition erratum E10 reverses E38, and #150's `rmt-e2e-38` adjustment is correct.

## Cause
✅ Confirmed per case by running the same 247 cases on `main` and on the integrated tree: with F1, F3 and #148, the crashes and timeouts are gone.

## Fix
Merge `main` into #146, and add #148:
- **keep the teacher's code** for F2, F4, F5 and F6a
- **keep the student's** F1, F3, F7, #148 and the `--all-cases` lanes
- **remove** F6b
- map the teacher's standalone error to `XML_ERROR_ENTITY_DECLARED_IN_PE` (24)
- update one runner test to the merged routing

The full decision table is in the report.

## Verification
On the integrated tree, both builds:
- W3C `--all-cases`: 2,283 verdicts checked + 302 no-crash-only, **0 failed, 0 errors, 0 skipped**
- DLL lane: **247 / 247**
- Eiffel matrix: 4 / 4
- Python: 192 OK
- Not run on Jenkins yet.

## Links
- 📄 **Additional info: summary for the student and the supervisor**, with answers to the three questions (failing cases, more XML 1.0 cases, XML version): [summary.md](https://github.com/andersoxie/xpact/blob/fix/151-integrate-146-148-with-main/reports/issue-0151/summary.md)
- Full report, with the data **before and after**: [report.md](https://github.com/andersoxie/xpact/blob/fix/151-integrate-146-148-with-main/reports/issue-0151/report.md) · data folder: [runs/](https://github.com/andersoxie/xpact/blob/fix/151-integrate-146-148-with-main/reports/issue-0151/runs)
- Pull request: #152 (into `student-Mass`)
- Related: #146, #148 (PR #149), #150

## Status
- [x] Reproduced on `main`
- [x] Fixed and verified locally (both builds)
- [x] Pull request #152 opened
- [ ] Merged into `student-Mass`
- [ ] Jenkins run (close this issue only after it passes)

## Discussion

### CodTanium, 2026-10-28 01:28: comment

Merged into `student-Mass` as 293918f (PR #152) on 2026-10-28. Local Jenkins Benchmarks stage (10 s per case, both builds): all 2,585 W3C cases, 0 failed, 0 errors, 0 skipped. Details: [reports/latest-2026-10-28](https://github.com/andersoxie/xpact/blob/student-Mass/reports/latest-2026-10-28/README.md). **Kept open until a Jenkins run on `student-Mass` confirms it.**
