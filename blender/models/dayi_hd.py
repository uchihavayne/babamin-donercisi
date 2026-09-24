"""DAYI (USTA) — HD katmanlari, 2. model (birlesik surum, 3. tur).

    blender --background --factory-startup --python blender/models/dayi_hd.py [-- katman_adi]
    DAYI_OLCEK=0.82 blender ... (servis bolmesindeki 0.82 olcek, atlas dayi82)

Kullanici: "dayi hic olmamis". Ilk model ilkel sekillerden (kure kafa, silindir
govde, boru kollar, dikdortgen gozler) yapilmis bir kurdele askeri oyuncagina
benziyordu. Bu model:
  kafa   : yumurta yuz (dolgun cene + yanaklar), kulaklar, fesin altindan
           dalgali beyaz sac tutamlari
  yuz    : kapakli badem gozler (bebek + isik), gur beyaz kaslar, etli burun
           (kanatlar + kemer), uclari kivrik beyaz pala biyik, dudak
  fes    : konik keçe fes, tepe dugmesi, kordonlu puskul (sallanir)
  govde  : egimli omuz + gobekli gomlek (patlet + dugmeler), onu acik bordo
           yelek (altin sirma kenar + kivrimli isleme), cizgili kusak + dugum
  bacak  : kivrimli lacivert salvar, bilek buzgusu, yemeni
  kollar : kabarik gomlek yeni, manset, parmakli el
Katman adlari, tuval ve capa noktalari ilk modelle AYNI: oyun kodu degismez.

Oyundaki karsiligi: js/chars.js drawChef(x, y, st, t) -> remake_gorsel f_dayiHD.
  kafa merkezi (23, 30)   fes ustu gy~3   omuz ustu gy=50   ayak ~gy=150
Cikti: blender/out/dayi_hd/<katman>.png — hepsi AYNI tuvalde, 2x HD.
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

P = pal.P
HD = 2
TUVAL = (-12, -8, 74, 168)          # gx0, gy0, w, h (mantik pikseli)
OLCEK = float(os.environ.get("DAYI_OLCEK", "1"))
if abs(OLCEK - 1.0) > 1e-6:
    OUT = os.path.join(_HERE, "out", "dayi%d_hd" % int(round(OLCEK * 100)))
    TUVAL = (-12, -8, 75, 175)
else:
    OUT = os.path.join(_HERE, "out", "dayi_hd")

# ---------------------------------------------------------------- renkler
SKIN = ["#95603c", "#c68658", "#e9b186", "#fbd2a8"]
GOMLEK = ["#9c927c", "#d0c8b2", "#ece6d6", "#faf6ec"]
YELEK = ["#4e1010", "#7e1c1a", "#a82a24", "#c84234"]
ALTIN = [P["au3"], P["au2"], P["au1"], P["au0"]]
KUSAK = ["#3c1410", "#62211a", "#86301f", "#a8452a"]
KUSAK2 = ["#5a4410", "#8a6a1c", "#b88e2a", "#d8b04a"]
SALVAR = ["#161d2e", "#232e48", "#344468", "#4c6090"]
LASTIK = ["#101624", "#1c2438", "#2c3a58", "#44567e"]
CIZME = ["#241208", "#42220f", "#63361a", "#86502a"]
AK = ["#a8a49c", "#cfccc5", "#ebeae5", "#ffffff"]
FES = [P["red3"], P["red2"], P["red1"], P["red0"]]
FES_UST = ["#96271c", "#b8352a", "#cc4434", "#e05a48"]
PUSKUL = ["#140e0a", "#241a14", "#3a2c22", "#54402e"]
DUDAK = ["#6a2a22", "#8e3c30", "#a85444", "#c06a58"]
STOPS = [0.0, 0.34, 0.62, 0.86]
EK = ["#ffffff", "#2b1a12", "#1a120c", "#f6efe2", "#5a2c22", "#7a3a30", "#c9584a", "#e07a68", "#fff0dc",
      "#3a2418", "#d9cfc0", "#6e6a62"]
# BIRLESIK (6. tur, madde 6): ince belli bardakta demli cay (yudum jesti)
CAY = ["#3e0e04", "#6a1c08", "#96300c", "#c24e18"]
CAM = ["#8a9ea4", "#c4d6da", "#e6f0f2", "#ffffff"]
IZINLI = sorted(set(sum([SKIN, GOMLEK, YELEK, ALTIN, KUSAK, KUSAK2, SALVAR, LASTIK, CIZME, AK, FES, FES_UST,
                         PUSKUL, DUDAK, CAY, CAM], []) + EK))


def sahne():
    L._FONTLAR.clear()
    px.reset()
    gx0, gy0, w, h = TUVAL
    px.setup(int(round(w * HD * OLCEK)), int(round(h * HD * OLCEK)))
    px.ortho_cam(gx0 + w / 2.0, -(gy0 + h / 2.0), w, h)
    px.world("#000000", 0.0)
    # isik: onden, ustten, soldan (oyunun cizimlerinde acik taraf sol-ust)
    d = Vector((0.45, 0.80, -0.40)).normalized()
    s = px.sun(math.pi, rot=(0, 0, 0))
    s.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def cel(ad, ramp, stops=None, noise=0.0, noise_scale=8.0):
    return px.cel(ad, ramp, stops or STOPS, noise=noise, noise_scale=noise_scale)


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
    """(gx, gy) a -> b arasi koni/silindir (derinlik sabit)."""
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
    v = Vector((bx - ax, 0, -(by - ay))).normalized()
    ob.rotation_euler = v.to_track_quat("Z", "Y").to_euler()
    ob.location = ((ax + bx) / 2.0, derin, -(ay + by) / 2.0)
    me.materials.append(mat)
    return ob


def egri_tup(ad, noktalar, yaricap, mat, res=3):
    """(gx, gy, derin) noktalarindan gecen yumusak tup; her noktada ayri yaricap."""
    cu = bpy.data.curves.new(ad, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = 1.0
    cu.bevel_resolution = res
    cu.use_fill_caps = True
    sp = cu.splines.new("BEZIER")
    sp.bezier_points.add(len(noktalar) - 1)
    for q, (gx, gy, d) in enumerate(noktalar):
        bp = sp.bezier_points[q]
        bp.co = (gx, d, -gy)
        bp.handle_left_type = bp.handle_right_type = "AUTO"
        bp.radius = yaricap[q] if isinstance(yaricap, (list, tuple)) else yaricap
    ob = link(bpy.data.objects.new(ad, cu))
    cu.materials.append(mat)
    return L.meshle(ob, mat)


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
    return L.kutu(ad, gx0, gx1, -gy1, -gy0, derin - kalin / 2.0, derin + kalin / 2.0, mat)


def _elips_on(gx, gy, cx, cy, rx, rz, ry, d0=0.0):
    k = 1 - ((gx - cx) / rx) ** 2 - ((gy - cy) / rz) ** 2
    return d0 - ry * math.sqrt(k) if k > 0 else None


def yuz_on(gx, gy):
    """Yuzun (kafa + cene) on yuzeyinin derinligi."""
    ds = [d for d in (_elips_on(gx, gy, 23, 29.5, 14.2, 14.2, 12.6),
                      _elips_on(gx, gy, 23, 36.5, 13.4, 8.5, 11.8)) if d is not None]
    return (min(ds) if ds else 0.0) - 0.2


# eski ad (kol jestleri vb. kullaniyor)
kafa_on = yuz_on


# ---------------------------------------------------------------- bacak (salvar)
def bacak():
    M = cel("Salvar", SALVAR)
    MD = px.flat("SalvarKivrim", SALVAR[0])
    by = 50
    ust, alt = by + 58, by + 96
    orta = 23.5

    def g_ust(u):
        return 44.0 + 5.0 * math.sin(u * math.pi * 0.95)
    dikey_profil("salvar_ust", ust, ust + 22, g_ust, 0.64, lambda u: orta, 0, M, seg=40, satir=16)
    paca = {}
    for yon in (-1, 1):
        def g2(u):
            return 24.0 - 10.5 * u ** 1.2

        def c2(u, yon=yon):
            return orta + yon * (11.2 + 0.6 * u)
        dikey_profil("paca%d" % yon, ust + 17, alt - 3, g2, 0.86, c2, 0, M, seg=32, satir=16)
        paca[yon] = (g2, c2)
    # dikey kivrimlar: bol kumasin katlari (on yuzeyde ince koyu egriler)
    for yon in (-1, 1):
        g2, c2 = paca[yon]
        for j, off in enumerate((-0.45, 0.05, 0.5)):
            nok = []
            for q in range(6):
                u = 0.1 + q / 5.0 * 0.8
                gy = ust + 17 + (alt - 3 - ust - 17) * u
                hw = g2(u) / 2.0
                x = c2(u) + off * hw + math.sin(u * 5 + j + yon) * 0.8
                rel = (x - c2(u)) / hw
                d = -hw * 0.86 * math.sqrt(max(0.0, 1 - rel * rel)) - 0.15
                nok.append((x, gy, d))
            egri_tup("kivrim%d_%d" % (yon, j), nok, [0.22, 0.34, 0.38, 0.36, 0.3, 0.18], MD)
    for j, off in enumerate((-0.2, 0.25)):
        nok = []
        for q in range(5):
            u = 0.15 + q / 4.0 * 0.7
            gy = ust + 22 * u
            hw = g_ust(u) / 2.0
            x = orta + off * hw + math.sin(u * 4 + j) * 0.7
            rel = (x - orta) / hw
            nok.append((x, gy, -hw * 0.64 * math.sqrt(max(0.0, 1 - rel * rel)) - 0.15))
        egri_tup("kivrim_ust%d" % j, nok, [0.2, 0.32, 0.34, 0.3, 0.2], MD)
    # bilek buzgusu + yemeni (ucu hafif sivri, kalkik)
    ML = cel("Lastik", LASTIK)
    MC = cel("Yemeni", CIZME)
    for yon in (-1, 1):
        cx = orta + yon * 12.0
        L.silindir("lastik", 6.2, cx, 0, -(alt - 2.5), 3.4, ML, seg=24)
        elipsoid("yemeni", cx + yon * 0.8, by + 98.0, 8.6, 3.6, 7.0, -1.0, MC, seg=28, ring=14)
        tup("burun", (cx + yon * 6.5, by + 98.4), (cx + yon * 10.4, by + 96.6), 2.2, -2.5, MC, r_b=0.5, seg=14)
        elipsoid("taban", cx + yon * 0.8, by + 100.6, 8.8, 1.0, 7.2, -1.0, px.flat("Taban", "#241208"), seg=24, ring=8)


# ---------------------------------------------------------------- govde
def gomlek_gen(gy_rel):
    """Gomlek genisligi (by'ye gore gy): egimli omuz -> dolgun gobek -> bel."""
    g = gy_rel
    if g < 7.0:
        return 21.0 + (g + 2.0) / 9.0 * 17.0
    if g < 20.0:
        return 38.0 + (g - 7.0) / 13.0 * 1.5
    if g < 44.0:
        return 39.5 + 8.0 * math.sin((g - 20.0) / 24.0 * math.pi / 2)
    return 47.5 - (g - 44.0) / 18.0 * 2.5


def govde_on(gx, gy, by=50):
    """Gomlek + gobek on yuzeyi derinligi."""
    hw = gomlek_gen(gy - by) / 2.0
    rel = (gx - 23.5) / hw
    d = -hw * 0.56 * math.sqrt(max(0.0, 1 - rel * rel))
    b = _elips_on(gx, gy, 23.5, by + 40, 15.0, 15.5, 15.0, -2.8)
    return min(d, b) if b is not None else d


def govde():
    MG = cel("Gomlek", GOMLEK)
    MY = cel("Yelek", YELEK, noise=0.05, noise_scale=14)
    MA = cel("Altin", ALTIN)
    MK = cel("Kusak", KUSAK)
    MK2 = cel("Kusak2", KUSAK2)
    by = 50
    # gomlek: egimli omuz, gobege dogru genisleyen; one tasan gobek
    dikey_profil("gomlek", by - 2, by + 62, lambda u: gomlek_gen(-2 + 64 * u), 0.56, lambda u: 23.5, 0, MG,
                 seg=44, satir=32)
    elipsoid("gobek", 23.5, by + 40, 15.0, 15.5, 15.0, -2.8, MG, seg=36, ring=22)
    # patlet + dugmeler
    Mp = cel("Patlet", [GOMLEK[0], GOMLEK[1], GOMLEK[1], GOMLEK[2]])
    nok = [(23.5, by + g, govde_on(23.5, by + g) - 0.15) for g in (0, 10, 20, 30, 40, 50)]
    egri_tup("patlet", nok, 0.9, Mp)
    for g in (6, 18, 30, 42):
        elipsoid("dugme", 23.5, by + g, 0.8, 0.8, 0.5, govde_on(23.5, by + g) - 1.0,
                 px.flat("GomlekDugme", "#d9cfc0"), seg=10, ring=6)
    # gobek kivrimlari (gomlegin gerildigi yerler)
    MKr = px.flat("GomlekKivrim", GOMLEK[0])
    for yon in (-1, 1):
        nok = []
        for q in range(4):
            u = q / 3.0
            gx = 23.5 + yon * (6 + u * 7)
            gy = by + 44 + u * 5 - 3 * math.sin(u * math.pi)
            nok.append((gx, gy, govde_on(gx, gy) - 0.1))
        egri_tup("kivrim%d" % yon, nok, [0.15, 0.3, 0.3, 0.12], MKr)
    # YELEK: govdeden biraz genis kabuk, onu acik (asagi dogru genisleyen V)
    def acik(gy_rel):
        return 5.2 + max(0.0, gy_rel - 2) / 52.0 * 8.8

    def y_gen(u):
        g = -1.5 + 55.5 * u
        return gomlek_gen(g) + 2.2 - (2.0 * (g - 46) / 8 if g > 46 else 0.0)
    kabuk = dikey_profil("yelek", by - 1.5, by + 54, y_gen, 0.6, lambda u: 23.5, 0, MY, seg=48, satir=38)
    bm = bmesh.new()
    bm.from_mesh(kabuk.data)
    sil = [f for f in bm.faces if f.calc_center_median().y < 0
           and abs(f.calc_center_median().x - 23.5) < acik(-f.calc_center_median().z - by)]
    bmesh.ops.delete(bm, geom=sil, context="FACES")
    bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.6)
    bm.to_mesh(kabuk.data)
    bm.free()

    def yelek_on(gx, gy):
        u = (gy - by + 1.5) / 55.5
        hw = y_gen(min(1.0, max(0.0, u))) / 2.0
        rel = (gx - 23.5) / hw
        return -hw * 0.6 * math.sqrt(max(0.0, 1 - rel * rel)) - 0.7
    # altin sirma: on kenarlar + etek
    for yon in (-1, 1):
        nok = []
        for g in (-1.0, 8, 18, 28, 38, 47, 53):
            gx = 23.5 + yon * (acik(g) + 0.4)
            nok.append((gx, by + g, yelek_on(gx, by + g) - 0.2))
        egri_tup("sirma%d" % yon, nok, 0.75, MA)
        # yaka arkasi: iki on kenar ensede birlesir
        nok = [(23.5 + yon * (acik(-1) + 0.4), by - 1.0, yelek_on(23.5 + yon * (acik(-1) + 0.4), by - 1.0) - 0.2),
               (23.5 + yon * 8.5, by - 1.6, -3.0), (23.5 + yon * 10.5, by - 0.8, -1.0)]
        egri_tup("sirma_yaka%d" % yon, nok, 0.7, MA)
        nok = []
        for q in range(7):
            u = q / 6.0
            gx = 23.5 + yon * (acik(53) + 0.4 + u * 10.5)
            gy = by + 53.2 - 1.2 * u
            nok.append((gx, gy, yelek_on(gx, gy) - 0.2))
        egri_tup("etek%d" % yon, nok, 0.7, MA)
    # isleme: gogus ve kalcada kivrimli altin motif (spiral + yaprak)
    Mi = cel("Isleme", ALTIN)
    for yon in (-1, 1):
        for (mx, my, s) in ((23.5 + yon * 14.5, by + 14, 1.0), (23.5 + yon * 16.5, by + 38, 1.15)):
            nok = []
            for q in range(10):
                a = q / 9.0 * math.pi * 2.3
                r = (0.6 + q * 0.42) * s
                gx = mx + yon * math.cos(a) * r
                gy = my + math.sin(a) * r * 0.9
                nok.append((gx, gy, yelek_on(gx, gy) - 0.15))
            egri_tup("spiral", nok, 0.36, Mi)
            for q, (dx, dy, aci) in enumerate(((-3.5, -3.2, 0.8), (3.2, -3.6, -0.6), (0.5, 4.2, 0.1))):
                gx, gy = mx + yon * dx * s, my + dy * s
                e = elipsoid("yaprak", gx, gy, 1.5 * s, 0.7 * s, 0.35, yelek_on(gx, gy) - 0.1, Mi, seg=10, ring=6)
                e.rotation_euler = (0, aci * yon, 0)
    # KUSAK: bele sarili, katli kumas + iki ince altin cizgi; yanda dugum + sarkan uclar
    ky, kh = by + 52, 12.0
    dikey_profil("kusak", ky, ky + kh, lambda u: 49.0 - 1.5 * u + 0.5 * math.sin(u * 9), 0.64,
                 lambda u: 23.5, -0.3, MK, seg=48, satir=12)
    for q, sy in enumerate((ky + 3.2, ky + 8.2)):
        dikey_profil("kusak_serit%d" % q, sy, sy + 1.2, lambda u: 49.4 - 0.9 * q, 0.645, lambda u: 23.5, -0.35, MK2, satir=1)
    for q, sy in enumerate((ky + 5.6, ky + 10.4)):
        dikey_profil("kusak_kat%d" % q, sy, sy + 0.5, lambda u: 49.1 - 0.9 * q, 0.643, lambda u: 23.5, -0.33,
                     px.flat("KusakKat", KUSAK[0]), satir=1)
    elipsoid("dugum", 36.0, ky + 5.5, 4.2, 4.4, 3.0, -15.0, MK, seg=20, ring=12)
    for q, (x0, x1, uz) in enumerate(((34.8, 33.4, 13.0), (38.4, 40.2, 11.0))):
        egri_tup("sarkan%d" % q, [(x0, ky + 7.5, -15.6), ((x0 + x1) / 2, ky + 7.5 + uz * 0.5, -15.2),
                                  (x1, ky + 7.5 + uz, -14.6)], [1.9, 1.7, 1.5], MK)
        elipsoid("puskulcuk%d" % q, x1, ky + 8.4 + uz, 1.4, 1.1, 1.1, -14.4, MK2, seg=10, ring=6)


