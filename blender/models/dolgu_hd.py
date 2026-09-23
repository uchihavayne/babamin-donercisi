"""ACIK DURUMUN DOLGUSU — tek 3B sahne (birlesik surum, 3. tur).

    blender --background --factory-startup --python blender/models/dolgu_hd.py [-- 180 122 ...]
    python blender/dolgu_birlestir.py          (ham renderlardan atlas parcalari)
    python blender/hd_atlas.py dolgu180_hd dolgu180   (her olcek icin)

Kullanici: "malzemeler durumun icinde karismiyor, hepsi layer olarak ust uste
biniyor". Eskiden et / patates / tursu ayri ayri render edilip sirayla ust
uste yapistiriliyordu (tursu hep en ustte). Simdi et x patates x tursu
seviyelerinin (0..4) HER birlesimi lavasla birlikte TEK sahnede render edilir:
parcalar birbirinin arasina girer, z-tamponu kimin onde oldugunu belirler,
gunes golgesi (Eevee) parcalardan birbirine ve lavasa duser.

Lavas oyunda ayrica (durum atlasi, durum_acik_<olcek>) cizilir. Bu sahnede
lavas bir MASKE malzemesiyle render edilir: aydinlik = macenta, golgede =
camgobegi. dolgu_birlestir.py macenta/camgobegi pikselleri ayiklar; yalniz
dolgu parcalari (opak) + lavasa dusen golge (yari saydam) kalir.

Yogurt ve sos her zaman en son dokulur (gercekte de ustte); etin yigin
seviyesine gore yiginin ustune serilir, et yigini "holdout" olarak sahnede
durur (sirtin arkasinda kalan kisim gorunmez).

Tuval durum_acik ile AYNI: (-24, -11, 48, 22), K = 0.5 -> pikseller birebir.
"""
import sys, os, math, json
import bpy, bmesh
from mathutils import Vector, Matrix

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import durum_hd as D

HAM = os.path.join(_HERE, "out", "dolgu_ham")
K = 0.5
TUVAL = (-24, -11, 48, 22)
OLCEKLER = {180: 1.8, 122: 1.22, 90: 0.9, 100: 1.0}
S4 = [0, .3, .5, .8]
cel = I.cel

LAV_Z = 1.1      # lavasin ust yuzu (durum_hd.durum_acik)
YC = -2.4        # yiginin derinlik merkezi (lavasin ortasi, ekranda)
W = 5.6          # yiginin derinlik yari genisligi


def h1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


# ---------------------------------------------------------------- yigin bicimi
def et_L(m):
    return 7.5 + 2.4 * m


def et_H(m):
    return 0.0 if m <= 0 else 1.0 + 0.7 * m


def h_et(m, x, y):
    """Et yigininin (m seviyesi) (x, y) noktasindaki kubbe yuksekligi."""
    if m <= 0:
        return 0.0
    u = x / et_L(m)
    v = (y - YC) / W
    q = 1.0 - u * u - 0.85 * v * v
    return et_H(m) * max(0.0, q) ** 0.65


# ---------------------------------------------------------------- malzemeler
def malz():
    return {
        "et": cel("Et", ["#6a3410", "#9a5420", "#c47a34", "#e8aa5c"], [0, .25, .5, .8], noise=0.16, noise_scale=5),
        "et2": cel("Et2", ["#5a2a0c", "#84441a", "#a8642a", "#d08c44"], [0, .25, .5, .8], noise=0.2, noise_scale=7),
        "et_kenar": cel("EtKenar", ["#3a1c08", "#5a2c0c", "#7a3e12", "#9a561e"], S4),
        "pat": {t: cel("Pat" + t, r, S4) for t, r in (
            ("acik", ["#8a6218", "#b88a28", "#ecce6c", "#fbeab0"]),
            ("orta", ["#6a4810", "#9a7020", "#d8aa42", "#f0d271"]),
            ("koyu", ["#4a320a", "#7a5414", "#b8801f", "#d9a03a"]))},
        "t_kabuk": cel("TursuKabuk", ["#1a2808", "#2e4212", "#44601c", "#5a7a28"], S4),
        "t_ic": cel("TursuIc", ["#6e7c28", "#8e9c3c", "#aab458", "#c4cc78"], S4),
        "t_cek": px.flat("TursuCek", "#dcdca4"),
    }


