/* ============================================================
   BABAMIN DÖNERCİSİ — basarim.js
   BASARIMLAR. Tek bir tablo hem oyun ici basarim ekranini besler
   hem de magaza kimliklerini uretir:
     Steam            -> ACH_<ID>            (API name)
     Game Center      -> <bundle>.ach.<id>   (achievement identifier)
     Google Play      -> ayni id, konsolda eslenir
   `tools/basarimlar.js` bu tablodan magazalara yuklenecek listeleri
   dokuyor; tablo tek kaynaktir, iki yerde elle guncellenmez.

   Metinler oyunun genel duzenine uyar: `ad`/`ac` Turkce KAYNAK metindir,
   Ingilizcesi js/i18n.js icindeki EN sozlugunde durur ve T() ile alinir.
   Yeni basarim eklerken iki satiri da sozluge eklemeyi unutma —
   tools/basarimlar.js eksik ceviriyi hata olarak bildirir.
   ============================================================ */
'use strict';

var BS_BUNDLE = 'com.babamindonercisi.game';

/* oku(S, G) o an ki ILERLEMEYI dondurur; hedef'e ulasinca acilir.
   S = G.stats (kalici toplamlar), G = oyun durumu. */
var BASARIM = [
  /* ---------------- SERVIS ---------------- */
  { id: 'ilk_durum', grup: 'servis', ikon: 'wrap', kademe: 1, hedef: 1,
    ad: 'İlk Dürüm',
    ac: 'İlk dürümünü sat.',
    oku: function (S) { return S.wraps || 0; } },
  { id: 'durum_100', grup: 'servis', ikon: 'wrap', kademe: 1, hedef: 100,
    ad: 'Tezgâhın Sahibi',
    ac: '100 dürüm sat.',
    oku: function (S) { return S.wraps || 0; } },
  { id: 'durum_1000', grup: 'servis', ikon: 'wrap', kademe: 2, hedef: 1000,
    ad: 'Bin Dürüm',
    ac: '1000 dürüm sat.',
    oku: function (S) { return S.wraps || 0; } },
  { id: 'durum_10000', grup: 'servis', ikon: 'wrap', kademe: 3, hedef: 10000,
    ad: 'Dürüm Efsanesi',
    ac: '10.000 dürüm sat.',
    oku: function (S) { return S.wraps || 0; } },
  { id: 'ilk_iskender', grup: 'servis', ikon: 'iskender', kademe: 1, hedef: 1,
    ad: 'Tereyağı Kokusu',
    ac: 'İlk İskender tabağını çıkar.',
    oku: function (S) { return S.isk || 0; } },
  { id: 'iskender_500', grup: 'servis', ikon: 'iskender', kademe: 2, hedef: 500,
    ad: 'İskender Ustası',
    ac: '500 İskender tabağı çıkar.',
    oku: function (S) { return S.isk || 0; } },
  { id: 'icecek_1000', grup: 'servis', ikon: 'cola', kademe: 2, hedef: 1000,
    ad: 'Buzlu Servis',
    ac: '1000 içecek sat.',
    oku: function (S) { return S.drinks || 0; } },
  { id: 'patates_500', grup: 'servis', ikon: 'fbox', kademe: 2, hedef: 500,
    ad: 'Kızartma Kralı',
    ac: '500 porsiyon patates sat.',
    oku: function (S) { return S.boxes || 0; } },
  { id: 'tatli_250', grup: 'servis', ikon: 'sweet', kademe: 2, hedef: 250,
    ad: 'Tatlı Kaçamağı',
    ac: '250 tatlı sat.',
    oku: function (S) { return S.sweets || 0; } },
  { id: 'gun_40_musteri', grup: 'servis', ikon: 'meat', kademe: 2, hedef: 40,
    ad: 'Yoğun Gün',
    ac: 'Tek günde 40 ürün sat.',
    oku: function (S) { return S.gunEnCok || 0; } },

  /* ---------------- PARA ---------------- */
  { id: 'ilk_bin', grup: 'para', ikon: 'coin', kademe: 1, hedef: 1000,
    ad: 'İlk Bin',
    ac: 'Toplam $1.000 kazan.',
    oku: function (S) { return S.earned || 0; } },
  { id: 'kazanc_100k', grup: 'para', ikon: 'coin', kademe: 2, hedef: 100000,
    ad: 'Yüz Bin',
    ac: 'Toplam $100.000 kazan.',
    oku: function (S) { return S.earned || 0; } },
  { id: 'kazanc_1m', grup: 'para', ikon: 'coin', kademe: 3, hedef: 1000000,
    ad: 'Milyoner',
    ac: 'Toplam $1.000.000 kazan.',
    oku: function (S) { return S.earned || 0; } },
  { id: 'kazanc_10m', grup: 'para', ikon: 'coin', kademe: 3, hedef: 10000000,
    ad: 'On Milyon',
    ac: 'Toplam $10.000.000 kazan.',
    oku: function (S) { return S.earned || 0; } },
  { id: 'gun_1000', grup: 'para', ikon: 'coin', kademe: 1, hedef: 1000,
    ad: 'İyi Gün',
    ac: 'Tek günde $1.000 kazan.',
    oku: function (S) { return S.best || 0; } },
  { id: 'gun_5000', grup: 'para', ikon: 'coin', kademe: 2, hedef: 5000,
    ad: 'Harika Gün',
    ac: 'Tek günde $5.000 kazan.',
    oku: function (S) { return S.best || 0; } },
  { id: 'gun_15000', grup: 'para', ikon: 'star', kademe: 3, hedef: 15000,
    ad: 'Rekor Gün',
    ac: 'Tek günde $15.000 kazan.',
    oku: function (S) { return S.best || 0; } },
  { id: 'bahsis_5000', grup: 'para', ikon: 'heart', kademe: 2, hedef: 5000,
    ad: 'Cömert Müşteriler',
    ac: 'Toplam $5.000 bahşiş topla.',
    oku: function (S) { return S.bahsis || 0; } },

  /* ---------------- BORC ---------------- */
  { id: 'borc_ilk', grup: 'borc', ikon: 'coin', kademe: 1, hedef: 1,
    ad: 'İlk Taksit',
    ac: 'Borcundan ilk ödemeyi yap.',
    oku: function (S) { return S.debtPaid || 0; } },
  { id: 'borc_100k', grup: 'borc', ikon: 'coin', kademe: 2, hedef: 100000,
    ad: 'Faiz Eriyor',
    ac: 'Borcundan $100.000 öde.',
    oku: function (S) { return S.debtPaid || 0; } },
  { id: 'borc_yari', grup: 'borc', ikon: 'star', kademe: 2, hedef: 1,
    ad: 'Yarı Yolda',
    ac: 'Borcun yarısını kapat.',
    oku: function (S, G) { return G.debt <= DEBT_START / 2 ? 1 : 0; } },
  { id: 'borc_bitti', grup: 'borc', ikon: 'star', kademe: 3, hedef: 1,
    ad: 'Babanın Borcu',
    ac: 'Borcun tamamını kapat.',
    oku: function (S, G) { return (G.debt <= 0 || G.debtCleared) ? 1 : 0; } },
  { id: 'borc_hizli', grup: 'borc', ikon: 'star', kademe: 3, hedef: 1,
    ad: 'Erken Kapanış',
    ac: '120 günden önce borcu bitir.',
    oku: function (S, G) { return ((G.debt <= 0 || G.debtCleared) && G.day <= 120) ? 1 : 0; } },

  /* ---------------- DUKKAN ---------------- */
  { id: 'ilk_upgrade', grup: 'dukkan', ikon: 'star', kademe: 1, hedef: 1,
    ad: 'İlk Yatırım',
    ac: 'İlk geliştirmeni satın al.',
    oku: function (S, G) { return upgTotalLv(G); } },
  { id: 'upgrade_15', grup: 'dukkan', ikon: 'star', kademe: 2, hedef: 15,
    ad: 'Yenileme',
    ac: '15 geliştirme seviyesi al.',
    oku: function (S, G) { return upgTotalLv(G); } },
  { id: 'upgrade_hepsi', grup: 'dukkan', ikon: 'star', kademe: 3, hedef: 1,
    ad: 'Tam Donanım',
    ac: 'Bütün geliştirmeleri sonuna kadar aç.',
    oku: function (S, G) { return upgTotalLv(G) >= bsUpgTavan() ? 1 : 0; } },
  { id: 'sube_1', grup: 'dukkan', ikon: 'pide', kademe: 1, hedef: 1,
    ad: 'İkinci Şube',
    ac: 'İlk şubeni aç.',
    oku: function (S, G) { return G.branch || 0; } },
  { id: 'sube_3', grup: 'dukkan', ikon: 'pide', kademe: 2, hedef: 3,
    ad: 'Zincir',
    ac: '3 şube aç.',
    oku: function (S, G) { return G.branch || 0; } },
  { id: 'sube_hepsi', grup: 'dukkan', ikon: 'pide', kademe: 3, hedef: 1,
    ad: 'İmparatorluk',
    ac: 'Bütün şubeleri aç.',
    oku: function (S, G) { return (G.branch || 0) >= BRANCH.length ? 1 : 0; } },
  { id: 'telefon_25', grup: 'dukkan', ikon: 'fries', kademe: 1, hedef: 25,
    ad: 'Paket Servis',
    ac: '25 telefon siparişi tamamla.',
    oku: function (S) { return S.phone || 0; } },
  { id: 'telefon_200', grup: 'dukkan', ikon: 'fries', kademe: 2, hedef: 200,
    ad: 'Hat Meşgul',
    ac: '200 telefon siparişi tamamla.',
    oku: function (S) { return S.phone || 0; } },
  { id: 'moto_tamir', grup: 'dukkan', ikon: 'fbox', kademe: 1, hedef: 1,
    ad: 'Yolda Kalma',
    ac: 'Dayının motorunu bir kez tamir ettir.',
    oku: function (S) { return S.moto || 0; } },
  { id: 'dayi_20', grup: 'dukkan', ikon: 'meat', kademe: 2, hedef: 20,
    ad: 'Dayının Eli',
    ac: 'Dayıdan 20 kez yardım iste.',
    oku: function (S) { return S.dayi || 0; } },

  /* ---------------- SEHIR ---------------- */
  { id: 'sehir_2', grup: 'sehir', ikon: 'plate', kademe: 1, hedef: 2,
    ad: 'Yolcu',
    ac: '2 farklı şehirde dükkân aç.',
    oku: function (S) { return bsSehirSayisi(S); } },
  { id: 'sehir_5', grup: 'sehir', ikon: 'plate', kademe: 2, hedef: 5,
    ad: 'Gezgin',
    ac: '5 farklı şehirde dükkân aç.',
    oku: function (S) { return bsSehirSayisi(S); } },
  { id: 'sehir_hepsi', grup: 'sehir', ikon: 'star', kademe: 3, hedef: SEHIR.length,
    ad: 'Bütün Ülke',
    ac: 'Bütün şehirlerde dükkân aç.',
    oku: function (S) { return bsSehirSayisi(S); } },
  { id: 'gece_30', grup: 'sehir', ikon: 'pickle', kademe: 2, hedef: 30,
    ad: 'Otuz Gece',
    ac: '30 gün oyna.',
    oku: function (S) { return S.days || 0; } },
  { id: 'gun_100', grup: 'sehir', ikon: 'pickle', kademe: 3, hedef: 100,
    ad: 'Yüz Gün',
    ac: '100 gün oyna.',
    oku: function (S) { return S.days || 0; } },
  { id: 'gun_365', grup: 'sehir', ikon: 'star', kademe: 3, hedef: 365,
    ad: 'Bir Yıl',
    ac: '365 gün oyna.',
    oku: function (S) { return S.days || 0; } },

  /* ---------------- USTALIK ---------------- */
  { id: 'mukemmel_gun', grup: 'usta', ikon: 'heart', kademe: 1, hedef: 1,
    ad: 'Kusursuz Gün',
    ac: 'Bir günü tek müşteri kaçırmadan bitir.',
    oku: function (S) { return S.mukemmel || 0; } },
  { id: 'mukemmel_10', grup: 'usta', ikon: 'heart', kademe: 3, hedef: 10,
    ad: 'Kusursuz On',
    ac: '10 kusursuz gün çıkar.',
    oku: function (S) { return S.mukemmel || 0; } },
  { id: 'seri_10', grup: 'usta', ikon: 'garlic', kademe: 1, hedef: 10,
    ad: 'Seri',
    ac: 'Üst üste 10 müşteriyi memnun et.',
    oku: function (S) { return S.enSeri || 0; } },
  { id: 'seri_30', grup: 'usta', ikon: 'garlic', kademe: 2, hedef: 30,
    ad: 'Uzun Seri',
    ac: 'Üst üste 30 müşteriyi memnun et.',
    oku: function (S) { return S.enSeri || 0; } },
  { id: 'seri_75', grup: 'usta', ikon: 'star', kademe: 3, hedef: 75,
    ad: 'Kesintisiz',
    ac: 'Üst üste 75 müşteriyi memnun et.',
    oku: function (S) { return S.enSeri || 0; } },
  { id: 'temiz_mutfak', grup: 'usta', ikon: 'sauce', kademe: 2, hedef: 10,
    ad: 'Temiz Mutfak',
    ac: 'Üst üste 10 gün hijyen cezası alma.',
    oku: function (S) { return S.temizSeri || 0; } },
  { id: 'depo_tam', grup: 'usta', ikon: 'pickle', kademe: 1, hedef: 1,
    ad: 'Depo Dolu',
    ac: 'Bir günü deposu dolu kapat.',
    oku: function (S) { return S.depoTam || 0; } },
  { id: 'buyuk_siparis', grup: 'usta', ikon: 'plate', kademe: 2, hedef: 25,
    ad: 'Kalabalık Sofra',
    ac: '4 ve üstü ürünlü 25 sipariş tamamla.',
    oku: function (S) { return S.buyukSiparis || 0; } },

  /* ---------------- DEMIRKENT ---------------- */
  { id: 'demirkent_ilk', grup: 'demirkent', ikon: 'plate', kademe: 1, hedef: 1,
    ad: 'Sınırın Ötesi',
    ac: 'Demirkent\'e geç.',
    oku: function (S) { return S.fgunEn || 0; } },
  { id: 'demirkent_10', grup: 'demirkent', ikon: 'plate', kademe: 2, hedef: 10,
    ad: 'Direniş',
    ac: 'Demirkent\'te 10 gün dayan.',
    oku: function (S) { return S.fgunEn || 0; } },
  { id: 'demirkent_30', grup: 'demirkent', ikon: 'star', kademe: 3, hedef: 30,
    ad: 'Demirkent Sakini',
    ac: 'Demirkent\'te 30 gün dayan.',
    oku: function (S) { return S.fgunEn || 0; } },
  { id: 'ev_2', grup: 'demirkent', ikon: 'pide', kademe: 1, hedef: 1,
    ad: 'Arka Sokak',
    ac: 'Bodrumdan çık, daha iyi bir eve taşın.',
    oku: function (S) { return S.evEn || 0; } },
  { id: 'ev_4', grup: 'demirkent', ikon: 'pide', kademe: 2, hedef: 3,
    ad: 'Devlet Lojmanı',
    ac: 'Devlet lojmanına taşın.',
    oku: function (S) { return S.evEn || 0; } },
  { id: 'ev_son', grup: 'demirkent', ikon: 'star', kademe: 3, hedef: EVLER.length - 1,
    ad: 'Parti Konutu',
    ac: 'En üst basamağa, parti konutuna çık.',
    oku: function (S) { return S.evEn || 0; } },
  { id: 'lider_siparis', grup: 'demirkent', ikon: 'iskender', kademe: 2, hedef: 1,
    ad: 'Liderin Siparişi',
    ac: 'Ülkenin liderine doğru siparişi ver.',
    oku: function (S) { return S.lider || 0; } },
  { id: 'lider_3', grup: 'demirkent', ikon: 'star', kademe: 3, hedef: 3,
    ad: 'Sadık Esnaf',
    ac: 'Lidere 3 kez doğru siparişi ver.',
    oku: function (S) { return S.lider || 0; } },
  { id: 'sicil_temiz', grup: 'demirkent', ikon: 'sauce', kademe: 2, hedef: 1,
    ad: 'Sicili Temiz',
    ac: 'Demirkent\'te bir günü hiç ihlalsiz kapat.',
    oku: function (S) { return S.temizGun || 0; } },
  { id: 'kacakci', grup: 'demirkent', ikon: 'hot', kademe: 2, hedef: 10,
    ad: 'Kaçakçı',
    ac: 'Yasaklı ürünü 10 kez yakalanmadan ver.',
    oku: function (S) { return S.kacak || 0; } },

  /* ---------------- GIZLI ---------------- */
  { id: 'muhur', grup: 'gizli', ikon: 'hot', kademe: 1, hedef: 1, gizli: true,
    ad: 'Mühürlü Dükkân',
    ac: 'Müfettiş dükkânı bir kez kapatsın.',
    oku: function (S) { return S.muhur || 0; } },
  { id: 'yanik', grup: 'gizli', ikon: 'meat', kademe: 1, hedef: 10, gizli: true,
    ad: 'Ateşle Oynama',
    ac: 'Izgarada 10 dürüm yak.',
    oku: function (S) { return S.yanik || 0; } },
  { id: 'hirsiz', grup: 'gizli', ikon: 'coin', kademe: 1, hedef: 1, gizli: true,
    ad: 'Kepenk Kırıldı',
    ac: 'Gece bir kez soyul.',
    oku: function (S) { return (S.stolen || 0) > 0 ? 1 : 0; } },
  { id: 'sifir_kasa', grup: 'gizli', ikon: 'coin', kademe: 1, hedef: 1, gizli: true,
    ad: 'Sıfır Kasa',
    ac: 'Bir günü cebinde hiç para kalmadan kapat.',
    oku: function (S) { return S.sifirGun || 0; } },
  { id: 'sabirsiz', grup: 'gizli', ikon: 'fries', kademe: 1, hedef: 50, gizli: true,
    ad: 'Bekleyemem',
    ac: '50 müşteri kaçır.',
    oku: function (S) { return S.lost || 0; } },
  { id: 'buyuk_bahsis', grup: 'gizli', ikon: 'heart', kademe: 2, hedef: 25, gizli: true,
    ad: 'Cebi Geniş',
    ac: 'Tek seferde $25 bahşiş al.',
    oku: function (S) { return S.enBahsis || 0; } },
  { id: 'evsiz', grup: 'gizli', ikon: 'heart', kademe: 2, hedef: 10, gizli: true,
    ad: 'Karnını Doyur',
    ac: '10 kez parası olmayanı doyur.',
    oku: function (S) { return S.fed || 0; } }
];

