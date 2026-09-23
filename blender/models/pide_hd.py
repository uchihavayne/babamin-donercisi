"""ISKENDER PIDE TAHTASI — remake HD (food.js drawPideBoard, pideSerit, pideKup, pideBicak).

    blender --background --factory-startup --python blender/models/pide_hd.py [-- ad ...]
    python blender/hd_atlas.py pide_hd pide

Pide PIDE_NEED + 1 = 5 dilime bolunur; kesilen dilimler 2 sira kup olur, kesilmeyen
dilim ekmek kalibi olarak kalir. Tahta ctx.scale icinde de cizildigi icin (servis
tahtasi 1 / .74 / .58, elde .85) her parca 4 olcekte render edilir.
  pide_serit_<q>_<o>   q 0..4, capa (cx, cy)  (taban = cy + 6)
  pide_kup_<q>_<o>     kesilmis dilimin kupleri
  pide_bicak_<o>       capa (bicak x, agiz y)
"""
import sys, os, math, json
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "pide_hd")
HD = 2
K = S.K
ez = T.ez
kutu = S.kutu
PIDE_NEED, PIDE_KAL, PIDE_DER = 4, 5.2, 3.4
OLCEK = (1.0, 0.85, 0.74, 0.58)
PARCALAR, KOKEN, OLCEKLER = {}, {}, {}


def hash1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


def serit(q):
    seg = PIDE_NEED + 1
    rx = 24.0
    u = (q + 0.5) / seg - 0.5
    kk = abs(u * 2)
    d = PIDE_DER * math.sqrt(max(0.1, 1 - kk * kk * 0.8))
    h = PIDE_KAL * (0.78 + 0.22 * math.sqrt(max(0.0, 1 - kk * kk)))
    return {"L": math.floor(-rx + q * (rx * 2 / seg) + 0.5), "R": math.floor(-rx + (q + 1) * (rx * 2 / seg) + 0.5),
            "d": d, "h": max(2.0, math.floor(h + 0.5)), "geri": math.floor(h + d * 2 + 0.5)}


def ekmek():
    return I.cel("Pide", ["#5e3a12", "#7a4f22", "#a8762e", "#dcae55", "#f0cd94"], [0, .22, .5, .66, .88], noise=0.1, noise_scale=16)


def pide_serit(q):
    def fn():
        taban = 6.0
        s = serit(q)
        sol = s["L"] + (1 if q == 0 else 0)
        sag = s["R"] - (1 if q == PIDE_NEED else 0)
        derin = (s["geri"] - s["h"]) / K
        uc = q in (0, PIDE_NEED)
        kutu(sol, sag, taban - s["h"], taban, 0.0, derin, ekmek(), bevel=1.1 if uc else 0.5)
        # kazima cizgisi ve susam
        Mc = S.mat_duz("#b8842c")
        bx = s["L"] + 2 + math.floor(hash1(q * 5.3) * (s["R"] - s["L"] - 6) + 0.5)
        T.ust_cizgi("kazi", bx, taban - s["h"] - 1.0, bx + 2.0, taban - s["h"] - 1.3, 0.5, ez(taban - s["h"], 0.0, K) + 0.05, Mc, K)
        for k in range(3):
            sx = s["L"] + 1.5 + hash1(q * 9.1 + k) * (s["R"] - s["L"] - 3)
            sg = taban - s["h"] - 0.5 - hash1(q * 3.7 + k * 2.3) * (s["geri"] - s["h"] - 1)
            e = I.elipsoid("susam", sx, sg, 0.5, 0.3, 0.3, 0.0, S.mat_duz("#fce7bd"), seg=6, ring=4)
            e.location = (sx, (-(sg) - ez(taban - s["h"], 0.0, K)) / K + 0.0, ez(taban - s["h"], 0.0, K) + 0.15)
    return fn


