"""UYGULAMA IKONU ADAYLARI — Blender'da 3B, oyunun paletinde piksel render.

    blender --background --factory-startup --python blender/models/ikon.py -- hepsi
    ... -- sis | bicak | durum | fes

Bugunku ikon (mobil/assets/icon.png) piksel-art bir durumu 1024'e YUMUSAK
buyutmustu: her piksel bulanik, kenarlar camur. Burada 128x128 "oyun
pikseli" render edilip TAM 8 kat en-yakin-komsu ile 1024'e cikiliyor —
her piksel keskin 8x8 kare.

Telefonda ikon ~60 px gorunuyor: tek, kalin bir silüet sart, yazi yok.

  sis   : oyunun doner sisi ortada, arkasinda isiticinin turuncu kareleri
  bicak : ayni sis, uzun doner bicagi yandan dilim kesiyor, dilim ucuyor
  durum : kagida sarili durum, acik ucundan et / tursu / patates
  fes   : sis babanin FESINI takmis — "babamin dönercisi" tek resimde

HICBIRI UYGULANMADI. Secilen, assets/icon-1024.png'ye konup
tools/assets.js ile PWA / Android katmanlari uretilecek.
"""
import sys, os, math
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import palette as pal
import logo as L                 # ortak 3B yardimcilar (kutu, silindir, levha ...)

OUT = os.path.join(_HERE, "out", "ikon")
N = 128                          # ikon tuvali (oyun pikseli)
BUYUT = 8                        # 128 x 8 = 1024
P = pal.P


def sahne():
    L._FONTLAR.clear()
    px.reset()
    px.setup(N, N, transparent=True)
    px.ortho_cam(0.0, 0.0, N, N)
    px.world("#000000", 0.0)
    L.isik()


def zemin():
    """Zemin sonradan numpy ile konuyor (bkz. zemin_bas). Burada bos."""
    return None


def zemin_bas(konu):
    """Kademeli daire hale: koyu kirmizi koseler -> acik merkez. Tam
    merkezde; iOS'un yuvarlatilmis kare maskesi koseleri kesse de konu
    cercevede kalir. Kademe sayisi az: piksel artta yumusak gecis olmaz."""
    import numpy as np
    def rgb(h):
        h = h.lstrip("#"); return [int(h[i:i + 2], 16) for i in (0, 2, 4)]
    zem = np.zeros((N, N, 4), dtype=np.uint8)
    zem[..., 3] = 255
    yy, xx = np.mgrid[0:N, 0:N]
    d = np.sqrt((xx - (N - 1) / 2.0) ** 2 + (yy - (N - 1) / 2.0) ** 2)
    kademe = [(999, P["red3"]), (62, P["red2"]), (52, P["red1"])]
    for rr, c in kademe:
        zem[d <= rr, :3] = rgb(c)
    a = konu[..., 3:4].astype(np.float32) / 255.0
    zem[..., :3] = (konu[..., :3] * a + zem[..., :3] * (1 - a)).astype(np.uint8)
    return zem


def isitici(cx, cz, w, h, kol=3, sat=6):
    """Oyundaki sisin arkasindaki turuncu kareler: koyu cerceve + izgara."""
    M_panel = L.cel("Panel", L.DARK)
    M_heat = [px.flat("Isi%d" % i, c) for i, c in enumerate((P["f3"], P["f2"], P["f1"]))]
    L.levha("isitici", w, h, 4, cx, cz, 16, 5, 0.8, M_panel)
    gw = (w - 8) / kol
    gh = (h - 8) / sat
    for r in range(sat):
        for c in range(kol):
            x0 = cx - w / 2 + 4 + c * gw + 1
            z0 = cz - h / 2 + 4 + r * gh + 1
            L.kutu("kare", x0, x0 + gw - 2.4, z0, z0 + gh - 2.4, 12.5, 13.5,
                   M_heat[(r * 2 + c) % 3])


