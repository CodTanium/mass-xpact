# Issue #153: Dual regression lane: small functional cases on xpact and Xpact-core, whole and chunked, with event traces

Archived from <https://github.com/andersoxie/xpact/issues/153> on 2026-10-28 19:58 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-28 01:26 |
| Closed |  |
| Labels | `type:task`, `group:B-reliable-results`, `test` |
| Milestone | - |

## Description

Plan step 4 checkpoint (newUpdates.txt): elements, attributes, text, malformed
input and chunked input through an xpact adapter and an Xpact-core adapter,
with inspectable event traces.

- scripts/build_implementations.py: new "regression" profile
- benchmarks/dual_regression/: shared root and trace, one adapter per parser
- scripts/run_dual_regression.py/.ps1: builds 4 executables, 61 inputs x every
  chunking (910 runs per build), lifecycle on one reused parser, reports
- tests/python/test_dual_regression.py: 14 tests
- docs/dual-regression-lane.md

Evidence (student PC, 26 Oct): xpact 910/910 in both builds, lifecycle 10/10;
Xpact-core 887/910 (findings 2 and 3). Mutation check: CR normalization undone
-> 21 wrong events caught. Python 192 OK.


Rerun 2026-10-28 on the integrated branch `latest-integrated` (main #150 + #146/#148/#151, @ 2e6de7a): identical results. xpact 910/910 in both builds, lifecycle 10/10; Xpact-core 887/910 (the two Xpact-core behaviours, empty final call and lone-CR chunk, are recorded in docs/dual-regression-lane.md).

First tracked in the student's own repository as CodTanium/mass-xpact#1; included in PR #152 (#151).

## Discussion

### CodTanium, 2026-10-28 01:28: comment

Merged into `student-Mass` as 293918f (PR #152) on 2026-10-28. Local Jenkins Benchmarks stage (10 s per case, both builds): all 2,585 W3C cases, 0 failed, 0 errors, 0 skipped. Details: [reports/latest-2026-10-28](https://github.com/andersoxie/xpact/blob/student-Mass/reports/latest-2026-10-28/README.md). **Kept open until a Jenkins run on `student-Mass` confirms it.**
