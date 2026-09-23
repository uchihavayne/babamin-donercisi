"""OZEL MUSTERI KALIPLARI - 3B model + piksel-art render.

Oyundaki karsiligi: js/chars.js -> KALIP tablosu,
  drawKalipGovde(id, x, by, bw, sh, s, L)   govde ~28x30
  drawKalipBas(id, hx, hy, hw, s, L)        bas   ~16 genis

Bunlar dizi/film karakteri DEGIL, o turlerin ARKETIPLERI: isim yok,
marka yok, oyuncu yuzu yok. Kucuk boyutta zaten yalnizca SILUET ve
RENK okunuyor - bir karakteri taniten sey de budur. Uc-bes bicim
disindaki her sey 28 pikselde kayboluyor, o yuzden her kalip birkac
guclu isarete indirgendi:

  kuzeyli : omuzda kabarik kurk + koyu dalgali sac + sirtta kilic
  kimyager: sari tulum + kel kafa + gozluk + kecisakal + yesil eldiven
  cirak   : siyah cuppe + cizgili uzun atki + yuvarlak gozluk + asa
  kralice : gumus orgu sac + yuksek yakali mavi-gri elbise
  bilge   : uzun ak sakal + sivri genis kenarli sapka + degnek

Boru hattinin uc kurali (blender/README.md): 1 birim = 1 piksel,
anti-alias yok, renk yonetimi kapali.
"""
import sys, os, math
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
import pxcore as px
import palette as pal

OUT = os.path.join(_HERE, "out")
W, H = 46, 76                 # tek musteri karesi


# ----------------------------------------------------------- yardimcilar
def new_obj(name, bm, smooth=True):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    if smooth:
        for p in me.polygons:
            p.use_smooth = True
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    return ob


def kutu(name, x0, y0, z0, x1, y1, z1, mat, smooth=False):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    ob = new_obj(name, bm, smooth=smooth)
    ob.scale = (max(.4, abs(x1 - x0)), max(.4, abs(y1 - y0)), max(.4, abs(z1 - z0)))
    ob.location = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    ob.data.materials.append(mat)
    return ob


def silindir(name, eksen, a0, a1, r, mat, seg=20, r1=None):
    bm = bmesh.new()
    halka = []
    for idx, tt in enumerate((a0, a1)):
        rr = r if (r1 is None or idx == 0) else r1
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            c, s = math.cos(a) * rr, math.sin(a) * rr
            if eksen == 'x':
                vs.append(bm.verts.new((tt, c, s)))
            elif eksen == 'y':
                vs.append(bm.verts.new((c, tt, s)))
            else:
                vs.append(bm.verts.new((c, s, tt)))
        halka.append(vs)
    for k in range(seg):
        bm.faces.new((halka[0][k], halka[0][(k + 1) % seg],
                      halka[1][(k + 1) % seg], halka[1][k]))
    bm.faces.new(list(reversed(halka[0])))
    bm.faces.new(halka[1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


def kure(ad, mat, seg=16, ring=10):
    bm = bmesh.new()
    try:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, radius=1.0)
    except TypeError:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, diameter=1.0)
    ob = new_obj(ad, bm)
    ob.data.materials.append(mat)
    return ob


def yumru(ad, mat, n, merkez, yaricap, boy, tohum=1.0):
    """Kurelerden orulmus duzensiz kutle - kurk, sac, sakal icin."""
    obs = []
    for i in range(n):
        a = i * 2.399 + tohum
        rr = yaricap * (0.55 + 0.45 * math.cos(a * 1.7))
        k = kure("%s%d" % (ad, i), mat, seg=10, ring=7)
        sc = boy * (0.65 + 0.35 * math.sin(a * 2.3))
        k.scale = (sc, sc * 0.8, sc)
        k.location = (merkez[0] + math.cos(a) * rr,
                      merkez[1] + math.sin(a * 1.3) * 2,
                      merkez[2] + math.sin(a) * rr * 0.55)
        obs.append(k)
    return obs


