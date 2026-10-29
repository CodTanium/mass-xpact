# Parser changes, 23–28 October

> Masoud (CodTanium) · `student-Mass` @ [`e5d59e2`](https://github.com/andersoxie/xpact/commit/e5d59e2) · nothing pushed to `main` · see also [requests for 2026-10-29](2026-10-29.md)

**Background.** Until last week, Jenkins skipped 858 W3C cases per build (old editions, XML 1.1, optional errors, external entities). With Option A (#146) all 2,585 cases run, which exposed the bugs in section 1. A new test then compared xpact's parsed output, not just the verdict, with the catalog's `OUTPUT` files, which exposed the bugs in section 2.

**Where.** Code: `src/xp_parser.e` (most changes), `src/xp_native_parser.e`, `src/xp_native_callback_handler.e`, new `src/xp_literal_check_handler.e`, on `student-Mass`. Reports: `reports/issue-0151/`, `reports/latest-2026-10-28/`, `reports/issue-0154/` … `issue-0159/`.

## 1. W3C all-cases fixes (27 Oct, #146 / #151)

Found by running all 2,585 cases. Mostly the external-entity path.

| Fix | Change | Commit |
|---|---|---|
| F1 | Recursion through external entities detected in child parsers (was a stack overflow in the DLL) | [`8beecc4`](https://github.com/andersoxie/xpact/commit/8beecc4) |
| F2 | Parameter-entity references expanded inside declarations in the external DTD | [`200389f`](https://github.com/andersoxie/xpact/commit/200389f) |
| F3 | Only the first top-level element of an external entity is counted (assertions-build exit) | [`4d8e1fc`](https://github.com/andersoxie/xpact/commit/4d8e1fc) |
| F4 | WFC Entity Declared enforced in standalone documents | [`3b18f90`](https://github.com/andersoxie/xpact/commit/3b18f90) |
| F5 | `encoding` required in text declarations | [`3ef6a7f`](https://github.com/andersoxie/xpact/commit/3ef6a7f) |
| F6 | Misplaced XML declarations rejected | [`cd719ea`](https://github.com/andersoxie/xpact/commit/cd719ea) |
| F7 | Parser base passed to `ExternalEntityRefHandler` (was `NULL`) | [`915ab06`](https://github.com/andersoxie/xpact/commit/915ab06) |
| #148 | Internal entity references: reference position kept, no rescans (`pr-xml-*` 16 s → 0.2 s, assertions build) | [`e5cc8f7`](https://github.com/andersoxie/xpact/commit/e5cc8f7) |

Integration with your #150: `main` merged in ([`a1fc6af`](https://github.com/andersoxie/xpact/commit/a1fc6af)); my F4 entity-origin table removed in favour of yours ([`ef50129`](https://github.com/andersoxie/xpact/commit/ef50129)); F6b dropped, 1.x text declaration accepted per E10 ([`5e93e85`](https://github.com/andersoxie/xpact/commit/5e93e85)); standalone entity error mapped to `XML_ERROR_ENTITY_DECLARED_IN_PE` ([`6e99419`](https://github.com/andersoxie/xpact/commit/6e99419)).

## 2. W3C output comparison fixes (28 Oct, #154–#159)

Found by comparing canonical output with the catalog's `OUTPUT` files (DLL path).

| PR | Change |
|---|---|
| [#160](https://github.com/andersoxie/xpact/pull/160) | Attribute defaults declared in the external DTD / external entities applied |
| [#161](https://github.com/andersoxie/xpact/pull/161) | Declared defaults of tokenized attribute types normalized (§3.3.3) |
| [#162](https://github.com/andersoxie/xpact/pull/162) | Public identifiers normalized |
| [#163](https://github.com/andersoxie/xpact/pull/163) | A second U+FEFF after UTF-16 decoding kept as data |
| [#164](https://github.com/andersoxie/xpact/pull/164) | External PE text included in entity literals (§4.4.5) instead of parsed as declarations |

**Result:** 399 / 432 exact output (was 359). After each fix: 0 cases worse, normal build = assertions build, dual regression lane 910 / 910.

## 3. Waiting for

- ⬜ Jenkins all-tests on `e5d59e2`; the issues stay open until it passes.
