"""KUCUK ISTASYONLAR — remake HD parcalari.

    blender --background --factory-startup --python blender/models/istasyon_hd.py [-- parca ...]
    python blender/hd_atlas.py istasyon_hd istasyon

Oyundaki karsiliklari (art.js):
  drawBreadStack  -> lavas_yigin     capa: ST.bread sol-ust (w=42)
  drawPideStack   -> pide_yigin      capa: ST.bread sol-ust
  potBinPaint     -> patates_dolap   capa: ST.potato sol-ust (44x38)
  drawSweetTray   -> tatli_arka / tatli_on, baklava (capa: parca merkezi cx,cy)
  drawTrash       -> cop_govde (capa: ST.trash sol-ust 30x28), cop_kapak
  drawCrate       -> stok_oyuk (capa: ST.crate sol-ust 34x34), stok_cekmece,
                     stok_ic (capa: cekmecenin sol-ustu dx,dy)
  drawWallCam     -> kamera (capa: art.js cx0,cy0 = 424,30)
Etiket yazilari (LAVAS, TATLI, STOK, COP), yanip sonen isiklar, sallanan
kapak ve cop yigini oyunda kodla kaliyor (durum oradan geliyor).

Bakis: yatay yuzeyler oblik acilimla (K), dikey on yuzler 1:1.
"""
import sys, os, math, json
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import palette as pal
import logo as L

OUT = os.path.join(_HERE, "out", "istasyon_hd")
P = pal.P
HD = 2
KOKEN = {}
PARCALAR = {}


def sahne(gx0, gy0, w, h):
    L._FONTLAR.clear()
    px.reset()
    px.setup(int(w * HD), int(h * HD))
    px.ortho_cam(gx0 + w / 2.0, -(gy0 + h / 2.0), w, h)
    px.world("#000000", 0.0)
    d = Vector((0.40, 0.60, -0.70)).normalized()
    s = px.sun(math.pi, rot=(0, 0, 0))
    s.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def cel(ad, ramp, stops=None, noise=0.0, noise_scale=8.0):
    return px.cel(ad, ramp, stops, noise=noise, noise_scale=noise_scale)


def link(ob):
    bpy.context.collection.objects.link(ob)
    return ob


def mesh_ob(ad, bm, mat, smooth=True):
    me = bpy.data.meshes.new(ad)
    bm.to_mesh(me)
    bm.free()
    if smooth:
        for p in me.polygons:
            p.use_smooth = True
    ob = link(bpy.data.objects.new(ad, me))
    me.materials.append(mat)
    return ob


def yatay_elips(ad, gx, gy, rx, kalin, mat, K, ry_ekran=None, seg=40, egim=0.0):
    """Ekranda (gx, gy) merkezli yatay disk: ust yuzu ekranda ry_ekran
    yuksekliginde elips gorunur (derinlik yaricapi = ry_ekran / K)."""
    ry = (ry_ekran if ry_ekran is not None else rx * K) / K
    bm = bmesh.new()
    alt, ust = [], []
    for i in range(seg):
        a = 2 * math.pi * i / seg
        x, y = math.cos(a) * rx, math.sin(a) * ry
        alt.append(bm.verts.new((x, y, 0)))
        ust.append(bm.verts.new((x * (1 - egim), y * (1 - egim), kalin)))
    for i in range(seg):
        bm.faces.new((alt[i], alt[(i + 1) % seg], ust[(i + 1) % seg], ust[i]))
    bm.faces.new(list(reversed(alt)))
    bm.faces.new(ust)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = mesh_ob(ad, bm, mat)
    # merkezi ekranda (gx, gy): oblik acilim sonra z += y*K; y merkezi 0
    ob.location = (gx, 0, -gy - kalin / 2.0)
    return ob


def elipsoid(ad, gx, gy, rx, rz, ry, derin, mat, seg=16, ring=10):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, radius=1.0)
    ob = mesh_ob(ad, bm, mat)
    ob.scale = (rx, ry, rz)
    ob.location = (gx, derin, -gy)
    return ob


def parca(ad, tuval, fn, K=0.4, cizgi=None, cizgi_alfa=170):
    PARCALAR[ad] = (tuval, fn, K, cizgi, cizgi_alfa)
    KOKEN[ad] = (tuval[0], tuval[1])


