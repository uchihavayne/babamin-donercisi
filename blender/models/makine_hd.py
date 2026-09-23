"""UST SIRA MAKINELER — remake HD parcalari.

    blender --background --factory-startup --python blender/models/makine_hd.py [-- parca ...]
    python blender/hd_atlas.py makine_hd makine

Oyundaki karsiliklari (art.js):
  drawIcecekKasasi (ST.drinkM, w 62, h 34, bolme 1..3) -> icecek_kasa_1/2/3   capa: (x, y)
  drawDrinkMachine (w 62 ya da 34 ayran acikken, h 32) -> icecek_govde_62/34 capa: (x, y)
      kademe 2 manometre -> icecek_gosterge   capa: (x + w>>1, y - 5)
      kademe 3 CO2 tupu  -> icecek_tank       capa: (x - 4, y) ve (x + w, y)
      kademe 4 ekran     -> icecek_ekran      capa: (x + w>>1 - 8, y - 8)
  drawAyranTank (w 28, h 40 oyunda / 46 dukkanda; kazan yaricapi 10, buyuk kazan 12)
                    -> ayran_<r>_<bh>         capa: (x, y)
  drawFryer (ST.fryer 58x44)  -> fritoz_govde (govde + hazne + yag + rezistans + panel)
                                 fritoz_sepet_40 (tek) / fritoz_sepet_19 (cift hazne)
                                 fritoz_sap (sepet kolu, capa: ax, ay)
                                 fritoz_on (hazne on dudagi: sepetlerin ONUNDE)
                                 fritoz_bolme (kademe 3), fritoz_oto (kademe 4)
Kodla kalanlar: dokulen icecek / ayran akisi, manometre ibresi, ekran ve
isiklar, seviye penceresindeki ayran, yag yuzeyi dalgasi, kabarciklar,
sepetteki patatesler, yagin sepeti ortmesi, fritoz ekrani yazisi, dugme
cizgisi, duman ve parcaciklar (rastgele cagrilar orijinal sirada).
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

OUT = os.path.join(_HERE, "out", "makine_hd")
HD = 2
KOKEN = {}
PARCALAR = {}
cel = I.cel
ez = T.ez
onkutu = T.onkutu
torna = T.torna
hexmul = T.hexmul


def parca(ad, tuval, fn, K=0.3, cizgi=None, cizgi_alfa=170):
    PARCALAR[ad] = (tuval, fn, K, cizgi, cizgi_alfa)
    KOKEN[ad] = (tuval[0], tuval[1])


def c4(ad, koyu, orta, acik, parlak, stops=(0, .3, .5, .8), noise=0.0):
    return cel(ad, [koyu, orta, acik, parlak], list(stops), noise=noise, noise_scale=18)


def levha(ad, x0, gy0, w, h, r, y, derin, mat, K, bevel=0.0):
    """Onden bakan yuvarlak koseli levha: on yuzu y'de, ekranda (x0, gy0, w, h)."""
    ob = L.levha(ad, w, h, r, x0 + w / 2.0, ez(gy0 + h / 2.0, y + derin / 2.0, K), y + derin / 2.0, derin, bevel, mat)
    return ob


