#!/usr/bin/env python3
"""List training dummy mobs referenced by tra_fild spawn scripts.

Use this to audit mob_avail.yml coverage. Native S_DUMMY_* sprites should be
used as-is on clients that ship s_dummy_* assets (data.grf); do not remap them
to legacy DUMMY_10/50/100/150 unless that older sprite set is confirmed.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPAWN_FILE = ROOT / "npc" / "re" / "mobs" / "tra_fild_123.txt"
MOB_DB_FILES = (
	ROOT / "db" / "re" / "mob_db.yml",
	ROOT / "db" / "import" / "mob_db.yml",
)
MOB_AVAIL_FILE = ROOT / "db" / "import" / "mob_avail.yml"

MONSTER_RE = re.compile(
	r"monster\s+.+?\s+(\d+),",
	re.IGNORECASE,
)
COMMENT_RE = re.compile(r"//\s*(\S+)")
AEGIS_RE = re.compile(r"AegisName:\s*(\S+)")
MOB_AVAIL_RE = re.compile(r"^\s*-\s*Mob:\s*(\S+)", re.MULTILINE)


def load_aegis_names() -> dict[int, str]:
	names: dict[int, str] = {}
	current_id: int | None = None
	for path in MOB_DB_FILES:
		if not path.exists():
			continue
		for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
			if line.strip().startswith("- Id:"):
				current_id = int(line.split(":", 1)[1].strip())
				continue
			match = AEGIS_RE.search(line)
			if match and current_id is not None:
				names[current_id] = match.group(1)
				current_id = None
	return names


def main() -> None:
	if not SPAWN_FILE.exists():
		raise SystemExit(f"Missing spawn file: {SPAWN_FILE}")

	aegis_by_id = load_aegis_names()
	spawned: dict[str, int] = {}

	for line in SPAWN_FILE.read_text(encoding="utf-8", errors="replace").splitlines():
		monster = MONSTER_RE.search(line)
		if not monster:
			continue
		mob_id = int(monster.group(1))
		comment = COMMENT_RE.search(line)
		name = comment.group(1) if comment else aegis_by_id.get(mob_id, str(mob_id))
		spawned[name] = mob_id

	avail = set()
	if MOB_AVAIL_FILE.exists():
		avail = set(MOB_AVAIL_RE.findall(MOB_AVAIL_FILE.read_text(encoding="utf-8", errors="replace")))

	print(f"Training dummies in {SPAWN_FILE.name}: {len(spawned)} unique Aegis names")
	for name in sorted(spawned):
		mapped = "remapped" if name in avail else "native"
		print(f"  {name:<28} id={spawned[name]:<6} {mapped}")

	missing_db = [name for name, mob_id in spawned.items() if name not in aegis_by_id.values() and not name.isdigit()]
	if missing_db:
		print("\nWarning: spawn comments / IDs not found in mob_db:")
		for name in sorted(missing_db):
			print(f"  {name}")


if __name__ == "__main__":
	main()