def sis(cx, cz, boy):
    """models/spit.py'nin konisi, olceklenip tasiniyor. (ust_z, alt_z) doner."""
    import spit
    M_meat = px.cel_nx("Et", spit.meat_ramp(0.86), spit.NX_STOPS,
                       band=1.0, band_amt=0.010, noise=0.016, noise_scale=1.4)
    M_steel = L.cel("Celik", L.STEEL)
    cone = spit.build_cone(mass=1.0, cut=0.0, rot=0.6, seed=7)
    cone.data.materials.clear()
    cone.data.materials.append(M_meat)
    bpy.context.view_layer.update()
    mw = cone.matrix_world
    vs = [mw @ v.co for v in cone.data.vertices]
    x0 = min(v.x for v in vs); x1 = max(v.x for v in vs)
    z0 = min(v.z for v in vs); z1 = max(v.z for v in vs)
    y0 = min(v.y for v in vs); y1 = max(v.y for v in vs)
    s = boy / (z1 - z0)
    c0 = Vector(((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2))
    hedef = Vector((cx, 2.0, cz))
    inv = mw.inverted()
    for v in cone.data.vertices:
        v.co = inv @ (((mw @ v.co) - c0) * s + hedef)
    cone.data.update()
    ust = cz + boy / 2
    alt = cz - boy / 2
    L.silindir("cubuk", 1.2, cx, 2, ust + 4, 9, M_steel, seg=10)
    L.silindir("tepe", 5, cx, 2, ust + 1.2, 2.6, M_steel, seg=16)
    return ust, alt, (x1 - x0) * s / 2


# ------------------------------------------------------------ adaylar
def c_sis():
    sahne(); zemin()
    isitici(0, 2, 78, 104)
    ust, alt, r = sis(0, -1, 98)
    M_steel = L.cel("Celik2", L.STEEL)
    L.silindir("tepsi", r * 0.95, 0, 2, alt - 2.5, 2.4, M_steel, seg=28, r2=r * 1.08)
    px.shear_scene(0.16)


def c_bicak():
    sahne(); zemin()
    isitici(-12, 4, 62, 100)
    ust, alt, r_ = sis(-12, -2, 96)
    M_blade = L.cel("Bicak", [P["mt4"], P["mt2"], P["mt1"], P["mt0"]])
    M_sirt = L.cel("BicakSirt", [P["mt5"], P["mt4"], P["mt3"], P["mt2"]])
    M_sap = L.cel("Sap", [P["wd3"], P["wd2"], P["wd1"], P["wd0"]])
    M_percin = L.cel("Percin", [P["mt3"], P["mt2"], P["mt1"], P["mt0"]])
    M_meat = L.cel("Dilim", [P["m5"], P["m4"], P["m3"], P["m2"]])
    # bicak YEREL koordinatta kurulur (agiz asagi), sonra tek pivotla doner
    parca = []
    parca.append(L.cokgen("agiz", [(-3.5, 34), (3.5, 34), (3.5, -26), (0, -34), (-3.5, -28)],
                          0, 0, 0, 2.2, 0.4, M_blade))
    parca.append(L.kutu("sirt", -3.6, -2.2, -26, 34, -1.6, 1.6, M_sirt))
    parca.append(L.kutu("bilezik", -4.6, 4.6, 34, 37, -1.8, 1.8, M_sirt))
    parca.append(L.levha("sap", 8, 24, 3, 0, 49, 0, 3.4, 0.7, M_sap))
    for pz in (43, 55):
        parca.append(L.silindir("percin", 1.2, 0, -2.2, pz, 1.0, M_percin, seg=8, eksen="Y"))
    piv = bpy.data.objects.new("bicak_pivot", None)
    bpy.context.collection.objects.link(piv)
    for ob in parca:
        ob.parent = piv
    piv.location = (r_ - 2, -16, 6)
    piv.rotation_euler = (0, math.radians(26), 0)
    bpy.context.view_layer.update()
    for ob in parca:
        mw = ob.matrix_world.copy(); ob.parent = None; ob.matrix_world = mw
    # ucan dilim: kivrik ince et, bicagin agzindan kopmus
    dilim = L.cokgen("dilim", [(-9, 2), (-4, 6), (5, 5), (10, 1), (5, -3), (-5, -2)],
                     0, 0, 0, 2.4, 0.7, M_meat)
    dilim.location = (40, -14, -18)
    dilim.rotation_euler = (math.radians(90), math.radians(-18), 0)
    px.shear_scene(0.16)


def c_durum():
    sahne(); zemin()
    M_lavas = L.cel("Lavas", [P["m4"], P["p3"], P["p2"], P["p1"]])
    M_kagit = L.cel("Kagit", [P["s3"], P["s2"], P["s1"], P["s0"]])
    M_bant = L.cel("Bant", L.RED)
    M_meat = L.cel("Et", [P["m5"], P["m4"], P["m3"], P["m2"]])
    M_tur = L.cel("Tursu", [P["g4"], P["g3"], P["g2"], P["g1"]])
    M_pat = L.cel("Patates", [P["p3"], P["p2"], P["p1"], P["p0"]])
    M_yog = L.cel("Yogurt", [P["s2"], P["s1"], P["s0"], P["white"]])
    grup = []
    R = 20
    grup.append(L.silindir("lavas", R, 0, 0, 0, 100, M_lavas, seg=36, eksen="X"))
    grup.append(L.silindir("kagit", R + 1.6, -16, 0, 0, 68, M_kagit, seg=36, eksen="X"))
    grup.append(L.silindir("bant", R + 1.9, -26, 0, 0, 8, M_bant, seg=36, eksen="X"))
    # acik uc: koyu et diski + tasan malzeme (buyuk ki 60 px'te okunsun)
    grup.append(L.silindir("ic", R - 2.5, 50.2, 0, 0, 1.4, M_meat, seg=30, eksen="X"))
    for i, (dz, dy) in enumerate(((7, -9), (-5, -12), (11, 5), (-10, 4), (1, -3), (-2, 9))):
        grup.append(L.silindir("et%d" % i, 5.2, 52, dy, dz, 3.2, M_meat, seg=10, eksen="X"))
    for i, (dz, dy) in enumerate(((12, -5), (-3, -15), (-13, -7), (5, 12))):
        grup.append(L.silindir("tur%d" % i, 4.4, 53.8, dy, dz, 1.6, M_tur, seg=12, eksen="X"))
    for i, (dz, dy) in enumerate(((3, -16), (-10, -14), (14, -12), (-15, 2))):
        grup.append(L.kutu("pat%d" % i, 51, 59, dz - 1.6, dz + 1.6, dy - 1.6, dy + 1.6, M_pat))
    grup.append(L.silindir("yog", 4.2, 53, -17, 8, 2.0, M_yog, seg=12, eksen="X"))
    piv = bpy.data.objects.new("pivot", None)
    bpy.context.collection.objects.link(piv)
    for ob in grup:
        ob.parent = piv
    piv.location = (-4, 0, -2)
    piv.rotation_euler = (0, math.radians(-34), math.radians(-24))
    bpy.context.view_layer.update()
    for ob in grup:
        mw = ob.matrix_world.copy(); ob.parent = None; ob.matrix_world = mw
    px.shear_scene(0.16)


def c_fes():
    sahne(); zemin()
    isitici(0, -8, 76, 80)
    ust, alt, r = sis(0, -12, 78)
    M_steel = L.cel("Celik2", L.STEEL)
    L.silindir("tepsi", r * 0.95, 0, 2, alt - 2.5, 2.4, M_steel, seg=28, r2=r * 1.08)
    # babanin fesi sisin tepesine oturmus, puskulu yana sarkiyor
    M_fes = L.cel("Fes", [P["red3"], P["red2"], P["red0"], P["raw"]])
    M_tepe = L.cel("FesTepe", [P["red3"], P["red3"], P["red2"], P["red1"]])
    M_puskul = L.cel("Puskul", [P["ink"], P["ink"], P["ink2"], P["mt5"]])
    fz = ust + 11
    L.silindir("fes", 20, 0, -8, fz, 24, M_fes, seg=40, r2=15)
    L.silindir("fes_tepe", 15, 0, -8, fz + 12.4, 0.8, M_tepe, seg=36)
    L.silindir("ip", 1.0, 12, -26, fz + 4, 16, M_puskul, seg=6)
    L.silindir("puskul", 4.2, 12, -26, fz - 7, 10, M_puskul, seg=10, r2=1.4)
    px.shear_scene(0.16)


ADAY = {"sis": c_sis, "bicak": c_bicak, "durum": c_durum, "fes": c_fes}


# ================================================================ DURUM VARYANTLARI
# Kullanici 3. adayi (durum) secti; bunlar ondan TEK bir buyuk seyi degistiren
# alternatifler. c_durum'a dokunulmadi — karsilastirma adil kalsin.

KRAFT = [P["ui3"], P["ui2"], P["ui1"], P["s1"]]
SKIN = [P["skin3"], P["skin2"], P["skin1"], P["skin0"]]


def _malzeme(kagit=None):
    return {
        "lavas": L.cel("Lavas", [P["m4"], P["p3"], P["p2"], P["p1"]]),
        "kagit": L.cel("Kagit", kagit or [P["s3"], P["s2"], P["s1"], P["s0"]]),
        "bant": L.cel("Bant", L.RED),
        "et": L.cel("Et", [P["m5"], P["m4"], P["m3"], P["m2"]]),
        "tursu": L.cel("Tursu", [P["g4"], P["g3"], P["g2"], P["g1"]]),
        "patates": L.cel("Patates", [P["p3"], P["p2"], P["p1"], P["p0"]]),
        "yogurt": L.cel("Yogurt", [P["s2"], P["s1"], P["s0"], P["white"]]),
    }


def durum_parca(M, R=20, uzun=100, kagit_boy=68, bant=True, dolgu=True, etiket=False):
    """Yerel koordinatta durum: eksen +X, acik uc x = uzun/2.
    c_durum ile ayni olculer; varyantlar olcek ve kesimle ayrisiyor."""
    u2 = uzun / 2.0
    g = []
    g.append(L.silindir("lavas", R, 0, 0, 0, uzun, M["lavas"], seg=36, eksen="X"))
    kx = -u2 + kagit_boy / 2.0
    g.append(L.silindir("kagit", R + 1.6, kx, 0, 0, kagit_boy, M["kagit"], seg=36, eksen="X"))
    if bant:
        g.append(L.silindir("bant", R + 1.9, kx - 10, 0, 0, 8, M["bant"], seg=36, eksen="X"))
    if etiket:                                       # kraft kagitta yuvarlak kirmizi etiket
        g.append(L.silindir("etiket", 7.5, kx - 4, -R - 2.2, 2, 1.0, M["bant"], seg=20, eksen="Y"))
        g.append(L.silindir("etiket_ic", 5.2, kx - 4, -R - 2.9, 2, 0.6, M["kagit"], seg=18, eksen="Y"))
    if dolgu:
        g.append(L.silindir("ic", R - 2.5, u2 + 0.2, 0, 0, 1.4, M["et"], seg=30, eksen="X"))
        for i, (dz, dy) in enumerate(((7, -9), (-5, -12), (11, 5), (-10, 4), (1, -3), (-2, 9))):
            g.append(L.silindir("et%d" % i, 5.2, u2 + 2, dy, dz, 3.2, M["et"], seg=10, eksen="X"))
        for i, (dz, dy) in enumerate(((12, -5), (-3, -15), (-13, -7), (5, 12))):
            g.append(L.silindir("tur%d" % i, 4.4, u2 + 3.8, dy, dz, 1.6, M["tursu"], seg=12, eksen="X"))
        for i, (dz, dy) in enumerate(((3, -16), (-10, -14), (14, -12), (-15, 2))):
            g.append(L.kutu("pat%d" % i, u2 + 1, u2 + 9, dz - 1.6, dz + 1.6, dy - 1.6, dy + 1.6,
                            M["patates"]))
        g.append(L.silindir("yog", 4.2, u2 + 3, -17, 8, 2.0, M["yogurt"], seg=12, eksen="X"))
    return g


def pivotla(grup, konum, rot_y, rot_z, olcek=1.0, noktalar=()):
    """Grubu ortak bir pivot etrafinda dondurur. noktalar: yerel koordinatlar
    -> DUNYA koordinatlari olarak doner (buhar gibi 2B eklemeler icin)."""
    piv = bpy.data.objects.new("pivot", None)
    bpy.context.collection.objects.link(piv)
    for ob in grup:
        ob.parent = piv
    piv.location = konum
    piv.rotation_euler = (0, math.radians(rot_y), math.radians(rot_z))
    piv.scale = (olcek, olcek, olcek)
    bpy.context.view_layer.update()
    dunya = [piv.matrix_world @ Vector(n) for n in noktalar]
    for ob in grup:
        mw = ob.matrix_world.copy(); ob.parent = None; ob.matrix_world = mw
    return dunya


def kes(ob, kesiciler):
    """Boolean FARK: kesicileri objeden oyar, sonra modifiyeri gomer."""
    for i, k in enumerate(kesiciler):
        md = ob.modifiers.new("kes%d" % i, "BOOLEAN")
        md.operation = "DIFFERENCE"
        md.object = k
        md.solver = "EXACT"
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    yeni = bpy.data.meshes.new_from_object(ob.evaluated_get(dg))
    ob.modifiers.clear()
    eski = ob.data
    ob.data = yeni
    bpy.data.meshes.remove(eski)


def kure(name, r, x, y, z):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=18, v_segments=12, radius=r)
    ob = L.obj(name, bm, None, smooth=True)
    ob.location = (x, y, z)
    return ob


