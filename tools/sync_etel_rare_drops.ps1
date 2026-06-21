# Add rare Etel shop materials as map drops wherever Etel_Dust is already present.
# Targets EP19 (jor_*) GlobalDrops in db/re/map_drops.yml.
# Rates tuned for <10% effective drop at 150x server rates (base rate * 150 / 100000 < 0.10).
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$reFile = Join-Path $root 'db\re\map_drops.yml'

$ep19MapPattern = '^jor_'

# base rate * 150 / 100000 => effective % (all below 10%)
$etelRareDrops = @(
	@{ Item = 'Etel_Stone'; Rate = 2500 },
	@{ Item = 'Blessed_Etel_Dust'; Rate = 2000 },
	@{ Item = 'Etel_Skyblue_Jewel'; Rate = 1500 },
	@{ Item = 'Etel_Topaz'; Rate = 1200 },
	@{ Item = 'Etel_Violet_Jewel'; Rate = 1000 },
	@{ Item = 'Etel_Amber'; Rate = 800 }
)

function Test-HasEtelRare {
	param([string[]]$Lines)
	foreach ($drop in $etelRareDrops) {
		if ($Lines -match "Item:\s*$($drop.Item)\b") { return $true }
	}
	return $false
}

function Get-MaxGlobalIndex {
	param([string[]]$Lines)
	$max = -1
	foreach ($line in $Lines) {
		if ($line -match '^\s*- Index:\s*(\d+)') {
			$idx = [int]$Matches[1]
			if ($idx -gt $max) { $max = $idx }
		}
	}
	return $max
}

function Add-EtelRareGlobalDrops {
	param([System.Collections.Generic.List[string]]$Lines)

	if (Test-HasEtelRare -Lines $Lines) { return $false }
	if ($Lines -notmatch 'Item:\s*Etel_Dust\b') { return $false }

	$maxIdx = Get-MaxGlobalIndex -Lines $Lines
	$insertAt = $Lines.Count
	for ($i = 0; $i -lt $Lines.Count; $i++) {
		if ($Lines[$i] -match '^\s*SpecificDrops:') {
			$insertAt = $i
			break
		}
	}

	$newLines = New-Object System.Collections.Generic.List[string]
	$idx = $maxIdx + 1
	foreach ($drop in $etelRareDrops) {
		$newLines.Add("      - Index: $idx")
		$newLines.Add("        Item: $($drop.Item)")
		$newLines.Add("        Rate: $($drop.Rate)")
		$idx++
	}

	for ($j = $newLines.Count - 1; $j -ge 0; $j--) {
		$Lines.Insert($insertAt, $newLines[$j])
	}
	return $true
}

$rawLines = [System.Collections.Generic.List[string]]::new()
$rawLines.AddRange([string[]](Get-Content $reFile -Encoding UTF8))

$outLines = [System.Collections.Generic.List[string]]::new()
$currentMap = $null
$currentBlock = $null
$patched = 0

$i = 0
while ($i -lt $rawLines.Count) {
	$line = $rawLines[$i]
	if ($line -match '^\s*- Map:\s*(.+)\s*$') {
		if ($null -ne $currentBlock) {
			if ($currentMap -match $ep19MapPattern) {
				if (Add-EtelRareGlobalDrops -Lines $currentBlock) { $patched++ }
			}
			$outLines.AddRange($currentBlock)
		}
		$currentMap = $Matches[1].Trim()
		$currentBlock = [System.Collections.Generic.List[string]]::new()
		$currentBlock.Add($line)
	} elseif ($null -ne $currentBlock) {
		$currentBlock.Add($line)
	} else {
		$outLines.Add($line)
	}
	$i++
}

if ($null -ne $currentBlock) {
	if ($currentMap -match $ep19MapPattern) {
		if (Add-EtelRareGlobalDrops -Lines $currentBlock) { $patched++ }
	}
	$outLines.AddRange($currentBlock)
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($reFile, (($outLines -join "`n") + "`n"), $utf8NoBom)
Write-Host "Patched ${reFile}: added rare Etel map drops on $patched EP19 map(s)"
