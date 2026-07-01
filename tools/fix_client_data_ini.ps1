# Deploys quest/client helpers. Does NOT switch to data_fixed.grf (use original DATA.INI).
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea",
	[string]$SourceRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia - Copy"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ClientRoot)) {
	throw "Client folder not found: $ClientRoot"
}

foreach ($name in @("data_fixed.grf", "proasia_fixed.grf")) {
	$path = Join-Path $ClientRoot $name
	if (Test-Path $path) {
		$item = Get-Item -LiteralPath $path
		if ($item.LinkType -ne "") {
			Remove-Item -LiteralPath $path -Force
			Write-Host "Removed hardlink $name"
		}
	}
}

$launcher = "2026-02-19_Ragexe_1770960005_patched.exe"
$bat = "Start PRO Asia.bat"
foreach ($name in @($launcher, $bat)) {
	$dst = Join-Path $ClientRoot $name
	if (Test-Path $dst) { continue }
	$src = Join-Path $SourceRoot $name
	if (-not (Test-Path $src)) { continue }
	if ($name -like "*.exe") {
		cmd /c mklink /H "`"$dst`"" "`"$src`""
		if ($LASTEXITCODE -ne 0) { Copy-Item -LiteralPath $src -Destination $dst }
	} else {
		Copy-Item -LiteralPath $src -Destination $dst
	}
}

& (Join-Path $PSScriptRoot "deploy_questinfo_client_patch.ps1") -ClientRoot $ClientRoot
& (Join-Path $PSScriptRoot "deploy_druid_client_patch.ps1") -ClientRoot $ClientRoot

Write-Host "Quest + Druid patches deployed. Keep your original DATA.INI / GRF set."
