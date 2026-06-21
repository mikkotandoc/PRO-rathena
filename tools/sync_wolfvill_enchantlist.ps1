# Patches the client EnchantList.lub with Wolf Village (Gray Wolf) enchant UI entries.
# Required for the Perfect Enchant tab on item_enchant IDs 1-5 (Emmet @ wolfvill).
#
# Usage:
#   .\tools\sync_wolfvill_enchantlist.ps1 -ClientEnchantList "D:\RO\data\luafiles514\lua files\Enchant\EnchantList.lub"
#
# Optional: refresh the repo copy of the patch block
#   .\tools\sync_wolfvill_enchantlist.ps1 -ClientEnchantList "..." -UpdateRepoPatch
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
$patchPath = Join-Path $root 'clientside\data\luafiles514\lua files\Enchant\EnchantList_wolfvill.lub'
$sourceUrl = 'https://raw.githubusercontent.com/llchrisll/ROenglishRE/refs/heads/master/Translation/Compatibility/2023-09-20/data/luafiles514/lua%20files/Enchant/EnchantList.lub'
$firstTableId = 1
$lastTableId = 5
$nextTableId = 6

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

if (-not (Test-Path $ClientEnchantList)) {
	throw "Client EnchantList.lub not found: $ClientEnchantList"
}

if ($UpdateRepoPatch -or -not (Test-Path $patchPath)) {
	$tempSource = Join-Path $env:TEMP 'EnchantList_official_wolfvill.lub'
	Write-Host 'Downloading official EnchantList.lub...'
	curl.exe -fsSL $sourceUrl -o $tempSource
	if (-not (Test-Path $tempSource)) {
		if (Test-Path $patchPath) {
			Write-Host "Download failed; falling back to repo patch: $patchPath"
			$patchLines = Get-Content $patchPath -Encoding UTF8
		} else {
			throw 'Failed to download source EnchantList.lub and no repo patch is available'
		}
	} else {
		$sourceLines = Get-Content $tempSource -Encoding UTF8
		$patchLines = Get-TableBlock -Lines $sourceLines -TableId $firstTableId -UntilTableId $nextTableId
	}
} else {
	Write-Host "Using repo patch: $patchPath"
	$patchLines = Get-Content $patchPath -Encoding UTF8
}
$perfectCount = ($patchLines | Select-String -Pattern 'AddPerfectEnchant').Count
Write-Host "Wolf Village patch: $($patchLines.Count) lines, $perfectCount AddPerfectEnchant entries"

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

$existing = Get-TableBlock -Lines $clientLines -TableId $firstTableId -UntilTableId $nextTableId
if ($null -ne $existing) {
	$start = ($clientLines | Select-String -Pattern "^Table\[$firstTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
	$endMatch = $clientLines | Select-String -Pattern "^Table\[$nextTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1
	$end = $endMatch.LineNumber - 1
	$updated = @(
		$clientLines[0..($start - 2)]
		$patchLines
		''
		$clientLines[($end)..($clientLines.Length - 1)]
	)
} else {
	$insertAt = ($clientLines | Select-String -Pattern "^Table\[$nextTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
	if (-not $insertAt) {
		throw "Table[$firstTableId]-Table[$lastTableId] missing and Table[$nextTableId] not found; cannot patch automatically"
	}
	$updated = @(
		$clientLines[0..($insertAt - 2)]
		$patchLines
		''
		$clientLines[($insertAt - 1)..($clientLines.Length - 1)]
	)
}

$updated | Set-Content -Path $ClientEnchantList -Encoding UTF8
Write-Host "Patched: $ClientEnchantList"
Write-Host "Backup:  $backupPath"
Write-Host ''
Write-Host 'Verify in-game: Emmet @ wolfvill -> enchant Gray Wolf gear -> Perfect Enchant tab on final slot.'
