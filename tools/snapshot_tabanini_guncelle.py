#!/usr/bin/env python3
"""Anlik goruntu referansini (validation/module-snapshot-baseline.json) GUVENLI guncelle.

tests/module_snapshot.gd cizim degisince "piksel" ozetleri farkli cikar; bu BEKLENEN
bir sey olabilir (bilincli gorsel degisiklik). Ama ayni test OYUN DURUMU ve KAYIT
icerigi degismisse gercek bir hata vardir. Bu arac yalnizca piksel ozetini degistirir;
durum ya da kayit farkliysa hicbir sey yazmadan durur.

Kullanim (proje kokunden):
    godot --headless --path . --script tests/module_snapshot.gd --quit-after 3000 -- --test
    python3 tools/snapshot_tabanini_guncelle.py            # farklari goster, yazma
    python3 tools/snapshot_tabanini_guncelle.py --yaz      # piksel farklarini tabana yaz
Sonra `git diff validation/module-snapshot-baseline.json` ile yalniz "pixels" satirlarinin
degistigine bak ve gorsel degisikligin istedigin sey oldugundan emin ol.
"""
import json
import sys
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
TABAN = KOK / "validation" / "module-snapshot-baseline.json"
YENI = KOK / "artifacts" / "module-snapshot-after.json"


def main() -> int:
    if not YENI.exists():
        print(f"{YENI} yok: once tests/module_snapshot.gd calistir")
        return 2
    ham = TABAN.read_text(encoding="utf-8")
    taban = json.loads(ham)
    yeni = json.loads(YENI.read_text(encoding="utf-8"))
    degisen, bozuk = [], []
    for ad, eski in taban.items():
        if ad == "save":
            if yeni.get(ad) != eski:
                bozuk.append("save (kayit icerigi degismis)")
            continue
        y = yeni.get(ad)
        if y is None:
            bozuk.append(f"{ad} (yeni calistirmada yok)")
            continue
        if y["state"] != eski["state"]:
            bozuk.append(f"{ad} (OYUN DURUMU degismis)")
        elif y["pixels"] != eski["pixels"]:
            degisen.append((ad, eski["pixels"], y["pixels"]))
    if bozuk:
        print("DURDU: piksel disinda fark var, bu bir hata olabilir -> tabana YAZILMADI:")
        for b in bozuk:
            print("  -", b)
        return 1
    if not degisen:
        print("Fark yok: taban zaten guncel.")
        return 0
    print("Yalniz piksel ozeti degisen sahneler:", ", ".join(a for a, _, _ in degisen))
    if "--yaz" not in sys.argv:
        print("Yazmak icin --yaz ekle (once degisikligin bilincli oldugundan emin ol).")
        return 0
    for ad, eski, y in degisen:
        if ham.count(eski) != 1:
            print(f"{ad}: eski ozet tabanda tek degil, elle bak")
            return 1
        ham = ham.replace(eski, y)
    TABAN.write_text(ham, encoding="utf-8")
    print(f"{len(degisen)} sahnenin piksel ozeti guncellendi.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
