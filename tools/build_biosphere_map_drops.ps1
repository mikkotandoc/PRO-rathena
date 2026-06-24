# Generate db/import/map_drops.yml for Varmundt's Biosphere special drops.
# Zone runes/essence: kRO reference at 75% (matches build_biosphere_mobs.ps1).
# BarMealTicket: 5-10% via map GlobalDrops (weaker maps = lower rate).
# Map drop Rate is n/100000 (see db/import-tmpl/map_drops.yml).
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$importDir = Join-Path $root 'db\import'
$outFile = Join-Path $importDir 'map_drops.yml'

if (-not (Test-Path $importDir)) {
	New-Item -ItemType Directory -Path $importDir | Out-Null
}

function Get-Rate {
	param([double]$Percent)
	return [int][Math]::Round($Percent * 750, 0)
}

function Get-MapRate {
	param([double]$Percent)
	return [int][Math]::Round($Percent * 1000, 0)
}

function Convert-DropYaml {
	param(
		[int]$StartIndex,
		[array]$Drops,
		[switch]$RawPercent
	)
	$lines = New-Object System.Collections.Generic.List[string]
	$idx = $StartIndex
	foreach ($drop in $Drops) {
		$rate = if ($RawPercent) { Get-MapRate $drop.Percent } else { Get-Rate $drop.Percent }
		$lines.Add("      - Index: $idx")
		$lines.Add("        Item: $($drop.Item)")
		$lines.Add("        Rate: $rate")
		$idx++
	}
	return $lines
}

function Get-MapTicketPercent {
	param([string]$Map)
	$ticketByMap = [ordered]@{
		bl_grass  = 5
		bl_lava   = 6
		bl_ice    = 6.5
		bl_death  = 7
		bl_soul   = 7.5
		bl_venom  = 8
		bl_temple = 8.5
		bl_depth1 = 9
		bl_depth2 = 10
	}
	if ($ticketByMap.Contains($Map)) { return $ticketByMap[$Map] }
	return 5
}

function Read-BiosphereSpawns {
	param([string[]]$Files)

	$byMap = @{}
	foreach ($file in $Files) {
		$path = Join-Path $root $file
		if (-not (Test-Path $path)) { continue }
		foreach ($line in Get-Content $path -Encoding UTF8) {
			if ($line -notmatch '^(?<map>bl_\w+)\s+(?<type>monster|boss_monster)\s+\S+\s+(?<id>\d+),(?<amount>\d+).+//\s*(?<aegis>\S+)') { continue }
			$entry = [ordered]@{
				Aegis = $Matches.aegis
				SpawnType = $Matches.type
				Amount = [int]$Matches.amount
			}
			if (-not $byMap.ContainsKey($Matches.map)) {
				$byMap[$Matches.map] = New-Object System.Collections.Generic.List[object]
			}
			$byMap[$Matches.map].Add($entry)
		}
	}
	return $byMap
}

$oreDrops = @(
	@{ Item = 'Zelunium_Ore'; Percent = 1.8 },
	@{ Item = 'Zelunium'; Percent = 0.17 },
	@{ Item = 'Shadowdecon_Ore'; Percent = 1.8 },
	@{ Item = 'Shadowdecon'; Percent = 0.17 },
	@{ Item = 'Acc_Ore_1'; Percent = 50 },
	@{ Item = 'Acc_Stone_1'; Percent = 10 },
	@{ Item = 'Weapon_Ore_1'; Percent = 40 },
	@{ Item = 'Armor_Ore_1'; Percent = 40 },
	@{ Item = 'Weapon_Stone_1'; Percent = 8 },
	@{ Item = 'Armor_Stone_1'; Percent = 8 },
	@{ Item = 'Acc_Ore_2'; Percent = 5 },
	@{ Item = 'Acc_Stone_2'; Percent = 1 },
	@{ Item = 'Weapon_Ore_2'; Percent = 4 },
	@{ Item = 'Armor_Ore_2'; Percent = 4 },
	@{ Item = 'Weapon_Stone_2'; Percent = 0.8 },
	@{ Item = 'Armor_Stone_2'; Percent = 0.8 },
	@{ Item = 'Acc_Ore_3'; Percent = 0.5 },
	@{ Item = 'Acc_Stone_3'; Percent = 0.35 },
	@{ Item = 'Weapon_Ore_3'; Percent = 0.4 },
	@{ Item = 'Armor_Ore_3'; Percent = 0.4 },
	@{ Item = 'Weapon_Stone_3'; Percent = 0.25 },
	@{ Item = 'Armor_Stone_3'; Percent = 0.25 }
)