# ---------------------------------------------------------------- lavas / pide
def lavas_yigin():
    K = 0.39
    Mt = cel("Tabak", ["#9aa2aa", "#c9cfd6", "#e8edf2", "#f6f9fb"])
    yatay_elips("tabak", 21, 21, 18, 1.2, Mt, K, ry_ekran=7, egim=0.08)
    Ml = cel("Lavas", ["#b8925a", "#d8b581", "#f0d5a8", "#f8e6c4"], noise=0.10, noise_scale=14)
    for i in range(4):
        yatay_elips("lavas%d" % i, 21, 18 - i * 3, 14 - i, 1.4, Ml, K, ry_ekran=4, egim=0.04)
    # ustteki lavasta pisme benekleri
    Mb = px.flat("Benek", "#c39a63")
    for s in range(7):
        a = s * 2.1
        elipsoid("benek", 21 + math.cos(a) * (3 + s * 1.2), 9 + math.sin(a) * 1.4, 0.9, 0.5, 0.5, -1.0, Mb, seg=8, ring=4)


def pide_yigin():
    K = 0.39
    Mp = cel("Pide", ["#7a4e20", "#a06a2e", "#d9a765", "#eec78c"], noise=0.12, noise_scale=12)
    for i in range(3):
        yatay_elips("pide%d" % i, 21, 9 - i * 3, 13 - i, 2.2, Mp, K, ry_ekran=4, egim=0.18)
    Mb = px.flat("Susam", "#8a5f31")
    for s in range(6):
        elipsoid("benek", 14 + s * 3, 1.5 + (s % 2) * 0.8, 0.7, 0.4, 0.4, -1.2, Mb, seg=8, ring=4)


# ---------------------------------------------------------------- patates dolabi
def patates_dolap(w=44, h=38):
    Mah = cel("DolapAhsap", ["#2e2010", "#4e3a18", "#6d5228", "#8a6a3a"])
    Mic = px.flat("DolapIc", "#3a2a12")
    # dolap: arkadaki koyu oyuk + cerceve
    L.kutu("oyuk", 0, w, -h, 0, 4, 6, Mic)
    for ad, x0, x1, z0, z1 in (("ust", 0, w, -2, 0), ("alt", 0, w, -h, -h + 2),
                               ("sol", 0, 2, -h, 0), ("sag", w - 2, w, -h, 0)):
        L.kutu(ad, x0, x1, z0, z1, -1, 5, Mah)
    # sepet govdesi
    sx, sw, sy, sh = 2, w - 4, 5, h - 8
    Msep = cel("Sepet", ["#4e3a18", "#6d5228", "#a5813f", "#c9a45e"])
    L.kutu("sepet_arka", sx, sx + sw, -(sy + sh), -sy, 2.5, 3.5, cel("SepetIc", ["#3a2a12", "#5b4420", "#6d5228"]))
    # patatesler: yigin
    Mpat = cel("Patates", ["#6e4a1c", "#9a6a2c", "#c49a54", "#e2bf7a"], noise=0.12, noise_scale=10)
    cx, base = w / 2.0, sy + sh - 9
    import random
    r = random.Random(7)
    for i in range(19):
        u = (i + 0.5) / 19.0
        ox = (u - 0.5) * 2 * (sw / 2 - 4) + r.uniform(-1.5, 1.5)
        tepe = 7 * (1 - abs(u - 0.5) * 1.6)
        oy = base - r.uniform(0, tepe) - (i % 3) * 1.2
        rr = 5 + (1 if r.random() > .6 else 0)
        elipsoid("patates%d" % i, cx + ox, oy, rr * 0.9, rr * 0.72, rr * 0.8, r.uniform(-1.5, 1.5), Mpat)
    # on orgu: yatay seritler
    oy0 = sy + round(sh * .42)
    for gy in range(oy0, sy + sh, 3):
        L.kutu("orgu", sx, sx + sw, -(gy + 2), -gy, -3.2, -1.2, Msep)
    for gx in range(0, sw, 4):
        L.kutu("orucu", sx + gx, sx + gx + 1, -(sy + sh), -oy0, -3.6, -3.0, cel("Orucu", ["#4e3a18", "#6d5228", "#c09a52"]))
    # sepet agzi (cember)
    L.kutu("cember", sx - 1, sx + sw + 1, -(sy + 3), -sy, -3.6, 3.6, cel("Cember", ["#6d5228", "#8a6a3a", "#a5813f", "#c9a45e"]))
    L.kutu("taban", sx - 1, sx + sw + 1, -(sy + sh), -(sy + sh - 2), -3.6, 3.6, Msep)


