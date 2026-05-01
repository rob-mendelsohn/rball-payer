#!/usr/bin/env python3
"""
Generate PWA + favicon PNG/ICO assets for Spark Racquetball.

Requirements:
    pip install Pillow

Outputs (written to the same directory as this script):
    icon-512.png, icon-192.png, apple-touch-icon.png, favicon.ico
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont

# ── Brand colours ─────────────────────────────────────────────────────────────
GREEN     = (26,  71,  42)   # #1a472a
GOLD      = (232, 184, 75)   # #e8b84b
GOLD_TR   = (232, 184, 75, 108)  # semi-transparent for strings
WHITE     = (255, 255, 255)
SHADOW    = (0,   0,   0,   140)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def _clip_strings(img: Image.Image, cx, cy, rx, ry) -> None:
    """Draw racquet strings clipped to the head ellipse."""
    strings = Image.new('RGBA', img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(strings)
    lw = max(2, int(img.width * 0.011))

    # 6 horizontal strings
    ya, yb = cy - ry * 0.88, cy + ry * 0.88
    for i in range(6):
        y = ya + i * (yb - ya) / 5
        sd.line([(cx - rx * 1.2, y), (cx + rx * 1.2, y)], fill=GOLD_TR, width=lw)

    # 4 vertical strings
    xa, xb = cx - rx * 0.73, cx + rx * 0.73
    for i in range(4):
        x = xa + i * (xb - xa) / 3
        sd.line([(x, cy - ry * 1.2), (x, cy + ry * 1.2)], fill=GOLD_TR, width=lw)

    # Ellipse clip mask
    mask = Image.new('L', img.size, 0)
    ImageDraw.Draw(mask).ellipse(
        [cx - rx, cy - ry, cx + rx, cy + ry], fill=255)
    img.paste(strings, (0, 0), mask)


def draw_icon(size: int) -> Image.Image:
    """Render the icon at *size*×*size* using 3× supersampling."""
    ss = 3
    w = h = size * ss

    img = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── Racquet geometry ──────────────────────────────────────────────────────
    cx      = w * 0.500
    head_cy = h * 0.375
    head_rx = w * 0.213
    head_ry = h * 0.252

    # ── Full green background (maskable-safe for PWA) ─────────────────────────
    draw.rectangle([0, 0, w, h], fill=(*GREEN, 255))

    # ── Strings (clipped to head) ─────────────────────────────────────────────
    _clip_strings(img, cx, head_cy, head_rx, head_ry)
    draw = ImageDraw.Draw(img)  # re-acquire after paste

    # ── Head outline ──────────────────────────────────────────────────────────
    bw = max(4, int(w * 0.030))
    draw.ellipse(
        [cx - head_rx, head_cy - head_ry, cx + head_rx, head_cy + head_ry],
        outline=(*GOLD, 255), width=bw)

    # ── Handle (rounded rectangle) ────────────────────────────────────────────
    hw  = int(w * 0.085)
    hh  = int(h * 0.260)
    hx1 = int(cx - hw / 2)
    hy1 = int(head_cy + head_ry - bw * 0.5)
    hr  = int(hw * 0.30)
    try:
        draw.rounded_rectangle([hx1, hy1, hx1 + hw, hy1 + hh],
                               radius=hr, fill=(*GOLD, 255))
    except AttributeError:  # Pillow < 8.2
        draw.rectangle([hx1, hy1, hx1 + hw, hy1 + hh], fill=(*GOLD, 255))

    # ── Dollar sign ───────────────────────────────────────────────────────────
    font_size = int(w * 0.340)
    font = None
    for fp in [
        'C:/Windows/Fonts/ariblk.ttf',     # Arial Black
        'C:/Windows/Fonts/arialbd.ttf',    # Arial Bold
        '/System/Library/Fonts/Arial Bold.ttf',
        '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
        '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
    ]:
        try:
            font = ImageFont.truetype(fp, font_size)
            break
        except (OSError, IOError):
            continue
    if font is None:
        font = ImageFont.load_default()

    sf = ImageDraw.Draw(img)  # same draw object
    text = '$'
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    tx = int(cx - tw / 2 - bbox[0])
    ty = int(head_cy - th / 2 - bbox[1])

    off = int(w * 0.006)
    draw.text((tx + off, ty + off), text, fill=SHADOW,            font=font)
    draw.text((tx,       ty),       text, fill=(*WHITE, 248),     font=font)

    # ── Downsample ────────────────────────────────────────────────────────────
    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    outputs = [
        (512, 'icon-512.png'),
        (192, 'icon-192.png'),
        (180, 'apple-touch-icon.png'),
        (32,  '_fav32.png'),
        (16,  '_fav16.png'),
    ]

    imgs: dict[int, Image.Image] = {}
    for sz, name in outputs:
        print(f'Generating {name} ({sz}×{sz})…', end='', flush=True)
        pil = draw_icon(sz)
        imgs[sz] = pil
        path = os.path.join(SCRIPT_DIR, name)
        pil.save(path)
        print(f' -> {path}')

    # favicon.ico (32×32 + 16×16 embedded)
    ico_path = os.path.join(SCRIPT_DIR, 'favicon.ico')
    imgs[32].save(ico_path, format='ICO',
                  sizes=[(32, 32), (16, 16)],
                  append_images=[imgs[16]])
    print(f'Saved {ico_path}')

    # Clean up temp files
    for sz, name in outputs:
        if name.startswith('_'):
            os.remove(os.path.join(SCRIPT_DIR, name))

    print('\nAll icon assets generated successfully.')


if __name__ == '__main__':
    main()
