# Issue #210: Task: XPact website - upload and test XML, docs, conformance and benchmark pages

Archived from <https://github.com/andersoxie/xpact/issues/210> on 2026-11-02 15:47 UTC.

| | |
|---|---|
| State | open |
| Author | CodTanium |
| Created | 2026-11-02 10:32 |
| Closed |  |
| Labels | `documentation`, `enhancement`, `type:task`, `test` |
| Milestone | Week 8 - Consolidate |

## Description

## Task
Build the XPact website described in `website/guide.txt`: a public XML validation tool that also demonstrates the parser. Visitors upload or paste XML and see what XPact does with it. The site also has documentation, conformance and benchmark results, and project links.

## Scope (guide.txt, 5 components)
| Component | Technology | Folder |
|---|---|---|
| Frontend | React 19 + TypeScript (Vite) | `website/frontend/` |
| Backend | ASP.NET Core (.NET 10) REST API | `website/backend/src/Xpact.Api/` |
| Worker | separate process per document, P/Invoke into `xpact.dll` | `website/backend/src/Xpact.Worker/` |
| Parser | `xpact.dll`, `xpact_assertions.dll` (unchanged) | built by `scripts/build_native_eiffel.ps1` |
| Results | JSON responses; conformance and benchmark data exported from `reports/` | `website/data/` |

Pages: Home, Validator (the main feature), Documentation, Benchmarks and conformance, Project.

## Environment
Student PC 2, Windows 11, `student-Mass` @ `22876e9`. EiffelStudio 25.12 (`msc_vc140`), .NET SDK 10.0.300, Node 24.19.

## Commands
```powershell
.\website\scripts\build-dll.ps1   # build both DLLs, copy them into the website
.\website\scripts\test.ps1        # backend end-to-end tests + frontend type check and build
.\website\scripts\publish.ps1     # website\dist
.\website\dist\Xpact.Api.exe --urls http://localhost:5099
```

## Expected
- Valid XML is accepted; invalid XML is rejected with the Expat error code, line and column.
- The result is the same whether the document is fed whole or in pieces.
- Both builds work: production, and assertions (contracts checked).
- External entities are never loaded.
- A crash or a slow document cannot take the server down.

## Actual (local, 2026-11-02)
- ✅ Backend: 19 / 19 end-to-end tests pass, through the real worker and DLL.
- ✅ Frontend: type check and build pass.
- ✅ Browser QA of the published site: all pages render, the validator flows work, 0 console errors, 0 failed requests.
- ✅ Screenshots checked: light, dark, and phone width (no horizontal overflow).

## Problems met (kept separate)
1. One test expected code 5 for `<root>` at the end of input. Expat (and XPact) report 3, "no element found". ✅ Confirmed as a wrong expectation; the test was corrected.
2. Port 8080 is used by Apache `httpd` on this PC. ✅ Confirmed; the site uses 5099.
3. A parser finding from the security tests (nested entity expansion) has **its own issue** (linked below).

## Not done
- [ ] Public deployment (guide phase 7): HTTPS, forwarded headers, a low-privilege worker account
- [ ] Memory cap not triggered by any test; no load test

## Links
- Pull request: #212 (into `student-Mass`)
- Report: [reports/issue-0210/report.md](https://github.com/andersoxie/xpact/blob/fix/210-xpact-website/reports/issue-0210/report.md), with [logs](https://github.com/andersoxie/xpact/blob/fix/210-xpact-website/reports/issue-0210/logs) and [screenshots](https://github.com/andersoxie/xpact/blob/fix/210-xpact-website/reports/issue-0210/screenshots)
- Website docs: [website/README.md](https://github.com/andersoxie/xpact/blob/fix/210-xpact-website/website/README.md)
- Finding found on the way: #211

## Status
- [x] Built and tested locally
- [x] Pull request #212 opened
- [ ] Merged into `student-Mass`
- [ ] Deployed (guide phase 7)
