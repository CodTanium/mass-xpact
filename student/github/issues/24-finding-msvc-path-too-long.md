---
title: "Finding: importing the MSVC environment fails with \"The input line is too long\" after repeated runs"
labels: group:B-reliable-results, D2-guided, P1, type:finding
milestone: Week 3 - Failure reporting
---
## Steps to reproduce
1. In one PowerShell window, run `.\scripts\run_phase1.ps1` and `.\scripts\build_native_eiffel.ps1` (both import the Visual Studio environment).
2. In the same window, run `.\scripts\run_eiffel_test_matrix.ps1`

## Expected
The MSVC environment loads and the four matrix cells run.

## Actual
On 2026-10-19 the matrix stopped before compiling anything:

```
The input line is too long.
The syntax of the command is incorrect.
Failed to import Visual Studio C++ environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
At ...\scripts\import_msvc_environment.ps1:24 char:2
```

"The input line is too long." comes from cmd.exe (~8191-character limit). In a fresh shell PATH is about 1,040 characters.

## Revision and configuration
Most likely `4f71743` (run in a copied folder, not exact; see the report). EiffelStudio 25.12.9.8922 win64, Visual Studio 18 Community 18.10.3, MSVC 14.51.36231, Windows PowerShell 5.1.

## Logs
`student/results/error-report-2026-10-19/error-report-2026-10-19.md`, error 3. A full console log was not saved.

## Possible explanation (not confirmed)
`import_msvc_environment.ps1` copies the vcvars environment into the process with `Set-Item Env:...`. Each import in the same window prepends the Visual Studio folders to PATH (and INCLUDE/LIB/LIBPATH) again, until vcvars64.bat itself exceeds cmd's limit. Check: `$env:Path.Length` in the failing window, then rerun in a new window. If confirmed, skip the import when `$env:VCToolsInstallDir` is already set.
