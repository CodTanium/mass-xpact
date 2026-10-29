> **Copied 2026-10-27 from the local run folder** `test-runs/2026-10-27-w3c-all-cases/` (before the fixes). Relative links below point to that folder and are not in the repository; the per-case results are in [runs/before-fixes/](runs/before-fixes/summary.md).

# Test run: all 2,585 W3C cases, nothing skipped (27 October 2026)

> **Local only.** Nothing committed, pushed or sent to GitHub. The code changes are uncommitted on the
> local branch `local/w3c-no-skips` in `C:\Users\masou\Desktop\Lia\xpact\w7-smoke`
> (full diff: [local-changes.diff](local-changes.diff)).

## In short

| | Assertions off | Assertions on |
|---|---:|---:|
| Cases | 2,585 | 2,585 |
| **Skipped** | **0** (was 858) | **0** (was 858) |
| Passed | 2,533 | 2,527 |
| Failed (wrong verdict) | 51 | 51 |
| Errors (crash) | 1 | 7 |

- ✅ The 1,727 original cases still pass, in both builds.
- ✅ 309 old-edition cases pass with the 4th-edition name rules that the DLL uses.
- ✅ 28 optional-error cases and 274 XML 1.1 cases: no crash in the normal build.
- ❌ External entities through the DLL: **6 findings** (F1–F6 below). These were never tested before, because the cases were skipped.

## Lanes: how each formerly skipped case is judged

| Lane | Cases | Program | Expected result | Off: pass / fail / error | On: pass / fail / error |
|---|---:|---|---|---|---|
| core (unchanged) | 1,727 | Eiffel `xpact_benchmarks` | W3C verdict | 1727 / 0 / 0 | 1727 / 0 / 0 |
| legacy-names | 309 | Eiffel, `--legacy-names` (4th-edition name tables, as `XP_NATIVE_PARSER` uses) | W3C verdict (written for editions 1–4) | 309 / 0 / 0 | 309 / 0 / 0 |
| external-entities | 247 | new DLL checker `xpact_w3c_case.exe`: external entities and the external DTD loaded with `XML_ExternalEntityParserCreate`, as Expat programs and `xmlwf -p` do | W3C verdict, nonvalidating (valid/invalid → accept, not-wf → reject) | 195 / 51 / 1 | 192 / 51 / 4 |
| optional-error | 28 | Eiffel, or the DLL checker if it has entities | either verdict allowed by the spec; a crash or timeout fails | 28 / 0 / 0 | 28 / 0 / 0 |
| xml-1.1 | 274 | Eiffel, or the DLL checker if it has entities | no XML 1.0 verdict exists; a crash or timeout fails | 274 / 0 / 0 | 271 / 0 / 3 |

(309 + 28 + 274 + 247 = 858. The old reasons split slightly differently: 2 old-edition cases are `error` cases, and 1 VERSION 1.1 case is in xml-1.1.)

## Findings: one problem each (format of `CLAUDE.md`)

Common to all: student PC, Windows 11, EiffelStudio 25.12.9.8922, MSVC 19.51, `ISE_C_COMPILER=msc_vc140`,
code `student-Mass` @ `ec1705d` + the local changes, finalized builds (`xpact.dll`, and `xpact_assertions.dll` with `-keep`).
Command: [`run.ps1`](run.ps1). Per-case results: [w3c/results.tsv](w3c/results.tsv).
None of these is fixed yet; each needs its own investigation.

### F1: a self-including external entity crashes the DLL (stack overflow)
- **Case:** `not-wf-ext-sa-001`: `<!ENTITY e SYSTEM "001.ent">`, and `001.ent` contains `&e;`.
- **Expected:** REJECT (recursive entity). Expat reports `XML_ERROR_RECURSIVE_ENTITY_REF`.
- **Actual:** no verdict; exit `0xC00000FD` (STATUS_STACK_OVERFLOW) with `xpact.dll`, `0xC0000005` (access violation) with `xpact_assertions.dll`.
- **Cause:** ❓ suspected: the DLL does not mark an external entity as open while the handler parses it, so the recursion is never detected.

### F2: a parameter-entity reference inside markup in an external DTD is rejected (44 cases)
- **Minimal:** an external DTD `t.dtd` containing `<!ENTITY % a "b|c">` and `<!ELEMENT h (%a;)*>` is rejected with `not well-formed (invalid token)`, line 2.
- The same happens inside `<!ATTLIST>`, and in a conditional section (`<![ %e; ...`).
- The same DTD **without** the reference is accepted, and `%d;` *between* declarations is accepted.
- **Expected:** ACCEPT. References inside declarations are allowed in the external subset (XML 1.0, §2.8 and WFC "PEs in Internal Subset").
- **Actual:** REJECT in 44 valid or invalid cases in both builds: 36 `invalid token`, 5 `syntax error`, 3 `unclosed token`. This includes the 3 `pr-xml-*` cases (the XML specification itself, `spec.dtd` line 318).
- **Cause:** ❔ unknown.

