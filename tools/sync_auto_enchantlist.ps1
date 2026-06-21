# Patches the client EnchantList.lub with bound Automatic equipment enchant UI entries.
# Required for the Perfect Enchant tab on item_enchant IDs 35, 41, 44, 45, 46 (Lisa @ ba_in01).
#
# Usage:
#   .\tools\sync_auto_enchantlist.ps1 -ClientEnchantList "D:\RO\data\luafiles514\lua files\Enchant\EnchantList.lub"
#
# Optional: refresh the repo copy of the patch block
#   .\tools\sync_auto_enchantlist.ps1 -ClientEnchantList "..." -UpdateRepoPatch
#
# Requires client >= 2023-09-20 (AddTargetItem_Duplicate + Perfect Enchant tab).
# Source: llchrisll/ROenglishRE EnchantList.lub (2023-09-20 compatibility build).

param(
	[Parameter(Mandatory = $true)]
	[string]$ClientEnchantList,
	[switch]$UpdateRepoPatch
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$patchPath = Join-Path $root 'clientside\data\luafiles514\lua files\Enchant\EnchantList_auto.lub'
$sourceUrl = 'https://raw.githubusercontent.com/llchrisll/ROenglishRE/refs/heads/master/Translation/Compatibility/2023-09-20/data/luafiles514/lua%20files/Enchant/EnchantList.lub'
$tableIds = @(35, 41, 44, 45, 46)

function Get-TableBlock {
	param(
		[string[]]$Lines,
		[int]$TableId,
		[int]$UntilTableId
	)
	$start = ($Lines | Select-String -Pattern "^Table\[$TableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
	if (-not $start) { return $null }
	$endMatch = $Lines | Select-String -Pattern "^Table\[$UntilTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1
	if (-not $endMatch) {
		throw "Could not find Table[$UntilTableId] after Table[$TableId]"
	}
	$end = $endMatch.LineNumber - 1
	return ,@($Lines[($start - 1)..($end - 1)])
}

function Get-NextTableId {
	param([int]$TableId)
	switch ($TableId) {
		35 { return 41 }
		41 { return 44 }
		44 { return 45 }
		45 { return 46 }
		46 { return 47 }
		default { throw "Unsupported table id: $TableId" }
	}
}

if (-not (Test-Path $ClientEnchantList)) {
	throw "Client EnchantList.lub not found: $ClientEnchantList"
}

if ($UpdateRepoPatch -or -not (Test-Path $patchPath)) {
	$tempSource = Join-Path $env:TEMP 'EnchantList_official_auto.lub'
	Write-Host 'Downloading official EnchantList.lub...'
	curl.exe -fsSL $sourceUrl -o $tempSource
	if (-not (Test-Path $tempSource)) {
		if (Test-Path $patchPath) {
			Write-Host "Download failed; falling back to repo patch: $patchPath"
			$sourceLines = Get-Content $patchPath -Encoding UTF8
		} else {
			throw 'Failed to download source EnchantList.lub and no repo patch is available'
		}
	} else {
		$sourceLines = Get-Content $tempSource -Encoding UTF8
	}
	$patchLines = @()
	foreach ($tableId in $tableIds) {
		$block = Get-TableBlock -Lines $sourceLines -TableId $tableId -UntilTableId (Get-NextTableId $tableId)
		if (-not $block) {
			throw "Could not extract Table[$tableId] from source EnchantList.lub"
		}
		$patchLines += $block
		$patchLines += ''
	}
} else {
	Write-Host "Using repo patch: $patchPath"
	$patchLines = Get-Content $patchPath -Encoding UTF8
}

$perfectCount = ($patchLines | Select-String -Pattern 'AddPerfectEnchant').Count
Write-Host "Automatic bound patch: $($patchLines.Count) lines, $perfectCount AddPerfectEnchant entries"

if ($UpdateRepoPatch) {
	$patchDir = Split-Path $patchPath -Parent
	if (-not (Test-Path $patchDir)) {
		New-Item -ItemType Directory -Force -Path $patchDir | Out-Null
	}
	$patchLines | Set-Content -Path $patchPath -Encoding UTF8
	Write-Host "Updated repo patch: $patchPath"
}

$clientLines = Get-Content $ClientEnchantList -Encoding UTF8
$backupPath = "$ClientEnchantList.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $ClientEnchantList $backupPath

$updated = $clientLines
foreach ($tableId in $tableIds) {
	$nextTableId = Get-NextTableId $tableId
	$block = Get-TableBlock -Lines $patchLines -TableId $tableId -UntilTableId $nextTableId
	if (-not $block) {
		throw "Patch block for Table[$tableId] not found in repo patch"
	}
	$existing = Get-TableBlock -Lines $updated -TableId $tableId -UntilTableId $nextTableId
	if ($null -ne $existing) {
		$start = ($updated | Select-String -Pattern "^Table\[$tableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
		$endMatch = $updated | Select-String -Pattern "^Table\[$nextTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1
		$end = $endMatch.LineNumber - 1
		$updated = @(
			$updated[0..($start - 2)]
			$block
			''
			$updated[($end)..($updated.Length - 1)]
		)
	} else {
		$insertAt = ($updated | Select-String -Pattern "^Table\[$nextTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
		if (-not $insertAt) {
			throw "Table[$tableId] missing and Table[$nextTableId] not found; cannot patch automatically"
		}
		$updated = @(
			$updated[0..($insertAt - 2)]
			$block
			''
			$updated[($insertAt - 1)..($updated.Length - 1)]
		)
	}
}

$updated | Set-Content -Path $ClientEnchantList -Encoding UTF8
Write-Host "Patched: $ClientEnchantList"
Write-Host "Backup:  $backupPath"
Write-Host ''
Write-Host 'Verify in-game: Lisa @ ba_in01 87,370 -> Perfect Orb Enhancement (Bound) on E_Auto armor/booster gear.'
