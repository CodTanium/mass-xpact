# Fix report: issue #70, close the doc gaps found in the 2026-10-22 checklist audit

Issue: [#70](https://github.com/andersoxie/xpact/issues/70)   Branch: `fix/70-audit-doc-gaps`   Base: `student-Mass` @ `76ac272`   Date: 2026-10-22

## Why

On 2026-10-22 every closed issue's "Done when" list was compared with the
repository at `76ac272`. 12 issues (#14, #16, #18, #24, #26, #29, #33, #35,
#37, #43, #45, #46) had unticked boxes even though the work was merged.

## The audit

| Result | Issues / items | What was done |
|---|---|---|
| ✅ Really done | all items of #14, #16, #18, #24, #26, #29, #33, #37, #45; 3 of 4 of #43; 4 of 5 of #46 | Ticked on GitHub, each marked "verified 2026-10-22 at `76ac272`" |
| ✅ Done another way | #29 "draft for the CR finding added" | Ticked with the note: filed directly as issue #28, no draft |
| 🔧 Not true, fixable | #43 "every page states its date and commit"; #35 "README describes … which issue has which" | **This change** |
| ⏸ Not true, needs someone else | #35: 6 labels in `labels.json` not on GitHub | Left unticked with a note; the supervisor decides (`student/github/README.md`) |
| ⏸ Dropped | #46: the Jenkins stage turns red | Split into its own unticked, struck-through line (#64) |
| 🔧 Missing evidence | A01's last three items (behind #18) | Separate issue [#68](https://github.com/andersoxie/xpact/issues/68) |

How each item was checked: file exists (`Test-Path`), content searched
(`grep`), labels and milestones compared with `gh label list` and
`gh api repos/andersoxie/xpact/milestones`, link check over every `.md` under
`student/`, `reports/`, `docs/`, and `git diff --name-status --diff-filter=MDR`
for overwritten evidence (none since #44).

## What changed

| File | Change |
|---|---|
| `student/README.md` | Status line: weeks 1-3 ✅, what is on hold, date and commit |
| `student/VERSIONING.md`, `student/report/README.md` | "Last updated" line with the commit |
| `student/github/README.md` | "Last updated" line; issues #2-#70; #48-#70 in the milestone table and in "created outside the drafts"; board table from the issue state (closed #28, #45, #46 no longer under Todo); note that the board could not be read |
| `student/PLAN.md` | Week 3: the audit and what is still open from it |
| `reports/README.md` | Row for #70 |

Also on GitHub (not a file change): #64 got its milestone and labels; #68
got `documentation`.

## Expected results (written before testing)

| # | Check | Expected |
|---|---|---|
| 1 | First 10 lines of the four pages | each shows `2026-10-22` and `76ac272` |
| 2 | Every closed issue number #2-#70 in `student/github/README.md` | present |
| 3 | Link check | 0 broken |
| 4 | `git diff --stat origin/student-Mass` | only the files above |

## Verification

| # | Command | Actual | |
|---|---|---|---|
| 1 | `head -10` of each page, `grep 76ac272` | all four match | ✅ |
| 2 | `gh issue list --state all` numbers vs. `grep "#N"` in the README | none missing (#2-#70) | ✅ |
| 3 | link check script | 0 broken | ✅ |
| 4 | `git diff --stat origin/student-Mass` | the files above plus this report (7) | ✅ |

## Limitations

- The project board was **not read**: the `gh` token has no `read:project`
  scope. The board table is built from the issue state, and says so.
- `#69` (A01 evidence) is a separate, unmerged pull request; the pages say so.

## How to revert

```powershell
.\student\tools\fix.ps1 revert -Issue 70 -Commit <merged sha>
```