# ---------------------------------------------------------------- tatli
def tatli_arka(w=34, h=34):
    Mcam = px.flat_a("CamArka", "#dff0f4", 0.30)
    L.kutu("cam_ic", 1, w - 1, -(h - 6), -8, 3, 4, Mcam)
    Mt = cel("Serbet", ["#6e4416", "#8a5a2a", "#c08a3a", "#dca858"])
    L.kutu("tepsi", 2, w - 2, -(h - 9), -(h - 14), -2, 3, Mt)


def tatli_on(w=34, h=34):
    Mb = cel("TatliTaban", ["#5e666e", "#8a929b", "#c6ccd2", "#e6ebef"])
    L.kutu("taban", 0, w, -(h - 2), -(h - 8), -3, 3, Mb)
    Mk = px.flat("CamKenar", "#7fa5ad")
    L.cerceve("kenar", w, h - 12, 0.5, 1.0, w / 2.0, -(h / 2.0), -3.4, 0.4, Mk)
    L.kutu("isik", 1, w - 1, -8, -7, -3.8, -3.6, px.flat("CamIsik", "#e8f6fa"))


def baklava():
    """drawBaklava: ust yuzu eskenar dortgen, yanda kat kat yufka, fistik."""
    K = 0.55
    bm = bmesh.new()
    kalin = 3.0
    ust = [(0, -5.0 / K * 0.5), (6.0, 0), (0, 5.0 / K * 0.5), (-6.0, 0)]
    a = [bm.verts.new((x, y, 0)) for x, y in ust]
    b = [bm.verts.new((x, y, kalin)) for x, y in ust]
    for i in range(4):
        bm.faces.new((a[i], a[(i + 1) % 4], b[(i + 1) % 4], b[i]))
    bm.faces.new(list(reversed(a)))
    bm.faces.new(b)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = mesh_ob("baklava", bm, cel("Baklava", ["#6b4212", "#8a5a1a", "#cf9c47", "#e8bd62", "#ffdf9a"]), smooth=False)
    ob.location = (0, 0, -4.5)
    Mk = px.flat("Kat", "#a8762a")
    for dz in (0.9, 1.9):
        bm2 = bmesh.new()
        vs = [bm2.verts.new((x * 1.01, y * 1.01, dz)) for x, y in ust]
        for i in range(4):
            j = (i + 1) % 4
            v1 = bm2.verts.new((ust[i][0] * 1.01, ust[i][1] * 1.01, dz + 0.3))
            v2 = bm2.verts.new((ust[j][0] * 1.01, ust[j][1] * 1.01, dz + 0.3))
            bm2.faces.new((vs[i], vs[j], v2, v1))
        o2 = mesh_ob("kat", bm2, Mk, smooth=False)
        o2.location = (0, 0, -4.5)
    Mf = px.flat("Fistik", "#6b9440")
    elipsoid("fistik", 0, 1.6, 1.3, 0.8, 1.0, -0.5, Mf, seg=8, ring=5)
    return K


# ---------------------------------------------------------------- cop
def cop_govde(w=30, h=28):
    Mc = cel("CopCerceve", ["#4a443c", "#6e675e", "#8a8278", "#a59d92"])
    Mi = px.flat("CopIc", "#14110f")
    L.kutu("ic", 1, w - 1, -(h - 1), -1, 6, 8, Mi)
    for ad, x0, x1, z0, z1 in (("ust", 0, w, -2, 0), ("alt", 0, w, -h, -h + 2),
                               ("sol", 0, 2, -h, 0), ("sag", w - 2, w, -h, 0)):
        L.kutu(ad, x0, x1, z0, z1, -1, 7, Mc)
    # ic derinlik golgesi: ust kenardan asagi kararan ic duvar
    L.kutu("ic_duvar", 2, w - 2, -8, -2, 0.5, 6, cel("IcDuvar", ["#0e0c0a", "#1c1814", "#2a2622"]))


def cop_kapak(w=30):
    M = cel("Kapak", ["#2e2a24", "#4a443c", "#6e675e", "#8a8278"])
    L.kutu("dil", 3, w - 3, -3, 0, -1.2, 1.2, M)


# ---------------------------------------------------------------- stok
def stok_oyuk(w=34, h=34):
    Mi = px.flat("OyukIc", "#171310")
    L.kutu("oyuk", -1, w + 1, -(h + 1), 1, 5, 7, Mi)
    L.kutu("oyuk_ust", 0, w, -8, 0, 0, 5, cel("OyukUst", ["#050403", "#0e0b09", "#1a1512"]))
    Mc = cel("OyukCerceve", ["#3a342e", "#5b544c", "#7a7268"])
    for ad, x0, x1, z0, z1 in (("u", -1, w + 1, 0, 1), ("a", -1, w + 1, -(h + 1), -h),
                               ("s", -1, 0, -(h + 1), 1), ("g", w, w + 1, -(h + 1), 1)):
        L.kutu(ad, x0, x1, z0, z1, -0.5, 5, Mc)


