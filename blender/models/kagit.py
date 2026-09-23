"""KAGIT RULOSU + KAGIT MAKINESI - 3B model + piksel-art render.

Oyundaki karsiligi: js/art.js -> drawPaperStation(x, y, w, h, level, ...)
  level 0  ahsap askida rulo kagit          (yukseltme yok)
  level 1  Kagit makinesi                   (data.js UPG 'paper')
  level 2  Otomatik sarma                   (ayni kabin, oto calisir)
ayrica js/food.js -> drawWrapRolled() icindeki kagit mansonu.

Su anki cizim: rulo duz bir kare + iki renk serit; makine dik bir gri
kutu. Ruloda SARIM yok - kagidin ust uste sarilmis olmasi ancak uc
kapaktaki ic ice halkalardan ve govdedeki hafif kademelerden okunur.

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


def silindir(name, x0, x1, r, mat, seg=34, kapak=True, smooth=True):
    """X ekseninde silindir - rulonun govdesi."""
    bm = bmesh.new()
    halka = []
    for x in (x0, x1):
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            vs.append(bm.verts.new((x, math.cos(a) * r, math.sin(a) * r)))
        halka.append(vs)
    for k in range(seg):
        bm.faces.new((halka[0][k], halka[0][(k + 1) % seg],
                      halka[1][(k + 1) % seg], halka[1][k]))
    if kapak:
        bm.faces.new(list(reversed(halka[0])))
        bm.faces.new(halka[1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=smooth)
    ob.data.materials.append(mat)
    return ob


def halka_yuzu(name, x, ric, rdis, mat, seg=34):
    """Rulonun UC KAPAGI: ic ice halka - sarimi bu anlatir."""
    bm = bmesh.new()
    ic, dis = [], []
    for j in range(seg):
        a = 2 * math.pi * j / seg
        ic.append(bm.verts.new((x, math.cos(a) * ric, math.sin(a) * ric)))
        dis.append(bm.verts.new((x, math.cos(a) * rdis, math.sin(a) * rdis)))
    for k in range(seg):
        bm.faces.new((ic[k], dis[k], dis[(k + 1) % seg], ic[(k + 1) % seg]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=False)
    ob.data.materials.append(mat)
    return ob


def kutu(name, x0, y0, z0, x1, y1, z1, mat):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    ob = new_obj(name, bm, smooth=False)
    ob.scale = ((x1 - x0), (y1 - y0), (z1 - z0))
    ob.location = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    ob.data.materials.append(mat)
    return ob


def sayfa(name, w, h, f, mat, nx=24, ny=22):
    """Sarkan kagit: dalgali, alt kenari YIRTIK."""
    bm = bmesh.new()
    grid = []
    for j in range(ny + 1):
        v = j / ny
        satir = []
        for i in range(nx + 1):
            u = i / nx
            satir.append(bm.verts.new(((u - .5) * w, f(u, v), -v * h)))
        grid.append(satir)
    for j in range(ny):
        for i in range(nx):
            # alt kenarda duzensiz yirtik: son satirda bazi yuzler atlanir
            if j == ny - 1 and (i * 7 + 3) % 5 < 2:
                continue
            bm.faces.new((grid[j][i], grid[j][i + 1],
                          grid[j + 1][i + 1], grid[j + 1][i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    md = ob.modifiers.new("K", "SOLIDIFY")
    md.thickness = 0.5
    return ob


# ------------------------------------------------------------- paletler
KAGIT = ["#b9b3a2", "#cfc9b8", "#e8e4d6", "#f8f4e8", "#ffffff"]
KAGIT_STOP = [0.0, 0.20, 0.50, 0.78, 0.94]
AHSAP = ["#4e2e17", "#6b4122", "#8a5730", "#a8703f", "#c99565"]
CELIK = ["#39424b", "#5f6672", "#878e99", "#aeb5be", "#d3d8de"]
KIRMIZI = ["#8e1f18", "#b8302a", "#d8352c", "#f0705f"]
MAVI = ["#1e3c4e", "#2c5369", "#2f5f9e", "#6ba7c4"]


def rulo_kur(r, boy, M_k, M_kir, M_mav, sarim=True):
    """Rulo govdesi + iki uc kapagi + baskili seritler."""
    silindir("Rulo", -boy / 2, boy / 2, r, M_k)
    if sarim:
        # ic ice halkalar: kagidin sarili oldugunu bu anlatir
        for i, rr in enumerate((r * .82, r * .60, r * .38)):
            halka_yuzu("H%d" % i, -boy / 2 - 0.35, rr - 0.45, rr, M_k)
        halka_yuzu("Gobek", -boy / 2 - 0.35, 0.0, r * .22, M_kir)
    # Baskili seritler rulo BOYUNCA uzanir. Halka olarak yapinca yatay
    # silindirde ekrana DIKEY bant olarak dusuyordu.
    def kusak(ad, aci, mat):
        bm = bmesh.new()
        prev = None
        yay = 0.30                      # kusagin cevresel genisligi (rad)
        for x in (-boy * .46, boy * .46):
            vs = []
            for j in range(7):
                a = aci - yay / 2 + yay * j / 6
                vs.append(bm.verts.new((x, math.cos(a) * (r + .12),
                                        math.sin(a) * (r + .12))))
            if prev is not None:
                for k in range(6):
                    bm.faces.new((prev[k], prev[k + 1], vs[k + 1], vs[k]))
            prev = vs
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        o = new_obj(ad, bm, smooth=False)
        o.data.materials.append(mat)
        return o
    kusak("Kir", math.radians(152), M_kir)
    kusak("Mav", math.radians(205), M_mav)


def sahne_rulo(dolu=1.0, sarkan=1.0):
    """Ahsap askida rulo kagit (level 0). dolu: rulo capi."""
    px.reset()
    px.setup(34, 46)
    px.ortho_cam(0, 0, 34, 46)
    px.world("#000000", 0.0)

    M_k = px.cel_nx("Kagit", KAGIT, KAGIT_STOP, axis="Z", noise=0.012, noise_scale=1.4)
    M_a = px.cel_nx("Ahsap", AHSAP, [0, .20, .48, .76, .93], axis="X",
                    noise=0.03, noise_scale=1.1)
    M_kir = px.cel_nx("Kir", KIRMIZI, [0, .30, .64, .90], axis="Z")
    M_mav = px.cel_nx("Mav", MAVI, [0, .30, .64, .90], axis="Z")

    # --- ahsap aski: iki dikey kol + alt kusak ---
    kutu("KolSol", -13.0, -2.0, -18.0, -9.5, 2.0, 12.0, M_a)
    kutu("KolSag", 9.5, -2.0, -18.0, 13.0, 2.0, 12.0, M_a)
    kutu("Kusak", -13.0, -2.2, -20.0, 13.0, 2.2, -16.5, M_a)

    # --- rulo ---
    r = 4.5 + dolu * 4.5
    rulo_kur(r, 19.0, M_k, M_kir, M_mav)
    # mil
    silindir("Mil", -11.5, 11.5, 0.7, px.flat("MilM", "#5f6672"))
    # Uc kapagindaki ic ice halkalar gorunsun diye rulo hafif cevrilir:
    # tam yandan bakinca sarim hic okunmuyor.
    for ob in bpy.context.scene.objects:
        if ob.name.startswith(("Rulo", "H0", "H1", "H2", "Gobek", "Kir", "Mav", "Mil")):
            ob.rotation_euler = (0, 0, math.radians(-34))

    # --- sarkan uc ---
    if sarkan > 0:
        def f(u, v):
            return math.sin(u * 5.0 + v * 2.0) * 0.55 - 1.2
        sy = sayfa("Sarkan", 13.0, 10.0 * sarkan, f, M_k)
        sy.location = (0, -r - 0.4, -r + 1.0)
    px.shear_scene(0.30)


def sahne_makine(cikan=0.0, oto=False):
    """Kagit makinesi (level 1) / otomatik sarma (level 2)."""
    px.reset()
    px.setup(34, 46)
    px.ortho_cam(0, 0, 34, 46)
    px.world("#000000", 0.0)

    M_c = px.cel_nx("Celik", CELIK, [0, .20, .48, .76, .93], axis="X")
    M_ck = px.cel_nx("CelikK", ["#232a31", "#39424b", "#5f6672"], [0, .40, .82], axis="X")
    M_k = px.cel_nx("Kagit", KAGIT, KAGIT_STOP, axis="Z")
    M_kir = px.cel_nx("Kir", KIRMIZI, [0, .30, .64, .90], axis="Z")
    M_mav = px.cel_nx("Mav", MAVI, [0, .30, .64, .90], axis="Z")

    # --- kabin ---
    kutu("Kabin", -11.0, -5.0, -20.0, 11.0, 5.0, 14.0, M_c)
    kutu("UstKapak", -12.0, -5.6, 14.0, 12.0, 5.6, 18.0, M_ck)
    # cam pencere: govdenin onunde koyu bir cukur
    kutu("Cerceve", -9.0, -6.4, -1.0, 9.0, -5.4, 11.0, M_ck)
    # pencerenin ardindaki rulo
    rulo_kur(5.6, 15.0, M_k, M_kir, M_mav)
    for ob in bpy.context.scene.objects:
        if ob.name.startswith(("Rulo", "H0", "H1", "H2", "Gobek", "Kir", "Mav")):
            # Z etrafinda 90: eksen Y'ye doner, kapak kameraya bakar.
            # (0,90,0) ekseni yukari cevirip ruloyu dikey sutun yapiyordu.
            ob.rotation_euler = (0, 0, math.radians(90))
            ob.location = (0, 1.0, 5.0)

    # alt govde: duz gri bir lekeydi, on panel + kenar cizgisi eklendi
    kutu("OnPanel", -9.5, -5.6, -19.0, 9.5, -5.0, -10.0, M_ck)
    kutu("PanelIc", -8.5, -5.5, -18.0, 8.5, -5.1, -11.0, M_c)

    # --- testere agizli kesme cubugu ---
    kutu("Kesici", -10.0, -6.2, -8.0, 10.0, -5.0, -6.0, M_ck)
    for i in range(10):
        kutu("Dis%d" % i, -9.0 + i * 2.0, -6.2, -9.2, -8.0 + i * 2.0, -5.2, -8.0,
             px.flat("DisM%d" % i, "#c2cad1"))

    # --- calisma lambasi ---
    kutu("Lamba", 7.0, -6.0, 15.0, 9.0, -5.2, 17.0,
         px.flat("LambaM", "#7dff7a" if (cikan > 0 or oto) else "#7a4040"))
    if oto:
        # otomatik sarma: ustte ikinci motor kutusu
        kutu("Motor", -8.0, -5.4, 18.0, 2.0, 5.4, 23.0, M_ck)
        kutu("Kasnak", 3.0, -5.6, 18.5, 8.0, 5.6, 22.5, M_c)

    # --- cikan kagit ---
    if cikan > 0:
        def f(u, v):
            return math.sin(u * 6.0) * 0.4 - 6.6
        sy = sayfa("Cikan", 17.0, 4.0 + cikan * 12.0, f, M_k)
        sy.location = (0, 0, -9.0)
    px.shear_scene(0.30)


def sahne_manson():
    """Sarilmis durumun kagit mansonu (food.js drawWrapRolled)."""
    px.reset()
    px.setup(52, 24)
    px.ortho_cam(0, 0, 52, 24)
    px.world("#000000", 0.0)
    M_k = px.cel_nx("Kagit", KAGIT, KAGIT_STOP, axis="Z", noise=0.014, noise_scale=1.2)
    M_d = px.cel_nx("Durum", ["#a8794a", "#c9a06a", "#f0d5a8", "#f8e6c4"],
                    [0, .22, .62, .90], axis="Z")
    M_kir = px.cel_nx("Kir", KIRMIZI, [0, .30, .64, .90], axis="Z")
    silindir("Durum", -20.0, 20.0, 6.4, M_d)
    # manson: govdeyi saran kabuk, ustte katlanma cizgisi
    silindir("Manson", -21.0, -2.0, 6.9, M_k, kapak=False, smooth=False)
    silindir("Serit", -14.0, -12.6, 7.1, M_kir, kapak=False)
    px.shear_scene(0.20)


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (KAGIT, AHSAP, CELIK, KIRMIZI, MAVI):
        ok += g
    ok += ["#232a31", "#c2cad1", "#7dff7a", "#7a4040", "#5f6672"]
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "rulo"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "k_%s.png" % ad)), "#2b2018", 105)

    if mode == "rulo":
        for i, (d, sk) in enumerate(((1.0, 1.0), (0.62, 0.7), (0.28, 0.4), (1.0, 0.0))):
            sahne_rulo(dolu=d, sarkan=sk); paths.append(cek("rulo%d" % i))
        px.audit(paths[0], allowed(), "rulo", show=20)
        px.contact(paths, 4, os.path.join(OUT, "kagit_rulo_x5.png"), scale=5)

    elif mode == "makine":
        for i, (c, o) in enumerate(((0.0, False), (0.45, False), (1.0, False),
                                    (0.0, True), (0.7, True))):
            sahne_makine(cikan=c, oto=o); paths.append(cek("mak%d" % i))
        px.audit(paths[2], allowed(), "makine", show=20)
        px.contact(paths, 5, os.path.join(OUT, "kagit_makine_x5.png"), scale=5)

    elif mode == "manson":
        sahne_manson(); paths.append(cek("manson"))
        px.contact(paths, 1, os.path.join(OUT, "kagit_manson_x6.png"), scale=6)

    print("KAGIT_DONE %s" % mode)


if __name__ == "__main__":
    main()
