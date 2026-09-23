/* ============================================================
   DÖNER EFSANESİ — data.js
   Basit başlangıç, upgrade ile otomasyon.
   Başlangıçta TEK ürün: Dürüm = Lavaş + Tavuk + Turşu + Yoğurt + Patates
   ============================================================ */
'use strict';

/* Fiyatlar 2026-09-02'de kullanici talimatiyla artirildi (eski 'fiyatlar
   degismez' kurali kaldirildi). Durumde artis GOVDEDE: soslu durum da
   +2-3 arasinda kalsin diye bonuslar yalniz +1 arttirildi.
     sade durum   12 -> 15
     izgarali     18 -> 22
     izgara+sos   21 -> 26
   Tek basina satilanlara tam +3. */
var PRICE = { wrap: 15, grillBonus: 7, sauceBonus: 4, drink: 10, fbox: 12, ayran: 9, sweet: 14, iskender: 29, tomato: 5, pepper: 6 };
var MEAT_NEED = 4;          /* bir dürüme giren et porsiyonu */
var FRIES_NEED = 4;         /* bir dürüme giren patates porsiyonu */
var PICKLE_NEED = 4;        /* bir dürüme giren turşu porsiyonu */
var YOGURT_NEED = 4;        /* bir dürüme giren yoğurt porsiyonu */
var PLATE_YOGURT = 3;       /* iskender tabağına giren yoğurt */
var PIDE_NEED = 4;          /* pideyi doğramak için gereken vuruş */
var TOMATO_NEED = 3;        /* tabağa giren domates dilimi */
var PEPPER_NEED = 2;        /* tabağa giren biber */
var ISK_MEAT = 5;           /* bir iskender tabağına giren et porsiyonu */
var PHONE_MUL = 1.9;        /* telefon siparişi para çarpanı */
var RAIN_CHANCE = 0.16;     /* yağmurlu gün olasılığı (3. günden sonra) */
/* --- MAC GUNU ---
   Gunun ritmi yoktu: musteri hizi acilistan kapanisa sabitti.
   Mac gunu gunun ortasina bir dalga koyuyor. */
var MAC_ARA_MIN = 8, MAC_ARA_MAK = 12;   /* kac gunde bir */
var MAC_ILK = 6;                          /* ilk mac gunu en erken */
var MAC_BAS = .40, MAC_BIT = .68;         /* gunun hangi diliminde */
var MAC_HIZ = 0.34;                       /* dalgada gelis araligi carpani */
/* --- GUN ACILISI ---
   Kepenk 1.5 saniyede kalkiyor; ilk musteri 4.2 saniye sonra yola
   cikiyordu, yani oyuncu daha tezgaha bakmadan kapida biri oluyordu.
   Once ocagi yak, sisi kes, stogu doldur diye 10 saniye nefes payi. */
var ILK_MUSTERI = 10;        /* gun basinda ilk musterinin cikis anı (sn) */

/* --- SOKAK KEDISI ---
   Olaylarin hemen hepsi cezalandirici. Kedi odullendiren bir an:
   et verirsen sans, vermezsen ceza yok. */
var KEDI_GUN = 4;            /* en erken kacinci gun */
var KEDI_SANS = 0.30;        /* gun basina gelme olasiligi */
var KEDI_BEKLE = 26;         /* kac saniye bekler, sonra gider */
/* --- ELEKTRIK KESINTISI ---
   Izgara ve fritoz durur; ELLE yapilan her sey calisir, oyun
   kilitlenmez. Jenerator suresini kisaltir, son seviye engeller. */
var KESINTI_GUN = 8;         /* en erken kacinci gun */
var KESINTI_SANS = 0.16;     /* gun basina olasilik */
var KESINTI_SURE = 34;       /* taban sure (sn) */

/* --- MALZEME SECIMI ---
   Acikken musteri "sunu istemiyorum" diyor. Dürüm pahalanir ama
   artik herkese ayni dürüm gitmez. */
var SECIM_MALZEME = ['pickle', 'yogurt', 'fries'];
var SECIM_AD = { pickle: 'turşusuz', yogurt: 'yoğurtsuz', fries: 'patatessiz' };
/* Rozetin yanına yazılan KISA ad. İstasyon ipuçlarıyla aynı anahtarlar:
   oyuncu tezgâhta hangi kutuya "Turşu" dendiğini zaten görüyor, aynı
   kelimeyi baloncukta görünce eşleştirmesi kolay oluyor. */
var SECIM_KISA = { pickle: 'Turşu', yogurt: 'Yoğurt', fries: 'Patates' };
/* Müşteri tezgâha varınca isteğini SÖYLER de: rozet kaçarsa cümle
   yakalar. İki kanal birden. */
function secimReplik(ord) {
  if (!ord || !ord.yok || !ord.yok.length) return '';
  var p = [];
  for (var i = 0; i < ord.yok.length; i++) p.push(T(SECIM_AD[ord.yok[i]]));
  return p.join(', ') + T(', lütfen.');
}

/* --- RAKIP DONERCI ---
   Karsi kaldirimda dukkan acar. Arada gelip bahse girer: kabul
   etmek ZORUNLU DEGIL, reddetmenin cezasi yok. */
var RAKIP_GUN = 10;          /* dukkani kacinci gun acilir */
var RAKIP_ARA_MIN = 5, RAKIP_ARA_MAK = 8;   /* kac gunde bir gelir */
var RAKIP_PES = 6;           /* ust uste kac bahis kaybederse dukkani kapanir */

/* Bahis turleri. hedef(G) o gunun sartina gore hedefi uretir,
   olc(G) gun sonunda ulasilan degeri verir. */
/* Cumle ON ve SON diye ikiye bolunuyor: aradaki sayiyi kod koyuyor.
   Suslu parantezli yer tutucu kullanilamiyordu: o iki karakter
   oyunun kendi fontunda yok, denetim de kaynagi tariyor.
   Bolme ayni zamanda TR/EN sozdizimi farkini da cozuyor:
     TR  'Bugün' + 10 + 'dürüm satamazsın.'
     EN  "You can't sell" + 10 + 'wraps today.'  */
var BAHIS = [
  { id: 'durum', on: 'Bugün', son: 'dürüm satamazsın.', para: false,
    hedef: function (G) { return Math.max(4, Math.round(6 + G.day * .22)); },
    olc: function (G) { return G.stat.wraps || 0; } },
  { id: 'para', on: 'Bugün kasaya', son: 'koyamazsın.', para: true,
    hedef: function (G) { return Math.round((160 + G.day * 26) / 10) * 10; },
    olc: function (G) { return (G.stat.earned || 0) - (G.stat.branch || 0); } },
  { id: 'kacan', on: '', son: 'Bugün en az bir müşteri kaçırırsın.', para: false,
    hedef: function () { return 0; },
    olc: function (G) { return -(G.stat.lost || 0); } },   /* 0 kacan = 0 >= 0 kazanir */
  { id: 'bahsis', on: 'Bugün toplam', son: 'bahşiş alamazsın.', para: true,
    hedef: function (G) { return Math.round((30 + G.day * 6) / 5) * 5; },
    olc: function (G) { return G.stat.tips || 0; } }
];
function bahisTip(id) { for (var i = 0; i < BAHIS.length; i++) if (BAHIS[i].id === id) return BAHIS[i]; return null; }
/* Bahis parasi: gune gore buyur, ama gunluk kazancin altinda kalir. */
function bahisPara(G) { return Math.round((200 + G.day * 34) / 10) * 10; }

/* --- Rakibin agzi ---
   Once laf atar, sonra iddiayi soyler, sonra parayi masaya koyar.
   Ilk ziyaret ozel: kendini tanitiyor. */
