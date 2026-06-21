# Sync Play_RO_Gold_Coin_ (50000) map GlobalDrops at 6% (6000/100000).
# Targets: Varmundt Biosphere, Illusion dungeons, Episode 18/19 maps.
# Removes gold coin drops from pay_dun* and orcsdun* in db/re/map_drops.yml.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$reFile = Join-Path $root 'db\re\map_drops.yml'
$goldRate = 6000
$item = 'Play_RO_Gold_Coin_'

$illusionMaps = @(
	'pay_d03_i', 'gef_d01_i', 'ice_d03_i', 'tur_d03_i', 'tur_d04_i', 'tur_d04ia', 'tur_d04ib',
	'ein_d02_i', 'com_d02_i', 'iz_d04_i', 'iz_d05_i', 'prt_mz03_i', 'ant_d02_i'
)
$ep18Maps = @(
	'oz_dun01', 'oz_dun02', 'gw_fild01', 'gw_fild02', 'ra_fild10', 'ra_fild11', 'ra_fild12', 'ra_fild13',
	'amicitia1', 'amicitia2', 'sp_rudus', 'sp_rudus2', 'sp_rudus3', 'sp_rudus4',
	'nif_dun01', 'nif_dun02', 'abyss_01', 'abyss_02', 'abyss_03', 'abyss_04', 'ein_dun03', 'clock_01'
)
$ep19Maps = @(
	'jor_tail', 'jor_back1', 'jor_back2', 'jor_back3', 'jor_back4', 'jor_back5', 'jor_back6',
	'jor_nest', 'jor_dun01', 'jor_dun02', 'jor_dun03', 'jor_ab01', 'jor_ab02', 'jor_que',
	'jor_maze', 'jor_root1', 'jor_root2', 'jor_root3', 'jor_safty1', 'jor_safty2', 'jor_sanct',
	'jor_twice', 'jor_twig', 'jor_albe', 'jor_base', 'jor_crk', 'jor_crk_p', 'jor_mbase',
	'jor_raise1', 'jor_raise2', 'jor_tmple1', 'jor_tmple2', 'jor_sklf1', 'jor_sklf2'
)
$biosphereMaps = @(
	'bl_grass', 'bl_lava', 'bl_ice', 'bl_death', 'bl_soul', 'bl_temple', 'bl_venom', 'bl_depth1', 'bl_depth2'
)
$removeMaps = @(
	'orcsdun01', 'orcsdun02', 'pay_dun00', 'pay_dun01', 'pay_dun02', 'pay_dun03', 'pay_dun04'
)

$targetMaps = @{}
foreach ($m in ($illusionMaps + $ep18Maps + $ep19Maps)) { $targetMaps[$m] = $true }

function Add-Lines {
	param(
		[System.Collections.Generic.List[string]]$Target,
		[string[]]$Lines
	)
	foreach ($l in $Lines) { $Target.Add($l) }
}

function New-GoldGlobalBlock {
	param([int]$Index = 0)
	return @(
		'    GlobalDrops:',
		"      - Index: $Index",
		"        Item: $item",
		"        Rate: $goldRate"
	)
}

function Set-GoldInMapBlock {
	param([System.Collections.Generic.List[string]]$Lines)

	$hasGlobal = $false
	$goldIdx = -1
	$insertAt = -1
	$maxIdx = -1

	for ($i = 0; $i -lt $Lines.Count; $i++) {
		if ($Lines[$i] -match '^\s*GlobalDrops:') { $hasGlobal = $true }
		if ($Lines[$i] -match '^\s*- Index:\s*(\d+)') {
			$idx = [int]$Matches[1]
			if ($idx -gt $maxIdx) { $maxIdx = $idx }
			if ($i + 2 -lt $Lines.Count -and $Lines[$i + 1] -match "Item:\s*$item" -and $Lines[$i + 2] -match 'Rate:\s*(\d+)') {
				$goldIdx = $i
			}
		}
		if ($insertAt -lt 0 -and $Lines[$i] -match '^\s*SpecificDrops:') { $insertAt = $i }
	}

	if ($goldIdx -ge 0) {
		$Lines[$goldIdx + 2] = "        Rate: $goldRate"
		return
	}

	$newDrop = @(
		"      - Index: $($maxIdx + 1)",
		"        Item: $item",
		"        Rate: $goldRate"
	)

	if ($hasGlobal) {
		if ($insertAt -ge 0) {
			for ($j = $newDrop.Count - 1; $j -ge 0; $j--) {
				$Lines.Insert($insertAt, $newDrop[$j])
			}
		} else {
			Add-Lines -Target $Lines -Lines $newDrop
		}
		return
	}

	$block = New-GoldGlobalBlock -Index 0
	if ($insertAt -ge 0) {
		for ($j = $block.Count - 1; $j -ge 0; $j--) {
			$Lines.Insert($insertAt, $block[$j])
		}
	} else {
		Add-Lines -Target $Lines -Lines $block
	}
}

