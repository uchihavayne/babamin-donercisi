"""PROLOG SAHNELERI — remake HD (prologue.js).

    blender --background --factory-startup --python blender/models/prolog_hd.py [-- ad ...]
    python blender/hd_atlas.py prolog_hd prolog

Hikaye paneli 400x150 (ekranda 40,44). prologue.js cizimleri "pb" uzayinda:
x -200..200 (ekran x = 240 + x), z yukari (ekran y = 133 - z). Burada modeller
ayni sayilarla kurulur; P(x, z) panel icindeki ekran noktasina cevirir.
Her sahne: sabit arka katman (numpy gok + Blender), sabit on katman ve
hareketli parcalar (kod eski formullerle konumlar). Capa: panel sol-ust (0, 0),
hareketli parcalarda pb noktasi (belirtildigi gibi).

Sahne 1 (dukkan, gunduz):
  p1_arka        gok, gunes, bulut, uzak siluet + cami, orta/yakin binalar, yol,
                 dukkan ici (raf, kavanozlar, asili lambalar)
  p1_baba_govde, p1_baba_kol, p1_baba_bas, p1_baba_bas_kirp   capa pb (bx=4, 0)
  p1_tezgah      tezgah + yemek vitrini (sis kodda)
  p1_on          cam yansimasi, ahsap cerceve, cini serit, tente, tabela, cop, menu
  p1_kisi_<0..2> kuyruktaki uc kisi, capa pb (bx, 0)
  p1_yuru_<b>_<z> yuruyen gazeteci (bacak -3..3, sicrama 0/1), capa pb (bx, 0)
  p1_lamba       sokak lambasi (kisilerin onunde)
"""
import sys, os, math, json, random
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

OUT = os.path.join(_HERE, "out", "prolog_hd")
HD = 2
K = 0.3
PW, PH = 400, 150
PARCALAR, KOKEN = {}, {}


def ez(gy, y, k=None):
    return -gy - y * (K if k is None else k)


def P(x, z):
    return (x + 200.0, 89.0 - z)


def parca(ad, tuval, fn, cizgi="#140e0a", cizgi_alfa=90, tur="3b", k=None):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa, tur, K if k is None else k)
    KOKEN[ad] = (tuval[0], tuval[1])


_MAT = {}


def ton(renk, f=(0.7, 0.88, 1.0, 1.12), stops=(0, .3, .55, .85), noise=0.0, ns=30):
    k = ("t", renk, f, stops, noise)
    if k not in _MAT:
        _MAT[k] = I.cel("M%d" % len(_MAT), [T.hexmul(renk, x) for x in f], list(stops), noise=noise, noise_scale=ns)
    return _MAT[k]


def duz(renk):
    k = ("d", renk)
    if k not in _MAT:
        _MAT[k] = px.flat("D%d" % len(_MAT), renk)
    return _MAT[k]


def alfa(renk, a):
    k = ("a", renk, a)
    if k not in _MAT:
        _MAT[k] = px.flat_a("A%d" % len(_MAT), renk, a)
    return _MAT[k]


