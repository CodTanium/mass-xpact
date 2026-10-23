# XPact — Consolidated Error Report, Troubleshooting and Fix History

**Project:** XPact — XML parsing, by contract
**Period covered:** September–October 2026
**Platform:** Windows x64
**Environment:** EiffelStudio 25.12 Standard, PowerShell, Visual Studio C++ tools (VS 18 / MSVC 14.51), Python 3.10, Jenkins (Temurin OpenJDK 21.0.12.1)
**Suggested repository location:** `docs/troubleshooting/error-report.md`

> This document merges the earlier troubleshooting history, the build-fix notes and the student build report into one record. Where the documents disagreed, the most recent result wins: several issues listed as "unresolved" in the earlier history (notably the missing `.lnk` file) were fixed later and are marked as resolved here. Error counts, paths and outcomes should be revalidated against the latest repository state before being used as release or conformance claims.

---

## 1. Project Overview

XPact is an Eiffel-based XML parser that aims to provide a libexpat-compatible API through a native C interface. The project separates the public C API, the native bridge and the Eiffel parsing implementation:

| Path | Role |
|---|---|
| `include/xpact.h` | Public C API header |
| `native/xpact_native.c` | C ABI and native bridge |
| `src/xp_native_parser.e` | Eiffel-side native integration |
| `src/xp_parser.e` | Core XML parsing implementation |
| `src/XP_CLI` | Command-line parsing application |
| `tests/` | Automated tests and test infrastructure |
| `scripts/` | Build, testing and diagnostic automation |
| `EIFGENs/` | Generated Eiffel build artifacts (should not be committed) |

The principal objective is correct XML parsing behaviour and compatibility before performance work.

Two distinctions run through this whole report. First, successfully compiling the native C bridge does not prove that the Eiffel parser is installed or working through the DLL. Second, a passing test harness does not prove that XPact passes the XML conformance suite.

---

## 2. Status Summary

| # | Issue | Area | Status |
|---|---|---|---|
| 3.1 | Wrong Eiffel runtime include directory | Build environment | **Resolved** in `build_native_eiffel.ps1`; verify `run_native_runtime_smoke.ps1` |
| 3.2 | PowerShell execution policy | Build environment | Workaround |
| 3.3 | `cl.exe` not available | Build environment | **Resolved** (vcvars64 loaded by script) |
| 4.1 | Missing Eiffel link response file (`.lnk`) | Native build | **Resolved** |
| 4.2 | Incompatible precompiled base | Native build | **Resolved** |
| 4.3 | Stale `ec.lock` file | Native build | **Resolved** |
| 4.4 | `vswhere.exe` stderr aborting scripts | Native build | **Resolved** |
| 4.5 | `finish_freezing` / W_code vs F_code | Native build | Clarified; build now completes |
| 4.6 | Bridge-only DLL: "Eiffel parser bridge is not installed" | Native integration | Likely superseded by Eiffel-backed DLL; re-run C# test |
| 4.7 | `cmd.exe: The input line is too long` | Native build | Not reproduced since fixes; unverified |
| 4.8 | Assertions-tier DLL smoke crash (`0xC0000008`) | Native runtime | **Open** |
| 5.1 | `XP_NATIVE_PARSER` postcondition violation | Eiffel contracts | **Open** |
| 5.2 | Eiffel AutoTest | Tests | Passing run recorded |
| 6.1 | Invalid UTF-8 accepted | Conformance | **Open** |
| 6.2 | Duplicate ATTLIST enumeration accepted | Conformance | **Open** |
| 6.3 | XMLconf: 852 of 2,163 failing | Conformance | **Open** (baseline recorded) |
| 6.4 | Callback behaviour for rejected documents | Conformance | **Open** |
| 7.1 | Python vs PowerShell runner discrepancy | Reporting | **Open** |
| 7.2 | Python CSV `writerows` test failure | Reporting | **Open** |
| 8.1 | Large-file parsing performance | Performance | Investigation ongoing |
| 8.2 | Metrics REAL_64/REAL_32 type errors | Performance | Change reverted |
| 9.1 | Jenkins precompile prompt / unattended builds | CI | **Open** |

