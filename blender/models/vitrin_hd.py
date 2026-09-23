"""VITRIN, KEPENK VE DUVAR SUSLERI — remake HD.

    blender --background --factory-startup --python blender/models/vitrin_hd.py [-- ad ...]
    python blender/hd_atlas.py vitrin_hd vitrin

art.js bakeWinOver (vitrin cercevesi, kayitlar, tas esik, cam parlamasi),
drawShutter (kepenk), drawTabela (isikli tabela), boya yukseltmesinin duvar
lambasi ve drawPoster (1 kilim, 2 DONER TAZE afisi, 3 BABA portresi).

  pencere            capa LAY.win (x, y)            cerceve + 2 kayit + tas esik
  esik_golge         capa LAY.win (x, y)            (yari saydam, numpy)
  cam_isik           capa LAY.glass (x, y)          parlama seritleri + ton + ic golge
  kepenk_sac         capa LAY.glass (x, y)          264x89 lamel sac; oyun ALTTAN kirpar
                                                    (kepenk inerken lameller asagi kayar)
  kepenk_alt         capa (glass.x, glass.y + hgt - 4)
  kepenk_golge       capa (glass.x, glass.y + hgt)
  kepenk_rulo_<rh>   rh 3..9, capa (glass.x, glass.y - rh + 1)
  tabela_sol         capa (sx, sy)
  tabela_orta        capa karonun sol kenari (16 px, yatayda tekrar)
  tabela_sag         capa (sx + sw, sy)
  ampul_acik/kapali  capa ampul merkezi; ampul_isik parilti
  lamba, lamba_isik  capa (0, 0) (duvardaki mutlak konum)
  afis_1/2/3         capa drawPoster (x, y)
"""
import sys, os, math, json, random
import bpy, bmesh
import numpy as np
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D

OUT = os.path.join(_HERE, "out", "vitrin_hd")
HD = 2
K = 0.5
cel = I.cel
ez, onkutu, on_poligon, torna, hexmul = T.ez, T.onkutu, T.on_poligon, T.torna, T.hexmul
PARCALAR, KOKEN = {}, {}


def parca(ad, tuval, fn, cizgi=None, cizgi_alfa=150, tur="3b"):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa, tur)
    KOKEN[ad] = (tuval[0], tuval[1])


def levha(ad, x0, gy0, w, h, r, y, derin, mat, bevel=0.0, kalin=None):
    """On yuzu y'de, ekranda (x0, gy0, w, h) duran yuvarlak koseli levha;
    kalin verilirse ortasi bos cerceve."""
    yc = y + derin / 2.0
    dis = L.yuvarlak_dikdortgen(w, h, r)
    sp = [dis]
    if kalin:
        sp.append(list(reversed(L.yuvarlak_dikdortgen(w - 2 * kalin, h - 2 * kalin, max(0.3, r - kalin * 0.6)))))
    ob = L._egri(ad, sp, x0 + w / 2.0, ez(gy0 + h / 2.0, yc, K), yc, derin, bevel)
    return L.meshle(ob, mat)


