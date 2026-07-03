# Boost Cor Core (EP17_1_EVT39) and Mysterious Component (EP17_1_EVT02) drops by 50%.
# - Multiply existing mob drop rates by 1.5
# - Add both items to 12 additional EP17.2 field mobs (50% more droppers)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$mobFile = Join-Path $root 'db\re\mob_db.yml'

function Round-DropRate {
	param([double]$Rate)
	return [int][Math]::Round($Rate, [MidpointRounding]::AwayFromZero)
}

# AegisName -> @{ EVT02 = rate; EVT39 = rate } (already +50% tuned)
$newDrops = @{
	'EP17_2_BELLARE3'       = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_DOLOR3'         = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_SANARE3'        = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_PLAGA3'         = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_VENENUM3'       = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_BOOKWORM'       = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_ROAMING_SPLBOOK' = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_CRAMP'          = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_WATERFALL'      = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_PLASMA_Y'       = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_PLASMA_R'       = @{ EVT02 = 15; EVT39 = 8 }
	'EP17_2_BETA_BASIC'     = @{ EVT02 = 15; EVT39 = 8 }
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.AddRange([string[]](Get-Content $mobFile -Encoding UTF8))

$rateBumps = 0
$dropsAdded = 0
$currentMob = $null
$inDrops = $false
$dropsStart = -1
$dropsEnd = -1
$pendingMobBlocks = @()

function Flush-MobBlock {
	param(
		[System.Collections.Generic.List[string]]$Block,
		[string]$AegisName
	)

	if ($null -eq $Block -or $Block.Count -eq 0) { return }

	$dropsIdx = -1
	$cardIdx = -1
	$hasEvt02 = $false
	$hasEvt39 = $false

	for ($i = 0; $i -lt $Block.Count; $i++) {
		$line = $Block[$i]
		if ($line -match '^\s+Drops:\s*$') { $dropsIdx = $i }
		if ($line -match '^\s+- Item:\s+EP17_1_EVT02\b') { $hasEvt02 = $true }
		if ($line -match '^\s+- Item:\s+EP17_1_EVT39\b') { $hasEvt39 = $true }
		if ($line -match '^\s+- Item:\s+.+\s*$' -and $line -match '_Card\b') {
			$cardIdx = $i
		}
	}

	# Bump existing rates for target items
	for ($i = 0; $i -lt $Block.Count - 1; $i++) {
		if ($Block[$i] -match '^\s+- Item:\s+(EP17_1_EVT02|EP17_1_EVT39)\s*$' -and
			$Block[$i + 1] -match '^\s+Rate:\s+(\d+)\s*$') {
			$old = [int]$Matches[1]
			$new = Round-DropRate ($old * 1.5)
			if ($new -ne $old) {
				$Block[$i + 1] = ($Block[$i + 1] -replace 'Rate:\s+\d+', "Rate: $new")
				$script:rateBumps++
			}
		}
	}

	if ($newDrops.ContainsKey($AegisName) -and $dropsIdx -ge 0 -and -not $hasEvt02 -and -not $hasEvt39) {
		$insertAt = if ($cardIdx -ge 0) { $cardIdx } else { $Block.Count }
		$rates = $newDrops[$AegisName]
		$insert = @(
			"      - Item: EP17_1_EVT39",
			"        Rate: $($rates.EVT39)",
			"      - Item: EP17_1_EVT02",
			"        Rate: $($rates.EVT02)"
		)
		for ($j = $insert.Count - 1; $j -ge 0; $j--) {
			$Block.Insert($insertAt, $insert[$j])
		}
		$script:dropsAdded++
	}

	$script:outLines.AddRange($Block)
}

$outLines = [System.Collections.Generic.List[string]]::new()
$currentBlock = $null
$currentAegis = $null

for ($i = 0; $i -lt $lines.Count; $i++) {
	$line = $lines[$i]
	if ($line -match '^\s+- Id:\s+\d+\s*$') {
		if ($null -ne $currentBlock) {
			Flush-MobBlock -Block $currentBlock -AegisName $currentAegis
		}
		$currentBlock = [System.Collections.Generic.List[string]]::new()
		$currentAegis = $null
		$currentBlock.Add($line)
		continue
	}

	if ($null -eq $currentBlock) {
		$outLines.Add($line)
		continue
	}

	$currentBlock.Add($line)
	if ($line -match '^\s+AegisName:\s+(\S+)\s*$') {
		$currentAegis = $Matches[1]
	}
}

if ($null -ne $currentBlock) {
	Flush-MobBlock -Block $currentBlock -AegisName $currentAegis
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($mobFile, (($outLines -join "`n") + "`n"), $utf8NoBom)
Write-Host "Updated ${mobFile}: bumped $rateBumps drop rate(s), added drops to $dropsAdded mob(s)"
