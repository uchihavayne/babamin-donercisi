#!/usr/bin/env python3
"""Web sürümünü TEK bir .html dosyasına paketler: motor (wasm) + oyun verisi gzip + base64 ile sayfanın içine gömülür.

Kullanım:
    python tools/web_tek_dosya.py                          # exports/web  →  exports/babamin-donercisi.html
    python tools/web_tek_dosya.py KLASOR CIKTI.html
    python tools/web_tek_dosya.py --sina                   # Godot'suz kendi kendine sınama

Önce web sürümü dışa aktarılmış olmalı (GODOT=... sh tools/web_derle.sh). Çıktı ~20 MB'tır (wasm 38 MB → gzip ~10 MB → base64 ~13 MB).
Tarayıcı açılışta gömülü veriyi DecompressionStream ile açar (Chrome 80+, Firefox 113+, Safari 16.4+); yükleyici: web/tek_dosya_yukleyici.js.
Dosya tek başına çalışır: dosyaya çift tıklayıp (file://) da, bir sunucuya koyup da, başka bir sayfaya <iframe src=...> ile de gömülebilir.
Yalnız standart kütüphane kullanır. Aynı girdi her zaman aynı çıktıyı verir (gzip zaman damgası sıfır).
"""
import argparse
import base64
import gzip
import io
import os
import re
import sys

KOK = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
YUKLEYICI = os.path.join(KOK, "web", "tek_dosya_yukleyici.js")


class TekDosyaHatasi(Exception):
    pass


def oku(klasor: str, ad: str) -> bytes:
    yol = os.path.join(klasor, ad)
    if not os.path.isfile(yol):
        raise TekDosyaHatasi("%s yok (önce web sürümünü dışa aktar: sh tools/web_derle.sh)" % yol)
    with open(yol, "rb") as f:
        return f.read()


def gzip_bayt(veri: bytes) -> bytes:
    tampon = io.BytesIO()
    with gzip.GzipFile(fileobj=tampon, mode="wb", compresslevel=9, mtime=0) as g:   # mtime=0: tekrarlanabilir çıktı
        g.write(veri)
    return tampon.getvalue()


def metin_guvenli(veri: bytes, ad: str) -> str:
    """Satır içi <script> bloğuna ham konabilecek metin: ayrıştırıcıyı bozan diziler yoksa olduğu gibi döner."""
    metin = veri.decode("utf-8")
    for yasak in ("</script", "<!--", "-->"):
        if yasak in metin.lower():
            raise TekDosyaHatasi("%s içinde '%s' var; satır içi gömmek güvenli değil" % (ad, yasak))
    return metin