def ekran(p, k=0.16):
    """Dunya noktasi -> 128'lik tuvalde piksel (oblik kaydirma dahil)."""
    z = p.z + p.y * k
    return (N / 2.0 + p.x, N / 2.0 - z)


# ---------------------------------------------------------------- 3a ISIRIK
def c_d_isirik():
    """Kraft kagit + kirmizi yuvarlak etiket + ust kenardan bir ISIRIK.

    3B boolean ile uc deneme yapildi; geometri kesiliyordu ama ikonda
    OKUNMUYORDU: cukurun duvarlari cel golgelemede karisik sarilara
    donuyor, isirik ufalanmis bir yama gibi duruyordu. Piksel ressami
    isirigi 2B yapar: silüetten uc yuvarlak lokma alinir, kesik kenara
    ince lavas cizgisi + ic dolgu boyanir, dis hat taraklı kenari izler.
    Isirik uret() icinde, dis hattan ONCE isirik_ciz() ile aciliyor."""
    sahne()
    M = _malzeme(KRAFT)
    g = durum_parca(M, bant=False, dolgu=True, etiket=True)
    pivotla(g, (-4, 0, -2), -34, -24)
    px.shear_scene(0.16)
    return {"isirik": True}


def el_hatti(konu, renk=None):
    """Elin kagida / lavasa degdigi yere 1 px koyu hat (piksel artta
    "ic kontur"). Ten (skin0-3) kremsi kagitla neredeyse ayni parlaklikta:
    ana ekranda (~60 px) parmaklar kagidin icinde kayboluyordu. Hat elin
    DISINA, kagit pikseline boyanir — parmaklar 1 px dolgunlasir."""
    import numpy as np
    a = konu.copy()
    op = a[..., 3] > 127
    ten = np.zeros(op.shape, bool)
    for h in ("skin0", "skin1", "skin2", "skin3", "raw", "raw2"):
        ten |= op & np.all(a[..., :3] == _rgb(P[h]), axis=-1)
    kom = np.zeros_like(ten)
    kom[1:, :] |= ten[:-1, :]; kom[:-1, :] |= ten[1:, :]
    kom[:, 1:] |= ten[:, :-1]; kom[:, :-1] |= ten[:, 1:]
    # tirnagin beyaz parlak noktasi ten degil ama ELIN ICINDE: boyanirsa
    # her tirnakta koyu bir benek cikiyor
    parlak = np.all(a[..., :3] == _rgb(P["white"]), axis=-1)
    a[kom & op & ~ten & ~parlak, :3] = _rgb(renk or P["m4"])
    return a


