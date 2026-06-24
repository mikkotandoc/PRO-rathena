# Generates placeholder PNG job sprites (72x72) for every ID used in the wiki job tree.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$dest = Join-Path $PSScriptRoot '..\assets\images\jobs'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$ids = @(
	0,1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19,20,23,24,25,
	4008,4009,4010,4011,4012,4013,4014,4015,4016,4017,4019,4020,4021,
	4046,4047,4049,4054,4055,4056,4057,4058,4059,4066,4067,4068,4069,4070,4071,4072,
	4211,4212,4215,4218,4239,4240,4252,4253,4254,4255,4256,4257,4258,4259,4260,4261,4262,4263,4264,
	4305,4306,4307,4351,4353,4355
)

function Get-JobTint([int]$id) {
	$h = ($id * 37) % 360
	return [System.Drawing.Color]::FromArgb(60 + ($id % 40), 80 + (($id * 3) % 50), 100 + (($id * 7) % 60))
}

foreach ($id in $ids) {
	$out = Join-Path $dest "$id.png"
	if ((Test-Path $out) -and ((Get-Item $out).Length -gt 2000)) {
		Write-Host "skip $id (exists)"
		continue
	}

	$bmp = New-Object System.Drawing.Bitmap 72, 72, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
	$g = [System.Drawing.Graphics]::FromImage($bmp)
	$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
	$g.Clear([System.Drawing.Color]::FromArgb(28, 37, 48))

	$accent = Get-JobTint $id
	$brush = New-Object System.Drawing.SolidBrush $accent
	$g.FillEllipse($brush, 10, 8, 52, 52)
	$brush.Dispose()

	$pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(201, 162, 39)), 2
	$g.DrawRectangle($pen, 1, 1, 69, 69)
	$pen.Dispose()

	$font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
	$text = [string]$id
	$size = $g.MeasureString($text, $font)
	$g.DrawString($text, $font, [System.Drawing.Brushes]::White, (72 - $size.Width) / 2, (72 - $size.Height) / 2 - 2)
	$font.Dispose()

	$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
	$g.Dispose()
	$bmp.Dispose()
	Write-Host "wrote $out"
}

Write-Host "Done."
