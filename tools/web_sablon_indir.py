#!/usr/bin/env python3
"""Godot WEB dışa aktarma şablonlarını (yalnız web olanlar, ~20 MB) indirip Godot'un şablon klasörüne koyar.

Neden: Editörün "Manage Export Templates → Download" düğmesi TÜM platformların şablonlarını (~1,3 GB) indirir.
Web için yalnız iki küçük zip yeter. Bu araç büyük .tpz arşivinin içinden yalnız onları HTTP Range ile çeker.

Kullanım:
    python tools/web_sablon_indir.py                 # 4.7.2, bu bilgisayarın Godot şablon klasörüne
    python tools/web_sablon_indir.py --surum 4.7.3
    python tools/web_sablon_indir.py --hedef KLASOR  # başka klasöre (deneme)
    python tools/web_sablon_indir.py --zorla         # var olanların üzerine yaz

Sonra: GODOT=/godot/yolu sh tools/web_derle.sh
Yalnız standart kütüphane kullanır; HTTPS_PROXY ortam değişkenine uyar.
"""
import argparse
import io
import os
import shutil
import sys
import urllib.request
import zipfile

URL = "https://github.com/godotengine/godot/releases/download/{s}-stable/Godot_v{s}-stable_export_templates.tpz"
ISTENEN = ["templates/version.txt", "templates/web_nothreads_release.zip", "templates/web_nothreads_debug.zip"]


def sablon_klasoru(surum: str) -> str:
    if sys.platform.startswith("win"):
        taban = os.path.join(os.environ.get("APPDATA", os.path.expanduser("~")), "Godot", "export_templates")
    elif sys.platform == "darwin":
        taban = os.path.expanduser("~/Library/Application Support/Godot/export_templates")
    else:
        veri = os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
        taban = os.path.join(veri, "godot", "export_templates")
    return os.path.join(taban, surum + ".stable")


class UzakDosya(io.RawIOBase):
    """HTTP Range ile okunan, aranabilir salt-okunur dosya (zipfile bunun üstünden yalnız gereken parçaları çeker)."""
    BLOK = 4 * 1024 * 1024

    def __init__(self, url: str):
        yanit = urllib.request.urlopen(urllib.request.Request(url, headers={"Range": "bytes=0-0"}), timeout=60)
        self.url = yanit.geturl()          # GitHub imzalı depolama adresine yönlendirir
        self.boy = int(yanit.headers["Content-Range"].split("/")[1])
        yanit.read()
        self.konum = 0
        self.b0 = 0
        self.tampon = b""

    def readable(self):
        return True

    def seekable(self):
        return True

    def tell(self):
        return self.konum

    def seek(self, ofset, nereden=0):
        self.konum = ofset if nereden == 0 else (self.konum + ofset if nereden == 1 else self.boy + ofset)
        return self.konum

    def _getir(self, bas: int, son: int) -> bytes:
        for deneme in range(4):
            try:
                istek = urllib.request.Request(self.url, headers={"Range": "bytes=%d-%d" % (bas, son)})
                with urllib.request.urlopen(istek, timeout=120) as yanit:
                    return yanit.read()
            except Exception:
                if deneme == 3:
                    raise
        return b""

    def read(self, n=-1):
        if n is None or n < 0:
            n = self.boy - self.konum
        n = min(n, self.boy - self.konum)
        cikti = bytearray()
        while n > 0:
            if self.b0 <= self.konum < self.b0 + len(self.tampon):
                k = self.konum - self.b0
                parca = self.tampon[k:k + n]
                cikti += parca
                self.konum += len(parca)
                n -= len(parca)
            else:
                bas = self.konum
                self.tampon = self._getir(bas, min(self.boy - 1, bas + max(n, self.BLOK) - 1))
                self.b0 = bas
        return bytes(cikti)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--surum", default="4.7.2", help="Godot sürümü (varsayılan 4.7.2)")
    ap.add_argument("--hedef", default="", help="şablonların yazılacağı klasör (varsayılan: Godot'un şablon klasörü)")
    ap.add_argument("--zorla", action="store_true", help="var olan dosyaların üzerine yaz")
    a = ap.parse_args()
    hedef = a.hedef or sablon_klasoru(a.surum)
    gerekli = [os.path.basename(p) for p in ISTENEN]
    if not a.zorla and all(os.path.isfile(os.path.join(hedef, g)) for g in gerekli):
        print("Web şablonları zaten kurulu: %s" % hedef)
        return 0
    os.makedirs(hedef, exist_ok=True)
    url = URL.format(s=a.surum)
    print("İndiriliyor (yalnız web şablonları): %s" % url)
    try:
        arsiv = zipfile.ZipFile(UzakDosya(url))
        bulunan = {i.filename: i for i in arsiv.infolist()}
        for ad in ISTENEN:
            if ad not in bulunan:
                print("HATA: arşivde %s yok (sürüm numarası doğru mu?)" % ad, file=sys.stderr)
                return 1
            yol = os.path.join(hedef, os.path.basename(ad))
            with arsiv.open(bulunan[ad]) as kaynak, open(yol, "wb") as hdf:
                shutil.copyfileobj(kaynak, hdf)
            print("  yazıldı: %s (%.1f MB)" % (yol, os.path.getsize(yol) / 1048576))
    except Exception as e:
        print("HATA: şablonlar indirilemedi (%s). Ağ erişimini ya da sürüm numarasını kontrol et;" % e, file=sys.stderr)
        print("alternatif: Godot editörü → Editor → Manage Export Templates → Download and Install.", file=sys.stderr)
        return 1
    print("Tamam: %s" % hedef)
    return 0


if __name__ == "__main__":
    sys.exit(main())