def isirik_ciz(konu):
    """Konu (seffaf zeminli) goruntusunun UST silüetinden, acik uca yakin
    uc yuvarlak lokma alir. Kesigin icinde: 1 px acik lavas kenari, sonra
    et bandi ve icinde tursu / yogurt / patates benekleri."""
    import numpy as np
    a = konu.copy()
    op = a[..., 3] > 127
    H_, W_ = op.shape
    # ust kenar: her sutunda ilk opak piksel
    ust = np.full(W_, -1)
    for x in range(W_):
        ys = np.nonzero(op[:, x])[0]
        if ys.size:
            ust[x] = ys[0]
    # acik ucun biraz gerisi: opak sutunlarin sag tarafinin %58-%80 arasi
    dolu = np.nonzero(ust >= 0)[0]
    x_bas, x_son = dolu.min(), dolu.max()
    merkezler = []
    for oran in (0.60, 0.68, 0.76):
        cx = int(x_bas + (x_son - x_bas) * oran)
        merkezler.append((cx, ust[cx] + 1))
    r = 7.5
    yy, xx = np.mgrid[0:H_, 0:W_]
    d = np.full((H_, W_), 999.0)
    for cx, cy in merkezler:
        d = np.minimum(d, np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2))
    def rgb(h):
        h = h.lstrip("#"); return [int(h[i:i + 2], 16) for i in (0, 2, 4)]
    kalan = op & (d > r)
    a[op & (d <= r), 3] = 0                                  # lokma
    kenar = kalan & (d <= r + 1.2)                           # lavas kesiti
    ic = kalan & (d > r + 1.2) & (d <= r + 4.5)              # dolgu bandi
    a[kenar, :3] = rgb(P["p0"])
    a[ic, :3] = rgb(P["m3"])
    # benekler: sabit desen (rastgele degil — her render ayni)
    benek = [(P["g2"], 0), (P["s0"], 1), (P["g2"], 2), (P["p1"], 3), (P["m2"], 4)]
    for (c, k) in benek:
        m = ic & (((xx * 3 + yy * 5 + k * 7) % 11) == 0)
        a[m, :3] = rgb(c)
    return a


# ---------------------------------------------------------------- 3b BUHAR
def c_d_buhar():
    """Daha dik tutulmus, sicacik: acik uctan buhar yukseliyor (buhar 2B
    olarak sonradan ciziliyor — dis hat almasin, ince kalsin)."""
    sahne()
    M = _malzeme()
    g = durum_parca(M, R=19, uzun=96)
    ag = pivotla(g, (-2, 0, -10), -58, -14, olcek=0.96, noktalar=[(48 + 6, 0, 0)])
    px.shear_scene(0.16)
    return {"buhar": ekran(ag[0])}


