"""SOKAK AKTORLERI — remake HD: yayalar (yurume dongusu) ve araclar.

    blender --background --factory-startup --python blender/models/sokak_hd.py [-- onek ...]
    python blender/hd_atlas.py sokak_hd sokak

art.js drawPed: 8 karelik yurume tablosu FR = [on ayak x, arka ayak x, on bacak
boyu, arka bacak boyu, govde y, kol salinimi]; kimlik (gomlek/pantolon/ten/sac
rengi, boy, genislik, sac, sapka, ceket, esya) pedKimlik'ten. Burada parca
RENKSIZ (ton kodlu, shaders/ton.gdshader CARPAN): her kare icin bolge gecisleri
  yaya_<ph>_<g>_<bolge>   ph 0..7, g = govde genisligi 4|5, bolge pant/gomlek/ten/sabit
                          capa (x, yy) ; saga bakar, sola yururken capa ekseninde ayna
  yaya_bas_ten / yaya_goz (sabit) / yaya_sac_<0..3> / yaya_sapka   capa (x, yy)
  yaya_ceket_<g>          ceket kenarlari + dugme (gomlek CARPAN), capa (x, yy)
Esya ve semsiye kodda.

art.js drawVehicle: tip 0 araba, 1 taksi, 2 minibus, 3 kucuk araba, 4 uzun otobus,
5 iki katli otobus; serit olcegi sc 1 / .86; renk CAR_PAL (b d l).
  arac_<tip>_<sc>_govde   PALET (sutunlar 3: l b d)   capa (x + round(L/2), y)
  arac_<tip>_<sc>_sabit   camlar, farlar, tampon, taksi lambasi (NORMAL)
  teker_<f>               f 0..7 donme karesi (NORMAL), capa teker merkezi
Fren lambasi (duruyor), golge, teker kemeri golgesi kodda.
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
import kalip_hd as KH

OUT = os.path.join(_HERE, "out", "sokak_hd")
HD = 2
K = 0.2
ez, onkutu, torna = T.ez, T.onkutu, T.torna
gri = M.gri
Z = KH.Z
GECIS = KH.GECIS
PARCALAR, KOKEN = {}, {}

FR = [[3, -3, 4, 4, 0, 2], [2, -2, 4, 4, -1, 1], [0, 0, 5, 4, -1, 0], [-2, 2, 4, 4, -1, -1],
      [-3, 3, 4, 4, 0, -2], [-2, 2, 4, 4, -1, -1], [0, 0, 4, 5, -1, 0], [2, -2, 4, 4, -1, 1]]


def carp(ad, f):
    return px.flat(ad, gri(f))


def uzuv(ad, a, b, r, y, mat, seg=10):
    """Ekranda a=(x,gy) -> b=(x,gy) arasi kapsul uzuv (derinlik y)."""
    ax, ag = a
    bx, bg = b
    uz = math.hypot(bx - ax, bg - ag)
    ob = L.silindir(ad, r, (ax + bx) / 2.0, y, ez((ag + bg) / 2.0, y, K), max(0.01, uz), mat, seg=seg, eksen="Z")
    ob.rotation_euler = (0, math.atan2(bx - ax, -(bg - ag)), 0)
    for (px_, pg) in (a, b):
        e = I.elipsoid(ad + "_uc", px_, pg, r, r, r, y, mat, seg=8, ring=5)
        e.location = (px_, y, ez(pg, y, K))
    return ob


# ---------------------------------------------------------------- yaya
def yaya(ph, g):
    def fn():
        fx0, bx0, fl, bl, by, arm = FR[ph]
        # capa (x, yy); x kolonunun merkezi +.5
        cx = 0.5
        kalca = (cx, -4.0)
        # arka bacak (koyu), on bacak
        uzuv("arka_bacak", kalca, (cx + bx0 * 0.9, -4.0 + bl - 0.8), 0.95, 1.2, Z("pant", lambda: carp("ArkaBacak", .74)))
        uzuv("on_bacak", kalca, (cx + fx0 * 0.9, -4.0 + fl - 0.8), 0.95, -0.4, Z("pant", lambda: carp("OnBacak", 1.0)))
        for ad, ax, ab, yy in (("arka_ayak", bx0, bl, 1.3), ("on_ayak", fx0, fl, -0.6)):
            e = I.elipsoid(ad, cx + ax * 0.9 + 0.6, -4.0 + ab - 0.4, 1.3, 0.7, 0.9, yy, Z("sabit", lambda: px.flat("Ayak", "#241c16")), seg=8, ring=5)
            e.location = (cx + ax * 0.9 + 0.6, yy, ez(-4.0 + ab - 0.4, yy, K))
        # govde: gx0 = x - floor(g/2), yy-8 .. yy-3
        gx0 = -math.floor(g / 2.0)
        w = g + 1.0
        torna("govde", [(w / 2.0 - 0.3, 0), (w / 2.0, 2.5), (w / 2.0 - 0.2, 4.5), (w / 2.0 - 1.0, 5.2)], gx0 + w / 2.0, -3.0, 0.3, 0.75,
              Z("gomlek", lambda: px.cel("Govde", [gri(.76), gri(1.0), gri(1.4)], [0, .42, .85])), K, seg=16)
        # kollar
        omuz_s = (gx0 - 0.3, -6.8)
        omuz_g = (gx0 + g + 0.5, -6.8)
        uzuv("kol_arka", omuz_s, (gx0 - 0.6 - arm * 0.35, -3.5 - arm * 0.6), 0.6, 1.5, Z("gomlek", lambda: carp("KolA", .78)))
        uzuv("kol_on", omuz_g, (gx0 + g + 0.6 + arm * 0.35, -3.5 + arm * 0.6), 0.6, -1.4, Z("gomlek", lambda: carp("KolO", .94)))
        for ad, hx, hg, yy in (("el_a", gx0 - 0.6 - arm * 0.35, -3.0 - arm * 0.6, 1.5), ("el_o", gx0 + g + 0.6 + arm * 0.35, -3.0 + arm * 0.6, -1.4)):
            e = I.elipsoid(ad, hx, hg, 0.7, 0.7, 0.6, yy - 0.2, Z("ten", lambda: carp("El", 1.0)), seg=8, ring=5)
            e.location = (hx, yy - 0.2, ez(hg, yy - 0.2, K))
    return fn


def yaya_bas(bolge):
    def fn():
        GECIS[0] = bolge
        hy = -11.0
        e = I.elipsoid("bas", 0.5, hy + 1.5, 2.3, 1.9, 1.9, 0.0, Z("ten", lambda: px.cel("Bas", [gri(.8), gri(1.0), gri(1.12)], [0, .45, .85])), seg=14, ring=10)
        e.location = (0.5, 0.0, ez(hy + 1.5, 0.0, K))
        for ex in (0.5, 2.5):
            g = I.elipsoid("goz", ex, hy + 1.5, 0.45, 0.5, 0.2, -1.9, Z("sabit", lambda: px.flat("Goz", "#2b2018")), seg=6, ring=4)
            g.location = (ex, -1.9, ez(hy + 1.5, -1.9, K))
    return fn


def yaya_sac(stil):
    def fn():
        GECIS[0] = "sac"
        hy = -11.0
        Ms = lambda: px.cel("Sac", [gri(.8), gri(1.0), gri(1.2)], [0, .45, .85])
        if stil != 3:
            M.kubbe("tepe", 0.5, hy + 0.6, 2.6, 2.4, Z("sac", Ms), y=0.3)
        else:
            for sx in (-2.0, 2.0):
                e = I.elipsoid("yan", 0.5 + sx, hy + 0.6, 0.8, 0.9, 1.0, 0.4, Z("sac", Ms), seg=8, ring=5)
                e.location = (0.5 + sx, 0.4, ez(hy + 0.6, 0.4, K))
        if stil == 1:
            for sx in (-2.0, 2.0):
                uzuv("uzun", (0.5 + sx, hy), (0.5 + sx, hy + 3.5), 0.7, 0.5, Z("sac", Ms))
        if stil == 2:
            e = I.elipsoid("atkuyrugu", -2.4, hy - 0.2, 1.0, 1.1, 0.9, 1.2, Z("sac", Ms), seg=8, ring=5)
            e.location = (-2.4, 1.2, ez(hy - 0.2, 1.2, K))
    return fn


def yaya_sapka():
    GECIS[0] = "gomlek"
    hy = -11.0
    M.kubbe("sapka", 0.5, hy - 0.2, 2.7, 2.2, px.cel("Sapka", [gri(.45), gri(.55), gri(.65)], [0, .45, .85]), y=0.2)
    L.silindir("siper", 0.5, 2.6, -0.5, ez(hy - 0.4, -0.5, K), 3.0, carp("Siper", .45), seg=8, eksen="X")


def yaya_ceket(g):
    def fn():
        GECIS[0] = "gomlek"
        gx0 = -math.floor(g / 2.0)
        for x0 in (gx0, gx0 + g - 1):
            onkutu("kenar", x0 + 0.1, x0 + 0.8, -8, -3, -1.5, -1.2, carp("Kenar", .6), K)
        onkutu("dugme", 0.2, 0.8, -7, -6.4, -1.6, -1.3, carp("Dugme", 1.6), K)
    return fn


# ---------------------------------------------------------------- araclar
def s_(k, sc):
    return math.floor(k * sc + 0.5)


def vehlen(tip, sc):
    b = 44 if tip == 2 else (32 if tip == 3 else (50 if tip == 4 else (46 if tip == 5 else 38)))
    return math.floor(b * sc + 0.5)


def arac(tip, sc):
    def fn():
        Lg = vehlen(tip, sc)
        # capa x = sol uc + round(L/2): geometri sol uca gore kurulup kaydirilir
        ox = -math.floor(Lg / 2.0 + 0.5)
        wr = max(2, s_(3, sc))
        bodyH = s_(7, sc)
        roofH = s_(10 if tip == 2 else 6, sc)
        by = -wr - bodyH
        ry = by - roofH
        D = 10.0
        Mg = lambda ad, f=None: Z("govde", lambda: px.cel("Govde" + ad, ["#000000", "#808080", "#ffffff"], [0, .3, .85]))
        Mcam = lambda ad, c: Z("sabit", lambda: px.cel("Cam" + ad, [T.hexmul(c, .7), c, T.hexmul(c, 1.15)], [0, .35, .8]))
        Mcer = lambda ad, c: Z("sabit", lambda: px.flat("Cer" + ad, c))

        def kutu(ad, x0, x1, g0, g1, y0, y1, mat):
            return onkutu(ad, ox + x0, ox + x1, g0, g1, y0, y1, mat, K)

        def govde_kutu(ad, x0, x1, g0, g1, y0=0.0, y1=D, bevel=0.8):
            yc = (y0 + y1) / 2.0
            L.levha(ad, x1 - x0, g1 - g0, bevel, ox + (x0 + x1) / 2.0, ez((g0 + g1) / 2.0, yc, K), yc, y1 - y0, 0.4, Mg(ad))

        if tip == 4:
            jr = s_(9, sc)
            jy = by - jr
            govde_kutu("alt", 0, Lg, by, by + bodyH)
            govde_kutu("ust", s_(3, sc), Lg - s_(6, sc), jy, by + 1, 0.5, D - 0.5)
            for jw in range(5):
                wx = s_(6 + jw * 8, sc)
                kutu("cam", wx, wx + s_(6, sc), jy + s_(2, sc), jy + s_(2, sc) + s_(5, sc), -0.9, -0.5, Mcer("TramCam", "#20282e"))
                kutu("cam_i", wx + 0.3, wx + s_(6, sc) - 0.3, jy + s_(2, sc) + 0.3, jy + s_(2, sc) + 1.2, -1.0, -0.9, Mcer("TramCamI", "#3a4a58"))
            kutu("serit", 1, Lg - 2, by + s_(3, sc), by + s_(3, sc) + max(1, s_(2, sc)), -0.8, -0.5, Mg("Serit"))
            kutu("on_cam", Lg - s_(6, sc), Lg, by, by + bodyH - 1, -0.9, -0.5, Mcam("TramOn", "#d8dee4"))
        elif tip == 5:
            dh = s_(15, sc)
            dy = by - dh
            govde_kutu("govde", 0, Lg, dy, by + bodyH)
            for dk in range(2):
                for dw in range(4):
                    wx = s_(4 + dw * 10, sc)
                    wy = dy + s_(2 + dk * 8, sc)
                    kutu("cer", wx, wx + s_(8, sc), wy, wy + s_(5, sc), -0.9, -0.5, Mcer("OtoCer", "#2c3b45"))
                    kutu("cam", wx + 0.3, wx + s_(8, sc) - 0.3, wy + 0.3, wy + s_(4, sc), -1.0, -0.9, Mcam("Oto", "#a9cbdc"))
            kutu("serit", 1, Lg - 2, dy + s_(7, sc), dy + s_(7, sc) + max(1, s_(1, sc)), -0.8, -0.5, Z("govde", lambda: px.flat("OtoSerit", "#000000")))
        elif tip == 2:
            govde_kutu("govde", 0, Lg, ry, by + bodyH, bevel=1.4)
            kutu("serit", 1, Lg - 2, by - s_(2, sc), by, -0.8, -0.5, Mcer("MiniSerit", "#2f6a8a"))
            for wi in range(3):
                wx = s_(5 + wi * 11, sc)
                kutu("cer", wx, wx + s_(9, sc), ry + s_(2, sc), ry + s_(2, sc) + s_(5, sc), -0.9, -0.5, Mcer("MiniCer", "#2c3b45"))
                kutu("cam", wx + 0.3, wx + s_(9, sc) - 0.3, ry + s_(2, sc) + 0.3, ry + s_(2, sc) + s_(4, sc), -1.0, -0.9, Mcam("Mini", "#a9cbdc"))
            kutu("on_cer", Lg - s_(8, sc), Lg - s_(2, sc), ry + s_(2, sc), ry + s_(2, sc) + s_(5, sc), -0.9, -0.5, Mcer("MiniOnCer", "#2c3b45"))
            kutu("on_cam", Lg - s_(8, sc) + 0.3, Lg - s_(2, sc) - 0.3, ry + s_(2, sc) + 0.3, ry + s_(2, sc) + s_(4, sc), -1.0, -0.9, Mcam("MiniOn", "#bcd8e6"))
        else:
            cabX = s_(8 if tip == 3 else 10, sc)
            cabW = s_(16 if tip == 3 else 18, sc)
            # kabin: egimli on/arka cam (yamuk)
            bm = bmesh.new()
            egim = max(1.5, roofH * 0.45)
            pts = [(cabX - egim * 0.6, by + 0.5), (cabX + cabW + egim * 0.8, by + 0.5), (cabX + cabW - 0.3, ry), (cabX + 0.6, ry)]
            T.on_poligon("kabin", [(ox + x, g) for x, g in pts], 1.0, Mg("Kabin"), K, derin=D - 2.0)
            gw2 = math.floor(cabW / 2.0 + 0.5) - 1
            ghh = max(2, roofH - 2)
            for i2, renk in ((0, "#9cc2d6"), (1, "#b6d4e4")):
                x0 = cabX + 1 + i2 * gw2
                kutu("cer%d" % i2, x0, x0 + gw2 - 1, ry + 1, ry + 1 + ghh, 0.6, 0.9, Mcer("KabinCer", "#22303a"))
                kutu("cam%d" % i2, x0 + 0.3, x0 + gw2 - 1.3, ry + 1.3, ry + ghh, 0.5, 0.6, Mcam("Kabin%d" % i2, renk))
            govde_kutu("govde", 0, Lg, by, by + bodyH, bevel=1.2)
            kutu("kapi", cabX + gw2 - 0.2, cabX + gw2 + 0.3, by + 1, by + bodyH - 1, -0.45, -0.3, Z("govde", lambda: px.flat("Kapi", "#000000")))
            kutu("kol", cabX + 2, cabX + 2 + s_(3, sc), by + s_(2, sc), by + s_(2, sc) + 0.8, -0.5, -0.35, Z("govde", lambda: px.flat("KapiKolu", "#ffffff")))
            kutu("tampon", 0, Lg - 1, by + bodyH - s_(2, sc), by + bodyH - s_(2, sc) + max(1, s_(1, sc)), -0.6, 0.3, Mcer("Tampon", "#8f979f"))
            if tip == 1:
                kutu("lamba", s_(15, sc), s_(15, sc) + s_(9, sc), ry - s_(3, sc), ry, 3.0, 6.0, Mcer("LambaCer", "#2b2018"))
                kutu("lamba_i", s_(15, sc) + 0.3, s_(15, sc) + s_(8, sc), ry - s_(3, sc) + 0.3, ry - 1, 2.8, 3.0, Mcer("LambaI", "#ffe9a0"))
        # far
        kutu("far", Lg - s_(2, sc), Lg + 0.3, by + s_(2, sc), by + s_(2, sc) + s_(2, sc), -1.2, 0.3, Mcer("Far", "#fff2b8"))
    return fn


def teker(f):
    def fn():
        GECIS[0] = "sabit"
        r = 3
        L.silindir("lastik", r + 0.4, 0.5, 0.0, ez(0.5, 0.0, K), 2.0, px.cel("Lastik", ["#101216", "#1c1f24", "#2b3037"], [0, .45, .85]), seg=20, eksen="Y")
        L.silindir("jant", r - 1.0, 0.5, -1.1, ez(0.5, -1.1, K), 0.3, px.cel("Jant", ["#7a838b", "#9aa3ab", "#c3cbd2"], [0, .45, .85]), seg=16, eksen="Y")
        a = f / 8.0 * math.pi * 2
        for k in range(2):
            aa = a + k * math.pi
            ex, eg = 0.5 + math.cos(aa) * (r - 2.0), 0.5 + math.sin(aa) * (r - 2.0)
            T.onkutu("bijon", ex - 0.4, ex + 0.4, eg - 0.4, eg + 0.4, -1.5, -1.3, px.flat("Bijon", "#5a636b"), K)
    return fn


BOLGE_YAYA = ["pant", "gomlek", "ten", "sabit"]
for _ph in range(8):
    for _g in (4, 5):
        for _b in BOLGE_YAYA:
            ad = "yaya_%d_%d_%s" % (_ph, _g, _b)
            PARCALAR[ad] = ((-6, -12, 13, 16), yaya(_ph, _g), _b)
            KOKEN[ad] = (-6, -12)
for _b in ("ten", "sabit"):
    PARCALAR["yaya_bas_" + _b] = ((-4, -15, 9, 8), yaya_bas(_b), None)
    KOKEN["yaya_bas_" + _b] = (-4, -15)
for _s in range(4):
    PARCALAR["yaya_sac_%d" % _s] = ((-5, -15, 11, 10), yaya_sac(_s), None)
    KOKEN["yaya_sac_%d" % _s] = (-5, -15)
PARCALAR["yaya_sapka"] = ((-5, -15, 11, 7), lambda: yaya_sapka(), None)
KOKEN["yaya_sapka"] = (-5, -15)
for _g in (4, 5):
    PARCALAR["yaya_ceket_%d" % _g] = ((-4, -9, 9, 7), yaya_ceket(_g), None)
    KOKEN["yaya_ceket_%d" % _g] = (-4, -9)
for _tip in range(6):
    for _sc in (1.0, 0.86):
        Lg = vehlen(_tip, _sc)
        for _b in ("govde", "sabit"):
            ad = "arac_%d_%d_%s" % (_tip, int(round(_sc * 100)), _b)
            PARCALAR[ad] = ((-Lg // 2 - 4, -34, Lg + 8, 36), arac(_tip, _sc), _b)
            KOKEN[ad] = (-Lg // 2 - 4, -34)
for _f in range(8):
    PARCALAR["teker_%d" % _f] = ((-4, -4, 9, 9), teker(_f), None)
    KOKEN["teker_%d" % _f] = (-4, -4)


def uret(ad):
    (gx0, gy0, w, h), fn, bolge = PARCALAR[ad]
    M.sahne(gx0, gy0, w, h)
    GECIS[0] = bolge
    fn()
    px.shear_scene(K)
    yol = px.render(os.path.join(OUT, ad + ".png"))
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
    print("SOKAK_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