# ---------------------------------------------------------------- kollar
def kol(ad, omuz, el, derin=-2.0, yen_r=4.3, mat_yen=None, mat_ten=None, manset=True, omuz_kapak=False):
    """Omuzdan ele kabarik gomlek yeni (omuzda dar, dirsekte bol, bilekte
    buzgulu) + manset + el."""
    MG = mat_yen or cel("Yen", GOMLEK)
    MS = mat_ten or cel("Ten", SKIN)
    ox, oy = omuz
    ex, ey = el
    uz = math.hypot(ex - ox, ey - oy)
    if uz > 0.5:
        k = max(0.0, (uz - 3.6) / uz)
        mx, my = ox + (ex - ox) * k, oy + (ey - oy) * k
        dx_, dy_ = (ex - ox) / uz, (ey - oy) / uz
        nx_, ny_ = -dy_, dx_
        yan = 1.0 if ox >= 23.5 else -1.0
        if nx_ * yan + ny_ * 0.3 < 0:
            nx_, ny_ = -nx_, -ny_
        orta = (ox + (mx - ox) * 0.55 + nx_ * 0.9, oy + (my - oy) * 0.55 + ny_ * 0.9)
        r_o = yen_r * 1.2
        tup(ad + "_yen", (ox, oy), orta, yen_r * 0.95, derin, MG, r_b=r_o)
        tup(ad + "_yen2", orta, (mx, my), r_o, derin, MG, r_b=yen_r * 0.78)
        elipsoid(ad + "_dirsek", orta[0], orta[1], r_o, r_o, r_o, derin, MG, seg=18, ring=12)
        elipsoid(ad + "_omuz", ox, oy, yen_r + 0.5, yen_r, yen_r, derin, MG, seg=16, ring=10)
        # kabarik yenin kivrimi: dirsek ile bilek arasinda iki yumusak katlanma
        MKr = px.flat("YenKat", GOMLEK[1])
        for q, t in enumerate((0.35, 0.7)):
            cx = orta[0] + (mx - orta[0]) * t
            cy = orta[1] + (my - orta[1]) * t
            rr = r_o + (yen_r * 0.78 - r_o) * t
            egri_tup(ad + "_kat%d" % q, [(cx - nx_ * rr * 0.9 + dx_ * 0.3, cy - ny_ * rr * 0.9 + dy_ * 0.3, derin - rr * 0.5),
                                         (cx - dx_ * 0.4, cy - dy_ * 0.4, derin - rr - 0.05),
                                         (cx + nx_ * rr * 0.8 + dx_ * 0.5, cy + ny_ * rr * 0.8 + dy_ * 0.5, derin - rr * 0.5)],
                     [0.12, 0.26, 0.12], MKr)
        if not manset:
            tup(ad + "_onkol", (mx, my), (ex, ey), yen_r * 0.62, derin - 0.2, MS, r_b=yen_r * 0.55)
        if manset:
            MM = cel("Manset", ["#8a7e66", "#c9c1ac", "#ddd6c4", "#efe9da"])
            m2 = min(1.0, k + 1.8 / max(uz, .1))
            tup(ad + "_manset", (mx, my), (ox + (ex - ox) * m2, oy + (ey - oy) * m2), yen_r * 0.78 + 0.3, derin, MM)
    el_ciz(ad + "_el", (ex, ey), (ex - ox, ey - oy), derin - 0.5, MS)
    if omuz_kapak:
        yelek_omuz(ox, oy, derin)


