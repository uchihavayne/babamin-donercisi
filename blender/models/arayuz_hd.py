"""ARAYUZ: PANEL, DUGME, HUD KUTULARI, SIPARIS BALONU — remake HD.

    blender --background --factory-startup --python blender/models/arayuz_hd.py [-- ad ...]
    python blender/hd_atlas.py arayuz_hd arayuz

ui.js panel() / button() / drawHUD() / drawOrderBubble() her ekranda var.
Tum parcalarin capasi SOL UST kose (oyundaki f_rrect(x, y, w, h) ile ayni yer).
9 DILIM olanlar (panel, baslik, dugme_*, balon*, para_plaka): koseler birebir,
kenarlar esnetilir — dilim kosesi panel 12, digerleri 6 oyun pikseli.
  panel        40x40 cerceve halkasi (ui5/ui4/ui1/ui0 pah), ORTASI BOS
  panel_ic     64x64 tekrarlanabilir krem kagit (panel ici dolgusu)
  baslik       40x13 kirmizi baslik levhasi
  dugme_govde  40x24 notr govde (oyun c2 ile modulate), dugme_yuz 40x22 (c1)
  balon[_acil] 40x40 siparis balonu, kuyruk[_acil] 12x8 alt sivri uc
  gun_kutu[_k] 30x26 / 30x16 takvim blogu, sure_kutu[_k] 42x20 / 42x16 kasa
  para_plaka   40x16 koyu saydam plaka + altin kenar, mola_dugme 18x16
"""
import sys, os, math, json
import bpy
import numpy as np

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import durum_hd as D
import sokak_arka_hd as S

OUT = os.path.join(_HERE, "out", "arayuz_hd")
HD = 2
PARCALAR, KOKEN = {}, {}
UI = {"ui0": "#fdf3dd", "ui1": "#e5cfa4", "ui2": "#b99a68", "ui3": "#7d603a",
      "ui4": "#4a3722", "ui5": "#2b1f14", "red1": "#c33c2c", "red2": "#96271c"}


def parca(ad, w, h, fn, tur="3b"):
    """Capa sol ust kose: tuval (0, 0, w, h)."""
    PARCALAR[ad] = ((0, 0, w, h), fn, tur)
    KOKEN[ad] = (0, 0)


def cel(ad, renk, f=(0.55, 0.8, 1.0, 1.18)):
    """Tek renkten dort kademeli cel: pahlar isigi yakalasin."""
    return I.cel(ad, [S.hexmul(renk, f[0]), S.hexmul(renk, f[1]), renk, S.hexmul(renk, f[3])],
                 [0, .34, .62, .9])


def levha(ad, w, h, r, kw, kh, y, derin, bevel, mat, dx=0.0, dy=0.0, bev_mod=0.0):
    """kw x kh tuvalinin ORTASINA oturan yuvarlak levha (dx, dy kaydirir)."""
    ob = L.levha(ad, w, h, r, kw / 2.0 + dx, -kh / 2.0 - dy, y, derin, bevel, mat)
    if bev_mod:
        m = ob.modifiers.new("bev", "BEVEL")
        m.width = bev_mod
        m.segments = 2
        m.limit_method = "ANGLE"
    return ob


# ================================================================ panel cercevesi
def panel():
    """Ic ice dort halka: disi koyu (ui5), sonra ui4, ui1 ve krem ic dudak.
    Ortasi bos — dolgusu panel_ic dokusu."""
    W = 40.0
    kat = [(W, 4.0, 1.0, UI["ui5"], 0.0, 0.2),
           (W - 2.0, 3.6, 1.0, UI["ui4"], 0.6, 0.42),
           (W - 4.0, 3.2, 1.0, UI["ui1"], 1.1, 0.46),
           (W - 6.0, 3.0, 1.4, UI["ui0"], 1.6, 0.52)]
    for i, (w, r, kal, renk, y, bev) in enumerate(kat):
        ob = L.cerceve("kat%d" % i, w, w, r, kal, W / 2.0, -W / 2.0, -y, 0.9 + y * 0.2,
                       cel("Pnl%d" % i, renk))
        m = ob.modifiers.new("bev", "BEVEL")
        m.width = bev
        m.segments = 2
        m.limit_method = "ANGLE"


