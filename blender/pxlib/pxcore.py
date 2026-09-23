"""Piksel-art render cekirdegi.

Kural: 1 Blender birimi = 1 oyun pikseli. Ortografik kamera, anti-alias yok,
Standard view transform, cel-shade materyal -> cikti dogrudan oyun paletinde.
"""
import math, os
import bpy
import numpy as np

# ---------------------------------------------------------------- renk yardim
def hex_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))

def srgb_to_lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def lin_to_srgb(c):
    return c * 12.92 if c <= 0.0031308 else 1.055 * (c ** (1 / 2.4)) - 0.055

def hex_lin(h, a=1.0):
    """Hex -> Blender soket rengi (linear). Standard view transform ile
    render ciktisinda tam olarak ayni hex geri gelir."""
    r, g, b = hex_rgb(h)
    return (srgb_to_lin(r), srgb_to_lin(g), srgb_to_lin(b), a)

# ---------------------------------------------------------------- sahne kurma
def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    for blk in (bpy.data.meshes, bpy.data.materials, bpy.data.images,
                bpy.data.objects, bpy.data.curves):
        for d in list(blk):
            try:
                blk.remove(d)
            except Exception:
                pass

def setup(w, h, transparent=True):
    sc = bpy.context.scene
    r = sc.render
    r.engine = "BLENDER_EEVEE"
    r.resolution_x, r.resolution_y = int(w), int(h)
    r.resolution_percentage = 100
    r.filter_size = 0.01          # anti-alias kapali: kenarlar keskin piksel
    r.film_transparent = transparent
    r.image_settings.file_format = "PNG"
    r.image_settings.color_mode = "RGBA"
    r.image_settings.color_depth = "8"
    r.image_settings.compression = 0
    r.dither_intensity = 0.0   # 8-bit dither kapali: renkler birebir
    sc.eevee.taa_render_samples = 1   # jitter yok
    for attr, val in (("use_raytracing", False), ("use_shadows", False),
                      ("use_volumetric_lights", False)):
        if hasattr(sc.eevee, attr):
            try:
                setattr(sc.eevee, attr, val)
            except Exception:
                pass
    # renk yonetimi: hicbir tone-map yok
    sc.view_settings.view_transform = "Standard"
    sc.view_settings.look = "None"
    sc.view_settings.exposure = 0.0
    sc.view_settings.gamma = 1.0
    sc.display_settings.display_device = "sRGB"
    return sc

def ortho_cam(cx, cz, w, h, name="Cam"):
    """Onden ortografik kamera. Gorunen alan: cx +- w/2, cz +- h/2 (piksel)."""
    cam_data = bpy.data.cameras.new(name)
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = float(max(w, h))
    cam_data.clip_start = 1.0
    cam_data.clip_end = 4000.0
    cam = bpy.data.objects.new(name, cam_data)
    cam.location = (cx, -1200.0, cz)
    cam.rotation_euler = (math.radians(90), 0, 0)
    bpy.context.collection.objects.link(cam)
    bpy.context.scene.camera = cam
    return cam

def shear_scene(k=0.55, objects=None):
    """Kabin (oblik) izdusum: z += y * k.

    Oyun saf on-gorunum ciziyor ama YATAY yuzeyleri yukaridan bakiyormus gibi
    sahteliyor - `trayBase()` icindeki egimli duvarlar, `ell()` ile yassilan
    tepsi agizlari hep bu. Gercek bir kamera egimi dikey olculeri cos(t) kadar
    kisaltir ve 1 birim = 1 piksel kurali bozulur.

    Bunun yerine geometriyi kaydiriyoruz: dikey yuzler tam 1:1 kalir, derinlik
    kazanan sadece yatay yuzeyler olur. 2B oyun sanatinin kullandigi izdusumun
    ta kendisi.

    k : 1 birim derinlik basina kac piksel dikey acilim
    """
    # matrix_world, obje olusturulduktan sonra depsgraph degerlendirilene
    # kadar ESKI kalir. Guncellemeden okursak kaydirmayi dunya degil YEREL
    # uzayda yapmis oluyoruz: yassi bir kutuda (yuksekligi derinliginden
    # cok kucuk) egim neredeyse yok oluyor, ust yuzey gorunmuyordu.
    bpy.context.view_layer.update()
    for ob in (objects if objects is not None else bpy.context.scene.objects):
        if ob.type != "MESH":
            continue
        mw = ob.matrix_world
        me = ob.data
        for v in me.vertices:
            wco = mw @ v.co
            wco.z += wco.y * k
            v.co = mw.inverted() @ wco
        me.update()
        me.calc_loop_triangles()
    return k

