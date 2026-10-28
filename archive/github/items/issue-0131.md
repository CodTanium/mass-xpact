# Issue #131: Finding: SonarQube analysis on Jenkins fails with HTTP 401 Unauthorized

Archived from <https://github.com/andersoxie/xpact/issues/131> on 2026-10-28 01:33 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-26 19:57 |
| Closed |  |
| Labels | `type:finding`, `group:B-reliable-results`, `build` |
| Milestone | Week 5 - Regressions |

## Description

## Problem
The Jenkins stage **SonarQube analysis** fails with `HTTP 401 Unauthorized`.

**Environment:** Jenkins on the supervisor's machine, `main` @ `9e1747d`, 2026-10-23. Log: [`reports/issue-0073/jenkins-log-2026-10-23.txt`](../blob/student-Mass/reports/issue-0073/jenkins-log-2026-10-23.txt), line 113.

**Command:** the `withSonarQubeEnv` / SonarScanner CLI 8.0.1 step.

## Expected result
The analysis is uploaded to `https://sonarqube.bsharp.se`.

## Actual result / error output
```
ERROR Failed to query server version: GET https://sonarqube.bsharp.se/api/v2/analysis/version failed with HTTP 401 Unauthorized. Please check the property sonar.t…
```

## Cause
❔ **Suspected:** the server token in the Jenkins `Sonar` configuration is missing or has expired. The 401 status points there; it was not checked on the server.

## Fix
None. Needs the token renewed by whoever administers Jenkins and SonarQube.
