# Report: issue #146, Option A: all W3C cases, no skips, F1–F7 fixed

Issue: [#146](https://github.com/andersoxie/xpact/issues/146)   Branch: `fix/146-option-a-w3c-all-cases`   Base: `student-Mass` @ `ec1705d`   Date: 2026-10-27

> **Option A.** This branch is one way to remove the skipped W3C cases: run every case in a lane where it can be
> judged, and fix what that exposes. Other options are compared in [latest_w3c.txt](latest_w3c.txt) and the PR.

## In short

| | Passed | Failed | Errors | Skipped |
|---|---:|---:|---:|---:|
| Before (Jenkins #70, per build) | 1,727 | 0 | 0 | 858 |
| `--all-cases`, before fixes (off / on) | 2,533 / 2,527 | 51 / 51 | 1 / 7 | 0 |
| **`--all-cases`, after fixes, 30 s (both builds)** | **2,585** | **0** | **0** | **0** |

- ✅ No case is skipped any more. The 858 out-of-profile cases run in four lanes (see below).
- ✅ The new lanes exposed 7 parser problems in the external-entity path, never tested before. All 7 are fixed (F1–F7), one commit each.
- ✅ No regression: the smoke tests, the Eiffel matrix, Python, the native stage, and the C# comparison with Expat (4,308 inputs) all pass.
- ⬜ Jenkins has not run this branch yet; #146 stays open until it has.
- ⚠️ With 10 s per case (the Jenkins default), the assertions build times out on the 3 `pr-xml-*` documents. They take about 16 s each, are accepted at 30 s, and are slow, not wrong. **Fixed separately in [#148](https://github.com/andersoxie/xpact/issues/148)** (PR #149): 0.2 s.
- ✅ **Added 2026-10-27:** Jenkins runs all cases (`run_benchmarks.ps1 -W3cAllCases`), and either-verdict cases are reported apart as "no crash only". See [Jenkins and honest counts](#added-jenkins-runs-all-cases-and-honest-counts).

## Lanes (`scripts/run_w3c_conformance.py --all-cases`)

| Lane | Cases | Program | Pass when |
|---|---:|---|---|
| core (unchanged) | 1,727 | Eiffel harness | W3C verdict |
| legacy-names | 309 | Eiffel harness `--legacy-names` (4th-edition name tables, as `XP_NATIVE_PARSER`) | W3C verdict |
| external-entities | 247 | `tests/native/xpact_w3c_case.c` on the DLL; files loaded with `XML_ExternalEntityParserCreate`, below the suite root only | W3C verdict (nonvalidating) |
| optional-error | 28 | harness, or the DLL checker for entity cases | either verdict; a crash or timeout fails |
| xml-1.1 | 274 | harness, or the DLL checker for entity cases | either verdict; a crash or timeout fails |

Without `--all-cases` the runner is unchanged: 1,727 run, 858 skipped, exit 0 ([default-mode](runs/default-mode/summary.md)). Usage: [`docs/w3c-xml-conformance.md`](../../docs/w3c-xml-conformance.md#all-cases---all-cases).

## Fixes

One commit each. Cause: ✅ confirmed for all.

| | Problem | Test cases | Before | Cause | Fix | After |
|---|---|---|---|---|---|---|
| F1 | an external entity that references itself | `not-wf-ext-sa-001` | crash `0xC00000FD` (off), `0xC0000005` (on) | the entity was marked active only after the resolver ran; child parsers did not see the parent's active entities | mark it before resolving; children inherit `active_entity_names` | REJECT "recursive entity reference" |
| F2 | `%pe;` inside ELEMENT/ATTLIST/NOTATION in an external DTD | 48, incl. `pr-xml-*` (`spec.dtd`), `invalid--005/006`, `rmt-e2e-14`, `invalid-not-sa-022`, `valid-not-sa-003` | REJECT | references inside declarations were never replaced | in an external DTD, replace each reference with its text plus one space each side (4.4.8); the closing `>` may come from the entity; `INCLUDE[` from an entity; external PEs as in Expat | ACCEPT; internal subset still REJECT |
| F3 | the assertions DLL, with two top-level elements in an external entity | `valid-ext-sa-005/006`, `ext01`, `ibm77n16`, `ibm77v04`, `ibm77v10` | silent exit `0xC00000FF` | invariant `document_element_count <= 1` broken: each top-level element was counted | count the first one only | ACCEPT |
| F4 | `standalone="yes"` with an entity declared only externally | `not-wf-sa03`, `ibm32n09`, `ibm68n06` | ACCEPT | where an entity was declared was not recorded | mark external/PE declarations, also those merged from child parsers; the error code is `XML_ERROR_ENTITY_DECLARED_IN_PE` (24) | REJECT |
| F5 | a text declaration without `encoding=` | `dtd07`, `encoding07` | ACCEPT | only version **or** encoding was required | external entities require an encoding; the error code is `XML_ERROR_TEXT_DECL` (31) | REJECT |
| F6 | `<?xml?>` not at the start of an external entity; a 1.0 document using a 1.1 entity | `not-wf-not-sa-002`, `rmt-e2e-38` | ACCEPT | an XML declaration was accepted anywhere in a subset, and any 1.x entity version | only at the start of an external entity (`XML_ERROR_MISPLACED_XML_PI`), version `1.0` only (erratum E38) | REJECT |
| F7 | `ExternalEntityRefHandler` received `base = NULL` | all external-entity cases | NULL | `default_pointer` was passed | pass the native parser's base | the base is set; the checker's workaround fires 0 times |

Full detail, with minimal reproductions: [findings-before-fixes.md](findings-before-fixes.md). Its links point to the original local run folder.

## Verification

Student PC: Windows 11, EiffelStudio 25.12.9.8922, MSVC 19.51, `ISE_C_COMPILER=msc_vc140`, Python 3.14.
The committed source was rebuilt fix by fix from `ec1705d`, and its SHA-256 matches the tested files.

| # | Check | Result | |
|---|---|---|---|
| 1 | `--all-cases`, 10 s | off 2,585/2,585; on 2,582 + 3 timeouts ([summary](runs/after-fixes-10s/summary.md)) | ✅ / ⚠️ |
| 2 | `--all-cases`, 30 s | 2,585/2,585 in both builds, exit 0 ([summary](runs/after-fixes-30s/summary.md), [results](runs/after-fixes-30s/results.tsv)) | ✅ |
| 3 | runner without `--all-cases` | 1,727 passed, 858 skipped, exit 0 ([summary](runs/default-mode/summary.md)) | ✅ |
| 4 | `build_native_eiffel.ps1`, Production and Assertions | `xpact Eiffel DLL smoke: ok` ×2 ([log](logs/build-dlls-final.txt)) | ✅ |
| 5 | `run_eiffel_test_matrix.ps1` (workbench, all assertions including loop invariants) | 4/4 ok ([log](logs/eiffel-matrix-after-fixes.txt)) | ✅ |
| 6 | Python suite | 178 OK ([log](logs/python-after-fixes.txt)) | ✅ |
| 7 | runtime smoke, Windows ABI, chunked CRC (7/7), shim audit | all ok ([logs](logs/)) | ✅ |
| 8 | C# DLL tests against Expat 2.8.1 (#121), 4,308 inputs | the same verdict everywhere; difference table identical to before ([off](logs/compare-xpact-summary.md), [on](logs/compare-xpact_assertions-summary.md)) | ✅ |
| 9 | Jenkins | not run | ⬜ |

**Problem met (environment, kept separate):** the chunked CRC corpus and the shim audit first stopped with `'vswhere.exe' is not recognized`. Cause (✅ confirmed): `vcvars64.bat` needs the Visual Studio Installer folder on `PATH`, and my shell did not have it. With it on `PATH`, both passed.

**Mistake in my own work:** while committing, one `git commit` failed (two message options together), so F1 landed in the F7 commit. Nothing was pushed. I reset the local branch to the tooling commit and redid the fix commits; the final source hash matches the tested files.

## Old edition and optional error details

- [old-edition-cases.tsv](old-edition-cases.tsv): all 309 cases with both verdicts.
  - 4th-edition rules: 309 REJECT, matching the W3C.
  - 5th-edition rules: 302 ACCEPT, 7 REJECT (a second root element).
- [optional-error-cases.tsv](optional-error-cases.tsv): all 28 `TYPE="error"` cases, with xpact's verdict and message. 14 ACCEPT, 14 REJECT, the same in both builds.

## The 2003 `xmlconf` (W3C CVS, `xmlconf.xml` 1.6 of 2003-11-13)

- **Result:** 2,162 cases: 1,570 passed, 302 failed, 290 errors, 0 skipped ([summary](runs/xmlconf-2003/summary.md)).
- **The 290 errors** are files missing from that copy. 143 of them are Edinburgh files that exist in another folder, because that old catalog has no `xml:base`.
- **The 302 failures** are exactly the old name-rule tests. That catalog has no `EDITION` marks, so they are judged with the 5th-edition rules; with the 4th-edition rules, all pass.
- **Recommendation:** use the 2013 suite.

## Added: Jenkins runs all cases, and honest counts

Two commits on this branch, after the first review of option A:

| Commit | Change |
|---|---|
| Report either-verdict W3C cases apart from checked verdicts | `optional-error` and `xml-1.1` passes are counted as `no_crash_only`, not `passed`; they get their own JUnit suite, `w3c-xml-<engine>-no-crash-only`; 5 new runner tests (33 OK) |
| Run all W3C cases in the Jenkins Benchmarks stage | `run_benchmarks.ps1 -W3cAllCases` builds the matching DLL, compiles the checker, and passes `--all-cases`; both Jenkinsfiles switch it on |

**Verification:** the Jenkins Benchmarks stage script was run locally on this branch **plus the #148 fix**, with the default 10 s ([log](runs/jenkins-stage/jenkins-benchmarks-stage.txt), [summary](runs/jenkins-stage/summary.md)). Exit 0.

| JUnit suite | Tests | Failures | Errors | Skipped |
|---|---:|---:|---:|---:|
| `w3c-xml-Finalized` | 2,283 | 0 | 0 | 0 |
| `w3c-xml-Finalized-no-crash-only` | 302 | 0 | 0 | 0 |
| `w3c-xml-FinalizedAssertions` | 2,283 | 0 | 0 | 0 |
| `w3c-xml-FinalizedAssertions-no-crash-only` | 302 | 0 | 0 | 0 |

Same code (option A + #148): Eiffel matrix 4/4 ([log](runs/jenkins-stage/eiffel-matrix-combined.txt)), Python 183 OK ([log](runs/jenkins-stage/python-combined.txt)).

**Without #148**, the assertions build still times out on the 3 `pr-xml-*` documents at 10 s, so merge #149 before, or together with, this PR.

**Problem met (environment, kept separate):** the first local run stopped at the WSL benchmark probe, because WSL is not installed on the student PC ([log](runs/jenkins-stage/jenkins-benchmarks-stage-ATTEMPT1-no-wsl.txt)). The rerun used `-SkipWslC` as its only deviation from Jenkins ([script](runs/jenkins-stage/jenkins-benchmarks-stage-nowsl.ps1)). That run's generated `docs/benchmarks.md` was restored and is not committed.

## Limitations

- The Eiffel API resolver path (`XP_EXTERNAL_ENTITY_RESOLVER`) is not covered by the W3C run.
- The xml-1.1 and optional-error lanes show only "no crash, a clean verdict".
- Canonical output (`OUTPUT`) is not compared.
- F7 passes the reading parser's base; Expat passes the declaring one.
- The F4 marks are not kept with a cached DOCTYPE; not checked.
- The libexpat source suite was not run: there is no Expat source tree on the student PC.

## Revert

One commit per fix. `git revert <sha>` reverts one fix; after a squash merge, use `.\student\tools\fix.ps1 revert -Issue 146 -Commit <merge sha>`.
