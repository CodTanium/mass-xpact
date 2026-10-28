# Issue #128: C02: turn the #38, #39, #40 reproductions into permanent regression tests

Archived from <https://github.com/andersoxie/xpact/issues/128> on 2026-10-28 01:33 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 19:36 |
| Closed | 2026-10-26 19:50 |
| Labels | `type:task`, `group:C-correctness`, `D2-guided`, `P0`, `test`, `regression` |
| Milestone | Week 5 - Regressions |

## Description

## Task
Week 5, C02 ([draft 13](../blob/student-Mass/student/github/issues/13-C02.md)): "Regressions added to the test suite". The reproductions of #38, #39 and #40 were found by the C# DLL test program (#37) and fixed in #80. No test that Jenkins runs checks them today: #80 added no tests, and the C# program is not in CI.

## Plan
1. **C smoke test** (`tests/native/xpact_eiffel_dll_smoke.c`): `build_native_eiffel.ps1` runs it on both DLLs, locally and on Jenkins. Add `check_final_input_regressions()`:
   - the C02 matrix (`<root/>`, `<root></root>`, `<root>hi</root>`, empty, `<root>`, `<root><child></root>`, `<root/>junk`);
   - 6 bad UTF-8 sequences in 6 places, plus `é` as a control;
   - with the callback sets none, start, end, start+end, chardata and default;
   - whole, split at every byte, and byte by byte.
2. **Eiffel suite** (`tests/xp_test_root.e`): add `test_final_input_regressions`. It runs the same inputs through `XP_PARSER` (whole) and `XP_NATIVE_PARSER` (every split, byte by byte).
3. **Prove the tests catch the bugs:** undo the #38 and #40 fixes in a scratch build, check that the new tests fail, then restore.

## Expected (written before running)
- On today's code, both DLLs and the Eiffel matrix (4 builds) pass with the new checks.
- With the #38 fix undone, the smoke test fails on `<root>` with a start handler.
- With the #40 fix undone, the assertions build stops at a non-final `<`.
- The error code of `<root/>junk` is not checked (#124 is open). Positions are not checked (#122).

## Done when
- [ ] Smoke check added; both DLL builds pass
- [ ] Eiffel test added; matrix 4/4
- [ ] Undo-fix check done for #38 and #40
- [ ] Draft 13 and PLAN.md ticked

## Discussion

### CodTanium, 2026-10-26 19:50: comment

Done in 508d9c5 (PR #129). Verified: both DLL smoke tests ok, Eiffel matrix 4/4 (MSVC). With the #38 fix undone the new smoke check fails on <root>; with the #40 fix undone the new Eiffel test fails (index_in_bounds). Report: reports/issue-0128/report.md.
