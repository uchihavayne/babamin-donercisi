"""SOKAK ARKA PLANI — remake HD (art.js bakeStreet + drawBuilding + drawImza).

    blender --background --factory-startup --python blender/models/sokak_arka_hd.py [-- sehir_id ...]
    python blender/hd_atlas.py sokak_arka_hd sokak_arka

bakeStreet camin arkasindaki SABIT sokagi (gok, bulut, simge yapi, uzak
siluet, bina cepheleri, kaldirim, yol) sehir basina bir kez pisiriyor. Bina
yerlesimi yalniz hash1'e bagli, oyun durumundan bagimsiz: burada ayni yerlesim
(genislik, yukseklik, cati esyalari, pencere isiklari, tarz dallari) 3B
modelleniyor ve sehir basina tek 264x92 goruntu (2x) cikiyor.
Rakip dukkanin zemin kati (insaat / acik / kapali: gune ve hikayeye bagli) kodda
eski cizimle ustune basiliyor; burada o kat bos duvar.

Katmanlar (numpy ile birlestirilir): gok + bulutlar (numpy) -> simge yapi
(Blender, pusla) -> uzak siluet (numpy) -> binalar + zemin (Blender).
  sokak_<id>   capa LAY.glass (x, y)
"""
import sys, os, math, json, random
import bpy, bmesh
import numpy as np
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import logo as L
import istasyon_hd as I
import tezgah_hd as T
import durum_hd as D

KOK = os.path.dirname(_HERE)
OUT = os.path.join(_HERE, "out", "sokak_arka_hd")
HD = 2
K = 0.5
# BIRLESIK: cam olculeri yeni yerlesimden (yerlesim.py; remake 264x92)
import yerlesim as YER
GW, GH = YER.GL_W, YER.GL_H
BASE = 50                    # stM: base = glass.y + 50
ROAD_Y, ROAD_H, CURB2 = 58, 26, 84
ez, onkutu, hexmul = T.ez, T.onkutu, T.hexmul

BLD = [{"wall": "#c9a883", "trim": "#8a6a48", "awn": "#c0281c", "sign": "#2f4f6a"}, {"wall": "#a7bfcb", "trim": "#6d8492", "awn": "#2f6a8a", "sign": "#7a3a2a"}, {"wall": "#c8a0a6", "trim": "#8e6a70", "awn": "#3f8a4a", "sign": "#4a3a6a"}, {"wall": "#bfb491", "trim": "#867c60", "awn": "#b0862a", "sign": "#2f5f3a"}, {"wall": "#9fb0a4", "trim": "#6b7a70", "awn": "#8a3a6a", "sign": "#5a4a2a"}]
BLD_BETON = [{"wall": "#7a7e84", "trim": "#565a60", "awn": "#6a4a44", "sign": "#4a4e54"}, {"wall": "#6e7278", "trim": "#4a4e54", "awn": "#5a4440", "sign": "#3e4248"}, {"wall": "#868a90", "trim": "#5e6268", "awn": "#6a5450", "sign": "#52565c"}, {"wall": "#666a70", "trim": "#44484e", "awn": "#584442", "sign": "#3a3e44"}, {"wall": "#7e8288", "trim": "#5a5e64", "awn": "#644c48", "sign": "#464a50"}]
PED_SHIRT = ["#3f6fbd", "#8a4a7a", "#3f8a4a", "#b0602a", "#4a5560", "#a83a2a", "#2f8a8a", "#6a4a9a", "#c9a23a", "#7a3a3a", "#356a4a", "#5a6a8a"]
CEPHE_VARSAYILAN = {"boyAz": 24, "boyCok": 34, "genAz": 46, "genCok": 66, "tarz": "dukkan"}


def hash1(v):
    r = math.sin(v * 127.1) * 43758.5453
    return r - math.floor(r)


def sehirler():
    s = open(os.path.join(KOK, "data", "sehir.gd"), encoding="utf-8").read()
    s = s[s.index("const VALUE = ") + len("const VALUE = "):]
    s = s.replace("null", "None").replace("true", "True").replace("false", "False")
    return eval(s)


def rgb(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], np.float32) / 255.0


def karis(a, b, k):
    c = rgb(a) * (1 - k) + rgb(b) * k
    return "#%02x%02x%02x" % tuple(int(round(x * 255)) for x in c)


# ================================================================ malzemeler
_MAT = {}


def mat_ton(renk, f=(0.62, 0.8, 1.0, 1.12), stops=(0, .3, .5, .8), noise=0.0, ns=30):
    """Tek renkten 4 basamakli cel rampasi (onbellekli)."""
    k = ("t", renk, f, stops, noise)
    if k not in _MAT:
        _MAT[k] = I.cel("M%d" % len(_MAT), [hexmul(renk, x) for x in f], list(stops), noise=noise, noise_scale=ns)
    return _MAT[k]


def mat_duz(renk):
    k = ("d", renk)
    if k not in _MAT:
        _MAT[k] = px.flat("D%d" % len(_MAT), renk)
    return _MAT[k]


def mat_alfa(renk, a):
    k = ("a", renk, a)
    if k not in _MAT:
        _MAT[k] = px.flat_a("A%d" % len(_MAT), renk, a)
    return _MAT[k]


def kutu(x0, x1, gy0, gy1, y0, y1, mat, bevel=0.0):
    """On yuzu y0'da ekranda [gy0, gy1] duran kutu (istege bagli pah)."""
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    z0, z1 = ez(gy1, y0, K), ez(gy0, y0, K)
    for v in bm.verts:
        v.co.x = x0 if v.co.x < 0 else x1
        v.co.y = y0 if v.co.y < 0 else y1
        v.co.z = z0 if v.co.z < 0 else z1
    if bevel > 0:
        bmesh.ops.bevel(bm, geom=bm.edges[:], offset=bevel, segments=1, affect="EDGES")
    return I.mesh_ob("k", bm, mat, smooth=False)


def cerceve(x0, x1, gy0, gy1, t, y0, y1, mat, bevel=0.0):
    """Ortasi bos kutu cerceve (4 kenar): arkasindaki cam/kapi gorunur kalir."""
    kutu(x0, x1, gy0, gy0 + t, y0, y1, mat, bevel)
    kutu(x0, x1, gy1 - t, gy1, y0, y1, mat, bevel)
    kutu(x0, x0 + t, gy0 + t, gy1 - t, y0, y1, mat, bevel)
    kutu(x1 - t, x1, gy0 + t, gy1 - t, y0, y1, mat, bevel)


def on_levha(pts, y, mat):
    """Dikey on yuzde (derinlik y) ekran koseli ince levha."""
    return T.on_poligon("p", pts, y, mat, K, derin=0.05)


def zemin_poligon(pts, z, mat):
    return T.ust_poligon("z", pts, z, mat, K, kal=0.05)


def silindir_z(x, gy0, gy1, y, r, mat, seg=8):
    """Dikey silindir: ekranda gy0..gy1."""
    boy = gy1 - gy0
    return L.silindir("s", r, x, y, ez((gy0 + gy1) / 2.0, y, K), boy, mat, seg=seg, eksen="Z")


