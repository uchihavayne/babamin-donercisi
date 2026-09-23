"""Logo icin yazi olculeri — SISTEM Python'u ile calisir (fontTools gerekir).

    python blender/logo_olcu.py

Blender'in kendi Python'unda fontTools yok. Harf harf dizmek icin her
harfin ilerleme genisligi ve fontun buyuk harf yuksekligi gerekiyor;
bunlari burada okuyup blender/out/logo_font.json'a yaziyoruz, Blender
betigi (models/logo.py) oradan okuyor.

Bir fontta harf YOKSA (Cooper Black'te Ş Ğ İ yok) "var" tablosunda
false doner; logo.py o harfi taban harf + ayri modellenmis aksanla kurar.
"""
import json, os, sys
from fontTools.ttLib import TTFont

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out", "logo_font.json")

FONTLAR = {
    "cooper":   "C:/Windows/Fonts/COOPBL.TTF",
    "arialblk": "C:/Windows/Fonts/ariblk.ttf",
    "impact":   "C:/Windows/Fonts/impact.ttf",
    "elephant": "C:/Windows/Fonts/ELEPHNT.TTF",
    "hatten":   "C:/Windows/Fonts/HATTEN.TTF",
    "rockeb":   "C:/Windows/Fonts/ROCKEB.TTF",
}
# logoda gecebilecek her harf (6 dilin basliklari + rakamlar)
HARFLER = ("ABCDEFGHIJKLMNOPQRSTUVWXYZÇĞİÖŞÜÄÉÈÊÀÁÍÓÚÑÃÕÔ'’&-.,0123456789 "
           "abcdefghijklmnopqrstuvwxyz")

sonuc = {}
for ad, yol in FONTLAR.items():
    if not os.path.exists(yol):
        print("YOK:", yol); continue
    f = TTFont(yol)
    cmap = f.getBestCmap()
    upm = f["head"].unitsPerEm
    os2 = f["OS/2"]
    cap = getattr(os2, "sCapHeight", 0) or 0
    if cap <= 0:                                  # eski fontlarda bos olabilir
        g = f.getGlyphSet()
        from fontTools.pens.boundsPen import BoundsPen
        bp = BoundsPen(g); g[cmap[ord("H")]].draw(bp)
        cap = bp.bounds[3]
    hmtx = f["hmtx"].metrics
    adv, var = {}, {}
    for ch in HARFLER:
        gid = cmap.get(ord(ch))
        var[ch] = gid is not None
        if gid is not None:
            adv[ch] = hmtx[gid][0] / upm
    sonuc[ad] = {"yol": yol, "upm": upm, "cap": cap / upm, "adv": adv, "var": var}
    eksik = [c for c in "ÇĞİÖŞÜ" if not var[c]]
    print("%-9s cap=%.3f em  eksik:%s" % (ad, cap / upm, "".join(eksik) or "-"))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w", encoding="utf-8") as fp:
    json.dump(sonuc, fp, ensure_ascii=False, indent=1)
print("yazildi:", OUT)
