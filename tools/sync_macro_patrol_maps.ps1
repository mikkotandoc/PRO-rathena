# Generate macro patrol .farm_maps$ setarray from map_drops.yml files.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$files = @(
	(Join-Path $root 'db\re\map_drops.yml'),
	(Join-Path $root 'db\import\map_drops.yml')
)
$maps = New-Object System.Collections.Generic.List[string]
foreach ($f in $files) {
	if (-not (Test-Path $f)) { continue }
	$current = $null
	foreach ($line in Get-Content $f -Encoding UTF8) {
		if ($line -match '^\s*- Map:\s*(.+)\s*$') {
			$current = $Matches[1].Trim()
			continue
		}
		if ($null -ne $current -and $line -match 'Item:\s*Play_RO_Gold_Coin_') {
			$maps.Add($current)
		}
	}
}
$unique = $maps | Sort-Object -Unique
Write-Host "Found $($unique.Count) farming maps with Play_RO_Gold_Coin_ drops:"
Write-Host ''
Write-Host 'setarray .farm_maps$,'
for ($i = 0; $i -lt $unique.Count; $i++) {
	$suffix = if ($i -lt $unique.Count - 1) { ',' } else { ';' }
	Write-Host "`t`"$($unique[$i])`"$suffix"
}
