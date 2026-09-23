# Çoklu cihaz altyapısı

19 Eylül 2026. Bu kaynak projenin hedefleri Windows, macOS, Linux, Android, iPhone/iPad ve lisanslı bir Godot konsol portu üzerinden PS4/PS5'tir. Ortak oyun kodu tamamen GDScript'tir. **Bu paket, her cihazda denenmiş mağaza sürümleri içermez.**

## Hazırlanan temel

- `scenes/main.tscn` → `platform_shell.gd`: ekrana ve güvenli alana yerleşen dış arayüz. Oyunun tamamı ayrı bir **480×270 SubViewport** içinde çizilir. En-boy oranı korunur; farklı ekranlarda kenarlarda boşluk kalabilir. Dış arayüz ekran çözünürlüğünde çizilir.
- `platform_game.gd` → `order_flow.gd` → `counter_design.gd` → `game_sprites.gd` → `game.gd`: platform bağlantısı, mevcut GPU/sprite çizimi ve mevcut oyun kuralları. Oyun kodunu yeniden yazmak gerekmez.
- `device_input.gd` ve `station_actions.gd`: tezgâhtaki görseller üzerinden doğrudan kullanım, nesne seçimi ve basılı tutma. Fareyle özgün sürükleme; özel alanlar için hassas imleç korunur. Büyük yazılı işlem paneli veya ekran altında kalıcı ipucu şeridi yoktur. Yardım ve ekran ayarları Mola menüsünden açılır; oyun alanı bu arayüzler için küçültülmez. Seçim sonrası kısa nesne ipucu 1,4 saniyede kaybolur.
- `project.godot` içindeki **Input Map**: tuş atamaları editörden değiştirilebilir. Yerel arayüzün onay/geri tuşları da oyun koluna atanmıştır.
- `export_presets.cfg`: Windows x86_64, macOS universal, Linux x86_64, Linux ARM64, Android ARM32/ARM64 ve iOS dışa aktarma profilleri.

Yeni tezgâhın bütün giriş yöntemleri aynı `j_ST` ölçülerini kullanır. Yerleşim 480×270 oyun alanında sabittir; ekran en-boy oranı nesneleri esnetmez. Yeni içecek/sos bölmeleri ve depo konumları hem nesne seçimine hem hassas imlece işlendi.

## Kontroller

| İşlem | Klavye/fare | PS düzeni | Genel kol |
| --- | --- | --- | --- |
| Döneri hızlı kes | R basılı tut | R2 basılı tut | RT basılı tut |
| Nesne seç | Fare veya WASD / oklar | Sol çubuk / yön tuşları | Sol çubuk / D-pad |
| Tahta / müşteri / ızgara gözü değiştir | Tab: sonraki, Q: önceki | L1/R1 | LB/RB |
| Nesneyi kullan / sar / kağıtla | Enter veya Boşluk; fareyle özgün tık/sürükle | × bas / basılı tut | A bas / basılı tut |
| Ürünü al / geri bırak | E | □ | X |
| Hassas imleç | Shift | L2 | LT |
| Geri / sürüklemeyi iptal | Esc | ○ | B |
| Mola / devam | P veya Esc | Options | Start |
| Kontrol yardımı | F1 | △ | Y |
| Tam ekran | F11 | Yardım → Ekran ayarları | Yardım → Ekran ayarları |
| Ses aç/kapat | M | Oyun içi SES menüsü | Oyun içi SES menüsü |

Dokunmada lavaşa ve malzeme tepsilerine doğrudan dokun. Dürümü basılı tutarak sar; tekrar basılı tutarak kağıtla (ızgara açıksa önce ızgaraya gider). Hazır ürüne ve ardından müşteriye dokunarak servis et. Kağıt istasyonu da aktif dürümü paketler. Parmağı erken bırakmak veya nesneden uzaklaştırmak işlemi iptal eder. Elde alınan ürün parmağın üstünde görünür. Bir basılı tutma tamamlandığında sonraki işlemi başlatmak için yeniden basmak gerekir. **Dönerin üstüne dokunmak tek kesişte üç dilim kazandırır; basılı tutmak kesmeyi tekrarlar.** Kolda dönerin üzerindeyken ×/A basılı tutmak da çalışır. **R2/RT** (klavyede **R**) imleci doğrudan dönere götürür; bırakınca önceki hedefe döndürür. Böylece sol çubuğu sürekli yukarı–aşağı sallamak gerekmez. Elinde ürün veya açık panel varsa bu kısayol başlamaz.

