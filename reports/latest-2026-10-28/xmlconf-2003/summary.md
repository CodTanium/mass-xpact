# W3C XML conformance

Source: https://www.w3.org/XML/Test/xmlts20130923.zip

Profile: XML 1.0 fifth edition; namespaces unless NAMESPACE=no; nonvalidating; external-resource cases included; local suite root supplied to each engine; binary verdicts only

| Engine | Cases | Passed (verdict checked) | No crash only | Failed | Errors | Skipped | Known | Unexpected | Elapsed ms |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Finalized | 2162 | 1491 | 79 | 302 | 290 | 0 | 0 | 592 | 24642.26 |
| FinalizedAssertions | 2162 | 1491 | 79 | 302 | 290 | 0 | 0 | 592 | 25736.737 |

## Lanes (--all-cases)

| Engine | Lane | Judged by | Cases | Passed | Failed | Errors | Skipped | Accepted | Rejected |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| Finalized | core | verdict | 1866 | 1491 | 302 | 73 | 0 | 865 | 928 |
| Finalized | optional-error | no crash only | 24 | 18 | 0 | 6 | 0 | 7 | 11 |
| Finalized | xml-1.1 | no crash only | 272 | 61 | 0 | 211 | 0 | 2 | 59 |
| FinalizedAssertions | core | verdict | 1866 | 1491 | 302 | 73 | 0 | 865 | 928 |
| FinalizedAssertions | optional-error | no crash only | 24 | 18 | 0 | 6 | 0 | 7 | 11 |
| FinalizedAssertions | xml-1.1 | no crash only | 272 | 61 | 0 | 211 | 0 | 2 | 59 |

- `core`: the profile above
- `optional-error`: TYPE=error: the specification allows either verdict; only a crash, timeout or missing verdict fails
- `xml-1.1`: XML 1.1 / Namespaces 1.1: no XML 1.0 verdict exists; only a crash, timeout or missing verdict fails

Known counts failures and errors listed in the known-failures file; they are still parser gaps.
Unexpected counts every other failure or error; any unexpected result fails the run.
Elapsed time includes a fresh process and file read per executed case; it is not parser-only throughput.
Skipped cases are excluded from conformance results. Canonical output comparisons are not implemented.
