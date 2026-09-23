/* ============================================================
   ŞEHİRLER — her şubenin kendi dokusu
   G.city: -1 = babanın dükkânı (ev), 0..6 = BRANCH sırası.
   Tema yalnızca GÖRÜNÜŞ değiştirir; ekonomiye dokunmaz.
   ============================================================ */
var SEHIR = [
  {
    id: 'ev', ad: 'BABANIN DÜKKÂNI', zeminTip: 'ahsap', imza: null,
    trafik: [[0,0,0,30],[0,2,2,23],[0,3,4,34],[1,1,1,33],[1,3,3,39],[1,0,5,27]],
    ikon: 'posta', agac: 'yaprak',
    /* Baba dukkani: mahalle. Karisik, biyik bol. */
    yagmur: 0.16, kar: 0.03, sicak: 0.02,
    musteri: { ten:[0,1,1,2,2,3], sac:[0,0,1,1,2,7],
      gomlek:['#4a7fc0','#c95a4a','#5aa86a','#d8a03c','#8a8f96','#5c6470'],
      aks:{ glasses:.12, cap:.14, kufiya:.06, band:.08, beard:.14 }, biyik:.42 },
    cephe: { boyAz: 24, boyCok: 34, genAz: 46, genCok: 66, tarz: 'dukkan' },
    duvar: ['#6ba7c4', '#4d87a6', '#3a6c88', '#2c5369', '#25485c'],
    zemin: ['#a8703f', '#8a5730', '#6b4122', '#4e2e17'],
    tas: ['#e6e6ea', '#c8c9d2', '#a4a5b3', '#7d7e8d', '#5b5c69'],
    gok: ['#7fbde8', '#dcecf4'], bina: ['#6d8a9e', '#5d7a90'],
    yol: '#41454b', kaldirim: '#b4bbc2'
  },
  {
    id: 'istanbul', ad: 'İSTANBUL', zeminTip: 'ahsap', imza: 'galata',
    trafik: [[0,1,1,32],[0,2,3,22],[0,0,2,34],[1,1,1,30],[1,3,0,38],[1,2,3,24]],
    ikon: 'simit', agac: 'yaprak',
    /* Vapur iskelesi: her kesim, biyik ve sakal bol. */
    yagmur: 0.22, kar: 0.05, sicak: 0.04,
    musteri: { ten:[0,1,1,2,2,3], sac:[0,0,1,1,7,3],
      gomlek:['#c95a4a','#4a7fc0','#d8a03c','#5aa86a','#8a6ac0','#8a8f96'],
      aks:{ glasses:.10, cap:.16, kufiya:.05, band:.10, beard:.16 }, biyik:.46 },
    cephe: { boyAz: 24, boyCok: 34, genAz: 44, genCok: 62, tarz: 'dukkan' },
    duvar: ['#7ecbc4', '#4fa9a2', '#3a8880', '#2b6a63', '#1f4f4a'],
    zemin: ['#c08a4e', '#a06c38', '#7d5026', '#5a3818'],
    tas: ['#f0e4cc', '#dcc9a6', '#c0a97f', '#9a8256', '#6f5c3a'],
    gok: ['#8fd0e8', '#f6e3c0'], bina: ['#c9a97e', '#a8845c'],
    yol: '#4a4640', kaldirim: '#c9c0ad'
  },
  {
    id: 'berlin', ad: 'BERLİN', zeminTip: 'beton', imza: 'kule',
    trafik: [[0,0,5,31],[0,2,1,22],[0,3,2,35],[1,0,9,29],[1,3,5,37],[1,2,1,23]],
    ikon: 'sutun', agac: 'budanmis',
    /* Berlin: koyu ve sade giyim, sapka bol, biyik az. */
    yagmur: 0.34, kar: 0.16, sicak: 0.01,
    musteri: { ten:[0,0,1,2,3,4], sac:[0,1,2,3,5,6],
      gomlek:['#3f4650','#5c6470','#4a5a3c','#8a8f96','#2f3640','#6b5a4a'],
      aks:{ glasses:.20, cap:.22, kufiya:.02, band:.06, beard:.14 }, biyik:.20 },
    cephe: { boyAz: 28, boyCok: 34, genAz: 40, genCok: 58, tarz: 'blok' },
    duvar: ['#b9b1a8', '#96897c', '#75695e', '#544a41', '#3a332c'],
    zemin: ['#8f8f8d', '#71716f', '#575755', '#3c3c3a'],
    tas: ['#c9b0a0', '#a8887a', '#8a6a5c', '#6a4e44', '#4a352e'],
    gok: ['#9fb3c0', '#cdd8de'], bina: ['#7c8790', '#68727a'],
    yol: '#3c4046', kaldirim: '#a8aeb4'
  },
  {
    id: 'londra', ad: 'LONDRA', zeminTip: 'ahsap', imza: 'saat',
    trafik: [[0,5,0,23],[0,0,9,31],[0,3,2,34],[1,5,0,21],[1,0,9,28],[1,3,5,36]],
    ikon: 'kulube', agac: 'budanmis',
    /* Londra: koyu palto tonlari, gozluk cok. */
    yagmur: 0.52, kar: 0.10, sicak: 0.00,
    musteri: { ten:[0,0,1,2,3,4], sac:[0,1,3,5,6,7],
      gomlek:['#2f3f5a','#5a3a3a','#3f4650','#6b5a4a','#8a8f96','#44506b'],
      aks:{ glasses:.26, cap:.10, kufiya:.03, band:.05, beard:.12 }, biyik:.18 },
    cephe: { boyAz: 26, boyCok: 34, genAz: 38, genCok: 54, tarz: 'blok' },
    duvar: ['#7fb08a', '#5a8f68', '#43724f', '#31563b', '#22402a'],
    zemin: ['#8a6a4a', '#6c4f34', '#523a24', '#3a2818'],
    tas: ['#e8e2d4', '#cdc5b3', '#aaa08c', '#847a66', '#5c5344'],
    gok: ['#a8b8c4', '#d8dfe4'], bina: ['#7a7f88', '#666b73'],
    yol: '#3e4247', kaldirim: '#b0b6bb'
  },
  {
    id: 'manila', ad: 'MANİLA', zeminTip: 'beton', imza: 'kuleler',
    trafik: [[0,4,6,26],[0,3,7,33],[0,2,1,22],[1,4,8,28],[1,4,6,25],[1,3,0,35]],
    ikon: 'sarisari', agac: 'palmiye',
    /* Manila: tropik, canli, kalabalik. Sik yagmur. */
    yagmur: 0.44, kar: 0.00, sicak: 0.22,
    musteri: { ten:[1,2,2,3,1,2], sac:[0,0,0,1,7,1],
      gomlek:['#e0483a','#f0a83a','#3fa8c0','#8ac04a','#f2e2b8','#c04a8a'],
      aks:{ glasses:.10, cap:.20, kufiya:.04, band:.16, beard:.08 }, biyik:.24 },
    cephe: { boyAz: 22, boyCok: 30, genAz: 34, genCok: 48, tarz: 'tabela' },
    duvar: ['#f0c98a', '#dba85e', '#bd8a42', '#96692e', '#6e4c1e'],
    zemin: ['#b8b0a0', '#98907f', '#7a7264', '#575149'],
    tas: ['#e8dcc0', '#cfbe98', '#ac9a74', '#877552', '#5f5138'],
    gok: ['#7fc4d8', '#f2e0b8'], bina: ['#c9b08a', '#a89068'],
    yol: '#4c4a44', kaldirim: '#c4bca8'
  },
  {
    id: 'paris', ad: 'PARİS', zeminTip: 'ahsap', imza: 'kafes',
    trafik: [[0,3,2,33],[0,0,5,31],[0,3,9,34],[1,3,4,36],[1,0,2,30],[1,2,2,23]],
    ikon: 'kafe', agac: 'budanmis',
    /* Paris: pastel ve notr tonlar, atki (kufiya) sik. */
    yagmur: 0.28, kar: 0.08, sicak: 0.03,
    musteri: { ten:[0,0,1,1,2,4], sac:[0,1,2,3,4,6],
      gomlek:['#d8c9b0','#b8a08a','#8fa8c0','#c98a8a','#e0e4e8','#9a8fa8'],
      aks:{ glasses:.18, cap:.08, kufiya:.22, band:.06, beard:.08 }, biyik:.16 },
    cephe: { boyAz: 26, boyCok: 34, genAz: 36, genCok: 52, tarz: 'mansart' },
    duvar: ['#f0dcc8', '#d9bfa6', '#bfa287', '#9c8168', '#78614c'],
    zemin: ['#c9a06a', '#a87f4c', '#8a6438', '#644728'],
    tas: ['#f4efe2', '#ded7c6', '#bdb4a0', '#948b78', '#6b6353'],
    gok: ['#9ec8e8', '#f0e6ea'], bina: ['#b8b0a4', '#9a9288'],
    yol: '#4a4a4e', kaldirim: '#c4bfb4'
  },
  {
    id: 'dubai', ad: 'DUBAİ', zeminTip: 'mermer', imza: 'gokdelen',
    trafik: [[0,0,2,40],[0,2,2,28],[0,3,2,39],[1,0,2,42],[1,3,5,38],[1,0,9,36]],
    ikon: 'palmiye', agac: 'palmiye',
    /* Dubai: beyaz ve bej, kufiya cok, sakal bol. Yagmur yok gibi. */
    yagmur: 0.02, kar: 0.00, sicak: 0.34,
    musteri: { ten:[1,2,2,3,3,0], sac:[0,0,1,7,1,0],
      gomlek:['#f2ece0','#e8dcc4','#d8cbb0','#c9b896','#ffffff','#e0d0b4'],
      aks:{ glasses:.10, cap:.05, kufiya:.38, band:.04, beard:.24 }, biyik:.34 },
    cephe: { boyAz: 31, boyCok: 34, genAz: 26, genCok: 38, tarz: 'cam' },
    duvar: ['#f2dfae', '#dcc184', '#c0a463', '#9c8248', '#786232'],
    zemin: ['#e8e2d4', '#cfc7b6', '#b0a795', '#8a8172'],
    tas: ['#f6ecd6', '#e4d3ae', '#c9b487', '#a38f64', '#7a6a48'],
    gok: ['#f0c98a', '#fdf0d4'], bina: ['#d8c49a', '#bda87e'],
    yol: '#57534c', kaldirim: '#ddd4c0'
  },
  {
    id: 'tokyo', ad: 'TOKYO', zeminTip: 'ahsap', imza: 'pagoda',
    trafik: [[0,3,2,32],[0,2,2,24],[0,0,9,33],[1,3,2,34],[1,0,5,31],[1,3,8,30]],
    ikon: 'otomat', agac: 'sakura',
    /* Tokyo: siyah-beyaz-lacivert, gozluk cok, biyik nadir. */
    yagmur: 0.38, kar: 0.09, sicak: 0.05,
    musteri: { ten:[0,0,4,1,0,4], sac:[0,0,0,1,5,6],
      gomlek:['#2b2f3a','#e0e4e8','#3f4a6b','#8a8f96','#c95a5a','#4a5560'],
      aks:{ glasses:.30, cap:.14, kufiya:.02, band:.08, beard:.05 }, biyik:.08 },
    cephe: { boyAz: 27, boyCok: 34, genAz: 30, genCok: 44, tarz: 'tabela' },
    duvar: ['#8fa8d8', '#5f7cb8', '#455f96', '#2f4372', '#1e2c50'],
    zemin: ['#7a6a52', '#5c4e3a', '#443a2a', '#2e281c'],
    tas: ['#d8dae0', '#b2b6c0', '#8c909c', '#666a76', '#454854'],
    gok: ['#5f6fa8', '#e0a8b8'], bina: ['#5a6488', '#48506e'],
    yol: '#33363c', kaldirim: '#9aa0aa'
  },
  {
    id: 'newyork', ad: 'NEW YORK', zeminTip: 'dama', imza: 'manhattan',
    trafik: [[0,1,1,34],[0,1,1,30],[0,0,5,32],[1,1,1,33],[1,2,1,24],[1,3,9,36]],
    ikon: 'musluk', agac: 'yaprak',
    /* New York: canli ve karisik, sapka cok. */
    yagmur: 0.30, kar: 0.14, sicak: 0.04,
    musteri: { ten:[0,1,2,3,3,4], sac:[0,0,1,2,5,7],
      gomlek:['#c9433a','#3f7fc0','#d8a03c','#4aa86a','#8a4ac0','#2f3640'],
      aks:{ glasses:.14, cap:.30, kufiya:.03, band:.14, beard:.12 }, biyik:.22 },
    cephe: { boyAz: 33, boyCok: 34, genAz: 22, genCok: 32, tarz: 'gokdelen' },
    duvar: ['#f2f2f0', '#dcdcd8', '#c0c0bc', '#9a9a96', '#3a3a38'],
    zemin: ['#e0e0dc', '#4a4a48', '#2e2e2c', '#1c1c1a'],
    tas: ['#c08a68', '#a06e50', '#84573c', '#63402b', '#45291a'],
    gok: ['#3a4a72', '#8a7ea8'], bina: ['#4e5670', '#3e4458'],
    yol: '#35383e', kaldirim: '#9fa4aa'
  },
  {
    /* DEMİRKENT — hayali diktatörlük. Brütalist, gri, tek tip.
       Renk yok denecek kadar az; tek canlı ton rejimin kırmızısı. */
    id: 'demirkent', ad: 'DEMİRKENT', zeminTip: 'beton', imza: 'anit',
    trafik: [[0,2,5,20],[0,0,9,24],[0,2,5,21],[1,2,5,22],[1,0,9,26],[1,3,5,23]],
    ikon: 'sutun', agac: 'budanmis',
    /* Halk tek tip giyinir: gri, haki, koyu mavi. Aksesuar az — dikkat çeker. */
    yagmur: 0.46, kar: 0.12, sicak: 0.02,
    musteri: { ten:[0,1,1,2,2,3], sac:[0,0,1,5,5,6],
      /* Gri halkin arasinda birkac kirmizi: 'kirmizi giyene satis yasak'
         fermani yoksa hicbir zaman tetiklenmiyordu (olu kural) ve gri
         sehirde tek renk leke de iyi duruyor. 8'de 1 kirmizi. */
      gomlek:['#6b7078','#57606a','#4a5560','#7a7f70','#3f4650','#8a8d92','#8a8d92','#c93a2e'],
      aks:{ glasses:.16, cap:.20, kufiya:.02, band:.06, beard:.10 }, biyik:.26 },
    cephe: { boyAz: 30, boyCok: 34, genAz: 28, genCok: 40, tarz: 'beton' },
    duvar: ['#8e9298', '#6e7278', '#565a60', '#3e4248', '#2a2e34'],
    zemin: ['#7a7d82', '#5e6166', '#46484c', '#303236'],
    tas: ['#c2c4c8', '#a0a2a6', '#7e8084', '#5c5e62', '#3e4044'],
    gok: ['#8a8f96', '#b8bcc0'], bina: ['#6a6e74', '#54585e'],
    yol: '#3a3c40', kaldirim: '#8c8f94'
  }
];

