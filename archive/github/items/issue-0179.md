# Issue #179: Finding: run_libexpat_adapter.ps1 without -XpactLibrary links the bridge-only xpact.lib (A04-1)

Archived from <https://github.com/andersoxie/xpact/issues/179> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 09:19 |
| Closed | 2026-10-31 13:41 |
| Labels | `bug`, `type:finding`, `group:B-reliable-results`, `test`, `build` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
Run without `-XpactLibrary` (and without `XPACT_EXPAT_LIBRARY`), `scripts/run_libexpat_adapter.ps1 -Mode NativeSuite` links Expat's C tests against **`build\native\xpact.lib`**, the C bridge **without** the Eiffel parser. Every parse then fails with error 44 and the suite reports it as an unexpected failure. Jenkins is **not** affected: it passes `-XpactLibrary build\native-eiffel\xpact.lib` (`XPACT_LIBRARY` in `ci/Jenkinsfile.all-tests`). A developer running the script by hand after `run_native_abi_tests.ps1` or `build_native.ps1` gets the wrong library without a warning.

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/168-a04-loaded-library` @ `f985102` (= `student-Mass`), Visual Studio 18 Community (MSVC, bundled CMake), Expat 2.8.1 sources (`R_2_8_1`), PowerShell 5.1. |
| **Found by** | A04 (#168): every runner run under a load watcher (Windows debug API) that records each DLL a process loads, with its SHA-256 |
| **Expected** | the Eiffel-backed `build\native-eiffel\xpact.dll`, as Jenkins uses, or a clear error when no library is given |
| **Actual** | the test program loads `build\native\xpact.dll` (bridge-only, SHA-256 `f65b09225e2c1a0d…`); see [loads.txt](https://github.com/andersoxie/xpact/blob/fix/168-a04-loaded-library/student/results/A04-loaded-library/runs/libexpat-adapter-default/loads.txt) |
| **Error output** | `FAIL [chunksize=0 deferral=0]: test_nul_byte` … `ERROR: 44: Eiffel parser bridge is not installed (line 1, offset 0)`, then `Native libexpat suite failed unexpectedly: basic_tests.c/test_nul_byte`; [console](https://github.com/andersoxie/xpact/blob/fix/168-a04-loaded-library/student/results/A04-loaded-library/runs/libexpat-adapter-default/) |
| **Investigation** | Same command with `-XpactLibrary build\native-eiffel\xpact.lib` loads the normal Eiffel DLL ([loads.txt](https://github.com/andersoxie/xpact/blob/fix/168-a04-loaded-library/student/results/A04-loaded-library/runs/libexpat-adapter-jenkins/loads.txt)) and gives the known 399 checks / 38 expected (allocator) failures. Code: `Resolve-XpactLibrary` returns `build\native\xpact.lib` (or `libxpact.so`) when the parameter is empty. |
| **Cause** | ✅ **confirmed**: the fallback path in `Resolve-XpactLibrary` (`scripts/run_libexpat_adapter.ps1`, around line 315) points at the bridge-only build directory. |
| **Fix** | none yet. Options: default to `build\native-eiffel\xpact.lib`; or keep the fallback but stop with a clear message when the selected library is the bridge-only one |
| **Verification** | not yet; rerun `student/results/A04-loaded-library/run_a04.py --only libexpat-adapter-default` and check that it loads `normal` |

**Command:**
```powershell
.\scripts\run_native_abi_tests.ps1 -Target Windows   # builds build\native\xpact.lib
.\scripts\run_libexpat_adapter.ps1 -Mode NativeSuite -ExpatSourceDir <expat-2.8.1>\expat -OutputDir build\a04\adapter-default -SkipNativeBuild
```
Related: #168 (A04), error report section 4.6 (bridge-only DLL returns error 44).

## Discussion

### CodTanium, 2026-10-31 09:54: comment

Fix in PR #182 (into student-Mass). Default is now `build\native-eiffel\xpact.lib`, and NativeSuite builds with `build_native_eiffel.ps1`; the bridge-only build is never picked by itself.

Verified locally: documented default command gives 399 checks / 38 expected failures, exit 0; 208/208 test processes load the Eiffel DLL (before: 288 bridge-only); the new regression test fails on the old script; Python suite 207 OK. Report: reports/issue-0179/report.md on the branch.

Not closing until the PR is merged and checked.

### CodTanium, 2026-10-31 12:51: comment

Fix merged into `student-Mass`: #182 (`8ee95b8`); plan updated in #185 (`48c2fb8`).

Post-merge check on `student-Mass` @ `8ee95b8`: adapter tests 7 OK, Python suite 207 OK. Pre-merge evidence in `reports/issue-0179/report.md` (default command 399 checks / 38 expected failures; 208/208 test processes load `build\native-eiffel\xpact.dll`).

Leaving open until a Jenkins run includes the fix.

### CodTanium, 2026-10-31 13:41: comment

Closing: fixed in #182 (`8ee95b8`), verified locally (default command 399 checks / 38 expected failures; 208/208 test processes load the Eiffel DLL; Python suite OK after the merge). Student decision 2026-10-31: no Jenkins run needed for this script fix. Plan row moved to Solved in #190 (`5af2321`).
