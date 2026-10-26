# Issue #13: Finding: XP_GC_CRITICAL_SECTION.execute silently swallows exceptions from GC-suspended parses

Archived from <https://github.com/andersoxie/xpact/issues/13> on 2026-10-26 17:14 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-19 23:02 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `D3-advanced`, `P1`, `investigation` |
| Milestone | Week 2 - Baseline |

## Description

## Report details

| Item | Value |
|---|---|
| Git commit | `20e6bc3` on `student-Mass` (git clone, exact) |
| Input file / SHA-256 | No file: the literal `<root/>` (7 bytes) in `tests/xp_test_root.e:1072`, SHA-256 `6238462c4873df4c50bc1a901ece576b2d166b0156802c88a05a85b1f5d511c7` |
| Exact command | `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Workbench`; diagnostic runs in a throwaway worktree with the change in the Logs section |
| Compiler versions | EiffelStudio 25.12.9.8922 win64 · Visual Studio 18 Community 18.10.3, MSVC 14.51.36231 · Windows 11 Home 10.0.26300 · Windows PowerShell 5.1 |
| Assertions / build mode | Assertions On, Workbench |
| Loaded library | None (`xpact_tests.exe` is a plain Eiffel program) |
| Callbacks | None (`XP_NATIVE_PARSER` created with `make`) |
| Chunk sizes | Whole document, `is_final = True` |
| Expected | An exception raised inside a GC-suspended parse reaches the caller, so the trace names the real failure |
| Actual | The exception is silently dropped. The parse returns `Xml_status_error` with `parsing_status` unchanged, and the only visible symptom is a different, misleading failure (#3: `final_finished_or_suspended`) |
| Exit status | 1 (from the misleading postcondition failure) |

## Cause

`XP_GC_CRITICAL_SECTION.execute` (`src/xp_gc_critical_section.e:80-88`) calls `MEMORY.execute_without_collection` from EiffelStudio's base library (`library/base/elks/kernel/memory.e:306-338`). That routine ends with:

```eiffel
rescue
    retried := True
    retry
end
```

So any exception in the action (contract violation, Void call, I/O error, ...) is caught, collection is restored, and the routine returns normally, as if the action had succeeded.

`XP_NATIVE_PARSER.parse` uses this for every parse with `suspend_gc_during_parse = True` (`src/xp_native_parser.e:745-749`). `XP_PARSER.parse_without_garbage_collection` (`src/xp_parser.e:363-375`) uses the same path, so an exception there becomes a plain `False` result.

## Evidence

In #3 the real exception was a loop-variant violation in `direct_start_tag_attributes` (fixed for review in #12). The test only showed the outer postcondition `final_finished_or_suspended` of `parse`, because the variant exception was swallowed. Replacing `memory.execute_without_collection (a_action)` with `enter; a_action.call (Void); leave` (diagnostic only, not committed) made the real exception appear:

```text
XP_NATIVE_PARSER    direct_start_tag_attributes @11
                    a_end_index - i: Non-decreasing loop variant or negative value reached.
...
XP_GC_CRITICAL_SECTION execute @3
XP_NATIVE_PARSER    parse @5
```

Full logs: `reports/fix-issue-3-diagnostic-no-rescue.txt` and `reports/fix-issue-3-diagnostic.diff.txt` on branch `fix/3-start-tag-loop-variant` (#12).

## Why it matters

- In assertions-on builds, real contract violations inside GC-suspended parses are hidden or show up as unrelated failures.
- In assertions-off and production builds, the parse fails with `Xml_status_error` but the cause is lost, and the parser can be left half-updated (`parsing_status`, buffers).

## Possible fix (not implemented, needs review: it changes library behaviour)

Implement `execute` without `execute_without_collection`: `enter`, call the action, `leave`, and in a `rescue` clause call `leave` (if active) and let the exception propagate (no `retry`). The postcondition `collection_status_preserved` still holds on normal exit. Add a test where the action raises, checking that the exception reaches the caller and that collection is restored.

Related: #3, #12.

## Discussion

### CodTanium, 2026-10-21 23:59: comment

**Possibly related, 2026-10-22 (#37):** through `xpact_assertions.dll`, many contract failures end the process with `0xC0000409` and **no Eiffel trace at all**, while others of the same kind print a full trace. Whether a given case prints a trace is not even stable: 17 of 1,329 crashes had a trace in one run and none in the next.

- 811 of 1,329 crashes without a trace on the current DLL; most are B03 (#3), and they disappear with the B03 fix.
- With the B03 fix, 132 crashes without a trace remain, all with the same trigger as #40 (a chunk ending with `<`), where other cases show `find_markup_declaration_end index_in_bounds`.

That the trace is lost the way this issue describes (an exception swallowed during a GC-suspended parse) is **suspected**, not shown. Data: [results README](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/README.md#repeatability-).