def panel_ic():
    """64x64 tekrarlanabilir krem kagit: ince lif + seyrek benek."""
    W = 64

    def fn():
        n = W * HD
        a = np.zeros((n, n, 4), np.float32)
        yy, xx = np.mgrid[0:n, 0:n].astype(np.float32)
        col = np.repeat(S.rgb(UI["ui0"])[None, None, :], n, 0).repeat(n, 1)
        lif = (np.sin(xx * (2 * math.pi * 8 / n)) * 0.4 + np.sin(yy * (2 * math.pi * 5 / n) + 1.3) * 0.6)
        col *= (1.0 + lif[..., None] * 0.009)
        rng = np.random.default_rng(7)
        b = rng.random((n, n))
        col *= (1.0 - (b > 0.9955)[..., None] * 0.085)
        col *= (1.0 + (b < 0.003)[..., None] * 0.03)
        a[..., :3] = np.clip(col, 0, 1)
        a[..., 3] = 1.0
        return (a * 255 + 0.5).astype(np.uint8)
    return fn


# ================================================================ baslik levhasi
def baslik():
    levha("dis", 40.0, 13.0, 3.0, 40, 13, 0.0, 0.8, 0.18, cel("BasDis", UI["red2"], (0.5, 0.75, 1.0, 1.1)))
    levha("yuz", 38.0, 11.0, 3.0, 40, 13, -0.7, 1.1, 0.7, cel("BasYuz", UI["red1"]), bev_mod=0.7)


# ================================================================ dugme
def dugme_govde():
    """Notr govde: oyun c2 (koyu ton) ile modulate ediyor."""
    levha("govde", 40.0, 24.0, 3.0, 40, 24, 0.0, 1.0, 0.3,
          cel("DgGovde", "#ffffff", (0.58, 0.82, 0.96, 1.0)), bev_mod=0.55)


def dugme_yuz():
    """Notr yuz (c1 modulate): ust kenar parlak, asagi dogru hafif koyulasan pah."""
    levha("yuz", 40.0, 22.0, 3.0, 40, 22, -0.8, 1.2, 0.9,
          cel("DgYuz", "#ffffff", (0.66, 0.88, 0.98, 1.0)), bev_mod=0.9)


# ================================================================ siparis balonu
def balon(acil):
    """Balon cercevesi: dis halka duz koyu (ui4) / acil kirmizi, ic krem yuz."""
    def fn():
        dis = "#e8483a" if acil else UI["ui4"]
        ic = "#f7ded6" if acil else UI["ui0"]
        levha("dis", 40.0, 40.0, 4.0, 40, 40, 0.6, 0.7, 0.2, px.flat("BlnD%d" % acil, dis))
        levha("ic", 37.6, 37.6, 3.2, 40, 40, -0.9, 1.1, 0.6,
              cel("BlnI%d" % acil, ic, (0.76, 0.92, 1.0, 1.06)), bev_mod=0.6)
    return fn


def kuyruk(acil):
    """Balonun alt ucu: capa sol ust (tuval 12x8), ucu asagi bakar."""
    def fn():
        dis = "#e8483a" if acil else UI["ui4"]
        ic = "#f7ded6" if acil else UI["ui0"]
        L.cokgen("dis", [(1.4, -0.6), (10.2, -0.6), (4.6, -7.2)], 0.0, 0.0, 0.6, 0.7, 0.14,
                 px.flat("KyrD%d" % acil, dis))
        L.cokgen("ic", [(2.4, -1.4), (9.0, -1.4), (4.8, -6.0)], 0.0, 0.0, -0.9, 1.0, 0.2,
                 cel("KyrI%d" % acil, ic, (0.8, 0.93, 1.0, 1.05)))
    return fn


