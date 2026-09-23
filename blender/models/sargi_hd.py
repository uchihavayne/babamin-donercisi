"""ACIK DURUMUN MALZEME KATMANLARI — birlesik surum HD (food.js drawWrapOpen).

    blender --background --factory-startup --python blender/models/sargi_hd.py [-- ust_et ...]
    python blender/hd_atlas.py sargi_hd sargi

Lavasin ustundeki et / patates / tursu / yogurt / sos oyunda f_hash1 ile
yerlestirilen piksel parcalar; yerlesim yalniz malzeme SAYISINA bagli
(orani = sayi / 4, tarif dort birimlik). Her malzeme ve seviye (1..4) ayni
hash dizisiyle burada 3B kurulur. Yeni tahtada urun ctx.scale icinde
(1.8 / 1.22 / 0.9) cizildigi icin her olcek ayri render edilir.

Capa: durumun merkezi (cx, cy). Parca adi: ust_<tur>_<seviye>_<olcek>,
sos: ust_sos_<hot|garlic>_<olcek>.
"""
import sys, os, math, json
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D

OUT = os.path.join(_HERE, "out", "sargi_hd")
HD = 2
K = 0.5
S4 = [0, .3, .5, .8]
OLCEKLER = (1.8, 1.22, 0.9, 1.0)
TUVAL = (-27, -17, 56, 24)
PARCALAR, KOKEN, OLCEK = {}, {}, {}
cel = I.cel
ez = T.ez
BY = -3.0      # food.js: by = cy - 3


def h1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


def fl(v):
    return math.floor(v + 0.5)


def kutu_ekran(ad, x0, x1, gy_ust, gy_on, gy_alt, mat, pah=0.35, y0=0.0):
    """Ust yuzu ekranda gy_ust..gy_on, on yuzu gy_on..gy_alt olan kutu (derinlik
    (gy_on-gy_ust)/K). Pahli: yuvarlak et/patates hissi."""
    D_ = max(0.3, (gy_on - gy_ust) / K)
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y0 + D_
        v.co.z = -gy_alt if v.co.z < 0 else -gy_on
    if pah > 0:
        bmesh.ops.bevel(bm, geom=bm.edges[:], offset=pah, segments=2, profile=0.5, affect="EDGES")
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return I.mesh_ob(ad, bm, mat, smooth=True)


def golge(ad, x0, gy0, w, h, alfa):
    """Yari saydam golge (lavas ustunde), parcalarin arkasinda."""
    m = px.flat_a(ad, "#2a1808", alfa)
    T.ust_poligon(ad, [(x0, gy0), (x0 + w, gy0), (x0 + w, gy0 + h), (x0, gy0 + h)], -(gy0 + h) - 0.02, m, K, kal=0.01)


# ---------------------------------------------------------------- et
def et(k):
    def fn():
        oran = min(1.0, k / 4.0)
        parca_n = max(5, int(math.floor(5 + oran * 9 + 0.5)))
        gen = 16 + oran * 18
        Me = cel("UstEt", ["#4a260a", "#7e4412", "#a85f1e", "#d98f38"], S4, noise=0.12, noise_scale=9)
        Mi = px.flat("UstEtIsik", "#eeb463")
        My = px.flat("UstEtYag", "#ffd291")
        for m in range(parca_n):
            mu = 0.5 if parca_n == 1 else m / (parca_n - 1.0)
            r = h1(m * 2.1)
            mx = math.floor(-gen / 2.0 + mu * gen + (r * 3 - 1.5) + 0.5)
            kub = math.sin(mu * math.pi) * (2.2 + oran * 2.4)
            my = math.floor(BY + 1 - kub + (h1(m * 5.3) * 2.4 - 1.2) + 0.5)
            mw = 4 + int(r * 2.4)
            golge("EtGolge%d" % m, mx - 1, my + 2, mw + 2, 2, 0.34)
            # ust yuzu 1 satir, on yuzu 2 satir; hafif egik (kabuk dokusu)
            ob = kutu_ekran("et%d" % m, mx, mx + mw, my - 0.2, my + 1, my + 3, Me, pah=0.45, y0=-0.02 * m)
            ob.rotation_euler = (0, math.radians((h1(m * 3.3) - 0.5) * 16), 0)
            # kizarmis kabuk isigi + yag parlamasi (tasarimdaki #eeb463 / #ffd291)
            I.elipsoid("isik", mx + 1.5, my - 0.3, 0.8, 0.45, 0.4, -0.6 - 0.2 * m, Mi, seg=8, ring=4).location.z = ez(my - 0.3, -0.6 - 0.2 * m, K)
            if h1(m * 7.7) > 0.55:
                e = I.elipsoid("yag", mx + mw - 1.5, my - 0.4, 0.55, 0.35, 0.3, -0.7 - 0.2 * m, My, seg=8, ring=4)
                e.location.z = ez(my - 0.4, -0.7 - 0.2 * m, K)
    return fn


