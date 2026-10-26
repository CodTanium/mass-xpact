# Issue #33: Task: A02 - reproduce assertions-enabled workbench and finalized builds

Archived from <https://github.com/andersoxie/xpact/issues/33> on 2026-10-26 11:49 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 22:38 |
| Closed | 2026-10-21 22:48 |
| Labels | `type:task`, `D2-guided`, `P0`, `test` |
| Milestone | Week 2 - Baseline |

## Description

Created from the draft `student/github/issues/02-A02.md`.

## Goal
Reproduce fresh assertions-enabled workbench and finalized builds. Record tool dependencies and blocked steps; produce setup instructions another developer can follow.

## Why
Student guide, task register A02 and the week 2 plan ("Baseline log with revision, configuration, commands and known failures").

## Done when
- [x] Baseline log with revision (`git rev-parse HEAD`), configuration, commands, exit codes and known failures _(verified 2026-10-22 at `76ac272`)_
- [x] Workbench and finalized (`ec -finalize -keep`) assertions-enabled test lanes run: 2026-10-14, outside git, `student/baseline/BASELINE.md` steps 2 and 4
- [x] Tool versions recorded: EiffelStudio, C backend (`ISE_C_COMPILER`), Visual Studio / MSVC, Python, PowerShell: `BASELINE.md` section 2, `baseline/logs/environment.log`
- [x] Blocked steps written down with their error output: `BASELINE.md` section 5 (K1-K5), with logs
- [x] Setup instructions drafted in `student/report/setup-guide.md` _(verified 2026-10-22 at `76ac272`)_
- [x] Logs in `student/results/A02-baseline/` _(verified 2026-10-22 at `76ac272`)_

## Evidence / notes
**Mostly done.** The first baseline ran on 2026-10-14 outside git: `student/baseline/BASELINE.md`. Its findings are filed as separate `type:finding` issues. Weeks 1–2 build problems and fixes: `student/history/`.

Remaining: apply the patches (blocker issue), rerun `.\student\baseline\run_baseline.ps1` in this checkout so the results are tied to a commit, and write `student/report/setup-guide.md`.

## Discussion

### CodTanium, 2026-10-21 22:48: comment

Done on student-Mass in 1799b35 and 42d6b40: baseline rerun at 1799b35 (student/results/A02-baseline/README.md), setup guide in student/report/setup-guide.md.
