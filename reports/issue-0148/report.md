# Report: issue #148, internal entity references cost time proportional to the document

Issue: [#148](https://github.com/andersoxie/xpact/issues/148)   Branch: `fix/148-entity-position-speed`   Base: `student-Mass` @ `ec1705d`   Date: 2026-10-27

## In short

| | |
|---|---|
| ✅ Cause | `note_position` treated indexes into internal entity text as document indexes, and walked back and forth over the document for every `&name;` |
| ✅ Fix | while an internal entity is expanded as content, keep the position of the reference (`src/xp_parser.e`, 14 lines) |
| ✅ Speed | XML spec document 1,100 → 79 ms; 2,000 references in 400 KB: 5,923 → 84 ms; with assertions, the XML spec takes 16 s → 0.2 s |
| ✅ No regression | Eiffel matrix 4/4, W3C unchanged, Expat comparison identical, native tests ok |
| ✅ Side effect | an error inside an entity is now reported at the reference, as Expat reports it |
| ⬜ Jenkins | not run |

## Problem (CLAUDE.md format)

1. **Problem:** each reference to a declared internal entity in content costs time proportional to the document size.
2. **Environment:** student PC, Windows 11, EiffelStudio 25.12.9.8922, MSVC 19.51, `msc_vc140`, finalized builds with assertions off and on.
3. **Command:**
   - `python make_inputs.py <folder>`
   - `bash timing.sh EIFGENs\xpact_benchmarks\F_code\xpact_benchmarks.exe <folder> <xmlconf>`
   - ([make_inputs.py](make_inputs.py), [timing.sh](timing.sh))
4. **Expected:** time grows with the document only. `&amp;` costs 86 ms for 2,000 references in 400 KB.
5. **Actual:** see the table below ([before](timing-before-normal.txt)).
6. **Error output:** none; the result was correct, only slow.
7. **Investigation:**
   - Changing the number of references and the document size separately: the time grows with their **product**. Predefined references (`&amp;`) are not affected.
   - In `parse_entity_content`, `note_position (i)` receives indexes into the replacement text.
   - `note_position` compares them with the current document index and calls `retreat_position_to` and later `advance_position_to`. Each of these scans the document between the two indexes.
8. **Cause:** ✅ confirmed. Only this change removes the slowness.
9. **Fix:**
   - A new counter `internal_entity_expansion_depth`, raised around `parse_entity_content` for internal entities in `include_general_entity_in_content`.
   - While it is above 0, `note_position` uses `entity_reference_start_stack`, the outermost reference. Character data events already used that stack.
   - First attempt: the same rule for every entity expansion. It broke the Eiffel test "replacement text preserves prior error checkpoint", which pins the positions of external (resolver) entities ([log](eiffel-matrix-FIRST-ATTEMPT-failed.txt)), so the rule was limited to internal entities.
10. **Verification:** below.

| Document | Before | After, assertions off | After, assertions on |
|---|---:|---:|---:|
| `tiny.xml` (process start) | 84 ms | 69 ms | 68 ms |
| plain 1.6 MB, no entities | 134 ms | 133 ms | 834 ms |
| 500 references, 100 KB | 455 ms | 82 ms | 128 ms |
| 500 references, 400 KB | 1,636 ms | 84 ms | 274 ms |
| 2,000 references, 100 KB | 1,740 ms | 72 ms | 164 ms |
| 2,000 references, 400 KB | 5,923 ms | 84 ms | 320 ms |
| 2,000 × `&amp;`, 400 KB | 86 ms | 89 ms | 290 ms |
| `pr-xml-utf-8.xml` | 1,100 ms | 79 ms | 215 ms |
| `pr-xml-utf-16.xml` | 1,145 ms | 95 ms | 247 ms |

Logs: [after, off](timing-after-normal.txt), [after, on](timing-after-assertions.txt). Before, with assertions on: about 16 s per `pr-xml` document (measured on 26–27 October, #146).

## Verification

| # | Check | Result | |
|---|---|---|---|
| 1 | `run_eiffel_test_matrix.ps1` (workbench, all assertions) | 4/4 ok ([log](eiffel-matrix.txt)) | ✅ |
| 2 | W3C runner, normal mode | 1,727 passed, 858 skipped, exit 0: unchanged ([summary](w3c-default-summary.md)) | ✅ |
| 3 | `build_native_eiffel.ps1`, Production and Assertions | smoke ok ×2 ([log](build-dlls.txt)) | ✅ |
| 4 | C# DLL tests against Expat 2.8.1 (#121), 4,308 inputs | the difference table is identical to before ([off](compare-xpact-summary.md), [on](compare-xpact_assertions-summary.md)) | ✅ |
| 5 | runtime smoke, Windows ABI, chunked CRC (7/7), shim audit (6/6) | ok ([logs](.)) | ✅ |
| 6 | Python suite | OK ([log](python.txt)) | ✅ |
| 7 | error positions inside entities ([positions.txt](positions.txt)), against Expat 2.7.3 (`pyexpat`) | 3 unchanged; `mismatch` goes from line 1 col 8 to **line 4 col 3, the same as Expat** | ✅ |
| 8 | Jenkins | not run | ⬜ |

Separate note, not caused by this fix: in `badchar` (a character reference `&#0;` inside an entity value), xpact reports column 13 and Expat column 31, both before and after.

The native stage runs locally needed the Visual Studio Installer folder on `PATH`, because `vcvars64.bat` calls `vswhere.exe` (environment, see #146).

## Revert

`.\student\tools\fix.ps1 revert -Issue 148 -Commit <merge sha>`