def silindir_x(x0, x1, gy, y, r, mat, seg=8):
    boy = x1 - x0
    return L.silindir("s", r, (x0 + x1) / 2.0, y, ez(gy, y, K), boy, mat, seg=seg, eksen="X")


def elipsoid(cx, gy, rx, ry, rd, y, mat, seg=12, ring=8):
    e = I.elipsoid("e", cx, gy, rx, ry, rd, y, mat, seg=seg, ring=ring)
    e.location = (cx, y, ez(gy, y, K))
    return e


# ================================================================ bina
def pencere(wx, wy, lit, trim, r):
    """bldWindow 9x10: trim cerceve, girintili cam (yanik: sicak ic, perde), hac kayit, denizlik."""
    cerceve(wx, wx + 9, wy, wy + 10, 1.0, -0.35, 0.4, mat_ton(trim))
    if lit:
        kutu(wx + 1, wx + 8, wy + 1, wy + 9, 0.55, 0.9, mat_duz("#ffdf9a"))
        kutu(wx + 1, wx + 8, wy + 1, wy + 2, 0.5, 0.9, mat_duz("#fff2c8"))
        if r.random() < 0.6:        # perde
            kutu(wx + 1, wx + 3, wy + 1, wy + 9, 0.45, 0.9, mat_ton("#e8b45a", f=(0.8, 0.95, 1.0, 1.05)))
    else:
        kutu(wx + 1, wx + 8, wy + 1, wy + 9, 0.55, 0.9, mat_duz("#6f95a8"))
        on_levha([(wx + 1, wy + 1), (wx + 8, wy + 1), (wx + 8, wy + 4.5), (wx + 1, wy + 4.5)], 0.5, mat_duz("#8fb3c4"))
        on_levha([(wx + 5.2, wy + 1.2), (wx + 6.4, wy + 1.2), (wx + 3.4, wy + 8.8), (wx + 2.2, wy + 8.8)], 0.48, mat_alfa("#dff0fa", 0.5))
    kutu(wx + 4.2, wx + 4.8, wy + 1, wy + 9, 0.1, 0.5, mat_ton(trim))
    kutu(wx + 1, wx + 8, wy + 4.7, wy + 5.3, 0.1, 0.5, mat_ton(trim))
    kutu(wx - 1, wx + 10, wy + 9, wy + 10.2, -1.2, 0.2, mat_ton("#e8e2d4", f=(0.7, 0.86, 1.0, 1.06)), bevel=0.15)


def cati_esyalari(bx, bw, top, i, B):
    trim = B["trim"]
    Mt = mat_ton(trim)
    if hash1(i * 11.3) > 0.5:                       # baca
        chx = bx + 6 + math.floor(hash1(i * 2.2) * (bw - 16))
        kutu(chx, chx + 6, top - 11, top - 4, 1.0, 4.0, Mt, bevel=0.2)
        kutu(chx - 1, chx + 7, top - 12, top - 10.4, 0.6, 4.4, mat_ton(hexmul(trim, 1.2)), bevel=0.2)
        kutu(chx + 1.5, chx + 4.5, top - 12.3, top - 11.9, 1.4, 3.4, mat_duz("#2b2420"))
    if hash1(i * 4.7) > 0.45:                       # su deposu
        wtx = bx + bw - 16 - math.floor(hash1(i * 3.3) * 8)
        Md = mat_ton("#9a8a72", noise=0.05)
        L.silindir("depo", 2.6, wtx + 3.6, 3.0, ez(top - 6.6, 3.0, K), 7.2, Md, seg=14, eksen="X")
        for lx in (wtx + 1, wtx + 6):
            kutu(lx, lx + 0.8, top - 4.5, top - 1, 2.6, 3.4, mat_duz("#5a4a3a"))
    if hash1(i * 8.9) > 0.55:                       # canak anten
        stx = bx + 8 + math.floor(hash1(i * 6.7) * (bw - 20))
        silindir_z(stx, top - 4.5, top, 2.0, 0.35, mat_duz("#8f979f"))
        e = elipsoid(stx, top - 6, 3.0, 3.0, 0.9, 1.2, mat_ton("#d9dcdf", f=(0.7, 0.86, 1.0, 1.08)), seg=16, ring=8)
        e.rotation_euler = (0, 0, math.radians(-25))
        elipsoid(stx + 1.6, top - 6.8, 0.5, 0.5, 0.5, 0.2, mat_duz("#5a636b"), seg=6, ring=4)
    if hash1(i * 12.1) > 0.6:                       # tv anteni
        atx = bx + 4 + math.floor(hash1(i * 9.9) * (bw - 10))
        Ma = mat_duz("#8f979f")
        kutu(atx, atx + 0.6, top - 12, top, 2.0, 2.6, Ma)
        for gy in (top - 10, top - 7):
            kutu(atx - 2.2, atx + 2.8, gy, gy + 0.5, 2.0, 2.4, Ma)
    if hash1(i * 15.7) > 0.66:                      # camasir ipi
        lx0, lx1 = bx + 5, bx + bw - 6
        kutu(lx0, lx1, top - 3.2, top - 2.8, -2.2, -2.0, mat_duz("#d8d0b8"))
        for cw2 in range(4):
            cx3 = lx0 + 4 + cw2 * max(5, math.floor((lx1 - lx0 - 8) / 3))
            if cx3 > lx1 - 3:
                break
            renk = PED_SHIRT[(i * 3 + cw2) % len(PED_SHIRT)]
            kutu(cx3, cx3 + 3, top - 3, top + 1.2, -2.4, -2.1, mat_ton(renk, f=(0.7, 0.86, 1.0, 1.1)))


