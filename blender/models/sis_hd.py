"""DONER SISI HD — Godot remake icin silindirik yuzey dokulari.

    blender --background --factory-startup --python blender/models/sis_hd.py

Remake'te sis sprite karesi DEGIL, shader: koniyi, donusu, pisme rengini ve
kesim yuzunu Godot ekran kartinda hesapliyor (kutle / pisme / aci / kesim
surekli parametreler; kare olarak on binlerce kombinasyon ederdi). Blender'in
isi etin YUZEYINI uretmek:

  1. Uc boyutlu doner: ust uste yigilmis et dilimleri (her dilimin kenari
     kendi duzensizliginde tasiyor), 4 dikis olugu (dilimler dort parca
     halinde dizilir), yag damlalari, et parcaciklari. Sekil oyundaki koni
     profiliyle (art.js coneProfile) ayni.
  2. Cycles AO pisirme: yuksek cozunurluklu modelden sade koni uzerine,
     silindirik UV'ye. Dilim aralarindaki gercek golgeler buradan geliyor.
  3. Renk kanallari (parlaklik / yag / kizarma) ayni yukseklik alanindan.

Cikti: blender/out/sis_hd/
  sis_doku.png       RGBA NU x NV: R=parlaklik  G=yag  B=kizarma  A=AO
  sis_yukseklik.png  L    NU x NV: yuzey yuksekligi (0.5 = duz); silüet
                     kenarinin donerken titremesi icin
  onizleme_3b.png    modelin 3B isikli gorunusu (kontrol icin)

Doku koordinati: u = aci / 2pi (yatayda DIKISSIZ, 0 = 1), v = 0 tepe .. 1 dip.
Boyut: NU = 256 ~ 2x ekranda koni cevresi (2*pi*38), NV = 220 = 2x yukseklik.
Boylece shader dokuyu ~1:1 ornekler; donerken piksel titremesi en az.
"""
import sys, os, math
import bpy
import numpy as np

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(_HERE, "out", "sis_hd")
NU, NV = 256, 220
H = 110.0          # koni yuksekligi (mantik pikseli), art.js: bot - top
MAXR = 19.0
TAU = 2 * math.pi


def cone_profile(ty):
    """art.js coneProfile — birebir (dizi surumu)."""
    ty = np.asarray(ty, dtype=np.float64)
    out = np.empty_like(ty)
    a = ty < .09
    u = np.clip(ty / .09, 0, 1)
    out[a] = (.52 + .44 * (u * u * (3 - 2 * u)))[a]
    b = (ty >= .09) & (ty < .62)
    out[b] = (.96 + .04 * np.sin((ty - .09) / .53 * np.pi))[b]
    c = ty >= .62
    k = (ty - .62) / .38
    out[c] = np.maximum(.10, 1 - k * k * .90)[c]
    return out


# ---------------------------------------------------------------- alanlar
def periyodik(th, K, rng):
    """Aciya gore dikissiz yumusak gurultu: tam sayi frekansli sinus toplami."""
    s = np.zeros_like(th)
    for k in range(1, K + 1):
        s += rng.normal() / k * np.sin(k * th + rng.uniform(0, TAU))
    return s / (np.abs(s).max() + 1e-9)


def gurultu2(TH, Y, n, ky_aralik, kt_aralik, rng):
    """Aciya gore dikissiz 2B gurultu: rastgele yonlu duz dalgalarin toplami.
    Aci frekansi TAM SAYI (dikis yok); dikey frekans serbest. Ilk surumdeki
    birkac sinusluk "lif" orgu gibi duzenli gorunuyordu; cok bilesen ve
    rastgele yon bunu kiriyor."""
    s = np.zeros_like(TH)
    for _ in range(n):
        kt = rng.integers(kt_aralik[0], kt_aralik[1] + 1) * rng.choice([-1, 1])
        ky = rng.uniform(*ky_aralik)
        s += np.sin(kt * TH + ky * Y + rng.uniform(0, TAU)) * rng.uniform(.4, 1.0)
    return s / (np.abs(s).max() + 1e-9)


