# Issue #51: Finding: import_msvc_environment.ps1 stops on "'vswhere.exe' is not recognized" in PowerShell 5.1

Archived from <https://github.com/andersoxie/xpact/issues/51> on 2026-10-26 20:59 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 07:15 |
| Closed | 2026-10-22 07:17 |
| Labels | `type:finding`, `group:B-reliable-results`, `P1`, `build` |
| Milestone | Week 3 - Failure reporting |

## Description

## Steps to reproduce
1. Open Windows PowerShell 5.1 without the MSVC environment and without `C:\Program Files (x86)\Microsoft Visual Studio\Installer` on `PATH`.
2. Run a script that loads MSVC with its output captured, e.g. `.\scripts\build_native_eiffel.ps1 *>&1 | Select -Last 5`, or `. .\scripts\import_msvc_environment.ps1` inside `& { ... } *>&1`.

## Expected
The MSVC environment is loaded and the script continues.

## Actual
`vcvars64.bat` calls `vswhere.exe` by name and prints `'vswhere.exe' is not recognized as an internal or external command` to stderr. With `$ErrorActionPreference = "Stop"`, Windows PowerShell 5.1 turns that into a `NativeCommandError` and the script stops in `import_msvc_environment.ps1` line 32. Seen again on 2026-10-22 when rebuilding the DLLs.

`import_msvc_environment.ps1` already knows where `vswhere.exe` is (`$VsWhere`), but does not put its folder on `PATH` for `vcvars64.bat`. Today the workaround is a manual first line in the setup guide (`student/report/setup-guide.md`, section 3), also noted in `student/PLAN.md` under "Workarounds in use".

## Proposed next step
Add the Installer folder to `PATH` inside the `cmd.exe` call that runs `vcvars64.bat`, then remove the manual step from the setup guide.

## Discussion

### CodTanium, 2026-10-22 07:17: comment

Fixed in `3076a92` (PR #52).
