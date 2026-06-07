#!/usr/bin/env python3
"""Génère AppIcon.appiconset pour BeatDeal — variante C violet subtil, plein canvas."""
from __future__ import annotations

import json
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ICONSET = ROOT / "BeatDeal" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"

BG = (14, 12, 20)
VIOLET = (124, 58, 237)
STRIPE_A = (48, 40, 72)
STRIPE_B = (32, 28, 46)

ICONS: list[tuple[str, int, str, str, str]] = [
    ("Icon-40.png", 40, "iphone", "20x20", "2x"),
    ("Icon-60.png", 60, "iphone", "20x20", "3x"),
    ("Icon-58.png", 58, "iphone", "29x29", "2x"),
    ("Icon-87.png", 87, "iphone", "29x29", "3x"),
    ("Icon-80.png", 80, "iphone", "40x40", "2x"),
    ("Icon-120-40.png", 120, "iphone", "40x40", "3x"),
    ("Icon-120.png", 120, "iphone", "60x60", "2x"),
    ("Icon-180.png", 180, "iphone", "60x60", "3x"),
    ("Icon-1024.png", 1024, "ios-marketing", "1024x1024", "1x"),
]


def _chunk(tag: bytes, payload: bytes) -> bytes:
    return (
        struct.pack(">I", len(payload))
        + tag
        + payload
        + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF)
    )


def rgba_png(size: int, pixels: bytes) -> bytes:
    rows = b"".join(b"\x00" + pixels[y * size * 3 : (y + 1) * size * 3] for y in range(size))
    ihdr = struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + _chunk(b"IHDR", ihdr) + _chunk(b"IDAT", zlib.compress(rows, 9)) + _chunk(b"IEND", b"")


def in_doc(lx: float, ly: float, doc_w: float, doc_h: float, radius: float) -> bool:
    if lx < 0 or ly < 0 or lx > doc_w or ly > doc_h:
        return False
    r = radius
    if lx < r and ly < r and (lx - r) ** 2 + (ly - r) ** 2 > r * r:
        return False
    if lx > doc_w - r and ly < r and (lx - (doc_w - r)) ** 2 + (ly - r) ** 2 > r * r:
        return False
    if lx < r and ly > doc_h - r and (lx - r) ** 2 + (ly - (doc_h - r)) ** 2 > r * r:
        return False
    if lx > doc_w - r and ly > doc_h - r and (lx - (doc_w - r)) ** 2 + (ly - (doc_h - r)) ** 2 > r * r:
        return False
    return True


def draw_icon(size: int) -> bytes:
    buf = bytearray(size * size * 3)
    cx, cy = size / 2, size / 2
    doc_w = size * 0.44
    doc_h = size * 0.54
    doc_r = size * 0.045

    for y in range(size):
        for x in range(size):
            lx = x - (cx - doc_w / 2)
            ly = y - (cy - doc_h / 2)

            if in_doc(lx, ly, doc_w, doc_h, doc_r):
                if ly < doc_h * 0.17:
                    pr, pg, pb = VIOLET
                elif int((ly - doc_h * 0.17) / (doc_h * 0.105)) % 2 == 0:
                    pr, pg, pb = STRIPE_A
                else:
                    pr, pg, pb = STRIPE_B
            else:
                pr, pg, pb = BG

            i = (y * size + x) * 3
            buf[i], buf[i + 1], buf[i + 2] = pr, pg, pb

    return rgba_png(size, bytes(buf))


def main() -> None:
    ICONSET.mkdir(parents=True, exist_ok=True)
    contents: dict = {"images": [], "info": {"version": 1, "author": "xcode"}}

    for filename, px, idiom, size_str, scale in ICONS:
        (ICONSET / filename).write_bytes(draw_icon(px))
        contents["images"].append(
            {"filename": filename, "idiom": idiom, "size": size_str, "scale": scale}
        )

    (ICONSET / "Contents.json").write_text(json.dumps(contents, indent=2), encoding="utf-8")
    print(f"Généré {len(ICONS)} icônes (variante C) dans {ICONSET}")


if __name__ == "__main__":
    main()
