"""LOGO ADAYLARI — Blender'da 3B model, oyunun paletinde piksel render.

    python blender/logo_olcu.py          (bir kez: font olculeri)
    blender --background --factory-startup --python blender/models/logo.py -- hepsi
    ... -- tabela | sis | neon | rozet   (tek aday, hizli deneme icin)

DORT YON, hepsi Turkce ve Ingilizce:

  tabela : emaye dukkan tabelasi. Kirmizi emaye levha, krem ic cerceve,
           kose civatalari; demir koldan iki zincirle sarkiyor.
           Yazi Cooper Black — sicak, 70'ler lokanta tabelasi.
  sis    : oyunun KENDI doner sisi (models/spit.py'den birebir) amblem
           olarak solda, arkasinda isiticinin turuncu kareleri; adi
           kirmizi kurdelenin uzerinde.
  neon   : karanlik duvar panosu, harfler NEON TUP — yazinin dolgusu
           yok, yalniz kontur tupu; arkasinda sonuk hale.
  rozet  : yuvarlak muhur. Ortada babanin FESI (prologdaki baba onu
           takiyor), ustte yildizlar, adi krem kurdelede.

HICBIRI OYUNA BAGLI DEGIL. Kullanici birini secene kadar yalniz
blender/out/logo/ klasorune render ediliyor; js/ui.js'teki baslik
cizimine dokunulmadi.

Boru hattinin kurallari (blender/README.md): 1 birim = 1 piksel,
anti-alias yok, renk yonetimi kapali, cikti palete cakiliyor.
"""
import sys, os, math, json
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import palette as pal

OUT = os.path.join(_HERE, "out", "logo")
W, H = 320, 112                      # logo tuvali (oyun pikseli)
K_SHEAR = 0.34                       # derinlik basina dikey acilim

with open(os.path.join(_HERE, "out", "logo_font.json"), encoding="utf-8") as fp:
    FONT = json.load(fp)

YAZI = {
    "tr": ("BABAMIN", "DÖNERCİSİ"),
    "en": ("MY FATHER'S", "KEBAB SHOP"),
}

P = pal.P
GOLD  = [P["au3"], P["au2"], P["au1"], P["au0"]]
RED   = [P["red3"], P["red2"], P["red1"], P["red0"]]
CREAM = [P["s3"], P["s2"], P["s1"], P["s0"]]
IRON  = [P["ink"], P["mt5"], P["mt4"], P["mt3"]]
STEEL = [P["mt4"], P["mt3"], P["mt2"], P["mt1"]]
DARK  = [P["ui5"], P["ui4"], P["ink2"], P["ui4"]]
# Isik ondan-ustten-soldan: on yuz ~.85, ust bevel ~.92 (parlak),
# acilan ust yuz ~.45 (koyu) -> kabartma okunuyor.
STOPS4 = [0.0, 0.50, 0.78, 0.905]


# ================================================================ temel
def link(ob):
    bpy.context.collection.objects.link(ob)
    return ob

def obj(name, bm, mat=None, smooth=False):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    if smooth:
        for p in me.polygons:
            p.use_smooth = True
    ob = link(bpy.data.objects.new(name, me))
    if mat:
        me.materials.append(mat)
    return ob

def meshle(ob, mat=None):
    """Egri/yazi objesini gercek mesh'e cevirir: shear_scene yalniz
    MESH objelerini kaydiriyor, egri kalirsa derinlik acilmaz."""
    bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg))
    mo = link(bpy.data.objects.new(ob.name + "_m", me))
    mo.matrix_world = ob.matrix_world.copy()
    bpy.data.objects.remove(ob, do_unlink=True)
    if mat:
        me.materials.clear()
        me.materials.append(mat)
    return mo

def kutu(name, x0, x1, z0, z1, y0, y1, mat):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    return obj(name, bm, mat)

def silindir(name, r, x, y, z, boy, mat, seg=24, eksen="Z", r2=None):
    """create_cone: radius1 ALT (-boy/2), radius2 UST (+boy/2)."""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=seg,
                          radius1=r, radius2=(r if r2 is None else r2), depth=boy)
    ob = obj(name, bm, mat, smooth=True)
    if eksen == "Y":
        ob.rotation_euler = (math.radians(90), 0, 0)
    elif eksen == "X":
        ob.rotation_euler = (0, math.radians(90), 0)
    ob.location = (x, y, z)
    return ob

