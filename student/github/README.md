# GitHub setup

The plan from `docs/xpact-student-introduction.md` as GitHub labels, milestones,
issues and a project board.

| File | Content |
|---|---|
| `labels.json` | 14 labels: group (A, B, C, F, G), difficulty (D1–D4), priority (P0, P1), type (task, finding, blocker) |
| `milestones.json` | One milestone per review point, weeks 2, 3, 4, 5, 7 and 10. Due dates assume that week 1 started on 2026-10-05. Change them if that is wrong. |
| `issues/*.md` | 20 issue drafts: the guide's suggested selection plus the week 2 findings. Edit or delete drafts before running the script. |
| `setup-github.ps1` | Creates all of the above on GitHub. Safe to run again. |

## Milestones and issues

| Milestone | Issues |
|---|---|
| Week 2 - Baseline | A01, A02 · findings: finalized lane without `-keep`, B03 postcondition, runner stops at the first failure, DLL crash code, Python 3.10 harness |
| Week 3 - Failure reporting | B01, B02 |
| Week 4 - Input matrix | G01, xmlconf verdict rules |
| Week 5 - Regressions | C02, C03, C10 (part) |
| Week 7 - Comparison | A04, G03 |
| Week 10 - Handover | A06 (open all ten weeks), report and handover, F01 and F02 (optional) |

## Running it

Creating labels, milestones and issues needs **write access** to the repository.
Ask the supervisor first whether to use `andersoxie/xpact` or a fork of your own.

```powershell
winget install GitHub.cli          # once; then open a new PowerShell window
gh auth login                      # once; choose GitHub.com and log in with the browser
gh auth refresh -s project         # only for -CreateProject

cd C:\Users\masou\Documents\xpact-student-mass
.\student\github\setup-github.ps1 -DryRun                    # shows what it would do
.\student\github\setup-github.ps1                            # labels, milestones, issues
.\student\github\setup-github.ps1 -CreateProject             # ... plus the project board
.\student\github\setup-github.ps1 -Repo <you>/xpact          # use your fork instead
```

## Project board columns

The script creates the board and adds the issues. You set up the columns once, in the browser:

1. Open the project, go to **Settings** and then **Status**, and set the options
   to `Backlog`, `This week`, `In progress`, `In review` and `Done`.
2. In the view menu, choose **Layout: Board**, grouped by Status.
3. Under **Workflows**, turn on "Item closed -> Done" and "Pull request merged -> Done".
4. Move all issues to `Backlog`, then each week drag that week's issues to `This week`.
