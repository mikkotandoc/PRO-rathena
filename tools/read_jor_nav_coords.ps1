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
			return [PSCustomObject]@{ Cells = $msOut.ToArray(); Xs = $xs; Ys = $ys }
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
foreach ($c in @(@('jor_root2',200,150),@('jor_root1',276,82),@('jor_root2',239,243))) {
	$m = Get-MapInfo $path $c[0]
	Write-Output ("{0} {1},{2} = {3}" -f $c[0], $c[1], $c[2], (Test-Walkable $m.Cells $m.Xs $m.Ys $c[1] $c[2]))
}
