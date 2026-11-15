# Rehber — kaybolmadan çalışma kılavuzu

Bu belge "bu projede ne nerede, bir şeyi değiştirince neye dikkat etmeliyim, hata nasıl yakalanır" sorularının kısa cevabıdır. Ayrıntı için: [CODE_MAP.md](CODE_MAP.md) (hangi kod nerede), [BIRLESIK.md](BIRLESIK.md) (tur tur neler yapıldı), [ECONOMY.md](ECONOMY.md) (fiyat/tempo), [PLATFORMLAR.md](PLATFORMLAR.md) (mobil, Steam, dışa aktarma).

## 1. Oyun ve hedef

Babanın döner dükkânını ve **5.000.000 $ borcu** devralırsın: döner kes, dürüm sar, müşteriyi doyur, dükkânı büyüt, borcu kapat. **Süreye karşı yarış** oyunudur: her gün kısadır, "bir dürüm daha yetişir mi?" gerilimi oyunun kalbidir. Rahat/sakin (cozy) bir oyun değil; baskı, olaylar ve ceza kuralları **kasıtlıdır** — yumuşatma, danışmadan değiştirme.

Hedef: önce mobil, sonra Steam. Kalite çıtası "gold+" — her sistem sorunsuz, her dil ve ekran boyu temiz.

## 2. Klasör haritası (5 dakikada)

