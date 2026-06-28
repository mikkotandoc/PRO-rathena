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
function TW($C, $Xs, $Ys, $X, $Y) {
	if ($X -lt 0 -or $Y -lt 0 -or $X -ge $Xs -or $Y -ge $Ys) { return $false }
	return ($C[($Y * $Xs) + $X] -in 0,2,3,4,6)
}
function InSpan($wx, $wy, $sx, $sy, $x, $y) {
	return ($x -ge ($wx - $sx) -and $x -le ($wx + $sx) -and $y -ge ($wy - $sy) -and $y -le ($wy + $sy))
}
$path = 'C:\Users\Mikko Tandoc\Documents\GitHub\PRO-rathena\db\map_cache.dat'
$s2 = Get-MapInfo $path 'jor_safty2'
$r2 = Get-MapInfo $path 'jor_root2'
Write-Output 'Walkable:'
Write-Output ("  safty2 74,365 = {0}" -f (TW $s2.Cells $s2.Xs $s2.Ys 74 365))
Write-Output ("  root2 235,238 = {0}" -f (TW $r2.Cells $r2.Xs $r2.Ys 235 238))
Write-Output ''
Write-Output 'Landing inside return warp span (should be False):'
Write-Output ("  74,365 in safty2 portal 74,361 span 2,2 = {0}" -f (InSpan 74 361 2 2 74 365))
Write-Output ''
Write-Output 'root2 landing candidates (portal 235,241 span 2,2):'
$r2 = Get-MapInfo $path 'jor_root2'
foreach ($c in @(@(232,241),@(231,241),@(238,241),@(235,245),@(235,236),@(228,241),@(240,241))) {
	Write-Output ("  {0},{1} walk={2} inSpan={3}" -f $c[0], $c[1], (TW $r2.Cells $r2.Xs $r2.Ys $c[0] $c[1]), (InSpan 235 241 2 2 $c[0] $c[1]))
}