var RAKIP_SELAM_ILK = [
  'Karşıya dükkân açtım. Komşuyuz artık.',
  'Yeni komşun benim. Karşıdaki dükkân.',
  'Karşıdaki dükkân bana ait. Tanışalım.'
];
var RAKIP_SELAM = [
  'Yine ben. Sıkıldın mı benden?',
  'Kepenk açık, demek iş var.',
  'Geçerken uğradım. Bir bakayım dedim.',
  'Dün seni izledim. Fena değilsin.',
  'Karşıdan bakıyorum, tezgâh boş duruyor.'
];
/* Kabul edilirse / reddedilirse rakibin son sozu. */
var RAKIP_KABUL = [
  'Tamam. Akşam hesaplaşırız.',
  'Anlaştık. Kepenk inince görüşürüz.',
  'Sözün söz. Akşama bakarız.'
];
var RAKIP_RET = [
  'Korktun demek. Anlıyorum.',
  'Peki. Belki başka gün.',
  'Olsun. Ben yine gelirim.'
];
var RAKIP_CEKIL = [
  'Cevap yok. Ben gidiyorum.',
  'Meşgulsün galiba. Sonra konuşuruz.'
];
var FINE_MIN = 150, FINE_MAX = 400;   /* hijyen cezası (borca eklenir) */
var TRASH_PER_PEEL = 0.045;   /* bir patatesin kabukları */
var TRASH_PER_ITEM = 0.055; /* çöpe atılan her ürünün kirlilik payı */
var TRASH_PER_SALE = 0.012; /* her satışta doğal kirlenme */
var INSPECT_DAY = 4;        /* denetçi bu günden sonra gelebilir */
var INSPECT_CHANCE = 0.28;  /* o gün denetçi gelme olasılığı */
/* --- gece hırsızı --- */
var THIEF_DAY = 12;         /* bu günden sonra gece hırsız gelebilir */
var THIEF_CHANCE = 0.24;    /* güvenlik yokken gece ziyaret olasılığı */
var THIEF_MIN = 0.08, THIEF_MAX = 0.20;  /* paranın çalınan oranı */
/* --- Dayı'nın motoru --- */
var MOTO_DAY = 8;           /* bu günden sonra motor bozulabilir */
var MOTO_CHANCE = 0.055;    /* gün başında bozulma olasılığı */
/* --- evsiz misafir --- */
var HOMELESS_DAY = 5;       /* bu günden sonra gelebilir */
var HOMELESS_CHANCE = 0.30; /* o gün gelme olasılığı */
var LUCK_MAX = 6;           /* şans en fazla bu kadar birikir */
var LUCK_FIND_MIN = 50, LUCK_FIND_MAX = 200;
var DEBT_START = 5000000;   /* babadan kalan borç */
/* Borca giden pay dusuruldu (0.25 -> 0.18): oyuncunun elinde daha cok
   para kalsin, upgrade'ler daha erken alinabilsin. Kullanici: 'para
   kasmak biraz zor, insanlar oyundan sikabilir'. */
var DEBT_CUT = 0.18;        /* gün sonu kazancın borca giden oranı */


/* ---------- geliştirmeler ----------
   tag: dükkân ekranında fiyat etiketinin konumu (istasyona ok çizilir) */
var UPG = [
  {
    id: 'knife', name: 'Bıçak', desc: 'Döner daha kolay kesilir',
    st: 'spit', tag: [44, 60],
    lvName: ['Keskin bıçak', 'Çift taraflı bıçak', 'Profesyonel satır', 'Otomatik kesim makinesi'],
    lv: [{ p: 250 }, { p: 700 }, { p: 1800 }, { p: 4200 }]
  },
  {
    id: 'tongs', name: 'Servis Maşası', desc: 'Tek tıkta daha çok malzeme',
    st: 'meat', tag: [128, 92],
    lvName: ['Büyük maşa', 'Çift maşa', 'Porsiyon kepçesi'],
    lv: [{ p: 300 }, { p: 900 }, { p: 2200 }]
  },
  {
    id: 'pknife', name: 'Patates Bıçağı', desc: 'Hızlı doğrar, çuvaldan çok çıkar',
    st: 'cut', tag: [300, 132],
    lvName: ['Keskin bıçak', 'Doğrama aparatı', 'Dilimleme presi', 'Otomatik doğrayıcı'],
    lv: [{ p: 260 }, { p: 750 }, { p: 1900 }, { p: 4400 }]
  },
  {
    id: 'fryer', name: 'Fritöz', desc: 'Hızlı kızartma, geniş sepet',
    st: 'fryer', tag: [312, 62],
    lvName: ['Güçlü rezistans', 'Geniş sepet', 'Çift hazne', 'Otomatik fritöz'],
    lv: [{ p: 320 }, { p: 950 }, { p: 2300 }, { p: 5200 }]
  },
  {
    id: 'paper', name: 'Kağıt Makinesi', desc: 'Kağıdı makine takar',
    st: 'paper', tag: [204, 132],
    lvName: ['Kağıt makinesi', 'Otomatik sarma'],
    lv: [{ p: 450 }, { p: 1900 }]
  },
  {
    id: 'grill', name: 'Izgara', desc: 'Dürümü kızart, pahalı sat',
    st: 'grill', tag: [250, 100],
    lvName: ['Izgara', 'Hızlı ızgara', 'Çift ızgara', 'Otomatik ızgara'],
    lv: [{ p: 700 }, { p: 1700 }, { p: 3800 }, { p: 8000 }]
  },
  {
    id: 'drink', name: 'İçecek Standı', desc: 'Kola & Fanta sat',
    st: 'drinkM', tag: [232, 62],
    lvName: ['İçecek standı', 'Hızlı dolum', 'Basınçlı dolum', 'Otomatik dolum'],
    lv: [{ p: 600 }, { p: 1500 }, { p: 3400 }, { p: 7000 }]
  },
  {
    id: 'fbox', name: 'Patates Porsiyon', desc: 'Kutuda patates sat',
    st: 'fbox', tag: [386, 132],
    lvName: ['Porsiyon kutusu', 'Otomatik porsiyon'],
    lv: [{ p: 550 }, { p: 1800 }]
  },
  {
    id: 'ayran', name: 'Ayran Kazanı', desc: 'Ayran sat — stoktan doldurulur',
    st: 'ayran', tag: [268, 62],
    lvName: ['Ayran kazanı', 'Büyük kazan'],
    lv: [{ p: 800 }, { p: 2200 }]
  },
  {
    id: 'sweet', name: 'Tatlı Tepsisi', desc: 'Halka tatlısı sat',
    st: 'sweet', tag: [352, 152],
    lvName: ['Tatlı tepsisi', 'Şerbetli vitrin'],
    lv: [{ p: 1100 }, { p: 2900 }]
  },
  {
    id: 'garnish', name: 'Domates & Biber', desc: 'İskender yanına garnitür, tabak pahalanır',
    /* Garnitur YALNIZ iskender tabagina gidiyor; tabak yokken almak
       anlamsizdi. Once iskender acilmali. */
    gerek: 'iskender',
    st: 'garnish', tag: [226, 96],
    lvName: ['Domates & biber tepsisi', 'Büyük tepsi'],
    lv: [{ p: 1500 }, { p: 3800 }]
  },
  {
    id: 'sauce', name: 'Sos Standı', desc: 'Acı & sarımsak sos — dürüm daha pahalı',
    st: 'sauce', tag: [340, 112],
    lvName: ['Acı & sarımsak sos', 'Sarılmış dürüme de sos'],
    lv: [{ p: 900 }, { p: 3200 }]
  },
  {
    id: 'iskender', name: 'İskender Tabağı', desc: 'Pide + döner + tereyağı + yoğurt',
    st: 'board', tag: [156, 112],
    lvName: ['İskender tabağı', 'Hızlı porsiyon', 'Otomatik tabak'],
    lv: [{ p: 2200 }, { p: 5000 }, { p: 11000 }]
  },
  {
    id: 'board', name: 'Geniş Tezgâh', desc: 'Aynı anda 2–3 dürüm',
    st: 'board', tag: [124, 132],
    lvName: ['2 dürüm', '3 dürüm'],
    lv: [{ p: 700 }, { p: 2400 }]
  },
  {
    id: 'helper', name: 'Çırak', desc: 'Para toplar, stok doldurur, çöpü atar',
    st: 'crate', tag: [406, 96],
    lvName: ['Paraları toplar', 'Stok doldurur', 'Çöpü boşaltır'],
    lv: [{ p: 900 }, { p: 2800 }, { p: 6500 }]
  },
  {
    id: 'phone', name: 'Telefon & Motor', desc: 'Paket sipariş — çok daha kârlı',
    st: 'phone', tag: [24, 90],
    lvName: ['Telefon hattı + motor', 'Sık sipariş', 'Hızlı kurye'],
    lv: [{ p: 1300 }, { p: 3400 }, { p: 7500 }]
  },
  {
    id: 'uncle', name: 'Dayı', desc: 'Gün sonunda siparişi kurtarır',
    st: 'uncle', tag: [24, 148],
    lvName: ['1 kurtarma', '2 kurtarma', '4 kurtarma'],
    lv: [{ p: 550 }, { p: 1600 }, { p: 3800 }]
  },
  {
    id: 'store', name: 'Depo', desc: 'Daha çok turşu / yoğurt',
    st: 'crate', tag: [406, 62],
    lvName: ['Büyük kutu', 'Depo rafı', 'Soğuk oda'],
    lv: [{ p: 240 }, { p: 700 }, { p: 1700 }]
  },
  {
    id: 'security', name: 'Güvenlik', desc: 'Gece hırsızına karşı dükkânı koru',
    st: 'shutter', tag: [420, 45],
    lvName: ['Kepenk kilidi', 'Alarm sistemi', 'Güvenlik kamerası', 'Çelik kepenk + kayıt'],
    lv: [{ p: 700 }, { p: 2000 }, { p: 4800 }, { p: 9500 }]
  },
  {
    id: 'sign', name: 'Tabela & Reklam', desc: 'Çok müşteri, yüksek fiyat',
    st: 'wall', tag: [306, 44],
    lvName: ['Işıklı tabela', 'El ilanı', 'Şehir reklamı'],
    lv: [{ p: 480 }, { p: 1400 }, { p: 3200 }]
  },
  {
    id: 'expand', name: 'Dükkânı Büyüt', desc: 'Duvarı yık, sıra uzasın',
    st: 'wall', tag: [176, 62],
    lvName: ['+1 müşteri sırası', '+1 sıra daha', 'Geniş salon'],
    lv: [{ p: 1100 }, { p: 3000 }, { p: 6800 }]
  },
  {
    id: 'secim', name: 'Malzeme Seçimi', desc: 'Müşteri seçer, dürüm pahalanır',
    st: 'pickle', tag: [96, 45],
    lvName: ['Müşteri tercihi', 'Zor müşteriler'],
    lv: [{ p: 2600 }, { p: 6400 }]
  },
  {
    id: 'jenerator', name: 'Jeneratör', desc: 'Elektrik kesintisini kısaltır',
    st: 'grill', tag: [216, 45],
    lvName: ['Akü yedeği', 'Küçük jeneratör', 'Kesintisiz güç'],
    lv: [{ p: 1400 }, { p: 3800 }, { p: 8600 }]
  },
  {
    id: 'paint', name: 'Boya & Dekor', desc: 'Duvar rengi, müşteri sabrı',
    st: 'wall', tag: [96, 44],
    lvName: ['Mavi fayans', 'Yeşil fayans', 'Lüks turuncu'],
    lv: [{ p: 200 }, { p: 550 }, { p: 1200 }]
  }
];
function upgById(id) { for (var i = 0; i < UPG.length; i++) if (UPG[i].id === id) return UPG[i]; return null; }

