# Issue #3: Finding: postcondition final_finished_or_suspended fails in test_garbage_collection_suspension (B03)

Archived from <https://github.com/andersoxie/xpact/issues/3> on 2026-10-28 20:22 UTC.

| | |
|---|---|
| State | closed (completed) |
| Author | CodTanium |
| Created | 2026-10-19 21:25 |
| Closed | 2026-10-26 12:13 |
| Labels | `bug`, `type:finding`, `group:C-correctness`, `D3-advanced`, `P0`, `investigation` |
| Milestone | Week 2 - Baseline |

## Description

## Report details

| Item | Value |
|---|---|
| Git commit | **Rerun:** `cada501ca3117135d3649e1e8ca45b2ccc717748` (`student-Mass`, git clone, exact). **Original run** (2026-10-19): copied folder `xpact3.0\...`, not a git clone, most likely `4f71743`. |
| Input file / SHA-256 | No file: the input is the literal string `<root/>` (7 bytes) inside the test, `tests/xp_test_root.e:1072`. SHA-256 of those 7 bytes: `6238462c4873df4c50bc1a901ece576b2d166b0156802c88a05a85b1f5d511c7` |
| Exact command | **Rerun:** `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Workbench` (run as `powershell -NoProfile -ExecutionPolicy Bypass -File ...`). **Original:** `.\scripts\run_phase1.ps1`, which runs `run_eiffel_test_matrix.ps1 -AssertionMode All -BuildMode All` |
| Compiler versions | EiffelStudio 25.12.9.8922 win64 · Visual Studio 18 Community 18.10.3, MSVC 14.51.36231 · Windows 11 Home 10.0.26300 · Windows PowerShell 5.1 |
| Assertions / build mode | Assertions **On** (target `xpact_tests_assertions`: precondition, postcondition, check, invariant, loop, supplier_precondition all true), **Workbench** |
| Loaded library | None: `EIFGENs\xpact_tests_assertions\W_code\xpact_tests.exe` is a plain Eiffel program; it does not load `xpact.dll` or `xpact_assertions.dll` |
| Callbacks | None: `XP_NATIVE_PARSER` created with `make`, no event handler. (Earlier steps of the same test use `XP_NULL_EVENT_HANDLER` and pass.) |
| Chunk sizes | Whole document in one call, `is_final = True`, no split points |
| Expected | `l_native.parse ("<root/>", True)` with `set_suspend_gc_during_parse (True)` returns `Xml_status_ok`, `parsing_status = Xml_finished`, and GC is collecting again afterwards (`tests/xp_test_root.e:1070-1074`) |
| Actual | `XP_NATIVE_PARSER.parse` violates its postcondition `final_finished_or_suspended` before returning |
| Exit status | **1** from `xpact_tests.exe` (run directly: `EXIT=1`); **1** from the matrix script |

Expectations for the reruns were written to a file at 2026-10-20 00:39, before running anything. For the original run (2026-10-19) the expectation was not written down beforehand; it is recorded here afterwards.

The call that fails (`tests/xp_test_root.e:1069-1072`), with GC collection on before the call:

```eiffel
l_memory.collection_on
create l_native.make
l_native.set_suspend_gc_during_parse (True)
l_status := l_native.parse ("<root/>", True)
```

## Error output: rerun at cada501

```text
xpact_tests: system execution failed.
Following is the set of recorded exceptions:

-------------------------------------------------------------------------------
Class / Object      Routine                Nature of exception           Effect
-------------------------------------------------------------------------------
XP_NATIVE_PARSER    parse @10              final_finished_or_suspended: 
<000000000475ADA8>                         Postcondition violated.       Fail
-------------------------------------------------------------------------------
XP_NATIVE_PARSER    parse @10                                           
<000000000475ADA8>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        test_garbage_collection_suspension @18
<000000000450F588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        make @34                                            
<000000000450F588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        root's creation                                     
<000000000450F588>                         Routine failure.              Exit
-------------------------------------------------------------------------------
Test executable failed for assertions-on / Workbench.
At C:\Users\masou\Desktop\Lia\xpact\xpactGit\scripts\run_eiffel_test_matrix.ps1:81 char:3
+         throw "Test executable failed for $AssertionLabel / $Mode."
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Test executable...on / Workbench.:String) [], RuntimeException
    + FullyQualifiedErrorId : Test executable failed for assertions-on / Workbench.
```

