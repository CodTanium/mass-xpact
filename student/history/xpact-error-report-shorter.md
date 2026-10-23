# XPact: Windows Build, Errors & How to Reproduce Them (README3)
**Environment:** Windows 11 x64 · EiffelStudio 25.12 Standard
(`C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard`) · VS 18
Community (MSVC 14.5x) · PowerShell 5.1 · Python 3.10 · Jenkins (OpenJDK 21).

## 1. The one idea behind most build errors

The native scripts compile C with **Microsoft `cl`**, but Eiffel's default C
backend on this machine is **mingw (gcc)**. Mixing the two breaks the build.

| `ISE_C_COMPILER` | Backend | Result |
|---|---|---|
| empty (default) | mingw / gcc | ❌ can't link MSVC `.obj` files, and writes no `.lnk` |
| `msc` | old MSVC runtime | ❌ unresolved `__iob_func`, `_set_output_format` |
| `msc_vc140` | MSVC (current) | ✅ **use this** |

The only precompiled Eiffel base (`base-safe`) on this machine was built for
mingw. That means any ECF built with `msc_vc140` must **not** contain
`<precompile>`. The first build is slower because Base gets compiled from
source.

The scripts set `msc_vc140` only for the length of their own run. To check the
current value: `echo $env:ISE_C_COMPILER` (empty means mingw).

## 2. Everyday commands (run from the repo root)

```powershell
Set-ExecutionPolicy Bypass -Scope Process   # if scripts are blocked
.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode All -BuildMode All
.\scripts\run_native_runtime_smoke.ps1 [-AssertionMode On|Off]    # C ABI -> Eiffel parser
.\scripts\build_native_eiffel.ps1                                 # build\native-eiffel\xpact.dll + smoke
.\scripts\build_native_eiffel.ps1 -BuildTier Assertions -SkipSmoke
.\scripts\package_windows_release.ps1    # dist\xpact-0.1.0-preview-windows-x64.zip
```

All of these were verified with EXIT=0 on 2026-10-14. Both smoke runs print
`xpact native runtime smoke: ok`, and the DLL smoke prints
`xpact Eiffel DLL smoke: ok`.

## 3. Status at a glance

| # | Issue | Status |
|---|---|---|
| 4.1 | Smoke script: `undefined reference to __security_check_cookie` | ✅ Fixed |
| 4.2 | `Expected Eiffel link response file not found (.lnk)` | ✅ Fixed |
| 4.3 | `precompiled file is missing or unreadable` | ✅ Fixed |
| 4.4 | `msc` spec: unresolved `__iob_func` | ✅ Avoided (use `msc_vc140`) |
| 4.5 | Stale `ec.lock` → `Cannot create project directory` | ✅ Fixed |
| 4.6 | `'vswhere.exe' is not recognized` aborts the script | ✅ Fixed |
| 4.7 | `Cannot find Eiffel runtime include directory` | ✅ Fixed |
| 4.8 | `cl.exe` not found / execution policy | ✅ Fixed / workaround |
| 5.1 | Assertions-tier DLL crash `0xC0000008` | ❌ Open |
| 5.2 | `The input line is too long` | ⚠️ Workaround only |
| 5.3 | `XP_NATIVE_PARSER` postcondition violated | ❌ Open |
| 5.4 | Bridge-only DLL: "Eiffel parser bridge is not installed" | ⚠️ Probably superseded |
| 6.x | XML conformance (bad UTF-8, ATTLIST, 852 XMLconf failures) | ❌ Open |
| 7.x | Python reporting and Jenkins | ❌ Open |

> **About the reproduction steps:** each one deliberately brings back a broken
> state. Afterwards, rerun the normal script (the fixed scripts use `-clean`)
> and delete any leftover `EIFGENs\<target>\ec.lock`. Steps marked
> *(untested)* follow from the root cause but weren't rerun for this file.


