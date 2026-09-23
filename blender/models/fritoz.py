"""FRITOZ + AYRAN KAZANI - 3B model + piksel-art render.

Oyundaki karsiliklari:
  js/art.js -> drawFryer(x, y, w, h, F, t)       ST.fryer  58x44
  js/art.js -> drawAyranTank(x, y, w, h, ...)    ST.ayran  28x46

Yukseltmeler (js/data.js):
  UPG 'fryer' : Guclu rezistans / Genis sepet / CIFT HAZNE / Otomatik
  UPG 'ayran' : Ayran kazani / Buyuk kazan

Fritozde asil mesele DERINLIK: yag haznesi govdeye GOMULU olmali,
sepet yagin icinde durmali, rezistans arkada gorunmeli. Duz cizimde
hazne bir dikdortgen lekesi oluyor. 'Cift hazne' kademesi de simdiye
kadar gorsel olarak hic ayrismiyordu.

Ayran kazani: paslanmaz silindir, kubbe kapak, on yuzde seviye
penceresi ve musluk. Su anki cizim dikdortgen bir kutu.

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


def silindir(name, eksen, a0, a1, r, mat, seg=26, kapak=True, r1=None):
    bm = bmesh.new()
    halka = []
    for idx, tt in enumerate((a0, a1)):
        rr = r if (r1 is None or idx == 0) else r1
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            c, s = math.cos(a) * rr, math.sin(a) * rr
            if eksen == 'x':
                vs.append(bm.verts.new((tt, c, s)))
            elif eksen == 'y':
                vs.append(bm.verts.new((c, tt, s)))
            else:
                vs.append(bm.verts.new((c, s, tt)))
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


def kubbe(name, r, yuk, mat, seg=26, rings=8):
    """Kazan kapagi: yarim elipsoit."""
    bm = bmesh.new()
    prev = None
    for i in range(rings + 1):
        v = (math.pi / 2) * i / rings
        sy, cz = math.sin(v), math.cos(v)
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            vs.append(bm.verts.new((math.cos(a) * sy * r,
                                    math.sin(a) * sy * r, cz * yuk)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


def sepet(name, x0, x1, z0, z1, mat, tel=9):
    """Kizartma sepeti: tel kafes + sap."""
    kutu(name + "Cerceve", x0, -3.0, z0, x1, 3.0, z0 + 0.8, mat)
    kutu(name + "Ust", x0, -3.0, z1, x1, 3.0, z1 + 0.8, mat)
    for i in range(tel):
        tx = x0 + (x1 - x0) * (i + .5) / tel
        kutu(name + "T%d" % i, tx - 0.35, -2.6, z0, tx + 0.35, 2.6, z1, mat)
    # yan duvarlar
    kutu(name + "YS", x0, -3.0, z0, x0 + 0.8, 3.0, z1, mat)
    kutu(name + "YG", x1 - 0.8, -3.0, z0, x1, 3.0, z1, mat)


# ------------------------------------------------------------- paletler
TEAL = ["#24494b", "#3f7d80", "#4e9295", "#5aa3a6", "#7cc4c6"]
TEAL_ST = [0.0, 0.20, 0.48, 0.76, 0.93]
CELIK = ["#5f6672", "#878e99", "#aeb5be", "#d3d8de", "#f2f4f6"]
KOYU = ["#1b2126", "#2f3740", "#4a525c", "#6b737d"]
YAG = ["#5e3f0c", "#7a5a14", "#a8811f", "#bd932c", "#d0a93c"]
MAVI = ["#1c3a66", "#24487a", "#3f79c0", "#6b9ad8", "#a8c8ee"]
AYRAN = ["#cfcabc", "#e8e4d8", "#f6f4ea", "#ffffff"]


def sahne_fritoz(kademe=1):
    """kademe 1..4. 3 ve ustu CIFT HAZNE."""
    px.reset()
    px.setup(64, 50)
    px.ortho_cam(0, 0, 64, 50)
    px.world("#000000", 0.0)

    M_t = px.cel_nx("Teal", TEAL, TEAL_ST, axis="X")
    M_c = px.cel_nx("Celik", CELIK, [0, .20, .48, .76, .93], axis="X")
    M_k = px.cel_nx("Koyu", KOYU, [0, .34, .66, .90], axis="X")
    M_y = px.cel_nx("Yag", YAG, [0, .18, .46, .74, .92], axis="Z")

    W, H = 56.0, 40.0
    cift = kademe >= 3

    # --- arka sicrama paneli ---
    kutu("Sicrama", -W / 2 + 2, 2.0, H / 2 - 4, W / 2 - 2, 5.0, H / 2 + 8, M_t)
    # --- govde: on yuz cerceve, ortada hazne oyugu ---
    kutu("Arka", -W / 2, 1.0, -H / 2, W / 2, 5.0, H / 2, M_t)
    HZ0, HZ1 = -H / 2 + 9.0, H / 2 - 3.0     # hazne dikey araligi
    kutu("OnSol", -W / 2, -5.0, -H / 2, -W / 2 + 4, 1.0, H / 2, M_t)
    kutu("OnSag", W / 2 - 4, -5.0, -H / 2, W / 2, 1.0, H / 2, M_t)
    kutu("OnUst", -W / 2, -5.0, HZ1, W / 2, 1.0, H / 2, M_t)
    kutu("OnAlt", -W / 2, -5.0, -H / 2, W / 2, 1.0, HZ0, M_t)

    # --- hazne(ler) ---
    hazneler = [(-W / 2 + 5, -1.0)] if not cift else [(-W / 2 + 5, -1.5), (2.5, W / 2 - 5)]
    if not cift:
        hazneler = [(-W / 2 + 5, W / 2 - 5)]
    for i, (hx0, hx1) in enumerate(hazneler):
        # Hazne cukuru YALNIZ ARKA DUVAR olmali: kati kutu yapinca
        # on yuzu yagin onune gecip icerideki her seyi kapatiyordu.
        kutu("HD%d" % i, hx0, 0.0, HZ0, hx1, 1.0, HZ1, M_k)
        kutu("HYS%d" % i, hx0, -4.2, HZ0, hx0 + 1.0, 1.0, HZ1, M_k)
        kutu("HYG%d" % i, hx1 - 1.0, -4.2, HZ0, hx1, 1.0, HZ1, M_k)
        kutu("HAlt%d" % i, hx0, -4.2, HZ0, hx1, 1.0, HZ0 + 1.0, M_k)
        # yag
        yy = HZ1 - 5.0
        kutu("Yag%d" % i, hx0 + 1, -3.9, HZ0 + 1.5, hx1 - 1, 0.0, yy, M_y)
        # yagin ust yuzu daha acik
        kutu("YagUst%d" % i, hx0 + 1, -4.0, yy - 1.0, hx1 - 1, 0.0, yy, M_y)
        # rezistans: yagin icinde kivrimli boru
        for r in range(3):
            rz = HZ0 + 3.0 + r * 1.8
            kutu("Rez%d_%d" % (i, r), hx0 + 2, -2.0, rz, hx1 - 2, -1.2, rz + 0.7, M_c)
        # sepet: yagin icinde
        genis = 1.0 if kademe >= 2 else 0.78
        sx0 = hx0 + 1.5 + (hx1 - hx0) * (1 - genis) * .5
        sx1 = hx1 - 1.5 - (hx1 - hx0) * (1 - genis) * .5
        sepet("Sep%d" % i, sx0, sx1, yy - 4.0, yy + 2.0, M_c)
        # sap: hazne kenarindan YUKARI kalkar (govdeye girmez)
        kutu("Sap%d" % i, sx1 - 1.0, -3.0, yy + 2.0, sx1 + 0.2, -2.2, HZ1 + 4.0, M_c)
        kutu("SapUc%d" % i, sx1 - 3.0, -3.2, HZ1 + 4.0, sx1 + 0.4, -2.0, HZ1 + 5.2, M_k)

    # --- on kontrol paneli ---
    kutu("Panel", -W / 2 + 3, -6.0, -H / 2 + 1.0, W / 2 - 3, -4.6, -H / 2 + 8.0, M_k)
    kutu("Ekran", -W / 2 + 6, -6.4, -H / 2 + 2.5, -W / 2 + 20, -6.0, -H / 2 + 6.5,
         px.flat("EkranM", "#1b2126"))
    for d in range(3):                       # rakamlar
        kutu("Hane%d" % d, -W / 2 + 8 + d * 4, -6.6, -H / 2 + 3.5,
             -W / 2 + 10.5 + d * 4, -6.5, -H / 2 + 5.8,
             px.flat("HaneM%d" % d, "#ff9c2e"))
    # dugmeler
    for b in range(2):
        silindir("Dug%d" % b, 'y', -6.8, -6.0, 1.4, M_c, seg=12)
        for o in bpy.context.scene.objects:
            if o.name == "Dug%d" % b:
                o.location = (W / 2 - 12 + b * 5, 0, -H / 2 + 4.5)

    if kademe >= 4:
        # Otomatik fritoz: sepetleri kaldiran kol + sensor
        kutu("Kol", -W / 2 + 4, -4.0, H / 2 - 1.0, W / 2 - 4, -3.2, H / 2 + 1.0, M_c)
        kutu("Motor", W / 2 - 10, -4.4, H / 2 + 1.0, W / 2 - 4, -3.0, H / 2 + 5.0, M_k)
        kutu("Isik", W / 2 - 8, -4.6, H / 2 + 2.0, W / 2 - 6, -4.4, H / 2 + 3.5,
             px.flat("IsikM", "#7dff7a"))
    px.shear_scene(0.22)


def sahne_ayran(dolu=0.7, buyuk=False, akiyor=False):
    """Ayran kazani. buyuk=True -> UPG 'ayran' sv2."""
    px.reset()
    px.setup(34, 52)
    px.ortho_cam(0, 0, 34, 52)
    px.world("#000000", 0.0)

    M_c = px.cel_nx("Celik", CELIK, [0, .20, .48, .76, .93], axis="X")
    M_k = px.cel_nx("Koyu", KOYU, [0, .34, .66, .90], axis="X")
    M_m = px.cel_nx("Mavi", MAVI, [0, .18, .46, .74, .92], axis="X")
    M_a = px.cel_nx("Ayran", AYRAN, [0, .34, .68, .92], axis="Z")

    R = 11.0 if buyuk else 9.0
    Z0, Z1 = -16.0, (14.0 if buyuk else 11.0)

    # --- ayaklar ---
    for s in (-1, 1):
        kutu("Ayak%d" % s, s * (R - 3) - 1.2, -1.5, Z0 - 4.0,
             s * (R - 3) + 1.2, 1.5, Z0, M_k)
    # --- govde: dikey silindir ---
    silindir("Govde", 'z', Z0, Z1, R, M_c, seg=30)
    # --- kubbe kapak ---
    kp = kubbe("Kapak", R * 0.98, 5.0, M_c)
    kp.location.z = Z1
    silindir("Tutamak", 'z', Z1 + 5.0, Z1 + 7.5, 1.6, M_k, seg=12)
    # --- mavi etiket bandi: govdeyi sarar ---
    silindir("Etiket", 'z', Z1 - 12.0, Z1 - 3.0, R + 0.15, M_m, seg=30, kapak=False)
    # etiket uzerine ayran bardagi
    kutu("Bardak", -2.2, -R - 0.6, Z1 - 10.5, 2.2, -R - 0.3, Z1 - 4.5,
         px.flat("BardakM", "#f6f4ea"))
    kutu("BardakA", -1.6, -R - 0.9, Z1 - 10.0, 1.6, -R - 0.6, Z1 - 5.5,
         px.flat("BardakAM", "#ffffff"))
    # --- seviye penceresi: on yuzde dikey cam serit ---
    kutu("PenCerceve", R - 5.0, -R - 0.9, Z0 + 3.0, R - 1.6, -R + 1.0, Z1 - 13.0, M_k)
    ph0, ph1 = Z0 + 4.0, Z1 - 14.0
    kutu("Seviye", R - 4.4, -R - 1.2, ph0, R - 2.2, -R + 0.5,
         ph0 + (ph1 - ph0) * dolu, M_a)
    # --- musluk ---
    kutu("MuslukG", -2.0, -R - 1.6, Z0 + 4.0, 2.0, -R + 1.0, Z0 + 8.0, M_c)
    silindir("MuslukB", 'z', Z0 + 1.0, Z0 + 4.5, 1.1, M_c, seg=12)
    for o in bpy.context.scene.objects:
        if o.name == "MuslukB":
            o.location = (0, -R - 0.4, 0)
    kutu("Kol", -0.7, -R - 3.0, Z0 + 6.0, 0.7, -R - 1.4, Z0 + 10.0, M_k)
    if akiyor:
        silindir("Akis", 'z', Z0 - 6.0, Z0 + 1.0, 0.8, M_a, seg=10)
        for o in bpy.context.scene.objects:
            if o.name == "Akis":
                o.location = (0, -R - 0.4, 0)
    px.shear_scene(0.18)


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (TEAL, CELIK, KOYU, YAG, MAVI, AYRAN):
        ok += g
    ok += ["#ff9c2e", "#7dff7a", "#1b2126"]
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "fritoz"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "f_%s.png" % ad)), "#2b2018", 105)

    if mode == "fritoz":
        for k in (1, 2, 3, 4):
            sahne_fritoz(kademe=k); paths.append(cek("fr%d" % k))
        px.audit(paths[0], allowed(), "fritoz", show=22)
        px.contact(paths, 2, os.path.join(OUT, "fritoz_x5.png"), scale=5)
    else:
        for i, (d, b, a) in enumerate(((0.85, False, False), (0.45, False, True),
                                       (0.90, True, False), (0.30, True, True))):
            sahne_ayran(dolu=d, buyuk=b, akiyor=a); paths.append(cek("ay%d" % i))
        px.audit(paths[0], allowed(), "ayran", show=22)
        px.contact(paths, 4, os.path.join(OUT, "ayran_x5.png"), scale=5)

    print("FRITOZ_DONE %s" % mode)


if __name__ == "__main__":
    main()