def world(hexcol="#000000", strength=0.0):
    """Ortam isigi - golgeli tarafi tabana oturtur (karanlik tarafi kaldirir)."""
    wd = bpy.data.worlds.get("W") or bpy.data.worlds.new("W")
    bpy.context.scene.world = wd
    wd.use_nodes = True
    nt = wd.node_tree
    nt.nodes.clear()
    bg = nt.nodes.new("ShaderNodeBackground")
    bg.inputs["Color"].default_value = hex_lin(hexcol)
    bg.inputs["Strength"].default_value = float(strength)
    out = nt.nodes.new("ShaderNodeOutputWorld")
    nt.links.new(bg.outputs[0], out.inputs["Surface"])
    return wd

def sun(strength=3.0, rot=(-35, 0, -40), name="Sun"):
    d = bpy.data.lights.new(name, type="SUN")
    d.energy = strength
    d.angle = 0.0                  # sert terminator
    o = bpy.data.objects.new(name, d)
    o.rotation_euler = tuple(math.radians(a) for a in rot)
    bpy.context.collection.objects.link(o)
    return o

# ---------------------------------------------------------------- materyaller
def _nodes(mat):
    mat.use_nodes = True
    nt = mat.node_tree
    nt.nodes.clear()
    return nt, nt.nodes, nt.links

def flat(name, hexcol):
    """Golgesiz duz renk - oyunun fr() cagrilarinin karsiligi."""
    mat = bpy.data.materials.new(name)
    nt, n, l = _nodes(mat)
    em = n.new("ShaderNodeEmission"); em.location = (0, 0)
    em.inputs["Color"].default_value = hex_lin(hexcol)
    em.inputs["Strength"].default_value = 1.0
    out = n.new("ShaderNodeOutputMaterial"); out.location = (220, 0)
    l.new(em.outputs[0], out.inputs["Surface"])
    return mat

def flat_a(name, hexcol, alpha=0.25):
    """Yari saydam duz renk - oyunun globalAlpha ile cizdigi golgeler icin."""
    mat = bpy.data.materials.new(name)
    nt, n, l = _nodes(mat)
    em = n.new("ShaderNodeEmission"); em.location = (-200, 60)
    em.inputs["Color"].default_value = hex_lin(hexcol)
    tr = n.new("ShaderNodeBsdfTransparent"); tr.location = (-200, -80)
    mix = n.new("ShaderNodeMixShader"); mix.location = (20, 0)
    mix.inputs[0].default_value = float(alpha)
    l.new(tr.outputs[0], mix.inputs[1])
    l.new(em.outputs[0], mix.inputs[2])
    out = n.new("ShaderNodeOutputMaterial"); out.location = (220, 0)
    l.new(mix.outputs[0], out.inputs["Surface"])
    for attr in ("surface_render_method", "blend_method"):
        if hasattr(mat, attr):
            try:
                setattr(mat, attr, "BLENDED" if attr == "surface_render_method" else "BLEND")
            except Exception:
                pass
    return mat