def kutu(x0, z0, x1, z1, y0, y1, mat, bevel=0.0):
    """pb dikdortgeni (x0,z0)-(x1,z1), on yuzu y0'da."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    gx0, gy1 = P(x0, z0)
    gx1, gy0 = P(x1, z1)
    zz0, zz1 = ez(gy1, y0), ez(gy0, y0)
    for v in bm.verts:
        v.co.x = gx0 if v.co.x < 0 else gx1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = zz0 if v.co.z < 0 else zz1
    if bevel > 0:
        bmesh.ops.bevel(bm, geom=bm.edges[:], offset=bevel, segments=1, affect="EDGES")
    return I.mesh_ob("k", bm, mat, smooth=False)


def levha(pts, y, mat, derin=0.05):
    """pb noktalari (x, z) ile on yuz levhasi."""
    return T.on_poligon("l", [P(x, z) for x, z in pts], y, mat, K, derin=derin)


def elips(cx, cz, rx, rz, rd, y, mat, seg=16, ring=10):
    gx, gy = P(cx, cz)
    e = I.elipsoid("e", gx, gy, rx, rd, rz, y, mat, seg=seg, ring=ring)
    e.scale = (rx, rd, rz)
    e.location = (gx, y, ez(gy, y))
    return e


def silindir_z(x, z0, z1, y, r, mat, seg=10, r2=None):
    gx, gy0 = P(x, z1)
    _, gy1 = P(x, z0)
    return L.silindir("s", r, gx, y, ez((gy0 + gy1) / 2.0, y), gy1 - gy0, mat, seg=seg, eksen="Z", r2=r2)


def uzuv(a, b, r, y, mat, seg=10):
    ax, ag = P(*a)
    bx, bg = P(*b)
    uz = math.hypot(bx - ax, bg - ag)
    ob = L.silindir("u", r, (ax + bx) / 2.0, y, ez((ag + bg) / 2.0, y), max(0.01, uz), mat, seg=seg, eksen="Z")
    ob.rotation_euler = (0, math.atan2(bx - ax, -(bg - ag)), 0)
    for (px_, pg) in ((ax, ag), (bx, bg)):
        e = I.elipsoid("uc", px_, pg, r, r, r, y, mat, seg=8, ring=5)
        e.location = (px_, y, ez(pg, y))
    return ob


def sahne(isik=(-0.45, 0.62, -0.62)):
    D.sahne(0, 0, PW, PH, 1.0)
    _MAT.clear()
    g = [o for o in bpy.context.scene.objects if o.type == "LIGHT"][0]
    g.rotation_euler = Vector(isik).normalized().to_track_quat("-Z", "Y").to_euler()


def rgb(h):
    return S.rgb(h)


def np_bos():
    return np.zeros((PH * HD, PW * HD, 4), np.float32)


def np_koord():
    yy, xx = np.mgrid[0:PH * HD, 0:PW * HD].astype(np.float32) + 0.5
    X = xx / HD - 200.0            # pb x
    Z = 89.0 - yy / HD             # pb z
    return X, Z


def ustune(dst, renk, a):
    a = np.clip(a, 0, 1)[..., None]
    c = rgb(renk)
    dst[..., :3] = dst[..., :3] * (1 - a) + c * a
    dst[..., 3:4] = np.maximum(dst[..., 3:4], a)
    return dst


# ================================================================ sahne 1
def p1_gok():
    a = np_bos()
    X, Z = np_koord()
    bant = [(96, "#5e8fbc"), (72, "#72a2c9"), (56, "#8ab7d6"), (42, "#a4cbdf"), (28, "#c0dbe4"), (14, "#dbe4d8"), (0, "#f0e0bc"), (-62, "#f0e0bc")]
    zs = np.array([b[0] for b in bant], np.float32)[::-1]
    cs = np.array([rgb(b[1]) for b in bant], np.float32)[::-1]
    for ch in range(3):
        a[..., ch] = np.interp(Z, zs, cs[:, ch])
    a[..., 3] = 1.0
    d = np.hypot(X - 150, Z - 74)
    ustune(a, "#f6e6bc", np.clip((34 - d) / 14, 0, 1) * 0.7)
    ustune(a, "#fdf2d2", np.clip((16 - d) / 2.0, 0, 1))
    ustune(a, "#fffbe8", np.clip((10 - d) / 1.5, 0, 1))
    for cx, cz, w, h in ((-150, 70, 44, 7), (-58, 80, 30, 6), (54, 84, 40, 6)):
        alan = np.zeros_like(X)
        for ox, oz, rx, rz in ((0, h * 0.35, w, h * 0.6), (-w * 0.45, h * 0.2, w * 0.45, h * 0.55), (w * 0.4, h * 0.25, w * 0.5, h * 0.6), (-w * 0.1, h * 0.8, w * 0.35, h * 0.55)):
            alan = np.maximum(alan, 1 - ((X - cx - ox) / rx) ** 2 - ((Z - cz - oz) / rz) ** 2)
        m = np.clip(alan * 5, 0, 1)
        alt = np.clip((cz + h * 0.35 - Z) / (h * 0.7), 0, 1)
        renk = rgb("#f2f7f9")[None, None] * (1 - alt[..., None]) + rgb("#c2d8e6")[None, None] * alt[..., None]
        a[..., :3] = a[..., :3] * (1 - m[..., None] * 0.9) + renk * m[..., None] * 0.9
    return a


def p1_arka_3b():
    U1, U2, U3 = "#9db6c6", "#8aa7ba", "#b2c6d2"
    Mu = ton(U1, f=(0.9, 0.96, 1.0, 1.04))
    uzak = [(-238, -186, 30), (-192, -150, 48), (-156, -112, 24), (-118, -70, 40), (-76, -30, 20), (-36, 14, 34), (10, 56, 16), (52, 104, 38), (98, 148, 26), (142, 196, 44), (190, 238, 22)]
    for x0, x1, h in uzak:
        kutu(x0, -40, x1, h, 30, 34, Mu)
        kutu(x0 - 2, h, x1 + 2, h + 3, 29.6, 34, duz(U3))
        for r in range(int((h + 34) / 13)):
            for c in range(max(1, int((x1 - x0) / 12))):
                kutu(x0 + 5 + c * 12, -34 + r * 13, x0 + 10 + c * 12, -28 + r * 13, 29.9, 30, duz(U2))
    # cami: kubbe, kasnak, alem, iki minare
    Mc = ton(U3, f=(0.86, 0.95, 1.0, 1.06))
    gx, gy = P(128, 44)
    T.torna("kubbe", [(26, 0), (25, 6), (20, 14), (11, 19.5), (0.5, 22)], gx, gy, 26, 0.35, Mc, K, seg=28)
    kutu(98, 36, 158, 46, 27, 36, ton(U1, f=(0.86, 0.95, 1.0, 1.05)))
    kutu(126.5, 62, 129.5, 72, 25.6, 26.4, Mc)
    for mx in (102, 156):
        silindir_z(mx, 36, 84, 25, 3.0, Mc, seg=12)
        gx, gy = P(mx, 80)
        L.silindir("serefe", 5.0, gx, 25, ez(gy, 25), 3.6, ton(U1, f=(0.86, 0.95, 1.0, 1.05)), seg=14, eksen="Z")
        gx, gy = P(mx, 84)
        T.torna("kulah", [(2.4, 0), (0.2, 8.5)], gx, gy, 25, 1.0, Mc, K, seg=12)
    # orta binalar
    O1, O2, O3, O4 = "#7d838a", "#686e75", "#949aa0", "#4a5663"
    orta = [(-236, -168, 28), (-172, -104, 52), (-108, -50, 20), (42, 96, 44), (100, 158, 26), (162, 236, 50)]
    for x0, x1, h in orta:
        kutu(x0, -40, x1, h, 18, 24, ton(O1, f=(0.82, 0.94, 1.0, 1.08)))
        kutu(x1 - 7, -40, x1, h, 17.95, 24, duz(O2))
        kutu(x0 - 3, h - 2, x1 + 3, h + 4, 17.2, 24, ton(O3, f=(0.8, 0.92, 1.0, 1.1)), bevel=0.4)
        for r in range(int((h + 36) / 15)):
            for c in range(max(1, int((x1 - x0) / 15))):
                wx, wz = x0 + 6 + c * 15, -32 + r * 15
                if wz + 9 > h - 6:
                    continue
                kutu(wx, wz, wx + 7, wz + 9, 17.9, 18.2, duz(O4))
                kutu(wx - 1, wz - 2, wx + 8, wz, 17.4, 18.1, duz(O3))
    kutu(-150, 52, -128, 66, 19, 23, ton(O2), bevel=0.5)
    for lx in (-146, -135):
        kutu(lx, 46, lx + 3, 52, 20, 21, duz(O2))
    for ax in (180, 198):
        kutu(ax, 50, ax + 2, 64, 20, 20.5, duz(O2))
        kutu(ax - 5, 61, ax + 7, 63, 20, 20.5, duz(O2))
    # yakin binalar (balkonlu, bazi pencereler yanik)
    Y1, Y2, Y3, Y4, Y5 = "#6b6152", "#544c40", "#8a8070", "#2c3742", "#e8bd72"
    for idx, (x0, x1, h) in enumerate(((-236, -100, 38), (100, 236, 34))):
        kutu(x0, -38, x1, h, 6, 12, ton(Y1, f=(0.8, 0.92, 1.0, 1.08), noise=0.05, ns=20))
        kutu(x0, h - 3, x1, h + 5, 5.0, 12, ton(Y3, f=(0.75, 0.9, 1.0, 1.1)), bevel=0.5)
        kutu(x0, -38, x1, -28, 5.6, 12, ton(Y2))
        kutu(x0, -8, x1, -6, 5.5, 12, ton(Y2))
        kutu(x1 - 6, -38, x1, h, 5.9, 12, duz(Y2))
        n = int((x1 - x0) / 30)
        for c in range(n):
            for r in range(2):
                wx, wz = x0 + 12 + c * 30, -24 + r * 20
                yanik = (c + r * 3 + idx) % 4 == 0
                kutu(wx, wz, wx + 12, wz + 13, 5.9, 6.2, ton(Y5 if yanik else Y4, f=(0.9, 1.0, 1.0, 1.05)))
                if yanik:
                    kutu(wx + 1, wz + 1, wx + 4, wz + 12, 5.85, 6.0, ton("#c98a4a"))
                kutu(wx + 5, wz, wx + 7, wz + 13, 5.7, 6.0, duz(Y2))
                kutu(wx - 2, wz - 2, wx + 14, wz, 4.6, 6.0, ton(Y3), bevel=0.3)
                if r == 1:
                    for b2 in range(6):
                        kutu(wx - 1 + b2 * 3, wz - 7, wx + b2 * 3, wz - 1, 3.0, 3.4, duz(Y2))
                    kutu(wx - 3, wz - 1, wx + 15, wz + 1, 2.8, 6.0, ton(Y3), bevel=0.3)
                    kutu(wx - 3, wz - 8, wx + 15, wz - 7, 2.9, 3.5, duz(Y2))
    # yol, bordur, kaldirim
    kutu(-240, -61, 240, -48, 0, 2, ton("#3b4046", noise=0.1, ns=60))
    for i in range(10):
        kutu(-224 + i * 48, -57, -200 + i * 48, -55, -0.05, 0.1, duz("#c9c093"))
    kutu(-240, -48, 240, -42, -0.2, 2, ton("#6d6d64", noise=0.05))
    kutu(-240, -42, 240, -38, -0.1, 3, ton("#adada0", noise=0.06))
    for i in range(11):
        kutu(-224 + i * 46, -42, -223 + i * 46, -38, -0.15, 0, duz("#7c7c72"))
    for i in range(4):
        kutu(128 + i * 5, -50, 130 + i * 5, -43, -0.3, 0, duz("#4a4a44"))
    # dukkan ici
    kutu(-86, -32, 86, 24, 8, 10, duz("#20130c"))
    for z0, z1, renk in ((-32, -18, "#4a2e18"), (-18, -4, "#3a2313"), (-4, 10, "#2e1c10"), (10, 24, "#241509")):
        kutu(-86, z0, 86, z1, 7.9, 10, ton(renk, f=(0.85, 0.95, 1.0, 1.06), noise=0.08, ns=25))
    kutu(-80, 0, -16, 3, 5.0, 7.9, ton("#6b4122"), bevel=0.3)
    for i in range(8):
        renk = ["#3f79c0", "#c9302a", "#d8ac35"][i % 3]
        gx, gy = P(-74 + i * 7, 3)
        T.torna("kavanoz", [(2.0, 0), (2.2, 5), (1.6, 7.2), (1.2, 8)], gx, gy, 6.2, 0.8, ton(renk, f=(0.7, 0.9, 1.0, 1.3)), K, seg=12)
    for lx in (-56, -6, 46):
        kutu(lx - 0.6, 16, lx + 0.6, 24, 6.8, 7.2, duz("#2b2018"))
        gx, gy = P(lx, 11)
        T.torna("abajur", [(6.2, 0), (5.0, 2.4), (2.0, 5.0), (0.8, 5.4)], gx, gy, 6.4, 0.6, ton("#4a3a28", f=(0.7, 0.9, 1.0, 1.25)), K, seg=18, kapak=False)
        e = elips(lx, 11.6, 3.6, 1.2, 1.0, 6.0, duz("#ffe6a8"))
    kutu(-68, -22, -36, -16, 6.5, 7.9, ton("#3a3a40"), bevel=0.3)


def p1_isik_katman():
    """Dukkan icindeki lamba haleleri (yari saydam, arka katmana eklenir)."""
    a = np_bos()
    X, Z = np_koord()
    for lx in (-56, -6, 46):
        d1 = np.sqrt(((X - lx) / 16) ** 2 + ((Z - 5) / 9) ** 2)
        ustune(a, "#ffcf7a", np.clip(1 - d1, 0, 1) ** 1.3 * 0.28)
        d2 = np.sqrt(((X - lx) / 10) ** 2 + ((Z + 2) / 14) ** 2)
        ustune(a, "#ffb84a", np.clip(1 - d2, 0, 1) ** 1.5 * 0.18)
    return a


def p1_baba_govde():
    bx = 4
    Mk = ton("#a8281c", f=(0.62, 0.84, 1.0, 1.18))
    kutu(bx - 12, -19, bx + 12, 6, 2.0, 7.0, Mk, bevel=2.5)
    kutu(bx - 8, -19, bx + 8, 3, 1.7, 2.2, ton("#e4dcc6", f=(0.78, 0.92, 1.0, 1.05)), bevel=0.8)
    for sx in (-5, 5):
        uzuv((bx + sx, 3.5), (bx + sx * 1.3, 6.5), 0.4, 1.6, duz("#cfc7b2"))


def p1_baba_kol():
    bx = 4
    Mk = ton("#a8281c", f=(0.62, 0.84, 1.0, 1.18))
    uzuv((bx + 10, -2), (bx + 20, -4.5), 3.6, 1.5, Mk)
    elips(bx + 23, -7, 3.2, 3.0, 2.6, 0.8, ton("#e0a978"))


def p1_baba_bas(kirp):
    def fn():
        bx = 4
        Mt = ton("#e0a978", f=(0.72, 0.88, 1.0, 1.1))
        elips(bx, 12, 7.6, 7.2, 6.0, 3.0, Mt, seg=20, ring=14)
        for sx in (-7.4, 7.4):
            elips(bx + sx, 11.5, 1.4, 2.2, 1.0, 3.5, Mt)
        # biyik
        for sx in (-2.6, 2.6):
            e = elips(bx + sx, 9.6, 3.2, 1.3, 1.0, -2.6, ton("#ddd6c8", f=(0.8, 0.94, 1.0, 1.06)), seg=12, ring=6)
        elips(bx, 11.2, 1.3, 1.6, 1.2, -2.9, ton("#c98a5a"))
        if kirp:
            for sx in (-3, 3):
                kutu(bx + sx - 1.5, 12.6, bx + sx + 1.5, 13.3, -2.8, -2.6, duz("#9a6a44"))
        else:
            for sx in (-3, 3):
                elips(bx + sx, 13, 1.1, 1.1, 0.4, -2.9, duz("#2b2018"), seg=8, ring=5)
        # fes
        gx, gy = P(bx, 17.5)
        T.torna("fes", [(8.6, 0), (8.2, 3.5), (7.2, 6.8), (0.3, 7.0)], gx, gy, 2.2, 0.8, ton("#c9302a", f=(0.62, 0.84, 1.0, 1.18)), K, seg=24)
        T.torna("bant", [(8.8, 0), (8.6, 1.2)], gx, gy + 0.3, 2.2, 0.82, ton("#7a1a12"), K, seg=24)
    return fn


def p1_tezgah():
    kutu(-86, -32, 86, -18, -8, -3, ton("#6b4122", f=(0.7, 0.88, 1.0, 1.12), noise=0.08, ns=22), bevel=0.5)
    kutu(-86, -19.4, 86, -17, -8.4, -3, ton("#a8703f", f=(0.75, 0.9, 1.0, 1.15)), bevel=0.4)
    kutu(-30, -32, 22, -21, -9.0, -8.2, ton("#456a7a", f=(0.8, 0.94, 1.0, 1.1)), bevel=0.3)
    for i in range(6):
        renk = ["#c9302a", "#3f8a4a", "#d8ac35"][i % 3]
        kutu(-27 + i * 8, -30, -22 + i * 8, -26, -9.3, -9.0, ton(renk, f=(0.75, 0.9, 1.0, 1.15)), bevel=0.4)
    levha([(-30, -21.5), (22, -21.5), (22, -21), (-30, -21)], -9.4, alfa("#dff0fa", 0.6))
    # sis direk (et kodda)
    kutu(-53, -27, -51, 28, 1.0, 1.6, ton("#9aa3ab", f=(0.6, 0.85, 1.0, 1.25)))


def p1_on():
    levha([(-84, -30), (84, -30), (84, 22), (-84, 22)], -10, alfa("#8fb8cc", 0.08))
    levha([(-84, 8), (84, 8), (84, 22), (-84, 22)], -10.02, alfa("#12283a", 0.26))
    AH1, AH2, AH3, AH4 = "#5a3418", "#7a4a24", "#9a6634", "#3d2210"
    Ma = ton(AH2, f=(0.7, 0.88, 1.0, 1.18), noise=0.1, ns=26)
    kutu(-98, -38, -84, 34, -12, -8, Ma, bevel=0.8)
    kutu(84, -38, 98, 34, -12, -8, Ma, bevel=0.8)
    kutu(-98, 22, 98, 34, -12.5, -8, Ma, bevel=0.8)
    kutu(-98, -38, 98, -30, -12.5, -8, ton(AH4), bevel=0.6)
    for i in range(25):
        kutu(-96 + i * 8, -37, -90 + i * 8, -31, -12.7, -12.4, ton("#2f6b62" if i % 2 == 0 else "#3d8078", f=(0.75, 0.9, 1.0, 1.15)), bevel=0.3)
    kutu(-98, -31, 98, -30, -12.8, -12.4, duz("#8fbdb4"))
    kutu(26, -30, 32, 22, -11.5, -9, Ma, bevel=0.6)
    kutu(78, -30, 84, 22, -11.5, -9, Ma, bevel=0.6)
    elips(73, -4.5, 2.2, 1.4, 1.0, -11.5, ton("#d8ac35", f=(0.6, 0.85, 1.0, 1.3)))
    kutu(32, -40, 84, -38, -14, -8, ton("#a2a297"), bevel=0.3)
    # tente: seritler (egimli) + fistolu etek
    Mr = ton("#c0281c", f=(0.62, 0.84, 1.0, 1.15))
    Mb = ton("#f2ece0", f=(0.72, 0.88, 1.0, 1.03))
    for i in range(17):
        x0 = -102 + i * 12
        M = Mr if i % 2 == 0 else Mb
        bm = bmesh.new()
        p0 = P(x0, 37)
        p1 = P(x0 + 12, 37)
        p2 = P(x0 + 12, 22)
        p3 = P(x0, 22)
        v = [bm.verts.new((p0[0], -9.0, ez(p0[1], -9.0))), bm.verts.new((p1[0], -9.0, ez(p1[1], -9.0))),
             bm.verts.new((p2[0], -22.0, ez(p2[1], -22.0))), bm.verts.new((p3[0], -22.0, ez(p3[1], -22.0)))]
        bm.faces.new(v)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        if bm.faces[0].normal.z < 0:
            bm.faces[0].normal_flip()
        I.mesh_ob("tente", bm, M, smooth=False)
        etek = [(x0, 22), (x0 + 12, 22), (x0 + 12, 19)]
        for k in range(1, 8):
            a = math.pi * k / 8
            etek.append((x0 + 6 + math.cos(a) * 6, 19 - math.sin(a) * 3.2))
        levha(etek, -22.1, M)
    # tabela
    kutu(-92, 38, 92, 61, -10, -6, ton("#7a1a12", f=(0.7, 0.88, 1.0, 1.15)), bevel=0.8)
    kutu(-88, 42, 88, 57, -10.5, -9.5, ton("#c0281c", f=(0.75, 0.9, 1.0, 1.12)), bevel=0.4)
    kutu(-92, 58, 92, 60, -10.4, -9.8, duz("#e2604f"))
    # cop kutusu, menu tahtasi
    Mc = ton("#4a5058", f=(0.62, 0.84, 1.0, 1.25))
    gx, gy = P(115, -42)
    T.torna("cop", [(6.8, 0), (7.4, 20)], gx, gy, -14, 0.7, Mc, K, seg=18)
    T.torna("kapak", [(8.2, 0), (8.0, 2.4), (5.0, 3.4)], gx, gy - 20, -14, 0.7, ton("#6b737d", f=(0.62, 0.84, 1.0, 1.25)), K, seg=18)
    Mt = ton("#6b4122", f=(0.7, 0.88, 1.0, 1.15), noise=0.1)
    uzuv((-126, -42), (-120, -20), 0.8, -13, Mt)
    uzuv((-110, -42), (-116, -20), 0.8, -13, Mt)
    kutu(-128, -34, -108, -20, -14.5, -13.5, Mt, bevel=0.5)
    kutu(-126, -32, -110, -22, -14.8, -14.5, ton("#e8dcc0", f=(0.85, 0.95, 1.0, 1.03)))
    kutu(-123, -28, -113, -27, -15, -14.8, duz("#8e2018"))
    kutu(-123, -25, -116, -24, -15, -14.8, duz("#8e2018"))


def p1_kisi(i):
    kuyruk = [(134, "#3f5a72", "#2e3f52", "#e0a978"), (160, "#5c4a5e", "#3e3242", "#c9885a"), (186, "#4a6b4a", "#33472f", "#f0bd8a")]

    def fn():
        bx, ust, alt, ten = kuyruk[i]
        kisi(bx, ust, alt, ten, "#2b2018", 0, 0, sac_tip=i)
    return fn


def kisi(bx, ust, alt, ten, sac, bacak, zip_, sac_tip=0, gazete=False):
    Ma = ton(alt, f=(0.7, 0.88, 1.0, 1.15))
    Mu = ton(ust, f=(0.66, 0.86, 1.0, 1.15))
    Mt = ton(ten, f=(0.74, 0.9, 1.0, 1.08))
    uzuv((bx - 3.5 - bacak * 0.6, -26), (bx - 3.5 - bacak, -37), 2.5, 1.5, Ma)
    uzuv((bx + 3.5 + bacak * 0.6, -26), (bx + 3.5 + bacak, -37), 2.5, 0.5, Ma)
    for sx, yy in ((-3.5 - bacak, 1.2), (3.5 + bacak, 0.2)):
        elips(bx + sx + 1.0, -38.5, 3.0, 1.4, 2.0, yy - 0.5, ton("#241c16", f=(0.8, 1.0, 1.0, 1.6)), seg=10, ring=6)
    gx, gy = P(bx, -24 + zip_)
    T.torna("govde", [(7.2, 0), (7.6, 6), (7.4, 13), (5.5, 17.5), (3.0, 18.5)], gx, gy, 0.0, 0.62, Mu, K, seg=20)
    kutu(bx - 7.2, -26 + zip_, bx + 7.2, -23 + zip_, -4.6, 3.0, ton(alt, f=(0.6, 0.8, 1.0, 1.1)), bevel=0.6)
    uzuv((bx + 7, -9 + zip_), (bx + 8.5, -19 + zip_), 2.0, -1.5, Mu)
    elips(bx + 8.8, -20.5 + zip_, 1.8, 1.8, 1.4, -2.0, Mt)
    elips(bx, -2 + zip_, 5.4, 5.6, 4.6, 0.0, Mt, seg=18, ring=12)
    Ms = ton(sac, f=(0.7, 0.95, 1.0, 1.5))
    if sac_tip == 1:
        gx, gy = P(bx, 2.2 + zip_)
        T.torna("kasket", [(6.0, 0), (5.6, 2.0), (3.0, 3.0), (0.3, 3.2)], gx, gy, 0.0, 0.9, ton("#3a3a3a", f=(0.7, 0.9, 1.0, 1.4)), K, seg=16)
        elips(bx + 5, 2.2 + zip_, 4.0, 0.8, 2.0, -3.0, ton("#2a2a2a"))
    else:
        e = elips(bx, 2.0 + zip_, 6.0, 3.6, 5.0, 0.3, Ms, seg=16, ring=10)
    if gazete:
        kutu(bx + 8, -18 + zip_, bx + 16, -13 + zip_, -4.0, -3.4, ton("#f0d5a8", f=(0.85, 0.95, 1.0, 1.03)), bevel=0.3)
        for k in range(3):
            kutu(bx + 9, -17 + k * 1.3 + zip_, bx + 15, -16.6 + k * 1.3 + zip_, -4.1, -4.0, duz("#8a8474"))


def p1_yuru(bacak, zip_):
    def fn():
        kisi(0, "#6b5a3a", "#4a4030", "#e0a978", "#3a2a1e", bacak, zip_, sac_tip=0, gazete=True)
    return fn


def p1_lamba():
    Md = ton("#2b2620", f=(0.8, 0.95, 1.0, 1.6))
    silindir_z(-173, -42, 66, -16, 3.0, Md, seg=12)
    kutu(-176.5, -42, -169.5, -38, -17, -15, ton("#1e1a16"), bevel=0.4)
    pts = [(-173 + i * 4.2, 67 - i * 0.9) for i in range(10)]
    for a, b in zip(pts, pts[1:]):
        uzuv(a, b, 1.1, -16, Md)
    kutu(-141, 53.5, -125, 60.5, -18, -14, ton("#3a342c", f=(0.7, 0.9, 1.0, 1.4)), bevel=0.8)
    kutu(-138, 54.6, -128, 57, -18.3, -18, duz("#ffe6a8"))


def p1_lamba_isik():
    a = np_bos()
    X, Z = np_koord()
    r = np.clip(56 - Z, 0, None)
    ic = np.clip((np.minimum(X - (-140 - r * 0.45), (-126 + r * 0.45) - X)) / 4.0, 0, 1) * (Z < 55)
    ustune(a, "#ffe6a8", ic * np.clip(1 - r / 60, 0, 1) ** 1.4 * 0.16)
    d = np.hypot((X + 133) / 12, (Z - 56) / 6)
    ustune(a, "#fff2c0", np.clip(1 - d, 0, 1) ** 1.6 * 0.4)
    return a


# ================================================================ sahne 2 (baba yakin plan)
def p2_zemin():
    a = np_bos()
    X, Z = np_koord()
    bant = [(-70, "#241610"), (-30, "#2e1c12"), (4, "#382214"), (34, "#432a18"), (96, "#432a18")]
    zs = np.array([b[0] for b in bant], np.float32)
    cs = np.array([rgb(b[1]) for b in bant], np.float32)
    for ch in range(3):
        a[..., ch] = np.interp(Z, zs, cs[:, ch])
    a[..., 3] = 1.0
    return a


def p2_arka_3b():
    r = random.Random(12)
    for row in range(11):
        z0 = -59 + row * 14
        ox = 9 if row % 2 else 0
        for c in range(-1, 14):
            x0 = -222 + c * 36 + ox + 1
            x1 = x0 + 34.5
            zc = z0 + 6.5
            renk = "#2e1c12" if zc < -30 else ("#382214" if zc < 4 else ("#432a18" if zc < 34 else "#4a2f1b"))
            renk = T.hexmul(renk, r.uniform(0.9, 1.12))
            kutu(x0, z0 + 0.6, x1, z0 + 13.4, r.uniform(-0.25, 0.1), 2.0, ton(renk, f=(0.75, 0.92, 1.0, 1.1), noise=0.12, ns=18), bevel=0.6)
    for x, h in ((-186, 26), (-166, 20), (154, 30), (176, 22)):
        kutu(x - 1, 96 - h, x + 1, 96, -1.0, -0.4, ton("#1c1108", f=(0.8, 1.0, 1.0, 1.8)))
        kutu(x - 7, 90 - h, x + 7, 96 - h, -1.2, -0.2, ton("#2b2018", f=(0.7, 0.95, 1.0, 1.6)), bevel=0.4)
        gx, gy = P(x, 88 - h)
        L.halka("kanca", 2.2, 2.8, 0.5, gx, ez(gy, -0.8), -0.8, ton("#5a5a60", f=(0.6, 0.9, 1.0, 1.5)))


def p2_ocak_arka():
    X = -136
    Mg = ton("#22222a", f=(0.7, 0.9, 1.0, 1.3))
    kutu(X - 38, -58, X + 38, -48, -2, 6, ton("#2f2f38", f=(0.7, 0.9, 1.0, 1.35)), bevel=0.8)
    kutu(X - 38, -50, X + 38, -48, -2.2, 6, duz("#6f7880"))
    kutu(X - 32, -48, X + 32, 44, 0, 8, Mg, bevel=1.0)
    kutu(X - 25, -44, X + 25, 42, -0.2, 0.2, duz("#101016"))


def p2_ocak_on():
    X = -136
    Mr = ton("#3d3d48", f=(0.66, 0.9, 1.0, 1.35))
    kutu(X - 27, -43, X - 25, 41, -1.5, 0.5, Mr)
    kutu(X + 25, -43, X + 27, 41, -1.5, 0.5, ton("#1c1c24", f=(0.8, 1.0, 1.0, 1.6)))
    kutu(X - 32, 40, X + 32, 44, -1.6, 0.5, Mr, bevel=0.4)
    kutu(X - 16, 44, X + 16, 54, -1, 5, ton("#2a2a32", f=(0.7, 0.9, 1.0, 1.35)), bevel=0.6)
    kutu(X - 16, 52, X + 16, 54, -1.2, 5, duz("#4d545c"))
    gx, gy = P(X - 9, 48)
    L.silindir("dugme", 2.4, gx, -1.4, ez(gy, -1.4), 0.8, ton("#6f7880", f=(0.6, 0.9, 1.0, 1.35)), seg=14, eksen="Y")
    silindir_z(X, -52, 48, -6.0, 2.0, ton("#9aa3ab", f=(0.55, 0.85, 1.0, 1.4)), seg=12)


def p2_ocak_ust():
    X = -136
    kutu(X + 12, -48, X + 26, -46, -8, -5, ton("#8a5f2a", f=(0.7, 0.9, 1.0, 1.2)), bevel=0.3)


def p2_hale():
    a = np_bos()
    X, Z = np_koord()
    d = np.sqrt(((X + 130) / 150) ** 2 + ((Z + 7) / 110) ** 2)
    a[..., :3] = rgb("#ff9a3a")
    a[..., 3] = np.clip(1 - d, 0, 1) ** 1.1 * 0.62
    return a


def p2_baba():
    BX, BZ = 62, 6
    Mk = ton("#c33c2c", f=(0.55, 0.78, 1.0, 1.18), stops=(0, .25, .5, .82))
    e = elips(BX - 2, BZ - 64, 56, 46, 30, 12, Mk, seg=28, ring=18)
    Mw = ton("#e4dcc6", f=(0.72, 0.88, 1.0, 1.07))
    elips(BX - 2, BZ - 68, 26, 42, 8, -12, Mw, seg=22, ring=14)
    elips(BX, BZ - 30, 20, 8, 12, -6, ton("#c33c2c", f=(0.6, 0.82, 1.0, 1.15)), seg=20, ring=10)
    Mt = ton("#e0a978", f=(0.62, 0.8, 1.0, 1.1), stops=(0, .25, .5, .84))
    silindir_z(BX, -24 + BZ, -4 + BZ, 0, 10.5, ton("#c9885a", f=(0.65, 0.82, 1.0, 1.08)), seg=16)
    elips(BX, BZ + 4, 25, 29, 22, -6, Mt, seg=28, ring=20)
    for sx in (-25, 25):
        elips(BX + sx, BZ + 2, 4.6, 8.0, 3.0, -4, Mt, seg=12, ring=8)
    elips(BX - 1, BZ + 4, 5.5, 8.5, 5.0, -26, Mt, seg=14, ring=10)
    elips(BX - 1, BZ - 4, 7.0, 3.6, 3.0, -25, ton("#b87b4c"), seg=12, ring=8)
    for sx in (-15, 15):
        elips(BX + sx, BZ - 7, 7.0, 5.0, 3.0, -22, ton("#e8a07a", f=(0.85, 0.95, 1.0, 1.05)), seg=12, ring=8)
    # kaslar (egik, gri)
    for i, sx in enumerate((-11, 11)):
        # yumusak, ic ucu hafif kalkik kaslar (sefkatli bakis)
        pts = [(BX + sx - 8 + j * 2, BZ + 20.5 + (j - 4) * (-0.22 if i else 0.22) - ((j - 4) / 4.0) ** 2 * 0.8) for j in range(9)]
        for a_, b_ in zip(pts, pts[1:]):
            uzuv(a_, b_, 1.3, -24, ton("#b8b0a0", f=(0.72, 0.9, 1.0, 1.12)))
    # biyik: kivrik uclu genis biyik
    Mb = ton("#ddd6c8", f=(0.72, 0.88, 1.0, 1.08))
    pts = []
    for j in range(29):
        u = abs(j - 14) / 14.0
        pts.append((BX - 15 + j, BZ - 9 + u * u * 6 + max(2.0, 6 - u * 3.5) / 2))
    for a_, b_, j in zip(pts, pts[1:], range(28)):
        u = abs(j - 14) / 14.0
        uzuv(a_, b_, max(1.0, (6 - u * 3.5) / 2), -27.5, Mb)
    # agiz (gulumseyen)
    pts = [(BX - 6 + j, BZ - 16.5 + (abs(j - 6) / 6) ** 2 * 2) for j in range(13)]
    for a_, b_ in zip(pts, pts[1:]):
        uzuv(a_, b_, 0.6, -26.5, duz("#8a4a2e"))
    # fes + puskul kordonu yuvasi
    Mf = ton("#c33c2c", f=(0.58, 0.8, 1.0, 1.18))
    gx, gy = P(BX, BZ + 30)
    T.torna("fes", [(23, 0), (22.4, 10), (21.6, 18), (19.5, 21.6), (0.5, 22.5)], gx, gy, -2, 0.55, Mf, K, seg=32)
    T.torna("bant", [(23.4, 0), (23.2, 4.2)], gx, gy + 0.5, -2, 0.56, ton("#7a1a12", f=(0.7, 0.9, 1.0, 1.15)), K, seg=32)


def p2_goz(acik):
    def fn():
        BX, BZ = 62, 6
        for sx in (-11, 11):
            if acik:
                # gulen goz: alt kapak yukari kavisli, ust kapak gozun yarisini ortuyor
                elips(BX + sx, BZ + 12, 5.0, 3.2, 1.5, -24.5, duz("#f0ece2"), seg=14, ring=8)
                elips(BX + sx + 0.8, BZ + 11.6, 2.4, 2.4, 1.0, -25.6, duz("#2b2018"), seg=12, ring=8)
                elips(BX + sx + 0.1, BZ + 12.4, 0.7, 0.7, 0.5, -26.4, duz("#ffffff"), seg=8, ring=5)
                kutu(BX + sx - 5.6, BZ + 13.0, BX + sx + 5.6, BZ + 16.4, -26.6, -26.3, ton("#e0a978", f=(0.8, 0.92, 1.0, 1.05)))
                pts = [(BX + sx - 5.5 + k, BZ + 13.2 - (abs(k - 5.5) / 5.5) ** 2 * 1.4) for k in range(12)]
                for a_, b_ in zip(pts, pts[1:]):
                    uzuv(a_, b_, 0.55, -26.8, duz("#6a3a22"))
                pts = [(BX + sx - 5 + k, BZ + 9.2 + (abs(k - 5) / 5) ** 2 * 1.4) for k in range(11)]
                for a_, b_ in zip(pts, pts[1:]):
                    uzuv(a_, b_, 0.4, -26.8, duz("#b87b4c"))
            else:
                pts = [(BX + sx - 5 + k, BZ + 12 - (abs(k - 5) / 5) ** 2 * -1.2) for k in range(11)]
                for a_, b_ in zip(pts, pts[1:]):
                    uzuv(a_, b_, 0.6, -25.8, duz("#8a5230"))
    return fn


def p2_puskul():
    BX, BZ = 62, 6
    Md = ton("#2b2018", f=(0.7, 0.95, 1.0, 1.8))
    uzuv((BX + 20, BZ + 53), (BX + 20, BZ + 39), 0.7, -12, Md)
    elips(BX + 20, BZ + 36, 3.4, 3.6, 2.6, -12, Md, seg=12, ring=8)
    for k in range(5):
        uzuv((BX + 20 + (k - 2) * 0.9, BZ + 34), (BX + 20 + (k - 2) * 1.4, BZ + 29), 0.35, -12.5, Md)


def p2_kol():
    Mk = ton("#c33c2c", f=(0.55, 0.78, 1.0, 1.18))
    pts = [(26 - i * 6, -59 + (20 * i * 6 / 42.0)) for i in range(8)]
    for i, (a_, b_) in enumerate(zip(pts, pts[1:])):
        uzuv(a_, b_, 10.5 - i * 0.4, -32, Mk)
    levha([(4, -50), (14, -50), (14, -47), (4, -47)], -18, alfa("#6b1610", 0.3))
    Mc = ton("#e4dcc6", f=(0.7, 0.88, 1.0, 1.07))
    uzuv((-12, -39), (-19, -43), 9.2, -36, Mc)
    # durum (lavas rulo + kagit)
    X, R = -31, 10
    Ml = I.cel("Lavas", ["#8a5f2a", "#a87a41", "#cfa268", "#f0d5a8", "#fdfaf0"], [0, .2, .4, .7, .9])
    gx, gy = P(X, -42)
    T.torna("durum", [(9.6, 0), (10.0, 20), (9.6, 55), (8.6, 57)], gx, gy, -40, 0.7, Ml, K, seg=24)
    Mi = ton("#8a4a1a")
    gx, gy = P(X, 12)
    I.yatay_elips("ic", gx, gy, 7.2, 1.0, Mi, K, ry_ekran=3.0, seg=24).location = (gx, -44.0, ez(gy, -44.0))
    for cx, cz, rx, rz, renk in ((X - 3, 11.5, 3.5, 2.2, "#d18c42"), (X + 3, 11.5, 2.6, 1.8, "#3f8a4a"), (X, 10, 2.0, 1.4, "#c9302a")):
        elips(cx, cz, rx, rz, 1.4, -46.5, ton(renk, f=(0.7, 0.9, 1.0, 1.15)), seg=10, ring=6)
    Mp = I.cel("DKagit", ["#9e9888", "#b0a894", "#e4dcc6", "#fdfaf0", "#ffffff"], [0, .2, .45, .75, .92])
    gx, gy = P(X, -42)
    T.torna("kagit", [(11.2, 0), (11.4, 32.5), (11.0, 33)], gx, gy, -40, 0.72, Mp, K, seg=24, kapak=False)
    for z0, renk in ((-19, "#d8352c"), (-24, "#2f5f9e")):
        levha([(X - 9, z0), (X + 9, z0), (X + 9, z0 + 2), (X - 9, z0 + 2)], -48.4, duz(renk))
    # el: avuc, dort parmak, basparmak
    Mh = I.cel("El", ["#5e3820", "#96603a", "#b87b4c", "#d79f70", "#e8b184"], [0, .2, .45, .72, .9])
    elips(X, -25.5, 15, 12, 8, -38, Mh, seg=20, ring=12)
    for i in range(4):
        fz = -16 - i * 6
        f0 = X - 15 + (2 if i == 3 else 0)
        f1 = X + 13 - (2 if i == 3 else 0)
        uzuv((f0, fz), (f1, fz), 3.0, -50 - i * 0.3, Mh)
    pts = [(X + 12 - (q / 18) * 3, -36 + q) for q in range(0, 19, 3)]
    for a_, b_ in zip(pts, pts[1:]):
        uzuv(a_, b_, 3.2, -49.5, Mh)
    elips(X + 9, -15, 2.4, 1.8, 1.0, -53, ton("#f0bd8a", f=(0.85, 0.95, 1.0, 1.05)), seg=10, ring=6)


def p2_atmosfer():
    a = np_bos()
    X, Z = np_koord()
    ustune(a, "#ff8a3a", np.full(X.shape, 0.07, np.float32))
    kenar = np.clip((np.abs(X) - 130) / 60, 0, 1) * 0.38
    ust_alt = np.maximum(np.clip((Z - 60) / 30, 0, 1), np.clip((-40 - Z) / 22, 0, 1)) * 0.28
    a2 = 1 - (1 - kenar) * (1 - ust_alt)
    a[..., :3] = a[..., :3] * a[..., 3:4] / np.maximum(1e-6, a[..., 3:4] + a2[..., None] * (1 - a[..., 3:4]))
    out = np.zeros_like(a)
    # siyah kararma + turuncu ton birlikte: iki katmanli "over"
    out[..., :3] = rgb("#ff8a3a") * 0.07 / np.maximum(1e-6, 0.07 + a2[..., None] * 0.93)
    out[..., 3] = 0.07 + a2 * 0.93
    return out


# ================================================================ sahne 3 (kapali dukkan, gece, kar)
def p3_gok():
    a = np_bos()
    X, Z = np_koord()
    bant = [(-62, "#2f3d55"), (10, "#2f3d55"), (26, "#273348"), (44, "#1f293b"), (64, "#18202f"), (96, "#121824")]
    zs = np.array([b[0] for b in bant], np.float32)
    cs = np.array([rgb(b[1]) for b in bant], np.float32)
    for ch in range(3):
        a[..., ch] = np.interp(Z, zs, cs[:, ch])
    a[..., 3] = 1.0
    for cx, cz, w, h in ((-140, 70, 60, 9), (30, 82, 74, 8), (170, 64, 44, 7)):
        alan = np.zeros_like(X)
        for ox, oz, rx, rz in ((0, h * 0.35, w, h * 0.6), (-w * 0.45, h * 0.15, w * 0.45, h * 0.55), (w * 0.4, h * 0.2, w * 0.5, h * 0.6)):
            alan = np.maximum(alan, 1 - ((X - cx - ox) / rx) ** 2 - ((Z - cz - oz) / rz) ** 2)
        m = np.clip(alan * 5, 0, 1)
        ustune(a, "#3a4660", m * 0.85)
    r = random.Random(3)
    for i in range(40):
        sx, sz = r.uniform(-200, 200), r.uniform(40, 89)
        ustune(a, "#dfe8ff", np.clip(1 - np.hypot(X - sx, Z - sz) / 0.9, 0, 1) * r.uniform(0.3, 0.8))
    return a


def p3_arka_3b():
    r = random.Random(8)
    for x0, x1, h in ((-238, -170, 40), (-176, -120, 62), (126, 190, 54), (184, 238, 38)):
        kutu(x0, -36, x1, h, 20, 26, ton("#1b2432", f=(0.85, 0.95, 1.0, 1.08)))
        for rr in range(int((h + 30) / 16)):
            for c in range(max(1, int((x1 - x0) / 18))):
                yan = (rr * 3 + c * 5 + int(x0)) % 4 == 0
                kutu(x0 + 7 + c * 18, -26 + rr * 16, x0 + 14 + c * 18, -17 + rr * 16, 19.9, 20.1, duz("#d8a850" if yan else "#141b27"))
    for idx, (x0, x1) in enumerate(((-238, -142), (142, 238))):
        kutu(x0, -36, x1, 54, 8, 14, ton("#2a3040", f=(0.8, 0.93, 1.0, 1.08), noise=0.04))
        kutu(x0 - 1, 52, x1 + 1, 59, 7.2, 14, ton("#3a4254"), bevel=0.4)
        kutu(x0 - 1, 57, x1 + 1, 60, 6.8, 14, ton("#c8d4e0", f=(0.8, 0.94, 1.0, 1.04), noise=0.1, ns=40), bevel=0.6)
        for c in range(3):
            for rr in range(3):
                yan = (c + rr * 2 + idx) % 3 == 0
                kutu(x0 + 14 + c * 28, -22 + rr * 22, x0 + 26 + c * 28, -8 + rr * 22, 7.9, 8.2, ton("#e0b060" if yan else "#161d2a", f=(0.9, 1.0, 1.0, 1.05)))
                kutu(x0 + 12 + c * 28, -24 + rr * 22, x0 + 28 + c * 28, -22 + rr * 22, 7.0, 8.2, ton("#c8d4e0", f=(0.85, 0.95, 1.0, 1.02)), bevel=0.3)
    # yol + karli kaldirim
    kutu(-240, -61, 240, -48, 0, 2, ton("#191d25", noise=0.08, ns=50))
    kutu(-240, -48, 240, -42, -0.2, 2, ton("#20262e"))
    kutu(-240, -42, 240, -36, -0.6, 3, ton("#c8d4e0", f=(0.82, 0.94, 1.0, 1.04), noise=0.12, ns=40), bevel=0.5)
    for i in range(14):
        kutu(-230 + i * 34, -52, -206 + i * 34, -50, -0.05, 0.1, duz("#8fa2b6"))
    # kapali dukkan: govde, cini serit, kepenk
    kutu(-150, -38, 150, 40, 3, 8, ton("#33251a", f=(0.75, 0.92, 1.0, 1.08), noise=0.08, ns=25))
    kutu(140, -38, 150, 40, 2.9, 8, duz("#241a12"))
    kutu(-150, -38, 150, -30, 2.4, 8, ton("#241a12"), bevel=0.4)
    for i in range(38):
        kutu(-148 + i * 8, -37, -142 + i * 8, -31, 2.2, 2.5, ton("#22453f" if i % 2 == 0 else "#2b544e", f=(0.75, 0.9, 1.0, 1.12)), bevel=0.3)
    Ms = I.cel("Kepenk3", ["#232a30", "#2a3138", "#39424a", "#4b555f", "#5f6a75"], [0, .25, .5, .78, .93])
    for rr in range(18):
        z = -30 + rr * 3
        kutu(-136, z, 136, z + 3, 2.6, 3.4, Ms, bevel=0.45)
    for v in range(-132, 136, 26):
        kutu(v, -30, v + 2, 24, 2.4, 2.7, duz("#232a30"))
    for x, z, w, h in ((-96, -12, 14, 8), (34, 6, 10, 6), (88, -22, 18, 5), (-40, 14, 9, 7)):
        levha([(x, z), (x + w, z), (x + w - 2, z + h), (x + 1, z + h - 1)], 2.3, alfa("#6a4a2a", 0.55))
    kutu(-140, 24, 140, 34, 1.5, 6, ton("#3d464f", f=(0.7, 0.9, 1.0, 1.15)), bevel=0.6)
    kutu(-140, 32, 140, 34, 1.3, 6, duz("#5d6772"))
    kutu(-136, -32, 136, -30, 1.8, 3, duz("#5d6772"))
    for x0 in (-14, 6):
        kutu(x0, -30, x0 + 8, -14, 1.6, 2.4, ton("#5d6772", f=(0.6, 0.85, 1.0, 1.2)), bevel=0.3)
    # asma kilit
    Mkl = I.cel("Kilit3", ["#4d545c", "#6f7880", "#98a2ab", "#c6ced5"], [0, .3, .62, .9])
    gx, gy = P(0, -14)
    L.halka("kanca", 7.2, 7.2, 1.4, gx, ez(gy, 0.6), 0.6, Mkl)
    elips(0, -24, 12, 10, 4, -1.5, Mkl, seg=24, ring=14)
    kutu(-2, -28, 2, -24, -5.6, -5.4, duz("#12161a"))
    kutu(-1, -31, 1, -27, -5.6, -5.4, duz("#12161a"))
    # tente (koyu, karli) + sonuk tabela
    kutu(-140, 36, 140, 62, -2, 4, ton("#3a1410", f=(0.7, 0.9, 1.0, 1.1)), bevel=0.8)
    kutu(-136, 39, 136, 59, -2.4, -1.6, ton("#521a14", f=(0.75, 0.92, 1.0, 1.08)), bevel=0.4)
    for i in range(12):
        sonuk = i in (2, 5, 9)
        elips(-129.5 + i * 23, 38, 2.4, 2.0, 1.4, -2.6, ton("#2b2620" if sonuk else "#4a4438", f=(0.8, 0.95, 1.0, 1.2)), seg=10, ring=6)
    kutu(-140, 62, 140, 65.5, -2.4, 4.5, ton("#c8d4e0", f=(0.82, 0.94, 1.0, 1.04), noise=0.15, ns=40), bevel=0.8)
    for i in range(13):
        tx = -80 + i * 12
        sk = i not in (5, 6, 7)
        z0, z1 = (28, 35) if sk else (20, 29)
        levha([(tx, z0), (tx + 12, z0), (tx + 12, z1), (tx, z1)], -6 if sk else -7, ton("#6b1a14" if i % 2 == 0 else "#8a8478", f=(0.7, 0.9, 1.0, 1.1)))
    kutu(-80, 33, 76, 36, -6.5, -2, ton("#c8d4e0", noise=0.15, ns=40), bevel=0.5)
    # saksi + guller, mum tutucu
    gx, gy = P(-162, -38)
    T.torna("saksi", [(5.2, 0), (6.4, 12)], gx, gy, -10, 0.8, ton("#3a3f48", f=(0.7, 0.9, 1.0, 1.3)), K, seg=16)
    for fx, fz in ((-167, -14), (-161, -8), (-155, -16)):
        uzuv((fx + 1, -26), (fx + 1, fz), 0.8, -10.5, ton("#2f4a2a"))
        uzuv((fx + 1, fz - 7), (fx - 3, fz - 5), 0.8, -10.5, ton("#2f4a2a"))
        elips(fx + 1, fz + 4, 5.2, 4.2, 3.2, -11.5, I.cel("Gul%d" % fx, ["#6e1510", "#8e2018", "#c33c2c", "#e2604f"], [0, .3, .6, .88]), seg=14, ring=8)
    kutu(-146, -38, -140, -26, -10, -8, ton("#d8d2c0", f=(0.7, 0.9, 1.0, 1.04)), bevel=0.4)
    # sokak lambasi (soguk isik)
    Md = ton("#12161c", f=(0.8, 1.0, 1.0, 1.8))
    silindir_z(-203, -42, 66, -14, 3.0, Md, seg=12)
    pts = [(-203 + i * 4.2, 67 - i * 0.9) for i in range(10)]
    for a_, b_ in zip(pts, pts[1:]):
        uzuv(a_, b_, 1.1, -14, Md)
    kutu(-171, 53.5, -155, 60.5, -16, -12, ton("#1a1f26", f=(0.8, 1.0, 1.0, 1.8)), bevel=0.8)
    kutu(-168, 54.6, -158, 57, -16.3, -16, duz("#ffe6a8"))


def p3_isik():
    a = np_bos()
    X, Z = np_koord()
    r = np.clip(56 - Z, 0, None)
    ic = np.clip(np.minimum(X - (-178 - r * 0.43), (-148 + r * 0.43) - X) / 5.0, 0, 1) * (Z < 55)
    ustune(a, "#cfe0ff", ic * np.clip(1 - r / 100, 0, 1) * 0.16)
    d = np.hypot((X + 163) / 12, (Z - 56) / 6)
    ustune(a, "#fff2c0", np.clip(1 - d, 0, 1) ** 1.6 * 0.45)
    # kar yigintisi parlama (kaldirim)
    ustune(a, "#ffffff", np.clip(1 - np.abs(Z + 39) / 2.5, 0, 1) * 0.08)
    return a


def p3_kagit():
    Mk = I.cel("Tebligat", ["#b0a894", "#cfc7b2", "#e8e2d0", "#f6f2e6"], [0, .3, .62, .9])
    kutu(-84, -8, -58, 16, -8, -7.4, Mk, bevel=0.3)
    kutu(-80, 10, -62, 13, -8.2, -8.0, duz("#8a2018"))
    for i in range(4):
        x1 = -66 + (i % 2) * 4
        kutu(-80, 4 - i * 4, x1, 5 - i * 4, -8.2, -8.0, duz("#6b6558"))
    for x0 in (-87, -63):
        kutu(x0, 13, x0 + 8, 17, -8.6, -8.2, ton("#d8d2c0", f=(0.8, 0.94, 1.0, 1.03)), bevel=0.2)


# ================================================================ sahne 4 (icra yazisi)
def p4_zemin():
    a = np_bos()
    X, Z = np_koord()
    for z0, z1, renk in ((-62, -10, "#170f0a"), (-10, 34, "#20160e"), (34, 66, "#1a1109"), (66, 96, "#120c07")):
        m = ((Z >= z0) & (Z < z1)).astype(np.float32)
        a[..., :3] += m[..., None] * rgb(renk)
    a[..., 3] = 1.0
    return a


def p4_arka_3b():
    r = random.Random(4)
    for i in range(15):
        x = -220 + i * 30
        kutu(x - 1, -10, x + 2, 96, 6.0, 7.0, ton("#2a1c12", f=(0.8, 0.95, 1.0, 1.2)), bevel=0.3)
    for i in range(22):
        x0 = -236 + i * 22
        renk = T.hexmul("#3d2a1c", r.uniform(0.9, 1.1))
        kutu(x0, -61, x0 + 21.2, -16, 0.0, 30.0, ton(renk, f=(0.8, 0.94, 1.0, 1.06), noise=0.14, ns=22), bevel=0.25)
    kutu(-240, -16, 240, -13, -0.4, 30, ton("#7a5638", f=(0.75, 0.9, 1.0, 1.12)), bevel=0.5)
    kutu(-240, -13, 240, -6, 4.0, 5.0, ton("#3d2a1c"))
    # gozluk
    Mg = ton("#d8ac35", f=(0.6, 0.85, 1.0, 1.3))
    for cx in (-158, -128):
        gx, gy = P(cx, -2)
        L.halka("cam", 10.5, 10.5, 0.9, gx, ez(gy, -4.0), -4.0, Mg)
        levha([(cx - 9, -11), (cx + 9, -11), (cx + 9, 7), (cx - 9, 7)], -3.8, alfa("#b0c6d2", 0.22))
    uzuv((-147, -1.5), (-139, -1.5), 0.9, -4.0, Mg)
    uzuv((-169, -1.5), (-176, -0.5), 0.9, -3.0, Mg)
    # cay: tabak, ince belli cam, kasik, kup seker
    gx, gy = P(146, -10)
    I.yatay_elips("tabak", gx, gy, 20, 1.0, ton("#b0c6d2", f=(0.62, 0.85, 1.0, 1.12)), K, ry_ekran=3.2, seg=32).location = (gx, -6.0, ez(gy, -6.0))
    gx, gy = P(146, -12)
    Mc = alfa("#dfeef6", 0.28)
    T.torna("cam", [(9.6, 0), (7.6, 8), (6.2, 15), (8.2, 23), (10.8, 30)], gx, gy, -8, 0.8, Mc, K, seg=24, kapak=False)
    Mt = I.cel("Cay", ["#8a4410", "#c06a18", "#e08a28", "#f0a848"], [0, .3, .6, .88])
    T.torna("cay", [(8.2, 0), (6.4, 7.5), (5.2, 14), (7.0, 21.5), (8.6, 25.5)], gx, gy - 1.5, -8, 0.78, Mt, K, seg=24)
    silindir_z(162, 0, 28, -9.5, 0.9, ton("#98a2ab", f=(0.6, 0.85, 1.0, 1.35)), seg=8)
    kutu(158, 26, 166, 31, -10.5, -8.8, ton("#c6ced5", f=(0.6, 0.85, 1.0, 1.25)), bevel=0.8)
    for x0, z0 in ((176, -8), (184, -6)):
        kutu(x0, z0, x0 + 7, z0 + 6, -8, -2, ton("#f4f0e6", f=(0.75, 0.9, 1.0, 1.03), noise=0.2, ns=60), bevel=0.4)


def p4_isik():
    a = np_bos()
    X, Z = np_koord()
    d = np.sqrt((X / 130) ** 2 + ((Z + 30) / 26) ** 2)
    ustune(a, "#ffcf7a", np.clip(1 - d, 0, 1) ** 1.2 * 0.22)
    for cx, x0, x1 in ((-143, -172, -114), (154, 122, 186)):
        m = np.clip(1 - np.abs(X - cx) / ((x1 - x0) / 2), 0, 1) * np.clip(1 - np.abs(Z + 13) / 3, 0, 1)
        ustune(a, "#000000", m * 0.4)
    return a


def p4_lamba():
    Md = ton("#1a1208", f=(0.8, 1.0, 1.0, 1.8))
    silindir_z(0, 84, 110, -2.0, 1.2, Md, seg=8)
    gx, gy = P(0, 78)
    T.torna("duy", [(5.0, 0), (5.0, 3.0), (2.4, 6.0)], gx, gy, -2.0, 0.8, ton("#3a2f20", f=(0.7, 0.92, 1.0, 1.3)), K, seg=16)
    elips(0, 71, 7.6, 9.4, 6.0, -2.4, duz("#ffe9a8"), seg=16, ring=12)
    elips(-2, 73, 3.6, 4.6, 3.0, -8.0, duz("#fff8d8"), seg=12, ring=8)


def p4_koni():
    a = np_bos()
    X, Z = np_koord()
    u = np.clip((70 - Z) / 132.0, 0, 1)
    yari = 12 + (70 - Z) / 4.4 * 6.0
    ic = np.clip((yari - np.abs(X)) / 12.0, 0, 1) * (Z <= 72)
    ustune(a, "#ffcf7a", ic * (0.5 - 0.3 * u) * 0.9 * np.clip((72 - Z) / 6, 0, 1))
    return a


def p4_kagit():
    kutu(-76, -18, 70, 60, -6, -5.4, ton("#cfc7b2", f=(0.8, 0.94, 1.0, 1.04)), bevel=0.3)
    kutu(-76, -18, 68, 59, -6.1, -5.8, ton("#e8e2d0", f=(0.82, 0.95, 1.0, 1.03), noise=0.06, ns=30))
    kutu(-74, -16, 64, 57, -6.2, -6.1, ton("#f8f4e8", f=(0.85, 0.96, 1.0, 1.02), noise=0.05, ns=30))
    kutu(-66, 42, -50, 56, -6.6, -6.2, ton("#8a8474"), bevel=0.3)
    kutu(-63, 45, -53, 53, -6.7, -6.6, duz("#cfc7b2"))
    kutu(-42, 40, 14, 45, -6.3, -6.2, duz("#6b6558"))
    kutu(-66, 34, 60, 36, -6.3, -6.2, duz("#8a8474"))
    for i in range(4):
        kutu(-66, 24 - i * 7, 58 - (30 if i == 3 else 0), 26 - i * 7, -6.3, -6.2, duz("#8a8474"))
    kutu(-54, -10, 50, 12, -6.5, -6.2, ton("#a8a090"), bevel=0.3)
    kutu(-52, -8, 48, 10, -6.6, -6.5, duz("#f2eede"))
    for i in range(9):
        kutu(20 + i * 4, -14 + (i % 3) * 2, 24 + i * 4, -12 + (i % 3) * 2, -6.3, -6.2, duz("#3a3a48"))


def p4_eller():
    for ex, yon in ((-84, -1), (78, 1)):
        levha([(ex - 16, -14), (ex + 16, -14), (ex + 16, -9), (ex - 16, -9)], -5.0, alfa("#000000", 0.42))
        Ms = ton("#c2b9a2", f=(0.72, 0.88, 1.0, 1.06))
        Mm = ton("#8a5230", f=(0.72, 0.9, 1.0, 1.1))
        uzuv((ex + yon * 9, -10), (ex + yon * 22, -14), 8.4, -1.0, ton("#a86a3e", f=(0.7, 0.88, 1.0, 1.1)))
        uzuv((ex + yon * 6, -9), (ex + yon * 10, -11), 8.8, -3.0, Ms)
        Mh = I.cel("Eller%d" % ex, ["#5e3820", "#7a4426", "#a86a3e", "#c9885a", "#e0a978"], [0, .2, .45, .72, .9])
        elips(ex + yon * 1, -3, 11, 9, 5, -8.0, Mh, seg=18, ring=12)
        for j, boy in enumerate((13, 20, 22, 19)):
            fz = -8 + j * 4.8
            fbas = ex - yon * 4
            fuc = ex - yon * boy
            uzuv((fbas, fz + 0.3), (fuc + yon * 1.5, fz + 0.3), 2.2, -10.0 - j * 0.2, Mh)
            elips(fuc + yon * 2, fz + 0.8, 1.6, 1.1, 0.6, -12.6, ton("#f0bd8a", f=(0.85, 0.95, 1.0, 1.05)), seg=8, ring=5)
        uzuv((ex + yon * 4, -11), (ex + yon * 9, -11), 3.2, -11.5, Mh)


def p4_vinyet():
    a = np_bos()
    X, Z = np_koord()
    kenar = np.clip((np.abs(X) - 150) / 40, 0, 1) * 0.5
    ust = np.clip((Z - 66) / 18, 0, 1) * 0.35
    alt = np.clip((-40 - Z) / 21, 0, 1) * 0.32
    al = 1 - (1 - kenar) * (1 - ust) * (1 - alt)
    a[..., 3] = al
    return a


# ================================================================ sahne 5 (anahtar, safak)
def p5_gok():
    a = np_bos()
    X, Z = np_koord()
    bant = [(-62, "#f0c070"), (6, "#f0c070"), (16, "#e0a758"), (26, "#c58a5c"), (36, "#9a6f72"), (46, "#6f6180"), (58, "#4d5478"), (72, "#33406c"), (96, "#22305c")]
    zs = np.array([b[0] for b in bant], np.float32)
    cs = np.array([rgb(b[1]) for b in bant], np.float32)
    for ch in range(3):
        a[..., ch] = np.interp(Z, zs, cs[:, ch])
    a[..., 3] = 1.0
    d = np.hypot(X - 180, Z - 72)
    ustune(a, "#f6d68a", np.clip((46 - d) / 16, 0, 1) * 0.75)
    ustune(a, "#fde8b0", np.clip((21 - d) / 2.5, 0, 1))
    ustune(a, "#fff6d8", np.clip((13 - d) / 2.0, 0, 1))
    return a


def p5_arka_3b():
    for x0, x1, h in ((-238, -172, 44), (-178, -126, 60), (128, 192, 52), (186, 238, 40)):
        kutu(x0, -36, x1, h, 20, 26, ton("#4a4258", f=(0.86, 0.96, 1.0, 1.06)))
        kutu(x0 - 2, h, x1 + 2, h + 3, 19.6, 26, duz("#5e5468"))
    for x0, x1 in ((-238, -144), (144, 238)):
        kutu(x0, -36, x1, 54, 8, 14, ton("#5a4c4a", f=(0.8, 0.93, 1.0, 1.08), noise=0.05))
        kutu(x0 - 1, 52, x1 + 1, 59, 7.2, 14, ton("#7a6656"), bevel=0.4)
        for c in range(3):
            for rr in range(3):
                kutu(x0 + 14 + c * 28, -22 + rr * 22, x0 + 26 + c * 28, -8 + rr * 22, 7.9, 8.2, duz("#3a3442"))
                kutu(x0 + 12 + c * 28, -24 + rr * 22, x0 + 28 + c * 28, -22 + rr * 22, 7.0, 8.2, ton("#7a6656"), bevel=0.3)
    kutu(-240, -61, 240, -48, 0, 2, ton("#3a3038", noise=0.08, ns=50))
    kutu(-240, -48, 240, -42, -0.2, 2, ton("#6a6058"))
    kutu(-240, -42, 240, -38, -0.4, 3, ton("#a8a096", noise=0.06), bevel=0.4)
    for i in range(11):
        kutu(-224 + i * 46, -42, -223 + i * 46, -38, -0.5, -0.3, duz("#7a7268"))
    kutu(-136, -30, 136, 2, 8, 10, duz("#3a2312"))
    for z0, z1, renk in ((-30, -24, "#a8631f"), (-24, -18, "#7d4116"), (-18, -10, "#552c11"), (-10, -4, "#3a1e0c"), (-4, 2, "#291406")):
        kutu(-136, z0, 136, z1, 7.9, 10, ton(renk, f=(0.85, 0.95, 1.0, 1.06), noise=0.08, ns=25))
    kutu(-128, -8, -92, -5, 5.0, 7.9, ton("#6b4122"), bevel=0.3)
    for i in range(5):
        renk = ["#3f79c0", "#c9302a", "#d8ac35"][i % 3]
        gx, gy = P(-124 + i * 7, -5)
        T.torna("kavanoz", [(2.0, 0), (2.2, 4.5), (1.4, 6)], gx, gy, 6.2, 0.8, ton(renk, f=(0.7, 0.9, 1.0, 1.3)), K, seg=12)
    kutu(30, -6, 108, -3, 5.0, 7.9, ton("#6b4122"), bevel=0.3)
    for i in range(5):
        x = 38 + i * 15
        kutu(x, -12, x + 2, -6, 6.0, 6.4, duz("#8a929a"))
        gx, gy = P(x + 1, -18)
        T.torna("et", [(3.0, 0), (3.4, 2.5), (2.6, 6)], gx, gy + 6, 6.2, 0.8, I.cel("Et5%d" % i, ["#7a4318", "#a5622a", "#d18c42", "#f0b269"], [0, .3, .6, .88]), K, seg=12)


def p5_isik():
    a = np_bos()
    X, Z = np_koord()
    d = np.sqrt((X / 150) ** 2 + ((Z + 20) / 22) ** 2)
    ustune(a, "#ffb04a", np.clip(1 - d, 0, 1) ** 1.3 * 0.18)
    return a


def p5_tezgah():
    kutu(-136, -30, 136, -18, -4, 0, ton("#6b4122", f=(0.7, 0.88, 1.0, 1.12), noise=0.08, ns=22), bevel=0.5)
    kutu(-136, -19.4, 136, -17, -4.4, 0, ton("#a8703f", f=(0.75, 0.9, 1.0, 1.15)), bevel=0.4)



def p5_cerceve():
    Ma = ton("#4a3524", f=(0.7, 0.88, 1.0, 1.18), noise=0.1, ns=26)
    kutu(-150, -38, -136, 40, -8, -2, Ma, bevel=0.8)
    kutu(136, -38, 150, 40, -8, -2, Ma, bevel=0.8)
    kutu(144, -38, 150, 40, -8.05, -2, duz("#33251a"))
    kutu(-150, 34, 150, 40, -8, -2, Ma, bevel=0.6)
    for x0 in (-150, 136):
        kutu(x0, -38, x0 + 14, -30, -8.3, -2, ton("#33251a"), bevel=0.4)
        for i in range(2):
            kutu(x0 + 1 + i * 7, -37, x0 + 7 + i * 7, -31, -8.6, -8.3, ton("#2f6b62" if i % 2 == 0 else "#3d8078", f=(0.75, 0.9, 1.0, 1.15)), bevel=0.3)


def p5_kepenk():
    """Kapali konum (alt = -30): lameller z -30..24, alt kol -33..-28. Kod
    acildikca yukari kaydirir ve z 24'ten yukarisini kirpar."""
    Ms = I.cel("Kepenk5", ["#2a3138", "#3a4148", "#48515a", "#5d6772", "#7a858f"], [0, .25, .5, .78, .93])
    for rr in range(18):
        z = -30 + rr * 3
        kutu(-136, z, 136, z + 3, -3.0, -2.2, Ms, bevel=0.45)
    for v in range(-132, 136, 26):
        kutu(v, -30, v + 2, 24, -3.3, -3.0, duz("#2f363c"))
    kutu(-136, -33, 136, -31, -3.4, -2.2, ton("#2a3138"), bevel=0.3)
    kutu(-136, -31, 136, -28, -3.6, -2.2, ton("#98a2ab", f=(0.62, 0.85, 1.0, 1.2)), bevel=0.5)


