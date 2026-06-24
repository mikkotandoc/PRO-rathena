# Rebuild db/import/mob_db.yml for Varmundt Biosphere (no UTF-8 BOM)
$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not (Test-Path "$PSScriptRoot\..\db\import")) { $root = Split-Path $PSScriptRoot -Parent }
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$outFile = Join-Path $root 'db\import\mob_db.yml'
$prFile = Join-Path $env:TEMP 'mob_db_pr8115.yml'

if (-not (Test-Path $prFile)) {
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/rathena/rathena/d8408d6b4866dc4e1c350093820a54c1e08d597d/db/re/mob_db.yml' -OutFile $prFile
}

function Convert-EcoMob {
    param($m)
    $atk = [int]((($m.AtkMin + $m.AtkMax) / 2) * 0.972)
    $matk = [int]((($m.MatkMin + $m.MatkMax) / 2) * 0.918)
    $walk = [int](1000 / $m.Speed)
    $motion = [int](1000 / $m.Aspd)
    $delay = if ($m.AttackDelay) { $m.AttackDelay } else { [Math]::Max(96, [int]($motion * 0.2)) }

    $yaml = @"
  - Id: $($m.Id)
    AegisName: $($m.Aegis)
    Name: $($m.Name)
    Level: $($m.Lv)
    Hp: $($m.Hp)
    BaseExp: $($m.BaseExp)
    JobExp: $($m.JobExp)
    Attack: $atk
    Attack2: $matk
    Defense: $($m.Def)
    MagicDefense: $($m.MDef)
    Resistance: $($m.Res)
    MagicResistance: $($m.MRes)
    Str: $($m.Str)
    Agi: $($m.Agi)
    Vit: $($m.Vit)
    Int: $($m.Int)
    Dex: $($m.Dex)
    Luk: $($m.Luk)
    AttackRange: $($m.Range)
    SkillRange: 10
    ChaseRange: 12
    Size: $($m.Size)
    Race: $($m.Race)
    Element: $($m.Element)
    ElementLevel: $($m.ElemLv)
    WalkSpeed: $walk
    AttackDelay: $delay
    AttackMotion: $motion
    DamageMotion: 432
    DamageTaken: $($m.DmgTaken)
    Ai: $($m.Ai)
"@

    if ($m.Boss) {
        $yaml += "`n    Class: Boss"
        if ($m.Mvp) {
            $yaml += @"

    Modes:
      Mvp: true
    MvpDrops:
      - Item: $($m.MvpBox)
        Rate: 4000
      - Item: $($m.MvpEssence)
        Rate: 3500
      - Item: Blacksmith_Blessing
        Rate: 500
"@
        }
    }

    $yaml += "`n    Drops:"
    foreach ($drop in $m.Drops) {
        $yaml += "`n      - Item: $($drop.Item)`n        Rate: $($drop.Rate)"
    }
    return $yaml
}