def yelek_omuz(ox, oy, derin):
    """Yelegin omzu: yenin ustunu orten bordo kapak + kol agzinda altin sirma."""
    yan = 1.0 if ox >= 23.5 else -1.0
    MY = cel("YelekOmuz", YELEK, noise=0.05, noise_scale=14)
    MA = cel("OmuzSirma", ALTIN)
    cx, cy = ox - yan * 1.2, oy - 2.2
    elipsoid("yelek_omuz", cx, cy, 5.4, 4.6, 5.6, derin - 0.6, MY, seg=24, ring=14)
    nok = []
    for q in range(7):
        a = math.pi * (0.1 + 0.8 * q / 6.0)
        gx = cx + math.cos(a) * 5.5 * (-yan)
        gy = cy + math.sin(a) * 4.7
        nok.append((gx, gy, derin - 0.6 - 5.2 * math.sin(a) * 0.9))
    egri_tup("omuz_sirma", nok, 0.6, MA)


def el_ciz(ad, bilek, yon, derin, MS, sol=None):
    """Avuc + dort parmak + basparmak. bilek (gx, gy); yon: koldan ele."""
    bx, by = bilek
    L_ = math.hypot(yon[0], yon[1]) or 1.0
    dx, dy = yon[0] / L_, yon[1] / L_
    nx, ny = -dy, dx
    aci = math.atan2(dx, -dy)
    px_, py_ = bx + dx * 1.8, by + dy * 1.8
    ob = elipsoid(ad + "_avuc", px_, py_, 3.9, 3.6, 2.5, derin, MS, seg=20, ring=12)
    ob.rotation_euler = (0, aci, 0)
    tup(ad + "_bilek", (bx - dx * 0.8, by - dy * 0.8), (px_, py_), 2.6, derin, MS)
    ux, uy = bx + dx * 4.6, by + dy * 4.6
    for i, (off, boy) in enumerate(((-2.2, 2.9), (-0.75, 3.5), (0.75, 3.4), (2.2, 2.7))):
        kx, ky = ux + nx * off, uy + ny * off
        tx, ty = kx + dx * boy - nx * off * 0.08, ky + dy * boy - ny * off * 0.08
        tup(ad + "_p%d" % i, (kx, ky), (tx, ty), 0.9, derin - 0.4, MS, r_b=0.72)
        elipsoid(ad + "_p%d_uc" % i, tx, ty, 0.74, 0.74, 0.74, derin - 0.45, MS, seg=10, ring=6)
    yan = (1.0 if (23.0 - bx) * nx >= 0 else -1.0) if sol is None else (1.0 if sol else -1.0)
    tbx, tby = bx + dx * 1.2 + nx * 2.6 * yan, by + dy * 1.2 + ny * 2.6 * yan
    tex, tey = tbx + dx * 2.6 - nx * 0.8 * yan, tby + dy * 2.6 - ny * 0.8 * yan
    tup(ad + "_bas", (tbx, tby), (tex, tey), 0.9, derin - 1.6, MS, r_b=0.75)
    elipsoid(ad + "_bas_uc", tex, tey, 0.75, 0.75, 0.75, derin - 1.6, MS, seg=10, ring=6)
    elipsoid(ad + "_bas_kok", tbx, tby, 1.2, 1.2, 1.0, derin - 1.2, MS, seg=10, ring=6)


