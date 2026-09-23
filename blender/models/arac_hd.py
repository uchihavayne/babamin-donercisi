"""KESIM ARACLARI — remake HD (art.js drawKesimBicagi, drawSpit oto tiras).

    blender --background --factory-startup --python blender/models/arac_hd.py [-- ad ...]
    python blender/hd_atlas.py arac_hd arac

  bicak_<k>    k 0..3 (BICAK_KADEME): capa (ux, uy), agiz saga bakar (yon -1).
               0 ahsap sapli, 1 siyah sap + 2 percin, 2 cift bicakli elektrikli,
               3 altin bilezikli, 3 percin, kancali uzun sap.
  oto_ray      capa (rx0, spit.top): 4 px ray, cvata sirasi
  oto_motor    capa (rx0, spit.top): motor kutusu + teker yuvasi (teker cubugu kodda doner)
  oto_araba    capa (rx0, cy2): kizak arabasi + kelepce + bicak
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
import durum_hd as D
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "arac_hd")
HD = 2
K = S.K
ez = T.ez
kutu, elipsoid = S.kutu, S.elipsoid
mat_ton, mat_duz, hexmul = S.mat_ton, S.mat_duz, T.hexmul
PARCALAR, KOKEN = {}, {}

KADEME = [
    {"boy": 19, "yuk": 1, "cift": False, "celik": ["#767f88", "#a2abb3", "#c4ccd3"], "sapK": "#4e2e17", "sapG": "#6b4122", "sapI": "#8a5730", "bilezik": "#7a6c5c", "bilezikI": "#9a8a76", "percin": 0, "sapUz": 7, "sapKal": 1},
    {"boy": 25, "yuk": 1, "cift": False, "celik": ["#5a636c", "#c9d2da", "#eef4f8"], "sapK": "#141414", "sapG": "#242830", "sapI": "#3a4048", "bilezik": "#8f9aa4", "bilezikI": "#eef4f8", "percin": 2, "sapUz": 8, "sapKal": 2},
    {"boy": 27, "yuk": 0, "cift": True, "celik": ["#5a636c", "#c9d2da", "#eef4f8"], "sapK": "#141414", "sapG": "#242830", "sapI": "#3a4048", "bilezik": "#8f9aa4", "bilezikI": "#eef4f8", "percin": 3, "sapUz": 9, "sapKal": 2},
    {"boy": 29, "yuk": 2, "cift": False, "celik": ["#4a525a", "#b6c0c9", "#ffffff"], "sapK": "#141414", "sapG": "#242830", "sapI": "#565e68", "bilezik": "#a97113", "bilezikI": "#ffd34e", "percin": 3, "sapUz": 10, "sapKal": 3},
]


def parca(ad, tuval, fn, cizgi="#1a1410", cizgi_alfa=120):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa)
    KOKEN[ad] = (tuval[0], tuval[1])


def tup(noktalar, yaricap, y, mat, seg=10, derin=0.8, kapak=True):
    """Ekran noktalarindan gecen boru (bicak sapi); yaricap(t) px."""
    bm = bmesh.new()
    n = len(noktalar)
    halkalar = []
    for k, (x, gy) in enumerate(noktalar):
        a = noktalar[max(0, k - 1)]
        b = noktalar[min(n - 1, k + 1)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        u = math.hypot(dx, dy) or 1.0
        nx, ny = -dy / u, dx / u
        r = yaricap(k / (n - 1))
        halka = []
        for s in range(seg):
            aci = 2 * math.pi * s / seg
            sx = x + nx * r * math.cos(aci)
            sgy = gy + ny * r * math.cos(aci)
            sy = y - r * derin * math.sin(aci)
            halka.append(bm.verts.new((sx, sy, ez(sgy, sy, K))))
        halkalar.append(halka)
    for k in range(n - 1):
        for s in range(seg):
            bm.faces.new((halkalar[k][s], halkalar[k][(s + 1) % seg], halkalar[k + 1][(s + 1) % seg], halkalar[k + 1][s]))
    if kapak:
        bm.faces.new(list(reversed(halkalar[0])))
        bm.faces.new(halkalar[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return I.mesh_ob("tup", bm, mat, smooth=True)


def agiz(x_uc, x_dip, gy, yari, y, mat, yuvarlak=True):
    """Bicak agzi: sirtta kalin (arkada), agizda ince (onde) kama kesitli
    levha; uc (x_uc) yuvarlatilmis, dipte (bilezik tarafi) boyun."""
    bm = bmesh.new()
    n = 24
    ust, alt, sirt = [], [], []
    for k in range(n + 1):
        t = k / n
        x = x_dip + (x_uc - x_dip) * t
        h = yari
        if t < 0.1:                                    # boyun
            h = yari * (0.55 + 0.45 * t / 0.1)
        if yuvarlak and t > 0.86:                      # yuvarlak uc (alt kenardan kavis)
            v = (t - 0.86) / 0.14
            h_alt = yari * math.sqrt(max(0.0, 1 - v * v))
        else:
            h_alt = h
        ust.append(bm.verts.new((x, y, ez(gy - h, y, K))))
        sirt.append(bm.verts.new((x, y + 0.35, ez(gy - h + 0.2, y + 0.35, K))))
        alt.append(bm.verts.new((x, y - 0.05, ez(gy + h_alt, y - 0.05, K))))
    for k in range(n):
        bm.faces.new((ust[k], ust[k + 1], alt[k + 1], alt[k]))           # on (egimli) yuz
        bm.faces.new((sirt[k], sirt[k + 1], ust[k + 1], ust[k]))         # sirt
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    for f in bm.faces:
        if f.normal.y > 0.5:
            f.normal_flip()
    return I.mesh_ob("agiz", bm, mat, smooth=False)


def bicak(k):
    Kd = KADEME[k]

    def fn():
        boy, yuk = Kd["boy"], Kd["yuk"]
        c0, c1, c2 = Kd["celik"]
        Mc = I.cel("Celik%d" % k, [hexmul(c0, 0.85), c0, c1, c2, "#ffffff"], [0, .2, .45, .78, .95])
        uc = 0.5
        dip = -boy + 0.5
        if Kd["cift"]:
            for oz in (-2.0, 2.0):
                agiz(uc, dip, oz + 0.5, 0.75, -0.2, Mc)
            blok = -(boy - 2) - 3
            kutu(blok, blok + 4, -1.5, 3.5, -0.8, 0.8, mat_ton(c0, f=(0.62, 0.84, 1.0, 1.25)), bevel=0.3)
            kutu(blok + 1, blok + 3, -2.2, -1.5, -0.6, 0.6, mat_duz(c1))
        else:
            agiz(uc, dip, 0.5, yuk + 0.55, -0.2, Mc)
            # sirtta ince parlak cizgi
            T.on_poligon("parlak", [(dip + 3, 0.5 - yuk - 0.25), (uc - 2, 0.5 - yuk - 0.25), (uc - 2, 0.5 - yuk + 0.15), (dip + 3, 0.5 - yuk + 0.15)],
                         -0.35, px.flat_a("Parlak%d" % k, "#ffffff", 0.7), K, derin=0.02)
        bx0 = -(boy + 1)
        bh = Kd["sapKal"] + 1
        Mb = I.cel("Bilezik%d" % k, [hexmul(Kd["bilezik"], 0.7), Kd["bilezik"], Kd["bilezikI"], "#ffffff"], [0, .3, .65, .92])
        kutu(bx0 - 1, bx0 + 2, 0.5 - bh, 0.5 + bh + 0.5, -1.2, 1.2, Mb, bevel=0.4)
        # sap: kalinlik sin ile siser, son %38'de yukari kancalanir
        sapUz, sapKal = Kd["sapUz"], Kd["sapKal"]
        pts, rr = [], []
        for s in range(sapUz + 1):
            sx = -(boy + 3 + s) + 0.5
            kanca = -max(0.0, (s - sapUz * 0.62) * 0.5) if s > sapUz * 0.62 else 0.0
            pts.append((sx, 0.5 + kanca))
        Ms = I.cel("Sap%d" % k, [Kd["sapK"], Kd["sapG"], Kd["sapI"], hexmul(Kd["sapI"], 1.5)], [0, .3, .62, .9],
                   noise=0.12 if k == 0 else 0.0, noise_scale=20)
        tup(pts, lambda t: sapKal + 0.45 + 0.6 * math.sin((t * sapUz + 1) / (sapUz + 1) * math.pi) - (0.4 if t > 0.95 else 0.0), 0.0, Ms, seg=12)
        for p in range(Kd["percin"]):
            px0 = -(boy + 5 + p * 2) + 0.5
            L.silindir("percin", 0.55, px0, -sapKal - 0.6, ez(0.6, -sapKal - 0.6, K), 0.4, mat_ton(Kd["bilezikI"], f=(0.6, 0.85, 1.0, 1.1)), seg=10, eksen="Y")
    return fn


def oto_ray():
    H0 = 168 - 58
    Mr = I.cel("Ray", ["#2a2f36", "#3a4048", "#6b737d", "#98a0a9"], [0, .25, .55, .85])
    kutu(0, 4, -6, H0 + 8, -1.0, 1.0, Mr, bevel=0.4)
    kutu(1, 3, -6, H0 + 8, -1.2, -1.0, mat_ton("#4a525a"))
    for rv in range(0, H0 + 10, 8):
        elipsoid(1.5, -4 + rv + 0.5, 0.7, 0.7, 0.4, -1.4, mat_ton("#98a0a9", f=(0.6, 0.85, 1.0, 1.2)), seg=8, ring=5)


def oto_motor():
    Mm = I.cel("Motor", ["#2f3740", "#3f4852", "#59636d", "#8b959e"], [0, .25, .5, .82])
    kutu(-7, 9, -16, -4, -2.0, 2.0, Mm, bevel=0.6)
    for x in range(-5, 8, 2):                           # sogutma kanatlari
        kutu(x, x + 0.6, -14.5, -12.5, -2.15, -2.0, mat_duz("#2f3740"))
    # teker yuvasi (cubuk kodda doner)
    L.silindir("teker", 4.2, 1.5, -2.2, ez(-9.5, -2.2, K), 0.6, I.cel("TekerD", ["#2a2f36", "#3a4048", "#5a636c"], [0, .4, .8]), seg=24, eksen="Y")
    L.silindir("teker_ic", 3.1, 1.5, -2.6, ez(-9.5, -2.6, K), 0.3, I.cel("TekerI", ["#6b737d", "#98a0a9", "#c6ccd2"], [0, .45, .85]), seg=24, eksen="Y")
    L.silindir("mil", 0.8, 1.5, -2.9, ez(-9.5, -2.9, K), 0.3, mat_duz("#2f3740"), seg=10, eksen="Y")
    kutu(-5, -2.6, -13.8, -11.8, -2.1, -2.0, mat_duz("#1a1f24"))    # led yuvasi


def oto_araba():
    Ma = I.cel("Araba", ["#3f4852", "#59636d", "#8b959e", "#c6ccd2"], [0, .25, .5, .82])
    kutu(-4, 8, -5, 6, -1.8, 1.8, Ma, bevel=0.6)
    kutu(-5, -2, -1, 2, -2.4, 0.5, mat_ton("#2f3740", f=(0.6, 0.85, 1.0, 1.3)), bevel=0.3)
    for gy in (-3.5, 3.5):
        L.silindir("vida", 0.6, 6.5, -1.9, ez(gy, -1.9, K), 0.3, mat_duz("#2f3740"), seg=8, eksen="Y")
    Mc = I.cel("ArabaCelik", ["#8f9aa4", "#c9d2da", "#eef4f8", "#ffffff"], [0, .3, .65, .9])
    agiz(21.5, 7.0, 0.5, 1.4, -0.6, Mc)


for _k in range(4):
    _Kd = KADEME[_k]
    _sol = -(_Kd["boy"] + 3 + _Kd["sapUz"]) - 3
    parca("bicak_%d" % _k, (_sol, -7, -_sol + 3, 14), bicak(_k))
parca("oto_ray", (-2, -8, 8, 120), oto_ray)
parca("oto_motor", (-9, -19, 20, 17), oto_motor)
parca("oto_araba", (-7, -7, 31, 15), oto_araba)


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa = PARCALAR[ad]
    D.sahne(gx0, gy0, w, h, 1.0)
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
        json.dump({"hd": HD, "katmanlar": list(PARCALAR), "kokenler": {k: list(v) for k, v in KOKEN.items()}}, fp, indent=1)
    print("ARAC_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