def sac_kubbe(ad, mat, hz, hw, arka=2.0, ust=2.5, en=2.2, boy=3.0):
    """Basi SARAN sac kutlesi.

    yumru()'yu dogrudan basin merkezine koymak ise yaramiyor: kureler
    basin ICINDE kaliyor ve hicbiri gorunmuyor. Sac, bastan BUYUK ve
    biraz ARKADA duran bir kubbe olmali; yuz kuresi onden disari cikar.
    """
    k = kure(ad, mat)
    k.scale = (hw + en, hw + 1, hw + boy)
    k.location = (0, arka, hz + ust)
    return k


def mat_isik(ad, ramp, stops=None):
    if stops is None:
        n = len(ramp)
        stops = [0.0] + [0.16 + 0.66 * i / (n - 1) for i in range(1, n)]
    return px.cel(ad, ramp, stops)


# ------------------------------------------------------------- paletler
TEN = ["#8a5230", "#a86a3e", "#c9885a", "#e0a978", "#f0bd8a"]
SIYAH = ["#0e1014", "#191d24", "#262c36", "#353d49", "#48525f"]
KURK = ["#241f19", "#3a332a", "#4f463a", "#675c4c", "#83765f"]
DERI = ["#241a14", "#3a2a1e", "#503b2a", "#6a5138"]
CELIK = ["#3a4148", "#525b64", "#727d88", "#98a4b0", "#c4cfd8"]
SARI = ["#8a7a10", "#b8a41c", "#d8c22a", "#eddc55", "#fbf090"]
YESIL = ["#1e4a2c", "#2f6b3e", "#428f54", "#5db56f"]
BORDO = ["#4a1018", "#701a24", "#9a2632", "#c2404c"]
ALTIN = ["#7a5a12", "#a8811f", "#d8ac35", "#ffd75e"]
GUMUS = ["#8a8f9c", "#b0b6c2", "#ced3dc", "#e6e9ef", "#fbfcff"]
MAVI = ["#20323e", "#2f4c5c", "#436a7e", "#5f8ea2", "#87b3c4"]
GRI = ["#3a3a40", "#54545c", "#70707a", "#8f8f9a", "#b2b2bc"]
AK = ["#9a9a96", "#bcbcb6", "#d8d8d2", "#eeeeea", "#ffffff"]
AHSAP = ["#3a2a18", "#54402a", "#6f5638", "#8a6f4a"]


def sahne():
    px.reset(); px.setup(W, H)
    px.ortho_cam(0, 6, W, H)
    px.world("#141014", 0.32)
    px.sun(math.pi, rot=(52, 0, -40))


def govde(M_kiyafet, bw=28, by=-30, boy=30, omuz=True):
    """Ortak govde kutlesi: omuz elipsi + torso. chars.js'teki
    kalipZemin() ile ayni oran - genislik 28, yukseklik 30."""
    if omuz:
        o = kure("Omuz", M_kiyafet)
        o.scale = (bw / 2.0, 7, 7)
        o.location = (0, 0, by + boy - 1)
    kutu("Torso", -bw / 2.0, -7, by, bw / 2.0, 7, by + boy - 1, M_kiyafet)
    # kollar
    for sx in (-1, 1):
        k = kutu("Kol%d" % sx, sx * (bw / 2.0 - 1), -6, by + 3,
                 sx * (bw / 2.0 + 4), 6, by + boy - 6, M_kiyafet)
    return by + boy


def bas(M_ten, hz, hw=8):
    """Bas kuresi + boyun. hz = bas merkezi."""
    b = kure("Bas", M_ten)
    b.scale = (hw, hw - 1, hw + 2)
    b.location = (0, -1.8, hz)          # yuz sac kubbesinden one cikar
    silindir("Boyun", 'z', hz - hw - 5, hz - hw + 2, 4, M_ten, seg=12)
    return b