def mask_malz():
    """Lavas icin maske: aydinlik macenta, golgede camgobegi (sabit rampa)."""
    mat = bpy.data.materials.new("LavasMaske")
    mat.use_nodes = True
    n, l = mat.node_tree.nodes, mat.node_tree.links
    n.clear()
    dif = n.new("ShaderNodeBsdfDiffuse")
    s2r = n.new("ShaderNodeShaderToRGB")
    bw = n.new("ShaderNodeRGBToBW")
    ramp = n.new("ShaderNodeValToRGB")
    cr = ramp.color_ramp
    cr.interpolation = "CONSTANT"
    cr.elements[0].position = 0.0
    cr.elements[0].color = (0, 1, 1, 1)
    cr.elements[1].position = 0.035
    cr.elements[1].color = (1, 0, 1, 1)
    em = n.new("ShaderNodeEmission")
    out = n.new("ShaderNodeOutputMaterial")
    l.new(dif.outputs[0], s2r.inputs[0])
    l.new(s2r.outputs[0], bw.inputs[0])
    l.new(bw.outputs[0], ramp.inputs["Fac"])
    l.new(ramp.outputs["Color"], em.inputs["Color"])
    l.new(em.outputs[0], out.inputs["Surface"])
    return mat


def holdout_malz():
    mat = bpy.data.materials.new("Holdout")
    mat.use_nodes = True
    n, l = mat.node_tree.nodes, mat.node_tree.links
    n.clear()
    h = n.new("ShaderNodeHoldout")
    out = n.new("ShaderNodeOutputMaterial")
    l.new(h.outputs[0], out.inputs["Surface"])
    return mat


# ---------------------------------------------------------------- parcalar
def talas(ad, x, y, z, boy, en, kal, rot, kivrim, tohum, M, Mk):
    """Doner et talasi: ince, kivrik, kenari duzensiz yaprak; yan yuzleri
    (kizarmis kenar) koyu malzeme."""
    bm = bmesh.new()
    nu, nv = 7, 5
    g = []
    for i in range(nu):
        u = i / (nu - 1.0) * 2 - 1
        sira = []
        for j in range(nv):
            v = j / (nv - 1.0) * 2 - 1
            kenar = i in (0, nu - 1) or j in (0, nv - 1)
            s = 1.0 - (0.12 * h1(tohum * 3.1 + i * 7.7 + j * 1.3) if kenar else 0.0)
            gx = u * boy / 2.0 * s * (1.0 - 0.08 * abs(v))
            gy = v * en / 2.0 * s * (1.0 - 0.18 * u * u)
            gz = kivrim * u * u + 0.22 * math.sin(u * 3.0 + tohum) * math.cos(v * 1.7 + tohum)
            sira.append(bm.verts.new((gx, gy, gz)))
        g.append(sira)
    for i in range(nu - 1):
        for j in range(nv - 1):
            bm.faces.new((g[i][j], g[i + 1][j], g[i + 1][j + 1], g[i][j + 1]))
    bmesh.ops.solidify(bm, geom=bm.faces[:], thickness=kal)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = I.mesh_ob(ad, bm, M, smooth=True)
    ob.data.materials.append(Mk)
    for pol in ob.data.polygons:
        if abs(pol.normal.z) < 0.45:
            pol.material_index = 1
    ob.rotation_euler = rot
    ob.location = (x, y, z)
    return ob


def cubuk(ad, x, y, z, boy, kal, yaw, pitch, M):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x *= boy
        v.co.y *= kal
        v.co.z *= kal
    bmesh.ops.bevel(bm, geom=bm.edges[:], offset=kal * 0.22, segments=2, profile=0.5, affect="EDGES")
    ob = I.mesh_ob(ad, bm, M, smooth=True)
    ob.rotation_euler = (0.0, pitch, yaw)
    ob.location = (x, y, z)
    return ob


