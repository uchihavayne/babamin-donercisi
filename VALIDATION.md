# Müşteriden önce hazırlık — 0.7.2

Müşteri şartı zaten hazırlık kurallarında yoktu. Farede boş tahtaya basış lavaş açmıyordu; dokunma/kol açıyordu. Fareyle lavaş/pide yığını ve boş tahta artık aynı istasyon işleminden geçer. Dolmuş tezgâha ekmek alma girişimi mevcut ürünü değiştirmeden kısa bir açıklama verir. Sipariş bağlama isteğe bağlı kalır; önceden eklenen malzemeler korunur.

**149 kontrol, 0 başarısızlık** — Godot 4.7.1 / macOS / Apple M4: `bread_preparation` 26, `ingredient_input` 21, `order_flow` 30, `stations` 56, `ingredient_input_visual` (GPU) 16. Günlüklerde GDScript hatası yok.

Yeni test gerçek ilk günün öğretim ve kepenk durumunu korur; müşteri oluşturmadan fare/dokunma/kol ile yığından ve boş tahtadan lavaş alma, seçilen boş tahta, diğer boş tahtaya yerleştirme, dolu tezgâh reddi, pide/lavaş ayrımı ve sonradan gelen müşteriye hazırlığı bağlamayı doğrular. Değişiklik öncesi 23 kontrolün 5'i başarısızdı. GPU testine masaüstü/telefon düzeninde boş tahtaya basma ve dolu tezgâh geri bildirimi eklendi. Bunlar programla üretilen yerel olaylardır; fiziksel telefon/konsol testi değildir.

Rapor: `validation/bread-preparation-results.json`; GPU raporu: `validation/ingredient-input/visual-results.json`. Tüm testler ayrı kayıt dosyaları kullanır.

Önceki sürüm doğrulamaları:

# Malzeme tıklamaları — 0.7.1

Hata yeniden üretildi: aynı kare aralığında lavaş, et ve turşuya basıldığında doğrudan malzeme işlemleri sıradaki lavaş açma olayını geçiyordu. Kedi beklerken 6/18/45 kare süren hareketsiz et tıklamaları da sürükleme kabul edilip boşa gidiyordu. Ayrıca stok/porsiyon sınırında istasyon işlemi sessizce reddediliyordu. İlk 10 regresyon kontrolünün 8'i eski kodda başarısız oldu; düzeltme sonrası genişletilmiş 21 kontrol geçti.

**343 kontrol, 0 başarısızlık** — Godot 4.7.1, macOS / Apple M4. Son koşuların günlüklerinde GDScript hatası yok:

| Süit | Kontrol |
| --- | ---: |
| ingredient_input | 21 |
| ingredient_input_visual (GPU) | 12 |
| order_flow | 30 |
| platform_input | 84 |
| counter_input | 17 |
| stations | 56 |
| runtime_state | 31 |
| cutting | 61 |
| mouse_slicing | 31 |

Yeni kontroller; hızlı hazırlık sırası, art arda basışlar, sürükleme sonrası malzeme ekleme, kediye et verme/boşluğa sürüklemeyi iptal, stok sınırı, başka siparişe taşmama, alandan çıkınca basılı tutmayı iptal, mola/cihaz değişiminde bekleyen girdileri temizleme ve geçici hata mesajlarını kapsar. `ingredient_input_visual` gerçek Godot viewport/shell yoluna fare ve dokunma olayları gönderir; masaüstü/telefon yerleşiminde malzemenin ve stoğun yalnızca bir kez değiştiğini, basılı tutmanın sınırda durduğunu doğrular. Girdiler programla üretilmiştir; fiziksel telefon/konsol testi değildir.

Raporlar `validation/ingredient-input-results.json` ve `validation/ingredient-input/visual-results.json`; incelenen GPU görüntüleri aynı klasörde `mouse.png` ve `touch.png`. Kullanıcı kayıtları yerine ayrı test kayıtları kullanıldı. Kesim verimi, fiyatlar ve tarif miktarları değişmedi.

Önceki sürüm doğrulamaları:

# Kazanç ve geliştirme dengesi — 0.7.0

Ana ürün satış fiyatları yaklaşık %25–33 artırıldı; 24 ekipmanın ilk satın alma ve sonraki seviye fiyatları yeniden dengelendi. Hız, kapasite ve otomasyon eşikleri korunur. Mağaza kartı gerçek ayarlardan önce/sonra değerini gösterir; sahip olunan eşyada “GELİŞTİR” düğmesi vardır. Satın alma kuralları `upgrade_system.gd` içinde merkezi doğrulanır; seviye, para, önkoşul ve üst sınır kontrol edilir. Mevcut kayıt şeması ve alınmış seviyeler korunur.

Ödeme parçalarının bağımsız yuvarlanmasından kaynaklanan kasa/rapor farkı giderildi. 1–300 tutarlarındaki bütün ödeme dağılımlarının toplamı kontrol edildi; gerçek müşteri ve kurye ödeme yolları ayrıca çalıştırıldı.

**246 kontrol, 0 başarısızlık** — Godot 4.7.1, macOS / Apple M4:

