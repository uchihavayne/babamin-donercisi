"""ICECEK DOLABI - 3B model + piksel-art render.

Oyundaki karsiligi: js/art.js -> drawDrinkMachine(x, y, w, h, D, t)
Kutu: ST.drinkM = { x: 260, y: 146, w: 62, h: 50 }
Yukseltme: js/data.js UPG 'drink' - lvName:
    1 Icecek standi   2 Hizli dolum   3 Basincli dolum   4 Otomatik dolum

Su anki cizim: gri bir levha uzerinde turuncu ve kirmizi iki duz
dikdortgen. Makinenin GOVDESI yok - post-mix dolum kabini aslinda
paslanmaz bir kabin, onunde isikli lezzet panelleri, altta izgarali
damlalik ve kollu musluklar var. Derinlik yalnizca bu parcalarin
birbirine gore kademelenmesinden dogar.

Boru hattinin uc kurali (blender/README.md): 1 birim = 1 piksel,
anti-alias yok, renk yonetimi kapali.
"""
import sys, os, math
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
import pxcore as px
import palette as pal

OUT = os.path.join(_HERE, "out")


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


def kutu(name, x0, y0, z0, x1, y1, z1, mat, smooth=False):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    ob = new_obj(name, bm, smooth=smooth)
    ob.scale = (abs(x1 - x0), abs(y1 - y0), abs(z1 - z0))
    ob.location = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    ob.data.materials.append(mat)
    return ob