def cel(name, ramp_hex, stops=None, noise=0.0, noise_scale=8.0, bias=0.0):
    """Cel-shade: lambert -> sabit (CONSTANT) renk rampasi -> emission.

    ramp_hex : koyu -> acik hex listesi (palet tonlari)
    stops    : rampa esik konumlari (len(ramp_hex) adet, artan, 0..1)
    noise    : yuzeye doku kirilmasi katar (et, ekmek icin)
    bias     : tum tonlari yukari/asagi kaydirir
    """
    n_c = len(ramp_hex)
    if stops is None:
        stops = [i / n_c for i in range(n_c)]
    mat = bpy.data.materials.new(name)
    nt, n, l = _nodes(mat)

    dif = n.new("ShaderNodeBsdfDiffuse"); dif.location = (-900, 0)
    dif.inputs["Color"].default_value = (1, 1, 1, 1)
    dif.inputs["Roughness"].default_value = 1.0

    s2r = n.new("ShaderNodeShaderToRGB"); s2r.location = (-700, 0)
    l.new(dif.outputs[0], s2r.inputs[0])

    bw = n.new("ShaderNodeRGBToBW"); bw.location = (-540, 0)
    l.new(s2r.outputs[0], bw.inputs[0])

    val = bw.outputs[0]

    if noise > 0.0:
        tex = n.new("ShaderNodeTexNoise"); tex.location = (-700, -260)
        tex.inputs["Scale"].default_value = noise_scale
        tex.inputs["Detail"].default_value = 3.0
        nb = n.new("ShaderNodeRGBToBW"); nb.location = (-540, -260)
        l.new(tex.outputs["Color"], nb.inputs[0])
        sub = n.new("ShaderNodeMath"); sub.location = (-400, -260)
        sub.operation = "SUBTRACT"; sub.inputs[1].default_value = 0.5
        l.new(nb.outputs[0], sub.inputs[0])
        mul = n.new("ShaderNodeMath"); mul.location = (-260, -260)
        mul.operation = "MULTIPLY"; mul.inputs[1].default_value = float(noise)
        l.new(sub.outputs[0], mul.inputs[0])
        add = n.new("ShaderNodeMath"); add.location = (-260, -60)
        add.operation = "ADD"
        l.new(val, add.inputs[0]); l.new(mul.outputs[0], add.inputs[1])
        val = add.outputs[0]

    if bias != 0.0:
        bs = n.new("ShaderNodeMath"); bs.location = (-120, -60)
        bs.operation = "ADD"; bs.inputs[1].default_value = float(bias)
        l.new(val, bs.inputs[0])
        val = bs.outputs[0]

    ramp = n.new("ShaderNodeValToRGB"); ramp.location = (40, 0)
    cr = ramp.color_ramp
    cr.interpolation = "CONSTANT"
    while len(cr.elements) > 1:
        cr.elements.remove(cr.elements[-1])
    cr.elements[0].position = 0.0
    cr.elements[0].color = hex_lin(ramp_hex[0])
    for i in range(1, n_c):
        e = cr.elements.new(min(1.0, max(0.0, stops[i])))
        e.color = hex_lin(ramp_hex[i])
    l.new(val, ramp.inputs["Fac"])

    em = n.new("ShaderNodeEmission"); em.location = (300, 0)
    em.inputs["Strength"].default_value = 1.0
    l.new(ramp.outputs["Color"], em.inputs["Color"])

    out = n.new("ShaderNodeOutputMaterial"); out.location = (500, 0)
    l.new(em.outputs[0], out.inputs["Surface"])
    return mat

