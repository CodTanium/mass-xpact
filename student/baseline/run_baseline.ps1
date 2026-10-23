[CmdletBinding()]
param(
	# Steps to run (default: all). Names match the step list below.
	[string[]] $Step = @("environment", "event-trace", "matrix-workbench", "matrix-finalized", "matrix-finalized-keep", "native-runtime-smoke", "assertions-dll", "xmlconf"),
	# Where the logs go, relative to the repository root (default: this
	# folder's logs\, which holds the week 2 run).
	[string] $LogDir = ""
)

# ---------------------------------------------------------------------------
# Assertions-enabled baseline for xpact (student plan, week 2).
#
# Records the environment and a fingerprint of the sources, follows parser
# events for small sample documents, and runs every assertions-enabled test
# lane. Every step writes its own log under .\logs and a row in
# .\logs\results.tsv. A failing step does NOT stop the run: known failures
# are part of the baseline.
# ---------------------------------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Here = $PSScriptRoot
# This folder is student\baseline, two levels below the repository root.
$RepoRoot = Split-Path -Parent (Split-Path -Parent $Here)
$Logs = if ($LogDir) { Join-Path $RepoRoot $LogDir } else { Join-Path $Here "logs" }
New-Item -ItemType Directory -Force -Path $Logs | Out-Null
$ResultsPath = Join-Path $Logs "results.tsv"
if (-not (Test-Path -LiteralPath $ResultsPath)) {
	"step`tstarted`tseconds`texit_code`tcommand`tlog" | Set-Content -LiteralPath $ResultsPath -Encoding UTF8
}

# Runs $Block with stderr allowed, sends all output to $LogName, and records
# the exit code. Never throws for a failing native command.
function Invoke-Step {
	param(
		[string] $Name,
		[string] $Command,
		[scriptblock] $Block
	)
	$Log = Join-Path $Logs "$Name.log"
	Write-Host "== $Name =="
	Write-Host "   $Command"
	$Started = Get-Date
	$SavedErrorActionPreference = $ErrorActionPreference
	$ErrorActionPreference = "Continue"
	Push-Location $RepoRoot
	try {
		"# $Command`n# started $($Started.ToString('s'))`n" | Set-Content -LiteralPath $Log -Encoding UTF8
		# Blank stderr lines arrive as empty RemoteExceptions; log them as blank.
		& $Block *>&1 | ForEach-Object {
			if ($_ -is [System.Management.Automation.ErrorRecord] -and $_.Exception -is [System.Management.Automation.RemoteException]) { $_.Exception.Message } else { "$_" }
		} | Add-Content -LiteralPath $Log -Encoding UTF8
		$ExitCode = $LASTEXITCODE
	}
	catch {
		"$_" | Add-Content -LiteralPath $Log -Encoding UTF8
		$ExitCode = -1
	}
	finally {
		Pop-Location
		$ErrorActionPreference = $SavedErrorActionPreference
	}
	$Seconds = [math]::Round(((Get-Date) - $Started).TotalSeconds)
	"# exit code $ExitCode after $Seconds s" | Add-Content -LiteralPath $Log -Encoding UTF8
	"$Name`t$($Started.ToString('s'))`t$Seconds`t$ExitCode`t$Command`tlogs\$Name.log" | Add-Content -LiteralPath $ResultsPath -Encoding UTF8
	Write-Host "   exit code $ExitCode after $Seconds s -> logs\$Name.log"
}

# Child scripts run in their own PowerShell process, exactly as a developer
# would run them from the repository root.
function Invoke-RepoScript {
	param([string] $Script, [string[]] $Arguments)
	& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $RepoRoot $Script) @Arguments
}

