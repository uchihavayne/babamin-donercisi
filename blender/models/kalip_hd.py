"""MUSTERI KALIP KIYAFETLERI — remake HD, renk BOLGESI gecisleriyle.

    blender --background --factory-startup --python blender/models/kalip_hd.py [-- onek ...]
    python blender/hd_atlas.py kalip_hd kalip

chars.js drawKalipGovde / drawKalipBas: isci, memur, ogrenci, yasli, turist,
sporcu, kurye, sofor (ozel kaliplar oyunda kapali: OZEL_ACIK = false).
Bir kiyafet birden cok renk kaynagindan boyaniyor: kalibin ana rengi (tohumla
secilen), altindaki gomlek (sh), kalibin seri rengi, ten, sabit renkler. Her
kaynak AYRI bir katman: sahne her gecis icin kurulur, o gecisin bolgesi ton
kodlu, diger bolgeler HOLDOUT (gorunmez ama onundekini/arkasindakini ortuyor).
Oyunda katmanlar hangi sirayla cizilirse cizilsin ortusmeler 3B'deki gibi.

  kg_<kalip>_<bw>_<bolge>   bolge: ana sh seri (CARPAN), ten (PALET), sabit (NORMAL)
                            capa (x, by)
  kb_<kalip>_<G>_<bolge>    bas: isci/turist sabit; kurye (kask rengi) ve sofor
                            (kasket rengi) CARPAN + sabit; capa (hx, hy)
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
import musteri_hd as M

OUT = os.path.join(_HERE, "out", "kalip_hd")
HD = 2
K = M.K
ez, torna = T.ez, T.torna
gri = M.gri
PARCALAR, KOKEN = {}, {}
GECIS = [None]
YM = 4.0
DER = 0.42
AU2 = "#e0a41f"


def holdout():
    m = bpy.data.materials.new("Holdout")
    m.use_nodes = True
    nt = m.node_tree
    nt.nodes.clear()
    h = nt.nodes.new("ShaderNodeHoldout")
    o = nt.nodes.new("ShaderNodeOutputMaterial")
    nt.links.new(h.outputs[0], o.inputs["Surface"])
    return m


def Z(bolge, mat_fn):
    """Bu gecisin bolgesiyse gercek malzeme, degilse holdout."""
    return mat_fn() if bolge == GECIS[0] else holdout()


def carp(ad, f):
    return px.flat(ad, gri(f))


def ten(ad, s):
    return px.flat(ad, M.TON[s])


def govde_derinlik(x, gy, bw):
    """Govde yuzeyinin (x, gy)'deki on derinligi (torna: tavan by-2, omuz kubbesi 7 px)."""
    hw = bw / 2.0
    h = 32.0 - gy
    if h <= 27:
        r = hw
    else:
        u = min(1.0, (h - 27) / 7.0)
        r = hw * math.sqrt(max(0.0, 1 - u * u))
    return YM - math.sqrt(max(0.0, r * r - x * x)) * DER


def yama(ad, pts, bw, ofset, mat, kesim=5):
    """Govde yuzeyine yapisan duz renkli yama: ekran poligonu, her kosenin
    derinligi govde yuzeyinden (ofset kadar onde)."""
    bm = bmesh.new()
    vs = [bm.verts.new((x, 0, 0)) for x, _ in pts]
    f = bm.faces.new(vs)
    for v, (x, gy) in zip(vs, pts):
        v.co = Vector((x, gy, 0))
    bmesh.ops.triangulate(bm, faces=[f])
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=kesim, use_grid_fill=True)
    for v in bm.verts:
        x, gy = v.co.x, v.co.y
        y = govde_derinlik(x, gy, bw) - ofset
        v.co = Vector((x, y, ez(gy, y, K)))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = I.mesh_ob(ad, bm, mat, smooth=False)
    return ob


def dik(x0, gy0, w, h):
    return [(x0, gy0), (x0 + w, gy0), (x0 + w, gy0 + h), (x0, gy0 + h)]


