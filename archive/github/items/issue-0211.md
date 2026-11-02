# Issue #211: Finding: nested entity expansion (billion laughs) is rejected after ~7 s as 'syntax error'; Expat stops it in ~0.1 s

Archived from <https://github.com/andersoxie/xpact/issues/211> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-11-02 10:32 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `investigation` |
| Milestone | Week 8 - Consolidate |

## Description

## Problem
A document whose nested entities expand to 10 MB or more (a "billion laughs" document) is rejected only after **about 7 s**, with code 2 **"syntax error"**. Expat rejects the same document in **about 0.1 s** with its amplification-limit error.

## Environment
- Student PC 2, Windows 11, `student-Mass` @ `22876e9`
- `xpact.dll` production build (SHA-256 `35460E77DDC74083…`), built 2026-11-02 with `scripts/build_native_eiffel.ps1 -BuildTier Production` (EiffelStudio 25.12, `msc_vc140`)
- Reference: CPython 3.15.0 `pyexpat`, `expat_2.8.5`
- Assertions build: **not** measured

## Command
```powershell
python -I laughs.py website\dist\Xpact.Worker.exe website\dist\native\xpact.dll <out>
```
Each document goes through the website worker: `XML_ParserCreate(NULL)`, then one final `XML_Parse`. Test IDs: `laughs-3` … `laughs-8` (3 to 8 levels of 10 references each).

## Expected
Like Expat: reject quickly (well under a second) once the expansion far exceeds the input, with an error that names the cause.

## Actual
| Levels | Input | Expands to | XPact | Time | Expat 2.8.5 | Time |
|---:|---:|---:|---|---:|---|---:|
| 3 | 181 B | 10 KB | accepted | 125 ms | accepted | 0 ms |
| 4 | 225 B | 100 KB | accepted | 209 ms | accepted | 2 ms |
| 5 | 269 B | 1 MB | accepted | 1,257 ms | accepted | 15 ms |
| 6 | 313 B | 10 MB | **rejected, "syntax error"** | **6,990 ms** | rejected, amplification limit | 106 ms |
| 8 | 401 B | 1 GB | **rejected, "syntax error"** | **7,302 ms** | rejected, amplification limit | 100 ms |

XPact times include about 100 ms to start the worker process.

## Error output
- XPact: `{"verdict":"rejected","error":{"message":"syntax error"}}`
- Expat: `limit on input amplification factor (from DTD and entities) breached`

## Investigation
- The time grows with the expansion up to 10 MB, then levels off at about 7 s, so a limit seems to be reached late.
- The parser source was **not** read.

## Cause
❓ **Suspected, not confirmed:** `XP_PARSER` has an expansion limit (`Default_max_entity_expansion_bytes`), but it is reached later than Expat's amplification check and is reported as a syntax error.

## Fix
None in the parser. The website contains it (10 s time limit, 512 MB memory cap, 1 MB input).

## Verification
The website test `Slow_documents_are_stopped_by_the_timeout` passes (the request ends in under 8 s). The parser behaviour is unchanged.

## Links
- Evidence: [reports/issue-0211/](https://github.com/andersoxie/xpact/blob/fix/210-xpact-website/reports/issue-0211) (report, the five documents, `laughs.py`, `results.json`), added in PR #212
- Found by the website's security tests: #210
