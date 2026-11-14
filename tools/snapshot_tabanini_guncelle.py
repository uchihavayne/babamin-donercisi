#!/usr/bin/env python3
"""Anlik goruntu referansini (validation/module-snapshot-baseline.json) GUVENLI guncelle.

tests/module_snapshot.gd cizim degisince "piksel" ozetleri farkli cikar; bu BEKLENEN
bir sey olabilir (bilincli gorsel degisiklik). Ama ayni test OYUN DURUMU ve KAYIT
icerigi degismisse gercek bir hata vardir. Bu arac varsayilan olarak yalnizca piksel
ozetini degistirir; durum ya da kayit farkliysa hicbir sey yazmadan durur.

Yeni bir ilerleme kaydi alani eklediysen (save_system.f_saveAll) "save" referansi
BILINCLI olarak degisir: --kayit ile o fark da kabul edilir (hangi alanlarin eklendigi /
silindigi / degistigi once yazdirilir).

Kullanim (proje kokunden):
    godot --headless --path . --script tests/module_snapshot.gd --quit-after 3000 -- --test
    python3 tools/snapshot_tabanini_guncelle.py                   # farklari goster, yazma
    python3 tools/snapshot_tabanini_guncelle.py --yaz             # piksel farklarini tabana yaz
    python3 tools/snapshot_tabanini_guncelle.py --kayit --yaz     # kayit alani degisikligini de yaz
Sonra `git diff validation/module-snapshot-baseline.json` ile yalniz beklenen satirlarin
degistigine bak ve degisikligin istedigin sey oldugundan emin ol.
"""
import json
import sys
from pathlib import Path

KOK = Path(__file__).resolve().parent.parent
TABAN = KOK / "validation" / "module-snapshot-baseline.json"
YENI = KOK / "artifacts" / "module-snapshot-after.json"


def kayit_farki_ozeti(eski: str, yeni: str) -> list[str]:
    """Iki kayit metninin ust duzey alan farklarini okunur satirlar olarak dondurur."""
    try:
        a, b = json.loads(eski), json.loads(yeni)
    except ValueError:
        return ["(kayit metni JSON olarak okunamadi)"]
    satirlar = []
    for k in sorted(set(a) | set(b)):
        if k not in a:
            satirlar.append(f"  + {k} = {json.dumps(b[k], ensure_ascii=False)[:70]}")
        elif k not in b:
            satirlar.append(f"  - {k}")
        elif a[k] != b[k]:
            satirlar.append(f"  ~ {k}: {json.dumps(a[k], ensure_ascii=False)[:40]} -> {json.dumps(b[k], ensure_ascii=False)[:40]}")
    return satirlar


def main() -> int:
    if not YENI.exists():
        print(f"{YENI} yok: once tests/module_snapshot.gd calistir")
        return 2
    kayit_izni = "--kayit" in sys.argv
    ham = TABAN.read_text(encoding="utf-8")
    taban = json.loads(ham)
    yeni = json.loads(YENI.read_text(encoding="utf-8"))
    degisen, bozuk, kayit_degisti = [], [], None
    for ad, eski in taban.items():
        if ad == "save":
            if yeni.get(ad) != eski:
                kayit_degisti = (eski, yeni.get(ad))
            continue
        y = yeni.get(ad)
        if y is None:
            bozuk.append(f"{ad} (yeni calistirmada yok)")
            continue
        if y["state"] != eski["state"]:
            bozuk.append(f"{ad} (OYUN DURUMU degismis)")
        elif y["pixels"] != eski["pixels"]:
            degisen.append((ad, eski["pixels"], y["pixels"]))
    if kayit_degisti and not isinstance(kayit_degisti[1], str):
        bozuk.append("save (yeni calistirmada yok)")
        kayit_degisti = None
    if kayit_degisti and not kayit_izni:
        bozuk.append("save (kayit icerigi degismis; yeni bir kayit alani eklediysen bilincli: --kayit)")
    if bozuk:
        print("DURDU: piksel disinda fark var, bu bir hata olabilir -> tabana YAZILMADI:")
        for b in bozuk:
            print("  -", b)
        if kayit_degisti:
            print("Kayit alani farklari:")
            print("\n".join(kayit_farki_ozeti(*kayit_degisti)))
        return 1
    if not degisen and not kayit_degisti:
        print("Fark yok: taban zaten guncel.")
        return 0
    if degisen:
        print("Piksel ozeti degisen sahneler:", ", ".join(a for a, _, _ in degisen))
    if kayit_degisti:
        print("Kayit (save) referansi degisecek; alan farklari:")
        print("\n".join(kayit_farki_ozeti(*kayit_degisti)))
    if "--yaz" not in sys.argv:
        print("Yazmak icin --yaz ekle (once degisikligin bilincli oldugundan emin ol).")
        return 0
    for ad, eski, y in degisen:
        if ham.count(eski) != 1:
            print(f"{ad}: eski ozet tabanda tek degil, elle bak")
            return 1
        ham = ham.replace(eski, y)
    if kayit_degisti:
        # taban dosyasi Godot bicimli (tab girintili); kayit metni orada kacisli dize olarak durur
        eski_k = json.dumps(kayit_degisti[0], ensure_ascii=False)
        yeni_k = json.dumps(kayit_degisti[1], ensure_ascii=False)
        if ham.count(eski_k) != 1:
            print("save: eski kayit metni tabanda tek bir yerde bulunamadi, elle guncelle")
            return 1
        ham = ham.replace(eski_k, yeni_k)
    TABAN.write_text(ham, encoding="utf-8")
    print(f"{len(degisen)} sahnenin piksel ozeti" + (" ve save referansi" if kayit_degisti else "") + " guncellendi.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