def cephe_tarzi(bx, bw, bh, top, by, i, B, tarz):
    if tarz == "gokdelen":
        for gv in range(3, int(bw - 2), 5):
            kutu(bx + gv, bx + gv + 0.7, top + 2, by - 15, -0.35, 0.1, mat_ton(hexmul(B["wall"], 1.25), f=(0.7, 0.9, 1.0, 1.08)))
        if hash1(i * 6.7) > 0.45:                   # yangin merdiveni
            ym = bx + 2 + math.floor(hash1(i * 2.1) * (bw - 8))
            Mm = mat_duz("#3a3f46")
            kutu(ym, ym + 0.6, top + 5, by - 16, -1.6, -1.2, Mm)
            kutu(ym + 6.4, ym + 7, top + 5, by - 16, -1.6, -1.2, Mm)
            yk = top + 6
            while yk < by - 16:
                kutu(ym, ym + 7, yk, yk + 0.6, -1.6, -1.2, Mm)
                yk += 7
    elif tarz == "cam":
        cb = top + 2
        Mc = mat_ton("#6aa0bc", f=(0.7, 0.88, 1.0, 1.1))
        while cb < by - 15:
            kutu(bx + 1, bx + bw - 2, cb + 1, cb + 2.6, -0.2, 0.2, Mc)
            kutu(bx + 1, bx + bw - 2, cb + 2.6, cb + 3, -0.3, 0.2, mat_ton("#bfe4f2"))
            cb += 3
        for q in range(0, int(bh), 6):
            x = bx + 2 + (q * 3) % max(1, bw - 5)
            on_levha([(x, top + q), (x + 1.2, top + q), (x + 0.2, top + q + 3), (x - 1, top + q + 3)], -0.35, mat_alfa("#ffffff", 0.35))
    elif tarz == "mansart":
        Mr = mat_ton(hexmul(B["trim"], 0.62), f=(0.6, 0.8, 1.0, 1.15), noise=0.06)
        bm = bmesh.new()
        # egimli cati: saçak (top-4) onde, sirt (top-9) geride
        x0, x1 = bx, bx + bw
        on_y, arka_y = -1.0, 5.0
        a = [bm.verts.new((x0, on_y, ez(top - 4, on_y, K))), bm.verts.new((x1, on_y, ez(top - 4, on_y, K))),
             bm.verts.new((x1 - 4, arka_y, ez(top - 9, arka_y, K))),
             bm.verts.new((x0 + 4, arka_y, ez(top - 9, arka_y, K)))]
        bm.faces.new(a)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        f = bm.faces[0]
        if f.normal.y > 0:
            f.normal_flip()
        I.mesh_ob("mansart", bm, Mr, smooth=False)
        if bw > 24:
            dx = bx + bw // 2
            kutu(dx - 3, dx + 3, top - 8, top - 4, -1.2, 1.0, mat_ton(hexmul(B["trim"], 0.5)), bevel=0.2)
            kutu(dx - 2, dx + 2, top - 7, top - 4.6, -1.3, 0.0, mat_duz("#8fb4c8"))
            bm = bmesh.new()
            p = [bm.verts.new((dx - 3.6, -1.4, ez(top - 8, -1.4, K))), bm.verts.new((dx + 3.6, -1.4, ez(top - 8, -1.4, K))),
                 bm.verts.new((dx, -1.4, ez(top - 10, -1.4, K)))]
            bm.faces.new(p)
            I.mesh_ob("alinlik", bm, mat_ton(hexmul(B["trim"], 0.45)), smooth=False)
    elif tarz == "beton":
        for bk in range(int(top + 4), int(by - 2), 7):
            kutu(bx + 1, bx + bw - 2, bk, bk + 0.5, -0.12, 0.1, mat_duz(karis(B["wall"], "#3e4248", 0.35)))
            kutu(bx + 1, bx + bw - 2, bk + 0.5, bk + 1, -0.1, 0.1, mat_duz(karis(B["wall"], "#c8ccd0", 0.14)))
        for bd in range(6, int(bw - 4), 12):
            kutu(bx + bd, bx + bd + 0.5, top + 2, by - 2, -0.12, 0.1, mat_duz(karis(B["wall"], "#2e3238", 0.2)))
        for sl in range(3):
            if hash1(i * 9.1 + sl * 4.3) < 0.45:
                continue
            slx = bx + 3 + math.floor(hash1(i * 2.7 + sl) * (bw - 8))
            slh = 6 + math.floor(hash1(i * 5.1 + sl) * 14)
            h = min(slh, bh - 3)
            on_levha([(slx, top + 1), (slx + 2, top + 1), (slx + 1.4, top + 1 + h), (slx + 0.6, top + 1 + h)], -0.15, mat_alfa("#2a2e34", 0.22))
        if hash1(i * 13.7) > 0.52 and bw >= 26:     # pankart
            ax = bx + math.floor((bw - 14) / 2)
            ah = min(bh - 6, 20 + math.floor(hash1(i * 3.9) * 8))
            Mb = mat_ton("#9e2016", f=(0.62, 0.8, 1.0, 1.14), noise=0.05)
            bm = bmesh.new()
            V = []
            for j in range(9):
                v = j / 8
                sat = []
                for u in (0.0, 0.5, 1.0):
                    y = -0.6 - 0.35 * math.sin(u * math.pi) * (0.4 + v)
                    sat.append(bm.verts.new((ax + u * 13, y, ez(top + 2 + v * ah, y, K))))
                V.append(sat)
            for j in range(8):
                for c in range(2):
                    bm.faces.new((V[j + 1][c], V[j + 1][c + 1], V[j][c + 1], V[j][c]))
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
            for fc in bm.faces:
                if fc.normal.y > 0:
                    fc.normal_flip()
            I.mesh_ob("pankart", bm, Mb, smooth=True)
            kutu(ax - 0.5, ax + 13.5, top + 1.4, top + 2.2, -1.2, -0.4, mat_duz("#5a3a2a"))
            Mk = mat_duz("#e8dcb0")
            sy0 = top + 6
            yildiz = [(6.5, 0), (7.4, 2.2), (9.6, 2.2), (7.9, 3.5), (8.6, 5.6), (6.5, 4.3), (4.4, 5.6), (5.1, 3.5), (3.4, 2.2), (5.6, 2.2)]
            on_levha([(ax + px_, sy0 - 0.5 + py_) for px_, py_ in yildiz], -1.35, Mk)
            ay0 = sy0 + 7
            while ay0 < top + ah - 2:
                on_levha([(ax + 3, ay0), (ax + 11, ay0), (ax + 11, ay0 + 0.7), (ax + 3, ay0 + 0.7)], -1.2, mat_alfa("#e8dcb0", 0.7))
                ay0 += 3
            for pk in range(0, 13, 3):
                on_levha([(ax + pk, top + 2 + ah), (ax + pk + 1.4, top + 2 + ah), (ax + pk + 0.7, top + 3.6 + ah)], -0.9, mat_duz("#6e1a12"))
    elif tarz == "tabela":
        for tb in range(3):
            if hash1(i * 5.3 + tb * 2.7) < 0.42:
                continue
            tbx = bx + 3 + tb * max(6, (bw - 8) / 3)
            tby = top + 4 + math.floor(hash1(i + tb) * 6)
            tbh = 8 + math.floor(hash1(i * 3.1 + tb) * 10)
            if tby + tbh > by - 6:
                tbh = max(6, by - 6 - tby)
            tc = ["#e2483a", "#f0b03a", "#3fa8c0", "#8ac04a"][(i + tb) % 4]
            kutu(tbx, tbx + 5, tby, tby + tbh, -3.0, -0.8, mat_ton(tc, f=(0.55, 0.8, 1.0, 1.15)), bevel=0.3)
            kutu(tbx + 2, tbx + 3, tby - 1.2, tby, -1.2, 0.0, mat_duz("#3a3a40"))
            for tp in range(2, int(tbh) - 1, 3):
                kutu(tbx + 1.2, tbx + 3.8, tby + tp - 0.2, tby + tp + 1.2, -3.1, -3.0, mat_duz("#ffffff"))