def cel_nx(name, ramp_hex, stops, band=0.0, band_freq=0.62, band_amt=0.03,
           noise=0.0, noise_scale=6.0, specks=None, axis="X"):
    """Oyunun kendi golgeleme mantigi: ton, yuzey normalinin YATAY bileseni
    (nx) ile belirlenir - isik kaynagi degil.

    art.js drawSpit() icinde tam olarak bu yapiliyor:
        nx = x / r  ->  shade = .52 / .66 / .80 / .95 / 1.12 / 1.30 / 1.12 / .86
    Kamera +Y yonune baktigi icin dunya X'i = ekran X'i, yani Geometry
    node'unun Normal.x'i dogrudan oyunun nx'idir.

    Avantaji: model donerken bantlar yerinde kalir (isikta oldugu gibi
    kaynamaz), silueti donen dikis takip eder. Piksel artta kritik.

    band : >0 ise yatay et-katmani dalgalanmasi ekler (art.js'teki `lay`)
    """
    mat = bpy.data.materials.new(name)
    nt, n, l = _nodes(mat)

    geo = n.new("ShaderNodeNewGeometry"); geo.location = (-1100, 0)
    sep = n.new("ShaderNodeSeparateXYZ"); sep.location = (-940, 60)
    l.new(geo.outputs["Normal"], sep.inputs[0])

    # axis="X": dikey silindirler (sis) - ton yatay normalden
    # axis="Z": yatay silindirler (durum) - ton dikey normalden, isik ustten
    # (-1..1) -> 0..1
    mr = n.new("ShaderNodeMapRange"); mr.location = (-780, 60)
    mr.inputs["From Min"].default_value = -1.0
    mr.inputs["From Max"].default_value = 1.0
    mr.inputs["To Min"].default_value = 0.0
    mr.inputs["To Max"].default_value = 1.0
    l.new(sep.outputs[axis], mr.inputs["Value"])
    val = mr.outputs["Result"]

    if band > 0.0:
        # art.js: lay = sin(y*.62 + sin(y*.19)*1.6);  layM = 1 + lay*.028
        pz = n.new("ShaderNodeSeparateXYZ"); pz.location = (-940, -240)
        l.new(geo.outputs["Position"], pz.inputs[0])
        f1 = n.new("ShaderNodeMath"); f1.location = (-780, -300)
        f1.operation = "MULTIPLY"; f1.inputs[1].default_value = 0.19
        l.new(pz.outputs["Z"], f1.inputs[0])
        s1 = n.new("ShaderNodeMath"); s1.location = (-640, -300)
        s1.operation = "SINE"
        l.new(f1.outputs[0], s1.inputs[0])
        m1 = n.new("ShaderNodeMath"); m1.location = (-500, -300)
        m1.operation = "MULTIPLY"; m1.inputs[1].default_value = 1.6
        l.new(s1.outputs[0], m1.inputs[0])
        f2 = n.new("ShaderNodeMath"); f2.location = (-780, -160)
        f2.operation = "MULTIPLY"; f2.inputs[1].default_value = float(band_freq)
        l.new(pz.outputs["Z"], f2.inputs[0])
        ad = n.new("ShaderNodeMath"); ad.location = (-500, -160)
        ad.operation = "ADD"
        l.new(f2.outputs[0], ad.inputs[0]); l.new(m1.outputs[0], ad.inputs[1])
        s2 = n.new("ShaderNodeMath"); s2.location = (-360, -200)
        s2.operation = "SINE"
        l.new(ad.outputs[0], s2.inputs[0])
        m2 = n.new("ShaderNodeMath"); m2.location = (-220, -200)
        m2.operation = "MULTIPLY"; m2.inputs[1].default_value = float(band_amt)
        l.new(s2.outputs[0], m2.inputs[0])
        aa = n.new("ShaderNodeMath"); aa.location = (-80, 20)
        aa.operation = "ADD"
        l.new(val, aa.inputs[0]); l.new(m2.outputs[0], aa.inputs[1])
        val = aa.outputs[0]

    if noise > 0.0:
        tx = n.new("ShaderNodeTexNoise"); tx.location = (-780, -520)
        tx.inputs["Scale"].default_value = float(noise_scale)
        tx.inputs["Detail"].default_value = 2.0
        nb = n.new("ShaderNodeRGBToBW"); nb.location = (-620, -520)
        l.new(tx.outputs["Color"], nb.inputs[0])
        sb = n.new("ShaderNodeMath"); sb.location = (-480, -520)
        sb.operation = "SUBTRACT"; sb.inputs[1].default_value = 0.5
        l.new(nb.outputs[0], sb.inputs[0])
        mn = n.new("ShaderNodeMath"); mn.location = (-340, -520)
        mn.operation = "MULTIPLY"; mn.inputs[1].default_value = float(noise)
        l.new(sb.outputs[0], mn.inputs[0])
        an = n.new("ShaderNodeMath"); an.location = (60, -60)
        an.operation = "ADD"
        l.new(val, an.inputs[0]); l.new(mn.outputs[0], an.inputs[1])
        val = an.outputs[0]

    ramp = n.new("ShaderNodeValToRGB"); ramp.location = (240, 0)
    cr = ramp.color_ramp
    cr.interpolation = "CONSTANT"
    while len(cr.elements) > 1:
        cr.elements.remove(cr.elements[-1])
    cr.elements[0].position = 0.0
    cr.elements[0].color = hex_lin(ramp_hex[0])
    for i in range(1, len(ramp_hex)):
        e = cr.elements.new(min(1.0, max(0.0, stops[i])))
        e.color = hex_lin(ramp_hex[i])
    l.new(val, ramp.inputs["Fac"])

    col = ramp.outputs["Color"]

    if specks:
        # art.js'in koni uzerine serptigi ayrintilar:
        #   kind="dot"  -> "parlak yag damlalari" (Voronoi hucre MERKEZLERI)
        #   kind="line" -> "katman ayrim cizgileri" (her `period` pikselde bir)
        yy = -420
        for sp in specks:
            kind = sp.get("kind", "dot")
            if kind == "dot":
                vor = n.new("ShaderNodeTexVoronoi"); vor.location = (240, yy)
                vor.feature = "F1"
                vor.inputs["Scale"].default_value = float(sp.get("scale", 0.9))
                msk = n.new("ShaderNodeMath"); msk.location = (400, yy)
                msk.operation = "LESS_THAN"
                msk.inputs[1].default_value = float(sp.get("size", 0.12))
                l.new(vor.outputs["Distance"], msk.inputs[0])
                mask = msk.outputs[0]
            else:
                # Position.Z modulo period -> ince yatay serit
                pz2 = n.new("ShaderNodeSeparateXYZ"); pz2.location = (100, yy)
                l.new(geo.outputs["Position"], pz2.inputs[0])
                # Serit ekseni: dikey silindirde Z (sis katmanlari),
                # yatay silindirde X (durumun izgara izleri).
                lax = sp.get("along", "Z")
                src = pz2.outputs[lax]
                # egik serit: eksene dik bileseni katarak kaydir
                # (food.js izgara izlerini dx=3 / dy=8 egimle ciziyor)
                skew = float(sp.get("skew", 0.0))
                if skew != 0.0:
                    other = "Z" if lax == "X" else "X"
                    sk = n.new("ShaderNodeMath"); sk.location = (100, yy - 90)
                    sk.operation = "MULTIPLY"; sk.inputs[1].default_value = skew
                    l.new(pz2.outputs[other], sk.inputs[0])
                    sa2 = n.new("ShaderNodeMath"); sa2.location = (170, yy - 45)
                    sa2.operation = "ADD"
                    l.new(src, sa2.inputs[0]); l.new(sk.outputs[0], sa2.inputs[1])
                    src = sa2.outputs[0]
                # MODULO isareti korudugu icin once mutlak deger al.
                ab = n.new("ShaderNodeMath"); ab.location = (230, yy)
                ab.operation = "ABSOLUTE"
                l.new(src, ab.inputs[0])
                md = n.new("ShaderNodeMath"); md.location = (300, yy)
                md.operation = "MODULO"
                md.inputs[1].default_value = float(sp.get("period", 12.0))
                l.new(ab.outputs[0], md.inputs[0])
                msk = n.new("ShaderNodeMath"); msk.location = (400, yy)
                msk.operation = "LESS_THAN"
                msk.inputs[1].default_value = float(sp.get("width", 1.0))
                l.new(md.outputs[0], msk.inputs[0])
                mask = msk.outputs[0]
                # kesik cizgi: art.js hash1(x*3.1 + y*1.7) > .38
                dash = float(sp.get("dash", 0.0))
                if dash > 0.0:
                    dn = n.new("ShaderNodeTexNoise"); dn.location = (240, yy - 160)
                    dn.inputs["Scale"].default_value = float(sp.get("dash_scale", 14.0))
                    db = n.new("ShaderNodeRGBToBW"); db.location = (400, yy - 160)
                    l.new(dn.outputs["Color"], db.inputs[0])
                    dg = n.new("ShaderNodeMath"); dg.location = (540, yy - 160)
                    dg.operation = "GREATER_THAN"; dg.inputs[1].default_value = dash
                    l.new(db.outputs[0], dg.inputs[0])
                    dm = n.new("ShaderNodeMath"); dm.location = (680, yy - 80)
                    dm.operation = "MULTIPLY"
                    l.new(mask, dm.inputs[0]); l.new(dg.outputs[0], dm.inputs[1])
                    mask = dm.outputs[0]

            # sadece belli bir nx bolgesinde gorunsun (art.js: gx2 = r*.05..r*.70)
            gate = sp.get("min_n01")
            if gate is not None:
                gt2 = n.new("ShaderNodeMath"); gt2.location = (540, yy + 80)
                gt2.operation = "GREATER_THAN"; gt2.inputs[1].default_value = float(gate)
                l.new(mr.outputs["Result"], gt2.inputs[0])
                gm = n.new("ShaderNodeMath"); gm.location = (680, yy + 80)
                gm.operation = "MULTIPLY"
                l.new(mask, gm.inputs[0]); l.new(gt2.outputs[0], gm.inputs[1])
                mask = gm.outputs[0]

            mx = n.new("ShaderNodeMix"); mx.location = (820, yy + 240)
            mx.data_type = "RGBA"
            l.new(mask, mx.inputs["Factor"])
            l.new(col, mx.inputs[6])                       # A
            mx.inputs[7].default_value = hex_lin(sp["color"])  # B
            col = mx.outputs[2]
            yy -= 620

    em = n.new("ShaderNodeEmission"); em.location = (760, 0)
    em.inputs["Strength"].default_value = 1.0
    l.new(col, em.inputs["Color"])
    out = n.new("ShaderNodeOutputMaterial"); out.location = (940, 0)
    l.new(em.outputs[0], out.inputs["Surface"])
    return mat

