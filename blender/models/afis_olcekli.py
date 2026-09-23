"""Duvar afisleri (vitrin_hd afis_1..3) OLCEKLI render — birlesik surum.

    blender --background --factory-startup --python blender/models/afis_olcekli.py
    python blender/hd_atlas.py afis64_hd afis64

counter_design.f_drawPoster afisi ctx.scale(0.64) icinde ciziyor; HD doku
olcegi yok saydigi icin afis o olcekte ayrica render edilir (atlas
"afis64"; dx, dy olceksiz mantik pikseli, oyun donusumu olcekler).
"""
import sys, os, json
_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import vitrin_hd as V
import durum_hd as D

SC = 0.64
OUT = os.path.join(_HERE, "out", "afis%d_hd" % int(round(SC * 100)))
ADLAR = ["afis_1", "afis_2", "afis_3"]


def main():
    os.makedirs(OUT, exist_ok=True)
    for ad in ADLAR:
        (gx0, gy0, w, h), fn, cizgi, cizgi_alfa, tur = V.PARCALAR[ad]
        D.sahne(gx0, gy0, w, h, SC)
        fn()
        px.shear_scene(V.K)
        yol = px.render(os.path.join(OUT, ad + ".png"))
        if cizgi:
            px.outline(yol, hexcol=cizgi, alpha=cizgi_alfa)
    with open(os.path.join(OUT, "tuval.json"), "w", encoding="utf-8") as fp:
        json.dump({"hd": V.HD, "katmanlar": ADLAR,
                   "kokenler": {k: list(V.KOKEN[k]) for k in ADLAR},
                   "olcekler": {k: SC for k in ADLAR}}, fp, indent=1)
    print("AFIS_OLCEKLI_DONE %d" % len(ADLAR))


if __name__ == "__main__":
    main()
