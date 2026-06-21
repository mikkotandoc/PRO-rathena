$ErrorActionPreference = 'Stop'
$reFile = Join-Path $PSScriptRoot '..\db\re\map_drops.yml'
$importFile = Join-Path $PSScriptRoot '..\db\import\map_drops.yml'
$re = Get-Content $reFile -Raw
$import = if (Test-Path $importFile) { Get-Content $importFile -Raw } else { '' }

$targets = @(
	'pay_d03_i','gef_d01_i','ice_d03_i','tur_d03_i','tur_d04_i','tur_d04ia','tur_d04ib',
	'ein_d02_i','com_d02_i','iz_d04_i','iz_d05_i','prt_mz03_i','ant_d02_i',
	'oz_dun01','oz_dun02','gw_fild01','gw_fild02','ra_fild10','ra_fild11','ra_fild12','ra_fild13',
	'amicitia1','amicitia2','sp_rudus','sp_rudus2','sp_rudus3','sp_rudus4',
	'nif_dun01','nif_dun02','abyss_01','abyss_02','abyss_03','abyss_04','ein_dun03','clock_01',
	'jor_tail','jor_back1','jor_back2','jor_back3','jor_back4','jor_back5','jor_back6',
	'jor_nest','jor_dun01','jor_dun02','jor_dun03','jor_ab01','jor_ab02','jor_que',
	'jor_maze','jor_root1','jor_root2','jor_root3','jor_safty1','jor_safty2','jor_sanct',
	'jor_twice','jor_twig','jor_albe','jor_base','jor_crk','jor_crk_p','jor_mbase',
	'jor_raise1','jor_raise2','jor_tmple1','jor_tmple2','jor_sklf1','jor_sklf2'
)
$biosphere = @('bl_grass','bl_lava','bl_ice','bl_death','bl_soul','bl_temple','bl_venom','bl_depth1','bl_depth2')
$remove = @('orcsdun01','orcsdun02','pay_dun00','pay_dun01','pay_dun02','pay_dun03','pay_dun04')

$bad = @()
foreach ($m in $targets) {
	if ($re -notmatch "(?ms)- Map: $m\b.*?Item: Play_RO_Gold_Coin_.*?Rate: 6000") {
		$bad += "re wrong/missing: $m"
	}
}
foreach ($m in $biosphere) {
	if ($import -notmatch "(?ms)- Map: $m\b.*?Item: Play_RO_Gold_Coin_.*?Rate: 6000") {
		$bad += "import wrong/missing: $m"
	}
}
foreach ($m in $remove) {
	if ($re -match "(?m)- Map: $m\b") { $bad += "re still has: $m" }
}

if ($bad.Count -eq 0) {
	Write-Host "OK: all $($targets.Count) re targets + $($biosphere.Count) biosphere maps at 6%; removed maps absent."
} else {
	$bad | ForEach-Object { Write-Host $_ }
	exit 1
}
