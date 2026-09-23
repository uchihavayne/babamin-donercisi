"""TELEFON, DENETIM LAMBASI, GECE ESYALARI, KESINTI ISIGI — remake HD.

    blender --background --factory-startup --python blender/models/gece_hd.py [-- ad ...]
    python blender/hd_atlas.py gece_hd gece

  telefon_govde[_m]   capa ST.phone (x, y) (tuslu govde; _m muhurlu soluk)
  telefon_ahize[_m]   capa (x, hy) (ahize + kivrik kablo)
  telefon_bant        capa ST.phone (x, y) (capraz muhur bandi + mum muhur)
  denetim_govde       capa denetimLambaKutu (x, y); denetim_cam_<0|1|2> sonuk / isiniyor / yaniyor
  alarm_<0|1>         capa (108, 38) gece alarm kutusu
  kilit               capa (W/2, 112) kepenk kilidi
  fener_isik          capa hirsiz (tx, TY): fener konisi (numpy)
  kesinti_isik        capa (pcx, pcy): elektrik kesintisinde izgara kor isigi (numpy)
"""
import sys, os, math, json
import bpy, bmesh
import numpy as np
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D
import sokak_arka_hd as S
import arac_hd as A

OUT = os.path.join(_HERE, "out", "gece_hd")
HD = 2
K = S.K
ez = T.ez
kutu, elipsoid, cerceve, on_levha = S.kutu, S.elipsoid, S.cerceve, S.on_levha
mat_ton, mat_duz, hexmul = S.mat_ton, S.mat_duz, T.hexmul
PARCALAR, KOKEN = {}, {}


def parca(ad, tuval, fn, cizgi="#0e0c0a", cizgi_alfa=110, tur="3b"):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa, tur)
    KOKEN[ad] = (tuval[0], tuval[1])


def c4(renk, f=(0.62, 0.84, 1.0, 1.22)):
    return mat_ton(renk, f=f)


# ================================================================ telefon
def telefon_govde(m):
    def fn():
        g0, g1, tus, tusI = ("#2b2f36", "#3f454e", "#8a929b", "#c6ccd2") if not m else ("#24262a", "#3a3d42", "#5c6167", "#787e85")
        Mg = I.cel("TelGovde%d" % m, [hexmul(g0, .8), g0, g1, hexmul(g1, 1.35)], [0, .25, .55, .88])
        # egimli govde: tabani genis, ustu dar
        bm = bmesh.new()
        on_y, arka_y = -2.5, 3.0
        pts_on = [(2.0, 28.0), (22.0, 28.0), (21.0, 8.0), (3.0, 8.0)]
        a = [bm.verts.new((x, on_y, ez(g, on_y, K))) for x, g in pts_on]
        b = [bm.verts.new((x, arka_y, ez(g - 2.0, arka_y, K))) for x, g in pts_on]
        bm.faces.new(a)
        bm.faces.new(list(reversed(b)))
        for i in range(4):
            bm.faces.new((a[i], a[(i + 1) % 4], b[(i + 1) % 4], b[i]))
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.6, segments=2, affect="EDGES")
        I.mesh_ob("govde", bm, Mg, smooth=False)
        Mt = I.cel("Tus%d" % m, [hexmul(tus, .7), tus, tusI, "#ffffff" if not m else tusI], [0, .3, .65, .92])
        for r in range(3):
            for c in range(3):
                x0, g0_ = 6 + c * 4, 12 + r * 4
                kutu(x0, x0 + 3, g0_, g0_ + 3, -3.2, -2.4, Mt, bevel=0.4)
        kutu(5, 19, 25.0, 26.2, -2.7, -2.4, mat_duz(hexmul(g0, 0.7)))
    return fn


def telefon_ahize(m):
    def fn():
        kir, kirI = ("#c0281c", "#e2483a") if not m else ("#6a4a46", "#825a55")
        Mk = I.cel("Ahize%d" % m, [hexmul(kir, .6), hexmul(kir, .8), kir, kirI, hexmul(kirI, 1.3)], [0, .2, .45, .75, .92])
        # sap: iki uca kalinlasan kemer; uclarda dinleme / konusma kaplari
        pts = [(2.0, 3.0), (5.0, 1.4), (12.0, 0.8), (19.0, 1.4), (22.0, 3.0)]
        A.tup(pts, lambda t: 1.9 + 0.3 * abs(math.cos(t * math.pi)), -0.5, Mk, seg=12)
        for x in (2.0, 22.0):
            T.torna("kap", [(2.6, 0), (2.6, 1.0), (1.8, 2.4)], x, 6.2, -0.5, 0.8, Mk, K, seg=16)
        # kivrik kablo
        Mc = mat_ton("#1f2329", f=(0.7, 0.95, 1.0, 1.6))
        onceki = None
        for k in range(13):
            u = k / 12
            x = 12.0 + math.sin(u * 6.0 * 1.2) * 2.0
            g = 6.0 + u * 6.0
            if onceki:
                T.on_poligon("kablo", [(onceki[0] - 0.45, onceki[1]), (onceki[0] + 0.45, onceki[1]), (x + 0.45, g), (x - 0.45, g)], 0.6, Mc, K, derin=0.2)
            onceki = (x, g)
    return fn