# ---------------------------------------------------------------- 3c YAKIN
def c_d_yakin():
    """Yakin plan: durum ikonu doldurup kenardan tasiyor, acik uc sag ustte.
    60 px'te en buyuk okunur alan."""
    sahne()
    M = _malzeme()
    g = durum_parca(M)
    pivotla(g, (-17, 0, -15), -36, -22, olcek=1.5)
    px.shear_scene(0.16)
    return {}


# ---------------------------------------------------------------- 3d ISITICI
def c_d_isitici():
    """3'un aynisi, zemini doner isiticisinin turuncu kareleri: baslik
    logosu B ile ayni dunya."""
    sahne()
    M = _malzeme()
    g = durum_parca(M)
    pivotla(g, (-4, 0, -2), -34, -24)
    px.shear_scene(0.16)
    return {}


# ---------------------------------------------------------------- 3e EL
def c_d_el():
    """Babanin eli durumu bize uzatiyor — prologun 2. sahnesi.

    Ilk denemede dort ayri silindir parmak, kagidin ustunde bir cubuk
    demeti gibi duruyordu. Piksel oyunlarda el-tutan-nesne boyle
    cizilmez: YUMRUK tek parcadir, parmaklar yalniz bogum cizgisiyle
    ayrilir. Burada kavrayis, kagidi saran bir ten bandi + uc koyu
    bogum halkasi + ustte basparmak."""
    sahne()
    M = _malzeme()
    M_ten = L.cel("Ten", SKIN)
    M_bogum = px.flat("Bogum", P["skin3"])
    M_gomlek = L.cel("Gomlek", [P["s3"], P["s2"], P["s1"], P["s0"]])
    M_yelek = L.cel("Yelek", L.RED)
    R, U = 18, 92
    g = durum_parca(M, R=R, uzun=U, kagit_boy=60)
    fx, fl = -20, 22                                 # yumrugun ortasi ve boyu
    g.append(L.silindir("yumruk", R + 4.2, fx, 0, -1.0, fl, M_ten, seg=36, eksen="X"))
    for i in range(3):                               # parmak aralari
        bx = fx - fl / 2 + fl * (i + 1) / 4.0
        g.append(L.silindir("bogum%d" % i, R + 4.5, bx, 0, -1.0, 0.9, M_bogum, seg=36, eksen="X"))
    # basparmak: yumrugun ustunden uca dogru uzanan kapsul
    g.append(L.silindir("basparmak", 4.2, fx + 9, -6, R + 3.2, 14, M_ten, seg=14, eksen="X"))
    bu = kure("basuc", 4.2, fx + 16, -6, R + 3.2)
    bu.data.materials.append(M_ten)
    g.append(bu)
    # bilek, manset, yelekli kol: sol altta kadrajdan cikiyor
    g.append(L.silindir("bilek", 11, fx - fl / 2 - 6, 0, -2, 12, M_ten, seg=20, eksen="X"))
    g.append(L.silindir("manset", 13.5, fx - fl / 2 - 16, 0, -2, 10, M_gomlek, seg=24, eksen="X"))
    g.append(L.silindir("kol", 15, fx - fl / 2 - 38, 0, -2, 36, M_yelek, seg=24, eksen="X"))
    pivotla(g, (8, 0, 2), -30, -24, olcek=0.96)
    px.shear_scene(0.16)
    return {}


DURUMLAR = {
    "d_isirik": c_d_isirik, "d_buhar": c_d_buhar, "d_yakin": c_d_yakin,
    "d_isitici": c_d_isitici, "d_el": c_d_el,
}
ADAY.update(DURUMLAR)


# ================================================================ DURUM v2
# Kullanici 3a / 3c / 3e'yi secti: "durum daha belirgin ve ayirt edilebilir
# olsun, babanin eli el gibi olsun". v1 durumu jenerik bir silindirdi
# (burrito, mum, baget olabilirdi). Duruma OZGU olan seyler eklendi:
#   - IZGARA IZLERI : oyun durumu izgarada kizartiyor; capraz koyu seritler
#   - KIZARMIS LEKE : lavasin uzerinde benekli kizarma (cel noise)
#   - TASAN DOLGU   : kivrik doner parcalari, kirmizi domates, yesil tursu,
#                     beyaz yogurt, sari patates — tek renk yigin degil

def boru(name, pts, r, mat, kapak=True, nurbs=True):
    """3B nokta dizisi boyunca tup (parmak, kol, doner seridi)."""
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = r
    cu.bevel_resolution = 3
    cu.use_fill_caps = kapak
    sp = cu.splines.new("NURBS" if nurbs and len(pts) > 2 else "POLY")
    sp.points.add(len(pts) - 1)
    for p, c in zip(sp.points, pts):
        p.co = (c[0], c[1], c[2], 1.0)
    if nurbs and len(pts) > 2:
        sp.order_u = 3
        sp.use_endpoint_u = True
    ob = L.link(bpy.data.objects.new(name, cu))
    return L.meshle(ob, mat)


def top(name, r, x, y, z, mat, sx=1.0, sy=1.0, sz=1.0):
    ob = kure(name, r, x, y, z)
    ob.scale = (sx, sy, sz)
    ob.data.materials.append(mat)
    return ob


