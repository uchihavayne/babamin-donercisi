"""ISKENDER TABAGI — tek 3B sahne (birlesik surum, 6. tur analiz madde 2).

    blender --background --factory-startup --python blender/models/iskender_hd.py [-- parca_oneki ...]
    python blender/hd_atlas.py iskender_hd iskender

Eskiden tabagin icerigi kodda ciziliyordu: pide kupleri ve et duz kare
bloklar, tereyagi turuncu zikzak, domates artili kirmizi daire. Simdi:
  isk_E_B_Y_<o>   : tabak + pide kupleri + et yigini (E 0..4) + tereyagli
                    domates sosu (B 0/1, pideye de isler) + yan yogurt (Y 0..3)
                    TEK sahnede; Eevee golgeleri birbirine duser.
  isk_bib_P_E_<o> : kozlenmis sivri biber (P 1..2), E seviyesindeki yiginin
                    ustunde yatar (tabak / pide / et holdout: arkada kalan gorunmez)
  isk_dom_T_<o>   : kozlenmis domates (T 1..3), tabagin on-solunda (tabak holdout)
Capa (cx, cy) = food.js drawPlate ile ayni; tabak yiyecek_hd.tabak ile birebir.
Oyunda: remake_gorsel.f_hdIskender (taban -> biber -> domates).
"""
import sys, os, math, json
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import durum_hd as D
import dolgu_hd as DG
import pide_hd as PH
import yiyecek_hd as Y

OUT = os.path.join(_HERE, "out", "iskender_hd")
HD = 2
K = 0.5
TUVAL = (-23, -17, 46, 30)
OLCEKLER = (1.8, 1.22, 0.9, 0.85, 1.0)
S4 = [0, .3, .5, .8]
cel = I.cel
h1 = DG.h1

# tabak (yiyecek_hd.tabak): taban z -3, derinlik carpani 0.8; ic yuzey profili
TABAK_IC = [(0.0, 1.2), (6.0, 1.2), (12.0, 1.25), (16.0, 1.5), (17.2, 2.2), (18.8, 3.0)]
TABAN = -1.8                 # cukurun tabani (z)
PIDE_UST = TABAN + 2.5       # pide kuplerinin ust yuzu
XM, YM = -2.0, 0.8           # et yigininin merkezi (derinlik y: + arka)


def tabak_z(x, y):
    """Tabagin ic yuzeyinin (x, y) noktasindaki yuksekligi."""
    r = math.sqrt(x * x + (y / 0.8) ** 2)
    for (r0, h0), (r1, h1_) in zip(TABAK_IC, TABAK_IC[1:]):
        if r <= r1:
            return -3.0 + h0 + (h1_ - h0) * (r - r0) / (r1 - r0)
    return 0.0


def yigin(E):
    """Et yigininin olculeri: yari boy, yari derinlik, kubbe yuksekligi."""
    return 5.5 + 1.8 * E, 4.2 + 0.9 * E, 0.7 + 0.55 * E


def ust_z(E, x, y):
    """Yiginin (yoksa pidenin) (x, y) ustundeki yuksekligi."""
    if E <= 0:
        return PIDE_UST
    Lm, Wm, H = yigin(E)
    q = 1.0 - ((x - XM) / Lm) ** 2 - 0.85 * ((y - YM) / Wm) ** 2
    return PIDE_UST + 0.3 + H * max(0.0, q) ** 0.65


