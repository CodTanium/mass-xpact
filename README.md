# mass-xpact: my student work on xpact

> **This repository is a full copy of [andersoxie/xpact](https://github.com/andersoxie/xpact)**
> (Anders Persson's project) with its complete history, kept as a record of the work I,
> **Masoud Dehdar ([@CodTanium](https://github.com/CodTanium))**, did on it as a
> student assignment in October 2026. The project itself, its design and its
> original code are Anders Persson's; my work is on the `student-Mass` branch.
> The original project README follows [below](#xpact).

xpact is an XML parser written in Eiffel with Design by Contract, exposed to C
programs through an Expat-compatible API (`XML_Parse` and friends). My assignment
was testing and verification: make the builds reproducible, find and report
failures, and verify fixes with assertions enabled.

### ✅ What I did

| Area | Result |
|---|---|
| **Builds on Windows** | The native Eiffel-backed DLL, smoke tests and test matrix did not build on the student PC. Fixed the include path, the C backend, `PATH` growth and `vswhere` problems, `-keep` for finalized lanes (#2, #4, #7, #10, #48, #51, #53, #55, #73) |
| **Reliable test results** | Failing tests now exit nonzero in every build (B01, #45); a deliberately failing meta-test proves it (B02, #46); one exception no longer stops the remaining tests (#60) |
| **Parser correctness** | Strict UTF-8 and XML characters, UTF-16, name rules, DTD declarations, loops that advance on error (#79), CR handling (#28). W3C XML conformance went from 1,491 / 1,444 passed (236 failed, 47 crashes) to **1,727 / 1,727 in both finalized builds**, assertions off and on, on the student PC |
| **W3C without skips** | All 2,585 W3C XML test cases run, none skipped (was 1,727 run, 858 skipped): 2,283 with a checked verdict + 302 "no crash only", **0 failed, 0 errors** in both builds. Found and fixed DLL crashes with external entities (F1, F3) and a slowdown where each entity reference cost time proportional to the document (XML spec document 16 s → 0.2 s with assertions); integrated with the supervisor's external-resource work (#146, #148, #151, #152, [report](reports/latest-2026-10-28/README.md)) |
| **DLL testing** | A C# test program for the xpact DLL: 3,360 cases across whole-input and chunked parsing, finding three parser bugs (#37 → #38, #39, #40) |
| **Versioning workflow** | Every fix: issue → branch → expected result written first → report with before/after logs → pull request → squash merge, revertable in one commit ([`student/VERSIONING.md`](student/VERSIONING.md), [`student/tools/fix.ps1`](student/tools/fix.ps1)) |

### 📂 Where to look

| Start here | What it holds |
|---|---|
| [`reports/README.md`](reports/README.md) | Every fix: issue, pull request, commit and a report with verification and logs |
| [`archive/github/README.md`](archive/github/README.md) | **All issues and pull requests** of the original repository with every comment (GitHub cannot move them, so they are archived here) |
| [`student/PLAN.md`](student/PLAN.md) | The 10-week plan and its status |
| [`student/notes/weekly/`](student/notes/weekly/) | Weekly notes |
| [`archive/personal-notes/`](archive/personal-notes/README.md) | My working notes from outside git |

Branches: `portfolio` (this page, default) = `student-Mass` + this README and the archive.
`student-Mass` and `main` are unchanged copies of the original repository's branches
(last refreshed 2026-10-28 evening: `student-Mass` @ `d0a4e21`, with the #154 and #156 fixes (PR #160, #161); `main` deliberately left at `de01371`,
the original's `main` is at `1714f31` and is contained in `student-Mass`).
`latest-integrated` is the branch the 2026-10-28 W3C report was built on.

---

# xpact

xpact is an Eiffel XML parser project inspired by Finnian Reilly's Eiffel.org
proposal, "Finding a billion-user project for Eiffel: How DbC catches the
security flaws that Rust misses."

Tagline: **XML parsing, by contract.**

The project goal is to use libexpat as the public reference point while keeping
the parser semantics owned by Eiffel. The C code in `native/` is an ABI bridge:
it exports libexpat-shaped symbols and delegates parsing to Eiffel classes. It
is not intended to become a second C parser.

## Current Status

This checkpoint is a Windows-only Phase 1 preview, not a final drop-in
replacement for libexpat.

Implemented and verified now:

- Eiffel targets explicitly compile with void safety enabled
  (`support="all" use="all"`), using the safe Base precompile.
- Contract-backed temporary garbage-collection suspension for critical parse
  sections.
- XML 1.0 tokenization and entity handling in Eiffel.
- Capability-based external entity resolver policy: xpact does not open files,
  URLs, or sockets by itself.
- A libexpat 2.8.1 public API header surface in `include/xpact.h`.
- A Windows x64 Eiffel-backed `xpact.dll` build path.
- A finalized assertion-enabled `xpact_assertions.dll` tier for contract-audited
  validation runs.
- C ABI smoke tests for public callers and for the private Eiffel bridge.
- A native C benchmark path against the Windows Eiffel-backed DLL.
- A chunked `XML_Parse` CRC harness that compares event digests across buffer
  sizes and can be compiled against xpact or libexpat.
- An upstream libexpat test-suite adapter with explicit green/red parity rows.
- Published benchmark, performance-analysis, and parity documentation.
- W3C XML binary conformance tests in the benchmark lane, with per-case
  reports for both finalized assertion modes and Jenkins publication.
- An opt-in large XML benchmark runner for caller-supplied, pre-decompressed
  real corpora.

The upstream Expat 2.8.1 manifest currently has 399 `START_TEST(...)` entries.
The expected-failure list expands to 86 rows:

- 86 allocator-injection tests are intentionally out of the current Eiffel
  release scope because they exercise libexpat's manual C allocation hook
  contract.

## What Is Left

Before calling xpact a credible drop-in replacement, the project still needs:

- true incremental parsing in the Eiffel parser/session core; the current
  native adapter accepts chunks and now has CRC coverage for replayed character
  data, but it still relies on accumulated-buffer replay rather than a
  suspendable parser session;
- a stronger native-suite gate that reports actual unexpected failures by
  upstream test name, not only the current expected-failure manifest expansion;
- Phase 2 performance work: buffer-backed token slices, lazy materialization,
  string-pool recycling, and a native byte-buffer parse path;
- replacement testing in at least one public application that normally builds
  against libexpat;
- Linux/WSL packaging for an Eiffel-backed `libxpact.so`;
- broader consumer ABI coverage across compilers and build systems;
- a release decision on whether allocator-injection semantics are intentionally
  unsupported or emulated at the C ABI boundary.

## Reading Order

Start here, then read:

1. `docs/article-reading-guide.md` for how the repository maps to the original
   Eiffel.org article and the Design by Contract argument.
2. `docs/phase-1.md` for the full Windows Phase 1 scope.
3. `docs/test-matrix.md` for assertion-on/assertion-off test lanes.
4. `docs/platform-builds.md` for Windows, Linux, and Eiffel .NET build
   preparation.
5. `docs/design-overview.md` and `docs/bon/` for the design map and BON views.
6. `docs/libexpat-api-compatibility.md` for the public C API surface.
7. `docs/libexpat-parity.md` and `adapters/libexpat/parity.tsv` for green/red
   upstream test-suite status.
8. `docs/chunked-parse-crc.md` for incremental parsing verification through
   CRC-32 event digests across chunk sizes.
9. `docs/incremental-shim-audit.md` for the current accumulated-buffer replay
   baseline before the true incremental parser session.
10. `docs/incremental-core-prototype.md` for the isolated Eiffel session
    prototype that starts replacing replay with state-owned parsing.
11. `docs/expat-port-spike.md` for the isolated Expat-processor-style Eiffel
    port experiment.
12. `docs/expat-c-code-investigation.md` for what the original Expat C source
    suggests about incremental parsing and optional low-level C helpers.
13. `docs/benchmarks.md` for same-machine benchmark results.
14. `docs/large-xml-benchmarks.md` for opt-in real-corpus macro-benchmarking.
15. `docs/performance-analysis.md` for the current xpact-vs-libexpat performance
   gap analysis and next optimization priorities.
16. `docs/drop-in-verification.md` for the Jenkins and public-application
   replacement plan.
17. [Jenkins email notifications](docs/jenkins-email-notifications.md) for
   setting recipients for failed and unstable builds.

## Build And Verify

For independent builds of our parser and a pinned Finnian Xpact-core revision,
see [Pinned implementation builds](docs/implementation-builds.md). This first
integration step provides isolated build probes and provenance; shared test
and benchmark execution follows separately.

The first complete comparison path is [the focused dual catalog lane](docs/dual-catalog-lane.md):
`scripts/run_dual_catalog.ps1` qualifies both implementations, then measures only
the finalized, assertion-discarded 100-item catalog configuration.

The [dual W3C lane](docs/dual-w3c-lane.md), `scripts/run_dual_w3c.ps1`, runs the
same applicable conformance cases with both implementations in that configuration
and reports their acceptance/rejection results side by side.

Both lanes are included in the main [Jenkins execution and plots](docs/dual-implementation-jenkins.md)
when `RUN_BENCHMARKS` is enabled.

Compile and run the Eiffel regression matrix, both with and without Eiffel
runtime assertions:

```powershell
.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode All -BuildMode All
```

Build the Windows Eiffel-backed native DLL:

```powershell
.\scripts\build_native_eiffel.ps1
```

Build the optimized assertion tier:

```powershell
.\scripts\build_native_eiffel.ps1 -BuildTier Assertions
```

Run native ABI/link smoke tests:

```powershell
.\scripts\run_native_abi_tests.ps1 -Target Windows
```

Run chunked `XML_Parse` CRC diagnostics:

```powershell
.\scripts\run_chunked_crc_corpus.ps1 -Target Xpact -ParseMode All
```

Audit the current accumulated-buffer incremental shim:

```powershell
.\scripts\run_incremental_shim_audit.ps1 -SkipBuild
```

Refresh the upstream Expat manifest and parity expansion:

```powershell
.\scripts\run_libexpat_adapter.ps1 `
  -Mode Manifest `
  -ExpatSourceDir .\build\libexpat-R_2_8_1\libexpat-R_2_8_1\expat `
  -OutputDir .\build\libexpat-adapter-current `
  -XpactLibrary .\build\native-eiffel\xpact.lib `
  -SkipNativeBuild
```

Package the Windows x64 preview release:

```powershell
.\scripts\package_windows_release.ps1
```

Run benchmarks including the W3C XML conformance suite:

```powershell
.\scripts\run_benchmarks.ps1 -EiffelBuild Finalized,FinalizedAssertions
```

The suite runs by default in both Jenkins benchmark pipelines. See
[W3C conformance benchmarks](docs/w3c-xml-conformance.md) for the supported
profile, offline setup, and detailed reports.

Run the additional Eiffel/GCC comparison inside WSL2 (requires Linux
EiffelStudio in that distribution):

```powershell
.\scripts\run_wsl_benchmarks.ps1 -Distribution Ubuntu
```

See [WSL2 Eiffel/GCC benchmarks](docs/wsl-benchmarks.md) for setup, timing
methodology, and the optional Jenkins lane.

Run opt-in large XML benchmarks with pre-decompressed real XML files:

```powershell
.\scripts\run_large_xml_benchmarks.ps1 -XmlFile C:\data\pubmed\pubmed25n0001.xml
```
