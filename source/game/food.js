/* ============================================================
   DÖNER EFSANESİ — food.js
   Yemek/ürün çizimleri, ikonlar, imleç, para
   ============================================================ */
'use strict';

/* ürün: {kind:'wrap'|'fries'|'drink'|'plate', ...} */

/* ---------- açık lavaş + malzemeler ---------- */
function drawWrapOpen(cx, cy, wrap, t, sc) {
  sc = sc || 1;
  var roll = clamp(wrap.roll || 0, 0, 1);
  ctx.save();
  if (sc !== 1) { ctx.translate(cx, cy); ctx.scale(sc, sc); ctx.translate(-cx, -cy); }

  var rx = 22, ry = 9;
  /* sarma cephesi aşağıdan yukarı ilerler */
  var frontY = lerp(cy + ry + 2, cy, roll);
  var tubeH = lerp(3, 13, roll);
  var topCut = frontY - tubeH / 2;

  /* ---- henüz sarılmamış düz kısım (cephenin üstünde kalan) ---- */
  ctx.save();
  ctx.beginPath();
  ctx.rect(cx - 34, cy - 26, 68, Math.max(0, topCut - (cy - 26)));
  ctx.clip();

  ctx.globalAlpha = .22; ell(cx, cy + ry - 1, rx, 3, '#000'); ctx.globalAlpha = 1;
  ell(cx, cy, rx, ry, '#c9a06a');
  ell(cx, cy - 1, rx, ry, '#f0d5a8');
  ell(cx - 2, cy - 3, rx - 6, ry - 4, '#f8e6c4');
  for (var i = 0; i < 16; i++) {
    var a = hash1(i * 3.1) * TAU, r0 = hash1(i * 7.3);
    px(cx + Math.cos(a) * rx * r0 * .9, cy - 1 + Math.sin(a) * ry * r0 * .9, hash1(i) > .5 ? '#c39a63' : '#e0bd85');
  }
  ell(cx, cy + ry - 3, rx - 1, 2, '#dcbb8b');

  /* ---- iç malzeme ---- */
  /* ---- iç malzeme ----
     Her malzemenin altına koyu bir taban çizilir; yoksa açık renkli
     lavaşın üstünde yoğurt ve patates kayboluyordu. Miktar arttıkça
     hem parça sayısı hem kapladığı genişlik büyür. */
  var mn = wrap.meat || 0, fn = wrap.friesN || 0;
  var by = cy - 3;

  /* --- döner: koyu tabanlı parçalar --- */
  if (mn > 0) {
    /* Et OBEK halinde durur, duz bir serit degil. Blender'da
       (blender/models/durum.py) parcalar lavasin ustunde ortada
       kabarik bir yigin yapiyor; kod da artik ayni egriyi kullaniyor:
       ortadaki parcalar yukari cikar, kenardakiler alcalir. */
    var mOran = clamp(mn / MEAT_NEED, 0, 1);
    var chunks = Math.max(5, Math.round(5 + mOran * 9));
    var mGen = 16 + mOran * 18;
    for (var m = 0; m < chunks; m++) {
      var mu = chunks === 1 ? .5 : m / (chunks - 1);
      var mrnd = hash1(m * 2.1);
      var mx = Math.round(cx - mGen / 2 + mu * mGen + (mrnd * 3 - 1.5));
      /* yigin egrisi: ortada kabarik, kenarda yassi */
      var kub = Math.sin(mu * Math.PI) * (2.2 + mOran * 2.4);
      var my = Math.round(by + 1 - kub + (hash1(m * 5.3) * 2.4 - 1.2));
      var mw = 4 + ((mrnd * 2.4) | 0);
      ctx.globalAlpha = .34; fr(mx - 1, my + 2, mw + 2, 2, '#2a1808'); ctx.globalAlpha = 1;
      fr(mx, my + 1, mw, 2, '#7e4412');       /* alt kenar */
      fr(mx, my, mw, 1, '#bd7024');           /* govde */
      px(mx + 1, my - 1, '#eeb463');          /* ust isik */
      if (hash1(m * 7.7) > .55) px(mx + mw - 2, my - 1, '#ffd291');
      px(mx, my, '#9c5718');                  /* kizarmis uc */
    }
  }

  /* --- patates: dürümün içinde dağınık duran çubuklar ---
     Aynı hizada yan yana çizilince diş sırası gibi duruyordu.
     Artık her çubuğun kendi açısı, boyu ve yüksekliği var; aralarında
     boşluk kalıyor, bir kısmı diğerinin üstüne biniyor. */
  if (fn > 0) {
    var fOran = clamp(fn / FRIES_NEED, 0, 1);
    var fc = Math.max(4, Math.round(4 + fOran * 7));
    var fGen = 16 + fOran * 18;
    for (var f = 0; f < fc; f++) {
      var t0 = f * 3.77 + 1.3;
      /* düzgün aralık yerine saçılmış konum */
      var fu = (f + hash1(t0) * 0.9) / fc;
      var fx = Math.round(cx - fGen / 2 + fu * fGen);
      var fy = Math.round(by + (hash1(t0 * 1.9) * 5 - 2));
      var fL = 4 + ((hash1(t0 * 2.7) * 5) | 0);
      /* açı: -1 aşağı eğik, 0 yatay, 1 yukarı eğik */
      var aci = (hash1(t0 * 4.1) * 2 - 1) * 0.5;
      /* Uc kizarma kademesi (art.js PT tablosuyla ayni aile) */
      var tk = hash1(t0 * 5.3);
      var acik = tk > .66;
      var govde = acik ? '#f0d271' : (tk < .30 ? '#b8801f' : '#dcae42');
      var kenar = acik ? '#a8791c' : (tk < .30 ? '#5e3f0c' : '#8a6218');
      var ustC = acik ? '#fff0b8' : (tk < .30 ? '#d9a03a' : '#f0d271');

      /* zemin gölgesi: çubuk ekmeğin üstünde duruyor hissi */
      ctx.globalAlpha = .30;
      for (var g0 = 0; g0 < fL; g0++) {
        px(fx + g0, fy + Math.round((g0 - fL / 2) * aci) + 2, '#6a4a12');
      }
      ctx.globalAlpha = 1;

      /* gövde: iki piksel kalınlık, uçlarda kesit */
      for (var q0 = 0; q0 < fL; q0++) {
        var qy = fy + Math.round((q0 - fL / 2) * aci);
        var uc = (q0 === 0 || q0 === fL - 1);
        px(fx + q0, qy + 1, kenar);
        px(fx + q0, qy, uc ? kenar : govde);
      }
      /* üst ışık şeridi: ortada, uçlara değmiyor */
      if (fL > 3) {
        for (var q1 = 1; q1 < fL - 1; q1++) {
          if (hash1(t0 + q1) < .35) continue;      /* kesintili parlaklık */
          px(fx + q1, fy + Math.round((q1 - fL / 2) * aci) - 1, ustC);
        }
      }
    }
  }

  /* --- turşu: koyu yeşil taban + açık üst yüz --- */
  var pkN = wrap.pickleN || 0;
  if (pkN > 0) {
    var pOran = clamp(pkN / PICKLE_NEED, 0, 1);
    var pc = Math.max(3, Math.round(3 + pOran * 5));
    var pGen = 14 + pOran * 16;
    for (var k = 0; k < pc; k++) {
      var pu = pc === 1 ? .5 : k / (pc - 1);
      var kx = Math.round(cx - pGen / 2 + pu * pGen);
      var ky = Math.round(by - 3 + ((hash1(k * 4.1) * 3) | 0));
      ctx.globalAlpha = .32; ell(kx, ky + 2, 4, 2, '#12200a'); ctx.globalAlpha = 1;
      ell(kx, ky + 1, 4, 2, '#2c4410');
      ell(kx, ky, 4, 2, '#6e9128');
      ell(kx - 1, ky - 1, 2, 1, '#a8ca52');
      px(kx + 1, ky, '#c4dc74');
    }
  }

  /* --- yoğurt: tek piksel nokta değil, koyu gölgeli kalın şerit --- */
  var ygN = wrap.yogurtN || 0;
  if (ygN > 0) {
    var yOran = clamp(ygN / YOGURT_NEED, 0, 1);
    var yGen = Math.round(14 + yOran * 20);
    var yKal = 1 + Math.round(yOran * 1.6);     /* şerit kalınlığı */
    var y0 = cx - yGen / 2;
    /* önce koyu gölge: lavaştan ayrılsın */
    for (var z0 = 0; z0 <= yGen; z0++) {
      var zy0 = by - 5 + Math.sin(z0 * .42 + 1.1) * 2.1;
      ctx.globalAlpha = .30;
      fr(Math.round(y0 + z0), Math.round(zy0) + yKal, 1, 2, '#6a6252');
      ctx.globalAlpha = 1;
    }
    /* şeridin gövdesi */
    for (var z1 = 0; z1 <= yGen; z1++) {
      var zx1 = Math.round(y0 + z1);
      var zy1 = Math.round(by - 5 + Math.sin(z1 * .42 + 1.1) * 2.1);
      fr(zx1, zy1, 1, yKal, '#cfc4a6');         /* alt: gölgeli krem */
      px(zx1, zy1, '#f8f4e6');                  /* üst: parlak yüz */
      if (z1 % 5 === 2) px(zx1, zy1 - 1, '#ffffff');   /* kabarcık parıltısı */
    }
  }
  if (wrap.sauce) {
    var sc0 = wrap.sauce === 'hot' ? '#b3241a' : '#e6dfc8';
    var sc1 = wrap.sauce === 'hot' ? '#f04a34' : '#fdfaf0';
    for (var z = 0; z < 26; z++) {
      var zx = cx - 17 + z * 1.35, zy = by - 6 + Math.sin(z * 1.35) * 3;
      px(zx, zy + 1, sc0); px(zx, zy, sc1);
    }
    if (wrap.sauce === 'hot') { px(cx - 9, by - 8, '#ff8a70'); px(cx + 7, by - 9, '#ff8a70'); }
    else { px(cx - 6, by - 9, '#ffffff'); px(cx + 9, by - 8, '#ffffff'); }
  }
  ctx.restore();

  /* ---- yuvarlanan rulo (aşağıdan yukarı) ---- */
  if (roll > 0) {
    var th = Math.max(3, Math.round(tubeH));
    var ty = Math.round(frontY - th / 2);
    var tw = Math.round(rx * 2 * (0.88 + 0.12 * roll));
    var tx = Math.round(cx - tw / 2);
    var rr = Math.min(5, Math.floor(th / 2));
    ctx.globalAlpha = .26; ell(cx, cy + ry + 1, tw / 2, 3, '#000'); ctx.globalAlpha = 1;
    rrect(tx, ty, tw, th, rr, '#b98d5c');
    rrect(tx, ty, tw, Math.max(1, th - 2), rr, '#e8c99a');
    if (th > 5) rrect(tx + 4, ty + 1, tw - 9, Math.max(1, Math.round(th * .22)), 1, '#f8e6c4');
    ctx.globalAlpha = .35; hl(tx + 3, ty + th - 2, tw - 6, '#a8814e'); ctx.globalAlpha = 1;
    /* dönüş: kayan çapraz dikişler */
    var scroll = (roll * 40) % 9;
    for (var ri = -9; ri < tw; ri += 9) {
      var sxp = tx + ri + scroll;
      if (sxp < tx + 2 || sxp > tx + tw - 2) continue;
      ctx.globalAlpha = .28;
      ln(sxp, ty + 1, sxp + Math.max(1, Math.round(th * .3)), ty + th - 2, '#b98d5c');
      ctx.globalAlpha = 1;
    }
    /* uçlarda sarım spirali */
    if (th > 6) {
      ell(tx + 2, ty + th / 2, 2, th / 2 - 1, '#dcbb8b');
      ell(tx + tw - 3, ty + th / 2, 2, th / 2 - 1, '#dcbb8b');
      px(tx + 2, ty + Math.round(th / 2) - 1, '#f0d5a8');
      px(tx + tw - 3, ty + Math.round(th / 2) - 1, '#f0d5a8');
    }
    /* yuvarlanan ön kenar (üst tarafta, lavaşı içine alıyor) */
    ctx.globalAlpha = .40;
    hl(tx + 2, ty, tw - 4, '#a8814e');
    ctx.globalAlpha = 1;
    hl(tx + 3, ty + 1, tw - 6, '#fff0d0');
    if (roll < 1 && chance(.3)) part({ x: cx + rnd(-16, 16), y: ty, vx: rnd(-6, 6), vy: rnd(-20, -6), life: .35, col: '#f8e6c4', g: 90, sz: 1 });
  }
  ctx.restore();
}

