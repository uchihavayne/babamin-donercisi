"""YENI TEZGAH (birlesik surum, counter_design.gd) — remake HD parcalari.

    blender --background --factory-startup --python blender/models/tezgah2_hd.py [-- parca ...]
    python blender/hd_atlas.py tezgah2_hd tezgah2

counter_design.gd'nin onaylanmis yerlesimi (480x270 mantik koordinati)
Blender'da 3B kurulup 2x HD render edilir. Yerlesim ve renkler tasarimla
AYNI; kazanc: pah/egim golgesi, firca izli celik, ahsap damari, 1 HD px ayrinti.

Parcalar ve capalari:
  tezgah_alt   dudak + cekmeceler + koyu alt govde     capa (0,0) ekran
  tezgah_celik calisma yuzeyi (tema rengine gore modulate)  capa (0,0)
  tezgah_ust   pencere rafi + damlama tepsisi + soguk ray   capa (0,0)
  servis       Dayi'nin servis bolmesi (f_drawCounterProps) capa (0,0)
  tahta        hazirlama tahtasi 150x48                    capa ST.board sol-ust

Koordinat: 1 birim = 1 mantik pikseli. Ekran gy -> dunya z = -gy. Oblik
acilim z += y*K (yatay yuzeyler K kati gorunur).
"""
import sys, os, math, json, random
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T

OUT = os.path.join(_HERE, "out", "tezgah2_hd")
HD = 2
KOKEN = {}
PARCALAR = {}
cel = I.cel
mesh_ob = I.mesh_ob
ez = T.ez
onkutu = T.onkutu
yatay_plaka = T.yatay_plaka
ust_cizgi = T.ust_cizgi
ust_poligon = T.ust_poligon
flat = px.flat
K0 = 0.5

S4 = [0, .3, .5, .8]        # rampa esikleri: sag/alt, sol, on yuz, ust yuz


def parca(ad, tuval, fn, K=K0, cizgi=None, cizgi_alfa=170):
    PARCALAR[ad] = (tuval, fn, K, cizgi, cizgi_alfa)
    KOKEN[ad] = (tuval[0], tuval[1])


