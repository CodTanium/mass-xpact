# Student workspace (Mass)

Everything produced for the ten-week xpact student assignment lives in this
folder, so it stays separate from the parser code. The plan, the task register
(A01–H06) and the suggested task selection come from
[`docs/xpact-student-introduction.md`](../docs/xpact-student-introduction.md).

**Start here: [PLAN2.md](PLAN2.md)**: the 10-week plan with everything done, tested and found so far. [PLAN.md](PLAN.md) is the empty version.

## Layout

| Path | What goes there |
|---|---|
| [`history/`](history/) | Weeks 1–2 before this repository: error reports, build fix notes, and your fixes as patches |
| [`baseline/`](baseline/) | The week 2 assertions-enabled baseline: script, event trace, logs, BASELINE.md |
| [`results/`](results/) | One folder per issue with its evidence: logs, inputs, before/after output |
| [`notes/weekly/`](notes/weekly/) | Half-page weekly notes, one file per week |
| [`report/`](report/) | The university report, demonstration notes and handover guide (weeks 8–10) |
| [`github/`](github/) | Labels, milestones and issue drafts, plus `setup-github.ps1`, which creates them on GitHub |

Outside this folder:

| Path | What it is |
|---|---|
| `.github/ISSUE_TEMPLATE/` | "Task" and "Finding" forms for new issues |
| `.github/pull_request_template.md` | The checklist every pull request starts with |
| `.github/workflows/python-harness.yml` | Runs the Python harness tests on every pull request (no Eiffel needed) |

## Branches

| Branch | Purpose |
|---|---|
| `main` | The teacher's code. Never commit to it directly. |
| `student-Mass` | Your integration branch. Finished, reviewed work is merged here. |
| `<id>-<words>` | One short-lived branch per issue, e.g. `b01-nonzero-exit`, made from `student-Mass` |

## Working on one issue

```text
pick an issue from "This week" on the board
  -> git switch student-Mass ; git pull
  -> git switch -c b01-nonzero-exit
  -> small commits; evidence goes in student/results/B01-nonzero-exit/
  -> git push -u origin b01-nonzero-exit
  -> open a pull request into student-Mass, body says "Closes #<issue number>"
  -> supervisor reviews -> merge -> the issue closes and the card moves to Done
  -> write the week's note in student/notes/weekly/ and link it in the A06 issue
```

The same steps as PowerShell commands:

```powershell
git switch student-Mass
git pull
git switch -c b01-nonzero-exit
# ... work, then:
git add -A
git commit -m "B01: make xpact_tests.exe exit nonzero on failure"
git push -u origin b01-nonzero-exit
```

Then open the pull request on GitHub. After pushing, GitHub shows a "Compare & pull request" button.

## What every result must record

From the guide, "One issue at a time": for each result keep

- the input or its hash,
- the source revision (`git rev-parse HEAD`) and any uncommitted changes,
- compiler and assertion settings, callback configuration and chunk sizes,
- expected and actual outcome,
- the exact command and its exit status.

Keep confirmed observations separate from possible explanations. A green
manifest or a count of test definitions is not evidence that the tests passed.

## Logs in git

The repository's `.gitignore` excludes `*.log`. An exception lets `.log` files
under `student/` be committed, because they are the evidence. Build output
(`EIFGENs/`, `build/`, `*.exe`) is still ignored everywhere.