# Id,Aegis,Name,Lv,Hp,BaseExp,JobExp,AtkMin,AtkMax,MatkMin,MatkMax,Def,MDef,Res,MRes,Str,Agi,Vit,Int,Dex,Luk,Range,Size,Race,Element,ElemLv,Speed,Aspd,DmgTaken,Ai,Boss,Mvp,Zone
$ecoCsv = @'
21920,ECO_RUDO,Temple Rudo,253,32534117,1360016,951537,16013,23814,9409,17054,480,512,439,679,157,169,176,238,216,238,1,Small,Angel,Holy,3,7.69,5.95,20,04,0,0,temple
21921,ECO_ARCHANGELING,Temple Arc Angeling,253,36048967,1357745,950422,18345,27283,7780,14047,703,398,667,521,216,178,206,216,216,206,1,Medium,Angel,Holy,3,6.67,1.49,20,04,0,0,temple
21922,ECO_FAKE_ANGEL,Temple False Angel,253,33216055,1360833,950205,20418,30390,7020,12661,473,260,400,324,221,260,144,185,244,227,2,Small,Angel,Holy,3,14.29,3.47,20,04,0,0,temple
21923,ECO_PLASMA_P,Temple Plasma,254,35377971,1374116,957072,24118,35903,6895,12426,808,312,794,375,293,246,233,188,261,244,1,Small,Formless,Dark,4,7.69,1.04,20,04,0,0,temple
21924,ECO_SOLACE,Temple Solace,254,35374557,1384784,964502,23587,35122,6705,12090,776,299,738,349,264,222,209,169,235,220,2,Medium,Angel,Holy,3,5.88,3.79,20,04,0,0,temple
21925,ECO_ANOPHELES,Temple Anopheles,254,36842663,1348511,943958,17582,26097,8155,14674,802,463,838,661,297,245,283,297,297,283,1,Small,Insect,Wind,3,6.67,3.47,20,04,0,0,temple
21926,ECO_GRYPHON,Temple Gryphon,255,44443635,1405103,977700,15380,22843,6349,11374,989,433,956,568,198,191,269,232,246,221,1,Large,Brute,Wind,4,5.00,2.98,20,04,0,0,temple
21927,ECO_RANDGRIS,Temple Valkyrie Randgris,260,291553526,1853337,1297336,37632,56197,16050,29377,742,423,724,568,241,199,230,241,241,230,2,Large,Angel,Holy,4,5.56,1.74,20,21,1,1,temple
21928,ECO_COMODO,Venom Comodo,253,37802826,1361942,948593,21819,32486,5918,10647,739,285,677,320,232,195,184,149,207,194,2,Medium,Brute,Poison,3,6.67,5.95,20,04,0,0,venom
21929,ECO_POISON_TOAD,Venom Poison Toad,253,36500000,1365000,950000,20000,30000,5500,10000,720,280,660,310,220,190,180,150,210,190,1,Medium,Brute,Poison,2,6.67,4.00,20,04,0,0,venom
21930,ECO_SIDE_WINDER,Venom Side Winder,253,37000000,1368000,952000,21000,31000,5800,10500,730,290,670,315,225,200,185,145,215,195,1,Medium,Brute,Poison,2,7.00,3.50,20,04,0,0,venom
21931,ECO_CRAMP,Venom Cramp,253,37200000,1370000,953000,20500,30500,5700,10200,735,292,675,318,228,198,182,148,212,192,1,Small,Brute,Poison,2,8.00,2.50,20,04,0,0,venom
21932,ECO_KUKRE,Venom Kukre,253,36000000,1360000,949000,19500,29000,5400,9800,710,275,650,305,215,185,175,140,205,185,1,Small,Insect,Poison,1,10.00,2.00,20,04,0,0,venom
21933,ECO_NEPENTHES,Venom Nepenthes,254,38000000,1375000,960000,22000,33000,6000,11000,745,295,680,325,235,205,190,155,220,200,2,Medium,Plant,Poison,3,5.00,1.20,20,04,0,0,venom
21934,ECO_ANGRA_MANTIS,Venom Angra Mantis,254,38500000,1380000,962000,23000,34000,6200,11500,750,300,685,330,240,210,195,160,225,205,1,Medium,Insect,Poison,3,6.00,2.80,20,04,0,0,venom
21935,ECO_VENOM_KIMERA,Venomous Chimera,260,318378443,1853333,1297333,35261,52654,14581,26671,711,403,670,524,216,178,206,216,216,206,1,Large,Brute,Poison,4,5.88,1.49,20,21,1,1,venom
21936,ECO_NIGHTMARE,Soul Nightmare,253,42580971,1359260,945803,15329,22767,6368,11408,991,433,963,572,200,193,272,235,249,224,1,Large,Brute,Ghost,3,6.67,2.45,20,04,0,0,soul
21937,ECO_WHISPER,Soul Whisper,253,40000000,1362000,950000,14000,21000,6000,11000,850,400,900,550,180,200,250,220,240,210,1,Medium,Demon,Ghost,3,10.00,1.96,20,04,0,0,soul
21938,ECO_MARIONETTE,Soul Marionette,253,41000000,1364000,951000,14500,21500,6100,11200,870,410,920,560,190,195,255,230,245,215,1,Medium,Demon,Ghost,3,8.00,2.20,20,04,0,0,soul
21939,ECO_NOXIOUS,Soul Noxious,254,42000000,1370000,955000,15000,22000,6200,11500,900,420,940,580,195,198,260,235,250,220,1,Medium,Demon,Ghost,2,7.00,2.00,20,04,0,0,soul
21940,ECO_THE_PAPER,Soul The Paper,254,41500000,1368000,953000,14800,21800,6150,11300,880,415,930,570,185,192,258,228,242,218,1,Medium,Demon,Ghost,3,9.00,2.50,20,04,0,0,soul
21941,ECO_GAJOMART,Soul Gajomart,254,41800000,1369000,954000,15200,22500,6300,11600,910,425,950,585,200,200,262,240,248,222,1,Medium,Demon,Ghost,2,6.50,2.30,20,04,0,0,soul
21942,ECO_ODIUM,Soul Odium,255,43000000,1400000,975000,16000,23500,6500,12000,920,430,960,590,205,205,265,245,252,225,1,Medium,Demon,Ghost,3,6.00,2.00,20,04,0,0,soul
21943,ECO_GLOOMUNDERNIGHT,Soul Gloom Under Night,260,291562787,1824690,1277280,37269,55611,17185,31414,844,489,900,712,325,268,309,325,324,309,3,Large,Formless,Ghost,3,5.56,1.39,20,21,1,1,soul
'@