## 4. Fixed build errors
### 4.1 `run_native_runtime_smoke.ps1`: undefined `__security_check_cookie`
Warning: .drectve `/DEFAULTLIB:"LIBCMT" /DEFAULTLIB:"OLDNAMES" ' unrecognized
xpact_native.obj:(.text$mn+0x2fc2): undefined reference to `__security_check_cookie'
xpact_native.obj:(.xdata+0x1e8): undefined reference to `__GSHandlerCheck'
collect2: ld returned 1 exit status
finish_freezing failed for native runtime target assertions-on.

**Cause.** The build has two halves:
1. `cl` compiles `native\*.c` into `build\native-runtime\*.obj`. `cl`'s
   default `/GS` stack protection adds calls to `__security_check_cookie` and
   `__GSHandlerCheck`, plus `/DEFAULTLIB:LIBCMT` directives.
2. `ec` generates C in `EIFGENs\<target>\W_code`. Then `finish_freezing`
   compiles that C and **links** it together with those `.obj` files.

With the default mingw backend, gcc's `ld` does the linking. It doesn't
understand the MSVC directives and doesn't link the MSVC C runtime, so those
two functions are missing.

**Fix.**
- `scripts\run_native_runtime_smoke.ps1`:
  - sets `ISE_C_COMPILER=msc_vc140` around `ec`, `finish_freezing` and the
    smoke exe, and restores the old value in a `finally` block;
  - adds an `Invoke-NativeCommand` helper so that stderr text can't abort the
    script, and checks `$LASTEXITCODE` instead (see 4.6).
- `tests\xpact_native_runtime.ecf`: removed `<precompile>` from both targets.
- Deleted the stale `EIFGENs\xpact_native_runtime\ec.lock`.

**Reproduce** (fresh PowerShell window, repo root, scripts unchanged). The
MSVC `.obj` files are already in `build\native-runtime`, so you only have to
run half 2 with mingw:

```powershell
$env:ISE_C_COMPILER = $null
ec -batch -clean -config tests\xpact_native_runtime.ecf -target xpact_native_runtime
cd EIFGENs\xpact_native_runtime\W_code; finish_freezing; cd ..\..\..
```

**Verify.** Running `.\scripts\run_native_runtime_smoke.ps1` prints
`ok` twice and exits 0. `W_code\xpact_native_runtime.lnk` exists, which means
MSVC `link` was used.

### 4.2 Missing link response file `xpact_native_library.lnk`

Expected Eiffel link response file not found:
...\EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk


**Cause.** `build_native_eiffel.ps1` re-links the Eiffel output as a DLL using
the `.lnk` file. Only an MSVC backend writes that file; mingw doesn't.

**Fix.** `build_native_eiffel.ps1` forces `msc_vc140` around `ec -finalize`
and `finish_freezing`.

**Reproduce:**
```powershell
$env:ISE_C_COMPILER = $null
ec -batch -clean -finalize -keep -config tests\xpact_native_library.ecf -target xpact_native_library
cd EIFGENs\xpact_native_library\F_code; finish_freezing; cd ..\..\..
Get-ChildItem EIFGENs -Recurse -Filter *.lnk      # nothing for this target
```

### 4.3 `precompiled file is missing or unreadable`

**Cause.** The ECF declared the mingw-only `base-safe` precompile while being
built with `msc_vc140`.

**Fix.** Removed `<precompile name="base_pre" .../>` from both targets in
`tests\xpact_native_library.ecf` and in `tests\xpact_native_runtime.ecf`.

**Reproduce** *(untested)*: put this line back into one target and run the
matching script:
`<precompile name="base_pre" location="$ISE_PRECOMP\base-safe.ecf"/>`

Note: a broken precompile named `base-safe.broken-20261013` remains in
`%USERPROFILE%\Documents\Eiffel User Files\25.12\precomp\spec\win64\EIFGENs\`.
It's harmless but explains the state of the install.

### 4.4 `msc` spec: unresolved `__iob_func`, `_set_output_format` (linker 0x460)

**Cause.** `msc` targets an old MSVC C runtime. **Fix:** use `msc_vc140`.
**Reproduce** *(untested)*: run the commands from 4.2 with
`$env:ISE_C_COMPILER = "msc"`.

### 4.5 Stale `ec.lock`: `Cannot create project directory ... fixing the permissions`

**Cause.** An interrupted `ec` run leaves `EIFGENs\<target>\ec.lock` behind.
**Fix:** confirm that no `ec.exe` is building *this* project, then delete the
lock:

```powershell
Get-CimInstance Win32_Process -Filter "Name='ec.exe'" | Select ProcessId, CommandLine
Remove-Item .\EIFGENs\<target>\ec.lock
```

An EiffelStudio GUI open on a *different* copy of the repo doesn't hold this
lock. **Reproduce:** press Ctrl+C during `ec`, then run it again.

### 4.6 `'vswhere.exe' is not recognized` stops the script

**Cause.** `vcvars64.bat` (and `ec`'s banner) write to stderr. Under
`$ErrorActionPreference = "Stop"`, PowerShell turns that text into a fatal
error whenever output is redirected, for example in CI or with `*> log.txt`.

**Fix.** Native calls in `build_native_eiffel.ps1`,
`import_msvc_environment.ps1` and `run_native_runtime_smoke.ps1` now run
under `Continue` and check `$LASTEXITCODE`.

**Reproduce:** run the original (pre-fix) smoke script with
`*> log.txt`. It stops inside `Compile-CObject`.

### 4.7 `Cannot find Eiffel runtime include directory`

**Cause.** The fallback path was `C:\El2502E\studio\spec\win64\include`.
**Fix.** The fallback in both scripts is now
`C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard\studio\spec\win64\include`,
and `ISE_EIFFEL` overrides it. **Reproduce:** with `ISE_EIFFEL` unset, change
the fallback back to the old path.

### 4.8 `cl.exe` not found / scripts blocked

The scripts load `vcvars64.bat` through `import_msvc_environment.ps1`. If
PowerShell blocks scripts, run `Set-ExecutionPolicy Bypass -Scope Process`.
That affects only the current window.

---

## 5. Open native and runtime issues

### 5.1 Assertions-tier DLL crashes at load: `STATUS_INVALID_HANDLE (0xC0000008)`

The assertions-tier DLL builds, but its smoke test crashes at process attach.
This is likely a loader-lock problem in the assertion runtime. CI and packaging
hide it with `-SkipSmoke`.
**Reproduce:** `.\scripts\build_native_eiffel.ps1 -BuildTier Assertions`

### 5.2 `cmd.exe: The input line is too long`

This came from `run_phase1.ps1`, and earlier from `build_native_eiffel.ps1`.
Each `vcvars64.bat` import adds to `PATH` until it passes cmd.exe's
8,191-character limit. **Workaround:** use a fresh PowerShell window.
**Reproduce** *(untested)*: run several build scripts one after another in the
same window, then run `.\scripts\run_phase1.ps1`.

### 5.3 `XP_NATIVE_PARSER parse @10 final_finished_or_suspended: Postcondition violated`

**Reproduce:**
`.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode All`.
Save the input that triggers it. This may be linked to 5.1.

### 5.4 "Eiffel parser bridge is not installed" (error 44, `XML_ERROR_NOT_STARTED`)

`scripts\build_native.ps1` builds a **bridge-only** `build\native\xpact.dll`
(about 117 KB) with no Eiffel parser inside. A C# P/Invoke call to `XML_Parse`
on it fails. **Next step:** rerun the C# test against
`build\native-eiffel\xpact.dll`, and make sure consumers don't pick up the
bridge-only DLL.

---

## 6. Open XML correctness and conformance issues

| Issue | Reproduce | Expected | Actual |
|---|---|---|---|
| Invalid UTF-8 accepted | see below | reject | `xpact parse: ok` |
| Duplicate ATTLIST token `(one\|one)`, XMLconf `rmt-e2e-2a` (`E2a.xml`) | `xpact.exe --parse-file E2a.xml` | reject (if validating) | ok |
| Callbacks fired on rejected documents | parse `<root>` or `<root><child></root>` with callbacks | no start/end/char/complete callbacks | not fully verified |

```powershell
[IO.File]::WriteAllBytes("$PWD\bad-utf8.xml", [byte[]](0x3C,0x72,0x3E,0xC3,0x28,0x3C,0x2F,0x72,0x3E))  # <r>\xC3(</r>
.\EIFGENs\xpact\W_code\xpact.exe --parse-file .\bad-utf8.xml
```

**XMLconf baseline:** 2,163 tests, 1,311 passed, **852 failed**, 0 missing
(494 valid, 215 invalid, 1,425 not-well-formed, 29 error). Verdict rules:
valid and error mean accept; invalid and not-wf mean reject. A non-validating
parser is *expected* to accept "invalid" documents, so group the failures by
category before fixing individual cases.

---

## 7. Open reporting, performance and CI issues

- **Python vs PowerShell runners disagree.** In the
  `xpact-codex-w3c-xml-conformance-benchmarks` project, the Python harness
  passes while XMLconf shows 852 failures. Harness tests check orchestration,
  not parser verdicts. Compare both runners on the same suite, executable,
  verdict rules and skip handling.
- **Python CSV failure:** `python test_w3c_conformance.py` fails in
  `test_junit_and_summary_reconcile_failure_error_skip_and_verdict_counts`
  at `csv.writerows`. Likely causes are dict rows passed to a plain
  `csv.writer`, or keys that don't match `fieldnames`.
- **Performance:** a 1 MB `asd.xml` takes about 3.4 s and a 53-byte file
  about 6 ms. These are Workbench numbers; measure again on a Finalized build.
  A `REAL_64`/`REAL_32` change to the metrics handler was reverted.
- **Jenkins:** the job runs as SYSTEM, which doesn't see the user's
  precompiled bases, so the `base-safe.ecf` precompile prompt blocks
  unattended builds. Give the service account `ISE_EIFFEL`,
  `ISE_C_COMPILER=msc_vc140`, and ECFs without `<precompile>`.

---

## 8. Files changed by the fixes

| File | Change |
|---|---|
| `scripts\build_native_eiffel.ps1` | `msc_vc140`, stderr guards, include path |
| `scripts\run_native_runtime_smoke.ps1` | `msc_vc140`, `Invoke-NativeCommand` |
| `scripts\import_msvc_environment.ps1` | stderr guard around `vcvars64.bat` |
| `tests\xpact_native_library.ecf` | `<precompile>` removed (both targets) |
| `tests\xpact_native_runtime.ecf` | `<precompile>` removed (both targets) |

These ECFs still use the mingw precompile, which is fine while they're built
with mingw and link no MSVC objects: `xpact.ecf`, `tests\xpact_tests.ecf`,
`tests\xpact_autotest.ecf`, `benchmarks\xpact_benchmarks.ecf`.

---

## 9. Suggested next steps

1. Fix the assertions-tier crash (5.1) together with the postcondition
   violation (5.3).
2. Reject invalid UTF-8 and add a regression test for it.
3. Decide whether XPact should validate or not. Then fix or reclassify the
   ATTLIST case and group the 852 XMLconf failures.
4. Fix the CSV test, then reconcile the Python and PowerShell runners.
5. Rerun the C# P/Invoke test against the Eiffel-backed DLL.
6. Make Jenkins builds unattended.
7. Measure performance again on Finalized builds.

For every defect, keep a minimal input, the expected and actual results, the
build configuration, and a regression test. Check error codes and callbacks,
not just the exit code.
