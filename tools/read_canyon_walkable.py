#!/usr/bin/env python3
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHES = [
    ROOT / "db" / "import" / "map_cache.dat",
    ROOT / "db" / "re" / "map_cache.dat",
    ROOT / "db" / "map_cache.dat",
]

WALKABLE = {0, 2, 3, 4, 6}


def load_map(cache_path: Path, map_name: str):
    data = cache_path.read_bytes()
    count = struct.unpack_from("<H", data, 4)[0]
    pos = 8
    for _ in range(count):
        name = data[pos : pos + 12].split(b"\0", 1)[0].decode("ascii", "replace")
        xs, ys = struct.unpack_from("<hh", data, pos + 12)
        ln = struct.unpack_from("<I", data, pos + 16)[0]
        payload = data[pos + 20 : pos + 20 + ln]
        if name == map_name:
            cells = zlib.decompress(payload)
            if len(cells) != xs * ys:
                raise RuntimeError(f"{map_name}: got {len(cells)} cells, expected {xs * ys}")
            return xs, ys, cells
        pos += 20 + ln
    raise KeyError(f"{map_name} not found in {cache_path}")


def walkable(cells, xs, ys, x, y):
    if x < 0 or y < 0 or x >= xs or y >= ys:
        return False
    return cells[y * xs + x] in WALKABLE


def scan(cells, xs, ys, x0, x1, y0, y1):
    out = []
    for y in range(y0, y1 + 1):
        row = [x for x in range(x0, min(x1 + 1, xs)) if walkable(cells, xs, ys, x, y)]
        if row:
            out.append((y, row))
    return out


def main():
    info = None
    cache_used = None
    for cache in CACHES:
        if not cache.exists():
            continue
        try:
            info = load_map(cache, "1@20cn1")
            cache_used = cache
            break
        except KeyError:
            continue
    if info is None:
        raise SystemExit("1@20cn1 not found")

    xs, ys, cells = info
    print(f"Using {cache_used}")
    print(f"1@20cn1: {xs}x{ys}")

    candidates = [
        ("Lehar entry (kRO)", 350, 75),
        ("Lehar entry (-100)", 250, 75),
        ("Lehar entry (-50)", 300, 75),
        ("Iwin 1 (kRO)", 378, 82),
        ("Iwin 1 (-100)", 278, 82),
        ("Iwin 2 (kRO)", 332, 338),
        ("Iwin 2 (-100)", 232, 238),
        ("Portal 1 (kRO)", 346, 352),
        ("Portal 1 (-100)", 246, 252),
        ("Lehar 2", 168, 248),
        ("Lehar hide (kRO)", 355, 72),
        ("Lehar hide (-100)", 255, 72),
    ]

    print("\nCoordinate check:")
    for label, x, y in candidates:
        ib = 0 <= x < xs and 0 <= y < ys
        print(f"  {label:22} ({x:3},{y:3}) inBounds={ib} walkable={walkable(cells, xs, ys, x, y) if ib else False}")

    regions = [
        ("entry", 200, xs - 1, 60, 100),
        ("mid-north", 150, xs - 1, 200, ys - 1),
        ("hide-south", 200, xs - 1, 55, 85),
    ]
    for name, x0, x1, y0, y1 in regions:
        print(f"\nWalkable in {name} (x={x0}-{x1}, y={y0}-{y1}):")
        for y, row in scan(cells, xs, ys, x0, x1, y0, y1):
            print(f"  y={y:3}: {row[:20]}{'...' if len(row) > 20 else ''}")

    # Find nearest walkable to target points
    print("\nNearest walkable to key targets:")
    targets = [
        ("entry", 250, 75),
        ("entry2", 240, 75),
        ("entry3", 230, 75),
        ("entry4", 220, 75),
        ("entry5", 210, 75),
    ]
    for label, tx, ty in targets:
        best = None
        for radius in range(1, 80):
            for dy in range(-radius, radius + 1):
                for dx in range(-radius, radius + 1):
                    if abs(dx) != radius and abs(dy) != radius:
                        continue
                    x, y = tx + dx, ty + dy
                    if walkable(cells, xs, ys, x, y):
                        dist = abs(dx) + abs(dy)
                        if best is None or dist < best[0]:
                            best = (dist, x, y)
            if best:
                break
        print(f"  {label} target ({tx},{ty}) -> {best}")


if __name__ == "__main__":
    main()
