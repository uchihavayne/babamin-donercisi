# Blender piksel-art modelleri

Döner Efsanesi'nin nesnelerini Blender'da 3B modelleyip **oyunun kendi
paletinde, anti-alias'sız piksel-art sprite** olarak render eden ayrı bir
çalışma alanı.

> Bu klasör oyuna **bağlı değil**. `tools/build.js` sadece açık bir dosya
> listesini kopyalıyor, `blender/` hiçbir şekilde `dist/`'e girmiyor.
> Oyun hâlâ %100 kodla çiziliyor; buradan çıkan bir şey ancak sen istersen
> uygulanır.

---

## Neden 3B?

Oyun her şeyi elle kodla çiziyor. 3B'nin kazandırdığı tek şey var ama büyük:
**türev üretmek.** Şişi bir kez modelleyince

- 16 karelik dönüş animasyonu,
- 5 pişme derecesi,
- 5 et miktarı,
- kesilmiş / kesilmemiş hâli

tek komutla çıkıyor. Bunları elle piksel piksel çizmek günler sürer.

## Nasıl çalışıyor

Üç kural boru hattının tamamını belirliyor:

1. **1 Blender birimi = 1 oyun pikseli.** Ortografik kamera, `ortho_scale`
   render genişliğine eşit. Model doğrudan oyun koordinatlarında kuruluyor
   (`blender_x = oyun_x`, `blender_z = -oyun_y`).
2. **Anti-alias yok.** `filter_size = 0.01`, `taa_render_samples = 1`,
   `dither_intensity = 0`. Kenarlar tam piksel.
3. **Renk yönetimi kapalı.** `view_transform = "Standard"`, materyaller
   Emission. Palet hex'i içeri linear olarak veriliyor, dışarı **birebir aynı
   hex** çıkıyor.

Gölgeleme ışıkla değil, **oyunun kendi mantığıyla** yapılıyor: `cel_nx()`
tonu yüzey normalinin bir bileşeninden okuyup sabit (CONSTANT) bir renk
rampasına sokuyor. `art.js`'teki

```js
if (nx < -.78) shade = .52; else if (nx < -.55) shade = .66; ...
```

kademelerinin birebir karşılığı. Işık kaynağı olmadığı için koni dönerken
bantlar kaymıyor — sadece dikişler dönüyor, tam da oyunun yaptığı şey.

Her render sonunda `audit()` çıktıdaki benzersiz renkleri sayıp palet dışına
çıkanı rapor ediyor. İkisi de şu an **sıfır palet dışı renk** veriyor.

### Oblik açılım (`shear_scene`) — 2026-09-09 düzeltmesi

`shear_scene(k)` geometriyi `z += y * k` ile kaydırıp yatay yüzeyleri
görünür kılıyor. Kaydırma **dünya** uzayında yapılmalı ama `matrix_world`,
obje oluşturulduktan sonra depsgraph değerlendirilene kadar eski kalıyordu;
okuyunca kaydırma sessizce **yerel** uzayda oluyordu.

Sonucu şu: bir kutunun üst yüzeyi `k · yükseklik / derinlik` kadar
eğiliyordu. Küp gibi objelerde fark edilmiyor, ama **yassı** bir levhada
(yüksekliği derinliğinden çok küçük) üst yüzey neredeyse yok oluyordu —
pide 5 piksellik bir çıta gibi çıkıyordu. `bpy.context.view_layer.update()`
eklendi. Bu düzeltmeden **önce** üretilmiş render'lar yatay yüzeyleri
olduğundan dar gösteriyor; yeniden render almak gerekir.

## Dosyalar