/* Oyuncunun bulunduğu şehrin teması. */
function sehirTema() {
  var i = (typeof G !== 'undefined' && G && typeof G.city === 'number') ? G.city : -1;
  return SEHIR[clamp(i + 1, 0, SEHIR.length - 1)];
}
/* Şehrin adı — İngilizcede de şube adları çevrilir. */
function sehirAdi(i) {
  if (i === undefined) i = (typeof G !== 'undefined' && G) ? G.city : -1;
  if (i < 0) return T('BABANIN DÜKKÂNI');
  return T(BRANCH[clamp(i, 0, BRANCH.length - 1)].name);
}
/* Oraya gidilebilir mi: şube açılmış olmalı. */
function sehirAcik(i) {
  if (i < 0) return true;
  return i < (G.branch || 0);
}

/* ---------- boya: gerçekten farklı renkler ----------
   Eskiden %24 karışım yapılıyordu ve her seviye mevcut rengin
   yakınına düşüyordu ("mavi -> biraz daha mavi"). Artık TON
   DÖNDÜRME var: mavi fayans -> yeşil -> sıcak turuncu gibi
   birbirinden ayrık paletler. */
function _hex2rgb(h) {
  var v = parseInt(h.slice(1), 16);
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255];
}
function _rgb2hex(r, g, b) {
  function k(n) { n = Math.max(0, Math.min(255, Math.round(n))); var s = n.toString(16); return s.length < 2 ? '0' + s : s; }
  return '#' + k(r) + k(g) + k(b);
}
function _rgb2hsl(r, g, b) {
  r /= 255; g /= 255; b /= 255;
  var mx = Math.max(r, g, b), mn = Math.min(r, g, b), d = mx - mn;
  var l = (mx + mn) / 2, h = 0, sat = 0;
  if (d) {
    sat = l > .5 ? d / (2 - mx - mn) : d / (mx + mn);
    if (mx === r) h = ((g - b) / d + (g < b ? 6 : 0));
    else if (mx === g) h = (b - r) / d + 2;
    else h = (r - g) / d + 4;
    h /= 6;
  }
  return [h, sat, l];
}
function _hsl2rgb(h, s, l) {
  function f(p, q, t) {
    if (t < 0) t += 1; if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }
  if (!s) return [l * 255, l * 255, l * 255];
  var q = l < .5 ? l * (1 + s) : l + s - l * s, p = 2 * l - q;
  return [f(p, q, h + 1 / 3) * 255, f(p, q, h) * 255, f(p, q, h - 1 / 3) * 255];
}
/* Her boya seviyesi MUTLAK bir hedef ton verir:
   [hedefTon(null=degistirme), doygunlukCarpani, parlaklikKaydirma].
   Parlaklik dokusu korunur, yani fayans deseni kaybolmaz. */
