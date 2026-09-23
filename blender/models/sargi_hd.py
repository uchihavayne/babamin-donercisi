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
def _yassi_disk(ad, gx, gy, rx, ry_ekran, kalin, aci, mat_yan, mat_ust, K):
    """Yatay, ince, dondurulmus disk (ust yuz ayri malzeme). Merkez ekranda (gx, gy)."""
    ry = ry_ekran / K
    bm = bmesh.new()
    seg = 28
    alt, ust = [], []
    for q in range(seg):
        a = 2 * math.pi * q / seg
        x, y = math.cos(a) * rx, math.sin(a) * ry
        ca, sa = math.cos(aci), math.sin(aci)
        xr, yr = x * ca - y * sa * K, x * sa / K + y * ca
        alt.append(bm.verts.new((xr, yr, 0.0)))
        ust.append(bm.verts.new((xr * 0.97, yr * 0.97, kalin)))
    for q in range(seg):
        bm.faces.new((alt[q], alt[(q + 1) % seg], ust[(q + 1) % seg], ust[q]))
    bm.faces.new(list(reversed(alt)))
    f = bm.faces.new(ust)
    f.material_index = 1
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = I.mesh_ob(ad, bm, mat_yan, smooth=False)
    ob.data.materials.append(mat_ust)
    for pol in ob.data.polygons:
        if pol.normal.z > 0.9:
            pol.material_index = 1
    ob.location = (gx, 0.0, -gy - kalin / 2.0)
    return ob


def tursu(k):
    """Kullanici: "top gibi, hic olmamis". Ince dilimlenmis tursu: YASSI oval
    diskler (koyu yesil kabuk kenari + acik, yari saydam ic + cekirdek halkasi),
    farkli acilarla lavasa dagilmis; 2 / 3 / 3 / 4 adet."""
    def fn():
        n = {1: 2, 2: 3, 3: 3, 4: 4}[k]
        gen = 14 + k * 4.0
        Myan = cel("TursuYan", ["#1c2c0a", "#2c4410", "#3f5e18", "#557a22"], S4)
        Must = cel("TursuUst", ["#3f5e18", "#557a22", "#6e9128", "#86a838"], S4, noise=0.08, noise_scale=10)
        Mic = px.flat("TursuIc", "#a8c656")
        Mc = px.flat("TursuCek", "#e9eeb0")
        for q in range(n):
            pu = 0.5 if n == 1 else q / (n - 1.0)
            kx = -gen / 2.0 + pu * gen + (h1(q * 2.9) - 0.5) * 2.4
            ky = BY - 0.5 + (1.4 if q % 2 else -1.0) + (h1(q * 4.1) - 0.5) * 1.0
            aci = (h1(q * 6.7) - 0.5) * 0.9
            gol = px.flat_a("TursuGolge%d" % q, "#12200a", 0.3)
            I.yatay_elips("golge%d" % q, kx + 0.7, ky + 1.0, 3.6, 0.05, gol, K, ry_ekran=1.9)
            d = _yassi_disk("tursu%d" % q, kx, ky, 3.5, 2.0, 0.45, aci, Myan, Must, K)
            d.location.y = -0.4 - q * 0.3
            d.location.z = -ky - 0.225 - d.location.y * K
            # ic yuz: acik halka + cekirdekler (disk ustunde, ayni aci)
            z_ust = d.location.z + 0.45 + 0.02
            for c in range(6):
                a = c * 1.047 + q
                ex = kx + math.cos(a) * 1.6
                ey = ky + math.sin(a) * 0.8
                e = I.elipsoid("cek%d_%d" % (q, c), ex, ey, 0.32, 0.12, 0.2, 0.0, Mc, seg=6, ring=4)
                e.location = (ex, d.location.y - 0.05, -ey + (z_ust - (-ky)) + d.location.y * 0.0)
            ic = I.elipsoid("ic%d" % q, kx - 0.2, ky - 0.2, 1.0, 0.06, 0.5, 0.0, Mic, seg=10, ring=4)
            ic.location = (kx - 0.2, d.location.y - 0.05, z_ust - 0.02 + (ky - (ky - 0.2)))
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


