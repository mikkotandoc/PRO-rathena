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

$checks = @(
	@('jor_root2', 239, 243), @('jor_root2', 239, 238), @('jor_root2', 235, 241),
	@('jor_root2', 35, 10), @('jor_root2', 35, 7), @('jor_root2', 215, 244), @('jor_root2', 215, 238),
	@('jor_safty2', 77, 362), @('jor_safty2', 77, 357)
)

Write-Output 'Warp coordinate walkability:'
foreach ($c in $checks) {
	$info = Get-MapInfo $path $c[0]
	$ok = Test-Walkable $info.Cells $info.Xs $info.Ys $c[1] $c[2]
	Write-Output ("  {0,-12} {1,3},{2,3} walkable={3}" -f $c[0], $c[1], $c[2], $ok)
}

Write-Output ''
Write-Output 'Walkable near jor_root2 (225..245, 235..250):'
$r2 = Get-MapInfo $path 'jor_root2'
for ($y = 235; $y -le 250; $y++) {
	$row = @()
	for ($x = 225; $x -le 245; $x++) {
		if (Test-Walkable $r2.Cells $r2.Xs $r2.Ys $x $y) { $row += $x }
	}
	if ($row.Count -gt 0) { Write-Output ("  y={0,3}: {1}" -f $y, ($row -join ',')) }
}

Write-Output ''
Write-Output 'Best safty2 portal spot near 235,241 (search radius):'
$best = $null; $bestD = 9999
for ($y = 230; $y -le 250; $y++) {
	for ($x = 225; $x -le 245; $x++) {
		if (-not (Test-Walkable $r2.Cells $r2.Xs $r2.Ys $x $y)) { continue }
		$d = [Math]::Abs($x - 235) + [Math]::Abs($y - 241)
		if ($d -lt $bestD) { $bestD = $d; $best = "$x,$y" }
	}
}
Write-Output "  portal: $best"

Write-Output ''
Write-Output 'jor_safty2 walkable near 77,357-362:'
$s2 = Get-MapInfo $path 'jor_safty2'
for ($y = 350; $y -le 370; $y++) {
	$row = @()
	for ($x = 70; $x -le 85; $x++) {
		if (Test-Walkable $s2.Cells $s2.Xs $s2.Ys $x $y) { $row += $x }
	}
	if ($row.Count -gt 0) { Write-Output ("  y={0,3}: {1}" -f $y, ($row -join ',')) }
}