# ---------------------------------------------------------------- icecek kasasi
def icecek_kasa(bolme, w=62, h=34):
    def fn():
        K = 0.3
        Mc = c4("KasaCerceve", "#3f454e", "#59636d", "#7a838c", "#b8c0c8")
        Mi = c4("KasaIc", "#4a525a", "#6a737c", "#7a838c", "#98a1aa")
        levha("cerceve", -2, -4, w + 4, h + 6, 1.5, 6, 2, Mc, K)
        onkutu("ic", -1, w + 1, -2.5, h + 1.5, 5.8, 6.2, Mi, K)
        onkutu("isik", -1, w + 1, -3.5, -3, 5.7, 6.2, px.flat("KasaIsik", "#b8c0c8"), K)
        Mb = c4("Bolme", "#3f454e", "#4a525a", "#98a1aa", "#b8c0c8")
        for i in range(1, bolme):
            bx = math.floor(w / bolme * i + 0.5)
            onkutu("bolme", bx - 0.5, bx + 1.5, -3, h + 1, 3.5, 6, Mb, K)
        # damlalik: one cikan yatay tepsi, ustu izgarali
        dy = h + 6
        Mt = c4("Damlalik", "#3a4148", "#4a525a", "#6f767e", "#98a1aa")
        onkutu("damlalik", -2, w + 2, dy + 1, dy + 5, -2, 6, Mt, K)
        zt = ez(dy + 1, -2, K)
        L.kutu("damlalik_ust", -1, w + 1, zt - 0.3, zt, -1.5, 5.5, c4("DamlalikUst", "#4a525a", "#59636d", "#6f767e", "#8e979f"))
        g = 0
        while g < w:
            L.kutu("yarik", g + 0.3, g + 1.2, zt - 0.2, zt + 0.02, -1.0, 5.0, px.flat("Yarik", "#3a4148"))
            g += 3
    return fn


# ---------------------------------------------------------------- icecek makinesi
def icecek_govde(w, h=32):
    def fn():
        K = 0.3
        yari = w >> 1
        Mg = c4("IcGovde", "#6f777f", "#8b939b", "#b8c0c7", "#dde3e8")
        levha("govde", 0, 0, w, h, 1.0, 0, 4, Mg, K, bevel=0.4)
        onkutu("sol_isik", 1, 4.5, 0.5, h - 1.5, -0.35, 1, c4("SolIsik", "#b8c0c7", "#c9d0d6", "#dde3e8", "#eef2f5"), K)
        onkutu("sag_golge", w - 5, w - 1, 0.5, h - 1.5, -0.3, 1, px.flat("SagGolge", "#939aa0"), K)
        Mk = c4("IcKapak", "#1f242a", "#2b3138", "#3f454e", "#7d868e")
        onkutu("ust", -1, w + 1, -3, 2, -0.8, 3.5, Mk, K)
        onkutu("ust_isik", 0, w, -3, -2.5, -0.9, 3.5, px.flat("UstIsik", "#7d868e"), K)
        onkutu("alt", -1, w + 1, h - 3, h + 2, -0.8, 3.5, Mk, K)
        onkutu("alt_isik", 0, w, h - 3, h - 2.5, -0.9, 3.5, px.flat("AltIsik", "#5b626a"), K)
        # lezzet panelleri (isikli), ustunde sise simgesi
        pH, pY = 11, 2
        for i in range(2):
            pX = 2 + i * (yari - 1)
            pW = yari - 3
            if pW < 6:
                continue
            ic, ac, pr = (("#d8641c", "#f0821c", "#ffb03c") if i == 0 else ("#8e1c14", "#c0281c", "#e05a48"))
            onkutu("panel_cerceve", pX - 1, pX + pW + 1, pY - 1, pY + pH + 1, -0.6, 1, px.flat("PanelCer", "#2b3138"), K)
            onkutu("panel", pX, pX + pW, pY, pY + pH, -0.7, 0, c4("Panel%d" % i, ic, ic, ac, pr, (0, .3, .45, .9)), K)
            onkutu("panel_isik", pX + 1, pX + pW - 2, pY, pY + 0.6, -0.75, 0, px.flat("PanelIsik%d" % i, pr), K)
            onkutu("panel_golge", pX + pW - 1, pX + pW, pY, pY + pH, -0.75, 0, px.flat("PanelGolge%d" % i, ic), K)
            bx = pX + (pW >> 1) - 1 + 0.5
            gv, gi = (("#e8dcc0", "#fffdf2") if i == 0 else ("#4a1c10", "#8a3a20"))
            Ms = c4("SiseSimge%d" % i, hexmul(gv, .55), hexmul(gv, .8), gv, gi)
            torna("sise", [(2.3, 0), (2.3, 5.2), (1.2, 6.6), (1.2, 8.6)], bx, pY + 11, -1.6, 0.5, Ms, K)
            torna("sise_kapak", [(1.4, 8.6), (1.4, 9.6)], bx, pY + 11, -1.6, 0.5,
                  px.flat("SiseKap%d" % i, "#d8641c" if i == 0 else "#c0281c"), K)
        # dolum bolmesi
        oY = pY + pH + 1
        oH = h - oY - 4
        onkutu("bolme_cer", 3, w - 3, oY, oY + oH, -0.6, 1, px.flat("BolmeCer", "#232a31"), K)
        onkutu("bolme_arka", 4, w - 4, oY + 1, oY + oH - 1, -0.7, -0.6, c4("BolmeArka", "#2e343b", "#353b43", "#3f454e", "#4a515a"), K)
        onkutu("bolme_golge", 4, w - 4, oY + 1, oY + 4, -0.75, -0.7, px.flat("BolmeGolge", "#2a2f36"), K)
        onkutu("bolme_tavan", 3, w - 3, oY, oY + 2, -0.8, -0.7, px.flat("Tavan", "#2b3138"), K)
        onkutu("bolme_isik", 4, w - 4, oY, oY + 0.6, -0.85, -0.7, px.flat("BolmeIsik", "#5b626a"), K)
        for m in range(2):
            mx = 7 + m * (w - 15)
            Mn = c4("Musluk", "#6f777f", "#8b939b", "#c3cad1", "#dde3e8")
            onkutu("musluk", mx - 2, mx + 2.5, oY + 1, oY + 4.5, -2.4, -0.9, Mn, K)
            T.torna("uc", [(0.9, 0), (0.9, 2.2)], mx + 0.2, oY + 7, -1.6, 1.0, c4("Uc", "#4f575f", "#6f777f", "#8b939b", "#aeb5bc"), K)
            onkutu("kol", mx + 2.3, mx + 3.2, oY + 1.5, oY + 6, -2.8, -1.8, c4("Kol", "#1f242a", "#2b3138", "#3f454e", "#5b626a"), K)
        dY = oY + oH - 3
        onkutu("izgara", 5, w - 5, dY, dY + 3, -2.0, -0.5, c4("Izgara", "#1f242a", "#2b3138", "#3f454e", "#8b939b"), K)
        onkutu("izgara_isik", 5, w - 5, dY, dY + 0.5, -2.05, -0.5, px.flat("IzgIsik", "#8b939b"), K)
        gx = 0
        while gx < w - 12:
            onkutu("izgara_delik", 6 + gx, 6.8 + gx, dY + 1, dY + 2, -2.1, -2.0, px.flat("IzgDelik", "#b8c0c7"), K)
            gx += 2
    return fn


