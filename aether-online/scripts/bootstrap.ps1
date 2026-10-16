#Requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $RepoRoot

function Get-PinnedValue {
    param([Parameter(Mandatory = $true)][string] $Name)

    $path = Join-Path $RepoRoot 'VERSIONS'
    foreach ($line in Get-Content -LiteralPath $path) {
        $trimmed = $line.Trim()
        if ($trimmed.Length -eq 0 -or $trimmed.StartsWith('#')) {
            continue
        }

        $separator = $trimmed.IndexOf('=')
        if ($separator -lt 1) {
            continue
        }

        $key = $trimmed.Substring(0, $separator).Trim()
        if ($key -eq $Name) {
            return $trimmed.Substring($separator + 1).Trim()
        }
    }

    throw "VERSIONS does not define $Name."
}

$expectedSdk = Get-PinnedValue 'dotnet_sdk'
$expectedGodot = Get-PinnedValue 'godot_version'

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw "dotnet is not on PATH. Install .NET SDK $expectedSdk (see README.md)."
}

$actualSdk = (& dotnet --version).Trim()
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

if ($actualSdk -ne $expectedSdk) {
    throw "dotnet SDK is '$actualSdk'. This repository pins $expectedSdk and global.json sets rollForward to disable."
}

Write-Host "dotnet SDK $actualSdk"

if (-not (Get-Command godot -ErrorAction SilentlyContinue)) {
    Write-Warning "godot is not on PATH. Install Godot $expectedGodot .NET before opening the client or starting the server."
}
else {
    $godotRaw = (& godot --version 2>&1 | Out-String).Trim()
    $godotFirst = ($godotRaw -split '\r?\n' | Where-Object { $_.Trim().Length -gt 0 } | Select-Object -First 1).Trim()
    if ($godotFirst -notlike "$expectedGodot*") {
        throw "godot reports '$godotFirst'. This repository pins $expectedGodot."
    }

    Write-Host "godot $godotFirst"
}

$solution = Join-Path $RepoRoot 'AetherOnline.sln'
& dotnet restore $solution --nologo
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Bootstrap complete."
