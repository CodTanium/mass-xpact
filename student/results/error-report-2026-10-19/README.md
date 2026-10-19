# Error report 2026-10-19 - three failed runs

Issues: B03 postcondition (draft 05), build fixes not in main (draft 22), MSVC "input line is too long" (draft 24)
Branch: student-Mass   Revision: most likely `4f71743` (runs were made in a copied folder, not a git clone; see the report)

| # | Command | Result |
|---|---|---|
| 1 | `.\scripts\build_native_eiffel.ps1` | "Cannot find Eiffel runtime include directory." |
| 2 | `.\scripts\run_phase1.ps1` | `final_finished_or_suspended` postcondition violated in `test_garbage_collection_suspension` (assertions-on / Workbench) |
| 3 | `.\scripts\run_eiffel_test_matrix.ps1` | "The input line is too long." while importing vcvars64.bat |

Files:
- `error-report-2026-10-19.md`: the full report (environment, error output, observations, possible explanations, next steps)
- `exception_trace.log`: Eiffel exception trace from run 2
