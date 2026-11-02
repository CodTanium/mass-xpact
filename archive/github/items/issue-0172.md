# Issue #172: Finding: whole document: no events before an invalid-character error; in pieces xpact gives them, as Expat (F02-2, G03-3)

Archived from <https://github.com/andersoxie/xpact/issues/172> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 06:04 |
| Closed | 2026-10-31 16:09 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `test`, `investigation` |
| Milestone | Week 7 - Comparison |

## Description

## Problem
Parsed **whole**, `o-p02fail15` and `o-p02fail27` (UTF-16 documents with a forbidden character, e.g. U+0011, inside `<doc>`) give **no events** before the error. Fed in pieces of 1-3 bytes, xpact delivers `start doc` first, as Expat does in every mode. This is F02-2 of the W3C-in-pieces test (#165 report: 139 documents behave like this).

| Field | |
|---|---|
| **Environment** | Windows 11 (student PC), branch `fix/169-g03-expat-chunk-comparison` @ `f985102` (= `student-Mass`, = `main` + #166). `xpact_assertions.dll` (SHA-256 `9d1f30aa84eec3da…`) and `xpact.dll` (`aaf5d1d297b083de…`), MSVC finalized builds, **identical results**. Reference: `libexpat.dll` Expat 2.8.1 (`R_2_8_1`, MSVC Release, `36a2532e2181ab8b…`). Python 3.14.0. Both DLLs driven by the same ctypes harness, same settings (namespaces as in the catalog, local external entities, `XML_PARAM_ENTITY_PARSING_ALWAYS`). |
| **Found by** | G03 (#169): the 93 G01 cases (#118) through xpact and Expat 2.8.1, `XML_Parse` and `XML_ParseBuffer`, whole and in chunks of 1, 2, 3, 7, 64, 1024 bytes |
| **Expected** | `start doc`, then the error (Expat 2.8.1, every chunking) |
| **Actual** | whole: no events, error 4 at 1:0; chunks of 1-3 bytes: `start doc`, error 4. Traces: [o-p02fail15](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/o-p02fail15.json), [o-p02fail27](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/runs/assertions/differences/o-p02fail27.json) |
| **Error output** | none; the verdict is right |
| **Investigation** | 8 of 14 configurations differ from Expat (whole and 7, 64, 1024 byte chunks, both API calls); xpact is not the same in all chunkings, Expat is. |
| **Cause** | ❔ **unknown**. 🟡 suspected: characters are checked over the whole available input before any callback; with little input per call the check reaches the bad character only after the start tag was delivered. |
| **Fix** | none yet |
| **Verification** | not yet; rerun `compare.py` and check that these cases become `match` and nothing else changes |

**Command:**
```powershell
python -I student\results\G03-comparison\compare.py --tag assertions --xpact-dll build\native-eiffel\xpact_assertions.dll
python -I student\results\G03-comparison\compare.py --tag normal --xpact-dll build\native-eiffel\xpact.dll
```

Related: #123 (no events before a malformed-UTF-8 error; another input, maybe the same cause); #165 report section 6. Results: [G03 README](https://github.com/andersoxie/xpact/blob/fix/169-g03-expat-chunk-comparison/student/results/G03-comparison/README.md).

## Discussion

### CodTanium, 2026-10-31 13:46: comment

Started on branch `fix/172-whole-document-events-before-char-error` (from `student-Mass` @ `5af2321`). Investigation in `reports/issue-0172/report.md`.

**Cause: confirmed.** `normalized_input` (`src/xp_parser.e`) checks every character of the **whole** input before parsing and stops at the first forbidden one, so a whole document fails before its first callback.
- Probe (`reports/issue-0172/tools/probe.py`, 7 documents: content, after a child, attribute, comment, before and after the root, UTF-16 like o-p02fail15): xpact **split right before the character** gives exactly Expat 2.8.1's events in all 7; xpact whole gives none. Production and assertions DLLs give identical results.
- G03 baseline unchanged from the committed run (same 34 differences; o-p02fail15/27 "events differ").

**Planned fix:** treat the forbidden character as the end of the input received so far: parse the text before it as a non-final piece, then raise error 4. Document path of the native DLL only at first. The error position (1:0 vs Expat's column) stays with #171/#122.

No parser change yet.

### CodTanium, 2026-10-31 16:09: comment

Fixed in #192, squash-merged into `student-Mass` as `b069ffb` (its title says "Record the #172 baseline…" because GitHub took the first commit's title; the commit contains the fix, `src/xp_parser.e` + `src/xp_native_parser.e`, identical to the tested `3462eb8`).

When the up-front character check stops a document parse, the DLL now parses the text in front of the character as a non-final piece and then reports error 4, as Expat.

Verified (both builds identical; report `reports/issue-0172/report.md`):
- probe 7/7 events = Expat, whole and split
- G03: o-p02fail15 / o-p02fail27 events now match; xpact stable in 92/93 ways (= Expat, was 90)
- W3C in pieces: 2,438 → **2,561** stable, 0 worse
- C# DLL tests vs Expat 2.8.1: 1,079 → **3,423** identical, 0 worse in any field
- W3C verdicts (2,585) and output test (399/432) identical per case; W3C benchmark stage 2,283 + 302, 0 failed; Expat runtests same 38; Eiffel matrix 4/4; Python 210 OK (also after the merge)

Left: the UTF-16 error column (1:5 vs 1:6) → #171. Closed after the local check (student decision 2026-10-31).