/* ---------- tahtadaki bütün pide (doğranmadan önce) ---------- */
/* Blender: blender/models/sos.py -> sahne_pide().
   Pide YASSI bir elips levha; 5 düşey şerit, her şeridin derinliği ve
   kalınlığı elips eğrisinden geliyor. Doğranan şerit yerinde küplere
   dönüşüyor (İskender'de pide küp doğranır, dilim değil). */
var PIDE_KAL = 5.2;    /* kabuk kalınlığı (ön yüz) */
var PIDE_DER = 3.4;    /* üst yüzeyin yarı derinliği (oblik açılım) */

/* q. şeridin ölçüleri: kenarlar, derinlik, kalınlık, üst yüzeyin arka satırı.
   Arka satır FLOAT'tan yuvarlanıyor: tam sayı derinlik kullanınca uç
   şeritler ortadan 5 piksel alçak kalıyor ve elips yerine "plato +
   kanat" gibi duruyordu. */
function pideSerit(cx, q) {
  var seg = PIDE_NEED + 1, rx = 24;
  var u = (q + .5) / seg - .5;
  var kk = Math.abs(u * 2.0);                    /* 0 ortada .. 0.8 uçlarda */
  var d = PIDE_DER * Math.sqrt(Math.max(.10, 1 - kk * kk * .80));
  var h = PIDE_KAL * (.78 + .22 * Math.sqrt(Math.max(0, 1 - kk * kk)));
  return {
    L: Math.round(cx - rx + q * (rx * 2 / seg)),
    R: Math.round(cx - rx + (q + 1) * (rx * 2 / seg)),
    d: d, h: Math.max(2, Math.round(h)),
    geri: Math.round(h + d * 2)                  /* tabandan üst arka kenara */
  };
}

/* Şef bıçağı: ağız aşağıda, sap yukarıda. Eski çizimde sap ALTTA idi,
   bıçak baş aşağı duruyordu. Namlu aşağı doğru genişliyor ve hafif sola
   yatıyor — 3 piksellik dik dikdörtgen ekranda kâğıt parçası gibi
   duruyordu. agizY = kesici kenarın oturduğu satır. */
function pideBicak(x, agizY) {
  var bh = 10, r, ww, x0;
  for (r = 0; r < bh; r++) {
    ww = 4 + Math.round(4 * r / (bh - 1));       /* 4 -> 8 piksel */
    x0 = x - ww + 2 + Math.round((bh - 1 - r) * .18);
    fr(x0, agizY - bh + r, ww, 1, '#aab4bd');
    hl(x0, agizY - bh + r, 2, '#dfe6ec');        /* sol yüzde parlama */
    px(x0 + ww - 1, agizY - bh + r, '#6d7a86');  /* sırt gölgesi */
  }
  hl(x - 6, agizY - 1, 8, '#ffffff');            /* keskin ağız */
  px(x - 7, agizY - 1, '#dfe6ec');
  /* bolster */
  fr(x - 1, agizY - bh - 2, 5, 2, '#8f979f');
  hl(x - 1, agizY - bh - 2, 5, '#c3ccd3');
  /* sap: sağa yatık */
  for (r = 0; r < 7; r++) {
    x0 = x + Math.round(r * .3);
    fr(x0 - 2, agizY - bh - 3 - r, 6, 1, '#3a2718');
    fr(x0 - 1, agizY - bh - 3 - r, 4, 1, '#7a5230');
    px(x0 - 1, agizY - bh - 3 - r, '#a5733f');
  }
  px(x + 1, agizY - bh - 6, '#c9a06a');          /* perçin */
}