| Süit | Kontrol |
| --- | ---: |
| economy | 39 |
| economy_visual (GPU) | 8 |
| regression | 34 |
| module_services | 18 |
| order_flow | 30 |
| stations | 56 |
| cutting | 61 |

Son başarılı koşularda GDScript hatası yok. Ek olarak önceki **6 referans karşılaştırması** geçti: fiyat göstermeyen beş sahnenin pikselleri/oyun durumu ve kayıt örneği. Referans değiştirilmedi; yeni ekonomi ayrı testlerle doğrulandı.

`economy` testi; gerçek sipariş teslimi, tam ödeme, bahşiş, %18 borç, telefonun 1,9 çarpanı, eksik para/önkoşul/üst seviye reddi, satın alımın kayıttan geri yüklenmesi, kesim verimi ve otomasyon açılma seviyelerini kapsar. 24 ekipmanın seviye fiyatları artar; önizleme altı dilde karta sığar ve oyun durumunu değiştirmez.

12 günlük, günde 6/8/10 doğru siparişli kontrollü karşılaştırma raporu `validation/economy-results.json` içindedir. Altı sipariş senaryosunda ilk gün net kazanç 84→113; ilk maşa 4.→1. gün; içecek standı 4. gün. Varsayımlar ve tüm fiyatlar **ECONOMY.md** içinde. Bu sabit iş yükü modeli gerçek oyuncu süresi/başarısı ölçümü değildir; telefon/şube geliri, gece olayları ve kayıplar dahil edilmez.

GPU testinde masaüstünde fareyle ilk fritöz alımı, oyun kolu düğme olayıyla ikinci seviyeye geçiş ve telefon yerleşiminde dokunarak ilk içecek standı alımı denetlendi. Para bir kez düşer ve makine doğru hıza geçer. Ekran görüntüleri `validation/economy/`; fiziksel konsol/telefon testi değildir. Kullanıcı kayıtlarından ayrı test dosyaları kullanıldı.

Önceki sürüm doğrulamaları:

# Daha küçük sorumluluk modülleri — 0.6.1

- `game.gd` **2.090 → 310 satır**; ortak durum ayrı `core/game_state.gd` dosyasında **284 satır**. 527 normal yönlendirme kaldırıldı; çağrılar doğrudan ilgili modüle gider. Özelleştirme, başlangıç ve görsel üretim araçlarının ihtiyaç duyduğu 65 giriş korundu.
- En büyük uygulama dosyası **2.776 → 509 satır**. Ekipmanlar, hazırlama/sürükleme, telefon/kurye, olaylar, karakterler, sokak, menüler ve hikâye sahneleri anlamlı alt klasörlere ayrıldı. Her parça aynı oyun örneğine bağlıdır; bağımsız güncelleme döngüleri eklenmedi.
- **488 kontrol geçti; başarısızlık ve GDScript hatası yok.** Kapsam ve süit başına sayılar `validation/fine-modules-results.json` içindedir. Aynı 13 süit (aşağıdaki 0.6.0 tablosu) yeni çağrı yollarıyla tekrar çalıştırıldı. Fare/kol/dokunma girdileri simüle edilmiştir; dört görsel süit Apple M4 üzerinde gerçek GPU çizimini denetler.
- **6 birebir karşılaştırma geçti:** beş sahnenin pikselleri, oyun/rastgele sayı durumu ve kayıt JSON'u 0.5.4 referansıyla aynı. Referans dosyası değiştirilmedi.
- Ek kaynak denetiminde **891 uygulama fonksiyonunun** 0.6.0'daki gövdesiyle eşleştiği doğrulandı; yalnızca modül yolu, boşluk ve yorum farkları dışarıda bırakıldı. Sonuç `validation/fine-module-audit.json`. Bu kaynak karşılaştırması çalışma zamanı testlerinin yerine geçmez.

Düzenleme noktaları ve korunması gereken özelleştirme çağrıları **CODE_MAP.md** içinde. Kayıt şeması/yolu, kesim verimi, süreler, tarifler ve görseller korunur. Eski harici scriptlerde kaldırılmış `game.f_...` normal çağrılarını ilgili modül yoluna uyarlamak gerekir; proje içindeki testler ve araçlar uyarlandı. Bu sürüm için yeni FPS/hızlanma iddiası yoktur.

Önceki sürüm doğrulamaları:

# Modüler GDScript düzeni — 0.6.0

- Ana `game.gd` dosyası **26.324 → 2.090 satır**; `order_flow.gd` **304 → 94 satır**. Ortak durum ve mevcut çağrı girişleri korunur. Uygulama `core/`, `systems/` ve `rendering/` altında 30 ayrı dosyada; en büyük modül 2.776 satırdır.
- Müşteri/telefon/kurye, tarif/hazırlama, özel sipariş, ekipman, kayıt, gün döngüsü, olaylar ve ilerleme ayrı modüllerdedir. Çizim; sokak, tezgâh, karakter, yiyecek, ekipman, sipariş ve menü dosyalarına bölündü.
- 592 dış oyun fonksiyonunun imzası korundu. İç callback'ler sahiplerinin yanına taşındı; 68 ekipman ayarı isimli fonksiyon oldu. Porsiyon ve fiyat varsayılanları tarif modülünde, kesim verimi ekipman modülündedir. Kayıt şeması/yolu korunur. Bozuk JSON kayıtları aynı hata durumuyla reddedilir; JSON.parse ile kontrollü okuma gereksiz motor hata çıktısı üretmez.

