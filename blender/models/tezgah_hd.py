"""ALT TEZGAH ISTASYONLARI — remake HD parcalari.

    blender --background --factory-startup --python blender/models/tezgah_hd.py [-- parca ...]
    python blender/hd_atlas.py tezgah_hd tezgah

Oyundaki karsiliklari (art.js):
  servis tahtasi (drawPlay icinde, ST.board 94x47)  -> tahta          capa: ST.board sol-ust
  drawCutBoard   (ST.cut 48x46)   -> kesme_tahta, kesme_kap           capa: ST.cut sol-ust
                                     patates_2..11 (kesilen patates)  capa: (x+w/2-6, y+20)
                                     patates_dilim                    capa: dilimin sol-ustu
                                     cig_cubuk (kaptaki cig patates)  capa: cubugun sol-ustu
  drawGrill      (ST.grill 68x46) -> izgara_govde, izgara_cubuk       capa: ST.grill sol-ust
  drawPaperStation (ST.paper 24x46)
                   seviye 0       -> kagit_aski                       capa: ST.paper sol-ust
                   seviye 1+      -> kagit_makine, (2+) kagit_oto
  drawSauceStation (ST.sauce 48x48) -> sos_raf                        capa: ST.sauce sol-ust
  drawSauceBottle -> sise_0 (aci) / sise_1 (sarimsak) / sise_2 (tereyagi)
                                                   capa: sisenin (cx, taban) noktasi
  drawFboxStation (ST.fbox 38x46) -> kutu_raf, kutu_bos               capa: ST.fbox sol-ust

Oyunda kodla kalanlar (durum oradan geliyor): izgaradaki korlar (cizgilerin
ARASINDA yanip sonuyor: govde -> kor -> cubuk sirasi), yuva cerceveleri,
kagit makinesinin isigi / cikan kagit / fan noktasi, sise sikma bandi ve
kilit, patates dilim sayisi, etiket yazilari, golgeler.

Koordinat: 1 birim = 1 mantik pikseli. Ekran gy -> dunya z = -gy. Oblik
acilim z += y*K: derinligi y olan bir nokta ekranda gy = -(z + y*K)'de.
"""
import sys, os, math, json, random
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I

OUT = os.path.join(_HERE, "out", "tezgah_hd")
HD = 2
KOKEN = {}
PARCALAR = {}
cel = I.cel
mesh_ob = I.mesh_ob


def parca(ad, tuval, fn, K=0.5, cizgi=None, cizgi_alfa=170):
    PARCALAR[ad] = (tuval, fn, K, cizgi, cizgi_alfa)
    KOKEN[ad] = (tuval[0], tuval[1])


def hexmul(h, f):
    h = h.lstrip("#")
    r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    return "#%02x%02x%02x" % tuple(max(0, min(255, int(round(c * f)))) for c in (r, g, b))


def ez(gy, y, K):
    """Derinligi y olan noktanin ekranda gy'de gorunmesi icin z."""
    return -gy - y * K


def onkutu(ad, x0, x1, gy0, gy1, y0, y1, mat, K):
    """On yuzu (y0'da) ekranda [gy0, gy1] araliginda duran kutu."""
    return L.kutu(ad, x0, x1, ez(gy1, y0, K), ez(gy0, y0, K), y0, y1, mat)


def _yr(x0, y0, w, d, rx, ry, seg=5):
    pts = []
    for cx, cy, a0 in ((x0 + w - rx, y0 + d - ry, 0), (x0 + rx, y0 + d - ry, 90),
                       (x0 + rx, y0 + ry, 180), (x0 + w - rx, y0 + ry, 270)):
        for i in range(seg + 1):
            a = math.radians(a0 + 90.0 * i / seg)
            pts.append((cx + rx * math.cos(a), cy + ry * math.sin(a)))
    return pts


def yatay_plaka(ad, x0, gy0, w, hs, r, kalin, mat, K, z_ust=None):
    """Ust yuzu ekranda (x0, gy0, w, hs) dikdortgeninde gorunen yuvarlak
    koseli yatay levha. On kenarin altinda `kalin` px dudak gorunur."""
    if z_ust is None:
        z_ust = -(gy0 + hs)
    yf = (-(gy0 + hs) - z_ust) / K
    D = hs / K
    pts = _yr(x0, yf, w, D, r, min(r / K, D / 2.0 - 0.01))
    bm = bmesh.new()
    alt = [bm.verts.new((x, y, z_ust - kalin)) for x, y in pts]
    ust = [bm.verts.new((x, y, z_ust)) for x, y in pts]
    n = len(pts)
    for i in range(n):
        bm.faces.new((alt[i], alt[(i + 1) % n], ust[(i + 1) % n], ust[i]))
    bm.faces.new(list(reversed(alt)))
    bm.faces.new(ust)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return mesh_ob(ad, bm, mat, smooth=False), z_ust