def p5_on():
    kutu(-140, 24, 140, 34, -5.5, -1, ton("#3d464f", f=(0.7, 0.9, 1.0, 1.15)), bevel=0.6)
    kutu(-140, 32, 140, 34, -5.7, -1, duz("#5d6772"))
    for x0 in (-142, 136):
        kutu(x0, -30, x0 + 6, 34, -5.5, -2, ton("#4a5058", f=(0.6, 0.85, 1.0, 1.25)), bevel=0.4)
    kutu(-140, 36, 140, 62, -8, -3, ton("#7a1a12", f=(0.7, 0.9, 1.0, 1.15)), bevel=0.8)
    kutu(-136, 39, 136, 59, -8.5, -7.5, ton("#a8281c", f=(0.75, 0.92, 1.0, 1.1)), bevel=0.4)
    for i in range(12):
        elips(-129.5 + i * 23, 38, 2.4, 2.0, 1.4, -8.6, ton("#8a7a4a", f=(0.8, 0.95, 1.0, 1.2)), seg=10, ring=6)


def p5_el():
    Mk = ton("#8e2018", f=(0.62, 0.84, 1.0, 1.18))
    kutu(150, -34, 240, -8, -12, -4, Mk, bevel=2.0)
    kutu(150, -12, 240, -8, -12.2, -4, ton("#c33c2c"))
    kutu(142, -36, 156, -6, -14, -5, ton("#e4dcc6", f=(0.72, 0.88, 1.0, 1.06)), bevel=1.2)
    Mh = I.cel("El5", ["#5e3820", "#6f4326", "#a86a3e", "#c9885a", "#e0a978"], [0, .2, .45, .72, .9])
    elips(127, -21.5, 16, 13, 8, -12, Mh, seg=20, ring=14)
    for i in range(4):
        fz = -33 + i * 7
        uzuv((126, fz + 3), (112, fz + 3), 3.6, -16 - i * 0.3, Mh)
    uzuv((130, -12), (122, -9.5), 3.6, -18, Mh)
    # anahtar: halka + govde + dis
    Mg = I.cel("Anahtar", ["#8a6a18", "#a8811f", "#d8ac35", "#ffd75e", "#fff2a8"], [0, .2, .45, .75, .92])
    gx, gy = P(106, -21)
    L.halka("halka", 12, 12, 2.2, gx, ez(gy, -15), -15, Mg)
    kutu(52, -25, 94, -18, -15.5, -13.5, Mg, bevel=0.8)
    kutu(52, -34, 62, -21, -15.3, -13.8, Mg, bevel=0.5)
    kutu(66, -32, 74, -21, -15.3, -13.8, Mg, bevel=0.5)
    kutu(52, -21, 58, -14, -15.3, -13.8, Mg, bevel=0.5)