### F3: the assertions DLL exits silently on an external entity with two elements
- **Minimal:** `<doc>&e;</doc>`, where `t.ent` = `<e/><e/>`.
  - `xpact.dll`: ACCEPT.
  - `xpact_assertions.dll`: no output, exit `0xC00000FF`, no `exception_trace.log`.
  - One element, text only, or `<e></e>` all work.
- **Cases:** 3 in external-entities (`valid-ext-sa-005`, `-006`, `ext01`) and 3 in xml-1.1 (`ibm77n16`, `ibm77v04`, `ibm77v10`). Assertions build only.
- **Cause:** ❔ unknown. Possibly an assertion violation that is not reported; not checked.

### F4: an undeclared entity in a `standalone="yes"` document is accepted (3 cases)
- **Cases:** `not-wf-sa03`, `ibm-not-wf-P32-ibm32n09`, `ibm-not-wf-P68-ibm68n06`.
- **Expected:** REJECT (WFC: Entity Declared; the entity is declared only externally).
- **Actual:** ACCEPT, in both builds.
- **Cause:** ❔ unknown.

### F5: a text declaration without `encoding=` is accepted (2 cases)
- **Cases:** `dtd07`, `encoding07`.
- **Expected:** REJECT (a TextDecl requires EncodingDecl).
- **Actual:** ACCEPT.
- **Cause:** ❔ unknown.

### F6: other accepted not-wf cases (2, may be separate)
- `not-wf-not-sa-002`: a PI target `xml` (in any case) inside an external entity. ACCEPT instead of REJECT.
- `rmt-e2e-38`: an XML 1.0 document referring to an XML 1.1 entity. ACCEPT instead of REJECT.
- **Cause:** ❔ unknown; kept together only until each one is looked at.

### Also found (API difference, not a verdict)
- **F7:** xpact passes `base = NULL` to the `ExternalEntityRefHandler`, although `XML_SetBase` was called. Expat passes the base.
- The checker works around it with `XML_GetBase(parser)`, marked in the code, and counts it (`XPACT_NULL_BASE`).
- **Cause:** ❔ unknown. A workaround in the test program, not a fix.

## Problems in my own work during this run (kept separate)

1. The checker's first version refused every entity. That was F7 (`base` is NULL); fixed in the checker with a labelled workaround.
2. One edit broke a C string literal (a tab and a newline written literally), so the old checker binary ran once. The build error was visible; I fixed it and rebuilt, and the old binary's results were not used.
3. The lanes table also appeared in the normal mode. Fixed: it now appears only with `--all-cases`. Both modes were rerun with the same numbers.

## Regression checks

| Check | Result | |
|---|---|---|
| Runner in normal mode (no `--all-cases`) | 1,727 passed, 858 skipped, exit 0: same as before ([w3c-default-mode/](w3c-default-mode/summary.md)) | ✅ |
| `test_w3c_conformance.py` | 28 tests OK | ✅ |
| Full Python suite | 178 tests OK | ✅ |
| `--legacy-names` on `not-wf-sa-140` | REJECT `invalid name character` (without it: ACCEPT) | ✅ |
| Checker refuses paths outside the suite (`../../x.xml`) | REJECT, entity not opened | ✅ |
| `--all-cases` run twice | same counts both times | ✅ |

## What changed (local, uncommitted)

| File | Change |
|---|---|
| `benchmarks/xp_benchmark_root.e` | new option `--legacy-names` → `set_legacy_name_character_ranges (True)` |
| `tests/native/xpact_w3c_case.c` | **new**: one W3C case through the DLL, with external entities from files below `--entity-root` |
| `scripts/run_w3c_conformance.py` | new opt-in `--all-cases` and `--entity-engine`; lanes; `ANY` expectation; `lane` column in `results.tsv`; lane table in `summary.md`; JUnit class names per lane (core unchanged) |

Normal behaviour (and therefore Jenkins) is unchanged unless `--all-cases` is passed.

## Limitations: what this run does not prove

- **External entities are tested through the DLL path only.** The Eiffel API has a resolver too, but it expects decoded text and does not handle text declarations, so it was not used.
- **The DLL uses 4th-edition name rules.** A few external-entity cases may depend on 5th-edition names; not checked case by case.
- **xml-1.1 and optional-error only show "no crash"**, not a correct verdict.
- **Verdicts only:** canonical output (`OUTPUT` in xmlconf) is not compared.
- **Local run only;** not a Jenkins run.