def _malzeme2(kagit=None):
    M = _malzeme(kagit)
    # kizarmis lavas: rampa + leke (cel noise); ton rampasi daha genis
    M["lavas"] = px.cel("Lavas2", [P["m4"], P["m2"], P["p2"], P["p1"]],
                        [0.0, 0.40, 0.70, 0.88], noise=0.30, noise_scale=7.0)
    M["iz"] = L.cel("IzgaraIzi", [P["m5"], P["m5"], P["m4"], P["m4"]])
    M["domates"] = L.cel("Domates", [P["red3"], P["red2"], P["red1"], P["red0"]])
    M["maydanoz"] = L.cel("Maydanoz", [P["g4"], P["g3"], P["g2"], P["g1"]])
    M["et2"] = L.cel("EtSerit", [P["m5"], P["m4"], P["m3"], P["m1"]])
    return M


def durum_v2(M, R=20, uzun=96, kagit_boy=60, bant=True, etiket=False):
    """Yerel koordinat: eksen +X, acik uc x=+uzun/2, bukulu kagit x=-uzun/2."""
    u2 = uzun / 2.0
    g = []
    g.append(L.silindir("lavas", R, 0, 0, 0, uzun, M["lavas"], seg=40, eksen="X"))
    # kagit: duz kesik uc. Bir surumde alt uca bukulmus sivri bir koni
    # vardi; ikonda anlamsiz bir cikinti gibi okundu, kullanici kaldirtti.
    kx = -u2 + kagit_boy / 2.0
    RP = R + 1.6
    g.append(L.silindir("kagit", RP, kx, 0, 0, kagit_boy, M["kagit"], seg=40, eksen="X"))
    if bant:
        g.append(L.silindir("bant", R + 1.9, kx - 8, 0, 0, 7, M["bant"], seg=40, eksen="X"))
    if etiket:
        g.append(L.silindir("etiket", 7.5, kx - 6, -RP - 0.6, 2, 1.0, M["bant"], seg=20, eksen="Y"))
        g.append(L.silindir("etiket_ic", 5.2, kx - 6, -RP - 1.3, 2, 0.6, M["kagit"], seg=18, eksen="Y"))
    # izgara izleri: kagittan acik uca kadar capraz koyu seritler
    for i, xi in enumerate((-2, 9, 20, 31, 42)):
        if xi > u2 - 3 or xi < kx + kagit_boy / 2 - 1:
            continue
        iz = L.silindir("iz%d" % i, R + 0.45, xi, 0, 0, 2.0, M["iz"], seg=40, eksen="X")
        iz.rotation_euler = (0, math.radians(90 + 26), 0)
        g.append(iz)
    # acik uc: et diski + tasan dolgu
    g.append(L.silindir("ic", R - 2.2, u2 + 0.2, 0, 0, 1.4, M["et"], seg=32, eksen="X"))
    # kivrik doner seritleri (tup), uctan disari dogru egri
    for i, (dy, dz, ey, ez) in enumerate(((-6, 8, -10, 14), (-12, -2, -18, 1), (2, 12, 4, 19),
                                          (-4, -10, -8, -16), (6, 2, 11, 5), (-14, 7, -20, 10))):
        g.append(boru("et_serit%d" % i, [(u2 - 2, dy, dz), (u2 + 5, (dy + ey) / 2, (dz + ez) / 2 + 2),
                                         (u2 + 9, ey, ez)], 1.9, M["et2"]))
    for i, (dy, dz) in enumerate(((-9, -6), (5, 9), (-2, 15))):             # domates dilimi
        d = L.silindir("dom%d" % i, 4.4, u2 + 3.5, dy, dz, 1.6, M["domates"], seg=14, eksen="X")
        g.append(d)
    for i, (dy, dz) in enumerate(((-16, -8), (9, -4), (-8, 3), (1, -14))):  # tursu
        g.append(L.silindir("tur%d" % i, 3.8, u2 + 4.5, dy, dz, 1.4, M["tursu"], seg=12, eksen="X"))
    for i, (dy, dz) in enumerate(((-3, -17), (-17, 4), (12, 12))):           # patates
        g.append(L.kutu("pat%d" % i, u2 + 1, u2 + 11, dz - 1.4, dz + 1.4, dy - 1.4, dy + 1.4,
                        M["patates"]))
    for i, (dy, dz) in enumerate(((-7, 17), (3, 16))):                        # yogurt
        g.append(top("yog%d" % i, 3.0, u2 + 2, dy, dz, M["yogurt"], sx=1.4))
    for i, (dy, dz) in enumerate(((-11, 12), (7, -11))):                      # maydanoz
        g.append(L.kutu("may%d" % i, u2 + 5, u2 + 8, dz - 1.2, dz + 1.2, dy - 1.2, dy + 1.2,
                        M["maydanoz"]))
    return g


# ---------------------------------------------------------------- v2 adaylari
def c_e_isirik():
    """3a v2: kraft kagit + isirik (2B), izgara izli durum.
    Kagittaki yuvarlak kirmizi etiket kaldirildi: ikonda anlamsiz bir
    kirmizi nokta gibi okundu, kullanici sordu."""
    sahne()
    M = _malzeme2(KRAFT)
    g = durum_v2(M, bant=False, etiket=False)
    pivotla(g, (-2, 0, -2), -34, -24)
    px.shear_scene(0.16)
    return {"isirik": True}


def c_e_yakin():
    """3c v2: yakin plan, izgara izleri ve dolgu en buyuk burada."""
    sahne()
    M = _malzeme2()
    g = durum_v2(M)
    pivotla(g, (-16, 0, -14), -36, -22, olcek=1.48)
    px.shear_scene(0.16)
    return {}


