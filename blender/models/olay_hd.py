"""OLAY KARAKTERLERI — remake HD (art.js drawAsker, drawGozcu, drawThief,
drawRakip, drawKedi, drawScooter; drawInspector panosu).

    blender --background --factory-startup --python blender/models/olay_hd.py [-- ad ...]
    python blender/hd_atlas.py olay_hd olay

Hareketli parcalar ayri: kod eski formullerle (yurume fazi, sallanma, kol
salinimi, kuyruk) konumlar. Sokak figurleri (asker, gozcu) saga bakar,
kod aynalar. Capa = eski fonksiyonun (x, y) ayak noktasi.
  asker_bacak_<ph> ph 0..7, asker_govde, asker_kol_<k> k 0..2 (ka -1..1)
  gozcu_bacak_<ph>, gozcu_cephe_bacak, gozcu_yan, gozcu_cephe_bak, gozcu_cephe_sor
  hirsiz_govde, hirsiz_bas, hirsiz_kol_sol, hirsiz_kol_sag, hirsiz_canta
  rakip
  kedi_yuru, kedi_bacak_on, kedi_bacak_arka, kedi_kuyruk, kedi_otur, kedi_otur_kuyruk, kedi_yiyor
  scooter_arac, scooter_surucu, scooter_bas (+ _60: yolda paneli olcegi)
  pano   capa (bx, by) (denetci panosu)
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
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "olay_hd")
HD = 2
K = S.K
ez = T.ez
kutu, elipsoid, cerceve, on_levha = S.kutu, S.elipsoid, S.cerceve, S.on_levha
mat_ton, mat_duz, hexmul = S.mat_ton, S.mat_duz, T.hexmul
PARCALAR, KOKEN, OLCEK = {}, {}, {}
FRG = [[2, -2], [1, -1], [0, 0], [-1, 1], [-2, 2], [-1, 1], [0, 0], [1, -1]]


def parca(ad, tuval, fn, cizgi="#0e0c0a", cizgi_alfa=120, olcek=1.0):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa, olcek)
    KOKEN[ad] = (tuval[0], tuval[1])
    if olcek != 1.0:
        OLCEK[ad] = olcek


def uzuv(a, b, r, y, mat, seg=10):
    ax, ag = a
    bx, bg = b
    uz = math.hypot(bx - ax, bg - ag)
    ob = L.silindir("uzuv", r, (ax + bx) / 2.0, y, ez((ag + bg) / 2.0, y, K), max(0.01, uz), mat, seg=seg, eksen="Z")
    ob.rotation_euler = (0, math.atan2(bx - ax, -(bg - ag)), 0)
    for (px_, pg) in (a, b):
        elipsoid(px_, pg, r, r, r, y, mat, seg=8, ring=5)
    return ob


def c3(renk, f=(0.66, 0.86, 1.0, 1.14)):
    return mat_ton(renk, f=f)


# ================================================================ asker
UNI, UNI2, MIG, TEN = "#4a5148", "#39403a", "#3a423c", "#c99a66"


def asker_bacak(ph):
    def fn():
        on, arka = FRG[ph]
        for dx, y, renk, bot in ((arka, 0.8, UNI2, "#1a1e19"), (on, -0.8, UNI, "#20241f")):
            uzuv((0.5, -4.2), (0.5 + dx * 0.8, -1.2), 0.85, y, c3(renk))
            elipsoid(0.5 + dx * 0.8 + 0.5, -0.6, 1.2, 0.65, 0.8, y - 0.2, c3(bot, f=(0.7, 0.9, 1.0, 1.4)), seg=8, ring=5)
    return fn


def asker_govde():
    T.torna("govde", [(2.3, 0), (2.5, 3.0), (2.2, 5.0), (1.2, 5.6)], 0.5, -4.0, 0.0, 0.8, c3(UNI), K, seg=16)
    T.torna("kemer", [(2.55, 0), (2.55, 0.9)], 0.5, -5.0, 0.0, 0.82, c3("#20241f"), K, seg=16)
    elipsoid(1.4, -5.3, 0.45, 0.35, 0.2, -2.1, mat_duz("#8a7a3a"), seg=6, ring=4)
    # tufek sirtta (yon +1: namlu arkada yukari)
    uzuv((-1.6, -11.2), (0.9, -5.6), 0.42, 1.8, c3("#2a2620", f=(0.7, 0.9, 1.0, 1.5)))
    kutu(-2.0, -1.2, -12.2, -11.0, 1.6, 2.2, mat_duz("#1a1612"))
    # bas + kulak + goz
    elipsoid(0.5, -10.5, 1.8, 1.8, 1.6, 0.0, c3(TEN), seg=14, ring=10)
    elipsoid(1.7, -10.7, 0.35, 0.4, 0.2, -1.7, mat_duz("#14161a"), seg=6, ring=4)
    # kask
    I.elipsoid("kask", 0.5, -11.2, 2.4, 1.9, 2.2, 0.0, c3(MIG, f=(0.6, 0.85, 1.0, 1.25)), seg=16, ring=10).location = (0.5, 0.0, ez(-11.6, 0.0, K))
    kutu(-2.2, 3.2, -11.5, -10.9, -2.4, 2.4, c3(MIG, f=(0.55, 0.8, 1.0, 1.2)), bevel=0.2)


def asker_kol(ka):
    def fn():
        uzuv((3.2, -8.2), (3.4 + ka * 0.3, -5.6 + ka), 0.6, -1.6, c3(UNI2))
        elipsoid(3.5 + ka * 0.3, -5.0 + ka, 0.6, 0.6, 0.5, -1.8, c3(TEN), seg=8, ring=5)
    return fn


# ================================================================ gozcu
PALTO, PALTO2, ISIK, BANT, ROZET = "#23262c", "#191c21", "#33373f", "#8e1c14", "#c9a23a"


def gozcu_bacak(ph):
    def fn():
        on, arka = FRG[ph]
        for dx, y, renk in ((arka, 0.8, PALTO2), (on, -0.8, ISIK)):
            uzuv((0.5, -4.2), (0.5 + dx * 0.8, -1.2), 0.8, y, c3(renk, f=(0.7, 0.9, 1.0, 1.25)))
            elipsoid(0.5 + dx * 0.8 + 0.5, -0.6, 1.1, 0.6, 0.8, y - 0.2, c3("#0b0d10", f=(0.8, 1.0, 1.0, 2.2)), seg=8, ring=5)
    return fn


def gozcu_cephe_bacak():
    for dx, y in ((-1.0, 0.2), (2.0, 0.2)):
        uzuv((dx, -4.2), (dx, -1.0), 0.85, y, c3(PALTO2, f=(0.7, 0.9, 1.0, 1.3)))
        elipsoid(dx + (-0.5 if dx < 0 else 0.5), -0.5, 1.0, 0.6, 0.8, y - 0.3, c3("#0b0d10", f=(0.8, 1.0, 1.0, 2.2)), seg=8, ring=5)


def _gozcu_bas(cephe):
    hy = -11.5
    elipsoid(0.5, hy, 1.6, 1.7, 1.5, 0.0, c3(TEN), seg=14, ring=10)
    if cephe:
        for ex in (-0.5, 1.5):
            elipsoid(ex, hy + 0.2, 0.35, 0.35, 0.2, -1.55, mat_duz("#14161a"), seg=6, ring=4)
    else:
        elipsoid(1.6, hy + 0.2, 0.35, 0.35, 0.2, -1.55, mat_duz("#14161a"), seg=6, ring=4)
    # fotr sapka: tepe + kirmizi bant + altin rozet + siperlik
    T.torna("tepe", [(1.9, 0), (1.95, 1.2), (1.6, 2.0), (0.2, 2.2)], 0.5, hy - 0.6, 0.0, 1.0, c3(PALTO2, f=(0.7, 0.95, 1.0, 1.5)), K, seg=16)
    T.torna("bant", [(1.98, 0), (1.98, 0.6)], 0.5, hy - 0.6, 0.0, 1.0, c3(BANT), K, seg=16)
    elipsoid(0.5, hy - 1.9, 0.35, 0.35, 0.2, -2.0, mat_duz(ROZET), seg=6, ring=4)
    if cephe:
        I.yatay_elips("siper", 0.5, hy - 0.2, 3.3, 0.3, c3("#0b0d10", f=(0.8, 1.0, 1.0, 2.2)), K, ry_ekran=1.1, seg=24)
    else:
        I.yatay_elips("siper", 1.3, hy - 0.2, 3.0, 0.3, c3("#0b0d10", f=(0.8, 1.0, 1.0, 2.2)), K, ry_ekran=0.9, seg=24)


def gozcu_yan():
    T.torna("palto", [(2.0, 0), (2.4, 1.2), (2.4, 4.2), (1.9, 5.6), (1.0, 6.0)], 0.5, -3.6, 0.0, 0.85, c3(PALTO, f=(0.66, 0.9, 1.0, 1.4)), K, seg=16)
    T.torna("kemer", [(2.45, 0), (2.45, 0.7)], 0.5, -5.2, 0.0, 0.87, c3("#0e1013"), K, seg=16)
    _gozcu_bas(False)


def gozcu_cephe(sor):
    def fn():
        T.torna("palto", [(2.8, 0), (3.3, 1.2), (3.3, 4.2), (2.6, 5.6), (1.2, 6.0)], 0.5, -3.6, 0.0, 0.7, c3(PALTO, f=(0.66, 0.9, 1.0, 1.4)), K, seg=18)
        T.torna("kemer", [(3.35, 0), (3.35, 0.7)], 0.5, -5.2, 0.0, 0.72, c3("#0e1013"), K, seg=18)
        on_levha([(0.2, -9.5), (0.8, -9.5), (0.8, -4.2), (0.2, -4.2)], -2.45, mat_duz(PALTO2))
        elipsoid(1.5, -5.5, 0.45, 0.45, 0.2, -2.5, mat_duz(ROZET), seg=6, ring=4)
        for sx in (-2.3, 3.3):
            elipsoid(sx, -9.3, 0.5, 0.5, 0.3, -2.4, mat_duz(ROZET), seg=6, ring=4)
        if sor:
            uzuv((3.3, -8.4), (6.2, -7.8), 0.55, -1.2, c3(PALTO2))
            elipsoid(6.6, -7.8, 0.6, 0.5, 0.5, -1.3, c3(TEN), seg=8, ring=5)
            uzuv((-2.3, -8.4), (-2.9, -6.0), 0.55, -0.6, c3(PALTO2))
        else:                                           # eller belde
            for a, b in (((-2.3, -8.4), (-3.2, -6.4)), ((3.3, -8.4), (4.2, -6.4))):
                uzuv(a, b, 0.55, -0.4, c3(PALTO2))
                elipsoid(b[0], b[1] + 0.3, 0.55, 0.5, 0.4, -0.6, c3(TEN), seg=8, ring=5)
        _gozcu_bas(True)
    return fn


# ================================================================ hirsiz
C0, C1, C2, C3 = "#171b22", "#262d39", "#333c4b", "#454f61"


def pelerin_malz():
    return I.cel("Pelerin", [hexmul(C0, 0.8), C0, C1, C2, C3], [0, .18, .4, .7, .92], noise=0.06, noise_scale=10)


def hirsiz_govde():
    Mp = pelerin_malz()
    T.torna("pelerin", [(13.2, 0), (13.0, 8), (12.2, 18), (10.8, 24), (7.0, 28), (2.0, 29.6)], 0.5, 1.0, 1.0, 0.45, Mp, K, seg=28)
    on_levha([(0.1, -24), (0.9, -24), (0.9, 0), (0.1, 0)], -5.4, mat_duz("#12161c"))
    for sx in (-6.0, 7.0):                              # cep kapaklari
        kutu(sx - 3, sx + 3, -10.5, -7.0, -5.8, -5.0, c3(C0, f=(0.7, 0.9, 1.0, 1.4)), bevel=0.4)
    # ayaklar
    for sx in (-5.0, 6.0):
        elipsoid(sx, 0.2, 3.0, 1.4, 2.0, -3.0, c3("#0f1218", f=(0.8, 1.0, 1.0, 1.8)), seg=10, ring=6)


def hirsiz_bas():
    hy = -42.0
    Mp = pelerin_malz()
    elipsoid(0.5, hy + 1.5, 13.2, 12.6, 9.0, 1.0, Mp, seg=24, ring=16)
    # yuz boslugu
    elipsoid(0.5, hy + 2.5, 8.4, 7.4, 3.5, -6.0, mat_duz("#080a0e"), seg=20, ring=12)
    # gozler (parlayan)
    for ex in (-3.5, 5.0):
        kutu(ex - 1.8, ex + 2.0, hy + 0.2, hy + 2.0, -9.7, -9.5, mat_duz("#cfd8e2"))
        kutu(ex - 0.6, ex + 0.6, hy + 0.3, hy + 1.1, -9.8, -9.7, mat_duz("#ffffff"))
    # yaka + dugmeler
    kutu(-7.5, 9.0, hy + 9.5, hy + 15.5, -6.0, 2.0, Mp, bevel=1.2)
    for sx in (-4.5, 5.5):
        for gy in (hy + 12, hy + 14):
            elipsoid(sx, gy, 0.6, 0.6, 0.3, -6.3, mat_duz("#5a6474"), seg=6, ring=4)


def hirsiz_kol(sol):
    def fn():
        Mp = pelerin_malz()
        x = -14.0 if sol else 13.5
        uzuv((x, -22.5), (x - (0.5 if sol else -0.5), -2.5), 2.6, -1.0 if sol else -2.0, Mp)
        elipsoid(x - (0.5 if sol else -0.5), -1.5, 3.0, 3.0, 2.5, -2.5, c3("#0f1218", f=(0.8, 1.0, 1.0, 1.6)), seg=10, ring=6)
    return fn


def hirsiz_canta():
    Mc = I.cel("Canta", ["#3e3421", "#5c4d31", "#8a7448", "#a68d58", "#c2a86e"], [0, .2, .45, .75, .92], noise=0.12, noise_scale=14)
    e = I.elipsoid("canta", 0.0, 9.0, 9.2, 8.4, 7.5, 0.0, Mc, seg=22, ring=14)
    e.location = (0.0, 0.0, ez(9.5, 0.0, K))
    T.torna("boyun", [(3.6, 0), (4.4, 2.2), (4.8, 4.2)], 0.0, 3.4, -0.5, 0.8, Mc, K, seg=16)
    T.torna("bag", [(3.9, 0), (3.9, 1.4)], 0.0, 1.4, -0.5, 0.85, c3("#4e4128"), K, seg=16)
    # kabartma $ (altin iplik)
    Ma = mat_duz("#f0d78a")
    kutu(-9.0, 0.0, 2.0, 7.0, -3.0, 1.0, c3("#12161c", f=(0.7, 0.9, 1.0, 1.5)), bevel=0.8)   # kol bagi
    pts = []
    for k in range(13):
        u = k / 12
        a = math.pi * (0.9 - 2.2 * u)
        pts.append((0.3 + math.cos(a) * 2.0 * (1 if u < 0.5 else -1), 7.0 + u * 7.0))
    for a_, b_ in zip(pts, pts[1:]):
        T.on_poligon("dolar", [(a_[0] - 0.45, a_[1]), (a_[0] + 0.45, a_[1]), (b_[0] + 0.45, b_[1]), (b_[0] - 0.45, b_[1])], -8.2, Ma, K, derin=0.1)
    kutu(0.0, 0.8, 5.8, 15.2, -8.3, -8.2, Ma)


# ================================================================ rakip
def rakip():
    """Karsi dukkanin sahibi (birlesik surum, kullanici: "modellemesi yetersiz"):
    yuvarlak omuzlu ceket + V yaka, gogus hizasinda kavusturulmus kollar,
    kendi dukkaninin amblemli onlugu, kendinden emin yuz (kalkik kas, yan
    gulumseme, kalin biyik, sakal golgesi), logolu kasket. Capa: ayak noktasi,
    boy eskisiyle ayni (konusma balonu ayni yerde)."""
    Mc = I.cel("RakipCeket", ["#17242b", "#2a3d48", "#3a5664", "#5a7c8a"], [0, .3, .6, .88])
    Mk = I.cel("RakipKol", ["#1a2830", "#2f4450", "#3f5c6a", "#5f8290"], [0, .3, .6, .88])
    TEN_R = "#b98b6a"
    T.torna("govde", [(10.4, 0), (11.4, 8), (12.1, 17), (12.4, 23), (11.6, 26.6), (8.8, 29.6), (4.6, 31.2)],
            0.5, 1.0, 0.0, 0.55, Mc, K, seg=32)
    # V yaka: beyaz tisort + koyu yakalar
    on_levha([(-3.6, -31.2), (4.6, -31.2), (0.5, -23.2)], -6.6, mat_duz("#e8ecef"))
    on_levha([(-3.6, -31.2), (-1.8, -31.2), (0.5, -23.2), (-0.4, -23.8)], -6.8, mat_duz("#1b2830"))
    on_levha([(2.8, -31.2), (4.6, -31.2), (1.4, -23.8), (0.5, -23.2)], -6.8, mat_duz("#1b2830"))
    # onluk (gogsun altinda; cogu tezgahin arkasinda kalir): beyaz + kirmizi serit + doner amblemi
    Mo = I.cel("Onluk", ["#9aa3aa", "#c9d2d8", "#e4ebef", "#ffffff"], [0, .3, .62, .9])
    kutu(-8.8, 9.8, -13.2, 1.0, -7.6, -7.0, Mo, bevel=0.6)
    kutu(-8.8, 9.8, -13.2, -11.8, -7.75, -7.6, mat_duz("#c0281c"))
    em = I.elipsoid("amblem", 0.5, -7.0, 1.6, 2.6, 0.4, -7.9, c3("#a0602a"), seg=10, ring=6)
    em.location = (0.5, -7.9, ez(-7.0, -7.9, K))
    # ust kollar (omuzdan dirsege) + kavusturulmus on kollar
    uzuv((-11.4, -24.8), (-10.6, -16.8), 2.5, -4.0, Mk)
    uzuv((12.4, -24.8), (11.6, -16.8), 2.5, -4.0, Mk)
    uzuv((11.8, -17.0), (-5.5, -14.2), 2.3, -8.4, Mk)
    uzuv((-10.8, -17.4), (6.6, -14.6), 2.3, -9.3, Mk)
    for (hx, hy, y) in ((-6.8, -14.1, -8.8), (7.9, -14.5, -9.7)):
        elipsoid(hx, hy, 1.7, 1.4, 1.1, y, c3(TEN_R), seg=10, ring=6)
    # boyun + bas
    T.torna("boyun", [(3.0, 0), (2.8, 6)], 0.5, -28.5, 0.0, 0.8, c3("#a87a54"), K, seg=14)
    e = I.elipsoid("bas", 0.5, -39.5, 7.4, 8.0, 6.5, 0.0, c3(TEN_R, f=(0.7, 0.88, 1.0, 1.1)), seg=22, ring=16)
    e.location = (0.5, 0.0, ez(-39.5, 0.0, K))
    # sakal golgesi (cene)
    sg = I.elipsoid("sakal", 0.5, -35.0, 5.6, 3.0, 2.0, -5.2, c3("#8e6a4c", f=(0.8, 0.95, 1.0, 1.05)), seg=16, ring=8)
    sg.location = (0.5, -5.2, ez(-35.0, -5.2, K))
    for sx in (-7.2, 8.2):
        elipsoid(sx, -39.0, 1.3, 1.9, 1.0, 0.5, c3("#a87a54"), seg=8, ring=6)
    # kaslar: sol duz ve catik, sag kalkik (kendinden emin)
    uzuv((-5.0, -43.0), (-1.2, -42.4), 0.6, -6.8, mat_duz("#2a2018"))
    uzuv((2.2, -43.0), (6.0, -44.4), 0.6, -6.8, mat_duz("#2a2018"))
    # gozler: yari kapali (ust kapak) + bebek
    for sx, yuk in ((-3.0, 0.55), (4.0, 0.75)):
        elipsoid(sx, -40.6, 1.1, yuk, 0.3, -6.9, mat_duz("#f4ece0"), seg=10, ring=6)
        elipsoid(sx + 0.3, -40.5, 0.55, min(0.55, yuk), 0.3, -7.05, mat_duz("#1a1410"), seg=8, ring=5)
        uzuv((sx - 1.2, -41.1), (sx + 1.2, -41.1), 0.35, -7.1, mat_duz("#8e6a4c"))
    elipsoid(0.5, -38.0, 1.3, 1.7, 1.2, -7.2, c3("#a87a54"), seg=10, ring=6)
    # kalin biyik + yan gulumseme (sag kose yukarida)
    for sx in (-2.0, 3.0):
        b = I.elipsoid("biyik", sx, -35.8, 2.9, 1.2, 0.8, -7.4, c3("#2a2018", f=(0.7, 0.9, 1.0, 1.6)), seg=12, ring=6)
        b.location = (sx, -7.4, ez(-35.8, -7.4, K))
        b.rotation_euler = (0, math.radians(12 if sx < 0 else -16), 0)
    uzuv((-0.6, -33.9), (3.4, -34.6), 0.35, -7.2, mat_duz("#6a3a2a"))
    # sac + logolu mavi kasket
    I.elipsoid("sac", 0.5, -45.0, 8.0, 3.5, 6.8, 0.2, c3("#2a2018", f=(0.7, 0.9, 1.0, 1.5)), seg=18, ring=10).location = (0.5, 0.2, ez(-45.5, 0.2, K))
    T.torna("kasket", [(8.2, 0), (8.0, 2.4), (6.0, 3.8), (0.3, 4.2)], 0.5, -46.2, 0.4, 0.8, c3("#2f6a8a", f=(0.6, 0.85, 1.0, 1.25)), K, seg=26)
    I.yatay_elips("siper", 3.0, -46.2, 7.5, 0.5, c3("#1f4a62", f=(0.6, 0.85, 1.0, 1.25)), K, ry_ekran=2.0, seg=24).location.y = -4.0
    lg = I.elipsoid("logo", 0.5, -48.2, 1.8, 1.4, 0.3, -6.2, c3("#c0281c"), seg=12, ring=6)
    lg.location = (0.5, -6.2, ez(-48.2, -6.2, K))


# ================================================================ kedi
KG, KK, KA = "#4a4038", "#332c26", "#6b5c50"


def kedi_malz():
    return I.cel("Kedi", [KK, KG, KA, hexmul(KA, 1.25)], [0, .3, .62, .9], noise=0.1, noise_scale=16)


def _kedi_bas(cx, gy, cephe):
    M = kedi_malz()
    elipsoid(cx, gy, 3.3, 2.9, 2.6, -0.5, M, seg=16, ring=10)
    for sx in (-2.0, 2.0):
        bm = bmesh.new()
        y = -0.8
        p = [bm.verts.new((cx + sx - 1.2, y, ez(gy - 1.6, y, K))), bm.verts.new((cx + sx + 1.2, y, ez(gy - 1.6, y, K))),
             bm.verts.new((cx + sx * 1.1, y, ez(gy - 4.4, y, K)))]
        bm.faces.new(p)
        bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.6)
        I.mesh_ob("kulak", bm, M, smooth=False)
    ex = (-1.3, 1.4) if cephe else (0.4, 2.3)
    for x in ex:
        elipsoid(cx + x, gy + 0.2, 0.55, 0.6, 0.2, -3.1, mat_duz("#c8e070"), seg=8, ring=5)
        kutu(cx + x - 0.12, cx + x + 0.12, gy - 0.3, gy + 0.7, -3.35, -3.3, mat_duz("#1a1410"))
    nx = 0.0 if cephe else 2.8
    elipsoid(cx + nx, gy + 1.5, 0.45, 0.35, 0.2, -3.2, mat_duz("#d8a0a0"), seg=6, ring=4)


def kedi_yuru():
    M = kedi_malz()
    e = I.elipsoid("govde", -0.5, -4.3, 6.8, 2.9, 3.0, 0.0, M, seg=18, ring=10)
    e.location = (-0.5, 0.0, ez(-4.3, 0.0, K))
    _kedi_bas(6.8, -9.0, False)


def kedi_bacak(on):
    def fn():
        M = kedi_malz()
        x = 4.0 if on else -4.0
        uzuv((x, -3.0), (x, -0.4), 0.9, -1.2, M)
    return fn


def kedi_kuyruk():
    M = kedi_malz()
    pts = [(-6.5, -5.0), (-8.5, -6.5), (-9.5, -8.6), (-9.0, -10.2)]
    for a, b in zip(pts, pts[1:]):
        uzuv(a, b, 0.8, 0.8, M)


def kedi_otur():
    M = kedi_malz()
    T.torna("govde", [(3.6, 0), (4.4, 2.5), (4.0, 6.0), (2.6, 9.0), (1.5, 10.0)], 0.0, 0.0, 0.0, 0.8, M, K, seg=18)
    for sx in (-1.5, 1.5):
        elipsoid(sx, -0.6, 1.2, 0.7, 1.0, -3.0, M, seg=8, ring=5)
    on_levha([(-1.2, -8.0), (1.2, -8.0), (0.8, -2.0), (-0.8, -2.0)], -3.6, S.mat_alfa(KA, 0.6))
    _kedi_bas(0.0, -13.2, True)


def kedi_otur_kuyruk():
    M = kedi_malz()
    pts = [(3.5, -1.0), (6.0, -1.6), (8.2, -3.0), (8.8, -5.8)]
    for a, b in zip(pts, pts[1:]):
        uzuv(a, b, 0.85, 1.5, M)


def kedi_yiyor():
    M = kedi_malz()
    e = I.elipsoid("govde", -0.5, -3.3, 6.2, 2.7, 3.0, 0.0, M, seg=18, ring=10)
    e.location = (-0.5, 0.0, ez(-3.3, 0.0, K))
    _kedi_bas(6.0, -5.5, False)
    pts = [(-6.0, -4.0), (-8.0, -5.5), (-8.8, -7.2)]
    for a, b in zip(pts, pts[1:]):
        uzuv(a, b, 0.8, 0.8, M)


# ================================================================ scooter
def scooter_arac():
    for x in (-10.0, 10.0):
        L.silindir("lastik", 4.2, x, 0.0, ez(2.0, 0.0, K), 2.0, c3("#1f2329", f=(0.7, 0.9, 1.0, 1.6)), seg=22, eksen="Y")
        L.silindir("jant", 2.2, x, -1.1, ez(2.0, -1.1, K), 0.3, c3("#5c646e", f=(0.7, 0.9, 1.0, 1.3)), seg=16, eksen="Y")
    Mk = I.cel("Scooter", ["#6e140e", "#8e1c14", "#c0281c", "#e2483a", "#ff7a66"], [0, .2, .45, .75, .93])
    L.meshle(L._egri("govde", [L.yuvarlak_dikdortgen(24, 7.5, 3.0)], 0.0, ez(-1.25, 0.0, K), 0.0, 3.2, 0.6), Mk)
    kutu(8.0, 13.0, -12.0, -3.0, -1.2, 1.2, Mk, bevel=0.6)
    kutu(12.0, 14.2, -10.2, -7.2, -1.5, 0.8, mat_duz("#fff2a8"))
    kutu(7.0, 15.0, -14.2, -12.2, -1.8, 1.8, c3("#3f454e"), bevel=0.4)
    # teslimat kutusu
    Mb = I.cel("Kutu", ["#2f5a90", "#3f6ba8", "#4f81c4", "#6b9ad8"], [0, .3, .6, .88])
    kutu(-16.0, -7.0, -12.0, -4.0, -2.4, 2.4, Mb, bevel=0.6)
    kutu(-15.0, -8.0, -10.5, -9.0, -2.5, -2.4, mat_duz("#fff2a8"))


def scooter_surucu():
    Mc = I.cel("Mont", ["#b8b2a4", "#d9d3c4", "#f4efe2", "#ffffff"], [0, .3, .62, .9])
    T.torna("govde", [(4.4, 0), (4.8, 5), (4.2, 10), (2.4, 12)], -0.5, -4.0, -0.5, 0.8, Mc, K, seg=18)
    on_levha([(-5.2, -15.5), (-1.2, -15.5), (-1.2, -4.2), (-5.2, -4.2)], -4.2, c3("#c33c2c"))
    uzuv((2.5, -13.0), (9.0, -12.5), 1.1, -2.2, Mc)
    elipsoid(9.5, -12.5, 1.1, 1.0, 1.0, -2.4, c3("#f0bd8a"), seg=8, ring=5)
    uzuv((-1.0, -4.0), (5.0, -3.2), 1.4, -1.5, c3("#3a3f48"))


def scooter_bas():
    hy = -20.5
    elipsoid(0.0, hy, 4.8, 4.8, 4.2, 0.0, c3("#f0bd8a", f=(0.7, 0.88, 1.0, 1.1)), seg=16, ring=12)
    I.elipsoid("kask", -0.3, hy - 2.0, 5.4, 4.2, 5.0, 0.2, I.cel("Kask", ["#6d1a12", "#96271c", "#c33c2c", "#e05a48"], [0, .3, .6, .88]), seg=18, ring=12).location = (-0.3, 0.2, ez(hy - 2.0, 0.2, K))
    kutu(-3.0, 4.2, hy + 1.2, hy + 3.0, -5.2, -4.4, mat_duz("#f4f4f0"), bevel=0.3)
    elipsoid(2.2, hy + 0.2, 0.6, 0.6, 0.3, -4.6, mat_duz("#1a1410"), seg=6, ring=4)


def pano():
    kutu(0, 12, 0, 15, -0.6, 0.6, c3("#8a6a3a", f=(0.62, 0.84, 1.0, 1.15)), bevel=0.4)
    kutu(1, 11, 1, 14, -0.8, -0.6, c3("#e8e2d0", f=(0.8, 0.94, 1.0, 1.04)))
    for i in range(4):
        kutu(2, 10, 4 + i * 3, 4.6 + i * 3, -0.85, -0.8, mat_duz("#b9b2a0"))
    kutu(3, 9, -2, 1.2, -1.2, 0.2, c3("#9aa3ab", f=(0.6, 0.85, 1.0, 1.25)), bevel=0.4)


# ================================================================ kayit
for _ph in range(8):
    parca("asker_bacak_%d" % _ph, (-4, -6, 10, 7), asker_bacak(_ph), cizgi_alfa=90)
parca("asker_govde", (-5, -15, 11, 12), asker_govde, cizgi_alfa=100)
for _k in range(3):
    parca("asker_kol_%d" % _k, (1, -10, 5, 8), asker_kol(_k - 1), cizgi_alfa=90)
for _ph in range(8):
    parca("gozcu_bacak_%d" % _ph, (-4, -6, 10, 7), gozcu_bacak(_ph), cizgi_alfa=90)
parca("gozcu_cephe_bacak", (-4, -6, 9, 7), gozcu_cephe_bacak, cizgi_alfa=90)
parca("gozcu_yan", (-4, -16, 10, 13), gozcu_yan, cizgi_alfa=100)
parca("gozcu_cephe_bak", (-6, -16, 13, 13), gozcu_cephe(False), cizgi_alfa=100)
parca("gozcu_cephe_sor", (-5, -16, 14, 13), gozcu_cephe(True), cizgi_alfa=100)
parca("hirsiz_govde", (-16, -31, 34, 34), hirsiz_govde)
parca("hirsiz_bas", (-16, -58, 34, 32), hirsiz_bas)
parca("hirsiz_kol_sol", (-19, -27, 10, 30), hirsiz_kol(True))
parca("hirsiz_kol_sag", (9, -27, 10, 30), hirsiz_kol(False))
parca("hirsiz_canta", (-12, -3, 24, 22), hirsiz_canta)
parca("rakip", (-18, -54, 37, 57), rakip)
parca("kedi_yuru", (-9, -15, 20, 14), kedi_yuru)
parca("kedi_bacak_on", (2, -5, 5, 6), kedi_bacak(True), cizgi_alfa=90)
parca("kedi_bacak_arka", (-6, -5, 5, 6), kedi_bacak(False), cizgi_alfa=90)
parca("kedi_kuyruk", (-12, -13, 8, 10), kedi_kuyruk)
parca("kedi_otur", (-6, -20, 12, 22), kedi_otur)
parca("kedi_otur_kuyruk", (2, -8, 9, 9), kedi_otur_kuyruk)
parca("kedi_yiyor", (-11, -12, 22, 13), kedi_yiyor)
for _sc, _ek in ((1.0, ""), (0.6, "_60")):
    parca("scooter_arac" + _ek, (-19, -17, 36, 25), scooter_arac, olcek=_sc)
    parca("scooter_surucu" + _ek, (-8, -18, 20, 17), scooter_surucu, olcek=_sc)
    parca("scooter_bas" + _ek, (-7, -28, 14, 14), scooter_bas, olcek=_sc)
parca("pano", (-1, -3, 14, 19), pano)


# ================================================================ lider ve korumalari
LID_TAKIM, LID_TEN, LID_ALTIN, LID_KIRMIZI = "#22252b", "#d6ab7c", "#c9a23a", "#8e1c14"


def lider():
    """game.js drawLider: koyu takimli, kasketli lider (capa ayak noktasi).
    Eski cizimle ayni boy: govde 24, bas 9, kasket 5 -> toplam 38 px."""
    Mt = I.cel("LidTakim", ["#101216", "#1b1e24", LID_TAKIM, "#333740"], [0, .3, .62, .92])
    Ma = mat_duz(LID_ALTIN)
    Mk = mat_duz(LID_KIRMIZI)
    for sx in (-2.2, 2.2):                                   # bacaklar
        T.torna("bacak", [(1.8, 0), (1.9, 4), (2.0, 8)], sx, 0.0, 0.0, 0.7, Mt, K, seg=12)
    T.torna("palto", [(4.7, 0), (5.0, 5), (4.9, 11), (4.1, 15), (2.9, 17)], 0.0, -8.0, 0.0, 0.62, Mt, K, seg=24)
    kutu(-4.9, 4.9, -17.6, -15.8, -3.3, 3.3, mat_duz("#0e1013"), bevel=0.35)   # kemer
    kutu(-1.3, 1.3, -17.8, -15.6, -3.7, -2.6, Ma, bevel=0.25)                  # toka
    uzuv((-4.2, -24.0), (3.4, -18.2), 0.85, -3.5, Mk)                          # capraz kusak
    for sx in (-4.1, 4.1):                                                     # apoletler
        kutu(sx - 1.3, sx + 1.3, -25.2, -24.2, -3.2, 2.0, Ma, bevel=0.25)
    for i, (mx, mg) in enumerate(((-3.3, -22.4), (-3.3, -20.4), (-1.2, -21.4))):
        elipsoid(mx, mg, 0.8, 0.8, 0.4, -3.5, Ma if i != 2 else Mk, seg=8, ring=5)
    for sx in (-5.4, 5.4):                                                     # kollar
        uzuv((sx, -24.0), (sx + (-0.5 if sx < 0 else 0.5), -17.6), 1.35, -2.5, Mt)
        elipsoid(sx + (-0.7 if sx < 0 else 0.7), -16.9, 1.15, 1.15, 0.9, -2.8, c3(LID_TEN))
    T.torna("boyun", [(1.7, 0), (1.6, 3)], 0.0, -26.4, 0.0, 0.8, c3("#b8905f"), K, seg=10)
    e = I.elipsoid("bas", 0.0, -29.6, 3.5, 3.9, 3.1, 0.0, c3(LID_TEN, f=(0.72, 0.9, 1.0, 1.12)), seg=16, ring=11)
    e.location = (0.0, 0.0, ez(-29.6, 0.0, K))
    for sx in (-1.4, 1.4):                                                     # gozler
        elipsoid(sx, -30.2, 0.6, 0.6, 0.35, -3.2, mat_duz("#14161a"), seg=8, ring=5)
    elipsoid(0.0, -27.6, 1.5, 0.5, 0.4, -3.0, mat_duz("#8a5a4a"), seg=10, ring=5)
    elipsoid(0.0, -28.5, 2.0, 0.7, 0.55, -3.2, c3("#3a2e24", f=(0.7, 0.9, 1.0, 1.4)), seg=12, ring=6)
    T.torna("kasket", [(4.0, 0), (3.9, 2.0), (2.8, 3.2), (0.3, 3.5)], 0.0, -33.2, 0.0, 0.8,
            c3("#171a1f", f=(0.6, 0.85, 1.0, 1.35)), K, seg=20)
    T.torna("bant", [(4.1, 0), (4.1, 1.3)], 0.0, -33.4, 0.0, 0.82, Mk, K, seg=20, kapak=False)
    I.yatay_elips("siper", 0.0, -33.4, 5.0, 0.5, c3("#0b0d10", f=(0.6, 0.85, 1.0, 1.4)), K, ry_ekran=1.5, seg=20).location.y = -2.6
    elipsoid(0.0, -34.9, 0.8, 0.8, 0.4, -3.6, Ma, seg=8, ring=5)


def lider_koruma():
    """Liderin iki yanindaki koruma (tufekli, kaskli); kod x eksenine aynalar."""
    Mu = I.cel("KorUni", ["#171a17", "#252a24", "#3a413a", "#4c544c"], [0, .3, .62, .9])
    Mk = I.cel("KorKask", ["#161a16", "#242a24", "#39403a", "#525a52"], [0, .3, .62, .9])
    for sx in (-2.0, 2.0):
        T.torna("bacak", [(1.7, 0), (1.8, 4), (1.9, 9)], sx, 0.0, 0.0, 0.7, Mu, K, seg=12)
    T.torna("govde", [(4.4, 0), (4.6, 5), (4.4, 11.5)], 0.0, -9.0, 0.0, 0.62, Mu, K, seg=20)
    kutu(-4.6, 4.6, -15.4, -13.8, -3.2, 3.2, mat_duz("#20241f"), bevel=0.3)
    for sx in (-5.0, 5.0):                                   # kollar
        uzuv((sx, -19.6), (sx + (-0.4 if sx < 0 else 0.4), -13.0), 1.3, -2.6, Mu)
    T.torna("boyun", [(1.7, 0), (1.6, 3)], 0.0, -21.0, 0.0, 0.8, c3("#b8905f"), K, seg=10)
    e = I.elipsoid("bas", 0.0, -24.6, 3.4, 3.8, 3.0, 0.0, c3(TEN, f=(0.72, 0.9, 1.0, 1.1)), seg=16, ring=10)
    e.location = (0.0, 0.0, ez(-24.6, 0.0, K))
    for sx in (-1.3, 1.3):
        elipsoid(sx, -25.2, 0.55, 0.55, 0.35, -2.9, mat_duz("#14161a"), seg=8, ring=5)
    # kask (celik siperlik)
    T.torna("kask", [(4.0, 0), (3.9, 1.8), (2.6, 3.0), (0.3, 3.3)], 0.0, -28.0, 0.0, 0.82, Mk, K, seg=18)
    I.yatay_elips("kaskkenar", 0.0, -28.0, 4.6, 0.6, c3("#20241f", f=(0.6, 0.85, 1.0, 1.3)), K, ry_ekran=1.6, seg=20).location.y = -2.6
    # tufek: omuzda dikey duruyor
    uzuv((5.9, -27.2), (5.9, -16.2), 0.75, -3.6, c3("#2a2620", f=(0.6, 0.86, 1.0, 1.3)))
    kutu(5.0, 6.9, -18.0, -14.6, -4.2, -3.0, c3("#4a3a28", f=(0.6, 0.85, 1.0, 1.25)), bevel=0.35)


parca("lider", (-10, -40, 20, 43), lider)
parca("lider_koruma", (-8, -33, 16, 36), lider_koruma)


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, olcek = PARCALAR[ad]
    D.sahne(gx0, gy0, w, h, olcek)
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
                   "olcekler": OLCEK}, fp, indent=1)
    print("OLAY_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
