# Work before this repository (weeks 1–2)

This work was done in `Desktop\xpact-student-test`, a checkout without git, from
September to 2026-10-15. It is copied here so nothing is lost.

| File | What it is |
|---|---|
| [`xpact-error-report.md`](xpact-error-report.md) | Consolidated error report: 21 issues, from build environment problems to conformance, with status |
| [`xpact-error-report-shorter.md`](xpact-error-report-shorter.md) | A shorter version of the same report |
| [`BUILD_FIX_NOTES.txt`](BUILD_FIX_NOTES.txt) | How the native DLL build was fixed (msc_vc140 backend, precompile, `ec.lock`, stderr guards) |
| `firstReport.odt` | The first version of the error report (2026-10-13) |
| [`patches/01-week1-build-fixes.patch`](patches/01-week1-build-fixes.patch) | Commit `b930600` (2026-10-14): `msc_vc140` backend and stderr guards in `build_native_eiffel.ps1`, `import_msvc_environment.ps1` and `run_native_runtime_smoke.ps1`; mingw-only precompile removed from two ECFs; adds `run_xmlconf_conformance.ps1` |
| [`patches/02-week2-runner-changes.patch`](patches/02-week2-runner-changes.patch) | Uncommitted week 2 changes: `run_xmlconf_conformance.ps1` downloads the pinned W3C ZIP and runs `finish_freezing`; stderr guard in `run_eiffel_test_matrix.ps1` |

The branches that held `b930600` (`student-test`, `Mass-test-workbench`) were
deleted from GitHub, so these patches are now the only copy outside the Desktop folder.

## Applying the patches

The build on this PC needs them (see the blocker issue `22-blocker-build-fixes.md`):

```powershell
cd C:\Users\masou\Documents\xpact-student-mass
git apply student\history\patches\01-week1-build-fixes.patch
git apply student\history\patches\02-week2-runner-changes.patch
```

Apply them on an issue branch, not directly on `student-Mass`, and agree with the
supervisor whether they should be committed.