def pah_kutu(ad, x0, x1, gy0, gy1, y0, y1, mat, K, pah=0.6, seg=1):
    """On yuzu (derinlik y0) ekranda [gy0, gy1] olan, kenarlari pahli kutu.
    Pah ust kenarda isik, alt kenarda golge verir (cel rampasi)."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    z0, z1 = ez(gy1, y0, K), ez(gy0, y0, K)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    if pah > 0:
        bmesh.ops.bevel(bm, geom=bm.edges[:], offset=pah, segments=seg, profile=0.5, affect="EDGES")
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return mesh_ob(ad, bm, mat, smooth=False)


def duz_plaka(ad, x0, gy0, w, hs, kalin, mat, K):
    """Ust yuzu ekranda (x0, gy0, w, hs) gorunen koseli yatay levha; ust z doner."""
    z = -(gy0 + hs)
    L.kutu(ad, x0, x0 + w, z - kalin, z, 0, hs / K, mat)
    return z


def serit(ad, x0, gy0, x1, gy1, y, mat, K, derin=0.05):
    """On yuze yapisik ince dikdortgen serit (damar, cizgi)."""
    return onkutu(ad, x0, x1, gy0, gy1, y - derin, y, mat, K)


# ---------------------------------------------------------------- tezgah alt govde
AHSAP = ["#3f2616", "#6e4122", "#875126", "#a8703c"]
AHSAP_ACIK = ["#5b3822", "#8a5a2e", "#a96f3a", "#e1b17a"]


def tezgah_alt():
    K = K0
    # koyu govde (cekmece aralari, cop kutusunun arkasi)
    onkutu("taban", 32, 480, 240, 270, 4, 6, flat("Taban", "#392a21"), K)
    onkutu("taban_golge", 32, 480, 240, 243, 3.9, 4, flat("TabanGolge", "#2a1e17"), K)
    # calisma yuzeyinin on dudagi (236..241): yuvarlak burun + koyu on yuz
    Mdud = cel("Dudak", ["#353d41", "#444e52", "#56636a", "#6c7a80"], S4)
    onkutu("dudak", 32, 480, 238.2, 241, 0, 3, Mdud, K)
    Mbur = cel("Burun", ["#56636a", "#8e999b", "#bcc5c3", "#edf0dc"], [0, .25, .55, .8])
    L.silindir("burun", 1.25, 256.0, 1.25, ez(237.4, 1.25, K), 448, Mbur, seg=20, eksen="X")
    serit("burun_isik", 32, 236.2, 480, 236.7, -0.1, flat("BurunIsik", "#f4f6e6"), K)
    # ahsap cekmeceler
    Mah = cel("Cekmece", AHSAP, S4, noise=0.05, noise_scale=38)
    Mkol = cel("Kol", ["#26292b", "#393b3c", "#8d9092", "#d4d6d0"], S4)
    r = random.Random(7)
    for x in (34, 101, 168, 235, 302):
        pah_kutu("cekmece", x, x + 64, 241.3, 270, -1.2, 3, Mah, K, pah=0.9, seg=2)
        # damar: tasarimdaki 7 px aralikli dikey tonlar, HD'de ince ve kesik
        for i in range(4, 61, 7):
            ton = "#956030" if (i // 7) % 2 else "#7f4d26"
            serit("damar", x + i, 243.5, x + i + 0.5, 268.5, -1.2, flat("Damar%d" % (i % 3), ton), K)
            yy = 243 + (i * 7.0) % 21
            serit("damar2", x + i + 0.5, yy, x + i + 1.0, min(268, yy + 8), -1.2, flat("DamarA", "#b57a44"), K)
        # kulp: iki ayak + yuvarlak cubuk
        kx = x + 43
        for ax in (kx + 1, kx + 12):
            onkutu("kulp_ayak", ax, ax + 1.2, 247.3, 249.7, -2.6, -1.2, Mkol, K)
        L.silindir("kulp", 0.95, kx + 7.0, -3.0, ez(248.4, -3.0, K), 14, Mkol, seg=14, eksen="X")
    # celik cekmeceler (fritoz / kesme altinda)
    Mcc = cel("CelikCekmece", ["#3f4649", "#52595e", "#90999c", "#cbd0ca"], S4)
    Mcuk = cel("Cukur", ["#262b2d", "#2f3537", "#41484b", "#5b6468"], S4)
    for y in (241, 256):
        pah_kutu("c_cekmece", 336, 387, y + 0.3, y + 13, -1.8, 3, Mcc, K, pah=0.8, seg=2)
        onkutu("c_cukur", 351, 369, y + 3, y + 6, -2.1, -1.2, Mcuk, K)
        serit("c_cukur_isik", 351, y + 5.5, 369, y + 6, -2.15, flat("CukurIsik", "#c9ced0"), K)
    # patates kasasinin arkasindaki ahsap pano (cogu ortulu)
    pah_kutu("pano", 391, 437, 240.3, 270, -0.5, 3, cel("Pano", AHSAP_ACIK, S4, noise=0.05, noise_scale=38), K, pah=0.7)


# ---------------------------------------------------------------- calisma yuzeyi
# Tema 0 celigi #91999b; diger temalar oyunda modulate ile (base / #91999b).
CELIK = ["#5d6568", "#798184", "#858d90", "#91999b"]


def tezgah_celik():
    K = K0
    Mc = cel("Celik", CELIK, S4)
    z = duz_plaka("yuzey", 32, 150, 448, 86, 0.8, Mc, K)
    # firca izi: yatay, cok ince, hafif dalgali ton kusaklari
    Mac = flat("FircaA", "#98a0a2")
    Mko = flat("FircaK", "#8a9295")
    r = random.Random(19)
    for y in range(151, 236, 2):
        x = 32.0
        while x < 478:
            uz = r.uniform(18, 70)
            if r.random() < 0.55:
                ust_cizgi("firca", x, y + r.uniform(0, 1.2), min(479.5, x + uz), y + r.uniform(0, 1.2), 0.35, z,
                          Mac if r.random() < 0.6 else Mko, K)
            x += uz + r.uniform(4, 30)
    # tasarimdaki 65 deterministik cizik (oyunun rastgeleligini kullanmaz)
    Mci = flat("Cizik", "#a6aeb0")
    Mcg = flat("CizikG", "#7f878a")
    for i in range(65):
        x = 34 + (i * 97.0) % 436
        y = 151 + (i * 23.0) % 81
        uz = min(14.0, 476.0 - x)
        ust_cizgi("cizik", x, y + 0.3, x + uz, y + 0.55, 0.3, z + 0.01, Mci if i % 2 == 0 else Mcg, K)
    # arka kenar golgesi (raf dibinde) ve on kenara dogru hafif isik
    ust_poligon("arka_golge", [(32, 150), (480, 150), (480, 151.5), (32, 151.5)], z + 0.02, flat("ArkaGolge", "#6d7578"), K)
    ust_poligon("on_isik", [(32, 234.5), (480, 234.5), (480, 235.5), (32, 235.5)], z + 0.02, flat("OnIsik", "#a3abad"), K)


# ---------------------------------------------------------------- raf + damlama + soguk ray
def kuyu(ad, x0, gy0, w, hs, derin, Mdis, Mic, Mtab, K, cerceve=2.0, z_ust=None):
    """Yuzeye gomulu dikdortgen kuyu: ust cerceve (flans) + ice egimli
    duvarlar + taban. Ekranda (x0, gy0, w, hs); on kenar gy0+hs.
    z_ust: yuzeyin z'si (makine tablasi); verilmezse on kenar derinlik 0'da."""
    etek = 1.0
    if z_ust is None:
        z_ust = -(gy0 + hs)
        z = z_ust
    else:
        # makine tablasi dolu kutu: kuyu tablanin USTUNE oturur (taban tablanin
        # hemen ustunde, cerceve derin kadar yukarida, etek tablaya iner)
        z = z_ust + derin + 0.05
        etek = derin + 0.05
    y_on = (-z - (gy0 + hs)) / K
    D = hs / K
    c = cerceve
    bm = bmesh.new()

    def v(x, y, zz):
        return bm.verts.new((x, y + y_on, zz))
    O = [v(x0, 0, z), v(x0 + w, 0, z), v(x0 + w, D, z), v(x0, D, z)]
    Ic = [v(x0 + c, c / K * 0.5, z), v(x0 + w - c, c / K * 0.5, z), v(x0 + w - c, D - c / K * 0.5, z), v(x0 + c, D - c / K * 0.5, z)]
    for i in range(4):
        bm.faces.new((O[i], O[(i + 1) % 4], Ic[(i + 1) % 4], Ic[i]))
    Ob = [v(x0, 0, z - etek), v(x0 + w, 0, z - etek), v(x0 + w, D, z - etek), v(x0, D, z - etek)]
    for i in range(4):
        bm.faces.new((Ob[i], Ob[(i + 1) % 4], O[(i + 1) % 4], O[i]))
    ob = mesh_ob(ad + "_flans", bm, Mdis, smooth=False)
    for p in ob.data.polygons:
        if p.normal.z < -0.5:
            p.flip()
    # ic duvarlar + taban (normaller kuyunun ortasina)
    bm = bmesh.new()
    Iu = [v(x0 + c, c / K * 0.5, z), v(x0 + w - c, c / K * 0.5, z), v(x0 + w - c, D - c / K * 0.5, z), v(x0 + c, D - c / K * 0.5, z)]
    e = 1.0
    Z = [v(x0 + c + e, c / K * 0.5 + e, z - derin), v(x0 + w - c - e, c / K * 0.5 + e, z - derin),
         v(x0 + w - c - e, D - c / K * 0.5 - e, z - derin), v(x0 + c + e, D - c / K * 0.5 - e, z - derin)]
    for i in range(4):
        bm.faces.new((Iu[i], Iu[(i + 1) % 4], Z[(i + 1) % 4], Z[i]))
    ob2 = mesh_ob(ad + "_ic", bm, Mic, smooth=False)
    orta = Vector((x0 + w / 2.0, y_on + D / 2.0, 0))
    for p in ob2.data.polygons:
        c3 = Vector(p.center)
        ist = Vector((orta.x - c3.x, orta.y - c3.y, 0))
        if p.normal.dot(ist) < 0:
            p.flip()
    bm = bmesh.new()
    Zt = [v(x0 + c + e, c / K * 0.5 + e, z - derin), v(x0 + w - c - e, c / K * 0.5 + e, z - derin),
          v(x0 + w - c - e, D - c / K * 0.5 - e, z - derin), v(x0 + c + e, D - c / K * 0.5 - e, z - derin)]
    bm.faces.new(Zt)
    ob3 = mesh_ob(ad + "_taban", bm, Mtab, smooth=False)
    for p in ob3.data.polygons:
        if p.normal.z < 0:
            p.flip()
    return z


def tezgah_ust():
    K = K0
    # pencere rafi (33..476 x 140..150): krem tas/ahsap pervaz, yuvarlak on kenar
    Mraf = cel("Raf", ["#8f7950", "#a89262", "#bea775", "#f3dfb4"], S4, noise=0.03, noise_scale=40)
    pah_kutu("raf", 33, 476, 142.2, 149.2, 0, 4.4, Mraf, K, pah=0.8, seg=2)
    serit("raf_isik", 33.5, 142.4, 475.5, 142.9, -0.02, flat("RafIsik", "#f7e6c0"), K)
    serit("raf_alt", 33, 149.0, 476, 150.0, -0.3, flat("RafAlt", "#8f7950"), K)
    # damlama tepsisi (40..103 x 174..191): kalin celik cerceve, izgarali kuyu
    Mdis = cel("DamDis", ["#3a4246", "#4e585d", "#aab3ae", "#e0e5d9"], S4)
    Mic = cel("DamIc", ["#3a4448", "#56626a", "#6a767c", "#7d898e"], S4)
    Mtab = cel("DamTab", ["#48535a", "#5b676e", "#66727a", "#737f86"], S4)
    pah_kutu("dam_on", 40, 103, 186.3, 191, 0, 1.5, cel("DamOn", ["#3a4246", "#4e585d", "#c0c9c3", "#e0e5d9"], S4), K, pah=0.5)
    z = kuyu("dam", 40, 174, 63, 12.5, 3.0, Mdis, Mic, Mtab, K, cerceve=2.0)
    Mizg = cel("DamIzg", ["#3a4448", "#6f7b80", "#9aa5a8", "#c6cfcc"], S4)
    for i in range(9):
        gx = 45 + i * 6.5
        ust_cizgi("izgara", gx, 177.2, gx, 185.0, 0.9, z - 1.2, Mizg, K)
    # damla izi (kizarmis yag) -- tasarimdaki #c08a2a damlalari
    Myag = flat("Yag", "#8a6a2a")
    for gx, gy in ((63, 181.5), (69, 183.5), (74, 180.2)):
        ust_poligon("yag", [(gx - 1.2, gy - 0.4), (gx + 1.2, gy - 0.4), (gx + 1.2, gy + 0.4), (gx - 1.2, gy + 0.4)], z - 2.9, Myag, K)
    # soguk ray (104..286 x 150..186): tepsilerin oturdugu gomme kuyu
    Mrd = cel("RayDis", ["#4a555b", "#67747b", "#b5bdb7", "#dce2d8"], S4)
    Mri = cel("RayIc", ["#3d474c", "#4e5a60", "#5a666c", "#67747b"], S4)
    Mrt = cel("RayTab", ["#39434a", "#465158", "#4e5a60", "#56626a"], S4)
    kuyu("ray", 104, 150, 182, 35.5, 4.0, Mrd, Mri, Mrt, K, cerceve=1.6)
    serit("ray_on_isik", 104, 185.3, 286, 185.9, -0.02, flat("RayOnIsik", "#d1d8cc"), K)


# ---------------------------------------------------------------- servis bolmesi
def servis():
    K = K0
    Mcer = cel("SerCer", ["#2f2620", "#3a2f26", "#44372c", "#6d5a45"], S4, noise=0.04, noise_scale=30)
    Mpan = cel("SerPan", ["#4a3c2e", "#584837", "#65533e", "#7a664c"], S4, noise=0.05, noise_scale=26)
    # arka pano: dikey tahtalar
    onkutu("arka", 2, 42, 130, 266, 6, 8, Mpan, K)
    for i, x in enumerate((2, 15.3, 28.6)):
        pah_kutu("tahta", x + 0.2, x + 13.1, 130.5, 265, 5.4, 6, Mpan, K, pah=0.45)
        for j in range(3):
            dx = x + 3 + j * 3.6 + (i * 1.3) % 2
            serit("damar", dx, 133 + j * 17, dx + 0.45, 262 - j * 9, 5.35, flat("SerDamar%d" % j, "#5a4a37" if j % 2 else "#716048"), K)
    # cerceve: sol dikme, ust kiris, sag dikme (sagda isik alan kenar)
    pah_kutu("sol", 0, 2.4, 128, 270, 0, 8, Mcer, K, pah=0.5)
    pah_kutu("ust", 0, 44, 128, 131, 0, 8, Mcer, K, pah=0.5)
    pah_kutu("sag", 41.4, 44, 128, 270, 0, 8, Mcer, K, pah=0.5)
    serit("sag_isik", 42, 129, 42.6, 269, -0.05, flat("SagIsik", "#ad9266"), K)
    # zemin tahtasi + on kenar isigi
    Mzem = cel("SerZem", ["#4a3c2e", "#6b5436", "#8a6c44", "#b7935e"], S4, noise=0.04, noise_scale=30)
    duz_plaka("zemin", 2.4, 262, 39, 3.5, 0.5, Mzem, K)
    serit("zemin_on", 2.4, 265, 41.4, 266, -0.05, flat("ZemOn", "#b7935e"), K)
    onkutu("zemin_alt", 2.4, 41.4, 266, 270, -0.02, 0.5, flat("ZemAlt", "#3a2f26"), K)


# ---------------------------------------------------------------- hazirlama tahtasi
def tahta(w=150, h=48):
    """counter_design f_drawPreparation: ust yuzey y..y+h-7, on yuz 4 px,
    golge sag-alt. Capa: ST.board sol-ust."""
    K = K0
    Mg = cel("TahtaGovde", ["#4e3418", "#6a4424", "#815128", "#c9975f"], S4, noise=0.05, noise_scale=30)
    Mi = cel("TahtaIc", ["#8a6238", "#b58a58", "#c9975f", "#d7ad75"], S4, noise=0.06, noise_scale=24)
    # golge (tasarimda sag-alt koyu gri)
    ust_poligon("golge", [(3, 5), (w + 2, 5), (w + 2, h + 1), (3, h + 1)], -(h + 1.2), flat("TahtaGolge", "#505350"), K, kal=0.02)
    _, zt = yatay_plaka("tahta", 0, 0, w, h - 7, 2.2, 4.0, Mg, K)
    _, zi = yatay_plaka("ic", 2.5, 2, w - 5, h - 11, 1.6, 0.3, Mi, K, z_ust=zt + 0.3)
    r = random.Random(23)
    for g in range(7):
        T._damar(r, 5, w - 5, 6 + g * 5.2, zi, flat("Damar%d" % g, "#c99b67" if g % 2 else "#cea06b"), K)
    ust_cizgi("isik", 3, 1.2, w - 3, 1.2, 0.8, zt, flat("TahtaIsik", "#f0ce93"), K)
    # bicak izleri (tasarimdaki capraz cizikler, HD'de ince + parlak kenar)
    Mc = flat("Iz", "#c28f5b")
    Mc2 = flat("Iz2", "#e6c490")
    for i in range(int((w - 20) / 13)):
        bx, by = 9 + i * 13, 8 + (i % 3) * 7
        ust_cizgi("iz", bx, by, bx + 5, by + 4, 0.5, zi, Mc, K)
        ust_cizgi("iz2", bx + 1.2, by + 0.3, bx + 4.6, by + 3.1, 0.35, zi, Mc2, K)


# ---------------------------------------------------------------- makine govdesi
# counter_design.machine_body: acik celik cerceve + koyu ic panel + sag-alt
# golge. Burada ust yuzu gorunen kutu: ust (tabla) + on yuz serit.
CELIK_ACIK = ["#5c6b73", "#8e9a9c", "#b0b8b5", "#dfe4d8"]
CELIK_PANEL = ["#4f5b61", "#6f7c80", "#8a969a", "#a3aeb0"]


def makine(ad, x, gy, w, h, on_h, K):
    """Ekranda (x, gy, w, h): ust tabla gy..gy+h-on_h, on yuz on_h px.
    Doner: tablanin ust z'si (ust yuzde parca yerlestirmek icin)."""
    Mg = cel(ad + "Govde", CELIK_ACIK, S4)
    Mp = cel(ad + "Panel", CELIK_PANEL, S4)
    # golge (sag-alt, tasarimdaki #4c5557)
    Mgol = flat(ad + "Golge", "#4c5557")
    onkutu(ad + "_golge_alt", x + 1.5, x + w + 1, gy + h - 0.5, gy + h + 1.5, -0.05, 0.1, Mgol, K)
    onkutu(ad + "_golge_sag", x + w - 0.5, x + w + 1, gy + 3, gy + h + 1.5, -0.05, 0.1, Mgol, K)
    ust = h - on_h
    D = max(0.5, ust) / K
    zt = -(gy + ust)
    b = bmesh.new()
    bmesh.ops.create_cube(b, size=1.0)
    for v in b.verts:
        v.co.x = x if v.co.x < 0 else x + w
        v.co.y = 0 if v.co.y < 0 else D
        v.co.z = zt - on_h if v.co.z < 0 else zt
    bmesh.ops.bevel(b, geom=b.edges[:], offset=1.1, segments=2, profile=0.5, affect="EDGES")
    bmesh.ops.recalc_face_normals(b, faces=b.faces[:])
    mesh_ob(ad + "_govde", b, Mg, smooth=False)
    # on yuzde gomme panel
    onkutu(ad + "_panel", x + 2.5, x + w - 2.5, gy + ust + 1.2, gy + h - 1.6, -0.25, 0.5, Mp, K)
    serit(ad + "_panel_isik", x + 2.5, gy + ust + 1.2, x + w - 2.5, gy + ust + 1.7, -0.3, flat(ad + "PanelIsik", "#c3cccb"), K)
    return zt