**488 kontrol, 0 başarısızlık** — Godot 4.7.1 / macOS / Apple M4:

| Süit | Kontrol |
| --- | ---: |
| cutting | 61 |
| mouse_slicing | 31 |
| stations | 56 |
| order_flow | 30 |
| runtime_state | 31 |
| platform_input | 84 |
| counter_input | 17 |
| regression | 34 |
| module_services | 18 |
| counter_design_visual (GPU) | 62 |
| order_flow_visual (GPU) | 19 |
| mouse_slicing_visual (GPU) | 16 |
| stations_visual (GPU) | 29 |

Son başarılı koşularda GDScript çalışma zamanı hatası görülmedi. Modül testi iki bağımsız oyun örneği, ayrı fiyat varsayılanları, seviye callback'leri, atomik kayıt, gerçek diskten yükleme, eski şema ve hatalı/gelecek şema kayıtlarını kapsar. Mevcut regresyon 24 geliştirmeyi ve 10 şehri kapsar. Kontrol girdileri üretilmiştir; fiziksel telefon/konsol testi değildir.

**6 ek birebir karşılaştırma geçti:** taşıma öncesi 0.5.4'ten alınan başlık, Yeni Oyun girişi, hazırlanmış sipariş, paketlenmiş dürüm ve gelişmiş dükkân sahnelerinde CPU görüntü piksellerinin SHA-256 değerleri ve oyun durumu aynı. Altıncı karşılaştırmada kayıt JSON'u da aynı. Rastgele sayı durumu karşılaştırmaya dahildir. Referans `validation/module-snapshot-baseline.json`, sonuç `module-snapshot-results.json` içindedir. GPU süitlerinde gerçek son kare ve bıçağın opak pikselleri ayrıca denetlendi.

Sınırlı performans kontrolü: aynı gelişmiş dükkân/5 müşteri senaryosunda 15 ısınma karesi sonrası 60 kare, ardışık headless çalıştırmalar. `advance()` içindeki CPU simülasyonu ve çizim komutlarını hazırlama medyanı önce **28,174 ms**, sonra **25,813 ms**; P95 önce **39,150 ms**, sonra **31,160 ms**. Bu tek ölçüm donanım FPS'i veya GPU gecikmesi değildir; genellenmiş hızlanma iddiası taşımaz. Rapor `module-performance-results.json` içindedir.

Düzenleme rehberi **CODE_MAP.md**; kaynak ZIP'i modülleri, rehberi ve bu sürümde kullanılan testleri içerir. Testler için kullanıcı kaydından ayrı dosyalar kullanıldı. Önceki sürüm sonuçları aşağıdadır.

# Eksik işlem kaydı ve Yeni Oyun tezgâh hatası — 0.5.4

- `station_actions.gd`: `holding.target` gibi zorunlu alanlar okunmadan önce kayıt doğrulanır. Eksik kayıt iptal edilir; iptal işlemi eksik `id`/`board` alanlarını da tolere eder. İşlem, girdi temizleme çağrılarından önce ayrılır; kesme/doğrama durur, açık dürümün yarım sarma ilerlemesi sıfırlanır.
- `counter_design.gd`: `f_resetProgress()` özgün kurala göre `custom` bilgisini `null` yapar. Yeni tezgâh çiziminin doğrudan `custom.get()` çağırması “Yeni Oyun → giriş” akışında hata veriyordu. Atlas ve prosedürel çizim ortak tema okuyucusundan varsayılan temayı alır; mevcut tema seçimleri korunur.

**179 kontrol, 0 başarısızlık; GDScript çalışma zamanı hatası yok:** `runtime_state.gd` 31 + `stations.gd` 56 + `order_flow.gd` 30 + GPU `counter_design_visual.gd` 62. Godot 4.7.1 / macOS / Apple M4.

Yeni regresyon: gerçek `f_resetProgress → f_goIntro → ilk gün` geçişi, atlas ve prosedürel tezgâh, eksik/eski özelleştirme alanı, mevcut renkler. Basılı tutma hatası için geçerli eylem kayıtlarından `target/id/source/time/board/index/next` alanları tek tek kaldırıldı; güvenli iptal, fazladan malzeme tüketilmemesi ve sonraki basışın çalışması doğrulandı. Sarma, patates doğrama ve döner kesme iptalleri de kontrol edildi. Eksik basılı tutma kaydının doğal oynanışta ilk kez nasıl oluştuğu henüz tekrarlanamadı; test bu durumu kontrollü biçimde oluşturur.

Rapor: `validation/runtime-state-results.json`; diğer süitlerin raporları kendi validation klasörlerinde. Testler kullanıcı kaydını değiştirmeyen ayrı kayıt yollarıyla çalıştı. Önceki sürüm sonuçları aşağıdadır.

# Daha dolgun kesişler — 0.5.3

