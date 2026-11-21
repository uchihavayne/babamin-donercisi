# Babamın Dönercisi — Birleşik Sürüm

Bu klasör iki çalışmanın birleşimidir:

| Kaynak | Ne alındı |
| --- | --- |
| `kebap-shop-main` v0.7.2 (taban) | Modüler kod yapısı (`scripts/systems`, `scripts/rendering`, ~100 modül), onaylı yeni tezgâh yerleşimi (`counter_design.gd`), sipariş akışı (`order_flow.gd`), platform kabuğu, dokunma/kumanda girişi, testler |
| `Babamin_Donercisi_Remake` | 2x HD görsel katman: GPU tuvali, Blender atlasları, shader'lar, HD kancaları, animasyon iyileştirmeleri, keskin ölçekleme |

İki kaynak klasör de **dokunulmadan** duruyor. Oynanış, kurallar ve ekonomi tabandakiyle aynı.

## Görsel katman nasıl bağlandı

```
pixel_primitives -> native_platform -> remake_gorsel -> core/game_state -> game
  -> game_sprites -> counter_design -> counter_design_hd -> order_flow -> platform_game
```

- `native_platform.gd`: `OLCEK = 2`; GPU kipinde `gpu_canvas.gd` (remake sürümü) 960x540 çizer. Testlerdeki CPU tuvali (varsayılan `--test`) değişmedi: HD kancaları yalnız GPU tuvalinde çalışır, piksel anlık görüntüleri aynı kalır.
- `platform_shell.gd`: oyun 960x540 alt görünümde; pencereye `shaders/keskin_olcek.gdshader` ile basılır (kesirli ölçekte eşit piksel). Girdi yine 480x270 mantık biriminde.
- `remake_gorsel.gd`: bütün HD çizimler. Oyun fonksiyonlarına `_c("f_x", ...)` ile erişir (önce oyun nesnesi, sonra modüller).
- Modüllerdeki kancalar: `if game.f_hdX(...): return null` — remake'teki 104 kanca otomatik taşındı (aynı aktarım kaynağı, hizalama ile).
- `game_sprites.gd`: HD açıkken HD parçası olan çağrılar önce HD'yi dener; HD karşılığı olmayan boyutlarda PNG önbelleği kalır (performans).
- `counter_design_hd.gd`: yeni tezgâhın HD gövdeleri. Onaylı yerleşim ve durum mantığı (LED, doluluk, kayma, sallanma) aynı; HD kapalıysa `counter_design.gd` çizer.
- `rendering/order_draw.gd`: yeni sipariş balonu 9 dilim HD balon + HD malzeme çipleri.

F2: HD aç/kapat (karşılaştırma).

**Oynamak:** `Oyna.cmd` (çift tıkla). Kayıt klasörü ayrı: `%APPDATA%\Babamin_Donercisi_Birlesik` (remake ve kebap-shop aynı `My Father's Kebab Shop` klasörünü paylaşıyor; ilk açılışta oradaki kayıt yalnız okunup kopyalanır, oraya yazılmaz).

## Blender parçaları (yeni tezgâh)

| Dosya | Atlas | İçerik |
| --- | --- | --- |
| `blender/models/tezgah2_hd.py` | `tezgah2` | tezgâh yüzeyi (tema rengiyle modülate), raf, damlama tepsisi, soğuk ray, çekmeceler, servis bölmesi, hazırlık tahtası 150x48, fritöz, ızgara, kesme tahtası + satır + patates, içecek dolabı + musluk panelleri, kâğıt makinesi/yığını, stok çekmecesi, patates kasası, çöp, ekmek altlığı, sos şişeleri, 46'lık kutu rafı |
| `blender/models/tepsi_hd.py` | `tepsi` | + 44x32 / 44x27 / 34x27 küvetler, 44x32 yoğurt (küvet holdout ile) |
| `blender/models/dayi_hd.py` (`DAYI_OLCEK=0.82`) | `dayi82` | servis bölmesindeki 0.82 ölçekli Dayı |
| `blender/models/afis_olcekli.py` | `afis64` | 0.64 ölçekli duvar afişleri |
| `blender/models/ikon_hd.py` | `ikon` | + sipariş balonu malzeme çipleri (istenen / istemiyor), hazırlık şeridi ikonları |
| `blender/models/sargi_hd.py` | `sargi` | açık dürümün et/patates/turşu/yoğurt/sos katmanları (oyundaki `f_hash1` yerleşimi, 4 seviye × 4 ölçek) |
| `durum_hd.py`, `yiyecek_hd.py`, `pide_hd.py` | `durum`, `yiyecek`, `pide` | + yeni tahtanın 1.8 / 1.22 / 0.9 ölçekleri |
| `blender/models/dolgu_hd.py` + `blender/dolgu_birlestir.py` | `dolgu180`, `dolgu122`, `dolgu90`, `dolgu100` | açık dürüm dolgusu: et × patates × turşu (0–4) her birleşimi lavaşla TEK sahnede (parçalar birbirine karışır, gölge düşürür); yoğurt ve sos etin yığın seviyesine göre üste dökülür |

Birleşik yerleşimin ölçüleri (pencere 300×103, cam 292×95, döner şişi) `blender/models/yerlesim.py` içinde; `vitrin_hd.py`, `sokak_arka_hd.py` ve `arac_hd.py` (otomatik kesim rayı) buradan okur.

Kullanıcı geri bildirimiyle gelen düzenlemeler (2026-09-23):

| Konu | Çözüm |
| --- | --- |
| Arabalar/insanlar duvarın üstünden geçiyordu | Pencere çerçevesi, kepenk ve sokak arka planı yeni cam boyunda |
| Kedi geri geri yürüyordu | Kedi hep sola yürür; yürüyüş kareleri aynalı |
| Rakibin adamı tezgâhın üstüne çıkıyordu | Raf hizasında kırpılır; model yenilendi |
| Dayı sağa sola kayıp titriyordu | Ayaklar sabit, nefes/ağırlık yalnız üst gövdede, yarım piksel |
| Oto kesim rayı Dayı'nın üstündeydi, alt ucu yarımdı | Dayı şişten sonra çizilir; ray uzadı, cıvatalı ayak |
| Fritöz, patates sepeti | Remake (önceki) tasarımları yeni yuva ölçüsünde |
| Patates doğrama düzdü | Patates kısalır, dilimler birikir, satır iner-kalkar, kırıntı, bıçak izi |
| Soslar yarım/kesik | Dolu gövdeli sıkma şişe, ortada etiket |
| Ekmekler altlığa oturmuyordu | Tabaksız yığınlar altlığın üstünde |
| Açık dürümde turşu fazla/büyük, yoğurt şerit | 2–4 küçük turşu, kaşık yoğurt damlaları, ince sos |
| Balonda sıra numaraları, "!" işareti | Numaralar kaldırıldı; sos rozeti (acı biber / sarımsak) |
| Balondaki içecek ≠ makinedeki bardak | İkon makinedeki cam bardak modelinden |
| Domates/biber bitmiyor gibi | Tepside tane tane azalır |
| Depo çekmecesinde yalnız 2 kavanoz | Açık tüm stok türlerinin ikonu |
| Tatlı tepsisi | Bakır baklava tepsisi + 0–6 dilim |
| Elektrik kesintisi ışığı kare kare | `shaders/kesinti.gdshader`: karanlık + ocaktan yumuşak sıcak hale |
| "MAÇ ÇIKIŞI" yazısı | Kaldırıldı; müşteriler ve yayalar takım atkılı |

İkinci tur:

| Konu | Çözüm |
| --- | --- |
| Dürümdeki turşu ve yoğurt olmamış | Turşu: yassı, ince oval dilimler (kabuk kenarı + çekirdekler); yoğurt: dürüme sürülmüş düzensiz kenarlı ince lekeler |
| "Sossuz isteniyor" diye dürüm katlatılmıyordu | Engel kaldırıldı: dürüm başka bir bekleyen siparişe uyuyorsa ona bağlanır, hiçbirine uymuyorsa serbest dürüm olarak katlanır |
| Lavaş ucundan katlanmış gibi | Açık lavaş yeniden modellendi (ön kıvrım yok, kenar halkası, kızarma lekeleri) |
| Kedi modeli zayıf | Tekir kedi: göğüs/kalça hatlı gövde, beyaz patiler, kıvrık kuyruk, badem gözler, pembe iç kulak |
| Rakip çıkarken içecek makinesinin üstünden geçiyordu | Rakibin gövdesi müşterilerle aynı katmanda çizilir (balonu en üstte kalır) |
| Yüzlerde ip gibi çizgi | Kuryenin çene kayışı kaldırıldı, kask alnın üstüne alındı; HD yüzde "çene" ayrıntısının (koyu elips + çizgi) çenenin tamamını kesen şeridi çizilmez |
| Dayı'nın elleri top gibi | Avuç + dört parmak + başparmaklı eller; dirsekte hafif kırılan, bileğe incelen yen; kısa boyun, çene gölgesi, dik gömlek yakası |

Üçüncü tur:

| Konu | Çözüm |
| --- | --- |
| Dayı hiç olmamış | Model baştan: yumurta yüz, kapaklı gözler, gür kaşlar, pala bıyık, konik fes + kordonlu püskül, eğimli omuz + göbek, işlemeli bordo yelek, çizgili kuşak, kıvrımlı şalvar, yemeni, kabarık yenler (katman adları aynı) |
| Ekmek kesik/yarım | Açık dürüm sarma animasyonu için alttan kırpılıyordu; sarma başlamamışken HD'de kırpma yok |
| Döner keserken Dayı anlamsız hareket ediyor | Döneri oyuncu keser; Dayı kesimde bekleme pozunda durur, şişe bakar |
| Dolgu katman katman, karışmıyor | `dolgu_hd.py`: 125 birleşim tek 3B sahnede; yoğurt/sos yığının üstüne dökülür |
| Lavaş tahtada durmuyor, havada gibi | Tek üründe (1.8) lavaş tahtanın ön kenarına taşıyordu ve eski gölge elipsi aşağı düşüp kenardan sarkıyordu: çizim 3.5 px yukarı (hedef noktası aynı), HD'de lavaşa yapışık temas gölgesi, lavaş alttan inceltildi (2.1 → 1.35 px) |
| Sarılı dürümün ucu kapalı | Kamera hafif sağdan (x += y·0.42, `durum_hd.x_egim`): sağ uç açık, dış kat + sarmal iç kat + uçtan taşan et/patates/turşu/sos; sol uç kıvrık kapalı; kağıt aynı açıyla; uçtaki piksel işaretleri HD'de yok; gölge gövdeye yapışık |
| Lavaş pizza hamuruna benziyor | Kabarık kenar halkası ve kusursuz elips kaldırıldı: düzensiz kenarlı ince yufka, yumuşak dalgalı yüzey, soluk kızarma benekleri + un tozu (dolgu yeniden render) |
| Açık uç görseli iyi değil | Uç baştan: gölgeli iç yüzey (derinlik), ince dalgalı açılmış lavaş ağzı, uçtan kabarık taşan döner talaşları, üç patates çubuğu, yüzü görünen iki turşu dilimi, beyaz sos + kısa damla |

Dördüncü tur:

| Konu | Çözüm |
| --- | --- |
| Bahis penceresi ne kabul ne ret | Düğmeler müşteri tıklama alanına düşüyordu; panel açıkken panel içi tıklama istasyonlara/oyun girdisine gitmez (`tests/bahis_input.gd`) |
| Dayı motorla ters gidiyor | Çıkışta (sola) model aynalanır |
| Izgara birden fazla dürüm almıyor | Tek tıkta boş göz kadar sarılı dürüm girer; dar ızgarada 1 / 2 satır / 2x2 yerleşim |
| Tahtada bölüm seçip malzeme eklemek saçma | `wrap_system.f_malzemeHedefi`: malzeme ona ihtiyacı olan ürüne gider (seçili → seçili siparişe bağlı → en eski; sipariş istemiyorsa gitmez); seçili ürün ayrılınca sıradakine geçilir (`tests/akilli_hedef.gd`) |
| Standart dürümde malzeme çipleri gereksiz | Balonda yalnız istenmeyen malzemeler (üstü çizili) satır açar |
| Turşu vb. ikonlar kötü | `ikon_hd.malzeme_model`: kornişon+dilim, çanakta yoğurt, kapta patates, talaş et, domates, biber, tereyağı |
| İskender tabağında ne eksik görünmüyor | Hazırlık şeridi tabak için: et, yoğurt, tereyağı (+ domates, biber); pide için DOĞRA n/N |
| İskender pidesi (yığın ≠ tahta) | `pide_hd.pide_mesh`: tırnaklı oval pide hem yığında hem tahtada |
| Şemsiyeler yetersiz | Dilimli HD şemsiye (kubbe + sap); yağmurda yürüyenlerin %80'i şemsiyeli |
| Hırsız modeli zayıf | Bere, göz maskesi, çizgili kazak, çuval |
| Yükseltmeler ucuz | Fiyatlar 0.7.0 ile remake arasına çekildi (ECONOMY.md) |

Beşinci tur (cila):

| Konu | Çözüm |
| --- | --- |
| Pide yığınının üstü kesik | Tuval üstten büyüdü; katmanlar hafif dönük (paralel çizgi gibiydi) |
| Moto siparişinde sos ikonları farklı | `phone_draw` yeni fişi modülde arıyordu (hep eski fiş); fiş balonla aynı HD ikonlar, ölçeksiz |
| Balonda patates dürümden büyük, üst üste | Ürün başına eşit 20 px hücre, tek tip `sip_*` ikonlar, satırda en fazla 3 ürün |
| Gün sonu / rekor listesinde ikonlar taşıyor | Küçük tek tip `lst_*` ikonlar |
| Hava rozeti telefonun üstünde | Üst satırda borç kutusunun yanında |
| "BOZUK" moto etiketi Dayı'nın üstünde | Bölmenin altında |
| Hata taraması | `tests/kaos.gd` (HD, rastgele eylem + olaylar): 4 tur, 29.000 kare, 0 betik hatası; bozuk üç test onarıldı |

Önizleme: `python blender/tezgah2_onizleme.py` (parçaları oyundaki yerlerine dizer).

**Atlas yeniden paketlenince Godot içe aktarması şart**:

```sh
python blender/hd_atlas.py tezgah2_hd tezgah2
godot --headless --path . --import
```

Dürüm dolgusu (4 ölçek × 155 render, ölçek başına ~1 dk; ölçekler paralel çalıştırılabilir):