def dugme(ad, gx, gy, r, K, y_on=-0.4):
    Md = cel(ad + "Dugme", ["#141c1e", "#202d2f", "#3b4a4d", "#7d8b8c"], S4)
    L.silindir(ad, r, gx, y_on - 0.6, ez(gy, y_on - 0.6, K), 1.2, Md, seg=20, eksen="Y")
    onkutu(ad + "_cizgi", gx - 0.25, gx + 0.25, gy - r + 0.4, gy - 0.4, y_on - 1.3, y_on - 1.2, flat(ad + "Cizgi", "#c7cbbb"), K)


# ---------------------------------------------------------------- fritoz (51x43)
def fritoz_govde(w=51, h=43):
    K = K0
    zt = makine("Fri", 0, 7, w, h - 7, 9, K)
    D = (h - 7 - 9) / K
    # arka kontrol kafasi (sepet askisi): tablanin arka kenarinda dik levha
    Mk = cel("FriKafa", ["#2c353a", "#394349", "#465159", "#8e9c9e"], S4)
    L.kutu("kafa", 8, w - 8, zt, zt + 7.5, D - 3, D, Mk)
    L.kutu("kafa_isik", 8.3, w - 8.3, zt + 7.1, zt + 7.6, D - 3.05, D - 2.95, flat("KafaIsik", "#c8d2cb"))
    L.kutu("kafa_yarik", 10, w - 10, zt + 2, zt + 5.5, D - 3.1, D - 3.0, flat("KafaYarik", "#1e292b"))
    # yag haznesi: tablaya gomulu kuyu, sicak yag + ustte tel sepet
    Md = cel("FriHazD", ["#2a302a", "#373e37", "#6d756c", "#9aa39a"], S4)
    Mi = cel("FriHazI", ["#232823", "#2e342e", "#373e37", "#454c45"], S4)
    My = cel("FriYag", ["#6a5012", "#866719", "#a8841f", "#b28c24"], S4, noise=0.08, noise_scale=14)
    zk = kuyu("haz", 4, 10, w - 8, 22, 3.0, Md, Mi, My, K, cerceve=1.5, z_ust=zt)
    # tel sepet: yatay ve dikey teller (yagin biraz ustunde)
    Mt = cel("FriTel", ["#6f6c57", "#8d8a6e", "#ada782", "#d8d3ae"], S4)
    Mt2 = cel("FriTel2", ["#77796c", "#9a9c89", "#b5b7a2", "#dcdfcb"], S4)
    zs = zk - 1.0
    for row in range(14, h - 12, 4):
        ust_cizgi("tel_y", 7, row, w - 7, row, 0.55, zs, Mt, K)
    for col in range(8, w - 6, 5):
        ust_cizgi("tel_d", col, 12.5, col, h - 13, 0.55, zs + 0.05, Mt2, K)
    # sepet cercevesi
    for (a, b2) in (((6.5, 12.3), (w - 6.5, 12.3)), ((6.5, h - 12.8), (w - 6.5, h - 12.8))):
        ust_cizgi("cerceve", a[0], a[1], b2[0], b2[1], 0.9, zs + 0.1, Mt, K)
    # on yuz: dugme
    dugme("fri_dugme", w - 10, h - 6, 3.0, K)
    # LED yuvasi (renk oyunda kodla)
    onkutu("led_yuva", 6.5, 12.5, h - 8.5, h - 3.5, -0.45, 0.2, flat("LedYuva", "#28302f"), K)


def fritoz_kol(w=51, h=43):
    """Sepet kolu: patateslerin USTUNDE cizilir (tasarim sirasi)."""
    K = K0
    Mk = cel("FriKol", ["#1b292c", "#262f33", "#343d40", "#6a777b"], S4)
    D = (h - 7 - 9) / K
    zt = -(7 + h - 7 - 9)
    # dikey cubuk: kafadan sepete inen
    L.kutu("kol_cubuk", w / 2 - 1.6, w / 2 + 1.6, zt + 0.5, zt + 3.5, D - 12, D - 3, Mk)
    L.kutu("kol_tutamak", w / 2 - 7, w / 2 + 7, zt + 4.5, zt + 8.5, D - 4.5, D - 2.5, cel("FriTut", ["#101a1c", "#1b292c", "#2c3b3e", "#5d6d70"], S4))


