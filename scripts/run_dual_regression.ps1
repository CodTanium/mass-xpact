[CmdletBinding()]
param(
    [switch] $Offline,
    [ValidateRange(1, 3600)] [int] $TimeoutSeconds = 60
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "import_msvc_environment.ps1")
$RunnerArguments = @("--timeout", "$TimeoutSeconds")
if ($Offline) { $RunnerArguments += "--offline" }
& python (Join-Path $PSScriptRoot "run_dual_regression.py") @RunnerArguments
if ($LASTEXITCODE -ne 0) {
    throw "Dual regression returned $LASTEXITCODE. xpact failures (exit 1) and incomplete runs (exit 2) are recorded in the printed run directory."
}
