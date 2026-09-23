/* ============================================================
   DÖNER EFSANESİ — art.js
   Sahne yerleşimi, arka plan (taş kemer + fayans), tezgâh,
   istasyonlar: şiş, tepsiler, fritöz, içecek, ızgara
   ============================================================ */
'use strict';

var LAY = {
  ledgeY: 148, ledgeH: 11,
  /* vitrin: dis cerceve ve cam (sokak burada gorunur) */
  win: { x: 150, y: 30, w: 272, h: 100 },
  glass: { x: 154, y: 34, w: 264, h: 92 },
  surfY: 159, lipY: 247, floorY: 258,
  rowA: 168, rowB: 200,
  spit: { cx: 80, top: 58, bot: 168 },
  chef: { x: 4, y: 108 },
  custSlots: [
    { x: 142, y: 152 }, { x: 208, y: 152 }, { x: 274, y: 152 }, { x: 340, y: 152 }, { x: 404, y: 152 }
  ]
};

/* istasyon kutuları (tıklama alanları da bunlar) */
var ST = {
  spit:   { x: 58, y: 50, w: 46, h: 126 },
  /* et tepsisi kucultuldu, pay bolmelere verildi */
  meat:   { x: 58, y: 168, w: 46, h: 28 },
  /* --- GARNITUR TEZGAHI: uc bolme, tek vitrin govdesi ---
     Uc ayri vitrin 108..216 arasi 108px yiyordu; bitisik bolmeler
     78px. Kazanilan 30px komsulara dagitildi. */
  pickle: { x: 108, y: 168, w: 34, h: 28 },
  yogurt: { x: 142, y: 168, w: 34, h: 28 },
  friesT: { x: 176, y: 168, w: 34, h: 28 },
  garnish:{ x: 214, y: 168, w: 42, h: 28 },
  /* --- BIRLESIK ICECEK MAKINESI ---
     drinkM tum uniteyi kapsar; ayran onun SAG BOLMESI (yalniz cizim
     ve kilit etiketi icin ayri dikdortgen). Tiklama musluk bolgesine
     gore ayrilir, ayri istasyon yok. */
  drinkM: { x: 260, y: 146, w: 62, h: 50 },
  ayran:  { x: 294, y: 150, w: 28, h: 46 },
  fryer:  { x: 326, y: 152, w: 58, h: 44 },
  /* sepet saga cekildi ve komsulariyla HIZALANDI: ust/sol bosluk
     kalmasin diye tezgah yuzeyine kadar uzatildi. */
  potato: { x: 386, y: 160, w: 44, h: 38 },
  /* STOK ve COP artik tezgahta degil, SAG TAS DUVARDA gomulu.
     Tezgahtan iki istasyonluk yer acildi. */
  /* SAG DUVAR: ustten alta TATLI / STOK / COP. Ucu de tezgahtan
     cikarildi, alt sirada yer acildi. */
  crate:  { x: 438, y: 190, w: 34, h: 34 },
  /* --- ALT SIRA --- tatli duvara tasininca acilan yer, elle en cok
     calisilan istasyonlara dagitildi: tahta, izgara ve kesme buyudu. */
  bread:  { x: 44, y: 200, w: 42, h: 46 },
  board:  { x: 90, y: 199, w: 94, h: 47 },
  paper:  { x: 188, y: 200, w: 24, h: 46 },
  grill:  { x: 216, y: 200, w: 68, h: 46 },
  cut:    { x: 288, y: 200, w: 48, h: 46 },
  sauce:  { x: 340, y: 198, w: 48, h: 48 },
  fbox:   { x: 392, y: 200, w: 38, h: 46 },
  sweet:  { x: 438, y: 150, w: 34, h: 34 },
  trash:  { x: 440, y: 228, w: 30, h: 28 },
  uncle:  { x: 2, y: 96, w: 46, h: 162 },
  phone:  { x: 6, y: 44, w: 26, h: 30 },
  shutter: { x: 150, y: 30, w: 272, h: 100 }
};


/* ============================================================
   SOKAK VİTRİNİ
   ============================================================ */
function mixHex(a, b, k) {
  var pa = parseInt(a.slice(1), 16), pb = parseInt(b.slice(1), 16);
  var r0 = (pa >> 16) & 255, g0 = (pa >> 8) & 255, b0 = pa & 255;
  var r1 = (pb >> 16) & 255, g1 = (pb >> 8) & 255, b1 = pb & 255;
  return 'rgb(' + Math.round(lerp(r0, r1, k)) + ',' + Math.round(lerp(g0, g1, k)) + ',' + Math.round(lerp(b0, b1, k)) + ')';
}

/* sokağın yatay şeritleri */
function stM() {
  var G0 = LAY.glass;
  return {
    gx: G0.x, gy: G0.y, gw: G0.w, gh: G0.h,
    base: G0.y + 50,        /* karşı binaların zemini */
    walkY: G0.y + 57,       /* karşı kaldırımda yaya taban çizgisi */
    roadY: G0.y + 58, roadH: 26,
    farY: G0.y + 70,        /* uzak şerit taban çizgisi */
    nearY: G0.y + 82,       /* yakın şerit taban çizgisi */
    curb2: G0.y + 84        /* bizim taraf kaldırım */
  };
}

/* ---------------- karşı binalar ---------------- */
var BLD = [
  { wall: '#c9a883', trim: '#8a6a48', awn: '#c0281c', sign: '#2f4f6a' },
  { wall: '#a7bfcb', trim: '#6d8492', awn: '#2f6a8a', sign: '#7a3a2a' },
  { wall: '#c8a0a6', trim: '#8e6a70', awn: '#3f8a4a', sign: '#4a3a6a' },
  { wall: '#bfb491', trim: '#867c60', awn: '#b0862a', sign: '#2f5f3a' },
  { wall: '#9fb0a4', trim: '#6b7a70', awn: '#8a3a6a', sign: '#5a4a2a' }
];
function bldWindow(x, y, w, h, lit, trim) {
  fr(x, y, w, h, trim);                                   /* çerçeve */
  fr(x + 1, y + 1, w - 2, h - 2, lit ? '#3a3226' : '#33454f');
  fr(x + 1, y + 1, w - 2, h - 3, lit ? '#ffdf9a' : '#7ea3b5');
  if (lit) { fr(x + 1, y + 1, w - 2, 1, '#fff2c8'); px(x + 2, y + h - 3, '#e8b45a'); }
  else { hl(x + 1, y + 1, w - 2, '#a8c6d4'); px(x + w - 3, y + 2, '#dff0fa'); }
  vl(x + Math.floor(w / 2), y + 1, h - 2, trim);          /* dikme */
  hl(x + 1, y + Math.floor(h / 2), w - 2, trim);          /* kayıt */
  hl(x - 1, y + h - 1, w + 2, '#e8e2d4');                 /* denizlik */
  hl(x - 1, y + h, w + 2, shadeCol(trim, .7));
}
/* Rejim sehrinde renk yok: ayni bina cizimi gri palete oturur. */
var BLD_BETON = [
  { wall: '#7a7e84', trim: '#565a60', awn: '#6a4a44', sign: '#4a4e54' },
  { wall: '#6e7278', trim: '#4a4e54', awn: '#5a4440', sign: '#3e4248' },
  { wall: '#868a90', trim: '#5e6268', awn: '#6a5450', sign: '#52565c' },
  { wall: '#666a70', trim: '#44484e', awn: '#584442', sign: '#3a3e44' },
  { wall: '#7e8288', trim: '#5a5e64', awn: '#644c48', sign: '#464a50' }
];
function drawBuilding(bx, by, bw, bh, i, gy, tarz, rakip) {
  tarz = tarz || 'dukkan';
  var B = (tarz === 'beton' ? BLD_BETON : BLD)[i % BLD.length];
  var top = by - bh;
  /* gövde */
  fr(bx, top, bw, bh, shadeCol(B.wall, .78));
  fr(bx, top, bw - 1, bh, B.wall);
  /* sıva dokusu */
  for (var d = 0; d < 26; d++) {
    ctx.globalAlpha = .07;
    hl(bx + 2 + hash1(i * 7 + d * 3.1) * (bw - 8), top + 3 + hash1(i * 3 + d * 5.7) * (bh - 8), 3 + hash1(d) * 6, d % 2 ? '#ffffff' : '#000000');
    ctx.globalAlpha = 1;
  }
  /* --- TARZA OZEL CEPHE --- */
  if (tarz === 'gokdelen') {
    /* dar ve yuksek: dikey seritler + yangin merdiveni */
    for (var gv = 3; gv < bw - 2; gv += 5) {
      ctx.globalAlpha = .16; vl(bx + gv, top + 2, bh - 4, '#ffffff'); ctx.globalAlpha = 1;
    }
    if (hash1(i * 6.7) > .45) {
      var ym = bx + 2 + Math.floor(hash1(i * 2.1) * (bw - 8));
      for (var yk = top + 6; yk < by - 4; yk += 7) {
        ctx.globalAlpha = .55; hl(ym, yk, 7, '#3a3f46'); ctx.globalAlpha = 1;
        px(ym, yk + 1, '#4a5058'); px(ym + 6, yk + 1, '#4a5058');
      }
    }
  } else if (tarz === 'cam') {
    /* cam kule: mavi yansimali yatay bantlar */
    for (var cb = top + 2; cb < by - 2; cb += 3) {
      ctx.globalAlpha = .26; hl(bx + 1, cb, bw - 3, '#bfe4f2'); ctx.globalAlpha = 1;
      ctx.globalAlpha = .14; hl(bx + 1, cb + 1, bw - 3, '#2f6a8a'); ctx.globalAlpha = 1;
    }
    ctx.globalAlpha = .18;
    for (var cd = 0; cd < bh; cd += 2) px(bx + 2 + ((cd * 3) % Math.max(1, bw - 5)), top + cd, '#ffffff');
    ctx.globalAlpha = 1;
  } else if (tarz === 'mansart') {
    /* mansart cati: ustte egik koyu bant + tavan pencereleri */
    for (var mk = 0; mk < 5; mk++)
      fr(bx + mk, top - 4 - mk, bw - mk * 2, 1, shadeCol(B.trim, .62));
    if (bw > 24) {
      fr(bx + (bw >> 1) - 3, top - 7, 6, 4, shadeCol(B.trim, .5));
      fr(bx + (bw >> 1) - 2, top - 6, 4, 3, '#8fb4c8');
    }
  } else if (tarz === 'beton') {
    /* --- BRUTALIST BLOK: cıplak beton, kati izgara, su lekesi ---
       Sehir "soluk ve baskici" hissetmeli: renk yok, tekrar var. */
    ctx.globalAlpha = .55; fr(bx, top, bw - 1, bh, '#6e7278'); ctx.globalAlpha = 1;
    /* kalip izleri: yatay beton dokum bantlari */
    for (var bk = top + 4; bk < by - 2; bk += 7) {
      ctx.globalAlpha = .22; hl(bx + 1, bk, bw - 3, '#3e4248'); ctx.globalAlpha = 1;
      ctx.globalAlpha = .12; hl(bx + 1, bk + 1, bw - 3, '#c8ccd0'); ctx.globalAlpha = 1;
    }
    /* dikey derz */
    for (var bd = 6; bd < bw - 4; bd += 12) {
      ctx.globalAlpha = .16; vl(bx + bd, top + 2, bh - 4, '#2e3238'); ctx.globalAlpha = 1;
    }
    /* su lekeleri: kornisten asagi akan koyu izler */
    for (var sl = 0; sl < 3; sl++) {
      if (hash1(i * 9.1 + sl * 4.3) < .45) continue;
      var slx = bx + 3 + Math.floor(hash1(i * 2.7 + sl) * (bw - 8));
      var slh = 6 + Math.floor(hash1(i * 5.1 + sl) * 14);
      ctx.globalAlpha = .17; fr(slx, top + 1, 2, Math.min(slh, bh - 3), '#2a2e34'); ctx.globalAlpha = 1;
    }
    /* propaganda afisi: bazi binalarda tepeden sarkan kirmizi bez */
    if (hash1(i * 13.7) > .52 && bw >= 26) {
      var ax = bx + Math.floor((bw - 14) / 2);
      var ah = Math.min(bh - 6, 20 + Math.floor(hash1(i * 3.9) * 8));
      fr(ax, top + 2, 14, ah, '#6e1a12');
      fr(ax, top + 2, 13, ah - 1, '#9e2016');
      hl(ax, top + 2, 13, '#c0342a');
      /* alt kenar puskullu */
      for (var pk = 0; pk < 13; pk += 3) px(ax + pk, top + 2 + ah, '#6e1a12');
      /* afisteki yildiz */
      var sy0 = top + 6;
      px(ax + 6, sy0, '#e8dcb0');
      fr(ax + 4, sy0 + 1, 5, 1, '#e8dcb0');
      fr(ax + 5, sy0 + 2, 3, 1, '#e8dcb0');
      px(ax + 4, sy0 + 3, '#e8dcb0'); px(ax + 8, sy0 + 3, '#e8dcb0');
      /* altinda yazi taklidi satirlar */
      for (var ay0 = sy0 + 6; ay0 < top + ah - 2; ay0 += 3) {
        ctx.globalAlpha = .55; hl(ax + 3, ay0, 8, '#e8dcb0'); ctx.globalAlpha = 1;
      }
    }
  } else if (tarz === 'tabela') {
    /* tabela kalabaligi: dikey neon levhalar */
    for (var tb = 0; tb < 3; tb++) {
      if (hash1(i * 5.3 + tb * 2.7) < .42) continue;
      var tbx = bx + 3 + tb * Math.max(6, (bw - 8) / 3);
      var tby = top + 4 + Math.floor(hash1(i + tb) * 6);
      var tbh = 8 + Math.floor(hash1(i * 3.1 + tb) * 10);
      if (tby + tbh > by - 6) tbh = Math.max(6, by - 6 - tby);
      var tc = ['#e2483a', '#f0b03a', '#3fa8c0', '#8ac04a'][(i + tb) % 4];
      fr(tbx, tby, 5, tbh, shadeCol(tc, .55));
      fr(tbx, tby, 4, tbh - 1, tc);
      for (var tp = 2; tp < tbh - 1; tp += 3) px(tbx + 1, tby + tp, '#ffffff');
    }
  }
  /* saçak / korniş */
  fr(bx - 2, top - 4, bw + 4, 4, shadeCol(B.trim, .85));
  fr(bx - 2, top - 4, bw + 4, 3, B.trim);
  hl(bx - 2, top - 4, bw + 4, shadeCol(B.trim, 1.5));
  ctx.globalAlpha = .3; hl(bx - 1, top, bw + 2, '#000'); ctx.globalAlpha = 1;
  /* çatı bacası */
  if (hash1(i * 11.3) > .5) {
    var chx = bx + 6 + Math.floor(hash1(i * 2.2) * (bw - 16));
    fr(chx, top - 11, 6, 7, shadeCol(B.trim, .8));
    fr(chx, top - 11, 5, 7, B.trim);
    fr(chx - 1, top - 12, 8, 2, shadeCol(B.trim, 1.2));
  }
  /* çatı kalabalığı: su deposu, uydu, anten, çamaşır ipi */
  if (hash1(i * 4.7) > .45) {                       /* su deposu */
    var wtx = bx + bw - 16 - Math.floor(hash1(i * 3.3) * 8);
    fr(wtx, top - 9, 8, 5, '#7a6a58');
    fr(wtx, top - 9, 7, 4, '#9a8a72');
    hl(wtx, top - 9, 7, '#b8a88e');
    vl(wtx + 1, top - 4, 3, '#5a4a3a'); vl(wtx + 6, top - 4, 3, '#5a4a3a');
  }
  if (hash1(i * 8.9) > .55) {                       /* uydu anteni */
    var stx = bx + 8 + Math.floor(hash1(i * 6.7) * (bw - 20));
    ell(stx, top - 6, 3, 3, '#c9ccd0');
    ell(stx, top - 6, 2, 2, '#e6e9ec');
    vl(stx, top - 4, 4, '#8f979f');
    px(stx + 2, top - 7, '#5a636b');
  }
  if (hash1(i * 12.1) > .60) {                      /* anten çubugu */
    var atx = bx + 4 + Math.floor(hash1(i * 9.9) * (bw - 10));
    vl(atx, top - 12, 12, '#8f979f');
    hl(atx - 2, top - 10, 5, '#8f979f');
    hl(atx - 2, top - 7, 5, '#8f979f');
  }
  if (hash1(i * 15.7) > .66) {                      /* çamaşır ipi */
    var lx0 = bx + 5, lx1 = bx + bw - 6;
    ctx.globalAlpha = .5; hl(lx0, top - 3, lx1 - lx0, '#d8d0b8'); ctx.globalAlpha = 1;
    for (var cw2 = 0; cw2 < 4; cw2++) {
      var cx3 = lx0 + 4 + cw2 * Math.max(5, Math.floor((lx1 - lx0 - 8) / 3));
      if (cx3 > lx1 - 3) break;
      fr(cx3, top - 3, 3, 4, PED_SHIRT[(i * 3 + cw2) % PED_SHIRT.length]);
    }
  }
  /* üst kat pencereleri */
  var cols = Math.max(2, Math.floor((bw - 6) / 14));
  var step = (bw - 6) / cols;
  var floors = Math.floor((bh - 20) / 13);
  for (var f = 0; f < floors; f++) {
    var wy = top + 5 + f * 13;
    if (wy + 10 > by - 15) break;
    for (var c = 0; c < cols; c++) {
      var wx = bx + 3 + Math.round(c * step) + Math.round((step - 9) / 2);
      var lit = hash1(i * 13 + f * 5.3 + c * 2.7) > .52;
      bldWindow(wx, wy, 9, 10, lit, B.trim);
    }
    /* balkon */
    if (f === 0 && hash1(i * 6.1) > .55) {
      var byy = wy + 11;
      fr(bx + 3, byy, bw - 7, 2, shadeCol(B.trim, 1.1));
      for (var rr = bx + 4; rr < bx + bw - 5; rr += 3) vl(rr, byy - 4, 4, shadeCol(B.trim, .9));
      hl(bx + 3, byy - 4, bw - 7, shadeCol(B.trim, 1.3));
    }
  }
  /* yağmur borusu */
  if (hash1(i * 4.9) > .45) {
    vl(bx + bw - 3, top, bh, shadeCol(B.wall, .6));
    vl(bx + bw - 2, top, bh, shadeCol(B.wall, 1.15));
    for (var pb = top + 8; pb < by; pb += 14) fr(bx + bw - 4, pb, 3, 2, shadeCol(B.wall, .55));
  }
  /* klima */
  if (hash1(i * 8.7) > .6) {
    var ax = bx + 4, ay = top + 20;
    fr(ax, ay, 7, 5, '#8f979f');
    fr(ax, ay, 6, 4, '#c2c9d0');
    vl(ax + 2, ay + 1, 3, '#8f979f'); vl(ax + 4, ay + 1, 3, '#8f979f');
    ctx.globalAlpha = .3; fr(ax, ay + 5, 7, 1, '#000'); ctx.globalAlpha = 1;
  }

  /* ---- zemin kat ---- */
  var gyy = by - 15;
  if (tarz === 'gokdelen' || tarz === 'cam') {
    /* Gokdelen lobisi: tente/tabela yok, yuksek cam giris.
       Dukkan cephesi cizilirse bina 'kucuk dukkan' gibi okunuyordu. */
    fr(bx + 1, by - 15, bw - 2, 15, shadeCol(B.wall, .62));
    for (var lg = 2; lg < bw - 3; lg += 5) {
      fr(bx + lg, by - 13, 4, 12, '#2b3a44');
      fr(bx + lg, by - 13, 3, 11, '#4a7a92');
      ctx.globalAlpha = .35; hl(bx + lg, by - 13, 3, '#bfe4f2'); ctx.globalAlpha = 1;
    }
    /* giris kanopisi */
    fr(bx + (bw >> 1) - 5, by - 16, 11, 2, shadeCol(B.trim, .8));
    hl(bx + (bw >> 1) - 5, by - 16, 11, shadeCol(B.trim, 1.3));
    ctx.globalAlpha = .30; fr(bx, by - 1, bw, 1, '#000'); ctx.globalAlpha = 1;
    return;
  }
  if (tarz === 'beton') {
    /* --- DEVLET DUKKANI: tente yok, neon yok, mal yok ---
       Yarisi kepenkli; acik olanin onunde kuyruk parmakligi var. */
    fr(bx + 1, gyy - 6, bw - 2, 21, shadeCol(B.wall, .72));
    /* levha: sade, yazisiz, numarali */
    fr(bx + 3, gyy - 6, bw - 7, 5, '#3e4248');
    fr(bx + 3, gyy - 6, bw - 8, 4, B.sign);
    ctx.globalAlpha = .55;
    for (var lv = bx + 6; lv < bx + bw - 9; lv += 5) fr(lv, gyy - 4, 3, 1, '#c8ccd0');
    ctx.globalAlpha = 1;
    var kepenk = hash1(i * 7.7) > .45;
    if (kepenk) {
      /* indirilmis metal kepenk: yatay oluklar + asma kilit */
      fr(bx + 3, gyy, bw - 7, 14, '#4e5258');
      for (var kk2 = gyy + 1; kk2 < gyy + 14; kk2 += 2) {
        ctx.globalAlpha = .35; hl(bx + 3, kk2, bw - 8, '#2e3238'); ctx.globalAlpha = 1;
      }
      fr(bx + 3, gyy + 13, bw - 7, 2, '#33373d');
      fr(bx + (bw >> 1) - 1, gyy + 12, 3, 3, '#7a7e84');
    } else {
      /* acik: karanlik ic, bos raflar, onunde kuyruk parmakligi */
      fr(bx + 3, gyy, bw - 7, 14, '#242830');
      ctx.globalAlpha = .5;
      for (var rf = gyy + 3; rf < gyy + 12; rf += 4) hl(bx + 5, rf, bw - 11, '#4a4e54');
      ctx.globalAlpha = 1;
      /* kapi */
      fr(bx + 5, gyy + 4, 5, 11, '#33373d');
      fr(bx + 5, gyy + 4, 4, 10, '#454a50');
      /* kuyruk parmakligi: iki dikme + yatay bar */
      var qx = bx + 12;
      if (qx + 12 < bx + bw - 4) {
        fr(qx, gyy + 9, 1, 6, '#6a6e74');
        fr(qx + 11, gyy + 9, 1, 6, '#6a6e74');
        fr(qx, gyy + 10, 12, 1, '#7a7e84');
      }
    }
    ctx.globalAlpha = .30; fr(bx, by - 1, bw, 1, '#000'); ctx.globalAlpha = 1;
    return;
  }
  /* --- RAKIP DONERCI: zemin kat ona ait ---
     Govde, kornis, cati ve ust katlar yukarida ciziliyor; boylece
     komsu cephelerle ayni malzemeden yapilmis oluyor. */
  if (rakip) { rakipZemin(bx, by, bw, gyy, B, rakip); return; }

  /* tabela */
  fr(bx + 2, gyy - 6, bw - 5, 6, shadeCol(B.sign, .7));
  fr(bx + 2, gyy - 6, bw - 6, 5, B.sign);
  hl(bx + 2, gyy - 6, bw - 6, shadeCol(B.sign, 1.4));
  var lw = 4;
  for (var s = bx + 5; s < bx + bw - 6; s += lw + 2) {
    fr(s, gyy - 4, Math.min(lw, bx + bw - 7 - s), 2, hash1(s * 1.7 + i) > .5 ? '#ffd77a' : '#f2ece0');
  }
  /* tente (fisto kenarlı) */
  var ay2 = gyy;
  for (var sx2 = 0; sx2 < bw - 4; sx2++) {
    var band = ((sx2 / 6) | 0) & 1;
    var col = band ? B.awn : '#f2ece0';
    fr(bx + 2 + sx2, ay2, 1, 5, col);
    /* fisto: dalga */
    var wv = ((sx2 % 6) < 3) ? 1 : 0;
    if (wv) px(bx + 2 + sx2, ay2 + 5, col);
  }
  hl(bx + 2, ay2, bw - 4, 'rgba(255,255,255,.4)');
  ctx.globalAlpha = .32; fr(bx + 2, ay2 + 6, bw - 4, 2, '#000'); ctx.globalAlpha = 1;
  /* vitrin camı */
  var vy = ay2 + 7, vh = by - vy - 1;
  fr(bx + 3, vy, bw - 7, vh, '#2f3d47');
  fr(bx + 4, vy + 1, bw - 9, vh - 2, hash1(i * 2.9) > .5 ? '#9fc0d0' : '#b8ccd6');
  /* cam yansıması */
  ctx.globalAlpha = .35;
  for (var q = 0; q < vh - 2; q++) fr(bx + 6 + q, vy + 1 + q, 4, 1, '#ffffff');
  ctx.globalAlpha = 1;
  /* vitrindeki mallar */
  for (var m = 0; m < 3; m++) {
    var mx = bx + 6 + m * 7;
    if (mx + 3 > bx + bw - 6) break;
    fr(mx, by - 4, 3, 3, ['#c0281c', '#e0a83a', '#3f8a4a'][(i + m) % 3]);
  }
  /* kapı */
  var dx0 = bx + bw - 12;
  fr(dx0, vy, 9, vh + 1, shadeCol(B.trim, .7));
  fr(dx0 + 1, vy + 1, 7, vh, '#7a5f42');
  fr(dx0 + 2, vy + 2, 5, 5, '#a8c6d4');
  px(dx0 + 6, vy + Math.round(vh * .6), '#f0d78a');
  /* basamak */
  fr(bx + 2, by, bw - 4, 1, '#cdd4da');
}

/* ---------------- vitrinin ardındaki sabit sokak ---------------- */
function bakeStreet() {
  var M = stM(), gx = M.gx, gy = M.gy, gw = M.gw, gh = M.gh;
  /* Her sey camin icinde kalsin. Bacalar ve kornisler cerceve
     hizasini asiyordu; artik hicbir sey disari tasamaz. */
  ctx.save();
  ctx.beginPath(); ctx.rect(gx, gy, gw, gh); ctx.clip();

  var TEMA = sehirTema();
  /* ---- gökyüzü: şehrin kendi ışığı ---- */
  for (var y = 0; y < 56; y++) {
    fr(gx, gy + y, gw, 1, mixHex(TEMA.gok[0], TEMA.gok[1], clamp(y / 44, 0, 1)));
  }
  /* bulutlar */
  for (var cl = 0; cl < 5; cl++) {
    var cxx = gx + 6 + hash1(cl * 5.3) * (gw - 24);
    var cyy = gy + 3 + hash1(cl * 2.1) * 14;
    var cw = 9 + hash1(cl * 1.7) * 8;
    ctx.globalAlpha = .75;
    ell(cxx, cyy + 1, cw, 3, '#dfeaf2');
    ell(cxx, cyy, cw, 3, '#ffffff');
    ell(cxx - cw * .5, cyy + 1, cw * .55, 2, '#ffffff');
    ell(cxx + cw * .55, cyy + 1, cw * .45, 2, '#f4fafd');
    ctx.globalAlpha = 1;
  }
  /* ---- şehrin imzası: binaların ARKASINDA, ufukta ---- */
  if (TEMA.imza) drawImza(TEMA.imza, gx + Math.round(gw * .70), M.base);

  /* ---- uzak silüet: iki katman, arkadaki daha soluk ve yüksek ---- */
  for (var kat = 0; kat < 2; kat++) {
    var solukluk = kat === 0 ? .20 : .34;      /* arka katman daha soluk */
    var yukseklik = kat === 0 ? 14 : 0;        /* arka katman daha yüksek */
    var adim = kat === 0 ? 26 : 30;
    var kaydir = kat === 0 ? -14 : -10;
    var sayi = Math.ceil(gw / adim) + 2;
    for (var f = 0; f < sayi; f++) {
      var tohum = f * 3.7 + kat * 17.3;
      var fw = 18 + Math.floor(hash1(tohum) * 24);
      var fx0 = gx + kaydir + f * adim;
      var fh = 20 + yukseklik + Math.floor(hash1(tohum * 1.9) * 20);
      var fy0 = M.base - fh;
      if (fy0 < gy + 2) fy0 = gy + 2;          /* camın üstüne taşma */
      ctx.globalAlpha = solukluk;
      fr(fx0, fy0, fw, M.base - fy0, kat === 0 ? TEMA.bina[0] : TEMA.bina[1]);
      fr(fx0, fy0, fw, 2, mixHex(TEMA.bina[0], '#ffffff', .18));
      /* çatıda su deposu / anten */
      if (hash1(tohum * 5.1) > .62) {
        fr(fx0 + 4, fy0 - 4, 5, 4, TEMA.bina[0]);
        fr(fx0 + 3, fy0 - 5, 7, 1, mixHex(TEMA.bina[0], '#ffffff', .18));
      }
      if (hash1(tohum * 8.3) > .70) vl(fx0 + fw - 6, fy0 - 6, 6, mixHex(TEMA.bina[0], '#ffffff', .18));
      ctx.globalAlpha = 1;
      for (var wy = 0; wy < 6; wy++) {
        for (var wx = 0; wx < 3; wx++) {
          if (hash1(tohum * 11 + wy * 3.3 + wx * 1.9) < .48) continue;
          var pcy = fy0 + 5 + wy * 6;
          if (pcy + 4 > M.base - 2) break;
          ctx.globalAlpha = solukluk * .8;
          fr(fx0 + 4 + wx * 6, pcy, 3, 4, '#e6f0f6');
          ctx.globalAlpha = 1;
        }
      }
    }
  }

  /* ---- karşı sıra dükkânlar ---- */
  var bx = gx - 16, bi = 0;
  /* Rakip donerciye SABIT bir cephe slotu ayrilir: sokaga sonradan
     yapistirilmis gibi degil, sirann bir parcasi gibi dursun. */
  var rakipSlot = 3, rakipDurum = rakipCepheDurum();
  /* Cepheler sehre gore: New York dar ve yuksek (kucuk binalar
     yakisiksizdi), Dubai ince cam kuleler, Paris/Londra klasik blok. */
  var CP = TEMA.cephe || { boyAz: 24, boyCok: 34, genAz: 46, genCok: 66, tarz: 'dukkan' };
  while (bx < gx + gw + 10) {
    var bw = CP.genAz + Math.floor(hash1(bi * 4.3) * (CP.genCok - CP.genAz));
    /* Tepede gokyuzu gorunsun: baca (top-12) ve kornis (top-4) dahil
       en yuksek nokta camin ust kenarinin altinda kalmali. */
    var enYuksek = (M.base - gy) - 16;
    var bh = CP.boyAz + Math.floor(hash1(bi * 9.1) * Math.max(1, CP.boyCok - CP.boyAz));
    if (bh > enYuksek) bh = enYuksek;
    if (bi === rakipSlot && rakipDurum && CP.tarz === 'dukkan') {
      /* dukkan cephesi olan sehirlerde rakip o sirada oturur */
      bw = 58;
      drawBuilding(bx, M.base, bw, Math.min(bh, 30), bi, gy, CP.tarz, rakipDurum);
    } else {
      drawBuilding(bx, M.base, bw, bh, bi, gy, CP.tarz);
    }
    bx += bw + 3;
    bi++;
  }

  /* ---- DEMIRKENT: hoparlorlu direk ----
     Rejim sehrinin en taniyici parcasi. Kaldirimin ustunde, binalarin
     onunde durur; iki yana bakan iki huni. */
  if (CP.tarz === 'beton') {
    var hx = gx + Math.round(gw * .34), hb = M.base + 2;
    fr(hx, hb - 40, 2, 40, '#4a4e54');
    fr(hx, hb - 40, 1, 40, '#6a6e74');
    /* baglanti kolu */
    fr(hx - 5, hb - 39, 12, 1, '#4a4e54');
    /* iki huni: dar uctan genise */
    for (var hn = 0; hn < 2; hn++) {
      var yon2 = hn ? 1 : -1, ux = hx + (hn ? 6 : -6);
      for (var hk = 0; hk < 5; hk++) {
        fr(ux + yon2 * hk, hb - 42 - hk, 1, 3 + hk * 2, '#3e4248');
      }
      fr(ux + yon2 * 4, hb - 47, 1, 12, '#5a5e64');
    }
    fr(hx - 1, hb - 41, 4, 3, '#5a5e64');
  }

  /* ---- karşı kaldırım ---- */
  fr(gx, M.base + 1, gw, 7, mixHex(TEMA.kaldirim, '#000000', .16));
  fr(gx, M.base + 1, gw, 6, TEMA.kaldirim);
  for (var s1 = gx - 3; s1 < gx + gw; s1 += 13) {
    vl(s1 + (((s1 / 13) | 0) % 2 ? 5 : 0), M.base + 1, 6, '#a9b0b7');
  }
  hl(gx, M.base + 1, gw, '#dbe1e6');
  /* bordür */
  fr(gx, M.base + 7, gw, 2, '#858c93');
  hl(gx, M.base + 7, gw, '#cbd1d7');

  /* ---- yol ---- */
  fr(gx, M.roadY, gw, M.roadH, TEMA.yol);
  for (var n = 0; n < 190; n++) {
    ctx.globalAlpha = .26;
    px(gx + hash1(n * 3.1) * gw, M.roadY + 2 + hash1(n * 5.7) * (M.roadH - 4), hash1(n) > .5 ? '#565b62' : '#35383e');
    ctx.globalAlpha = 1;
  }
  /* asfalt yaması */
  ctx.globalAlpha = .18;
  fr(gx + 150, M.roadY + 4, 40, 9, '#000');
  fr(gx + 40, M.roadY + 15, 26, 6, '#000');
  ctx.globalAlpha = 1;
  /* orta şerit */
  for (var dsh = gx + 3; dsh < gx + gw; dsh += 20) {
    fr(dsh, M.roadY + Math.round(M.roadH / 2) - 1, 11, 2, '#d9cf98');
    hl(dsh, M.roadY + Math.round(M.roadH / 2) - 1, 11, '#f2ebc4');
  }
  /* yaya geçidi */
  for (var zb = 0; zb < 5; zb++) {
    fr(gx + 196 + zb * 8, M.roadY + 1, 5, M.roadH - 2, 'rgba(232,236,240,.72)');
  }

  /* ---- bizim taraf: bordür + kaldırım ---- */
  fr(gx, M.curb2, gw, 2, '#858c93');
  hl(gx, M.curb2, gw, '#cbd1d7');
  fr(gx, M.curb2 + 2, gw, gy + gh - M.curb2 - 2, TEMA.kaldirim);
  for (var s2 = gx + 5; s2 < gx + gw; s2 += 15) vl(s2, M.curb2 + 2, gy + gh - M.curb2 - 2, '#9aa1a8');
  hl(gx, M.curb2 + 2, gw, '#d2d8dd');
  ctx.restore();
}

/* ---------------- şehre özel sokak öğeleri ---------------- */
/* Karşı kaldırımdaki ağaç: her şehir kendi ağacını yetiştirir. */
function drawSokakAgaci(tx, ty, tip) {
  if (tip === 'palmiye') {
    fr(tx - 4, ty - 2, 9, 3, '#5a4a32');
    for (var s = 0; s < 23; s++)
      px(tx + Math.round(Math.sin(s * .16) * 2), ty - 2 - s, s % 3 === 0 ? '#87694a' : '#6b533a');
    var py0 = ty - 26, pxx = tx + Math.round(Math.sin(23 * .16) * 2);
    for (var p = 0; p < 7; p++) {
      var pa = -2.95 + p * 0.49;
      ln(pxx, py0, pxx + Math.cos(pa) * 13, py0 + Math.sin(pa) * 9, '#2f6a34');
      ln(pxx, py0, pxx + Math.cos(pa) * 10, py0 + Math.sin(pa) * 7, '#3f8a4a');
      ln(pxx, py0, pxx + Math.cos(pa) * 6, py0 + Math.sin(pa) * 4, '#4d9a58');
    }
    for (var hd = 0; hd < 4; hd++) px(pxx - 2 + hd, py0 + 2, '#b0862a');
    return;
  }
  if (tip === 'sakura') {
    fr(tx - 4, ty - 2, 9, 3, '#5a4a32');
    fr(tx - 1, ty - 19, 3, 18, '#5a4436');
    vl(tx - 1, ty - 19, 18, '#75594a');
    ln(tx, ty - 13, tx - 5, ty - 18, '#5a4436');
    ln(tx, ty - 15, tx + 5, ty - 19, '#5a4436');
    ell(tx, ty - 24, 11, 7, '#c9738f');
    ell(tx - 5, ty - 26, 7, 5, '#e090aa');
    ell(tx + 5, ty - 23, 7, 5, '#e090aa');
    ell(tx - 1, ty - 28, 6, 4, '#f7b8ce');
    for (var lf2 = 0; lf2 < 9; lf2++)
      px(tx - 8 + hash1(lf2 * 3.7) * 16, ty - 29 + hash1(lf2 * 5.1) * 12, '#ffd8e6');
    return;
  }
  if (tip === 'budanmis') {
    /* budanmış çınar: düz gövde, kutu gibi kesilmiş taç */
    fr(tx - 4, ty - 2, 9, 3, '#5a4a32');
    fr(tx - 1, ty - 22, 3, 21, '#6b6252');
    vl(tx - 1, ty - 22, 21, '#877c68');
    fr(tx - 9, ty - 31, 19, 10, '#2f5a30');
    fr(tx - 8, ty - 31, 17, 9, '#3d6f39');
    hl(tx - 7, ty - 31, 15, '#4d8544');
    for (var lf3 = 0; lf3 < 10; lf3++)
      px(tx - 8 + hash1(lf3 * 3.7) * 17, ty - 30 + hash1(lf3 * 5.1) * 8, '#5b9a4e');
    return;
  }
  /* yapraklı (varsayılan) */
  fr(tx - 4, ty - 2, 9, 3, '#5a4a32');
  fr(tx - 1, ty - 20, 3, 19, '#6b533a');
  vl(tx - 1, ty - 20, 19, '#87694a');
  ln(tx, ty - 14, tx - 4, ty - 18, '#6b533a');
  ln(tx, ty - 16, tx + 4, ty - 20, '#6b533a');
  ell(tx, ty - 25, 11, 8, '#2f5a30');
  ell(tx - 4, ty - 27, 7, 6, '#3d6f39');
  ell(tx + 5, ty - 24, 7, 5, '#3d6f39');
  ell(tx - 1, ty - 29, 6, 4, '#4d8544');
  for (var lf = 0; lf < 8; lf++)
    px(tx - 8 + hash1(lf * 3.7) * 16, ty - 30 + hash1(lf * 5.1) * 12, '#63a052');
}

