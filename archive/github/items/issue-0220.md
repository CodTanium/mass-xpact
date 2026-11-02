# Issue #220: Credit the student's work (testing, fixes, website) on the website

Archived from <https://github.com/andersoxie/xpact/issues/220> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-11-02 14:59 |
| Closed | 2026-11-02 15:02 |
| Labels | `documentation`, `enhancement` |
| Milestone | - |

## Description

## Problem
The website does not say who built it or who did the testing and fixes it shows.

## Change
- `site.ts`: the author's name and links in one place.
- Footer (every page): "Testing, fixes and this website by Masoud Dehdar".
- Project page: a "Who built what" section that separates Bsharp's XPact parser from the student's work (test suites, fixes, build/CI work, website), with links to the GitHub profile and the merged PRs.

## Discussion

### CodTanium, 2026-11-02 15:01: comment

Done in c47f685 (PR #221). Verified: frontend build passes; footer and the 'Who built what' section render at 1280 px and 390 px with 0 console errors.
