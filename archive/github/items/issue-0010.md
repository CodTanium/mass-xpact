# Issue #10: Finding: run_native_runtime_smoke.ps1 fails: wrong include fallback, then mingw cannot link the MSVC objects

Archived from <https://github.com/andersoxie/xpact/issues/10> on 2026-10-26 18:53 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-19 22:54 |
| Closed | 2026-10-19 23:13 |
| Labels | `bug`, `type:finding`, `group:B-reliable-results`, `D2-guided`, `P0`, `build` |
| Milestone | Week 1 - Setup |

## Description

## Report details

| Item | Value |
|---|---|
| Git commit | `3b8a20508fa35b2ef2c632f6764b71cdd339c9ca` (`student-Mass`, git clone, exact) |
| Input file / SHA-256 | n/a: build failure, the smoke program never runs |
| Exact command | **A:** `.\scripts\run_native_runtime_smoke.ps1` (defaults: `-AssertionMode All -OutputDir build\native-runtime`). **B:** the same with `ISE_EIFFEL` set to `C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard` for that process only. Both run as `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\run_native_runtime_smoke.ps1` |
| Compiler versions | EiffelStudio 25.12.9.8922 win64 · Visual Studio 18 Community 18.10.3, MSVC 14.51.36231 · Windows 11 Home 10.0.26300 · Windows PowerShell 5.1. Eiffel C backend: **mingw** (EiffelStudio default; `ISE_C_COMPILER` not set) |
| Assertions / build mode | First cell: assertions **On** (target `xpact_native_runtime`), **Workbench** (`ec -batch -clean`, `W_code`). The assertions-off cell (`xpact_native_runtime_no_assertions`) is never reached. |
| Loaded library | None: the smoke program is a plain Eiffel executable that links the native objects directly; it was never built |
| Callbacks | n/a (never ran) |
| Chunk sizes | n/a (never ran) |
| Expected | Both cells build and `xpact_native_runtime.exe` exits 0 |
| Actual | **A:** "Cannot find Eiffel runtime include directory." before any C file is compiled. **B:** the C objects compile with MSVC `cl`, then the mingw link of `xpact_native_runtime.exe` fails: `undefined reference to '__security_check_cookie'` and `'__GSHandlerCheck'` |
| Exit status | **A: 1** · **B: 1** (after 9 s) |

Expectations were written to a file before both runs. Both runs behaved as expected.

## Error output A (full)

<details><summary>Full console output (A-default.txt)</summary>

```text
commit 3b8a20508fa35b2ef2c632f6764b71cdd339c9ca
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
Cannot find Eiffel runtime include directory.
At C:\Users\masou\Desktop\Lia\xpact\xpactGit\scripts\run_native_runtime_smoke.ps1:44 char:2
+     throw "Cannot find Eiffel runtime include directory."
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Cannot find Eif...lude directory.:String) [], RuntimeException
    + FullyQualifiedErrorId : Cannot find Eiffel runtime include directory.
 
EXIT=1
```

</details>

## Error output B (full)

<details><summary>Full console output (B-ise-eiffel.txt)</summary>