/* Kaldırımdaki imza nesnesi: şehri tek bakışta ele veren küçük detay. */
function drawSehirIkonu(x, y, id, t) {
  if (id === 'simit') {                 /* İstanbul: simit arabası */
    fr(x - 3, y - 11, 16, 9, '#8a2318');
    fr(x - 2, y - 11, 14, 8, '#c0392b');
    hl(x - 2, y - 11, 14, '#e2604f');
    fr(x - 4, y - 14, 18, 3, '#e8ecef');
    hl(x - 4, y - 14, 18, '#ffffff');
    for (var s = 0; s < 3; s++) ring(x + 1 + s * 4, y - 7, 2, '#c9a03a');
    disc(x + 1, y - 1, 2, '#3a3f45'); disc(x + 9, y - 1, 2, '#3a3f45');
    return;
  }
  if (id === 'sutun') {                 /* Berlin: reklam sütunu */
    fr(x, y - 19, 11, 19, '#3a4048');
    fr(x + 1, y - 19, 9, 18, '#5a4a6a');
    hl(x + 1, y - 19, 9, '#7a6a8a');
    fr(x + 2, y - 16, 7, 6, '#d8a03c');
    fr(x + 3, y - 14, 5, 1, '#6b4a10');
    fr(x + 2, y - 8, 7, 5, '#c0392b');
    fr(x + 3, y - 6, 5, 1, '#6b1a12');
    fr(x - 1, y - 22, 13, 3, '#2f343a');
    hl(x - 1, y - 22, 13, '#5a636b');
    return;
  }
  if (id === 'kulube') {                /* Londra: kırmızı telefon kulübesi */
    fr(x - 1, y - 23, 13, 23, '#7a1810');
    fr(x, y - 22, 11, 22, '#c0392b');
    hl(x, y - 22, 11, '#e2604f');
    for (var kk = 0; kk < 3; kk++)
      for (var jj = 0; jj < 2; jj++)
        fr(x + 1 + jj * 5, y - 20 + kk * 6, 4, 5, '#2c3b45');
    fr(x - 2, y - 26, 15, 4, '#7a1810');
    fr(x - 1, y - 26, 13, 3, '#c0392b');
    hl(x - 1, y - 26, 13, '#e2604f');
    return;
  }
  if (id === 'sarisari') {              /* Manila: sari-sari tezgâhı */
    fr(x - 4, y - 11, 19, 11, '#6b533a');
    fr(x - 3, y - 11, 17, 10, '#8a6a48');
    fr(x - 5, y - 14, 21, 3, '#3f8a4a');
    hl(x - 5, y - 14, 21, '#63b46f');
    /* asılı poşetler: renk cümbüşü */
    for (var pp = 0; pp < 7; pp++)
      fr(x - 4 + pp * 3, y - 11, 2, 3,
         ['#e8b62c', '#c0392b', '#3f6fbd', '#e07a2a', '#7a4a9a', '#2aa08a', '#e2604f'][pp]);
    fr(x + 2, y - 8, 6, 4, '#e8ecef');
    hl(x + 2, y - 8, 6, '#ffffff');
    return;
  }
  if (id === 'kafe') {                  /* Paris: kaldırım kafesi */
    ell(x + 4, y - 10, 6, 2, '#e8ecef');
    vl(x + 4, y - 9, 8, '#6f777f');
    fr(x + 3, y - 2, 3, 2, '#4d545b');
    px(x + 3, y - 12, '#c0392b'); px(x + 4, y - 13, '#c0392b');
    fr(x - 3, y - 8, 2, 8, '#2f6a4a');
    fr(x - 4, y - 13, 4, 6, '#3f8a5a');
    fr(x + 9, y - 8, 2, 8, '#2f6a4a');
    fr(x + 9, y - 13, 4, 6, '#3f8a5a');
    return;
  }
  if (id === 'otomat') {                /* Tokyo: ışıklı otomat */
    fr(x - 1, y - 21, 14, 21, '#2f343a');
    fr(x, y - 20, 12, 20, '#e8ecef');
    fr(x + 1, y - 19, 10, 12, '#16202c');
    for (var oi = 0; oi < 6; oi++)
      fr(x + 2 + (oi % 3) * 3, y - 18 + Math.floor(oi / 3) * 5, 2, 4,
         ['#c0392b', '#3f6fbd', '#e8b62c', '#3f8a4a', '#e07a2a', '#e8ecef'][oi]);
    fr(x + 1, y - 6, 10, 2, '#8f979f');
    fr(x + 2, y - 3, 4, 1, '#4d545b');
    ctx.globalAlpha = .16 + .06 * Math.sin(t * 2);
    fr(x - 3, y - 23, 18, 24, '#bfe8ff');
    ctx.globalAlpha = 1;
    return;
  }
  if (id === 'musluk') {                /* New York: yangın musluğu + buhar */
    fr(x + 2, y - 11, 7, 11, '#8a2318');
    fr(x + 3, y - 11, 5, 10, '#c0392b');
    hl(x + 3, y - 11, 5, '#e2604f');
    fr(x + 1, y - 13, 9, 2, '#8a2318');
    fr(x + 4, y - 15, 3, 2, '#c0392b');
    fr(x, y - 8, 2, 3, '#8a2318'); fr(x + 9, y - 8, 2, 3, '#8a2318');
    if (chance(.045)) smoke(x + 16, y - 1, 1, 'rgba(220,228,236,.42)');
    return;
  }
  if (id === 'palmiye') {               /* Dubai: saksıda hurma */
    fr(x + 1, y - 6, 9, 6, '#9a7a52');
    fr(x + 2, y - 6, 7, 5, '#c09868');
    hl(x + 2, y - 6, 7, '#d8b088');
    fr(x + 4, y - 17, 3, 11, '#6b533a');
    vl(x + 4, y - 17, 11, '#87694a');
    for (var pd = 0; pd < 6; pd++) {
      var pa2 = -2.85 + pd * 0.55;
      ln(x + 5, y - 18, x + 5 + Math.cos(pa2) * 9, y - 18 + Math.sin(pa2) * 6, '#2f6a34');
      ln(x + 5, y - 18, x + 5 + Math.cos(pa2) * 6, y - 18 + Math.sin(pa2) * 4, '#4d9a58');
    }
    return;
  }
  /* varsayılan: posta kutusu */
  fr(x, y - 12, 7, 12, '#8a2318');
  fr(x, y - 12, 6, 11, '#c0392b');
  hl(x, y - 12, 6, '#e2604f');
  fr(x + 1, y - 10, 4, 1, '#3a1a14');
  vl(x + 3, y, 1, '#5a636b');
}

/* ---------------- özel müşterilerin binekleri ----------------
   Blender: blender/models/binek.py. Ozel kalipli musteri dukkanda
   oldugu surece bineği sokakta park etmis durur. */

/* Uçan süpürge: YATAY sap + arkada saman demeti.
   Önce dikey çiziliyordu; uçan bir süpürge yatay durur ve üstünde
   binici oturur. Park hâlinde de yatay, yerden birkaç piksel yukarıda
   asılı bekler (sihirli süpürge yere yatmaz). */
function drawSupurge(x, y, p, binici) {
  var i;
  p = p === undefined ? 1 : clamp(p, 0, 1);
  var sal = Math.round(Math.sin(y * .07 + p * 9) * 1);
  var yy = y - 8 - Math.round((1 - p) * 26) + sal;      /* havada asılı */
  ctx.globalAlpha = .22 * p; ell(x + 2, y, 9, 2, '#000'); ctx.globalAlpha = 1;
  /* sap: soldan sağa yatay, hafif eğimli */
  for (i = 0; i < 22; i++) {
    var sx = x - 10 + i, sy = yy - Math.round(i * .10);
    fr(sx, sy, 1, 2, '#54402a');
    px(sx, sy, '#8a6f4a');
  }
  fr(x + 11, yy - 3, 2, 2, '#6f5638');                  /* sapın ucundaki topuz */
  px(x + 11, yy - 3, '#a88a5e');
  /* saman demeti: SOL uçta, arkaya doğru dağılır */
  for (i = 0; i < 7; i++) {
    var u = (i - 3) / 3, boy = 7 - Math.abs(i - 3);
    for (var q = 0; q < boy; q++) {
      px(x - 11 - q, yy + Math.round(u * 3) + Math.round(q * u * .35),
         i % 3 === 0 ? '#d8b468' : (i % 3 === 1 ? '#b89448' : '#8f7230'));
    }
  }
  vl(x - 9, yy - 2, 5, '#4a3418');                      /* bağlama ipi */
  px(x - 9, yy - 2, '#8a662e');
  if (binici) drawCirakMini(x + 1, yy, t0Bin(), true);
}

/* Çırak: sokakta görünen küçük figür. Tezgâhtaki kalıpla aynı kimlik:
   dağınık koyu saç, yuvarlak gözlük, siyah cüppe, çizgili atkı.
   otur=true iken süpürgeye binmiş (bacaklar yandan sarkar). */
function drawCirakMini(x, y, t, otur, yuru) {
  var ad = yuru ? (Math.floor(t * 7) % 2) : 0;
  if (!otur) { ctx.globalAlpha = .28; ell(x, y, 5, 2, '#000'); ctx.globalAlpha = 1; }
  var gy0 = otur ? y - 9 : y - 11;
  fr(x - 4, gy0, 8, otur ? 7 : 11, '#161a22');          /* cüppe */
  fr(x - 4, gy0, 7, otur ? 6 : 10, '#20242e');
  fr(x - 3, gy0 + 1, 2, 4, '#9a2632');                  /* atkı */
  fr(x - 3, gy0 + 3, 2, 2, '#d8ac35');
  if (otur) {                                           /* süpürgeye binmiş */
    fr(x - 1, y - 2, 6, 3, '#0b0d12');                  /* uyluk konturu */
    fr(x - 1, y - 2, 5, 2, '#2d3340');                  /* uyluk: öne */
    fr(x + 3, y - 1, 3, 7, '#0b0d12');                  /* baldır konturu */
    fr(x + 3, y, 2, 5, '#20242e');
    fr(x + 2, y + 5, 4, 2, '#2b2018');                  /* ayak */
    fr(x - 5, gy0 + 3, 3, 4, '#9a2632');                /* uçuşan cüppe eteği */
  } else if (yuru) { px(x - 2 + ad, y - 1, '#2b2018'); px(x + 1 - ad, y - 1, '#2b2018'); }
  fr(x - 3, gy0 - 5, 6, 5, '#c9885a');                  /* yüz */
  fr(x - 2, gy0 - 5, 4, 4, '#e0a978');
  fr(x - 3, gy0 - 3, 2, 2, '#f0ece2'); fr(x + 1, gy0 - 3, 2, 2, '#f0ece2');
  px(x - 2, gy0 - 3, '#2b2018'); px(x + 1, gy0 - 3, '#2b2018');
  hl(x - 1, gy0 - 3, 2, '#2a2a2e');                     /* gözlük köprüsü */
  fr(x - 4, gy0 - 8, 8, 4, '#2a1e14');                  /* dağınık saç */
  px(x - 4, gy0 - 9, '#2a1e14'); px(x + 2, gy0 - 9, '#2a1e14');
}
function t0Bin() { return (typeof G !== 'undefined' && G.t) ? G.t : 0; }

/* Motokaravan, yandan./* Motokaravan, yandan. Sokaktaki arabalarla ayni olcekte ama bir tik
   uzun ve yuksek - park edince fark edilsin. */
function drawKaravan(x, y, t, hiz) {
  /* hiz > 0 iken yolda: tekerlek doner, far yanar.
     Cizim varsayilan olarak kabini SAGDA; sagdan gelip sola giderken
     geri geri gelmis oluyordu. Cagiran taraf aynaliyor. */
  var i, L = 62;
  hiz = hiz || 0;
  ctx.globalAlpha = .30; ell(x + L / 2, y, L / 2 - 2, 2, '#000'); ctx.globalAlpha = 1;
  /* govde */
  fr(x, y - 22, 54, 18, '#7a7468');
  fr(x + 1, y - 22, 52, 17, '#bab4a8');
  hl(x + 1, y - 22, 52, '#efe9dc');
  fr(x + 1, y - 6, 52, 2, '#9a948a');
  fr(x + 1, y - 15, 52, 3, '#9a8340');                 /* altin bant */
  hl(x + 1, y - 15, 52, '#c9ac58');
  /* on kabin: alcak ve one egik */
  fr(x + 52, y - 16, 10, 12, '#7a7468');
  fr(x + 52, y - 16, 9, 11, '#bab4a8');
  fr(x + 56, y - 14, 6, 6, '#4d7386');                 /* on cam */
  hl(x + 56, y - 14, 6, '#7aa3b6');
  fr(x + 58, y - 5, 4, 2, '#4d545c');                  /* tampon */
  px(x + 61, y - 12, '#ffe08a');                       /* far */
  /* yan camlar */
  for (i = 0; i < 3; i++) {
    fr(x + 4 + i * 12, y - 20, 9, 7, '#33505f');
    fr(x + 4 + i * 12, y - 20, 8, 6, '#4d7386');
    hl(x + 4 + i * 12, y - 20, 8, '#7aa3b6');
  }
  /* kapi + basamak */
  fr(x + 40, y - 20, 10, 15, '#9a948a');
  rc(x + 40, y - 20, 10, 15, '#7a7468');
  px(x + 48, y - 13, '#4d545c');
  fr(x + 41, y - 4, 8, 2, '#6f7880');
  /* tekerlekler: yolda donerler */
  for (i = 0; i < 2; i++) {
    var wx = x + 9 + i * 34;
    disc(wx, y - 4, 5, '#14161a');
    disc(wx, y - 4, 3, '#31363e');
    if (hiz > .02) {                       /* donen jant cizgisi */
      var wa = t * 14 * hiz + i;
      var wxa = Math.round(Math.cos(wa) * 2), wya = Math.round(Math.sin(wa) * 2);
      ln(wx - wxa, y - 4 - wya, wx + wxa, y - 4 + wya, '#98a2ab');
    } else disc(wx, y - 4, 1, '#98a2ab');
  }
  if (hiz > .02) {                         /* yolda: far ve stop */
    fr(x + 61, y - 13, 2, 3, '#ffe08a');
    px(x + 62, y - 12, '#fffbe0');
    fr(x - 1, y - 13, 2, 2, '#c02a1e');
  }
  /* catida klima + anten */
  fr(x + 14, y - 25, 12, 3, '#4d545c');
  hl(x + 14, y - 25, 12, '#98a2ab');
  vl(x + 36, y - 31, 9, '#6f7880');
  fr(x + 33, y - 32, 7, 1, '#6f7880');
}

/* Ejderha: kraliçenin bineği. Blender: blender/models/binek.py.
   YIRTICI duruş - baş öne uzanmış ve alçak, ağız açık, kanat yarı
   kalkık. İlk tasarımlarda boyun dimdik yukarı gidiyordu; o duruş
   ejderhayı sevimli gösteriyordu.
   x,y = zemin merkezi.  inis: 0 havada, 1 konmuş. */
function drawEjderha(x, y, t, inis, ucus) {
  inis = inis === undefined ? 1 : clamp(inis, 0, 1);
  var P0 = '#0e1711', P1 = '#16241a', P2 = '#1f3324', P3 = '#2b452f';
  var KRN = '#5f5228', KRN2 = '#7d6b36', BOY = '#7c6c52', BOY2 = '#9e8c6c';
  var ZAR = '#131f18', ZARK = '#4a6b46';
  var cirp = ucus ? Math.sin(t * 7.5) * 7 : Math.sin(t * .9) * 1;
  var nf = Math.round(Math.sin(t * 1.5));          /* nefes */

  /* tapering zincir: uzuv boyunca incelen elips dizisi */
  function zin(pts, r0, r1) {
    for (var i = 0; i < pts.length - 1; i++) {
      var a = pts[i], b = pts[i + 1];
      for (var q = 0; q <= 5; q++) {
        var u = (i + q / 5) / (pts.length - 1);
        var rr = r0 + (r1 - r0) * u;
        var ax = a[0] + (b[0] - a[0]) * (q / 5);
        var ay = a[1] + (b[1] - a[1]) * (q / 5);
        ell(ax, ay, rr, rr * .94, P1);
        ell(ax - 1, ay - 1, Math.max(1, rr - 1.4), Math.max(1, rr * .70), P2);
      }
    }
  }

  if (!ucus) { ctx.globalAlpha = .30; ell(x + 2, y, 28, 4, '#000'); ctx.globalAlpha = 1; }

  /* --- kuyruk: geriye uzanir, ucunda diken --- */
  zin([[x + 15, y - 9], [x + 24, y - 10], [x + 30, y - 13], [x + 34, y - 19],
       [x + 34, y - 25]], 4.5, 1.2);
  for (var d0 = 0; d0 < 3; d0++) {
    var da = -0.6 + d0 * 0.7;
    ln(x + 34, y - 25, x + 34 + Math.round(Math.cos(da) * 5),
       y - 25 - Math.round(Math.sin(da) * 5), BOY);
  }
  /* --- arka bacaklar (uçuşta toplanır) --- */
  var bcU = ucus ? 6 : 0;
  for (var b0 = 0; b0 < 2; b0++) {
    var bx0 = x + 12 + b0 * 3;
    ell(bx0, y - 7 - bcU, 4, ucus ? 4 : 6, b0 ? P1 : P2);
    ell(bx0 - 1, y - 8 - bcU, 3, ucus ? 3 : 4, b0 ? P2 : P3);
    ell(bx0 - 2, y - 1 - bcU * 1.4, 4.5, 2, P1);
    for (var n0 = 0; n0 < 3; n0++) px(bx0 - 6 + n0, y - Math.round(bcU * 1.4), BOY);
  }
  /* --- gövde --- */
  ell(x + 4, y - 12 + nf, 14, 9, P1);
  ell(x + 3, y - 13 + nf, 13, 8, P2);
  ell(x + 2, y - 16 + nf, 11, 5, P1);              /* sırt bandı */
  ell(x + 3, y - 6, 10, 3, KRN);                   /* karın */
  for (var k0 = 0; k0 < 5; k0++) fr(x - 5 + k0 * 4, y - 8, 3, 1, KRN2);
  /* --- ön bacaklar: öne basmış --- */
  for (var f0 = 0; f0 < 2; f0++) {
    var fx0 = x - 12 + f0 * 3;
    ell(fx0, y - 6 - bcU, 3.5, ucus ? 3.5 : 5, f0 ? P1 : P2);
    ell(fx0 - 1, y - 7 - bcU, 2.5, ucus ? 2.5 : 3.5, f0 ? P2 : P3);
    ell(fx0 - 2, y - 1 - bcU * 1.4, 4, 2, P1);
    for (var n1 = 0; n1 < 3; n1++) px(fx0 - 6 + n1, y - Math.round(bcU * 1.4), BOY);
  }
  /* --- boyun: ALÇAK ve ÖNE --- */
  zin([[x - 3, y - 13], [x - 10, y - 15], [x - 17, y - 16], [x - 23, y - 15]],
      5.0, 3.2);
  for (var s0 = 0; s0 < 4; s0++)                   /* boyun dikenleri */
    ln(x - 6 - s0 * 5, y - 19, x - 9 - s0 * 5, y - 23 + s0, BOY);

  /* --- KANAT: yarı açık, geriye yatık --- */
  /* Uçuşta kanat TAM AÇIK ve gerilir; konmuş hâlde yarı katlı.
     Blender: ejderha(ucus=True). */
  var kg = ucus ? 1.85 : 1;
  var kz = [[x - 1, y - 18], [x + 6 + 4 * kg, y - 15 - 2 * kg],
            [x + 8 + 11 * kg, y - 18 - 5 * kg],
            [x + 9 + 13 * kg + Math.round(cirp * .3),
             y - 20 - 13 * kg - Math.round(cirp)],
            [x + 6 + 7 * kg, y - 22 - 15 * kg - Math.round(cirp)],
            [x + 1, y - 22 - 7 * kg]];
  ctx.fillStyle = ZAR;
  ctx.beginPath();
  ctx.moveTo(kz[0][0], kz[0][1]);
  for (var z0 = 1; z0 < kz.length; z0++) ctx.lineTo(kz[z0][0], kz[z0][1]);
  ctx.closePath(); ctx.fill();
  ln(kz[0][0], kz[0][1], kz[3][0], kz[3][1], ZARK);       /* ön kenar */
  ln(kz[3][0], kz[3][1], kz[4][0], kz[4][1], ZARK);
  for (var kb = 0; kb < 4; kb++) {                        /* kemikler */
    var ka = -1.06 + kb * .30;
    var kl = (17 - kb * 3) * kg;
    ln(x + 1 + kb * 4, y - 18,
       x + 1 + kb * 4 + Math.round(Math.cos(ka) * kl),
       y - 18 + Math.round(Math.sin(ka) * kl) - Math.round(cirp * .6),
       BOY);
  }
  /* --- sırt dikenleri --- */
  for (var sd = 0; sd < 4; sd++)
    ln(x - 2 + sd * 6, y - 20, x - 3 + sd * 6, y - 25 + sd, BOY);

  /* --- BAŞ: öne uzanmış, AĞIZ AÇIK --- */
  var hx0 = x - 28, hy0 = y - 15;
  ell(hx0, hy0, 6, 5, P1);
  ell(hx0 - 1, hy0 - 1, 5, 4, P2);
  fr(hx0 - 12, hy0 - 3, 12, 5, P1);                       /* üst çene */
  fr(hx0 - 12, hy0 - 3, 11, 4, P2);
  hl(hx0 - 11, hy0 - 3, 10, P3);
  fr(hx0 - 11, hy0 + 3, 10, 3, KRN);                      /* alt çene: düşük */
  hl(hx0 - 11, hy0 + 3, 9, KRN2);
  fr(hx0 - 10, hy0 + 1, 9, 2, '#2a0a10');                 /* ağız içi */
  for (var dt0 = 0; dt0 < 5; dt0++) {                     /* dişler */
    px(hx0 - 10 + dt0 * 2, hy0 + 1, '#e8e2d0');
    px(hx0 - 9 + dt0 * 2, hy0 + 2, '#d8d2c0');
  }
  fr(hx0 - 7, hy0 - 6, 9, 3, P1);                         /* kaş çıkıntısı */
  hl(hx0 - 7, hy0 - 6, 8, P2);
  px(hx0 - 12, hy0 - 2, '#0b1410');                       /* burun deliği */
  fr(hx0 - 5, hy0 - 3, 3, 2, '#ff7a1e');                  /* göz */
  px(hx0 - 4, hy0 - 3, '#160604');
  for (var bz0 = 0; bz0 < 3; bz0++) {                     /* boynuzlar: geriye */
    var bl = 9 - bz0 * 2;
    ln(hx0 + 1 + bz0, hy0 - 6 + bz0, hx0 + 1 + bz0 + bl, hy0 - 8 + bz0 - bl / 3,
       bz0 ? BOY : BOY2);
  }
  /* konarken/kalkarken toz */
  if (inis > 0 && inis < 1) {
    ctx.globalAlpha = .26 * (1 - inis);
    ell(x + 2, y + 3, 20 + (1 - inis) * 14, 4, '#d8d0c0');
    ctx.globalAlpha = 1;
  }
}

/* Kraliçe: sokakta görünen küçük figür (ejderhaya biner/iner).
   Tezgâhtaki kalıpla aynı kimlik: platin saç, altın yaka, mavi elbise. */
function drawKraliceMini(x, y, t, yuru, otur) {
  /* otur=true: ejderhaya BINMIS. Once sirtta ayakta ve kocaman
     duruyordu; binen biri oturur, bacaklari yandan sarkar. */
  var ad = yuru ? (Math.floor(t * 7) % 2) : 0;
  if (otur) {
    /* BINMIS: kucuk, one egik, bacak dizden kirik ve acik tonda.
       Once ayakta figurun aynisi kullaniliyordu; ejderhaya gore
       kocaman kaliyor ve sirtta ayakta duruyor gibi okunuyordu. */
    /* y = OTURMA cizgisi (ejderhanin sirti). Bacak bu cizginin ALTINA
       sarkmali; once govdeyle ayni hizada cizilince ejderhanin
       silueti icinde kalip hic gorunmuyordu. */
    fr(x - 1, y - 1, 6, 3, '#1b2f3a');                  /* uyluk konturu */
    fr(x - 1, y - 1, 5, 2, '#5f8ea2');                  /* uyluk: öne */
    fr(x + 3, y, 3, 7, '#1b2f3a');                      /* baldır konturu */
    fr(x + 3, y + 1, 2, 5, '#87b3c4');                  /* baldır: aşağı */
    fr(x + 2, y + 6, 4, 2, '#2b2018');                  /* ayak */
    fr(x - 4, y - 8, 9, 9, '#1b2f3a');                  /* gövde konturu */
    fr(x - 3, y - 7, 7, 7, '#2f4c5c');                  /* gövde: öne eğik */
    fr(x - 3, y - 7, 6, 6, '#436a7e');
    vl(x - 2, y - 7, 6, '#5f8ea2');
    fr(x - 2, y - 9, 5, 2, '#a8842c');                  /* altın yaka */
    fr(x - 3, y - 14, 7, 6, '#7a4a2a');                 /* yüz konturu */
    fr(x - 2, y - 13, 5, 4, '#c9885a');
    fr(x - 1, y - 13, 3, 3, '#e0a978');
    px(x - 1, y - 12, '#2b2018'); px(x + 1, y - 12, '#2b2018');
    fr(x - 4, y - 17, 9, 4, '#8a7a58');                 /* saç konturu */
    fr(x - 3, y - 16, 7, 3, '#b8a684');                 /* platin saç */
    fr(x - 3, y - 16, 6, 2, '#e8dcc0');
    fr(x - 5, y - 13, 2, 5, '#d8c9a8');                 /* uçuşan örgü */
    px(x - 6, y - 11, '#e8dcc0');
    return;
  }
  var gy0 = y - 11;
  ctx.globalAlpha = .28; ell(x, y, 5, 2, '#000'); ctx.globalAlpha = 1;
  fr(x - 4, gy0, 8, 11, '#2f4c5c');                     /* elbise */
  fr(x - 4, gy0, 7, 10, '#436a7e');
  vl(x - 3, gy0, 10, '#5f8ea2');
  fr(x - 3, gy0 - 2, 6, 3, '#a8842c');                  /* altın yaka */
  hl(x - 3, gy0 - 2, 6, '#e0bc58');
  fr(x - 3, gy0 - 7, 6, 5, '#c9885a');                  /* yüz */
  fr(x - 2, gy0 - 7, 4, 4, '#e0a978');
  px(x - 2, gy0 - 5, '#2b2018'); px(x + 1, gy0 - 5, '#2b2018');
  fr(x - 4, gy0 - 10, 8, 4, '#b8a684');                 /* platin saç */
  fr(x - 4, gy0 - 10, 7, 3, '#e8dcc0');
  fr(x - 5, gy0 - 7, 2, 8, '#d8c9a8');                  /* örgüler */
  fr(x + 3, gy0 - 7, 2, 8, '#a89474');
  if (yuru) { px(x - 2 + ad, y - 1, '#2b2018'); px(x + 1 - ad, y - 1, '#2b2018'); }
}

/* ---------------- sokak mobilyası (kaldırımda, canlı katman) ---------------- */
/* Dukkanda ozel kalipli musteri varsa bineği sokakta park etmis olur.
   Musteri gidince binek de gider. */
/* Bineklerin gelis/gidis ilerlemesi: 0 yokken, 1 park etmisken.
   drawStreet her karede cagrildigi icin dt'yi t farkindan cikariyoruz. */
var _binekT = -1;
/* Ejderhanin gelis-gidis sirasi. Once yalniz beliriyor/kayboluyordu;
   simdi ucar gelir, konar, binici iner ve dukkana yurur; musteri
   cikinca binici geri gelip biner ve ejderha havalanir. */
var EJD = { faz: 'yok', t: 0 };
var EJD_SURE = { ucus: 2.2, inis: .7, iner: 1.5, biner: 1.5, kalkis: 2.4 };
/* Supurge de ayni mantikla: sagdan suzulur, kavis cizerek konar. */
var SUP = { faz: 'yok', t: 0 };
var SUP_SURE = { ucus: 1.6, iner: 1.2, biner: 1.2, kalkis: 1.5 };
/* Karavan: gelir, KAPISINI ACAR, kimyager iner, kapi kapanir; cikista
   kapi tekrar acilir, biner, kapanir ve karavan surup gider. Eskiden
   yalniz 0->1 bir yumusatmayla beliriyordu - inen/binen kimse yoktu,
   atlastaki door_open/door_close klipleri de bos duruyordu. */
var KAR = { faz: 'yok', t: 0 };
var KAR_SURE = { gelis: 2.2, kapiAc: .6, iner: 1.6, kapiKapa: .6,
                 kapiAc2: .6, biner: 1.6, kapiKapa2: .6, gidis: 2.4 };
var KAR_SIRA = ['yok', 'gelis', 'kapiAc', 'iner', 'kapiKapa', 'bekle',
                'kapiAc2', 'biner', 'kapiKapa2', 'gidis'];

function fazIlerlet(S, SURE, ist, sira) {
  S.t += S.dt;
  var i = sira.indexOf(S.faz);
  if (S.faz === 'yok') { if (ist) { S.faz = sira[1]; S.t = 0; } return; }
  if (S.faz === 'bekle') { if (!ist) { S.faz = sira[i + 1]; S.t = 0; } return; }
  if (SURE[S.faz] !== undefined && S.t >= SURE[S.faz]) {
    S.faz = sira[(i + 1) % sira.length]; S.t = 0;
  }
}

function updateBinek(t, PK) {
  var dt = _binekT < 0 ? 0 : clamp(t - _binekT, 0, .12);
  _binekT = t;
  KAR.dt = dt;
  fazIlerlet(KAR, KAR_SURE, !!PK.kimyager, KAR_SIRA);
  EJD.dt = dt;
  fazIlerlet(EJD, EJD_SURE, !!PK.kralice,
             ['yok', 'ucus', 'inis', 'iner', 'bekle', 'biner', 'kalkis']);
  SUP.dt = dt;
  fazIlerlet(SUP, SUP_SURE, !!PK.cirak,
             ['yok', 'ucus', 'iner', 'bekle', 'biner', 'kalkis']);
}

/* Ozel musteri binegiyle geliyor: binek konup binici inene kadar
   dukkana girmez. Once binek ayri, musteri ayri geliyordu. */
function binekBekle(kalip) {
  if (kalip === 'kralice') {
    return EJD.faz === 'yok' || EJD.faz === 'ucus' || EJD.faz === 'inis' ||
           (EJD.faz === 'iner' && EJD.t < EJD_SURE.iner * .80);
  }
  if (kalip === 'cirak') {
    return SUP.faz === 'yok' || SUP.faz === 'ucus' ||
           (SUP.faz === 'iner' && SUP.t < SUP_SURE.iner * .80);
  }
  if (kalip === 'kimyager') {
    /* Karavan gelip kapisini acana ve kimyager inip dukkana varana
       kadar bekler. Eskiden hic beklemiyordu: karavan hala yolda
       gelirken kimyager tezgahta duruyordu. */
    return KAR.faz === 'yok' || KAR.faz === 'gelis' || KAR.faz === 'kapiAc' ||
           (KAR.faz === 'iner' && KAR.t < KAR_SURE.iner * .80);
  }
  return false;
}

function parkedKalip() {
  var v = {};
  if (typeof G === 'undefined' || !G.customers) return v;
  for (var i = 0; i < G.customers.length; i++) {
    var c = G.customers[i];
    if (!c || !c.look) continue;
    /* 'leave' de SAYILIR: musteri tezgahtan ayrildiginda hala
       dukkanin icinde, kapiya yuruyor. Dislayinca binek erken
       "gitti" sanip binicisini sokakta geri cagiriyordu - kralice
       daha dukkandan cikmadan arkada ejderhaya biniyordu. */
    if (c.look.kalip) v[c.look.kalip] = 1;
  }
  return v;
}

function drawStreetProps(t, lampOn) {
  var M = stM(), gx = M.gx;
  /* --- ağaç (karşı kaldırım): şehrin türüne göre --- */
  drawSokakAgaci(gx + 118, M.base + 7, (sehirTema() || {}).agac);
  /* --- sokak lambası (karşı kaldırım) --- */
  var lx = gx + 46, ly = M.base + 8;
  fr(lx - 1, ly - 34, 3, 34, '#4d545b');
  vl(lx - 1, ly - 34, 34, '#6f777f');
  fr(lx - 3, ly - 1, 7, 2, '#3d434a');
  ln(lx + 1, ly - 34, lx + 7, ly - 36, '#4d545b');
  fr(lx + 6, ly - 37, 8, 3, '#5b636b');
  fr(lx + 7, ly - 34, 6, 2, lampOn ? '#ffe9a0' : '#8f979f');
  if (lampOn) {
    ctx.globalAlpha = .22;
    for (var gI = 0; gI < 12; gI++) fr(lx + 10 - 2 - gI, ly - 32 + gI, 4 + gI * 2, 1, '#ffe9a0');
    ctx.globalAlpha = 1;
  }
  /* --- otobüs durağı (karşı kaldırım) --- */
  var bsx = gx + 150, bsy = M.base + 8;
  fr(bsx, bsy - 22, 2, 22, '#5a636b');
  fr(bsx + 30, bsy - 22, 2, 22, '#5a636b');
  fr(bsx - 2, bsy - 25, 36, 3, '#3f6fbd');
  hl(bsx - 2, bsy - 25, 36, '#6f9ede');
  ctx.globalAlpha = .30; fr(bsx + 2, bsy - 22, 28, 14, '#cfe4f2'); ctx.globalAlpha = 1;
  /* durak tabelası */
  fr(bsx + 8, bsy - 20, 14, 8, '#2f4f6a');
  fr(bsx + 9, bsy - 19, 12, 6, '#e8ecef');
  hl(bsx + 10, bsy - 17, 10, '#3f6fbd');
  hl(bsx + 10, bsy - 15, 7, '#8a9aa8');
  /* bank */
  fr(bsx + 4, bsy - 7, 24, 2, '#7a5a3a');
  hl(bsx + 4, bsy - 7, 24, '#9a7a52');
  vl(bsx + 6, bsy - 5, 5, '#5a4a32'); vl(bsx + 25, bsy - 5, 5, '#5a4a32');

  /* --- sehre ozel kaldirim simgesi --- */
  var pkx = gx + 78, pky = M.base + 8;
  drawSehirIkonu(pkx, pky, (sehirTema() || {}).ikon, t);

  /* --- trafik lambası (karşı) --- */
  var trx = gx + 224, try0 = M.base + 8;
  fr(trx - 1, try0 - 26, 3, 26, '#4d545b');
  fr(trx - 4, try0 - 38, 9, 13, '#33383e');
  fr(trx - 3, try0 - 37, 7, 11, '#454b52');
  /* Isik gercekten calisiyor: TLIGHT durumunu gosterir ve araclar buna uyar. */
  var st = TLIGHT.state;
  var kirmizi = st === 'red', sari = st === 'yellow', yesil = st === 'green';
  disc(trx, try0 - 34, 2, kirmizi ? '#e2483a' : '#5a2a26');
  disc(trx, try0 - 30, 2, sari ? '#e0c23a' : '#5a512a');
  disc(trx, try0 - 27, 2, yesil ? '#3fbf5a' : '#2a5a34');
  /* yanan lambanin halesi */
  var hy = kirmizi ? try0 - 34 : (sari ? try0 - 30 : try0 - 27);
  var hc = kirmizi ? '#e2483a' : (sari ? '#e0c23a' : '#3fbf5a');
  ctx.globalAlpha = .22 + .10 * Math.sin(t * 4);
  disc(trx, hy, 4, hc);
  ctx.globalAlpha = 1;
  /* yaya lambasi (gecidin yaninda) */
  var pwx = trx - 30;
  fr(pwx - 1, try0 - 16, 3, 16, '#4d545b');
  fr(pwx - 3, try0 - 24, 7, 9, '#33383e');
  fr(pwx - 2, try0 - 23, 5, 7, '#454b52');
  disc(pwx, try0 - 21, 1, kirmizi ? '#3fbf5a' : '#2a5a34');   /* araclar dururken yaya gecer */
  disc(pwx, try0 - 18, 1, kirmizi ? '#5a2a26' : '#e2483a');
}
/* bizim taraf kaldırım: araçlardan sonra çizilir (önde durur) */
function drawNearProps(t) {
  var M = stM(), gx = M.gx;
  var pby = LAY.glass.y + LAY.glass.h - 1;
  /* park etmiş bisiklet */
  var pbx = gx + 90;
  ctx.globalAlpha = .28; ell(pbx + 7, pby, 11, 2, '#000'); ctx.globalAlpha = 1;
  ring(pbx, pby - 5, 4, '#2b3037'); ring(pbx + 14, pby - 5, 4, '#2b3037');
  px(pbx, pby - 5, '#8f979f'); px(pbx + 14, pby - 5, '#8f979f');
  ln(pbx, pby - 5, pbx + 6, pby - 12, '#3f8a4a');
  ln(pbx + 6, pby - 12, pbx + 14, pby - 5, '#3f8a4a');
  ln(pbx + 6, pby - 12, pbx + 2, pby - 5, '#357a40');
  ln(pbx + 14, pby - 5, pbx + 9, pby - 5, '#357a40');
  fr(pbx + 4, pby - 14, 4, 2, '#2b2018');
  ln(pbx + 12, pby - 13, pbx + 17, pby - 13, '#5a636b');
  vl(pbx + 14, pby - 13, 8, '#5a636b');
  /* çöp kutusu */
  var kx = gx + 236;
  ctx.globalAlpha = .28; ell(kx + 5, pby, 8, 2, '#000'); ctx.globalAlpha = 1;
  fr(kx, pby - 13, 11, 13, '#4f5a52');
  fr(kx + 1, pby - 13, 9, 12, '#63705f');
  for (var kk = 0; kk < 3; kk++) vl(kx + 3 + kk * 3, pby - 11, 9, '#4f5a52');
  fr(kx - 1, pby - 15, 13, 3, '#3f4a44');
  hl(kx - 1, pby - 15, 13, '#7c8a78');
}

