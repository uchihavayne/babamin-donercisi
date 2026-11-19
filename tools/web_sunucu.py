#!/usr/bin/env python3
"""Web surumunu yerelde denemek icin kucuk statik sunucu (yalniz standart kutuphane).

Kullanim:
    python3 tools/web_sunucu.py                      # exports/web (ya da betigin yanindaki klasor) http://127.0.0.1:8060 adresinde sunulur
    python3 tools/web_sunucu.py KLASOR --port 9000   # baska klasor / port
    python3 tools/web_sunucu.py --izole              # COOP/COEP basliklari (yalniz is parcacikli derleme icin gerekir)

Neden gerekli: tarayicilar file:// ile acilan .wasm / .pck dosyalarini yuklemez, sayfa http(s) ile sunulmali.
Bu sunucu .wasm icin dogru MIME turunu verir ve onbellegi kapatir (her denemede guncel dosya).
Yayin icin bu sunucu gerekmez: herhangi bir statik barindirma (itch.io, GitHub Pages, Netlify, kendi sunucun) yeter.
"""
import argparse
import functools
import http.server
import os
import socketserver
import sys


class Isleyici(http.server.SimpleHTTPRequestHandler):
    izole = False
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".js": "text/javascript",
        ".mjs": "text/javascript",
        ".pck": "application/octet-stream",
        ".json": "application/json",
        ".webmanifest": "application/manifest+json",
    }

    def end_headers(self) -> None:
        self.send_header("Cache-Control", "no-store")
        if self.izole:
            self.send_header("Cross-Origin-Opener-Policy", "same-origin")
            self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def log_message(self, fmt: str, *args) -> None:  # sessiz: yalniz hatalar
        if args and str(args[1]).startswith(("4", "5")):
            sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    # varsayilan: betigin yanindaki klasor (web ZIP'inin icinde), yoksa projenin exports/web klasoru
    yan = os.path.dirname(os.path.abspath(__file__))
    varsayilan = yan if os.path.isfile(os.path.join(yan, "index.html")) else os.path.join(yan, "..", "exports", "web")
    ap.add_argument("klasor", nargs="?", default=varsayilan)
    ap.add_argument("--port", type=int, default=8060)
    ap.add_argument("--izole", action="store_true", help="COOP/COEP basliklarini ekle")
    a = ap.parse_args()
    kok = os.path.abspath(a.klasor)
    if not os.path.isfile(os.path.join(kok, "index.html")):
        print("HATA: %s icinde index.html yok (once web surumunu disa aktar: sh tools/web_derle.sh)" % kok, file=sys.stderr)
        return 1
    Isleyici.izole = a.izole
    isleyici = functools.partial(Isleyici, directory=kok)
    socketserver.ThreadingTCPServer.allow_reuse_address = True
    with socketserver.ThreadingTCPServer(("127.0.0.1", a.port), isleyici) as sunucu:
        print("Sunuluyor: http://127.0.0.1:%d/  (klasor: %s)  Durdurmak icin Ctrl+C" % (a.port, kok), flush=True)
        try:
            sunucu.serve_forever()
        except KeyboardInterrupt:
            print("\nDurduruldu.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