# ================================================================ kayit
parca("p1_arka", (0, 0, PW, PH), None, tur="birlesik")
parca("p1_baba_govde", (0, 0, PW, PH), p1_baba_govde, cizgi_alfa=80)
parca("p1_baba_kol", (0, 0, PW, PH), p1_baba_kol, cizgi_alfa=80)
parca("p1_baba_bas", (0, 0, PW, PH), p1_baba_bas(False), cizgi_alfa=80)
parca("p1_baba_bas_kirp", (0, 0, PW, PH), p1_baba_bas(True), cizgi_alfa=80)
parca("p1_tezgah", (0, 0, PW, PH), p1_tezgah, cizgi_alfa=70)
parca("p1_on", (0, 0, PW, PH), p1_on, cizgi_alfa=80)
for _i in range(3):
    parca("p1_kisi_%d" % _i, (0, 0, PW, PH), p1_kisi(_i), cizgi_alfa=90)
for _b in range(-3, 4):
    for _z in (0, 1):
        parca("p1_yuru_%d_%d" % (_b, _z), (-20, 0, 40, PH), p1_yuru(_b, _z), cizgi_alfa=90)
parca("p1_lamba", (0, 0, PW, PH), p1_lamba, cizgi_alfa=90)
parca("p1_lamba_isik", (0, 0, PW, PH), p1_lamba_isik, tur="np")
BIRLESIK = {"p1_arka": (p1_gok, p1_arka_3b, p1_isik_katman, "#2a2622"),
            "p2_arka": (p2_zemin, p2_arka_3b, None, "#1a0e08"),
            "p3_arka": (p3_gok, p3_arka_3b, p3_isik, "#0a0c10"),
            "p4_arka": (p4_zemin, p4_arka_3b, p4_isik, "#0a0604"),
            "p5_arka": (p5_gok, p5_arka_3b, p5_isik, "#2a1e18")}
