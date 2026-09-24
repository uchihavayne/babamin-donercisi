"""ISKENDER PIDE TAHTASI — remake HD (food.js drawPideBoard, pideSerit, pideKup, pideBicak).

    blender --background --factory-startup --python blender/models/pide_hd.py [-- ad ...]
    python blender/hd_atlas.py pide_hd pide

Pide PIDE_NEED + 1 = 5 dilime bolunur; kesilen dilimler 2 sira kup olur, kesilmeyen
dilim ekmek kalibi olarak kalir. Tahta ctx.scale icinde de cizildigi icin (servis
tahtasi 1 / .74 / .58, elde .85) her parca 4 olcekte render edilir.
  pide_serit_<q>_<o>   q 0..4, capa (cx, cy)  (taban = cy + 6)
  pide_kup_<q>_<o>     kesilmis dilimin kupleri
  pide_bicak_<o>       capa (bicak x, agiz y)
"""
import sys, os, math, json
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "pide_hd")
HD = 2
K = S.K
ez = T.ez
kutu = S.kutu
PIDE_NEED, PIDE_KAL, PIDE_DER = 4, 5.2, 3.4
OLCEK = (1.0, 0.85, 0.74, 0.58, 1.8, 1.22, 0.9)
PARCALAR, KOKEN, OLCEKLER = {}, {}, {}


def hash1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


def serit(q):
    seg = PIDE_NEED + 1
    rx = 24.0
    u = (q + 0.5) / seg - 0.5
    kk = abs(u * 2)
    d = PIDE_DER * math.sqrt(max(0.1, 1 - kk * kk * 0.8))
    h = PIDE_KAL * (0.78 + 0.22 * math.sqrt(max(0.0, 1 - kk * kk)))
    return {"L": math.floor(-rx + q * (rx * 2 / seg) + 0.5), "R": math.floor(-rx + (q + 1) * (rx * 2 / seg) + 0.5),
            "d": d, "h": max(2.0, math.floor(h + 0.5)), "geri": math.floor(h + d * 2 + 0.5)}


def ekmek():
    return I.cel("Pide", ["#4e2c0c", "#7a4818", "#a86c26", "#d09440", "#ecc070"], [0, .2, .45, .66, .88], noise=0.1, noise_scale=16)


def ekmek_ic():
    """Pidenin kesilen yuzu (yumusak ic)."""
    return I.cel("PideIc", ["#b8905a", "#d8b67c", "#ecd2a0", "#f8e6c0"], [0, .3, .55, .85], noise=0.12, noise_scale=22)


def _pide_h(x, y, cx, cy, rx, ry, kalin, desen):
    """Tirnakli pide yuksekligi: kabarik kenar halkasi, ortada baklava bicimli
    tirnak izleri (oluklar), kenarda yuvarlak dusus."""
    r = math.sqrt(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2)
    taban = 0.8 + 0.35 * math.exp(-((r - 0.82) / 0.075) ** 2)
    if r > 0.88:
        taban *= math.sqrt(max(0.0, 1.0 - ((r - 0.88) / 0.12) ** 2))
    oluk = 0.0
    if desen and r < 0.7:
        a = abs(math.sin((x * 0.55 + y * 0.8) * 0.9))
        b = abs(math.sin((x * 0.55 - y * 0.8) * 0.9))
        oluk = 0.45 * max(0.0, 1.0 - min(a, b) / 0.3) * min(1.0, (0.7 - r) / 0.08)
    return kalin * max(0.0, taban - oluk)