Tek kesişin verimi 1 → 3 dilime yükseltildi; başlangıç kesme aralığı tekrar 0,5 saniye (geliştirmeler 0,38 / 0,30 / 0,24 / 0,18). Tek bıçak darbesi ve kesme sesiyle üç et parçası uçar, gerçek kazanç kısa bir göstergede görünür. Tepside bir veya iki dilimlik yer kaldığında stok, parçalar ve gösterge aynı miktarı izler. Otomatik kesici aynı verimi kullanır; 0,16 saniyelik aralığı korunur.

**164 kontrol, 0 başarısızlık:** `tests/cutting.gd` 61, `tests/mouse_slicing.gd` 31, `tests/stations.gd` 56, `tests/mouse_slicing_visual.gd` 16. GDScript çalışma zamanı hatası yok. Altı kesişte dolma, 0/13/14/15/16 stokta kapasite sınırı ve gerçek parça sayısı, parçaların inişinde ikinci kez stok eklenmemesi, otomatik kesici, bırakma/durma, mola ve istasyon girdileri doğrulandı. Son GPU karesinde bıçağın bütün opak pikselleri et efektleri ve paket fişiyle birlikte karşılaştırıldı; örtülen piksel yok.

| Örnekleme | Fare hareketi / basılı tutma ile dolu tepsi |
| --- | --- |
| 30 FPS | 2,700 sn |
| 60 FPS | 2,600 sn |
| 120 FPS | 2,508 sn |

`tests/cutting_visual.gd` ayrıca beş GPU görüntüsü üretti; dokunmayı bırakınca durma ve kol hedefinin geri dönmesi doğrulandı. Dokunma kesişindeki üç parça ve `+3` göstergesi görüntüde kontrol edildi.

Godot 4.7.1 / macOS / Apple M4 üzerinde üretilmiş girdilerle ölçülen simülasyon süresidir. Her örneklemede ilk iki saniyede dört kesiş ve 12 dilim elde edildi. Fiziksel telefon veya konsol testi yapılmadı. Güncel rapor ve GPU görüntüleri `validation/cutting/` içindedir; aşağıdaki 0.5.2 ve önceki bölümler tarihsel sonuçlardır.

# Tepsiyi doldurma süresi — 0.5.2

Başlangıç kesme aralığı 0,5 → 0,18 saniye; geliştirmeler 0,15 / 0,12 / 0,10 / 0,08 saniye. Aynı kural fare, dokunma ve kol için kullanılır. Tepsi 16 dilim, tarif 4 dilim olarak kaldı; otomatik kesici aralığı değiştirilmedi.

**69 kontrol, 0 başarısızlık:** `tests/cutting.gd` 38 + `tests/mouse_slicing.gd` 31. Bırakma/durma, kapasite, kenar, modal/mola ve geliştirme kontrolleri tekrar geçti. Boştan 16 dilime ölçülen süre hem sürekli fare hareketinde hem basılı tutmada:

| Örnekleme | Dolu tepsi |
| --- | --- |
| 30 FPS | 3,033 sn |
| 60 FPS | 2,767 sn |
| 120 FPS | 2,758 sn |

Godot 4.7.1 / macOS, üretilmiş girdiler. Bu süreler ölçülen oyun simülasyonu zamanıdır; fiziksel oyuncu hızını veya cihaz FPS performansını ölçmez. Raporlar `validation/cutting/results.json` ve `mouse-slicing-results.json` içinde. Görsel değişiklik yapılmadığından GPU süitleri bu küçük hız ayarında tekrar çalıştırılmadı; aşağıdaki sonuçlar önceki sürümlere aittir.

# Fareyle sürekli kesme ve bıçak görünürlüğü — 0.5.1

Fare artık sadece kareler arasındaki dikey farkla kesmez: yerel mouse hareket olaylarının bütün yolu toplanır, yatay/çapraz ve aynı kare içindeki gidiş–dönüşler sayılır. Başlangıç eşiği 155 yerine yaklaşık 19 oyun pikselidir; bıçak geliştirmelerinin bekleme süresi ve 16 dilim tepsi sınırı korunur. Fare durunca bekleyen hareket yeni dilim üretmez. Kenar toleransı komşu istasyonları dışarıda bırakır. Bıçak, paket fişi ve diğer dünya öğelerinden sonra çizilir; tepsi dolunca görünür kalır.

**155 kontrol, 0 başarısızlık** — macOS / Apple M4 / Godot 4.7.1:

- `tests/mouse_slicing.gd`: 28 kontrol; kısa dikey/yatay/çapraz/dairesel hareket, hızlı gidiş–dönüş, titreme, durma, kenar toleransı, komşu istasyon, yeniden giriş, tepsi dolması/boşalması, panel/mola/elde ürün engeli. 30/60/120 FPS örneklemelerinin her birinde iki saniyede dört dilim; üst bıçak seviyesinde daha hızlı kesme.
- `tests/mouse_slicing_visual.gd`: 16 kontrol; gerçek Godot pencere girdi yolundan mouse olayları, iki ekran oranı, kenarlar ve tekrar giriş. Paket fişi açıkken ve tepsi doluyken son GPU karesindeki bıçağın bütün opak pikselleri atlasla karşılaştırıldı; örtülen piksel yok. Aynı karede gidiş–dönüş yerel olaylarla da doğrulandı. Bu, fiziksel fareyle elle yapılan bir oturum değildir.
- `tests/mouse_knife.gd`: 17 kontrol; eski tekil çizim karşılaştırması tam dünya çizimiyle değiştirildi, katman örtüşmesi de denetleniyor.
- Diğer tekrarlar: `cutting.gd` 35, `order_flow.gd` 30, `stations_visual.gd` 29. Dokunma/kol kesmesi, sipariş döngüsü ve doğrudan tezgâh etkileşimleri geçti.

