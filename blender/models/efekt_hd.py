"""UCAN PARA, KAR, CAM DAMLASI, KIRAGI — remake HD (food.js drawCoin, art.js drawKar/drawCamDamla).

    blender --background --factory-startup --python blender/models/efekt_hd.py [-- ad ...]
    python blender/hd_atlas.py efekt_hd efekt

  para_a_<r> / para_g_<r>  r = 1..5 donme fazi (oyunda rx = max(1, round(5*|sin|)))
                           altin (v>=25) / gumus; capa para merkezi (x, y)
                           GERCEK 3B: silindir Z ekseni etrafinda fi kadar donuk,
                           ekrandaki yari genislik r*cos(fi) + kalinlik/2*sin(fi).
                           Bu parcalarda egme (shear) YOK: para ekran duzleminde.
  kar_b / kar_k            buyuk (2x2 blok) ve kucuk (1 px) kar tanesi kristali
  damla_<rx>_<ry>          cam damlasi (1_1, 1_2, 2_2, 2_3), damla_k = r<1.1 tek px
  kirag_ust / kirag_alt    cam kenarindaki kiragi seridi (LAY.glass w=264)
"""
import sys, os, math, json
import bpy, bmesh
import numpy as np
from mathutils import Matrix, Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "efekt_hd")
HD = 2
hexmul = T.hexmul
PARCALAR, KOKEN = {}, {}


def parca(ad, tuval, fn, cizgi=None, cizgi_alfa=110, tur="3b"):
    PARCALAR[ad] = (tuval, fn, cizgi, cizgi_alfa, tur)
    KOKEN[ad] = (tuval[0], tuval[1])


def hash1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


# ================================================================ para
PARA_R, PARA_KAL = 5.0, 1.35
ALTIN = ["#8a5a0d", "#a97113", "#e0a41f", "#ffd34e", "#fff2a8"]
GUMUS = ["#6f6f6f", "#8a8a8a", "#a9a9a9", "#d8d8d8", "#f7f7f7"]


def _fi(rx):
    """Ekranda yari genislik rx olacak donme acisi (0 = tam daire)."""
    en_iyi, hata = 0.0, 1e9
    for i in range(2000):
        f = i * (math.pi / 2.0) / 1999.0
        g = PARA_R * math.cos(f) + (PARA_KAL / 2.0) * math.sin(f)
        if abs(g - rx) < hata:
            hata, en_iyi = abs(g - rx), f
    return en_iyi


def _silindir(ad, r, kal, mat, seg=32, y0=0.0):
    """Ekrana bakan silindir: ekseni Y, merkez (0, y0, 0)."""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=seg,
                          radius1=r, radius2=r, depth=kal)
    bmesh.ops.rotate(bm, verts=bm.verts, cent=(0, 0, 0),
                     matrix=Matrix.Rotation(math.pi / 2.0, 3, "X"))
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0.0, y0, 0.0))
    return I.mesh_ob(ad, bm, mat, smooth=False)


def para(altin, rx):
    """food.js: alt elips au3 (kenar), ust au1, ic au0, uzerinde rakam.
    HD: kenar koyu ramp, ic alan bir kademe acik ve 0.2 kabarik, on yuzde
    kabartma rakam (altin 5 / gumus 1)."""
    def fn():
        ramp = ALTIN if altin else GUMUS
        Mg = I.cel("ParaG%d%d" % (altin, rx), ramp, [0, .26, .52, .74, .93])
        Mi = I.cel("ParaI%d%d" % (altin, rx), ramp[2:] + [ramp[-1]], [0, .38, .72, .95])
        Mr = I.cel("ParaR%d%d" % (altin, rx), ramp[:3], [0, .42, .9])
        obs = [_silindir("govde", PARA_R, PARA_KAL, Mg, seg=36)]
        obs.append(_silindir("ic", PARA_R - 1.3, PARA_KAL + 0.4, Mi, seg=32))
        obs += L.yazi("5" if altin else "1", "arialblk", 4.6, 0.0, -2.3,
                      -(PARA_KAL / 2.0 + 0.45), 0.55, 0.06, Mr)[0]
        M = Matrix.Rotation(_fi(rx), 4, "Z")
        for ob in obs:
            ob.matrix_world = M @ ob.matrix_world
    return fn


