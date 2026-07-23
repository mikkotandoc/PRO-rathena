#!/usr/bin/env python3
"""Scan Ragnarok client binaries for Rune System related strings and packet bytes."""
from __future__ import annotations

import os
import sys
from pathlib import Path

EXE_PATHS = [
    Path(r"c:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia - Copy\proasia.exe"),
    Path(r"c:\Users\Mikko Tandoc\Downloads\asd\2\PRO-Ragnarok Asia - Copy\2026-01-07_Ragexe_1767686776_VHL_v5_clientinfo_patched_patched.exe"),
]

STRINGS_ASCII = [
    b"CRuneSystemMgr",
    b"runesystem",
    b"RuneSystem",
    b"RuneTablet",
    b"rune_system",
    b"SystemEN\\Rune",
    b"System\\Rune",
    b"itemDecom",
    b"runeset",
    b"CRune",
    b"RuneUI",
]

STRINGS_UTF16 = [
    s.decode("ascii").encode("utf-16le") for s in [
        "CRuneSystemMgr",
        "runesystem",
        "RuneSystem",
        "RuneTablet",
        "rune_system",
        "SystemEN\\Rune",
        "System\\Rune",
        "itemDecom",
        "runeset",
        "CRune",
        "RuneUI",
    ]
]

PACKET_PATTERNS = [
    (b"\xAE\x0B", "0x0AE2 (AE 0B)"),
    (b"\x9A\x0B", "0x0B9A (9A 0B)"),
]

CONTEXT = 64


def hexdump(data: bytes, base_off: int = 0) -> str:
    lines = []
    for i in range(0, len(data), 16):
        chunk = data[i : i + 16]
        hexpart = " ".join(f"{b:02X}" for b in chunk)
        asciipart = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        lines.append(f"  {base_off + i:08X}  {hexpart:<48}  {asciipart}")
    return "\n".join(lines)


def find_all(data: bytes, needle: bytes):
    hits = []
    start = 0
    while True:
        idx = data.find(needle, start)
        if idx < 0:
            break
        hits.append(idx)
        start = idx + 1
    return hits


def scan_file(path: Path):
    results = []
    if not path.exists():
        print(f"\n[MISSING] {path}")
        return results

    size = path.stat().st_size
    print(f"\n{'=' * 80}")
    print(f"FILE: {path}")
    print(f"SIZE: {size} ({size:#x})")
    print(f"{'=' * 80}")

    data = path.read_bytes()

    for needle in STRINGS_ASCII:
        label = needle.decode("ascii", errors="replace")
        for off in find_all(data, needle):
            dump_start = max(0, off - CONTEXT)
            dump = data[dump_start : min(len(data), off + len(needle) + CONTEXT)]
            hit = {
                "file": str(path),
                "offset": off,
                "encoding": "ASCII",
                "string": label,
                "needle_len": len(needle),
            }
            results.append(hit)
            print(f"\n--- HIT ASCII '{label}' @ 0x{off:08X} ({off}) ---")
            print(f"Context ({CONTEXT} before / {CONTEXT} after):")
            print(hexdump(dump, dump_start))

            window_start = max(0, off - 256)
            window_end = min(len(data), off + len(needle) + 256)
            window = data[window_start:window_end]
            for pat, pname in PACKET_PATTERNS:
                for poff in find_all(window, pat):
                    abs_off = window_start + poff
                    print(f"  ** Packet pattern {pname} near string @ 0x{abs_off:08X} (delta={abs_off - off:+d})")

    for needle, label_bytes in zip(STRINGS_UTF16, STRINGS_ASCII):
        label = label_bytes.decode("ascii", errors="replace")
        for off in find_all(data, needle):
            dump_start = max(0, off - CONTEXT)
            dump = data[dump_start : min(len(data), off + len(needle) + CONTEXT)]
            hit = {
                "file": str(path),
                "offset": off,
                "encoding": "UTF-16LE",
                "string": label,
                "needle_len": len(needle),
            }
            results.append(hit)
            print(f"\n--- HIT UTF-16LE '{label}' @ 0x{off:08X} ({off}) ---")
            print(f"Context ({CONTEXT} before / {CONTEXT} after):")
            print(hexdump(dump, dump_start))

            window_start = max(0, off - 256)
            window_end = min(len(data), off + len(needle) + 256)
            window = data[window_start:window_end]
            for pat, pname in PACKET_PATTERNS:
                for poff in find_all(window, pat):
                    abs_off = window_start + poff
                    print(f"  ** Packet pattern {pname} near string @ 0x{abs_off:08X} (delta={abs_off - off:+d})")

    return results


def main() -> int:
    all_hits = []
    for p in EXE_PATHS:
        all_hits.extend(scan_file(p))

    print(f"\n{'=' * 80}")
    print("SUMMARY OF ALL HITS")
    print(f"{'=' * 80}")
    if not all_hits:
        print("No string hits found in any file.")
    else:
        print(f"Total hits: {len(all_hits)}")
        for h in all_hits:
            print(
                f"  [{h['encoding']:8}] 0x{h['offset']:08X}  {h['string']!r}"
                f"  :: {os.path.basename(h['file'])}"
            )

    print(f"\n{'=' * 80}")
    print("GLOBAL PACKET BYTE COUNTS (entire file; noisy)")
    print(f"{'=' * 80}")
    for p in EXE_PATHS:
        if not p.exists():
            continue
        data = p.read_bytes()
        print(f"\n{p.name}:")
        for pat, pname in PACKET_PATTERNS:
            count = data.count(pat)
            print(f"  {pname}: {count} occurrences")

    return 0


if __name__ == "__main__":
    sys.exit(main())