"""DURUM (acik lavas, sarili durum, kagit) — remake HD, olcek varyantli.

    blender --background --factory-startup --python blender/models/durum_hd.py [-- parca ...]
    python blender/hd_atlas.py durum_hd durum

Oyundaki karsiliklari (food.js):
  drawWrapOpen   : lavas tabani (elipsler + benekler + on kivrim)  -> durum_acik_<olcek>
                   capa (cx, cy)
  drawWrapRolled : govde (rrect + uclar + spiral + izgara izleri + kizarma benekleri +
                   uctaki et) kizarma kademesine gore            -> durum_<kademe>_<olcek>
                   kademe: k0 k20 k40 k60 k80 k100 (kizarma 0..1), yanik (burnt)
                   kagit onu / arkasi                            -> durum_kagit_<olcek>,
                                                                    durum_kagit_arka_<olcek>
                   capa (cx, cy); kagit oyunda paperT ile asagi kayar (po), saydamlasir
Olcek: oyun durumu ctx.scale icinde ciziyor (servis tahtasi 1/.74/.58, izgara
.8/.62/.58). Parca her olcekte AYRI render ediliyor (en yakin komsu kucultme
bozuk piksel verir); ad soneki 100 80 74 62 58.
Dolgu (et, patates, tursu, yogurt, sos), sarma animasyonundaki tup, ustteki
isaret pikselleri, duman ve sos rozeti kodda.
"""
import sys, os, math, json
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T

OUT = os.path.join(_HERE, "out", "durum_hd")
HD = 2
cel = I.cel
ez, onkutu, on_poligon, hexmul = T.ez, T.onkutu, T.on_poligon, T.hexmul
PARCALAR = {}
KOKEN = {}
OLCEK = {}


def hash1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


def mix(a, b, t):
    a, b = a.lstrip("#"), b.lstrip("#")
    ca = [int(a[i:i + 2], 16) for i in (0, 2, 4)]
    cb = [int(b[i:i + 2], 16) for i in (0, 2, 4)]
    return "#%02x%02x%02x" % tuple(int(round(x + (y - x) * t)) for x, y in zip(ca, cb))


def sahne(gx0, gy0, w, h, sc):
    L._FONTLAR.clear()
    px.reset()
    px.setup(int(round(w * HD * sc)), int(round(h * HD * sc)))
    px.ortho_cam(gx0 + w / 2.0, -(gy0 + h / 2.0), w, h)
    px.world("#000000", 0.0)
    d = Vector((0.40, 0.60, -0.70)).normalized()
    s = px.sun(math.pi, rot=(0, 0, 0))
    s.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def parca(ad, tuval, fn, K, olcekler, cizgi=None, cizgi_alfa=150):
    for sc in olcekler:
        tam = "%s_%d" % (ad, int(round(sc * 100)))
        PARCALAR[tam] = (tuval, fn, K, cizgi, cizgi_alfa, sc)
        KOKEN[tam] = (tuval[0], tuval[1])
        OLCEK[tam] = sc


# ---------------------------------------------------------------- acik lavas
LAV_RX, LAV_RY_EKRAN = 21.7, 8.7      # ust yuzun yaricaplari (ekran)
LAV_UST = 1.1                          # ust yuzun ortalama yuksekligi (z)


def lavas_r(a):
    """Duzensiz yufka kenari: acinin fonksiyonu olarak goreli yaricap."""
    return (1.0 + 0.032 * math.sin(3 * a + 0.7) + 0.022 * math.sin(5 * a + 2.1)
            + 0.013 * math.sin(11 * a + 0.3) + 0.008 * math.sin(17 * a + 1.3))


def lavas_z(x, y):
    """Ust yuzey yuksekligi: genis, yumusak dalgalar (yufka duz durmaz)."""
    return (LAV_UST + 0.16 * math.sin(x * 0.21 + 0.4) * math.cos(y * 0.15 + 0.3)
            + 0.09 * math.sin((x + 1.7 * y) * 0.33 + 1.1))


