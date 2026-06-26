# Removes broken partial card table overrides from the client data folder.
# Loose data/num2cardillustnametable.txt REPLACES the full GRF table; a partial file
# causes Gravity errors on almost every card View.
param(
	[string]$ClientRoot = "C:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea"
)

$ErrorActionPreference = "Stop"
$dataDir = Join-Path $ClientRoot "data"
$targets = @(
	"num2cardillustnametable.txt",
	"cardprefixnametable.txt",
	"cardpostfixnametable.txt",
	"carditemnametable.txt"
)

foreach ($name in $targets) {
	$path = Join-Path $dataDir $name
	if (Test-Path $path) {
		Remove-Item -LiteralPath $path -Force
		Write-Host "Removed $path"
	}
}

Write-Host "Card tables restored to GRF defaults. Restart the client fully before testing View."
