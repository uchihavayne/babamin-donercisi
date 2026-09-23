"""ACILIS HIKAYESI - 5 sahne, 3B model + piksel-art render.

Oyundaki karsiligi: js/prologue.js -> PRO_SCENES
Sahne cercevesi: 400 x 150 piksel, (40,44) konumunda.

  1 proShopDay  "Babam bu dukkani kirk yil isletti..."
  2 proFather   "Bir durum, bir insani doyurur derdi..."
  3 proClosed   "Gecen kis gitti. Kepenk uc ay kapali kaldi."
  4 proDebt     "Sonra kapiya bir kagit geldi... $5.000.000"
  5 proKey      "Anahtar bende, ocak sogumadi."

ARAC SECIMI - ilk denemede ogrenilen ders:
  Mimarî duz kutulardan olusur; her on yuzun normali ayni (0,-1,0),
  dolayisiyla cel_nx bunlara TEK ton verir. Ilk render bu yuzden
  mukavva gibi ciktikti. Cozum, aracin dogru olanini secmek:

    px.flat  -> mimari. Her yuzeyin tonunu ELDE seciyorum; isik/golge
                tasarimi benim, motorun degil. Piksel artta dogrusu bu.
    px.cel   -> organik form (baba portresi, el, anahtar). Gercek gunes
                yonu + lambert -> yuzun hacmi cikiyor.
    cel_nx   -> sis/doner. Oyunun kendi bantlama mantigi.

  3B'nin buradaki asil kazanci: dogru ortu-sirasi (occlusion), oblik
  izdusumden gelen ust yuzeyler ve olcek tutarliligi.

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
W, H = 400, 150
K = 0.10                      # oblik izdusum egimi: z += y*K


# ----------------------------------------------------------- yardimcilar
_MATS = {}
_RENK = set()


def F(col):
    """Duz renk materyali - ayni hex bir kez uretilir."""
    m = _MATS.get(col)
    if m is None:
        m = px.flat("M_%s" % col[1:], col)
        _MATS[col] = m
        _RENK.add(col)
    return m


def new_obj(name, bm, smooth=False):
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
    ob.scale = (max(0.4, abs(x1 - x0)), max(0.4, abs(y1 - y0)),
                max(0.4, abs(z1 - z0)))
    ob.location = ((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
    ob.data.materials.append(mat)
    return ob


def kt(ad, x0, y0, z0, x1, y1, z1, col):
    """EKRAN koordinatiyla kutu.

    z degerleri render'da nereye dusecekse o. shear_scene sonradan
    z += y*K uyguladigi icin burada y0*K kadar geri aliyoruz; boylece
    on yuz tam istedigim yere oturuyor, ust yuzeyin oblik acilimi ise
    korunuyor.
    """
    off = y0 * K
    return kutu(ad, x0, y0, z0 - off, x1, y1, z1 - off, F(col))


def pl(ad, x0, z0, x1, z1, y, col):
    """Ince dikey levha - belirli derinlikte tek renkli yuzey."""
    return kt(ad, x0, y, z0, x1, y + 0.4, z1, col)


def plA(ad, x0, z0, x1, z1, y, col, a=0.25):
    """Yari saydam levha - oyunun globalAlpha golgelerinin karsiligi."""
    off = y * K
    _RENK.add(col)
    return kutu(ad, x0, y, z0 - off, x1, y + 0.4, z1 - off,
                px.flat_a("A_%s_%s" % (ad, col[1:]), col, a))


def plE(ad, cx, cz, gen, boy, aci, y, col, a=0.2):
    """Egik yari saydam serit - vitrin camindaki yansima.

    Buyuk dikdortgen yansima cami sutlu gosteriyordu; gercek vitrin
    ince, egik seritler halinde yansitir.
    """
    _RENK.add(col)
    ob = kutu(ad, cx - gen / 2, y, cz - boy / 2 - y * K,
              cx + gen / 2, y + 0.4, cz + boy / 2 - y * K,
              px.flat_a("E_%s" % ad, col, a))
    ob.rotation_euler = (0, math.radians(aci), 0)
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
    ob = new_obj(name, bm, smooth=True)
    ob.data.materials.append(mat)
    return ob


def kure(ad, mat, seg=18, ring=12):
    bm = bmesh.new()
    try:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring,
                                  radius=1.0)
    except TypeError:
        bmesh.ops.create_uvsphere(bm, u_segments=seg, v_segments=ring,
                                  diameter=1.0)
    ob = new_obj(ad, bm, smooth=True)
    ob.data.materials.append(mat)
    return ob


# Etin siluet profili: 0 = TABAN, 1 = TEPE (koni asagidan yukari orulur).
# Duz konik kenar tahta bir havuc gibi duruyordu; gercek doner ustte
# dar baslar, ust ucte birinde SISER, sonra asagi daralir.
DONER_PROFIL = [.16, .31, .47, .61, .73, .83, .91, .97, 1.00, .99, .90, .74, .50]


def koni(name, z0, z1, r0, r1, mat, seg=26, puruz=0.0, profil=None):
    bm = bmesh.new()
    prev = None
    rings = 18
    for i in range(rings + 1):
        v = i / rings
        z = z0 + (z1 - z0) * v
        if profil:
            fi = v * (len(profil) - 1)
            f0 = min(len(profil) - 1, int(fi))
            f1 = min(len(profil) - 1, f0 + 1)
            pr = profil[f0] + (profil[f1] - profil[f0]) * (fi - f0)
            r = r1 + (r0 - r1) * pr
        else:
            r = r0 + (r1 - r0) * v
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            d = 1 + puruz * math.sin(a * 5.0 + v * 7.0)
            vs.append(bm.verts.new((math.cos(a) * r * d, math.sin(a) * r * d, z)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg],
                              vs[(k + 1) % seg], vs[k]))
        prev = vs
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm, smooth=True)
    ob.data.materials.append(mat)
    return ob


def kagit(ad, x0, z0, x1, z1, y, mat, kivrim=0.0, seg=16, egim=0.0):
    """Hafif kivrimli kagit yuzeyi.

    Duz bir levha yerine ortasi one kalkik bir yuzey: cel gunesle
    render edilince kivrim tonlama farki olarak okunuyor. Kagidin
    "yeni gelmis, henuz duzlesmemis" hissi bundan cikiyor.
    """
    bm = bmesh.new()
    rows = []
    for j in range(seg + 1):
        v = j / float(seg)
        z = z0 + (z1 - z0) * v
        dy = kivrim * math.sin(v * math.pi)
        rows.append([bm.verts.new((x0, y - dy, z - y * K)),
                     bm.verts.new((x1, y - dy, z - y * K))])
    for j in range(seg):
        bm.faces.new((rows[j][0], rows[j][1], rows[j + 1][1], rows[j + 1][0]))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(ad, bm, smooth=True)
    ob.data.materials.append(mat)
    if egim:
        ob.rotation_euler = (0, math.radians(egim), 0)
    return ob


def halka(ad, cx, cz, r, kal, mat, y=0.0, n=18):
    """Kucuk kurelerden ring - anahtar sapi, kilit boynu."""
    obs = []
    for i in range(n):
        a = 2 * math.pi * i / n
        k = kure("%s%d" % (ad, i), mat)
        k.scale = (kal, kal, kal)
        koy(k, cx + math.cos(a) * r, y, cz + math.sin(a) * r)
        obs.append(k)
    return obs


def koy(ob, x, y, z):
    """Nesneyi EKRAN koordinatina koy (shear telafili)."""
    ob.location = (x, y, z - y * K)
    return ob


def mat_nx(ad, ramp, ax="X", **kw):
    n = len(ramp)
    stops = [i / (n - .6) for i in range(n)]
    return px.cel_nx(ad, ramp, stops, axis=ax, **kw)


def mat_isik(ad, ramp, stops=None):
    """Gercek gunes yonuyle cel-shade - organik formlar icin."""
    if stops is None:
        n = len(ramp)
        stops = [0.0] + [0.18 + 0.66 * i / (n - 1) for i in range(1, n)]
    return px.cel(ad, ramp, stops)


# ------------------------------------------------------------- paletler
ET = ["#7a3f12", "#a5622a", "#d18c42", "#f0b269", "#ffd9a0"]
TEN = ["#8a5230", "#a86a3e", "#c9885a", "#e0a978", "#f0bd8a"]
KIRMIZI = ["#6b1610", "#8e2018", "#c33c2c", "#e2604f", "#f08a76"]
BIYIK = ["#8a8172", "#b8b0a0", "#ddd6c8", "#f4f0e6"]
PIRINC = ["#7a5a12", "#a8811f", "#d8ac35", "#ffd75e", "#fff0b0"]
CELIK = ["#33393f", "#4d545c", "#6f7880", "#98a2ab", "#c6ced5"]


# ============================================================== SAHNE 1
def sahne1():
    """SABAH. Dukkan calisiyor; sokak canli, isik soldan.

    Dikey butce (ekran z, kare -61..+89):
      sokak  -61..-48 | kaldirim yuzu -48..-42 | ust -42..-38
      kaide  -38..-30 | VITRIN -30..+22 | kiris +22..+34
      tente  +24..+36 | tabela +38..+60 | gokyuzu ustu

    Tonlama (havadan perspektif): uzak > acik ve mavimsi, yakin > koyu
    ve doygun. Ilk denemede hepsi ayni gri tondaydi, derinlik yoktu.
    """
    px.reset(); _MATS.clear()
    px.setup(W, H)
    px.ortho_cam(0, 14, W, H)
    px.world("#000000", 0.0)

    # ---------------------------------------------------------- GOKYUZU
    gok = [(72, 96, "#5e8fbc"), (56, 72, "#72a2c9"), (42, 56, "#8ab7d6"),
           (28, 42, "#a4cbdf"), (14, 28, "#c0dbe4"), (0, 14, "#dbe4d8"),
           (-62, 0, "#f0e0bc")]
    for i, (z0, z1, c) in enumerate(gok):
        pl("Gok%d" % i, -230, z0, 230, z1, 132, c)
    # sabah gunesi: sagda, dukkanin ustunde acikta kalan gokte
    for i, (r, c) in enumerate(((22, "#f6e6bc"), (15, "#fdf2d2"), (9, "#fffbe8"))):
        s = kure("Gunes%d" % i, F(c)); s.scale = (r, .4, r)
        koy(s, 150, 130, 74)
    for i, (bx, bz, bw, bh, c1, c2) in enumerate((
            (-150, 70, 44, 7, "#e8f2f6", "#c2d8e6"),
            (-58, 80, 30, 6, "#e8f2f6", "#c2d8e6"),
            (54, 84, 40, 6, "#f0f6f8", "#cadfea"))):
        pl("Bul%dA" % i, bx - bw, bz, bx + bw, bz + bh, 128, c1)
        pl("Bul%dB" % i, bx - bw + 4, bz, bx + bw - 8, bz + bh - 3, 127.6, c2)

    # ------------------------------------------- UZAK SILUET (puslu sira)
    U1, U2, U3 = "#9db6c6", "#8aa7ba", "#b2c6d2"
    uzak = [(-238, -186, 30), (-192, -150, 48), (-156, -112, 24),
            (-118, -70, 40), (-76, -30, 20), (-36, 14, 34),
            (10, 56, 16), (52, 104, 38), (98, 148, 26),
            (142, 196, 44), (188, 238, 22)]
    for i, (x0, x1, h) in enumerate(uzak):
        pl("Uz%d" % i, x0, -40, x1, h, 112, U1)
        pl("UzT%d" % i, x0 - 2, h, x1 + 2, h + 3, 111.6, U3)
        for r in range(int((h + 34) // 13)):
            for c in range(max(1, int((x1 - x0) // 12))):
                pl("UzP%d_%d_%d" % (i, r, c), x0 + 5 + c * 12, -34 + r * 13,
                   x0 + 10 + c * 12, -28 + r * 13, 111.4, U2)
    # cami: kubbe + iki minare - sehri yerine oturtan siluet
    kb = kure("Kubbe", F(U3)); kb.scale = (26, 8, 22); koy(kb, 128, 110, 44)
    pl("KubbeKas", 98, 36, 158, 46, 109.6, U1)
    pl("KubbeAlem", 126, 62, 130, 72, 109.4, U3)
    for i, mx in ((0, 102), (1, 156)):
        pl("Min%d" % i, mx - 3, 36, mx + 3, 84, 109.4, U3)
        pl("MinS%d" % i, mx - 5, 76, mx + 5, 80, 109.2, U1)
        pl("MinK%d" % i, mx - 2, 84, mx + 2, 92, 109.4, U3)

    # ---------------------------------------------- ORTA SIRA BINALARI
    O1, O2, O3, O4 = "#7d838a", "#686e75", "#949aa0", "#4a5663"
    orta = [(-236, -168, 28), (-172, -104, 52), (-108, -50, 20),
            (42, 96, 44), (100, 158, 26), (162, 236, 50)]
    for i, (x0, x1, h) in enumerate(orta):
        pl("Or%d" % i, x0, -40, x1, h, 82, O1)
        pl("OrGl%d" % i, x1 - 7, -40, x1, h, 81.8, O2)
        pl("OrIs%d" % i, x0, -40, x0 + 4, h, 81.8, O3)
        pl("OrKr%d" % i, x0 - 3, h, x1 + 3, h + 4, 81.4, O3)
        pl("OrKr2%d" % i, x0 - 3, h - 2, x1 + 3, h, 81.3, O2)
        for r in range(int((h + 36) // 15)):
            for c in range(max(1, int((x1 - x0) // 15))):
                wx = x0 + 6 + c * 15
                wz = -32 + r * 15
                if wz + 9 > h - 6:
                    continue
                pl("OrP%d_%d_%d" % (i, r, c), wx, wz, wx + 7, wz + 9, 81.4, O4)
                pl("OrS%d_%d_%d" % (i, r, c), wx - 1, wz - 2, wx + 8, wz, 81.2, O3)
    pl("Depo", -150, 52, -128, 66, 81.2, O2)
    pl("DepoA", -146, 46, -143, 52, 81.2, O2)
    pl("DepoA2", -135, 46, -132, 52, 81.2, O2)
    for i, (ax, az) in enumerate(((180, 50), (198, 50))):
        pl("Ant%d" % i, ax, az, ax + 2, az + 14, 81.2, O2)
        pl("AntC%d" % i, ax - 5, az + 11, ax + 7, az + 13, 81.2, O2)

    # ------------------------------------ YAKIN SIRA (dukkanin komsulari)
    Y1, Y2, Y3, Y4, Y5 = "#6b6152", "#544c40", "#8a8070", "#2c3742", "#e8bd72"
    for i, (x0, x1, h) in enumerate(((-236, -100, 38), (100, 236, 34))):
        pl("Yk%d" % i, x0, -38, x1, h, 46, Y1)
        pl("YkKr%d" % i, x0, h, x1, h + 5, 45.6, Y3)
        pl("YkKr2%d" % i, x0, h - 3, x1, h, 45.4, Y2)
        pl("YkSo%d" % i, x0, -38, x0 + 3, h, 45.6, Y3)
        pl("YkSa%d" % i, x1 - 6, -38, x1, h, 45.6, Y2)
        pl("YkKat%d" % i, x0, -8, x1, -6, 45.5, Y2)
        pl("YkDkn%d" % i, x0, -38, x1, -28, 45.5, Y2)      # zemin kat dukkani
        n = int((x1 - x0) // 30)
        for c in range(n):
            for r in range(2):
                wx = x0 + 12 + c * 30
                wz = -24 + r * 20
                yanik = (c + r * 3 + i) % 4 == 0
                pl("YkP%d_%d_%d" % (i, c, r), wx, wz, wx + 12, wz + 13, 45.4,
                   Y5 if yanik else Y4)
                pl("YkPC%d_%d_%d" % (i, c, r), wx + 5, wz, wx + 7, wz + 13, 45.2, Y2)
                pl("YkPU%d_%d_%d" % (i, c, r), wx - 2, wz + 13, wx + 14, wz + 15,
                   45.2, Y3)
                if r == 1:
                    for b in range(5):
                        pl("YkB%d_%d_%d" % (i, c, b), wx - 1 + b * 3, wz - 7,
                           wx + b * 3, wz - 1, 44.0, Y2)
                    pl("YkBU%d_%d" % (i, c), wx - 3, wz - 1, wx + 15, wz + 1,
                       43.8, Y3)

    # --------------------------------------------------------- SOKAK
    # asfalt: sig kutu - derin olursa oblik ust yuzu kaldirimi orter
    kt("Asfalt", -240, -70, -61, 240, -22, -53, "#3b4046")
    for i in range(10):
        pl("Ser%d" % i, -224 + i * 48, -57, -200 + i * 48, -55, -71, "#c9c093")
    kt("Kald", -240, -22, -61, 240, 18, -42, "#8f8f84")
    pl("KaldYuz", -240, -48, 240, -42, -22.4, "#6d6d64")
    pl("KaldKen", -240, -42, 240, -40.4, -22.4, "#adada0")
    for i in range(11):
        pl("KldD%d" % i, -224 + i * 46, -42, -223 + i * 46, -38, -22.2, "#7c7c72")
    for i in range(4):
        pl("Izg%d" % i, 128 + i * 5, -50, 130 + i * 5, -43, -22.2, "#4a4a44")

    # --------------------------------------------------------- DUKKAN
    AH1, AH2, AH3, AH4 = "#5a3418", "#7a4a24", "#9a6634", "#3d2210"
    CEP = 16.0                                  # cephe duzlemi
    # --- IC MEKAN (en arkada) ---
    ic = 34.0
    pl("IcArka", -86, -32, 86, 24, ic, "#20130c")
    for i, (z0, z1, c) in enumerate(((-32, -18, "#4a2e18"), (-18, -4, "#3a2313"),
                                     (-4, 10, "#2e1c10"), (10, 24, "#241509"))):
        pl("IcKat%d" % i, -86, z0, 86, z1, ic - 0.2, c)
    pl("Raf", -80, 0, -16, 3, 32, "#6b4122")
    for i in range(8):
        pl("Sise%d" % i, -76 + i * 7, 3, -72 + i * 7, 11, 31.6,
           ("#3f79c0", "#c9302a", "#d8ac35")[i % 3])
    for i, lx in enumerate((-56, -6, 46)):
        pl("Kbl%d" % i, lx - 1, 16, lx + 1, 24, 31.6, "#2b2018")
        pl("Lmb%d" % i, lx - 6, 11, lx + 6, 16, 31.4, "#4a3a28")
        pl("LmbI%d" % i, lx - 5, 11, lx + 5, 13, 31.2, "#ffe6a8")
        plA("LmbH%d" % i, lx - 15, -2, lx + 15, 13, 30.8, "#ffcf7a", 0.22)
        plA("LmbH2%d" % i, lx - 9, -14, lx + 9, 12, 30.7, "#ffb84a", 0.16)

    # --- doner sisi: hacimli, oyunun kendi bantlamasiyla ---
    M_et = mat_nx("Et", ET, "X", band=1.0, band_freq=0.45, band_amt=0.05,
                  noise=0.07)
    kn = koni("Koni", 0, 40, 11, 2.8, M_et, puruz=0.045,
              profil=DONER_PROFIL)
    koy(kn, -52, 26, -22)
    sis = silindir("Sis", 'z', -5, 50, 1.2, F("#9aa3ab"), seg=10)
    koy(sis, -52, 26, -22)
    pl("Ocak", -68, -22, -36, -16, 24, "#3a3a40")
    for i in range(5):
        pl("Kor%d" % i, -66 + i * 6, -21, -62 + i * 6, -18, 23.6,
           ("#ff7a2a", "#ffb04a")[i % 2])
    plA("OcakHare", -76, -26, -28, 22, 23.2, "#ff9a3a", 0.20)
    plA("ZeminIsik", -86, -32, 86, -22, 23.0, "#ffb84a", 0.10)   # zemin sicakligi

    # --- tezgah + baba ---
    kt("Tezgah", -86, 20, -32, 86, 30, -18, "#6b4122")
    pl("TezUst", -86, -19, 86, -17, 19.6, "#a8703f")
    pl("TezCam", -30, -32, 22, -21, 19.4, "#456a7a")     # sogutmali vitrin
    for i in range(6):                                   # icindeki kaplar
        pl("TezK%d" % i, -27 + i * 8, -30, -22 + i * 8, -26, 19.2,
           ("#c9302a", "#3f8a4a", "#d8ac35")[i % 3])
    bx = 4
    pl("BbGovde", bx - 12, -19, bx + 12, 6, 24, "#a8281c")
    pl("BbOnluk", bx - 8, -19, bx + 8, 3, 23.8, "#e4dcc6")
    pl("BbKol", bx + 11, -8, bx + 22, 1, 23.8, "#a8281c")
    pl("BbEl", bx + 20, -10, bx + 26, -4, 23.6, "#e0a978")
    pl("BbBas", bx - 7, 6, bx + 7, 18, 23.8, "#e0a978")
    pl("BbBiyik", bx - 5, 9, bx + 5, 11, 23.6, "#ddd6c8")
    pl("BbGoz1", bx - 4, 12, bx - 2, 14, 23.6, "#2b2018")
    pl("BbGoz2", bx + 2, 12, bx + 4, 14, 23.6, "#2b2018")
    pl("BbFes", bx - 8, 18, bx + 8, 24, 23.6, "#c9302a")
    pl("BbFesA", bx - 9, 17, bx + 9, 18, 23.4, "#7a1a12")

    # --- CAM + CERCEVE: cephe DORT PARCA, ortasi gercek bosluk ---
    plA("Cam", -84, -30, 84, 22, 18.0, "#8fb8cc", 0.07)
    plA("CamGolge", -84, 8, 84, 22, 17.8, "#12283a", 0.30)    # tente golgesi
    # yansimalar: egik ince seritler; sisin ve babanin uzerinden gecmez
    plE("Yns1", -76, -4, 4, 74, -26, 17.6, "#eaf6ff", 0.15)
    plE("Yns2", -69, -4, 2, 74, -26, 17.5, "#eaf6ff", 0.11)
    plE("Yns3", 64, -4, 3, 72, -26, 17.5, "#eaf6ff", 0.13)
    plE("Yns4", 71, -4, 1.5, 72, -26, 17.4, "#eaf6ff", 0.09)
    # cephe parcalari
    pl("CpSol", -98, -38, -84, 34, CEP, AH2)
    pl("CpSolI", -98, -38, -95, 34, CEP - 0.2, AH3)
    pl("CpSag", 84, -38, 98, 34, CEP, AH2)
    pl("CpSagG", 93, -38, 98, 34, CEP - 0.2, AH1)
    pl("CpKiris", -98, 22, 98, 34, CEP, AH2)
    pl("CpKirisI", -98, 32, 98, 34, CEP - 0.2, AH3)
    pl("CpKirisG", -98, 22, 98, 24, CEP - 0.2, AH1)
    pl("CpKaide", -98, -38, 98, -30, CEP, AH4)
    for i in range(25):                                        # fayans kusak
        pl("Fy%d" % i, -96 + i * 8, -37, -90 + i * 8, -31, CEP - 0.2,
           "#2f6b62" if i % 2 == 0 else "#3d8078")
    pl("FyUst", -98, -31, 98, -30, CEP - 0.3, "#8fbdb4")
    # dikme + kapi
    pl("Dikme", 26, -30, 32, 22, CEP - 0.1, AH2)
    pl("DikmeI", 26, -30, 28, 22, CEP - 0.3, AH3)
    pl("KapiCr", 78, -30, 84, 22, CEP - 0.1, AH3)
    pl("KapiKol", 70, -6, 76, -3, CEP - 0.3, "#d8ac35")
    pl("Esik", 32, -40, 84, -38, CEP - 1.0, "#a2a297")

    # --- TENTE: kirmizi-krem seritli, ONE cikik, etek dilimli ---
    for i in range(17):
        x0 = -102 + i * 12
        kt("Tnt%d" % i, x0, 3, 26, x0 + 12, 15, 36,
           "#c0281c" if i % 2 == 0 else "#f2ece0")
    kt("TntAlin", -102, 2.0, 22, 102, 3.6, 28, "#8e2018")
    for i in range(17):                       # etek: bitisik bant + diller
        x0 = -102 + i * 12
        c = "#c0281c" if i % 2 == 0 else "#f2ece0"
        kt("TntE%d" % i, x0, 2.0, 19, x0 + 12, 3.6, 22, c)
        kt("TntD%d" % i, x0 + 3, 2.0, 16, x0 + 9, 3.6, 19, c)
    kt("TntKol1", -100, 4, 26, -97, 15, 34, "#6f7880")
    kt("TntKol2", 97, 4, 26, 100, 15, 34, "#6f7880")

    # --- TABELA: pano + ampuller ---
    kt("Tab", -92, 12, 38, 92, 19, 60, "#7a1a12")
    pl("TabIc", -88, 42, 88, 57, 11.6, "#c0281c")
    pl("TabUst", -92, 58, 92, 60, 11.4, "#e2604f")
    for i in range(9):                                        # "USTA DONER"
        pl("Hrf%d" % i, -66 + i * 16, 45, -56 + i * 16, 54, 11.4, "#ffd75e")
    for i in range(12):
        pl("Amp%d" % i, -88 + i * 16, 37, -84 + i * 16, 41, 11.4,
           "#fff0b0" if i % 2 == 0 else "#8a7a4a")

    # ------------------------------------------- SOKAK ESYASI (on plan)
    # cop kovasi
    kt("Cop", 108, -30, -42, 122, -18, -22, "#4a5058")
    pl("CopKap", 106, -22, 124, -19, -30.4, "#6b737d")
    # kaldirim tabelasi (A tipi)
    kt("Ayak", -128, -34, -42, -108, -26, -20, "#6b4122")
    pl("AyakIc", -126, -40, -110, -22, -34.4, "#e8dcc0")
    pl("AyakY1", -123, -28, -113, -26, -34.6, "#8e2018")
    pl("AyakY2", -123, -33, -116, -31, -34.6, "#8e2018")
    # sokak lambasi: cerceveyi soldan kesen koyu siluet -> derinlik
    kt("Direk", -176, -78, -42, -170, -70, 66, "#2b2620")
    for i in range(9):                       # egik kol
        kt("Kol%d" % i, -170 + i * 4, -78, 66 - i * 0.9, -164 + i * 4, -70,
           68 - i * 0.9, "#2b2620")
    kt("Lamba", -140, -80, 54, -126, -68, 60, "#3a342c")
    pl("LambaI", -138, 55, -128, 58, -80.4, "#ffe6a8")
    pl("DirekA", -176, -42, -170, -38, -78.4, "#1e1a16")

    # --- kuyruk: dukkanin sag yaninda musteriler ---
    for i, (mx, ust, alt, ten) in enumerate((
            (134, "#3f5a72", "#2e3f52", "#e0a978"),
            (160, "#5c4a5e", "#3e3242", "#c9885a"),
            (186, "#4a6b4a", "#33472f", "#f0bd8a"))):
        plA("Ms%dGl" % i, mx - 9, -41, mx + 11, -38, -6.6, "#000000", 0.35)
        pl("Ms%dBc" % i, mx - 7, -38, mx + 7, -22, -6, alt)
        pl("Ms%dB" % i, mx - 7, -22, mx + 7, -6, -6, ust)
        pl("Ms%dY" % i, mx - 5, -6, mx + 5, 2, -6.2, ten)
        pl("Ms%dSac" % i, mx - 6, 1, mx + 6, 5, -6.4, "#2b2018")
    # yaya: solda, durumunu almis gidiyor
    plA("YyGl", -125, -41, -103, -38, -8.6, "#000000", 0.35)
    pl("YyBc", -120, -38, -108, -22, -8, "#4a4030")
    pl("YyB", -121, -22, -107, -6, -8, "#6b5a3a")
    pl("YyY", -119, -6, -109, 2, -8.2, "#e0a978")
    pl("YySac", -120, 1, -108, 5, -8.4, "#3a2a1e")
    pl("YyDrm", -105, -18, -97, -13, -8.4, "#f0d5a8")

    px.shear_scene(K)



# ============================================================== SAHNE 2
def sahne2():
    """BABA PORTRESI. Ocak isigi soldan-alttan; yuz gercek hacimli.

    Burada px.cel + gercek gunes kullaniliyor: duz renkle yuzun hacmini
    elde boyamak yerine lambert bantliyor. cel_nx olsaydi yuze dikey
    seritler binerdi - portrede yanlis.
    """
    px.reset(); _MATS.clear()
    px.setup(W, H)
    px.ortho_cam(0, 14, W, H)
    px.world("#1a0f08", 0.35)
    # ocak yonu: soldan, onden, hafif asagidan
    px.sun(math.pi, rot=(101, 0, -47))

    M_ten = mat_isik("Ten", TEN)
    M_kir = mat_isik("Kirmizi", KIRMIZI)
    M_onl = mat_isik("Onluk", ["#8f8878", "#aba392", "#c9c1ae", "#e4dcc6",
                               "#f6f1e2"])
    M_biy = mat_isik("Biyik", BIYIK)
    M_ekm = mat_isik("Ekmek", ["#8a5f2a", "#a87a41", "#cfa268", "#f0d5a8",
                               "#fdfaf0"])
    M_et = mat_nx("Et2", ET, "X", band=1.0, band_freq=0.45, band_amt=0.05)

    # ------------------------------------------------- ARKA: dukkan icini
    for i, (z0, z1, c) in enumerate(((-70, -30, "#241610"), (-30, 4, "#2e1c12"),
                                     (4, 34, "#382214"), (34, 96, "#432a18"))):
        pl("Fon%d" % i, -230, z0, 230, z1, 150, c)
    # tugla derzleri
    for r in range(11):
        pl("Drz%d" % r, -230, -60 + r * 14, 230, -59 + r * 14, 149.6, "#4e3020")
        for c in range(13):
            ox = 9 if r % 2 else 0
            pl("Drz%d_%d" % (r, c), -222 + c * 36 + ox, -59 + r * 14,
               -221 + c * 36 + ox, -46 + r * 14, 149.6, "#4e3020")
    # asili takimlar: siluet
    for i, (hx, hl_) in enumerate(((-186, 26), (-166, 20), (154, 30), (176, 22))):
        pl("Ask%d" % i, hx - 1, 96 - hl_, hx + 1, 96, 148, "#1c1108")
        pl("AskB%d" % i, hx - 7, 90 - hl_, hx + 7, 96 - hl_, 148, "#2b2018")

    # ------------------------------------------- SOL: DONER UNITESI
    # Brulor eskiden koninin YANINDA duran ayri bir turuncu cubuklu
    # kutuydu; iki nesne birbiriyle ilgisiz goruniyordu. Gercek doner
    # ocaginda brulor etin ARKASINDADIR ve etin iki yanindan tasarak
    # silueti arkadan aydinlatir - sahnenin isik kaynagi da o.
    DX = -136
    pl("Tabla", DX - 38, -58, DX + 38, -48, 124, "#2f2f38")
    pl("TablaU", DX - 38, -50, DX + 38, -48, 123.6, "#6f7880")
    pl("Panel", DX - 32, -48, DX + 32, 44, 122, "#22222a")
    pl("PanelI", DX - 32, -48, DX - 27, 44, 121.8, "#3d3d48")
    pl("PanelG", DX + 27, -48, DX + 32, 44, 121.8, "#14141a")
    for i in range(12):                      # brulor siralari
        bz = -43 + i * 7
        pl("BrA%d" % i, DX - 25, bz, DX + 25, bz + 5, 121.4, "#c0421a")
        pl("BrB%d" % i, DX - 25, bz + 1, DX + 25, bz + 4, 121.2, "#ff7a2a")
        pl("BrC%d" % i, DX - 25, bz + 2, DX + 25, bz + 3, 121.0, "#ffb04a")
        pl("BrD%d" % i, DX - 25, bz + 5, DX + 25, bz + 6, 121.0, "#1c1c24")
    pl("Yatak1", DX - 27, -43, DX - 25, 41, 120.8, "#3d3d48")
    pl("Yatak2", DX + 25, -43, DX + 27, 41, 120.8, "#1c1c24")
    pl("Motor", DX - 16, 44, DX + 16, 54, 121.4, "#2a2a32")
    pl("MotorU", DX - 16, 52, DX + 16, 54, 121.2, "#4d545c")
    kn = koni("Koni2", 0, 70, 20, 5, M_et, puruz=0.045, profil=DONER_PROFIL)
    koy(kn, DX, 118, -40)
    sis2 = silindir("Sis2", 'z', -52, 48, 1.8, F("#c6ced5"), seg=10)
    koy(sis2, DX, 117, 0)
    for r in range(26):                      # kor parlamasi: yumusak hale
        plA("Hale%d" % r, DX - 30 - r * 3, -56 - r * 2, DX + 30 + r * 4,
            42 + r * 2, 116 - r * 0.2, "#ff9a3a", 0.030)

    # ------------------------------------------------- BABA
    BX, BZ = 62, 6                          # yuzun merkezi (ekran)
    # omuzlar + govde
    gov = kure("Govde", M_kir); gov.scale = (56, 26, 46); koy(gov, BX, 60, BZ - 62)
    onl = kure("Onluk", M_onl); onl.scale = (26, 22, 42); koy(onl, BX, 36, BZ - 66)
    # yaka
    yk = kure("Yaka", M_kir); yk.scale = (20, 14, 8); koy(yk, BX, 40, BZ - 30)
    # boyun
    bo = silindir("Boyun", 'z', -20, 4, 11, M_ten, seg=16); koy(bo, BX, 44, BZ - 22)
    # bas: elipsoid
    bas = kure("Bas", M_ten); bas.scale = (25, 24, 29); koy(bas, BX, 40, BZ + 4)
    # cene/elmacik hacmi
    cn = kure("Cene", M_ten); cn.scale = (18, 18, 12); koy(cn, BX, 34, BZ - 12)
    # kulaklar
    for i, sx in ((0, -25), (1, 25)):
        ku = kure("Kulak%d" % i, M_ten); ku.scale = (5, 8, 8)
        koy(ku, BX + sx, 40, BZ + 2)
    # burun
    br = kure("Burun", M_ten); br.scale = (6, 8, 9); koy(br, BX - 1, 18, BZ + 1)
    brk = kure("BurunK", M_ten); brk.scale = (8, 6, 4); koy(brk, BX - 1, 20, BZ - 5)
    # goz cukurlari + gozler
    for i, sx in ((0, -11), (1, 11)):
        ak = kure("Ak%d" % i, mat_isik("Ak%d" % i, ["#cfc7b6", "#e8e2d2",
                                                    "#f8f4ea"]))
        ak.scale = (6, 5, 5); koy(ak, BX + sx, 22, BZ + 12)
        bb = kure("Bbk%d" % i, F("#2b2018")); bb.scale = (2.6, 2.6, 2.6)
        koy(bb, BX + sx + 1, 17, BZ + 11)
        prl = kure("Prl%d" % i, F("#ffffff")); prl.scale = (1.0, 1.0, 1.0)
        koy(prl, BX + sx - 0.5, 15, BZ + 13)
        # kas: kalin, hafif egik
        for j in range(9):
            pl("Kas%d_%d" % (i, j), BX + sx - 8 + j * 2, BZ + 19 + (j - 4) * (0.6 if i else -0.6),
               BX + sx - 6 + j * 2, BZ + 22 + (j - 4) * (0.6 if i else -0.6),
               16, "#cfc7b6")
    # fes + puskul
    fes = silindir("Fes", 'z', 0, 22, 21, M_kir, seg=20, r1=22)
    koy(fes, BX, 40, BZ + 24)
    pl("FesKen", BX - 23, BZ + 22, BX + 23, BZ + 25, 17, "#7a1a12")
    pl("Pusk", BX + 20, BZ + 30, BX + 22, BZ + 46, 16, "#2b2018")
    pl("PuskU", BX + 17, BZ + 28, BX + 25, BZ + 32, 16, "#2b2018")
    # pala biyik: ortada kalin, uclari yukari
    for j in range(29):
        u = abs(j - 14) / 14.0
        lift = u * u * 6
        th = max(2.0, 6 - u * 3.5)
        pl("Byk%d" % j, BX - 15 + j, BZ - 9 + lift, BX - 14 + j,
           BZ - 9 + lift + th, 16, "#ddd6c8")
        pl("BykU%d" % j, BX - 15 + j, BZ - 9 + lift + th - 1, BX - 14 + j,
           BZ - 9 + lift + th, 15.8, "#f4f0e6")
    # gulumseme
    for j in range(13):
        u = abs(j - 6) / 6.0
        pl("Agz%d" % j, BX - 6 + j, BZ - 17 + u * u * 2, BX - 5 + j,
           BZ - 16 + u * u * 2, 16, "#8a4a2e")

    # ------------------------------------------------- ELDEKI DURUM
    # POZ NOTU: onceki kurguda durum ONE uzatiliyordu, yani kol
    # kameraya dogru KISALIYORDU (foreshortening). Bu olcekte
    # (el ~30 piksel) hicbir sekilde okunmadi - uc deneme de basarisiz.
    # Yeni kurgu: durum DIKEY, on kol asagidan yukari geliyor.
    #   1) kisalma yok, on kol yandan ve gercek uzunlukta
    #   2) dikey tupu kavrayan yumrukta parmaklar onden YATAY bantlar
    #      olarak gorunur - modellemesi de okunmasi da cok daha kolay
    DX, ZA, ZB = -31, -42, 15                # durumun ekseni ve uclari
    dr = silindir("Durum", 'z', ZA, ZB, 10, M_ekm, seg=20)
    koy(dr, DX, 20, 0)
    M_kag2 = mat_isik("KagD", ["#b0a894", "#cfc7b2", "#e4dcc6", "#fdfaf0",
                               "#ffffff"])
    kg = silindir("Kagit", 'z', ZA - 1, -10, 11, M_kag2, seg=20)
    koy(kg, DX, 19.6, 0)
    pl("KagAgiz", DX - 11, -12, DX + 11, -10, 18.8, "#9e9888")
    pl("KagSerit1", DX - 9, -19, DX + 9, -17, 18.8, "#d8352c")
    pl("KagSerit2", DX - 9, -24, DX + 9, -22, 18.8, "#2f5f9e")
    # ustteki acik uc: gercek kesit
    for i, (rx, rz, c) in enumerate(((9, 4, "#e8c07a"), (7, 3, "#8a4a1a"))):
        uc = kure("Uc%d" % i, F(c)); uc.scale = (rx, 7, rz)
        koy(uc, DX, 16 - i, ZB - 3)
    for i, (ux, uz, rr, c) in enumerate(((-3, -4, 3.0, "#d18c42"),
                                         (3, -4, 2.4, "#3f8a4a"),
                                         (0, -6, 1.8, "#c9302a"))):
        h = kure("Har%d" % i, F(c)); h.scale = (rr, 3, rr)
        koy(h, DX + ux, 14, ZB + uz)

    # --- YUMRUK: avuc parmaklarin ARKASINDA, parmaklar YATAY ---
    YA, YU = -40, -13                        # yumrugun alt/ust siniri
    yum = kure("Avuc", M_ten); yum.scale = (16, 12, 12.5)
    koy(yum, DX, 15, (YA + YU) / 2.0 + 1)
    for i in range(4):                       # dort yatay parmak
        fz = YU - 3 - i * 6
        kis = 2 if i == 3 else 0
        pr = silindir("Prm%d" % i, 'x', DX - 15 + kis, DX + 13 - kis, 3.4,
                      M_ten, seg=12)
        koy(pr, 0, 11, fz)
    bp = silindir("Basp", 'z', YA + 4, YA + 22, 3.8, M_ten, seg=12)
    koy(bp, DX + 11, 9, 0)                   # basparmak: sag yanda dikey

    # --- ON KOL: dirsekten bilege, asagidan yukari ---
    kol = kutu("Kol", -23, 24, -11, 23, 36, 11, M_kir)
    kol.rotation_euler = (0, math.radians(-25), 0)
    kol.location = (5, 30, -49 - 30 * K)
    mn = kutu("Manset", -10, 22, -11, 10, 34, 11,
              mat_isik("Mns2", ["#8f8878", "#aba392", "#c9c1ae", "#e4dcc6",
                                "#f6f1e2"]))
    mn.rotation_euler = (0, math.radians(-25), 0)
    mn.location = (-17, 28, -39 - 28 * K)

    # ------------------------------------------------- ATMOSFER
    plA("SicakOrt", -230, -70, 230, 96, 8, "#ff8a3a", 0.07)
    plA("Vinyet1", -230, -70, -150, 96, 6, "#000000", 0.30)
    plA("Vinyet2", 150, -70, 230, 96, 6, "#000000", 0.30)
    plA("VinyetU", -230, 70, 230, 96, 5.8, "#000000", 0.22)
    plA("VinyetA", -230, -70, 230, -52, 5.8, "#000000", 0.22)

    px.shear_scene(K)


# ============================================================== SAHNE 3
def sahne3():
    """KIS GECESI. Kepenk kapali, uc aydir acilmamis.

    Kadraj sahne 1'den DAHA YAKIN: ayni dukkan ama artik sokak degil,
    kapali kepenk anlatiyor. Sicak/soguk karsitligi hikayenin donum
    noktasi - sahne 1 sari, burasi mavi.
    """
    px.reset(); _MATS.clear()
    px.setup(W, H)
    px.ortho_cam(0, 14, W, H)
    px.world("#000000", 0.0)

    # ------------------------------------------------------- gece gogu
    gok = [(64, 96, "#121824"), (44, 64, "#18202f"), (26, 44, "#1f293b"),
           (10, 26, "#273348"), (-62, 10, "#2f3d55")]
    for i, (z0, z1, c) in enumerate(gok):
        pl("Gok%d" % i, -230, z0, 230, z1, 132, c)
    for i, (bx, bz, bw, bh) in enumerate(((-140, 70, 60, 9), (30, 82, 74, 8),
                                          (170, 64, 44, 7))):
        pl("Bul%d" % i, bx - bw, bz, bx + bw, bz + bh, 128, "#38455e")
        pl("BulA%d" % i, bx - bw + 5, bz, bx + bw - 9, bz + bh - 3, 127.6, "#2b3448")
    # uzak siluetler: sadece koyu kutle + birkac yanan pencere
    for i, (x0, x1, h) in enumerate(((-238, -170, 40), (-176, -120, 62),
                                     (126, 190, 54), (184, 238, 38))):
        pl("Uz%d" % i, x0, -36, x1, h, 96, "#1b2432")
        for r in range(int((h + 30) // 16)):
            for c in range(max(1, int((x1 - x0) // 18))):
                yanik = (r * 3 + c * 5 + i) % 7 == 0
                pl("UzP%d_%d_%d" % (i, r, c), x0 + 7 + c * 18, -26 + r * 16,
                   x0 + 14 + c * 18, -17 + r * 16, 95.6,
                   "#d8a850" if yanik else "#232d3d")
    # komsu binalar
    for i, (x0, x1) in enumerate(((-238, -142), (142, 238))):
        pl("Ym%d" % i, x0, -36, x1, 54, 60, "#2a3040")
        pl("YmKr%d" % i, x0, 54, x1, 59, 59.6, "#3a4254")
        for c in range(3):
            for r in range(3):
                yanik = (c + r * 2 + i) % 5 == 0
                pl("YmP%d_%d_%d" % (i, c, r), x0 + 14 + c * 28, -22 + r * 22,
                   x0 + 26 + c * 28, -8 + r * 22, 59.4,
                   "#e0b060" if yanik else "#1c2430")
        pl("YmKar%d" % i, x0, 54, x1, 57, 59.2, "#c8d4e0")     # cati kari

    # --------------------------------------------------------- sokak
    kt("Asfalt", -240, -70, -61, 240, -22, -50, "#191d25")
    kt("Kald", -240, -22, -61, 240, 18, -42, "#2a3038")
    pl("KaldYuz", -240, -48, 240, -42, -22.4, "#20262e")
    # kar: kaldirimda ve yolun kenarinda birikmis
    pl("Kar1", -240, -42, 240, -38, -22.3, "#c8d4e0")
    pl("Kar2", -240, -38, 240, -36, -22.2, "#9fb0c2")
    for i in range(14):
        pl("KarY%d" % i, -230 + i * 34, -52, -206 + i * 34, -50, -70.4, "#8fa2b6")

    # --------------------------------------------------------- DUKKAN
    CEP = 16.0
    pl("Cephe", -150, -38, 150, 40, CEP + 2, "#33251a")
    pl("CepheG", 140, -38, 150, 40, CEP + 1.8, "#241a12")
    pl("Kaide", -150, -38, 150, -30, CEP + 1.6, "#241a12")
    for i in range(38):
        pl("Fy%d" % i, -148 + i * 8, -37, -142 + i * 8, -31, CEP + 1.4,
           "#22453f" if i % 2 == 0 else "#2b544e")

    # --- KEPENK: yatay oluklar, uc tonlu; ustte rulo kutusu ---
    ust, alt = 24, -30
    for r in range((ust - alt) // 3):
        z = alt + r * 3
        pl("KpA%d" % r, -136, z, 136, z + 1, CEP, "#2a3138")
        pl("KpB%d" % r, -136, z + 1, 136, z + 2, CEP, "#4b555f")
        pl("KpC%d" % r, -136, z + 2, 136, z + 3, CEP, "#39424a")
    for v in range(-132, 136, 26):                    # dikey ekler
        pl("KpE%d" % (v + 200), v, alt, v + 2, ust, CEP - 0.2, "#232a30")
    for i, (rx, rz, rw, rh) in enumerate(((-96, -12, 14, 8), (34, 6, 10, 6),
                                          (88, -22, 18, 5), (-40, 14, 9, 7))):
        pl("Pas%d" % i, rx, rz, rx + rw, rz + rh, CEP - 0.3, "#6b4526")
        pl("Pas2%d" % i, rx + 2, rz + 1, rx + rw - 3, rz + rh - 2, CEP - 0.4,
           "#8a5a30")
    pl("KpRulo", -140, 24, 140, 34, CEP - 0.4, "#3d464f")
    pl("KpRuloI", -140, 32, 140, 34, CEP - 0.6, "#5d6772")
    pl("KpAlt", -136, -32, 136, -30, CEP - 0.4, "#5d6772")

    # --- asma kilit + kol ---
    M_cel = mat_isik("Celik", CELIK, stops=[0.0, .12, .26, .44, .64])
    px.sun(math.pi, rot=(52, 0, -40))
    pl("HaspA", -14, -30, -6, -14, CEP - 0.6, "#5d6772")       # kulaklar
    pl("HaspB", 6, -30, 14, -14, CEP - 0.6, "#5d6772")
    pl("HaspAG", -14, -30, -12, -14, CEP - 0.7, "#2f363c")
    pl("HaspBG", 12, -30, 14, -14, CEP - 0.7, "#2f363c")
    halka("KlB", 0, -14, 8, 2.4, M_cel, y=CEP - 3, n=14)       # kilit boynu
    kl = kure("Kilit", M_cel); kl.scale = (12, 7, 10); koy(kl, 0, CEP - 4, -24)
    pl("KlDelik", -2, -28, 2, -24, CEP - 5, "#12161a")
    pl("KlDelik2", -1, -31, 1, -27, CEP - 5, "#12161a")
    plA("KlGolge", -14, -36, 16, -30, CEP - 5.2, "#000000", 0.45)

    # --- kepenge yapistirilmis ilan (kucuk, kose kalkik) ---
    kagit("Ilan", -84, -8, -58, 16, CEP - 1.0, mat_isik("Kag", ["#6b6558",
          "#8a8474", "#b0a894", "#cfc7b2", "#e8e2d0"],
          stops=[0.0, .10, .22, .36, .52]), kivrim=1.0)
    pl("IlanB", -80, 10, -62, 13, CEP - 2.0, "#8a2018")
    for i in range(4):
        pl("IlanS%d" % i, -80, 4 - i * 4, -66 + (i % 2) * 4, 5 - i * 4,
           CEP - 2.0, "#6b6558")
    pl("Bant1", -87, 13, -79, 17, CEP - 2.2, "#d8d2c0")
    pl("Bant2", -63, 13, -55, 17, CEP - 2.2, "#d8d2c0")

    # --- sonmus tabela ---
    pl("Tab", -140, 36, 140, 62, CEP + 1.2, "#3a1410")
    pl("TabIc", -136, 39, 136, 59, CEP + 1.0, "#521a14")
    for i in range(9):
        pl("Hrf%d" % i, -92 + i * 22, 44, -78 + i * 22, 55, CEP + 0.8, "#7a5040")
    for i in range(12):
        kirik = i in (2, 5, 9)
        pl("Amp%d" % i, -132 + i * 23, 36, -127 + i * 23, 40, CEP + 0.8,
           "#2b2620" if kirik else "#4a4438")
    pl("TabKar", -140, 62, 140, 65, CEP + 0.8, "#c8d4e0")      # tabelada kar

    # --- sarkik, yirtik tente ---
    for i in range(13):
        x0 = -80 + i * 12
        sark = 0 if i in (5, 6, 7) else 1
        kt("Tnt%d" % i, x0, 6, 28 - (0 if sark else 8), x0 + 12, 15,
           34 - (0 if sark else 6),
           "#6b1a14" if i % 2 == 0 else "#8a8478")
    pl("TntKar", -80, 33, 76, 36, 5.6, "#c8d4e0")

    # --------------------------------------------- anma: karanfil + mum
    pl("Vazo", -168, -38, -156, -26, 8, "#3a3f48")
    for i, (fx, fz) in enumerate(((-167, -14), (-161, -8), (-155, -16))):
        pl("Sap%d" % i, fx, -26, fx + 2, fz, 7.8, "#2f4a2a")
        pl("Yap%d" % i, fx - 4, fz - 8, fx + 1, fz - 6, 7.8, "#2f4a2a")
        pl("Gul%d" % i, fx - 5, fz, fx + 7, fz + 8, 7.6, "#8e2018")
        pl("GulI%d" % i, fx - 3, fz + 2, fx + 5, fz + 7, 7.4, "#c33c2c")
        pl("GulU%d" % i, fx - 2, fz + 5, fx + 3, fz + 7, 7.2, "#e2604f")
    pl("Mum", -146, -38, -140, -26, 8, "#d8d2c0")
    pl("MumG", -141, -38, -140, -26, 7.9, "#9e9888")
    pl("MumAlev", -144, -26, -142, -22, 7.6, "#ffd75e")
    px_ = -143
    for r in range(7):                      # hale: kucuk ve mumun etrafinda
        plA("MumH%d" % r, px_ - 4 - r * 2, -30 - r * 1.5, px_ + 4 + r * 2,
            -20 + r * 2, 7.4 - r * 0.05, "#ffb04a", 0.055)

    # --------------------------------------------- on plan: lamba + kar
    kt("Direk", -206, -78, -42, -200, -70, 66, "#12161c")
    for i in range(9):
        kt("Kol%d" % i, -200 + i * 4, -78, 66 - i * 0.9, -194 + i * 4, -70,
           68 - i * 0.9, "#12161c")
    kt("Lamba", -170, -80, 54, -156, -68, 60, "#1a1f26")
    pl("LambaI", -168, 55, -158, 58, -80.4, "#ffe6a8")
    for r in range(16):                       # lambanin isik konisi
        plA("Koni%d" % r, -178 - r * 2.6, 52 - r * 6, -148 + r * 2.6, 56 - r * 6,
            -80.6, "#cfe0ff", 0.030)
    # kar taneleri
    kar = [(-214, 78), (-188, 44), (-160, 88), (-132, 20), (-104, 66),
           (-76, 34), (-48, 82), (-20, 52), (8, 90), (36, 28), (64, 70),
           (92, 46), (120, 86), (148, 32), (176, 62), (204, 78), (-198, 8),
           (-118, -6), (-58, 6), (18, -12), (86, 2), (154, -8), (210, 14),
           (-166, 58), (-92, 96), (-6, 68), (110, 12), (188, 40)]
    for i, (kx, kz) in enumerate(kar):
        b = 2 if i % 3 else 3
        plA("Kr%d" % i, kx, kz, kx + b, kz + b, -90, "#eaf2ff", 0.85)

    px.shear_scene(K)


# ============================================================== SAHNE 4
def sahne4():
    """BORC KAGIDI. Tek ampul, masa, kagit - ve babanin gozlugu.

    En yakin kadraj. Tek isik kaynagi var (tepedeki ampul), o yuzden
    burada px.cel + gercek gunes dogru arac: kagidin kivrimi, cam
    bardagin yuvarlagi, elin hacmi tonlamadan cikiyor.

    Dikkat: kagidin kivrimi icerigini yutmasin diye kivrim 1.2'de
    tutuluyor ve tum yazi/muhur y=6.0'da, kagidin en one gelen
    noktasindan (8-1.2=6.8) daha ONDE.
    """
    px.reset(); _MATS.clear()
    px.setup(W, H)
    px.ortho_cam(0, 14, W, H)
    px.world("#1a1008", 0.30)
    px.sun(math.pi, rot=(28, 0, -12))            # ustten, hafif soldan

    DUZ = [0.0, .10, .22, .36, .52]              # on yuz en parlak tonu alsin
    M_kag = mat_isik("Kag", ["#8a8474", "#a8a090", "#cfc7b2", "#e8e2d0",
                             "#f8f4e8"], stops=DUZ)
    M_cam = mat_isik("CamM", ["#43525c", "#5f727e", "#8098a6", "#b0c6d2",
                              "#e0eef6"], stops=DUZ)
    M_cay = mat_isik("Cay", ["#5a2a08", "#8a4410", "#c06a18", "#e08a28",
                             "#ffb04a"], stops=DUZ)
    M_ten = mat_isik("Ten", TEN, stops=DUZ)
    M_pir = mat_isik("Pirinc", PIRINC, stops=DUZ)

    # ------------------------------------------------------- karanlik oda
    for i, (z0, z1, c) in enumerate(((-62, -10, "#170f0a"), (-10, 34, "#20160e"),
                                     (34, 66, "#1a1109"), (66, 96, "#120c07"))):
        pl("Fon%d" % i, -230, z0, 230, z1, 170, c)
    for i in range(15):                          # duvar tahtalari
        pl("Duv%d" % i, -220 + i * 30, -10, -218 + i * 30, 96, 169.6, "#2a1c12")

    # ------------------------------------------------------- ampul + hale
    pl("Kablo", -2, 84, 2, 96, 150, "#1a1208")
    pl("Duy", -5, 78, 5, 84, 150, "#3a2f20")
    amp = kure("Ampul", F("#ffe9a8")); amp.scale = (8, 6, 10); koy(amp, 0, 150, 72)
    amp2 = kure("Ampul2", F("#fff8d8")); amp2.scale = (4, 3, 5); koy(amp2, -2, 149, 73)
    for r in range(30):                          # isik konisi duvara vuruyor
        plA("Kon%d" % r, -12 - r * 6.0, 68 - r * 4.4, 12 + r * 6.0, 72 - r * 4.4,
            160 - r * 0.2, "#ffcf7a", 0.038)

    # ------------------------------------------------------- masa
    kt("Masa", -240, -46, -61, 240, 30, -14, "#3d2a1c")
    pl("MasaKen", -240, -16, 240, -13, -46.4, "#7a5638")
    for i in range(22):                          # ahsap damari
        pl("Dmr%d" % i, -236 + i * 22, -61, -234 + i * 22, -16, -46.2, "#33241a")
    plA("MasaIsik", -120, -16, 120, -12, -46.6, "#ffcf7a", 0.16)

    # ------------------------------------------------------- KAGIT
    plA("KagGolge", -70, -22, 82, 58, 9.2, "#000000", 0.40)     # dusen golge
    kagit("Kagit", -76, -18, 70, 60, 8, M_kag, kivrim=1.2, seg=18, egim=-3)
    Y = 6.0
    # antet
    pl("Arma", -66, 42, -50, 56, Y, "#8a8474")
    pl("ArmaI", -63, 45, -53, 53, Y - 0.2, "#cfc7b2")
    for i in range(11):                          # "ICRA VE IFLAS MUDURLUGU"
        pl("Ant%d" % i, -42 + i * 8, 48, -37 + i * 8, 55, Y, "#4a4438")
    for i in range(7):
        pl("Ant2%d" % i, -42 + i * 8, 40, -37 + i * 8, 45, Y, "#6b6558")
    pl("Cizgi", -66, 34, 60, 36, Y, "#8a8474")
    # govde satirlari
    for i in range(4):
        pl("Str%d" % i, -66, 24 - i * 7, 58 - (30 if i == 3 else 0), 26 - i * 7,
           Y, "#8a8474")
    # tutar kutusu
    pl("TutCr", -54, -10, 50, 12, Y, "#a8a090")
    pl("TutIc", -52, -8, 48, 10, Y - 0.2, "#f2eede")
    for i in range(7):                           # "TOPLAM BORC"
        pl("TB%d" % i, -46 + i * 7, 4, -42 + i * 7, 9, Y - 0.4, "#7a3428")
    for i, w in enumerate((7, 3, 7, 7, 7, 3, 7, 7, 7)):   # $5.000.000
        pl("Rk%d" % i, -44 + i * 11, -6, -44 + i * 11 + w, 2, Y - 0.4, "#a8201a")
    # imza
    for i in range(9):
        pl("Imz%d" % i, 20 + i * 4, -14 + (i % 3) * 2, 24 + i * 4,
           -12 + (i % 3) * 2, Y, "#3a3a4a")
    # kirmizi muhur: iki halka + capraz yazi
    halka("Mhr1", 44, 22, 16, 2.2, F("#a8201a"), y=Y - 0.6, n=24)
    halka("Mhr2", 44, 22, 11, 1.5, F("#a8201a"), y=Y - 0.6, n=18)
    for i in range(9):                           # "ODENMEDI"
        pl("MhrY%d" % i, 34 + i * 2.6, 20 + (i - 4) * 0.5, 36 + i * 2.6,
           25 + (i - 4) * 0.5, Y - 0.8, "#a8201a")
    plA("MhrLeke", 52, 6, 64, 12, Y - 0.9, "#a8201a", 0.35)

    # ------------------------------------------------- babanin gozlugu
    halka("GzS", -158, -2, 11, 2.3, M_pir, y=-20, n=20)
    halka("GzG", -128, -2, 11, 2.3, M_pir, y=-20, n=20)
    pl("GzKopru", -147, -3, -139, 0, -20.4, "#a8811f")
    pl("GzSap", -174, -2, -156, 1, -20.4, "#a8811f")
    plA("GzCam1", -167, -11, -149, 7, -19.6, "#b0c6d2", 0.22)
    plA("GzCam2", -137, -11, -119, 7, -19.6, "#b0c6d2", 0.22)
    plA("GzGolge", -172, -15, -114, -11, -19.0, "#000000", 0.40)

    # ------------------------------------------------- cay bardagi
    koni("CayA", -10, 8, 10, 6.4, M_cam, seg=20).location = (146, -20, 2.0)
    koni("CayU", 8, 28, 6.4, 11, M_cam, seg=20).location = (146, -20, 2.0)
    koni("CayI", -7, 6, 8.2, 5, M_cay, seg=20).location = (146, -20.4, 2.04)
    koni("CayI2", 6, 21, 5, 8.6, M_cay, seg=20).location = (146, -20.4, 2.04)
    tb = kure("Tabak", M_cam); tb.scale = (20, 14, 2.6); koy(tb, 146, -18, -10)
    pl("Kasik", 160, 0, 164, 28, -21, "#98a2ab")
    pl("KasikU", 158, 26, 166, 32, -21, "#c6ced5")
    for i, (sx, sz) in enumerate(((176, -8), (184, -6))):
        pl("Sek%d" % i, sx, sz, sx + 7, sz + 6, -21, "#f4f0e6")
    plA("CayGolge", 122, -14, 186, -9, -18.0, "#000000", 0.42)

    # ------------------------------------- eller: kagidin alt kosesini tutuyor
    # On kollar yatay kahverengi sosisler gibi uzaniyordu. Masanin
    # KARSI tarafinda oturan biri kagidi tutarken on kollari kameraya
    # dogru KISALIR; gorunen sey el, bilek ve masanin on kenarinin
    # (z=-14) arkasinda kaybolan kisa bir manset.
    BOY = (13, 20, 22, 19)                       # serce -> isaret
    M_mns = mat_isik("Mns", ["#8f8878", "#aba392", "#c9c1ae", "#e4dcc6",
                             "#f6f1e2"], stops=DUZ)
    for i, (ex, yon) in enumerate(((-84, -1), (78, 1))):
        el = kure("El%d" % i, M_ten); el.scale = (12, 11, 10)
        koy(el, ex + yon * 2, 2, -2)
        for j in range(4):                       # parmaklar: boylari farkli
            uz = BOY[j]
            a, b = ex - yon * 4, ex - yon * uz
            kutu("Pr%d_%d" % (i, j), min(a, b), 0, -10 + j * 4.8,
                 max(a, b), 10, -6 + j * 4.8, M_ten)
            bg = kure("Bg%d_%d" % (i, j), M_ten); bg.scale = (3, 5, 2.4)
            koy(bg, ex - yon * 2, 0, -8 + j * 4.8)
        bp = kure("Bp%d" % i, M_ten); bp.scale = (7, 6, 4)
        koy(bp, ex + yon * 9, 1, -11)
        kutu("Mn%d" % i, ex + yon * 7 - 9, 4, -14, ex + yon * 7 + 9, 14, -5,
             M_mns)

    # ------------------------------------------------- vinyet
    plA("Vin1", -230, -62, -170, 96, -60, "#000000", 0.44)
    plA("Vin2", 170, -62, 230, 96, -60, "#000000", 0.44)
    plA("Vin3", -230, 74, 230, 96, -60.2, "#000000", 0.30)
    # ampulun isigi asagi dogru soner: alt bant duz ahsap levha degil,
    # isigin bittigi yer olsun.
    for r in range(12):
        plA("Dip%d" % r, -230, -61 + r * 3, 230, -58 + r * 3, -60.4 - r * 0.05,
            "#000000", 0.30 - r * 0.024)

    px.shear_scene(K)



# ============================================================== SAHNE 5
def sahne5():
    """SAFAK. Kepenk yarim acik, icerisi sicak; elde anahtar.

    Sahne 3'un aynasi: ayni kadraj, ayni kepenk - ama isik icerideki
    ocaktan disari vuruyor. Anahtar 3B: pirinc rampasi + gercek gunes,
    yuvarlak sapin hacmi bundan cikiyor.
    """
    px.reset(); _MATS.clear()
    px.setup(W, H)
    px.ortho_cam(0, 14, W, H)
    px.world("#1a1208", 0.25)
    px.sun(math.pi, rot=(58, 0, -52))            # safak: sol ustten

    M_pir = mat_isik("Pirinc", PIRINC)
    M_ten = mat_isik("Ten", TEN)
    M_kir = mat_isik("Kirmizi", KIRMIZI)

    # ------------------------------------------------------- safak gogu
    gok = [(72, 96, "#22305c"), (58, 72, "#33406c"), (46, 58, "#4d5478"),
           (36, 46, "#6f6180"), (26, 36, "#9a6f72"), (16, 26, "#c58a5c"),
           (6, 16, "#e0a758"), (-62, 6, "#f2c877")]
    for i, (z0, z1, c) in enumerate(gok):
        pl("Gok%d" % i, -230, z0, 230, z1, 132, c)
    for i, (r, c) in enumerate(((30, "#f6d68a"), (21, "#fde8b0"), (13, "#fff6d8"))):
        sn = kure("Gun%d" % i, F(c)); sn.scale = (r, .4, r)
        koy(sn, 176, 130, 20)
    # kuslar
    for i, (bx, bz) in enumerate(((-150, 74), (-128, 66), (-104, 78),
                                  (96, 70), (124, 82))):
        pl("Ku%dA" % i, bx - 4, bz, bx - 1, bz + 2, 126, "#3a4a56")
        pl("Ku%dB" % i, bx + 1, bz, bx + 4, bz + 2, 126, "#3a4a56")
        pl("Ku%dC" % i, bx - 1, bz - 1, bx + 1, bz, 126, "#3a4a56")

    for i, (x0, x1, h) in enumerate(((-238, -172, 44), (-178, -126, 60),
                                     (128, 192, 52), (186, 238, 40))):
        pl("Uz%d" % i, x0, -36, x1, h, 96, "#4a4258")
        pl("UzT%d" % i, x0 - 2, h, x1 + 2, h + 3, 95.6, "#5e5468")
    for i, (x0, x1) in enumerate(((-238, -144), (144, 238))):
        pl("Ym%d" % i, x0, -36, x1, 54, 60, "#5a4c4a")
        pl("YmKr%d" % i, x0, 54, x1, 59, 59.6, "#7a6656")
        pl("YmIs%d" % i, x0, -36, x0 + 4, 54, 59.4, "#7a6656")
        for c in range(3):
            for r in range(3):
                pl("YmP%d_%d_%d" % (i, c, r), x0 + 14 + c * 28, -22 + r * 22,
                   x0 + 26 + c * 28, -8 + r * 22, 59.4, "#3a3442")

    # --------------------------------------------------------- sokak
    kt("Asfalt", -240, -70, -61, 240, -22, -50, "#3a3038")
    kt("Kald", -240, -22, -61, 240, 18, -42, "#8a8078")
    pl("KaldYuz", -240, -48, 240, -42, -22.4, "#6a6058")
    pl("KaldKen", -240, -42, 240, -40.4, -22.4, "#a8a096")
    for i in range(11):
        pl("KldD%d" % i, -224 + i * 46, -42, -223 + i * 46, -38, -22.2, "#7a7268")

    # --------------------------------------------------------- DUKKAN
    CEP = 16.0
    # Cephe PARCALI: kepenk agzi gercek bosluk olmali, yoksa icerideki
    # sicaklik gorunmez (sahne 1'de ayni hatayi yapmistim).
    pl("CepSol", -150, -38, -136, 40, CEP + 2, "#4a3524")
    pl("CepSag", 136, -38, 150, 40, CEP + 2, "#4a3524")
    pl("CepSagG", 144, -38, 150, 40, CEP + 1.8, "#33251a")
    pl("CepUst", -150, 34, 150, 40, CEP + 2, "#4a3524")
    pl("Kaide", -150, -38, -136, -30, CEP + 1.6, "#33251a")
    pl("Kaide2", 136, -38, 150, -30, CEP + 1.6, "#33251a")
    for i in range(4):
        pl("Fy%d" % i, -148 + i * 8, -37, -142 + i * 8, -31, CEP + 1.4,
           "#2f6b62" if i % 2 == 0 else "#3d8078")
        pl("Fz%d" % i, 138 + i * 8, -37, 144 + i * 8, -31, CEP + 1.4,
           "#2f6b62" if i % 2 == 0 else "#3d8078")

    # --- IC: kepenk agzindan gorunen sicaklik ---
    ic = 30.0
    pl("IcArka", -136, -30, 136, 2, ic, "#3a2312")
    for i, (z0, z1, c) in enumerate(((-30, -24, "#a8631f"), (-24, -18, "#8a4a1a"),
                                     (-18, -10, "#6b3714"), (-10, -4, "#4e2810"),
                                     (-4, 2, "#3a1d0c"))):
        pl("IcKat%d" % i, -136, z0, 136, z1, ic - 0.2, c)
    pl("IcRaf", -128, -8, -92, -5, 29.6, "#6b4122")     # arka raf
    for i in range(5):
        pl("IcSis%d" % i, -126 + i * 7, -5, -122 + i * 7, 1, 29.4,
           ("#3f79c0", "#c9302a", "#d8ac35")[i % 3])
    pl("IcAsk", 30, -6, 108, -3, 29.6, "#6b4122")       # asili sis dizisi
    for i in range(5):
        pl("IcSap%d" % i, 38 + i * 15, -12, 40 + i * 15, -6, 29.4, "#8a929a")
        pl("IcSis%d" % i, 36 + i * 15, -18, 42 + i * 15, -12, 29.4, "#a5622a")
        pl("IcSisU%d" % i, 37 + i * 15, -17, 40 + i * 15, -14, 29.2, "#d18c42")
    M_et = mat_nx("Et", ET, "X", band=1.0, band_freq=0.45, band_amt=0.05)
    kn = koni("Koni", 0, 30, 9, 2.4, M_et, puruz=0.045,
              profil=DONER_PROFIL)
    koy(kn, -74, 26, -26)
    silindir("Sis", 'z', -4, 36, 1.1, F("#9aa3ab"), seg=10).location = (
        -74, 26, -30 - 26 * K)
    for i in range(5):
        pl("Kor%d" % i, -88 + i * 6, -26, -84 + i * 6, -23, 25.6,
           ("#ff7a2a", "#ffb04a")[i % 2])
    kt("Tezgah", -136, 22, -30, 136, 28, -18, "#6b4122")
    pl("TezUst", -136, -19, 136, -17, 21.6, "#a8703f")
    for i in range(9):
        plA("IcHale%d" % i, -136, -30 + i * 4, 136, -26 + i * 4, 20,
            "#ffb04a", 0.16 - i * 0.014)
    # kepenk agzindan tasip cepheye vuran isik
    plA("AgizIsik", -140, -2, 140, 4, 14, "#ffd08a", 0.30)

    # --- KEPENK: yarim acik, ustte rulo ---
    ust, alt = 24, 2                              # sadece ust yari kapali
    for r in range((ust - alt) // 3):
        z = alt + r * 3
        pl("KpA%d" % r, -136, z, 136, z + 1, CEP, "#3a4148")
        pl("KpB%d" % r, -136, z + 1, 136, z + 2, CEP, "#5d6772")
        pl("KpC%d" % r, -136, z + 2, 136, z + 3, CEP, "#48515a")
    for v in range(-132, 136, 26):
        pl("KpE%d" % (v + 200), v, alt, v + 2, ust, CEP - 0.2, "#2f363c")
    pl("KpAlt", -136, -1, 136, 2, CEP - 0.4, "#98a2ab")        # alt lamasi
    pl("KpAltG", -136, -3, 136, -1, CEP - 0.4, "#2a3138")
    pl("KpRulo", -140, 24, 140, 34, CEP - 0.4, "#3d464f")
    pl("KpRuloI", -140, 32, 140, 34, CEP - 0.6, "#5d6772")
    # kepenk yanlari (kilavuz raylari)
    pl("RaySol", -142, -30, -136, 34, CEP - 0.6, "#4a5058")
    pl("RaySag", 136, -30, 142, 34, CEP - 0.6, "#4a5058")

    # --- isik kaldirima vuruyor ---
    for r in range(18):
        plA("Yer%d" % r, -136 - r * 3, -33 - r * 0.6, 136 + r * 3, -31 - r * 0.6,
            -21 - r * 0.2, "#ffcf7a", 0.055)

    # --- tabela: sabah isiginda, henuz yanmiyor ---
    pl("Tab", -140, 36, 140, 62, CEP + 1.2, "#7a1a12")
    pl("TabIc", -136, 39, 136, 59, CEP + 1.0, "#a8281c")
    for i in range(9):
        pl("Hrf%d" % i, -92 + i * 22, 44, -78 + i * 22, 55, CEP + 0.8, "#e8c070")
    for i in range(12):
        pl("Amp%d" % i, -132 + i * 23, 36, -127 + i * 23, 40, CEP + 0.8,
           "#8a7a4a")

    # ------------------------------------------------- KOL, EL, ANAHTAR
    # Onceki hali dev bir kirmizi elipsti. Artik: kol kutusu + manset +
    # avuc + dort parmak + basparmak; anahtar avucun icinden cikiyor.
    kt("Kol", 150, -54, -34, 240, -42, -8, "#8e2018")
    kt("KolIs", 150, -55, -12, 240, -54.6, -8, "#c33c2c")
    kt("Manset", 142, -56, -36, 156, -42, -6, "#e4dcc6")
    kt("MansetG", 142, -57, -36, 156, -56.6, -32, "#c2b9a2")
    el = kure("El", M_ten); el.scale = (16, 12, 13); koy(el, 128, -50, -21)
    for i in range(4):                                # parmaklar
        pr = kure("Prm%d" % i, M_ten); pr.scale = (9, 6, 4)
        koy(pr, 118, -54, -32 + i * 7)
    bp = kure("Basp", M_ten); bp.scale = (7, 7, 5); koy(bp, 124, -58, -10)
    # anahtar: sap halkasi + govde + dis (avucun solundan cikar)
    halka("AnhS", 106, -21, 14, 3.6, M_pir, y=-56, n=22)
    silindir("AnhG", 'x', 52, 108, 3.4, M_pir, seg=14).location = (
        0, -56, -21 + 5.6)
    kt("AnhD1", 52, -58, -34, 62, -54, -21, "#d8ac35")
    kt("AnhD2", 66, -58, -32, 74, -54, -21, "#d8ac35")
    kt("AnhD3", 52, -58, -21, 58, -54, -14, "#a8811f")
    for i in range(7):                                # parilti: ARKADA kalir
        plA("Pri%d" % i, 92 - i * 5, -27 - i * 2, 100 + i * 5, -15 + i * 2,
            -50 + i * 0.2, "#fff0b0", 0.10)
    for i, (sx, sz) in enumerate(((88, -6), (118, -34), (74, -30))):
        pl("Isil%dA" % i, sx - 4, sz, sx + 4, sz + 1, -60, "#fff6d8")
        pl("Isil%dB" % i, sx, sz - 4, sx + 1, sz + 5, -60, "#fff6d8")

    px.shear_scene(K)


def allowed():
    return sorted(set(list(pal.ALL_HEX) + list(_RENK) + ET + TEN + KIRMIZI +
                      BIYIK + PIRINC + CELIK))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "12345"
    os.makedirs(OUT, exist_ok=True)
    yollar = []
    if "1" in mode:
        sahne1()
        yollar.append(px.render(os.path.join(OUT, "h_sahne1.png")))
    if "2" in mode:
        sahne2()
        yollar.append(px.render(os.path.join(OUT, "h_sahne2.png")))
    if "3" in mode:
        sahne3()
        yollar.append(px.render(os.path.join(OUT, "h_sahne3.png")))
    if "4" in mode:
        sahne4()
        yollar.append(px.render(os.path.join(OUT, "h_sahne4.png")))
    if "5" in mode:
        sahne5()
        yollar.append(px.render(os.path.join(OUT, "h_sahne5.png")))
    if yollar:
        px.contact(yollar, 1, os.path.join(OUT, "hikaye_x2.png"), scale=2)
    print("HIKAYE_DONE %s" % mode)


if __name__ == "__main__":
    main()