parca("p2_arka", (0, 0, PW, PH), None, tur="birlesik")
parca("p2_ocak_arka", (0, 0, PW, PH), p2_ocak_arka, cizgi_alfa=60)
parca("p2_ocak_on", (0, 0, PW, PH), p2_ocak_on, cizgi_alfa=60)
parca("p2_ocak_ust", (0, 0, PW, PH), p2_ocak_ust, cizgi_alfa=60)
parca("p2_hale", (0, 0, PW, PH), p2_hale, tur="np")
parca("p2_baba", (0, 0, PW, PH), p2_baba, cizgi_alfa=90, k=0.12)
parca("p2_goz_acik", (0, 0, PW, PH), p2_goz(True), cizgi=None, k=0.12)
parca("p2_goz_kapali", (0, 0, PW, PH), p2_goz(False), cizgi=None, k=0.12)
parca("p2_puskul", (0, 0, PW, PH), p2_puskul, cizgi_alfa=80, k=0.12)
parca("p2_kol", (0, 0, PW, PH), p2_kol, cizgi_alfa=90, k=0.12)
parca("p2_atmosfer", (0, 0, PW, PH), p2_atmosfer, tur="np")
parca("p3_arka", (0, 0, PW, PH), None, tur="birlesik")
parca("p3_kagit", (0, 0, PW, PH), p3_kagit, cizgi_alfa=80)
parca("p4_arka", (0, 0, PW, PH), None, tur="birlesik")
parca("p4_lamba", (0, 0, PW, PH), p4_lamba, cizgi_alfa=70)
parca("p4_koni", (0, 0, PW, PH), p4_koni, tur="np")
parca("p4_kagit", (0, 0, PW, PH), p4_kagit, cizgi_alfa=70, k=0.1)
parca("p4_eller", (0, 0, PW, PH), p4_eller, cizgi_alfa=90, k=0.1)
parca("p4_vinyet", (0, 0, PW, PH), p4_vinyet, tur="np")
parca("p5_arka", (0, 0, PW, PH), None, tur="birlesik")
parca("p5_tezgah", (0, 0, PW, PH), p5_tezgah, cizgi_alfa=70)
parca("p5_cerceve", (0, 0, PW, PH), p5_cerceve, cizgi_alfa=70)
parca("p5_kepenk", (0, 0, PW, PH), p5_kepenk, cizgi_alfa=60)
parca("p5_on", (0, 0, PW, PH), p5_on, cizgi_alfa=70)
parca("p5_el", (0, 0, PW, PH), p5_el, cizgi_alfa=90, k=0.12)