```sh
blender --background --factory-startup --python blender/models/dolgu_hd.py -- 180   # 122 90 100
python blender/dolgu_birlestir.py
python blender/hd_atlas.py dolgu180_hd dolgu180    # her ölçek için
```

Yoksa `atlas.json` yeni koordinatları gösterir ama doku eski kalır; parçalar karışık görünür.

`blender/out/` git dışı (yeniden üretilebilir); remake'in çıktıları buraya kopyalandı, paketleyici tüm katmanları buradan okur.

## Doğrulama

```sh
sh tests/kontrol.sh                                   # tüm betikler ayrıştırılır (tek Godot açılışı)
sh tests/hepsi.sh                                     # ayrıştırma + tabanın tüm testleri + görsel testler (~3 dk)
godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test --full [--sahne shop|title|dayend]
godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test --full --kedi gelis|bekle|yiyor --rakip 330 --kalip kurye
godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test --dolgu 4,3,2,3 --sos garlic   # tek dürüm (1.8 ölçek)
godot --path . --resolution 960x540 --script tests/hd_musteri_dizi.gd -- --test --gpu-test --adet 32 [--kalip kurye]   # yüz yüz müşteri ızgarası
godot --path . --resolution 960x540 --script tests/hd_profil.gd -- --test --gpu-test
godot --path . --resolution 960x540 --script tests/kaos.gd -- --test --gpu-test --kare 9000 --tohum 7   # rastgele oyun turu, hata avı
godot --headless --path . --script tests/module_snapshot.gd --quit-after 3000 -- --test
```

Tabanın bütün testleri geçiyor (sipariş akışı, kesim, istasyonlar, girişler, ekonomi, anlık görüntü 6/6). Anlık görüntü referansında tek değişiklik `upgraded-shop`: taban projede boyalı duvar siyah çiziliyordu (`js_compat` `toString(16)` tabanı yok sayıyordu), birleşik sürümde doğru renk.

Kare süresi (tam yükseltmeli oyun, 300 kare ortalaması, editör motoru, Ryzen 5 3600X + RTX 5060): 13,1 ms; başlık 14 ms. Ölçüm: `hd_sahne.gd --full --kare 60 --olc 300`, ayrıntı `tests/hd_profil.gd`, tek çağrı maliyetleri `tests/hd_mikro.gd`.

## Yapılacaklar (6. tur analizi, 2026-09-24)

Kullanıcının sırası: **1, 2, 9 → 15, 18 → 10 → kalanlar**. Biten madde `[x]`.

- [x] 1 Sarma animasyonu CPU piksel tüp → Blender tüpü (durum_tup_<1..10>, benekler dönerek)
- [x] 2 İskender tabağı → iskender_hd.py (tabak+pide+et+sos+yoğurt tek sahne; biber, közlenmiş domates katman)
- [x] 9 Oyun sonu: kutlama → 5 sahnelik kapanış hikâyesi (ÖDENDİ damgası, baba, dolu dükkân, kepenk, SON kartı) → serbest oyun (tests/kapanis.gd)
- [x] 15 Performans: oyun karesi 14,4 → 13,1 ms, başlık 19,6 → 14,0 ms (uçan et talaşı, elips, çerçeveli yazı, yaya kimliği, sokak ölçüsü önbellekte; başlık vinyetinin görünmeyen 52 çerçevesi kesildi). Mobil zaten 30 FPS. Release masaüstü 11,5 ms (hata ayıklama 15,6). Android APK: exports/android (ETC2/ASTC açıldı); telefonda Ayarlar → "Kare süresini göster". Ölçüm modu: `-- --olcum 300`
- [—] 18 Ses: fiziksel modelle sentezlenmiş örnekler denendi, kullanıcı beğenmedi ("eski sesler daha iyiydi") → kaldırıldı, eski sesler duruyor
- [x] 10 Tempo ölçüldü (tests/tempo.gd, ECONOMY.md): ilk şube 21-35. gün, borç 78-107. gün; borç ilk 60 günde neredeyse erimiyor (karar kullanıcıda)
- [—] 3 Yazıya Scale2x denendi, kullanıcı beğenmedi ("yazı kalitesini niye böyle yaptın") → eski piksel yazı
- [x] 4 Parçacık: konfeti dönen kâğıt, büyük benek yuvarlak, hızlı kıvılcım/kırıntı kısa izli
- [x] 5 Müşteri ifadesi okunur: sabırsız (0,55 altı) ter damlası, kızgın öfke damarı + kırmızı yanak, mutlu pembe yanak (hd_musteri_dizi --ruh)
- [x] 6 Dayı: üçüncü jest çay yudumu (ince belli bardak, 8 kare, yudumda gözler yarı kapalı, kol yüzün önüne geçer); mevcut: nefes, fes/bıyık jesti, kırpma, sevinç
- [x] 7 Gece hırsızı: sinsi parmak ucu yürüyüş, kasada çömelip iki elle karıştırma + çuvala uçan banknotlar, kaçışta toz (süsler saat+hash)
- [x] 8 Dükkân: alınan istasyon gri sahnede renkli belirir + altın çerçeve, 1,6 sn'de griye döner (gpu_canvas mono_kar)
- [—] 11 İtibar sistemi önerildi, kullanıcı seçmedi
- [x] 12 Toplu sipariş (kullanıcı seçimi): 5. günden sonra telefon %22 "x4/x5" çalar, 4-5 standart dürüm (+ bazen içecek), ürün başı paket ücretinin 1,4 katı, fiş "TOPLU" iki sütun (tests/toplu_siparis.gd); acele/müdavim istenmedi
- [x] 13 Ertesi gün başında "YENİ: Fritöz 6.5sn > 4.8sn" bildirimi + istasyon parlaması
- [x] 14 Olay dengesi ölçüldü: bahis panelinde geri sayım zaten var; gece hırsızı borç bitişini 2-4 gün geciktiriyor, güvenlik azaltıyor (tempo.gd --hirsiz) → değişiklik gerekmedi
- [—] 16 Eski piksel yolu bilinçli kalıyor (testler + ölçekli çizim yedeği)
- [x] 17 (tr, en) çiftleri localization.cift ile sözlükten; 93 metin 4 dile çevrildi (tests/dil_cift.gd)
- [x] 19 İstasyon adı etiketi fare 0,45 sn durunca belirir (çerçeve hemen)
- [x] 20 Öğretici/onay mesajları oyun başına ilk 3 kez; hata ve olaylar her zaman
- [x] 21 Mobil: telefon oranında (2,17:1) kesilme/çakışma yok; Android yatay kilitli (dikey hiç oluşmaz)

## Yedinci tur (2026-09-24)

| Kullanıcı | Yapılan |
| --- | --- |
| Yazı kalitesi/tipi kötü | Scale2x kaldırıldı, eski piksel yazı |
| Yeni sesler kötü | Sentez sesler kaldırıldı, eski sesler |
| Toplu sipariş | 5. günden sonra telefonun %22'si "x4/x5": 4-5 standart dürüm, ürün başı paket ücretinin 1,4 katı (`tests/toplu_siparis.gd`) |
| Dürüm tahtaya geri konmuyor, bazen | Elde ürünle BOŞ tahtaya tıklamak hiçbir şey yapmıyordu; artık bırakır |
| Hazır İskender teslim edilemiyor | Tabak ancak tamamen dolunca alınabiliyordu; seçili tahtada ikinci tıklamada eksik tabak da alınır |
| Eksik malzemeyle verilebilsin, ücret ona göre | Müşteri ve paket eksik/fazla malzemeli dürümü kabul eder; en iyi uyan kaleme gider; ücret çarpanı et .40 + patates .28 + turşu .16 + yoğurt .16 (istenmeyen konmamışsa tam). Sarılmamış/kâğıtsız/ızgarasız/yanık yine verilmez (`tests/eksik_teslim.gd`; tabanın order_flow testi karara göre güncellendi) |

## Sekizinci tur (2026-09-25)

| Kullanıcı / oyuncu | Yapılan |
| --- | --- |
| "En basit şey için 7-8 tur; aynı şeye defalarca bastırarak keyif olmaz" | Tek tık tam porsiyon; maşa artık 2-3 ürüne birden koyar (son seviye yan malzeme seti); ilk seviye fiyatları 0.7.0; ilk günlerde müşteri daha sık; borç taksiti 6. günden. Önce/sonra tablosu ECONOMY.md. Taban testleri "tık başına 1 birim" varsayımından tam porsiyona güncellendi; anlık görüntüde yalnız rastgele sayı durumu kaydı (daha az parçacık), tahta/stok/para aynı (`tests/tek_tik.gd`) |

## Dokuzuncu tur: genel test (2026-09-25)

Araçlar: `tests/usta_bot.gd` (oyunu 1. günden insan hızında oynayan bot; her karede durum denetimi, gün gün ölçüm; `--gecikme 0.4/0.6/0.9`, `--up`, `--ilk`, `--iz`), `tests/fare_akisi.gd` (öğreticinin yolu gerçek fare olaylarıyla + klavye kısayolları).

Sonuç: ~70 bot günü + kaos + tüm testler: 0 betik hatası, 0 durum ihlali. Düzeltilen: öğretici "4 porsiyon" diyordu (tek tık sonrası), fare ipuçları DE/FR/ES/PT'de İngilizceydi, OKU_BENI'de Tab/Q yanlış anlatılmıştı (oyun içi yardım doğru: "tahta değiştir").

Bot ölçümleri (onay bekleyen tasarım konuları):

| Konu | Ölçüm |
| --- | --- |
| Gün sonu ani kapanış | Müşteri süre bitmeden 2 sn öncesine kadar gelir; süre dolunca sıradakiler sayılmadan kaybolur, yarım ürün boşa gider (her gün 1-2 müşteri) |
| Yer dolunca müşteri doğmaz | Gelme denemelerinin %45-50si, Tabela sonrası %70-75i sessizce düşer; Tabela (daha çok müşteri) Dükkânı Büyüt olmadan etkisiz, oyuncu kaçırdığını görmez |
| Kimse kızıp gitmez | 3 hızda ~70 günde kaçan müşteri yalnız elektrik kesintisi / ızgara sıkışması günlerinde |
| Izgara tek tahtayla | Tahtadaki dürüm patates beklerken pişen dürüm alınamaz, bekledikçe yanar (bot 9 gün kilitlendi; insan sarıp takas edebilir) |
| Her sabah stok sıfır | İlk günlerde hamlelerin %26-35'i hazırlık (stok doldurma, et, patates) |
| Bahis hedefleri | "Müşteri kaçırırsın" bahsi bedava kazanç; bahşiş hedefi (30+6·gün) orta/hızlı oyuncuda ulaşılamaz; ödül (200+34·gün) 2 günlük kazanç. **11. turda çözüldü:** hedefler oyuncunun son 3 gününe bağlandı |

Kullanıcının seçtiği 1 ve 2 yapıldı (`tests/kapanis_sira.gd`):

| Konu | Çözüm |
| --- | --- |
| Gün ani bitiyor | Son 15 sn yeni müşteri gelmez (`game_loop.SON_MUSTERI`). Süre dolunca "SON MÜŞTERİLER", saat 0:00 kırmızı yanıp söner; içerideki müşteriler servis edilene ya da sabrı tükenene kadar gün sürer (en fazla 45 sn, `KAPANIS_SINIR`). Geliştirici "GÜN BİT" beklemez |
| Yer yokken müşteri doğmuyordu | Camın önündeki yakın kaldırımda, kapı tarafında en fazla 3 kişilik sıra (sokak yayası olarak, kapıya dönük, başında sabır çubuğu). Yer açılınca sıranın ilki kapıdan (sağ kenar) girer; 10 sn (boya ile uzar) dolunca "YER YOK" deyip kaldırımdan uzaklaşır. Kaçan sayılmaz; gün sonunda "Kaçan müşteri" satırında "kapıdan dönen N" |

Ayrıca bulundu (henüz yapılmadı): birleşik sürümün yeni sipariş balonu müşteri konuşma satırlarını (`line`/`lineT`: bekleme, kızgın, eksik, aç misafir sözleri) hiç çizmiyor; yalnız eski balonda (`legacy_order_draw`) vardı.

## Onuncu tur (2026-09-27)

| Kullanıcı | Yapılan |
| --- | --- |
| "Müşteri kaçtı vs diye yazı çıkmasın ekrana" | Sıradan ayrılan müşteri için "YER YOK" yazısı ve sesi kaldırıldı (içeride sabrı biten müşteri zaten yazı çıkarmıyordu). Ayrılış yalnız görsel: sıranın arkasındaki kaldırım şeridine geçip sola yürür, camın dışına çıkınca silinir. Kapanışta ve lider gelince dağılan sıra da yazısız |
| "Camın dışında yakında müşteriler sıralansın" | Sıra bordürden camın dibine alındı (bisiklet / çöp kutusuyla aynı hiza), kapıya dönük ayakta bekler (adım ortasında donmuş kare yerine bacaklar bitişik, arada bir ağırlık değiştirir). Gelen, sıradakilerin arkasındaki şeritten yürüyüp yerine geçer; sıra ilerleyince bir adım öne yürür; yer açılınca ilk sıradaki kapıya yürür ve kapıda içeri girer (kapı sesi o an çalar, sıraya girerken çalmaz) |
| Dükkânı Büyüt son seviyesinde sıra görünmüyordu | 5. yerin müşterisi camın sağ ucunu örtüyordu; sıra tam doluyken gizliydi. Sıra artık son iki müşteri yerinin arasındaki, hiçbir yer düzeninde örtülmeyen boşlukta (`customer_system.sira_x`); oradaki sokak çöp kutusu orta bölmeye alındı (`street_draw.COP_X`, 236 → 170). Anlık görüntü referansında yalnız 5 sahnenin piksel özeti değişti (kutunun yeri), oyun durumu ve kayıt aynı |
| "Yer yoksa ayrılsınlar" | Kural aynı: sıra (3 kişi) doluyken gelen girmez; sıradaki 10 sn (boya ile uzar) bekler, yer açılmazsa gider; gün sonunda "kapıdan dönen N" |
| Lider gelince sıra içeri giriyordu | Lider gelince içeridekilerle birlikte kapıdaki sıra da dağılır (kapıdan dönen sayılmaz); lider varken boşalan yere kimse girmez |
| Sırada bekleyen aç misafir | "Aç bir misafir geldi…" duyurusu kapıda beklerken değil, içeri girince çıkar |

