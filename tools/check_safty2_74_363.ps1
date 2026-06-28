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
$m = Get-MapInfo $path 'jor_safty2'
Write-Output "jor_safty2: $($m.Xs)x$($m.Ys)"
Write-Output ''
Write-Output 'Current + user coords walkability:'
foreach ($c in @(@(77,360),@(81,359),@(81,362),@(74,363),@(77,362),@(77,359),@(81,362),@(75,361),@(73,363),@(74,362))) {
	Write-Output ("  {0,3},{1,3} = {2}" -f $c[0], $c[1], (TW $m.Cells $m.Xs $m.Ys $c[0] $c[1]))
}
Write-Output ''
Write-Output 'Walkable near 74,363 (x=68..85, y=355..370):'
for ($y = 355; $y -le 370; $y++) {
	$row = @()
	for ($x = 68; $x -le 85; $x++) {
		if (TW $m.Cells $m.Xs $m.Ys $x $y) { $row += $x }
	}
	if ($row.Count -gt 0) { Write-Output ("  y={0,3}: {1}" -f $y, ($row -join ',')) }
}
