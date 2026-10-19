XPACT ERROR REPORT - 2026-10-19
===============================

Three failures seen on 2026-10-19. Each one is reported separately below in the
format from guide.txt Part 1.

Common environment (applies to all three)
-----------------------------------------
  Commit:          Most likely 4f717432df166f73166343130937f533c0e9d91c
                   (codex/w3c-xml-conformance-benchmarks), not exact. The runs
                   were made in a copied folder,
                   C:\Users\masou\Desktop\Lia\xpact3.0\xpact-codex-w3c-xml-conformance-benchmarks,
                   which is not a git clone. Its name points to that branch,
                   and the files involved (src\xp_native_parser.e,
                   tests\xp_test_root.e, scripts\build_native_eiffel.ps1,
                   scripts\import_msvc_environment.ps1,
                   scripts\run_eiffel_test_matrix.ps1) are byte-identical to
                   that commit, and also to main @ fee611a. Next runs should
                   be made in the git clone so the hash is exact.
  EiffelStudio:    ISE EiffelStudio 25.12.9.8922 - win64
                   (C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard)
  MSVC:            Visual Studio 18 Community (catalog version 18.10.3),
                   MSVC toolset 14.51.36231
  OS:              Windows 11 Home 10.0.26300
  Shell:           Windows PowerShell 5.1
  ISE_EIFFEL:      not set (user, machine and process scope all empty)


===========================================================================
ERROR 1 - build_native_eiffel.ps1 cannot find the Eiffel runtime include dir
===========================================================================

  Command:         .\scripts\build_native_eiffel.ps1     (default parameters:
                   -BuildTier Production, -OutputDir build\native-eiffel)
  Build step:      Native DLL build, C compilation of the first object
                   (Compile-CObject -> Get-IseInclude). The build stopped
                   before any C file was compiled.
  Assertions/mode: n/a (build failed before the build tier mattered;
                   requested tier was Production)
  Loaded library:  none - no DLL was produced (build\native-eiffel is empty)
  Callbacks/chunks/input: n/a (no parse was run)
  Exit status:     nonzero (script terminated by `throw`)

  Expected:        xpact.dll built into build\native-eiffel, then smoke test.
  Actual:          Script stopped after loading the MSVC environment.

  Error output:
    Loaded Visual Studio C++ x64 environment from C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
    Cannot find Eiffel runtime include directory.
    At ...\scripts\build_native_eiffel.ps1:46 char:2
    +     throw "Cannot find Eiffel runtime include directory."
        + CategoryInfo          : OperationStopped: (Cannot find Eif...lude directory.:String) [], RuntimeException
        + FullyQualifiedErrorId : Cannot find Eiffel runtime include directory.

  Observations (confirmed):
    - Get-IseInclude (scripts\build_native_eiffel.ps1:35-47) looks in
      $env:ISE_EIFFEL\studio\spec\win64\include, then falls back to the
      hard-coded path C:\El2502E\studio\spec\win64\include.
    - ISE_EIFFEL is not set on this machine, and C:\El2502E does not exist.
    - The include directory does exist at
      C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard\studio\spec\win64\include
    - `ec` itself is found on PATH, so EiffelStudio is installed; only the
      script's lookup fails.

  Possible explanations (unconfirmed):
    - The fallback path is from a different install (EiffelStudio 25.02
      Enterprise, "El2502E") and does not match a standard 25.12 install.
    - Setting ISE_EIFFEL to the 25.12 install folder should let the script
      continue, e.g.
        $env:ISE_EIFFEL = "C:\Program Files\Eiffel Software\EiffelStudio 25.12 Standard"
      Not yet tried. A longer-term fix would be to derive the path from the
      location of ec.exe instead of a hard-coded folder.


===========================================================================
ERROR 2 - Postcondition final_finished_or_suspended violated in
          test_garbage_collection_suspension (assertions-on / Workbench)