def pide_kup(q):
    def fn():
        taban = 6.0
        s = serit(q)
        Mk = I.cel("Kup%d" % q, ["#6a4418", "#8a5f2a", "#b8842c", "#e8bd72", "#f6dfa8"], [0, .22, .5, .66, .88], noise=0.08, noise_scale=20)
        for b in (1, 0):
            for a in range(3):
                hs = hash1(q * 13.7 + a * 3.1 + b * 7.7)
                kx = s["L"] + 1 + a * 3 + (1 if b else 0)
                if kx + 3 > s["R"]:
                    continue
                y = taban - b * 4 - math.floor(hs * 1.4 + 0.5)
                kutu(kx, kx + 3, y - 3, y, b * 2.0, b * 2.0 + 4.0, Mk, bevel=0.35)
    return fn


def pide_bicak():
    Ms = I.cel("PBicak", ["#6d7a86", "#aab4bd", "#dfe6ec", "#ffffff"], [0, .3, .62, .9])
    pts = []
    for r in (0, 9):
        ww = 4 + math.floor(4 * r / 9 + 0.5)
        x0 = -ww + 2 + math.floor((9 - r) * 0.18 + 0.5)
        pts.append((x0, -10 + r, x0 + ww))
    poli = [(pts[0][0], pts[0][1]), (pts[0][2], pts[0][1]), (pts[1][2], pts[1][1] + 1), (pts[1][0] - 1, pts[1][1] + 1)]
    T.on_poligon("agiz", poli, -0.3, Ms, K, derin=0.5)
    T.on_poligon("kenar", [(-7, -0.6), (2, -0.6), (2, 0.2), (-7, 0.2)], -0.9, S.mat_duz("#ffffff"), K, derin=0.05)
    kutu(-1, 4, -12, -10, -0.6, 0.6, I.cel("PBilezik", ["#6d7a86", "#8f979f", "#c3ccd3"], [0, .45, .85]), bevel=0.3)
    Mw = I.cel("PSap", ["#3a2718", "#5a3a22", "#7a5230", "#a5733f"], [0, .3, .62, .9], noise=0.1, noise_scale=20)
    import arac_hd as A
    A.tup([(1.0, -12.2), (1.9, -15.5), (2.8, -19.0), (3.2, -20.2)], lambda t: 2.6 - 0.4 * t, 0.0, Mw, seg=12)
    e = I.elipsoid("percin", 1.5, -16, 0.6, 0.6, 0.3, -0.9, S.mat_duz("#c9a06a"), seg=8, ring=4)
    e.location = (1.5, -0.9, ez(-16, -0.9, K))


def parca(ad, tuval, fn, cizgi="#2a1a0c", cizgi_alfa=110):
    for sc in OLCEK:
        tam = "%s_%d" % (ad, int(round(sc * 100)))
        PARCALAR[tam] = (tuval, fn, cizgi, cizgi_alfa, sc)
        KOKEN[tam] = (tuval[0], tuval[1])
        OLCEKLER[tam] = sc


for _q in range(PIDE_NEED + 1):
    parca("pide_serit_%d" % _q, (-27, -10, 54, 18), pide_serit(_q), cizgi=None)
    parca("pide_kup_%d" % _q, (-27, -10, 54, 18), pide_kup(_q), cizgi="#3a2410", cizgi_alfa=60)
parca("pide_bicak", (-10, -22, 17, 24), pide_bicak)


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, sc = PARCALAR[ad]
    D.sahne(gx0, gy0, w, h, sc)
    S._MAT.clear()
    fn()
    px.shear_scene(K)
    yol = px.render(os.path.join(OUT, ad + ".png"))
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
        json.dump({"hd": HD, "katmanlar": list(PARCALAR), "kokenler": {k: list(v) for k, v in KOKEN.items()},
                   "olcekler": {k: v for k, v in OLCEKLER.items() if v != 1.0}}, fp, indent=1)
    print("PIDE_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
