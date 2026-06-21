# Generate readable 220x90 captcha BMPs (white text on black, no noise).
# Matches tools/gen_captcha_bmp.js — CAPTCHA_BMP_SIZE = 59454.
$ErrorActionPreference = 'Stop'

$Width = 220
$Height = 90
$TextScale = 6
$CaptchaBmpSize = 2 + 52 + (3 * $Width * $Height)

$Font = @{
	'A' = @('01110','10001','10001','11111','10001','10001','10001')
	'B' = @('11110','10001','10001','11110','10001','10001','11110')
	'C' = @('01111','10000','10000','10000','10000','10000','01111')
	'D' = @('11110','10001','10001','10001','10001','10001','11110')
	'E' = @('11111','10000','10000','11110','10000','10000','11111')
	'F' = @('11111','10000','10000','11110','10000','10000','10000')
	'G' = @('01111','10000','10000','10011','10001','10001','01111')
	'H' = @('10001','10001','10001','11111','10001','10001','10001')
	'I' = @('11111','00100','00100','00100','00100','00100','11111')
	'J' = @('00111','00010','00010','00010','00010','10010','01100')
	'K' = @('10001','10010','10100','11000','10100','10010','10001')
	'L' = @('10000','10000','10000','10000','10000','10000','11111')
	'M' = @('10001','11011','10101','10001','10001','10001','10001')
	'N' = @('10001','11001','10101','10011','10001','10001','10001')
	'O' = @('01110','10001','10001','10001','10001','10001','01110')
	'P' = @('11110','10001','10001','11110','10000','10000','10000')
	'R' = @('11110','10001','10001','11110','10100','10010','10001')
	'S' = @('01111','10000','10000','01110','00001','00001','11110')
	'T' = @('11111','00100','00100','00100','00100','00100','00100')
	'U' = @('10001','10001','10001','10001','10001','10001','01110')
	'V' = @('10001','10001','10001','10001','10001','01010','00100')
	'W' = @('10001','10001','10001','10001','10101','11011','10001')
	'X' = @('10001','10001','01010','00100','01010','10001','10001')
	'Y' = @('10001','10001','01010','00100','00100','00100','00100')
	'Z' = @('11111','00001','00010','00100','01000','10000','11111')
	'0' = @('01110','10001','10001','10001','10001','10001','01110')
	'1' = @('00100','01100','00100','00100','00100','00100','01110')
	'2' = @('01110','10001','00001','00010','00100','01000','11111')
	'3' = @('11110','00001','00001','01110','00001','00001','11110')
	'4' = @('00010','00110','01010','10010','11111','00010','00010')
	'5' = @('11111','10000','10000','11110','00001','00001','11110')
	'6' = @('01111','10000','10000','11111','10001','10001','01110')
	'7' = @('11111','00001','00010','00100','01000','01000','01000')
	'8' = @('01110','10001','10001','01110','10001','10001','01110')
	'9' = @('01110','10001','10001','01111','00001','00001','01110')
}

$Captchas = @(
	@('captcha_01.bmp', 'WOLF'),
	@('captcha_02.bmp', 'BEAR'),
	@('captcha_03.bmp', 'FIRE'),
	@('captcha_04.bmp', 'WIND'),
	@('captcha_05.bmp', 'GOLD'),
	@('captcha_06.bmp', 'MOON'),
	@('captcha_07.bmp', 'STAR'),
	@('captcha_08.bmp', 'HERO'),
	@('captcha_09.bmp', 'KING'),
	@('captcha_10.bmp', 'ROSE')
)

function Set-Pixel {
	param([byte[]]$Pixels, [int]$X, [int]$Y, [byte]$B, [byte]$G, [byte]$R)
	if ($X -lt 0 -or $X -ge $Width -or $Y -lt 0 -or $Y -ge $Height) { return }
	$idx = (($Height - 1 - $Y) * $Width + $X) * 3
	$Pixels[$idx] = $B
	$Pixels[$idx + 1] = $G
	$Pixels[$idx + 2] = $R
}