Raporlar: `validation/cutting/mouse-slicing-results.json`, `mouse-slicing-visual-results.json`. GPU görüntüleri: `mouse-receipt-layer.png`, `mouse-tray-full.png`, `mouse-horizontal.png`.

```sh
godot --headless --path . --script tests/mouse_slicing.gd --quit-after 300 -- --test
godot --path . --script tests/mouse_slicing_visual.gd --quit-after 1200 -- --test --gpu-test
```

# Sipariş döngüsü ve yerleşim düzeltmeleri — 0.5.0 / 19 Eylül 2026

**185 kontrol, 0 başarısızlık.** Godot 4.7.1, macOS / Apple M4. Son başarılı koşularda GDScript çalışma zamanı hatası görülmedi.

- `tests/order_flow.gd`: 30 kontrol. Tek/çift malzeme eksiltme, sos eşleşmesi, tek istenmeyen parçada ret, ürünün elde kalması, farklı tarifli iki dürümün doğru kaleme teslimi, kurye doğrulaması, tam kalite, içecekli siparişin aşamalı tamamlanması, makineyle paketleme, tahta eşleştirme ve müşteri ayrılması. Fare/dokunma/kol basılı tutma, porsiyon sınırı, stok bitmesi, bırakma/alandan çıkma/tahta değiştirme/mola iptali.
- `tests/order_flow_visual.gd`: 19 kontrol. Beş müşterinin balon sınırları/çakışması, tamamlanan kalemin tiklenmesi, duvar süsü/pencere ve Dayı/döner alanları. Gerçek GPU görüntüleri masaüstü ve 1170×540 telefon penceresinde alındı; Dayı, paket fişi ve malzeme simgeleri gözle kontrol edildi.
- Mevcut regresyonlar tekrar geçti: `stations.gd` 56, `stations_visual.gd` 29, `counter_input.gd` 17, `regression.gd` 34. Bunlar doğrudan nesne girdisi, sarma/paketleme/ızgara, gerçek viewport'a dokunma, sos/içecek fare hedefleri ve 24 geliştirme/10 şehir çizimlerini kapsar.
- Raporlar: `validation/order-flow/results.json`, `visual-results.json`. Görüntüler aynı klasördedir. Önceki aşamaların test sayıları aşağıda tarihsel olarak korunmuştur; diğer süitlerin bu sürümde yeniden çalıştırıldığı anlamına gelmez.
- Girdiler macOS üzerinde üretilmiştir; fiziksel telefon/kol veya PlayStation üzerinde yeni doğrulama yapılmadı. Yeni FPS ölçümü yoktur.

```sh
godot --headless --path . --script tests/order_flow.gd --quit-after 300 -- --test
godot --path . --script tests/order_flow_visual.gd --quit-after 600 -- --test --gpu-test
```

# Kesilmiş patates rengi — 0.4.1

Çiğ patates çiziminde kızarmış patates paleti ve 0,65 karartma katsayısı kullanılması düzeltildi. Kesilmiş patates artık açık krem/sarı, kızarmış uçlar olmadan çizilir. Fritözdeki patatesin 0,6 karartması da kaldırıldı; altın sarısı palet korunur. Oyun kuralları değişmedi.

`tests/counter_design_visual.gd` yeniden çalıştırıldı: 62 kontrol geçti, çalışma zamanı hatası yok. `validation/counter-design/cut-potatoes.png` ve `frying-potatoes.png` gerçek GPU görüntüleri gözle kontrol edildi. Aşağıdaki 364 kontrol önceki 0.4.0 doğrulamasıdır; bu renk düzeltmesinde tüm süitler tekrar çalıştırılmadı.

# Yeni tezgâh — 0.4.0 / 19 Eylül 2026

