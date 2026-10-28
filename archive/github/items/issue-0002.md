# Issue #2: Finding: build_native_eiffel.ps1 cannot find the Eiffel runtime include directory

Archived from <https://github.com/andersoxie/xpact/issues/2> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-19 21:25 |
| Closed | 2026-10-19 23:13 |
| Labels | `bug`, `type:finding`, `group:B-reliable-results`, `D2-guided`, `P0`, `build` |
| Milestone | Week 1 - Setup |

## Description

## Report details

| Item | Value |
|---|---|
| Git commit | **Rerun:** `5240cfc6b43893470f1db820387f707a3421f692` (`student-Mass` before the fix, git clone, exact). **Original run** (2026-10-19): copied folder `xpact3.0\...`, not a git clone, most likely `4f71743`. |
| Input file / SHA-256 | n/a: build failure, no XML is parsed |
| Exact command | `.\scripts\build_native_eiffel.ps1` (defaults: `-BuildTier Production -OutputDir build\native-eiffel`), `ISE_EIFFEL` unset. Rerun as `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_native_eiffel.ps1` |
| Compiler versions | EiffelStudio 25.12.9.8922 win64 · Visual Studio 18 Community 18.10.3, MSVC 14.51.36231 · Windows 11 Home 10.0.26300 · Windows PowerShell 5.1 |
| Assertions / build mode | Production tier: target `xpact_native_library`, assertions **off** (all six off in `tests/xpact_native_library.ecf`), **Finalized** (`ec -finalize`). The script stopped before `ec` ran. |
| Loaded library | None: the script stopped before any DLL was built (`build\native-eiffel` empty) |
| Callbacks | n/a (no parse) |
| Chunk sizes | n/a (no parse) |
| Expected | `build\native-eiffel\xpact.dll` is built and the smoke test passes |
| Actual | Stops in `Get-IseInclude` with "Cannot find Eiffel runtime include directory." before any C file is compiled |
| Exit status | **1** (rerun, `powershell -File` exit code). Original run: stopped at the same `throw`; exact code not recorded. |

Expectations for the reruns were written to a file at 2026-10-20 00:39, before running anything. For the original run (2026-10-19) the expectation was not written down beforehand; it is recorded here afterwards.

## Error output: rerun at 5240cfc (full)

<details><summary>Full console output (issue2-before-fix.txt)</summary>

```text
commit 5240cfc6b43893470f1db820387f707a3421f692
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
Cannot find Eiffel runtime include directory.
At C:\Users\masou\AppData\Local\Temp\claude\c--Users-masou-Desktop-Lia-xpact3-0-xpact-codex-w3c-xml-conformance-benchma
rks\6992f0bd-9539-424c-9ed2-62f5622c238e\scratchpad\rerun\wt-5240cfc\scripts\build_native_eiffel.ps1:46 char:2
+     throw "Cannot find Eiffel runtime include directory."
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Cannot find Eif...lude directory.:String) [], RuntimeException
    + FullyQualifiedErrorId : Cannot find Eiffel runtime include directory.
 
EXIT=1
```

</details>

## Error output: original run, 2026-10-19 (full, as pasted)

```text
.\scripts\build_native_eiffel.ps1
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
Cannot find Eiffel runtime include directory.
At C:\Users\masou\Desktop\Lia\xpact3.0\xpact-codex-w3c-xml-conformance-benchmarks\scripts\build_native_eiffel.
ps1:46 char:2
+     throw "Cannot find Eiffel runtime include directory."
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Cannot find Eif...lude directory.:String) [], RuntimeExcepti
   on
FullyQualifiedErrorId : Cannot find Eiffel runtime include directory.
```

## Observations
- `Get-IseInclude` (`scripts/build_native_eiffel.ps1:35-47`) checks `$env:ISE_EIFFEL\studio\spec\win64\include`, then a hard-coded `C:\El2502E\studio\spec\win64\include`.
- `ISE_EIFFEL` is not set (user, machine and process) and `C:\El2502E` does not exist.
- The directory exists at `C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard\studio\spec\win64\include`, and `ec` is on PATH.
- The `'vswhere.exe' is not recognized` lines in the rerun come from `vcvars64.bat` and are harmless at this point (see #7).

## Cause (confirmed)
The fallback path belongs to a different install (EiffelStudio 25.02 Enterprise). With `ISE_EIFFEL` unset, neither location exists.

## Status
Fixed on `student-Mass` in 9eb18bd (fallback set to the 25.12 Standard install). With that fix the build gets past this step and stops at #7. Fix report: [reports/fix-report-issue-2.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/fix-report-issue-2.md). Kept open until the fix reaches `main`.

## Logs
- Rerun output: above
- Original report: [reports/error-report-2026-10-19.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/error-report-2026-10-19.md), error 1

## Discussion

### CodTanium, 2026-10-19 22:16: comment

Fixed on `student-Mass` in 9eb18bd: the fallback in `scripts/build_native_eiffel.ps1:42` now points to `C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard\studio\spec\win64\include`. `ISE_EIFFEL` still takes priority.

Fix report with all four options considered and the verification run: [reports/fix-report-issue-2.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/fix-report-issue-2.md)

**Verification:** with `ISE_EIFFEL` unset, the include-directory error no longer appears. The build then stops at the known `'vswhere.exe' is not recognized` stderr error (`build_native_eiffel.ps1:52`), which is not part of this issue; see the "Next blocker" section of the report.

Leaving this open until the fix reaches `main`. A more portable fix (searching the install folders, option 4) is suggested for that.

### CodTanium, 2026-10-19 23:29: comment

The fix report moved in #14: it is now [reports/issue-0002/report.md](https://github.com/andersoxie/xpact/blob/4a957b1/reports/issue-0002/report.md).
