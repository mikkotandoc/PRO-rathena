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

function Find-Best($MapName, $Path, $PreferX, $PreferY, [string]$Edge) {
	$info = Get-MapInfo $Path $MapName
	if ($null -eq $info) { return $null }
	$best = $null
	$bestDist = [double]::MaxValue
	if ($Edge -eq 'south') {
		for ($y = $info.Ys - 1; $y -ge 240; $y--) {
			for ($x = 0; $x -lt $info.Xs; $x++) {
				if (-not (Test-Walkable $info.Cells $info.Xs $info.Ys $x $y)) { continue }
				$dist = [Math]::Abs($x - $PreferX) + ($info.Ys - 1 - $y)
				if ($dist -lt $bestDist) { $bestDist = $dist; $best = "$x,$y" }
			}
		}
	} elseif ($Edge -eq 'north') {
		for ($y = 0; $y -le 30; $y++) {
			for ($x = 0; $x -lt $info.Xs; $x++) {
				if (-not (Test-Walkable $info.Cells $info.Xs $info.Ys $x $y)) { continue }
				$dist = [Math]::Abs($x - $PreferX) + $y
				if ($dist -lt $bestDist) { $bestDist = $dist; $best = "$x,$y" }
			}
		}
	}
	return $best
}

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$path = Join-Path $root 'db\map_cache.dat'

$checks = @(
	@('jor_nest', 37, 270), @('jor_root1', 32, 11), @('jor_root1', 32, 15),
	@('jor_root1', 201, 259), @('jor_root2', 35, 10), @('jor_root2', 35, 7), @('jor_root1', 201, 256),
	@('jor_root2', 215, 244), @('jor_root3', 330, 20), @('jor_root3', 330, 14), @('jor_root2', 215, 238),
	@('jor_root2', 239, 243)
)

foreach ($c in $checks) {
	$info = Get-MapInfo $path $c[0]
	$ok = Test-Walkable $info.Cells $info.Xs $info.Ys $c[1] $c[2]
	Write-Output ("{0,-12} {1,3},{2,3} walkable={3}" -f $c[0], $c[1], $c[2], $ok)
}

Write-Output ''
Write-Output 'Suggested root1->root2 (south of root1 near x=200):'
Write-Output ("  exit:  {0}" -f (Find-Best 'jor_root1' $path 200 297 'south'))
Write-Output ("  entry: {0}" -f (Find-Best 'jor_root2' $path 200 12 'north'))
Write-Output 'Suggested root2->root3:'
Write-Output ("  exit:  {0}" -f (Find-Best 'jor_root2' $path 200 297 'south'))
Write-Output ("  entry: {0}" -f (Find-Best 'jor_root3' $path 50 12 'north'))