/* ---------- seviye değerleri ---------- */
function UV(G, id) { return G.up[id] || 0; }
function LV(arr, n) { return arr[Math.min(n, arr.length - 1)]; }
var TUN = {
  /* et */
  meatPerClick: function (G) { return LV([1, 2, 3, 4], UV(G, 'tongs')); },
  shaveDist: function (G) { return LV([155, 120, 88, 60, 42], UV(G, 'knife')); },
  /* Iki dilim arasi EN AZ bu kadar sure gecmeli. Yoksa hizli suren
     oyuncu saniyede 20 dilim kesip otomatigi anlamsiz birakiyordu. */
  shaveCd: function (G) { return LV([0.50, 0.38, 0.30, 0.24, 0.18], UV(G, 'knife')); },
  /* Otomatik, elle kesmenin EN IYISINDEN hizli olmali (ve ellerini bosaltir) */
  autoShaveCd: function () { return 0.16; },
  autoShave: function (G) { return UV(G, 'knife') >= 4; },
  meatCap: function () { return 16; },
  /* patates */
  cutTime: function (G) { return LV([3.2, 2.3, 1.6, 1.0, 0.7], UV(G, 'pknife')); },
  cutYield: function (G) { return LV([26, 32, 40, 50, 62], UV(G, 'pknife')); },
  autoCut: function (G) { return UV(G, 'pknife') >= 4; },
  fryTime: function (G) { return LV([8.5, 6.5, 4.8, 3.4, 2.4], UV(G, 'fryer')); },
  fryCap: function (G) { return LV([26, 32, 40, 50, 62], UV(G, 'fryer')); },
  autoFry: function (G) { return UV(G, 'fryer') >= 4; },
  /* tepsi bir kızartmayı alacak kadar büyük: sepet boşalınca tepsi dolu görünür */
  friesCap: function () { return TUN.fryCap(G) + 6; },
  /* kağıt */
  paperTime: function (G) { return LV([0.85, 0.4, 0.2], UV(G, 'paper')); },
  autoPaper: function (G) { return UV(G, 'paper') >= 2; },
  /* ızgara */
  grillOn: function (G) { return UV(G, 'grill') >= 1; },
  grillTime: function (G) { return LV([0, 3.4, 2.5, 1.8, 1.2], UV(G, 'grill')); },
  /* Ayni anda kac dürüm sigar */
  grillCap: function (G) { return LV([0, 1, 2, 3, 4], UV(G, 'grill')); },
  /* Ilk iki seviyede izgara kontrolsuz: unutursan yanar.
     3. seviyeden itibaren isi ayari var, yanmaz. */
  grillYanar: function (G) { var v = UV(G, 'grill'); return v >= 1 && v <= 2; },
  /* Pistikten sonra yanmaya kac saniye var */
  grillYanmaSure: function (G) {
    var t = LV([0, 6, 8, 0, 0], UV(G, 'grill'));
    /* sicak dalgasinda izgara daha cabuk kavuruyor */
    return (G && G.weather === 'sicak') ? Math.round(t * .70) : t;
  },
  autoGrill: function (G) { return UV(G, 'grill') >= 4; },
  /* içecek */
  drinkOn: function (G) { return UV(G, 'drink') >= 1; },
  pourTime: function (G) { return LV([0, 3.2, 2.2, 1.3, 0.6], UV(G, 'drink')); },
  autoDrink: function (G) { return UV(G, 'drink') >= 4; },
  /* patates kutusu */
  fboxOn: function (G) { return UV(G, 'fbox') >= 1; },
  fboxTime: function (G) { return LV([0, 1.4, 0.5], UV(G, 'fbox')); },
  autoBox: function (G) { return UV(G, 'fbox') >= 2; },
  /* garnitür */
  garnishOn: function (G) { return UV(G, 'garnish') >= 1; },
  garnishMax: function (G) { return LV([0, 14, 26], UV(G, 'garnish')); },
  /* sos */
  sauceOn: function (G) { return UV(G, 'sauce') >= 1; },
  /* Otomatik sos KALDIRILDI (oyun kendi kafasina sos surmez).
     Sv2 artik: sarilmis dürüme de sos surulebilir. */
  sauceLate: function (G) { return UV(G, 'sauce') >= 2; },
  /* iskender */
  iskOn: function (G) { return UV(G, 'iskender') >= 1; },
  iskMeat: function (G) { return LV([ISK_MEAT, ISK_MEAT, 4, 4], UV(G, 'iskender')); },
  autoIsk: function (G) { return UV(G, 'iskender') >= 3; },
  /* ayran & tatlı */
  ayranOn: function (G) { return UV(G, 'ayran') >= 1; },
  sweetOn: function (G) { return UV(G, 'sweet') >= 1; },
  ayranMax: function (G) { return LV([0, 14, 26], UV(G, 'ayran')); },
  sweetMax: function (G) { return LV([0, 10, 20], UV(G, 'sweet')); },
  /* tezgâh */
  boards: function (G) { return LV([1, 2, 3], UV(G, 'board')); },
  /* çırak */
  autoCoin: function (G) { return UV(G, 'helper') >= 1; },
  autoStock: function (G) { return UV(G, 'helper') >= 2; },
  /* Cirak SERVIS YAPMAZ: musteriye urunu her zaman oyuncu verir.
     Otomatik servis oyunun ana isini elinden aliyordu. */
  autoTrash: function (G) { return UV(G, 'helper') >= 3; },
  /* telefon / kurye */
  phoneOn: function (G) { return UV(G, 'phone') >= 1; },
  phoneGap: function (G) { return LV([0, 42, 30, 22], UV(G, 'phone')); },
  /* Yagmurda yol uzar: motor yavaslar, teslimat gec doner. Oyuncuya
     ayrica soylenmiyor, ekranda gorup anliyor. */
  courierTime: function (G) {
    var t = LV([0, 13, 11, 7], UV(G, 'phone'));
    return (G && G.weather === 'rain') ? Math.round(t * 1.55) : t;
  },
  courierYavas: function (G) { return (G && G.weather === 'rain') ? 1.55 : 1; },
  /* ---- HAVA ----
     KAR  : musteri SEYREK gelir ama sabri yuksek ve bahsisi iyi -
            soguk gunde sicak yemek makbul.
     SICAK: kalabalik ama sabirsiz; izgara da daha cabuk yakar. */
  havaGelis: function (G) {                     /* musteri araligi carpani */
    if (!G) return 1;
    if (G.weather === 'kar') return 1.40;       /* daha seyrek */
    if (G.weather === 'sicak') return 0.86;     /* daha sik */
    return 1;
  },
  havaSabir: function (G) {
    if (!G) return 1;
    if (G.weather === 'kar') return 1.35;       /* uzun bekler */
    if (G.weather === 'sicak') return 0.80;     /* cabuk sinirlenir */
    return 1;
  },
  havaBahsis: function (G) { return (G && G.weather === 'kar') ? 1.45 : 1; },
  /* --- MALZEME SECIMI --- 0 kapali, 1 tek istek, 2 iki istek olabilir */
  secimOn: function (G) { return UV(G, 'secim') > 0; },
  secimEnCok: function (G) { return LV([0, 1, 2], UV(G, 'secim')); },
  /* Zahmetin karsiligi: dürüm basina fiyat farki. */
  secimZam: function (G) { return LV([0, 4, 7], UV(G, 'secim')); },
  /* --- MAC DALGASI --- kalabalik acele eder: sabri az, bahsisi bol. */
  macSabir: function (G) { return (G && G.macDalga) ? 0.72 : 1; },
  macBahsis: function (G) { return (G && G.macDalga) ? 1.55 : 1; },
  /* --- JENERATOR --- 0: yok, 3: kesinti hic olmaz */
  kesintiSure: function (G) { return LV([1, .62, .38, 0], UV(G, 'jenerator')) * KESINTI_SURE; },
  kesintiVar: function (G) { return UV(G, 'jenerator') < 3; },
  /* dayı */
  uncleUses: function (G) { return LV([0, 1, 2, 4], UV(G, 'uncle')); },
  /* depo */
  stockMax: function (G) { return LV([24, 40, 64, 100], UV(G, 'store')); },
  refillPer: function (G) { return LV([6, 9, 14, 22], UV(G, 'store')); },
  /* güvenlik */
  secLevel: function (G) { return UV(G, 'security'); },
  /* hırsızın gelme olasılığı ve soyma şansı seviyeye göre düşer */
  thiefVisit: function (G) { return LV([1, .72, .5, .32, .16], UV(G, 'security')) * THIEF_CHANCE; },
  thiefSteal: function (G) { return LV([.62, .42, .26, .13, .04], UV(G, 'security')); },
  secName: function (G) {
    var n = UV(G, 'security');
    return n === 0 ? '' : ['Kepenk kilidi', 'Alarm', 'Kamera', 'Çelik kepenk'][n - 1];
  },
  /* dükkân */
  patience: function (G) { return LV([1, 1.15, 1.3, 1.5], UV(G, 'paint')); },
  wallStyle: function (G) { return UV(G, 'paint'); },
  slots: function (G) { return LV([2, 3, 4, 5], UV(G, 'expand')); },
  priceMul: function (G) { return LV([1, 1.16, 1.34, 1.6], UV(G, 'sign')); },
  custMul: function (G) { return LV([1, 1.25, 1.5, 1.9], UV(G, 'sign')); }
};

