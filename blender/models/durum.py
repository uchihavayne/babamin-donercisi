"""DURUM ICI + PATATES - 3B model + piksel-art render.

Oyundaki karsiliklari:
  js/art.js  -> fryStick()        patates cubugu (tepsi + durum ici)
  js/food.js -> drawWrapOpen()    acik lavas ve icindeki malzeme
  js/food.js -> drawFriesCup()    servis edilen patates kupu

Sorun: patates cubugu tek piksel kalinliginda iki satirdan ibaret
(`px(x0+q, y+1, koyu); px(x0+q, y, govde)`), yani hacmi yok. Durumun
icindeki et de 5x2'lik duz bir dikdortgen. Ikisi de oyunun en cok
bakilan yerlerinde duruyor.

Boru hattinin uc kurali (blender/README.md): 1 birim = 1 piksel,
anti-alias yok, renk yonetimi kapali. Golgeleme cel_nx ile.
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


def cubuk(name, boy, kalin, mat=None, buk=0.0, seg=4, rings=14):
    """Patates cubugu: kare kesitli prizma, koseleri hafif kirik,
    boyunca hafif bukumlu. Uclari duz kesik (kizarmis kesit orada)."""
    bm = bmesh.new()
    prev = None
    first = None
    kesit = []
    n = 10
    for i in range(n):
        a = 2 * math.pi * i / n
        # kare kesite yakin ama kosesi yumusak
        c, s = math.cos(a), math.sin(a)
        k = (abs(c) ** 3.2 + abs(s) ** 3.2) ** (-1 / 3.2)
        kesit.append((c * k, s * k))
    for i in range(rings + 1):
        u = i / rings
        x = -boy / 2 + u * boy
        r = kalin * (1.0 - 0.10 * math.sin(u * math.pi * 2.0))
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
    if mat:
        ob.data.materials.append(mat)
    return ob


def elipsoit(name, rx, ry, rz, mat=None, seg=34, rings=20, duz=0.0):
    """Lavas govdesi / et parcasi: yassilastirilmis kure."""
    bm = bmesh.new()
    prev = None
    for i in range(rings + 1):
        v = math.pi * i / rings
        sy, cy2 = math.sin(v), math.cos(v)
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            d = 1.0 + duz * math.sin(a * 4.0) * sy
            vs.append(bm.verts.new((math.cos(a) * sy * rx * d,
                                    math.sin(a) * sy * ry * d,
                                    cy2 * rz)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    if mat:
        ob.data.materials.append(mat)
    return ob


def kup(name, x, y, sx, sy, sz_, col, depth=-6.0, mat=None):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    ob = new_obj(name, bm, smooth=False)
    ob.scale = (float(sx), float(sz_), float(sy))
    ob.location = (float(x), float(depth), gz(y))
    ob.data.materials.append(mat or px.flat(name + "M", col))
    return ob


# ------------------------------------------------------------- materyaller
def mat_patates(kizarma=0.5):
    """js/art.js PT tablosu. kizarma 0 = solgun, 1 = koyu kizarmis."""
    if kizarma < 0.33:
        return ["#8a6218", "#a8791c", "#dcae42", "#f0d271", "#fff0b8"]
    if kizarma < 0.7:
        return ["#7a5410", "#a87a1c", "#d9ab3e", "#e8bf52", "#fff0b8"]
    return ["#5e3f0c", "#8a5c12", "#b8801f", "#d9a03a", "#f5d78e"]


def mat_et():
    return ["#52290a", "#7e4412", "#9c5718", "#bd7024", "#d98f38", "#eeb463", "#ffd291"]


# ------------------------------------------------------------------ sahneler
def sahne_patates(kare=0):
    """Tek patates cubugu, farkli aci / boy / kizarma.
    Oyunda bu iki satir pikseldi: `px(...,koyu); px(...,govde)`."""
    px.reset()
    px.setup(20, 16)
    px.ortho_cam(0, 0, 20, 16)
    px.world("#000000", 0.0)

    AYAR = [
        # (boy, kalinlik, bukum, kizarma, egim)
        (12.0, 1.35, 0.5, 0.20, -6),
        (10.0, 1.55, 0.9, 0.50, 14),
        (13.0, 1.25, 0.3, 0.85, -22),
        (8.5, 1.70, 1.2, 0.35, 32),
        (11.0, 1.45, 0.7, 0.65, -38),
        (9.5, 1.30, 0.4, 0.95, 6),
    ]
    boy, kal, buk, kiz, egim = AYAR[kare % len(AYAR)]
    # YATAY cubuk: ton dikey normalden (isik ustten). axis="X" olsaydi
    # govde boyunca normal.x ~0 kalip cubuk tek renk cikardi.
    M = px.cel_nx("Patates", mat_patates(kiz), [0.0, 0.18, 0.44, 0.72, 0.92],
                  axis="Z", noise=0.02, noise_scale=2.2)
    M_uc = px.cel_nx("Uc", ["#5e3f0c", "#8a5c12", "#b8801f"], [0.0, 0.40, 0.82], axis="Z")
    ob = cubuk("Cubuk", boy, kal, mat=M, buk=buk)
    ob.rotation_euler = (0, math.radians(egim), 0)
    # uc kesitleri: kizarmis, govdeden koyu
    for s in (-1, 1):
        r = math.radians(egim)
        ux = math.cos(r) * s * boy / 2
        uz = -math.sin(r) * s * boy / 2
        kup("Uc%d" % (s + 1), ux, -uz, 0.55, kal * 1.9, kal * 1.9, None,
            depth=0.0, mat=M_uc)
    px.shear_scene(SHEAR * 0.35)


def sahne_durum_ici(mn=4, fn=4, pn=4, yn=0):
    """ACIK LAVAS + IC MALZEME. Oyunda lavas duz bir elips, et 5x2'lik
    dikdortgen, patates iki satir piksel. Burada hepsi hacimli ve
    birbirinin ustune biniyor - gercek bir durum tabagi gibi."""
    px.reset()
    px.setup(56, 32)
    px.ortho_cam(0, 0, 56, 32)
    px.world("#000000", 0.0)

    M_lavas = px.cel_nx("Lavas", ["#a8794a", "#c9a06a", "#f0d5a8", "#f8e6c4"],
                        [0.0, 0.22, 0.62, 0.90], axis="Z",
                        noise=0.022, noise_scale=1.4)
    M_et = px.cel_nx("Et", mat_et(), [0.0, 0.10, 0.24, 0.42, 0.62, 0.80, 0.94],
                     axis="Z", noise=0.03, noise_scale=2.4)
    M_pat = px.cel_nx("Pat", mat_patates(0.5), [0.0, 0.18, 0.44, 0.72, 0.92], axis="Z")
    M_tur = px.cel_nx("Tur", ["#3f5c14", "#6d9127", "#9dbe45", "#c3da6e"],
                      [0.0, 0.28, 0.62, 0.90], axis="Z")
    M_yog = px.cel_nx("Yog", ["#d6cbae", "#efe7d0", "#fffdf2"], [0.0, 0.42, 0.84], axis="Z")

    # --- lavas: yassi elipsoit, kenari hafif dalgali ---
    lv = elipsoit("Lavas", 24.0, 10.0, 2.2, mat=M_lavas, duz=0.035)
    lv.location = (0, 0, -4.0)

    # --- et parcalari: lavasin ortasinda obek ---
    for i in range(max(0, min(mn, 6)) * 2):
        u = (i + 0.5) / max(1, mn * 2)
        x = -13.0 + u * 26.0
        y = math.sin(i * 2.7) * 2.6
        e = elipsoit("Et%d" % i, 3.4, 1.9, 1.5, mat=M_et, duz=0.10)
        e.location = (x, y - 1.5, -1.2 + math.sin(i * 1.9) * 0.7)
        e.rotation_euler = (0, math.radians(math.sin(i * 3.1) * 26), 0)

    # --- patates cubuklari: et obeginin ustune capraz ---
    for i in range(max(0, min(fn, 6))):
        c = cubuk("Pat%d" % i, 9.0 + (i % 3) * 2.0, 1.25, mat=M_pat, buk=0.6)
        c.location = (-10.0 + i * 4.4, -3.5, 0.8 + (i % 2) * 1.1)
        c.rotation_euler = (0, math.radians(-30 + i * 17), 0)

    # --- tursu dilimleri: kenarda ---
    for i in range(max(0, min(pn, 4))):
        t = elipsoit("Tur%d" % i, 2.7, 2.7, 0.8, mat=M_tur)
        t.location = (-16.0 + i * 10.0, -5.0, -2.6 + (i % 2) * 4.6)
        # -62 derecede dilim kenardan gorunup ince yesil bir serit
        # oluyordu; disk yuzu Z'ye dik, kameraya donmesi ~90 istiyor
        t.rotation_euler = (math.radians(-82 + (i % 2) * 8), 0,
                            math.radians(i * 26))

    # --- yogurt: ustten gezdirilen serit ---
    if yn > 0:
        for i in range(10):
            u = i / 9.0
            kup("Yog%d" % i, -14.0 + u * 28.0, -2.0 + math.sin(u * 7.0) * 2.4,
                1.9, 1.1, 1.1, None, depth=-6.0, mat=M_yog)

    px.shear_scene(SHEAR)


def sahne_kup(q=1.0):
    """Servis patates kupu (food.js drawFriesCup): kagit kup + tasan
    cubuklar. Oyunda cubuklar tek satir piksel."""
    px.reset()
    px.setup(30, 34)
    px.ortho_cam(0, 0, 30, 34)
    px.world("#000000", 0.0)

    M_kagit = px.cel_nx("Kagit", ["#a83a2c", "#c9503c", "#e2664a", "#f2907a"],
                        [0.0, 0.26, 0.60, 0.90], axis="X")
    M_pat = px.cel_nx("Pat", mat_patates(0.5), [0.0, 0.18, 0.44, 0.72, 0.92], axis="Z")

    # kup: ters kesik koni
    bm = bmesh.new()
    seg, rings = 26, 12
    prev = None
    for i in range(rings + 1):
        u = i / rings
        r = 5.0 + u * 4.2
        zz = -12.0 + u * 18.0
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            vs.append(bm.verts.new((math.cos(a) * r, math.sin(a) * r * 0.5, zz)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg], vs[(k + 1) % seg], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    kupa = new_obj("Kup", bm)
    kupa.data.materials.append(M_kagit)

    # tasan cubuklar
    n = int(3 + q * 6)
    for i in range(n):
        u = i / max(1, n - 1)
        c = cubuk("PC%d" % i, 12.0 + (i % 3) * 3.0, 1.3, mat=M_pat, buk=0.5)
        c.location = (-4.5 + u * 9.0, -3.0 - (i % 2) * 1.5, 6.0 + (i % 3) * 2.2)
        c.rotation_euler = (math.radians((i % 2) * 18), math.radians(58 + i * 9), 0)
    px.shear_scene(SHEAR * 0.5)


# ------------------------------------------------------------------ denetim
def allowed():
    ok = list(pal.ALL_HEX)
    ok += ["#8a6218", "#a8791c", "#dcae42", "#f0d271", "#fff0b8",
           "#7a5410", "#a87a1c", "#d9ab3e", "#e8bf52",
           "#5e3f0c", "#8a5c12", "#b8801f", "#d9a03a", "#f5d78e",
           "#52290a", "#7e4412", "#9c5718", "#bd7024", "#d98f38", "#eeb463", "#ffd291",
           "#a8794a", "#c9a06a", "#f0d5a8", "#f8e6c4",
           "#3f5c14", "#6d9127", "#9dbe45", "#c3da6e",
           "#d6cbae", "#efe7d0", "#fffdf2",
           "#a83a2c", "#c9503c", "#e2664a", "#f2907a"]
    return sorted(set(ok))


# ---------------------------------------------------------------------- main
def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "patates"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "d_%s.png" % ad)), "#2b2018", 105)

    if mode == "patates":
        for i in range(6):
            sahne_patates(kare=i); paths.append(cek("pat%d" % i))
        px.audit(paths[1], allowed(), "patates", show=16)
        px.contact(paths, 3, os.path.join(OUT, "durum_patates_x6.png"), scale=6)
        px.sheet(paths, 6, os.path.join(OUT, "patates_sheet.png"))

    elif mode == "ici":
        setups = [
            dict(mn=1, fn=0, pn=0),
            dict(mn=4, fn=0, pn=0),
            dict(mn=4, fn=4, pn=0),
            dict(mn=4, fn=4, pn=4),
            dict(mn=4, fn=4, pn=4, yn=4),
            dict(mn=6, fn=6, pn=4, yn=4),
        ]
        for i, s in enumerate(setups):
            sahne_durum_ici(**s); paths.append(cek("ici%d" % i))
        px.audit(paths[4], allowed(), "durum ici", show=24)
        px.contact(paths, 2, os.path.join(OUT, "durum_ici_x5.png"), scale=5)
        px.contact(paths, 3, os.path.join(OUT, "durum_ici_x2.png"), scale=2)

    elif mode == "kup":
        for i, q in enumerate((0.3, 0.7, 1.0)):
            sahne_kup(q=q); paths.append(cek("kup%d" % i))
        px.contact(paths, 3, os.path.join(OUT, "durum_kup_x5.png"), scale=5)

    print("DURUM_DONE %s" % mode)


if __name__ == "__main__":
    main()