# ---------------------------------------------------------------- izgara (48x45)
def izgara2(w=48, h=45):
    K = K0
    zt = makine("Izg", 0, 5, w, h - 5, 9, K)
    D = (h - 5 - 9) / K
    # pisirme plakasi: koyu dokum, kaburgali
    Mp = cel("IzgPlaka", ["#1f2729", "#2a3437", "#343f42", "#465356"], S4)
    Mk = cel("IzgKab", ["#4f5a58", "#6c7775", "#86928e", "#b8c2bd"], S4)
    zp = kuyu("plaka", 3, 8, w - 6, 26, 1.2, cel("IzgCer", ["#28302f", "#343f42", "#5a6664", "#86928e"], S4), Mp, Mp, K, cerceve=1.2, z_ust=zt)
    for line in range(5, w - 4, 3):
        ust_cizgi("kaburga", line, 10, line, h - 13.5, 0.9, zp - 0.5, Mk, K)
    # arka kapak kolu: iki dikme + yatay cubuk
    Mkol = cel("IzgKol", ["#1b2426", "#273235", "#56625f", "#c1cbc7"], S4)
    L.kutu("kol", w / 2 - 9, w / 2 + 9, zt + 5, zt + 8.5, D - 2, D + 0.5, Mkol)
    for kx in (w / 2 - 9, w / 2 + 7.5):
        L.kutu("kol_dikme", kx, kx + 1.5, zt, zt + 5, D - 1.5, D, Mkol)
    dugme("izg_dugme", w - 9, h - 6, 3.0, K)
    onkutu("led_yuva", 5.5, 10.5, h - 8.5, h - 3.5, -0.45, 0.2, flat("LedYuva2", "#28302f"), K)


# ---------------------------------------------------------------- kesme tahtasi (51x37)
def kesme2(w=51, h=37):
    K = K0
    Mg = cel("KesGovde", ["#5a3d20", "#7a5530", "#986c40", "#d4ad73"], S4, noise=0.05, noise_scale=30)
    Mi = cel("KesIc", ["#9a7648", "#bf9660", "#d4ad73", "#e0bd88"], S4, noise=0.06, noise_scale=24)
    _, zt = yatay_plaka("tahta", 0, 3, w, h - 6, 2.2, 3.0, Mg, K)
    _, zi = yatay_plaka("ic", 1.5, 4, w - 3, h - 9, 1.6, 0.3, Mi, K, z_ust=zt + 0.3)
    r = random.Random(31)
    for g in range(5):
        T._damar(r, 4, w - 4, 8 + g * 5.5, zi, flat("KDamar%d" % g, "#c89b64" if g % 2 else "#cda26a"), K)
    ust_cizgi("isik", 3, 4.2, w - 3, 4.2, 0.7, zt, flat("KesIsik", "#ecc995"), K)
    Mc = flat("KesIz", "#b98d5a")
    for sx in range(6):
        ust_cizgi("kesik", 8 + sx * 5.5, 9, 10 + sx * 5.5, 17, 0.45, zi, Mc, K)


def satir():
    """Kesme tahtasindaki satir: dikey yatan agiz (7x13) + sap (3x7). Capa:
    agzin sol-ustu."""
    Mb = cel("SatirAgiz", ["#8f978c", "#b9c1b4", "#dde3d5", "#faf9e8"], S4)
    Ms = cel("SatirSap", ["#2e1c12", "#44291c", "#5a3927", "#8a5c40"], S4)
    L.kutu("agiz", 0, 7, -13, 0, 0, 1.0, Mb)
    L.kutu("agiz_kenar", 0, 1.0, -13, 0, -0.05, 1.0, flat("SatirKenar", "#faf9e8"))
    L.kutu("agiz_sirt", 6.2, 7, -13, 0, -0.05, 1.0, flat("SatirSirt", "#a9b0a4"))
    L.silindir("percin", 0.6, 4.5, -0.3, -3.0, 0.6, flat("Percin", "#7b8277"), seg=10, eksen="Y")
    L.kutu("sap", 2, 5, -20, -13, 0.1, 2.2, Ms)
    L.kutu("sap_isik", 2.2, 2.8, -19.5, -13.3, 0.0, 2.2, flat("SapIsik", "#8a5c40"))


def patates_butun():
    """Kesme tahtasindaki butun patates (ell 9x6). Capa: merkez."""
    K = 0.5
    Mk = cel("PatKabuk", ["#7a5424", "#9a6c30", "#bb8841", "#e5bb78"], S4, noise=0.1, noise_scale=7)
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=14, radius=1.0)
    for v in bm.verts:
        bozul = 1.0 + 0.06 * math.sin(v.co.x * 5.0 + 1.3) + 0.04 * math.cos(v.co.z * 7.0)
        v.co.x *= 9.0 * bozul
        v.co.z *= 4.2 * bozul
        v.co.y *= 5.5 * bozul
    ob = mesh_ob("patates", bm, Mk)
    ob.location = (0, 6, ez(0.5, 6, K))
    Mg = flat("PatGoz", "#896135")
    for gx, gy in ((-5, -1.5), (-1, 1.5), (3, -2.2), (6, 1)):
        I.elipsoid("goz", gx, gy, 0.6, 0.4, 0.35, 0.3, Mg, seg=8, ring=4)


# ---------------------------------------------------------------- icecek dolabi (56x58)
def icecek_govde(w=56, h=58):
    """Duvardaki icecek makinesi: on yuz (K kucuk, ust yuz 3 px)."""
    K = 0.3
    Mg = cel("IceGovde", CELIK_ACIK, S4)
    D = 3.0 / K
    zt = -3.0
    b = bmesh.new()
    bmesh.ops.create_cube(b, size=1.0)
    for v in b.verts:
        v.co.x = 0 if v.co.x < 0 else w
        v.co.y = 0 if v.co.y < 0 else D
        v.co.z = -(h - 1) if v.co.z < 0 else zt
    bmesh.ops.bevel(b, geom=b.edges[:], offset=1.2, segments=2, profile=0.5, affect="EDGES")
    bmesh.ops.recalc_face_normals(b, faces=b.faces[:])
    mesh_ob("govde", b, Mg, smooth=False)
    onkutu("golge", 1.5, w + 1, 3, h + 1, D, D + 0.2, flat("IceGolge", "#4c5557"), K)
    # dolum boslugu (bardak konur): koyu, ic tavanda golge
    Mb = cel("IceBos", ["#1c2a2c", "#223234", "#2c3e40", "#3a5053"], S4)
    onkutu("bosluk", 3, w - 3, 24, h - 6, 0.6, 1.4, Mb, K)
    onkutu("bosluk_tavan", 3, w - 3, 24, 26, 0.55, 0.6, flat("IceTavan", "#162224"), K)
    # damlama izgarasi
    Mz = cel("IceIzg", ["#475254", "#626f71", "#8e9c9a", "#bdc9c3"], S4)
    onkutu("izgara", 4, w - 4, h - 6, h - 3, -0.3, 1.2, Mz, K)
    for col in range(5, w - 4, 3):
        serit("izg_cizgi", col, h - 5.6, col + 0.8, h - 3.2, -0.35, flat("IzgCizgi", "#d6e0da"), K)
    # ust panel cercevesi (musluk pencerelerinin yuvasi)
    onkutu("panel", 2.5, w - 2.5, 3, 23, -0.1, 0.4, cel("IcePanel", CELIK_PANEL, S4), K)


ICECEK = {"fanta": ("#e59a32", ["#8a4f12", "#c07420", "#e59a32", "#f7c06a"]),
          "cola": ("#a83e2d", ["#4a1810", "#7a261a", "#a83e2d", "#d0644e"]),
          "ayran": ("#c9dcc6", ["#7f9480", "#a9bda9", "#c9dcc6", "#eef6ea"])}


