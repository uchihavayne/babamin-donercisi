/* ============================================================
   DÖNER EFSANESİ — chars.js
   Usta (şef) ve müşteri karakterleri
   ============================================================ */
'use strict';

var SKINS = [
  ['#ffdcb0', '#f0bd8a', '#cf9560', '#a06f42'],
  ['#f6c99a', '#dda674', '#b8834f', '#8d5f34'],
  ['#d9a273', '#bd8354', '#96633a', '#6e4726'],
  ['#b07a45', '#8a5730', '#6b4122', '#4e2e17'],
  ['#ffe6c8', '#f2c9a2', '#d2a175', '#a87a50'],
  /* rampadaki bosluklari dolduran tonlar (5-8) */
  ['#f0d0a8', '#d8b088', '#b08a5c', '#856240'],
  ['#e8c4a0', '#cea67e', '#a87f56', '#7d5a38'],
  ['#c48f60', '#a67044', '#82522c', '#5d391c'],
  ['#9a6a3e', '#78502a', '#5a3a1c', '#3f2712']
];
var HAIRCOLS = ['#2b1d16', '#4a3020', '#7a5230', '#a8763c', '#d8d2c8', '#8e8e94', '#e8e4dc', '#5a2f1c'];
var SHIRTS = ['#4a7fc0', '#c95a4a', '#5aa86a', '#d8a03c', '#8a6ac0', '#3f9fa8', '#c96a9a', '#8a8f96', '#e0e4e8', '#5c6470'];

function shadeCol(hex, f) {
  var r = parseInt(hex.substr(1, 2), 16), g = parseInt(hex.substr(3, 2), 16), b = parseInt(hex.substr(5, 2), 16);
  r = clamp(Math.round(r * f), 0, 255); g = clamp(Math.round(g * f), 0, 255); b = clamp(Math.round(b * f), 0, 255);
  return 'rgb(' + r + ',' + g + ',' + b + ')';
}

/* ============================================================
   USTA — sol tarafta, tezgâhın arkasında
   st: {mode:'idle'|'slice'|'happy'|'box', armT}
   ============================================================ */
var NOCHEF = false;
function drawChef(x, y, st, t) {
  if (NOCHEF) return;      /* gece: dükkân boş */
  var bob = Math.sin(t * 1.7) * 1;
  var breathe = Math.sin(t * 2.4) * .7;
  var s = SKINS[0];
  /* --- CANLILIK: hepsi t'den turetilir, ayrica durum tutulmaz --- */
  var agirlik = Math.sin(t * .52) * 1.3;          /* yavas agirlik degistirme */
  var zipla = st.mode === 'happy' ? -Math.abs(Math.sin(t * 7)) * 3 : 0;
  /* her ~7.4 sn'de bir kisa jest: 0 biyik sivazla, 1 fes duzelt, 2 dur */
  var dongu = (t % 7.4) / 7.4;
  var jestTip = Math.floor(t / 7.4) % 3;
  var jestVar = st.mode === 'idle' && jestTip < 2 && dongu > .55 && dongu < .82;
  var jestK = jestVar ? Math.sin((dongu - .55) / .27 * Math.PI) : 0;
  var kafaDon = Math.round(Math.sin(t * .43) * 1.4);   /* kafa govdeden bagimsiz */
  ctx.save();
  ctx.translate(Math.round(agirlik), Math.round(zipla));
  var hx = x + 23;
  var fz = y + bob;              /* fes üstü */
  var hy = y + 30 + bob;         /* kafa merkezi */
  var by = y + 50 + bob;         /* omuz üstü */

  /* ---- gölge (ayakların altında) ---- */
  ctx.globalAlpha = .32; ell(hx, y + 152 + bob, 21, 4, '#000'); ctx.globalAlpha = 1;

  /* ---- bacaklar (şalvar) ---- */
  /* --- SALVAR ---
     Belde DAR (26px), uylukta bol (41px), bilekte toplanir (30px).
     Eskiden belde de 34px'ti; gomlekle ayni genislikte olunca belden
     asagisi ayri yapistirilmis bir blok gibi duruyordu. Bel kismi
     kusagin altinda kalir, o yuzden yukaridan baslar. */
  var lgy = by + 66, lgh = 30;          /* cizmeler bu iki degere bagli */
  var slTop = by + 58, slAlt = lgy + lgh - 4;   /* paca cizmenin ustune otursun */
  var slH = slAlt - slTop;
  var ayrimU = 0.52;                    /* bu orandan sonra iki bacak */
  var KEN = '#1e3a63', GOV = '#35619a', ISK = '#5285c4', GLG = '#20406e';
  var solBacak = null, sagBacak = null;  /* bilek lastikleri buna oturur */

  function bacakSerit(bx0, bw0, yy0) {
    if (bw0 < 3) return;
    fr(bx0, yy0, bw0, 1, KEN);
    fr(bx0 + 1, yy0, bw0 - 2, 1, GOV);
    px(bx0 + 1, yy0, ISK);                      /* ic isik */
    px(bx0 + bw0 - 2, yy0, GLG);                /* dis golge */
  }

  for (var lr = 0; lr < slH; lr++) {
    var lu = lr / (slH - 1);
    var yy0 = slTop + lr;
    /* Dis siluet TEK egridir: belde dar, uylukta bol, bilekte toplanir.
       Bacaklar bu siluetin ortasindan ince bir yarik kesilerek elde edilir.
       Bacaklari ayri ayri konumlandirmak dis hatti bozup carpik bacak
       gorunumu veriyordu. */
    var gen = Math.round(26 + Math.sin(lu * Math.PI * 0.82) * 16 - lu * 3);
    var lx0 = Math.round(x + 23 - gen / 2);
    if (lu < ayrimU) { bacakSerit(lx0, gen, yy0); continue; }
    var t1 = (lu - ayrimU) / (1 - ayrimU);
    var ara = 1 + Math.round(t1 * 2);            /* yarik 1 -> 3 px */
    var oy = Math.round(x + 23) - (ara >> 1);
    var solG = oy - lx0, sagX = oy + ara, sagG = lx0 + gen - sagX;
    bacakSerit(lx0, solG, yy0);
    bacakSerit(sagX, sagG, yy0);
    ctx.globalAlpha = .26;
    fr(oy, yy0, ara, 1, '#0e1c33');              /* bacak arasi golge */
    ctx.globalAlpha = 1;
    solBacak = [lx0, solG]; sagBacak = [sagX, sagG];
  }
  /* kumas kivrimlari: kalcadan dize dogru */
  ctx.globalAlpha = .16;
  for (var kv = 0; kv < 3; kv++) {
    var kvx = x + 12 + kv * 11;
    ln(kvx, slTop + 8, kvx + 2, slTop + 22, '#14284a');
  }
  ctx.globalAlpha = 1;
  /* bilek lastikleri: salvar burada toplanir. Genislikleri bacaklarin
     gercek olcusunden gelir; sabit degerler siluetin disina tasiyordu. */
  var blY = slAlt - 4, blSet = [solBacak, sagBacak];
  for (var bi2 = 0; bi2 < 2; bi2++) {
    var bl = blSet[bi2];
    if (!bl || bl[1] < 3) continue;
    fr(bl[0], blY, bl[1], 4, '#16294a');
    fr(bl[0] + 1, blY, bl[1] - 2, 3, '#2b4d80');
    hl(bl[0] + 1, blY, bl[1] - 2, '#4a7ab8');
  }
  fr(x + 4, lgy + 26, 16, 4, '#8a5230'); fr(x + 25, lgy + 26, 16, 4, '#8a5230');
  hl(x + 4, lgy + 26, 16, '#a5713f'); hl(x + 25, lgy + 26, 16, '#a5713f');
  ell(x + 11, lgy + 33, 10, 4, '#3a2418');
  ell(x + 11, lgy + 32, 10, 4, '#5b3a20');
  hl(x + 6, lgy + 30, 10, '#7a5230');
  ell(x + 33, lgy + 33, 10, 4, '#3a2418');
  ell(x + 33, lgy + 32, 10, 4, '#5b3a20');
  hl(x + 28, lgy + 30, 10, '#7a5230');

  /* ---- gövde ---- */
  ell(hx, by + 6, 23, 9, '#ded8c8');
  fr(x + 1, by + 6, 45, 62, '#ded8c8');
  fr(x + 2, by + 5, 43, 62, '#f4efe2');
  ell(hx, by + 5, 22, 8, '#f4efe2');
  ell(hx + 1, by + 52 + breathe, 21, 13, '#f8f4e8');
  ctx.globalAlpha = .14; ell(hx + 5, by + 56, 16, 8, '#a89a80'); ctx.globalAlpha = 1;
  for (var i = 0; i < 4; i++) {
    ctx.globalAlpha = .16;
    ln(x + 12 + i * 7, by + 16, x + 10 + i * 7, by + 34, '#a89a80');
    ctx.globalAlpha = 1;
  }
  /* yelek */
  fr(x + 1, by + 5, 15, 58, P.red3);
  fr(x + 2, by + 5, 13, 57, P.red1);
  fr(x + 3, by + 7, 10, 54, P.red0);
  ell(x + 8, by + 6, 8, 5, P.red1);
  fr(x + 31, by + 5, 15, 58, P.red3);
  fr(x + 32, by + 5, 13, 57, P.red1);
  fr(x + 33, by + 7, 10, 54, P.red0);
  ell(x + 38, by + 6, 8, 5, P.red1);
  vl(x + 15, by + 6, 57, P.au1); vl(x + 16, by + 6, 57, P.au2);
  vl(x + 30, by + 6, 57, P.au1); vl(x + 31, by + 6, 57, P.au2);
  for (var d = 0; d < 4; d++) { disc(x + 11, by + 16 + d * 11, 1, P.au0); disc(x + 36, by + 16 + d * 11, 1, P.au0); }
  /* yelek islemesi: sari sarmal motif */
  ctx.globalAlpha = .55;
  for (var im = 0; im < 5; im++) {
    var iy = by + 12 + im * 10;
    ln(x + 5, iy, x + 8, iy + 3, P.au2); ln(x + 8, iy + 3, x + 5, iy + 6, P.au2);
    ln(x + 42, iy, x + 39, iy + 3, P.au2); ln(x + 39, iy + 3, x + 42, iy + 6, P.au2);
  }
  ctx.globalAlpha = 1;
  /* ---- KUSAK ----
     Yelekle AYNI kirmizi ailede, altin seritli. Eskiden salvarla ayni
     maviydi ve belden asagisi tek blok gibi okunuyordu; renk ayrimi
     silueti uc banda boluyor: krem gomlek / kirmizi kusak / mavi salvar. */
  var kuy = by + 57, kuh = 12;
  fr(x + 2, kuy, 44, kuh, '#5e1a14');                  /* koyu kenar */
  fr(x + 3, kuy, 42, kuh - 1, '#8e2b20');
  fr(x + 3, kuy + 1, 42, kuh - 4, '#a8392a');          /* govde */
  hl(x + 4, kuy + 1, 40, '#c4523c');                   /* ust isik */
  /* altin seritler */
  ctx.globalAlpha = .85;
  hl(x + 4, kuy + 3, 40, P.au2);
  hl(x + 4, kuy + kuh - 4, 40, P.au2);
  ctx.globalAlpha = 1;
  /* kumas kivrimlari */
  ctx.globalAlpha = .20;
  for (var w2 = 0; w2 < 5; w2++) {
    ln(x + 8 + w2 * 8, kuy + 2, x + 10 + w2 * 8, kuy + kuh - 2, '#40100c');
  }
  ctx.globalAlpha = 1;
  /* SAG YANDA dugum ve sarkan uc: kusagin baglandigi belli olsun */
  fr(x + 33, kuy + 1, 9, kuh - 2, '#7a2419');
  fr(x + 34, kuy + 2, 7, kuh - 4, '#a8392a');
  hl(x + 35, kuy + 2, 5, '#c4523c');
  px(x + 37, kuy + 5, '#5e1a14');
  fr(x + 36, kuy + kuh - 1, 5, 7, '#7a2419');          /* sarkan uc */
  fr(x + 36, kuy + kuh - 1, 4, 6, '#983224');
  for (var pu = 0; pu < 4; pu++) px(x + 36 + pu, kuy + kuh + 6, '#5e1a14');
  /* kusagin salvara dusurdugu golge: iki parca birbirine otursun */
  ctx.globalAlpha = .34; hl(x + 6, kuy + kuh, 36, '#0e1c33'); ctx.globalAlpha = 1;
  ctx.globalAlpha = .18; hl(x + 7, kuy + kuh + 1, 34, '#0e1c33'); ctx.globalAlpha = 1;

  /* ---- kollar ---- */
  var armSw = st.mode === 'slice' ? Math.sin(st.armT * 15) * 5 : 0;
  if (st.mode === 'slice') {
    fr(x + 38, by + 8, 10, 20, '#e2dccc');
    fr(x + 39, by + 8, 9, 19, '#f8f4e8');
    fr(x + 42, by + 22 + armSw, 8, 12, s[1]);
    fr(x + 42, by + 22 + armSw, 8, 11, s[0]);
    ell(x + 46, by + 32 + armSw, 5, 5, s[1]);
    ell(x + 46, by + 31 + armSw, 5, 4, s[0]);
    fr(x - 1, by + 14, 10, 22, '#e2dccc');
    fr(x, by + 14, 9, 21, '#f8f4e8');
    ell(x + 4, by + 37, 5, 5, s[1]); ell(x + 4, by + 36, 5, 4, s[0]);
  } else if (st.mode === 'happy') {
    fr(x - 3, by - 12, 10, 24, '#f8f4e8'); ell(x + 2, by - 14, 5, 5, s[0]);
    fr(x + 40, by - 12, 10, 24, '#f8f4e8'); ell(x + 45, by - 14, 5, 5, s[0]);
  } else if (st.mode === 'box') {
    fr(x + 2, by + 22, 42, 24, '#a87840');
    fr(x + 3, by + 22, 40, 23, '#d8a464');
    hl(x + 3, by + 22, 40, '#eccb92');
    for (var b2 = 0; b2 < 4; b2++) hl(x + 6, by + 27 + b2 * 5, 34, '#c09055');
    fr(x + 20, by + 22, 7, 24, '#b8894e');
    txt('ET', x + 23, by + 30, '#6d4a22', { align: 'c' });
    fr(x - 2, by + 16, 10, 16, '#f8f4e8'); ell(x + 3, by + 34, 5, 5, s[1]);
    fr(x + 38, by + 16, 10, 16, '#f8f4e8'); ell(x + 43, by + 34, 5, 5, s[1]);
  } else {
    /* sol kol: OMUZDAN baslar. Eskiden by+14'ten, yani govdenin
       ortasindan basliyordu ve kol yapistirilmis gibi duruyordu. */
    fr(x - 2, by + 8, 10, 31, '#e2dccc');
    fr(x - 1, by + 8, 9, 30, '#f8f4e8');
    ell(x + 3, by + 9, 6, 4, '#f8f4e8');              /* omuz yuvarlagi */
    ctx.globalAlpha = .16; fr(x - 2, by + 9, 3, 30, '#000'); ctx.globalAlpha = 1;
    fr(x - 2, by + 34, 10, 3, '#d8d2c0');             /* manset */
    ell(x + 3, by + 41 + breathe, 5, 5, s[1]); ell(x + 3, by + 40 + breathe, 5, 4, s[0]);
    /* sag kol: jest sirasinda el yuze dogru kalkar
       (jestTip 0 -> biyigi sivazlar, 1 -> fesi duzeltir).
       Kol OMUZDAN ELE dogru cizilir; yoksa el havada kopuk kaliyor. */
    var omzX = x + 43, omzY = by + 10;               /* omuz, govde ortasi degil */
    var dinX = x + 44, dinY = by + 41 - breathe;
    var hedX = hx + 12, hedY = hy + (jestTip === 1 ? -4 : 9);
    var elX = Math.round(dinX + (hedX - dinX) * jestK);
    var elY = Math.round(dinY + (hedY - dinY) * jestK);
    for (var kk = 0; kk <= 16; kk++) {
      var u4 = kk / 16;
      var ax2 = Math.round(omzX + (elX - omzX) * u4);
      var ay2 = Math.round(omzY + (elY - omzY) * u4);
      fr(ax2 - 4, ay2 - 2, 9, 4, '#e2dccc');
      fr(ax2 - 3, ay2 - 2, 8, 3, '#f8f4e8');
    }
    ell(omzX - 1, omzY + 1, 6, 4, '#f8f4e8');        /* omuz yuvarlagi */
    fr(elX - 4, elY - 4, 9, 3, '#d8d2c0');        /* manset */
    ell(elX, elY + 1, 5, 5, s[1]); ell(elX, elY, 5, 4, s[0]);
  }

  /* ---- boyun ---- */
  fr(hx - 6, hy + 13, 12, 8, s[2]);
  fr(hx - 5, hy + 13, 10, 7, s[1]);
  ctx.globalAlpha = .25; fr(hx - 6, hy + 13, 12, 3, '#000'); ctx.globalAlpha = 1;

  /* ---- kafa (govdeden bagimsiz hafif donus) ---- */
  hx += kafaDon;
  ell(hx, hy, 15, 14, s[2]);
  ell(hx - 1, hy - 1, 14, 13, s[0]);
  ell(hx + 5, hy + 2, 10, 11, s[1]);
  ctx.globalAlpha = .3; ell(hx + 10, hy + 2, 5, 8, s[2]); ctx.globalAlpha = 1;
  ell(hx - 15, hy + 3, 3, 5, s[1]); px(hx - 16, hy + 3, s[2]);
  ell(hx + 15, hy + 3, 3, 5, s[1]); px(hx + 16, hy + 3, s[2]);
  fr(hx - 16, hy - 4, 5, 10, '#eeeeea');
  fr(hx + 12, hy - 4, 5, 10, '#eeeeea');
  ell(hx - 14, hy + 5, 4, 4, '#dcdcd6'); ell(hx + 14, hy + 5, 4, 4, '#dcdcd6');

  /* ---- fes ---- */
  fr(hx - 13, fz + 5, 27, 14, P.red3);
  fr(hx - 12, fz + 5, 25, 13, P.red2);
  fr(hx - 11, fz + 6, 21, 12, P.red1);
  fr(hx - 10, fz + 7, 9, 10, P.red0);
  hl(hx - 11, fz + 6, 21, '#f28a70');
  ell(hx, fz + 5, 14, 3, P.red1);
  ell(hx, fz + 4, 14, 3, '#e8674f');
  ell(hx - 4, fz + 3, 6, 1, '#f4a08a');
  ctx.globalAlpha = .3; hl(hx - 12, fz + 18, 25, '#000'); ctx.globalAlpha = 1;
  var tsw = Math.sin(t * 2.2) * 3;
  ln(hx + 11, fz + 4, hx + 15 + tsw, fz + 16, '#241a14');
  ln(hx + 11, fz + 4, hx + 14 + tsw, fz + 15, '#3a2a20');
  disc(hx + 15 + tsw, fz + 17, 2, '#241a14');
  px(hx + 14 + tsw, fz + 16, '#4a3a2a');

  /* ---- yüz ---- */
  /* gur beyaz kaslar: mutluyken kalkar, jest sirasinda hafif oynar */
  var kasY = hy - 6 - (st.mode === 'happy' ? 1 : 0) - Math.round(jestK);
  fr(hx - 11, kasY, 7, 3, '#efefe9'); px(hx - 12, kasY + 1, '#efefe9');
  px(hx - 12, kasY + 2, '#dcdcd6'); px(hx - 4, kasY - 1, '#efefe9');
  fr(hx + 4, kasY, 7, 3, '#efefe9'); px(hx + 11, kasY + 1, '#efefe9');
  px(hx + 11, kasY + 2, '#dcdcd6'); px(hx + 3, kasY - 1, '#efefe9');
  var blink = (hash1(Math.floor(t * 1.3)) > .90);
  if (blink) { fr(hx - 10, hy, 6, 1, s[3]); fr(hx + 4, hy, 6, 1, s[3]); }
  else {
    fr(hx - 10, hy - 3, 6, 6, '#ffffff'); fr(hx + 4, hy - 3, 6, 6, '#ffffff');
    var lookx = st.mode === 'slice' ? 1 : (Math.sin(t * .6) > 0 ? 1 : 0);
    fr(hx - 8 + lookx, hy - 1, 3, 3, '#2b2018'); fr(hx + 6 + lookx, hy - 1, 3, 3, '#2b2018');
    px(hx - 8 + lookx, hy - 1, '#6a5a4a'); px(hx + 6 + lookx, hy - 1, '#6a5a4a');
  }
  ell(hx - 1, hy + 5, 6, 6, s[3]);
  ell(hx - 1, hy + 4, 6, 5, s[1]);
  ell(hx - 1, hy + 3, 5, 4, s[0]);
  ell(hx - 3, hy + 2, 3, 2, '#fff0dc');
  px(hx + 4, hy + 6, s[3]); px(hx - 6, hy + 6, s[3]);
  hl(hx - 5, hy + 9, 10, s[2]);
  ctx.globalAlpha = .32;
  ell(hx - 11, hy + 6, 4, 3, '#e07a68'); ell(hx + 9, hy + 6, 4, 3, '#e07a68');
  ctx.globalAlpha = 1;
  fr(hx - 10, hy + 10, 20, 4, '#f4f4f0');
  fr(hx - 13, hy + 9, 5, 4, '#f4f4f0');
  fr(hx + 8, hy + 9, 5, 4, '#f4f4f0');
  px(hx - 14, hy + 8, '#f4f4f0'); px(hx + 13, hy + 8, '#f4f4f0');
  px(hx - 15, hy + 7, '#e8e8e2'); px(hx + 14, hy + 7, '#e8e8e2');
  hl(hx - 9, hy + 10, 18, '#ffffff');
  ctx.globalAlpha = .3; hl(hx - 8, hy + 13, 16, '#c8c8c2'); ctx.globalAlpha = 1;
  if (st.mode === 'happy') {
    /* daha genis gulumseme + yanaklarda kirisik */
    fr(hx - 7, hy + 14, 15, 4, '#7a3a30');
    hl(hx - 6, hy + 17, 13, '#c9584a');
    hl(hx - 6, hy + 14, 13, '#ffffff');
    ln(hx - 12, hy + 11, hx - 10, hy + 14, s[3]);
    ln(hx + 11, hy + 11, hx + 9, hy + 14, s[3]);
  } else hl(hx - 4, hy + 14, 9, '#a86a5a');
  ctx.restore();
}