KESIM_KARE = 11
JEST_KARE = 8


def cay_bardagi(ad, bx, by, derin, egim):
    """Ince belli cay bardagi: dibi elin icinde, agzi egim (radyan) yonunde.
    Govde demli cay rengi (cam ince, icerik okunur), agizda cam halka, yanda
    parlak cizgi."""
    ux, uy = math.sin(egim), -math.cos(egim)
    MC = cel("Cay", CAY)
    MG = cel("CayCam", CAM)
    p0 = (bx, by)
    p1 = (bx + ux * 2.8, by + uy * 2.8)
    p2 = (bx + ux * 6.0, by + uy * 6.0)
    tup(ad + "_alt", p0, p1, 1.7, derin, MC, r_b=1.15)
    tup(ad + "_ust", p1, p2, 1.15, derin, MC, r_b=1.85)
    elipsoid(ad + "_dip", p0[0], p0[1], 1.8, 0.7, 1.8, derin, MG, seg=14, ring=8)
    elipsoid(ad + "_agiz", p2[0], p2[1], 1.95, 0.45, 1.95, derin, MG, seg=16, ring=8)
    nx, ny = -uy, ux
    egri_tup(ad + "_isik", [(p0[0] - nx * 1.1, p0[1] - ny * 1.1, derin - 1.5),
                            (p1[0] - nx * 0.7, p1[1] - ny * 0.7, derin - 1.3),
                            (p2[0] - nx * 1.3, p2[1] - ny * 1.3, derin - 1.7)], [0.22, 0.18, 0.22], px.flat("CayIsik", "#ffffff"))