def durum_acik():
    """Acik lavas. 3. tur, kullanici: "lavastan cok pizza hamuruna benziyor".
    Pizza izlenimini veren uc sey kaldirildi: kabarik kenar halkasi, kusursuz
    elips, yuzeyi capraz ikiye bolen kubbe golgesi. Simdi: ince (0.6 px),
    kenari duzensiz yufka; yuzeyde genis yumusak dalgalar; kucuk kizarmis
    benekler, birkac soluk kizarma lekesi ve un tozu."""
    K = 0.5
    RY = LAV_RY_EKRAN / K
    Mt = cel("LavasUst", ["#e4c797", "#ebd1a4", "#f0d9b0", "#f5e1bd"], [0, .22, .5, .86], noise=0.06, noise_scale=9)
    Ma = px.flat("LavasAlt", "#c89e6a")
    bm = bmesh.new()
    halka_n, seg = 12, 96
    merkez = bm.verts.new((0.0, 0.0, lavas_z(0, 0)))
    halkalar = []
    for i_ in range(1, halka_n + 1):
        t = i_ / float(halka_n)
        h = []
        for j_ in range(seg):
            a = 2 * math.pi * j_ / seg
            rr = t * lavas_r(a)
            x, y = math.cos(a) * LAV_RX * rr, math.sin(a) * RY * rr
            h.append(bm.verts.new((x, y, lavas_z(x, y) + 0.12 * t ** 6)))
        halkalar.append(h)
    for j_ in range(seg):
        bm.faces.new((merkez, halkalar[0][j_], halkalar[0][(j_ + 1) % seg]))
    for a_, b_ in zip(halkalar, halkalar[1:]):
        for j_ in range(seg):
            bm.faces.new((a_[j_], b_[j_], b_[(j_ + 1) % seg], a_[(j_ + 1) % seg]))
    # alt yuz + kenar (ince)
    dis = halkalar[-1]
    alt = [bm.verts.new((v.co.x * 1.004, v.co.y * 1.004, 0.55)) for v in dis]
    for j_ in range(seg):
        bm.faces.new((dis[j_], alt[j_], alt[(j_ + 1) % seg], dis[(j_ + 1) % seg]))
    bm.faces.new(list(reversed(alt)))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = I.mesh_ob("lavas", bm, Mt)
    ob.data.materials.append(Ma)
    for pol in ob.data.polygons:
        if pol.normal.z < 0.3:
            pol.material_index = 1

    def leke(ad, x, y, rx, ry, mat, faz):
        """Yuzeye yapisik duzensiz leke (dunya koordinati, ust yuzeyin 0.04 ustu)."""
        bm2 = bmesh.new()
        n = 9
        vs = []
        for q in range(n):
            a = 2 * math.pi * q / n
            rr = 1.0 + 0.25 * math.sin(3 * a + faz) + 0.15 * math.sin(5 * a + faz * 2)
            px_, py_ = x + math.cos(a) * rx * rr, y + math.sin(a) * ry * rr
            vs.append(bm2.verts.new((px_, py_, lavas_z(px_, py_) + 0.04)))
        bm2.faces.new(vs)
        bmesh.ops.recalc_face_normals(bm2, faces=bm2.faces[:])
        o = I.mesh_ob(ad, bm2, mat, smooth=False)
        for pol in o.data.polygons:
            if pol.normal.z < 0:
                pol.flip()
        return o

    # soluk kizarma bolgeleri (genis, yari saydam)
    for i_ in range(5):
        a = hash1(i_ * 9.1) * math.tau
        r0 = 0.25 + 0.5 * hash1(i_ * 4.3)
        leke("kizarma%d" % i_, math.cos(a) * LAV_RX * r0, math.sin(a) * RY * r0, 3.0 + 2.0 * hash1(i_ * 2.2),
             2.4 + 1.6 * hash1(i_ * 6.6), px.flat_a("Kizarma", "#d6a466", 0.2), i_ * 1.7)
    # kizarmis benekler: kucuk, kume kume; iki ton
    for i_ in range(24):
        a = hash1(i_ * 3.1) * math.tau
        r0 = hash1(i_ * 7.3) ** 0.6 * 0.86
        x, y = math.cos(a) * LAV_RX * r0, math.sin(a) * RY * r0
        koyu = hash1(i_ * 1.3) > 0.72
        rr = 0.3 + hash1(i_ * 1.7) * (0.4 if koyu else 0.7)
        renk = "#c8955e" if koyu else "#dcb27e"
        leke("benek%d" % i_, x, y, rr * 1.2, rr * 1.6, px.flat("Benek%s" % renk, renk), i_)
    # un tozu / kabarcik parlakligi
    for i_ in range(14):
        a = hash1(i_ * 5.9 + 1) * math.tau
        r0 = hash1(i_ * 2.7 + 3) ** 0.7 * 0.8
        x, y = math.cos(a) * LAV_RX * r0, math.sin(a) * RY * r0
        leke("un%d" % i_, x, y, 0.5 + 0.4 * hash1(i_), 0.7 + 0.5 * hash1(i_ * 3), px.flat("Un", "#faefd8"), i_ * 0.7)