/* ---------------- araçlar ---------------- */
/* type: 0 sedan, 1 taksi, 2 minibüs, 3 hatchback */
var CAR_PAL = [
  { b: '#c0392b', d: '#8a2318', l: '#e2604f' },
  { b: '#e8b62c', d: '#a87c15', l: '#ffd76a' },
  { b: '#e8ecef', d: '#a8b0b8', l: '#ffffff' },
  { b: '#2f6a8a', d: '#1e4661', l: '#4f9ec0' },
  { b: '#3f8a4a', d: '#276030', l: '#63b46f' },
  { b: '#4a5560', d: '#2e363f', l: '#6f7d8a' },
  { b: '#e07a2a', d: '#a35316', l: '#ffa055' },   /* 6 turuncu  */
  { b: '#7a4a9a', d: '#53306c', l: '#a273c0' },   /* 7 mor      */
  { b: '#2aa08a', d: '#177063', l: '#4fc9b0' },   /* 8 turkuaz  */
  { b: '#22262c', d: '#101317', l: '#3d444c' }    /* 9 siyah    */
];
function wheel(x, y, r, t, sp) {
  disc(x, y, r, '#1c1f24');
  disc(x, y, r - 1, '#2b3037');
  disc(x, y, Math.max(1, r - 2), '#9aa3ab');
  var a = t * sp;
  px(x + Math.round(Math.cos(a) * (r - 2)), y + Math.round(Math.sin(a) * (r - 2)), '#5a636b');
  px(x - Math.round(Math.cos(a) * (r - 2)), y - Math.round(Math.sin(a) * (r - 2)), '#5a636b');
}
function vehLen(type, sc) {
  var b = type === 2 ? 44 : type === 3 ? 32 : type === 4 ? 50 : type === 5 ? 46 : 38;
  return Math.round(b * sc);
}
function drawVehicle(x, y, sc, type, ci, dir, t, duruyor) {
  var L = vehLen(type, sc);
  x = Math.round(x); y = Math.round(y);
  ctx.save();
  if (dir < 0) { ctx.translate((x + Math.round(L / 2)) * 2, 0); ctx.scale(-1, 1); }
  var C = CAR_PAL[ci % CAR_PAL.length];
  var wr = Math.max(2, Math.round(3 * sc));
  var bodyH = Math.round(7 * sc), roofH = Math.round((type === 2 ? 10 : 6) * sc);
  var by = y - wr - bodyH;             /* gövde üst */
  var ry = by - roofH;                 /* tavan üst */

  /* gölge */
  ctx.globalAlpha = .30; ell(x + L / 2, y, L / 2 - 1, Math.max(1, Math.round(2 * sc)), '#000'); ctx.globalAlpha = 1;

  if (type === 4) {
    /* --- jeepney (Manila): uzun, alcak, boydan boya sundurmali --- */
    var jr = Math.round(9 * sc), jy = by - jr;
    fr(x, by, L, bodyH, C.d);
    fr(x, by, L - 1, bodyH - 1, C.b);
    fr(x + Math.round(3 * sc), jy, L - Math.round(9 * sc), jr, C.d);
    fr(x + Math.round(3 * sc), jy, L - Math.round(10 * sc), jr - 1, C.b);
    hl(x + Math.round(4 * sc), jy, L - Math.round(12 * sc), C.l);
    /* acik yan: yolcular sirada oturur */
    for (var jw = 0; jw < 5; jw++)
      fr(x + Math.round((6 + jw * 8) * sc), jy + Math.round(2 * sc),
         Math.round(6 * sc), Math.round(5 * sc), '#20282e');
    /* renkli serit + krom on */
    fr(x + 1, by + Math.round(3 * sc), L - 3, Math.max(1, Math.round(2 * sc)), C.l);
    fr(x + L - Math.round(6 * sc), by, Math.round(6 * sc), bodyH - 1, '#d8dee4');
    hl(x + L - Math.round(6 * sc), by, Math.round(6 * sc), '#ffffff');
  } else if (type === 5) {
    /* --- cift katli otobus (Londra) --- */
    var dh = Math.round(15 * sc), dy = by - dh;
    fr(x, dy, L, bodyH + dh, C.d);
    fr(x, dy, L - 1, bodyH + dh - 1, C.b);
    hl(x + 1, dy, L - 3, C.l);
    for (var dk = 0; dk < 2; dk++) {
      var dwy = dy + Math.round((2 + dk * 8) * sc);
      for (var dw = 0; dw < 4; dw++) {
        var dwx = x + Math.round((4 + dw * 10) * sc);
        fr(dwx, dwy, Math.round(8 * sc), Math.round(5 * sc), '#2c3b45');
        fr(dwx, dwy, Math.round(8 * sc), Math.round(4 * sc), '#a9cbdc');
        hl(dwx, dwy, Math.round(8 * sc), '#dff0fa');
      }
    }
    /* iki kat arasi bant */
    fr(x + 1, dy + Math.round(7 * sc), L - 3, Math.max(1, Math.round(1 * sc)), C.d);
  } else if (type === 2) {
    /* --- minibüs / dolmuş --- */
    fr(x, ry, L, bodyH + roofH, C.d);
    fr(x, ry, L - 1, bodyH + roofH - 1, C.b);
    hl(x + 1, ry, L - 3, C.l);
    /* şerit */
    fr(x + 1, by - Math.round(2 * sc), L - 3, Math.max(1, Math.round(2 * sc)), '#2f6a8a');
    /* camlar */
    for (var wI = 0; wI < 3; wI++) {
      var wx0 = x + Math.round((5 + wI * 11) * sc);
      fr(wx0, ry + Math.round(2 * sc), Math.round(9 * sc), Math.round(5 * sc), '#2c3b45');
      fr(wx0, ry + Math.round(2 * sc), Math.round(9 * sc), Math.round(4 * sc), '#a9cbdc');
      hl(wx0, ry + Math.round(2 * sc), Math.round(9 * sc), '#dff0fa');
    }
    /* ön cam */
    fr(x + L - Math.round(8 * sc), ry + Math.round(2 * sc), Math.round(6 * sc), Math.round(5 * sc), '#2c3b45');
    fr(x + L - Math.round(8 * sc), ry + Math.round(2 * sc), Math.round(6 * sc), Math.round(4 * sc), '#bcd8e6');
  } else {
    /* --- otomobil --- */
    var cabX = x + Math.round((type === 3 ? 8 : 10) * sc);
    var cabW = Math.round((type === 3 ? 16 : 18) * sc);
    /* tavan */
    fr(cabX, ry, cabW, roofH, C.d);
    fr(cabX, ry, cabW - 1, roofH - 1, C.b);
    hl(cabX + 1, ry, cabW - 3, C.l);
    /* camlar */
    var gw2 = Math.round(cabW / 2) - 1;
    var ghh = Math.max(2, roofH - 2);
    fr(cabX + 1, ry + 1, gw2 - 1, ghh, '#22303a');
    fr(cabX + 1, ry + 1, gw2 - 1, ghh - 1, '#9cc2d6');
    fr(cabX + gw2 + 1, ry + 1, gw2 - 1, ghh, '#22303a');
    fr(cabX + gw2 + 1, ry + 1, gw2 - 1, ghh - 1, '#b6d4e4');
    hl(cabX + 1, ry + 1, gw2 - 1, '#eaf6ff');
    hl(cabX + gw2 + 1, ry + 1, gw2 - 1, '#eaf6ff');
    /* gövde */
    fr(x, by, L, bodyH, C.d);
    fr(x, by, L - 1, bodyH - 1, C.b);
    hl(x + 2, by, L - 5, C.l);
    /* kaput/bagaj alçalması */
    fr(x, by, Math.round(3 * sc), Math.max(1, Math.round(1 * sc)), C.d);
    fr(x + L - Math.round(3 * sc), by, Math.round(3 * sc), Math.max(1, Math.round(1 * sc)), C.d);
    /* kapı çizgisi + kolu */
    vl(cabX + gw2, by + 1, bodyH - 2, C.d);
    fr(cabX + 2, by + Math.round(2 * sc), Math.round(3 * sc), 1, C.l);
    /* tampon */
    fr(x, by + bodyH - Math.round(2 * sc), L - 1, Math.max(1, Math.round(1 * sc)), '#8f979f');
  }
  /* taksi tepe lambası */
  if (type === 1) {
    fr(x + Math.round(15 * sc), ry - Math.round(3 * sc), Math.round(9 * sc), Math.round(3 * sc), '#2b2018');
    fr(x + Math.round(15 * sc), ry - Math.round(3 * sc), Math.round(8 * sc), Math.round(2 * sc), '#ffe9a0');
  }
  /* farlar */
  fr(x + L - Math.round(2 * sc), by + Math.round(2 * sc), Math.round(2 * sc), Math.round(2 * sc), '#fff2b8');
  /* stop: arac dururken fren lambasi parlar */
  var stopC = duruyor ? '#ff5a48' : '#d8352c';
  fr(x, by + Math.round(2 * sc), Math.max(1, Math.round(2 * sc)), Math.round(2 * sc), stopC);
  if (duruyor) {
    ctx.globalAlpha = .35;
    fr(x - 1, by + Math.round(1 * sc), Math.round(3 * sc), Math.round(4 * sc), '#ff5a48');
    ctx.globalAlpha = 1;
  }
  /* tekerler: duran aracin tekeri donmez */
  var wy2 = y - wr;
  var wsp = duruyor ? 0 : (dir > 0 ? 9 : -9);
  wheel(x + Math.round((type === 2 ? 9 : 8) * sc), wy2, wr, t, wsp);
  wheel(x + L - Math.round((type === 2 ? 10 : 9) * sc), wy2, wr, t, wsp);
  /* çamurluk gölgesi */
  ctx.globalAlpha = .35;
  fr(x + Math.round(5 * sc), wy2 - wr, Math.round(7 * sc), 1, '#000');
  fr(x + L - Math.round(13 * sc), wy2 - wr, Math.round(7 * sc), 1, '#000');
  ctx.globalAlpha = 1;
  ctx.restore();
}

/* ---------------- yayalar ---------------- */
var PED_SHIRT = ['#3f6fbd', '#8a4a7a', '#3f8a4a', '#b0602a', '#4a5560', '#a83a2a',
  '#2f8a8a', '#6a4a9a', '#c9a23a', '#7a3a3a', '#356a4a', '#5a6a8a'];
var PED_PANT = ['#2f3740', '#4a3a2a', '#33414f', '#3a3a44', '#5a4a3a', '#26303a'];
var PED_SKIN = ['#f0bd8a', '#d9a273', '#b57f52', '#8a5c38', '#e0ae7e', '#6d4526'];
var PED_HAIR = ['#2b2018', '#5a3a1e', '#3a2a20', '#7a6a58', '#1a1410', '#8a6a3a', '#a89078'];

/* Her yayanin sabit bir kimligi var: boy, gövde genisligi, sac bicimi,
   aksesuar. k degeri degismedigi icin ayni yaya hep ayni gorunur. */
/* Rejim sehrinde halk da tek duze giyinir: parlak gomlek yok. */
var PED_SHIRT_BETON = ['#5a6068', '#4a5058', '#5c6350', '#6a6458', '#454b54',
  '#67635a', '#515760', '#5e5a52', '#4e5a52', '#6a6e74', '#585e56', '#4a4e54'];
/* TEMA fonksiyon ici yerel bir degisken; burada kapsamda DEGIL. */
function betonSehir() {
  if (typeof sehirTema !== 'function') return false;
  var tm = sehirTema();
  return !!(tm && tm.cephe && tm.cephe.tarz === 'beton');
}
function pedKimlik(k) {
  var h = function (n) { return hash1(k * 7.31 + n * 2.17); };
  var GOM = betonSehir() ? PED_SHIRT_BETON : PED_SHIRT;
  return {
    shirt: GOM[k % GOM.length],
    pant: PED_PANT[(k * 3) % PED_PANT.length],
    skin: PED_SKIN[(k * 5) % PED_SKIN.length],
    hair: PED_HAIR[(k * 2) % PED_HAIR.length],
    boy: h(1) < .22 ? -2 : (h(1) > .82 ? 1 : 0),      /* kisa / normal / uzun */
    genis: h(2) > .74 ? 1 : 0,                         /* genis omuzlu */
    sac: Math.floor(h(3) * 4),                         /* 0 kisa 1 uzun 2 topuz 3 kel */
    esya: Math.floor(h(4) * 5),                        /* 0 yok 1 canta 2 sirt 3 pos 4 kahve */
    sapka: h(5) > .80,
    ceket: h(6) > .62,
    tempo: 5.6 + h(7) * 2.8                            /* adim hizi kisiden kisiye degisir */
  };
}

function drawPed(x, y, k, dir, t, sc, umbrella) {
  x = Math.round(x); y = Math.round(y);
  var P0 = pedKimlik(k);
  var shirt = P0.shirt, pant = P0.pant, skin = P0.skin, hair = P0.hair;
  var boy = P0.boy;                       /* -2 kisa, 0 normal, +1 uzun */
  var gw2 = 4 + P0.genis;                 /* gövde genisligi */

  /* --- 8 fazli yuruyus: bacaklar gercekten makaslar, gövde inip kalkar ---
     [on bacak dx, arka bacak dx, on boy, arka boy, gövde dy, kol acisi] */
  var ph = Math.floor((t * P0.tempo + k * 1.7) % 8);
  var FR = [
    [3, -3, 4, 4, 0, 2],
    [2, -2, 4, 4, -1, 1],
    [0, 0, 5, 4, -1, 0],
    [-2, 2, 4, 4, -1, -1],
    [-3, 3, 4, 4, 0, -2],
    [-2, 2, 4, 4, -1, -1],
    [0, 0, 4, 5, -1, 0],
    [2, -2, 4, 4, -1, 1]
  ][ph];
  var fx0 = FR[0], bx0 = FR[1], fl = FR[2], bl = FR[3], by = FR[4] + boy, arm = FR[5];
  var yy = y + by;

  ctx.globalAlpha = .24; ell(x, y, 3 + P0.genis, 1, '#000'); ctx.globalAlpha = 1;

  /* --- arka bacak (koyu) --- */
  fr(x + bx0 - 1, yy - 4, 2, bl, shadeCol(pant, .74));
  px(x + bx0 - 1 + (bx0 < 0 ? -1 : 1), yy - 5 + bl, '#241c16');     /* ayakkabi */
  /* --- on bacak --- */
  fr(x + fx0 - 1, yy - 4, 2, fl, pant);
  px(x + fx0 - 1 + (fx0 > 0 ? 1 : -1), yy - 5 + fl, '#1a1410');

  /* --- gövde --- */
  var gx0 = x - Math.floor(gw2 / 2);
  fr(gx0, yy - 8, gw2 + 1, 5, shadeCol(shirt, .76));
  fr(gx0, yy - 8, gw2, 4, shirt);
  hl(gx0, yy - 8, gw2, shadeCol(shirt, 1.4));
  if (P0.ceket) {                                    /* acik ceket: iki yaka */
    vl(gx0, yy - 8, 5, shadeCol(shirt, .6));
    vl(gx0 + gw2 - 1, yy - 8, 5, shadeCol(shirt, .6));
    px(x, yy - 7, shadeCol(shirt, 1.6));
  }

  /* --- kollar: bacaklarin tersi --- */
  fr(gx0 - 1, yy - 7 - arm, 1, 4, shadeCol(shirt, .78));
  px(gx0 - 1, yy - 3 - arm, skin);
  fr(gx0 + gw2, yy - 7 + arm, 1, 4, shadeCol(shirt, .94));
  px(gx0 + gw2, yy - 3 + arm, skin);

  /* --- esya (kolla birlikte sallanir) --- */
  if (P0.esya === 1) {                                /* el cantasi */
    fr(gx0 + gw2, yy - 2 + arm, 2, 3, '#7a4a2a'); px(gx0 + gw2, yy - 2 + arm, '#a8703a');
  } else if (P0.esya === 2) {                         /* sirt cantasi */
    fr(gx0 - (dir > 0 ? 1 : -gw2), yy - 7, 2, 5, '#3f5a7a');
    px(gx0 - (dir > 0 ? 1 : -gw2), yy - 7, '#5a7a9a');
  } else if (P0.esya === 3) {                         /* poset */
    fr(gx0 + gw2, yy - 2 + arm, 2, 3, '#dfe6ea'); hl(gx0 + gw2, yy - 2 + arm, 2, '#ffffff');
  } else if (P0.esya === 4) {                         /* kahve bardagi */
    fr(gx0 + gw2, yy - 3 + arm, 2, 2, '#e8e2d0'); px(gx0 + gw2, yy - 4 + arm, '#a83a2a');
  }

  /* --- bas --- */
  var hy = yy - 11;
  fr(x - 1, hy, 3, 3, skin);
  px(x - 2, hy + 1, skin); px(x + 2, hy + 1, skin);
  /* sac bicimi */
  if (P0.sac === 0) {                                 /* kisa */
    fr(x - 2, hy - 1, 5, 1, hair); px(x - 2, hy, hair); px(x + 2, hy, hair);
  } else if (P0.sac === 1) {                          /* uzun */
    fr(x - 2, hy - 1, 5, 1, hair);
    vl(x - 2, hy, 4, hair); vl(x + 2, hy, 4, hair);
  } else if (P0.sac === 2) {                          /* topuz */
    fr(x - 2, hy - 1, 5, 1, hair); px(x - 2, hy, hair); px(x + 2, hy, hair);
    px(x + (dir > 0 ? -3 : 3), hy - 1, hair); px(x + (dir > 0 ? -3 : 3), hy, hair);
  } else {                                            /* kel/seyrek */
    px(x - 2, hy, hair); px(x + 2, hy, hair);
  }
  if (P0.sapka) {                                     /* sapka sacin ustune */
    fr(x - 2, hy - 2, 5, 2, shadeCol(shirt, .55));
    fr(x - 3 + (dir > 0 ? 2 : 0), hy - 1, 3, 1, shadeCol(shirt, .45));
  }
  /* iki goz, bakis yonu */
  px(x - 1 + (dir > 0 ? 1 : 0), hy + 1, '#2b2018');
  px(x + 1 + (dir > 0 ? 1 : 0), hy + 1, '#2b2018');

  if (umbrella) {
    ell(x, yy - 15 + boy, 6, 2, '#2f4f6a');
    ell(x, yy - 16 + boy, 6, 2, PED_SHIRT[(k * 4) % PED_SHIRT.length]);
    vl(x, yy - 15 + boy, 5, '#5a4a32');
    px(x - 5, yy - 14 + boy, '#2f4f6a'); px(x + 5, yy - 14 + boy, '#2f4f6a');
  }
}

/* ---- vitrin çerçevesi + cam yansıması (bir kez pişer) ---- */
var WINOVER = null;
function bakeWinOver() {
  var Wn = LAY.win, G0 = LAY.glass;
  var c = document.createElement('canvas');
  c.width = Wn.w + 12; c.height = Wn.h + 16;
  var g2 = c.getContext('2d'); g2.imageSmoothingEnabled = false;
  var old = ctx; ctx = g2;
  var ox = 6, oy = 4;
  var ix = ox + (G0.x - Wn.x), iy = oy + (G0.y - Wn.y);
  var iw = G0.w, ih = G0.h;

  ctx.save();
  ctx.beginPath(); ctx.rect(ix, iy, iw, ih); ctx.clip();
  ctx.globalAlpha = .08;
  for (var i = 0; i < ih; i++) {
    fr(ix + 26 + i, iy + i, 26, 1, '#ffffff');
    fr(ix + 62 + i, iy + i, 11, 1, '#ffffff');
    fr(ix + 152 + i, iy + i, 18, 1, '#ffffff');
  }
  ctx.globalAlpha = .05; fr(ix, iy, iw, Math.round(ih * .45), '#cfe6f2');
  ctx.globalAlpha = 1;
  ctx.restore();

  var m1 = ix + Math.round(iw / 3), m2 = ix + Math.round(iw * 2 / 3);
  [m1, m2].forEach(function (mx) {
    fr(mx - 2, iy, 5, ih, '#333940');
    fr(mx - 2, iy, 4, ih, '#4c545d');
    vl(mx - 2, iy, ih, '#79838d');
    vl(mx + 2, iy, ih, '#23282e');
  });

  fr(ox, oy, Wn.w, 5, '#333940'); fr(ox, oy, Wn.w, 4, '#4c545d'); hl(ox, oy, Wn.w, '#79838d');
  fr(ox, oy + Wn.h - 5, Wn.w, 5, '#2b3037');
  fr(ox, oy, 5, Wn.h, '#333940'); fr(ox, oy, 4, Wn.h, '#4c545d'); vl(ox, oy, Wn.h, '#79838d');
  fr(ox + Wn.w - 5, oy, 5, Wn.h, '#2b3037'); vl(ox + Wn.w - 1, oy, Wn.h, '#1d2126');
  ctx.globalAlpha = .35;
  fr(ix, iy, iw, 3, '#000'); fr(ix, iy, 3, ih, '#000');
  ctx.globalAlpha = 1;

  var sy2 = oy + Wn.h - 2;
  fr(ox - 6, sy2, Wn.w + 12, 7, '#8d8577');
  fr(ox - 6, sy2, Wn.w + 12, 6, '#c9c2b0');
  hl(ox - 6, sy2, Wn.w + 12, '#e8e2d0');
  for (var v = 0; v < 22; v++) {
    ctx.globalAlpha = .18;
    hl(ox - 4 + hash1(v * 3.9) * (Wn.w + 4), sy2 + 1 + (v % 4), 5 + hash1(v) * 9, '#8d8577');
    ctx.globalAlpha = 1;
  }
  ctx.globalAlpha = .3; fr(ox - 6, sy2 + 6, Wn.w + 12, 2, '#000'); ctx.globalAlpha = 1;

  ctx = old;
  WINOVER = { c: c, ox: ox, oy: oy };
}

/* ---------- guvenlik kamerasi (gunduz de duvarda) ---------- */
function drawWallCam(t, alert) {
  var cx0 = 424, cy0 = 30;
  fr(cx0 + 10, cy0 - 2, 5, 8, '#3a4149');
  hl(cx0 + 10, cy0 - 2, 5, '#5f6a75');
  fr(cx0, cy0 + 3, 15, 8, '#2b3037');
  fr(cx0 + 1, cy0 + 4, 13, 6, '#4a545f');
  hl(cx0 + 1, cy0 + 4, 13, '#6d7a86');
  fr(cx0 - 4, cy0 + 5, 5, 5, '#1b1f26');
  disc(cx0 - 2, cy0 + 7, 2, '#0d1015');
  px(cx0 - 3, cy0 + 6, '#8fb4d8');
  var on = Math.sin(t * 6) > 0;
  disc(cx0 + 12, cy0 + 6, 1, on ? '#ff4a3a' : '#5a2a26');
  if (on && alert) { ctx.globalAlpha = .16; disc(cx0 + 12, cy0 + 6, 5, '#ff4a3a'); ctx.globalAlpha = 1; }
}

/* ---- kepenk (gun basi acilis) ---- */
function drawShutter(k) {
  var G0 = LAY.glass;
  k = clamp(k, 0, 1);
  var hgt = Math.round(G0.h * k);
  ctx.save();
  ctx.beginPath(); ctx.rect(G0.x, G0.y, G0.w, G0.h); ctx.clip();
  if (hgt > 2) {
    for (var yy = 0; yy < hgt - 3; yy++) {
      var band = yy % 3;
      fr(G0.x, G0.y + yy, G0.w, 1, band === 0 ? '#6d757e' : (band === 1 ? '#98a1aa' : '#565e66'));
    }
    /* dikey nervür ve kir */
    for (var vx = G0.x + 4; vx < G0.x + G0.w; vx += 11) {
      ctx.globalAlpha = .16; vl(vx, G0.y, hgt - 3, '#000'); ctx.globalAlpha = 1;
      ctx.globalAlpha = .10; vl(vx + 1, G0.y, hgt - 3, '#ffffff'); ctx.globalAlpha = 1;
    }
    for (var sp = 0; sp < 20; sp++) {
      ctx.globalAlpha = .10;
      fr(G0.x + hash1(sp * 3.1) * G0.w, G0.y + hash1(sp * 5.7) * Math.max(1, hgt - 6), 3 + hash1(sp) * 7, 2, '#3a2a22');
      ctx.globalAlpha = 1;
    }
    /* alt ray */
    fr(G0.x, G0.y + hgt - 4, G0.w, 4, '#353b42');
    fr(G0.x, G0.y + hgt - 4, G0.w, 3, '#5b636c');
    hl(G0.x, G0.y + hgt - 4, G0.w, '#9aa3ac');
    /* tutamak */
    fr(G0.x + G0.w / 2 - 7, G0.y + hgt - 3, 14, 3, '#262b31');
    hl(G0.x + G0.w / 2 - 7, G0.y + hgt - 3, 14, '#6f777f');
    /* ray gölgesi camda */
    ctx.globalAlpha = .3; fr(G0.x, G0.y + hgt, G0.w, 3, '#000'); ctx.globalAlpha = 1;
  }
  ctx.restore();
  /* üstte toplanan rulo */
  if (k < .98) {
    var rh = Math.round(3 + (1 - k) * 6);
    fr(G0.x - 2, G0.y - rh + 1, G0.w + 4, rh, '#3f464e');
    fr(G0.x - 2, G0.y - rh + 1, G0.w + 4, rh - 1, '#6d757e');
    for (var rr = 1; rr < rh - 1; rr += 2) hl(G0.x - 2, G0.y - rh + 1 + rr, G0.w + 4, '#4d555d');
    hl(G0.x - 2, G0.y - rh + 1, G0.w + 4, '#9aa3ac');
  }
}

/* ---- hareketli sokak ---- */
/* ============================================================
   TRAFIK
   Araclar artik zamana gore degil, kendi hizlariyla ilerler.
   Onunde arac varsa yavaslar, gerekirse durur; kirmizi isikta
   durak cizgisinde bekler. Boylece ic ice gecmeleri imkansiz.
   ============================================================ */
var LANE_DIR = [1, -1];          /* uzak serit saga, yakin serit sola akar */

/* isik: yesil -> sari -> kirmizi dongusu */
var TLIGHT = { state: 'green', t: 0, GREEN: 11, YELLOW: 2, RED: 7 };

var TRAF = [];
var TRAFCITY = null;
/* Her sehrin kendi trafigi var: [serit, tip, renk, hiz].
   New York'ta sari taksi, Londra'da cift katli, Manila'da jeepney gecer. */
var TRAF_VARSAYILAN = [[0, 0, 0, 30], [0, 2, 2, 23], [0, 3, 4, 34],
                       [1, 1, 1, 33], [1, 3, 3, 39], [1, 0, 5, 27]];
function trafInit() {
  var M = stM(), span = M.gw + 140;
  var tema = (typeof sehirTema === 'function') ? sehirTema() : null;
  var tar = (tema && tema.trafik && tema.trafik.length) ? tema.trafik : TRAF_VARSAYILAN;
  /* Ayni seritteki araclar ust uste dogmasin diye serit icinde esit dagitilir. */
  var toplam = [0, 0], sayac = [0, 0], k;
  for (k = 0; k < tar.length; k++) toplam[tar[k][0]]++;
  TRAF = [];
  for (k = 0; k < tar.length; k++) {
    var r = tar[k], ln = r[0];
    TRAF.push({
      lane: ln, ty: r[1], ci: r[2], want: r[3], v: r[3],
      u: (sayac[ln] + (ln ? .55 : .05)) / Math.max(1, toplam[ln])
    });
    sayac[ln]++;
  }
  for (var i = 0; i < TRAF.length; i++) { TRAF[i].dir = LANE_DIR[TRAF[i].lane]; TRAF[i].span = span; }
  _carSnd = []; for (var j = 0; j < TRAF.length; j++) _carSnd.push(0);
}
/* Sehir degisince trafik yeniden kurulur; yoksa Tokyo'da Londra otobusu kalirdi. */
function trafGerek() {
  var c = (typeof G !== 'undefined' && G && typeof G.city === 'number') ? G.city : -1;
  if (!TRAF.length || TRAFCITY !== c) { TRAFCITY = c; trafInit(); }
}

/* aracin yol boyunca kat ettigi mesafe (0..1 -> piksel) */
function trafX(c, M) {
  var span = M.gw + 140;
  var L = vehLen(c.ty, c.lane ? 1 : .86);
  return c.dir > 0 ? M.gx - L - 20 + c.u * span : M.gx + M.gw + 20 - c.u * span;
}

/* --- KORNA: trafik sikistikca calar ---
   Rastgele calmak sahte duruyor. Olcut, kac aracin YAVASLADIGI:
   kirmizi isikta ve arka arkaya duran araclarda sik, akan trafikte
   neredeyse hic. Iki kayit donusumlu, aralarinda en az 1.2 sn. */
var KORNA = { bek: 4, son: 0 };
function kornaGuncelle(dt, t) {
  KORNA.bek -= dt;
  if (KORNA.bek > 0) return;
  var yavas = 0, n = TRAF.length;
  for (var i = 0; i < n; i++) if (TRAF[i].v < TRAF[i].want * .45) yavas++;
  var yogun = n ? yavas / n : 0;                 /* 0 akiyor .. 1 tikandi */
  if (yogun < .25) { KORNA.bek = 2.5; return; }  /* akan trafikte korna yok */
  /* sikisiklik arttikca bekleme kisalir: ~20 sn -> ~5 sn.
     Daha sik calinca ambiyans degil gurultu oluyor. */
  KORNA.bek = 4.5 + (1 - yogun) * 16 + Math.random() * 4;
  if (t - KORNA.son < 2.5) return;
  KORNA.son = t;
  if (typeof sndPlay === 'function') {
    sndPlay(Math.random() < .55 ? 'korna1' : 'korna2',
            0.94 + Math.random() * 0.14);        /* hafif perde farki */
  }
}

function updateTraffic(dt) {
  trafGerek();
  var M = stM(), span = M.gw + 140;
  if (typeof G !== 'undefined' && G.scene === 'play') kornaGuncelle(dt, G.t || 0);

  /* --- isik --- */
  var T = TLIGHT;
  T.t += dt;
  if (T.state === 'green' && T.t > T.GREEN) { T.state = 'yellow'; T.t = 0; }
  else if (T.state === 'yellow' && T.t > T.YELLOW) { T.state = 'red'; T.t = 0; }
  else if (T.state === 'red' && T.t > T.RED) { T.state = 'green'; T.t = 0; }
  var durmaliMi = (T.state === 'red' || T.state === 'yellow');

  for (var i = 0; i < TRAF.length; i++) {
    var c = TRAF[i];
    var L = vehLen(c.ty, c.lane ? 1 : .86);
    var hedef = c.want;

    /* --- kirmizi isik: durak cizgisine kadar yaklas ---
       Gecit bakeStreet'te gx+196 ile gx+236 arasi. Saga giden arac
       gecidin solunda, sola giden sagında durur. */
    if (durmaliMi) {
      var burun = trafX(c, M) + (c.dir > 0 ? L : 0);       /* aracin on ucu */
      var cizgi = c.dir > 0 ? (M.gx + 192) : (M.gx + 240);
      var kalan = (cizgi - burun) * c.dir;                  /* kendi yonunde kalan yol */
      if (kalan > -2 && kalan < 52) {
        hedef = Math.min(hedef, Math.max(0, (kalan - 2) * 1.1));
      }
    }

    /* --- onundeki arac --- */
    var enYakin = 1e9;
    for (var j = 0; j < TRAF.length; j++) {
      if (j === i) continue;
      var o = TRAF[j];
      if (o.lane !== c.lane) continue;
      /* ayni seritte, ayni yonde ilerleyen ve onde olan arac */
      var fark = o.u - c.u;
      if (fark < 0) fark += 1;                    /* halka gibi sarmala */
      var mesafe = fark * span - L - 4;           /* tampon payi */
      if (mesafe < enYakin) enYakin = mesafe;
    }
    if (enYakin < 34) {
      /* guvenli takip: mesafe azaldikca hiz duser, cok yakinsa durur */
      hedef = Math.min(hedef, Math.max(0, (enYakin - 5) * 1.15));
    }

    /* --- hizlanma / frenleme --- */
    var ivme = hedef < c.v ? 46 : 15;             /* fren gazdan hizli */
    if (c.v < hedef) c.v = Math.min(hedef, c.v + ivme * dt);
    else c.v = Math.max(hedef, c.v - ivme * dt);
    if (c.v < 0) c.v = 0;

    var onceki = c.u;
    c.u = (c.u + (c.v * dt) / span) % 1;

    /* gecis sesi: ekranin ortasindan gecerken */
    if (onceki < .5 && c.u >= .5 && c.v > 6) SFX.carPass(c.lane === 1);
    if (c.u < onceki && chance(.06)) SFX.horn();
    _carSnd[i] = c.u;
  }
}

/* ---------------- DEMIRKENT: devlet gozcusu ----------------
   Sivil yayalardan AYIRT EDILEBILIR olmali: daha uzun, siyaha yakin
   paltolu, kirmizi bantli sapkali. 'bakiyor' iken cepheden durur, elleri
   arkada — oyuncu tek bakista "su an beni izliyor" diyebilmeli. */
function drawGozcu(x, y, t, bakiyor, sorgu) {
  x = Math.round(x); y = Math.round(y);
  var PALTO = '#23262c', PALTO2 = '#191c21', ISIK = '#33373f';
  var TEN = '#c99a66', BANT = '#8e1c14', ROZET = '#c9a23a';
  var cephe = bakiyor || sorgu;
  var yon = (G.gozcu && G.gozcu.dir < 0) ? -1 : 1;

  ctx.globalAlpha = .26; ell(x, y, cephe ? 4 : 3, 1, '#000'); ctx.globalAlpha = 1;

  /* bacaklar (4px) */
  if (cephe) {
    fr(x - 2, y - 4, 2, 4, PALTO2);
    fr(x + 1, y - 4, 2, 4, PALTO2);
    px(x - 3, y - 1, '#0b0d10'); px(x + 3, y - 1, '#0b0d10');
  } else {
    var ph = Math.floor((t * 6.0) % 8);
    var FRG = [[2, -2], [1, -1], [0, 0], [-1, 1], [-2, 2], [-1, 1], [0, 0], [1, -1]][ph];
    fr(x + FRG[1] - 1, y - 4, 2, 4, PALTO2);
    fr(x + FRG[0] - 1, y - 4, 2, 4, ISIK);
    px(x + FRG[1] - 1 + (FRG[1] < 0 ? -1 : 1), y - 1, '#0b0d10');
    px(x + FRG[0] - 1 + (FRG[0] > 0 ? 1 : -1), y - 1, '#0b0d10');
  }

  /* palto: cepheden genis, profilde dar — durus farki siluetten okunsun */
  var gw2 = cephe ? 7 : 5;
  var gx2 = x - (cephe ? 3 : 2);
  var gy = y - 10;
  fr(gx2, gy, gw2, 6, PALTO);
  hl(gx2, gy, gw2, ISIK);
  fr(gx2, gy + 4, gw2, 1, '#0e1013');            /* kemer */
  if (cephe) {
    px(x, gy + 1, PALTO2);
    px(x + 1, gy + 4, ROZET);
    px(gx2, gy, ROZET); px(gx2 + gw2 - 1, gy, ROZET);   /* apolet */
  } else {
    px(gx2 + (yon > 0 ? gw2 - 1 : 0), gy + 1, PALTO2);
  }

  /* kollar */
  if (bakiyor) {
    px(gx2 - 1, gy + 2, PALTO2); px(gx2 + gw2, gy + 2, PALTO2);
  } else if (sorgu) {
    fr(x + 3, gy + 2, 3, 1, PALTO2);
    px(x + 6, gy + 2, TEN);
  } else {
    var ka = Math.round(Math.sin(t * 6.0));
    px(x + (yon > 0 ? 2 : -3), gy + 2 + ka, PALTO2);
  }

  /* bas (3px) */
  var hy = y - 13;
  fr(x - 1, hy, 3, 3, TEN);
  if (cephe) { px(x - 1, hy + 1, '#14161a'); px(x + 1, hy + 1, '#14161a'); }
  else { px(x + (yon > 0 ? 1 : -1), hy + 1, '#14161a'); }

  /* kasket: kubbe + kirmizi bant + siperlik */
  fr(x - 2, hy - 2, 5, 2, PALTO2);
  hl(x - 2, hy - 2, 5, ISIK);
  fr(x - 2, hy, 5, 1, BANT);
  px(x, hy - 1, ROZET);
  if (cephe) fr(x - 3, hy + 1, 7, 1, '#0b0d10');
  else fr(yon > 0 ? x + 1 : x - 3, hy + 1, 3, 1, '#0b0d10');

  /* Sorguda basinin ustunde unlem */
  if (sorgu) {
    var uy = y - 22 + Math.round(Math.sin(t * 9));
    fr(x, uy, 1, 3, '#e2483a');
    px(x, uy + 4, '#e2483a');
    ctx.globalAlpha = .3; disc(x, uy + 2, 4, '#e2483a'); ctx.globalAlpha = 1;
  }
  /* Bakarken kasket rozeti parlar */
  if (bakiyor) {
    ctx.globalAlpha = .45 + .45 * Math.sin(t * 7);
    px(x, hy - 1, '#fff3c0');
    ctx.globalAlpha = 1;
  }
}

/* Demirkent devriyesi: karsi kaldirimda yuruyen asker.
   Gozcuden farkli — o cami izler, bunlar sadece gecerler. Silueti
   sivilden ayiran sey: migfer, omuzdaki tufek ve kilitli adim. */
function drawAsker(x, y, t, dir, faz) {
  x = Math.round(x); y = Math.round(y);
  var UNI = '#4a5148', UNI2 = '#39403a', MIG = '#3a423c', TEN = '#c99a66';
  var yon = dir > 0 ? 1 : -1;
  ctx.globalAlpha = .24; ell(x, y, 3, 1, '#000'); ctx.globalAlpha = 1;

  /* Adimlar devriyede KILITLI: iki asker ayni fazda yurur. */
  var ph = Math.floor((t * 5.4 + faz) % 8);
  var FR = [[2, -2], [1, -1], [0, 0], [-1, 1], [-2, 2], [-1, 1], [0, 0], [1, -1]][ph];

  /* bacaklar (yaya olcegi: 4px) */
  fr(x + FR[1] - 1, y - 4, 2, 4, UNI2);
  fr(x + FR[0] - 1, y - 4, 2, 4, UNI);
  px(x + FR[1] - 1 + (FR[1] < 0 ? -1 : 1), y - 1, '#20241f');
  px(x + FR[0] - 1 + (FR[0] > 0 ? 1 : -1), y - 1, '#1a1e19');

  /* govde (5px) */
  var gy = y - 9;
  fr(x - 2, gy, 5, 5, UNI);
  hl(x - 2, gy, 5, '#5c6459');
  fr(x - 2, gy + 3, 5, 1, '#20241f');            /* kemer */

  /* kol */
  var ka = Math.round(Math.sin(t * 5.4 + faz));
  fr(x + (yon > 0 ? 3 : -3), gy + 1 + ka, 1, 3, UNI2);

  /* sirttan capraz tufek — kisa */
  var tx0 = x - yon * 2;
  for (var i = 0; i < 6; i++) px(tx0 + yon * Math.round(i * .5), gy - 2 + i, '#2a2620');

  /* bas (3px) */
  var hy = y - 12;
  fr(x - 1, hy, 3, 3, TEN);
  px(x - 2, hy + 1, TEN); px(x + 2, hy + 1, TEN);
  px(x + (yon > 0 ? 1 : -1), hy + 1, '#14161a');
  /* migfer: kubbe + ense siperi */
  fr(x - 2, hy - 1, 5, 1, MIG);
  fr(x - 1, hy - 2, 3, 1, MIG);
  px(x - yon * 3, hy, MIG);
}

/* --- yayalar: kaldirimda yurur, isik kirmiziyken karsidan karsiya gecer --- */
var WALKERS = [
  { sp: 7.0, off: .10, k: 0, dir: 1 },
  { sp: 5.8, off: .58, k: 1, dir: -1 },
  { sp: 8.2, off: .34, k: 2, dir: 1 },
  { sp: 6.6, off: .80, k: 5, dir: -1 },
  { sp: 6.2, off: .22, k: 7, dir: 1 },
  { sp: 7.6, off: .68, k: 9, dir: -1 }
];
/* gecitten karsiya gecen yayalar */
var CROSSERS = [
  { k: 3, p: 0, hiz: 15, bekle: 0, git: 0, kay: 0 },
  { k: 8, p: 0, hiz: 13, bekle: 1.4, git: 0, kay: 0 }
];
function updateCrossers(dt) {
  var gecebilir = TLIGHT.state === 'red';
  for (var i = 0; i < CROSSERS.length; i++) {
    var cr = CROSSERS[i];
    /* HATA: karsi kaldirima varinca p sifirlaniyordu; cizim p<=0 olani
       atladigi icin yaya tam kaldirima basarken bir anda yok oluyordu.
       Artik kaldirima cikip yurumeye devam eder, camin sag kenarindan
       cikinca gorunmez olur; ancak ondan sonra basa alinir. */
    if (cr.git > 0) {
      cr.git -= dt;
      cr.kay += dt * 30;
      if (cr.git <= 0) { cr.p = 0; cr.kay = 0; cr.git = 0; cr.yon = -(cr.yon || 1); cr.bekle = 4 + i * 3; }
    } else if (cr.p > 0 && cr.p < 1) {
      cr.p += (cr.hiz * dt) / 30;
      if (cr.p >= 1) { cr.p = 1; cr.git = 3.4; }      /* vardi: kaldirimda uzaklas */
    } else if (gecebilir) {
      if (cr.bekle > 0) cr.bekle -= dt;
      else { cr.p = 0.001; cr.bekle = 3 + i * 2.5; }
    }
  }
}

var _carSnd = [0, 0, 0, 0, 0, 0];