def tursu_dilim(ad, x, y, z, r, kal, rot, tohum, Mk, Mi, Mc):
    """Ince tursu dilimi: koyu yesil kabuk halkasi + acik ic + cekirdek halkasi."""
    bm = bmesh.new()
    seg = 20
    alt, ust, ic = [], [], []
    for q in range(seg):
        a = 2 * math.pi * q / seg
        rr = r * (1.0 + 0.07 * math.sin(3 * a + tohum))
        cx, cy = math.cos(a) * rr, math.sin(a) * rr * 0.88
        alt.append(bm.verts.new((cx, cy, 0.0)))
        ust.append(bm.verts.new((cx, cy, kal)))
        ic.append(bm.verts.new((cx * 0.8, cy * 0.8, kal + 0.02)))
    yuz = []
    for q in range(seg):
        k = (q + 1) % seg
        yuz.append((bm.faces.new((alt[q], alt[k], ust[k], ust[q])), 0))
        yuz.append((bm.faces.new((ust[q], ust[k], ic[k], ic[q])), 0))
    yuz.append((bm.faces.new(list(reversed(alt))), 0))
    yuz.append((bm.faces.new(ic), 1))
    for c in range(6):
        a = c * math.pi / 3 + tohum
        sx, sy = math.cos(a) * r * 0.42, math.sin(a) * r * 0.37
        pts = [bm.verts.new((sx + 0.2 * math.cos(b * math.pi / 2) * (1.4 if b % 2 == 0 else 1.0),
                             sy + 0.2 * math.sin(b * math.pi / 2), kal + 0.05)) for b in range(4)]
        yuz.append((bm.faces.new(pts), 2))
    for f, mi in yuz:
        f.material_index = mi
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = I.mesh_ob(ad, bm, Mk, smooth=False)
    ob.data.materials.append(Mi)
    ob.data.materials.append(Mc)
    ob.rotation_euler = rot
    ob.location = (x, y, z)
    return ob


# ---------------------------------------------------------------- yerlesim
def et_kur(m, Mt, holdout=None):
    if m <= 0:
        return
    n = {1: 12, 2: 19, 3: 27, 4: 36}[m]
    Lm = et_L(m)
    Mk = holdout or Mt["et_kenar"]
    for i in range(n):
        # kademeli dagilim: once orta, sonra kenarlar (seviye artinca yigin uzar)
        u = ((i * 0.618034) % 1.0) * 2 - 1
        x = u * Lm * 0.92
        y = YC + (h1(i * 5.3) - 0.5) * 2 * W * 0.8
        h = h_et(m, x, y)
        t = math.sqrt(h1(i * 2.9))
        z = LAV_Z + 0.45 + h * (0.2 + 0.8 * t)
        egim = math.radians(18 + 34 * h1(i * 7.1)) * min(1.0, 0.4 + 0.6 * h)
        rot = (egim, math.radians((h1(i * 4.4) - 0.5) * 40), math.radians((h1(i * 6.6) - 0.5) * 70))
        talas("et%d" % i, x, y, z, 4.6 + 1.6 * h1(i * 1.7), 3.4 + 1.2 * h1(i * 3.9), 0.5,
              rot, 0.5 + 0.7 * h1(i * 8.8), i * 1.37, holdout or (Mt["et2"] if h1(i * 2.3) > 0.62 else Mt["et"]), Mk)


def patates_kur(p, m, Mt):
    if p <= 0:
        return
    n = {1: 4, 2: 6, 3: 8, 4: 10}[p]
    Lp = 6.0 + 2.2 * p
    for i in range(n):
        u = ((i * 0.618034 + 0.31) % 1.0) * 2 - 1
        x = u * Lp * 0.9
        y = YC + (h1(i * 9.1 + 2) - 0.5) * 2 * W * 0.75
        h = h_et(m, x, y)
        r = 0.2 + 0.9 * h1(i * 3.3 + 1)
        z = LAV_Z + 0.5 + h * (0.55 + 0.6 * r)
        tk = h1(i * 5.3 + 1.3)
        ton = "acik" if tk > 0.66 else ("koyu" if tk < 0.3 else "orta")
        yaw = math.radians((h1(i * 4.1 + 1) - 0.5) * 80)
        pitch = math.radians((h1(i * 6.2) - 0.5) * (30 if h > 0.5 else 6))
        cubuk("pat%d" % i, x, y, z, 5.0 + 3.0 * h1(i * 2.7 + 1), 1.1, yaw, pitch, Mt["pat"][ton])


