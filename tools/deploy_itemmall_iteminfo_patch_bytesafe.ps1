# Byte-safe deployment of itemmall_cash_items.lua into SystemEN/itemInfo_C.lua.
# Unlike deploy_itemmall_iteminfo_patch.ps1, this never decodes the target file
# as UTF-8, so raw CP949 (Korean) resource-name bytes are preserved exactly.
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia"
)

$ErrorActionPreference = "Stop"

$ItemInfoC = Join-Path $ClientRoot "SystemEN\itemInfo_C.lua"
$PatchFile = Join-Path $PSScriptRoot "client_patch\itemInfo\itemmall_cash_items.lua"
$Marker = "-- Item Mall cash shop (itemmall_cash_items.lua)"
$Anchor = "-- VIP Card 7D"

if (-not (Test-Path -LiteralPath $ItemInfoC)) { throw "itemInfo_C.lua not found: $ItemInfoC" }
if (-not (Test-Path -LiteralPath $PatchFile)) { throw "Patch file not found: $PatchFile" }

# Latin-1 round-trips all 256 byte values, so string operations stay byte-exact.
$latin1 = [System.Text.Encoding]::GetEncoding(28591)
$content = $latin1.GetString([System.IO.File]::ReadAllBytes($ItemInfoC))
$patch = $latin1.GetString([System.IO.File]::ReadAllBytes($PatchFile))

if ($patch -match '[^\x00-\x7F]') { throw "Patch file must be pure ASCII to be encoding-safe." }

# Strip leading header comments (everything up to the first blank line).
$patch = [regex]::Replace($patch, '(?s)\A(--[^\r\n]*\r?\n)+\r?\n', '')
# Normalize patch line endings to CRLF to match itemInfo_C.lua.
$patch = $patch -replace '\r?\n', "`r`n"
$patch = $patch.TrimEnd("`r", "`n") + "`r`n"

$mIdx = $content.IndexOf($Marker)
$aIdx = $content.IndexOf($Anchor)
if ($aIdx -lt 0) { throw "VIP Card anchor not found in itemInfo_C.lua" }

if ($mIdx -ge 0) {
	if ($aIdx -lt $mIdx) { throw "Anchor appears before marker; aborting." }
	# Keep the blank line right before the anchor.
	$blockEnd = $content.LastIndexOf("`r`n`r`n", $aIdx)
	if ($blockEnd -lt $mIdx) { $blockEnd = $aIdx }
	$before = $content.Substring(0, $mIdx)
	$after = $content.Substring($blockEnd)
	$content = $before + $Marker + "`r`n" + $patch + $after
	Write-Host "Replaced existing item mall block."
} else {
	$before = $content.Substring(0, $aIdx)
	$after = $content.Substring($aIdx)
	$content = $before + $Marker + "`r`n" + $patch + "`r`n" + $after
	Write-Host "Inserted item mall block before VIP section."
}

[System.IO.File]::WriteAllBytes($ItemInfoC, $latin1.GetBytes($content))
Write-Host "Deployed byte-safe item mall entries to $ItemInfoC"
