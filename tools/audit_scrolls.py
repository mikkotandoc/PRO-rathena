#!/usr/bin/env python3
"""Audit scroll-like usable items in db/re/ for broken scripts."""
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1]
db_re = root / "db/re"

grp_text = (db_re / "item_group_db.yml").read_text(encoding="utf-8", errors="ignore")
item_groups = set(re.findall(r"- Group: (\S+)", grp_text))

laphine_up = (db_re / "laphine_upgrade.yml").read_text(encoding="utf-8", errors="ignore")
laphine_up_items = set(re.findall(r"- Item: (\S+)", laphine_up))
laphine_syn = (db_re / "laphine_synthesis.yml").read_text(encoding="utf-8", errors="ignore")
laphine_syn_items = set(re.findall(r"- Item: (\S+)", laphine_syn))
package_items = set(re.findall(r"- Item: (\S+)", (db_re / "item_packages.yml").read_text(encoding="utf-8", errors="ignore")))

aegis_to_id = {}
items = []
for f in sorted(db_re.glob("item_db*.yml")):
    content = f.read_text(encoding="utf-8", errors="ignore")
    for block in re.split(r"\n  - Id: ", content):
        m_id = re.match(r"(\d+)\n", block)
        m_aegis = re.search(r"AegisName: (\S+)", block)
        m_name = re.search(r"Name: (.+)", block)
        m_type = re.search(r"Type: (\S+)", block)
        if not m_id or not m_aegis:
            continue
        script = ""
        sm = re.search(r"Script: \|\n((?:      .+\n?)*)", block)
        if sm:
            script = "\n".join(line[6:] if line.startswith("      ") else line for line in sm.group(1).splitlines()).strip()
        items.append({
            "id": int(m_id.group(1)),
            "aegis": m_aegis.group(1),
            "name": m_name.group(1).strip() if m_name else "",
            "type": m_type.group(1) if m_type else "",
            "file": f.name,
            "script": script,
        })

scroll_re = re.compile(r"scroll|Scroll|spellbook|Spellbook|_Up$|_Mix$", re.I)
moan_re = re.compile(r"moan|corruption|evil.?spirit", re.I)

scrolls = [it for it in items if scroll_re.search(it["aegis"]) or scroll_re.search(it["name"]) or moan_re.search(it["aegis"]) or moan_re.search(it["name"]) or "laphine_upgrade" in it["script"] or "laphine_synthesis" in it["script"]]

issues = []
for it in scrolls:
    probs = []
    s = it["script"]
    if it["type"] in ("Usable", "DelayConsume", "Delayconsume") and not s and it["aegis"] not in package_items:
        probs.append("EMPTY_SCRIPT")
    if "laphine_upgrade()" in s and it["aegis"] not in laphine_up_items:
        probs.append("MISSING_LAPPHINE_UPGRADE")
    if "laphine_synthesis()" in s and it["aegis"] not in laphine_syn_items:
        probs.append("MISSING_LAPPHINE_SYNTHESIS")
    for ig in re.findall(r"getgroupitem\s*\(\s*IG_(\w+)", s, re.I):
        if ig.upper() not in {g.upper() for g in item_groups}:
            probs.append(f"MISSING_IG:{ig}")
    if probs:
        issues.append((it, probs))

print(f"Scroll-like items: {len(scrolls)}")
print(f"With issues: {len(issues)}\n")
for cat in sorted({p.split(":")[0] for _, ps in issues for p in ps}):
    its = [it for it, ps in issues if any(p.startswith(cat) for p in ps)]
    print(f"=== {cat} ({len(its)}) ===")
    for it in sorted(its, key=lambda x: x["id"]):
        ps = [p for it2, pss in issues if it2 is it for p in pss]
        print(f"  {it['id']:>8}  {it['aegis']:<35}  {','.join(ps)}")
