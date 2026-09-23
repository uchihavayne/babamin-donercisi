# Babamın Dönercisi — Godot / GDScript

`myfathersdonershop.html` dosyasındaki oyunun Godot projesi. Oyun çalışırken yalnızca GDScript ve Godot'un standart kaynakları kullanılır. Tarayıcı, WebView, JavaScript yorumlayıcısı, C#, GDExtension veya ek eklenti gerekmez.

## Açma

1. Godot'ta **İçe Aktar / Import** seçeneğiyle bu klasördeki `project.godot` dosyasını seç.
2. İlk açılışta görsel ve ses dosyalarının içe aktarılmasını bekle.
3. **F5** ile oyunu çalıştır.

Doğrulanan sürüm: **Godot 4.7.1**, macOS / Apple Silicon. PC, Android, iPhone/iPad ve PS4/PS5 hedefleri için ortak kontrol ve ekran altyapısı eklendi. Paket düzenlenebilir kaynak projedir; diğer cihazlar için hazır uygulama veya sertifikalı konsol sürümü değildir. Dışa aktarma, kontroller ve kalan cihaz testleri **[PLATFORMLAR.md](PLATFORMLAR.md)** içinde.

## Müşteriden önce hazırlık — 0.7.2

Müşteri veya sipariş seçmeden **lavaş yığınına ya da boş tahtaya basarak** ekmeği doğrudan tezgâha açabilirsin. Fare, dokunma ve kol aynı işlemi kullanır. Malzemeleri önceden ekleyebilir, müşteri gelince hazırladığın açık dürümü onun siparişine bağlayabilirsin. Tezgâh doluysa mevcut ürün korunur ve kısa bir mesaj gösterilir. Pide geliştirmesi açıkken pide ve lavaş ayrı hedeflerdir.

## Malzeme tıklamaları — 0.7.1

Hızlı lavaş → et → turşu tıklamaları artık geliş sırasıyla işlenir; doğrudan malzeme işlemi, bekleyen lavaş açma veya sürüklemeyi bırakma olayının önüne geçmez. Fare ve dokunma aynı sırayı korur. Kedi varken et tepsisindeki tıklama, basılı kalma süresine göre sürükleme sayılmaz; kediyi beslemek için gerçekten sürüklemek gerekir. Boş stok, dolu porsiyon, lavaş eksikliği veya sarılmış ürün kısa bir mesajla açıklanır; mesaj kendiliğinden kaybolur. Çalışan oyunu **F8**, ardından **F5** ile yeniden başlat.

## Daha ulaşılabilir geliştirmeler — 0.7.0

Ana ürünlerin satış fiyatları yaklaşık %25–33 arttı (dürüm 15→20). İlk ekipman alımları ucuzladı; sonraki seviyeler kademeli pahalılaşır. İlk maşa 110, bıçak 100, fritöz 150, içecek standı 220. Var olan hız/kapasite seviyeleri ve son seviyedeki otomasyon korunur. Mağaza kartında gerçek süre/kapasite farkı ve sahip olunan eşyada **GELİŞTİR** düğmesi görünür.

Günde 6 doğru siparişlik kontrollü ekonomi senaryosunda ilk maşa 4. gün yerine 1. gün, içecek standı 4. gün alınabildi. Bu bir sabit iş yükü modeli; gerçek oyuncu temposu değildir. Kayıtlı ekipmanlar korunur. Ayrıntılı fiyatlar, varsayımlar ve düzenleme noktaları: **[ECONOMY.md](ECONOMY.md)**.

## Daha küçük oyun modülleri — 0.6.1

`game.gd` artık **310 satır**. 527 gereksiz yönlendirme kaldırıldı; normal işlemler doğrudan sahibi olan modülü çağırır. Ortak oyun durumu `core/game_state.gd` içinde **284 satırdır**. En uzun uygulama dosyası **509 satır**; ekipman, sipariş hazırlama, telefon/kurye, sokak, karakterler, menüler ve hikâye kendi alt klasörlerinde bulunur.

