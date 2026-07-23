# Deploys custom item icon BMPs for Legend Hunt materials (1000700 / 1000701).
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia - Copy"
)

$ErrorActionPreference = "Stop"

function Get-UiInterfaceFolder {
	# Korean folder name: 유저인터페이스
	[Text.Encoding]::GetEncoding(949).GetString([byte[]](0xC0, 0xAF, 0xC0, 0xDA, 0xC0, 0xCE, 0xC5, 0xCD, 0xC6, 0xE4, 0xC0, 0xCC, 0xBD, 0xBA))
}

function New-ItemIconBmp {
	param(
		[string]$Path,
		[int]$Width = 24,
		[int]$Height = 24,
		[scriptblock]$DrawPixel
	)

	$rowSize = [int][Math]::Ceiling(($Width * 3) / 4) * 4
	$pixelBytes = $rowSize * $Height
	$fileSize = 54 + $pixelBytes

	$ms = New-Object System.IO.MemoryStream
	$bw = New-Object System.IO.BinaryWriter($ms)
	$bw.Write([byte[]]@(0x42, 0x4D))
	$bw.Write([int32]$fileSize)
	$bw.Write([int32]0)
	$bw.Write([int32]54)
	$bw.Write([int32]40)
	$bw.Write([int32]$Width)
	$bw.Write([int32]$Height)
	$bw.Write([int16]1)
	$bw.Write([int16]24)
	$bw.Write([int32]0)
	$bw.Write([int32]$pixelBytes)
	$bw.Write([int32]0)
	$bw.Write([int32]0)
	$bw.Write([int32]0)
	$bw.Write([int32]0)

	for ($y = 0; $y -lt $Height; $y++) {
		for ($x = 0; $x -lt $Width; $x++) {
			$b = 0; $g = 0; $r = 0
			& $DrawPixel $x $y ([ref]$b) ([ref]$g) ([ref]$r)
			$bw.Write([byte]$b)
			$bw.Write([byte]$g)
			$bw.Write([byte]$r)
		}
		for ($p = 0; $p -lt ($rowSize - ($Width * 3)); $p++) { $bw.Write([byte]0) }
	}

	$dir = Split-Path -Path $Path -Parent
	if (-not (Test-Path -LiteralPath $dir)) {
		New-Item -ItemType Directory -Force -Path $dir | Out-Null
	}

	$bw.Flush()
	[System.IO.File]::WriteAllBytes($Path, $ms.ToArray())
	$bw.Close()
	$ms.Close()
}

function Set-Color {
	param([ref]$B, [ref]$G, [ref]$R, [int]$BVal, [int]$GVal, [int]$RVal)
	$B.Value = [byte]$BVal
	$G.Value = [byte]$GVal
	$R.Value = [byte]$RVal
}

function Draw-LegendHuntScrap {
	param([int]$X, [int]$Y, [ref]$B, [ref]$G, [ref]$R)

	# Dark slate background
	Set-Color -B $B -G $G -R $R -BVal 28 -GVal 30 -RVal 36

	$cx = 11.5
	$cy = 12.0
	$dx = $X - $cx
	$dy = $Y - $cy

	# Jagged bronze shard
	$shard = ($X -ge 8 -and $X -le 16 -and $Y -ge 5 -and $Y -le 19)
	if ($shard) {
		$edge = ($X -eq 8 -or $X -eq 16 -or $Y -eq 5 -or ($Y -eq 19 -and $X -ge 10))
		$highlight = ($X -ge 12 -and $Y -le 10)
		if ($edge) {
			Set-Color -B $B -G $G -R $R -BVal 70 -GVal 95 -RVal 170
		} elseif ($highlight) {
			Set-Color -B $B -G $G -R $R -BVal 120 -GVal 170 -RVal 255
		} else {
			Set-Color -B $B -G $G -R $R -BVal 85 -GVal 120 -RVal 210
		}
	}

	# Small crack detail
	if (($X -eq 10 -or $X -eq 13) -and $Y -ge 11 -and $Y -le 16) {
		Set-Color -B $B -G $G -R $R -BVal 45 -GVal 55 -RVal 90
	}

	# Corner spark
	if (($X -eq 14 -and $Y -eq 7) -or ($X -eq 15 -and $Y -eq 8)) {
		Set-Color -B $B -G $G -R $R -BVal 180 -GVal 220 -RVal 255
	}
}

function Draw-LegendHuntCore {
	param([int]$X, [int]$Y, [ref]$B, [ref]$G, [ref]$R)

	# Deep indigo background
	Set-Color -B $B -G $G -R $R -BVal 18 -GVal 12 -RVal 42

	$cx = 11.5
	$cy = 12.0
	$dist = [Math]::Sqrt(($X - $cx) * ($X - $cx) + ($Y - $cy) * ($Y - $cy))

	# Outer glow ring
	if ($dist -le 9.2 -and $dist -ge 7.4) {
		Set-Color -B $B -G $G -R $R -BVal 120 -GVal 60 -RVal 220
	}

	# Mid orb
	if ($dist -le 7.2) {
		Set-Color -B $B -G $G -R $R -BVal 180 -GVal 90 -RVal 255
	}

	# Bright core
	if ($dist -le 4.0) {
		Set-Color -B $B -G $G -R $R -BVal 240 -GVal 180 -RVal 255
	}

	# Center highlight
	if ($dist -le 1.8) {
		Set-Color -B $B -G $G -R $R -BVal 255 -GVal 255 -RVal 255
	}

	# Orbiting motes
	if (($X -eq 5 -and $Y -eq 8) -or ($X -eq 18 -and $Y -eq 9) -or ($X -eq 7 -and $Y -eq 17)) {
		Set-Color -B $B -G $G -R $R -BVal 200 -GVal 140 -RVal 255
	}
}

$dataDir = Join-Path $ClientRoot "data"
$uiFolder = Get-UiInterfaceFolder
$itemDir = Join-Path (Join-Path (Join-Path $dataDir "texture") $uiFolder) "item"
$collectionDir = Join-Path $itemDir "collection"

$targets = @(
	@{ Name = "Legend_Hunt_Scrap"; Draw = ${function:Draw-LegendHuntScrap} },
	@{ Name = "Legend_Hunt_Core"; Draw = ${function:Draw-LegendHuntCore} }
)

foreach ($target in $targets) {
	$itemPath = Join-Path $itemDir "$($target.Name).bmp"
	$collectionPath = Join-Path $collectionDir "$($target.Name).bmp"
	New-ItemIconBmp -Path $itemPath -DrawPixel $target.Draw
	New-ItemIconBmp -Path $collectionPath -DrawPixel $target.Draw
	Write-Host "Wrote $($target.Name).bmp -> item + collection"
}

Write-Host "Legend Hunt item sprites deployed to $itemDir"