/* ---- magaza kimlikleri: tabloden turer, elle yazilmaz ---- */
function bsSteamId(b) { return 'ACH_' + b.id.toUpperCase(); }
function bsGcId(b) { return BS_BUNDLE + '.ach.' + b.id; }

/* ---- yardimcilar ---- */
function bsAd(b) { return T(b.ad); }
function bsAc(b) { return T(b.ac); }
/* magaza koprusu her zaman Ingilizce ad ister, oyun dili ne olursa olsun */
function bsIng(s) { return (typeof EN !== 'undefined' && EN[s]) || s; }
function bsUpgTavan() {
  var n = 0;
  for (var i = 0; i < UPG.length; i++) n += UPG[i].lv.length;
  return n;
}
function bsSehirSayisi(S) {
  var a = S && S.sehir;
  return (a && a.length) ? a.length : 0;
}
function basarimById(id) {
  for (var i = 0; i < BASARIM.length; i++) if (BASARIM[i].id === id) return BASARIM[i];
  return null;
}
function basarimAcik(id) { return !!(G.bs && G.bs[id]); }
function basarimSayisi() {
  var n = 0;
  for (var i = 0; i < BASARIM.length; i++) if (basarimAcik(BASARIM[i].id)) n++;
  return n;
}
/* 0..1 arasi ilerleme; acilmissa 1 */
function basarimOran(b) {
  if (basarimAcik(b.id)) return 1;
  var v = 0;
  try { v = b.oku(G.stats || {}, G) || 0; } catch (e) { v = 0; }
  return clamp(v / (b.hedef || 1), 0, 1);
}

