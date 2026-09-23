"""DONER BICAKLARI - dort yukseltme kademesi, 3B model + piksel render.

Oyundaki karsiligi:
  js/data.js  -> UPG 'knife', lvName:
      0  (yok)              basit, yipranmis bicak
      1  Keskin bicak       temiz, uzun agiz
      2  Cift tarafli bicak iki yani da bilenmis, simetrik
      3  Profesyonel satir  yuksek dikdortgen agiz, agir
      4  Otomatik kesim     -> ayri makine cizimi zaten var (art.js)

  js/art.js   -> drawKesimBicagi()   (su anki tek gorunum)
  js/game.js  -> drawDonerBicak()    (imlec bicagi, ayni cizicye delege)

SORUN 1: gercek doner bicagi UZUN ve GENIS AGIZLIDIR - neredeyse bir
kilic. Simdiki cizim ince bir sofra bicagi gibi duruyor.
SORUN 2: yukseltme alininca gorunum degismiyor; oyuncu 4200 dolar
odeyip ayni bicagi goruyor.

Boru hattinin uc kurali (blender/README.md): 1 birim = 1 piksel,
anti-alias yok, renk yonetimi kapali. Golgeleme cel_nx ile.

Yerel koordinat: (0,0) = agzin ucu.  Sap SOLDA, agiz SAGA bakar.
"""
import sys, os, math
import bpy, bmesh

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
import pxcore as px
import palette as pal

OUT = os.path.join(_HERE, "out")


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


def agiz(name, boy, yuk, kalin, mat, cift=False, seg=40):
    """Doner bicagi agzi: BOYDAN BOYA ayni genislik, UCU YUVARLAK.

    boy   : agiz uzunlugu
    yuk   : agiz yuksekligi (bastan sona sabit)
    kalin : celik kalinligi (derinlik)
    cift  : ust kenar da bilenmis -> sirtta ikinci hat

    Onceki surumler uca dogru konikleserek sivriliyordu; o bir mutfak
    bicagi silueti. Doner bicagi et SIYIRIR, delmez - ucu kaskatidir.
    """
    bm = bmesh.new()
    prev = None
    first = None
    UC = 0.90                       # son %10 yuvarlanir
    for i in range(seg + 1):
        u = i / seg                 # 0 = sap tarafi, 1 = uc
        x = -boy + u * boy
        if u < UC:
            yar = 1.0
        else:
            t = (u - UC) / (1 - UC)
            yar = math.sqrt(max(0.0, 1 - t * t))    # ceyrek daire: yuvarlak uc
        h = (yuk / 2) * yar
        if h < 0.18:
            h = 0.18
        kl = kalin * (0.62 + 0.38 * yar)
        # kesit: sirt duz ve kalin, kesici kenar ince
        if cift:
            kesit = [(-kl * .30, h), (kl * .30, h),
                     (kl, h * .25), (kl * .30, -h), (-kl * .30, -h),
                     (-kl, h * .25)]
        else:
            kesit = [(-kl, h), (kl, h),
                     (kl * .50, -h * .45), (0.0, -h), (-kl * .50, -h * .45)]
        vs = [bm.verts.new((x, y, z)) for (y, z) in kesit]
        if prev is not None:
            m = len(kesit)
            for j in range(m):
                bm.faces.new((prev[j], prev[(j + 1) % m], vs[(j + 1) % m], vs[j]))
        else:
            first = vs
        prev = vs
    bm.faces.new(list(reversed(first)))
    bm.faces.new(prev)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


def sap(name, x0, x1, r0, r1, mat, seg=18, kose=False, kanca=0.0):
    """Sap: X boyunca silindir (kose=True ise kare kesitli).
    kanca>0 ise ARKA UC yukari kivrilir - referans fotograftaki gibi."""
    bm = bmesh.new()
    prev = None
    first = None
    n = 14
    for i in range(n + 1):
        u = i / n
        x = x0 + (x1 - x0) * u
        r = r0 + (r1 - r0) * u
        r *= (0.90 + 0.14 * math.sin(u * math.pi))     # ortasi dolgun
        kz = kanca * max(0.0, (u - 0.62) / 0.38) ** 1.6
        vs = []
        for j in range(seg):
            a = 2 * math.pi * j / seg
            c, s = math.cos(a), math.sin(a)
            if kose:
                kk = (abs(c) ** 4 + abs(s) ** 4) ** (-.25)
                c *= kk; s *= kk
            vs.append(bm.verts.new((x, c * r, s * r + kz)))
        if prev is not None:
            for k in range(seg):
                bm.faces.new((prev[k], prev[(k + 1) % seg], vs[(k + 1) % seg], vs[k]))
        else:
            first = vs
        prev = vs
    bm.faces.new(list(reversed(first)))
    bm.faces.new(prev)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    ob = new_obj(name, bm)
    ob.data.materials.append(mat)
    return ob


def blok(name, x0, x1, r, mat, seg=16):
    return sap(name, x0, x1, r, r, mat, seg=seg)