def kutu_bevel(ad, x0, x1, gy0, gy1, y0, y1, mat, bevel=0.4, seg=2):
    """On yuzu y0'da ekranda [gy0, gy1] duran pahli kutu."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    z0, z1 = ez(gy1, y0, K), ez(gy0, y0, K)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    bmesh.ops.bevel(bm, geom=bm.edges[:], offset=bevel, segments=seg, affect="EDGES")
    return I.mesh_ob(ad, bm, mat, smooth=True)


def doku_malzeme(ad, arr, tonlar=(0.70, 0.86, 1.0, 1.10), stops=(0.0, 0.32, 0.55, 0.86)):
    """Numpy RGBA dokusu x sabit basamakli lambert (cel) -> emission."""
    h, w = arr.shape[:2]
    img = bpy.data.images.new(ad, width=w, height=h, alpha=True)
    img.colorspace_settings.name = "sRGB"
    img.pixels.foreach_set((arr[::-1].astype(np.float32) / 255.0).ravel())
    img.update()
    img.pack()
    m = bpy.data.materials.new(ad)
    m.use_nodes = True
    n, l = m.node_tree.nodes, m.node_tree.links
    n.clear()
    tex = n.new("ShaderNodeTexImage")
    tex.image = img
    tex.interpolation = "Linear"
    dif = n.new("ShaderNodeBsdfDiffuse")
    s2r = n.new("ShaderNodeShaderToRGB")
    l.new(dif.outputs[0], s2r.inputs[0])
    bw = n.new("ShaderNodeRGBToBW")
    l.new(s2r.outputs[0], bw.inputs[0])
    ramp = n.new("ShaderNodeValToRGB")
    cr = ramp.color_ramp
    cr.interpolation = "CONSTANT"
    while len(cr.elements) > 1:
        cr.elements.remove(cr.elements[-1])
    cr.elements[0].position = 0.0
    cr.elements[0].color = (tonlar[0],) * 3 + (1.0,)
    for t, s in zip(tonlar[1:], stops[1:]):
        e = cr.elements.new(s)
        e.color = (t, t, t, 1.0)
    l.new(bw.outputs[0], ramp.inputs["Fac"])
    mul = n.new("ShaderNodeVectorMath")
    mul.operation = "MULTIPLY"
    l.new(tex.outputs["Color"], mul.inputs[0])
    l.new(ramp.outputs["Color"], mul.inputs[1])
    em = n.new("ShaderNodeEmission")
    l.new(mul.outputs[0], em.inputs["Color"])
    out = n.new("ShaderNodeOutputMaterial")
    l.new(em.outputs[0], out.inputs["Surface"])
    return m


def izgara(ad, x0, gy0, w, h, nx, ny, derinlik, mat):
    """UV'li on yuz izgarasi; derinlik(u, v) -> y (kumas dalgasi, kagit kivrimi)."""
    bm = bmesh.new()
    uv = bm.loops.layers.uv.new("UVMap")
    V = []
    for j in range(ny + 1):
        sat = []
        for i in range(nx + 1):
            u, v = i / nx, j / ny
            y = derinlik(u, v)
            sat.append(bm.verts.new((x0 + u * w, y, ez(gy0 + v * h, y, K))))
        V.append(sat)
    for j in range(ny):
        for i in range(nx):
            f = bm.faces.new((V[j + 1][i], V[j + 1][i + 1], V[j][i + 1], V[j][i]))
            for lp, (a, b) in zip(f.loops, ((i, j + 1), (i + 1, j + 1), (i + 1, j), (i, j))):
                lp[uv].uv = (a / nx, 1.0 - b / ny)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        if f.normal.y > 0:
            f.normal_flip()
    return I.mesh_ob(ad, bm, mat, smooth=True)


def rgba(hexcol, a=255):
    h = hexcol.lstrip("#")
    return [int(h[i:i + 2], 16) for i in (0, 2, 4)] + [a]


def bos(w, h, olcek=HD):
    return np.zeros((h * olcek, w * olcek, 4), np.float32)


def ustune(dst, renk, alfa):
    """Duz alfa 'over': dst (h,w,4 float 0..1), renk hex, alfa (h,w) 0..1."""
    c = np.array(rgba(renk)[:3], np.float32) / 255.0
    a = np.clip(alfa, 0, 1)[..., None]
    da = dst[..., 3:4]
    oa = a + da * (1 - a)
    rgb = (c * a + dst[..., :3] * da * (1 - a)) / np.maximum(oa, 1e-6)
    dst[..., :3] = rgb
    dst[..., 3:4] = oa
    return dst


def u8(arr):
    return (np.clip(arr, 0, 1) * 255.0 + 0.5).astype(np.uint8)


# ================================================================ vitrin
WIN_W, WIN_H = 272, 100
GL_X, GL_Y, GL_W, GL_H = 4, 4, 264, 92      # cam, win'e gore


def pencere():
    Mal = cel("Aluminyum", ["#1d2126", "#2b3037", "#3b424a", "#4c545d", "#79838d", "#a3adb6"],
              [0, .18, .34, .5, .78, .93])
    # dis cerceve: pahli profil, ortasi bos
    levha("cerceve", 0, 0, WIN_W, WIN_H, 2.0, -1.2, 2.6, Mal, bevel=0.55, kalin=4.6)
    # cam cita (cerceve icinde, geride, koyu)
    Mc = cel("Cita", ["#15181c", "#23282e", "#333940", "#4c545d"], [0, .3, .55, .85])
    levha("cita", GL_X - 0.4, GL_Y - 0.4, GL_W + 0.8, GL_H + 0.8, 0.8, 0.9, 0.8, Mc, kalin=1.3)
    # iki kayit (art.js: mx = ix + round(iw/3), ix + round(2iw/3); mx-2 .. mx+3)
    for mx in (GL_X + 88, GL_X + 176):
        levha("kayit", mx - 2.1, GL_Y - 0.5, 5.2, GL_H + 1.0, 1.0, -0.5, 2.0, Mal, bevel=0.6)
        # kayit uclarinda vida
        for gy in (GL_Y + 5, GL_Y + GL_H - 5):
            e = I.elipsoid("vida", mx + 0.5, gy, 0.7, 0.7, 0.3, -1.6, cel("Vida", ["#2b3037", "#79838d", "#c3ccd4"], [0, .5, .85]), seg=10, ring=6)
            e.location = (mx + 0.5, -1.6, ez(gy, -1.6, K))
    # tas esik: ust yuzu 2 px, on yuzu 98..105
    Mt = cel("Esik", ["#6f685c", "#8d8577", "#b3ab98", "#c9c2b0", "#e8e2d0"],
             [0, .2, .42, .6, .86], noise=0.07, noise_scale=22)
    kutu_bevel("esik", -6, 278, 99.0, 105.0, -3.0, -0.2, Mt, bevel=0.5)


