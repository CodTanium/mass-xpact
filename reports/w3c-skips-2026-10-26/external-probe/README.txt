Diagnostic external entity probe, 26 October 2026

Purpose: investigate 247 cases excluded solely for ENTITIES metadata using the
current XP_PARSER with All_external_entities and a suite-local file resolver.
This is an isolated diagnostic prototype. It changes no production parser API,
runner selection or CI behavior. Its portable sources were rebuilt and all 247
cases rerun; results below come from that portable build.

From the repository root in Windows PowerShell, with EiffelStudio and Python on
PATH, a Visual Studio x64 C++ installation, and the pinned W3C archive extracted
under build/validation-corpora/w3c-xml-20130923/xmlconf:

  .\reports\w3c-skips-2026-10-26\external-probe\build_probe.ps1

The script imports the repository's MSVC environment helper, builds finalized
with all assertions retained (-finalize -keep), and runs all 247 external cases.
Builds and raw per-case stdout/stderr/result files go under the ignored folder:

  build/w3c-skip-investigation/external-probe-builds/<UTC timestamp>-<unique ID>/

The runner also uses a new unique output directory on each standalone rerun:

  build/w3c-skip-investigation/external-probe-runs/<UTC timestamp>-<unique ID>/

To rerun without rebuilding:

  python reports/w3c-skips-2026-10-26/external-probe/run_probe.py --executable build/w3c-skip-investigation/external-probe-builds/<UTC timestamp>-<unique ID>/

The runner also uses a new unique output directory on each standalone rerun:

  build/w3c-skip-investigation/external-probe-runs/<UTC timestamp>-<unique ID>/project/EIFGENs/probe/F_code/external_probe.exe

The runner returns 0 when the diagnostic campaign completes. Inspect results.json
for wrong verdicts; exit 0 does not assert XML conformance.

Observed: 247 normal binary verdicts, no crashes or timeouts. 171 match the
catalog and 76 differ. Three cases are inconclusive for conformance: two matching
REJECTs depend on missing/reserved 'nul' resources (not-wf-sa-081/-082); the wrong
REJECT for rmt-e2e-18 depends on this prototype's nested relative-base handling.
Excluding those gives 169 matching verdicts and 75 mismatches (33 valid rejects,
32 invalid rejects, 10 not-well-formed accepts). Do not count the two 'nul'
rejections as evidence that the parser detects the intended document defects.

Resolver boundary: raw resource bytes are returned unchanged. File paths are
canonicalized and restricted to the suite directory; network/absolute identifiers
are denied. Every request is recorded on stderr. The resolver anchors every
request to the top document directory. The current resolver interface supplies
no declaration base or parser-enter/exit callbacks, so nested relative identifiers
may resolve incorrectly. It does not decode external-resource encodings or strip
external text declarations before returning bytes. Those failures expose work
needed in a real loader/child-parser integration and are not certified parser
conformance failures in isolation. Missing resource failures are marked explicitly.

Fresh parser per case; the runner reads source documents as raw bytes, uses
namespace processing according to the catalog, and allows ten seconds per case.
General external entities, parameter entities and external subsets were exercised;
241 cases made resolver calls. The remaining six use no resolver callback.
No lifecycle/reuse, resource leak, native ABI or pinned-core claims are made.

results.json contains portable suite-relative paths, full normal stdout/stderr,
expected and actual outcomes, process exit codes and the separate conformance
assessment. build-provenance.json records parser/probe fingerprints, executable
hash, source revision, compiler identity and archive verification. The executable
and build outputs are not included. The original extracted suite bytes were
compared with all files in the verified pinned archive before recording evidence.

The recorded portable executable was built before unique output paths were added;
its actual build location is in build-provenance.json. The sources of the ECF
and both Eiffel classes are unchanged since that build. The final Python runner
was rerun against it after tightening marker/exit consistency and adding unique
campaign directories; all 247 verdicts and all three inconclusive assessments
were unchanged. Matching marker plus inconsistent exit code is a harness error.
Existing explicitly requested output directories are refused, preserving evidence.
