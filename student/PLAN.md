# 10-week plan

Based on [`docs/xpact-student-introduction.md`](../docs/xpact-student-introduction.md):
"A proposed ten week plan" and "Suggested student selection". Each task links to
its issue draft in [`github/issues/`](github/issues/). Once the issues exist on
GitHub, tick the boxes here or close the issues.

Week 1 = 2026-10-05. Review with the supervisor at the end of every week, and
write the weekly note in [`notes/weekly/`](notes/weekly/).

## Week 1 – Setup
**Activity:** Learn basic XML, the project structure and the Git workflow. Build with help.
**Bring to review:** Setup notes and one successful example parse.
- [ ] [A01](github/issues/01-A01.md) Learn XML events, contracts, Git and the layout; trace one accepted and one rejected document

## Week 2 – Baseline
**Activity:** Follow parser events and run the assertions-enabled tests.
**Bring to review:** A baseline log with revision, configuration, commands and known failures.
- [ ] [A02](github/issues/02-A02.md) Reproduce assertions-enabled workbench and finalized builds (rerun the baseline in this repo)
- [ ] Report the baseline findings:
  - [ ] [Finalized lane drops assertions (missing `-keep`)](github/issues/04-finding-finalized-keep.md)
  - [ ] [Postcondition `final_finished_or_suspended` fails (B03)](github/issues/05-finding-b03-postcondition.md)
  - [ ] [Test runner stops at the first failure](github/issues/06-finding-runner-stops.md)
  - [ ] [Assertions DLL smoke test crashes](github/issues/07-finding-dll-crash.md)
  - [ ] [Python harness fails on Python 3.10](github/issues/08-finding-python310.md)
- [ ] **Decision:** choose one main improvement and a small input set with the supervisor

## Week 3 – Failure reporting
**Activity:** Learn how the test runner reports failure. Reproduce a deliberately failing test.
**Bring to review:** A bounded failure-reporting fix, or a precise proposal with evidence.
- [ ] [B01](github/issues/09-B01.md) Failing tests must return a nonzero exit status
- [ ] [B02](github/issues/10-B02.md) Deliberately failing meta-tests

## Week 4 – Input matrix
**Activity:** Design small regressions and select 50–100 applicable W3C XML cases with the supervisor.
**Bring to review:** An input matrix with reviewed expected outcomes.
- [ ] [G01](github/issues/11-G01.md) Corpus manifest and 50–100 reviewed W3C cases
- [ ] [Fix xmlconf verdict rules](github/issues/12-xmlconf-verdicts.md)

## Week 5 – Regressions
**Activity:** Run the selected small inputs with different callbacks and chunk boundaries.
**Bring to review:** Repeatable regressions and small bug reproductions.
- [ ] [C02](github/issues/13-C02.md) Malformed final-input cases
- [ ] [C03](github/issues/14-C03.md) Chunk boundaries
- [ ] [C10 (part)](github/issues/15-C10.md) Malformed UTF-8
- [ ] **Decision:** review with the supervisor what can realistically be completed

## Week 6 – One improvement
**Activity:** Pair on one manageable test-framework or verification-script improvement.
**Bring to review:** Before-and-after results and a reviewed change.
- [ ] The improvement chosen in week 2 (B01/B02, the xmlconf verdicts or a C-group regression), reviewed and merged

## Week 7 – Comparison
**Activity:** Compare xpact and libexpat; add more applicable W3C cases as time permits.
**Bring to review:** A table of matches, differences and untested cases.
- [ ] [A04](github/issues/16-A04.md) Verify which library the tests load
- [ ] [G03](github/issues/17-G03.md) xpact vs Expat comparison across chunks

## Week 8 – Consolidate
**Activity:** Consolidate the results and add selected SVG or libxml2 cases. Core integration stays optional.
**Bring to review:** Shared fixtures and comparison output, or documented integration requirements.
- [ ] Shared fixtures and comparison output committed under `results/`
- [ ] Optional: [F01](github/issues/19-F01.md) Core build, [F02](github/issues/20-F02.md) Core runner

## Week 9 – Analyse and draft
**Activity:** Analyse the results and draft the report. Try selected PubMed files if the correctness checks permit.
**Bring to review:** A draft report and result tables tied to specific builds.
- [ ] [Report draft](github/issues/18-report-handover.md) in [`report/`](report/)

## Week 10 – Handover
**Activity:** Demonstrate the work, address review comments and hand it over.
**Bring to review:** Final report, tests, code or proposals, setup guide and follow-up list.
- [ ] [Report, demonstration and handover](github/issues/18-report-handover.md)
- [ ] [A06](github/issues/03-A06.md) All weekly notes and result records complete

## Not in the plan (unless the supervisor asks)
The other tasks in the register (A03, A05, B03–B07, C01, C04–C09, D, E, F03–F09,
G02, G04–G10, H) are context, or work owned by experienced developers. B04 or
B05 is an alternative to B01/B02 if failure accounting turns out to be more useful.