**Hangi değişiklik hangi dosyada yapılır:** [CODE_MAP.md](CODE_MAP.md). Örneğin döner kesme `systems/equipment/cutting_system.gd`, kızartma `potato_system.gd`, içecek `drink_system.gd`, dürüm hazırlama `systems/orders/assembly_system.gd` içindedir. Görünüm, oyun kuralları ve kayıt biçimi korunur. Godot'ta çalışan oturumu **F8** ile kapatıp **F5** ile yeniden başlat.

## Çalışma zamanı düzeltmeleri — 0.5.4

“Yeni Oyun” sonrasında özelleştirme bilgisi boşken tezgâh varsayılan görünümle çizilir. Hedefi veya diğer gerekli alanları eksik basılı tutma kayıtları güvenle iptal edilir; kesme/doğrama ve sarma ilerlemesi de temizlenir. Yeni sürümü denemeden önce çalışan oyunu **F8** ile durdur, ardından **F5** ile yeniden başlat.

## Daha dolgun kesişler — 0.5.3

Her başarılı kesiş **3 dilim et** kazandırır; üç et parçası tepsiye uçar ve kısa bir `+3` görünür. Başlangıç bıçağı tekrar 0,5 saniyelik temposundadır: 16 dilimlik tepsi **6 kesişte**, sürekli girişte yaklaşık **2,5–2,7 saniyede** dolar. Son kesiş yalnızca kalan boşluğu doldurur; parça sayısı ve gösterge gerçek miktarı izler. Fare, dokunma, kol ve otomatik kesici aynı kesiş verimini kullanır. Geliştirmelerin kesme aralıkları 0,38 / 0,30 / 0,24 / 0,18 saniye; otomatik kesicinin aralığı 0,16 saniyedir. Kesim miktarı `scripts/systems/equipment/cutting_system.gd` içindeki `MEAT_PER_CUT` sabitinden düzenlenebilir.

## Fareyle kesme — 0.5.1

Döner üzerinde **tıklamadan kısa yatay/dikey/çapraz hareketler** keser. Aynı kare içindeki gidiş–dönüş mesafesi kaybolmaz; fare durunca biriken hareketten ek dilim çıkmaz. Bıçak hareketi takip eder, kenarda küçük sapmalarda kaybolmaz ve paket fişi/tezgâhın önünde çizilir. Bıçak hızı ve 16 dilim tepsi sınırı korunur; dolduğunda bıçak görünmeye devam eder ve “TEPSİ DOLU” belirtilir. Yeni kodu denemek için çalışan oyunu durdurup F5 ile yeniden başlat.

## Sipariş döngüsü — 0.5.0

- Müşteri balonları aynı genişlikte: ürünler, sos işareti, turşu/yoğurt/patates simgeleri, istenmeyen malzemede kırmızı çizgi, tamamlanan üründe tik ve sabır çubuğu. Beş müşteri yan yana sığar. Paket fişinde her dürümün tercihleri kendi satırındadır.
- Boş elle müşteriye veya balonuna basarak siparişi seç. Kol ile müşteride × / A aynı işi yapar. Yeni lavaş, seçilen müşterinin uygun siparişine; seçim yoksa ilk bekleyen, başka tahtaya atanmamış dürüme bağlanır. Tahtadaki küçük numara müşteriyi gösterir. Açık dürümü başka müşteriyi seçerek yeniden eşleştirebilirsin.
- Fare, dokunma ve kolda malzemeye tek basış bir porsiyon; basılı tutmak 0,24 saniyeden sonra 0,14 saniye arayla ekler. Kapasite/stoğa ulaşınca, bırakınca, alandan çıkınca veya tahta değişince durur. Malzemeleri oyuncu seçer.
- Tahta üzerinde dört küçük porsiyon göstergesi bulunur. Eşleştirilen sipariş eksik veya yanlışsa sarma tamamlanmaz; kısa mesaj nedeni belirtir. Yanlış malzeme eklenmiş dürüm başka uygun müşteriye eşleştirilebilir veya mevcut çöp işlemiyle atılıp yeniden hazırlanabilir.
- Yanlış tarif/sos müşteri ve kurye tarafından teslim alınmaz; ürün elde kalır, satış ve sipariş ilerlemesi değişmez. Doğru turşusuz/yoğurtsuz/patatessiz tarif tam kalite alır. Dürüm teslim edilince kombodaki içecek/patates/tatlı beklemeye devam eder.
- Tercihlerin açılması mevcut **Malzeme Seçimi** geliştirmesine bağlıdır; ilk seviye tek, ikinci seviye çift eksiltmeye izin verir. Fiyatlar, stok miktarları, pişirme süreleri ve makine açılma koşulları değiştirilmedi.
- Dayı soldaki ayrı alanda tezgâhın önünde çizilir; telefon ve paket fişi başını kapatmaz. Duvar süsü pencerenin solundaki duvar alanına sığdırıldı.

