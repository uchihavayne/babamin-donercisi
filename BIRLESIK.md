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
