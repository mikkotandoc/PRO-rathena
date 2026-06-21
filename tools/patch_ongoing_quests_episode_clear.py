#!/usr/bin/env python3
"""Patch OngoingQuests.lub episode clear chapter marker quest IDs."""
import re
import sys
from pathlib import Path

LUB_PATH = Path(
	r"c:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia w.o alitea\SystemEN\OngoingQuests.lub"
)

# Episode chapter titles from quest_db.yml / episode_clear.txt
CHAPTER_QUESTS = {
	13210: "Other World Entry Related Quest",
	13211: "Adapting to New Environment",
	13212: "Conflict of Three Nations Alliance Investigation Team",
	13213: "Report to the Continent",
	13214: "Dandelion's Request",
	13215: "Attitude Towards New Things",
	13216: "Gaining Trust from Cat Hand",
	13217: "Translator",
	13218: "Messenger",
	13219: "Continuing Research",
	13220: "Homesickness",
	13221: "To El Dicastes!",
	13222: "Doha's Secret Order",
	13223: "Fred's Request",
	14000: "Ep14.1 Bifrost",
	14001: "Ep14.2 Eclage",
	14002: "Ep14.3 Final Battle",
	15009: "Arunafeltz Excavation Team",
	15010: "Regenerating Memory",
	15011: "To Phantasmagorica!",
	15012: "Traces",
	15013: "Monthly Brigan",
	17040: "Ep17.1 New Operation Base",
	17041: "Pax's Employment Journey",
	17042: "Regenscrhirm Recapture Operation",
	17043: "Old Memories",
	17044: "Sky Seen from the Well",
	17045: "Pure Mischievous Child",
	17046: "Pax's Employment Journey 2",
	17100: "Ep17.2 Mansion's Doghole",
	17101: "Straggler in the Sewer",
	17102: "Cannot Find Network",
	17103: "I Want to Know That",
	17104: "Pest Extermination Operation",
	17105: "Attending the Coronation",
	17106: "Water Garden",
	17107: "Be Quiet in the Library",
	17108: "Bathhouse, Strange Creature and Me",
	18150: "To the Church State",
	18151: "Niren's Request",
	18152: "Children of Gray",
	18153: "Oz's Maze and the Merchant",
	18154: "Daily Bread to Be Thankful For",
	18155: "Sacred Relic for Essence",
	18156: "Belated Migration",
	18157: "I Can't Sleep",
	18158: "This Is Not That Place",
	18159: "Where Is My Home",
	18160: "There Are No Bad Beasts in the World",
	18161: "Gray Village Governor Candidate",
	18162: "Great Meeting in Gray Wolf Forest",
	18163: "Wolf in Sheep's Clothing",
	18164: "Sacred Deception",
	19200: "Guest Who Came on the North Wind",
	19201: "Patrol with Awin",
	19202: "Encounter with Experiment Subject 210426",
	19203: "Infiltration of Rgan's Dwelling",
	19204: "Finding Clues",
	19205: "Accumulating Suspicions",
	19206: "Confused Snake's Nest",
	19207: "Finding Underground Hideout from the Surface",
	19208: "Airship Destruction Operation",
	19209: "Saint of Purification",
	19210: "Frozen Sea",
	20000: "Natives of the Ancient Ice Gorge",
	20001: "Era of Cold War and Espionage",
	20003: "More Expert Than Any Awin",
	20004: "Kopo's Secret Base",
	20005: "Infiltration of Rgans' Hideout",
	20006: "Where the End of the Maze Leads",
	20007: "Deep Ancient Sea",
	20008: "The Undying One",
}

ADD_IDS = sorted(
	qid
	for qid in CHAPTER_QUESTS
	if qid
	in (
		13210,
		13211,
		13212,
		13213,
		13214,
		13215,
		13216,
		13217,
		13218,
		13219,
		13220,
		13221,
		13222,
		13223,
		14000,
		15009,
		15010,
		15011,
		15012,
		15013,
		19201,
		19202,
		19203,
		19204,
		19205,
		19206,
		19207,
		19208,
		19209,
		19210,
	)
)

UPDATE_IDS = sorted(set(CHAPTER_QUESTS) - set(ADD_IDS))


def make_block(qid: int, title: str) -> str:
	"""Minimal episode chapter marker block (tab-indented like nearby entries)."""
	escaped = title.replace("\\", "\\\\").replace('"', '\\"')
	return (
		f"\t[{qid}] = {{\n"
		f'\t\tTitle = "{escaped}",\n'
		f'\t\tIconName = "ico_ep.bmp",\n'
		f"\t\tDescription = {{\n"
		f'\t\t\t"{escaped}"\n'
		f"\t\t}},\n"
		f'\t\tSummary = "{escaped}"\n'
		f"\t}},"
	)


def find_block_span(lines: list[str], qid: int) -> tuple[int, int] | None:
	pattern = re.compile(rf"^\s*\[{qid}\]\s*=\s*\{{")
	start = None
	for i, line in enumerate(lines):
		if pattern.match(line):
			start = i
			break
	if start is None:
		return None
	depth = 0
	for j in range(start, len(lines)):
		depth += lines[j].count("{") - lines[j].count("}")
		if depth == 0 and j > start:
			return start, j
	return None


def find_insert_line(lines: list[str], before_qid: int) -> int | None:
	pattern = re.compile(rf"^\s*\[{before_qid}\]\s*=\s*\{{")
	for i, line in enumerate(lines):
		if pattern.match(line):
			return i
	return None


def main() -> int:
	path = Path(sys.argv[1]) if len(sys.argv) > 1 else LUB_PATH
	text = path.read_text(encoding="utf-8")
	lines = text.splitlines(keepends=True)

	# Update existing blocks
	for qid in UPDATE_IDS:
		span = find_block_span(lines, qid)
		if span is None:
			print(f"WARN: [{qid}] not found for update, skipping")
			continue
		start, end = span
		new_block = make_block(qid, CHAPTER_QUESTS[qid]) + "\n"
		lines[start : end + 1] = [new_block]
		print(f"Updated [{qid}]")

	# Insert new blocks (reverse order so line numbers stay valid)
	insert_after = {
		13210: 13205,
		14000: 14001,
		15009: 15014,
		19201: 19200,
	}
	for qid in sorted(ADD_IDS, reverse=True):
		if qid in insert_after:
			anchor = insert_after[qid]
			if qid == 15009:
				# insert before 15014 (after 15008 block)
				insert_at = find_insert_line(lines, 15014)
			elif qid >= 19201:
				# insert after 19200 block
				span = find_block_span(lines, 19200)
				if span is None:
					print(f"ERROR: cannot insert [{qid}], anchor 19200 missing")
					return 1
				insert_at = span[1] + 1
			else:
				span = find_block_span(lines, anchor)
				if span is None:
					print(f"ERROR: cannot insert [{qid}], anchor [{anchor}] missing")
					return 1
				insert_at = span[1] + 1
		else:
			# sequential ep13 / ep15 inserts: chain after previous id
			prev = qid - 1
			while prev not in CHAPTER_QUESTS and prev >= 13210:
				prev -= 1
			span = find_block_span(lines, prev)
			if span is None:
				print(f"ERROR: cannot insert [{qid}], prev [{prev}] missing")
				return 1
			insert_at = span[1] + 1

		lines.insert(insert_at, make_block(qid, CHAPTER_QUESTS[qid]) + "\n")
		print(f"Inserted [{qid}] at line {insert_at + 1}")

	path.write_text("".join(lines), encoding="utf-8", newline="")
	print(f"Done. Wrote {path}")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
