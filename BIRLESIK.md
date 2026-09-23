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
godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test --full [--sahne shop|title|dayend]
godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test --full --kedi gelis|bekle|yiyor --rakip 330 --kalip kurye
godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test --dolgu 4,3,2,3 --sos garlic   # tek dürüm (1.8 ölçek)
godot --path . --resolution 960x540 --script tests/hd_musteri_dizi.gd -- --test --gpu-test --adet 32 [--kalip kurye]   # yüz yüz müşteri ızgarası
godot --path . --resolution 960x540 --script tests/hd_profil.gd -- --test --gpu-test
godot --headless --path . --script tests/module_snapshot.gd --quit-after 3000 -- --test
```

Tabanın bütün testleri geçiyor (sipariş akışı, kesim, istasyonlar, girişler, ekonomi, anlık görüntü 6/6). Anlık görüntü referansında tek değişiklik `upgraded-shop`: taban projede boyalı duvar siyah çiziliyordu (`js_compat` `toString(16)` tabanı yok sayıyordu), birleşik sürümde doğru renk.

Kare süresi (tam yükseltmeli oyun ekranı çizimi, Ryzen 5 3600X + RTX 5060): 12 ms; başlık 18 ms.
