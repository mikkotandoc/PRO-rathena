# Patches itemmall in rAthena map_cache.dat using official kRO cell data (200x100).
# Usage: powershell -File tools/patch_itemmall_mapcache.ps1 [-CachePath db/re/map_cache.dat]

param(
	[string]$CachePath = (Join-Path $PSScriptRoot "..\db\re\map_cache.dat")
)

$ErrorActionPreference = "Stop"
$EntryPath = Join-Path $PSScriptRoot "data\itemmall_mapcache_entry.bin"

if (-not (Test-Path $EntryPath)) {
	Write-Error "Missing $EntryPath"
}

if (-not (Test-Path $CachePath)) {
	Write-Error "Missing map cache: $CachePath"
}

function Parse-Maps([byte[]]$Bytes) {
	$MapCount = [BitConverter]::ToUInt16($Bytes, 4)
	$Pos = 8
	$Maps = @()
	for ($I = 0; $I -lt $MapCount; $I++) {
		$Name = [Text.Encoding]::ASCII.GetString($Bytes, $Pos, 12).Trim([char]0)
		$Xs = [BitConverter]::ToInt16($Bytes, $Pos + 12)
		$Ys = [BitConverter]::ToInt16($Bytes, $Pos + 14)
		$Len = [BitConverter]::ToUInt32($Bytes, $Pos + 16)
		$Payload = New-Object byte[] $Len
		[Array]::Copy($Bytes, $Pos + 20, $Payload, 0, $Len)
		$Maps += ,@($Name, $Xs, $Ys, $Payload)
		$Pos += 20 + $Len
	}
	return $Maps
}

function Build-Cache($Maps) {
	$Body = New-Object System.Collections.Generic.List[byte]
	foreach ($M in ($Maps | Sort-Object { $_[0] })) {
		$NameBytes = New-Object byte[] 12
		$Encoded = [Text.Encoding]::ASCII.GetBytes($M[0])
		[Array]::Copy($Encoded, 0, $NameBytes, 0, [Math]::Min(11, $Encoded.Length))
		$Body.AddRange($NameBytes)
		$Body.AddRange([BitConverter]::GetBytes([int16]$M[1]))
		$Body.AddRange([BitConverter]::GetBytes([int16]$M[2]))
		$Body.AddRange([BitConverter]::GetBytes([uint32]$M[3].Length))
		$Body.AddRange($M[3])
	}
	$Arr = $Body.ToArray()
	$Out = New-Object byte[] (8 + $Arr.Length)
	[BitConverter]::GetBytes([uint32](8 + $Arr.Length)).CopyTo($Out, 0)
	[BitConverter]::GetBytes([uint16]$Maps.Count).CopyTo($Out, 4)
	$Arr.CopyTo($Out, 8)
	return $Out
}

$EntryBytes = [IO.File]::ReadAllBytes($EntryPath)
$EntryName = [Text.Encoding]::ASCII.GetString($EntryBytes, 0, 12).Trim([char]0)
$EntryXs = [BitConverter]::ToInt16($EntryBytes, 12)
$EntryYs = [BitConverter]::ToInt16($EntryBytes, 14)
$EntryLen = [BitConverter]::ToUInt32($EntryBytes, 16)
$EntryPayload = New-Object byte[] $EntryLen
[Array]::Copy($EntryBytes, 20, $EntryPayload, 0, $EntryLen)

$Local = [IO.File]::ReadAllBytes($CachePath)
$Maps = @(Parse-Maps $Local | Where-Object { $_[0] -ne $EntryName })
$Maps += ,@($EntryName, $EntryXs, $EntryYs, $EntryPayload)

$NewCache = Build-Cache $Maps
[IO.File]::WriteAllBytes($CachePath, $NewCache)
Write-Host "Patched $EntryName (${EntryXs}x${EntryYs}) in $CachePath"