<details><summary>Full console output (issue3-matrix-on-workbench.txt)</summary>

```text
commit cada501ca3117135d3649e1e8ca45b2ccc717748
== xpact tests: assertions-on / Workbench ==
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
	C:\Users\masou\Desktop\Lia\xpact\xpactGit\EIFGENs\xpact_tests_assertions\W_code
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
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c einit.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eparents.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c evisib.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c ececil.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c enames.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c ecall.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c efrozen.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eplug.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eskelet.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c epattern.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c emain.c
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c eoption.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
cd C1 && if [ ! -f finished ] ; then  "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/make.exe" Cobj1.o ; fi  && cd ..
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
if [ ! -f ../../../xpact_tests.rc ] ; then "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/cp" "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/config/win64/mingw/eiffel.rc" ../../../xpact_tests.rc ; fi 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
make.exe[1]: Entering directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/C1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc" -O0 -pipe -imacros eif_config.mingw.h -D_WIN32_WINNT=0x0500 -DWINVER=0x0500 -D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN   -DWORKBENCH -I"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/include" -I. -I"..\..\..\..\include" -I"..\..\..\..\native" -c big_file_C1_c.c
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/windres" --preprocessor='"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/cpp.exe"' -I../../.. ../../../xpact_tests.rc -O coff -o xpact_tests.res
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:92: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
c:\\program files\\eiffel software\\eiffelstudio 25.12 standard\\gcc\\win64\\mingw\\bin\\../lib/gcc/x86_64-w64-mingw32/4.4.5/include/xmmintrin.h:859: digit exceeds base
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/E1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f Cobj1.o
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/ld" -r -o Cobj1.o big_file_C1_c.o 
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/touch" finished
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f big_file_C1_c.o 
make.exe[1]: Leaving directory `/c/Users/masou/Desktop/Lia/xpact/xpactGit/EIFGENs/xpact_tests_assertions/W_code/C1'
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/msys/1.0/bin/rm" -f xpact_tests.exe
"C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/gcc/win64/mingw/bin/gcc"  -mconsole -o xpact_tests.exe E1/emain.o "c:\users\masou\documents\eiffel user files\25.12\precomp\spec\win64\EIFGENs\base-safe\W_code/mingw/precomp.lib" xpact_tests.res E1/eparents.o  E1/einit.o  E1/ececil.o  E1/evisib.o  E1/enames.o  E1/eskelet.o  E1/eplug.o  E1/ecall.o  E1/efrozen.o  E1/epattern.o  E1/eoption.o  C1/Cobj1.o   "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard/studio/spec/win64/lib/mingw/wkbench.a" -luser32 -lws2_32 -ladvapi32 -lgdi32 -lshell32 -lmsimg32 -lcomdlg32 -luuid -lole32 -loleaut32 -lcomctl32 -lmpr -lshlwapi -lwinspool -lstdc++ 
echo done > completed.eif
C compilation completed

xpact_tests: system execution failed.
Following is the set of recorded exceptions:

-------------------------------------------------------------------------------
Class / Object      Routine                Nature of exception           Effect
-------------------------------------------------------------------------------
XP_NATIVE_PARSER    parse @10              final_finished_or_suspended: 
<000000000475ADA8>                         Postcondition violated.       Fail
-------------------------------------------------------------------------------
XP_NATIVE_PARSER    parse @10                                           
<000000000475ADA8>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        test_garbage_collection_suspension @18
<000000000450F588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        make @34                                            
<000000000450F588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        root's creation                                     
<000000000450F588>                         Routine failure.              Exit
-------------------------------------------------------------------------------
Test executable failed for assertions-on / Workbench.
At C:\Users\masou\Desktop\Lia\xpact\xpactGit\scripts\run_eiffel_test_matrix.ps1:81 char:3
+         throw "Test executable failed for $AssertionLabel / $Mode."
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Test executable...on / Workbench.:String) [], RuntimeException
    + FullyQualifiedErrorId : Test executable failed for assertions-on / Workbench.
 
