# Issue #227: Website: test that the worker memory cap stops a document that needs more

Archived from <https://github.com/andersoxie/xpact/issues/227> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-11-02 15:34 |
| Closed |  |
| Labels | `test` |
| Milestone | - |

## Description

## Problem
The worker's memory cap (Windows Job Object, `WorkerMemoryMb`, 512 MB) is set up but never tested with a document that actually reaches it (`website/docs/security.md`: "⬜ not tested").

## Measurement (student PC, fresh DLLs from student-Mass)
| Document | Worker peak memory |
|---|---|
| `<a/>` | ~28 MB |
| 1 MB, 100,000 empty elements | ~59 MB |

## Change
A test with `WorkerMemoryMb = 45`: `<a/>` is still accepted, the 100,000-element document is stopped (not accepted). With the normal cap the same document is accepted, so the cap is what stops it.
