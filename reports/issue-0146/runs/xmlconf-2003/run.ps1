# The xmlconf folder in the project root (W3C CVS snapshot, xmlconf.xml revision 1.6 of 2003-11-13),
# all cases, both builds, nothing skipped. Code: local branch local/w3c-no-skips in w7-smoke (not pushed).
$ErrorActionPreference = "Stop"
$Code = "C:\Users\masou\Desktop\Lia\xpact\w7-smoke"
$Suite = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "xmlconf"
$Python = "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe"
& $Python "$Code\scripts\run_w3c_conformance.py" --suite-dir $Suite --output-dir (Join-Path $PSScriptRoot "w3c") --timeout 30 --all-cases `
	--engine "Finalized=$Code\EIFGENs\xpact_benchmarks\F_code\xpact_benchmarks.exe" `
	--engine "FinalizedAssertions=$Code\EIFGENs\xpact_benchmarks_assertions\F_code\xpact_benchmarks.exe" `
	--entity-engine "Finalized=$Code\build\w3c-dll\xpact_w3c_case.exe" `
	--entity-engine "FinalizedAssertions=$Code\build\w3c-dll\xpact_w3c_case_assertions.exe"
"EXIT=$LASTEXITCODE"