var BOYA_KAT = [
  [null, 1.00, 0.00],    /* sv0: satin alinmadi -> şehrin kendi rengi */
  [0.56, 0.90, 0.00],    /* sv1: mavi fayans */
  [0.33, 0.80, 0.01],    /* sv2: yeşil fayans */
  [0.07, 0.78, 0.05]     /* sv3: lüks turuncu / kiremit */
];
function boyaUygula(renk, kat) {
  var c = _hex2rgb(renk), hsl = _rgb2hsl(c[0], c[1], c[2]);
  var h = (kat[0] === null) ? hsl[0] : kat[0];
  /* Renksiz (gri) tonlarda doygunluk 0'dir; hedef tonun gorunmesi
     icin taban bir doygunluk verilir, yoksa boya hic etki etmez. */
  var taban = Math.max(hsl[1], kat[0] === null ? hsl[1] : 0.30);
  var sa = Math.max(0, Math.min(1, taban * kat[1]));
  var l = Math.max(0.04, Math.min(0.96, hsl[2] + kat[2]));
  var o = _hsl2rgb(h, sa, l);
  return _rgb2hex(o[0], o[1], o[2]);
}
function duvarPaleti(tema, decor) {
  var kat = BOYA_KAT[(decor || 0) % BOYA_KAT.length];
  if (kat[0] === null) return tema.duvar;
  var o = [];
  for (var i = 0; i < tema.duvar.length; i++) o.push(boyaUygula(tema.duvar[i], kat));
  return o;
}
/* Beyaz taş duvar da boyayla değişsin — kullanıcı ikisinin de
   değişmesini istedi. Taş daha az kaydırılır ki taş gibi kalsın. */
