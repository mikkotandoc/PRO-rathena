Add-Type -AssemblyName System.IO.Compression

function Get-MapGatCells {
	param(
		[string]$Path,
		[string]$MapName
	)

	$bytes = [IO.File]::ReadAllBytes($Path)
	$count = [BitConverter]::ToUInt16($bytes, 4)
	$pos = 8

	for ($i = 0; $i -lt $count; $i++) {
		$nameBytes = $bytes[$pos..($pos + 11)]
		$name = [Text.Encoding]::ASCII.GetString($nameBytes).Trim([char]0)
		$xs = [BitConverter]::ToInt16($bytes, $pos + 12)
		$ys = [BitConverter]::ToInt16($bytes, $pos + 14)
		$len = [BitConverter]::ToInt32($bytes, $pos + 16)
		$dataPos = $pos + 20

		if ($name -eq $MapName) {
			$expected = [int]$xs * [int]$ys
			$compressed = New-Object byte[] $len
			[Array]::Copy($bytes, $dataPos, $compressed, 0, $len)

			$msOut = New-Object IO.MemoryStream
			$msIn = New-Object IO.MemoryStream(,$compressed)
			$msIn.Position = 2  # skip zlib CMF/FLG header used by rAthena map_cache
			$deflate = New-Object IO.Compression.DeflateStream($msIn, [IO.Compression.CompressionMode]::Decompress)
			$deflate.CopyTo($msOut)
			$deflate.Dispose()
			$msIn.Dispose()

			$cells = $msOut.ToArray()
			if ($cells.Length -ne $expected) {
				Write-Warning ("{0}: decompressed {1} bytes, expected {2}" -f $name, $cells.Length, $expected)
			}

			return [PSCustomObject]@{
				Name = $name
				Xs = $xs
				Ys = $ys
				Cells = $msOut.ToArray()
			}
		}

		$pos = $dataPos + $len
	}

	return $null
}

function Test-Walkable {
	param(
		[byte[]]$Cells,
		[int16]$Xs,
		[int16]$Ys,
		[int]$X,
		[int]$Y
	)

	if ($X -lt 0 -or $Y -lt 0 -or $X -ge $Xs -or $Y -ge $Ys) {
		return $false
	}

	# GAT types with walkable=1 in rAthena: 0,2,3,4,6
	$gat = $Cells[($Y * $Xs) + $X]
	return ($gat -in 0,2,3,4,6)
}

$cachePaths = @(
	'db\import\map_cache.dat',
	'db\re\map_cache.dat',
	'db\map_cache.dat'
)

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$mapInfo = $null

foreach ($rel in $cachePaths) {
	$path = Join-Path $root $rel
	if (-not (Test-Path $path)) { continue }
	$mapInfo = Get-MapGatCells -Path $path -MapName '1@20cn1'
		if ($null -ne $mapInfo) {
		Write-Output "Using cache: $path"
		$script:pathUsed = $path
		break
	}
}

if ($null -eq $mapInfo) {
	Write-Error '1@20cn1 not found in map cache'
	exit 1
}

Write-Output ("Map {0}: {1}x{2}" -f $mapInfo.Name, $mapInfo.Xs, $mapInfo.Ys)

# Original script coords (kRO walkthrough) and -100 shifted variants
$allCoords = @(
	@{ Label = 'instance entry'; X = 256; Y = 75 },
	@{ Label = 'Lehar#ep20cn00'; X = 256; Y = 75 },
	@{ Label = 'Iwin#ep20cn01'; X = 276; Y = 82 },
	@{ Label = 'Iwin#ep20cn02'; X = 232; Y = 238 },
	@{ Label = 'Portal#ep20cn01'; X = 241; Y = 252 },
	@{ Label = 'Lehar#ep20cn02'; X = 240; Y = 248 },
	@{ Label = 'Bagot#ep20cn01'; X = 165; Y = 241 },
	@{ Label = 'Nyar#ep20cn01'; X = 240; Y = 245 },
	@{ Label = 'Portal#ep20cn02'; X = 240; Y = 242 },
	@{ Label = 'Lehar#ep20cn03'; X = 255; Y = 72 },
	@{ Label = 'Nyar#ep20cn02'; X = 258; Y = 68 },
	@{ Label = 'Portal#ep20cn03'; X = 260; Y = 65 }
)

