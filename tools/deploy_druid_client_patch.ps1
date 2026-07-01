# Patches Episode 21 Druid job IDs into client datainfo (npcidentity.lub + jobname.lub).
# Fixes characters showing as Poring when the client lacks JT_DRUID (4351) mappings.
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ClientRoot)) {
	throw "Client folder not found: $ClientRoot"
}

$repoRoot = Split-Path $PSScriptRoot -Parent
$targetDir = Join-Path $ClientRoot "data\luafiles514\lua files\datainfo"
$snippetDir = Join-Path $repoRoot "clientside\data\luafiles514\lua files\datainfo\patches"

$identitySnippet = Get-Content -LiteralPath (Join-Path $snippetDir "druid_npcidentity_snippet.lub") -Raw
$jobnameSnippet = Get-Content -LiteralPath (Join-Path $snippetDir "druid_jobname_snippet.lub") -Raw

function Import-DruidPatch {
	param(
		[string]$FilePath,
		[string]$Marker,
		[string]$Snippet,
		[string]$Label
	)

	if (-not (Test-Path $FilePath)) {
		Write-Warning "Missing $Label at $FilePath — extract/copy datainfo from your GRF into data\ first."
		return $false
	}

	$content = Get-Content -LiteralPath $FilePath -Raw
	if ($content -match [regex]::Escape($Marker)) {
		Write-Host "$Label already contains $Marker — skipped."
		return $true
	}

	$insertAt = $content.LastIndexOf('}')
	if ($insertAt -lt 0) {
		throw "Could not find closing brace in $FilePath"
	}

	$patched = $content.Insert($insertAt, "`r`n$Snippet")
	Set-Content -LiteralPath $FilePath -Value $patched -NoNewline -Encoding UTF8
	Write-Host "Patched $Label"
	return $true
}

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$identityPath = Join-Path $targetDir "npcidentity.lub"
$jobnamePath = Join-Path $targetDir "jobname.lub"

Import-DruidPatch -FilePath $identityPath -Marker "JT_DRUID" -Snippet $identitySnippet -Label "npcidentity.lub" | Out-Null
Import-DruidPatch -FilePath $jobnamePath -Marker "JT_DRUID" -Snippet $jobnameSnippet -Label "jobname.lub" | Out-Null

Write-Host "Druid client patch finished. Target: $targetDir"
Write-Host "Requires Episode 21 player sprites (druid/karnos/alitea .act/.spr) in your client data or GRF."