/* ============================================================
   MÜŞTERİLER
   ============================================================ */
/* Yuz kimligi: goz / burun / kas / agiz / yanak. Sac ve kiyafet zaten
   degisiyordu ama yuz sabitti, herkes ayni adam gibi duruyordu. */
/* Musteri tipi: sacini, yuz tuylerini ve boyunu belirler. */
function yeniTip(r) {
  var a = r();
  return a < .42 ? 'adam' : (a < .80 ? 'kadin' : 'cocuk');
}
function yeniYuz(r) {
  var y = r();
  return {
    sekil: Math.floor(r() * 5),   /* 0 oval 1 uzun 2 kare 3 yuvarlak 4 kalp */
    goz: Math.floor(r() * 6),     /* 0 normal 1 dar 2 iri 3 ayrik 4 bitisik 5 dusuk */
    gozR: Math.floor(r() * 4),    /* 0 kahve 1 mavi 2 yesil 3 ela */
    burun: Math.floor(r() * 5),   /* 0 kucuk 1 genis 2 uzun 3 kemerli 4 kalkik */
    kas: Math.floor(r() * 5),     /* 0 normal 1 kalin 2 ince 3 catik 4 kavisli */
    agiz: Math.floor(r() * 5),    /* 0 normal 1 genis 2 kucuk 3 dolgun 4 ince */
    gozB: Math.floor(r() * 6),    /* goz BICIMI: 0 duz 1 badem 2 yuvarlak
                                     3 kapakli 4 cekik 5 dusuk kose */
    oran: Math.floor(r() * 3),    /* hatlari toplu 1px yukari/asagi al */
    aralik: Math.floor(r() * 3),  /* gozler arasi mesafe */
    agizU: Math.floor(r() * 3),   /* burun ile agiz arasi (filtrum) */
    kulak: Math.floor(r() * 3),   /* 0 normal 1 buyuk 2 kucuk */
    cene: Math.floor(r() * 3),    /* 0 duz 1 gamzeli 2 cift */
    yas: y < .58 ? 0 : (y < .82 ? 1 : 2),   /* 0 genc 1 orta 2 yasli */
    yanak: r() < .28,
    cil: r() < .17,
    ben: r() < .15 ? 1 + Math.floor(r() * 3) : 0
  };
}
/* KAFA KONTURU — her satir icin yari genislik.
   Elips yerine satir satir cizmek gercek alin/elmacik/cene farki veriyor;
   22x22'lik bir kafada ilk okunan sey konturdur, hatlar degil. */
function kafaKontur(sekil, hw, hh) {
  var g = [], n = hh * 2 + 1;
  for (var i = 0; i < n; i++) {
    var dy = i - hh, u = i / (n - 1);
    var e = Math.sqrt(Math.max(0, 1 - (dy * dy) / (hh * hh))), f;
    switch (sekil) {
      case 1:                                   /* UZUN: dar yuz, uzayan cene */
        f = Math.pow(e, .62) * (0.90 - u * 0.16);
        if (u > .74) f *= 1 - (u - .74) * 1.9;
        break;
      case 2:                                   /* KARE: genis, duz cene hatti */
        f = u < .30 ? Math.pow(e, .78)
          : (u < .82 ? Math.max(Math.pow(e, .78), 0.93) : 0.93 - (u - .82) * 4.0);
        break;
      case 3:                                   /* YUVARLAK: dolgun, kisa cene */
        f = Math.pow(e, .58) * 1.05;
        if (u > .88) f *= 1 - (u - .88) * 4.0;
        break;
      case 4:                                   /* KALP: genis alin, sivri cene */
        f = Math.pow(e, .70) * (1.10 - u * 0.10) - Math.pow(u, 3.0) * 0.55;
        break;
      default:                                  /* OVAL (eski kafa) */
        f = e;
        break;
    }
    var wv = Math.round(f * hw);
    g.push(wv < 2 ? 0 : wv);        /* 1px kalan uc sivri cikinti gibi duruyordu */
  }
  return g;
}
var GOZ_RENK = ['#2b2018', '#33557e', '#3c6347', '#6a5230'];
/* GOZ AKI — bicime gore. Eskiden her goz ayni beyaz dikdortgendi;
   22x22'lik bir kafada en cok okunan sey goz, hepsi ayni dikdortgen
   olunca butun yuzler ayni adam gibi duruyordu.
   yon: -1 sol goz, +1 sag goz (asimetrik bicimler icin). */
function gozAki(ex, ey, w, h, bicim, yon, s) {
  var AK = '#ffffff';
  if (bicim === 2) {                       /* YUVARLAK */
    var ry = Math.max(2, (h - 1) >> 1);
    ell(ex + ((w - 1) >> 1), ey + ((h - 1) >> 1), Math.max(2, (w - 1) >> 1), ry, AK);
  } else if (bicim === 1) {                /* BADEM: kose satirlari yumusar */
    var enKis = Math.max(0, (w - 3) >> 1);   /* en az 3px beyaz kalsin */
    for (var i = 0; i < h; i++) {
      var u = h > 1 ? Math.abs(i - (h - 1) / 2) / ((h - 1) / 2) : 0;
      var kis = Math.min(enKis, Math.round(Math.pow(u, 1.8) * 1.6));
      fr(ex + kis, ey + i, w - kis * 2, 1, AK);
    }
  } else if (bicim === 3) {                /* KAPAKLI: ust kapak iner */
    fr(ex, ey + 2, w, Math.max(1, h - 2), AK);
    fr(ex, ey, w, 2, s[2]);
    hl(ex, ey + 1, w, s[3]);
  } else if (bicim === 4) {                /* CEKIK: ince yarik */
    fr(ex, ey + Math.max(1, ((h - 2) >> 1)), w, 2, AK);
    hl(ex, ey + Math.max(0, ((h - 2) >> 1) - 1), w, s[3]);
  } else if (bicim === 5) {                /* DUSUK: dis kose asagi kayar */
    for (var c = 0; c < w; c++) {
      var dis = yon < 0 ? c : (w - 1 - c);
      var kay = dis < 2 ? 1 : 0;
      fr(ex + c, ey + kay, 1, Math.max(1, h - kay), AK);
    }
  } else {                                 /* DUZ (eski) */
    fr(ex, ey, w, h, AK);
  }
}
/* Eski kayitlarda yuz alani yok: tohumdan tureterek ayni musteri hep ayni
   gorunsun (kayit bozulmasin). */
