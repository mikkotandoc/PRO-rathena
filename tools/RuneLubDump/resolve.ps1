$ErrorActionPreference = "Stop"
$dir = "C:\Users\Mikko Tandoc\Documents\GitHub\PRO-rathena\tools\RuneLubDump"
$settbl = (Get-Content (Join-Path $dir _settbl.json) -Raw | ConvertFrom-Json).RuneSettbl_info
$table  = (Get-Content (Join-Path $dir _table.json)  -Raw | ConvertFrom-Json).RuneTable_itemList

function Mat([int]$idx) {
    $entry = $table.$("$idx")
    if ($null -eq $entry) { return "(none)" }
    ($entry | ForEach-Object { "$($_[0])x$($_[1])" }) -join ', '
}

$ep20 = $settbl.'20'
foreach ($setid in ($ep20.PSObject.Properties.Name | Sort-Object)) {
    $s = $ep20.$setid
    Write-Output "=== $setid  $($s.RuneSetRes) ==="
    Write-Output ("Slots: " + (($s.RuneSet_SlotList) -join ', '))
    Write-Output ("Activation[$($s.RuneSetActiveList)]: " + (Mat ([int]$s.RuneSetActiveList)))
    Write-Output ("ChanceProfile: succ=$($s.RuneSet_UpGrade_Percentage_table) fail=$($s.RuneSet_UpGrade_Percentage_table_Fail)")
    $g = 1
    foreach ($ui in $s.RuneSet_UpGradeList) {
        Write-Output ("  +$g mats[$ui]: " + (Mat ([int]$ui)))
        $g++
    }
}