Kesme hızı mevcut bıçak geliştirmesi ve tepsi kapasitesiyle sınırlıdır. Başlangıç bıçağının bekleme süresi 0,5 saniyedir; her kesiş üç dilim verir. 16 dilimlik tepsi altı kesişte dolar. Sürekli fare hareketi ve basılı tutma testlerinde bu süre 30 FPS’te 2,7, 60 FPS’te 2,6, 120 FPS’te 2,51 saniyedir. Bıçak geliştirme aralıkları 0,38 / 0,30 / 0,24 / 0,18 saniyedir. Otomatik kesici de her kesişte üç dilim verir; aralığı 0,16 saniyedir. Kısayolu bırakmak, geri/iptal, kol çıkarma ve uygulamanın arka plana geçmesi kesmeyi durdurur. Duraklatma sonrasında yeniden başlamak için tetik bırakılıp tekrar basılmalıdır. Fareyi tıklamadan döner üzerinde yatay, dikey veya çapraz hareket ettirmek keser. Kısa hareketler ve aynı kare içindeki hızlı gidiş–dönüşler sayılır; fare durunca dilim üretilmez. Başlangıç hareket eşiği yaklaşık 19 oyun pikselidir; yükseltilmiş bıçakta azalır. Bıçak kenardaki küçük sapmalarda görünür kalır; komşu istasyona taşınınca kesme biter. Tepsi doluyken bıçak saklanmaz, “TEPSİ DOLU” gösterilir.

Dokunma/kol bıçağı daha büyük çizilir ve parmağın solunda hareket eder. Her gerçek kesişte tek kesik izi ve kesme sesi, kırıntılar, üç uçan et parçası ve kısa bir `+3` göstergesi görünür. Tepside yalnızca bir veya iki dilimlik yer kaldıysa hem parça sayısı hem gösterge buna uyar; doluyken başarılı kesim efekti üretilmez. Parçalar tepsiye vardığında ikinci kez stok eklenmez. Aynı anda tek parmak oyundaki sürüklemenin sahibidir. Hızlı dokunuşlarda basma ve bırakma ayrı oyun karelerine iletilir. Sistem tarafından iptal edilen veya oyun alanı dışına bırakılan sürükleme güvenle iptal edilir.

Kol tezgâhta gerçek nesneler arasında atlar; seçilen nesne küçük köşe işaretleri ve kısa bir tuş ipucuyla gösterilir. Malzeme seçiliyken L1/R1 aktif hazırlama tahtasını değiştirir; yanlışlıkla başka tahtaya malzeme eklenmez. ×/A tepside malzeme ekler, tahtada sarar/kağıtlar/alır, müşteride servis eder; içecek ve fritözde işleme göre doldurur veya hazır ürünü alır. Depo açıldığında kendi görünür stok yuvaları seçilir. Menüler ve özel alanlarda eski imleç akışı devam eder; L2/LT basılı tutarak hassas imlece geçilir. Ekran ayarlarından doğrudan istasyon kontrolü kapatılabilir; bu durumda E/□/X eski tutma kilididir. İkinci kol aktif oyuncuyu devralmaz; kullanılan kol çıkarıldığında gün durur, yeni kol ilk girdide devralır. PS tuş adları standart kol düzenini tarif eder; gerçek PlayStation konsol testi anlamına gelmez.

Tabela yazmak için mobil sistem klavyesi, bilgisayar klavyesi veya kol ile gezilen ekran klavyesi kullanılabilir. Yeni dış yardım/ekran arayüzü Türkçe ve İngilizcedir; mevcut oyunun altı dili korunmuştur.