# ================================================================ HUD kutulari
def gun_kutu(kompakt):
    """Takvim blogu: krem yaprak + kirmizi baslik + ustte iki spiral halka."""
    def fn():
        H = 16.0 if kompakt else 26.0
        levha("kenar", 30.0, H, 3.0, 30, H, 0.4, 0.7, 0.2, cel("GunKen", "#8a7a60", (0.45, 0.7, 1.0, 1.1)))
        levha("yaprak", 28.4, H - 1.4, 2.6, 30, H, -0.5, 1.0, 0.45,
              cel("GunYap", "#f2ece0", (0.72, 0.9, 1.0, 1.05)), bev_mod=0.45)
        bas = 6.0 if kompakt else 8.0
        levha("baslik", 28.4, bas, 2.4, 30, H, -0.9, 1.0, 0.4,
              cel("GunBas", "#c0281c", (0.55, 0.8, 1.0, 1.15)), dy=-(H - bas) / 2.0 + 0.7)
        if not kompakt:
            for hx in (6.0, 23.0):
                L.halka("halka", 1.4, 1.8, 0.5, hx, -1.0, -1.4, cel("GunHal", "#9aa3ab", (0.45, 0.75, 1.0, 1.25)))
    return fn


def sure_kutu(kompakt):
    """Ahsap kasa icinde karanlik gosterge (sure)."""
    def fn():
        H = 16.0 if kompakt else 20.0
        levha("kasa", 42.0, H, 3.0, 42, H, 0.0, 0.8, 0.22, cel("SurKasa", "#7a5230", (0.5, 0.76, 1.0, 1.12)))
        levha("ic", 40.0, H - 2.0, 3.0, 42, H, -0.6, 0.9, 0.4, cel("SurIc", "#9c6b3f", (0.6, 0.82, 1.0, 1.1)))
        levha("ekran", 36.0, H - 6.0, 2.0, 42, H, -1.3, 0.9, 0.3, cel("SurEkr", "#241a14", (0.7, 0.9, 1.0, 1.5)))
    return fn


def para_plaka():
    """Koyu saydam plaka + altin kenar (9 dilim: genislik paraya gore)."""
    levha("plaka", 40.0, 16.0, 4.0, 40, 16, 0.0, 0.8, 0.3, px.flat_a("ParaPlk", "#1e1410", 0.78))
    ob = L.cerceve("kenar", 40.0, 16.0, 4.0, 0.8, 20.0, -8.0, -0.6, 0.9, px.flat_a("ParaKen", "#ffdc8c", 0.45))
    m = ob.modifiers.new("bev", "BEVEL")
    m.width = 0.25
    m.segments = 2
    m.limit_method = "ANGLE"


def mola_dugme():
    """Mola dugmesi: koyu yuvarlak plaka + iki krem cubuk."""
    levha("plaka", 18.0, 16.0, 3.0, 18, 16, 0.0, 0.8, 0.3, px.flat_a("MolaPlk", "#1e1410", 0.75))
    for dx in (-2.5, 2.5):
        levha("cubuk", 3.0, 8.0, 0.6, 18, 16, -0.8, 0.9, 0.25,
              cel("MolaCub", UI["ui0"], (0.6, 0.85, 1.0, 1.1)), dx=dx)


# ================================================================ kayit
parca("panel", 40, 40, panel)
parca("panel_ic", 64, 64, panel_ic(), tur="np")
parca("baslik", 40, 13, baslik)
parca("dugme_govde", 40, 24, dugme_govde)
parca("dugme_yuz", 40, 22, dugme_yuz)
parca("balon", 40, 40, balon(0))
parca("balon_acil", 40, 40, balon(1))
parca("kuyruk", 12, 8, kuyruk(0))
parca("kuyruk_acil", 12, 8, kuyruk(1))
parca("gun_kutu", 30, 26, gun_kutu(0))
parca("gun_kutu_k", 30, 16, gun_kutu(1))
parca("sure_kutu", 42, 20, sure_kutu(0))
parca("sure_kutu_k", 42, 16, sure_kutu(1))
parca("para_plaka", 40, 16, para_plaka)
parca("mola_dugme", 18, 16, mola_dugme)


