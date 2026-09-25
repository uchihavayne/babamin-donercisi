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