def cam_isik():
    """Cam uzerine: art.js'in %8 beyaz capraz seritleri (26/62/152 px, 26/11/18
    genis), ust %45'te mavi ton, ust/sol kenarda ic golge. Yumusak kenarli."""
    H, W = GL_H * HD, GL_W * HD
    a = bos(GL_W, GL_H)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32) + 0.5
    ton = np.clip(1.0 - yy / (H * 0.62), 0, 1) ** 1.3 * 0.085
    ustune(a, "#cfe6f2", ton)
    for x0, gen, guc in ((26, 26, .085), (62, 11, .075), (152, 18, .08)):
        d = xx - yy - x0 * HD                          # serit icinde 0..gen*HD
        g = gen * HD
        kenar = np.clip(np.minimum(d, g - d) / 5.0, 0, 1)
        on = np.clip(1.0 - np.abs(d - 2.0) / 2.0, 0, 1) * 0.07   # on kenarda ince parlak cizgi
        ust = np.clip(1.0 - yy / H * 0.55, 0, 1)                  # asagi dogru soner
        ustune(a, "#ffffff", (kenar * guc + on) * ust)
    golge = np.maximum(np.clip(1.0 - yy / 9.0, 0, 1) ** 1.6, np.clip(1.0 - xx / 9.0, 0, 1) ** 1.6) * 0.42
    ustune(a, "#000000", golge)
    return u8(a)


def esik_golge():
    a = bos(284, 4)
    yy = np.mgrid[0:4 * HD, 0:284 * HD][0].astype(np.float32) + 0.5
    ustune(a, "#000000", np.clip(1.0 - yy / (3.2 * HD), 0, 1) ** 1.4 * 0.38)
    return u8(a)


# ================================================================ kepenk
SAC_H = 89