def tursu_kur(t, m, Mt):
    if t <= 0:
        return
    n = {1: 2, 2: 3, 3: 4, 4: 5}[t]
    Lt = 5.0 + 2.2 * t
    for i in range(n):
        u = ((i * 0.618034 + 0.12) % 1.0) * 2 - 1
        x = u * Lt * 0.9
        y = YC - W * 0.15 + (h1(i * 4.7 + 5) - 0.5) * 2 * W * 0.55
        h = h_et(m, x, y)
        z = LAV_Z + 0.3 + h * (0.85 + 0.35 * h1(i * 2.2 + 3))
        egim = math.radians(28 + 26 * h1(i * 3.7 + 2)) * min(1.0, 0.6 + h * 0.5)
        rot = (egim, math.radians((h1(i * 5.5) - 0.5) * 50), math.radians(h1(i * 1.9) * 180))
        tursu_dilim("tursu%d" % i, x, y, z, 1.7 + 0.25 * h1(i * 6.1), 0.36, rot, i * 2.1,
                    Mt["t_kabuk"], Mt["t_ic"], Mt["t_cek"])


def _serit(ad, noktalar, r, mat, yass=0.6):
    cu = bpy.data.curves.new(ad, "CURVE")
    cu.dimensions = "3D"
    cu.bevel_depth = r
    cu.bevel_resolution = 3
    cu.use_fill_caps = True
    sp = cu.splines.new("BEZIER")
    sp.bezier_points.add(len(noktalar) - 1)
    for q, (x, y, z) in enumerate(noktalar):
        bp = sp.bezier_points[q]
        bp.co = (x, y, z)
        bp.handle_left_type = bp.handle_right_type = "AUTO"
        bp.radius = 1.0
    ob = bpy.data.objects.new(ad, cu)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    me = L.meshle(ob, mat)
    # dokulen sos yassidir: her kosesi en yakin yol noktasinin yuksekligine
    # dogru bastirilir (tup -> yassi serit)
    for v in me.data.vertices:
        en = min(noktalar, key=lambda p: (p[0] - v.co.x) ** 2 + (p[1] - v.co.y) ** 2)
        v.co.z = en[2] + (v.co.z - en[2]) * yass
    me.data.update()
    return me


def yogurt_kur(k, m, Mt):
    """Yiginin ustune zikzakla dokulmus, parlak, koyu kivamli yogurt."""
    My = cel("Yogurt", ["#bdb49c", "#dcd5c2", "#f1ece0", "#ffffff"], S4)
    Lk = 3.5 + 3.0 * k
    tur = 1 if k < 3 else 2
    for s in range(tur):
        nok = []
        n = 14 + 4 * k
        for q in range(n + 1):
            u = q / float(n)
            x = -Lk + u * 2 * Lk + (s * 1.3)
            y = YC - 0.8 + math.sin(u * (5.0 + k) * math.pi / 2 + s * 1.7) * (1.6 + 0.3 * k) - s * 0.6
            z = LAV_Z + h_et(m, x, y) + (1.15 if m > 0 else 0.35) + 0.15 * math.sin(u * 17 + s)
            nok.append((x, y, z))
        _serit("yog%d" % s, nok, 0.52 + 0.06 * k, My)
    # birkac kasik birikintisi
    for q in range({1: 1, 2: 2, 3: 2, 4: 3}[k]):
        x = (h1(q * 3.3 + k) - 0.5) * 2 * Lk * 0.7
        y = YC - 1.2 + (h1(q * 5.1) - 0.5) * 2.0
        z = LAV_Z + h_et(m, x, y) + (1.0 if m > 0 else 0.25)
        e = I.elipsoid("yog_top%d" % q, x, 0, 1.1 + 0.2 * k, 0.55, 1.0, 0, My, seg=16, ring=8)
        e.location = (x, y, z)


