#!/usr/bin/env python3

"""Add or replace itemmall in rAthena map cache using official kRO cell data (200x100)."""

import struct

from pathlib import Path



ROOT = Path(__file__).resolve().parents[1]

ENTRY = ROOT / "tools" / "data" / "itemmall_mapcache_entry.bin"

DEFAULT_CACHE = ROOT / "db" / "re" / "map_cache.dat"

IMPORT_CACHE = ROOT / "db" / "import" / "map_cache.dat"

MAP_NAME = "itemmall"





def parse_cache(data: bytes):

    map_count = struct.unpack_from("<IH", data, 4)[1]

    maps = []

    pos = 8

    for _ in range(map_count):

        name = data[pos : pos + 12].split(b"\0", 1)[0].decode("ascii")

        xs, ys, ln = struct.unpack_from("<hhI", data, pos + 12)

        payload = data[pos + 20 : pos + 20 + ln]

        maps.append({"name": name, "xs": xs, "ys": ys, "payload": payload})

        pos += 20 + ln

    return maps





def build_cache(maps):

    body = bytearray()

    for entry in sorted(maps, key=lambda m: m["name"]):

        name = entry["name"].encode("ascii")[:11]

        name = name + b"\0" * (12 - len(name))

        body.extend(name)

        body.extend(struct.pack("<hhI", entry["xs"], entry["ys"], len(entry["payload"])))

        body.extend(entry["payload"])

    header = struct.pack("<IH", 8 + len(body), len(maps))

    return header + body





def load_entry():

    raw = ENTRY.read_bytes()

    name = raw[:12].split(b"\0", 1)[0].decode("ascii")

    xs, ys, ln = struct.unpack_from("<hhI", raw, 12)

    payload = raw[20 : 20 + ln]

    return {"name": name, "xs": xs, "ys": ys, "payload": payload}





def patch_cache(dst: Path):

    if not ENTRY.exists():

        raise SystemExit(f"Missing entry blob: {ENTRY}")

    if not dst.exists():

        raise SystemExit(f"Missing map cache: {dst}")



    entry = load_entry()

    maps = [m for m in parse_cache(dst.read_bytes()) if m["name"] != MAP_NAME]

    maps.append(entry)

    dst.write_bytes(build_cache(maps))

    print(f"Patched {entry['name']} ({entry['xs']}x{entry['ys']}) in {dst}")





def main():

    if IMPORT_CACHE.exists():

        patch_cache(IMPORT_CACHE)

    else:

        patch_cache(DEFAULT_CACHE)





if __name__ == "__main__":

    main()

