# Personal notes

Working notes kept outside git during the assignment (October 2026), added here
unchanged so the record is complete. They are snapshots: the reports in
[`reports/`](../../reports/README.md) and the issues in the
[GitHub archive](../github/README.md) are the checked record.

| File | Date | What it is |
|---|---|---|
| [`xpact-investigation-report-2026-10-13.md`](xpact-investigation-report-2026-10-13.md) | 2026-10-13 | First investigation report (weeks 1-2). The build errors it lists as unresolved were fixed later in #2, #4, #7 and #10 |
| [`guide.txt`](guide.txt) | 2026-10-19 | Reporting guide: what to record for an error and for a test result, collected from the student guide |
| [`error.odt`](error.odt) | 2026-10-20 | Error-report checklist (the same fields as `guide.txt`) |
| [`how each fix work.odt`](how%20each%20fix%20work.odt) | 2026-10-20 | How the `fix.ps1` versioning workflow works, step by step (before the `reports/issue-NNNN/` layout of #14) |
| [`for superviser (draft 2026-10-20).txt`](for%20superviser%20%28draft%202026-10-20%29.txt) | 2026-10-20 | First draft of the supervisor summary; the committed version is [`student/for superviser.txt`](../../student/for%20superviser.txt) |
| [`sync-latest.ps1`](sync-latest.ps1) | 2026-10-20 | Script that refreshed the non-git working folder from the git clone |
| [`builds.txt`](builds.txt) | 2026-10-22 | Map of every ECF target, script, assertion setting and what each build's output verifies |
| [`jenkins.odt`](jenkins.odt) | 2026-10-23, updated 2026-10-25 | Jenkins notes |
| [`reportweek.txt`](reportweek.txt) | 2026-10-23 | Weekly report, week 3 (19-23 October) |
| [`w3cerror.txt`](w3cerror.txt) | 2026-10-24 | Analysis of the Jenkins W3C skips: where 1,716 skipped and 3,497 passed come from, and which skips can be fixed |
| [`newChanges.txt`](newChanges.txt) | 2026-10-25, updated 2026-10-26 | The supervisor's changes on `main` (#82-#101) in plain words, what they mean for the student work, and the sync of `main` into `student-Mass` (#102, #103) |
| [`xpact-core.txt`](xpact-core.txt) | 2026-10-27 | The supervisor's xpact vs Xpact-core lanes on the student PC, the new dual regression lane, and two Xpact-core behaviours (empty final call, lone-CR chunk) |
| [`smoke-test.txt`](smoke-test.txt) | 2026-10-27 | The assertions DLL smoke test switched back on (#142) and the 7 skipped Python tests fixed (#143) |
| [`versionisseu.txt`](versionisseu.txt) | 2026-10-27 | Why W3C cases were skipped: old XML editions, XML 1.1, optional errors, in plain words |
| [`latest_w3c.txt`](latest_w3c.txt) | 2026-10-27 | Option A step by step (#146, F1-F7), the `--all-cases` flag, the speed finding. **Out of date:** written before the supervisor's #150; F6b in it was wrong (dropped in #151) |
| [`status-2026-10-28.txt`](status-2026-10-28.txt) | 2026-10-28 | "Where am I?": timeline of 24-28 October, the supervisor's #150, the #151/#152 integration, and what was left |
| [`latest600Test.txt`](latest600Test.txt) | 2026-10-28 | The 11 extra test types found online (W3C output, chunking, fuzzing, Expat differential, security, Expat's own tests, libxml2, encodings, memory, Python, large files), how each works, and what went wrong in that session |
| [`latest600Test2.txt`](latest600Test2.txt) | 2026-10-28 | Test 1 rerun: the W3C **output** check, 359 of 432 right, the 6 problems F01-1 to F01-6 |
| [`latest600Test3.md`](latest600Test3.md) | 2026-10-28 | Results of the six fixes #154-#159 (PR #160-#164): W3C output 359 -> 399 of 432, no xpact-only difference left, every check |
| [`w3c-report-2026-10-28.txt`](w3c-report-2026-10-28.txt) | 2026-10-28 | The W3C result of the integrated version in plain words: 2,585 cases, 0 failed, 0 errors, 0 skipped (full report: [`reports/latest-2026-10-28`](../../reports/latest-2026-10-28/README.md)) |

The Jenkins log of `main` at `cf12dee` (`jenkinReport.txt`) is already in the
repository as [`reports/issue-0079/jenkins-log-cf12dee-before.txt`](../../reports/issue-0079/jenkins-log-cf12dee-before.txt).