def telefon_bant():
    Mb = I.cel("Bant", ["#4e120c", "#6e1a12", "#b83228", "#d8493a"], [0, .3, .6, .88])
    aci = -0.42
    cx, cy = 12.0, 18.0
    bm = bmesh.new()
    kose = []
    for x, g in ((-17, -4), (17, -4), (17, 4), (-17, 4)):
        rx = cx + x * math.cos(aci) - g * math.sin(aci)
        rg = cy + x * math.sin(aci) + g * math.cos(aci)
        kose.append((rx, rg))
    T.on_poligon("bant", kose, -4.0, Mb, K, derin=0.3)
    ust = []
    for x, g in ((-16, -3.8), (16, -3.8), (16, -2.6), (-16, -2.6)):
        ust.append((cx + x * math.cos(aci) - g * math.sin(aci), cy + x * math.sin(aci) + g * math.cos(aci)))
    T.on_poligon("bant_isik", ust, -4.35, mat_duz("#d8493a"), K, derin=0.05)
    alt = []
    for x, g in ((-17, 3.0), (17, 3.0), (17, 4.0), (-17, 4.0)):
        alt.append((cx + x * math.cos(aci) - g * math.sin(aci), cy + x * math.sin(aci) + g * math.cos(aci)))
    T.on_poligon("bant_golge", alt, -4.35, mat_duz("#6e1a12"), K, derin=0.05)
    L.silindir("muhur", 3.2, 20.0, -4.6, ez(26.0, -4.6, K), 0.8, c4("#b83228", f=(0.6, 0.85, 1.0, 1.2)), seg=18, eksen="Y")
    elipsoid(20.0, 26.0, 1.8, 1.8, 0.4, -5.1, mat_duz("#d8493a"), seg=12, ring=6)
    elipsoid(19.4, 25.2, 0.6, 0.5, 0.2, -5.5, mat_duz("#ffb0a0"), seg=6, ring=4)


# ================================================================ denetim lambasi
def denetim_govde():
    Mg = I.cel("DenGovde", ["#25282d", "#3a3e44", "#4a4e54", "#61666d"], [0, .3, .6, .88])
    kutu(6, 10, 0, 4, -0.8, 1.2, c4("#5a5e64"), bevel=0.4)
    kutu(2, 14, 4, 7, -1.2, 1.4, mat_ton("#2e3238"), bevel=0.4)
    cerceve(1, 15, 6, 14, 1.4, -2.0, 1.2, Mg)
    kutu(1, 15, 12.6, 14, -2.1, 1.2, mat_ton("#25282d"), bevel=0.3)


def denetim_cam(k):
    def fn():
        mr, ic = [("#5a2620", "#3e1a16"), ("#d8922a", "#f0d090"), ("#ff4132", "#ffd0c0")][k]
        kutu(2.4, 13.6, 7.2, 12.8, -1.4, 0.8, mat_duz(mr))
        elipsoid(8.0, 10.0, 4.2, 1.9, 1.0, -1.6, I.cel("Cam%d" % k, [mr, hexmul(mr, 1.15), ic], [0, .45, .85]), seg=16, ring=8)
        for i in range(4):
            kutu(3.0 + i * 3.0, 3.6 + i * 3.0, 7.0, 13.0, -2.8, -2.5, mat_duz("#2a2d32"))
    return fn


# ================================================================ gece esyalari
def alarm(acik):
    def fn():
        kutu(0, 12, 0, 7, -1.5, 1.5, I.cel("Alarm", ["#1f252c", "#2f3740", "#454b52", "#6a727a"], [0, .3, .6, .88]), bevel=0.5)
        renk = "#ff3a2a" if acik else "#6a2018"
        T.torna("kubbe", [(5.6, 0), (5.2, 1.6), (3.2, 3.4), (0.3, 4.2)], 6.0, 1.0, -0.5, 0.7,
                I.cel("AlarmKubbe%d" % acik, [hexmul(renk, .7), renk, hexmul(renk, 1.4) if acik else hexmul(renk, 1.2), "#ffd0c0" if acik else hexmul(renk, 1.4)], [0, .3, .65, .9]), K, seg=20)
        for x in (2.5, 9.5):
            elipsoid(x, 4.0, 0.5, 0.5, 0.2, -1.6, mat_duz("#8a929b"), seg=6, ring=4)
    return fn


