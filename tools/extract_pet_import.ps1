$petDb = Join-Path $PSScriptRoot "..\db\re\pet_db.yml"
$importDir = Join-Path $PSScriptRoot "..\db\import"
$outPath = Join-Path $importDir "pet_db.yml"
New-Item -ItemType Directory -Force -Path $importDir | Out-Null

$lines = Get-Content $petDb -Encoding UTF8
$newPets = New-Object System.Collections.Generic.List[string]
$evoEntries = New-Object System.Collections.Generic.List[object]

# Extract fully commented pet blocks
$i = 0
while ($i -lt $lines.Count) {
	if ($lines[$i] -match '^#  - Mob: ') {
		$block = New-Object System.Collections.Generic.List[string]
		while ($i -lt $lines.Count) {
			$line = $lines[$i]
			if ($line -match '^#  - Mob: ' -and $block.Count -gt 0) { break }
			if ($line -match '^#  - Mob: ' -or ($block.Count -gt 0 -and ($line -match '^#' -or $line.Trim() -eq ''))) {
				if ($line -match '^#') {
					$uncommented = $line -replace '^#', ''
					[void]$block.Add($uncommented)
				}
				$i++
			}
			else { break }
		}
		if ($block.Count -gt 0) {
			foreach ($b in $block) { [void]$newPets.Add($b) }
			[void]$newPets.Add('')
		}
	}
	else { $i++ }
}

# Extract commented Evolution on active pets
$i = 0
while ($i -lt $lines.Count) {
	if ($lines[$i] -match '^  - Mob: ' -and $lines[$i] -notmatch '^#') {
		$mobLine = $lines[$i]
		$j = $i + 1
		$evoBlock = New-Object System.Collections.Generic.List[string]
		$inEvo = $false
		while ($j -lt $lines.Count -and -not ($lines[$j] -match '^  - Mob: ' -and $lines[$j] -notmatch '^#')) {
			$line = $lines[$j]
			if ($line -match '^#  - Mob: ') { break }
			if ($line -match '^#\s+Evolution:') { $inEvo = $true }
			if ($inEvo) {
				if ($line -match '^#') {
					if ($line -match '^#\s*$') { $j++; continue }
					[void]$evoBlock.Add(($line -replace '^#', ''))
				}
				elseif ($line.Trim() -ne '') { break }
			}
			$j++
		}
		if ($evoBlock.Count -gt 0) {
			$entry = New-Object System.Collections.Generic.List[string]
			[void]$entry.Add($mobLine)
			foreach ($e in $evoBlock) { [void]$entry.Add($e) }
			[void]$evoEntries.Add($entry)
		}
		$i++
	}
	else { $i++ }
}

$out = @(
	'Header:',
	'  Type: PET_DB',
	'  Version: 1',
	'',
	'Body:'
)
foreach ($p in $newPets) { $out += $p }
foreach ($entry in $evoEntries) {
	foreach ($e in $entry) { $out += $e }
	$out += ''
}

$out | Set-Content -Path $outPath -Encoding UTF8
Write-Host "Wrote $($out.Count) lines, $($evoEntries.Count) evolution overrides, new pet blocks from commented entries"