def musluk(n, tip):
    """Musluk penceresi + etiket + agiz. Capa: pencerenin sol-ustu (cx-seg/2, y+4)."""
    def fn():
        K = 0.3
        w = 56.0
        seg = w / n - 4
        renk, rampa = ICECEK[tip]
        # pencere cercevesi + arkadan aydinlatilmis renkli panel
        onkutu("cerceve", 0, seg, 0, 18, -0.2, 0.3, cel("MusCer" + tip, ["#1f3034", "#2a3d42", "#344b50", "#557277"], S4), K)
        onkutu("panel", 1, seg - 1, 1, 16, -0.45, -0.2, cel("MusPan" + tip, rampa, S4), K)
        # parlaklik: ust serit + capraz yansima
        serit("parlak", 1.6, 2, seg - 1.6, 2.6, -0.5, flat("MusParlak", "#f0d9ac" if tip != "ayran" else "#ffffff"), K)
        serit("yansima", 2, 4, min(seg - 2, 3.2), 14.5, -0.48, flat("MusYans" + tip, rampa[3]), K)
        # etiket: bardak / sise silueti
        cx = seg / 2.0
        et = "#faf0d9" if tip == "ayran" else "#3a2920"
        onkutu("etiket", cx - 2.5, cx + 2.5, 6, 14, -0.6, -0.45, flat("Etiket" + tip, et), K)
        onkutu("etiket_ust", cx - 1.5, cx + 1.5, 4, 7, -0.62, -0.45, flat("EtiketUst", "#e6e3c8"), K)
        if tip == "ayran":
            serit("etiket_bant", cx - 2.5, 9, cx + 2.5, 10.5, -0.63, flat("AyranBant", "#3f79c0"), K)
        # musluk agzi (pencerenin altinda, govdeden cikar)
        Ma = cel("MusAgiz", ["#5f6f72", "#84969a", "#c4d0c8", "#eef4ee"], S4)
        pah_kutu("agiz", cx - 3, cx + 3, 20, 24, -2.4, 0.5, Ma, K, pah=0.5)
        onkutu("agiz_uc", cx - 1, cx + 1, 24, 28, -1.6, -0.6, cel("MusUc", ["#3e4b4e", "#5b6b6e", "#84969a", "#b5c4c2"], S4), K)
        serit("agiz_golge", cx + 3, 21, cx + 3.6, 26, 0.45, flat("AgizGolge", "#182e32"), K)
    return fn


# ---------------------------------------------------------------- kagit (24x27)
def kagit_makine2(w=24, h=27):
    K = 0.3
    makine("Kag", 0, 3, w, h - 4, 18, K)
    Ms = cel("KagYarik", ["#141b1d", "#1d272a", "#273237", "#3c4a50"], S4)
    onkutu("yarik", 3, w - 3, 7, 13, -0.6, 0.3, Ms, K)
    # yariktan cikan kagit (kremsi, kirmizi serit)
    Mk = cel("KagKagit", ["#b9b39e", "#ddd6c0", "#f4edda", "#fffaf0"], S4)
    pah_kutu("kagit", 5, w - 5, 10, 21, -1.2, -0.6, Mk, K, pah=0.3)
    serit("kagit_serit", 6, 14, w - 6, 14.8, -1.25, flat("KagSerit", "#ce4935"), K)
    onkutu("led_yuva", 2.5, 6.5, 2.6, 6.4, -0.5, 0.2, flat("KagLedYuva", "#28302f"), K)


def kagit_yigin2(w=24, h=27):
    K = 0.4
    Mt = cel("YigTaban", ["#3f484b", "#56636a", "#657174", "#d4ddd5"], S4)
    duz_plaka("taban", 0, 5, w, 3.5, 0.8, Mt, K)
    onkutu("taban_on", 0, w, 8.5, h, 0, 1, Mt, K)
    serit("taban_isik", 0, 8.5, w, 9, -0.05, flat("YigIsik", "#d4ddd5"), K)
    Mk = cel("YigKagit", ["#9c9a88", "#bbb9a5", "#e8e2cc", "#faf4df"], S4)
    for i in range(4, -1, -1):
        y0 = 4 + i * 2
        pah_kutu("yaprak", 2, w - 2, y0, y0 + 15, -0.4 - (4 - i) * 0.05, 0.2, Mk, K, pah=0.25)
        serit("yaprak_serit", 4, y0 + 2, w - 4, y0 + 2.6, -0.5 - (4 - i) * 0.05, flat("YigSerit", "#cf4832"), K)


# ---------------------------------------------------------------- stok cekmecesi (49x28)
def stok2(w=49, h=28, kavanoz=True):
    K = 0.4
    makine("Stk", 0, 0, w, h, 26, K)
    Mo = cel("StkOyuk", ["#1c2628", "#26323a", "#303e42", "#56666a"], S4)
    pah_kutu("oyuk", w / 2 - 9, w / 2 + 9, 6, 10, -0.9, 0.2, Mo, K, pah=0.5)
    serit("oyuk_isik", w / 2 - 7, 6, w / 2 + 7, 6.5, -0.95, flat("OyukIsik", "#c1cdc5"), K)
    if not kavanoz:
        return
    # iki kavanoz: tursu (yesil) + yogurt (krem)
    for i, (govde, kapak) in enumerate((("#647633", "#c4d2cc"), ("#eee5cc", "#c4d2cc"))):
        kx = 8 + i * 9 + 3
        koyu = ["#3c4a1e", "#52632a"] if i == 0 else ["#b3aa90", "#d4cbb1"]
        acik = "#8fa451" if i == 0 else "#fff8e6"
        L.silindir("kavanoz", 3.0, kx, -1.6, ez(20.5, -1.6, K), 7, cel("Kav%d" % i, koyu + [govde, acik], S4), seg=16)
        L.silindir("kav_kapak", 3.2, kx, -1.6, ez(16.8, -1.6, K), 1.4, cel("KavK%d" % i, ["#7d8a86", "#9dacaa", kapak, "#eef6f2"], S4), seg=16)


# ---------------------------------------------------------------- tatli tepsisi (34x27)
# Kullanici: "tatli tepsisini duzenle". Bakir baklava tepsisi (kalkik kenar,
# serbet parlakligi) + ayri baklava dilimleri (oyun kalan sayiya gore dizer).
def tatli_tepsi(w=34, h=27):
    K = K0
    Mb = cel("Bakir", ["#5a2a10", "#8a4a1e", "#b8703a", "#e8a86a"], S4)
    Mi = cel("BakirIc", ["#6a3814", "#8a5020", "#a8682e", "#c88848"], S4, noise=0.05, noise_scale=20)
    T.ust_poligon("golge", [(2, 4), (w + 1.5, 4), (w + 1.5, h + 1), (2, h + 1)], -(h + 1.2), px.flat_a("TatliGolge", "#1a1a1a", 0.35), K, kal=0.02)
    # kalkik kenarli tepsi: kenar (flans) + ice egimli duvar + taban (kuyu gibi)
    zt = kuyu("tepsi", 0, 0, w, h - 3, 2.2, Mb, Mb, Mi, K, cerceve=1.8)
    onkutu("on_kenar", 0.3, w - 0.3, h - 3, h - 0.5, -0.05, 0.2, cel("BakirOn", ["#5a2a10", "#7a3e18", "#a0602e", "#c8804a"], S4), K)
    ust_cizgi("isik", 2.5, 0.6, w - 2.5, 0.6, 0.6, zt + 0.02, px.flat("BakirIsik", "#f6c890"), K)
    ust_poligon("serbet", [(6, 6), (15, 6), (12, 9), (5, 9)], zt - 2.18, px.flat_a("Serbet", "#ffe6a0", 0.35), K)


def baklava_dilim():
    """Tek baklava dilimi: eskenar dortgen ust yuz, katli yan yuz, fistik.
    Capa: dilimin merkezi."""
    K = K0
    Mu = cel("BakUst", ["#8a4f14", "#c07a2c", "#dca048", "#f4c878"], S4, noise=0.06, noise_scale=16)
    Mk = cel("BakKat", ["#6a3810", "#9a5c1c", "#c88438", "#e8b060"], S4)
    ust = [(-5.0, 0.0), (0.0, -3.0), (5.0, 0.0), (0.0, 3.0)]
    kal = 2.4
    bm = bmesh.new()
    alt = [bm.verts.new((x, (-gy) / K, -kal)) for x, gy in ust]
    tep = [bm.verts.new((x, (-gy) / K, 0.0)) for x, gy in ust]
    for i in range(4):
        bm.faces.new((alt[i], alt[(i + 1) % 4], tep[(i + 1) % 4], tep[i]))
    bm.faces.new(list(reversed(alt)))
    bm.faces.new(tep)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = mesh_ob("baklava", bm, Mk, smooth=False)
    ob.data.materials.append(Mu)
    for p in ob.data.polygons:
        if p.normal.z > 0.9:
            p.material_index = 1
    # yan yuzde yufka katlari (ince acik cizgiler)
    for zz in (-0.7, -1.5):
        for (x0, g0), (x1, g1) in ((ust[3], ust[0]), (ust[2], ust[3])):
            ust_cizgi("kat", x0, g0 + (-zz) * 0.0, x1, g1, 0.25, zz, px.flat("Kat", "#f0c070"), K)
    # fistik kirintisi
    Mf = cel("Fistik", ["#2f5a14", "#4a7a22", "#6aa032", "#9ac85a"], S4)
    for q, (fx, fy) in enumerate(((-0.8, -0.4), (0.6, 0.3), (0.1, -1.0), (-0.2, 0.8))):
        e = I.elipsoid("fistik%d" % q, fx, fy, 0.7, 0.4, 0.5, 0.0, Mf, seg=8, ring=4)
        e.location = (fx, (-fy) / K, 0.35)