/* doğranmış tek küp: yan yüz + üst yüzey + kesik yüz */
function pideKup(x, y, w, hh, dd) {
  fr(x, y - hh, w, hh, '#b8842c');
  fr(x, y - 2, w, 2, '#8a5f2a');
  fr(x, y - hh - dd, w, dd, '#e8bd72');
  hl(x, y - hh - dd, w, '#f6dfa8');
  vl(x + w - 1, y - hh + 1, hh - 1, '#f0dcb0');   /* kesilmiş yüz */
}

function drawPideBoard(cx, cy, it, t, sc) {
  sc = sc || 1;
  ctx.save();
  if (sc !== 1) { ctx.translate(cx, cy); ctx.scale(sc, sc); ctx.translate(-cx, -cy); }
  var n = Math.min(it.n || 0, PIDE_NEED);
  var ch = clamp(it.chop || 0, 0, 1);            /* chop 0'in altına taşabiliyor */
  var seg = PIDE_NEED + 1;
  var taban = cy + 6;                             /* pidenin ön-alt çizgisi */
  var q, S;

  /* un serpintisi */
  for (var f = 0; f < 12; f++) {
    ctx.globalAlpha = .35;
    px(cx - 28 + hash1(f * 3.7) * 56, taban + 1 + hash1(f * 5.1) * 4, '#f4ead2');
    ctx.globalAlpha = 1;
  }
  /* gölge */
  ctx.globalAlpha = .32; ell(cx, taban + 1, 25, 3, '#3a2a18'); ctx.globalAlpha = 1;

  /* --- şeritler: arkadan öne değil, soldan sağa (hepsi aynı derinlikte) --- */
  for (q = 0; q < seg; q++) {
    S = pideSerit(cx, q);
    var w = S.R - S.L;
    if (q < n) {
      /* doğranmış: yerinde küp yığını. Arka sıra önce. */
      for (var b = 1; b >= 0; b--) {
        for (var a = 0; a < 3; a++) {
          var hs = hash1(q * 13.7 + a * 3.1 + b * 7.7);
          var kx = S.L + 1 + a * 3 + (b ? 1 : 0);
          if (kx + 3 > S.R) continue;
          pideKup(kx, taban - b * 4 - Math.round(hs * 1.4), 3, 3, 2);
        }
      }
      continue;
    }
    /* --- bütün şerit --- */
    var ust = taban - S.geri;                      /* üst yüzeyin arka kenarı */
    var on = taban - S.h;                          /* üst yüzeyin ön kenarı */
    /* Uç şeritler 1 piksel içeri: kare kesilmiş uçlar elipsi tuğla
       gibi gösteriyordu. */
    var sol = S.L + (q === 0 ? 1 : 0);
    var sag = S.R - (q === seg - 1 ? 1 : 0);
    var gw = sag - sol;
    /* kabuk (yan yüz) */
    fr(sol, on, gw, S.h, '#a8762e');
    fr(sol, taban - 2, gw, 2, '#7a4f22');
    hl(sol, taban - 1, gw, '#5e3a12');
    if (q === 0) vl(S.L, on + 1, S.h - 2, '#8a5f2a');        /* yuvarlak uç */
    if (q === seg - 1) vl(S.R - 1, on + 1, S.h - 2, '#8a5f2a');
    /* üst yüzey */
    var uc = (q === 0 || q === seg - 1) ? 1 : 0;    /* uçlarda köşe yumuşatma */
    fr(sol + (q === 0 ? uc : 0), ust, gw - uc, on - ust, '#dcae55');
    hl(sol + (q === 0 ? uc : 0), ust, gw - uc, '#f0cd94');   /* arka kenar ışığı */
    hl(sol, on - 1, gw, '#c98f3c');                /* ön dudak */
    /* baklava deseni: şerit başına TEK çapraz çentik. Eskiden şerit
       başına 6 piksel vardı ve üst yüzey gürültüye dönüşüyordu. */
    var cy0 = ust + 2;
    for (var e = 0; e < 3; e++) if (cy0 + e < on - 1) px(S.L + 3 + e, cy0 + e, '#a8762e');
    /* kabarcık + susam */
    var bs = hash1(q * 5.3);
    fr(S.L + 2 + Math.round(bs * (w - 6)), ust + 1, 2, 1, '#b8842c');
    px(S.L + 1 + Math.round(hash1(q * 9.1) * (w - 3)), on - 3, '#fce7bd');
    /* kesilmiş komşu varsa iç yüzü göster */
    if (q === n && n > 0) vl(S.L, on + 1, S.h - 2, '#f4e6c2');
  }

  /* --- bıçak: sap YUKARIDA, ağız aşağıda; vuruşta pideye iner --- */
  if (n < PIDE_NEED) {
    S = pideSerit(cx, n);
    var S2 = pideSerit(cx, Math.min(n + 1, seg - 1));
    var kxp = S.R;
    /* ch 1 = tam vurdu (aşağıda), 0 = dinlenme (yukarıda).
       Eskiden tersti: vuruş anında bıçak yukarı zıplıyordu. */
    var lift = Math.round(8 * (1 - Math.pow(ch, .55)));
    /* iki komşu şeridin YÜKSEK olanına iniyor, yoksa bıçak pideye
       gömülmüş gibi duruyor */
    var agiz = taban - Math.max(S.geri, S2.geri) + 1 - lift;
    /* tahtadaki gölge: bıçak indikçe küçülüp koyulaşıyor */
    ctx.globalAlpha = .10 + .16 * ch;
    fr(kxp - 4, taban + 1, 8 - Math.round(lift * .25), 2, '#000');
    ctx.globalAlpha = 1;
    pideBicak(kxp, agiz);
    /* çarpma: pideyi boydan boya kesen beyaz çubuk yerine ağzın iki
       yanında kısa kıvılcım — 15 piksellik şerit ekranda bıçağı değil
       çizgiyi gösteriyordu. */
    if (ch > .55) {
      ctx.globalAlpha = (ch - .55) * 1.4;
      hl(kxp - 8, agiz - 1, 4, '#ffffff');
      hl(kxp + 2, agiz - 1, 4, '#ffffff');
      px(kxp - 10, agiz - 3, '#fff6dc'); px(kxp + 6, agiz - 4, '#fff6dc');
      ctx.globalAlpha = 1;
    }
  }
  ctx.restore();
}

