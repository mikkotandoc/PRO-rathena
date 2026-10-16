#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$solution = Join-Path $RepoRoot 'AetherOnline.sln'

& dotnet test $solution -c Debug --nologo
exit $LASTEXITCODE
