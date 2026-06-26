# Deploys quest tracker .lub overrides into client data/ (replaces GRF questinfo scripts).
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea"
)

$ErrorActionPreference = "Stop"
$ongoing = Join-Path $ClientRoot "SystemEN\OngoingQuests.lub"
$targetDir = Join-Path $ClientRoot "data\luafiles514\lua files\datainfo"

if (-not (Test-Path $ongoing)) { throw "Missing $ongoing" }

New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item -LiteralPath $ongoing -Destination (Join-Path $targetDir "questinfo.lub") -Force
Copy-Item -LiteralPath $ongoing -Destination (Join-Path $targetDir "questinfo_f.lub") -Force

Write-Host "Deployed questinfo.lub + questinfo_f.lub to $targetDir"
