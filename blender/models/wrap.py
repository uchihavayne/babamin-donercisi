"""DURUM - 3B model + piksel-art render.

Oyundaki karsiligi: js/food.js -> drawWrapRolled()
  govde 40 x 13, rrect yaricap 5, uclarda elips
  renkler  ham : base #f0d5a8  shade #c9a06a  lite #f8e6c4
           kizarmis: -> #d9a765 / #a87a41 / #f0c68e  (mixHex ile)
           yanik   : #3f3129 / #241c17 / #544234
  kagit mansonu 21 px, #cfc9b8 / #e8e4d6
  izgara izleri #8a5a2a, koyu benekler #6b3f18

Yerel koordinat: (0,0) = oyunun cx,cy'si.  blender_z = -yerel_y
Tuval: 52 x 28

Golgeleme ekseni Z: yatay silindir, isik ustten. Oyun da ayni sekilde
ustte `lite` bandi, ortada `base`, altta `shade` cizip birakiyor.
"""
import sys, os, math
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
import pxcore as px
import palette as pal

OUT = os.path.join(_HERE, "out")

W, H = 40.0, 13.0
CANVAS_W, CANVAS_H = 52, 28


def gz(y):
    return -float(y)

# ------------------------------------------------------------------ renkler
def mix_hex(a, b, k):
    """art.js mixHex - iki hex arasi dogrusal karisim."""
    pa = [int(a.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
    pb = [int(b.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
    return "#%02x%02x%02x" % tuple(
        int(round(pa[i] + (pb[i] - pa[i]) * k)) for i in range(3))

def blend(over, under, a):
    """Oyunun globalAlpha ile ustuste bindirmesinin duz renk karsiligi."""
    po = [int(over.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
    pu = [int(under.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
    return "#%02x%02x%02x" % tuple(
        int(round(po[i] * a + pu[i] * (1 - a))) for i in range(3))

def wrap_cols(kiz=0.0, burnt=False):
    """food.js:drawWrapRolled icindeki base/shade/lite secimi."""
    if burnt:
        return "#3f3129", "#241c17", "#544234"
    if kiz <= 0:
        return "#f0d5a8", "#c9a06a", "#f8e6c4"
    return (mix_hex("#f0d5a8", "#d9a765", kiz),
            mix_hex("#c9a06a", "#a87a41", kiz),
            mix_hex("#f8e6c4", "#f0c68e", kiz))

# Oyunun dikey bant duzeni (rrect yiginindan okunmus):
#   en ust 1 px  base, sonra 4 px lite, orta base, en alt 2 px shade
# nz -1..1 -> n01 0..1 olarak:
NZ_STOPS = [0.0, 0.16, 0.60, 0.90]      # shade | base | lite | base

# --------------------------------------------------------------- mesh yardim
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

def capsule(name, length, r0, r1, seg=44, rings=26, mat=None):
    """Yatay durum govdesi: X ekseni boyunca, uclari yuvarlatilmis,
    hafif konik (bir ucu daha dolgun - gercek durum boyle sarilir)."""
    bm = bmesh.new()
    prev = None
    for i in range(rings + 1):
        u = i / rings
        x = -length / 2 + u * length
        r = r0 + (r1 - r0) * u
        # uclarda yuvarlatma (yarim elips profil)
        cap = 0.16
        if u < cap:
            r *= math.sin(u / cap * math.pi / 2) ** 0.62
        elif u > 1 - cap:
            r *= math.sin((1 - u) / cap * math.pi / 2) ** 0.62
        r = max(0.25, r)
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            # lavas sarimi: cevrede hafif kose - duz ekmek gibi okusun
            rr = r * (1 + 0.035 * math.sin(a * 5.0 + u * 2.2))
            vs.append(bm.verts.new((x, math.sin(a) * rr, math.cos(a) * rr)))
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

def tube(name, x0, x1, r, thick=0.0, seg=40, mat=None, arc=1.0):
    """Kagit mansonu: govdeyi saran ince kabuk."""
    bm = bmesh.new()
    prev = None
    n = 2
    for i in range(n + 1):
        x = x0 + (x1 - x0) * i / n
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg * arc - math.pi * arc + math.pi / 2
            vs.append(bm.verts.new((x, math.sin(a) * r, math.cos(a) * r)))
        if prev is not None:
            for k in range(seg - (0 if arc >= 1.0 else 1)):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    if mat:
        ob.data.materials.append(mat)
    return ob

def ellip(name, cx, gy, rx, ry, depth=-2.0, mat=None, seg=28):
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, cap_ends=True, segments=seg, radius=1.0)
    ob = new_obj(name, bm, smooth=False)
    ob.scale = (float(rx), float(ry), 1.0)
    ob.rotation_euler = (math.radians(90), 0, 0)
    ob.location = (float(cx), float(depth), gz(gy))
    if mat:
        ob.data.materials.append(mat)
    return ob

def dot(name, x, y, col, depth=-9.0, size=1.0):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    ob = new_obj(name, bm, smooth=False)
    ob.scale = (size, 0.5, size)
    ob.location = (x + 0.5, depth, gz(y) - 0.5)
    ob.data.materials.append(px.flat(name + "M", col))
    return ob

# --------------------------------------------------------------- sahne kurma
def build_scene(kiz=0.0, burnt=False, paper=False,
                pickle=False, yogurt=False, fries=False):
    px.reset()
    px.setup(CANVAS_W, CANVAS_H)
    px.ortho_cam(0, 0, CANVAS_W, CANVAS_H)
    px.world("#000000", 0.0)

    base, shade, lite = wrap_cols(kiz, burnt)

    specks = []
    # izgara izleri: kiz > .18'den sonra, 5 adet, 7 px arayla
    if kiz > .18 and not burnt:
        # food.js: globalAlpha .55 * izK ile #8a5a2a. Duz renk karsiligini
        # onceden hesaplayip yaziyoruz - cikti yine oyun paletinde kaliyor.
        izg = min(1.0, (kiz - .18) / .82)
        specks.append({"kind": "line",
                       "color": blend("#8a5a2a", base, .55 * izg),
                       "along": "X", "period": 7.0, "width": 1.0,
                       "skew": 0.38, "dash": 0.0, "min_n01": 0.30})
    # iyice kizarinca koyu benekler
    if kiz > .62 and not burnt:
        specks.append({"kind": "dot", "color": "#6b3f18",
                       "scale": 0.55, "size": 0.20, "min_n01": 0.30})

    M_body = px.cel_nx("Lavas", [shade, base, lite, base], NZ_STOPS,
                       axis="Z", noise=0.014, noise_scale=1.1, specks=specks)
    M_paper = px.cel_nx("Kagit", ["#b9b3a2", "#cfc9b8", "#f4f2e8", "#e8e4d6"],
                        [0.0, 0.13, 0.55, 0.88], axis="Z")

    # zemin golgesi (food.js: ell(cx, cy+8, w/2, 3, '#000') @ .25)
    ellip("Golge", 0, 8, W / 2, 3, 14.0, px.flat_a("GolgeM", "#000000", 0.25))

    # govde: sag uc biraz daha dolgun (icerik o tarafa dogru)
    capsule("Durum", W, H / 2 - 0.35, H / 2 + 0.25, mat=M_body)

    # --- izgara izleri (grill marks) 3B'de govdeyi sariyor -----------------
    # (materyaldeki `line` specks bunu yapiyor; ayrica geometri yok)

    # --- kagit mansonu ----------------------------------------------------
    if paper:
        tube("Kagit", -W / 2 - 1, -W / 2 + 20, H / 2 + 0.6, mat=M_paper)

    # --- uctan tasan icerik (food.js sonundaki px() cagrilari) -------------
    dot("Et1", W / 2 - 4, -2, "#c98436")
    dot("Et2", W / 2 - 5, 1, "#8a4f1e")
    if pickle:
        dot("Tursu", W / 2 - 6, -3, pal.P["g1"])
    if yogurt:
        dot("Yogurt", W / 2 - 3, 2, pal.P["s0"])
    if fries:
        dot("Patates", W / 2 - 7, 2, pal.P["p1"])


def allowed():
    ok = list(pal.ALL_HEX) + ["#8a5a2a", "#6b3f18", "#c98436", "#8a4f1e",
                              "#cfc9b8", "#e8e4d6", "#f4f2e8", "#b9b3a2"]
    for i in range(41):
        k = i / 40.0
        ok += list(wrap_cols(k))
        if k > .18:
            ok.append(blend("#8a5a2a", wrap_cols(k)[0], .55 * min(1.0, (k - .18) / .82)))
    ok += list(wrap_cols(0, True))
    return sorted(set(ok))

# ---------------------------------------------------------------------- main
def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "look"
    os.makedirs(OUT, exist_ok=True)

    if mode == "look":
        setups = [
            dict(kiz=0.0),
            dict(kiz=0.35),
            dict(kiz=0.70),
            dict(kiz=1.0),
            dict(kiz=0.0, burnt=True),
            dict(kiz=0.85, paper=True, pickle=True, yogurt=True, fries=True),
        ]
        paths = []
        for i, s in enumerate(setups):
            build_scene(**s)
            paths.append(px.outline(px.render(os.path.join(OUT, "wrap%d.png" % i)),
                                    "#2b2018", 110))
        px.audit(paths[2], allowed(), "wrap2", show=16)
        px.contact(paths, 3, os.path.join(OUT, "wrap_x6.png"), scale=6)
        px.contact(paths, 6, os.path.join(OUT, "wrap_x1.png"), scale=1)

    print("WRAP_DONE %s" % mode)


if __name__ == "__main__":
    main()