```text
commit 3b8a20508fa35b2ef2c632f6764b71cdd339c9ca, ISE_EIFFEL=C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
xpact_native.c
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
xpact_eiffel_runtime_bridge.c
== native runtime smoke: assertions-on ==
Eiffel Compilation Manager
Version 25.12.9.8922 - win64

Degree 6: Examining System
Degree 5: Parsing Classes
Degree 4: Analyzing Inheritance
Degree 3: Checking Types
Degree 2: Generating Byte Code
Freezing System Changes
Degree -1: Generating Code
System Recompiled.
You must now run "finish_freezing" in:
	C:\Users\masou\Desktop\Lia\xpact\xpactGit\EIFGENs\xpact_native_runtime\W_code
Eiffel C/C++ Compilation Tool - Version: 25.12
Copyright Eiffel Software 1996-2024. All Rights Reserved.

Preparing C compilation using already configured mingw C compiler...
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/cp" "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/config/win64/templates/emain.template" "E1/emain.c"
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eparents.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" einit.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" ececil.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" evisib.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" enames.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eskelet.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eplug.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" ecall.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" efrozen.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" epattern.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" emain.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eoption.o  ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eparents.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c einit.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c evisib.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c ececil.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c enames.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eplug.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eskelet.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c efrozen.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c ecall.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c epattern.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c emain.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eoption.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
cd C1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj1.o ; fi  && cd ..
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
if [ ! -f ../../../xpact_native_runtime.rc ] ; then "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/cp" "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/config/win64/mingw/eiffel.rc" ../../../xpact_native_runtime.rc ; fi 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/C1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C1_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/windres" --preprocessor='"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/cpp.exe"' -I../../.. ../../../xpact_native_runtime.rc -O coff -o xpact_native_runtime.res
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj1.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj1.o big_file_C1_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C1_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_runtime/W_code/C1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f xpact_native_runtime.exe
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc"  -mconsole -o xpact_native_runtime.exe E1/emain.o "c:\users\masou\documents\eiffel user files\25.12\precomp\spec\win64\EIFGENs\base-safe\W_code/mingw/precomp.lib" xpact_native_runtime.res E1/eparents.o  E1/einit.o  E1/ececil.o  E1/evisib.o  E1/enames.o  E1/eskelet.o  E1/eplug.o  E1/ecall.o  E1/efrozen.o  E1/epattern.o  E1/eoption.o  C1/Cobj1.o  "..\..\..\build\native-runtime\xpact_native.obj" "..\..\..\build\native-runtime\xpact_eiffel_runtime_bridge.obj" "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/lib/mingw/wkbench.a" -luser32 -lws2_32 -ladvapi32 -lgdi32 -lshell32 -lmsimg32 -lcomdlg32 -luuid -lole32 -loleaut32 -lcomctl32 -lmpr -lshlwapi -lwinspool -lstdc++ 
Warning: .drectve `/DEFAULTLIB:"LIBCMT" /DEFAULTLIB:"OLDNAMES" ' unrecognized
Warning: .drectve `/DEFAULTLIB:"uuid.lib" /DEFAULTLIB:"uuid.lib" /DEFAULTLIB:"LIBCMT" /DEFAULTLIB:"OLDNAMES" ' unrecognized
..\..\..\build\native-runtime\xpact_native.obj:(.text$mn+0x2fc2): undefined reference to `__security_check_cookie'
..\..\..\build\native-runtime\xpact_native.obj:(.xdata+0x1e8): undefined reference to `__GSHandlerCheck'
collect2: ld returned 1 exit status
make.exe": *** [xpact_native_runtime.exe] Error 1
finish_freezing failed for native runtime target assertions-on.
At C:\Users\masou\Desktop\Lia\xpact\xpactGit\scripts\run_native_runtime_smoke.ps1:96 char:4
+             throw "finish_freezing failed for native runtime target $ ...
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (finish_freezing... assertions-on.:String) [], RuntimeException
    + FullyQualifiedErrorId : finish_freezing failed for native runtime target assertions-on.
 
EXIT=1 after 9s
```

</details>

## Observations
- **A:** `Get-IseInclude` (`scripts/run_native_runtime_smoke.ps1:33-45`) has the same `C:\El2502E` fallback that #2 fixed in `build_native_eiffel.ps1`.
- **B:**
  - EiffelStudio printed "Preparing C compilation using already configured **mingw** C compiler".
  - It linked with `gcc` against the mingw precompiled library `...\precomp\spec\win64\EIFGENs\base-safe\W_code\mingw\precomp.lib`.
  - `xpact_native.obj` and `xpact_eiffel_runtime_bridge.obj` were compiled by MSVC `cl` (`Compile-CObject`). They reference MSVC CRT symbols that the mingw linker can't resolve.
- Same root cause as #7: the Eiffel part is built with mingw, but the native objects are MSVC. `tests/xpact_native_runtime.ecf` also uses the mingw-only `<precompile>` in both targets.
- Like #7 before its fix, `ec`, `finish_freezing` and the smoke `.exe` run under `$ErrorActionPreference = "Stop"` with no stderr guard.

## Known fix (week 1, not yet applied)
`student/history/patches/01-week1-build-fixes.patch` (commit `b930600`), for `scripts/run_native_runtime_smoke.ps1` and `tests/xpact_native_runtime.ecf`:
- Use the 25.12 Standard install as the include fallback.
- Run `ec`/`finish_freezing` with `ISE_C_COMPILER=msc_vc140`, restored afterwards.
- Guard native commands against stderr.
- Remove `<precompile>` from both targets.

This is the same fix as #2 and #7 (pull request #8), applied to this script.

Related: #2, #7.

## Discussion

### CodTanium, 2026-10-19 22:56: comment

Fixed on `student-Mass` in 20e6bc3 (pull request #11).

**Fix:** the week 1 fix (patch 01) for `scripts/run_native_runtime_smoke.ps1` and `tests/xpact_native_runtime.ecf`: 25.12 Standard include fallback, `ISE_C_COMPILER=msc_vc140` around `ec`/`finish_freezing` (restored afterwards), stderr guards for native commands, `<precompile>` removed from both targets. Both files are identical to what the patch produces.

**Verification** (fresh process, `ISE_EIFFEL` and `ISE_C_COMPILER` unset, expectations written before testing):

| Command | Before (3b8a205) | After |
|---|---|---|
| `run_native_runtime_smoke.ps1` | include directory not found, exit 1 (with `ISE_EIFFEL` set: mingw link fails), exit 1 | both cells use msc_vc140 and print "xpact native runtime smoke: ok", **exit 0** |
| `ISE_C_COMPILER` after the run | n/a | unchanged (empty) |

Fix report with logs: [reports/fix-report-issue-10.md](https://github.com/andersoxie/xpact/blob/20e6bc30eab47d359624107953a1085a2d3e10da/reports/fix-report-issue-10.md)

Leaving this open until the fix reaches `main`. Revert with `.\student\tools\fix.ps1 revert -Issue 10 -Commit 20e6bc3`.