/* ---------- iskender tabağı ---------- */
function drawPlate(cx, cy, pl, t, sc) {
  sc = sc || 1;
  ctx.save();
  if (sc !== 1) { ctx.translate(cx, cy); ctx.scale(sc, sc); ctx.translate(-cx, -cy); }
  var rx = 20, ry = 8;
  var amt = 1;
  ctx.globalAlpha = .25; ell(cx, cy + ry + 1, rx, 3, '#000'); ctx.globalAlpha = 1;
  /* porselen tabak */
  ell(cx, cy + 2, rx, ry, '#aeb6bd');
  ell(cx, cy + 1, rx, ry, '#e9eef2');
  ell(cx, cy, rx - 1, ry - 1, '#fbfdfe');
  ell(cx, cy + 1, rx - 4, ry - 2, '#d6dee4');
  ell(cx, cy, rx - 4, ry - 2, '#f2f6f9');
  /* mavi kenar şeridi */
  ctx.globalAlpha = .5;
  ell(cx, cy - 1, rx - 2, ry - 1, '#8fb4d8');
  ell(cx, cy - 1, rx - 3, ry - 2, '#f2f6f9');
  ctx.globalAlpha = 1;
  /* PIDE YATAGI. Blender: blender/models/sos.py -> sahne_tabak.
     Eskiden kupler tabaga RASTGELE dagiliyordu, yemek duz bir leke
     gibi duruyordu. Gercek iskender bir YIGIN'dir: kupler merkeze
     dogru yukselir, ust siralar daha dar ve daha acik tonda. */
  if (pl.pide) {
    for (var kat = 0; kat < 3; kat++) {
      var kn = [9, 6, 3][kat], kry = [0, -2, -4][kat];
      var kgen = [1.0, .66, .36][kat];
      for (var i = 0; i < kn; i++) {
        var a = (i / kn) * TAU + kat * 1.1;
        var px0 = cx + Math.cos(a) * (rx - 7) * kgen;
        var py0 = cy - 1 + kry + Math.sin(a) * (ry - 3) * kgen;
        fr(px0 - 2, py0 - 1, 4, 4, '#7a5228');
        fr(px0 - 2, py0 - 1, 4, 3, kat ? '#e0b478' : '#d9a765');
        px(px0 - 1, py0 - 1, kat ? '#fce7bd' : '#f0cd94');
      }
    }
  }
  /* ET: yiginin USTUNU orten kivrilmis seritler */
  if (pl.meat > 0) {
    var mc = Math.max(0, Math.round(Math.min(pl.meat, 6) * 1.6 * amt));
    for (var m = 0; m < mc; m++) {
      var ma = (m / Math.max(1, mc)) * TAU + 0.7;
      var mrr = .22 + (m % 3) * .26;
      var mx0 = cx + Math.cos(ma) * (rx - 8) * mrr;
      var my0 = cy - 5 + Math.sin(ma) * (ry - 4) * mrr;
      fr(mx0 - 4, my0, 8, 4, '#7a4318');
      fr(mx0 - 4, my0, 8, 3, '#c98436');
      hl(mx0 - 3, my0, 6, '#eeb464');
      px(mx0 + 3, my0 + 2, '#9a5a20');
    }
  }
  if (pl.butter) {
    /* TEREYAGI: yiginin uzerinden akan tabaka + kenardan sizan damlalar */
    ctx.globalAlpha = .78 * amt + .22;
    for (var b = 0; b < 22; b++) {
      var bx0 = cx - 14 + b * 1.35, by0 = cy - 7 + Math.sin(b * .9) * 2.4;
      fr(bx0, by0, 2, 3, '#a83a12');
      fr(bx0, by0, 2, 2, '#e2621c');
      if (b % 4 === 0) px(bx0, by0, '#ffb45a');
    }
    for (var b2 = 0; b2 < 4; b2++) {
      var dx0 = cx - 10 + b2 * 7;
      fr(dx0, cy - 2 + (b2 % 2), 2, 3, '#c04a14');
      px(dx0, cy - 2 + (b2 % 2), '#f07a2a');
    }
    ctx.globalAlpha = 1;
    /* buhar */
    if (chance(.10)) part({ x: cx + rnd(-10, 10), y: cy - 6, vx: rnd(-4, 4), vy: rnd(-16, -8), life: .6, col: 'rgba(255,220,180,.5)', g: -8, sz: 1 });
  }
  /* --- garnitür: domates dilimi + biber --- */
  if (pl.tomato) {
    for (var ti = 0; ti < Math.min(3, pl.tomato); ti++) {
      drawTomatoSlice(cx - 12 + ti * 7, cy + ry - 5, 5);
    }
  }
  if (pl.pepper) {
    for (var pi2 = 0; pi2 < Math.min(2, pl.pepper); pi2++) {
      drawPepper(cx + 7 + pi2 * 7, cy - 1, 12, pi2 ? 1 : -1);
    }
  }
  if (pl.yogurt) {
    var yx = cx + 11, yy = cy + 1;
    ell(yx, yy + 1, 6 * amt + 1, 3.2 * amt + .6, '#cfc9b4');
    ell(yx, yy, 6 * amt + 1, 3.2 * amt + .6, P.s0);
    ell(yx - 1, yy - 1, 3.4 * amt + .5, 1.6 * amt + .4, '#ffffff');
  }
  ctx.restore();
}
/* ---------- sos rozeti: sarılmış dürümün üstünde ---------- */
function sauceBadge(cx, cy, sauce) {
  if (!sauce) return;
  var bx = Math.round(cx), by = Math.round(cy);
  var aci = sauce === 'hot';

  /* kağıda iliştirilmiş yuvarlak etiket */
  ctx.globalAlpha = .32; disc(bx, by + 2, 7, '#000'); ctx.globalAlpha = 1;
  disc(bx, by, 7, '#15100c');
  /* zemin: acıda koyu kiremit, sarımsakta koyu haki — simge üstünde patlasın */
  disc(bx, by, 6, aci ? '#6e1108' : '#5a5340');
  disc(bx, by, 5, aci ? '#a52014' : '#7d7458');
  ctx.globalAlpha = .30; hl(bx - 2, by - 4, 5, '#ffffff'); ctx.globalAlpha = 1;

  if (aci) {
    /* SİVRİ BİBER: üstte geniş, aşağı doğru sivrilen, hafif kıvrık */
    var gov = [           /* [dy, x0, genişlik] */
      [-3, 0, 2], [-2, 0, 3], [-1, 0, 3],
      [0, 0, 3], [1, 1, 2], [2, 1, 2], [3, 2, 1]
    ];
    for (var i = 0; i < gov.length; i++) {
      var dy = gov[i][0], x0 = gov[i][1] - 1, gw = gov[i][2];
      fr(bx + x0, by + dy, gw, 1, '#7a0f06');          /* gölge tarafı */
      fr(bx + x0, by + dy, gw - (gw > 1 ? 1 : 0), 1, '#e8321c');
      px(bx + x0, by + dy, '#ff8a6a');                  /* ışık şeridi */
    }
    /* yeşil sap, hafif eğik */
    px(bx - 1, by - 4, '#3f6d18');
    px(bx, by - 5, '#548f22');
    px(bx + 1, by - 6, '#6bab2e');
  } else {
    /* SARIMSAK BAŞI: yuvarlak taban, sivri tepe, dişler ayrı */
    fr(bx - 3, by, 7, 3, '#efe9d6');                    /* geniş taban */
    fr(bx - 2, by - 2, 5, 2, '#f8f4e6');                /* omuz */
    px(bx - 3, by + 3, '#d8d0b8'); px(bx + 3, by + 3, '#d8d0b8');
    fr(bx - 2, by + 3, 5, 1, '#e4dcc4');                /* alt kavis */
    /* diş ayrım çizgileri */
    vl(bx - 1, by - 1, 4, '#c9c0a4');
    vl(bx + 1, by - 1, 4, '#c9c0a4');
    /* sivri sap */
    px(bx, by - 3, '#cdc4a6');
    px(bx, by - 4, '#a89a78');
    px(bx, by - 5, '#8a7c5c');
    /* parlaklık */
    px(bx - 2, by, '#ffffff'); px(bx - 2, by + 1, '#ffffff');
  }
}