# ---------------------------------------------------------------- depo cekmecesi ikonlari
# Kullanici: "iki sey varmis gibi gorunuyor ama ici dolu". Cekmecenin onune
# ACIK olan butun stok turlerinin kucuk ikonu dizilir (oyun hangilerinin
# acik oldugunu bilir). Capa: ikonun alt-orta noktasi.
def stok_ikon(tur):
    def fn():
        K = 0.4
        if tur == "pickle":
            L.silindir("kav", 2.6, 0, -1.2, ez(-3.2, -1.2, K), 6.2, cel("IkTursu", ["#2e3a12", "#4a5c1e", "#647633", "#8fa451"], S4), seg=16)
            L.silindir("kapak", 2.8, 0, -1.2, ez(-6.9, -1.2, K), 1.2, cel("IkKapak", ["#7d8a86", "#9dacaa", "#c4d2cc", "#eef6f2"], S4), seg=16)
            for q in range(3):
                e = I.elipsoid("t", -1.2 + q * 1.2, -2.6 - (q % 2) * 1.4, 0.8, 0.5, 0.3, -2.8, px.flat("IkTursuD", "#a8ca52"), seg=8, ring=4)
                e.location.z = ez(-2.6 - (q % 2) * 1.4, -2.8, K)
        elif tur == "yogurt":
            T.torna("kova", [(2.4, 0.0), (3.0, 5.6)], 0, 0, 0.0, 0.8, cel("IkYog", ["#b9b19c", "#dcd6c6", "#f4f0e4", "#ffffff"], S4), K)
            T.torna("bant", [(2.75, 2.0), (2.9, 3.4)], 0, 0, 0.0, 0.8, px.flat("IkYogBant", "#3f79c0"), K, kapak=False)
            T.torna("kapak", [(3.2, 5.6), (3.2, 6.5)], 0, 0, 0.0, 0.8, cel("IkYogKap", ["#2f5a90", "#3f79c0", "#5a94d6", "#8ab8ea"], S4), K)
        elif tur == "ayran":
            T.torna("sise", [(1.8, 0.0), (2.0, 4.4), (1.1, 6.0), (0.9, 7.4)], 0, 0, 0.0, 0.8, cel("IkAyran", ["#b9c4c8", "#dfe7ec", "#f8f6ee", "#ffffff"], S4), K)
            T.torna("bant", [(2.05, 1.6), (2.05, 3.2)], 0, 0, 0.0, 0.8, px.flat("IkAyranBant", "#3f79c0"), K, kapak=False)
            T.torna("kapak", [(1.1, 7.4), (1.1, 8.6)], 0, 0, 0.0, 0.8, cel("IkAyranKap", ["#2f5a90", "#3f79c0", "#5a94d6", "#8ab8ea"], S4), K)
        elif tur == "sweet":
            # iki kat baklava dilimi (kenari kizarmis, ustu fistikli)
            Mb = cel("IkBaklava", ["#8a4f14", "#b8702a", "#d9953e", "#f4c070"], S4)
            L.kutu("baklava", -3.4, 3.4, 0.0, 4.2, -1.5, 3.5, Mb)
            for zz in (1.4, 2.8):
                onkutu("kat", -3.4, 3.4, -zz - 0.3, -zz, -1.55, 3.5, px.flat("IkKat", "#b8702a"), K)
            onkutu("fistik", -1.4, 1.4, -5.6, -4.7, 0.2, 1.2, px.flat("IkFistik", "#6aa032"), K)
        elif tur == "tomato":
            e = I.elipsoid("domates", 0, -2.6, 2.8, 2.4, 2.2, 0.0, cel("IkDomates", ["#7a1a12", "#b82a1c", "#e2483a", "#ff8a70"], S4), seg=16, ring=10)
            e.location.z = ez(-2.6, 0.0, K)
            for q in range(4):
                a = q * 1.57
                onkutu("sap", math.cos(a) * 0.9 - 0.3, math.cos(a) * 0.9 + 0.3, -5.4 + math.sin(a) * 0.3, -4.8, -2.3, -2.0, px.flat("IkDomSap", "#3f7a22"), K)
        elif tur == "pepper":
            e = I.elipsoid("biber", 0, -3.2, 1.3, 3.2, 1.2, 0.0, cel("IkBiber", ["#2f5a14", "#4a7a22", "#6aa032", "#9ac85a"], S4), seg=12, ring=10)
            e.location.z = ez(-3.2, 0.0, K)
            e.rotation_euler = (0, math.radians(18), 0)
            onkutu("sap", -0.3, 0.5, -7.2, -6.0, -0.9, -0.2, px.flat("IkBiberSap", "#2f5a14"), K)
    return fn


# ---------------------------------------------------------------- patates kasasi (46x28)
def patates_kasa2(w=46, h=28):
    K = 0.5
    Mc = cel("KasaDis", ["#3a2816", "#553c22", "#7a5630", "#a37542"], S4, noise=0.05, noise_scale=30)
    Mi = flat("KasaIc", "#302719")
    onkutu("arka", 0, w, 0, h, 8, 9, Mi, K)
    pah_kutu("sol", 0, 2, 0, h, 0, 9, Mc, K, pah=0.4)
    pah_kutu("sag", w - 2, w, 0, h, 0, 9, Mc, K, pah=0.4)
    onkutu("ust", 0, w, 0, 2, 0, 9, Mc, K)
    # patatesler: tasarimdaki 12 yeri (7+(i*9)%(w-13), 7+(i*7)%(h-13))
    Mp = cel("KasaPat", ["#6d4c26", "#946a38", "#b98a49", "#d4aa69"], S4, noise=0.08, noise_scale=6)
    for i in range(12):
        px_ = 7 + (i * 9.0) % (w - 13)
        py_ = 7 + (i * 7.0) % (h - 13)
        dy = 4.0 - (py_ / h) * 3.0
        e = I.elipsoid("pat", px_, py_, 5.0, 3.8, 3.5, dy, Mp, seg=14, ring=8)
        e.location.z = ez(py_, dy, K)
    # on citalar (yatay iki cita + dikey ince cubuklar)
    Mci = cel("KasaCita", ["#5a3f1e", "#86632e", "#bb8b4a", "#d9ac6a"], S4, noise=0.05, noise_scale=30)
    for yy in (h - 10, h - 4):
        pah_kutu("cita", 2, w - 2, yy, yy + 2, -0.6, 0.4, Mci, K, pah=0.35)
    for xx in range(3, w - 2, 7):
        onkutu("cubuk", xx, xx + 1, h - 11, h - 1, -0.4, 0.2, flat("KasaCubuk", "#86632e"), K)


# ---------------------------------------------------------------- cop (31x50)
def cop2(w=31, h=50):
    K = 0.5
    Mg = cel("CopGovde", ["#2c3436", "#394244", "#454e50", "#6e7a7c"], S4)
    Mi = cel("CopOn", ["#232d30", "#2b3739", "#303c3f", "#46565a"], S4)
    pah_kutu("govde", 2, w - 2, 7, h - 1, 0, 8, Mg, K, pah=1.0, seg=2)
    onkutu("on", 5, w - 5, 9, h - 3, -0.3, 0.3, Mi, K)
    serit("on_isik", 5, 9.5, 5.6, h - 4, -0.35, flat("CopIsik", "#526367"), K)
    # kapak: ustu acik halka (agiz koyu)
    Mk = cel("CopKapak", ["#4a5454", "#5f6a6a", "#778282", "#b3bcba"], S4)
    _, zk = yatay_plaka("kapak", 0, 0, w, 7.5, 2.0, 2.5, Mk, K)
    yatay_plaka("agiz", 3, 1.5, w - 6, 4.5, 1.2, 0.2, flat("CopAgiz", "#172225"), K, z_ust=zk + 0.2)
    # pedal
    pah_kutu("pedal", w / 2 - 5, w / 2 + 5, h - 3, h, -2.5, 0.5, Mk, K, pah=0.4)


# ---------------------------------------------------------------- ekmek altligi (48x35)
def altlik(w=48, h=35):
    K = K0
    Mg = cel("AltGovde", ["#4a3018", "#6b4526", "#906238", "#d7ac72"], S4, noise=0.05, noise_scale=30)
    Mi = cel("AltIc", ["#7d5530", "#93673c", "#a67446", "#c59560"], S4, noise=0.06, noise_scale=24)
    _, zt = yatay_plaka("altlik", 0, 0, w, h - 3, 1.5, 2.5, Mg, K)
    _, zi = yatay_plaka("ic", 2, 1.5, w - 4, h - 7, 1.2, 0.25, Mi, K, z_ust=zt + 0.25)
    ust_cizgi("isik", 1.5, 0.6, w - 1.5, 0.6, 0.6, zt, flat("AltIsik", "#e3bc84"), K)
    r = random.Random(41)
    for g in range(4):
        T._damar(r, 4, w - 4, 5 + g * 6.5, zi, flat("AltDamar%d" % g, "#9a6a3e"), K)


