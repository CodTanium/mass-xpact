---
title: "Finding: Jenkins builds stop at an EiffelStudio precompile prompt"
labels: group:B-reliable-results, D2-guided, P1, type:finding
milestone: Week 3 - Failure reporting
---
## Steps to reproduce
1. Run the Windows Jenkins job (Jenkins as a Windows service under the SYSTEM account).

## Expected
The build completes unattended.

## Actual
Repeated builds hit an interactive prompt about the `base-safe.ecf` precompile. Job #4 completed, but the prompt remained (error report, section 9.1). The SYSTEM account has a different user profile, so it does not see the precompiled bases under `%USERPROFILE%\Documents\Eiffel User Files\`.

## Logs
`student/history/xpact-error-report.md`, section 9.1. Attach the Jenkins console output of a new run.

## Proposed next step
Check which ECFs still declare a `<precompile>`. Give the Jenkins service a consistent EiffelStudio install, environment (`ISE_EIFFEL`, `ISE_C_COMPILER`) and account profile. Related: B01/B02 (CI must report failures, not hang).
