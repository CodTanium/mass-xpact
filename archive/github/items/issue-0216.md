# Issue #216: Website test: <root/>junk gives error 4 instead of 9 (junk after document element)

Archived from <https://github.com/andersoxie/xpact/issues/216> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-11-02 14:19 |
| Closed | 2026-11-02 15:33 |
| Labels | `bug`, `test`, `investigation` |
| Milestone | - |

## Description

## Problem
The website backend test `Invalid_documents_are_rejected(xml: "<root/>junk", expectedCode: 9)` fails: the website worker gets error **4** (invalid token) from `xpact.dll`. Expat gives **9** (junk after document element), and the #124 report says xpact was fixed to give 9.

## Environment
Windows 11, student PC; `student-Mass` @ `1b3c862` (clean, no local changes); .NET 10; `website\backend\native\xpact.dll` copied with `build-dll.ps1 -SkipBuild`.

## Command
`dotnet test website\backend\Xpact.Web.slnx -c Release`

## Expected / actual
Expected 9 (Expat 2.7.3 via `pyexpat`: `9 junk after document element: line 1, column 7`). Actual 4. 18 of 19 tests pass.

## Investigation
- The same failure with the DLLs in `xpactGit\build\native-eiffel` (built 2026-10-31 18:39) and with the #124 build in the `w11-plan` worktree (18:29).
- No commit changed `src/` or `native/` after `32bc80a`.
- Not caused by #215 (the same result on clean `student-Mass`).

## Cause
❔ **Unknown.** Suspected, not confirmed: (a) both DLL copies predate the merged #124 fix (merged 19:41); or (b) the website worker calls the DLL in a way the #124 fix does not cover (handlers set, chunking).

## Next step
Build fresh DLLs from `student-Mass` (`website\scripts\build-dll.ps1` without `-SkipBuild`) and rerun the test.

## Discussion

### CodTanium, 2026-11-02 15:33: comment

Fixed in a375085 (PR #226). Cause confirmed: a stale DLL build plus PreserveNewest skipping an older-dated replacement. Verified: the replacement now reaches bin, and all 20 backend tests pass with fresh DLLs from student-Mass.