def alanlar(seed=7):
    rng = np.random.default_rng(seed)
    u = (np.arange(NU) + .5) / NU
    v = (np.arange(NV) + .5) / NV
    TH, V = np.meshgrid(u * TAU, v)          # (NV, NU)
    Y = V * H

    # --- dilimler: kalinlik DEGISKEN (2.4..5.8 px), alt sinir aciya gore dalgali
    sinirlar = [-6.0]
    while sinirlar[-1] < H + 6:
        sinirlar.append(sinirlar[-1] + rng.uniform(2.4, 5.8))
    n = len(sinirlar)
    sinir = np.zeros((n, NU))
    cikinti = np.zeros((n, NU))
    parlak = np.zeros(n)
    for j in range(n):
        sinir[j] = sinirlar[j] + 1.3 * periyodik(u * TAU, 7, rng)
        cikinti[j] = .55 + .55 * periyodik(u * TAU, 11, rng)
        parlak[j] = rng.uniform(-.20, .20)
    yuk = np.zeros((NV, NU))
    f_ic = np.zeros((NV, NU))
    dilim = np.zeros((NV, NU), dtype=np.int32)
    for j in range(n - 1):
        alt, ust = sinir[j][None, :], sinir[j + 1][None, :]
        m = (Y >= alt) & (Y < ust)
        f = np.clip((Y - alt) / np.maximum(ust - alt, .5), 0, 1)
        # et asagi sarkar: dilimin alt yarisi daha dolgun
        prof = np.power(np.sin(np.pi * np.power(f, .8)), .6) * cikinti[j][None, :]
        yuk = np.where(m, prof, yuk)
        f_ic = np.where(m, f, f_ic)
        dilim = np.where(m, j, dilim)

    # --- topak topak kesilmis yuzey (bicak her geciste farkli derinlik)
    topak = gurultu2(TH, Y, 60, (.05, .6), (2, 14), rng)
    yuk += .55 * topak

    # --- dort dikis olugu (art.js SEAMS=4), yer yer kapanmis
    th0 = rng.uniform(0, TAU / 4)
    kapali = .5 + .5 * gurultu2(TH, Y, 12, (.08, .3), (1, 3), rng)
    for k in range(4):
        d = np.angle(np.exp(1j * (TH - (th0 + k * TAU / 4))))
        yuk -= 1.0 * np.exp(-(d / .06) ** 2) * (.45 + .55 * kapali)

    # --- et parcaciklari
    for _ in range(70):
        tc, yc = rng.uniform(0, TAU), rng.uniform(4, H - 4)
        rt, ry = rng.uniform(.05, .13), rng.uniform(1.5, 4.0)
        d = np.angle(np.exp(1j * (TH - tc)))
        yuk += rng.uniform(-.25, .6) * np.exp(-(d / rt) ** 2 - ((Y - yc) / ry) ** 2)

    # --- yag damlalari
    yag = np.zeros((NV, NU))
    for _ in range(12):
        tc, y0 = rng.uniform(0, TAU), rng.uniform(8, H * .7)
        boy = rng.uniform(8, 24)
        d = np.angle(np.exp(1j * (TH - tc)))
        g = np.clip(1 - (Y - y0) / boy, 0, 1) * (Y >= y0)
        serit = np.exp(-(d / (.016 + .018 * g)) ** 2) * g
        yag = np.maximum(yag, serit)
        yuk += .25 * serit

    # dilim aralarindaki yag katmani: her yerde degil, kopuk kopuk
    kopuk = np.clip(.5 + .8 * gurultu2(TH, Y, 20, (.1, .5), (3, 16), rng), 0, 1)
    ince = np.exp(-(f_ic / .09) ** 2) * kopuk
    yag = np.maximum(yag, np.clip(ince, 0, 1) * .75)

    # --- parlaklik: dilim basina ton + topak + ince lif
    lif = gurultu2(TH, Y, 50, (.8, 2.2), (10, 40), rng)
    parl = .5 + parlak[dilim] + .14 * topak + .08 * lif + .08 * np.clip(yuk, -1, 1.5)

    # --- kizarma: cikintilarin ust kenari (dilimin ust kismi, disa tasan) citir
    ust_kenar = np.exp(-((f_ic - .12) / .18) ** 2)
    kiz = np.clip((yuk - .45) * 1.1 + .45 * ust_kenar * (yuk > .2) + .2 * lif, 0, 1)
    return yuk, np.clip(parl, 0, 1), np.clip(yag, 0, 1), kiz


