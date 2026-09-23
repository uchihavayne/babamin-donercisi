"""MUSTERI PARCALARI — remake HD, TON KODLU (renk oyunda shader'la).

    blender --background --factory-startup --python blender/models/musteri_hd.py [-- onek ...]
    python blender/hd_atlas.py musteri_hd musteri

chars.js drawCustomer bir musteriyi 16 yuz ozelligi + sac + aksesuar + kalip
ile KODLA ciziyor; ayni parca her ten / sac / gomlek rengiyle kullanilsin diye
parcalar gri tonla kodlanmis render ediliyor (shaders/ton.gdshader):
  CARPAN (gomlek, sac, sapka, biyik, sakal): gri = shadeCol carpani / 2
          .55 #464646  .62 #4f4f4f  .72 #5c5c5c  .8 #666666  1.0 #808080
          1.14 #919191  1.25 #9f9f9f  1.3 #a6a6a6
  PALET  (ten): s0 #ffffff  s1 #aaaaaa  s2 #555555  s3 #000000
  NORMAL (gozluk, pusu, bant, kel parlakligi): gercek renk

Parcalar ve capalar (oyundaki koordinatlar, chars.js):
  govde_<bw>            bw 18/26/32   capa (x, by)          CARPAN (gomlek)
  boyun_ust             capa (hx, hy)                        PALET
  boyun_alt             capa (x, by)                         PALET
  el                    capa elin merkezi (cx, cy)           PALET
  kafa_<sekil>_<hw>     10 kafa + cocuk 3_9, capa (hx, hy)   PALET
  kulak_<0|1|2>         capa kulagin merkezi (cx, cy)        PALET
  burun_<0..4>          capa (hx, fy)                        PALET
  sac_<stil>_<G>        stil 0..10, G = sacG 9..12, capa (hx, hy)  CARPAN (sac)
  sac_2p_<G>            kel parlakligi                       NORMAL
  biyik_<6|7>           capa (hx, fy + 6 + agzU)             CARPAN (sac)
  sakal_<skG>_<skA>     capa (hx, hy)                        CARPAN (sac)
  gozluk_<tip>_<icE>    tip 0..3, capa (hx, fy)              NORMAL
  sapka_<G>             capa (hx, hy)                        CARPAN (gomlek * .8)
  pusu_<G>, bant_<G>    capa (hx, hy)                        NORMAL
Yuz ifadesi (kas, goz, agiz), yanak, kirisik, cil, ben, cene, kalip kiyafetleri
bu asamada kodla ciziliyor.
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

OUT = os.path.join(_HERE, "out", "musteri_hd")
HD = 2
K = 0.2
ez, onkutu, on_poligon, torna = T.ez, T.onkutu, T.on_poligon, T.torna
PARCALAR, KOKEN = {}, {}


def parca(ad, tuval, fn, cizgi=None, cizgi_alfa=255):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa)
    KOKEN[ad] = (tuval[0], tuval[1])


def gri(f):
    v = max(0, min(255, int(round(f / 2.0 * 255))))
    return "#%02x%02x%02x" % (v, v, v)


def carpan(ad, faktorler, stops):
    return px.cel(ad, [gri(f) for f in faktorler], stops)


def carpan_duz(ad, f):
    return px.flat(ad, gri(f))


TON = {"s0": "#ffffff", "s1": "#aaaaaa", "s2": "#555555", "s3": "#000000"}


def palet(ad, seviyeler, stops):
    return px.cel(ad, [TON[s] for s in seviyeler], stops)


def palet_duz(ad, s):
    return px.flat(ad, TON[s])


def kontur(sekil, hw, hh=11):
    g = []
    n = hh * 2 + 1
    for i in range(n):
        dy = i - hh
        u = i / (n - 1)
        e = math.sqrt(max(0, 1 - (dy * dy) / (hh * hh)))
        if sekil == 1:
            f = e ** .62 * (.9 - u * .16)
            if u > .74:
                f *= (1 - (u - .74) * 1.9)
        elif sekil == 2:
            f = e ** .78 if u < .3 else (max(e ** .78, .93) if u < .82 else (.93 - (u - .82) * 4))
        elif sekil == 3:
            f = e ** .58 * 1.05
            if u > .88:
                f *= (1 - (u - .88) * 4)
        elif sekil == 4:
            f = e ** .7 * (1.1 - u * .1) - u ** 3 * .55
        else:
            f = e
        wv = math.floor(f * hw + .5)
        g.append(0 if wv < 2 else wv)
    return g


def elipsoid(ad, cx, gy, rx, ry, rz_derin, y, mat, seg=16, ring=10):
    """Ekranda (cx, gy) merkezli, rx x ry yaricapli, derinligi rz_derin olan elipsoid."""
    ob = I.elipsoid(ad, cx, gy, rx, ry, rz_derin, y, mat, seg=seg, ring=ring)
    ob.location = (cx, y, ez(gy, y, K))
    return ob


def kutu(ad, x0, x1, g0, g1, y0, y1, mat):
    return onkutu(ad, x0, x1, g0, g1, y0, y1, mat, K)


# ---------------------------------------------------------------- govde
def govde(bw):
    def fn():
        M = carpan("Govde", [.62, .72, 1.0, 1.14], [0, .22, .42, .8])
        hw = bw / 2.0
        prof = []
        for i in range(0, 35):
            h = i
            if h <= 27:
                r = hw
            else:
                u = (h - 27) / 7.0
                r = hw * math.sqrt(max(0.0, 1 - u * u))
            prof.append((max(0.01, r), h))
        torna("govde", prof, 0, 32, 4.0, 0.42, M, K, seg=28)
        Mk = carpan("Kol", [.62, .66, .8, .92], [0, .2, .42, .8])
        for sx in (-1, 1):
            torna("kol", [(0.5, 0), (2.5, 1.5), (2.5, 20), (2.2, 22)], sx * (hw + 0.5), 30, 1.5, 0.8, Mk, K, seg=14)
        yon = 4.0 - hw * 0.42 - 0.6
        on_poligon("yaka", [(-6, 2), (6, 2), (6, 5), (3, 6), (-3, 6), (-6, 5)], yon, carpan_duz("Yaka", .62), K, derin=0.05)
        for sx in (-1, 1):
            on_poligon("v", [(sx * 5.4, 3), (sx * 4.6, 3), (sx * 0.2, 7.2), (-sx * 0.5, 7.2)], yon - 0.05, carpan_duz("YakaV", .55), K, derin=0.02)
    return fn


def boyun_ust():
    M = palet("BoyunU", ["s2", "s1"], [0, .42])
    torna("boyun", [(3.6, 0), (3.6, 6.5)], 0.0, 16.0, 1.0, 0.8, M, K, seg=16)


def boyun_alt():
    M = palet("BoyunA", ["s2", "s1"], [0, .42])
    torna("boyun", [(3.0, 0), (3.0, 5.5)], 0.0, 6.0, 1.0, 0.8, M, K, seg=16)


def el():
    M = palet("El", ["s2", "s1", "s0"], [0, .38, .82])
    elipsoid("el", 0.5, 0.5, 3.4, 3.2, 2.6, 0, M)


# ---------------------------------------------------------------- kafa
def kontur_surekli(sekil, hw, hh=11):
    """kontur() ile ayni formul, yuvarlama ve '<2 ise 0' kesmesi YOK:
    geometri bununla kurulur (tam sayi basamaklari normallerde serit yapiyordu)."""
    def f_(i):
        n = hh * 2 + 1
        dy = i - hh
        u = i / (n - 1)
        e = math.sqrt(max(0, 1 - (dy * dy) / (hh * hh)))
        if sekil == 1:
            f = e ** .62 * (.9 - u * .16)
            if u > .74:
                f *= (1 - (u - .74) * 1.9)
        elif sekil == 2:
            f = e ** .78 if u < .3 else (max(e ** .78, .93) if u < .82 else (.93 - (u - .82) * 4))
        elif sekil == 3:
            f = e ** .58 * 1.05
            if u > .88:
                f *= (1 - (u - .88) * 4)
        elif sekil == 4:
            f = e ** .7 * (1.1 - u * .1) - u ** 3 * .55
        else:
            f = e
        return max(0.0, f * hw)
    return f_


def kafa(sekil, hw):
    def fn():
        KN = kontur(sekil, hw)
        fs = kontur_surekli(sekil, hw)
        M = palet("Kafa", ["s3", "s2", "s1", "s0"], [0, .04, .2, .44])
        satirlar = [i for i, w in enumerate(KN) if w > 0]
        r0, r1 = satirlar[0], satirlar[-1]
        bm = bmesh.new()
        seg = 36
        halkalar = []
        adim = 16
        for j in range(adim * (r1 - r0 + 1) + 1):
            # satir indeksi i: ust kenar r0 .. alt kenar r1 + 1 (ekran satiri i -> gy = i - 11)
            yy = r0 + j / float(adim)
            i = min(max(yy - 0.5, 0.0), 22.0)
            a0 = int(math.floor(i))
            fr = i - a0
            w = fs(a0) * (1 - fr) + fs(min(22, a0 + 1)) * fr
            # uclarda kubbe: silueti tam satirlarda kapat
            ust = (yy - r0)
            alt = (r1 + 1 - yy)
            if ust < 1.0:
                w *= math.sqrt(max(0.0, ust))
            if alt < 1.0:
                w *= math.sqrt(max(0.0, alt))
            w = max(0.02, w)
            gy = yy - 11.0
            z = ez(gy, 0.0, K)
            halkalar.append([bm.verts.new((0.5 + w * math.cos(2 * math.pi * k / seg), w * 0.9 * math.sin(2 * math.pi * k / seg), z))
                             for k in range(seg)])
        for a_, b_ in zip(halkalar, halkalar[1:]):
            for k in range(seg):
                bm.faces.new((a_[k], a_[(k + 1) % seg], b_[(k + 1) % seg], b_[k]))
        bm.faces.new(list(reversed(halkalar[0])))
        bm.faces.new(halkalar[-1])
        bmesh.ops.remove_doubles(bm, verts=bm.verts[:], dist=0.0001)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        I.mesh_ob("kafa", bm, M)
    return fn


def kulak(k):
    def fn():
        M = palet("Kulak", ["s3", "s2", "s1"], [0, .1, .45])
        rx, ry = {0: (2, 3), 1: (2, 4), 2: (1, 2)}[k]
        elipsoid("kulak", 0.5, 0.5, rx + 0.1, ry + 0.2, 1.2, 1.5, M)
        elipsoid("ic", 0.5, 0.6, max(0.5, rx * 0.4), max(0.8, ry * 0.45), 0.4, 0.2, palet_duz("KulakIc", "s2" if k != 1 else "s3"))
    return fn


def burun(n):
    def fn():
        # eski cizimde burun s2 golge + s1 isik: yuzden koyu okunur (s0 olursa yuzde kaybolup iri bir leke gibi duruyordu)
        M = palet("Burun", ["s3", "s2", "s1", "s0"], [0, .08, .42, .9])
        Md = palet_duz("Delik", "s3")
        yon = -2.0
        if n == 1:
            elipsoid("uc", 0.5, 4.2, 3.6, 2.6, 1.9, yon, M)
            for dx in (-3, 3):
                elipsoid("delik", dx + 0.5, 5.4, 0.7, 0.55, 0.3, yon - 2.0, Md, seg=8, ring=4)
        elif n == 2:
            torna("kopru", [(1.0, 0), (1.0, 5.0)], 0.5, 6.0, yon, 0.9, M, K, seg=10)
            elipsoid("uc", 0.5, 5.4, 1.9, 1.7, 1.5, yon - 0.4, M)
            elipsoid("delik", 1.6, 6.4, 0.6, 0.45, 0.3, yon - 2.0, Md, seg=8, ring=4)
        elif n == 3:
            torna("kopru", [(1.1, 0), (1.3, 6.0)], 0.5, 6.5, yon, 0.9, M, K, seg=10)
            elipsoid("uc", 1.5, 6.3, 2.8, 1.9, 1.7, yon - 0.5, M)
            for dx in (-2, 3):
                elipsoid("delik", dx + 0.5, 6.9, 0.65, 0.5, 0.3, yon - 2.4, Md, seg=8, ring=4)
        elif n == 4:
            elipsoid("uc", 0.5, 5.2, 2.7, 1.9, 1.6, yon, M)
            elipsoid("kopru", 0.5, 3.6, 1.0, 1.4, 0.8, yon + 0.4, M, seg=10, ring=6)
            for dx in (-2, 2):
                elipsoid("delik", dx + 0.5, 6.3, 0.6, 0.45, 0.3, yon - 1.8, Md, seg=8, ring=4)
        else:
            elipsoid("uc", 0.5, 4.2, 2.8, 2.7, 1.9, yon, M)
            elipsoid("delik", 2.8, 5.8, 0.55, 0.45, 0.3, yon - 2.1, Md, seg=8, ring=4)
    return fn


# ---------------------------------------------------------------- sac
def sac_malz(ad="Sac"):
    return carpan(ad, [.55, .72, 1.0, 1.3], [0, .18, .42, .8])


def kubbe(ad, cx, gy, rx, ry, M, y=-0.5, derin=None, alt_duz=True):
    """Ust yarisi elips kubbe (sac takkesi): alt kenar duz."""
    derin = derin if derin is not None else rx * 0.9
    bm = bmesh.new()
    seg = 28
    halkalar = []
    n = 10
    for i in range(n + 1):
        a = (math.pi / 2) * i / n
        r = max(0.02, rx * math.cos(a))
        gyy = gy - ry * math.sin(a)
        halkalar.append([bm.verts.new((cx + r * math.cos(2 * math.pi * k / seg), y + (r / rx) * derin * math.sin(2 * math.pi * k / seg), ez(gyy, y, K)))
                         for k in range(seg)])
    for a_, b_ in zip(halkalar, halkalar[1:]):
        for k in range(seg):
            bm.faces.new((a_[k], a_[(k + 1) % seg], b_[(k + 1) % seg], b_[k]))
    bm.faces.new(list(reversed(halkalar[0])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return I.mesh_ob(ad, bm, M)


def sac(stil, G):
    def fn():
        M = sac_malz()
        Ml = carpan_duz("SacIsik", 1.3)
        Md = carpan_duz("SacKoyu", .72)
        cx = 0.5
        if stil == 0:
            kubbe("kubbe", cx, -3.5, G + 0.5, 8.5, M)
            kutu("perçem", -G, G + 1, -5, -2, -G * 0.6, 1, M)
            elipsoid("isik", -2.5, -9, 4.5, 1.6, 1.0, -G * 0.85, Ml, seg=12, ring=6)
            kutu("fav_s", -G, -G + 1, -2, -1, -G * 0.6 - 0.1, 1, Md)
            kutu("fav_g", G, G + 1, -2, -1, -G * 0.6 - 0.1, 1, Md)
        elif stil == 1:
            kubbe("kubbe", cx, -3.0, G + 0.5, 6.5, M)
            for i in range(6):
                sx = -G + 1 + i * 4
                gy0 = -12 + (i % 2)
                torna("diken", [(1.8, 0), (1.5, 4.0), (0.3, 7.2)], sx + 1.5, gy0 + 7, -G * 0.4, 0.8, M, K, seg=10)
                elipsoid("diken_isik", sx + 0.8, gy0 + 0.8, 0.7, 0.9, 0.4, -G * 0.4 - 1.5, Ml, seg=8, ring=4)
        elif stil == 2:
            for sx in (-1, 1):
                x0 = -G - 1 if sx < 0 else G - 2
                torna("tutam", [(1.6, 0), (2.1, 3.5), (1.6, 7.0)], x0 + 2, 3, 0.0, 0.8, M, K, seg=12)
        elif stil == 3:
            kubbe("kubbe", cx, -1.0, G + 1.5, 10.0, M)
            for sx in (-1, 1):
                x0 = -G - 3 if sx < 0 else G - 1
                torna("yan", [(2.4, 0), (2.6, 8), (2.4, 16)], x0 + 2, 9, -1.0, 0.8, M, K, seg=12)
            elipsoid("isik", -2.5, -10, 5.5, 1.6, 1.0, -G * 0.95, Ml, seg=12, ring=6)
        elif stil == 4:
            kubbe("kubbe", cx, -2.5, G + 0.5, 7.5, M)
            elipsoid("topuz", 1.5, -12, 4.5, 4.5, 4.0, 0.0, M)
            elipsoid("isik", -0.5, -14, 1.2, 0.9, 0.6, -4.0, Ml, seg=8, ring=4)
        elif stil == 5:
            kubbe("kubbe", cx, -2.5, G + 0.5, 7.5, M)
            for j in range(5):
                elipsoid("bukle", -G + 2.5 + j * 5, -9, 4.3, 3.3, 3.0, -G * 0.55, M)
            elipsoid("isik", -1.5, -11, 3.5, 1.4, 1.0, -G * 0.6 - 2.5, Ml, seg=12, ring=6)
        elif stil == 6:
            elipsoid("afro", cx, -8, G + 3.5, 7.5, G + 2.0, 1.0, M, seg=24, ring=14)
            for sx in (-1, 1):
                elipsoid("yan", sx * (G + 1) + 0.5, -4, 4.4, 5.4, 3.5, 0.5, M)
            elipsoid("isik", -2.5, -11, 4.5, 1.6, 1.0, -G - 1.5, Ml, seg=12, ring=6)
        elif stil == 8:
            kubbe("kubbe", cx, -2.0, G + 1.5, 9.0, M)
            kutu("percem", -G - 1, G + 2, -5, -1, -G * 0.6, 1, M)
            for sx in (-1, 1):
                x0 = -G - 2 if sx < 0 else G - 1
                torna("yan", [(2.4, 0), (2.6, 10), (2.4, 21)], x0 + 2, 17, -1.0, 0.8, M, K, seg=12)
            elipsoid("isik", -2.5, -9, 4.5, 1.6, 1.0, -G * 0.85, Ml, seg=12, ring=6)
            on_poligon("isik_yan", [(-G - 1, -2), (-G - 0.4, -2), (-G - 0.4, 14), (-G - 1, 14)], -3.5, carpan_duz("SacIsikYan", 1.15), K, derin=0.05)
        elif stil == 9:
            kubbe("kubbe", cx, -2.5, G + 0.5, 7.5, M)
            kutu("percem", -G, G + 1, -5, -2, -G * 0.6, 1, M)
            kutu("toka", G - 0.5, G + 2.5, -4, 0, -1.0, 1.5, Md)
            bm = bmesh.new()
            for q in range(15):
                qx = G + 1 + math.floor(math.sin(q * 0.33) * 2 + 0.5)
                elipsoid("kuyruk", qx + 1.5, -1.5 + q, 1.9, 1.0, 1.4, 0.0, Ml if q % 4 == 0 else M, seg=10, ring=5)
            elipsoid("isik", -2.5, -9, 4.5, 1.6, 1.0, -G * 0.85, Ml, seg=12, ring=6)
        elif stil == 10:
            kubbe("kubbe", cx, -3.5, G + 0.5, 8.5, M)
            kutu("percem", -G, G + 1, -5, -2, -G * 0.6, 1, M)
            elipsoid("topuz", cx, -13, 5.2, 4.2, 4.0, 0.0, M)
            elipsoid("topuz_isik", cx, -14, 3.0, 2.0, 1.5, -3.4, Ml, seg=12, ring=6)
            kutu("fav_s", -G, -G + 1, -2, -1, -G * 0.6 - 0.1, 1, Md)
            kutu("fav_g", G, G + 1, -2, -1, -G * 0.6 - 0.1, 1, Md)
        else:  # 7: taranmis
            kubbe("kubbe", cx, -3.0, G + 0.5, 7.5, M)
            for k in range(5):
                on_poligon("tarak", [(-8 + k * 4 - 0.3, -9), (-8 + k * 4 + 0.4, -9), (-5 + k * 4 + 0.4, -4), (-5 + k * 4 - 0.3, -4)],
                           -G - 1.5, carpan_duz("Tarak", 1.3), K, derin=0.02)
    return fn


def sac_parilti(G):
    def fn():
        elipsoid("parilti", -3.5, -8, 4.5, 2.4, 0.5, -3, px.flat("Parilti", "#fff2dc"), seg=12, ring=6)
        elipsoid("isik", 0.5, -6, G - 1.5, 3.4, 0.4, -2.5, px.flat_a("ParlakBeyaz", "#ffffff", 0.25), seg=16, ring=8)
    return fn


def biyik(G):
    def fn():
        M = sac_malz("Biyik")
        torna("biyik", [(0.8, 0), (1.3, 1.0), (0.8, 2.0)], 0, 2, -1.0, 1.0, M, K, seg=8)
        bm_ob = L.silindir("govde", 1.1, 0.0, -1.0, ez(1.0, -1.0, K), G * 2.0, M, seg=12, eksen="X")
        for sx in (-1, 1):
            elipsoid("uc", sx * (G + 0.3) + (0.5 if sx > 0 else -0.5), 2.0, 1.0, 1.0, 0.9, -0.8, M, seg=10, ring=5)
    return fn


def sakal(skG, skA):
    def fn():
        M = sac_malz("Sakal")
        Ml = carpan("SakalIsik", [.86, 1.2, 1.3], [0, .3, .7])
        for b in range(-skG, skG + 1):
            bh = 3 + math.floor(math.sin((b + skG) * 0.7) * 2 + 0.5)
            kutu("tel", b, b + 1, 6, 6 + bh + 3, -2.0, 0.0, M)
        elipsoid("cene", 0.5, 10.5, skA + 0.5, 3.4, 2.4, -1.5, M)
        elipsoid("cene_isik", 0.5, 11.5, max(2, skA - 2) + 0.5, 2.3, 1.5, -3.2, Ml)
    return fn


def gozluk(tip, icE):
    def fn():
        glS = -10 + icE
        glG = 4 - icE
        glC = "#5a4a3a" if tip == 2 else "#2b2018"
        Mc = px.flat("Cerceve%d" % tip, glC)
        yon = -3.0
        if tip == 1:
            for x0 in (glS, glG):
                cx = x0 + 3.5
                dis = [(cx + 3.5 * math.cos(2 * math.pi * j / 24), 0.5 + 3.5 * math.sin(2 * math.pi * j / 24)) for j in range(24)]
                ic = [(cx + 2.6 * math.cos(2 * math.pi * j / 24), 0.5 + 2.6 * math.sin(2 * math.pi * j / 24)) for j in range(24)]
                for j in range(24):
                    k = (j + 1) % 24
                    on_poligon("cer", [dis[j], dis[k], ic[k], ic[j]], yon, Mc, K, derin=0.05)
                on_poligon("cam", ic, yon + 0.1, px.flat_a("Cam1", "#ffffff", 0.2), K, derin=0.02)
                elipsoid("parilti", cx - 1.0, -0.5, 0.6, 0.6, 0.2, yon - 0.2, px.flat_a("Par1", "#ffffff", 0.8), seg=8, ring=4)
            kutu("kopru", glS + 7, glG, 0.2, 1.0, yon - 0.1, yon + 0.2, Mc)
        elif tip == 2:
            for x0 in (glS, glG):
                for (a, b, c, d) in ((x0 + 1, -2, x0 + 6, -1), (x0 + 1, 2, x0 + 6, 3), (x0 + 1, -2, x0 + 2, 3), (x0 + 5, -2, x0 + 6, 3)):
                    kutu("cer", a, c, b, d, yon, yon + 0.3, Mc)
                kutu("cam", x0 + 2, x0 + 5, -1, 2, yon + 0.2, yon + 0.3, px.flat_a("Cam2", "#ffffff", 0.16))
            kutu("kopru", glS + 6, glG + 1, 0, 1, yon, yon + 0.3, Mc)
            kutu("sap_s", glS, glS + 1, -1, 0, yon, yon + 0.3, Mc)
            kutu("sap_g", glG + 6, glG + 7, -1, 0, yon, yon + 0.3, Mc)
        elif tip == 3:
            Mg = px.flat("GunesCer", "#1c1610")
            for x0 in (glS, glG):
                levha = L.levha("cer", 7, 7, 1.5, x0 + 3.5, ez(0.5, yon, K), yon, 0.3, 0.0, Mg)
                L.levha("cam", 5, 5, 1.0, x0 + 3.5, ez(0.5, yon - 0.2, K), yon - 0.2, 0.1, 0.0,
                        px.cel("GunesCam", ["#223044", "#33455e", "#4a6284"], [0, .4, .8]))
                elipsoid("parilti", x0 + 1.5, -1.5, 0.6, 0.6, 0.2, yon - 0.5, px.flat_a("Par3", "#ffffff", 0.55), seg=8, ring=4)
            kutu("kopru", glS + 7, glG, -1, 0, yon, yon + 0.3, Mg)
        else:
            for x0 in (glS, glG):
                for (a, b, c, d) in ((x0, -3, x0 + 7, -2), (x0, 3, x0 + 7, 4), (x0, -3, x0 + 1, 4), (x0 + 6, -3, x0 + 7, 4)):
                    kutu("cer", a, c, b, d, yon, yon + 0.3, Mc)
                kutu("cam", x0 + 1, x0 + 6, -2, 3, yon + 0.2, yon + 0.3, px.flat_a("Cam0", "#ffffff", 0.22))
                elipsoid("parilti", x0 + 2.5, -1.5, 0.6, 0.6, 0.2, yon - 0.2, px.flat_a("Par0", "#ffffff", 0.8), seg=8, ring=4)
            kutu("kopru", glS + 7, glG, 0, 1, yon, yon + 0.3, Mc)
    return fn


def sapka(G):
    def fn():
        M = carpan("Sapka", [.6, .7, 1.0, 1.25], [0, .15, .42, .82])
        kubbe("tepe", 0.5, -6.0, G + 0.5, 7.5, M)
        kutu("kusak", -G - 1, G + 2, -10, -4, -G * 0.7, 1.0, carpan("Kusak", [.6, .7, .8], [0, .3, .7]))
        L.silindir("siper", 1.1, -G - 1.5, -G * 0.6, ez(-5, -G * 0.6, K), 7.5, carpan("Siper", [.5, .6, .9], [0, .3, .75]), seg=10, eksen="X")
        elipsoid("dugme", 0.5, -13, 1.3, 1.1, 1.1, 0.0, carpan_duz("Dugme", 1.3), seg=8, ring=5)
    return fn


def pusu(G):
    def fn():
        Mb = px.cel("Kumas", ["#c9c9c4", "#e2e2dc", "#f4f4f0", "#ffffff"], [0, .2, .45, .85])
        kubbe("ortu", 0.5, -4.0, G + 2.5, 9.5, Mb)
        for sx in (-1, 1):
            x0 = -G - 3 if sx < 0 else G - 1
            torna("yan", [(2.2, 0), (2.4, 7), (2.2, 14)], x0 + 2, 9, 0.5, 0.7, Mb, K, seg=12)
        Mr = px.flat("Desen", "#d8443a")
        for k in range(7):
            for dx, dy in ((0, -10 + (k % 2) * 2), (1, -8 + (k % 2) * 2)):
                kutu("desen", -G + k * 3 + dx, -G + k * 3 + dx + 1, dy, dy + 1, -G - 2.5, -G - 2.4, Mr)
            kutu("desen_yan", -G - 2 + (k % 3), -G - 1 + (k % 3), -2 + k, -1 + k, -3.5, -3.4, Mr)
        Mg = px.cel("Agal", ["#1a1a18", "#2b2b28", "#55554e"], [0, .4, .8])
        L.silindir("agal", 1.5, 0.5, -G * 0.2, ez(-12.5, -G * 0.2, K), G * 2 + 4, Mg, seg=12, eksen="X")
    return fn


def bant(G):
    def fn():
        Mb = px.cel("Bant", ["#2a5990", "#3f79c0", "#6b9ad8"], [0, .35, .8])
        L.silindir("bant", 2.0, 0.5, -G * 0.2, ez(-6.0, -G * 0.2, K), G * 2 + 2.5, Mb, seg=14, eksen="X")
        kutu("kuyruk", G - 1, G + 4, -7, 1, 0.0, 1.0, Mb)
        elipsoid("uc", G + 3.5, 1.5, 0.8, 0.8, 0.5, -0.2, px.flat("BantUc", "#2a5990"), seg=8, ring=4)
    return fn


for _bw in (18, 26, 32):
    parca("govde_%d" % _bw, (-(_bw // 2 + 6), -4, _bw + 12, 38), govde(_bw), cizgi=gri(.5), cizgi_alfa=150)
parca("boyun_ust", (-6, 8, 13, 10), boyun_ust)
parca("boyun_alt", (-5, -1, 11, 9), boyun_alt)
parca("el", (-4, -4, 9, 9), el, cizgi=TON["s3"], cizgi_alfa=120)
BASLAR = [(s, hw) for s in range(5) for hw in (11, 12)] + [(3, 9)]
for _s, _hw in BASLAR:
    parca("kafa_%d_%d" % (_s, _hw), (-15, -13, 31, 26), kafa(_s, _hw), cizgi=TON["s2"], cizgi_alfa=255)
for _k in (0, 1, 2):
    parca("kulak_%d" % _k, (-4, -6, 9, 13), kulak(_k), cizgi=TON["s2"], cizgi_alfa=200)
for _n in range(5):
    parca("burun_%d" % _n, (-6, -2, 13, 12), burun(_n))
for _G in (9, 10, 11, 12):
    for _st in range(11):
        parca("sac_%d_%d" % (_st, _G), (-_G - 7, -22, 2 * _G + 16, 42), sac(_st, _G), cizgi=gri(.5), cizgi_alfa=170)
    parca("sac_2p_%d" % _G, (-_G - 2, -12, 2 * _G + 5, 10), sac_parilti(_G))
    parca("sapka_%d" % _G, (-_G - 8, -16, 2 * _G + 12, 14), sapka(_G), cizgi=gri(.45), cizgi_alfa=160)
    parca("pusu_%d" % _G, (-_G - 5, -16, 2 * _G + 11, 28), pusu(_G), cizgi="#8a8a84", cizgi_alfa=150)
    parca("bant_%d" % _G, (-_G - 3, -10, 2 * _G + 10, 14), bant(_G), cizgi="#1e3d66", cizgi_alfa=150)
for _G in (6, 7):
    parca("biyik_%d" % _G, (-_G - 3, -2, 2 * _G + 6, 6), biyik(_G), cizgi=gri(.5), cizgi_alfa=140)
for _skG, _skA in [(7, 4), (7, 5), (8, 4), (8, 5), (9, 7), (10, 7), (10, 8), (11, 8), (11, 9)]:
    parca("sakal_%d_%d" % (_skG, _skA), (-_skG - 3, 4, 2 * _skG + 7, 12), sakal(_skG, _skA), cizgi=gri(.5), cizgi_alfa=150)
for _t in range(4):
    for _ic in (0, 1, 2):
        parca("gozluk_%d_%d" % (_t, _ic), (-12, -5, 25, 11), gozluk(_t, _ic))


def sahne(gx0, gy0, w, h):
    D.sahne(gx0, gy0, w, h, 1.0)
    gunes = [o for o in bpy.context.scene.objects if o.type == "LIGHT"][0]
    d = Vector((0.35, 0.80, -0.45)).normalized()
    gunes.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa = PARCALAR[ad]
    sahne(gx0, gy0, w, h)
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
    print("MUSTERI_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
