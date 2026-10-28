# Issue #121: C03/C10: compare chunk and malformed-UTF-8 results with Expat 2.8.1

Archived from <https://github.com/andersoxie/xpact/issues/121> on 2026-10-28 01:33 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 19:24 |
| Closed | 2026-10-26 19:34 |
| Labels | `type:task`, `group:C-correctness`, `D2-guided`, `P0`, `test` |
| Milestone | Week 5 - Regressions |

## Description

## Task
Week 5, C03 and C10 (part), the open parts: compare xpact's results with **Expat 2.8.1** (`R_2_8_1`, the version the libexpat adapter pins).

Drafts: [`student/github/issues/14-C03.md`](../blob/student-Mass/student/github/issues/14-C03.md), [`15-C10.md`](../blob/student-Mass/student/github/issues/15-C10.md).

## Plan
1. Build Expat 2.8.1 from source as `libexpat.dll` (MSVC x64, Release, upstream defaults). Build files go under `build\` and are not committed.
2. Add the two missing C10 inputs to `tests/dotnet/XpactDllTests/Catalog.cs`: a lone continuation byte `80` and `FF`, in the same six places.
3. Run the C# DLL test program (#37) with `--dll` on `libexpat.dll`, `xpact.dll` and `xpact_assertions.dll`.
4. Compare the runs case by case: verdict, error code, line, column, and chunked vs whole.
5. Results go in `student/results/C03-chunks/` and `student/results/C10-utf8/`. Each difference is minimized and saved as a byte-exact fixture.

## Expected (written before running)
- Expat rejects every malformed UTF-8 input, whole and at every split.
- On Expat, chunking never changes the verdict or the error code.
- xpact and Expat agree on every verdict, since all 3,360 cases pass on xpact today.
- Error codes: known to differ (the catalog's libexpat codes were never checked). Each difference gets recorded, not judged as a bug yet.

## Done when
- [ ] Expat 2.8.1 DLL built, version and SHA-256 recorded
- [ ] `80` and `FF` inputs added
- [ ] Three runs saved, comparison table written
- [ ] Differences saved as fixtures
- [ ] C03 and C10 drafts and PLAN.md ticked

## Discussion

### CodTanium, 2026-10-26 19:34: comment

Done in ed3febc (PR #127). Verified: Expat 2.8.1, xpact.dll and xpact_assertions.dll each 4,308/4,308 pass, 0 crash. 0 of 4,308 verdicts differ from Expat. Five differences reported as #122-#126. Report: reports/issue-0121/report.md; results: student/results/expat-2.8.1/.