/* ---------- gün ayarları ---------- */
function dayCfg(d, G) {
  /* Taban 60 sn (1:00). Her gun +2 sn, her upgrade seviyesi +2 sn.
     Ilk gun kisa ve ogretici; gelismis dukkanda gun uzuyor. */
  var len = Math.min(210, 60 + d * 2 + upgTotalLv(G) * 2);
  var rate = Math.max(2.0, 6.8 - d * 0.22) / TUN.custMul(G);
  return { len: len, rate: rate, slots: TUN.slots(G) };
}

/* ---------- sipariş üretimi ---------- */
function orderWrap(G) {
  var w = { kind: 'wrap' };
  if (TUN.sauceOn(G) && chance(.45)) w.sauce = chance(.6) ? 'hot' : 'garlic';
  /* MALZEME SECIMI: musterilerin bir kismi bir seyi ISTEMIYOR.
     Hepsi degil - istek disi dürüm de gelmeye devam etsin ki
     "yine mi ayni sey" hissi olusmasin. */
  if (TUN.secimOn(G) && chance(.55)) {
    var havuz = SECIM_MALZEME.slice();
    var kac = 1;
    if (TUN.secimEnCok(G) > 1 && chance(.30)) kac = 2;
    w.yok = [];
    for (var i = 0; i < kac && havuz.length; i++) {
      var j = Math.floor(Math.random() * havuz.length);
      w.yok.push(havuz.splice(j, 1)[0]);
    }
  }
  return w;
}
/* Siparis bu malzemeyi istemiyor mu? */
function siparisIstemez(ord, m) {
  return !!(ord && ord.yok && ord.yok.indexOf(m) >= 0);
}
function makeOrder(G) {
  /* Karne gunu: tek tip tayin — sade durum, yan urun yok. */
  if (typeof fermanDunya === 'function' && fermanDunya('karne')) {
    return [{ kind: 'wrap', sauce: null }];
  }
  var items = [TUN.iskOn(G) && chance(.26) ? { kind: 'plate' } : orderWrap(G)];
  var drinks = [];
  if (TUN.drinkOn(G)) { drinks.push('cola'); drinks.push('fanta'); }
  if (TUN.ayranOn(G)) drinks.push('ayran');
  /* SICAK dalgasinda icecek talebi patliyor: %40 -> %78.
     MAC dalgasinda da herkes yanina bir sey aliyor. */
  var icOran = (G && G.weather === 'sicak') ? .78 : ((G && G.macDalga) ? .70 : .40);
  if (drinks.length && chance(icOran)) items.push({ kind: 'drink', type: pick(drinks) });
  if (TUN.fboxOn(G) && chance(.30)) items.push({ kind: 'fbox' });
  if (TUN.sweetOn(G) && chance(.26) && items.length < 3) items.push({ kind: 'sweet' });
  return items;
}
function makePhoneOrder(G) {
  var items = [TUN.iskOn(G) && chance(.22) ? { kind: 'plate' } : orderWrap(G)];
  if (chance(.55)) items.push(orderWrap(G));
  var drinks = [];
  if (TUN.drinkOn(G)) { drinks.push('cola'); drinks.push('fanta'); }
  if (TUN.ayranOn(G)) drinks.push('ayran');
  if (drinks.length && chance((G && G.weather === 'sicak') ? .88 : .6)) items.push({ kind: 'drink', type: pick(drinks) });
  if (TUN.fboxOn(G) && chance(.4)) items.push({ kind: 'fbox' });
  if (TUN.sweetOn(G) && chance(.3)) items.push({ kind: 'sweet' });
  return items;
}
function itemPrice(it, G) {
  var v = 0;
  if (it.kind === 'wrap') {
    v = PRICE.wrap + (it.grilled ? PRICE.grillBonus : 0) + (it.sauce ? PRICE.sauceBonus : 0);
    /* Malzeme secimi acikken dürüm daha pahali: is daha zahmetli. */
    v += TUN.secimZam(G);
  }
  else if (it.kind === 'plate') {
    v = PRICE.iskender;
    if (it.tomato) v += PRICE.tomato;
    if (it.pepper) v += PRICE.pepper;
  }
  else if (it.kind === 'drink') v = (it.type === 'ayran' ? PRICE.ayran : PRICE.drink);
  else if (it.kind === 'fbox') v = PRICE.fbox;
  else if (it.kind === 'sweet') v = PRICE.sweet;
  return Math.round(v * TUN.priceMul(G));
}