# ---------------------------------------------------------------- patates
PAT_TON = {"acik": ["#8a6218", "#a8791c", "#f0d271", "#fff0b8"],
           "orta": ["#5e3f0c", "#8a6218", "#dcae42", "#f0d271"],
           "koyu": ["#3f2a08", "#5e3f0c", "#b8801f", "#d9a03a"]}


def patates(k):
    def fn():
        oran = min(1.0, k / 4.0)
        n = max(4, int(math.floor(4 + oran * 7 + 0.5)))
        gen = 16 + oran * 18
        mats = {t: cel("UstPat" + t, r, S4) for t, r in PAT_TON.items()}
        for f in range(n):
            t0 = f * 3.77 + 1.3
            fu = (f + h1(t0) * 0.9) / n
            fx = math.floor(-gen / 2.0 + fu * gen + 0.5)
            fy = math.floor(BY + (h1(t0 * 1.9) * 5 - 2) + 0.5)
            fL = 4 + int(h1(t0 * 2.7) * 5)
            aci = (h1(t0 * 4.1) * 2 - 1) * 0.5
            tk = h1(t0 * 5.3)
            ton = "acik" if tk > 0.66 else ("koyu" if tk < 0.3 else "orta")
            # cubuk: sol uc (fx, fy + (0 - fL/2)*aci); merkezi (fx + fL/2, fy)
            cx = fx + fL / 2.0
            golge("PatGolge%d" % f, fx, fy + 2, fL, 1.2, 0.3)
            ob = kutu_ekran("pat%d" % f, -fL / 2.0, fL / 2.0, -0.9, 0.1, 1.9, mats[ton], pah=0.3, y0=-0.3 - 0.015 * f)
            ob.location = (cx, 0, -fy)
            ob.rotation_euler = (0, math.atan(aci), 0)
    return fn


# ---------------------------------------------------------------- tursu
def tursu(k):
    def fn():
        oran = min(1.0, k / 4.0)
        n = max(3, int(math.floor(3 + oran * 5 + 0.5)))
        gen = 14 + oran * 16
        Mk = cel("UstTursuK", ["#12200a", "#2c4410", "#4a6a1a", "#6e9128"], S4)
        Mi = cel("UstTursuI", ["#4a6a1a", "#6e9128", "#8fb03c", "#a8ca52"], S4)
        Mc = px.flat("UstTursuC", "#c4dc74")
        for q in range(n):
            pu = 0.5 if n == 1 else q / (n - 1.0)
            kx = math.floor(-gen / 2.0 + pu * gen + 0.5)
            ky = math.floor(BY - 3 + int(h1(q * 4.1) * 3) + 0.5)
            m = px.flat_a("TursuGolge%d" % q, "#12200a", 0.32)
            I.yatay_elips("golge%d" % q, kx, ky + 2.2, 4.3, 0.2, m, K, ry_ekran=2.2)
            # dilim: kalin kabuk halkasi + ic (cekirdekli) yuz, hafif egik
            I.yatay_elips("kabuk%d" % q, kx, ky + 0.6, 4.4, 1.1, Mk, K, ry_ekran=2.4, egim=0.05)
            I.yatay_elips("ic%d" % q, kx - 0.2, ky - 0.1, 3.6, 0.3, Mi, K, ry_ekran=1.9).location.z += 0.9
            for s in range(4):
                a = s * 1.57 + q
                e = I.elipsoid("cek%d" % s, kx + math.cos(a) * 1.6, ky - 0.2 + math.sin(a) * 0.7, 0.45, 0.3, 0.3, -1.0, Mc, seg=6, ring=4)
                e.location.z = ez(ky - 0.2 + math.sin(a) * 0.7, -1.0, K) + 1.0
    return fn


