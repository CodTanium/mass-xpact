# Issue #73: Finding: Jenkins DLL build cannot find the Eiffel include folder (C:\El2502E fallback replaced in #2/#10)

Archived from <https://github.com/andersoxie/xpact/issues/73> on 2026-10-26 18:53 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-23 07:54 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:B-reliable-results`, `P0`, `build`, `regression` |
| Milestone | Week 3 - Failure reporting |

## Description

## Problem
Jenkins (`ci/Jenkinsfile.windows-phase1`, run on `main` @ `9e1747d`, 2026-10-23) stops in stage **Build Eiffel-Backed DLL**; every later stage is skipped and the build is FAILURE.

## Environment
Jenkins machine: EiffelStudio 25.02.9.8723 Enterprise (win64), VS 2022 Build Tools (cl 19.44), Windows 11. Not reproducible on the student PC as is (there the 25.12 Standard path exists).

## Command
`scripts\build_native_eiffel.ps1` (Jenkins stage "Build Eiffel-Backed DLL")

## Expected / actual
- Expected: the script finds the Eiffel runtime include folder, as it did before the student fixes (`C:\El2502E\studio\spec\win64\include`).
- Actual: `Cannot find Eiffel runtime include directory.` at `scripts\build_native_eiffel.ps1:46`

## Cause — confirmed from the code
`9eb18bd` (#2) **replaced** the fallback `C:\El2502E\...` (EiffelStudio 25.02 Enterprise, the Jenkins install) with `C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard\...` (the student PC) instead of adding it. `20e6bc3` (#10, #11) did the same in `scripts\run_native_runtime_smoke.ps1:40`. `ISE_EIFFEL` is evidently not set on Jenkins (otherwise it would be used first) — suspected, not seen.

## Fix (planned)
In both scripts, search in order: `ISE_EIFFEL`, `C:\El2502E`, EiffelStudio 25.12 Standard, then the EiffelStudio that provides `ec` on `PATH`. Error message lists the folders searched.

## Done when
- [ ] Both scripts search the list above
- [ ] Order tested with a temporary copy of the function and fake install folders
- [ ] `build_native_eiffel.ps1` and `run_native_runtime_smoke.ps1` still build on the student PC
- [ ] Jenkins log saved in `reports/issue-NNNN/`; report with verification
- [ ] Jenkins rerun gets past the include lookup (needs the supervisor)

## Discussion

### CodTanium, 2026-10-23 12:02: comment

@andersoxie — request for a Jenkins rerun (no action needed until the PRs below are merged).

**What happened:** the Jenkins run on `main` @ `9e1747d` (2026-10-23) stopped at *Build Eiffel-Backed DLL* with `Cannot find Eiffel runtime include directory.` Full log: [`reports/issue-0073/jenkins-log-2026-10-23.txt`](https://github.com/andersoxie/xpact/blob/fix/73-eiffel-include-fallback/reports/issue-0073/jenkins-log-2026-10-23.txt).

**Cause (confirmed):** our fixes for #2 and #10 replaced the fallback `C:\El2502E` (your EiffelStudio 25.02 Enterprise) with the student PC's path instead of adding it. Sorry about that.

**Fixes, waiting for review/merge into `student-Mass`:**
- #75: `build_native_eiffel.ps1` and `run_native_runtime_smoke.ps1` search `ISE_EIFFEL` → `C:\El2502E` → EiffelStudio 25.12 Standard → the EiffelStudio of `ec` on `PATH`.
- #76 (#74): the same scripts keep an existing MSVC backend (`msc*`) instead of always forcing `msc_vc140`.

Both are tested on the student PC (lookup test with fake install folders: the Jenkins case failed before and passes now; DLL and runtime smoke build, exit 0), but **not on your Jenkins machine**.

**Request:** once #75 and #76 are in `student-Mass` and you have merged `student-Mass` into `main` (your decision — we don't touch `main`), please rerun the `xpact` job and paste or attach the console output here. #73 and #74 stay open until *Build Eiffel-Backed DLL* passes there.

Two more things from the same log, not caused by these PRs:
- *SonarQube analysis*: `HTTP 401 Unauthorized` from `sonarqube.bsharp.se` — the Sonar token in Jenkins seems missing or expired; only you can renew it.
- *Eiffel Tests* turns green but prints no test result (no `xpact Phase 1 tests: ok`). On the student PC the same stage script ran a stale `xpact_tests.exe` that printed nothing and exited 0, because the stage runs no `finish_freezing`. We will file this separately.
