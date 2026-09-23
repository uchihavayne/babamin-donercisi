"""TEZGAH GOVDESI — remake HD (tek parca, 4 renk secenegi).

    blender --background --factory-startup --python blender/models/govde_hd.py [-- 0 1 2 3]
    python blender/hd_atlas.py govde_hd govde

Oyundaki karsiligi: art.js drawCounterRaw + drawCounterProps (oyunda bir kez
CLAYER tuvaline pisiriliyor). Musteri tarafindaki tas pervaz (ledgeY 148..159),
calisma yuzeyi (surfY 159..lipY 247; renk G.custom.counter -> COUNTER_PAL),
celik haznelar, lastik paspas, raf, ahsap kutuk, on dudak (247..258), pervaz
ustundeki pecetelik / tuzluk / biberlik / siseler.
Sol uc yuvarlatmasi ve sagdaki tas kemer kesigi (archR, hash1) orijinal
formulle PNG'ye maske olarak uygulanir.

Parca: govde_<renk>   capa (0, 0) = ekranin sol-ustu (parca kendi yerinde)
"""
import sys, os, math, json
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T

OUT = os.path.join(_HERE, "out", "govde_hd")
HD = 2
W = 480
X0 = 44
LY, LH = 148, 11
SURF, LIP, FLOOR = 159, 247, 258
GX0, GY0, GW, GH = 44, 132, 436, 126
K = 0.5

PAL = [{"base": "#c3c9d0", "hi": "#ffffff", "lo": "#2f343b", "lip": "#aeb5be", "edge": "#f6f8fa"},
       {"base": "#a8bccd", "hi": "#e6f2fb", "lo": "#26384a", "lip": "#8fa6bb", "edge": "#dceaf6"},
       {"base": "#c9a271", "hi": "#f6e2c0", "lo": "#4a3520", "lip": "#a5794a", "edge": "#e8c99a"},
       {"base": "#c99a6a", "hi": "#ffdcae", "lo": "#5a3a1e", "lip": "#a87a44", "edge": "#f0c88e"}]
MT = {"mt0": "#f2f4f6", "mt1": "#d3d8de", "mt2": "#aeb5be", "mt3": "#878e99", "mt4": "#5f6672", "mt5": "#41474f"}
ez, onkutu, torna, hexmul = T.ez, T.onkutu, T.torna, T.hexmul
cel = I.cel


def hash1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


def archR(y):
    q = math.floor(y / 11.0)
    return W - (28 + math.floor(hash1(q * 5.1 + 40) * 9) + math.floor(10 * math.sin(y * 0.011 + 0.4) + 0.5))


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


def karis(a, b, t):
    ra, rb = rgb(a), rgb(b)
    return "#%02x%02x%02x" % tuple(int(round((x + (y - x) * t) * 255)) for x, y in zip(ra, rb))


def firca_malzeme(ad, renkler, uzama=(0.02, 1.0, 1.0), olcek=2.2, guc=0.10, eksen=1):
    """Fircalanmis yuzey: renk rampasi nesnenin uretilen koordinatinin bir
    ekseni boyunca (on -> arka), x yonunde uzatilmis gurultu ile kiriliyor.
    Emission: isiklandirmadan bagimsiz, eski cizimin dikey tonlamasi gibi."""
    mat = bpy.data.materials.new(ad)
    mat.use_nodes = True
    nt = mat.node_tree
    n, l = nt.nodes, nt.links
    n.clear()
    tc = n.new("ShaderNodeTexCoord")
    sep = n.new("ShaderNodeSeparateXYZ")
    l.new(tc.outputs["Generated"], sep.inputs[0])
    mp = n.new("ShaderNodeMapping")
    mp.inputs["Scale"].default_value = (uzama[0] * olcek * 100, uzama[1] * olcek * 100, uzama[2] * olcek * 100)
    l.new(tc.outputs["Generated"], mp.inputs[0])
    nz = n.new("ShaderNodeTexNoise")
    nz.inputs["Scale"].default_value = 1.0
    nz.inputs["Detail"].default_value = 4.0
    l.new(mp.outputs[0], nz.inputs["Vector"])
    sub = n.new("ShaderNodeMath"); sub.operation = "SUBTRACT"; sub.inputs[1].default_value = 0.5
    l.new(nz.outputs["Fac"], sub.inputs[0])
    mul = n.new("ShaderNodeMath"); mul.operation = "MULTIPLY"; mul.inputs[1].default_value = guc
    l.new(sub.outputs[0], mul.inputs[0])
    add = n.new("ShaderNodeMath"); add.operation = "ADD"
    l.new(sep.outputs[eksen], add.inputs[0])
    l.new(mul.outputs[0], add.inputs[1])
    ramp = n.new("ShaderNodeValToRGB")
    cr = ramp.color_ramp
    cr.interpolation = "CONSTANT"
    while len(cr.elements) > 1:
        cr.elements.remove(cr.elements[-1])
    cr.elements[0].position = 0.0
    cr.elements[0].color = px.hex_lin(renkler[0])
    for i in range(1, len(renkler)):
        e = cr.elements.new(i / len(renkler))
        e.color = px.hex_lin(renkler[i])
    l.new(add.outputs[0], ramp.inputs["Fac"])
    em = n.new("ShaderNodeEmission")
    l.new(ramp.outputs["Color"], em.inputs["Color"])
    out = n.new("ShaderNodeOutputMaterial")
    l.new(em.outputs[0], out.inputs["Surface"])
    return mat


