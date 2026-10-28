# Issue #140: Script for the supervisor: collect dual-implementation and Jenkins information into one .txt

Archived from <https://github.com/andersoxie/xpact/issues/140> on 2026-10-28 19:58 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 21:22 |
| Closed | 2026-10-26 21:27 |
| Labels | `type:task`, `workflow`, `group:G-verification` |
| Milestone | Week 5 - Regressions |

## Description

## Task
Write a script the supervisor can run on the Jenkins machine. It collects, into one `.txt` file, what is needed for the open steps of the dual-implementation plan (`newUpdates.txt`) and for #74/#79. That information only exists on that machine:

- **Tools:** EiffelStudio version; `ISE_EIFFEL`, `ISE_PLATFORM` and `ISE_C_COMPILER` (process, user and machine scope; for #74); MSVC, Python, Git, .NET, CMake.
- **Repository:** path, branch, commit, local changes, remotes.
- **Xpact-core:** the pinned checkout in `build/dependencies/xpact-core/`.
- **Local dual runs:** the newest `build/dual-catalog`, `build/dual-w3c` and `build/dual-ci-*` runs (`run.json`, summaries).
- **Jenkins:** the last builds of the xpact jobs (result, stage lines, key lines, tail), and archived dual-CI `run.json` files. This covers "Jenkins controller execution has not been performed", #74, #79 and #130.
- **WSL:** distributions, and whether EiffelStudio is installed there (step 7).
- **Large XML:** corpus files the supervisor names: size and SHA-256 (step 7).
- **Optional (`-RunDualLanes`):** run both dual lanes now and include their results (step 9 baseline).

## Rules
- Read-only by default; it never changes the repo, Jenkins or Git settings.
- Windows PowerShell 5.1 compatible.
- E-mail addresses masked, output size limited.

## Expected (written before testing)
- On the student PC (no Jenkins, no WSL distro): it completes, writes the file, and reports the missing parts as "not found" instead of failing.
- It parses in PowerShell 5.1.

## Discussion

### CodTanium, 2026-10-26 21:27: comment

Done in 36509b8 (PR #141). Verified on the student PC (PowerShell 5.1): parses with 0 errors; completes without Jenkins or WSL; reads a fake Jenkins home correctly (e-mail masked); -LargeXml and -RunDualLanes behave as described. Not yet run on the supervisor's machine. Report: reports/issue-0140/report.md.