def pide_mesh(ad, cx, taban_gy, rx, ry, kalin, x_ara=None, desen=True, tohum=0.0, mat=None, mat_ic=None, tohumlar=True):
    """BIRLESIK (4. tur, kullanici: "iskender pideden olur, pide modeli yap"):
    oval, yassi tirnakli pide. Onu (en yakin kenar) derinlik 0'da, taban
    ekranda taban_gy. x_ara=(L, R): yalniz o dilim; kesik yuzlerde ekmegin ici."""
    M = mat or ekmek()
    Mi = mat_ic or ekmek_ic()
    cy = ry
    z0 = -taban_gy
    L_ = cx - rx if x_ara is None else max(cx - rx + 0.01, x_ara[0])
    R_ = cx + rx if x_ara is None else min(cx + rx - 0.01, x_ara[1])
    nx = max(4, int((R_ - L_) / 0.45))
    ny = 26
    bm = bmesh.new()
    g = []
    for i_ in range(nx + 1):
        x = L_ + (R_ - L_) * i_ / nx
        yy = ry * math.sqrt(max(0.0, 1.0 - ((x - cx) / rx) ** 2))
        sira = []
        for j_ in range(ny + 1):
            y = cy - yy + 2 * yy * j_ / ny
            sira.append(bm.verts.new((x, y, z0 + _pide_h(x, y, cx, cy, rx, ry, kalin, desen))))
        g.append(sira)
    for i_ in range(nx):
        for j_ in range(ny):
            bm.faces.new((g[i_][j_], g[i_ + 1][j_], g[i_ + 1][j_ + 1], g[i_][j_ + 1]))
    kesik = []
    if x_ara is not None:
        for kenar, x in ((0, L_), (nx, R_)):
            if abs(x - (cx - rx)) < 0.05 or abs(x - (cx + rx)) < 0.05:
                continue
            ust = g[kenar]
            alt = [bm.verts.new((v.co.x, v.co.y, z0)) for v in ust]
            for j_ in range(ny):
                kesik.append(bm.faces.new((alt[j_], alt[j_ + 1], ust[j_ + 1], ust[j_])))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in kesik:
        f.material_index = 1
    ob = I.mesh_ob(ad, bm, M, smooth=True)
    ob.data.materials.append(Mi)
    for pol in ob.data.polygons:
        if pol.normal.z < -0.1:
            pol.flip()
    if tohumlar:
        # corek otu (siyah) ve susam (krem): ust yuzeyde, kabarik kenarin icinde
        Mn = S.mat_duz("#1e1612")
        Ms = S.mat_duz("#f4e2b8")
        for q in range(int(rx * ry * 0.22)):
            a = hash1(q * 3.7 + tohum) * math.tau
            rr = 0.72 * math.sqrt(hash1(q * 7.1 + tohum))
            x = cx + math.cos(a) * rx * rr
            y = cy + math.sin(a) * ry * rr
            if x_ara is not None and not (L_ + 0.3 < x < R_ - 0.3):
                continue
            z = z0 + _pide_h(x, y, cx, cy, rx, ry, kalin, desen)
            e = I.elipsoid("tohum%d" % q, 0, 0, 0.42, 0.18, 0.26, 0.0, Mn if hash1(q * 1.9 + tohum) > 0.4 else Ms, seg=6, ring=4)
            e.location = (x, y, z + 0.1)
            e.rotation_euler = (0, 0, hash1(q * 5.5) * 3.0)
    return ob


PIDE_RX, PIDE_RY, PIDE_KALIN = 24.0, 10.5, 3.6


def pide_serit(q):
    def fn():
        seg = PIDE_NEED + 1
        L_ = -PIDE_RX + q * (PIDE_RX * 2 / seg)
        R_ = -PIDE_RX + (q + 1) * (PIDE_RX * 2 / seg)
        # dilimler arasinda ince bicak izi: kesik yuzler 0.15 iceride
        pide_mesh("pide%d" % q, 0.0, 6.0, PIDE_RX, PIDE_RY, PIDE_KALIN,
                  x_ara=(L_ + (0.12 if q > 0 else 0.0), R_ - (0.12 if q < PIDE_NEED else 0.0)))
    return fn


