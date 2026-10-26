# Issue #37: Task: C# test program for the xpact DLL (C02, C03, C10 part)

Archived from <https://github.com/andersoxie/xpact/issues/37> on 2026-10-26 11:49 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-21 23:25 |
| Closed | 2026-10-22 00:19 |
| Labels | `type:task`, `group:C-correctness`, `D2-guided`, `P0`, `test` |
| Milestone | Week 5 - Regressions |

## Description

Tests C02, C03 and part of C10 from the task register go through the C API (`XML_Parse`), which the Eiffel test matrix and the W3C runner never use: they call the Eiffel parser directly. So far nothing tested the bridge, the chunk handling in `XP_NATIVE_PARSER` or the callback adapter with these inputs.

**What:** a small C# program, `tests/dotnet/XpactDllTests/`, that loads `xpact_assertions.dll` (or `xpact.dll`) and calls it like a C program, with P/Invoke.

| Group | Task | Inputs |
|---|---|---|
| `c02` | C02 | `<root/>`, `<root></root>`, `<root>hi</root>`, empty, `<root>`, `<root><child></root>`, `<root/>junk` |
| `cr` | #28 | CR LF, lone CR, CR after the root, CR in an attribute |
| `utf8` | C10 (part) | `C3 28`, `C0 AF`, `ED A0 80`, `F4 90 80 80` and the control `C3 A9` in text, attribute, name, comment, PI, CDATA |

Each input × 6 callback sets (none, start, end, start+end, chardata, default) × every chunking (whole, split at every byte, byte by byte) = 3,360 cases. A crash inside the DLL kills only a child process and is recorded.

## Done when
- [x] The program builds with `dotnet build` and its build output stays in `build/` (ignored) _(verified 2026-10-22 at `76ac272`)_
- [x] Expected results are written down before the run (in the program and in the report) _(verified 2026-10-22 at `76ac272`)_
- [x] Full run on `xpact_assertions.dll` and on `xpact.dll`, results in `student/results/dll-tests-2026-10-22/` with revision, DLL hash, commands, results, events (`results.tsv`), known failures and limitations _(verified 2026-10-22 at `76ac272`)_
- [x] Each distinct problem it finds is its own finding issue _(verified 2026-10-22 at `76ac272`)_

## Discussion

### CodTanium, 2026-10-22 00:19: comment

Done in `79f2a29` (PR #41). Verified: builds with 0 warnings, 3,360 cases, full runs on three DLLs repeat case for case. Results: `student/results/dll-tests-2026-10-22/`. Findings filed as #38, #39, #40 (open); evidence added to #3 and #28. The Expat comparison for C03/C10 is still to do (G03).
