# Issue #28: Finding: loop variant in XP_PARSER.normalized_input fails on every input that contains a CR

Archived from <https://github.com/andersoxie/xpact/issues/28> on 2026-10-26 20:59 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 16:11 |
| Closed | 2026-10-22 12:08 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `D3-advanced`, `P0`, `test`, `regression` |
| Milestone | Week 3 - Failure reporting |

## Description

## Report details

| Item | Value |
|---|---|
| Git commit | `2f0d441633fe036fabf0d972aa68c5e3836c60cd` (`student-Mass`, git clone, no local changes in `src/`, `benchmarks/`, `scripts/`) |
| Input file / SHA-256 | `cr-lf.xml`, 9 bytes `3C 72 3E 0D 0A 3C 2F 72 3E` (`<r>` CR LF `</r>`), SHA-256 `5b7e3147871965a78cccb9a0693be825766ba0125de44acf6f21debcff2a9fed`. Control: `lf.xml`, same without the CR (8 bytes), SHA-256 `7b5783c08d18f9276eea591b0e50210fd77f15d18f829097a98333654d4881c5` |
| Exact command | `EIFGENs\xpact_benchmarks_assertions\F_code\xpact_benchmarks.exe --conformance-file cr-lf.xml` |
| Compiler versions | EiffelStudio 25.12.9.8922 win64 · Visual Studio 18 Community, MSVC 14.51.36231 · Windows 11 Home 10.0.26200 · Windows PowerShell 5.1 |
| Assertions / build mode | Assertions **On**: `benchmarks/xpact_benchmarks.ecf` target `xpact_benchmarks_assertions` (all assertion kinds true), `ec -batch -clean -finalize -keep`, then `finish_freezing` |
| Loaded library | None: `xpact_benchmarks.exe` is a plain Eiffel program; `--conformance-file` calls `XP_PARSER.parse` directly (`benchmarks/xp_benchmark_root.e:63-68`) |
| Callbacks | `XP_NULL_EVENT_HANDLER` (no-op) |
| Chunk sizes | Whole document in one call |
| Expected | `XPACT_CONFORMANCE	ACCEPT`, exit 0 (the document is well formed) |
| Actual | Loop variant violation in `XP_PARSER.normalized_input`, exit 1 |
| Exit status | **1** |

| Input | Assertions off (`xpact_benchmarks`) | Assertions on (`xpact_benchmarks_assertions`) |
|---|---|---|
| `lf.xml` | ACCEPT, exit 0 | ACCEPT, exit 0 |
| `cr-lf.xml` | ACCEPT, exit 0 | **crash, exit 1** |

## Error output

```text
xpact_benchmarks: system execution failed.
Following is the set of recorded exceptions:

-------------------------------------------------------------------------------
Class / Object      Routine                Nature of exception           Effect
-------------------------------------------------------------------------------
XP_PARSER           normalized_input @8    a_input.count - i + 1:
<0000027FD2042808>                         Non-decreasing loop variant or negative value reached.
                                                                         Fail
-------------------------------------------------------------------------------
XP_PARSER           normalized_input @8
<0000027FD2042808>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_PARSER           parse @5
<0000027FD2042808>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_BENCHMARK_ROOT   run_conformance @24
<0000027FD2041588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_BENCHMARK_ROOT   make @2
<0000027FD2041588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_BENCHMARK_ROOT   root's creation
<0000027FD2041588>                         Routine failure.              Exit
-------------------------------------------------------------------------------
```

(Trace from W3C case `not-wf-sa-001`; the 9-byte input gives the same first entry.)

## Observations

- The loop is `src/xp_parser.e:4461-4478`, in the `a_allow_alias` branch of `normalized_input`:

  ```eiffel
  until
      i > a_input.count or has_error or l_needs_copy
  loop
      c := a_input.item (i)
      if c = '%R' then
          l_needs_copy := True        -- i is not changed
      elseif not is_xml_character_code (c.code) then
          set_error ("invalid XML character")
          i := a_input.count + 1
      else
          i := i + 1
      end
  variant
      a_input.count - i + 1
  end
  ```

  When `c = '%R'`, `l_needs_copy` becomes True but `i` is not changed, so the variant does not decrease in that iteration. The exit condition (`l_needs_copy`) still ends the loop, so without assertions the result is correct.
- W3C suite 20130923 with `scripts/run_w3c_conformance.py`, 1,727 applicable cases: with assertions on, **1,357 cases crash here**. All 1,357 files contain a CR byte (0x0D); no file without CR crashes here. With assertions off, the same build has 0 crashes.
- Because almost every W3C file has CR LF line ends, this hides any other assertion failure in the suite. The 53-crash finding from 2026-10-14 (`student/github/issues/21-finding-xmlconf-crashes.md`) cannot be rechecked until this is fixed.
- Same kind of failure as B03 (#3): a loop variant that does not decrease although the loop ends correctly.

## Possible explanation (not confirmed)

The variant does not account for the `l_needs_copy` exit. Either `i` should also advance on CR, or the variant should also decrease when `l_needs_copy` becomes True. Choosing the repair is for the developers; the contract has not been switched off.

## Logs

The W3C run, the 9-byte inputs and the crash list are committed under `student/results/w3c-conformance-2026-10-21/` with the W3C run task.

## Discussion

### CodTanium, 2026-10-21 16:17: comment

The repro and the W3C evidence are now on student-Mass (8850dab, #30): student/results/w3c-conformance-2026-10-21/ (cr-lf.xml, lf.xml, failures.tsv with all 1,357 cases) and reports/error-reports/2026-10-21.md, error 1.

### CodTanium, 2026-10-21 22:48: comment

Regression test added on student-Mass in 1ea242e (test_cr_line_ends_with_deferred_positions). It fails with assertions on until the parser is repaired; a one-line repair is proposed in reports/issue-0028/report.md for the parser's developers. Leaving this issue open.

### CodTanium, 2026-10-21 23:59: comment

**Also through the DLL, 2026-10-22 (#37):** with **no callbacks set**, CR LF, a lone CR, a CR after the root and a CR in an attribute crash `xpact_assertions.dll` (whole document: `cr-crlf/none/whole`, `cr-lone/none/whole`, …). With the B03 fix applied, the trace shows this bug:

```
XP_PARSER  normalized_input @8  a_input.count - i + 1: Non-decreasing loop variant or negative value reached.
```

With **any** callback set the same inputs pass, and the character data is a single LF (`text:\x0a`), exactly as the analysis in `reports/issue-0028/report.md` predicts (only a handler that wants no events reaches the broken loop). 28 crashes of this kind on the B03-fixed DLL.

Data: [results README, finding 5](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/README.md#findings) · [crash example](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/assertions-b03fix/crash-examples/cr-28-cr-crlf_none_whole.txt). Still open: the parser is not repaired.

### CodTanium, 2026-10-22 12:08: comment

Repaired in `d279717` (PR #59). Regression test passes with assertions on; W3C with assertions on: crashes 1,360 -> 47 (the rest are in DTD declaration parsing, listed in reports/issue-0028/w3c-after-fix/).
