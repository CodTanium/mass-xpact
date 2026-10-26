# Issue #90: Add email notifications for failed and unstable xpact builds

Archived from <https://github.com/andersoxie/xpact/issues/90> on 2026-10-26 17:14 UTC.

| | |
|---|---|
| State | open |
| Author | andersoxie |
| Created | 2026-10-25 09:02 |
| Closed |  |
| Labels | - |
| Milestone | - |

## Description

Neither xpact Jenkinsfile currently sends email when a build fails or becomes unstable.

Add an `EMAIL_RECIPIENTS` parameter to both pipelines so addresses can be entered in Jenkins without committing them to the repository. Start with an empty default, retain the last submitted value for later builds, and allow clearing it to disable notifications.

Send one notification for final `FAILURE` and `UNSTABLE` results, after artifact/test publication. Include the build result and links to the build and console. Do not send for success, aborted, or not-built results. Mail delivery errors must preserve the original build result, and cancellation must propagate.

Local verification already passed 19 Groovy stub scenarios against both complete Jenkinsfiles, covering recipient lifecycle, result filtering, message contents, publication ordering, SMTP failures, and interruption propagation. No email was sent. Real Jenkins Declarative/CPS execution and SMTP delivery remain unverified.

Full-file validation also exposed two pre-existing Groovy escaping errors in the all-tests Sonar PowerShell block. A minimal prerequisite correction is included separately so that pipeline can parse and be tested.
