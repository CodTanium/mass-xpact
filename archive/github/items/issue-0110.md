# Issue #110: Task: sync student-Mass with main after #101

Archived from <https://github.com/andersoxie/xpact/issues/110> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 16:36 |
| Closed | 2026-10-26 16:44 |
| Labels | `type:task`, `workflow` |
| Milestone | Week 4 - Input matrix |

## Description

## Task
Bring the supervisor's PR #101 (parser performance, 25-26 October) from `main` into `student-Mass`, so `student-Mass` is 0 commits behind `main`. `main` is only read, never changed.

`main` @ `de01371` is 11 commits ahead of `student-Mass` @ `731f8e2`: ASCII validation in input normalization, attribute name sets without strings, no prefix rescans, CDATA markers, batched text positions, DOCTYPE no-op parsing, plus profiling evidence (`docs/*performance*.md`, `benchmarks/results/`). Parser code: `src/xp_parser.e`, new `src/xp_attribute_name_range_set.e`; tests: +533 lines in `tests/xp_test_root.e`.

## Done when
- [ ] In-memory trial merge (`git merge-tree`) has no conflicts
- [ ] Pull request `main` → `student-Mass`, merged with a merge commit (not squashed)
- [ ] `student-Mass` is 0 behind `main`
- [ ] Tests on the merged code, expected results written first: Eiffel matrix (4 lanes), both DLLs + C# DLL tests, W3C both builds — all with `ISE_C_COMPILER=msc_vc140`
- [ ] Local copy refreshed with `sync-latest.ps1`

## Discussion

### CodTanium, 2026-10-26 16:44: comment

Done and verified 2026-10-26 — report: https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0110/report.md

- [x] `git merge-tree` trial merge: no conflicts
- [x] PR #111 merged with a merge commit (`e8c5cb3`); `main` unchanged at `de01371`
- [x] `student-Mass` is **0 behind `main`**
- [x] Tests on the merged code (`ISE_C_COMPILER=msc_vc140`, expected results written first): Eiffel matrix 4/4 lanes, both DLL smoke tests, C# DLL tests 3,360/3,360 on both DLLs (0 crash), W3C 1,727 passed / 0 failed in both builds. Python 3.14: the 15 known long-path problems (#104), as expected
- [x] Local copy refreshed with `sync-latest.ps1`

Evidence recorded in PR #112 (`72b2f5c`).
