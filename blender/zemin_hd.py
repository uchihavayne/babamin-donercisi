"""DUKKAN ZEMINI — remake HD ton dokulari (sistem Python + numpy + PIL).

    python blender/zemin_hd.py

art.js bakeBG zemin seridi (floorY 258 .. 270, 480 genis): sehrin zeminTip'ine
gore ahsap / beton / dama / mermer. Renk sehir paletinden (TEMA.zemin, 4 ton)
geldigi icin doku RENK degil PALET INDEKSI tasir: R = 1 - i/3 (i 0 acik .. 3 koyu).
Oyun shaders/ton.gdshader PALET kipiyle 4x1 sehir paletini uygular.
Cikti: assets/remake/zemin/<tip>.png  (960x24)
"""
import os
import numpy as np
from PIL import Image

KOK = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HEDEF = os.path.join(KOK, "assets", "remake", "zemin")
W, H = 960, 24


def hash1(v):
    r = np.sin(np.asarray(v, dtype=np.float64) * 127.1) * 43758.5453
    return r - np.floor(r)


def kaydet(idx, ad):
    idx = np.clip(idx, 0, 3).astype(np.float32)
    r = (1.0 - idx / 3.0) * 255.0 + 0.5
    a = np.zeros((H, W, 4), np.uint8)
    a[..., 0] = r.astype(np.uint8)
    a[..., 3] = 255
    Image.fromarray(a, "RGBA").save(os.path.join(HEDEF, ad + ".png"))


def ahsap():
    rng = np.random.default_rng(3)
    idx = np.full((H, W), 2, np.int32)
    yy, xx = np.mgrid[0:H, 0:W]
    # tahta damari: yatay kesik cizgiler
    for _ in range(170):
        x0, y0 = rng.integers(0, W), rng.integers(4, H)
        uz = rng.integers(8, 30)
        idx[y0, x0:x0 + uz] = 1 if rng.random() < 0.5 else 3
    # budak
    for _ in range(9):
        cx, cy = rng.integers(10, W - 10), rng.integers(8, H - 4)
        m = ((xx - cx) / 3.2) ** 2 + ((yy - cy) / 1.6) ** 2 < 1
        idx[m] = 3
    fx = -6
    while fx < 480:
        sxx = fx + int(np.floor(hash1(fx) * 4.0))
        X = sxx * 2
        if 0 <= X < W:
            idx[:, X:X + 2] = 3
            if X + 2 < W:
                idx[:, X + 2] = 1
        fx += 17
    idx[0:2, :] = 1
    return idx


def beton():
    rng = np.random.default_rng(5)
    idx = np.full((H, W), 1, np.int32)
    bx = -4
    while bx < 480:
        X = bx * 2
        if 0 <= X < W:
            idx[:, max(0, X):X + 2] = 2
        bx += 29
    yy, xx = np.mgrid[0:H, 0:W]
    for by in range(5, 12, 7):
        idx[by * 2, (xx[0] % 2 == 0)] = 3
    for bs in range(520):
        sx = int(np.floor(hash1(bs * 3.7) * W))
        sy = int(np.floor(hash1(bs * 8.1) * H))
        idx[sy, sx] = 0 if hash1(bs) > 0.5 else 3
    return idx


def dama():
    yy, xx = np.mgrid[0:H, 0:W]
    kare = ((xx // 2 + 8) // 16 + (yy // 2) // 8) % 2
    idx = np.where(kare == 1, 0, 2).astype(np.int32)
    idx[(yy % 16 == 0) & (xx % 2 == 0)] = 3
    return idx


def mermer():
    rng = np.random.default_rng(9)
    idx = np.zeros((H, W), np.int32)
    mx = -10
    while mx < 480:
        X = mx * 2
        if 0 <= X < W:
            idx[:, max(0, X):X + 2] = 2
        for md in range(3):
            vx = (mx + 6 + md * 11) * 2
            for y in range(2, H, 1):
                x = int(vx + (y / H) * (10 - md * 6) + np.sin(y * 0.7 + md) * 1.2)
                if 0 <= x < W and rng.random() < 0.8:
                    idx[y, x] = 3
        mx += 38
    idx[0:2, :] = 1
    return idx


def main():
    os.makedirs(HEDEF, exist_ok=True)
    for ad, fn in (("ahsap", ahsap), ("beton", beton), ("dama", dama), ("mermer", mermer)):
        kaydet(fn(), ad)
    print("ZEMIN HD: 4 doku ->", HEDEF)


if __name__ == "__main__":
    main()