def _egri(name, splines, x, z, y, derin, bevel, fill="BOTH", res=1):
    """2B egri (on yuze bakan), extrude + bevel. splines: nokta listeleri."""
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "2D"
    cu.fill_mode = fill
    cu.extrude = derin / 2.0
    cu.bevel_depth = bevel
    cu.bevel_resolution = res
    for pts in splines:
        sp = cu.splines.new("POLY")
        sp.points.add(len(pts) - 1)
        for p, (a, b) in zip(sp.points, pts):
            p.co = (a, b, 0.0, 1.0)
        sp.use_cyclic_u = True
    ob = link(bpy.data.objects.new(name, cu))
    ob.rotation_euler = (math.radians(90), 0, 0)   # yerel XY -> dunya XZ, yuz -Y'ye
    ob.location = (x, y, z)
    return ob

def yuvarlak_dikdortgen(w, h, r, seg=6):
    pts, hw, hh = [], w / 2.0 - r, h / 2.0 - r
    for cx, cz, a0 in ((hw, hh, 0), (-hw, hh, 90), (-hw, -hh, 180), (hw, -hh, 270)):
        for i in range(seg + 1):
            a = math.radians(a0 + 90.0 * i / seg)
            pts.append((cx + r * math.cos(a), cz + r * math.sin(a)))
    return pts

def daire(r, seg=40):
    return [(r * math.cos(2 * math.pi * i / seg), r * math.sin(2 * math.pi * i / seg))
            for i in range(seg)]

def levha(name, w, h, r, x, z, y, derin, bevel, mat):
    return meshle(_egri(name, [yuvarlak_dikdortgen(w, h, r)], x, z, y, derin, bevel), mat)

def cerceve(name, w, h, r, kalin, x, z, y, derin, mat):
    """Iki kontur -> arasi dolu, ortasi bos (cift-tek kurali)."""
    dis = yuvarlak_dikdortgen(w, h, r)
    ic = list(reversed(yuvarlak_dikdortgen(w - 2 * kalin, h - 2 * kalin, max(0.5, r - kalin))))
    return meshle(_egri(name, [dis, ic], x, z, y, derin, 0.0), mat)

def disk(name, r, x, z, y, derin, bevel, mat, ic=None):
    spl = [daire(r)]
    if ic:
        spl.append(list(reversed(daire(ic))))
    return meshle(_egri(name, spl, x, z, y, derin, bevel), mat)

def cokgen(name, pts, x, z, y, derin, bevel, mat):
    return meshle(_egri(name, [pts], x, z, y, derin, bevel), mat)