function tasPaleti(tema, decor) {
  var kat = BOYA_KAT[(decor || 0) % BOYA_KAT.length];
  if (kat[0] === null) return tema.tas;
  /* taş boyanın tonunu ALIR ama doygunluğu düşük kalır: taş gibi durur */
  var yumusak = [kat[0], kat[1] * 0.30, kat[2] * 0.4];
  var o = [];
  for (var i = 0; i < tema.tas.length; i++) o.push(boyaUygula(tema.tas[i], yumusak));
  return o;
}

/* ---------- şehir imzaları: uzak silüette görünür ---------- */
function drawImza(id, cx, taban) {
  if (!id) return;
  /* Onundeki dukkan cepheleri taban-34'e kadar yukselir; camin ust
     kenari taban-50'dedir. Yani siluetin yalnizca EN UST 16 PIKSELI
     gorunur. Her sehrin taninan detayi bilerek o banda yerlestirildi;
     govdenin alti cephelerin arkasinda kalir ve bu dogru bir derinlik. */
  var k1 = 'rgba(64,86,104,.62)', k2 = 'rgba(64,86,104,.82)';
  var isik = 'rgba(252,242,196,.6)';
  function y(h) { return taban - h; }
  if (id === 'galata') {
    /* silindir govde + konik kulah (kulah gorunur bantta) */
    fr(cx - 6, y(38), 13, 38, k1);
    for (var i = 0; i < 3; i++) px(cx - 3 + i * 3, y(30), isik);
    fr(cx - 7, y(41), 15, 3, k2);                 /* balkon */
    for (var kk = 0; kk < 7; kk++)                /* konik kulah */
      fr(cx - 6 + kk, y(41 + kk + 1), 13 - kk * 2, 1, k2);
    ln(cx, y(49), cx, y(52), k2);
    /* iki minare: serefeleri de bantta */
    for (var m = 0; m < 2; m++) {
      var mx = cx + (m ? 17 : -18);
      fr(mx - 1, y(36), 3, 36, k1);
      fr(mx - 3, y(37), 7, 2, k2);
      for (var mk = 0; mk < 3; mk++) fr(mx - 1 + mk, y(39 + mk), 3 - mk * 2, 1, k2);
      ln(mx, y(42), mx, y(46), k2);
    }
  } else if (id === 'kule') {
    /* TV kulesi: kure gorunur bantta */
    fr(cx - 2, y(36), 4, 36, k1);
    ell(cx, y(40), 7, 7, k2);
    ell(cx, y(41), 4, 4, 'rgba(232,242,248,.55)');
    px(cx - 2, y(41), isik); px(cx + 2, y(41), isik);
    fr(cx - 1, y(48), 3, 8, k2);
    ln(cx, y(50), cx, y(54), k2);
  } else if (id === 'saat') {
    /* saat kulesi: kadran ve sivri catі bantta */
    fr(cx - 6, y(36), 13, 36, k1);
    fr(cx - 7, y(39), 15, 3, k2);
    ell(cx, y(35), 4, 4, 'rgba(252,244,206,.85)');  /* kadran */
    px(cx, y(36), k2); px(cx + 1, y(35), k2);
    for (var t2 = 0; t2 < 5; t2++)                  /* sivri cati */
      fr(cx - 6 + t2, y(42 + t2), 13 - t2 * 2, 1, k2);
    ln(cx, y(47), cx, y(51), k2);
  } else if (id === 'kafes') {
    /* kafes kule: daralan tepe + anten bantta */
    for (var y2 = 0; y2 < 46; y2++) {
      var g2 = Math.round(13 * Math.pow(1 - y2 / 46, 1.7)) + 1;
      px(cx - g2, y(y2), k1); px(cx + g2, y(y2), k1);
      if (y2 % 11 === 0) fr(cx - g2, y(y2), g2 * 2, 1, k2);
    }
    fr(cx - 2, y(43), 5, 3, k2);
    ln(cx, y(46), cx, y(51), k2);
  } else if (id === 'gokdelen') {
    /* kademeli sivri: son kademeler bantta */
    for (var s2 = 0; s2 < 6; s2++) {
      var sw = 15 - s2 * 2;
      fr(cx - (sw >> 1), y(8 + s2 * 7 + 9), sw, 10, s2 % 2 ? k2 : k1);
    }
    ln(cx, y(52), cx, y(60), k2);
    px(cx, y(56), isik);
  } else if (id === 'pagoda') {
    /* ust iki cati bantta kalsin */
    for (var pg = 0; pg < 5; pg++) {
      var pw = 24 - pg * 4, py = y(10 + pg * 8);
      fr(cx - (pw >> 1), py, pw, 2, k2);
      px(cx - (pw >> 1) - 1, py + 1, k2); px(cx + (pw >> 1), py + 1, k2);
      fr(cx - (pw >> 1) + 2, py + 2, pw - 4, 6, k1);
    }
    ln(cx, y(44), cx, y(50), k2);
  } else if (id === 'kuleler') {
    /* Manila: yeni is kuleleri + palmiye */
    var mb = [34, 46, 30, 40];
    for (var mn = 0; mn < mb.length; mn++) {
      var mbx = cx - 18 + mn * 10;
      fr(mbx, y(mb[mn]), 8, mb[mn], mn % 2 ? k2 : k1);
      for (var mw = 4; mw < mb[mn] - 2; mw += 4)
        if (hash1(mn * 3.7 + mw) > .5) px(mbx + 3, y(mb[mn] - mw), isik);
    }
    /* palmiye */
    var pxx = cx + 26;
    fr(pxx, y(20), 2, 20, k2);
    for (var pl = 0; pl < 5; pl++) {
      var pa = -0.5 + pl * 0.5;
      ln(pxx + 1, y(20), pxx + 1 + Math.round(Math.cos(pa) * 7), y(20) - Math.round(Math.sin(pa) * 5) - 2, k2);
    }
  } else if (id === 'manhattan') {
    /* gokdelenler: en uzunlar bantta */
    var boy = [30, 44, 34, 50, 32, 40];
    for (var n2 = 0; n2 < boy.length; n2++) {
      var bx = cx - 26 + n2 * 10;
      fr(bx, y(boy[n2]), 9, boy[n2], n2 % 2 ? k2 : k1);
      for (var wy2 = 3; wy2 < boy[n2] - 2; wy2 += 5) {
        if (hash1(n2 * 3.3 + wy2) > .42) px(bx + 2, y(boy[n2] - wy2), isik);
        if (hash1(n2 * 7.1 + wy2) > .52) px(bx + 6, y(boy[n2] - wy2), 'rgba(252,242,196,.45)');
      }
    }
    ln(cx + 4, y(50), cx + 4, y(56), k2);
  } else if (id === 'anit') {
    /* DEMİRKENT: rejimin dikilitaşı — üstünde yıldız, iki yanında bayrak.
       Yalnız üst ~16px görünür, tanınan detay oraya konuldu. */
    fr(cx - 5, y(46), 11, 46, k2);
    fr(cx - 4, y(46), 9, 45, k1);
    vl(cx - 4, y(45), 44, '#9aa0a6');
    for (var kt = 0; kt < 5; kt++) hl(cx - 4, y(40 - kt * 8), 9, k2);
    /* tepede yildiz */
    fr(cx - 1, y(52), 3, 6, '#b83228');
    fr(cx - 4, y(50), 9, 3, '#b83228');
    px(cx - 5, y(49), '#8e2318'); px(cx + 5, y(49), '#8e2318');
    px(cx, y(53), '#e2604f');
    /* yan bayraklar */
    for (var bd = -1; bd <= 1; bd += 2) {
      var bxx = cx + bd * 12;
      vl(bxx, y(34), 34, k2);
      fr(bd < 0 ? bxx - 7 : bxx + 1, y(34), 7, 5, '#b83228');
      px(bd < 0 ? bxx - 7 : bxx + 7, y(32), '#8e2318');
    }
  }
}