function yuzKimlik(L) {
  var h = L.seed || 0, F = L.yuz;
  /* Eski kayit hic yuz tasimiyor ya da ESKI (dar) kumeyi tasiyor.
     Ikisinde de eksik alanlari tohumdan turetiyoruz: ayni musteri hep ayni
     kaliyor, kayit bozulmuyor, yeni alanlar yine de cesitleniyor. */
  if (!F) F = {};
  if (F.sekil === undefined) F.sekil = Math.floor(hash1(h * 1.3) * 5);
  if (F.goz === undefined) F.goz = Math.floor(hash1(h * 1.7) * 6);
  if (F.gozR === undefined) F.gozR = Math.floor(hash1(h * 2.1) * 4);
  if (F.burun === undefined) F.burun = Math.floor(hash1(h * 3.1) * 5);
  if (F.kas === undefined) F.kas = Math.floor(hash1(h * 5.3) * 5);
  if (F.agiz === undefined) F.agiz = Math.floor(hash1(h * 7.9) * 5);
  if (F.gozB === undefined) F.gozB = Math.floor(hash1(h * 2.7) * 6);
  if (F.oran === undefined) F.oran = Math.floor(hash1(h * 4.1) * 3);
  if (F.aralik === undefined) F.aralik = Math.floor(hash1(h * 6.7) * 3);
  if (F.agizU === undefined) F.agizU = Math.floor(hash1(h * 8.3) * 3);
  if (F.kulak === undefined) F.kulak = Math.floor(hash1(h * 9.1) * 3);
  if (F.cene === undefined) F.cene = Math.floor(hash1(h * 13.7) * 3);
  if (F.yas === undefined) {
    var yv = hash1(h * 17.3);
    F.yas = yv < .58 ? 0 : (yv < .82 ? 1 : 2);
  }
  if (F.yanak === undefined) F.yanak = hash1(h * 11.3) < .28;
  if (F.cil === undefined) F.cil = hash1(h * 19.1) < .17;
  if (F.ben === undefined) {
    F.ben = hash1(h * 23.9) < .15 ? 1 + Math.floor(hash1(h * 29.3) * 3) : 0;
  }
  L.yuz = F;
  return F;
}
/* Dunya fermanlari halkin gorunusunu degistirir: tek tip tulum, aciik bas,
   tras mecburiyeti. newCustomerLook'un IKI cikisi var, ikisi de buradan
   gecer — yoksa sehir profili olmayan durumda ferman islemiyordu. */