def kol_katmani(ad):
    """Katman adindan poz: kol_sol_bosta, kol_sag_jest_fes_3 ..."""
    by, hx, hy = 50, 23, 30
    if ad == "kol_sol_bosta":
        kol(ad, (4.5, by + 9), (3.5, by + 40))
    elif ad == "kol_sag_bosta":
        kol(ad, (42.5, by + 9), (43.5, by + 41))
    elif ad.startswith("kol_sag_jest_"):
        _, _, _, tip, n = ad.split("_")
        k = int(n) / float(JEST_KARE)
        hedef_y = hy - 7 if tip == "fes" else hy + 9
        hedef_x = hx + 11 if tip == "fes" else hx + 13
        elx = 43.5 + (hedef_x - 43.5) * k
        ely = (by + 41) + (hedef_y - (by + 41)) * k
        kol(ad, (42.5, by + 9), (elx, ely), derin=-6.0 * k - 2.0)
    elif ad.startswith("kol_sag_kesim_"):
        sw = -5.0 + 10.0 * int(ad.split("_")[-1]) / float(KESIM_KARE - 1)
        kol(ad, (42.5, by + 9), (46, by + 34 + sw))
    elif ad == "kol_sol_kesim":
        kol(ad, (4.5, by + 12), (4, by + 36.5))
    elif ad.startswith("kol_sol_cay_"):
        # yudum: el kalcadan cenenin soluna kalkar, bardak agiza dogru egilir
        k = int(ad.split("_")[-1]) / float(JEST_KARE)
        elx = 3.5 + (14.5 - 3.5) * k
        ely = (by + 40) + (49.0 - (by + 40)) * k
        d = -6.0 * k - 2.0
        kol(ad, (4.5, by + 9), (elx, ely), derin=d)
        cay_bardagi(ad + "_bardak", elx + 1.2, ely - 2.4, d - 2.5, math.radians(38.0) * k * k)
    elif ad == "kol_sol_mutlu":
        kol(ad, (3.5, by + 11), (2, by - 14), manset=False)
    elif ad == "kol_sag_mutlu":
        kol(ad, (43.5, by + 11), (45, by - 14), manset=False)