def gozluk(hz, mat, r=3.0, ax=4.2):
    """Iki yuvarlak cerceve + kopru.

    y=-9.8: yuz kuresi (merkez y=-1.8, derinlik 7) on yuzeyini
    y=-8.8'de bitiriyor. Daha geride birakilinca gozluk yuzun ICINDE
    kaliyor ve tende sisik lekelere donuyordu.
    """
    for sx in (-ax, ax):
        for i in range(14):
            a = 2 * math.pi * i / 14
            k = kure("Gz%d_%d" % (int(sx * 10), i), mat, seg=6, ring=5)
            k.scale = (0.7, 0.7, 0.7)
            k.location = (sx + math.cos(a) * r, -9.8, hz + 1 + math.sin(a) * r)
    kutu("Kopru", -1.6, -10.0, hz + 0.4, 1.6, -9.4, hz + 1.4, mat)
    for sx in (-ax - r, ax + r):                       # saplar
        kutu("Sap%d" % int(sx * 10), sx - 0.5, -9.8, hz + 1.4,
             sx + 0.5, -5.0, hz + 2.2, mat)


def kurk_manto(ad, mat, z, genislik=21, sira=3):
    """Omuz hatti boyunca uzanan kabarik kurk.

    yumru() kureleri DAIRESEL dagitiyor; manto icin yanlis arac -
    gogse yigilmis top kumesi cikiyordu. Kurk omuzda durur ve yanlara
    tasar, o yuzden yatay bir yay boyunca dizilmesi gerekiyor.
    """
    n = 0
    for s2 in range(sira):
        yy = -6 + s2 * 5.0
        adet = 11 - s2 * 2
        for i in range(adet):
            u = (i / (adet - 1.0)) * 2 - 1                 # -1..1
            kx = u * genislik * (1 - s2 * 0.12)
            kz = z - abs(u) * 3.2 - s2 * 1.4               # omuzdan yanlara iner
            k = kure("%s%d" % (ad, n), mat, seg=10, ring=7); n += 1
            sc = 4.6 - abs(u) * 1.0 - s2 * 0.5
            k.scale = (sc, sc * 0.85, sc * 0.9)
            k.location = (kx, yy, kz + (1.2 if i % 2 else -1.2))


def gozler(hz, ax=3.6, r=1.5):
    """Iki goz + parilti.

    Oyunda yuzu alttaki temel musteri sistemi ciziyor; kalip katmani
    onun USTUNE biniyor. Blender calismasinda yuz olmadigi icin bes
    kalip da gozsuz cikmisti - tasarimi degerlendirmeyi zorlastiriyor.
    y=-9.4: yuz kuresinin on yuzeyi -8.8'de bitiyor.
    """
    M_goz = px.flat("Goz", "#241a14")
    M_ak = px.flat("GozAk", "#f4f0e6")
    M_pr = px.flat("GozPr", "#ffffff")
    for sx in (-ax, ax):
        a = kure("Ak%d" % int(sx * 10), M_ak, seg=8, ring=6)
        a.scale = (r + 0.5, 0.9, r)
        a.location = (sx, -9.2, hz + 1)
        g = kure("Gz%d" % int(sx * 10), M_goz, seg=8, ring=6)
        g.scale = (r * 0.62, 0.7, r * 0.62)
        g.location = (sx + 0.3, -9.6, hz + 0.9)
        pr = kure("Pr%d" % int(sx * 10), M_pr, seg=6, ring=5)
        pr.scale = (0.42, 0.5, 0.42)
        pr.location = (sx - 0.4, -9.9, hz + 1.5)
    # kaslar
    M_kas = px.flat("Kas", "#3a2a1e")
    for sx in (-ax, ax):
        kutu("Kas%d" % int(sx * 10), sx - 2.4, -9.4, hz + 3.0,
             sx + 2.4, -8.8, hz + 3.9, M_kas)


