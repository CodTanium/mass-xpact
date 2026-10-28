[CmdletBinding()]
param()
$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
$RunIdentity = [DateTime]::UtcNow.ToString("yyyyMMddTHHmmssZ-") + [Guid]::NewGuid().ToString("N").Substring(0,12)
$ProbeBuildRoot = Join-Path (Join-Path $RepoRoot "build/w3c-skip-investigation/external-probe-builds") $RunIdentity
New-Item -ItemType Directory -Force -Path $ProbeBuildRoot | Out-Null
. (Join-Path $RepoRoot "scripts/import_msvc_environment.ps1")
$EcPath = (Get-Command ec).Source
$InstallationRoot = Split-Path (Split-Path (Split-Path (Split-Path (Split-Path $EcPath))))
$env:ISE_EIFFEL = $InstallationRoot
$env:ISE_LIBRARY = $InstallationRoot
$env:ISE_PLATFORM = "win64"
$env:ISE_C_COMPILER = "msc_vc140"
$env:XPACT_SOURCE_ROOT = $RepoRoot
& ec -batch -clean -finalize -keep -config (Join-Path $PSScriptRoot "probe.ecf") -target probe -project_path (Join-Path $ProbeBuildRoot "project") *> (Join-Path $ProbeBuildRoot "eiffel.log")
if ($LASTEXITCODE -ne 0) { throw "Probe Eiffel compilation failed; see $ProbeBuildRoot/eiffel.log" }
$CodeRoot = Join-Path $ProbeBuildRoot "project/EIFGENs/probe/F_code"
Push-Location $CodeRoot
try {
 & finish_freezing *> (Join-Path $ProbeBuildRoot "c.log")
 if ($LASTEXITCODE -ne 0) { throw "Probe C compilation failed; see $ProbeBuildRoot/c.log" }
} finally { Pop-Location }
& python (Join-Path $PSScriptRoot "run_probe.py") --executable (Join-Path $CodeRoot "external_probe.exe") --output-dir (Join-Path $ProbeBuildRoot "campaign")
if ($LASTEXITCODE -ne 0) { throw "Diagnostic probe did not complete" }