$zoneDrops = @{
    temple = @(
        @{ Item = 'Feather'; Rate = 3000 },
        @{ Item = 'Fluff'; Rate = 3000 }
    )
    venom = @(
        @{ Item = 'Sticky_Mucus'; Rate = 3000 },
        @{ Item = 'Detrimindexta'; Rate = 2000 }
    )
    soul = @(
        @{ Item = 'Horseshoe'; Rate = 3500 },
        @{ Item = 'Transparent_Cloth'; Rate = 2000 }
    )
}

$zoneMvp = @{
    temple = @{ Box = 'Temple_Rune_Box5'; Essence = 'Barmund_Temple_Essence' }
    venom  = @{ Box = 'Venom_Rune_Box5'; Essence = 'Barmund_Venom_Essence' }
    soul   = @{ Box = 'Soul_Rune_Box5'; Essence = 'Barmund_Soul_Essence' }
}

$ecoYaml = New-Object System.Collections.Generic.List[string]
foreach ($line in ($ecoCsv.Trim() -split "`n")) {
    $f = ($line.Trim() -split ',').ForEach({ $_.Trim() })
    $zone = $f[31]
    $m = [ordered]@{
        Id = [int]$f[0]; Aegis = $f[1]; Name = $f[2]; Lv = [int]$f[3]; Hp = [int]$f[4]
        BaseExp = [int]$f[5]; JobExp = [int]$f[6]
        AtkMin = [int]$f[7]; AtkMax = [int]$f[8]; MatkMin = [int]$f[9]; MatkMax = [int]$f[10]
        Def = [int]$f[11]; MDef = [int]$f[12]; Res = [int]$f[13]; MRes = [int]$f[14]
        Str = [int]$f[15]; Agi = [int]$f[16]; Vit = [int]$f[17]; Int = [int]$f[18]
        Dex = [int]$f[19]; Luk = [int]$f[20]; Range = [int]$f[21]; Size = $f[22]
        Race = $f[23]; Element = $f[24]; ElemLv = [int]$f[25]
        Speed = [double]$f[26]; Aspd = [double]$f[27]; DmgTaken = [int]$f[28]; Ai = $f[29]
        Boss = ($f[30] -eq '1'); Mvp = ($f[31] -eq '1')
    }
    $zone = $f[32]
    if ($m.Mvp) {
        $m.MvpBox = $zoneMvp[$zone].Box
        $m.MvpEssence = $zoneMvp[$zone].Essence
    }
    $m.Drops = $zoneDrops[$zone]
    $ecoYaml.Add((Convert-EcoMob $m))
}

$depth1 = (Get-Content $prFile -Encoding UTF8)[114951..115718]

# Depth 2: always regenerate from tools/generate_bio_mobs.py (abyss jewels live in map_drops).
$depth2 = @()
$pyScript = Join-Path $root 'tools\generate_bio_mobs.py'
if (Test-Path $pyScript) {
	$depth2Text = & python -c @"
import sys
sys.path.insert(0, r'$root\tools')
from generate_bio_mobs import DEPTH2_KRO, render_depth2
parts = []
for mid, data in sorted(DEPTH2_KRO.items()):
    entry = dict(data)
    entry['Id'] = mid
    parts.append(render_depth2(entry))
print('\n'.join(parts))
"@
	if ($depth2Text) { $depth2 = $depth2Text -split "`n" }
}