function drawStreet(t, dayK, rainOn, courier) {
  var M = stM(), gx = M.gx, gy = M.gy, gw = M.gw, gh = M.gh;
  ctx.save();
  ctx.beginPath(); ctx.rect(gx, gy, gw, gh); ctx.clip();

  if (dayK > 0.001) {
    ctx.globalAlpha = Math.min(.40, dayK * .40);
    fr(gx, gy, gw, gh, '#ff8a3a');
    ctx.globalAlpha = Math.min(.20, dayK * .20);
    fr(gx, gy, gw, gh, '#3a2a5a');
    ctx.globalAlpha = 1;
  }
  if (rainOn) { ctx.globalAlpha = .24; fr(gx, gy, gw, gh, '#2a4a7a'); ctx.globalAlpha = 1; }
  /* KAR: sokak solgunlasir, gokyuzu kursuni. SICAK: her sey sararir. */
  if (typeof isKar === 'function' && isKar()) {
    ctx.globalAlpha = .20; fr(gx, gy, gw, gh, '#b8cde4'); ctx.globalAlpha = 1;
  } else if (typeof isSicak === 'function' && isSicak()) {
    ctx.globalAlpha = .16; fr(gx, gy, gw, gh, '#ffb64a'); ctx.globalAlpha = 1;
  }

  drawStreetProps(t, dayK > .35 || rainOn);

  /* --- SICAK: asfaltta yukselen sicak hava titremesi ---
     Yolun uzerinde yatay, kayan acik seritler. Ucuz ama sicagi
     aninda okutuyor; sokakta baska isaret yoktu. */
  if (typeof isSicak === 'function' && isSicak()) {
    ctx.globalAlpha = .13;
    for (var hs = 0; hs < 7; hs++) {
      var hy = M.roadY + 3 + hs * Math.max(2, (M.roadH - 6) / 7);
      var kay = Math.sin(t * 1.7 + hs * 1.3) * 7;
      hl(Math.round(gx + 10 + kay), Math.round(hy), gw - 26, '#fff0c0');
    }
    ctx.globalAlpha = 1;
  }

  /* --- gökyüzünde kuşlar (yağmurda uçmazlar) --- */
  if (!rainOn) {
    for (var bi2 = 0; bi2 < 5; bi2++) {
      var bsp = 11 + (bi2 % 3) * 4;
      var bu = ((t * bsp / (gw + 60)) + bi2 * .23) % 1;
      var bx2 = gx - 20 + bu * (gw + 40);
      var by2 = gy + 6 + Math.sin(t * 1.4 + bi2 * 2.1) * 3 + (bi2 % 3) * 5;
      var kanat = Math.sin(t * 9 + bi2 * 1.7) > 0 ? 1 : -1;
      ctx.globalAlpha = .55;
      px(bx2, by2, '#4a5560');
      px(bx2 - 1, by2 - kanat, '#4a5560');
      px(bx2 + 1, by2 - kanat, '#4a5560');
      ctx.globalAlpha = 1;
    }
  }

  var span = gw + 110;
  /* yayalar (karşı kaldırım) */
  /* Demirkent: yayalarin bir kismi ASKER. Devriye ikili gider, adimlari
     kilitli — sokak "gezilen" degil "devriye gezilen" bir yer olsun. */
  var devriye = (typeof G !== 'undefined') && G.ferman && fermanSehri(G);
  for (var wi = 0; wi < WALKERS.length; wi++) {
    var wk = WALKERS[wi];
    var uw = ((t * wk.sp / span) + wk.off) % 1;
    var wx = wk.dir > 0 ? gx - 24 + uw * span : gx + gw + 24 - uw * span;
    if (devriye && (wi === 1 || wi === 3)) {
      /* ikili devriye: ikinci asker birincinin 7px gerisinde, ayni fazda */
      drawAsker(wx, M.walkY, t, wk.dir, 0);
      drawAsker(wx - wk.dir * 7, M.walkY, t, wk.dir, 0);
    } else {
      drawPed(wx, M.walkY, wk.k, wk.dir, t, 1, rainOn && (wk.k % 2 === 0));
    }
  }
  /* araçlar: konumları updateTraffic() tutar, burada sadece çizilir.
     Taban çizgisine göre arkadan öne sıralanır. */
  var laneY = [M.farY, M.nearY];
  var actors = [];
  trafGerek();
  for (var i = 0; i < TRAF.length; i++) {
    (function (cr) {
      var sc = cr.lane ? 1 : .86;
      var cx0 = trafX(cr, M);
      var duruyor = cr.v < 3;
      actors.push({
        y: laneY[cr.lane],
        f: function () { drawVehicle(cx0, laneY[cr.lane], sc, cr.ty, cr.ci, cr.dir, t, duruyor); }
      });
    })(TRAF[i]);
  }
  /* --- park etmiş binekler: trafikle AYNI listede.
     Sokak mobilyasi katmaninda cizilince her araba karavanin
     ustunden geciyordu; burada taban cizgisine gore siralaniyor. --- */
  var PK = parkedKalip();
  updateBinek(t, PK);
  if (KAR.faz !== 'yok') {
    (function () {
      /* Park etmis arac kaldirima yanasir: taban cizgisi akan seritten
         3px ONDE. Ayni cizgide birakinca siralama esitlenip trafik
         karavanin ustunden geciyordu. */
      var ky = M.nearY + 3, pkx = gx + gw - 70;
      var kx = pkx, kklip = 'idle', ku, khiz = 0, kyuru = -1, kbin = false;
      var v;
      if (KAR.faz === 'gelis') {
        /* fren yapan bir arac gibi YAVASLAYARAK gelir, duz kaymaz */
        v = clamp(KAR.t / KAR_SURE.gelis, 0, 1);
        var ge = 1 - (1 - v) * (1 - v) * (1 - v);
        kx = Math.round(pkx + (gx + gw + 90 - pkx) * (1 - ge));
        kklip = 'drive'; khiz = 1 - ge;
      } else if (KAR.faz === 'kapiAc' || KAR.faz === 'kapiAc2') {
        kklip = 'door_open';
        ku = clamp(KAR.t / KAR_SURE[KAR.faz], 0, 1);
      } else if (KAR.faz === 'kapiKapa' || KAR.faz === 'kapiKapa2') {
        kklip = 'door_close';
        ku = clamp(KAR.t / KAR_SURE[KAR.faz], 0, 1);
      } else if (KAR.faz === 'iner') {
        /* kapi ACIK kalir; kimyager kapidan cikip GIRISE dogru yurur */
        kklip = 'door_open'; ku = 1;
        v = clamp(KAR.t / KAR_SURE.iner, 0, 1);
        /* %80'de kaybolur: binekBekle musteriyi tam o anda birakiyor,
           yoksa ayni kisi hem sokakta hem dukkanda gorunur */
        if (v < .80) kyuru = v / .80;
      } else if (KAR.faz === 'biner') {
        kklip = 'door_open'; ku = 1;
        v = clamp(KAR.t / KAR_SURE.biner, 0, 1);
        if (v < .80) kyuru = 1 - v / .80; else kbin = true;
      } else if (KAR.faz === 'gidis') {
        /* geldigi yonde DEVAM eder: geri geri gitmez */
        v = clamp(KAR.t / KAR_SURE.gidis, 0, 1);
        kx = Math.round(pkx - (pkx - gx + 130) * v * v);
        kklip = 'drive'; khiz = 1;
      }
      actors.push({
        y: ky,
        f: function () {
          /* Atlas SAGA bakiyor; karavan sagdan gelip sola park ettigi
             icin aynalaniyor. */
          var kmerkez = kx + 31;
          var kok = sprCiz('karavan', kklip, t, kmerkez, ky, { mini: true, flip: true, u: ku });
          if (!kok) {
            ctx.save();                       /* yedek: eski cizim */
            ctx.translate(kmerkez * 2, 0); ctx.scale(-1, 1);
            drawKaravan(kx, ky, t, khiz);
            ctx.restore();
          }
          if (kyuru >= 0) {
            /* Kapidan cikip SAG kemere (dukkan girisine) yurur.
               Musteri dukkana sagdan giriyor; sola yurutunce ayni kisi
               solda kaybolup sagda beliriyordu. */
            var kap = kok ? sprSoket('karavan', 'doorFoot', kmerkez, ky, true, true)
                          : { x: kmerkez, y: ky };
            var hx2 = gx + gw + 12;
            var wx = Math.round(kap.x + kyuru * (hx2 - kap.x));
            sprCiz('kimyager', 'walk_side', t, wx, ky + 1, { mini: true });
          } else if (kbin) {
            /* kapinin onunde duruyor, birazdan biniyor */
            var kap2 = kok ? sprSoket('karavan', 'doorFoot', kmerkez, ky, true, true)
                           : { x: kmerkez, y: ky };
            sprCiz('kimyager', 'idle', t, kap2.x, ky + 1, { mini: true, flip: true });
          }
        }
      });
    })();
  }
  /* --- EJDERHA: uc, kon, binici in / bin, havalan --- */
  if (EJD.faz !== 'yok') {
    (function () {
      var pX = gx + Math.round(gw * .60), pY = M.farY + 2;
      var ex = pX, ey = pY, ucus = false, inis = 1, bin = -1, byuru = 0;
      var u;
      if (EJD.faz === 'ucus') {
        u = clamp(EJD.t / EJD_SURE.ucus, 0, 1);
        var eu = 1 - (1 - u) * (1 - u);               /* yavaslayarak iner */
        ex = Math.round(gx + gw + 90 + (pX - gx - gw - 90) * eu);
        ey = Math.round(pY - 84 * (1 - eu));
        ucus = true; inis = eu; bin = 0;
      } else if (EJD.faz === 'inis') {
        inis = 1 - clamp(EJD.t / EJD_SURE.inis, 0, 1) * .001; bin = 0;
      } else if (EJD.faz === 'iner') {
        u = clamp(EJD.t / EJD_SURE.iner, 0, 1);
        /* binici once kayarak iner, sonra sola yurur.
           %80'de KAYBOLUR: binekBekle musteriyi tam o anda birakiyor,
           yoksa ayni kisi 0.3 saniye hem sokakta hem dukkanda duruyor. */
        bin = u < .30 ? 0 : (u < .80 ? 1 : -1);
        byuru = u < .30 ? 0 : (u - .30) / .70;
      } else if (EJD.faz === 'biner') {
        u = clamp(EJD.t / EJD_SURE.biner, 0, 1);
        bin = u > .70 ? 0 : 1;
        byuru = u > .70 ? 0 : 1 - u / .70;
      } else if (EJD.faz === 'kalkis') {
        u = clamp(EJD.t / EJD_SURE.kalkis, 0, 1);
        var ku = u * u;                                /* hizlanarak kalkar */
        ex = Math.round(pX - (pX - gx + 110) * ku);
        ey = Math.round(pY - 96 * ku);
        ucus = true; inis = 1 - ku; bin = 0;
      }
      actors.push({
        y: EJD.faz === 'bekle' || EJD.faz === 'iner' || EJD.faz === 'biner'
           ? pY : pY - 1,
        f: function () {
          /* Atlas saga bakiyor; ejderha sagdan gelip sola konuyor,
             kalkarken de sola gidiyor - her iki halde aynalanir. */
          var klip = 'idle', u;
          if (EJD.faz === 'ucus') klip = 'fly';
          else if (EJD.faz === 'inis') { klip = 'land'; u = clamp(EJD.t / EJD_SURE.inis, 0, 1); }
          else if (EJD.faz === 'kalkis') { klip = 'takeoff'; u = clamp(EJD.t / EJD_SURE.kalkis, 0, 1); }
          /* Ejderha TAM boyda (117x87): mini olcekte sokakta koyu bir
             leke gibi duruyordu. Uzak seritteki yaya 16 piksel; ejderha
             bir insanin bes kati - ejderha zaten oyle. Binici ise mini,
             yoksa ejderha kadar buyuk olurdu. */
          var ejdOk = sprCiz('ejderha', klip, t, ex, ey, { flip: true, u: u });
          if (!ejdOk) drawEjderha(ex, ey, t, inis, ucus);
          if (bin === 0) {
            /* Binici SIRTTA. Paketteki 'ride' pozu ayakta duran bir poz;
               bacaklar sirt cizgisinde kesilerek oturmus gibi okunuyor. */
            var st = ejdOk && sprSoket('ejderha', 'riderSeat', ex, ey, false, true);
            if (!(st && sprCiz('kralice', 'ride', t, st.x, st.y + 10,
                               { mini: true, flip: true, kesAlt: st.y + 2 })))
              drawKraliceMini(ex - 4, ey - 21, t, false, true);
          } else if (bin === 1) {
            /* Binici yerde: ejderhadan SAG kemere (dukkan girisine)
               yurur. Eskiden sola yuruyup pencerenin solunda
               kayboluyordu, sonra musteri sagdan (x = W+24) giriyordu -
               ayni kisi solda kaybolup sagda beliriyordu. */
            var gcx = ex + 14, ghx = gx + gw + 16;
            var bx = Math.round(gcx + byuru * (ghx - gcx));
            if (!sprCiz('kralice', 'walk_side', t, bx, pY + 2, { mini: true }))
              drawKraliceMini(bx, pY + 2, t, true, false);
          }
        }
      });
    })();
  }
  /* --- SUPURGE: cirak UZERINDE gelir, iner, park eder --- */
  if (SUP.faz !== 'yok') {
    (function () {
      var sX = gx + Math.round(gw * .30), sY = M.curb2 + 2;
      var sx2 = sX, sp = 1, sbin = false, syuru = -1, u2;
      if (SUP.faz === 'ucus') {
        u2 = clamp(SUP.t / SUP_SURE.ucus, 0, 1);
        var se = 1 - (1 - u2) * (1 - u2);
        sx2 = Math.round(gx + gw + 34 + (sX - gx - gw - 34) * se);
        sp = se; sbin = true;
      } else if (SUP.faz === 'iner') {
        u2 = clamp(SUP.t / SUP_SURE.iner, 0, 1);
        sbin = u2 < .30;
        /* %80'de kaybolur: musteri tam o anda dukkana giriyor */
        if (u2 >= .30 && u2 < .80) syuru = (u2 - .30) / .70;
      } else if (SUP.faz === 'biner') {
        u2 = clamp(SUP.t / SUP_SURE.biner, 0, 1);
        sbin = u2 > .70;
        if (u2 <= .70) syuru = 1 - u2 / .70;
      } else if (SUP.faz === 'kalkis') {
        var ku2 = clamp(SUP.t / SUP_SURE.kalkis, 0, 1);
        sx2 = Math.round(sX + (gx + gw + 44 - sX) * (ku2 * ku2));
        sp = 1 - ku2 * .35; sbin = true;
      }
      actors.push({
        y: M.curb2 + 1,
        f: function () {
          /* Kalkista SAGA gidiyor, gelis ve inis SOLA. */
          var sag = SUP.faz === 'kalkis';
          var sklip = 'idle', su;
          if (SUP.faz === 'ucus' || SUP.faz === 'kalkis') sklip = 'fly';
          else if (SUP.faz === 'iner') { sklip = 'land'; su = clamp(SUP.t / SUP_SURE.iner, 0, 1); }
          else if (SUP.faz === 'biner') { sklip = 'land'; su = 1 - clamp(SUP.t / SUP_SURE.biner, 0, 1); }
          /* SIRA ONEMLI: once binici, sonra supurge. Sopa ciragin
             kalcasinin ONUNDEN geciyor, bacaklari asagi sarkiyor -
             supurgeye binmis gibi okunuyor. Kirpma denendi, havada
             oturan bir govde gibi duruyordu. */
          var ss = sbin && sprVar('supurge', true)
                 ? sprSoket('supurge', 'riderSeat', sx2, sY, true, !sag) : null;
          if (ss) sprCiz('cirak', 'ride', t, ss.x, ss.y + 12,
                         { mini: true, flip: !sag });
          var supOk = sprCiz('supurge', sklip, t, sx2, sY, { mini: true, flip: !sag, u: su });
          if (!supOk) drawSupurge(sx2, sY, sp, sbin);
          if (syuru >= 0) {
            /* cirak da SAG kemere yurur - musteri oradan giriyor */
            var scx = sx2 + 10, shx = gx + gw + 16;
            var cbx = Math.round(scx + syuru * (shx - scx));
            if (!sprCiz('cirak', 'walk_side', t, cbx, sY + 2, { mini: true }))
              drawCirakMini(cbx, sY + 2, t, false, true);
          }
        }
      });
    })();
  }

  /* geçitten karşıya geçen yayalar */  /* geçitten karşıya geçen yayalar */
  for (var ci2 = 0; ci2 < CROSSERS.length; ci2++) {
    (function (cr) {
      if (cr.p <= 0 && cr.git <= 0) return;
      var yon = cr.yon || 1;
      var pp = yon > 0 ? cr.p : 1 - cr.p;
      var cy3 = M.walkY + pp * (M.curb2 - M.walkY);
      /* karsiya vardiktan sonra kaldirim boyunca saga yurur */
      var cx4 = gx + 200 + (cr.k % 3) * 6 + cr.kay;
      var bak = cr.git > 0 ? 1 : yon;
      actors.push({
        y: cy3,
        f: function () { drawPed(cx4, cy3, cr.k, bak, t, 1, rainOn); }
      });
    })(CROSSERS[ci2]);
  }
  /* kurye: şeritlerin arasından (motosiklet gibi) geçer */
  if (courier && courier.out > 0) {
    (function () {
      var cu = clamp(courier.out, 0, 1);
      var cy2 = M.farY + 6;
      var sx3 = courier.dir > 0 ? gx - 34 + cu * (gw + 68) : gx + gw + 34 - cu * (gw + 68);
      actors.push({
        y: cy2,
        f: function () {
          ctx.save();
          if (courier.dir < 0) { ctx.translate(Math.round(sx3) * 2, 0); ctx.scale(-1, 1); }
          drawScooter(Math.round(sx3), cy2 - 8, t, .8);
          ctx.restore();
        }
      });
    })();
  }
  /* --- sokak kedisi: yakin kaldirimda --- */
  if (typeof G !== 'undefined' && G.kedi && G.kedi.faz !== 'yok') {
    actors.push({ y: M.curb2 + 2, f: function () { drawKedi(t); } });
  }
  /* --- Demirkent gozcusu: BIZIM taraftaki kaldirimda, en onde --- */
  if (typeof G !== 'undefined' && G.gozcu && G.ferman && !G.ferman.kapandi) {
    (function (Z) {
      actors.push({
        y: M.curb2 + 1,
        f: function () {
          drawGozcu(Z.x, M.curb2, t, Z.state === 'bak', Z.state === 'sorgu');
        }
      });
    })(G.gozcu);
  }
  actors.sort(function (a, b) { return a.y - b.y; });
  for (var aI = 0; aI < actors.length; aI++) actors[aI].f();
  drawNearProps(t);
  /* --- DEMIRKENT: sokagin rengi cekilir ---
     'saturation' karisim kipi arka planin acikligini korur, doygunlugunu
     gri kaynaktan alir. Kirmizi afisler ve gozcunun bandi bu orandan sonra
     hala kirmizi kalir; geri kalan her sey kursuniye doner. */
  if (betonSehir()) {
    var eskiKip = ctx.globalCompositeOperation;
    ctx.globalCompositeOperation = 'saturation';
    ctx.globalAlpha = .72; fr(gx, gy, gw, gh, '#808080'); ctx.globalAlpha = 1;
    ctx.globalCompositeOperation = eskiKip;
    /* uzeri hafif kursuni pus: mesafe ve soguk hava */
    ctx.globalAlpha = .10; fr(gx, gy, gw, gh, '#9aa0a8'); ctx.globalAlpha = 1;
  }
  /* --- yağmur: SOKAKTA yağar, camın içinde kalır --- */
  if (rainOn) {
    /* 1) eğik yağmur çizgileri: rüzgârla hafif yatık */
    for (var d = 0; d < 40; d++) {
      var hz = 150 + hash1(d * 1.7) * 190;                 /* düşme hızı */
      var dx0 = gx + ((hash1(d * 3.3) * gw + t * 26) % gw);
      var dy0 = gy + ((hash1(d * 7.9) * gh + t * hz) % gh);
      var boy = 4 + (d % 5);
      var yak = hash1(d * 5.1);                            /* yakın olan daha belirgin */
      ctx.globalAlpha = .16 + yak * .26;
      /* eğim: 1px sola kayarak düşer */
      for (var q = 0; q < boy; q++) {
        px(Math.round(dx0 - q * .32), Math.round(dy0 + q), yak > .6 ? '#eaf6ff' : '#bcd8e8');
      }
      ctx.globalAlpha = 1;
    }

    /* 2) zemine çarpma: yolda ve kaldırımda sıçrayan halkalar */
    for (var sp = 0; sp < 14; sp++) {
      var faz = (t * 1.9 + hash1(sp * 2.3) * 5) % 1;       /* 0..1 döngü */
      var sx0 = gx + hash1(sp * 4.7) * gw;
      var sy0 = M.roadY + hash1(sp * 8.1) * (M.curb2 - M.roadY);
      ctx.globalAlpha = (1 - faz) * .34;
      var rr = Math.round(1 + faz * 3);
      ring(Math.round(sx0), Math.round(sy0), rr, '#cfe4f2');
      if (faz < .35) px(Math.round(sx0), Math.round(sy0) - 1, '#ffffff');
      ctx.globalAlpha = 1;
    }

    /* 3) ıslak asfalt: yolda titreşen yansımalar */
    ctx.globalAlpha = .12;
    for (var wr = 0; wr < 8; wr++) {
      var wx = gx + hash1(wr * 6.1) * (gw - 14);
      var wy = M.roadY + 4 + hash1(wr * 3.9) * (M.roadH - 8);
      var ww = 6 + Math.round(Math.sin(t * 3 + wr) * 2) + (wr % 4) * 3;
      hl(Math.round(wx), Math.round(wy), ww, '#8fb8d0');
    }
    ctx.globalAlpha = 1;

    /* 4) camın kendi damlaları: birikip süzülenler */
    if (typeof drawCamDamla === 'function') drawCamDamla(t);
  }
  /* Kar YAGMURDAN BAGIMSIZ: bu blok `if (rainOn)` icine dusersse
     karli gunde hic cizilmez. Cam kirpmasinin icinde kalmali ki
     taneler dukkanin icine tasmasin. */
  if (typeof drawKar === 'function') drawKar(t);
  ctx.restore();

  if (!WINOVER) bakeWinOver();
  ctx.drawImage(WINOVER.c, LAY.win.x - WINOVER.ox, LAY.win.y - WINOVER.oy);
}

/* ---------- arka plan pişirme ---------- */
var BG = null, BGDECOR = 0;
/* Dayi dukkanda duruyor mu? Durmuyorsa solda ona ayrilan bosluk
   sahipsiz kaliyor; tas duvar oraya sokulup boslugu kapatir.
   TEK KAYNAK: hem tasin yerini hem Dayinin cizilip cizilmedigini
   bu belirler, ikisi asla ayri dusmesin. */
function dayiVar() {
  if (typeof G === 'undefined' || !G) return false;
  /* baslik ekraninda dukkanin tanitim goruntusu var: Dayi hep orada */
  if (G.scene === 'title') return true;
  return !!(typeof TUN !== 'undefined' && G.up && TUN.uncleUses(G) > 0);
}
/* Beyaz tas duvarin sag siniri.
   Dayi yokken tas tezgaha (CX0=44) kadar sokulur; bosluk kapanir.
   Dayi acilinca geri cekilir, cunku o bosluga Dayi gelip duracak. */
function archL(y) {
  var q = Math.floor(y / 11);
  if (dayiVar()) return 14 + Math.floor(hash1(q * 3.7) * 7) + Math.round(6 * Math.sin(y * 0.013 + 1.2));
  return 40 + Math.floor(hash1(q * 3.7) * 4) + Math.round(2 * Math.sin(y * 0.013 + 1.2));
}
function archR(y) {
  var q = Math.floor(y / 11);
  return W - (28 + Math.floor(hash1(q * 5.1 + 40) * 9) + Math.round(10 * Math.sin(y * 0.011 + .4)));
}
/* Tas duvarlarin ON KATMANI.
   BG'ye pisen ayni pikseller seffaf bir katmana kopyalanir; musteriler
   cizildikten SONRA basilinca musteri tasin arkasina girmis olur.
   Boylece dukkandan cikan musteri tezgahin onunde yarim govdeyle
   kalmaz, tasin arkasinda kaybolur. */
var STONEFG = null;
function bakeStoneFG() {
  if (!BG) return;
  var c = document.createElement('canvas'); c.width = W; c.height = H;
  var g = c.getContext('2d');
  for (var y = 0; y < H; y++) {
    var eL = archL(y);
    if (eL > 0) g.drawImage(BG, 0, y, eL, 1, 0, y, eL, 1);
    var eR = archR(y);
    if (eR < W) g.drawImage(BG, eR, y, W - eR, 1, eR, y, W - eR, 1);
  }
  STONEFG = c;
}
function drawStoneFG() {
  if (!STONEFG) bakeStoneFG();
  if (STONEFG) ctx.drawImage(STONEFG, 0, 0);
}
var BGDAYI = null;
/* Arka plan yalniz boya degisince degil, Dayi ise girince de
   yeniden pisirilmeli: tas duvarin sag siniri kayiyor. */
var BGCITY = null;
/* Rakip cephesi arka planin PARCASI: insaat -> acik -> kapali
   gecisleri sokagin yeniden pismesini gerektiriyor. */
var BGRAKIP = null;
function bgBayat() {
  return !BG || BGDECOR !== UV(G, 'paint') || BGDAYI !== dayiVar() ||
         BGCITY !== G.city || BGRAKIP !== rakipCepheDurum();
}
function bakeBG(decor) {
  BGDECOR = decor || 0;
  BGDAYI = dayiVar();
  BGCITY = G.city;
  BGRAKIP = rakipCepheDurum();
  var c = document.createElement('canvas'); c.width = W; c.height = H;
  var g = c.getContext('2d');
  var oldctx = ctx; ctx = g;

  /* ---- fayans duvar ---- */
  var TEMA = sehirTema();
  var wallCols = duvarPaleti(TEMA, decor);
  /* taş duvar da boyayla değişir (eskiden sabitti) */
  var TASP = tasPaleti(TEMA, decor);
  fr(0, 0, W, LAY.floorY + 12, wallCols[3]);
  var TS = 18;
  for (var ty = -8; ty < LAY.floorY + 4; ty += TS) {
    for (var tx = 0; tx < W; tx += TS) {
      var hsh = hash1(tx * 0.37 + ty * 1.13);
      var base = hsh < .18 ? wallCols[0] : (hsh < .62 ? wallCols[1] : wallCols[2]);
      fr(tx + 1, ty + 1, TS - 1, TS - 1, base);
      hl(tx + 1, ty + 1, TS - 1, hsh < .18 ? '#8dc4dc' : wallCols[0]);
      vl(tx + 1, ty + 1, TS - 1, hsh < .5 ? wallCols[0] : base);
      hl(tx + 1, ty + TS - 1, TS - 1, wallCols[3]);
      /* kırık fayans */
      if (hash1(tx * 2.7 + ty * 0.91) > .955) {
        var bw = 5 + Math.floor(hash1(tx + ty) * 6), bh = 4 + Math.floor(hash1(tx * 2 + ty) * 5);
        var bx = tx + 3 + Math.floor(hash1(tx * .5 + ty) * 6), by = ty + 3 + Math.floor(hash1(ty * .5 + tx) * 6);
        fr(bx, by, bw, bh, '#3c2a24');
        fr(bx + 1, by + 1, bw - 2, bh - 2, '#2a1c18');
        hl(bx, by + bh, bw, wallCols[0]);
      }
    }
  }
  /* üstten gelen ışık */
  for (var y = 0; y < LAY.floorY; y++) {
    var a = Math.max(0, .20 - y * .0016);
    if (a > .004) { ctx.globalAlpha = a; fr(0, y, W, 1, '#ffffff'); }
  }
  ctx.globalAlpha = 1;
  /* köşe karartma */
  for (var y2 = 0; y2 < LAY.floorY; y2++) {
    ctx.globalAlpha = .16; fr(0, y2, 40, 1, '#000'); fr(W - 40, y2, 40, 1, '#000');
  }
  ctx.globalAlpha = 1;

  /* ---- vitrin: sokak manzarası ---- */
  bakeStreet();

  /* ---- taş kemer ---- */
  function stoneBand(side) {
    for (var y = 0; y < LAY.floorY + 12; y++) {
      var edge = side < 0 ? archL(y) : archR(y);
      var x0 = side < 0 ? 0 : edge, x1 = side < 0 ? edge : W;
      for (var x = x0; x < x1; x++) {
        var row = Math.floor(y / 13);
        var off = (row & 1) ? 11 : 0;
        var col = Math.floor((x + off) / 23);
        var seamX = ((x + off) % 23) === 0;
        var seamY = (y % 13) === 0;
        var v = hash1(row * 7.3 + col * 3.1);
        var TS = TASP, c;
        if (seamX || seamY) c = TS[4];
        else if ((y % 13) < 2) c = TS[0];
        else if ((y % 13) > 10) c = TS[3];
        else c = v < .3 ? TS[0] : (v < .72 ? TS[1] : TS[2]);
        /* ufak benekler */
        if (hash1(x * 1.7 + y * 2.3) > .93) c = v < .5 ? TS[0] : TS[3];
        px(x, y, c);
      }
      /* iç kenar gölgesi */
      if (side < 0) { px(edge - 1, y, TASP[4]); px(edge - 2, y, TASP[3]); px(edge, y, 'rgba(0,0,0,.35)'); }
      else { px(edge, y, TASP[4]); px(edge + 1, y, TASP[3]); px(edge - 1, y, 'rgba(0,0,0,.35)'); }
    }
  }
  stoneBand(-1); stoneBand(1);

  /* ---- zemin: sehrin kendi dokusu ---- */
  var Z = TEMA.zemin, zy = LAY.floorY, zh = H - LAY.floorY;
  fr(0, zy, W, zh, Z[2]);
  if (TEMA.zeminTip === 'dama') {
    /* siyah-beyaz dama: metro/kosebasi hissi */
    for (var dx = -8; dx < W; dx += 16) {
      for (var dy = zy; dy < H; dy += 8) {
        var kare = ((dx / 16 | 0) + (dy / 8 | 0)) % 2;
        fr(dx, dy, 16, 8, kare ? Z[0] : Z[2]);
      }
    }
    ctx.globalAlpha = .18;
    for (var dl = zy; dl < H; dl += 8) hl(0, dl, W, Z[3]);
    ctx.globalAlpha = 1;
  } else if (TEMA.zeminTip === 'mermer') {
    /* buyuk mermer levhalar + damar */
    fr(0, zy, W, zh, Z[0]);
    for (var mx2 = -10; mx2 < W; mx2 += 38) {
      vl(mx2, zy, zh, Z[2]);
      ctx.globalAlpha = .30;
      for (var md = 0; md < 3; md++) {
        var vx = mx2 + 6 + md * 11;
        ln(vx, zy + 1, vx + 5 - md * 3, H - 1, Z[3]);
      }
      ctx.globalAlpha = 1;
    }
    hl(0, zy, W, Z[1]);
  } else if (TEMA.zeminTip === 'beton') {
    /* dokme beton: derz cizgileri + benek */
    fr(0, zy, W, zh, Z[1]);
    for (var bx2 = -4; bx2 < W; bx2 += 29) vl(bx2, zy, zh, Z[2]);
    for (var by2 = zy + 5; by2 < H; by2 += 7) { ctx.globalAlpha = .22; hl(0, by2, W, Z[3]); ctx.globalAlpha = 1; }
    for (var bs = 0; bs < 260; bs++) {
      var sx2 = Math.floor(hash1(bs * 3.7) * W), sy2 = zy + Math.floor(hash1(bs * 8.1) * zh);
      px(sx2, sy2, hash1(bs) > .5 ? Z[0] : Z[3]);
    }
  } else {
    /* ahsap: tahtalar ve damar */
    for (var fx = -6; fx < W; fx += 17) {
      var sxx = fx + (Math.floor(hash1(fx) * 4));
      vl(sxx, zy, zh, Z[3]);
      for (var fy = zy; fy < H; fy++) {
        if (hash1(sxx * 1.3 + fy * 2.1) > .8) px(sxx + 1 + Math.floor(hash1(fy) * 12), fy, Z[1]);
      }
    }
    hl(0, zy, W, Z[1]);
  }
  ctx.globalAlpha = .3; fr(0, LAY.floorY, W, 3, '#000'); ctx.globalAlpha = 1;

  ctx = oldctx;
  BG = c;
  bakeStoneFG();
  return c;
}

/* ---------- tezgâh ---------- */
function steelWell(x, y, w, h) {
  /* çelik gömme hazne */
  fr(x, y, w, h, P.mt4);
  fr(x + 2, y + 2, w - 4, h - 4, '#5a616a');
  fr(x + 3, y + 3, w - 6, h - 6, '#4c535b');
  hl(x, y, w, P.mt0);
  hl(x + 1, y + 1, w - 2, P.mt2);
  hl(x, y + h - 1, w, P.mt1);
  hl(x, y + h - 2, w, P.mt3);
  vl(x, y, h, P.mt2); vl(x + w - 1, y, h, P.mt3);
  /* iç gölge */
  ctx.globalAlpha = .30; fr(x + 3, y + 3, w - 6, 3, '#000'); ctx.globalAlpha = 1;
}
function rubberMat(x, y, w, h) {
  rrect(x, y, w, h, 3, '#2f3339');
  rrect(x + 1, y, w - 2, h - 2, 3, '#3d424a');
  for (var j = 3; j < h - 3; j += 4) for (var i = 3; i < w - 3; i += 4) {
    px(x + i + ((j / 4) & 1 ? 2 : 0), y + j, '#333840');
  }
  hl(x + 3, y, w - 6, '#4e545d');
  ctx.globalAlpha = .25; hl(x + 3, y + h - 1, w - 6, '#000'); ctx.globalAlpha = 1;
}
function shelfUnit(x, y, w, h) {
  fr(x, y, w, h, P.mt2);
  fr(x + 1, y + 1, w - 2, h - 2, P.mt1);
  hl(x, y, w, P.mt0);
  for (var i = 0; i < 40; i++) {
    ctx.globalAlpha = .09;
    hl(x + 3 + hash1(i * 3.7) * (w - 20), y + 3 + hash1(i * 1.3) * (h - 6), 6 + hash1(i) * 12, '#ffffff');
  }
  ctx.globalAlpha = 1;
  hl(x, y + h - 2, w, P.mt3);
  hl(x, y + h - 1, w, P.mt4);
}
var CX0 = 44;  /* tezgâhın sol ucu */
var CLAYER = null;
function bakeCounter() {
  var c = document.createElement('canvas'); c.width = W; c.height = H;
  var g = c.getContext('2d');
  var old = ctx; ctx = g;
  drawCounterRaw();
  drawCounterProps(0);
  ctx = old;
  CLAYER = c;
  return c;
}
function drawCounter() {
  if (!CLAYER) bakeCounter();
  ctx.drawImage(CLAYER, 0, 0);
}
var COUNTER_PAL = [
  { base: '#c3c9d0', hi: '#ffffff', lo: '#2f343b', lip: '#aeb5be', edge: '#f6f8fa' },
  { base: '#a8bccd', hi: '#e6f2fb', lo: '#26384a', lip: '#8fa6bb', edge: '#dceaf6' },
  { base: '#c9a271', hi: '#f6e2c0', lo: '#4a3520', lip: '#a5794a', edge: '#e8c99a' },
  { base: '#c99a6a', hi: '#ffdcae', lo: '#5a3a1e', lip: '#a87a44', edge: '#f0c88e' }
];
function drawCounterRaw() {
  var ly = LAY.ledgeY, lh = LAY.ledgeH, x0 = CX0;
  var CP = COUNTER_PAL[(G.custom && G.custom.counter) ? G.custom.counter % COUNTER_PAL.length : 0];
  /* --- arka raf (mermer) --- */
  fr(x0, ly, W - x0, lh, '#cbb68c');
  hl(x0, ly, W - x0, '#f6e8c4');
  hl(x0, ly + 1, W - x0, '#e9d6ab');
  hl(x0, ly + 2, W - x0, '#dcc79c');
  hl(x0, ly + lh - 3, W - x0, '#b79f74');
  hl(x0, ly + lh - 2, W - x0, '#96805a');
  hl(x0, ly + lh - 1, W - x0, '#6d5c40');
  for (var i = x0; i < W; i += 2) {
    var hh = hash1(i * .77);
    if (hh > .78) px(i, ly + 3 + Math.floor(hh * 4), '#bda579');
    if (hh < .10) px(i, ly + 4 + Math.floor(hh * 30) % 4, '#e6d4ad');
  }
  ctx.globalAlpha = .25; fr(x0, ly + lh, W - x0, 4, '#000'); ctx.globalAlpha = 1;

  /* --- çelik çalışma yüzeyi --- */
  var sy = LAY.surfY, sh = LAY.lipY - sy;
  fr(x0, sy, W - x0, sh, CP.base);
  for (var y = 0; y < sh; y++) {
    var tt = y / sh;
    var a = .16 * (1 - tt) - .10 * tt;
    ctx.globalAlpha = Math.abs(a);
    fr(x0, sy + y, W - x0, 1, a > 0 ? CP.hi : CP.lo);
  }
  ctx.globalAlpha = 1;
  for (var k = 0; k < 170; k++) {
    var yy = sy + Math.floor(hash1(k * 3.3) * sh);
    var xx = x0 + Math.floor(hash1(k * 7.7) * (W - x0));
    var ww = 5 + Math.floor(hash1(k * 1.9) * 30);
    ctx.globalAlpha = .11;
    hl(xx, yy, ww, hash1(k) > .5 ? '#ffffff' : '#6d747d');
  }
  ctx.globalAlpha = 1;
  hl(x0, sy, W - x0, CP.edge); hl(x0, sy + 1, W - x0, CP.lip);

  /* --- üniteler --- */
  steelWell(52, 163, 176, 38);
  steelWell(224, 158, 200, 40);
  rubberMat(88, 197, 128, 48);
  shelfUnit(214, 197, 210, 48);
  /* ekmek tezgâhı (ahşap blok) */
  rrect(44, 197, 44, 48, 3, '#7a5230');
  rrect(45, 197, 42, 46, 3, '#a5713f');
  for (var bb = 0; bb < 6; bb++) hl(47, 201 + bb * 7, 38, '#8f6236');
  hl(45, 197, 42, '#c08d55');

  /* --- ön dudak --- */
  var py = LAY.lipY;
  fr(x0, py, W - x0, LAY.floorY - py, CP.lip);
  hl(x0, py, W - x0, CP.edge);
  hl(x0, py + 1, W - x0, P.mt1);
  hl(x0, LAY.floorY - 3, W - x0, P.mt3);
  hl(x0, LAY.floorY - 2, W - x0, P.mt4);
  hl(x0, LAY.floorY - 1, W - x0, P.mt5);
  for (var k2 = 0; k2 < 46; k2++) {
    ctx.globalAlpha = .07; vl(x0 + Math.floor(hash1(k2 * 5.1) * (W - x0)), py + 2, LAY.floorY - py - 4, '#ffffff');
  }
  ctx.globalAlpha = 1;
  hl(x0, py + 4, W - x0, '#9aa2ab');

  /* --- sol uç: yuvarlak köşe (şeffaf kes) --- */
  var R = 8;
  for (var i2 = 0; i2 < R; i2++) {
    var d = R - Math.round(Math.sqrt(R * R - (R - i2 - 1) * (R - i2 - 1)));
    if (d > 0) {
      ctx.clearRect(x0, ly + i2, d, 1);
      ctx.clearRect(x0, LAY.floorY - 1 - i2, d, 1);
    }
  }
  /* yan yüz gölgesi */
  ctx.globalAlpha = .30; fr(x0, ly + 4, 3, LAY.floorY - ly - 8, '#000'); ctx.globalAlpha = 1;
  vl(x0, ly + 6, LAY.floorY - ly - 12, '#8c949c');
  vl(x0 + 1, ly + 6, LAY.floorY - ly - 12, '#aeb6be');
  ctx.globalAlpha = .35; fr(x0 - 5, LAY.floorY, 10, 4, '#000'); ctx.globalAlpha = 1;

  /* --- sağ uç: taş duvarın arkasına gir --- */
  for (var yr = ly - 2; yr < LAY.floorY; yr++) {
    var e = archR(yr);
    if (e < W) ctx.clearRect(e, yr, W - e, 1);
    px(e - 1, yr, 'rgba(0,0,0,.35)');
  }
  ctx.clearRect(0, LAY.floorY, W, H - LAY.floorY);
}
/* rafta duran süs eşyaları */
function drawCounterProps(t) {
  /* peçetelik */
  var nx = 398, ny = LAY.ledgeY - 9;
  fr(nx, ny, 14, 10, '#9aa3ab');
  fr(nx + 1, ny + 1, 12, 8, '#c7ced5');
  fr(nx + 3, ny - 2, 8, 4, '#fdfaf0');
  hl(nx + 3, ny - 2, 8, '#ffffff');
  /* baharatlıklar */
  for (var i = 0; i < 2; i++) {
    var sx = 416 + i * 9, sy = LAY.ledgeY - 8;
    fr(sx, sy, 6, 9, i ? '#e8e2d4' : '#d8cfbc');
    fr(sx + 1, sy + 1, 4, 7, i ? '#f6f2e6' : '#3a2a20');
    fr(sx + 1, sy - 2, 4, 3, '#8a939b');
    hl(sx + 1, sy - 2, 4, '#c7ced5');
  }
  /* ketçap/mayonez şişeleri (sol) */
  bottleProp(48, LAY.ledgeY - 13, '#c0281c', '#e2483a');
  bottleProp(56, LAY.ledgeY - 13, '#f0e8d2', '#fffaf0');
}
function bottleProp(x, y, c0, c1) {
  fr(x, y + 3, 6, 10, c0);
  fr(x + 1, y + 3, 4, 9, c1);
  px(x + 1, y + 5, 'rgba(255,255,255,.6)');
  fr(x + 1, y, 4, 3, '#3a3a3a');
  fr(x + 2, y - 2, 2, 2, '#5a5a5a');
}