- Onaylanan konseptin yerleşimi özgün 480×270 piksel çizime uyarlandı. Büyük orta tahta, dört eşit malzeme tepsisi, sağda pişirme/içecek alanı, altta ahşap dolaplar ve depo bulunur. Açılmamış makineler gri kutu olarak gösterilmez. Tarifler, geliştirmeler ve doğrudan nesne kontrolleri korunur.
- Yeni çizimler `scripts/counter_design.gd` içinde; konumlar aynı `j_ST` üzerinden fare, dokunma, kol ve hassas imlece aktarılır. Çoklu tahtalar, sos/garnitür bölmeleri ve 1/2/3 içecek musluğu yeni ölçüleri kullanır. Döner ve kurye tıklama alanları çakışmaz.
- **364 otomatik kontrol, 0 başarısızlık**: 56 istasyon kuralı + 29 dokunma/pencere + 84 hassas imleç/girdi + 30 platform arayüzü + 35 kesme + 17 fare bıçağı + 34 oyun regresyonu + 62 yeni yerleşim/hedef kontrolü + 17 yeni fare etkileşimi. Bu koşuların günlüklerinde GDScript çalışma zamanı hatası yoktur. Rapor: `validation/counter-design/results.json`.
- 62 yeni görsel/hedef kontrolü: tezgâh sınırları ve çakışmalar, gerçek PNG yüklenmesi, gelişmiş nesnelerin merkezinden doğru seçilmesi, üç renk teması. GPU görüntüleri başlangıç, gelişmiş tezgâh, telefon oranı, üç tahta, depo, tüm ekipmanlar, renk teması ve menüyü kapsar. `validation/counter-design/` içindedir.
- 17 yeni fare kontrolü: iki dürüm sosu, tereyağı, iki garnitür, ayran/iki gazlı içecek/üç musluk kombinasyonlarında doldurma ve bardak alma. Ayran tek başına açıkken özgün tarifteki sıfır doldurma süresi korunur.
- Yeni beş PNG/Pixelorama dosyasıyla toplam **278 sprite bölgesi, 19 atlas, 19 Pixelorama projesi** vardır. Pixelorama 1.2.3 üzerinden beş yeni proje dışa aktarıldı: zemin, tepsi ve turşuda görünür fark yok; et ve patatesin yarı saydam piksellerinde en fazla 1/255 RGB yuvarlaması var. Alfa ve opak pikseller aynıdır. Ayrıntı: `pixelorama-results.json`.
- Doğrulama macOS / Apple M4 / Godot 4.7.1 üzerindedir. Kol ve dokunma olayları üretilmiştir; fiziksel telefon/konsol testi veya yeni FPS ölçümü değildir. Önceki performans tablosu eski yerleşime aittir.

Yeniden çalıştırma (proje kökünde):

```sh
godot --path . --script tests/counter_design_visual.gd --quit-after 1600 -- --test --gpu-test
godot --headless --path . --script tests/counter_input.gd --quit-after 1600 -- --test
```

Aşağıdaki bölümler önceki aşamaların kapsamını ve ölçümlerini saklar.

---

# Doğrudan tezgâh kontrolleri — 19 Eylül 2026

- Sağdaki yazılı işlem paneli ve alttaki kalıcı kontrol/ipucu şeridi kaldırıldı. Oyun alanı kullanılabilir ekranın tamamına 16:9 oranı korunarak sığar. Yardım ve ekran ayarları Mola menüsündedir; F1/kol yardım tuşuyla da açılır.
- Malzeme tepsileri, lavaş/pide, tahta, kağıt, ızgara, patates, fritöz, içecekler, depo yuvaları, müşteriler ve paralar sahnedeki gerçek görsellerinden kullanılır. Kolda seçim işareti ve 1,4 saniyede sönen kısa bağlamsal ipucu vardır. Dokunmada sarma/kağıt/doğrama basılı tutmayla, servis ürüne ve müşteriye dokunmayla yapılır. Elde tutulan yiyecek görünür kalır.
- `tests/stations.gd`: **56 kontrol**. Tam tarif/satış/para, ayrı hazırlama tahtası, malzeme miktarı, özgün üretim süreleri, manuel/otomatik kağıt, ızgara şartı, içecek, patates kutusu, pide/iskender, depo, mola, kol çıkarma, giriş cihazı değiştirme ve hassas imleç.
- `tests/stations_visual.gd`: **29 GPU pencere kontrolü**. Gerçek dokunma olaylarıyla tepsilerden tam tarif, sarma/kağıtlama/servis; ikinci parmak, erken bırakma, nesneden uzaklaşma ve dışarıda iptal. Beş ekran düzeninde alan/en-boy oranı kontrolü. Güncel görüntüler ve raporlar `validation/stations/` altında.
- Diğer kontroller: 84 eski giriş düzeni, 35 döner kesme, 17 fare bıçağı, 34 oyun regresyonu, 30 platform arayüzü (Mola → Kontroller dokunma geçişi dahil). Toplam **285 kontrol**, başarısızlık **0**. Cihaz girdileri macOS üzerinde üretildi; fiziksel telefon/kol/konsol testi değildir.

# Fare bıçağı görünürlük düzeltmesi

- Mutlak fare konumu taşıyan fakat `relative = Vector2.ZERO` olan olay dokunmatik moddan fareye dönmüyordu. Bu durum testte yeniden üretildi; gerçek fare olayı artık konumu ve giriş modunu hemen günceller. Dokunmadan üretilmiş fare olayları ve aktif parmağı kesintiye uğratacak olaylar hâlâ yok sayılır.
- Fare dönerin üzerindeyken kesim animasyonundaki ikinci bıçak çizilmez. Kesik/kırıntı/+1 katmanı bıçağın arkasına alındı. Piksel karşılaştırmasında efektin örttüğü 6 opak bıçak pikseli düzeltmeden sonra 0 oldu.
- `tests/mouse_knife.gd`: **17 kontrol geçti**. Fareye dönüş, sıfır hareket farkıyla yeniden giriş, 40 kare sabit bekleme, 60 kare kesim/bekleme, beş bıçak seviyesinde dolu tepsi ve piksel görünürlüğü doğrulandı. Üç GPU görüntüsü `validation/cutting/mouse-*.png` altında.
- 35 kesme, 84 cihaz girdisi ve 30 GPU arayüz kontrolü de geçti. Son koşulardaki toplam **166 kontrol**, başarısızlık **0**. Arayüz testi ölçeklenen pencereden gelen sıfır hareket farkına sahip fare girişini içerir.