def sos_kur(tur, m, Mt):
    sicak = tur == "hot"
    ramp = ["#6e140e", "#b3241a", "#d8362a", "#f25a42"] if sicak else ["#b8b19c", "#e6dfc8", "#f4f0e2", "#fdfaf0"]
    M = cel("Sos" + tur, ramp, S4)
    nok = []
    n = 40
    for q in range(n + 1):
        u = q / float(n)
        x = -14 + u * 28
        y = YC - 0.4 + math.sin(u * 11.0 + 0.6) * (2.2 + 0.6 * math.sin(u * 4.0))
        z = LAV_Z + h_et(m, x, y) + (1.35 if m > 0 else 0.3)
        nok.append((x, y, z))
    _serit("sos", nok, 0.3, M)


# ---------------------------------------------------------------- render
def sahne(sc):
    gx0, gy0, w, h = TUVAL
    D.sahne(gx0, gy0, w, h, sc)


def golge_ac():
    s = bpy.context.scene
    try:
        s.eevee.use_shadows = True
    except Exception:
        pass
    for ob in s.objects:
        if ob.type == "LIGHT":
            ob.data.use_shadow = True
            try:
                ob.data.angle = 0.0
            except Exception:
                pass


def lavas_maske():
    once = set(bpy.data.objects.keys())
    D.durum_acik()
    Mm = mask_malz()
    for ob in bpy.data.objects:
        if ob.name not in once and ob.type == "MESH":
            ob.data.materials.clear()
            ob.data.materials.append(Mm)


def render(yol):
    px.shear_scene(K)
    golge_ac()
    os.makedirs(os.path.dirname(yol), exist_ok=True)
    return px.render(yol)


def dolgu(o, e, p, t):
    sahne(OLCEKLER[o])
    Mt = malz()
    lavas_maske()
    et_kur(e, Mt)
    patates_kur(p, e, Mt)
    tursu_kur(t, e, Mt)
    return render(os.path.join(HAM, str(o), "d_%d_%d_%d.png" % (e, p, t)))


def ust(o, ad, fn, m):
    sahne(OLCEKLER[o])
    Mt = malz()
    et_kur(m, Mt, holdout=holdout_malz())
    fn(Mt)
    return render(os.path.join(HAM, str(o), "%s_%d.png" % (ad, m)))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    olcek = [int(a) for a in argv if a.isdigit()] or list(OLCEKLER)
    tek = [a for a in argv if not a.isdigit()]
    say = 0
    for o in olcek:
        if tek:
            for a in tek:
                if a.startswith("d_"):
                    e, p, t = (int(v) for v in a[2:].split("_"))
                    dolgu(o, e, p, t)
                elif a.startswith("y_"):
                    k, m = (int(v) for v in a[2:].split("_"))
                    ust(o, "y_%d" % k, lambda Mt, k=k, m=m: yogurt_kur(k, m, Mt), m)
                elif a.startswith("s_"):
                    tur, m = a[2:].split("_")
                    ust(o, "s_%s" % tur, lambda Mt, tur=tur, m=int(m): sos_kur(tur, m, Mt), int(m))
                say += 1
            continue
        for e in range(5):
            for p in range(5):
                for t in range(5):
                    dolgu(o, e, p, t)
                    say += 1
        for m in range(5):
            for k in (1, 2, 3, 4):
                ust(o, "y_%d" % k, lambda Mt, k=k, m=m: yogurt_kur(k, m, Mt), m)
                say += 1
            for tur in ("hot", "garlic"):
                ust(o, "s_%s" % tur, lambda Mt, tur=tur, m=m: sos_kur(tur, m, Mt), m)
                say += 1
    print("DOLGU_HD_DONE %d render" % say)


if __name__ == "__main__":
    main()