# ============================================================ 1) KUZEYLI
def kuzeyli():
    """Omuzda kabarik kurk, koyu dalgali sac, sirtta kilic.

    Bu kalipta her sey KURK'te: 28 pikselde tanitan tek sey omuzlarin
    ne kadar genis ve tuylu oldugu. Kilic da siluetten tasan tek
    dogru cizgi olarak duruyor.
    """
    sahne()
    M_siyah = mat_isik("Siyah", SIYAH)
    M_kurk = mat_isik("Kurk", KURK)
    M_deri = mat_isik("Deri", DERI)
    M_ten = mat_isik("Ten", TEN)
    M_cel = mat_isik("Celik", CELIK)

    # KILIC: sag omuzun ustunden cikan kabza - balcak + topuz.
    # Once ince gri bir cubuktu, sopa gibi duruyordu.
    kl = silindir("Kilic", 'z', 0, 20, 1.4, M_cel, seg=8)
    kl.rotation_euler = (0, math.radians(22), 0)
    kl.location = (9, 8, 6)
    kb = silindir("Kabza", 'z', 20, 29, 1.9, M_deri, seg=8)
    kb.rotation_euler = (0, math.radians(22), 0)
    kb.location = (9, 8, 6)
    bc = kutu("Balcak", -5.5, 6, 19, 5.5, 10, 21.6, M_cel)
    bc.rotation_euler = (0, math.radians(22), 0)
    bc.location = (9, 0, 6)
    tp = kure("Topuz", M_cel); tp.scale = (2.4, 2.2, 2.0)
    tp.location = (2.5, 8, 33)

    govde(M_siyah)
    # tek capraz deri kayis + toka (X sekli kafa karistiriyordu)
    ky = kutu("Kayis", -3.4, -8, -30, 3.4, -6.4, 2, M_deri)
    ky.rotation_euler = (0, math.radians(24), 0)
    tk = kutu("Toka", -2.6, -8.6, -12, 2.6, -6.8, -7.4,
              mat_isik("Toka", ["#5a4a1a", "#8a7328", "#b89c3c"]))
    # KURK MANTO: omuz hattinin USTUNDE ve govdeden GENIS. Siluetten
    # tasan omuz bu kalibi tanitan tek sey.
    kurk_manto("Kurk", M_kurk, 5, genislik=24, sira=3)

    M_sac = mat_isik("SacK", ["#12100e", "#221d18", "#332b22", "#463b2e"])
    sac_kubbe("SacK", M_sac, 20, 8, arka=1.6, ust=2.2, en=2.4, boy=3.4)
    bas(M_ten, 20)
    # omuza inen dalgali kutle: kubbenin kenarindan asagi
    for sx in (-10, 10):
        yumru("SacYan%d" % sx, M_sac, 7, (sx, -1, 13), 4.5, 3.6,
              tohum=1.9 + sx * 0.1)
    yumru("SacUst", M_sac, 8, (0, 1, 27), 7, 3.0, tohum=0.7)
    gozler(20)


