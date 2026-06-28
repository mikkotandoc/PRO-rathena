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
$root3 = Get-MapInfo $path 'jor_root3'

Write-Output 'jor_root3 northernmost walkable per column x=40..60:'
for ($x = 40; $x -le 60; $x++) {
	for ($y = 0; $y -le 50; $y++) {
		if (Test-Walkable $root3.Cells $root3.Xs $root3.Ys $x $y) {
			Write-Output "  x=$x -> y=$y"
			break
		}
	}
}

Write-Output ''
Write-Output 'jor_root3 y=0..20 all walkable x:'
for ($y = 0; $y -le 20; $y++) {
	$row = @()
	for ($x = 0; $x -lt $root3.Xs; $x++) {
		if (Test-Walkable $root3.Cells $root3.Xs $root3.Ys $x $y) { $row += $x }
	}
	if ($row.Count -gt 0) { Write-Output ("  y={0,2}: first={1} last={2} count={3}" -f $y, $row[0], $row[-1], $row.Count) }
}

Write-Output ''
Write-Output 'Final proposed coords:'
$final = @(
	@('jor_root3', 330, 15), @('jor_root3', 330, 16), @('jor_root3', 330, 17), @('jor_root3', 330, 18),
	@('jor_root2', 215, 240), @('jor_root2', 215, 238)
)
foreach ($c in $final) {
	$info = Get-MapInfo $path $c[0]
	$ok = Test-Walkable $info.Cells $info.Xs $info.Ys $c[1] $c[2]
	Write-Output ("{0,-12} {1,3},{2,3} walkable={3}" -f $c[0], $c[1], $c[2], $ok)
}