/* ---------- müşteri repliği ---------- */
var LINES_WAIT = ['Acele et usta!', 'Çok acıktım…', 'Hızlı olsun abi', 'Ne kadar sürer?', 'Bekliyorum ha!', 'Kokusu güzel!'];
var LINES_HAPPY = ['Ellerine sağlık!', 'Efsane olmuş!', 'Bir numara!', 'Yine geleceğim', 'Harika döner!', 'Nefis!'];
var LINES_ANGRY = ['Çok beklettin!', 'Gidiyorum ben!', 'Rezalet!', 'Bir daha gelmem!', 'Yeter artık!'];
var LINES_CHEAP = ['Eksik kalmış be!', 'Bu ne ya, az koymuşsun', 'Yarım dürüm mü bu?', 'Parasını da yarım veririm', 'Doymadım ki!'];
var LINES_WRONG = ['Bu benim değil!', 'Yanlış sipariş!', 'Ben bunu istemedim'];
/* Ozel musteri kaliplarinin gelis repligi. Dizi/film repliklerinin
   BIREBIR kopyasi degil, ayni ruhta kendi cumlelerimiz: gorsellerde
   koydugumuz "isim/marka kullanma, sadece cagristir" kurali metin
   icin de gecerli - hatta metinde kopyalama daha net gorunur. */
var KALIP_REPLIK = {
  kuzeyli:  'Nöbet bitti. Ayaz bastırdı, sıcak bir şey iyi gider.',
  kimyager: 'Adımı bilmiyorsun ama siparişimi biliyorsun.',
  cirak:    'Süpürgeyi kapıya park ettim, çekmesinler.',
  kralice:  'Ejderhaları dışarı park ettim. Çabuk ol.',
  bilge:    'Sıra bende. Kimse öne geçemez.'
};
var LINES_SECIM = ['Ben böyle istememiştim!', 'Söylediğimi koymamışsın.',
  'Bunu istemiyordum ya…', 'Siparişimi dinlemedin.'];
var LINES_SAUCE = ['Sosunu unuttun!', 'Ben acılı istemiştim', 'Sos nerede usta?', 'Sossuz olur mu hiç?'];
var LINES_THIEF_WIN = ['Kasadan aldığını götürdü…', 'Kepengi zorlamış!', 'Gece dükkâna giren olmuş.'];
var LINES_THIEF_LOSE = ['Alarm çaldı, kaçtı!', 'Kepengi açamadı.', 'Kamerayı görünce kaçtı.', 'Kilide takıldı, gitti.'];
var LINES_MOTO = ['Motor çalışmıyor usta…', 'Dayı: "Marşa basıyorum, ses yok."', 'Motorun bujisi gitmiş.'];
var LINES_HOMELESS = ['Bir lokma… Allah razı olsun.', 'İki gündür bir şey yemedim.', 'Karnım çok aç usta…'];
var LINES_HOMELESS_OK = ['Allah bereket versin!', 'Elin dert görmesin.', 'Bunu unutmam usta.'];
var LINES_LUCK = ['Yolda para buldum usta!', 'Bak ne buldum!', 'Şansımız açık bugün.'];
var LINES_INSPECT_OK = ['Tertemiz, helal olsun!', 'Böyle devam usta.', 'Not: temiz mutfak.'];
var LINES_INSPECT_BAD = ['Bu ne pislik böyle!', 'Çöpler taşmış, ceza yazıyorum.', 'Hijyen sıfır. Ceza!'];
var POSTERS = ['Yok', 'Halı', 'Döner Afişi', 'Babanın Fotoğrafı'];
var COUNTER_STYLES = ['Çelik', 'Mavi', 'Ahşap', 'Bakır'];
var TIPS_LOAD = [
  'Dönerin üstünde imleci yukarı-aşağı gezdir, et kesilir.',
  'Dürümü sarmak için aşağıdan yukarı sürükle.',
  'Turşu ve yoğurt çabuk biter — kutudan doldurmayı unutma.',
  'Bir patates yaklaşık 6 dürümlük kızartma çıkarır.',
  'Dürümü önce sar, sonra ızgaraya at.',
  'Telefon çalarsa aç — paket sipariş çok daha kârlı.',
  'Upgrade aldıkça işler otomatikleşir.',
  'Sos şişesine bas — dürüm daha pahalı satılır.',
  'İskender: pide al → tahtada doğra → döner → tereyağı → yoğurt.',
  'Garnitür (domates + biber) iskenderi daha pahalı yapar.',
  'Tabela ve dükkân büyütme daha çok müşteri getirir.',
  'Kola, fanta ve ayran ayrı musluklardır — üçünü aynı anda doldurabilirsin.',
  'Şube açmak için önce dükkânı geliştir; şube geliri günlük performansına bağlıdır.',
  'Gün başında tepsiler boştur — önce kutudan stok doldur.'
];


/* ============================================================
   ŞUBELER — geç oyun ekonomisi
   Tezgâhta kazandığın parayla şehre şube açarsın. Her şube her
   gün kendi kazancını getirir; ama getirisi o günkü dükkân
   performansına bağlıdır (müşteri kaçırırsan şubeler de düşer).
   Tezgâh fiyatları hiç değişmez; bu tamamen ayrı bir katman.
   ============================================================ */
/* Şube merdiveni. Fiyat kademeli olarak sertleşir ve geri ödeme süresi
   de uzar (ilk şube ~1.5 günde, son şube ~2.2 günde kendini öder), yani
   her basamak bir öncekinden daha ciddi bir yatırım kararıdır.
   Adlar i18n tablosundan çevrilir. */
var BRANCH = [
  /* DENGE (2026-08-29): ilk sube 900 cok ucuzdu, birkac gunde aciliyordu.
     Fiyatlar ~4x, gelirler ~0.62x, upgrade gereksinimleri +4/+5 seviye.
     Amac: sehirlere erken tasinmamak, zinciri hak ederek kurmak. */
  { name: 'İSTANBUL', p: 5000,     inc: 620,     req: 9,  desc: 'Vapur iskelesinin yanı, sabahtan akşama kuyruk.' },
  { name: 'BERLİN',   p: 12000,    inc: 1950,    req: 14, desc: 'Dönerin ikinci vatanı. Burada iddia büyük.' },
  { name: 'LONDRA',   p: 27000,    inc: 5400,    req: 19, desc: 'Gece yarısı bile kapanmayan bir köşe.' },
  { name: 'MANİLA',   p: 48000,    inc: 9800,    req: 23, desc: 'Sokak yemeği başkenti — kuyruk hiç bitmez.' },
  { name: 'PARİS',    p: 88000,   inc: 17500,   req: 27, desc: 'Küçük bir dükkân, çok titiz bir şehir.' },
  { name: 'DUBAİ',    p: 220000,   inc: 56000,   req: 32, desc: 'Gökdelenlerin altında, turist akını.' },
  { name: 'TOKYO',    p: 600000,  inc: 180000,  req: 38, desc: 'Titizliğin ödüllendirildiği tek şehir.' },
  { name: 'NEW YORK', p: 1500000,  inc: 570000,  req: 44, desc: 'Zincirin tacı. Uyumayan şehirde döner.' },
  /* Bütün şubeler açıldıktan sonra girilen AYRI MOD: her gün ferman var. */
  { name: 'DEMİRKENT', p: 2500000, inc: 780000,  req: 52, ferman: true,
    desc: 'Yönetim her sabah ferman yayınlar. Kurala uymayan dükkân kapanır.' }
];
/* Şube açmak için dükkânın kendisi de gelişmiş olmalı. Toplam upgrade
   seviyesi 65; bir şube "req" kadar seviye ister. Böylece oyun kendi
   sırasını korur: önce elinle yap, geliştir, sonra zinciri kur. */