def govde_taban(bw, bolge, faktor_ramp=(.72, 1.0, 1.14), kollar=True):
    """kalipZemin: art.js'teki govde (omuz elipsi + govde + sol isik + kollar)."""
    hw = bw / 2.0
    prof = []
    for i in range(0, 35):
        if i <= 27:
            r = hw
        else:
            u = (i - 27) / 7.0
            r = hw * math.sqrt(max(0.0, 1 - u * u))
        prof.append((max(0.01, r), i))
    torna("zemin", prof, 0, 32, YM, DER, Z(bolge, lambda: px.cel("Zemin", [gri(faktor_ramp[0]), gri(faktor_ramp[1]), gri(faktor_ramp[2])], [0, .42, .8])), K, seg=28)
    if kollar:
        for sx in (-1, 1):
            torna("kol", [(0.5, 0), (2.5, 1.5), (2.5, 20), (2.2, 22)], sx * (hw + 0.5), 30, 1.5, 0.8,
                  Z(bolge, lambda: px.cel("Kol", [gri(.62), gri(.66), gri(.8), gri(.92)], [0, .2, .42, .8])), K, seg=14)


def gorunmez_govde(bw):
    """Zemini olmayan kaliplar (ogrenci, kurye): govde oyunda normal gomlekle
    ciziliyor; burada yalniz ortucu (holdout) olarak var."""
    GECIS_ESKI = GECIS[0]
    GECIS[0] = "__"
    govde_taban(bw, "yok")
    GECIS[0] = GECIS_ESKI


def yaka(bw, ofset=0.6):
    yama("yaka", dik(-6, 2, 12, 4), bw, ofset, Z("sh", lambda: carp("Yaka", .62)))
    L.silindir("boyun", 3.0, 0.0, YM - bw / 2.0 * DER - ofset - 0.2, ez(3.5, YM - bw / 2.0 * DER - ofset - 0.2, K), 5.0,
               Z("ten", lambda: M.palet("Boyun", ["s2", "s1"], [0, .42])), seg=14, eksen="Z")


def bant(ad, gy, kal, bw, bolge, faktor, ofset=0.05):
    # yanlarda da onde de govde yuzeyinden `ofset` kadar disarida
    hw = bw / 2.0 + ofset
    torna(ad, [(hw, 0), (hw, kal)], 0, gy + kal, YM, (bw / 2.0 * DER + ofset) / hw, Z(bolge, lambda: carp(ad, faktor)), K, seg=28, kapak=False)


