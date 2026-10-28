# Issue #43: Task: bring the student docs up to date (2026-10-22) in the CLAUDE.md layout

Archived from <https://github.com/andersoxie/xpact/issues/43> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-22 00:01 |
| Closed | 2026-10-22 00:19 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

Bring every student document up to date with the work of 2026-10-21 and 2026-10-22, and lay them out the way `CLAUDE.md` asks: simple first, more detail further in, linked, easy to read, ✅ for done.

Affected: `student/README.md` (entry page), `student/PLAN.md` (live plan, known problems as a living TODO), `reports/README.md`, `student/for superviser.txt`, the week 3 note, `student/results/README.md`, `student/baseline/BASELINE.md` (update notes only, no evidence changed), the drafts C02/C03/C10/A04/07, `student/VERSIONING.md` (who merges, stacked pull requests), and the guide written on 2026-10-21 (`guide.txt`, `next-tests.txt`, untracked in the repository root).

## Done when
- [ ] Every page states its date and the commit it describes ⚠️ **not yet:** `student/README.md`, `student/VERSIONING.md`, `student/github/README.md` and `student/report/README.md` do not state a date and commit at the top
- [x] Every open problem is in one known-problems table with its issue and status (confirmed / suspected / unknown) _(verified 2026-10-22 at `76ac272`)_
- [x] Links resolve _(verified 2026-10-22 at `76ac272`)_
- [x] Nothing in `student/baseline/` evidence or in earlier results is overwritten _(verified 2026-10-22 at `76ac272`)_

## Discussion

### CodTanium, 2026-10-22 00:19: comment

Done in `6ad5f84` (PR #44). Verified: every page has its date, all open problems are in `student/PLAN.md` 'Known problems' with their cause marked, relative links resolve (check script: 0 broken), `student/baseline/` evidence unchanged (3 dated notes in BASELINE.md only).
