# Scan-RunePacketsDeep.ps1
#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$out = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'GitHub\PRO-rathena\tools\_scan_rune_packets_deep.txt'
$log = New-Object System.Text.StringBuilder
function L([string]$m) { [void]$log.AppendLine($m); Write-Host $m }
L('RUNE Packet Deep Scan ' + [datetime]::Now.ToString('o'))
L('')
