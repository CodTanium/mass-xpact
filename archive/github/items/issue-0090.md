# Issue #90: Add email notifications for failed and unstable xpact builds

Archived from <https://github.com/andersoxie/xpact/issues/90> on 2026-11-01 03:16 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | andersoxie |
| Created | 2026-10-25 09:02 |
| Closed | 2026-10-31 16:17 |
| Labels | - |
| Milestone | - |

## Description

Neither xpact Jenkinsfile currently sends email when a build fails or becomes unstable.

Add an `EMAIL_RECIPIENTS` parameter to both pipelines so addresses can be entered in Jenkins without committing them to the repository. Start with an empty default, retain the last submitted value for later builds, and allow clearing it to disable notifications.

Send one notification for final `FAILURE` and `UNSTABLE` results, after artifact/test publication. Include the build result and links to the build and console. Do not send for success, aborted, or not-built results. Mail delivery errors must preserve the original build result, and cancellation must propagate.

Local verification already passed 19 Groovy stub scenarios against both complete Jenkinsfiles, covering recipient lifecycle, result filtering, message contents, publication ordering, SMTP failures, and interruption propagation. No email was sent. Real Jenkins Declarative/CPS execution and SMTP delivery remain unverified.

Full-file validation also exposed two pre-existing Groovy escaping errors in the all-tests Sonar PowerShell block. A minimal prerequisite correction is included separately so that pipeline can parse and be tested.

## Discussion

### CodTanium, 2026-10-31 16:17: comment

Done by PR #91 and #92 (merged into `main`; in `student-Mass` since #189). Checked on `student-Mass` @ `02a6575` in both Jenkinsfiles: `EMAIL_RECIPIENTS` parameter with an empty default that keeps the last value; `notifyBuildResultByEmail` sends only for `FAILURE` and `UNSTABLE`, skips when the list is empty, wraps `mail` in `catchError(buildResult: 'SUCCESS', …, catchInterruptions: false)`, so a mail error keeps the original result and cancellation goes through. Checked by reading the code; no email was sent from the student PC.
