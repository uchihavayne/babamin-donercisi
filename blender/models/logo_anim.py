"""BASLIK LOGOSU — B (SIS), ANIMASYONLU. Kullanici logo adaylarindan B'yi
secti ve "doner sisi donsun" dedi (2026-09-11).

    blender --background --factory-startup --python blender/models/logo_anim.py -- hepsi
    ... -- arka | sis | on          (tek katman, hizli deneme)
    python blender/logo_paketle.py  (sonra: kirp, paketle, js/logo-veri.js)

Tek resim yerine UC KATMAN. Hepsi ayni 320x112 tuvalde, ayni kamerayla
render ediliyor; oyun (js/logo.js -> logoCiz) ust uste koyuyor:

  arka : isitici panosu + kareleri (dil bagimsiz)
           arka_yak_0..5  atesleme: kareler alttan uste satir satir yanar
           arka_tit_00..  titreme dongusu: her kare kendi fazinda f3/f2/f1
  sis  : doner konisi + mil (dil bagimsiz), SIS_N kare = tam tur.
         Koni NESNE olarak donduruluyor: dikis oluklari, kesik katman
         cizgileri ve yag benekleri onunla doner; cel_nx golgesi DUNYA
         normalinden okundugu icin tonlar yerinde kalir. Oyunun kendi
         sisi (art.js drawSpit) de boyle doner.
  on   : kurdele + ust levha + yazi, dil basina bir kare (6 dil).

Katman sirasi = derinlik sirasi (isitici y=16 > sis y=2 > kurdele y=-22),
yani 2B'de ust uste koymak 3B render'in verecegi ortusmenin aynisi.

OLCU: telefonda baslik ekraninin gorunur bandi 34..126 (ust VIEW kirpmasi
ile BASLA dugmesi arasi) -> logo EN FAZLA 88 px. logo.py'deki onaylanan B
102 px idi ve telefonda ust 14 pikseli kesilecekti. Yazi boyu KORUNDU
(telefonda okunacak olan o); isitici 100 -> 73, koni 92 -> 78 px ve
"BABAMIN" levhasi kurdelenin ustune indi (asagida, yerlesim).
"""
import sys, os, math, json
import bpy
from mathutils import Vector

_HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(_HERE, "pxlib"))
sys.path.insert(0, os.path.join(_HERE, "models"))
import pxcore as px
import palette as pal
import logo as L                 # yazi, levha, kutu, cel ... (onaylanan B'nin parcalari)
import spit                      # oyunun kendi doner konisi

OUT = os.path.join(_HERE, "out", "logo_anim")
P = pal.P
SHEAR = 0.16

# Baslik metinleri js/i18n.js ile AYNI olmali ('BABAMIN' / 'DÖNERCİSİ'
# anahtarlarinin karsiliklari). Regres bunu kontrol ediyor: paketleyici
# metni js/logo-veri.js'e yaziyor, test T() ciktisiyla karsilastiriyor.
YAZI = {
    "tr": ("BABAMIN", "DÖNERCİSİ"),
    "en": ("MY FATHER'S", "KEBAB SHOP"),
    "de": ("MEINES VATERS", "DÖNERLADEN"),
    "es": ("EL LOCAL", "DE MI PADRE"),
    "fr": ("LA BOUTIQUE", "DE MON PÈRE"),
    "pt": ("A LOJA", "DO MEU PAI"),
}
DILLER = ("tr", "en", "de", "es", "fr", "pt")

# ---------------------------------------------------------------- yerlesim
# Ilk denemede "BABAMIN" levhasi sisin ORTASINDA duruyordu (onaylanan B'deki
# gibi): 88 px'e sikisinca kurdele + levha koninin %60'ini kapatiyor, donen
# et iki ince seritte kaliyordu. Levha artik kurdelenin USTUNE oturuyor
# (kurdele onde, levhanin alt kenarini ortuyor): yazi blogu altta tek parca,
# koni ustte ~36 px kesintisiz gorunuyor — donus okunuyor.
ISI_W, ISI_H, ISI_Z, ISI_Y = 96, 73, 2.0, 16      # isitici: alt ucu kurdelenin arkasinda
SATIR, SUTUN = 4, 6                                # satirlar USTTEN dizilir; alttakiler yazinin arkasinda
KONI_H, KONI_R, KONI_Z, KONI_Y = 78.0, 18.0, -4.0, 2.0
LEVHA_Z, LEVHA_H, LEVHA_Y = -1.0, 18, -20         # kurdelenin hemen ustu, ARKASINDA
YAZI_TABAN = LEVHA_Z - 2.5                         # levhanin kurdele USTUNDE kalan kismina ortali
RW, RZ, RH = 244, -24, 30                          # kurdele

