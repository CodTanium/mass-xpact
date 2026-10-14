# Week 2 - Assertions-enabled baseline

Week 2 baseline: follow parser events and run every assertions-enabled test,
recording revision, configuration, commands and known failures.

**Results: [BASELINE.md](BASELINE.md)**

## Contents

| Path | What it is |
|---|---|
| `BASELINE.md` | The baseline report: revision, configuration, commands, results, known failures |
| `run_baseline.ps1` | Runs every step below and writes one log per step |
| `event-trace/` | Small Eiffel program (`XP_EVENT_TRACE` + `XP_TRACE_HANDLER`) that prints every parser event, built with all assertions on |
| `event-trace/inputs/` | Sample documents: the guide's `<book>` example, the first test matrix (`<root/>`, `<root>`, mismatched tags, invalid UTF-8) and a richer document |
| `logs/results.tsv` | One row per step: start time, seconds, exit code, command, log |
| `logs/*.log` | Full output of each step |
| `logs/environment.log` | Tool versions, settings, assertion settings per target, source fingerprint |
| `logs/sources.sha256` | SHA-256 of every source file (the first run was in a checkout without git) |
| `walkthrough/` | The one-accepted / one-rejected walkthrough documents |
| `logs/event-trace-output.txt` | The parser events for each input |
| `logs/xmlconf-*.{txt,tsv}` | W3C conformance summary and per-case results |

## Rerun

From the repository root, in PowerShell:

```powershell
.\student\baseline\run_baseline.ps1                    # everything
.\student\baseline\run_baseline.ps1 -Step event-trace  # one step
```

Steps: `environment`, `event-trace`, `matrix-workbench`, `matrix-finalized`,
`matrix-finalized-keep`, `native-runtime-smoke`, `assertions-dll`, `xmlconf`.
A failing step does not stop the run, because known failures are part of the
baseline. Rows are appended to `logs/results.tsv`, so delete `logs/` first if
you want a clean table.

Trace your own XML file after one run:

```powershell
.\EIFGENs\xpact_event_trace\W_code\xpact_event_trace.exe path\to\file.xml
```

> The logs in `logs/` are from the first run on 2026-10-14 in `Desktop\xpact-student-test`,
> where this folder was called `Assertion enabled tests`. That checkout had the two patches in
> `student/history/patches/` applied. Apply them before rerunning: `run_xmlconf_conformance.ps1`,
> the `msc_vc140` backend and the stderr guards come from them.