/* ---------- döner şişi ---------- */
/* Her çağrıda 'rgb(...)' dizesi kuruluyordu; şiş çiziminde binlerce kez
   çağrılıyor. Değerleri yuvarlayıp sonucu saklıyoruz (görsel fark yok). */
var _mcC = {};
function meatCol(roast, shade) {
  var sQ = shade === undefined ? 1 : shade;
  var key = (((roast * 160) | 0) << 10) + ((sQ * 160) | 0);
  var hit = _mcC[key];
  if (hit !== undefined) return hit;
  var out = meatColCalc(roast, sQ);
  _mcC[key] = out;
  return out;
}
function meatColCalc(roast, shade) {
  var c;
  if (roast < .34) c = [lerp(233, 242, roast / .34), lerp(158, 180, roast / .34), lerp(136, 104, roast / .34)];
  else if (roast < .78) { var t = (roast - .34) / .44; c = [lerp(242, 208, t), lerp(180, 138, t), lerp(104, 64, t)]; }
  else if (roast < 1.0) { var t2 = (roast - .78) / .22; c = [lerp(208, 158, t2), lerp(138, 92, t2), lerp(64, 40, t2)]; }
  else { var t3 = Math.min(1, (roast - 1) / .35); c = [lerp(158, 58, t3), lerp(92, 42, t3), lerp(40, 30, t3)]; }
  var s = shade === undefined ? 1 : shade;
  return 'rgb(' + Math.round(clamp(c[0] * s, 0, 255)) + ',' + Math.round(clamp(c[1] * s, 0, 255)) + ',' + Math.round(clamp(c[2] * s, 0, 255)) + ')';
}
var _mcQ = [];
function meatColQ(k) {
  var c = _mcQ[k];
  if (c === undefined) { c = meatCol(((k / 40) | 0) / 15, (k % 40) / 12); _mcQ[k] = c; }
  return c;
}
function coneProfile(ty) {
  if (ty < .09) return .52 + .44 * ease(ty / .09);
  if (ty < .62) { var u = (ty - .09) / .53; return .96 + .04 * Math.sin(u * Math.PI); }
  var k = (ty - .62) / .38;
  return Math.max(.10, 1 - k * k * .90);
}
/* Et konisi her karede ~5000 piksel çiziyor ve her piksel için
   Math.asin çağırıyordu. Tablo araması aynı görüntüyü verir. */
var ASIN_LUT = (function () {
  var n = 1024, a = new Float32Array(n + 1);
  for (var i = 0; i <= n; i++) a[i] = Math.asin(i / n * 2 - 1);
  return a;
})();
function asinF(v) {
  var i = ((v + 1) * 512) | 0;
  return ASIN_LUT[i < 0 ? 0 : (i > 1024 ? 1024 : i)];
}

/* ---------- DONER BICAGI ----------
   Blender: blender/models/bicaklar.py -> agiz() / sap().

   Gercek doner bicaginin agzi boydan boya AYNI GENISLIKTE ve UCU
   YUVARLAKTIR - et siyirir, delmez. Onceki cizimler uca dogru
   konikleserek sivriliyordu, o mutfak bicagi silueti.

   data.js'te dort kademe var (UPG 'knife'); cizim artik kademeye
   gore degisiyor. Kademe 4 (Otomatik kesim) bicagi hic gostermez,
   drawSpit icindeki makine cizimi devreye girer. */
var BICAK_KADEME = [
  /* 0 - yukseltme yok: kisa, mat celik, sade ahsap sap */
  { boy: 19, yuk: 1, cift: false,
    celik: ['#767f88', '#a2abb3', '#c4ccd3'],
    sapK: '#4e2e17', sapG: '#6b4122', sapI: '#8a5730',
    bilezik: '#7a6c5c', bilezikI: '#9a8a76', percin: 0, sapUz: 7, sapKal: 1 },
  /* 1 - Keskin bicak: uzun parlak agiz, siyah sap, iki percin */
  { boy: 25, yuk: 1, cift: false,
    celik: ['#5a636c', '#c9d2da', '#eef4f8'],
    sapK: '#141414', sapG: '#242830', sapI: '#3a4048',
    bilezik: '#8f9aa4', bilezikI: '#eef4f8', percin: 2, sapUz: 8, sapKal: 2 },
  /* 2 - Cift tarafli: ORTADAN AYRILMIS iki paralel agiz */
  { boy: 27, yuk: 0, cift: true,
    celik: ['#5a636c', '#c9d2da', '#eef4f8'],
    sapK: '#141414', sapG: '#242830', sapI: '#3a4048',
    bilezik: '#8f9aa4', bilezikI: '#eef4f8', percin: 3, sapUz: 9, sapKal: 2 },
  /* 3 - Profesyonel satir: genis agiz, pirinc bilezik, kalin sap */
  { boy: 29, yuk: 2, cift: false,
    celik: ['#4a525a', '#b6c0c9', '#ffffff'],
    sapK: '#141414', sapG: '#242830', sapI: '#565e68',
    bilezik: '#a97113', bilezikI: '#ffd34e', percin: 3, sapUz: 10, sapKal: 3 }
];

/* (ux, uy) = agzin UCU. yon: -1 sap solda / agiz saga.
   kademe: 0..3 (UV(G,'knife') dogrudan verilebilir, kirpilir). */
function drawKesimBicagi(ux, uy, yon, kademe) {
  var d = yon || -1;
  var K = BICAK_KADEME[clamp(Math.round(kademe || 0), 0, 3)];
  ux = Math.round(ux); uy = Math.round(uy);

  /* --- agiz: duz, ucta yuvarlanir --- */
  function agizCiz(oz, yuk) {
    for (var i = 0; i < K.boy; i++) {
      var u = K.boy > 1 ? i / (K.boy - 1) : 0;
      var bx = ux + d * i;
      var h = yuk;
      if (u > .86) {                       /* son %14: ceyrek daire */
        var t = (u - .86) / .14;
        h = Math.round(yuk * Math.sqrt(Math.max(0, 1 - t * t)));
      }
      var y0 = uy + oz;
      fr(bx, y0 - h, 1, h * 2 + 1, K.celik[0]);     /* koyu kenar */
      fr(bx, y0 - h, 1, h * 2, K.celik[1]);         /* govde */
      px(bx, y0 - h, K.celik[2]);                   /* sirt isigi */
      if (yuk > 1) px(bx, y0, K.celik[1]);
    }
  }
  if (K.cift) {
    /* iki ayri agiz, arada bosluk: bir hamlede iki dilim */
    agizCiz(-2, 0);
    agizCiz(2, 0);
    /* sapa girdikleri yerde birlesirler */
    fr(ux + d * (K.boy - 2) - (d < 0 ? 3 : 0), uy - 2, 4, 5, K.celik[0]);
    fr(ux + d * (K.boy - 2) - (d < 0 ? 3 : 0), uy - 2, 4, 4, K.celik[1]);
  } else {
    agizCiz(0, K.yuk);
  }

  /* --- bilezik --- */
  var bx0 = ux + d * (K.boy + 1);
  var bh = K.sapKal + 1;   /* bilezik sapla ayni olcude */
  fr(bx0 - 1, uy - bh, 3, bh * 2 + 1, K.bilezik);
  fr(bx0 - 1, uy - bh, 3, bh * 2, K.bilezikI);
  px(bx0 - 1, uy - bh, K.bilezikI);

  /* --- sap: ortasi dolgun, arkasi hafif kancali --- */
  for (var s = 0; s < K.sapUz; s++) {
    var sx = ux + d * (K.boy + 3 + s);
    var sv = Math.sin((s + 1) / (K.sapUz + 1) * Math.PI);
    var sk = K.sapKal + Math.round(sv * .9);
    var kanca = s > K.sapUz * .62 ? -Math.round((s - K.sapUz * .62) * .5) : 0;
    var sy = uy + kanca;
    fr(sx, sy - sk, 1, sk * 2 + 1, K.sapK);
    fr(sx, sy - sk + 1, 1, sk * 2 - 1, K.sapG);
    px(sx, sy - sk + 1, K.sapI);
  }
  /* --- perculer --- */
  for (var pI = 0; pI < K.percin; pI++) {
    var px0 = ux + d * (K.boy + 5 + pI * 2);
    px(px0, uy, K.bilezikI);
    px(px0, uy + 1, K.bilezik);
  }
}

/* ---------- TIRASLANAN ET DILIMI ----------
   Blender: kesim.py -> dilim_kur(). Oyunda dusen et 1 px'lik `part()`
   noktasiydi. Gercekte tiras edilen et KIVRILIR: bir ucu kizarmis
   kabuk, ic yuzu acik. kv 0..1 kivrim, k parca kimligi. */
function drawEtDilimi(x, y, kv, k, sc) {
  sc = sc || 1;
  var boy = Math.round((5 + hash1(k * 3.1) * 3) * sc);
  var don = hash1(k * 7.7) * 0.9 - 0.45;
  var kabuk = '#7e4412', koyu = '#9c5718', govde = '#bd7024';
  var acik = '#eeb463', isik = '#ffd291';
  x = Math.round(x); y = Math.round(y);
  for (var i = 0; i < boy; i++) {
    var u = boy > 1 ? i / (boy - 1) : .5;
    /* kivrilma: uc dogru rulo olur */
    var a = u * Math.PI * 1.35 * kv + don;
    var cx = x + Math.round(Math.sin(a) * boy * .55);
    var cy = y + Math.round((1 - Math.cos(a)) * boy * .40) - Math.round(boy * .2);
    var kal = 1 + (u > .18 && u < .82 ? 1 : 0);
    fr(cx, cy, 1, kal + 1, kabuk);          /* ates goren yuz */
    px(cx, cy, u < .5 ? govde : koyu);
    if (kal > 1) px(cx, cy + 1, u < .55 ? acik : govde);
  }
  /* ic yuzun parlak ucu */
  px(x + Math.round(Math.sin(don) * boy * .55), y - Math.round(boy * .2), isik);
}

function drawSpit(sp, t) {
  var cx = LAY.spit.cx, top = LAY.spit.top, bot = LAY.spit.bot;
  var H0 = bot - top;
  var maxR = 19;

  /* --- ısıtıcı paneli (arkada, sağda) --- */
  var hx = cx + 19, hy = top + 2, hw = 17, hh = H0 - 14;
  fr(hx - 1, hy - 1, hw + 2, hh + 2, P.mt4);
  fr(hx, hy, hw, hh, P.mt2);
  fr(hx + 2, hy + 2, hw - 4, hh - 4, '#241610');
  hl(hx, hy, hw, P.mt0); vl(hx, hy, hh, P.mt1);
  hl(hx, hy + hh - 1, hw, P.mt5);
  for (var i = 0; i < 6; i++) {
    var seg = Math.floor((hh - 8) / 6);
    var ey = hy + 4 + i * seg;
    var fl = .55 + .45 * Math.sin(t * 6 + i * 1.9);
    fr(hx + 3, ey, hw - 6, seg - 3, '#6d1a08');
    fr(hx + 3, ey, hw - 6, seg - 4, i % 2 ? '#c8380f' : '#e0500f');
    ctx.globalAlpha = .30 + .40 * fl;
    fr(hx + 4, ey + 1, hw - 8, Math.max(1, seg - 5), '#ff9c2e');
    ctx.globalAlpha = .25 + .3 * fl;
    fr(hx + 5, ey + 1, hw - 10, Math.max(1, seg - 6), '#ffe08a');
    ctx.globalAlpha = 1;
    if (chance(.014)) part({ x: hx + rnd(3, hw - 3), y: ey, vx: rnd(-4, 2), vy: rnd(-30, -14), life: rnd(.3, .8), col: pick([P.f1, P.f2, P.f0]), g: -16, sz: 1 });
  }
  /* ısı parıltısı */
  ctx.globalAlpha = .10 + .045 * Math.sin(t * 5);
  fr(cx - 4, top, 26, H0, '#ff8a2a');
  ctx.globalAlpha = 1;
  heatShimmer(cx + 8, top + 6, 18, H0 - 12, t);

  /* --- şiş mili --- */
  vl(cx - 1, top - 12, H0 + 16, P.mt4);
  vl(cx, top - 12, H0 + 16, P.mt1);
  vl(cx + 1, top - 12, H0 + 16, P.mt3);
  fr(cx - 5, top - 15, 11, 4, P.mt3); hl(cx - 5, top - 15, 11, P.mt0);
  fr(cx - 8, top - 19, 17, 4, P.mt2); hl(cx - 8, top - 19, 17, P.mt0);
  hl(cx - 8, top - 16, 17, P.mt4);
  /* tavandan asılı çubuk */
  vl(cx, 0, top - 18, P.mt3); vl(cx + 1, 0, top - 18, P.mt4);

  /* --- et konisi --- */
  var mass = clamp(sp.mass, 0, 1);
  var scaleR = 0.45 + 0.55 * mass;
  var coneTop = top + Math.round((1 - mass) * 10);
  var coneH = H0 - Math.round((1 - mass) * 18);
  ctx.globalAlpha = .30; ell(cx + 2, bot + 3, 15, 4, '#000'); ctx.globalAlpha = 1;

  for (var y = 0; y < coneH; y++) {
    var ty = y / coneH;
    var rjit = (Math.sin(y * .21 + sp.rot * 1.3) > .25 ? 1 : 0) - (Math.sin(y * .29 + 2.1 + sp.rot) > .55 ? 1 : 0);
    var r = Math.max(1, Math.round(maxR * scaleR * coneProfile(ty)) + (ty > .06 && ty < .95 ? rjit : 0));
    var yy = coneTop + y;
    var cutAmt = (sp.cutDepth > 0 && y > 8 && y < coneH * .8) ? Math.round(sp.cutDepth * (1 - Math.abs(ty - .45))) : 0;
    var lay = Math.sin(y * .62 + Math.sin(y * .19) * 1.6);
    var layM = 1 + lay * .028;
    var runK = -1, runX = 0;
    for (var x = -r; x <= r; x++) {
      if (cutAmt > 0 && x < 0 && -x > r - cutAmt) continue;
      var nx = x / r;
      var n01 = nx * .5 + .5;
      var shade;
      if (nx < -.78) shade = .52;
      else if (nx < -.55) shade = .66;
      else if (nx < -.25) shade = .80;
      else if (nx < .10) shade = .95;
      else if (nx < .38) shade = 1.12;
      else if (nx < .62) shade = 1.30;
      else if (nx < .86) shade = 1.12;
      else shade = .86;
      var ang = asinF(nx);
      var seam = (ang * 1.9 + sp.rot * 2.2) / Math.PI;
      seam = seam - Math.floor(seam);
      if (seam < .10) shade *= .80;
      else if (seam < .16) shade *= 1.10;
      shade *= layM;
      var lroast = sp.roast * (.84 + .30 * n01);
      if (ty < .05) lroast *= .82;
      var k = ((lroast * 15) | 0) * 40 + ((shade * 12) | 0);
      if (k !== runK) {
        if (runK >= 0) { ctx.fillStyle = meatColQ(runK); ctx.fillRect(cx + runX, yy, x - runX, 1); }
        runK = k; runX = x;
      }
    }
    if (runK >= 0) { ctx.fillStyle = meatColQ(runK); ctx.fillRect(cx + runX, yy, r + 1 - runX, 1); }
    /* dış hat */
    px(cx - r - 1 + cutAmt, yy, 'rgba(30,18,10,.45)');
    px(cx + r + 1, yy, 'rgba(30,18,10,.40)');
    /* dış kabuk kenarı */
    px(cx + r, yy, meatCol(sp.roast * 1.05, .80));
    px(cx + r - 1, yy, meatCol(sp.roast * 1.0, 1.22));
    px(cx - r + cutAmt, yy, meatCol(sp.roast * .78, .60));
    if (cutAmt === 0) px(cx - r - 1, yy, 'rgba(20,12,8,.35)');
    /* katman ayrım çizgileri */
    if ((y + Math.floor(sp.rot * 2)) % 12 === 0) {
      for (var x2 = -r + 2 + cutAmt; x2 < r - 1; x2++) {
        if (hash1(x2 * 3.1 + y * 1.7) > .38) px(cx + x2, yy, meatCol(sp.roast * .92, .78));
      }
    }
    /* parlak yağ damlaları */
    if (hash1(y * 4.7 + Math.floor(sp.rot * 1.5)) > .80) {
      var gx2 = Math.round(rnd(r * .05, r * .70));
      px(cx + gx2, yy, meatCol(sp.roast * .9, 1.55));
      px(cx + gx2, yy + 1, meatCol(sp.roast, 1.25));
    }
    /* yanık lekeleri */
    if (sp.roast > 1.02 && hash1(y * 2.3 + Math.floor(sp.rot)) > .70) {
      var bx2 = Math.round(rnd(-r * .3, r * .9));
      px(cx + bx2, yy, '#33231a'); px(cx + bx2 + 1, yy, '#4a3226');
    }
  }
  /* taze kesim yüzeyi */
  if (sp.cutDepth > 0) {
    for (var yc = 10; yc < coneH * .8; yc++) {
      var rr = Math.max(1, Math.round(maxR * scaleR * coneProfile(yc / coneH)));
      var ca = Math.round(sp.cutDepth * (1 - Math.abs(yc / coneH - .45)));
      if (ca > 0) {
        px(cx - rr + ca, coneTop + yc, meatCol(sp.roast * .22, 1.15));
        px(cx - rr + ca + 1, coneTop + yc, meatCol(sp.roast * .34, .98));
      }
    }
  }
  /* tepe: domates + biber */
  var topR = Math.round(maxR * scaleR * coneProfile(.02));
  ell(cx, coneTop + 1, topR - 1, 3, '#a8302a');
  ell(cx, coneTop, topR - 1, 3, '#d8443a');
  ell(cx - 2, coneTop - 1, Math.max(2, topR - 5), 1, '#f2887a');
  px(cx + 3, coneTop - 2, P.g2); px(cx + 4, coneTop - 3, P.g1);
  /* --- alt tabla / yağ toplama --- */
  fr(cx - 9, bot - 3, 19, 3, P.mt4);
  hl(cx - 9, bot - 3, 19, P.mt1);
  ell(cx, bot + 2, 13, 4, P.mt4);
  ell(cx, bot + 1, 13, 4, P.mt1);
  ell(cx, bot + 1, 10, 2, P.mt2);
  ell(cx + 1, bot + 2, 7, 1, '#9a6a1e');
  if (chance(.02)) part({ x: cx + rnd(-4, 4), y: bot - 4, vx: 0, vy: 20, life: .5, col: '#c08a2a', g: 90, sz: 1, floor: bot + 1 });

  /* --- OTOMATİK KESİM MAKİNESİ (bıçak sv.4) --- */
  if (typeof TUN !== 'undefined' && G.up && TUN.autoShave(G)) {
    var rx0 = cx - Math.round(maxR * scaleR) - 12;
    /* dikey ray */
    fr(rx0, top - 6, 4, H0 + 14, '#3a4048');
    fr(rx0 + 1, top - 6, 2, H0 + 14, '#6b737d');
    for (var rv = 0; rv < H0 + 10; rv += 8) px(rx0 + 1, top - 4 + rv, '#98a0a9');
    /* üst motor kutusu */
    fr(rx0 - 7, top - 16, 16, 12, '#2f3740');
    fr(rx0 - 6, top - 16, 14, 11, '#59636d');
    hl(rx0 - 6, top - 16, 14, '#8b959e');
    /* dönen kasnak */
    var wa = t * 9;
    disc(rx0 + 1, top - 10, 4, '#3a4048');
    disc(rx0 + 1, top - 10, 3, '#98a0a9');
    ln(rx0 + 1, top - 10, rx0 + 1 + Math.cos(wa) * 3, top - 10 + Math.sin(wa) * 3, '#2f3740');
    px(rx0 - 4, top - 13, chance(.5) ? '#7dff7a' : '#2a6a28');
    /* taşıyıcı + bıçak */
    var ph = (G.shave ? (G.shave.auto || 0) / .55 : 0);
    var tri = ph < .5 ? ph * 2 : (1 - ph) * 2;
    var cy2 = Math.round(lerp(top + 10, bot - 18, clamp(tri, 0, 1)));
    fr(rx0 - 4, cy2 - 5, 12, 11, '#59636d');
    fr(rx0 - 3, cy2 - 5, 10, 10, '#8b959e');
    hl(rx0 - 3, cy2 - 5, 10, '#c6ccd2');
    fr(rx0 - 5, cy2 - 1, 3, 3, '#2f3740');
    /* bıçak (koniye doğru) */
    fr(rx0 + 7, cy2 - 1, 14, 3, '#c9d2da');
    fr(rx0 + 7, cy2 - 1, 14, 2, '#eef4f8');
    hl(rx0 + 7, cy2 - 1, 14, '#ffffff');
    px(rx0 + 21, cy2, '#ffffff');
    if (chance(.25)) part({ x: rx0 + 20, y: cy2 + rnd(-2, 2), vx: rnd(-26, -6), vy: rnd(-18, 4), life: .35, col: pick(['#c98436', '#eeb464']), g: 240, sz: 1, floor: ST.meat.y + rnd(4, 12) });
  }

  /* --- bıçak --- */
  if (sp.sliceT > 0) {
    var kt = 1 - sp.sliceT;
    var ky = coneTop + 10 + kt * (coneH - 26);
    var kx = cx - Math.round(maxR * scaleR) - 3;
    ctx.globalAlpha = .30;
    fr(kx + 2, ky - 8, 3, 16, '#dfe6ec');
    ctx.globalAlpha = 1;
    drawKesimBicagi(kx + 4, ky + 1, -1,
                    (typeof UV === 'function' ? UV(G, 'knife') : 0));
    if (chance(.5)) part({ x: kx + 4, y: ky + rnd(-2, 2), vx: rnd(-40, -10), vy: rnd(-20, 10), life: .3, col: '#ffffff', g: 60, sz: 1 });
  }
}

/* ---------- tepsiler ---------- */
function trayInnerShade(x, y, w, h) {
  /* yalnızca arka duvarın yemeğe düşen gölgesi — alt taraf karartılmaz */
  ctx.globalAlpha = .16; fr(x + 2, y + 2, w - 4, 2, '#000');
  ctx.globalAlpha = .09; fr(x + 2, y + 4, w - 4, 2, '#000');
  ctx.globalAlpha = .10; fr(x + 2, y + 2, 2, h - 9, '#000'); fr(x + w - 4, y + 2, 2, h - 9, '#000');
  ctx.globalAlpha = 1;
  /* ön kenarda ince ışık: derinlik */
  ctx.globalAlpha = .22; hl(x + 3, y + h - 7, w - 6, '#ffffff'); ctx.globalAlpha = 1;
}

/* --- tek parça çizimleri --- */
function trayFlash(x, y, w, h, fx) {
  if (fx <= 0) return;
  ctx.globalAlpha = Math.sin(fx * Math.PI) * .45;
  rrectOut(x - 1, y - 1, w + 2, h + 2, 2, '#ffffff');
  ctx.globalAlpha = 1;
}
/* ---------- gastronom küvet ----------
   Kuyu gibi: ağız (üst açıklık) geniş, zemin daha dar ve aşağıda.
   Aradaki EĞİMLİ DUVARLAR çizilir — derinlik bundan okunur.
   Arka duvar en çok görünen yüzdür (yukarıdan bakıyoruz), yan duvarlar
   içeri doğru daralır, ön duvarın iç yüzü neredeyse görünmez.        */
function trayFloor(x, y, w, h) {
  /* ağız: çerçevenin hemen içi */
  var ax = x + 2, aw = w - 4, ay = y + 2, ah = h - 4;
  /* zemin: ağızdan içeri çekilmiş ve aşağı kaymış */
  var duvar = 4;                       /* arka duvarın görünen derinliği */
  var yan = 2;                         /* yan duvarların genişliği */
  return {
    ax: ax, aw: aw, ay: ay, ah: ah,
    ix: ax + yan, iw: aw - yan * 2,    /* zemin yatay sınırları */
    arka: ay + duvar,                  /* zeminin arka kenarı */
    zemin: ay + duvar,
    on: ay + ah - 1,                   /* zeminin ön kenarı */
    duvar: duvar, yan: yan
  };
}

function trayBase(x, y, w, h) {
  var F = trayFloor(x, y, w, h);

  /* --- dış flanş (küvetin ağzındaki kalın kenar) --- */
  fr(x, y, w, h, '#aeb6be');
  hl(x, y, w, '#f4f8fb');                        /* tepe ışığı */
  hl(x + 1, y + 1, w - 2, '#d2d9e0');
  vl(x, y, h, '#dfe5eb'); vl(x + w - 1, y, h, '#868e96');
  hl(x, y + h - 1, w, '#666e76');
  hl(x + 1, y + h - 2, w - 2, '#9aa2aa');
  px(x, y, '#c4ccd3'); px(x + w - 1, y, '#9ba3ab');
  px(x, y + h - 1, '#7f878f'); px(x + w - 1, y + h - 1, '#727a82');

  /* --- ARKA DUVAR: yukarıdan aşağı aydınlanır (dibe yakın ışık toplar) --- */
  for (var d = 0; d < F.duvar; d++) {
    var u = d / Math.max(1, F.duvar - 1);
    fr(F.ax, F.ay + d, F.aw, 1, mixHex('#79828b', '#a9b2ba', u));
  }
  /* ağzın arka kenarında keskin koyu çizgi: kenarın kalınlığı */
  hl(F.ax, F.ay, F.aw, '#5e666e');
  /* duvarın dibinde zemine geçiş */
  ctx.globalAlpha = .35; hl(F.ix, F.arka, F.iw, '#4e565e'); ctx.globalAlpha = 1;

  /* --- YAN DUVARLAR: ağızdan zemine doğru daralan yamuk --- */
  var dh = F.on - F.arka;
  for (var r = 0; r < dh; r++) {
    var v = r / Math.max(1, dh - 1);
    /* aşağı indikçe yan duvar incelir (perspektif) */
    var gen = Math.max(1, Math.round(F.yan * (1 - v * .45)));
    var yy = F.arka + r;
    /* sol duvar: ışığı alır */
    for (var a = 0; a < gen; a++) {
      px(F.ax + a, yy, mixHex('#9aa3ab', '#c3ccd3', a / Math.max(1, gen - 1)));
    }
    /* sağ duvar: gölgede */
    for (var b = 0; b < gen; b++) {
      px(F.ax + F.aw - 1 - b, yy, mixHex('#79828b', '#5e666e', b / Math.max(1, gen - 1)));
    }
  }

  /* --- ZEMİN --- */
  for (var z = 0; z < dh; z++) {
    var w2 = z / Math.max(1, dh - 1);
    fr(F.ix, F.arka + z, F.iw, 1, mixHex('#8b949c', '#a6afb7', w2));
  }
  /* zeminde uzunlamasına yansıma */
  ctx.globalAlpha = .24;
  fr(F.ix + 2, F.arka + Math.round(dh * .42), F.iw - 4, 2, '#e6ecf1');
  ctx.globalAlpha = 1;
  /* arka duvarın zemine düşürdüğü gölge */
  ctx.globalAlpha = .22;
  fr(F.ix, F.arka + 1, F.iw, 2, '#3c434a');
  ctx.globalAlpha = 1;

  /* --- ÖN DUVARIN İÇ YÜZÜ: ince, ışık alan şerit --- */
  hl(F.ax, F.on, F.aw, '#cdd5dc');
  ctx.globalAlpha = .5; hl(F.ax, F.on + 1, F.aw, '#8f979f'); ctx.globalAlpha = 1;
}

/* yığın konumu: ortada tepe, kenarlara doğru alçalan doğal öbek */
/* ---------- tepsi doldurma: kenardan kenara, katman katman ----------
   lvl 0..1 = doluluk yüksekliği. Üst sıra aydınlık (yüzey), alt sıralar
   gölgede (ön yüz). Taşmasın diye tepsinin içine kırpılır. */
/* ---------- 3/4 üstten dolum ----------
   Kesit gibi katman katman değil: yemek küvetin ZEMİNİNE yayılır.
   Arkadaki sıralar önce çizilir, öndekiler üstlerine biner; böylece
   derinlik oluşur. Doluluk iki şeyden okunur:
     - kaplama : yemeğin zeminin ne kadarını örttüğü
     - kabarma : yığının arka duvarı ne kadar aştığı
   Sonuç önbelleğe alınır (aynı seviye her karede yeniden çizilmesin). */
var FILLCACHE = {}, FILLN = 0;

function drawFill(x, y, w, h, lvl, seed, item) {
  lvl = clamp(lvl, 0, 1);
  var q = Math.round(lvl * 40);
  var key = w + ',' + h + ',' + q + ',' + seed + ',' + (item.name || '?');
  var e = FILLCACHE[key];
  if (!e) {
    if (FILLN > 400) { FILLCACHE = {}; FILLN = 0; }
    var oc = document.createElement('canvas');
    oc.width = w + 4; oc.height = h + 10;
    var eskiCtx = ctx;
    ctx = oc.getContext('2d');
    ctx.imageSmoothingEnabled = false;
    var ty = fillPaint(2, 6, w, h, q / 40, seed, item);
    ctx = eskiCtx;
    e = FILLCACHE[key] = { c: oc, ty: ty - 6 };
    FILLN++;
  }
  ctx.drawImage(e.c, (x | 0) - 2, (y | 0) - 6);
  return (y | 0) + e.ty;
}

function fillPaint(x, y, w, h, lvl, seed, item) {
  var F = trayFloor(x, y, w, h);
  var zh = F.on - F.zemin;                 /* zemin derinliği */
  if (zh < 4) zh = 4;

  /* Zeminin ne kadarı örtülü: az malzemede önde ince bir şerit kalır,
     dolduğunda arka duvara kadar tamamı kaplanır. */
  /* Taban %30'du: bomboş küvet bile yarı dolu görünüyordu. */
  var kaplama = 0.10 + 0.90 * lvl;
  var arkaSinir = F.on - Math.round(zh * kaplama);
  /* yığın arka duvarı aşabilir: "ağzına kadar dolu" hissi */
  var kabarma = Math.round(lvl * 7);
  var tepe = Math.max(F.arka - kabarma, y + 1);
  if (arkaSinir < tepe) arkaSinir = tepe;

  ctx.save();
  /* küvetin içi + biraz taşma payı */
  ctx.beginPath();
  ctx.rect(F.ix - 1, y - 4, F.iw + 2, (F.on + 2) - (y - 4));
  ctx.clip();

  /* --- sıralar: arkadan öne ---
     Küvet gerçekten dolu görünsün diye sıralar sık ve iki geçişli:
     ikinci geçiş yarım hücre kaydırılıp aradaki boşlukları kapatır. */
  var derinlik = F.on - arkaSinir;
  var sira = Math.max(3, Math.round(derinlik / 1.9));
  var sutun = Math.max(4, Math.round(F.iw / 4.4));

  /* Az malzemede ikinci geçiş yapılmaz ve parçalar seyrekleşir:
     zemin aralardan görünsün, "azaldı" hissi doğsun. */
  var gecisSayi = lvl > 0.45 ? 2 : 1;
  var seyreklik = lvl < 0.45 ? (0.35 + lvl * 1.4) : 1;
  for (var gecis = 0; gecis < gecisSayi; gecis++) {
    for (var r = 0; r < sira; r++) {
      var v = sira === 1 ? 1 : r / (sira - 1);        /* 0 arka, 1 ön */
      var ry = Math.round(arkaSinir + v * derinlik);
      /* arka sıralar gölgede, ön sıralar ışıkta */
      /* Arka sıralar 0.66'ya kadar koyulaşıyordu; tepenin koyu bir
         bant gibi görünmesinin sebebi buydu. Fark küçültüldü. */
      var sh = 0.90 + 0.16 * v;
      /* arka sıra biraz daha dar: perspektif */
      var daralt = Math.round((1 - v) * 2);
      var sx0 = F.ix + daralt, sw = F.iw - daralt * 2;
      for (var c = 0; c < sutun; c++) {
        /* ikinci geçiş yarım hücre sağa kayar */
        var u = (c + (gecis ? 1.0 : 0.5)) / sutun;
        if (u > 1) continue;
        var tohum = c * 3.11 + r * 7.73 + seed + gecis * 53.7;
        if (seyreklik < 1 && hash1(tohum * 4.7 + 9.1) > seyreklik) continue;
        /* yığının ortası kabarık: kubbe */
        var kubbe = Math.round(Math.cos((u - .5) * Math.PI) * kabarma * (1 - v * .6) * .6);
        var jx = (hash1(tohum) - .5) * (sw / sutun) * 1.35;
        var jy = (hash1(tohum * 1.7 + 2.3) - .5) * 2.6;
        var px0 = sx0 + u * sw + jx;
        var py0 = ry + jy - kubbe;
        item(Math.round(px0), Math.round(py0), sh,
             (c + r * 41 + seed * 13 + gecis * 911) | 0,
             hash1(tohum * 2.31 + 1.1));
      }
    }
  }

  /* --- arka kenarda çok hafif temas gölgesi --- */
  ctx.globalAlpha = .12;
  fr(F.ix, arkaSinir - 1, F.iw, 1, '#3a2a18');
  ctx.globalAlpha = 1;
  /* --- ön kenar: kütlenin ön yüzü ışık alır, hemen altına küvetin
         dudağına düşen gölge gelir. Derinlik bu ikiliden okunur. --- */
  ctx.globalAlpha = .18;
  fr(F.ix, F.on - 2, F.iw, 2, '#ffd9a0');
  ctx.globalAlpha = .22;
  fr(F.ix, F.on, F.iw, 1, '#3a3f45');
  ctx.globalAlpha = 1;
  /* --- yan duvarlarla temas --- */
  ctx.globalAlpha = .13;
  vl(F.ix, arkaSinir, F.on - arkaSinir, '#000');
  vl(F.ix + F.iw - 1, arkaSinir, F.on - arkaSinir, '#000');
  ctx.globalAlpha = 1;

  ctx.restore();
  return arkaSinir;
}

/* Tursu dilimi. Blender: blender/models/garnitur.py -> sahne_tursu.
   Eskiden ust uste bindirilmis DUZ elipslerdi, yuvarlak yesil bir
   leke gibi duruyordu. Gercek kornison kabugu OLUKLU; oluk siluete
   girmezse dilim, dilim gibi okunmuyor. */
function pickleSlice(x, y, sh, k, sz) {
  var rw = sz > .5 ? 7 : 6, rh = sz > .5 ? 5 : 4;
  var don = hash1(k * 2.71) * Math.PI;         /* her dilim baska donuk */
  var kabK = shadeCol('#22350a', sh);
  var kab = shadeCol('#3f5c14', sh);
  var et = shadeCol('#6d9127', sh);
  var ic = shadeCol('#9dbe45', sh);
  x = Math.round(x); y = Math.round(y);

  ctx.globalAlpha = .22; ell(x, y + 2, rw, 1, '#2e4410'); ctx.globalAlpha = 1;
  ell(x, y + 1, rw, rh, kabK);                 /* alt kenar */
  ell(x, y, rw, rh, kab);                      /* kabuk */
  /* OLUKLAR: cevreye yedi cikinti, aralarina cukur */
  for (var pi = 0; pi < 7; pi++) {
    var a = don + pi * (Math.PI * 2 / 7);
    px(Math.round(x + Math.cos(a) * (rw + .7)),
       Math.round(y + Math.sin(a) * (rh + .6)), kab);
    var a2 = a + Math.PI / 7;
    px(Math.round(x + Math.cos(a2) * (rw - .4)),
       Math.round(y + Math.sin(a2) * (rh - .4)), kabK);
  }
  ell(x, y, rw - 1, rh - 1, et);                /* dis et */
  ell(x, y, Math.max(1, rw - 2), Math.max(1, rh - 2), ic);
  /* Bu elips rw-4 x rh-3 olunca 2x1'e dusup ARTI isareti gibi
     cikiyordu; genisletildi, yatik bir isik lekesi oldu. */
  ell(x, y - 1, Math.max(2, rw - 3), 1, shadeCol('#bcd668', sh));
  /* cekirdek yatagi: ucgen dizilim */
  px(x - 1, y, shadeCol('#e2efa4', sh));
  px(x + 1, y, shadeCol('#e2efa4', sh));
  px(x, y - 1, shadeCol('#eef6c4', sh));
  /* islak parilti */
  if (sh > .9 && hash1(k * 2.3) > .45) px(x - 2, y - 2, '#f2fbd0');
}

/* ---------- döner dilimi ----------
   Şişten tıraşlanan et düz bir çubuk değildir: ince, düzensiz, ateşe
   bakan yüzü koyu kızarmış, iç yüzü açık; çoğu kıvrılır ya da katlanır.
   k = parça kimliği (sabit kalır), sz = boy, sh = ışık çarpanı.        */
/* Palet bir kademe aydınlatıldı: tepsi diğerlerinin yanında
   çamurumsu koyu duruyordu. Kontrast korundu, taban yükseltildi. */
/* Aydınlık ama patatesle karışmasın: sarıdan kırmızıya çekildi.
   Et sıcak kahve-turuncu, patates soluk sarı kalır. */
var ET = {
  kabuk: '#7e4412',      /* ateşe bakan kızarmış kenar */
  koyu: '#9c5718',
  orta: '#bd7024',
  et: '#d98f38',
  ic: '#eeb463',         /* kesik iç yüz */
  isik: '#ffd291',
  yag: '#fff0cc',        /* yağ parıltısı */
  kömür: '#52290a'
};

