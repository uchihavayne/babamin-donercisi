"""GARNITURLER - 3B model + piksel-art render.

Oyundaki karsiliklari:
  js/art.js -> pickleSlice()        tursu dilimi   (tursu tepsisi)
  js/art.js -> drawTomatoSlice()    domates dilimi (garnitur tepsisi sol)
  js/art.js -> drawPepper()         sivri biber    (garnitur tepsisi sag)

Neden 3B: bu parcalar tepside ONLUK bir yigin halinde, her biri farkli
acidan duruyor. Elde her aciyi ayri cizmek yerine modeli bir kez kurup
donduruyoruz; ayni parca 6 acidan cikiyor, yigin tekrar etmiyor.

Boru hattinin uc kurali (bkz. blender/README.md):
  1 birim = 1 piksel | anti-alias yok | renk yonetimi kapali.
Golgeleme isikla degil cel_nx ile: ton yuzey normalinden okunuyor,
oyunun kendi shadeCol() kademelerinin karsiligi.

Yerel koordinat: (0,0) = parcanin merkezi. blender_z = -yerel_y.
"""
import sys, os, math
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
import pxcore as px
import palette as pal

OUT = os.path.join(_HERE, "out")

CANVAS = 22          # her parca 22x22 tuvale rendere edilir
SHEAR = 0.55         # tepsilerdeki 3/4 egim (trayBase ile ayni his)


def gz(y):
    return -float(y)


# ------------------------------------------------------------------ mesh
def new_obj(name, bm, smooth=True):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    if smooth:
        for p in me.polygons:
            p.use_smooth = True
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    return ob


