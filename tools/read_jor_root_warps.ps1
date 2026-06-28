function Get-MapInfo {
	param(
		[string]$Path,
		[string]$MapName
	)
	$bytes = [IO.File]::ReadAllBytes($Path)
	$count = [BitConverter]::ToUInt16($bytes, 4)
	$pos = 8
	for ($i = 0; $i -lt $count; $i++) {
		$name = [Text.Encoding]::ASCII.GetString($bytes[$pos..($pos + 11)]).Trim([char]0)
		$xs = [BitConverter]::ToInt16($bytes, $pos + 12)
		$ys = [BitConverter]::ToInt16($bytes, $pos + 14)
		$len = [BitConverter]::ToInt32($bytes, $pos + 16)
		if ($name -eq $MapName) {
			$c = New-Object byte[] $len
			[Array]::Copy($bytes, $pos + 20, $c, 0, $len)
			$msIn = New-Object IO.MemoryStream(,$c)
			$msIn.Position = 2
			$msOut = New-Object IO.MemoryStream
			$d = New-Object IO.Compression.DeflateStream($msIn, [IO.Compression.CompressionMode]::Decompress)
			$d.CopyTo($msOut)
			return [PSCustomObject]@{
				Name = $name
				Xs = $xs
				Ys = $ys
				Cells = $msOut.ToArray()
			}
		}
		$pos += 20 + $len
	}
	return $null
}

function Test-Walkable {
	param($Cells, $Xs, $Ys, $X, $Y)
	if ($X -lt 0 -or $Y -lt 0 -or $X -ge $Xs -or $Y -ge $Ys) { return $false }
	$gat = $Cells[($Y * $Xs) + $X]
	return ($gat -in 0,2,3,4,6)
}

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$path = Join-Path $root 'db\map_cache.dat'

$warps = @(
	@{ Map = 'jor_nest'; X = 37; Y = 270; Label = 'nest->root1' },
	@{ Map = 'jor_root1'; X = 32; Y = 8; Label = 'root1->nest' },
	@{ Map = 'jor_root1'; X = 200; Y = 297; Label = 'root1->root2' },
	@{ Map = 'jor_root2'; X = 200; Y = 8; Label = 'root2->root1' },
	@{ Map = 'jor_root2'; X = 200; Y = 297; Label = 'root2->root3' },
	@{ Map = 'jor_root2'; X = 239; Y = 243; Label = 'root2->safty2' }
)

foreach ($mapName in @('jor_root1', 'jor_root2', 'jor_nest')) {
	$info = Get-MapInfo -Path $path -MapName $mapName
	if ($null -eq $info) {
		Write-Output "$mapName not found"
		continue
	}
	Write-Output "$($info.Name): $($info.Xs)x$($info.Ys)"
}

Write-Output ''
Write-Output 'Warp coordinate check:'
foreach ($w in $warps) {
	$info = Get-MapInfo -Path $path -MapName $w.Map
	if ($null -eq $info) { continue }
	$ib = ($w.X -ge 0 -and $w.Y -ge 0 -and $w.X -lt $info.Xs -and $w.Y -lt $info.Ys)
	$ok = Test-Walkable -Cells $info.Cells -Xs $info.Xs -Ys $info.Ys -X $w.X -Y $w.Y
	Write-Output ("  {0,-16} {1,3},{2,3} inBounds={3} walkable={4}" -f $w.Label, $w.X, $w.Y, $ib, $ok)
}

function Scan-Edge {
	param($Info, [string]$Label, [int]$StartY, [int]$EndY, [int]$StartX, [int]$EndX)
	Write-Output ''
	Write-Output $Label
	for ($y = $StartY; $y -le $EndY; $y++) {
		$row = @()
		for ($x = $StartX; $x -le $EndX; $x++) {
			if (Test-Walkable -Cells $Info.Cells -Xs $Info.Xs -Ys $Info.Ys -X $x -Y $y) { $row += $x }
		}
		if ($row.Count -gt 0) { Write-Output ("  y={0,3}: {1}" -f $y, ($row -join ',')) }
	}
}

$root1 = Get-MapInfo -Path $path -MapName 'jor_root1'
$root2 = Get-MapInfo -Path $path -MapName 'jor_root2'
if ($null -ne $root1) {
	Scan-Edge $root1 'jor_root1 south edge (y=250..299, all x):' 250 299 0 299
	Scan-Edge $root1 'jor_root1 north edge (y=0..30, all x):' 0 30 0 299
}
if ($null -ne $root2) {
	Scan-Edge $root2 'jor_root2 north edge (y=0..30, all x):' 0 30 0 299
	Scan-Edge $root2 'jor_root2 south edge (y=250..299, all x):' 250 299 0 299
}