var FERMAN_TULUM = '#5c6350';        /* devletin verdigi haki tulum */
function fermanGorunum(L) {
  /* Baslikli kalip (baret/kask/kasket/sapka) varsa mevcut aksesuari kapat:
     iki sapka ust uste biniyor. */
  if (L.kalip && L.kalip !== 'yok' && kalipById(L.kalip).baslik &&
      (L.acc === 'cap' || L.acc === 'kufiya' || L.acc === 'band')) L.acc = 'none';
  /* Ozel kaliplarin kendi sac/sakal/gozluk tasarimi var. Temel sistemin
     saci ve aksesuari kalibin uzerinden tasiyordu: kimyager kel olmasi
     gerekirken uzun sacli, cirak sakalli cikiyordu. */
  if (L.kalip && OZEL_KALIP[L.kalip]) {
    L.acc = 'none';
    L.mustache = false;
    L.hair = -1;                      /* kalip kendi sacini ciziyor */
    /* Gozlugu kalip katmaninda cizmek ise yaramiyor: drawKalipBas
       yuzden ONCE cagriliyor, yuz sistemi gozleri gozlugun uzerine
       ciziyor. Temel gozluk sistemi yuzden SONRA cizildigi icin
       cerceve oraya birakiliyor. */
    if (L.kalip === 'cirak' || L.kalip === 'kimyager') {
      L.acc = 'glasses';
      L.glTip = 1;                    /* YUVARLAK cerceve */
    }
    /* Tek kisi: ten/yuz/boy/tip sabit. Yoksa her gelen baska biri
       oluyordu - ayni cirak degil, cirak KILIGINDA rastgele biri. */
    var KK = KALIP_KIMLIK[L.kalip];
    if (KK) {
      L.tip = KK.tip; L.skin = KK.skin; L.big = KK.big;
      /* Yuz nesnesini KOMPLE degistirmek yanlis: yeniYuz() kulak,
         cene, yas, filtrum gibi alanlar da uretiyor ve onlar
         undefined kaliyordu. Yalniz kimligi belirleyen alanlar
         mevcut nesnenin uzerine yaziliyor. */
      if (!L.yuz) L.yuz = yeniYuz(Math.random);
      for (var yk in KK.yuz) if (KK.yuz.hasOwnProperty(yk)) L.yuz[yk] = KK.yuz[yk];
    }
  }
  if (typeof fermanDunya !== 'function') return L;
  if (fermanDunya('tekTip')) { L.shirtCol = FERMAN_TULUM; L.shirt = 0; }
  if (fermanDunya('bassiz') && (L.acc === 'cap' || L.acc === 'kufiya' || L.acc === 'band')) L.acc = 'none';
  if (fermanDunya('tras')) { L.mustache = false; if (L.acc === 'beard') L.acc = 'none'; }
  return L;
}
function newCustomerLook(seed) {
  var r = Math.random;
  /* Sehrin kendi musteri profili: ten/sac/gomlek dagilimi ve
     aksesuar egilimi degisir. Profil yoksa eski duzgun dagilim. */
  var P = null;
  if (typeof sehirTema === 'function') { var tm = sehirTema(); if (tm && tm.musteri) P = tm.musteri; }
  function sec(dizi) { return dizi[Math.floor(r() * dizi.length)]; }
  if (!P) {
    var a0 = r(), t0 = yeniTip(r);
    return fermanGorunum({
      skin: Math.floor(r() * SKINS.length),
      hair: t0 === 'kadin' ? 8 + Math.floor(r() * 3) : Math.floor(r() * 8),
      hairCol: Math.floor(r() * HAIRCOLS.length),
      shirt: Math.floor(r() * SHIRTS.length),
      /* kadin ve cocukta sakal/biyik yok, kufiye erkege ozel */
      acc: (function () {
        var a = a0 < .15 ? 'glasses' : (a0 < .28 ? 'cap' : (a0 < .40 ? 'kufiya' : (a0 < .50 ? 'band' : (a0 < .62 ? 'beard' : 'none'))));
        if (t0 !== 'adam' && (a === 'beard' || a === 'kufiya')) a = 'none';
        return a;
      })(),
      mustache: t0 === 'adam' && r() < .38,
      big: t0 === 'cocuk' ? false : r() < .32,
      yuz: yeniYuz(r),
      kalip: KALIP_ACIK ? kalipSec(r, t0, true) : 'yok',
      tip: t0,
      seed: seed
    });
  }
  /* aksesuar: olasiliklar sirayla tuketilir, kalan 'none' */
  var a = r(), acc = 'none', esik = 0, K = P.aks;
  var sira = ['glasses', 'cap', 'kufiya', 'band', 'beard'];
  for (var i = 0; i < sira.length; i++) {
    esik += (K[sira[i]] || 0);
    if (a < esik) { acc = sira[i]; break; }
  }
  var tp = yeniTip(r);
  /* Sehir profili ten listesi 0-4 arasini kullaniyor; yeni tonlar hic
     cikmazdi. Besde bir tam listeden secip sehrin karakterini bozmadan
     cesitlilik ekliyoruz. */
  var tenI = r() < .22 ? Math.floor(r() * SKINS.length) : sec(P.ten);
  return fermanGorunum({
    skin: clamp(tenI, 0, SKINS.length - 1),
    hair: tp === 'kadin' ? 8 + Math.floor(r() * 3) : Math.floor(r() * 8),
    hairCol: clamp(sec(P.sac), 0, HAIRCOLS.length - 1),
    shirt: Math.floor(r() * SHIRTS.length),
    shirtCol: sec(P.gomlek),          /* sehre ozel gomlek rengi */
    acc: tp === 'adam' ? acc : (acc === 'beard' || acc === 'kufiya' ? 'none' : acc),
    mustache: tp === 'adam' && r() < (P.biyik === undefined ? .38 : P.biyik),
    big: tp === 'cocuk' ? false : r() < .32,
    yuz: yeniYuz(r),
    kalip: KALIP_ACIK ? kalipSec(r, tp, true) : 'yok',
    tip: tp,
    seed: seed
  });
}
function drawCustomer(c, t) {
  /* shirtCol varsa sehir paletinden gelir; eski kayitlar SHIRTS'e duser */
  var L = c.look, s = SKINS[L.skin], hc = HAIRCOLS[L.hairCol], sh = L.shirtCol || SHIRTS[L.shirt];
  var bob = Math.sin(t * 2 + L.seed) * (c.mood === 'angry' ? 1.7 : .8);
  var jitter = c.mood === 'angry' ? Math.round(Math.sin(t * 26)) : 0;
  var jump = (c.mood === 'happy' || c.mood === 'served') ? -Math.abs(Math.sin(t * 8)) * 2 : 0;
  var sway = (c.state === 'walkin' || c.state === 'leave') ? Math.sin(t * 11) * 1.2 : 0;
  var x = Math.round(c.x + jitter + sway), y = Math.round(c.y + bob + jump);
  /* Eski kayitlarda tip yok: tohumdan turet, ayni musteri hep ayni kalsin. */
  var tip = L.tip || (hash1((L.seed || 0) * 2.3) < .42 ? 'adam'
                     : (hash1((L.seed || 0) * 2.3) < .80 ? 'kadin' : 'cocuk'));
  var cocuk = tip === 'cocuk', kadin = tip === 'kadin';
  var wide = cocuk ? -4 : (L.big ? 3 : 0);
  var hy = y - 42 + (cocuk ? 11 : 0), hx = x;

  /* ---- Blender atlasi olan ozel karakter ----
     Bes ozel kalip (kralice / kuzeyli / cirak / bilge / kimyager)
     tam sprite ile ciziliyor. Oyunun kendi govde+kafa+aksesuar katmanlari
     ATLANIR; ust uste binerse iki yuz, iki govde gorunur. Duygu
     efektleri (ofke damari, kalpler) sprite'in uzerinde devam eder. */
  if (typeof sprMusteri === 'function' && sprMusteri(c, t, x, y)) {
    sprDuygu(hx, hy, c.mood, t);
    return;
  }

  /* ---- gövde ---- */
  var by = y - 30 + (cocuk ? 9 : 0);
  var bw = 26 + wide * 2;
  /* omuz eğrisi */
  ell(x, by + 5, bw / 2, 7, shadeCol(sh, .72));
  fr(x - bw / 2, by + 5, bw, 26, shadeCol(sh, .72));
  ell(x, by + 4, bw / 2 - 1, 6, sh);
  fr(x - bw / 2 + 1, by + 4, bw - 2, 26, sh);
  /* sol aydınlık */
  fr(x - bw / 2 + 1, by + 5, 7, 25, shadeCol(sh, 1.14));
  /* sağ gölge */
  ctx.globalAlpha = .20; fr(x + 3, by + 4, bw / 2 - 3, 27, '#000'); ctx.globalAlpha = 1;
  /* kollar */
  fr(x - bw / 2 - 3, by + 8, 5, 22, shadeCol(sh, .80));
  fr(x - bw / 2 - 3, by + 8, 4, 21, shadeCol(sh, .92));
  fr(x + bw / 2 - 2, by + 8, 5, 22, shadeCol(sh, .66));
  /* eller (tezgâhta) */
  if (c.state === 'wait') {
    var hy2 = by + 27;
    ell(x - bw / 2 - 1, hy2 + 1, 3, 3, s[2]);
    ell(x - bw / 2 - 1, hy2, 3, 3, s[1]);
    px(x - bw / 2 - 2, hy2 - 1, s[0]);
    ell(x + bw / 2, hy2 + 1, 3, 3, s[2]);
    ell(x + bw / 2, hy2, 3, 3, s[1]);
    px(x + bw / 2 + 1, hy2 - 1, s[0]);
  }
  /* yaka */
  fr(x - 6, by + 2, 12, 4, shadeCol(sh, .62));
  fr(x - 3, by + 1, 6, 5, s[1]);
  ln(x - 5, by + 3, x, by + 7, shadeCol(sh, .55));
  ln(x + 5, by + 3, x, by + 7, shadeCol(sh, .55));
  /* desen */
  if (L.seed % 3 === 0) {
    for (var i = 0; i < 8; i++) px(x - 9 + (i * 5) % 19, by + 10 + (i * 7) % 18, shadeCol(sh, 1.35));
  } else if (L.seed % 5 === 0) {
    for (var j = 0; j < 3; j++) hl(x - bw / 2 + 1, by + 10 + j * 7, bw - 2, shadeCol(sh, .84));
  }
  /* ---- kalip: kiyafet katmani (isci tulumu, ceket, kapusonlu...) ---- */
  var KLP = kalipKimlik(L);
  drawKalipGovde(KLP, x, by, bw, sh, s, L);

  /* ---- boyun ---- */
  fr(hx - 4, hy + 10, 8, 6, s[2]);
  fr(hx - 3, hy + 10, 6, 5, s[1]);

  /* ---- kafa ----
     Satir satir cizilir: 5 farkli kontur (oval/uzun/kare/yuvarlak/kalp).
     Eskiden tek bir elipsti, herkes ayni kafa seklindeydi. */
  var F = yuzKimlik(L);
  var hw = cocuk ? 9 : (L.big ? 12 : 11), hh = 11;
  /* cocukta sivri ya da kare cene yanlis duruyor: hep yuvarlak */
  var yzS = cocuk ? 3 : F.sekil;
  var KON = kafaKontur(yzS, hw, hh);
  function konG(dy) { var ki = dy + hh; return (ki >= 0 && ki < KON.length) ? KON[ki] : 0; }
  for (var kr = 0; kr < KON.length; kr++) {
    var kw = KON[kr]; if (kw <= 0) continue;
    var ky = hy - hh + kr;
    fr(hx - kw, ky, kw * 2 + 1, 1, s[2]);              /* kontur */
    if (kw >= 2) fr(hx - kw + 1, ky, kw * 2 - 1, 1, s[0]);   /* aydinlik yuz */
  }
  /* Sag yanak orta tonu: DUZGUN elips, kontura kirpilir. Satir basina
     yuzdeyle hesaplayinca kenari tirtiklaniyor, yuzde leke gibi duruyordu. */
  var ycx = hx + Math.round(hw * .36), ycR = Math.max(3, Math.round(hw * .58));
  for (var kc = 0; kc < KON.length; kc++) {
    var cw = KON[kc]; if (cw < 2) continue;
    var cy = hy - hh + kc, dyc = cy - (hy + 1);
    if (Math.abs(dyc) > 8) continue;
    var yar = Math.floor(ycR * Math.sqrt(1 - (dyc * dyc) / 64) + .5);
    var ca = Math.max(ycx - yar, hx - cw + 1), cb = Math.min(ycx + yar, hx + cw - 1);
    if (cb >= ca) fr(ca, cy, cb - ca + 1, 1, s[1]);
  }
  ctx.globalAlpha = .30;                               /* sag kenar golgesi */
  for (var kg = 4; kg < KON.length - 2; kg++) {
    if (KON[kg] < 3) continue;
    fr(hx + KON[kg] - 2, hy - hh + kg, 2, 1, s[2]);
  }
  ctx.globalAlpha = 1;
  /* KULAKLAR — kafanin gercek genisligine oturur, sabit hw'ye degil */
  var kuG = konG(2);
  if (F.kulak === 1) {                                 /* kepce: 3px disari */
    ell(hx - kuG - 1, hy + 2, 2, 4, s[1]); ell(hx + kuG + 1, hy + 2, 2, 4, s[1]);
    px(hx - kuG - 1, hy + 2, s[3]); px(hx + kuG + 1, hy + 2, s[3]);
    px(hx - kuG - 1, hy + 1, s[2]); px(hx + kuG + 1, hy + 1, s[2]);
  } else if (F.kulak === 2) {                          /* kucuk: 1px */
    ell(hx - kuG, hy + 2, 1, 2, s[1]); ell(hx + kuG, hy + 2, 1, 2, s[1]);
    px(hx - kuG, hy + 2, s[2]); px(hx + kuG, hy + 2, s[2]);
  } else {                                             /* normal: 2px */
    ell(hx - kuG, hy + 2, 2, 3, s[1]); ell(hx + kuG, hy + 2, 2, 3, s[1]);
    px(hx - kuG, hy + 2, s[2]); px(hx + kuG, hy + 2, s[2]);
  }

  /* Sac ve aksesuar SAC HIZASINDAKI gercek kafa genisligini alir.
     Sabit hw ile cizilince dar konturlarda 2px havada kaliyorlardi. */
  var sacG = Math.max(6, konG(-5));
  drawHair(hx, hy, sacG, L.hair, hc, s);
  drawAcc(hx, hy, sacG, L, sh, hc);
  drawKalipBas(KLP, hx, hy, sacG, s, L);      /* baret / kask / kasket / sapka */

  /* ---- yüz ---- */
  var mood = c.mood, ang = mood === 'angry', hap = (mood === 'happy' || mood === 'served');
  var imp = c.patience !== undefined && c.patience < .35 && !hap;
  /* Dar yuzlerde goz/kas ice kayar, yoksa konturun disina tasiyorlar. */
  var icE = Math.max(0, Math.min(2, Math.round((11 - konG(-1)) * .6)));
  /* HAT KUMESI: kas-goz-burun-agiz topluca 1px yukari/asagi. Kontur
     ayni kalsa bile bu tek basina 'baska bir insan' hissi veriyor;
     eskiden butun hatlar hy'ye sabit uzakliktaydi. */
  var fy = hy + ((F.oran === undefined ? 1 : F.oran) - 1);
  var agzU = (F.agizU === undefined ? 1 : F.agizU) - 1;   /* filtrum boyu */
  var browY = fy - 5 + (ang ? 2 : 0);
  var kaW = (F.kas === 2 || F.kas === 4) ? 4 : 5, kaH = F.kas === 1 ? 3 : 2;
  var kaD = F.kas === 1 ? 1 : 0;                 /* kalin kas biraz asagi */
  var kaC = F.yas === 2 ? shadeCol(hc, 1.5) : hc;  /* yaslida kaslar aciliyor */
  var kSol = hx - 9 + icE, kSag = hx + 5 - icE;
  if (ang) {
    fr(kSol, browY + kaD, kaW, kaH, kaC); px(kSol + kaW, browY + 2, kaC); px(kSol - 1, browY - 1, kaC);
    fr(kSag, browY + kaD, kaW, kaH, kaC); px(kSag - 1, browY + 2, kaC); px(kSag + kaW, browY - 1, kaC);
  } else if (hap) {
    fr(kSol, browY - 1, kaW, 1, kaC); px(kSol - 1, browY, kaC);
    fr(kSag, browY - 1, kaW, 1, kaC); px(kSag + kaW, browY, kaC);
  } else if (F.kas === 3) {                      /* CATIK: ic uclar asagida */
    fr(kSol, browY, kaW, 2, kaC); px(kSol + kaW, browY + 1, kaC); px(kSol - 1, browY - 1, kaC);
    fr(kSag, browY, kaW, 2, kaC); px(kSag - 1, browY + 1, kaC); px(kSag + kaW, browY - 1, kaC);
  } else if (F.kas === 4) {                      /* KAVISLI: ortasi yukarida */
    fr(kSol, browY + 1, kaW, 1, kaC); hl(kSol + 1, browY, kaW - 2, kaC);
    fr(kSag, browY + 1, kaW, 1, kaC); hl(kSag + 1, browY, kaW - 2, kaC);
  } else {
    fr(kSol, browY + kaD, kaW, kaH, kaC); fr(kSag, browY + kaD, kaW, kaH, kaC);
  }
  var blink = hash1(Math.floor(t * 1.6) + L.seed) > .92;
  /* goz: 0 normal, 1 dar, 2 iri, 3 ayrik, 4 bitisik, 5 dusuk kapak */
  var gzW = F.goz === 2 ? 6 : 5;
  var gzH = F.goz === 1 ? 3 : (F.goz === 2 ? 6 : (F.goz === 5 ? 4 : 5));
  /* aralik hatlarin kimligini goz bicimi kadar degistiriyor: ayni yuz
     1px acilinca baska biri gibi okunuyor */
  var gzA = (F.goz === 3 ? 1 : (F.goz === 4 ? -1 : 0)) + ((F.aralik === undefined ? 1 : F.aralik) - 1);
  var gzD = F.goz === 5 ? 1 : 0;                        /* dusuk goz asagi kayar */
  /* iri gozde 6x6 beyaza 3x3 bebek kuculuyordu, bakis bos cikiyordu */
  var bbW = F.goz === 2 ? 3 : 2, bbH = F.goz === 1 ? 2 : (F.goz === 2 ? 4 : 3);
  var gzC = GOZ_RENK[F.gozR || 0] || '#2b2018';
  var gSol = hx - 9 - gzA + icE, gSag = hx + 5 + gzA - icE;
  if (hap) {
    ln(gSol, fy + 1 + gzD, gSol + 3, fy - 2 + gzD, gzC); ln(gSol + 3, fy - 2 + gzD, gSol + 6, fy + 1 + gzD, gzC);
    ln(gSag - 2, fy + 1 + gzD, gSag + 1, fy - 2 + gzD, gzC); ln(gSag + 1, fy - 2 + gzD, gSag + 4, fy + 1 + gzD, gzC);
  } else if (blink && !ang) {
    fr(gSol, fy + gzD, gzW, 1, s[3]); fr(gSag, fy + gzD, gzW, 1, s[3]);
  } else {
    var gB = F.gozB || 0;
    gozAki(gSol, fy - 2 + gzD, gzW, gzH, gB, -1, s);
    gozAki(gSag, fy - 2 + gzD, gzW, gzH, gB, 1, s);
    var lx = ang ? 1 : Math.round(Math.sin(t * .8 + L.seed));
    var ly = imp ? 1 : 0;
    /* dar bicimlerde bebek akin disina tasiyordu: yukseklik kirpiliyor.
       Ayrica bebek aka gore DIKEY ORTALANIYOR — eskiden uste yaslaniyordu,
       herkes hafif yukari bakiyor gibi cikiyordu. */
    var pH = (gB === 4) ? 2 : ((gB === 3) ? Math.min(bbH, gzH - 2) : bbH);
    var akUst = (gB === 3) ? 2 : ((gB === 4) ? Math.max(1, (gzH - 2) >> 1) : 0);
    var akH = (gB === 3) ? (gzH - 2) : ((gB === 4) ? 2 : gzH);
    var pY = (fy - 2 + gzD) + akUst + Math.floor((akH - pH) / 2) + ly;
    fr(gSol + 1 + lx, pY, bbW, Math.max(1, pH), gzC);
    fr(gSag + 1 + lx, pY, bbW, Math.max(1, pH), gzC);
    px(gSol + 1 + lx, pY, '#6a5a4a');
    px(gSag + 1 + lx, pY, '#6a5a4a');
    if (F.goz === 5) {                            /* dusuk ust kapak */
      hl(gSol, fy - 2, gzW, s[3]); hl(gSag, fy - 2, gzW, s[3]);
    }
    if (kadin) {                                  /* kirpik */
      px(gSol - 1, fy - 3 + gzD, '#2b2018'); px(gSol - 2, fy - 2 + gzD, '#2b2018');
      px(gSag + gzW, fy - 3 + gzD, '#2b2018'); px(gSag + gzW + 1, fy - 2 + gzD, '#2b2018');
    }
    if (ang) { px(gSol, fy - 3, '#e04a3a'); px(gSag + gzW - 1, fy - 3, '#e04a3a'); }
  }
  /* burun: 0 kucuk, 1 genis, 2 uzun, 3 kemerli, 4 kalkik */
  if (F.burun === 1) {
    ell(hx, fy + 4, 4, 3, s[2]); ell(hx - 1, fy + 3, 4, 2, s[1]);
    px(hx - 3, fy + 5, s[3]); px(hx + 3, fy + 5, s[3]);
  } else if (F.burun === 2) {
    fr(hx - 1, fy + 1, 2, 5, s[2]); fr(hx - 1, fy + 1, 1, 4, s[1]);
    ell(hx, fy + 5, 2, 2, s[2]); px(hx + 1, fy + 6, s[3]);
  } else if (F.burun === 3) {                    /* KEMERLI: sirti cikik */
    fr(hx - 1, fy, 2, 6, s[2]); fr(hx - 1, fy, 1, 5, s[1]);
    px(hx + 1, fy + 1, s[1]); px(hx + 2, fy + 3, s[2]);
    ell(hx + 1, fy + 6, 3, 2, s[2]);
    px(hx + 3, fy + 6, s[3]); px(hx - 2, fy + 6, s[3]);
  } else if (F.burun === 4) {                    /* KALKIK: ucu havada */
    ell(hx, fy + 5, 3, 2, s[2]); ell(hx - 1, fy + 4, 2, 2, s[1]);
    px(hx - 2, fy + 6, s[3]); px(hx + 2, fy + 6, s[3]); px(hx, fy + 3, s[1]);
  } else {
    ell(hx, fy + 4, 3, 3, s[2]); ell(hx - 1, fy + 3, 3, 3, s[1]);
    px(hx - 2, fy + 2, s[0]); px(hx + 2, fy + 5, s[3]);
  }
  /* al yanak — konturun icinde kalsin, dar yuzde disari tasiyordu */
  var ynG = Math.max(4, konG(4) - 3);
  if (F.yanak) {
    ctx.globalAlpha = .30;
    ell(hx - ynG, fy + 4, 3, 2, '#e07a6a'); ell(hx + ynG, fy + 4, 3, 2, '#e07a6a');
    ctx.globalAlpha = 1;
  }
  /* ---- YAS ----
     0 genc: hicbir sey. 1 orta: nazolabial. 2 yasli: goz alti torbasi,
     kaz ayagi ve derin nazolabial. 22x22'de kirisik ancak bu kadar okunur. */
  if (F.yas >= 1 && !cocuk) {
    ctx.globalAlpha = F.yas === 2 ? .55 : .32;
    px(hx - ynG + 1, fy + 5, s[3]); px(hx - ynG + 2, fy + 6, s[3]);
    px(hx + ynG - 1, fy + 5, s[3]); px(hx + ynG - 2, fy + 6, s[3]);
    if (F.yas === 2) {
      px(hx - ynG + 2, fy + 7, s[3]); px(hx + ynG - 2, fy + 7, s[3]);
      hl(gSol + 1, fy + 3 + gzD, gzW - 1, s[3]);          /* goz alti torbasi */
      hl(gSag, fy + 3 + gzD, gzW - 1, s[3]);
      px(gSol - 2, fy - 1, s[3]); px(gSol - 3, fy, s[3]);  /* kaz ayagi */
      px(gSag + gzW + 1, fy - 1, s[3]); px(gSag + gzW + 2, fy, s[3]);
    }
    ctx.globalAlpha = 1;
  }
  /* ---- CIL ---- */
  if (F.cil) {
    ctx.globalAlpha = .42;
    for (var cl = 0; cl < 9; cl++) {
      var ca = hash1((L.seed || 1) * 3.7 + cl), cb = hash1((L.seed || 1) * 5.9 + cl);
      var cxx = hx + Math.round((ca * 2 - 1) * (ynG + 1));
      var cyy = fy + 2 + Math.round(cb * 4);
      if (Math.abs(cxx - hx) <= konG(cyy - fy)) px(cxx, cyy, s[3]);
    }
    ctx.globalAlpha = 1;
  }
  /* ---- BEN ---- */
  if (F.ben === 1) px(hx - ynG + 1, fy + 3, s[3]);
  else if (F.ben === 2) px(hx + ynG - 2, fy + 7, s[3]);
  else if (F.ben === 3) px(hx + 3, fy - 4, s[3]);
  /* ---- CENE: 0 duz, 1 gamzeli, 2 cift ---- */
  var ceG = konG(9);
  if (F.cene === 1 && ceG > 2 && !cocuk) {
    px(hx, hy + 9, s[3]); px(hx, hy + 10, s[3]);
  } else if (F.cene === 2 && ceG > 2 && !cocuk) {
    ell(hx, hy + 10, Math.max(2, ceG), 2, s[2]);
    ctx.globalAlpha = .40; hl(hx - ceG + 1, hy + 9, ceG * 2 - 1, s[3]); ctx.globalAlpha = 1;
  }
  /* bıyık — cene hattini asmasin */
  if (L.mustache) {
    var byG = Math.max(4, Math.min(7, konG(6) - 1));
    fr(hx - byG, fy + 6 + agzU, byG * 2, 2, hc);
    px(hx - byG - 1, fy + 7 + agzU, hc); px(hx + byG, fy + 7 + agzU, hc);
  }
  if (L.acc === 'beard') {
    /* sakal konturdan tasmasin: dar/sivri yuzlerde havada duruyordu */
    var skG = Math.max(4, konG(6));
    for (var b = -skG; b <= skG; b++) {
      var bh = 3 + Math.round(Math.sin((b + skG) * .7) * 2);
      fr(hx + b, hy + 6, 1, bh + 3, hc);
    }
    var skA = Math.max(3, konG(9) + 1);
    ell(hx, hy + 10, skA, 3, hc);
    ell(hx, hy + 11, Math.max(2, skA - 2), 2, shadeCol(hc, 1.2));
  }
  /* ağız */
  var my = fy + (L.mustache ? 9 : 8) + agzU;
  var agD = F.agiz === 1 ? 1 : (F.agiz === 2 ? -1 : 0);   /* genis / kucuk */
  agD = Math.min(agD, Math.max(-1, konG(8) - 5));         /* dar cenede tasmasin */
  if (hap) {
    fr(hx - 4 - agD, my, 9 + agD * 2, 3, '#6d2f28');
    hl(hx - 3 - agD, my + 3, 7 + agD * 2, '#c9584a');
    hl(hx - 3 - agD, my, 7 + agD * 2, '#ffffff');
  } else if (ang) {
    fr(hx - 4 - agD, my, 9 + agD * 2, 3, '#6d2f28');
    hl(hx - 4 - agD, my, 9 + agD * 2, '#ffffff');
    px(hx - 5 - agD, my - 1, s[2]); px(hx + 5 + agD, my - 1, s[2]);
  } else if (imp) {
    hl(hx - 4 - agD, my + 1, 8 + agD * 2, kadin ? '#c4405a' : '#8d3a30');
    px(hx + 4 + agD, my, kadin ? '#c4405a' : '#8d3a30');
  } else if (kadin) {
    /* ruj: dolgun, iki satirli agiz */
    fr(hx - 3 - agD, my, 7 + agD * 2, 2, '#c4405a');
    hl(hx - 3 - agD, my, 7 + agD * 2, '#e2607a');
  } else if (F.agiz === 3) {                    /* DOLGUN dudak */
    fr(hx - 3 - agD, my, 7 + agD * 2, 2, '#8d3a30');
    hl(hx - 2 - agD, my, 5 + agD * 2, '#a8544a');
  } else if (F.agiz === 4) {                    /* INCE dudak */
    hl(hx - 2 - agD, my, 5 + agD * 2, '#7d352c');
  } else {
    hl(hx - 3 - agD, my, 7 + agD * 2, '#8d3a30');
  }
  /* gözlük */
  if (L.acc === 'glasses') {
    /* Gozluk de tek tipti. Tohumdan dort cerceve: kare / yuvarlak /
       ince tel / gunes. Kayitta yeni alan tutmuyor, ayni musteri ayni. */
    var glT = L.glTip !== undefined ? L.glTip
      : Math.floor(hash1((L.seed || 0) * 31.7) * 4);
    var glS = hx - 10 + icE, glG = hx + 4 - icE;
    var glC = glT === 2 ? '#5a4a3a' : '#2b2018';
    if (glT === 1) {                              /* YUVARLAK */
      ring(glS + 3, fy, 3, glC); ring(glG + 3, fy, 3, glC);
      hl(glS + 7, fy, glG - glS - 6, glC);
      ctx.globalAlpha = .20;
      disc(glS + 3, fy, 2, '#ffffff'); disc(glG + 3, fy, 2, '#ffffff');
      ctx.globalAlpha = 1;
      px(glS + 2, fy - 1, 'rgba(255,255,255,.8)'); px(glG + 2, fy - 1, 'rgba(255,255,255,.8)');
    } else if (glT === 2) {                       /* INCE TEL */
      rc(glS + 1, fy - 2, 5, 5, glC); rc(glG + 1, fy - 2, 5, 5, glC);
      hl(glS + 6, fy, glG - glS - 5, glC);
      px(glS, fy - 1, glC); px(glG + 6, fy - 1, glC);
      ctx.globalAlpha = .16; fr(glS + 2, fy - 1, 3, 3, '#ffffff'); fr(glG + 2, fy - 1, 3, 3, '#ffffff'); ctx.globalAlpha = 1;
    } else if (glT === 3) {                       /* GUNES GOZLUGU */
      fr(glS, fy - 3, 7, 7, '#1c1610'); fr(glG, fy - 3, 7, 7, '#1c1610');
      fr(glS + 1, fy - 2, 5, 5, '#33455e'); fr(glG + 1, fy - 2, 5, 5, '#33455e');
      hl(glS + 7, fy - 1, glG - glS - 6, '#1c1610');
      px(glS + 1, fy - 2, 'rgba(255,255,255,.55)'); px(glG + 1, fy - 2, 'rgba(255,255,255,.55)');
    } else {                                      /* KARE (eski) */
      rc(glS, fy - 3, 7, 7, glC); rc(glG, fy - 3, 7, 7, glC);
      hl(glS + 7, fy, glG - glS - 6, glC);
      ctx.globalAlpha = .22; fr(glS + 1, fy - 2, 5, 5, '#ffffff'); fr(glG + 1, fy - 2, 5, 5, '#ffffff'); ctx.globalAlpha = 1;
      px(glS + 2, fy - 2, 'rgba(255,255,255,.8)'); px(glG + 2, fy - 2, 'rgba(255,255,255,.8)');
    }
  }
  /* duygu efektleri */
  if (ang && chance(.05)) smoke(hx + rnd(-11, 11), hy - 13, 1, 'rgba(230,90,60,.55)');
  if (ang) {
    /* öfke damarı */
    var vx2 = hx + 8, vy2 = hy - 9;
    if (Math.sin(t * 8) > 0) { px(vx2, vy2, '#e04a3a'); px(vx2 + 1, vy2 - 1, '#e04a3a'); px(vx2 + 2, vy2, '#e04a3a'); px(vx2 + 1, vy2 + 1, '#e04a3a'); }
  }
  if (mood === 'served' && chance(.06)) {
    part({ x: hx + rnd(-9, 9), y: hy - 10, vx: rnd(-6, 6), vy: rnd(-24, -12), life: .9, col: '#e2483a', g: -8, sz: 2 });
  }
}
function drawAcc(hx, hy, hw, L, sh, hc) {
  if (L.acc === 'cap') {
    var cc = shadeCol(sh, .8);
    fr(hx - hw - 1, hy - 10, hw * 2 + 2, 6, shadeCol(cc, .7));
    ell(hx, hy - 10, hw, 5, cc);
    fr(hx - hw, hy - 10, hw * 2, 5, cc);
    hl(hx - hw + 2, hy - 12, hw * 2 - 4, shadeCol(cc, 1.25));
    fr(hx - hw - 5, hy - 6, 7, 2, shadeCol(cc, .6));
    hl(hx - hw - 5, hy - 6, 7, shadeCol(cc, .9));
    disc(hx, hy - 13, 1, shadeCol(cc, 1.3));
  } else if (L.acc === 'kufiya') {
    fr(hx - hw - 2, hy - 12, hw * 2 + 4, 9, '#f4f4f0');
    fr(hx - hw - 3, hy - 5, 4, 14, '#f4f4f0');
    fr(hx + hw - 1, hy - 5, 4, 14, '#f4f4f0');
    for (var k = 0; k < 7; k++) {
      px(hx - hw + k * 3, hy - 10 + (k % 2) * 2, '#d8443a');
      px(hx - hw + 1 + k * 3, hy - 8 + (k % 2) * 2, '#d8443a');
      px(hx - hw - 2 + (k % 3), hy - 2 + k, '#d8443a');
    }
    fr(hx - hw - 2, hy - 14, hw * 2 + 4, 3, '#2b2b28');
    hl(hx - hw - 1, hy - 14, hw * 2 + 2, '#55554e');
  } else if (L.acc === 'band') {
    fr(hx - hw - 1, hy - 8, hw * 2 + 2, 4, '#3f79c0');
    hl(hx - hw - 1, hy - 8, hw * 2 + 2, '#6b9ad8');
    hl(hx - hw - 1, hy - 5, hw * 2 + 2, '#2a5990');
    fr(hx + hw - 1, hy - 7, 5, 8, '#3f79c0');
    px(hx + hw + 3, hy + 1, '#2a5990');
  }
}
function drawHair(hx, hy, hw, style, hc, s) {
  if (style < 0) return;                  /* kalip kendi sacini ciziyor */
  var d = shadeCol(hc, .72), l = shadeCol(hc, 1.3);
  switch (style) {
    case 0:
      ell(hx, hy - 5, hw, 6, hc); fr(hx - hw, hy - 5, hw * 2, 3, hc);
      ell(hx - 3, hy - 9, 5, 2, l);
      px(hx - hw, hy - 1, d); px(hx + hw - 1, hy - 1, d);
      break;
    case 1:
      ell(hx, hy - 5, hw, 4, hc);
      for (var i = 0; i < 6; i++) {
        var sx = hx - hw + 1 + i * 4;
        fr(sx, hy - 12 + (i % 2), 3, 7, hc);
        px(sx, hy - 12 + (i % 2), l);
      }
      break;
    case 2:
      fr(hx - hw - 1, hy - 4, 4, 7, hc); fr(hx + hw - 2, hy - 4, 4, 7, hc);
      ell(hx - 4, hy - 8, 4, 2, '#fff2dc');
      ctx.globalAlpha = .25; ell(hx, hy - 6, hw - 2, 3, '#ffffff'); ctx.globalAlpha = 1;
      break;
    case 3:
      ell(hx, hy - 4, hw + 1, 7, hc);
      fr(hx - hw - 3, hy - 7, 4, 16, hc); fr(hx + hw - 1, hy - 7, 4, 16, hc);
      ell(hx - 3, hy - 10, 6, 2, l);
      break;
    case 4:
      ell(hx, hy - 5, hw, 5, hc);
      disc(hx + 1, hy - 12, 4, hc); px(hx - 1, hy - 14, l);
      break;
    case 5:
      ell(hx, hy - 5, hw, 5, hc);
      for (var j = 0; j < 5; j++) ell(hx - hw + 2 + j * 5, hy - 9, 4, 3, hc);
      ell(hx - 2, hy - 11, 4, 2, l);
      break;
    case 6:
      ell(hx, hy - 8, hw + 3, 7, hc);
      ell(hx - hw - 1, hy - 4, 4, 5, hc); ell(hx + hw + 1, hy - 4, 4, 5, hc);
      ell(hx - 3, hy - 11, 5, 2, l);
      break;
    /* --- 8-10: uzun sac (kadin musteriler) --- */
    case 8:                                   /* omuza inen duz sac */
      ell(hx, hy - 5, hw + 1, 6, hc);
      fr(hx - hw - 1, hy - 5, hw * 2 + 2, 4, hc);
      fr(hx - hw - 2, hy - 4, 4, 21, hc);
      fr(hx + hw - 2, hy - 4, 4, 21, hc);
      px(hx - hw - 2, hy + 16, d); px(hx + hw + 1, hy + 16, d);
      ctx.globalAlpha = .35; vl(hx - hw - 1, hy - 2, 16, l); ctx.globalAlpha = 1;
      ell(hx - 3, hy - 9, 5, 2, l);
      break;
    case 9:                                   /* at kuyrugu */
      ell(hx, hy - 5, hw, 5, hc);
      fr(hx - hw, hy - 5, hw * 2, 3, hc);
      fr(hx + hw - 1, hy - 4, 3, 4, shadeCol(hc, .6));   /* toka */
      for (var q9 = 0; q9 < 15; q9++) {
        var qx = hx + hw + 1 + Math.round(Math.sin(q9 * .33) * 2);
        fr(qx, hy - 2 + q9, 3, 1, q9 % 4 === 0 ? l : hc);
      }
      ell(hx - 3, hy - 9, 5, 2, l);
      break;
    case 10:                                  /* topuz */
      ell(hx, hy - 5, hw, 6, hc);
      fr(hx - hw, hy - 5, hw * 2, 3, hc);
      ell(hx, hy - 13, 5, 4, hc);
      ell(hx, hy - 14, 4, 3, l);
      ctx.globalAlpha = .4; ring(hx, hy - 13, 4, d); ctx.globalAlpha = 1;
      px(hx - hw, hy - 1, d); px(hx + hw - 1, hy - 1, d);
      break;
    default:
      ell(hx, hy - 5, hw, 5, hc);
      for (var k = 0; k < 5; k++) ln(hx - 8 + k * 4, hy - 9, hx - 5 + k * 4, hy - 4, l);
      break;
  }
}