# --------------------------------------------------------------- paletler
CELIK_YENI = ["#5a636c", "#8f9aa4", "#c9d2da", "#eef4f8", "#ffffff"]
CELIK_ESKI = ["#4e565e", "#767f88", "#a2abb3", "#c4ccd3", "#dfe6ec"]
CELIK_PRO = ["#4a525a", "#7b858f", "#b6c0c9", "#e2e9ef", "#ffffff"]
AHSAP = ["#3f2712", "#5b3a20", "#7a5230", "#a5713f", "#c99565"]
SIYAH = ["#141414", "#242830", "#3a4048", "#565e68", "#7b848e"]
PIRINC = ["#a97113", "#e0a41f", "#ffd34e", "#fff2a8"]
STOP = [0.0, 0.18, 0.44, 0.72, 0.92]


def sahne(kademe):
    """kademe 0..3 - data.js'teki lvName sirasiyla.
    Olculer referans fotograftan: agiz sapin ~3.5-4 kati, ucu yuvarlak."""
    px.reset()
    px.setup(50, 18)
    px.ortho_cam(0, 0, 50, 18)
    px.world("#000000", 0.0)

    if kademe == 0:
        M_c = px.cel_nx("C0", CELIK_ESKI, STOP, axis="Z", noise=0.03, noise_scale=2.0)
        M_s = px.cel_nx("S0", AHSAP, STOP, axis="Z", noise=0.02, noise_scale=1.6)
        M_b = px.cel_nx("B0", ["#5a5048", "#7a6c5c", "#9a8a76"], [0, .4, .82], axis="Z")
        agiz("Agiz", 20.0, 3.2, 0.55, M_c)
        blok("Bilezik", -21.2, -20.0, 1.7, M_b)
        sap("Sap", -28.5, -21.2, 2.9, 2.4, M_s)

    elif kademe == 1:
        M_c = px.cel_nx("C1", CELIK_YENI, STOP, axis="Z")
        M_s = px.cel_nx("S1", SIYAH, STOP, axis="Z")
        M_b = px.cel_nx("B1", ["#8f9aa4", "#c9d2da", "#eef4f8"], [0, .4, .84], axis="Z")
        agiz("Agiz", 26.0, 3.6, 0.58, M_c)
        blok("Bilezik", -27.4, -26.0, 1.9, M_b)
        sap("Sap", -35.0, -27.4, 3.1, 2.6, M_s, kose=True, kanca=1.1)
        for dx in (-29.5, -32.0):
            blok("P%d" % int(-dx), dx - .35, dx + .35, 0.7, M_b)

    elif kademe == 2:
        M_c = px.cel_nx("C2", CELIK_YENI, STOP, axis="Z")
        M_s = px.cel_nx("S2", SIYAH, STOP, axis="Z")
        M_b = px.cel_nx("B2", ["#8f9aa4", "#c9d2da", "#eef4f8"], [0, .4, .84], axis="Z")
        # IKI AYRI AGIZ: ortadan ayrilir, arada gercek bosluk kalir.
        # Tek agiza ikinci bilenme hatti koymak yeterince okunmuyordu.
        ust = agiz("AgizUst", 29.0, 1.9, 0.52, M_c)
        alt = agiz("AgizAlt", 29.0, 1.9, 0.52, M_c)
        ust.location.z = 1.55
        alt.location.z = -1.55
        # iki agzin sapa girdigi yerde birlestiren kama
        blok("Catal", -30.4, -27.5, 2.2, M_c)
        blok("Bilezik", -31.8, -30.4, 2.4, M_b)
        sap("Sap", -39.4, -31.8, 3.3, 2.7, M_s, kose=True, kanca=1.4)
        for dx in (-33.4, -35.4, -37.4):
            blok("P%d" % int(-dx), dx - .35, dx + .35, 0.75, M_b)

    else:
        M_c = px.cel_nx("C3", CELIK_PRO, STOP, axis="Z")
        M_s = px.cel_nx("S3", SIYAH, STOP, axis="Z")
        M_b = px.cel_nx("B3", PIRINC, [0, .30, .64, .90], axis="Z")
        agiz("Agiz", 30.0, 5.0, 0.68, M_c)
        blok("Bilezik", -31.6, -30.0, 2.6, M_b)
        sap("Sap", -40.0, -31.6, 3.7, 3.1, M_s, kose=True, kanca=1.7)
        for dx in (-33.3, -35.3, -37.3):
            blok("P%d" % int(-dx), dx - .4, dx + .4, 0.85, M_b)

    # uc sagda, sap solda: kadraja otur
    for ob in bpy.context.scene.objects:
        if ob.type == "MESH":
            ob.location.x += 21.0


def allowed():
    ok = list(pal.ALL_HEX)
    for g in (CELIK_YENI, CELIK_ESKI, CELIK_PRO, AHSAP, SIYAH, PIRINC):
        ok += g
    ok += ["#5a5048", "#7a6c5c", "#9a8a76"]
    return sorted(set(ok))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mode = argv[0] if argv else "look"
    os.makedirs(OUT, exist_ok=True)
    paths = []
    for i in range(4):
        sahne(i)
        paths.append(px.outline(px.render(os.path.join(OUT, "bic%d.png" % i)),
                                "#2b2018", 105))
    px.audit(paths[1], allowed(), "bicak sv1", show=18)
    px.contact(paths, 2, os.path.join(OUT, "bicaklar_x6.png"), scale=6)
    px.contact(paths, 4, os.path.join(OUT, "bicaklar_x2.png"), scale=2)
    print("BICAKLAR_DONE %s" % mode)


if __name__ == "__main__":
    main()