def yuzey_renkleri(P):
    """Eski cizim: taban + ustte hi (.16'dan azalarak), altta lo (.10'a
    artarak). Uretilen koordinat y: 0 = on (ekranda alt), 1 = arka (ust)."""
    renk = []
    n = 10
    for i in range(n):
        u = i / (n - 1.0)          # 0 on/alt -> 1 arka/ust
        tt = 1.0 - u               # eski cizimdeki tt: ust 0, alt 1
        a = 0.16 * (1 - tt) - 0.10 * tt
        renk.append(karis(P["base"], P["hi"], a) if a > 0 else karis(P["base"], P["lo"], -a))
    return renk


def govde(ri):
    def fn():
        P = PAL[ri]
        # --- calisma yuzeyi
        D = (LIP - SURF) / K
        Ms = firca_malzeme("Yuzey", yuzey_renkleri(P), uzama=(0.012, 1.0, 1.0), olcek=2.4, guc=0.09)
        ob, zt = T.yatay_plaka("yuzey", X0 - 2, SURF, W - X0 + 4, LIP - SURF, 0.1, 2.0, Ms, K)
        T.ust_cizgi("kenar", X0, SURF + 0.4, W, SURF + 0.4, 0.8, zt, px.flat("Kenar", P["edge"]), K)
        T.ust_cizgi("dudak", X0, SURF + 1.2, W, SURF + 1.2, 0.7, zt, px.flat("KenarDudak", P["lip"]), K)
        # --- pervaz golgesi yuzeyde
        T.ust_poligon("pervaz_golge", [(X0, SURF), (W, SURF), (W, SURF + 4), (X0, SURF + 4)], zt, px.flat_a("PervazGolge", "#000000", 0.22), K, kal=0.06)
        # --- tas pervaz (musteri tarafi): one bakan yuvarlak burun
        yb = D                            # yuzeyin arka kenari
        Mp = cel("Pervaz", ["#6d5c40", "#96805a", "#b79f74", "#cbb68c", "#dcc79c", "#e9d6ab", "#f6e8c4"],
                 [0, .12, .26, .42, .6, .76, .88], noise=0.07, noise_scale=40)
        onkutu("pervaz", X0 - 2, W + 2, LY + 2, LY + LH - 2, yb, yb + 6, Mp, K)
        L.silindir("pervaz_burun_ust", 2.0, (X0 + W) / 2.0, yb + 0.6, ez(LY + 2.2, yb + 0.6, K), W - X0 + 4, Mp, seg=16, eksen="X")
        L.silindir("pervaz_burun_alt", 2.0, (X0 + W) / 2.0, yb + 0.6, ez(LY + LH - 2.2, yb + 0.6, K), W - X0 + 4, Mp, seg=16, eksen="X")
        # --- celik haznelar
        def hazne(ad, x, y, w, h):
            zz = zt + 0.02
            T.ust_poligon(ad, [(x, y), (x + w, y), (x + w, y + h), (x, y + h)], zz, cel(ad + "Dis", [MT["mt5"], MT["mt4"], MT["mt3"], MT["mt4"]], [0, .3, .6, .95]), K, kal=0.5)
            zi = zz + 0.5
            T.ust_poligon(ad + "_ic", [(x + 2, y + 2), (x + w - 2, y + 2), (x + w - 2, y + h - 2), (x + 2, y + h - 2)], zi,
                          T.px.flat(ad + "Ic1", "#5a616a") if hasattr(T, "px") else px.flat(ad + "Ic1", "#5a616a"), K, kal=0.05)
            T.ust_poligon(ad + "_ic2", [(x + 3, y + 3), (x + w - 3, y + 3), (x + w - 3, y + h - 3), (x + 3, y + h - 3)], zi + 0.05,
                          firca_malzeme(ad + "Taban", ["#454c54", "#4c535b", "#4c535b", "#535a62"], uzama=(0.02, 1, 1), olcek=3.0, guc=0.25), K, kal=0.05)
            T.ust_poligon(ad + "_golge", [(x + 3, y + 3), (x + w - 3, y + 3), (x + w - 3, y + 6), (x + 3, y + 6)], zi + 0.1,
                          px.flat_a(ad + "Golge", "#000000", 0.3), K, kal=0.02)
            for (gx0, gy0, gx1, gy1, renk, kal) in ((x, y + 0.5, x + w, y + 0.5, MT["mt0"], 1.0), (x + 1, y + 1.5, x + w - 1, y + 1.5, MT["mt2"], 1.0),
                                                    (x, y + h - 0.5, x + w, y + h - 0.5, MT["mt1"], 1.0), (x, y + h - 1.5, x + w, y + h - 1.5, MT["mt3"], 1.0),
                                                    (x + 0.5, y, x + 0.5, y + h, MT["mt2"], 1.0), (x + w - 0.5, y, x + w - 0.5, y + h, MT["mt3"], 1.0)):
                T.ust_cizgi(ad + "_hat", gx0, gy0, gx1, gy1, kal, zi + 0.12, px.flat(ad + renk, renk), K)
        hazne("hazneA", 52, 163, 176, 38)
        hazne("hazneB", 224, 158, 200, 40)
        # --- lastik paspas
        mx, my, mw, mh = 88, 197, 128, 48
        T.yatay_plaka("paspas_alt", mx, my + 1, mw, mh - 1, 3, 0.4, px.flat("PaspasAlt", "#2f3339"), K, z_ust=zt + 0.4)
        T.yatay_plaka("paspas", mx + 1, my, mw - 2, mh - 2, 3, 0.3, cel("Paspas", ["#30343a", "#383d44", "#3d424a", "#454a52"], [0, .3, .5, .8]), K, z_ust=zt + 0.7)
        Md = px.flat("PaspasNokta", "#30353c")
        for j in range(3, mh - 3, 4):
            for i in range(3, mw - 3, 4):
                ox = mx + i + (2 if (j // 4) & 1 else 0)
                T.ust_poligon("nokta", [(ox + 0.1, my + j + 0.1), (ox + 1.0, my + j + 0.1), (ox + 1.0, my + j + 0.9), (ox + 0.1, my + j + 0.9)], zt + 0.72, Md, K, kal=0.02)
        T.ust_cizgi("paspas_isik", mx + 3, my + 0.4, mx + mw - 3, my + 0.4, 0.8, zt + 0.72, px.flat("PaspasIsik", "#4e545d"), K)
        # --- raf (istasyonlarin altindaki celik tabla)
        sx, sy, sw, sh = 214, 197, 210, 48
        T.ust_poligon("raf", [(sx, sy), (sx + sw, sy), (sx + sw, sy + sh), (sx, sy + sh)], zt + 0.02, px.flat("RafKenar", MT["mt2"]), K, kal=0.4)
        T.ust_poligon("raf_ic", [(sx + 1, sy + 1), (sx + sw - 1, sy + 1), (sx + sw - 1, sy + sh - 1), (sx + 1, sy + sh - 1)], zt + 0.44,
                      firca_malzeme("RafIc", [karis(MT["mt1"], "#ffffff", .06), MT["mt1"], MT["mt1"], karis(MT["mt1"], "#ffffff", .1)], uzama=(0.01, 1, 1), olcek=3.0, guc=0.35), K, kal=0.02)
        for (a, b, renk) in ((sy + 0.5, sy + 0.5, MT["mt0"]), (sy + sh - 1.5, sy + sh - 1.5, MT["mt3"]), (sy + sh - 0.5, sy + sh - 0.5, MT["mt4"])):
            T.ust_cizgi("raf_hat", sx, a, sx + sw, b, 1.0, zt + 0.47, px.flat("RafHat" + renk, renk), K)
        # --- ahsap kutuk (lavas yiginin altinda)
        kx, ky, kw, kh = 44, 197, 44, 48
        T.yatay_plaka("kutuk_alt", kx, ky, kw, kh, 3, 0.6, px.flat("KutukAlt", "#7a5230"), K, z_ust=zt + 0.6)
        T.yatay_plaka("kutuk", kx + 1, ky, kw - 2, kh - 2, 3, 0.3, cel("Kutuk", ["#7a5230", "#8f6236", "#a5713f", "#b07c48"], [0, .3, .5, .8], noise=0.1, noise_scale=30), K, z_ust=zt + 0.9)
        for bb in range(6):
            T.ust_cizgi("kutuk_hat", 47, 201 + bb * 7, 85, 201 + bb * 7 + (0.4 if bb % 2 else -0.3), 0.9, zt + 0.92, px.flat("KutukHat", "#8f6236"), K)
        T.ust_cizgi("kutuk_isik", 45, 197.4, 87, 197.4, 0.8, zt + 0.92, px.flat("KutukIsik", "#c08d55"), K)
        # --- on dudak (dikey): ustte kenar parlakligi, altta koyulasan pahli metal
        Ml = cel("Dudak", [MT["mt5"], MT["mt4"], MT["mt3"], P["lip"], karis(P["lip"], P["edge"], .5), P["edge"]],
                 [0, .18, .3, .45, .7, .9])
        onkutu("dudak", X0 - 2, W + 2, LIP + 2, FLOOR - 3, 0, 3, px.flat("DudakYuz", P["lip"]), K)
        L.silindir("dudak_ust", 1.6, (X0 + W) / 2.0, 0.2, ez(LIP + 1.4, 0.2, K), W - X0 + 4, Ml, seg=16, eksen="X")
        onkutu("dudak_alt1", X0 - 2, W + 2, FLOOR - 3, FLOOR - 2, -0.05, 3, px.flat("DudakAlt1", MT["mt3"]), K)
        onkutu("dudak_alt2", X0 - 2, W + 2, FLOOR - 2, FLOOR - 1, -0.05, 3, px.flat("DudakAlt2", MT["mt4"]), K)
        onkutu("dudak_alt3", X0 - 2, W + 2, FLOOR - 1, FLOOR, -0.05, 3, px.flat("DudakAlt3", MT["mt5"]), K)
        onkutu("dudak_oluk", X0 - 2, W + 2, LIP + 4, LIP + 4.6, -0.08, 3, px.flat("DudakOluk", "#9aa2ab"), K)
        import random
        r = random.Random(46)
        for k in range(46):
            x = X0 + math.floor(hash1(k * 5.1) * (W - X0))
            onkutu("cizik", x, x + 0.5, LIP + 2, FLOOR - 4, -0.1, 0, px.flat_a("Cizik", "#ffffff", 0.07), K)
        # --- pervaz ustundeki esyalar (drawCounterProps)
        yp = yb + 3.0
        zp = ez(LY, yp, K)
        def on_kutu(ad, x0, x1, g0, g1, mat, dy=0.0):
            onkutu(ad, x0, x1, g0, g1, yp - 1.5 + dy, yp + 1.5 + dy, mat, K)
        # pecetelik
        nx, ny = 398, LY - 9
        on_kutu("pecetelik", nx, nx + 14, ny, ny + 10, cel("Pecetelik", ["#6f777f", "#9aa3ab", "#c7ced5", "#e2e7eb"], [0, .3, .5, .8]))
        on_kutu("pecetelik_ic", nx + 1, nx + 13, ny + 1, ny + 9, px.flat("PecetelikIc", "#c7ced5"), dy=-0.1)
        for i in range(4):
            on_kutu("pecete", nx + 3 + i * 0.3, nx + 11 - i * 0.2, ny - 2 + i * 0.6, ny + 2, cel("Pecete", ["#d6d2c6", "#ebe7da", "#fdfaf0", "#ffffff"], [0, .3, .5, .8]), dy=0.4 * i)
        # tuzluk + biberlik
        for i in range(2):
            sx0, sy0 = 416 + i * 9, LY - 8
            gov = ("#e8e2d4", "#f6f2e6") if i else ("#d8cfbc", "#3a2a20")
            torna("tuz_cam", [(2.6, 0), (3.0, 1.0), (3.0, 8.0)], sx0 + 3, sy0 + 9, yp, 0.8, cel("Cam%d" % i, [hexmul(gov[0], .7), gov[0], karis(gov[0], "#ffffff", .4), "#ffffff"], [0, .3, .5, .85]), K)
            torna("tuz_ic", [(2.2, 0.8), (2.4, 6.5)], sx0 + 3, sy0 + 9, yp - 0.9, 0.8, px.flat("TuzIc%d" % i, gov[1]), K)
            torna("tuz_kapak", [(2.6, 8.0), (2.6, 10.2), (1.8, 11.0)], sx0 + 3, sy0 + 9, yp, 0.8, cel("TuzKap", ["#5f6672", "#8a939b", "#b3bac1", "#c7ced5"], [0, .3, .5, .8]), K)
        # siseler
        for bx, c0, c1 in ((48, "#c0281c", "#e2483a"), (56, "#f0e8d2", "#fffaf0")):
            by0 = LY - 13
            torna("sise", [(2.6, 0), (3.0, 0.8), (3.0, 9.0), (2.2, 10.0)], bx + 3, by0 + 13, yp, 0.8, cel("Sise" + c0, [hexmul(c0, .6), c0, c1, karis(c1, "#ffffff", .5)], [0, .3, .5, .85]), K)
            torna("sise_kapak", [(2.0, 10.0), (2.0, 13.0)], bx + 3, by0 + 13, yp, 0.8, cel("SiseKap", ["#2a2a2a", "#3a3a3a", "#4a4a4a", "#6a6a6a"], [0, .3, .5, .8]), K)
            torna("sise_uc", [(1.0, 13.0), (1.0, 15.0), (0.5, 15.4)], bx + 3, by0 + 13, yp, 0.8, px.flat("SiseUc", "#5a5a5a"), K)
    return fn


def maske(yol):
    """Sol uc yuvarlatmasi, sol kenar golgesi/isigi, sag kemer kesigi."""
    a = px.read_png(yol).astype("float32")
    import numpy as np
    H, Wd = a.shape[:2]

    def satir(y):
        return (y - GY0) * HD

    def sutun(x):
        return int(round((x - GX0) * HD))

    def bosalt(x0, x1, y):
        r0 = satir(y)
        if r0 < 0 or r0 >= H:
            return
        a[r0:r0 + HD, max(0, sutun(x0)):max(0, min(Wd, sutun(x1))), 3] = 0

    def boya(x0, x1, y0, y1, renk, alfa):
        r0, r1 = max(0, satir(y0)), min(H, satir(y1))
        c0, c1 = max(0, sutun(x0)), min(Wd, sutun(x1))
        if r1 <= r0 or c1 <= c0:
            return
        blok = a[r0:r1, c0:c1]
        rr = np.array(rgb(renk)) * 255.0
        m = blok[..., 3] > 0
        blok[..., :3][m] = blok[..., :3][m] * (1 - alfa) + rr * alfa

    # sol kenar golgesi + iki parlak cizgi
    boya(X0, X0 + 3, LY + 4, FLOOR - 4, "#000000", 0.3)
    boya(X0, X0 + 1, LY + 6, FLOOR - 6, "#8c949c", 1.0)
    boya(X0 + 1, X0 + 2, LY + 6, FLOOR - 6, "#aeb6be", 1.0)
    # sol koseler (R=8)
    R = 8
    for i in range(R):
        d = R - math.floor(math.sqrt(R * R - (R - i - 1) * (R - i - 1)) + 0.5)
        if d > 0:
            bosalt(X0, X0 + d, LY + i)
            bosalt(X0, X0 + d, FLOOR - 1 - i)
    # sag tas kemer kesigi
    for y in range(LY - 2, FLOOR):
        e = archR(y)
        if e < W:
            bosalt(e, W, y)
        boya(e - 1, e, y, y + 1, "#000000", 0.35)
    # zeminin alti
    a[satir(FLOOR):, :, 3] = 0
    px.write_png(np.clip(a, 0, 255).astype("uint8"), yol)


PARCALAR = {("govde_%d" % i): govde(i) for i in range(4)}


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = ["govde_%s" % a for a in argv] if argv else list(PARCALAR)
    for ad in adlar:
        I.sahne(GX0, GY0, GW, GH)
        PARCALAR[ad]()
        px.shear_scene(K)
        yol = px.render(os.path.join(OUT, ad + ".png"))
        maske(yol)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR),
                   "kokenler": {k: [GX0, GY0] for k in PARCALAR}}, fp, indent=1)
    print("GOVDE_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
