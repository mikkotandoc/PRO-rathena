# Removes UTF-8 BOM from itemInfo_C.lua (RO client Lua cannot parse BOM).
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea"
)

$ErrorActionPreference = "Stop"
$path = Join-Path $ClientRoot "SystemEN\itemInfo_C.lua"

if (-not (Test-Path $path)) { throw "itemInfo_C.lua not found: $path" }

$bytes = [System.IO.File]::ReadAllBytes($path)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
	$text = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
	$utf8 = New-Object System.Text.UTF8Encoding $false
	[System.IO.File]::WriteAllText($path, $text, $utf8)
	Write-Host "Removed UTF-8 BOM from itemInfo_C.lua"
} else {
	Write-Host "No UTF-8 BOM detected at start of itemInfo_C.lua"
}