def paketle(klasor: str, cikti: str, yukleyici_yolu: str = YUKLEYICI) -> dict:
    """klasor (Godot web dışa aktarımı) → tek dosyalık cikti. Boyut bilgisi döner."""
    html = oku(klasor, "index.html").decode("utf-8")
    motor_js = metin_guvenli(oku(klasor, "index.js"), "index.js")
    with open(yukleyici_yolu, "rb") as f:
        yukleyici = metin_guvenli(f.read(), "tek_dosya_yukleyici.js")
    ses1 = metin_guvenli(oku(klasor, "index.audio.worklet.js"), "index.audio.worklet.js")
    ses2 = metin_guvenli(oku(klasor, "index.audio.position.worklet.js"), "index.audio.position.worklet.js")
    simge = base64.b64encode(oku(klasor, "index.icon.png")).decode("ascii")

    # dışarıdan dosya isteyen satırlar: motor betiği ve simgeler
    motor_etiketi = '<script src="index.js"></script>'
    if html.count(motor_etiketi) != 1:
        raise TekDosyaHatasi("index.html içinde %s tek kez bulunamadı (kabuk değişmiş olabilir)" % motor_etiketi)
    html, n1 = re.subn(r'<link id="-gd-engine-icon"[^>]*>', '<link rel="icon" type="image/png" href="data:image/png;base64,%s">' % simge, html)
    html, n2 = re.subn(r'\s*<link rel="apple-touch-icon"[^>]*>', "", html)
    if n1 != 1 or n2 != 1:
        raise TekDosyaHatasi("simge bağlantıları beklenen biçimde değil (%d, %d)" % (n1, n2))

    boyutlar = {}
    bloklar = []
    for ad in ("index.wasm", "index.pck"):
        ham = oku(klasor, ad)
        sikisik = gzip_bayt(ham)
        b64 = base64.b64encode(sikisik).decode("ascii")
        boyutlar[ad] = (len(ham), len(sikisik), len(b64))
        bloklar.append('<script type="application/octet-stream" data-ad="%s">%s</script>' % (ad, b64))
    bloklar.append('<script type="text/plain" data-ad="index.audio.worklet.js">%s</script>' % ses1)
    bloklar.append('<script type="text/plain" data-ad="index.audio.position.worklet.js">%s</script>' % ses2)

    # dosya iniyorken (betikler henüz çalışmadan) açılış ekranında boyut ipucu: dilden bağımsız
    mb = sum(v[2] for v in boyutlar.values()) / 1048576
    html = html.replace('<p id="yuzde">…</p>', '<p id="yuzde">%d MB …</p>' % round(mb), 1)

    # sıra önemli: veri blokları → yükleyici (fetch / AudioWorklet yönlendirmesi) → motor → kabuk betiği
    yerine = "\n".join(bloklar) + "\n<script>\n" + yukleyici + "\n</script>\n<script>\n" + motor_js + "\n</script>"
    # açıklama satırı DOCTYPE'tan önce değil, charset bildiriminden sonra (karakter kodlaması ilk 1024 bayt içinde okunur; yalnız ASCII)
    karakter = '<meta charset="utf-8">'
    if html.count(karakter) != 1:
        raise TekDosyaHatasi("index.html içinde %s tek kez bulunamadı" % karakter)
    html = html.replace(karakter, karakter + "\n\t\t<!-- Babamin Donercisi / My Father's Kebab Shop: single-file web build (engine + game data embedded). Generator: tools/web_tek_dosya.py -->", 1)
    sonuc = html.replace(motor_etiketi, yerine)

    os.makedirs(os.path.dirname(os.path.abspath(cikti)), exist_ok=True)
    with open(cikti, "w", encoding="utf-8", newline="\n") as f:
        f.write(sonuc)
    return {"boyutlar": boyutlar, "toplam": os.path.getsize(cikti)}


