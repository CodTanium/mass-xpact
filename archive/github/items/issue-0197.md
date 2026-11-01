# Issue #197: Run the W3C-in-pieces test (test 2) on several cores

Archived from <https://github.com/andersoxie/xpact/issues/197> on 2026-11-01 03:16 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-31 18:40 |
| Closed |  |
| Labels | `test` |
| Milestone | - |

## Description

**Task:** `reports/issue-0165/tools/run.py` (test 2: every W3C document whole vs byte by byte vs split at every size, through xpact.dll and Expat) runs the 2,585 documents one after another through one worker pair. It takes about 20–25 minutes per DLL build, mostly because the DLL re-parses markup from the start on every call (F05-1; measured 2026-10-31: 8 KB of elements byte by byte takes 58 s, Expat 5 ms).

The documents are independent, and the student PC has 6 cores. Running them on N worker pairs in parallel should cut the time several-fold without changing the parser or the results.

**Done when:**
- `run.py --jobs N` runs the cases on N worker pairs (default 1 = today's behaviour)
- the output files (`chunked-<tag>.tsv`, `-summary.json`) keep their format and row order
- a parallel run gives exactly the same per-document results as a sequential run on the same DLL
- the time saved is recorded

The parser's own speed (F05-1) is not part of this task.
