# Kazanç ve geliştirme dengesi — 0.7.0

Amaç: ilk gün anlamlı bir iyileştirme alabilmek, birkaç gün içinde yeni ürün açmak, sonraki seviyelerde hız/kapasite kazanmak. Başlangıç araçları kullanılabilir kalır; otomatik kesici ve diğer tam otomasyonlar son seviyelerdedir.

## Satış fiyatları

| Ürün | Önce | Şimdi |
| --- | ---: | ---: |
| Sade dürüm | 15 | 20 |
| İçecek | 10 | 13 |
| Patates porsiyon | 12 | 15 |
| Ayran | 9 | 12 |
| Tatlı | 14 | 18 |
| İskender (ekler hariç) | 29 | 37 |

Izgara farkı 7→8, sos 4→5, domates 5→6, biber 6→8. Ana ürünlerin satış fiyatı yaklaşık %25–33 arttı. Hızlı servis bahşişi aynı formülü kullanır; %18 borç kesintisi, şehir/şube gelirleri ve 1,9 telefon siparişi çarpanı korunur.

Para parçalarına bölünürken her parçanın ayrı yuvarlanması bazen kasa ile satış raporunu farklı yapıyordu. Artık kalan birimler parçalar arasında dağıtılır: örneğin 23 birimlik ödeme 12+11 gelir. Gösterilen gelir, toplanan para ve borç hesabı aynı tutarı kullanır.

## Ekipman fiyatları

Her tutar **o seviyeye geçişte ödenen ek fiyat**tır; birikimli toplam değildir. Seviye sayıları ve mevcut kayıtların ekipman kimlikleri aynı kalır. Daha önce alınan seviyeler korunur; geriye dönük para iadesi yapılmaz.

| Ekipman | Önceki seviye fiyatları | Yeni seviye fiyatları |
| --- | --- | --- |
| Bıçak | 250 / 700 / 1800 / 4200 | 100 / 360 / 1100 / 3600 |
| Servis Maşası | 300 / 900 / 2200 | 110 / 480 / 1600 |
| Patates Bıçağı | 260 / 750 / 1900 / 4400 | 100 / 380 / 1200 / 3800 |
| Fritöz | 320 / 950 / 2300 / 5200 | 150 / 520 / 1500 / 4400 |
| Kağıt Makinesi | 450 / 1900 | 180 / 1400 |
| Izgara | 700 / 1700 / 3800 / 8000 | 260 / 1000 / 2700 / 6500 |
| İçecek Standı | 600 / 1500 / 3400 / 7000 | 220 / 850 / 2400 / 5800 |
| Patates Porsiyon | 550 / 1800 | 180 / 1250 |
| Ayran Kazanı | 800 / 2200 | 260 / 1550 |
| Tatlı Tepsisi | 1100 / 2900 | 360 / 2100 |
| Domates & Biber | 1500 / 3800 | 500 / 2800 |
| Sos Standı | 900 / 3200 | 300 / 2300 |
| İskender Tabağı | 2200 / 5000 / 11000 | 800 / 3200 / 8500 |
| Geniş Tezgâh | 700 / 2400 | 280 / 1600 |
| Çırak | 900 / 2800 / 6500 | 380 / 1800 / 5000 |
| Telefon & Motor | 1300 / 3400 / 7500 | 550 / 2300 / 5800 |
| Dayı | 550 / 1600 / 3800 | 240 / 1050 / 2800 |
| Depo | 240 / 700 / 1700 | 100 / 400 / 1200 |
| Güvenlik | 700 / 2000 / 4800 / 9500 | 300 / 1300 / 3500 / 7500 |
| Tabela & Reklam | 480 / 1400 / 3200 | 220 / 850 / 2300 |
| Dükkânı Büyüt | 1100 / 3000 / 6800 | 480 / 1950 / 5000 |
| Malzeme Seçimi | 2600 / 6400 | 450 / 2600 |
| Jeneratör | 1400 / 3800 / 8600 | 650 / 2600 / 6800 |
| Boya & Dekor | 200 / 550 / 1200 | 90 / 330 / 900 |