/* ============================================================
   MUSTERI KALIPLARI (arketipler)
   Yuzler cesitlendi ama herkes ayni sade gomlekle geliyordu. Kalip,
   govdeye bir kiyafet katmani ve bazen kafaya baslik ekler; siluet
   uzaktan bile ayrisir.

   KALIP_ACIK false iken hicbir sey degismez — newCustomerLook 'yok'
   atar, iki kanca da ilk satirda cikar. Onay gelince tek sabit true.
   ============================================================ */
var KALIP_ACIK = true;

/* agirlik: sade musteri hala cogunluk olmali, kalabalik bir kostum
   gecidine donmesin */
var KALIP = [
  { id: 'yok',     w: 30, tip: 'hepsi' },
  { id: 'isci',    w: 8,  tip: 'buyuk',  baslik: true },
  { id: 'memur',   w: 8,  tip: 'buyuk' },
  { id: 'ogrenci', w: 8,  tip: 'hepsi' },
  { id: 'yasli',   w: 7,  tip: 'buyuk' },
  { id: 'turist',  w: 5,  tip: 'buyuk',  baslik: true },
  { id: 'sporcu',  w: 6,  tip: 'hepsi' },
  { id: 'kurye',   w: 5,  tip: 'buyuk',  baslik: true },
  { id: 'sofor',   w: 5,  tip: 'buyuk',  baslik: true },
  /* --- OZEL KALIPLAR --- Agirliklari 0: rastgele tabloya GIRMEZLER.
     Kendi kapilari var (ozelKalipSec): gunde en fazla bir, 10-15
     gunde bir. Agirlik 2 ile ~%8 musteri ozel oluyordu; ayni gun
     ayni karakter tekrar tekrar geliyor, her gun en az biri
     cikiyordu - ozel olmaktan cikip dekora donusmuslerdi. */
  { id: 'kuzeyli', w: 0, tip: 'buyuk' },
  { id: 'kimyager', w: 0, tip: 'buyuk', baslik: true },
  { id: 'cirak',   w: 0, tip: 'hepsi' },
  { id: 'kralice', w: 0, tip: 'kadin' },
  { id: 'bilge',   w: 0, tip: 'buyuk', baslik: true }
];

