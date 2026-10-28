# Issue #137: Finish PR #76 and clean up merged branches

Archived from <https://github.com/andersoxie/xpact/issues/137> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 20:50 |
| Closed | 2026-10-26 20:56 |
| Labels | `type:task`, `workflow` |
| Milestone | Week 5 - Regressions |

## Description

## Task
1. Finish PR #76 (#74). Bring the current `student-Mass` into `fix/74-keep-msvc-backend`, retest with MSVC (both DLL builds with smoke, the native runtime smoke, the Eiffel matrix), then squash-merge. #74 stays open until a Jenkins run confirms it.
2. Delete our branches whose PRs are merged, on andersoxie/xpact and on the CodTanium/mass-xpact copy:
   - `fix/121-expat-comparison`, `fix/128-final-input-regressions`, `fix/132-remove-old-runner-copy`, `fix/134-docs-week5`, `fix/73-jenkins-verified`;
   - `docs/week-03-report`, `fix/68-a01-evidence`, `fix/70-audit-doc-gaps`, `fix/3-start-tag-loop-variant`, `fix/w3c-known-failures`.
3. Delete the merged and gone local branches in the clone.

`main` and the supervisor's `codex/*` branches are not touched.

## Expected
- Before each branch is deleted, its PR is MERGED.
- After the cleanup, `student-Mass` and `main` are unchanged by the deletions.
- PR #76: all builds pass.

## Discussion

### CodTanium, 2026-10-26 20:56: comment

Done in d2f98a9 (PR #138). Verified:
- PR #76 merged as 7cf5a94 after a retest (8/8 choice cases, both DLL smokes, runtime smoke, matrix 4/4, MSVC).
- 11 merged branches deleted (each had a MERGED PR); main de01371 and student-Mass unchanged by the deletions; 20 local branches deleted.
- The fix/137 branch was deleted on merge.
Evidence: reports/issue-0137/branch-cleanup.txt. The mass-xpact copy is cleaned after its refresh.
