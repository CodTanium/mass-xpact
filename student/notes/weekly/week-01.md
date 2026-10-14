# Week 1 - 2026-10-05 to 2026-10-09 (build work began in September)

## Tried
- Built xpact on Windows: EiffelStudio 25.12, VS 18 / MSVC 14.51, PowerShell 5.1, Python 3.10, Jenkins.
- Fixed the native build step by step: the include path, the C backend (mingw vs `msc_vc140`), the precompiled base, `ec.lock`, and stderr aborting the scripts.

## What the evidence shows
- The production Eiffel-backed DLL builds and passes its smoke test; the release package builds. ([BUILD_FIX_NOTES.txt](../../history/BUILD_FIX_NOTES.txt))
- The bridge-only DLL is not enough: `XML_Parse` from C# returns error 44, "Eiffel parser bridge is not installed".
- AutoTest generated tests: ok.
- Already visible: invalid UTF-8 accepted, the B03 postcondition violation, and the assertions DLL smoke crash. ([error report](../../history/xpact-error-report.md))

## Blocked
- The assertions-tier DLL smoke test crashes (`0xC0000008`); CI skips it.

## Next week
- Assertions-enabled baseline with revision, configuration, commands and known failures.
