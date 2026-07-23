# Merges item mall cash shop itemInfo entries into the client override table.
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia - Copy"
)

$ErrorActionPreference = "Stop"

$ItemInfoC = Join-Path $ClientRoot "SystemEN\itemInfo_C.lua"
$PatchFile = Join-Path $PSScriptRoot "client_patch\itemInfo\itemmall_cash_items.lua"
$Marker = "-- Item Mall cash shop (itemmall_cash_items.lua)"

if (-not (Test-Path $ItemInfoC)) { throw "itemInfo_C.lua not found: $ItemInfoC" }
if (-not (Test-Path $PatchFile)) { throw "Patch file not found: $PatchFile" }

$content = Get-Content -Path $ItemInfoC -Raw -Encoding UTF8
$patch = Get-Content -Path $PatchFile -Raw -Encoding UTF8

# Strip UTF-8 BOM if present (Lua cannot parse it).
if ($content.Length -gt 0 -and [int][char]$content[0] -eq 0xFEFF) {
	$content = $content.Substring(1)
}

# Strip header comments from the patch body.
$patch = [regex]::Replace($patch, '(?s)\A--.*?\n\n', '')

if ($content -match [regex]::Escape($Marker)) {
	$pattern = "(?s)$([regex]::Escape($Marker)).*?(?=\r?\n-- VIP Card 7D)"
	$content = [regex]::Replace($content, $pattern, "$Marker`r`n$patch")
	Write-Host "Updated existing item mall itemInfo block."
} else {
	$anchor = "`r`n-- VIP Card 7D (7 Days)"
	if ($content -notmatch [regex]::Escape($anchor.Trim())) {
		$anchor = "`n-- VIP Card 7D (7 Days)"
	}
	if ($content -notmatch '-- VIP Card 7D') {
		throw "Could not find VIP Card anchor in itemInfo_C.lua"
	}
	$content = $content -replace '(?s)(\r?\n-- VIP Card 7D \(7 Days\))', "$([Environment]::NewLine)$Marker$([Environment]::NewLine)$patch`$1"
	Write-Host "Inserted item mall itemInfo block before VIP section."
}

# Lua clients cannot parse UTF-8 BOM; PowerShell's UTF8 encoding adds one by default.
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($ItemInfoC, $content, $utf8NoBom)
Write-Host "Deployed item mall cash shop entries to $ItemInfoC"
