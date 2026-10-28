# W3C XML conformance run: 2026-10-27

## ✅ Result at a glance

| Build | Cases | Passed | Failed | Errors | Skipped | Unexpected | Time |
|---|---:|---:|---:|---:|---:|---:|---:|
| Finalized (assertions discarded) | 2,585 | ✅ **1,727** | 0 | 0 | 858 | 0 | 63.5 s |
| FinalizedAssertions (assertions **on**) | 2,585 | ✅ **1,727** | 0 | 0 | 858 | 0 | 62.8 s |

**Every applicable case passes in both builds.** The known-failures list is empty, so no failures were tolerated.

---

## 1. Configuration

| Item | Value |
|---|---|
| Branch / revision | `student-Mass` @ `ec1705d0fe51dc16ccb2131ccc83893c80eaa921` (clean tree) |
| Does **not** include | `main`'s `af320e3` (PR #150, external resources, 1,974-case profile) |
| Suite | W3C `xmlts20130923.zip`, cached in `build/validation-corpora/w3c-xml-20130923/` (SHA-256 checked by the runner) |
| Profile | XML 1.0 fifth edition, namespaces unless `NAMESPACE="no"`, nonvalidating, **no external entities**, binary accept/reject verdicts |
| Builds | `EIFGENs/xpact_benchmarks` (finalized `-keep`, assertions discarded) and `EIFGENs/xpact_benchmarks_assertions` (finalized `-keep`, assertions enabled), both built today by `run_benchmarks.ps1` |
| Toolchain | EiffelStudio 25.12.9.8922 win64, `ISE_C_COMPILER=msc_vc140`, Windows 11 Home 10.0.26200 |
| Python | 3.15.0 (uv): `C:\Users\masou\AppData\Roaming\uv\python\cpython-3.15.0-windows-x86_64-none\python.exe` |
| Timeout | 10 s per case |
| Known failures | `benchmarks/w3c-known-failures.tsv`: header only, 0 rows |

## 2. Commands and results

| # | Command | Result |
|---|---|---|
| 1 | `.\scripts\run_benchmarks.ps1 -OutputDir build\w3c-run-20261027 -Iterations 100 -Repetitions 1 -SkipWslC -SkipNativeXpactC` (output redirected with `*>>`) | ❌ stopped at the first `ec` call: see problem P1 |
| 2 | Same command, without redirection | ⚠️ both builds compiled ✅, then the catalog step crashed: see problem P2 |
| 3 | `python scripts\run_w3c_conformance.py --output-dir build\w3c-run-20261027\w3c-xml-conformance --timeout 10 --known-failures benchmarks\w3c-known-failures.tsv --engine "Finalized=EIFGENs/xpact_benchmarks/F_code/xpact_benchmarks.exe" --engine "FinalizedAssertions=EIFGENs/xpact_benchmarks_assertions/F_code/xpact_benchmarks.exe"` | ✅ exit 0, results as in the table above |

## 3. Evidence (not committed; `build/` is ignored)

- `build/w3c-run-20261027/w3c-xml-conformance/summary.md`, `summary.json`
- `build/w3c-run-20261027/w3c-xml-conformance/results.tsv`: per-case verdicts and timings
- `build/w3c-run-20261027/w3c-xml-conformance/junit.xml`
- `build/w3c-run-20261027/w3c-runner.log`: runner console output

Copy these into `reports/` if they need to be kept as baseline evidence.

## 4. Breakdown

| | Finalized | FinalizedAssertions |
|---|---:|---:|
| Accepted (valid / invalid cases) | 776 | 776 |
| Rejected (not-wf cases) | 951 | 951 |
| Skipped (other versions/editions, external entities, `error` cases) | 858 | 858 |

## 5. Problems found during the run

> These are about the **run script and environment**, not the parser. Each one is kept separate.

### P1: Logging with `*>>` stops `run_benchmarks.ps1` at the first `ec` call
1. **Problem:** the script aborts as soon as EiffelStudio's `ec` starts.
2. **Environment:** Windows PowerShell 5.1, student PC.
3. **Command:** `.\scripts\run_benchmarks.ps1 ... *>> run.log`
4. **Expected:** the build runs, and the output goes to the log.
5. **Actual:** stops immediately.
6. **Error:** `ec.exe : Eiffel Compilation Manager ... NativeCommandError` at `run_benchmarks.ps1:254`.
7. **Investigation:** reran without redirection, and the build went through.
8. **Cause:** *suspected*: PowerShell 5.1 turns native stderr into error records when it is redirected, and the script uses `$ErrorActionPreference = "Stop"`.
9. **Fix:** none. Workaround: don't redirect the output.
10. **Verification:** the run without redirection compiled both builds.

### P2: `run_benchmarks.ps1 -Repetitions 1` crashes after the builds
1. **Problem:** the catalog benchmark step throws an error, so the W3C step is never reached.
2. **Environment:** as above, revision `ec1705d`.
3. **Command:** `.\scripts\run_benchmarks.ps1 -OutputDir build\w3c-run-20261027 -Iterations 100 -Repetitions 1 -SkipWslC -SkipNativeXpactC`
4. **Expected:** the benchmarks run with one repetition, then the W3C lane runs.
5. **Actual:** `MethodArgumentConversionInvalidCastArgument`.
6. **Error:** `Cannot convert argument "collection", with value: "@{Benchmark=catalog-100-items; ...}", for "AddRange" to type "System.Collections.Generic.IEnumerable`1[System.Object]"`
7. **Investigation:** the failing value is one `PSCustomObject`, not an array.
8. **Cause:** *suspected*: with one repetition the function returns a single object, and `List.AddRange` needs a collection. The default `-Repetitions 3` probably doesn't hit this. Not confirmed.
9. **Fix:** none. Workaround: run `run_w3c_conformance.py` directly (command 3).
10. **Verification:** not rerun with `-Repetitions 3`.

### P3: `python` on PATH only opens the Microsoft Store
- `python.exe` in `WindowsApps` is the Store stub (0 bytes). PLAN.md says Python 3.14 was installed (#113), but it isn't on this PC now. Python is available only through uv: 3.15.0 and 3.10.22.
- `run_benchmarks.ps1` needs `python` on PATH. For this run I put uv's 3.15.0 first on PATH for the session only.

## 6. Limits: what this run does not prove

- [ ] Only the **1,727-case** profile. `main` now has PR #150 (**1,974 cases**, external entities). That code isn't on `student-Mass` yet.
- [ ] Binary verdicts only: no canonical output or event-trace comparison.
- [ ] Not the dual lane (Finnian's Xpact-core). That needs `run_dual_w3c.ps1`.
- [ ] Not the native DLL or C ABI paths.

## 7. Next steps

- [ ] Sync `student-Mass` with `main` (#150), then rerun to check the 1,974-case profile.
- [ ] Open Issues for P2 and P3. P1 is optional, as a docs note.
- [ ] Keep the evidence in `reports/` if this run should serve as a baseline.
