# Çoklu cihaz altyapısı

19 Eylül 2026. Bu kaynak projenin hedefleri Windows, macOS, Linux, Android, iPhone/iPad ve lisanslı bir Godot konsol portu üzerinden PS4/PS5'tir. Ortak oyun kodu tamamen GDScript'tir. **Bu paket, her cihazda denenmiş mağaza sürümleri içermez.**

## Hazırlanan temel

- `scenes/main.tscn` → `platform_shell.gd`: ekrana ve güvenli alana yerleşen dış arayüz. Oyunun tamamı ayrı bir **480×270 SubViewport** içinde çizilir. En-boy oranı korunur; farklı ekranlarda kenarlarda boşluk kalabilir. Dış arayüz ekran çözünürlüğünde çizilir.
- `platform_game.gd` → `order_flow.gd` → `counter_design.gd` → `game_sprites.gd` → `game.gd`: platform bağlantısı, mevcut GPU/sprite çizimi ve mevcut oyun kuralları. Oyun kodunu yeniden yazmak gerekmez.
- `device_input.gd` ve `station_actions.gd`: tezgâhtaki görseller üzerinden doğrudan kullanım, nesne seçimi ve basılı tutma. Fareyle özgün sürükleme; özel alanlar için hassas imleç korunur. Büyük yazılı işlem paneli veya ekran altında kalıcı ipucu şeridi yoktur. Yardım ve ekran ayarları Mola menüsünden açılır; oyun alanı bu arayüzler için küçültülmez. Seçim sonrası kısa nesne ipucu 1,4 saniyede kaybolur.
- `project.godot` içindeki **Input Map**: tuş atamaları editörden değiştirilebilir. Yerel arayüzün onay/geri tuşları da oyun koluna atanmıştır.
- `export_presets.cfg`: Windows x86_64, macOS universal, Linux x86_64, Linux ARM64, Android ARM32/ARM64, iOS ve **Web (HTML5)** dışa aktarma profilleri.

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
- **Titreşim (haptik):** her ses olayı kendi titreşim desenini de tetikler (`scripts/core/haptics.gd`). Telefon / tablette `Input.vibrate_handheld`, seçili oyun kolunda `Input.start_joy_vibration`; fare / klavyede hiçbir şey olmaz. Yağmur, motor, korna gibi ambiyans sesleri titretmez. Ayar: Mola → Yardım → Ekran ayarları → "Titreşim (telefon ve oyun kolu)" (varsayılan açık, `controls/haptics`). **Android'de `export_presets.cfg` profilinde `permissions/vibrate=true` şarttır** (yoksa titreşim sessizce çalışmaz; eklendi). iOS'ta ek izin gerekmez (iPad'de titreşim motoru olmadığından etkisizdir). Gerçek telefon, kol ve iPhone/iPad üzerinde denenmedi: darbe süreleri / genlikleri `DESEN` tablosundan cihazda ayarlanmalıdır.
- `user://records.json` mevcut ilerlemeyi, `user://device_settings.cfg` ekran tercihlerini tutar. **Gün içi kayıt:** oyun sürerken her 12 saniyede, arka plana alırken ve ana menüye dönerken devam eden günün anlık görüntüsü aynı depoda ayrı bir anahtara (`doner_efsanesi_v1_gunici`) yazılır. Uygulama işletim sistemi tarafından kapatılırsa Devam Et günü molada, kalınan yerden açar; en çok son 12 saniyelik ilerleme kaybolur. Gün bitince, Yeni Oyun'da ve öğretici sürerken anlık görüntü yazılmaz/silinir; bozuk, başka güne ya da eski sürüme ait olan yok sayılır ve mevcut ilerleme kaydı yüklenir. Bulut kaydı veya cihazlar arasında kayıt eşitleme eklenmedi.

## Web (tarayıcıda oynanır, iframe ile gömülür)

Oyun tarayıcıda da çalışır (Godot Web, WebAssembly + WebGL 2). Çıktı bir klasördür; herhangi bir statik barındırmaya konur ve başka bir sayfaya `<iframe>` ile gömülür.

```sh
python tools/web_sablon_indir.py                      # yalnız web şablonları (~20 MB; editörün tam paketi ~1,3 GB)
GODOT=/godot/yolu sh tools/web_derle.sh --tek --zip   # exports/web + TEK dosyalık exports/babamin-donercisi.html (19 MB) + ZIP (14 MB)
python tools/web_sunucu.py                            # yerelde dene: http://127.0.0.1:8060/ (çok dosyalı klasör file:// ile açılmaz)
node tools/web_dene.js [exports/babamin-donercisi.html]   # gerçek tarayıcıda (Chromium) açılış / BAŞLA / konsol denemesi (Playwright gerekir)
python tools/web_tek_dosya.py --sina                  # tek dosya üreticisinin Godot'suz kendi kendine sınaması
```

- **Klasörün içi:** `index.html` (gömülecek sayfa), `index.js` + `index.wasm` (motor, 38 MB; sunucu gzip yaparsa ~10 MB) ve `index.pck` (oyun verisi, 5 MB), ses işleyicileri ve simgeler; ayrıca `embed-ornek.html` (iframe örneği), `OKU-BENI.txt` ve `web_sunucu.py`. İlk yükleme sıkıştırılmışsa ~15 MB, değilse ~45 MB.
- **Tek dosyalık sürüm** (`exports/babamin-donercisi.html`, 19 MB; kullanıcı: "direkt html olarak ver"): motor ve oyun verisi HTML'in İÇİNE gzip + base64 olarak gömülür (wasm 39,5 MB → 10,1 MB → 13,4 MB; pck 5,1 MB → 4,8 MB → 6,4 MB; motor betiği ham). Tarayıcı açılışta `DecompressionStream` ile açar (Chrome 80+, Firefox 113+, Safari 16.4+). Godot'un yükleyicisi dosyaları `fetch()` ile ister ve ses işleyicilerini `AudioWorklet.addModule(adres)` ile yükler; `web/tek_dosya_yukleyici.js` bu istekleri gömülü verinin açılmış haliyle karşılar (ağ isteği yok), ses işleyicilerini `data:` adresiyle verir (`file://` sayfalarında `blob:` adresi yüklenmez), `file://` sayfalarındaki gereksiz ServiceWorker reddini yutar. Üretici `tools/web_tek_dosya.py` (aynı girdi → aynı çıktı). **Nasıl açılır:** dosyaya çift tıkla (`file://`), bir sunucuya koy (HTTPS ya da localhost) ya da `<iframe src="…/babamin-donercisi.html" allow="fullscreen; autoplay; gamepad">` ile gömül. **Düz `http://` (localhost değil) sayfalarda açılmaz:** Godot'un ses motoru güvenli bağlam ister (denendi: `audioWorklet` yoksa motor açılışta hata verir); kabuk bunu 6 dilde açıklar.
- **Neden iframe'e gömülebilir:** derleme **tek iş parçacıklı** (`variant/thread_support=false`): SharedArrayBuffer / COOP / COEP başlığı istemez, özel sunucu ayarı gerekmez. Çizim GL Compatibility → WebGL 2 (projenin zaten kullandığı yol). `tests/web_ortam.gd` bu ayarları kilitler.
- **Gömme:** `<iframe src="…/index.html?dil=tr" allow="fullscreen; autoplay; gamepad" style="width:100%; aspect-ratio:16/9; border:0">`. `allow="fullscreen"` yoksa oyunun "Tam ekran" düğmesi iframe içinde çalışmaz; `sandbox` verilirse en az `allow-scripts allow-same-origin` gerekir.
- **Özel kabuk** `web/kabuk.html`: Godot'un beyaz açılış ekranı yerine oyunun renklerinde, 6 dilde yükleme çubuğu; WebGL 2 yoksa nedenini yazar; telefon dikeyken "telefonu yan çevir" önerisi (kapatılabilir).
- **Tarayıcıya özgü davranışlar** (`scripts/web_ortam.gd`; masaüstü ve yerel mobil derlemelerde hiçbir şey değişmez): telefon / tablet tarayıcısı (CSS `pointer: coarse`) dokunmatik ve mobil sayılır (dokunmatik kip, büyük düğmeler, 30 FPS hedefi); **ilk açılış dili** kayıtlı seçim → `?dil=xx` → tarayıcı dili → İngilizce sırasıyla belirlenir; sürekli kayıt (`user://`) tarayıcının IndexedDB'sine yazılır, adrese özeldir ve sayfa yenilenince kalır; ses ilk dokunuşta açılır (tarayıcı kuralı); titreşim yalnız Vibration API'yi destekleyen tarayıcılarda (Android Chrome) çalışır.
- **Ölçüm** (`--olcum 300`: tam geliştirmeli dükkân, 3 müşteri; aynı sunucu CPU'su ve yazılımsal GL): web release 16,9 ms / kare, yerel debug 11,0 ms; yani web ~1,5× yavaş. Gerçek GPU'lu masaüstünde 60 FPS beklenir, telefonda uygulama 30 FPS hedefine iner.
- **Doğrulandı** (masaüstü Chromium, yazılımsal WebGL 2): açılış ve HD çizim, BAŞLA → prolog → dükkân, dokunmatik telefon emülasyonu (yatay + dikey), farklı kökenli iframe, dil seçiminin sayfa yenilenince kalması (IndexedDB), ses bağlamının dokunuştan sonra çalışır duruma geçmesi, konsolda hata yok. **Tek dosya:** `file://` (çift tıklama), `http://127.0.0.1`, başka kökenli `<iframe>`, `file://` içinde `<iframe>`, telefon emülasyonu; sayfanın kendisi dışında ağ isteği yok; açılış ~2,8 sn (yerel disk, bu sunucuda). **Doğrulanmadı:** gerçek telefon, iPhone Safari (bellek sınırı, titreşim yok), Firefox, Safari, gerçek GPU hızı, sesin kulakla duyulması, uzun oturum.
- **Bilinen ayrıntılar:** açılışta Chromium "GPU stall due to ReadPixels" uyarısını birkaç kez yazar (sprite sayfaları yüklenirken; zararsız, yalnız yükleme anı). Telefon dikeyken oyun küçük görünür (yatay öneri çıkar). Oyunu güncelleyince eski dosyalar tarayıcı önbelleğinde kalabilir: yeni sürümü yeni klasöre koy.

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
| Web (HTML5) | `Web` | Web şablonları (`python tools/web_sablon_indir.py`), `sh tools/web_derle.sh --zip`; statik barındırma (HTTPS), iframe ile gömme. Bölüm: Web |
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