def _parmak(M_ten, M_tirnak, x, rr, a0, a1, r=3.3, ad="p"):
    """Durumu saran parmak: yerel +Z'den (ust) -Y'ye (on, kamera) dogru aci.

    Bir onceki surumde parmaklar alt-arkadan baslayip UST-ARKADA bitiyordu:
    kameradan bakinca yalniz govdeleri — capraz seritler — gorunuyor, uclar,
    tirnaklar hic gorunmuyordu; el cizgili bir kol gibi okunuyordu.
    Simdi el durumun ARKASINDA; parmak arkadan UST'ten gecip ON yuzde
    bitiyor, tirnak kameraya bakiyor. Kok kalin, uc ince; ortada bogum
    (yay disari bir birim itiliyor)."""
    g = []
    n = 10
    pts, yar = [], []
    for i in range(n + 1):
        t = i / float(n)
        a = math.radians(a0 + (a1 - a0) * t)
        bog = 1.1 * math.exp(-((t - 0.52) / 0.12) ** 2)       # orta bogum kabarir
        rrt = rr + bog
        pts.append((x, -rrt * math.sin(a), rrt * math.cos(a)))
        yar.append(1.0 - 0.20 * t)                             # uca dogru incelir
    cu = bpy.data.curves.new(ad, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = r
    cu.bevel_resolution = 3
    cu.use_fill_caps = True
    sp = cu.splines.new("NURBS")
    sp.points.add(len(pts) - 1)
    for pt, c, k in zip(sp.points, pts, yar):
        pt.co = (c[0], c[1], c[2], 1.0)
        pt.radius = k
    sp.order_u = 3
    sp.use_endpoint_u = True
    ob = L.link(bpy.data.objects.new(ad, cu))
    g.append(L.meshle(ob, M_ten))
    ua = math.radians(a1)
    ru = r * 0.80
    g.append(top(ad + "_uc", ru, x, -rr * math.sin(ua), rr * math.cos(ua), M_ten))
    # tirnak: ucun dis yuzunde, kameraya bakan yassi oval
    ta = math.radians(a1 - 9)
    tr = rr + ru * 0.78
    tn = top(ad + "_tirnak", ru * 0.72, x, -tr * math.sin(ta), tr * math.cos(ta), M_tirnak,
             sx=1.0, sy=1.0, sz=0.38)
    tn.rotation_euler = (ta, 0, 0)
    g.append(tn)
    return g


def _el_sahnesi(konum, rot_y, rot_z, olcek):
    """3e v2: babanin eli durumu bize uzatiyor.

    El durumun ARKASINDA (yiyecegi birine uzatir gibi). Dort parmak
    arkadan ustten dolanip ON yuzde bitiyor — tirnakli uclar gorunur;
    basparmak alttan gelip onlarla bulusuyor. Bilek durumun altindan
    iner, beyaz manset ve kirmizi yelek koluna baglanir."""
    sahne()
    M = _malzeme2()
    M_ten = px.cel("Ten2", [P["skin3"], P["skin2"], P["skin1"], P["skin0"]],
                   [0.0, 0.42, 0.70, 0.90])
    M_tirnak = px.cel("Tirnak", [P["raw2"], P["raw"], P["skin0"], P["white"]],
                      [0.0, 0.40, 0.72, 0.93])
    M_gomlek = L.cel("Gomlek", [P["s3"], P["s2"], P["s1"], P["s0"]])
    M_yelek = L.cel("Yelek", L.RED)
    R, U = 18, 92
    # kirmizi kagit bandi parmakla basparmak arasindan yara gibi gorunuyordu
    g = durum_v2(M, R=R, uzun=U, kagit_boy=58, bant=False)
    RP = R + 1.6
    rr = RP + 3.6
    x0 = -29
    # (x ofseti, bitis acisi, kalinlik): orta parmak en uzun, serce en kisa.
    # 250 derece = arka; 360 = ust; 450 = 90 = tam on.
    # parmaklar bir onceki denemede kemikli duruyordu: kalinlik +0.5
    for i, (dx, a1, r) in enumerate(((0, 438, 3.8), (7.9, 452, 3.9), (15.8, 440, 3.8),
                                     (23.2, 422, 3.3))):
        g += _parmak(M_ten, M_tirnak, x0 + dx, rr, 250, a1, r=r, ad="parmak%d" % i)
    # basparmak: alttan (arka-alt) gelip onde yukari bakiyor, parmaklarla bulusur
    g += _parmak(M_ten, M_tirnak, x0 + 14, RP + 4.0, 215, 128, r=4.1, ad="basparmak")
    # avuc arkada (parmak koklerini toplar; kismen gorunur)
    g.append(top("avuc", 12, x0 + 10, 9, -4, M_ten, sx=1.25, sy=0.7, sz=1.2))
    # bilek -> manset -> yelek kolu: durumun altindan inip kadrajdan cikar
    g.append(boru("bilek", [(x0 + 11, 7, -RP - 2), (x0 + 8, 5, -RP - 16)], 8.2, M_ten, nurbs=False))
    g.append(boru("manset", [(x0 + 8.5, 5, -RP - 15), (x0 + 6, 5, -RP - 23)], 10.4, M_gomlek,
                  nurbs=False))
    g.append(boru("kol", [(x0 + 6.5, 5, -RP - 22), (x0 - 2, 5, -RP - 52)], 12.5, M_yelek,
                  nurbs=False))
    pivotla(g, konum, rot_y, rot_z, olcek=olcek)
    px.shear_scene(0.16)
    return {}


def c_e_el():
    """3e: babanin eli, tam gorunum (kol kadrajin altindan cikar)."""
    return _el_sahnesi((10, 0, 6), -32, -22, 0.94)


def c_e_el_yakin():
    """3e YAKIN: 3c'nin yakin kadraji + babanin eli. El ve dolgulu uc
    ikonu dolduruyor; acik uc iOS'un yuvarlak kose maskesinin icinde
    kalacak kadar merkeze cekildi, bilek + manset alttan kadrajdan cikiyor.
    Yakin planda ten kagitla karisiyordu: el_hatti parmaklari ayiriyor."""
    ek = _el_sahnesi((-4, 0, -12), -46, -24, 1.36)
    ek["el_hatti"] = True
    return ek


V2 = {"e_isirik": c_e_isirik, "e_yakin": c_e_yakin, "e_el": c_e_el, "e_el_yakin": c_e_el_yakin}
ADAY.update(V2)


# ---------------------------------------------------------------- zeminler
def _rgb(h):
    h = h.lstrip("#")
    return [int(h[i:i + 2], 16) for i in (0, 2, 4)]


def zemin_isin(konu):
    """Isin demeti: merkezden donusumlu iki kirmizi — reklam afisi dili."""
    import numpy as np
    zem = np.zeros((N, N, 4), dtype=np.uint8); zem[..., 3] = 255
    yy, xx = np.mgrid[0:N, 0:N]
    cx = cy = (N - 1) / 2.0
    ang = np.arctan2(yy - cy, xx - cx)
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
    isin = (np.floor((ang + math.pi) / (2 * math.pi) * 14) % 2).astype(bool)
    zem[..., :3] = _rgb(P["red2"])
    zem[isin, :3] = _rgb(P["red1"])
    zem[d > 60, :3] = _rgb(P["red3"])
    zem[(d <= 60) & (d > 57), :3] = _rgb(P["red2"])
    return _bindir(zem, konu)


def zemin_isitici(konu):
    """Doner isiticisi: koyu cerceve, turuncu kare izgara (oyundaki gibi)."""
    import numpy as np
    zem = np.zeros((N, N, 4), dtype=np.uint8); zem[..., 3] = 255
    zem[..., :3] = _rgb(P["ui5"])
    # altin lavas sari/turuncu karelerde kayboluyordu: kareler KIRMIZI-turuncu
    renk = [_rgb(P["f4"]), _rgb(pal.EXTRA["heat_a"]), _rgb(P["f3"])]
    kenar, ara, adet = 8, 3, 5
    kare = (N - 2 * kenar - (adet - 1) * ara) // adet
    for r in range(adet):
        for c in range(adet):
            x0 = kenar + c * (kare + ara)
            y0 = kenar + r * (kare + ara)
            zem[y0:y0 + kare, x0:x0 + kare, :3] = renk[(r * 2 + c) % 3]
            zem[y0:y0 + 1, x0:x0 + kare, :3] = _rgb(P["f2"])      # ust parlaklik
    return _bindir(zem, konu)


def _bindir(zem, konu):
    import numpy as np
    a = konu[..., 3:4].astype(np.float32) / 255.0
    zem[..., :3] = (konu[..., :3] * a + zem[..., :3] * (1 - a)).astype(np.uint8)
    return zem


def buhar_ciz(tam, x0, y0):
    """Uc ince buhar kivrimi, 2B piksel; dis hat yok ki hafif dursun."""
    renkler = [_rgb(P["s0"]), _rgb(P["s1"]), _rgb(P["s2"])]
    for j, (dx, faz) in enumerate(((-7, 0.0), (0, 1.9), (7, 3.6))):
        for t in range(0, 26):
            x = int(round(x0 + dx + 3.0 * math.sin(t * 0.38 + faz)))
            y = int(round(y0 - 4 - t))
            if 0 <= x < N - 1 and 0 <= y < N:
                c = renkler[min(2, t // 9)]
                tam[y, x, :3] = c
                tam[y, x + 1, :3] = c
    return tam


ZEMIN = {"d_buhar": zemin_isin, "d_isitici": zemin_isitici}


def buyut(yol, cikti):
    """128 -> 1024, EN YAKIN KOMSU: her oyun pikseli 8x8 keskin kare."""
    import numpy as np
    a = px.read_png(yol)
    a[..., 3] = 255                                   # App Store: alfa yok
    big = np.repeat(np.repeat(a, BUYUT, 0), BUYUT, 1)
    return px.write_png(big, cikti)


def uret(ad):
    ek = ADAY[ad]() or {}
    konu_yol = px.render(os.path.join(OUT, "%s_konu.png" % ad))
    if px.audit(konu_yol, pal.ALL_HEX, label=ad, show=0):
        px.quantize(konu_yol, pal.ALL_HEX)
    if ek.get("el_hatti"):                               # dis hattan ONCE
        px.write_png(el_hatti(px.read_png(konu_yol), ek.get("hat_renk")), konu_yol)
    if ek.get("isirik"):                                 # dis hattan ONCE
        px.write_png(isirik_ciz(px.read_png(konu_yol)), konu_yol)
    px.outline(konu_yol, hexcol=P["ui5"], alpha=255)    # zeminden ayiran hat
    tam = ZEMIN.get(ad, zemin_bas)(px.read_png(konu_yol))
    if "buhar" in ek:
        tam = buhar_ciz(tam, *ek["buhar"])
    yol = px.write_png(tam, os.path.join(OUT, "%s_128.png" % ad))
    big = buyut(yol, os.path.join(OUT, "%s_1024.png" % ad))
    print("IKON %s -> %s" % (ad, big))
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mod = argv[0] if argv else "hepsi"
    if mod == "hepsi":
        adlar = list(ADAY)
    elif mod == "durumlar":
        adlar = ["durum"] + list(DURUMLAR)
    elif mod == "v2":
        adlar = list(V2)
    else:
        adlar = [mod]
    yollar = [uret(a) for a in adlar]
    px.contact(yollar, len(yollar), os.path.join(OUT, "_%s_x3.png" % mod), pad=8, scale=3)
    print("IKON_DONE %s" % mod)


if __name__ == "__main__":
    main()
