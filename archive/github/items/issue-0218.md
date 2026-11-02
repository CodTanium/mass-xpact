# Issue #218: Show the AlotOfTests results against Expat on the website's front page

Archived from <https://github.com/andersoxie/xpact/issues/218> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-11-02 14:39 |
| Closed | 2026-11-02 14:42 |
| Labels | `documentation`, `enhancement` |
| Milestone | - |

## Description

## Problem
The front page shows how much testing was done (#215), but not the **results** of the AlotOfTests runs against Expat, nor the improvement measured after the #165 fix (W3C in pieces: 1,995 → 2,438 of 2,585 documents identical).

## Change
`export-data.py` adds a `results` list to `testing.json`, read from the result files (`reports/issue-0165/logs/test2/*-summary.json`, the AlotOfTests TSVs and READMEs); the front page shows it as a third section "Results against Expat".

## Discussion

### CodTanium, 2026-11-02 14:42: comment

Done in a74a43e (PR #219). Verified: frontend build passes; the page shows the 8 result tiles with the values from the result files at 1280 px and 390 px.