Güncel oyun görüntüleri: `validation/order-flow/orders-desktop.png`, `orders-phone.png` ve `courier-receipt.png`. Kalıcı yardım paneli yoktur; hazırlama göstergesi yalnızca tahtada dürüm varken görünür.

## Yeni tezgâh — 0.4.0

Onaylanan konseptin yerleşimi oyunun 480×270 piksel diline uyarlandı: ortada daha büyük hazırlama tahtası, arkada aynı ölçüde dört malzeme tepsisi, solda döner, sağda pişirme alanı ve içecek makinesi, altta ahşap dolaplar/depo/patates sepeti. Açılmamış makinelerin gri kilit kutuları gösterilmez; ekipmanlar geliştirmeyle görünür. Bu, konsept görselinin statik arka plan olarak kullanılması değildir; yiyecekler, stoklar ve makineler oyunun canlı durumunu gösterir.

Görsel örnek: `validation/counter-design/equipped-counter.png`. Ortak tıklama alanları, kol hedefleri, bardak ve sos bölmeleri yeni ölçüleri kullanır. Tarif ve geliştirme kuralları korunur. Yeni çizimlerin konumları ve hareketli parçaları `scripts/counter_design.gd` içindedir; zemin ve tepsi atlasları Pixelorama'da düzenlenebilir.

## Neler aktarıldı?

- Özgün 480 × 270 piksel oyun alanı, renkler, bitmap yazı tipi ve animasyonlu logo.
- Kodla çizilen dükkân, sokak, trafik, müşteriler, yiyecekler, parçacıklar ve hikâye sahneleri.
- Döner kesme, malzeme ekleme, sürükleyerek sarma, paketleme, servis ve para toplama.
- Gün döngüsü, borç, geliştirmeler, otomasyon, şubeler, şehirler, hava ve olay sistemleri.
- Türkçe, İngilizce, Almanca, İspanyolca, Fransızca ve Portekizce.
- Oyun içi başarımlar, istatistikler, ses ayarları, tabela düzenleme ve kayıtlar.
- HTML içine gömülü 14 logo görseli ve 7 ses kaydı. PNG'ler ve özgün ses dosyaları aynen çıkarıldı; AAC para sesi ayrıca Godot için PCM WAV'a dönüştürüldü.

Kaynak HTML'de kapalı olan ve HTML'ye gömülmemiş özel karakter atlasları burada da kapalıdır. Kaynakta bulunan prosedürel karakter çizimleri kullanılır.

## Godot'ta düzenleme

