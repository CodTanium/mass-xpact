# Issue #106: Task: finish the open week 2 and week 3 items in PLAN.md

Archived from <https://github.com/andersoxie/xpact/issues/106> on 2026-10-28 01:33 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 14:07 |
| Closed | 2026-10-26 14:09 |
| Labels | `documentation`, `type:task`, `workflow` |
| Milestone | Week 3 - Failure reporting |

## Description

## Task
Finish the unticked items of weeks 2 and 3 in `student/PLAN.md` where the evidence now exists, and say plainly which ones cannot be finished by the student alone.

| Item | Evidence | Action |
|---|---|---|
| Week 2: assertions DLL smoke test crashes (K3, draft 07) | #104 check 2026-10-26: `build_native_eiffel.ps1 -BuildTier Assertions` → `xpact Eiffel DLL smoke: ok` | tick; record resolution in draft 07 |
| Week 2: 53 (later 47) W3C crashes (draft 21) | #104 check: W3C `FinalizedAssertions` 1,727 passed, 0 failed, 0 errors, no crash | tick; record resolution in draft 21 |
| Week 2: "Report the baseline findings" | all sub-items ticked | tick |
| Week 3: #46 Jenkins stage turns red | dropped by the student in #64 | tick as dropped (as the Jenkins precompile item in week 2) |
| Week 2: decision with the supervisor | none recorded | stays open — needs the supervisor |
| Week 3: #35 six labels | still not on GitHub | stays open — needs the supervisor's OK |
| Week 3: project board | `gh` token lacks `read:project` | stays open — the student must run `gh auth refresh -s read:project,project` |

## Done when
- [ ] PLAN.md weeks 2 and 3 updated as above
- [ ] Drafts 07 and 21 record the resolution with the evidence
- [ ] Report with verification in `reports/issue-NNNN/`

## Discussion

### CodTanium, 2026-10-26 14:09: comment

Done in `a39362a` (PR #107), checked on `student-Mass` 2026-10-26:

- [x] PLAN.md weeks 2 and 3: K3 and the W3C crashes ticked as fixed (#80, evidence from #104); "Report the baseline findings" ticked; #46 ticked as dropped (#64)
- [x] Drafts 07 and 21 record the resolution with the evidence
- [x] Report: `reports/issue-0106/report.md`

Still open in weeks 2-3, each needing someone other than the student's tools: the supervisor decision on the main improvement, the 6 missing labels (#35, supervisor's OK), and the project board (`gh auth refresh -s read:project,project`).
