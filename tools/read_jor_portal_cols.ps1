function Get-MapInfo {
	param([string]$Path, [string]$MapName)
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
			return [PSCustomObject]@{ Name = $name; Xs = $xs; Ys = $ys; Cells = $msOut.ToArray() }
		}
		$pos += 20 + $len
	}
}

function Test-Walkable($Cells, $Xs, $Ys, $X, $Y) {
	if ($X -lt 0 -or $Y -lt 0 -or $X -ge $Xs -or $Y -ge $Ys) { return $false }
	return ($Cells[($Y * $Xs) + $X] -in 0,2,3,4,6)
}

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$path = Join-Path $root 'db\map_cache.dat'
$root1 = Get-MapInfo $path 'jor_root1'
$root2 = Get-MapInfo $path 'jor_root2'

Write-Output 'jor_root1 column x=200:'
for ($y = 240; $y -lt 300; $y++) {
	$ok = Test-Walkable $root1.Cells $root1.Xs $root1.Ys 200 $y
	if ($ok) { Write-Output "  y=$y walkable" }
}

Write-Output ''
Write-Output 'jor_root1 southernmost walkable per column (x=180..220):'
for ($x = 180; $x -le 220; $x++) {
	for ($y = 299; $y -ge 240; $y--) {
		if (Test-Walkable $root1.Cells $root1.Xs $root1.Ys $x $y) {
			Write-Output "  x=$x -> y=$y"
			break
		}
	}
}

Write-Output ''
Write-Output 'jor_root2 column x=200 (north):'
for ($y = 0; $y -le 30; $y++) {
	$ok = Test-Walkable $root2.Cells $root2.Xs $root2.Ys 200 $y
	if ($ok) { Write-Output "  y=$y walkable" }
}

Write-Output ''
Write-Output 'jor_root2 northernmost walkable per column (x=10..40):'
for ($x = 10; $x -le 40; $x++) {
	for ($y = 0; $y -le 30; $y++) {
		if (Test-Walkable $root2.Cells $root2.Xs $root2.Ys $x $y) {
			Write-Output "  x=$x -> y=$y"
			break
		}
	}
}

Write-Output ''
Write-Output 'jor_root1 northernmost walkable (x=25..45):'
for ($x = 25; $x -le 45; $x++) {
	for ($y = 0; $y -le 30; $y++) {
		if (Test-Walkable $root1.Cells $root1.Xs $root1.Ys $x $y) {
			Write-Output "  x=$x -> y=$y"
			break
		}
	}
}