# ------------------------------------------------------------ render/denetim
def render(path):
    path = os.path.abspath(path)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    return path

def read_png(path):
    """PNG -> (h, w, 4) uint8 dizi. Renk yonetimi kapali (ham bayt)."""
    img = bpy.data.images.load(os.path.abspath(path), check_existing=False)
    img.colorspace_settings.name = "Non-Color"
    w, h = img.size
    buf = np.empty(w * h * 4, dtype=np.float32)
    img.pixels.foreach_get(buf)
    bpy.data.images.remove(img)
    a = (np.clip(buf.reshape(h, w, 4), 0, 1) * 255.0 + 0.5).astype(np.uint8)
    return a[::-1]                      # Blender alttan-uste saklar

def write_png(arr, path):
    h, w = arr.shape[:2]
    img = bpy.data.images.new("out", width=w, height=h, alpha=True)
    img.colorspace_settings.name = "Non-Color"
    flat_a = (arr[::-1].astype(np.float32) / 255.0).ravel()
    img.pixels.foreach_set(flat_a)
    img.file_format = "PNG"
    path = os.path.abspath(path)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.filepath_raw = path
    img.save()
    bpy.data.images.remove(img)
    return path

def audit(path, allowed_hex, label="", show=40):
    """Ciktidaki benzersiz renkleri sayar, palet disi olanlari raporlar."""
    a = read_png(path)
    op = a[..., 3] > 127
    rgb = a[..., :3][op]
    if rgb.size == 0:
        print("AUDIT %s: BOS GORUNTU" % label)
        return []
    uniq, cnt = np.unique(rgb.reshape(-1, 3), axis=0, return_counts=True)
    allow = set(h.lower().lstrip("#") for h in allowed_hex)
    lines, bad = [], []
    for c, k in sorted(zip(uniq.tolist(), cnt.tolist()), key=lambda z: -z[1]):
        hx = "%02x%02x%02x" % tuple(c)
        ok = hx in allow
        if not ok:
            bad.append((hx, k))
        lines.append("  %s#%s %6d px%s" % (" " if ok else "!", hx, k,
                                           "" if ok else "  <- PALET DISI"))
    print("AUDIT %s: %d benzersiz renk, %d opak piksel" % (label, len(uniq), int(op.sum())))
    for s in lines[:show]:
        print(s)
    if bad:
        print("AUDIT %s: %d palet disi renk" % (label, len(bad)))
    return bad