def halka(name, rx, rz, tel, x, z, y, mat, yan=False):
    """Zincir halkasi: kapali egri + bevel = tup."""
    cu = bpy.data.curves.new(name, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = tel
    cu.bevel_resolution = 2
    sp = cu.splines.new("POLY")
    n = 14
    sp.points.add(n - 1)
    for i, p in enumerate(sp.points):
        a = 2 * math.pi * i / n
        p.co = (rx * math.cos(a), rz * math.sin(a), 0.0, 1.0)
    sp.use_cyclic_u = True
    ob = link(bpy.data.objects.new(name, cu))
    ob.rotation_euler = (math.radians(90), 0, math.radians(90) if yan else 0)
    ob.location = (x, y, z)
    return meshle(ob, mat)

def yildiz(r, ic, n=5):
    pts = []
    for i in range(2 * n):
        rr = r if i % 2 == 0 else ic
        a = math.pi / 2 + math.pi * i / n
        pts.append((rr * math.cos(a), rr * math.sin(a)))
    return pts


# ================================================================ yazi
_FONTLAR = {}
def _font(ad):
    if ad not in _FONTLAR:
        _FONTLAR[ad] = bpy.data.fonts.load(FONT[ad]["yol"])
    return _FONTLAR[ad]

# Fontta olmayan Turkce buyuk harf: taban harf + modellenmis aksan
AKSAN = {"İ": ("I", "nokta"), "Ş": ("S", "cedilla"), "Ğ": ("G", "breve")}

def _taban(F, ch):
    if F["var"].get(ch):
        return ch, None
    return AKSAN.get(ch, (ch, None))

def yazi_genisligi(metin, ad, cap, aralik=0.0):
    F = FONT[ad]
    em = cap / F["cap"]
    w = 0.0
    for i, ch in enumerate(metin):
        b, _ = _taban(F, ch)
        w += F["adv"].get(b, 0.55) * em
        if i < len(metin) - 1:
            w += aralik
    return w

def golgeli(metin, ad, cap, cx, zb, y, derin, bevel, mat, golge_mat, dx=1.6, dz=-1.6,
            golge_y=None, **kw):
    """Tabela ressaminin 'golgesi': harfin sag-altina koyu bir kopya.
    Oblik izdusum harfin ancak UST yuzunu 1 px gosteriyordu, harfler
    levhaya yapistirilmis gibi duruyordu; golge onlari levhadan kaldiriyor."""
    gy = y + derin * 0.6 if golge_y is None else golge_y
    yazi(metin, ad, cap, cx + dx, zb + dz, gy, min(derin, 1.6), bevel, golge_mat, **kw)
    return yazi(metin, ad, cap, cx, zb, y, derin, bevel, mat, **kw)

def yazi(metin, ad, cap, cx, zb, y, derin, bevel, mat, maxw=None, aralik=0.0,
         dolgu=True):
    """Harf harf dizilmis 3B yazi. zb = taban cizgisi. Genislik maxw'yi
    asarsa buyuk harf yuksekligi kuculur (EN basliklar daha uzun)."""
    F = FONT[ad]
    w = yazi_genisligi(metin, ad, cap, aralik)
    if maxw and w > maxw:
        cap *= maxw / w
        w = yazi_genisligi(metin, ad, cap, aralik)
    em = cap / F["cap"]
    fnt = _font(ad)
    x = cx - w / 2.0
    parca = []
    for i, ch in enumerate(metin):
        b, aksan = _taban(F, ch)
        a = F["adv"].get(b, 0.55) * em
        if ch != " ":
            cu = bpy.data.curves.new("h%d" % i, "FONT")
            cu.body = b
            cu.font = fnt
            cu.size = em
            cu.align_x = "LEFT"
            if dolgu:
                cu.extrude = derin / 2.0
                cu.bevel_depth = bevel
                cu.bevel_resolution = 1
            else:                                   # neon: yalniz kontur tupu
                cu.fill_mode = "NONE"
                cu.extrude = 0.0
                cu.bevel_depth = bevel
                cu.bevel_resolution = 2
            ob = link(bpy.data.objects.new("h%d" % i, cu))
            ob.rotation_euler = (math.radians(90), 0, 0)
            ob.location = (x, y, zb)
            parca.append(meshle(ob, mat))
            if aksan == "nokta":
                d = max(2.0, round(cap * 0.19))
                x0 = x + a / 2.0 - d / 2.0
                z0 = zb + cap + max(1.5, cap * 0.10)
                if dolgu:
                    parca.append(kutu("nk%d" % i, x0, x0 + d, z0, z0 + d,
                                      y - derin / 2.0, y + derin / 2.0, mat))
                else:
                    parca.append(halka("nk%d" % i, d / 2.0, d / 2.0, bevel,
                                       x0 + d / 2.0, z0 + d / 2.0, y, mat))
        x += a + aralik
    return parca, w, cap


# ================================================================ sahne
def isik():
    """Isigin GIDIS yonu: onden, biraz ustten ve soldan."""
    d = Vector((0.30, 0.85, -0.45)).normalized()
    s = px.sun(math.pi, rot=(0, 0, 0))
    s.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
    return s

def sahne():
    _FONTLAR.clear()          # reset() font datablock'larini da siliyor
    px.reset()
    px.setup(W, H)
    px.ortho_cam(0.0, 0.0, W, H)
    px.world("#000000", 0.0)
    isik()

def cel(ad, ramp):
    return px.cel(ad, ramp, STOPS4)


# ================================================================ A) TABELA
def c_tabela(dil):
    """Emaye dukkan tabelasi, demir koldan zincirle sarkiyor."""
    sahne()
    M_red, M_gold, M_cream = cel("Emaye", RED), cel("Yaldiz", GOLD), cel("Krem", CREAM)
    M_iron, M_bolt = cel("Demir", IRON), cel("Civata", STEEL)
    M_golge = px.flat("Golge", P["red3"])

    # demir kol: kalin cubuk, iki ucta kivrim
    kutu("kol", -134, 134, 50, 54, 5, 9, M_iron)
    for sx in (-1, 1):
        halka("kivrim%d" % sx, 5, 5, 1.6, sx * 139, 49, 7, M_iron)
    # zincirler: kol ile levha arasi 17 px, uc halka, sirayla yuz/yan
    for sx in (-1, 1):
        for j in range(3):
            halka("z%d_%d" % (sx, j), 2.8, 4.0, 1.3, sx * 104, 46 - j * 6.0, 2.0,
                  M_iron, yan=(j % 2 == 1))
    # levha
    levha("levha", 292, 78, 9, 0, -6, 0, 7, 1.4, M_red)
    cerceve("ic_cerceve", 280, 66, 6, 2.2, 0, -6, -5.8, 1.4, M_cream)
    for sx in (-1, 1):
        for sz in (-1, 1):
            silindir("civata", 2.4, sx * 137, -6.0, -6 + sz * 30, 2.2, M_bolt, seg=12, eksen="Y")
    # yazi: golgeli
    ust, alt = YAZI[dil]
    golgeli(ust, "cooper", 10, 0, 12, -8.0, 2.0, 0.5, M_cream, M_golge, dx=1.0, dz=-1.0,
            golge_y=-5.9, maxw=196, aralik=2.4)
    golgeli(alt, "cooper", 25, 0, -27, -8.6, 3.2, 0.8, M_gold, M_golge, dx=2.0, dz=-2.0,
            golge_y=-5.9, maxw=262, aralik=0.6)
    px.shear_scene(0.44)


# ================================================================ B) SIS
def c_sis(dil):
    """Oyunun kendi doner sisi ortada, adi onundeki kurdelede.

    Ilk denemede sis solda ayri bir kutu, yazi sagda ayri duruyordu:
    iki sey gibi okunuyordu, amblem gibi degil."""
    import spit
    sahne()
    M_red = cel("Kurdele", RED)
    M_red_d = cel("KurdeleArka", [P["red3"], P["red3"], P["red2"], P["red2"]])
    M_gold, M_cream = cel("Yaldiz", GOLD), cel("Krem", CREAM)
    M_steel = cel("Celik", STEEL)
    M_panel = cel("Panel", DARK)
    M_levha = cel("Levhacik", [P["ui5"], P["ui5"], P["ui4"], P["ui4"]])
    M_golge = px.flat("Golge", P["red3"])
    M_heat = [px.flat("Isitici%d" % i, h) for i, h in
              enumerate((P["f3"], P["f2"], P["f1"]))]

    SX = 0.0
    # isitici: sisin ARKASINDA, iki yana tasan turuncu kareler
    levha("isitici", 96, 100, 5, SX, 2, 16, 6, 0.8, M_panel)
    for r in range(6):
        for c in range(6):
            m = M_heat[(r * 2 + c) % 3]
            x0 = SX - 42 + c * 14.3
            z0 = -44 + r * 15.3
            kutu("kare", x0, x0 + 11, z0, z0 + 12, 11.5, 12.5, m)

    # sis: models/spit.py'nin konisi, olceklenip ortaya tasiniyor
    M_meat = px.cel_nx("Et", spit.meat_ramp(0.66), spit.NX_STOPS,
                       band=1.0, band_amt=0.010, noise=0.016, noise_scale=1.4)
    cone = spit.build_cone(mass=1.0, cut=0.0, rot=0.6, seed=7)
    cone.data.materials.clear()
    cone.data.materials.append(M_meat)
    bpy.context.view_layer.update()
    mw = cone.matrix_world
    vs = [mw @ v.co for v in cone.data.vertices]
    x0 = min(v.x for v in vs); x1 = max(v.x for v in vs)
    z0 = min(v.z for v in vs); z1 = max(v.z for v in vs)
    y0 = min(v.y for v in vs); y1 = max(v.y for v in vs)
    s_ = 92.0 / (z1 - z0)
    c0 = Vector(((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2))
    hedef = Vector((SX, 2.0, 2.0))
    inv = mw.inverted()
    for v in cone.data.vertices:
        v.co = inv @ (((mw @ v.co) - c0) * s_ + hedef)
    cone.data.update()
    ust_z = 2.0 + (z1 - z0) * s_ / 2
    silindir("cubuk", 1.4, SX, 2, ust_z + 4, 10, M_steel, seg=10)
    silindir("tepe", 6, SX, 2, ust_z + 1.5, 3, M_steel, seg=16)

    # kurdele: sisin ONUNDE, iki yana genis, arkada catalli kuyruklar
    RW, RZ, RH = 244, -24, 30
    kuyruk = [(-24, 11), (8, 11), (8, -11), (-24, -11), (-15, 0)]
    cokgen("kuyruk_sol", [(-q[0], q[1]) for q in kuyruk], -RW / 2 - 6, RZ - 7, -16, 3, 0.5, M_red_d)
    cokgen("kuyruk_sag", kuyruk, RW / 2 + 6, RZ - 7, -16, 3, 0.5, M_red_d)
    levha("kurdele", RW, RH, 3, 0, RZ, -22, 4, 0.9, M_red)

    ust, alt = YAZI[dil]
    # ust satir sisin onunde, koyu kucuk levhanin uzerinde: et zemininde okunmaz
    genis = yazi_genisligi(ust, "arialblk", 11, 1.6)
    levha("ust_levha", min(200, genis + 18), 20, 3, 0, 20, -22, 3, 0.6, M_levha)
    yazi(ust, "arialblk", 11, 0, 15, -25, 2.2, 0.4, M_cream, maxw=184, aralik=1.6)
    golgeli(alt, "arialblk", 20, 0, RZ - 10, -27.6, 2.6, 0.6, M_gold, M_golge,
            dx=1.4, dz=-1.4, golge_y=-25.2, maxw=RW - 24, aralik=0.6)
    # sis govdesini cel_nx yuvarlatiyor, oblige gerek yok; buyuk kaydirma
    # derin katmanlari (kurdele y=-22) birbirinden ayiriyordu
    px.shear_scene(0.16)


# ================================================================ C) NEON
def c_neon(dil):
    """Karanlik pano, harfler neon tup (dolgusuz kontur).

    Ilk denemede kalin hale tupu ince parlak tupun ONUNE tasiyordu
    (kalin tupun on yuzu kameraya daha yakin): yazi bordo cikiyordu.
    Simdi hale panonun dibinde, tup ondan belirgin ileride."""
    sahne()
    M_pano = cel("Pano", [P["ui5"], P["ui5"], P["ink2"], P["ink"]])
    M_kasa = cel("Kasa", IRON)
    M_vida = cel("Vida", STEEL)
    N_pembe, N_hale_p = px.flat("NeonPembe", P["pink"]), px.flat("HalePembe", P["red3"])
    N_amber, N_hale_a = px.flat("NeonAmber", P["f1"]), px.flat("HaleAmber", P["au3"])
    N_kirmizi = px.flat("NeonKirmizi", P["red0"])

    levha("kasa", 304, 90, 6, 0, -2, 6, 8, 1.0, M_kasa)
    levha("pano", 292, 78, 4, 0, -2, 1.4, 1.2, 0.4, M_pano)
    for sx in (-1, 1):
        for sz in (-1, 1):
            silindir("vida", 2.0, sx * 140, -1.0, -2 + sz * 34, 1.2, M_vida, seg=10, eksen="Y")
    cerceve("hale_cerceve", 278, 66, 8, 3.4, 0, -2, 0.4, 0.4, N_hale_p)
    cerceve("neon_cerceve", 274, 62, 7, 1.3, 0, -2, -4.0, 0.6, N_kirmizi)

    ust, alt = YAZI[dil]
    # 12 px'te tup konturu dolu lekeye donuyordu: kucuk satir DOLU harf
    yazi(ust, "arialblk", 11, 0, 12, -5.0, 1.0, 0.0, N_amber, maxw=210, aralik=2.4)
    yazi(alt, "arialblk", 26, 0, -27, 0.2, 0, 1.6, N_hale_p, maxw=256, aralik=1.2, dolgu=False)
    yazi(alt, "arialblk", 26, 0, -27, -5.0, 0, 1.0, N_pembe, maxw=256, aralik=1.2, dolgu=False)
    px.shear_scene(0.12)


# ================================================================ D) ROZET
def c_rozet(dil):
    """Yuvarlak muhur: ortada babanin fesi, adi kurdelede."""
    sahne()
    M_gold, M_red, M_cream = cel("Yaldiz", GOLD), cel("Kirmizi", RED), cel("Krem", CREAM)
    M_cream_d = cel("KremArka", [P["s3"], P["s3"], P["s2"], P["s2"]])
    M_fes = cel("Fes", [P["red3"], P["red2"], P["red0"], P["raw"]])
    M_puskul = cel("Puskul", [P["ink"], P["ink"], P["ink2"], P["mt5"]])
    M_tepe = cel("FesTepe", [P["red3"], P["red3"], P["red2"], P["red1"]])
    M_golge = px.flat("Golge", P["red3"])

    disk("dis", 54, 0, 3, 5, 7, 1.6, M_gold)
    disk("ic", 46, 0, 3, 0, 2, 0.8, M_red)
    disk("ic_hat", 43, 0, 3, -1.4, 0.8, 0.0, M_gold, ic=41.4)
    # fes: buyuk kesik koni + tepe + pusku (yana sarkan ip)
    silindir("fes", 15, 0, -6, 8, 22, M_fes, seg=32, r2=11)
    silindir("fes_tepe", 11, 0, -6, 19.3, 0.8, M_tepe, seg=28)
    silindir("ip", 0.8, 7.5, -16, 12, 16, M_puskul, seg=6)
    silindir("puskul", 3.4, 7.5, -16, 1.5, 8, M_puskul, seg=10, r2=1.2)
    # yildizlar fesin iki yaninda
    for sx in (-1, 1):
        cokgen("yildiz", yildiz(4.6, 2.0), sx * 27, 8, -2.4, 1.6, 0.3, M_gold)
    # kurdele
    kuyruk = [(-28, 11), (8, 11), (8, -11), (-28, -11), (-18, 0)]
    cokgen("kuyruk_sol", [(-q[0], q[1]) for q in kuyruk], -120, -27, 7, 3, 0.4, M_cream_d)
    cokgen("kuyruk_sag", kuyruk, 120, -27, 7, 3, 0.4, M_cream_d)
    levha("kurdele", 244, 26, 2, 0, -23, -8, 4, 0.8, M_cream)

    ust, alt = YAZI[dil]
    yazi(ust, "elephant", 10, 0, 28, -2.6, 1.6, 0.3, M_cream, maxw=82, aralik=0.2)
    golgeli(alt, "elephant", 16, 0, -30, -11.8, 2.2, 0.5, M_red, M_golge,
            dx=1.0, dz=-1.0, golge_y=-10.2, maxw=218, aralik=0.8)
    px.shear_scene(K_SHEAR * 0.8)


ADAY = {"tabela": c_tabela, "sis": c_sis, "neon": c_neon, "rozet": c_rozet}


def uret(ad, dil):
    ADAY[ad](dil)
    yol = px.render(os.path.join(OUT, "%s_%s.png" % (ad, dil)))
    kotu = px.audit(yol, pal.ALL_HEX, label="%s_%s" % (ad, dil), show=0)
    if kotu:
        px.quantize(yol, pal.ALL_HEX)
    px.outline(yol, hexcol=P["ui5"], alpha=235)
    print("LOGO %s_%s -> %s" % (ad, dil, yol))
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mod = argv[0] if argv else "hepsi"
    adlar = list(ADAY) if mod == "hepsi" else [mod]
    yollar = []
    for ad in adlar:
        for dil in ("tr", "en"):
            yollar.append(uret(ad, dil))
    px.contact(yollar, 2, os.path.join(OUT, "_adaylar_x2.png"), pad=6, scale=2)
    print("LOGO_DONE %s" % mod)


if __name__ == "__main__":
    main()
