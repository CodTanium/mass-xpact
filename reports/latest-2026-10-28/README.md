# W3C report: the latest integrated version (28 October 2026)

> **Branch `latest-integrated`** in `CodTanium/mass-xpact` (the student's own repository).
> Not sent to `andersoxie/xpact`, not merged anywhere, `main` untouched.
> It combines everything that existed on 28 October:
> - `main` with the supervisor's **#150** (local external resources in the W3C suite);
> - the student's **#146** (Option A), **#148** (speed) and **#151** (integration with #150), the same code as PR #152;
> - the **#148 report**, which #152 did not include;
> - the **dual regression lane** (CodTanium/mass-xpact#1), which was uncommitted since 26 October.

## 1. In short

| | Result |
|---|---|
| ✅ W3C, all 2,585 cases, Jenkins stage, **10 s** per case | **0 failed, 0 errors, 0 skipped** in both builds |
| ✅ Cases with a checked verdict | **2,283 per build**: 1,974 core + 309 old-edition |
| ✅ "No crash only" cases (either verdict allowed) | **302 per build**: 28 optional errors + 274 XML 1.1 |
| ✅ External entities through the DLL (Expat API) | **247 / 247** in both builds |
| ✅ No regression elsewhere | Eiffel matrix 4/4 · Python 206 OK · DLL smoke ×2 · native stage ok · Expat comparison identical · dual lane 910/910 |
| ⬜ Jenkins | not run (this branch is not in `andersoxie/xpact`) |

## 2. Where we started → where we are

| Date | Version | Checked | Skipped | Failed / errors |
|---|---|---:|---:|---:|
| 24 Oct | Jenkins #70 (`main`) | 1,727 | 858 | 0 |
| 27 Oct | Option A, before fixes (`--all-cases`) | 2,533 / 2,527 | 0 | 52 / 58 |
| 27 Oct | `main` after the supervisor's #150 | 1,974 | 611 | 0, but the assertions build times out on 3 documents at 10 s, and the DLL crashes on 5 external-entity cases |
| **28 Oct** | **this branch** | **2,283 + 302 no-crash-only** | **0** | **0** |

## 3. The W3C run in detail

Command: the Jenkins Benchmarks stage script (`ci/Jenkinsfile.all-tests`), run locally:
- `python -m unittest ... test_w3c_conformance.py` (41 OK);
- then `run_benchmarks.ps1 -EiffelBuild Finalized,FinalizedAssertions -W3cAllCases`.

The only deviation from Jenkins is `-SkipWslC`: WSL is not installed on the student PC ([script](logs/jenkins-benchmarks-stage-nowsl.ps1), [console](logs/jenkins-benchmarks-stage.txt)).

| Lane | Judged by | Cases | Assertions off | Assertions on | ACCEPT / REJECT |
|---|---|---:|---|---|---|
| core (XML 1.0 5th edition, local external resources, #150) | the W3C verdict | 1,974 | ✅ 1,974 | ✅ 1,974 | 958 / 1,016 |
| legacy-names (editions 1–4, 4th-edition name tables, as the DLL uses) | the W3C verdict | 309 | ✅ 309 | ✅ 309 | 0 / 309 |
| optional-error (`TYPE="error"`) | no crash only | 28 | ✅ 28 | ✅ 28 | 14 / 14 |
| xml-1.1 | no crash only | 274 | ✅ 274 | ✅ 274 | 137 / 137 |
| **Total** | | **2,585** | **2,585** | **2,585** | |

JUnit, as Jenkins would show it: `w3c-xml-<build>` with 2,283 tests, and `w3c-xml-<build>-no-crash-only` with 302 tests. 0 failures, 0 errors, 0 skipped in each ([summary](w3c/summary.md), [per case](w3c/results.tsv)).

The catalog's expected result is adjusted for one case (the supervisor's #150): `rmt-e2e-38`.
- The catalog says REJECT; the profile requires ACCEPT.
- Reason: fourth-edition erratum E10 reverses E38, and XML 1.0 5th edition accepts a 1.x text declaration that uses no 1.1 features.

### External entities through the DLL

The `core` lane loads external files through the Eiffel resolver (#150). The same 247 cases were also run through `xpact.dll` and `xpact_assertions.dll`, with the Expat-API checker `tests/native/xpact_w3c_case.c` and the tool `reports/issue-0151/tools/dll_entity_lane.py`:
- **247 / 247 in both builds** ([summary](dll-entity-lane/summary.json));
- on `main` without #146 and #148, this was 246 + 1 crash (off) and 240 + 4 crashes + 3 timeouts (on): #151, "before 3".

## 4. Other checks (the same commit)

| Check | Result |
|---|---|
| `build_native_eiffel.ps1`, Production and Assertions | `xpact Eiffel DLL smoke: ok` ×2 ([log](logs/build-dlls.txt)) |
| runtime smoke, Windows ABI, chunked CRC (7/7), shim audit (6/6 passes) | ok ([logs](logs/)) |
| `run_eiffel_test_matrix.ps1` (workbench, all assertions) | 4/4 ok ([log](logs/eiffel-matrix.txt)) |
| Python suite | 206 tests OK ([log](logs/python.txt)) |
| C# DLL tests against Expat 2.8.1 (4,308 inputs, #121) | same verdicts; the difference table is identical to the recorded one ([off](logs/compare-xpact-summary.md), [on](logs/compare-xpact_assertions-summary.md)) |
| Dual regression lane | xpact 910/910 in both builds, lifecycle 10/10; Xpact-core 887/910 ([report](../dual-regression-2026-10-28/summary.md)) |

## 5. The 2003 `xmlconf` (W3C CVS, `xmlconf.xml` 1.6 of 2003-11-13), for comparison

| Build | Cases | Checked | No crash only | Failed | Errors |
|---|---:|---:|---:|---:|---:|
| both | 2,162 | 1,491 | 79 | 302 | 290 |

- **290 errors:** files missing from that copy. 143 of them are Edinburgh files whose old catalog has no `xml:base`.
- **302 failures:** the old name-character tests. That catalog has no `EDITION` marks, so they are judged with 5th-edition rules. In the 2013 suite, the same tests pass in the legacy-names lane.
- **Use the 2013 suite;** this one is only a comparison ([summary](xmlconf-2003/summary.md)).

## 6. Problems met during this run (kept separate)

| Problem | Cause | Handling |
|---|---|---|
| `run_benchmarks.ps1` stops at the WSL probe | environment: WSL is not installed on the student PC (✅ confirmed 27 Oct) | `-SkipWslC`, the only deviation from Jenkins |
| `run_benchmarks.ps1` rewrites `docs/benchmarks.md` | by design: the script records its timings there | restored, not committed |
| The native stage needs `vswhere.exe` on `PATH` | environment: `vcvars64.bat` calls it by name | Visual Studio Installer folder put on `PATH` for the run |

## 7. Limitations

- This branch has not run on Jenkins.
- The `xml-1.1` and `optional-error` lanes show only "a clean verdict, no crash".
- Canonical output (`OUTPUT`) is not compared.
- Timings come from one PC (EiffelStudio 25.12, MSVC 19.51); the supervisor's machine uses 25.02 and 19.44.
