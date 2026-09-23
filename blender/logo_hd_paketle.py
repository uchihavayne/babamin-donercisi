"""HD baslik logosunu paketler (sistem Python + PIL).

    blender ... --python blender/models/logo_anim_hd.py -- hepsi   (once)
    python blender/logo_hd_paketle.py

Girdi : blender/out/logo_anim_hd/*.png + meta.json   (640x224, 2x)
Cikti : assets/remake/logo/arka.png, sis.png, on_<dil>.png, maske_<dil>.png, logo.json

logo.json olculeri MANTIK pikseli (2x'in yarisi): oyun eski LOGO_VERI ile ayni
yerlesimi kullanir (cx, katman x/y, kare kw/kh), kaynak dikdortgenleri 2x.
Sayfalar mobil doku sinirina gore satirlara bolunur (arka 6, sis 8 sutun).
"""
import json, os
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
KOK = os.path.dirname(HERE)
SRC = os.path.join(HERE, "out", "logo_anim_hd")
HEDEF = os.path.join(KOK, "assets", "remake", "logo")
ALTIN = {(0xff, 0xf2, 0xa8), (0xff, 0xd3, 0x4e), (0xe0, 0xa4, 0x1f), (0xa9, 0x71, 0x13)}


def ac(ad):
    return Image.open(os.path.join(SRC, ad + ".png")).convert("RGBA")


def birlesim(kutular):
    return (min(b[0] for b in kutular), min(b[1] for b in kutular),
            max(b[2] for b in kutular), max(b[3] for b in kutular))


def cift(kutu):
    """Kutuyu cift sayilara genislet: mantik koordinatlari tam/yarim olmasin."""
    x0, y0, x1, y1 = kutu
    return (x0 - x0 % 2, y0 - y0 % 2, x1 + x1 % 2, y1 + y1 % 2)


def sayfa(kareler, kutu, sut):
    x0, y0, x1, y1 = kutu
    kw, kh = x1 - x0, y1 - y0
    sat = (len(kareler) + sut - 1) // sut
    s = Image.new("RGBA", (kw * min(sut, len(kareler)), kh * sat), (0, 0, 0, 0))
    for i, im in enumerate(kareler):
        s.paste(im.crop(kutu), ((i % sut) * kw, (i // sut) * kh))
    return s, kw, kh


def main():
    os.makedirs(HEDEF, exist_ok=True)
    meta = json.load(open(os.path.join(SRC, "meta.json"), encoding="utf-8"))
    TW = meta["tuval"][0] * 2
    yak = [ac("arka_yak_%d" % k) for k in range(meta["yak_n"])]
    tit = [ac("arka_tit_%02d" % f) for f in range(meta["tit_n"])]
    sis = [ac("sis_%02d" % i) for i in range(meta["sis_n"])]
    on = {d: ac("on_" + d) for d in meta["diller"]}

    k_arka = cift(birlesim([im.getbbox() for im in yak + tit]))
    k_sis = cift(birlesim([im.getbbox() for im in sis]))
    k_on = {d: cift(im.getbbox()) for d, im in on.items()}
    cer = birlesim([k_arka, k_sis] + list(k_on.values()))
    fx, fy = cer[0], cer[1]
    veri = {"hd": 2, "w": (cer[2] - fx) / 2, "h": (cer[3] - fy) / 2, "cx": (TW // 2 - fx) / 2}

    s, kw, kh = sayfa(yak + tit, k_arka, 6)
    s.save(os.path.join(HEDEF, "arka.png"), optimize=True)
    veri["arka"] = {"x": (k_arka[0] - fx) / 2, "y": (k_arka[1] - fy) / 2, "kw": kw, "kh": kh, "sut": 6}

    s, kw, kh = sayfa(sis, k_sis, 8)
    s.save(os.path.join(HEDEF, "sis.png"), optimize=True)
    veri["sis"] = {"x": (k_sis[0] - fx) / 2, "y": (k_sis[1] - fy) / 2, "kw": kw, "kh": kh, "sut": 8}

    veri["on"] = {}
    for d, im in on.items():
        k = k_on[d]
        kes = im.crop(k)
        kes.save(os.path.join(HEDEF, "on_%s.png" % d), optimize=True)
        m = Image.new("RGBA", kes.size, (0, 0, 0, 0))
        mp, kp = m.load(), kes.load()
        for y in range(kes.height):
            for x in range(kes.width):
                c = kp[x, y]
                if c[3] > 127 and c[:3] in ALTIN:
                    mp[x, y] = (255, 255, 255, 255)
        m.save(os.path.join(HEDEF, "maske_%s.png" % d), optimize=True)
        veri["on"][d] = {"x": (k[0] - fx) / 2, "y": (k[1] - fy) / 2, "w": kes.width, "h": kes.height}
    with open(os.path.join(HEDEF, "logo.json"), "w", encoding="utf-8") as fp:
        json.dump(veri, fp, ensure_ascii=False, indent=1)
    print("LOGO HD: cerceve %.1fx%.1f cx %.1f  arka %s  sis %s" % (veri["w"], veri["h"], veri["cx"], veri["arka"], veri["sis"]))


if __name__ == "__main__":
    main()
