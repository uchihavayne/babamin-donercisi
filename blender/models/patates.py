"""PATATES / DOGRAMA / CUVAL / COP - 3B model + piksel-art render.

Oyundaki karsiliklari:
  js/art.js -> drawCutBoard(...)    dograma tahtasi + patates + dilimler
  js/art.js -> potBinPaint(...)     patates cuvali (duvar oyugunda)
  js/art.js -> drawTrash(...)       cop kovasi

Su anki cizimler:
  patates  : iki ust uste elips -> yumru degil, duz bir leke
  dilimler : 2x8 sari dikdortgenler
  cuval    : hasir sepet dokusu, cuval degil
  cop      : koyu bir dikdortgen agiz

3B'nin buradaki kazanci: PATATESIN YUMRU FORMU (duzensiz, gozleri olan
bir kok) ve dograma sirasinda KESIT yuzunun acilmasi. Bunlar elle
tutturulmasi zor, modelden bakarak kodlamak kolay.

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


def yumru(name, rx, ry, rz, mat, seg=30, rings=20, tohum=0.0, puruz=0.16,
          kesik=None):
    """Patates: duzensiz yumru. kesik verilirse (x degeri) o duzlemin
    SAGI atilir - dograma sirasinda kesit yuzu acilir."""
    bm = bmesh.new()
    prev = None
    for i in range(rings + 1):
        v = math.pi * i / rings
        sy, cz = math.sin(v), math.cos(v)
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            # duzensizlik: birkac dusuk frekansli dalga
            d = (1.0
                 + puruz * math.sin(a * 3.0 + tohum) * sy
                 + puruz * .7 * math.sin(v * 4.0 + tohum * 1.7)
                 + puruz * .5 * math.sin(a * 5.0 + v * 3.0 + tohum * 2.3))
            x = math.cos(a) * sy * rx * d
            y = math.sin(a) * sy * ry * d
            z = cz * rz * d
            if kesik is not None and x > kesik:
                x = kesik
            vs.append(bm.verts.new((x, y, z)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


def cubuk(name, boy, kal, mat, buk=0.0, seg=10, rings=10):
    """Dogranmis patates cubugu (durum.py'deki ile ayni form)."""
    bm = bmesh.new()
    prev = None
    first = None
    kesit = []
    for i in range(seg):
        a = 2 * math.pi * i / seg
        c, s = math.cos(a), math.sin(a)
        k = (abs(c) ** 3.2 + abs(s) ** 3.2) ** (-1 / 3.2)
        kesit.append((c * k, s * k))
    for i in range(rings + 1):
        u = i / rings
        x = -boy / 2 + u * boy
        r = kal * (1.0 - 0.08 * math.sin(u * math.pi * 2.0))
        egri = math.sin(u * math.pi) * buk
        vs = [bm.verts.new((x, cy * r, cz * r + egri)) for (cy, cz) in kesit]
        if prev is not None:
            m = len(kesit)
            for j in range(m):
                bm.faces.new((prev[j], prev[(j + 1) % m], vs[(j + 1) % m], vs[j]))
        else:
            first = vs
        prev = vs
    bm.faces.new(list(reversed(first)))
    bm.faces.new(prev)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=False)
    ob.data.materials.append(mat)
    return ob