# Onaylanan B'de pisme .66 idi: turuncu isitici karelerinin onunde et ayni
# tonda eriyordu. Daha pismis (kahverengi) koni kareden ayrisiyor.
ROAST = 0.84
SIS_N = 64                                         # tam tur kare sayisi
TIT_N = 12                                         # isitici titreme dongusu

ISI_RENK = {"sonuk": P["ui4"], "kor": P["f4"], 0: P["f3"], 1: P["f2"], 2: P["f1"]}


def sahne():
    L.sahne()                    # 320x112, ortografik kamera, isik


def bitir():
    px.shear_scene(SHEAR)


# ---------------------------------------------------------------- ARKA
def tit_seviye(r, c, f):
    """Titreme: her kare kendi fazinda yavas bir sinus, 3 kademe (f3/f2/f1).

    Fazlar ESIT DAGITILIYOR ((5r + 7c) mod 12): her karede her kademeden
    ayni sayida kare var, isiticinin toplam parlakligi sabit kaliyor, yalniz
    tek tek kareler kiprasiyor. Sozde-rastgele (sin-hash) fazla denendi:
    kucuk tamsayilarda fazlar kumelendi, butun pano birlikte sonup yandi."""
    faz = ((r * 5 + c * 7) % TIT_N) / float(TIT_N)
    a = 2 * math.pi * (f / float(TIT_N) + faz)
    v = 1.2 + 1.2 * math.sin(a)
    return max(0, min(2, int(round(v))))


def arka(durum):
    """durum(r, c) -> ISI_RENK anahtari. r=0 en ALT satir."""
    M_panel = L.cel("Panel", L.DARK)
    mats = {}
    def mat(k):
        if k not in mats:
            mats[k] = px.flat("Isi_%s" % k, ISI_RENK[k])
        return mats[k]
    L.levha("isitici", ISI_W, ISI_H, 5, 0, ISI_Z, ISI_Y, 6, 0.8, M_panel)
    z_ust = ISI_Z + ISI_H / 2.0 - 4 - 12            # en ust satirin tabani
    for r in range(SATIR):
        for c in range(SUTUN):
            x0 = -42 + c * 14.3
            z0 = z_ust - (SATIR - 1 - r) * 15.3
            L.kutu("kare", x0, x0 + 11, z0, z0 + 12, 11.5, 12.5, mat(durum(r, c)))


def arka_kareleri():
    """[(ad, durum)] — once atesleme, sonra titreme dongusu."""
    kareler = []
    for k in range(SATIR + 1):                    # 0: hepsi sonuk .. 5: hepsi yanik
        def d(r, c, k=k):
            if r < k - 1:
                return tit_seviye(r, c, 0)
            if r == k - 1:
                return "kor"                      # yeni tutusan satir: koyu kor
            return "sonuk"
        kareler.append(("arka_yak_%d" % k, d))
    for f in range(TIT_N):
        kareler.append(("arka_tit_%02d" % f, lambda r, c, f=f: tit_seviye(r, c, f)))
    return kareler


# ---------------------------------------------------------------- SIS
def sis(aci):
    """Oyunun konisi (spit.build_cone), olceklenip ortaya alinmis ve
    kendi ekseni etrafinda `aci` radyan dondurulmus."""
    M_meat = px.cel_nx("Et", spit.meat_ramp(ROAST), spit.NX_STOPS,
                       band=1.0, band_amt=0.010, noise=0.016, noise_scale=1.4,
                       specks=[
                           {"kind": "line", "color": spit.line_hex(ROAST),
                            "period": 12.0, "width": 1.0,
                            "dash": 0.55, "dash_scale": 13.0},
                           {"kind": "dot", "color": spit.fat_hex(ROAST),
                            "scale": 0.45, "size": 0.24, "min_n01": 0.50},
                       ])
    M_steel = L.cel("Celik", L.STEEL)
    cone = spit.build_cone(mass=1.0, cut=0.0, rot=0.6, seed=7)
    cone.data.materials.clear()
    cone.data.materials.append(M_meat)
    me = cone.data
    zs = [v.co.z for v in me.vertices]
    z0, z1 = min(zs), max(zs)
    sz = KONI_H / (z1 - z0)
    sr = KONI_R / spit.MAXR
    zc = (z0 + z1) / 2.0
    for v in me.vertices:                         # ekseni yerel orijine al
        v.co = Vector((v.co.x * sr, v.co.y * sr, (v.co.z - zc) * sz))
    me.update()
    cone.location = (0.0, KONI_Y, KONI_Z)
    cone.rotation_euler = (0.0, 0.0, aci)
    ust = KONI_Z + KONI_H / 2.0
    L.silindir("tepe", 6, 0, KONI_Y, ust + 1.5, 3, M_steel, seg=16)
    L.silindir("cubuk", 1.4, 0, KONI_Y, ust + 3.5, 6, M_steel, seg=10)