# ---------------------------------------------------------------- sarili durum
KADEME = [("k0", 0.0), ("k20", 0.2), ("k40", 0.4), ("k60", 0.6), ("k80", 0.8), ("k100", 1.0), ("yanik", None)]


KX = 0.42      # sarili durum: yana egik izdusum (sag uc gorunur)


def x_egim(kx=KX):
    """x += y * kx: kamera hafif sagdan bakar; tupun sag (acik) ucu gorunur.
    shear_scene (z += y*K) ile birlikte uygulanir (ikisi de yalniz y'ye bagli)."""
    bpy.context.view_layer.update()
    for ob in bpy.context.scene.objects:
        if ob.type != "MESH":
            continue
        mw = ob.matrix_world
        inv = mw.inverted()
        for v in ob.data.vertices:
            w = mw @ v.co
            w.x += w.y * kx
            v.co = inv @ w
        ob.data.update()


R_DURUM = 6.3
X_UC = 18.6        # acik sag ucun x'i


def _dolgu_ucu(k):
    """Acik uctan gorunen / tasan dolgu: et lopcalari, iki patates, tursu, sos.
    Tupun ekseni (y=0, z=0) boyunca, ic yaricap ~4.4 icinde."""
    Me = cel("UcEt", ["#5a2c0c", "#8c4c1c", "#b86c2c", "#e0a050"], [0, .28, .52, .82], noise=0.2, noise_scale=6)
    Me2 = cel("UcEt2", ["#4a240a", "#7a4014", "#a45c20", "#cf8a3a"], [0, .28, .52, .82], noise=0.2, noise_scale=7)
    for q in range(14):
        a = hash1(q * 3.3) * math.tau
        rr = 3.9 * math.sqrt(hash1(q * 7.7))
        y, z = math.cos(a) * rr, math.sin(a) * rr
        x = X_UC - 1.2 + hash1(q * 5.1) * 2.6
        e = I.elipsoid("et%d" % q, x, 0, 1.5 + 0.7 * hash1(q), 1.0 + 0.4 * hash1(q * 2), 1.3, 0, Me if q % 3 else Me2,
                       seg=10, ring=7)
        e.location = (x, y, z)
        e.rotation_euler = (hash1(q * 1.1) * 3.0, hash1(q * 2.3) * 3.0, hash1(q * 3.7) * 3.0)
    Mp = cel("UcPat", ["#8a6218", "#b88a28", "#ecce6c", "#fbeab0"], [0, .3, .5, .8])
    for q, (y, z, uz, aci) in enumerate(((-1.6, 1.2, 6.0, 0.18), (1.4, -1.6, 5.2, -0.22))):
        bm = bmesh.new()
        bmesh.ops.create_cube(bm, size=1.0)
        for v in bm.verts:
            v.co.x *= uz
            v.co.y *= 1.1
            v.co.z *= 1.1
        bmesh.ops.bevel(bm, geom=bm.edges[:], offset=0.22, segments=2, profile=0.5, affect="EDGES")
        ob = I.mesh_ob("pat%d" % q, bm, Mp)
        ob.location = (X_UC - uz / 2 + 2.3, y, z)
        ob.rotation_euler = (0.0, aci, aci * 0.6)
    Mt = cel("UcTursu", ["#2e4212", "#44601c", "#6e9128", "#a8c656"], [0, .3, .5, .8])
    t = I.elipsoid("tursu", X_UC + 0.4, 0, 0.35, 1.3, 1.25, 0, Mt, seg=14, ring=8)
    t.location = (X_UC + 0.5, 0.6, 2.2)
    t.rotation_euler = (0.3, 0.2, 0.0)
    # beyaz sos: uctan hafif tasan birikinti + damla
    Ms = cel("UcSos", ["#c4bca6", "#e2dccb", "#f3efe4", "#ffffff"], [0, .3, .5, .8])
    b = I.elipsoid("sos", 0, 0, 1.0, 0.9, 1.6, 0, Ms, seg=12, ring=8)
    b.location = (X_UC + 0.7, -0.4, -2.9)
    d = I.elipsoid("damla", 0, 0, 0.6, 0.9, 0.6, 0, Ms, seg=10, ring=6)
    d.location = (X_UC + 1.0, -1.2, -4.0)


