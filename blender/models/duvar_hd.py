"""DUVAR KAROSU + TAS KEMER BLOGU — remake HD ton dokulari.

    blender --background --factory-startup --python blender/models/duvar_hd.py
    (cikti dogrudan assets/remake/duvar/karo.png, tas.png)

art.js bakeBG: duvar 18 px karolardan (sehir paletinin 3 tonundan biri, ust/sol
isik, alt golge, %4.5 kirik karo), kemer kenarlari 23x13 tas bloklarindan
(sira kaydirmali, derz koyu, ust iki satir acik, alt iki koyu) ciziliyor.
Palet sehre ve boya yukseltmesine gore degistigi icin burada RENK yok: doku
yalniz TON tasir (R: isik 0..1, G: 1 = yuzey / 0 = derz). Renk shaders/duvar.gdshader
ve shaders/tas.gdshader'da paletten seciliyor.

  karo.png : 36x36 (tek karo, 17 px yuzey + 1 px derz, 2x)
  tas.png  : 46x26 (tek blok, 22x12 yuzey + derz, 2x) x 4 varyant yan yana (184x26)
"""
import sys, os, math, random
import bpy, bmesh
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import numpy as np

KOK = os.path.dirname(_HERE)
HEDEF = os.path.join(KOK, "assets", "remake", "duvar")
TMP = os.path.join(_HERE, "out", "duvar_hd")


def ton_malzeme(ad, maske=1.0):
    """Isik degeri (lambert) gri emission olarak; G kanali maske."""
    m = bpy.data.materials.new(ad)
    m.use_nodes = True
    n, l = m.node_tree.nodes, m.node_tree.links
    n.clear()
    dif = n.new("ShaderNodeBsdfDiffuse")
    s2r = n.new("ShaderNodeShaderToRGB")
    l.new(dif.outputs[0], s2r.inputs[0])
    bw = n.new("ShaderNodeRGBToBW")
    l.new(s2r.outputs[0], bw.inputs[0])
    comb = n.new("ShaderNodeCombineColor")
    l.new(bw.outputs[0], comb.inputs[0])
    comb.inputs[1].default_value = maske
    comb.inputs[2].default_value = 0.0
    em = n.new("ShaderNodeEmission")
    l.new(comb.outputs[0], em.inputs["Color"])
    out = n.new("ShaderNodeOutputMaterial")
    l.new(em.outputs[0], out.inputs["Surface"])
    return m


def sahne(w, h):
    px.reset()
    sc = bpy.context.scene
    px.setup(w * 2, h * 2, transparent=False)
    sc.view_settings.view_transform = "Standard"
    px.ortho_cam(w / 2.0, -h / 2.0, w, h)
    px.world("#000000", 0.0)
    d = Vector((0.45, 0.55, -0.70)).normalized()
    s = px.sun(math.pi, rot=(0, 0, 0))
    s.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def kutu_bevel(ad, x0, z0, w, h, derin, bevel, mat, bozul=0.0, tohum=0):
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x0 + w
        v.co.z = z0 if v.co.z < 0 else z0 + h
        v.co.y = 0.0 if v.co.y < 0 else derin
    bmesh.ops.bevel(bm, geom=bm.edges[:], offset=bevel, segments=3, affect="EDGES")
    if bozul > 0:
        bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=3, use_grid_fill=True)
        r = random.Random(tohum)
        for v in bm.verts:
            if v.co.y < derin * 0.5:
                v.co.y += (r.random() - 0.5) * bozul
    me = bpy.data.meshes.new(ad)
    bm.to_mesh(me)
    bm.free()
    for p in me.polygons:
        # genis on yuz duz golgelensin (yumusak normal yuzeye yastik gibi degrade yayiyordu)
        p.use_smooth = not (p.normal.y < -0.98 and p.area > 4.0)
    ob = bpy.data.objects.new(ad, me)
    bpy.context.collection.objects.link(ob)
    me.materials.append(mat)
    return ob


def render(yol):
    return px.render(yol)


def karo():
    sahne(18, 18)
    # derz: arka plan G=0 (dunya siyah zaten R=0,G=0); karo yuzeyi G=1
    M = ton_malzeme("Karo")
    kutu_bevel("karo", 1.0, -18.0, 17.0, 17.0, 2.0, 1.1, M)
    # sir yuzeyinde hafif dalgalanma: ince gurultu yok, yalniz kenar pahi
    yol = render(os.path.join(TMP, "karo.png"))
    return yol


def tas():
    parcalar = []
    for i in range(4):
        sahne(23, 13)
        M = ton_malzeme("Tas%d" % i)
        kutu_bevel("tas", 1.0, -13.0, 22.0, 12.0, 3.0, 1.4, M, bozul=0.9, tohum=11 + i * 7)
        yol = render(os.path.join(TMP, "tas_%d.png" % i))
        parcalar.append(yol)
    return parcalar


def main():
    os.makedirs(TMP, exist_ok=True)
    os.makedirs(HEDEF, exist_ok=True)
    k = karo()
    a = px.read_png(k)
    a[..., 3] = 255
    px.write_png(a, os.path.join(HEDEF, "karo.png"))
    t = tas()
    satirlar = [px.read_png(p) for p in t]
    birlesik = np.concatenate(satirlar, axis=1)
    birlesik[..., 3] = 255
    px.write_png(birlesik, os.path.join(HEDEF, "tas.png"))
    print("DUVAR_HD_DONE")


if __name__ == "__main__":
    main()
