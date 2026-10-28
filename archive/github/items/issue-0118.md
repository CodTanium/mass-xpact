# Issue #118: Task: G01 - corpus manifest and 50-100 reviewed W3C cases

Archived from <https://github.com/andersoxie/xpact/issues/118> on 2026-10-28 21:36 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 17:27 |
| Closed | 2026-10-26 17:35 |
| Labels | `type:task`, `D2-guided`, `P0`, `test`, `group:G-verification` |
| Milestone | Week 4 - Input matrix |

## Description

## Task (G01, draft 11)
Build a portable corpus manifest with sources, versions, hashes, dependencies and expectations, starting with 50-100 applicable W3C XML cases (student guide, task register G01; week 4 "an input matrix with reviewed expected outcomes").

## Plan
A reproducible script selects the cases from the official catalog (`xmlconf.xml`, suite 20130923, archive SHA-256 pinned in `scripts/run_w3c_conformance.py`), covering text-, tag- and attribute-heavy inputs, namespaces, encodings and DTD/entities, with both accepted and rejected inputs. Per case: ID, path, SHA-256, size, type, XML version/edition, namespace, external-entity dependency, expected outcome by the guide's table, counted or not (with reason), and today's observed result in both builds.

Selection: **by the student, not reviewed by the supervisor** (the student decided to skip the supervisor review); recorded as such.

## Done when
- [ ] `student/results/G01-corpus/manifest.tsv` + the script + README
- [ ] 50-100 cases across the listed categories; external-entity and XML 1.1 cases marked, not counted
- [ ] Every expected outcome checked against the guide's rules and today's results (both builds)
- [ ] Draft 11 updated; report with verification

## Discussion

### CodTanium, 2026-10-26 17:35: comment

Done in `e30f0e6` (PR #120), verified 2026-10-26 — results: https://github.com/andersoxie/xpact/blob/student-Mass/student/results/G01-corpus/README.md
- [x] `student/results/G01-corpus/manifest.tsv` + `make_manifest.py` + README + summary
- [x] 93 cases: 83 counted (46 accept, 37 reject) across text, tags, attributes, namespaces, encodings, DTD, entities, characters, invalid, largest; 10 marked not counted
- [x] Every expected outcome checked against the guide's table and today's results in both builds (93/93 ok); 5 read by eye
- [x] Draft 11 updated; report `reports/issue-0118/report.md`

Selected by the student, not reviewed by the supervisor (the student's decision).