def durum_govde(kiz):
    """Sarili durum. 3. tur, kullanici: "ucu kapali olmasin, oradan eti vs.
    gorelim". Eskiden kapsul (iki ucu kapali) + ucta sahte oval. Simdi: sol uc
    kivrilip kapanmis, sag uc ACIK: disi kalin kat, icte sarmal lavas kati,
    ortasinda uctan tasan dolgu. Kamera hafif sagdan (x_egim) -> uc gorunur."""
    def fn():
        K = 0.25
        if kiz is None:
            base, shade, lite = "#3f3129", "#241c17", "#544234"
            k = 1.0
        else:
            k = kiz
            base = mix("#f0d5a8", "#d9a765", k)
            shade = mix("#c9a06a", "#a87a41", k)
            lite = mix("#f8e6c4", "#f0c68e", k)
        Mg = cel("Durum", [hexmul(shade, .85), shade, base, lite], [0, .3, .5, .82], noise=0.08, noise_scale=10)
        ic_renk = mix("#f0d5a8", "#e2b882", k * 0.5) if kiz is not None else "#5a4a3c"
        Mi = cel("DurumIc", [hexmul(ic_renk, .8), hexmul(ic_renk, .9), ic_renk, hexmul(ic_renk, 1.04)], [0, .3, .5, .82])
        R = R_DURUM
        T_ = 0.7
        bm = bmesh.new()
        seg = 32
        # sol uc yuvarlak kapali, govde duz, sag uc acik (dis yuzey)
        xs = [-20.0 + 5.0 * (1 - math.cos(math.pi / 2 * i / 6)) for i in range(7)]
        xs += [-15.0 + (X_UC + 15.0) * i / 8 for i in range(1, 9)]
        dis = []
        for x in xs:
            u = max(0.0, -x - 15.0) / 5.0
            r = R * math.sqrt(max(0.0, 1 - u * u))
            # uca yakin hafif genisleme (lavas agzi acilir)
            r *= 1.0 + 0.05 * max(0.0, (x - (X_UC - 3.0)) / 3.0)
            dis.append([bm.verts.new((x, -r * math.cos(2 * math.pi * j / seg), r * math.sin(2 * math.pi * j / seg))) for j in range(seg)])
        for a_, b_ in zip(dis, dis[1:]):
            for j in range(seg):
                bm.faces.new((a_[j], a_[(j + 1) % seg], b_[(j + 1) % seg], b_[j]))
        # agiz kenari (kalinlik) + ic yuzey (kisa)
        r_uc = R * 1.05
        ic_on = [bm.verts.new((X_UC, -(r_uc - T_) * math.cos(2 * math.pi * j / seg), (r_uc - T_) * math.sin(2 * math.pi * j / seg))) for j in range(seg)]
        ic_arka = [bm.verts.new((X_UC - 5.0, -(R - T_) * math.cos(2 * math.pi * j / seg), (R - T_) * math.sin(2 * math.pi * j / seg))) for j in range(seg)]
        son = dis[-1]
        kenar_yuz, ic_yuz = [], []
        for j in range(seg):
            kenar_yuz.append(bm.faces.new((son[j], son[(j + 1) % seg], ic_on[(j + 1) % seg], ic_on[j])))
            ic_yuz.append(bm.faces.new((ic_on[j], ic_on[(j + 1) % seg], ic_arka[(j + 1) % seg], ic_arka[j])))
        ic_yuz.append(bm.faces.new(list(reversed(ic_arka))))
        for f in ic_yuz + kenar_yuz:
            f.material_index = 1
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        ob = I.mesh_ob("govde", bm, Mg)
        ob.data.materials.append(Mi)
        # sarmal ic kat: uctan gorunen spiral (dis kattan ice dogru bir tur)
        bm2 = bmesh.new()
        n = 40
        on_, arka_ = [], []
        for q in range(n + 1):
            a = 0.6 + q / float(n) * math.tau * 1.05
            rr = r_uc - T_ - 0.25 - (q / float(n)) * 1.5
            yy, zz = -rr * math.cos(a), rr * math.sin(a)
            on_.append(bm2.verts.new((X_UC - 0.25, yy, zz)))
            arka_.append(bm2.verts.new((X_UC - 4.0, yy, zz)))
        for q in range(n):
            bm2.faces.new((on_[q], on_[q + 1], arka_[q + 1], arka_[q]))
        bmesh.ops.solidify(bm2, geom=bm2.faces[:], thickness=0.45)
        bmesh.ops.recalc_face_normals(bm2, faces=bm2.faces[:])
        I.mesh_ob("sarmal", bm2, Mi)
        _dolgu_ucu(k)
        yon = -R - 0.4
        # spiral cizgiler (sarma izi)
        for si in range(4):
            x0 = -12 + si * 7.5
            on_poligon("spiral", [(x0 - 0.4, -5), (x0 + 0.4, -5), (x0 + 2.4, 5), (x0 + 1.6, 5)], yon - 0.1,
                       px.flat_a("Spiral%s" % shade, shade, 0.22), K, derin=0.02)
        # izgara izleri
        if kiz is not None and kiz > 0.18:
            guc = min(1.0, max(0.0, (kiz - 0.18) / 0.82))
            for gi in range(5):
                izk = min(1.0, max(0.0, (guc - gi * 0.11) / 0.45))
                if izk <= 0:
                    continue
                x0 = -14 + gi * 6.5
                on_poligon("iz", [(x0 - 0.55, -4), (x0 + 0.55, -4), (x0 + 3.55, 4), (x0 + 2.45, 4)], yon - 0.15 - gi * 0.01,
                           px.flat_a("Iz%d%.2f" % (gi, izk), "#8a5a2a", 0.55 * izk), K, derin=0.02)
            if kiz > 0.62:
                a = 0.4 * min(1.0, max(0.0, (kiz - 0.62) / 0.38))
                for kb in range(6):
                    bx = math.floor(-15 + hash1(kb * 3.7) * 28 + 0.5)
                    by = math.floor(-4 + hash1(kb * 8.3) * 8 + 0.5)
                    onkutu("benek", bx, bx + 1, by, by + 1, yon - 0.3, yon - 0.2, px.flat_a("KBenek%.2f" % a, "#6b3f18", a), K)
        if kiz is None:
            for kb in range(9):
                bx = -16 + hash1(kb * 5.3) * 30
                by = -4 + hash1(kb * 2.9) * 8
                onkutu("is", bx, bx + 1.5, by, by + 1, yon - 0.3, yon - 0.2, px.flat("Is", "#1a1411"), K)
        x_egim()
    return fn


