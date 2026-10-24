# Issue #40: Finding: a non-final chunk that ends with '<' crashes xpact_assertions.dll (find_markup_declaration_end index_in_bounds)

Archived from <https://github.com/andersoxie/xpact/issues/40> on 2026-10-24 20:26 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-21 23:57 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `D3-advanced`, `P0`, `test`, `investigation` |
| Milestone | Week 5 - Regressions |

## Description

**1. Problem:** a non-final `XML_Parse` call whose data ends with `<` crashes `xpact_assertions.dll`: an Eiffel loop invariant fails, the runtime panics, and the calling program dies with `0xC0000409`.

**2. Environment:** Windows 11, `student-Mass` @ `42d6b40`, `xpact_assertions.dll` from `build_native_eiffel.ps1 -BuildTier Assertions` (SHA-256 `8cc96794…`), and the same with only the B03 fix applied (`38c2b2c7…`). `xpact.dll` (assertions off) does not crash.

**3. Command:**
```powershell
build\dotnet\XpactDllTests\bin\Release\net10.0\XpactDllTests.exe --only c02-valid/none/split@1 --isolate --verbose
```
That is `XML_Parse(p, "<", 1, 0)` followed by `XML_Parse(p, "root/>", 6, 1)`, no callbacks. Program from #37.

**4. Expected:** ACCEPT, as for the whole document, with no contract violation.

**5. Actual:** the process ends with exit code `-1073740791` (`0xC0000409`) during the first call.

**6. Error output** (full output: [crash example](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/assertions-b03fix/crash-examples/lt-at-chunk-end-c02-valid_none_split_1.txt)):
```
xpact_native_library: PANIC: main entry point vanished ...
XP_PARSER           find_markup_declaration_end @4
                                           index_in_bounds:
                                           Loop invariant violated.      Fail
XP_PARSER           markup_prefix_end @18              Routine failure.
XP_PARSER           incomplete_markup_prefix_start @8  Routine failure.
XP_NATIVE_PARSER    should_defer_reparse_callbacks @9  Routine failure.
XP_NATIVE_PARSER    parse_with_current_gc_policy @26   Routine failure.
XP_NATIVE_PARSER    parse @7  ->  XP_NATIVE_BRIDGE_EXPORT parse @3  ->  XP_NATIVE_LIBRARY_ROOT
```

**7. Investigation:** with the B03 fix, all 672 crashes of the 3,360 cases were classified. **644** have `<` as the last byte of a non-final chunk (`split@1` of any input; splits right before `</r>`, `<!--`, `<?pi`, `<![CDATA[`; every byte-by-byte run). 512 of them show the trace above, **132 show no trace at all**. The other 28 are #28. Because every byte-by-byte run crashes, no byte-by-byte result on the assertions DLL means anything until this is fixed. Whether a crash prints a trace is not stable between runs (17 cases changed).

**8. Cause:** the trigger is **confirmed** (a chunk ends with `<`). In the code it is **suspected** that `find_markup_declaration_end` steps past the end of the available input when the markup so far is only `<`. That the 132 crashes without a trace have the same cause is also **suspected** (the trace may be lost, see #13).

**9. Fix:** none. Parser change, for the parser's developers.

**10. Verification:** a fix is verified when no `split` or `bytes` case crashes in `find_markup_declaration_end` on `xpact_assertions.dll`.

**Logs:** [results README, finding 3](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/README.md#findings) · [assertions-b03fix/results.tsv](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/assertions-b03fix/results.tsv) · [summary](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/assertions-b03fix/summary.txt)
