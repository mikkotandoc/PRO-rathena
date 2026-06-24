# Download job sprite PNGs for the wiki job tree (server-side fetch).
$ErrorActionPreference = 'Continue'

$dest = Join-Path $PSScriptRoot '..\assets\images\jobs'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$ids = @(
	0,1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19,20,23,24,25,
	4008,4009,4010,4011,4012,4013,4014,4015,4016,4017,4019,4020,4021,
	4046,4047,4049,4054,4055,4056,4057,4058,4059,4066,4067,4068,4069,4070,4071,4072,
	4211,4212,4215,4218,4239,4240,4252,4253,4254,4255,4256,4257,4258,4259,4260,4261,4262,4263,4264,
	4305,4306,4307,4351,4353,4355
)

$headers = @{
	'User-Agent' = 'PRO-Ragnarok-Wiki/1.0'
	'Referer'    = 'https://www.divine-pride.net/'
	'Accept'     = 'image/png,image/*,*/*'
}

function Test-ValidImage([byte[]]$bytes) {
	if ($null -eq $bytes -or $bytes.Length -lt 400) { return $false }
	$head = [System.Text.Encoding]::ASCII.GetString($bytes[0..([Math]::Min(11, $bytes.Length - 1))])
	if ($head.StartsWith('<!DOCTYPE') -or $head.StartsWith('<html')) { return $false }
	if ([System.Text.Encoding]::ASCII.GetString($bytes).Contains('CPakEx')) { return $false }
	# PNG
	if ($bytes.Length -ge 8 -and $bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50 -and $bytes[2] -eq 0x4E -and $bytes[3] -eq 0x47) { return $true }
	# GIF
	if ($bytes.Length -ge 6 -and $bytes[0] -eq 0x47 -and $bytes[1] -eq 0x49 -and $bytes[2] -eq 0x46) { return $true }
	# JPEG
	if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8 -and $bytes[2] -eq 0xFF) { return $true }
	return $false
}

function Get-ImageExtension([byte[]]$bytes) {
	if ($bytes.Length -ge 8 -and $bytes[0] -eq 0x89 -and $bytes[1] -eq 0x50) { return 'png' }
	if ($bytes.Length -ge 6 -and $bytes[0] -eq 0x47 -and $bytes[1] -eq 0x49) { return 'gif' }
	if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xD8) { return 'jpg' }
	return 'png'
}

$ok = 0
$skip = 0
$fail = 0

Write-Host "Fetching $($ids.Count) job sprites into $dest"
Write-Host ''

foreach ($id in $ids) {
	$existing = Get-ChildItem -Path $dest -Filter "$id.*" -ErrorAction SilentlyContinue |
		Where-Object { $_.Length -gt 400 } |
		Select-Object -First 1

	if ($existing) {
		Write-Host "[skip] $id ($($existing.Name), $($existing.Length) bytes)"
		$skip++
		continue
	}

	$sources = @(
		"https://static.divine-pride.net/images/jobs/png/$id.png",
		"https://www.divine-pride.net/images/jobs/png/$id.png",
		"https://static.divine-pride.net/images/jobs/$id.png"
	)

	$downloaded = $false
	foreach ($url in $sources) {
		try {
			$response = Invoke-WebRequest -Uri $url -Headers $headers -TimeoutSec 15 -UseBasicParsing
			$bytes = $response.Content
			if ($bytes -is [string]) {
				$bytes = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetBytes($bytes)
			}
			if (-not (Test-ValidImage $bytes)) {
				continue
			}
			$ext = Get-ImageExtension $bytes
			$out = Join-Path $dest "$id.$ext"
			[System.IO.File]::WriteAllBytes($out, $bytes)
			Write-Host "[ok]   $id -> $out ($($bytes.Length) bytes)"
			$ok++
			$downloaded = $true
			break
		}
		catch {
			continue
		}
	}

	if (-not $downloaded) {
		Write-Host "[fail] $id"
		$fail++
	}

	Start-Sleep -Milliseconds 150
}

Write-Host ''
Write-Host "Done. downloaded=$ok skipped=$skip failed=$fail"
if ($fail -gt 0) { exit 1 }
