# A02 - Reproduce assertions-enabled workbench and finalized builds

Issue: [#33](https://github.com/andersoxie/xpact/issues/33)   Revision: `1799b3566f254d6e4eff7ce8dc5f6797e267c499` (`student-Mass`)   Date: 2026-10-22

The week 2 baseline ([`../../baseline/BASELINE.md`](../../baseline/BASELINE.md))
ran on 2026-10-14 in a folder without git. This is the same baseline rerun in
the git clone, so every result is tied to a commit. How to set up a PC for it:
[`../../report/setup-guide.md`](../../report/setup-guide.md).

## Configuration

From [`environment.log`](environment.log):

| | |
|---|---|
| OS | Windows 11 Home 10.0.26200, 64-bit |
| EiffelStudio | 25.12.9.8922 win64 |
| C backend | `ISE_C_COMPILER=msc_vc140` (user environment variable; week 2: empty = mingw) |
| Visual Studio / MSVC | Community 2026, toolset 14.51.36231 (`vswhere` reports 18.6.11819.183; week 2 recorded 18.10) |
| PowerShell | 5.1.26100.9711 |
| Python | 3.10.22 and 3.15.0 via uv (not on `PATH`; `python` is the Store alias, hence the error line in the log) |
| Assertions | pre/post/check/invariant **all on** for every target used: `xpact_tests_assertions`, `xpact_native_runtime`, `xpact_native_library_assertions`, `xpact_event_trace` |
| Uncommitted | 17 paths, all documentation under `student/` and untracked notes; `src/`, `tests/`, `scripts/` and `run_baseline.ps1` committed |
| Source fingerprint | `ed5bf0da...353ac3f3d` over 120 files ([`sources.sha256`](sources.sha256)) |

## Runs

Command, from the repository root:

```powershell
$env:Path = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer;$env:Path"
cmd /c "powershell -NoProfile -ExecutionPolicy Bypass -Command "". .\scripts\import_msvc_environment.ps1; .\student\baseline\run_baseline.ps1 -LogDir student\results\A02-baseline -Step environment,event-trace,matrix-workbench,matrix-finalized,matrix-finalized-keep,native-runtime-smoke,assertions-dll"" > student\results\A02-baseline\run-console.txt 2>&1"
```

MSVC is loaded first because the workbench lane does not load it itself
(setup guide, section 3). The `xmlconf` step was left out: its script is not
in git, and the W3C suite now runs with the Python runner (#29). In
[`results.tsv`](results.tsv) the `log` column says `logs\...`; the logs are in
this folder.

| # | Step | Command | Expected | Actual | Exit | Log |
|---|---|---|---|---|---|---|
| 1 | environment | tool versions and fingerprint | recorded | recorded | 0 | [environment.log](environment.log) |
| 2 | event-trace | `xpact_event_trace.exe` on 7 inputs | as week 2 | identical to week 2: 5 accepted, 3 rejected with position, `06-bad-utf8.xml` **accepted** (K4) | 0 | [event-trace.log](event-trace.log), [event-trace-output.txt](event-trace-output.txt) |
| 3 | matrix-workbench | `run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Workbench` | fails in the #28 test | `normalized_input @8` loop variant in `test_cr_line_ends_with_deferred_positions` | 1 | [matrix-workbench.log](matrix-workbench.log) |
| 4 | matrix-finalized | `run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Finalized` | "ok" without assertions (K2) | `xpact Eiffel test matrix: ok` | 0 | [matrix-finalized.log](matrix-finalized.log) |
| 5 | matrix-finalized-keep | `ec -finalize -keep ... xpact_tests_assertions`, `finish_freezing`, `xpact_tests.exe` | as 3 | as 3 | 1 | [matrix-finalized-keep.log](matrix-finalized-keep.log) |
| 6 | native-runtime-smoke | `run_native_runtime_smoke.ps1 -AssertionMode On` | ok | `xpact native runtime smoke: ok` | 0 | [native-runtime-smoke.log](native-runtime-smoke.log) |
| 7 | assertions-dll | `build_native_eiffel.ps1 -BuildTier Assertions` (smoke on) | DLL builds, smoke crashes (K3) | `Built ...xpact_assertions.dll`; smoke exit `-1073741784` = `0xC0000028` | 1 | [assertions-dll.log](assertions-dll.log) |

## Observations

- Every step gave the expected result, so the week 2 baseline reproduces in
  the git clone.
- Steps 3 and 5 now stop at the #28 regression test (added in `1ea242e`),
  which runs before `test_garbage_collection_suspension`. So B03 (K1) is not
  reached; it is still there (shown in `reports/issue-0028/`, check 6).
- K2 is unchanged: the finalized lane reports "ok" without checking contracts.
- K3 has the same crash code as on 2026-10-14 (`0xC0000028`).
- K4 is unchanged: invalid UTF-8 `C3 28` is accepted.
- New since week 2: with `ISE_C_COMPILER=msc_vc140`, the workbench lane needs
  MSVC loaded beforehand (`run_eiffel_test_matrix.ps1` lines 85-88 load it
  only for finalized lanes).

## Possible explanations

Not confirmed:
- The Visual Studio version differs from week 2 (18.6 vs 18.10) although the
  MSVC toolset is the same; `vswhere -latest` may pick another installed
  instance.