# ---------------------------------------------------------------- yogurt
def _tup(ad, noktalar, r, mat, bevel_res=4):
    """Nokta dizisinden (x, derinlik, z) gecen tup (bezier degil poly)."""
    cu = bpy.data.curves.new(ad, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = r
    cu.bevel_resolution = bevel_res
    cu.use_fill_caps = True
    sp = cu.splines.new("POLY")
    sp.points.add(len(noktalar) - 1)
    for i, (x, y, z) in enumerate(noktalar):
        sp.points[i].co = (x, y, z, 1.0)
    ob = bpy.data.objects.new(ad, cu)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    return L.meshle(ob, mat)


def yogurt(k):
    def fn():
        oran = min(1.0, k / 4.0)
        gen = math.floor(14 + oran * 20 + 0.5)
        kal = 1 + math.floor(oran * 1.6 + 0.5)
        y0 = -gen / 2.0
        My = cel("UstYog", ["#a89f86", "#cfc4a6", "#f1ecdd", "#ffffff"], S4)
        m = px.flat_a("YogGolge", "#6a6252", 0.3)
        nok, gol = [], []
        z = 0
        while z <= gen:
            x = math.floor(y0 + z + 0.5) + 0.5
            gy = BY - 5 + math.sin(z * 0.42 + 1.1) * 2.1 + kal / 2.0 + 0.5
            nok.append((x, -1.0, -gy))
            gol.append((x, gy + kal / 2.0 + 0.8))
            z += 1
        for i, (x, gy) in enumerate(gol):
            T.ust_poligon("yg%d" % i, [(x - 0.5, gy), (x + 0.5, gy), (x + 0.5, gy + 1.6), (x - 0.5, gy + 1.6)], -(gy + 1.6) - 0.02, m, K, kal=0.01)
        _tup("yogurt", nok, 0.55 + kal * 0.45, My)
        # tepe parlakligi: her 5. noktada kucuk beyaz damla
        Mb = px.flat("YogParlak", "#ffffff")
        for i in range(2, len(nok), 5):
            x, _, zz = nok[i]
            e = I.elipsoid("parlak%d" % i, x, -zz - kal * 0.5, 0.5, 0.4, 0.3, -2.0, Mb, seg=6, ring=4)
            e.location.z = zz + kal * 0.45 + 0.3
    return fn


# ---------------------------------------------------------------- sos
def sos(tur):
    def fn():
        sicak = tur == "hot"
        ramp = ["#6e140e", "#b3241a", "#d8362a", "#f04a34"] if sicak else ["#b8b19c", "#e6dfc8", "#f4f0e2", "#fdfaf0"]
        M = cel("UstSos" + tur, ramp, S4)
        nok = []
        for z in range(26):
            zx = -17 + z * 1.35
            zy = BY - 6 + math.sin(z * 1.35) * 3 + 0.5
            nok.append((zx, -2.0, -zy))
        _tup("sos", nok, 0.62, M)
        Md = px.flat("SosDamla" + tur, "#ff8a70" if sicak else "#ffffff")
        for (dx, dy) in (((-9, BY - 8), (7, BY - 9)) if sicak else ((-6, BY - 9), (9, BY - 8))):
            e = I.elipsoid("damla", dx + 0.5, dy + 0.5, 0.6, 0.5, 0.4, -2.5, Md, seg=8, ring=4)
            e.location.z = -(dy + 0.5)
    return fn


def parca(ad, fn, cizgi=None, cizgi_alfa=120):
    for sc in OLCEKLER:
        tam = "%s_%d" % (ad, int(round(sc * 100)))
        PARCALAR[tam] = (fn, cizgi, cizgi_alfa, sc)
        KOKEN[tam] = (TUVAL[0], TUVAL[1])
        OLCEK[tam] = sc


for _k in (1, 2, 3, 4):
    parca("ust_et_%d" % _k, et(_k), cizgi="#3a1a06", cizgi_alfa=110)
    parca("ust_patates_%d" % _k, patates(_k), cizgi="#4a3208", cizgi_alfa=100)
    parca("ust_tursu_%d" % _k, tursu(_k))
    parca("ust_yogurt_%d" % _k, yogurt(_k))
parca("ust_sos_hot", sos("hot"))
parca("ust_sos_garlic", sos("garlic"))


def uret(ad):
    fn, cizgi, cizgi_alfa, sc = PARCALAR[ad]
    gx0, gy0, w, h = TUVAL
    D.sahne(gx0, gy0, w, h, sc)
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
        json.dump({"hd": HD, "katmanlar": list(PARCALAR),
                   "kokenler": {k: list(v) for k, v in KOKEN.items()},
                   "olcekler": OLCEK}, fp, indent=1)
    print("SARGI_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