Malzemeye tek basış bir porsiyon ekler; basılı tutmak aynı tahtayı kapasitesine kadar doldurur. Fare/dokunma hedefinden çıkmak, tuşu bırakmak, tahtayı değiştirmek veya mola vermek tekrarı durdurur. Boş elle müşteri/balon seçmek açık dürümü o tarife bağlar; ürün eldeyken aynı işlem servis yapar.

## Ekran, performans ve yaşam döngüsü

- Mobilde iki yatay yön desteklenir (`sensor_landscape`). Tablet çoklu pencere/dikey pencere durumunda da tam oyun sığdırılır; tezgâh yatay oynamak için tasarlanmıştır.
- Android/iOS güvenli alan bilgisi ekran koordinatlarından arayüz koordinatlarına çevrilir; çentik ve sistem kenarları dışarıda bırakılır.
- Ekran menüsündeki **TV için kenar payı** görüntüyü içeri alır. **Tam piksel ölçekleme** piksel büyüklüklerini eşit tutar; daha fazla kenar boşluğu bırakabilir.
- Grafikler aynı düşük çözünürlükte işlendiği için 4K ekran oyun içi çizim çözünürlüğünü artırmaz. Dokular nearest filtreyle büyütülür.
- Bilgisayarda varsayılan hedef 60 FPS, mobilde 30 FPS'tir. Ekran menüsünden değiştirilebilir. Bunlar kare sınırıdır; her donanımda bu hızın sağlanacağını garanti etmez. Yoğun sahnelerin CPU yükü için önceki ölçümler `VALIDATION.md` içindedir.
- Odak/arka plan kaybında tutulan girişler temizlenir, gün duraklar ve mevcut kalıcı ilerleme kayıt biçimi yazılır. Geri dönünce devam kararı oyuncudadır. Android sistem geri tuşu önce açık dış pencereyi kapatır.
- `user://records.json` mevcut ilerlemeyi, `user://device_settings.cfg` ekran tercihlerini tutar. **Uygulama işletim sistemi tarafından kapatılırsa devam eden günün bütün geçici durumu geri yüklenmez:** mevcut oyunun ilerleme kaydı yüklenir. Bulut kaydı veya cihazlar arasında kayıt eşitleme eklenmedi.

## Dışa aktarma

1. Projede kullanılan Godot sürümünün dışa aktarma şablonlarını **Editor → Manage Export Templates** üzerinden kur.
2. **Project → Export** içinde hedef profili seç. Çıktı klasörünü oluştur. `com.myfathersdoner.game` örnek paket kimliğini kendi benzersiz kimliğinle değiştir.
3. Önce geliştirme sürümü çıkarıp ilgili gerçek cihazda dene. Mağaza için imzalama ve mağaza bilgilerini tamamla.

| Hedef | Hazırlanan profil | Yayın öncesi gerekenler |
| --- | --- | --- |
| Windows | `Windows` | Eşleşen şablon; Windows'ta gerçek çalıştırma ve kol testi; dağıtım için gerekiyorsa kod imzası |
| macOS | `macOS` | Universal şablon; doğrudan dağıtım için uygun imzalama/notarizasyon |
| Linux / ARM64 | `Linux`, `Linux ARM64` | İlgili şablon; GPU/sürücü ve ses testi |
| Android | `Android` | Şablon, uyumlu JDK/Android SDK; yerel deneme APK. Play Store için Gradle/AAB ve kullanıcıya ait release keystore |
| iPhone / iPad | `iOS` | Şablon, macOS/Xcode, Team ID ve provisioning. Profil Xcode projesi çıkarır; cihaz derleme ve imzası Xcode'da tamamlanır |
| PS4 / PS5 | Ortak GDScript + kol altyapısı | Sony geliştirici onayı, yetkili Godot konsol portu, konsol SDK/export araçları ve devkit; platform servisleri ve sertifikasyon testleri |