# ---------------------------------------------------------------- kafa
def kafa():
    MS = cel("Kafa", SKIN)
    elipsoid("kafa", 23, 29.5, 14.2, 14.2, 12.6, 0, MS, seg=40, ring=26)
    elipsoid("cene", 23, 36.5, 13.4, 8.5, 11.8, 0, MS, seg=40, ring=22)
    for gx in (14.6, 31.4):
        elipsoid("yanak", gx, 35.2, 5.0, 4.2, 4.6, yuz_on(gx, 35.2) + 3.6, MS, seg=22, ring=14)
    MK = cel("KulakIc", [SKIN[0], SKIN[0], SKIN[1], SKIN[1]])
    for gx, yon in ((8.7, -1), (37.3, 1)):
        elipsoid("kulak", gx, 32.4, 2.8, 4.7, 2.2, -1.2, MS, seg=18, ring=12)
        elipsoid("kulak_ic", gx - yon * 0.2, 32.8, 1.3, 2.9, 0.7, -3.0, MK, seg=12, ring=8)
    # beyaz sac: fesin altindan sakaklara dalgali tutamlar (kulaklarin ustu/arkasi)
    MA = cel("Sac", AK, noise=0.1, noise_scale=10)
    for yon in (-1, 1):
        for i, (dx, gy, r, d) in enumerate(((11.8, 19.8, 3.2, 2.0), (13.4, 22.8, 3.4, 1.4),
                                            (14.4, 26.0, 3.3, 1.2), (14.6, 29.2, 2.9, 1.8),
                                            (14.0, 31.8, 2.3, 2.6))):
            e = elipsoid("sac", 23 + yon * dx, gy, r * 0.9, r, r * 1.1, d, MA, seg=16, ring=10)
            e.rotation_euler = (0, yon * 0.35, 0)
        # ense (kulak arkasi) kisa sac
        elipsoid("ense", 23 + yon * 11.5, 34.5, 3.0, 3.2, 3.0, 4.5, MA, seg=14, ring=8)


def boyun():
    """Kisa, asagi dogru genisleyen boyun; cene altinda golge; dik gomlek yakasi."""
    MS = cel("Boyun", [SKIN[0], SKIN[1], SKIN[1], SKIN[2]])
    L.silindir("boyun", 6.6, 23, 1, -47, 9, MS, seg=24, r2=5.8)
    elipsoid("cene_golge", 23, 43.8, 5.9, 1.9, 5.4, 0.6, px.flat("CeneGolge", SKIN[0]), seg=20, ring=8)
    MY = cel("Yaka", GOMLEK)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=False, cap_tris=False, segments=32, radius1=7.8, radius2=7.0, depth=3.4)
    sil = [f for f in bm.faces if f.calc_center_median().y < -5.0 and abs(f.calc_center_median().x) < 2.6]
    bmesh.ops.delete(bm, geom=sil, context="FACES")
    bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=0.6)
    me = bpy.data.meshes.new("yaka")
    bm.to_mesh(me)
    bm.free()
    for p_ in me.polygons:
        p_.use_smooth = True
    ob = link(bpy.data.objects.new("yaka", me))
    ob.location = (23, 1.0, -49.4)
    me.materials.append(MY)


