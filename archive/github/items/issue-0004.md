# Issue #4: Finding: importing the MSVC environment fails with "The input line is too long"

Archived from <https://github.com/andersoxie/xpact/issues/4> on 2026-10-24 20:26 UTC.

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
| Git commit | **Rerun:** `cada501ca3117135d3649e1e8ca45b2ccc717748` (`student-Mass`, git clone, exact). **Original run** (2026-10-19): copied folder `xpact3.0\...`, not a git clone, most likely `4f71743`. |
| Input file / SHA-256 | n/a: environment setup failure, no XML is parsed |
| Exact command | **Original:** `.\scripts\run_eiffel_test_matrix.ps1` (no parameters = `-AssertionMode All -BuildMode All`), in a window where `run_phase1.ps1` and `build_native_eiffel.ps1` had already run. **Rerun (minimal):** `powershell -NoProfile -ExecutionPolicy Bypass -File issue4-repeat-import.ps1 -Repo C:\Users\masou\Desktop\Lia\xpact\xpactGit`, which dot-sources `scripts\import_msvc_environment.ps1` repeatedly in one process (script below) |
| Compiler versions | EiffelStudio 25.12.9.8922 win64 · Visual Studio 18 Community 18.10.3, MSVC 14.51.36231 · Windows 11 Home 10.0.26300 · Windows PowerShell 5.1 |
| Assertions / build mode | n/a: fails while importing the MSVC environment, before any cell is compiled. The original command would have run all four cells (On/Off × Workbench/Finalized). |
| Loaded library | None: nothing was built or run |
| Callbacks | n/a (no parse) |
| Chunk sizes | n/a (no parse) |
| Expected | The MSVC environment loads every time, then the matrix cells run |
| Actual | PATH grows by 1,432 characters per import; the **5th** import fails with "The input line is too long." |
| Exit status | **1** (rerun). Original run: stopped at the `throw` in `import_msvc_environment.ps1:24`; exact code not recorded. |

Expectations for the reruns were written to a file at 2026-10-20 00:39, before running anything. For the original run (2026-10-19) the expectation was not written down beforehand; it is recorded here afterwards.

## Error output: rerun at cada501 (full)

<details><summary>Full console output (issue4-repeat-import.txt)</summary>

```text
commit cada501ca3117135d3649e1e8ca45b2ccc717748
start: PATH length 1335
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
import 1: ok, PATH length 2767
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
import 2: ok, PATH length 4199
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
import 3: ok, PATH length 5631
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
import 4: ok, PATH length 7063
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
The input line is too long.
The syntax of the command is incorrect.
import 5: FAILED, PATH length 7063
error: Failed to import Visual Studio C++ environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
EXIT=1
```

</details>

<details><summary>Rerun script: issue4-repeat-import.ps1</summary>

```powershell
# Dot-sources import_msvc_environment.ps1 repeatedly in one process, as
# running several scripts in one PowerShell window does.
param([string] $Repo)
$ErrorActionPreference = "Stop"
"commit $(git -C $Repo rev-parse HEAD)"
"start: PATH length $($env:Path.Length)"
for ($i = 1; $i -le 20; $i++) {
	try {
		. (Join-Path $Repo "scripts\import_msvc_environment.ps1")
		"import ${i}: ok, PATH length $($env:Path.Length)"
	} catch {
		"import ${i}: FAILED, PATH length $($env:Path.Length)"
		"error: $($_.Exception.Message)"
		exit 1
	}
}
"no failure after 20 imports"
exit 0
```

</details>

## Error output: original run, 2026-10-19 (full, as pasted)

```text
.\scripts\run_eiffel_test_matrix.ps1
The input line is too long.
The syntax of the command is incorrect.
Failed to import Visual Studio C++ environment from C:\Program Files\Microsoft Visual
Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
At C:\Users\masou\Desktop\Lia\xpact3.0\xpact-codex-w3c-xml-conformance-benchmarks\scripts\import_msvc_environm
ent.ps1:24 char:2
+     throw "Failed to import Visual Studio C++ environment from $VcVar ...
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Failed to impor...ld\vcvars64.bat:String) [], RuntimeExcepti
   on
    + FullyQualifiedErrorId : Failed to import Visual Studio C++ environment from C:\Program Files\Microsoft
   Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
```

## Observations
- PATH length: 1,335 at start → 2,767 → 4,199 → 5,631 → 7,063 after 4 imports (+1,432 each).
- The 5th import fails: `vcvars64.bat` itself prints "The input line is too long." once PATH plus what it prepends passes cmd.exe's ~8,191-character limit.
- `import_msvc_environment.ps1` copies the whole vcvars environment into the process with `Set-Item Env:...`, so every script in the same window that imports it adds another copy of the Visual Studio folders.

## Cause (confirmed by the rerun)
Repeated imports in one PowerShell process grow PATH until `vcvars64.bat` exceeds cmd.exe's line limit.

## Workaround and known fix
- **Workaround:** run each script in a new PowerShell window.
- **Fix (exists in another local copy, `xpactVsCode\xpact\scripts\import_msvc_environment.ps1`):** skip the import when `VSCMD_VER` is set and `cl.exe` is found, and de-duplicate PATH when importing.
- `build_native_eiffel.ps1` also runs `vcvars64.bat` again for every `cl`/`link` call (`Invoke-VcCommand`), starting from the already-long PATH.

## Logs
- Rerun output and script: above
- Original report: [reports/error-report-2026-10-19.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/error-report-2026-10-19.md), error 3

## Discussion

### CodTanium, 2026-10-19 22:53: comment

Fixed on `student-Mass` in 3b8a205 (pull request #9).

**Fix:** `scripts/import_msvc_environment.ps1` now skips the import when an x64 MSVC environment is already loaded (`VSCMD_VER`, `VSCMD_ARG_TGT_ARCH=x64`, `cl.exe` on PATH), and removes duplicate PATH entries when it does import.

**Verification** (fresh process each, expectations written before testing):

| Command | Before (eb6fc5d) | After |
|---|---|---|
| 20 imports in one process | PATH 1,335 → 7,063, **import 5 fails** ("The input line is too long."), exit 1 | PATH 2,657 after import 1, unchanged for imports 2-20, **exit 0** |
| `build_native_eiffel.ps1` twice in one process | not run | both builds and smoke tests ok, PATH stays 2,657, **exit 0** |
| `cl.exe` / `link.exe` after 20 imports | n/a | MSVC 14.51.36231 HostX64\x64 |

Fix report with logs: [reports/fix-report-issue-4.md](https://github.com/andersoxie/xpact/blob/3b8a20508fa35b2ef2c632f6764b71cdd339c9ca/reports/fix-report-issue-4.md)

Not tested: the other scripts that import the environment (e.g. `run_eiffel_test_matrix.ps1 -BuildMode Finalized`). Leaving this open until the fix reaches `main`. Revert with `.\student\tools\fix.ps1 revert -Issue 4 -Commit 3b8a205`.