def zemin_kat(bx, bw, by, i, B, tarz):
    gyy = by - 15
    wall = B["wall"]
    if tarz in ("gokdelen", "cam"):
        kutu(bx + 1, bx + bw - 1, by - 15, by, -0.4, 0.5, mat_ton(hexmul(wall, 0.62)), bevel=0.2)
        for lg in range(2, int(bw - 3), 5):
            kutu(bx + lg, bx + lg + 4, by - 13, by - 1, -0.5, 0.5, mat_duz("#2b3a44"))
            kutu(bx + lg + 0.6, bx + lg + 3.4, by - 12.4, by - 1.6, -0.3, 0.5, mat_ton("#4a7a92", f=(0.8, 0.92, 1.0, 1.08)))
            on_levha([(bx + lg + 0.6, by - 12.4), (bx + lg + 3.4, by - 12.4), (bx + lg + 3.4, by - 11.6), (bx + lg + 0.6, by - 11.6)], -0.35, mat_alfa("#bfe4f2", 0.45))
        cx = bx + bw // 2
        kutu(cx - 6, cx + 6, by - 16.5, by - 14.8, -4.0, 0.0, mat_ton(B["trim"]), bevel=0.25)
        return
    if tarz == "beton":
        kutu(bx + 1, bx + bw - 1, gyy - 6, by, 0.9, 1.4, mat_ton(hexmul(wall, 0.72)))
        kutu(bx + 3, bx + bw - 4, gyy - 6, gyy - 1, -1.2, 0.2, mat_duz("#3e4248"), bevel=0.2)
        kutu(bx + 3.4, bx + bw - 4.6, gyy - 5.6, gyy - 1.8, -1.3, 0.2, mat_ton(B["sign"], f=(0.7, 0.88, 1.0, 1.1)))
        for lv in range(int(bx + 6), int(bx + bw - 9), 5):
            kutu(lv, lv + 3, gyy - 4.2, gyy - 3.2, -1.4, -1.2, mat_alfa("#c8ccd0", 0.6))
        if hash1(i * 7.7) > 0.45:               # kepenkli dukkan
            kutu(bx + 3, bx + bw - 4, gyy, gyy + 14, 0.2, 0.8, mat_duz("#4e5258"))
            for kk in range(1, 14, 2):
                kutu(bx + 3, bx + bw - 4, gyy + kk, gyy + kk + 0.8, 0.0, 0.8, mat_ton("#5e6268", f=(0.6, 0.8, 1.0, 1.1)))
            kutu(bx + 3, bx + bw - 4, gyy + 13, gyy + 15, -0.2, 0.8, mat_ton("#33373d"))
            hx = bx + bw // 2
            kutu(hx - 1.5, hx + 1.5, gyy + 12.4, gyy + 14.2, -0.5, 0.0, mat_ton("#7a7e84"))
        else:                                   # karanlik giris + korkuluk
            kutu(bx + 3, bx + bw - 4, gyy, gyy + 14, 0.5, 0.9, mat_duz("#242830"))
            for rf in range(3, 12, 4):
                kutu(bx + 5, bx + bw - 6, gyy + rf, gyy + rf + 0.5, 0.3, 0.5, mat_alfa("#4a4e54", 0.5))
            kutu(bx + 5, bx + 10, gyy + 4, gyy + 15, -0.2, 0.5, mat_ton("#454a50"), bevel=0.2)
            qx = bx + 12
            if qx + 12 < bx + bw - 4:
                Mq = mat_ton("#7a7e84", f=(0.6, 0.85, 1.0, 1.15))
                silindir_z(qx + 0.5, gyy + 9, gyy + 15, -1.0, 0.45, Mq)
                silindir_z(qx + 11.5, gyy + 9, gyy + 15, -1.0, 0.45, Mq)
                silindir_x(qx, qx + 12, gyy + 10.3, -1.0, 0.45, Mq)
        return
    # dukkan / tabela / blok / mansart: tabela bandi, tente, vitrin, mal, kapi
    Ms = mat_ton(B["sign"], f=(0.62, 0.82, 1.0, 1.18))
    kutu(bx + 2, bx + bw - 3, gyy - 6, gyy, -1.4, 0.4, Ms, bevel=0.3)
    s = bx + 5
    while s < bx + bw - 6:
        w = min(4, bx + bw - 7 - s)
        renk = "#ffd77a" if hash1(s * 1.7 + i) > 0.5 else "#f2ece0"
        kutu(s, s + w, gyy - 4.2, gyy - 2.2, -1.55, -1.3, mat_duz(renk))
        s += 6
    # tente: duvardan (y=0, gy=gyy) one (y=-4, gy=gyy+5) egimli seritler + fistolu etek
    awn = B["awn"]
    Ma = mat_ton(awn, f=(0.6, 0.82, 1.0, 1.12))
    Mb = mat_ton("#f2ece0", f=(0.68, 0.86, 1.0, 1.04))
    x0 = bx + 2
    x1 = bx + bw - 2
    dy = -4.0
    sx = x0
    while sx < x1:
        e = min(3, x1 - sx)
        band = int((sx - x0) // 6) % 2
        M = Ma if band else Mb
        bm = bmesh.new()
        v = [bm.verts.new((sx, 0.0, ez(gyy, 0.0, K))), bm.verts.new((sx + e, 0.0, ez(gyy, 0.0, K))),
             bm.verts.new((sx + e, dy, ez(gyy + 4.2, dy, K))), bm.verts.new((sx, dy, ez(gyy + 4.2, dy, K)))]
        bm.faces.new(v)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
        if bm.faces[0].normal.z < 0:
            bm.faces[0].normal_flip()
        I.mesh_ob("tente", bm, M, smooth=False)
        # etek: ust duz, alt yarim fisto (her 6 px'lik bandin ilk yarisi)
        etek = [(sx, gyy + 4.2), (sx + e, gyy + 4.2), (sx + e, gyy + 5.4)]
        for k in range(1, 6):
            a = math.pi * k / 5
            etek.append((sx + e / 2.0 + math.cos(a) * e / 2.0, gyy + 5.4 + math.sin(a) * 1.1))
        on_levha(etek, dy - 0.02, M)
        sx += e
    # tente golgesi ve vitrin
    vy = gyy + 7
    vh = by - vy - 1
    cerceve(bx + 3, bx + bw - 4, vy, vy + vh, 1.0, -0.25, 0.5, mat_ton("#2f3d47"))
    cam = "#9fc0d0" if hash1(i * 2.9) > 0.5 else "#b8ccd6"
    kutu(bx + 4, bx + bw - 5, vy + 1, vy + vh - 1, 0.35, 0.8, mat_duz(hexmul(cam, 0.92)))
    for m in range(3):
        mx = bx + 6 + m * 7
        if mx + 3 > bx + bw - 6:
            break
        renk = ["#c0281c", "#e0a83a", "#3f8a4a"][(i + m) % 3]
        kutu(mx, mx + 3, by - 4, by - 1, 0.1, 0.34, mat_ton(renk, f=(0.7, 0.86, 1.0, 1.12)), bevel=0.2)
    on_levha([(bx + 6, vy + 1), (bx + 10, vy + 1), (bx + 10 + vh - 2, vy + vh - 1), (bx + 6 + vh - 2, vy + vh - 1)], 0.0, mat_alfa("#ffffff", 0.3))
    on_levha([(bx + 3, gyy + 5.6), (bx + bw - 4, gyy + 5.6), (bx + bw - 4, gyy + 7.6), (bx + 3, gyy + 7.6)], -0.3, mat_alfa("#000000", 0.28))
    dx0 = bx + bw - 12
    cerceve(dx0, dx0 + 9, vy, vy + vh + 2, 1.0, -0.45, 0.5, mat_ton(hexmul(B["trim"], 0.7)))
    kutu(dx0 + 1, dx0 + 8, vy + 1, vy + vh + 1, 0.2, 0.6, mat_ton("#7a5f42", noise=0.06))
    kutu(dx0 + 2, dx0 + 7, vy + 2, vy + 5.5, 0.1, 0.3, mat_duz("#a8c6d4"))
    elipsoid(dx0 + 6.3, vy + round(vh * 0.6), 0.5, 0.5, 0.3, -0.05, mat_duz("#f0d78a"), seg=6, ring=4)


def bina(bx, by, bw, bh, i, tarz, rakip=False):
    tarz = tarz or "dukkan"
    B = (BLD_BETON if tarz == "beton" else BLD)[i % len(BLD)]
    top = by - bh
    wall = B["wall"]
    duvar = mat_ton(wall, f=(0.62, 0.84, 1.0, 1.1), noise=0.05, ns=24)
    if tarz == "beton":
        duvar = mat_ton(karis(wall, "#6e7278", 0.55), f=(0.62, 0.84, 1.0, 1.08), noise=0.07, ns=18)
    kutu(bx, bx + bw, top, by, 0.0, 6.0, duvar, bevel=0.4)
    r = random.Random(int(i * 97 + 13))
    for d in range(26):                               # siva lekeleri
        x = bx + 2 + hash1(i * 7 + d * 3.1) * (bw - 8)
        y = top + 3 + hash1(i * 3 + d * 5.7) * (bh - 8)
        w = 3 + hash1(d) * 6
        on_levha([(x, y), (x + w, y), (x + w, y + 0.6), (x, y + 0.6)], -0.02, mat_alfa("#ffffff" if d % 2 else "#000000", 0.07))
    cephe_tarzi(bx, bw, bh, top, by, i, B, tarz)
    # korniş
    kutu(bx - 2, bx + bw + 2, top - 4, top, -1.6, 1.0, mat_ton(B["trim"], f=(0.62, 0.85, 1.0, 1.25)), bevel=0.35)
    on_levha([(bx - 1, top), (bx + bw + 1, top), (bx + bw + 1, top + 1.2), (bx - 1, top + 1.2)], -0.04, mat_alfa("#000000", 0.3))
    cati_esyalari(bx, bw, top, i, B)
    cols = max(2, math.floor((bw - 6) / 14))
    step = (bw - 6) / cols
    floors = math.floor((bh - 20) / 13)
    for f in range(max(0, floors)):
        wy = top + 5 + f * 13
        if wy + 10 > by - 15:
            break
        for c in range(cols):
            wx = bx + 3 + math.floor(c * step + 0.5) + math.floor((step - 9) / 2 + 0.5)
            lit = hash1(i * 13 + f * 5.3 + c * 2.7) > 0.52
            pencere(wx, wy, lit, B["trim"], r)
        if f == 0 and hash1(i * 6.1) > 0.55:          # balkon
            byy = wy + 11
            Mk = mat_ton(hexmul(B["trim"], 1.1))
            kutu(bx + 3, bx + bw - 4, byy, byy + 2, -3.0, 0.2, Mk, bevel=0.25)
            rr = bx + 4
            while rr < bx + bw - 5:
                kutu(rr, rr + 0.5, byy - 4, byy, -2.8, -2.4, mat_ton(hexmul(B["trim"], 0.9)))
                rr += 3
            kutu(bx + 3, bx + bw - 4, byy - 4.4, byy - 3.8, -3.0, -2.2, mat_ton(hexmul(B["trim"], 1.3)))
    if hash1(i * 4.9) > 0.45:                         # yagis borusu
        Mp = mat_ton(hexmul(wall, 0.8), f=(0.6, 0.85, 1.0, 1.2))
        silindir_z(bx + bw - 2.5, top, by, -0.6, 0.75, Mp)
        pb = top + 8
        while pb < by:
            kutu(bx + bw - 4, bx + bw - 1, pb, pb + 1.4, -1.5, 0.0, mat_ton(hexmul(wall, 0.55)))
            pb += 14
    if hash1(i * 8.7) > 0.6:                          # klima
        ax, ay = bx + 4, top + 20
        kutu(ax, ax + 7, ay, ay + 5, -2.4, 0.0, mat_ton("#c2c9d0", f=(0.66, 0.84, 1.0, 1.08)), bevel=0.3)
        for gx in (ax + 2, ax + 4):
            kutu(gx, gx + 0.6, ay + 1, ay + 4, -2.5, -2.3, mat_duz("#8f979f"))
        on_levha([(ax, ay + 5), (ax + 7, ay + 5), (ax + 7, ay + 6), (ax, ay + 6)], -0.03, mat_alfa("#000000", 0.25))
    if rakip:
        return                                        # zemin kat kodda (rakipZemin)
    zemin_kat(bx, bw, by, i, B, tarz)
    if tarz in ("gokdelen", "cam", "beton"):
        on_levha([(bx, by - 1), (bx + bw, by - 1), (bx + bw, by), (bx, by)], -0.5, mat_alfa("#000000", 0.3))


def yerlesim(tema):
    CP = tema.get("cephe") or CEPHE_VARSAYILAN
    out = []
    bx, bi = -16, 0
    while bx < GW + 10:
        bw = CP["genAz"] + math.floor(hash1(bi * 4.3) * (CP["genCok"] - CP["genAz"]))
        en_yuksek = BASE - 16
        bh = CP["boyAz"] + math.floor(hash1(bi * 9.1) * max(1, CP["boyCok"] - CP["boyAz"]))
        bh = min(bh, en_yuksek)
        rakip = bi == 3 and CP["tarz"] == "dukkan"
        if rakip:
            bw = 58
            bh = min(bh, 30)
        out.append((bx, bw, bh, bi, rakip))
        bx += bw + 3
        bi += 1
    return out, CP["tarz"]


# ================================================================ zemin (kaldirim, yol)
def zemin(tema):
    kal = tema["kaldirim"]
    Mk = mat_ton(kal, f=(0.72, 0.88, 1.0, 1.06), noise=0.06, ns=40)
    Z = -BASE
    # ust kaldirim (base+1 .. base+7), bordur (base+7 .. base+9), yol, alt bordur, alt kaldirim
    zemin_poligon([(-2, BASE), (GW + 2, BASE), (GW + 2, BASE + 7), (-2, BASE + 7)], Z, Mk)
    for s1 in range(-3, GW, 13):
        x = s1 + (5 if int(s1 / 13) % 2 else 0)
        zemin_poligon([(x, BASE + 1), (x + 0.5, BASE + 1), (x + 0.5, BASE + 7), (x, BASE + 7)], Z + 0.06, mat_duz("#a9b0b7"))
    zemin_poligon([(-2, BASE + 3.8), (GW + 2, BASE + 3.8), (GW + 2, BASE + 4.2), (-2, BASE + 4.2)], Z + 0.06, mat_alfa("#8a9198", 0.5))
    # bordur tasi: ust yuz + on yuz
    kutu(-2, GW + 2, BASE + 7.4, BASE + 9, -14.0 - 0.8, -13.0, mat_ton("#a3aab1", f=(0.62, 0.82, 1.0, 1.12)), bevel=0.3)
    yol = tema["yol"]
    My = mat_ton(yol, f=(0.8, 0.92, 1.0, 1.06), noise=0.12, ns=90)
    Zy = Z - 1.6
    zemin_poligon([(-2, ROAD_Y + 0.4), (GW + 2, ROAD_Y + 0.4), (GW + 2, CURB2), (-2, CURB2)], Zy, My)
    for x0, y0, w, h in ((150, ROAD_Y + 4, 40, 9), (40, ROAD_Y + 15, 26, 6)):   # yama asfalt
        zemin_poligon([(x0, y0), (x0 + w, y0 + 0.5), (x0 + w - 1, y0 + h), (x0 + 1, y0 + h - 0.5)], Zy + 0.05, mat_ton(hexmul(yol, 0.85), f=(0.85, 0.95, 1.0, 1.04), noise=0.1, ns=70))
    rg = random.Random(21)
    for _ in range(9):                                 # catlaklar
        x, y = rg.uniform(5, GW - 20), rg.uniform(ROAD_Y + 3, CURB2 - 3)
        pts = [(x, y)]
        for k in range(4):
            x += rg.uniform(2, 5)
            y += rg.uniform(-1.2, 1.2)
            pts.append((x, y))
        for a, b in zip(pts, pts[1:]):
            T.ust_cizgi("catlak", a[0], a[1], b[0], b[1], 0.35, Zy + 0.08, mat_duz(hexmul(yol, 0.7)), K)
    orta = ROAD_Y + round(ROAD_H / 2) - 1
    for dsh in range(3, GW, 20):
        zemin_poligon([(dsh, orta), (dsh + 11, orta), (dsh + 11, orta + 2), (dsh, orta + 2)], Zy + 0.1, mat_ton("#d9cf98", f=(0.9, 0.97, 1.0, 1.08), noise=0.15, ns=60))
    for zb in range(5):
        x = 196 + zb * 8
        zemin_poligon([(x, ROAD_Y + 1), (x + 5, ROAD_Y + 1), (x + 5, CURB2 - 1), (x, CURB2 - 1)], Zy + 0.1, mat_ton("#e8ecf0", f=(0.86, 0.95, 1.0, 1.02), noise=0.12, ns=50))
    # rogar kapagi
    I.yatay_elips("rogar", 118, ROAD_Y + 20, 3.2, 0.1, mat_ton("#3a3d42", noise=0.2, ns=80), K, ry_ekran=1.4, seg=20).location = (118, (-(ROAD_Y + 20) - (Zy + 0.1)) / K, Zy + 0.1)
    # alt bordur + kaldirim
    kutu(-2, GW + 2, CURB2, CURB2 + 2, -66.4, -65.4, mat_ton("#a3aab1", f=(0.62, 0.82, 1.0, 1.12)), bevel=0.3)
    zemin_poligon([(-2, CURB2 + 2), (GW + 2, CURB2 + 2), (GW + 2, GH + 2), (-2, GH + 2)], Z - 0.8, Mk)
    for s2 in range(5, GW, 15):
        zemin_poligon([(s2, CURB2 + 2), (s2 + 0.5, CURB2 + 2), (s2 + 0.5, GH + 2), (s2, GH + 2)], Z - 0.74, mat_duz("#9aa1a8"))


def hoparlor_diregi():
    """Beton sehir: direk + iki boru hoparlor (bakeStreet'in 'beton' dali)."""
    hx = round(GW * 0.34)
    hb = BASE + 2
    Md = mat_ton("#5a5e64", f=(0.66, 0.84, 1.0, 1.2))
    silindir_z(hx + 1, hb - 40, hb, -4.0, 0.9, Md)
    kutu(hx - 5, hx + 7, hb - 39.5, hb - 38.7, -4.6, -3.4, Md)
    for yon in (-1, 1):
        ux = hx + 1 + yon * 5
        c = L.silindir("boru", 2.2, ux + yon * 2.2, -4.0, ez(hb - 44, -4.0, K), 5.0, mat_ton("#5a5e64", f=(0.55, 0.8, 1.0, 1.2)),
                       seg=12, eksen="X", r2=0.6)
        c.rotation_euler = (0, math.radians(90 if yon < 0 else -90), 0)
    kutu(hx - 1, hx + 3, hb - 41, hb - 38, -4.8, -3.2, Md, bevel=0.2)


# ================================================================ simge yapilar (uzakta, pusla)
def imza(ad):
    cx = round(GW * 0.7)
    Y = lambda h: BASE - h
    M1 = mat_ton("#4c6678", f=(0.72, 0.88, 1.0, 1.1))
    M2 = mat_ton("#40566a", f=(0.72, 0.88, 1.0, 1.1))
    Mi = mat_duz("#fcf2c4")
    y0 = 40.0
    if ad == "galata":
        torna_ = T.torna
        torna_("govde", [(6.5, 0), (6.5, 38)], cx + 0.5, BASE, y0, 1.0, M1, K, seg=20)
        for k in range(3):
            kutu(cx - 3 + k * 3, cx - 2 + k * 3, Y(30), Y(28), y0 - 6.6, y0 - 6.4, Mi)
        torna_("sepet", [(7.5, 0), (7.5, 3)], cx + 0.5, Y(38), y0, 1.0, M2, K, seg=20)
        torna_("kulah", [(6.8, 0), (0.2, 8)], cx + 0.5, Y(41), y0, 1.0, M2, K, seg=20)
        silindir_z(cx + 0.5, Y(52), Y(49), y0, 0.3, M2)
        for mx in (cx - 18, cx + 17):
            torna_("minare", [(1.5, 0), (1.5, 36)], mx + 0.5, BASE, y0 + 6, 1.0, M1, K, seg=12)
            torna_("serefe", [(3.2, 0), (3.2, 2)], mx + 0.5, Y(36), y0 + 6, 1.0, M2, K, seg=12)
            torna_("kulah", [(1.5, 0), (0.1, 7)], mx + 0.5, Y(39), y0 + 6, 1.0, M2, K, seg=12)
    elif ad == "kule":
        silindir_z(cx, Y(36), BASE, y0, 2.0, M1, seg=14)
        elipsoid(cx, Y(40), 7, 7, 7, y0, M2, seg=20, ring=12)
        kutu(cx - 4, cx + 4, Y(41.5), Y(40.5), y0 - 7.2, y0 - 7.0, mat_alfa("#e8f2f8", 0.5))
        kutu(cx - 2.5, cx - 1.5, Y(41.5), Y(40.5), y0 - 7.4, y0 - 7.2, Mi)
        kutu(cx + 1.5, cx + 2.5, Y(41.5), Y(40.5), y0 - 7.4, y0 - 7.2, Mi)
        silindir_z(cx + 0.5, Y(56), Y(47), y0, 1.2, M2, seg=10)
        silindir_z(cx + 0.5, Y(60), Y(55), y0, 0.35, M2, seg=6)
    elif ad == "saat":
        kutu(cx - 6, cx + 7, Y(36), BASE, y0, y0 + 13, M1)
        kutu(cx - 7, cx + 8, Y(39), Y(36), y0 - 0.8, y0 + 13.8, M2, bevel=0.3)
        L.silindir("kadran", 4.0, cx + 0.5, y0 - 0.9, ez(Y(35), y0 - 0.9, K), 0.4, mat_ton("#fcf4ce", f=(0.8, 0.92, 1.0, 1.04)), seg=20, eksen="Y")
        kutu(cx + 0.2, cx + 0.8, Y(38), Y(35), y0 - 1.3, y0 - 1.1, M2)
        kutu(cx + 0.5, cx + 2.6, Y(35.3), Y(34.7), y0 - 1.3, y0 - 1.1, M2)
        for k in range(5):
            w = 13 - k * 2.5
            kutu(cx + 0.5 - w / 2, cx + 0.5 + w / 2, Y(43 + k), Y(42 + k), y0 + k * 1.2, y0 + 13 - k * 1.2, M2)
        silindir_z(cx + 0.5, Y(52), Y(47), y0 + 6.5, 0.35, M2, seg=6)
    elif ad == "kafes":
        for yy in range(0, 46):
            g2 = round(13 * (1 - yy / 46) ** 1.7) + 1
            for sx in (-1, 1):
                kutu(cx + sx * g2 - 0.5, cx + sx * g2 + 0.5, Y(yy + 1), Y(yy), y0, y0 + 1, M1)
            if yy % 11 == 0:
                kutu(cx - g2, cx + g2, Y(yy + 1), Y(yy), y0 - 0.2, y0 + 1.2, M2)
        for yy in range(2, 44, 3):                      # kafes caprazlari
            g2 = round(13 * (1 - yy / 46) ** 1.7) + 1
            T.on_poligon("capraz", [(cx - g2, Y(yy)), (cx - g2 + 0.6, Y(yy)), (cx + g2, Y(yy + 3)), (cx + g2 - 0.6, Y(yy + 3))], y0 + 0.4, mat_alfa("#4c6678", 0.6), K, derin=0.05)
        kutu(cx - 2, cx + 3, Y(46), Y(43), y0 - 0.2, y0 + 1.2, M2)
        silindir_z(cx + 0.5, Y(51), Y(46), y0 + 0.5, 0.3, M2, seg=6)
    elif ad == "gokdelen":
        for s2 in range(6):
            sw = 15 - s2 * 2
            h0 = 8 + s2 * 7
            kutu(cx - sw // 2, cx - sw // 2 + sw, Y(h0 + 9), Y(h0 - 1) if s2 else BASE, y0 + s2, y0 + 10 - s2, M2 if s2 % 2 else M1, bevel=0.3)
        silindir_z(cx + 0.5, Y(60), Y(52), y0 + 5, 0.4, M2, seg=6)
        kutu(cx, cx + 1, Y(57), Y(56), y0 + 4, y0 + 4.2, Mi)
    elif ad == "pagoda":
        for pg in range(5):
            pw = 24 - pg * 4
            py = Y(10 + pg * 8)
            kutu(cx - pw // 2 + 2, cx + pw // 2 - 2, py + 2, py + 8, y0 + 3, y0 + pw - 3, M1)
            kutu(cx - pw // 2, cx + pw // 2, py, py + 2, y0 + 1, y0 + pw - 1, M2, bevel=0.4)
            for sx in (-1, 1):
                kutu(cx + sx * (pw // 2) - (1 if sx < 0 else 0), cx + sx * (pw // 2) + (0 if sx < 0 else 1), py - 0.8, py + 1.2, y0 + 1, y0 + 2, M2)
        silindir_z(cx + 0.5, Y(50), Y(44), y0 + 5, 0.35, M2, seg=6)
    elif ad == "kuleler":
        mb = [34, 46, 30, 40]
        for mn, h in enumerate(mb):
            mbx = cx - 18 + mn * 10
            T.torna("kule", [(4.0, 0), (4.0, h - 4), (2.6, h - 1), (1.0, h)], mbx + 4, BASE, y0, 1.0, M2 if mn % 2 else M1, K, seg=16)
            for mw in range(4, h - 2, 4):
                if hash1(mn * 3.7 + mw) > 0.5:
                    kutu(mbx + 3, mbx + 4, Y(h - mw) - 0.5, Y(h - mw) + 0.5, y0 - 4.2, y0 - 4.0, Mi)
        pxx = cx + 26
        silindir_z(pxx + 1, Y(20), BASE, y0, 0.8, M2)
        for pl in range(5):
            pa = -0.5 + pl * 0.5
            x1 = pxx + 1 + round(math.cos(pa) * 7)
            yy = Y(20) - round(math.sin(pa) * 5) - 2
            T.on_poligon("yaprak", [(pxx + 1, Y(20)), (x1, yy), (x1 - 0.5, yy + 1), (pxx + 1, Y(20) + 1)], y0 - 1, M2, K, derin=0.1)
            T.on_poligon("yaprak", [(pxx + 1, Y(20)), (2 * pxx + 2 - x1, yy), (2 * pxx + 2 - x1 + 0.5, yy + 1), (pxx + 1, Y(20) + 1)], y0 - 1, M2, K, derin=0.1)
    elif ad == "manhattan":
        boy = [30, 44, 34, 50, 32, 40]
        for n2, h in enumerate(boy):
            bx = cx - 26 + n2 * 10
            kutu(bx, bx + 9, Y(h), BASE, y0 + n2 % 2 * 3, y0 + 9, M2 if n2 % 2 else M1, bevel=0.2)
            if n2 == 3:
                T.torna("tepe", [(3.2, 0), (0.2, 6)], bx + 4.5, Y(h), y0 + 4, 1.0, M2, K, seg=12)
            for wy2 in range(3, h - 2, 5):
                if hash1(n2 * 3.3 + wy2) > 0.42:
                    kutu(bx + 2, bx + 3, Y(h - wy2) - 0.5, Y(h - wy2) + 0.5, y0 + n2 % 2 * 3 - 0.1, y0, Mi)
                if hash1(n2 * 7.1 + wy2) > 0.52:
                    kutu(bx + 6, bx + 7, Y(h - wy2) - 0.5, Y(h - wy2) + 0.5, y0 + n2 % 2 * 3 - 0.1, y0, mat_alfa("#fcf2c4", 0.55))
        silindir_z(cx + 4.5, Y(56), Y(50 + 6), y0 + 4, 0.3, M2, seg=6)
    elif ad == "anit":
        kutu(cx - 5, cx + 6, Y(46), BASE, y0, y0 + 11, M1, bevel=0.3)
        for kt in range(5):
            kutu(cx - 5.2, cx + 6.2, Y(40 - kt * 8) - 0.6, Y(40 - kt * 8), y0 - 0.2, y0 + 11.2, M2)
        Mr = mat_ton("#b83228", f=(0.65, 0.85, 1.0, 1.12))
        kutu(cx - 1, cx + 2, Y(52), Y(46), y0 + 4, y0 + 7, Mr)
        kutu(cx - 4, cx + 5, Y(50), Y(47), y0 + 2, y0 + 9, Mr, bevel=0.3)
        for bd in (-1, 1):
            bxx = cx + bd * 12
            silindir_z(bxx + 0.5, Y(34), BASE, y0, 0.35, M2, seg=6)
            fx0 = bxx - 7 if bd < 0 else bxx + 1
            bm = bmesh.new()
            V = []
            for j in range(5):
                u = j / 4
                y = y0 - 0.3 * math.sin(u * math.pi * 2)
                V.append([bm.verts.new((fx0 + u * 7, y, ez(Y(34) + v, y, K))) for v in (0, 5)])
            for j in range(4):
                bm.faces.new((V[j][0], V[j + 1][0], V[j + 1][1], V[j][1]))
            bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
            I.mesh_ob("bayrak", bm, Mr, smooth=True)


# ================================================================ numpy katmanlari
def gok_ve_bulut(tema):
    H, W = GH * HD, GW * HD
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32) + 0.5
    k = np.clip((yy / HD) / 44.0, 0, 1)[..., None]
    img = rgb(tema["gok"][0]) * (1 - k) + rgb(tema["gok"][1]) * k
    a = np.ones((H, W), np.float32)
    out = np.dstack([img, a])
    for cl in range(5):
        cx = 6 + hash1(cl * 5.3) * (GW - 24)
        cy = 3 + hash1(cl * 2.1) * 14
        cw = 9 + hash1(cl * 1.7) * 8
        X, Y = xx / HD, yy / HD
        alan = np.zeros((H, W), np.float32)
        for ox, oy, rx, ry in ((0, 0, cw, 3.0), (-cw * 0.5, 1, cw * 0.55, 2.2), (cw * 0.55, 1, cw * 0.45, 2.2),
                               (-cw * 0.15, -1.6, cw * 0.4, 2.4), (cw * 0.3, -1.0, cw * 0.35, 2.0)):
            d = ((X - cx - ox) / rx) ** 2 + ((Y - cy - oy) / ry) ** 2
            alan = np.maximum(alan, 1.0 - d)
        m = np.clip(alan * 6.0, 0, 1)
        golge = np.clip((Y - cy + 0.2) / 3.0, 0, 1)
        renk = rgb("#ffffff")[None, None] * (1 - golge[..., None]) + rgb("#d6e4ee")[None, None] * golge[..., None]
        al = (m * 0.8)[..., None]
        out[..., :3] = out[..., :3] * (1 - al) + renk * al
    return out


def uzak_siluet(out, tema):
    H, W = GH * HD, GW * HD
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32) + 0.5
    X, Y = xx / HD, yy / HD
    for kat in range(2):
        sol = 0.2 if kat == 0 else 0.34
        yuk = 14 if kat == 0 else 0
        adim = 26 if kat == 0 else 30
        kay = -14 if kat == 0 else -10
        sayi = math.ceil(GW / adim) + 2
        renk = tema["bina"][kat]
        for f in range(sayi):
            t = f * 3.7 + kat * 17.3
            fw = 18 + math.floor(hash1(t) * 24)
            fx0 = kay + f * adim
            fh = 20 + yuk + math.floor(hash1(t * 1.9) * 20)
            fy0 = max(BASE - fh, 2)
            govde = (X >= fx0) & (X < fx0 + fw) & (Y >= fy0) & (Y < BASE)
            if hash1(t * 5.1) > 0.62:
                govde |= (X >= fx0 + 4) & (X < fx0 + 9) & (Y >= fy0 - 4) & (Y < fy0)
            if hash1(t * 8.3) > 0.7:
                govde |= (X >= fx0 + fw - 6) & (X < fx0 + fw - 5.5) & (Y >= fy0 - 6) & (Y < fy0)
            # pus: asagi dogru hafif acilan ton
            ton = rgb(renk)[None, None] * (1.0 + 0.08 * np.clip((Y - fy0) / 30.0, 0, 1))[..., None]
            ust = (Y < fy0 + 1.5) & govde
            ton = np.where(ust[..., None], rgb(karis(renk, "#ffffff", 0.2))[None, None], ton)
            al = (govde * sol)[..., None]
            out[..., :3] = out[..., :3] * (1 - al) + ton * al
            for wy in range(6):
                for wx in range(3):
                    if hash1(t * 11 + wy * 3.3 + wx * 1.9) < 0.48:
                        continue
                    pcy = fy0 + 5 + wy * 6
                    if pcy + 4 > BASE - 2:
                        break
                    x0 = fx0 + 4 + wx * 6
                    m = (X >= x0 + 0.5) & (X < x0 + 2.5) & (Y >= pcy + 0.5) & (Y < pcy + 3.5)
                    al = (m * sol * 0.8)[..., None]
                    out[..., :3] = out[..., :3] * (1 - al) + rgb("#e6f0f6") * al
    return out


def ustune_goruntu(out, yol, alfa=1.0):
    a = px.read_png(yol).astype(np.float32) / 255.0
    al = a[..., 3:4] * alfa
    out[..., :3] = out[..., :3] * (1 - al) + a[..., :3] * al
    return out


def sahne():
    D.sahne(0, 0, GW, GH, 1.0)
    _MAT.clear()


def uret(tema):
    sid = tema["id"]
    tmp = os.path.join(OUT, "_tmp")
    out = gok_ve_bulut(tema)
    if tema.get("imza"):
        sahne()
        imza(tema["imza"])
        px.shear_scene(K)
        yol = px.render(os.path.join(tmp, sid + "_imza.png"))
        out = ustune_goruntu(out, yol, 0.72)
    out = uzak_siluet(out, tema)
    sahne()
    liste, tarz = yerlesim(tema)
    for bx, bw, bh, bi, rakip in liste:
        bina(bx, BASE, bw, bh, bi, tarz, rakip)
    if tarz == "beton":
        hoparlor_diregi()
    zemin(tema)
    px.shear_scene(K)
    yol = px.render(os.path.join(tmp, sid + "_bina.png"))
    px.outline(yol, hexcol="#1e1a1a", alpha=70)
    out = ustune_goruntu(out, yol)
    out[..., 3] = 1.0
    return px.write_png((np.clip(out, 0, 1) * 255 + 0.5).astype(np.uint8), os.path.join(OUT, "sokak_%s.png" % sid))


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    os.makedirs(OUT, exist_ok=True)
    S = sehirler()
    for tema in S:
        if argv and tema["id"] not in argv:
            continue
        uret(tema)
        print("SOKAK", tema["id"])
    adlar = ["sokak_%s" % t["id"] for t in S]
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": HD, "katmanlar": adlar, "kokenler": {a: [0, 0] for a in adlar}}, fp, indent=1)
    print("SOKAK_ARKA_HD_DONE")


if __name__ == "__main__":
    main()