def bez(name, w, h, f, mat, nx=26, ny=22):
    """Cuval bezi: dalgali yuzey."""
    bm = bmesh.new()
    grid = []
    for j in range(ny + 1):
        v = j / ny
        satir = []
        for i in range(nx + 1):
            u = i / nx
            satir.append(bm.verts.new(((u - .5) * w, f(u, v), (v - .5) * h)))
        grid.append(satir)
    for j in range(ny):
        for i in range(nx):
            bm.faces.new((grid[j][i], grid[j][i + 1],
                          grid[j + 1][i + 1], grid[j + 1][i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


# ------------------------------------------------------------- paletler
KABUK = ["#6d4d24", "#8a6432", "#a87a3e", "#b98b46", "#d8ab63"]
KABUK_ST = [0.0, 0.18, 0.44, 0.72, 0.92]
ETI = ["#c8b87e", "#e8d59a", "#f2e0a8", "#f8ecc0", "#fff6d0"]
AHSAP = ["#8a6a42", "#a8764a", "#c49a68", "#dcb480", "#eccb96"]
CUVAL = ["#6b5636", "#8a7048", "#a88a5c", "#c4a675", "#dcc094"]
KOYU = ["#141a1f", "#232a31", "#39424b", "#5f6672", "#878e99"]
CELIK = ["#5f6672", "#878e99", "#aeb5be", "#d3d8de", "#f2f4f6"]


# ------------------------------------------------------------- sahneler
def sahne_patates(kesim=0.0, tohum=1.0):
    """Tek patates. kesim 0..1 -> saginda o kadari dogranmis, KESIT
    yuzu acikta. Oyunda patates iki ust uste elipsti."""
    px.reset()
    px.setup(30, 22)
    px.ortho_cam(0, 0, 30, 22)
    px.world("#000000", 0.0)

    M_k = px.cel_nx("Kabuk", KABUK, KABUK_ST, axis="Z",
                    noise=0.035, noise_scale=2.4)
    M_e = px.cel_nx("Et", ETI, [0, .22, .50, .78, .94], axis="X")

    RX = 9.0
    kesikX = None if kesim <= 0 else (RX - kesim * RX * 1.85)
    yumru("Patates", RX, 5.5, 5.0, M_k, tohum=tohum, kesik=kesikX)
    if kesikX is not None:
        # kesit yuzu: acik ic et
        kutu("Kesit", kesikX - 0.3, -5.6, -5.2, kesikX + 0.3, 5.6, 5.2, M_e)
    # gozler: kabukta koyu cukurlar
    for g in range(4):
        a = tohum * 2.1 + g * 1.9
        gx = math.cos(a) * RX * .55
        gz = math.sin(a) * 3.4
        if kesikX is not None and gx > kesikX - 1:
            continue
        kutu("Goz%d" % g, gx - 0.6, -6.2, gz - 0.6, gx + 0.6, -4.8, gz + 0.6,
             px.flat("GozM%d" % g, "#5a3f1c"))
    px.shear_scene(0.30)


def sahne_dograma(kare=0):
    """DOGRAMA DIZISI: bicak inip patatesten cubuk ayiriyor. 6 kare."""
    px.reset()
    px.setup(46, 26)
    px.ortho_cam(0, 0, 46, 26)
    px.world("#000000", 0.0)

    M_k = px.cel_nx("Kabuk", KABUK, KABUK_ST, axis="Z", noise=0.035, noise_scale=2.4)
    M_e = px.cel_nx("Et", ETI, [0, .22, .50, .78, .94], axis="X")
    M_a = px.cel_nx("Ahsap", AHSAP, [0, .20, .48, .76, .93], axis="Z",
                    noise=0.03, noise_scale=1.2)
    M_c = px.cel_nx("Celik", CELIK, [0, .20, .48, .76, .93], axis="Z")

    u = kare / 5.0
    # tahta
    kutu("Tahta", -21.0, -3.0, -11.0, 21.0, 3.0, -7.0, M_a)
    # patates: soldan saga dogranir
    kesim = u * 0.72
    RX = 8.0
    kesikX = RX - kesim * RX * 1.9
    yumru("Patates", RX, 5.0, 4.6, M_k, tohum=1.3, kesik=kesikX)
    for o in bpy.context.scene.objects:
        if o.name == "Patates":
            o.location = (-8.0, 0, -2.4)
    if kesim > 0.02:
        kutu("Kesit", -8.0 + kesikX - 0.3, -5.2, -7.0,
             -8.0 + kesikX + 0.3, 5.2, 2.2, M_e)
    # ayrilan cubuklar: saga dizilir
    n = int(u * 5)
    for i in range(n):
        c = cubuk("Cub%d" % i, 9.0, 1.15, M_e, buk=0.4)
        c.location = (2.0 + i * 3.0, -1.0, -5.4 + (i % 2) * 0.9)
        c.rotation_euler = (0, math.radians(90), math.radians((i % 3 - 1) * 9))
    # bicak: iniyor
    bh = 6.0 - u * 9.0
    kutu("Agiz", -8.0 + kesikX - 6.0, -1.2, bh, -8.0 + kesikX + 6.0, -0.4, bh + 1.6, M_c)
    kutu("Sirt", -8.0 + kesikX - 6.0, -1.3, bh + 1.4, -8.0 + kesikX + 6.0, -0.3, bh + 2.2,
         px.flat("SirtM", "#5a636c"))
    kutu("Sap", -8.0 + kesikX + 6.0, -1.6, bh + 0.4, -8.0 + kesikX + 12.0, 0.0, bh + 3.0,
         px.flat("SapM", "#3f2712"))
    px.shear_scene(0.30)


def sahne_cuval(dolu=1.0):
    """PATATES CUVALI: bez cuval, agzi kivrik, icinden patatesler."""
    px.reset()
    px.setup(50, 44)
    px.ortho_cam(0, 0, 50, 44)
    px.world("#000000", 0.0)

    M_c = px.cel_nx("Cuval", CUVAL, [0, .20, .48, .76, .93], axis="X",
                    noise=0.05, noise_scale=3.2)
    M_k = px.cel_nx("Kabuk", KABUK, KABUK_ST, axis="Z", noise=0.035, noise_scale=2.2)

    # --- cuval govdesi: alta dogru genisleyen, dalgali torba ---
    bm = bmesh.new()
    seg, rings = 30, 18
    prev = None
    for i in range(rings + 1):
        v = i / rings
        z = 16.0 - v * 34.0
        r = 9.0 + math.sin(v * math.pi * .82) * 7.0
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            # kumas kirisiklari
            d = 1.0 + 0.06 * math.sin(a * 7.0 + v * 4.0) + 0.04 * math.sin(v * 9.0)
            vs.append(bm.verts.new((math.cos(a) * r * d, math.sin(a) * r * .55 * d, z)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        prev = vs
    bm.faces.new(prev)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj("Cuval", bm)
    ob.data.materials.append(M_c)

    # --- agzi disa kivrik: kalin bir halka ---
    bm2 = bmesh.new()
    prev2 = None
    for i in range(9):
        v = i / 8.0
        ang = v * math.pi
        rr = 9.5 + math.sin(ang) * 2.6
        zz = 16.0 + math.cos(ang) * 3.0
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            d = 1.0 + 0.05 * math.sin(a * 6.0)
            vs.append(bm2.verts.new((math.cos(a) * rr * d, math.sin(a) * rr * .55 * d, zz)))
        if prev2 is not None:
            for k in range(seg):
                bm2.faces.new((prev2[k], prev2[(k + 1) % seg],
                               vs[(k + 1) % seg], vs[k]))
        prev2 = vs
    bmesh.ops.recalc_face_normals(bm2, faces=bm2.faces[:])
    ob2 = new_obj("Agiz", bm2)
    ob2.data.materials.append(M_c)

    # --- icindeki patatesler: agizdan tasar ---
    n = int(3 + dolu * 5)
    for i in range(n):
        a = i * 2.4
        yumru("P%d" % i, 3.6, 2.4, 2.2, M_k, tohum=i * 1.7, puruz=0.20)
        for o in bpy.context.scene.objects:
            if o.name == "P%d" % i:
                o.location = (math.cos(a) * 5.0, math.sin(a) * 2.4 - 1.0,
                              15.0 + (i % 3) * 1.6)
    px.shear_scene(0.26)


def sahne_cop(dolu=0.5, acik=False):
    """COP KOVASI: duvara gomulu, egik kapak, icinde cop."""
    px.reset()
    px.setup(40, 36)
    px.ortho_cam(0, 0, 40, 36)
    px.world("#000000", 0.0)

    M_c = px.cel_nx("Celik", CELIK, [0, .20, .48, .76, .93], axis="X")
    M_k = px.cel_nx("Koyu", KOYU, [0, .28, .56, .82, .95], axis="X")
    M_p = px.cel_nx("Cop", ["#3a3228", "#5a4c3a", "#7a6a52", "#9a8a6c"],
                    [0, .30, .64, .90], axis="Z", noise=0.06, noise_scale=3.0)

    W, H = 32.0, 28.0
    # --- duvar oyugu: koyu ic ---
    kutu("Oyuk", -W / 2, 1.0, -H / 2, W / 2, 5.0, H / 2, M_k)
    # --- celik cerceve: on yuz dort parca, ortada agiz ---
    A0, A1 = -H / 2 + 3.0, H / 2 - 5.0
    kutu("CerSol", -W / 2, -4.0, -H / 2, -W / 2 + 3, 1.0, H / 2, M_c)
    kutu("CerSag", W / 2 - 3, -4.0, -H / 2, W / 2, 1.0, H / 2, M_c)
    kutu("CerUst", -W / 2, -4.0, A1, W / 2, 1.0, H / 2, M_c)
    kutu("CerAlt", -W / 2, -4.0, -H / 2, W / 2, 1.0, A0, M_c)
    # --- egik kapak: itilince acilir ---
    # KAPAK: -14 derece ONDEN duz bir cubuk gibi goruluyordu.
    # Egim buyutuldu, kapak one cekildi - itilebilir bir kapak gibi okusun.
    kap = kutu("Kapak", -W / 2 + 4, -6.4, A1 - 8.0, W / 2 - 4, -5.2, A1 - 0.5, M_c)
    kap.rotation_euler = (math.radians(-72 if acik else -34), 0, 0)
    kap.location.z += 2.6
    kutu("Kol", -4.0, -7.0, A1 - 7.0, 4.0, -6.2, A1 - 5.6, M_k)

    # --- icindeki cop: dolulukla YUKSELIR ve cesitlenir ---
    if dolu > 0.05:
        M_kag = px.cel_nx("Kagit", ["#8a8474", "#b9b3a2", "#e8e4d6", "#f8f4e8"],
                          [0, .30, .64, .90], axis="Z", noise=0.05, noise_scale=3.0)
        M_et = px.cel_nx("Et", ["#52290a", "#7e4412", "#9c5718", "#bd7024"],
                         [0, .30, .64, .90], axis="Z")
        n = int(3 + dolu * 8)
        tepe = A0 + 2.0 + dolu * 10.0
        for i in range(n):
            a = i * 2.37
            cx0 = math.cos(a) * (W / 2 - 7.0)
            cz0 = A0 + 1.0 + (i / max(1.0, n - 1.0)) * (tepe - A0 - 1.0)
            bw = 2.2 + (i % 3) * 1.1
            mm = M_kag if i % 3 else (M_et if i % 5 == 0 else M_p)
            kutu("C%d" % i, cx0 - bw, -3.0, cz0, cx0 + bw, 0.5, cz0 + 2.4 + (i % 2), mm)
    px.shear_scene(0.26)


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (KABUK, ETI, AHSAP, CUVAL, KOYU, CELIK):
        ok += g
    ok += ["#5a3f1c", "#5a636c", "#3f2712",
           "#3a3228", "#5a4c3a", "#7a6a52", "#9a8a6c"]
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "patates"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "p_%s.png" % ad)), "#2b2018", 105)

    if mode == "patates":
        for i, (k, s) in enumerate(((0.0, 1.0), (0.0, 3.4), (0.0, 5.9),
                                    (0.25, 1.0), (0.55, 1.0), (0.80, 1.0))):
            sahne_patates(kesim=k, tohum=s); paths.append(cek("pat%d" % i))
        px.audit(paths[0], allowed(), "patates", show=20)
        px.contact(paths, 3, os.path.join(OUT, "patates_x6.png"), scale=6)
    elif mode == "dograma":
        for i in range(6):
            sahne_dograma(kare=i); paths.append(cek("dog%d" % i))
        px.contact(paths, 3, os.path.join(OUT, "dograma_x5.png"), scale=5)
        px.sheet(paths, 6, os.path.join(OUT, "dograma_sheet.png"))
    elif mode == "cuval":
        for i, d in enumerate((1.0, 0.6, 0.25)):
            sahne_cuval(dolu=d); paths.append(cek("cuv%d" % i))
        px.contact(paths, 3, os.path.join(OUT, "cuval_x5.png"), scale=5)
    else:
        for i, (d, a) in enumerate(((0.1, False), (0.6, False), (1.0, False), (0.6, True))):
            sahne_cop(dolu=d, acik=a); paths.append(cek("cop%d" % i))
        px.contact(paths, 4, os.path.join(OUT, "cop_x5.png"), scale=5)

    print("PATATES_DONE %s" % mode)


if __name__ == "__main__":
    main()
