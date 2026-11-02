# Issue #224: Website: rate limit counts the proxy, not the visitor, behind a reverse proxy

Archived from <https://github.com/andersoxie/xpact/issues/224> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-11-02 15:29 |
| Closed | 2026-11-02 15:31 |
| Labels | `documentation`, `enhancement` |
| Milestone | - |

## Description

## Problem
Behind a reverse proxy (IIS, nginx), every request reaches the API from the proxy's address. The rate limit (30 requests/min per IP) then counts **all visitors together**, and logs show the proxy instead of the visitor. Listed as an open point in `website/docs/security.md`.

## Change
- Use ASP.NET Core's forwarded-headers middleware (`X-Forwarded-For`, `X-Forwarded-Proto`) before the rate limiter.
- Trust only proxies on the same machine (the default) plus the addresses in the new setting `Xpact:KnownProxies`, so visitors cannot fake their IP.
- A test: two visitors behind the same proxy get separate rate limits.

## Discussion

### CodTanium, 2026-11-02 15:31: comment

Fixed in dbcf579 (PR #225). Verified: the new test fails without the change (second visitor 429) and all 20 backend tests pass with it.