/* ---------- sarılmış dürüm ---------- */
function drawWrapRolled(cx, cy, wrap, t, sc) {
  sc = sc || 1;
  if (sc !== 1) { ctx.save(); ctx.translate(cx, cy); ctx.scale(sc, sc); ctx.translate(-cx, -cy); }
  var w = 40, h = 13, grilled = !!wrap.grilled;
  /* kizarma 0..1: izgarada bekledikce kararir. grilled ise tam kizarmis. */
  var kiz = grilled ? 1 : clamp(wrap.kizarma || 0, 0, 1);
  var base = kiz <= 0 ? '#f0d5a8' : mixHex('#f0d5a8', '#d9a765', kiz);
  var shade = kiz <= 0 ? '#c9a06a' : mixHex('#c9a06a', '#a87a41', kiz);
  var lite = kiz <= 0 ? '#f8e6c4' : mixHex('#f8e6c4', '#f0c68e', kiz);
  /* YANMIS: izgarada unutulmus. Komur rengi, bakinca anlasilir. */
  if (wrap.burnt) {
    base = '#3f3129'; shade = '#241c17'; lite = '#544234';
  }
  var pt = wrap.paperT > 0 ? wrap.paperT : 0;   /* 1 -> yeni takıldı */
  var po = Math.round(pt * pt * 10);            /* kağıt aşağıdan yukarı oturur */
  var pl = cx - w / 2 - 1, pw = 21;             /* kağıt manşonu */

  ctx.globalAlpha = .25; ell(cx, cy + 8, w / 2, 3, '#000'); ctx.globalAlpha = 1;

  /* ---- KAĞIDIN ARKA KATI (dürümün arkasında görünen ağız payı) ---- */
  if (wrap.paper) {
    ctx.globalAlpha = 1 - pt * .3;
    rrect(pl - 1, cy - h / 2 - 1 + po, pw + 3, h + 2, 5, '#cfc9b8');
    rrect(pl - 1, cy - h / 2 - 1 + po, pw + 3, h + 1, 5, '#e8e4d6');
    ctx.globalAlpha = 1;
  }

  /* ---- DÜRÜM GÖVDESİ ---- */
  rrect(cx - w / 2, cy - h / 2, w, h, 5, shade);
  rrect(cx - w / 2, cy - h / 2, w, h - 2, 5, base);
  rrect(cx - w / 2 + 3, cy - h / 2 + 1, w - 8, 4, 2, lite);
  ell(cx - w / 2 + 2, cy, 3, h / 2 - 1, shade);
  ell(cx + w / 2 - 2, cy, 3, h / 2 - 1, shade);
  px(cx - w / 2 + 2, cy, base); px(cx + w / 2 - 2, cy, base);
  /* sarım dikişleri */
  for (var si = 0; si < 4; si++) {
    ctx.globalAlpha = .22;
    ln(cx - w / 2 + 8 + si * 8, cy - 5, cx - w / 2 + 10 + si * 8, cy + 5, shade);
    ctx.globalAlpha = 1;
  }
  /* ızgara izleri: kizardikca belirginlesir, tek tek basar */
  if (kiz > .18) {
    var izGuc = clamp((kiz - .18) / .82, 0, 1);
    for (var gi = 0; gi < 5; gi++) {
      /* her iz biraz sonra cikar: sirayla yaniyormus gibi */
      var izK = clamp((izGuc - gi * .11) / .45, 0, 1);
      if (izK <= 0) continue;
      ctx.globalAlpha = .55 * izK;
      ln(cx - 14 + gi * 7, cy - 4, cx - 11 + gi * 7, cy + 4, '#8a5a2a');
      ctx.globalAlpha = 1;
    }
    /* iyice kizarinca koyu benekler */
    if (kiz > .62) {
      ctx.globalAlpha = .40 * clamp((kiz - .62) / .38, 0, 1);
      for (var kb = 0; kb < 6; kb++) {
        px(Math.round(cx - 15 + hash1(kb * 3.7) * 30), Math.round(cy - 4 + hash1(kb * 8.3) * 8), '#6b3f18');
      }
      ctx.globalAlpha = 1;
    }
  }
  if (grilled) {
  }
  /* uçtan taşan içerik */
  px(cx + w / 2 - 4, cy - 2, '#c98436'); px(cx + w / 2 - 5, cy + 1, '#8a4f1e');
  if (wrap.pickle) px(cx + w / 2 - 6, cy - 3, P.g1);
  if (wrap.yogurt) px(cx + w / 2 - 3, cy + 2, P.s0);
  if (wrap.friesN > 0) px(cx + w / 2 - 7, cy + 2, P.p1);

  /* ---- KAĞIT: silindire sarılı manşon, ağzı çapraz kesik ---- */
  if (wrap.paper) {
    var ph = h;
    var pty = Math.round(cy - ph / 2 + po);
    var alpha = 1 - pt * .15;
    ctx.globalAlpha = alpha;
    for (var yy = 0; yy < ph; yy++) {
      var tt = yy / (ph - 1);
      /* yuvarlak sol uç */
      var inset = (yy === 0 || yy === ph - 1) ? 3 : (yy === 1 || yy === ph - 2 ? 1 : 0);
      var rowX = pl + inset;
      /* çapraz ağız: üstte daha kısa, altta daha uzun (kağıt açılıyor) */
      var rowR = pl + pw - 5 + Math.round(tt * 6);
      var rowW = rowR - rowX;
      if (rowW < 2) continue;
      var col;
      if (yy === 0) col = '#fdfaf0';
      else if (yy < 3) col = '#f8f5ea';
      else if (yy < ph - 4) col = '#f2eee0';
      else if (yy < ph - 2) col = '#e2ddcc';
      else col = '#cfc8b4';
      fr(rowX, pty + yy, rowW, 1, col);
      /* ağız kenarı */
      px(rowR - 1, pty + yy, yy < 3 ? '#ffffff' : '#e8e2d0');
      px(rowR, pty + yy, 'rgba(120,112,94,.45)');
    }
    /* sol uçta büzülme katları */
    for (var fi = 0; fi < 3; fi++) {
      ctx.globalAlpha = alpha * (.28 + fi * .07);
      ln(pl + 2 + fi * 2, pty + 2, pl + 4 + fi * 2, pty + ph - 3, '#d2ccb8');
    }
    ctx.globalAlpha = alpha;
    /* baskı bantları (çapraz ağza göre kısalır) */
    var b1y = Math.round(pty + ph * .32), b2y = Math.round(pty + ph * .62);
    fr(pl + 4, b1y, pw - 10, 2, '#d8352c');
    px(pl + 3, b1y + 1, '#b02a22');
    fr(pl + 4, b2y, pw - 9, 2, '#2f5f9e');
    px(pl + 3, b2y + 1, '#26477a');
    for (var di = 0; di < 4; di++) px(pl + 5 + di * 4, pty + 2, di % 2 ? '#2f5f9e' : '#d8352c');
    /* dürümün kağıda düşürdüğü gölge (içeride hissi) */
    ctx.globalAlpha = alpha * .35;
    for (var sy2 = 2; sy2 < ph - 2; sy2++) {
      var sr = pl + pw - 5 + Math.round((sy2 / (ph - 1)) * 6);
      px(sr - 2, pty + sy2, '#8a8474');
    }
    ctx.globalAlpha = 1;
  }
  if (wrap.hot && chance(.04)) smoke(cx + rnd(-10, 10), cy - 7, 1, 'rgba(255,250,240,.4)');
  if (sc !== 1) ctx.restore();
  /* sos rozeti: hangi dürüm soslu, bakınca anlaşılsın */
  if (wrap.sauce) sauceBadge(cx + 13, cy - 6, wrap.sauce);
}
/* ---------- patates kutusu ---------- */
/* Patates kutusu. Blender: blender/models/sos.py -> sahne_kutu.
   'burnt' hali YOK: fritoz durum makinesi idle -> fry -> done ve
   yanma sayaci (yanar/yanSure/burnt) yalniz IZGARADAKI durumlere ait.
   Bu dal hic calismiyordu, kaldirildi. */