# ================================================================ sabir tupu (musteri yaninda)
def sabir_tup():
    """Eski: 7x26 koyu yari saydam kutu. HD: kapsul cam tup, ici koyu, metal
    kapakli (ust/alt). Sivi oyunda rect_hd ile doluyor."""
    levha("cam", 7.0, 26.0, 3.2, 7, 26, 0.0, 0.8, 0.25, px.flat_a("TupIc", "#140e0c", 0.72))
    ob = L.cerceve("kenar", 7.0, 26.0, 3.2, 0.7, 3.5, -13.0, -0.5, 0.9, I.cel("TupKen", ["#2a211c", "#5a4a40", "#8a7a6e"], [0, .5, .9]))
    m = ob.modifiers.new("bev", "BEVEL")
    m.width = 0.2
    m.segments = 2
    m.limit_method = "ANGLE"


def sabir_parilti():
    """Tupun onundeki cam parlamasi (sivinin USTUNE cizilir): solda ince
    dikey isik, sagda koyu kenar golgesi."""
    L.kutu("isik", 1.6, 2.2, -21.5, -4.0, -1.4, -1.3, px.flat_a("TupIsik", "#ffffff", 0.55))
    L.kutu("isik2", 1.6, 2.2, -23.2, -22.2, -1.4, -1.3, px.flat_a("TupIsik2", "#ffffff", 0.35))
    L.kutu("golge", 4.6, 5.2, -22.5, -3.5, -1.4, -1.3, px.flat_a("TupGolge", "#000000", 0.18))


parca("sabir_tup", 7, 26, sabir_tup)
parca("sabir_parilti", 7, 26, sabir_parilti)


# ================================================================ basarim rozeti (ui.js bsRozet)
def _yuvarlak_kare_mesafe(n, r):
    """n x n HD tuvalde yuvarlak kose kareye isaretli mesafe (icerisi negatif)."""
    yy, xx = np.mgrid[0:n, 0:n].astype(np.float32) + 0.5
    c = n / 2.0
    qx = np.abs(xx - c) - (c - r)
    qy = np.abs(yy - c) - (c - r)
    dis = np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - r
    return dis, xx - c, yy - c


def rozet_halka():
    """16x16 notr metal halka (oyunda kademe rengiyle modulate). Piksel pah:
    dis 1 HD px koyu kontur, 3 px egimli yuz (sol-ustten isik), ic 1 px golge."""
    def fn():
        n = 16 * HD
        a = np.zeros((n, n, 4), np.float32)
        d, dx, dy = _yuvarlak_kare_mesafe(n, 3.0 * HD)
        ic = -d
        halka = (ic >= 0) & (ic < 5.0)
        # yuz normali ~ merkezden disa; isik sol-ust
        nx = dx / np.maximum(1e-3, np.hypot(dx, dy))
        ny = dy / np.maximum(1e-3, np.hypot(dx, dy))
        isik = np.clip(0.72 - 0.38 * (nx * 0.7 + ny * 0.7), 0.3, 1.0)
        deger = np.where(ic < 1.0, 0.32, np.where(ic >= 4.0, 0.45, isik))
        # parlak cizgi: yuzun ustunde 1 px
        deger = np.where((ic >= 1.0) & (ic < 2.0) & (ny < -0.3), 1.0, deger)
        a[..., 0] = a[..., 1] = a[..., 2] = deger
        a[..., 3] = halka * 1.0
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


def rozet_taban():
    """Rozetin koyu ic yuvasi: ustte ic golge, altta 1 px isik (cukur hissi)."""
    def fn():
        n = 16 * HD
        a = np.zeros((n, n, 4), np.float32)
        d, dx, dy = _yuvarlak_kare_mesafe(n, 3.0 * HD)
        ic = -d
        dolu = ic >= 3.0
        col = np.repeat(S.rgb("#3a3026")[None, None, :], n, 0).repeat(n, 1)
        yy = np.mgrid[0:n, 0:n][0].astype(np.float32)
        ust_golge = np.clip(1.0 - (yy - 4.0) / 4.0, 0, 1) * 0.35
        col *= (1.0 - ust_golge)[..., None]
        alt_isik = ((ic >= 3.0) & (ic < 4.0) & (dy > 4.0))
        col = np.where(alt_isik[..., None], S.rgb("#5a4a3a"), col)
        a[..., :3] = col
        a[..., 3] = dolu * 1.0
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


parca("rozet_halka", 16, 16, rozet_halka(), tur="np")
parca("rozet_taban", 16, 16, rozet_taban(), tur="np")