def fes():
    """Konik keçe fes: altta (basta) genis, tepede dar; tepe dugmesi."""
    MF = cel("Fes", FES, noise=0.04, noise_scale=20)
    MU = cel("FesUst", FES_UST)
    L.silindir("fes", 12.4, 23, 0.4, -12.6, 17.0, MF, seg=48, r2=10.2)
    L.silindir("fes_tepe", 10.2, 23, 0.4, -4.3, 0.7, MU, seg=48)
    # alt kenar: basa oturan hafif kalin keçe kivrimi
    L.silindir("fes_kenar", 12.55, 23, 0.4, -20.6, 1.1, cel("FesKenar", [FES[0], FES[0], FES[1], FES[2]]), seg=48)
    elipsoid("dugme", 23.8, 3.6, 1.3, 0.7, 1.3, -1.0, px.flat("FesDugme", "#241a14"), seg=12, ring=6)


def puskul(sw):
    """Tepe dugmesinden fesin sagina inen kordon + siyah puskul (sw: sallanma)."""
    MP = cel("Puskul", PUSKUL)
    egri_tup("kordon", [(24.0, 3.6, -1.2), (30.0, 3.9, -3.0), (33.6, 5.8, -2.2), (34.4 + sw * 0.35, 10.0, -1.0),
                        (34.8 + sw * 0.7, 13.2, -0.6)], 0.42, MP)
    elipsoid("dugum", 34.8 + sw * 0.7, 13.6, 1.3, 1.1, 1.2, -0.6, MP, seg=12, ring=8)
    tup("puskul", (34.8 + sw * 0.72, 14.2), (35.2 + sw, 20.2), 1.2, -0.6, MP, r_b=2.1, seg=16)
    for q in range(4):
        x = 35.2 + sw + (q - 1.5) * 0.9
        tup("iplik%d" % q, (x - (q - 1.5) * 0.3, 16.0), (x, 20.8), 0.35, -2.4, px.flat("Iplik", "#3a2c22"), seg=6)


def kas(yuk=0.0):
    """Gur beyaz kaslar: ice dogru kalin, disa dogru incelip sarkan tutamlar."""
    MA = cel("Kas", AK, noise=0.1, noise_scale=12)
    for cx, yon in ((16.8, -1), (29.2, 1)):
        for i in range(6):
            u = i / 5.0
            gx = cx - yon * 2.6 + yon * u * 6.0
            gy = 26.7 - yuk - 0.9 * math.sin(u * math.pi * 0.85) + 1.3 * u * u
            r = 1.5 - 0.5 * u
            e = elipsoid("kas%d" % i, gx, gy, r * 1.5, r, r * 0.9, yuz_on(gx, gy) - 0.5, MA, seg=12, ring=8)
            e.rotation_euler = (0, yon * (-0.1 - 0.35 * u), 0)
        # ucta disa tasan tek tel
        tup("kas_tel", (cx + yon * 3.2, 27.6 - yuk), (cx + yon * 5.0, 28.6 - yuk), 0.4,
            yuz_on(cx + yon * 3.6, 26.4) - 0.3, MA, r_b=0.2, seg=8)


def gozler(durum):
    B = px.flat("GozBeyaz", "#f6efe2")
    Kb = px.flat("GozBebek", "#2b1a12")
    Is = px.flat("GozIsik", "#ffffff")
    Kp = cel("Kapak", SKIN)
    Cz = px.flat("KirpikCizgi", "#3a2418")
    for cx in (16.8, 29.2):
        d = yuz_on(cx, 31.2)
        if durum == "kapali":
            egri_tup("kapali", [(cx - 2.5, 31.0, d - 0.3), (cx, 32.1, d - 0.6), (cx + 2.5, 31.0, d - 0.3)],
                     [0.3, 0.5, 0.3], Cz)
            continue
        elipsoid("ak", cx, 31.4, 2.5, 2.0, 0.8, d + 0.2, B, seg=22, ring=14)
        bak = 0.75 if durum == "acik_1" else 0.0
        elipsoid("bebek", cx + bak, 31.6, 1.7, 1.95, 0.6, d - 0.25, Kb, seg=16, ring=10)
        elipsoid("isik", cx + bak - 0.65, 30.9, 0.55, 0.55, 0.3, d - 0.7, Is, seg=8, ring=6)
        # ust kapak (ten): gozun ust kenarini hafif orter -> yumusak, sevecen bakis
        kap_y = 31.6 if durum == "yari" else 29.7
        elipsoid("kapak", cx, kap_y - 1.3, 2.9, 1.6, 1.0, d - 0.6, Kp, seg=18, ring=10)
        ust = kap_y + 0.1
        egri_tup("kirpik", [(cx - 2.7, ust + 0.9, d - 0.9), (cx - 1.0, ust, d - 1.2), (cx + 1.2, ust, d - 1.2),
                            (cx + 2.8, ust + 0.8, d - 0.9)], [0.3, 0.45, 0.45, 0.35], Cz)
        # alt kapak / yas cizgisi (yumusak)
        egri_tup("alt_kapak", [(cx - 2.0, 33.4, d - 0.2), (cx, 33.9, d - 0.3), (cx + 2.0, 33.4, d - 0.2)],
                 [0.12, 0.22, 0.12], px.flat("AltKapak", SKIN[0]))