# ---------------------------------------------------------------- ON
def on(dil):
    M_red = L.cel("Kurdele", L.RED)
    M_red_d = L.cel("KurdeleArka", [P["red3"], P["red3"], P["red2"], P["red2"]])
    M_gold, M_cream = L.cel("Yaldiz", L.GOLD), L.cel("Krem", L.CREAM)
    M_levha = L.cel("Levhacik", [P["ui5"], P["ui5"], P["ui4"], P["ui4"]])
    M_golge = px.flat("Golge", P["red3"])

    kuyruk = [(-24, 11), (8, 11), (8, -11), (-24, -11), (-15, 0)]
    L.cokgen("kuyruk_sol", [(-q[0], q[1]) for q in kuyruk], -RW / 2 - 6, RZ - 5, -16, 3, 0.5, M_red_d)
    L.cokgen("kuyruk_sag", kuyruk, RW / 2 + 6, RZ - 5, -16, 3, 0.5, M_red_d)
    L.levha("kurdele", RW, RH, 3, 0, RZ, -22, 4, 0.9, M_red)

    ust, alt = YAZI[dil]
    genis = L.yazi_genisligi(ust, "arialblk", 11, 1.6)
    L.levha("ust_levha", min(200, genis + 18), LEVHA_H, 3, 0, LEVHA_Z, LEVHA_Y, 3, 0.6, M_levha)
    L.yazi(ust, "arialblk", 11, 0, YAZI_TABAN, LEVHA_Y - 3, 2.2, 0.4, M_cream, maxw=184, aralik=1.6)
    L.golgeli(alt, "arialblk", 20, 0, RZ - 10, -27.6, 2.6, 0.6, M_gold, M_golge,
              dx=1.4, dz=-1.4, golge_y=-25.2, maxw=RW - 24, aralik=0.6)


# ---------------------------------------------------------------- render
IZINLI = sorted(set(list(pal.ALL_HEX) + spit.meat_ramp(ROAST) + spit.steel_ramp()
                    + [spit.line_hex(ROAST), spit.fat_hex(ROAST)]))


def uret(ad):
    yol = px.render(os.path.join(OUT, ad + ".png"))
    if px.audit(yol, IZINLI, label=ad, show=0):
        px.quantize(yol, IZINLI)
    px.outline(yol, hexcol=P["ui5"], alpha=235)
    return yol


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    mod = argv[0] if argv else "hepsi"
    os.makedirs(OUT, exist_ok=True)
    yollar = []
    if mod in ("hepsi", "arka"):
        for ad, d in arka_kareleri():
            sahne(); arka(d); bitir()
            yollar.append(uret(ad))
    if mod in ("hepsi", "sis"):
        for i in range(SIS_N):
            sahne(); sis(2 * math.pi * i / SIS_N); bitir()
            yollar.append(uret("sis_%02d" % i))
    if mod in ("hepsi", "on"):
        for dil in DILLER:
            sahne(); on(dil); bitir()
            yollar.append(uret("on_" + dil))
    with open(os.path.join(OUT, "meta.json"), "w", encoding="utf-8") as fp:
        json.dump({"tuval": [L.W, L.H], "sis_n": SIS_N, "tit_n": TIT_N,
                   "yak_n": SATIR + 1, "yazi": YAZI, "diller": DILLER},
                  fp, ensure_ascii=False, indent=1)
    print("LOGO_ANIM_DONE %s (%d kare)" % (mod, len(yollar)))


if __name__ == "__main__":
    main()
