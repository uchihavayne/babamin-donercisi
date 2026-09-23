"""GAZETE (arma, susleme, kagit), ONAY/CARPI IKONU, MOTO ROZETI — remake HD.

    blender --background --factory-startup --python blender/models/ufak_hd.py [-- ad ...]
    python blender/hd_atlas.py ufak_hd ufak

  arma        gazete basligindaki kartal armasi (ui.js gazeteArma), capa (cx, cy)
  susleme     baslik yanindaki kivrim (gazeteSusleme), capa (x, y); sag taraf ayna
  kagit       304x16 dikey TEKRARLANABILIR gazete kagidi dokusu (lif + leke)
  onay/carpi  siparis balonundaki tik / carpi (beyaz; oyunda modulate renk)
  moto_ikon   "BOZUK" rozetindeki kucuk motosiklet
"""
import sys, os, math, json
import bpy, bmesh
import numpy as np
from mathutils import Matrix

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "ufak_hd")
HD = 2
PARCALAR, KOKEN = {}, {}
MUREKKEP = "#1e1a14"
KREM = "#e6dcbe"


def parca(ad, tuval, fn, cizgi=None, cizgi_alfa=110, tur="3b"):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa, tur)
    KOKEN[ad] = (tuval[0], tuval[1])


def hash1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


def duz(ad, renk):
    return px.flat(ad + renk, renk)


def sekil(ad, pts, mat, y=0.0, derin=0.6, bevel=0.0):
    """Ekran duzleminde poligon: pts (gx, gy) oyun pikseli, gy asagi."""
    return L.cokgen(ad, [(x, -g) for x, g in pts], 0.0, 0.0, y, derin, bevel, mat)


# ================================================================ gazete armasi
def arma():
    """Kanatlarini acmis kartal: eski cizimdeki 5 sirali kanat ayni yerde,
    HD'de tuyler ince ve sivri, bas/gaga ayri, tepede yildiz."""
    M = duz("Murekkep", MUREKKEP)
    Mk = duz("Krem", KREM)
    # kanat: eski cizimdeki 5 sirali basamak yerine TEK siluet (ayni sinirlar),
    # tuy ayrimlari krem kazima cizgisi
    for yon in (-1, 1):
        ic = yon * 4.6
        sekil("kanat%d" % yon, [(ic, 3.2), (yon * 10.0, 3.2), (yon * 22.4, 11.4),
                                (yon * 22.4, 13.2), (ic, 13.2)], M, bevel=0.2)
        # tek ince tuy kazimasi: 2x'te daha fazlasi kanadi cizgili gosteriyor
        sekil("tuycizgi%d" % yon, [(ic - yon * 0.8, 9.4), (yon * 17.4, 12.0),
                                   (yon * 17.4, 11.5), (ic - yon * 0.8, 8.9)], Mk, y=-0.5, derin=0.4)
    # govde + kuyruk
    sekil("govde", [(-3.0, 2.0), (3.0, 2.0), (2.2, 9.4), (-2.2, 9.4)], M, bevel=0.3)
    sekil("kuyruk", [(-2.0, 9.2), (2.0, 9.2), (1.1, 13.0), (-1.1, 13.0)], M, bevel=0.15)
    for d in (-1, 1):
        sekil("pence%d" % d, [(d * 0.5, 12.6), (d * 2.6, 12.4), (d * 2.2, 13.4), (d * 0.5, 13.4)], M, bevel=0.1)
    # bas + gaga (govdeden ince boyunla ayri)
    sekil("boyun", [(-1.2, 1.2), (1.2, 1.2), (1.4, 2.6), (-1.4, 2.6)], M)
    L.disk("bas", 1.9, 0.0, 0.2, 0.0, 0.6, 0.12, M)
    sekil("gaga", [(1.4, -0.4), (4.2, 0.5), (1.4, 1.5)], M, bevel=0.2)
    # tepede kucuk taç (yildiz 2x'te okunmuyordu)
    sekil("tac", [(-1.5, -1.2), (1.5, -1.2), (0.9, -3.0), (0.0, -2.2), (-0.9, -3.0)], M, bevel=0.2)
    # krem gogus kalkani + goz
    sekil("kalkan", [(-1.9, 3.6), (1.9, 3.6), (1.5, 6.2), (0.0, 7.4), (-1.5, 6.2)], Mk, y=-0.5, derin=0.4)
    sekil("goz", [(0.5, -0.4), (1.3, -0.4), (1.3, 0.4), (0.5, 0.4)], Mk, y=-0.5, derin=0.4)


