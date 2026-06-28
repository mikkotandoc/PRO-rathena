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
function Cell-Type($Cells, $Xs, $Ys, $X, $Y) {
	if ($X -lt 0 -or $Y -lt 0 -or $X -ge $Xs -or $Y -ge $Ys) { return 'OOB' }
	return $Cells[($Y * $Xs) + $X]
}

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$path = Join-Path $root 'db\map_cache.dat'
$s2 = Get-MapInfo $path 'jor_safty2'
Write-Output "jor_safty2 size: $($s2.Xs)x$($s2.Ys)"
Write-Output 'Cell types at safty2 landing area (77,358-365):'
for ($y = 358; $y -le 365; $y++) {
	$row = @()
	for ($x = 74; $x -le 80; $x++) {
		$row += ("{0}:{1}" -f $x, (Cell-Type $s2.Cells $s2.Xs $s2.Ys $x $y))
	}
	Write-Output ("  y={0} {1}" -f $y, ($row -join ' '))
}

Write-Output ''
Write-Output 'jor_root2 return candidates near branch:'
$r2 = Get-MapInfo $path 'jor_root2'
foreach ($c in @(@(235,241),@(236,241),@(234,241),@(232,241),@(235,240),@(239,238))) {
	Write-Output ("  {0},{1} walkable={2} cell={3}" -f $c[0], $c[1], (Test-Walkable $r2.Cells $r2.Xs $r2.Ys $c[0] $c[1]), (Cell-Type $r2.Cells $r2.Xs $r2.Ys $c[0] $c[1]))
}
