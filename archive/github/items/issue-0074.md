# Issue #74: Finding: native build scripts override the machine's MSVC backend with msc_vc140

Archived from <https://github.com/andersoxie/xpact/issues/74> on 2026-10-26 11:49 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-23 07:54 |
| Closed |  |
| Labels | `type:finding`, `group:B-reliable-results`, `P1`, `build`, `investigation` |
| Milestone | Week 3 - Failure reporting |

## Description

## Problem
`scripts\build_native_eiffel.ps1` (since `eb6fc5d`, #7/#8) and `scripts\run_native_runtime_smoke.ps1` (since `20e6bc3`, #10/#11) always set `ISE_C_COMPILER=msc_vc140` for their compile, overriding the machine's own choice. Before, Jenkins built with whatever backend it had configured.

## Status
**Not seen failing** — Jenkins stopped earlier (include folder, see the companion finding). A risk found while checking every student build change against the Jenkins machine on 2026-10-23.

## Expected / actual
- Expected: a machine that already selects an MSVC backend (`msc`, `msc_vc140`, …) keeps it; only a non-MSVC backend (mingw, or unset) is switched to `msc_vc140` (needed for the `.lnk` link response file).
- Actual: always `msc_vc140`.

## Cause
Confirmed from the code (the two assignments). Whether `msc_vc140` would work on the Jenkins machine is **unknown**.

## Done when
- [ ] Both scripts keep an existing `msc*` value; otherwise use `msc_vc140`; the old value is restored afterwards as now
- [ ] Logic tested for unset, `mingw`, `msc`, `msc_vc140`
- [ ] Both scripts still build on the student PC (where it is unset)
- [ ] Report with verification

## Discussion

### CodTanium, 2026-10-23 12:02: comment

Fix in PR #76. Not seen failing yet; needs the same Jenkins rerun as #73 (see the request there: https://github.com/andersoxie/xpact/issues/73). Stays open until a Jenkins run builds the DLL.