def susleme():
    """Baslik yanindaki kivrim: incelen dal + tek yaprak + uc noktasi."""
    M = duz("Murekkep2", "#2a251c")
    ust = [(-1.0, -0.9), (4.0, -1.6), (8.0, -2.6), (10.8, -3.6)]
    alt = [(10.8, -2.9), (8.0, -1.6), (4.0, -0.4), (-1.0, 0.5)]
    sekil("dal", ust + alt, M, bevel=0.12)
    sekil("yaprak", [(3.4, -1.5), (5.2, -4.4), (7.0, -3.2), (5.4, -1.0)], M, bevel=0.3)
    L.disk("uc", 0.9, 11.6, 3.9, 0.0, 0.6, 0.25, M)
    L.disk("dugum", 1.5, -1.6, 0.0, 0.0, 0.6, 0.4, M)


# ================================================================ gazete kagidi
def kagit():
    """304x16 dikey tekrarlanabilir eskimis kagit: lif + benek + hafif leke."""
    W, H = 304, 16

    def fn():
        w, h = W * HD, H * HD
        a = np.zeros((h, w, 4), np.float32)
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
        taban = S.rgb(KREM)
        col = np.repeat(taban[None, None, :], h, 0).repeat(w, 1)
        # yatay lifler (dikeyde tekrarlanabilir: sin donemleri h'nin tam kati)
        lif = (np.sin(yy * (2 * math.pi * 6 / h)) * 0.5 + np.sin(xx * 0.31 + yy * 0.11) * 0.5)
        col *= (1.0 + lif[..., None] * 0.012)
        rng = np.random.default_rng(11)
        benek = rng.random((h, w))
        col *= (1.0 - (benek > 0.9965)[..., None] * 0.22)
        col *= (1.0 + (benek < 0.002)[..., None] * 0.05)
        # kenarlarda hafif sararma (sol/sag)
        kn = np.clip(np.minimum(xx, w - 1 - xx) / 26.0, 0, 1)
        sarar = (1.0 - kn) * 0.07
        col[..., 0] *= (1.0 - sarar * 0.2)
        col[..., 1] *= (1.0 - sarar * 0.5)
        col[..., 2] *= (1.0 - sarar * 1.0)
        a[..., :3] = np.clip(col, 0, 1)
        a[..., 3] = 1.0
        return (a * 255 + 0.5).astype(np.uint8)
    return fn


# ================================================================ ikonlar
def onay():
    """Tik: beyaz, oyunda modulate renkle basiliyor (drawCheck ile ayni yer)."""
    M = duz("Beyaz", "#ffffff")
    sekil("tik", [(-3.4, 0.2), (-1.2, 2.6), (3.4, -2.4), (3.4, -0.9), (-1.1, 3.6), (-3.4, 1.4)], M, bevel=0.22)


def carpi():
    M = duz("Beyaz", "#ffffff")
    for d in (-1, 1):
        sekil("kol%d" % d, [(-3.4 * d, -3.0), (-2.2 * d, -3.4), (3.4 * d, 2.6), (2.4 * d, 3.2)], M, bevel=0.22)


def moto_ikon():
    """Rozetteki kucuk motosiklet: iki teker, sase, gidon."""
    Mg = I.cel("MotoIkon", ["#5a636b", "#8b959d", "#c7ced5", "#eef3f7"], [0, .35, .7, .95])
    Md = duz("Lastik", "#22262a")
    for cx in (-4.0, 4.5):
        L.halka("teker", 2.6, 2.6, 0.75, cx, -6.0, 0.0, Md)
        L.disk("jant", 1.2, cx, -6.0, 0.2, 0.3, 0.1, Mg)
    sekil("sase", [(-4.0, 6.0), (-1.0, 3.2), (3.0, 3.2), (4.5, 6.0), (3.0, 5.2), (-1.0, 5.0)], Mg, derin=0.8, bevel=0.2)
    sekil("sele", [(-3.4, 3.0), (-0.4, 2.6), (-0.4, 3.6), (-3.4, 3.8)], Mg, derin=0.8, bevel=0.2)
    sekil("gidon", [(3.0, 3.2), (4.0, 1.2), (6.0, 1.0), (6.0, 2.0), (4.6, 2.2), (4.0, 3.4)], Mg, derin=0.6, bevel=0.15)


