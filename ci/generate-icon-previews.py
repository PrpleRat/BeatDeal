#!/usr/bin/env python3
"""Génère des previews 1024px de logos BeatDeal — ne remplace pas l'AppIcon."""
from __future__ import annotations

import math
import struct
import zlib
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "docs" / "icon-previews"
SIZE = 1024

# Palette BeatDeal
VIOLET = (124, 58, 237)
VIOLET_LIGHT = (167, 139, 250)
BG_DARK = (10, 10, 10)
BG_SOFT = (18, 18, 22)


@dataclass
class Variant:
    slug: str
    title: str
    description: str


VARIANTS = [
    Variant(
        "a-contraste-clair",
        "A — Document clair",
        "Corps blanc cassé + bandes grises visibles. Contraste maximal, lisible en petit.",
    ),
    Variant(
        "b-carte-elevee",
        "B — Carte surélevée",
        "Fond noir + carte gris anthracite + bordure violette fine + bandes alternées.",
    ),
    Variant(
        "c-violet-subtil",
        "C — Teinte violette",
        "Carte sombre mais bandes teintées violet/gris — reste dark mode, plus de relief.",
    ),
    Variant(
        "d-minimal-stroke",
        "D — Contour lumineux",
        "Document sombre avec contour blanc/violet et header plus large.",
    ),
    Variant(
        "e-glass",
        "E — Glass premium",
        "Effet verre : fond dégradé, carte semi-claire, reflet discret en haut.",
    ),
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


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def lerp_rgb(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def in_rounded_app_icon(x: int, y: int, size: int) -> bool:
    margin = size * 0.08
    corner_r = size * 0.18
    for corner_x, corner_y in (
        (margin, margin),
        (size - margin, margin),
        (margin, size - margin),
        (size - margin, size - margin),
    ):
        if (x < margin or x >= size - margin) and (y < margin or y >= size - margin):
            dx, dy = x - corner_x, y - corner_y
            if dx * dx + dy * dy > corner_r * corner_r:
                return False
    return True


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


def dist_to_doc_edge(lx: float, ly: float, doc_w: float, doc_h: float) -> float:
    return min(lx, ly, doc_w - lx, doc_h - ly)


def draw_variant(slug: str) -> bytes:
    size = SIZE
    buf = bytearray(size * size * 3)
    cx, cy = size / 2, size / 2
    doc_w = size * 0.44
    doc_h = size * 0.54
    doc_r = size * 0.045

    for y in range(size):
        for x in range(size):
            if not in_rounded_app_icon(x, y, size):
                pr, pg, pb = BG_DARK
            else:
                lx = x - (cx - doc_w / 2)
                ly = y - (cy - doc_h / 2)
                in_document = in_doc(lx, ly, doc_w, doc_h, doc_r)

                if slug == "a-contraste-clair":
                    if not in_document:
                        pr, pg, pb = BG_DARK
                    elif ly < doc_h * 0.17:
                        pr, pg, pb = VIOLET
                    elif int((ly - doc_h * 0.17) / (doc_h * 0.11)) % 2 == 0:
                        pr, pg, pb = (232, 232, 236)
                    else:
                        pr, pg, pb = (210, 210, 218)

                elif slug == "b-carte-elevee":
                    if not in_document:
                        pr, pg, pb = BG_DARK
                    else:
                        edge = dist_to_doc_edge(lx, ly, doc_w, doc_h)
                        if edge < 2.5:
                            pr, pg, pb = VIOLET_LIGHT
                        elif ly < doc_h * 0.17:
                            pr, pg, pb = VIOLET
                        elif int((ly - doc_h * 0.17) / (doc_h * 0.105)) % 2 == 0:
                            pr, pg, pb = (58, 58, 68)
                        else:
                            pr, pg, pb = (38, 38, 48)

                elif slug == "c-violet-subtil":
                    if not in_document:
                        pr, pg, pb = (14, 12, 20)
                    elif ly < doc_h * 0.17:
                        pr, pg, pb = VIOLET
                    elif int((ly - doc_h * 0.17) / (doc_h * 0.105)) % 2 == 0:
                        pr, pg, pb = (48, 40, 72)
                    else:
                        pr, pg, pb = (32, 28, 46)

                elif slug == "d-minimal-stroke":
                    if not in_document:
                        pr, pg, pb = BG_SOFT
                    else:
                        edge = dist_to_doc_edge(lx, ly, doc_w, doc_h)
                        if edge < 3:
                            pr, pg, pb = (240, 240, 245)
                        elif ly < doc_h * 0.2:
                            pr, pg, pb = VIOLET
                        elif int((ly - doc_h * 0.2) / (doc_h * 0.1)) % 2 == 0:
                            pr, pg, pb = (52, 52, 60)
                        else:
                            pr, pg, pb = (36, 36, 44)

                elif slug == "e-glass":
                    t = y / size
                    bg = lerp_rgb((12, 10, 18), (24, 18, 36), t)
                    if not in_document:
                        pr, pg, pb = bg
                    else:
                        edge = dist_to_doc_edge(lx, ly, doc_w, doc_h)
                        if edge < 2:
                            pr, pg, pb = lerp_rgb(VIOLET_LIGHT, (255, 255, 255), 0.35)
                        elif ly < doc_h * 0.17:
                            pr, pg, pb = VIOLET
                        elif ly < doc_h * 0.22:
                            pr, pg, pb = lerp_rgb(VIOLET_LIGHT, (200, 196, 220), 0.55)
                        elif int((ly - doc_h * 0.22) / (doc_h * 0.1)) % 2 == 0:
                            pr, pg, pb = (72, 68, 92)
                        else:
                            pr, pg, pb = (54, 50, 72)
                else:
                    pr, pg, pb = BG_DARK

            i = (y * size + x) * 3
            buf[i], buf[i + 1], buf[i + 2] = pr, pg, pb

    return rgba_png(size, bytes(buf))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    lines = ["# BeatDeal — Propositions logo app\n"]
    for v in VARIANTS:
        path = OUT / f"{v.slug}.png"
        path.write_bytes(draw_variant(v.slug))
        lines.append(f"## {v.title}\n\n{v.description}\n\n![{v.title}]({v.slug}.png)\n")
        print(f"OK {path.name} — {v.title}")

    (OUT / "README.md").write_text("\n".join(lines), encoding="utf-8")
    print(f"\nPreviews dans {OUT}")


if __name__ == "__main__":
    main()
