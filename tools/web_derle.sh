#!/bin/sh
# Web (HTML5) surumunu exports/web klasorune disa aktarir; istenirse ZIP'ler.
# Kullanim (proje kokunden):  GODOT=/godot/yolu sh tools/web_derle.sh [--tek] [--zip] [--debug]
#   --tek    exports/babamin-donercisi.html: motor + oyun verisi icinde TEK dosya (~20 MB; file:// ile bile acilir)
#   --zip    exports/babamin-donercisi-web.zip dosyasini da uretir (index.html ZIP'in kokunde)
#   --debug  debug sablonuyla derler (konsol ayrintisi, "DEV" etiketi; yayin icin KULLANMA)
# Onkosul: Godot 4.7.2 + web sablonlari. Sablonlar yoksa (yalniz ~20 MB):  python tools/web_sablon_indir.py
# Sonuc: exports/web (oyun + embed-ornek.html + OKU-BENI.txt + web_sunucu.py). Denemek: python tools/web_sunucu.py
set -e
KOK="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KOK"
GODOT="${GODOT:-godot}"
KIP="--export-release"
ZIP=0
TEK=0
PY=python3
command -v python3 > /dev/null 2>&1 || PY=python
for a in "$@"; do
	case "$a" in
		--zip) ZIP=1 ;;
		--tek) TEK=1 ;;
		--debug) KIP="--export-debug" ;;
		*) echo "bilinmeyen secenek: $a" >&2; exit 2 ;;
	esac
done
mkdir -p exports
[ -f exports/.gdignore ] || : > exports/.gdignore      # Godot, disa aktarilan dosyalari projeye ice aktarmasin
CIKTI=exports/web
rm -rf "$CIKTI"
mkdir -p "$CIKTI"
"$GODOT" --headless --path . --import > /dev/null 2>&1 || true
if ! "$GODOT" --headless --path . "$KIP" "Web" "$CIKTI/index.html" > exports/web-derle.log 2>&1 || [ ! -f "$CIKTI/index.wasm" ]; then
	echo "HATA: web disa aktarma basarisiz (ayrinti: exports/web-derle.log)." >&2
	echo "Web sablonlari kurulu mu?  python tools/web_sablon_indir.py" >&2
	exit 1
fi
cp web/embed-ornek.html web/OKU-BENI.txt "$CIKTI/"
cp tools/web_sunucu.py "$CIKTI/web_sunucu.py"
echo "Web surumu hazir: $CIKTI ($(du -sk "$CIKTI" | cut -f1) KB)"
ls -l "$CIKTI" | awk 'NR>1 {printf "  %10d  %s\n", $5, $9}'
if [ "$TEK" = "1" ]; then
	"$PY" tools/web_tek_dosya.py "$CIKTI" exports/babamin-donercisi.html
fi
if [ "$ZIP" = "1" ]; then
	"$PY" - "$CIKTI" exports/babamin-donercisi-web.zip <<'PYEOF'
import os, sys, zipfile
klasor, hedef = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(hedef, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for ad in sorted(os.listdir(klasor)):
        yol = os.path.join(klasor, ad)
        if os.path.isfile(yol): z.write(yol, ad)
print("ZIP: %s (%.1f MB)" % (hedef, os.path.getsize(hedef) / 1048576))
PYEOF
fi