Write-Output ''
Write-Output 'Coordinate walkability check:'
foreach ($t in $allCoords) {
	$ok = Test-Walkable -Cells $mapInfo.Cells -Xs $mapInfo.Xs -Ys $mapInfo.Ys -X $t.X -Y $t.Y
	$inBounds = ($t.X -ge 0 -and $t.Y -ge 0 -and $t.X -lt $mapInfo.Xs -and $t.Y -lt $mapInfo.Ys)
	Write-Output ("  {0,-22} ({1,3},{2,3}) inBounds={3} walkable={4}" -f $t.Label, $t.X, $t.Y, $inBounds, $ok)
}

Write-Output ''
Write-Output 'Walkable cells near entry area (y=70..85, x=240..299):'
for ($y = 70; $y -le 85; $y++) {
	$row = @()
	for ($x = 240; $x -lt $mapInfo.Xs; $x++) {
		if (Test-Walkable -Cells $mapInfo.Cells -Xs $mapInfo.Xs -Ys $mapInfo.Ys -X $x -Y $y) {
			$row += $x
		}
	}
	if ($row.Count -gt 0) {
		Write-Output ("  y={0,3}: x={1}" -f $y, ($row -join ','))
	}
}

Write-Output ''
Write-Output 'Walkable cells near Iwin2 area (y=230..250, x=220..299):'
for ($y = 230; $y -le 250; $y++) {
	$row = @()
	for ($x = 220; $x -lt $mapInfo.Xs; $x++) {
		if (Test-Walkable -Cells $mapInfo.Cells -Xs $mapInfo.Xs -Ys $mapInfo.Ys -X $x -Y $y) {
			$row += $x
		}
	}
	if ($row.Count -gt 0) {
		Write-Output ("  y={0,3}: x={1}" -f $y, ($row -join ','))
	}
}

Write-Output ''
Write-Output 'Walkable cells near portal1 area (y=245..255, x=235..299):'
for ($y = 245; $y -le 255; $y++) {
	$row = @()
	for ($x = 235; $x -lt $mapInfo.Xs; $x++) {
		if (Test-Walkable -Cells $mapInfo.Cells -Xs $mapInfo.Xs -Ys $mapInfo.Ys -X $x -Y $y) {
			$row += $x
		}
	}
	if ($row.Count -gt 0) {
		Write-Output ("  y={0,3}: x={1}" -f $y, ($row -join ','))
	}
}

Write-Output ''
Write-Output '1@20cn2 coordinates:'
$map2 = Get-MapGatCells -Path $pathUsed -MapName '1@20cn2'
if ($null -ne $map2) {
	Write-Output ("Map {0}: {1}x{2}" -f $map2.Name, $map2.Xs, $map2.Ys)
	foreach ($t in @(
		@{ Label = 'Lehar finale'; X = 33; Y = 27 },
		@{ Label = 'Exit portal'; X = 38; Y = 27 }
	)) {
		$ok = Test-Walkable -Cells $map2.Cells -Xs $map2.Xs -Ys $map2.Ys -X $t.X -Y $t.Y
		$inBounds = ($t.X -ge 0 -and $t.Y -ge 0 -and $t.X -lt $map2.Xs -and $t.Y -lt $map2.Ys)
		Write-Output ("  {0,-18} ({1,3},{2,3}) inBounds={3} walkable={4}" -f $t.Label, $t.X, $t.Y, $inBounds, $ok)
	}
}