# ---------------------------------------------------------------- 3B
def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def koni_mesh(ad, nu, nv, yuk=None, olcek=.9):
    """(aci, yukseklik) izgarasindan koni. yuk verilirse yaricapa eklenir.
    UV: u = aci/2pi (dikiste ciftlenmis kose), v = tepe 1 .. dip 0 (Blender)."""
    import bmesh
    bm = bmesh.new()
    uv = bm.loops.layers.uv.new()
    satirlar = []
    for i in range(nv + 1):
        v = i / nv
        r0 = MAXR * float(cone_profile(np.array([v]))[0])
        satir = []
        for k in range(nu + 1):
            u = k / nu
            r = r0
            if yuk is not None:
                ku = min(int(u * NU), NU - 1)
                kv = min(int(v * NV), NV - 1)
                r = r0 + olcek * yuk[kv, ku] * (r0 / MAXR)
            a = u * TAU
            satir.append(bm.verts.new((r * math.cos(a), r * math.sin(a), -v * H)))
        satirlar.append(satir)
    for i in range(nv):
        for k in range(nu):
            f = bm.faces.new((satirlar[i][k], satirlar[i][k + 1], satirlar[i + 1][k + 1], satirlar[i + 1][k]))
            for loop, (uu, vv) in zip(f.loops, ((k, i), (k + 1, i), (k + 1, i + 1), (k, i + 1))):
                loop[uv].uv = (uu / nu, 1 - vv / nv)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    me = bpy.data.meshes.new(ad)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        p.use_smooth = True
    ob = bpy.data.objects.new(ad, me)
    bpy.context.collection.objects.link(ob)
    return ob


def ao_pisir(yuksek, alcak, yol):
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"
    sc.cycles.samples = 96
    sc.cycles.device = "CPU"
    img = bpy.data.images.new("ao", NU, NV, alpha=False)
    img.colorspace_settings.name = "Non-Color"
    mat = bpy.data.materials.new("Hedef")
    mat.use_nodes = True
    tex = mat.node_tree.nodes.new("ShaderNodeTexImage")
    tex.image = img
    mat.node_tree.nodes.active = tex
    alcak.data.materials.append(mat)
    bpy.ops.object.select_all(action="DESELECT")
    yuksek.select_set(True)
    alcak.select_set(True)
    bpy.context.view_layer.objects.active = alcak
    bk = sc.render.bake
    bk.use_selected_to_active = True
    bk.cage_extrusion = 3.0
    bk.margin = 4
    bpy.ops.object.bake(type="AO")
    px = np.array(img.pixels[:], dtype=np.float32).reshape(NV, NU, 4)[::-1, :, 0]
    return px


def kaydet_png(arr_u8, yol, mod):
    """Blender uzerinden PNG yaz (PIL yok). arr: (h, w, c) uint8, ust satir ilk."""
    h, w = arr_u8.shape[:2]
    c = arr_u8.shape[2] if arr_u8.ndim == 3 else 1
    rgba = np.zeros((h, w, 4), dtype=np.float32)
    if c == 1:
        g = arr_u8.reshape(h, w).astype(np.float32) / 255.0
        rgba[..., 0] = g; rgba[..., 1] = g; rgba[..., 2] = g; rgba[..., 3] = 1
    else:
        rgba[..., :c] = arr_u8.astype(np.float32) / 255.0
        if c == 3:
            rgba[..., 3] = 1
    img = bpy.data.images.new("kayit", w, h, alpha=True)
    img.colorspace_settings.name = "Non-Color"
    img.pixels.foreach_set(rgba[::-1].ravel())
    img.filepath_raw = yol
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)