# ---------------------------------------------------------------- govde kaliplari
def isci(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    govde_taban(bw, "ana")
    # altindaki gomlek: omuzlar ve kisa kollar
    yama("gomlek_s", dik(sol + 1, 4, 8, 9), bw, 0.3, Z("sh", lambda: carp("G1", .9)))
    yama("gomlek_g", dik(sag - 8, 4, 8, 9), bw, 0.3, Z("sh", lambda: carp("G2", .74)))
    yama("gomlek_o", [(sol + 2 + 11 * (1 - math.cos(math.pi * j / 12)), 4 + 5 * math.sin(-math.pi * j / 12) * 0 + 5 * (1 - math.sin(math.pi * j / 12))) for j in range(13)],
         bw, 0.32, Z("sh", lambda: carp("G3", 1.0)))
    for sx, f in ((-1, .8), (1, .66)):
        torna("kolluk", [(2.7, 0), (2.8, 9)], sx * (bw / 2.0 + 0.5), 17, 1.5, 0.8, Z("sh", lambda f=f: px.cel("Kolluk%.2f" % f, [gri(f * .85), gri(f)], [0, .45])), K, seg=14, kapak=False)
    # tulum: gogusluk + askilar + cep
    yama("gogusluk", dik(-9, 12, 18, 18), bw, 0.8, Z("ana", lambda: px.cel("Gogusluk", [gri(.72), gri(1.0), gri(1.1)], [0, .4, .85])))
    yama("gogusluk_ust", dik(-9, 12, 18, 1), bw, 0.9, Z("ana", lambda: carp("GoguslukUst", 1.22)))
    for x0 in (-9, 6):
        yama("aski", dik(x0, 4, 3, 9), bw, 0.8, Z("ana", lambda: carp("Aski", 1.0)))
        yama("aski_ust", dik(x0, 4, 1, 1), bw, 0.9, Z("ana", lambda: carp("AskiUst", 1.22)))
    for x0 in (-8, 7):
        yama("dugme", dik(x0, 12, 1, 1), bw, 1.0, Z("sabit", lambda: px.flat("Dugme", AU2)))
    yama("cep", dik(-8, 22, 7, 5), bw, 0.95, Z("ana", lambda: carp("Cep", .72)))
    yama("cep_ust", dik(-8, 22, 7, 1), bw, 1.0, Z("ana", lambda: carp("CepUst", 1.22)))
    # reflektor seritler (gogusluk ustunde, kollar dahil sarar)
    for gy in (17, 20):
        bant("serit%d" % gy, gy, 1.0, bw, "seri", 1.0, ofset=1.1)
    yaka(bw)


def memur(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    govde_taban(bw, "ana")
    yama("gomlek", dik(-4, 6, 8, 24), bw, 0.3, Z("sabit", lambda: px.flat("Gomlek", "#e6e2d6")))
    yama("gomlek_kenar", dik(-4, 6, 1, 24), bw, 0.35, Z("sabit", lambda: px.flat("GomlekKenar", "#c8c2b2")))
    yama("klapa_s", [(-8, 5), (-4, 5), (0, 13), (-1, 13)], bw, 0.6, Z("ana", lambda: carp("KlapaS", .72)))
    yama("klapa_g", [(4, 5), (8, 5), (1, 13), (0, 13)], bw, 0.6, Z("ana", lambda: carp("KlapaG", .6)))
    yama("klapa_isik", [(-8, 5), (-7.2, 5), (-0.2, 13), (-1, 13)], bw, 0.65, Z("ana", lambda: carp("KlapaIsik", 1.22)))
    yama("kravat_dugum", dik(-2, 7, 4, 4), bw, 0.7, Z("seri", lambda: carp("Dugum", 1.0)))
    yama("kravat", [(-1, 11), (2, 11), (2.5, 22), (0.5, 24), (-1.5, 22)], bw, 0.65, Z("seri", lambda: carp("Kravat", .9)))
    yama("kravat_isik", dik(0, 8, 1, 1), bw, 0.75, Z("seri", lambda: carp("KravatIsik", 1.35)))
    for d in range(3):
        yama("kravat_cizgi", dik(-1, 14 + d * 4, 3, 1), bw, 0.7, Z("seri", lambda: carp("KravatCizgi", .7)))
    yama("rozet", dik(sag - 4, 16, 1, 1), bw, 0.4, Z("sabit", lambda: px.flat("Rozet", AU2)))
    yaka(bw, ofset=0.9)


def ogrenci(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    gorunmez_govde(bw)
    # canta: govdenin arkasindan tasan yanlar
    L.kutu("canta_s", sol - 5, sol - 1, ez(34, YM + 3, K), ez(20, YM + 3, K), YM + 1, YM + 5, Z("ana", lambda: px.cel("CantaS", [gri(.6), gri(.72)], [0, .5])))
    L.kutu("canta_g", sag + 1, sag + 5, ez(34, YM + 3, K), ez(20, YM + 3, K), YM + 1, YM + 5, Z("ana", lambda: px.cel("CantaG", [gri(.52), gri(.6)], [0, .5])))
    # kapusonlu: yaka kivrimi
    rx = bw / 2.0 - 1
    ust = [(-rx * math.cos(math.pi * j / 16), 7 - 5 * math.sin(math.pi * j / 16)) for j in range(17)]
    alt = [(rx * math.cos(math.pi * j / 16), 7 + 5 * math.sin(math.pi * j / 16)) for j in range(1, 16)]
    yama("kapuson", ust + alt, bw, 0.3, Z("sh", lambda: px.cel("Kapuson", [gri(.66), gri(.82)], [0, .5])))
    yama("kapuson_cizgi", dik(-7, 3, 14, 1), bw, 0.4, Z("sh", lambda: carp("KapusonCizgi", .58)))
    yama("cep", dik(-9, 21, 18, 1), bw, 0.35, Z("sh", lambda: carp("CepCizgi", .6)))
    yama("cep_s", dik(-9, 21, 1, 6), bw, 0.35, Z("sh", lambda: carp("CepS", .6)))
    yama("cep_g", dik(8, 21, 1, 6), bw, 0.35, Z("sh", lambda: carp("CepG", .6)))
    for x0 in (-8, 6):
        torna("askı", [(1.5, 0), (1.5, 22)], x0 + 1.5, 28, govde_derinlik(x0 + 1.5, 17, bw) - 0.8, 0.6,
              Z("ana", lambda: px.cel("Aski", [gri(.72), gri(1.0), gri(1.22)], [0, .4, .8])), K, seg=10)
    for x0 in (-7, 7):
        yama("toka", dik(x0, 17, 1, 1), bw, 2.2, Z("seri", lambda: carp("Toka", 1.0)))
    yaka(bw)


def yasli(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    govde_taban(bw, "ana")
    yama("gomlek", dik(-4, 8, 8, 22), bw, 0.3, Z("sh", lambda: carp("Gomlek", 1.05)))
    yama("hirka_s", dik(-4, 8, 1, 22), bw, 0.35, Z("sh", lambda: carp("HirkaS", .8)))
    yama("hirka_g", dik(3, 8, 1, 22), bw, 0.35, Z("sh", lambda: carp("HirkaG", .8)))
    for b in range(4):
        yama("dugme", dik(-6, 13 + b * 5, 1, 1), bw, 0.4, Z("seri", lambda: carp("Dugme", 1.0)))
        yama("dugme_g", dik(-6, 14 + b * 5, 1, 1), bw, 0.4, Z("seri", lambda: carp("DugmeG", .7)))
    yama("omuz_isik", dik(sol + 1, 4, 8, 1), bw, 0.2, Z("ana", lambda: carp("OmuzIsik", 1.22)))
    # atki: boyna sarili yuvarlak bant + one sarkan uc
    L.silindir("atki", 3.0, 0.0, YM - bw / 2.0 * DER * 0.6, ez(5.0, YM - bw / 2.0 * DER * 0.6, K), 18.0,
               Z("seri", lambda: px.cel("Atki", [gri(.8), gri(1.0), gri(1.14)], [0, .4, .8])), seg=16, eksen="X")
    yama("atki_uc", dik(4, 8, 5, 12), bw, 1.6, Z("seri", lambda: carp("AtkiUc", .94)))
    yama("atki_uc_ust", dik(4, 8, 5, 1), bw, 1.7, Z("seri", lambda: carp("AtkiUcUst", 1.0)))
    for pu in range(5):
        yama("puskul", dik(4 + pu, 20, 0.6, 1.5), bw, 1.7, Z("seri", lambda: carp("Puskul", .68)))


def turist(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    govde_taban(bw, "ana", kollar=False)
    for sx, f in ((-1, .8), (1, .66)):
        torna("kolluk", [(0.5, 0), (2.8, 1.5), (2.8, 10)], sx * (bw / 2.0 + 0.5), 18, 1.5, 0.8, Z("ana", lambda f=f: px.cel("Kolluk%.2f" % f, [gri(f * .85), gri(f)], [0, .45])), K, seg=14)
        torna("kol", [(2.3, 0), (2.4, 12)], sx * (bw / 2.0 + 0.5), 30, 1.5, 0.8, Z("ten", lambda: M.palet("Kol", ["s2", "s1"], [0, .45])), K, seg=14, kapak=False)
    for ci in range(12):
        cx2 = sol + 3 + (ci * 7) % (bw - 6)
        cy2 = 8 + (ci * 5) % 20
        yama("cicek", [(cx2 + 0.5, cy2 - 0.3), (cx2 + 1.9, cy2 + 1.2), (cx2 + 0.5, cy2 + 2.6), (cx2 - 0.9, cy2 + 1.2)], bw, 0.25, Z("seri", lambda: carp("Cicek", 1.0)), kesim=2)
        yama("cicek_ic", dik(cx2 + 0.2, cy2 + 0.9, 0.6, 0.6), bw, 0.3, Z("seri", lambda: carp("CicekIc", .8)), kesim=1)
    for sx in (-1, 1):
        yama("kayis", [(sx * 6 - 0.5, 5), (sx * 6 + 0.5, 5), (sx * 2 + 0.5, 16), (sx * 2 - 0.5, 16)], bw, 0.5, Z("sabit", lambda: px.flat("Kayis", "#4a3f30")))
    mk_y = govde_derinlik(0, 19, bw) - 3.0
    L.levha("makine", 10, 7, 1.2, 0.0, ez(19.5, mk_y, K), mk_y, 3.0, 0.3, Z("sabit", lambda: px.cel("Makine", ["#25252a", "#3f3f46", "#5f5f68"], [0, .4, .85])))
    L.silindir("objektif", 2.2, 0.0, mk_y - 2.0, ez(19.0, mk_y - 2.0, K), 2.0, Z("sabit", lambda: px.cel("Objektif", ["#0a0a0e", "#14141a", "#2a2a33"], [0, .4, .85])), seg=16, eksen="Y")
    I.elipsoid("yansima", -1.0, 18.0, 0.6, 0.6, 0.3, mk_y - 3.2, Z("sabit", lambda: px.flat("Yansima", "#7ab0d8")), seg=8, ring=4).location = (-0.5, mk_y - 3.2, ez(18.5, mk_y - 3.2, K))
    T.onkutu("flas", 3.5, 5.0, 16.5, 18.0, mk_y - 1.8, mk_y - 1.5, Z("sabit", lambda: px.flat("Flas", "#c8c0a8")), K)
    yaka(bw)


def sporcu(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    govde_taban(bw, "ana", kollar=False)
    for sx in (-1, 1):
        torna("kol", [(0.5, 0), (2.5, 1.5), (2.5, 20), (2.2, 22)], sx * (bw / 2.0 + 0.5), 30, 1.5, 0.8,
              Z("ana", lambda: px.cel("Kol", [gri(.62), gri(.66), gri(.8), gri(.92)], [0, .2, .42, .8])), K, seg=14)
        xs = sol - 3 if sx < 0 else sag + 1
        T.onkutu("kol_serit", xs, xs + 2, 10, 30, 1.5 - 2.6, 1.5 + 2.0, Z("seri", lambda sx=sx: carp("KolSerit%d" % sx, 1.0 if sx < 0 else .86)), K)
    yama("fermuar", dik(-1, 8, 2, 22), bw, 0.3, Z("ana", lambda: carp("Fermuar", .58)))
    yama("fermuar_isik", dik(-1, 8, 0.6, 22), bw, 0.35, Z("ana", lambda: carp("FermuarIsik", 1.35)))
    yama("fermuar_ucu", dik(0, 10, 1, 1.4), bw, 0.45, Z("seri", lambda: carp("FermuarUcu", 1.0)))
    L.silindir("yaka", 2.4, 0.0, YM - bw / 2.0 * DER * 0.55, ez(5.2, YM - bw / 2.0 * DER * 0.55, K), 14.0,
               Z("ana", lambda: px.cel("Yaka", [gri(.72), gri(1.08)], [0, .5])), seg=14, eksen="X")
    yama("yaka_serit", dik(-6, 3, 12, 0.8), bw, 2.6, Z("seri", lambda: carp("YakaSerit", 1.0)))
    yama("logo", dik(-8, 17, 5, 2), bw, 0.3, Z("seri", lambda: carp("Logo", 1.0)))
    yama("logo_ic", dik(-7, 18, 1, 1), bw, 0.35, Z("ana", lambda: carp("LogoIc", 1.0)))


def kurye(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    gorunmez_govde(bw)
    hw = bw / 2.0 - 1
    prof = [(hw + 0.3, 0)]
    for i in range(1, 25):
        h = i
        if h <= 20:
            r = hw + 0.3
        else:
            u = (h - 20) / 5.0
            r = (hw + 0.3) * math.sqrt(max(0.0, 1 - u * u * 0.7))
        prof.append((r, h))
    torna("yelek", prof, 0, 30, YM, DER * (bw / 2.0) / (hw + 0.3) * 1.02, Z("ana", lambda: px.cel("Yelek", [gri(.72), gri(1.0), gri(1.12)], [0, .45, .82])), K, seg=28, kapak=False)
    yama("orta", dik(-1, 6, 2, 24), bw, 0.5, Z("ana", lambda: carp("Orta", .6)))
    for gy in (16, 19):
        bant("serit%d" % gy, gy, 1.0, bw, "seri", 1.0, ofset=0.6)
    yama("kayis", [(-10, 5), (-7, 5), (10.6, 29), (7.6, 29)], bw, 0.9, Z("sabit", lambda: px.cel("KayisK", ["#39312a", "#5c4e40"], [0, .7])))
    yama("kayis_kenar", [(-10, 5), (-9.2, 5), (8.4, 29), (7.6, 29)], bw, 0.95, Z("sabit", lambda: px.flat("KayisKenar", "#5c4e40")))
    yaka(bw, ofset=0.8)


def sofor(bw):
    sol, sag = -bw / 2.0, bw / 2.0
    govde_taban(bw, "ana")
    yama("yaka_v", [(-5, 4), (5, 4), (0, 11)], bw, 0.4, Z("sabit", lambda: px.cel("YakaV", ["#cfcabc", "#e0dcd0"], [0, .5])))
    yama("yaka_kenar_s", [(-5.6, 4), (-5, 4), (0, 11), (-0.6, 11)], bw, 0.45, Z("ana", lambda: carp("YakaKenar", .6)))
    yama("yaka_kenar_g", [(5, 4), (5.6, 4), (0.6, 11), (0, 11)], bw, 0.45, Z("ana", lambda: carp("YakaKenarG", .6)))
    yama("yaka_uc_s", [(-6, 3), (-2, 3), (-2, 6), (-4, 7.5), (-6, 6)], bw, 0.7, Z("sabit", lambda: px.flat("YakaUcS", "#e0dcd0")))
    yama("yaka_uc_g", [(2, 3), (7, 3), (7, 6), (5, 7.5), (2, 6)], bw, 0.7, Z("sabit", lambda: px.flat("YakaUcG", "#cfcabc")))
    yama("kravat", [(-1, 11), (1, 11), (1.4, 18), (0, 19.5), (-1.4, 18)], bw, 0.5, Z("seri", lambda: carp("Kravat", 1.0)))
    yama("cep", dik(sol + 2, 17, 6, 5), bw, 0.3, Z("ana", lambda: carp("Cep", .72)))
    yama("cep_ust", dik(sol + 2, 17, 6, 1), bw, 0.35, Z("ana", lambda: carp("CepUst", 1.22)))
    yama("kemer", dik(sol + 1, 29, bw - 2, 1), bw, 0.2, Z("ana", lambda: carp("Kemer", .72)))


# ---------------------------------------------------------------- bas kaliplari
def kb_isci(G):
    bc = "#e8b820"
    def mat(ad, f):
        return px.flat(ad, T.hexmul(bc, f))
    M.kubbe("kask", 0.5, -1.5, G + 1.5, 14.0, Z("sabit", lambda: px.cel("Kask", [T.hexmul(bc, .7), bc, T.hexmul(bc, 1.15)], [0, .45, .85])), y=-0.5)
    L.silindir("siper", 1.6, 0.5, -1.0, ez(-4.6, -1.0, K), 2 * G + 8, Z("sabit", lambda: px.cel("Siper", [T.hexmul(bc, .62), T.hexmul(bc, .88), T.hexmul(bc, 1.15)], [0, .4, .85])), seg=14, eksen="X")
    T.onkutu("sirt", -0.5, 1.5, -15, -7, -G - 2.0, -G, Z("sabit", lambda: mat("Sirt", .78)), K)
    M.elipsoid("isik", -3.5, -12, 3.5, 1.6, 0.6, -G - 1.5, Z("sabit", lambda: mat("Isik", 1.35)), seg=12, ring=6)


def kb_turist(G):
    tc = "#ddc98f"
    Mh = lambda: px.cel("Hasir", [T.hexmul(tc, .66), T.hexmul(tc, .84), tc, T.hexmul(tc, 1.15)], [0, .25, .5, .85], noise=0.08, noise_scale=30)
    I.yatay_elips("kenar", 0.5, -6.5, G + 6.5, 0.9, Z("sabit", Mh), 0.5, ry_ekran=3.4, seg=48, egim=0.02)
    M.kubbe("tepe", 0.5, -8.0, G - 0.5, 7.0, Z("sabit", Mh), y=0.0)
    L.silindir("kurdele", G - 0.3, 0.5, 0.0, ez(-8.5, 0.0, K), 1.2, Z("sabit", lambda: px.flat("Kurdele", "#8a5f31")), seg=32, eksen="Z")
    T.onkutu("rozet", G - 6, G - 3, -9.5, -7.5, -G + 0.2, -G + 0.6, Z("sabit", lambda: px.flat("Rozet", "#b8442e")), K)


def kb_kurye(G):
    M.kubbe("kask", 0.5, -1.0, G + 2.5, 17.0, Z("ana", lambda: px.cel("KaskK", [gri(.48), gri(.58), gri(1.0), gri(1.28)], [0, .15, .45, .85])), y=0.0)
    L.silindir("kenar", 1.4, 0.5, -0.5, ez(-4.3, -0.5, K), 2 * G + 7, Z("ana", lambda: px.cel("KenarK", [gri(.58), gri(.88)], [0, .5])), seg=12, eksen="X")
    for sx, f in ((-1, .58), (1, .48)):
        x0 = -G - 2 if sx < 0 else G
        T.onkutu("kulaklik", x0, x0 + 3, -4, 4, -1.0, 2.0, Z("ana", lambda f=f: carp("Kulaklik%.2f" % f, f)), K)
    T.onkutu("vizor", -G + 1, G - 1, -13, -10, -G - 2.6, -G - 2.4, Z("sabit", lambda: px.flat_a("Vizor", "#8ab8d8", 0.45)), K)
    T.onkutu("vizor_isik", -G + 2, G - 2, -13, -12.5, -G - 2.7, -G - 2.5, Z("sabit", lambda: px.flat("VizorIsik", "#cfe4f2")), K)
    for sx in (-1, 1):
        T.on_poligon("kayis", [(sx * G - 0.5 * sx, 4), (sx * G + 0.5 * sx, 4), (sx * 2 + 0.5 * sx, 9.5), (sx * 2 - 0.5 * sx, 9.5)], -G * 0.8 - 1.0, Z("sabit", lambda: px.flat("KayisC", "#2b261f")), K, derin=0.1)
    T.onkutu("toka", -3, 3, 9, 11, -G * 0.8 - 1.2, -G * 0.8 - 1.0, Z("sabit", lambda: px.cel("TokaC", ["#3d362e", "#7a6c58"], [0, .7])), K)


def kb_sofor(G):
    M.kubbe("kasket", 0.5, -4.5, G + 1.0, 8.0, Z("ana", lambda: px.cel("Kasket", [gri(.66), gri(1.0), gri(1.12), gri(1.32)], [0, .35, .6, .88])), y=0.0)
    L.silindir("siper", 1.1, -G * 0.4, -G * 0.7, ez(-4.2, -G * 0.7, K), G + 3.0, Z("ana", lambda: px.cel("SiperK", [gri(.52), gri(.78)], [0, .55])), seg=12, eksen="X")
    T.onkutu("golge", -G + 1, G - 1, -4, -3, -G - 0.2, -G, Z("ana", lambda: carp("KasketGolge", .45)), K)


GOVDE = {"isci": (isci, ["ana", "sh", "seri", "ten", "sabit"]), "memur": (memur, ["ana", "sh", "seri", "ten", "sabit"]),
         "ogrenci": (ogrenci, ["ana", "sh", "seri", "ten"]), "yasli": (yasli, ["ana", "sh", "seri"]),
         "turist": (turist, ["ana", "sh", "seri", "ten", "sabit"]), "sporcu": (sporcu, ["ana", "seri"]),
         "kurye": (kurye, ["ana", "sh", "seri", "ten", "sabit"]), "sofor": (sofor, ["ana", "seri", "sabit"])}
BAS = {"isci": (kb_isci, ["sabit"]), "turist": (kb_turist, ["sabit"]), "kurye": (kb_kurye, ["ana", "sabit"]), "sofor": (kb_sofor, ["ana"])}

for _k, (_fn, _bolgeler) in GOVDE.items():
    for _bw in (18, 26, 32):
        for _b in _bolgeler:
            PARCALAR["kg_%s_%d_%s" % (_k, _bw, _b)] = ((-(_bw // 2 + 7), -4, _bw + 14, 38), _fn, _bw, _b)
            KOKEN["kg_%s_%d_%s" % (_k, _bw, _b)] = (-(_bw // 2 + 7), -4)
for _k, (_fn, _bolgeler) in BAS.items():
    for _G in (9, 10, 11, 12):
        for _b in _bolgeler:
            PARCALAR["kb_%s_%d_%s" % (_k, _G, _b)] = ((-_G - 9, -20, 2 * _G + 19, 34), _fn, _G, _b)
            KOKEN["kb_%s_%d_%s" % (_k, _G, _b)] = (-_G - 9, -20)


def uret(ad):
    (gx0, gy0, w, h), fn, arg, bolge = PARCALAR[ad]
    M.sahne(gx0, gy0, w, h)
    GECIS[0] = bolge
    fn(arg)
    px.shear_scene(K)
    return px.render(os.path.join(OUT, ad + ".png"))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    adlar = [a for a in PARCALAR if not argv or any(a.startswith(x) for x in argv)]
    for ad in adlar:
        uret(ad)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": list(PARCALAR),
                   "kokenler": {k: list(v) for k, v in KOKEN.items()}}, fp, indent=1)
    print("KALIP_HD_DONE %d parca" % len(adlar))


if __name__ == "__main__":
    main()
