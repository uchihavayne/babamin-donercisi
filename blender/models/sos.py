"""SOS RAFI / ISKENDER TABAGI / IZGARA / TATLI - 3B model + piksel render.

Oyundaki karsiliklari:
  js/art.js  -> drawSauceStation(x, y, w, h, ...)   ST.sauce  48x48
  js/food.js -> drawPlate(cx, cy, pl, t, sc)        tabak     ~48x28
  js/art.js  -> drawGrill(x, y, w, h, Gr, t, cap)   ST.grill  68x46
  js/art.js  -> tatli istasyonu (drawSweet icinde)  ST.sweet  34x34

Dorduyle de ayni sorun var: hepsi DUZ. Sise dikdortgen, tabak elips,
izgara gri kutu, tatli da halka. Hicbirinde hacim yok, o yuzden
tezgahin uzerinde "cizilmis" duruyorlar, "duruyor" gibi durmuyorlar.

  SISE   : govde silindir, omuz konik, boyun ince, ustte kapak.
           Icindeki sos seviyesi camdan gorunuyor; her sosun kendi
           siluetı var (aci uzun-ince, sarimsak bodur, tereyagi klasik).
  TABAK  : porselen kase - yukselen kenar + gomuk yuzey. Icindekiler
           dagilmis kupler degil, bir YIGIN: pide yatagi, ustunde
           kivrilmis et dilimleri, uzerine akan tereyagi, kenarda
           yogurt kepcesi.
  IZGARA : ates kutusu + YUVARLAK cubuklardan izgara. Cubuklarin
           arasindan asagidaki kor goruniyor - duz cizimde bu yok,
           izgara sadece cizgili bir dikdortgendi.
  TATLI  : halka (donut gibi duruyordu) yerine BAKLAVA: serbet
           tepsisinde baklava dilimleri, katlari gorunur, ustu fistikli.

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
K = 0.42                      # tabak/izgara icin oblik acilim


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


def silindir(name, eksen, a0, a1, r, mat, seg=24, r1=None):
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


def kure(ad, mat, seg=18, ring=12):
    bm = bmesh.new()
    try:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, radius=1.0)
    except TypeError:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring, diameter=1.0)
    ob = new_obj(ad, bm)
    ob.data.materials.append(mat)
    return ob


def prizma(ad, kose, z0, z1, mat):
    """Duz kenarli prizma - baklava dilimi icin."""
    bm = bmesh.new()
    alt = [bm.verts.new((x, y, z0)) for (x, y) in kose]
    ust = [bm.verts.new((x, y, z1)) for (x, y) in kose]
    n = len(kose)
    for i in range(n):
        bm.faces.new((alt[i], alt[(i + 1) % n], ust[(i + 1) % n], ust[i]))
    bm.faces.new(list(reversed(alt)))
    bm.faces.new(ust)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(ad, bm, smooth=False)
    ob.data.materials.append(mat)
    return ob


def mat_nx(ad, ramp, ax="X", **kw):
    n = len(ramp)
    stops = [i / (n - .6) for i in range(n)]
    return px.cel_nx(ad, ramp, stops, axis=ax, **kw)


# ------------------------------------------------------------- paletler
CAM = ["#2f4a5a", "#43606f", "#5f8296", "#8fb0c2", "#c6dbe6"]      # sise cami
ACI = ["#5e0f0a", "#8e1c14", "#c02a1e", "#e2382a", "#ff7a62"]      # aci sos
SAR = ["#8a8272", "#b0a894", "#cfc7b2", "#e8e2d0", "#ffffff"]      # sarimsak
TER = ["#8a5a10", "#c98a1a", "#f0b53c", "#ffd77a", "#fff0c0"]      # tereyagi
AHS = ["#4e2e17", "#6b4122", "#8a5730", "#a8703f", "#c99565"]      # ahsap
CEL = ["#33393f", "#4d545c", "#6f7880", "#98a2ab", "#c6ced5"]      # celik
POR = ["#9aa4ac", "#c2ccd4", "#e2eaf0", "#f4f8fb", "#ffffff"]      # porselen
ET = ["#7a3f12", "#a5622a", "#d18c42", "#f0b269", "#ffd9a0"]       # et
PID = ["#7a5228", "#a3742f", "#d9a765", "#f0cd94", "#fce7bd"]      # pide
YOG = ["#c9c4b4", "#e4e0d2", "#f4f2e8", "#fbfaf4", "#ffffff"]      # yogurt
KOR = ["#6b1a06", "#a83a12", "#e0500f", "#ff7a2a", "#ffb04a"]      # kor
BAK = ["#8a5a1a", "#b8842c", "#dcae55", "#f0cd82", "#ffe6ae"]      # baklava
FIS = ["#2f4a1e", "#47692c", "#6b9440", "#93bd63"]                 # fistik


def gunes():
    px.world("#141014", 0.30)
    px.sun(math.pi, rot=(52, 0, -40))


def mat_isik(ad, ramp, stops=None):
    if stops is None:
        n = len(ramp)
        stops = [0.0] + [0.16 + 0.66 * i / (n - 1) for i in range(1, n)]
    return px.cel(ad, ramp, stops)


# ============================================================ 1) SOS RAFI
def sahne_sos():
    """Uc sikma sisesi ahsap rafta.

    Onceki cizimde sise duz bir dikdortgendi: omuz yok, boyun yok,
    icindeki sos gorunmuyordu. Sise govdesi SOSUN RENGINDE - tezgahta
    duran bir sikma sisesi boyle okunur; cam yalnizca kenardaki
    parlamadir. Ust bosluk ve seviye cizgisi de goruluyor.
    """
    px.reset(); px.setup(48, 48)
    px.ortho_cam(0, 0, 48, 48)
    px.world("#000000", 0.0)

    M_ahs = mat_nx("Ahsap", AHS)
    M_pano = px.flat("Pano", "#2a2018")

    kutu("Pano", -24, 14, -8, 24, 15, 24, M_pano)
    kutu("Raf", -24, -8, -20, 24, 12, -14, M_ahs)
    kutu("RafKenar", -24, -9, -21, 24, -8, -14, mat_nx("RafK", AHS))

    siseler = (
        # (x, r, govde z0, z1, omuz boyu, sos rampasi, kapak, doluluk)
        (-16, 4.8, -14, 2, 5, ACI, "#8e1c14", 0.74),      # aci: uzun-ince
        (0, 6.2, -14, -2, 4, SAR, "#8a8272", 0.52),       # sarimsak: bodur
        (16, 5.2, -14, 0, 5, TER, "#8a5a10", 0.86),       # tereyagi: klasik
    )
    for i, (sx, r, z0, z1, omuz, sos, kapak, dolu) in enumerate(siseler):
        M_sos = mat_nx("Sos%d" % i, sos)
        M_bos = mat_nx("Bos%d" % i, [sos[0], sos[1], sos[2]])   # ust bosluk
        zs = z0 + (z1 - z0) * dolu
        # dolu kisim: sosun kendi rengi
        ob = silindir("Dolu%d" % i, 'z', z0, zs, r, M_sos, seg=20)
        ob.location.x = sx
        # bos kisim: ayni renk ama koyu - seviye cizgisi buradan okunur
        ob = silindir("Bos%d" % i, 'z', zs, z1, r, M_bos, seg=20)
        ob.location.x = sx
        ob = silindir("Seviye%d" % i, 'z', zs - 0.5, zs + 0.5, r + 0.15,
                      px.flat("Sv%d" % i, sos[4]), seg=20)
        ob.location.x = sx
        # omuz + boyun
        ob = silindir("Omuz%d" % i, 'z', z1, z1 + omuz, r, M_bos, seg=20, r1=2.6)
        ob.location.x = sx
        ob = silindir("Boyun%d" % i, 'z', z1 + omuz, z1 + omuz + 3, 2.6, M_bos, seg=14)
        ob.location.x = sx
        # kapak: bilezik + govde + agiz
        M_kap = mat_nx("Kpk%d" % i, ["#2f363c", "#4d545c", "#6f7880", "#98a2ab"])
        ob = silindir("Bilezik%d" % i, 'z', z1 + omuz + 2.4, z1 + omuz + 4, 3.4,
                      px.flat("Blz%d" % i, kapak), seg=14)
        ob.location.x = sx
        ob = silindir("Kapak%d" % i, 'z', z1 + omuz + 4, z1 + omuz + 8, 3.0,
                      M_kap, seg=14)
        ob.location.x = sx
        ob = silindir("Agiz%d" % i, 'z', z1 + omuz + 8, z1 + omuz + 10, 1.2,
                      M_kap, seg=10)
        ob.location.x = sx
        # etiket: govdeyi saran krem bant
        M_et = mat_nx("Etk%d" % i, ["#b0a894", "#cfc7b2", "#e8e2d0", "#f4efe0",
                                    "#ffffff"])
        ob = silindir("Etiket%d" % i, 'z', z0 + 4, z0 + 12, r + 0.4, M_et, seg=20)
        ob.location.x = sx
        # etiketteki simge lekesi
        sim = kure("Sim%d" % i, px.flat("Sm%d" % i, sos[3]))
        sim.scale = (2.2, 1.0, 1.6)
        sim.location = (sx, -(r + 1.0), z0 + 8)

    px.shear_scene(0.10)


# ====================================================== 2) ISKENDER TABAGI
def sahne_tabak(garnitur=True):
    """Porselen kase + pide yatagi + et + tereyagi + yogurt.

    Iki hata vardi: mavi kenar seridi DOLU bir disk oldugu icin butun
    tabagi maviye boyuyordu (gercek serit ince bir HALKA olmali), ve
    yemek tabagin ortasinda kucucuk bir lekeydi. Gercek iskender
    tabagi doludur: altta pide yatagi, ustunde kivrilmis et dilimleri,
    uzerine akan tereyagi, kenarda ayri bir yogurt kepcesi.
    """
    px.reset(); px.setup(52, 30)
    px.ortho_cam(0, 0, 52, 30)
    gunes()

    M_por = mat_isik("Por", POR)
    M_kase = mat_isik("Por2", ["#8e98a0", "#aeb8c0", "#ccd6de", "#e6eef4"])
    M_pid = mat_isik("Pide", PID)
    M_et = mat_isik("Et", ET)
    M_yog = mat_isik("Yog", YOG)
    M_ter = mat_isik("Ter", TER)

    # --- tabak: ayak + govde + yukselen kenar + gomuk yuzey ---
    silindir("Ayak", 'z', -9, -7, 12, M_kase, seg=24)
    silindir("Govde", 'z', -7, -3, 22, M_por, seg=32)
    silindir("Kenar", 'z', -3, -1, 22, M_por, seg=32)      # yukselen kenar
    silindir("Yuzey", 'z', -3, -2.4, 18, M_kase, seg=32)   # gomuk yuzey
    # mavi serit: gercek HALKA (disk degil) - once mavi, ustune porselen
    silindir("SeritM", 'z', -1, -0.7, 21.0, px.flat("Sm", "#8fb4d8"), seg=32)
    silindir("SeritI", 'z', -1, -0.6, 19.4, M_por, seg=32)

    # --- pide yatagi: kaseyi dolduran yigin ---
    for i in range(30):
        a = i * 2.399
        rr = 2 + (i % 6) * 2.6
        kx = math.cos(a) * rr
        ky = math.sin(a) * rr * 0.52
        kz = -2.4 + (1 - rr / 15.0) * 4.6
        k = kutu("Pide%d" % i, kx - 2.1, ky - 1.7, kz, kx + 2.1, ky + 1.7,
                 kz + 2.8, M_pid)
        k.rotation_euler = (0, 0, a)

    # --- et dilimleri: kivrilmis seritler, yiginin ustunu kaplar ---
    for i in range(13):
        a = i * 1.83
        rr = 1.5 + (i % 5) * 2.7
        ex = math.cos(a) * rr
        ey = math.sin(a) * rr * 0.48
        ez = 2.4 + (1 - rr / 14.0) * 3.2
        d = silindir("Et%d" % i, 'x', -4.6, 4.6, 1.6, M_et, seg=10, r1=1.1)
        d.rotation_euler = (math.radians(-54), 0, a * 0.8)
        d.location = (ex, ey, ez)

    # --- tereyagi sosu: yiginin uzerine akan tabaka ---
    sos = kure("Sos", M_ter)
    sos.scale = (12, 6.6, 1.1)
    sos.location = (-2, -0.5, 6.2)
    for i in range(6):
        d = kure("Damla%d" % i, M_ter)
        d.scale = (2.0, 1.3, 0.8)
        d.location = (-11 + i * 4.2, -3.8 + (i % 2) * 1.8, 5.0)

    # --- yogurt: kenarda ayri kepce ---
    y = kure("Yogurt", M_yog); y.scale = (6.8, 4.8, 3.6)
    y.location = (13.5, -1.5, 2.4)
    y2 = kure("Yogurt2", M_yog); y2.scale = (3.6, 2.8, 2.4)
    y2.location = (12.0, -3.0, 4.8)

    if garnitur:
        for i in range(2):
            t = silindir("Dom%d" % i, 'z', 0, 1.6, 3.4,
                         mat_isik("Dom", ["#7a1c12", "#a82a1c", "#d8402c",
                                          "#f06a4a"]), seg=16)
            t.location = (-13 + i * 5, 7.5, 0.4)
            ic = silindir("DomIc%d" % i, 'z', 1.6, 1.9, 2.2,
                          px.flat("DomIcM%d" % i, "#f08a68"), seg=16)
            ic.location = (-13 + i * 5, 7.5, 0.4)
        b = silindir("Biber", 'z', 0, 11, 1.9,
                     mat_isik("Bib", ["#1e3a12", "#2f5a1c", "#468a28",
                                      "#6bb83e"]), seg=12, r1=0.7)
        b.rotation_euler = (math.radians(-64), 0, math.radians(18))
        b.location = (7, 7, 0.4)

    px.shear_scene(K)


# ============================================================== 3) IZGARA
def sahne_izgara(dolu=0):
    """Ates kutusu + YUVARLAK cubuklardan izgara.

    Ilk denemede govde DOLU bir kutuydu ve hem cubuklari hem koru
    yutmustu - bu oturumda besinci kez ayni hata (icecek dolabi,
    fritoz haznesi, vitrin cercevesi, kepenk agzi). Ates kutusu ACIK
    KABUK olmali: taban tepsisi + dort duvar, ustu acik. Derinlik
    hissi de tam oradan geliyor: cubuklarin arasindan kor goruluyor.
    """
    px.reset(); px.setup(68, 46)
    px.ortho_cam(0, 2, 68, 46)
    gunes()

    M_cel = mat_isik("Cel", CEL)
    M_koyu = mat_isik("Koyu", ["#12161a", "#1e242a", "#2c343c", "#3c4650"])
    M_kor = px.cel("Kor", KOR, [0.0, .12, .28, .48, .70])

    # --- ACIK KABUK: taban + dort duvar ---
    kutu("Taban", -32, -11, -20, 32, 11, -16, M_koyu)
    # ON ve YAN duvarlar izgaranin ALTINDA biter (z=-4); yoksa duvar
    # izgarayi ve koru ortuyor - ilk denemede tam bu oldu.
    kutu("OnDuvar", -32, -13, -20, 32, -10, -5, M_cel)
    kutu("ArkaDuvar", -32, 10, -20, 32, 13, 4, M_cel)
    kutu("SolDuvar", -34, -13, -20, -31, 13, -5, M_cel)
    kutu("SagDuvar", 31, -13, -20, 34, 13, -5, M_cel)
    kutu("OnBant", -32, -14, -12, 32, -13, -8, mat_isik("Cel2", CEL[1:]))
    for sx in (-30, 26):                                        # ayaklar
        kutu("Ayak%d" % (sx + 40), sx, -8, -26, sx + 4, 8, -20, M_koyu)

    # --- kor yatagi: cubuklarin ALTINDA, artik goruluyor ---
    # Kor yatagi cubuklarin HEMEN ALTINDA olmali: 5 birim asagida
    # kalinca oblik acilimda cubuklarin taradigi bandin altina dusuyor
    # ve aralardan hicbir sey gorunmuyordu.
    kutu("KorZemin", -30, -10, -3.6, 30, 10, -2.8,
         px.flat("KorZ", "#e0500f"))
    for i in range(26):
        a = i * 2.399
        kx = math.cos(a) * ((i % 7) * 4.4 + 2)
        ky = math.sin(a) * ((i % 4) * 2.4 + 1)
        k = kure("Kor%d" % i, M_kor)
        k.scale = (2.6, 2.0, 1.1)
        k.location = (kx, ky, -2.6)

    # --- izgara cubuklari: ONDEN ARKAYA. Soldan saga uzananlar oblik
    #     acilimda ust uste biniyor ve arada bosluk kalmiyordu; onden
    #     arkaya uzananlar ise birer dikey serit olarak okunuyor. ---
    for i in range(18):
        cx0 = -30 + i * 3.55
        c = silindir("Cubuk%d" % i, 'y', -10, 10, 0.95, M_cel, seg=10)
        c.location = (cx0, 0, -0.8)
    for cy0 in (-9, 9):                                         # enine profiller
        kutu("Profil%d" % (cy0 + 20), -31, cy0 - 1.2, -3.2, 31, cy0 + 1.2, -2.2,
             M_cel)

    # --- arka kapak (hood) ---
    kutu("Kapak", -32, 6, 6, 32, 13, 13, M_cel)
    kutu("KapakUst", -32, 6, 12, 32, 13, 14.5, mat_isik("Cel3", CEL[1:]))
    kutu("Sap", -7, 2, 14, 7, 5, 16.5, M_koyu)
    kutu("SapKol1", -7, 2, 13, -5, 5, 15, M_cel)
    kutu("SapKol2", 5, 2, 13, 7, 5, 15, M_cel)

    # on panel: tutamak rayi + iki dugme - duz gri levha olmasin
    kutu("Ray", -26, -16, -13, 26, -14, -11.5, M_cel)
    for sx in (-24, 22):
        kutu("RayAyak%d" % (sx + 30), sx, -16, -16, sx + 2, -13, -11.5, M_cel)
    for sx in (-14, 12):
        d = silindir("Dugme%d" % (sx + 20), 'y', -15, -13, 2.2,
                     mat_isik("Dgm", ["#1e242a", "#3c4650", "#5c6874"]), seg=12)
        d.location = (sx, 0, -17)

    if dolu:
        M_ek = mat_isik("Ekmek", PID)
        for i in range(dolu):
            d = silindir("Durum%d" % i, 'x', -11, 11, 3.6, M_ek, seg=14)
            d.location = (0, -5 + i * 9, 1.6)

    px.shear_scene(K)


# =============================================================== 4) TATLI
def sahne_tatli(adet=6):
    """Serbet tepsisinde BAKLAVA.

    Onceki cizim halka seklindeydi - ekranda donut gibi duruyordu.
    Ilk 3B denemede de tepsi kenarlari baklavadan yuksek kalinca
    yalnizca fistiklar goruniyordu; kenarlar alcaltildi.
    """
    px.reset(); px.setup(34, 34)
    px.ortho_cam(0, -2, 34, 34)
    gunes()

    M_tep = mat_isik("Tepsi", CEL)
    M_bak = mat_isik("Baklava", BAK)
    M_kat = mat_isik("Kat", ["#a3742f", "#cf9c47", "#eec27a", "#ffe6ae"])
    M_fis = mat_isik("Fistik", FIS)
    M_ser = px.flat("Serbet", "#a8781f")

    # --- tepsi: ALCAK kenar, baklava uzerinde kalsin ---
    kutu("Taban", -15, -9, -15, 15, 9, -12, M_tep)
    for kx0, ky0, kx1, ky1 in ((-15, -9, -13, 9), (13, -9, 15, 9),
                               (-15, 7, 15, 9), (-15, -9, 15, -7)):
        kutu("Kenar%d_%d" % (kx0 + 20, ky0 + 20), kx0, ky0, -15, kx1, ky1, -10.5,
             M_tep)
    kutu("Serbet", -13, -7, -12, 13, 7, -11.2, M_ser)

    # --- baklava dilimleri: eskenar dortgen prizma, kat kat ---
    yer = ((-8, 3.5), (0, 3.5), (8, 3.5), (-8, -3.5), (0, -3.5), (8, -3.5))
    for i in range(min(adet, len(yer))):
        bx, by = yer[i]
        kose = [(bx - 4.4, by), (bx, by - 2.8), (bx + 4.4, by), (bx, by + 2.8)]
        prizma("Bak%d" % i, kose, -12, -6.0, M_bak)
        kose2 = [(bx - 3.5, by), (bx, by - 2.2), (bx + 3.5, by), (bx, by + 2.2)]
        prizma("Kat%d" % i, kose2, -6.0, -4.6, M_kat)
        for j in range(3):
            f = kure("Fis%d_%d" % (i, j), M_fis)
            f.scale = (0.95, 0.75, 0.65)
            f.location = (bx - 1.5 + j * 1.5, by - 0.4 + (j % 2) * 0.9, -4.3)

    px.shear_scene(K)


# ======================================================== 5) PATATES KUTUSU
def sahne_kutu(hal="dolu"):
    """Patates kutusu: yamuk govde + on kapak + disari tasan cubuklar.

    hal: "dolu" | "bos".  Oyunda baska hal yok - drawFriesCup yalniz
    'ok' ve 'bos' ile cagriliyor.

    Oyundaki cizim (js/food.js -> drawFriesCup) zaten yamuk bir govde
    ve dik cubuklar cizyordu ama kutu DUZ bir levhaydi: kenar katlari,
    on kapagin ustune bindigi cizgi ve agzin karanligi yoktu. 3B'de
    bunlar kendiliginden cikiyor - kutu bir KUTU gibi duruyor.
    """
    px.reset(); px.setup(46, 46)
    px.ortho_cam(0, 2, 46, 46)
    gunes()

    M_kut = mat_isik("Kutu", ["#7d1610", "#96201a", "#c22a20", "#e8483a",
                              "#ff7f6c"])
    M_kap = mat_isik("Kapak", ["#8a7a10", "#c9a41c", "#eddc55", "#fbf090"])
    M_ic = px.flat("KutuIc", "#5e120d")
    # YANIK HAL YOK. Fritoz durum makinesi idle -> fry -> done; 'done'a
    # gelince orada kalir. Yanma sayaci (yanar/yanSure/burnt) yalniz
    # IZGARADAKI durumlere ait. Yanik patates tasarlamak bosa isti.
    M_pat = mat_isik("Patates", ["#8a5a12", "#e0a828", "#f0c24a", "#f8d874",
                                 "#fff0c0"])

    # --- govde: asagi daralan yamuk, dort duvar (icini yutmasin) ---
    ust, alt, z0, z1 = 17, 11, -18, -2
    n = 14
    for i in range(n):
        u = i / (n - 1.0)
        g = ust + (alt - ust) * u
        z = z1 + (z0 - z1) * u
        kutu("On%d" % i, -g, -7, z, g, -6, z + 1.4, M_kut)
        kutu("Sol%d" % i, -g, -7, z, -g + 1.6, 7, z + 1.4, M_kut)
        kutu("Sag%d" % i, g - 1.6, -7, z, g, 7, z + 1.4, M_kut)
        # Arka duvar da DARALMALI: tam genislikte dolu bir levha
        # birakilinca yandan daralan duvarlarin arkasindan tasiyor ve
        # siluet dikdortgene donuyordu.
        kutu("Arka%d" % i, -g, 6, z, g, 7, z + 1.4, M_kut)
    kutu("Agiz", -ust + 2, -6, z1 - 2, ust - 2, 6, z1, M_ic)     # karanlik ic
    # on kapak: govdenin onune katlanan sari bant
    for i in range(6):
        u = (i + 2) / (n - 1.0)
        g = ust + (alt - ust) * u
        z = z1 + (z0 - z1) * u
        kutu("Kap%d" % i, -g + 1, -7.6, z, g - 1, -6.8, z + 1.4, M_kap)

    if hal != "bos":
        # --- cubuklar: boylari ve egimleri farkli, kutudan tasar ---
        for i in range(22):
            a = i * 2.399
            fx = math.cos(a) * (3 + (i % 5) * 2.4)
            fy = math.sin(a) * 4
            boy = 9 + (i % 5) * 2.6
            c = silindir("Pat%d" % i, 'z', 0, boy, 1.7, M_pat, seg=6)
            c.rotation_euler = (math.radians((i % 5 - 2) * 6),
                                math.radians((i % 3 - 1) * 8), 0)
            c.location = (fx, fy, -6)
    px.shear_scene(0.30)


# ====================================================== 6) PATATES PORSIYONU
def sahne_porsiyon():
    """Tepsideki patates yigini: uc tonlu, uclari kizarmis cubuklar."""
    px.reset(); px.setup(52, 34)
    px.ortho_cam(0, 0, 52, 34)
    gunes()

    M_tep = mat_isik("Tepsi", CEL)
    tonlar = [mat_isik("P0", ["#8a5a12", "#c98a1e", "#e0a828", "#f0c24a"]),
              mat_isik("P1", ["#9a6a18", "#dca030", "#f0c24a", "#f8d874"]),
              mat_isik("P2", ["#7a4a10", "#b87c1a", "#d89a28", "#eab850"])]
    kutu("Tepsi", -24, -10, -16, 24, 10, -13, M_tep)
    # Tepsi kenari yiginin USTUNDE kalinca patates gorunmuyordu; kenar
    # alcaltildi (tatli tepsisinde de ayni hata olmustu).
    for kx0, ky0, kx1, ky1 in ((-24, -10, -22, 10), (22, -10, 24, 10),
                               (-24, 8, 24, 10), (-24, -10, 24, -8)):
        kutu("Ken%d_%d" % (kx0 + 30, ky0 + 30), kx0, ky0, -16, kx1, ky1, -12, M_tep)
    # Yigin yatay bir lekeydi: cubuklar hep ayni yukseklikteydi ve
    # tepsi kenarinin altinda kaliyordu. Artik uc kat halinde yigiliyor.
    for kat in range(3):
        adet = 16 - kat * 4
        for i in range(adet):
            a = i * 2.399 + kat * 1.1
            yay = (1 - kat * 0.26)
            fx = math.cos(a) * (3 + (i % 5) * 3.0) * yay
            fy = math.sin(a) * (2 + (i % 3) * 1.8) * yay
            fz = -12 + kat * 3.4
            boy = 9 + (i % 4) * 3
            c = silindir("Cub%d_%d" % (kat, i), 'x', -boy / 2.0, boy / 2.0, 1.5,
                         tonlar[(i + kat) % 3], seg=6)
            c.rotation_euler = (0, math.radians((i % 3 - 1) * 12), a * 0.7)
            c.location = (fx, fy, fz)
    px.shear_scene(0.42)


# ========================================================== 7) ISKENDER PIDESI
def sahne_pide(kesim=0, bicak=-1):
    """Tahtada iskender pidesi.

    kesim : kac serit kupe ayrilmis (0..5)
    bicak : -1 yok, 0..1 vurus fazi (0 tepede, 1 tahtaya carpti)

    Oyundaki cizim pideyi 18 piksel yuksek KUBBELI dilimler halinde
    veriyordu; ekranda somun ekmek gibi duruyordu. Iskender pidesi
    yassidir: capinin sekizde biri kalinlikta, ust yuzeyi baklava
    dilimi ciziklerle bolunmus, kenari sisik ve daha koyu. Dograninca
    KUP cikar, dilim degil.
    """
    px.reset(); px.setup(96, 46)
    px.ortho_cam(0, 2, 96, 46)
    gunes()

    M_ust = mat_isik("PideUst", ["#8a5f2a", "#b8842c", "#dcae55", "#f0cd94",
                                 "#fce7bd"])
    M_kbk = mat_isik("PideKabuk", ["#5e3a12", "#8a5f2a", "#a8762e", "#c98f3c"])
    M_ic = mat_isik("PideIc", ["#c9b078", "#e2cfa0", "#f4e6c2"])
    M_taht = mat_isik("Tahta", AHS)
    M_cel = mat_isik("Celik", ["#6d7a86", "#aab4bd", "#dfe6ec", "#ffffff"])
    M_sap = mat_isik("Sap", ["#3a2718", "#7a5230", "#a5733f"])

    kutu("Tahta", -42, -15, -16, 42, 15, -11, M_taht)

    KAL, GEN, DER, KES = 4.4, 30.0, 11.0, 5
    ZT = -11                                    # tahta ustu

    def serit(i):
        """i. dusey seridin (x merkez, yari-genislik, yari-derinlik, yukseklik)"""
        u = (i + .5) / KES - .5                 # -0.4 .. 0.4
        kk = abs(u * 2.5)                       # 0 ortada .. 1 uclarda
        der = DER * math.sqrt(max(.10, 1 - kk * kk * .80))
        yuk = KAL * (0.78 + 0.22 * math.sqrt(max(0, 1 - kk * kk)))
        return u * GEN * 2, GEN / KES, der, yuk

    for i in range(KES):
        cx, w, der, yuk = serit(i)
        ayr = 0.0 if i >= kesim else 0.9        # kesilenler araliyor
        pay = 0.0 if i >= kesim else 0.6        # kesik yuzler arasi bosluk
        gx0, gx1 = cx - w + pay - ayr * (kesim - i), cx + w - pay - ayr * (kesim - i)
        # kabuk govdesi
        kutu("Pd%d" % i, gx0, -der, ZT, gx1, der, ZT + yuk, M_kbk)
        # ust yuzey: kenardan 1.2 icerde, acik ton -> sisik kenar hissi
        kutu("PdU%d" % i, gx0 + 1.0, -der + 1.3, ZT + yuk - 1.2,
             gx1 - 1.0, der - 1.3, ZT + yuk + .6, M_ust)
        if i < kesim:
            # kesik yuz: gozenekli beyaz ic
            kutu("Ic%d" % i, gx1 - .7, -der + .8, ZT + .3,
                 gx1 + .1, der - .8, ZT + yuk - .5, M_ic)
        else:
            # butun kisim: enine kesik izleri (baklava deseni)
            for j in range(3):
                yy = -der + (j + .6) * der * .66
                kutu("Cz%d_%d" % (i, j), gx0 + 1.4, yy, ZT + yuk - .3,
                     gx1 - 1.4, yy + .8, ZT + yuk + .5, M_kbk)
            # kabarcik
            k = kure("Kab%d" % i, M_kbk)
            k.scale = (2.2, 1.4, 0.5)
            k.location = (cx + (i % 2) * 3 - 1.5, (i % 3 - 1) * der * .4,
                          ZT + yuk + .4)

    # --- dogranmis kupler: sol tarafta yigin ---
    for i in range(kesim * 3):
        a = i * 2.399
        kx = -GEN - 10 + (i % 4) * 5.2
        ky = math.sin(a) * 6
        kz = ZT + (i // 4) * 3.2
        k = kutu("Kup%d" % i, kx - 2.3, ky - 2.1, kz, kx + 2.3, ky + 2.1,
                 kz + 2.9, M_ust)
        k.rotation_euler = (0, 0, a * .5)
        kutu("KupIc%d" % i, kx - 1.9, ky - 2.3, kz + .3, kx + 1.9, ky - 2.0,
             kz + 2.5, M_ic)

    # --- bicak: dik iner, sap saga dogru ---
    if bicak >= 0:
        cx, w, der, yuk = serit(min(kesim, KES - 1))
        bx = cx + w
        yuks = 16 * (1 - bicak) ** 2
        z0 = ZT + yuk + yuks
        kutu("Namlu", bx - 1.1, -10, z0, bx + 1.1, 10, z0 + 13, M_cel)
        kutu("Sirt", bx - 1.1, -10, z0 + 12, bx + 1.1, 10, z0 + 14, M_sap)
        kutu("Sap", bx - 2.0, 8, z0 + 6, bx + 2.0, 16, z0 + 12.5, M_sap)

    px.shear_scene(K)


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (CAM, ACI, SAR, TER, AHS, CEL, POR, ET, PID, YOG, KOR, BAK, FIS):
        ok += g
    ok += ["#2a2018", "#8fb4d8", "#ffffff", "#f08a68", "#b8842c"]
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "hepsi"
    os.makedirs(OUT, exist_ok=True)

    def cek(ad):
        return px.outline(px.render(os.path.join(OUT, "s_%s.png" % ad)),
                          "#2b2018", 105)

    yollar = []
    if mode in ("hepsi", "sos"):
        sahne_sos(); yollar.append(cek("sos"))
    if mode in ("hepsi", "tabak"):
        sahne_tabak(garnitur=False); yollar.append(cek("tabak0"))
        sahne_tabak(garnitur=True); yollar.append(cek("tabak1"))
    if mode in ("hepsi", "izgara"):
        sahne_izgara(dolu=0); yollar.append(cek("izgara0"))
        sahne_izgara(dolu=2); yollar.append(cek("izgara2"))
    if mode in ("hepsi", "tatli"):
        sahne_tatli(adet=6); yollar.append(cek("tatli"))
    if mode in ("hepsi", "pide"):
        for kk, bb in ((0, 0.0), (1, 0.85), (2, -1), (4, -1)):
            sahne_pide(kesim=kk, bicak=bb); yollar.append(cek("pide%d" % kk))
    if mode in ("hepsi", "patates"):
        for h in ("dolu", "bos"):
            sahne_kutu(hal=h); yollar.append(cek("kutu_" + h))
        sahne_porsiyon(); yollar.append(cek("porsiyon"))
    if yollar:
        px.contact(yollar, 3, os.path.join(OUT, "sos_x5.png"), scale=5)
    print("SOS_DONE %s" % mode)


if __name__ == "__main__":
    main()