def kendini_sina() -> None:
    """Godot'suz, kendi içinde sınama: sahte bir dışa aktarım klasörü paketlenir ve çıktının yapısı doğrulanır."""
    import random
    import tempfile
    rnd = random.Random(7)
    with tempfile.TemporaryDirectory() as gecici:
        girdi = os.path.join(gecici, "girdi")
        os.makedirs(girdi)
        sahte = {
            "index.wasm": bytes(rnd.randrange(256) for _ in range(5000)) + b"\0asm" * 3000,
            "index.pck": bytes(rnd.randrange(256) for _ in range(3000)),
            "index.icon.png": bytes(rnd.randrange(256) for _ in range(300)),
            "index.js": b"var Godot=function(){return 1};\n",
            "index.audio.worklet.js": b"class A{} // ses 1\n",
            "index.audio.position.worklet.js": b"class B{} // ses 2\n",
            "index.html": ('<!DOCTYPE html><html><head><meta charset="utf-8"><link id="-gd-engine-icon" rel="icon" type="image/png" href="index.icon.png" />\n'
                           '<link rel="apple-touch-icon" href="index.apple-touch-icon.png"/></head><body><canvas id="canvas"></canvas>'
                           '<p id="yuzde">…</p><script src="index.js"></script><script>const GODOT_CONFIG = {};</script></body></html>').encode("utf-8"),
        }
        for ad, veri in sahte.items():
            with open(os.path.join(girdi, ad), "wb") as f:
                f.write(veri)
        cikti = os.path.join(gecici, "oyun.html")
        paketle(girdi, cikti)
        metin = open(cikti, encoding="utf-8").read()
        # 1) gömülü veri, sıkıştırma ve base64'ten geri açılınca bire bir aynı
        for ad in ("index.wasm", "index.pck"):
            m = re.search(r'<script type="application/octet-stream" data-ad="%s">([^<]*)</script>' % re.escape(ad), metin)
            assert m, ad + " bloğu yok"
            assert gzip.decompress(base64.b64decode(m.group(1))) == sahte[ad], ad + " geri açılınca farklı"
        # 2) ses işleyicileri ham metin olarak
        assert 'data-ad="index.audio.worklet.js">class A{} // ses 1' in metin and 'data-ad="index.audio.position.worklet.js">class B{} // ses 2' in metin
        # 3) dışarıdan dosya isteyen hiçbir etiket kalmadı
        assert 'src="index.js"' not in metin and 'href="index.icon.png"' not in metin and "apple-touch-icon" not in metin
        assert 'href="data:image/png;base64,' in metin
        # 4) sıra: veri blokları → yükleyici → motor → kabuk betiği
        k_veri = metin.index('data-ad="index.pck"')
        k_yukleyici = metin.index("var gercekFetch")   # yükleyici betiğinin ilk satırlarından
        k_motor = metin.index("var Godot=function")
        k_kabuk = metin.index("const GODOT_CONFIG")
        assert k_veri < k_yukleyici < k_motor < k_kabuk, "betik sırası yanlış"
        assert metin.count("var Godot=function") == 1
        assert metin.startswith("<!DOCTYPE html>") and metin.index('<meta charset="utf-8">') < metin.index("<!--"), "DOCTYPE ilk, açıklama charset'ten sonra olmalı"
        assert metin[:1024].isascii() or '<meta charset="utf-8">' in metin[:1024], "charset ilk 1024 bayt içinde olmalı"
        # 5) tekrarlanabilir: aynı girdi aynı çıktı
        cikti2 = os.path.join(gecici, "oyun2.html")
        paketle(girdi, cikti2)
        assert open(cikti, "rb").read() == open(cikti2, "rb").read(), "çıktı tekrarlanabilir değil"
        # 6) güvensiz motor betiği reddedilir
        with open(os.path.join(girdi, "index.js"), "wb") as f:
            f.write(b"var x='</script>';")
        try:
            paketle(girdi, os.path.join(gecici, "kotu.html"))
            raise AssertionError("</script içeren motor betiği reddedilmedi")
        except TekDosyaHatasi:
            pass
        # 7) kabuk değişmişse (beklenen etiket yoksa) sessizce geçmez
        with open(os.path.join(girdi, "index.js"), "wb") as f:
            f.write(sahte["index.js"])
        with open(os.path.join(girdi, "index.html"), "wb") as f:
            f.write(b"<html><body>bos</body></html>")
        try:
            paketle(girdi, os.path.join(gecici, "kotu2.html"))
            raise AssertionError("beklenen etiketsiz kabuk reddedilmedi")
        except TekDosyaHatasi:
            pass
    print("TEK DOSYA SINAMASI TAMAM")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("klasor", nargs="?", default=os.path.join(KOK, "exports", "web"))
    ap.add_argument("cikti", nargs="?", default=os.path.join(KOK, "exports", "babamin-donercisi.html"))
    ap.add_argument("--sina", action="store_true", help="Godot'suz kendi kendine sınama (hepsi.sh / tests/web_ortam.gd çağırır)")
    a = ap.parse_args()
    if a.sina:
        kendini_sina()
        return 0
    try:
        bilgi = paketle(a.klasor, a.cikti)
    except TekDosyaHatasi as e:
        print("HATA: %s" % e, file=sys.stderr)
        return 1
    for ad, (ham, sik, b64) in bilgi["boyutlar"].items():
        print("  %-10s ham %9d  gzip %9d  base64 %9d" % (ad, ham, sik, b64))
    print("Tek dosya: %s (%.1f MB)" % (a.cikti, bilgi["toplam"] / 1048576))
    return 0


if __name__ == "__main__":
    sys.exit(main())
