"""DAYI (USTA) — remake HD katmanlari.

    blender --background --factory-startup --python blender/models/dayi_hd.py [-- katman_adi]

Oyundaki karsiligi: js/chars.js drawChef(x, y, st, t). Olculer oradan birebir:
yerel koordinat (gx, gy) = cizimin (x, y) noktasina gore mantik pikseli.
  kafa merkezi (23, 30)   fes ustu gy=0   omuz ustu gy=50   ayak ~gy=153

OYUNDA GERCEKTEN KULLANILAN durumlar (game.js): 'idle', 'slice' (doSlice),
'happy' (Dayi yardimi). drawChef'teki 'box' pozunu oyun hic cagirmiyor ->
yapilmadi. Canlilik (nefes, sallanma, agirlik aktarma, kafa donusu, goz
kirpma, puskul, 7.4 sn'lik jest) Godot'da orijinal formullerle birlesiyor;
Blender yalniz parcalari ve pozlari uretiyor:

  bacak, govde, boyun, kafa, fes, puskul_0..6, kas, goz_*, burun, allik,
  biyik, agiz, agiz_mutlu, kol_* (bosta / jest fes / jest biyik / kesim /
  mutlu)

Cikti: blender/out/dayi_hd/<katman>.png — hepsi AYNI tuvalde (gx -12..62,
gy -8..160), 2x HD. blender/hd_atlas.py bunlari kirpip atlasa paketler.
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

OUT = os.path.join(_HERE, "out", "dayi_hd")
P = pal.P
HD = 2
TUVAL = (-12, -8, 74, 168)          # gx0, gy0, w, h (mantik pikseli)

# ---------------------------------------------------------------- renkler
# chars.js'teki renkler koyudan acige; cel rampasi 4 kademe
SKIN = ["#a06f42", "#cf9560", "#f0bd8a", "#ffdcb0"]
GOMLEK = ["#a89a80", "#ded8c8", "#f4efe2", "#f8f4e8"]
YELEK = [P["red3"], P["red2"], P["red1"], P["red0"]]
ALTIN = [P["au3"], P["au2"], P["au1"], P["au0"]]
KUSAK = ["#5e1a14", "#8e2b20", "#a8392a", "#c4523c"]
SALVAR = ["#1e3a63", "#20406e", "#35619a", "#5285c4"]
LASTIK = ["#16294a", "#16294a", "#2b4d80", "#4a7ab8"]
CIZME = ["#3a2418", "#5b3a20", "#7a5230", "#a5713f"]
AK = ["#c8c8c2", "#dcdcd6", "#efefe9", "#ffffff"]
FES = [P["red3"], P["red2"], P["red1"], P["red0"]]
FES_UST = [P["red1"], "#e8674f", "#e8674f", "#f4a08a"]
PUSKUL = ["#241a14", "#241a14", "#3a2a20", "#4a3a2a"]
STOPS = [0.0, 0.42, 0.70, 0.88]

IZINLI = sorted(set(SKIN + GOMLEK + YELEK + ALTIN + KUSAK + SALVAR + LASTIK + CIZME + AK + FES
                    + FES_UST + PUSKUL + ["#ffffff", "#2b2018", "#6a5a4a", "#a86a5a", "#7a3a30",
                                          "#c9584a", "#e07a68", "#d8d2c0", "#fff0dc", "#e8e2d2"]))


def sahne():
    L._FONTLAR.clear()
    px.reset()
    gx0, gy0, w, h = TUVAL
    px.setup(w * HD, h * HD)
    px.ortho_cam(gx0 + w / 2.0, -(gy0 + h / 2.0), w, h)
    px.world("#000000", 0.0)
    # isik: onden, ustten, soldan (oyunun cizimlerinde acik taraf sol-ust)
    d = Vector((0.45, 0.80, -0.40)).normalized()
    s = px.sun(math.pi, rot=(0, 0, 0))
    s.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def cel(ad, ramp):
    return px.cel(ad, ramp, STOPS)


# ---------------------------------------------------------------- geometri
def link(ob):
    bpy.context.collection.objects.link(ob)
    return ob


def elipsoid(ad, gx, gy, rx, rz, ry, derin, mat, seg=28, ring=18):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, radius=1.0)
    me = bpy.data.meshes.new(ad)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = True
    ob = link(bpy.data.objects.new(ad, me))
    ob.scale = (rx, ry, rz)
    ob.location = (gx, derin, -gy)
    me.materials.append(mat)
    return ob


def tup(ad, a, b, r, derin, mat, r_b=None, seg=20):
    """(gx, gy) a -> b arasi silindir; uclar yuvarlak degil (ayri top eklenir)."""
    ax, ay = a
    bx, by = b
    uz = math.hypot(bx - ax, by - ay)
    if uz < 0.01:
        return None
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=seg,
                          radius1=r, radius2=(r if r_b is None else r_b), depth=uz)
    me = bpy.data.meshes.new(ad)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = True
    ob = link(bpy.data.objects.new(ad, me))
    # koni Z ekseninde; (ax,-ay) -> (bx,-by) yonune cevir
    v = Vector((bx - ax, 0, -(by - ay))).normalized()
    ob.rotation_euler = v.to_track_quat("Z", "Y").to_euler()
    ob.location = ((ax + bx) / 2.0, derin, -(ay + by) / 2.0)
    me.materials.append(mat)
    return ob


def dikey_profil(ad, gy0, gy1, gen_f, derin_orani, cx_f, derin, mat, seg=36, satir=24):
    """Yatay elips kesitlerden govde: her satirda genislik gen_f(u), merkez cx_f(u)."""
    bm = bmesh.new()
    halkalar = []
    for i in range(satir + 1):
        u = i / satir
        gy = gy0 + (gy1 - gy0) * u
        w = max(0.3, gen_f(u)) / 2.0
        cx = cx_f(u)
        halka = []
        for k in range(seg):
            a = 2 * math.pi * k / seg
            halka.append(bm.verts.new((cx + math.cos(a) * w, math.sin(a) * w * derin_orani, -gy)))
        halkalar.append(halka)
    for i in range(satir):
        for k in range(seg):
            bm.faces.new((halkalar[i][k], halkalar[i][(k + 1) % seg],
                          halkalar[i + 1][(k + 1) % seg], halkalar[i + 1][k]))
    bm.faces.new(list(reversed(halkalar[0])))
    bm.faces.new(halkalar[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    me = bpy.data.meshes.new(ad)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = True
    ob = link(bpy.data.objects.new(ad, me))
    ob.location = (0, derin, 0)
    me.materials.append(mat)
    return ob


def duz(ad, gx0, gy0, gx1, gy1, derin, mat, kalin=0.4):
    """Kameraya bakan ince duz dikdortgen (goz, agiz cizgisi...)."""
    return L.kutu(ad, gx0, gx1, -gy1, -gy0, derin - kalin / 2.0, derin + kalin / 2.0, mat)


def kafa_on(gx, gy):
    """Kafa elipsoidinin (23,30; 15x14, derinlik 13) on yuzeyinin derinligi."""
    k = 1 - ((gx - 23) / 15.0) ** 2 - ((gy - 30) / 14.0) ** 2
    return -13.0 * math.sqrt(max(0.0, k)) - 0.2


# ---------------------------------------------------------------- parcalar
def bacak():
    M = cel("Salvar", SALVAR)
    by = 50
    sl_top, sl_alt = by + 58, by + 92
    ayrim = 0.52

    def gen(u):
        return (26 + math.sin(u * math.pi * 0.82) * 16 - u * 3) * 1.08
    uy = sl_top + (sl_alt - sl_top) * ayrim
    dikey_profil("salvar_ust", sl_top, uy + 1, lambda u: gen(u * ayrim), 0.62,
                 lambda u: 23.0, 0, M)
    for yan in (-1, 1):
        def g2(u, yan=yan):
            lu = ayrim + (1 - ayrim) * u
            ara = 1 + round(u * 2)
            return (gen(lu) - ara) / 2.0

        def c2(u, yan=yan):
            lu = ayrim + (1 - ayrim) * u
            return 23.0 + yan * (gen(lu) / 4.0 + 0.5)
        dikey_profil("salvar_%d" % yan, uy, sl_alt, g2, 0.80, c2, 0, M)
    ML = cel("Lastik", LASTIK)
    MC = cel("Cizme", CIZME)
    for cx in (12.0, 34.0):
        L.silindir("lastik", 6.8, cx, 0, -(sl_alt - 2), 4, ML, seg=24)
        L.silindir("konc", 7.6, cx, 0, -(by + 94), 4, MC, seg=24)
        elipsoid("ayak", cx - 1, by + 98.5, 10, 4.6, 7.5, -1.5, MC)


def govde_gen(u):
    """Govde genisligi (u: omuz 0 .. bel 1): yuvarlak omuz, dolgun gobek.
    Ilk surum sabit 45 px silindirdi; oyuncak robot gibi kutu duruyordu."""
    if u < 0.12:
        return 30 + 15 * math.sin(u / 0.12 * math.pi / 2)
    return 45 + 3 * math.sin((u - 0.12) / 0.88 * math.pi) - 1.0 * u


def govde():
    MG = cel("Gomlek", GOMLEK)
    MY = cel("Yelek", YELEK)
    MA = cel("Altin", ALTIN)
    MK = cel("Kusak", KUSAK)
    by = 50
    # gomlek: genis, hafif oval govde. UST kenar by-3 (eski cizimde omuz elipsi
    # by+5 merkezli, ry 8 -> tepe by-3); by+3'ten baslayinca boyunla govde
    # arasinda bosluk kaliyordu (kafa ayri duruyor gibi).
    dikey_profil("gomlek", by - 3, by + 69, lambda u: govde_gen(max(0.0, (u - 0.083) / 0.917)) * (0.62 + 0.38 * min(1.0, u / 0.083)) if u < 0.083 else govde_gen((u - 0.083) / 0.917), 0.50, lambda u: 23.5, 0, MG)
    elipsoid("gobek", 24.5, by + 50, 13, 13, 13.5, -1.5, MG)
    # yelek: govdeden biraz genis kabuk, onu acik (x 16..31)
    kabuk = dikey_profil("yelek", by + 3.5, by + 64, lambda u: govde_gen(u * 0.92) + 2.2, 0.56, lambda u: 23.5, 0, MY)
    bm = bmesh.new()
    bm.from_mesh(kabuk.data)
    sil = [f for f in bm.faces if (16.0 < f.calc_center_median().x < 31.0 and f.calc_center_median().y < 0)]
    bmesh.ops.delete(bm, geom=sil, context="FACES")
    bm.to_mesh(kabuk.data)
    bm.free()
    # yelek on kenar altin serit
    for gx in (15.6, 31.4):
        d = -math.sqrt(max(0.0, 1 - ((gx - 23.5) / 23.6) ** 2)) * 13.2 - 0.6
        L.kutu("serit", gx - 0.9, gx + 0.9, -(by + 63), -(by + 5), d - 0.6, d + 0.6, MA)
    # dugmeler ve sarmal isleme
    for i in range(4):
        for gx in (11.0, 36.0):
            d = -math.sqrt(max(0.0, 1 - ((gx - 23.5) / 23.6) ** 2)) * 13.2 - 1.0
            elipsoid("dugme", gx, by + 16 + i * 11, 1.2, 1.2, 0.8, d, MA, seg=10, ring=6)
    for i in range(5):
        iy = by + 12 + i * 10
        for gx, yon in ((5.5, 1), (41.5, -1)):
            d = -math.sqrt(max(0.0, 1 - ((gx - 23.5) / 23.6) ** 2)) * 13.2 - 0.7
            pts = [(0, 0), (1.2 * yon, 0), (3.5 * yon, -3), (1.2 * yon, -6), (0, -6), (2.3 * yon, -3)]
            L.cokgen("isleme", pts, gx, -iy, d, 0.3, 0.0, MA)
    # kusak
    ky, kh = by + 57, 12
    dikey_profil("kusak", ky, ky + kh, lambda u: 46.5, 0.56, lambda u: 23.5, -0.3, MK)
    for sy in (ky + 3, ky + kh - 4):
        dikey_profil("kusak_serit", sy, sy + 1, lambda u: 46.9, 0.57, lambda u: 23.5, -0.3, MA, satir=1)
    elipsoid("dugum", 37.5, ky + 5.5, 4.8, 4.8, 3.2, -13.8, MK)
    L.kutu("sarkan", 36, 41, -(ky + kh + 7), -(ky + kh - 1), -14.2, -12.6, MK)


def kol(ad, omuz, el, derin=-2.0, yen_r=4.3, mat_yen=None, mat_ten=None, manset=True):
    """Omuzdan ele gomlek yeni + manset + el."""
    MG = mat_yen or cel("Yen", GOMLEK)
    MS = mat_ten or cel("Ten", SKIN)
    ox, oy = omuz
    ex, ey = el
    uz = math.hypot(ex - ox, ey - oy)
    if uz > 0.5:
        k = max(0.0, (uz - 4.0) / uz)
        mx, my = ox + (ex - ox) * k, oy + (ey - oy) * k
        tup(ad + "_yen", (ox, oy), (mx, my), yen_r, derin, MG)
        elipsoid(ad + "_omuz", ox, oy, yen_r + 0.6, yen_r, yen_r, derin, MG, seg=16, ring=10)
        if manset:
            MM = cel("Manset", ["#a89a80", "#d8d2c0", "#e8e2d2", "#f4efe2"])
            tup(ad + "_manset", (mx, my), (ox + (ex - ox) * min(1.0, k + 1.8 / max(uz, .1)),
                                            oy + (ey - oy) * min(1.0, k + 1.8 / max(uz, .1))),
                yen_r + 0.4, derin, MM)
    elipsoid(ad + "_el", ex, ey, 5.3, 5.0, 4.6, derin - 0.5, MS, seg=16, ring=10)


# kare sayilari: kesim kolu 1 px adimla (sw -5..5), jestler 8 kare (eskisi 5 / 4)
KESIM_KARE = 11
JEST_KARE = 8


def kol_katmani(ad):
    """Katman adindan poz: kol_sol_bosta, kol_sag_jest_fes_3 ..."""
    by, hx, hy = 50, 23, 30
    if ad == "kol_sol_bosta":
        kol(ad, (3, by + 10), (3, by + 40))
    elif ad == "kol_sag_bosta":
        kol(ad, (43, by + 10), (44, by + 41))
    elif ad.startswith("kol_sag_jest_"):
        _, _, _, tip, n = ad.split("_")
        k = int(n) / float(JEST_KARE)
        hedef_y = hy - 4 if tip == "fes" else hy + 9
        elx = 44 + (hx + 12 - 44) * k
        ely = (by + 41) + (hedef_y - (by + 41)) * k
        kol(ad, (43, by + 10), (elx, ely), derin=-6.0 * k - 2.0)
    elif ad.startswith("kol_sag_kesim_"):
        sw = -5.0 + 10.0 * int(ad.split("_")[-1]) / float(KESIM_KARE - 1)
        MG, MS = cel("Yen", GOMLEK), cel("Ten", SKIN)
        tup("ust", (43, by + 9), (43.5, by + 24), 5.0, -2.0, MG)
        elipsoid("omuz", 43, by + 9, 5.4, 5, 5, -2.0, MG, seg=16, ring=10)
        tup("on", (44, by + 24), (46, by + 30 + sw), 4.0, -3.0, MS)
        elipsoid("el", 46, by + 31.5 + sw, 4.8, 4.6, 4.2, -3.5, MS, seg=16, ring=10)
    elif ad == "kol_sol_kesim":
        kol(ad, (4, by + 15), (4, by + 36.5))
    elif ad == "kol_sol_mutlu":
        kol(ad, (2, by + 11), (2, by - 14), manset=False)
    elif ad == "kol_sag_mutlu":
        kol(ad, (45, by + 11), (45, by - 14), manset=False)


def kafa():
    MS = cel("Kafa", SKIN)
    MA = cel("Sac", AK)
    elipsoid("kafa", 23, 30, 15, 14, 13, 0, MS)
    for gx in (8.0, 38.0):
        elipsoid("kulak", gx, 33, 3, 5, 2.5, -1, MS, seg=14, ring=8)
    for gx in (9.5, 36.5):
        elipsoid("sac", gx, 29, 3.4, 6, 6.5, -2, MA, seg=16, ring=10)
        elipsoid("sac_alt", gx, 34.5, 4, 4, 5.5, -2.5, MA, seg=16, ring=10)


def boyun():
    MS = cel("Boyun", [SKIN[0], SKIN[0], SKIN[1], SKIN[2]])
    L.silindir("boyun", 6, 23, 1, -47, 9, MS, seg=20)


def fes():
    MF = cel("Fes", FES)
    MU = cel("FesUst", FES_UST)
    L.silindir("fes", 13.5, 23, 0, -12, 14, MF, seg=40, r2=12.4)
    L.silindir("fes_tepe", 12.4, 23, 0, -4.6, 0.8, MU, seg=40)


def puskul(sw):
    MP = cel("Puskul", PUSKUL)
    tup("ip", (34, 4), (38 + sw, 16), 0.7, -13.5, MP, seg=8)
    elipsoid("top", 38 + sw, 17, 2.2, 2.4, 2.0, -13.5, MP, seg=12, ring=8)


def kas(yuk=0.0):
    MA = cel("Kas", AK)
    for gx, yon in ((14.5, -1), (31.5, 1)):
        d = kafa_on(gx, 25)
        elipsoid("kas", gx, 25 - yuk, 4.2, 1.8, 1.4, d - 0.4, MA, seg=14, ring=8)
        elipsoid("kas_uc", gx + yon * 3.6, 26 - yuk, 1.4, 1.4, 1.0, d - 0.2, MA, seg=10, ring=6)


def gozler(durum):
    B = px.flat("GozBeyaz", "#ffffff")
    K = px.flat("GozBebek", "#2b2018")
    I = px.flat("GozIsik", "#6a5a4a")
    for gx0 in (13, 27):
        d = kafa_on(gx0 + 3, 30) - 0.3
        if durum == "kapali":
            duz("kapak", gx0, 30, gx0 + 6, 31, d, px.flat("Kapak", SKIN[0]))
            continue
        if durum == "yari":
            # kirpma ara karesi: ust kapak gozun yarisina inmis
            duz("beyaz", gx0, 30, gx0 + 6, 33, d, B)
            duz("bebek", gx0 + 2, 30, gx0 + 5, 32, d - 0.4, K)
            duz("kapak", gx0, 27, gx0 + 6, 30, d - 0.7, px.flat("KapakY", SKIN[1]))
            duz("kapak_cizgi", gx0, 30, gx0 + 6, 30.5, d - 0.8, px.flat("KapakC", "#a06f42"))
            continue
        look = 1 if durum == "acik_1" else 0
        duz("beyaz", gx0, 27, gx0 + 6, 33, d, B)
        duz("bebek", gx0 + 2 + look, 29, gx0 + 5 + look, 32, d - 0.4, K)
        duz("isik", gx0 + 2 + look, 29, gx0 + 3 + look, 30, d - 0.6, I)


def burun():
    MS = cel("Burun", SKIN)
    elipsoid("burun", 22, 34, 6, 5, 4.2, kafa_on(22, 34) + 1.5, MS)
    elipsoid("burun_isik", 20, 32, 2.6, 1.6, 1.0, kafa_on(20, 32) - 1.6, px.flat("BurunIsik", "#fff0dc"),
             seg=10, ring=6)


def allik():
    M = px.flat_a("Allik", "#e07a68", 0.32)
    for gx in (12.0, 32.0):
        elipsoid("allik", gx, 36, 4, 3, 0.6, kafa_on(gx, 36) - 0.5, M, seg=14, ring=8)


def biyik():
    MA = cel("Biyik", AK)
    d = kafa_on(23, 42) - 2.0
    elipsoid("biyik", 23, 41.5, 10.5, 2.6, 3.0, d, MA)
    for gx, yon in ((12.5, -1), (33.5, 1)):
        elipsoid("kivrim", gx, 40.5, 3.2, 2.4, 2.4, d + 0.8, MA, seg=16, ring=10)
        elipsoid("uc", gx + yon * 3.4, 38.5, 1.6, 1.6, 1.4, d + 1.2, MA, seg=10, ring=6)


def agiz(mutlu):
    d = kafa_on(23, 44) - 0.6
    if not mutlu:
        duz("agiz", 19, 44, 28, 45, d, px.flat("Agiz", "#a86a5a"))
        return
    duz("agiz", 16, 44, 31, 48, d, px.flat("AgizIc", "#7a3a30"))
    duz("dis", 17, 44, 30, 45, d - 0.3, px.flat("Dis", "#ffffff"))
    duz("dil", 17, 47, 30, 48, d - 0.3, px.flat("Dil", "#c9584a"))
    K = px.flat("Kirisik", SKIN[0])
    L.kutu("kirisik_l", 11, 12, -44, -41, kafa_on(11.5, 42) - 0.4, kafa_on(11.5, 42) + 0.1, K)
    L.kutu("kirisik_r", 34, 35, -44, -41, kafa_on(34.5, 42) - 0.4, kafa_on(34.5, 42) + 0.1, K)


# ---------------------------------------------------------------- katmanlar
KATMANLAR = {}


def katman(ad, fn, cizgi=True, cizgi_renk=None):
    KATMANLAR[ad] = (fn, cizgi, cizgi_renk)


katman("bacak", bacak)
katman("govde", govde)
katman("boyun", boyun, cizgi=False)
katman("kafa", kafa)
katman("fes", fes)
for i, sw in enumerate((-3, -2, -1, 0, 1, 2, 3)):
    katman("puskul_%d" % i, lambda sw=sw: puskul(sw))
katman("kas", kas, cizgi_renk="#a06f42")
katman("kas_ust", lambda: kas(1.0), cizgi_renk="#a06f42")
for dz in ("acik_0", "acik_1", "kapali", "yari"):
    katman("goz_" + dz, lambda dz=dz: gozler(dz), cizgi=False)
katman("burun", burun, cizgi_renk="#a06f42")
katman("allik", allik, cizgi=False)
katman("biyik", biyik, cizgi_renk="#a06f42")
katman("agiz", lambda: agiz(False), cizgi=False)
katman("agiz_mutlu", lambda: agiz(True), cizgi=False)
for ad in (["kol_sol_bosta", "kol_sag_bosta", "kol_sol_kesim", "kol_sol_mutlu", "kol_sag_mutlu"]
           + ["kol_sag_jest_fes_%d" % i for i in range(1, JEST_KARE + 1)]
           + ["kol_sag_jest_biyik_%d" % i for i in range(1, JEST_KARE + 1)]
           + ["kol_sag_kesim_%d" % i for i in range(KESIM_KARE)]):
    katman(ad, lambda ad=ad: kol_katmani(ad))


def uret(ad):
    fn, cizgi, renk = KATMANLAR[ad]
    sahne()
    fn()
    yol = px.render(os.path.join(OUT, ad + ".png"))
    kotu = px.audit(yol, IZINLI, label=ad, show=0)
    if kotu:
        px.quantize(yol, IZINLI)
    if cizgi:
        px.outline(yol, hexcol=renk or P["ui5"], alpha=230)
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = argv if argv else list(KATMANLAR)
    for ad in adlar:
        uret(ad)
    gx0, gy0, w, h = TUVAL
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"gx0": gx0, "gy0": gy0, "w": w, "h": h, "hd": HD,
                   "katmanlar": list(KATMANLAR)}, fp, indent=1)
    print("DAYI_HD_DONE %d katman" % len(adlar))


if __name__ == "__main__":
    main()