# Preserve non-biosphere import entries (e.g. Airship Crash MD_AIRBOAT_*)
$preserveYaml = @()
$biosphereIds = 21920..21943 + 22140..22155 + 22252..22261
if (Test-Path $outFile) {
    $existing = Get-Content $outFile -Raw -Encoding UTF8
    $blocks = [regex]::Matches($existing, '(?ms)^  - Id: (\d+)\r?\n.*?(?=^  - Id: \d+\r?\n|\z)')
    foreach ($block in $blocks) {
        $id = [int]$block.Groups[1].Value
        if ($biosphereIds -notcontains $id) {
            $preserveYaml += $block.Value.TrimEnd()
        }
    }
}

$header = @'
# Custom mob import overlay
# Varmundt's Biosphere: ECO 21920-21943, Depth 1 (PR #8115), Depth 2 (kRO EP20)
# Other entries (e.g. Airship Crash) are preserved across rebuilds

Header:
  Type: MOB_DB
  Version: 5

Body:
'@

$parts = @($header) + $ecoYaml + $depth1 + $depth2 + $preserveYaml
$content = ($parts -join "`n") + "`n"

# Fix upstream PR placeholders and name length limits (max 23 chars)
$content = $content -replace 'aegis_1001330', 'Bar_D_Fl_Specimen'
$content = $content -replace 'aegis_1001331', 'Bar_D_Ea_Specimen'
$content = $content -replace 'aegis_1001332', 'Bar_D_Ic_Specimen'
$content = $content -replace 'aegis_1001333', 'Bar_D_St_Specimen'
$content = $content -replace 'aegis_1001334', 'Bar_D_So_Specimen'
$content = $content -replace 'aegis_1001335', 'Bar_D_Pu_Specimen'
$content = $content -replace 'aegis_1001336', 'Bar_D_Co_Specimen'
$content = $content -replace 'aegis_1001337', 'Bar_D_Po_Specimen'
$content = $content -replace 'Name: Temple Valkyrie Randgris', 'Name: Temple Randgris'
$content = $content -replace 'Name: Abyss Morocc Incarnation', 'Name: Abyss Morocc Avatar'

# Tune biosphere rune/essence drops (75% of official base rates)
$nl = [Environment]::NewLine
$content = $content -replace '(Temple_Barmund_Rune|Venom_Barmund_Rune|Soul_Barmund_Rune)\r?\n        Rate: 1500', ('$1' + $nl + '        Rate: 1125')
$content = $content -replace '(Barmund_Temple_Essence|Barmund_Venom_Essence|Barmund_Soul_Essence)\r?\n        Rate: 300', ('$1' + $nl + '        Rate: 225')
$content = $content -replace 'Etel_Dust\r?\n        Rate: 150', ('Etel_Dust' + $nl + '        Rate: 113')
$content = $content -replace 'Etel_Dust\r?\n        Rate: 200', ('Etel_Dust' + $nl + '        Rate: 150')
$content = $content -replace '(_Barmund_Rune2)\r?\n        Rate: 20', ('$1' + $nl + '        Rate: 15')
$content = $content -replace '(_Barmund_Rune)\r?\n        Rate: 80', ('$1' + $nl + '        Rate: 60')
$content = $content -replace '(Barmund_(?:Plain|Flame|Ice|Death|Temple|Venom|Soul)_Essence)\r?\n        Rate: 30', ('$1' + $nl + '        Rate: 23')

# 80% damage reduction for all biosphere mobs (20% damage taken)
$biosphereIds = 21920..21943 + 22140..22155 + 22252..22261
foreach ($id in $biosphereIds) {
	$content = $content -replace "(?ms)(^  - Id: $id\r?\n.*?^    DamageTaken: )\d+", '${1}20'
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outFile, $content, $utf8NoBom)

$bytes = [System.IO.File]::ReadAllBytes($outFile)[0..2]
Write-Host "Wrote $outFile ($((Get-Content $outFile).Count) lines, BOM bytes: $($bytes -join ','))"