def quantize(path, allowed_hex, out=None):
    """Palet disi pikselleri en yakin palet rengine cakar (guvenlik agi)."""
    a = read_png(path)
    pal = np.array([[int(h.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
                    for h in allowed_hex], dtype=np.float32)
    rgb = a[..., :3].astype(np.float32)
    wts = np.array([0.30, 0.59, 0.11], dtype=np.float32)
    d = (((rgb[:, :, None, :] - pal[None, None, :, :]) ** 2) * wts).sum(-1)
    idx = d.argmin(-1)
    a[..., :3] = pal[idx].astype(np.uint8)
    a[..., 3] = np.where(a[..., 3] > 127, 255, 0).astype(np.uint8)
    return write_png(a, out or path)

def outline(path, hexcol="#1e120a", alpha=115, out=None):
    """Siluetin disina 1 px koyu hat ekler.

    art.js koninin iki yanina yari saydam koyu piksel koyuyor
    (`px(cx-r-1, yy, 'rgba(20,12,8,.35)')`). Seffaf zeminli sprite'ta ayni
    seyi alfa maskesini 1 px genisleterek yapiyoruz - sprite sahneye
    oturdugunda oyunun kendi cizimiyle ayni kenar okunur.
    """
    a = read_png(path)
    m = a[..., 3] > 127
    d = np.zeros_like(m)
    d[1:, :] |= m[:-1, :]
    d[:-1, :] |= m[1:, :]
    d[:, 1:] |= m[:, :-1]
    d[:, :-1] |= m[:, 1:]
    edge = d & ~m
    r, g, b = (int(hexcol.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4))
    a[edge] = [r, g, b, int(alpha)]
    return write_png(a, out or path)

def sheet(paths, cols, out, pad=0):
    """Kareleri tek sprite sheet'e dizer (seffaf zemin)."""
    ims = [read_png(p) for p in paths]
    fh, fw = ims[0].shape[:2]
    rows = (len(ims) + cols - 1) // cols
    W = cols * fw + pad * (cols - 1)
    H = rows * fh + pad * (rows - 1)
    canvas = np.zeros((H, W, 4), dtype=np.uint8)
    for i, im in enumerate(ims):
        r, c = divmod(i, cols)
        y, x = r * (fh + pad), c * (fw + pad)
        canvas[y:y + fh, x:x + fw] = im
    write_png(canvas, out)
    print("SHEET %s  %dx%d  (%d kare, %dx%d)" % (out, W, H, len(ims), fw, fh))
    return out

def contact(paths, cols, out, cell_bg="#2b1f14", pad=2, scale=1):
    """Denetim icin koyu zeminli, buyutulmus onizleme tablosu."""
    ims = [read_png(p) for p in paths]
    fh = max(i.shape[0] for i in ims)
    fw = max(i.shape[1] for i in ims)
    rows = (len(ims) + cols - 1) // cols
    W = (cols * fw + pad * (cols + 1)) * scale
    H = (rows * fh + pad * (rows + 1)) * scale
    bgc = [int(cell_bg.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)] + [255]
    canvas = np.zeros((H, W, 4), dtype=np.uint8)
    canvas[..., :] = bgc
    for i, im in enumerate(ims):
        r, c = divmod(i, cols)
        y = pad + r * (fh + pad)
        x = pad + c * (fw + pad)
        h0, w0 = im.shape[:2]
        big = np.repeat(np.repeat(im, scale, 0), scale, 1)
        ys, xs = y * scale, x * scale
        reg = canvas[ys:ys + h0 * scale, xs:xs + w0 * scale]
        al = big[..., 3:4].astype(np.float32) / 255.0
        reg[..., :3] = (big[..., :3] * al + reg[..., :3] * (1 - al)).astype(np.uint8)
    write_png(canvas, out)
    print("CONTACT %s  %dx%d" % (out, W, H))
    return out
