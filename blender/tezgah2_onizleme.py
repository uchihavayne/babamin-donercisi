"""Yeni tezgah HD parcalarini oyundaki yerlerine dizen onizleme (PIL).
    python blender/tezgah2_onizleme.py [cikti.png]
Konumlar counter_design.gd'deki j_ST ile ayni."""
import json, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
ST = {"spit": (46, 48, 44, 128), "meat": (108, 153, 44, 32), "pickle": (152, 153, 44, 32),
      "yogurt": (196, 153, 44, 32), "friesT": (240, 153, 44, 32), "garnish": (284, 153, 44, 27),
      "bread": (80, 194, 48, 40), "board": (130, 187, 150, 48), "paper": (308, 208, 24, 27),
      "sauce": (288, 180, 44, 27), "fryer": (336, 153, 51, 43), "grill": (391, 151, 48, 45),
      "cut": (336, 198, 51, 37), "fbox": (391, 199, 46, 36), "drinkM": (418, 92, 56, 58),
      "sweet": (440, 175, 34, 27), "potato": (391, 241, 46, 28), "crate": (337, 241, 49, 28),
      "trash": (442, 218, 31, 50)}


def yukle(klasor):
    t = json.load(open(os.path.join(OUT, klasor, "tuval.json"), encoding="utf-8"))
    return t


TV = {k: yukle(k) for k in ("tezgah2_hd", "tepsi_hd", "tezgah_hd", "istasyon_hd")}


def koy(c, klasor, ad, ax, ay):
    t = TV[klasor]
    gx, gy = t.get("kokenler", {}).get(ad, (t.get("gx0", 0), t.get("gy0", 0)))
    im = Image.open(os.path.join(OUT, klasor, ad + ".png")).convert("RGBA")
    c.alpha_composite(im, (int(round((ax + gx) * 2)), int(round((ay + gy) * 2))))


def main():
    c = Image.new("RGBA", (960, 540), (60, 70, 80, 255))
    koy(c, "tezgah2_hd", "tezgah_celik", 0, 0)
    koy(c, "tezgah2_hd", "tezgah_ust", 0, 0)
    koy(c, "tezgah2_hd", "tezgah_alt", 0, 0)
    koy(c, "tezgah2_hd", "servis", 0, 0)
    for k in ("meat", "pickle", "yogurt", "friesT"):
        x, y, w, h = ST[k]
        koy(c, "tepsi_hd", "kuvet_44x32", x, y)
    x, y, w, h = ST["garnish"]
    koy(c, "tepsi_hd", "kuvet_44x27", x, y)
    x, y, w, h = ST["sweet"]
    koy(c, "tepsi_hd", "kuvet_34x27", x, y)
    x, y, w, h = ST["board"]
    koy(c, "tezgah2_hd", "tahta", x, y)
    x, y, w, h = ST["bread"]
    koy(c, "tezgah2_hd", "altlik", x, y + 3)
    koy(c, "istasyon_hd", "lavas_yigin", x + 3, y - 1)
    x, y, w, h = ST["fryer"]
    koy(c, "tezgah2_hd", "fritoz_govde", x, y)
    koy(c, "tezgah2_hd", "fritoz_kol", x, y)
    x, y, w, h = ST["grill"]
    koy(c, "tezgah2_hd", "izgara_govde", x, y)
    x, y, w, h = ST["cut"]
    koy(c, "tezgah2_hd", "kesme_tahta", x, y)
    koy(c, "tezgah2_hd", "patates_butun", x + w / 2, y + h / 2)
    koy(c, "tezgah2_hd", "satir", x + w - 12, y + h / 2 - 6)
    x, y, w, h = ST["drinkM"]
    koy(c, "tezgah2_hd", "icecek_govde", x, y)
    for i, t in enumerate(("fanta", "cola", "ayran")):
        seg = w / 3 - 4
        cx = x + (i + .5) * w / 3
        koy(c, "tezgah2_hd", "musluk_3_%s" % t, cx - seg / 2, y + 4)
    x, y, w, h = ST["paper"]
    koy(c, "tezgah2_hd", "kagit_makine", x, y)
    x, y, w, h = ST["crate"]
    koy(c, "tezgah2_hd", "stok", x, y)
    x, y, w, h = ST["potato"]
    koy(c, "tezgah2_hd", "patates_kasa", x, y)
    x, y, w, h = ST["trash"]
    koy(c, "tezgah2_hd", "cop", x, y)
    x, y, w, h = ST["fbox"]
    koy(c, "tezgah2_hd", "kutu_raf_46", x, y)
    koy(c, "tezgah_hd", "kutu_bos", x, y)
    x, y, w, h = ST["sauce"]
    for i in range(3):
        koy(c, "tezgah2_hd", "sise_%d" % i, x + (i + .5) * w / 3, y + h - 2)
    yol = sys.argv[1] if len(sys.argv) > 1 else os.path.join(OUT, "_tezgah2_tam.png")
    c.save(yol)
    c.crop((0, 160, 960, 540)).save(yol.replace(".png", "_alt.png"))
    print("ONIZLEME", yol)


if __name__ == "__main__":
    main()