## Hız ve kapasite

Mevcut seviye etkileri korunur. Mağaza kartı artık gerçekten kullanılan ayarlardan **önce → sonra** değerini okur. İlk alımda “SATIN AL”, sonraki seviyelerde “GELİŞTİR” görünür. Açılmamış bir makinede yanıltıcı “0 saniye” yerine alınacak makinenin değeri gösterilir. Bu bilgiler yalnızca mağaza kartındadır.

- **Maşa:** işlem başına 1 → 2 → 3 → 4 malzeme.
- **Fritöz:** 8,5 → 6,5 → 4,8 → 3,4 → 2,4 saniye; sepet 26 → 32 → 40 → 50 → 62.
- **İçecek standı:** ilk alımda 3,2 saniye; ardından 2,2 → 1,3 → 0,6. Son seviye otomatik.
- **Bıçak:** 0,50 → 0,38 → 0,30 → 0,24 → 0,18 saniye. Her kesişte 3 et, tepsi kapasitesi 16; son seviye otomatik kesici. Önceki kesme hissi korunur.
- **Kağıt makinesi:** 0,85 → 0,40 → 0,20 saniye; son seviye otomatik sarma.

## 12 günlük ekonomi senaryosu

Bu bir **sabit iş yükü karşılaştırmasıdır**, gerçek oyuncunun hızının ölçümü değildir. Her gün 6/8/10 doğru dürüm siparişi, teslimatta %70 sabır ve güneşli hava varsayılır. İçecek açılınca her üçüncü siparişe içecek eklenir; ızgara açılınca dürümler ızgaralı hazırlanır. Gerçek servis, bahşiş, para toplama, borç, satın alma ve kayıt fonksiyonları kullanılır. Telefon/şube geliri, gece kaybı ve cezalar dahil edilmez. Hazırlama süresi ve kaçan müşteri model dışındadır; iki fiyat eğrisinde de doğru para bölüşümü kullanılır.

Satın alma önceliği: maşa, bıçak, içecek, fritöz, kağıt, depo, malzeme seçimi, ızgara, çırak, maşa 2, telefon, bıçak 2. Başka tercihlerde tarihler değişir.

| Günlük sipariş | İlk gün net (önce → sonra) | İlk maşa günü (önce → sonra) | İçecek açılışı (önce → sonra) |
| --- | --- | --- | --- |
| 6 | 84 → 113 | 4 → 1 | 12 günde yok → 4 |
| 8 | 112 → 151 | 3 → 1 | 11 → 3 |
| 10 | 139 → 189 | 3 → 1 | 9 → 3 |

Günde 6 sipariş senaryosunda ilk günün 113 net kazancı ilk maşanın 110 fiyatını karşılar. Aynı oyuncu 2. gün bıçak, 4. gün içecek, 5. gün fritöz alabilir. Otomasyonun son seviyeleri bu ilk 12 günlük sırada henüz alınmaz. Oyuncu denemeleriyle tempo yeniden değerlendirilebilir; bu sonuçlar herkes için garanti değildir.

## Nereden ayarlanır?

- `scripts/systems/recipe_system.gd`: ürün fiyatları (`PRICE`).
- `data/upg.gd`: her ekipmanın seviye fiyatı (`lv[].p`).
- `scripts/systems/equipment_tuning.gd`: gerçek süre, kapasite ve otomasyon koşulları.
- `scripts/systems/upgrade_system.gd`: satın alma doğrulaması, seviye önizlemesi ve mağaza düğmesi.
- `scripts/systems/payment_system.gd`: ödeme tutarının para parçalarına dağıtılması.

