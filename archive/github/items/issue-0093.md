# Issue #93: Pin Xpact-core and add isolated implementation build probes

Archived from <https://github.com/andersoxie/xpact/issues/93> on 2026-10-26 18:53 UTC.

| | |
|---|---|
| State | open |
| Author | andersoxie |
| Created | 2026-10-25 13:53 |
| Closed |  |
| Labels | - |
| Milestone | - |

## Description

Step 1 of the planned dual-implementation test and benchmark integration.

Record the fork URL and exact revision `6c017fb5b6e04fd0ae401bc54bb3c6a3c3bd6676`, prepare verified source with offline reuse, and build independent assertion-enabled finalized probes for xpact and Finnian Reilly's Xpact-core. Record source, toolchain, configuration and executable provenance for each build.

Acceptance:
- Both implementations build independently on Windows x64/MSVC and verify the tiny XML probe's start/end/text events.
- Altered or mismatched core source is rejected; failed preparation/build/publication cannot be reported as a verified pair.
- Builds, helper objects, logs and manifests are isolated by run and implementation.
- Infrastructure failure/retry tests and documented reproduction commands are included.

Local evidence before committing: 24 infrastructure tests passed, and both finalized `-keep` smoke builds passed using EiffelStudio 25.02.9.8723 and MSVC 19.44.35229. Broader functional parity, benchmark execution and native C/.NET adapters belong to later steps.