# ---------------------------------------------------------------- ekmek altligindaki yiginlar
# Capa: ST.bread sol-ust (altlik 48x35 bunun (0,3)'unde). Kullanici: "ekmekler
# tahtaya oturmuyor" -> tabaksiz, altligin USTUNE oturan yiginlar.
def _lavas_yigin(cx, taban_gy, adet, rx, K):
    Ml = cel("LavasY", ["#b8925a", "#d8b581", "#f0d5a8", "#f8e6c4"], S4, noise=0.10, noise_scale=14)
    Mk = cel("LavasKenar", ["#9c7644", "#c49a62", "#dcb27a", "#ecc894"], S4, noise=0.08, noise_scale=10)
    Mg = px.flat_a("LavasGolge", "#3a2210", 0.35)
    I.yatay_elips("golge", cx + 1.0, taban_gy + 1.2, rx + 1.5, 0.1, Mg, K, ry_ekran=4.6)
    for i in range(adet):
        gy = taban_gy - i * 2.6
        r = rx - (i % 2) * 0.6 - i * 0.25
        I.yatay_elips("lavas%d" % i, cx + (0.6 if i % 2 else -0.4), gy, r, 1.3, Mk if i < adet - 1 else Ml, K, ry_ekran=4.2, egim=0.05)
    ust = taban_gy - (adet - 1) * 2.6
    Mb = px.flat("LavasBenek", "#c39a63")
    for q in range(8):
        a = q * 2.1
        e = I.elipsoid("benek", cx + math.cos(a) * (2.5 + q * 1.3), ust - 1.2 + math.sin(a) * 1.4, 0.9, 0.5, 0.5, -1.4, Mb, seg=8, ring=4)
        e.location.z = ez(ust - 1.2 + math.sin(a) * 1.4, -1.4, K) + 1.3


def _pide_yigin(cx, taban_gy, adet, rx, K):
    Mp = cel("PideY", ["#7a4e20", "#a06a2e", "#d9a765", "#eec78c"], S4, noise=0.12, noise_scale=12)
    Mg = px.flat_a("PideGolge", "#3a2210", 0.35)
    I.yatay_elips("golge", cx + 1.0, taban_gy + 1.4, rx + 1.5, 0.1, Mg, K, ry_ekran=4.0)
    for i in range(adet):
        I.yatay_elips("pide%d" % i, cx, taban_gy - i * 3.2, rx - i * 0.8, 2.2, Mp, K, ry_ekran=3.6, egim=0.18)
    ust = taban_gy - (adet - 1) * 3.2
    Mb = px.flat("PideSusam", "#8a5f31")
    for q in range(7):
        # ust pidenin ust yuzunde (merkez derinlik 0, yuzey z = -gy + kalinlik/2)
        gy = ust - 0.6 + ((q * 3) % 5 - 2) * 0.45
        e = I.elipsoid("susam", cx - 9 + q * 3, gy, 0.7, 0.4, 0.4, 0.0, Mb, seg=8, ring=4)
        e.location = (cx - 9 + q * 3, 0.0, -gy + 1.1)


def ekmek_lavas_tek():
    _lavas_yigin(24.0, 27.0, 6, 17.0, K0)


def ekmek_pide_arka():
    _pide_yigin(24.0, 17.0, 3, 15.0, K0)


def ekmek_lavas_on():
    _lavas_yigin(24.0, 31.0, 4, 16.0, K0)


# ---------------------------------------------------------------- patates sepeti (46x28)
def patates_sepet(w=46, h=28):
    """Remake'in patates dolabi (istasyon_hd.patates_dolap): koyu oyuklu ahsap
    dolap + hasir sepet. Yuva alcak oldugu icin patatesler iki sira, her biri
    ayri tonda (yigin tek yumru gibi gorunmesin)."""
    Mah = cel("DolapAhsap", ["#2e2010", "#4e3a18", "#6d5228", "#8a6a3a"], S4)
    L.kutu("oyuk", 0, w, -h, 0, 4, 6, px.flat("DolapIc", "#3a2a12"))
    for ad, x0, x1, z0, z1 in (("ust", 0, w, -2, 0), ("alt", 0, w, -h, -h + 2),
                               ("sol", 0, 2, -h, 0), ("sag", w - 2, w, -h, 0)):
        L.kutu(ad, x0, x1, z0, z1, -1, 5, Mah)
    sx, sw, sy, sh = 2, w - 4, 4, h - 6
    Msep = cel("Sepet", ["#4e3a18", "#6d5228", "#a5813f", "#c9a45e"], S4)
    L.kutu("sepet_arka", sx, sx + sw, -(sy + sh), -sy, 2.5, 3.5, cel("SepetIc", ["#3a2a12", "#4e3a18", "#5b4420", "#6d5228"], S4))
    tonlar = [cel("Pat%d" % i, r, S4, noise=0.14, noise_scale=9) for i, r in enumerate((
        ["#5e3e16", "#8a5e26", "#b98a48", "#dcb574"],
        ["#6e4a1c", "#9a6a2c", "#c49a54", "#e2bf7a"],
        ["#664418", "#906430", "#bd9250", "#d8b070"]))]
    Mg = px.flat("PatGoz", "#5e3e16")
    r = random.Random(11)
    # arka sira (yuksekte, geride) + on sira (asagida, onde)
    for sira, (n, gy0, derin, rr) in enumerate(((6, sy + 7.5, 1.2, 3.9), (5, sy + 11.0, -0.8, 4.2))):
        for i in range(n):
            u = (i + 0.5) / n
            ox = sx + 3 + u * (sw - 6) + r.uniform(-0.8, 0.8) + (1.8 if sira else 0)
            oy = gy0 + r.uniform(-0.8, 0.8)
            e = I.elipsoid("pat%d_%d" % (sira, i), ox, oy, rr * r.uniform(0.95, 1.12), rr * 0.74, rr * 0.8, derin, tonlar[(i + sira) % 3], seg=16, ring=10)
            e.rotation_euler = (0, r.uniform(-0.35, 0.35), 0)
            for q in range(2):
                a = r.uniform(0, 6.28)
                g = I.elipsoid("goz", ox + math.cos(a) * rr * 0.5, oy - 1.0 + math.sin(a) * rr * 0.3, 0.45, 0.3, 0.3, derin - rr * 0.8, Mg, seg=6, ring=4)
    # on orgu: yatay seritler + dikey cubuklar
    oy0 = sy + round(sh * .5)
    for gy in range(oy0, sy + sh, 3):
        L.kutu("orgu", sx, sx + sw, -(gy + 2), -gy, -5.2, -4.2, Msep)
    for gx in range(0, sw, 4):
        L.kutu("orucu", sx + gx, sx + gx + 1, -(sy + sh), -oy0, -5.6, -5.0, cel("Orucu", ["#4e3a18", "#6d5228", "#a5813f", "#c09a52"], S4))
    L.kutu("cember", sx - 1, sx + sw + 1, -(oy0 + 1.2), -(oy0 - 0.8), -5.8, -4.0, cel("Cember", ["#6d5228", "#8a6a3a", "#a5813f", "#c9a45e"], S4))
    L.kutu("taban", sx - 1, sx + sw + 1, -(sy + sh), -(sy + sh - 2), -5.8, 3.6, Msep)


# ---------------------------------------------------------------- sos siseleri
# Kullanici: "soslar kesik gibi, yarim gibi". Klasik sikma sise: TAMAMEN dolu
# renkli govde (acik: kirmizi / sarimsak: krem / tereyag: sari), ortada
# sarili etiket + ikon, yuvarlak omuz, vidali kapak ve sivri uc. Capa:
# sisenin (cx, taban). Tasarim olcusu: govde 10x14, kapak 6x4, uc 2x5.
SOS2 = [{"ramp": ["#6e140e", "#a8231a", "#d8362a", "#f25a44"], "cap": "#3a2a24"},
        {"ramp": ["#b3aa92", "#d9d1bb", "#f1ecdd", "#ffffff"], "cap": "#6f7a84"},
        {"ramp": ["#9a6a0c", "#d0921c", "#f0b53c", "#ffd77a"], "cap": "#7a4f16"}]


