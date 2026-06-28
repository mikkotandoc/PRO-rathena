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
function Near-Walkable($Path, $Map, $X, $Y) {
	$m = Get-MapInfo $Path $Map
	for ($r = 0; $r -le 30; $r++) {
		for ($dx = -$r; $dx -le $r; $dx++) {
			for ($dy = -$r; $dy -le $r; $dy++) {
				$nx = $X + $dx; $ny = $Y + $dy
				if (Test-Walkable $m.Cells $m.Xs $m.Ys $nx $ny) { return "$nx,$ny" }
			}
		}
	}
}
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$path = Join-Path $root 'db\map_cache.dat'
Write-Output ("root1 hunt near 276,82 -> {0}" -f (Near-Walkable $path 'jor_root1' 276 82))
Write-Output ("root2 hunt near 200,150 -> {0}" -f (Near-Walkable $path 'jor_root2' 200 150))
Write-Output ("root1 portal near 201,259 -> {0}" -f (Near-Walkable $path 'jor_root1' 201 259))
