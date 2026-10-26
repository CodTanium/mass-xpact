# Issue #34: Task: repair the repository state left on 2026-10-21 (overwritten baseline log, direct pushes, uncommitted docs)

Archived from <https://github.com/andersoxie/xpact/issues/34> on 2026-10-26 17:14 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 23:19 |
| Closed | 2026-10-22 00:19 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

Found on 2026-10-22 while checking the clone against `CLAUDE.md`. Five separate problems, all in how the work of 2026-10-21 was recorded. None of them changes the parser or a test result.

| # | Problem | Cause | Fix |
|---|---|---|---|
| 1 | The week 2 baseline log `student/baseline/logs/matrix-finalized-keep.log` was **overwritten** in the working copy (40,731 → 3,686 bytes, a PowerShell error record) | **Confirmed:** the A02 rerun wrote into the week 2 log folder, before `run_baseline.ps1 -LogDir` existed (`1799b35`) | Restored from git (`git restore`); the committed file was never changed. The A02 copy is in `student/results/A02-baseline/` |
| 2 | Four commits were **pushed straight to `student-Mass`** without a pull request: `1ea242e` (#28), `492c6eb` (#32), `1799b35` and `42d6b40` (#33) | **Confirmed** from `git log` and `gh pr list` | History is not rewritten (that would need a force push). The four commits are listed in `student/VERSIONING.md` ("Committed without a pull request") and with their SHAs in `reports/README.md` |
| 3 | Pull request #31 (the same #28 test) was **closed, not merged**, and its branch `fix/28-cr-regression-test` was left on GitHub | Follows from 2 | Checked that `1ea242e` has the same 8 files as the branch, then deleted the branch (local and on GitHub). #31 stays closed |
| 4 | Doc updates from 2026-10-21 (README, VERSIONING, supervisor page, week 3 note, history, two issue drafts) were **left uncommitted** in the working copy | **Suspected:** taken out of #31 (`0d27d9f`, "Take the unrelated student docs out of this pull request") and never committed elsewhere | Committed in this task |
| 5 | `reports/README.md` has no row for #33 and says "see git log --grep" instead of the commit for #28 and #32 | Follows from 2 | Rows completed with the SHAs |

Also: `CLAUDE.md` (the rules for this work) was not in git, and the unpacked W3C suite `xmlconf/` was untracked. `CLAUDE.md` is committed; `xmlconf/` is downloaded data, so it is excluded locally (`.git/info/exclude`) and not committed.

**Environment:** `C:\xpact\xpact-student-Mass`, branch `student-Mass` @ `42d6b40`, Windows 11, Windows PowerShell 5.1, git, GitHub CLI 2.102.

**Commands used to find it:** `git status --short`, `git diff --stat`, `git log --oneline --all --graph`, `gh pr list --state all`, `git diff 1ea242e 0d27d9f --stat -- tests reports/issue-0028` (empty: same content).

**Verification:** after the pull request, `git status` shows only files that are meant to be untracked, every fix in `reports/README.md` has a commit, and `git ls-remote origin fix/28-cr-regression-test` is empty.

## Discussion

### CodTanium, 2026-10-22 00:19: comment

Fixed in `6e2278e` (PR #36). Verified: the week 2 log is restored (`git status` clean for `student/baseline/`), the four direct commits are listed in `student/VERSIONING.md` and `reports/README.md`, the stale branch is gone (`git ls-remote origin fix/28-cr-regression-test` empty). Report: `reports/issue-0034/report.md`.