function Fill-Rect {
	param([byte[]]$Pixels, [int]$X0, [int]$Y0, [int]$X1, [int]$Y1, [byte]$B, [byte]$G, [byte]$R)
	for ($y = $Y0; $y -le $Y1; $y++) {
		for ($x = $X0; $x -le $X1; $x++) {
			Set-Pixel -Pixels $Pixels -X $x -Y $y -B $B -G $G -R $R
		}
	}
}

function Draw-Text {
	param([byte[]]$Pixels, [string]$Text, [int]$Scale = $TextScale)
	$upper = $Text.ToUpperInvariant()
	$charW = 5 * $Scale + $Scale
	$totalW = $upper.Length * $charW - $Scale
	$startX = [Math]::Max(4, [int](($Width - $totalW) / 2))
	$startY = [int](($Height - 7 * $Scale) / 2)

	for ($ci = 0; $ci -lt $upper.Length; $ci++) {
		$key = [string]$upper[$ci]
		if (-not $Font.ContainsKey($key)) { continue }
		$glyph = $Font[$key]
		$ox = $startX + $ci * $charW
		for ($row = 0; $row -lt $glyph.Length; $row++) {
			for ($col = 0; $col -lt $glyph[$row].Length; $col++) {
				if ($glyph[$row][$col] -ne '1') { continue }
				for ($dy = 0; $dy -lt $Scale; $dy++) {
					for ($dx = 0; $dx -lt $Scale; $dx++) {
						Set-Pixel -Pixels $Pixels -X ($ox + $col * $Scale + $dx) -Y ($startY + $row * $Scale + $dy) -B 255 -G 255 -R 255
					}
				}
				for ($dy = 0; $dy -lt $Scale; $dy++) {
					Set-Pixel -Pixels $Pixels -X ($ox + $col * $Scale + $Scale) -Y ($startY + $row * $Scale + $dy) -B 255 -G 255 -R 255
				}
				for ($dx = 0; $dx -le $Scale; $dx++) {
					Set-Pixel -Pixels $Pixels -X ($ox + $col * $Scale + $dx) -Y ($startY + $row * $Scale + $Scale) -B 255 -G 255 -R 255
				}
			}
		}
	}
}

function New-CaptchaBmp {
	param([string]$Text)
	$pixels = New-Object byte[] ($Width * $Height * 3)

	Fill-Rect -Pixels $pixels -X0 0 -Y0 0 -X1 ($Width - 1) -Y1 ($Height - 1) -B 0 -G 0 -R 0
	Fill-Rect -Pixels $pixels -X0 2 -Y0 2 -X1 ($Width - 3) -Y1 ($Height - 3) -B 20 -G 20 -R 20
	Fill-Rect -Pixels $pixels -X0 4 -Y0 4 -X1 ($Width - 5) -Y1 ($Height - 5) -B 0 -G 0 -R 0

	Draw-Text -Pixels $pixels -Text $Text

	$ms = New-Object System.IO.MemoryStream
	$bw = New-Object System.IO.BinaryWriter $ms
	$bw.Write([byte[]]@(0x42, 0x4D))
	$bw.Write([int32]$CaptchaBmpSize)
	$bw.Write([int32]0)
	$bw.Write([int32]54)
	$bw.Write([int32]40)
	$bw.Write([int32]$Width)
	$bw.Write([int32]$Height)
	$bw.Write([int16]1)
	$bw.Write([int16]24)
	$bw.Write([int32]0)
	$bw.Write([int32]$pixels.Length)
	$bw.Write([int32]2835)
	$bw.Write([int32]2835)
	$bw.Write([int32]0)
	$bw.Write([int32]0)
	$bw.Write($pixels)
	$bytes = $ms.ToArray()
	$bw.Close()
	$ms.Close()

	if ($bytes.Length -ne $CaptchaBmpSize) {
		throw "Invalid BMP size $($bytes.Length), expected $CaptchaBmpSize"
	}
	return $bytes
}

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$outDir = Join-Path $root 'db\import\captcha'
if (-not (Test-Path $outDir)) {
	New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

foreach ($entry in $Captchas) {
	$file = $entry[0]
	$answer = $entry[1]
	$path = Join-Path $outDir $file
	[System.IO.File]::WriteAllBytes($path, (New-CaptchaBmp -Text $answer))
	Write-Host "Wrote $file ($answer)"
}

Write-Host "Done."