function drawFriesCup(cx, cy, q, t) {
  var bos = q === 'bos';
  ctx.globalAlpha = .22; ell(cx, cy + 9, 8, 2, '#000'); ctx.globalAlpha = 1;
  /* --- patatesler: DIK duran cubuklar, arka sira once ---
     Eskiden 9 tane duz 2x8 sari dikdortgendi ve tek bir sari
     blok gibi gorunuyordu. Simdi her cubuk kendi tonunda,
     boyu ve egimi farkli, kutudan disari tasiyor. */
  var koyuUc = '#8a5a12';
  var govdeler = ['#f0c24a', '#e0a828', '#f8d874'];
  for (var sira = 0; sira < (bos ? 0 : 2); sira++) {
    var adet = sira === 0 ? 6 : 5;
    for (var i = 0; i < adet; i++) {
      var k = sira * 7 + i;
      var boy = 7 + Math.round(hash1(k * 4.3) * 5);           /* 7..12 */
      var egim = Math.round((hash1(k * 2.9) - .5) * 3);       /* -1..1 */
      var fx = cx - 6 + i * (sira === 0 ? 2.4 : 2.8) + (sira ? 1 : 0);
      var taban = cy + (sira === 0 ? 1 : 3);
      var tepe = taban - boy;
      var gc = govdeler[(k + sira) % govdeler.length];
      if (sira === 0) { ctx.globalAlpha = .78; }
      for (var q = 0; q < boy; q++) {
        var u = q / Math.max(1, boy - 1);
        var xx = Math.round(fx + egim * u);
        var yy = taban - q;
        px(xx, yy, q === boy - 1 ? koyuUc : gc);
        px(xx + 1, yy, q === boy - 1 ? koyuUc : shadeCol(gc, .82));
      }
      /* uc parlakligi */
      px(Math.round(fx + egim), tepe + 1, '#fff0c0');
      ctx.globalAlpha = 1;
    }
  }
  /* --- KUTU: belirgin yamuk govde ---
     Eskiden ust 17 / alt 10 idi ve 12 satira yayiliyordu; ekranda
     kucuk kirmizi bir leke gibi duruyordu. Yamuk artik daha keskin
     (21 -> 11), govde bir satir daha uzun ve kenar katlari var. */
  var ustG = bos ? 19 : 21, altG = 11, gy = cy - 3, gh = 14;
  for (var r2 = 0; r2 < gh; r2++) {
    var u2 = r2 / (gh - 1);
    var gen = Math.round(ustG + (altG - ustG) * u2);
    var x0 = Math.round(cx - gen / 2), yy = gy + r2;
    fr(x0, yy, gen, 1, '#7d1610');                    /* dis kenar */
    fr(x0 + 1, yy, gen - 2, 1, u2 < .14 ? '#e8483a' : '#c22a20');
    px(x0 + 1, yy, '#ff7f6c');                        /* sol isik */
    px(x0 + 2, yy, '#e8483a');
    px(x0 + gen - 2, yy, '#5e120d');                  /* sag golge */
  }
  /* agiz: patateslerin ciktigi karanlik ic */
  var agz = Math.round(ustG - 3);
  fr(cx - agz / 2, gy, agz, 2, '#5e120d');
  hl(cx - agz / 2, gy, agz, bos ? '#7d1610' : '#8e1c14');
  hl(cx - ustG / 2 + 1, gy, ustG - 2, '#ff7f6c');     /* agiz dudagi */
  /* on kapak: kutunun on yuzune katlanan sari bant, yamuga uyar */
  var kapY = gy + 4, kapH = 6;
  for (var r3 = 0; r3 < kapH; r3++) {
    var u3 = (r3 + 4) / (gh - 1);
    var g3 = Math.round(ustG + (altG - ustG) * u3) - 4;
    var xk = Math.round(cx - g3 / 2), yk = kapY + r3;
    fr(xk, yk, g3, 1, r3 === 0 ? '#ffe98e'
       : (r3 < 3 ? '#f7d34a' : (r3 < 5 ? '#e0be32' : '#c9a41c')));
    px(xk, yk, '#c9a41c'); px(xk + g3 - 1, yk, '#a88a14');   /* katlama */
  }
  ctx.globalAlpha = .35;
  hl(Math.round(cx - (ustG - 6) / 2), kapY + kapH, ustG - 6, '#5e120d');
  ctx.globalAlpha = 1;
  /* yan kat cizgileri: kutunun katlandigi yerler */
  ctx.globalAlpha = .30;
  vl(Math.round(cx - ustG / 2) + 3, gy + 2, gh - 3, '#5e120d');
  vl(Math.round(cx + ustG / 2) - 4, gy + 2, gh - 3, '#5e120d');
  ctx.globalAlpha = 1;
  /* alt kenar */
  ctx.globalAlpha = .30;
  hl(Math.round(cx - altG / 2) + 1, gy + gh - 1, altG - 2, '#000');
  ctx.globalAlpha = 1;
  if (bos) {
    /* bos kutu: agzi ezik ve ici gorunuyor */
    fr(cx - agz / 2 + 1, gy + 1, agz - 2, 3, '#6b1710');
    px(cx - agz / 2 + 2, gy, '#c22a20'); px(cx + agz / 2 - 3, gy, '#c22a20');
  }
}

/* ---------- tatlı porsiyonu ---------- */
/* Tatli tabagi: uc baklava dilimi + serbet. Tezgahtaki ve siparis
   balonundaki tatliyla ayni bicim - uc yerde uc ayri tatli
   gorunmesin. */
function drawSweetPlate(cx, cy, t) {
  ctx.globalAlpha = .22; ell(cx, cy + 6, 12, 3, '#000'); ctx.globalAlpha = 1;
  ell(cx, cy + 4, 13, 4, '#c9cfd6');
  ell(cx, cy + 3, 13, 4, '#eef2f5');
  ell(cx, cy + 2, 10, 3, '#d7dde3');
  ell(cx, cy + 2, 9, 2, '#c98a2a');                /* şerbet */
  for (var i = 0; i < 3; i++) {
    var rx = cx - 7 + i * 7, ry = cy - 5 - (i % 2) * 2;
    drawBaklava(rx, ry);
  }
}

/* ---------- içecek ---------- */
function drawCup(cx, cy, kind, fill, t) {
  var col0, col1;
  if (kind === 'cola') { col0 = '#8a3a20'; col1 = '#4a1c10'; }
  else if (kind === 'orange' || kind === 'fanta') { col0 = P.or0; col1 = P.or1; }
  else { col0 = '#ffffff'; col1 = '#e4e2d8'; }
  ctx.globalAlpha = .22; ell(cx, cy + 10, 6, 2, '#000'); ctx.globalAlpha = 1;
  /* bardak gövdesi (hafif konik) */
  for (var y = 0; y < 16; y++) {
    var w = 5 + Math.round(y * .12);
    ctx.globalAlpha = .30;
    fr(cx - w, cy - 6 + y, w * 2, 1, '#dfeaf0');
    ctx.globalAlpha = 1;
  }
  /* sıvı */
  var lh = Math.round(14 * clamp(fill, 0, 1));
  for (var y2 = 0; y2 < lh; y2++) {
    var yy = cy + 8 - y2;
    var w2 = 5 + Math.round((15 - y2) * .12);
    fr(cx - w2 + 1, yy, w2 * 2 - 2, 1, y2 === lh - 1 ? col0 : col1);
  }
  if (lh > 0) { hl(cx - 4, cy + 8 - lh + 1, 8, col0); }
  /* köpük / buz */
  if (kind === 'cola' && lh > 3) {
    for (var b = 0; b < 4; b++) px(cx - 3 + b * 2, cy + 6 - (hash1(b * 3.1 + t | 0) * lh | 0), '#a9713f');
  }
  /* cam kenarı */
  for (var y3 = 0; y3 < 16; y3++) {
    var w3 = 5 + Math.round(y3 * .12);
    px(cx - w3, cy - 6 + y3, 'rgba(255,255,255,.75)');
    px(cx + w3 - 1, cy - 6 + y3, 'rgba(200,220,230,.85)');
  }
  hl(cx - 5, cy - 6, 11, '#ffffff');
  ell(cx, cy + 9, 6, 2, 'rgba(220,235,242,.8)');
  /* pipet */
  {
    ln(cx + 2, cy - 10, cx + 4, cy - 3, kind === 'cola' ? '#e2382a' : '#3f79c0');
    ln(cx + 3, cy - 10, cx + 5, cy - 3, '#ffffff');
  }
}

/* ---------- genel ürün çizimi ---------- */
function drawItem(it, x, y, t) {
  if (!it) return;
  if (it.kind === 'wrap') {
    if (it.state === 'open') drawWrapOpen(x, y, it, t);
    else drawWrapRolled(x, y, it, t);
  } else if (it.kind === 'fries') drawFriesCup(x, y, it.q, t);
  else if (it.kind === 'fbox') drawFriesCup(x, y, 'ok', t);
  else if (it.kind === 'sweet') drawSweetPlate(x, y, t);
  else if (it.kind === 'drink') drawCup(x, y, it.type, it.fill === undefined ? 1 : it.fill, t);
  else if (it.kind === 'plate') drawPlate(x, y, it, t, .85);
  else if (it.kind === 'pide') drawPideBoard(x, y, it, t, .85);
}