function upgTotalLv(g) {
  var n = 0;
  for (var i = 0; i < UPG.length; i++) n += (g.up[UPG[i].id] || 0);
  return n;
}
function branchLocked(i, g) {
  return upgTotalLv(g) < BRANCH[i].req;
}
/* ============================================================
   FERMANLAR — Demirkent modu
   tip: 'musteri' -> o gun bu musteriye satis yasak (X'e basip gonder)
        'urun'    -> o gun bu urun hic satilamaz
   test(): musteri ya da urun icin true donerse YASAK demektir.
   ============================================================ */
var FERMAN_CEZA_SINIR = 10;     /* bu kadar ihlalde dukkan kapanir */
/* 3'te kapatmak cok sertti: bir gun ~30 musteri, yasaklarin her biri
   musterilerin %12-21'ini tutuyor. Oyuncu kurali ogrenmeden gun
   bitiyordu. 10, hatayi affeder ama umursamazligi affetmez. */
var FERMAN_CEZA_PARA = 310;     /* her ihlalde kesilen ceza */
var FERMANLAR = [
  { id: 'gozluk', tip: 'musteri', metin: 'Gözlüklüye satış yasak',
    test: function (c) { return c.look && c.look.acc === 'glasses'; } },
  { id: 'sapka', tip: 'musteri', metin: 'Şapkalıya satış yasak',
    test: function (c) { return c.look && c.look.acc === 'cap'; } },
  { id: 'sakal', tip: 'musteri', metin: 'Sakallıya satış yasak',
    test: function (c) { return c.look && (c.look.acc === 'beard' || c.look.mustache); } },
  { id: 'cocuk', tip: 'musteri', metin: 'Çocuğa satış yasak',
    test: function (c) { return c.look && c.look.tip === 'cocuk'; } },
  { id: 'kirmizi', tip: 'musteri', metin: 'Kırmızı giyene satış yasak',
    test: function (c) { return c.look && /^#c9|^#c0|^#e2[34]/.test(c.look.shirtCol || ''); } },
  { id: 'aci', tip: 'urun', metin: 'Acı sos yasak',
    test: function (it) { return it && it.sauce === 'hot'; } },
  { id: 'sarimsak', tip: 'urun', metin: 'Sarımsak sosu yasak',
    test: function (it) { return it && it.sauce === 'garlic'; } },
  { id: 'patates', tip: 'urun', metin: 'Patates satışı yasak',
    test: function (it) { return it && it.kind === 'fbox'; } },
  { id: 'icecek', tip: 'urun', metin: 'İçecek satışı yasak',
    test: function (it) { return it && it.kind === 'drink'; } },
  { id: 'tatli', tip: 'urun', metin: 'Tatlı satışı yasak',
    test: function (it) { return it && it.kind === 'sweet'; } },
  { id: 'iskender', tip: 'urun', metin: 'İskender satışı yasak',
    test: function (it) { return it && it.kind === 'plate'; } },
  /* --- DUNYA FERMANLARI: satisi yasaklamaz, gunu degistirir ---
     Ihlal uretmezler; halkin gorunusunu ya da gunun akisini degistirirler.
     Gun boyu surer, ertesi gun kalkar. */
  { id: 'tekTip', tip: 'dunya', metin: 'Herkes devletin tulumunu giyecek' },
  { id: 'bassiz', tip: 'dunya', metin: 'Baş örtmek yasak' },
  { id: 'tras',   tip: 'dunya', metin: 'Traş mecburiyeti' },
  { id: 'sokak',  tip: 'dunya', metin: 'Sokağa çıkma kısıtlaması' },
  { id: 'kurye',  tip: 'dunya', metin: 'Motorlu kuryelere çıkma yasağı' },
  /* Kurye yasaginin tersi: hat acik ama HER cagriya cevap zorunlu. */
  { id: 'telefon', tip: 'dunya', metin: 'Her siparişe cevap verilecek' },
  /* Karne gunu: herkes ayni tayini alir, yan urun yok. */
  { id: 'karne',   tip: 'dunya', metin: 'Herkese tek tip tayın verilecek' }
];
/* Dunya fermani X ile musteri fermani Y ayni gun cikarsa gun oynanamaz
   hale gelir (ornegin herkes tulum giyerken 'kirmizi giyene satma').
   fermanSec bu ciftleri asla birlikte secmez. */
var FERMAN_CAKISMA = {
  /* Hat hem kapali hem zorunlu olamaz. */
  kurye: ['telefon'], telefon: ['kurye'],
  tekTip: ['kirmizi'], kirmizi: ['tekTip'],
  bassiz: ['sapka'],   sapka:   ['bassiz'],
  tras:   ['sakal'],   sakal:   ['tras']
};
/* Gazete manseti: ferman kimligine gore. Evreni buyutur. */
var FERMAN_MANSET = {
  gozluk:   'CAM, HALKIN GÖZÜNÜ BOZUYOR',
  sapka:    'BAŞ ÖRTMEK GİZLENMEKTİR',
  sakal:    'TIRAŞ, İTAATİN İLK ŞARTIDIR',
  cocuk:    'ÇOCUK MİDESİ DEVLETİN EMANETİ',
  kirmizi:  'KIRMIZI, HUZURU BOZAN RENKTİR',
  aci:      'ACI, HALKI ÖFKELENDİRİYOR',
  sarimsak: 'SARIMSAK KOKUSU YASAKLANDI',
  patates:  'PATATES STOKLARI DEVLETİNDİR',
  icecek:   'SU İÇMEK YETERLİDİR',
  tatli:    'TATLI, TEMBELLİĞE YOL AÇAR',
  iskender: 'İSKENDER, LÜKS SAYILDI',
  tekTip:   'TEK TİP, TEK YÜREK',
  bassiz:   'AÇIK BAŞ, AÇIK VİCDAN',
  tras:     'SAKAL, ARKASINA SAKLANILAN PERDEDİR',
  sokak:    'SOKAK, GEREKSİZ KALABALIKTAN ARINDIRILDI',
  kurye:    'MOTOR GÜRÜLTÜSÜ HALKI RAHATSIZ EDİYOR',
  telefon:  'HİÇBİR VATANDAŞ CEVAPSIZ BIRAKILAMAZ',
  karne:    'TAYIN SİSTEMİ BUGÜN UYGULANACAK'
};
/* ============================================================
   GAZETE HABERLERI — rejimin gunluk kucuk haberleri
   Ferman degil: oyunu etkilemez, evreni kurar. Her gun ucu secilir,
   gun numarasindan turetildigi icin ayni gun ayni haberler cikar.
   ============================================================ */
var FERMAN_HABER = [
  ['ET TAYINI YENİDEN DÜZENLENDİ', 'Kişi başı haftalık pay yüzde altı azaltıldı.'],
  ['SINIRDA HUZUR HÂKİM', 'Komşu devletin iddiaları kesin olarak yalanlandı.'],
  ['FABRİKA REKOR KIRDI', 'Üretim hedefinin yüzde yüz dördüne ulaşıldı.'],
  ['GECE YÜRÜYÜŞÜ ERTELENDİ', 'Tören, hava şartları nedeniyle haftaya alındı.'],
  ['YENİ KÖPRÜ HİZMETE GİRDİ', 'Açılış törenine katılım zorunludur.'],
  ['EKMEK KUYRUĞU KISALDI', 'Ortalama bekleme süresi iki saate indi.'],
  /* Bu haber GERCEK bir etki tasir: o gun paket hatti kapali. Gazete ile
     oyunun celismemesi icin (bkz. haberEtki). */
  ['TELEFON HATLARI BAKIMDA', 'Bugün hiçbir sipariş telefonu bağlanmıyor.', 'telefonKapali'],
  ['KAYIP İLANI', 'Bilgi verenler devletçe ödüllendirilecektir.'],
  ['KÖMÜR DAĞITIMI BAŞLIYOR', 'Kupon sırası yarın saat on dörtte açıklanacak.'],
  ['OKULLARA YENİ DERS', 'Ferman Bilgisi müfredata eklendi.'],
  ['TREN SEFERLERİ AZALTILDI', 'Gereksiz seyahat, üretimden çalınan zamandır.'],
  ['SU KESİNTİSİ DUYURUSU', 'Bakım çalışması üç gün sürecektir.'],
  ['HALK KOROSU KURULDU', 'Katılım gönüllüdür; devamsızlık kayda geçer.'],
  ['KİRA TARİFESİ GÜNCELLENDİ', 'Dükkân kiralarına yüzde dokuz zam yapıldı.'],
  ['MEYDANDA TOPLU JİMNASTİK', 'Bütün esnaf saat altıda hazır bulunacaktır.'],
  ['İTHALAT DURDURULDU', 'Yerli üretim halkın ihtiyacına fazlasıyla yeter.'],
  ['SAAT İLERİ ALINDI', 'Gün ışığından daha uzun süre yararlanılacak.'],
  ['HAVA RAPORU', 'Yarın soğuk; ısınma kuponları sınırlı sayıdadır.'],
  ['MADALYA TÖRENİ YAPILDI', 'Üç işçiye Devlet Nişanı takdim edildi.'],
  ['SOKAK HAYVANI GÖRÜLMEDİ', 'Şehir temizliği çalışmaları tamamlandı.'],
  ['RADYO YAYINI UZATILDI', 'Akşam kuşağı bir saat daha sürecek.'],
  ['PASAPORT İŞLEMLERİ', 'Yeni başvuru şimdilik alınmamaktadır.'],
  ['DÖNER USTALARI TESCİLLENDİ', 'Belgesiz şiş çevirmek yasaklandı.'],
  ['UN FİYATI SABİTLENDİ', 'Fiyat artıran esnaf hakkında işlem yapılacaktır.']
];
/* Liderin gunluk vecizesi — gazetenin alt kosesinde durur. */
var LIDER_SOZ = [
  'Çalışan halk, düşünmeye vakit bulamayan halktır.',
  'Sabır, devletin vatandaşa en büyük armağanıdır.',
  'Şikâyet eden, henüz yeterince çalışmamıştır.',
  'Bir milletin gücü, sorduğu soruların azlığıyla ölçülür.',
  'Ekmek bölünür, itaat bölünmez.',
  'Kapısı açık dükkân, kalbi açık vatandaştır.',
  'Düzen, herkesin yerini bilmesidir.',
  'Bugün fedakârlık, yarın yine fedakârlık.',
  'Az konuşan çok üretir.',
  'Devlet görür, devlet bilir, devlet unutmaz.',
  'Kuyruğa girmek, düzene girmektir.',
  'Boş vakit, düşmanın en sadık dostudur.'
];
function liderSozu(gun) {
  return LIDER_SOZ[Math.floor(hash1(gun * 9.13 + 2.7) * LIDER_SOZ.length)];
}
/* Gazetenin kunyesindeki hava satiri — gunden turetilir. */
/* 'kapalı' sozlukte zaten var (kapali dukkan) — cakismasin diye 'bulutlu'. */
var GAZETE_HAVA = ['açık', 'bulutlu', 'sisli', 'yağmurlu', 'soğuk', 'rüzgârlı'];
function gazeteHava(gun) {
  return GAZETE_HAVA[Math.floor(hash1(gun * 4.41 + 1.3) * GAZETE_HAVA.length)];
}
function gazeteDerece(gun) {
  return -6 + Math.floor(hash1(gun * 6.19 + 5.5) * 18);
}

/* Bugunku haberlerden biri bu etkiyi tasiyor mu?
   Haberler yalnizca dekor degil: bazilari gunu degistirir. */
function haberEtki(etki, gun) {
  var g = (gun === undefined && typeof G !== 'undefined') ? G.day : gun;
  var h = haberSec(g, 3);
  for (var i = 0; i < h.length; i++) if (h[i][2] === etki) return true;
  return false;
}
/* Gunun haberleri: gun numarasindan turetilir, ayni gun ayni haber. */
function haberSec(gun, adet) {
  adet = adet || 3;
  var out = [], kul = {};
  for (var i = 0; i < adet; i++) {
    var idx = Math.floor(hash1(gun * 3.11 + i * 13.7) * FERMAN_HABER.length);
    var g = 0;
    while (kul[idx] && g++ < FERMAN_HABER.length) idx = (idx + 1) % FERMAN_HABER.length;
    kul[idx] = 1;
    out.push(FERMAN_HABER[idx]);
  }
  return out;
}
/* Kac ferman cikacak? Demirkent'te gecirilen gune gore artar: ilk gunler
   tek yasak, sonra iki, ileride uce cikar. Nefes alacak gunler kalir. */
function fermanAdet(fgun, gun) {
  fgun = fgun || 0;
  if (fgun < 3) return 1;
  if (fgun < 8) return (gun % 2 === 0) ? 2 : 1;
  if (fgun < 16) return (gun % 3 === 0) ? 3 : ((gun % 2) ? 1 : 2);
  return (gun % 3 === 0) ? 3 : 2;
}

/* O gunun fermanlarini sec (gun numarasindan turetilir: ayni gun ayni ferman) */
function fermanSec(gun, adet) {
  /* adet verilmezse Demirkent'te gecirilen gune gore hesaplanir; gazete ve
     startDay AYNI degeri kullanmali, yoksa gazete baska yasak gosterir. */
  var n = adet || fermanAdet((typeof G !== 'undefined' ? G.fgun : 0), gun);
  var out = [], kullanildi = {};
  /* Secilen ferman, zaten secilmis biriyle cakisiyor mu?
     (ornegin herkes tulum giyerken 'kirmizi giyene satma' -> gun oynanmaz) */
  function uygun(f) {
    if (f.tip === 'dunya' && dunyaVar) return false;   /* gunde en fazla bir dunya fermani */
    var c = FERMAN_CAKISMA[f.id];
    if (!c) return true;
    for (var q = 0; q < out.length; q++) if (c.indexOf(out[q].id) >= 0) return false;
    return true;
  }
  var dunyaVar = false;
  for (var i = 0; i < n; i++) {
    var idx = Math.floor(hash1(gun * 7.3 + i * 19.7) * FERMANLAR.length);
    var guard = 0;
    while ((kullanildi[idx] || !uygun(FERMANLAR[idx])) && guard++ < FERMANLAR.length)
      idx = (idx + 1) % FERMANLAR.length;
    if (kullanildi[idx] || !uygun(FERMANLAR[idx])) continue;   /* uygun kalmadi */
    kullanildi[idx] = 1;
    if (FERMANLAR[idx].tip === 'dunya') dunyaVar = true;
    out.push(FERMANLAR[idx]);
  }
  return out;
}
/* Bugun bu DUNYA fermani yururlukte mi? */
function fermanDunya(id) {
  var F = (typeof G !== 'undefined') && G.ferman;
  if (!F) return false;
  for (var i = 0; i < F.liste.length; i++) if (F.liste[i].id === id) return true;
  return false;
}
/* ============================================================
   DEMIRKENT EKONOMISI — ana oyundan TAMAMEN ayri
   Kendi kasasi, kendi gun sayaci. Sube geliri ve borc taksiti burada
   islemez; kazanc gunun giderlerine gider. Amac: para kazanmak zor olsun,
   her gun "neyi odemeyecegim" karari cikssin.
   ============================================================ */
/* --- LIDER ZIYARETI ---
   Nadir ve deterministik: gun numarasindan turetilir ki gazete ile oyun
   ayni gunu soylesin. Ilk gunlerde yok (oyuncu once modu ogrensin). */
var LIDER_ILK_GUN = 4;          /* bu Demirkent gununden once gelmez */
var LIDER_ODUL = 3100;          /* memnun ayrilirsa */
var LIDER_CEZA = 3;             /* kizarsa yazilan ihlal sayisi */
function liderGunu(fgun, gun) {
  if ((fgun || 0) < LIDER_ILK_GUN) return false;
  return hash1(gun * 5.77 + 3.1) < 0.09;      /* ~11 gunde bir */
}
var FP_BASLANGIC = 1480;       /* moda ilk giriste verilen kasa (bir gunluk gider payi) */
var FP_BATIK_SINIR = 3;        /* ust uste bu kadar gun eksideysen tahliye */
/* --- EV KADEMELERI ---
   kira    : gunluk taban kira (fgun ile artar)
   pesinat : tasinma bedeli, bir kerelik
   isinma  : isinma giderinin carpani (yalitim)
   hasta   : hastalanma riskinin carpani (rutubet/soguk)
   Ust kademeler pahali ama gunluk yuku hafifletir; asil odul guvenlik. */
/* Kira araligi DAR (240 -> 790): kira hep odenebilir kalmali, yoksa ust
   daire tuzaga doner. Asil duvar PESINAT. Ust daire kendini amorti eder:
   isinma + ilac tasarrufu, kira artisindan buyuktur. */
var EVLER = [
  { ad: 'Bodrum katı',      kira: 295, pesinat: 0,       isinma: 1.55, hasta: 1.75 },
  { ad: 'Arka sokak odası', kira: 370, pesinat: 5550,    isinma: 1.25, hasta: 1.35 },
  { ad: 'İşçi bloğu',       kira: 455, pesinat: 14800,   isinma: 1.00, hasta: 1.00 },
  { ad: 'Devlet lojmanı',   kira: 545, pesinat: 34600,   isinma: 0.76, hasta: 0.68 },
  { ad: 'Merkez apartmanı', kira: 615, pesinat: 74000,   isinma: 0.55, hasta: 0.42 },
  { ad: 'Parti konutu',     kira: 690, pesinat: 101000,  isinma: 0.38, hasta: 0.22 }
];
function evSimdiki() { return EVLER[clamp(G.ev || 0, 0, EVLER.length - 1)]; }
/* Gider rampasi bir yerde DURMALI: gelir sabitken dik bir rampa her kosuyu
   ayni gunde bitiriyor ve ev merdiveni hic oynanamiyordu. Gec oyunun
   baskisi fermanlardan ve olaylardan gelir. */
var FGUN_TAVAN = 45;
function fgunEtki(fgun) { return Math.min(fgun || 0, FGUN_TAVAN); }
/* Kira SABIT: kademeye bagli, gune degil. Yukselmenin bedeli pesinattir;
   kirayi da rampalayinca yukselmek ekonomik olarak kotu karar oluyordu. */
function evKira() { return evSimdiki().kira; }

var HANE_UYE = [
  { id: 'es',   ad: 'Eş' },
  { id: 'ogul', ad: 'Oğul' },
  { id: 'kiz',  ad: 'Kız' },
  { id: 'anne', ad: 'Anne' }
];
/* Gider kalemleri. zorunlu olanlar kapatilamaz; digerleri oyuncunun
   secimi — atlamak para birakir ama bedeli hane halkina odenir. */
/* Rakamlar tools/sim.js olcumune gore secildi: tam upgrade'li tezgah
   gunde ~$2.800 kazandiriyor. Ayrintili gerekce icin dosya basindaki
   yorum blokina bak. Tezgah FIYATLARI degismez — zorluk giderden gelir. */
var GIDER = [
  { id: 'dukkan', ad: 'Dükkân kirası',  zorunlu: true,  temel: 642, artis: 5 },
  /* 'ev' kaleminin tutari EVLER tablosundan gelir (giderTutar'a bak). */
  { id: 'ev',     ad: 'Ev kirası',      zorunlu: true,  temel: 420, artis: 6, evBagli: true },
  { id: 'yemek',  ad: 'Yemek',          zorunlu: false, temel: 105, artis: 0.9, kisiBasi: true },
  { id: 'isinma', ad: 'Isınma',         zorunlu: false, temel: 216, artis: 2.5 },
  { id: 'ilac',   ad: 'İlaç',           zorunlu: false, temel: 296, artis: 5, hastaGerek: true }
];
/* Tam upgrade'li iyi bir gunun kazanci — denge testinin dayanagi.
   sim.js gun 170-183 arasi: 54 siparis, $2.683-2.902. */
/* Fiyatlar 2026-09-02'de x1.235 artinca yeniden olculdu (tools/sim.js
   ortalama siparis 39.3 -> 48.5). Demirkent giderleri de ayni oranda
   olceklendi ki modun zorlugu ve ev merdiveni egrisi degismesin. */
var FP_IYI_GUN = 3450;
function giderTutar(g, fgun, kisi) {
  /* Ev kirasi oturulan daireye gore; isinma da evin yalitimina gore. */
  if (g.evBagli) return evKira(fgun);
  var t = g.temel + Math.round(g.artis * fgunEtki(fgun));
  if (g.id === 'isinma') t = Math.round(t * evSimdiki().isinma);
  if (g.kisiBasi) t *= Math.max(0, kisi || 0);
  return t;
}
function haneKur() {
  return HANE_UYE.map(function (u) { return { id: u.id, ad: u.ad, ac: 0, hasta: 0, gitti: false }; });
}
function haneCanli(h) {
  var n = 0;
  for (var i = 0; i < (h || []).length; i++) if (!h[i].gitti) n++;
  return n;
}
function haneHasta(h) {
  var n = 0;
  for (var i = 0; i < (h || []).length; i++) if (!h[i].gitti && h[i].hasta > 0) n++;
  return n;
}
function fermanSehri(g) {
  var i = (g && typeof g.city === 'number') ? g.city : -1;
  return i >= 0 && i < BRANCH.length && !!BRANCH[i].ferman;
}
var BR_MIN = 0.35;          /* boş gün: şube geliri bu kadara düşer */
var BR_MAX = 1.15;          /* kusursuz gün: bu kadar çıkar */

/* açılabilecek sıradaki şube (hepsi alındıysa null) */
function nextBranch(g) {
  var n = (g.branch || 0);
  return n < BRANCH.length ? BRANCH[n] : null;
}
/* sahip olunan şubelerin toplam taban geliri */
function branchBase(g) {
  var n = (g.branch || 0), t = 0;
  for (var i = 0; i < n && i < BRANCH.length; i++) t += BRANCH[i].inc;
  return t;
}
/* Bir günün şube performansı. İki şey birden ölçülür:
     hacim  — o gün gerçekten ne kadar sattın (tezgâhı boş bırakırsan düşer)
     memnun — gelen müşterinin ne kadarını yetiştirdin
   Böylece şubeler bedava para basmaz; dükkânı çalıştırmak zorundasın. */
function branchPerf(served, lost, day, g) {
  var tot = served + lost;
  var memnun = tot > 0 ? served / tot : 0;
  var hacim = memnun;
  if (day) {
    var cfg = dayCfg(day, g || { up: {} });
    var hedef = Math.max(5, Math.floor((cfg.len - 25) / cfg.rate * 0.35));
    hacim = clamp(served / hedef, 0, 1);
  }
  /* hacim belirleyici; memnuniyet onu yükseltir. Tezgâhı boş bırakırsan
     "hiç müşteri kaçırmadım" demenin bir anlamı kalmaz. */
  return BR_MIN + (BR_MAX - BR_MIN) * hacim * (0.55 + 0.45 * memnun);
}
