#!/usr/bin/env python3
"""Generate client EnchantList.lub Table[N] blocks from db/re/item_enchant.yml."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "db" / "re" / "item_enchant.yml"


def parse_materials(block: str) -> list[tuple[str, int]]:
	materials: list[tuple[str, int]] = []
	for match in re.finditer(
		r"- Material: (\S+)\s*\n\s*Amount: (\d+)",
		block,
	):
		materials.append((match.group(1), int(match.group(2))))
	return materials


def fmt_materials(materials: list[tuple[str, int]]) -> str:
	if not materials:
		return ""
	parts = ", ".join(f'{{"{name}", {amount}}}' for name, amount in materials)
	return ", " + parts


def parse_enchant_block(block: str) -> dict:
	entry: dict = {
		"target_items": [],
		"minimum_refine": 0,
		"minimum_enchantgrade": 0,
		"allow_random_options": True,
		"reset": None,
		"order": [],
		"slots": {},
	}

	for match in re.finditer(r"^      (\w[\w_]*): true\s*$", block, re.M):
		entry["target_items"].append(match.group(1))

	if m := re.search(r"MinimumRefine: (\d+)", block):
		entry["minimum_refine"] = int(m.group(1))
	if m := re.search(r"MinimumEnchantgrade: (\d+)", block):
		entry["minimum_enchantgrade"] = int(m.group(1))
	if re.search(r"AllowRandomOptions: false", block):
		entry["allow_random_options"] = False

	reset_match = re.search(
		r"Reset:\s*\n((?:      .+\n)+?)(?=    Order:|    Slots:|  - Id:|\Z)",
		block,
	)
	if reset_match:
		reset_block = reset_match.group(1)
		chance = int(re.search(r"Chance: (\d+)", reset_block).group(1))
		price = int(re.search(r"Price: (\d+)", reset_block).group(1))
		entry["reset"] = (chance, price, parse_materials(reset_block))

	for match in re.finditer(r"- Slot: (\d+)", block):
		entry["order"].append(int(match.group(1)))

	for slot_match in re.finditer(
		r"- Slot: (\d+)\s*\n((?:        .+\n)+?)(?=      - Slot:|\Z)",
		block,
	):
		slot_id = int(slot_match.group(1))
		slot_block = slot_match.group(2)
		slot: dict = {
			"price": 0,
			"chance": 100000,
			"materials": parse_materials(slot_block),
			"enchants": {},
			"perfect": [],
			"upgrades": [],
		}
		if m := re.search(r"Price: (\d+)", slot_block):
			slot["price"] = int(m.group(1))
		if m := re.search(r"Chance: (\d+)", slot_block):
			slot["chance"] = int(m.group(1))

		for grade_match in re.finditer(
			r"- Enchantgrade: (\d+)\s*\n\s*Items:\s*\n((?:              .+\n)+?)(?=          - Enchantgrade:|        PerfectEnchants:|        Upgrades:|$)",
			slot_block,
		):
			grade = int(grade_match.group(1))
			items: list[tuple[str, int]] = []
			for item_match in re.finditer(
				r"- Item: (\S+)\s*\n\s*Chance: (\d+)",
				grade_match.group(2),
			):
				items.append((item_match.group(1), int(item_match.group(2))))
			slot["enchants"][grade] = items

		for perfect_match in re.finditer(
			r"- Item: (\S+)\s*\n((?:            .+\n)+?)(?=          - Item:|        Upgrades:|$)",
			slot_block.split("PerfectEnchants:", 1)[1]
			if "PerfectEnchants:" in slot_block
			else "",
		):
			perfect_block = perfect_match.group(2)
			price = int(m.group(1)) if (m := re.search(r"Price: (\d+)", perfect_block)) else 0
			slot["perfect"].append(
				(perfect_match.group(1), price, parse_materials(perfect_block))
			)

		if "Upgrades:" in slot_block:
			upgrade_section = slot_block.split("Upgrades:", 1)[1]
			for upgrade_match in re.finditer(
				r"- Enchant: (\S+)\s*\n\s*Upgrade: (\S+)\s*\n((?:            .+\n)+?)(?=          - Enchant:|\Z)",
				upgrade_section,
			):
				upgrade_block = upgrade_match.group(3)
				price = int(m.group(1)) if (m := re.search(r"Price: (\d+)", upgrade_block)) else 0
				slot["upgrades"].append(
					(
						upgrade_match.group(1),
						upgrade_match.group(2),
						price,
						parse_materials(upgrade_block),
					)
				)

		entry["slots"][slot_id] = slot

	return entry


def extract_entry(source_text: str, entry_id: int) -> str:
	pattern = rf"  - Id: {entry_id}\s*\n(.*?)(?=  - Id: |\Z)"
	match = re.search(pattern, source_text, re.S)
	if not match:
		raise RuntimeError(f"Item enchant Id {entry_id} not found in {SOURCE}")
	return match.group(1)


def emit_table(entry_id: int, entry: dict) -> list[str]:
	lines: list[str] = []
	lines.append(f"Table[{entry_id}] = CreateEnchantInfo()")

	if entry["order"]:
		order = ", ".join(str(slot) for slot in entry["order"])
		lines.append(f"Table[{entry_id}]:SetSlotOrder({order})")

	for item in entry["target_items"]:
		lines.append(f'Table[{entry_id}]:AddTargetItem("{item}")')

	lines.append(
		f"Table[{entry_id}]:SetCondition({entry['minimum_refine']}, {entry['minimum_enchantgrade']})"
	)
	lines.append(
		f"Table[{entry_id}]:ApproveRandomOption({'true' if entry['allow_random_options'] else 'false'})"
	)

	if entry["reset"]:
		chance, price, materials = entry["reset"]
		if materials:
			lines.append(
				f"Table[{entry_id}]:SetReset(true, {chance}, {price}{fmt_materials(materials)})"
			)
		else:
			lines.append(f"Table[{entry_id}]:SetReset(true, {chance}, {price})")
	else:
		lines.append(f"Table[{entry_id}]:SetReset(false, 0, 0)")

	lines.append(
		f'Table[{entry_id}]:SetCaution("Temporal Circlet Enchantment\\nReset Chance: 70%\\nOn reset failure the circlet is destroyed.")'
	)

	for slot_id in entry["order"]:
		slot = entry["slots"][slot_id]
		prefix = f"Table[{entry_id}].Slot[{slot_id}]"

		if slot["enchants"]:
			lines.append(
				f"{prefix}:SetRequire({slot['price']}{fmt_materials(slot['materials'])})"
			)
			lines.append(f"{prefix}:SetSuccessRate({slot['chance']})")
			for grade in range(5):
				lines.append(f"{prefix}:SetGradeBonus({grade}, 0)")
			for grade, items in sorted(slot["enchants"].items()):
				for item_name, item_chance in items:
					lines.append(
						f'{prefix}:SetEnchant({grade}, "{item_name}", {item_chance})'
					)

		for item_name, price, materials in slot["perfect"]:
			lines.append(
				f'{prefix}:AddPerfectEnchant("{item_name}", {price}{fmt_materials(materials)})'
			)

		for from_item, to_item, price, materials in slot["upgrades"]:
			lines.append(
				f'{prefix}:AddUpgradeEnchant("{from_item}", "{to_item}", {price}{fmt_materials(materials)})'
			)

	return lines


def main() -> int:
	if len(sys.argv) < 2:
		print(f"Usage: {Path(__file__).name} <enchant_id> [output.lub]", file=sys.stderr)
		return 1

	entry_id = int(sys.argv[1])
	source_text = SOURCE.read_text(encoding="utf-8")
	entry = parse_enchant_block(extract_entry(source_text, entry_id))
	lines = emit_table(entry_id, entry)

	if len(sys.argv) >= 3:
		out = Path(sys.argv[2])
		out.parent.mkdir(parents=True, exist_ok=True)
		out.write_text("\n".join(lines) + "\n", encoding="utf-8")
		print(f"Wrote {len(lines)} lines -> {out}")
	else:
		print("\n".join(lines))
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
