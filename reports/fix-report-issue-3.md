# Fix report: issue #3 (B03), postcondition `final_finished_or_suspended` fails in the GC-suspension test

Issue: [#3](https://github.com/andersoxie/xpact/issues/3)   Branch: `fix/3-start-tag-loop-variant`   Base: `student-Mass` @ `20e6bc3`   Date: 2026-10-20

> **Parser change: needs review by the parser's developer before merging** (pull request checklist). The pull request is left open for that review.

## Summary

| Item | Value |
|---|---|
| B03 question | *Is the code, the contract or the test wrong?* **The contract.** The loop variant in `XP_NATIVE_PARSER.direct_start_tag_attributes` (`src/xp_native_parser.e`) is incomplete. The code and the test are correct. |
| Root cause | On `<root/>`, one loop iteration sets `l_valid := False` without advancing `i`, so the variant `a_end_index - i` does not decrease. With assertions on, the runtime raises "Non-decreasing loop variant". |
| Why it showed up as `final_finished_or_suspended` | With GC suspension on, the parse runs inside `MEMORY.execute_without_collection`, whose `rescue ... retry` **silently swallows** the variant exception. The parse is abandoned, `parsing_status` never reaches `Xml_finished`, and the outer postcondition of `parse` fails instead. |
| Fix | Variant `a_end_index - i` → `a_end_index - i + l_valid.to_integer`. No change to behaviour; the check stays on. |
| Result | All four test matrix cells: "xpact Phase 1 tests: ok", exit 0 |

## Expected results (written before testing)

| # | Command | Expected |
|---|---|---|
| 1 | `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Workbench` | `test_garbage_collection_suspension` no longer fails. Tests after it in `XP_TEST_ROOT.make` never ran before (the runner stops at the first failure), so they may show other, unrelated failures. If none: "xpact Eiffel test matrix: ok", exit 0. |
| 2 | Same with `-BuildMode Finalized` | Same result as 1 |
| 3 | `-AssertionMode Off` (both build modes) | Unchanged: the variant is not checked with assertions off. Exit code not trusted (known `check` problem, `TODO_CODE_REVIEW.md:84-85`). |

## Investigation

### 1. The postcondition is a symptom

`parse` (`src/xp_native_parser.e:737-759`) with `suspend_gc_during_parse = True` runs:

```eiffel
create l_result.put (Xml_status_error)
create l_section.make
l_section.execute (agent parse_status_into_cell (a_input, a_is_final, l_result))
Result := l_result.item
```

The private `parse_with_current_gc_policy` called by the agent has the **same** postcondition `final_finished_or_suspended` (line 918), but that one never failed. Only the outer `parse` did. This suggests the agent never finished.

`XP_GC_CRITICAL_SECTION.execute` calls `MEMORY.execute_without_collection` (EiffelStudio 25.12, `library/base/elks/kernel/memory.e:306-338`):

```eiffel
do
    if not retried then
        ... a_action.call (Void) ...
    else
        ... restore collecting ...
    end
rescue
    retried := True
    retry
end
```

Any exception inside `a_action` is caught and dropped. `l_result` keeps `Xml_status_error`, `parsing_status` keeps its old value, and the outer postcondition fails.

### 2. Diagnostic: let the exception through

In a throwaway worktree (not committed), `XP_GC_CRITICAL_SECTION.execute` was changed to `enter; a_action.call (Void); leave` (no rescue). Then the assertions-on / Workbench cell was run again. The real exception appeared ([fix-issue-3-diagnostic-no-rescue.txt](fix-issue-3-diagnostic-no-rescue.txt)):

```text
XP_NATIVE_PARSER    direct_start_tag_attributes @11
                                           a_end_index - i:
                                           Non-decreasing loop variant or negative value reached.
XP_NATIVE_PARSER    is_directly_emittable_completed_start_tag @4
XP_NATIVE_PARSER    parse_with_current_gc_policy @38
XP_NATIVE_PARSER    parse_status_into_cell @3
PROCEDURE           call @3
XP_GC_CRITICAL_SECTION execute @3
XP_NATIVE_PARSER    parse @5
XP_TEST_ROOT        test_garbage_collection_suspension @18
```

### 3. Diagnostic: it is not about the GC

In the same worktree, the test was also changed to `set_suspend_gc_during_parse (False)`. The same `parse ("<root/>", True)` fails at the same place, now directly from `parse_with_current_gc_policy` ([fix-issue-3-diagnostic-no-gc.txt](fix-issue-3-diagnostic-no-gc.txt)). Both diagnostic changes are in [fix-issue-3-diagnostic.diff.txt](fix-issue-3-diagnostic.diff.txt). The first run used only the `execute` change; the second used both.

### 4. The loop

`direct_start_tag_attributes` (`src/xp_native_parser.e:1159-1251`), outer loop:

```eiffel
from until
    i >= a_end_index or else not l_valid or else l_done
loop
    i := skip_reparse_tag_spaces (a_input, i, a_end_index)
    if i >= a_end_index then
        l_done := True
    elseif a_input.item (i) = '/' then
        l_valid := False                 -- i not advanced
    elseif not l_attributes.is_name_start_character (a_input.item (i)) then
        l_valid := False                 -- i not advanced
    else
        ... attribute: always advances i ...
    end
variant
    a_end_index - i
end
```

For `<root/>`, `a_end_index` = 7 (`>`), and the name loop stops at `i` = 6 (`/`). The outer loop's single iteration takes the `'/'` branch: `l_valid := False`, `i` stays 6, so the variant stays 1. The ISE runtime checks the variant after the body, before the exit condition, and raises the violation. Without the check, the loop would exit correctly on `not l_valid` and return `Void` (not directly emittable), which is the intended result.

So **the code terminates correctly, and the variant does not describe that termination**. Every start tag that ends in `/>` or has an unexpected character after the name hits this when loop assertions are on.

## What changed

`src/xp_native_parser.e`, the outer loop variant of `direct_start_tag_attributes`:

```diff
 				variant
-					a_end_index - i
+						-- Some iterations only set `l_valid' to False without
+						-- advancing `i' (for example at the '/' of "<root/>");
+						-- count that as progress so the variant still decreases.
+					a_end_index - i + l_valid.to_integer
 				end
```

Why this is a valid variant (decreases every iteration, never negative):

| Iteration | `i` | `l_valid` | Change in variant |
|---|---|---|---|
| `'/'` or bad character | unchanged | True → False | −1 |
| attribute parsed | +k (k ≥ 1) | stays True | −k |
| invalid attribute | +k (k ≥ 1) | True → False | −(k+1) |
| end reached (`l_done`) | → `a_end_index` | stays True | to 1, from ≥ 2 |

`i` never goes past `a_end_index` inside the loop (every advance is bounded by it), so `a_end_index - i ≥ 0`, and the variant is ≥ 0.

Not changed: the test, the postcondition, and `XP_GC_CRITICAL_SECTION`. The exception swallowing is reported separately (it can hide other failures in GC-suspended parses).

## Verification

Clone `C:\Users\masou\Desktop\Lia\xpact\xpactGit`, branch `fix/3-start-tag-loop-variant`. EiffelStudio 25.12.9.8922 win64, Visual Studio 18 Community 18.10.3 (MSVC 14.51.36231), Windows PowerShell 5.1. Each cell run separately in a fresh `powershell -NoProfile -ExecutionPolicy Bypass` process; each cell recompiles (`ec -batch -clean`).

| # | Cell (`run_eiffel_test_matrix.ps1 -AssertionMode … -BuildMode …`) | Before (`cada501`, same code as `20e6bc3`) | After (this branch) | Exit before → after |
|---|---|---|---|---|
| 1 | On / Workbench | `final_finished_or_suspended` violated in `test_garbage_collection_suspension` | "xpact Phase 1 tests: ok", "xpact Eiffel test matrix: ok" | 1 → **0** |
| 2 | On / Finalized | not run before (the script stopped at cell 1) | ok | → **0** |
| 3 | Off / Workbench | (exit code not trusted) | ok | → 0 |
| 4 | Off / Finalized | (exit code not trusted) | ok | → 0 |

Expectations 1 and 2 were met. No other test failed after `test_garbage_collection_suspension`, although those tests had never run with assertions on before. Expectation 3: cells 3 and 4 print ok, but in these cells a failing `check` would not change the exit code (known problem), so they are weaker evidence.

Not tested: libexpat adapter, W3C conformance, benchmarks.

Logs:
- Before: [fix-issue-3-before-on-workbench.txt](fix-issue-3-before-on-workbench.txt)
- Diagnostics: [fix-issue-3-diagnostic-no-rescue.txt](fix-issue-3-diagnostic-no-rescue.txt), [fix-issue-3-diagnostic-no-gc.txt](fix-issue-3-diagnostic-no-gc.txt), [fix-issue-3-diagnostic.diff.txt](fix-issue-3-diagnostic.diff.txt)
- After: [On-Workbench](fix-issue-3-after-On-Workbench.txt), [On-Finalized](fix-issue-3-after-On-Finalized.txt), [Off-Workbench](fix-issue-3-after-Off-Workbench.txt), [Off-Finalized](fix-issue-3-after-Off-Finalized.txt)

## How to revert

```powershell
.\student\tools\fix.ps1 revert -Issue 3 -Commit <merged sha>
```