if ($Step -contains "environment") {
	Invoke-Step "environment" "tool versions, settings and source fingerprint" {
		"date:            $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz'))"
		$Os = Get-CimInstance Win32_OperatingSystem
		"os:              $($Os.Caption) $($Os.Version) $($Os.OSArchitecture)"
		"powershell:      $($PSVersionTable.PSVersion)"
		"ec:              $((& ec -version 2>&1 | Out-String).Trim())"
		"ec path:         $((Get-Command ec).Source)"
		"python:          $((& python --version 2>&1 | Out-String).Trim())"
		# Pythons installed with uv are not on PATH (see student\README.md).
		$UvPython = Join-Path $env:APPDATA "uv\python"
		if (Test-Path -LiteralPath $UvPython) {
			"python (uv):     $((Get-ChildItem -LiteralPath $UvPython -Directory -Filter 'cpython-*' | Select-Object -ExpandProperty Name) -join ', ')"
		}
		"ISE_EIFFEL:      $env:ISE_EIFFEL"
		"ISE_C_COMPILER:  '$env:ISE_C_COMPILER' (empty = mingw default)"
		$VsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
		if (Test-Path -LiteralPath $VsWhere) {
			"visual studio:   $((& $VsWhere -latest -property displayName | Out-String).Trim()) $((& $VsWhere -latest -property installationVersion | Out-String).Trim())"
		}
		$VcTools = Get-ChildItem "${env:ProgramFiles}\Microsoft Visual Studio\*\*\VC\Tools\MSVC\*" -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
		"msvc toolsets:   $($VcTools -join ', ')"
		$Precomp = Join-Path $env:USERPROFILE "Documents\Eiffel User Files\25.12\precomp\spec"
		if (Test-Path -LiteralPath $Precomp) {
			"precompiles:     $((Get-ChildItem -LiteralPath $Precomp -Recurse -Directory -Filter 'base-safe*' | ForEach-Object { $_.FullName.Substring($Precomp.Length + 1) }) -join ', ')"
		}
		""
		"assertion settings (ECF targets used below):"
		foreach ($Ecf in @("tests\xpact_tests.ecf", "tests\xpact_native_runtime.ecf", "tests\xpact_native_library.ecf", "xpact.ecf", "student\baseline\event-trace\xp_event_trace.ecf")) {
			$Text = Get-Content -LiteralPath (Join-Path $RepoRoot $Ecf) -Raw
			foreach ($Match in [regex]::Matches($Text, '(?s)<target name="([^"]+)">.*?<assertions precondition="(\w+)" postcondition="(\w+)" check="(\w+)" invariant="(\w+)"')) {
				"  {0,-45} {1,-36} pre={2} post={3} check={4} invariant={5}" -f $Ecf, $Match.Groups[1].Value, $Match.Groups[2].Value, $Match.Groups[3].Value, $Match.Groups[4].Value, $Match.Groups[5].Value
			}
		}
		""
		"git commit:      $((& git -C $RepoRoot rev-parse HEAD 2>&1 | Out-String).Trim())"
		"git branch:      $((& git -C $RepoRoot rev-parse --abbrev-ref HEAD 2>&1 | Out-String).Trim())"
		"git changes:     $((@(& git -C $RepoRoot status --porcelain 2>&1)).Count) uncommitted path(s)"
		""
		# Also identify the exact sources
		# by content: one SHA-256 per file, plus one combined fingerprint.
		# (-Include is ignored together with -LiteralPath in PowerShell 5.1,
		# so filter on the extension instead.)
		$Files = @(Get-ChildItem -LiteralPath $RepoRoot -Recurse -File |
			Where-Object { $_.Extension -in @(".e", ".ecf", ".c", ".h", ".ps1") -and $_.FullName -notmatch '\\(EIFGENs|build|dist|xmlTests)\\' } |
			Sort-Object FullName)
		$Lines = foreach ($File in $Files) {
			"{0}  {1}" -f (Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $File.FullName.Substring($RepoRoot.Length + 1)
		}
		$Lines | Set-Content -LiteralPath (Join-Path $Logs "sources.sha256") -Encoding UTF8
		$Combined = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes(($Lines -join "`n")))
		"source files:    $($Files.Count) (*.e, *.ecf, *.c, *.h, *.ps1; list in logs\sources.sha256)"
		"source sha256:   $(($Combined | ForEach-Object { $_.ToString('x2') }) -join '')"
		$global:LASTEXITCODE = 0
	}
}

