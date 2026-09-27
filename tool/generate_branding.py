#!/usr/bin/env python3
"""Generate app/PWA icons with the Python standard library only."""
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]


def chunk(kind: bytes, data: bytes) -> bytes:
    return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xFFFFFFFF)


def write_png(path: Path, width: int, height: int, rows: list[bytearray]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = b''.join(b'\x00' + bytes(row) for row in rows)
    payload = b'\x89PNG\r\n\x1a\n'
    payload += chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0))
    payload += chunk(b'IDAT', zlib.compress(raw, 9))
    payload += chunk(b'IEND', b'')
    path.write_bytes(payload)


def icon(size: int) -> list[bytearray]:
    bg = (10, 18, 32)
    panel = (17, 30, 52)
    white = (244, 247, 251)
    yellow = (250, 204, 21)
    red = (235, 62, 62)
    rows = [bytearray(bg * size) for _ in range(size)]

    def set_px(x: int, y: int, color: tuple[int, int, int]) -> None:
        if 0 <= x < size and 0 <= y < size:
            i = x * 3
            rows[y][i:i + 3] = bytes(color)

    def rect(x0: float, y0: float, x1: float, y1: float, color: tuple[int, int, int]) -> None:
        for y in range(int(y0 * size), int(y1 * size)):
            for x in range(int(x0 * size), int(x1 * size)):
                set_px(x, y, color)

    def circle(cx: float, cy: float, radius: float, color: tuple[int, int, int]) -> None:
        cxi, cyi, r = int(cx * size), int(cy * size), int(radius * size)
        rr = r * r
        for y in range(cyi - r, cyi + r + 1):
            dy = y - cyi
            for x in range(cxi - r, cxi + r + 1):
                dx = x - cxi
                if dx * dx + dy * dy <= rr:
                    set_px(x, y, color)

    rect(.08, .08, .92, .92, panel)
    rect(.20, .18, .39, .48, yellow)
    rect(.61, .18, .80, .48, red)
    rect(.24, .57, .68, .69, white)
    circle(.69, .63, .09, white)
    circle(.69, .63, .038, panel)
    # lanyard / lower mark
    rect(.33, .75, .67, .79, white)
    rect(.47, .79, .53, .88, white)
    return rows


def generate(path: Path, size: int) -> None:
    write_png(path, size, size, icon(size))


web = ROOT / 'web' / 'icons'
for size in (192, 512):
    generate(web / f'Icon-{size}.png', size)
    generate(web / f'Icon-maskable-{size}.png', size)

android_sizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
}
for density, size in android_sizes.items():
    generate(ROOT / 'assets' / 'branding' / 'android' / f'mipmap-{density}' / 'ic_launcher.png', size)

print('Branding generated.')
