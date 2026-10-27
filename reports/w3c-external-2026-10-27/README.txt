W3C external-resource campaign, 27 October 2026

Status: passed on the final post-local-root-guard source snapshot.

Fresh Windows x64 finalized builds used EiffelStudio 25.02.9.8723 Enterprise
and MSVC 19.44.35229, with -keep only for the assertion-enabled build. Both
executables have the same recorded source fingerprint. The exact command and
resolved executable paths are in conformance-command.json; build manifests and
five passing directed qualification controls per mode are included separately.

                         Passed  Wrong verdicts  Errors  Skipped  ACCEPT  REJECT
Assertions discarded      1974          0           0      611      958    1016
Assertions retained       1974          0           0      611      958    1016

The runner returned exit 0 with no known-failure allowlist. results.tsv retains
all 5,170 engine/catalog rows using suite-relative paths. additional-cases.tsv
records all 65 additions per mode against their former skipped status; all 130
executions passed. All 3,386 suite files were compared byte-for-byte with the
checksum-verified pinned archive after execution. The previous 1,909-case campaign
under reports/w3c-expanded-2026-10-26 remains separate.

External identifiers resolve from the declaring file, including nested DTDs.
The runner supplies --suite-root with the canonical local xmlconf directory.
The xpact adapters enable local external-resource loading and disable unread
entity skips. Original resource bytes reach the parser without caller-side
transcoding. Absolute/network identifiers, escapes, links and reparse points
are denied. UNC and mapped network suite roots are checked before filesystem
access. Missing, unreadable, denied or changed parsed resources produce exit 2
without an ACCEPT/REJECT marker and cannot pass a malformed XML case.

not-wf-sa-081 and not-wf-sa-082 reject external references in explicit/default
attribute values before resource access. NOTATION and unparsed NDATA identifiers
are declarations, not resource requests. resource-audit.json retains the static
review, including the reserved nul references and the unused platform identifiers.

rmt-e2e-38 retains catalog_expected=REJECT but requires profile ACCEPT for the
exact reviewed document and entity hashes. Fourth Edition erratum E10 explicitly
reverses Second Edition E38; Fifth Edition accepts 1.x version declarations when
the content uses only XML 1.0 features. This entity contains only <foo/>. The
correction requires both input hashes, path and catalog metadata; it is neither
a skip nor a known-failure row. TSV, summary JSON, passing JUnit properties and
dual-engine result schemas retain the correction. e38-edition-correction.json
records the primary sources and an independent Expat 2.7.3 corroboration:
  https://www.w3.org/XML/xml-V10-4e-errata#E10
  https://www.w3.org/TR/2008/REC-xml-20081126/#sec-prolog-dtd
  https://www.w3.org/TR/2008/REC-xml-20081126/#sec-TextDecl

Independent verification:
- Eiffel finalized matrix: 73 routines per assertion mode, 146 executions, 0 failures.
  eiffel-regressions.json/.txt plus input-hash/integrity records retain the
  command, executable hashes and unchanged source/test/ECF inputs. Scenarios
  include token padding, quoted percent, split delimiters, conditional/IGNORE
  bodies, recursion followed by reuse, original positions after expansion,
  raw UTF-16/text declarations and malformed recovery, resumable callback
  suspension during inline PE expansion, nested bases, missing-resource/base
  change/retry, declaration precedence, no-I/O attributes/defaults and cleanup.
- Ordinary benchmark entry point: 65/65 additional cases passed in each assertion
  mode; benchmark-adapters.json retains source/config/executable provenance.
- CLI boundaries: 25 fixtures on each of 4 executables, 100/100 passed. They include
  raw UTF-16 and empty resources, nested bases, missing resources, malformed CLI,
  traversal/URI/device denial, UNC-root denial and a real directory junction.
  The exact link was removed while its target remained intact. The mapped
  remote-drive guard was reviewed but no such drive existed for live testing.
- Python runner regressions: 36 canonical, 26 dual W3C and 33 implementation-build
  tests passed.

Reproduce the complete conformance run from the repository root after building
both W3C assertion modes with scripts/build_implementations.py --profile w3c
--implementation xpact --assertions off/on in the imported MSVC environment.
Pass their recorded .executable paths using --engine Finalized=EXE and
--engine FinalizedAssertions=EXE, select a fresh --output-dir, and --timeout 10.
The exact successful invocation is retained in conformance-command.json.

cli-boundary-checks.py preserves the executed fixture generator. Run from the
repository root with LABEL=EXE arguments for the four recorded executables.
Its XPACT_JUNCTION_FIXTURE environment variable must name a workspace-contained
fixture having suite/document.xml referring to link/entity.ent, where suite/link
is a directory junction to an ordinary directory outside that suite. The actual
creation, denial, and verified nonrecursive cleanup are recorded in the CLI JSON.

The pinned core source and no-loader behavior are unchanged. No expanded core
comparison, canonical-output/event-trace comparison, native DLL/.NET integration
or Jenkins controller execution is claimed. The early diagnostic, interim-*
identities and prior-final-9603c78e snapshot preserve earlier evidence; current
passing totals are supported by the final top-level build manifests and results.
