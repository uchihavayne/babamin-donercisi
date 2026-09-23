"""YIYECEK KAPLARI — remake HD: iskender tabagi, patates kutusu, icecek
kupasi, tatli tabagi.

    blender --background --factory-startup --python blender/models/yiyecek_hd.py [-- parca ...]
    python blender/hd_atlas.py yiyecek_hd yiyecek

Oyundaki karsiliklari (food.js):
  drawPlate      : porselen tabak (kenar, cukur, mavi hat)   -> tabak_<olcek> (100 85 74 58)
                   capa (cx, cy); icerik (pide, et, tereyag, domates, biber, yogurt) kodda
  drawFriesCup   : kirmizi karton + etiket (+ patatesler)     -> patates_kutusu_ok / _bos
                   capa (cx, cy)
  drawCup        : cam arkasi (buzlu ton)                     -> kupa_arka
                   cam kenarlari, agiz, taban, pipet          -> kupa_on_kirmizi (kola) / kupa_on_mavi
                   capa (cx, cy); icecek seviyesi ve kola kabarciklari kodda
  drawSweetPlate : kucuk tabak + serbet                       -> tatli_tabagi, capa (cx, cy)
                   baklavalar istasyon atlasindan
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

OUT = os.path.join(_HERE, "out", "yiyecek_hd")
HD = 2
cel = I.cel
ez, onkutu, on_poligon, torna, hexmul = T.ez, T.onkutu, T.on_poligon, T.torna, T.hexmul
PARCALAR, KOKEN, OLCEK = {}, {}, {}


def parca(ad, tuval, fn, K, olcekler=None, cizgi=None, cizgi_alfa=140):
    for sc in (olcekler or [None]):
        tam = ad if sc is None else "%s_%d" % (ad, int(round(sc * 100)))
        PARCALAR[tam] = (tuval, fn, K, cizgi, cizgi_alfa, sc or 1.0)
        KOKEN[tam] = (tuval[0], tuval[1])
        if sc is not None:
            OLCEK[tam] = sc


# ---------------------------------------------------------------- tabak
def tabak():
    K = 0.5
    der = 0.8
    Mp = cel("Porselen", ["#aeb6bd", "#d6dee4", "#e9eef2", "#fbfdfe"], [0, .25, .5, .8])
    prof = [(13.5, 0.0), (16.0, 0.4), (18.6, 1.7), (20.0, 2.6), (19.6, 2.95), (18.8, 3.0), (17.2, 2.2),
            (16.0, 1.5), (12.0, 1.25), (6.0, 1.2), (0.0, 1.2)]
    torna("tabak", prof, 0, 3.0, 0, der, Mp, K, seg=48, kapak=False)
    torna("tabak_alt", [(13.5, 0.0), (0.3, 0.0)], 0, 3.0, 0, der, px.flat("TabakAlt", "#aeb6bd"), K, seg=48, kapak=False)
    # kenardaki mavi hat
    torna("mavi", [(17.6, 2.62), (18.5, 2.97)], 0, 2.98, 0, der, px.flat("MaviHat", "#c5d8eb"), K, seg=48, kapak=False)


# ---------------------------------------------------------------- patates kutusu
def _cubuk(ad, cx, gy_alt, boy, gen, y, aci, mat, uc_mat, K):
    """Egik kare kesitli patates cubugu: alt ortasi (cx, gy_alt), aci derece."""
    a = math.radians(aci)
    ux, uz = math.sin(a), math.cos(a)
    pxx, pzz = math.cos(a), -math.sin(a)
    z0 = ez(gy_alt, y, K)

    def kutu_(t0, t1, m):
        bm = bmesh.new()
        vs = []
        for t in (t0, t1):
            for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
                vs.append(bm.verts.new((cx + ux * t + pxx * sx * gen / 2, y + sy * gen / 2,
                                        z0 + uz * t + pzz * sx * gen / 2)))
        for q in ((0, 1, 2, 3), (7, 6, 5, 4), (0, 4, 5, 1), (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)):
            bm.faces.new([vs[i] for i in q])
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        return I.mesh_ob(ad, bm, m, smooth=False)
    if uc_mat is None:
        return kutu_(0.0, boy, mat)
    kutu_(0.0, boy - 0.7, mat)
    return kutu_(boy - 0.7, boy, uc_mat)


def patates_kutusu(dolu):
    def fn():
        K = 0.3
        ustG = 21.0 if dolu else 19.0
        altG = 11.0
        gy, gh = -3.0, 14.0
        taban = gy + gh
        der = 0.42
        Mk = cel("Karton", ["#5e120d", "#7d1610", "#c22a20", "#e8483a"], [0, .28, .5, .82])
        torna("kutu", [(altG / 2.0, 0.0), (ustG / 2.0, gh)], 0, taban, 0, der, Mk, K, seg=32, kapak=False)
        torna("kutu_taban", [(altG / 2.0, 0.0), (0.3, 0.0)], 0, taban, 0, der, px.flat("KutuTaban", "#5e120d"), K, seg=32, kapak=False)
        # ic yuzey (agizdan gorunen koyu karton)
        torna("ic", [(altG / 2.0 - 0.5, 0.6), (ustG / 2.0 - 0.6, gh - 0.05)], 0, taban, 0, der, px.flat("KutuIc", "#6b1710"), K, seg=32, kapak=False)
        # agiz kenari
        torna("agiz", [(ustG / 2.0 - 0.1, gh - 0.4), (ustG / 2.0 + 0.1, gh)], 0, taban, 0, der, px.flat("AgizKenar", "#ff7f6c"), K, seg=32, kapak=False)
        yon = -(ustG / 2.0) * der - 0.4
        # sari etiket: onde, kutunun egimine uyan yamuk
        kapY = gy + 4

        def gen(r):
            u = (r + 4.0) / (gh - 1.0)
            return math.floor(ustG + (altG - ustG) * u + 0.5) - 4

        renkler = ["#ffe98e", "#f7d34a", "#f7d34a", "#e0be32", "#e0be32", "#c9a41c"]
        for r in range(6):
            g = gen(r)
            on_poligon("etiket", [(-g / 2.0, kapY + r), (g / 2.0, kapY + r), (g / 2.0, kapY + r + 1), (-g / 2.0, kapY + r + 1)],
                       yon, px.flat("Etiket%d" % r, renkler[r]), K, derin=0.05)
        on_poligon("etiket_golge", [(-(ustG - 6) / 2.0, kapY + 6), ((ustG - 6) / 2.0, kapY + 6), ((ustG - 6) / 2.0, kapY + 7), (-(ustG - 6) / 2.0, kapY + 7)],
                   yon, px.flat_a("EtiketGolge", "#5e120d", 0.35), K, derin=0.05)
        # yan katlanma cizgileri
        for sx, x in ((-1, -ustG / 2.0 + 3), (1, ustG / 2.0 - 4)):
            on_poligon("kat", [(x, gy + 2), (x + 0.6, gy + 2), (x + 0.6 - sx * 1.2, gy + gh - 1), (x - sx * 1.2, gy + gh - 1)],
                       yon - 0.02, px.flat_a("Kat", "#5e120d", 0.3), K, derin=0.02)
        # "M" benzeri kivrim: etiketin ustunde koyu serit
        on_poligon("agiz_bant", [(-(ustG - 3) / 2.0, gy), ((ustG - 3) / 2.0, gy), ((ustG - 3) / 2.0, gy + 1.2), (-(ustG - 3) / 2.0, gy + 1.2)],
                   yon - 0.3, px.flat("AgizBant", "#8e1c14" if dolu else "#7d1610"), K, derin=0.02)
        if dolu:
            # ince, yelpaze gibi acilan, iki tonlu, ucu kizarmis cubuklar (siparis
            # ikonuyla ayni dil); arka sira golgede. Eski: 1.7 genis kalin bloklar.
            Mp = cel("PatCubuk", ["#c0801e", "#eab440", "#fbd46c", "#fff0b8"], [0, .24, .5, .86])
            Mp2 = cel("PatCubuk2", ["#a86a1c", "#d89c34", "#f0bf56", "#fbe19a"], [0, .24, .5, .86])
            Mu = cel("PatUc", ["#9a6120", "#c98a2a", "#e0ac50"], [0, .45, .85])
            Mg = cel("PatGolge", ["#6e4312", "#9a6a22", "#c39040"], [0, .45, .85])
            arka = ((-6.4, 10.2, -13), (-3.6, 11.6, -6), (-0.8, 12.2, 1), (2.0, 11.4, 7), (4.8, 10.0, 13), (7.2, 8.8, 18))
            on = ((-7.6, 8.2, -19), (-5.4, 9.6, -12), (-3.1, 10.4, -6), (-0.8, 10.8, -1), (1.5, 10.2, 4),
                  (3.8, 9.4, 10), (6.0, 8.4, 15), (7.9, 7.2, 21))
            for i, (x, boy, aci) in enumerate(arka):
                _cubuk("pg%d" % i, x, 2.0, boy + 1.0 + 0.8 * D.hash1(i * 3.1), 1.2, 1.2, aci, Mg, None, K)
            for i, (x, boy, aci) in enumerate(on):
                _cubuk("po%d" % i, x, 1.4, boy + 1.2 + 0.8 * D.hash1(i * 5.7), 1.25, -0.2, aci,
                       Mp if i % 2 == 0 else Mp2, Mu, K)
    return fn


# ---------------------------------------------------------------- kupa
def _kupa_gen(y):
    return 5 + math.floor(y * 0.12 + 0.5)


def kupa_arka():
    K = 0.3
    pts = [(-_kupa_gen(0), -6), (_kupa_gen(0), -6), (_kupa_gen(15), 10), (-_kupa_gen(15), 10)]
    on_poligon("cam", pts, 2.0, px.flat_a("CamArka", "#dfeaf0", 0.3), K, derin=0.05)


def kupa_on(pipet):
    def fn():
        K = 0.3
        # sol parlak kenar, sag mavimsi kenar
        on_poligon("sol", [(-_kupa_gen(0), -6), (-_kupa_gen(0) + 0.9, -6), (-_kupa_gen(15) + 0.9, 10), (-_kupa_gen(15), 10)],
                   -3.0, px.flat_a("CamSol", "#ffffff", 0.75), K, derin=0.05)
        on_poligon("sol_ic", [(-_kupa_gen(0) + 1.4, -5), (-_kupa_gen(0) + 1.9, -5), (-_kupa_gen(15) + 1.9, 8), (-_kupa_gen(15) + 1.4, 8)],
                   -3.0, px.flat_a("CamSolIc", "#ffffff", 0.35), K, derin=0.05)
        on_poligon("sag", [(_kupa_gen(0) - 1, -6), (_kupa_gen(0) - 0.1, -6), (_kupa_gen(15) - 0.1, 10), (_kupa_gen(15) - 1, 10)],
                   -3.0, px.flat_a("CamSag", "#c8dce6", 0.85), K, derin=0.05)
        # agiz halkasi (ustten ince elips) + taban
        ag = [(5.5 * math.cos(2 * math.pi * j / 24), -6 + 1.0 * math.sin(2 * math.pi * j / 24)) for j in range(24)]
        ic = [(4.6 * math.cos(2 * math.pi * j / 24), -6 + 0.55 * math.sin(2 * math.pi * j / 24)) for j in range(24)]
        for j in range(24):
            k = (j + 1) % 24
            on_poligon("agiz", [ag[j], ag[k], ic[k], ic[j]], -3.1, px.flat_a("Agiz", "#ffffff", 0.9), K, derin=0.02)
        tb = [(6.0 * math.cos(2 * math.pi * j / 24), 9 + 2.0 * math.sin(2 * math.pi * j / 24)) for j in range(24)]
        on_poligon("taban", tb, -2.9, px.flat_a("Taban", "#dcebf2", 0.8), K, derin=0.02)
        tb2 = [(4.5 * math.cos(2 * math.pi * j / 24), 8.6 + 1.1 * math.sin(2 * math.pi * j / 24)) for j in range(24)]
        on_poligon("taban_ic", tb2, -2.95, px.flat_a("TabanIc", "#ffffff", 0.35), K, derin=0.02)
        # pipet: egik silindir
        renk = "#e2382a" if pipet == "kirmizi" else "#3f79c0"
        Mp = cel("Pipet" + pipet, [hexmul(renk, .6), hexmul(renk, .85), renk, "#ffffff"], [0, .3, .5, .9])
        x0, y0, x1, y1 = 2.6, -10.0, 4.6, -3.0
        uz = math.hypot(x1 - x0, y1 - y0)
        p = L.silindir("pipet", 0.9, (x0 + x1) / 2.0, -3.5, ez((y0 + y1) / 2.0, -3.5, K), uz, Mp, seg=10, eksen="Z")
        p.rotation_euler = (0, math.atan2(x1 - x0, -(y1 - y0)), 0)
        # pipetin beyaz seridi
        on_poligon("pipet_serit", [(x0 + 0.5, y0 + 1.5), (x0 + 0.9, y0 + 1.5), (x0 + 1.3, y0 + 3.0), (x0 + 0.9, y0 + 3.0)],
                   -4.6, px.flat("PipetSerit", "#ffffff"), K, derin=0.02)
    return fn


# ---------------------------------------------------------------- tatli tabagi
def tatli_tabagi():
    K = 0.5
    der = 0.62
    Mp = cel("TTabak", ["#aeb6bd", "#c9cfd6", "#d7dde3", "#eef2f5"], [0, .25, .5, .8])
    prof = [(9.0, 0.0), (11.0, 0.4), (13.0, 1.4), (12.6, 1.7), (11.2, 1.3), (10.0, 0.9), (0.3, 0.8)]
    torna("tabak", prof, 0, 5.0, 0, der, Mp, K, seg=40, kapak=False)
    torna("serbet", [(8.8, 0.95), (0.3, 1.1)], 0, 5.0, 0, der * 0.72, cel("Serbet", ["#8a5a1a", "#a8701f", "#c98a2a", "#e0a848"], [0, .25, .5, .8]), K, seg=40, kapak=False)


parca("tabak", (-22, -10, 44, 22), tabak, 0.5, [1.0, 0.85, 0.74, 0.58], cizgi="#7d858c", cizgi_alfa=110)
parca("patates_kutusu_ok", (-12, -14, 24, 26), patates_kutusu(True), 0.3, cizgi="#4a0e0a", cizgi_alfa=130)
parca("patates_kutusu_bos", (-12, -14, 24, 26), patates_kutusu(False), 0.3, cizgi="#4a0e0a", cizgi_alfa=130)
parca("kupa_arka", (-8, -8, 16, 20), kupa_arka, 0.3)
parca("kupa_on_kirmizi", (-8, -12, 16, 24), kupa_on("kirmizi"), 0.3)
parca("kupa_on_mavi", (-8, -12, 16, 24), kupa_on("mavi"), 0.3)
parca("tatli_tabagi", (-15, -2, 30, 12), tatli_tabagi, 0.5, cizgi="#8a929a", cizgi_alfa=100)


def uret(ad):
    (gx0, gy0, w, h), fn, K, cizgi, cizgi_alfa, sc = PARCALAR[ad]
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
    print("YIYECEK_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
