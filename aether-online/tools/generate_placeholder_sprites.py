#!/usr/bin/env python3
"""Write the placeholder traveler sprite sheet used by the client."""

import struct
import zlib
from pathlib import Path

FRAME = 64
COLUMNS = 8
ROWS = 10
WIDTH = FRAME * COLUMNS
HEIGHT = FRAME * ROWS


def write_png(path, width, height, rgba):
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    raw = b"".join(b"\x00" + rgba[y * width * 4:(y + 1) * width * 4] for y in range(height))
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def put(pixels, x, y, color):
    if 0 <= x < WIDTH and 0 <= y < HEIGHT:
        index = (y * WIDTH + x) * 4
        pixels[index:index + 4] = bytes(color)


def fill_rect(pixels, x0, y0, x1, y1, color):
    for y in range(y0, y1):
        for x in range(x0, x1):
            put(pixels, x, y, color)


def fill_circle(pixels, cx, cy, radius, color):
    r2 = radius * radius
    for y in range(cy - radius, cy + radius + 1):
        for x in range(cx - radius, cx + radius + 1):
            if ((x - cx) * (x - cx)) + ((y - cy) * (y - cy)) <= r2:
                put(pixels, x, y, color)


def direction_vector(column):
    vectors = (
        (0, 1),
        (1, 1),
        (1, 0),
        (1, -1),
        (0, -1),
        (-1, -1),
        (-1, 0),
        (-1, 1),
    )
    return vectors[column]


def draw_frame(pixels, column, row):
    ox = column * FRAME
    oy = row * FRAME
    if row < 2:
        body = (90, 176, 166, 255)
    elif row < 6:
        body = (214, 186, 122, 255)
    elif row < 8:
        body = (214, 146, 78, 255)
    else:
        body = (132, 136, 142, 255)

    bob = (row - 2) % 4 if 2 <= row < 6 else 0
    dead = row >= 8
    fill_circle(pixels, ox + 32, oy + 54, 10, (20, 24, 20, 90))
    torso_top = oy + (40 if dead else 24 + bob)
    torso_bottom = oy + (52 if dead else 46 + bob)
    fill_rect(pixels, ox + 24, torso_top, ox + 40, torso_bottom, body)
    if not dead:
        fill_circle(pixels, ox + 32, oy + 18 + bob, 7, (236, 220, 190, 255))
    dx, dy = direction_vector(column)
    fill_rect(pixels, ox + 30 + (dx * 8), oy + 28 + bob + (dy * 8), ox + 35 + (dx * 8), oy + 33 + bob + (dy * 8), (40, 36, 32, 255))
    if 6 <= row < 8:
        fill_rect(pixels, ox + 18, oy + 30, ox + 46, oy + 33, (255, 236, 180, 255))


def main():
    root = Path(__file__).resolve().parents[1]
    target = root / "client" / "AetherClient" / "assets" / "sprites" / "placeholder-traveler.png"
    target.parent.mkdir(parents=True, exist_ok=True)
    pixels = bytearray(WIDTH * HEIGHT * 4)
    for row in range(ROWS):
        for column in range(COLUMNS):
            draw_frame(pixels, column, row)
    write_png(target, WIDTH, HEIGHT, pixels)
    print(target)


if __name__ == "__main__":
    main()