def icecek_gosterge():
    K = 0.3
    L.silindir("dis", 3.0, 0, 0.5, ez(0, 0.5, K), 1.2, c4("GostDis", "#4f575f", "#6f777f", "#8b939b", "#b8c0c7"), seg=20, eksen="Y")
    L.silindir("kadran", 2.1, 0, -0.2, ez(0, -0.2, K), 0.2, px.flat("Kadran", "#eef2f5"), seg=20, eksen="Y")
    for a in range(5):
        aa = math.radians(200 + a * 35)
        onkutu("cizik", 1.6 * math.cos(aa) - 0.2, 1.6 * math.cos(aa) + 0.2, -1.6 * math.sin(aa) - 0.2, -1.6 * math.sin(aa) + 0.2,
               -0.35, -0.3, px.flat("Cizik", "#8b939b"), K)


def icecek_tank(h=32):
    K = 0.3
    boy = h - 8
    torna("tup", [(1.2, 0), (2.0, 1.0), (2.0, boy - 1), (1.6, boy)], 2, 3 + boy, 1.5, 1.0,
          c4("Tup", "#6f777f", "#8b939b", "#b8c0c7", "#dde3e8"), K)
    torna("tup_kapak", [(2.1, boy - 0.2), (2.1, boy + 2), (1.2, boy + 2.4)], 2, 3 + boy, 1.5, 1.0,
          c4("TupKapak", "#2b3138", "#3f454e", "#59626b", "#7d868e"), K)
    torna("tup_bant", [(2.06, boy * 0.55), (2.06, boy * 0.55 + 3)], 2, 3 + boy, 1.5, 1.0,
          c4("TupBant", "#1c3a66", "#2c5a98", "#3f79c0", "#6b9ad8"), K, kapak=False)