# =========================================================== 2) KIMYAGER
def kimyager():
    """Sari tulum, kel kafa, gozluk, kecisakal, yesil eldiven."""
    sahne()
    M_sari = mat_isik("Sari", SARI)
    M_ten = mat_isik("Ten", TEN)
    M_yes = mat_isik("Yesil", YESIL)
    M_gri = mat_isik("Gri", GRI)
    M_kah = mat_isik("Kahve", ["#241810", "#3a2a1c", "#50402c"])

    govde(M_sari)
    # tulum detaylari: fermuar + yaka + kapusonun sirtta yigilmasi
    kutu("Fermuar", -1, -8, -30, 1, -7, -2, M_gri)
    kutu("Yaka", -9, -8, -3, 9, -6, 1, mat_isik("Sari2", SARI[1:]))
    yumru("Kapuson", M_sari, 7, (0, 6, -2), 9, 4.0, tohum=1.4)
    # eldivenler
    for sx in (-15, 15):
        e = kure("Eldiven%d" % sx, M_yes)
        e.scale = (4.5, 4, 5)
        e.location = (sx, -3, -22)
    # maske boyunda asili
    # boyunda asili maske: dar bir bant + filtre, gogse yayilan gri
    # dikdortgen kafa karistiriyordu
    kutu("Maske", -4.5, -9.5, -6, 4.5, -7.5, -1, M_gri)
    silindir("Filtre", 'y', -11.5, -9.5, 2.0, mat_isik("Gri2", GRI[1:]),
             seg=10).location = (0, 0, -3.5)

    bas(M_ten, 20, hw=8)
    # kel kafa: tepede parlama, yanlarda kisa kir sac
    for sx in (-8, 8):                       # yanlarda kisa kir sac
        yumru("YanSac%d" % sx, M_gri, 5, (sx, 0.5, 18), 3.2, 2.4,
              tohum=0.4 + sx * 0.2)
    # kecisakal: cenenin ONUNDE (y negatif), yoksa bas onu yutuyor
    yumru("Sakal", M_kah, 10, (0, -6.5, 13.5), 5.5, 2.6, tohum=1.1)
    yumru("Biyik", M_kah, 4, (0, -7.5, 17.5), 3.4, 1.9, tohum=2.2)
    gozluk(20, mat_isik("Cerceve", ["#2a2a2e", "#44444a", "#63636b"]))
    gozler(20)


# ============================================================== 3) CIRAK
def cirak():
    """Siyah cuppe, cizgili uzun atki, yuvarlak gozluk, asa."""
    sahne()
    M_siyah = mat_isik("Cuppe", SIYAH)
    M_ten = mat_isik("Ten", TEN)
    M_bor = mat_isik("Bordo", BORDO)
    M_alt = mat_isik("Altin", ALTIN)
    M_ahs = mat_isik("Ahsap", AHSAP)
    M_sac = mat_isik("Sac", ["#1a120c", "#2a1e14", "#3d2c1e", "#54402c"])

    # asa: elde, dikey
    silindir("Asa", 'z', -28, 6, 1.1, M_ahs, seg=8).location = (17, -6, 0)
    kure("AsaUc", M_alt).scale = (1.8, 1.8, 1.8)
    bpy.data.objects["AsaUc"].location = (17, -6, 7)

    govde(M_siyah)
    # cuppe eteginin genislemesi
    kutu("Etek", -17, -7, -30, 17, 7, -20, M_siyah)
    # ATKI: gogusten asagi sarkan iki uc, enine cizgili
    for i in range(9):
        z0 = -2 - i * 3
        c = M_bor if i % 2 == 0 else M_alt
        kutu("AtkiSol%d" % i, -9, -9, z0 - 3, -4, -7, z0, c)
        if i < 5:
            kutu("AtkiSag%d" % i, 4, -9, z0 - 3, 9, -7, z0, c)
    kutu("AtkiBoyun", -10, -9, -3, 10, -5, 2, M_bor)

    sac_kubbe("SacC", M_sac, 20, 8, arka=1.4, ust=2.8, en=1.8, boy=2.8)
    bas(M_ten, 20, hw=8)
    yumru("SacDagi", M_sac, 9, (0, 0.5, 27), 7.5, 2.8, tohum=1.6)   # daginik
    gozluk(20, mat_isik("Cerceve2", ["#2a2a2e", "#44444a", "#63636b"]))
    gozler(20)


