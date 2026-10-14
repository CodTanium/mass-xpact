# Week 2 - 2026-10-12 to 2026-10-16

## Tried
- Ran every assertions-enabled lane and followed the parser events for 7 small documents: [BASELINE.md](../../baseline/BASELINE.md).
- Walked through one accepted and one rejected document: [trace-output.txt](../../baseline/walkthrough/trace-output.txt).
- Made the W3C runner download the pinned suite ZIP, and compared it with the teacher's Python runner.
- Read `exception_trace.log` from the xmlconf run.

## What the evidence shows
- Event trace: events arrive in document order, and rejected documents deliver the events before the error, then stop.
- Invalid UTF-8 (`C3 28`) is accepted.
- B03 postcondition fails in workbench and finalized `-keep`; the runner stops there.
- The "finalized" assertions lane is green only because `-keep` is missing.
- The assertions DLL smoke test crashes, now with `0xC0000028`.
- **53 W3C cases crash xpact with contract violations, and 45 are scored as passes** ([crash folder](../../results/xmlconf-crashes-2026-10-14/)).
- The Python harness fails 1 test on Python 3.10 (csv cannot write NUL).

## Blocked
- The build fixes are not in `main`, and the branches that held them were deleted. They are saved as patches; I need to ask the supervisor how to bring them in.

## Next week
- Agree the main improvement with the supervisor. Apply the patches and rerun the baseline in git (A02). Start B01/B02.
