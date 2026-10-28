# The Jenkins "Benchmarks" stage script (ci/Jenkinsfile.all-tests), run locally.
Set-Location $args[0]
$env:ISE_C_COMPILER = "msc_vc140"
$env:Path = "$env:LOCALAPPDATA\Programs\Python\Python314;${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer;$env:Path"
$ErrorActionPreference = "Stop"
foreach ($ReportName in @("junit.xml", "results.tsv", "summary.json", "summary.md")) {
  $ReportPath = Join-Path "build/benchmarks/w3c-xml-conformance" $ReportName
  if (Test-Path -LiteralPath $ReportPath -PathType Leaf) {
    Remove-Item -LiteralPath $ReportPath -Force
  }
}
python -m unittest discover -s tests/python -p test_w3c_conformance.py
if ($LASTEXITCODE -ne 0) {
  throw "W3C conformance runner unit tests failed."
}
$BenchmarkArguments = @{ EiffelBuild = @("Finalized", "FinalizedAssertions"); W3cAllCases = $true; SkipWslC = $true }   # local deviation: no WSL on the student PC
.\scripts\run_benchmarks.ps1 @BenchmarkArguments
"STAGE-EXIT=$LASTEXITCODE"
