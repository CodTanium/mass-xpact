# Issue #7: Finding: build_native_eiffel.ps1 stops with "Expected Eiffel link response file not found" (xpact_native_library.lnk)

Archived from <https://github.com/andersoxie/xpact/issues/7> on 2026-10-26 20:59 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-19 22:33 |
| Closed | 2026-10-19 23:13 |
| Labels | `bug`, `type:finding`, `group:B-reliable-results`, `D2-guided`, `P0`, `build` |
| Milestone | Week 1 - Setup |

## Description

## Report details

| Item | Value |
|---|---|
| Git commit | **Rerun:** `cada501ca3117135d3649e1e8ca45b2ccc717748` (`student-Mass`, includes the #2 fix; git clone, exact). **Original run** (2026-10-20): copied folder `xpact3.0\...` with the #2 fix applied by hand, not a git clone, most likely `4f71743`. |
| Input file / SHA-256 | n/a: build failure, no XML is parsed |
| Exact command | `.\scripts\build_native_eiffel.ps1` (defaults: `-BuildTier Production -OutputDir build\native-eiffel`). Rerun as `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_native_eiffel.ps1`, with `C:\Program Files (x86)\Microsoft Visual Studio\Installer` added to the front of PATH (see Observations) |
| Compiler versions | EiffelStudio 25.12.9.8922 win64 · Visual Studio 18 Community 18.10.3, MSVC 14.51.36231 · Windows 11 Home 10.0.26300 · Windows PowerShell 5.1. **Eiffel C backend used: mingw** (`gcc` from the EiffelStudio install); `ISE_C_COMPILER` not set (user, machine, process) |
| Assertions / build mode | Production tier: target `xpact_native_library`, assertions **off** (all six off in `tests/xpact_native_library.ecf`), **Finalized** (`ec -batch -clean -finalize -keep`) |
| Loaded library | None: no DLL was built (`build\native-eiffel` contains only the three `.obj` files) |
| Callbacks | n/a (no parse) |
| Chunk sizes | n/a (no parse) |
| Expected | `build\native-eiffel\xpact.dll` is built and the smoke test passes |
| Actual | `ec` and `finish_freezing` finish ("C compilation completed"), then `Get-LinkResponseFile` throws: no `xpact_native_library.lnk` in `F_code` |
| Exit status | **1** (rerun). Original run: stopped at the same `throw` (`build_native_eiffel.ps1:91`); exact code not recorded. |

Expectations for the reruns were written to a file at 2026-10-20 00:39 (and, for the PATH variant, again before that run). For the original run the expectation was not written down beforehand.

## Error output: rerun at cada501

```text
echo done > completed.eif
C compilation completed
Expected Eiffel link response file not found: 
C:\Users\masou\Desktop\Lia\xpact\xpactGit\EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk
At C:\Users\masou\Desktop\Lia\xpact\xpactGit\scripts\build_native_eiffel.ps1:91 char:2
+     throw "Expected Eiffel link response file not found: $Expected"
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Expected Eiffel...ive_library.lnk:String) [], RuntimeException
    + FullyQualifiedErrorId : Expected Eiffel link response file not found: C:\Users\masou\Desktop\Lia\xpact\xpactGit\ 
   EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk
```

<details><summary>Full console output (issue7-build-vswhere-on-path.txt)</summary>

```text
commit cada501ca3117135d3649e1e8ca45b2ccc717748
PATH prefix: C:\Program Files (x86)\Microsoft Visual Studio\Installer
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
xpact_native.c
xpact_eiffel_runtime_bridge.c
xpact_eiffel_dllmain.c
Eiffel Compilation Manager
Version 25.12.9.8922 - win64

Degree 6: Examining System
Degree 5: Parsing Classes
Degree 4: Analyzing Inheritance
Degree 3: Checking Types
Degree 2: Generating Byte Code
Degree -2: Constructing Polymorphic Table
Degree -3: Generating Optimized Code
System Recompiled.
You must now run "finish_freezing" in:
	C:\Users\masou\Desktop\Lia\xpact\xpactGit\EIFGENs\xpact_native_library\F_code
Eiffel C/C++ Compilation Tool - Version: 25.12
Copyright Eiffel Software 1996-2024. All Rights Reserved.

Preparing C compilation using already configured mingw C compiler...
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/cp" "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/config/win64/templates/emain.template" "E1/emain.c"
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/bin/x2c.exe" E1/estructure.x E1/estructure.h
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/bin/x2c.exe" E1/eoffsets.x E1/eoffsets.h
if [ ! -f ../../../xpact_native_library.rc ] ; then "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/cp" "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/config/win64/mingw/eiffel.rc" ../../../xpact_native_library.rc ; fi 
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" emain.o  ; fi  && cd ..
cd E2 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Eobj2.o ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eparents.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" einit.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" ececil.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" evisib.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" enames.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eskelet.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eplug.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" esize.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" epoly.o  ; fi  && cd ..
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eref.o  ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E2'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_E2_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c emain.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c einit.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eparents.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c ececil.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c evisib.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c enames.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eplug.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/bin/x2c.exe" eskelet.x eskelet.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/bin/x2c.exe" esize.x esize.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c epoly.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eref.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c esize.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eskelet.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
cd E1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" eoption.o  ; fi  && cd ..
cd C20 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj20.o ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eoption.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
cd C19 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj19.o ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C20'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C20_c.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
cd C18 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj18.o ; fi  && cd ..
cd C17 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj17.o ; fi  && cd ..
cd C16 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj16.o ; fi  && cd ..
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
cd C15 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj15.o ; fi  && cd ..
cd C14 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj14.o ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C18'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C18_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C17'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C17_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C19'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C19_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C16'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C16_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f esize.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
cd C13 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj13.o ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C15'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C15_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C14'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C14_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C13'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C13_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f eskelet.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
cd C12 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj12.o ; fi  && cd ..
cd C11 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj11.o ; fi  && cd ..
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E1'
cd C10 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj10.o ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C12'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C12_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C11'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C11_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C10'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C10_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Eobj2.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Eobj2.o big_file_E2_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj12.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj12.o big_file_C12_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C12_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj13.o
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C12'
cd C9 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj9.o ; fi  && cd ..
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj13.o big_file_C13_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj16.o
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C9'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C9_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_E2_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj16.o big_file_C16_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/E2'
cd C8 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj8.o ; fi  && cd ..
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C13_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C8'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C8_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj17.o
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C13'
cd C7 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj7.o ; fi  && cd ..
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C16_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj17.o big_file_C17_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C16'
cd C6 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj6.o ; fi  && cd ..
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj14.o
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C7'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C7_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj14.o big_file_C14_c.o 
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C6'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C6_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C17_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C14_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C17'
cd C5 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj5.o ; fi  && cd ..
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C14'
cd C4 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj4.o ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C5'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C5_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj18.o
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C4'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C4_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj19.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj18.o big_file_C18_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj19.o big_file_C19_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C19_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C18_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C19'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C18'
cd C3 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj3.o ; fi  && cd ..
cd C2 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj2.o ; fi  && cd ..
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C2'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C2_c.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C3'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C3_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj15.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj15.o big_file_C15_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj10.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj11.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C15_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj10.o big_file_C10_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C15'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj11.o big_file_C11_c.o 
cd C1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj1.o ; fi  && cd ..
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O2 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C1_c.c
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C10_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C11_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C10'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/windres" --preprocessor='"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/cpp.exe"' -I../../.. ../../../xpact_native_library.rc -O coff -o xpact_native_library.res
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C11'
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj2.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj2.o big_file_C2_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C2_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C2'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj3.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj9.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj3.o big_file_C3_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj9.o big_file_C9_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C3_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C9_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C3'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C9'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj8.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj8.o big_file_C8_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C8_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C8'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj6.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj6.o big_file_C6_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C6_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C6'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj20.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj20.o big_file_C20_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C20_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C20'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj7.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj7.o big_file_C7_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C7_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C7'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj4.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj4.o big_file_C4_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj1.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj1.o big_file_C1_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C4_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C4'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C1_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj5.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj5.o big_file_C5_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C5_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_native_library/F_code/C5'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f xpact_native_library.exe
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc"  -mwindows -o xpact_native_library.exe E1/emain.o  xpact_native_library.res E2/Eobj2.o E1/eparents.o  E1/einit.o  E1/ececil.o  E1/evisib.o  E1/enames.o  E1/eskelet.o  E1/eplug.o  E1/esize.o  E1/epoly.o  E1/eref.o  E1/eoption.o  C20/Cobj20.o C19/Cobj19.o C18/Cobj18.o C17/Cobj17.o C16/Cobj16.o C15/Cobj15.o C14/Cobj14.o C13/Cobj13.o C12/Cobj12.o C11/Cobj11.o C10/Cobj10.o C9/Cobj9.o C8/Cobj8.o C7/Cobj7.o C6/Cobj6.o C5/Cobj5.o C4/Cobj4.o C3/Cobj3.o C2/Cobj2.o C1/Cobj1.o  "..\..\..\build\native-eiffel\xpact_native.obj" "..\..\..\build\native-eiffel\xpact_eiffel_runtime_bridge.obj" "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/lib/mingw/finalized.a" -luser32 -lws2_32 -ladvapi32 -lgdi32 -lshell32 -lmsimg32 -lcomdlg32 -luuid -lole32 -loleaut32 -lcomctl32 -lmpr -lshlwapi -lwinspool -lstdc++ 
Warning: .drectve `/DEFAULTLIB:"LIBCMT" /DEFAULTLIB:"OLDNAMES" /EXPORT:XML_SetElementDeclHandler /EXPORT:XML_SetAttlistDeclHandler /EXPORT:XML_SetXmlDeclHandler /EXPORT:XML_ParserCreate /EXPORT:XML_ParserCreateNS /EXPORT:XML_ParserCreate_MM /EXPORT:XML_ParserReset /EXPORT:XML_SetEntityDeclHandler /EXPORT:XML_SetElementHandler /EXPORT:XML_SetStartElementHandler /EXPORT:XML_SetEndElementHandler /EXPORT:XML_SetCharacterDataHandler /EXPORT:XML_SetProcessingInstructionHandler /EXPORT:XML_SetCommentHandler /EXPORT:XML_SetCdataSectionHandler /EXPORT:XML_SetStartCdataSectionHandler /EXPORT:XML_SetEndCdataSectionHandler /EXPORT:XML_SetDefaultHandler /EXPORT:XML_SetDefaultHandlerExpand /EXPORT:XML_SetDoctypeDeclHandler /EXPORT:XML_SetStartDoctypeDeclHandler /EXPORT:XML_SetEndDoctypeDeclHandler /EXPORT:XML_SetUnparsedEntityDeclHandler /EXPORT:XML_SetNotationDeclHandler /EXPORT:XML_SetNamespaceDeclHandler /EXPORT:XML_SetStartNamespaceDeclHandler /EXPORT:XML_SetEndNamespaceDeclHandler /EXPORT:XML_SetNotStandaloneHandler /EXPORT:XML_SetExternalEntityRefHandler /EXPORT:XML_SetExternalEntityRefHandlerArg /EXPORT:XML_SetSkippedEntityHandler /EXPORT:XML_SetUnknownEncodingHandler /EXPORT:XML_DefaultCurrent /EXPORT:XML_SetReturnNSTriplet /EXPORT:XML_SetUserData /EXPORT:XML_SetEncoding /EXPORT:XML_UseParserAsHandlerArg /EXPORT:XML_UseForeignDTD /EXPORT:XML_SetBase /EXPORT:XML_GetBase /EXPORT:XML_GetSpecifiedAttributeCount /EXPORT:XML_GetIdAttributeIndex /EXPORT:XML_GetAttributeInfo /EXPORT:XML_Parse /EXPORT:XML_GetBuffer /EXPORT:XML_ParseBuffer /EXPORT:XML_StopParser /EXPORT:XML_ResumeParser /EXPORT:XML_GetParsingStatus /EXPORT:XML_ExternalEntityParserCreate /EXPORT:XML_SetParamEntityParsing /EXPORT:XML_SetHashSalt /EXPORT:XML_SetHashSalt16Bytes /EXPORT:XML_GetErrorCode /EXPORT:XML_GetCurrentLineNumber /EXPORT:XML_GetCurrentColumnNumber /EXPORT:XML_GetCurrentByteIndex /EXPORT:XML_GetCurrentByteCount /EXPORT:XML_GetInputContext /EXPORT:XML_FreeContentModel /EXPORT:XML_MemMalloc /EXPORT:XML_MemRealloc /EXPORT:XML_MemFree /EXPORT:XML_ParserFree /EXPORT:XML_ErrorString /EXPORT:XML_ExpatVersion /EXPORT:XML_ExpatVersionInfo /EXPORT:XML_GetFeatureList /EXPORT:XML_SetBillionLaughsAttackProtectionMaximumAmplification /EXPORT:XML_SetBillionLaughsAttackProtectionActivationThreshold /EXPORT:XML_SetAllocTrackerMaximumAmplification /EXPORT:XML_SetAllocTrackerActivationThreshold /EXPORT:XML_SetReparseDeferralEnabled /EXPORT:XPACT_SetEiffelBridge /EXPORT:XPACT_ClearEiffelBridge /EXPORT:XPACT_TestingAccountingGetCountBytesDirect /EXPORT:XPACT_TestingAccountingGetCountBytesIndirect ' unrecognized
Warning: .drectve `/DEFAULTLIB:"uuid.lib" /DEFAULTLIB:"uuid.lib" /DEFAULTLIB:"LIBCMT" /DEFAULTLIB:"OLDNAMES" /EXPORT:XPACT_RegisterEiffelRuntimeBridge /EXPORT:XPACT_RegisterEiffelRuntimeBridgePointers /EXPORT:XPACT_UnregisterEiffelRuntimeBridge ' unrecognized
echo done > completed.eif
C compilation completed
Expected Eiffel link response file not found: 
C:\Users\masou\Desktop\Lia\xpact\xpactGit\EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk
At C:\Users\masou\Desktop\Lia\xpact\xpactGit\scripts\build_native_eiffel.ps1:91 char:2
+     throw "Expected Eiffel link response file not found: $Expected"
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Expected Eiffel...ive_library.lnk:String) [], RuntimeException
    + FullyQualifiedErrorId : Expected Eiffel link response file not found: C:\Users\masou\Desktop\Lia\xpact\xpactGit\ 
   EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk
 
EXIT=1 after 27s
```

</details>

## Error output: original run, 2026-10-20 (full, as pasted)

```text
C compilation completed
Expected Eiffel link response file not found: C:\Users\masou\Desktop\Lia\xpact3.0\xpact-codex-w3c-xml-conformance-bench
marks\EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk
At C:\Users\masou\Desktop\Lia\xpact3.0\xpact-codex-w3c-xml-conformance-benchmarks\scripts\build_native_eiffel.ps1:91
char:2
+     throw "Expected Eiffel link response file not found: $Expected"
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Expected Eiffel...ive_library.lnk:String) [], RuntimeException
    + FullyQualifiedErrorId : Expected Eiffel link response file not found: C:\Users\masou\Desktop\Lia\xpact3.0\xpact-
   codex-w3c-xml-conformance-benchmarks\EIFGENs\xpact_native_library\F_code\xpact_native_library.lnk
```

## Observations
- The full log shows **"Preparing C compilation using already configured mingw C compiler..."**, and every C file is compiled with `...\EiffelStudio 25.12 Standard\gcc\win64\mingw\bin\gcc`.
- After the run, `EIFGENs\xpact_native_library\F_code` contains `Makefile`, `Makefile.SH` and `xpact_native_library.exe`, and **no `.lnk` file**.
- `Get-LinkResponseFile` (`scripts/build_native_eiffel.ps1:78-92`) needs `F_code\<target>.lnk`, or exactly one other `*.lnk`, which only an MSVC backend writes.
- **The same command without the PATH change stops earlier:** in a fresh `powershell -File` process, `Invoke-VcCommand` (line 52, `cmd.exe /c ... 2>&1`) turns the `'vswhere.exe' is not recognized` stderr line from `vcvars64.bat` into a terminating error, exit 1 after 1 s. With the Visual Studio Installer folder on PATH, `vswhere.exe` is found, nothing is written to stderr, and the script reaches this error. In the original interactive window the script also got this far. Output of that run:

<details><summary>Full console output (issue7-build.txt)</summary>

```text
commit cada501ca3117135d3649e1e8ca45b2ccc717748
ISE_C_COMPILER=[]
'vswhere.exe' is not recognized as an internal or external command,
operable program or batch file.
Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
cmd.exe : 'vswhere.exe' is not recognized as an internal or external command,
At C:\Users\masou\Desktop\Lia\xpact\xpactGit\scripts\build_native_eiffel.ps1:52 char:12
+     $Output = cmd.exe /c "`"$VcVars`" >nul && $Command" 2>&1
+               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: ('vswhere.exe' i...ternal command,:String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 
EXIT=1 after 1s
```

</details>

## Cause (confirmed by the rerun)
EiffelStudio's configured C backend on this PC is **mingw**. It links with gcc and writes no `.lnk` response file, but the script expects the MSVC link step.

## Known fix (from week 1, not yet applied)
From `student/history/xpact-error-report.md` §4.1-4.4, in `student/history/patches/01-week1-build-fixes.patch` (commit `b930600`):
- Set `ISE_C_COMPILER = "msc_vc140"` around the `ec` and `finish_freezing` calls. (The plain `msc` backend failed with VS 18: unresolved `__iob_func`, `_set_output_format`.)
- Remove the mingw-only `<precompile>` from both targets in `tests/xpact_native_library.ecf` (lines 18 and 37).
- Delete a stale `EIFGENs\xpact_native_library\ec.lock` if one is left.
- Guard native calls against stderr (the `vswhere.exe` problem above).

Related: #2 (previous step in the same script), #4 (MSVC environment import).

## Logs
- Rerun output: above (full)

## Discussion

### CodTanium, 2026-10-19 22:50: comment

Fixed on `student-Mass` in eb6fc5d (pull request #8).

**Cause (confirmed):** EiffelStudio's default C backend on this PC is mingw, which writes no `.lnk` link response file.

**Fix:** `build_native_eiffel.ps1` now compiles the target with `ISE_C_COMPILER=msc_vc140` (restored afterwards) and no longer lets harmless stderr from `vcvars64.bat` abort native commands. The mingw-only `<precompile>` was removed from both targets in `tests/xpact_native_library.ecf`. This is the week 1 fix (patch 01) for these two files only.

**Verification** (fresh process, default PATH, expectations written before testing):

| Command | Before | After |
|---|---|---|
| `build_native_eiffel.ps1` (Production) | exit 1, no DLL | msc_vc140 used, `.lnk` created, `xpact.dll` built, smoke test ok, **exit 0** |
| `build_native_eiffel.ps1 -BuildTier Assertions -SkipSmoke` | not reached | `xpact_assertions.dll` built, **exit 0** |
| `ISE_C_COMPILER` after the run | n/a | unchanged (empty) |

`xpact.dll` SHA-256: `2899b89298d7a6a41832bee3ea16d67571c24866128566dca1f78c3e0db409a1`

Fix report with before/after logs: [reports/fix-report-issue-7.md](https://github.com/andersoxie/xpact/blob/eb6fc5d62153d06cc7a2ece53824640f384a157d/reports/fix-report-issue-7.md)

Not covered here: `run_native_runtime_smoke.ps1` / `xpact_native_runtime.ecf` (same mingw problem, separate issue), the Assertions smoke test (known crash at load), and #4.

Leaving this open until the fix reaches `main`, like #2. Revert with `.\student\tools\fix.ps1 revert -Issue 7 -Commit eb6fc5d`.
