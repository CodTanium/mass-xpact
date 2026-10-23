# xmlconf: xpact.exe crashes with contract violations

Found: 2026-10-15, by reading `exception_trace.log` (EiffelStudio appends every
crash to this file) and `xmlconf-results.tsv` from the 2026-10-14 baseline.
Issue draft: [`21-finding-xmlconf-crashes.md`](../../github/issues/21-finding-xmlconf-crashes.md).

## Configuration
Revision: the Desktop checkout without git (source fingerprint `e2c5eafe…` in
`student/baseline/logs/environment.log`) = `main` + both patches in `student/history/patches/`.
Build: `xpact.ecf` target `xpact`, workbench, all assertions on.
Command: `scripts\run_xmlconf_conformance.ps1`, which runs `xpact.exe --parse-file <case>` for every case.

## Observations
- **53 of 2,168 cases** end in `xpact: system execution failed` with an Eiffel contract violation, not a parse error.
- The runner treats any nonzero exit as REJECT. So **45 crashing `not-wf` cases are scored as "pass"**, and 8 crashing `valid` cases as an ordinary FAIL.
- 8 distinct crash sites ([`crashes.tsv`](crashes.tsv) lists every case):

| Cases | Crash site | Contract | Nature |
|---:|---|---|---|
| 11 | `XP_PARSER.parse_attlist_declaration @16` | `index_in_bounds` | loop invariant violated |
| 10 | `XP_PARSER.parse_content_particle @43` | `index_in_bounds` | loop invariant violated |
| 10 | `XP_PARSER.parse_attlist_declaration @18` | `l_end - i` | loop variant not decreasing / negative |
| 7 | `XP_PARSER.parse_attlist_default_value @7` | `index_in_bounds` | loop invariant violated |
| 6 | `XP_PARSER.normalized_input @8` | `a_input.count - i + 1` | loop variant not decreasing / negative |
| 5 | `XP_PARSER.parse_content_particle @12` | `a_end_index - i + 2` | loop variant not decreasing / negative |
| 2 | `XP_PARSER.put_external_entity @4` | `system_id_not_empty` | precondition violated |
| 2 | `PLAIN_TEXT_FILE.read_stream @2` (from `FILE`) | `is_readable` | precondition violated |

- The 8 crashing **valid** documents are `ibm-valid-P03-ibm03v01`,
  `ibm-1-1-valid-P03-ibm03v05`, `rmt-026` to `rmt-029` (all `normalized_input`), and
  `ibm-valid-P11-ibm11v01` and `ibm11v02` (`put_external_entity`).
- `exception_trace.log` contains 110 traces: 106 from `xpact.exe` (53 cases × 2 xmlconf runs)
  and 4 from `xpact_tests.exe` (the known `final_finished_or_suspended` postcondition, B03).

## Possible explanations (not confirmed)
- The six `normalized_input` cases are all line-end / whitespace tests (production P03,
  and XML 1.1 line ends in rmt-026 to rmt-029). This may point at end-of-line normalization.
- Most other sites are DTD declaration loops (ATTLIST, content particles) running past
  the end of malformed declarations.
- With assertions **off**, these loops may run out of bounds silently instead of stopping.
  That is worth testing, because production builds may not have the contracts.

## Next steps
1. Reproduce one case per crash site with the current build:
   `.\EIFGENs\xpact\W_code\xpact.exe --parse-file <suite>\<uri>`.
2. Minimize each case to the smallest input that still crashes, and save the exact bytes.
3. Make the runner report crashes as their own category, not as REJECT (B04: "Report crashes and incomplete runs separately").
