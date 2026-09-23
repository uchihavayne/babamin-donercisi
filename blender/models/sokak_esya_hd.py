"""SOKAK ESYALARI — remake HD (art.js drawStreetProps, drawNearProps,
drawSokakAgaci, drawSehirIkonu).

    blender --background --factory-startup --python blender/models/sokak_esya_hd.py [-- ad ...]
    python blender/hd_atlas.py sokak_esya_hd sokak_esya

Her kare camin arkasinda, sokak aktorlerinin arasinda cizilen esyalar. Durum
degistirenler ayri parca: sokak lambasi (acik mercek + isik konisi), trafik
lambasi (yanan mercek + renkle boyanan parilti), yaya lambasi (yuru / dur).
Capa = eski fonksiyonun (x, y) noktasi.
  agac_<yaprak|budanmis|sakura|palmiye>     capa (tx, ty)
  lamba, lamba_acik, lamba_isik              capa (lx, ly)
  durak                                      capa (bsx, bsy)
  sehir_<posta|simit|sutun|kulube|sarisari|kafe|palmiye|otomat|musluk>  capa (x, y)
  trafik_govde, trafik_<kirmizi|sari|yesil>, trafik_isik (merkez)  capa (trx, try0)
  yaya_govde, yaya_yuru, yaya_dur            capa (pwx, try0)
  bisiklet, cop                              capa (pbx, pby), (kx, pby)
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

OUT = os.path.join(_HERE, "out", "sokak_esya_hd")
HD = 2
K = S.K
ez = T.ez
kutu, cerceve, on_levha, silindir_z, silindir_x, elipsoid = S.kutu, S.cerceve, S.on_levha, S.silindir_z, S.silindir_x, S.elipsoid
mat_ton, mat_duz, mat_alfa, hexmul = S.mat_ton, S.mat_duz, S.mat_alfa, T.hexmul
PARCALAR, KOKEN = {}, {}


def parca(ad, tuval, fn, cizgi="#1e1a1a", cizgi_alfa=110, tur="3b"):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa, tur)
    KOKEN[ad] = (tuval[0], tuval[1])


def serit(noktalar, genislik, y, mat, ad="serit"):
    """Ekran noktalarindan gecen, genisligi uca dogru degisen on yuz seridi
    (palmiye yapragi, dal). genislik: t (0..1) -> px."""
    bm = bmesh.new()
    n = len(noktalar)
    sol, sag = [], []
    for k, (x, gy) in enumerate(noktalar):
        a = noktalar[max(0, k - 1)]
        b = noktalar[min(n - 1, k + 1)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        u = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / u, dx / u
        w = genislik(k / (n - 1)) / 2.0
        sol.append(bm.verts.new((x + nx * w, y, ez(gy + ny * w, y, K))))
        sag.append(bm.verts.new((x - nx * w, y, ez(gy - ny * w, y, K))))
    for k in range(n - 1):
        bm.faces.new((sol[k], sol[k + 1], sag[k + 1], sag[k]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        if f.normal.y > 0:
            f.normal_flip()
    return I.mesh_ob(ad, bm, mat, smooth=True)


def yaprak_top(cx, gy, rx, ry, y, mat, tohum):
    """Yaprak kumesi: gurultuyle bozulmus elipsoid."""
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=3, radius=1.0)
    r = random.Random(tohum)
    faz = [r.uniform(0, 6.28) for _ in range(6)]
    for v in bm.verts:
        c = v.co
        d = 1.0 + 0.09 * math.sin(c.x * 5.1 + faz[0]) * math.sin(c.z * 4.3 + faz[1]) + 0.07 * math.sin(c.y * 6.7 + faz[2])
        v.co = Vector((c.x * rx * d, c.y * min(rx, ry) * 0.7 * d, c.z * ry * d))
    ob = I.mesh_ob("yaprak", bm, mat, smooth=True)
    ob.location = (cx, y, ez(gy, y, K))
    return ob


def govde(x, gy0, gy1, r0, r1, y, mat):
    """Konik agac govdesi (gy1 taban, gy0 tepe)."""
    return T.torna("govde", [(r1, 0), (r0, gy1 - gy0)], x, gy1, y, 1.0, mat, K, seg=10)


def dal(x0, g0, x1, g1, kal, y, mat):
    return serit([(x0, g0), ((x0 + x1) / 2 + 0.3, (g0 + g1) / 2 - 0.4), (x1, g1)], lambda t: kal * (1 - 0.6 * t), y, mat)


def cukur(y=0.0):
    """Agac cukuru (9x3): toprak + demir izgara kenari."""
    kutu(-4.5, 4.5, -2.0, 1.0, y - 1.0, y + 3.0, mat_ton("#5a4a32", noise=0.2, ns=60), bevel=0.3)
    cerceve(-5.0, 5.0, -2.2, 1.0, 0.6, y - 1.2, y + 3.2, mat_ton("#3a3f45", f=(0.6, 0.85, 1.0, 1.2)))


# ================================================================ agaclar
def agac_yaprak():
    cukur()
    Mg = mat_ton("#6b533a", f=(0.7, 0.88, 1.0, 1.15), noise=0.1, ns=40)
    govde(0.5, -20, -1, 1.0, 1.6, 0.0, Mg)
    dal(0.5, -14, -4, -18, 1.2, -0.6, Mg)
    dal(0.5, -16, 4.5, -20, 1.2, -0.6, Mg)
    Mf = S.I.cel("AgacY", ["#1f4424", "#2f5a30", "#3d6f39", "#4d8544", "#63a052"], [0, .25, .45, .7, .9], noise=0.22, noise_scale=3.5)
    yaprak_top(0.0, -25, 11, 8, 1.0, Mf, 1)
    yaprak_top(-4.5, -27, 7, 6, -1.0, Mf, 2)
    yaprak_top(5.0, -24, 7, 5, -1.5, Mf, 3)
    yaprak_top(-1.0, -29.5, 6, 4.5, -2.0, Mf, 4)


def agac_budanmis():
    cukur()
    Mg = mat_ton("#6b6252", f=(0.7, 0.88, 1.0, 1.15), noise=0.08, ns=40)
    govde(0.5, -22, -1, 1.0, 1.5, 0.0, Mg)
    Mf = S.I.cel("AgacB", ["#1f4424", "#2f5a30", "#3d6f39", "#4d8544", "#5b9a4e"], [0, .25, .45, .7, .9], noise=0.18, noise_scale=5)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co = Vector((v.co.x * 19, v.co.y * 9, v.co.z * 10))
    bmesh.ops.bevel(bm, geom=bm.edges[:], offset=2.2, segments=4, affect="EDGES")
    r = random.Random(9)
    for v in bm.verts:
        v.co += Vector((r.uniform(-.3, .3), r.uniform(-.3, .3), r.uniform(-.3, .3)))
    ob = I.mesh_ob("budanmis", bm, Mf, smooth=True)
    ob.location = (0.5, 1.0, ez(-26.5, 1.0, K))


def agac_sakura():
    cukur()
    Mg = mat_ton("#5a4436", f=(0.7, 0.88, 1.0, 1.18), noise=0.1, ns=40)
    govde(0.5, -19, -1, 1.0, 1.6, 0.0, Mg)
    dal(0.5, -13, -4.5, -18, 1.2, -0.6, Mg)
    dal(0.5, -15, 5.5, -19, 1.2, -0.6, Mg)
    Mf = S.I.cel("Sakura", ["#a85a76", "#c9738f", "#e090aa", "#f7b8ce", "#ffd8e6"], [0, .25, .45, .72, .92], noise=0.22, noise_scale=3.5)
    yaprak_top(0.0, -24, 11, 7, 1.0, Mf, 5)
    yaprak_top(-5.0, -26, 7, 5, -1.0, Mf, 6)
    yaprak_top(5.0, -23, 7, 5, -1.5, Mf, 7)
    yaprak_top(-1.0, -28, 6, 4, -2.0, Mf, 8)
    for k in range(9):
        x = -8 + S.hash1(k * 3.7) * 16
        gy = -29 + S.hash1(k * 5.1) * 12
        elipsoid(x, gy, 0.55, 0.45, 0.3, -6.0, mat_duz("#ffe6ee"), seg=6, ring=4)
    # dusen yapraklar
    for k in range(4):
        elipsoid(-7 + k * 4.5, -6 - (k % 2) * 5, 0.5, 0.35, 0.2, -3.0, mat_duz("#f7b8ce"), seg=6, ring=4)


def agac_palmiye():
    cukur()
    Mg = mat_ton("#6b533a", f=(0.7, 0.9, 1.0, 1.18), noise=0.08, ns=30)
    noktalar = [(0.5 + round(math.sin(s * 0.16) * 2), -2 - s) for s in range(0, 24, 2)]
    for k, (x, gy) in enumerate(noktalar):              # halkali govde
        T.torna("halka", [(1.25, 0), (1.45, 1.2), (1.1, 2.0)], x, gy, 0.0, 1.0, Mg if k % 2 else mat_ton("#87694a", f=(0.7, 0.9, 1.0, 1.15)), K, seg=10)
    py0 = -26
    pxx = 0.5 + round(math.sin(23 * 0.16) * 2)
    Mf1 = mat_ton("#3f8a4a", f=(0.62, 0.8, 1.0, 1.2))
    for p in range(7):
        pa = -2.95 + p * 0.49
        pts = []
        for k in range(9):
            t = k / 8
            pts.append((pxx + math.cos(pa) * 13 * t, py0 + math.sin(pa) * 9 * t + 5.0 * t * t * (0.4 + abs(math.cos(pa)) * 0.6)))
        serit(pts, lambda t: 0.6 + 2.4 * math.sin(t * math.pi) ** 0.8, -1.5 + p * 0.3, Mf1, "frond")
        # orta damar
        serit(pts, lambda t: 0.35 * (1 - t), -1.6 + p * 0.3, mat_ton("#2f6a34"), "damar")
    for hd_ in range(3):
        elipsoid(pxx - 1.5 + hd_ * 1.5, py0 + 2.2, 0.9, 0.9, 0.9, -1.8, mat_ton("#b0862a", f=(0.6, 0.85, 1.0, 1.15)), seg=8, ring=6)


# ================================================================ lamba, durak
def lamba():
    Mp = mat_ton("#4d545b", f=(0.6, 0.82, 1.0, 1.35))
    kutu(-3, 4, -1, 1, -1.5, 1.5, mat_ton("#3d434a"), bevel=0.3)
    silindir_z(0.5, -34, -1, 0.0, 1.2, Mp, seg=10)
    silindir_z(0.5, -3.5, -1, 0.0, 1.6, Mp, seg=10)
    serit([(0.5, -33.5), (3.0, -35.6), (7.5, -36.0)], lambda t: 1.0, -0.2, Mp, "kol")
    kutu(6, 14, -37, -34, -1.5, 1.5, mat_ton("#5b636b", f=(0.6, 0.82, 1.0, 1.3)), bevel=0.5)
    kutu(7, 13, -34, -33, -1.0, 1.0, mat_duz("#8f979f"))


def lamba_acik():
    kutu(7, 13, -34, -33, -1.0, 1.0, mat_duz("#fff4c0"))
    kutu(8, 12, -34, -33.4, -1.1, 0.8, mat_duz("#ffffff"))


def lamba_isik():
    a = np.zeros((20 * HD, 34 * HD, 4), np.float32)
    yy, xx = np.mgrid[0:20 * HD, 0:34 * HD].astype(np.float32) + 0.5
    X = xx / HD - 7.0
    Y = yy / HD - 33.0
    r = Y + 32.0
    sol = 8.0 - r
    sag = 12.0 + r
    ic = np.clip(np.minimum(X - sol, sag - X) / 2.5, 0, 1) * (r >= 0)
    boy = np.clip(1.0 - r / 13.0, 0, 1)
    al = ic * boy * 0.34
    c = S.rgb("#ffe9a0")
    a[..., :3] = c
    a[..., 3] = al
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


def durak():
    Mp = mat_ton("#5a636b", f=(0.6, 0.82, 1.0, 1.3))
    for x in (1.0, 31.0):
        silindir_z(x, -22, 0, 0.0, 1.0, Mp, seg=10)
    kutu(-2, 34, -25, -22, -3.0, 5.0, mat_ton("#3f6fbd", f=(0.62, 0.82, 1.0, 1.25)), bevel=0.5)
    on_levha([(2, -22), (30, -22), (30, -8), (2, -8)], 3.0, mat_alfa("#cfe4f2", 0.32))
    kutu(2, 30, -22, -21.4, 2.8, 3.2, mat_duz("#8a9aa8"))
    kutu(8, 22, -20, -12, 1.6, 2.6, mat_ton("#2f4f6a"), bevel=0.3)
    kutu(9, 21, -19, -13, 1.4, 1.6, mat_duz("#e8ecef"))
    kutu(10, 20, -17.2, -16.6, 1.3, 1.4, mat_duz("#3f6fbd"))
    kutu(10, 17, -15.2, -14.7, 1.3, 1.4, mat_duz("#8a9aa8"))
    elipsoid(14.5, -18, 0.8, 0.8, 0.2, 1.3, mat_duz("#e2483a"), seg=8, ring=4)
    Mb = mat_ton("#7a5a3a", f=(0.62, 0.84, 1.0, 1.2), noise=0.06)
    kutu(4, 28, -7.2, -6.2, -1.0, 2.0, Mb, bevel=0.2)
    kutu(4, 28, -12, -9.5, 1.8, 2.4, Mb, bevel=0.2)
    for x in (6, 25):
        kutu(x, x + 1, -6.2, 0, 0.0, 1.0, mat_ton("#5a4a32"))


# ================================================================ sehir ikonlari
def sehir_posta():
    Mk = mat_ton("#c0392b", f=(0.6, 0.82, 1.0, 1.2))
    kutu(0, 7, -12, 0, -1.5, 2.5, Mk, bevel=0.6)
    T.torna("kubbe", [(3.5, 0), (3.2, 1.2), (1.5, 2.4), (0.1, 2.6)], 3.5, -12, 0.5, 0.6, Mk, K, seg=16)
    kutu(1, 6, -10, -9.2, -1.7, -1.4, mat_duz("#3a1a14"))
    kutu(1.5, 5.5, -7, -4.5, -1.6, -1.4, mat_duz("#f0d78a"))
    kutu(-0.5, 7.5, -0.8, 0.4, -2.0, 3.0, mat_ton("#5a636b"), bevel=0.2)


def sehir_simit():
    Mk = mat_ton("#c0392b", f=(0.6, 0.82, 1.0, 1.2))
    kutu(-3, 13, -11, -2, -2.0, 3.0, Mk, bevel=0.5)
    cerceve(-2, 12, -10, -3, 0.8, -2.1, -1.6, mat_ton("#e2604f"))
    kutu(-4, 14, -14.2, -11, -3.0, 4.0, mat_ton("#e8ecef", f=(0.7, 0.88, 1.0, 1.04)), bevel=0.5)
    for s in range(3):
        L.halka("simit", 1.5, 1.5, 0.55, 1.5 + s * 4, ez(-7, -2.4, K), -2.4, mat_ton("#c9a03a", f=(0.6, 0.85, 1.0, 1.15)))
        for k in range(5):
            elipsoid(0.5 + s * 4 + math.cos(k * 1.3) * 1.5, -7 + math.sin(k * 1.3) * 1.5, 0.25, 0.25, 0.25, -2.9, mat_duz("#fff2c8"), seg=4, ring=3)
    for x in (1.5, 9.5):
        L.silindir("teker", 2.0, x, -2.5, ez(-1.5, -2.5, K), 1.0, mat_ton("#3a3f45", f=(0.6, 0.85, 1.0, 1.2)), seg=14, eksen="Y")
        L.silindir("gobek", 0.6, x, -3.1, ez(-1.5, -3.1, K), 0.3, mat_duz("#8f979f"), seg=8, eksen="Y")
    serit([(13, -6), (16, -8), (17.5, -8.4)], lambda t: 0.6, -1.0, mat_ton("#5a636b"), "sap")


def sehir_sutun():
    Ms = mat_ton("#5a4a6a", f=(0.6, 0.82, 1.0, 1.2))
    T.torna("sutun", [(5.5, 0), (5.5, 19)], 5.5, 0, 1.0, 0.6, Ms, K, seg=24, kapak=False)
    T.torna("sapka", [(6.5, 0), (6.6, 1.5), (5.2, 3.0), (0.3, 4.2)], 5.5, -19, 1.0, 0.6, mat_ton("#2f343a", f=(0.6, 0.85, 1.0, 1.4)), K, seg=24)
    kutu(2, 9, -16, -10, -2.6, -2.3, mat_ton("#d8a03c", f=(0.75, 0.9, 1.0, 1.08)))
    kutu(3, 8, -14.2, -13.6, -2.7, -2.6, mat_duz("#6b4a10"))
    kutu(2, 9, -8, -3, -2.6, -2.3, mat_ton("#c0392b", f=(0.75, 0.9, 1.0, 1.08)))
    kutu(3, 8, -6.2, -5.6, -2.7, -2.6, mat_duz("#6b1a12"))
    T.torna("taban", [(6.2, 0), (6.2, 1.2)], 5.5, 0, 1.0, 0.6, mat_ton("#2f343a"), K, seg=24)


def sehir_kulube():
    Mk = mat_ton("#c0392b", f=(0.6, 0.82, 1.0, 1.2))
    kutu(-1, 12, -23, 0, -1.5, 4.0, Mk, bevel=0.4)
    for kk in range(3):
        for jj in range(2):
            x0, g0 = 1 + jj * 5, -20 + kk * 6
            kutu(x0, x0 + 4, g0, g0 + 5, -1.8, -1.55, mat_ton("#2c3b45", f=(0.8, 0.9, 1.0, 1.1)))
            on_levha([(x0 + 2.4, g0 + 0.3), (x0 + 3.3, g0 + 0.3), (x0 + 1.4, g0 + 4.7), (x0 + 0.5, g0 + 4.7)], -1.9, mat_alfa("#bfe4f2", 0.4))
    kutu(-2, 13, -26, -23, -2.2, 4.6, Mk, bevel=0.6)
    T.torna("tepe", [(4.5, 0), (3.5, 1.2), (0.3, 1.8)], 5.5, -26, 1.2, 0.8, Mk, K, seg=16)
    kutu(1, 10, -25.2, -24, -2.35, -2.25, mat_duz("#fff2c8"))


def sehir_sarisari():
    Mw = mat_ton("#8a6a48", f=(0.6, 0.82, 1.0, 1.18), noise=0.08)
    kutu(-4, 15, -11, 0, -1.5, 3.0, Mw, bevel=0.4)
    for k in range(4):
        kutu(-3.5, 14.5, -9.5 + k * 2.6, -9.0 + k * 2.6, -1.6, -1.5, mat_duz("#6b533a"))
    bm = bmesh.new()
    v = [bm.verts.new((-6, -4.0, ez(-11, -4.0, K))), bm.verts.new((17, -4.0, ez(-11, -4.0, K))),
         bm.verts.new((16, 3.0, ez(-14.5, 3.0, K))), bm.verts.new((-5, 3.0, ez(-14.5, 3.0, K)))]
    bm.faces.new(v)
    bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.5)
    I.mesh_ob("cati", bm, mat_ton("#3f8a4a", f=(0.6, 0.82, 1.0, 1.2)), smooth=False)
    renk = ["#e8b62c", "#c0392b", "#3f6fbd", "#e07a2a", "#7a4a9a", "#2aa08a", "#e2604f"]
    for pp in range(7):
        kutu(-4 + pp * 3, -2 + pp * 3, -11, -7.5, -4.2, -3.6, mat_ton(renk[pp], f=(0.7, 0.88, 1.0, 1.12)))
    kutu(2, 8, -8, -4, -1.9, -1.6, mat_ton("#e8ecef", f=(0.8, 0.92, 1.0, 1.04)))


def sehir_kafe():
    T.torna("semsiye", [(6.5, 0), (5.0, 1.0), (0.3, 2.6)], 4.5, -10, 0.0, 0.6, mat_ton("#e8ecef", f=(0.66, 0.86, 1.0, 1.04)), K, seg=20, kapak=False)
    elipsoid(4.5, -12.8, 0.6, 0.6, 0.6, 0.0, mat_duz("#c0392b"), seg=6, ring=4)
    silindir_z(4.5, -12, 0, 0.0, 0.35, mat_ton("#6f777f"), seg=6)
    T.torna("masa", [(2.8, 0), (2.8, 0.6)], 4.5, -4.2, 0.0, 0.6, mat_ton("#8a6a48"), K, seg=16)
    kutu(3, 6, -2, 0, -1.0, 1.0, mat_ton("#4d545b"), bevel=0.3)
    for x in (-3.0, 10.0):
        Mc = mat_ton("#3f8a5a", f=(0.6, 0.82, 1.0, 1.2))
        kutu(x - 1, x + 3, -13, -7, 0.5, 1.2, Mc, bevel=0.3)
        kutu(x - 1, x + 3, -7.4, -6.2, -2.0, 1.2, Mc, bevel=0.2)
        for dx in (-0.6, 2.2):
            kutu(x + dx, x + dx + 0.6, -6.2, 0, -1.6, -1.2, mat_ton("#2f6a4a"))


def sehir_palmiye():
    kutu(1, 10, -6, 0, -2.0, 3.0, mat_ton("#c09868", f=(0.62, 0.84, 1.0, 1.15), noise=0.08), bevel=0.5)
    kutu(0.5, 10.5, -6.6, -5.4, -2.3, 3.3, mat_ton("#d8b088"), bevel=0.3)
    T.torna("govde", [(1.2, 0), (1.0, 11)], 5.5, -6, 0.5, 1.0, mat_ton("#6b533a", f=(0.7, 0.9, 1.0, 1.18), noise=0.1), K, seg=10)
    for pd in range(6):
        pa = -2.85 + pd * 0.55
        pts = [(5.5 + math.cos(pa) * 9 * t, -18 + math.sin(pa) * 6 * t + 3 * t * t) for t in [k / 7 for k in range(8)]]
        S_ = serit(pts, lambda t: 0.5 + 1.8 * math.sin(t * math.pi), -1.0 + pd * 0.2, mat_ton("#3f8a4a", f=(0.62, 0.82, 1.0, 1.2)), "frond")


def sehir_otomat():
    kutu(-1, 13, -21, 0, -2.0, 4.0, mat_ton("#2f343a", f=(0.6, 0.85, 1.0, 1.3)), bevel=0.4)
    kutu(0, 12, -20, 0, -2.3, -2.0, mat_ton("#e8ecef", f=(0.72, 0.88, 1.0, 1.04)))
    kutu(1, 11, -19, -7, -2.5, -2.2, mat_duz("#16202c"))
    renk = ["#c0392b", "#3f6fbd", "#e8b62c", "#3f8a4a", "#e07a2a", "#e8ecef"]
    for oi in range(6):
        x = 2 + (oi % 3) * 3
        g = -18 + (oi // 3) * 5
        T.torna("kutu", [(0.9, 0), (0.9, 3.2), (0.5, 3.8)], x + 1, g + 4, -2.9, 0.5, mat_ton(renk[oi], f=(0.66, 0.86, 1.0, 1.15)), K, seg=8)
    on_levha([(1.2, -19), (3.5, -19), (1.2, -15)], -3.3, mat_alfa("#ffffff", 0.22))
    kutu(1, 11, -6, -4, -2.6, -2.2, mat_ton("#8f979f"))
    kutu(2, 6, -3, -2, -2.5, -2.2, mat_duz("#4d545b"))
    kutu(9, 10.5, -11, -8.5, -2.5, -2.2, mat_duz("#e8b62c"))


def sehir_musluk():
    Mk = mat_ton("#c0392b", f=(0.6, 0.82, 1.0, 1.2))
    T.torna("govde", [(3.0, 0), (2.6, 1), (2.6, 10), (3.4, 10.4), (3.4, 11.4), (1.6, 12.2), (1.4, 14.0), (0.2, 14.6)], 5.5, 0, 0.0, 1.0, Mk, K, seg=16)
    for x, yon in ((1.0, -1), (10.0, 1)):
        L.silindir("agiz", 1.1, x, 0.0, ez(-6.5, 0.0, K), 2.4, Mk, seg=10, eksen="X")
        L.silindir("kapak", 0.8, x + yon * 1.3, 0.0, ez(-6.5, 0.0, K), 0.6, mat_ton("#8a2318"), seg=8, eksen="X")
    L.silindir("on", 1.3, 5.5, -2.6, ez(-7.5, -2.6, K), 1.2, Mk, seg=10, eksen="Y")


# ================================================================ trafik ve yaya lambasi
def trafik_govde():
    Mp = mat_ton("#4d545b", f=(0.6, 0.82, 1.0, 1.3))
    silindir_z(0.5, -26, 0, 1.0, 1.2, Mp, seg=10)
    kutu(-2, 3, -1, 0.6, -0.5, 2.5, mat_ton("#3d434a"), bevel=0.3)
    kutu(-4, 5, -38, -25, -1.5, 3.0, mat_ton("#33383e", f=(0.6, 0.85, 1.0, 1.3)), bevel=0.5)
    for gy, renk in ((-34, "#5a2a26"), (-30.5, "#5a512a"), (-27, "#2a5a34")):
        L.silindir("mercek", 1.8, 0.5, -1.7, ez(gy, -1.7, K), 0.3, mat_duz(renk), seg=14, eksen="Y")
        # siperlik: merceg in ustunde yarim boru
        bm = bmesh.new()
        V = []
        for k in range(9):
            a = math.pi * k / 8
            x = 0.5 + math.cos(a) * 2.2
            g = gy - math.sin(a) * 2.2
            V.append((bm.verts.new((x, -1.6, ez(g, -1.6, K))), bm.verts.new((x, -3.2, ez(g, -3.2, K)))))
        for k in range(8):
            bm.faces.new((V[k][0], V[k + 1][0], V[k + 1][1], V[k][1]))
        bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.3)
        I.mesh_ob("siper", bm, mat_ton("#23272c", f=(0.6, 0.85, 1.0, 1.4)), smooth=True)


def trafik_mercek(gy, renk):
    def fn():
        L.silindir("mercek", 1.8, 0.5, -1.8, ez(gy, -1.8, K), 0.3, mat_duz(renk), seg=14, eksen="Y")
        elipsoid(0.0, gy - 0.6, 0.7, 0.5, 0.2, -2.0, mat_duz("#ffffff"), seg=8, ring=4)
    return fn


def isik_topu():
    n = 10 * HD
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
    d = np.hypot(xx - n / 2, yy - n / 2) / (4.6 * HD)
    a = np.zeros((n, n, 4), np.float32)
    a[..., :3] = 1.0
    a[..., 3] = np.clip(1 - d, 0, 1) ** 1.2
    return (a * 255 + 0.5).astype(np.uint8)


def yaya_govde():
    Mp = mat_ton("#4d545b", f=(0.6, 0.82, 1.0, 1.3))
    silindir_z(0.5, -16, 0, 1.0, 1.1, Mp, seg=10)
    kutu(-3, 4, -24, -15, -1.4, 2.4, mat_ton("#33383e", f=(0.6, 0.85, 1.0, 1.3)), bevel=0.4)
    for gy in (-21, -18):
        kutu(-2, 3, gy - 1.3, gy + 1.3, -1.6, -1.4, mat_duz("#1e2226"))


def yaya_isik(yuru):
    def fn():
        gy = -21 if yuru else -18
        renk = "#3fbf5a" if yuru else "#e2483a"
        M = mat_duz(renk)
        kutu(-2, 3, gy - 1.3, gy + 1.3, -1.7, -1.6, mat_duz("#15181b"))
        # kucuk insan simgesi: bas + govde + bacaklar (1.4 kat)
        elipsoid(0.5, gy - 1.3, 0.55, 0.55, 0.2, -1.8, M, seg=6, ring=4)
        if yuru:
            serit([(0.3, gy - 0.6), (0.8, gy + 0.6)], lambda t: 0.9, -1.8, M, "g")
            serit([(0.8, gy + 0.5), (-0.6, gy + 1.4)], lambda t: 0.6, -1.8, M, "b1")
            serit([(0.8, gy + 0.5), (1.8, gy + 1.4)], lambda t: 0.6, -1.8, M, "b2")
        else:
            serit([(0.5, gy - 0.6), (0.5, gy + 0.6)], lambda t: 1.1, -1.8, M, "g")
            serit([(0.1, gy + 0.5), (0.1, gy + 1.4)], lambda t: 0.5, -1.8, M, "b1")
            serit([(0.9, gy + 0.5), (0.9, gy + 1.4)], lambda t: 0.5, -1.8, M, "b2")
    return fn


# ================================================================ yakin esyalar
def bisiklet():
    Mt = mat_ton("#2b3037", f=(0.6, 0.85, 1.0, 1.4))
    for x in (0.0, 14.0):
        L.halka("teker", 4.0, 4.0, 0.45, x, ez(-5, 0.0, K), 0.0, Mt, yan=False)
        for k in range(4):
            a = k * math.pi / 4
            T.on_poligon("tel", [(x - math.cos(a) * 3.6, -5 - math.sin(a) * 3.6), (x + math.cos(a) * 3.6, -5 + math.sin(a) * 3.6),
                                 (x + math.cos(a) * 3.6 + 0.15, -5 + math.sin(a) * 3.6 + 0.15), (x - math.cos(a) * 3.6 + 0.15, -5 - math.sin(a) * 3.6 + 0.15)],
                         0.1, mat_alfa("#8f979f", 0.7), K, derin=0.02)
        elipsoid(x, -5, 0.6, 0.6, 0.4, -0.2, mat_duz("#8f979f"), seg=8, ring=4)
    Mf = mat_ton("#3f8a4a", f=(0.6, 0.82, 1.0, 1.25))
    for a, b in (((0, -5), (6, -12)), ((6, -12), (14, -5)), ((6, -12), (2, -5)), ((14, -5), (9, -5)), ((2, -5), (9, -5)), ((9, -5), (6.5, -12))):
        serit([a, b], lambda t: 0.9, -0.4, Mf, "kadro")
    kutu(4, 8, -14, -12.6, -1.2, 0.8, mat_ton("#2b2018", f=(0.6, 0.9, 1.0, 1.4)), bevel=0.3)
    serit([(14, -5), (13.6, -9.0), (14.2, -13)], lambda t: 0.7, -0.6, mat_ton("#5a636b"), "catal")
    serit([(12, -13), (17, -13)], lambda t: 0.6, -0.9, mat_ton("#5a636b"), "gidon")
    elipsoid(9, -5, 1.0, 1.0, 0.4, -0.6, mat_ton("#5a636b"), seg=8, ring=4)


def cop():
    Mg = mat_ton("#63705f", f=(0.62, 0.82, 1.0, 1.15), noise=0.05)
    kutu(0, 11, -13, 0, -1.5, 3.5, Mg, bevel=0.5)
    for kk in range(3):
        kutu(3 + kk * 3, 3.6 + kk * 3, -11, -2, -1.6, -1.4, mat_ton("#4f5a52"))
    kutu(-1, 12, -15.2, -12.2, -2.2, 4.2, mat_ton("#3f4a44", f=(0.6, 0.85, 1.0, 1.4)), bevel=0.6)
    kutu(3.5, 7.5, -16.2, -15.2, 0.0, 1.5, mat_ton("#3f4a44"), bevel=0.3)
    on_levha([(2.4, -8.5), (8.6, -8.5), (8.6, -6.5), (2.4, -6.5)], -1.7, mat_alfa("#e8ecef", 0.55))


# ================================================================ kayit
parca("agac_yaprak", (-14, -36, 28, 39), agac_yaprak)
parca("agac_budanmis", (-12, -35, 25, 38), agac_budanmis)
parca("agac_sakura", (-14, -35, 28, 38), agac_sakura)
parca("agac_palmiye", (-16, -36, 34, 39), agac_palmiye)
parca("lamba", (-5, -40, 21, 42), lamba)
parca("lamba_acik", (5, -36, 10, 4), lamba_acik, cizgi=None)
parca("lamba_isik", (-7, -33, 34, 20), lamba_isik, tur="np")
parca("durak", (-4, -28, 40, 30), durak)
parca("sehir_posta", (-2, -17, 11, 19), sehir_posta)
parca("sehir_simit", (-6, -17, 26, 19), sehir_simit)
parca("sehir_sutun", (-3, -25, 17, 27), sehir_sutun)
parca("sehir_kulube", (-4, -30, 20, 32), sehir_kulube)
parca("sehir_sarisari", (-8, -18, 28, 20), sehir_sarisari)
parca("sehir_kafe", (-6, -16, 22, 18), sehir_kafe)
parca("sehir_palmiye", (-6, -28, 24, 30), sehir_palmiye)
parca("sehir_otomat", (-3, -24, 18, 26), sehir_otomat)
parca("sehir_musluk", (-2, -18, 16, 20), sehir_musluk)
parca("trafik_govde", (-7, -41, 14, 43), trafik_govde)
parca("trafik_kirmizi", (-2, -37, 5, 5), trafik_mercek(-34, "#ff5a48"), cizgi=None)
parca("trafik_sari", (-2, -33, 5, 5), trafik_mercek(-30.5, "#ffd84a"), cizgi=None)
parca("trafik_yesil", (-2, -30, 5, 5), trafik_mercek(-27, "#4ae06a"), cizgi=None)
parca("trafik_isik", (-5, -5, 10, 10), isik_topu, tur="np")
parca("yaya_govde", (-5, -26, 11, 28), yaya_govde)
parca("yaya_yuru", (-3, -24, 7, 5), yaya_isik(True), cizgi=None)
parca("yaya_dur", (-3, -21, 7, 5), yaya_isik(False), cizgi=None)
parca("bisiklet", (-6, -17, 26, 19), bisiklet, cizgi_alfa=80)
parca("cop", (-3, -19, 17, 21), cop)


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
    print("SOKAK_ESYA_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