# ============================================================ 4) KRALICE
def kralice():
    """Gumus orgu sac, yuksek yakali mavi-gri elbise."""
    sahne()
    M_mavi = mat_isik("Mavi", MAVI)
    M_ten = mat_isik("Ten", TEN)
    M_gum = mat_isik("Gumus", GUMUS)
    M_alt = mat_isik("Altin2", ALTIN)

    govde(M_mavi)
    # yuksek yaka: boynu saran dik bant
    silindir("Yaka", 'z', -4, 8, 7.5, M_alt, seg=16, r1=6.5)
    silindir("YakaIc", 'z', -3, 7, 6.0, M_mavi, seg=16)
    # elbisede dikey pileler
    for i in range(5):
        kutu("Pile%d" % i, -11 + i * 5.4, -8, -30, -9.4 + i * 5.4, -7, -6,
             mat_isik("Mavi2", MAVI[:3]))

    sac_kubbe("SacKr", M_gum, 20, 7.6, arka=1.2, ust=2.4, en=2.6, boy=3.2)
    bas(M_ten, 20, hw=7.6)
    yumru("SacUst", M_gum, 9, (0, 0.5, 27), 7.5, 2.8, tohum=0.9)
    for sx in (-9, 9):
        for i in range(7):
            k = kure("Orgu%d_%d" % (sx, i), M_gum, seg=8, ring=6)
            r = 3.2 - i * 0.16
            k.scale = (r, r * 0.8, r * 0.85)
            k.location = (sx + (1 if i % 2 else -1) * 0.9, -1, 16 - i * 3.4)
    gozler(20, ax=3.4, r=1.4)


# ============================================================== 5) BILGE
def bilge():
    """Uzun ak sakal, sivri genis kenarli sapka, degnek."""
    sahne()
    M_gri = mat_isik("Cube", GRI)
    M_ten = mat_isik("Ten", TEN)
    M_ak = mat_isik("Ak", AK)
    M_ahs = mat_isik("Degnek", AHSAP)

    silindir("Degnek", 'z', -30, 14, 1.2, M_ahs, seg=8).location = (18, -6, 0)
    kutu("DegnekUc", 15, -8, 13, 21, -4, 17, M_ahs)

    govde(M_gri)
    kutu("Etek", -17, -7, -30, 17, 7, -18, M_gri)
    # kemer
    kutu("Kemer", -14, -8, -14, 14, -6, -10, mat_isik("Kemer", AHSAP))

    sac_kubbe("SacB", M_ak, 20, 7.6, arka=1.4, ust=2.0, en=2.4, boy=2.6)
    bas(M_ten, 20, hw=7.6)
    # AK SAKAL: cenenin ONUNDE, gogse dogru inen konik kutle
    yumru("Sakal", M_ak, 14, (0, -6.5, 11), 7, 4.0, tohum=1.3)
    yumru("Sakal2", M_ak, 9, (0, -7, 3), 5.0, 3.4, tohum=2.5)
    yumru("Sakal3", M_ak, 6, (0, -6.5, -4), 3.4, 2.8, tohum=3.9)
    yumru("Biyik", M_ak, 5, (0, -8, 16.5), 4, 2.2, tohum=0.6)
    # SIVRI SAPKA: genis kenar + konik tepe
    silindir("Kenar", 'z', 25, 27, 15, M_gri, seg=20)
    silindir("Tepe", 'z', 26, 44, 8.5, M_gri, seg=20, r1=1.2)
    silindir("Bant", 'z', 27, 30, 8.8, mat_isik("Bant", GRI[:2]), seg=20)
    gozler(20, ax=3.4, r=1.4)


KALIPLAR = (("kuzeyli", kuzeyli), ("kimyager", kimyager), ("cirak", cirak),
            ("kralice", kralice), ("bilge", bilge))


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (TEN, SIYAH, KURK, DERI, CELIK, SARI, YESIL, BORDO, ALTIN,
              GUMUS, MAVI, GRI, AK, AHSAP):
        ok += g
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "hepsi"
    os.makedirs(OUT, exist_ok=True)
    yollar = []
    for ad, fn in KALIPLAR:
        if mode not in ("hepsi", ad):
            continue
        fn()
        yollar.append(px.outline(px.render(os.path.join(OUT, "k_%s.png" % ad)),
                                 "#2b2018", 110))
    if yollar:
        px.contact(yollar, 5, os.path.join(OUT, "kalip_x5.png"), scale=5)
    print("KALIP_DONE %s" % mode)


if __name__ == "__main__":
    main()
