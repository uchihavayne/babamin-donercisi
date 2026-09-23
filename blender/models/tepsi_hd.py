"""TEZGAH TEPSILERI — remake HD parcalari.

    blender --background --factory-startup --python blender/models/tepsi_hd.py [-- parca ...]
    python blender/hd_atlas.py tepsi_hd tepsi

Oyundaki karsiligi (art.js): trayBase / drawTepsiKasasi / drawTepsiCami /
trayInnerShade + icerik parcalari meatStrip, pickleSlice, fryStick,
drawTomatoSlice, drawPepper, drawYogurtTray. Yerlesim (fillPaint: arkadan
one siralar, kubbe, az malzemede seyrelme) Godot'da ayni algoritmayla HD
parcalari diziyor; Blender yalniz parcalari uretiyor.

Bakis: oyunun sahte 3/4 ustten bakisi = yatay yuzeylere oblik acilim
(shear k=0.5: 2 birim derinlik = 1 ekran pikseli). Kuvetin arka ic duvari
4 px gorunur (art.js trayFloor duvar=4), yan duvarlar 2 px (yan=2).

Capalar (gy asagi, mantik pikseli):
  kuvet_W, golge_W : tepsinin sol-ust kosesi (ST.x, ST.y)
  kasa_102, cam_102: uclu garnitur blogunun sol-ust kosesi (ST.pickle)
  et_*, tursu_*, patates_*, domates_*, biber_* : parcanin merkezi
     (fillPaint'in item(x, y) noktasi)
  yogurt_1..8      : yogurt tepsisinin sol-ust kosesi
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

OUT = os.path.join(_HERE, "out", "tepsi_hd")
P = pal.P
HD = 2
K = 0.5                                # oblik acilim

CELIK = ["#4e565e", "#79828b", "#a9b2ba", "#d2d9e0", "#f4f8fb"]
CELIK_STOP = [0.0, 0.30, 0.55, 0.78, 0.92]
ET = ["#52290a", "#7e4412", "#9c5718", "#bd7024", "#d98f38", "#eeb463", "#ffd291"]
ET_STOP = [0.0, 0.18, 0.32, 0.46, 0.60, 0.76, 0.90]
TURSU_KABUK = ["#22350a", "#2e4a10", "#3f5c14", "#5b7726"]
PATATES = ["#8a5a14", "#b8801e", "#d9a43a", "#f0c860", "#fbe39a"]
DOMATES = ["#6e1812", "#8e2018", "#b8302a", "#d8443a", "#e2564a"]
BIBER = ["#1c2f08", "#2c4a10", "#48731a", "#6d9c28", "#a4cc4a"]
YOGURT = ["#9a927c", "#b0a790", "#c9c0a9", "#ded6c0", "#efe8d6", "#fbf7ea"]

KOKEN = {}          # parca -> (gx0, gy0)


def sahne(gx0, gy0, w, h):
    L._FONTLAR.clear()
    px.reset()
    px.setup(int(w * HD), int(h * HD))
    px.ortho_cam(gx0 + w / 2.0, -(gy0 + h / 2.0), w, h)
    px.world("#000000", 0.0)
    d = Vector((0.40, 0.55, -0.73)).normalized()          # ustten, onden, soldan
    s = px.sun(math.pi, rot=(0, 0, 0))
    s.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def cel(ad, ramp, stops=None):
    return px.cel(ad, ramp, stops)


def link(ob):
    bpy.context.collection.objects.link(ob)
    return ob


def mesh_ob(ad, bm, mat, smooth=False):
    me = bpy.data.meshes.new(ad)
    bm.to_mesh(me)
    bm.free()
    if smooth:
        for p in me.polygons:
            p.use_smooth = True
    ob = link(bpy.data.objects.new(ad, me))
    me.materials.append(mat)
    return ob


def ekran(gx, gy_on, derinlik=0.0):
    """Ekran (gx, gy) + yatay derinlik -> dunya. gy_on: nesnenin ekrandaki on
    kenari; derinlik arkaya dogru dunya birimi (ekranda K kati yukari)."""
    return Vector((gx, derinlik, -gy_on))


# ---------------------------------------------------------------- kuvet
def kuvet(w, h, derin_z=5.0):
    """Tepsi: flans cercevesi + ice egimli duvarlar + zemin, oblik bakis.
    Ekran dikdortgeni (0,0)-(w,h): on kenar gy=h, arka kenar gy=0."""
    M = cel("Celik", CELIK, CELIK_STOP)
    Dy = h / K                                   # arkaya dogru dunya derinligi
    ax0, ax1 = 2.0, w - 2.0
    ay0, ay1 = 2.0 / K, (h - 2.0) / K            # dunya y: on 0 .. arka Dy
    z0 = -h                                       # on kenar ekranda gy=h
    bm = bmesh.new()

    def v(x, y, z):
        return bm.verts.new((x, y, z0 + z))
    # flans: dis dikdortgen - ic agiz (ust yuz) + dis kenar
    t = 0.0
    O = [v(0, 0, t), v(w, 0, t), v(w, Dy, t), v(0, Dy, t)]
    I = [v(ax0, ay0, t), v(ax1, ay0, t), v(ax1, ay1, t), v(ax0, ay1, t)]
    for i in range(4):
        bm.faces.new((O[i], O[(i + 1) % 4], I[(i + 1) % 4], I[i]))
    Ob = [v(0, 0, -1.2), v(w, 0, -1.2), v(w, Dy, -1.2), v(0, Dy, -1.2)]
    for i in range(4):
        bm.faces.new((Ob[i], Ob[(i + 1) % 4], O[(i + 1) % 4], O[i]))
    # ic duvarlar -> zemin (yanlar 2 px iceri, derinlik derin_z)
    ix0, ix1 = ax0 + 2.0, ax1 - 2.0
    iy0, iy1 = ay0 + 1.0, ay1 - 1.0
    Z = [v(ix0, iy0, -derin_z), v(ix1, iy0, -derin_z), v(ix1, iy1, -derin_z), v(ix0, iy1, -derin_z)]
    for i in range(4):
        bm.faces.new((I[i], I[(i + 1) % 4], Z[(i + 1) % 4], Z[i]))
    bm.faces.new(Z)
    # Normaller elle: acik bir kabuk oldugu icin recalc ic/dis ayirt edemiyor.
    # Yatay yuzler yukari; ic duvarlar kuvetin ortasina; flans dis kenari disa.
    orta = Vector((w / 2.0, Dy / 2.0, 0))
    bm.normal_update()
    for f in bm.faces:
        c = f.calc_center_median()
        n = f.normal
        zs = [vv.co.z - z0 for vv in f.verts]
        if abs(n.z) > 0.9:
            istenen = Vector((0, 0, 1))
        elif min(zs) < -1.5:                       # ic duvar
            istenen = Vector((orta.x - c.x, orta.y - c.y, 0))
        else:                                      # flans dis kenari
            istenen = Vector((c.x - orta.x, c.y - orta.y, 0))
        if n.dot(istenen) < 0:
            f.normal_flip()
    return mesh_ob("kuvet", bm, M)


def ic_golge(w, h):
    """trayInnerShade: arka duvarin yemege dusurdugu golge + on kenar isigi.
    Yari saydam: oyunda alfa ile ciziliyor, burada tek renk maske."""
    Mk = px.flat("Golge", "#000000")
    Ma = px.flat("Isik", "#ffffff")
    z = -h - 0.1
    L.kutu("g_ust", 2, w - 2, -4, -2, -1, -0.5, Mk)
    L.kutu("g_sol", 2, 4, -(h - 7), -2, -1, -0.5, Mk)
    L.kutu("g_sag", w - 4, w - 2, -(h - 7), -2, -1, -0.5, Mk)
    L.kutu("isik", 3, w - 3, -(h - 6), -(h - 7), -1, -0.5, Ma)


def kasa(w, h, bolme=3):
    """drawTepsiKasasi: uclu blogun celik cercevesi ve bolme cubuklari."""
    M = cel("KasaCelik", ["#4a525a", "#6f767e", "#8e959d", "#b8c0c8", "#dfe5eb"], CELIK_STOP)
    Dy = h / K
    z0 = -h
    for ad, x0, x1, y0, y1 in (("on", -3, w + 3, -8, 0), ("arka", -3, w + 3, Dy, Dy + 8),
                               ("sol", -3, 0, 0, Dy), ("sag", w, w + 3, 0, Dy)):
        L.kutu(ad, x0, x1, z0 - 1.5, z0 + 1.0, y0, y1, M)
    for i in range(1, bolme):
        bx = round(w / bolme * i)
        L.kutu("bolme", bx - 1, bx + 1, z0 - 1.0, z0 + 1.0, 0, Dy, M)
    L.kutu("alt", -3, w + 3, z0 - 5.5, z0 - 1.5, -9, -8, cel("KasaAlt", ["#3e464e", "#59636d", "#8e959d"]))


def cam(w, h):
    """drawTepsiCami: egik parlama seritleri + kenar. Beyaz maske; oyunda
    dusuk alfayla ciziliyor."""
    Mb = px.flat("CamSerit", "#ffffff")
    for g in range(0, int(w), 9):
        pts = [(0, 0), (1.2, 0), (7.2, h + 1), (6.0, h + 1)]
        L.cokgen("serit", [(p[0], -p[1]) for p in pts], g, 1, -3, 0.2, 0.0, Mb)
    Mk = px.flat("CamKenar", "#b4d2e6")
    L.cerceve("kenar", w + 2, h + 2, 0.5, 0.6, w / 2.0, -h / 2.0, -3.2, 0.2, Mk)


def garnitur_bolme(w, h):
    M = cel("Bolme", ["#5e666e", "#8a929b", "#c7ced5", "#e6ebef"])
    mid = round(w * .52)
    L.kutu("bolme", mid - 1, mid + 1, -(h - 6), -4, -1.5, 1.5, M)


# ---------------------------------------------------------------- icerik
def serit_mesh(ad, uzun, en, kalin, egri_f, mat, x0=0.0):
    """x boyunca uzun, yatay ince serit (et dilimi, patates). egri_f(u) ->
    (dz, dy): dikey kalkma ve derinlik kaymasi."""
    bm = bmesh.new()
    n = max(4, int(uzun * 2))
    satir = []
    for i in range(n + 1):
        u = i / n
        dz, dy = egri_f(u)
        x = x0 - uzun / 2.0 + uzun * u
        z0 = dz - kalin / 2.0          # parca capaya ORTALI (art.js cubugu y'ye ortalar)
        halka = [bm.verts.new((x, dy - en / 2.0, z0)), bm.verts.new((x, dy + en / 2.0, z0)),
                 bm.verts.new((x, dy + en / 2.0, z0 + kalin)), bm.verts.new((x, dy - en / 2.0, z0 + kalin))]
        satir.append(halka)
    for i in range(n):
        for k in range(4):
            bm.faces.new((satir[i][k], satir[i][(k + 1) % 4], satir[i + 1][(k + 1) % 4], satir[i + 1][k]))
    bm.faces.new(list(reversed(satir[0])))
    bm.faces.new(satir[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return mesh_ob(ad, bm, mat, smooth=True)


def et_parca(tip, uzun):
    M = cel("Et", ET, ET_STOP)
    if tip == "duz":
        serit_mesh("et", uzun, 3.2, 1.3, lambda u: (math.sin(u * 4.2) * 0.35, 0.0), M)
    elif tip == "kivrik":
        serit_mesh("et", uzun, 3.2, 1.3,
                   lambda u: ((max(0.0, (u - .62) / .38) ** 1.5) * 2.4, 0.0), M)
    elif tip == "katli":
        serit_mesh("alt", uzun, 3.2, 1.2, lambda u: (0.0, 0.0), M)
        serit_mesh("ust", uzun * .45, 3.0, 1.2, lambda u: (1.2, 0.2), M, x0=uzun * .275)
    else:                                   # tiknaz
        serit_mesh("et", uzun, 4.4, 2.2, lambda u: (math.sin(u * 3.1) * 0.5, 0.0), M)


def patates(tip, uzun):
    M = cel("Patates", PATATES)
    if tip == "yatik":
        serit_mesh("pat", uzun, 1.8, 1.8, lambda u: (math.sin(u * math.pi) * 0.6, 0.0), M)
    elif tip == "sag" or tip == "sol":
        yon = 1 if tip == "sag" else -1
        ob = serit_mesh("pat", uzun, 1.8, 1.8, lambda u: (0.0, 0.0), M)
        ob.rotation_euler = (0, 0, math.radians(35 * yon))
    else:                                   # dik: yigindan firlamis
        ob = serit_mesh("pat", uzun, 1.8, 1.8, lambda u: (0.0, 0.0), M)
        ob.rotation_euler = (0, math.radians(-80), 0)
        ob.location = (0, 0, uzun / 2.0)


def disk_dilim(ad, r, kalin, halkalar, mat_kenar, olukn=0, cekirdek=None, bolme=0):
    """Yatay disk (tursu / domates dilimi): kenar oluklu, ust yuz halkali."""
    seg = 36
    bm = bmesh.new()
    alt, ust = [], []
    for i in range(seg):
        a = 2 * math.pi * i / seg
        rr = r
        if olukn:
            rr = r * (1.0 + 0.10 * max(0.0, math.cos(a * olukn)))
        alt.append(bm.verts.new((math.cos(a) * rr, math.sin(a) * rr, 0)))
        ust.append(bm.verts.new((math.cos(a) * rr, math.sin(a) * rr, kalin)))
    for i in range(seg):
        bm.faces.new((alt[i], alt[(i + 1) % seg], ust[(i + 1) % seg], ust[i]))
    bm.faces.new(list(reversed(alt)))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    mesh_ob(ad + "_kenar", bm, mat_kenar, smooth=True)
    return None


def yatay_disk(ad, r, z, renk):
    """Ust yuze yatan duz renkli disk."""
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, cap_ends=True, segments=32, radius=r)
    ob = mesh_ob(ad, bm, px.flat(ad, renk))
    ob.location = (0, 0, z)
    return ob


def ortala_z(dz):
    """Sahnedeki tum nesneleri dz kadar kaydir: dilim kalinligi capaya ortali."""
    for ob in bpy.context.scene.objects:
        if ob.type == "MESH":
            ob.location.z += dz


def tursu(r):
    Mk = cel("TursuKabuk", TURSU_KABUK)
    disk_dilim("tursu", r, 1.2, [], Mk, olukn=7)
    yatay_disk("et", r * 0.86, 1.25, "#6d9127")
    yatay_disk("ic", r * 0.62, 1.30, "#9dbe45")
    yatay_disk("isik", r * 0.30, 1.35, "#bcd668")
    for i in range(3):
        a = math.pi / 2 + i * 2 * math.pi / 3
        ob = yatay_disk("cekirdek%d" % i, 0.55, 1.4, "#e2efa4")
        ob.location = (math.cos(a) * r * 0.25, math.sin(a) * r * 0.25, 1.4)
    ortala_z(-0.7)


def domates(r):
    Mk = cel("DomatesKabuk", DOMATES)
    disk_dilim("domates", r, 1.3, [], Mk)
    yatay_disk("et", r * 0.84, 1.35, "#e2564a")
    for i in range(3):
        a = -math.pi / 2 + i * 2 * math.pi / 3
        bm = bmesh.new()
        pts = [(0, 0), (math.cos(a - .25) * r * .7, math.sin(a - .25) * r * .7),
               (math.cos(a + .25) * r * .7, math.sin(a + .25) * r * .7)]
        vs = [bm.verts.new((p[0], p[1], 1.42)) for p in pts]
        bm.faces.new(vs)
        mesh_ob("bolme%d" % i, bm, px.flat("DomatesBolme", "#ffc0a8"))
        sa = a + math.pi / 3
        ob = yatay_disk("tohum%d" % i, 0.6, 1.45, "#f7e6b0")
        ob.location = (math.cos(sa) * r * .55, math.sin(sa) * r * .55, 1.45)
    ob = yatay_disk("gobek", 0.9, 1.46, "#ffd2b8")
    ortala_z(-0.7)


def biber(boy):
    """art.js drawPepper: DIK duran biber, sap ustte, uc capanin (x, y)
    noktasinda; govde asagi dogru sin(u*1.45)*2 kadar kivrilir (flip ayna)."""
    # asagi incelen govdenin normalleri asagi bakiyor: isik ustten geldigi icin
    # neredeyse tamami golgede kaliyordu; ton rampasi yukari kaydirildi
    M = px.cel("Biber", BIBER, bias=0.32)
    bm = bmesh.new()
    seg = 12
    halkalar = []
    n = 16
    wmax = max(2.0, math.floor(boy * .26 + .5))
    for i in range(n + 1):
        u = i / n
        w = wmax * (.62 + u / .22 * .38) if u < .22 else wmax * max(0.04, (1 - (u - .22) / .78)) ** .62
        bend = math.sin(u * 1.45) * 2.0
        gy = -boy + 1 + u * (boy - 1)
        halka = [bm.verts.new((bend + 0.5 + math.cos(2 * math.pi * k / seg) * w,
                               math.sin(2 * math.pi * k / seg) * w * 0.8, -gy)) for k in range(seg)]
        halkalar.append(halka)
    for i in range(n):
        for k in range(seg):
            bm.faces.new((halkalar[i][k], halkalar[i][(k + 1) % seg],
                          halkalar[i + 1][(k + 1) % seg], halkalar[i + 1][k]))
    bm.faces.new(list(reversed(halkalar[0])))
    bm.faces.new(halkalar[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    mesh_ob("biber", bm, M, smooth=True)
    Ms = cel("Sap", ["#2c4a10", "#3d5219", "#5b7726", "#7fa138"])
    canak = bpy.data.objects.new("canak", bpy.data.meshes.new("canak"))
    bm2 = bmesh.new()
    bmesh.ops.create_uvsphere(bm2, u_segments=14, v_segments=8, radius=1.0)
    bm2.to_mesh(canak.data)
    bm2.free()
    bpy.context.collection.objects.link(canak)
    canak.data.materials.append(Ms)
    for p_ in canak.data.polygons:
        p_.use_smooth = True
    canak.scale = (3.6, 2.4, 1.1)
    canak.location = (0.5, 0, boy - 1.6)
    L.silindir("sap", 0.9, 0.5, 0, boy + 1.8, 4.2, Ms, seg=8, eksen="Z")


def yogurt(w, h, seviye):
    """drawYogurtTray kutlesi: seviye 1..8, kasik cukurlari ve kabarma."""
    lvl = seviye / 8.0
    M = cel("Yogurt", YOGURT)
    ax0, ax1 = 4.0, w - 4.0
    zh = (h - 2 - 1) - (2 + 4)                   # F.on - F.zemin
    kaplama = 0.10 + 0.90 * lvl
    on_y = 1.0 / K                                # on kenar dunya y
    arka_y = on_y + (zh * kaplama) / K
    tepe = 0.6 + lvl * 3.2
    bm = bmesh.new()
    NX, NY = 40, 16
    grid = []
    for j in range(NY + 1):
        v = j / NY
        y = on_y + (arka_y - on_y) * v
        satir = []
        for i in range(NX + 1):
            u = i / NX
            x = ax0 + (ax1 - ax0) * u
            kenar = (abs(u - .5) * 2) ** 2.4 * 0.8
            z = tepe * (1 - v * 0.25) * (1 - kenar)
            for (cp, cg, cd) in ((0.70, .20, .26), (0.28, .15, .15)):
                d = abs(u - cp)
                if d < cg:
                    z -= math.cos(d / cg * math.pi * .5) * cd * tepe * 1.6 * (1 - abs(v - .45))
            z += math.sin(i * 1.7 + j * 2.3) * 0.12
            satir.append(bm.verts.new((x, y, -h - 4.6 + max(0.2, z))))
        grid.append(satir)
    for j in range(NY):
        for i in range(NX):
            bm.faces.new((grid[j][i], grid[j][i + 1], grid[j + 1][i + 1], grid[j + 1][i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = mesh_ob("yogurt", bm, M, smooth=True)
    for p in ob.data.polygons:
        if p.normal.z < 0:
            p.flip()


# ---------------------------------------------------------------- uretim
PARCALAR = {}


def parca(ad, tuval, fn, cizgi=None):
    """tuval: (gx0, gy0, w, h) capaya gore."""
    PARCALAR[ad] = (tuval, fn, cizgi)
    KOKEN[ad] = (tuval[0], tuval[1])


for W in (46, 34, 42):
    parca("kuvet_%d" % W, (-5, -6, W + 10, 28 + 13), lambda W=W: kuvet(W, 28))
    parca("golge_%d" % W, (-5, -6, W + 10, 28 + 13), lambda W=W: ic_golge(W, 28))
parca("kasa_102", (-6, -8, 114, 28 + 18), lambda: kasa(102, 28))
parca("cam_102", (-4, -4, 110, 28 + 8), lambda: cam(102, 28))
parca("garnitur_bolme", (-2, -2, 46, 32), lambda: garnitur_bolme(42, 28))

ET_VARYANT = []
for tip, boylar in (("duz", (6, 9, 12, 14)), ("kivrik", (7, 10, 13)), ("katli", (8, 12)), ("tiknaz", (5, 7))):
    for b in boylar:
        ad = "et_%s_%d" % (tip, b)
        ET_VARYANT.append(ad)
        parca(ad, (-10, -8, 20, 14), lambda tip=tip, b=b: et_parca(tip, b), cizgi="#4a2a08")
for r in (6, 7):
    parca("tursu_%d" % r, (-10, -8, 20, 14), lambda r=r: tursu(r), cizgi="#1c2f08")
for tip, boylar in (("yatik", (6, 9, 12)), ("sag", (8, 11)), ("sol", (8, 11)), ("dik", (6, 9))):
    for b in boylar:
        parca("patates_%s_%d" % (tip, b), (-10, -12, 20, 18), lambda tip=tip, b=b: patates(tip, b),
              cizgi="#4a3208")
parca("domates_6", (-9, -7, 18, 14), lambda: domates(6.0), cizgi="#4a1008")
for b in (12, 13, 14):
    parca("biber_%d" % b, (-7, -b - 6, 14, b + 9), lambda b=b: biber(b), cizgi="#1c2f08")
for s in range(1, 9):
    parca("yogurt_%d" % s, (-5, -6, 34 + 10, 28 + 13), lambda s=s: yogurt(34, 28, s))


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi = PARCALAR[ad]
    sahne(gx0, gy0, w, h)
    fn()
    px.shear_scene(K)
    yol = px.render(os.path.join(OUT, ad + ".png"))
    if cizgi:
        px.outline(yol, hexcol=cizgi, alpha=150)
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
    print("TEPSI_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