# ================================================================ kayit
parca("arma", (-16, -6, 32, 21), arma, cizgi=None)
parca("susleme", (-3, -5, 16, 10), susleme, cizgi=None)
parca("kagit", (0, 0, 304, 16), kagit(), tur="np")
parca("onay", (-5, -5, 10, 10), onay, cizgi=None)
parca("carpi", (-5, -5, 10, 10), carpi, cizgi=None)
parca("moto_ikon", (-8, -10, 17, 19), moto_ikon, cizgi="#13161a", cizgi_alfa=120)


# ================================================================ HUD hava rozeti (ui.js drawHUD)
# capa: rozetin (wx, wy) noktasi; eski bulut ell(wx+6, wy+4, 5, 3) + ell(wx+10, wy+3, 4, 3)
def hava_bulut(kar):
    def fn():
        ton = ["#8e9fb2", "#b7c6d6", "#d6e2ee", "#f2f7fc"] if kar else ["#6f8196", "#98abc0", "#c6d4e2", "#e2ecf6"]
        M = I.cel("Bulut%d" % kar, ton, [0, .3, .62, .9])
        for gx, gy, rx, ry in ((5.2, 4.8, 4.2, 2.8), (9.6, 3.4, 3.9, 3.2), (12.4, 5.0, 2.8, 2.2), (7.4, 2.6, 2.6, 2.4)):
            e = I.elipsoid("b", gx, gy, rx, ry, 2.4, 0.0, M, seg=18, ring=10)
            e.location = (gx, 0.0, -gy)
    return fn


def hava_gunes():
    Mg = I.cel("Gunes", ["#e08a1a", "#ffb23c", "#ffd257", "#fff2a8"], [0, .3, .62, .9])
    e = I.elipsoid("gunes", 0.0, 0.0, 4.0, 4.0, 2.2, 0.0, Mg, seg=24, ring=14)
    e.location = (0.0, 0.0, 0.0)


def hava_damla():
    """Yagmur damlasi (1x2 mantik): ustu sivri, alti yuvarlak, mavi."""
    a = np.zeros((4, 2, 4), np.float32)
    for (y, x), (renk, al) in {(0, 1): ("#8fb8e0", 0.55), (1, 0): ("#8fb8e0", 0.8), (1, 1): ("#8fb8e0", 0.9),
                               (2, 0): ("#6b9ad8", 1.0), (2, 1): ("#b8d4f0", 1.0),
                               (3, 0): ("#4f7fc0", 1.0), (3, 1): ("#6b9ad8", 1.0)}.items():
        a[y, x, :3] = S.rgb(renk)
        a[y, x, 3] = al
    return (a * 255 + 0.5).astype(np.uint8)


def hava_isin():
    """Gunes isini noktasi: 2x2 cekirdek + yumusak kose (3x3 HD, mantik 1.5)."""
    a = np.zeros((4, 4, 4), np.float32)
    for y in range(4):
        for x in range(4):
            d = math.hypot(x - 1.5, y - 1.5)
            a[y, x, :3] = S.rgb("#ffb23c") if d > 0.8 else S.rgb("#ffe08a")
            a[y, x, 3] = max(0.0, 1.0 - max(0.0, d - 0.75) * 0.9)
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


parca("hava_bulut", (0, -1, 17, 10), hava_bulut(0), cizgi="#3a4a5e", cizgi_alfa=120)
parca("hava_bulut_kar", (0, -1, 17, 10), hava_bulut(1), cizgi="#4a5a6e", cizgi_alfa=110)
parca("hava_gunes", (-5, -5, 10, 10), hava_gunes, cizgi="#8a4a0a", cizgi_alfa=120)
parca("hava_damla", (0, 0, 1, 2), hava_damla, tur="np")
parca("hava_isin", (-1, -1, 2, 2), hava_isin, tur="np")


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, tur = PARCALAR[ad]
    yol = os.path.join(OUT, ad + ".png")
    if tur == "np":
        px.reset()
        return px.write_png(fn(), yol)
    D.sahne(gx0, gy0, w, h, 1.0)
    S._MAT.clear()
    L._FONTLAR.clear()
    fn()
    px.render(yol)                       # ekran duzlemi: egme yok
    if cizgi:
        px.outline(yol, hexcol=cizgi, alpha=cizgi_alfa)
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = [a for a in PARCALAR if not argv or any(a.startswith(x) for x in argv)]
    for ad in adlar:
        uret(ad)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR), "kokenler": {k: list(v) for k, v in KOKEN.items()}}, fp, indent=1)
    print("UFAK_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