def bildirim_plaka():
    """Basarim bildirimi plakasi (9 dilim, 40x30): altin pahli kenar + koyu
    kahve yuz, ustte ic golge. Eski: #4a3a1e / #2b2118 katmanlari + au0 kontur."""
    def fn():
        w, h = 40 * HD, 30 * HD
        a = np.zeros((h, w, 4), np.float32)
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32) + 0.5
        r = 4.0 * HD
        cx, cy = w / 2.0, h / 2.0
        qx = np.abs(xx - cx) - (cx - r)
        qy = np.abs(yy - cy) - (cy - r)
        d = np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - r
        ic = -d
        dolu = ic >= 0
        yuz = np.repeat(S.rgb("#2b2118")[None, None, :], h, 0).repeat(w, 1)
        yuz *= (1.0 - np.clip(1.0 - (yy - 5.0) / 6.0, 0, 1) * 0.3)[..., None]
        altin_acik, altin, altin_koyu = S.rgb("#fff2a8"), S.rgb("#e0a41f"), S.rgb("#8a5a12")
        ust = (yy < cy)
        kenar = np.where(ust[..., None], altin_acik, altin_koyu)
        col = np.where((ic < 1.0)[..., None], S.rgb("#1e140c"),
              np.where((ic < 2.0)[..., None], kenar,
              np.where((ic < 3.0)[..., None], altin,
              np.where((ic < 4.0)[..., None], S.rgb("#4a3a1e"), yuz))))
        a[..., :3] = col
        a[..., 3] = dolu * 1.0
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


parca("bildirim_plaka", 40, 30, bildirim_plaka(), tur="np")


def koyu_kart():
    """Dukkan yukseltme karti (9 dilim, 40x30): koyu kahve yuz, ustte 1 px
    isik cizgisi ve ic golge, alt kenarda koyu dudak. Eski: #1d1611 / #2b2119
    katmanlari + #4a3a2c cizgi. Kontur (altin/gri) oyunda ayrica ciziliyor."""
    def fn():
        w, h = 40 * HD, 30 * HD
        a = np.zeros((h, w, 4), np.float32)
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32) + 0.5
        r = 4.0 * HD
        cx, cy = w / 2.0, h / 2.0
        qx = np.abs(xx - cx) - (cx - r)
        qy = np.abs(yy - cy) - (cy - r)
        d = np.hypot(np.maximum(qx, 0), np.maximum(qy, 0)) + np.minimum(np.maximum(qx, qy), 0) - r
        ic = -d
        yuz = np.repeat(S.rgb("#2b2119")[None, None, :], h, 0).repeat(w, 1)
        yuz *= (1.0 - np.clip(1.0 - (yy - 3.0) / 8.0, 0, 1) * 0.18)[..., None]
        yuz *= (1.0 + np.clip((yy - (h - 14.0)) / 10.0, 0, 1) * 0.06)[..., None]
        col = np.where((ic < 1.5)[..., None], S.rgb("#1d1611"), yuz)
        col = np.where(((ic >= 1.5) & (ic < 2.5) & (yy < cy))[..., None], S.rgb("#4a3a2c"), col)
        col = np.where(((yy >= h - 4.0) & (ic >= 1.5))[..., None], S.rgb("#1d1611"), col)
        a[..., :3] = col
        a[..., 3] = (ic >= 0) * 1.0
        return (np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8)
    return fn


parca("koyu_kart", 40, 30, koyu_kart(), tur="np")


def uret(ad):
    (gx0, gy0, w, h), fn, tur = PARCALAR[ad]
    yol = os.path.join(OUT, ad + ".png")
    if tur == "np":
        px.reset()
        return px.write_png(fn(), yol)
    D.sahne(gx0, gy0, w, h, 1.0)
    S._MAT.clear()
    fn()
    px.render(yol)                                     # ekran duzlemi: egme yok
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = [a for a in PARCALAR if not argv or any(a.startswith(x) for x in argv)]
    for ad in adlar:
        uret(ad)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR), "kokenler": {k: list(v) for k, v in KOKEN.items()},
                   "kirpma": False}, fp, indent=1)
    print("ARAYUZ_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