def stok_cekmece(w=34, h=30):
    """Cekmece: govde + sol on yuz (kulp burada). Capa cekmecenin sol-ustu."""
    Mg = cel("Cekmece", ["#4e3a18", "#5b4420", "#7a5a2c", "#a5813f"], noise=0.06, noise_scale=20)
    L.kutu("govde", 0, w, -h, 0, -1, 3, Mg)
    for v in range(0, h - 2, 4):
        L.kutu("tahta", 1, w - 1, -(1 + v + 1), -(1 + v + 0.6), -1.3, -1.0, px.flat("TahtaAra", "#5b4420"))


def stok_onyuz(w=34, h=30):
    """Cekmecenin sol on yuzu + dikey kulp: icerigin ONUNDE cizilir."""
    Mo = cel("OnYuz", ["#3e2e12", "#4e3a18", "#6d5228", "#a5813f"])
    L.kutu("on_yuz", 0, 5, -h, 0, -2.2, 3, Mo)
    Mk = cel("Kulp", ["#4a443c", "#6e675e", "#8a8278", "#c0b8ac"])
    L.kutu("kulp", 1, 3, -(h / 2 + 6), -(h / 2 - 6), -3.4, -2.2, Mk)


def stok_ic(w=34, h=30):
    Mi = px.flat("CekmeceIc", "#3a2a16")
    L.kutu("ic", 3, w - 3, -(h - 4), -3, -1.4, -1.2, Mi)
    elipsoid("tursu_kavanoz", 9, h - 9, 6, 4, 3, -2, cel("Yesil", [P["g4"], P["g3"], P["g2"], P["g1"]]))
    elipsoid("yogurt_kova", w - 10, h - 8, 6, 4, 3, -2, cel("Beyaz", ["#9aa2aa", "#c9cfd6", "#e2e8ed", "#eef2f5"]))


def kamera():
    Mg = cel("Kamera", ["#1b1f26", "#2b3037", "#4a545f", "#6d7a86"])
    L.kutu("ayak", 10, 15, -6, 2, 0, 3, cel("KamAyak", ["#2b3037", "#3a4149", "#5f6a75"]))
    L.kutu("govde", 0, 15, -11, -3, -2, 2, Mg)
    L.kutu("burun", -4, 1, -10, -5, -2.5, 1.5, px.flat("Burun", "#1b1f26"))
    elipsoid("mercek", -2, 7, 2, 2, 1, -3, px.flat("Mercek", "#0d1015"), seg=10, ring=6)
    elipsoid("parilti", -3, 6, 0.6, 0.6, 0.4, -4, px.flat("Parilti", "#8fb4d8"), seg=6, ring=4)


parca("lavas_yigin", (-2, -2, 46, 34), lavas_yigin, K=0.39, cizgi="#8a6a3a")
parca("pide_yigin", (-2, -6, 46, 24), pide_yigin, K=0.39, cizgi="#5a3a18")
parca("patates_dolap", (-3, -3, 50, 44), patates_dolap, K=0.30)
parca("tatli_arka", (-2, -2, 38, 38), tatli_arka, K=0.30)
parca("tatli_on", (-2, -2, 38, 38), tatli_on, K=0.30)
parca("baklava", (-8, -6, 16, 16), baklava, K=0.55, cizgi="#4a2a08", cizgi_alfa=120)
parca("cop_govde", (-2, -2, 34, 32), cop_govde, K=0.25)
parca("cop_kapak", (-1, -2, 32, 7), cop_kapak, K=0.25)
parca("stok_oyuk", (-3, -3, 40, 40), stok_oyuk, K=0.25)
parca("stok_cekmece", (-2, -2, 38, 34), stok_cekmece, K=0.25)
parca("stok_ic", (-1, -1, 36, 32), stok_ic, K=0.25)
parca("stok_onyuz", (-2, -2, 12, 34), stok_onyuz, K=0.25)
parca("kamera", (-6, -4, 24, 16), kamera, K=0.25, cizgi="#0d1015", cizgi_alfa=200)


def uret(ad):
    (gx0, gy0, w, h), fn, K, cizgi, cizgi_alfa = PARCALAR[ad]
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
    adlar = argv if argv else list(PARCALAR)
    for ad in adlar:
        uret(ad)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR),
                   "kokenler": {k: list(v) for k, v in KOKEN.items()}}, fp, indent=1)
    print("ISTASYON_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