def icecek_ekran():
    K = 0.3
    levha("kasa", 0, 0, 16, 5, 1.0, 0, 2, c4("Ekran", "#1f242a", "#2b3138", "#3f454e", "#59626b"), K, bevel=0.2)
    onkutu("cam", 1, 15, 0.5, 4, -0.2, 0, px.flat("EkranCam", "#141a1f"), K)


# ---------------------------------------------------------------- ayran kazani
def ayran(r, bh, w=28):
    def fn():
        K = 0.3
        cx = math.floor(w / 2.0 + 0.5)
        by = 8
        ym = r * 0.45 + 0.5
        Mb = c4("Kazan", "#5f6672", "#878e99", "#aeb5be", "#f2f4f6", (0, .25, .45, .75))
        # ayaklar
        Ma = c4("Ayak", "#1b2126", "#2f3740", "#3f4852", "#59636d")
        for lx in (cx - r + 2, cx + r - 5):
            onkutu("ayak", lx, lx + 3, by + bh - 1, by + bh + 4, ym - 1.5, ym + 1.5, Ma, K)
        # govde silindiri + kubbe kapak
        prof = [(r - 1.0, 0), (r, 1.0), (r, 1.3), (r, bh - 0.3), (r, bh)]
        torna("govde", prof, cx, by + bh, ym, 0.45, Mb, K, seg=36)
        kubbe = []
        for k in range(7):
            a = (math.pi / 2.0) * k / 6.0
            kubbe.append((r * math.cos(a) if k < 6 else 0.4, bh + math.sin(a) * 5.0))
        torna("kubbe", kubbe, cx, by + bh, ym, 0.45, Mb, K, seg=36)
        # alt kenar halkasi
        torna("alt_halka", [(r + 0.15, 0.2), (r + 0.15, 1.2)], cx, by + bh, ym, 0.45, px.flat("AltHalka", "#878e99"), K, kapak=False)
        # kapak topuzu
        torna("topuz", [(2.0, bh + 4.2), (2.0, bh + 7.2), (1.0, bh + 8.2)], cx, by + bh, ym, 0.6, Ma, K)
        # mavi etiket bandi
        ey, eh = by + 5, 11
        torna("bant", [(r + 0.08, bh - (ey - by) - eh), (r + 0.08, bh - (ey - by))], cx, by + bh, ym, 0.45,
              c4("Bant", "#1c3a66", "#2c5a98", "#3f79c0", "#6b9ad8", (0, .25, .45, .75)), K, kapak=False)
        # bant ustunde ayran kasesi simgesi
        yon = ym - r * 0.45 - 0.35
        Mg = c4("Kase", "#cfcabc", "#e2ded2", "#f6f4ea", "#ffffff")
        T.torna("kase", [(1.9, 0), (2.5, 6.0)], cx + 0.5, ey + 9, yon - 1.3, 0.35, Mg, K)
        T.torna("kase_ic", [(2.35, 5.7), (2.35, 6.05)], cx + 0.5, ey + 9, yon - 1.3, 0.35, px.flat("KaseIc", "#a8c8ee"), K)
        # seviye penceresi (yalniz yeterince yuksek kazanda)
        wx, wy = cx - r + 4, ey + eh + 2
        wh = (by + bh) - wy - 3
        if wh > 4:
            onkutu("pencere", wx, wx + 4, wy, wy + wh, yon - 0.4, yon + 0.5, px.flat("Pencere", "#1b2126"), K)
            onkutu("pencere_ic", wx, wx + 3, wy, wy + wh - 1, yon - 0.5, yon + 0.5, px.flat("PencereIc", "#2f3740"), K)
            onkutu("pencere_kenar", wx, wx + 0.8, wy, wy + wh, yon - 0.8, yon + 0.5, px.flat("PencereKenar", "#6b737d"), K)
        # musluk
        tx, ty = cx + r - 7, by + bh - 9
        Mm = c4("Musluk", "#5f6672", "#878e99", "#d3d8de", "#eef2f5")
        onkutu("musluk", tx - 2, tx + 4, ty, ty + 4, yon - 2.0, yon + 0.5, Mm, K)
        T.torna("agiz", [(0.9, 0), (0.9, 3)], tx + 1, ty + 7, yon - 1.0, 1.0, px.flat("Agiz", "#878e99"), K)
        onkutu("kol", tx - 4, tx - 2, ty - 3, ty + 2, yon - 2.5, yon - 1.0, Ma, K)
    return fn