def ust_poligon(ad, pts, z, mat, K, kal=0.04):
    """Yatay yuzey ustune (z) ekranda pts koseli ince yama."""
    bm = bmesh.new()
    a = [bm.verts.new((gx, (-gy - z) / K, z)) for gx, gy in pts]
    b = [bm.verts.new((gx, (-gy - z) / K, z + kal)) for gx, gy in pts]
    n = len(pts)
    for i in range(n):
        bm.faces.new((a[i], a[(i + 1) % n], b[(i + 1) % n], b[i]))
    bm.faces.new(list(reversed(a)))
    bm.faces.new(b)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return mesh_ob(ad, bm, mat, smooth=False)


def ust_cizgi(ad, x0, gy0, x1, gy1, kal, z, mat, K):
    dx, dy = x1 - x0, gy1 - gy0
    L_ = math.hypot(dx, dy) or 1.0
    nx, ny = -dy / L_ * kal / 2.0, dx / L_ * kal / 2.0
    return ust_poligon(ad, [(x0 + nx, gy0 + ny), (x1 + nx, gy1 + ny), (x1 - nx, gy1 - ny), (x0 - nx, gy0 - ny)], z, mat, K)


def on_poligon(ad, pts, y, mat, K, derin=0.3):
    """Dikey on yuze (derinlik y) ekranda pts koseli levha."""
    bm = bmesh.new()
    a = [bm.verts.new((gx, y, ez(gy, y, K))) for gx, gy in pts]
    b = [bm.verts.new((gx, y + derin, ez(gy, y, K))) for gx, gy in pts]
    n = len(pts)
    for i in range(n):
        bm.faces.new((a[i], a[(i + 1) % n], b[(i + 1) % n], b[i]))
    bm.faces.new(list(reversed(a)))
    bm.faces.new(b)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return mesh_ob(ad, bm, mat, smooth=False)