/* ---------- ikonlar (sipariş balonu / menü) ---------- */
function icon(id, x, y, t) {
  /* 14x14 alanın merkezinde çizer */
  switch (id) {
    case 'wrap':
      /* çapraz dürüm */
      rrect(x - 7, y - 3, 14, 8, 3, '#a87a41');
      rrect(x - 7, y - 4, 14, 8, 3, '#f0d5a8');
      rrect(x - 5, y - 3, 10, 3, 2, '#f8e6c4');
      fr(x - 6, y - 4, 5, 8, '#f4f2ea');
      fr(x - 5, y - 2, 3, 1, '#d8352c'); fr(x - 5, y, 3, 1, '#2f5f9e');
      px(x + 5, y - 2, P.m2); px(x + 4, y + 1, P.m3); px(x + 3, y - 2, P.g1);
      ln(x - 1, y - 4, x + 1, y + 4, '#c9a06a');
      ln(x + 2, y - 4, x + 4, y + 4, '#c9a06a');
      break;
    case 'pide':
      /* açık ekmek arası */
      ell(x, y + 2, 8, 4, '#a87a41');
      ell(x, y + 1, 8, 4, '#d9a765');
      ell(x, y, 7, 3, '#eec78c');
      fr(x - 6, y - 2, 12, 3, '#8a5f31');
      for (var pi = 0; pi < 4; pi++) px(x - 5 + pi * 3, y - 2, meatCol(.85, 1));
      for (var pj = 0; pj < 3; pj++) px(x - 4 + pj * 4, y - 1, P.g1);
      hl(x - 5, y - 3, 10, '#f4dcae');
      break;
    case 'cola':
      fr(x - 4, y - 7, 9, 14, 'rgba(235,244,250,.55)');
      fr(x - 3, y - 3, 7, 9, P.cola);
      fr(x - 3, y - 3, 7, 2, P.cola2);
      px(x - 3, y - 1, '#7a4620'); px(x + 2, y + 2, '#7a4620');
      rc(x - 4, y - 7, 9, 14, '#ffffff');
      vl(x - 3, y - 6, 12, 'rgba(255,255,255,.7)');
      ln(x + 2, y - 10, x + 3, y - 5, '#e2382a'); ln(x + 3, y - 10, x + 4, y - 5, '#ffffff');
      break;
    case 'fanta':
    case 'orange':
      fr(x - 4, y - 7, 9, 14, 'rgba(235,244,250,.55)');
      fr(x - 3, y - 4, 7, 10, P.or1);
      fr(x - 3, y - 4, 7, 3, P.or0);
      px(x - 2, y - 3, '#ffd98a');
      rc(x - 4, y - 7, 9, 14, '#ffffff');
      vl(x - 3, y - 6, 12, 'rgba(255,255,255,.7)');
      ln(x + 2, y - 10, x + 3, y - 5, '#3f79c0'); ln(x + 3, y - 10, x + 4, y - 5, '#ffffff');
      break;
    case 'ayran':
      /* Ayran bardagi - drawCup('ayran') ile AYNI nesne olmali.
         Eskiden burada mavi KAPAKLI, uzerinde 'A' yazan kapali bir
         bardak vardi; tezgahta doldurulan ise seffaf bardak + beyaz
         ayran + mavi pipetti. Musteri bir sey isteyip baskasi
         geliyormus gibi duruyordu. */
      ctx.globalAlpha = .30;
      for (var ay = 0; ay < 14; ay++) {
        var aw = 4 + Math.round(ay * .12);
        fr(x - aw, y - 6 + ay, aw * 2, 1, '#dfeaf0');
      }
      ctx.globalAlpha = 1;
      for (var ay2 = 0; ay2 < 12; ay2++) {           /* beyaz ayran */
        var ayy = y + 7 - ay2, aw2 = 4 + Math.round((13 - ay2) * .12);
        fr(x - aw2 + 1, ayy, aw2 * 2 - 2, 1, ay2 === 11 ? '#ffffff' : '#e4e2d8');
      }
      hl(x - 3, y - 4, 7, '#ffffff');                /* kopuk */
      for (var ay3 = 0; ay3 < 14; ay3++) {           /* cam kenari */
        var aw3 = 4 + Math.round(ay3 * .12);
        px(x - aw3, y - 6 + ay3, 'rgba(255,255,255,.75)');
        px(x + aw3 - 1, y - 6 + ay3, 'rgba(200,220,230,.85)');
      }
      hl(x - 4, y - 6, 9, '#ffffff');
      ln(x + 1, y - 9, x + 3, y - 3, '#3f79c0');     /* mavi pipet */
      ln(x + 2, y - 9, x + 4, y - 3, '#ffffff');
      break;
    case 'fbox':
    case 'fries':
      for (var fi = 0; fi < 5; fi++) {
        var fxx = x - 5 + fi * 2.4, fyy = y - 7 - (fi % 2) * 2;
        fr(fxx, fyy, 2, 7, P.p2); fr(fxx, fyy, 2, 6, P.p1); px(fxx, fyy, P.p0);
      }
      /* Kutu: tezgahtakiyle AYNI siluet (ustu genis, alti dar). Siparis
         balonundaki ikon eski duz dikdortgen kutuda kalmisti. */
      for (var kr = 0; kr < 10; kr++) {
        var ku = kr / 9, kg = Math.round(15 + (8 - 15) * ku);
        var kx2 = Math.round(x - kg / 2), ky2 = y - 1 + kr;
        fr(kx2, ky2, kg, 1, '#7d1610');
        fr(kx2 + 1, ky2, kg - 2, 1, ku < .16 ? '#e8483a' : '#c22a20');
        px(kx2 + 1, ky2, '#ff7f6c');
        px(kx2 + kg - 2, ky2, '#5e120d');
      }
      fr(x - 6, y - 1, 13, 2, '#5e120d');            /* agiz */
      hl(x - 6, y - 1, 13, '#ff7f6c');
      for (var kb = 0; kb < 4; kb++) {               /* on kapak bandi */
        var kbg = Math.round(15 + (8 - 15) * ((kb + 3) / 9)) - 3;
        fr(Math.round(x - kbg / 2), y + 2 + kb, kbg, 1,
           kb === 0 ? '#ffe98e' : (kb < 2 ? '#f7d34a' : '#e0be32'));
      }
      break;
    case 'sweet':
      /* Siparis balonundaki tatli halka tatlisiydi, tezgahtaki ise
         baklava - musteri istedigi seyi tezgahta bulamiyordu. */
      ell(x, y + 4, 9, 3, '#c9cfd6'); ell(x, y + 3, 9, 3, '#eef2f5');
      for (var swi = 0; swi < 2; swi++) {
        var sx2 = x - 4 + swi * 8;
        fr(sx2 - 3, y + 1, 7, 2, '#8a5a1a');            /* yan yuz: katlar */
        hl(sx2 - 3, y + 1, 7, '#a8762a');
        fr(sx2 - 1, y - 3, 3, 1, '#e8bd62');            /* ust: dortgen */
        fr(sx2 - 3, y - 2, 7, 1, '#e8bd62');
        fr(sx2 - 2, y - 1, 5, 1, '#cf9c47');
        fr(sx2 - 1, y, 3, 1, '#cf9c47');
        px(sx2, y - 2, '#6b9440');                      /* fistik */
        px(sx2 - 1, y - 3, '#ffdf9a');
      }
      break;
    case 'pickle':
      ell(x - 2, y + 1, 3, 2, P.g3); ell(x - 2, y, 3, 2, P.g2);
      ell(x + 3, y + 2, 3, 2, P.g3); ell(x + 3, y + 1, 3, 2, P.g2);
      px(x - 3, y - 1, P.g0); px(x + 2, y, P.g0);
      break;
    case 'iskender':
      ell(x, y + 4, 8, 3, '#b6bec6');
      ell(x, y + 3, 8, 3, '#eef2f5');
      ell(x, y + 3, 6, 2, '#dbe2e8');
      for (var ii = 0; ii < 4; ii++) { var ix = x - 5 + ii * 3; fr(ix, y, 3, 3, '#8a5f31'); fr(ix, y, 3, 2, '#d9a765'); }
      fr(x - 5, y - 3, 4, 3, '#7a4318'); fr(x - 5, y - 3, 4, 2, '#c98436');
      fr(x + 1, y - 3, 4, 3, '#7a4318'); fr(x + 1, y - 3, 4, 2, '#c98436');
      ln(x - 5, y - 1, x + 5, y - 1, '#e2621c');
      ell(x + 5, y + 2, 3, 2, P.s0); px(x + 4, y + 1, '#ffffff');
      break;
    case 'garlic':
      ell(x, y + 3, 5, 4, '#cfc7b2');
      ell(x, y + 2, 5, 4, '#f6f2e6');
      ell(x - 2, y + 2, 2, 3, '#ffffff');
      ln(x, y - 3, x, y - 1, '#b0a88e');
      px(x - 1, y - 3, '#8a8470');
      break;
    case 'sauce':
      ell(x, y + 2, 6, 3, P.s2); ell(x, y + 1, 6, 3, P.s0);
      px(x - 2, y, '#ffffff'); px(x + 2, y + 1, '#ffffff');
      break;
    case 'hot':
      /* biber */
      ell(x, y + 1, 5, 3, '#a81f18'); ell(x, y, 5, 3, '#e2352a');
      px(x - 3, y - 1, '#ff6a55');
      ln(x + 4, y - 3, x + 5, y - 5, P.g2);
      break;
    case 'meat':
      fr(x - 5, y - 2, 5, 4, meatCol(.8, .8)); fr(x - 5, y - 2, 5, 3, meatCol(.8, 1.05));
      fr(x + 1, y - 1, 5, 4, meatCol(.9, .8)); fr(x + 1, y - 1, 5, 3, meatCol(.9, 1.05));
      break;
    case 'falafel':
      ell(x - 3, y + 1, 4, 3, P.m4); ell(x - 3, y, 4, 3, P.m3);
      ell(x + 3, y + 2, 4, 3, P.m4); ell(x + 3, y + 1, 4, 3, P.m3);
      break;
    case 'plate':
      ell(x, y + 4, 9, 3, '#a9b0b8');
      ell(x, y + 3, 9, 3, '#eef2f5');
      ell(x, y + 2, 6, 2, '#d7dde3');
      /* köfteler */
      ell(x - 4, y, 4, 3, P.m4); ell(x - 4, y - 1, 4, 3, P.m3); px(x - 5, y - 2, P.m1);
      ell(x + 3, y + 1, 4, 3, P.m4); ell(x + 3, y, 4, 3, P.m3); px(x + 2, y - 1, P.m1);
      /* garnitür */
      px(x - 1, y - 3, P.g1); px(x + 1, y - 3, P.g2);
      fr(x + 5, y - 4, 1, 4, P.p1); fr(x + 7, y - 3, 1, 3, P.p1);
      break;
    case 'coin':
      ell(x, y, 5, 5, P.au3); ell(x, y - 1, 5, 5, P.au1);
      ell(x, y - 1, 3, 3, P.au0); px(x - 2, y - 3, '#ffffff');
      break;
    case 'star':
      drawStar(x, y, 5, P.au1, P.au3);
      break;
    case 'heart':
      drawHeart(x, y, 1, '#e2483a');
      break;
  }
}
function drawStar(cx, cy, r, col, col2) {
  var pat = [
    '.....#.....',
    '....###....',
    '....###....',
    '###########',
    '.#########.',
    '..#######..',
    '..#######..',
    '.###...###.',
    '##.......##'
  ];
  var s = Math.max(1, Math.round(r / 5));
  var ox = cx - Math.round(5.5 * s), oy = cy - Math.round(4 * s);
  for (var y = 0; y < pat.length; y++) for (var x = 0; x < 11; x++) {
    if (pat[y][x] !== '#') continue;
    var c = (y < 2 || (y < 5 && x > 2 && x < 8)) ? col : (y > 6 ? (col2 || col) : col);
    fr(ox + x * s, oy + y * s, s, s, c);
  }
  /* parlama */
  fr(ox + 4 * s, oy + 1 * s, s, s, '#ffffff');
  fr(ox + 3 * s, oy + 4 * s, s * 2, s, 'rgba(255,255,255,.55)');
}
function drawHeart(cx, cy, sc, col) {
  var pat = [
    '.##.##.',
    '#######',
    '#######',
    '.#####.',
    '..###..',
    '...#...'
  ];
  for (var y = 0; y < pat.length; y++) for (var x = 0; x < pat[y].length; x++)
    if (pat[y][x] === '#') fr(cx - 3 * sc + x * sc, cy - 3 * sc + y * sc, sc, sc, col);
  px(cx - 2, cy - 2, 'rgba(255,255,255,.7)');
}
function drawX(cx, cy, col) {
  for (var i = -2; i <= 2; i++) { px(cx + i, cy + i, col); px(cx + i, cy - i, col); }
  px(cx + 3, cy + 3, col); px(cx - 3, cy - 3, col); px(cx + 3, cy - 3, col); px(cx - 3, cy + 3, col);
}
function drawCheck(cx, cy, col) {
  px(cx - 3, cy, col); px(cx - 2, cy + 1, col); px(cx - 1, cy + 2, col);
  px(cx, cy + 1, col); px(cx + 1, cy, col); px(cx + 2, cy - 1, col); px(cx + 3, cy - 2, col);
  px(cx - 3, cy + 1, col); px(cx, cy + 2, col); px(cx + 3, cy - 1, col);
}

