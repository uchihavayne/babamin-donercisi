# Pixelorama ile asset düzenleme

Pixelorama 1.2.3 ile açma ve PNG dışa aktarma kontrol edildi. Kaynak projeler `pixelorama/`, oyunun okuduğu PNG dosyaları `../assets/sprites/` içinde.

## Düzenleme akışı

1. Pixelorama'da **File → Open** ile `.pxo` dosyasını aç.
2. Sol alttaki katman listesinden değiştireceğin parçayı seç. Katman adları manifest anahtarlarıyla eşleşir.
3. Çizimini düzenle, **Save** ile `.pxo` dosyasını kaydet.
4. **File → Export** ile tek kareyi PNG olarak, **%100 ölçekte**, aynı dosya adıyla `assets/sprites/` içine aktar. Tüm görünür katmanlar birlikte dışa aktarılmalı. Tuvali kırpma veya yeniden boyutlandırma.
5. Godot'ta içe aktarma tamamlanınca oyunu yeniden çalıştır.

`.pxo` kaydetmek tek başına oyunun PNG'sini değiştirmez. PNG dışa aktarma adımı gereklidir.

## Dosyalar

| Kaynak | İçerik | Tuval / hücre |
| --- | --- | --- |
| `counter_design_base.pxo` | Yeni tezgâh zemini, ahşap dolaplar ve metal yüzey; saydam üst alan korunmalı | 480×270 |
| `counter_design_trays.pxo` | Yeni eşit boydaki tepsilerin taban/gölge katmanları | 256×128 / 128×128 |
| `counter_fill_*.pxo` | Yeni et, turşu ve patates tepsilerinin 41 doluluk seviyesi | 384×252 / 48×42 |
| `tezgah_esyalari.pxo` | Tepsiler, lavaş, pide, patates kasası, iki yönde dört bıçak seviyesi | 1024×512 / 128×128 |
| `doluluk_et.pxo` | 41 et doluluk seviyesi, soldan sağa ve üstten alta | 400×228 / 50×38 |
| `doluluk_tursu.pxo` | 41 turşu doluluk seviyesi | 304×228 / 38×38 |
| `doluluk_patates.pxo` | 41 patates doluluk seviyesi | 304×228 / 38×38 |
| `hikaye_*.pxo` | Hikâye ekranlarının 10 ayrı arka/ön katmanı | 400×150 |

`assets/sprites/donerci.gpl` özgün renk paletidir; Pixelorama'ya palet olarak aktarılabilir. PNG hücrelerinin koordinatları `assets/sprites/manifest.json` içindedir. Hücre boyutunu değiştirmek istersen manifestin `region` ve `offset` alanlarını da güncelle.

## İsteğe bağlı toplu dışa aktarma

Proje kökünde:

```sh
python3 tools/export_pixelorama.py tezgah_esyalari
python3 tools/export_pixelorama.py
```

İlk komut bir projeyi, ikinci komut 19 projeyi de dışa aktarır ve karşılık gelen PNG dosyalarının üzerine yazar. Python 3 ve Pixelorama gerekir. macOS'ta kurulu uygulama otomatik bulunur; farklı kurulumlar için `PIXELORAMA_BIN` ortam değişkenini kullan.

## Kodla kalan görseller

Rastgele müşterilerin görünüm ve mimik birleşimleri çalışma sırasında hazırlanıp saklanır; her kare yeniden çizilmez. Dönerin pişmesi/kesilmesi, yağmur, parçacıklar, bazı makineler ve hareketli öğeler kodla çizilmeye devam eder. Yeni tahta ve makineler `scripts/counter_design.gd` içindedir. Diğerleri `scripts/game_sprites.gd`, `scripts/spit_pixels.gd` ve özgün `scripts/game.gd` içinden düzenlenebilir. Oyun kuralları GDScript'tedir.

Çalışma klasöründeki `tools/bake_sprites.gd` atlasları özgün koddan yeniden üretir. Pixelorama'daki düzenlemeleri PNG'lerin üzerine yazacağı için normal görsel düzenleme sırasında çalıştırma. `tools/make_pixelorama.py` kaynak projeleri oluşturur; mevcut `.pxo` dosyalarını varsayılan olarak korur.

Pixelorama'nın [içe aktarma](https://pixelorama.org/user_manual/Import/) ve [komut satırı](https://pixelorama.org/user_manual/cli/) belgeleri.

Yeni tezgâhın varsayılan zemin PNG'si yalnızca varsayılan tezgâh temasında kullanılır. Diğer üç oyun içi renk seçeneği aynı geometrinin kodla çizilmiş sürümünü kullanır. Atlaslarda olmayan hareketli ekipmanlar ve hazırlanan yemekler GDScript'ten çizilir.

`tools/bake_counter_design.gd` yalnızca yeni beş atlası yeniden üretir; bu atlaslardaki PNG düzenlemelerinin üzerine yazar. Normal çizim için çalıştırma. Koddan bilinçli yeniden üretim sonrasında `python3 tools/make_pixelorama.py counter_design_base counter_design_trays counter_fill_et counter_fill_tursu counter_fill_patates --replace` yalnızca yeni beş Pixelorama projesini yeniler. Bu yardımcı araç için Pillow gerekir. Oyun çalışırken Python gerekmez.