# Kesme kontrolü ve geri bildirim

- `tests/cutting.gd`: **35 kontrol geçti**. R2/RT doğrudan dönere geçer, bırakıldığında eski hedefe döner. Dokunma ve ×/A basılı tutma tekrar keser; klavyede R aynı kısayolu sağlar.
- Başlangıç bıçağıyla 30/60/120 FPS koşullarının her birinde iki saniyede **4 dilim**; yükseltilmiş bıçakta daha hızlı kesim ve 16 porsiyon tepsi sınırı doğrulandı. Fareyle eski kesme hareketi korunur.
- Tetik bırakma, dokunma iptali, ikinci parmak, açık panel, elde ürün, mola ve kol çıkarma kontrolleri geçer. Kesmeyi bıraktıktan sonra fazladan dilim üretilmez.
- Beş gerçek GPU görüntüsü `validation/cutting/` altında. Büyük bıçak özgün küçük bıçağın yerine çizilir; çift bıçak görünmez. Kesik izi/kırıntı/+1 efekti en fazla üç kayıtla sınırlıdır; yalnızca gerçek stok artışında başlar. Uçan et büyütülür; ek stok veya ek oyun rastgeleliği üretilmez.
- Cihaz girdileri macOS üzerinde simüle edildi; fiziksel kol ve telefon üzerinde el hissi ayrıca denenmelidir.

# Çoklu cihaz altyapısı — 19 Eylül 2026

Ana sahne `platform_shell.gd` ile açılır. 480×270 oyun `platform_game.gd` → `game_sprites.gd` zinciri üzerinden bir SubViewport içinde çalışır; dış arayüz yüksek çözünürlükte çizilir.

- 84 giriş/yerleşim kontrolü geçti. Kol ile dürüm hazırlama ve gerçek servis, çoklu parmak sahipliği, hızlı basma/bırakma, hassas imleç, kol değişimi, klavye, uygulama odağı ve kayıt doğrulandı.
- 29 gerçek GPU pencere kontrolü geçti. Ölçekli fare ve yerel dokunma olayları, oyun koluyla tabela klavyesi, Türkçe yazı, telefon/tablet/geniş ekran/dikey pencere ve Android sistem olaylarının benzetimi kontrol edildi.
- Önceki 34 oyun kontrolü yeni `platform_game.gd` üzerinde tekrar geçti. Toplam: **147 kontrol**.
- `validation/platform/` ekran görüntüleri, JSON sonuçları ve dışa aktarma önkoşul raporunu içerir.
- Windows profiliyle Godot kaynak PCK paketi üretildi ve macOS'taki Godot motoruyla açıldı. Bu test Windows EXE veya konsol uygulaması çalıştırma testi değildir.
- PCK açılışında kaynak yükleme hatası görülmedi. Ses çalarken zorunlu `--quit-after` kapanışının bazı koşularında motor MP3 oynatma nesnesinin kapanışta bırakılmadığını bildirdi (`asset_02.mp3`); bu ani kapanış uyarısı ayrıca izlenmelidir. Oyun ve arayüz testleri kontrollü kapanışla hatasız tamamlandı.

Fiziksel PS4/PS5, Windows/Linux, Android veya iOS cihazı test edilmedi. Mobil sanal klavye, gerçek çentik ölçümleri, pil, mağaza doğrulaması ve konsol sertifikasyonu tamamlanmadı. Godot dışa aktarma şablonları kurulu olmadığından bağımsız platform uygulamaları üretilmedi. PS4/PS5 ayrıca Sony erişimi ve lisanslı konsol portu ister. Ayrıntılar `PLATFORMLAR.md` içindedir.

# Sprite / GPU optimizasyonu — önceki ölçüm

Godot 4.7.1 / macOS / Apple M4. Çoklu cihaz dış arayüzü eklenmeden önce `scripts/game_sprites.gd` ile alınan GPU çizimi ölçümleri.

- 152 sprite/katman, 14 PNG atlası ve 14 katmanlı Pixelorama projesi oluşturuldu.
- 34 oyun kontrolü hem CPU hem GPU çizimiyle geçti; çalışma zamanı hatası görülmedi.
- Müşteri mimikleri/hareketleri, yoğurt doluluğu ve döner kesilme/pişme durumlarını kapsayan 92 karşılaştırmada rastgele sayı akışı ve parçacıklar eşleşti.
- Bu 92 izole görüntüde kanal başına en büyük fark 1/255 oldu (tepsi saydamlığı yuvarlaması).
- Pixelorama 1.2.3, katmanlı et atlasını arayüzde açtı. Tezgâh projesinin Pixelorama üzerinden PNG dışa aktarımında görünür RGB değerleri ve tüm alfa değerleri birebir eşleşti. Tam saydam piksellerin kullanılmayan RGB değerleri farklı olabilir.

