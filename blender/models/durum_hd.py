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
def durum_acik():
    """Acik lavas. BIRLESIK: kullanici "ucundan katlanmis gibi" dedi -> ondeki
    koyu kivrim bandi kaldirildi, kubbe golgesinin yuzeyi capraz iki tona bolmesi
    yumusatildi (yakin tonlu rampa); yerine cepecevre ince kizarmis kenar ve
    dogal pisme kabarciklari."""
    K = 0.5
    rx, ry = 22.0, 9.0
    Ma = px.flat("LavasAlt", "#c49a64")
    # alt kat: lavas ince (eskiden toplam ~2.1 px kalinlik tabak gibi duruyordu)
    I.yatay_elips("alt", 0, -0.05, rx, 0.6, Ma, K, ry_ekran=ry, seg=56)
    Ml = cel("LavasUst", ["#e2c290", "#ebcd9e", "#f0d5a8", "#f5dfb8"], [0, .3, .55, .88], noise=0.06, noise_scale=7)
    I.yatay_elips("ust", 0, -0.6, rx - 0.3, 1.0, Ml, K, ry_ekran=ry - 0.3, seg=56, egim=0.02)
    zt = 0.6 - 0.5 + 1.0 + 0.02
    # kizarmis kenar: disk kenari boyunca ince, hafif koyu halka
    Mk = px.flat("LavasKenar", "#d8b27c")
    dis, ic = [], []
    for j in range(56):
        a = 2 * math.pi * j / 56
        dis.append((math.cos(a) * (rx - 0.6), -0.6 + math.sin(a) * (ry - 0.8)))
        ic.append((math.cos(a) * (rx - 2.0), -0.6 + math.sin(a) * (ry - 1.9)))
    for j in range(56):
        k = (j + 1) % 56
        T.ust_poligon("kenar", [dis[j], dis[k], ic[k], ic[j]], zt, Mk, K, kal=0.04)
    # pisme lekeleri (kucuk koyu) + kabarciklar (acik)
    for i in range(18):
        a = hash1(i * 3.1) * math.tau
        r0 = hash1(i * 7.3) ** 0.7
        x = math.cos(a) * rx * r0 * 0.82
        y = -0.8 + math.sin(a) * ry * r0 * 0.78
        koyu = hash1(i) > 0.55
        renk = "#c89e68" if koyu else "#faeccd"
        rr = 0.55 + hash1(i * 1.7) * 0.5
        pts = [(x + rr * 1.3 * math.cos(2 * math.pi * q / 8), y + rr * 0.6 * math.sin(2 * math.pi * q / 8)) for q in range(8)]
        T.ust_poligon("benek", pts, zt + 0.02, px.flat("Benek%s" % renk, renk), K, kal=0.05)


# ---------------------------------------------------------------- sarili durum
KADEME = [("k0", 0.0), ("k20", 0.2), ("k40", 0.4), ("k60", 0.6), ("k80", 0.8), ("k100", 1.0), ("yanik", None)]