def durum_kagit():
    """Kagit: tupun sol yarisini saran kavisli yaprak, sag kenari egik."""
    K = 0.25
    R = 6.9
    pl, pw, ph = -21.0, 21.0, 13
    Mk = cel("Kagit", ["#cfc8b4", "#e2ddcc", "#f2eee0", "#fdfaf0"], [0, .3, .5, .85])
    bm = bmesh.new()
    satirlar = 16
    kol = 10
    grid = []
    for r in range(satirlar + 1):
        tt = r / satirlar                      # 0 ust -> 1 alt
        a = math.pi / 2 - tt * math.pi         # +90 (ust) .. -90 (alt)
        yy, zz = -math.cos(a) * R, math.sin(a) * R
        uc = 0.0
        if tt < 0.08 or tt > 0.92:
            uc = 2.2
        elif tt < 0.16 or tt > 0.84:
            uc = 0.8
        x0 = pl + uc
        x1 = pl + pw - 5 + tt * 6
        grid.append([bm.verts.new((x0 + (x1 - x0) * c / kol, yy, zz)) for c in range(kol + 1)])
    for r in range(satirlar):
        for c in range(kol):
            bm.faces.new((grid[r][c], grid[r][c + 1], grid[r + 1][c + 1], grid[r + 1][c]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = I.mesh_ob("kagit", bm, Mk)
    for f in ob.data.polygons:
        if f.normal.y > 0:
            f.flip()
    yon = -R - 0.3

    def satir_y(row):
        return -ph / 2.0 + row

    # kivrim cizgileri
    for fi in range(3):
        a = 0.28 + fi * 0.07
        on_poligon("kivrim", [(pl + 2 + fi * 2 - 0.3, satir_y(2)), (pl + 2 + fi * 2 + 0.3, satir_y(2)),
                              (pl + 4 + fi * 2 + 0.3, satir_y(ph - 3)), (pl + 4 + fi * 2 - 0.3, satir_y(ph - 3))],
                   yon, px.flat_a("Kivrim%d" % fi, "#d2ccb8", a), K, derin=0.02)
    # kirmizi ve mavi bant
    b1 = round(ph * 0.32)
    b2 = round(ph * 0.62)
    on_poligon("bant1", [(pl + 4, satir_y(b1)), (pl + pw - 6, satir_y(b1)), (pl + pw - 6, satir_y(b1 + 2)), (pl + 4, satir_y(b1 + 2))],
               yon - 0.05, cel("Kirmizi", ["#8e1f18", "#b02a22", "#d8352c", "#e8584e"], [0, .3, .5, .85]), K, derin=0.05)
    on_poligon("bant2", [(pl + 4, satir_y(b2)), (pl + pw - 5, satir_y(b2)), (pl + pw - 5, satir_y(b2 + 2)), (pl + 4, satir_y(b2 + 2))],
               yon - 0.05, cel("Mavi", ["#1e3d66", "#26477a", "#2f5f9e", "#4a7cc0"], [0, .3, .5, .85]), K, derin=0.05)
    onkutu("bant1_uc", pl + 3, pl + 4, satir_y(b1 + 1), satir_y(b1 + 2), yon - 0.1, yon, px.flat("B1Uc", "#b02a22"), K)
    onkutu("bant2_uc", pl + 3, pl + 4, satir_y(b2 + 1), satir_y(b2 + 2), yon - 0.1, yon, px.flat("B2Uc", "#26477a"), K)
    for di in range(4):
        x = pl + 5 + di * 4
        renk = "#2f5f9e" if di % 2 else "#d8352c"
        pts = [(x + 0.5 + 0.5 * math.cos(2 * math.pi * j / 8), satir_y(2) + 0.5 + 0.5 * math.sin(2 * math.pi * j / 8)) for j in range(8)]
        on_poligon("nokta", pts, yon - 0.06, px.flat("Nokta%s" % renk, renk), K, derin=0.05)
    # egik sag kenar: parlak hat + golge
    kenar_ic, kenar_dis = [], []
    for row in range(ph):
        tt = row / (ph - 1.0)
        xr = pl + pw - 5 + math.floor(tt * 6 + 0.5)
        kenar_ic.append((xr - 0.8, satir_y(row) + 0.5))
        kenar_dis.append((xr - 0.1, satir_y(row) + 0.5))
    on_poligon("kenar_isik", kenar_ic + list(reversed(kenar_dis)), yon - 0.04, px.flat("KenarIsik", "#f8f5ea"), K, derin=0.02)
    for row in range(2, ph - 2):
        tt = row / (ph - 1.0)
        xr = pl + pw - 5 + math.floor(tt * 6 + 0.5)
        onkutu("golge", xr - 2.2, xr - 1.4, satir_y(row), satir_y(row) + 1, yon - 0.03, yon - 0.02, px.flat_a("KGolge", "#8a8474", 0.35), K)
    x_egim()


def durum_kagit_arka():
    K = 0.25
    pl, pw, h = -21.0, 21.0, 13.0
    L.levha("arka", pw + 3, h + 2, 4.5, pl - 1 + (pw + 3) / 2.0, 0.0, 4.0, 0.5, 0.0, px.flat("KagitArkaAlt", "#cfc9b8"))
    L.levha("arka_ust", pw + 3, h + 1, 4.5, pl - 1 + (pw + 3) / 2.0, 0.5, 3.6, 0.3, 0.0, px.flat("KagitArkaUst", "#e8e4d6"))
    x_egim()


# BIRLESIK: yeni tahtada 1 / 2 / 3 urun -> 1.8 / 1.22 / 0.9 olcek (counter_design)
ACIK_OLCEK = (1.0, 0.74, 0.58, 1.8, 1.22, 0.9)
SARILI_OLCEK = (1.0, 0.8, 0.74, 0.62, 0.58, 1.8, 1.22, 0.9)
parca("durum_acik", (-24, -11, 48, 22), durum_acik, 0.5, ACIK_OLCEK, cizgi="#8a6a3a", cizgi_alfa=110)
for _ad, _k in KADEME:
    parca("durum_" + _ad, (-26, -10, 52, 20), durum_govde(_k), 0.25, SARILI_OLCEK, cizgi="#5a3a18", cizgi_alfa=120)
parca("durum_kagit", (-26, -10, 30, 20), durum_kagit, 0.25, SARILI_OLCEK)
parca("durum_kagit_arka", (-27, -10, 32, 20), durum_kagit_arka, 0.25, SARILI_OLCEK)


def uret(ad):
    (gx0, gy0, w, h), fn, K, cizgi, cizgi_alfa, sc = PARCALAR[ad]
    sahne(gx0, gy0, w, h, sc)
    fn()
    px.shear_scene(K)
    yol = px.render(os.path.join(OUT, ad + ".png"))
    if cizgi:
        px.outline(yol, hexcol=cizgi, alpha=cizgi_alfa)
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = [a for a in PARCALAR if not argv or any(a.startswith(x) for x in argv)]
    for ad in adlar:
        uret(ad)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR),
                   "kokenler": {k: list(v) for k, v in KOKEN.items()},
                   "olcekler": OLCEK}, fp, indent=1)
    print("DURUM_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