def renderla(fn, yol, k):
    global K
    eski = K
    K = k
    sahne()
    fn()
    px.shear_scene(K)
    px.render(yol)
    K = eski
    return yol


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, tur, k = PARCALAR[ad]
    yol = os.path.join(OUT, ad + ".png")
    if tur == "np":
        px.reset()
        return px.write_png((np.clip(fn(), 0, 1) * 255 + 0.5).astype(np.uint8), yol)
    if tur == "birlesik":
        gok_fn, model_fn, isik_fn, cizgi_r = BIRLESIK[ad]
        gok = gok_fn()
        tmp = renderla(model_fn, os.path.join(OUT, "_%s_3b.png" % ad), k)
        px.outline(tmp, hexcol=cizgi_r, alpha=50)
        b = px.read_png(tmp).astype(np.float32) / 255.0
        al = b[..., 3:4]
        gok[..., :3] = gok[..., :3] * (1 - al) + b[..., :3] * al
        if isik_fn:
            isik = isik_fn()
            al = isik[..., 3:4]
            gok[..., :3] = gok[..., :3] * (1 - al) + isik[..., :3] * al
        gok[..., 3] = 1.0
        return px.write_png((np.clip(gok, 0, 1) * 255 + 0.5).astype(np.uint8), yol)
    if gx0 == 0 and w == PW:
        renderla(fn, yol, k)
    else:
        _dar(fn, yol, k, gx0, gy0, w, h)
    if cizgi:
        px.outline(yol, hexcol=cizgi, alpha=cizgi_alfa)
    return yol


def _dar(fn, yol, k, gx0, gy0, w, h):
    """Kisi gibi pb x=0'a gore modellenen parcalar: tuval x (200+gx0 .. )."""
    global K
    eski = K
    K = k
    D.sahne(200.0 + gx0, gy0, w, h, 1.0)
    _MAT.clear()
    g = [o for o in bpy.context.scene.objects if o.type == "LIGHT"][0]
    g.rotation_euler = Vector((-0.45, 0.62, -0.62)).normalized().to_track_quat("-Z", "Y").to_euler()
    fn()
    px.shear_scene(K)
    px.render(yol)
    K = eski
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = [a for a in PARCALAR if not argv or any(a.startswith(x) for x in argv)]
    for ad in adlar:
        uret(ad)
        print("  ", ad)
    kok = {k: [float(v[0]), float(v[1])] for k, v in KOKEN.items()}
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR), "kokenler": kok}, fp, indent=1)
    print("PROLOG_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
