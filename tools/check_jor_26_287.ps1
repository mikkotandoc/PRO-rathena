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
$path = 'C:\Users\Mikko Tandoc\Documents\GitHub\PRO-rathena\db\map_cache.dat'
foreach ($m in @('jor_root2','jor_back2','jor_root3')) {
	$info = Get-MapInfo $path $m
	foreach ($c in @(@(26,287),@(26,284),@(26,290),@(215,244),@(215,238),@(330,14),@(330,20))) {
		Write-Output ("{0,-10} {1,3},{2,3} walkable={3}" -f $m, $c[0], $c[1], (TW $info.Cells $info.Xs $info.Ys $c[0] $c[1]))
	}
	Write-Output ''
}