EXIT=1 after 7s
```

</details>

## Error output: original run, 2026-10-19 (full, as pasted)

```text
run_phase1.ps1
echo done > completed.eif
C compilation completed
xpact_tests: system execution failed.
Following is the set of recorded exceptions:

-------------------------------------------------------------------------------
Class / Object      Routine                Nature of exception           Effect
-------------------------------------------------------------------------------
XP_NATIVE_PARSER    parse @10              final_finished_or_suspended:
<000000000444EDA8>                         Postcondition violated.       Fail
-------------------------------------------------------------------------------
XP_NATIVE_PARSER    parse @10
<000000000444EDA8>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        test_garbage_collection_suspension @18
<0000000004203588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        make @34
<0000000004203588>                         Routine failure.              Fail
-------------------------------------------------------------------------------
XP_TEST_ROOT        root's creation
<0000000004203588>                         Routine failure.              Exit
-------------------------------------------------------------------------------
Test executable failed for assertions-on / Workbench.
At C:\Users\masou\Desktop\Lia\xpact3.0\xpact-codex-w3c-xml-conformance-benchmarks\scripts\run_eiffel_test_matrix.ps1:81 char:3
+         throw "Test executable failed for $AssertionLabel / $Mode."
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (Test executable...on / Workbench.:String) [], RuntimeException
    + FullyQualifiedErrorId : Test executable failed for assertions-on / Workbench.