---

## 3. Build Environment and Configuration

### 3.1 Incorrect Eiffel runtime include directory

**Scripts:** `scripts\build_native_eiffel.ps1`, `scripts\run_native_runtime_smoke.ps1`

**Observed error**

```
PS C:\Users\masou\Desktop\xpact-student-test> .\scripts\build_native_eiffel.ps1 -BuildTier Assertions
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
Cannot find Eiffel runtime include directory.
At C:\Users\masou\Desktop\xpact-student-test\scripts\build_native_eiffel.ps1:46 char:2
+ throw "Cannot find Eiffel runtime include directory."
```

**Cause**

The script used a fallback path that does not exist on this machine:

```powershell
$Fallback = "C:\El2502E\studio\spec\win64\include"
```

The actual installation is:

```
C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard
```

with the compiler at `...\studio\spec\win64\bin\ec.exe`.

**Fix**

```powershell
$Fallback = "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard\studio\spec\win64\include"
```

**Verification:** The build moved past the include-directory error and reached the C compilation stage (where it then hit issue 4.1).

**Remaining work:** `run_native_runtime_smoke.ps1` reported the same class of error and should get the same correction. A more robust long-term fix is to derive the path from `ISE_EIFFEL` (or from the location of `ec.exe`) instead of hard-coding a fallback.

### 3.2 PowerShell execution policy

PowerShell's execution policy prevented scripts from running. Workaround:

```powershell
Set-ExecutionPolicy Bypass -Scope Process
```

This affects only the current PowerShell process and does not change the machine-wide policy. It does not fix errors inside the scripts.

### 3.3 Visual Studio C++ compiler not available

`cl.exe` was not initially available in PowerShell. The x64 developer environment script is:

```
C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
```

The build script now loads it automatically (see the "Loaded Visual Studio C++ x64 environment" line in 3.1), via `scripts\import_msvc_environment.ps1`. A successful C compilation does not on its own confirm that the Eiffel-backed build works.

---

## 4. Native DLL Build and Eiffel Runtime Integration

### 4.1 Missing Eiffel link response file — RESOLVED

**Script:** `scripts\build_native_eiffel.ps1`

**Observed error**

```
C compilation completed
Expected Eiffel link response file not found:
C:\Users\masou\Desktop\xpact-student-test\EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk
At C:\Users\masou\Desktop\xpact-student-test\scripts\build_native_eiffel.ps1:91 char:2
+ throw "Expected Eiffel link response file not found: $Expected"
```

**How it was diagnosed**

```powershell
$Expected = ".\EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk"
Test-Path $Expected        # -> False

Get-ChildItem .\EIFGENs -Recurse -File -Filter *.lnk -ErrorAction SilentlyContinue |
    Select-Object FullName, Length   # -> no results
```

No `.lnk` files existed anywhere under `EIFGENs`. An earlier note recorded that on one rerun `finish_freezing` was present in the folder and the build ran, which pointed toward a configuration problem rather than a missing step.

**Root cause**

The script assumed the Eiffel target was compiled with an MSVC backend, which emits a `.lnk` response file in `F_code`. The machine's default Eiffel "spec" is **mingw** (gcc):

- The mingw backend links with `dllwrap`/`gcc`, produces no `.lnk` file, and builds a gcc `.exe` instead.
- The plain `msc` spec's runtime library was incompatible with the installed Visual Studio (linker error 0x460: unresolved `__iob_func`, `_set_output_format`, etc.).
- Only the **`msc_vc140`** spec produces a usable `.lnk` and links against a runtime compatible with MSVC 14.51 / VS 18.

**Fix** (in `scripts\build_native_eiffel.ps1`)

Force the backend around the compile and finalize steps, then restore the previous value:

```powershell
$OldCompiler = $env:ISE_C_COMPILER
$env:ISE_C_COMPILER = "msc_vc140"
try {
    ec -batch -clean -finalize -keep -config tests\xpact_native_library.ecf -target $EiffelTarget
    ...
    Push-Location $FinalCode
    try { finish_freezing } finally { Pop-Location }
    ...
} finally {
    $env:ISE_C_COMPILER = $OldCompiler
}
```

