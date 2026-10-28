# Issue #130: Finding: Jenkins "Eiffel Tests" stage turns green without printing a test result

Archived from <https://github.com/andersoxie/xpact/issues/130> on 2026-10-28 01:33 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-26 19:57 |
| Closed |  |
| Labels | `type:finding`, `group:B-reliable-results`, `build`, `investigation` |
| Milestone | Week 5 - Regressions |

## Description

## Problem
The Jenkins stage **"Eiffel Tests"** turns green, but its log shows no test result. It never prints `xpact Phase 1 tests: ok` or a FAIL line.

**Environment:** Jenkins on the supervisor's machine, `main` @ `9e1747d`, 2026-10-23. Log: [`reports/issue-0073/jenkins-log-2026-10-23.txt`](../blob/student-Mass/reports/issue-0073/jenkins-log-2026-10-23.txt), from line 59. The stage was unchanged in the 2026-10-26 check (#104).

**Command:** the stage's `powershell` step in the Jenkinsfile.

## Expected result
The stage prints the test result (`xpact Phase 1 tests: ok` or the failing tests). A failing test makes the stage red.

## Actual result
The log has `Eiffel Compilation Manager` lines written to stderr through `powershellWrapper.ps1`, then the stage ends green with no test output.

## Investigation
On the student PC, the same symptom came from a stale test executable (#104). On Jenkins it has not been checked: the student has no access to the Jenkins machine.

## Cause
- ✔ **Confirmed** on the student PC (stale executable).
- ❓ **Unknown** on Jenkins.

## Fix
None. Needs someone with access to the Jenkins pipeline.
