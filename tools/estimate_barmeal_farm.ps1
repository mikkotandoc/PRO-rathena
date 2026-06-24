$mapTicketPercent = [ordered]@{
	bl_grass  = 0.05
	bl_lava   = 0.06
	bl_ice    = 0.065
	bl_death  = 0.07
	bl_soul   = 0.075
	bl_venom  = 0.08
	bl_temple = 0.085
	bl_depth1 = 0.09
	bl_depth2 = 0.10
}

$spawnFiles = @(
	'npc\re\mobs\dungeons\biosphere.txt',
	'npc\re\mobs\dungeons\bl_depth1.txt'
)
$root = Split-Path $PSScriptRoot -Parent
$byMap = @{}

foreach ($file in $spawnFiles) {
	$path = Join-Path $root $file
	foreach ($line in Get-Content $path) {
		if ($line -notmatch '^(?<map>bl_\w+)\s+(?<type>monster|boss_monster)\s+\S+\s+(?<id>\d+),(?<amount>\d+).+//\s*(?<aegis>\S+)') { continue }
		if ($Matches.type -eq 'boss_monster') { continue }
		$map = $Matches.map
		$rate = $mapTicketPercent[$map]
		if (-not $byMap[$map]) { $byMap[$map] = @{ w = 0; wr = 0.0; min = 1.0; max = 0.0 } }
		$byMap[$map].w += [int]$Matches.amount
		$byMap[$map].wr += [int]$Matches.amount * $rate
		if ($rate -lt $byMap[$map].min) { $byMap[$map].min = $rate }
		if ($rate -gt $byMap[$map].max) { $byMap[$map].max = $rate }
	}
}

Write-Host '=== Per-map weighted ticket rate (excluding MVP) ==='
$totalW = 0.0
$totalWR = 0.0
foreach ($map in ($byMap.Keys | Sort-Object)) {
	$avg = $byMap[$map].wr / $byMap[$map].w
	$totalW += $byMap[$map].w
	$totalWR += $byMap[$map].wr
	$kills = [Math]::Ceiling(500 / $avg)
	Write-Host ("{0,-10} avg {1,5:N2}% | kills for 500: {2,6} | range {3:N0}-{4:N0}%" -f $map, ($avg * 100), $kills, ($byMap[$map].min * 100), ($byMap[$map].max * 100))
}
$globalAvg = $totalWR / $totalW
Write-Host ("`nAll maps weighted avg: {0:N2}% ({1} kills for 500)" -f ($globalAvg * 100), [Math]::Ceiling(500 / $globalAvg))

Write-Host "`n=== Hours to farm 500 tickets ==="
$scenarios = @(
	@{ Label = 'Focus rare spawns (4.5%)'; Rate = 0.045 },
	@{ Label = 'Typical zone map average'; Rate = 0.0229 },
	@{ Label = 'Common trash only (2%)'; Rate = 0.02 },
	@{ Label = 'Depth maps (~3.25%)'; Rate = 0.0325 }
)
$kpmRates = @(8, 10, 12, 15)
foreach ($sc in $scenarios) {
	Write-Host ("`n{0} ({1:N1}% per kill):" -f $sc.Label, ($sc.Rate * 100))
	$kills = [Math]::Ceiling(500 / $sc.Rate)
	foreach ($kpm in $kpmRates) {
		$hours = ($kills / $kpm) / 60
		Write-Host ("  {0,2} kills/min -> {1,5:N1} h ({2} kills)" -f $kpm, $hours, $kills)
	}
}

$r = 0.0229
$mean = 500 / $r
$sd = [Math]::Sqrt(500 * (1 - $r) / ($r * $r))
Write-Host "`n=== Variance at typical 2.29% (natural map mix) ==="
Write-Host ("Expected kills: {0:N0}" -f $mean)
Write-Host ("Std deviation:    {0:N0} kills (~{1:N0}% swing)" -f $sd, ($sd / $mean * 100))
Write-Host ("Rough 10 kpm band: {0:N1}-{1:N1} hours for most players" -f (($mean - $sd) / 10 / 60), (($mean + $sd) / 10 / 60))
