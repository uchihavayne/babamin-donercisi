"""KESIM - bicak + tiraslanan et. 3B model + piksel-art render.

Oyundaki karsiligi: js/art.js -> drawSpit() sonundaki bicak blogu
  fr(kx-10, ky, 14, 3, '#c9d2da')   -> 14x3'luk duz gri dikdortgen
  fr(kx-17, ky-1, 8, 5, '#5b3a20')  -> 8x5'lik kahve sap
  taze kesim yuzu: konide 2 px acik seritten ibaret
  dusen et: 1 px'lik `part()` noktalari

Sorun: kesim oyunun EN COK tekrarlanan hareketi ama gorsel olarak en
zayifi. Bicak bir dikdortgen, dusen et nokta. Bu dosya ucunu birden
yeniden tasarliyor:

  bicak   - gercek doner bicagi: uzun ince agiz, sirt kalinligi,
            boyun (bolster), perculu sap. 4 acidan.
  dilim   - tirasla ayrilan et KIVRILIR. Duz cubuk degil; bir ucu
            kizarmis kabuk, ic yuzu acik. 6 takla karesi.
  kesim   - bicagin koniye girip bir dilimi soymasi: 6 kare.

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


def prizma(name, kesit, x0, x1, mat=None, smooth=False, olcek=None):
    """Kesiti X boyunca supurur. kesit: [(y, z), ...] saat yonunde.
    olcek(u) verilirse kesit boyunca daralir/genisler."""
    bm = bmesh.new()
    prev = None
    first = None
    n = 10
    for i in range(n + 1):
        u = i / n
        x = x0 + (x1 - x0) * u
        k = olcek(u) if olcek else 1.0
        vs = [bm.verts.new((x, y * k, z * k)) for (y, z) in kesit]
        if prev is not None:
            m = len(kesit)
            for j in range(m):
                bm.faces.new((prev[j], prev[(j + 1) % m],
                              vs[(j + 1) % m], vs[j]))
        else:
            first = vs
        prev = vs
    bm.faces.new(list(reversed(first)))
    bm.faces.new(prev)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=smooth)
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


def cone_profile(ty):
    """art.js:coneProfile - birebir."""
    if ty < .09:
        return .52 + .44 * (ty / .09) * (2 - ty / .09)
    if ty < .62:
        u = (ty - .09) / .53
        return .96 + .04 * math.sin(u * math.pi)
    k = (ty - .62) / .38
    return max(.10, 1 - k * k * .90)


# ---------------------------------------------------------------- BICAK
def bicak_kur(mat_agiz, mat_sirt, mat_sap, mat_percin, boy=26.0):
    """Doner bicagi. Agiz ince ve uzun, sirt kalin; ikisi arasinda
    keskin bir kama. Sap perculu, boyunda pirinc bilezik.

    Oyundaki hali 14x3'luk duz bir dikdortgendi - kalinlik, agiz
    keskinligi ve sap detayi yoktu.
    """
    # --- agiz: kama kesiti. z<0 keskin uc, z>0 sirt ---
    #   (y, z)  y = derinlik, z = yukseklik
    kesit_agiz = [(-0.5, 1.5), (0.5, 1.5), (0.9, 0.2), (0.0, -1.6), (-0.9, 0.2)]
    b = prizma("Agiz", kesit_agiz, -boy / 2, boy / 2 - 7, mat=mat_agiz, smooth=True,
               olcek=lambda u: 0.72 + 0.28 * (1 - (1 - u) ** 2))
    # --- sirt seridi: agzin ustunde daha koyu ince bant ---
    prizma("Sirt", [(-0.55, 1.9), (0.55, 1.9), (0.55, 1.35), (-0.55, 1.35)],
           -boy / 2 + 1, boy / 2 - 7, mat=mat_sirt)
    # --- boyun / bilezik ---
    prizma("Bilezik", [(-1.5, 2.4), (1.5, 2.4), (1.5, -1.9), (-1.5, -1.9)],
           boy / 2 - 7.6, boy / 2 - 5.6, mat=mat_percin)
    # --- sap: hafif kalinlasip ucta yuvarlanir ---
    kesit_sap = [(-1.7, 2.6), (1.7, 2.6), (2.0, 0.4), (1.2, -2.2),
                 (-1.2, -2.2), (-2.0, 0.4)]
    prizma("Sap", kesit_sap, boy / 2 - 5.6, boy / 2 + 2.4, mat=mat_sap, smooth=True,
           olcek=lambda u: 0.86 + 0.30 * math.sin(u * math.pi))
    # --- perculer ---
    for i, dx in enumerate((-2.6, 0.4)):
        kup("Percin%d" % i, boy / 2 - 2.0 + dx, 0, 0.9, 0.9, 1.0, None,
            depth=-2.4, mat=mat_percin)
    return b


def sahne_bicak(aci=0.0, boy=26.0):
    px.reset()
    px.setup(40, 20)
    px.ortho_cam(0, 0, 40, 20)
    px.world("#000000", 0.0)

    # Celik: oyunun kendi bicak tonlari (#c9d2da/#eef4f8/#ffffff) korunur,
    # araya iki ara ton girer - kama kesiti ancak boyle okunur.
    M_agiz = px.cel_nx("Celik", ["#8f9aa4", "#a9b4be", "#c9d2da", "#eef4f8", "#ffffff"],
                       [0.0, 0.20, 0.46, 0.74, 0.93], axis="Z")
    M_sirt = px.cel_nx("Sirt", ["#6d7883", "#8f9aa4", "#b4bfc8"],
                       [0.0, 0.40, 0.82], axis="Z")
    M_sap = px.cel_nx("Sap", ["#3f2712", "#5b3a20", "#7a5230", "#a5713f", "#c99565"],
                      [0.0, 0.18, 0.44, 0.72, 0.92], axis="Z")
    M_per = px.cel_nx("Percin", ["#a97113", "#e0a41f", "#ffd34e", "#fff2a8"],
                      [0.0, 0.30, 0.64, 0.90], axis="Z")

    bicak_kur(M_agiz, M_sirt, M_sap, M_per, boy=boy)
    if aci:
        for ob in bpy.context.scene.objects:
            if ob.type == "MESH":
                ob.rotation_euler = (0, math.radians(aci), 0)


# ---------------------------------------------------------------- DILIM
def dilim_kur(kivrim=1.0, boy=11.0, en=7.4, mat=None, kabuk_mat=None):
    """Tiraslanan et dilimi: ince bir yaprak, bir ucundan KIVRILIR.
    Ates goren yuzu kabuk, ic yuzu acik. Oyunda bu 1 px'lik bir noktaydi."""
    nx, ny = 22, 8
    bm = bmesh.new()
    grid = []
    for j in range(ny + 1):
        v = j / ny
        satir = []
        for i in range(nx + 1):
            u = i / nx
            # kivrilma: bir uc rulo olur (yay yaricapi u ile kucultulur)
            t = u ** 1.35
            ang = t * math.pi * 1.55 * kivrim
            R = boy / max(0.35, (math.pi * 1.55 * kivrim))
            x = math.sin(ang) * R
            z = (1 - math.cos(ang)) * R
            # dilim eni boyunca hafif dalga: duz plaka gibi durmasin
            y = (v - .5) * en * (1.0 - 0.22 * math.sin(u * 3.1))
            z += math.sin(v * math.pi * 2.0 + u * 4.0) * 0.28
            satir.append(bm.verts.new((x, y, -z)))
        grid.append(satir)
    for j in range(ny):
        for i in range(nx):
            bm.faces.new((grid[j][i], grid[j][i + 1],
                          grid[j + 1][i + 1], grid[j + 1][i]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj("Dilim", bm)
    if mat:
        ob.data.materials.append(mat)
    # kalinlik: ince ama sifir degil - kenardan kabuk gorunsun
    md = ob.modifiers.new("K", "SOLIDIFY")
    md.thickness = 1.25
    md.offset = -1.0
    # Serit X ekseninde yatirilir: genisligi (Y) ekran dikeyine duser.
    # Yatirilmazsa kamera yalnizca kivrim egrisini goruyor, parca 1px
    # kalinliginda bir tel gibi cikiyor.
    ob.rotation_euler = (math.radians(-58), 0, 0)
    return ob


# Elle secilmis takla acilari: hicbiri seridi kenardan gostermiyor.
# Dogrusal rampada son kareler ~94 derece Y donusune gidip parcayi
# yassi bir cubuga ceviriyordu.
DILIM_ACI = [(-58, -12, 0), (-50, 20, 14), (-68, -26, -12),
             (-46, 10, 28), (-74, 26, -20), (-56, -22, 34)]

def sahne_dilim(kare=0, kivrim=1.0, roast=0.75):
    px.reset()
    px.setup(26, 22)
    px.ortho_cam(0, 0, 26, 22)
    px.world("#000000", 0.0)

    # ET tonlari: js/art.js icindeki ET tablosu
    M_et = px.cel_nx("Et", ["#52290a", "#7e4412", "#9c5718", "#bd7024",
                            "#d98f38", "#eeb463", "#ffd291"],
                     [0.0, 0.10, 0.24, 0.42, 0.62, 0.80, 0.94], axis="Z",
                     noise=0.03, noise_scale=2.6)
    d = dilim_kur(kivrim=kivrim, mat=M_et)
    rx, ry, rz = DILIM_ACI[kare % len(DILIM_ACI)]
    d.rotation_euler = (math.radians(rx), math.radians(ry), math.radians(rz))


# ---------------------------------------------------------------- KESIM
def sahne_kesim(faz=0.0):
    """Bicagin koniye girip dilim soymasi. faz 0..1:
       0.00  bicak yaklasiyor
       0.25  agiz ete degdi, taze kesim yuzu aciliyor
       0.50  dilim soyuluyor, kivrim basliyor
       0.75  dilim ayriliyor
       1.00  dilim dusuyor, kesim yuzu acikta
    """
    px.reset()
    px.setup(56, 38)
    px.ortho_cam(0, 0, 56, 38)
    px.world("#000000", 0.0)

    M_agiz = px.cel_nx("Celik", ["#8f9aa4", "#a9b4be", "#c9d2da", "#eef4f8", "#ffffff"],
                       [0.0, 0.20, 0.46, 0.74, 0.93], axis="Z")
    M_sirt = px.cel_nx("Sirt", ["#6d7883", "#8f9aa4", "#b4bfc8"], [0.0, 0.40, 0.82], axis="Z")
    M_sap = px.cel_nx("Sap", ["#3f2712", "#5b3a20", "#7a5230", "#a5713f"],
                      [0.0, 0.20, 0.50, 0.84], axis="Z")
    M_per = px.cel_nx("Percin", ["#a97113", "#e0a41f", "#ffd34e"], [0.0, 0.34, 0.78], axis="Z")
    # koni: disi kizarmis, taze kesim yuzu ACIK (icerisi)
    M_koni = px.cel_nx("Koni", ["#4d290f", "#78421a", "#a5622a", "#d18c42", "#f0b269"],
                       [0.0, 0.16, 0.40, 0.68, 0.90], axis="X",
                       band=1.0, band_freq=0.5, band_amt=0.05)
    M_taze = px.cel_nx("Taze", ["#a5622a", "#d18c42", "#f0b269", "#ffd9a0"],
                       [0.0, 0.30, 0.64, 0.90], axis="X")
    M_et = px.cel_nx("Et", ["#52290a", "#7e4412", "#9c5718", "#bd7024",
                            "#d98f38", "#eeb463", "#ffd291"],
                     [0.0, 0.10, 0.24, 0.42, 0.62, 0.80, 0.94], axis="Z")

    # --- koninin SAG tarafi (kadraja giren parca) ---
    bm = bmesh.new()
    seg, rings = 34, 28
    H0 = 38.0
    KONI_X, KONI_R = 17.0, 13.0     # merkez kadrajin sagina tasar
    prev = None
    for i in range(rings + 1):
        ty = i / rings
        r = KONI_R * cone_profile(ty * .90 + .05)
        zz = 19.0 - ty * H0
        vs = []
        for j in range(seg):
            a = math.pi * (-0.5 + j / (seg - 1))     # yalniz on yarim
            # x ezilmesi kaldirildi: koni koni gibi dursun
            vs.append(bm.verts.new((KONI_X + math.sin(a) * r,
                                    math.cos(a) * r * 0.55, zz)))
        if prev is not None:
            for k in range(seg - 1):
                bm.faces.new((prev[k], prev[k + 1], vs[k + 1], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    koni = new_obj("Koni", bm)
    koni.data.materials.append(M_koni)

    # --- taze kesim yuzu: bicagin actigi ic yuz (faz ile buyur) ---
    # --- bicak: yukaridan asagi iner, sol yanaga bastirir ---
    by = 15.0 - faz * 28.0                 # inis tuvale gore buyutuldu
    bas = min(1.0, faz * 3.2)              # koniye yaklasma
    bicak_kur(M_agiz, M_sirt, M_sap, M_per, boy=22.0)
    for ob in bpy.context.scene.objects:
        if ob.name in ("Agiz", "Sirt", "Bilezik", "Sap", "Percin0", "Percin1"):
            # Z'de 180: agiz koniye doner, sap kadrajin soluna cikar.
            ob.location = (-7.0 + bas * 3.0, -7.0, by)
            ob.rotation_euler = (0, math.radians(7), math.radians(180))

    # --- taze kesim yuzu: bicagin gectigi yerde ic et acilir ---
    if faz > 0.18:
        h = min(1.0, (faz - 0.18) / 0.55) * 20.0
        t = prizma("Taze", [(-0.5, 0.0), (0.5, 0.0), (0.5, -h), (-0.5, -h)],
                   -0.7, 0.7, mat=M_taze)
        t.location = (5.2, -4.6, 15.0)

    # --- soyulan dilim: kesim agzindan ayrilip dusuyor ---
    if faz > 0.28:
        k = (faz - 0.28) / 0.72
        d = dilim_kur(kivrim=0.30 + k * 1.30, boy=12.0, mat=M_et)
        d.location = (4.0 - k * 5.0, -9.0, by + 2.0 - k * 9.0)
        d.rotation_euler = (math.radians(-58 + k * 24), math.radians(-14 - k * 26),
                            math.radians(k * 20))


# ------------------------------------------------------------------ denetim
def allowed():
    ok = list(pal.ALL_HEX)
    ok += ["#8f9aa4", "#a9b4be", "#c9d2da", "#eef4f8", "#ffffff",
           "#6d7883", "#b4bfc8", "#3f2712", "#5b3a20", "#7a5230", "#a5713f",
           "#c99565", "#a97113", "#e0a41f", "#ffd34e", "#fff2a8",
           "#52290a", "#7e4412", "#9c5718", "#bd7024", "#d98f38", "#eeb463",
           "#ffd291", "#4d290f", "#78421a", "#a5622a", "#d18c42", "#f0b269",
           "#ffd9a0"]
    return sorted(set(ok))


# ---------------------------------------------------------------------- main
def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "bicak"
    os.makedirs(OUT, exist_ok=True)
    paths = []

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "k_%s.png" % ad)), "#2b2018", 105)

    if mode == "bicak":
        for i, a in enumerate((0, -6, -14, 8)):
            sahne_bicak(aci=a); paths.append(cek("bicak%d" % i))
        px.audit(paths[0], allowed(), "bicak", show=16)
        px.contact(paths, 2, os.path.join(OUT, "kesim_bicak_x6.png"), scale=6)

    elif mode == "dilim":
        for i in range(6):
            sahne_dilim(kare=i, kivrim=0.55 + i * 0.20)
            paths.append(cek("dilim%d" % i))
        px.audit(paths[2], allowed(), "dilim", show=16)
        px.contact(paths, 3, os.path.join(OUT, "kesim_dilim_x6.png"), scale=6)
        px.sheet(paths, 6, os.path.join(OUT, "dilim_sheet.png"))

    elif mode == "kesim":
        for i in range(6):
            sahne_kesim(faz=i / 5.0)
            paths.append(cek("kesim%d" % i))
        px.audit(paths[3], allowed(), "kesim", show=20)
        px.contact(paths, 3, os.path.join(OUT, "kesim_dizi_x5.png"), scale=5)
        px.contact(paths, 6, os.path.join(OUT, "kesim_dizi_x2.png"), scale=2)
        px.sheet(paths, 6, os.path.join(OUT, "kesim_sheet.png"))

    print("KESIM_DONE %s" % mode)


if __name__ == "__main__":
    main()