# ---------------------------------------------------------------- fritoz
FW, FH = 58, 44
VX, VW, VY, VH = 5, 48, 10, 19
VB = VY + VH
OILY = VY + 2


def fritoz_govde():
    K = 0.3
    Mt = c4("FrUst", "#2b5a5c", "#356669", "#5aa3a6", "#7cc4c6", (0, .3, .45, .8))
    # ust tabla (tezgaha yaslanan arka raf): yatay, ustten gorunur
    onkutu("ust", 3, FW - 3, 1.5, 7, 0, 6, Mt, K)
    onkutu("ust_isik", 4, FW - 4, 1.5, 2.0, -0.05, 6, px.flat("UstIsik", "#7cc4c6"), K)
    Mg = c4("FrGovde", "#24494b", "#3f7d80", "#4e9295", "#7cc4c6", (0, .3, .5, .8))
    # govde: hazne penceresinin cevresinde dort parca (pencere acik kalsin)
    for ad, x0, x1, g0, g1 in (("sol", 0, VX - 1, 7, FH), ("sag", VX + VW + 1, FW, 7, FH),
                               ("ust", VX - 1, VX + VW + 1, 7, VY - 1), ("alt", VX - 1, VX + VW + 1, VB + 1, FH)):
        onkutu("govde_" + ad, x0, x1, g0, g1, 0, 5, Mg, K)
    onkutu("govde_sol_kenar", 0, 1, 7, FH, -0.2, 5, px.flat("GovSolKenar", "#356669"), K)
    onkutu("govde_sag_kenar", FW - 1, FW, 7, FH, -0.2, 5, px.flat("GovSagKenar", "#2b5a5c"), K)
    onkutu("govde_isik", 1.5, FW - 1.5, 7.2, 7.8, -0.35, 1, px.flat("GovIsik", "#7cc4c6"), K)
    onkutu("govde_alt", 1, FW - 1, FH - 1, FH, -0.3, 1, px.flat("GovAlt", "#24494b"), K)
    # hazne: govdeye gomulu pencere, icinde yag
    # pencere kenari: 1 px'lik koyu pervaz (govde parcalari pencereyi 1 px genis birakiyor)
    onkutu("hazne_cer", VX - 1, VX + VW + 1, VY - 1, VB + 1, 4.2, 4.6, px.flat("HazneCer", "#24494b"), K)
    onkutu("hazne_cer_ust", VX - 1, VX + VW + 1, VY - 1, VY - 0.4, 4.1, 4.6, px.flat("HazneCerUst", "#1b3739"), K)
    onkutu("hazne_ic", VX, VX + VW, VY, VB, 3.5, 4, px.flat("HazneIc", "#2a2317"), K)
    oilH = VB - OILY
    Moil = c4("Yag", "#7a5a14", "#a8811f", "#bd932c", "#d0a93c", (0, .25, .45, .8))
    onkutu("yag", VX, VX + VW, OILY, VB, 0.5, 2.5, Moil, K)
    onkutu("yag_kat1", VX + 1, VX + VW - 1, OILY + 1, VB - 2, 0.4, 2.5, px.flat("YagK1", "#a8811f"), K)
    onkutu("yag_kat2", VX + 2, VX + VW - 2, OILY + 2, VB - 4, 0.3, 2.5, px.flat("YagK2", "#bd932c"), K)
    onkutu("yag_ust", VX + 3, VX + VW - 3, OILY + 2, OILY + 5, 0.25, 2.5, px.flat("YagUst", "#d0a93c"), K)
    onkutu("parilti", VX + 4, VX + 4 + 14, OILY + 2, OILY + 4, 0.2, 0.25, px.flat_a("Parilti", "#fff8dc", 0.15), K)
    # rezistans borulari (yagin icinde: yag rengine karismis)
    Mr = c4("Rezistans", "#7e7456", "#a1936a", "#b8aa7c", "#c2b389")
    rzY = VY + math.floor(VH * 0.34 + 0.5)
    for rz in range(2):
        ry = rzY + rz * 4 + 1
        L.silindir("rz", 1.0, VX + VW / 2.0, 0.0, ez(ry, 0.0, K), VW - 6, Mr, seg=10, eksen="X")
        for ex in (VX + 3.5, VX + VW - 3.5):
            onkutu("rz_uc", ex - 0.5, ex + 0.5, ry - 1, ry + 1, -1.2, -0.9, px.flat("RzUc", "#6b737d"), K)
    onkutu("rz_dik", VX + VW - 5, VX + VW - 3, rzY, rzY + 5, -0.9, 0.5, Mr, K)
    # sepet askisi plakasi
    onkutu("aski", VX + VW - 10, VX + VW - 2, VY - 2, VY, -0.8, 1.5, c4("Aski", "#6f777f", "#9aa3ac", "#c3cad1", "#d6dde3"), K)
    # kontrol paneli
    pY, pX, pW = VB + 3, 3, FW - 6
    onkutu("panel", pX, pX + pW, pY, pY + 9, -0.5, 1, c4("FrPanel", "#1f252b", "#2f3740", "#3a434d", "#59636d"), K)
    onkutu("panel_ic", pX + 0.6, pX + pW - 0.6, pY + 0.6, pY + 8.4, -0.6, 1, px.flat("PanelIc", "#2f3740"), K)
    onkutu("ekran", pX + 2, pX + 24, pY + 1, pY + 8, -0.75, 0, px.flat("FrEkran", "#160c0c"), K)
    kx, ky = pX + pW - 7, pY + 4
    L.silindir("dugme", 3.0, kx, -1.0, ez(ky, -1.0, K), 1.0, c4("FrDugme", "#5d666f", "#8b959e", "#aab3bb", "#c8d0d8"), seg=20, eksen="Y")
    L.silindir("dugme_ic", 2.0, kx, -1.6, ez(ky, -1.6, K), 0.2, px.flat("DugmeIc", "#c8d0d8"), seg=16, eksen="Y")
    L.silindir("led_yuva", 2.0, kx - 9, -0.9, ez(ky, -0.9, K), 0.4, px.flat("LedYuva", "#1b2026"), seg=16, eksen="Y")


