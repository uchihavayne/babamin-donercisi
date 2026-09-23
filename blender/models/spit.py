"""DONER SISI - 3B model + piksel-art render.

Oyundaki karsiligi: js/art.js -> drawSpit()
  LAY.spit = { cx:80, top:58, bot:168 }   maxR = 19
  ST.spit  = { x:58, y:50, w:46, h:126 }
  Isitici paneli: hx = cx+19, hw = 17, hh = H0-14

Koordinat: 1 Blender birimi = 1 oyun pikseli.
  blender_x = oyun_x        blender_z = -oyun_y   (oyunun Y'si asagi bakar)

Cikti tuvali: 64 x 144  (oyun x 56..120, oyun y 35..179)

Golgeleme oyunun kendi mantigiyla: ton = yuzey normalinin yatay bileseni.
Isik kaynagi yok; boylece koni donerken bantlar kaymiyor, sadece dikisler
(seam) donuyor - tam da art.js'in yaptigi sey.
"""
import sys, os, math, random
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
import pxcore as px
import palette as pal

OUT = os.path.join(_HERE, "out")

# ------------------------------------------------------------------ olculer
CX, TOP, BOT = 80.0, 58.0, 168.0
H0 = BOT - TOP            # 110
MAXR = 19.0
CANVAS_W, CANVAS_H = 64, 144
CAM_X, CAM_Z = 88.0, -107.0

# art.js'teki nx -> shade kademelerinin birebir karsiligi.
# nx esikleri: -.78 -.55 -.25 .10 .38 .62 .86   (n01 = nx*.5+.5)
NX_STOPS  = [0.0, .110, .225, .375, .550, .690, .810, .930]
NX_SHADES = [.52, .66, .80, .95, 1.12, 1.30, 1.12, .86]


def gz(y):
    """oyun y -> blender z"""
    return -float(y)

# ------------------------------------------------------- oyunun kendi egrisi
def ease(t):
    return t * t * (3 - 2 * t)

def cone_profile(ty):
    """art.js:coneProfile - birebir. ty 0 (ust) .. 1 (alt)."""
    if ty < .09:
        return .52 + .44 * ease(ty / .09)
    if ty < .62:
        u = (ty - .09) / .53
        return .96 + .04 * math.sin(u * math.pi)
    k = (ty - .62) / .38
    return max(.10, 1 - k * k * .90)

def meat_ramp(roast, top=False):
    """art.js: her bant kendi pisme derecesini tasir.

        lroast = roast * (.84 + .30 * n01)      <- isiticiya bakan yuz
        if (ty < .05) lroast *= .82             <- tepe daha az pismis
        renk   = meatColCalc(lroast) * shade
    """
    edges = NX_STOPS + [1.0]
    out = []
    for i, s in enumerate(NX_SHADES):
        n01 = (edges[i] + edges[i + 1]) / 2.0
        lroast = roast * (.84 + .30 * n01)
        if top:
            lroast *= .82
        r, g, b = pal.meat_col(lroast)
        out.append("#%02x%02x%02x" % tuple(
            max(0, min(255, int(round(v * s)))) for v in (r, g, b)))
    return out

def fat_hex(roast):
    """art.js: parlak yag damlasi = meatCol(roast*.9, 1.55)"""
    r, g, b = pal.meat_col(roast * .9)
    return "#%02x%02x%02x" % tuple(
        max(0, min(255, int(round(v * 1.55)))) for v in (r, g, b))

def line_hex(roast):
    """art.js: katman ayrim cizgisi = meatCol(roast*.92, .78)"""
    r, g, b = pal.meat_col(roast * .92)
    return "#%02x%02x%02x" % tuple(
        max(0, min(255, int(round(v * .78)))) for v in (r, g, b))

def steel_ramp():
    """Celigin ayni 8 kademeye oturtulmus hali (paletten secilmis)."""
    k = ("mt4", "mt4", "mt3", "mt2", "mt1", "mt0", "mt1", "mt3")
    return [pal.P[i] for i in k]

# --------------------------------------------------------------- mesh yardim
def new_obj(name, bm, smooth=False):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    if smooth:
        for p in me.polygons:
            p.use_smooth = True
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    return ob

def box(name, x0, y0, z0, x1, y1, z1, mat=None):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    ob = new_obj(name, bm)
    ob.scale = (abs(x1 - x0), abs(y1 - y0), abs(z1 - z0))
    ob.location = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    if mat:
        ob.data.materials.append(mat)
    return ob