def silindir(name, eksen, a0, a1, r, mat, seg=20, kapak=True):
    """eksen: 'x' | 'y' | 'z'."""
    bm = bmesh.new()
    halka = []
    for t in (a0, a1):
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            c, s = math.cos(a) * r, math.sin(a) * r
            if eksen == 'x':
                vs.append(bm.verts.new((t, c, s)))
            elif eksen == 'y':
                vs.append(bm.verts.new((c, t, s)))
            else:
                vs.append(bm.verts.new((c, s, t)))
        halka.append(vs)
    for k in range(seg):
        bm.faces.new((halka[0][k], halka[0][(k + 1) % seg],
                      halka[1][(k + 1) % seg], halka[1][k]))
    if kapak:
        bm.faces.new(list(reversed(halka[0])))
        bm.faces.new(halka[1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


def sise(name, x, z, r, boy, mat_govde, mat_kapak):
    """Panel uzerindeki sise grafigi: govde + boyun + kapak."""
    silindir(name + "G", 'z', z, z + boy, r, mat_govde, seg=14)
    silindir(name + "B", 'z', z + boy, z + boy + 1.4, r * .42, mat_govde, seg=10)
    silindir(name + "K", 'z', z + boy + 1.4, z + boy + 2.4, r * .52, mat_kapak, seg=10)
    for o in bpy.context.scene.objects:
        if o.name.startswith(name):
            o.location.x = x


# ------------------------------------------------------------- paletler
CELIK = ["#6f777f", "#8b939b", "#b8c0c7", "#dde3e8", "#f2f5f8"]
CELIK_ST = [0.0, 0.20, 0.48, 0.76, 0.93]
KOYU = ["#2b3138", "#3f454e", "#5b626a", "#7d868e"]
TURUNCU = ["#8a4408", "#d8641c", "#f0821c", "#ffb03c", "#ffd08a"]
KIRMIZI = ["#5e1008", "#8e1c14", "#c0281c", "#e05a48", "#f2907a"]
KREM = ["#c8b898", "#e8dcc0", "#f6efdc", "#fffdf2"]
KAHVE = ["#2a1408", "#4a1c10", "#8a3a20", "#c07a58"]


def sahne(kademe=1, akiyor=None):
    """kademe 1..4 (data.js UPG 'drink'). akiyor: None | 'fanta' | 'cola'."""
    px.reset()
    px.setup(66, 54)
    px.ortho_cam(0, 0, 66, 54)
    px.world("#000000", 0.0)

    M_c = px.cel_nx("Celik", CELIK, CELIK_ST, axis="X")
    M_k = px.cel_nx("Koyu", KOYU, [0, .34, .66, .90], axis="X")
    M_t = px.cel_nx("Turuncu", TURUNCU, [0, .18, .44, .72, .92], axis="X")
    M_r = px.cel_nx("Kirmizi", KIRMIZI, [0, .18, .44, .72, .92], axis="X")
    M_kr = px.cel_nx("Krem", KREM, [0, .30, .64, .90], axis="X")
    M_kh = px.cel_nx("Kahve", KAHVE, [0, .34, .68, .92], axis="X")
    M_cam = px.flat_a("Cam", "#cfe4f2", 0.30)

    W, H = 58.0, 46.0
    ON = -7.0          # on yuzun y'si (kameraya yakin)

    # --- ana kabin ---
    # ARKA govde + koyu ic duvar
    kutu("Arka", -W / 2, 1.0, -H / 2, W / 2, 6.0, H / 2, M_c)
    kutu("IcDuvar", -W / 2 + 2, 0.0, -H / 2 + 3, W / 2 - 2, 1.2, H / 2 - 3, M_k)
    # ON YUZ dort parca: ortada servis boslugu kalir
    OY0, OY1 = -H / 2 + 4.0, -2.0        # boslugun dikey araligi
    kutu("OnSol", -W / 2, -6.0, -H / 2, -W / 2 + 5, 1.0, H / 2, M_c)
    kutu("OnSag", W / 2 - 5, -6.0, -H / 2, W / 2, 1.0, H / 2, M_c)
    kutu("OnUst", -W / 2, -6.0, OY1, W / 2, 1.0, H / 2, M_c)
    kutu("OnAlt", -W / 2, -6.0, -H / 2, W / 2, 1.0, OY0, M_c)
    kutu("UstBant", -W / 2 - 1, ON - 0.8, H / 2 - 5.0, W / 2 + 1, 6.0, H / 2 + 1.5, M_k)
    kutu("AltBant", -W / 2 - 1, ON - 0.8, -H / 2 - 1.5, W / 2 + 1, 6.0, -H / 2 + 3.0, M_k)

    # --- iki isikli lezzet paneli: kabinden ONE cikik ---
    for i, (M, mS, mK) in enumerate(((M_t, M_kr, M_t), (M_r, M_kh, M_r))):
        px0 = -W / 2 + 3.0 + i * (W / 2 - 1.0)
        px1 = px0 + (W / 2 - 5.0)
        # cerceve
        kutu("PC%d" % i, px0 - 1, ON - 1.6, 2.0, px1 + 1, ON - 0.4, H / 2 - 6.0, M_k)
        # isikli yuz
        kutu("PY%d" % i, px0, ON - 2.4, 3.0, px1, ON - 1.4, H / 2 - 7.0, M)
        # sise grafigi
        sise("S%d" % i, (px0 + px1) / 2, 6.0, 2.6, 8.0, mS, mK)
        for o in bpy.context.scene.objects:
            if o.name.startswith("S%d" % i):
                o.location.y = ON - 3.0

    # boslugun tavani: musluklarin oturdugu koyu tabla
    kutu("BoslukTavan", -W / 2 + 5, -1.0, -3.4, W / 2 - 5, 1.0, -2.0, M_k)

    # --- muslukler: govde + kol ---
    for i in range(2):
        mx = -W / 2 + 9.0 + i * (W - 18.0)
        kutu("MG%d" % i, mx - 2.5, ON - 2.6, -4.0, mx + 2.5, ON + 1.0, 1.0, M_c)
        silindir("MB%d" % i, 'z', -8.0, -4.0, 1.2, M_c, seg=12)
        for o in bpy.context.scene.objects:
            if o.name == "MB%d" % i:
                o.location = (mx, ON - 1.2, 0)
        # kol
        kutu("MK%d" % i, mx - 0.8, ON - 4.2, -1.0, mx + 0.8, ON - 2.4, 3.5, M_k)

    # --- akan icecek ---
    if akiyor:
        mx = -W / 2 + 9.0 if akiyor == 'fanta' else W / 2 - 9.0
        silindir("Akis", 'z', -H / 2 + 8.0, -8.0, 0.9,
                 M_t if akiyor == 'fanta' else M_r, seg=10)
        for o in bpy.context.scene.objects:
            if o.name == "Akis":
                o.location = (mx, ON - 1.2, 0)

    # --- damlalik: oyugun ICINDE, izgarasi ustten gorunur ---
    DY = -H / 2 + 5.0
    kutu("Damlalik", -W / 2 + 5, ON - 1.0, DY, W / 2 - 5, 4.5, DY + 2.2, M_k)
    for g in range(13):
        gx = -W / 2 + 6.5 + g * ((W - 13.0) / 12.0)
        kutu("Izgara%d" % g, gx - 0.4, ON - 1.2, DY + 1.6,
             gx + 0.4, 4.0, DY + 2.6, M_c)
    # bardak sehpasi: damlaligin ustunde ince celik cubuk
    kutu("Sehpa", -W / 2 + 6, ON - 1.4, DY + 2.6, W / 2 - 6, 4.0, DY + 3.2, M_c)

    # --- kademeye gore ek donanim ---
    if kademe >= 2:
        # Hizli dolum: ustte basinc gostergesi
        silindir("Saat", 'y', ON - 3.2, ON - 1.6, 2.4, M_c, seg=16)
        for o in bpy.context.scene.objects:
            if o.name == "Saat":
                o.location = (0, 0, H / 2 - 3.2)
        kutu("SaatIc", -1.6, ON - 3.4, H / 2 - 4.8, 1.6, ON - 3.3, H / 2 - 1.6, M_kr)
    if kademe >= 3:
        # Basincli dolum: yanlarda karbonasyon tupleri
        for s in (-1, 1):
            silindir("Tup%d" % s, 'z', -H / 2 + 4, H / 2 - 8, 2.2, M_c, seg=14)
            for o in bpy.context.scene.objects:
                if o.name == "Tup%d" % s:
                    o.location = (s * (W / 2 + 2.6), 0, 0)
    if kademe >= 4:
        # Otomatik dolum: dijital panel + sensor
        kutu("Dijital", -8.0, ON - 3.0, H / 2 - 4.6, 8.0, ON - 2.2, H / 2 - 1.4, M_k)
        for d in range(5):
            kutu("Hane%d" % d, -6.5 + d * 3.0, ON - 3.3, H / 2 - 4.0,
                 -5.0 + d * 3.0, ON - 3.1, H / 2 - 2.0,
                 px.flat("HaneM%d" % d, "#7dff7a"))

    px.shear_scene(0.22)


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (CELIK, KOYU, TURUNCU, KIRMIZI, KREM, KAHVE):
        ok += g
    ok += ["#7dff7a", "#cfe4f2"]
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "look"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "i_%s.png" % ad)), "#2b2018", 105)

    for i, (k, ak) in enumerate(((1, None), (2, None), (3, None), (4, None),
                                 (1, 'fanta'), (4, 'cola'))):
        sahne(kademe=k, akiyor=ak)
        paths.append(cek("ic%d" % i))
    px.audit(paths[0], allowed(), "icecek", show=22)
    px.contact(paths, 3, os.path.join(OUT, "icecek_x5.png"), scale=5)
    px.contact(paths, 6, os.path.join(OUT, "icecek_x2.png"), scale=2)
    print("ICECEK_DONE %s" % mode)


if __name__ == "__main__":
    main()
