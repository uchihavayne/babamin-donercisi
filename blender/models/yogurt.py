"""YOGURT + LAVAS - 3B model + piksel-art render.

Oyundaki karsiliklari:
  js/art.js  -> drawYogurtTray()   yogurt kuveti (tepsi)
  js/food.js -> drawWrapOpen()     lavasin ustune gezdirilen yogurt
  js/food.js -> drawWrapRolled()   sarilmis durum (lavas)
  js/art.js  -> drawBread()        lavas yigini (ekmek istasyonu)

Yogurt sivi bir yuzey: oyunda duz beyaz elipslerle ciziliyor, kase
gibi degil bir kagit gibi duruyor. 3B'de asil kazanc MENISKUS: sivinin
kenarda kuvete tirmanmasi, yuzeyin hafif cukur olmasi ve kepceyle
alinan yerdeki cukurluk. Bunlar elle piksel piksel tutturulmasi zor,
modelden bakarak kodlamak kolay.

Lavas: yassi, kenarlari dalgali, yuzeyi kabarcikli. Su anki cizim duz
bir elips + rastgele noktalar.

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
SHEAR = 0.55


def gz(y):
    return -float(y)


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


def yuzey(name, w, h, f, mat=None, nx=40, ny=26, elips=True):
    """Yukseklik fonksiyonu f(u,v) ile bir yuzey. elips=True ise
    dikdortgen disindaki yuzler kurulmaz (siluet elips olur)."""
    bm = bmesh.new()
    grid = []
    for j in range(ny + 1):
        v = j / ny
        satir = []
        for i in range(nx + 1):
            u = i / nx
            x = (u - .5) * w
            y = (v - .5) * h
            satir.append(bm.verts.new((x, y, f(u, v))))
        grid.append(satir)

    def icinde(i, j):
        if not elips:
            return True
        x = (i / nx - .5) * w
        y = (j / ny - .5) * h
        return ((x / (w / 2)) ** 2 + (y / (h / 2)) ** 2) <= 1.02

    for j in range(ny):
        for i in range(nx):
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


def kuvet(name, w, h, derin, mat, kalin=1.4):
    """Paslanmaz kuvet: dis duvarlar + ic taban."""
    bm = bmesh.new()
    dis = [(-w / 2, -h / 2), (w / 2, -h / 2), (w / 2, h / 2), (-w / 2, h / 2)]
    ic = [(x * (1 - 2 * kalin / w), y * (1 - 2 * kalin / h)) for (x, y) in dis]
    ust_d = [bm.verts.new((x, y, 0.0)) for (x, y) in dis]
    ust_i = [bm.verts.new((x, y, 0.0)) for (x, y) in ic]
    alt_i = [bm.verts.new((x, y, -derin)) for (x, y) in ic]
    for k in range(4):
        n = (k + 1) % 4
        bm.faces.new((ust_d[k], ust_d[n], ust_i[n], ust_i[k]))   # dudak
        bm.faces.new((ust_i[k], ust_i[n], alt_i[n], alt_i[k]))   # ic duvar
    bm.faces.new(list(reversed(alt_i)))                          # taban
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=False)
    ob.data.materials.append(mat)
    return ob


def kepce(name, r, mat):
    """Kepce kasesi: yarim kure + sap."""
    bm = bmesh.new()
    seg, rings = 22, 10
    prev = None
    for i in range(rings + 1):
        v = (math.pi / 2) * i / rings
        sy, cy2 = math.sin(v), math.cos(v)
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            vs.append(bm.verts.new((math.cos(a) * sy * r,
                                    math.sin(a) * sy * r, -cy2 * r)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


# ------------------------------------------------------------- paletler
YOG = ["#b3a684", "#d6cbae", "#efe7d0", "#fffdf2", "#ffffff"]
YOG_STOP = [0.0, 0.62, 0.80, 0.91, 0.975]
CELIK = ["#5f6672", "#878e99", "#aeb5be", "#d3d8de", "#f2f4f6"]
LAVAS = ["#8a5f31", "#a8794a", "#c9a06a", "#f0d5a8", "#f8e6c4"]


# ------------------------------------------------------------- sahneler
def sahne_yogurt(dolu=0.75, kepceli=False):
    """Kuvette yogurt. Asil mesele MENISKUS: sivi kenarda duvara
    tirmanir, ortasi hafif cukurdur. Oyunda duz beyaz bir elips."""
    px.reset()
    px.setup(44, 30)
    px.ortho_cam(0, 0, 44, 30)
    px.world("#000000", 0.0)

    M_y = px.cel_nx("Yogurt", YOG, YOG_STOP, axis="Z",
                    noise=0.012, noise_scale=1.2)
    # axis="Z": kuvetin ust dudagi, ic duvari ve tabani ayri banda duser.
    # axis="X" iken on duvarin normali sabit olup her yer tek renk cikiyordu.
    M_c = px.cel_nx("Celik", CELIK, [0.0, 0.22, 0.50, 0.78, 0.94], axis="Z")

    W, H = 30.0, 16.0
    kuvet("Kuvet", W, H, 7.0, M_c)

    yuzey_z = -7.0 + dolu * 6.4

    def f(u, v):
        # kenardan uzaklik 0..1
        dx = abs(u - .5) * 2
        dy = abs(v - .5) * 2
        d = max(dx, dy)
        # meniskus: kenarda yukari tirmanir
        # Meniskus ve cukurluk BELIRGIN olmali: sig birakinca yuzeyin
        # normali her yerde +Z kalip butun sivi tek renk cikiyor.
        men = math.exp(-((1 - d) * 4.0) ** 2) * 2.6
        cuk = -(1 - d * d) * 1.5
        # kepce izi: sag tarafta cukurluk
        kz = 0.0
        if kepceli:
            r = math.hypot((u - .72) * W, (v - .5) * H)
            kz = -max(0.0, 1 - (r / 5.0) ** 2) * 2.6
        return yuzey_z + men + cuk + kz

    yuzey("Yogurt", W - 2.6, H - 2.6, f, mat=M_y, nx=44, ny=30, elips=False)

    if kepceli:
        k = kepce("Kepce", 3.4, M_c)
        k.location = (W * 0.22, 0, yuzey_z + 3.2)

    px.shear_scene(SHEAR)


def sahne_lavas(kabarcik=1.0, kizarma=0.0):
    """LAVAS: yassi, kenari dalgali, yuzeyi kabarcikli. Oyunda duz bir
    elips + rastgele noktalar; kabarciklarin GOLGESI yok, o yuzden
    yuzey duz kagit gibi duruyor."""
    px.reset()
    px.setup(54, 30)
    px.ortho_cam(0, 0, 54, 30)
    px.world("#000000", 0.0)

    ramp = list(LAVAS)
    if kizarma > 0:
        # kizardikca koyulasir (food.js mixHex ile ayni yon)
        def mix(a, b, k):
            pa = [int(a[1:][i:i + 2], 16) for i in (0, 2, 4)]
            pb = [int(b[1:][i:i + 2], 16) for i in (0, 2, 4)]
            return "#%02x%02x%02x" % tuple(
                int(round(pa[i] + (pb[i] - pa[i]) * k)) for i in range(3))
        hedef = ["#5e3f18", "#7a5228", "#a87a41", "#d9a765", "#f0c68e"]
        ramp = [mix(ramp[i], hedef[i], kizarma) for i in range(5)]

    M_l = px.cel_nx("Lavas", ramp, [0.0, 0.18, 0.46, 0.76, 0.93], axis="Z",
                    noise=0.030, noise_scale=1.8)

    W, H = 46.0, 19.0

    def f(u, v):
        # ana kubbe
        k = 1 - ((u - .5) * 2) ** 2 - ((v - .5) * 2) ** 2
        z = math.sqrt(max(0.0, k)) * 3.2
        # kabarciklar: duzensiz kucuk tumsekler
        for (bu, bv, br, bh) in ((.24, .42, .10, 1.5), (.42, .60, .07, 1.1),
                                 (.61, .38, .09, 1.3), (.76, .55, .06, 0.9),
                                 (.33, .66, .05, 0.8), (.55, .30, .06, 1.0)):
            d = math.hypot((u - bu) * 2.3, (v - bv))
            if d < br:
                z += math.cos(d / br * math.pi / 2) * bh * kabarcik
        # kenar dalgasi
        z += math.sin(u * 17.0) * math.cos(v * 9.0) * 0.16
        return z

    yuzey("Lavas", W, H, f, mat=M_l, nx=54, ny=26, elips=True)
    px.shear_scene(SHEAR)


def sahne_lavas_yigin(n=5):
    """Ekmek istasyonundaki LAVAS YIGINI: ust uste duran yassi ekmekler."""
    px.reset()
    px.setup(50, 34)
    px.ortho_cam(0, 0, 50, 34)
    px.world("#000000", 0.0)
    M_l = px.cel_nx("Lavas", LAVAS, [0.0, 0.18, 0.46, 0.76, 0.93], axis="Z",
                    noise=0.028, noise_scale=1.8)
    for i in range(n):
        def f(u, v, i=i):
            k = 1 - ((u - .5) * 2) ** 2 - ((v - .5) * 2) ** 2
            z = math.sqrt(max(0.0, k)) * 1.1
            z += math.sin(u * 13.0 + i * 2.1) * math.cos(v * 7.0) * 0.22
            return z
        ob = yuzey("L%d" % i, 38.0 - i * 0.8, 15.0 - i * 0.4, f, mat=M_l,
                   nx=40, ny=20, elips=True)
        ob.location = (math.sin(i * 2.3) * 1.4, 0, -10.0 + i * 2.4)
    px.shear_scene(SHEAR)


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (YOG, CELIK, LAVAS):
        ok += g
    ok += ["#5e3f18", "#7a5228", "#a87a41", "#d9a765", "#f0c68e"]
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "yogurt"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "y_%s.png" % ad)), "#2b2018", 105)

    if mode == "yogurt":
        for i, (d, kp) in enumerate(((0.95, False), (0.70, False), (0.42, False),
                                     (0.18, False), (0.75, True), (0.45, True))):
            sahne_yogurt(dolu=d, kepceli=kp)
            paths.append(cek("yog%d" % i))
        px.audit(paths[1], allowed(), "yogurt", show=18)
        px.contact(paths, 3, os.path.join(OUT, "yogurt_x5.png"), scale=5)

    elif mode == "lavas":
        for i, (kb, kz) in enumerate(((1.0, 0.0), (0.6, 0.0), (1.0, 0.45),
                                      (1.0, 0.9))):
            sahne_lavas(kabarcik=kb, kizarma=kz)
            paths.append(cek("lav%d" % i))
        sahne_lavas_yigin(5)
        paths.append(cek("lavyigin"))
        px.audit(paths[0], allowed(), "lavas", show=18)
        px.contact(paths, 3, os.path.join(OUT, "lavas_x5.png"), scale=5)

    print("YOGURT_DONE %s" % mode)


if __name__ == "__main__":
    main()