| Dosya | İçerik |
| --- | --- |
| `scenes/main.tscn` | Ana Godot sahnesi |
| `scripts/platform_shell.gd` | 480×270 oyun viewport'u, güvenli ekran alanı, yardım/ekran ayarları ve yerel yazı girişi |
| `scripts/platform_game.gd` | Platform giriş sınıfı, menü hedefleri ve uygulama yaşam döngüsü |
| `scripts/device_input.gd` | Fare/dokunma/klavye/kol girdileri, nesne seçimi ve hassas imleç |
| `scripts/station_actions.gd` | Tezgâhtaki nesnelerin doğrudan kullanımı, bağlamsal işlemler ve basılı tutma |
| `export_presets.cfg` | Windows, macOS, Linux, Android ve iOS dışa aktarma profilleri |
| `scripts/game.gd` | Modül kurulumu ve özelleştirilen 65 giriş noktası |
| `scripts/core/game_state.gd` | Oyun örneğine ait ortak durum |
| `scripts/systems/customer_system.gd` | Müşteri, servis ve ödeme |
| `scripts/systems/customers/` | Telefon/kurye, Dayı/motor ve karakter görünümü seçimi |
| `scripts/systems/recipe_system.gd` | Tarifler, temel fiyatlar, malzeme miktarları ve kalite |
| `scripts/systems/orders/` | Tahta/lavaş, malzeme ekleme, sos ve sürükleme |
| `scripts/systems/order_system.gd` | Özel sipariş eşleştirme, eksik/istenmeyen malzeme ve doğru servis |
| `scripts/systems/equipment_system.gd` | Geliştirme sorguları ve otomasyon sırası |
| `scripts/systems/equipment/` | Kesme, patates/kızartma, ızgara, içecek, paketleme ve stok |
| `scripts/systems/upgrade_system.gd` | Ekipman satın alma, seviye doğrulaması ve gerçek hız/kapasite önizlemesi |
| `scripts/systems/equipment_tuning.gd` | Bıçak/makine süreleri, kapasite ve seviye ayarları |
| `scripts/systems/save_system.gd` | Kayıt içeriği, şema kontrolü ve kayıtlı oyunu yükleme |
| `scripts/systems/session_system.gd` | Gün başlangıcı/sonu ve sıfırlama |
| `scripts/core/game_loop.gd` | Ana güncelleme ve sahne çizim sırası |
| `scripts/systems/gameplay_input.gd` | Oyun alanındaki tıklama/tuş işlemleri |
| `scripts/rendering/` | Ayrı karakter, yiyecek, ekipman, sokak, menü ve hikâye çizimleri |
| `scripts/core/` | Başlangıç verisi, dil, ses işaretleri ve ortak yardımcılar |
| `scripts/order_flow.gd` | Sipariş modüllerini mevcut sahneye bağlayan kısa adaptör |
| `scripts/rendering/order_draw.gd` | Sipariş balonları, malzeme simgeleri ve paket fişi |
| `scripts/counter_design.gd` | Onaylanan tezgâh düzeni, istasyon ölçüleri ve yeni ekipman çizimleri |
| `scripts/game_sprites.gd` | Sprite çizimi, müşteri pozları ve yoğurt önbelleği |
| `scripts/gpu_canvas.gd` | GPU üzerinde çizim, atlas bölgeleri, kırpma ve renk filtresi |
| `scripts/sprite_library.gd` | Düzenlenebilir PNG atlasları ve manifest yükleyicisi |
| `scripts/spit_pixels.gd` | Dönerin kesilme, dönme ve pişme görünümünün hızlandırılmış hesabı |
| `scripts/native_platform.gd` | Godot pencere/girdi/ses bağlantıları, kayıt ve çizim önbellekleri |
| `scripts/pixel_canvas.gd` | GDScript ile piksel çizimi, katman, kırpma ve saydamlık |
| `scripts/pixel_primitives.gd` | Çizgi, elips, piksel ve dikdörtgen gibi sık kullanılan çizimler |
| `scripts/js_compat.gd` | Kaynağın dinamik veri davranışını koruyan GDScript yardımcıları; JavaScript çalıştırmaz |
| `scripts/save_store.gd` | Yerel JSON kayıt deposu ve geçici dosya üzerinden atomik yazma |
| `data/upg.gd` | Geliştirmelerin isimleri, seviyeleri ve fiyatları |
| `data/sehir.gd` | Şehirlerin renkleri ve görsel temaları |
| `data/glyphs.gd` | Özgün piksel yazı tipinin karakterleri |
| `data/en.gd`, `data/dictionary_*.gd` | Çeviri sözlükleri |
| `assets/images/` | Özgün logo katmanları ve animasyon atlasları |
| `assets/sprites/` | 278 sprite/katman içeren 19 PNG, bölge manifesti ve renk paleti |
| `art/pixelorama/` | 19 Pixelorama `.pxo` projesi (1–41 katman) |
| `assets/audio/` | Ses dosyaları |