## Performans

Her sahnede aynı rastgelelik tohumu ve 120 kare, ardışık ayrı koşular. Tablo oyun güncellemesi ve çizim komutlarını hazırlama süresidir; GPU tamamlanmasını, VSync beklemesini veya ekran sunumunu ölçen bir FPS testi değildir. Pencere odağı test sırasında sahneyi değiştirmez.

| Sahne | Önce medyan | Sonra medyan | Süre azalması | Sonra p95 |
| --- | --- | --- | --- | --- |
| Başlangıç oyunu | 23.51 ms | 11.68 ms | %50.3 | 12.15 ms |
| Tüm geliştirmeler, 3 müşteri, yağmur | 44.07 ms | 24.44 ms | %44.6 | 25.61 ms |
| Geliştirmeli dükkânla başlık ekranı | 40.26 ms | 22.53 ms | %44.0 | 24.47 ms |

Ölçülen normal oyun karesinin sonunda yeni doku yüklemesi: 0. Başlık ekranındaki hareketli logo parıltısı gerektiğinde bir doku günceller. Yoğun sahnede 16,7 ms bütçesi hâlâ aşılır; bu sürüm tüm cihazlarda sabit 60 FPS garantisi vermez. Mobil ve diğer işletim sistemleri test edilmedi.

## Görsel karşılaştırma

`validation/sprites/` altında solda önceki CPU çizimi, sağda GPU/sprite çizimi vardır. 14 ekran (başlık, hikâye, başlangıç oyunu ve 11 şehir görünümü) karşılaştırıldı.

| Ekran | Ortalama RGB kanal farkı (0–255) |
| --- | --- |
| title | 0.10671 |
| story | 0.12442 |
| play | 0.30584 |
| city-9 | 0.52316 |

GPU ile CPU arasında özellikle saydamlık ve renk filtresinde küçük yuvarlama farkları bulunur. Döner canlı hesaplanır; rastgele müşteri çeşitliliği korunur, pozlar önbelleğe alınır. Bütün grafikler PNG’ye dönüştürülmüş değildir.

## Yeniden çalıştırma

```sh
godot --headless --path . --script tests/regression.gd -- --test
godot --path . --script tests/regression.gd -- --test --gpu-test
godot --headless --path . --script tests/sprite_equivalence.gd -- --test
godot --path . --script tests/sprite_render.gd -- --test --baseline --cpu-renderer
godot --path . --script tests/sprite_render.gd -- --test --gpu-test
```

Test araçları çalışma klasöründedir, oyuncunun normal kayıtlarını değiştirmez. PNG sprite düzenleme ve dışa aktarma rehberi: `art/PIXELORAMA_REHBERI.md`.

---

## İlk HTML aktarımının geçmiş doğrulaması
# Doğrulama sonuçları

Godot 4.7.1 / macOS / Apple M4 üzerinde doğrulandı.

- Otomatik kontrol: **34**; başarısız: **0**.
- Kapsam: 6 dil, 5 hikâye sahnesi, dürüm hazırlama/satış/para toplama, kayıt okuma, Escape, 6 yardımcı panel, 10 şehir ve başlangıç dükkânı, 24 geliştirme açıkken oyun, gece ekranı, Türkçe tabela girişi ve odak kaybı.
- Kaynaktan çıkarılan 21 gömülü dosyanın SHA-256 doğrulaması: **başarılı**.
- Gerçek Godot penceresinde fareyle Devam → Dükkânı Aç → tezgâh geçişi kontrol edildi.

## Görsel karşılaştırma

Aynı başlangıç rastgelelik tohumu ve aynı kare adımları kullanıldı. Karşılaştırma görsellerinde **solda HTML, sağda Godot** bulunur. Ölçüm üç referans ekranıyla sınırlıdır; tüm oyun karelerinin aynı olduğunu kanıtlamaz.

| Ekran | Ortalama kanal farkı (0–255) |
| --- | --- |
| title | 0.3042 |
| story | 0.1249 |
| play | 0.4443 |

## Kare süresi

Başlangıç ekranlarında tek headless test koşusunda ölçülen değerler; kapsamlı FPS garantisi değildir.
- TITLE: 30.69 ms.
- STORY: 4.48 ms.
- PLAY: 26.39 ms.

İlk aktarımda Godot piksel çizimi ile tarayıcı Canvas çizimi arasında küçük saydamlık/yuvarlama farkları ölçüldü. Sentezlenen seslerin filtreleri Godot PCM üretimine uyarlandığından tını birebir olmayabilir. Diğer işletim sistemleri ve mobil cihazlar bu ortamda test edilmedi.

## Testleri yeniden çalıştırma

Çalışma klasöründe:

```sh
godot --headless --path . --script tests/regression.gd -- --test
godot --headless --path . --script tests/smoke.gd -- --test
```

Testler kendi `artifacts/` kayıt dosyalarını kullanır. Oyuncunun normal kaydını değiştirmez. Test ve dönüşüm araçları dağıtım ZIP’ine dahil edilmez.
