---
title: "Finding: assertions-tier DLL smoke test crashes (0xC0000028, earlier 0xC0000008)"
labels: group:B-reliable-results, D3-advanced, P1, type:finding
milestone: Week 2 - Baseline
---
## Steps to reproduce
1. `.\scripts\build_native_eiffel.ps1 -BuildTier Assertions` (smoke test on, **without** `-SkipSmoke`)

## Expected
The DLL builds and the smoke test passes.

## Actual
In the baseline from 2026-10-14, the DLL built, but the smoke test crashed with exit code `-1073741784` = `0xC0000028` STATUS_BAD_STACK. Earlier notes recorded `0xC0000008` STATUS_INVALID_HANDLE, so the crash code is not stable. CI hides this with `-SkipSmoke`.

## Logs
Attach `assertions-dll.log` from a rerun in this checkout, and record the exit code of several runs.
