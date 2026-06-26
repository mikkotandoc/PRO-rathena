# Generates custom card art assets WITHOUT overriding official card tables.
# Official card View art comes from data.grf. Never write a partial
# data/num2cardillustnametable.txt - it replaces the full GRF table and
# causes Gravity errors on almost every card.
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea",
	[string]$ItemInfoC = "",
	[string]$PatchOut = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ItemInfoC)) {
	$ItemInfoC = Join-Path $ClientRoot "SystemEN\itemInfo_C.lua"
}
if ([string]::IsNullOrWhiteSpace($PatchOut)) {
	$PatchOut = Join-Path $PSScriptRoot "card_illust_custom_patch.txt"
}

if (-not (Test-Path $ItemInfoC)) {
	throw "itemInfo_C.lua not found: $ItemInfoC"
}

$content = Get-Content -Path $ItemInfoC -Raw -Encoding UTF8
$matches = [regex]::Matches($content, '\[(\d+)\]\s*=\s*\{(?<body>[\s\S]*?)\n\t\},')
$cards = @()

foreach ($m in $matches) {
	$id = [int]$m.Groups[1].Value
	$body = $m.Groups['body'].Value
	if ($body -notmatch 'Type:\^000000 Card') { continue }
	if ($id -lt 1230000) { continue }

	$name = [regex]::Match($body, 'identifiedDisplayName = "([^"]+)"').Groups[1].Value
	$hasEffect = $body -match 'EffectID\s*='
	$cards += [pscustomobject]@{
		Id = $id
		Name = $name
		HasEffect = $hasEffect
	}
}

if ($cards.Count -eq 0) {
	Write-Host "No custom card IDs (>= 1230000) found in itemInfo_C.lua"
	exit 0
}

function Get-CardPrefix {
	param([string]$CardName)
	$prefix = $CardName -replace '\s+Card\s*$', ''
	$prefix = $prefix.Trim()
	if ([string]::IsNullOrWhiteSpace($prefix)) { return "Custom" }
	return $prefix
}

$dataDir = Join-Path $ClientRoot "data"
$uiFolder = [Text.Encoding]::GetEncoding(949).GetString([byte[]](0xC0,0xAF,0xC0,0xDA,0xC0,0xCE,0xC5,0xCD,0xC6,0xE4,0xC0,0xCC,0xBD,0xBA))
$cardBmpDir = Join-Path (Join-Path (Join-Path $dataDir "texture") $uiFolder) "cardbmp"
New-Item -ItemType Directory -Force -Path $cardBmpDir | Out-Null

function New-PlaceholderCardBmp {
	param([string]$Path)
	if (Test-Path -LiteralPath $Path) { return }

	$width = 300
	$height = 400
	$rowSize = [int][Math]::Ceiling(($width * 3) / 4) * 4
	$pixelBytes = $rowSize * $height
	$fileSize = 54 + $pixelBytes

	$ms = New-Object System.IO.MemoryStream
	$bw = New-Object System.IO.BinaryWriter($ms)
	$bw.Write([byte[]]@(0x42, 0x4D))
	$bw.Write([int32]$fileSize)
	$bw.Write([int32]0)
	$bw.Write([int32]54)
	$bw.Write([int32]40)
	$bw.Write([int32]$width)
	$bw.Write([int32]$height)
	$bw.Write([int16]1)
	$bw.Write([int16]24)
	$bw.Write([int32]0)
	$bw.Write([int32]$pixelBytes)
	$bw.Write([int32]0)
	$bw.Write([int32]0)
	$bw.Write([int32]0)
	$bw.Write([int32]0)

	for ($y = 0; $y -lt $height; $y++) {
		for ($x = 0; $x -lt $width; $x++) {
			if ($x -lt 8 -or $x -ge ($width - 8) -or $y -lt 8 -or $y -ge ($height - 8)) {
				$bw.Write([byte]40); $bw.Write([byte]40); $bw.Write([byte]40)
			} else {
				$bw.Write([byte]200); $bw.Write([byte]200); $bw.Write([byte]200)
			}
		}
		for ($p = 0; $p -lt ($rowSize - ($width * 3)); $p++) { $bw.Write([byte]0) }
	}

	$bw.Flush()
	[System.IO.File]::WriteAllBytes($Path, $ms.ToArray())
	$bw.Close(); $ms.Close()
}

$illustPatch = New-Object System.Collections.Generic.List[string]
$prefixPatch = New-Object System.Collections.Generic.List[string]

foreach ($card in $cards) {
	$illust = "$($card.Id)"
	$illustPatch.Add("$($card.Id)#$illust#")
	$prefixPatch.Add("$($card.Id)#$(Get-CardPrefix $card.Name)#")
	New-PlaceholderCardBmp -Path (Join-Path $cardBmpDir "$illust.bmp")
}

$patchDir = Split-Path $PatchOut -Parent
if (-not (Test-Path $patchDir)) { New-Item -ItemType Directory -Force -Path $patchDir | Out-Null }

$patchText = @(
	"# Merge these lines into proasia_Custom.grf -> data/num2cardillustnametable.txt"
	"# Do NOT place a partial table in data/ (it overrides the full GRF table)."
	"#"
	"# num2cardillustnametable.txt"
) + $illustPatch + @(
	"#",
	"# cardprefixnametable.txt"
) + $prefixPatch

$patchText | Set-Content -Path $PatchOut -Encoding Default

$missingEffect = $cards | Where-Object { -not $_.HasEffect }
if ($missingEffect.Count -gt 0) {
	Write-Warning "Cards missing EffectID in itemInfo_C.lua: $($missingEffect.Id -join ', ')"
}

Write-Host ('Ensured {0} custom card BMP placeholders in {1}' -f $cards.Count, $cardBmpDir)
Write-Host ('Wrote GRF merge patch to {0}' -f $PatchOut)
