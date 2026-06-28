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

Write-Output "jor_root3: $($root3.Xs)x$($root3.Ys)"
Write-Output 'north edge y=0..35:'
for ($y = 0; $y -le 35; $y++) {
	$row = @()
	for ($x = 0; $x -lt 50; $x++) {
		if (Test-Walkable $root3.Cells $root3.Xs $root3.Ys $x $y) { $row += $x }
	}
	if ($row.Count -gt 0) { Write-Output ("  y={0,2}: {1}" -f $y, ($row -join ',')) }
}

Write-Output ''
Write-Output 'Verify proposed coords:'
$coords = @(
	@('jor_root1', 201, 259), @('jor_root2', 35, 10), @('jor_root2', 35, 7), @('jor_root1', 201, 256),
	@('jor_root1', 32, 11), @('jor_root2', 215, 244), @('jor_root3', 126, 30), @('jor_root3', 126, 33)
)
foreach ($c in $coords) {
	$info = Get-MapInfo $path $c[0]
	$ok = Test-Walkable $info.Cells $info.Xs $info.Ys $c[1] $c[2]
	Write-Output ("{0,-12} {1,3},{2,3} walkable={3}" -f $c[0], $c[1], $c[2], $ok)
}
