"""HD KATMAN ATLASI PAKETLEYICI (sistem Python + PIL).

    python blender/hd_atlas.py <out alt klasoru> <atlas adi>
    python blender/hd_atlas.py dayi_hd dayi

Girdi : blender/out/<klasor>/tuval.json
          {"hd": 2, "katmanlar": [...],
           "gx0": .., "gy0": ..,                       # ortak tuval kokeni (varsayilan)
           "kokenler": {"parca_adi": [gx0, gy0], ...}}  # parcaya ozel (istege bagli)
        blender/out/<klasor>/<katman>.png
          gx0, gy0: PNG'nin sol-ust kosesinin, parcanin CAPA noktasina gore
          mantik pikseli konumu (Dayi: drawChef'in (x,y)'si; tepsi: sol-ust;
          et parcasi: merkezi).
Cikti : assets/remake/<atlas>/atlas.png
        assets/remake/<atlas>/atlas.json
          {"hd": 2, "parca": {ad: [ax, ay, w, h, dx, dy]}}
          ax,ay,w,h : atlastaki dikdortgen (HD piksel)
          dx,dy     : kirpilmis parcanin capaya gore konumu (mantik pikseli,
                      1/hd katlari)

Oyun (scripts/remake_gorsel.gd -> hd_ciz) parcayi capanin (x, y) noktasina
gore (x + dx, y + dy)'ye, HD piksel izgarasina oturtarak ciziyor.
"""
import json, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
KOK = os.path.dirname(HERE)


def paketle(klasor, ad, bosluk=2, genislik=1024):
    kaynak = os.path.join(HERE, "out", klasor)
    tuval = json.load(open(os.path.join(kaynak, "tuval.json"), encoding="utf-8"))
    hd = tuval["hd"]
    kokenler = tuval.get("kokenler", {})
    # "kirpma": false -> saydam kenarlar KIRPILMAZ (9 dilim parcalarinda dilim
    # sinirlari kaymasin diye; arayuz_hd)
    kirp = tuval.get("kirpma", True)
    parcalar = []
    for k in tuval["katmanlar"]:
        yol = os.path.join(kaynak, k + ".png")
        if not os.path.exists(yol):
            print("  YOK:", k)
            continue
        im = Image.open(yol).convert("RGBA")
        kutu = im.getbbox() if kirp else (0, 0, im.width, im.height)
        if kutu is None:
            print("  BOS:", k)
            continue
        gx0, gy0 = kokenler.get(k, (tuval.get("gx0", 0), tuval.get("gy0", 0)))
        # olcekli parca (ctx.scale icinde cizilen): hd*olcek pikselle render
        # edildi; dx, dy yine OLCEKSIZ mantik pikseli (oyun donusumu olcekler)
        sc = tuval.get("olcekler", {}).get(k, 1.0)
        parcalar.append((k, im.crop(kutu), gx0 + kutu[0] / (hd * sc), gy0 + kutu[1] / (hd * sc)))
    parcalar.sort(key=lambda p: -p[1].height)
    x = y = raf_h = 0
    yer = {}
    for k, im, dx, dy in parcalar:
        if x + im.width > genislik:
            x = 0
            y += raf_h + bosluk
            raf_h = 0
        yer[k] = (x, y)
        x += im.width + bosluk
        raf_h = max(raf_h, im.height)
    h = y + raf_h
    atlas = Image.new("RGBA", (genislik, max(1, h)), (0, 0, 0, 0))
    veri = {"hd": hd, "parca": {}}
    for k, im, dx, dy in parcalar:
        ax, ay = yer[k]
        atlas.paste(im, (ax, ay))
        veri["parca"][k] = [ax, ay, im.width, im.height, dx, dy]
    hedef = os.path.join(KOK, "assets", "remake", ad)
    os.makedirs(hedef, exist_ok=True)
    atlas.save(os.path.join(hedef, "atlas.png"), optimize=True)
    with open(os.path.join(hedef, "atlas.json"), "w", encoding="utf-8") as fp:
        json.dump(veri, fp, ensure_ascii=False, separators=(",", ":"))
    print("ATLAS %s: %d parca, %dx%d, %.1f KB" % (ad, len(parcalar), genislik, h,
                                                 os.path.getsize(os.path.join(hedef, "atlas.png")) / 1024))


if __name__ == "__main__":
    paketle(sys.argv[1], sys.argv[2])
