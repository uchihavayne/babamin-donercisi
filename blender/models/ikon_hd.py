"""SIPARIS / ARAYUZ IKONLARI — remake HD.

    blender --background --factory-startup --python blender/models/ikon_hd.py [-- ad ...]
    python blender/hd_atlas.py ikon_hd ikon

food.js icon(id, x, y): siparis balonu, HUD, dukkan listeleri. Her ikon capasi
(x, y) = eski cizimin merkez noktasi; olcu eski ikonun kaplama alanina yakin.
  ikon_<id>   id: wrap pide cola fanta ayran fbox sweet pickle iskender garlic
              sauce hot meat falafel plate coin star
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
import musteri_hd as M

OUT = os.path.join(_HERE, "out", "ikon_hd")
HD = 2
K = 0.35
cel = I.cel
ez, onkutu, on_poligon, torna, hexmul = T.ez, T.onkutu, T.on_poligon, T.torna, T.hexmul
PARCALAR, KOKEN = {}, {}


def parca(ad, tuval, fn, cizgi="#2b1f14", cizgi_alfa=150):
    PARCALAR["ikon_" + ad] = (tuval, fn, cizgi, cizgi_alfa)
    KOKEN["ikon_" + ad] = (tuval[0], tuval[1])


def el(ad, cx, gy, rx, ry, rd, y, mat, seg=16, ring=10):
    e = I.elipsoid(ad, cx, gy, rx, ry, rd, y, mat, seg=seg, ring=ring)
    e.location = (cx, y, ez(gy, y, K))
    return e


def c3(ad, a, b, c, st=(0, .4, .82)):
    return cel(ad, [a, b, c], list(st))


# ---------------------------------------------------------------- ikonlar
def wrap():
    Mg = c3("Durum", "#a87a41", "#f0d5a8", "#f8e6c4")
    L.silindir("durum", 3.6, 1.2, 0, ez(0, 0, K), 11.5, Mg, seg=20, eksen="X")
    for sx in (-1, 1):
        el("uc", 1.2 + sx * 5.5, 0.0, 1.8, 3.4, 3.4, 0.0, Mg)
    # kagit (sol yari) + seritler
    Mk = c3("Kagit", "#cfc8b4", "#f2eee0", "#ffffff")
    L.silindir("kagit", 3.95, -3.3, 0, ez(0, 0, K), 5.6, Mk, seg=20, eksen="X")
    on_poligon("kirmizi", [(-5.9, -2.1), (-1.1, -2.1), (-1.1, -1.0), (-5.9, -1.0)], -4.2, px.flat("Kirmizi", "#d8352c"), K, derin=0.05)
    on_poligon("mavi", [(-5.9, 0.0), (-1.1, 0.0), (-1.1, 1.1), (-5.9, 1.1)], -4.2, px.flat("Mavi", "#2f5f9e"), K, derin=0.05)
    for sx in (5.5, 4.2):
        onkutu("et", sx - 0.4, sx + 0.5, -2.2, -1.2, -4.0, -3.8, px.flat("Et", "#d18c42"), K)
    onkutu("marul", 3.0, 3.9, -2.2, -1.3, -4.1, -3.9, px.flat("Marul", "#a8c257"), K)


def pide():
    Mp = c3("Pide", "#a87a41", "#d9a765", "#eec78c")
    T.torna("pide", [(8.0, 0), (8.2, 1.5), (7.2, 3.2), (0.1, 3.8)], 0, 3.5, 0, 0.45, Mp, K, seg=32)
    for i in range(4):
        el("et", -5 + i * 3.2, -1.8, 1.3, 0.9, 1.0, -1.2, c3("PEt", "#78421a", "#d18c42", "#f0b269"), seg=8, ring=5)
    for i in range(3):
        el("yesil", -3.5 + i * 4, -0.6, 0.7, 0.5, 0.5, -2.2, px.flat("Yesil", "#a8c257"), seg=6, ring=4)


def icecek(liquid, lc0, lc1, pipet):
    def fn():
        # cam: seffaf beyaz govde, icinde sivi, kenarlar parlak, pipet
        yuk = 14.0
        torna("sivi", [(3.1, 0.3), (3.3, 9.5 if liquid != "ayran" else 11.0)], 0.5, 6.8, 0.0, 0.55,
              cel("Sivi" + liquid, [hexmul(lc1, .8), lc1, lc0], [0, .45, .85]), K, seg=20)
        on_poligon("cam", [(-4, -7), (5, -7), (5, 7), (-4, 7)], 1.5, px.flat_a("CamArka", "#ebf4fa", 0.55), K, derin=0.05)
        on_poligon("sol", [(-4, -7), (-3.2, -7), (-3.2, 7), (-4, 7)], -2.4, px.flat_a("CamSol", "#ffffff", 0.75), K, derin=0.02)
        on_poligon("sag", [(4.2, -7), (5, -7), (5, 7), (4.2, 7)], -2.4, px.flat_a("CamSag", "#ffffff", 0.95), K, derin=0.02)
        on_poligon("ust", [(-4, -7), (5, -7), (5, -6.3), (-4, -6.3)], -2.4, px.flat("CamUst", "#ffffff"), K, derin=0.02)
        on_poligon("alt", [(-4, 6.3), (5, 6.3), (5, 7), (-4, 7)], -2.4, px.flat("CamAlt", "#ffffff"), K, derin=0.02)
        if liquid == "cola":
            for bx, by in ((-1.5, 2.5), (2.2, 4.8), (0.5, 0.2)):
                el("kabarcik", bx, by, 0.45, 0.45, 0.2, -2.6, px.flat("Kabarcik", "#9a6a42"), seg=6, ring=4)
        Mp = cel("Pipet", [hexmul(pipet, .7), pipet, "#ffffff"], [0, .45, .9])
        p = L.silindir("pipet", 0.6, 2.9, -1.5, ez(-7.5, -1.5, K), 6.0, Mp, seg=8, eksen="Z")
        p.rotation_euler = (0, math.radians(-12), 0)
    return fn


def _cubuk(ad, cx, gy_alt, boy, gen, y, aci, mat, uc_mat=None):
    """Ekran duzleminde egik kare kesitli cubuk (patates): alt ortasi (cx, gy_alt),
    aci derece (+ saga yatik). Ucu ayri malzemeyle hafif kizarmis."""
    a = math.radians(aci)
    ux, uz = math.sin(a), math.cos(a)            # eksen (ekranda yukari)
    px_, pz_ = math.cos(a), -math.sin(a)         # dik yon
    z0 = ez(gy_alt, y, K)
    def kutu_(t0, t1, m):
        bm = bmesh.new()
        vs = []
        for t in (t0, t1):
            for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
                vs.append(bm.verts.new((cx + ux * t + px_ * sx * gen / 2, y + sy * gen / 2,
                                        z0 + uz * t + pz_ * sx * gen / 2)))
        f = [(0, 1, 2, 3), (7, 6, 5, 4), (0, 4, 5, 1), (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)]
        for q in f:
            bm.faces.new([vs[i] for i in q])
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        return I.mesh_ob(ad, bm, m, smooth=False)
    if uc_mat is None:
        return kutu_(0.0, boy, mat)
    kutu_(0.0, boy - 0.7, mat)
    return kutu_(boy - 0.7, boy, uc_mat)


def fbox():
    """Patates kutusu (food.js icon 'fbox'/'fries'): ustu genis alti dar kirmizi
    karton, on yuzde ust kenari kavisli sari bant; icinde yelpaze gibi acilan
    ince, egik, uclari kizarmis patates cubuklari (arka sira uzun)."""
    # iki ton: yan yana cubuklar ayri okunsun (on yuzler ayni isigi aliyor)
    Mp = cel("PatCubuk", ["#a8691a", "#dca23a", "#f5c95e", "#ffe7a0"], [0, .3, .62, .9])
    Mp2 = cel("PatCubuk2", ["#94591a", "#c98c2c", "#e6b24a", "#f7d98a"], [0, .3, .62, .9])
    Mu = cel("PatUc", ["#9a6120", "#c98a2a", "#e0ac50"], [0, .45, .85])
    Mg = cel("PatGolge", ["#6e4312", "#9a6a22", "#c39040"], [0, .45, .85])
    # arka sira: golgede, aralarda gorunen koyu cubuklar
    for i, (x, boy, aci) in enumerate(((-3.3, 10.0, -12), (-0.6, 11.0, -3), (2.2, 10.6, 7), (4.6, 9.4, 15))):
        _cubuk("pg%d" % i, x, 0.4, boy, 1.2, 1.8, aci, Mg)
    # on sira: yelpaze, arada 0.9 bosluk, tonlar sirayla
    for i, (x, boy, aci) in enumerate(((-4.8, 8.6, -17), (-2.6, 9.8, -9), (-0.4, 10.4, -2),
                                       (1.8, 9.9, 5), (3.9, 8.8, 12), (5.6, 7.6, 19))):
        _cubuk("po%d" % i, x, 0.4, boy, 1.25, 0.2, aci, Mp if i % 2 == 0 else Mp2, Mu)
    # karton kutu: ust 15 genis (gy -1), alt 8 genis (gy 8.5)
    Mk = cel("Karton", ["#5e120d", "#8f1a12", "#c92c21", "#ee5a48"], [0, .26, .52, .84])
    T.torna("kutu", [(4.0, 0), (7.5, 9.5)], 0.5, 8.5, 0, 0.42, Mk, K, seg=28, kapak=False)
    T.torna("agiz", [(7.3, 9.1), (7.6, 9.6)], 0.5, 8.5, 0, 0.42, px.flat("AgizK", "#ff8a74"), K, seg=28, kapak=False)
    # on yuzde ust kenari kavisli sari bant (kutunun on yuzune yapisik)
    Mb = cel("Bant", ["#d8a81e", "#f5cf3c", "#ffe98e"], [0, .45, .85])
    pts = []
    for i in range(13):
        u = i / 12.0
        x = -5.4 + u * 11.8
        pts.append((x, 2.2 + math.sin(u * math.pi) * 1.3))
    for x, g in ((5.3, 5.2), (-4.3, 5.2)):
        pts.append((x, g))
    on_poligon("bant", pts, -3.6, Mb, K, derin=0.05)
    on_poligon("bantcizgi", [(-4.2, 5.4), (5.2, 5.4), (5.0, 5.9), (-4.0, 5.9)], -3.62, px.flat("BantK", "#b01f16"), K, derin=0.04)


def sweet():
    Mt = cel("TTabak", ["#aeb6bd", "#c9cfd6", "#eef2f5"], [0, .45, .85])
    T.torna("tabak", [(6.0, 0), (9.2, 1.0), (8.6, 1.5), (0.1, 1.2)], 0, 5.0, 0, 0.35, Mt, K, seg=32, kapak=False)
    Mb = cel("Baklava", ["#8a5a1a", "#cf9c47", "#e8bd62", "#ffdf9a"], [0, .3, .6, .88])
    for sx in (-4, 4):
        bm = bmesh.new()
        pts = [(0, -2.2), (3.5, 0), (0, 2.2), (-3.5, 0)]
        a = [bm.verts.new((x, y * 2.2, 0)) for x, y in pts]
        b = [bm.verts.new((x, y * 2.2, 2.6)) for x, y in pts]
        for i in range(4):
            bm.faces.new((a[i], a[(i + 1) % 4], b[(i + 1) % 4], b[i]))
        bm.faces.new(list(reversed(a)))
        bm.faces.new(b)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        ob = I.mesh_ob("baklava", bm, Mb, smooth=False)
        ob.location = (sx + 0.5, 0.0, ez(1.5, 0.0, K))
        el("fistik", sx + 0.5, -1.8, 0.7, 0.45, 0.4, -1.0, px.flat("Fistik", "#6b9440"), seg=6, ring=4)


def pickle():
    Mg = cel("Tursu", ["#3d5219", "#5b7726", "#7fa138", "#cfe08a"], [0, .3, .6, .9])
    el("t1", -1.5, 0.5, 3.4, 2.2, 1.2, 0.0, Mg)
    el("t2", 3.5, 1.5, 3.4, 2.2, 1.2, -1.0, Mg)


def iskender():
    """Iskender (food.js icon 'iskender'): beyaz oval tabak, altta pide kupleri,
    ustunde ust uste yigilmis ince doner dilimleri, parlak domates sosu,
    yaninda yogurt topu ve kozlenmis yesil biber."""
    Mt = cel("Tabak", ["#9aa3ac", "#cfd6dd", "#eef2f5", "#ffffff"], [0, .3, .62, .9])
    T.torna("tabak", [(5.2, 0), (9.2, 1.0), (8.6, 1.7), (0.1, 1.3)], 0.3, 5.4, 0, 0.36, Mt, K, seg=36, kapak=False)
    # pide kupleri: tabagin onunde gorunen kizarmis kenar
    Mpd = cel("PideI", ["#5e3414", "#94602c", "#c48e4c", "#e2b474"], [0, .3, .62, .9])
    for i, x in enumerate((-6.6, -4.0, -1.4, 1.2, 3.8)):
        onkutu("pide%d" % i, x, x + 2.2, 2.8, 3.9, -0.9 + (i % 2) * 0.25, 0.7, Mpd, K)
    # doner dilimleri: yassi, hafif kivrik, ust uste
    renkler = (["#4a220c", "#7e3c16", "#b25e26", "#dc8e4c"], ["#55270e", "#8a441a", "#c06a2c", "#e8a05a"])
    dil = ((-4.4, 1.6, 3.2, 12), (-1.4, 1.2, 3.4, -8), (1.6, 1.5, 3.1, 16), (-2.8, 0.0, 2.9, -18), (0.4, -0.4, 3.0, 6), (3.0, 0.4, 2.6, -12))
    for i, (x, g, r, aci) in enumerate(dil):
        e = el("dilim%d" % i, x, g, r, 1.0, 1.9, -0.6 - i * 0.18, cel("Dilim%d" % i, renkler[i % 2], [0, .3, .6, .9]), seg=14, ring=8)
        e.rotation_euler = (0, math.radians(aci), 0)
    # domates sosu (parlak) + tereyagi pariltisi
    e = el("sos", -1.6, -0.7, 3.4, 0.9, 1.6, -2.1, cel("Sos", ["#7e1a0e", "#b82a18", "#e2482a", "#ff8a64"], [0, .3, .62, .9]), seg=16, ring=8)
    e.rotation_euler = (0, math.radians(-6), 0)
    el("tereyag", -2.8, -1.3, 0.9, 0.35, 0.4, -2.6, px.flat("Tereyag", "#ffd98a"), seg=8, ring=4)
    # yogurt topu (sagda) ve yesil biber (arkada)
    el("yogurt", 6.0, 1.6, 2.6, 1.9, 1.7, -0.9, cel("Yogurt", ["#c9c3ae", "#ece8da", "#fbfaf4", "#ffffff"], [0, .3, .62, .9]))
    el("yogurt_tepe", 5.6, 0.4, 1.2, 0.8, 0.9, -1.6, px.flat("YogT", "#ffffff"), seg=10, ring=6)
    b = el("biber", 3.8, -2.4, 3.0, 0.8, 0.8, 0.9, cel("Biber", ["#27481a", "#3f7026", "#5f9a38", "#8cc45a"], [0, .3, .62, .9]), seg=12, ring=6)
    b.rotation_euler = (0, math.radians(-22), 0)


def garlic():
    Mg = cel("Sarimsak", ["#b0a88e", "#cfc7b2", "#f6f2e6", "#ffffff"], [0, .3, .6, .9])
    el("bas", 0.5, 2.5, 4.8, 4.0, 4.0, 0.0, Mg, seg=20, ring=12)
    for dx in (-1.6, 1.6):
        on_poligon("dilim", [(dx + 0.3, -0.5), (dx + 0.7, -0.5), (dx + 0.7, 5.5), (dx + 0.3, 5.5)], -4.2, px.flat("DilimC", "#cfc7b2"), K, derin=0.02)
    L.silindir("sap", 0.5, 0.5, 0.0, ez(-2.5, 0.0, K), 3.0, px.flat("SapS", "#8a8470"), seg=8, eksen="Z")


def sauce():
    Ms = cel("Sos", ["#d6cbae", "#efe7d0", "#fffdf2"], [0, .45, .85])
    T.torna("sos", [(6.0, 0), (5.8, 1.2), (3.5, 2.4), (0.1, 2.8)], 0.5, 3.0, 0, 0.5, Ms, K, seg=24)


def hot():
    Mb = cel("Aci", ["#8e1c14", "#c02a20", "#e2352a", "#ff6a55"], [0, .3, .6, .9])
    el("biber", 0.5, 0.5, 5.0, 2.8, 2.4, 0.0, Mb, seg=20, ring=10)
    p = L.silindir("sap", 0.5, 5.0, -0.5, ez(-3.5, -0.5, K), 2.6, px.flat("SapA", "#7fa138"), seg=8, eksen="Z")
    p.rotation_euler = (0, math.radians(30), 0)


def meat():
    for x0, f in ((-5, .8), (1, .9)):
        onkutu("et", x0, x0 + 5, -2 + (1 if x0 > 0 else 0), 2 + (1 if x0 > 0 else 0), -1, 2,
               cel("EtM%d" % x0, ["#5a2f10", "#a5622a", "#d18c42", "#f0b269"], [0, .3, .6, .9]), K)


def falafel():
    Mf = cel("Falafel", ["#4d290f", "#78421a", "#a5622a", "#d18c42"], [0, .3, .6, .9])
    el("f1", -2.5, 0.5, 3.6, 3.0, 3.0, 0.0, Mf)
    el("f2", 3.5, 1.5, 3.6, 3.0, 3.0, -1.0, Mf)


def plate():
    Mt = cel("TabakP", ["#a9b0b8", "#d7dde3", "#eef2f5"], [0, .45, .85])
    T.torna("tabak", [(6.0, 0), (9.2, 1.0), (8.6, 1.6), (0.1, 1.3)], 0, 5.0, 0, 0.36, Mt, K, seg=32, kapak=False)
    Mk = cel("Kofte", ["#78421a", "#a5622a", "#d18c42", "#f0b269"], [0, .3, .6, .9])
    el("k1", -3.5, 0.0, 3.6, 2.8, 2.6, -0.4, Mk)
    el("k2", 3.5, 0.8, 3.6, 2.8, 2.6, -1.4, Mk)
    for x, h in ((5.5, 4), (7.5, 3)):
        onkutu("patates", x, x + 1, -h, 0, -2.6, -1.8, px.flat("PatP", "#f7cc63"), K)


def coin():
    Mc = cel("Altin", ["#a97113", "#e0a41f", "#ffd34e", "#fff2a8"], [0, .3, .62, .9])
    L.silindir("para", 5.2, 0.5, 0.0, ez(-0.5, 0.0, K), 1.6, Mc, seg=24, eksen="Y")
    L.silindir("ic", 3.2, 0.5, -1.0, ez(-0.5, -1.0, K), 0.3, cel("AltinIc", ["#e0a41f", "#ffd34e", "#fff2a8"], [0, .5, .9]), seg=20, eksen="Y")


def star():
    Ms = cel("Yildiz", ["#a97113", "#e0a41f", "#ffd34e", "#fff2a8"], [0, .3, .62, .9])
    pts = []
    for k in range(10):
        a = -math.pi / 2 + k * math.pi / 5
        r = 5.6 if k % 2 == 0 else 2.4
        pts.append((0.5 + math.cos(a) * r, 0.5 + math.sin(a) * r))
    bm = bmesh.new()
    merkez = bm.verts.new((0.5, -1.4, ez(0.5, -1.4, K)))
    kenar = [bm.verts.new((x, 0.0, ez(g, 0.0, K))) for x, g in pts]
    arka = bm.verts.new((0.5, 1.0, ez(0.5, 1.0, K)))
    for i in range(10):
        bm.faces.new((merkez, kenar[i], kenar[(i + 1) % 10]))
        bm.faces.new((arka, kenar[(i + 1) % 10], kenar[i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    I.mesh_ob("yildiz", bm, Ms, smooth=False)


parca("wrap", (-8, -6, 17, 12), wrap)
parca("pide", (-9, -5, 19, 10), pide)
parca("cola", (-6, -11, 12, 19), icecek("cola", "#6b3a1c", "#43220f", "#e2382a"))
parca("fanta", (-6, -11, 12, 19), icecek("fanta", "#ffb03c", "#f0821c", "#3f79c0"))
parca("ayran", (-6, -11, 12, 19), icecek("ayran", "#ffffff", "#e4e2d8", "#3f79c0"))
parca("fbox", (-9, -12, 19, 23), fbox)
parca("sweet", (-10, -6, 21, 12), sweet)
parca("pickle", (-6, -3, 13, 7), pickle)
parca("iskender", (-11, -6, 23, 12), iskender)
parca("garlic", (-6, -5, 13, 12), garlic)
parca("sauce", (-7, -3, 15, 7), sauce)
parca("hot", (-6, -6, 13, 11), hot)
parca("meat", (-6, -4, 13, 8), meat)
parca("falafel", (-7, -4, 15, 9), falafel)
parca("plate", (-10, -5, 21, 11), plate)
parca("coin", (-6, -7, 13, 13), coin)
parca("star", (-6, -6, 13, 13), star)


# ---------------------------------------------------------------- "istemiyorum" cipi (ui.js yokRozet)
# kirmizi halka + krem yuz + malzeme (tursu / yogurt / patates) + capraz kirmizi cizgi
def yok(m):
    def fn():
        Mh = cel("YokHalka", ["#6d1a12", "#8e1c14", "#c0281c", "#e2483a"], [0, .3, .6, .9])
        L.halka("halka", 5.2, 5.2, 0.9, 0.0, 0.0, 0.2, Mh)
        L.disk("yuz", 4.6, 0.0, 0.0, 0.8, 0.4, 0.1, cel("YokYuz", ["#d8cdb4", "#efe6d0", "#f7efdc", "#fffaf0"], [0, .3, .6, .9]))
        if m == "pickle":
            Mt = cel("TursuY", ["#2f5a14", "#4a7a22", "#6aa032", "#9ac85a"], [0, .3, .6, .9])
            e = I.elipsoid("tursu", 0.0, 0.0, 3.4, 2.4, 1.2, 0.0, Mt, seg=16, ring=8)
            e.location = (0.0, -0.4, 0.0)
            for k in range(5):
                a = k * 1.256
                d = I.elipsoid("cekirdek", 0, 0, 0.35, 0.35, 0.2, 0, px.flat("TursuC", "#d8ec9a"), seg=6, ring=4)
                d.location = (math.cos(a) * 1.4, -1.5, math.sin(a) * 1.0)
        elif m == "yogurt":
            My = cel("YogY", ["#b8c4d0", "#dfe7ee", "#f4f8fb", "#ffffff"], [0, .3, .6, .9])
            e = I.elipsoid("yog1", 0.0, 0.0, 3.4, 1.8, 1.4, 0.0, My, seg=16, ring=8)
            e.location = (0.0, -0.5, -0.8)
            e = I.elipsoid("yog2", 0.0, 0.0, 2.2, 1.6, 1.2, 0.0, My, seg=14, ring=8)
            e.location = (0.0, -1.0, 0.8)
        else:
            Mp = cel("PatY", ["#b8791e", "#e0a83c", "#f7cc63", "#ffe9a3"], [0, .3, .62, .9])
            for k, (x, h, a) in enumerate(((-2.0, 5.2, -12), (0.2, 6.2, 2), (2.3, 5.0, 14))):
                L.kutu("pat%d" % k, x - 0.6, x + 0.6, -3.0, -3.0 + h, -1.5, -0.3, Mp).rotation_euler = (0, math.radians(a), 0)
        # capraz yasak cizgisi (sol ust -> sag alt), ustte
        ob = L.kutu("cizgi", -5.0, 5.0, -0.65, 0.65, -2.6, -2.0, cel("YokCizgi", ["#8e1c14", "#c0281c", "#e2483a", "#ff7a6a"], [0, .3, .6, .9]))
        ob.rotation_euler = (0, math.radians(45), 0)
    return fn


def cip(m, yasak, zemin=True):
    """BIRLESIK SURUM: yeni siparis balonunun (order_draw.order_badge) malzeme
    cipi. Krem (istenen) / pembe (istemiyor) yuvarlak levha + malzeme; istemiyor
    ise kirmizi capraz cizgi (sol alt -> sag ust). Capa: cipin merkezi (x, y);
    levha ekranda x-7..x+7, y-6..y+7."""
    def fn():
        st = [0, .3, .6, .9]
        renk = ["#b09d78", "#d2c29e", "#e7dec3", "#f8f1de"] if not yasak else ["#c08e74", "#e0b397", "#f4d3bc", "#fde9dc"]
        if zemin:
            ob = L._egri("cip", [L.yuvarlak_dikdortgen(14, 13, 2.4)], 0.0, -0.5, 0.6, 1.2, 0.35)
            L.meshle(ob, cel("Cip" + ("Y" if yasak else "N"), renk, st))
        if m == "pickle":
            Mt = cel("TursuC", ["#2f5a14", "#4a7a22", "#6aa032", "#9ac85a"], st)
            e = I.elipsoid("tursu", 0.0, 0.0, 4.2, 2.6, 1.2, 0.0, Mt, seg=16, ring=8)
            e.location = (0.0, -0.5, 0.2)
            for k in range(5):
                a = k * 1.256
                d = I.elipsoid("cekirdek", 0, 0, 0.4, 0.4, 0.2, 0, px.flat("TursuCC", "#e9dd8a"), seg=6, ring=4)
                d.location = (math.cos(a) * 1.8, -1.7, 0.2 + math.sin(a) * 1.1)
        elif m == "yogurt":
            Mk = cel("YogKase", ["#46707f", "#5a8798", "#6f9aab", "#a8c8d4"], st)
            e = I.elipsoid("kase", 0.0, 0.0, 4.4, 2.2, 1.3, 0.0, Mk, seg=18, ring=8)
            e.location = (0.0, -0.4, -1.4)
            My = cel("YogC", ["#c9c1ad", "#ece2c8", "#fff5de", "#ffffff"], st)
            e = I.elipsoid("yog", 0.0, 0.0, 3.8, 1.5, 1.2, 0.0, My, seg=16, ring=8)
            e.location = (0.0, -1.0, 0.3)
            e = I.elipsoid("yog2", 0.0, 0.0, 1.8, 1.2, 0.9, 0.0, My, seg=12, ring=6)
            e.location = (1.3, -1.5, 1.4)
        elif m == "fries":
            Mp = cel("PatC", ["#8a5518", "#c9852c", "#e8b44a", "#f4ce69"], [0, .3, .62, .9])
            for k, (x, h, a) in enumerate(((-3.2, 7.6, -8), (0.0, 8.2, 0), (3.2, 7.4, 8))):
                L.kutu("pat%d" % k, x - 0.8, x + 0.8, -4.2, -4.2 + h, -1.6, -0.2, Mp).rotation_euler = (0, math.radians(a), 0)
        else:
            Me = cel("EtC", ["#5a2f10", "#9c5427", "#c47a3c", "#e4a45b"], st)
            for k in range(3):
                ob = L.kutu("et%d" % k, -3.6, 3.6, -0.9, 0.9, -1.6, -0.3, Me)
                ob.location = (-1.0 + k * 1.6, 0.0, 2.2 - k * 2.0)
                ob.rotation_euler = (0, math.radians(-14), 0)
        if yasak:
            ob = L.kutu("cizgi", -6.2, 6.2, -0.75, 0.75, -2.8, -2.1, cel("CipCizgi", ["#7a1a14", "#b33028", "#d8483a", "#ff7a6a"], st))
            ob.rotation_euler = (0, math.radians(-45), 0)
    return fn


for _m in ("pickle", "yogurt", "fries", "meat"):
    parca("cip_%s" % _m, (-8, -7, 16, 15), cip(_m, False), cizgi="#6b5236", cizgi_alfa=110)
    parca("cip_%s_yok" % _m, (-8, -7, 16, 15), cip(_m, True), cizgi="#6b3a26", cizgi_alfa=110)
    # hazirlama seridi (order_draw.draw_preparation_overlay): zeminsiz malzeme
    parca("mal_%s" % _m, (-8, -7, 16, 15), cip(_m, False, False), cizgi="#1e140c", cizgi_alfa=140)


for _m in ("pickle", "yogurt", "fries"):
    parca("yok_%s" % _m, (-7, -7, 14, 14), yok(_m), cizgi="#4a0e0a", cizgi_alfa=120)


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa = PARCALAR[ad]
    M.sahne(gx0, gy0, w, h)
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
                   "kokenler": {k: list(v) for k, v in KOKEN.items()}}, fp, indent=1)
    print("IKON_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
