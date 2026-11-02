# Issue #168: A04 - Verify which library the tests, benchmarks and examples load

Archived from <https://github.com/andersoxie/xpact/issues/168> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-31 05:58 |
| Closed | 2026-10-31 14:13 |
| Labels | `type:task`, `D2-guided`, `P1`, `test`, `investigation`, `group:A-orientation` |
| Milestone | Week 7 - Comparison |

## Description

Student guide task **A04** ([student/github/issues/16-A04.md](../blob/student-Mass/student/github/issues/16-A04.md)), on hold since 2026-10-22 (#66), now resumed.

## Goal
For every runner (tests, benchmarks, packaged examples): the **path and SHA-256 of the xpact DLL that is actually loaded**, in each supported configuration (normal and assertions DLL; workbench, finalized, finalized with assertions for the Eiffel lanes).

## Why
A comparison is only meaningful if it is known which build was measured. Most runners put `build\native-eiffel` first on `PATH`, but Windows looks in the executable's own folder first, so a stale copy there would win without any message. `XML_ExpatVersion()` cannot tell them apart: `xpact.dll` returns `expat_2.8.1`, like Expat.

## Method
Each runner is started under a small debugger (Windows debug API, no admin needed) that records every DLL loaded by every process it starts; the loaded files are then hashed and compared with the expected library.

## Done when
- [x] For each runner: the path and hash of the DLL actually loaded
- [x] Table: configuration -> expected library -> observed library
- [x] Mismatches filed as findings; results in `student/results/A04-loaded-library/`
- [x] The C# P/Invoke smoke test re-run against `build\native-eiffel\xpact.dll`

## Discussion

### CodTanium, 2026-10-31 09:22: comment

## Results 2026-10-31 (PR #181)

16 runners checked under a load watcher; every loaded `xpact.dll` / `xpact_assertions.dll` / `libexpat*.dll` identified by SHA-256.

- ✅ **15** load the expected library (DLL builds, C#, ABI smoke = bridge-only by design, CRC, shim audit, Expat's C tests as Jenkins, Jenkins Benchmarks, large XML, student test 1; examples, package, Python and Eiffel matrix load no DLL)
- ❌ **1**: Expat's C tests without `-XpactLibrary` link the bridge-only DLL → #179
- 🟡 `run_benchmarks.ps1 -Repetitions 1` fails → #180
- 0 unknown or stale DLLs

Details and evidence: [README](https://github.com/andersoxie/xpact/blob/fix/168-a04-loaded-library/student/results/A04-loaded-library/README.md).

Status: results in PR #181, waiting for review. Not closing this issue until the PR is merged.

### CodTanium, 2026-10-31 14:13: comment

Closing: A04 done and merged into `student-Mass` (PR #181, `3032770`). All four boxes met: 16 runners with the path and SHA-256 of every loaded DLL; the configuration → expected → observed table (`student/results/A04-loaded-library/README.md`); the mismatches filed and since fixed (#179 via #182, #180 via #186); C# P/Invoke tests re-run against `build\native-eiffel\xpact.dll` (0 failures). Student decision 2026-10-31: no Jenkins run needed.
