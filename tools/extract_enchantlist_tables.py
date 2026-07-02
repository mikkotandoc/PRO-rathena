#!/usr/bin/env python3
"""Extract EnchantList.lub table blocks from the official reference cache."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "tools" / "_EnchantList_official.lub"


def extract_tables(lines: list[str], table_ids: list[int]) -> list[str]:
	blocks: list[str] = []
	for tid in table_ids:
		start = next(
			(i for i, line in enumerate(lines) if re.match(rf"^Table\[{tid}\] = CreateEnchantInfo\(\)", line)),
			None,
		)
		if start is None:
			raise RuntimeError(f"Table[{tid}] not found in {SOURCE}")
		end = len(lines)
		for j in range(start + 1, len(lines)):
			match = re.match(r"^Table\[(\d+)\] = CreateEnchantInfo\(\)", lines[j])
			if match and int(match.group(1)) != tid:
				end = j
				break
		blocks.extend(lines[start:end])
		blocks.append("")
	return blocks


def main() -> int:
	if not SOURCE.exists():
		print(f"Missing source file: {SOURCE}", file=sys.stderr)
		return 1

	lines = SOURCE.read_text(encoding="utf-8", errors="replace").splitlines()
	biosphere_ids = [16, 17, 18, 19, 52, 53, 54, 55, 57, 58, 59, 60, 61, 62]
	biosphere_out = ROOT / "clientside/data/luafiles514/lua files/Enchant/EnchantList_biosphere.lub"
	biosphere_out.parent.mkdir(parents=True, exist_ok=True)
	biosphere_block = extract_tables(lines, biosphere_ids)
	biosphere_out.write_text("\n".join(biosphere_block) + "\n", encoding="utf-8")
	print(f"Wrote {len(biosphere_block)} lines -> {biosphere_out}")

	constellation_ids = list(range(7, 14))
	constellation_out = ROOT / "clientside/data/luafiles514/lua files/Enchant/EnchantList_constellation.lub"
	constellation_block = extract_tables(lines, constellation_ids)
	constellation_out.write_text("\n".join(constellation_block) + "\n", encoding="utf-8")
	print(f"Wrote {len(constellation_block)} lines -> {constellation_out}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
