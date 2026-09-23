#!/bin/sh
# Tum betikleri Godot ayristiricisindan gecirir; hata varsa cikis kodu 1.
# Kullanim (proje kokunden): sh tests/kontrol.sh
GODOT="/c/Users/uchih/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
cikti=$(timeout 180 "$GODOT" --headless --path . --script tests/kontrol.gd 2>&1)
echo "$cikti" | grep -E "SCRIPT ERROR|Parse Error|HATA|KONTROL" | head -40
echo "$cikti" | grep -q "KONTROL TAMAM"