def ellip(name, cx, gy, rx, ry, depth=-2.0, mat=None, seg=32):
    """Kameraya bakan yassi elips diski.

    Oyun saf on-gorunum ciziyor ama yatay yuzeyleri (koninin tepesi, yag
    tablasi) `ell()` ile yassi elips olarak sahteliyor. Ayni hileyi burada
    da kullaniyoruz; boylece sprite oyunun perspektifiyle birebir ortusuyor.
    """
    bm = bmesh.new()
    bmesh.ops.create_circle(bm, cap_ends=True, segments=seg, radius=1.0)
    ob = new_obj(name, bm)
    ob.scale = (float(rx), float(ry), 1.0)
    ob.rotation_euler = (math.radians(90), 0, 0)
    ob.location = (float(cx), float(depth), gz(gy))
    if mat:
        ob.data.materials.append(mat)
    return ob

def cyl(name, r, z0, z1, x=0.0, y=0.0, seg=20, mat=None, smooth=True):
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=seg,
                          radius1=r, radius2=r, depth=abs(z1 - z0))
    ob = new_obj(name, bm, smooth=smooth)
    ob.location = (x, y, (z0 + z1) / 2)
    if mat:
        ob.data.materials.append(mat)
    return ob

# ------------------------------------------------------------------ et konisi
SEAMS = 4          # cevrede kac dikis (art.js: ang*1.9/PI -> gorunur yuzde ~2)

def build_cone(mass=1.0, cut=0.0, rot=0.0, seed=7, layers=56, seg=64):
    """Istiflenmis et dilimlerinden koni.

    - yaricap art.js coneProfile'dan
    - `lay` katman dalgalanmasi geometriye islenmis (art.js layM)
    - SEAMS adet dikey oluk: donusun gorunur olmasini saglayan sey
    - siluet titremesi art.js'in +-1px rjit'inin karsiligi
    """
    rng = random.Random(seed)
    mass = max(0.0, min(1.0, mass))
    scale_r = 0.45 + 0.55 * mass
    cone_top = TOP + (1 - mass) * 10.0
    cone_h = H0 - (1 - mass) * 18.0

    bm = bmesh.new()
    prev = None
    for i in range(layers + 1):
        ty = i / layers
        gy = cone_top + ty * cone_h            # oyun y'si
        base = MAXR * scale_r * cone_profile(ty)
        # NOT: art.js'te `layM` YARICAPI degil GOLGEYI carpiyor. O yuzden
        # katman dalgasi burada degil, materyalde (cel_nx band=) duruyor.
        # Geometride sadece art.js'in rjit'i var: seyrek +-1 px basamak.
        if .06 < ty < .95:
            rj = (1 if math.sin(gy * .21) > .25 else 0) \
                 - (1 if math.sin(gy * .29 + 2.1) > .55 else 0)
            base += rj
        z = gz(gy)
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            # Yuzey ozellikleri (dikis, doku) `rot` kadar doner; mesh ekseni
            # sabit kalir. Boylece kesim yuzeyini dunya X'inde uygulayabiliriz
            # - oyunda da kesim ekran uzayinda sabit (bicak hep solda).
            af = a - rot
            r = base
            sa = (af * SEAMS) % (2 * math.pi)
            if sa < 0.55:
                r *= 1.0 - 0.075 * math.sin(sa / 0.55 * math.pi)
            r += math.sin(af * 3.0 + i * 1.31) * 0.15
            r = max(0.4, r)
            vs.append(bm.verts.new((math.cos(a) * r, math.sin(a) * r, z)))
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

    ob = new_obj("EtKonisi", bm, smooth=True)
    ob.location = (CX, 0, 0)

    # --- kesim yuzeyi: usta bicagi soldan gecmis, duz bir yuz kalmis -------
    if cut > 0.0:
        depth = cut * MAXR * scale_r * 0.9
        for v in ob.data.vertices:
            tyv = (-v.co.z - cone_top) / cone_h
            if not (0.08 < tyv < 0.80):
                continue
            band = 1.0 - abs(tyv - 0.44) / 0.40
            if band <= 0:
                continue
            plane = -(MAXR * scale_r) + depth * band
            if v.co.x < plane:
                v.co.x = plane
    return ob