```

## Observations
- Violated clause: `src/xp_native_parser.e:756`:
  `final_finished_or_suspended: a_is_final implies (parsing_status = Xml_finished or parsing_status = Xml_suspended)`.
  So after a final parse of `<root/>` with GC suspension on, `parsing_status` was neither `Xml_finished` nor `Xml_suspended`.
- With GC suspension on, `parse` runs through `XP_GC_CRITICAL_SECTION.execute (agent parse_status_into_cell ...)` (`src/xp_native_parser.e:745-749`).
- Same failure, same place, in both runs (only the object addresses differ).
- Already listed in `TODO_CODE_REVIEW.md:92-93` and as task B03 in `docs/xpact-student-introduction.md`.
- The rerun only ran the assertions-on / Workbench cell. On / Finalized was not run. The assertions-off cells can't show this failure (postconditions are off) and their exit code is not trustworthy (`check` is compiled out, `TODO_CODE_REVIEW.md:84-85`).

## Possible explanation (not confirmed)
`parsing_status` may not be updated on the GC-suspended path (inside the agent / critical section), so the returned status is fine but `parsing_status` stays at `Xml_parsing` or its initial value. Next step: print `parsing_status` and the cell result just before the postcondition is checked. The contract has not been switched off.

## Logs
- Rerun output: above
- Original report: [reports/error-report-2026-10-19.md](https://github.com/andersoxie/xpact/blob/student-Mass/reports/error-report-2026-10-19.md), error 2 (with `exception_trace.log`)

## Discussion

### CodTanium, 2026-10-19 23:02: comment

**B03 answer: the contract is wrong, not the code or the test.** Fix proposed in #12, **waiting for review by the parser's developer** (not merged).

**Root cause:** the outer loop variant `a_end_index - i` in `XP_NATIVE_PARSER.direct_start_tag_attributes` does not decrease when an iteration only sets `l_valid := False` without advancing `i`, as at the `/` of `<root/>`. With assertions on, the runtime raises "Non-decreasing loop variant". The loop itself terminates correctly.

**Why it looked like `final_finished_or_suspended`:** with GC suspension on, the parse runs inside `MEMORY.execute_without_collection`, whose `rescue ... retry` silently swallows the variant exception. The parse is abandoned and the outer postcondition of `parse` fails instead. Reported separately as #13.

**How it was found** (throwaway worktree, nothing committed):
1. Removed the swallowing rescue → the real exception appeared: `direct_start_tag_attributes`, "Non-decreasing loop variant".
2. Turned GC suspension off in the test → same failure, so it is **not GC-related**.

**Fix (#12):** variant → `a_end_index - i + l_valid.to_integer`. Behaviour unchanged, check stays on.

**Verification on the fix branch** (each cell in a fresh process, expectations written before testing):

| Cell | Before | After |
|---|---|---|
| On / Workbench | postcondition failure, exit 1 | "xpact Phase 1 tests: ok", **exit 0** |
| On / Finalized | not reached | ok, **exit 0** |
| Off / Workbench | (exit code not trusted) | ok, exit 0 |
| Off / Finalized | (exit code not trusted) | ok, exit 0 |

No other test failed after this one, although those tests had never run with assertions on before.

Fix report with the analysis, proof of the new variant and all logs: [reports/fix-report-issue-3.md](https://github.com/andersoxie/xpact/blob/d9f662f6c5455a09865124ff8b38f2092979a8c2/reports/fix-report-issue-3.md)

### CodTanium, 2026-10-21 23:59: comment

**New evidence, 2026-10-22 (through the DLL, #37).** B03 does not only break the GC-suspension test: it crashes `xpact_assertions.dll` on **every input with `/>`**, including `<root/>` itself.

| `xpact_assertions.dll` | whole-document crashes | all crashes | crashes without a trace |
|---|---:|---:|---:|
| current `student-Mass` (`42d6b40`) | 86 (84 of them inputs with `/>`) | 1,329 | 811 |
| `42d6b40` + **only** the B03 line from `d9f662f` | 2 (both #28) | 672 | 158 |

- **Confirmed:** with only the B03 change, no `/>` input crashes any more (`<root/>`, `<root/>junk`, all attribute and element-name cases).
- Most of these crashes print **no Eiffel trace** (the process just ends with `0xC0000409`); a few show `XP_NATIVE_PARSER direct_start_tag_attributes @11 a_end_index - i: Non-decreasing loop variant`. Losing the trace fits #13.
- The C smoke test `xpact_assertions_eiffel_dll_smoke.exe` **still crashes** (`0xC0000028`) with the B03 fix, so B03 is not the only cause of K3 (draft 07).

How it was done: separate worktree `C:\xpact\xpact-b03-check` at `42d6b40`, `git show d9f662f -- src | git apply`, `scripts\build_native_eiffel.ps1 -BuildTier Assertions -OutputDir build\native-eiffel-b03`; nothing committed. Details: [results README, finding 4](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/README.md#findings) · [diff](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/assertions-b03fix/b03-fix.diff) · [build log](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/assertions-b03fix/build.log) · [crash example](https://github.com/andersoxie/xpact/blob/fix/37-dll-test-program/student/results/dll-tests-2026-10-22/assertions/crash-examples/b03-no-trace-c02-valid_none_whole.txt)

This supports reviewing draft PR #12. Still open: the PR waits for the parser developer's review.

### CodTanium, 2026-10-26 12:13: comment

**Verified fixed, 2026-10-26** (#104, report: https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/report.md).

- Fix: PR #12, merged by the supervisor; on `student-Mass` @ `41731c8`.
- Command: `.\scripts\run_eiffel_test_matrix.ps1 -AssertionMode All -BuildMode All` on the student PC (EiffelStudio 25.12, assertions on and off, finalized with `-keep`).
- Expected (written first): 4 × `xpact Phase 1 tests: ok`, exit 0.
- Actual: 4 × `xpact Phase 1 tests: ok`, exit 0. The assertions-on / Workbench lane runs `test_garbage_collection_suspension` without the `final_finished_or_suspended` violation ([log](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/logs/matrix-all.txt)).
- Through the DLL (the 2026-10-22 evidence above: crash on every `/>` input): `XpactDllTests` on `xpact_assertions.dll` 3,360/3,360, 0 crashes ([log](https://github.com/andersoxie/xpact/blob/student-Mass/reports/issue-0104/logs/10-dll-tests-assertions.txt)).

Closing. #13 (the GC wrapper that hid this error) stays open.