The script also checks the exit codes of `ec` and `finish_freezing` explicitly. Switching backends required the related fixes in 4.2–4.4.

**Verification**

```
.\scripts\build_native_eiffel.ps1
  -> Built build\native-eiffel\xpact.dll (Production)
  -> xpact Eiffel DLL smoke: ok
  -> EXIT=0
```

### 4.2 Incompatible precompiled base — RESOLVED

**File:** `tests\xpact_native_library.ecf`

When building with the MSVC spec, Eiffel reported that the precompiled file was missing or unreadable. Both targets declared a `<precompile>` base (`base-safe`) that exists only for the mingw spec. The Eiffel install on this machine has no usable MSVC precompiled base.

**Fix:** removed the following element from **both** targets, `xpact_native_library` and `xpact_native_library_assertions`:

```xml
<precompile name="base_pre" .../>
```

The `msc_vc140` spec is now used without a precompiled base. This makes full compiles slower but works.

**Note:** A prior failed attempt left a broken precompiled base named `base-safe.broken-20261013` in
`%USERPROFILE%\Documents\Eiffel User Files\25.12\precomp\spec\win64\EIFGENs\`. It is unrelated to the fix but explains the state of the install, and may be related to the Jenkins precompile prompt in 9.1.

### 4.3 Stale `ec.lock` file — RESOLVED

**Error:** `Cannot create project directory ... fixing the permissions`

**Cause:** A leftover `EIFGENs\xpact_native_library\ec.lock` from an interrupted run.

**Fix:** after confirming no `ec` process was running:

```powershell
Remove-Item ".\EIFGENs\xpact_native_library\ec.lock"
```

**Suggestion:** have the build script detect a stale lock and print a clear message instead of failing with a misleading permissions error.

### 4.4 `vswhere.exe` stderr warning aborting scripts — RESOLVED

**Scripts:** `scripts\build_native_eiffel.ps1`, `scripts\import_msvc_environment.ps1`

With `$ErrorActionPreference = "Stop"`, the harmless `'vswhere.exe' is not recognized` message written to stderr was promoted to a terminating error.

**Fix:** native calls (`ec`, `finish_freezing`, the smoke `.exe`, the `vcvars64.bat` invocation and the `cl`/`link` calls inside `Invoke-VcCommand`) now temporarily set `$ErrorActionPreference = "Continue"` and check `$LASTEXITCODE` explicitly.

### 4.5 `finish_freezing` and W_code vs F_code

After recompilation, EiffelStudio instructed the developer to run `finish_freezing`. This means the Eiffel-to-C stage had completed but native C compilation and linking remained.

- `W_code` — Workbench build output.
- `F_code` — Finalized build output.

The two are not interchangeable. `finish_freezing` completes the native stage for whichever target and mode was generated; it does not replace the initial Eiffel compilation. With the fixes in 4.1–4.4 the script now runs it from `F_code` successfully.

### 4.6 Bridge-only DLL: "Eiffel parser bridge is not installed"

**Script:** `scripts\build_native.ps1`

`build_native.ps1` produced `build\native\xpact.dll` (about 116,736 bytes) plus `xpact.lib` and `xpact.exp`. A C# P/Invoke smoke test calling `XML_Parse` received error code **44** (`XML_ERROR_NOT_STARTED`) with the message:

```
Eiffel parser bridge is not installed
```

The DLL contained only the C bridge; the Eiffel parser had not been linked in.

**Current status:** `build_native_eiffel.ps1` now produces an Eiffel-backed DLL at `build\native-eiffel\xpact.dll` whose smoke test passes. This very likely supersedes the problem, but the **C# P/Invoke test should be re-run against `build\native-eiffel\xpact.dll`** to confirm. Make sure consumers do not accidentally pick up the bridge-only DLL from `build\native\`.

### 4.7 Windows command-line length error

```
cmd.exe : The input line is too long
```

Seen around line 71 of `build_native_eiffel.ps1` while investigating the assertions-enabled build. It has not been reported since the 4.1–4.4 fixes, and the assertions tier now builds, but the root cause was never confirmed.

**If it returns:** inspect the exact command passed to `cmd.exe`, especially compiler arguments and environment variables. Repeatedly calling `vcvars64.bat` in one session can grow `PATH` past the limit, so try a fresh PowerShell window first. A response-file approach helps if the length comes from compiler arguments.

### 4.8 Assertions-tier DLL smoke crash — OPEN

The assertions-tier build succeeds:

```
.\scripts\build_native_eiffel.ps1 -BuildTier Assertions -SkipSmoke   # EXIT=0
```

However, running its smoke test (without `-SkipSmoke`) crashes at process attach with **`STATUS_INVALID_HANDLE (0xC0000008)`**. This is a pre-existing assertion-runtime / loader-lock issue, separate from the build fixes. CI and `package_windows_release.ps1` always pass `-SkipSmoke` for the assertion tier, so this crash is currently hidden from automated checks.

---

## 5. Eiffel Compilation and Automated Tests

### 5.1 Parser postcondition violation — OPEN

**Script:** `scripts\run_eiffel_test_matrix.ps1`

```
XP_NATIVE_PARSER parse @10 final_finished_or_suspended: Postcondition violated
```

The parser did not satisfy the postcondition on its final state. This matters because XPact relies on Eiffel contracts to express correctness.

Matrix options:

```
-AssertionMode All | Off | On
-BuildMode All | Workbench | Finalized
```

**Next step:** preserve the exact input and parser state that trigger the violation. It may be related to the assertions-tier crash in 4.8.

### 5.2 Eiffel AutoTest — passing run recorded

After `finish_freezing`:

```powershell
.\EIFGENs\xpact_autotest\W_code\xpact_autotest.exe
# xpact AutoTest generated tests: ok
```

This confirms the generated AutoTest suite ran in that instance. It does not establish native DLL correctness or XML conformance.

---

## 6. XML Parsing Correctness and Conformance

### 6.1 Invalid UTF-8 accepted — OPEN

`bad-utf8.xml` contains the byte sequence `C3 28`, which is not valid UTF-8.

```powershell
.\EIFGENs\xpact\W_code\xpact.exe --parse-file .\bad-utf8.xml
# xpact parse: ok
```

**Expected:** reject. A regression test should verify that the parser rejects the input, reports an appropriate error, does not fire document-completion callbacks, and behaves the same with assertions on and off.

### 6.2 Duplicate ATTLIST enumeration accepted — OPEN

XMLconf test **rmt-e2e-2a** (`E2a.xml`) contains a duplicate token in an ATTLIST enumeration, equivalent to `(one|one)`.

- Expected: reject (classified *invalid*).
- Observed: `xpact parse: ok`.

**Next step:** trace ATTLIST parsing and enumeration validation in `src/xp_parser.e` and add a regression test. Note that duplicate enumeration tokens are a validity constraint, so the fix depends on whether XPact is meant to act as a validating parser (see 7.1 on verdict rules).

### 6.3 XMLconf conformance results — OPEN

| Metric | Count |
|---|---|
| Total tests | 2,163 |
| Passed | 1,311 |
| Failed | 852 |
| Missing | 0 |

| Expected classification | Count |
|---|---|
| Valid | 494 |
| Invalid | 215 |
| Not well-formed | 1,425 |
| Error | 29 |

Verdict rules used by the runner:

- `valid` and `error` → accept
- `invalid` and `not-wf` → reject

The 852 failures are a backlog of mismatches, not necessarily 852 independent defects. **Next step:** group failures by category and parser behaviour before investigating individual cases. In particular, check how many failures are *invalid* cases, since a non-validating parser is expected to accept those.

### 6.4 Callback behaviour for rejected documents — OPEN

For malformed or invalid XML, tests should check that the parser does not report successful completion or deliver callbacks that should not occur: start-element, end-element, character-data, document-completion and chunk-related callbacks. The intended matrix covers valid XML, incomplete XML, mismatched tags and invalid UTF-8. A complete set of passing results has not yet been established.

---

## 7. Python and PowerShell Conformance Reporting

### 7.1 Python and PowerShell runners disagree — OPEN

**Related project:** `xpact-codex-w3c-xml-conformance-benchmarks`
**Files:** `scripts/run_w3c_conformance.py`, `tests/python/test_w3c_conformance.py`

The Python benchmark appeared to show passing tests, while the PowerShell XMLconf runner reported 852 failures. The Python project pins a specific W3C XML Test Suite version by SHA-256.

A passing Python harness test does not mean XPact passed the XML suite: harness tests can validate orchestration, verdict logic and reporting without exercising every parser case.

**Compare both runners on:**

1. The same XML test suite and catalog.
2. The same XPact executable and build configuration.
3. The same expected-verdict rules.
4. Handling of errors, skips and unsupported cases.
5. Whether summaries count harness tests or actual parser tests.

### 7.2 Python CSV report-generation failure — OPEN

```
python test_w3c_conformance.py
```

Failing test: `test_junit_and_summary_reconcile_failure_error_skip_and_verdict_counts`. The traceback points to `write_reports`, at the `csv.writerows` call.

The tests were changed to write to a persistent `test-output/reports` directory for easier inspection. This is an investigation aid, not a fix. Make sure that directory is isolated from source fixtures and that tests do not depend on stale reports.

**Next step:** inspect the data passed to `writerows` (common causes are rows that are dicts passed to a plain `csv.writer`, or keys not matching `fieldnames` in a `DictWriter`), then verify that JUnit, CSV and summary totals agree for pass, failure, error, skip and verdict categories.

---

## 8. Performance and Metrics

### 8.1 Large-file parsing performance — ongoing

| Input | Size | Approx. time |
|---|---|---|
| `asd.xml` (large test input) | 1,048,568 bytes | 3.4–3.5 s |
| `test.xml` | 53 bytes | 6 ms |

These are development observations, not controlled benchmarks, and were taken on Workbench builds. A `--no-positions` option was discussed as an experiment but not confirmed as implemented. Repeat the measurements on a Finalized build before drawing conclusions.

### 8.2 Metrics event handler type errors — reverted

An attempted callbacks-per-second calculation in `XP_METRICS_EVENT_HANDLER` caused `REAL_64` / `REAL_32` type errors and was reverted. A later `test.xml` run with `--metrics` reported: 5 elements, 5 end elements, 9 character-data events, 53 bytes, 1 XML declaration.

---

## 9. Jenkins and Continuous Integration

### 9.1 Precompile prompt and unattended builds — OPEN

Jenkins runs on Windows (Temurin OpenJDK 21.0.12.1), initially under the **SYSTEM** account, with its workspace at `C:\ProgramData\Jenkins\.jenkins\workspace`. Repeated builds hit a prompt involving EiffelStudio's `base-safe.ecf` precompile. Job #4 completed successfully, but the prompt remained.

One troubleshooting note recorded a Jenkins setup error as unrelated to XPact; the precompile prompt, however, is directly relevant. The SYSTEM account has a different user profile, so it does not see the precompiled bases under `%USERPROFILE%\Documents\Eiffel User Files\`. Removing `<precompile>` from `xpact_native_library.ecf` (4.2) may already avoid the prompt for that target; other ECFs that still declare a precompile should be checked.

**Next step:** give the Jenkins service a consistent EiffelStudio install, environment (`ISE_EIFFEL`, `ISE_C_COMPILER=msc_vc140`) and account profile, so builds never need interactive input.

---

## 10. Verified Build Commands

| Command | Purpose | Result |
|---|---|---|
| `.\scripts\build_native_eiffel.ps1` | Production Eiffel-backed DLL | `build\native-eiffel\xpact.dll`, smoke ok, EXIT=0 |
| `.\scripts\build_native_eiffel.ps1 -BuildTier Assertions -SkipSmoke` | Assertions-tier DLL | `build\native-eiffel\xpact_assertions.dll`, EXIT=0 |
| `.\scripts\package_windows_release.ps1` | Build and package release | `dist\xpact-0.1.0-preview-windows-x64.zip`, EXIT=0 |

---

## 11. Scripts and Tools Inventory

| Script or tool | Purpose | Related issues |
|---|---|---|
| `scripts\build_native.ps1` | Build bridge-only C DLL | 4.6 |
| `scripts\build_native_eiffel.ps1` | Build Eiffel-backed DLL | 3.1, 4.1–4.5, 4.7, 4.8 |
| `scripts\import_msvc_environment.ps1` | Load VS x64 environment | 3.3, 4.4 |
| `scripts\package_windows_release.ps1` | Build and package Windows release | 4.8 (`-SkipSmoke`) |
| `scripts\run_native_runtime_smoke.ps1` | Native runtime smoke test | 3.1 (path still to verify) |
| `scripts\run_eiffel_test_matrix.ps1` | Assertion/build-mode test matrix | 5.1 |
| `scripts/run_w3c_conformance.py` | Python W3C conformance runner | 7.1 |
| `tests/python/test_w3c_conformance.py` | Python harness tests | 7.2 |
| XMLconf PowerShell runner | XMLconf suite against the CLI | 6.3, 7.1 (confirm filename in repo) |
| `tests\xpact_native_library.ecf` | Eiffel native library config | 4.2 |
| `EIFGENs\xpact_autotest\W_code\xpact_autotest.exe` | Eiffel AutoTest suite | 5.2 |
| `xpact.exe --parse-file PATH [--metrics]` | CLI parse / metrics | 6.1, 6.2, 8.1, 8.2 |
| C# P/Invoke smoke test | Public C API from C# | 4.6 |
| `finish_freezing` | Native compile/link stage | 4.5 |

---

## 12. Outstanding Work, in Suggested Order

1. Apply the include-path fix to `run_native_runtime_smoke.ps1` (or derive the path from `ISE_EIFFEL` in all scripts).
2. Re-run the C# P/Invoke test against `build\native-eiffel\xpact.dll`.
3. Investigate the assertions-tier crash (4.8) together with the postcondition violation (5.1).
4. Fix invalid UTF-8 acceptance (6.1).
5. Decide validating vs non-validating behaviour, then fix or reclassify the ATTLIST case (6.2).
6. Group the 852 XMLconf failures by category (6.3).
7. Fix the CSV `writerows` failure, then reconcile the Python and PowerShell runners (7.1, 7.2).
8. Make Jenkins builds unattended (9.1).
9. Revisit performance on Finalized builds (8.1).
10. Watch for a recurrence of the command-line length error (4.7).

---

## 13. Regression Test Plan

| Test | Input or scenario | Expected |
|---|---|---|
| Valid XML | `<root/>` | Accept |
| Incomplete XML | `<root>` | Reject |
| Mismatched tags | `<root><child></root>` | Reject |
| Invalid UTF-8 | Bytes `C3 28` in a UTF-8 document | Reject |
| Duplicate enumeration | ATTLIST `(one|one)` | Reject (if validating) |
| Eiffel contracts | Test matrix with assertions on | No unexpected contract violations |
| Native integration | Call the public C API on the Eiffel-backed DLL | Parser installed and working |
| Assertions DLL | Assertions-tier smoke without `-SkipSmoke` | No crash at process attach |
| Conformance reporting | Python vs PowerShell on the same suite and executable | Same verdicts and totals |
| CI reproducibility | Jenkins build | Completes unattended |

Tests should check more than the exit code: where applicable, also verify the error state and callback behaviour. Each discovered defect should have a minimal input file, an expected result, an actual result, the build configuration used, and a regression test.

---

## 14. Conclusion

The native build is now working: the production Eiffel-backed DLL builds and passes its smoke test, the assertions-tier DLL builds, and the Windows release packages successfully. The key fixes were correcting the Eiffel include path, forcing the `msc_vc140` backend, removing the mingw-only precompiled base, removing a stale lock file, and stopping harmless stderr output from aborting the scripts.

What remains is mostly correctness rather than build plumbing: the assertions-tier runtime crash, the parser postcondition violation, invalid UTF-8 and DTD acceptance, the XMLconf failure backlog, the reporting discrepancy, and unattended CI. These should stay visible as open issues until each is reproduced, fixed and verified with a regression test.
