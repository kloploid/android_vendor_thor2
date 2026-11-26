#!/usr/bin/env python3
"""Builds bootanimation.zip in the Nine look: black, "nine" typed by a monospace cursor, then the
cursor blinking until the system is up; the hint bar at the bottom says "starting…".

    python3 make.py /path/to/DroidSansMono.ttf   (the phone's monospace: /system/fonts)

Needs Pillow. Writes bootanimation.zip next to this script (stored, not compressed, as the boot
animation player requires).
"""
import io
import os
import sys
import zipfile

from PIL import Image, ImageDraw, ImageFont

W, H, FPS = 480, 800, 10
BLACK, WHITE = (0, 0, 0), (255, 255, 255)
GRAY_DIM, GRAY_MUTED, DIVIDER = (0x8A, 0x8A, 0x8A), (0x66, 0x66, 0x66), (0x26, 0x26, 0x26)
WORD = "nine"


def frame(font, hint_font, text, cursor):
    img = Image.new("RGB", (W, H), BLACK)
    d = ImageDraw.Draw(img)
    char_w = font.getlength("n")
    ascent, descent = font.getmetrics()
    x0 = (W - char_w * (len(WORD) + 1)) / 2  # the word and its cursor, centered
    y0 = H * 0.42 - ascent / 2
    d.text((x0, y0), text, font=font, fill=WHITE)
    if cursor:
        cx = x0 + char_w * len(text)
        top = y0 + ascent * 0.18
        d.rectangle([cx + 2, top, cx + char_w * 0.62, y0 + ascent], fill=GRAY_DIM)
    # The hint bar, as on every Nine screen: a hairline and a muted line of text.
    bar = H - 36
    d.line([(0, bar), (W, bar)], fill=DIVIDER, width=1)
    d.text((22, bar + 9), "starting…", font=hint_font, fill=GRAY_MUTED)
    out = io.BytesIO()
    img.save(out, "PNG", optimize=True)
    return out.getvalue()


def main():
    font_path = sys.argv[1]
    font = ImageFont.truetype(font_path, 72)
    hint_font = ImageFont.truetype(font_path, 15)
    # part0, once: the cursor blinks twice, then types the word.
    part0 = [("", True)] * 3 + [("", False)] * 3 + [("", True)] * 3 + [("", False)] * 2
    for i in range(1, len(WORD) + 1):
        part0 += [(WORD[:i], True)] * (2 if i < len(WORD) else 4)
    # part1, until the system is up: the word, the cursor blinking once a second.
    part1 = [(WORD, True)] * 5 + [(WORD, False)] * 5
    target = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bootanimation.zip")
    with zipfile.ZipFile(target, "w", zipfile.ZIP_STORED) as z:
        z.writestr("desc.txt", "%d %d %d\np 1 0 part0\np 0 0 part1\n" % (W, H, FPS))
        for name, frames in (("part0", part0), ("part1", part1)):
            for i, (text, cursor) in enumerate(frames):
                z.writestr("%s/%03d.png" % (name, i), frame(font, hint_font, text, cursor))
    print("%s: %d + %d frames, %d bytes" % (target, len(part0), len(part1), os.path.getsize(target)))


if __name__ == "__main__":
    main()