if ($Step -contains "event-trace") {
	$TraceEcf = "student\baseline\event-trace\xp_event_trace.ecf"
	Invoke-Step "event-trace" "ec -batch -clean -config `"$TraceEcf`" -target xpact_event_trace; finish_freezing; xpact_event_trace.exe inputs\*.xml" {
		& ec -batch -clean -config $TraceEcf -target xpact_event_trace
		if ($LASTEXITCODE -ne 0) { return }
		Push-Location (Join-Path $RepoRoot "EIFGENs\xpact_event_trace\W_code")
		try { & finish_freezing } finally { Pop-Location }
		if ($LASTEXITCODE -ne 0) { return }
		$Inputs = @(Get-ChildItem -LiteralPath (Join-Path $Here "event-trace\inputs") -Filter *.xml | Sort-Object Name |
			ForEach-Object { "student\baseline\event-trace\inputs\$($_.Name)" })
		$Trace = Join-Path $Logs "event-trace-output.txt"
		& (Join-Path $RepoRoot "EIFGENs\xpact_event_trace\W_code\xpact_event_trace.exe") @Inputs 2>&1 | Tee-Object -FilePath $Trace
	}
}

if ($Step -contains "matrix-workbench") {
	Invoke-Step "matrix-workbench" ".\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Workbench" {
		Invoke-RepoScript "scripts\run_eiffel_test_matrix.ps1" @("-AssertionMode", "On", "-BuildMode", "Workbench")
	}
}

if ($Step -contains "matrix-finalized") {
	Invoke-Step "matrix-finalized" ".\scripts\run_eiffel_test_matrix.ps1 -AssertionMode On -BuildMode Finalized" {
		Invoke-RepoScript "scripts\run_eiffel_test_matrix.ps1" @("-AssertionMode", "On", "-BuildMode", "Finalized")
	}
}

# run_eiffel_test_matrix.ps1 finalizes with "ec -finalize" but without "-keep",
# and finalizing without -keep REMOVES all assertion checks. This extra lane is
# the same build with -keep, i.e. a finalized build that really checks contracts.
if ($Step -contains "matrix-finalized-keep") {
	Invoke-Step "matrix-finalized-keep" "ec -batch -clean -finalize -keep -config tests\xpact_tests.ecf -target xpact_tests_assertions; finish_freezing; xpact_tests.exe" {
		& ec -batch -clean -finalize -keep -config tests\xpact_tests.ecf -target xpact_tests_assertions
		if ($LASTEXITCODE -ne 0) { return }
		Push-Location (Join-Path $RepoRoot "EIFGENs\xpact_tests_assertions\F_code")
		try { & finish_freezing } finally { Pop-Location }
		if ($LASTEXITCODE -ne 0) { return }
		& (Join-Path $RepoRoot "EIFGENs\xpact_tests_assertions\F_code\xpact_tests.exe")
	}
}

if ($Step -contains "native-runtime-smoke") {
	Invoke-Step "native-runtime-smoke" ".\scripts\run_native_runtime_smoke.ps1 -AssertionMode On" {
		Invoke-RepoScript "scripts\run_native_runtime_smoke.ps1" @("-AssertionMode", "On")
	}
}

if ($Step -contains "assertions-dll") {
	Invoke-Step "assertions-dll" ".\scripts\build_native_eiffel.ps1 -BuildTier Assertions   (with smoke, no -SkipSmoke)" {
		Invoke-RepoScript "scripts\build_native_eiffel.ps1" @("-BuildTier", "Assertions")
	}
}

if ($Step -contains "xmlconf") {
	Invoke-Step "xmlconf" ".\scripts\run_xmlconf_conformance.ps1   (xpact.exe, assertions on)" {
		Invoke-RepoScript "scripts\run_xmlconf_conformance.ps1" @()
		$Summary = Join-Path $RepoRoot "build\xmlconf-conformance\xmlconf-summary.txt"
		if (Test-Path -LiteralPath $Summary) {
			Copy-Item -LiteralPath $Summary -Destination (Join-Path $Logs "xmlconf-summary.txt") -Force
			Copy-Item -LiteralPath (Join-Path $RepoRoot "build\xmlconf-conformance\xmlconf-results.tsv") -Destination (Join-Path $Logs "xmlconf-results.tsv") -Force
		}
	}
}

Write-Host ""
Write-Host "Results: $ResultsPath"
Get-Content -LiteralPath $ResultsPath | ForEach-Object { Write-Host "  $_" }
