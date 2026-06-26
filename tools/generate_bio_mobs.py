#!/usr/bin/env python3
"""Generate db/import/mob_db.yml BIO_ depth entries from PR8115 + kRO EP20."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IMPORT_MOB = ROOT / "db" / "import" / "mob_db.yml"
PR_PATCH = Path(__import__("os").environ.get("TEMP", "/tmp")) / "pr8115_mob_patch.txt"

ATK_FACTOR = 0.984
MATK_FACTOR = 0.949

DEPTH2_KRO = {
    22252: {
        "AegisName": "BIO_DUNEYRR", "Name": "Abyss Duneyrr",
        "Level": 265, "Hp": 166986400, "BaseExp": 6626510, "JobExp": 4615364,
        "AtkMin": 47506, "AtkMax": 70919, "MatkMin": 12034, "MatkMax": 21895,
        "Defense": 443, "MagicDefense": 171, "Resistance": 1725, "MagicResistance": 2009,
        "Str": 414, "Agi": 274, "Vit": 329, "Int": 265, "Dex": 368, "Luk": 352,
        "AttackRange": 2, "Size": "Large", "Race": "Demihuman", "Element": "Fire", "ElementLevel": 3,
        "Speed": 7.69, "Aspd": 2.38, "CommonDrop": "Fur",
    },
    22253: {
        "AegisName": "BIO_NAGA", "Name": "Abyss Naga",
        "Level": 265, "Hp": 181266750, "BaseExp": 6600885, "JobExp": 4597510,
        "AtkMin": 41543, "AtkMax": 61986, "MatkMin": 10459, "MatkMax": 18982,
        "Defense": 432, "MagicDefense": 167, "Resistance": 1651, "MagicResistance": 1923,
        "Str": 393, "Agi": 261, "Vit": 312, "Int": 252, "Dex": 350, "Luk": 334,
        "AttackRange": 2, "Size": "Large", "Race": "Brute", "Element": "Earth", "ElementLevel": 2,
        "Speed": 6.67, "Aspd": 1.16, "CommonDrop": "Scales_Shell",
    },
    22254: {
        "AegisName": "BIO_ANCIENT_TREE", "Name": "Abyss Ancient Tree",
        "Level": 265, "Hp": 164463460, "BaseExp": 6498899, "JobExp": 4526483,
        "AtkMin": 45258, "AtkMax": 67500, "MatkMin": 11944, "MatkMax": 21675,
        "Defense": 492, "MagicDefense": 190, "Resistance": 2066, "MagicResistance": 2401,
        "Str": 509, "Agi": 335, "Vit": 404, "Int": 326, "Dex": 448, "Luk": 433,
        "AttackRange": 1, "Size": "Large", "Race": "Plant", "Element": "Earth", "ElementLevel": 2,
        "Speed": 5.00, "Aspd": 1.04, "CommonDrop": "Elder_Branch",
    },
    22255: {
        "AegisName": "BIO_DOLLOCARIS", "Name": "Abyss Dollocaris",
        "Level": 265, "Hp": 178600800, "BaseExp": 6549636, "JobExp": 4561821,
        "AtkMin": 41198, "AtkMax": 61456, "MatkMin": 10497, "MatkMax": 19040,
        "Defense": 444, "MagicDefense": 172, "Resistance": 1734, "MagicResistance": 2019,
        "Str": 417, "Agi": 276, "Vit": 331, "Int": 267, "Dex": 370, "Luk": 354,
        "AttackRange": 1, "Size": "Medium", "Race": "Fish", "Element": "Earth", "ElementLevel": 3,
        "Speed": 5.00, "Aspd": 0.95, "CommonDrop": "Scropion's_Nipper",
    },
    22256: {
        "AegisName": "BIO_ICE_GARGOYLE", "Name": "Abyss Ice Gargoyle",
        "Level": 265, "Hp": 162858710, "BaseExp": 6595539, "JobExp": 4605240,
        "AtkMin": 35500, "AtkMax": 52941, "MatkMin": 11349, "MatkMax": 20594,
        "Defense": 255, "MagicDefense": 151, "Resistance": 851, "MagicResistance": 1915,
        "Str": 354, "Agi": 326, "Vit": 224, "Int": 298, "Dex": 443, "Luk": 364,
        "AttackRange": 11, "Size": "Medium", "Race": "Demon", "Element": "Water", "ElementLevel": 3,
        "Speed": 6.67, "Aspd": 1.39, "CommonDrop": "Petite_DiablOfs_Wing",
    },
    22257: {
        "AegisName": "BIO_FLAME_GHOST", "Name": "Abyss Flame Ghost",
        "Level": 265, "Hp": 159779165, "BaseExp": 6565544, "JobExp": 4583592,
        "AtkMin": 31327, "AtkMax": 46726, "MatkMin": 17705, "MatkMax": 32310,
        "Defense": 280, "MagicDefense": 314, "Resistance": 1067, "MagicResistance": 2177,
        "Str": 264, "Agi": 263, "Vit": 298, "Int": 402, "Dex": 385, "Luk": 402,
        "AttackRange": 3, "Size": "Medium", "Race": "Undead", "Element": "Fire", "ElementLevel": 2,
        "Speed": 10.00, "Aspd": 1.10, "CommonDrop": "Skull",
    },
    22258: {
        "AegisName": "BIO_ACIDUS_", "Name": "Abyss Acidus",
        "Level": 265, "Hp": 171678990, "BaseExp": 6690545, "JobExp": 4655421,
        "AtkMin": 34336, "AtkMax": 51209, "MatkMin": 13247, "MatkMax": 24048,
        "Defense": 592, "MagicDefense": 259, "Resistance": 2412, "MagicResistance": 1768,
        "Str": 325, "Agi": 288, "Vit": 442, "Int": 382, "Dex": 421, "Luk": 383,
        "AttackRange": 2, "Size": "Large", "Race": "Dragon", "Element": "Wind", "ElementLevel": 2,
        "Speed": 5.00, "Aspd": 1.30, "CommonDrop": "Dragon_Canine",
    },
    22259: {
        "AegisName": "BIO_MOROCC_1", "Name": "Abyss Morocc Avatar",
        "Level": 265, "Hp": 155392230, "BaseExp": 6652134, "JobExp": 4633211,
        "AtkMin": 49940, "AtkMax": 74569, "MatkMin": 12648, "MatkMax": 23033,
        "Defense": 444, "MagicDefense": 172, "Resistance": 1734, "MagicResistance": 2019,
        "Str": 417, "Agi": 276, "Vit": 331, "Int": 267, "Dex": 370, "Luk": 354,
        "AttackRange": 2, "Size": "Large", "Race": "Angel", "Element": "Dark", "ElementLevel": 1,
        "Speed": 6.67, "Aspd": 2.08, "CommonDrop": "Dark_Debris",
    },
    22260: {
        "AegisName": "BIO_SALAMANDER", "Name": "Abyss Salamander",
        "Level": 265, "Hp": 155742230, "BaseExp": 6575264, "JobExp": 4579669,
        "AtkMin": 50854, "AtkMax": 75905, "MatkMin": 13265, "MatkMax": 24142,
        "Defense": 480, "MagicDefense": 185, "Resistance": 1987, "MagicResistance": 2311,
        "Str": 487, "Agi": 321, "Vit": 387, "Int": 312, "Dex": 429, "Luk": 414,
        "AttackRange": 2, "Size": "Large", "Race": "Formless", "Element": "Fire", "ElementLevel": 2,
        "Speed": 7.69, "Aspd": 3.33, "CommonDrop": "Burning_Heart",
    },
    22261: {
        "AegisName": "BIO_MOSKILLO", "Name": "Abyss Moskillo",
        "Level": 265, "Hp": 155812230, "BaseExp": 6498388, "JobExp": 4526126,
        "AtkMin": 48782, "AtkMax": 72759, "MatkMin": 13071, "MatkMax": 23738,
        "Defense": 519, "MagicDefense": 200, "Resistance": 2257, "MagicResistance": 2623,
        "Str": 563, "Agi": 369, "Vit": 447, "Int": 361, "Dex": 493, "Luk": 478,
        "AttackRange": 1, "Size": "Medium", "Race": "Insect", "Element": "Wind", "ElementLevel": 3,
        "Speed": 5.00, "Aspd": 1.16, "CommonDrop": "Round_Shell",
    },
}

# Etel_Dust stays on mob_db; abyss jewels are map_drops on bl_depth2 (build_biosphere_map_drops.ps1).
DEPTH2_DROPS = [
    ("Etel_Dust", 200),
]


def parse_depth1_from_pr() -> str:
    lines = [l[1:] for l in PR_PATCH.read_text(encoding="utf-8").splitlines()
             if l.startswith("+") and not l.startswith("+++")]
    text = "\n".join(lines)
    blocks = []
    for m in re.finditer(r"  - Id: (22(?:14\d|15[0-5]))\n((?:    .+\n)+)", text):
        block = m.group(2)
        if "Specimen\n" in block and "Rate: 2500" not in block:
            block = block.rstrip("\n") + "\n        Rate: 2500\n"
        blocks.append(f"  - Id: {m.group(1)}\n{block}")
    yaml = "\n".join(blocks)
    replacements = {
        "aegis_1001330": "Bar_D_Fl_Specimen",
        "aegis_1001331": "Bar_D_Ea_Specimen",
        "aegis_1001332": "Bar_D_Ic_Specimen",
        "aegis_1001333": "Bar_D_St_Specimen",
        "aegis_1001334": "Bar_D_So_Specimen",
        "aegis_1001335": "Bar_D_Pu_Specimen",
        "aegis_1001336": "Bar_D_Co_Specimen",
        "aegis_1001337": "Bar_D_Po_Specimen",
    }
    for old, new in replacements.items():
        yaml = yaml.replace(old, new)
    return yaml.rstrip() + "\n"


def convert_motion(speed: float, aspd: float) -> tuple[int, int, int]:
    walk = max(20, int(round(1000 / speed)))
    motion = max(96, int(round(1000 / aspd)))
    delay = max(96, int(motion * 0.2))
    return walk, delay, motion


def render_depth2(m: dict) -> str:
    atk = int(round((m["AtkMin"] + m["AtkMax"]) / 2 * ATK_FACTOR))
    matk = int(round((m["MatkMin"] + m["MatkMax"]) / 2 * MATK_FACTOR))
    walk, delay, motion = convert_motion(m["Speed"], m["Aspd"])
    lines = [
        f"  - Id: {m['Id']}",
        f"    AegisName: {m['AegisName']}",
        f"    Name: {m['Name']}",
        f"    Level: {m['Level']}",
        f"    Hp: {m['Hp']}",
        f"    BaseExp: {m['BaseExp']}",
        f"    JobExp: {m['JobExp']}",
        f"    Attack: {atk}",
        f"    Attack2: {matk}",
        f"    Defense: {m['Defense']}",
        f"    MagicDefense: {m['MagicDefense']}",
        f"    Resistance: {m['Resistance']}",
        f"    MagicResistance: {m['MagicResistance']}",
        f"    Str: {m['Str']}",
        f"    Agi: {m['Agi']}",
        f"    Vit: {m['Vit']}",
        f"    Int: {m['Int']}",
        f"    Dex: {m['Dex']}",
        f"    Luk: {m['Luk']}",
        f"    AttackRange: {m['AttackRange']}",
        "    SkillRange: 10",
        "    ChaseRange: 12",
        f"    Size: {m['Size']}",
        f"    Race: {m['Race']}",
        f"    Element: {m['Element']}",
        f"    ElementLevel: {m['ElementLevel']}",
        f"    WalkSpeed: {walk}",
        f"    AttackDelay: {delay}",
        f"    AttackMotion: {motion}",
        "    DamageMotion: 432",
        "    DamageTaken: 10",
        "    Ai: 21",
        "    Class: Boss",
        "    Drops:",
        f"      - Item: {m['CommonDrop']}",
        "        Rate: 1500",
    ]
    for item, rate in DEPTH2_DROPS:
        lines.append(f"      - Item: {item}")
        lines.append(f"        Rate: {rate}")
    return "\n".join(lines)


def strip_existing_bio(text: str) -> str:
    ids = set(DEPTH2_KRO) | set(range(22140, 22156))
    parts = []
    pos = 0
    for m in re.finditer(r"^  - Id: (\d+)\n", text, re.M):
        mid = int(m.group(1))
        start = m.start()
        if start > pos:
            parts.append(text[pos:start])
        next_m = re.search(r"^  - Id: \d+\n", text[m.end():], re.M)
        end = m.end() + next_m.start() if next_m else len(text)
        if mid not in ids:
            parts.append(text[start:end])
        pos = end
    parts.append(text[pos:])
    return "".join(parts).rstrip() + "\n"


def main():
    depth1 = parse_depth1_from_pr()
    depth2_parts = []
    for mid, data in sorted(DEPTH2_KRO.items()):
        entry = dict(data)
        entry["Id"] = mid
        depth2_parts.append(render_depth2(entry))
    depth2 = "\n".join(depth2_parts) + "\n"

    header = (
        "# Varmundt's Biosphere depth mob definitions (import overlay)\n"
        "# Depth 1 (bl_depth1): rAthena PR #8115 / kRO EP20\n"
        "# Depth 2 (bl_depth2): kRO EP20 (Divine Pride), rAthena conversion\n\n"
    )
    bio_block = header + depth1 + depth2

    if IMPORT_MOB.exists():
        existing = IMPORT_MOB.read_text(encoding="utf-8")
        cleaned = strip_existing_bio(existing)
        if "Body:" in cleaned:
            body_idx = cleaned.rfind("Body:")
            insert_at = cleaned.find("\n", body_idx) + 1
            new_text = cleaned[:insert_at] + "\n" + bio_block + cleaned[insert_at:]
        else:
            new_text = cleaned + "\n" + bio_block
    else:
        new_text = (
            "Header:\n  Type: MOB_DB\n  Version: 5\n\nBody:\n\n" + bio_block
        )

    IMPORT_MOB.write_text(new_text, encoding="utf-8")
    print(f"Wrote {IMPORT_MOB} ({len(new_text.splitlines())} lines)")


if __name__ == "__main__":
    main()
