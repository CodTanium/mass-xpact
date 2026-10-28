# Issue #143: Finding: 7 native Python tests skip because the CMake bundled with Visual Studio is not found

Archived from <https://github.com/andersoxie/xpact/issues/143> on 2026-10-28 19:58 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-26 23:11 |
| Closed | 2026-10-26 23:18 |
| Labels | `type:finding`, `group:B-reliable-results`, `test` |
| Milestone | - |

## Description

**Problem:** 7 native Python tests are always skipped on the student PC (*Windows, CMake, and MSVC are required*), although Visual Studio and its bundled CMake are installed.

**Tests:** `test_libexpat_isolation.NativeIsolationTests` (6) and `test_libexpat_test_defaults.NativeTestDefaultTests` (1)

**Environment:** student PC, Windows 11, Visual Studio 18 Community (MSVC 19.51), no stand-alone CMake, Python 3.14, `student-Mass` @ `36509b8`.

**Command:** `python -m unittest discover -s tests/python -p "test_*.py"`
**Expected:** all 178 tests run.
**Actual:** `Ran 178 tests ... OK (skipped=7)`

**Investigation:** the tests look for `cmake` on `PATH`, then `%ProgramFiles%\CMake\bin\cmake.exe`. Visual Studio installs CMake under `Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin`, which neither place covers. With that folder on `PATH`, the libexpat tests ran: 13 tests, OK, 0 skipped.

**Cause:** confirmed. The CMake lookup misses Visual Studio's bundled CMake.
**Fix:** also find CMake through `vswhere` in the Visual Studio installation that has the C++ tools.
**Verification:** full Python suite with no skips on the student PC.

## Discussion

### CodTanium, 2026-10-26 23:18: comment

Fixed in ec1705d (PR #145), merged into student-Mass. Verified on the student PC: full Python suite `Ran 178 tests, OK`, 0 skipped (before: `OK (skipped=7)`). Logs: reports/issue-0143/python-all-before.txt and python-all-after.txt.