| Yer | İçinde ne var |
| --- | --- |
| `scenes/main.tscn` | Tek sahne; `scripts/platform_shell.gd` ekrana yerleşir, yardım/ayar pencerelerini çizer |
| `scripts/platform_game.gd` | Cihaz girdisi (fare/dokunma/kol), mola, uygulama yaşam döngüsü |
| `scripts/systems/` | **Oyun kuralları** (müşteri, sipariş, ekipman, ekonomi, olaylar, kayıt) |
| `scripts/rendering/` | **Çizim** (ekranlar, pencereler, karakterler, sokak, HUD) |
| `scripts/core/` | Ortak durum (`game_state.gd`), oyun döngüsü (`game_loop.gd`), dil (`localization.gd`), matematik/biçim (`math_utils.gd`) |
| `data/` | Veri: `upg.gd` (24 geliştirme), `sehir.gd` (9 şube), `en.gd` + `dictionary_de/fr/es/pt.gd` (çeviriler) |
| `assets/` | Görseller/sesler (HD atlaslar `assets/remake/`) |
| `tests/` | Testler ve botlar (aşağıda) |
| `tools/` | Yardımcı araçlar: ekran görüntüsü (`ekran_senaryo.gd`), taban güncelleme (`snapshot_tabanini_guncelle.py`) |
| `validation/` | Test referansları ve sonuç dosyaları |
| `artifacts/` | Testlerin yazdığı geçici dosyalar (git'e girmez) |

Oyun nesnesine her yerden `game.<modül>.<fonksiyon>` ile erişilir (örn. `game.customer_system.f_spawnCustomer()`). Oyun verisi `game.j_G` içindedir. `f_…` / `j_…` adları eski JavaScript kaynağıyla eşleşmek için korunur; **yeni kodu düz GDScript ile yazabilirsin** (`J.getv/J.add` zorunlu değil).

## 3. "Şunu değiştirmek istiyorum" — hızlı tablo

| İstek | Nereye bak |
| --- | --- |
| Müşteri gelişi, sabrı, kapıdaki sıra | `systems/customer_system.gd` (`SIRA_MAX`, `SIRA_SURE`), `progression_system.gd` (`f_dayCfg`) |
| Gün süresi / yoğunluk | `progression_system.gd` → `f_dayCfg` |
| Olaylar (müfettiş, hırsız, kesinti…) | `systems/event_system.gd`, `systems/events/`; eşikler `core/game_setup.gd` (`j_*_DAY`, `j_*_SANS`) |
| Fiyatlar ve geliştirmeler | `data/upg.gd`, `systems/upgrade_system.gd`, [ECONOMY.md](ECONOMY.md) |
| Bir ekranın görünümü | `rendering/ui/<ekran>_draw.gd` (dosya adı ekranı söyler) |
| Yeni görünür yazı | Kodda Türkçe yaz + **5 sözlüğe ekle** (bölüm 7) |
| Kayıt alanı eklemek | `systems/save_system.gd` (`f_saveAll`, `f_loadAndGo`) + `session_system.f_resetProgress` |
| Gün içi kayıt (mobilde uygulama kapanırsa) | `systems/save_system.gd` (`gunici_*`, `GUNICI_ARALIK`, `GUNICI_ATLA`) |
| Baba'nın Defteri (kayıp tarifler: sayfa bulma, sipariş, prim, usta) | veri: `data/tarif.gd`; mantık: `systems/events/tarif_system.gd`; ekran: `rendering/ui/tarif_draw.gd`; kancalar: `recipe_system.f_makeOrder`, `customer_system.f_deliver` / `f_payCustomer`, `session_system.f_endDay`, `shop_draw`, `day_end_draw`, `order_draw` |
| Rakip bahisleri (hedef, ödül, süzgeç) | `systems/events/rival_system.gd` (`BAHIS_KAT`, `f_bahisHedefi`, `f_bahisGunuKaydet`), ödül: `progression_system.f_bahisPara` |
| Çöp kutusu / ürün atma | `systems/event_system.gd` (`cop_eylemi`, `f_trashClick`, `f_dropOnTrash`), kumanda: `station_actions.gd` ("discard") |
| Telefon / pencere / dokunma | `platform_shell.gd`, `device_input.gd`, `station_actions.gd` |

## 4. Kural cetveli (kodla doğrulanmış)

- **Gün süresi:** `min(210, 60 + 2·gün + 2·toplam_geliştirme_seviyesi)` saniye. Süre bitince **son 15 sn** yeni müşteri gelmez; içerideki müşteriler bitene dek (en çok 45 sn) gün sürer.
- **Müşteri aralığı:** `max(2; min(6.8 − 0.22·gün; 4.6 − 0.08·gün)) / yoğunluk çarpanı` sn (bu değerin 0.75–1.2 katı rastgele).
- **Yer yoksa:** kapıda camın önünde en çok 3 kişilik sıra; sıradaki 10 sn bekler, yer açılmazsa **yazısız, sessizce** gider. Lider gelince sıra dağılır. Gün sonundaki "kapıdan dönen" yalnız sıraya girip gidenleri sayar.
- **Borç:** 5.000.000 $; **6. günden** her günün kazancının %18'i otomatik ödenir (Demirkent hariç).
- **Olay eşikleri (gün):** müfettiş 4 (%28), kedi 4 (%30), lider 4, evsiz 5 (%30), kesinti 8 (%16, 34 sn), motor arızası 8, rakip/bahis 10, hırsız 12.
- **Çöp:** müfettiş kontrol ettiği anda çöp %55'in üstündeyse ceza yazar (150–400 $, **borca eklenir**); temizse ceza yok. Kutuya dokunmak **hep çöpü boşaltır**; ürünü atmak için tutup kutuya sürüklenir (kumanda/klavyede "al" basılı).
- **Rakip bahsi (10. günden):** hedef oyuncunun **son 3 gündeki ortalamasının %110'u** (dürüm / kasaya giren para / bahşiş), kazanç ve ceza `200 + 34·gün`. Geçmiş yoksa eski gün formülleri. Reddetmek serbest; "müşteri kaçırırsın" yalnız son günlerde müşteri kaçmışsa çıkar.

## 5. Testler

```sh
GODOT=/godot/yolu sh tests/hepsi.sh      # hepsi; sonda "HEPSI GECTI" ya da kalanlar
sh tests/kontrol.sh                       # yalnız betik ayrıştırma (hızlı)
godot --headless --path . --script tests/cila.gd --quit-after 3000 -- --test   # tek test
```

Kural: **bir hata bulursan önce onu yakalayan bir test (ya da mevcut teste kontrol) ekle, sonra düzelt.** Test geçmeden commit yok.

| Test | Neyi korur |
| --- | --- |
| `order_flow`, `eksik_teslim`, `toplu_siparis` | Sipariş akışı, eksik teslim, toplu sipariş |
| `cutting`, `mouse_slicing`, `mouse_knife` | Döner kesme (fare/dokunma/kol) |
| `stations`, `counter_input`, `ingredient_input`, `bread_preparation`, `akilli_hedef`, `tek_tik`, `fare_akisi` | Tezgâhta nesne seçimi, malzeme ekleme, öğretici yolu |
| `economy`, `tempo` | Fiyat ve ilerleme dengesi |
| `kapanis`, `kapanis_sira` | Oyun sonu hikâyesi; gün sonu ve kapıdaki sıra kuralları |
| `tarif` | Baba'nın Defteri: sayfa bulma, ekipman, sipariş dağılımı, fiyat / usta / menü bonusu, kayıt, düğme-panel-kart akışı |
| `bahis_input`, `bahis_hedef`, `dev_panel` | Bahis paneli girdisi, bahis hedefleri (son 3 gün ortalaması), geliştirici paneli |
| `cop_kutusu` | Çöp kutusu: dokunmak boşaltır, sürükleyip bırakmak / basılı tutmak ürünü atar (fare, dokunma, kumanda) |
| `fritoz_katman` | Eski (HD kapalı) fritöz çiziminde patates çubukları yağ penceresinin dışına taşmaz; F2 yalnız debug'da; HD durum etiketi |
| `gun_ici_kayit` | Mobilde uygulama kapanırsa devam eden günün kalınan yerden açılması |
| `platform_input`, `runtime_state`, `module_services`, `regression` | Cihaz girdisi, durum/kayıt, modüller |
| `module_snapshot` | 5 sahnenin **piksel + durum + kayıt** referansı (bölüm 7) |
| `dil_cift`, `ceviri_tarama` | Çeviri kapsamı: koddaki her (tr, en) çifti ve oyun verisi 5 sözlükte var mı |
| `yazi_tasma` | 6 dilde ~7.400 yazı: ekrandan/pencereden/düğmeden taşma, üst üste binme, çevrilmemiş (Türkçe harfli) yazı |
| `cila` | Yayın öncesi taramada bulunan kusurların geri gelmemesi (fiş başlığı, rozet sütunu, sayı biçimi, aygıt sözü, sürüm eşitliği…) |
| `*_visual` | Gerçek GPU penceresiyle ekran kontrolleri (`--gpu-test`) |

**Botlar:** `tests/usta_bot.gd` oyunu insan hızında baştan oynar (kural/çökme avı; `--tam`, `--sehir N`, `--tohum`); `tests/kaos.gd` rastgele eylemlerle kırmaya çalışır.

## 6. Bir ekranı gözle görmek

```sh
godot --path . --resolution 960x540 --script tools/ekran_senaryo.gd -- --test --gpu-test --senaryo rekor --dil de --cikti artifacts/galeri
```

`--senaryo` listesi ve `--boyut 1200x540 --touch-preview` (telefon gibi) seçenekleri dosyanın başındadır. Çıktı PNG'ler `artifacts/galeri/` altına yazılır. "Bu pencere Almancada/telefonda nasıl görünüyor?" sorusunun en hızlı cevabıdır.

## 7. Yeni bir şey eklerken

**Yeni görünür yazı.** Kodda Türkçe yaz (`f_txt("MERHABA", …)`, ya da çift yazım `text("Merhaba","Hello")`). Sonra `data/en.gd` ve `data/dictionary_de|fr|es|pt.gd` dosyalarının **sonuna** aynı Türkçe anahtarla çeviri ekle (anahtar = Türkçe metnin kendisi; Türkçe metni değiştirirsen 5 dosyada anahtarı da değiştir). `ceviri_tarama` eksiği, `yazi_tasma` taşmayı yakalar. Uzun metne `{"maxw": N}` ver (sığmazsa "…" ile kısalır).

**Sayı/para yazarken** `game.math_utils.f_fmtMoney` (binlik ayracı dile göre), `f_fmtShort`, `f_fmtOndalik`, `f_yuzde` kullan: elle `"$" + str(n)` yazma.

**Fare "tıkla" sözü.** Telefonda "dokun", kolda yalın söz çıksın diye girdiye göre değişen metinler `core/localization.gd` içindeki `GIRDI_SOZ` tablosundadır.

**Çizim değişirse** `module_snapshot` piksel farkı verebilir. Fark yalnız piksel ise ve bilinçli bir görsel değişiklikse: `python3 tools/snapshot_tabanini_guncelle.py` (neyin değiştiğini söyler), onaylarsan `--yaz`. Oyun durumu farkı varsa araç durur: bu bir hatadır, tabanı değiştirme. Kayıt (`save`) farkı da durdurur; ama **yeni bir ilerleme kaydı alanı eklediysen** o fark bilinçlidir: araç hangi alanların eklendiğini yazar, doğruysa `python3 tools/snapshot_tabanini_guncelle.py --kayit --yaz`.

## 8. Başa dert açmış tuzaklar

- Test sonuç dosyaları (`validation/*-results.json`) test çalışınca değişir; commit'e **sokma** (`hepsi.sh` bunları geri alır). Yalnız bilinçle güncellenen `module-snapshot-baseline.json` girer.
- Oyunun rastgelesi kendi sayacıdır (`game.random_state`); `--test` kipinde sabittir. Testte "rastgele" davranış görmek için tohumu değiştir.
- Bir sahne `scene` alanıyla yönetilir (`title`, `intro`, `play`, `pause`, `dayend`, `shop`, `night`); yeni pencere ekliyorsan `platform_game.gd` içindeki pencere listelerine (`j_CUSTOM, j_PAYP, …`) ve `device_input.gd` hedef bağlamına eklemeyi unutma.
- Piksel yazı genişliği dile göre çok değişir (Almanca ~%30 uzun). Etiketle değer yan yanaysa `maxw` ver.
- Yeni bir **oyun durumu alanı** (`G.alan`) eklersen: ilerleme kaydı için `f_saveAll` + `f_loadAndGo` + `f_resetProgress` üçünü de güncelle. Gün içi anlık görüntü `G`'nin tamamını (`GUNICI_ATLA` hariç) yazar, orada ek iş gerekmez; ama `G`'ye düz sayı/yazı/dizi/sözlük dışında bir değer (Callable, Vector2…) koyarsan anlık görüntü yazılamaz — `gun_ici_kayit` testi bunu yakalar; alanı düz veriyle tut ya da `GUNICI_ATLA`'ya ekle.
- **İki çizim kipi var:** HD (varsayılan; Blender atlasları + shader) ve "eski çizim" (piksel). Eski çizim yalnız karşılaştırma içindir; **F2 yalnız debug derlemesinde** çalışır. Oyun eski çizimde kalmışsa debug derlemesinde ekranın üst ortasında kırmızı etiket ("ESKİ ÇİZİM · F2", "HD KAPALI: proje içe aktarılmamış", "dokular yüklenemedi") görünür. "Oyun kötü görünüyor / HD kapalı" şikâyetinde önce bunu kontrol et: **en sık neden projenin Godot'ta hiç içe aktarılmamış olmasıdır** (taze ZIP + `godot --path .`); çözüm `Oyna.cmd` (önce `--headless --path . --import` çalıştırır) ya da projeyi editörde bir kez açmak. `hd_acik` artık "istek VE dokular yüklü"dür; dokular yoksa F2 işe yaramaz.
- Godot 4.7; `.godot/` klasörü git'e girmez. İlk açılışta içe aktarma ~30 sn sürer.

## 9. Yayın kontrol listesi (mobil → Steam)

1. **Sürüm:** `project.godot` içindeki `config/version` ile `export_presets.cfg` (Windows/Android/iOS) aynı olmalı; Android sürüm kodu = `ana·10000 + ara·100 + yama` (0.7.2 → 702). `cila` testi bunu kilitler.
2. **Paket kimliği:** `com.myfathersdoner.game` örnektir; mağazaya çıkmadan kendi benzersiz kimliğinle değiştir.
3. **Android:** dışa aktarma şablonları + SDK + kendi imza anahtarın; Play Store için Gradle/AAB. Gerçek telefonda: kare süresi (Ayarlar → "Kare süresini göster"), pil, çentik, geri tuşu.
4. **Steam:** Windows/Linux/macOS profilleri hazır. Steamworks (GodotSteam) bu pakette **yok**; başarım (64 adet) ve bulut kaydı sonradan bağlanır. Kol desteği ve 16:9 sığdırma hazır.
5. **Gün içi kayıt:** uygulama işletim sistemi tarafından kapatılırsa gün molada, kalınan yerden geri gelir (anlık görüntü her 12 sn'de bir, arka plana alırken ve ana menüye dönerken yazılır; en çok son 12 sn kaybolur). Gerçek telefonda dene: oyunun ortasında uygulamayı kapat, yeniden aç, Devam Et.
6. **Mağaza görselleri:** `tools/ekran_senaryo.gd` ile her dilde ekran görüntüsü al.