/* Iki ozel musteri arasi gun araligi ve ilk gorunme penceresi. */
var OZEL_ARA_MIN = 10, OZEL_ARA_MAK = 15;
var OZEL_ILK_MIN = 4, OZEL_ILK_MAK = 8;
/* Gun uygunsa her musterinin ozel cikma sansi. Ilk musteriye
   sabitlemek yerine gune yayiliyor; tutmazsa ertesi gun yine uygun. */
var OZEL_SANS = .16;

/* Bugun bir ozel gelebilir mi? Gelebilirse EN UZUN SUREDIR gelmeyeni
   dondurur - ayni kisi ust uste gelmesin, besi sirayla donsun. */
function ozelKalipSec(tip) {
  if (!OZEL_ACIK) return null;                         /* yayinda kapali */
  if (typeof G === 'undefined' || !G) return null;
  if (G.ozelBugun) return null;                        /* bugun geldi */
  if ((G.day || 1) < (G.ozelHedef || OZEL_ILK_MIN)) return null;
  /* TIPE gore eleme YOK: KALIP_KIMLIK ozel kalibin tipini zaten
     eziyor (kralice hep 'kadin', kuzeyli hep 'adam'). Burada da
     elemek dagilimi bozuyordu - 'cirak' tek 'hepsi' kalip oldugu
     icin iki katindan fazla cikiyor, ust uste bile geliyordu. */
  var aday = [];
  for (var i = 0; i < KALIP.length; i++) {
    if (OZEL_KALIP[KALIP[i].id]) aday.push(KALIP[i].id);
  }
  if (!aday.length) return null;
  var gec = G.ozelGecmis || (G.ozelGecmis = {});
  aday.sort(function (a, b) { return (gec[a] || -9999) - (gec[b] || -9999); });
  /* En eski ikisinden rastgele: hep en eskiyi secmek bes kisilik sabit
     bir donguye yol aciyordu (sira ezberleniyor). Iki adaydan secmek
     sirayi kirar ama ust uste ayni kisiyi yine engeller. */
  return aday[Math.floor(Math.random() * Math.min(2, aday.length))];
}

/* Ozel geldi: gunun kotasi kapanir, siradaki gun belirlenir. */
function ozelKalipIsaretle(id, r) {
  if (typeof G === 'undefined' || !G) return;
  G.ozelBugun = true;
  if (!G.ozelGecmis) G.ozelGecmis = {};
  G.ozelGecmis[id] = G.day || 1;
  var ek = OZEL_ARA_MIN + Math.floor((r ? r() : Math.random()) *
           (OZEL_ARA_MAK - OZEL_ARA_MIN + 1));
  G.ozelHedef = (G.day || 1) + ek;
}

/* TEST ANAHTARI. Acikken HER musteri sirayla ozel kaliplardan birini
   alir - hepsini bir gunde gormek icin.

   Acikken NORMAL MUSTERI KALMIYOR - her gelen ozel kalip aliyor ve
   sokak kostum gecidine donuyor; regresyonda da sehir kimligi
   testleri duser. Yalniz gecici bakis icin acilir. */
var KALIP_TEST = false;
/* Kendi sacini/sakalini cizen kaliplar */
var OZEL_KALIP = { kuzeyli: 1, kimyager: 1, cirak: 1, kralice: 1, bilge: 1 };

/* ============================================================
   OZEL KARAKTER ANAHTARI  —  YAYINDA KAPALI
   ============================================================
   Bes ozel karakter taninabilir kurmaca kisilere benziyor. Apple 5.2
   ve Steam icerik kurallari, hak sahibi olunmayan taninan icerigi
   kabul etmiyor. Isimler pakete girmiyor (tools/isimtara.js bunu
   kontrol ediyor) ama asil tasiyici gorsellerin KENDISI.

   false: ozel musteri hic gelmez, atlaslar yuklenmez, derlemeye de
          girmez (tools/build.js bu satiri okur ve sprites/ klasorunu
          atlar). Binekler de cikmaz - yalniz ozel musteriyle geliyorlar.
   true : her sey geri gelir; kod, atlaslar ve replikler repoda duruyor.

   DEGISTIRIRSEN: node tools/build.js && node tools/tekdosya.js
   ============================================================ */
var OZEL_ACIK = false;

/* Ozel kaliplar TEK BIR KISI. Kalip yalniz kiyafet katmani oldugu
   icin ten, yuz hatlari, boy ve goz rengi temel sistemden rastgele
   geliyordu: her seferinde baska bir cirak, baska bir kralice
   geliyordu. Kimlik alanlari burada sabitleniyor. */
var KALIP_KIMLIK = {
  kuzeyli:  { tip: 'adam',  skin: 1, big: true,
              yuz: { sekil: 2, goz: 1, gozR: 1, burun: 3, kas: 1, agiz: 4,
                     gozB: 0, oran: 1, aralik: 1 } },
  kimyager: { tip: 'adam',  skin: 1, big: false,
              yuz: { sekil: 0, goz: 5, gozR: 2, burun: 1, kas: 2, agiz: 4,
                     gozB: 3, oran: 1, aralik: 1 } },
  cirak:    { tip: 'adam',  skin: 1, big: false,
              yuz: { sekil: 3, goz: 2, gozR: 2, burun: 0, kas: 0, agiz: 0,
                     gozB: 2, oran: 1, aralik: 1 } },
  kralice:  { tip: 'kadin', skin: 0, big: false,
              yuz: { sekil: 4, goz: 2, gozR: 1, burun: 0, kas: 4, agiz: 3,
                     gozB: 1, oran: 1, aralik: 1 } },
  bilge:    { tip: 'adam',  skin: 0, big: false,
              yuz: { sekil: 1, goz: 5, gozR: 3, burun: 2, kas: 1, agiz: 4,
                     gozB: 3, oran: 1, aralik: 1 } }
};
var _kalipSira = 0;
function kalipById(id) {
  for (var i = 0; i < KALIP.length; i++) if (KALIP[i].id === id) return KALIP[i];
  return KALIP[0];
}
function kalipSec(r, tip, ozelOlabilir) {
  if (KALIP_TEST && OZEL_ACIK) {          /* test: hepsi sirayla gelsin */
    if (tip === 'cocuk') return 'cirak';  /* cocuga yetiskin kalibi olmaz */
    var OZ = ['kuzeyli', 'kimyager', 'cirak', 'kralice', 'bilge'];
    return OZ[(_kalipSira++) % OZ.length];
  }
  /* OZEL kapisi: agirlik tablosundan degil buradan geciyorlar.
     ozelOlabilir=false ile cagrilirsa (eski kayittan tohumla kalip
     turetme) gunun kotasi HARCANMAZ. */
  if (ozelOlabilir) {
    var oz = ozelKalipSec(tip);
    if (oz && r() < OZEL_SANS) { ozelKalipIsaretle(oz, r); return oz; }
  }
  var uygun = [], top = 0;
  for (var i = 0; i < KALIP.length; i++) {
    var k = KALIP[i];
    if (k.w <= 0) continue;                              /* ozel: ayri kapidan */
    if (k.tip === 'buyuk' && tip === 'cocuk') continue;   /* cocuga takim/baret olmaz */
    /* belirli bir tipe bagli kalip (ornegin kralice) sadece o tipe */
    if (k.tip !== 'hepsi' && k.tip !== 'buyuk' && k.tip !== tip) continue;
    uygun.push(k); top += k.w;
  }
  var a = r() * top;
  for (var j = 0; j < uygun.length; j++) { a -= uygun[j].w; if (a <= 0) return uygun[j].id; }
  return 'yok';
}
/* eski kayitta kalip yok: tohumdan turet, ayni musteri hep ayni kalsin */
function kalipKimlik(L) {
  if (!KALIP_ACIK) return 'yok';
  if (L.kalip) return L.kalip;
  var h = (L.seed || 0) * 37.7, i = 0;
  L.kalip = kalipSec(function () { i++; return hash1(h + i * 1.7); }, L.tip || 'adam');
  return L.kalip;
}

var KALIP_RENK = {
  isci:    { ana: ['#c8781e', '#7a7a52', '#b8621c'], seri: '#f0ece0' },
  memur:   { ana: ['#2f3a52', '#3a3340', '#2b3b3a'], seri: '#c04a3a' },
  ogrenci: { ana: ['#4a4f5c', '#3f5a72', '#5c4a5e'], seri: '#d8b84a' },
  yasli:   { ana: ['#7a6650', '#5a5f6b', '#7a5a5e'], seri: '#c8b898' },
  turist:  { ana: ['#3aa8a0', '#d8a03c', '#c96a9a'], seri: '#fdf3dd' },
  sporcu:  { ana: ['#3a5f9a', '#9a3a46', '#357a54'], seri: '#f4f4f0' },
  kurye:   { ana: ['#c4dc46', '#e8c020', '#96cc44'], seri: '#e8e4d8',
             /* kask yelekle AYNI renk olunca kafa yelegin devami gibi
                okunuyordu; kaska ayri palet */
             kask: ['#d8352c', '#f0ece4', '#2b3038'] },
  sofor:   { ana: ['#7a6a52', '#6b5a62', '#5a6b6b'], seri: '#c85a3a',
             kasket: ['#3a3a42', '#4a3f32', '#38424e'] },
  /* --- ozel kaliplar --- */
  kuzeyli: { ana: ['#232830', '#2b2620', '#1e2430'], seri: '#6a5138',
             kurk: ['#4f463a', '#5a5148', '#3f382e'] },
  kimyager: { ana: ['#d8c22a', '#c9b420', '#e0cc38'], seri: '#3c4650' },
  cirak:   { ana: ['#1a1d26', '#20242e', '#161a22'], seri: '#9a2632' },
  kralice: { ana: ['#436a7e', '#3d6070', '#4a7286'], seri: '#d8ac35' },
  bilge:   { ana: ['#70707a', '#666672', '#7a7a84'], seri: '#54402a' }
};
function kalipAna(id, seed) {
  var R = KALIP_RENK[id];
  if (!R) return null;
  return R.ana[Math.floor(hash1((seed || 1) * 5.9) * R.ana.length)];
}

/* Govdeyi kiyafet renginde yeniden boyar. ONEMLI: taban govdeyle AYNI
   silueti kullanir (omuz elipsi + govde dikdortgeni). Ilk denemede duz
   dikdortgen cizmistim, omuz egrisi kaybolup herkes kutu gibi oluyordu.
   kolAtla: kollar gomlek renginde kalir (yelek gibi kolsuz parcalar). */
function kalipZemin(x, by, bw, ana, kolAtla) {
  var sol = Math.round(x - bw / 2), sag = Math.round(x + bw / 2);
  ell(x, by + 5, bw / 2, 7, shadeCol(ana, .72));
  fr(sol, by + 5, bw, 26, shadeCol(ana, .72));
  ell(x, by + 4, bw / 2 - 1, 6, ana);
  fr(sol + 1, by + 4, bw - 2, 26, ana);
  fr(sol + 1, by + 5, 7, 25, shadeCol(ana, 1.14));            /* sol aydinlik */
  ctx.globalAlpha = .20; fr(x + 3, by + 4, bw / 2 - 3, 27, '#000'); ctx.globalAlpha = 1;
  if (!kolAtla) {
    fr(sol - 3, by + 8, 5, 22, shadeCol(ana, .80));
    fr(sol - 3, by + 8, 4, 21, shadeCol(ana, .92));
    fr(sag - 2, by + 8, 5, 22, shadeCol(ana, .66));
  }
}
/* Gomlek yakasini geri koyar: kiyafet boyandiktan sonra boyun altinda
   gomlek gorunsun diye. */
function kalipYaka(x, by, sh, s) {
  fr(x - 6, by + 2, 12, 4, shadeCol(sh, .62));
  fr(x - 3, by + 1, 6, 5, s[1]);
}

