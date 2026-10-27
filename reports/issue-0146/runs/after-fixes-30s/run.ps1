# All 2,585 W3C cases, both builds, nothing skipped (--all-cases).
# Code: local branch local/w3c-no-skips in C:\Users\masou\Desktop\Lia\xpact\w7-smoke (not pushed).
$ErrorActionPreference = "Stop"
$Code = "C:\Users\masou\Desktop\Lia\xpact\w7-smoke"
$Suite = "C:\Users\masou\Desktop\Lia\xpact\xpactGit\build\validation-corpora\w3c-xml-20130923\xmlconf"
$Python = "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe"
& $Python "$Code\scripts\run_w3c_conformance.py" --suite-dir $Suite --output-dir (Join-Path $PSScriptRoot "w3c-timeout-30s") --timeout 30 `
	--known-failures "$Code\benchmarks\w3c-known-failures.tsv" --all-cases `
	--engine "Finalized=$Code\EIFGENs\xpact_benchmarks\F_code\xpact_benchmarks.exe" `
	--engine "FinalizedAssertions=$Code\EIFGENs\xpact_benchmarks_assertions\F_code\xpact_benchmarks.exe" `
	--entity-engine "Finalized=$Code\build\w3c-dll\xpact_w3c_case.exe" `
	--entity-engine "FinalizedAssertions=$Code\build\w3c-dll\xpact_w3c_case_assertions.exe"
"EXIT=$LASTEXITCODE"
