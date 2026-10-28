# Issue #79: Finding: parser fails 283 W3C cases and the DLL tests (#38, #39, #40, K3); Jenkins FAILURE on main

Archived from <https://github.com/andersoxie/xpact/issues/79> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | open (reopened) |
| Author | CodTanium |
| Created | 2026-10-23 16:46 |
| Closed |  |
| Labels | `bug`, `type:finding`, `P0`, `test` |
| Milestone | - |

## Description

**1. Problem:** the Jenkins build of `main` at `cf12dee` (2026-10-23) ends in FAILURE at the W3C XML conformance check: 236 wrong verdicts in both finalized builds and 47 crashes with assertions on. The DLL tests from #37 also show #38 (start-tag shortcut skips parsing), #39 (invalid UTF-8 accepted) and #40 (crash when a chunk ends with `<`), and the assertions DLL smoke test crashes (K3, draft 07).

**2. Environment:** Jenkins (EiffelStudio 25.02 Enterprise, VS 2022) and the student PC (EiffelStudio 25.12 Standard, VS 18) give identical W3C totals.

**3. Command:** `scripts\run_benchmarks.ps1 -EiffelBuild Finalized,FinalizedAssertions` (Jenkins "Benchmarks" stage).

**4. Expected:** every applicable W3C case (1,727 per build) passes; no crashes.

**5. Actual:** Finalized 1,491 passed / 236 failed; FinalizedAssertions 1,444 passed / 236 failed / 47 errors.

**6. Error output:** `W3C XML conformance failed` (`run_benchmarks.ps1:597`), `Finished: FAILURE`.

**7. Investigation / 8. Cause (confirmed per case by the fix):** no UTF-8 decoding (characters checked per byte, names accepted any byte > 127), no UTF-16 support, DTD declarations without required-space and keyword checks, loops whose error branches do not advance (contract failures under assertions), the #38 shortcut also running on the final call, and smaller WFC/validity mix-ups.

**9. Fix / 10. Verification:** in the linked PR and `reports/issue-NNNN/report.md`.

## Discussion

### CodTanium, 2026-10-23 17:45: comment

Reopened until Jenkins confirms the fix. It was closed automatically when PR #80 was merged into `main` (`366460d`), but the project rule is to close an issue only after the result is verified.

**Verified so far (student PC):** W3C 1,727/1,727 in both finalized builds, DLL tests 3,360/3,360 on both DLLs, all local Jenkins stages pass ([report](https://github.com/andersoxie/xpact/blob/main/reports/issue-0079/report.md)). GitHub Actions "Python harness tests" passed on `366460d`.

**Still needed:** a Jenkins run of `main` at `366460d` or later that gets through the Benchmarks stage with `unexpected: 0` for Finalized and FinalizedAssertions. Close this issue (and #38, #39, #40) with a link to that run.