def kilit():
    Mg = I.cel("Kilit", ["#5a636b", "#8a929b", "#c7ced5", "#eef2f5"], [0, .3, .65, .9])
    kutu(-4, 5, 0, 7, -1.5, 1.5, Mg, bevel=0.6)
    L.halka("kanca", 2.6, 3.0, 0.7, 0.5, ez(-0.8, 0.0, K), 0.0, Mg)
    kutu(-0.3, 1.3, 2.6, 5.4, -1.7, -1.5, mat_duz("#3a4048"))
    elipsoid(0.5, 2.8, 0.7, 0.7, 0.2, -1.8, mat_duz("#3a4048"), seg=8, ring=4)


def fener_isik():
    """art.js: 30 satir, satir fb'de (tx+8+fb, TY-22+fb/2) genislik 3+fb, %10 sari."""
    W, H = 70, 24
    a = np.zeros((H * HD, W * HD, 4), np.float32)
    yy, xx = np.mgrid[0:H * HD, 0:W * HD].astype(np.float32) + 0.5
    X = xx / HD + 6.0
    Y = yy / HD - 24.0
    # satir s = Y + 22: sol kenar 8 + 2s, sag kenar 11 + 4s (asagi-saga genisleyen koni)
    s_ = Y + 22.0
    sol, sag = 8.0 + 2.0 * s_, 11.0 + 4.0 * s_
    ic = np.clip(np.minimum(X - sol, sag - X) / 2.5, 0, 1) * (s_ >= -0.5) * (s_ <= 15.5)
    boy = np.clip(1.0 - s_ / 17.0, 0, 1) ** 0.7
    a[..., :3] = S.rgb("#ffe9a0")
    a[..., 3] = ic * boy * 0.34
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


def kesinti_isik():
    """art.js: 9 ic ice dikdortgen kor (%7.5 -> %1.7). Burada ayni kapsama
    yumusak kenarli elips kademeleriyle."""
    W, H = 132, 224
    a = np.zeros((H * HD, W * HD, 4), np.float32)
    yy, xx = np.mgrid[0:H * HD, 0:W * HD].astype(np.float32) + 0.5
    X = xx / HD - W / 2.0
    Y = yy / HD - H / 2.0
    kalan = np.ones(X.shape, np.float32)
    hw, hh = 17.0, 96.0
    for g in range(9):
        gw = hw * (1 + g * 0.42) * 2.6 / 2.0
        gh = hh * (1 + g * 0.16) / 2.0
        d = np.maximum(np.abs(X) / gw, np.abs(Y) / gh)
        d2 = np.sqrt((X / (gw * 1.15)) ** 2 + (Y / (gh * 1.05)) ** 2)
        m = np.clip((1.0 - np.minimum(d, d2 * 0.93)) * 6.0, 0, 1)
        kalan *= 1.0 - m * (0.075 - g * 0.0072)
    a[..., :3] = S.rgb("#ff7a1e")
    a[..., 3] = 1.0 - kalan
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


def kesinti_ic():
    """Izgara onundeki sicak alan (art.js (hx-6, hy-4, hw+12, hh+8) %20): yumusak kenarli."""
    W, H = 29 + 8, 104 + 8
    a = np.zeros((H * HD, W * HD, 4), np.float32)
    yy, xx = np.mgrid[0:H * HD, 0:W * HD].astype(np.float32) + 0.5
    X = xx / HD - 4.0
    Y = yy / HD - 4.0
    kenar = np.minimum(np.minimum(X, 29 - X), np.minimum(Y, 104 - Y))
    a[..., :3] = S.rgb("#ffa03c")
    a[..., 3] = np.clip((kenar + 2.0) / 5.0, 0, 1) ** 1.5
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


# ================================================================ kayit
parca("telefon_govde", (0, 5, 25, 26), telefon_govde(0))
parca("telefon_govde_m", (0, 5, 25, 26), telefon_govde(1))
parca("telefon_ahize", (-2, -3, 28, 17), telefon_ahize(0))
parca("telefon_ahize_m", (-2, -3, 28, 17), telefon_ahize(1))
parca("telefon_bant", (-6, 0, 36, 32), telefon_bant)
parca("denetim_govde", (-1, -2, 18, 18), denetim_govde)
for _k in range(3):
    parca("denetim_cam_%d" % _k, (1, 5, 14, 10), denetim_cam(_k), cizgi=None)
parca("alarm_0", (-2, -6, 16, 15), alarm(0))
parca("alarm_1", (-2, -6, 16, 15), alarm(1))
parca("kilit", (-6, -6, 13, 15), kilit)
parca("fener_isik", (6, -24, 70, 24), fener_isik, tur="np")
parca("kesinti_isik", (-66, -112, 132, 224), kesinti_isik, tur="np")
parca("kesinti_ic", (-10, -8, 37, 112), kesinti_ic, tur="np")


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, tur = PARCALAR[ad]
    yol = os.path.join(OUT, ad + ".png")
    if tur == "np":
        px.reset()
        return px.write_png(fn(), yol)
    D.sahne(gx0, gy0, w, h, 1.0)
    S._MAT.clear()
    fn()
    px.shear_scene(K)
    px.render(yol)
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
    print("GECE_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