def disk(name, r, kalin, seg=40, dalga=0.0, dalga_n=9.0, mat=None):
    """Yatik silindir: dilim govdesi. dalga>0 ise cevre tirtikli
    (tursunun kabugu duz degil, oluklu)."""
    bm = bmesh.new()
    halka = []
    for s in (-1, 1):
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            rr = r * (1.0 + dalga * math.sin(a * dalga_n))
            vs.append(bm.verts.new((math.cos(a) * rr, s * kalin / 2, math.sin(a) * rr)))
        halka.append(vs)
    for k in range(seg):
        bm.faces.new((halka[0][k], halka[0][(k + 1) % seg],
                      halka[1][(k + 1) % seg], halka[1][k]))
    bm.faces.new(list(reversed(halka[0])))
    bm.faces.new(halka[1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    if mat:
        ob.data.materials.append(mat)
    return ob


def dilim_yuzu(name, r, z, seg=36, mat=None, dalga=0.0, dalga_n=9.0):
    """Dilimin kesik YUZU - govdenin biraz onunde duran duz daire."""
    bm = bmesh.new()
    orta = bm.verts.new((0.0, z, 0.0))
    vs = []
    for j in range(seg):
        a = 2 * math.pi * j / seg
        rr = r * (1.0 + dalga * math.sin(a * dalga_n))
        vs.append(bm.verts.new((math.cos(a) * rr, z, math.sin(a) * rr)))
    for k in range(seg):
        bm.faces.new((orta, vs[k], vs[(k + 1) % seg]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=False)
    if mat:
        ob.data.materials.append(mat)
    return ob


def dilim(name, a0, a1, r0, r1, z, mat=None, seg=10):
    """Kesik yuzdeki bir DILIM (locule) - domatesin ic bolmeleri."""
    bm = bmesh.new()
    vs = []
    for i in range(seg + 1):
        a = math.radians(a0 + (a1 - a0) * i / seg)
        vs.append((math.cos(a), math.sin(a)))
    ic = [bm.verts.new((c * r0, z, s * r0)) for c, s in vs]
    dis = [bm.verts.new((c * r1, z, s * r1)) for c, s in vs]
    for k in range(seg):
        bm.faces.new((ic[k], dis[k], dis[k + 1], ic[k + 1]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=False)
    if mat:
        ob.data.materials.append(mat)
    return ob


def kapsul(name, boy, r0, r1, egri=0.0, seg=26, rings=22, mat=None):
    """Sivri biber govdesi: X boyunca konik, hafif kavisli, ucu sivri."""
    bm = bmesh.new()
    prev = None
    first = None
    for i in range(rings + 1):
        u = i / rings
        x = -boy / 2 + u * boy
        r = r0 + (r1 - r0) * u
        uc = 0.14
        if u < uc:
            r *= math.sin(u / uc * math.pi / 2) ** 0.55
        elif u > 1 - uc:
            r *= math.sin((1 - u) / uc * math.pi / 2) ** 0.85
        r = max(0.18, r)
        kav = math.sin(u * math.pi) * egri
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            # biberin uzunlamasina olugu
            rr = r * (1 + 0.10 * math.sin(a * 3.0))
            vs.append(bm.verts.new((x, math.sin(a) * rr, math.cos(a) * rr + kav)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        else:
            first = vs
        prev = vs
    bm.faces.new(list(reversed(first)))
    bm.faces.new(prev)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    if mat:
        ob.data.materials.append(mat)
    return ob


def kup(name, x, y, sx, sy, sz_, col, depth=-8.0):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    ob = new_obj(name, bm, smooth=False)
    ob.scale = (float(sx), float(sz_), float(sy))
    ob.location = (float(x), float(depth), gz(y))
    ob.data.materials.append(px.flat(name + "M", col))
    return ob


def yaprak(name, w, h, kirisik=0.0, mat=None, nx=18, ny=14):
    """Marul yapragi: dalgali yuzey. Kenarlar kivrik, ortasi kabarik."""
    bm = bmesh.new()
    grid = []
    for j in range(ny + 1):
        v = j / ny
        satir = []
        for i in range(nx + 1):
            u = i / nx
            x = (u - .5) * w
            y = (v - .5) * h
            # elips kirpma: yaprak koseleri yuvarlak
            k = 1.0 - ((x / (w / 2)) ** 2 + (y / (h / 2)) ** 2)
            if k < 0:
                k = 0
            z = math.sqrt(k) * 1.6
            z += math.sin(u * 9.0) * math.cos(v * 5.0) * kirisik
            satir.append(bm.verts.new((x, -z, gz(y))))
        grid.append(satir)
    def icinde(i, j):
        u = i / nx; v = j / ny
        x = (u - .5) * w; y = (v - .5) * h
        return ((x / (w / 2)) ** 2 + (y / (h / 2)) ** 2) <= 1.02
    for j in range(ny):
        for i in range(nx):
            # elips disindaki yuzu HIC kurma: yoksa siluet dikdortgen cikiyor
            if not (icinde(i, j) and icinde(i + 1, j) and
                    icinde(i + 1, j + 1) and icinde(i, j + 1)):
                continue
            bm.faces.new((grid[j][i], grid[j][i + 1],
                          grid[j + 1][i + 1], grid[j + 1][i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    if mat:
        ob.data.materials.append(mat)
    return ob


# ------------------------------------------------------------- sahneler
# Kesik yuzler kameraya bakar -> ton normalin Z bilesenine gore (axis="Z"),
# yani isik ustten. Yuvarlak govdelerde axis="X": oyunun sisi de boyle.

def sahne_domates(aci=0.0):
    """DOMATES DILIMI. Oyundaki hali duz bir kirmizi disk + birkac cekirdek.
    Gercek kesitte: koyu kabuk halkasi, soluk perikarp, ic bolmeler ve
    aralarinda jel + cekirdek. Bolmeler radyal, hepsi ayni degil."""
    px.reset()
    px.setup(CANVAS, CANVAS)
    px.ortho_cam(0, 0, CANVAS, CANVAS)
    px.world("#000000", 0.0)

    M_kabuk = px.cel_nx("Kabuk", ["#8e2018", "#b8302a", "#d8443a", "#f2887a"],
                        [0.0, 0.30, 0.62, 0.90], axis="Z")
    M_et = px.cel_nx("Et", ["#c4382c", "#e2564a", "#f07a68", "#ff9c8a"],
                     [0.0, 0.28, 0.60, 0.88], axis="Z")
    M_jel = px.flat("Jel", "#ffc0a8")
    M_cek = px.flat("Cekirdek", "#f7e6b0")

    r = 7.4
    disk("Govde", r, 2.2, dalga=0.012, mat=M_kabuk)
    dilim_yuzu("Yuz", r - 0.9, -1.25, mat=M_et)
    # ic bolmeler: 5 locule, biri digerlerinden genis (dogal duruyor)
    # 5 bolme 14px'te gurultuye donuyordu: 3 genis bolme okunuyor
    paylar = [12, 128, 244, 372]
    for i in range(3):
        dilim("Loc%d" % i, paylar[i] + 9, paylar[i + 1] - 9,
              1.6, r - 1.9, -1.45, mat=M_jel)
    for i in range(3):
        a = math.radians((paylar[i] + paylar[i + 1]) / 2)
        for k in (-1, 1):
            rr = 3.4 + k * 1.5
            kup("Cek%d_%d" % (i, k), math.cos(a) * rr, -math.sin(a) * rr,
                1.0, 1.0, 0.6, "#f7e6b0", depth=-1.9)
    # merkez kolumella
    kup("Orta", 0, 0, 1.6, 1.6, 0.6, "#ffd2b8", depth=-1.9)

    if aci:
        for ob in bpy.context.scene.objects:
            if ob.type == "MESH":
                ob.rotation_euler = (0, math.radians(aci), 0)
    px.shear_scene(SHEAR)


def sahne_tursu(aci=0.0):
    """TURSU DILIMI. Kabuk oluklu (tirtikli cevre), et yari saydam yesil,
    ortada cekirdek yatagi. Oyundaki hali duz elipsler."""
    px.reset()
    px.setup(CANVAS, CANVAS)
    px.ortho_cam(0, 0, CANVAS, CANVAS)
    px.world("#000000", 0.0)

    M_kabuk = px.cel_nx("TKabuk", ["#22350a", "#3f5c14", "#5d8420", "#8fb63a"],
                        [0.0, 0.26, 0.58, 0.88], axis="Z")
    M_et = px.cel_nx("TEt", ["#6d9127", "#9dbe45", "#bcd668", "#dcee9a"],
                     [0.0, 0.24, 0.56, 0.86], axis="Z")
    M_cek = px.flat("TCek", "#e2efa4")

    r = 6.9
    # oluk sigdi, yuvarlak yesil bir lekeydi: daha derin, daha az sayida
    disk("TGovde", r, 2.0, dalga=0.155, dalga_n=7.0, mat=M_kabuk)
    dilim_yuzu("TYuz", r - 1.4, -1.15, mat=M_et, dalga=0.13, dalga_n=7.0)
    # cekirdek yatagi: ortada ucgen dizilim
    for i in range(3):
        a = math.radians(90 + i * 120)
        kup("TC%d" % i, math.cos(a) * 1.5, -math.sin(a) * 1.5,
            0.85, 0.85, 0.6, "#e2efa4", depth=-1.75)
    kup("TC3", 0, 0, 0.8, 0.8, 0.6, "#eef6c4", depth=-1.75)

    if aci:
        for ob in bpy.context.scene.objects:
            if ob.type == "MESH":
                ob.rotation_euler = (0, math.radians(aci), 0)
    px.shear_scene(SHEAR)


def sahne_biber(egri=1.4, boy=13.0):
    """SIVRI BIBER. Uzun, kavisli, uc olugu belirgin, sapi kivrik."""
    px.reset()
    px.setup(CANVAS + 8, CANVAS)
    px.ortho_cam(0, 0, CANVAS + 8, CANVAS)
    px.world("#000000", 0.0)

    # YATAY govde: ton dikey normalden. axis="X" iken govde boyunca
    # normal.x ~0 kaliyor, biber tek duz yesil serit cikiyordu.
    M_biber = px.cel_nx("Biber", ["#2c4a10", "#48731a", "#6d9c28", "#a4cc4a", "#d8ee8a"],
                        [0.0, 0.18, 0.44, 0.72, 0.92], axis="Z")
    M_sap = px.cel_nx("Sap", ["#3d5219", "#5b7726", "#7fa138"],
                      [0.0, 0.38, 0.78], axis="Z")

    # koniklik cok sertti: govde yalniz sol ucta kalip geri kalani
    # serit gibi okunuyordu
    ob = kapsul("BGovde", boy, 3.4, 1.7, egri=egri, mat=M_biber)
    ob.rotation_euler = (0, math.radians(-10), 0)
    sap = kapsul("BSap", 4.0, 1.0, 0.6, egri=0.5, mat=M_sap)
    sap.location = (-boy / 2 - 1.2, 0, 1.3)
    sap.rotation_euler = (0, math.radians(30), 0)
    # Biber tepsiye YATIK duruyor; tam shear onu yassi bir seride
    # cevirip govdesini yok ediyordu.
    px.shear_scene(SHEAR * 0.45)


def sahne_sogan():
    """SOGAN HALKASI - oyunda YOK, oneri. Ic ice iki halka, ince, beyaza
    yakin, kenarinda mor kabuk izi."""
    px.reset()
    px.setup(CANVAS, CANVAS)
    px.ortho_cam(0, 0, CANVAS, CANVAS)
    px.world("#000000", 0.0)

    # Ilk denemede palet neredeyse beyazdi: saydam zeminde yalniz kontur
    # okunuyordu. Oyunun kemik tonlarina cekildi, mor kabuk izi eklendi.
    M_dis = px.cel_nx("SDis", ["#8a7a86", "#b3a684", "#d6cbae", "#efe7d0", "#fffdf2"],
                      [0.0, 0.22, 0.50, 0.78, 0.94], axis="Z")
    M_ic = px.cel_nx("SIc", ["#9a8a96", "#c0b49a", "#e0d6bc", "#f6f0e2"],
                     [0.0, 0.26, 0.58, 0.88], axis="Z")

    # Halkalari SILINDIR DUVARI olarak kurmustum: onden bakinca ince bir
    # cember cikiyordu, 14px'te gurultuden ibaretti. Tepside halka YASSI
    # durur - annulus (yassi halka) olarak kuruluyor.
    seg = 44
    for i, (ric, rdis, z, mat) in enumerate(((5.4, 7.2, -1.6, M_dis),
                                             (3.2, 4.8, -1.9, M_ic),
                                             (1.2, 2.6, -2.2, M_dis))):
        bm = bmesh.new()
        ic, dis = [], []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            d = 1 + 0.035 * math.sin(a * 5)
            ic.append(bm.verts.new((math.cos(a) * ric * d, z, math.sin(a) * ric * d)))
            dis.append(bm.verts.new((math.cos(a) * rdis * d, z, math.sin(a) * rdis * d)))
        for k in range(seg):
            bm.faces.new((ic[k], dis[k], dis[(k + 1) % seg], ic[(k + 1) % seg]))
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        o = new_obj("Halka%d" % i, bm, smooth=False)
        o.data.materials.append(mat)
    px.shear_scene(SHEAR)


def sahne_marul():
    """MARUL - oyunda YOK, oneri. Kirisik yaprak, ortada acik damar."""
    px.reset()
    px.setup(CANVAS + 4, CANVAS)
    px.ortho_cam(0, 0, CANVAS + 4, CANVAS)
    px.world("#000000", 0.0)

    # tepside koyu bir hoyuk gibiydi: aydinlik uclar one cekildi
    M_yaprak = px.cel_nx("Marul", ["#5b7726", "#7fa138", "#a8c257", "#cfe08a", "#e8f2b8"],
                         [0.0, 0.16, 0.40, 0.68, 0.90], axis="Z",
                         noise=0.02, noise_scale=3.0)
    yaprak("Yaprak", 19.0, 13.0, kirisik=1.15, mat=M_yaprak)
    px.shear_scene(SHEAR)


def sahne_limon():
    """LIMON DILIMI - oyunda YOK, oneri. Iskender/durum yanina."""
    px.reset()
    px.setup(CANVAS, CANVAS)
    px.ortho_cam(0, 0, CANVAS, CANVAS)
    px.world("#000000", 0.0)

    M_kabuk = px.cel_nx("LKabuk", ["#a97724", "#dba53a", "#f7cc63", "#ffe9a3"],
                        [0.0, 0.28, 0.62, 0.90], axis="Z")
    M_et = px.cel_nx("LEt", ["#dba53a", "#f7cc63", "#ffe9a3", "#fff3b0"],
                     [0.0, 0.26, 0.58, 0.88], axis="Z")
    M_zar = px.flat("LZar", "#fff8d0")

    r = 6.8
    disk("LGovde", r, 1.8, dalga=0.02, mat=M_kabuk)
    dilim_yuzu("LYuz", r - 1.1, -1.05, mat=M_et)
    # 8 ince zar 14px'te kayboluyordu: 6 kalin zar
    for i in range(6):
        a0 = i * 60.0
        dilim("LZ%d" % i, a0 - 4.0, a0 + 4.0, 0.9, r - 1.6, -1.25, mat=M_zar, seg=4)
    kup("LOrta", 0, 0, 1.1, 1.1, 0.5, "#fff8d0", depth=-1.6)
    px.shear_scene(SHEAR)


# ------------------------------------------------------------------ denetim
def allowed():
    ok = list(pal.ALL_HEX)
    ok += ["#8e2018", "#b8302a", "#d8443a", "#f2887a",
           "#c4382c", "#e2564a", "#f07a68", "#ff9c8a", "#ffc0a8", "#ffd2b8",
           "#f7e6b0",
           "#22350a", "#3f5c14", "#5d8420", "#8fb63a",
           "#6d9127", "#9dbe45", "#bcd668", "#dcee9a", "#e2efa4", "#eef6c4",
           "#2c4a10", "#48731a", "#6d9c28", "#a4cc4a", "#d8ee8a",
           "#b8a8bc", "#d8cbd8", "#efe7ef", "#fffaf6",
           "#c8bccb", "#e4dae4", "#f6f0f4", "#fffdfa",
           "#fff8d0"]
    return sorted(set(ok))


# ---------------------------------------------------------------------- main
def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "look"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        p = px.render(os.path.join(OUT, "g_%s.png" % ad))
        return px.outline(p, "#2b2018", 105)

    if mode == "look":
        # oyunda VAR olanlarin yeniden tasarimi
        sahne_domates(); paths.append(cek("domates"))
        sahne_tursu();   paths.append(cek("tursu"))
        sahne_biber();   paths.append(cek("biber"))
        # ONERI: oyunda olmayanlar
        sahne_sogan();   paths.append(cek("sogan"))
        sahne_marul();   paths.append(cek("marul"))
        sahne_limon();   paths.append(cek("limon"))
        px.audit(paths[0], allowed(), "domates", show=20)
        px.audit(paths[1], allowed(), "tursu", show=20)
        px.contact(paths, 3, os.path.join(OUT, "garnitur_x6.png"), scale=6)
        px.contact(paths, 6, os.path.join(OUT, "garnitur_x1.png"), scale=1)

    elif mode == "aci":
        # ayni parca farkli acilardan: yigin tekrar etmesin
        for i, a in enumerate((0, 32, 64, 96, 128, 160)):
            sahne_domates(a); paths.append(cek("dom%d" % i))
        for i, a in enumerate((0, 40, 80, 120, 160, 200)):
            sahne_tursu(a); paths.append(cek("tur%d" % i))
        for i, e in enumerate((0.6, 1.0, 1.4, 1.8, 2.2, 2.6)):
            sahne_biber(egri=e, boy=13.0 + i * 0.9); paths.append(cek("bib%d" % i))
        px.contact(paths, 6, os.path.join(OUT, "garnitur_aci_x5.png"), scale=5)
        px.sheet(paths[:6], 6, os.path.join(OUT, "domates_sheet.png"))

    print("GARNITUR_DONE %s" % mode)


if __name__ == "__main__":
    main()