def fritoz_on():
    K = 0.3
    onkutu("dudak", VX - 1, VX + VW + 1, VB - 2, VB, -1.2, 0, c4("Dudak", "#1b3739", "#24494b", "#3f7d80", "#4e9295"), K)
    onkutu("dudak_isik", VX - 1, VX + VW + 1, VB - 2, VB - 1.5, -1.25, 0, px.flat("DudakIsik", "#4e9295"), K)
    for x0 in (VX, VX + VW - 1):
        onkutu("kenar", x0, x0 + 1, VY, VB - 2, -1.0, 0, px.flat_a("Kenar", "#4a3410", 0.5), K)


def fritoz_sepet(bw, bh=13):
    def fn():
        K = 0.3
        Mt = px.flat("SepetTaban", "#2c333a")
        onkutu("arka", 1, bw - 1, 2, bh - 1, 1.8, 2.0, Mt, K)
        onkutu("taban", 0.5, bw - 0.5, bh - 1.2, bh, -0.2, 2.0, c4("SepetAlt", "#2c333a", "#3a424a", "#4f5861", "#66707a"), K)
        # tel orgu: dikey teller + iki yatay tel
        Mw = c4("Tel", "#5d666f", "#6f7881", "#8b949d", "#b9c2ca")
        gx = 0
        while gx < bw - 2:
            L.silindir("tel", 0.5, 1.5 + gx, -0.1, ez(2 + (bh - 3) / 2.0, -0.1, K), bh - 3, Mw, seg=6, eksen="Z")
            gx += 3
        for yy in (4.5, bh - 2.5):
            L.silindir("yatay", 0.45, bw / 2.0, -0.2, ez(yy, -0.2, K), bw - 1.5, px.flat("YatayTel", "#66707a"), seg=6, eksen="X")
        # agiz cemberi + yan cubuklar
        Mc = c4("Cember", "#6f7881", "#9aa3ac", "#c9d1d8", "#e2e8ee")
        L.silindir("cember", 0.9, bw / 2.0, -0.3, ez(1.0, -0.3, K), bw, Mc, seg=10, eksen="X")
        onkutu("sol", 0, 1, 0, bh, -0.5, 2.0, px.flat("SepetSol", "#b9c2ca"), K)
        onkutu("sag", bw - 1, bw, 0, bh, -0.5, 2.0, px.flat("SepetSag", "#8e97a0"), K)
    return fn