def pide_kup(q):
    """Kesilmis dilimin kupleri: ustu kabuk (pide rengi), yanlari ekmek ici."""
    def fn():
        taban = 6.0
        s = serit(q)
        Mk = ekmek()
        Mi = ekmek_ic()
        for b in (1, 0):
            for a in range(3):
                hs = hash1(q * 13.7 + a * 3.1 + b * 7.7)
                kx = s["L"] + 1 + a * 3 + (1 if b else 0)
                if kx + 3 > s["R"]:
                    continue
                y = taban - b * 4 - math.floor(hs * 1.4 + 0.5)
                ob = kutu(kx, kx + 3, y - 3, y, b * 2.0, b * 2.0 + 4.0, Mi, bevel=0.35)
                ob.data.materials.append(Mk)
                for pol in ob.data.polygons:
                    if pol.normal.z > 0.6:
                        pol.material_index = 1
                ob.rotation_euler = (0, 0, (hs - 0.5) * 0.4)
    return fn


def pide_bicak():
    Ms = I.cel("PBicak", ["#6d7a86", "#aab4bd", "#dfe6ec", "#ffffff"], [0, .3, .62, .9])
    pts = []
    for r in (0, 9):
        ww = 4 + math.floor(4 * r / 9 + 0.5)
        x0 = -ww + 2 + math.floor((9 - r) * 0.18 + 0.5)
        pts.append((x0, -10 + r, x0 + ww))
    poli = [(pts[0][0], pts[0][1]), (pts[0][2], pts[0][1]), (pts[1][2], pts[1][1] + 1), (pts[1][0] - 1, pts[1][1] + 1)]
    T.on_poligon("agiz", poli, -0.3, Ms, K, derin=0.5)
    T.on_poligon("kenar", [(-7, -0.6), (2, -0.6), (2, 0.2), (-7, 0.2)], -0.9, S.mat_duz("#ffffff"), K, derin=0.05)
    kutu(-1, 4, -12, -10, -0.6, 0.6, I.cel("PBilezik", ["#6d7a86", "#8f979f", "#c3ccd3"], [0, .45, .85]), bevel=0.3)
    Mw = I.cel("PSap", ["#3a2718", "#5a3a22", "#7a5230", "#a5733f"], [0, .3, .62, .9], noise=0.1, noise_scale=20)
    import arac_hd as A
    A.tup([(1.0, -12.2), (1.9, -15.5), (2.8, -19.0), (3.2, -20.2)], lambda t: 2.6 - 0.4 * t, 0.0, Mw, seg=12)
    e = I.elipsoid("percin", 1.5, -16, 0.6, 0.6, 0.3, -0.9, S.mat_duz("#c9a06a"), seg=8, ring=4)
    e.location = (1.5, -0.9, ez(-16, -0.9, K))


def parca(ad, tuval, fn, cizgi="#2a1a0c", cizgi_alfa=110):
    for sc in OLCEK:
        tam = "%s_%d" % (ad, int(round(sc * 100)))
        PARCALAR[tam] = (tuval, fn, cizgi, cizgi_alfa, sc)
        KOKEN[tam] = (tuval[0], tuval[1])
        OLCEKLER[tam] = sc


for _q in range(PIDE_NEED + 1):
    parca("pide_serit_%d" % _q, (-27, -10, 54, 18), pide_serit(_q), cizgi=None)
    parca("pide_kup_%d" % _q, (-27, -10, 54, 18), pide_kup(_q), cizgi="#3a2410", cizgi_alfa=60)
parca("pide_bicak", (-10, -22, 17, 24), pide_bicak)


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, sc = PARCALAR[ad]
    D.sahne(gx0, gy0, w, h, sc)
    S._MAT.clear()
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
        json.dump({"hd": HD, "katmanlar": list(PARCALAR), "kokenler": {k: list(v) for k, v in KOKEN.items()},
                   "olcekler": {k: v for k, v in OLCEKLER.items() if v != 1.0}}, fp, indent=1)
    print("PIDE_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