def kepenk_sac():
    """Oluklu celik lamel: her 3 px'te bir kubbeli serit + oluk."""
    Ms = cel("Sac", ["#3f464e", "#565e66", "#6d757e", "#98a1aa", "#b9c1c9"],
             [0, .28, .5, .8, .95], noise=0.035, noise_scale=70)
    prof = [(0.0, 0.05), (0.35, -0.10), (0.9, -0.62), (1.6, -0.72), (2.25, -0.55), (2.8, -0.12), (3.0, 0.05)]
    bm = bmesh.new()
    sira = []
    for k in range(-1, SAC_H // 3 + 2):
        for t, d in prof[:-1]:
            sira.append((k * 3 + t, d))
    satirlar = []
    for gy, d in sira:
        satirlar.append([bm.verts.new((x, d, ez(gy, d, K))) for x in (-2.0, 266.0)])
    for a, b in zip(satirlar, satirlar[1:]):
        bm.faces.new((a[0], a[1], b[1], b[0]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        if f.normal.y > 0:
            f.normal_flip()
    I.mesh_ob("sac", bm, Ms, smooth=True)


def kepenk_sac_son(yol):
    """Render sonrasi: lamel kilit derzleri (11 px'te bir), kir lekeleri,
    alt kisimda koyulasan is."""
    a = px.read_png(yol).astype(np.float32) / 255.0
    H, W = a.shape[:2]
    r = random.Random(7)
    for vx in range(4, 264, 11):
        c = vx * HD
        a[:, c, :3] *= 0.80
        if c + 1 < W:
            a[:, c + 1, :3] = np.minimum(1, a[:, c + 1, :3] * 1.07)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    kir = np.zeros((H, W), np.float32)
    for i in range(26):
        cx, cy = r.uniform(0, W), r.uniform(0, H)
        rx, ry = r.uniform(6, 20), r.uniform(2, 5)
        kir += np.exp(-(((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2)) * r.uniform(.06, .14)
    for i in range(9):                                  # pas akintisi (lamel olugundan asagi)
        cx, cy = r.uniform(8, W - 8), r.uniform(0, H * 0.7)
        L_ = r.uniform(10, 34)
        kir += np.exp(-(((xx - cx) / 1.2) ** 2)) * np.clip(1 - (yy - cy) / L_, 0, 1) * (yy > cy) * 0.12
    kir += (yy / H) ** 3 * 0.10
    kir = np.clip(kir, 0, 0.35)[..., None]
    pas = np.array(rgba("#3a2a22")[:3], np.float32) / 255.0
    a[..., :3] = a[..., :3] * (1 - kir) + pas * kir
    px.write_png(u8(a), yol)


def kepenk_alt():
    Mb = cel("KolAlt", ["#262b31", "#353b42", "#5b636c", "#7e8791", "#a8b1ba"], [0, .25, .48, .74, .92])
    kutu_bevel("kol", -0.5, 264.5, 0.0, 4.0, -1.4, 0.6, Mb, bevel=0.6)
    Mk = cel("Tutamak", ["#15181c", "#262b31", "#4a5159", "#6f777f"], [0, .3, .58, .86])
    # tutamak: iki ayak + yuvarlak cubuk
    for dx in (125.5, 137.5):
        kutu_bevel("ayak", dx, dx + 1.4, 1.0, 3.6, -2.4, -1.2, Mk, bevel=0.25)
    cu = L.silindir("cubuk", 0.75, 132.0, -2.9, 0.0, 13.0, Mk, seg=12, eksen="X")
    cu.location = (132.0, -2.9, ez(2.3, -2.9, K))
    # kilit gobegi
    L.silindir("kilit", 0.9, 132.0, -1.6, ez(2.0, -1.6, K), 0.6, cel("Kilit", ["#6b5a2a", "#b3923e", "#e8c46a"], [0, .5, .85]), seg=14, eksen="Y")


def kepenk_golge():
    a = bos(264, 3)
    yy = np.mgrid[0:3 * HD, 0:264 * HD][0].astype(np.float32) + 0.5
    ustune(a, "#000000", np.clip(1.0 - yy / (3.0 * HD), 0, 1) ** 1.2 * 0.36)
    return u8(a)


def kepenk_rulo(rh):
    def fn():
        Mr = cel("Rulo%d" % rh, ["#2f353c", "#3f464e", "#4d555d", "#6d757e", "#9aa3ac"], [0, .22, .45, .7, .9])
        kutu_bevel("kutu", -2, 266, 0.0, rh, -2.0, 1.0, Mr, bevel=min(0.7, rh * 0.18))
        Mo = px.flat("Oluk%d" % rh, "#4d555d")
        for rr in range(1, rh - 1, 2):
            onkutu("oluk", -1.5, 265.5, rr + 0.25, rr + 0.75, -2.08, -2.0, Mo, K)
        Mu = cel("RuloUc%d" % rh, ["#23282e", "#353b42", "#5b636c", "#8a939c"], [0, .3, .6, .88])
        for x0 in (-3.0, 264.0):
            kutu_bevel("uc", x0, x0 + 3.0, -0.4, rh + 0.4, -2.4, 1.0, Mu, bevel=min(0.6, rh * 0.15))
    return fn


# ================================================================ tabela
TAB_W = 120


def tabela():
    Mf = cel("TabelaCerceve", ["#1e140c", "#2b1f14", "#3a2a1e", "#5a4230", "#7a5a40"], [0, .22, .42, .72, .9])
    levha("cerceve", -2, -2, TAB_W + 4, 30, 3.0, -0.6, 2.0, Mf, bevel=0.5)
    Mk = cel("TabelaKenar", ["#7d1610", "#96271c", "#c0281c", "#d83a2c"], [0, .3, .55, .85])
    levha("kenar", 0, 0, TAB_W, 26, 2.0, -1.2, 1.0, Mk, bevel=0.35)
    Mp = cel("TabelaYuz", ["#c0281c", "#d6392b", "#e2483a", "#ef6454"], [0, .3, .55, .82])
    levha("yuz", 2, 2, TAB_W - 4, 22, 1.6, -1.9, 0.6, Mp, bevel=0.25)
    # ust kenarda parlak serit (isikli kutu cami)
    on_poligon("parlak", [(3.0, 2.6), (TAB_W - 3.0, 2.6), (TAB_W - 3.0, 3.3), (3.0, 3.3)], -2.35,
               px.flat_a("TabelaParlak", "#ffffff", 0.28), K, derin=0.02)
    on_poligon("alt_golge", [(3.0, 21.9), (TAB_W - 3.0, 21.9), (TAB_W - 3.0, 23.3), (3.0, 23.3)], -2.35,
               px.flat_a("TabelaAltG", "#5a0e08", 0.30), K, derin=0.02)
    # ampul duylari: art.js ampulleri sx+8+i*14'e koyuyor; genislige gore degistigi
    # icin duylar kodda ampulle birlikte ciziliyor (ampul_* parcasi)


def ampul(acik):
    def fn():
        Md = cel("Duy%d" % acik, ["#2b1f14", "#5a4a32", "#8a7a5a"], [0, .5, .85])
        L.silindir("duy", 1.3, 0.0, -1.2, ez(-1.4, -1.2, K), 1.0, Md, seg=12, eksen="Y")
        if acik:
            Mb = cel("AmpulA", ["#ffd34e", "#fff2a8", "#fffbe0", "#ffffff"], [0, .3, .62, .9])
        else:
            Mb = cel("AmpulK", ["#5e5232", "#8a7a4a", "#a8986a", "#c9bb8a"], [0, .35, .65, .9])
        e = I.elipsoid("ampul", 0.0, 0.0, 1.9, 1.9, 1.6, -2.4, Mb, seg=14, ring=8)
        e.location = (0.0, -2.4, ez(0.0, -2.4, K))
    return fn


def ampul_isik():
    a = bos(10, 10)
    yy, xx = np.mgrid[0:10 * HD, 0:10 * HD].astype(np.float32) + 0.5
    d = np.hypot(xx - 5 * HD, yy - 5 * HD) / (4.6 * HD)
    ustune(a, "#ffd34e", np.clip(1 - d, 0, 1) ** 1.5 * 0.55)
    return u8(a)


# ================================================================ lamba
def lamba():
    Mr = cel("LambaCubuk", ["#1e140c", "#3a2a1e", "#5a4230"], [0, .5, .85])
    L.silindir("cubuk", 0.55, 120.5, -0.8, ez(7.5, -0.8, K), 15.0, Mr, seg=10, eksen="Z")
    Mg = cel("Pirinc", ["#8a6424", "#b58a38", "#c9a04a", "#e8c46a", "#fff0b8"], [0, .22, .45, .72, .92], noise=0.03, noise_scale=40)
    torna("abajur", [(1.6, 7.0), (2.2, 6.2), (4.2, 4.2), (7.2, 1.4), (8.6, 0.0)], 120.5, 21.0, -2.0, 0.35, Mg, K, seg=32, kapak=False)
    torna("tepe", [(1.4, 0.0), (1.4, 1.2), (0.6, 1.8)], 120.5, 14.4, -2.0, 0.6, Mg, K, seg=16)
    e = I.elipsoid("ampul", 120.5, 22.0, 2.0, 1.7, 1.2, -2.6, px.flat("LambaAmpul", "#fffdf0"), seg=12, ring=8)
    e.location = (120.5, -2.6, ez(22.0, -2.6, K))


def lamba_isik():
    """art.js: 26 satir, satir r'de 117-r .. 124+r arasi %13 sari. Yumusak koni,
    asagi dogru soner, ustte abajur agzinda sicak hale."""
    W, H = 64, 32
    a = bos(W, H)
    yy, xx = np.mgrid[0:H * HD, 0:W * HD].astype(np.float32) + 0.5
    X = xx / HD - 32.0 + 120.0          # mantik x
    Y = yy / HD + 20.0                  # mantik y
    r = Y - 21.0
    sol, sag = 117.0 - r, 124.0 + r
    ic = np.clip(np.minimum(X - sol, sag - X) / 3.0, 0, 1) * (r >= -0.5)
    boy = np.clip(1.0 - r / 27.0, 0, 1) ** 1.2
    ustune(a, "#ffe9a0", ic * boy * 0.32)
    hale = np.clip(1.0 - np.hypot((X - 120.5) / 11.0, (Y - 21.0) / 4.0), 0, 1) ** 1.5 * 0.35
    ustune(a, "#fff6c0", hale)
    return u8(a)


# ================================================================ afisler
def kilim_doku():
    """42x30 kilim deseni, mantik pikseli basina 6 doku pikseli."""
    S = 6
    W, H = 42 * S, 30 * S
    a = np.zeros((H, W, 4), np.float32)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32) + 0.5
    X, Y = xx / S, yy / S

    def boya(maske, renk):
        c = np.array(rgba(renk)[:3], np.float32) / 255.0
        a[maske, :3] = c
        a[maske, 3] = 1.0

    boya(np.ones((H, W), bool), "#6b1a14")
    boya((X > 1) & (X < 41) & (Y > 1) & (Y < 29), "#a8321f")
    kus = (X > 2) & (X < 40) & (Y > 2) & (Y < 28) & ~((X > 3) & (X < 39) & (Y > 3) & (Y < 27))
    boya(kus, "#1f4f6a")
    # ust/alt zigzag seritler (altin)
    for y0, yon in ((4.4, 1), (25.6, -1)):
        zz = y0 + yon * (np.abs(((X - 5) % 4) - 2) - 1) * 0.8
        boya((np.abs(Y - zz) < 0.45) & (X > 4.5) & (X < 37.5), "#e2a83a")
    boya((X > 5) & (X < 37) & (Y > 6) & (Y < 24), "#8e2418")
    mcx, mcy = 21.0, 15.0
    boya(np.abs(X - mcx) / 9.5 + np.abs(Y - mcy) / 5.5 < 1, "#1f4f6a")
    boya(np.abs(X - mcx) / 6.5 + np.abs(Y - mcy) / 3.6 < 1, "#e2a83a")
    boya(np.abs(X - mcx) / 3.2 + np.abs(Y - mcy) / 1.8 < 1, "#8e2418")
    boya(np.abs(X - mcx) / 1.1 + np.abs(Y - mcy) / 0.7 < 1, "#e2a83a")
    for sx in (mcx - 14, mcx + 14):
        boya(np.abs(X - sx) / 3.0 + np.abs(Y - mcy) / 2.6 < 1, "#e2a83a")
        boya(np.abs(X - sx) / 1.2 + np.abs(Y - mcy) / 1.0 < 1, "#8e2418")
    # dokuma: yatay atki cizgileri + hafif kirlilik
    atki = 1.0 - 0.07 * (np.sin(yy * math.pi / 3.0) > 0.6)
    r = np.random.default_rng(5)
    kir = 1.0 - 0.05 * r.random((H, W)).astype(np.float32)
    a[..., :3] *= (atki * kir)[..., None]
    return u8(a)


def afis_1():
    Mk = doku_malzeme("Kilim", kilim_doku())
    izgara("kilim", 0, 0, 42, 30, 42, 15,
           lambda u, v: -0.5 - 0.35 * math.sin(u * math.pi * 3.0 + 0.6) * (0.4 + v) - 0.25 * math.sin(v * math.pi), Mk)
    Mp = cel("Puskul", ["#a89a7c", "#cfc3a6", "#e8dcc0", "#f6eedb"], [0, .3, .6, .88])
    r = random.Random(4)
    for x in [1.0 + i * 2.0 for i in range(20)] + [2.0 + i * 2.0 for i in range(20)]:
        for gy0, gy1 in ((-2.6, 0.2), (29.8, 32.4)):
            aci = r.uniform(-8, 8)
            boy = gy1 - gy0 + r.uniform(-0.4, 0.3)
            c = L.silindir("puskul", 0.36, x, -0.6, ez((gy0 + gy1) / 2.0, -0.6, K), boy, Mp, seg=6, eksen="Z")
            c.rotation_euler = (0, math.radians(aci), 0)


def afis2_doku():
    """36x32 kagit: krem, kenarlari sararmis, ortada doner resmi (4 px/mantik px)."""
    S = 4
    W, H = 36 * S, 32 * S
    a = np.zeros((H, W, 4), np.float32)
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32) + 0.5
    X, Y = xx / S, yy / S
    kagit = np.array(rgba("#f2e2b8")[:3], np.float32) / 255.0
    a[..., :3] = kagit
    a[..., 3] = 1.0
    kenar = np.minimum(np.minimum(X, 36 - X), np.minimum(Y, 32 - Y))
    sarar = np.clip(1.0 - kenar / 3.0, 0, 1) ** 2 * 0.16
    rng = np.random.default_rng(3)
    lek = rng.random((H // 8 + 1, W // 8 + 1)).astype(np.float32)
    lek = np.kron(lek, np.ones((8, 8), np.float32))[:H, :W]
    a[..., :3] *= (1.0 - sarar - lek * 0.035)[..., None]
    # doner (kagit koordinati: merkez x 18; sis y 10..23, koni y 11..22)
    cx = 18.0
    t = (Y - 11.0) / 11.0
    yari = 2.0 + np.sin(np.clip(t, 0, 1) * math.pi) * 4.0
    koni = (t >= 0) & (t <= 1) & (np.abs(X - cx) < yari)
    bant = np.floor((Y - 11.0) / 1.0)
    renk = np.where((bant % 4) == 0, 1, 0)
    c_a = np.array(rgba("#c98436")[:3], np.float32) / 255.0
    c_b = np.array(rgba("#a8621f")[:3], np.float32) / 255.0
    c_d = np.array(rgba("#e2483a")[:3], np.float32) / 255.0
    col = np.where(renk[..., None] == 1, c_b, c_a)
    col = np.where((t < 2.0 / 11.0)[..., None], c_d, col)
    golge = 1.12 - 0.42 * np.clip((X - cx) / np.maximum(yari, 0.1) * 0.5 + 0.5, 0, 1)
    col = col * golge[..., None]
    a[koni, :3] = np.clip(col[koni], 0, 1)
    kontur = (t >= -0.05) & (t <= 1.05) & (np.abs(np.abs(X - cx) - yari) < 0.32)
    a[kontur, :3] = np.array(rgba("#5a3a1e")[:3], np.float32) / 255.0
    sis = (np.abs(X - cx) < 0.4) & (Y > 9.0) & (Y < 24.5) & ~koni
    a[sis, :3] = np.array(rgba("#8a939b")[:3], np.float32) / 255.0
    return u8(a)


def afis_2():
    Mc = cel("AfisCerceve", ["#15100c", "#2b2018", "#4a3a2a", "#6a563f"], [0, .3, .62, .9])
    levha("cerceve", 0, 0, 40, 36, 2.0, -0.6, 1.6, Mc, bevel=0.45, kalin=2.2)
    Md = doku_malzeme("AfisKagit", afis2_doku(), tonlar=(0.82, 0.92, 1.0, 1.04))
    izgara("kagit", 2, 2, 36, 32, 18, 16,
           lambda u, v: 0.4 - 0.25 * math.sin(u * math.pi) * math.sin(v * math.pi) - 0.9 * max(0.0, u + v - 1.55) ** 2, Md)
    # DONER / TAZE yazilari oyunun piksel fontuyla kodda (HD fontta okunmuyordu)


def afis3_foto():
    S = 4
    W, H = 26 * S, 22 * S
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32) + 0.5
    d = np.hypot((xx / S - 13.0) / 16.0, (yy / S - 9.0) / 14.0)
    a = np.zeros((H, W, 4), np.float32)
    ic = np.array(rgba("#a9c3cf")[:3], np.float32) / 255.0
    dis = np.array(rgba("#6f8e9e")[:3], np.float32) / 255.0
    k = np.clip(d, 0, 1)[..., None]
    a[..., :3] = ic * (1 - k) + dis * k
    a[..., 3] = 1.0
    return u8(a)


def afis_3():
    Mc = cel("PortreCerceve", ["#3e2810", "#5a3a1a", "#6d4a22", "#8e6634", "#b08850"], [0, .2, .42, .7, .9], noise=0.05, noise_scale=30)
    levha("cerceve", 4, 0, 32, 34, 1.6, -2.6, 2.2, Mc, bevel=0.5, kalin=2.2)
    # paspartu fotografin ONUNDE (alt bosluga yazi): tasan omuzlari da keser
    Mm = cel("Paspartu", ["#b08850", "#c9a06a", "#dcb880"], [0, .45, .85])
    for x0, x1, g0, g1 in ((6.2, 33.8, 1.8, 3.0), (6.2, 7.0, 3.0, 25.0), (33.0, 33.8, 3.0, 25.0), (6.2, 33.8, 25.0, 32.2)):
        onkutu("paspartu", x0, x1, g0, g1, -2.0, 1.2, Mm, K)
    Mf = doku_malzeme("Foto", afis3_foto(), tonlar=(0.9, 0.97, 1.0, 1.02))
    izgara("foto", 7, 3, 26, 22, 4, 4, lambda u, v: 0.5, Mf)
    # bust: omuzlar (kirmizi gomlek), yaka, bas, fes, beyaz biyik, gozler
    fx, fy = 20.0, 13.4
    Mg = cel("PGomlek", ["#6d1a12", "#96271c", "#c33c2c", "#e05a48"], [0, .3, .55, .85])
    e = I.elipsoid("omuz", fx, 24.0, 9.2, 4.6, 1.2, 0.0, Mg, seg=20, ring=10)
    e.location = (fx, 0.0, ez(24.0, 0.0, K))
    Mt = cel("PTen", ["#b9794a", "#d99a68", "#f0bd8a", "#ffd9b0"], [0, .3, .56, .86])
    e = I.elipsoid("boyun", fx, 19.0, 2.2, 2.2, 1.0, -0.1, Mt, seg=12, ring=8)
    e.location = (fx, -0.1, ez(19.0, -0.1, K))
    e = I.elipsoid("bas", fx, fy, 5.0, 5.8, 1.6, -0.25, Mt, seg=20, ring=14)
    e.location = (fx, -0.25, ez(fy, -0.25, K))
    for sx in (-1, 1):
        e = I.elipsoid("kulak", fx + sx * 5.0, fy + 0.4, 0.9, 1.4, 0.5, -0.1, Mt, seg=10, ring=6)
        e.location = (fx + sx * 5.0, -0.1, ez(fy + 0.4, -0.1, K))
    Mfes = cel("PFes", ["#6d1a12", "#96271c", "#c33c2c", "#e05a48"], [0, .3, .56, .86])
    torna("fes", [(4.0, 0.0), (3.7, 2.4), (3.2, 4.2), (0.2, 4.4)], fx, fy - 3.8, -0.8, 0.45, Mfes, K, seg=24)
    Mp = cel("PPuskul", ["#1e140c", "#3a2a1e"], [0, .6])
    kutu_bevel("puskul", fx + 2.4, fx + 3.1, fy - 8.0, fy - 4.3, -1.3, -1.0, Mp, bevel=0.1, seg=1)
    Mb = cel("PBiyik", ["#b8b4a8", "#dcd9cf", "#efefe9", "#ffffff"], [0, .3, .6, .88])
    for sx in (-1, 1):
        e = I.elipsoid("biyik", fx + sx * 2.1, fy + 2.4, 2.5, 0.95, 0.5, -1.6, Mb, seg=12, ring=6)
        e.location = (fx + sx * 2.1, -1.6, ez(fy + 2.4, -1.6, K))
        e = I.elipsoid("kas", fx + sx * 2.2, fy - 2.3, 1.4, 0.45, 0.3, -1.5, Mb, seg=10, ring=5)
        e.location = (fx + sx * 2.2, -1.5, ez(fy - 2.3, -1.5, K))
    Mgoz = px.flat("PGoz", "#2b2018")
    for sx in (-1, 1):
        e = I.elipsoid("goz", fx + sx * 2.2, fy - 0.9, 0.75, 0.6, 0.3, -1.7, Mgoz, seg=8, ring=5)
        e.location = (fx + sx * 2.2, -1.7, ez(fy - 0.9, -1.7, K))
    e = I.elipsoid("burun", fx, fy + 0.7, 0.9, 1.1, 0.6, -1.4, Mt, seg=10, ring=6)
    e.location = (fx, -1.4, ez(fy + 0.7, -1.4, K))
    # cam yansimasi
    on_poligon("yansima", [(8.0, 12.0), (15.0, 3.2), (17.2, 3.2), (8.0, 14.8)], -2.1,
               px.flat_a("PYansima", "#ffffff", 0.16), K, derin=0.02)
    L.yazi("BABA", "arialblk", 4.6, 20.0, ez(31.2, -2.25, K), -2.25, 0.3, 0.0, px.flat("PYazi", "#4a2e16"), maxw=22, aralik=0.7)
    # yas kurdelesi (sol ust kose)
    Mr = cel("Kurdele", ["#000000", "#1a1414", "#3a3030"], [0, .5, .85])
    on_poligon("kurdele", [(3.2, 7.4), (11.4, -0.8), (13.4, -0.8), (3.2, 9.6)], -3.7, Mr, K, derin=0.2)


# ================================================================ kayit
parca("pencere", (-6, -4, 284, 116), pencere, cizgi="#15181c", cizgi_alfa=120)
parca("cam_isik", (0, 0, GL_W, GL_H), cam_isik, tur="np")
parca("esik_golge", (-6, 105, 284, 4), esik_golge, tur="np")
parca("kepenk_sac", (0, 0, 264, SAC_H), kepenk_sac)
parca("kepenk_alt", (-1, -2, 266, 7), kepenk_alt)
parca("kepenk_golge", (0, 0, 264, 3), kepenk_golge, tur="np")
for _rh in range(3, 10):
    parca("kepenk_rulo_%d" % _rh, (-4, -2, 272, _rh + 4), kepenk_rulo(_rh), cizgi="#1d2126", cizgi_alfa=110)
parca("tabela", (-4, -4, TAB_W + 8, 36), tabela, cizgi="#1e140c", cizgi_alfa=150)
parca("ampul_acik", (-3, -3, 6, 6), ampul(True))
parca("ampul_kapali", (-3, -3, 6, 6), ampul(False))
parca("ampul_isik", (-5, -5, 10, 10), ampul_isik, tur="np")
parca("lamba", (108, -1, 26, 25), lamba, cizgi="#1e140c", cizgi_alfa=130)
parca("lamba_isik", (88, 20, 64, 32), lamba_isik, tur="np")
parca("afis_1", (-2, -4, 46, 38), afis_1, cizgi="#1e140c", cizgi_alfa=110)
parca("afis_2", (-2, -2, 44, 40), afis_2, cizgi="#1e140c", cizgi_alfa=120)
parca("afis_3", (1, -3, 38, 40), afis_3, cizgi="#1e140c", cizgi_alfa=120)

TABELA_DILIM = {"tabela_sol": (-4, 10, -4), "tabela_orta": (40, 56, 0), "tabela_sag": (TAB_W - 10, TAB_W + 4, -10)}
for _ad, (_x0, _x1, _kx) in TABELA_DILIM.items():
    KOKEN[_ad] = (_kx, PARCALAR["tabela"][0][1])


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, tur = PARCALAR[ad]
    yol = os.path.join(OUT, ad + ".png")
    if tur == "np":
        px.reset()
        return px.write_png(fn(), yol)
    D.sahne(gx0, gy0, w, h, 1.0)
    fn()
    px.shear_scene(K)
    px.render(yol)
    if ad == "kepenk_sac":
        kepenk_sac_son(yol)
    if cizgi:
        px.outline(yol, hexcol=cizgi, alpha=cizgi_alfa)
    return yol


def tabela_dilimle():
    """tabela.png -> sol / orta (tekrar eden karo) / sag."""
    gx0, gy0 = PARCALAR["tabela"][0][:2]
    a = px.read_png(os.path.join(OUT, "tabela.png"))
    for ad, (x0, x1, _) in TABELA_DILIM.items():
        px.write_png(a[:, (x0 - gx0) * HD:(x1 - gx0) * HD].copy(), os.path.join(OUT, ad + ".png"))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = [a for a in PARCALAR if not argv or any(a.startswith(x) for x in argv)]
    for ad in adlar:
        uret(ad)
    if "tabela" in adlar:
        tabela_dilimle()
    katmanlar = [k for k in KOKEN if k != "tabela"]
    for k in katmanlar:
        assert os.path.exists(os.path.join(OUT, k + ".png")), k
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": katmanlar,
                   "kokenler": {k: list(KOKEN[k]) for k in katmanlar}}, fp, indent=1)
    print("VITRIN_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