PS4/PS5 için sahte bir export profili eklenmedi. Godot'un standart açık kaynak dağıtımı konsol SDK'larını içermez. Sağlayıcının renderer, kayıt, kullanıcı hesabı, sistem klavyesi, trophy ve askıya alma gereksinimleri lisanslı port aşamasında uyarlanmalıdır. PC'de DualShock/DualSense kullanmak, konsol sürümü üretmekle aynı işlem değildir. [Godot konsol desteği](https://godotengine.org/consoles/).

Resmî yönergeler: [Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html), [farklı çözünürlükler](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html).

Yerel önkoşulları görmek için `python3 tools/check_platforms.py` çalıştır. Bu araç kurulum yapmaz, şifre veya imza dosyası okumaz. Hazırlama sırasında Android SDK ve Xcode klasörleri vardı; Godot 4.7.1 dışa aktarma şablonları yoktu. Dolayısıyla bu pakette EXE/APK/IPA/PlayStation uygulaması yoktur. Doğrulama için Godot kaynak PCK paketi üretildi ve kurulu Godot motoruyla açıldı; bu bağımsız Windows uygulaması değildir.

## Test kapsamı

macOS / Apple M4 / Godot 4.7.1 üzerinde:

- Yeni tezgâh: 62 yerleşim/GPU kontrolü ve 17 fare etkileşimi. Tüm süitlerle toplam 364 kontrol geçti; ayrıntılar `VALIDATION.md` içindedir.

- Doğrudan nesne kontrolü: 56 kural/girdi kontrolü ve 29 gerçek GPU pencere kontrolü. Tepsilerden dokunarak tam tarif, sarma/kağıtlama, müşteriye servis, çoklu parmak/iptal ve beş ekran düzeni. Görseller `validation/stations/` altında.

- 84 kontrol: kol ile gerçek dürüm hazırlama ve servis, hassas imleç, hedef geçişi, kol çıkarma/değiştirme, dokunma sahipliği, hızlı dokunma, klavye, arka plana geçiş, kayıt, sekiz ekran geometrisi ve kesirli ekran ölçeğinde tam pikseller.
- 30 gerçek Godot pencere kontrolü: ölçekli fare girdisi, dokunmayla dış düğmeler, oyun koluyla yerel klavyede yazma, Türkçe karakterler, telefon/tablet/geniş ekran yerleşimi ve Android yaşam döngüsü olaylarının benzetimi.
- 34 önceki oyun testi yeni platform sınıfıyla tekrar geçti.
- Kesme iyileştirmesi için ayrıca 35 kontrol: R2/RT ve R, dokunma ve ×/A basılı tutma, 30/60/120 FPS hız eşitliği, bıçak seviyeleri, tepsi kapasitesi, iptal ve durdurma. `validation/cutting/` beş GPU ekran görüntüsü ve sonuç raporunu içerir.

Ekran görüntüleri ve sonuç JSON'ları `validation/platform/` içindedir. Testler masaüstünde üretilmiş cihaz girdilerini kullanır; fiziksel PS4/PS5, Android, iPhone veya iPad üzerinde performans, pil, sanal klavye, çentik, mağaza doğrulaması veya sertifikasyon testi yapılmadı. Desteklenecek minimum cihaz/işletim sistemi listesi bu donanım testlerinden sonra kesinleştirilmelidir.

Çalışma klasöründeki testler:

```sh
godot --headless --path . --script tests/stations.gd -- --test
godot --path . --script tests/stations_visual.gd -- --test --gpu-test
godot --headless --path . --script tests/platform_input.gd -- --test
godot --path . --script tests/platform_visual.gd -- --test --gpu-test
godot --headless --path . --script tests/regression.gd -- --test
```

Görüntü testi gerçek bir grafik oturumu ister. Geliştirici testleri çalışma klasöründedir; kaynak dağıtım ZIP'inde sonuçlar bulunur. Üretim export profilleri `source/`, `tools/`, `tests/`, `art/` ve doğrulama dosyalarını uygulamaya katmaz. Pixelorama çalışma dosyaları kaynak ZIP'inde korunur.
