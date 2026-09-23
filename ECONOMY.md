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
