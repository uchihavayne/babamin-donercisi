"""DONER ISITICISI — remake HD (art.js drawSpit: isitici paneli, kor elemanlar,
sicak isik, isi dalgalanmasi).

    blender --background --factory-startup --python blender/models/isitici_hd.py [-- ad ...]
    python blender/hd_atlas.py isitici_hd isitici

Oyunda: hx = cx + 19, hy = top + 2, hw 17, hh = H0 - 14 (96); 6 eleman,
seg = floor((hh - 8) / 6) = 14, eleman (hx + 3, hy + 4 + i*seg, 11, 11).
  isitici_govde   capa (hx, hy): metal kasa + koyu ic + 6 seramik yuva
  eleman_taban    capa eleman sol ustu: koyu kizil petekli seramik (sabit)
  eleman_kor      ayni capa: parlak kor (oyunda alfa 0.3+0.4*fl ile titrer)
  eleman_oz       ayni capa: sari cekirdek (alfa 0.25+0.3*fl)
  sicak_isik      capa (cx - 4, top): isiticiya dogru artan sicak isik (26 x H0)
"""
import sys, os, math, json
import bpy
import numpy as np

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import durum_hd as D
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "isitici_hd")
HD = 2
PARCALAR, KOKEN = {}, {}
HW, HH, SEG, EW, EH = 17, 96, 14, 11, 11
H0 = 110
MT = ["#41474f", "#5f6672", "#878e99", "#aeb5be", "#d3d8de", "#f2f4f6"]


def parca(ad, tuval, fn, tur="3b", cizgi=None):
    PARCALAR[ad] = (tuval, fn, tur, cizgi)
    KOKEN[ad] = (tuval[0], tuval[1])


def govde():
    """Metal kasa: pahli cerceve, ici koyu, alti/ustu havalandirma yariklari."""
    Mm = I.cel("Kasa", MT[1:], [0, .28, .52, .76, .94])
    Mk = I.cel("Ic", ["#140a06", "#1f130c", "#2e1d12"], [0, .5, .9])
    # dis kasa (19 x 98) ve ic bosluk
    L.levha("kasa", HW + 2.0, HH + 2.0, 1.6, (HW) / 2.0, -(HH) / 2.0, 0.0, 1.4, 0.35, Mm)
    L.levha("ic", HW - 4.0, HH - 4.0, 0.8, HW / 2.0, -HH / 2.0, -0.9, 0.6, 0.15, Mk)
    # seramik yuvalari: her elemanin arkasinda koyu kizil cukur
    Mz = I.cel("Yuva", ["#3a0c05", "#5a1406", "#6d1a08"], [0, .5, .9])
    for i in range(6):
        ey = 4 + i * SEG
        L.levha("yuva%d" % i, EW + 0.6, EH + 0.6, 0.8, 3 + EW / 2.0, -(ey + EH / 2.0), -1.1, 0.4, 0.1, Mz)
    # ust/alt havalandirma yariklari
    Mv = px.flat("Yarik", "#2a2f36")
    for gy in (1.2, HH - 1.8):
        for k in range(4):
            x0 = 3.0 + k * 3.2
            L.kutu("yarik", x0, x0 + 2.0, -gy - 0.5, -gy + 0.1, -1.0, -0.6, Mv)
    # vidalar
    Mv2 = I.cel("Vida", MT[2:], [0, .4, .75, .95])
    for gx in (1.4, HW - 1.4):
        for gy in (2.0, HH - 2.0):
            L.disk("vida", 0.6, gx, -gy, -1.05, 0.3, 0.1, Mv2)


def _petek(w, h, ofs=0.0):
    """Seramik kizilotesi eleman peteklerinin maskesi (HD piksel)."""
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    sat = np.floor(yy / 3.0)
    x2 = xx + (sat % 2) * 1.5 + ofs
    delik = ((np.mod(x2, 3.0) < 1.0) & (np.mod(yy, 3.0) < 1.0))
    return delik


def eleman(tur):
    def fn():
        w, h = EW * HD, EH * HD
        a = np.zeros((h, w, 4), np.float32)
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32) + 0.5
        # yuvarlatilmis kose maskesi
        kx = np.minimum(xx, w - xx)
        ky = np.minimum(yy, h - yy)
        kose = ~((kx < 1.6) & (ky < 1.6))
        delik = _petek(w, h)
        mx = (xx - w / 2.0) / (w / 2.0)
        my = (yy - h / 2.0) / (h / 2.0)
        merkez = np.clip(1.0 - (mx * mx + my * my) * 0.55, 0, 1)
        if tur == "taban":
            col = np.where(delik[..., None], S.rgb("#5c1206"), S.rgb("#c8380f"))
            ust = (yy < 2.0)[..., None]
            col = np.where(ust, S.rgb("#e0500f"), col)
            a[..., :3] = col
            a[..., 3] = kose * 1.0
        elif tur == "kor":
            col = np.where(delik[..., None], S.rgb("#d4480c"), S.rgb("#ff9c2e"))
            a[..., :3] = col
            a[..., 3] = kose * (0.55 + 0.45 * merkez)
        else:                                          # oz: sari cekirdek
            col = np.where(delik[..., None], S.rgb("#ffb040"), S.rgb("#ffe08a"))
            a[..., :3] = col
            a[..., 3] = kose * np.clip(merkez * 1.4 - 0.25, 0, 1) * (1.0 - delik * 0.5)
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


def sicak_isik():
    """Eski: 26 x H0 duz turuncu dikdortgen (alfa ~.1). HD: isiticiya (saga)
    dogru artan, ust/alt uclari yumusak sicak isik; alfa oyunda carpilir."""
    def fn():
        w, h = 26 * HD, H0 * HD
        a = np.zeros((h, w, 4), np.float32)
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32) + 0.5
        u = xx / w
        v = yy / h
        yatay = np.clip(u * 1.35, 0, 1) ** 1.6
        dikey = np.clip(v / 0.12, 0, 1) * np.clip((1.0 - v) / 0.18, 0, 1)
        a[..., :3] = S.rgb("#ff8a2a")
        a[..., 3] = np.clip(yatay * dikey * 1.6, 0, 1)
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


parca("isitici_govde", (-1, -1, HW + 2, HH + 2), govde, cizgi="#1c1f24")
parca("eleman_taban", (0, 0, EW, EH), eleman("taban"), tur="np")
parca("eleman_kor", (0, 0, EW, EH), eleman("kor"), tur="np")
parca("eleman_oz", (0, 0, EW, EH), eleman("oz"), tur="np")
parca("sicak_isik", (0, 0, 26, H0), sicak_isik(), tur="np")


def uret(ad):
    (gx0, gy0, w, h), fn, tur, cizgi = PARCALAR[ad]
    yol = os.path.join(OUT, ad + ".png")
    if tur == "np":
        px.reset()
        return px.write_png(fn(), yol)
    D.sahne(gx0, gy0, w, h, 1.0)
    S._MAT.clear()
    fn()
    px.render(yol)
    if cizgi:
        px.outline(yol, hexcol=cizgi, alpha=120)
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = [a for a in PARCALAR if not argv or any(a.startswith(x) for x in argv)]
    for ad in adlar:
        uret(ad)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR), "kokenler": {k: list(v) for k, v in KOKEN.items()},
                   "kirpma": False}, fp, indent=1)
    print("ISITICI_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