Durumlar: `sira` (bekliyor / yerine yürüyor), `sira_gir` (yeri ayrıldı, kapıya yürüyor; kapanış onu da bekler ya da gönderir), `sira_git` (sessizce gidiyor). Üçü de sokakta yaya olarak çizilir (`customer_system.sokakta`). Test: `tests/kapanis_sira.gd` (geliş şeridi, cam hizası, kapıya yürüyüp girme, yazısız ayrılış, kapanışta kapıya yürüyen, lider, 5 yerde görünürlük).

## On birinci tur (2026-11-10 → 2026-11-14): yayın öncesi tarama

Kullanıcının yönü: oyun **cozy olmayacak** — biraz zorlayıcı, süreye karşı yarış ("bir dürüm daha yetişir mi?"); hedef **önce mobil, sonra Steam**, kalite "gold+"; **büyük değişikliklerde önce danışılacak**. Bu tur kurallara dokunmadı; ekran/dil/cihaz taraması yapıldı, bulunan her kusur teste bağlandı. Başlıca bulgular ve düzeltmeler:

| Bulgu | Düzeltme |
| --- | --- |
| Şubeler penceresinde açıklama gelir yazısına biniyordu; Fransızca'da üst satırdaki iki yazı üst üste (8 şube açıkken) | Panel 392 → 432 px; açıklama `maxw` ile sığar; gelir yan yana sığmazsa kısa biçim ($1,62M) |
| Başarım bildirimi pencerelerin düğmesini ve alttaki ipucu satırını örtüyordu | Şubeler/Borç/Kişisel/Ev pencereleri açıkken bekler; ipucu satırının üstünde durur |
| Gün başı kartında hava/maç satırı karttan taşıyordu; KARLI GÜN okunmuyordu | Kart genişliği en uzun satıra göre; `maxw`; renk |
| Başarım rozetleri: HD simgeler 14×14 hücreden taşıyordu; Almanca "MEISTERSCHAFT" ilk rozete biniyordu | `rozet_ikon` hücreye kırpar / küçük simge; rozet sütunu en geniş grup etiketine göre kayar |
| Rekorlar: günlük kaçan ortalaması tam sayıya yuvarlanıyordu (29 günde 12 kaçan → "0"); etiket değere değiyordu | Tek ondalık ("0,4"); etiket `maxw` ile değerin soluna sığar |
| Telefon fişi başlığı Almanca/Fransızca'da fişten taşıyordu | KURIER / LIVREUR + `maxw` |
| Müfettiş bazı dükkân boylarında müşterinin üstüne biniyordu | `event_system.mufettis_x` (iki yer arası / boş yer) |
| Yeni Oyun tabelayı `null` bırakıyordu (Kişiselleştir "null" gösterdi) | İlk açılış varsayılanı (`varsayilan_tabela`) |
| Çöp kutusu etiketi gerçek işi söylemiyordu | Etiket `cop_eylemi()` ile aynı sırayı izler (Eldekini at / Yanmış dürümü at / Tezgâhtakini at / Çöpü boşalt) |
| Molada saat 0:00 görünüyordu | Kalan süre görünür |
| Demirkent'te kapıdaki sorgulanan müşteri eski yerini tutuyordu | Sorgudaki müşteri yer tutmaz |
| Sayı biçimi her dilde Türkçeydi ("$5.000.000" İngilizce'de, "5.00M") | Dile göre binlik/ondalık ayracı; yüzde işareti Türkçe'de önce, diğerlerinde sonra |
| Öğretici/ipuçları telefonda bile "Turşuya tıkla" diyordu | `localization.girdi`: fare "tıkla", dokunmatik "dokun", kol/klavye yalın söz; 6 dilde |
| Yardım/ayar penceresinde düğmeler kaydırma alanının içindeydi (kısa telefon ekranında görünmüyordu) | Düğmeler alt şeritte sabit |
| Yardım metni de/fr/es/pt'de İngilizce kalıyordu | 4 dile çevrildi |
| Ses panelinde etiket hoparlör çarpısına yapışıyordu; gece başlığı tabela yazısıyla karışıyordu; "DAYI x4" etiketini döner rayı kesiyordu; Rekorlar borç çubuğu yazısı okunmuyordu | Etiketler kaydırıldı; şerit koyulaştı; etiket ray çizildikten sonra çizilir; beyaz + gölge |
| Windows/Android/iOS dışa aktarma ayarları eski "0.2.0" sürümüyle çıkacaktı | Proje sürümü 0.7.2 (Android kodu 702); `cila` testi eşitliği kilitler |

**Süreye karşı yarış (küçük dokunuş, yalnız görsel):** son 10 saniyede ve kapanışta (saat 0:00 iken içerideki müşteriler bitirilirken) saat kutusundan her saniye dışa doğru kırmızı halka yayılır (`hud_draw.son_saniye_halkasi`). Süre, kural ve ses aynı. Zaten vardı: 20 sn altında kırmızı yanıp sönen saat, son 10 sn tik, son 5 sn uyarı sesi, "SON MÜŞTERİLER" yazısı.

**Yeni testler / araçlar**

- `tests/cila.gd`: yukarıdaki kusurların geri gelmemesi (12 madde: tabela varsayılanı, müfettiş konumu, çöp etiketi, `maxw`, sorgu, bildirim, fiş başlığı, rozet sütunu, rekor satırı, sayı biçimi, girdi sözü, sürüm eşitliği)
- `tests/ceviri_tarama.gd`: koddaki 78 (tr, en) çifti ve 501 oyun verisi metni 4 dilde çevrili mi
- `tests/yazi_tasma.gd`: 6 dilde ~7.400 yazı ölçülür (ekran, pencere, düğme, üst üste binme, çevrilmemiş harf); kasıtlı bozuk çeviriyle denendi
- `tests/kapanis_sira.gd` baştan yazıldı (kapıdaki sıra, yazısız ayrılma, kapanış, lider, yerleşim)
- `tests/cop_kutusu.gd` (çöp kutusu: dokun / sürükle / basılı tut; fare, dokunma, kumanda), `tests/gun_ici_kayit.gd` (gün içi anlık görüntü, 14 kontrol grubu), `tests/bahis_hedef.gd` (bahis hedefleri: son 3 gün ortalaması, tabanlar, kayıt/yükleme, "kaçırırsın" süzgeci)
- `tests/usta_bot.gd`: `--tam` (tüm geliştirmeler), `--sehir N`, `--tohum`
- `tools/ekran_senaryo.gd`: istenen ekranı istenen dilde / telefon boyunda PNG olarak kaydeder; `tools/snapshot_tabanini_guncelle.py`: anlık görüntü tabanını yalnız piksel farkı varsa (bilinçli yeni kayıt alanında `--kayit` ile kayıt referansını da) günceller
- [REHBER.md](REHBER.md): kısa yol haritası

**Ölçüm:** tam yükseltmeli oyun karesi (debug, llvmpipe) bu turdan önceki ağaç 10,21 ms, sonraki 10,17 ms (5'er ölçüm, fark −%0,4). Gün içi anlık görüntü (40. gün, tüm geliştirmeler, 7 müşteri): ~19 KB, yazma dahil ortalama 3,5 ms (20 ölçüm) ve 12 sn'de bir yazılır; 30 FPS kare bütçesinin (33 ms) çok altında. Bot taramaları (taze 24 gün, tam geliştirme, İstanbul/Berlin/Demirkent, kaos tohumu 7): betik hatası 0, kural ihlali 0.

**Kullanıcıya danışılıp yapılanlar** (kuralı değiştirdikleri için önce soruldu; kullanıcının seçimi → yapılan):

| Konu | Seçim | Yapılan |
| --- | --- | --- |
| Çöp kutusu | "Ayrı hedefler" | Kutuya dokunmak **hep çöpü boşaltır**; ürünü atmak için tutup kutuya sürükle (fare / dokunma). Kumanda ve klavyede "al" tuşunu 0,6 sn basılı tutmak tezgâhtakini atar. 10 px'ten kısa hareket, kutu dışında bırakma ve erken bırakma atmaz. Boş kovaya dokununca ipucu: "Ürünü atmak için çöp kutusuna sürükle". `event_system.f_trashClick / f_dropOnTrash`, `station_actions`; `tests/cop_kutusu.gd` |
| "Kapıdan dönen" | "Yalnız sıraya girip giden" | Sıra doluyken kapıdan dönen sayılmaz (tam geliştirmede günde 60–230 görünmeyen "kayıp" yazıyordu). Sayılanlar: sırada bekleyip sabrı biten ya da kapanışta dağılan müşteri; lider gelince dağılan sıra yine sayılmaz. `customer_system`; `tests/kapanis_sira.gd` |
| Rakip bahisleri | "Hedefler son 3 güne göre" | Hedef = oyuncunun **son 3 gündeki ortalamasının %110'u**; kazanç/ceza miktarı aynı (200 + 34·gün). Dürüm 1, para 10, bahşiş 5'lik adıma yuvarlanır; en düşük hedef 4 dürüm / $100 / $10. Gün sonunda `rival_system.f_bahisGunuKaydet` günün sayılarını `G.bahisGecmis`'e yazar (ilerleme kaydında saklanır, Yeni Oyun siler). Geçmiş yoksa (yeni oyun, eski kayıt) eski gün formülleri geçerli. "Müşteri kaçırırsın" bahsi, son günlerde hiç müşteri kaçmadıysa (bedava para olurdu) diğer üç türden birine eşit şansla kayar (aynı rastgele sayının kesirli kısmıyla seçilir, yeni rastgele sayı tüketmez). `tests/bahis_hedef.gd` |
| Mobil: gün içi kayıt | "Gün içini de kaydet" | Oyun sürerken her 12 sn'de, arka plana alırken ve ana menüye dönerken gün içi anlık görüntü ayrı bir anahtara (`doner_efsanesi_v1_gunici`) yazılır. Uygulama işletim sistemince kapatılırsa Devam Et günü **molada, kalınan yerden** açar (para, süre, müşteriler, tahtadaki ürün, izgara, el, telefon siparişi; sipariş sahibi aynı müşteri nesnesidir). Gün bitince, Yeni Oyun'da, öğreticide silinir; bozuk, başka güne ya da eski sürüme ait kayıt yok sayılır. İlerleme kaydı şeması değişmez. `save_system.gunici_*`; `tests/gun_ici_kayit.gd` |

**Hâlâ açık (insan oyuncu testi gerekir; sayı ayarı yapılmadı):**

1. Bot hızında hiç müşteri kaçmıyor (sabır dişsiz): "bir dürüm daha yetişir mi" gerilimi şimdilik süreden ve sıra sınırından geliyor; sabır / yoğunluk ayarı gerçek oyuncuyla denenmeli. (Bahsin "müşteri kaçırırsın" türü de bu yüzden yalnız müşteri kaçmış oyuncuya çıkar.)
2. Tek tahta + dolu ızgara sıkışması: tahtadaki dürüm patates beklerken pişen dürüm alınamıyor, bekledikçe yanıyor; insan sarıp takas edebilir, kural olarak bırakıldı.

## On ikinci tur (2026-11-15): görsel geri bildirimi

Kullanıcı: "görsel anlamda yetersiz; fritöze patates atıyorsun, patates her şeyin layer olarak önünde kalıyor; smooth güzel bir oyun değil." Gönderdiği ekran görüntüsü 1. günü **HD kapalı (eski çizim)** kipinde gösteriyordu (gri fritöz, çizgili döner, gürültülü duvar); benim görüntülerim HD açıktı ve 22. gündü, bu yüzden "aynı oyun değil" dedi.

| Bulgu | Düzeltme |
| --- | --- |
| Eski çizimde (HD kapalı) kızaran/pişmiş patates çubukları yağ penceresinin dışına taşıp fritözün çerçevesini ve kapağını ortuyordu (`counter_design.f_drawFryer`) | Çubuklar yalnız yağ penceresinin içine kırpılır (`j_ctx.clip`); aynı kırpma HD tezgâhın yedek yoluna da eklendi. `tests/fritoz_katman.gd` eski kodda 42 taşan piksel yakalar |
| **Asıl neden (kullanıcıda HD kapalıydı):** proje Godot'ta hiç içe aktarılmamıştı (taze ZIP); `Oyna.cmd` oyunu doğrudan açınca HD dokuları yüklenemiyor, oyun sessizce eski çizime düşüyor (721 script hatası). Temiz klasörde doğrulandı: içe aktarma yok → HD kapalı, var → açık | `Oyna.cmd` her açılışta önce `--headless --path . --import` çalıştırır; `hd_acik` = istek VE dokular (`remake_gorsel._dokular_var`): dokular yoksa HD tek merkezden kapalı, konsola bir kez uyarı, debug'da ekranda neden; yüklenemeyen sprite sayfası/zemin dokusu script hatası vermez (`tests/ice_aktarma.gd`) |
| Oyuncu F2 ile (ya da bir arızayla) sessizce eski çizime düşebiliyordu | F2 yalnız debug derlemesinde; debug'da HD kapalıyken üst ortada kırmızı etiket nedenini yazar (`remake_gorsel.hd_durum_metni`, `interface_draw.hd_uyari`) |

Burada açık kalan iki akıcılık işi (uçan patatesin düz disk görünmesi, "fritöze koy"un anlık geçmesi) ve kullanıcının eklediği haptik, aşağıdaki **Akıcılık cilası** bölümünde kapandı. Hâlâ açık olan tek şey görsel dil seçimi (Yön A / Yön B): kullanıcı "görsel dile dokunma şimdilik" dedi, bu yüzden hiçbir sanat dosyası ya da çizim stili değiştirilmedi.

### Kayıp tarifler — "Baba'nın Defteri" (kullanıcı kararı: "kayıp tarifler olsun, sadece")

"Bir dürüm daha yetişir mi" döngüsüne uzun vadeli bir hedef: babanın defterinin kayıp sayfaları. Her sayfa, müşterinin **adıyla** istediği bir sipariş şablonudur (sos × istenmeyen malzeme × ek ürün). Yeni bir makine ya da tuş yok; mevcut hazırlık akışı aynen çalışır, yalnız doğru yapılınca daha çok ödenir.

| # | Tarif | Bulunduğu gün (gün sonu) | Gereken geliştirme | Çarpan | Menü bonusu |
| --- | --- | --- | --- | --- | --- |
| 1 | Baba'nın Acılısı | 3 | Sos Standı | ×1,6 | — |
| 2 | Annenin Sarımsaklısı | 8 | Sos Standı | ×1,6 | — |
| 3 | Turşusuz Sade | 14 | Malzeme Seçimi | ×1,7 | — |
| 4 | Yoğurtsuz Acı | 21 | Sos + Malzeme Seçimi | ×1,8 | — |
| 5 | Hafif Dürüm (sarımsaklı, patatessiz) | 30 | Sos + Malzeme Seçimi | ×1,8 | — |
| 6 | Efsane Menü (dürüm + patates porsiyon + ayran) | 42 | Sos + Patates Porsiyon + Ayran Kazanı | ×1,5 | +%20 |
| 7 | Çifte Sade (turşusuz + yoğurtsuz) | 56 | Sos + Malzeme Seçimi 2 | ×2,0 | — |
| 8 | Gece Menüsü (dürüm + porsiyon + ayran + tatlı) | 72 | Sos + Porsiyon + Ayran + Tatlı Tepsisi | ×1,6 | +%25 |

- **Bulma:** `session_system.f_endDay` → `tarif_system.f_sayfaBul`. Gün sonu ekranında "Yeni sayfa bulundu!" kartı çıkar; **TAMAM'a basılana kadar "DÜKKÂNA GİT" yok**. Eski kayıtla açılan oyun atlanan sayfaları ilk gün sonunda sırayla (kart ardına kart) alır.
- **Sipariş:** `recipe_system.f_makeOrder` sonunda `tarif_system.f_siparisKarisitir`: bulunmuş **ve ekipmanı olan** tariflerden biri, normal müşterinin dürümünü %14 olasılıkla adıyla ister (iskender tabağı olan ilk kalemde karışmaz). Menü tarifinde rastgele eklemeler yerine tarifin kendi kalemleri gelir. Ekipmanı olmayan tarif hiç istenmez ve bu durumda rastgele sayı **tüketilmez** (eski akışlar, testler, referans görüntüler değişmez). Balonda ve hazırlık şeridinde altın yıldız, kumanda etiketinde tarif adı.
- **Ödül:** doğru sos + doğru malzeme + tam kalite teslimde dürüm fiyatı × çarpan (`customer_system.f_deliver` → `tarif_system.f_odul`). Her tarifin kendi servis sayacı vardır: **5 / 15 / 40 serviste usta seviyesi, her seviye +%10**. Menü tarifleri tüm sipariş **kızdırmadan** bitince toplama bonus verir (`f_payCustomer`). Eksik / yanlış teslimde prim yok, mevcut indirim ve kızma kuralları aynen; evsiz misafir tarif istemez.
- **Arayüz:** dükkân çubuğunda (para yazısı ile BORÇ ÖDE arası) defter simgesi; ilk sayfa bulunana kadar yok, okunmamış sayfa varken kırmızı "!" . Panel: 8 sekme (numara + usta yıldızları, kilit), seçili sayfada ad, kalemler, Baba'nın notu, "Hazır / Gerekli: …", fiyat, servis, usta çubuğu; kilitli sayfada "Bulunacağı gün: N". Geri tuşu / kumanda paneli kapatır.
- **Kayıt:** `G.tarif = {bulunan, yeni, gorulen, servis}` ilerleme kaydında ve gün içi anlık görüntüde. Yükleme `tarif_system.f_yukle` ile ayıklanır: bilinmeyen / tekrarlı kimlik, bozuk tür, eksi sayaç atılır; eski kayıtta alan yoksa boş defter.
- **Veri:** `data/tarif.gd` (kimlik değişmez; gün, çarpan, gerekenler düzenlenebilir). **Kod:** `systems/events/tarif_system.gd`, `rendering/ui/tarif_draw.gd`. **Çeviri:** 8 ad + 8 not + 14 arayüz metni × 5 sözlük (30 girdi).
- **Test:** `tests/tarif.gd` (veri, sayfa bulma, ekipman, sipariş dağılımı, eşleşme, fiyat / usta / menü bonusu, kayıt-yükleme-bozuk kayıt, düğme / panel / kart tıklama akışı; kasıtlı bozmalarla doğrulandı); `tests/yazi_tasma.gd` defteri ve yeni sayfa kartını 6 dilde ölçer; ekran görüntüsü senaryoları: `tools/ekran_senaryo.gd --senaryo defter | yeni_sayfa | dukkan_defter | tarif_balon`.
- **Doğrulama:** tam test seti 41/41; usta bot: doğal ilerleme 14 gün (sayfalar 3 / 8 / 14. gün sonunda geldi, ilk tarifli sipariş Sos alınınca 13. günde, 5 servis) ve geç oyun 45-52. gün tam geliştirmeli (23 tarif servisi) — ikisinde de `IHLAL {}`, betik hatası yok; kaos turu defter paneli ve yeni sayfa kartını rastgele durumlara sokar.
- **Elle deneme (Windows, `Oyna.cmd`):** oyunda **T** (geliştirici paneli) → HEPSİ MAX → **GÜN +1** ile 3. güne gel → **GÜN BİT**: gün sonunda ilk sayfa kartı çıkar. Daha çok sayfa için GÜN +1'e basarak 8 / 14 / 21 … günlerine ilerle.
- **Sahne kuralı:** defter yalnız dükkânda açık kalabilir (`platform_game.advance`): gün sonuna / güne / mola geçilirse kapanır; geri tuşu da kapatır.
- **Ekonomi:** sipariş başına gelir ~%9-12 artar (hepsi bulunmuş, ustalıksız); tüm tarifler usta olunca ~%13-20. Ayrıntı: [ECONOMY.md](ECONOMY.md).


### Akıcılık cilası: uçan patates, "fritöze koy", haptik (kullanıcı: "devam et bunları yap, görsel dile dokunma şimdilik")

Üç iş de mevcut sanatı değiştirmeden **hareket ve geri bildirim** ekler. Oyun kuralları, süreler, ekonomi ve kayıt biçimi aynı; yeni çizimler mevcut sprite'larla yapıldı (yeni görsel dosya yok).

| Alan | Önce | Sonra |
| --- | --- | --- |
| Uçan patates (HD) | Çuvaldan tahtaya 6×4 pikselik düz bir elips uçuyordu; tahtadaki patatesle hiç benzemiyordu | Tahtadaki patatesin **aynı sprite'ı** (`patates_11`) uçar: yay üzerinde -7°'den 0°'ye döner, hafif büyür, iniş noktasında büyüyen gölge ve kısa iz bırakır; tahtaya inince alt kenarı sabit ezilir (0,2 sn) ve toz çıkar |
| "Fritöze koy" | Çubuklar tahtadan anında kaybolur, fritözde anında belirirdi | Çubuklar 0,30 sn'de tahtadan sepete uçar; inince yağ sıçrar, cızırtı çalar, sepetteki patates 0,14 sn'de belirginleşir. **Kızartma süresi tıkladığın andan sayılır, değişmedi** |
| Haptik | Yoktu | Her ses olayı kendi titreşim desenini de tetikler: telefonda titreşim, oyun kolunda motor; masaüstünde fareyle hiçbir şey. Ayarlardan kapatılır |

**Uçan patates.** Çizim `remake_gorsel.f_hdUcanPatates` (+ saf fonksiyonlar `ucan_aci`, `ucan_olcek`); GPU tarafında `GpuCanvas.texture_hd_donuk` (döndürülmüş / ölçeklenmiş dokulu dörtgen). Kanca adı `ucan_patates` (`HD_KAPALI=ucan_patates` ortam değişkeniyle tek başına kapanır); HD yoksa eski çizim yedeği de iyileştirildi (iniş noktasına büyüyen gölge, yuvarlanan elips). Bu çalışma gerçek bir hata da buldu: uçan patatesin varış noktası, tahtadaki patatesten 11 piksel solda ve yukarıdaydı (iniş anında sıçrama); `potato_system.f_inisNoktasi()` artık ikisinin tek kaynağı. İniş ezilmesi `G.cut.land` (0,2 sn'de söner), toz `f_burst` ile (rastgele sayı yalnız iniş anında tüketilir).

**Fritöze koy.** Mantık aynı: tıklayınca kızartma o an başlar (`t = 0`), süre ve yük sayısı değişmez, tahta stoğu hemen azalır, `basket` sesi tıklamada çalar. Görsel ayrı bir katmandır: `G.flyF` (`potato_system.FRITOZ_UCUS = 0,30`), çubuklar tahtadaki yığından (`f_cubukBaslangic`) sepete (`f_sepetNoktasi`) uçar; inince `f_fritozInis` 9 yağ damlası (sabit desen, **rastgele sayı tüketmez**) sıçratır, `sizzle` çalar ve `fryer.gir = 1` olur (0,14 sn'de 0'a iner, patates o sürede belirginleşir). Çubuklar uçarken sepet boş çizilir (HD, HD yedeği ve eski çizim üçünde de); çubuklar yağ penceresine kırpılıdır (önceki fritöz katman düzeltmesi korunur). `flyF` gün içi anlık görüntüde taşınır, yeni gün temizler.

**Haptik** (`scripts/core/haptics.gd`).

- **Tek bağlantı noktası:** `game_setup` SFX tablosunu kurunca `haptics.bagla(j_SFX)` her desenli sesi "önce titreşim, sonra eski ses" olacak biçimde sarar; oyun kodundaki yüzlerce `J.method(game.j_SFX, "ad")` çağrısı ve seslerin dönüş değeri aynen kalır. `DESEN` tablosu 38 sesi eşler: `ad → [[süre ms, genlik 0..1], ...]`, negatif süre boşluktur. Titreşimler olayın ağırlığına göre: arayüz / tutma 5-10 ms ve 0,12-0,3; teslim ve çan 14 ms; para `cash` çift vuruş; seviye atlama / fanfare üç vuruş yükselen; hatalı teslim `bad` ve uyarı `warn` çift sert vuruş; `fail`, `slam`, `fine`, `stamp`, `angry` uzun ve güçlü.
- **Bilerek sessiz:** ambiyans sesleri (yağmur, motor, korna, geçen araba, buhar, ayak sesi, kızartma döngüsü): sürekli titreşim yorucu olur ve pil yer.
- **Aygıt:** telefon / tablet (`OS.has_feature("mobile")` ya da dokunmatik kip) → `Input.vibrate_handheld(ms, genlik)` (en az 10 ms); oyun kolu seçiliyse `Input.start_joy_vibration` (zayıf motor = genlik × 0,5, güçlü motor = genlik, en az 40 ms); **fare / klavyede hiçbir şey yapılmaz** (masaüstü bilgisayarda titreşim yok).
- **Fırtına önleme:** aynı ses adı en çok 0,09 sn'de bir titretir; darbeler 25 ms arayla sıraya girer, 0,30 sn'den fazla geriye giden darbe atılır (gecikmiş titreşim olmaz); uygulama arka plana gidince bekleyenler iptal edilir (`sustur`). Zaman oyun zamanıdır (`platform_game.advance` → `tick`), saat okunmaz, rastgele sayı tüketilmez.
- **Ayar:** Mola → Yardım → Ekran ayarları → "Titreşim (telefon ve oyun kolu)" (varsayılan açık; açınca çift vuruşluk deneme darbesi verir). `user://device_settings.cfg` içinde `controls/haptics`. 5 sözlükte çevirisi var.
- **Android izni:** `export_presets.cfg` Android profiline `permissions/vibrate=true` eklendi. **Bu olmadan telefon titreşimi sessizce hiçbir şey yapmaz** (Godot `vibrate_handheld` bu izni ister); `tests/haptik.gd` izni kilitler.
- **Doğrulanmadı:** gerçek telefon, gerçek oyun kolu ve iOS cihazı yok. Darbe süreleri / genlikleri modern titreşim motorları (LRA) için akılla ayarlandı; eski motorlarda en kısa darbeler (5-8 ms) hissedilmeyebilir. Ayar tek tablodadır (`DESEN`), gerçek cihazda denenip değerler oradan değiştirilir.

**Testler.** `tests/ucan_patates.gd` (mantık: uçuş süresi, iniş, ezilme, kayıt, eski çizim yedeği), `tests/ucan_patates_visual.gd` (GPU pikselleri: gerçek sprite, dönüş, gölge, iz, iniş; açı / ölçek saf fonksiyonları ve doğrudan `texture_hd_donuk` en-boy oranı), `tests/fritoze_koy.gd` (mantık değişmedi: `t`, süre, yük, stok; uçuş 0,30 sn; `sizzle` bir kez; `gir` tek yönlü), `tests/fritoze_koy_visual.gd` (GPU: çubuklar yolda, uçarken sepet boş, inince belirginleşir, HD kapalı yedek), `tests/haptik.gd` (sahte arka uçla: aygıt yokken sessiz, sarmalayıcı sesi aynen çalıştırır, ambiyans sessiz, desen zamanlaması, hız sınırı, kuyruk tavanı, ayar kapalı, gerçek teslim akışında `serve` + `cash`, ayarın diske yazılıp okunması, arka plana gidince iptal, Android izni). Hepsi kasıtlı bozmalarla (süre, tavan, ayar, izin, açı, ölçek...) doğrulandı. Ekran görüntüsü senaryoları: `tools/ekran_senaryo.gd --senaryo patates_ucus | fritoze_koy` (`--adim N --say M`, `--eski 1` = eski çizim).

**Doğrulama:** tam test seti 46/46 (ayrıştırma + 36 mantık / ayar testi + 9 GPU görsel test) ve usta bot: doğal ilerleme 12 gün (`--tohum 7`) ile geç oyun 46-48. gün tam geliştirmeli, ikisinde de `IHLAL {}` ve betik hatası yok. **Elle deneme (Windows, `Oyna.cmd`):** oyunu aç, kesilmiş patatesi fritöze koy (çubuklar sepete uçar, yağ sıçrar); çuvaldan patates al (tahtaya dönerek iner). Titreşim yalnız telefonda / oyun kolunda hissedilir: kolu tak, oyunu aç, hatalı bir teslim yap (çift sert vuruş) ve Mola → Yardım → Ekran ayarları'ndan "Titreşim"i kapat / aç (açarken çift vuruş verir).

### Web (HTML5) sürümü (kullanıcı: "bunun web versiyonunu da yap, html oynanılabilir bir sayfaya gömdüreceğim, denemesi için")

Oyun artık tarayıcıda çalışır ve başka bir sayfaya `<iframe>` ile gömülür. **Oyun kodu, kurallar, ekonomi, kayıt biçimi ve sanat değişmedi**; yalnız tarayıcıya özgü üç küçük uyarlama ve bir derleme hattı eklendi. Ayrıntı ve komutlar: [PLATFORMLAR.md](PLATFORMLAR.md) → Web.

| Konu | Karar / sonuç |
| --- | --- |
| Çizim ve iş parçacığı | Proje zaten GL Compatibility kullanıyordu: WebGL 2 ile aynen çalışır (HD çizim dahil). Derleme **tek iş parçacıklı**: SharedArrayBuffer / COOP / COEP istemez, bu yüzden başka kökenli bir sayfanın iframe'ine özel sunucu ayarı olmadan gömülür |
| Çıktı | `exports/web` (+ `exports/babamin-donercisi-web.zip`, 14 MB): oyun, `embed-ornek.html`, `OKU-BENI.txt`, `web_sunucu.py`. Motor 38 MB (gzip ile ~10 MB), oyun verisi 5 MB |
| Açılış ekranı | Özel kabuk `web/kabuk.html`: Godot'un beyaz logo ekranı yerine oyunun renklerinde yükleme çubuğu, 6 dilde metin, WebGL 2 yoksa nedenini yazar, telefon dikeyken "yan çevir" önerisi |
| Telefon tarayıcısı | `OS.has_feature("mobile")` tarayıcıda hep false'tur, bu yüzden telefon tarayıcısı masaüstü gibi açılırdı. `scripts/web_ortam.gd` CSS `pointer: coarse` ile algılar → dokunmatik kip, büyük düğmeler, 30 FPS hedefi (masaüstü ve yerel mobil derlemede etkisiz) |
| Dil | Oyun ilk açılışta İngilizce açılıyordu. **Yalnız web'de:** kayıtlı seçim → `?dil=xx` adres parametresi (gömen sayfa seçer) → tarayıcı dili → İngilizce. Masaüstü davranışı aynı (testler ve görüntü referansları kayıtlı dile bağlı) |
| Kayıt | `user://` tarayıcıda IndexedDB'ye yazılır, adrese özeldir, sayfa yenilenince kalır (farklı kökenli iframe'de de denendi). Gizli sekme / site verisini engelleme kaydı kalıcı yapmaz |
| Ses ve titreşim | Ses ilk dokunuşta açılır (tarayıcı kuralı; `AudioContext` dokunuştan önce `suspended`, sonra `running`). Titreşim yalnız Vibration API olan tarayıcılarda (Android Chrome); iPhone Safari desteklemez |
| Şablonlar | Editörün şablon paketi 1,3 GB; web için iki küçük zip yeter. `tools/web_sablon_indir.py` yalnız onları HTTP Range ile çeker (~20 MB), Windows / macOS / Linux'ta doğru klasöre koyar |
| **Tek dosya** (kullanıcı: "direkt html olarak ver") | `exports/babamin-donercisi.html` (19 MB): motor + oyun verisi gzip + base64 ile HTML'in içine gömülür, `web/tek_dosya_yukleyici.js` Godot'un `fetch` ve `AudioWorklet.addModule` isteklerini gömülü veriden karşılar. Çift tıklamayla (`file://`), sunucuda ya da `<iframe>` ile açılır; sayfanın kendisi dışında ağ isteği yoktur. Üretici `tools/web_tek_dosya.py` (Godot'suz `--sina` kendi kendine sınaması var) |
| Düz http:// | **Açılmaz, bilerek:** Godot'un ses motoru güvenli bağlam ister (denendi: `audioWorklet` olmayan sayfada motor açılışta `TypeError` verip takılır). Godot'un denetimi korundu; kabuk nedenini 6 dilde yazar. HTTPS, localhost ve `file://` çalışır |
| Dışa aktarma klasörü | `exports/` içindeki PNG'leri Godot projeye ice aktarıyordu (`.import` dosyaları, önbellek kirliliği). `exports/.gdignore` eklendi (`.gitignore` yalnız onu izler) |

**Ölçüm** (`--olcum 300`, tam geliştirmeli dükkân + 3 müşteri, aynı sunucu CPU'su, yazılımsal GL): web release **16,9 ms** / kare, web debug 18,3 ms, yerel debug 11,0 ms; yani web ~1,5× yavaş. Gerçek GPU'lu masaüstünde 60 FPS beklenir; telefonda uygulama 30 FPS hedefine iner.

**Tek dosya doğrulaması:** gerçek Chromium'da `file://` (çift tıklama), `http://127.0.0.1`, başka kökenli `<iframe>`, `file://` içinde `<iframe>`, telefon emülasyonu (yatay + dikey); açılış ~2,8 sn (yerel disk); sayfa dışında ağ isteği yok; konsolda hata yok; dil seçimi sayfa yenilenince kaldı (`file://` ve iframe'de de IndexedDB çalışıyor). İki şey sınama sırasında bulunup düzeltildi: `file://` sayfalarında ses işleyicisi `blob:` adresiyle yüklenmiyor (`data:` adresine geçildi, `blob:` yedek) ve Godot'un açılıştaki ServiceWorker denetimi `file://`'da yakalanmamış hata veriyordu (yutuldu). Düz `http://` için motorun denetimini gevşetmeyi de denedim, ses motoru açılışta çöktüğü için geri aldım.

**Doğrulama:** tam test seti 47/47 (yeni `web_ortam` dahil; masaüstü davranışı değişmedi). `tools/web_dene.js` gerçek Chromium'da (yazılımsal WebGL 2) açılış, WebGL 2 + Compatibility, tek iş parçacığı, canvas'ın pencereyi doldurması, BAŞLA, konsolda hata yok (6/6; ZIP temiz klasöre açılıp kendi `web_sunucu.py`'si ile sunularak denendi). Ayrıca elle: Türkçe tarayıcı → Türkçe, `?dil=de` → Almanca; telefon emülasyonu (yatay: dokunmatik prolog; dikey: yan çevir önerisi); başka kökenli iframe + `allow="fullscreen"`; dil seçimi sayfa yenilenince kaldı (IndexedDB'de `records.json`). `tests/web_ortam.gd` yapılandırmayı kilitler (tek iş parçacıklı profil, GL Compatibility, kabuk yer tutucuları ve 6 dil, iframe izinleri; kasıtlı bozmalarla doğrulandı) ve tarayıcı yardımcılarının masaüstünde etkisiz olduğunu gösterir.

**Doğrulanmadı:** gerçek telefon, iPhone Safari (bellek sınırı), Firefox / Safari, gerçek GPU hızı, sesin kulakla duyulması, uzun oturum. Bunlar gömen sayfada ilk denemede görülmeli; sorun çıkarsa `?dil=` dışında hiçbir ayar gerekmediği için düzeltme oyun tarafında yapılır.

### Patates doğrama tahtası: daha geniş, düzenli, hiçbir geliştirmeyle üst üste binmeyen yerleşim (kullanıcı: "patates kesme tahtasını ve yerini daha düzgün yap, daha büyük olsun, biraz daha anlaşılabilir, geniş olsun ama diğer upgradeler geldiğinde vs üst üste binmesinler")

**Oyun kuralları, süreler, ekonomi, kayıt biçimi ve geliştirme ağacı değişmedi; yeni sanat dosyası yok** (çelik kap ve çiğ çubuk mevcut `tezgah` atlasından). Değişen: tahtanın dokunma alanı / boyu, iç yerleşimi ve onu kuşatan iki istasyonun (sos standı, kâğıt makinesi) yeri. Sorun şuydu: sağ-alt şerit (sos + kâğıt + tahta + kızarmış patates kutusu) piksel piksel doluydu; tahta 51 piksellik alana patates, satır ve çubuk yığınını sıkıştırıyordu ve **büyütmek için yer yoktu**. Her istasyonun alanı (`j_ST`) geliştirmelerden bağımsız **sabit** olduğundan (kilitli yer tutucular ve kâğıt yığını da hep kendi alanında çizilir), çözüm de sabit bir düzen: kimse tahtaya yaklaşamaz, hangi geliştirme gelirse gelsin.

| Alan (mantık piksel, 480×270) | Önce | Sonra |
| --- | --- | --- |
| Patates tahtası | x 336, **51** × 37 | x 326, **63** × 37 (HD'de 102 → 126 piksel) |
| Sos standı | x 288, **44** (şişe başına 14,7) | x 286, **38** (şişe başına 12,7; tıklama indisi aynı `w / 3` kuralı) |
| Kâğıt makinesi | x 308 | x 298 |
| Komşular arası boşluk | sos → tahta 4 px, tahta → kutu 4 px (büyütecek yer yoktu) | sos → tahta **2 px**, kâğıt → tahta 4 px, tahta → kutu **2 px**, fritöz → tahta 2 px, tahta alt kenarı 235 (tezgâh kenarı 236) |
| HD tahta çizimi | 102 piksellik tek sprite | iki uç 1:1, aradaki **düz** 1 piksellik sütun yatay uzatılır (`_kesme_tahtasi`); çizik / gölge uzamaz |
| Tahtanın içi | patates, satır ve çubuklar aynı küçük alanda; çubuklar sağda başıboş yığın (en çok 12); boş tahtada ne beklendiği belli değil | soldan sağa **üç bölge:** [patates + dilimler] [satır] [**çelik kap** + çiğ çubuklar (3 × 5'e kadar) + **sayaç**]; boş tahtada patatesin geleceği yerde **soluk iz** |

**Neden bu çözüm:** tahtayı 51'den 63'e çıkarmak için şeritte 12 piksel açmak gerekiyordu. Seçenekler: (a) tahtayı yukarı almak (fritözle çakışır), (b) kutuyu sağa itmek (tatlı rafı ve çöp kutusu sütunuyla çakışır), (c) bu çözüm: sos standını 6 piksel daraltıp (şişe sprite'ı 11 piksel; şişe başına ≥ 12 piksel bırakıldı) kâğıt makinesiyle birlikte sola almak, hazırlık tahtasıyla arası hâlâ 6 piksel (280 → 286). Daha cesur bir seçenek **uygulanmadı, kararını sana bırakıyorum:** sos standını (35 piksele sıkıştırılmış hâliyle) sol boşluğa (x 44-80) taşımak sütunu tamamen açar; tahta ~76-80 piksele çıkabilir. Bu, tezgâhın görsel düzenini değiştireceği için danışmadan yapmadım.

**Sabit noktalar (`systems/equipment/potato_system.gd`, `KESME_*`):** çizim, uçan patatesin iniş noktası (`f_inisNoktasi`), bıçak izlerinin yatay merkezi (`f_kesikX`) ve çubukların kalkış noktası (`f_cubukBaslangic` → `f_kapNoktasi`) **aynı sabitleri** kullanır; böylece tahta yeniden boyutlanırsa bunlar birbirinden kopmaz (uçan patates çalışmasında bulunan 11 piksellik iniş sapması tam böyle bir kopukluktu). `counter_design.f_drawCutBoard`'un eski (HD kapalı) yedeği değişmedi, tahta genişliğine kendiliğinden uyar; yalnız `f_kesikX` iki yolu ayırır.

**Boş tahta ipucu:** patates yokken tahtada patatesin geleceği yerde soluk bir patates izi çizilir (dil gerektirmez: "patates buraya"). Kanca adı `kesme_iz` (`HD_KAPALI=kesme_iz` ile tek başına kapanır; piksel ölçen `ucan_patates_visual` referansı izsiz almak için kapatır). Uçan patates yoldayken iz çizilmez.

**Testler (ikisi de kasıtlı bozmalarla doğrulandı).**

- `tests/tezgah_yerlesim.gd` (mantık; 23 istasyon): hiçbir iki istasyonun dokunma alanı üst üste binmez (tek bilinçli istisna: içecek makinesi + takılı ayran kazanı); hepsi oyun alanının içinde; tahta ≥ 60 × 36, fritözün altında, alt kenarı tezgâh kenarını aşmaz; sos / kâğıt / kutuyla arası ≥ 2 px; sos şişesi başına ≥ 12 px; **HD'de çizilen parçaların gerçek kutuları** (atlas ölçüleriyle: sos şişeleri, kâğıt makinesi ve yığını, kutu rafı, fritöz, ızgara) tahta sprite'ıyla kesişmez; iç yerleşim (patates, satır, çelik kap, çubuklar) tahtanın içinde ve birbirine binmez; tüm geliştirmeler açılınca da alanlar aynı. Bozma: tahta x=316 (sos + kâğıtla çakışır), sos standı 44, kâğıt x=308, tahta 51 px, tahta 4 px sağa (kutuya dayanır): **beşi de** yakalandı.
- `tests/patates_tahtasi_visual.gd` (GPU, **gerçek HD pikselleri**; oyun donuk, otomatik doğrayıcı / fritöz tahtayı değiştirmez): (1) tahta sprite'ı kutunun tamamını (126 piksel) kaplar; (2) **hiçbir geliştirme** (24 geliştirmenin her biri tek tek ve hepsi birden) tahtanın kutusuna tek piksel koymaz; (3) tahta (patates, dilim, çelik kap, sayaç, ilerleme çubuğu) kendi kutusunun dışına taşmaz; (4) dolu tahtada çelik kapta çubuklar çizilir; (5) aynı durum iki kez aynı pencere görüntüsünü verir. Bozma: genişletme çizilmezse (100 / 126), çelik kap kutunun dışına kayarsa (kutu dışında 166 × 48 fark), kutu rafı 6 piksel sola çizilirse (tahtanın içinde 36 piksel): **üçü de** yakalandı. Son sürümü 12 ardışık koşuda aynı ölçümleri verdi.
- Ölçüm penceresi **bilerek dardır** (HD x 560-960, y 300-540): döner (`shaders/sis.gdshader` motorun `TIME`'ını parıltı / titreme için kullanır) ve pencerenin dışındaki sokak sahnesi oyun durmuşken de kareler arasında değişir (aynı durumdaki iki karede bile ~170 bin piksel; döner tabanı y ≥ 315'e iner). Bu, testin ilk sürümünde **kendiliğinden** ve ara sıra bir "tahta dışına taştı" yanlış alarmı verdi; kaynağı bulunup pencere daraltıldı ve ölçümün kararlı olduğu ayrıca (`tekrar_fark == 0`) test edildi. Girdi de kapatıldı (xvfb'de pencere açılırken gelen ilk fare hareketi imleci oynatabilir).
- `tests/ucan_patates_visual.gd`: boş tahta izi için `kesme_iz` kancası kapatıldı ve sınır ölçümü yalnız ≥ 5 piksellik sütun / satırları sayacak biçimde sağlamlaştırıldı (tek tük toz pikselleri sınırı genişletiyordu).
- `tests/hepsi.sh`: ikisi de listeye eklendi; `module_snapshot` referansında **yalnız 5 sahnenin piksel özeti** bilinçle güncellendi (`new-game-intro`, `packed-wrap`, `prepared-order`, `title`, `upgraded-shop`; hepsi tezgâhı çizer; oyun durumu ve kayıt referansı aynı kaldı).

**Ekran görüntüleri:** `tools/ekran_senaryo.gd --senaryo patates_tahta [--durum bos|patates|kesim|dolu] [--seviye N]` (oyun donuk; `--seviye` verilmezse tüm geliştirmeler tam). Önce / sonra karşılaştırması seviye 0 ve tüm geliştirmelerle, boş / patatesli / kesim sırasında / 14 çiğ çubuklu durumlarda ve eski (HD kapalı) çizimle denendi: sos şişeleri, kâğıt makinesi ve kutu rafı tahtaya değmiyor, çelik kap ve sayaç tahtanın içinde.

**Doğrulama:** tam test seti 49/49 (ayrıştırma + 38 mantık / ayar testi + 10 GPU görsel test; yeni: `tezgah_yerlesim`, `patates_tahtasi_visual`) ve usta bot: doğal ilerleme 12 gün (`--tohum 7`) ile geç oyun 46-48. gün tam geliştirmeli Demirkent (`--tam --sehir 8 --ilk 46 --gun 3`), ikisinde de `IHLAL {}` ve betik hatası yok. **Elle deneme:** oyunu aç (`Oyna.cmd`), çuvaldan patates al (tahtanın solunda, soluk izin üstüne iner), kes (bıçak izleri patatesin üstünde, çubuklar sağdaki çelik kaba düşer, sayaç artar), fritöze koy (çubuklar çelik kaptan uçar). Sos standından sos seç: şişeler daha dar ama tıklama alanı aynı üç eşit parça.

**Doğrulanmadı:** gerçek telefon ekranında yeni boyun dokunma hissi (tahta ve sos şişeleri küçük ekranda daha büyük ya da daha küçük mü hissedilir); 20:9 telefon ve 4:3 tablet pencerelerinde yerleşim (dönüşüm oranı değişir, alanlar aynı oranda ölçeklenir, ayrıca görülmedi); sos şişesi başına 12,67 pikselin parmakla rahat basılıp basılmadığı (önce 14,67'ydi). Sorun çıkarsa sos standını sol boşluğa taşımak (yukarıdaki cesur seçenek) tek yer değişikliğidir.

### Patates kesme efekti: bütün patates havada asılı kalıp doğranır, dilimler havaya uçar (kullanıcı: "patatesi keserken patates havaya mı uçsun, böyle güzel kesilme efekti ve animasyonu vs olsa, göze güzel gelen" + "bütün patateste animasyon var mıydı, havaya uçsun, havada keselim")

**Salt görsel katman:** oyun kuralları, süreler (`cutTime` 3,2 → 0,7 sn), verim (`cutYield` 26 → 62 porsiyon), ekonomi, **rastgele sayı akışı** ve kayıt biçimi aynı; yeni sanat dosyası yok (mevcut `patates_dilim`, `kesme_kap`, `satir` parçaları). Efekt durumu `G`'de değil `potato_system`'in kendi alanlarında (`kd_*`) durur: gün içi kayda girmez, `module_snapshot` durum referansı dokunulmadan kaldı, hiçbir yerde oyunun rastgele üreticisi çağrılmaz (sabit desenler).

| An | Önce | Sonra |
| --- | --- | --- |
| **Bütün patates** | Çuvaldan tahtaya **uçuş** ve iniş ezilmesi vardı (uçan patates işi); doğranırken patates tahtada **yerinde duruyordu**, yalnız kısalıyordu | İlk bıçak vuruşu patatesi **havaya fırlatır** (~9 px); vuruşlar sürdükçe her vuruş küçük bir tekmedir ve patates **havada asılı kalıp** (6-9 px) hafifçe sallanır (vuruş yönüne göre eğilir), **altında gölge** kalır, bıçak ve bıçak izleri patatesin yüksekliğinde iner (yani gerçekten *havada* doğranır). Vuruşlar bitince (0,2 sn) iner ve ezilir |
| Bıçak vuruşu | Bıçak, gerçek vuruştan bağımsız sabit 0,2 sn'lik ayrı bir tempoda iniyordu (ses 0,17 sn'de bir, görüntü 0,2 sn'de bir: kayıyordu) | Bıçak **gerçek vuruşla aynı karede** iner (ses + bıçak + kırıntı + ezilme birlikte); patates vuruşta alt kenarı sabit kalıp ezilir (%14), yarım piksel yana sarsılır, toparlanır (0,2 sn) |
| Yeni dilim | Dilim, `floor(prog × 7)` artınca bir anda belirirdi | Dilim kesik yüzden **zıplar** (8-11 piksel yay, 0,24 sn, takla atarak), sıradaki yerine iner; havadayken yerinde çizilmez, hedef canlıdır (patates kısaldıkça kesik yüz kayar, dilim yine tam yerine oturur) |
| Patates bitince | Sayaç bir anda tam değere sıçrardı; çiğ çubuklar kapta aniden belirirdi | Yedi dilim kesik yüzün yanından **havaya fırlar** (13-18 piksel yay, 0,34 sn, 35 ms arayla, dönerek, iz bırakarak), bıçağın üstünden aşıp **çelik kaba yağar**; her iniş kabı sallar, parıltı çıkarır, **sayaç porsiyon porsiyon yukarı sayar** (0 → 40 gibi, her dilim ~ 1/7'sini ekler) |
| Kalkış | Tozlu 8 parçacık kabın yanında | Aynı parçacıklar + dilimlerin kalktığı yerde parıltı ve nişasta tozu |

**Havada doğrama (bütün patates).** Fizik yalnız görseldir: her vuruş `kd_pv = max(kd_pv, KD_KALDIR × (1 − yükseklik / KD_TAVAN))` (tekme yükseldikçe zayıflar: simülasyonda ilk fırlatma tepesi ~8,9 px, vuruş ritminde (0,17 sn) ~6-9 px'de asılı kalır), yerçekimi `KD_YER` = 520 px/sn², tavan 14 px; eğim yay + sönüm (`KD_SALLA`). Dokunma alanı (tahta dikdörtgeni), ilerleme ve süre **aynı**: kesim hâlâ fare tahtanın üstündeyken zamanla ilerler, patatesin havada olması bir şeyi değiştirmez. Bıçağın üst sınırı `y − 4`'te kesilir: yoksa havadaki patatesi izleyen bıçak fritözün sayaç ekranını (tahtanın 6-14 px üstü) kapatıyordu (ilk denemede görüldü, düzeltildi). Havadaki patatesin altındaki gölge yükseldikçe küçülür ve silikleşir; inerken `kd_inis` ezilmesi; eğik çizim için `texture_hd_donuk` (tam dururken ve dinlenmede eski `hd_ciz` yolu: **dinlenme görüntüsü birebir aynı**).

**Nasıl çalışır.** Üç olay `potato_system`'e bağlandı (`f_slashAt` → `f_kesimVurus`, tamamlanma → `f_kesimTamam(verim)`, her kare → `f_kesimEfektGuncelle(dt)`; `game_loop` oyun karesinde çağırır, yeni gün `f_kesimEfektTemizle`). Saf yardımcılar: `f_kesimEzilme` (0 → 1 → 0), `f_bicakFazi`, `f_dilimKonum` (yay + dönüş; zıplayan dilimde hedef canlı), `f_dilimHavada`, `f_sayacPorsiyon(raw)` (= `raw − yoldaki porsiyon`; çizimin sayacı ve çelik kaptaki çubuk sayısı bunu kullanır), `f_kapSallanma`; patates durumu `kd_py` / `kd_pv` / `kd_pa` / `kd_pw` / `kd_inis`. Güvenlikler: yükleme / yeni patateste **zıplama yok** (`kd_n = -1` ilk görüşte senkronlar); havadaki dilim tavanı 28 (güncelleme durup art arda bitse birikmez, atılan dilimin payı sayaçtan düşülür); yoldaki dilim kalmayınca sayaç tam (kayan nokta artığı yok); **dükkân ekranı** sahte durumla çizdiği için efekt yalnız oyunun kendi tahtasında (`is_same(state, j_G.cut)`).

**Çizim.** HD (`counter_design_hd.f_drawCutBoard`): `patates_dilim` sprite'ı `texture_hd_donuk` ile döner, yay üzerinde iri (kameraya yakın) başlar, kaba inerken küçülüp solar, iki silik iz bırakır; yarım piksele yuvarlanır. Eski (HD kapalı) çizim de aynı efekti piksel dilimlerle gösterir (`counter_design.f_drawCutBoard`; hedef çelik kap yerine tahtanın sağı, yedek olduğu için sade). **Kanca adı `kesme_efekt`** (`HD_KAPALI=kesme_efekt` çizimi, parıltı parçacıklarını ve bıçağın vuruşa bağlanmasını tek başına kapatır; eski sabit tempo geri gelir).

**Testler** (ikisi de kasıtlı bozmalarla doğrulandı).

- `tests/kesme_efekt.gd` (mantık): **saflık** (aynı betikli kesim oturumu efektli ve efektsiz oynanınca `G` durumu birebir aynı, kesim boyunca rastgele sayı akışı aynı, raw aynı); vuruş / ezilme eğrileri; **bütün patates** (ilk vuruş fırlatır, vuruşlar sürerken hiç tahtaya inmez ve 6-9 px'de asılı kalır, tavanı aşmaz, vuruşlar bitince iner, ezilir ve eğim dahil tamamen durur, patates yokken vuruş bir şey kaldırmaz, bitince havadaki patates gider ve kalan kısım havadaki yüksekliğinden kalkar); dilim zıplaması (yükleme ve yeni patateste yok, 14 karede hâlâ havada, 15'te inmiş, yere tam oturur, dik iner, yay yüksekliği); tamamlanma (7 dilim, `raw` tam `cutYield` kadar, sayaç monoton ve ara değerli, hepsi inince tam); yeni gün temizliği; tavan ve takılı kalmama; 4. kademe otomatik doğrayıcıda sınırlı kalma. Bozma: kancada rastgele sayı tüketmek, efektin `raw`'ı değiştirmesi, zıplama süresini yarıya indirmek, tavanı kaldırmak, sayacı sona sıçratmak, yükleme senkronunu kaldırmak, **tekmeyi kaldırmak, yerçekimini 5 katına çıkarmak, eğimin tam durmasını kaldırmak, bitişte havadaki patatesi sıfırlamamak**: **onu da** yakalandı. *Bulunan test zaafı:* rastgele sayı akışını oturum sonunda karşılaştırmak bozmayı gizliyordu (oyun akışı ~50 kare sonra kendiliğinden yeniden eşitliyor); artık kesim biter bitmez karşılaştırılır.
- `tests/kesme_efekt_visual.gd` (GPU, **gerçek pikseller**, HD ve eski çizimde ayrı ayrı; 53 kontrol): dinlenme karesi efektle / efektsiz aynı; ezilme dinlenmeden farklı ve tahtanın kutusunda; **havadaki patates**: dinlenme konumunun üstünde de çizilir, dinlenmedeki **alt kısmı boşalır** (yani gerçekten yukarı çıkmış, yalnız eğilmemiş), altında gölge var, bıçak havadaki patatesin yüksekliğinde iner, inip durunca kare dinlenmeye birebir döner; zıplayan dilim **havadaki konumunda çizilir** ve **tahtadaki yeri boş kalır**; yere inince ve bitince kare dinlenme karesine **birebir** döner (tek piksel artık yok: dilim, sayaç, kap); havaya fırlayan dilimler konumlarında çizilir ve tahtanın üst yarısına kadar yükselir; kanca kapalıyken aktif efekt durumu bile görünmez; aynı durum aynı görüntü. Bozma: yoldaki dilimi yerinde de çizmek, sayacı kaydırmak, kancayı yok saymak, ezilmeyi çizmemek, havadaki dilimi çizmemek, eski çizimde dilimi çizmemek, **patatesi yükseltmeden çizmek, gölgeyi çizmemek, bıçağı patatesle birlikte yükseltmemek, eğimi sıfırlamamak**: **onu da** yakalandı (ikisi ilk sürümde kaçıyordu: havadaki dilimi hiç çizmemek ve patatesi yükseltmeden çizmek; "havadaki konumda çizilir" ve "alt kısmı boşalır" kontrolleri bu yüzden eklendi).
- `tests/hepsi.sh` ve `module_snapshot`: iki test listeye eklendi; piksel referansı **değişmedi** (efekt dinlenme görüntüsüne dokunmaz).

**Ekran görüntüsü / video karesi:** `tools/ekran_senaryo.gd --senaryo kesme_efekt [--seviye N] [--adim N] [--say N] [--fare 1]` (varsayılan: basılı fareyi taklit eder, imleç ve ipucu görüntüyü kapatmaz; `--fare 1` gerçek fare yolu; `--eski 1` eski çizim). 2. kademede 0,5 sn'lik bir bitişin kare kare dökümü incelendi (vuruş, zıplama, kalkış, uçuş, iniş, sayaç sayımı); 4. kademede (otomatik doğrayıcı + otomatik fritöz) efekt okunaklı kalıyor.

**Doğrulama:** tam test seti 51/51 (ayrıştırma + 39 mantık / ayar testi + 11 GPU görsel test; yeni: `kesme_efekt`, `kesme_efekt_visual`) ve usta bot: doğal ilerleme 12 gün (`--tohum 7`) ile geç oyun 46-48. gün tam geliştirmeli Demirkent (`--tam --sehir 8 --ilk 46 --gun 3`), ikisinde de `IHLAL {}` ve betik hatası yok; `module_snapshot` piksel referansı **değişmedi** (efekt dinlenme görüntüsüne dokunmaz). **Elle deneme:** oyunu aç (`Oyna.cmd`), çuvaldan patates al, tahtada basılı tutarak kes: bıçak sesle aynı anda iner, patates ezilir, dilimler zıplayıp sıraya iner; patates bitince dilimler havaya fırlayıp çelik kaba yağar, sayaç yukarı sayar. Fritöze koy: çubuklar kaptan fritöze uçar (önceki iş, değişmedi).

**Doğrulanmadı:** gerçek telefon / dokunmatik ekranda hissi (hızlı art arda vuruşta dilimler üst üste biner; 0,7 sn'lik 4. kademede yoğun ama okunaklı); **ses eşlemesi yok** (iniş için yeni ses eklenmedi: mevcut `potato` / `drop` sesleri aynen), istenirse iniş başına yumuşak bir "tık" eklenebilir (haptik tablosuna da işlenmeli); uzun oturumda performans (efekt yalnız bir avuç sprite çizer, ölçülmedi).

### Genel animasyon / görünüm taraması: panel ve mola geçişleri ile reddedilen işlem geri bildirimi (kullanıcı: "genel olarak animasyon ve görüntüde eksik olan şeyleri bul ve düzelt, daha iyi animasyon ve göze güzel görünme yap")

**Tarama.** Oyunun ekranları, istasyonları ve geçişleri tek tek gözden geçirildi; ayrıca bir **geçiş sınayıcı** yazıldı (gerçek oyunu GPU'da sürer, bir arayüz durumu değişince **değişimin ne kadarının ilk karede göründüğünü** ölçer: %100 = sert kesme, %0 = tam yumuşak). Oyun zaten yoğun animasyonlu (para uçuşu, müşteri nefesi / göz kırpma, fritöz kabarcıkları, gün sonu / gazete / kepenk sahneleri, uçan patates, kesme efekti...); **gerçek eksik** iki yerde bulundu:

1. **Mola menüsü ve bütün paneller sert kesmeyle açılıp kapanıyordu** (SES, REKOR, BAŞARIM, şubeler, kişiselleştirme, borç ödeme; değişimin %94-100'ü ilk karede görünüyordu).
2. **Oyunun reddettiği işlemlerde** (tezgâh dolu, lavaş yok, et yetmiyor, fritöz kapalı...) yalnız `bad` sesi + alttaki yazı vardı; **nerede ve neden reddedildiği** gözden kaçıyordu (koddaki ~100 `bad` çağrısının 67'si yazıyla birlikte).

Bilerek dokunulmayanlar: eldeki / sürüklenen ürünün imleci rijit izlemesi (yumuşatmak ürünün elde nerede olduğunu bulanıklaştırır ve kontrol hissini bozar, hızlı oyunda risk), depo çekmecesi (zaten kısmen animasyonlu), gün sonu (zaten kademeli ve yumuşak), global vinyet / ışık (görsel dil kararı bekliyor: "görsel dile dokunma şimdilik").

**Salt görsel katman:** oyun kuralları, süreler, ekonomi, **rastgele sayı akışı**, kayıt biçimi ve **girdi** (düğme / tıklama dikdörtgenleri, hedefler) aynı; yeni sanat dosyası yok. Durum `G`'de değil iki modülün kendi alanlarında durur (kayda girmez). Her ikisinin de **kanca adı** var (`HD_KAPALI=panel_gecis,ret_fx` eski davranışı geri getirir) ve **dinlenme görüntüsü eskiyle birebir aynı** (testle kilitli).

| Geçiş | İlk karede görünen değişim: açılış (Önce → Sonra) | Kapanış (Önce → Sonra) |
| --- | --- | --- |
| Mola menüsü | %96 → **%12** | %95 → %25 |
| Mola → SES paneli | %100 → **%3** | %98 → %36 |
| Mola → REKOR paneli | %100 → **%0** | %99 → %67 |
| Mola → BAŞARIM paneli | %100 → **%2** | %98 → %66 |
| Dükkân → ŞUBELER | %100 → **%22** | %94 → %18 |
| Dükkân → KİŞİSELLEŞTİR | %99 → **%0** | %99 → %10 |
| Dükkân → BORÇ ÖDE | %98 → **%0** | %98 → %15 |
| Dükkân → REKORLAR | %99 → **%1** | %99 → %22 |

(Ölçüm `+4. karede` açılışın ~%70'ini, `+8. karede` ~%92'sini gösterir: panel 0,2 sn'de yerine oturur.)

**1. Panel / mola geçişleri — `rendering/ui/modal_fx.gd`.** (a) **Karartma** (panelin arkasındaki koyulaştırma): her panel kendi `f_fr(0, 0, W, H)` satırını çiziyordu (mola 0,62; ses / şube / başarım 0,84; rekor / defter 0,82; kişiselleştirme 0,8; başlık tabanı 0,52); hepsi artık `modal_fx.f_dim(alfa, renk)` üzerinden çizilir. Görünen opaklık hedefe **sabit sürede yumuşak** varır (açılış 0,16 sn, sönme 0,12 sn, ease-out); **paneller arası geçişte eski değerden yenisine** gider (mola 0,62 → SES 0,84: arada parlak kare **yok**, test: asla 0,62'nin altına düşmez); kapanışta `f_son()` karartmayı soldurur. Sahne değişince (mola ↔ oyun hariç) karartma sıfırlanır ve ilk çizim anlık oturur (başlık ekranı açılırken fade yapmaz). (b) **Panel gövdesi** (`f_basla` ... `f_bitir`): açılışta **ustten 14 px süzülüp** (ease-out-back: hafif asma, ≤2 px) ve **beliriverir** (0,15 → 1 opaklık, 0,12 sn). Yalnız **öteleme** kullanılır (HD parçalar, yazı, düğmeler tek parça kayar; ölçek yok → HD / eski çizim karışması yok), kayma **tam sayı px**; yalnız **çizim** kayar: tıklama / hedef dikdörtgenleri değişmez, yani girdi hemen son konumundadır (test: `izle` listesi geçiş sırasında dinlenmeyle birebir). Belirme, `GpuCanvas.grup_basla(a)` / `grup_bitir()` ile paneli kendi çizim öğelerine koyup **öğenin modulate'ini** düşürür (panel içindeki kodlar `globalAlpha`'yı sık sık 1'e geri yazdığı için onunla yapılamıyordu); opaklık 1 iken hiçbir şey yapılmaz (çizim birebir aynı), sonraki karenin `begin_frame`'i modulate'i sıfırlar. Panel kimliği değişince (mola → ses) ya da panel ≥2 kare çizilmeyip yeniden açılınca giriş baştan başlar; aynı karede iki kez çizilen panel (başlıkta `f_drawTitle` + `f_drawTitleBasarim`) tek karelik ilerler. **Bağlantılar:** gerçek mola menüsü `platform_game.f_drawPause`'dur (`interface_draw.f_drawPause` taban sürümdür, ikisi de bağlandı), panel işlevleri `settings_draw` / `branch_draw` / `achievement_draw` / `tarif_draw`, başlık tabanı `title_draw.f_drawTitle`, kare başı / sonu `core/game_loop.f_frame`. **Bilinen sınır:** panelin KENDİSİ kapanırken hâlâ anında kaybolur (karartma ve alttaki panel yumuşak; kapanış tablodaki %60'lar bundan): kapanan panelin hayalini soldurmak için panelin son karesini saklamak gerekirdi, bu da çizim öğesi sırasına dokunur (risk / kazanç dengesi kötü). Çıkış hızlı olmalı: kabul edildi.

**2. Reddedilen işlem geri bildirimi — `rendering/ui/ret_fx.gd`.** Oyun işlemi reddederken (`bad` sesi + `f_say(...)` uyarı yazısı) artık (a) işlem noktasının **11 px üstünde kırmızı ✕ belirir** (mevcut HD `carpi` simgesi + koyu kontur; yatay sallanıp 6 px yükselerek 0,55 sn'de solar), (b) alttaki **uyarı yazısı iki yana sallanır** (0,32 sn, ±3 px, "hayır" hareketi). Tetik, **`bad` sesi ile `f_say`'in aynı karede çağrılması** (iki sırayla da; işlemi reddeden 67 satır böyle yazılmış) ve yalnız oyun sahnesinde: **ferman cezası, kedi, lider gibi OLAY cezaları `f_say` çağırmadığı için tetiklemez** (imlecin altında anlamsız ✕ çıkmasın). Yazı göstermeyen 6 ret satırı (`assembly_system` ×3, `drink_system`, `paper_system`, `stock_system`) `game.ret_fx.f_ret()` ile yalnız ✕ çıkarır. Konum `j_IN` (fare / dokunma; kol / klavyede `stations.select()` imleci seçili istasyona taşıdığı için de doğru), ekrana kırpılır. **Tekrar sınırı:** sallanma sürerken (0,25 sn) yeni tetik yok sayılır (basılı tutulan / peş peşe reddedilen işlem ✕'i yerinde dondurmaz). Ses AYNEN çalışır (sarmalayıcı eski sesi çağırır, dönüş değeri korunur; haptik sarmalayıcısıyla aynı kalıp).

**Testler (4 yeni; tam set 55 → hepsi geçti):**
- `tests/modal_fx.gd` (mantık, 50 kontrol): **saflık** (aynı betikli mola / panel oturumu geçişli ve geçişsiz oynanınca `G` ve rastgele sayı birebir aynı; her oturum yepyeni oyunla: trafik / sokak sayaçları önceki koşudan artık taşımaz) ve modül çağrıları rastgele sayı çekmez; mola karartması 0'dan artar, ilk kare hedefin yarısından az, `DIM_ACIL` içinde **tam 0,62**; mola ↔ ses karartması **asla 0,62'nin altına düşmez**; kapanış monoton söner ve **tam 0**; başlık tabanı ilk karede anlık, panel açılınca 0,52 → 0,84; sahne değişimi (mola → başlık anlık; giriş / gün sonu karartma sızdırmaz); panel girişi ilk karede -14 px, tam sayı adım, asma ≤2 px, tam 0'a oturur, `save` / `restore` dengeli; `izle` dikdörtgenleri geçişte dinlenmeyle aynı; kanca (`kapali_zorla` ve `HD_KAPALI=panel_gecis`); tick yokken her şey anlık; iç içe `f_basla`; aynı panelin ara panelsiz kapanıp açılması; **dinlenme pikselleri** kanca kapalıyla birebir.
- `tests/modal_fx_visual.gd` (GPU, **gerçek pikseller**, 32 kontrol): 9 panelin (mola, ses, rekor, başarım, başlık+başarım, şube, kişiselleştirme, borç, defter) **dinlenme karesi kanca kapalı (eski sert kesme) kareyle birebir** (karartma + HD parçalar + yazı + düğmeler); panel girişi pikselleri dinlenmeye azalan farkla yaklaşır ve **gerçekten solukken başlar** (parlaklık testi); asma evresinde panel dinlenme karesinin **2 HD piksel aşağı kaymışı ile aynı** (HD parçalar tek parça kayar); geçiş karesinden sonra iz yok; karartma artarken sahne parlaklığı tek yönlü azalır; **`GpuCanvas.grup_basla` ilkeli**: grup içi %30, grup dışı tam, **sonraki karede aynı çizim öğesine sızmaz**.
- `tests/ret_fx.gd` (mantık, 35 kontrol): `bad` + `f_say` iki sırayla tetikler, ✕ imlecin 11 px üstünde ve ekrana sığar (köşelerde); yalnız `bad`, yalnız `f_say`, farklı karelerdeki ikisi, mola sahnesi **tetiklemez**; **gerçek akışlar** ("Önce lavaş al", "Tezgâh dolu", doluyor olan musluğa tekrar basmak = yazısız ret → yalnız ✕); başarılı eylem tetiklemez; **ferman ihlali tetiklemez**; ömür, tekrar sınırı; **saflık** (G, rastgele sayı ve ses çağrıları aynı; tetik ve çizim rastgele sayı çekmez); kanca; sarmalayıcı eski sesi aynen çalıştırır; ✕ CPU tuvalinde çizilir, ömrü bitince kare tetiklenmemişle **birebir** aynı.
- `tests/ret_fx_visual.gd` (GPU, HD ve eski çizimde ayrı ayrı; 35 kontrol): ✕ küçük bir kutuda, imlecin üstünde, **kırmızı**, yükselir, soluklaşır, yatay sallanır, farkı yalnız kendi kutusunda; ömrü bitince iz yok; **toast desen kadar yana kayar (HD'de tam 2 × dx piksel, boyut aynı)**, yalnız toast kutusu değişir, toast kayarken ✕ **kaymaz**; kanca ikisini de kapatır; aynı durum aynı görüntü.

**Bozma denemeleri (yalıtılmış kopyalarda, 26 bozma; hepsi yakalandı):** karartmayı anlık yapmak, dinlenme değerini 0,97 yapmak, `restore`'u kaldırmak, **modulate sıfırlamayı kaldırmak, kaymayı ters yönlü yapmak**, sönmeyi kaldırmak, başlık tabanını eski satırlara döndürmek, **sahne değişiminde anlık oturmayı kaldırmak, ara panelsiz yeniden açılışı yok saymak**, belirmeyi kaldırmak, karartmayı ilerleyen değerle çizmemek, çift çizimde ilerlemeyi iki saymak; `bad` yerine her şeyde tetiklemek, `f_say` bağını kaldırmak, **✕ konumunu imleç hizasına almak**, ✕'i çizmemek, tekrar sınırını kaldırmak, kancayı yok saymak, sarmalayıcının eski sesi çağırmamasını, kırpmayı kaldırmak, tick'i bağlamamak, yazısız ret satırını silmek, **tetikte rastgele sayı çekmek**, toast kaymasını geri almamak, ✕'in rengini bozmak, ✕ çizim satırını silmek: hepsi ilgili testte kaldı. *Bulunan test zaafları (üçü ilk sürümde kaçıyordu, düzeltildi):* (1) **modulate sıfırlamayı kaldırmak** geçti: panelden sonra aynı çizim öğesini kullanan bir şey yoktu → `GpuCanvas.grup_basla` için doğrudan ilkel testi eklendi (ikinci karede aynı öğe yeniden kullanılır); (2) **ara panelsiz yeniden açılışı yok saymak** geçti: mola menüsü araya hep başka bir panel koyduğundan kare boşluğu kontrolü hiç devreye girmiyordu → modüle doğrudan ayrı test; (3) **✕'in imleç üstü ofsetini 0 yapmak** geçti: test sabiti kendisinden okuyordu (totoloji) → bağımsız 11 px beklenen değer; ayrıca bir test başarısızken `dx[-1]` ile çöküyordu (çıkış kodu 0 kalıyordu) → korumalı. Eşdeğer bozma: `f_son`'daki "yalnız oyun / dükkân sahnesinde sön" koruması `f_tick`'in sahne değişiminde zaten yaptığı sıfırlamayla aynı sonucu veriyordu → koddan silindi.

**Elle denemek için:** oyunda `Esc` / mola düğmesi: ekran ışığı kısılırken menü yukarıdan süzülüp belirir; "SES AYARLARI" / "REKOR" / "BAŞARIM": panel değişirken ekran parlamaz, yeni panel yumuşakça gelir; dükkânda ŞUBELER / KİŞİSELLEŞTİR / BORÇ ÖDE / REKORLAR aynı şekilde; devam edince ışık yumuşakça açılır. Tezgâhı doluyken lavaş almaya ya da lavaşsız et eklemeye çalış: imlecin üstünde kırmızı ✕ çıkar, alttaki yazı iki yana sallanır.

**Doğrulama:** tam test seti 55/55 (ayrıştırma + 41 mantık / ayar testi + 13 GPU görsel test; yeni: `modal_fx`, `modal_fx_visual`, `ret_fx`, `ret_fx_visual`). İlk koşuda 54/55'ti: `module_snapshot` üç durumda (`prepared-order`, `packed-wrap`, `upgraded-shop`) piksel farkı verdi, çünkü betikli akışlar fazla malzeme ekleyerek reddedilen işlem üretiyor ve ✕ / toast kayması reddin hemen ardından çekilen karelerde görünüyor (beklenen, istenen görsel). Neden `ret_fx` olduğu **ölçüldü**: `HD_KAPALI=ret_fx` ile 6/6 birebir, `panel_gecis` o karelere hiç dokunmuyor. Referans 0.5.4 modül eşdeğerliğini ölçtüğü için test `ret_fx`'i kapalı alır (`tests/module_snapshot.gd`), **referans dosyası değişmedi**; ✕ / toast kendi testlerinde. Usta bot: doğal ilerleme 12 gün (`--tohum 7`) ve geç oyun 46-48. gün tam geliştirmeli Demirkent (`--tam --sehir 8 --ilk 46 --gun 3`), ikisinde de `IHLAL {}` ve betik hatası yok. **Tarayıcıda (tek dosyalık HTML, gerçek Chromium / WebGL 2):** açılış denemesi 8/8; Playwright videosundan: mola açılırken karartma ve panel kare kare belirir, SES / REKOR panelleri düşerek gelir, REKOR kapanıp mola geri gelirken panel yumuşakça belirir, devam edince ekran ışığı yumuşakça açılır, konsol hatası yok (GL Compatibility'de `canvas_item_set_modulate` ile panel belirmesi de çalışıyor).

**Ekran görüntüsü / video karesi:** `tools/ekran_senaryo.gd --senaryo panel_gecis --panel mola|ses|rekor|basarim|sube|kisisel|borc [--say N] [--adim N]` (panel açılış geçişi kare kare) ve `--senaryo ret [--x N --y N --say N]` (reddedilen işlem); eski hal için `HD_KAPALI=panel_gecis` / `HD_KAPALI=ret_fx` ile aynı komut. Önce / sonra kare dizileri (yan yana GIF + kontak şeridi) bu iki kancayla çekildi.

**Doğrulanmadı:** gerçek telefon / dokunmatik ekranda hissi (parmak ✕'in üstünü kapatmasın diye 11 px yukarıda çıkıyor; küçük ekranda ✕ ufak kalabilir: mevcut HD `carpi` simgesi büyütülmedi); **kol / klavye kipinde ✕ konumu** (kodla doğrulandı: `stations.select()` imleci seçili istasyonun merkezine taşıyor ve ✕ `j_IN`'den okunuyor; oyunda kolla denenmedi); süzülme sırasında kol ile gezinirken odak halkası (kol kipinde imleç / vurgu düğmenin kendisi olduğundan düğmeyle birlikte kayar, ama yalnız gözle değil bu ortamda ölçülmedi); **panelin kendisinin kapanışı hâlâ anlık** (yukarıda).

### Tempo güncel kodla yeniden ölçüldü (kullanıcı: "tempoyu güncel kodla yeniden ölç")

`tests/tempo.gd` yeniden koşturuldu (`--gun 200 --hirsiz`) ve yeni bir `--gunluk` seçeneği eklendi (elle kazanç / şube geliri / kasa gün gün, şube performans çarpanı eğrisi). Sonuç: tempo 8. tur ölçümüyle **±1 gün aynı** (borç bitişi en ucuz alımda 99 / 87 / 78, şubeye biriktirirken 86 / 80 / 72. gün); asıl yeni bulgu gelirin yapısı: elle kazanç 30. günden sonra ~$10 bin/gün'de tavan yapıyor, şube geliri 50. günde %64, 60. günde %90, 80. günden sonra %99 pay alıyor; şube çarpanı gelenlerin %35'ine yetişince doyuyor. Ayrıntı ve tablo: [ECONOMY.md](ECONOMY.md) "12. tur: tempo güncel kodla yeniden ölçüldü". Oyun kodu değişmedi (yalnız ölçüm aracı ve belge).

## On üçüncü tur (2026-11-21): mekanik ve hikâye derinliği

Kullanıcı: "önerdiğin şeyleri uygula" — önceki turdaki dürüst eleştirinin dört maddesi: **icra gerçek bir mekanik olsun**, **geç oyunda beceri geri gelsin ve para sinki olsun**, **her şehrin metnindeki vaat bir kural olsun**, **hikâye yayılsın ve epilog Demirkent seçimlerine bağlansın**. Ayarlanabilir her sabit tek yerde, tempo modeli (`tests/tempo.gd`) ile ölçüldü; cezalar yumuşatılmadı.

### İcra (1/4): birikir, sabah memur gelir, kasada yoksa ihtar → kepenk mühürü

Eskiden borç taksiti (kazancın %18'i) her gün kasadan otomatik kesiliyordu: borç hiçbir zaman "tehdit" değildi. Şimdi oran **aynı**, zamanlama değişti:

- **Taksit birikir** (6. günden itibaren, `G.icra.birikim`); **her 7 günde bir sabah** (ilk: 13. günün sabahı) icra memuru kapıda bekler ve birikeni **kasadan** alır. Memur, dükkân çubuğundaki "GÜN N" düğmesine basınca gelir (gece olayından / hırsızdan **önce**): gün sonunun kazancı o akşam harcandıysa kasa boştur.
- **Kasa yeter** → HESAP TAMAM, ihtar silinir. **Yetmez** → kasadaki kadar alınır, kalan + %20 gecikme zammı birikmeye devam eder; **1. kusur İHTAR**, **ardışık 2. kusur KEPENK MÜHÜRÜ**: 1 / 2 / 3 gün (her mühürde bir uzar) gelirsiz kaybedilir, takvim ilerler, sonraki icra tam bir hafta sonra. Oyun bitmez (icradan satış yok): ceza kaybedilen günler ve gelirdir. İstenenin %2'sinden az eksik (yuvarlama payı) kusur sayılmaz.
- **Arayüz:** yaklaşırken (en çok 2 sabah) dükkân çubuğunun altında "İCRA YARIN SABAH — kasada kalmalı: $X" (kasa yetmiyorsa kırmızı, yarınsa titrer); oyun içinde borç kutusunun altında küçük etiket; gün sonu kartında "TAKSİT BİRİKTİ +$ · icra N gün sonra: $"; BORÇ ÖDE panelinde **TAKSİT** düğmesi (birikeni hemen öder; elle ödeme zaten önce birikenden düşer). Memur kartı: İstenen / Kasadan alınan / Eksik / Gecikme zammı / Kalan borç + durum şeridi (HESAP TAMAM, İHTAR!, sarı-siyah şeritli KEPENK MÜHÜRLENDİ) + memurun sözü; TAMAM'a basılana kadar gün başlamaz.
- **Son taksit** beklemez: borcun tamamı birikmiş ve kasadaysa gün sonunda hemen tahsil edilir (kutlama eskisi gibi). Oynanan şehir **Demirkent (ferman)** ise ya da borç bittiyse icra yoktur.
- **Kayıt:** `G.icra` ilerleme kaydında (eski kayıtta taze durum, ilk ziyaret yüklemeden en erken 1 hafta sonra); kart (`sonuc`) kayda girmez. `validation/module-snapshot-baseline.json` içinde yalnız `save` satırı yeni alan için güncellendi (5 piksel / durum anlık görüntüsü aynı).
- **Tempo modeli** (`tests/tempo.gd --rezerv`): "harcayabildiğini harcar" oyuncu (kasa her akşam sıfır) 160 günde **4-7 ihtar, 2-3 mühür (3-6 gün kayıp)**; "icra sabahı için rezerv ayıran" oyuncu **0 ihtar / 0 mühür** ve borcu eskisiyle aynı günlerde (±2) bitirir (97 / 84 / 76 ↔ 99 / 87 / 78). Yani ceza yalnız savurgan oyuna uygulanır; sistematik bir vergi yok (aynı %18, yalnız zamanlama).
- **Test:** `tests/icra.gd` (69 denetim: birikim, vade, tamam / ihtar / mühür ve süreleri, tolerans, elle ödeme, son taksit, Demirkent, kayıt / bozuk kayıt, düğme → kart → TAMAM akışı, çizimler) + `tests/yazi_tasma.gd`'ya icra ekranları (6 dilde taşma yok) + 30 bozma denemesi (`tests/icra.gd` hepsini yakaladı). `economy` / `kapanis` testleri yeni anlama güncellendi.

### Geç oyunda beceri + para sinki (2/4): şube geliri artık NET, performans geç oyunda daha çok hizmet ister

Ölçüm (12. tur tempo): 50. günden sonra gelirin %90'ından fazlası şubelerdendi ve şube çarpanı çabuk doyuyordu (gelenlerin %35'ine yetişmek 0,92, %100'ü 1,15) — geç oyunda beceri neredeyse hiçbir şey değiştirmiyor, kasa ise anlamsızlaşıyordu.
- **Hacim hedefi yükselir:** gelen müşterinin %35'i (≤ 20. gün) → **%75'i** (≥ 70. gün), arası doğrusal (`progression_system.BR_HEDEF_*`, `f_branchHedefOran`). `BR_MAX` 1,15 → **1,35**. Geç oyunda gelenlerin %40 / %55 / %70 / %85'ine yetişen 0,74 / 0,93 / 1,16 / 1,28 çarpan alır (eskiden hepsi ~1,0).
- **Zincir gideri** (kira + maaş + malzeme): `gider = taban gelir × (0,30 + 0,18 × performans)` (`BR_GIDER_SABIT`, `BR_GIDER_DEGISKEN`, `f_branchGider`); sabit kısım performanstan bağımsız, değişken kısım malzeme. Performans ~%37'nin altına düşünce şube kâr etmez (net 0; para eksiye düşmez). Gün sonu kartında "N ŞUBE GELİRİ +$net" ve altında "gider $X · performans %Y"; `stat.branch` NET, `stat.branchBrut` / `stat.branchGider` ayrıca. Demirkent'te ne gelir ne gider.
- **Şube tablosu ×1,6** (`inc`: 1.000 / 3.100 / 8.700 / 15.700 / 28.000 / 90.000 / 288.000 / 912.000 / 1.250.000): ortalama oyuncunun (%70) net geliri ve borç bitiş günü (82) korunur, **beceri aralığı açılır**: dikkatli oyuncuda %40 / %50 / %55 / %70 / %85 / %100 yetişme için borç **153 / 118 / 103 / 82 / 72 / 66**. günde biter (eski eğri, %55 / %70 / %85 için 95 / 83 / 76). Şube panelinde üst satır "Günlük **brüt** gelir", alt not "gider düşülür" der.
- **Test:** `tests/sube_ekonomi.gd` (31 denetim: hedef eğrisi, uçlar, beceri ayrımı, gider formülü, net ≥ 0, gün sonu muhasebesi, Demirkent, ölü gün, tablo) + 12 bozma denemesi (hepsi yakalandı) + `yazi_tasma` (şube giderleri satırı, 6 dil).

### Şehir kuralları + ziyaret primi (3/4): metindeki vaat artık bir kural

Eskiden şehir yalnız görseldi (sokak, hava, müşteri görünümü); "Burada iddia büyük", "kuyruk hiç bitmez" gibi açıklamalar boş vaatti. Şimdi her şube şehri, oynanan şehir olduğu gün geçerli **bir kural** taşır (Babanın Dükkânı ve Demirkent kuralsız). Kurallar mevcut ayar katmanına (`j_TUN`) ve birkaç noktaya bağlıdır; hiçbir yeni mekanik / çizim gerekmedi.

| Şehir | Kural (rozet) | Ne yapar |
| --- | --- | --- |
| İstanbul | KUYRUK · MÜŞTERİ +%25 | müşteri akışı ×1,25, sabır ×0,92 |
| Berlin | İDDİA ×2 | rakip bahsinin kazancı ve cezası ×2 |
| Londra | KAPANMAYAN KÖŞE · GÜN +%25 | gün süresi ×1,25 |
| Manila | BİTMEYEN KUYRUK · MÜŞTERİ +%40 | akış ×1,4, sabır ×0,85 |
| Paris | KÜÇÜK VE TİTİZ · YER −1 • CEZA ×2 | sıradaki yer −1 (en az 2), hijyen cezası ×2, fiyat ×1,15 |
| Dubai | TURİST AKINI · BAHŞİŞ +%80 | bahşiş ×1,8, sabır ×0,85 |
| Tokyo | KUSURSUZLUK · KUSURSUZ +%25 | kusursuz teslim (tam kalite + istenen seçim + doğru sos) ×1,25, kusurlu ×0,8; evsize bedava yemek aynı |
| New York | UYUMAYAN ŞEHİR · GÜN VE MÜŞTERİ +%15 | süre ×1,15, akış ×1,15 |

- **Ziyaret primi:** açık bir şube şehrinde çalışılan gün o şubenin **taban geliri %50 artar** (`city_rules.ZIYARET_PRIM`; gider de buna göre). Gün sonu kartında şube satırında altın ★. Böylece şehir seçmek gerçek bir karar: zor kural ↔ prim; ev dükkânı her zaman kuralsız, primsiz taban (tempo modelinin ölçtüğü). Aynı hizmetle başka şubede çalışmak net geliri artırır; ama kural yoğunluğu artırıyorsa (İstanbul / Manila / New York) hedef de büyür ve çarpan düşebilir — beceri yoksa prim yetmez.
- **Arayüz:** şube panelinde her açık / sıradaki şehirde amber rozet; panel altında prim notu; gün giriş kartında "ŞEHİR KURALI: …" + açıklama + prim satırı (hava / maç satırlarıyla birlikte, kart genişliğe göre ayarlanır); giriş kartı artık "Kalan borç … • N şube" satırına göre de genişler (Fransızca / İspanyolcada 1-3 px taşıyordu).
- **Çeviri:** 27 metin × 5 dil (8 ad, 8 rozet, 8 açıklama, 3 genel). **Test:** `tests/sehir_kural.gd` (202 denetim: veri + çeviri, her kuralın etkisi evle karşılaştırmalı, Paris cezası aralığı, Tokyo teslim, evsiz, prim, gün sonu, çizimler) + 20 bozma denemesi (hepsi yakalandı) + `yazi_tasma`'ya 8 şehir × 4 hava giriş kartı.

