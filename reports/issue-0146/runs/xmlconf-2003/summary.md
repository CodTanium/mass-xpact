# W3C XML conformance

Source: https://www.w3.org/XML/Test/xmlts20130923.zip

Profile: XML 1.0 fifth edition; namespaces unless NAMESPACE=no; nonvalidating; no external entities; binary verdicts only

| Engine | Cases | Passed | Failed | Errors | Skipped | Known | Unexpected | Elapsed ms |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Finalized | 2162 | 1570 | 302 | 290 | 0 | 0 | 592 | 41953.011 |
| FinalizedAssertions | 2162 | 1570 | 302 | 290 | 0 | 0 | 592 | 85208.384 |

## Lanes (--all-cases)

| Engine | Lane | Cases | Passed | Failed | Errors | Skipped | Accepted | Rejected |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Finalized | core | 1627 | 1256 | 302 | 69 | 0 | 695 | 863 |
| Finalized | external-entities | 239 | 235 | 0 | 4 | 0 | 170 | 65 |
| Finalized | optional-error | 24 | 18 | 0 | 6 | 0 | 7 | 11 |
| Finalized | xml-1.1 | 272 | 61 | 0 | 211 | 0 | 2 | 59 |
| FinalizedAssertions | core | 1627 | 1256 | 302 | 69 | 0 | 695 | 863 |
| FinalizedAssertions | external-entities | 239 | 235 | 0 | 4 | 0 | 170 | 65 |
| FinalizedAssertions | optional-error | 24 | 18 | 0 | 6 | 0 | 7 | 11 |
| FinalizedAssertions | xml-1.1 | 272 | 61 | 0 | 211 | 0 | 2 | 59 |

- `core`: the profile above
- `external-entities`: external entities loaded through the Expat-compatible DLL (child parsers, files below the suite root); W3C verdict, nonvalidating
- `optional-error`: TYPE=error: the specification allows either verdict; only a crash, timeout or missing verdict fails
- `xml-1.1`: XML 1.1 / Namespaces 1.1: no XML 1.0 verdict exists; only a crash, timeout or missing verdict fails

Known counts failures and errors listed in the known-failures file; they are still parser gaps.
Unexpected counts every other failure or error; any unexpected result fails the run.
Elapsed time includes a fresh process and file read per executed case; it is not parser-only throughput.
Skipped cases are excluded from conformance results. Canonical output comparisons are not implemented.
