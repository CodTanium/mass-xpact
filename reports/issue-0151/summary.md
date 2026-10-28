# #151: summary for the student and the supervisor (2026-10-27)

> **Update 2026-10-28:** all 2,585 W3C cases rerun on the final branch with the Jenkins stage at 10 s:
> 1,974 normal + 309 old-edition cases checked, 28 optional errors + 274 XML 1.1 "no crash only";
> **0 failed, 0 errors, 0 skipped** in both builds; DLL entity lane 247/247. Full report:
> [latest-2026-10-28](../latest-2026-10-28/README.md).

Full report with all data: [report.md](report.md) · Issue: [#151](https://github.com/andersoxie/xpact/issues/151)

The fixes from #146 and #148 were combined with the teacher's latest `main` (#150) on one branch. **Everything passes:** all 2,585 W3C cases in both builds, and the regression suites.

## 1. "The ones that fail: reproduce and fix them"
Failures reproduced on the teacher's `main` on the student PC:

- **Eiffel parser, assertions on:** 3 timeouts (`pr-xml-*`). **#148** fixes them.
- **Native DLL path:** 1 crash with assertions off. With assertions on, 4 crashes plus 3 timeouts.
  - **F1** fixes the stack-overflow crash.
  - **F3** fixes the assertion crashes.
  - **#148** fixes the timeouts.

So #150 and #146 mostly fix **different code paths**: #150 the Eiffel resolver, #146 the Expat-compatible DLL.

**What was kept from which side:**

| Kept | Fixes | Why |
|---|---|---|
| The student's | F1, F3, F7, #148, the `--all-cases` lanes | `main` has nothing equivalent. |
| The teacher's | F2, F4, F5, F6a | He solved the same problems, more generally. The duplicate student code was deleted. |
| Removed | F6b | It was **wrong**: erratum E10 reversed E38, so the teacher's E38 note is correct. |

**Results on the integrated branch:**

| Check | Result |
|---|---|
| W3C, all 2,585 cases | ✅ 2,283 verdicts checked + 302 no-crash-only. 0 failed, 0 errors, in both builds. |
| DLL, 247 external-entity cases | ✅ 247 / 247 in both builds |
| Eiffel test matrix | ✅ 4 / 4 |
| Python tests | ✅ 192 OK, after updating one #146 test to the merged routing |

## 2. "More cases to run as XML 1.0?"
The teacher excludes 611 cases:

| Group | Cases | Status |
|---|---:|---|
| Name-character tests from editions 1–4 | 310 | They have a real W3C verdict under the old rules, so they should count as checked. They already run in the `legacy-names` lane (309 / 309). |
| XML 1.1 | 274 | No XML 1.0 verdict exists, so they stay "no crash only". |
| Optional errors | 27 | The spec allows either verdict. The project needs to decide what xpact *should* do for each one. |

## 3. "Which XML version long term?"
- **Recommendation:** support XML 1.0, 5th edition, only. Keep the 4th-edition name tables just as an Expat-compatibility mode in the DLL. Don't implement XML 1.1.
- **How versions work:** the version is chosen **per document or entity**, not by running parsers in parallel. The spec says a 1.0 parser handles a `version="1.1"` document as 1.0, and xpact already does that.
- ⚠️ **Unverified:** the claims about which other parsers support 1.1 come from older sources (2004–2010). Check current release notes before quoting them as fact.