def onizleme(yuk, parl, yag, kiz, yol):
    """Isikli 3B gorunus: yuksek model, renkler kose ozniteliginden."""
    sc = bpy.context.scene
    ob = koni_mesh("Onizleme", 256, 220, yuk)
    me = ob.data
    renk = me.color_attributes.new("Renk", "FLOAT_COLOR", "POINT")
    et = np.array([.70, .42, .20])
    yagr = np.array([.95, .80, .45])
    kizr = np.array([.22, .12, .06])
    k = 0
    for i in range(221):
        v = i / 220
        for kk in range(257):
            u = kk / 256
            ku, kv = min(int(u * NU), NU - 1), min(int(v * NV), NV - 1)
            c = et * (.6 + .8 * parl[kv, ku])
            c = c + (yagr - c) * yag[kv, ku] * .8
            c = c + (kizr - c) * kiz[kv, ku] * .7
            renk.data[k].color = (c[0], c[1], c[2], 1)
            k += 1
    mat = bpy.data.materials.new("Et")
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = nt.nodes.get("Principled BSDF")
    attr = nt.nodes.new("ShaderNodeVertexColor")
    attr.layer_name = "Renk"
    nt.links.new(attr.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = .55
    me.materials.append(mat)
    cam_d = bpy.data.cameras.new("Kam")
    cam_d.type = "ORTHO"
    cam_d.ortho_scale = H * 1.15
    cam = bpy.data.objects.new("Kam", cam_d)
    cam.location = (0, -200, -H / 2)
    cam.rotation_euler = (math.radians(90), 0, 0)
    sc.collection.objects.link(cam)
    sc.camera = cam
    for ad, en, rot in (("Ana", 4.0, (math.radians(55), 0, math.radians(35))),
                        ("Dolgu", 1.2, (math.radians(70), 0, math.radians(-60)))):
        ld = bpy.data.lights.new(ad, "SUN")
        ld.energy = en
        lo = bpy.data.objects.new(ad, ld)
        lo.rotation_euler = rot
        sc.collection.objects.link(lo)
    sc.render.engine = "CYCLES"
    sc.cycles.samples = 48
    sc.render.resolution_x, sc.render.resolution_y = 320, 400
    sc.render.film_transparent = True
    sc.render.filepath = yol
    bpy.ops.render.render(write_still=True)


def main():
    os.makedirs(OUT, exist_ok=True)
    reset()
    yuk, parl, yag, kiz = alanlar()
    print("SIS_HD alanlar: yukseklik %.2f..%.2f" % (yuk.min(), yuk.max()))
    yuksek = koni_mesh("Yuksek", 256, 220, yuk)
    alcak = koni_mesh("Alcak", 64, 55)
    ao = ao_pisir(yuksek, alcak, None)
    print("SIS_HD AO: %.2f..%.2f ort %.2f" % (ao.min(), ao.max(), ao.mean()))
    doku = np.zeros((NV, NU, 4), dtype=np.uint8)
    doku[..., 0] = np.clip(parl * 255, 0, 255)
    doku[..., 1] = np.clip(yag * 255, 0, 255)
    doku[..., 2] = np.clip(kiz * 255, 0, 255)
    doku[..., 3] = np.clip(ao * 255, 0, 255)
    kaydet_png(doku, os.path.join(OUT, "sis_doku.png"), "RGBA")
    yk = np.clip((yuk / 3.0 + .5) * 255, 0, 255).astype(np.uint8)
    kaydet_png(yk, os.path.join(OUT, "sis_yukseklik.png"), "L")
    bpy.data.objects.remove(alcak, do_unlink=True)
    bpy.data.objects.remove(yuksek, do_unlink=True)
    onizleme(yuk, parl, yag, kiz, os.path.join(OUT, "onizleme_3b.png"))
    print("SIS_HD_DONE")


if __name__ == "__main__":
    main()