| dosya | ne yapar |
|---|---|
| `pxlib/palette.py` | `js/core.js`'teki `P` paletinin birebir kopyası + `meatColCalc()` |
| `pxlib/pxcore.py` | render çekirdeği: sahne kurulumu, cel materyaller, denetim, sprite sheet |
| `models/spit.py` | döner şişi (`art.js:drawSpit`) |
| `models/wrap.py` | dürüm (`food.js:drawWrapRolled`) |
| `models/kesim.py` | kesim animasyonu + tepsi garnitürleri |
| `models/bicaklar.py` | kesim bıçağı kademeleri (`art.js:drawKesimBicagi`) |
| `models/kagit.py` | dürüm kâğıdı ve kâğıt makinesi |
| `models/icecek.py` | içecek dolabı kademeleri |
| `models/fritoz.py` | fritöz + ayran kazanı |
| `models/patates.py` | patates, doğrama, çuval, çöp |
| `models/hikaye.py` | **açılış hikâyesinin 5 sahnesi** (`js/prologue.js`) |
| `models/sos.py` | sos rafı, İskender tabağı, ızgara, tatlı tepsisi |
| `models/kalip.py` | özel müşteri kalıpları (`js/chars.js` → `KALIP`) |
| `models/binek.py` | özel müşterilerin binekleri: ejderha, süpürge, karavan |

`hikaye.py` diğerlerinden farklı: tek bir nesne değil, 400x150'lik tam
sahneler üretiyor ve oyundaki `prologue.js` ile **aynı koordinat
sistemini** kullanıyor (Blender x -200..200, z -61..89 -> çerçeve
(40,44) 400x150). İkisi yan yana okunabilsin diye.

Sahnelerde araç seçimi bilinçli - ilk denemede hepsi `cel_nx` ile
yapılıp mukavva gibi çıkmıştı:

| araç | nerede | neden |
|---|---|---|
| `px.flat` | mimari | Kutuların bütün ön yüzlerinin normali aynı; `cel_nx` hepsine tek ton verir. Tonu elle seçmek gerekiyor. |
| `px.cel` + `px.sun` | baba portresi, el, anahtar, çay bardağı, kâğıdın kıvrımı | Gerçek ışık yönü + lambert; organik formun hacmi buradan çıkıyor. |
| `cel_nx` | döner konisi | Oyunun kendi bantlama mantığı; dönerken bantlar yerinde kalıyor. |
| `compare.py` | Blender çıktısını oyunun kendi çizimiyle yan yana koyar, siluet farkını ölçer |
| `ingame.py` | sprite'ı gerçek oyun karesine bindirir |
| `out/` | üretilen PNG'ler (elle silinebilir) |

## Çalıştırma

```bash
blender/yap.cmd spit rot
```

Modlar:

| komut | çıktı |
|---|---|
| `yap.cmd spit look` | 5 pişme derecesi yan yana |
| `yap.cmd spit rot` | 16 karelik dönüş + `spit_sheet.png` (1024×144) |
| `yap.cmd spit mass` | et azaldıkça koni |
| `yap.cmd wrap look` | ham → kızarmış → yanık, kâğıtlı |

Karşılaştırma (oyun sunucusu açıkken, tarayıcı konsolundan `__zoom` ile
referans alındıktan sonra):

```bash
blender/yap.cmd compare
blender/yap.cmd ingame spit_rot00.png
```

## Doğrulama sonuçları

- **Siluet:** şişin et konisi, oyunun kendi çizimiyle 109 satır boyunca
  ortalama **0,1 piksel** farkla örtüşüyor.
- **Palet:** dürüm 7 renk, hepsi oyunun kendi renkleri. Şiş, `meatColCalc()`
  eğrisinden üretilen tonlar dışında palet dışına çıkmıyor.
- **Sahne testi:** `ingame.py` sprite'ı gerçek oyun karesine bindiriyor;
  hizalama, ölçek ve renk tutuyor.

## Uygulanacak olursa

Sprite'lar saydam zeminli PNG. Oyuna girmesi için:

1. `spit_sheet.png` `assets/`'e girer (oyun şu an görsel dosyası
   kullanmıyor — bu ilkeyi bozar, karar senin).
2. `drawSpit()` içindeki koni döngüsü yerine sheet'ten
   `sp.rot`'a göre kare seçen bir `drawImage()` gelir.
3. Isıtıcı paneli, bıçak ve parçacıklar kodda kalır — onlar zaten canlı.

Alternatif: render'ları sadece **referans** olarak kullanıp `art.js`'e elle
kodlanmış çizime çevirmek. O zaman "hiç görsel dosyası yok" ilkesi bozulmaz.
