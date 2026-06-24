# Compare biosphere spawns vs db/import/map_drops.yml coverage
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$spawnFiles = @(
	(Join-Path $root 'npc\re\mobs\dungeons\biosphere.txt'),
	(Join-Path $root 'npc\re\mobs\dungeons\bl_depth1.txt')
)
$mapDropsFile = Join-Path $root 'db\import\map_drops.yml'

if (-not (Test-Path $mapDropsFile)) {
	Write-Host "ERROR: $mapDropsFile missing (run build_biosphere_map_drops.ps1)"
	exit 1
}

$mapDrops = Get-Content $mapDropsFile -Raw
$spawnPattern = '^(?<map>bl_\w+)\s+(?<type>monster|boss_monster)\s+\S+\s+(?<id>\d+),(?<amount>\d+).+//\s*(?<aegis>\S+)'

$spawns = @{}
foreach ($file in $spawnFiles) {
	foreach ($line in Get-Content $file -Encoding UTF8) {
		if ($line -notmatch $spawnPattern) { continue }
		if (-not $spawns.ContainsKey($Matches.map)) {
			$spawns[$Matches.map] = New-Object System.Collections.Generic.List[object]
		}
		$spawns[$Matches.map].Add([pscustomobject]@{
			Aegis = $Matches.aegis
			Type = $Matches.type
			Amount = [int]$Matches.amount
		})
	}
}

$specific = @{}
$globalByMap = @{}
$currentMap = $null
$currentMonster = $null
$inGlobal = $false
$inSpecific = $false

foreach ($line in Get-Content $mapDropsFile -Encoding UTF8) {
	if ($line -match '^\s+- Map: (bl_\w+)') {
		$currentMap = $Matches[1]
		$specific[$currentMap] = @{}
		$globalByMap[$currentMap] = New-Object System.Collections.Generic.List[string]
		$inGlobal = $false
		$inSpecific = $false
		continue
	}
	if ($line -match '^\s+GlobalDrops:') { $inGlobal = $true; $inSpecific = $false; continue }
	if ($line -match '^\s+SpecificDrops:') { $inSpecific = $true; $inGlobal = $false; continue }
	if ($line -match '^\s+- Monster: (\S+)') { $currentMonster = $Matches[1]; continue }
	if ($line -match '^\s+Item: (\S+)') {
		if ($inGlobal -and $currentMap) { $globalByMap[$currentMap].Add($Matches[1]) }
		if ($inSpecific -and $currentMap -and $currentMonster) {
			if (-not $specific[$currentMap].ContainsKey($currentMonster)) {
				$specific[$currentMap][$currentMonster] = New-Object System.Collections.Generic.List[string]
			}
			$specific[$currentMap][$currentMonster].Add($Matches[1])
		}
	}
}

$issues = New-Object System.Collections.Generic.List[string]

foreach ($map in ($spawns.Keys | Sort-Object)) {
	if ($mapDrops -notmatch "- Map: $map\b") {
		$issues.Add("MAP ENTRY MISSING: $map")
	}
	foreach ($mob in $spawns[$map]) {
		if (-not $specific[$map] -or -not $specific[$map].ContainsKey($mob.Aegis)) {
			$issues.Add("SPECIFIC DROP BLOCK MISSING: $map / $($mob.Aegis) ($($mob.Type))")
			continue
		}
		$items = $specific[$map][$mob.Aegis]
		if ($mob.Aegis -notmatch '^BIO_' -and $items -notcontains 'BarMealTicket') {
			$issues.Add("BarMealTicket MISSING: $map / $($mob.Aegis)")
		}
		if ($mob.Aegis -match '^BIO_' -and $items -notcontains 'BarMealTicket') {
			$issues.Add("BarMealTicket MISSING (BIO): $map / $($mob.Aegis)")
		}
		if ($mob.Aegis -match '^BIO_' -and $items -notcontains 'Etel_Stone') {
			$issues.Add("Etel_Stone MISSING (BIO): $map / $($mob.Aegis)")
		}
	}
}

$zoneRune = [ordered]@{
	bl_grass = 'Plain_Barmund_Rune'
	bl_lava = 'Flame_Barmund_Rune'
	bl_ice = 'Ice_Barmund_Rune'
	bl_death = 'Death_Barmund_Rune'
	bl_temple = 'Temple_Barmund_Rune'
	bl_venom = 'Venom_Barmund_Rune'
	bl_soul = 'Soul_Barmund_Rune'
}

foreach ($entry in $zoneRune.GetEnumerator()) {
	$map = $entry.Key
	$rune = $entry.Value
	$globals = $globalByMap[$map]
	if (-not $globals) {
		$issues.Add("NO GLOBAL DROPS: $map")
		continue
	}
	foreach ($item in @($rune, ($rune + '2'), 'Play_RO_Gold_Coin_', 'Zelunium_Ore', 'Shadowdecon_Ore')) {
		if ($globals -notcontains $item) {
			$issues.Add("GLOBAL DROP MISSING: $map -> $item")
		}
	}
}

foreach ($map in @('bl_depth1', 'bl_depth2')) {
	$globals = $globalByMap[$map]
	if (-not $globals) {
		$issues.Add("NO GLOBAL DROPS: $map")
		continue
	}
	foreach ($item in @('Play_RO_Gold_Coin_', 'Zelunium_Ore', 'Shadowdecon_Ore')) {
		if ($globals -notcontains $item) {
			$issues.Add("GLOBAL DROP MISSING: $map -> $item")
		}
	}
	if ($globals -match 'Barmund_Rune') {
		$issues.Add("UNEXPECTED ZONE RUNE ON DEPTH MAP: $map")
	}
}

# mob_db import presence for BIO_/custom ECO
$mobImport = Join-Path $root 'db\import\mob_db.yml'
if (-not (Test-Path $mobImport)) {
	$issues.Add('db/import/mob_db.yml missing (run build_biosphere_mobs.ps1)')
} else {
	$mobRaw = Get-Content $mobImport -Raw
	foreach ($map in ($spawns.Keys | Sort-Object)) {
		foreach ($mob in $spawns[$map]) {
			if ($mobRaw -notmatch "AegisName: $($mob.Aegis)\b") {
				$issues.Add("MOB_DB MISSING: $($mob.Aegis)")
			}
		}
	}
}

Write-Host "=== Biosphere map_drops audit ==="
Write-Host "Maps with spawns: $($spawns.Count)"
Write-Host "map_drops file: $mapDropsFile"
Write-Host ""

if ($issues.Count -eq 0) {
	Write-Host 'OK: no coverage gaps detected in generated import files.'
} else {
	Write-Host "Found $($issues.Count) issue(s):"
	$issues | ForEach-Object { Write-Host "  $_" }
	exit 1
}