/* ---- GOVDE KATMANI ---- */
function drawKalipGovde(id, x, by, bw, sh, s, L) {
  if (!id || id === 'yok') return;
  var R = KALIP_RENK[id];
  if (!R) return;
  var ana = kalipAna(id, L.seed), koy = shadeCol(ana, .72), ac = shadeCol(ana, 1.22);
  var sol = Math.round(x - bw / 2), sag = Math.round(x + bw / 2);
  var alt = by + 30;

  if (id === 'isci') {
    /* TULUM: ust gomlek, belden yukari askili onluk, yansitici seritler */
    kalipZemin(x, by, bw, ana);
    /* omuzlarda gomlek gorunsun: onluk gogsun ortasinda kalir */
    fr(sol + 1, by + 4, 8, 9, shadeCol(sh, .90));
    fr(sag - 8, by + 4, 8, 9, shadeCol(sh, .74));
    ell(x, by + 4, bw / 2 - 1, 5, sh);
    fr(sol - 3, by + 8, 5, 9, shadeCol(sh, .80));            /* kisa kol */
    fr(sag - 2, by + 8, 5, 9, shadeCol(sh, .66));
    fr(x - 9, by + 12, 18, alt - by - 12, ana);              /* onluk govdesi */
    fr(x - 9, by + 12, 18, 1, ac);
    fr(x - 9, by + 4, 3, 9, ana); fr(x + 6, by + 4, 3, 9, ana);   /* askilar */
    px(x - 9, by + 4, ac); px(x + 6, by + 4, ac);
    px(x - 8, by + 12, P.au2); px(x + 7, by + 12, P.au2);    /* tokalar */
    fr(x - 8, by + 22, 7, 5, koy);                            /* karin cebi */
    hl(x - 8, by + 22, 7, ac);
    ctx.globalAlpha = .92;                     /* tezgah alti kesiyor: yukarida */
    hl(sol + 1, by + 17, bw - 2, R.seri);
    hl(sol + 1, by + 20, bw - 2, R.seri);
    ctx.globalAlpha = 1;
    kalipYaka(x, by, sh, s);

  } else if (id === 'memur') {
    /* TAKIM: ceket, ortada gomlek seridi, yaka ucgenleri, kravat */
    kalipZemin(x, by, bw, ana);
    fr(x - 4, by + 6, 8, alt - by - 6, '#e6e2d6');            /* gomlek seridi */
    fr(x - 4, by + 6, 1, alt - by - 6, '#c8c2b2');
    for (var v = 0; v < 8; v++) {                             /* yaka */
      fr(x - 8 + v, by + 5 + v, 4, 1, koy);
      fr(x + 5 - v, by + 5 + v, 4, 1, shadeCol(ana, .60));
      px(x - 8 + v, by + 5 + v, ac);
    }
    fr(x - 2, by + 7, 4, 4, R.seri);                          /* kravat dugumu */
    fr(x - 1, by + 11, 3, 13, shadeCol(R.seri, .90));
    px(x, by + 8, shadeCol(R.seri, 1.35));
    for (var d = 0; d < 3; d++) hl(x - 1, by + 14 + d * 4, 3, shadeCol(R.seri, .70));
    px(sag - 4, by + 16, P.au2);                              /* yaka rozeti */
    kalipYaka(x, by, sh, s);

  } else if (id === 'kuzeyli') {
    /* KURK MANTO + CAPRAZ KAYIS + SIRTTA KILIC.
       Bu kalibi taniten tek sey omuzlardan TASAN kurk silueti; kurk
       cuppeyle ayni koyulukta olursa hepsi tek kutle oluyor, o yuzden
       kurk gri-kahve, cuppe siyah. */
    kalipZemin(x, by, bw, ana);
    /* kilic: sag omzun ustunden cikan kabza */
    /* Kilic basin arkasinda kaliyordu; omzun disina kaydirildi. */
    fr(sag - 1, by - 10, 4, 15, '#5a6068');                   /* kin */
    vl(sag - 1, by - 10, 15, '#98a4b0');
    fr(sag - 5, by - 13, 13, 3, '#c4cfd8');                   /* balcak */
    hl(sag - 5, by - 13, 13, '#e2eaf0');
    fr(sag - 2, by - 20, 6, 7, '#503b2a');                    /* kabza */
    vl(sag - 2, by - 20, 7, '#6a5138');
    disc(sag + 1, by - 22, 3, '#98a4b0');                     /* topuz */
    px(sag, by - 23, '#e2eaf0');
    /* kurk manto: omuz hattindan iki yana tasan kabarik kutle */
    var kf = R.kurk[Math.floor(hash1((L.seed || 1) * 3.7) * R.kurk.length)];
    /* Kurk govdeyle ayni genislikteyken hicbir sey soylemiyordu; asil
       is omuzdan TASMASINDA. Iki sira, disa dogru kabaran yumrular. */
    for (var sr = 0; sr < 2; sr++) {
      for (var kk = 0; kk < 11; kk++) {
        var kx0 = Math.round(sol - 6 + kk * ((bw + 12) / 10));
        var kd = 3 + (Math.abs(kk - 5) / 5) * 2 - sr;
        if (kd < 2) continue;
        var kz = by + 2 + sr * 4 + (kk % 2);
        ell(kx0, kz + 1, kd + 1, kd, shadeCol(kf, .66));
        ell(kx0, kz, kd, kd - 1, sr ? shadeCol(kf, .86) : kf);
        px(kx0 - 1, kz - 1, shadeCol(kf, 1.36));
      }
    }
    /* capraz deri kayis + toka */
    for (var ky2 = 0; ky2 < 17; ky2++) {
      var kxx = x - 8 + Math.round(ky2 * .78);
      fr(kxx, by + 9 + ky2, 3, 1, '#3a2a1e');
      px(kxx, by + 9 + ky2, '#6a5138');
    }
    fr(x + 1, by + 17, 5, 4, '#8a7328'); px(x + 2, by + 18, '#b89c3c');

  } else if (id === 'kimyager') {
    /* SARI TULUM + YESIL ELDIVEN + BOYUNDA MASKE */
    kalipZemin(x, by, bw, ana);
    vl(x, by + 4, alt - by - 4, shadeCol(ana, .62));          /* fermuar */
    fr(x - 8, by + 2, 16, 3, ac);                             /* yaka */
    ctx.globalAlpha = .30; hl(x - 8, by + 5, 16, '#000'); ctx.globalAlpha = 1;
    ell(x, by + 6, bw / 2 - 2, 4, shadeCol(ana, .78));        /* sirtta kapuson */
    fr(sol - 4, by + 24, 6, 6, '#2f6b3e');                    /* eldivenler */
    fr(sol - 4, by + 24, 5, 5, '#428f54');
    fr(sag - 2, by + 24, 6, 6, '#1e4a2c');
    fr(sag - 2, by + 24, 5, 5, '#2f6b3e');
    fr(x - 5, by + 8, 10, 5, R.seri);                         /* maske */
    fr(x - 4, by + 8, 8, 4, shadeCol(R.seri, 1.3));
    fr(x - 1, by + 13, 3, 3, R.seri);
    kalipYaka(x, by, sh, s);

  } else if (id === 'cirak') {
    /* SIYAH CUPPE + CIZGILI UZUN ATKI */
    kalipZemin(x, by, bw, ana);
    fr(sol - 2, by + 22, bw + 4, 8, ana);                     /* eteklenen alt */
    fr(sol - 1, by + 22, bw + 2, 7, ac);
    fr(x - 10, by + 2, 20, 5, R.seri);                        /* atki boyun */
    fr(x - 10, by + 2, 20, 3, shadeCol(R.seri, 1.2));
    for (var ai = 0; ai < 6; ai++) {                          /* sarkan uc */
      var az = by + 7 + ai * 4;
      if (az > alt - 2) break;
      fr(x - 9, az, 6, 4, ai % 2 ? '#d8ac35' : R.seri);
      px(x - 9, az, shadeCol(ai % 2 ? '#d8ac35' : R.seri, 1.3));
    }
    fr(x + 8, by + 7, 4, 9, R.seri);                          /* kisa uc */
    fr(x + 8, by + 11, 4, 4, '#d8ac35');
    fr(sag + 1, by + 6, 2, 20, '#6f5638');                    /* asa */
    px(sag + 1, by + 6, '#8a6f4a');
    disc(sag + 2, by + 4, 2, '#d8ac35');

  } else if (id === 'kralice') {
    /* YUKSEK ALTIN YAKA + MAVI-GRI ELBISE, DIKEY PILELER */
    kalipZemin(x, by, bw, ana);
    for (var pi = 0; pi < 5; pi++) {
      vl(x - 10 + pi * 5, by + 10, alt - by - 10, shadeCol(ana, .78));
      vl(x - 9 + pi * 5, by + 10, alt - by - 10, shadeCol(ana, 1.12));
    }
    fr(x - 8, by, 16, 9, shadeCol(R.seri, .68));              /* yuksek yaka */
    fr(x - 7, by, 14, 8, R.seri);
    hl(x - 7, by, 14, shadeCol(R.seri, 1.3));
    fr(x - 3, by + 9, 6, 4, shadeCol(R.seri, .82));           /* gogus tokasi */
    px(x - 1, by + 10, '#ffd75e');

  } else if (id === 'bilge') {
    /* GRI CUPPE + KEMER + DEGNEK + CENEDEN SARKAN AK SAKAL.
       Sakal GOVDE katmaninda: bas katmaninda cizilirse temel yuz
       sistemi agzi sakalin ustune ciziyor. */
    kalipZemin(x, by, bw, ana);
    fr(sol - 2, by + 20, bw + 4, 10, ana);                    /* etek */
    fr(sol - 1, by + 20, bw + 2, 9, ac);
    fr(x - 11, by + 15, 22, 4, R.seri);                       /* kemer */
    hl(x - 11, by + 15, 22, shadeCol(R.seri, 1.35));
    px(x, by + 16, '#b89c3c');
    fr(sag + 1, by - 6, 2, 34, '#6f5638');                    /* degnek */
    px(sag + 1, by - 6, '#8a6f4a');
    fr(sag - 1, by - 9, 6, 3, '#54402a');

  } else if (id === 'ogrenci') {
    /* KAPUSONLU + SIRT CANTASI: gomlek rengi kalir, ustune kapusan,
       kanguru cebi ve iki omuz askisi biner */
    fr(sol - 5, by + 10, 4, 14, koy);                         /* omuzdan tasan canta */
    fr(sag + 1, by + 10, 4, 14, shadeCol(ana, .60));
    ell(x, by + 7, bw / 2 - 1, 5, shadeCol(sh, .66));         /* kapusan yigini */
    ell(x, by + 6, bw / 2 - 2, 4, shadeCol(sh, .82));
    hl(x - 7, by + 3, 14, shadeCol(sh, .58));
    fr(x - 9, by + 21, 18, 1, shadeCol(sh, .60));             /* kanguru cebi */
    fr(x - 9, by + 21, 1, 6, shadeCol(sh, .60));
    fr(x + 8, by + 21, 1, 6, shadeCol(sh, .60));
    fr(x - 8, by + 6, 3, 22, ana);                            /* askilar */
    fr(x + 6, by + 6, 3, 22, ana);
    vl(x - 8, by + 6, 22, ac); vl(x + 6, by + 6, 22, ac);
    px(x - 7, by + 17, R.seri); px(x + 7, by + 17, R.seri);   /* toka */
    kalipYaka(x, by, sh, s);

  } else if (id === 'yasli') {
    /* HIRKA + ATKI: ortada gomlek, dugme sirasi, boyunda kalin atki */
    kalipZemin(x, by, bw, ana);
    fr(x - 4, by + 8, 8, alt - by - 8, shadeCol(sh, 1.05));   /* gomlek */
    fr(x - 4, by + 8, 1, alt - by - 8, shadeCol(sh, .80));
    fr(x + 3, by + 8, 1, alt - by - 8, shadeCol(sh, .80));
    for (var b2 = 0; b2 < 4; b2++) {
      px(x - 6, by + 13 + b2 * 5, R.seri);
      px(x - 6, by + 14 + b2 * 5, shadeCol(R.seri, .7));
    }
    hl(sol + 1, by + 4, 8, ac);
    fr(x - 9, by + 2, 18, 6, R.seri);                         /* atki */
    fr(x - 9, by + 2, 18, 4, shadeCol(R.seri, 1.14));
    ctx.globalAlpha = .35; hl(x - 8, by + 7, 16, '#000'); ctx.globalAlpha = 1;
    fr(x + 4, by + 8, 5, 12, shadeCol(R.seri, .94));          /* sarkan uc */
    hl(x + 4, by + 8, 5, R.seri);
    for (var pu = 0; pu < 5; pu++) px(x + 4 + pu, by + 20, shadeCol(R.seri, .68));

  } else if (id === 'turist') {
    /* DESENLI GOMLEK + BOYUNDA FOTOGRAF MAKINESI */
    kalipZemin(x, by, bw, ana);
    fr(sol - 3, by + 8, 5, 10, shadeCol(ana, .80));           /* kisa kol */
    fr(sag - 2, by + 8, 5, 10, shadeCol(ana, .66));
    fr(sol - 3, by + 18, 5, 12, s[2]);                        /* cıplak kol */
    fr(sol - 3, by + 18, 4, 11, s[1]);
    fr(sag - 2, by + 18, 5, 12, s[2]);
    for (var ci = 0; ci < 12; ci++) {                         /* cicek deseni */
      var cx2 = sol + 3 + (ci * 7) % (bw - 6), cy2 = by + 8 + (ci * 5) % 20;
      px(cx2, cy2, R.seri); px(cx2 + 1, cy2 + 1, R.seri);
      px(cx2 - 1, cy2 + 1, R.seri); px(cx2, cy2 + 2, shadeCol(R.seri, .8));
    }
    ln(x - 6, by + 5, x - 2, by + 16, '#4a3f30');             /* aski */
    ln(x + 6, by + 5, x + 2, by + 16, '#4a3f30');
    fr(x - 5, by + 16, 10, 7, '#25252a');                     /* makine */
    fr(x - 5, by + 16, 10, 5, '#3f3f46');
    hl(x - 4, by + 16, 8, '#5f5f68');
    disc(x, by + 19, 2, '#14141a'); px(x - 1, by + 18, '#7ab0d8');
    px(x + 4, by + 17, '#c8c0a8');
    kalipYaka(x, by, sh, s);

  } else if (id === 'sporcu') {
    /* ESOFMAN: dik yaka, fermuar, KOLLARDA beyaz serit */
    kalipZemin(x, by, bw, ana);
    fr(sol - 3, by + 10, 2, 20, R.seri);                      /* kol seridi */
    fr(sag + 1, by + 10, 2, 20, shadeCol(R.seri, .86));
    fr(x - 1, by + 8, 2, alt - by - 8, shadeCol(ana, .58));   /* fermuar */
    vl(x - 1, by + 8, alt - by - 8, shadeCol(ana, 1.35));
    px(x, by + 10, R.seri);
    fr(x - 7, by + 3, 14, 5, koy);                            /* dik yaka */
    fr(x - 7, by + 3, 14, 3, shadeCol(ana, 1.08));
    hl(x - 6, by + 3, 12, R.seri);
    fr(x - 8, by + 17, 5, 2, R.seri);                         /* gogus armasi */
    px(x - 7, by + 18, ana);

  } else if (id === 'kurye') {
    /* YANSITICI YELEK: KOLLAR gomlek renginde kalir, yelek parlar */
    fr(sol + 1, by + 6, bw - 2, alt - by - 6, ana);
    ell(x, by + 5, bw / 2 - 2, 5, ana);
    fr(sol + 1, by + 6, 6, alt - by - 6, shadeCol(ana, 1.12));
    ctx.globalAlpha = .18; fr(x + 3, by + 6, bw / 2 - 3, alt - by - 6, '#000'); ctx.globalAlpha = 1;
    ctx.globalAlpha = .95;                                    /* yansitici seritler */
    hl(sol + 2, by + 16, bw - 4, R.seri);
    hl(sol + 2, by + 19, bw - 4, R.seri);
    ctx.globalAlpha = 1;
    fr(x - 1, by + 6, 2, alt - by - 6, shadeCol(ana, .60));   /* fermuar */
    for (var ai = 0; ai < 24; ai++) {                         /* capraz canta askisi */
      var ax = Math.round(x - 10 + ai * .86), ay = by + 5 + ai;
      if (ay > alt) break;
      fr(ax, ay, 3, 1, '#39312a');
      px(ax, ay, '#5c4e40');
    }
    kalipYaka(x, by, sh, s);

  } else if (id === 'sofor') {
    /* SUVETER: V yaka, altindan gomlek yakasi cikar, kollar suveter */
    kalipZemin(x, by, bw, ana);
    for (var vi = 0; vi < 7; vi++) {                          /* V yaka acikligi */
      fr(x - 5 + vi, by + 4 + vi, 10 - vi * 2, 1, '#e0dcd0');
      px(x - 5 + vi, by + 4 + vi, shadeCol(ana, .60));
      px(x + 4 - vi, by + 4 + vi, shadeCol(ana, .60));
    }
    fr(x - 6, by + 3, 4, 3, '#e0dcd0');                       /* gomlek yaka ucu */
    fr(x + 3, by + 3, 4, 3, '#cfcabc');
    fr(x - 1, by + 11, 2, 8, R.seri);                         /* ince kravat */
    fr(sol + 2, by + 17, 6, 5, koy);                          /* gogus cebi */
    hl(sol + 2, by + 17, 6, ac);
    ctx.globalAlpha = .30; hl(sol + 1, by + 29, bw - 2, '#000'); ctx.globalAlpha = 1;
  }
}

