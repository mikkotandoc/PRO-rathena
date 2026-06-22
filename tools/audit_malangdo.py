#!/usr/bin/env python3
"""Audit Malangdo costume enchant NPC coverage vs item DB."""
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
npc_path = root / "npc/re/merchants/malangdo_costume.txt"
npc = npc_path.read_text(encoding="utf-8", errors="ignore")

# Load item DB
aegis_to_id = {}
id_to_aegis = {}
ids_in_db = set()
for f in sorted((root / "db/re").glob("item_db*.yml")):
	content = f.read_text(encoding="utf-8", errors="ignore")
	for block in re.split(r"\n  - Id: ", content):
		m_id = re.match(r"(\d+)\n", block)
		m_aegis = re.search(r"AegisName: (\S+)", block)
		if m_id and m_aegis:
			iid = int(m_id.group(1))
			aegis = m_aegis.group(1)
			ids_in_db.add(iid)
			aegis_to_id[aegis] = iid
			id_to_aegis[iid] = aegis

# Stone IDs from setarray .@stone_id blocks
stone_ids = set()
for block in re.findall(
	r"setarray \.@stone_id\[0\],\s*\n((?:\s*\d+,.*\n)+)", npc
):
	for sid in re.findall(r"(\d+),", block):
		stone_ids.add(int(sid))

# Garment stones from .@data$ array
for m in re.finditer(r"(\d+), (\d+), \"", npc):
	stone_ids.add(int(m.group(1)))

# Costume IDs from case statements in Aver/Lace sections
costume_ids = set(int(x) for x in re.findall(r"case (\d+):\s*//", npc))

# Exchange list costumes
exchange_ids = set()
for m in re.finditer(
	r"setarray \.@item_list_\d+\[0\],\s*\n((?:\s*\d+,.*\n)+)", npc
):
	exchange_ids.update(int(x) for x in re.findall(r"(\d+),", m.group(1)))

# Enchant card IDs referenced by stones
enchant_ids = set()
for block in re.findall(
	r"setarray \.@stone_id\[0\],\s*\n((?:\s*\d+,.*\n)+)", npc
):
	pairs = re.findall(r"(\d+),\s*(\d+)", block)
	for _, eid in pairs:
		enchant_ids.add(int(eid))
for m in re.finditer(r"(\d+), (\d+), \"", npc):
	enchant_ids.add(int(m.group(2)))

# 4th slot stones noted in file header
fourth_slot = [25058, 25059, 25136, 25137, 25138, 25176, 25177, 25178,
               25224, 25225, 25226, 25205]

print("=== MALANGDO ENCHANT AUDIT ===\n")
print(f"Stone item IDs in NPC scripts: {len(stone_ids)}")
print(f"Costume IDs in enchant lists: {len(costume_ids)}")
print(f"Costume IDs in exchange lists: {len(exchange_ids)}")

missing_stones_db = sorted(stone_ids - ids_in_db)
print(f"\n--- Stones in NPC missing from item DB ({len(missing_stones_db)}) ---")
for iid in missing_stones_db:
	print(f"  {iid:>8}  (enchant card refs may also be missing)")

missing_enchants_db = sorted(enchant_ids - ids_in_db)
print(f"\n--- Enchant cards in NPC missing from item DB ({len(missing_enchants_db)}) ---")
for iid in missing_enchants_db[:40]:
	print(f"  {iid:>8}  {id_to_aegis.get(iid, '?')}")
if len(missing_enchants_db) > 40:
	print(f"  ... and {len(missing_enchants_db) - 40} more")

missing_enchant_costumes = sorted(exchange_ids - costume_ids)
print(f"\n--- Exchange costumes not in enchant lists ({len(missing_enchant_costumes)}) ---")
for iid in missing_enchant_costumes:
	print(f"  {iid:>8}  {id_to_aegis.get(iid, '?')}")

print(f"\n--- 4th slot stones ---")
for iid in fourth_slot:
	in_npc = iid in stone_ids
	in_db = iid in ids_in_db
	name = id_to_aegis.get(iid, "?")
	print(f"  {iid:>8}  {name:<35}  NPC:{in_npc}  DB:{in_db}")

# Find costume stones in DB not wired to NPC
stone_pattern = re.compile(
	r"(Stone_Top|Stone_Middle|Stone_Bottom|Stone_Robe|_Stone$|_Stone_)"
)
db_stones = {
	iid: name
	for name, iid in aegis_to_id.items()
	if stone_pattern.search(name)
	and "Enchant_Stone_Box" not in name
	and "Box" not in name
}
unwired = sorted(
	set(db_stones) - stone_ids,
	key=lambda x: db_stones[x],
)
print(f"\n--- Costume stones in DB not in NPC ({len(unwired)}) ---")
for iid in unwired[:50]:
	print(f"  {iid:>8}  {db_stones[iid]}")
if len(unwired) > 50:
	print(f"  ... and {len(unwired) - 50} more")
