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
$s2 = Get-MapInfo $path 'jor_safty2'

Write-Output 'jor_safty2 walkable y=30-50 (north area):'
for ($y = 30; $y -le 50; $y++) {
	$row = @()
	for ($x = 180; $x -le 200; $x++) {
		if (Test-Walkable $s2.Cells $s2.Xs $s2.Ys $x $y) { $row += $x }
	}
	if ($row.Count -gt 0) { Write-Output ("  y={0,2}: {1}" -f $y, ($row -join ',')) }
}

Write-Output ''
Write-Output 'jor_safty2 walkable y=340-370 x=60-90:'
for ($y = 340; $y -le 370; $y++) {
	$row = @()
	for ($x = 60; $x -le 90; $x++) {
		if (Test-Walkable $s2.Cells $s2.Xs $s2.Ys $x $y) { $row += $x }
	}
	if ($row.Count -gt 0) { Write-Output ("  y={0,3}: {1}" -f $y, ($row -join ',')) }
}

Write-Output ''
Write-Output 'Other safty2 warps walkability:'
foreach ($c in @(@('jor_safty2',190,38),@('jor_safty2',310,43),@('jor_safty2',300,143),@('jor_maze',15,52))) {
	$info = Get-MapInfo $path $c[0]
	$ok = Test-Walkable $info.Cells $info.Xs $info.Ys $c[1] $c[2]
	Write-Output ("  {0} {1},{2} = {3}" -f $c[0], $c[1], $c[2], $ok)
}