# --------------------------------------------------------------- sahne kurma
def build_scene(mass=1.0, roast=0.62, cut=0.0, rot=0.0, seed=7,
                heater=True, flame_phase=0.0):
    px.reset()
    px.setup(CANVAS_W, CANVAS_H)
    px.ortho_cam(CAM_X, CAM_Z, CANVAS_W, CANVAS_H)
    px.world("#000000", 0.0)

    M_meat = px.cel_nx("Et", meat_ramp(roast), NX_STOPS,
                       band=1.0, band_amt=0.010, noise=0.016, noise_scale=1.4,
                       specks=[
                           # katman ayrim cizgileri: her 12 px, kesik kesik
                           {"kind": "line", "color": line_hex(roast),
                            "period": 12.0, "width": 1.0,
                            "dash": 0.55, "dash_scale": 13.0},
                           # parlak yag damlalari, agirlikli olarak sag yuzde
                           {"kind": "dot", "color": fat_hex(roast),
                            "scale": 0.45, "size": 0.24, "min_n01": 0.50},
                       ])
    M_steel = px.cel_nx("Celik", steel_ramp(), NX_STOPS)
    M_dark = px.flat("Koyu", pal.P["mt5"])

    # --- et konisi -------------------------------------------------------
    cone = build_cone(mass=mass, cut=cut, rot=rot, seed=seed)
    cone.data.materials.append(M_meat)

    scale_r = 0.45 + 0.55 * max(0.0, min(1.0, mass))
    cone_top = TOP + (1 - mass) * 10.0

    # --- tepe: domates + biber (art.js sonundaki ell() yigini) ------------
    top_r = round(MAXR * scale_r * cone_profile(.02))
    FRONT = -25.0          # koninin onunde: oyunun cizim sirasiyla ayni
    ellip("TepeGolge", CX, cone_top + 1, top_r - 1, 3, FRONT,
          px.flat("DomatesK", "#a8302a"))
    ellip("Domates", CX, cone_top, top_r - 1, 3, FRONT - 1,
          px.flat("DomatesA", "#d8443a"))
    ellip("DomatesIsik", CX - 2, cone_top - 1, max(2, top_r - 5), 1, FRONT - 2,
          px.flat("DomatesP", "#f2887a"))
    box("Biber1", CX + 3, FRONT - 3, gz(cone_top - 1), CX + 4, FRONT - 2.5,
        gz(cone_top - 2), px.flat("BiberK", pal.P["g2"]))
    box("Biber2", CX + 4, FRONT - 3, gz(cone_top - 2), CX + 5, FRONT - 2.5,
        gz(cone_top - 3), px.flat("BiberA", pal.P["g1"]))

    # --- sis mili --------------------------------------------------------
    cyl("Mil", 1.2, gz(TOP - 12), gz(BOT + 5), CX, 0, 12, M_steel)
    box("MilKapak", CX - 5.5, -5.5, gz(TOP - 15), CX + 5.5, 5.5, gz(TOP - 11), M_steel)
    box("Askilik", CX - 8.5, -6, gz(TOP - 19), CX + 8.5, 6, gz(TOP - 15), M_steel)
    box("TavanCubuk", CX - 1, -1, gz(TOP - 19), CX + 1, 1, gz(20), M_steel)

    # --- alt tabla / yag toplama (art.js sonu) ----------------------------
    box("TablaBoyun", CX - 9, FRONT - 4, gz(BOT), CX + 10, FRONT - 3.5, gz(BOT - 3),
        px.flat("TablaB", pal.P["mt4"]))
    box("TablaBoyunUst", CX - 9, FRONT - 4.5, gz(BOT - 2), CX + 10, FRONT - 4,
        gz(BOT - 3), px.flat("TablaBU", pal.P["mt1"]))
    ellip("TablaGolge", CX, BOT + 2, 13, 4, FRONT - 5, px.flat("TablaG", pal.P["mt4"]))
    ellip("Tabla", CX, BOT + 1, 13, 4, FRONT - 6, px.flat("TablaY", pal.P["mt1"]))
    ellip("TablaIc", CX, BOT + 1, 10, 2, FRONT - 7, px.flat("TablaI", pal.P["mt2"]))
    ellip("YagBirikinti", CX + 1, BOT + 2, 7, 1, FRONT - 8, px.flat("Yag", "#9a6a1e"))

    # --- isitici paneli (sagda, arkada) ----------------------------------
    if heater:
        hx, hy, hw, hh = CX + 19, TOP + 2, 17.0, H0 - 14
        box("PanelCerceve", hx - 1, 3, gz(hy + hh + 1), hx + hw + 1, 10, gz(hy - 1),
            px.flat("PanelKenar", pal.P["mt4"]))
        box("PanelGovde", hx, 4, gz(hy + hh), hx + hw, 9.6, gz(hy),
            px.flat("PanelYuz", pal.P["mt2"]))
        box("PanelUst", hx, 3.9, gz(hy + 1), hx + hw, 9.5, gz(hy),
            px.flat("PanelUstK", pal.P["mt0"]))
        box("PanelAlt", hx, 3.9, gz(hy + hh), hx + hw, 9.5, gz(hy + hh - 1),
            px.flat("PanelAltK", pal.P["mt5"]))
        box("PanelIc", hx + 2, 3.4, gz(hy + hh - 2), hx + hw - 2, 9.0, gz(hy + 2),
            px.flat("PanelKuyu", pal.EXTRA["heat_body"]))
        seg_h = int((hh - 8) // 6)
        for i in range(6):
            ey = hy + 4 + i * seg_h
            fl = .55 + .45 * math.sin(flame_phase * 6 + i * 1.9)
            base = pal.EXTRA["heat_a"] if i % 2 else pal.EXTRA["heat_b"]
            box("Rez%d" % i, hx + 3, 3.0, gz(ey + seg_h - 3), hx + hw - 3, 8.4, gz(ey),
                px.flat("RezK%d" % i, pal.EXTRA["heat_dark"]))
            box("RezY%d" % i, hx + 3, 2.8, gz(ey + seg_h - 4), hx + hw - 3, 8.2, gz(ey),
                px.flat("RezB%d" % i, base))
            box("RezS%d" % i, hx + 4, 2.6, gz(ey + seg_h - 5), hx + hw - 4, 8.0, gz(ey + 1),
                px.flat("RezS%d" % i, pal.EXTRA["heat_hot"]))
            if fl > .72:
                box("RezC%d" % i, hx + 5, 2.4, gz(ey + seg_h - 6), hx + hw - 5, 7.8, gz(ey + 2),
                    px.flat("RezC%d" % i, pal.EXTRA["heat_core"]))
    return cone

# ------------------------------------------------------------------- denetim
def allowed(roasts):
    ok = list(pal.ALL_HEX) + steel_ramp()
    for r in roasts:
        ok += meat_ramp(r)
    return sorted(set(ok))

# ---------------------------------------------------------------------- main
def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "look"
    os.makedirs(OUT, exist_ok=True)

    if mode == "look":
        roasts = [0.10, 0.45, 0.72, 0.95, 1.20]
        paths = []
        for i, r in enumerate(roasts):
            build_scene(mass=1.0, roast=r, cut=0.0 if i < 2 else 0.45, rot=0.4)
            paths.append(px.outline(px.render(os.path.join(OUT, "spit_roast%d.png" % i))))
        px.audit(paths[2], allowed(roasts), "spit_roast2", show=20)
        px.contact(paths, 5, os.path.join(OUT, "spit_roasts_x4.png"), scale=4)
        px.contact(paths, 5, os.path.join(OUT, "spit_roasts_x1.png"), scale=1)

    elif mode == "rot":
        n = 16
        paths = []
        for i in range(n):
            build_scene(mass=1.0, roast=0.72, cut=0.35,
                        rot=2 * math.pi * i / n, flame_phase=i * 0.11)
            paths.append(px.outline(px.render(os.path.join(OUT, "spit_rot%02d.png" % i))))
        px.sheet(paths, n, os.path.join(OUT, "spit_sheet.png"))
        px.contact(paths, 8, os.path.join(OUT, "spit_rot_x3.png"), scale=3)

    elif mode == "mass":
        vals = [1.0, 0.78, 0.55, 0.34, 0.14]
        paths = []
        for i, m in enumerate(vals):
            build_scene(mass=m, roast=0.72, cut=0.35 if m < .9 else 0.0, rot=0.9)
            paths.append(px.outline(px.render(os.path.join(OUT, "spit_mass%d.png" % i))))
        px.contact(paths, 5, os.path.join(OUT, "spit_mass_x4.png"), scale=4)

    print("SPIT_DONE %s" % mode)

if __name__ == "__main__":
    main()