/* ---- KAFA KATMANI: sacin ve aksesuarin ustune ---- */
function drawKalipBas(id, hx, hy, hw, s, L) {
  if (!id || id === 'yok') return;
  var R = KALIP_RENK[id];
  if (!R) return;
  var ana = kalipAna(id, L.seed), ac = shadeCol(ana, 1.25);

  if (id === 'isci') {
    /* BARET: kubbe + genis siperlik + tepe kaburgasi */
    var bc = '#e8b820';
    ell(hx, hy - 7, hw + 1, 8, shadeCol(bc, .70));
    ell(hx, hy - 8, hw, 7, bc);
    fr(hx - hw - 4, hy - 6, hw * 2 + 8, 3, shadeCol(bc, .62)); /* siperlik */
    fr(hx - hw - 4, hy - 6, hw * 2 + 8, 2, shadeCol(bc, .88));
    hl(hx - hw - 3, hy - 6, hw * 2 + 6, shadeCol(bc, 1.15));
    fr(hx - 1, hy - 15, 2, 8, shadeCol(bc, .78));             /* kaburga */
    ell(hx - 4, hy - 12, 4, 2, shadeCol(bc, 1.35));
    ctx.globalAlpha = .40; hl(hx - hw + 2, hy - 4, hw * 2 - 4, '#000'); ctx.globalAlpha = 1;

  } else if (id === 'kuzeyli') {
    /* KOYU DALGALI SAC: omuza inen kutle */
    var kzc = '#241d16';
    ell(hx, hy - 7, hw + 1, 6, kzc);                          /* tepe */
    ell(hx - 2, hy - 9, hw - 2, 3, shadeCol(kzc, 1.4));
    /* Yandan omuza inen dalgali tutamlar: silueti bunlar veriyor.
       Once tepede siyah bir bant vardi, kask gibi duruyordu. */
    /* Tutamlar kafa siluetinin DISINDA kalmali: iceriden baslayinca
       yanaklari kapatip yuzu iki koyu bandin arasina sikistiriyordu. */
    for (var t2 = 0; t2 < 13; t2++) {
      var tz = hy - 6 + t2, tk = 3 + (t2 % 3 === 0 ? 1 : 0);
      fr(hx - hw - tk, tz, tk, 1, kzc);
      fr(hx + hw, tz, tk, 1, shadeCol(kzc, .84));
      if (t2 % 4 === 1) px(hx - hw - tk, tz, shadeCol(kzc, 1.3));
    }
    /* SAKAL: erkege benzemiyordu cunku sakali yoktu. Onemli olan tonu:
       sacla ayni koyulukta olursa sac+biyik+sakal tek maske olup yuzu
       yutuyor. Sakal KAHVERENGI ve yalniz cene hattini sariyor,
       yanaklar acikta kaliyor. */
    var skl = '#4a3a28', sklK = '#33271b';
    for (var sb = 0; sb < 7; sb++) {
      var sbw = Math.max(2, 6 - Math.round(sb * .8));
      var sbz = hy + 5 + sb;
      fr(hx - sbw, sbz, sbw * 2, 1, sb < 4 ? skl : sklK);
      px(hx - sbw, sbz, sklK); px(hx + sbw - 1, sbz, sklK);
    }
    fr(hx - 5, hy + 3, 11, 1, skl);                           /* biyik: ince */
    px(hx - 5, hy + 3, sklK); px(hx + 5, hy + 3, sklK);
    vl(hx - 6, hy + 1, 5, sklK);                              /* favoriler */
    vl(hx + 5, hy + 1, 5, sklK);

  } else if (id === 'kimyager') {
    /* KEL KAFA + GOZLUK + KECISAKAL. Kel gorunmesi icin alttaki
       saci ten renginde bir kubbeyle kapatmak gerekiyor. */
    ell(hx, hy - 6, hw + 1, 7, s[1]);                         /* kel kubbe */
    ell(hx - 1, hy - 7, hw - 1, 5, s[2]);
    ell(hx - 3, hy - 9, 3, 2, s[3]);                          /* tepe parlamasi */
    fr(hx - hw - 1, hy - 2, 2, 5, '#8f8f9a');                 /* yanlarda kir sac */
    fr(hx + hw - 1, hy - 2, 2, 5, '#8f8f9a');
    fr(hx - 3, hy + 9, 6, 2, '#3a2a1c');                      /* keci sakal */
    px(hx - 3, hy + 9, '#50402c'); px(hx + 2, hy + 9, '#50402c');

  } else if (id === 'cirak') {
    /* DAGINIK KOYU SAC + YUVARLAK GOZLUK */
    var ccc = '#2a1e14';
    ell(hx, hy - 7, hw + 2, 6, ccc);
    fr(hx - hw - 2, hy - 7, hw * 2 + 4, 3, ccc);
    for (var di = 0; di < 5; di++) {                          /* daginik uclar */
      var dx2 = hx - hw + di * Math.max(2, ((hw * 2) / 4) | 0);
      fr(dx2, hy - 10 - (di % 2), 3, 3, ccc);
    }
    ell(hx - 3, hy - 9, 4, 2, shadeCol(ccc, 1.5));

  } else if (id === 'kralice') {
    /* GUMUS ORGU SAC: tepe kutlesi + iki yandan omuza inen orgu */
    /* Sac GRI degil PLATIN SARISI: referansta sicak, kremimsi beyaz.
       #ced3dc mavimsi griydi ve yasli gosteriyordu. */
    var gc2 = '#e8dcc0';
    ell(hx, hy - 7, hw + 2, 6, '#b8a684');
    fr(hx - hw - 2, hy - 7, hw * 2 + 4, 3, '#b8a684');
    ell(hx - 1, hy - 8, hw + 1, 5, gc2);
    ell(hx - 3, hy - 10, 4, 2, '#fdf8ec');
    for (var oi = 0; oi < 5; oi++) {
      var oz = hy - 2 + oi * 4;
      ell(hx - hw - 1, oz, 3, 3, '#a89474');
      ell(hx - hw - 1, oz - 1, 3, 2, gc2);
      px(hx - hw - 2, oz - 1, '#fdf8ec');
      ell(hx + hw + 1, oz, 3, 3, '#98846a');
      ell(hx + hw + 1, oz - 1, 3, 2, '#d8c9a8');
    }

  } else if (id === 'bilge') {
    /* SIVRI GENIS KENARLI SAPKA + AK KAS/BIYIK.
       Sakal govde katmaninda; burada yalnizca biyik var. */
    var scc = shadeCol(ana, .92);
    fr(hx - hw - 5, hy - 6, hw * 2 + 10, 3, shadeCol(scc, .68));   /* kenar */
    fr(hx - hw - 5, hy - 6, hw * 2 + 9, 2, scc);
    hl(hx - hw - 4, hy - 7, hw * 2 + 7, shadeCol(scc, 1.2));
    for (var hi = 0; hi < 13; hi++) {                             /* konik tepe */
      var kw = Math.max(1, Math.round((hw - 1) * (1 - hi / 13)));
      var kzz = hy - 8 - hi;
      fr(hx - kw + Math.round(hi * .25), kzz, kw * 2, 1, scc);
      px(hx - kw + Math.round(hi * .25), kzz, shadeCol(scc, 1.25));
    }
    fr(hx - hw + 1, hy - 9, hw * 2 - 2, 2, shadeCol(ana, .62));    /* bant */
    /* AK SAKAL: govde katmanindayken bas onu tamamen ortuyordu.
       Burada, cenenin altindan gogse dogru sarkan konik kutle. */
    for (var bi = 0; bi < 14; bi++) {
      var bw3 = Math.max(2, 8 - Math.round(bi * .48));
      var bz = hy + 4 + bi;
      fr(hx - bw3, bz, bw3 * 2, 1, bi < 9 ? '#d8d8d2' : '#bcbcb6');
      px(hx - bw3, bz, '#9a9a96'); px(hx + bw3 - 1, bz, '#9a9a96');
      if (bi % 4 === 0) hl(hx - bw3 + 1, bz, bw3, '#ffffff');
    }
    fr(hx - 5, hy + 3, 11, 2, '#eeeeea');                         /* biyik */
    px(hx - 5, hy + 3, '#bcbcb6'); px(hx + 5, hy + 3, '#bcbcb6');

  } else if (id === 'turist') {
    /* SAFARI SAPKASI: genis kenar, koyu bant */
    var tc = '#ddc98f';
    ell(hx, hy - 6, hw + 6, 3, shadeCol(tc, .66));
    ell(hx, hy - 7, hw + 5, 3, tc);
    hl(hx - hw - 3, hy - 8, hw * 2 + 6, shadeCol(tc, 1.15));
    ell(hx, hy - 10, hw - 1, 6, shadeCol(tc, .84));
    ell(hx, hy - 11, hw - 2, 5, tc);
    ell(hx - 4, hy - 14, 4, 2, shadeCol(tc, 1.25));
    ctx.globalAlpha = .95; hl(hx - hw + 2, hy - 8, hw * 2 - 4, '#8a5f31'); ctx.globalAlpha = 1;
    fr(hx + hw - 6, hy - 9, 3, 2, '#b8442e');                 /* bant tokasi */

  } else if (id === 'kurye') {
    /* KASK: kubbe GOZLERIN USTUNDE biter, yanaklarda kulaklik, cene kayisi.
       Ilk denemede vizor gozlerin uzerine geliyordu, yuz kayboluyordu;
       ikincisinde yelekle ayni yesildi, bere gibi duruyordu. */
    var kk = R.kask[Math.floor(hash1((L.seed || 1) * 7.3) * R.kask.length)];
    var kkKoy = shadeCol(kk, .58), kkAc = shadeCol(kk, 1.28);
    ell(hx, hy - 9, hw + 2, 9, kkKoy);
    ell(hx, hy - 10, hw + 1, 8, kk);
    fr(hx - hw - 2, hy - 10, hw * 2 + 5, 6, kk);                 /* yanlarda iner */
    fr(hx - hw - 2, hy - 10, 6, 6, kkAc);                        /* sol isik */
    ell(hx - 4, hy - 15, 5, 2, kkAc);
    ctx.globalAlpha = .30; fr(hx + 3, hy - 12, hw - 1, 8, '#000'); ctx.globalAlpha = 1;
    fr(hx - hw - 3, hy - 5, hw * 2 + 6, 2, kkKoy);               /* siperlik dudagi */
    hl(hx - hw - 3, hy - 5, hw * 2 + 6, shadeCol(kk, .88));
    fr(hx - hw - 2, hy - 4, 3, 8, kkKoy);                        /* kulakliklar */
    fr(hx + hw, hy - 4, 3, 8, shadeCol(kk, .48));
    px(hx - hw - 2, hy - 3, kkAc);
    ctx.globalAlpha = .45;                                       /* kaldirilmis vizor */
    fr(hx - hw + 1, hy - 13, hw * 2 - 2, 3, '#8ab8d8');
    ctx.globalAlpha = 1;
    hl(hx - hw + 2, hy - 13, hw * 2 - 4, '#cfe4f2');
    ln(hx - hw, hy + 4, hx - 2, hy + 9, '#2b261f');              /* cene kayisi */
    ln(hx + hw + 1, hy + 4, hx + 2, hy + 9, '#2b261f');
    fr(hx - 3, hy + 9, 6, 2, '#3d362e'); px(hx, hy + 9, '#7a6c58');

  } else if (id === 'sofor') {
    /* KASKET: yassi tepe + sola uzanan kisa siperlik.
       Kasket suveterle ayni tondaydi, bastan asagi tek gri lekeydi. */
    var kc = R.kasket[Math.floor(hash1((L.seed || 1) * 11.9) * R.kasket.length)];
    ell(hx, hy - 8, hw + 1, 5, shadeCol(kc, .66));
    ell(hx, hy - 9, hw, 4, kc);
    fr(hx - hw, hy - 9, hw * 2, 5, kc);
    fr(hx - hw, hy - 9, hw, 5, shadeCol(kc, 1.12));
    hl(hx - hw + 2, hy - 11, hw * 2 - 4, shadeCol(kc, 1.32));
    fr(hx - hw - 5, hy - 5, 9, 2, shadeCol(kc, .52));            /* siperlik */
    hl(hx - hw - 5, hy - 5, 9, shadeCol(kc, .78));
    ctx.globalAlpha = .35; hl(hx - hw + 1, hy - 4, hw * 2 - 2, '#000'); ctx.globalAlpha = 1;
  }
}
