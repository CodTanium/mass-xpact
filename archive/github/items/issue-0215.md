# Issue #215: Show the testing and project numbers on the website's front page

Archived from <https://github.com/andersoxie/xpact/issues/215> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-11-02 14:14 |
| Closed | 2026-11-02 14:19 |
| Labels | `documentation`, `enhancement` |
| Milestone | - |

## Description

## Problem
The website's front page shows only 4 numbers (W3C cases, verdicts, Expat pairs, builds). The large testing effort (AlotOfTests, #213: about 8 million `XML_Parse` calls, 2 million documents, 0 crashes) and the project's own numbers (PRs, commits, reports) are not visible.

## Change
- `export-data.py` writes `website/data/testing.json`: the AlotOfTests numbers (counted from its TSV files where possible, the rest from its READMEs) and a dated snapshot of the project numbers, each with its source link.
- The API serves it at `/api/results/testing`.
- The front page gets a section "Tested hard" with the numbers as tiles, and a note that they were measured on 2026-10-28 before the fixes.

## Verification
`website\scripts\test.ps1` (backend tests + frontend build) and a look at the page in a browser.

## Discussion

### CodTanium, 2026-11-02 14:19: comment

Done in 0505387 (PR #217). Verified: frontend build passes; the page shows 14 + 7 tiles with the expected values at 1280 px and 390 px, 0 console errors. Backend 18/19; the one failure is pre-existing (#216).