Kaynak fonksiyon adları korunmuştur: örneğin `startDay` → `f_startDay`, `drawSpit` → `f_drawSpit`. Ana durum `j_G`, istasyon kutuları `j_ST`, yerleşim `j_LAY`, ürün fiyatları `j_PRICE` içindedir. Editörde bu adlarla arama yapabilirsin.

Örnek düzenlemeler:

- Dürüm fiyatı: `scripts/game.gd` içinde `j_PRICE`.
- Başlangıç borcu: `j_DEBT_START`.
- Tezgâhtaki tıklama alanları: `scripts/counter_design.gd` içindeki `positions` → `j_ST`.
- Dönerin görünümü: `f_drawSpit`.
- Müşteri kuralları: `f_spawnCustomer`, `f_makeOrder`, `f_deliver`.
- Hikâye metinleri: `j_PRO_SCENES`; çizimleri `f_proShopDay` ve diğer `f_pro...` fonksiyonları.

Ana sahnedeki `platform_shell.gd`, 480×270 SubViewport içine `platform_game.gd` oyununu yerleştirir; bu sınıf `counter_design.gd` → `game_sprites.gd` üzerinden `game.gd` kurallarını devralır. Sprite atlasları Godot'un `RenderingServer` arayüzüyle doğrudan GPU'da çizilir; her nesne ayrı bir `Sprite2D` düğümü değildir. Orijinal prosedürel çizimler kaynak ve özelleştirilmiş ölçüler için yedek olarak durur. Rastgele müşteriler poz/mimik değiştikçe sprite üretir; aynı poz sonraki karelerde tekrar kullanılır. Sürekli kesilen ve pişen dönerin görünümü kodla hesaplanır.

## Pixelorama ile görsel düzenleme

`art/pixelorama/counter_design_base.pxo` (yeni tezgâh zemini), `counter_design_trays.pxo` (yeni tepsiler), `counter_fill_*.pxo` (yeni doluluklar) veya diğer `.pxo` dosyalarından birini aç. Her tezgâh eşyası ve her doluluk seviyesi ayrı katmandadır. Çizimini düzenleyip projeyi kaydet; ardından aynı adla `assets/sprites/` içine PNG olarak dışa aktar. Godot oyunu yeniden başlatıldığında değişikliği kullanır.

Tuval boyutlarını ve atlas hücrelerinin yerlerini koru. Et, turşu ve patates atlaslarında 41 doluluk seviyesi vardır; bunlar zaman animasyonu değil, stok miktarına göre seçilen görüntülerdir. Detaylar **`art/PIXELORAMA_REHBERI.md`** içinde.

## Kayıt ve kontroller

