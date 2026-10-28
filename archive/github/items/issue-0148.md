# Issue #148: Finding: each internal entity reference costs time proportional to the document (pr-xml 1.1 s, 16 s with assertions)

Archived from <https://github.com/andersoxie/xpact/issues/148> on 2026-10-28 01:33 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-10-27 03:29 |
| Closed |  |
| Labels | `bug`, `type:finding`, `group:C-correctness` |
| Milestone | - |

## Description

## Problem
Each reference to a declared **internal** entity (`&name;`) in content costs time proportional to the whole document. The XML specification document of the W3C suite (`pr-xml-*`, 1,431 references) takes about 1.1 s with assertions off and about 16 s with them on, so Jenkins' 10 s per-case limit is too short for it.

## Environment
Student PC, Windows 11, EiffelStudio 25.12.9.8922, MSVC 19.51 (`msc_vc140`). Finalized builds with assertions off and on. `student-Mass` @ `ec1705d`.

## Command
`EIFGENs\xpact_benchmarks\F_code\xpact_benchmarks.exe --conformance-file <file>`, best of 3.

## Expected
The time grows with the document size only; entity references cost about as much as `&amp;`.

## Actual
| Document | Time |
|---|---:|
| 500 references, 100 KB | 455 ms |
| 500 references, 400 KB | 1,636 ms |
| 2,000 references, 400 KB | 5,923 ms |
| the same with `&amp;` | 86 ms |
| `pr-xml-utf-8.xml` | 1,100 ms |

## Investigation
While internal entity text is parsed, `note_position` gets indexes into that text but treats them as document indexes. For every reference it walks back towards the start of the document (`retreat_position_to`) and then forward again.

## Cause
Confirmed: changing only this removes the slowness.

## Fix
While an internal entity is expanded as content, `note_position` keeps the position of the `&name;` reference. `entity_reference_start_stack` already holds it for text events and errors. External entities are unchanged.

## Verification
In the PR. Not verified on Jenkins yet.

## Discussion

### CodTanium, 2026-10-27 12:45: comment

Integrated with `main` (#150) in #151 / PR #152. The full decision per fix is in the [#151 report](https://github.com/andersoxie/xpact/blob/fix/151-integrate-146-148-with-main/reports/issue-0151/report.md#3-which-fix-was-kept-and-why) (short version: [summary](https://github.com/andersoxie/xpact/blob/fix/151-integrate-146-148-with-main/reports/issue-0151/summary.md)).

The fix is cherry-picked there (`e5cc8f7`). On `main` @ `1714f31` the three `pr-xml-*` cases still time out with assertions on (10 s Eiffel harness, 30 s DLL) on the student PC.

### CodTanium, 2026-10-28 01:28: comment

Merged into `student-Mass` as 293918f (PR #152) on 2026-10-28. Local Jenkins Benchmarks stage (10 s per case, both builds): all 2,585 W3C cases, 0 failed, 0 errors, 0 skipped. Details: [reports/latest-2026-10-28](https://github.com/andersoxie/xpact/blob/student-Mass/reports/latest-2026-10-28/README.md). **Kept open until a Jenkins run on `student-Mass` confirms it.**