# ================================================================ kar
def _bos(w, h):
    return np.zeros((h * HD, w * HD, 4), np.float32)


def _koy(a, x, y, renk, alfa):
    """HD piksel (x, y) — sprite sol ustu (0,0)."""
    if 0 <= y < a.shape[0] and 0 <= x < a.shape[1]:
        c = S.rgb(renk)
        al = min(1.0, a[y, x, 3] + alfa)
        a[y, x, :3] = c
        a[y, x, 3] = al


def kar_b():
    """2x2 logic blok yerine simetrik kristal (tuval 4x4 logic, merkez 2,2).
    Dikey/yatay kollar + capraz kisa kollar: 8x8 HD'de okunakli tek sekil."""
    a = _bos(4, 4)
    c = 3.5                                            # HD merkez (0..7)
    for d in (-1, 1):
        for s in range(1, 4):
            al = 1.0 if s < 3 else 0.7
            _koy(a, int(c + 0.5), int(c + 0.5 + d * s), "#ffffff", al)
            _koy(a, int(c + 0.5 + d * s), int(c + 0.5), "#ffffff", al)
        for e in (-1, 1):
            _koy(a, int(c + 0.5 + d * 2), int(c + 0.5 + e * 2), "#dceaff", 0.62)
            _koy(a, int(c + 0.5 + d), int(c + 0.5 + e), "#eef6ff", 0.85)
    _koy(a, 3, 3, "#ffffff", 1.0)
    _koy(a, 4, 3, "#ffffff", 1.0)
    _koy(a, 3, 4, "#ffffff", 1.0)
    _koy(a, 4, 4, "#ffffff", 1.0)
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


def kar_k():
    """1 logic px -> 2x2 HD cekirdek + yumusak kose."""
    a = _bos(2, 2)
    for x in range(4):
        for y in range(4):
            d = math.hypot(x - 1.5, y - 1.5)
            _koy(a, x, y, "#f2f8ff", max(0.0, 0.95 - d * 0.42))
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


# ================================================================ cam damlasi
def damla(rx, ry):
    """art.js: ell(x, y, rx, ry, '#cfe4f2') + tepede beyaz px + solda #eaf6ff.
    HD: ayni siluet, icinde kirilma (ust koyu, alt parlak) ve tepe isigi."""
    w, h = rx * 2 + 2, ry * 2 + 2

    def fn():
        a = _bos(w, h)
        yy, xx = np.mgrid[0:h * HD, 0:w * HD].astype(np.float32) + 0.5
        X = xx / HD - (rx + 1.0)                       # merkez
        Y = yy / HD - (ry + 1.0)
        R = (X / rx) ** 2 + (Y / ry) ** 2
        ic = np.clip((1.0 - R) * 3.2, 0, 1)
        # cam damlasi: ustte manzara koyu, altta parlak (mercek)
        ton = 0.42 + 0.58 * np.clip((Y / ry + 0.45) * 1.1, 0, 1)
        col = np.zeros(a.shape, np.float32)
        c0, c1 = S.rgb("#9fc3da"), S.rgb("#e7f5ff")
        for k in range(3):
            col[..., k] = c0[k] + (c1[k] - c0[k]) * ton
        # tepe isigi
        par = np.clip(1.0 - ((X + rx * 0.3) ** 2 / max(0.4, rx * 0.5) + (Y + ry * 0.45) ** 2 / max(0.4, ry * 0.5)), 0, 1)
        for k in range(3):
            col[..., k] = col[..., k] + (1.0 - col[..., k]) * par * 0.9
        a[..., :3] = col[..., :3]
        a[..., 3] = ic * 0.78
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


def damla_k():
    a = _bos(1, 1)
    for x in range(2):
        for y in range(2):
            _koy(a, x, y, "#dff0fa", 0.72 if (x + y) % 2 == 0 else 0.6)
    return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)


# ================================================================ kiragi
GW = 264