/* ---------- para ---------- */
function drawCoin(x, y, v, t, ph) {
  var sp = Math.abs(Math.sin(t * 3 + (ph || 0)));
  var rx = Math.max(1, Math.round(5 * sp)) ;
  var big = v >= 25;
  ctx.globalAlpha = .25; ell(x, y + 4, 5, 2, '#000'); ctx.globalAlpha = 1;
  ell(x, y, rx, 5, big ? P.au3 : '#a9a9a9');
  ell(x, y - 1, rx, 5, big ? P.au1 : '#d8d8d8');
  if (rx > 2) {
    ell(x, y - 1, rx - 2, 3, big ? P.au0 : '#f2f2f2');
    px(x - 1, y - 3, '#ffffff');
    txt(big ? '5' : '1', x, y - 4, big ? P.au3 : '#8a8a8a', { align: 'c' });
  }
}

/* ---------- imleç ---------- */
function drawCursor(x, y, mode, held, t) {
  x = Math.round(x); y = Math.round(y);
  if (held) {
    ctx.globalAlpha = .95;
    drawItem(held, x + 2, y + 16, t);
    ctx.globalAlpha = 1;
    /* Elde tasinan sarilmis dürüm de kimligini gostersin: musteriye
       vermeden once dogru olani aldigini gorebilesin. */
    if (held.kind === 'wrap' && held.state !== 'open' && typeof wrapEtiket === 'function') {
      wrapEtiket(x + 2, y + 28, held, false);
    }
  }
  if (mode === 'knife') {
    /* bıçak imleci */
    fr(x - 1, y - 2, 3, 14, '#2b2018');
    fr(x, y - 1, 2, 12, '#e8eef4');
    fr(x, y - 1, 1, 12, '#ffffff');
    fr(x - 2, y + 11, 5, 5, P.wd2);
    hl(x - 2, y + 11, 5, P.wd1);
    return;
  }
  var pat = mode === 'grab' ? [
    '..##....',
    '.#..#...',
    '.#..#.##',
    '.#..#.##',
    '.#....##',
    '#......#',
    '#......#',
    '.#....#.',
    '..####..'
  ] : [
    '.#......',
    '.##.....',
    '.#.#....',
    '.#..#...',
    '.#...#..',
    '.#....#.',
    '.#..###.',
    '.#.##...',
    '.##.....',
    '.#......'
  ];
  for (var j = 0; j < pat.length; j++) for (var i = 0; i < pat[j].length; i++) {
    if (pat[j][i] === '#') {
      fr(x + i, y + j, 1, 1, P.ink);
    }
  }
  /* iç dolgu */
  if (mode !== 'grab') {
    for (var j2 = 1; j2 < 9; j2++) {
      for (var i2 = 2; i2 < 7; i2++) {
        if (pat[j2] && pat[j2][i2] === '.' && pat[j2].slice(0, i2).indexOf('#') >= 0 && pat[j2].slice(i2).indexOf('#') >= 0)
          fr(x + i2, y + j2, 1, 1, '#ffffff');
      }
    }
  } else {
    fr(x + 2, y + 1, 2, 4, '#ffffff');
    fr(x + 1, y + 5, 6, 3, '#ffffff');
    fr(x + 6, y + 2, 2, 3, '#ffffff');
  }
}
