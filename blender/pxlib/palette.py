"""Doner Efsanesi ana paleti - js/core.js icindeki P nesnesinin birebir kopyasi.
Buradaki her renk oyunda halihazirda kullanilan bir renktir; render ciktisi
bu kumenin disina cikmamalidir."""

P = {
    "ink": "#241a20", "ink2": "#3a2a30", "white": "#fffaf0", "bone": "#efe4d2",
    "st0": "#e6e6ea", "st1": "#c8c9d2", "st2": "#a4a5b3", "st3": "#7d7e8d", "st4": "#5b5c69",
    "tl0": "#6ba7c4", "tl1": "#4d87a6", "tl2": "#3a6c88", "tl3": "#2c5369", "tl4": "#1e3c4e",
    "grout": "#25485c",
    "mt0": "#f2f4f6", "mt1": "#d3d8de", "mt2": "#aeb5be", "mt3": "#878e99", "mt4": "#5f6672", "mt5": "#41474f",
    "wd0": "#a8703f", "wd1": "#8a5730", "wd2": "#6b4122", "wd3": "#4e2e17",
    "m0": "#ffd9a0", "m1": "#f0b269", "m2": "#d18c42", "m3": "#a5622a", "m4": "#78421a", "m5": "#4d290f",
    "raw": "#e79f8c", "raw2": "#c97a68",
    "f0": "#fff3b0", "f1": "#ffd257", "f2": "#ff9c2e", "f3": "#ef5f22", "f4": "#b8331a",
    "g0": "#cfe08a", "g1": "#a8c257", "g2": "#7fa138", "g3": "#5b7726", "g4": "#3d5219",
    "s0": "#fffdf2", "s1": "#efe7d0", "s2": "#d6cbae", "s3": "#b3a684",
    "p0": "#ffe9a3", "p1": "#f7cc63", "p2": "#dba53a", "p3": "#a97724", "p4": "#7d5417",
    "cola": "#43220f", "cola2": "#6b3a1c", "or0": "#ffb03c", "or1": "#f0821c", "ay0": "#f6f4ea",
    "au0": "#fff2a8", "au1": "#ffd34e", "au2": "#e0a41f", "au3": "#a97113",
    "red0": "#e05a48", "red1": "#c33c2c", "red2": "#96271c", "red3": "#6d1a12",
    "skin0": "#ffdcb0", "skin1": "#f0bd8a", "skin2": "#cf9560", "skin3": "#a06f42",
    "ok": "#78d06a", "warn": "#ffcb3d", "bad": "#e8483a", "blue": "#57a9e0", "blue2": "#3b7fb5",
    "pur": "#9a6bcf", "pink": "#f090b8",
    "ui0": "#fdf3dd", "ui1": "#e5cfa4", "ui2": "#b99a68", "ui3": "#7d603a", "ui4": "#4a3722", "ui5": "#2b1f14",
}

# Oyunda dogrudan yazilmis, P'de olmayan ek tonlar (art.js icinden)
EXTRA = {
    "heat_body": "#241610", "heat_dark": "#6d1a08", "heat_a": "#c8380f", "heat_b": "#e0500f",
    "heat_hot": "#ff9c2e", "heat_core": "#ffe08a", "glow": "#ff8a2a",
}

# --- oyunun et renk fonksiyonu (art.js meatColCalc) --------------------------
def _lerp(a, b, k):
    return a + (b - a) * k

def meat_col(roast):
    """roast 0..1.35 -> (r,g,b) 0-255. art.js:meatColCalc ile ayni egri."""
    if roast < .34:
        k = roast / .34
        c = (_lerp(233, 242, k), _lerp(158, 180, k), _lerp(136, 104, k))
    elif roast < .78:
        k = (roast - .34) / .44
        c = (_lerp(242, 208, k), _lerp(180, 138, k), _lerp(104, 64, k))
    elif roast < 1.0:
        k = (roast - .78) / .22
        c = (_lerp(208, 158, k), _lerp(138, 92, k), _lerp(64, 40, k))
    else:
        k = min(1, (roast - 1) / .35)
        c = (_lerp(158, 58, k), _lerp(92, 42, k), _lerp(40, 30, k))
    return tuple(int(round(v)) for v in c)

def meat_hex(roast):
    r, g, b = meat_col(roast)
    return "#%02x%02x%02x" % (r, g, b)

def ramp(*keys):
    """Palet anahtarlarindan koyu->acik siralanmis hex listesi."""
    return [P[k] for k in keys]

# Sik kullanilan hazir rampalar (koyu -> acik)
METAL   = ramp("mt5", "mt4", "mt3", "mt2", "mt1", "mt0")
WOOD    = ramp("wd3", "wd2", "wd1", "wd0")
MEAT    = ramp("m5", "m4", "m3", "m2", "m1", "m0")
BREAD   = ramp("p4", "p3", "p2", "p1", "p0")
GREEN   = ramp("g4", "g3", "g2", "g1", "g0")
CREAM   = ramp("s3", "s2", "s1", "s0")
RED     = ramp("red3", "red2", "red1", "red0")
STONE   = ramp("st4", "st3", "st2", "st1", "st0")
TILE    = ramp("tl4", "tl3", "tl2", "tl1", "tl0")
FIRE    = ramp("f4", "f3", "f2", "f1", "f0")

ALL_HEX = sorted(set(list(P.values()) + list(EXTRA.values())))
