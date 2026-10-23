# Fix report: issue #68, complete the A01 evidence

Issue: [#68](https://github.com/andersoxie/xpact/issues/68)   Branch: `fix/68-a01-evidence`   Base: `student-Mass` @ `76ac272`   Date: 2026-10-22

## Why

A01 was ticked as done in `student/PLAN.md` on 2026-10-20 ([#18](https://github.com/andersoxie/xpact/issues/18)),
but three items of its "Done when" list in `student/github/issues/01-A01.md`
had no evidence in the repository: the checking tests were not linked, the
change-and-predict exercise was not recorded, and
`student/results/A01-orientation/` did not exist. #18's own checklist (plan
ticked, draft dated, report) was done; A01's evidence was not.

## What changed

| File | Change |
|---|---|
| `student/results/A01-orientation/predictions.md` | New. Predictions for 3 changed inputs, **committed alone before the run** (`fb72a77`) |
| `student/results/A01-orientation/inputs/*.xml` | New. `ok.xml` with one change each: duplicate attribute, `&amp;` in text, root end tag missing |
| `student/results/A01-orientation/actual-output.txt` | New. Event-trace output for `ok.xml`, `rejected.xml` and the 3 inputs |
| `student/results/A01-orientation/README.md` | New. Tests and parser path linked (file and line), predicted vs actual, what the differences mean, how to repeat, limitations |
| `student/github/issues/01-A01.md` | Last three "Done when" items ticked with their evidence |
| `student/PLAN.md` | A01 line points to the notes instead of "go in `results/A01-orientation/`" |
| `reports/README.md` | Row for #68 |

No source code or test was changed.

## Expected results (written before testing)

| # | Check | Expected |
|---|---|---|
| 1 | Order of commits | `predictions.md` is in a commit **before** the commit that adds `actual-output.txt` |
| 2 | Event-trace build, assertions on | `ec` and `finish_freezing` exit 0 |
| 3 | Controls `ok.xml`, `rejected.xml` | Same as the 2026-10-15 trace: ACCEPT 7 events; REJECT 1:15 `mismatched end tag`, 2 events |
| 4 | The 3 changed inputs | Recorded as they come; compared with `predictions.md` (no expectation of all predictions being right) |
| 5 | Relative links in `student/`, `reports/`, `docs/` | 0 broken |
| 6 | `git diff --stat origin/student-Mass` | Only the files above |

## Verification

Clone `C:\Users\masou\Desktop\Lia\xpact\xpactGit`, branch `fix/68-a01-evidence`.
EiffelStudio 25.12 Standard, MinGW gcc backend (workbench), all assertions on.

| # | Command | Actual | Exit | |
|---|---|---|---|---|
| 1 | `git log --format="%h %ci %s" -- student/results/A01-orientation` | `fb72a77 2026-10-22 23:19:57` predictions; the results commit comes after it | 0 | ✅ |
| 2 | `. .\scripts\import_msvc_environment.ps1; ec -batch -clean -config student\baseline\event-trace\xp_event_trace.ecf -target xpact_event_trace; finish_freezing` | `C compilation completed`, `xpact_event_trace.exe` present | 0 | ✅ |
| 3 | `xpact_event_trace.exe ok.xml rejected.xml …` | identical to `student/baseline/walkthrough/trace-output.txt` | 0 | ✅ |
| 4 | same run, 3 changed inputs | 1: REJECT 1:6 `duplicate attribute`, 1 event ✅ · 2: ACCEPT, text in 1 piece, 7 events ❌ (predicted 3 pieces) · 3: REJECT 1:41 `unclosed element`, 6 events ✅ | 0 | recorded |
| 5 | link check (regex over `](...)`, path relative to the file) | 0 broken | - | ✅ |
| 6 | `git diff --stat origin/student-Mass` | the files in "What changed", nothing else | 0 | ✅ |

The trace program exits 0 even for rejected documents (it is a tracing tool;
the verdict is in its output). Full output: [actual-output.txt](../../student/results/A01-orientation/actual-output.txt).

## How to revert

```powershell
.\student\tools\fix.ps1 revert -Issue 68 -Commit <merged sha>
```