$classicEquipDrops = @(
	@{ Item = 'Barmund_Armor'; Percent = 0.15 },
	@{ Item = 'Barmund_Manteau'; Percent = 0.15 },
	@{ Item = 'Barmund_Greave'; Percent = 0.15 },
	@{ Item = 'ST_Orleans_Gown'; Percent = 0.05 },
	@{ Item = 'ST_Orleans_Server'; Percent = 0.05 },
	@{ Item = 'ST_Orleans_Glove'; Percent = 0.05 },
	@{ Item = 'ST_Pinquicula_Corsage'; Percent = 0.05 },
	@{ Item = 'ST_Waterdrop_Brooch'; Percent = 0.05 },
	@{ Item = 'ST_Servival_Cloak'; Percent = 0.05 },
	@{ Item = 'ST_Naga_Armor'; Percent = 0.05 },
	@{ Item = 'ST_Naga_Shield'; Percent = 0.05 }
)

# Each biosphere map only drops its own rune fragment, full rune, and essence.
$zoneMaps = [ordered]@{
	bl_grass  = @{ Fragment = 'Plain_Barmund_Rune'; Rune = 'Plain_Barmund_Rune2'; Essence = 'Barmund_Plain_Essence' }
	bl_lava   = @{ Fragment = 'Flame_Barmund_Rune'; Rune = 'Flame_Barmund_Rune2'; Essence = 'Barmund_Flame_Essence' }
	bl_ice    = @{ Fragment = 'Ice_Barmund_Rune'; Rune = 'Ice_Barmund_Rune2'; Essence = 'Barmund_Ice_Essence' }
	bl_death  = @{ Fragment = 'Death_Barmund_Rune'; Rune = 'Death_Barmund_Rune2'; Essence = 'Barmund_Death_Essence' }
	bl_temple = @{ Fragment = 'Temple_Barmund_Rune'; Rune = 'Temple_Barmund_Rune2'; Essence = 'Barmund_Temple_Essence' }
	bl_venom  = @{ Fragment = 'Venom_Barmund_Rune'; Rune = 'Venom_Barmund_Rune2'; Essence = 'Barmund_Venom_Essence' }
	bl_soul   = @{ Fragment = 'Soul_Barmund_Rune'; Rune = 'Soul_Barmund_Rune2'; Essence = 'Barmund_Soul_Essence' }
}

$depthMaps = @('bl_depth1', 'bl_depth2')

# Rare Etel materials for depth BIO_ mobs (75% kRO tuning; <10% effective at 150x).
$etelRareDrops = @(
	@{ Item = 'Etel_Stone'; Rate = 1875 },
	@{ Item = 'Blessed_Etel_Dust'; Rate = 1500 },
	@{ Item = 'Etel_Skyblue_Jewel'; Rate = 1125 },
	@{ Item = 'Etel_Topaz'; Rate = 900 },
	@{ Item = 'Etel_Violet_Jewel'; Rate = 750 },
	@{ Item = 'Etel_Amber'; Rate = 600 }
)
$spawnFiles = @(
	'npc\re\mobs\dungeons\biosphere.txt',
	'npc\re\mobs\dungeons\bl_depth1.txt'
)
$spawnsByMap = Read-BiosphereSpawns -Files $spawnFiles

$header = @'
# Varmundt's Biosphere map-wide special drops (import overlay)
# Zone runes: map-specific GlobalDrops (75% kRO tuning)
# BarMealTicket: map GlobalDrops 5-10% (weaker maps = lower rate)
# BIO_ depth mobs: rare Etel material SpecificDrops (see `$etelRareDrops)
# Normal mob loot stays in mob_db.

Header:
  Type: MAP_DROP_DB
  Version: 2

Body:
'@

