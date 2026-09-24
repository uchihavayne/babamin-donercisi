#!/bin/sh
# Tum testler: ayristirma + tabanin mantik testleri + gorsel testler (GPU).
# Kullanim (proje kokunden): sh tests/hepsi.sh   -> sonda "HEPSI GECTI" ya da kalanlar
GODOT="/c/Users/uchih/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
kalan=""
sh tests/kontrol.sh >/dev/null || kalan="$kalan kontrol"
for t in order_flow cutting module_services stations counter_input ingredient_input bread_preparation \
         economy mouse_slicing platform_input runtime_state module_snapshot regression mouse_knife \
         bahis_input akilli_hedef kapanis; do
	timeout 300 "$GODOT" --headless --path . --script tests/$t.gd --quit-after 3000 -- --test >/tmp/t_$t.log 2>&1 || kalan="$kalan $t"
	grep -q "SCRIPT ERROR" /tmp/t_$t.log && kalan="$kalan $t(hata)"
done
for t in counter_design_visual economy_visual mouse_slicing_visual order_flow_visual stations_visual \
         platform_visual ingredient_input_visual; do
	timeout 300 "$GODOT" --path . --script tests/$t.gd --quit-after 3000 -- --test --gpu-test >/tmp/t_$t.log 2>&1 || kalan="$kalan $t"
	grep -q "SCRIPT ERROR" /tmp/t_$t.log && kalan="$kalan $t(hata)"
done
git checkout -q -- validation/ 2>/dev/null
if [ -z "$kalan" ]; then echo "HEPSI GECTI"; else echo "KALAN:$kalan"; exit 1; fi