def fritoz_sap():
    K = 0.3
    Mp = c4("Pim", "#4f575f", "#6e7780", "#a0a9b1", "#c8d0d8")
    L.silindir("pim", 2.0, 0, -0.8, ez(1, -0.8, K), 1.0, Mp, seg=16, eksen="Y")
    L.silindir("pim_ic", 1.0, 0, -1.4, ez(1, -1.4, K), 0.2, px.flat("PimIc", "#c8d0d8"), seg=10, eksen="Y")
    # egik kol: (0,0) -> (3,-8)
    Mk = c4("SapKol", "#6f7881", "#8e97a0", "#b9c2ca", "#d6dde3")
    x0, y0, x1, y1 = 0.8, 0.0, 3.7, -8.5
    uz = math.hypot(x1 - x0, y1 - y0)
    kol = L.silindir("kol", 0.6, (x0 + x1) / 2.0, -0.9, ez((y0 + y1) / 2.0, -0.9, K), uz, Mk, seg=8, eksen="Z")
    kol.rotation_euler = (0, math.atan2(x1 - x0, -(y1 - y0)), 0)
    # tutamak
    Mt = c4("Tutamak", "#141a1f", "#1a2026", "#39424b", "#5a656f")
    levha("tutamak", -2, -12, 12, 5, 1.8, -1.6, 2.0, Mt, K, bevel=0.5)
    onkutu("tutamak_isik", -1, 9, -11, -10.5, -1.75, -1.0, px.flat("TutIsik", "#5a656f"), K)


def fritoz_bolme():
    K = 0.3
    dvx = VX + (VW >> 1) - 1
    onkutu("bolme", dvx, dvx + 2, VY, VB, -0.6, 2.5, c4("Bolme", "#1b3739", "#24494b", "#3f7d80", "#5aa3a6"), K)
    onkutu("bolme_isik", dvx, dvx + 1, VY, VB, -0.65, 2.5, px.flat("BolmeIsik", "#5aa3a6"), K)
    onkutu("bolme_ust", dvx - 1, dvx + 3, VY - 1, VY - 0.4, -0.7, 2.5, px.flat("BolmeUst", "#7cc4c6"), K)


def fritoz_oto():
    K = 0.3
    Mr = c4("Ray", "#6f777f", "#8b949d", "#b9c2ca", "#d6dde3")
    L.silindir("ray", 1.0, VX + VW / 2.0, 1.0, ez(VY - 7, 1.0, K), VW + 4, Mr, seg=10, eksen="X")
    levha("kutu", VX + VW - 8, VY - 12, 8, 5, 1.0, -0.5, 2.5, c4("OtoKutu", "#1f252b", "#2f3740", "#5f6672", "#7d868e"), K, bevel=0.3)


