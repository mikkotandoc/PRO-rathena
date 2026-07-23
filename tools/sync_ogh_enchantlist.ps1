# Patches the client EnchantList.lub with OGH Challenge Temporal Circlet enchant UI (Table[169]).
#
# Usage:
#   .\tools\sync_ogh_enchantlist.ps1 -ClientEnchantList "D:\RO\data\luafiles514\lua files\Enchant\EnchantList.lub"
#
# Optional: regenerate repo patch from db/re/item_enchant.yml
#   .\tools\sync_ogh_enchantlist.ps1 -ClientEnchantList "..." -RegeneratePatch

param(
	[Parameter(Mandatory = $true)]
	[string]$ClientEnchantList,
	[switch]$RegeneratePatch
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$patchPath = Join-Path $root 'clientside\data\luafiles514\lua files\Enchant\EnchantList_ogh.lub'
$generator = Join-Path $PSScriptRoot 'generate_enchantlist_table.ps1'
$tableId = 169
$nextTableId = 170

function Get-TableBlock {
	param(
		[string[]]$Lines,
		[int]$TableId,
		[int]$UntilTableId
	)
	$start = ($Lines | Select-String -Pattern "^Table\[$TableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
	if (-not $start) { return $null }
	$endMatch = $Lines | Select-String -Pattern "^Table\[$UntilTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1
	if ($endMatch) {
		$end = $endMatch.LineNumber - 1
	} else {
		$end = $Lines.Length
	}
	return @($Lines[($start - 1)..($end - 1)])
}

if ($RegeneratePatch -or -not (Test-Path $patchPath)) {
	if (-not (Test-Path $generator)) {
		throw "Missing generator script: $generator"
	}
	& $generator -EntryId $tableId -OutputPath $patchPath
}

if (-not (Test-Path $patchPath)) {
	throw "Missing repo patch: $patchPath"
}

if (-not (Test-Path $ClientEnchantList)) {
	throw "Client EnchantList.lub not found: $ClientEnchantList"
}

# Patch block is ASCII-only (UTF-8). Client EnchantList.lub uses CP949 for Korean random-option names.
$enc949 = [System.Text.Encoding]::GetEncoding(949)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Read-ClientEnchantLines {
	param([string]$Path)
	$bytes = [System.IO.File]::ReadAllBytes($Path)
	if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
		$bytes = $bytes[3..($bytes.Length - 1)]
	}
	$text = $enc949.GetString($bytes)
	if ($text.EndsWith("`r`n")) { $text = $text.Substring(0, $text.Length - 2) }
	elseif ($text.EndsWith("`n")) { $text = $text.Substring(0, $text.Length - 1) }
	return @($text -split "`r`n|`n|`r", -1)
}

function Write-ClientEnchantLines {
	param(
		[string]$Path,
		[string[]]$Lines
	)
	$text = ($Lines -join "`r`n") + "`r`n"
	[System.IO.File]::WriteAllText($Path, $text, $enc949)
}

$patchLines = [System.IO.File]::ReadAllLines($patchPath, $utf8NoBom)
$perfectCount = ($patchLines | Select-String -Pattern 'AddPerfectEnchant|SetEnchant').Count
Write-Host "OGH patch: $($patchLines.Count) lines, $perfectCount enchant entries"

$clientLines = Read-ClientEnchantLines -Path $ClientEnchantList
$backupPath = "$ClientEnchantList.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $ClientEnchantList $backupPath

$block = Get-TableBlock -Lines $patchLines -TableId $tableId -UntilTableId $nextTableId
if (-not $block) {
	throw "Patch block for Table[$tableId] not found in $patchPath"
}

$updated = $clientLines
$existing = Get-TableBlock -Lines $updated -TableId $tableId -UntilTableId $nextTableId
if ($null -ne $existing) {
	$start = ($updated | Select-String -Pattern "^Table\[$tableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
	$endMatch = $updated | Select-String -Pattern "^Table\[$nextTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1
	if ($endMatch) {
		$end = $endMatch.LineNumber - 1
		$updated = @(
			$updated[0..($start - 2)]
			$block
			''
			$updated[$end..($updated.Length - 1)]
		)
	} else {
		$updated = @(
			$updated[0..($start - 2)]
			$block
		)
	}
} else {
	$insertAt = ($updated | Select-String -Pattern "^Table\[$nextTableId\] = CreateEnchantInfo\(\)" | Select-Object -First 1).LineNumber
	if ($insertAt) {
		$updated = @(
			$updated[0..($insertAt - 2)]
			$block
			''
			$updated[($insertAt - 1)..($updated.Length - 1)]
		)
	} else {
		$updated = $updated + @('', $block)
	}
}

Write-ClientEnchantLines -Path $ClientEnchantList -Lines $updated
Write-Host "Patched: $ClientEnchantList"
Write-Host "Backup:  $backupPath"
Write-Host ''
Write-Host 'Verify in-game: Oscar @ glast_01 137,291 -> Temporal Circlet Enchantment with circlet in inventory (unequipped).'