def durum_govde(kiz):
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
        # kapsul: tek parca donel govde (uclarla ayni yumusak normal, dikis yok)
        R = 6.3
        bm = bmesh.new()
        seg = 28
        xs = [-20.0 + 5.0 * (1 - math.cos(math.pi / 2 * i / 6)) for i in range(7)]
        xs += [-15.0 + 30.0 * i / 6 for i in range(1, 6)]
        xs += [15.0 + 5.0 * math.sin(math.pi / 2 * i / 6) for i in range(0, 7)]
        halkalar = []
        for x in xs:
            u = max(0.0, abs(x) - 15.0) / 5.0
            r = R * math.sqrt(max(0.0, 1 - u * u))
            halkalar.append([bm.verts.new((x, -r * math.cos(2 * math.pi * j / seg), r * math.sin(2 * math.pi * j / seg))) for j in range(seg)])
        for a_, b_ in zip(halkalar, halkalar[1:]):
            for j in range(seg):
                bm.faces.new((a_[j], a_[(j + 1) % seg], b_[(j + 1) % seg], b_[j]))
        bmesh.ops.remove_doubles(bm, verts=bm.verts[:], dist=0.001)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        I.mesh_ob("kapsul", bm, Mg)
        yon = -R - 0.4
        # uclardaki sarim halkasi
        for sx in (-1, 1):
            cx = sx * 18.0
            pts = [(cx + 2.2 * math.cos(2 * math.pi * j / 20), 4.6 * math.sin(2 * math.pi * j / 20)) for j in range(20)]
            on_poligon("uc_halka", pts, yon, px.flat("UcHalka%s" % shade, shade), K, derin=0.05)
            pts2 = [(cx + 0.9 * math.cos(2 * math.pi * j / 12), 1.6 * math.sin(2 * math.pi * j / 12)) for j in range(12)]
            on_poligon("uc_ic", pts2, yon - 0.05, px.flat("UcIc%s" % base, base), K, derin=0.05)
        # spiral cizgiler
        for si in range(4):
            x0 = -12 + si * 8
            on_poligon("spiral", [(x0 - 0.4, -5), (x0 + 0.4, -5), (x0 + 2.4, 5), (x0 + 1.6, 5)], yon - 0.1,
                       px.flat_a("Spiral%s" % shade, shade, 0.22), K, derin=0.02)
        # izgara izleri
        if kiz is not None and kiz > 0.18:
            guc = min(1.0, max(0.0, (kiz - 0.18) / 0.82))
            for gi in range(5):
                izk = min(1.0, max(0.0, (guc - gi * 0.11) / 0.45))
                if izk <= 0:
                    continue
                x0 = -14 + gi * 7
                on_poligon("iz", [(x0 - 0.55, -4), (x0 + 0.55, -4), (x0 + 3.55, 4), (x0 + 2.45, 4)], yon - 0.15 - gi * 0.01,
                           px.flat_a("Iz%d%.2f" % (gi, izk), "#8a5a2a", 0.55 * izk), K, derin=0.02)
            if kiz > 0.62:
                a = 0.4 * min(1.0, max(0.0, (kiz - 0.62) / 0.38))
                for kb in range(6):
                    bx = math.floor(-15 + hash1(kb * 3.7) * 30 + 0.5)
                    by = math.floor(-4 + hash1(kb * 8.3) * 8 + 0.5)
                    onkutu("benek", bx, bx + 1, by, by + 1, yon - 0.3, yon - 0.2, px.flat_a("KBenek%.2f" % a, "#6b3f18", a), K)
        if kiz is None:
            # yanik: is lekeleri
            for kb in range(9):
                bx = -16 + hash1(kb * 5.3) * 32
                by = -4 + hash1(kb * 2.9) * 8
                onkutu("is", bx, bx + 1.5, by, by + 1, yon - 0.3, yon - 0.2, px.flat("Is", "#1a1411"), K)
        # uctan gorunen et
        onkutu("et1", 16, 17, -2, -1, yon - 0.4, yon - 0.3, px.flat("Et1", "#c98436"), K)
        onkutu("et2", 15, 16, 1, 2, yon - 0.4, yon - 0.3, px.flat("Et2", "#8a4f1e"), K)
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


def durum_kagit_arka():
    K = 0.25
    pl, pw, h = -21.0, 21.0, 13.0
    L.levha("arka", pw + 3, h + 2, 4.5, pl - 1 + (pw + 3) / 2.0, 0.0, 4.0, 0.5, 0.0, px.flat("KagitArkaAlt", "#cfc9b8"))
    L.levha("arka_ust", pw + 3, h + 1, 4.5, pl - 1 + (pw + 3) / 2.0, 0.5, 3.6, 0.3, 0.0, px.flat("KagitArkaUst", "#e8e4d6"))


# BIRLESIK: yeni tahtada 1 / 2 / 3 urun -> 1.8 / 1.22 / 0.9 olcek (counter_design)
ACIK_OLCEK = (1.0, 0.74, 0.58, 1.8, 1.22, 0.9)
SARILI_OLCEK = (1.0, 0.8, 0.74, 0.62, 0.58, 1.8, 1.22, 0.9)
parca("durum_acik", (-24, -11, 48, 22), durum_acik, 0.5, ACIK_OLCEK, cizgi="#8a6a3a", cizgi_alfa=110)
for _ad, _k in KADEME:
    parca("durum_" + _ad, (-23, -9, 46, 18), durum_govde(_k), 0.25, SARILI_OLCEK, cizgi="#5a3a18", cizgi_alfa=120)
parca("durum_kagit", (-23, -9, 26, 18), durum_kagit, 0.25, SARILI_OLCEK)
parca("durum_kagit_arka", (-24, -9, 28, 18), durum_kagit_arka, 0.25, SARILI_OLCEK)


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