/* ---- acilis ---- */
var BSQ = { kuyruk: [], t: 0, sesli: true };

function basarimAc(id, sessiz) {
  var b = basarimById(id);
  if (!b || basarimAcik(id)) return false;
  if (!G.bs) G.bs = {};
  G.bs[id] = G.day || 1;
  if (!sessiz) {
    BSQ.kuyruk.push({ b: b, t: 0 });
    if (typeof SFX !== 'undefined' && SFX.levelup) SFX.levelup();
  }
  basarimBildir(b);
  return true;
}

/* Magaza koprusu. Hicbir koprusu olmayan ortamda (tarayici) sessizce
   gecer; oyun ici basarim yine calisir. Expo/WebView, Steam sarmalayici
   ve iframe ustu ana pencere ayri ayri denenir. */
function basarimBildir(b) {
  var yuk = {
    tip: 'basarim', id: b.id, ad: b.ad, en: bsIng(b.ad),
    steam: bsSteamId(b), gc: bsGcId(b)
  };
  try {
    if (window.__ACH && typeof window.__ACH.unlock === 'function') window.__ACH.unlock(yuk);
    if (window.ReactNativeWebView && window.ReactNativeWebView.postMessage) {
      window.ReactNativeWebView.postMessage(JSON.stringify(yuk));
    }
    if (window.steamworks && typeof window.steamworks.activateAchievement === 'function') {
      window.steamworks.activateAchievement(yuk.steam);
    }
    if (window.parent && window.parent !== window) window.parent.postMessage(yuk, '*');
  } catch (e) { /* kopru yoksa oyun akisi bozulmaz */ }
}

/* Tabloyu tarar, hedefe ulasanlari acar. Ucuz: ~60 kucuk kapanis.
   startDay/endDay/satin alma anlarinda ve oyun sirasinda yarim
   saniyede bir cagrilir. */
function basarimTara(sessiz) {
  if (!G.bs) G.bs = {};
  var S = G.stats || {}, acilan = 0;
  for (var i = 0; i < BASARIM.length; i++) {
    var b = BASARIM[i];
    if (G.bs[b.id]) continue;
    var v = 0;
    try { v = b.oku(S, G); } catch (e) { continue; }
    if ((v || 0) >= b.hedef) { if (basarimAc(b.id, sessiz)) acilan++; }
  }
  if (acilan) saveAll();
  return acilan;
}

/* Kayittan yuklenirken: eski kayitta G.bs yoktur. Mevcut istatistiklerle
   hak edilmis basarimlari SESSIZCE acariz — oyuncuya 40 bildirim
   yagdirmak yerine ekranda acilmis olarak gorunurler. */
function basarimBaslat(ilkKez) {
  if (!G.bs) { G.bs = {}; basarimTara(true); return; }
  if (ilkKez) basarimTara(true);
}