# --- Patch db/re/map_drops.yml ---
$rawLines = [System.Collections.Generic.List[string]]::new()
$rawLines.AddRange([string[]](Get-Content $reFile -Encoding UTF8))

$outLines = [System.Collections.Generic.List[string]]::new()
$currentMap = $null
$currentBlock = $null
$skipBlock = $false
$patchedMaps = @{}

$i = 0
while ($i -lt $rawLines.Count) {
	$line = $rawLines[$i]
	if ($line -match '^\s*- Map:\s*(.+)\s*$') {
		if ($null -ne $currentBlock) {
			if (-not $skipBlock) {
				if ($targetMaps.ContainsKey($currentMap)) {
					Set-GoldInMapBlock -Lines $currentBlock
					$patchedMaps[$currentMap] = $true
				}
				$outLines.AddRange($currentBlock)
			}
		}
		$currentMap = $Matches[1].Trim()
		$skipBlock = $removeMaps -contains $currentMap
		$currentBlock = [System.Collections.Generic.List[string]]::new()
		if (-not $skipBlock) { $currentBlock.Add($line) }
	} elseif (-not $skipBlock) {
		if ($null -ne $currentBlock) { $currentBlock.Add($line) } else { $outLines.Add($line) }
	}
	$i++
}

if ($null -ne $currentBlock -and -not $skipBlock) {
	if ($targetMaps.ContainsKey($currentMap)) {
		Set-GoldInMapBlock -Lines $currentBlock
		$patchedMaps[$currentMap] = $true
	}
	$outLines.AddRange($currentBlock)
}

$missing = @($targetMaps.Keys | Where-Object { -not $patchedMaps.ContainsKey($_) } | Sort-Object)
if ($missing.Count -gt 0) {
	$outLines.Add('')
	foreach ($map in $missing) {
		$outLines.Add("  - Map: $map")
		Add-Lines -Target $outLines -Lines (New-GoldGlobalBlock -Index 0)
	}
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($reFile, (($outLines -join "`n") + "`n"), $utf8NoBom)
Write-Host "Patched $reFile (removed $($removeMaps.Count) pay_dun/orcsdun patterns, updated $($patchedMaps.Count) maps, appended $($missing.Count) maps)"

# --- Append gold coin overlay for biosphere maps in import/map_drops.yml ---
$importFile = Join-Path $root 'db\import\map_drops.yml'
if (-not (Test-Path $importFile)) {
	Write-Host "Note: $importFile not found; run build_biosphere_map_drops.ps1 after this script."
	exit 0
}

$importLines = [System.Collections.Generic.List[string]]::new()
$importLines.AddRange([string[]](Get-Content $importFile -Encoding UTF8))
$importOut = [System.Collections.Generic.List[string]]::new()
$currentMap = $null
$currentBlock = $null
$bioPatched = 0

$i = 0
while ($i -lt $importLines.Count) {
	$line = $importLines[$i]
	if ($line -match '^\s*- Map:\s*(.+)\s*$') {
		if ($null -ne $currentBlock) {
			if ($biosphereMaps -contains $currentMap) {
				Set-GoldInMapBlock -Lines $currentBlock
				$bioPatched++
			}
			$importOut.AddRange($currentBlock)
		}
		$currentMap = $Matches[1].Trim()
		$currentBlock = [System.Collections.Generic.List[string]]::new()
		$currentBlock.Add($line)
	} else {
		if ($null -ne $currentBlock) { $currentBlock.Add($line) } else { $importOut.Add($line) }
	}
	$i++
}

if ($null -ne $currentBlock) {
	if ($biosphereMaps -contains $currentMap) {
		Set-GoldInMapBlock -Lines $currentBlock
		$bioPatched++
	}
	$importOut.AddRange($currentBlock)
}

[System.IO.File]::WriteAllText($importFile, (($importOut -join "`n") + "`n"), $utf8NoBom)
Write-Host "Patched $importFile biosphere maps with gold coin ($bioPatched maps)"