===========================================================================

  Command:         .\scripts\run_phase1.ps1
                   which runs
                   .\scripts\run_eiffel_test_matrix.ps1 -AssertionMode All -BuildMode All
  Failing cell:    Assertions On / Workbench
                   (target xpact_tests_assertions, executable
                   EIFGENs\xpact_tests_assertions\W_code\xpact_tests.exe)
  Loaded library:  none - xpact_tests.exe is a pure Eiffel executable and
                   does not load xpact.dll / xpact_assertions.dll
  Exit status:     nonzero from xpact_tests.exe (the matrix script threw
                   "Test executable failed for assertions-on / Workbench.")

  Failing test:    XP_TEST_ROOT.test_garbage_collection_suspension
                   (tests\xp_test_root.e:1041), called from make @34
  Repro input:     the literal string "<root/>" (7 bytes, inline in the
                   test - no input file)
  Call that failed:
                   create l_native.make
                   l_native.set_suspend_gc_during_parse (True)
                   l_status := l_native.parse ("<root/>", True)
                   (tests\xp_test_root.e:1070-1072)
  Callbacks:       none (XP_NATIVE_PARSER created with `make`, no handler
                   set). Earlier steps of the same test use
                   XP_NULL_EVENT_HANDLER and pass.
  Chunks:          whole document in one call, a_is_final = True
  GC state:        collection_on before the call, GC suspension requested

  Expected:        parse returns Xml_status_ok, parsing_status = Xml_finished,
                   and GC is collecting again afterwards (test lines 1073-1074).
  Actual:          parse fails its own postcondition before returning.

  Error output (full trace, also saved in exception_trace.log, 2026-10-19 18:32):
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
    At ...\scripts\run_eiffel_test_matrix.ps1:81 char:3

  Observations (confirmed):
    - The violated clause is src\xp_native_parser.e:756:
        final_finished_or_suspended: a_is_final implies
          (parsing_status = Xml_finished or parsing_status = Xml_suspended)
      So after a final parse of "<root/>" with GC suspension on,
      parsing_status was neither Xml_finished nor Xml_suspended.
    - With suspend_gc_during_parse = True, parse runs the work through
      XP_GC_CRITICAL_SECTION.execute (agent parse_status_into_cell ...)
      (xp_native_parser.e:745-749). The same input through the non-GC path
      is not what this test exercises.
    - The same failure is already listed as open in TODO_CODE_REVIEW.md:92-93
      and as task B03 in docs\xpact-student-introduction.md:386.
    - The matrix order is Off/Workbench, Off/Finalized, On/Workbench,
      On/Finalized. Only the tail of the console output was saved, so the
      results of the two assertions-off cells are not in this report, and
      On/Finalized was never run because the script stopped.
    - The assertions-off cells cannot be trusted as passes even if they
      showed exit 0: the failure signal there is a `check` that is compiled
      out (TODO_CODE_REVIEW.md:84-85, known bug).

  Possible explanations (unconfirmed):
    - The status may be set inside the agent/critical section on a path that
      does not update parsing_status (or updates a copy), so the returned
      Result is fine but parsing_status is left at Xml_parsing or an initial
      value. Next step: print parsing_status and the cell result just before
      the postcondition is evaluated.
    - No contract has been switched off. The contract stays on until it is
      clear whether the code, the contract or the test is wrong (task B03).


===========================================================================
ERROR 3 - "The input line is too long" while importing the MSVC environment
===========================================================================

  Command:         .\scripts\run_eiffel_test_matrix.ps1    (no parameters,
                   so -AssertionMode All -BuildMode All)
  Build step:      Before any compilation: dot-sourcing
                   scripts\import_msvc_environment.ps1, which runs
                   cmd.exe /s /c "vcvars64.bat >nul && set" (line 22).
  Assertions/mode: none ran - the script stopped before the first cell
  Loaded library:  none
  Callbacks/chunks/input: n/a
  Exit status:     nonzero (script terminated by `throw`)

  Expected:        MSVC environment loaded, then the four matrix cells run.
  Actual:          cmd.exe refused the command line, vcvars64.bat failed.

  Error output:
    The input line is too long.
    The syntax of the command is incorrect.
    Failed to import Visual Studio C++ environment from C:\Program Files\Microsoft Visual
    Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat
    At ...\scripts\import_msvc_environment.ps1:24 char:2
    +     throw "Failed to import Visual Studio C++ environment from $VcVar ...

  Observations (confirmed):
    - "The input line is too long." is a cmd.exe message: it appears when an
      expanded command line or environment variable goes past cmd's
      ~8191-character limit.
    - This run came after the run_phase1.ps1 run (Error 2) and the
      build_native_eiffel.ps1 run (Error 1), which both import the MSVC
      environment into the process with Set-Item Env:... 
    - In a fresh shell the PATH is about 1,040 characters (user PATH 511,
      machine PATH 526), well under the limit.

  Possible explanations (unconfirmed):
    - Each import in the same PowerShell window prepends the Visual Studio
      folders to PATH again (and to INCLUDE/LIB/LIBPATH), so after a few
      runs PATH passes cmd's limit and vcvars64.bat itself fails.
      Check: run `$env:Path.Length` in the window where it failed; then
      re-run the same command in a brand-new PowerShell window.
    - If confirmed, the script should skip the import when the environment
      is already loaded (e.g. when $env:VCToolsInstallDir is set), or run
      each script in a new process.


===========================================================================
NEXT STEPS
===========================================================================
  1. Fill in the commit hash from the git clone.
  2. Error 3: re-run the matrix in a new PowerShell window and save the full
     console output to a log file (not just the tail).
  3. Error 1: set ISE_EIFFEL for the session and re-run
     build_native_eiffel.ps1; report whether the DLL builds.
  4. Error 2: run the single cell
       .\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Workbench
     and then On/Finalized, and investigate parsing_status in the
     GC-suspension path (task B03) without disabling the contract.

Attached: exception_trace.log (Error 2). Full console logs were not saved
for these runs.
