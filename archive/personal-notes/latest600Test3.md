# ✅ Result: the W3C output test and its 6 fixes (#154–#159)

> 2026-10-28 · follows [latest600Test.txt](latest600Test.txt) (the test list) and [latest600Test2.txt](latest600Test2.txt) (the output check)
> **Repo:** all 5 pull requests ✅ **merged into `student-Mass`** (now `e5d59e2`) · local folder synced · `main` not touched (`1714f31`)

## 🚦 At a glance

| Step | Status |
|---|---|
| 1. One issue per problem | ✅ [#154](https://github.com/andersoxie/xpact/issues/154) – [#159](https://github.com/andersoxie/xpact/issues/159) posted |
| 2. Find the cause of each | ✅ all 6 confirmed |
| 3. One fix branch per problem, from `student-Mass` | ✅ 5 pull requests (#154 and #155 share one) |
| 4. Rerun test 1 (assertions first) + all old tests | ✅ all pass, nothing worse |
| 5. Mark done | ✅ reports, plan, reports index updated · 🟡 issues stay open until Jenkins |
| Merged | ✅ #160 `7028e68` · #161 `d0a4e21` · #162 `133ae01` · #163 `82c82b5` · #164 `e5d59e2` |

## 📈 Before → after

| | Start | After all fixes |
|---|---:|---:|
| ✅ W3C output exactly right | 359 / 432 | **399 / 432** |
| 🔴 wrong, xpact only | 40 | **0** |
| 🟡 optional (either answer allowed) | 4 | 4 |
| ⚪ Expat differs too (XML 1.1 files) | 29 | 29 |
| ❌ cases that got worse | | **0** |

| After PR | Right |
|---|---:|
| start | 359 |
| #160 (#154, #155) | 393 |
| #161 (#156) | 394 |
| #162 (#157) | 395 |
| #163 (#158) | 398 |
| #164 (#159) | **399** |

## 🔴 The 6 problems

| ID | Issue | Problem in easy words | Cases | Status |
|---|---|---|---:|---|
| F01-1 | [#154](https://github.com/andersoxie/xpact/issues/154) | default attribute values from a separate DTD file were lost | 30 | ✅ fixed, PR #160 |
| F01-2 | [#155](https://github.com/andersoxie/xpact/issues/155) | default attribute values lost inside an external entity | 1 | ✅ fixed, PR #160 |
| F01-3 | [#156](https://github.com/andersoxie/xpact/issues/156) | extra spaces not cleaned up in some attribute types | 4 | ✅ fixed, 3 by PR #160 + 1 by PR #161 |
| F01-4 | [#157](https://github.com/andersoxie/xpact/issues/157) | spaces not cleaned up in a public ID | 1 | ✅ fixed, PR #162 (all public IDs, not only notations) |
| F01-5 | [#158](https://github.com/andersoxie/xpact/issues/158) | a second BOM character dropped | 3 | ✅ fixed, PR #163 (also a wrong verdict: two-BOM UTF-16 files were accepted) |
| F01-6 | [#159](https://github.com/andersoxie/xpact/issues/159) | an entity inside an entity value read as declarations | 1 | ✅ fixed, PR #164 |

## 🔍 The causes (all confirmed)

| Issue | Cause in one line | Change |
|---|---|---|
| #154/#155 | parent and child parser passed entity tables but never attribute declarations | `src/xp_parser.e`, +52 |
| #156 | a **declared default** was not cleaned up like a written value | `src/xp_parser.e`, +4 |
| #157 | the routine that reads every public ID never normalized it | `src/xp_parser.e`, +6 |
| #158 | the BOM was removed twice: by the UTF-16 decoder, then again as a UTF-8 BOM | `xp_parser.e`, `xp_native_parser.e` |
| #159 | the literal-mode child parsed the file as declarations and gave no text back | 3 files + new `xp_literal_check_handler.e` |

## 🧪 Checks for every fix (assertions build first, then normal)

| Check | Result for each of the 5 PRs |
|---|---|
| ✅ DLL build + smoke test | ok ×2 |
| ✅ **Test 1, W3C output** | only that issue's cases changed, all to "right" |
| ✅ W3C accept/reject through the DLL (2,585) | identical |
| ✅ Jenkins W3C stage, run locally | 0 failed, 0 errors, 0 skipped |
| ✅ External files lane | 247 / 247 |
| ✅ Python suite | 206 OK |
| ✅ C# tests vs Expat (4,308) | identical |
| ✅ Dual regression lane | 910 / 910 |
| ✅ Eiffel test matrix | 4 / 4 |
| ✅ Expat's own C tests (for #159) | the same 38 allocator failures as before |
| ✅ GitHub check on each PR (`harness`) | pass |
| 🟡 Jenkins | not run yet |

Extra probes in the repo: public IDs in 4 places (`reports/issue-0157/pubid_probe.py`), BOMs in 10 cases × 4 splits (`reports/issue-0158/bom_probe.py`), the 11 entity-value cases (`reports/issue-0159/literal_probe.py`).

## ⚠️ Problems met on the way (kept separate)

| Problem | Cause | Done |
|---|---|---|
| Xpact-core part of the dual lane not built | ✅ environment: new worktree has no cached Xpact-core | xpact lane run; Xpact-core not touched |
| Test tool reported every case as a crash | ✅ my tool: a relative DLL path | fixed in the tool |
| Merges blocked at first | the permission system wants an explicit OK per merge | ✅ merged after your OK |
| `sync-latest.ps1` would overwrite your `CLAUDE.md` | the repo has its own `CLAUDE.md` | ✅ backed up and restored around every sync |
| My doc script broke 3 rows of the PLAN table (#156, #157 PRs) | ✅ my script inserted rows mid-line | repaired in PR #163; later scripts replace whole rows and check the columns |
| #159: four intermediate versions failed a check | ✅ my changes (details in the #159 report, section 5) | each found by the checks, fixed before the PR |

## 📂 Where everything is

| What | Where |
|---|---|
| Reports (CLAUDE.md format) | `reports/issue-0154`, `issue-0156`, `issue-0157`, `issue-0158`, `issue-0159` |
| Test tool, repro files | `reports/issue-0154/tools`, `reports/issue-0154/mini` |
| Local working copy of the tests | `AlotOfTests/01-w3c-output-comparison/` (`fix-F01-1`, `fix-156` … `fix-159`) |

## 🔁 Jenkins

No answer from the supervisor yet. #146, #148, #151, #153 and #154–#159 stay open until the Jenkins run.

## ➡️ Next

- [x] #154 – #159 fixed and merged into `student-Mass`
- [x] Local folder synced (`e5d59e2`)
- [x] Your own repo (mass-xpact) refreshed
- [ ] Jenkins run, then close #154 – #159
- [ ] The other tests (2–11 in `AlotOfTests`): rerun on `e5d59e2`, then their problems one at a time