/* Her dilimin kendi kızarma tonu var: kimi az pişmiş açık, kimi
   fazla kalmış koyu. Tek tonda çizilince yığın bulamaç gibi
   görünüyordu; ton farkı parçaları birbirinden ayırıyor. */
var _etTon = 1;
function etPx(x, y, c, sh) { px(x, y, shadeCol(c, sh * _etTon)); }

/* düz ama dalgalı şerit — en yaygın parça */
function _etDuz(x0, y, len, sh, k, tilt) {
  var oncekiY = null;
  for (var q = 0; q < len; q++) {
    var u = q / (len - 1);
    /* dalga küçük: parça ince ve bütün kalsın, kopmasın */
    var dal = Math.sin(u * 4.2 + k * 1.3) * .55;
    var yy = y + Math.round(dal + (q - len / 2) * tilt * .16);
    var uc = (q === 0 || q === len - 1);
    /* Basamak yerlerinde dilim ikiye ayrılmış gibi görünüyordu:
       önceki sütunla arası dolduruluyor. */
    if (oncekiY !== null && yy !== oncekiY) {
      var a0 = Math.min(oncekiY, yy), b0 = Math.max(oncekiY, yy);
      for (var f = a0; f <= b0; f++) {
        etPx(x0 + q, f + 1, ET.kabuk, sh * .8);
        etPx(x0 + q, f, ET.et, sh * .96);
      }
    }
    etPx(x0 + q, yy + 1, ET.kabuk, sh * .8);       /* alt: ateşe bakmış koyu yüz */
    etPx(x0 + q, yy, uc ? ET.koyu : ET.et, sh);
    if (!uc) etPx(x0 + q, yy - 1, ET.ic, sh * 1.02);   /* üst: açık kesik yüz */
    oncekiY = yy;
  }
  /* bir ucunda yoğunlaşan ateş kabuğu */
  var kUc = hash1(k * 2.3) > .5 ? 0 : len - 3;
  for (var c2 = 0; c2 < 3 && kUc + c2 < len; c2++) {
    etPx(x0 + kUc + c2, y + 1, ET.kömür, sh * .95);
  }
}

/* kıvrık parça: ucu hafifçe kalkmış, iç yüzü görünen dilim */
function _etKivrik(x0, y, len, sh, k) {
  var yon = hash1(k * 3.7) > .5 ? 1 : -1;
  /* kıvrım tek uçta toplanır: dilim masaya yatmış, bir ucu kalkmıştır */
  var uc = hash1(k * 5.9) > .5;
  var oncekiK = null;
  for (var q = 0; q < len; q++) {
    var u = q / (len - 1);
    var p2 = uc ? u : 1 - u;
    /* son üçte bir kalkar, gerisi düz yatar */
    var kalk = p2 < .62 ? 0 : Math.pow((p2 - .62) / .38, 1.5) * 2.2;
    var yy = y + Math.round(-kalk * yon);
    /* kıvrımın dikleştiği yerde gövde kopmasın */
    if (oncekiK !== null && yy !== oncekiK) {
      var a1 = Math.min(oncekiK, yy), b1 = Math.max(oncekiK, yy);
      for (var f2 = a1; f2 <= b1; f2++) {
        etPx(x0 + q, f2 + 1, ET.kabuk, sh * .78);
        etPx(x0 + q, f2, ET.et, sh * .94);
      }
    }
    etPx(x0 + q, yy + 1, ET.kabuk, sh * .78);
    etPx(x0 + q, yy, (q === 0 || q === len - 1) ? ET.koyu : ET.et, sh);
    /* kalkan uçta iç yüz görünür */
    if (kalk > .8) etPx(x0 + q, yy - 1, ET.ic, sh * 1.08);
    oncekiK = yy;
  }
}

/* katlanmış parça: bir ucu kendi üstüne devrilmiş dilim.
   Simetrik iç içe iki dikdörtgen "papyon" gibi duruyordu; artık kat
   tek yana toplanıyor ve gerçek bir kıvrım okunuyor. */
function _etKatli(x0, y, len, sh, k) {
  var sag = hash1(k * 5.1) > .5;              /* kat hangi uçta */
  var katL = Math.max(3, Math.round(len * .45));
  var altL = len;

  /* alttaki uzun kat: tam boy, düz yatıyor */
  for (var q = 0; q < altL; q++) {
    var ucA = (q === 0 || q === altL - 1);
    etPx(x0 + q, y + 2, ET.kabuk, sh * .74);
    etPx(x0 + q, y + 1, ucA ? ET.koyu : ET.orta, sh * .95);
  }

  /* üstteki kısa kat: bir uca devrilmiş, iç yüzü yukarı bakıyor */
  var kx = sag ? (x0 + altL - katL) : x0;
  for (var q2 = 0; q2 < katL; q2++) {
    var ucB = (q2 === 0 || q2 === katL - 1);
    etPx(kx + q2, y, ucB ? ET.koyu : ET.et, sh);
    if (!ucB) etPx(kx + q2, y - 1, ET.ic, sh * 1.06);
  }
  /* kıvrımın olduğu uç: iki kat burada birleşir, hafif koyu */
  var kIc = sag ? kx : (kx + katL - 1);
  etPx(kIc, y, ET.koyu, sh * .88);
  etPx(kIc, y + 1, ET.kabuk, sh * .8);
}

/* kısa kalın parça: şişin dibinden gelen tıknaz lokma */
function _etParca(x0, y, len, sh, k) {
  for (var q = 0; q < len; q++) {
    var uc = (q === 0 || q === len - 1);
    etPx(x0 + q, y + 2, ET.kabuk, sh * .7);
    etPx(x0 + q, y + 1, ET.orta, sh * .95);
    etPx(x0 + q, y, uc ? ET.koyu : ET.et, sh);
    if (!uc) etPx(x0 + q, y - 1, ET.ic, sh * 1.04);
  }
}

function meatStrip(x, y, sh, k, sz) {
  var bicim = Math.floor(hash1(k * 2.71) * 100) % 10;   /* 0-9 */
  var len, x0, tilt;
  y += Math.round((hash1(k * 7.9) - .5) * 3);

  /* bu parçanın kızarma tonu: 0.80 (koyu) .. 1.16 (açık) */
  _etTon = 0.92 + hash1(k * 1.37) * 0.24;   /* taban 0.80'di, dilimler kararıyordu */

  /* Ayrım gölgesi: parçanın altına ve bir yanına koyu bir kontur.
     Üst üste binen dilimler birbirinden ayrılsın. */
  var gLen = 6 + ((sz * 8) | 0);
  ctx.globalAlpha = .30;
  fr(x - (gLen >> 1) - 1, y + 2, gLen + 2, 2, '#4a2a08');
  ctx.globalAlpha = .18;
  fr(x - (gLen >> 1) - 1, y - 1, 1, 4, '#4a2a08');
  ctx.globalAlpha = 1;

  if (bicim < 4) {                    /* %40 düz şerit */
    len = 6 + ((sz * 8) | 0);
    x0 = x - (len >> 1);
    tilt = sz > .66 ? 1 : (sz < .32 ? -1 : 0);
    _etDuz(x0, y, len, sh, k, tilt);
  } else if (bicim < 7) {             /* %30 kıvrık */
    len = 7 + ((sz * 6) | 0);         /* kısa parça kıvrılınca kopuk görünüyor */
    x0 = x - (len >> 1);
    _etKivrik(x0, y, len, sh, k);
  } else if (bicim < 9) {             /* %20 katlı */
    len = 5 + ((sz * 6) | 0);
    x0 = x - (len >> 1);
    _etKatli(x0, y, len, sh, k);
  } else {                            /* %10 kalın lokma */
    len = 3 + ((sz * 4) | 0);
    x0 = x - (len >> 1);
    _etParca(x0, y, len, sh, k);
  }

  /* yağ parıltısı: yalnız üst sıradaki, ışık alan parçalarda */
  if (sh > .86 && hash1(k * 9.7) > .66) {
    var px0 = x0 + 1 + Math.floor(hash1(k * 6.3) * Math.max(1, len - 2));
    etPx(px0, y - 1, ET.yag, 1);
  }
  /* kömürleşmiş uç: nadiren, ateşe fazla yakın kalmış parça */
  if (hash1(k * 4.1) > .88) etPx(x0 + 1, y + 1, ET.kömür, sh);
  _etTon = 1;                      /* ton bu parçaya özeldi, sıfırla */
}

/* ---------- patates çubuğu ----------
   Üç kızarma tonu (açık / altın / fazla kızarmış) ve üç duruş
   (yatık, çapraz, dik). Her çubuğun koyu bir kenarı var; yoksa
   tepside sarı bir bulamaç gibi görünüyordu.                     */
var PT = {
  koyu: '#7a5410',      /* çubuğun gölgeli kenarı */
  govde: '#d9ab3e',
  acik: '#f0d271',
  altin: '#e8bf52',
  kizarmis: '#b8801f',
  uc: '#8a5c12',        /* uçtaki kızarmış kesit */
  isik: '#fff0b8',
  tuz: '#ffffff'
};

/* Tek patates cubugu. Blender modelinden aktarildi
   (blender/models/durum.py -> cubuk()). Eskiden iki satir pikseldi:
   `px(...,koyu); px(...,govde)` - hacmi yoktu, tepside sari bir
   bulamac gibi duruyordu. Artik uc tonlu prizma: ust isik, govde,
   alt kenar; boyunca hafif bukum; iki ucta kizarmis kesit. */
function fryBar(x0, y0, L, egim, buk, ust, govde, alt, ucC) {
  var yarim = L >> 1, ilkY = 0, sonY = 0;
  for (var q = 0; q < L; q++) {
    var u = L > 1 ? q / (L - 1) : .5;
    var cx = x0 - yarim + q;
    var cy = y0 + Math.round((q - yarim) * egim - Math.sin(u * Math.PI) * buk);
    if (q === 0) ilkY = cy;
    if (q === L - 1) sonY = cy;
    px(cx, cy - 1, ust);              /* ust isik seridi */
    px(cx, cy, govde);
    px(cx, cy + 1, alt);              /* alt kenar */
  }
  /* iki uctaki kizarmis kesit: cubugun nerede bittigi okunsun */
  px(x0 - yarim, ilkY, ucC); px(x0 - yarim, ilkY + 1, ucC);
  px(x0 - yarim + L - 1, sonY, ucC); px(x0 - yarim + L - 1, sonY + 1, ucC);
}

function fryStick(x, y, sh, k, sz) {
  var L = 6 + ((sz * 7) | 0);
  var ton = hash1(k * 6.1);
  /* uc kizarma kademesi: solgun / altin / koyu kizarmis */
  var G = ton > .74 ? PT.kizarmis : (ton < .26 ? PT.acik : PT.altin);
  var govde = shadeCol(G, sh);
  var ust = shadeCol(ton > .74 ? PT.altin : PT.isik, sh);
  var alt = shadeCol(PT.koyu, sh * .96);
  var ucC = shadeCol(PT.uc, sh * .92);
  var mode = hash1(k * 3.7);
  x = Math.round(x); y = Math.round(y);

  /* zemin golgesi: cubuklar birbirinden ayrissin */
  ctx.globalAlpha = .30;
  fr(x - (L >> 1), y + 2, L, 1, '#4a3208');
  ctx.globalAlpha = 1;

  if (mode < .38) {
    /* --- yatik, hafif bukumlu --- */
    fryBar(x, y, L, 0, .8 + hash1(k * 4.3) * .9, ust, govde, alt, ucC);
  } else if (mode < .78) {
    /* --- capraz --- */
    var yon = hash1(k * 8.3) > .5 ? .42 : -.42;
    fryBar(x, y, L, yon, .5, ust, govde, alt, ucC);
  } else {
    /* --- dik duran cubuk: yigindan yukari firlamis --- */
    var hgt = 4 + ((sz * 5) | 0);
    for (var q3 = 0; q3 < hgt; q3++) {
      var kay = Math.round(Math.sin(q3 / hgt * Math.PI) * .9);
      px(x - 1 + kay, y - q3, alt);
      px(x + kay, y - q3, govde);
      px(x + 1 + kay, y - q3, ust);
    }
    px(x - 1, y - hgt, ucC); px(x, y - hgt, ucC);
    px(x + 1, y - hgt, shadeCol(PT.uc, sh * 1.15));
  }

  /* tuz tanesi */
  if (hash1(k * 9.4) > .80) {
    ctx.globalAlpha = .85;
    px(x + ((hash1(k * 2.9) * L) | 0) - (L >> 1), y - 2, PT.tuz);
    ctx.globalAlpha = 1;
  }
}

function pileSpot(i, cx, halfW, baseY, pileH, seed) {
  var h1 = hash1(i * 3.71 + seed), h2 = hash1(i * 8.13 + seed * 2.1), h3 = hash1(i * 1.97 + seed * .7);
  var nx = (h1 * 2 - 1);
  nx = nx * (0.80 + 0.20 * h3);              /* kenarlara kadar yay */
  var mound = Math.pow(1 - Math.abs(nx) * .82, 0.62);
  var y = baseY - mound * pileH * (0.18 + 0.82 * h2);
  return [Math.round(cx + nx * halfW), Math.round(y), h3];
}

/* et tepsisi — doğal öbek hâlinde döner dilimleri */
/* ---------- et teknesi ----------
   Döner eti paslanmaz bir küvette bekler: dibinde et suyu birikir,
   yığın küvetin duvarına sıcak bir ışık vurur, üstünden buhar çıkar. */
function drawMeatTray(x, y, w, h, n, t, fx) {
  fx = fx || 0;
  var kap = (typeof TUN !== 'undefined' && TUN.meatCap) ? TUN.meatCap() : 16;
  var lvl = clamp(n / kap, 0, 1);

  trayBase(x, y, w, h);

  if (n <= 0) {
    trayInnerShade(x, y, w, h);
    return;
  }

  var bump = Math.round(Math.sin(fx * Math.PI) * 2);
  var topY = drawFill(x, y - bump, w, h, lvl, 1.3, meatStrip);

  /* --- yığının küvet duvarına vurduğu sıcak ışık --- */
  ctx.globalAlpha = .16 + lvl * .12;
  fr(x + 2, topY - 1, w - 4, 2, '#e8a850');
  ctx.globalAlpha = .10 + lvl * .08;
  vl(x + 2, topY, y + h - 4 - topY, '#d89440');
  vl(x + w - 3, topY, y + h - 4 - topY, '#d89440');
  ctx.globalAlpha = 1;

  trayInnerShade(x, y, w, h);

  /* --- buhar: doluluk arttıkça sıklaşır --- */
  if (chance(.10 + lvl * .20)) {
    part({
      x: x + 6 + rnd(0, w - 12), y: topY,
      vx: rnd(-4, 4), vy: rnd(-16, -7), life: .9,
      col: 'rgba(246,238,224,.34)', g: -14, sz: 1
    });
  }
  /* --- cızırtı: sıcak yağ zerresi --- */
  if (chance(.03 + lvl * .05)) {
    part({
      x: x + 5 + rnd(0, w - 10), y: topY + 2,
      vx: rnd(-10, 10), vy: rnd(-22, -10), life: .35,
      col: '#ffd79a', g: 180, sz: 1
    });
  }
  trayFlash(x, y, w, h, fx);
}
function drawPickleTray(x, y, w, h, n, max, t, fx) {
  fx = fx || 0;
  trayBase(x, y, w, h);
  var lvl = clamp(n / max, 0, 1);
  if (n <= 0) {
    trayInnerShade(x, y, w, h);
    return;
  }
  var bump = Math.round(Math.sin(fx * Math.PI) * 2);
  /* salamura: açık, parlak */
  ctx.globalAlpha = .38;
  fr(x + 3, y + h - 11, w - 6, 5, '#9dbe45');
  ctx.globalAlpha = .30;
  hl(x + 4, y + h - 11, w - 8, '#e2efa4');
  ctx.globalAlpha = 1;
  var topY = drawFill(x, y - bump, w, h, lvl, 4.7, pickleSlice);
  /* yüzey parıltısı */
  for (var g2 = 0; g2 < 6; g2++) {
    ctx.globalAlpha = .5;
    px(x + 5 + hash1(g2 * 3.9) * (w - 10), topY + 1 + Math.round(Math.sin(t * 2 + g2) * .6), '#eaf6b8');
    ctx.globalAlpha = 1;
  }
  trayInnerShade(x, y, w, h);
  trayFlash(x, y, w, h, fx);
}
function drawFriesTray(x, y, w, h, n, max, t, fx) {
  fx = fx || 0;
  trayBase(x, y, w, h);
  var lvl = clamp(n / max, 0, 1);
  if (n <= 0) {
    trayInnerShade(x, y, w, h);
    return;
  }
  var bump = Math.round(Math.sin(fx * Math.PI) * 2);
  var topY = drawFill(x, y - bump, w, h, lvl, 9.2, fryStick);
  trayInnerShade(x, y, w, h);
  /* tuz taneleri */
  for (var sI = 0; sI < 8; sI++) {
    ctx.globalAlpha = .5;
    px(x + 5 + hash1(sI * 5.9) * (w - 10), topY + 1 + hash1(sI * 2.3) * 4, '#ffffff');
    ctx.globalAlpha = 1;
  }
  trayFlash(x, y, w, h, fx);
}
function drawYogurtTray(x, y, w, h, n, max, t, fx) {
  fx = fx || 0;
  trayBase(x, y, w, h);
  var lvl = clamp(n / max, 0, 1);
  var F = trayFloor(x, y, w, h);
  var zh = F.on - F.zemin;

  if (n <= 0) {
    /* boş: zeminde kalan ince sıva izleri */
    ctx.globalAlpha = .42;
    for (var e0 = 0; e0 < 6; e0++) {
      ell(F.ix + 5 + e0 * 7, F.on - 2 - (e0 % 2) * 3, 3, 1, '#cfc7b0');
    }
    ctx.globalAlpha = 1;
    trayInnerShade(x, y, w, h);
    return;
  }

  var bump = Math.round(Math.sin(fx * Math.PI) * 2);
  /* kütlenin kapladığı derinlik ve arka duvarı aşma payı */
  var kaplama = 0.10 + 0.90 * lvl;
  var kabarma = Math.round(lvl * 6);
  var arka = Math.max(F.arka - kabarma, y + 2);
  var ustSinir = Math.max(arka, F.on - Math.round(zh * kaplama)) - bump;

  ctx.save();
  ctx.beginPath();
  ctx.rect(F.ix - 1, y, F.iw + 2, (F.on + 2) - y);
  ctx.clip();

  /* --- kütle: her sütunun kendi arka sınırı, kenarlarda içeri çekik --- */
  /* Çukur derinliği toplam kütlenin küçük bir payı olmalı; sabit 5px
     olunca az dolu küvette bütün yoğurdu yiyip ince bir bulut bırakıyordu. */
  var kutle = F.on - ustSinir;
  var cukurlar = [
    { p: 0.70, g: 8, d: Math.max(1, Math.round(kutle * 0.26)) },
    { p: 0.28, g: 6, d: Math.max(1, Math.round(kutle * 0.15)) }
  ];
  for (var c = 0; c < F.iw; c++) {
    var u = c / (F.iw - 1);
    /* kenarlarda kütle biraz geride başlar: küvete yayılmış his */
    var kenar = Math.round(Math.pow(Math.abs(u - .5) * 2, 2.4) * Math.max(1, kutle * 0.16));
    /* kaşık çukurları: yüzeyi öne doğru oyar */
    var oyuk = 0;
    for (var ci = 0; ci < cukurlar.length; ci++) {
      var cu = cukurlar[ci];
      var d = Math.abs(c - cu.p * F.iw);
      if (d < cu.g) oyuk += Math.round(Math.cos(d / cu.g * Math.PI * .5) * cu.d);
    }
    var puruz = Math.round((hash1(c * 0.9 + 3.1) - .5) * 1.6);
    var cTop = ustSinir + kenar + oyuk + puruz;
    if (cTop > F.on - 1) cTop = F.on - 1;

    /* sütunu arkadan öne doldur: uzaklaştıkça koyu */
    for (var yy = cTop; yy < F.on; yy++) {
      var v = (yy - cTop) / Math.max(1, F.on - cTop);
      var col = v < .16 ? '#efe8d6' : (v < .45 ? '#ded6c0' : (v < .78 ? '#c9c0a9' : '#b0a790'));
      px(F.ix + c, yy, col);
    }
    /* arka kenarda parlak yüzey çizgisi */
    px(F.ix + c, cTop, '#fbf7ea');
    /* komşusundan geride kalıyorsa kenarına gölge (çukur belirginleşsin) */
    var solFark = c > 0 ? 0 : 0;
    if (c > 0) {
      var oncekiTop = ustSinir + Math.round(Math.pow(Math.abs((c - 1) / (F.iw - 1) - .5) * 2, 2.4) * Math.max(1, kutle * 0.16));
      if (cTop > oncekiTop + 1) {
        ctx.globalAlpha = .26;
        for (var f = 0; f < Math.min(cTop - oncekiTop, 3); f++) px(F.ix + c, cTop - f, '#8d8574');
        ctx.globalAlpha = 1;
      }
    }
  }

  /* --- kaşık çukurlarının dibinde biriken su --- */
  for (var ci2 = 0; ci2 < cukurlar.length; ci2++) {
    var cc = cukurlar[ci2];
    var cxx = Math.round(F.ix + cc.p * F.iw);
    var cyy = ustSinir + cc.d + 1;
    ctx.globalAlpha = .30;
    ell(cxx, cyy + 1, Math.round(cc.g * .5), 2, '#9a9280');
    ctx.globalAlpha = .55;
    ell(cxx - 1, cyy, Math.round(cc.g * .3), 1, '#ffffff');
    ctx.globalAlpha = 1;
  }

  /* --- yüzeyde girdap izleri (kaşıkla karıştırılmış) --- */
  for (var sI = 0; sI < 3; sI++) {
    var swY = ustSinir + 3 + sI * 4;
    if (swY > F.on - 2) break;
    ctx.globalAlpha = .22;
    for (var qq = 0; qq < F.iw - 6; qq++) {
      var wy = swY + Math.round(Math.sin(qq * .30 + sI * 1.7) * 1.1);
      px(F.ix + 3 + qq, wy, sI % 2 ? '#ffffff' : '#c9c1ab');
    }
    ctx.globalAlpha = 1;
  }
  /* --- yüzey kabarcıkları --- */
  for (var bI = 0; bI < 5; bI++) {
    ctx.globalAlpha = .5;
    px(Math.round(F.ix + 3 + hash1(bI * 3.3) * (F.iw - 6)),
       Math.round(ustSinir + 2 + hash1(bI * 5.7) * (zh * .5)), '#ffffff');
    ctx.globalAlpha = 1;
  }
  /* --- arka duvara temas gölgesi --- */
  ctx.globalAlpha = .12;
  fr(F.ix, ustSinir - 1, F.iw, 1, '#8a8272');
  ctx.globalAlpha = 1;

  ctx.restore();
  trayInnerShade(x, y, w, h);
  trayFlash(x, y, w, h, fx);
}


/* ---------- slash izi ----------
   Bıçak darbesinin bıraktığı iz. Kalınlık çizgiye DİK verilir;
   dikey verilince eğik izler topak gibi kalınlaşıyordu.
   Ortası en kalın, uçları sivri: hızlı bir yay hissi.
   Bıçağın kendisi hiç çizilmez.                                   */
function slashCiz(x0, y0, dx, dy, boy, kalinlik, renk, alfa) {
  /* çizgiye dik birim vektör */
  var nx = -dy, ny = dx;
  ctx.globalAlpha = alfa;
  var adim = Math.max(1, Math.round(boy));
  for (var q = 0; q <= adim; q++) {
    var u = q / adim;
    var k = Math.sin(u * Math.PI);            /* uçlarda 0, ortada 1 */
    var kal = k * kalinlik;
    if (kal < .35) continue;
    var cx0 = x0 + dx * q;
    var cy0 = y0 + dy * q;
    var yar = Math.max(0, Math.round(kal));
    for (var o = -yar; o <= yar; o++) {
      px(Math.round(cx0 + nx * o), Math.round(cy0 + ny * o), renk);
    }
  }
  ctx.globalAlpha = 1;
}

function drawSlash(C) {
  if (!C.slash || !C.slash.length) return;
  for (var i = 0; i < C.slash.length; i++) {
    var s0 = C.slash[i];
    var k = clamp(s0.t, 0, 1);
    if (k <= 0) continue;
    var dx = Math.cos(s0.aci), dy = Math.sin(s0.aci);
    /* iz sönerken kısalır */
    var boy = s0.boy * (0.62 + 0.38 * k);
    var x0 = s0.x - dx * boy * .5, y0 = s0.y - dy * boy * .5;

    /* 1) dış hava dalgası — geniş, çok soluk */
    slashCiz(x0, y0, dx, dy, boy, 2.1 * k, '#ffe9a3', .10 * k);
    /* 2) sıcak kenar */
    slashCiz(x0, y0, dx, dy, boy, 1.15 * k, '#ffd27a', .40 * k);
    /* 3) keskin çekirdek — 1 piksel */
    slashCiz(x0, y0, dx, dy, boy, 0.55 * k, '#ffffff', .95 * k);

    /* 4) çarpma kıvılcımı: yalnız izin ilk anında, küçük */
    if (k > .70) {
      var a2 = (k - .70) / .30;
      ctx.globalAlpha = a2 * .9;
      px(Math.round(s0.x), Math.round(s0.y), '#ffffff');
      px(Math.round(s0.x + dx * 2), Math.round(s0.y + dy * 2), '#fff0c4');
      px(Math.round(s0.x - dx * 2), Math.round(s0.y - dy * 2), '#fff0c4');
      ctx.globalAlpha = 1;
    }
  }
}

function drawCutBoard(x, y, w, h, C, t) {
  /* ahşap tahta */
  ctx.globalAlpha = .3; rrect(x + 3, y + 8, w - 4, h - 12, 3, '#000'); ctx.globalAlpha = 1;
  rrect(x + 2, y + 6, w - 4, h - 12, 3, '#7a5230');
  rrect(x + 2, y + 5, w - 4, h - 12, 3, '#c49a68');
  rrect(x + 4, y + 7, w - 8, h - 16, 2, '#dcb480');
  for (var g = 0; g < 5; g++) { ctx.globalAlpha = .3; hl(x + 5, y + 9 + g * 5, w - 10, '#c09660'); ctx.globalAlpha = 1; }
  hl(x + 4, y + 6, w - 8, '#eccb96');
  /* çentikler */
  for (var s = 0; s < 6; s++) { ctx.globalAlpha = .25; ln(x + 8 + s * 6, y + 12, x + 10 + s * 6, y + 20, '#8a6a42'); ctx.globalAlpha = 1; }

  var cx = x + w / 2 - 6;
  if (C.potato) {
    /* patates (doğrandıkça küçülür) */
    var k = 1 - C.prog;
    var pw = Math.max(2, Math.round(11 * k));
    ell(cx, y + 20, pw, 6, '#8a6432');
    ell(cx, y + 19, pw, 6, '#b98b46');
    ell(cx - 2, y + 17, Math.max(1, pw - 3), 2, '#d8ab63');
    px(cx + 2, y + 18, '#6d4d24');
    /* kesilen dilimler */
    var slices = Math.floor(C.prog * 6);
    for (var i = 0; i < slices; i++) {
      fr(cx + 8 + i * 3, y + 16, 2, 8, P.p4);
      fr(cx + 8 + i * 3, y + 16, 2, 7, '#f2e0a8');
      px(cx + 8 + i * 3, y + 16, '#fff6d0');
    }
    /* bıçak çizilmez: hızlı hareket görünmez, iz görünür */
    drawSlash(C);
    /* ilerleme */
    if (C.prog > 0 && C.prog < 1) bar(x + 6, y - 4, w - 12, 5, C.prog, P.p1);
  } else {
    /* Tahta daraldi: iki satirlik uzun etiket tasiyordu. */
    txt('PATATES', x + w / 2, y + 20, 'rgba(60,40,24,.45)', { align: 'c' });
  }
  /* doğranmış patates kabı */
  var bx = x + w - 17, by = y + h - 22;
  fr(bx, by, 15, 14, '#8a929b');
  fr(bx + 1, by + 1, 13, 12, '#b6bec6');
  fr(bx + 1, by + 1, 13, 3, '#d6dee6');
  var raw = Math.min(10, C.raw);
  for (var r = 0; r < raw; r++) {
    var rx = bx + 2 + (r % 5) * 2.4, ry = by + 9 - Math.floor(r / 5) * 4;
    fr(rx, ry, 2, 5, '#e8d59a');
    px(rx, ry, '#f8ecc0');
  }
  if (C.raw > 0) txt('' + C.raw, bx + 14, by - 8, '#f8ecc0', { align: 'r', outline: 'rgba(0,0,0,.5)' });
}

/* ---------- fritöz ---------- */
/* F: {state:'idle'|'fry'|'done', t, dur, load, basketY} */
function drawFryer(x, y, w, h, F, t) {
  /* --- FRITOZ (bastan tasarlandi) ---
     Arkada sicrama paneli, ortada GOMME yag haznesi, ONDE yatay kontrol
     paneli. Kontrol paneli eskiden sagda duruyordu; sepetin sapi da saga
     uzandigi icin sap govdenin icine giriyordu. Panel one alindi, sap ise
     hazne kenarindan YUKARI kalkiyor: artik hicbir seyin icine girmiyor. */
  var bodyY = y + 7;                                  /* govde ust yuzeyi */
  var panH = 12;                                      /* on panel yuksekligi */
  var vatX = x + 5, vatW = w - 10;
  var vatY = bodyY + 3, vatH = h - panH - 13, vatB = vatY + vatH;

  /* --- arka sicrama paneli --- */
  fr(x + 3, y, w - 6, bodyY - y, '#356669');
  fr(x + 4, y, w - 8, bodyY - y - 1, '#5aa3a6');
  hl(x + 4, y, w - 8, '#7cc4c6');
  for (var sp = 0; sp < 6; sp++)
    px(x + 8 + hash1(sp * 2.7) * (w - 18), y + 1 + hash1(sp * 5.1) * 4, 'rgba(196,164,92,.45)');

  /* --- govde --- */
  var bh0 = h - (bodyY - y);
  fr(x, bodyY, w, bh0, '#3f7d80');
  fr(x + 1, bodyY + 1, w - 2, bh0 - 2, '#4e9295');
  hl(x + 1, bodyY, w - 2, '#7cc4c6');
  hl(x, y + h - 1, w, '#24494b');
  vl(x, bodyY, bh0, '#356669');
  vl(x + w - 1, bodyY, bh0, '#2b5a5c');

  /* --- gomme yag haznesi --- */
  fr(vatX - 1, vatY - 1, vatW + 2, vatH + 2, '#24494b');
  hl(vatX - 1, vatY - 1, vatW + 2, '#1b3739');
  fr(vatX, vatY, vatW, vatH, '#2a2317');
  var oilY = vatY + 2, oilH = vatB - oilY;
  /* derinlik: kenarlar koyu, orta acik, ustte parlama */
  fr(vatX, oilY, vatW, oilH, '#7a5a14');
  fr(vatX + 1, oilY + 1, vatW - 2, oilH - 3, '#a8811f');
  fr(vatX + 2, oilY + 2, vatW - 4, oilH - 6, '#bd932c');
  fr(vatX + 3, oilY + 2, vatW - 6, 3, '#d0a93c');
  for (var i = 0; i < vatW; i++)
    px(vatX + i, oilY + Math.sin(t * 3 + i * .4) * .8, '#c9a03a');
  /* vitrin camindan gelen yansima */
  ctx.globalAlpha = .15;
  fr(vatX + 4, oilY + 2, Math.round(vatW * .3), 2, '#fff8dc');
  ctx.globalAlpha = 1;
  if (F.state === 'fry') {
    for (var b = 0; b < 12; b++) {
      var bx2 = vatX + 1 + hash1(b * 3.1) * (vatW - 3);
      var by2 = ((t * (18 + b * 4) + b * 9) % (vatH - 4));
      px(bx2, vatB - 1 - by2, '#e6c463');
      if (chance(.006)) part({ x: bx2, y: oilY, vx: rnd(-4, 4), vy: rnd(-18, -8), life: .5, col: '#ffe9a3', g: 30, sz: 1 });
    }
  }
  /* --- REZISTANS: yagin icinde gorunen isitici boru ---
     Gercek fritozde en belirgin parca; cizimde hic yoktu. */
  var rzY = vatY + Math.round(vatH * .34);
  for (var rz = 0; rz < 2; rz++) {
    var ry2 = rzY + rz * 4;
    ctx.globalAlpha = .55;
    fr(vatX + 3, ry2, vatW - 6, 2, '#8b949d');
    hl(vatX + 3, ry2, vatW - 6, '#c6ced5');
    ctx.globalAlpha = 1;
    px(vatX + 3, ry2, '#6b737d'); px(vatX + vatW - 4, ry2, '#6b737d');
  }
  /* iki boruyu birlestiren dirsek */
  ctx.globalAlpha = .55;
  fr(vatX + vatW - 5, rzY, 2, 5, '#8b949d');
  ctx.globalAlpha = 1;

  /* haznenin arka kenarindaki suzme askisi */
  fr(vatX + vatW - 10, vatY - 2, 8, 2, '#9aa3ac');
  hl(vatX + vatW - 10, vatY - 2, 8, '#d6dde3');

  /* --- SEPET: tel orgu, kenarli ---
     'Cift hazne' (UPG 'fryer' sv3) alindiginda hazne ikiye bolunur;
     sepet de ikiye bolunmeli. Eskiden ayirac ciziliyor ama sepet tek
     ve tam genislikte kaliyordu. */
  var fkd0 = (typeof UV === 'function' && typeof G !== 'undefined')
    ? UV(G, 'fryer') : 0;
  var bskH = 13;
  var bskY = vatY - 2 + (F.basketY || 0);
  var sepetler = fkd0 >= 3
    ? [[vatX + 3, (vatW >> 1) - 5], [vatX + (vatW >> 1) + 2, (vatW >> 1) - 5]]
    : [[vatX + 4, vatW - 8]];
  for (var si = 0; si < sepetler.length; si++) {
  var bskX = sepetler[si][0], bskW = sepetler[si][1];
  /* alt golge yalniz hazne icinde kalirsa cizilir */
  if (bskY + bskH < vatB) {
    ctx.globalAlpha = .30;
    fr(bskX + 1, bskY + bskH, bskW - 2, Math.min(2, vatB - (bskY + bskH)), '#000');
    ctx.globalAlpha = 1;
  }
  fr(bskX, bskY + 1, bskW, bskH - 1, '#3a424a');
  fr(bskX + 1, bskY + 2, bskW - 2, bskH - 3, '#2c333a');
  for (var gx = 0; gx < bskW - 2; gx += 3) {
    ctx.globalAlpha = .50; vl(bskX + 1 + gx, bskY + 2, bskH - 3, '#8b949d'); ctx.globalAlpha = 1;
  }
  ctx.globalAlpha = .22;
  hl(bskX + 1, bskY + 4, bskW - 2, '#66707a');
  hl(bskX + 1, bskY + bskH - 3, bskW - 2, '#66707a');
  ctx.globalAlpha = 1;
  fr(bskX, bskY, bskW, 2, '#9aa3ac');
  hl(bskX, bskY, bskW, '#e2e8ee');
  vl(bskX, bskY, bskH, '#b9c2ca');
  vl(bskX + bskW - 1, bskY, bskH, '#8e97a0');
  if (F.load > 0) {
    var golden = F.state === 'done' || F.prog > .6;
    var fcol = golden ? [P.p0, P.p1, P.p2] : ['#f5e3b0', '#e8d59a', '#cbb87e'];
    var kont = golden ? '#5a3f10' : '#8d7c52';
    var adet = Math.min(16, 3 + F.load * 2);
    for (var i2 = 0; i2 < adet; i2++) {
      var yat = hash1(i2 * 9.1) > .45;
      var fw = yat ? 6 : 2, fh = yat ? 2 : 4;
      var fx = bskX + 2 + Math.floor(hash1(i2 * 1.7) * (bskW - 5 - fw));
      var fy = bskY + 3 + Math.floor(hash1(i2 * 4.3) * (bskH - 5 - fh));
      fr(fx + 1, fy + 1, fw, fh, kont);   /* kayik golge: ust uste binenler ayrilsin */
      fr(fx, fy, fw, fh, fcol[2]);
      fr(fx, fy, fw - (yat ? 1 : 0), fh - (yat ? 0 : 1), fcol[1]);
      px(fx, fy, fcol[0]);
    }
  }
  /* Suzulme damlasi yalniz sepet yagin USTUNDEYKEN dusebilir. */
  if (F.load > 0 && bskY + bskH < oilY && chance(.10))
    part({ x: bskX + rnd(2, bskW - 2), y: bskY + bskH, vx: 0, vy: rnd(4, 12),
           life: .35, col: '#c9a03a', g: 90, sz: 1 });

  /* --- SEPET YAGIN ICINDE ---
     Sepet en son cizildigi icin yagin ONUNDE duruyormus gibi okunuyordu.
     Cozum: yuzeyin ALTINDA kalan kismini yag tonuna boya, yag yuzeyini ve
     hazne duvarlarini sepetin UZERINE ciz. */
  var batUst = Math.max(bskY, oilY), batAlt = Math.min(bskY + bskH, vatB);
  if (batAlt > batUst) {
    ctx.globalAlpha = .36;                                  /* yag filmi */
    fr(bskX - 1, batUst, bskW + 2, batAlt - batUst, '#c9a03a');
    ctx.globalAlpha = .32;                                  /* su cizgisi kirilmasi */
    fr(bskX - 1, batUst, bskW + 2, 1, '#ffe9a3');
    ctx.globalAlpha = 1;
  }
  /* sepetin yaga dusurdugu golge */
  if (bskY + bskH < vatB - 1) {
    ctx.globalAlpha = .30;
    fr(bskX, Math.max(oilY + 1, bskY + bskH), bskW,
       Math.min(3, vatB - 1 - (bskY + bskH)), '#5a3f10');
    ctx.globalAlpha = 1;
  }
  }   /* <- sepet dongusu biter: cift haznede iki sepet cizildi */

  /* yag yuzeyi sepetin ONUNDEN gecer */
  for (var yi = 0; yi < vatW; yi++)
    px(vatX + yi, oilY + Math.sin(t * 3 + yi * .4) * .8, '#d8b44a');
  /* kizarirken kabarciklar sepetin de onunde yukselir */
  if (F.state === 'fry') {
    for (var fb = 0; fb < 6; fb++) {
      var fbx = bskX + 1 + hash1(fb * 7.3) * (bskW - 2);
      var fby = ((t * (22 + fb * 5) + fb * 13) % (vatB - oilY - 2));
      px(fbx, vatB - 2 - fby, '#ffe9a3');
    }
  }
  /* haznenin ic yan duvarlari + ON dudagi sepetin uzerine: oyugun ICINDE kalsin */
  ctx.globalAlpha = .50;
  vl(vatX, vatY, vatH, '#4a3410');
  vl(vatX + vatW - 1, vatY, vatH, '#4a3410');
  ctx.globalAlpha = 1;
  fr(vatX - 1, vatB - 2, vatW + 2, 2, '#24494b');
  hl(vatX - 1, vatB - 2, vatW + 2, '#4e9295');
  /* --- SAP: her sepetin kendi sapi. Sepet kenarina percinli, YUKARI
     kalkik; ust ucu haznenin disinda kalir -> yaga da govdeye de girmez. */
  for (var sj = 0; sj < sepetler.length; sj++) {
    var sbX = sepetler[sj][0], sbW = sepetler[sj][1];
    var ax = sbX + sbW - 5, ay = bskY + 1;
    disc(ax, ay + 1, 2, '#6e7780');
    disc(ax, ay + 1, 1, '#c8d0d8');
    for (var q = 0; q <= 8; q++) {
      var qy = ay - q, qx = ax + Math.round(q * 0.36);
      fr(qx, qy, 2, 1, '#8e97a0');
      px(qx, qy, '#d6dde3');
    }
    var gxT = ax + 3, gyT = ay - 12;
    fr(gxT - 5, gyT, 12, 5, '#1a2026');
    fr(gxT - 4, gyT + 1, 10, 3, '#39424b');
    hl(gxT - 4, gyT + 1, 10, '#5a656f');
    hl(gxT - 4, gyT + 3, 10, '#232a31');
  }

  /* --- ON KONTROL PANELI: zamanlayici + isi dugmesi + calisma lambasi --- */
  var pY = vatB + 3, pX = x + 3, pW = w - 6;
  fr(pX, pY, pW, panH - 3, '#2f3740');
  rc(pX, pY, pW, panH - 3, '#59636d');
  fr(pX + 2, pY + 1, 22, 7, '#160c0c');
  var secs = Math.max(0, Math.ceil(F.dur - F.t));
  var ekran = F.state === 'done' ? 'OK' : (F.state === 'idle' ? '180' : ('' + secs));
  txt(ekran, pX + 13, pY + 1,
      F.state === 'done' ? '#7dff7a' : (F.state === 'idle' ? '#c08040' : '#ff9a4a'),
      { align: 'c' });
  var kx = pX + pW - 7, ky = pY + 4;
  disc(kx, ky, 3, '#8b959e');
  disc(kx, ky, 2, '#c8d0d8');
  ln(kx, ky, kx + Math.cos(t) * 2, ky + Math.sin(t) * 2, '#2f3740');
  var ledOn = F.state === 'fry';
  disc(kx - 9, ky, 2, '#1b2026');
  px(kx - 9, ky, ledOn ? '#ff7a3a' : '#4a2a22');
  if (ledOn) { ctx.globalAlpha = .30; disc(kx - 9, ky, 2, '#ff7a3a'); ctx.globalAlpha = 1; }

  if (F.state === 'fry' && chance(.07)) smoke(vatX + rnd(2, vatW - 2), vatY, 1, 'rgba(255,240,210,.5)');

  /* --- KADEME GORUNUMLERI ---
     'Cift hazne' (sv3) ve 'Otomatik fritoz' (sv4) simdiye kadar gorsel
     olarak hic ayrismiyordu; oyuncu parayi odeyip ayni fritozu
     goruyordu (bicak/kagit/icecekle ayni sorun). */
  var fkd = (typeof UV === 'function' && typeof G !== 'undefined')
    ? UV(G, 'fryer') : 0;
  if (fkd >= 3) {
    /* hazneyi ortadan bolen celik ayirac + ikinci sepetin ustu */
    var dvx = vatX + (vatW >> 1) - 1;
    fr(dvx, vatY, 2, vatH, '#24494b');
    fr(dvx, vatY, 1, vatH, '#5aa3a6');
    hl(dvx - 1, vatY - 1, 4, '#7cc4c6');
    /* (ikinci sepet artik gercekten ciziliyor, sahte sap kaldirildi) */
  }
  if (fkd >= 4) {
    /* otomatik kaldirma kolu: hazne boyunca yatay ray + motor */
    fr(vatX - 2, vatY - 8, vatW + 4, 2, '#8b949d');
    hl(vatX - 2, vatY - 8, vatW + 4, '#d6dde3');
    fr(vatX + vatW - 8, vatY - 12, 8, 5, '#2f3740');
    fr(vatX + vatW - 7, vatY - 12, 6, 4, '#5f6672');
    disc(vatX + vatW - 4, vatY - 10, 1,
         Math.sin(t * 9) > 0 ? '#7dff7a' : '#2a6a28');
  }

}

