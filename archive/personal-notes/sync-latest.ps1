# Refreshes this folder (a plain copy, not a git clone) with the latest
# student-Mass from the git clone. Run it before building or testing:
#   .\sync-latest.ps1
# Fixes are made only in the clone; this folder just receives them.
# Files that git deleted or moved since the last sync are removed here too;
# files git never tracked (your notes, EIFGENs, build) are left alone.
$ErrorActionPreference = "Stop"
$Clone = "C:\Users\masou\Desktop\Lia\xpact\xpactGit"
$Zip = Join-Path $env:TEMP "xpact-latest.zip"
$Marker = Join-Path $PSScriptRoot ".synced-commit"

git -C $Clone fetch -q origin
if ($LASTEXITCODE -ne 0) { throw "git fetch failed in $Clone" }
$Target = "$(git -C $Clone rev-parse origin/student-Mass)".Trim()

# The first sync with this script compares against 20e6bc3, the commit the
# folder was first synced to.
$Previous = if (Test-Path -LiteralPath $Marker) { (Get-Content -LiteralPath $Marker -Raw).Trim() } else { "20e6bc3" }
foreach ($Path in @(git -C $Clone diff --name-only --diff-filter=DR --no-renames $Previous $Target)) {
	if ($Path -like ".vscode/*") { continue }
	$Local = Join-Path $PSScriptRoot $Path
	if (Test-Path -LiteralPath $Local -PathType Leaf) {
		Remove-Item -LiteralPath $Local -Force
		Write-Host "Removed (deleted or moved in git): $Path"
	}
}

git -C $Clone archive --format=zip -o $Zip $Target -- . ":(exclude).vscode"
if ($LASTEXITCODE -ne 0) { throw "git archive failed in $Clone" }
Expand-Archive -Path $Zip -DestinationPath $PSScriptRoot -Force
Remove-Item -LiteralPath $Zip -Force
Set-Content -LiteralPath $Marker -Value $Target -Encoding ascii
Write-Host "Synced to student-Mass @ $($Target.Substring(0, 7))"
