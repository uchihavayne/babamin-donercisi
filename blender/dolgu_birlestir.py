"""DOLGU HAM RENDERLARINDAN ATLAS PARCALARI (sistem Python + PIL).

    python blender/dolgu_birlestir.py [180 122 90 100]

Girdi : blender/out/dolgu_ham/<olcek>/d_E_P_T.png   (models/dolgu_hd.py)
          lavas maske renkleri: macenta = aydinlik lavas, camgobegi = golgede
          d_0_0_0.png = yalniz lavas (kendi golgesi -> cikarilir)
        blender/out/dolgu_ham/<olcek>/y_K_M.png, s_TUR_M.png (yogurt / sos)
Cikti : blender/out/dolgu<olcek>_hd/<parca>.png + tuval.json
          d_E_P_T : dolgu parcalari opak + lavasa dusen golge (yari saydam) +
                    kenar cizgisi (lavas disinda koyu, lavas ustunde yumusak)
          y_K_M, s_TUR_M : yogurt / sos + kenar cizgisi
Sonra: python blender/hd_atlas.py dolgu180_hd dolgu180  (her olcek)
"""
import json, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
HAM = os.path.join(HERE, "out", "dolgu_ham")
TUVAL = (-24, -11)
OLCEKLER = {180: 1.8, 122: 1.22, 90: 0.9, 100: 1.0}
MAC = (255, 0, 255)
CAM = (0, 255, 255)
GOLGE = (42, 24, 8, 84)
KENAR_DIS = (58, 26, 6, 210)
KENAR_IC = (58, 26, 6, 96)


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def sinif(p):
    if p[3] < 8:
        return 0          # arka plan
    c = p[:3]
    if c == MAC:
        return 1          # aydinlik lavas
    if c == CAM:
        return 2          # golgede lavas
    return 3              # dolgu


def dolgu(A, B):
    w, h = A.size
    a, b = A.load(), B.load()
    s = [[sinif(a[x, y]) for x in range(w)] for y in range(h)]
    sb = [[sinif(b[x, y]) for x in range(w)] for y in range(h)]
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    o = out.load()
    for y in range(h):
        for x in range(w):
            k = s[y][x]
            if k == 3:
                o[x, y] = a[x, y][:3] + (255,)
            elif k == 2 and sb[y][x] != 2:
                o[x, y] = GOLGE
    for y in range(h):
        for x in range(w):
            k = s[y][x]
            if k == 3:
                continue
            kom = any(0 <= x + dx < w and 0 <= y + dy < h and s[y + dy][x + dx] == 3
                      for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            if not kom:
                continue
            if k == 0:
                o[x, y] = KENAR_DIS
            else:
                eski = o[x, y]
                o[x, y] = KENAR_IC if eski[3] < KENAR_IC[3] else eski
    return out


def serit(A, kenar):
    w, h = A.size
    a = A.load()
    out = A.copy()
    o = out.load()
    dolu = [[a[x, y][3] > 8 for x in range(w)] for y in range(h)]
    for y in range(h):
        for x in range(w):
            if dolu[y][x]:
                o[x, y] = a[x, y][:3] + (255,)
                continue
            if any(0 <= x + dx < w and 0 <= y + dy < h and dolu[y + dy][x + dx]
                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                o[x, y] = kenar
    return out


def isle(o):
    kaynak = os.path.join(HAM, str(o))
    hedef = os.path.join(HERE, "out", "dolgu%d_hd" % o)
    os.makedirs(hedef, exist_ok=True)
    B = Image.open(os.path.join(kaynak, "d_0_0_0.png")).convert("RGBA")
    adlar = []
    for dosya in sorted(os.listdir(kaynak)):
        if not dosya.endswith(".png"):
            continue
        ad = dosya[:-4]
        if ad == "d_0_0_0":
            continue
        A = Image.open(os.path.join(kaynak, dosya)).convert("RGBA")
        if ad.startswith("d_"):
            im = dolgu(A, B)
        elif ad.startswith("y_"):
            im = serit(A, (106, 98, 82, 150))
        elif ad.startswith("s_hot"):
            im = serit(A, (74, 12, 8, 170))
        else:
            im = serit(A, (138, 130, 112, 150))
        if im.getbbox() is None:
            continue
        im.save(os.path.join(hedef, ad + ".png"))
        adlar.append(ad)
    with open(os.path.join(hedef, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": 2, "katmanlar": adlar,
                   "kokenler": {a: list(TUVAL) for a in adlar},
                   "olcekler": {a: OLCEKLER[o] for a in adlar}}, fp, indent=1)
    print("DOLGU %d: %d parca" % (o, len(adlar)))


if __name__ == "__main__":
    for o in ([int(a) for a in sys.argv[1:]] or list(OLCEKLER)):
        isle(o)
