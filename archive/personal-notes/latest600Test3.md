# ✅ Result: the W3C output test and the fix for #154 / #155

> 2026-10-28 · follows [latest600Test.txt](latest600Test.txt) (the test list) and [latest600Test2.txt](latest600Test2.txt) (the output check)
> **Repo:** [PR #160](https://github.com/andersoxie/xpact/pull/160) ✅ **merged into `student-Mass` as `7028e68`** · local folder synced · `main` not touched (`1714f31`)

## 🚦 At a glance

| Step | Status |
|---|---|
| 1. One issue per problem | ✅ [#154](https://github.com/andersoxie/xpact/issues/154) – [#159](https://github.com/andersoxie/xpact/issues/159) posted |
| 2. Find the cause of F01-1 | ✅ confirmed |
| 3. Fix on its own branch from `student-Mass` | ✅ `fix/154-attribute-defaults-external`, 2 commits |
| 4. Rerun test 1 (assertions first) + all old tests | ✅ all pass, nothing worse |
| 5. Mark done | ✅ report, plan, reports index updated · 🟡 issues stay open until merge + Jenkins |
| Pull request | ✅ [#160](https://github.com/andersoxie/xpact/pull/160) merged (`7028e68`), branch deleted, local folder synced |

## 📈 Before → after

| | Before | After |
|---|---:|---:|
| ✅ W3C output exactly right | 359 / 432 | **393 / 432** |
| 🔴 wrong, xpact only | 40 | **6** |
| 🟡 optional (either answer allowed) | 4 | 4 |
| ⚪ Expat differs too (XML 1.1 files) | 29 | 29 |
| ❌ cases that got worse | | **0** |

## 🔴 The 6 problems

| ID | Issue | Problem in easy words | Cases | Status |
|---|---|---|---:|---|
| F01-1 | [#154](https://github.com/andersoxie/xpact/issues/154) | default attribute values from a separate DTD file were lost | 30 | ✅ fixed (PR #160) |
| F01-2 | [#155](https://github.com/andersoxie/xpact/issues/155) | default attribute values lost inside an external entity | 1 | ✅ fixed (PR #160) |
| F01-3 | [#156](https://github.com/andersoxie/xpact/issues/156) | extra spaces not cleaned up in some attribute types | 4 | ✅ 4 / 4: 3 by PR #160, the last one (`valid-sa-096`) by [PR #161](https://github.com/andersoxie/xpact/pull/161) 🟡 PR not merged yet |
| F01-4 | [#157](https://github.com/andersoxie/xpact/issues/157) | spaces not cleaned up in a notation's public ID | 1 | ⬜ not started |
| F01-5 | [#158](https://github.com/andersoxie/xpact/issues/158) | a second BOM character dropped | 3 | ⬜ not started |
| F01-6 | [#159](https://github.com/andersoxie/xpact/issues/159) | an entity inside an entity value read as declarations | 1 | ⬜ not started |

## 🔍 The cause (confirmed)

When xpact reads a separate file (external DTD or entity), it uses a helper **child parser**. Parent and child passed the **entity** tables to each other, but **never the attribute declarations**. The fix passes those too, in the same three places (`src/xp_parser.e`, +52 lines):

| Place | Direction | Fixes |
|---|---|---|
| `import_entity_context` | parent → child | F01-2 |
| `merge_entity_context_from` | child → parent | F01-1 |
| `entity_context_snapshot` | the replay copy xpact uses when it re-reads the buffer | F01-1 |

## 🧪 Checks (assertions build first, then normal)

| Check | Before | After |
|---|---|---|
| ✅ DLL build + smoke test | ok ×2 | ok ×2 |
| ✅ **Test 1, W3C output** | 359 / 432 | **393 / 432** |
| ✅ W3C accept/reject through the DLL (2,585) | baseline | identical |
| ✅ Jenkins W3C stage, run locally | 0 failed | 0 failed, 0 errors, 0 skipped |
| ✅ External files lane | 247 / 247 | 247 / 247 |
| ✅ Python suite | 206 OK | 206 OK |
| ✅ C# tests vs Expat (4,308) | baseline | identical |
| ✅ Dual regression lane | 910 / 910 | 910 / 910 |
| ✅ Eiffel test matrix | 4 / 4 | 4 / 4 |
| ✅ GitHub check on PR #160 (`harness`) | | pass |
| 🟡 Jenkins | | not run yet |

## ⚠️ Problems met on the way (none caused by the fix)

| Problem | Cause | Done |
|---|---|---|
| Xpact-core part of the dual lane not built | ✅ environment: new worktree has no cached Xpact-core | xpact lane run; Xpact-core not touched by the fix |
| Test tool reported every case as a crash | ✅ my tool: a relative DLL path | fixed in the tool; rerun gives the same 393 |
| Merge of PR #160 blocked at first | the permission system blocks merges without review | ✅ merged after you said "try again" |
| `sync-latest.ps1` would overwrite your own `CLAUDE.md` with the repo's | the repo has its own `CLAUDE.md` | ✅ backed up and restored around the sync |

## 📂 Where everything is

| What | Where |
|---|---|
| Full report (CLAUDE.md format) | [reports/issue-0154/report.md](https://github.com/andersoxie/xpact/blob/bca7d9d/reports/issue-0154/report.md) |
| Test tool, repro files, all logs | `reports/issue-0154/` on the PR branch |
| Local working copy of the tests | `AlotOfTests/01-w3c-output-comparison/` |

## 🔧 #156: the last F01-3 case (PR #161)

| | Before (`7028e68`) | After |
|---|---:|---:|
| ✅ W3C output right | 393 / 432 | **394 / 432** |
| ❌ cases that got worse | | **0** |

**Cause (confirmed):** a value the element writes itself was cleaned up, but the **default from the DTD** was used exactly as written. Now the default is cleaned up where it is read (`src/xp_parser.e`, +4 lines), which is also what Expat reports (checked).

| Check (assertions build first) | Result |
|---|---|
| ✅ W3C output test | 394 / 432, only `valid-sa-096` changed |
| ✅ W3C accept/reject through the DLL (2,585) | identical |
| ✅ Jenkins W3C stage, run locally | 0 failed, 0 errors, 0 skipped |
| ✅ External files lane | 247 / 247 |
| ✅ Python suite | 206 OK |
| ✅ C# tests vs Expat (4,308) | identical |
| ✅ Dual regression lane | 910 / 910 |
| ✅ Eiffel test matrix | 4 / 4 |
| ✅ GitHub check on PR #161 | pass |
| ⬜ Merge | blocked by the permission system, needs your OK |

## 🔁 Jenkins

No answer from the supervisor yet on PR #152 or #160 (checked 2026-10-28 evening). #146, #148, #151, #153, #154, #155 and #156 stay open until the Jenkins run.

## ➡️ Next

- [x] Merge PR #160 into `student-Mass` (`7028e68`)
- [x] Refresh the local folder (`sync-latest.ps1`)
- [x] Refresh your own repo (mass-xpact): `portfolio` @ `93d8d2b`
- [x] #156: the last case (`valid-sa-096`): PR #161, checks pass
- [ ] Merge PR #161, then sync the local folder and mass-xpact again
- [ ] Jenkins run, then close #154, #155 and #156
- [ ] #157, #158, #159, one at a time