Test: `godot --headless --path . --script tests/economy.gd -- --test`.
Görsel/girdi testi: `godot --path . --script tests/economy_visual.gd -- --test --gpu-test`.
Sonuçlar: `validation/economy-results.json`, `validation/economy/visual-results.json`.
Önceki fiyatlar karşılaştırma için `tests/fixtures/economy-0.6.1.json` içinde korunur.

## Birleşik sürüm: fiyatlar yeniden yükseltildi

Kullanıcı: "upgrade maliyetleri biraz ucuz, diğer oyunda öyle değildi". Satış fiyatları (0.7.0) aynı; her ekipman seviyesi 0.7.0 fiyatı ile remake (0.6.1) fiyatının ortasına çekildi (onluğa yuvarlı). İlk seviyeler yaklaşık %75, son seviyeler yaklaşık %20 pahalandı. Sabit iş yükü simülasyonunda (6/8/10 sipariş) ilk yararlı alım 2. gün, ilk yeni ürün 5–7. gün (0.7.0: 1. gün / 3–5. gün; 0.6.1: 3–4. gün).

| Ekipman | Seviye fiyatları |
| --- | --- |
| Bıçak | 180 / 530 / 1450 / 3900 |
| Servis Maşası | 200 / 690 / 1900 |
| Patates Bıçağı | 180 / 560 / 1550 / 4100 |
| Fritöz | 240 / 740 / 1900 / 4800 |
| Kağıt Makinesi | 320 / 1650 |
| Izgara | 480 / 1350 / 3250 / 7250 |
| İçecek Standı | 410 / 1180 / 2900 / 6400 |
| Patates Porsiyon | 360 / 1520 |
| Ayran Kazanı | 530 / 1880 |
| Tatlı Tepsisi | 730 / 2500 |
| Domates & Biber | 1000 / 3300 |
| Sos Standı | 600 / 2750 |
| İskender Tabağı | 1500 / 4100 / 9750 |
| Geniş Tezgâh | 490 / 2000 |
| Çırak | 640 / 2300 / 5750 |
| Telefon & Motor | 920 / 2850 / 6650 |
| Dayı | 400 / 1320 / 3300 |
| Depo | 170 / 550 / 1450 |
| Güvenlik | 500 / 1650 / 4150 / 8500 |
| Tabela & Reklam | 350 / 1120 / 2750 |
| Dükkânı Büyüt | 790 / 2480 / 5900 |
| Malzeme Seçimi | 1520 / 4500 |
| Jeneratör | 1020 / 3200 / 7700 |
| Boya & Dekor | 140 / 440 / 1050 |

## Uzun vadeli tempo (6. tur, `tests/tempo.gd`)

Gerçek sipariş üretimi, fiyatlar, gün sonu (şube geliri + %18 borç kesintisi) ve satın alma fonksiyonlarıyla 200 günlük simülasyon. Oyuncu gelen müşterinin (`dayCfg`: `(len - 25) / rate`) belli bir oranına yetişir. Telefon, Dayı, bahşiş ve olay gelirleri yok; tarihler temkinli. Toplam 70 yükseltme seviyesi, 9 şube.

| Alım kuralı | Yetişme | İlk şube | Yükseltmeler biter | Borç biter | 60. gün kalan borç |
| --- | --- | --- | --- | --- | --- |
| En ucuz yükseltme | %55 | 35. gün | ~60. gün | 107. gün | $4,95M |
| En ucuz yükseltme | %70 | 26. gün | ~50. gün | 93. gün | $4,89M |
| En ucuz yükseltme | %85 | 24. gün | ~45. gün | 84. gün | $4,77M |
| Şubeye biriktir | %55 | 25. gün | ~80. gün | 93. gün | $4,89M |
| Şubeye biriktir | %70 | 23. gün | ~75. gün | 85. gün | $4,79M |
| Şubeye biriktir | %85 | 21. gün | ~70. gün | 78. gün | $4,54M |