/* Tek patates: yuvarlaga yakin, hafif yumurta bicimli, ustten isikli,
   uzerinde goz benekleri. Eskiden 4px yassi elipsti ve sepette
   "patates yok" gibi duruyordu. */
function drawPotato(cx, cy, r, k) {
  var h = hash1(k * 3.7);
  var rw = Math.max(3, Math.round(r * (0.92 + h * 0.26)));
  var rh = Math.max(3, Math.round(r * (0.78 + hash1(k * 1.9) * 0.22)));
  var yat = hash1(k * 5.3) > .55;              /* kimi yatik dursun */
  if (yat) { var t0 = rw; rw = rh + 1; rh = t0 - 1; }
  cx = Math.round(cx); cy = Math.round(cy);
  /* zemin golgesi */
  ctx.globalAlpha = .28; ell(cx, cy + rh - 1, rw, 2, '#000'); ctx.globalAlpha = 1;
  /* govde: koyu kenar -> orta -> ust isik.
     Kenar koyu tutuluyor ki sepette ust uste binince tek kutle olmasin. */
  ell(cx, cy, rw, rh, '#54390f');
  ell(cx, cy, rw - 1, rh - 1, '#9c6f2e');
  ell(cx, cy - 1, rw - 1, rh - 1, '#b98b46');
  ell(cx - 1, cy - 1, Math.max(1, rw - 2), Math.max(1, rh - 2), '#c99a52');
  /* ust parlaklik */
  ell(cx - Math.round(rw * .35), cy - Math.round(rh * .45),
      Math.max(1, Math.round(rw * .42)), Math.max(1, Math.round(rh * .32)), '#dcb271');
  px(cx - Math.round(rw * .4), cy - Math.round(rh * .5), '#eec98d');
  /* goz benekleri */
  for (var g = 0; g < 3; g++) {
    var a = hash1(k * 7.1 + g * 2.3) * 6.28;
    var bx = cx + Math.round(Math.cos(a) * rw * .45);
    var by = cy + Math.round(Math.sin(a) * rh * .45);
    if (hash1(k + g) > .45) px(bx, by, '#7a5424');
  }
}

/* ---------- patates sepeti (patatesler içinde) ---------- */
/* Patates kasası hiç değişmez: bir kez çizilip saklanır.
   Her karede yeniden çizmek 3.5 ms yiyordu. */
var POTBIN = null;
function drawPotatoBin(x, y, w, h, t) {
  if (POTBIN && POTBIN.w === w && POTBIN.h === h) {
    ctx.drawImage(POTBIN.c, (x | 0) - 2, (y | 0) - 2);
    return;
  }
  var oc = document.createElement('canvas');
  oc.width = w + 6; oc.height = h + 6;
  var eskiCtx = ctx;
  ctx = oc.getContext('2d');
  ctx.imageSmoothingEnabled = false;
  potBinPaint(2, 2, w, h);
  ctx = eskiCtx;
  POTBIN = { c: oc, w: w, h: h };
  ctx.drawImage(oc, (x | 0) - 2, (y | 0) - 2);
}
function potBinPaint(x, y, w, h) {
  /* --- dolabin ic oyugu: yalnizca ince bir seritte gorunur --- */
  fr(x, y, w, h, '#3a2a12');
  fr(x + 1, y + 1, w - 2, h - 2, '#4e3a18');
  ctx.globalAlpha = .40; fr(x + 1, y + 1, w - 2, 3, '#000'); ctx.globalAlpha = 1;

  /* --- SEPET: cercevenin neredeyse tamamini kaplar --- */
  var sx = x + 2, sw = w - 4;
  var sy = y + 5, sh = h - 8;               /* sepetin ust kenari ve boyu */
  /* sepet arkasi (ic karanlik) */
  fr(sx, sy, sw, sh, '#5b4420');
  ctx.globalAlpha = .35; fr(sx + 1, sy + 1, sw - 2, 4, '#000'); ctx.globalAlpha = 1;

  /* --- patatesler: sepetin ICINDE, kenardan tasar --- */
  var cx = x + w / 2, baseY = sy + sh - 9, halfW = sw / 2 - 4;
  var items = [];
  /* sepet agzina kadar dolu goruunsun: daha cok ve daha yuksek yigin */
  for (var i = 0; i < 19; i++) items.push(pileSpot(i, cx, halfW, baseY, 15, 7));
  items.sort(function (a, b) { return a[1] - b[1]; });
  for (var k = 0; k < items.length; k++) {
    drawPotato(items[k][0], items[k][1], 5 + (items[k][2] > .6 ? 1 : 0), k * 1.7 + 0.3);
  }

  /* --- on orgu: sepetin alt yarisini kaplar, patateslerin onunde --- */
  var oy = sy + Math.round(sh * .42);       /* orgunun basladigi yer */
  var oh = sy + sh - oy;
  /* yatay serit hasirlar */
  for (var gy = 0; gy < oh; gy += 3) {
    fr(sx, oy + gy, sw, 2, '#7a5a2c');
    hl(sx, oy + gy, sw, '#a5813f');
    ctx.globalAlpha = .30; hl(sx, oy + gy + 1, sw, '#4e3a18'); ctx.globalAlpha = 1;
  }
  /* dikey oruculer: hasirin altindan gecip ustune cikiyormus gibi */
  for (var gx = 0; gx < sw; gx += 4) {
    ctx.globalAlpha = .55; vl(sx + gx, oy, oh, '#6d5228');
    ctx.globalAlpha = .32; vl(sx + gx + 1, oy, oh, '#c09a52');
    ctx.globalAlpha = 1;
  }
  /* --- sepetin ust kenari (cember): patateslerin onunden gecer --- */
  fr(sx - 1, sy, sw + 2, 3, '#8a6a3a');
  fr(sx - 1, sy, sw + 2, 2, '#a5813f');
  hl(sx - 1, sy, sw + 2, '#c9a45e');
  /* kenar orgusu */
  for (var rx = 0; rx < sw + 2; rx += 3) {
    ctx.globalAlpha = .40; px(sx - 1 + rx, sy + 1, '#6d5228'); ctx.globalAlpha = 1;
  }
  /* --- sepetin alt tabani ve golgesi --- */
  fr(sx - 1, sy + sh - 2, sw + 2, 2, '#5b4420');
  hl(sx - 1, sy + sh - 2, sw + 2, '#7a5a2c');
  ctx.globalAlpha = .35; fr(x + 1, y + h - 3, w - 2, 2, '#000'); ctx.globalAlpha = 1;

  /* --- dolap cercevesi --- */
  rc(x, y, w, h, '#2e2010');
  hl(x + 1, y + 1, w - 2, '#6d5228');
  vl(x + 1, y + 1, h - 2, '#5b4420');
}

/* ---------- içecek makinesi (Fanta + Kola) ---------- */
/* Icecek dolabi. Blender: blender/models/icecek.py
   Eskiden duz bir levha uzerinde iki renkli dikdortgendi; makinenin
   govdesi yoktu. Artik kademeler var: celik cerceve -> isikli lezzet
   panelleri -> KOYU SERVIS OYUGU -> tavanda muslukler -> dipte
   izgarali damlalik. Derinlik bu kademelerden dogar.
   UPG 'drink' dort kademeli, cizim de artik kademeye gore degisir. */
function drawDrinkMachine(x, y, w, h, D, t) {
  var kd = (typeof UV === 'function' && typeof G !== 'undefined')
    ? clamp(UV(G, 'drink'), 1, 4) : 1;
  var yari = w >> 1;

  /* --- govde: celik cerceve --- */
  ctx.globalAlpha = .30; fr(x + 1, y + 2, w, h, '#000'); ctx.globalAlpha = 1;
  fr(x, y, w, h, '#6f777f');
  fr(x + 1, y, w - 2, h - 1, '#b8c0c7');
  fr(x + 1, y, 4, h - 1, '#dde3e8');                  /* sol isik */
  ctx.globalAlpha = .20; fr(x + w - 5, y, 4, h - 1, '#000'); ctx.globalAlpha = 1;
  /* ust ve alt koyu bant */
  fr(x - 1, y - 3, w + 2, 5, '#2b3138');
  fr(x, y - 3, w, 4, '#3f454e');
  hl(x, y - 3, w, '#7d868e');
  fr(x - 1, y + h - 3, w + 2, 5, '#2b3138');
  fr(x, y + h - 3, w, 4, '#3f454e');
  hl(x, y + h - 3, w, '#5b626a');

  /* --- iki isikli lezzet paneli --- */
  /* panel 13px iken servis oyuguna 10px kaliyordu ve akan icecek
     2px'e dusup gorunmuyordu */
  var pH = 11, pY = y + 2;
  for (var i = 0; i < 2; i++) {
    var pX = x + 2 + i * (yari - 1), pW = yari - 3;
    if (pW < 6) continue;
    fr(pX - 1, pY - 1, pW + 2, pH + 2, '#2b3138');    /* cerceve */
    var ic = i === 0 ? '#d8641c' : '#8e1c14';
    var ac = i === 0 ? '#f0821c' : '#c0281c';
    var pr = i === 0 ? '#ffb03c' : '#e05a48';
    fr(pX, pY, pW, pH, ic);
    fr(pX, pY, pW - 1, pH - 1, ac);
    hl(pX + 1, pY, pW - 3, pr);                       /* ust isik seridi */
    /* sise grafigi: govde + boyun + kapak */
    var bx = pX + (pW >> 1) - 1;
    var gv = i === 0 ? '#e8dcc0' : '#4a1c10';
    var gi = i === 0 ? '#fffdf2' : '#8a3a20';
    fr(bx - 2, pY + 4, 5, 7, '#2a1408');
    fr(bx - 2, pY + 4, 4, 6, gv);
    vl(bx - 2, pY + 4, 6, gi);
    fr(bx - 1, pY + 2, 3, 3, gv); px(bx - 1, pY + 2, gi);
    fr(bx - 1, pY + 1, 3, 1, i === 0 ? '#d8641c' : '#c0281c');
  }

  /* --- SERVIS OYUGU: koyu, kademeli --- */
  var oY = pY + pH + 1, oH = h - (oY - y) - 4;
  if (oH > 6) {
    fr(x + 3, oY, w - 6, oH, '#232a31');
    fr(x + 4, oY + 1, w - 8, oH - 2, '#3f454e');
    ctx.globalAlpha = .35; fr(x + 4, oY + 1, w - 8, 3, '#000'); ctx.globalAlpha = 1;
    /* oyugun tavani: musluklarin oturdugu tabla */
    fr(x + 3, oY, w - 6, 2, '#2b3138');
    hl(x + 4, oY, w - 8, '#5b626a');

    /* --- muslukler: govde + kol --- */
    for (var m = 0; m < 2; m++) {
      var mx = x + 7 + m * (w - 15);
      fr(mx - 2, oY + 1, 5, 4, '#8b939b');
      fr(mx - 2, oY + 1, 4, 3, '#dde3e8');
      fr(mx - 1, oY + 5, 2, 2, '#6f777f');            /* agiz */
      fr(mx + 2, oY + 2, 1, 4, '#2b3138');            /* kol */
      var tip = m === 0 ? 'fanta' : 'cola';
      if (D && D.pours && D.pours[tip] !== undefined) {
        for (var s = 0; s < oH - 8; s++) {
          var yy = oY + 7 + s;
          px(mx - 1 + (Math.sin(t * 20 + s) > 0 ? 0 : 1), yy,
             m === 0 ? '#d8641c' : '#8e1c14');
          px(mx, yy, m === 0 ? '#f0821c' : '#c0281c');
        }
        if (chance(.4)) part({ x: mx, y: oY + oH - 2, vx: rnd(-8, 8), vy: rnd(-16, -4),
                               life: .3, col: m === 0 ? '#ffb03c' : '#e05a48', g: 120, sz: 1 });
      }
    }
    /* --- damlalik: oyugun dibinde izgarali tepsi --- */
    var dY = oY + oH - 3;
    fr(x + 5, dY, w - 10, 3, '#2b3138');
    hl(x + 5, dY, w - 10, '#8b939b');
    for (var gx = 0; gx < w - 12; gx += 2) px(x + 6 + gx, dY + 1, '#b8c0c7');
  }

  /* --- kademeye gore ek donanim --- */
  if (kd >= 2) {                                      /* Hizli dolum */
    var sx = x + (w >> 1);
    disc(sx, y - 5, 3, '#6f777f');
    disc(sx, y - 5, 2, '#dde3e8');
    ln(sx, y - 5, sx + Math.round(Math.cos(t * 2) * 2), y - 5 + Math.round(Math.sin(t * 2) * 2), '#c0281c');
  }
  if (kd >= 3) {                                      /* Basincli dolum */
    for (var s2 = 0; s2 < 2; s2++) {
      var tx = s2 ? x + w : x - 4;
      fr(tx, y + 3, 4, h - 8, '#6f777f');
      fr(tx, y + 3, 3, h - 9, '#b8c0c7');
      hl(tx, y + 3, 3, '#dde3e8');
      fr(tx, y + 1, 4, 2, '#3f454e');
    }
  }
  if (kd >= 4) {                                      /* Otomatik dolum */
    var dx = x + (w >> 1) - 8;
    fr(dx, y - 8, 16, 5, '#2b3138');
    fr(dx + 1, y - 8, 14, 4, '#141a1f');
    for (var d = 0; d < 5; d++) {
      px(dx + 3 + d * 2, y - 6, (Math.sin(t * 4 + d) > 0) ? '#7dff7a' : '#2a6a28');
    }
  }
}

/* ---------- ayran kazanı ---------- */
function drawAyran(x, y, w, h, n, max, pour, t) {
  /* gövde: paslanmaz kazan */
  fr(x + 1, y + 6, w - 2, h - 10, '#8a929b');
  fr(x + 2, y + 6, w - 4, h - 11, '#c6ccd2');
  fr(x + 3, y + 7, 5, h - 13, '#eef2f6');
  ctx.globalAlpha = .25; fr(x + w - 8, y + 6, 6, h - 11, '#000'); ctx.globalAlpha = 1;
  /* kapak */
  ell(x + w / 2, y + 6, w / 2 - 1, 4, '#9aa3ab');
  ell(x + w / 2, y + 5, w / 2 - 1, 4, '#dfe5ea');
  ell(x + w / 2, y + 4, 4, 2, '#8a929b');
  /* cam seviye penceresi */
  var ix = x + w - 7, iy = y + 10, ih = h - 18;
  fr(ix, iy, 4, ih, '#3f454e');
  var lvl = clamp(n / Math.max(1, max), 0, 1);
  var fh = Math.round((ih - 2) * lvl);
  fr(ix + 1, iy + 1 + (ih - 2 - fh), 2, fh, '#f6f4ea');
  if (fh > 2) px(ix + 1, iy + 1 + (ih - 2 - fh), '#ffffff');
  /* musluk */
  fr(x + 4, y + h - 8, 6, 4, '#7d868e');
  fr(x + 5, y + h - 8, 4, 3, '#e6ebef');
  fr(x + 6, y + h - 5, 2, 3, '#9aa3ab');
  /* etiket */
  fr(x + 4, y + 12, w - 12, 8, '#3f79c0');
  txt('AYRAN', x + 4 + (w - 12) / 2, y + 14, '#ffffff', { align: 'c' });
  if (pour) {
    for (var s2 = 0; s2 < 7; s2++) {
      px(x + 6, y + h - 2 + s2, '#ffffff');
      px(x + 7, y + h - 2 + s2, '#e4e2d8');
    }
    if (chance(.4)) part({ x: x + 7, y: y + h + 4, vx: rnd(-6, 6), vy: rnd(-12, -2), life: .3, col: '#ffffff', g: 120, sz: 1 });
  }
  if (n <= 0) {
    ctx.globalAlpha = .5 + .5 * Math.sin(G.t * 8);
    ctx.globalAlpha = 1;
  }
}

/* Baklava dilimi. Blender: blender/models/sos.py -> sahne_tatli.
   Eski tatli HALKA seklindeydi ve ekranda donut gibi duruyordu.
   Baklavanin kucuk boyutta bile anlasilmasini saglayan iki sey var:
   eskenar dortgen kesim ve ust katin acik tonu. */
function drawBaklava(cx, cy) {
  /* Ilk denemede sadece koyudan aciga bir yigin satirdi: ekranda
     kahverengi bir leke + iki yesil nokta. Baklavayi baklava yapan
     iki sey var ve ikisi de yoktu:
       - UST YUZUN eskenar dortgen kesimi
       - YAN YUZDE gorunen kat kat yufka
     Ikisi de acikca ayri ciziliyor. */
  ctx.globalAlpha = .28; ell(cx, cy + 9, 6, 2, '#000'); ctx.globalAlpha = 1;
  /* yan yuz: dilimin kalinligi, kat cizgileriyle */
  fr(cx - 5, cy + 4, 10, 3, '#8a5a1a');
  hl(cx - 5, cy + 5, 10, '#a8762a');               /* ara yufka */
  vl(cx - 6, cy + 4, 3, '#6b4212'); vl(cx + 5, cy + 4, 3, '#6b4212');
  hl(cx - 5, cy + 6, 10, '#6b4212');
  /* ust yuz: eskenar dortgen */
  var GEN = [2, 4, 6, 4, 2];
  for (var r = 0; r < 5; r++) {
    var hw = GEN[r];
    fr(cx - hw, cy + r, hw * 2, 1, r < 2 ? '#e8bd62' : '#cf9c47');
  }
  hl(cx - 2, cy, 4, '#ffdf9a');                    /* tepe isigi */
  px(cx - 6, cy + 2, '#8a5a1a'); px(cx + 5, cy + 2, '#8a5a1a');   /* kose */
  /* fistik kirigi: ortada */
  px(cx - 1, cy + 2, '#6b9440'); px(cx + 1, cy + 2, '#47692c');
  px(cx, cy + 1, '#93bd63');
}

/* ---------- tatlı tepsisi (baklava) ---------- */
function drawSweetTray(x, y, w, h, n, max, t, fx) {
  fx = fx || 0;
  /* cam vitrin */
  ctx.globalAlpha = .30; fr(x + 1, y + 8, w - 2, h - 14, '#dff0f4'); ctx.globalAlpha = 1;
  fr(x, y + h - 8, w, 6, '#8a929b');
  fr(x + 1, y + h - 8, w - 2, 5, '#c6ccd2');
  rc(x, y + 6, w, h - 12, '#7fa5ad');
  hl(x + 1, y + 7, w - 2, '#e8f6fa');
  /* şerbet tepsisi */
  fr(x + 2, y + h - 14, w - 4, 5, '#8a5a2a');
  fr(x + 2, y + h - 14, w - 4, 4, '#c08a3a');
  var bump = Math.round(Math.sin(fx * Math.PI) * 2);
  var cnt = Math.min(4, Math.ceil(clamp(n / Math.max(1, max), 0, 1) * 4));
  for (var i = 0; i < cnt; i++) {
    var col = i % 2, row = (i / 2) | 0;
    var cx = x + 10 + col * 14, cy = y + h - 22 - row * 8 - bump;
    drawBaklava(cx, cy);
  }
  /* 'TATLI' istasyonun ORTASINA, cam vitrinin uzerine dusuyordu ve
     her sey birbirine giriyordu. Diger istasyonlarla ayni yere
     alindi: alt taban plakasi. */
  txt('TATLI', x + w / 2, y + h - 7, P.au1,
      { align: 'c', outline: 'rgba(0,0,0,.6)' });
}

/* ---------- ayran kazanı ---------- */
/* A: {pour:bool, t} */
/* Ayran kazani. Blender: blender/models/fritoz.py -> sahne_ayran.
   Eskiden dikdortgen bir kutuydu. Gercek kazan SILINDIR govdeli,
   kubbe kapakli; on yuzunde seviye penceresi ve kollu musluk var.
   UPG 'ayran' sv2 (Buyuk kazan) artik govdeyi genisletiyor. */
function drawAyranTank(x, y, w, h, n, max, A, t) {
  var lvl = clamp(n / Math.max(1, max), 0, 1);
  var buyuk = (typeof UV === 'function' && typeof G !== 'undefined')
    ? UV(G, 'ayran') >= 2 : false;
  var cx = Math.round(x + w / 2);
  var r = Math.round((w / 2 - 2) * (buyuk ? 1.0 : 0.86));
  var by = y + 8, bh = h - 18;                 /* silindir govde */

  /* --- ayaklar --- */
  fr(cx - r + 2, by + bh, 3, 4, '#2f3740');
  fr(cx + r - 5, by + bh, 3, 4, '#2f3740');
  /* --- govde: silindir, sol isik sag golge --- */
  ctx.globalAlpha = .28; ell(cx, by + bh + 4, r, 2, '#000'); ctx.globalAlpha = 1;
  fr(cx - r, by, r * 2, bh, '#5f6672');
  fr(cx - r + 1, by, r * 2 - 2, bh - 1, '#aeb5be');
  fr(cx - r + 1, by, 4, bh - 1, '#f2f4f6');            /* sol isik */
  ctx.globalAlpha = .22; fr(cx + r - 5, by, 4, bh - 1, '#000'); ctx.globalAlpha = 1;
  ell(cx, by + bh - 1, r - 1, 2, '#878e99');           /* alt kavis */

  /* --- kubbe kapak --- */
  ell(cx, by, r, 5, '#5f6672');
  ell(cx, by - 1, r, 5, '#aeb5be');
  ell(cx - 2, by - 3, r - 4, 2, '#f2f4f6');
  fr(cx - 2, by - 7, 4, 5, '#2f3740');                 /* tutamak */
  fr(cx - 1, by - 8, 2, 2, '#6b737d');

  /* --- mavi etiket bandi + ayran bardagi --- */
  var ey = by + 5, eh = 11;
  fr(cx - r + 1, ey, r * 2 - 2, eh, '#1c3a66');
  fr(cx - r + 1, ey, r * 2 - 2, eh - 1, '#3f79c0');
  hl(cx - r + 2, ey, r * 2 - 4, '#6b9ad8');
  ctx.globalAlpha = .22; fr(cx + r - 5, ey, 4, eh - 1, '#000'); ctx.globalAlpha = 1;
  /* bardak: gercek ayran bardagiyla ayni his - seffaf govde, beyaz ic */
  var gx = cx - 2;
  fr(gx, ey + 2, 5, 7, '#cfcabc');
  fr(gx, ey + 3, 4, 6, '#f6f4ea');
  hl(gx, ey + 2, 5, '#ffffff');
  px(gx + 4, ey + 5, '#a8c8ee');

  /* --- seviye penceresi: SOL on yuzde dikey cam ---
     Musluk saga alindi (bardak orada doluyor), pencere sola. */
  var wx = cx - r + 4, wy = ey + eh + 2, wh = (by + bh) - wy - 3;
  if (wh > 4) {
    fr(wx, wy, 4, wh, '#1b2126');
    fr(wx, wy, 3, wh - 1, '#2f3740');
    var fh = Math.max(0, Math.round((wh - 2) * lvl));
    fr(wx + 1, wy + 1 + (wh - 2 - fh), 2, fh, '#f6f4ea');
    if (fh > 1) px(wx + 1, wy + 1 + (wh - 2 - fh), '#ffffff');
    vl(wx, wy, wh, '#6b737d');
  }

  /* --- musluk: SAG yanda ---
     cupPos() ayran bardagini unitenin SAG ucune koyuyor; musluk solda
     kalinca soldan dokulup sagdaki bardak doluyordu. */
  var tx = cx + r - 7, ty = by + bh - 9;
  fr(tx - 2, ty, 6, 4, '#5f6672');
  fr(tx - 2, ty, 5, 3, '#d3d8de');
  fr(tx, ty + 4, 2, 3, '#878e99');
  fr(tx - 4, ty - 3, 2, 5, '#2f3740');                 /* kol */
  if (A && A.pour) {
    for (var s = 0; s < 8; s++) {
      px(tx + (Math.sin(t * 22 + s) > 0 ? 0 : 1), ty + 7 + s, '#e8e4d8');
      px(tx + 1, ty + 7 + s, '#ffffff');
    }
    if (chance(.35)) part({ x: tx + 1, y: ty + 15, vx: rnd(-6, 6), vy: rnd(-14, -4),
                            life: .3, col: '#ffffff', g: 110, sz: 1 });
  }
}


/* ---------- ayran kazanı ---------- */
/* A: {pour:bool, t} */


/* ---------- ızgara ---------- */
function drawGrill(x, y, w, h, Gr, t, cap) {
  /* Izgara. Blender: blender/models/sos.py -> sahne_izgara.
     Eskiden gri bir kutuya dikey cizgilerdi; izgara bir YUZEY gibi
     okunmuyordu. Artik ates kutusu ACIK: arkada davlumbaz, ortada
     onden arkaya cubuklar, aralarindan alttaki kor goruluyor.
     Derinlik hissi tam oradan geliyor. */
  var gy0 = y + 13, gy1 = y + 24;          /* izgara bandi */
  /* --- arka davlumbaz --- */
  var ly = y - 4;
  fr(x + 1, ly, w - 2, 8, P.mt3);
  fr(x + 2, ly, w - 4, 7, P.mt1);
  hl(x + 2, ly, w - 4, P.mt0);
  hl(x + 1, ly + 7, w - 2, P.mt5);
  fr(x + (w >> 1) - 7, ly - 4, 14, 4, '#2a2a32');            /* sap */
  fr(x + (w >> 1) - 6, ly - 4, 12, 3, '#454e58');
  /* --- govde ve yan duvarlar --- */
  fr(x, y + 4, w, h - 4, P.mt3);
  fr(x + 1, y + 5, w - 2, h - 6, '#6f767e');
  vl(x + 1, y + 5, h - 6, '#a8b0b8');
  vl(x + w - 2, y + 5, h - 6, '#565d65');
  /* --- ates yatagi: cubuklarin ALTINDA, koyu --- */
  fr(x + 3, y + 4, w - 6, gy1 - y - 4, '#20242a');
  for (var e = 0; e < 14; e++) {
    var ex = x + 5 + hash1(e * 3.1) * (w - 12);
    var ey = gy0 + 1 + hash1(e * 7.7) * (gy1 - gy0 - 3);
    ctx.globalAlpha = .45 + .35 * Math.sin(t * 3 + e * 1.7);
    fr(ex, ey, 2, 2, '#e0500f'); px(ex, ey, '#ff7a2a');
    ctx.globalAlpha = 1;
  }
  /* --- izgara cubuklari: ONDEN ARKAYA, aralarindan kor gorunur --- */
  for (var i = 0; i < w - 8; i += 4) {
    var bx2 = x + 4 + i;
    fr(bx2, gy0, 2, gy1 - gy0, '#727d88');
    vl(bx2, gy0, gy1 - gy0, '#98a4b0');
    vl(bx2 + 1, gy0, gy1 - gy0, '#525b64');
  }
  hl(x + 3, gy0, w - 6, '#8f9aa4');                          /* on profil */
  hl(x + 3, gy1 - 1, w - 6, '#3d444c');
  /* --- on panel: tutamak rayi + iki dugme --- */
  fr(x + 5, y + h - 9, w - 10, 2, '#8f9aa4');
  fr(x + 5, y + h - 10, 2, 4, '#727d88');
  fr(x + w - 7, y + h - 10, 2, 4, '#727d88');
  disc(x + 13, y + h - 15, 2, '#3c4650'); px(x + 13, y + h - 16, '#98a4b0');
  disc(x + w - 13, y + h - 15, 2, '#3c4650'); px(x + w - 13, y + h - 16, '#98a4b0');
  /* --- slot yuvalari: kac dürüm sigdigi TEK BAKISTA anlasilsin --- */
  cap = cap || 1;
  var sut = cap <= 2 ? cap : 2, satir = cap <= 2 ? 1 : 2;
  var gen = w - 8;
  for (var sy = 0; sy < satir; sy++) {
    for (var sx = 0; sx < sut; sx++) {
      var n = sy * sut + sx;
      if (n >= cap) break;
      var cx2 = Math.round(x + 4 + gen / sut * (sx + .5));
      var cy2 = Math.round(y + (satir === 1 ? 23 : 15 + sy * 16));
      var yw = Math.round(gen / sut) - 4, yh = satir === 1 ? 16 : 13;
      /* yuva: hafif cukur + kenar */
      ctx.globalAlpha = .30; fr(cx2 - yw / 2, cy2 - yh / 2, yw, yh, '#000'); ctx.globalAlpha = 1;
      rc(cx2 - yw / 2, cy2 - yh / 2, yw, yh, '#8a929a');
      /* yuvanin icindeki kizil kor */
      for (var e2 = 0; e2 < 3; e2++) {
        ctx.globalAlpha = .22 + .18 * Math.sin(t * 3.4 + n * 2.1 + e2);
        px(cx2 - 4 + e2 * 4, cy2 + (e2 % 2 ? 2 : -2), '#ff7a2a');
        ctx.globalAlpha = 1;
      }
    }
  }
  txt('IZGARA', x + w / 2, y + h - 7, 'rgba(255,255,255,.5)',
      { align: 'c', outline: 'rgba(0,0,0,.45)' });
  if (Gr.slots && Gr.slots.length && chance(.10)) smoke(x + rnd(6, w - 6), y + 10, 1, 'rgba(255,245,225,.45)');
}

/* ---------- ekmek yığını ---------- */
function drawBreadStack(x, y, w, h, label) {
  ell(x + w / 2, y + 22, 18, 7, '#c9cfd6');
  ell(x + w / 2, y + 21, 18, 7, '#e8edf2');
  ell(x + w / 2, y + 20, 15, 5, '#d3dae0');
  for (var i = 0; i < 4; i++) {
    var yy = y + 18 - i * 3;
    ell(x + w / 2, yy, 14 - i, 4, '#d8b581');
    ell(x + w / 2, yy - 1, 14 - i, 4, '#f0d5a8');
    ell(x + w / 2 - 2, yy - 2, 9, 2, '#f8e6c4');
    for (var s = 0; s < 5; s++) px(x + 6 + s * 6 + (i * 2), yy - 1 + (s % 2), '#c39a63');
  }
  if (label !== '') txt(label || 'LAVAŞ', x + w / 2, y + 30, 'rgba(255,255,255,.55)', { align: 'c', outline: 'rgba(0,0,0,.4)' });
}
/* iskender için pide yığını (ekmek istasyonunun üst yarısı) */
function drawPideStack(x, y, w) {
  var cx = x + w / 2;
  ctx.globalAlpha = .25; ell(cx, y + 11, 14, 3, '#000'); ctx.globalAlpha = 1;
  for (var i = 0; i < 3; i++) {
    var yy = y + 9 - i * 3;
    ell(cx, yy, 13 - i, 4, '#a06a2e');
    ell(cx, yy - 1, 13 - i, 4, '#d9a765');
    ell(cx - 1, yy - 2, 8, 2, '#eec78c');
    for (var s = 0; s < 4; s++) px(cx - 7 + s * 5 + i, yy - 1 + (s % 2), '#8a5f31');
  }
}

/* ---------- kağıt istasyonu ---------- */
/* Kagit istasyonu. Blender: blender/models/kagit.py
     sv0  ahsap askida rulo
     sv1  kagit makinesi
     sv2  otomatik sarma - ustte ek motor kutusu (eskiden sv1 ile
          birebir ayniydi, oyuncu 1900 dolarlik farki goremiyordu) */
function drawPaperStation(x, y, w, h, level, busy, t) {
  if (level === 0) {
    /* ================= AHSAP ASKIDA RULO ================= */
    var rcx0 = Math.round(x + w / 2), ry0 = y + 15;
    /* --- aski: iki dikey kol + alt kusak --- */
    fr(x + 1, y + 4, 3, 28, '#4e2e17');
    fr(x + 1, y + 4, 2, 27, '#6b4122');
    hl(x + 1, y + 4, 2, '#8a5730');
    fr(x + w - 4, y + 4, 3, 28, '#4e2e17');
    fr(x + w - 4, y + 4, 2, 27, '#6b4122');
    hl(x + w - 4, y + 4, 2, '#8a5730');
    fr(x + 1, y + 30, w - 2, 3, '#4e2e17');
    fr(x + 1, y + 30, w - 2, 2, '#6b4122');
    hl(x + 2, y + 30, w - 4, '#8a5730');

    /* --- rulo govdesi: hafif cevrik, sag ucta kapak gorunur --- */
    var rw = 8, rh = 7;
    ctx.globalAlpha = .26; ell(rcx0, ry0 + rh + 1, rw, 2, '#000'); ctx.globalAlpha = 1;
    fr(rcx0 - rw, ry0 - rh, rw * 2, rh * 2, '#b9b3a2');
    fr(rcx0 - rw, ry0 - rh, rw * 2 - 1, rh * 2 - 1, '#e8e4d6');
    fr(rcx0 - rw, ry0 - rh, rw * 2 - 1, 3, '#f8f4e8');
    hl(rcx0 - rw + 1, ry0 - rh, rw * 2 - 3, '#ffffff');
    ctx.globalAlpha = .22;
    fr(rcx0 + rw - 4, ry0 - rh, 4, rh * 2 - 1, '#7a7466');
    ctx.globalAlpha = 1;
    /* --- baski seritleri: rulo BOYUNCA (eskiden iki yatay cizgiydi,
           halka gibi durup rulonun yonunu bozuyordu) --- */
    fr(rcx0 - rw + 1, ry0 - 3, rw * 2 - 3, 2, '#b8302a');
    hl(rcx0 - rw + 1, ry0 - 3, rw * 2 - 3, '#d8352c');
    fr(rcx0 - rw + 1, ry0 + 2, rw * 2 - 3, 2, '#2c5369');
    hl(rcx0 - rw + 1, ry0 + 2, rw * 2 - 3, '#2f5f9e');
    /* --- uc kapagi: ic ice sarim halkalari + gobek --- */
    var kx0 = rcx0 + rw - 1;
    ell(kx0, ry0, 2, rh, '#cfc9b8');
    ell(kx0, ry0, 2, rh - 1, '#f8f4e8');
    ctx.globalAlpha = .55;
    ell(kx0, ry0, 2, rh - 3, '#c8c0ac');
    ell(kx0, ry0, 1, rh - 5, '#c8c0ac');
    ctx.globalAlpha = 1;
    px(kx0, ry0, '#b8302a'); px(kx0, ry0 - 1, '#8e1f18');
    /* --- sarkan uc: alt kenari yirtik --- */
    var sy0 = ry0 + rh;
    fr(rcx0 - 5, sy0, 10, 9, '#b9b3a2');
    fr(rcx0 - 5, sy0, 9, 8, '#f8f4e8');
    vl(rcx0 - 5, sy0, 8, '#ffffff');
    hl(rcx0 - 4, sy0 + 3, 7, '#d8352c');
    for (var z = 0; z < 10; z++) {
      px(rcx0 - 5 + z, sy0 + 8 + (z % 3 === 1 ? 1 : 0), '#cfc9b8');
    }

  } else {
    /* ================= KAGIT MAKINESI ================= */
    var oto = level >= 2;
    var mx = x + 1, mw = w - 2, my = y + 8, mh = h - 12;
    ctx.globalAlpha = .30; fr(mx + 1, my + 2, mw, mh, '#000'); ctx.globalAlpha = 1;
    /* govde */
    fr(mx, my, mw, mh, '#232a31');
    fr(mx + 1, my, mw - 2, mh - 1, '#39424b');
    fr(mx + 1, my, 4, mh - 1, '#5f6672');                 /* sol isik */
    ctx.globalAlpha = .24; fr(mx + mw - 5, my, 4, mh - 1, '#000'); ctx.globalAlpha = 1;
    /* ust kapak */
    fr(mx - 1, my - 5, mw + 2, 6, '#232a31');
    fr(mx, my - 5, mw, 5, '#5f6672');
    hl(mx, my - 5, mw, '#aeb5be');
    /* otomatik sarma: ustte ayri motor kutusu + kasnak */
    if (oto) {
      fr(mx + 2, my - 11, 9, 6, '#232a31');
      fr(mx + 3, my - 11, 7, 5, '#5f6672');
      hl(mx + 3, my - 11, 7, '#aeb5be');
      fr(mx + mw - 8, my - 10, 6, 5, '#232a31');
      fr(mx + mw - 7, my - 10, 4, 4, '#878e99');
      var wa = t * 8;
      px(Math.round(mx + mw - 5 + Math.cos(wa) * 1.4),
         Math.round(my - 8 + Math.sin(wa) * 1.4), '#d3d8de');
    }
    /* calisma lambasi */
    disc(mx + mw - 4, my - 3, 1,
         (busy > 0 || oto) ? (Math.sin(t * 16) > 0 ? '#7dff7a' : '#2a6a28') : '#7a4040');

    /* --- cam pencere: rulo UCTAN gorunur --- */
    var pnx = mx + 2, pny = my + 4, pnw = mw - 4, pnh = 16;
    fr(pnx - 1, pny - 1, pnw + 2, pnh + 2, '#141a1f');
    fr(pnx, pny, pnw, pnh, '#1c242b');
    var rcx = Math.round(pnx + pnw / 2), rcy = Math.round(pny + pnh / 2);
    ell(rcx, rcy + 1, 6, 6, '#b9b3a2');
    ell(rcx, rcy, 6, 6, '#e8e4d6');
    ell(rcx - 1, rcy - 1, 4, 4, '#f8f4e8');
    ctx.globalAlpha = .45;
    ring(rcx, rcy, 4, '#c8c0ac'); ring(rcx, rcy, 2, '#c8c0ac');
    ctx.globalAlpha = 1;
    px(rcx, rcy, '#b8302a'); px(rcx, rcy + 1, '#8e1f18');   /* gobek */
    ctx.globalAlpha = .14; fr(pnx + 1, pny + 1, 2, pnh - 3, '#ffffff'); ctx.globalAlpha = 1;

    /* --- testere agizli kesme cubugu --- */
    var kby = my + mh - 11;
    fr(mx + 1, kby, mw - 2, 3, '#232a31');
    hl(mx + 1, kby, mw - 2, '#878e99');
    for (var d3 = 0; d3 < mw - 3; d3 += 2) px(mx + 2 + d3, kby + 3, '#d3d8de');

    /* --- cikan kagit: baskili, alt kenari yirtik --- */
    var uz = busy > 0 ? Math.round(9 * (1 - busy)) : 0;
    if (uz > 0) {
      fr(mx + 2, kby + 4, mw - 4, uz, '#b9b3a2');
      fr(mx + 2, kby + 4, mw - 5, uz - 1, '#f8f4e8');
      hl(mx + 3, kby + 6, mw - 7, '#d8352c');
      if (uz > 5) hl(mx + 3, kby + 9, mw - 7, '#2f5f9e');
      for (var z2 = 0; z2 < mw - 4; z2++) {
        px(mx + 2 + z2, kby + 3 + uz + (z2 % 3 === 1 ? 1 : 0), '#cfc9b8');
      }
      if (chance(.30)) part({ x: mx + rnd(3, mw - 3), y: kby + 4, vx: rnd(-8, 8),
                              vy: rnd(-16, -4), life: .3, col: '#fdfaf0', g: 90, sz: 1 });
    }
    if (level >= 2) txt('OTO', x + w / 2, y + h - 6, P.ok, { align: 'c', outline: 'rgba(0,0,0,.6)' });
  }
}