def kirag(ust):
    w, h = GW, 10 if ust else 8

    def fn():
        a = _bos(w, h)
        H = h * HD
        for X in range(w * HD):
            b = X / float(HD)
            if ust:
                env = 3.0 + round(math.sin(b * 0.21) * 2.0 + math.sin(b * 0.07) * 2.5)
            else:
                env = 2.0 + round(math.sin(b * 0.17 + 2.0) * 1.8)
            env = max(0.0, env) + 0.5 * hash1(b * 1.7) + 0.4 * math.sin(b * 1.3)
            iyne = env + 1.1 * max(0.0, hash1(b * 0.53) - 0.62) * 3.0
            for j in range(H):
                d = (j / float(HD)) if ust else (h - j / float(HD))
                if d > iyne:
                    continue
                # kenarda yogun, uca dogru seyrelen kristal
                t = 1.0 - d / max(0.6, iyne)
                alfa = 0.34 * (0.55 + 0.45 * t)
                if d < 1.2:                            # cam kenarinda yogun bant
                    alfa = 0.40
                if d > env:                            # iyne ucu: seyrek
                    alfa *= 0.30 + 0.45 * (hash1(b * 3.1 + d) > 0.5)
                if hash1(b * 9.7 + d * 4.3) > 0.93:    # parilti
                    alfa = min(0.55, alfa * 1.9)
                _koy(a, X, j, "#e8f3ff", alfa)
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


# ================================================================ kayit
for _r in range(1, 6):
    parca("para_a_%d" % _r, (-7, -8, 14, 14), para(1, _r), cizgi="#4a300a", cizgi_alfa=120)
    parca("para_g_%d" % _r, (-7, -8, 14, 14), para(0, _r), cizgi="#3c3c3c", cizgi_alfa=110)
parca("kar_b", (-1, -1, 4, 4), kar_b, tur="np")
parca("kar_k", (0, 0, 2, 2), kar_k, tur="np")
for _rx, _ry in ((1, 1), (1, 2), (2, 2), (2, 3)):
    parca("damla_%d_%d" % (_rx, _ry), (-_rx - 1, -_ry - 1, _rx * 2 + 2, _ry * 2 + 2), damla(_rx, _ry), tur="np")
parca("damla_k", (0, 0, 1, 1), damla_k, tur="np")
parca("kirag_ust", (0, 0, GW, 10), kirag(True), tur="np")
parca("kirag_alt", (0, 0, GW, 8), kirag(False), tur="np")


# ================================================================ parcaciklar (core.js psDraw)
# duman_<R>: yumusak buhar/duman topu, R = HD piksel yaricapi (2..12). Oyunda
#            renk + alfa modulate (eski: sert disk).
# parilti_<R>: dort kollu yildiz parlamasi + yumusak merkez (eski: 1 px arti).
def duman(R):
    s = int(math.ceil(1.35 * R / 2.0)) + 1          # yari tuval (mantik px)

    def fn():
        n = s * 2 * HD
        a = np.zeros((n, n, 4), np.float32)
        yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
        d = np.hypot(xx - n / 2.0, yy - n / 2.0) / float(R)
        t = np.clip((1.3 - d) / 0.75, 0, 1)
        al = t * t * (3 - 2 * t)                       # smoothstep
        # hafif topaklik: kenar dalgali (buhar)
        aci = np.arctan2(yy - n / 2.0, xx - n / 2.0)
        al *= np.clip(1.0 - 0.18 * np.clip(d - 0.6, 0, 1) * (0.5 + 0.5 * np.sin(aci * 3 + R)), 0, 1)
        a[..., :3] = 1.0
        a[..., 3] = al
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn, s


