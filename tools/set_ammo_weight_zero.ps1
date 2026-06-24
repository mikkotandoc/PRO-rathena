# Set Weight: 0 for every item with Type: Ammo in item_db_etc.yml
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$files = @(
	(Join-Path $root 'db\re\item_db_etc.yml'),
	(Join-Path $root 'db\pre-re\item_db_etc.yml')
)

function Set-AmmoWeightZero([string]$path) {
	$lines = [System.IO.File]::ReadAllLines($path)
	$out = New-Object System.Collections.Generic.List[string]
	$isAmmo = $false
	$weightIdx = -1
	$ammo = 0
	$changed = 0

	foreach ($line in $lines) {
		if ($line -match '^\s*-\s+Id:\s+') {
			if ($isAmmo -and $weightIdx -ge 0) {
				$old = $out[$weightIdx]
				if ($old -notmatch 'Weight:\s*0\s*$') {
					$out[$weightIdx] = ($old -replace 'Weight:\s*\d+', 'Weight: 0')
					$changed++
				}
				$ammo++
			}
			$isAmmo = $false
			$weightIdx = -1
		}
		if ($line -match '^\s*Type:\s+Ammo\s*$') { $isAmmo = $true }
		if ($isAmmo -and $line -match '^\s*Weight:\s*\d+\s*$') { $weightIdx = $out.Count }
		[void]$out.Add($line)
	}
	if ($isAmmo -and $weightIdx -ge 0) {
		$old = $out[$weightIdx]
		if ($old -notmatch 'Weight:\s*0\s*$') {
			$out[$weightIdx] = ($old -replace 'Weight:\s*\d+', 'Weight: 0')
			$changed++
		}
		$ammo++
	}
	[System.IO.File]::WriteAllLines($path, $out)
	return @{ Ammo = $ammo; Changed = $changed }
}

foreach ($f in $files) {
	if (-not (Test-Path $f)) { continue }
	$r = Set-AmmoWeightZero $f
	Write-Host "$f : ammo=$($r.Ammo) changed=$($r.Changed)"
}