/* ---------- patates kutusu istasyonu ---------- */
function drawFboxStation(x, y, w, h, ready, t) {
  var cx = x + w / 2;
  /* --- ARKA RAF: bos kutu yigini, yukarida ve soluk --- */
  var ry = y + 5;
  ctx.globalAlpha = .30; fr(x + 2, ry + 11, w - 4, 2, '#000'); ctx.globalAlpha = 1;
  fr(x + 1, ry + 11, w - 2, 2, '#8e959d');
  hl(x + 1, ry + 11, w - 2, '#c6ccd2');
  /* Ic ice gecmis BOS kutular: duz dikdortgen degil, yamuk ve katmanli. */
  for (var i = 0; i < 3; i++) {
    var bx = Math.round(x + 4 + i * 7), by = ry + 2 - (i % 2);
    ctx.globalAlpha = .74;
    for (var kr = 0; kr < 9; kr++) {
      var ku = kr / 8, kg = Math.round(9 + (6 - 9) * ku);
      var kx = bx + Math.round((9 - kg) / 2);
      fr(kx, by + kr, kg, 1, '#8e1c14');
      fr(kx + 1, by + kr, kg - 2, 1, ku < .2 ? '#d8382a' : '#c02a20');
      px(kx + 1, by + kr, '#e86a58');
    }
    fr(bx + 1, by, 7, 1, '#5e120d');            /* agiz */
    fr(bx + 2, by + 3, 5, 2, '#f7d34a');        /* on bant */
    hl(bx + 2, by + 3, 5, '#ffe98e');
    ctx.globalAlpha = 1;
  }
  /* --- ON SIRA: DOLU kutular, tezgah yuzeyinde --- */
  var n = Math.min(2, ready | 0);
  for (var r = 0; r < n; r++) {
    var fx = Math.round(cx + (n === 1 ? 0 : (r === 0 ? -8 : 8)));
    drawFriesCup(fx, y + h - 14, 'ok', t + r);
  }
  if (!n) {
    /* bos: yerde nerede duracagini gosteren soluk iz */
    ctx.globalAlpha = .22;
    ell(cx, y + h - 5, 8, 2, '#000');
    ctx.globalAlpha = 1;
  }
  /* tezgah yuzeyi cizgisi: kutular buranin uzerinde durur */
  ctx.globalAlpha = .25; hl(x + 1, y + h - 4, w - 2, '#000'); ctx.globalAlpha = 1;
}

/* ---------- BIRLESIK ICECEK KASASI ----------
   Kola/fanta makinesi ile ayran kazani ayri iki kutuydu; artik tek
   celik kasa, icinde musluk bolmeleri. */
function drawIcecekKasasi(x, y, w, h, bolme, t) {
  ctx.globalAlpha = .30; fr(x + 1, y + h + 14, w, 3, '#000'); ctx.globalAlpha = 1;
  fr(x - 2, y - 4, w + 4, h + 6, '#59636d');
  fr(x - 1, y - 3, w + 2, h + 4, '#7a838c');
  hl(x - 1, y - 3, w + 2, '#b8c0c8');
  for (var i = 1; i < bolme; i++) {
    var bx = Math.round(x + (w / bolme) * i);
    ctx.globalAlpha = .55; vl(bx, y - 3, h + 4, '#4a525a'); ctx.globalAlpha = 1;
    vl(bx + 1, y - 3, h + 4, '#98a1aa');
  }
  var dy = y + h + 6;
  fr(x - 2, dy, w + 4, 5, '#4a525a');
  fr(x - 1, dy, w + 2, 4, '#6f767e');
  for (var g = 0; g < w; g += 3) px(x + g, dy + 1, '#59636d');
  hl(x - 1, dy, w + 2, '#98a1aa');
}

/* ---------- GARNITUR TEZGAHI: uc bolmeyi saran tek govde ----------
   Uc ayri vitrin yerine tek unite: dis cerceve bir kez cizilir,
   bolmeler arasina dikey ayirac konur. */
function drawTepsiKasasi(x, y, w, h, bolmeler) {
  ctx.globalAlpha = .30; fr(x + 1, y + h, w, 3, '#000'); ctx.globalAlpha = 1;
  fr(x - 3, y - 4, w + 6, h + 8, '#6f767e');
  fr(x - 2, y - 3, w + 4, h + 6, '#8e959d');
  fr(x - 2, y - 3, w + 4, 2, '#b8c0c8');
  fr(x - 1, y - 1, w + 2, h + 2, '#4a525a');
  for (var i = 1; i < bolmeler; i++) {
    var bx = Math.round(x + (w / bolmeler) * i);
    fr(bx - 1, y - 3, 2, h + 6, '#6f767e');
    vl(bx - 1, y - 3, h + 6, '#b8c0c8');
  }
  fr(x - 3, y + h + 3, w + 6, 2, '#59636d');
  hl(x - 3, y + h + 3, w + 6, '#8e959d');
}
/* Vitrin CAMI: butun bolmelerin onune tek gecis */
function drawTepsiCami(x, y, w, h, t) {
  ctx.globalAlpha = .13;
  fr(x - 1, y - 1, w + 2, h + 2, '#cfe4f2');
  ctx.globalAlpha = .20;
  for (var g = 0; g < w; g += 9) ln(x + g, y + h, x + g + 6, y - 1, '#ffffff');
  ctx.globalAlpha = 1;
  rc(x - 1, y - 1, w + 2, h + 2, 'rgba(180,210,230,.35)');
}

/* ---------- garnitür parçaları: her yerde aynı çizim ---------- */
/* sivri yeşil biber: sapı üstte omuzlu, aşağı doğru incelip sivrilir */
/* Sivri biber. Blender: blender/models/garnitur.py -> sahne_biber.
   SILUET eski degerlerinde birakildi - genisletince dart gibi sisiyor.
   Kazanc TONDA: eskiden iki ton vardi, artik dort ton + uzunlamasina
   oluk, yani govde yuvarlak okunuyor. */
function drawPepper(x, y, h, flip) {
  h = h || 13;
  flip = flip || 1;
  var wMax = Math.max(2, Math.round(h * .26));
  ctx.globalAlpha = .26; ell(x, y + 1, wMax + 1, 2, '#1c2f08'); ctx.globalAlpha = 1;
  for (var q = 0; q < h; q++) {
    var u = q / (h - 1);                       /* 0 = sap ucu, 1 = sivri uc */
    var w;
    if (u < .22) w = wMax * (.62 + (u / .22) * .38);       /* omuz */
    else w = wMax * Math.pow(1 - (u - .22) / .78, .62);    /* uzun konik */
    var iw = Math.round(Math.max(0, w));
    if (iw < 1 && u > .9) break;
    iw = Math.max(1, iw);
    var bend = Math.round(Math.sin(u * 1.45) * 2 * flip);
    var yy = y - h + q + 1;
    var cx2 = x + bend;
    fr(cx2 - iw, yy, iw * 2 + 1, 1, '#2c4a10');            /* koyu kenar */
    fr(cx2 - iw, yy, iw * 2, 1, '#48731a');                /* govde */
    if (iw > 1) fr(cx2 - iw, yy, iw, 1, '#6d9c28');        /* aydinlik yan */
    if (iw > 1 && u > .10 && u < .78) px(cx2 - iw + 1, yy, '#a4cc4a');
    if (iw > 2 && u > .18 && u < .62) px(cx2 - iw + 2, yy, '#d8ee8a');
    if (iw > 2 && q % 3 === 1) px(cx2 + iw - 2, yy, '#356312');  /* oluk */
  }
  /* sap */
  fr(x - 3, y - h + 1, 7, 2, '#3d5219');
  fr(x - 3, y - h + 1, 6, 1, '#5b7726');
  px(x - 4, y - h + 2, '#2c5210'); px(x + 4, y - h + 2, '#2c5210');
  fr(x - 1, y - h - 3, 3, 4, '#3d5219');
  fr(x - 1, y - h - 3, 2, 3, '#5b7726');
  px(x, y - h - 4, '#7fa138');
}

/* Dilimlenmis domates. Blender: garnitur.py -> sahne_domates.
   Kazanc TON RAMPASINDA: koyu kabuk halkasi -> kabuk -> et -> soluk
   perikarp. Bolmeler ilk denemede radyal bir DOLGU dongusuydu, ic
   kismi bastan asagi soluk pembeye boguyordu; artik uc kisa parmak,
   govde acikta kaliyor. */
function drawTomatoSlice(x, y, r) {
  r = Math.max(4, r || 6);
  x = Math.round(x); y = Math.round(y);
  var ry2 = Math.max(3, r - 1);
  ctx.globalAlpha = .28; ell(x, y + 2, r, 2, '#4a1008'); ctx.globalAlpha = 1;
  ell(x, y + 1, r, ry2, '#8e2018');            /* alt kenar */
  ell(x, y, r, ry2, '#b8302a');                /* kabuk halkasi */
  ell(x, y, r - 1, ry2 - 1, '#d8443a');
  ell(x, y, r - 2, Math.max(1, ry2 - 2), '#e2564a');   /* et */
  /* uc bolme: merkezden disa uzanan kisa soluk parmaklar */
  for (var i = 0; i < 3; i++) {
    var a = -Math.PI / 2 + i * (Math.PI * 2 / 3);
    var ex = x + Math.cos(a) * (r - 2.2);
    var ey = y + Math.sin(a) * (ry2 - 1.6);
    ln(x, y, Math.round(ex), Math.round(ey), '#ffc0a8');
    ln(x + (Math.abs(Math.cos(a)) > .5 ? 0 : 1), y + (Math.abs(Math.cos(a)) > .5 ? 1 : 0),
       Math.round(ex), Math.round(ey), '#f5a894');
  }
  px(x, y, '#ffd2b8');                          /* gobek */
  /* cekirdekler: bolme aralarinda */
  for (var s = 0; s < 3; s++) {
    var sa = -Math.PI / 2 + s * (Math.PI * 2 / 3) + Math.PI / 3;
    px(Math.round(x + Math.cos(sa) * (r - 2.4)),
       Math.round(y + Math.sin(sa) * (ry2 - 1.6)), '#f7e6b0');
  }
  px(x - 1, y - ry2 + 1, '#f2887a');            /* ust parlaklik */
}

/* ---------- domates & biber tepsisi ---------- */
function drawGarnishTray(x, y, w, h, tn, pn, max, t, fx) {
  fx = fx || 0;
  trayBase(x, y, w, h);
  var bump = Math.round(Math.sin(fx * Math.PI) * 2);
  var midX = x + Math.round(w * .52);
  /* bölme çubuğu */
  fr(midX - 1, y + 4, 2, h - 10, '#8a929b');
  vl(midX - 1, y + 4, h - 10, '#c7ced5');

  /* ---- sol: dilimlenmiş domates ---- */
  var tl = clamp(tn / Math.max(1, max), 0, 1);
  if (tn > 0) {
    var rows = Math.max(1, Math.round(1 + tl * 2.2));
    for (var rI = rows - 1; rI >= 0; rI--) {
      var ry2 = y + h - 10 - rI * 4 - bump;
      for (var c = 0; c < 3; c++) {
        var cx2 = x + 8 + c * 6 + (rI % 2) * 2;
        if (cx2 > midX - 7) continue;
        drawTomatoSlice(cx2, ry2, 6);
      }
    }
    if (chance(.04)) part({ x: x + 6 + rnd(0, 12), y: y + h - 11, vx: 0, vy: 10, life: .3, col: '#e2483a', g: 60, sz: 1, floor: y + h - 8 });
  } else {
  }

  /* ---- sağ: bütün yeşil biber ---- */
  var pl2 = clamp(pn / Math.max(1, max), 0, 1);
  if (pn > 0) {
    var pc = Math.max(1, Math.round(1 + pl2 * 3.2));
    for (var pI = pc - 1; pI >= 0; pI--) {
      var col = pI % 2, row = (pI / 2) | 0;
      var bx2 = midX + 5 + col * 7;
      var by2 = y + h - 8 - row * 3 - bump;
      if (bx2 > x + w - 4) continue;
      drawPepper(bx2, by2, 12 + (pI % 3), col ? 1 : -1);
    }
  } else {
  }

  trayInnerShade(x, y, w, h);
  trayFlash(x, y, w, h, fx);
}

/* ---------- malzeme kutusu (stok) ---------- */
function drawCrate(x, y, w, h, open, t, acik) {
  /* Duvara gomulu cekmece: acilinca SOLA dogru cikar (tezgaha dogru),
     kapaninca duvarin icine girer. 'acik' 0..1 kayma miktari. */
  var k = clamp(acik === undefined ? (open ? 1 : 0) : acik, 0, 1);
  var kay = Math.round(k * 22);            /* sola cikma mesafesi */

  /* --- duvardaki oyuk (cekmece cikinca gorunur) --- */
  fr(x - 1, y - 1, w + 2, h + 2, '#171310');
  for (var i = 0; i < h; i++) {
    ctx.globalAlpha = .14 + (1 - i / h) * .28;
    hl(x, y + i, w, '#000');
    ctx.globalAlpha = 1;
  }
  rc(x - 1, y - 1, w + 2, h + 2, '#5b544c');

  /* --- cekmece govdesi: sola kaymis --- */
  var dx = x - kay, dy = y + 2, dw = w, dh = h - 4;
  /* cekmecenin sag yan duvari: duvardan disari ciktikca uzar */
  if (kay > 0) {
    fr(dx + dw, dy + 2, kay, dh - 4, '#4e3a18');
    ctx.globalAlpha = .35; fr(dx + dw, dy + 2, kay, 3, '#000'); ctx.globalAlpha = 1;
    hl(dx + dw, dy + 2, kay, '#6d5228');
  }
  /* govde */
  ctx.globalAlpha = .30; fr(dx + 1, dy + dh, dw, 2, '#000'); ctx.globalAlpha = 1;
  fr(dx, dy, dw, dh, '#5b4420');
  fr(dx + 1, dy + 1, dw - 2, dh - 2, '#7a5a2c');
  for (var v = 0; v < dh - 2; v += 4) {
    ctx.globalAlpha = .20; hl(dx + 1, dy + 1 + v, dw - 2, '#5b4420'); ctx.globalAlpha = 1;
  }
  hl(dx + 1, dy + 1, dw - 2, '#a5813f');

  /* --- ic: acilinca malzemeler gorunur --- */
  if (k > .25) {
    ctx.globalAlpha = Math.min(1, (k - .25) / .5);
    fr(dx + 3, dy + 3, dw - 6, dh - 7, '#3a2a16');
    ell(dx + 9, dy + dh - 8, 6, 4, P.g3);
    ell(dx + 9, dy + dh - 9, 6, 4, P.g2);
    ell(dx + dw - 10, dy + dh - 7, 6, 4, '#c9cfd6');
    ell(dx + dw - 10, dy + dh - 8, 6, 4, '#eef2f5');
    ctx.globalAlpha = 1;
  }

  /* --- SOL on yuz: kulp burada, cunku cekmece sola cikiyor --- */
  fr(dx, dy, 5, dh, '#4e3a18');
  fr(dx, dy, 4, dh - 1, '#6d5228');
  vl(dx, dy, dh - 1, '#a5813f');
  /* dikey metal kulp */
  fr(dx + 1, dy + dh / 2 - 6, 2, 12, '#8a8278');
  vl(dx + 1, dy + dh / 2 - 6, 12, '#c0b8ac');
  px(dx + 1, dy + dh / 2 - 7, '#6e675e'); px(dx + 1, dy + dh / 2 + 6, '#6e675e');

  /* yazi cekmecenin ON YUZUNU haric tutarak ortalanir */
  txt('STOK', dx + 5 + (dw - 5) / 2, dy + 3, 'rgba(255,240,210,.55)', { align: 'c' });
  /* kapaliyken cagirici parilti */
  if (k < .1) {
    ctx.globalAlpha = .16 + .12 * Math.sin(t * 3);
    rc(x, y, w, h, P.au0);
    ctx.globalAlpha = 1;
  }
}

/* ---------- çöp kovası ---------- */
/* ---------- sos standı: acı / sarımsak / tereyağı ---------- */
/* Siselerin uzerinde yazi yok: rengi zaten ayirt ediyor. Eskiden burada
   kullanilmayan bir 'lbl' alani vardi; 'SAR' anahtari sarma ipucuyla
   cakistigi icin Ingilizcede tahtaya 'GRLC' yaziyordu. */
var SAUCE_DEF = [
  { id: 'hot',    c0: '#8e1c14', c1: '#e2382a', c2: '#ff7a62', cap: '#3a2a24' },
  { id: 'garlic', c0: '#bdb6a2', c1: '#f6f2e6', c2: '#ffffff', cap: '#6f7a84' },
  { id: 'butter', c0: '#a8700f', c1: '#f0b53c', c2: '#ffd77a', cap: '#7a4f16' }
];
function sauceSlotX(i) { return ST.sauce.x + 5 + i * 15; }

/* Her sosun kendi silueti. Blender: blender/models/sos.py -> sahne_sos.
   Uc sise birebir ayniyken raf tekduze bir sira gibi duruyordu; gercek
   bir sos rafinda siseler birbirinden once BICIMIYLE ayrilir. */
var SISE_BOY = [
  { w: 11, gov: 17, omuz: 5, boyun: 3 },     /* aci: uzun-ince */
  { w: 14, gov: 12, omuz: 4, boyun: 3 },     /* sarimsak: bodur */
  { w: 12, gov: 15, omuz: 5, boyun: 3 }      /* tereyagi: klasik */
];

/* Sikma sisesi: govde -> omuz -> boyun -> kapak.
   Govde SOSUN RENGINDE: tezgahta duran bir sise boyle okunur, cam
   yalnizca kenardaki parlamadir. Seviye cizgisi doluluğu gosterir. */
function drawSauceBottle(cx, taban, S, d, dolu) {
  var hw = S.w >> 1, gy = taban - S.gov;
  var koy = shadeCol(d.c1, .56), ac = shadeCol(d.c1, 1.20);
  var dz = Math.max(2, Math.round((S.gov - 2) * clamp(dolu, 0, 1)));
  /* govde: ust bos, alt dolu */
  fr(cx - hw, gy, S.w, S.gov, d.c0);
  fr(cx - hw + 1, gy + 1, S.w - 2, S.gov - 2, koy);
  fr(cx - hw + 1, taban - dz, S.w - 2, dz - 1, d.c1);
  hl(cx - hw + 1, taban - dz, S.w - 2, d.c2);          /* seviye cizgisi */
  vl(cx - hw + 1, gy + 2, S.gov - 4, ac);              /* sol parlama */
  vl(cx + hw - 2, gy + 2, S.gov - 4, shadeCol(d.c0, .84));
  /* omuz: yukari daralarak boyna baglanir */
  for (var i = 0; i < S.omuz; i++) {
    var ow = Math.max(3, Math.round(hw - (hw - 3) * (i + 1) / S.omuz));
    fr(cx - ow, gy - i - 1, ow * 2, 1, d.c0);
    fr(cx - ow + 1, gy - i - 1, ow * 2 - 2, 1, koy);
    px(cx - ow + 1, gy - i - 1, ac);
  }
  /* boyun */
  var ny = gy - S.omuz;
  fr(cx - 3, ny - S.boyun, 6, S.boyun, d.c0);
  fr(cx - 2, ny - S.boyun, 4, S.boyun, koy);
  /* kapak: bilezik + govde + agiz */
  var ky = ny - S.boyun;
  fr(cx - 4, ky - 2, 8, 2, shadeCol(d.cap, .72));
  fr(cx - 3, ky - 6, 6, 4, d.cap);
  hl(cx - 3, ky - 6, 6, shadeCol(d.cap, 1.55));
  fr(cx - 1, ky - 8, 2, 2, shadeCol(d.cap, 1.25));
}

function drawSauceStation(x, y, w, h, on, isk, fx, t) {
  /* ahsap raf */
  ctx.globalAlpha = .28; fr(x + 2, y + 40, w - 4, 3, '#000'); ctx.globalAlpha = 1;
  fr(x, y + 34, w, 7, '#5e3f1e');
  fr(x, y + 34, w, 6, '#8a5f2e');
  hl(x + 1, y + 34, w - 2, '#b98246');
  for (var v = 4; v < w - 3; v += 8) vl(x + v, y + 35, 5, '#7a5228');
  /* arka pano */
  ctx.globalAlpha = .32; fr(x + 1, y + 6, w - 2, 28, '#2a2018'); ctx.globalAlpha = 1;
  for (var i = 0; i < 3; i++) {
    var d = SAUCE_DEF[i], open = i === 2 ? isk : on;
    var S = SISE_BOY[i], cx0 = sauceSlotX(i) + 5;
    var sq = fx && fx[d.id] > 0 ? fx[d.id] : 0;
    var lift = Math.round(Math.sin(clamp(sq, 0, 1) * Math.PI) * 5);
    var taban = y + 34 - lift;
    if (lift > 0) { ctx.globalAlpha = .2; ell(cx0, y + 35, 6, 2, '#000'); ctx.globalAlpha = 1; }
    if (!open) ctx.globalAlpha = .26;
    drawSauceBottle(cx0, taban, S, d, .55 + i * .15);
    if (sq > 0) {                                   /* sikilirken govde ezilir */
      var ez = taban - Math.round(S.gov * .55);
      fr(cx0 - (S.w >> 1) - 2, ez, S.w + 4, 6, d.c1);
      px(cx0 - (S.w >> 1) - 2, ez, d.c0); px(cx0 + (S.w >> 1) + 1, ez, d.c0);
    }
    /* etiket: yazı yerine küçük resim */
    var eh = S.gov > 14 ? 9 : 7, ey0 = taban - S.gov + 3;
    var hw3 = S.w >> 1;
    fr(cx0 - hw3, ey0, S.w, eh, '#cfc7b2');
    fr(cx0 - hw3, ey0, S.w - 1, eh - 1, '#f4efe0');
    hl(cx0 - hw3, ey0, S.w - 1, '#ffffff');
    var lcx = cx0, lcy = ey0 + (eh >> 1);
    if (i === 0) {
      /* acı biber */
      ell(lcx, lcy + 1, 3, 2, '#8e1c14');
      ell(lcx, lcy, 3, 2, '#e2382a');
      px(lcx - 2, lcy - 1, '#ff7a62');
      px(lcx + 2, lcy - 2, '#4a7a20'); px(lcx + 3, lcy - 3, '#5a8a2a');
    } else if (i === 1) {
      /* sarımsak */
      ell(lcx, lcy + 1, 3, 3, '#cfc7b2');
      ell(lcx, lcy, 3, 3, '#ffffff');
      px(lcx - 1, lcy, '#cfc7b2'); px(lcx + 1, lcy, '#cfc7b2');
      px(lcx, lcy - 3, '#a89a78');
    } else {
      /* tereyağı */
      fr(lcx - 3, lcy - 2, 7, 5, '#c98a1a');
      fr(lcx - 3, lcy - 2, 6, 4, '#f0b53c');
      hl(lcx - 3, lcy - 2, 6, '#ffd77a');
    }
    if (!open) {                                    /* kilit */
      fr(cx0 - 3, taban - 8, 6, 5, '#8a929b');
      rc(cx0 - 2, taban - 12, 4, 5, '#8a929b');
    }
    ctx.globalAlpha = 1;
  }
  txt('SOS', x + w / 2, y + 41, 'rgba(255,255,255,.5)', { align: 'c', outline: 'rgba(0,0,0,.5)' });
}

/* Cop kovasi. Blender: blender/models/patates.py -> sahne_cop.
   Icerisi bos bir koyu agizdi; artik dolulukla YUKSELEN kagit ve et
   artiklari var, kademe farki okunuyor. */
function copIcerik(x, y, w, h, dolu) {
  /* --- COP ICERIGI: dolulukla yukselir --- */
  var d = clamp(dolu || 0, 0, 1);
  if (d < .04) return;
  var n = Math.round(3 + d * 8);
  var taban = y + h - 5, tepe = taban - Math.round(d * (h - 12));
  for (var i = 0; i < n; i++) {
    var a = i * 2.37;
    var cx0 = Math.round(x + w / 2 + Math.cos(a) * (w / 2 - 6));
    var cz0 = Math.round(taban - (i / Math.max(1, n - 1)) * (taban - tepe));
    var bw = 3 + (i % 3) * 2, bh = 2 + (i % 2);
    var kn = i % 3 ? '#8a8474' : (i % 5 === 0 ? '#52290a' : '#3a3228');
    var gv = i % 3 ? '#e8e4d6' : (i % 5 === 0 ? '#9c5718' : '#7a6a52');
    fr(cx0 - bw, cz0, bw * 2, bh + 1, kn);
    fr(cx0 - bw, cz0, bw * 2 - 1, bh, gv);
    px(cx0 - bw, cz0, i % 3 ? '#f8f4e8' : '#9a8a6c');
  }
}

function drawTrash(x, y, w, h, t, bosalt, dolu) {
  /* Duvara gomulu SIYAH kare: cop bacasi. Tezgahtaki kova yer
     kapliyordu, artik sag tas duvarin icinde. */
  var d = clamp(dolu || 0, 0, 1.35);
  /* gomme cukuru: kenarda tas govdesi, ortada karanlik */
  fr(x - 2, y - 2, w + 4, h + 4, 'rgba(0,0,0,.30)');
  fr(x, y, w, h, '#2a2622');
  fr(x + 1, y + 1, w - 2, h - 2, '#14110f');
  /* ic derinlik: ustten asagi acilan karanlik */
  for (var i = 0; i < h - 2; i++) {
    ctx.globalAlpha = .10 + (i / h) * .35;
    hl(x + 1, y + 1 + i, w - 2, '#000');
    ctx.globalAlpha = 1;
  }
  /* metal cerceve */
  rc(x, y, w, h, '#6e675e');
  hl(x + 1, y + 1, w - 2, '#8a8278');
  vl(x + 1, y + 1, h - 2, '#7a7369');
  /* kapak dili: cope atinca sallanir */
  var sal = bosalt > 0 ? Math.sin(bosalt * 26) * 2 : 0;
  var ky = y + 4 + Math.round(sal);
  fr(x + 3, ky, w - 6, 3, '#4a443c');
  hl(x + 3, ky, w - 6, '#6e675e');
  /* doluluk: icerideki yiginin ustu gorunur */
  if (d > .02) {
    var yh = Math.round((h - 10) * Math.min(1, d));
    var ty = y + h - 3 - yh;
    for (var q = 0; q < yh; q++) {
      var ww = w - 6 - Math.round(Math.abs(Math.sin(q * .7)) * 2);
      fr(x + 3, ty + q, ww, 1, q < 2 ? '#6b6258' : '#443e37');
    }
    /* Tanimlanabilir parcalar: eskiden tepede dort tek piksel vardi,
       yigin duz gri bir blok gibi okunuyordu. */
    copIcerik(x, y, w, h, Math.min(1, d));
    if (d > 1) {
      ctx.globalAlpha = .45 + .3 * Math.sin(t * 6);
      rc(x - 1, y - 1, w + 2, h + 2, P.bad);
      ctx.globalAlpha = 1;
    }
  }
  /* etiket — kovanin altinda, ama alt bant kirpiliysa gorunur alana cekilir */
  txt('ÇÖP', x + w / 2, Math.min(y + h + 2, H - VIEW.bot - 9),
      'rgba(255,255,255,.42)', { align: 'c', outline: 'rgba(0,0,0,.5)' });
  /* bosaltma tozu */
  if (bosalt > 0 && chance(.5)) {
    part({ x: x + rnd(2, w - 2), y: y + h - 4, vx: rnd(-8, 8), vy: rnd(-18, -6),
      life: .5, col: 'rgba(120,110,100,.5)', g: 60, sz: 1 });
  }
}
function heatShimmer(x, y, w, h, t) {
  ctx.globalAlpha = .07;
  for (var i = 0; i < h; i += 2) {
    var off = Math.sin(t * 3 + i * .5) * 1.5;
    hl(x + off, y + i, w, '#ffd0a0');
  }
  ctx.globalAlpha = 1;
}
function glowRect(x, y, w, h, col, a) {
  ctx.globalAlpha = a;
  rrectOut(x - 1, y - 1, w + 2, h + 2, 2, col);
  ctx.globalAlpha = a * .5;
  rrectOut(x - 2, y - 2, w + 4, h + 4, 3, col);
  ctx.globalAlpha = 1;
}
function bar(x, y, w, h, p, col, bgc) {
  fr(x, y, w, h, bgc || 'rgba(0,0,0,.6)');
  fr(x + 1, y + 1, Math.max(0, Math.round((w - 2) * p)), h - 2, col);
  if (h > 3) hl(x + 1, y + 1, Math.max(0, Math.round((w - 2) * p)), 'rgba(255,255,255,.4)');
}

/* ============================================================
   RAKIP DONERCININ ZEMIN KATI
   ============================================================
   drawBuilding icinden cagrilir; ustundeki govde/kornis/pencereler
   komsu cephelerle AYNI koddan gelir. Burada yalniz vitrin katI var.
   durum: 'insaat' | 'acik' | 'kapali'
   ============================================================ */
function rakipZemin(bx, by, bw, gyy, B, durum) {
  var t = (typeof G !== 'undefined' && G) ? (G.t || 0) : 0;

  /* ---------------- INSAAT: henuz acilmadi ---------------- */
  if (durum === 'insaat') {
    /* kapali kepenk */
    fr(bx + 2, gyy - 6, bw - 5, 21, shadeCol(B.wall, .70));
    fr(bx + 4, gyy, bw - 9, 15, '#5a5e64');
    for (var kk = gyy + 1; kk < gyy + 15; kk += 2) {
      ctx.globalAlpha = .34; hl(bx + 4, kk, bw - 10, '#33373d'); ctx.globalAlpha = 1;
    }
    /* levha: bos tabela + capraz bant */
    fr(bx + 3, gyy - 6, bw - 7, 5, '#6b6f75');
    fr(bx + 3, gyy - 6, bw - 8, 4, '#8a8f96');
    ctx.globalAlpha = .8;
    ln(bx + 5, gyy - 5, bx + bw - 9, gyy - 2, '#d8c04a');
    ln(bx + 5, gyy - 2, bx + bw - 9, gyy - 5, '#d8c04a');
    ctx.globalAlpha = 1;
    /* iskele: iki dikme + iki yatay kalas */
    var ix = bx + 3, iw = bw - 7;
    fr(ix, gyy - 8, 2, 23, '#8a6a3a'); fr(ix + iw - 2, gyy - 8, 2, 23, '#8a6a3a');
    fr(ix, gyy - 3, iw, 2, '#a8834a'); fr(ix, gyy + 7, iw, 2, '#a8834a');
    hl(ix, gyy - 3, iw, '#c39a58'); hl(ix, gyy + 7, iw, '#c39a58');
    /* uyari bandi: sari-siyah */
    for (var ub = 0; ub < iw - 2; ub += 4) {
      fr(ix + 1 + ub, gyy + 13, 2, 2, '#e8c23a');
      fr(ix + 3 + ub, gyy + 13, 2, 2, '#2a2620');
    }
    fr(bx + 2, by, bw - 4, 1, '#cdd4da');
    return;
  }

  /* ---------------- KAPALI: pes etti ---------------- */
  if (durum === 'kapali') {
    fr(bx + 2, gyy - 6, bw - 5, 21, shadeCol(B.wall, .62));
    /* sonmus tabela */
    fr(bx + 3, gyy - 6, bw - 7, 5, '#3a3a40');
    fr(bx + 3, gyy - 6, bw - 8, 4, '#4a4a52');
    /* inik kepenk */
    fr(bx + 4, gyy, bw - 9, 15, '#4e5258');
    for (var k2 = gyy + 1; k2 < gyy + 15; k2 += 2) {
      ctx.globalAlpha = .38; hl(bx + 4, k2, bw - 10, '#2e3238'); ctx.globalAlpha = 1;
    }
    /* asma kilit */
    fr(bx + (bw >> 1) - 1, gyy + 13, 3, 3, '#7a7e84');
    /* capraz muhur */
    ctx.globalAlpha = .85;
    ln(bx + 5, gyy + 1, bx + bw - 9, gyy + 13, '#a83a2a');
    ln(bx + 5, gyy + 13, bx + bw - 9, gyy + 1, '#a83a2a');
    ctx.globalAlpha = 1;
    fr(bx + 2, by, bw - 4, 1, '#cdd4da');
    return;
  }

  /* ---------------- ACIK: calisan rakip dukkani ---------------- */
  /* tabela: komsularla ayni bicim, rakip rengi */
  fr(bx + 2, gyy - 6, bw - 5, 6, '#1c4256');
  fr(bx + 2, gyy - 6, bw - 6, 5, '#2f6a8a');
  hl(bx + 2, gyy - 6, bw - 6, '#4a8fb4');
  /* isikli harf seridi: komsu tabelalardaki dilin aynisi */
  for (var sg = bx + 5; sg < bx + bw - 6; sg += 6) {
    ctx.globalAlpha = .70 + Math.sin(t * 3.1 + sg) * .22;
    fr(sg, gyy - 4, 4, 2, '#ffd77a');
    ctx.globalAlpha = 1;
  }
  /* tente: fistolu, komsularla ayni yapim, ters renk */
  var ay = gyy;
  for (var sx = 0; sx < bw - 4; sx++) {
    var band = ((sx / 6) | 0) & 1;
    var col = band ? '#2f6a8a' : '#f2ece0';
    fr(bx + 2 + sx, ay, 1, 5, col);
    if ((sx % 6) < 3) px(bx + 2 + sx, ay + 5, col);
  }
  hl(bx + 2, ay, bw - 4, 'rgba(255,255,255,.4)');
  ctx.globalAlpha = .32; fr(bx + 2, ay + 6, bw - 4, 2, '#000'); ctx.globalAlpha = 1;

  /* vitrin: icerisi sicak, rakip calisiyor */
  var vy = ay + 7, vh = by - vy - 1;
  fr(bx + 3, vy, bw - 7, vh, '#2f3d47');
  fr(bx + 4, vy + 1, bw - 9, vh - 2, '#3a2e26');
  ctx.globalAlpha = .20 + Math.sin(t * 1.9) * .04;
  fr(bx + 4, vy + 1, bw - 9, vh - 2, '#ffc46a');
  ctx.globalAlpha = 1;
  /* onun doneri: bizimkinin kucugu */
  var sx2 = bx + 7;
  fr(sx2, vy + 2, 4, vh - 5, '#8a5f31');
  fr(sx2, vy + 2, 3, vh - 5, '#c98436');
  fr(sx2 - 1, vy + 1, 6, 1, '#6b4a24');
  px(sx2 + 1, vy + vh - 4, '#ffd257');
  /* tezgah + calisan silueti */
  fr(bx + 13, by - 6, bw - 20, 2, '#6b5a48');
  var kx = bx + 18 + Math.round(Math.sin(t * .8) * 2);
  if (kx + 4 < bx + bw - 12) {
    fr(kx, by - 12, 4, 7, '#2f4450');
    fr(kx + 1, by - 15, 3, 3, '#b98b6a');
  }
  /* cam yansimasi: komsu vitrinlerdekiyle ayni */
  ctx.globalAlpha = .28;
  for (var q = 0; q < vh - 2; q++) fr(bx + 6 + q, vy + 1 + q, 3, 1, '#ffffff');
  ctx.globalAlpha = 1;
  /* kapi */
  var dx0 = bx + bw - 12;
  fr(dx0, vy, 9, vh + 1, '#1c4256');
  fr(dx0 + 1, vy + 1, 7, vh, '#3f5f70');
  fr(dx0 + 2, vy + 2, 5, 5, '#a8c6d4');
  px(dx0 + 6, vy + Math.round(vh * .6), '#f0d78a');
  fr(bx + 2, by, bw - 4, 1, '#cdd4da');
}

/* Rakip cephesi bugun hangi durumda? bakeStreet ve onbellek bunu
   okuyor; degisince sokak yeniden pisiyor. */
function rakipCepheDurum() {
  if (typeof G === 'undefined' || !G) return 'insaat';
  if (G.rakipKapandi) return 'kapali';
  return (G.day >= RAKIP_GUN) ? 'acik' : 'insaat';
}
