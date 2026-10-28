# Issue #142: Re-enable the DLL smoke tests that CI and the release script skip (-SkipSmoke)

Archived from <https://github.com/andersoxie/xpact/issues/142> on 2026-10-28 01:33 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-26 23:11 |
| Closed |  |
| Labels | `type:task`, `group:B-reliable-results`, `test`, `build` |
| Milestone | - |

## Description

**Problem:** CI and the release script still build the assertions DLL with `-SkipSmoke`. The skip was added to hide the K3 crash (`0xC0000028`, draft 07). That crash was fixed in PR #80 (#79) and verified in #104, so the skip now only hides any new failure. The libexpat adapter stage also builds the production DLL with `-SkipSmoke`.

**Where:**
- `ci/Jenkinsfile.all-tests`: stage *Windows Native Tests* (`-BuildTier Assertions -SkipSmoke`) and stage *libexpat adapter* (`-SkipSmoke`)
- `ci/Jenkinsfile.windows-phase1`: `-BuildTier Assertions -SkipSmoke`
- `scripts/package_windows_release.ps1`: `-BuildTier Assertions -SkipSmoke`

**Environment:** student PC, Windows 11, EiffelStudio 25.12.9.8922, MSVC 19.51, `ISE_C_COMPILER=msc_vc140`, `student-Mass` @ `36509b8`, finalized, assertions on.

**Command:** `.\scripts\build_native_eiffel.ps1 -BuildTier Assertions` (smoke on)
**Expected:** `xpact Eiffel DLL smoke: ok`, exit 0, so the skip can be removed.
**Actual (2026-10-27):** `xpact Eiffel DLL smoke: ok`, exit 0.

**Cause:** confirmed. The skip was a workaround for K3, which is fixed.
**Fix:** remove `-SkipSmoke` from these four calls. The benchmark and audit scripts keep their own `-SkipSmoke`, because they are measurement tools, not tests; in CI they run with `-SkipBuild` anyway.
**Verification:** local build with smoke ok. The Jenkins run on the PR branch is still to be checked; do not close before that.

## Discussion

### CodTanium, 2026-10-26 23:18: comment

Merged into student-Mass as 3daef15 (PR #144). Verified locally: CI native stage commands and package_windows_release.ps1 print `xpact Eiffel DLL smoke: ok` for both DLLs, exit 0 (reports/issue-0142). **Kept open** until a Jenkins all-tests run shows *build Eiffel-backed DLLs* green with the smoke test on.

### CodTanium, 2026-10-28 01:28: comment

`student-Mass` @ 293918f includes this change; the Jenkins run requested for #146/#151 will also show whether the assertions DLL smoke step is green.
