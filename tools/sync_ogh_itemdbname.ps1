# Restores ItemDBNameTbl.lub from proasia.grf (CP949) and merges OGH Temporal Circlet entries.
#
# Usage:
#   .\tools\sync_ogh_itemdbname.ps1 `
#     -ClientRoot "D:\RO\PRO-Ragnarok Asia - Copy"
#
# Or with an already-extracted clean file:
#   .\tools\sync_ogh_itemdbname.ps1 `
#     -ClientItemDB "D:\RO\data\luafiles514\lua files\ItemDBNameTbl.lub" `
#     -SkipGrfExtract

param(
	[string]$ClientRoot,
	[string]$ClientItemDB,
	[string]$GrfPath,
	[switch]$SkipGrfExtract
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$patchPath = Join-Path $root 'clientside\data\luafiles514\lua files\ItemDBNameTbl_ogh.lub'
$extractor = Join-Path $PSScriptRoot 'Extract-GrfFile.ps1'
$enc949 = [System.Text.Encoding]::GetEncoding(949)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$internalPath = 'data\luafiles514\lua files\ItemDBNameTbl.lub'

if (-not $ClientItemDB) {
	if (-not $ClientRoot) {
		throw 'Provide -ClientRoot or -ClientItemDB'
	}
	$ClientItemDB = Join-Path $ClientRoot $internalPath
}

if (-not $GrfPath) {
	if (-not $ClientRoot) {
		throw 'Provide -ClientRoot or -GrfPath for GRF extraction'
	}
	$GrfPath = Join-Path $ClientRoot 'proasia.grf'
}

if (-not (Test-Path $patchPath)) {
	throw "Missing repo patch: $patchPath"
}

if (-not (Test-Path $extractor)) {
	throw "Missing extractor: $extractor"
}

$clientDir = Split-Path $ClientItemDB -Parent
if (-not (Test-Path $clientDir)) {
	New-Item -ItemType Directory -Path $clientDir -Force | Out-Null
}

$tempExtract = Join-Path $clientDir 'ItemDBNameTbl.lub.grf_extract'
if (-not $SkipGrfExtract) {
	if (-not (Test-Path $GrfPath)) {
		throw "GRF not found: $GrfPath"
	}
	& $extractor -GrfPath $GrfPath -InternalPath $internalPath -OutputPath $tempExtract
	$basePath = $tempExtract
}
else {
	if (-not (Test-Path $ClientItemDB)) {
		throw "Client ItemDBNameTbl.lub not found: $ClientItemDB"
	}
	$basePath = $ClientItemDB
}

function Read-Cp949Text {
	param([string]$Path)
	$bytes = [System.IO.File]::ReadAllBytes($Path)
	if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
		$bytes = $bytes[3..($bytes.Length - 1)]
	}
	return $enc949.GetString($bytes)
}

function Write-Cp949Text {
	param(
		[string]$Path,
		[string]$Text
	)
	if (-not $Text.EndsWith("`r`n")) {
		$Text = $Text.TrimEnd("`r", "`n") + "`r`n"
	}
	[System.IO.File]::WriteAllText($Path, $Text, $enc949)
}

$baseText = Read-Cp949Text -Path $basePath
$qCount = ([System.Text.Encoding]::GetEncoding(949).GetBytes($baseText) | Where-Object { $_ -eq 0x3F }).Count
if ($qCount -gt 500) {
	throw "Base ItemDBNameTbl looks corrupted ($qCount ASCII '?' bytes). Re-extract from proasia.grf."
}

$closeIdx = $baseText.LastIndexOf("`r`n}")
if ($closeIdx -lt 0) { $closeIdx = $baseText.LastIndexOf("`n}") }
if ($closeIdx -lt 0) {
	throw 'Could not find closing brace in ItemDBNameTbl.lub'
}

$patchLines = [System.IO.File]::ReadAllLines($patchPath, $utf8NoBom) |
	Where-Object { $_.Trim() -ne '' -and $_.Trim() -ne ',' }
$patchBlock = ($patchLines -join "`r`n").TrimEnd().TrimEnd(',')
if (-not $patchBlock.EndsWith(',')) {
	$patchBlock += ','
}

$merged = $baseText.Insert($closeIdx, "`r`n`t$($patchBlock -replace "`r`n","`r`n`t")`r`n")

if (Test-Path $ClientItemDB) {
	$backupPath = "$ClientItemDB.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
	Copy-Item $ClientItemDB $backupPath
	Write-Host "Backup:  $backupPath"
}

Write-Cp949Text -Path $ClientItemDB -Text $merged
Write-Host "Patched: $ClientItemDB"
Write-Host "OGH entries merged: $($patchLines.Count)"

if ((Test-Path $tempExtract) -and -not $SkipGrfExtract) {
	Remove-Item $tempExtract -Force
}

Write-Host ''
Write-Host 'Restart the client fully, then test Oscar @ glast_01 137,291.'
