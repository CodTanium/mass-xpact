[CmdletBinding()]
param(
	# The GitHub repository to set up, as owner/name.
	[string] $Repo = "andersoxie/xpact",
	# Also create a Projects board and add every issue to it. Needs the
	# "project" scope: gh auth refresh -s project
	[switch] $CreateProject,
	[string] $ProjectTitle = "xpact student work (Mass)",
	# Print what would be created without changing anything on GitHub.
	[switch] $DryRun
)

# ---------------------------------------------------------------------------
# Creates the labels, milestones and issues defined next to this script on
# GitHub with the GitHub CLI (gh). Safe to run again: existing labels are
# updated, and milestones and issues with an existing title are skipped.
# ---------------------------------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Here = $PSScriptRoot
$Utf8 = New-Object System.Text.UTF8Encoding($false)

if (-not $DryRun -and -not (Get-Command gh -ErrorAction SilentlyContinue)) {
	throw "GitHub CLI not found. Install it with: winget install GitHub.cli   then open a new PowerShell window and run: gh auth login"
}

# Runs gh and fails on a nonzero exit code, unless -DryRun is set.
function Invoke-Gh {
	param([string[]] $Arguments)
	if ($DryRun) {
		Write-Host "   [dry run] gh $($Arguments -join ' ')"
		return
	}
	$Output = & gh @Arguments
	if ($LASTEXITCODE -ne 0) {
		throw "gh $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
	}
	$Output
}

# Reads an issue draft: a front-matter block (title, labels, milestone)
# between two "---" lines, followed by the issue body.
function Read-IssueDraft {
	param([string] $Path)
	$Lines = [System.IO.File]::ReadAllLines($Path, $Utf8)
	if ($Lines[0] -ne "---") { throw "No front matter in $Path" }
	$End = [array]::IndexOf($Lines, "---", 1)
	$Fields = @{}
	foreach ($Line in $Lines[1..($End - 1)]) {
		$Key, $Value = $Line -split ":\s*", 2
		$Fields[$Key.Trim()] = $Value.Trim().Trim('"')
	}
	[pscustomobject] @{
		Title     = $Fields["title"]
		Labels    = @($Fields["labels"] -split ",\s*")
		Milestone = $Fields["milestone"]
		Body      = ($Lines[($End + 1)..($Lines.Count - 1)] -join "`n").Trim() + "`n"
	}
}

if (-not $DryRun) {
	& gh auth status
	if ($LASTEXITCODE -ne 0) { throw "Not logged in. Run: gh auth login" }
}

Write-Host "== labels =="
foreach ($Label in (Get-Content -LiteralPath (Join-Path $Here "labels.json") -Raw -Encoding UTF8 | ConvertFrom-Json)) {
	Write-Host "   $($Label.name)"
	Invoke-Gh @("label", "create", $Label.name, "--repo", $Repo, "--color", $Label.color, "--description", $Label.description, "--force") | Out-Null
}

Write-Host "== milestones =="
$ExistingMilestones = if ($DryRun) { @() } else { @(Invoke-Gh @("api", "repos/$Repo/milestones?state=all&per_page=100", "--jq", ".[].title")) }
foreach ($Milestone in (Get-Content -LiteralPath (Join-Path $Here "milestones.json") -Raw -Encoding UTF8 | ConvertFrom-Json)) {
	if ($ExistingMilestones -contains $Milestone.title) {
		Write-Host "   exists: $($Milestone.title)"
		continue
	}
	Write-Host "   $($Milestone.title)"
	Invoke-Gh @("api", "repos/$Repo/milestones", "-X", "POST", "-f", "title=$($Milestone.title)", "-f", "description=$($Milestone.description)", "-f", "due_on=$($Milestone.due_on)T23:59:59Z") | Out-Null
}

Write-Host "== issues =="
$ExistingIssues = if ($DryRun) { @() } else { @(Invoke-Gh @("issue", "list", "--repo", $Repo, "--state", "all", "--limit", "1000", "--json", "title", "--jq", ".[].title")) }
$IssueUrls = New-Object System.Collections.Generic.List[string]
foreach ($File in (Get-ChildItem -LiteralPath (Join-Path $Here "issues") -Filter *.md | Sort-Object Name)) {
	$Issue = Read-IssueDraft $File.FullName
	if ($ExistingIssues -contains $Issue.Title) {
		Write-Host "   exists: $($Issue.Title)"
		continue
	}
	Write-Host "   $($Issue.Title)"
	$BodyFile = [System.IO.Path]::GetTempFileName()
	try {
		[System.IO.File]::WriteAllText($BodyFile, $Issue.Body, $Utf8)
		$Url = Invoke-Gh @("issue", "create", "--repo", $Repo, "--title", $Issue.Title, "--body-file", $BodyFile, "--label", ($Issue.Labels -join ","), "--milestone", $Issue.Milestone)
		if ($Url) { $IssueUrls.Add(("$Url").Trim()); Write-Host "      $Url" }
	} finally {
		Remove-Item -LiteralPath $BodyFile -Force -ErrorAction SilentlyContinue
	}
}

if ($CreateProject) {
	Write-Host "== project board =="
	$Owner = $Repo.Split("/")[0]
	$Project = Invoke-Gh @("project", "create", "--owner", $Owner, "--title", $ProjectTitle, "--format", "json")
	if (-not $DryRun) {
		$Number = ($Project | ConvertFrom-Json).number
		Invoke-Gh @("project", "link", "$Number", "--owner", $Owner, "--repo", $Repo) | Out-Null
		foreach ($Url in $IssueUrls) {
			Invoke-Gh @("project", "item-add", "$Number", "--owner", $Owner, "--url", $Url) | Out-Null
		}
		Write-Host "   project #$Number with $($IssueUrls.Count) issues. Set up its columns as described in student/github/README.md."
	}
}

Write-Host "done."