def kup(ad, x, y, z, s, h, yaw, Mi, Mk):
    """Pide kupu: ustu kabuk, yanlari ekmek ici; kenarlari yuvarlak."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= s
        v.co.y *= s * (0.9 + 0.2 * h1(x * 3.1 + y))
        v.co.z *= h
    bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.35, segments=2, profile=0.6, affect="EDGES")
    ob = I.mesh_ob(ad, bm, Mi, smooth=True)
    ob.data.materials.append(Mk)
    for pol in ob.data.polygons:
        if pol.normal.z > 0.55:
            pol.material_index = 1
    ob.rotation_euler = ((h1(x + 7.7) - 0.5) * 0.25, (h1(y + 3.3) - 0.5) * 0.25, yaw)
    ob.location = (x, y, z + h / 2.0)
    return ob


def pide_kur(sosli, hold=None):
    if sosli:
        # tereyagli domates sosu pidenin ustune isler
        Mk = cel("PideSosKabuk", ["#5e220a", "#8e3a14", "#bc5a24", "#e08a48"], S4, noise=0.12, noise_scale=14)
        Mi = cel("PideSosIc", ["#9a5a30", "#c07e48", "#dca068", "#eec08a"], S4, noise=0.12, noise_scale=20)
    else:
        Mk, Mi = PH.ekmek(), PH.ekmek_ic()
    Mk, Mi = hold or Mk, hold or Mi
    n = 0
    for gx in range(-4, 4):
        for gy in range(-3, 3):
            x = -1.5 + gx * 3.1 + 1.55 + (h1(gx * 3.7 + gy * 1.3) - 0.5) * 0.9
            y = gy * 3.0 + 1.5 + (h1(gx * 1.9 + gy * 5.1) - 0.5) * 0.8
            if ((x + 1.5) / 11.5) ** 2 + (y / 8.4) ** 2 > 1.0:
                continue
            s = 2.5 + 0.6 * h1(n * 2.3)
            h = 2.1 + 0.5 * h1(n * 4.1)
            kup("pide%d" % n, x, y, TABAN - 0.1, s, h, (h1(n * 6.7) - 0.5) * 0.9, Mi, Mk)
            n += 1


def et_kur(E, Mt, hold=None, sosli=False):
    if E <= 0:
        return
    if sosli and not hold:
        # domates sosu etin ustunu kaplar (parlak koyu kirmizi); talas kenarlari koyu kalir
        Mt = dict(Mt, et=cel("EtSos", ["#4a1206", "#7e240c", "#a83c16", "#dc6a34"], [0, .25, .5, .8], noise=0.16, noise_scale=5),
                  et2=cel("EtSos2", ["#5a2008", "#8a3a14", "#b0542a", "#d8844a"], [0, .25, .5, .8], noise=0.2, noise_scale=7))
    Lm, Wm, H = yigin(E)
    for i in range({1: 11, 2: 17, 3: 24, 4: 31}[E]):
        u = ((i * 0.618034) % 1.0) * 2 - 1
        x = XM + u * Lm * 0.9
        y = YM + (h1(i * 5.3) - 0.5) * 2 * Wm * 0.8
        h = ust_z(E, x, y) - PIDE_UST - 0.3
        z = PIDE_UST + 0.35 + h * (0.25 + 0.75 * math.sqrt(h1(i * 2.9)))
        egim = math.radians(15 + 30 * h1(i * 7.1)) * min(1.0, 0.4 + 0.6 * h / max(H, 0.1))
        rot = (egim, math.radians((h1(i * 4.4) - 0.5) * 40), math.radians((h1(i * 6.6) - 0.5) * 70))
        DG.talas("et%d" % i, x, y, z, 5.0 + 1.6 * h1(i * 1.7), 3.6 + 1.2 * h1(i * 3.9), 0.5, rot,
                 0.5 + 0.7 * h1(i * 8.8), i * 1.37, hold or (Mt["et2"] if h1(i * 2.3) > 0.62 else Mt["et"]),
                 hold or Mt["et_kenar"])


def sos_kur(E):
    """Tereyagli domates sosu: yiginin ustunde parlak seritler + tabak
    cukurunda pidelerin arasinda gorunen gol."""
    M = cel("DomatesSos", ["#4e0c04", "#8a1e08", "#bc3412", "#e86030"], S4)
    Mt = cel("Tereyag", ["#8a4a08", "#c8801a", "#eab040", "#fde08a"], [0, .3, .55, .82])
    Lm, Wm, _ = yigin(max(E, 1))
    for s in range(2):
        nok = []
        n = 28
        for q in range(n + 1):
            u = q / float(n)
            x = XM - Lm * 0.75 + u * Lm * 1.5
            y = YM + math.sin(u * 7.0 + s * 2.6) * Wm * 0.4 - s * 1.2
            nok.append((x, y, ust_z(E, x, y) + 0.5))
        DG._serit("tereyag%d" % s, nok, 0.5, Mt, yass=0.35)
    # tereyagi birikintileri (erimis, parlak)
    for q in range(4):
        x = XM + (h1(q * 3.7) - 0.5) * Lm * 1.2
        y = YM + (h1(q * 5.3) - 0.5) * Wm * 0.9
        e = I.elipsoid("yag%d" % q, 0, 0, 0.9 + 0.5 * h1(q), 0.3, 0.7, 0, Mt, seg=12, ring=6)
        e.location = (x, y, ust_z(E, x, y) + 0.45)
    # gol: pidelerin altinda, duzensiz kenarli ince tabaka
    bm = bmesh.new()
    vs = []
    for q in range(40):
        a = 2 * math.pi * q / 40
        rr = 1.0 + 0.06 * math.sin(5 * a + 1.3) + 0.04 * math.sin(9 * a)
        vs.append(bm.verts.new((-1.2 + math.cos(a) * 12.6 * rr, math.sin(a) * 9.6 * rr, TABAN + 0.06)))
    bm.faces.new(vs)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    o = I.mesh_ob("sos_gol", bm, M, smooth=False)
    for pol in o.data.polygons:
        if pol.normal.z < 0:
            pol.flip()


def yogurt_kur(Yk):
    """Yan yogurt: kasikla konmus tepe; kenari dalgali, ustunde kivrim."""
    if Yk <= 0:
        return
    My = cel("IskYogurt", ["#b8af96", "#dcd5c2", "#f1ece0", "#ffffff"], S4)
    cx, cy = 11.4, -3.0
    rx, ry, hh = 3.0 + 1.3 * Yk, 2.4 + 1.0 * Yk, 1.9 + 1.0 * Yk
    z0 = TABAN - 0.2
    bm = bmesh.new()
    seg, hal = 28, 9
    halkalar = []
    for i in range(hal):
        f = i / float(hal)
        phi = f * math.pi / 2
        h = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            dal = 1.0 + (0.1 * math.sin(5 * a + Yk) + 0.05 * math.sin(9 * a)) * (1.0 - f)
            rr = math.cos(phi) * dal
            h.append(bm.verts.new((cx + math.cos(a) * rx * rr, cy + math.sin(a) * ry * rr,
                                   z0 + hh * math.sin(phi) ** 0.8 + 0.25 * math.sin(3 * a + f * 4) * f)))
        halkalar.append(h)
    tepe = bm.verts.new((cx + 0.3, cy, z0 + hh + 0.2))
    for a_, b_ in zip(halkalar, halkalar[1:]):
        for j in range(seg):
            bm.faces.new((a_[j], a_[(j + 1) % seg], b_[(j + 1) % seg], b_[j]))
    for j in range(seg):
        bm.faces.new((halkalar[-1][j], halkalar[-1][(j + 1) % seg], tepe))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    I.mesh_ob("yogurt", bm, My)
    # kasik izi: tepede kivrilan serit
    nok = []
    for q in range(19):
        u = q / 18.0
        a = u * math.pi * 2.4
        rr = (1.0 - u) * 0.62
        x, y = cx + math.cos(a) * rx * rr, cy + math.sin(a) * ry * rr
        f = 1.0 - rr
        nok.append((x, y, z0 + hh * math.sin(f * math.pi / 2) ** 0.8 + 0.35))
    DG._serit("yog_kivrim", nok, 0.35 + 0.08 * Yk, My, yass=0.7)


def tabak_kur(hold=None):
    once = set(bpy.data.objects.keys())
    Y.tabak()
    if hold:
        for ob in bpy.data.objects:
            if ob.name not in once and ob.type == "MESH":
                ob.data.materials.clear()
                ob.data.materials.append(hold)


def taban(E, B, Yk):
    def fn():
        Mt = DG.malz()
        tabak_kur()
        pide_kur(B == 1)
        et_kur(E, Mt, sosli=B == 1)
        if B:
            sos_kur(E)
        yogurt_kur(Yk)
        DG.golge_ac()
    return fn


def golge_disk(ad, x, y, rx, ry, z, a=0.32):
    bm = bmesh.new()
    vs = [bm.verts.new((x + math.cos(2 * math.pi * q / 24) * rx, y + math.sin(2 * math.pi * q / 24) * ry, z)) for q in range(24)]
    bm.faces.new(vs)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    I.mesh_ob(ad, bm, px.flat_a("IskGolge", "#3a2210", a), smooth=False)


def biber(P, E):
    """Kozlenmis sivri biber: kivrik, sivri uclu; kararmis kabarciklar
    (gurultulu rampa) + acik yesil sap."""
    def fn():
        hold = DG.holdout_malz()
        tabak_kur(hold)
        pide_kur(False, hold)
        et_kur(E, None, hold)
        Mb = cel("Biber", ["#2a2a0c", "#3a6418", "#5a9a2a", "#94c858"], [0, .28, .5, .8], noise=0.3, noise_scale=3.5)
        Ms = cel("BiberSap", ["#5a6a2a", "#7a9a3a", "#a8c860", "#d0e490"], S4)
        for i in range(P):
            x0, y0 = XM - 8.5 + i * 3.0, YM + 1.0 + i * 4.0
            x1, y1 = XM + 6.0 + i * 3.5, YM - 2.5 + i * 3.2
            nok = []
            n = 7
            for q in range(n):
                u = q / (n - 1.0)
                x = x0 + (x1 - x0) * u
                y = y0 + (y1 - y0) * u + math.sin(u * math.pi) * 1.4
                nok.append((x, y, ust_z(E, x, y) + 1.0 - 0.25 * u))
            cu = bpy.data.curves.new("biber%d" % i, "CURVE")
            cu.dimensions = "3D"
            cu.bevel_depth = 1.25
            cu.bevel_resolution = 4
            cu.use_fill_caps = True
            sp = cu.splines.new("BEZIER")
            sp.bezier_points.add(n - 1)
            for q, p in enumerate(nok):
                bp = sp.bezier_points[q]
                bp.co = p
                bp.handle_left_type = bp.handle_right_type = "AUTO"
                bp.radius = max(0.12, 1.0 - 0.88 * (q / (n - 1.0)) ** 1.6)
            ob = bpy.data.objects.new("biber%d" % i, cu)
            bpy.context.collection.objects.link(ob)
            L.meshle(ob, Mb)
            # sap: kalin ucta kisa kivrik silindir + kaliks halkasi
            sx, sy, sz = nok[0]
            e = I.elipsoid("kaliks%d" % i, 0, 0, 1.15, 1.0, 1.15, 0, Ms, seg=14, ring=8)
            e.location = (sx - 0.9, sy, sz)
            sap = [(sx - 1.4, sy, sz), (sx - 2.6, sy + 0.4, sz + 0.5), (sx - 3.3, sy + 0.2, sz + 1.3)]
            cs = bpy.data.curves.new("sap%d" % i, "CURVE")
            cs.dimensions = "3D"
            cs.bevel_depth = 0.38
            cs.bevel_resolution = 2
            cs.use_fill_caps = True
            sp2 = cs.splines.new("BEZIER")
            sp2.bezier_points.add(len(sap) - 1)
            for q, p in enumerate(sap):
                bp = sp2.bezier_points[q]
                bp.co = p
                bp.handle_left_type = bp.handle_right_type = "AUTO"
            ob2 = bpy.data.objects.new("sap%d" % i, cs)
            bpy.context.collection.objects.link(ob2)
            L.meshle(ob2, Ms)
            for q in range(1, n - 1, 2):
                x, y, z = nok[q]
                golge_disk("bgolge%d_%d" % (i, q), x + 0.8, y - 0.6, 1.9, 1.4, ust_z(E, x, y) + 0.05, 0.22)
        DG.golge_ac()
    return fn


def domates(Tn):
    """Kozlenmis domates: kirisik kirmizi kabuk, kararmis lekeler, yesil kaliks."""
    def fn():
        tabak_kur(DG.holdout_malz())
        Md = cel("KozDomates", ["#3e0806", "#9a1a10", "#d23426", "#f4785a"], [0, .25, .5, .82], noise=0.18, noise_scale=5)
        Mc = cel("Kavruk", ["#140806", "#241008", "#3a1a0e", "#52281a"], S4)
        Mg = cel("DomatesKaliks", ["#1e3a0e", "#2e5a16", "#4a8a24", "#7ab040"], S4)
        yer = [(-13.0, -5.4), (-7.8, -8.4), (-2.4, -9.6)]
        for i in range(Tn):
            x, y = yer[i]
            r = 2.7 - 0.15 * i
            z = tabak_z(x, y)
            golge_disk("dgolge%d" % i, x + 0.6, y - 0.4, r * 1.15, r * 0.95, z + 0.04)
            e = I.elipsoid("domates%d" % i, 0, 0, r * 1.06, r * 0.86, r, 0, Md, seg=24, ring=14)
            e.location = (x, y, z + r * 0.8)
            e.rotation_euler = (0, 0, h1(i * 3.3) * 3.0)
            # kararmis lekeler (ust ve on yuz)
            for c in range(5):
                a = h1(i * 7.1 + c * 2.3) * math.tau
                b = 0.25 + 0.9 * h1(i * 5.9 + c * 1.7)
                px_, py_ = math.cos(a) * math.cos(b), math.sin(a) * math.cos(b)
                le = I.elipsoid("leke%d_%d" % (i, c), 0, 0, 0.75, 0.2, 0.55, 0, Mc, seg=10, ring=6)
                le.location = (x + px_ * r * 1.06, y + py_ * r, z + r * 0.8 + math.sin(b) * r * 0.86)
                le.rotation_euler = (math.atan2(py_, math.sin(b)) * 0.8, -math.atan2(px_, math.sin(b)) * 0.8, a)
            # kaliks: 5 yaprakli yildiz + sap
            tz = z + r * 0.8 + r * 0.86
            for c in range(5):
                a = c * math.tau / 5 + i
                yp = I.elipsoid("yaprak%d_%d" % (i, c), 0, 0, 0.9, 0.18, 0.35, 0, Mg, seg=8, ring=5)
                yp.location = (x + math.cos(a) * 0.8, y + math.sin(a) * 0.8, tz - 0.05)
                yp.rotation_euler = (0, 0.25, a)
            s = I.elipsoid("sap%d" % i, 0, 0, 0.3, 0.55, 0.3, 0, Mg, seg=8, ring=5)
            s.location = (x, y, tz + 0.35)
        DG.golge_ac()
    return fn


PARCALAR = {}
for _e in range(5):
    for _b in (0, 1):
        for _y in range(4):
            PARCALAR["isk_%d_%d_%d" % (_e, _b, _y)] = (taban(_e, _b, _y), "#6e747a", 110)
for _p in (1, 2):
    for _e in range(5):
        PARCALAR["isk_bib_%d_%d" % (_p, _e)] = (biber(_p, _e), "#1a3008", 130)
for _t in (1, 2, 3):
    PARCALAR["isk_dom_%d" % _t] = (domates(_t), "#4a0e0a", 130)


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    gx0, gy0, w, h = TUVAL
    katman, kok, olc = [], {}, {}
    say = 0
    for ad, (fn, cizgi, alfa) in PARCALAR.items():
        for sc in OLCEKLER:
            tam = "%s_%d" % (ad, int(round(sc * 100)))
            katman.append(tam)
            kok[tam] = [gx0, gy0]
            olc[tam] = sc
            if argv and not any(tam.startswith(a) for a in argv):
                continue
            D.sahne(gx0, gy0, w, h, sc)
            fn()
            px.shear_scene(K)
            yol = px.render(os.path.join(OUT, tam + ".png"))
            px.outline(yol, hexcol=cizgi, alpha=alfa)
            say += 1
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": katman, "kokenler": kok, "olcekler": olc}, fp, indent=1)
    print("ISKENDER_HD_DONE %d render" % say)


if __name__ == "__main__":
    main()
