# Issue #165: Finding: DTD callbacks delivered twice when the input arrives in several pieces (F02-1)

Archived from <https://github.com/andersoxie/xpact/issues/165> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-30 04:08 |
| Closed | 2026-10-31 09:26 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test` |
| Milestone | - |

## Description

> Found by test 2 of the extra test round: every W3C document fed whole, byte by byte, and split at every position, through `xpact.dll` (Expat as control). The verdict never changes; the events do.

| Field | |
|---|---|
| **1. Problem** | When a document arrives in several pieces, some DTD callbacks (`startdoctype`, `entitydecl`, …) are delivered **twice**. 481 W3C documents on 2026-10-28 (`293918f`); still present on `main` = `e5d59e2` |
| **2. Environment** | Windows 11 (student PC); `xpact.dll` and `xpact_assertions.dll` built from `e5d59e2` (EiffelStudio 25.12, MSVC); Python 3.14 ctypes; Expat control `pyexpat` 2.7.3 |
| **3. Command** | feed `<?xml version="1.0"?><!DOCTYPE d [<!ENTITY e "v">]><d/>` with `XML_Parse` in 4 pieces: `<?xml version="1.0"?` · `><!DOCTYPE d [<!ENTITY e "v">` · `]` · `><d/>` (smallest pattern, found by shrinking the byte-by-byte case) |
| **4. Expected** | `xmldecl, startdoctype, entitydecl, enddoctype, start, end`, each once (whole document, and Expat in every mode) |
| **5. Actual** | call 2 delivers `xmldecl, startdoctype, entitydecl`; call 3 nothing; call 4 delivers `startdoctype, entitydecl` **again**, then `enddoctype` |
| **6. Error output** | none; the document is accepted |
| **7. Investigation** | The DLL re-parses the whole buffer on every call and skips the callbacks already delivered (`prepare_callback_replay (delivered_callback_count)`). After a non-final call, `delivered_callback_count := handler.callback_sequence_count` (`src/xp_native_parser.e`). Call 3 re-parses only up to the unfinished DOCTYPE, which yields 1 callback, so the count drops from 3 to 1, below what the application has already received; call 4 then repeats callbacks 2 and 3 |
| **8. Cause** | 🟡 suspected (from the trace above); confirmed only when the fix makes the duplicates go away and changes nothing else |
| **9. Fix** | proposed: the delivered count must never go down (`delivered_callback_count.max (handler.callback_sequence_count)`) |
| **10. Verification** | ⬜ test 2 rerun, the old lanes, Expat's `runtests` |

Test 2 report (local): F02-1 in `AlotOfTests/02-w3c-chunked/README.md`. Related: F05-1 (each call re-parses the whole buffer).

## Discussion

### CodTanium, 2026-10-30 05:47: comment

Fix in PR #166: the count of delivered callbacks can no longer go down. Test 2 (W3C whole vs split vs byte by byte): 1,995 -> 2,438 of 2,585 stable, 0 worse; F02-1 gone. All old lanes and Expat's own C tests unchanged, both builds. Report: [reports/issue-0165/report.md](https://github.com/andersoxie/xpact/blob/6d0db96/reports/issue-0165/report.md). Stays open until merged and Jenkins has run.

### CodTanium, 2026-10-31 09:26: comment

✅ **Jenkins approved.** The fix is in PR #177 (`student-Mass` → `main`, merged as 733688e on 2026-10-31). The supervisor's Jenkins run on it passed all tests with no issues, so the verification this issue was waiting for is done. Closing as completed.
