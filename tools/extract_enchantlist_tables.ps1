# Extract Varmundt/Biosphere and Constellation EnchantList.lub table blocks from the repo cache.
# Usage:
#   .\tools\extract_enchantlist_tables.ps1
#   .\tools\extract_enchantlist_tables.ps1 -UpdateClient "D:\RO\data\luafiles514\lua files\Enchant\EnchantList.lub"

param(
	[string]$UpdateClient
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourcePath = Join-Path $root 'tools\_EnchantList_official.lub'
$biospherePatch = Join-Path $root 'clientside\data\luafiles514\lua files\Enchant\EnchantList_biosphere.lub'
$constellationPatch = Join-Path $root 'clientside\data\luafiles514\lua files\Enchant\EnchantList_constellation.lub'

function Get-TableBlock {
	param(
		[string[]]$Lines,
		[int]$TableId
	)
	$start = ($Lines | Select-String -Pattern "^Table\[$TableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
	if (-not $start) {
		throw "Table[$TableId] not found in source EnchantList.lub"
	}
	$end = $Lines.Length
	for ($i = $start; $i -lt $Lines.Length; $i++) {
		if ($Lines[$i] -match '^Table\[(\d+)\] = CreateEnchantInfo\(\)' -and [int]$Matches[1] -ne $TableId) {
			$end = $i
			break
		}
	}
	return ,@($Lines[($start - 1)..($end - 1)])
}

function Build-PatchFile {
	param(
		[string[]]$Lines,
		[int[]]$TableIds,
		[string]$OutputPath
	)
	$patchLines = @()
	foreach ($tableId in $TableIds) {
		$block = Get-TableBlock -Lines $Lines -TableId $tableId
		$patchLines += $block
		$patchLines += ''
	}
	$patchDir = Split-Path $OutputPath -Parent
	if (-not (Test-Path $patchDir)) {
		New-Item -ItemType Directory -Force -Path $patchDir | Out-Null
	}
	$patchLines | Set-Content -Path $OutputPath -Encoding UTF8
	Write-Host "Wrote $($patchLines.Count) lines -> $OutputPath"
	return $patchLines
}

function Merge-TableBlock {
	param(
		[string[]]$ClientLines,
		[string[]]$PatchLines,
		[int]$TableId
	)
	$block = Get-TableBlock -Lines $PatchLines -TableId $TableId
	$existing = Get-TableBlock -Lines $ClientLines -TableId $TableId -ErrorAction SilentlyContinue
	if ($existing) {
		$start = ($ClientLines | Select-String -Pattern "^Table\[$TableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
		$end = $ClientLines.Length
		for ($i = $start; $i -lt $ClientLines.Length; $i++) {
			if ($ClientLines[$i] -match '^Table\[(\d+)\] = CreateEnchantInfo\(\)' -and [int]$Matches[1] -ne $TableId) {
				$end = $i
				break
			}
		}
		return @(
			$ClientLines[0..($start - 2)]
			$block
			''
			$ClientLines[($end - 1)..($ClientLines.Length - 1)]
		)
	}

	$insertAt = ($ClientLines | Select-String -Pattern '^Table\[' | Where-Object {
		$_.Line -match '^Table\[(\d+)\] = CreateEnchantInfo\(\)' -and [int]$Matches[1] -gt $TableId
	} | Select-Object -First 1).LineNumber
	if (-not $insertAt) {
		return @($ClientLines + '' + $block + '')
	}
	return @(
		$ClientLines[0..($insertAt - 2)]
		$block
		''
		$ClientLines[($insertAt - 1)..($ClientLines.Length - 1)]
	)
}

if (-not (Test-Path $sourcePath)) {
	throw "Missing source cache: $sourcePath"
}

$sourceLines = Get-Content $sourcePath -Encoding UTF8
$biosphereIds = @(16, 17, 18, 19, 52, 53, 54, 55, 57, 58, 59, 60, 61, 62)
$constellationIds = 7..13

$biospherePatchLines = Build-PatchFile -Lines $sourceLines -TableIds $biosphereIds -OutputPath $biospherePatch
Build-PatchFile -Lines $sourceLines -TableIds $constellationIds -OutputPath $constellationPatch | Out-Null

if ($UpdateClient) {
	if (-not (Test-Path $UpdateClient)) {
		throw "Client EnchantList.lub not found: $UpdateClient"
	}
	$backupPath = "$UpdateClient.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
	Copy-Item $UpdateClient $backupPath
	$updated = Get-Content $UpdateClient -Encoding UTF8
	foreach ($tableId in ($biosphereIds + $constellationIds)) {
		$patchLines = if ($tableId -in $biosphereIds) { $biospherePatchLines } else { Get-Content $constellationPatch -Encoding UTF8 }
		$updated = Merge-TableBlock -ClientLines $updated -PatchLines $patchLines -TableId $tableId
	}
	$updated | Set-Content -Path $UpdateClient -Encoding UTF8
	Write-Host "Patched client EnchantList.lub: $UpdateClient"
	Write-Host "Backup: $backupPath"
}

Write-Host ''
Write-Host 'Deploy to player clients with:'
Write-Host "  .\tools\extract_enchantlist_tables.ps1 -UpdateClient `"<path-to-client>\data\luafiles514\lua files\Enchant\EnchantList.lub`""
