"""OZEL MUSTERILERIN BINEKLERI - 3B model + piksel-art render.

Oyundaki yeri: vitrinin ardindaki sokak (js/art.js -> bakeStreet).
Cam alani 264x92 @ (154,34); yakin serit taban cizgisi glass.y+82,
uzak serit glass.y+70. Arabalar ~40x20 civari, dolayisiyla:

  ejderha : ~74x50  (uzak seritte, arabadan buyuk olmali ki etki etsin)
  supurge : ~12x34  (kapinin yanina dayali, kucuk ve dikey)
  karavan : ~62x30  (yakin seritte, arabadan bir tik buyuk)

Uc bineği de YANDAN cizmek gerekiyor - sokak trafigi yandan gorunuyor.
Ejderhada onemli olan silueti: uzun boyun, kivrik kuyruk ve KATLI
kanat. Kanat acikken kadraja sigmiyor, o yuzden konmus halde.

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
    ob.scale = (max(.4, abs(x1 - x0)), max(.4, abs(y1 - y0)), max(.4, abs(z1 - z0)))
    ob.location = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    ob.data.materials.append(mat)
    return ob


def silindir(name, eksen, a0, a1, r, mat, seg=18, r1=None):
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
    bm.faces.new(list(reversed(halka[0])))
    bm.faces.new(halka[1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


def kure(ad, mat, seg=16, ring=10):
    bm = bmesh.new()
    try:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, radius=1.0)
    except TypeError:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, diameter=1.0)
    ob = new_obj(ad, bm)
    ob.data.materials.append(mat)
    return ob


def zincir(ad, mat, noktalar, r0, r1):
    """Nokta dizisi boyunca incelerek giden silindir zinciri -
    boyun, kuyruk gibi kivrimli govdeler icin."""
    n = len(noktalar) - 1
    for i in range(n):
        (x0, z0), (x1, z1) = noktalar[i], noktalar[i + 1]
        u0, u1 = i / float(n), (i + 1) / float(n)
        ra = r0 + (r1 - r0) * u0
        rb = r0 + (r1 - r0) * u1
        d = math.hypot(x1 - x0, z1 - z0)
        c = silindir("%s%d" % (ad, i), 'z', 0, d, ra, mat, seg=10, r1=rb)
        c.rotation_euler = (0, math.atan2(x1 - x0, z1 - z0), 0)
        c.location = (x0, 0, z0)
        k = kure("%sK%d" % (ad, i), mat, seg=8, ring=6)
        k.scale = (rb, rb, rb)
        k.location = (x1, 0, z1)


def levha(ad, kose, y0, y1, mat):
    """XZ duzleminde cokgen, Y boyunca kalinlik - kanat zari gibi
    duz ama duzensiz kenarli parcalar icin."""
    bm = bmesh.new()
    a = [bm.verts.new((x, y0, z)) for (x, z) in kose]
    b = [bm.verts.new((x, y1, z)) for (x, z) in kose]
    n = len(kose)
    for i in range(n):
        bm.faces.new((a[i], a[(i + 1) % n], b[(i + 1) % n], b[i]))
    bm.faces.new(list(reversed(a)))
    bm.faces.new(b)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(ad, bm, smooth=False)
    ob.data.materials.append(mat)
    return ob


def mat_isik(ad, ramp, stops=None):
    if stops is None:
        n = len(ramp)
        stops = [0.0] + [0.16 + 0.66 * i / (n - 1) for i in range(1, n)]
    return px.cel(ad, ramp, stops)


def sahne(w, h, cz=0):
    px.reset(); px.setup(w, h)
    px.ortho_cam(0, cz, w, h)
    px.world("#141018", 0.30)
    px.sun(math.pi, rot=(52, 0, -40))


# ------------------------------------------------------------- paletler
PUL = ["#070d09", "#0e1711", "#16241a", "#1f3324", "#2b452f"]      # ejderha: koyu yesil-siyah
KARIN = ["#2a2612", "#42391a", "#5f5228", "#7d6b36"]
KANAT = ["#0b1410", "#131f18", "#1d2e22", "#2a4130"]   # govdeden bir tik acik
BOYNUZ = ["#3a3228", "#5a4e3c", "#7c6c52", "#9e8c6c"]
ATES = ["#8a2c06", "#c04a10", "#e87a18", "#ffb040", "#ffe08a"]
AHSAP = ["#3a2a18", "#54402a", "#6f5638", "#8a6f4a", "#a88a5e"]
SAMAN = ["#6b5420", "#8f7230", "#b89448", "#d8b468"]
KARAVAN = ["#7a7468", "#9a948a", "#bab4a8", "#d6d0c4", "#efe9dc"]
CELIK = ["#33393f", "#4d545c", "#6f7880", "#98a2ab", "#c6ced5"]
CAM = ["#20323e", "#33505f", "#4d7386", "#7aa3b6"]
LASTIK = ["#14161a", "#22262c", "#31363e"]


# ============================================================= 1) EJDERHA
def ejderha(ucus=False):
    """Yirtici duruslu ejderha, yandan.

    Ilk hallerinde boyun dimdik yukari gidiyordu (brontosaurus durusu)
    ve sevimli duruyordu. Yirtici bir hayvan basini ONE uzatir, govde
    hizasina indirir; agzi acik, kanadi yari kalkik, bakisi kas
    cikintisiyla sert olur. Poz buna gore degistirildi.
    """
    sahne(96, 58, 2)
    M_pul = mat_isik("Pul", PUL)
    M_kar = mat_isik("Karin", KARIN)
    M_kan = mat_isik("Kanat", KANAT)
    M_boy = mat_isik("Boynuz", BOYNUZ)

    # --- govde: cokmus, one egik ---
    g = kure("Govde", M_pul); g.scale = (16, 10, 10); g.location = (6, 0, -6)
    gs = kure("Sirt", mat_isik("Sirt", PUL[:3]))
    gs.scale = (14, 6, 7); gs.location = (6, 3, 0)
    kr = kure("Karin", M_kar); kr.scale = (11, 8, 4); kr.location = (5, -5, -11)
    for i in range(5):
        kutu("Plaka%d" % i, -3 + i * 4, -9.4, -14, -0.4 + i * 4, -8.6, -9,
             mat_isik("Plaka", KARIN[1:]))

    # --- boyun: ALCAK ve ONE. Yukari giden boyun sevimli yapiyordu. ---
    zincir("Boyun", M_pul,
           [(-4, 2), (-12, 6), (-20, 8), (-27, 7), (-32, 4)], 6.2, 3.4)
    for i in range(5):                                  # boyun dikenleri
        d = silindir("BDiken%d" % i, 'z', 0, 3.6 - i * .4, 1.1, M_boy, seg=6,
                     r1=0.2)
        d.rotation_euler = (0, math.radians(-25 - i * 6), 0)
        d.location = (-7 - i * 5, 0, 8 - i * .6)

    # --- bas: one uzanmis, AGZI ACIK ---
    b = kure("Bas", M_pul); b.scale = (9, 6, 5.5); b.location = (-35, 0, 3)
    bn = silindir("Burun", 'x', -47, -34, 3.4, M_pul, seg=10, r1=2.2)
    bn.location = (0, 0, 4.4)
    kutu("UstCene", -47, -3.4, 3.6, -35, 3.4, 6.6, M_pul)
    # alt cene DUSUK: agiz acik
    ac = kutu("AltCene", -45, -3.0, -2.0, -34, 3.0, 0.6, M_kar)
    ac.rotation_euler = (0, math.radians(-14), 0)
    kutu("AgizIc", -44, -2.6, 0.6, -35, 2.6, 3.4, px.flat("AgizM", "#2a0a10"))
    for i in range(6):                                  # ust disler
        t = silindir("DisU%d" % i, 'z', 0, -2.6, 0.75, px.flat("DisM", "#e8e2d0"),
                     seg=5, r1=0.15)
        t.location = (-46 + i * 2.1, -3.0, 3.6)
    for i in range(5):                                  # alt disler
        t = silindir("DisA%d" % i, 'z', 0, 2.2, 0.7, px.flat("DisM2", "#d8d2c0"),
                     seg=5, r1=0.15)
        t.location = (-44 + i * 2.1, -2.8, 0.4)
    # kas cikintisi + sert bakis
    kutu("Kas", -41, -4.2, 7.2, -32, 4.2, 9.4, M_pul)
    gz = kure("Goz", px.flat("GozM", "#ff7a1e")); gz.scale = (1.7, 1.6, 1.0)
    gz.location = (-37, -4.6, 5.4)
    gi = kure("GozIc", px.flat("GozIc", "#160604")); gi.scale = (.6, 1.0, 1.1)
    gi.location = (-37.6, -5.4, 5.4)
    kutu("Delik", -47.4, -2.4, 5.4, -45.4, -1.2, 6.2, px.flat("DelikM", "#0b1410"))
    for i, (bx, bz, uz, aci) in enumerate(((-32, 9, 12, 118), (-28, 8, 9, 126),
                                           (-36, 8, 7, 108))):
        h = silindir("Boynuz%d" % i, 'z', 0, uz, 1.7, M_boy, seg=8, r1=0.3)
        h.rotation_euler = (0, math.radians(aci), 0)     # GERIYE dogru
        h.location = (bx, 0, bz)

    # --- KANAT: yari ACIK ve yukari kalkik (tehdit durusu) ---
    kutu("KanatOm", -4, 2, 2, 4, 8, 9, M_pul)
    # Kanat govdeyi ezecek kadar buyumustu; kuculdu ve geriye yatti -
    # yari acik durus korunuyor ama siluet ejderhanin kendisi.
    if ucus:
        # UCUS: kanat tam acik, yukari-geriye gerilmis
        levha("Zar", [(-4, 8), (12, 6), (34, 16), (40, 34), (22, 36), (4, 24)],
              3.0, 6.2, M_kan)
        levha("ZarKenar", [(-4, 8), (12, 6), (34, 16), (40, 34), (36, 35),
                           (32, 18), (11, 8), (-3, 10)], 2.4, 6.4,
              mat_isik("ZarKenar", ["#3a5638", "#4a6b46", "#628458"]))
        kemikler = ((0, 7, 32, 20), (6, 6, 31, 36), (14, 6, 27, 52),
                    (22, 8, 20, 66))
    else:
        levha("Zar", [(-2, 6), (9, 3), (22, 9), (25, 22), (14, 25), (2, 18)],
              3.0, 6.2, M_kan)
        levha("ZarKenar", [(-2, 6), (9, 3), (22, 9), (25, 22), (22, 23),
                           (20, 10), (8, 5), (-1, 8)], 2.4, 6.4,
              mat_isik("ZarKenar", ["#3a5638", "#4a6b46", "#628458"]))
        kemikler = ((1, 5, 20, 28), (5, 4, 19, 44), (10, 4, 16, 60),
                    (15, 6, 12, 74))
    for i, (ax, az, uz, aci) in enumerate(kemikler):
        f = silindir("Kemik%d" % i, 'z', 0, uz, 1.0, M_boy, seg=6, r1=0.35)
        f.rotation_euler = (0, math.radians(aci), 0)
        f.location = (ax, 2.4, az)

    # --- kuyruk: geriye uzanir, ucunda diken ---
    zincir("Kuyruk", M_pul,
           [(20, -8), (30, -9), (38, -6), (43, 1), (43, 9)], 5.5, 1.2)
    for i in range(3):
        d = silindir("KDiken%d" % i, 'z', 0, 4.5, 1.1, M_boy, seg=6, r1=0.2)
        d.rotation_euler = (0, math.radians(20 + i * 40), 0)
        d.location = (43, 0, 8)
    for i in range(5):                                  # sirt dikenleri
        d = silindir("Diken%d" % i, 'z', 0, 4.6 - i * .5, 1.4, M_boy, seg=6,
                     r1=0.2)
        d.location = (0 + i * 6, 0, 4 - i * .3)

    # --- bacaklar: on bacaklar ONE basmis, penceler acik ---
    bacaklar = (((-11, -7, 7, 3.4), (-9, 7, 7, 3.4), (12, -7, 8, 4.4),
                 (14, 7, 8, 4.4)) if ucus else
                ((-14, -7, 13, 3.6), (-12, 7, 13, 3.6), (16, -7, 15, 4.8),
                 (18, 7, 15, 4.8)))
    for i, (lx, ly, uz, kal) in enumerate(bacaklar):
        u = silindir("But%d" % i, 'z', -uz, -2, kal, M_pul, seg=8, r1=kal * .7)
        u.location = (lx, ly, 0)
        pn = kure("Pence%d" % i, M_pul)
        pn.scale = (5.5, 3.4, 2.2); pn.location = (lx - 2, ly, -uz - 1)
        for j in range(3):
            t = silindir("Tirnak%d_%d" % (i, j), 'x', 0, 5.5, 0.9, M_boy,
                         seg=6, r1=0.2)
            t.location = (lx - 7.5, ly - 2.2 + j * 2.2, -uz - 1.6)
    px.shear_scene(0.22)


# ============================================================= 2) SUPURGE
def supurge():
    """Duvara dayali ucan supurge: ahsap sap + baglanan saman demeti."""
    sahne(20, 40, 2)
    M_ahs = mat_isik("Ahsap", AHSAP)
    M_sam = mat_isik("Saman", SAMAN)
    M_ip = mat_isik("Ip", ["#4a3418", "#6b4c22", "#8a662e"])

    sp = silindir("Sap", 'z', -12, 18, 1.5, M_ahs, seg=10, r1=1.1)
    sp.rotation_euler = (0, math.radians(11), 0)
    kure("SapUc", M_ahs).scale = (1.8, 1.8, 1.6)
    bpy.data.objects["SapUc"].location = (3.6, 0, 18)
    # saman demeti: asagida, dagilan uclar
    for i in range(16):
        a = i * 2.399
        yay = 1 + (i % 4) * 0.9
        c = silindir("Sam%d" % i, 'z', 0, -12 - (i % 5), 0.6, M_sam, seg=5)
        c.rotation_euler = (math.radians((i % 3 - 1) * 8),
                            math.radians(math.cos(a) * 16), 0)
        c.location = (-2.4 + math.cos(a) * yay, math.sin(a) * 2.2, -8)
    for i in range(3):                      # baglama ipleri
        silindir("Ip%d" % i, 'y', -3, 3, 2.6 - i * 0.3, M_ip, seg=10).location = (
            -2.2, 0, -6 + i * 3)
    px.shear_scene(0.15)


# ============================================================= 3) KARAVAN
def karavan():
    """Kutu govdeli motokaravan, yandan. Sokaktaki arabalarla ayni
    olcekte ama bir tik uzun ve yuksek - park edince fark edilsin."""
    sahne(66, 34, 2)
    M_kar = mat_isik("Karavan", KARAVAN)
    M_cel = mat_isik("Celik", CELIK)
    M_cam = mat_isik("Cam", CAM)
    M_las = mat_isik("Lastik", LASTIK)

    # govde
    kutu("Govde", -30, -8, -6, 24, 8, 10, M_kar)
    kutu("Bant", -30, -8.6, -1, 24, -8, 2, mat_isik("Bant", ["#6b5a2a",
                                                             "#9a8340", "#c9ac58"]))
    kutu("Tavan", -30, -8, 9, 24, 8, 11, mat_isik("Kar2", KARAVAN[1:]))
    # on kabin: alcak ve one egik
    kutu("Kabin", 24, -7, -6, 32, 7, 4, M_kar)
    kutu("OnCam", 30, -7.4, -1, 32.6, 7.4, 3.4, M_cam)
    kutu("Tampon", 31, -7.6, -7, 33, 7.6, -4, M_cel)
    # yan camlar + kapi
    for i in range(3):
        kutu("Cam%d" % i, -26 + i * 12, -8.6, 2, -18 + i * 12, -8, 8, M_cam)
    kutu("Kapi", 6, -8.6, -5, 15, -8, 7, mat_isik("Kapi", KARAVAN[:3]))
    kutu("Kol", 13, -9, 0, 15, -8.4, 1.6, M_cel)
    kutu("Basamak", 6, -10, -8, 15, -8, -6.6, M_cel)
    # tekerlekler
    for wx in (-20, 16):
        w = silindir("Tek%d" % (wx + 30), 'y', -8.4, 8.4, 5.2, M_las, seg=14)
        w.location = (wx, 0, -8)
        j = silindir("Jant%d" % (wx + 30), 'y', -8.8, -8.2, 2.6, M_cel, seg=12)
        j.location = (wx, 0, -8)
    # catida klima + anten
    kutu("Klima", -14, -5, 11, -4, 5, 14, M_cel)
    silindir("Anten", 'z', 11, 20, 0.6, M_cel, seg=6).location = (10, 0, 0)
    kutu("AntenC", 6, -1, 19, 14, 1, 20, M_cel)
    px.shear_scene(0.30)


BINEKLER = (("ejderha", ejderha),
            ("ejderha_ucus", lambda: ejderha(ucus=True)),
            ("supurge", supurge), ("karavan", karavan))


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (PUL, KANAT, BOYNUZ, ATES, AHSAP, SAMAN, KARAVAN, CELIK, CAM,
              LASTIK):
        ok += g
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "hepsi"
    os.makedirs(OUT, exist_ok=True)
    yollar = []
    for ad, fn in BINEKLER:
        if mode not in ("hepsi", ad):
            continue
        fn()
        yollar.append(px.outline(px.render(os.path.join(OUT, "b_%s.png" % ad)),
                                 "#2b2018", 110))
    if yollar:
        px.contact(yollar, 3, os.path.join(OUT, "binek_x5.png"), scale=5)
    print("BINEK_DONE %s" % mode)


if __name__ == "__main__":
    main()
