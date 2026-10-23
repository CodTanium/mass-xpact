# A01 orientation: notes

> **Date:** 2026-10-22 · **Issue:** [#68](https://github.com/andersoxie/xpact/issues/68) (completes A01, [#18](https://github.com/andersoxie/xpact/issues/18))
> · **Revision run:** `fb72a77` (= `student-Mass` @ `76ac272` + the predictions commit) · **Build:** workbench, all assertions on

## At a glance

| | Item from the A01 "Done when" list | Where |
|---|---|---|
| ✅ | One accepted document traced event by event | [`ok.xml`](../../baseline/walkthrough/ok.xml): ACCEPT, 7 events ([2026-10-15 trace](../../baseline/walkthrough/trace-output.txt), rerun in [actual-output.txt](actual-output.txt)) |
| ✅ | One rejected document traced, with error and position | [`rejected.xml`](../../baseline/walkthrough/rejected.xml): REJECT at 1:15, `mismatched end tag` (same files) |
| ✅ | The test that checks each result, located and linked | [§1](#1-which-test-checks-each-result) |
| ✅ | A small input changed, outcome predicted before running | [§2](#2-change-and-predict): 3 inputs, **2 of 3 predictions right** |
| ✅ | Notes in `student/results/A01-orientation/` | this page |

**What I learned in one line each**

- 🟢 xpact rejects broken XML as expected for the three changed inputs, with a clear message and a position.
- 🟡 Events already delivered **stay delivered**: a rejected document still produces its start events up to the error.
- 🟡 xpact gave the text `a & b` as **one** text event; my prediction of three pieces (as Expat often does) was wrong. Both are allowed by the API.

## 1. Which test checks each result

Both walkthrough documents are tested **with exactly the same text** in the
custom test runner, [`tests/xp_test_root.e`](../../../tests/xp_test_root.e):

| Document | Test (file:line) | What the test checks | Parser code that decides |
|---|---|---|---|
| `ok.xml` `<root><child id="1">text</child><empty /></root>` | `test_well_formed_callbacks`, [`tests/xp_test_root.e:72`](../../../tests/xp_test_root.e#L72) (input at line 80) | accepted; exactly 7 events in order: `start:root:0`, `start:child:1`, `text:text`, `end:child`, `start:empty:0`, `end:empty`, `end:root` | normal path of `XP_PARSER.parse` |
| `rejected.xml` `<root><child></root>` | `test_mismatched_tag_is_rejected`, [`tests/xp_test_root.e:92`](../../../tests/xp_test_root.e#L92) (input at line 100) | rejected; `last_error` is `mismatched end tag` | `XP_PARSER.close_element`, [`src/xp_parser.e:3852`](../../../src/xp_parser.e#L3852); the error is set at [line 3864](../../../src/xp_parser.e#L3864) |

Both tests are registered at the top of `make` (`run_test (...)`, lines 14-15),
so they run first in every test-matrix lane.

The same "mismatched end tag" rule is also checked for the two other parse
engines in the repository: the incremental session (line 936) and the
Expat-port spike (line 976).

## 2. Change and predict

**Method.** Each input is `ok.xml` with **one** small change. The predictions
were written in [predictions.md](predictions.md) and **committed on their own
before the run** (commit `fb72a77`; see `git log -- student/results/A01-orientation`).
Then the inputs were run once with the event-trace program, output in
[actual-output.txt](actual-output.txt). Predictions written by Claude Code at the
student's request.

### Results

| # | Input (one change to `ok.xml`) | Predicted | Actual | |
|---|---|---|---|---|
| 1 | [duplicate attribute](inputs/change-1-duplicate-attribute.xml) `<child id="1" id="2">` | REJECT, `duplicate attribute`, 1 event | REJECT at 1:6, `duplicate attribute`, 1 event | ✅ |
| 2 | [predefined entity](inputs/change-2-entity.xml) `a &amp; b` | ACCEPT, text in 3 pieces, 9 events | ACCEPT, text `"a & b"` in **1** piece, 7 events | ❌ (pieces) |
| 3 | [root end tag missing](inputs/change-3-no-root-end.xml) | REJECT at end of input, 6 events | REJECT at 1:41, `unclosed element`, 6 events | ✅ |

### What the differences mean

- **#2, the wrong prediction.** I expected the text to arrive in three pieces
  (`"a "`, `"&"`, `" b"`) because Expat often splits character data at entity
  references. xpact joined it into one event. This is **not a bug**: a SAX-style
  API like Expat's may split text anywhere, so callers must join pieces
  themselves. It is a possible **difference from Expat** to keep in mind for the
  comparison in G03. Status: **unknown** what Expat 2.8.1 does with this exact
  input; not run.
- **Positions.** The columns fit **0-based** byte offsets, like Expat: 1:6 is
  where `<child` starts (offset 6), 1:41 is just past the last byte of the
  41-byte input, and 1:15 in `rejected.xml` is where the name `root` in
  `</root>` starts. Status: **suspected** (fits these 3 cases; the code was not
  checked).
- **Delivered events stay delivered.** In #1 and #3 the start events before the
  error were already given to the handler. A caller must be ready to undo work
  when the parse then fails.

## 3. How to repeat this

From the repository root, in Windows PowerShell:

```powershell
. .\scripts\import_msvc_environment.ps1
ec -batch -clean -config student\baseline\event-trace\xp_event_trace.ecf -target xpact_event_trace
Push-Location EIFGENs\xpact_event_trace\W_code; finish_freezing; Pop-Location
EIFGENs\xpact_event_trace\W_code\xpact_event_trace.exe `
  student\baseline\walkthrough\ok.xml student\baseline\walkthrough\rejected.xml `
  student\results\A01-orientation\inputs\change-1-duplicate-attribute.xml `
  student\results\A01-orientation\inputs\change-2-entity.xml `
  student\results\A01-orientation\inputs\change-3-no-root-end.xml
```

| Setting | Value |
|---|---|
| Machine | student Windows 11 PC |
| Compiler | EiffelStudio 25.12 Standard, C backend MinGW gcc (workbench) |
| Assertions | all on (`xp_event_trace.ecf`: precondition, postcondition, check, invariant, loop, supplier_precondition) |
| Library | the Eiffel parser compiled into the program; no DLL is loaded |
| Callbacks | start, end, text (and the other handlers in `xp_trace_handler.e`) |
| Chunks | each file parsed whole, in one call |

## 4. Limitations

- ⚠️ The trace program **exits 0 even when it rejects a document**. It is a
  tracing tool, not a test: the verdict is in its output, not in its exit
  code. The real tests are in `tests/xp_test_root.e`.
- ⚠️ Three changed inputs show how the parser behaves on these cases only;
  they are not a conformance result. The W3C suite is the broader check
  ([w3c-conformance-2026-10-21](../w3c-conformance-2026-10-21/README.md)).
- ⚠️ Only the Eiffel parser was run; the DLL and Expat were not.