def sise2(i):
    def fn():
        K = 0.3
        d = SOS2[i]
        ym, der = 2.5, 0.6
        hw, gov, omuz, boyun = 5.0, 10.0, 3.0, 1.0
        Mg = cel("Sise%d" % i, d["ramp"], S4)
        prof = [(hw - 1.2, 0.0), (hw - 0.3, 0.5), (hw, 1.4), (hw, gov - 0.6)]
        for k in range(1, 5):
            a = k / 4.0
            prof.append((hw - (hw - 2.6) * math.sin(a * math.pi / 2), gov - 0.6 + (omuz + 0.6) * (1 - math.cos(a * math.pi / 2))))
        prof.append((2.4, gov + omuz + boyun))
        T.torna("govde", prof, 0, 0, ym, der, Mg, K)
        # parlak serit: sol-onde dikey yansima (plastik parlakligi)
        yon = ym - hw * der
        onkutu("parlak", -3.4, -2.6, -(gov - 1.0), -2.0, yon - 0.35, yon - 0.1, px.flat("Parlak%d" % i, d["ramp"][3]), K)
        # etiket: govdenin ortasinda sarili bant + ince cerceve
        e_alt, eh = 2.4, 5.6
        T.torna("etiket", [(hw + 0.12, e_alt), (hw + 0.12, e_alt + eh)], 0, 0, ym, der,
                cel("Etiket%d" % i, ["#b9b19c", "#d8d0bb", "#f6f1e3", "#ffffff"], S4), K, kapak=False)
        for zz in (e_alt, e_alt + eh - 0.5):
            T.torna("etiket_cizgi", [(hw + 0.16, zz), (hw + 0.16, zz + 0.5)], 0, 0, ym, der, px.flat("EtiketCizgi%d" % i, d["ramp"][1]), K, kapak=False)
        lcy = -(e_alt + eh / 2.0)
        yon_e = ym - (hw + 0.12) * der - 0.35
        if i == 0:
            b = I.elipsoid("biber", 0, lcy, 2.3, 1.3, 0.5, yon_e, cel("Biber", ["#8e1c14", "#c02a20", "#e2382a", "#ff7a62"], S4), seg=12, ring=6)
            b.location.z = ez(lcy, yon_e, K)
            b.rotation_euler = (0, math.radians(-20), 0)
            sp = I.elipsoid("sap", 2.1, lcy - 1.3, 0.7, 0.4, 0.3, yon_e - 0.3, px.flat("Sap", "#5a8a2a"), seg=8, ring=4)
            sp.location.z = ez(lcy - 1.3, yon_e - 0.3, K)
        elif i == 1:
            # beyaz etikette secilsin: mor-bej sarimsak basi + dis cizgileri
            b = I.elipsoid("sarimsak", 0, lcy + 0.3, 2.2, 2.0, 0.5, yon_e, cel("Sarimsak", ["#6e5a6a", "#9a8494", "#c9b8c0", "#ebe0e4"], S4), seg=12, ring=6)
            b.location.z = ez(lcy + 0.3, yon_e, K)
            for dx in (-0.9, 0.9):
                onkutu("dis", dx - 0.2, dx + 0.2, lcy - 1.4, lcy + 1.5, yon_e - 0.6, yon_e - 0.45, px.flat("SarDis", "#6e5a6a"), K)
            u = I.elipsoid("uc", 0, lcy - 1.9, 0.4, 0.8, 0.3, yon_e - 0.2, px.flat("SarUc", "#6e5a6a"), seg=8, ring=4)
            u.location.z = ez(lcy - 1.9, yon_e - 0.2, K)
        else:
            Mt = cel("Tereyag", ["#a8680a", "#d88a14", "#f0a82c", "#ffd060"], S4)
            onkutu("tereyag_golge", -2.6, 2.9, lcy - 1.3, lcy + 1.9, yon_e - 0.5, yon_e, px.flat("TereyagGolge", "#9a6a2a"), K)
            onkutu("tereyag", -2.4, 2.6, lcy - 1.6, lcy + 1.6, yon_e - 0.8, yon_e, Mt, K)
            onkutu("tereyag_ust", -2.4, 2.6, lcy - 1.6, lcy - 1.1, yon_e - 0.85, yon_e, px.flat("TereyagIsik", "#ffe39a"), K)
        # kapak: vidali halka + kapak + sivri uc
        cap = d["cap"]
        z0 = gov + omuz + boyun
        T.torna("halka", [(3.1, z0 - 0.3), (3.1, z0 + 1.2)], 0, 0, ym, der, cel("KapH%d" % i, [T.hexmul(cap, .5), T.hexmul(cap, .75), cap, T.hexmul(cap, 1.3)], S4), K)
        T.torna("kapak", [(2.9, z0 + 1.2), (2.9, z0 + 3.2), (1.6, z0 + 4.2)], 0, 0, ym, der, cel("Kap%d" % i, [T.hexmul(cap, .6), cap, T.hexmul(cap, 1.3), T.hexmul(cap, 1.6)], S4), K)
        T.torna("uc", [(1.1, z0 + 4.0), (0.7, z0 + 7.5), (0.3, z0 + 8.2)], 0, 0, ym, der, cel("Uc%d" % i, [T.hexmul(cap, .7), cap, T.hexmul(cap, 1.3), T.hexmul(cap, 1.6)], S4), K)
        # taban golgesi yerine alt kenar koyulugu (sise masaya oturur)
        T.torna("taban", [(hw - 1.1, 0.0), (hw - 1.1, 0.4)], 0, 0, ym, der, px.flat("SiseTaban%d" % i, d["ramp"][0]), K)
    return fn


parca("tezgah_alt", (32, 235, 448, 35), tezgah_alt)
parca("tezgah_celik", (32, 149, 448, 88), tezgah_celik)
parca("tezgah_ust", (32, 139, 448, 53), tezgah_ust)
parca("servis", (0, 128, 44, 142), servis)
parca("tahta", (-1, -1, 154, 51), tahta)
parca("fritoz_govde", (-2, -1, 56, 47), fritoz_govde)
parca("fritoz_kol", (10, -1, 32, 22), fritoz_kol)
parca("izgara_govde", (-2, -1, 53, 49), izgara2)
parca("kesme_tahta", (-1, 1, 54, 38), kesme2)
parca("satir", (-1, -1, 9, 23), satir, K=0.3, cizgi="#2e2a24", cizgi_alfa=120)
parca("patates_butun", (-11, -8, 22, 16), patates_butun, cizgi="#4d3418", cizgi_alfa=130)
parca("icecek_govde", (-1, -1, 60, 62), icecek_govde, K=0.3)
for _n in (1, 2, 3):
    for _t in ("fanta", "cola", "ayran"):
        _seg = 56.0 / _n - 4
        parca("musluk_%d_%s" % (_n, _t), (-1, -1, int(_seg) + 3, 31), musluk(_n, _t), K=0.3)
parca("kagit_makine", (-1, 1, 27, 28), kagit_makine2, K=0.3)
parca("kagit_yigin", (-1, 2, 26, 26), kagit_yigin2, K=0.4)
parca("stok", (-1, -1, 52, 31), stok2, K=0.4)
parca("stok_bos", (-1, -1, 52, 31), lambda: stok2(kavanoz=False), K=0.4)
parca("tatli_tepsi", (-1, -1, 38, 31), tatli_tepsi)
parca("baklava_dilim", (-6, -5, 12, 9), baklava_dilim, cizgi="#4a2a08", cizgi_alfa=120)
for _t in ("pickle", "yogurt", "ayran", "sweet", "tomato", "pepper"):
    parca("stok_ikon_%s" % _t, (-5, -11, 10, 12), stok_ikon(_t), K=0.4, cizgi="#1c2426", cizgi_alfa=110)
# Kullanici: onceki oyunun patates sepeti daha iyi -> remake'in dolap + hasir
# sepet modeli yeni yuvanin olcusunde (46x28)
parca("patates_kasa", (-1, -1, 48, 31), patates_sepet, K=0.3, cizgi="#2a1c0c", cizgi_alfa=120)
parca("cop", (-1, -1, 34, 52), cop2)
parca("altlik", (-1, -1, 50, 37), altlik)
parca("kutu_raf_46", (0, 12, 46, 8), lambda: T.kutu_raf(46), K=0.4)
parca("ekmek_lavas_tek", (2, 2, 44, 34), ekmek_lavas_tek, cizgi="#8a6a3a", cizgi_alfa=110)
parca("ekmek_pide_arka", (4, 4, 40, 22), ekmek_pide_arka, cizgi="#5a3a18", cizgi_alfa=110)
parca("ekmek_lavas_on", (3, 16, 42, 22), ekmek_lavas_on, cizgi="#8a6a3a", cizgi_alfa=110)
for _i in range(3):
    parca("sise_%d" % _i, (-8, -25, 16, 28), sise2(_i), K=0.3, cizgi=T.hexmul(SOS2[_i]["ramp"][0], .7), cizgi_alfa=150)


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
    print("TEZGAH2_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