parca("icecek_kasa_1", (-3, -6, 68, 54), icecek_kasa(1))
parca("icecek_kasa_2", (-3, -6, 68, 54), icecek_kasa(2))
parca("icecek_kasa_3", (-3, -6, 68, 54), icecek_kasa(3))
parca("icecek_govde_62", (-2, -5, 66, 40), icecek_govde(62), cizgi="#3f454e", cizgi_alfa=120)
parca("icecek_govde_34", (-2, -5, 38, 40), icecek_govde(34), cizgi="#3f454e", cizgi_alfa=120)
parca("icecek_gosterge", (-4, -4, 8, 8), icecek_gosterge, cizgi="#3f454e", cizgi_alfa=150)
parca("icecek_tank", (-1, 0, 6, 30), icecek_tank, cizgi="#3f454e", cizgi_alfa=120)
parca("icecek_ekran", (-1, -1, 18, 7), icecek_ekran)
for _r in (10, 12):
    for _bh in (22, 28):
        parca("ayran_%d_%d" % (_r, _bh), (-1, -1, 30, _bh + 16), ayran(_r, _bh), cizgi="#2f3740", cizgi_alfa=110)
# BIRLESIK: yeni tezgahin fritoz yuvasi 51x43 (hazne 41 genis). Ayni model
# modul sabitleri gecici degistirilerek render edilir; parcalar "_51" ekli.
def _fritoz_boyut(fw, fh):
    global FW, FH, VW, VB, OILY
    FW, FH = fw, fh
    VW = fw - 10
    VB = VY + VH
    OILY = VY + 2


def _fritoz_olcu(fn, fw, fh):
    def g():
        _fritoz_boyut(fw, fh)
        try:
            fn()
        finally:
            _fritoz_boyut(58, 44)
    return g


parca("fritoz_govde_51", (-1, 0, 53, 45), _fritoz_olcu(fritoz_govde, 51, 43))
parca("fritoz_on_51", (3, 8, 45, 23), _fritoz_olcu(fritoz_on, 51, 43))
parca("fritoz_sepet_33", (-1, -1, 35, 15), fritoz_sepet(33))
parca("fritoz_sepet_15", (-1, -1, 17, 15), fritoz_sepet(15))
parca("fritoz_bolme_51", (22, 8, 6, 22), _fritoz_olcu(fritoz_bolme, 51, 43))
parca("fritoz_oto_51", (2, -3, 47, 9), _fritoz_olcu(fritoz_oto, 51, 43))
parca("fritoz_govde", (-1, 0, 60, 46), fritoz_govde)
parca("fritoz_on", (3, 8, 52, 23), fritoz_on)
parca("fritoz_sepet_40", (-1, -1, 42, 15), fritoz_sepet(40))
parca("fritoz_sepet_19", (-1, -1, 21, 15), fritoz_sepet(19))
parca("fritoz_sap", (-3, -13, 14, 17), fritoz_sap, cizgi="#141a1f", cizgi_alfa=110)
parca("fritoz_bolme", (26, 8, 6, 22), fritoz_bolme)
parca("fritoz_oto", (2, -3, 54, 9), fritoz_oto)


def uret(ad):
    (gx0, gy0, w, h), fn, K, cizgi, cizgi_alfa = PARCALAR[ad]
    I.sahne(gx0, gy0, w, h)
    fn()
    px.shear_scene(K)
    yol = px.render(os.path.join(OUT, ad + ".png"))
    if cizgi:
        px.outline(yol, hexcol=cizgi, alpha=cizgi_alfa)
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = argv if argv else list(PARCALAR)
    for ad in adlar:
        uret(ad)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR),
                   "kokenler": {k: list(v) for k, v in KOKEN.items()}}, fp, indent=1)
    print("MAKINE_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