Bulgular: 120 gün başarımı her profilde tutuyor. Borç ilk 60 günde %10'dan az eriyor, sonra şube geliriyle (New York 570 bin/gün) 25-30 günde bitiyor. Yani uzun süre borç çubuğu kıpırdamıyor. Yükseltmeler 45-80. günde tükeniyor, sonrasında yalnız şube alınabiliyor.

```sh
godot --headless --path . --script tests/tempo.gd --quit-after 1000000 -- --test [--gun 200]
```

Gece hırsızı dahil (`--hirsiz`, gerçek `f_rollNight`, güvenlik yükseltmesi azaltır; şubeye biriktiren oyuncu): borç 95. / 87. / 82. günde biter (hırsızsız 93 / 85 / 78). 200 günde çalınan toplam $13-88 bin, geç oyunda önemsiz. Olay sıklıkları: maç günü 8-12 günde bir (6. günden), kedi %30/gün (4. günden), elektrik kesintisi %16/gün (8. günden, 34 sn), rakip teklifi 5-8 günde bir (panelde 20 sn geri sayım), hırsız %24 ziyaret × %62 çalma (güvenliksiz), paranın %8-20'si.

## 8. tur: ilk günlerin temposu ve tekrar (oyuncu eleştirisi)

Eleştiri: "En basit şeyi almak için 7-8 tur oynuyorsun; sürekli aynı şeye defalarca bastırarak keyif olmaz." Ölçüm doğruladı: ilk 3 gün 5-6 müşteri geliyordu (gün ~62 sn), günlük net $49-66; oyunu değiştiren ilk alım 7-10. güne kalıyordu. Sade dürüm ~20 tık tutuyordu, 16'sı aynı malzemeye 4'er kez basmaktı (tam porsiyon ancak maşa 3'te, toplam $2.790).

Değişenler:

- **Tek tık = tam porsiyon** (et 4, turşu 4, yoğurt 4, patates 4, iskender eti 5, domates 3, biber 2). Dürüm ~20 → ~8 tık. Stok yetmezse kalan kadar konur.
- **Servis Maşası** yeni görev (Geniş Tezgâh gerekli): 1. seviye tıklanan malzemeyi 2, 2. seviye 3 ürüne birden koyar (akıllı hedefle; siparişin istemediği malzeme gitmez). 3. seviye (porsiyon kepçesi): turşu / yoğurt / patates tıklaması üç yan malzemeyi birlikte koyar. `assembly_system.masa_yay`, test `tests/tek_tik.gd`.
- **İlk seviye fiyatları 0.7.0'a döndü**, sonraki seviyeler birleşik sürümdeki gibi pahalı (bıçak 100 / 530 / 1450 / 3900 …).
- **İlk günlerde müşteri daha sık:** `rate = max(2, min(6,8 − 0,22·gün, 4,6 − 0,08·gün)) / tabela`; ~16. günden sonra eski eğri. 1. gün 5 → 8 müşteri.
- **Borç taksiti 6. günden başlar** (`session_system.TAKSIT_GUN`); gün sonunda "BORÇ TAKSİTİ — 6. günden başlar" yazar.

Önce → sonra (tempo modeli, gelenlerin %70'ine yetişen, en ucuzdan alan oyuncu):

| | Önce | Sonra |
| --- | --- | --- |
| 1. gün müşteri / net | 5 / $66 | 8 / $120 |
| İlk 5 günde alım | 2 (boya, depo) | 6 (boya, bıçak, patates bıçağı, depo, fritöz, kâğıt) |
| Bıçak / fritöz | 7. / 11. gün | 2. / 4. gün |
| İlk yeni ürün (en ucuzdan alan) | 15. gün | 7. gün (paket patates), 8. gün içecek |
| İçeceğe biriktiren | 6. gün | 2. gün |
| Dürüm başına tık | ~20 | ~8 |

Uzun vade (`tests/tempo.gd`): borç bitişi en ucuzdan alan 107 / 93 / 84 → 98 / 87 / 78. gün, şubeye biriktiren 93 / 85 / 78 → 86 / 79 / 73. gün (%55 / %70 / %85). İlk şube 35 / 26 / 24 → 27 / 22 / 19. gün. Oyun başı hızlandığı için hepsi 5-9 gün erkene kaydı.

## Rakip bahisleri (11. tur, kullanıcı kararı)

10. günden itibaren rakip bahis önerir; kabul etmek serbest. Hedef artık gün sayısına değil, **oyuncunun son 3 gündeki ortalamasının %110'una** bağlıdır (dürüm / kasaya giren para / bahşiş); böylece bahis geç oyunda bedava para, erken oyunda ulaşılmaz olmaz. Kazanç ve ceza değişmedi: `200 + 34·gün` ($10'a yuvarlı). En düşük hedefler 4 dürüm, $100, $10 bahşiş. Geçmişi olmayan oyunda (yeni oyun / eski kayıt) eski formüller (`6 + 0,22·gün` dürüm, `160 + 26·gün` $, `30 + 6·gün` bahşiş) geçerli. Test: `tests/bahis_hedef.gd`.

## Baba'nın Defteri — kayıp tarifler (12. tur, kullanıcı kararı)

Bulunmuş ve ekipmanı olan tarifler normal müşterinin dürümünü **%14** olasılıkla adıyla ister (iskender tabağı varken ilk kalem tabak olunca karışmaz: ~%10,5). Doğru sos + doğru malzeme + tam kalite teslimde dürüm fiyatı tarifin çarpanıyla (×1,5 – ×2,0) çarpılır; her tarifin 5 / 15 / 40. servisinde usta seviyesi gelir (+%10 / seviye); menü tarifleri tüm sipariş kızdırmadan bitince toplama +%20 / +%25 ekler. Bahşiş toplam üzerinden hesaplandığı için aynı oranda artar.

Sipariş başına ortalama gelir (30 000 sipariş, aynı rastgele akış; hepsi bulunmuş, tam ekipman — `tests` dışı tek seferlik ölçüm):

| Durum | Tarifsiz | Tarifli, usta 0 | Tarifli, hepsi usta 3 |
| --- | --- | --- | --- |
| Tam ekipman, iskendersiz | $50,91 | $56,73 (**+%11,4**) | $59,71 (+%17,3) |
| Tam ekipman + iskender | $50,87 | $55,18 (+%8,5) | $57,40 (+%12,9) |
| Yalnız Sos + Malzeme Seçimi 2 | $37,25 | $41,67 (+%11,9) | $44,55 (+%19,6) |

Yorum: artış, tarif sayfaları gün 3 – 72 arasında açıldığı ve usta seviyesi tarif başına 40 doğru servis gerektirdiği için kademelidir; erken oyunda (yalnız Acılı / Sarımsaklı) etki küçük, tam kadroda ~%9-12'dir. Prim yalnız **kusursuz** teslimde alınır; yanlış sos, eksik malzeme ya da kızgın müşteri primi sıfırlar ve ek hazırlık / dikkat ister (sert kural yumuşatılmadı). Ayar noktaları: `data/tarif.gd` (`carpan`, `menu`, `gun`), `tarif_system.gd` (`SANS`, `USTA_ESIK`, `USTA_ARTIS`).


## 12. tur: tempo güncel kodla yeniden ölçüldü (`tests/tempo.gd --gun 200 --hirsiz --gunluk`)

Kullanıcı: "tempoyu güncel kodla yeniden ölç". Model aynı (gerçek sipariş üretimi, fiyat, gün sonu, yükseltme / şube alımı; oyuncu gelen müşterinin sabit bir oranına yetişir; telefon, Dayı, bahşiş, olaylar, tarif primi ve bahis YOK). Kayıp tarifler, rakip bahisleri, kesme efekti, panel / ret geri bildirimi, haptik, web sürümü sonrası ölçüldü:

| Alım kuralı | Yetişme | İlk şube | Borç biter | 60. gün kalan borç (ödenen) | 8. tur: borç biter |
| --- | --- | --- | --- | --- | --- |
| En ucuz yükseltme | %55 | 27. gün | 99. gün | $4,92M (%1,6) | 98 |
| En ucuz yükseltme | %70 | 23. gün | 87. gün | $4,80M (%4,0) | 87 |
| En ucuz yükseltme | %85 | 21. gün | 78. gün | $4,51M (%9,8) | 78 |
| Şubeye biriktir | %55 | 21. gün | 86. gün | $4,79M (%4,3) | 86 |
| Şubeye biriktir | %70 | 18. gün | 80. gün | $4,54M (%9,2) | 79 |
| Şubeye biriktir | %85 | 16. gün | 72. gün | $3,77M (%24,6) | 73 |

Gece hırsızı ile (şubeye biriktir): borç 91 / 81 / 75. günde biter (hırsızsız 86 / 80 / 72). 70 yükseltme seviyesinin tamamı: en ucuz alımda %70 ve %85 için ≤ 45. gün (%55 için ≤ 60), şubeye biriktirirken ~60. gün (%55 için 61-90).

**Bulgular**

- **Tempo 8. tur ölçümüyle ±1 gün aynı**: sonraki işler (tarif, bahis, efektler) temel akışın hızını değiştirmedi. Eski 6. tur tablosundaki "borç ilk 60 günde %10'dan az eriyor" bugün de doğru: en ucuz alımda %1,6 / %4,0 / %9,8, şubeye biriktirirken %4,3 / %9,2 / %24,6.
- **Aktif oyun ilk ~30 günde büyüyor, sonra tavan yapıyor, 50. günden sonra gelirin küçük kısmı**: `--gunluk` (beceri 0,70, en ucuz alım): elle kazanç 30. günden sonra ~$10 bin/gün'de sabit (175 gelen müşteri, 122 servis); şube geliri 40. gün $2,7 bin (%20 pay), 50. gün $18 bin (%64), 60. gün $95 bin (%90), 70. gün $282 bin (%96), 80. günden sonra $1,69 milyon/gün (%99). Yani borcun kapanma hızını 50. günden sonra neredeyse yalnız şube alım zamanlaması belirliyor.
- **Şube performans çarpanı çabuk doyuyor** (`BR_MIN` 0,35, `BR_MAX` 1,15; hedef = gelenlerin %35'i): hiç servis vermeyen gün 0,35, gelenlerin %35'ine yetişmek 0,92, %70'i 1,04, %100'ü 1,15. Yani %35 ile %100 arası beceri yalnız ~%25 fark yaratıyor.
- **Kasa anlamsızlaşıyor**: borç bittikten sonra para birikiyor (100. gün ~$41M, 120. gün ~$75M); harcanacak yer yok (yükseltmeler 45-60. günde bitiyor, malzeme bedava, kira / maaş yok).
- **Şubeye biriktirmek her yetişme oranında 6-13 gün daha hızlı** (baskın strateji).
- **Hırsız notu güncellendi**: çalınan miktar kasanın oranı (`THIEF_MIN..MAX`); 200 günde toplam $55 bin / $4 bin / $12,4 milyon (%55 / %70 / %85). Eski "13-88 bin, geç oyunda önemsiz" notu bugün yanlış okunur: oran sabit, kasa büyüdükçe mutlak tutar büyüyor; ama hep borç bittikten sonra, yani oyun üzerinde etkisi yok. Borç bitişini 1-5 gün geciktiriyor.

Model sınırları: gerçek oyunda telefon / Dayı / bahşiş / olaylar / tarif primi geliri artırır, hatalar azaltır; oyuncu sabit oranda yetişmez (becerisi yükseltmelerle büyür). Rakamlar **yön** gösterir, kesin gün vermez.

## 13. tur: icra, net şube geliri, şehir primi (`tests/tempo.gd --gun 200 --rezerv --hirsiz --beceriler 0.40,0.55,0.70,0.85,0.95,1.00`)

Kullanıcı: "önerdiğin şeyleri uygula". Ekonomiyi değiştiren üç parça; hepsi tek yerde ayarlanır:

| Parça | Sabit | Değer | Yer |
| --- | --- | --- | --- |
| İcra: ilk ziyaret / aralık | `ILK_GUN` / `HAFTA` | 13. gün sabahı / 7 gün | `icra_system.gd` |
| İcra: yuvarlama payı | `TOLERANS` | istenenin %2'si (en az $1) | `icra_system.gd` |
| İcra: ihtar zammı | `GECIKME` | eksik kalanın **%50'si** birikene eklenir | `icra_system.gd` |
| İcra: kepenk mühürü | `MUHUR_GUN` | **2 / 3 / 4** gün (sonrakiler 4) | `icra_system.gd` |
| Taksit oranı / başlangıcı | `j_DEBT_CUT` / `TAKSIT_GUN` | %18 / 6. gün (eskisiyle aynı) | `game_setup.gd`, `session_system.gd` |
| Şube hacim hedefi | `BR_HEDEF_ILK` / `BR_HEDEF_SON` | gelenin %35'i (≤ 20. gün) → %75'i (≥ 70. gün) | `progression_system.gd` |
| Şube çarpanı uçları | `BR_MIN` / `BR_MAX` | 0,35 / **1,35** (eskiden 1,15) | `game_setup.gd` |
| Zincir gideri | `BR_GIDER_SABIT` / `BR_GIDER_DEGISKEN` | taban gelirin %30'u + %18'i × performans | `progression_system.gd` |
| Şube taban gelirleri | `inc` | eski tablo **×1,6** | `game_setup.gd` |
| Şehir ziyaret primi | `ZIYARET_PRIM` | çalışılan şubenin taban geliri +%50 | `city_rules.gd` |

Şehir kuralları ve ziyaret primi tempo modeline **girmez** (model ev dükkânında oynar; kural yok, prim yok): prim yalnız başka şehirde çalışan oyuncuya ek gelir ya da (yoğun şehirde) daha büyük hedef demektir. Aynı modelin diğer sınırları 12. turdaki gibi (telefon / Dayı / bahşiş / olay / tarif primi / bahis yok). Sipariş üretimi rastgele olduğundan bir koşudan ötekine **±1-3 gün** oynama olağan.

**Dikkatli oyuncu** (icra sabahına kadar birikmiş taksiti kasada ayırır → 0 ihtar, 0 mühür): borç bitiş günü

| Yetişme | En ucuz yükseltme | Şubeye biriktir | 12. tur: en ucuz | 12. tur: biriktir |
| --- | --- | --- | --- | --- |
| %40 | 153 | 134 | – | – |
| %55 | 103 | 90 | 99 | 86 |
| %70 | 82 | 75 | 87 | 80 |
| %85 | 72 | 68 | 78 | 72 |
| %95 | 69 | 64 | – | – |
| %100 | 66 | 62 | – | – |

Beceri aralığı açıldı (%55 → %85 arası en ucuz alımda 21 gün → 31 gün, %40 → %100 arası 87 gün); ortalama oyuncu (%70) eskisinden birkaç gün **hızlı** (şube artık gelenin %75'ine kadar hizmeti ödüllendirdiği için yükseltmeler anlamlı), düşük beceri daha **yavaş**. Şube performans çarpanı (gün 40, tüm yükseltmeler, 175 gelen; hedef o gün %51): gelenin %0'ına yetişen 0,35 · %10 0,47 · %20 0,60 · %35 0,83 · %50 1,12 · %70 1,21 · %100 1,35 (eskiden %35'ten sonra düz 1,0-1,15).

**Savurgan oyuncu** (harcayabildiğini harcar, kasa her akşam boş): borç bitiş günü (ihtar / mühür / kayıp gün)

| Yetişme | En ucuz: savurgan | dikkatli | Biriktir: savurgan | dikkatli |
| --- | --- | --- | --- | --- |
| %40 | 171 (11 / 5 / 17) | 153 | 131 (5 / 1 / 2) | 134 |
| %55 | 113 (7 / 3 / 9) | 103 | 91 (3 / 1 / 2) | 90 |
| %70 | 84 (5 / 2 / 5) | 82 | 73 (1 / 0 / 0) | 75 |
| %85 | 75 (5 / 2 / 5) | 72 | 65 (3 / 0 / 0) | 68 |
| %95 | 70 (5 / 2 / 5) | 69 | 63 (0 / 0 / 0) | 64 |
| %100 | 66 (4 / 1 / 2) | 66 | 60 (2 / 0 / 0) | 62 |

Gece hırsızı ile (biriktir, savurgan): 137 / 92 / 74 / 65 / 64 / 62 (hırsızsız 131 / 91 / 73 / 65 / 63 / 60): 0-6 gün, 12. turdaki 1-5 günle aynı mertebe. Çalınan tutar kasayla orantılı, yani hep geç ve borç bittikten sonra büyük.

**Ceza ayarı nasıl seçildi.** İlk sürüm (%20 zam, mühür 1 / 2 / 3 gün) savurgan oyuncuyu neredeyse hiç yavaşlatmıyordu (en ucuz alım, %55 / %70 / %85: 110 / 82 / 73 gün; dikkatli oyuncu 103-106 / 82 / 72). Yalıtılmış kopyalarda üç sertleştirme denendi (savurgan, en ucuz alım, %55 / %70 / %85):

| Sürüm | Borç bitiş günü |
| --- | --- |
| %20 zam · 1 / 2 / 3 gün (ilk) | 110 / 82 / 73 |
| **%50 zam · 2 / 3 / 4 gün (seçilen)** | **113 / 84 / 75** |
| %35 zam · 2 / 3 / 5 gün | 114 / 84 / 75 |
| %100 zam · 2 / 3 / 4 gün | 126 / 88 / 76 |

Seçilen sürüm "ceza yumuşatılmaz" ilkesine uygun sertleşme, ama %100 zam gibi ilk kez ihtar alan yeni oyuncuya (13. gün) orantısız olurdu; mühür süresi zaten asıl acı (kaybedilen gün + gelir).

**Dürüst bulgu / risk — ihtar iyi optimize eden için kısa vadeli kredi.** "Şubeye biriktir" kuralını oynayan savurgan oyuncu cezadan **kaçıyor** (91 / 73 / 65, dikkatli oyuncu 90 / 75 / 68): birikmiş taksiti kasada ayırmak şube alımını geciktiriyor; bir ihtar (kalanın %50'si zam, borç tutarını aşmaz) bu gecikmeden ucuz; ardışık **ikinci** kusur (mühür) ise biriktirene nadiren geliyor (kasa bir hafta içinde yeniden dolar). Ceza gerçek oyuncuda hissediliyor (ihtar kartı, zam, en ucuz alımda %55 için +10 gün, %40'ta +18 gün ve 17 gün mühür), ama şubeyi gözüne kestirmiş bir optimize edici için caydırıcı değil. Kolay kaldıraçlar: `GECIKME` (zammı yalnız eksikten değil birikmiş taksit toplamından ya da günlük kazançtan hesaplamak), ihtarı tek kusurda 1 günlük mühüre çevirmek, `TOLERANS`'ı sıfırlamak. Dokunulmadı: bu, bir oyun sertliği kararı; kullanıcıya bırakıldı.

**Para sinki**: zincir gideri (taban gelirin %30-48'i) şube gelirini küçültüyor, ama borç bittikten sonra kasa hâlâ boşta birikiyor (en ucuz alımda %70 yetişmede 100. gün ~$45M, 120. gün ~$78M). Gerçek bir harcama kalemi (şube yenileme, reklam, personel) bu turda yok; ayrı karar.