def torna(ad, profil, cx, gy_taban, ym, derin, mat, K, seg=28, kapak=True):
    """Dikey eksenli donel govde. profil: [(yaricap, yukseklik)], yukseklik
    tabandan yukari. derin: derinlik yonundeki yaricap carpani (yassi sise)."""
    bm = bmesh.new()
    z0 = ez(gy_taban, ym, K)
    halkalar = []
    for r, h in profil:
        halkalar.append([bm.verts.new((cx + r * math.cos(2 * math.pi * i / seg),
                                       ym + r * derin * math.sin(2 * math.pi * i / seg),
                                       z0 + h)) for i in range(seg)])
    for a, b in zip(halkalar, halkalar[1:]):
        for i in range(seg):
            bm.faces.new((a[i], a[(i + 1) % seg], b[(i + 1) % seg], b[i]))
    if kapak:
        bm.faces.new(list(reversed(halkalar[0])))
        bm.faces.new(halkalar[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return mesh_ob(ad, bm, mat, smooth=True)


# ---------------------------------------------------------------- ahsap tahtalar
def _ahsap_malzeme():
    Mg = cel("TahtaGovde", ["#4e3418", "#7a5230", "#a8804e", "#c49a68"], [0, .3, .62, .8], noise=0.05, noise_scale=30)
    Mi = cel("TahtaIc", ["#7a5230", "#b08a58", "#c9a26e", "#dcb480"], [0, .3, .62, .8], noise=0.06, noise_scale=26)
    return Mg, Mi


def _damar(r, x0, x1, gy, z, mat, K, kal=0.5):
    """Tahta damari: duz cizgi degil, hafif dalgali kesik parcalar."""
    x = x0
    while x < x1 - 2:
        uz = r.uniform(8, 18)
        x2 = min(x1, x + uz)
        o1, o2 = r.uniform(-.35, .35), r.uniform(-.35, .35)
        ust_cizgi("damar", x, gy + o1, x2, gy + o2, kal, z, mat, K)
        x = x2 + r.uniform(1.0, 4.0)


def tahta(w=94):
    K = 0.5
    Mg, Mi = _ahsap_malzeme()
    _, zt = yatay_plaka("tahta", 2, 7, w - 4, 34, 3, 1.5, Mg, K)
    _, zi = yatay_plaka("ic", 4, 9, w - 8, 30, 2, 0.35, Mi, K, z_ust=zt + 0.35)
    r = random.Random(3)
    for g in range(6):
        _damar(r, 5, w - 5, 11 + g * 5, zi, px.flat("Damar%d" % g, "#d3aa76" if g % 2 else "#d8b07d"), K)
    ust_cizgi("isik", 4, 8.4, w - 4, 8.4, 0.7, zt, px.flat("TahtaIsik", "#eccb96"), K)
    Mc = px.flat("Bicak", "#cda775")
    for ci in range(7):
        bx, by = 8 + ci * 12, 14 + (ci % 3) * 6
        ust_cizgi("iz", bx, by, bx + 5, by + 4, 0.5, zi, Mc, K)
        ust_cizgi("iz2", bx + 1.5, by + 0.4, bx + 4.5, by + 3, 0.4, zi, px.flat("Bicak2", "#e6c48e"), K)


def kesme_tahta(w=48, h=46):
    K = 0.5
    Mg, Mi = _ahsap_malzeme()
    _, zt = yatay_plaka("tahta", 2, 5, w - 4, h - 12, 3, 1.5, Mg, K)
    _, zi = yatay_plaka("ic", 4, 7, w - 8, h - 16, 2, 0.35, Mi, K, z_ust=zt + 0.35)
    r = random.Random(11)
    for g in range(5):
        _damar(r, 5, w - 5, 9 + g * 5, zi, px.flat("Damar%d" % g, "#d4ab76"), K)
    ust_cizgi("isik", 4, 6.4, w - 4, 6.4, 0.7, zt, px.flat("TahtaIsik", "#eccb96"), K)
    Mc = px.flat("Kesik", "#c8a270")
    for s in range(6):
        ust_cizgi("kesik", 8 + s * 6, 12, 10 + s * 6, 20, 0.5, zi, Mc, K)


def kesme_kap(w=48, h=46):
    """Cig patates kabi: bx = x+w-17, by = y+h-22, 15x14. Arka ic duvar
    acik, on dudak alcak: icindeki cubuklar kodla on dudagin ustune cizilir."""
    K = 0.5
    bx, by = w - 17, h - 22
    Mdis = cel("KapDis", ["#5f6672", "#7a828b", "#8a929b", "#c6ccd2"], [0, .3, .5, .8])
    Mic = cel("KapIc", ["#8a929b", "#a4acb4", "#b6bec6", "#d6dee6"], [0, .3, .5, .8])
    D = 8
    # arka duvar (ic yuzu kameraya bakiyor)
    onkutu("arka", bx, bx + 15, by, by + 11, D - 1, D, Mic, K)
    # taban
    L.kutu("taban", bx, bx + 15, ez(by + 14, 0, K) - 0.5, ez(by + 14, 0, K), 0, D, Mic)
    # yan duvarlar
    for x0 in (bx, bx + 14):
        L.kutu("yan", x0, x0 + 1, ez(by + 14, 0, K) - 0.5, ez(by + 3, D, K), 0, D, Mdis)
    # on dudak
    onkutu("on", bx, bx + 15, by + 9, by + 14, 0, 1, Mdis, K)
    onkutu("on_isik", bx + 1, bx + 14, by + 9, by + 9.5, -0.05, 0.5, px.flat("KapIsik", "#d6dee6"), K)


def cig_cubuk():
    K = 0.5
    M = cel("Cig", ["#b89a58", "#d8c07e", "#e8d59a", "#f8ecc0"], [0, .3, .55, .8])
    onkutu("cubuk", 0.1, 1.9, 0.6, 5, 0, 1.2, M, K)


def patates_n(pw):
    """Kesilen patates: sol ucu sabit, sag uctan kisaliyor, kesik yuzu acik."""
    def fn():
        K = 0.5
        Mk = cel("Kabuk", ["#6d4d24", "#8a6432", "#b98b46", "#d8ab63"], [0, .3, .5, .75], noise=0.12, noise_scale=6)
        Mi = cel("KesikYuz", ["#d8c488", "#e8d59a", "#f2e0a8", "#fff6d0"], [0, .3, .5, .75])
        bm = bmesh.new()
        bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=1.0)
        r = random.Random(5)
        for v in bm.verts:
            # patates: hafif yumru, tam elips degil
            bozul = 1.0 + 0.06 * math.sin(v.co.x * 5.0 + 1.3) + 0.04 * math.cos(v.co.z * 7.0)
            v.co.x *= 11.0 * bozul
            v.co.z *= 5.8 * bozul
            v.co.y *= 5.0 * bozul
        kesim = -11.0 + 2.0 * pw
        if pw < 11:
            # kesik yuzu hafif kameraya donuk: tam yana bakarsa onden gorunmuyor
            res = bmesh.ops.bisect_plane(bm, geom=bm.verts[:] + bm.edges[:] + bm.faces[:],
                                         plane_co=(kesim, 0, 0), plane_no=(0.8, -0.6, 0.0), clear_outer=True)
            kenar = [e for e in res["geom_cut"] if isinstance(e, bmesh.types.BMEdge)]
            yeni = bmesh.ops.holes_fill(bm, edges=kenar, sides=0)
            for f in yeni["faces"]:
                f.material_index = 1
                f.smooth = False
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        ob = mesh_ob("patates", bm, Mk)
        ob.data.materials.append(Mi)
        for p in ob.data.polygons:
            if p.material_index == 1:
                p.use_smooth = False
        ob.location = (0, 6, ez(0, 6, K))
        Mg = px.flat("Goz", "#6d4d24")
        for gx, gy in ((-6, -2), (-2, 1.5), (3, -2.5), (7, 1)):
            if gx < kesim - 1:
                I.elipsoid("goz", gx, gy - 0.5, 0.7, 0.45, 0.4, 0.6, Mg, seg=8, ring=4)
    return fn


def patates_dilim():
    K = 0.5
    M = cel("Dilim", ["#c9b47a", "#e0cc92", "#f2e0a8", "#fff6d0"], [0, .3, .5, .75])
    onkutu("dilim", 0, 2, 0.5, 8, 0, 0.8, M, K)
    onkutu("kabuk", 0, 2, 7.2, 8, -0.05, 0.8, px.flat("DilimKabuk", "#7d5417"), K)


# ---------------------------------------------------------------- izgara
def izgara_govde(w=68, h=46):
    K = 0.5
    D = 40
    Mgov = cel("IzgGovde", ["#41474f", "#565d65", "#6f767e", "#a8b0b8"], [0, .3, .5, .8])
    Mkenar = cel("IzgKenar", ["#41474f", "#878e99", "#a8b0b8", "#c6ccd2"], [0, .3, .5, .8])
    Mic = cel("IzgIc", ["#14171b", "#1a1e23", "#20242a", "#2a2f36"], [0, .3, .5, .8])
    zt = ez(24, 0, K)       # govde ust yuzeyi (on kenar ekranda y+24)
    # on panel (dis cerceve mt3 + ic yuz)
    onkutu("on", 0, w, 24, h, 0, 1.5, cel("IzgDis", ["#41474f", "#5f6672", "#878e99", "#a8b0b8"], [0, .3, .5, .8]), K)
    onkutu("on_ic", 1, w - 1, 24.5, h - 1, -0.2, 1, Mgov, K)
    onkutu("on_sol", 1, 2, 24.5, h - 1, -0.3, 1, px.flat("IzgSolIsik", "#a8b0b8"), K)
    onkutu("on_sag", w - 2, w - 1, 24.5, h - 1, -0.3, 1, px.flat("IzgSagGolge", "#565d65"), K)
    # ust kenarlar (sol/sag 3 px, on 1, arka 2) -> ortasi ates haznesi
    L.kutu("ust_sol", 0, 3, zt - 22, zt, 0, D, Mkenar)
    L.kutu("ust_sag", w - 3, w, zt - 22, zt, 0, D, Mkenar)
    L.kutu("ust_on", 3, w - 3, zt - 22, zt, 0, 1, Mkenar)
    L.kutu("ust_arka", 3, w - 3, zt - 22, zt, D - 2, D, Mkenar)
    # hazne: koyu taban + arka ic duvar
    L.kutu("hazne_taban", 3, w - 3, zt - 7, zt - 6, 1, D - 2, Mic)
    L.kutu("hazne_arka", 3, w - 3, zt - 6, zt, D - 3, D - 2, cel("IzgArkaIc", ["#101216", "#171a1f", "#1c2026", "#262b31"], [0, .3, .5, .8]))
    # kapak: arkada dik duran levha (ekranda y-4..y+4) + alt kenar golgesi
    Mkap = cel("Kapak", ["#41474f", "#878e99", "#d3d8de", "#f2f4f6"], [0, .3, .5, .7])
    L.kutu("kapak", 1, w - 1, zt, zt + 8, D, D + 2, Mkap)
    L.kutu("kapak_cerceve_s", 1, 2, zt, zt + 8, D - 0.1, D + 2, px.flat("KapakKenar", "#878e99"))
    L.kutu("kapak_cerceve_g", w - 2, w - 1, zt, zt + 8, D - 0.1, D + 2, px.flat("KapakKenar2", "#878e99"))
    L.kutu("kapak_alt", 1, w - 1, zt, zt + 1, D - 0.15, D + 2, px.flat("KapakAlt", "#41474f"))
    L.kutu("kapak_isik", 2, w - 2, zt + 7.5, zt + 8, D - 0.12, D + 2, px.flat("KapakIsik", "#f2f4f6"))
    # kapak kolu
    Mkol = cel("Kol", ["#1c1c22", "#2a2a32", "#454e58", "#5f6a75"], [0, .3, .5, .8])
    L.kutu("kol", w / 2 - 7, w / 2 + 7, zt + 8, zt + 11.5, D - 2, D + 1.5, Mkol)
    L.kutu("kol_ayak1", w / 2 - 6, w / 2 - 4, zt + 7, zt + 8, D - 1, D + 1, Mkol)
    L.kutu("kol_ayak2", w / 2 + 4, w / 2 + 6, zt + 7, zt + 8, D - 1, D + 1, Mkol)
    # havlu cubugu + ayaklari
    Mcub = cel("Cubuk", ["#5f6672", "#727d88", "#8f9aa4", "#c6ccd2"], [0, .3, .55, .8])
    yr = -3.0
    L.silindir("ray", 1.0, w / 2.0, yr, ez(h - 8, yr, K), w - 12, Mcub, seg=12, eksen="X")
    for x0 in (5, w - 7):
        onkutu("ray_ayak", x0, x0 + 2, h - 10, h - 6, yr, 0, Mcub, K)
    # dugmeler
    Mdug = cel("Dugme", ["#262d34", "#3c4650", "#56626e", "#98a4b0"], [0, .3, .55, .8])
    for kx in (13, w - 13):
        L.silindir("dugme", 2.0, kx, -0.8, ez(h - 15, -0.8, K), 1.6, Mdug, seg=16, eksen="Y")
        onkutu("dugme_cizgi", kx - 0.25, kx + 0.25, h - 17, h - 15, -1.7, -1.5, px.flat("DugmeCizgi", "#c6ccd2"), K)
    # on panelde havalandirma yariklari (ince detay)
    Myar = px.flat("Yarik", "#565d65")
    for i in range(5):
        onkutu("yarik", w / 2 - 9 + i * 4, w / 2 - 7.5 + i * 4, 27, 31, -0.25, 0.5, Myar, K)


def izgara_cubuk(w=68, h=46):
    """Yuvarlak cubuklu izgara: korlar kodla bunun ALTINA cizilir."""
    K = 0.5
    zt = ez(24, 0, K)
    Mc = cel("IzgCubuk", ["#3d444c", "#525b64", "#727d88", "#98a4b0"], [0, .3, .55, .8])
    yb = 22.0
    zc = zt - 0.7
    i = 0
    while 4 * i < w - 8:
        L.silindir("cubuk", 0.75, 5 + 4 * i, yb / 2.0, zc, yb, Mc, seg=10, eksen="Y")
        i += 1
    Mr = cel("IzgRay", ["#3d444c", "#56606a", "#8f9aa4", "#b8c2cc"], [0, .3, .55, .8])
    L.silindir("on_ray", 0.7, w / 2.0, 0.8, zc - 0.3, w - 6, Mr, seg=10, eksen="X")
    L.silindir("arka_ray", 0.7, w / 2.0, yb, zc - 0.3, w - 6, Mr, seg=10, eksen="X")


# ---------------------------------------------------------------- kagit
def _kagit_malz():
    return cel("Kagit", ["#b9b3a2", "#d8d2c2", "#e8e4d6", "#f8f4e8"], [0, .25, .5, .75])


def kagit_aski(w=24):
    K = 0.25
    Mah = cel("Aski", ["#3a2210", "#4e2e17", "#6b4122", "#8a5730"], [0, .3, .5, .75], noise=0.05, noise_scale=20)
    onkutu("sol", 1, 4, 4, 32, 0, 3, Mah, K)
    onkutu("sag", w - 4, w - 1, 4, 32, 0, 3, Mah, K)
    onkutu("alt", 1, w - 1, 30, 33, -0.5, 3, Mah, K)
    Mcivi = px.flat("Civi", "#c9a45e")
    for x in (2.5, w - 2.5):
        onkutu("civi", x - 0.5, x + 0.5, 14.5, 15.5, -0.2, 0.5, Mcivi, K)
    # rulo: x ekseni boyunca silindir, sag ucu hafif kameraya donuk (sarim halkalari gorunsun)
    Mk = _kagit_malz()
    cx, cy, yr = w / 2.0, 15.0, 1.5
    L.silindir("rulo", 7.0, cx, yr, ez(cy, yr, K), 15.0, Mk, seg=32, eksen="X")
    # baski seritleri: rulonun on yuzunde, eksene paralel
    for ad, renk, a0, a1 in (("kirmizi", "#c8322b", 0.22, 0.46), ("mavi", "#2f5f9e", -0.40, -0.16)):
        bm = bmesh.new()
        seg = 6
        vs = []
        for j in range(seg + 1):
            a = a0 + (a1 - a0) * j / seg
            yy, zz = -math.cos(a) * 7.06, math.sin(a) * 7.06
            vs.append((bm.verts.new((-7.3, yy, zz)), bm.verts.new((6.2, yy, zz))))
        for j in range(seg):
            bm.faces.new((vs[j][0], vs[j][1], vs[j + 1][1], vs[j + 1][0]))
        ob = mesh_ob("serit_" + ad, bm, cel("Serit" + ad, [hexmul(renk, .6), hexmul(renk, .8), renk, hexmul(renk, 1.15)], [0, .25, .5, .75]))
        ob.location = (cx, yr, ez(cy, yr, K))
    # sag uc: sarim halkalari (art.js gibi 2 px'lik elips, on yuzde)
    kx = cx + 6.8
    yon = yr - 7.4
    for rx, ry, renk in ((1.6, 7.0, "#cfc9b8"), (1.4, 6.0, "#f8f4e8"), (1.1, 4.2, "#d6d0bf"), (0.9, 3.2, "#f2eee2"),
                         (0.6, 2.0, "#d6d0bf"), (0.45, 1.0, "#b8302a")):
        pts = [(kx + rx * math.cos(2 * math.pi * j / 20), cy + ry * math.sin(2 * math.pi * j / 20)) for j in range(20)]
        on_poligon("halka", pts, yon, px.flat("Halka%s%s" % (renk, rx), renk), K, derin=0.05)
        yon -= 0.05
    # sarkan yaprak: yirtik alt kenar
    Mp = _kagit_malz()
    sy0 = cy + 7
    pts = [(cx - 5, sy0), (cx + 5, sy0)]
    for z in range(10, -1, -1):
        pts.append((cx - 5 + z, sy0 + 8.2 + (0.9 if z % 3 == 1 else 0.0)))
    on_poligon("yaprak", pts, -6.2, Mp, K, derin=0.3)
    on_poligon("yaprak_serit", [(cx - 4, sy0 + 3), (cx + 3.5, sy0 + 3), (cx + 3.5, sy0 + 3.8), (cx - 4, sy0 + 3.8)],
               -6.3, px.flat("YaprakSerit", "#d8352c"), K, derin=0.05)
    on_poligon("yaprak_isik", [(cx - 5, sy0), (cx - 4.4, sy0), (cx - 4.4, sy0 + 8), (cx - 5, sy0 + 8)],
               -6.3, px.flat("YaprakIsik", "#ffffff"), K, derin=0.05)


def kagit_makine(w=24, h=46):
    K = 0.3
    mx, mw, my, mh = 1, w - 2, 8, h - 12
    Mgov = cel("MakGovde", ["#1a2026", "#2e363e", "#39424b", "#5f6672"], [0, .3, .5, .75])
    onkutu("govde", mx, mx + mw, my, my + mh - 1, 0, 4, Mgov, K)
    onkutu("sol_pah", mx, mx + 4, my, my + mh - 1, -0.3, 3, cel("MakPah", ["#39424b", "#4a525c", "#5f6672", "#7a828b"], [0, .3, .5, .75]), K)
    onkutu("sag_golge", mx + mw - 4, mx + mw, my, my + mh - 1, -0.1, 3, px.flat("MakSagGolge", "#2b323a"), K)
    Mkap = cel("MakKapak", ["#232a31", "#3d444c", "#5f6672", "#aeb5be"], [0, .3, .5, .75])
    onkutu("kapak", mx - 1, mx + mw + 1, my - 5, my + 1, -1, 3, Mkap, K)
    onkutu("kapak_isik", mx, mx + mw, my - 5, my - 4.5, -1.1, 3, px.flat("KapIsik", "#aeb5be"), K)
    # isik yuvasi (renk kodla)
    L.silindir("led_yuva", 1.6, mx + mw - 4, -1.15, ez(my - 3, -1.15, K), 0.3, px.flat("LedYuva", "#141a1f"), seg=12, eksen="Y")
    # pencere
    pnx, pny, pnw, pnh = mx + 2, my + 4, mw - 4, 16
    onkutu("pen_cerceve", pnx - 1, pnx + pnw + 1, pny - 1, pny + pnh + 1, -0.35, 0, px.flat("PenCerceve", "#141a1f"), K)
    onkutu("pen_ic", pnx, pnx + pnw, pny, pny + pnh, -0.4, 0, px.flat("PenIc", "#1c242b"), K)
    # uctan gorulen rulo
    rcx, rcy = pnx + pnw / 2.0, pny + pnh / 2.0
    Mk = _kagit_malz()
    L.silindir("rulo", 6.0, rcx, -0.9, ez(rcy, -0.9, K), 1.0, Mk, seg=32, eksen="Y")
    for rr, renk in ((5.0, "#ece8da"), (4.2, "#d9d4c5"), (3.7, "#f5f1e5"), (2.2, "#d9d4c5"), (1.7, "#f8f4e8"), (0.9, "#b8302a")):
        L.silindir("halka", rr, rcx, -1.45 - (6 - rr) * 0.01, ez(rcy, -1.45, K), 0.1, px.flat("RH%s" % renk, renk), seg=28, eksen="Y")
    onkutu("parilti", pnx + 1, pnx + 2.5, pny + 1, pny + pnh - 2, -1.6, -1.55, px.flat_a("Parilti", "#ffffff", 0.16), K)
    # cikis agzi + disli bicak
    kby = my + mh - 11
    onkutu("agiz", mx + 1, mx + mw - 1, kby, kby + 3, -1.4, 0, cel("Agiz", ["#141a1f", "#232a31", "#39424b", "#878e99"], [0, .3, .5, .75]), K)
    onkutu("agiz_isik", mx + 1, mx + mw - 1, kby, kby + 0.5, -1.45, 0, px.flat("AgizIsik", "#878e99"), K)
    Mdis = px.flat("Dis", "#d3d8de")
    d = 0
    while d < mw - 3:
        onkutu("dis", mx + 2 + d, mx + 3 + d, kby + 3, kby + 3.8, -1.4, -1.0, Mdis, K)
        d += 2


def kagit_oto(w=24):
    K = 0.3
    mx, mw, my = 1, w - 2, 8
    Mk = cel("Motor", ["#232a31", "#3d444c", "#5f6672", "#aeb5be"], [0, .3, .5, .75])
    onkutu("motor", mx + 2, mx + 11, my - 11, my - 5, 0, 2.5, Mk, K)
    onkutu("motor_isik", mx + 3, mx + 10, my - 11, my - 10.5, -0.1, 2.5, px.flat("MotorIsik", "#aeb5be"), K)
    for i in range(3):
        onkutu("motor_yarik", mx + 4 + i * 2, mx + 5 + i * 2, my - 9, my - 6.5, -0.15, 0.5, px.flat("MotorYarik", "#232a31"), K)
    onkutu("fan", mx + mw - 8, mx + mw - 2, my - 10, my - 5, 0, 2.5, cel("Fan", ["#141a1f", "#1c2228", "#232a31", "#3d444c"], [0, .3, .5, .75]), K)
    L.silindir("fan_ic", 2.0, mx + mw - 5, -0.2, ez(my - 8, -0.2, K), 0.3, px.flat("FanIc", "#878e99"), seg=16, eksen="Y")


# ---------------------------------------------------------------- sos
SOS = [{"id": "hot", "c0": "#8e1c14", "c1": "#e2382a", "c2": "#ff7a62", "cap": "#3a2a24"},
       {"id": "garlic", "c0": "#bdb6a2", "c1": "#f6f2e6", "c2": "#ffffff", "cap": "#6f7a84"},
       {"id": "butter", "c0": "#a8700f", "c1": "#f0b53c", "c2": "#ffd77a", "cap": "#7a4f16"}]
BOY = [{"w": 11, "gov": 17, "omuz": 5, "boyun": 3}, {"w": 14, "gov": 12, "omuz": 4, "boyun": 3},
       {"w": 12, "gov": 15, "omuz": 5, "boyun": 3}]


def sos_raf(w=48):
    K = 0.4
    Mr = cel("Raf", ["#4a3016", "#5e3f1e", "#8a5f2e", "#b98246"], [0, .3, .5, .8], noise=0.06, noise_scale=18)
    onkutu("raf", 0, w, 35, 41, 0, 2.5, Mr, K)
    onkutu("raf_alt", 0, w, 40, 41, -0.1, 2.5, px.flat("RafAlt", "#5e3f1e"), K)
    Mc = px.flat("RafCizgi", "#7a5228")
    v = 4
    while v < w - 3:
        onkutu("cizgi", v, v + 0.5, 35.5, 40, -0.15, 0.5, Mc, K)
        v += 8


def sise(i):
    def fn():
        K = 0.3
        S, d = BOY[i], SOS[i]
        hw = S["w"] / 2.0
        gov, omuz, boyun = S["gov"], S["omuz"], S["boyun"]
        dolu = 0.55 + i * 0.15
        dz = max(2, int(math.floor((gov - 2) * dolu + 0.5)))
        der = 0.55
        ym = 2.5
        koy = hexmul(d["c1"], 0.56)
        # govde (bos kismi koyu: yari saydam plastik)
        profil = [(hw - 0.4, 0), (hw, 0.6), (hw, gov - 0.5), (hw - 0.6, gov)]
        for k in range(1, omuz + 1):
            profil.append((max(3.0, hw - (hw - 3.0) * k / omuz), gov + k))
        profil += [(3.0, gov + omuz + boyun)]
        torna("govde", profil, 0, 0, ym, der, cel("Sise%d" % i, [hexmul(d["c0"], .8), d["c0"], koy, hexmul(koy, 1.35)], [0, .3, .5, .8]), K)
        # icindeki sos: seviyeye kadar biraz daha genis kabuk
        torna("sos", [(hw + 0.06, 0.6), (hw + 0.06, dz)], 0, 0, ym, der,
              cel("Sos%d" % i, [d["c0"], hexmul(d["c1"], .85), d["c1"], d["c2"]], [0, .3, .5, .8]), K, kapak=False)
        torna("sos_ust", [(hw + 0.08, dz - 0.5), (hw + 0.08, dz)], 0, 0, ym, der, px.flat("SosUst%d" % i, d["c2"]), K, kapak=False)
        # kapak
        cap = d["cap"]
        z0 = gov + omuz + boyun
        torna("kapak_halka", [(4.0, z0), (4.0, z0 + 2)], 0, 0, ym, der, cel("KapH%d" % i, [hexmul(cap, .5), hexmul(cap, .72), hexmul(cap, .9), cap], [0, .3, .5, .8]), K)
        torna("kapak", [(3.0, z0 + 2), (3.0, z0 + 5.6), (2.6, z0 + 6)], 0, 0, ym, der, cel("Kap%d" % i, [hexmul(cap, .6), cap, hexmul(cap, 1.25), hexmul(cap, 1.55)], [0, .3, .5, .8]), K)
        torna("uc", [(1.0, z0 + 6), (0.8, z0 + 8), (0.3, z0 + 8.4)], 0, 0, ym, der, px.flat("Uc%d" % i, hexmul(cap, 1.25)), K)
        # etiket: govdeye sarili bant
        eh = 9 if gov > 14 else 7
        e_alt = gov - 3 - eh
        torna("etiket", [(hw + 0.14, e_alt), (hw + 0.14, e_alt + eh)], 0, 0, ym, der,
              cel("Etiket%d" % i, ["#b9b19c", "#cfc7b2", "#f4efe0", "#ffffff"], [0, .3, .5, .8]), K, kapak=False)
        # etiket ikonu: etiketin on yuzunde
        yon = ym - hw * der - 0.3
        lcy = -(e_alt + eh / 2.0)          # ekranda ikon merkezi (taban 0)
        if i == 0:
            b = I.elipsoid("biber", 0, lcy, 2.8, 1.8, 0.6, yon, cel("Biber", ["#8e1c14", "#c02a20", "#e2382a", "#ff7a62"], [0, .3, .5, .8]), seg=12, ring=6)
            b.location.z = ez(lcy, yon, K)
            b.rotation_euler = (0, math.radians(-18), 0)
            s = I.elipsoid("sap", 2.6, lcy - 1.8, 0.9, 0.5, 0.3, yon - 0.3, px.flat("Sap", "#5a8a2a"), seg=8, ring=4)
            s.location.z = ez(lcy - 1.8, yon - 0.3, K)
        elif i == 1:
            b = I.elipsoid("sarimsak", 0, lcy + 0.4, 2.8, 2.6, 0.6, yon, cel("Sarimsak", ["#a89a78", "#cfc7b2", "#f4f0e4", "#ffffff"], [0, .3, .5, .8]), seg=12, ring=6)
            b.location.z = ez(lcy + 0.4, yon, K)
            for dx in (-1.0, 1.0):
                onkutu("dilim", dx - 0.2, dx + 0.2, -lcy - 1.5, -lcy + 2.2, yon - 0.7, yon - 0.5, px.flat("SarimsakCizgi", "#cfc7b2"), K)
            s = I.elipsoid("sarimsak_uc", 0, lcy - 2.6, 0.5, 0.9, 0.3, yon - 0.2, px.flat("SarimsakUc", "#a89a78"), seg=8, ring=4)
            s.location.z = ez(lcy - 2.6, yon - 0.2, K)
        else:
            Mt = cel("Tereyag", ["#c98a1a", "#e0a02a", "#f0b53c", "#ffd77a"], [0, .3, .5, .8])
            onkutu("tereyag", -3, 3.5, -lcy - 2, -lcy + 2.5, yon - 1.0, yon, Mt, K)
            onkutu("tereyag_ust", -3, 3.5, -lcy - 2, -lcy - 1.5, yon - 1.1, yon, px.flat("TereyagIsik", "#ffd77a"), K)
    return fn


# ---------------------------------------------------------------- patates kutusu rafi
def kutu_raf(w=38):
    K = 0.4
    ry = 5
    M = cel("KutuRaf", ["#6e757d", "#8e959d", "#a8b0b8", "#c6ccd2"], [0, .3, .5, .8])
    onkutu("raf", 1, w - 1, ry + 11, ry + 13, 0, 3, M, K)
    onkutu("raf_isik", 1, w - 1, ry + 11, ry + 11.5, -0.05, 3, px.flat("RafIsik", "#c6ccd2"), K)


def kutu_bos(w=38):
    """Raftaki bos patates kutulari (oyunda %74 opaklikla cizilir)."""
    K = 0.4
    ry = 5
    Mk = cel("KutuKirmizi", ["#6e1510", "#8e1c14", "#c02a20", "#d8382a"], [0, .3, .5, .8])
    Mic = px.flat("KutuIc", "#5e120d")
    Mb = cel("KutuBant", ["#c9a030", "#e0bb3c", "#f7d34a", "#ffe98e"], [0, .3, .5, .8])
    for i in range(3):
        bx = 4 + i * 7
        by = ry + 2 - (i % 2)
        yy = 2.0 - i * 0.9
        cx = bx + 4.5
        taban = by + 9
        profil = [(3.0, 0), (4.5, 9)]
        torna("kutu", profil, cx, taban, yy, 0.45, Mk, K, kapak=False)
        torna("kutu_taban", [(3.0, 0), (3.0, 0.4)], cx, taban, yy, 0.45, Mk, K)
        # agiz: ic koyu elips
        torna("agiz", [(4.2, 8.7), (4.2, 8.9)], cx, taban, yy, 0.45, Mic, K)
        # on yuzde sari bant (M harfi yerine sade bant)
        onkutu("bant", bx + 2, bx + 7, by + 3, by + 5, yy - 4.5 * 0.45 - 0.35, yy - 1.0, Mb, K)


parca("tahta", (0, 4, 94, 42), tahta, K=0.5)
parca("kesme_tahta", (0, 2, 48, 42), kesme_tahta, K=0.5)
parca("kesme_kap", (29, 20, 19, 22), kesme_kap, K=0.5, cizgi="#41474f", cizgi_alfa=150)
parca("cig_cubuk", (-1, -1, 4, 7), cig_cubuk, K=0.5)
for _pw in range(2, 12):
    parca("patates_%d" % _pw, (-13, -9, 28, 17), patates_n(_pw), K=0.5, cizgi="#4d3418", cizgi_alfa=140)
parca("patates_dilim", (-1, -1, 4, 10), patates_dilim, K=0.5)
parca("izgara_govde", (-2, -12, 72, 60), izgara_govde, K=0.5)
parca("izgara_cubuk", (0, 10, 68, 16), izgara_cubuk, K=0.5)
parca("kagit_aski", (-1, 0, 26, 36), kagit_aski, K=0.25)
parca("kagit_makine", (-1, 0, 26, 44), kagit_makine, K=0.3)
parca("kagit_oto", (-1, -6, 26, 12), kagit_oto, K=0.3)
parca("sos_raf", (-1, 30, 50, 14), sos_raf, K=0.4)
for _i in range(3):
    _t = BOY[_i]["gov"] + BOY[_i]["omuz"] + BOY[_i]["boyun"] + 9
    parca("sise_%d" % _i, (-10, -(_t + 1), 20, _t + 4), sise(_i), K=0.3, cizgi=hexmul(SOS[_i]["c0"], .6), cizgi_alfa=150)
parca("kutu_raf", (0, 12, 38, 8), kutu_raf, K=0.4)
parca("kutu_bos", (0, 2, 30, 16), kutu_bos, K=0.4)


def uret(ad):
    (gx0, gy0, w, h), fn, K, cizgi, cizgi_alfa = PARCALAR[ad]
    I.sahne(gx0, gy0, w, h)
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
    print("TEZGAH_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