- Fare, dokunma, klavye ve standart oyun kolu desteklenir. **Escape**: geri/mola; **M**: ses; **F1** veya kolun üst tuşu: kontrol yardımı. **WASD/oklar** tezgâhtaki nesneleri seçer, **Enter/Boşluk** seçili nesneyi kullanır; sarma ve kağıtlama için basılı tutulur. Ayrıntılı tuşlar `PLATFORMLAR.md` içinde.
- Oyun sırasında sağda işlem paneli veya altta sürekli ipucu/kontrol şeridi yoktur. Yardım ve ekran ayarları Mola menüsündedir; F1 / △ / Y de yardımı açar. Koldaki kısa nesne ipucu 1,4 saniye sonra kaybolur; seçim işareti kalır. Telefonda lavaşa ve gerçek malzeme tepsilerine dokun; dürümü basılı tutarak sar ve kağıtla. Hazır ürüne, ardından müşteriye dokunarak servis et. Kolda sol çubuk/D-pad nesneler arasında geçer, ×/A aynı işlemleri uygular; küçük piksel işareti seçili nesneyi gösterir. L1/R1 hazırlama tahtasını veya aynı gruptaki müşteriyi/ızgara gözünü değiştirir.
- **R2/RT** (klavyede **R**) basılı tutarak doğrudan döner kesilir; bırakınca önceki hedefe dönülür. Telefonda dönerin üstünde basılı tut; büyük bıçak, kesik izi, üç uçan et parçası ve `+3` göstergesi kesimi belirginleştirir. Bıçak hızı ve tepsi sınırı korunur.
- Oyun alanı en-boy oranıyla farklı ekranlara sığar; mobil güvenli alan ve isteğe bağlı TV kenar payı vardır. Yeni dış arayüz Türkçe/İngilizcedir; özgün oyun altı dili kullanmaya devam eder.
- Kayıtlar Godot'un `user://records.json` dosyasına yazılır. Editörden **Project → Open User Data Folder** ile ulaşılır.
- Tarayıcıdaki `localStorage` kayıtları kendiliğinden taşınmaz.
- Özgün oyundaki gibi gün ortasının tüm geçici durumu kaydedilmez; kalıcı ilerleme saklanır.
- Arka plana geçişte girişler bırakılır, gün durur ve kalıcı ilerleme yazılır. Ekran tercihleri ayrıca `user://device_settings.cfg` dosyasındadır.

## Doğrulama ve sınırlar

`VALIDATION.md` ve `validation/` klasörü sonuçları içerir. Gerçek Godot penceresinde menüden oyuna geçiş kontrol edildi. Otomatik testlerde satış, para toplama, kayıt okuma, klavye ile duraklatma, diller, hikâye ekranları, paneller ve tüm şehirler kontrol edildi.

Bu aktarım piksel çizimlerini korur; iki farklı çizim motorunun saydamlık, kenar yumuşatma ve yuvarlama davranışları nedeniyle her pikselin bit düzeyinde aynı olması garanti edilmez. Web Audio ile üretilen efektler GDScript PCM sentezine uyarlandı; sentez filtrelerinin tınısında küçük farklar olabilir. Dosyadan gelen sesler özgün kayıtlardır.

Normal çalışmada görüntü GPU üzerinde birleştirilir; sabit PNG ve önbellek dokuları her kare yeniden yüklenmez. Yazı/karakter sprite üretimi ve bazı efektler gerektiğinde CPU üzerinde hazırlanır. Test makinesindeki önce/sonra süreleri `VALIDATION.md` içindedir. Bu hibrit yaklaşım bütün görsellerin hazır PNG olduğu anlamına gelmez; yoğun sahnelerde ve düşük güçlü cihazlarda ek optimizasyon gerekebilir.

## Geliştirme araçları

Git deposu Godot kaynaklarını, oyun assetlerini, Pixelorama projelerini, testleri ve aktarım araçlarını içerir. `.godot/`, geçici `artifacts/` çıktıları, yerel bağımlılıklar, dışa aktarılan uygulamalar ve dağıtım ZIP'i sürüm kontrolüne alınmaz. Klonladıktan sonra Godot'ta `project.godot` dosyasını aç; motor içe aktarma önbelleğini yeniden oluşturur. Kaynak dağıtım ZIP'ini `python3 tools/package.py` ile üretebilirsin.

Çalışma klasöründeki `source/` ve `tools/`, özgün kaynak dökümünü ve aktarım araçlarını tutar. Dağıtılan ZIP bunlara ihtiyaç duymaz ve bu JavaScript dosyalarını içermez. `tools/convert.cjs` yeniden çalıştırılırsa `scripts/game.gd` ve çıkarılan `data/` dosyalarının üzerine yazar; elle yaptığın Godot değişikliklerini korumak için bu dosyayı çalıştırman gerekmez.
