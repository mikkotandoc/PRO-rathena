param(
	[Parameter(Mandatory = $true)]
	[int]$EntryId,
	[Parameter(Mandatory = $true)]
	[string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$extracted = Join-Path $PSScriptRoot "_item_enchant_$EntryId.yml"
if (-not (Test-Path $extracted)) {
	$source = Join-Path (Resolve-Path (Join-Path $PSScriptRoot '..')).Path 'db\re\item_enchant.yml'
	$sourceLines = Get-Content $source -Encoding UTF8
	$start = -1
	for ($i = 0; $i -lt $sourceLines.Count; $i++) {
		if ($sourceLines[$i] -eq "  - Id: $EntryId") {
			$start = $i + 1
			break
		}
	}
	if ($start -lt 0) {
		throw "Item enchant Id $EntryId not found in $source"
	}
	$end = $sourceLines.Count
	for ($i = $start; $i -lt $sourceLines.Count; $i++) {
		if ($sourceLines[$i] -match '^  - Id: \d+$') {
			$end = $i
			break
		}
	}
	$sourceLines[$start..($end - 1)] | Set-Content -Path $extracted -Encoding UTF8
}

function Format-Materials([System.Collections.Generic.List[object]]$Materials) {
	if ($Materials.Count -eq 0) { return '' }
	$parts = foreach ($mat in $Materials) { "{`"$($mat.Name)`", $($mat.Amount)}" }
	return ', ' + ($parts -join ', ')
}

$lines = Get-Content $extracted -Encoding UTF8
$out = New-Object System.Collections.Generic.List[string]
$targetItems = New-Object System.Collections.Generic.List[string]
$order = New-Object System.Collections.Generic.List[int]
$slots = @{}

$section = ''
$slotId = 0
$grade = 0
$mode = ''
$pendingItem = $null
$pendingEnchant = $null
$pendingUpgrade = $null

function Ensure-Slot([int]$Id) {
	if (-not $script:slots.ContainsKey($Id)) {
		$script:slots[$Id] = [ordered]@{
			Price = 0
			Chance = 100000
			Materials = New-Object System.Collections.Generic.List[object]
			Enchants = @{}
			Perfect = New-Object System.Collections.Generic.List[object]
			Upgrades = New-Object System.Collections.Generic.List[object]
		}
	}
}

foreach ($line in $lines) {
	if ($line -match '^\s{6}(\w[\w_]*): true\s*$') {
		$targetItems.Add($Matches[1])
		continue
	}
	if ($line -match '^\s{4}Reset:') { $section = 'reset'; continue }
	if ($line -match '^\s{4}Order:') { $section = 'order'; continue }
	if ($line -match '^\s{4}Slots:') { $section = 'slots'; continue }
	if ($line -match '^\s{6}- Slot: (\d+)') {
		$slotId = [int]$Matches[1]
		Ensure-Slot $slotId
		if ($section -eq 'order') { $order.Add($slotId) }
		$mode = 'slot'
		continue
	}
	switch ($section) {
		'slots' {
			Ensure-Slot $slotId
			$slot = $slots[$slotId]
			if ($line -match '^\s{8}Price: (\d+)') { $slot.Price = [int]$Matches[1]; continue }
			if ($line -match '^\s{8}Chance: (\d+)') { $slot.Chance = [int]$Matches[1]; continue }
			if ($line -match '^\s{10}- Material: (\S+)') { $pendingItem = @{ Name = $Matches[1]; Amount = 0 }; continue }
			if ($line -match '^\s{12}Amount: (\d+)' -and $pendingItem) {
				$pendingItem.Amount = [int]$Matches[1]
				$slot.Materials.Add([pscustomobject]$pendingItem)
				$pendingItem = $null
				continue
			}
			if ($line -match '^\s{10}- Enchantgrade: (\d+)') {
				$grade = [int]$Matches[1]
				if (-not $slot.Enchants.ContainsKey($grade)) { $slot.Enchants[$grade] = New-Object System.Collections.Generic.List[object] }
				continue
			}
			if ($line -match '^\s{14}- Item: (\S+)') {
				$pendingEnchant = $Matches[1]
				continue
			}
			if ($line -match '^\s{16}Chance: (\d+)' -and $pendingEnchant) {
				$slot.Enchants[$grade].Add([pscustomobject]@{ Name = $pendingEnchant; Chance = [int]$Matches[1] })
				$pendingEnchant = $null
				continue
			}
			if ($line -match '^\s{8}PerfectEnchants:') { $mode = 'perfect'; continue }
			if ($line -match '^\s{8}Upgrades:') { $mode = 'upgrade'; continue }
			if ($mode -eq 'perfect' -and $line -match '^\s{10}- Item: (\S+)') {
				$slot.Perfect.Add([pscustomobject]@{ Name = $Matches[1]; Price = 0; Materials = New-Object System.Collections.Generic.List[object] })
				continue
			}
			if ($mode -eq 'perfect' -and $line -match '^\s{12}Price: (\d+)') {
				$slot.Perfect[$slot.Perfect.Count - 1].Price = [int]$Matches[1]
				continue
			}
			if ($mode -eq 'perfect' -and $line -match '^\s{14}- Material: (\S+)') {
				$pendingItem = @{ Name = $Matches[1]; Amount = 0 }
				continue
			}
			if ($mode -eq 'perfect' -and $line -match '^\s{16}Amount: (\d+)' -and $pendingItem) {
				$pendingItem.Amount = [int]$Matches[1]
				$slot.Perfect[$slot.Perfect.Count - 1].Materials.Add([pscustomobject]$pendingItem)
				$pendingItem = $null
				continue
			}
			if ($mode -eq 'upgrade' -and $line -match '^\s{10}- Enchant: (\S+)') {
				$slot.Upgrades.Add([pscustomobject]@{
					From = $Matches[1]; To = ''; Price = 0; Materials = New-Object System.Collections.Generic.List[object]
				})
				continue
			}
			if ($mode -eq 'upgrade' -and $line -match '^\s{12}Upgrade: (\S+)') {
				$slot.Upgrades[$slot.Upgrades.Count - 1].To = $Matches[1]
				continue
			}
			if ($mode -eq 'upgrade' -and $line -match '^\s{12}Price: (\d+)') {
				$slot.Upgrades[$slot.Upgrades.Count - 1].Price = [int]$Matches[1]
				continue
			}
			if ($mode -eq 'upgrade' -and $line -match '^\s{14}- Material: (\S+)') {
				$pendingItem = @{ Name = $Matches[1]; Amount = 0 }
				continue
			}
			if ($mode -eq 'upgrade' -and $line -match '^\s{16}Amount: (\d+)' -and $pendingItem) {
				$pendingItem.Amount = [int]$Matches[1]
				$slot.Upgrades[$slot.Upgrades.Count - 1].Materials.Add([pscustomobject]$pendingItem)
				$pendingItem = $null
				continue
			}
		}
	}
}

$out.Add("Table[$EntryId] = CreateEnchantInfo()")
$out.Add("Table[$EntryId]:SetSlotOrder($($order -join ', '))")
foreach ($item in $targetItems) { $out.Add("Table[$EntryId]:AddTargetItem(`"$item`")") }
$out.Add("Table[$EntryId]:SetCondition(0, 0)")
$out.Add("Table[$EntryId]:ApproveRandomOption(true)")
$out.Add("Table[$EntryId]:SetReset(true, 70000, 500000)")
$out.Add('Table[{0}]:SetCaution("Temporal Circlet Enchantment\nReset Chance: 70%\nOn reset failure the circlet is destroyed.")' -f $EntryId)

	foreach ($slotKey in $order) {
	$slot = $slots[$slotKey]
	$prefix = "Table[$EntryId].Slot[$slotKey]"
	if ($slot.Enchants.Count -gt 0) {
		$out.Add("$prefix`:SetRequire($($slot.Price)$(Format-Materials $slot.Materials))")
		$out.Add("$prefix`:SetSuccessRate($($slot.Chance))")
		0..4 | ForEach-Object { $out.Add("$prefix`:SetGradeBonus($_, 0)") }
		foreach ($gradeKey in ($slot.Enchants.Keys | Sort-Object)) {
			$items = @($slot.Enchants[$gradeKey])
			$sum = ($items | ForEach-Object { $_.Chance } | Measure-Object -Sum).Sum
			if ($sum -ne 100000 -and $sum -gt 0) {
				$scaled = foreach ($item in $items) {
					[pscustomobject]@{
						Name = $item.Name
						Chance = [int][Math]::Floor($item.Chance * 100000.0 / $sum)
					}
				}
				$remainder = 100000 - (($scaled | ForEach-Object { $_.Chance } | Measure-Object -Sum).Sum)
				for ($r = 0; $r -lt $remainder; $r++) {
					$scaled[$r % $scaled.Count].Chance++
				}
				$items = $scaled
			}
			foreach ($item in $items) {
				$out.Add("$prefix`:SetEnchant($gradeKey, `"$($item.Name)`", $($item.Chance))")
			}
		}
	}
	foreach ($perfect in $slot.Perfect) {
		$out.Add("$prefix`:AddPerfectEnchant(`"$($perfect.Name)`", $($perfect.Price)$(Format-Materials $perfect.Materials))")
	}
	foreach ($upgrade in $slot.Upgrades) {
		$out.Add("$prefix`:AddUpgradeEnchant(`"$($upgrade.From)`", `"$($upgrade.To)`", $($upgrade.Price)$(Format-Materials $upgrade.Materials))")
	}
}

$dir = Split-Path $OutputPath -Parent
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
# Lua clients cannot parse UTF-8 BOM; PowerShell's UTF8 encoding adds one by default.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($OutputPath, (($out -join "`r`n") + "`r`n"), $utf8NoBom)
Write-Host "Wrote $($out.Count) lines -> $OutputPath"
