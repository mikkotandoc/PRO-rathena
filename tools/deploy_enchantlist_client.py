#!/usr/bin/env python3
"""Deploy English AegisName EnchantList.lub for Perfect Enchant UI."""
from __future__ import annotations

import re
import shutil
import sys
import urllib.request
from pathlib import Path

DEFAULT_CLIENT = Path(r"C:\Users\User1\Documents\RO - Copy")
SOURCE_URL = (
	"https://raw.githubusercontent.com/llchrisll/ROenglishRE/refs/heads/master/"
	"Translation/Compatibility/2023-09-20/data/luafiles514/lua%20files/Enchant/EnchantList.lub"
)
CLIENT_REL = Path("data/luafiles514/lua files/Enchant/EnchantList.lub")
CACHE = Path(__file__).resolve().parent / "_EnchantList_official.lub"

# Ordered replacements for non-ASCII AddPerfectEnchant names per table/slot.
PERFECT_FIXES: dict[tuple[int, int], list[str]] = {
	(36, 3): ["Sharp5"],
	(36, 2): ["Expert_Archer5"],
	(37, 2): ["Casting_Bottom", "Fatal_Bottom"],
	(37, 1): ["Casting_Middle", "Fatal0"],
	(37, 0): ["Casting_Top", "Fatal_Top"],
	(38, 0): ["Casting_Robe", "Fatal_Robe", "FixedCasting05"],
	(42, 3): ["Vitality3", "Luck3", "Strength3", "Agility3", "Spell5", "Expert_Archer5"],
	(42, 2): ["Vitality3", "Luck3", "Strength3", "Agility3", "Improve_Orb_HealHP", "Attack_Delay_4"],
	(42, 1): ["Vitality3", "Luck3", "Strength3", "Agility3", "Improve_Orb_HealHP", "Fatal4", "Improve_Orb_Life", "Improve_Orb_M_Heal"],
	(43, 3): ["Vitality3", "Luck3", "Spirit3", "Agility3", "Spell5", "Expert_Archer5"],
	(43, 2): ["Vitality3", "Luck3", "Spirit3", "Agility3", "Improve_Orb_HealSP", "Attack_Delay_4"],
	(43, 1): ["Vitality3", "Luck3", "Spirit3", "Agility3", "Improve_Orb_HealSP", "Fatal4", "Improve_Orb_Soul", "Improve_Orb_M_Soul"],
}


def fetch_source() -> Path:
	if CACHE.exists() and CACHE.stat().st_size > 100000:
		return CACHE
	print("Downloading EnchantList.lub...")
	urllib.request.urlretrieve(SOURCE_URL, CACHE)
	return CACHE


def is_ascii_aegis(name: str) -> bool:
	return bool(re.fullmatch(r"[A-Za-z0-9_]+", name))


def fix_garbled_perfects(text: str) -> tuple[str, int]:
	lines = text.splitlines()
	current_table = None
	fix_counts: dict[tuple[int, int], int] = {}
	fixed = 0
	out = []

	for line in lines:
		table_match = re.match(r"Table\[(\d+)\] = CreateEnchantInfo\(\)", line)
		if table_match:
			current_table = int(table_match.group(1))

		perfect_match = re.match(
			r'(Table\[\d+\]\.Slot\[(\d+)\]:AddPerfectEnchant\()"([^"]*)"(, .*)',
			line,
		)
		if perfect_match and current_table is not None and not is_ascii_aegis(perfect_match.group(3)):
			slot = int(perfect_match.group(2))
			key = (current_table, slot)
			names = PERFECT_FIXES.get(key)
			if names is not None:
				idx = fix_counts.get(key, 0)
				if idx >= len(names):
					raise RuntimeError(f"Too many garbled entries for Table[{current_table}] Slot[{slot}]")
				line = f'{perfect_match.group(1)}"{names[idx]}"{perfect_match.group(4)}'
				fix_counts[key] = idx + 1
				fixed += 1

		out.append(line)

	return "\n".join(out) + ("\n" if text.endswith("\n") else ""), fixed


def verify_tables(text: str) -> None:
	for table_id in (34, 37, 38):
		if f"Table[{table_id}] = CreateEnchantInfo()" not in text:
			raise RuntimeError(f"Table[{table_id}] missing after patch")
		if f"Table[{table_id}].Slot" not in text:
			raise RuntimeError(f"Table[{table_id}] has no slot data after patch")
	for name in ("Casting_Bottom", "Casting_Robe", "Boost_C_Enchant_1"):
		if name not in text:
			raise RuntimeError(f"Expected AegisName missing after patch: {name}")


def main() -> int:
	client_root = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CLIENT
	target = client_root / CLIENT_REL

	source_text = fetch_source().read_text(encoding="utf-8", errors="replace")
	patched, fixed = fix_garbled_perfects(source_text)
	verify_tables(patched)

	target.parent.mkdir(parents=True, exist_ok=True)
	if target.exists():
		backup = target.with_suffix(target.suffix + ".bak")
		shutil.copy2(target, backup)
		print(f"Backup: {backup}")

	target.write_text(patched, encoding="utf-8", newline="\n")
	print(f"Wrote: {target}")
	print(f"Fixed {fixed} garbled AddPerfectEnchant AegisNames")
	print(f"Table[37] entries: {patched.count('Table[37].Slot')}")
	print(f"Table[38] entries: {patched.count('Table[38].Slot')}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