def parilti(R):
    s = int(math.ceil(R / 2.0)) + 1

    def fn():
        n = s * 2 * HD
        a = np.zeros((n, n, 4), np.float32)
        yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
        dx, dy = np.abs(xx - n / 2.0), np.abs(yy - n / 2.0)
        # piksel sanatina uygun KESKIN kollar: 1 HD px kalin (merkeze yakin 2 px),
        # alfa uca dogru kademeli azalir
        kal_y = np.where(dy < R * 0.4, 1.0, 0.5)
        kal_x = np.where(dx < R * 0.4, 1.0, 0.5)
        kol_d = (dx <= kal_y) * np.clip(1.15 - dy / (R + 0.5), 0, 1)
        kol_y = (dy <= kal_x) * np.clip(1.15 - dx / (R + 0.5), 0, 1)
        cap = (np.abs(dx - dy) <= 0.5) * ((dx + dy) <= R * 0.75) * 0.55
        mer = ((dx <= 1.0) & (dy <= 1.0)) * 1.0
        al = np.clip(np.maximum.reduce([kol_d, kol_y, cap, mer]), 0, 1)
        al = np.round(al * 4.0) / 4.0                  # 4 kademeli alfa (yumusak degil)
        a[..., :3] = 1.0
        a[..., 3] = al
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn, s


for _R in range(2, 13):
    _fn, _s = duman(_R)
    parca("duman_%d" % _R, (-_s, -_s, _s * 2, _s * 2), _fn, tur="np")
for _R in range(2, 9):
    _fn, _s = parilti(_R)
    parca("parilti_%d" % _R, (-_s, -_s, _s * 2, _s * 2), _fn, tur="np")


# ================================================================ izgara korlari (art.js drawGrill)
# eski: 2x2 turuncu kare + 1 px acik kose, alfa yanip soner. HD: duzensiz,
# catlakli, merkezi sari-sicak kor (3 bicim); hale icin duman sprite'i tintlenir.
def kor(v):
    def fn():
        n = 3 * HD
        a = np.zeros((n, n, 4), np.float32)
        yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
        rng = np.random.default_rng(31 + v)
        cx, cy = n / 2.0 + rng.uniform(-0.4, 0.4), n / 2.0 + rng.uniform(-0.4, 0.4)
        d = np.hypot((xx - cx) / (1.0 + 0.25 * v), (yy - cy) / (1.2 - 0.1 * v))
        sekil = d < 2.6 + rng.random((n, n)) * 0.5
        sicak = np.clip(1.0 - d / 2.6, 0, 1)
        c0, c1, c2 = S.rgb("#8a220a"), S.rgb("#ff6a1a"), S.rgb("#ffd070")
        col = np.where((sicak > 0.55)[..., None], c2, np.where((sicak > 0.22)[..., None], c1, c0))
        catlak = (rng.random((n, n)) > 0.8) & (sicak < 0.55)
        col = np.where(catlak[..., None], S.rgb("#3a0e04"), col)
        a[..., :3] = col
        a[..., 3] = sekil * 1.0
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


for _v in range(3):
    parca("kor_%d" % _v, (-1, -1, 3, 3), kor(_v), tur="np")


# ================================================================ isik huzmesi (prolog sahneleri)
# eski: 8 (ya da 6) px genis, 150 px boy duz dikdortgen, alfa ~.07. HD: kenarlari
# yumusak (gauss), ustte guclu asagi dogru sonen huzme; oyunda alfa carpilir.
def huzme(gen):
    def fn():
        w, h = (gen + 6) * HD, 150 * HD
        a = np.zeros((h, w, 4), np.float32)
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32) + 0.5
        dx = (xx - w / 2.0) / (gen * HD * 0.5)
        yatay = np.exp(-dx * dx * 1.6)
        v = yy / h
        dikey = np.clip(v / 0.06, 0, 1) * (1.0 - 0.65 * v)
        a[..., :3] = 1.0
        a[..., 3] = np.clip(yatay * dikey, 0, 1)
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


for _g in (6, 8):
    parca("huzme_%d" % _g, (-3, 0, _g + 6, 150), huzme(_g), tur="np")


def uret(ad):
    (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, tur = PARCALAR[ad]
    yol = os.path.join(OUT, ad + ".png")
    if tur == "np":
        px.reset()
        return px.write_png(fn(), yol)
    D.sahne(gx0, gy0, w, h, 1.0)
    S._MAT.clear()
    fn()
    # para ekran duzleminde: egme (shear) UYGULANMAZ
    px.render(yol)
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
    print("EFEKT_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