$body = New-Object System.Collections.Generic.List[string]

function Write-MapEntry {
	param(
		[string]$Map,
		[array]$GlobalDrops
	)

	$body.Add("  - Map: $Map")
	$body.Add('    GlobalDrops:')
	foreach ($line in (Convert-DropYaml -StartIndex 0 -Drops $GlobalDrops)) {
		$body.Add($line)
	}
	$goldIdx = $GlobalDrops.Count
	$body.Add("      - Index: $goldIdx")
	$body.Add('        Item: Play_RO_Gold_Coin_')
	$body.Add("        Rate: $(Get-MapRate 6)")
	$ticketIdx = $goldIdx + 1
	$body.Add("      - Index: $ticketIdx")
	$body.Add('        Item: BarMealTicket')
	$body.Add("        Rate: $(Get-MapRate (Get-MapTicketPercent $Map))")

	if ($spawnsByMap.ContainsKey($Map)) {
		$body.Add('    SpecificDrops:')
		foreach ($mob in $spawnsByMap[$Map]) {
			$body.Add("      - Monster: $($mob.Aegis)")
			$body.Add('        Drops:')
			$dropIdx = 0
			if ($mob.Aegis -match '^BIO_' -and $Map -in $depthMaps) {
				foreach ($drop in $etelRareDrops) {
					$body.Add("          - Index: $dropIdx")
					$body.Add("            Item: $($drop.Item)")
					$body.Add("            Rate: $($drop.Rate)")
					$dropIdx++
				}
			}
		}
	}
}

foreach ($entry in $zoneMaps.GetEnumerator()) {
	$map = $entry.Key
	$zone = $entry.Value
	$zoneDrops = @(
		@{ Item = $zone.Fragment; Percent = 15 },
		@{ Item = $zone.Rune; Percent = 3 },
		@{ Item = $zone.Essence; Percent = 1 }
	)

	$allDrops = $zoneDrops + $oreDrops
	if ($map -in @('bl_grass', 'bl_lava', 'bl_ice', 'bl_death')) {
		$allDrops += $classicEquipDrops
	} else {
		$allDrops += @{ Item = 'Barmund_Ring'; Percent = 0.15 }
	}

	Write-MapEntry -Map $map -GlobalDrops $allDrops
}

foreach ($map in $depthMaps) {
	Write-MapEntry -Map $map -GlobalDrops $oreDrops
}

$content = ($header, ($body -join "`n")) -join "`n" + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outFile, $content, $utf8NoBom)
Write-Host "Wrote $outFile ($((Get-Content $outFile).Count) lines)"

function Remove-BiosphereGlobalMobDrops {
	param([string]$FilePath)

	if (-not (Test-Path $FilePath)) { return }

	$globalItems = @(
		'Plain_Barmund_Rune','Flame_Barmund_Rune','Ice_Barmund_Rune','Death_Barmund_Rune',
		'Temple_Barmund_Rune','Venom_Barmund_Rune','Soul_Barmund_Rune',
		'Barmund_Plain_Essence','Barmund_Flame_Essence','Barmund_Ice_Essence','Barmund_Death_Essence',
		'Barmund_Temple_Essence','Barmund_Venom_Essence','Barmund_Soul_Essence',
		'Zelunium','Zelunium_Ore','Shadowdecon','Shadowdecon_Ore'
	)
	$globalRates = @(1125, 225, 17, 180)
	$pattern = '(?ms)^      - Item: (' + ($globalItems -join '|') + ')\r?\n        Rate: (' + ($globalRates -join '|') + ')\r?\n'
	$fileContent = [System.IO.File]::ReadAllText($FilePath)
	$newContent = [regex]::Replace($fileContent, $pattern, '')
	if ($newContent -ne $fileContent) {
		[System.IO.File]::WriteAllText($FilePath, $newContent, $utf8NoBom)
		Write-Host "Stripped biosphere global mob drops from $FilePath"
	}
}

Remove-BiosphereGlobalMobDrops -FilePath (Join-Path $root 'db\re\mob_db.yml')
Remove-BiosphereGlobalMobDrops -FilePath (Join-Path $root 'db\import\mob_db.yml')
