# W3C XML conformance

Source: https://www.w3.org/XML/Test/xmlts20130923.zip

Profile: XML 1.0 fifth edition; namespaces unless NAMESPACE=no; nonvalidating; no external entities; binary verdicts only

| Engine | Cases | Passed | Failed | Errors | Skipped | Known | Unexpected | Elapsed ms |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Finalized | 2585 | 2585 | 0 | 0 | 0 | 0 | 0 | 49119.379 |
| FinalizedAssertions | 2585 | 2585 | 0 | 0 | 0 | 0 | 0 | 104065.741 |

## Lanes (--all-cases)

| Engine | Lane | Cases | Passed | Failed | Errors | Skipped | Accepted | Rejected |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Finalized | core | 1727 | 1727 | 0 | 0 | 0 | 776 | 951 |
| Finalized | external-entities | 247 | 247 | 0 | 0 | 0 | 181 | 66 |
| Finalized | legacy-names | 309 | 309 | 0 | 0 | 0 | 0 | 309 |
| Finalized | optional-error | 28 | 28 | 0 | 0 | 0 | 14 | 14 |
| Finalized | xml-1.1 | 274 | 274 | 0 | 0 | 0 | 124 | 150 |
| FinalizedAssertions | core | 1727 | 1727 | 0 | 0 | 0 | 776 | 951 |
| FinalizedAssertions | external-entities | 247 | 247 | 0 | 0 | 0 | 181 | 66 |
| FinalizedAssertions | legacy-names | 309 | 309 | 0 | 0 | 0 | 0 | 309 |
| FinalizedAssertions | optional-error | 28 | 28 | 0 | 0 | 0 | 14 | 14 |
| FinalizedAssertions | xml-1.1 | 274 | 274 | 0 | 0 | 0 | 124 | 150 |

- `core`: the profile above
- `external-entities`: external entities loaded through the Expat-compatible DLL (child parsers, files below the suite root); W3C verdict, nonvalidating
- `legacy-names`: XML 1.0 editions 1-4: fourth-edition name tables (--legacy-names, as the native DLL parser uses); W3C verdict
- `optional-error`: TYPE=error: the specification allows either verdict; only a crash, timeout or missing verdict fails
- `xml-1.1`: XML 1.1 / Namespaces 1.1: no XML 1.0 verdict exists; only a crash, timeout or missing verdict fails

Known counts failures and errors listed in the known-failures file; they are still parser gaps.
Unexpected counts every other failure or error; any unexpected result fails the run.
Elapsed time includes a fresh process and file read per executed case; it is not parser-only throughput.
Skipped cases are excluded from conformance results. Canonical output comparisons are not implemented.