def _leke(ad, gx, gy, rx, ry_ekran, kal, faz, mat, K):
    """Yayilmis sos lekesi: duzensiz kenarli, alcak kubbeli ince tabaka."""
    ry = ry_ekran / K
    bm = bmesh.new()
    seg = 30
    kenar, orta = [], []
    for q in range(seg):
        a = 2 * math.pi * q / seg
        r = 1.0 + 0.16 * math.sin(3 * a + faz) + 0.09 * math.sin(5 * a + faz * 1.7)
        kenar.append(bm.verts.new((math.cos(a) * rx * r, math.sin(a) * ry * r, 0.0)))
        orta.append(bm.verts.new((math.cos(a) * rx * r * 0.7, math.sin(a) * ry * r * 0.7, kal * 0.8)))
    tepe = bm.verts.new((0.0, 0.0, kal))
    for q in range(seg):
        bm.faces.new((kenar[q], kenar[(q + 1) % seg], orta[(q + 1) % seg], orta[q]))
        bm.faces.new((orta[q], orta[(q + 1) % seg], tepe))
    bm.faces.new(list(reversed(kenar)))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = I.mesh_ob(ad, bm, mat, smooth=True)
    ob.location = (gx, 0.0, -gy - kal * 0.5)
    return ob


def yogurt(k):
    """Kullanici: "yogurt top top olmus". Dürüme SUR sulen yogurt: alcak,
    duzensiz kenarli, parlak beyaz lekeler lavas boyunca birbirine karisir;
    seviye arttikca leke sayisi ve boyu artar."""
    def fn():
        n = {1: 2, 2: 3, 3: 3, 4: 4}[k]
        gen = 10 + k * 4.0
        My = cel("UstYog", ["#c4bca6", "#e2dccb", "#f3efe4", "#ffffff"], S4)
        Mp = px.flat_a("YogParlak", "#ffffff", 0.85)
        for q in range(n):
            pu = 0.5 if n == 1 else q / (n - 1.0)
            dx = -gen / 2.0 + pu * gen + (h1(q * 3.7 + 1.1) - 0.5) * 2.0
            dy = BY - 2.2 + (h1(q * 5.9) - 0.5) * 2.0
            rx = 3.0 + h1(q * 1.9) * 1.0 + k * 0.2
            gol = px.flat_a("YogGolge%d" % q, "#6a6252", 0.22)
            I.yatay_elips("golge%d" % q, dx + 0.6, dy + 0.9, rx, 0.05, gol, K, ry_ekran=rx * 0.42)
            ob = _leke("yog%d" % q, dx, dy, rx, rx * 0.42, 0.6, q * 2.3 + k, My, K)
            ob.location.y = -1.2 - q * 0.2
            ob.location.z = -dy - 0.45 - ob.location.y * K
            e = I.elipsoid("parlak%d" % q, dx - rx * 0.3, dy - 0.5, 0.9, 0.12, 0.35, 0.0, Mp, seg=8, ring=4)
            e.location = (dx - rx * 0.3, ob.location.y - 0.3, ob.location.z + 0.95)
    return fn


# ---------------------------------------------------------------- sos
def sos(tur):
    """Ince, elle gezdirilmis sos: yuvarlak zikzak yerine dalgasi ve kalinligi
    degisen iplik + birkac damla."""
    def fn():
        sicak = tur == "hot"
        ramp = ["#6e140e", "#b3241a", "#d8362a", "#f04a34"] if sicak else ["#b8b19c", "#e6dfc8", "#f4f0e2", "#fdfaf0"]
        M = cel("UstSos" + tur, ramp, S4)
        nok = []
        n = 44
        for z in range(n + 1):
            u = z / float(n)
            zx = -15 + u * 30
            dalga = math.sin(u * 13.0 + 0.6) * (1.7 + 0.8 * math.sin(u * 4.0))
            zy = BY - 3.4 + dalga * 0.8 + math.sin(u * 31.0) * 0.25
            nok.append((zx, -2.0, -zy))
        _tup("sos", nok, 0.42, M)
        Md = cel("SosDamla" + tur, ramp, S4)
        for q, (dx, dy) in enumerate(((-11.5, BY - 1.6), (3.0, BY - 2.4), (12.5, BY - 2.0))):
            e = I.elipsoid("damla%d" % q, dx, dy, 0.7, 0.55, 0.5, -2.2, Md, seg=8, ring=5)
            e.location.z = ez(dy, -2.2, K)
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