def burun():
    MS = cel("Burun", SKIN)
    d = yuz_on(23, 34.2)
    elipsoid("kemer", 23, 30.8, 1.7, 3.2, 1.5, yuz_on(23, 30.8) - 0.3, MS, seg=14, ring=10)
    elipsoid("burun", 23, 34.3, 3.7, 3.5, 3.3, d - 1.5, MS, seg=26, ring=18)
    for yon in (-1, 1):
        elipsoid("kanat", 23 + yon * 2.7, 35.7, 1.8, 1.6, 1.6, d - 0.7, MS, seg=14, ring=8)
        elipsoid("delik", 23 + yon * 1.3, 37.0, 0.8, 0.45, 0.4, d - 2.6, px.flat("BurunDelik", "#7a3a30"),
                 seg=8, ring=4)
    elipsoid("isik", 21.9, 33.1, 1.1, 0.8, 0.4, d - 4.6, px.flat("BurunIsik", "#fff0dc"), seg=10, ring=6)


def allik():
    M = px.flat_a("Allik", "#e07a68", 0.34)
    for gx in (14.2, 31.8):
        elipsoid("allik", gx, 36.2, 3.8, 2.6, 0.6, yuz_on(gx, 36.2) - 1.0, M, seg=16, ring=8)


def biyik():
    """Beyaz pala biyik: burnun altindan disa kalin -> ince, uclari yukari kivrik."""
    MA = cel("Biyik", AK, noise=0.12, noise_scale=12)
    for yon in (-1, 1):
        nok, rr = [], []
        for (dx, gy, r) in ((0.6, 38.0, 2.3), (4.6, 39.0, 2.5), (8.6, 39.5, 2.0), (11.8, 38.4, 1.4),
                            (13.2, 36.2, 0.95), (12.6, 34.4, 0.55)):
            gx = 23 + yon * dx
            nok.append((gx, gy, yuz_on(gx, gy) - 1.2 - r))
            rr.append(r)
        egri_tup("biyik%d" % yon, nok, rr, MA)
        # tel tel gorunum: ustte iki ince koyu cizgi
        egri_tup("tel%d" % yon, [(23 + yon * 2.0, 38.6, yuz_on(23 + yon * 2, 38.6) - 4.4),
                                 (23 + yon * 6.0, 39.6, yuz_on(23 + yon * 6, 39.6) - 3.9),
                                 (23 + yon * 9.5, 39.4, yuz_on(23 + yon * 9.5, 39.4) - 2.9)],
                 [0.1, 0.16, 0.1], px.flat("BiyikTel", "#d9cfc0"))
    elipsoid("orta", 23, 38.0, 3.6, 2.0, 2.2, yuz_on(23, 38) - 2.6, MA, seg=16, ring=10)


def agiz(mutlu):
    d = yuz_on(23, 42.5)
    if not mutlu:
        elipsoid("dudak", 23, 42.6, 2.7, 1.0, 0.8, d - 0.2, cel("Dudak", DUDAK), seg=16, ring=8)
        duz("agiz", 20.2, 41.3, 25.8, 41.9, d - 0.6, px.flat("Agiz", "#5a2c22"))
        return
    elipsoid("agiz_ic", 23, 42.6, 4.8, 2.6, 0.8, d - 0.1, px.flat("AgizIc", "#5a2c22"), seg=20, ring=10)
    duz("dis", 19.2, 40.6, 26.8, 41.8, d - 1.0, px.flat("Dis", "#ffffff"))
    elipsoid("dil", 23, 44.0, 3.0, 1.1, 0.5, d - 0.9, px.flat("Dil", "#c9584a"), seg=14, ring=6)
    Kr = px.flat("Kirisik", SKIN[0])
    for yon in (-1, 1):
        gx = 23 + yon * 10.8
        egri_tup("kirisik", [(gx, 36.8, yuz_on(gx, 36.8) - 0.3), (gx + yon * 0.7, 39.4, yuz_on(gx, 39.4) - 0.3),
                             (gx + yon * 0.2, 41.8, yuz_on(gx, 41.8) - 0.3)], [0.15, 0.3, 0.15], Kr)


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
katman("kas", kas, cizgi_renk="#6e6a62")
katman("kas_ust", lambda: kas(1.2), cizgi_renk="#6e6a62")
for dz in ("acik_0", "acik_1", "kapali", "yari"):
    katman("goz_" + dz, lambda dz=dz: gozler(dz), cizgi=False)
katman("burun", burun, cizgi_renk="#95603c")
katman("allik", allik, cizgi=False)
katman("biyik", biyik, cizgi_renk="#6e6a62")
katman("agiz", lambda: agiz(False), cizgi=False)
katman("agiz_mutlu", lambda: agiz(True), cizgi=False)
for ad in (["kol_sol_bosta", "kol_sag_bosta", "kol_sol_kesim", "kol_sol_mutlu", "kol_sag_mutlu"]
           + ["kol_sag_jest_fes_%d" % i for i in range(1, JEST_KARE + 1)]
           + ["kol_sag_jest_biyik_%d" % i for i in range(1, JEST_KARE + 1)]
           + ["kol_sol_cay_%d" % i for i in range(1, JEST_KARE + 1)]
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
        veri = {"gx0": gx0, "gy0": gy0, "w": w, "h": h, "hd": HD,
                "katmanlar": list(KATMANLAR)}
        if abs(OLCEK - 1.0) > 1e-6:
            veri["olcekler"] = {k: OLCEK for k in KATMANLAR}
        json.dump(veri, fp, indent=1)
    print("DAYI_HD_DONE %d katman" % len(adlar))


if __name__ == "__main__":
    main()
