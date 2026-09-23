/* ============================================================
   DÖNER EFSANESİ — ui.js
   HUD, sipariş balonları, başlık, gün sonu, dükkân, duraklat
   ============================================================ */
'use strict';

/* ---------------- ortak parçalar ---------------- */
function panel(x, y, w, h, title) {
  ctx.globalAlpha = .35; rrect(x + 2, y + 3, w, h, 4, '#000'); ctx.globalAlpha = 1;
  rrect(x, y, w, h, 4, P.ui4);
  rrect(x + 1, y + 1, w - 2, h - 2, 3, P.ui1);
  rrect(x + 2, y + 2, w - 4, h - 4, 3, P.ui0);
  hl(x + 3, y + 2, w - 6, '#ffffff');
  rrectOut(x, y, w, h, 4, P.ui5);
  if (title) {
    var tw = textW(title) + 12;
    rrect(x + w / 2 - tw / 2, y - 6, tw, 13, 3, P.red2);
    rrect(x + w / 2 - tw / 2 + 1, y - 5, tw - 2, 11, 3, P.red1);
    txt(title, x + w / 2, y - 3, P.ui0, { align: 'c', shadow: 1 });
  }
}
function button(x, y, w, h, label, col, hot) {
  var over = inRect(IN.x, IN.y, x, y, w, h);
  var c0 = col || P.red1, c1 = shadeCol(c0, over ? 1.22 : 1.0), c2 = shadeCol(c0, .62);
  var off = over && IN.down ? 1 : 0;
  ctx.globalAlpha = .3; rrect(x + 1, y + 3, w, h, 3, '#000'); ctx.globalAlpha = 1;
  rrect(x, y + off, w, h, 3, c2);
  rrect(x, y + off, w, h - 2, 3, c1);
  hl(x + 3, y + 1 + off, w - 6, shadeCol(c0, 1.5));
  rrectOut(x, y + off, w, h, 3, P.ui5);
  txt(label, x + w / 2, y + off + (h - 8) / 2, P.ui0, { align: 'c', shadow: 1 });
  if (hot && !over) { ctx.globalAlpha = .3 + .25 * Math.sin(G.t * 6); rrectOut(x - 1, y - 1, w + 2, h + 2, 4, P.au0); ctx.globalAlpha = 1; }
  return over && IN.pressed;
}

/* Modal panel gorunur banda sigsin: dar telefonda dikey kirpma yuzunden
   270px'lik alan yok. Istenen y/h verilir, sigan kutu doner. */
function panelKutu(istenenY, istenenH) {
  var ust = VIEW.top + 4, alt = H - VIEW.bot - 4;
  var h = Math.min(istenenH, alt - ust);
  var y = Math.max(ust, Math.min(istenenY, alt - h));
  return [y, h];
}

/* ---------------- HUD ---------------- */
/* HUD sag grubunun yaslandigi kenar. Kirpmayi ve dokunmatikte kose payini
   birlikte hesaplar; cizim ile tiklama kutusu AYNI degeri kullanmali. */
function hudSagKenar() { return W - VIEW.right - (TOUCH ? 8 : 0); }
function hudCoinPos() {
  var ms = '$' + fmtMoney(G.money);
  var mw = textW(ms, 1, true) + 26;
  return [hudSagKenar() - 28 - mw + 9, 12 + VIEW.top];
}
function drawHUD(t) {
  /* HUD ekranin ust kenarina yapisir. Dar telefonda ust bant kirpildigi
     icin (VIEW.top) o kadar asagi kaydirilir, yoksa kesilirdi. */
  ctx.save();
  if (VIEW.top) ctx.translate(0, VIEW.top);
  /* Dar telefonda HUD alcalir: takvim rozeti 26 -> 16px. HUD ne kadar
     kisaysa ust bant o kadar cok kirpilabilir, oyun o kadar buyur. */
  var kompakt = VIEW.top > 0;
  /* takvim */
  var cx = 6, cy = 3;
  if (kompakt) {
    ctx.globalAlpha = .3; rrect(cx + 1, cy + 3, 30, 16, 3, '#000'); ctx.globalAlpha = 1;
    rrect(cx, cy + 1, 30, 16, 3, '#f2ece0');
    rrect(cx, cy + 1, 30, 6, 3, '#c0281c');
    txt('' + G.day, cx + 15, cy + 8, P.ink, { align: 'c' });
    rrectOut(cx, cy + 1, 30, 16, 3, '#8a7a60');
  } else {
    ctx.globalAlpha = .3; rrect(cx + 1, cy + 2, 30, 26, 3, '#000'); ctx.globalAlpha = 1;
    rrect(cx, cy, 30, 26, 3, '#f2ece0');
    rrect(cx, cy, 30, 8, 3, '#c0281c');
    rrect(cx + 1, cy + 1, 28, 6, 2, '#e2483a');
    txt('GÜN', cx + 15, cy + 1, P.white, { align: 'c' });
    txt('' + G.day, cx + 15, cy + 12, P.ink, { align: 'c' });
    vl(cx + 6, cy - 3, 4, '#8a8a90'); vl(cx + 23, cy - 3, 4, '#8a8a90');
    rrectOut(cx, cy, 30, 26, 3, '#8a7a60');
  }

  /* saat */
  var tx = 40, th = kompakt ? 16 : 20, ty0 = kompakt ? cy + 1 : cy;
  ctx.globalAlpha = .3; rrect(tx + 1, ty0 + 2, 42, th, 3, '#000'); ctx.globalAlpha = 1;
  rrect(tx, ty0, 42, th, 3, '#7a5230');
  rrect(tx + 1, ty0 + 1, 40, th - 2, 3, '#9c6b3f');
  rrect(tx + 3, ty0 + 3, 36, th - 6, 2, '#241a14');
  var tl = G.scene === 'play' ? G.timeLeft : 0;
  var low = tl < 20 && tl > 0;
  var tcol = low ? (Math.sin(t * 10) > 0 ? '#ff5a3a' : '#a03020') : '#ff9a4a';
  txt(fmtTime(tl), tx + 21, ty0 + (kompakt ? 5 : 6), tcol, { align: 'c', mono: true });
  if (!kompakt) { vl(tx + 8, cy - 3, 4, '#8a8a90'); vl(tx + 33, cy - 3, 4, '#8a8a90'); }

  /* sağ: satış + para + duraklat.
     Sag bant kirpildiginda hepsi o kadar sola kayar; yoksa duraklat
     dugmesi ekranin disinda kalirdi. */
  var Wr = hudSagKenar();
  rrect(Wr - 22, 4, 18, 16, 3, 'rgba(30,20,16,.75)');
  fr(Wr - 17, 8, 3, 8, P.ui0); fr(Wr - 12, 8, 3, 8, P.ui0);

  /* Demirkent'te AYRI kasa gosterilir ve eksiye dusebilir. */
  var fk = (typeof fkasaAcik === 'function') && fkasaAcik();
  var mval = fk ? (G.fpara || 0) : G.money;
  var ms = (mval < 0 ? '-' : '') + fmtShort(Math.abs(mval));
  var mw = textW(ms, 1, true) + 26;
  var mx = Wr - 28 - mw;
  var mpop = G.hudPop > 0 ? G.hudPop : 0;
  if (mpop > 0) {
    ctx.globalAlpha = mpop * .5;
    rrect(mx - 2, 2, mw + 4, 20, 5, P.au0);
    ctx.globalAlpha = 1;
  }
  rrect(mx, 4, mw, 16, 4, 'rgba(30,20,16,.78)');
  rrectOut(mx, 4, mw, 16, 4, mpop > 0 ? P.au0 : 'rgba(255,220,140,.35)');
  icon('coin', mx + 9, 12 - Math.round(mpop * 2), t);
  txt(ms, mx + mw - 5, 8 - Math.round(mpop * 2), mval < 0 ? '#ff6a56' : P.au0,
      { align: 'r', mono: true });

  /* hava durumu */
  if (G.weather === 'rain') {
    var wx = 8, wy = kompakt ? 22 : 32;
    ctx.globalAlpha = .85; rrect(wx - 2, wy - 2, 28, 14, 3, 'rgba(30,40,60,.8)'); ctx.globalAlpha = 1;
    ell(wx + 6, wy + 4, 5, 3, '#c6d4e2'); ell(wx + 10, wy + 3, 4, 3, '#e2ecf6');
    for (var ri = 0; ri < 3; ri++) {
      var ry2 = wy + 6 + ((t * 22 + ri * 4) % 6);
      px(wx + 3 + ri * 4, ry2, '#6b9ad8'); px(wx + 3 + ri * 4, ry2 + 1, '#8fb8e0');
    }
    txt('YAĞMUR', wx + 28, wy + 1, '#8fb8e0');
  } else if (G.weather === 'kar') {
    var kx = 8, ky = kompakt ? 22 : 32;
    ctx.globalAlpha = .85; rrect(kx - 2, ky - 2, 28, 14, 3, 'rgba(40,58,80,.8)'); ctx.globalAlpha = 1;
    ell(kx + 6, ky + 4, 5, 3, '#dbe7f2'); ell(kx + 10, ky + 3, 4, 3, '#f4f9ff');
    for (var ki = 0; ki < 3; ki++) {
      var ky2 = ky + 6 + ((t * 12 + ki * 4) % 6);
      px(kx + 3 + ki * 4, ky2, '#ffffff'); px(kx + 4 + ki * 4, ky2 + 1, '#cfe2f4');
    }
    txt('KAR', kx + 28, ky + 1, '#dbe7f2');
  } else if (G.weather === 'sicak') {
    var sx4 = 8, sy4 = kompakt ? 22 : 32;
    ctx.globalAlpha = .85; rrect(sx4 - 2, sy4 - 2, 28, 14, 3, 'rgba(70,40,10,.8)'); ctx.globalAlpha = 1;
    disc(sx4 + 7, sy4 + 5, 4, '#ffd257');
    for (var si4 = 0; si4 < 8; si4++) {
      var a4 = si4 * .785 + Math.sin(t * 1.6) * .12;
      px(sx4 + 7 + Math.round(Math.cos(a4) * 6), sy4 + 5 + Math.round(Math.sin(a4) * 6), '#ffb23c');
    }
    txt('SICAK', sx4 + 28, sy4 + 1, '#ffc86a');
  }
  /* MAC DALGASI: suruyorken ekranda goze carpan bir seri uyarisi */
  if (typeof macDalgada === 'function' && macDalgada()) {
    var mgw = textW(T('MAÇ ÇIKIŞI')) + 12;
    var mgx = W / 2 - mgw / 2, mgy = kompakt ? 22 : 32;
    ctx.globalAlpha = .55 + .3 * Math.sin(t * 6);
    rrect(mgx, mgy, mgw, 12, 3, 'rgba(20,60,20,.85)');
    rrectOut(mgx, mgy, mgw, 12, 3, '#8ad86a');
    ctx.globalAlpha = 1;
    txt(T('MAÇ ÇIKIŞI'), W / 2, mgy + 3, '#b8f09a', { align: 'c' });
  }

  /* BORÇ */
  if (G.debt > 0) {
    var ds = '$' + fmtShort(G.debt);
    /* Kutu genisligi ETIKETIN kendisinden olculur. Sabit 34 piksel
       Turkce "BORÇ"a gore ayarlanmisti; Almanca "SCHULD" daha genis
       ve rakamin uzerine biniyordu. textW zaten T()'den geciriyor. */
    var dw = textW('BORÇ') + textW(ds) + 16;
    var dx = 88;
    rrect(dx, 4, dw, 16, 4, 'rgba(60,16,12,.85)');
    rrectOut(dx, 4, dw, 16, 4, '#a83a2a');
    txt('BORÇ', dx + 5, 8, '#ff9a8a');
    txt(ds, dx + dw - 5, 8, '#ffd0c0', { align: 'r' });
    var prog = 1 - clamp(G.debt / DEBT_START, 0, 1);
    fr(dx + 2, 18, dw - 4, 2, 'rgba(0,0,0,.5)');
    fr(dx + 2, 18, Math.round((dw - 4) * prog), 2, P.ok);
  }
  var sold = G.stat ? (G.stat.wraps + G.stat.drinks + G.stat.boxes + (G.stat.sweets || 0)) : 0;
  var ss = '' + sold;
  var sw = textW(ss, 1, true) + 26;
  var sx2 = mx - 4 - sw;
  rrect(sx2, 4, sw, 16, 4, 'rgba(30,20,16,.78)');
  rrectOut(sx2, 4, sw, 16, 4, 'rgba(255,220,140,.22)');
  icon('wrap', sx2 + 10, 12, t);
  txt(ss, sx2 + sw - 5, 8, P.ui0, { align: 'r', mono: true });
  ctx.restore();
}

/* ---------------- sipariş balonu ---------------- */
function drawOrderBubble(c, t) {
  if (c.bubble <= .02) return;
  var items = c.items;
  /* 'istemiyorum' rozetleri icin balon UZAR: ikonun ustune binerse
     ikisi de okunmuyordu. */
  var yokListe = [], yokKalem = {};
  for (var yv = 0; yv < items.length; yv++) {
    var yy = items[yv].yok;
    if (!yy || !yy.length) continue;
    yokKalem[yv] = 1;
    for (var yj = 0; yj < yy.length; yj++) yokListe.push({ kalem: yv, m: yy[yj] });
  }
  var yokVar = yokListe.length > 0;
  /* Birden fazla KALEM istek taşıyorsa (yalnız 'sokak' fermanında iki
     dürüm gelebiliyor) satırın başına kalemin ikonu da konur, yoksa
     hangi dürümün olduğu belirsiz kalır. */
  var yokCokKalem = Object.keys(yokKalem).length > 1;
  var YS = 14;                                   /* satır yüksekliği */
  var cw = 22, bw = items.length * cw + 8;
  if (yokVar) {
    var enGenis = 0;
    for (var yg = 0; yg < yokListe.length; yg++) {
      var g = 17 + textW(SECIM_KISA[yokListe[yg].m]) + (yokCokKalem ? 13 : 0);
      if (g > enGenis) enGenis = g;
    }
    /* +8: yazi seridin sag kenarindan 2 piksel icerde biter. Daha
       genis yapmak balonu komsu musterinin balonuna sokuyor —
       tezgah yuvalari 66 piksel arayla. */
    bw = Math.max(bw, enGenis + 8);
  }
  var bh = yokVar ? 24 + yokListe.length * YS : 26;
  var bx = Math.round(c.x - bw / 2), by = Math.round(c.y - 56 - bh);
  bx = clamp(bx, 2, W - bw - 2);
  by = Math.max(by, VIEW.top + 3);               /* uzun balon tepeden taşmasın */
  var sc = easeOutBack(clamp(c.bubble, 0, 1));
  if (sc < .99) {
    ctx.save();
    ctx.translate(bx + bw / 2, by + bh);
    ctx.scale(sc, sc);
    ctx.translate(-(bx + bw / 2), -(by + bh));
  }
  var urgent = c.patience < .3;
  ctx.globalAlpha = .32; rrect(bx + 1, by + 3, bw, bh, 4, '#000'); ctx.globalAlpha = 1;
  rrect(bx, by, bw, bh, 4, urgent ? P.bad : P.ui4);
  rrect(bx + 1, by + 1, bw - 2, bh - 2, 3, urgent ? '#f7ded6' : P.ui0);
  hl(bx + 4, by + 2, bw - 8, '#ffffff');
  var tailX = clamp(c.x, bx + 6, bx + bw - 8);
  for (var q = 0; q < 5; q++) {
    fr(tailX - 3 + q, by + bh - 1 + q, 6 - q, 1, urgent ? '#f7ded6' : P.ui0);
    px(tailX - 3 + q, by + bh - 1 + q, urgent ? P.bad : P.ui4);
    px(tailX + 2, by + bh - 1 + q, urgent ? P.bad : P.ui4);
  }
  for (var i2 = 0; i2 < items.length; i2++) {
    var it = items[i2];
    var cxx = bx + 4 + i2 * cw + cw / 2 - 1;
    var iy = by + (yokVar ? 13 : bh / 2 + 1);
    var done = c.done[i2];
    if (i2 > 0) { ctx.globalAlpha = .25; vl(bx + 4 + i2 * cw - 2, by + 5, bh - 10, P.ui2); ctx.globalAlpha = 1; }
    if (done) ctx.globalAlpha = .28;
    if (it.kind === 'wrap') icon('wrap', cxx, iy, t);
    else if (it.kind === 'plate') icon('iskender', cxx, iy, t);
    else if (it.kind === 'drink') icon(it.type, cxx, iy, t);
    else if (it.kind === 'fbox') icon('fbox', cxx, iy - 1, t);
    else if (it.kind === 'sweet') icon('sweet', cxx, iy, t);
    if (it.kind === 'wrap' && it.sauce) {
      var sbx = cxx + 7, sby = iy - 7;
      disc(sbx, sby, 5, '#2a2018');
      disc(sbx, sby, 4, it.sauce === 'hot' ? '#c0281c' : '#e6dfc8');
      if (it.sauce === 'hot') {
        ell(sbx, sby + 1, 2, 3, '#8e1c14');
        ell(sbx - 1, sby + 1, 2, 3, '#ff7a62');
        px(sbx, sby - 3, '#5a8a2a'); px(sbx + 1, sby - 4, '#4a7a20');
      } else {
        ell(sbx, sby + 1, 3, 3, '#ffffff');
        px(sbx - 1, sby, '#cfc7b2'); px(sbx - 1, sby + 1, '#cfc7b2'); px(sbx + 1, sby, '#cfc7b2'); px(sbx + 1, sby + 1, '#cfc7b2');
        px(sbx, sby - 3, '#a89a78'); px(sbx, sby - 4, '#8a8060');
      }
    }
    ctx.globalAlpha = 1;
    if (done) drawCheck(cxx, iy, P.ok);
  }

  /* --- İSTEMİYORUM ŞERİDİ ---
     Rozetler eskiden ürün ikonunun altında tek başına duruyordu ve
     ne olduğu okunmuyordu. Artık kendi KIRMIZI şeridi var: yasak
     işareti + malzemenin ADI yan yana. Renk, işaret ve yazı aynı anda
     söylüyor — üçünden biri kaçsa bile ikisi kalıyor. */
  if (yokVar) {
    var sy = by + 22, sh = yokListe.length * YS;
    fr(bx + 3, sy - 2, bw - 6, 1, 'rgba(90,60,40,.35)');   /* ayraç */
    rrect(bx + 3, sy, bw - 6, sh, 2, '#8e1c14');
    rrect(bx + 3, sy, bw - 6, sh - 1, 2, '#b02a1e');
    hl(bx + 5, sy + 1, bw - 10, '#d24a38');
    for (var ys = 0; ys < yokListe.length; ys++) {
      var e = yokListe[ys], ry2 = sy + ys * YS + YS / 2 - 1, rx2 = bx + 11;
      if (yokCokKalem) {                       /* hangi ürün için */
        var ik = items[e.kalem];
        icon(ik.kind === 'plate' ? 'iskender' : (ik.kind === 'drink' ? ik.type : ik.kind),
             rx2, ry2, t, .5);
        rx2 += 13;
      }
      yokRozet(rx2, ry2, e.m);
      txt(SECIM_KISA[e.m], rx2 + 9, ry2 - 4, '#ffe0d4', { shadow: 1 });
    }
  }
  if (sc < .99) ctx.restore();

  /* sabır göstergesi */
  var px0 = c.x - 26, py0 = c.y - 52;
  var pv = clamp(c.patience, 0, 1);
  var pc = pv > .5 ? P.ok : (pv > .25 ? P.warn : P.bad);
  rrect(px0 - 1, py0 - 1, 7, 26, 2, 'rgba(20,14,12,.65)');
  var ph = Math.round(23 * pv);
  fr(px0 + 1, py0 + 23 - ph, 4, ph, pc);
  hl(px0 + 1, py0 + 23 - ph, 4, 'rgba(255,255,255,.55)');
  drawHeart(px0 + 2, py0 + 28, 1, pv > .25 ? '#e2483a' : (Math.sin(t * 12) > 0 ? '#ff8a7a' : '#8a2018'));

  if (c.lineT > 0) {
    var lw = textW(c.line) + 8;
    var lx = clamp(c.x - lw / 2, 2, W - lw - 2), ly = c.y - 74;
    ctx.globalAlpha = Math.min(1, c.lineT * 2);
    rrect(lx, ly, lw, 12, 3, c.mood === 'angry' ? P.bad : P.white);
    rrectOut(lx, ly, lw, 12, 3, P.ui5);
    txt(c.line, lx + 4, ly + 2, c.mood === 'angry' ? P.white : P.ink);
    ctx.globalAlpha = 1;
  }
  if (c.wrongT > 0) {
    ctx.globalAlpha = Math.min(1, c.wrongT * 2);
    drawX(c.x, c.y - 32, P.bad);
    ctx.globalAlpha = 1;
  }
}
/* küçük malzeme rozeti (7x7) */
function iconChip(kind, x, y) {
  var col, col2;
  if (kind === 'pickle') { col = P.g2; col2 = P.g0; }
  else if (kind === 'sauce') { col = '#e8e2cc'; col2 = '#ffffff'; }
  else if (kind === 'hot') { col = '#d8352c'; col2 = '#ff7a60'; }
  else if (kind === 'fries') { col = P.p2; col2 = P.p0; }
  else { col = P.m3; col2 = P.m1; }
  rrect(x - 4, y - 4, 8, 8, 2, P.ui4);
  rrect(x - 3, y - 3, 6, 6, 2, col);
  if (kind === 'pickle') { px(x - 1, y - 1, col2); px(x + 1, y, col2); px(x, y + 1, col2); }
  else if (kind === 'sauce') { hl(x - 2, y - 1, 4, col2); px(x - 1, y + 1, col2); }
  else if (kind === 'hot') { px(x, y - 2, col2); px(x - 1, y, col2); px(x + 1, y + 1, col2); }
  else if (kind === 'fries') { vl(x - 1, y - 2, 4, col2); vl(x + 1, y - 1, 3, col2); }
  else { hl(x - 2, y - 1, 4, col2); }
}

/* ---------------- başlık ekranı ---------------- */
var titleSpit = { rot: 0, roast: .85, mass: 1, sliceT: 0, cutDepth: 0 };

/* ---------------- dil seçici: kayan bayrak makarası ----------------
   Iki kutuluk TR/EN anahtari alti dile yetmiyordu. Yerine bir film
   seridi: bayraklar yatayda kayar, ortadaki isikli pencerede buyur,
   yanindakiler kucuk ve sonuk kalir. Secim aninda serit yayli bir
   hareketle yerine oturur, pencere bir kare parlar.

   Anima durumu burada duruyor cunku yalnizca bu cizim kullaniyor;
   G'ye tasimak kaydi buyutur, hicbir sey kazandirmaz. */
var DILUI = { anim: -1, hedef: 0, hiz: 0, parla: 0, son: -1 };

/* alti bayrak, hepsi elle: 5x8 fontun yaninda duracak kadar sade */
function bayrakCiz(kod, x, y, w, h) {
  var b = Math.max(1, Math.round(h / 3));
  if (kod === 'tr') {
    fr(x, y, w, h, '#c0281c');
    var cy = y + h / 2, r = Math.max(2, Math.round(h * .32));
    ell(x + w * .38, cy, r, r, '#ffffff');
    ell(x + w * .38 + Math.max(1, r * .35), cy, r * .78, r * .78, '#c0281c');
    var sx = Math.round(x + w * .62), sy = Math.round(cy);
    px(sx, sy - 1, '#ffffff'); px(sx - 1, sy, '#ffffff'); px(sx, sy, '#ffffff');
    px(sx + 1, sy, '#ffffff'); px(sx, sy + 1, '#ffffff');
  } else if (kod === 'gb') {
    fr(x, y, w, h, '#1a2a6c');
    for (var d = 0; d < h; d++) {
      px(x + Math.round(d * (w - 1) / (h - 1)), y + d, '#ffffff');
      px(x + w - 1 - Math.round(d * (w - 1) / (h - 1)), y + d, '#ffffff');
    }
    fr(x, y + Math.round(h / 2) - 1, w, 2, '#ffffff');
    fr(x + Math.round(w / 2) - 1, y, 2, h, '#ffffff');
    fr(x, y + Math.round(h / 2), w, 1, '#c0281c');
    fr(x + Math.round(w / 2), y, 1, h, '#c0281c');
  } else if (kod === 'de') {
    fr(x, y, w, b, '#141414');
    fr(x, y + b, w, b, '#c0281c');
    fr(x, y + b * 2, w, h - b * 2, '#e8b800');
  } else if (kod === 'es') {
    fr(x, y, w, h, '#c8102e');
    fr(x, y + b, w, h - b * 2, '#f0c020');
    /* arma yerine kucuk bir muhur: 22 piksel genislikte detay tutmaz */
    fr(x + Math.round(w * .26), y + b + 1, 2, Math.max(1, h - b * 2 - 2), '#a8202a');
  } else if (kod === 'fr') {
    var c = Math.round(w / 3);
    fr(x, y, c, h, '#1a3a8c');
    fr(x + c, y, w - c * 2, h, '#ffffff');
    fr(x + w - c, y, c, h, '#c8102e');
  } else if (kod === 'br') {
    fr(x, y, w, h, '#1a8a3c');
    /* sari baklava */
    var mx = x + w / 2, my = y + h / 2, rx = w * .38, ry = h * .38;
    for (var yy = 0; yy < h; yy++) {
      var t2 = 1 - Math.abs((yy + .5) - h / 2) / ry;
      if (t2 <= 0) continue;
      var ww = Math.max(1, Math.round(rx * t2 * 2));
      fr(Math.round(mx - ww / 2), y + yy, ww, 1, '#f0d020');
    }
    ell(mx, my, Math.max(2, h * .2), Math.max(2, h * .2), '#1a3a8c');
  }
  rc(x, y, w, h, 'rgba(0,0,0,.55)');
}

/* kucuk ucgen ok (yon: -1 sol, +1 sag)
   Satirlar ortadan disa daralir; duz kenar okun ARKASINDA kalir,
   sivri uc gosterdigi yone bakar. */
function dilOk(cx, cy, yon, col) {
  for (var r = -3; r <= 3; r++) {
    var w = 4 - Math.abs(r);
    if (w <= 0) continue;
    hl(yon > 0 ? cx - 2 : cx + 3 - w, cy + r, w, col);
  }
}

function langButtons(x, y) {
  var n = DILLER.length;
  var i, kod;
  var simdi = 0;
  for (i = 0; i < n; i++) if (DILLER[i].kod === LANG) simdi = i;
  if (DILUI.anim < 0) { DILUI.anim = simdi; DILUI.hedef = simdi; }
  if (DILUI.hedef !== simdi && Math.abs(DILUI.anim - DILUI.hedef) < .01) DILUI.hedef = simdi;

  /* zaman: cizim fonksiyonu dt almiyor, kendi saatimizi tutuyoruz */
  var t = performance.now() / 1000;
  var dt = (DILUI.son < 0) ? 0 : Math.min(.05, t - DILUI.son);
  DILUI.son = t;
  /* yayli oturma: kritik sonumlemeye yakin, hafif tasma birakir */
  var k = 190, s = 24;
  DILUI.hiz += ((DILUI.hedef - DILUI.anim) * k - DILUI.hiz * s) * dt;
  DILUI.anim += DILUI.hiz * dt;
  if (Math.abs(DILUI.hedef - DILUI.anim) < .002 && Math.abs(DILUI.hiz) < .02) {
    DILUI.anim = DILUI.hedef; DILUI.hiz = 0;
  }
  DILUI.parla = Math.max(0, DILUI.parla - dt * 3.2);

  var SW = 172, SH = 34, ADIM = 30;
  var x0 = Math.round(x), y0 = Math.round(y);
  var cx = x0 + SW / 2;

  /* gövde */
  ctx.globalAlpha = .45; rrect(x0 + 1, y0 + 2, SW, SH, 4, '#000'); ctx.globalAlpha = 1;
  rrect(x0, y0, SW, SH, 4, '#241b15');
  rrect(x0 + 1, y0 + 1, SW - 2, SH - 3, 4, '#171009');
  rrectOut(x0, y0, SW, SH, 4, P.ui5);
  /* film şeridi delikleri */
  for (i = 0; i < 11; i++) {
    var hx = x0 + 8 + i * 15;
    fr(hx, y0 + 2, 3, 2, '#0c0805');
    fr(hx, y0 + SH - 4, 3, 2, '#0c0805');
  }

  var gx0 = x0 + 15, gw = SW - 30;          /* okların arasındaki pencere */
  ctx.save();
  ctx.beginPath(); ctx.rect(gx0, y0 + 4, gw, SH - 8); ctx.clip();

  var tiklanan = -1;
  for (i = 0; i < n; i++) {
    var dx = (i - DILUI.anim) * ADIM;
    if (Math.abs(dx) > gw / 2 + ADIM) continue;
    var yak = clamp(1 - Math.abs(dx) / ADIM, 0, 1);   /* 1 = tam ortada */
    var fw = Math.round(13 + 9 * yak), fh = Math.round(9 + 5 * yak);
    var fx = Math.round(cx + dx - fw / 2);
    var fy = Math.round(y0 + 6 + (1 - yak) * 3);
    ctx.globalAlpha = .34 + .66 * yak;
    if (yak > .55) { ctx.globalAlpha = .30 * (yak - .55) / .45; rrect(fx - 2, fy - 2, fw + 4, fh + 4, 2, P.au0); ctx.globalAlpha = .34 + .66 * yak; }
    bayrakCiz(DILLER[i].bayrak, fx, fy, fw, fh);
    ctx.globalAlpha = 1;
    /* kenardakilerin kodu: kucuk, sonuk */
    if (yak < .5) {
      ctx.globalAlpha = .30 + .5 * yak;
      txt(DILLER[i].kod.toUpperCase(), Math.round(cx + dx), fy + fh + 2, P.ui1, { align: 'c' });
      ctx.globalAlpha = 1;
    }
    if (inRect(IN.x, IN.y, cx + dx - ADIM / 2, y0, ADIM, SH) &&
        IN.x > gx0 && IN.x < gx0 + gw) tiklanan = i;
  }
  ctx.restore();

  /* ışıklı pencere çerçevesi */
  var pul = .55 + .25 * Math.sin(t * 3.4);
  ctx.globalAlpha = pul;
  rrectOut(Math.round(cx - 14), y0 + 4, 28, 18, 3, P.au0);
  ctx.globalAlpha = Math.min(1, pul * .5 + DILUI.parla);
  rrectOut(Math.round(cx - 15), y0 + 3, 30, 20, 4, P.au1);
  ctx.globalAlpha = 1;
  if (DILUI.parla > 0) {
    ctx.globalAlpha = DILUI.parla * .5;
    rrect(Math.round(cx - 14), y0 + 4, 28, 18, 3, '#fff4c8');
    ctx.globalAlpha = 1;
  }

  /* seçili dilin kendi adı — makara dururken yazılır */
  var otur = clamp(1 - Math.abs(DILUI.hedef - DILUI.anim) * 1.8, 0, 1);
  var ad = DILLER[clamp(Math.round(DILUI.anim), 0, n - 1)].ad;
  ctx.globalAlpha = otur;
  txt(ad, cx, y0 + SH - 10, '#fff2cc', { align: 'c', shadow: 1 });
  ctx.globalAlpha = 1;

  /* oklar */
  var solVar = DILUI.hedef > 0, sagVar = DILUI.hedef < n - 1;
  var solUz = inRect(IN.x, IN.y, x0, y0, 15, SH);
  var sagUz = inRect(IN.x, IN.y, x0 + SW - 15, y0, 15, SH);
  dilOk(x0 + 8, y0 + SH / 2 - 1, -1, !solVar ? '#4a3f34' : (solUz ? '#fff2cc' : P.au1));
  dilOk(x0 + SW - 8, y0 + SH / 2 - 1, 1, !sagVar ? '#4a3f34' : (sagUz ? '#fff2cc' : P.au1));

  /* girdi */
  if (IN.pressed) {
    var yeni = -1;
    if (solUz && solVar) yeni = DILUI.hedef - 1;
    else if (sagUz && sagVar) yeni = DILUI.hedef + 1;
    else if (tiklanan >= 0) yeni = tiklanan;
    if (yeni >= 0 && yeni !== simdi) {
      DILUI.hedef = yeni; DILUI.parla = 1;
      setLang(DILLER[yeni].kod); SFX.ui();
    }
  }
}

function drawTitle(t) {
  /* giris ani (isitici yakilisi) paneller acikken de takip edilir */
  if (typeof logoGiris === 'function') logoGiris(t);
  /* canlı dükkân sahnesi */
  drawShopStatic(t, false);
  if (BSP.open) { drawBasarimPanel(t); return; }
  if (STATS.open) { drawStatsPanel(t); return; }
  if (SESP.open) { drawSesPanel(t); return; }
  ctx.globalAlpha = .52; fr(0, 0, W, H, '#180d07'); ctx.globalAlpha = 1;
  /* köşe karartma */
  for (var i = 0; i < 60; i++) {
    ctx.globalAlpha = .012 * (60 - i) / 6;
    rrectOut(-i, -i, W + i * 2, H + i * 2, 8, '#000');
  }
  ctx.globalAlpha = 1;

  /* logo — Blender'da uretilmis, animasyonlu (js/logo.js). Dar telefonda
     ust bant kirpildigi icin gorunur ust kenara yaslanir; 88 px'lik logo
     orada BASLA dugmesine 3 px kala biter (regres olcuyor). Resimler
     henuz cozulmediyse (ilk kareler) eski tabela cizilir. */
  if (typeof logoCiz !== 'function' || !logoCiz(t, W / 2, baslikLogoUst())) eskiTabela(t);
  psDraw();
  drawTitleMenu(t);
}

/* Logonun ust kenari ve alt kenari: menu yigini bu ikisine gore dizilir. */
function baslikLogoUst() { return VIEW.top ? VIEW.top + 1 : 24; }
function baslikLogoAlt() {
  return baslikLogoUst() + (typeof logoYukseklik === 'function' ? logoYukseklik() : 56);
}

/* Blender logosundan onceki, kodla cizilen tabela. Artik yalniz yedek:
   logo resimleri cozulmeden once ya da veri dosyasi yoksa. */
function eskiTabela(t) {
  var ly = (VIEW.top ? VIEW.top + 6 : 34) + Math.sin(t * 1.6) * 2;
  var lw = 258;
  ctx.globalAlpha = .45; rrect(W / 2 - lw / 2 + 3, ly + 4, lw, 56, 6, '#000'); ctx.globalAlpha = 1;
  rrect(W / 2 - lw / 2, ly, lw, 56, 6, P.red3);
  rrect(W / 2 - lw / 2 + 2, ly + 2, lw - 4, 52, 5, P.red1);
  rrect(W / 2 - lw / 2 + 4, ly + 4, lw - 8, 48, 4, P.red0);
  ctx.globalAlpha = .3; rrect(W / 2 - lw / 2 + 4, ly + 4, lw - 8, 16, 4, '#ffffff'); ctx.globalAlpha = 1;
  rrectOut(W / 2 - lw / 2, ly, lw, 56, 6, P.ui5);
  for (var b2 = 0; b2 < 11; b2++) {
    var on = Math.sin(t * 5 + b2 * .7) > -.35;
    var bx2 = W / 2 - lw / 2 + 10 + b2 * 24;
    disc(bx2, ly - 1, 2, on ? P.au0 : '#7a6a3a');
    disc(bx2, ly + 55, 2, on ? P.au0 : '#7a6a3a');
    if (on) { ctx.globalAlpha = .22; disc(bx2, ly - 1, 4, P.au1); disc(bx2, ly + 55, 4, P.au1); ctx.globalAlpha = 1; }
  }
  /* Tabelanın iki satırı: üstte küçük, altta büyük ad */
  txt('BABAMIN', W / 2, ly + 8, P.white, { align: 'c', sc: 2, outline: P.ui5 });
  txt('DÖNERCİSİ', W / 2, ly + 30, P.au0, { align: 'c', sc: 3, outline: P.ui5 });
  /* şiş ikonu */
  icon('wrap', W / 2 - 108, ly + 30, t);
  icon('wrap', W / 2 + 108, ly + 30, t);

  if (chance(.25)) part({ x: rnd(W / 2 - 130, W / 2 + 130), y: ly + 58, vx: rnd(-6, 6), vy: rnd(-28, -12), life: rnd(.5, 1), col: pick([P.f1, P.f2, P.f0]), g: -10, sz: 1 });
}

function drawTitleMenu(t) {
  /* --- ANA MENU ---
     Butonlar telefonda parmakla basilacak kadar buyuk ve ortada
     toplu; kenarlara dagilmis kucuk kutular mobilde isabet ettirmesi
     zordu. Dil secimi asagida, kendi seridinde. */
  var hasSave = !!loadGame();
  /* Yigin, logonun altindan ipucu seridine kadar olan bosluga ORTALANIR.
     Eskiden sabit by = 138 - VIEW.bot idi ve kayit varken SES/REKOR
     sirasi ipucu seridinin 6 px ALTINA giriyordu (masaustunde de).
     Telefonda kayitli yigin (76 px) yine sigmazsa serit tek satira
     iner: en iyi gun ve ipucu sirayla gosterilir. */
  var yigin = hasSave ? 76 : 54;
  var ust = baslikLogoAlt() + 3;
  var sy = (H - VIEW.bot - 38) - 24, sh = 22;
  if (ust + yigin > sy - 2) { sy += 10; sh = 12; }
  var bw = 132, bx = Math.round(W / 2 - bw / 2);
  var by = Math.max(ust, Math.round(ust + (sy - 2 - ust - yigin) / 2));
  if (hasSave) {
    if (button(bx, by, bw, 26, 'DEVAM ET', '#3f8a4a', true)) { SFX.ui(); loadAndGo(); }
    if (button(bx, by + 30, bw, 22, 'YENİ OYUN', P.red1)) {
      SFX.ui(); clearSave(); resetProgress(); goIntro();
    }
  } else {
    if (button(bx, by, bw, 30, 'BAŞLA', P.red1, true)) { SFX.ui(); goIntro(); }
  }
  /* yan yana iki kucuk: ses ve rekorlar */
  var yy = by + (hasSave ? 56 : 34);
  var kx3 = Math.round(W / 2 - 78);
  if (button(kx3, yy, 50, 20, 'SES', '#3f8ac0')) { SESP.open = true; SFX.ui(); }
  if (button(kx3 + 53, yy, 50, 20, 'REKOR', '#3f6fbd')) { STATS.open = true; SFX.ui(); }
  if (button(kx3 + 106, yy, 50, 20, 'BAŞARIM', '#b0862a')) { BSP.open = true; SFX.ui(); }
  /* Tam ekran iOS WebView'da calismiyor; dokunmatikte dugmeyi hic gosterme. */
  if (!TOUCH && button(8, 246, 84, 18, fsOn() ? 'PENCERE' : 'TAM EKRAN', '#7a5aa0')) { SFX.ui(); fsToggle(); }
  /* en iyi gun + ipucu seridi: dil butonlarinin USTUNDE biter */
  ctx.globalAlpha = .70;
  rrect(W / 2 - 140, sy, 280, sh, 4, 'rgba(20,12,8,.75)');
  ctx.globalAlpha = 1;
  if (sh > 12) {
    txt(T('En iyi: Gün ') + (G.best || 1), W / 2, sy + 2, P.au1, { align: 'c' });
    txt(TIPS_LOAD[Math.floor(t / 4) % TIPS_LOAD.length], W / 2, sy + 12, P.ui1, { align: 'c' });
  } else if (Math.floor(t / 4) % 2 === 0) {
    txt(T('En iyi: Gün ') + (G.best || 1), W / 2, sy + 2, P.au1, { align: 'c' });
  } else {
    txt(TIPS_LOAD[Math.floor(t / 8) % TIPS_LOAD.length], W / 2, sy + 2, P.ui1, { align: 'c' });
  }
  /* dil seçimi — en altta kendi seridinde.
     Dar telefonda alt bant kirpildigi icin gorunur alt kenara yaslanir. */
  langButtons(W / 2 - 86, H - VIEW.bot - 38);
  ftDraw();
}
function drawTitleBasarim(t) { if (BSP.open) drawBasarimPanel(t); }
function loadAndGo() {
  var s = loadGame();
  if (s) { G.day = s.day || 1; G.money = s.money || 0; G.up = s.up || {}; G.best = s.best || 1; G.totalSold = s.totalSold || 0; G.debt = (s.debt === undefined ? DEBT_START : s.debt); if (s.stats) G.stats = s.stats; if (s.custom) G.custom = s.custom; G.dersGorulmus = !!s.dersGorulmus;
    G.fpara = (s.fpara === undefined ? FP_BASLANGIC : s.fpara);
    G.fgun = s.fgun || 0; G.hane = s.hane || null; G.fbatik = s.fbatik || 0;
    G.ev = s.ev || 0;
    G.branch = s.branch || 0; G.city = (s.city === undefined ? -1 : s.city);
    /* Ozel musteri takvimi. Eski kayitta yok: siradaki ozel bugunden
       birkac gun sonraya kurulur, kayda dondugu an tabur gelmesin. */
    G.rakipHedef = s.rakipHedef || 0;
    G.rakipKapandi = !!s.rakipKapandi;
    G.rakipSeri = s.rakipSeri || 0;
    G.macHedef = s.macHedef || 0;
    G.ozelGecmis = s.ozelGecmis || {};
    G.ozelHedef = s.ozelHedef || ((s.day || 1) + OZEL_ILK_MIN +
      Math.floor(Math.random() * (OZEL_ILK_MAK - OZEL_ILK_MIN + 1)));
    G.bs = s.bs || null; }
  /* Eski kayitta G.bs yok: hak edilmisleri SESSIZCE ac, 40 bildirim yagmasin. */
  if (typeof basarimBaslat === 'function') basarimBaslat(true);
  goIntro();
}
function goIntro() {
  /* hikâye kesiti yalnızca bir kez */
  if (!G.prologueSeen && G.day === 1) { proStart(); return; }
  G.scene = 'intro'; G.sceneT = 0;
}

/* ---------------- gün girişi ---------------- */
function drawIntro(t) {
  drawShopStatic(t, false);
  ctx.globalAlpha = .55; fr(0, 0, W, H, '#140a06'); ctx.globalAlpha = 1;
  var k = clamp(G.sceneT * 2.2, 0, 1);
  /* 1. gün: babadan kalan dükkân hikâyesi */
  if (G.day === 1) {
    var sy = lerp(-120, 40, easeOutBack(k));
    panel(W / 2 - 120, sy, 240, 122, 'USTA DÖNER');
    txt('Baban vefat etti.', W / 2, sy + 12, P.ink, { align: 'c' });
    txt('Dükkân sana kaldı…', W / 2, sy + 24, P.ink, { align: 'c' });
    txt('ama üzerinde ağır bir borç var:', W / 2, sy + 40, P.ui4, { align: 'c' });
    txt('$' + fmtMoney(DEBT_START), W / 2, sy + 52, '#a83a2a', { align: 'c', sc: 2 });
    txt('Tezgâhta kazan, dükkânı büyüt,', W / 2, sy + 74, P.ui4, { align: 'c' });
    txt('şehre şube aç. Borcu kapat,', W / 2, sy + 84, P.ui4, { align: 'c' });
    txt('babanın dükkânını kurtar!', W / 2, sy + 94, P.ui4, { align: 'c' });
    if (G.sceneT > .5 && button(W / 2 - 46, sy + 104, 92, 16, 'DÜKKÂNI AÇ', '#3f8a4a', true)) { SFX.bell(); startDay(); }
    psDraw(); ftDraw();
    return;
  }
  /* DEMIRKENT: normal gun paneli yerine rejim gazetesi */
  if (fermanSehri(G)) { drawGazete(t, k); return; }
  /* Satirlar SIRAYLA dizilir ve panel icerige gore uzar. Eskiden sabit
     ofsetlerdi: yagmurlu gunde iki satir DUKKANI AC dugmesinin altinda
     kaliyor, okunmuyordu. */
  /* Hava satiri panelde yer kapliyor: dort durumun ucu satir ekliyor. */
  var yagmur = G.weather === 'rain';
  var havaVar = yagmur || G.weather === 'kar' || G.weather === 'sicak';
  var satir = (havaVar ? 1 : 0) + (G.macGun ? 1 : 0);
  var ph = 84 + satir * 24;
  var y = lerp(-60, satir ? 68 - (satir - 1) * 8 : 80, easeOutBack(k));
  panel(W / 2 - 96, y, 192, ph);
  txt(T('GÜN ') + G.day, W / 2, y + 10, P.red1, { align: 'c', sc: 2 });
  var cfg = dayCfg(G.day, G);
  var sy2 = y + 34;
  txt(T('Süre: ') + fmtTime(cfg.len) + T('    Sıra: ') + cfg.slots, W / 2, sy2, P.ui3, { align: 'c' });
  sy2 += 12;
  if (G.debt > 0) txt(T('Kalan borç: $') + fmtMoney(G.debt) + (G.branch ? '   •   ' + G.branch + T(' şube') : ''), W / 2, sy2, '#a83a2a', { align: 'c' });
  else txt('Borç bitti — dükkân tamamen senin!', W / 2, sy2, P.ok, { align: 'c' });
  sy2 += 12;
  if (yagmur) {
    txt('☂ YAĞMURLU GÜN', W / 2, sy2, '#6b9ad8', { align: 'c' }); sy2 += 10;
    txt('az müşteri • bol paket sipariş', W / 2, sy2, P.ui3, { align: 'c' }); sy2 += 12;
  } else if (G.weather === 'kar') {
    txt('KARLI GÜN', W / 2, sy2, '#dbe7f2', { align: 'c' }); sy2 += 10;
    txt('seyrek müşteri • sabırlı • bahşiş bol', W / 2, sy2, P.ui3, { align: 'c' }); sy2 += 12;
  } else if (G.weather === 'sicak') {
    txt('SICAK DALGASI', W / 2, sy2, '#ffc86a', { align: 'c' }); sy2 += 10;
    txt('herkes içecek ister • sabır az • ızgara çabuk yakar', W / 2, sy2, P.ui3, { align: 'c' }); sy2 += 12;
  }
  if (G.macGun) {
    txt('MAÇ GÜNÜ', W / 2, sy2, '#8ad86a', { align: 'c' }); sy2 += 10;
    txt('gün ortasında taraftar akını — acele ederler, bahşiş bol', W / 2, sy2, P.ui3, { align: 'c' }); sy2 += 12;
  }
  if (G.sceneT > .4 && button(W / 2 - 46, sy2 + 2, 92, 18, 'DÜKKÂNI AÇ', '#3f8a4a', true)) { SFX.bell(); startDay(); }
  psDraw(); ftDraw();
}

/* ---------------- DEMIRKENT: rejim gazetesi ---------------- */
function drawGazete(t, k) {
  /* G.ferman ancak startDay()'de kurulur; gun girisinde hala DUNKU liste
     duruyor. fermanSec(gun) deterministik oldugu icin gazete dogrudan
     gunden turetir ve startDay ayni listeyi uretir. */
  var liste = fermanSec(G.day);
  /* Dun yururlukteydi, bugun degil -> "kalkan ferman" haberi. */
  var kalkan = [];
  if (G.day > 1) {
    var dun = fermanSec(G.day - 1);
    for (var q = 0; q < dun.length; q++) {
      var hala = false;
      for (var w = 0; w < liste.length; w++) if (liste[w].id === dun[q].id) hala = true;
      if (!hala) kalkan.push(dun[q]);
    }
  }
  var liderVar = (typeof liderGunu === 'function') && liderGunu(G.fgun, G.day);

  var pw = 304, satirH = 21, haberH = 19;
  /* --- UYARLANIR YERLESIM ---
     Panel gorunur banda kirpiliyor (mobilde dar). Once en zengin duzen
     denenir; sigmazsa once soz kutusu, sonra dorduncu haber dusulur.
     Boylece masaustunde dolu, mobilde tasmayan bir sayfa cikar. */
  /* 'Kalkan ferman' artik soz kutusunun ALT SATIRI; ayri bir satir degil. */
  function yukseklik(nh, sozVar, kalkanVar) {
    var alt = sozVar ? (kalkanVar ? 34 : 24) : (kalkanVar ? 15 : 0);
    return 55 + liste.length * satirH + 8 + nh * haberH +
           (liderVar ? 18 : 0) + alt + 32;
  }
  /* Zenginlik sirasi: once soz kutusu, sonra haber sayisi, en sonda
     kalkan ferman satiri dusulur. En seyrek basamak her ekranda siğar —
     mobilde gorunur bant 216px'e kadar iniyor. */
  var duzen = [
    [4, true, true], [3, true, true], [4, false, true], [3, false, true],
    [2, false, true], [1, false, true], [1, false, false], [0, false, false]
  ];
  var son = duzen[duzen.length - 1];
  var nh = son[0], sozVar = son[1], kalkanGoster = son[2];
  var ph = yukseklik(nh, sozVar, kalkanGoster && kalkan.length > 0);
  for (var d0 = 0; d0 < duzen.length; d0++) {
    var kv = duzen[d0][2] && kalkan.length > 0;
    var hh = yukseklik(duzen[d0][0], duzen[d0][1], kv);
    if (panelKutu(0, hh)[1] >= hh) {
      nh = duzen[d0][0]; sozVar = duzen[d0][1]; kalkanGoster = duzen[d0][2]; ph = hh;
      break;
    }
  }
  if (!kalkanGoster) kalkan = [];        /* cizim de ayni karari gorsun */
  var haber = haberSec(G.day, nh);
  var kk = panelKutu(0, ph); ph = kk[1];
  var x = Math.round(W / 2 - pw / 2);
  var y = Math.round(lerp(-ph, kk[0], easeOutBack(k)));

  /* --- kagit --- */
  ctx.globalAlpha = .46; fr(x + 5, y + 6, pw, ph, '#000'); ctx.globalAlpha = 1;
  fr(x, y, pw, ph, '#b8ad8e');
  fr(x + 1, y + 1, pw - 2, ph - 2, '#e6dcbe');
  hl(x + 1, y + 1, pw - 2, '#f4ecd4');
  ctx.globalAlpha = .10;
  for (var d1 = 0; d1 < 30; d1++) {
    px(x + 4 + Math.floor(hash1(d1 * 3.7) * (pw - 8)),
       y + 4 + Math.floor(hash1(d1 * 8.3) * (ph - 8)), '#6a5f45');
  }
  ctx.globalAlpha = 1;
  ctx.globalAlpha = .13; fr(x + Math.round(pw / 2), y + 2, 1, ph - 4, '#6a5f45'); ctx.globalAlpha = 1;

  /* ================= KUNYE ================= */
  var my = y + 4;
  gazeteArma(x + pw / 2, my + 1);
  gazeteSusleme(x + 30, my + 8, 1);
  gazeteSusleme(x + pw - 30, my + 8, -1);
  txt(T('DEMİRKENT HABER'), x + pw / 2, my + 17, '#1e1a14', { align: 'c', sc: 2 });
  fr(x + 10, my + 35, pw - 20, 1, '#2a251c');
  fr(x + 10, my + 37, pw - 20, 2, '#2a251c');
  txt(T('GÜN ') + G.day, x + 12, my + 42, '#5a5142');
  txt(T('RESMİ GAZETE'), x + pw / 2, my + 42, '#5a5142', { align: 'c' });
  txt(T('BEDELSİZ'), x + pw - 12, my + 42, '#5a5142', { align: 'r' });
  /* hava satiri: kunyeyi gazete gibi dolduran kucuk ayrinti */
  /* Derece isareti (U+00B0) fontta yok; yazi ile yazilir. */
  txt(T('Hava: ') + T(gazeteHava(G.day)) + '   ' + gazeteDerece(G.day) + T(' derece'),
      x + 12, my + 51, '#7a7360');
  txt(T('Baskı: ') + (40000 + Math.floor(hash1(G.day * 2.9) * 9000)),
      x + pw - 12, my + 51, '#7a7360', { align: 'r' });
  fr(x + 10, my + 58, pw - 20, 1, '#8a8065');

  /* ================= MANSETLER ================= */
  var hy = my + 62;
  for (var m = 0; m < liste.length; m++) {
    var f = liste[m], ry = hy + m * satirH;
    var mn = FERMAN_MANSET[f.id] || f.metin;
    txt(T(mn), x + pw / 2, ry, '#1e1a14', { align: 'c' });
    txt(T(f.metin), x + pw / 2, ry + 10, '#8a2318', { align: 'c' });
    if (m < liste.length - 1) {
      ctx.globalAlpha = .35; hl(x + 60, ry + 19, pw - 120, '#8a8065'); ctx.globalAlpha = 1;
    }
  }

  /* ================= GÜNÜN HABERLERİ ================= */
  var cy = hy + liste.length * satirH + 2;
  fr(x + 10, cy - 3, pw - 20, 1, '#8a8065');
  var fw = 46, fh = nh * haberH - 4;
  gazeteFoto(x + 12, cy + 2, fw, Math.min(fh, 30));
  if (fh > 34) gazeteSutun(x + 12, cy + 36, fw - 2, Math.floor((fh - 34) / 4), 2.3);
  var nx = x + 12 + fw + 8, nw = pw - (fw + 34);
  for (var n = 0; n < haber.length; n++) {
    var hb = haber[n], ny = cy + 2 + n * haberH;
    txt(T(hb[0]), nx, ny, '#2a2620');
    txt(T(hb[1]), nx, ny + 9, '#6a6455');
    if (n < haber.length - 1) {
      ctx.globalAlpha = .28; hl(nx, ny + 17, nw, '#8a8065'); ctx.globalAlpha = 1;
    }
  }

  /* ================= LİDER ZİYARETİ DUYURUSU ================= */
  var ay = cy + 4 + haber.length * haberH;
  if (liderVar) {
    fr(x + 10, ay - 3, pw - 20, 1, '#8a8065');
    fr(x + 10, ay, pw - 20, 14, '#8e1c14');
    fr(x + 10, ay, pw - 21, 13, '#b83228');
    hl(x + 11, ay, pw - 23, '#d8493a');
    txt(T('LİDER BUGÜN ESNAFI ZİYARET EDECEK'), x + pw / 2, ay + 3, '#ffe9d0', { align: 'c' });
    ay += 18;
  }

  /* ============ LİDERİN SÖZÜ + KALKAN FERMAN (tek blok) ============ */
  if (sozVar) {
    var bh = kalkan.length ? 30 : 20;
    fr(x + 10, ay - 2, pw - 20, bh, '#dcd2b4');
    rc(x + 10, ay - 2, pw - 20, bh, '#a8a08a');
    fr(x + 10, ay - 2, 3, bh, '#8e1c14');
    txt(T('LİDERİN SÖZÜ'), x + 20, ay + 1, '#8a2318');
    txt(T(liderSozu(G.day)), x + 20, ay + 10, '#4a4436');
    if (kalkan.length) {
      var et2 = T('KALKAN FERMAN: ');
      txt(et2, x + 20, ay + 19, '#5a5142');
      txt(T(kalkan[0].metin) + (kalkan.length > 1 ? ' +' + (kalkan.length - 1) : ''),
          x + 20 + textW(et2), ay + 19, '#2f6a3a');
    }
    ay += bh + 4;
  } else if (kalkan.length) {
    fr(x + 10, ay - 3, pw - 20, 1, '#8a8065');
    var et = T('KALKAN FERMAN: ');
    var ad = T(kalkan[0].metin) + (kalkan.length > 1 ? ' +' + (kalkan.length - 1) : '');
    var tw = textW(et) + textW(ad);
    txt(et, x + pw / 2 - tw / 2, ay + 1, '#5a5142');
    txt(ad, x + pw / 2 - tw / 2 + textW(et), ay + 1, '#2f6a3a');
    ay += 15;
  }

  /* ================= ALT NOT + DÜĞME ================= */
  txt(T('Fermanı duvardaki kâğıttan tekrar okuyabilirsin.'),
      x + pw / 2, ay + 2, '#6a6455', { align: 'c' });
  if (G.sceneT > .4 && button(W / 2 - 52, ay + 12, 104, 18, 'DÜKKÂNI AÇ', '#3f8a4a', true)) {
    SFX.bell(); startDay();
  }
  psDraw(); ftDraw();
}

/* Gazete kunyesindeki devlet armasi: kanatli, yildizli, sertlestirilmis. */
function gazeteArma(cx, cy) {
  cx = Math.round(cx); cy = Math.round(cy);
  var S = '#1e1a14', K = '#e6dcbe';
  /* Kanatlar: her sirada iki px daha genis, altta kalinlasan tuy sirasi.
     Ince cizgi kalmasin diye 2px yuksekliginde bloklar. */
  for (var i = 0; i < 5; i++) {
    var uz = 5 + i * 3;
    fr(cx - 5 - uz, cy + 3 + i * 2, uz, 2, S);
    fr(cx + 6, cy + 3 + i * 2, uz, 2, S);
  }
  /* govde: omuzdan kuyruga daralan */
  fr(cx - 3, cy + 2, 7, 8, S);
  fr(cx - 2, cy + 10, 5, 2, S);
  fr(cx - 1, cy + 12, 3, 1, S);
  /* iki kafa: cift basli arma */
  fr(cx - 4, cy, 3, 3, S); fr(cx + 2, cy, 3, 3, S);
  px(cx - 5, cy + 1, S);   px(cx + 5, cy + 1, S);
  /* tac */
  fr(cx - 2, cy - 2, 5, 1, S);
  px(cx - 2, cy - 3, S); px(cx, cy - 4, S); px(cx + 2, cy - 3, S);
  /* gogusteki yildiz (kagit rengiyle oyulmus) */
  px(cx, cy + 4, K);
  fr(cx - 2, cy + 5, 5, 1, K);
  fr(cx - 1, cy + 6, 3, 1, K);
  px(cx - 2, cy + 7, K); px(cx + 2, cy + 7, K);
}
/* Kunyenin iki yanindaki kivrimli susleme. */
function gazeteSusleme(x, y, yon) {
  x = Math.round(x); y = Math.round(y);
  var S = '#2a251c';
  for (var i = 0; i < 9; i++) px(x + yon * i, y + (i < 3 ? 0 : (i < 6 ? -1 : 0)), S);
  px(x + yon * 10, y - 2, S); px(x + yon * 11, y - 3, S);
  px(x + yon * 10, y + 2, S); px(x + yon * 11, y + 3, S);
  fr(x - (yon > 0 ? 0 : 2), y - 1, 2, 3, S);
}
/* Gazete sutunu: gercek yazi degil, gazete dokusu veren cizgiler. */
function gazeteSutun(x, y, w, n, tohum) {
  x = Math.round(x); y = Math.round(y);
  ctx.globalAlpha = .52;
  for (var i = 0; i < n; i++) {
    var uz = Math.round(w * (0.55 + hash1(tohum + i * 1.9) * 0.45));
    fr(x, y + i * 4, uz, 1, '#4a4436');
  }
  ctx.globalAlpha = 1;
}
/* Gazete fotografi: rejim anitinin silueti, tramlanmis gri kutu icinde. */
function gazeteFoto(x, y, w, h) {
  x = Math.round(x); y = Math.round(y);
  fr(x, y, w, h, '#9a927e');
  fr(x + 1, y + 1, w - 2, h - 2, '#c2bba4');
  /* tram: seyrek yatay cizgiler */
  ctx.globalAlpha = .30;
  for (var i = 1; i < h - 1; i += 2) fr(x + 1, y + i, w - 2, 1, '#6a6455');
  ctx.globalAlpha = 1;
  /* anit silueti */
  var mx = x + Math.round(w / 2), tb = y + h - 3;
  fr(mx - 9, tb, 18, 2, '#4a4436');
  fr(mx - 6, tb - 3, 12, 3, '#5a5142');
  fr(mx - 2, tb - 15, 5, 12, '#3a352a');
  fr(mx - 1, tb - 18, 3, 3, '#3a352a');
  px(mx, tb - 19, '#2a251c');
  /* iki yanda bayrak direkleri */
  fr(mx - 13, tb - 10, 1, 10, '#4a4436');
  fr(mx + 12, tb - 10, 1, 10, '#4a4436');
  fr(mx - 12, tb - 10, 4, 3, '#8a2318');
  fr(mx + 9, tb - 10, 4, 3, '#8a2318');
}

/* ---------------- gün sonu ---------------- */
function drawDayEnd(t) {
  /* Demirkent ayri mod: kazanc ozeti degil GECINME hesabi cikar. */
  if (G.hesap) { drawHesap(t); return; }
  drawShopStatic(t, false);
  ctx.globalAlpha = .6; fr(0, 0, W, H, '#140a06'); ctx.globalAlpha = 1;
  var k = clamp(G.sceneT * 2, 0, 1);
  var y = lerp(-100, 48, easeOutBack(k));
  /* Ceza satiri da yer kaplar: yoksa BORC TAKSITI satirinin uzerine biner. */
  var extraH = (G.stat.branch > 0 ? 24 : 0) + (G.stat.fine > 0 ? 14 : 0) +
               (G.ferman && G.ferman.kapandi ? 12 : 0) +
               (G.bahisSonuc ? (G.bahisSonuc.kapandi ? 36 : 24) : 0);
  panel(W / 2 - 108, y, 216, 178 + extraH, T('GÜN ') + G.day + T(' BİTTİ'));
  var st = G.stat;
  var rows = [['wrap', 'Dürüm', st.wraps]];
  if (TUN.iskOn(G)) rows.push(['iskender', 'İskender', st.isk || 0]);
  if (TUN.drinkOn(G) || TUN.ayranOn(G)) rows.push(['cola', 'İçecek', st.drinks]);
  if (TUN.fboxOn(G)) rows.push(['fbox', 'Patates porsiyon', st.boxes]);
  if (TUN.sweetOn(G)) rows.push(['sweet', 'Tatlı', st.sweets || 0]);
  rows.push([null, 'Kaçan müşteri', st.lost]);
  for (var i = 0; i < rows.length; i++) {
    var ry = y + 20 + i * 13;
    if (G.sceneT * 3 < i + 1) continue;
    if (rows[i][0]) icon(rows[i][0], W / 2 - 86, ry + 4, t);
    txt(rows[i][1], W / 2 - 74, ry, P.ui4);
    txt('x' + rows[i][2], W / 2 + 92, ry, rows[i][0] ? P.ink : P.ui3, { align: 'r' });
    ctx.globalAlpha = .28; hl(W / 2 - 92, ry + 10, 184, P.ui2); ctx.globalAlpha = 1;
  }
  var ly = y + 24 + rows.length * 13;
  if (G.sceneT > 1.2) {
    txt('KAZANÇ', W / 2 - 92, ly, P.ui5);
    txt('$' + fmtMoney(st.earned), W / 2 + 92, ly - 3, P.red1, { align: 'r', sc: 2 });
  }
  if (G.sceneT > 1.6) txt(T('(bahşiş dahil $') + fmtMoney(st.tips) + ')', W / 2 + 92, ly + 14, P.ui3, { align: 'r' });
  /* şube geliri */
  var dy2 = 0;
  if (st.branch > 0 && G.sceneT > 1.65) {
    txt((G.branch || 0) + T(' ŞUBE GELİRİ'), W / 2 - 92, ly + 26, P.au2);
    txt('+$' + fmtMoney(st.branch), W / 2 + 92, ly + 26, P.au2, { align: 'r' });
    txt(T('performans %') + Math.round((st.brPerf || 1) * 100), W / 2 + 92, ly + 36, P.ui3, { align: 'r' });
    dy2 = 24;
  }
  /* Kesilen cezalar: Demirkent fermani ve mufettis. Gorunmezse oyuncu
     parasinin nereye gittigini anlamiyordu. */
  if (G.sceneT > 1.68 && st.fine > 0) {
    txt(T('KESİLEN CEZA'), W / 2 - 92, ly + 26 + dy2, '#e2483a');
    txt('-$' + fmtMoney(st.fine), W / 2 + 92, ly + 26 + dy2, '#e2483a', { align: 'r' });
    dy2 += 14;
  }
  if (G.ferman && G.ferman.kapandi && G.sceneT > 1.68) {
    txt(T('Ferman ihlali: dükkân erken kapatıldı.'), W / 2, ly + 26 + dy2, '#e2483a', { align: 'c' });
    dy2 += 12;
  }
  /* BAHIS sonucu: kazanc satirlarindan sonra, borctan once. */
  if (G.sceneT > 1.69 && G.bahisSonuc) {
    dy2 = bahisSonucSatiri(ly + 26 + dy2) - (ly + 26);
  }
  if (G.sceneT > 1.7 && st.debtPaid > 0) {
    txt('BORÇ TAKSİTİ', W / 2 - 92, ly + 26 + dy2, '#a83a2a');
    txt('-$' + fmtMoney(st.debtPaid), W / 2 + 92, ly + 26 + dy2, '#a83a2a', { align: 'r' });
    txt(T('kalan borç: $') + fmtMoney(G.debt), W / 2 + 92, ly + 36 + dy2, P.ui3, { align: 'r' });
  }
  if (!G.tutanak && G.sceneT > 1.9 && !G.celeb &&
      button(W / 2 - 46, y + 156 + extraH, 92, 18, 'DÜKKÂNA GİT', P.red1, true)) {
    SFX.ui(); G.scene = 'shop'; G.sceneT = 0; SHOP.bake = null;
  }
  psDraw(); ftDraw();
  if (G.tutanak) drawTutanak(t);
  if (G.celeb) drawDebtFree(t);
}

/* ---------------- DEMIRKENT: gecinme hesabi ----------------
   Zorunlu kalemler kapatilamaz; digerlerine tiklayarak vazgecebilirsin.
   Kasa eksiye duser — baski buradan gelir.
   DIKKAT: 'H' global tuval yuksekligi; hesap degiskeni HS. */
function drawHesap(t) {
  var HS = G.hesap;
  HS.t += 1 / 60;
  if (EVP.open) { drawShopStatic(t, true); drawEvPaneli(t); psDraw(); ftDraw(); return; }
  drawShopStatic(t, true);
  ctx.globalAlpha = .80; fr(0, 0, W, H, '#0b0a09'); ctx.globalAlpha = 1;

  var a = clamp(HS.t * 2.2, 0, 1);
  var pw = 268;
  var ph = 74 + HS.kalem.length * 13 + 44 + (HS.kapandi ? 32 : 0);
  var kk = panelKutu(0, ph); ph = kk[1];
  var x = Math.round(W / 2 - pw / 2);
  var y = Math.round(lerp(-ph, kk[0], easeOutBack(a)));

  ctx.globalAlpha = .45; fr(x + 4, y + 5, pw, ph, '#000'); ctx.globalAlpha = 1;
  fr(x, y, pw, ph, '#b9b096');
  fr(x + 1, y + 1, pw - 2, ph - 2, '#e8e0c6');
  hl(x + 1, y + 1, pw - 2, '#f6efd8');
  fr(x, y, pw, 3, '#4a4e54');

  txt(T('GÜN SONU HESABI'), x + pw / 2, y + 8, '#2a2620', { align: 'c' });
  txt(T('Demirkent — gün ') + ((G.fgun || 0) + 1) + '  -  ' + T(evSimdiki().ad),
      x + pw / 2, y + 19, '#7a7360', { align: 'c' });
  ctx.globalAlpha = .45; hl(x + 12, y + 30, pw - 24, '#8a8370'); ctx.globalAlpha = 1;

  var ry = y + 34;
  /* Bu iki satir KASAYA ZATEN girdi; bilgi amacli. */
  txt(T('BUGÜN'), x + 14, ry, '#8a8370');
  ry += 11;
  txt(T('Tezgâh geliri'), x + 14, ry, '#3a3630');
  txt('+$' + fmtMoney(HS.gelir), x + pw - 14, ry, '#2f6a3a', { align: 'r' });
  ry += 12;
  if (HS.ceza > 0) {
    txt(T('Ferman cezası'), x + 14, ry, '#3a3630');
    txt('-$' + fmtMoney(HS.ceza), x + pw - 14, ry, '#a83a2a', { align: 'r' });
    ry += 12;
  }
  ctx.globalAlpha = .35; hl(x + 12, ry - 2, pw - 24, '#8a8370'); ctx.globalAlpha = 1;
  ry += 4;
  txt(T('GİDERLER'), x + 14, ry, '#8a8370');
  ry += 11;

  for (var i = 0; i < HS.kalem.length; i++) {
    var g = HS.kalem[i], acik = HS.sec[g.id];
    var kx = x + 14, ky = ry - 1;
    var ust = !HS.kapandi && !g.zorunlu && inRect(IN.x, IN.y, kx - 2, ky - 2, pw - 26, 12);
    rrect(kx, ky, 9, 9, 2, g.zorunlu ? '#8a8370' : (ust ? '#c8a23a' : '#6a6455'));
    rrect(kx + 1, ky + 1, 7, 7, 2, acik ? (g.zorunlu ? '#7a6a3a' : '#3f8a4a') : '#e8e0c6');
    if (acik) {
      fr(kx + 3, ky + 4, 1, 3, '#ffffff');
      fr(kx + 4, ky + 5, 3, 1, '#ffffff');
      fr(kx + 5, ky + 3, 1, 3, '#ffffff');
    }
    var ad = T(g.ad);
    if (g.id === 'yemek') ad += ' (' + HS.kisi + ')';
    if (g.id === 'ilac') ad += ' (' + HS.hasta + ')';
    txt(ad, x + 28, ry, acik ? '#3a3630' : '#9a9282');
    if (g.id === 'ev') {
      /* Daire ADI baslikta duruyor; burada yalniz dugme — uzun daire
         adlari dugmenin altina giriyordu. */
      var ustTasin = !HS.kapandi && (G.ev || 0) < EVLER.length - 1;
      if (ustTasin && button(x + pw - 124, ry - 2, 54, 12, T('TAŞIN'), '#3f6fbd', true)) {
        EVP.open = true; SFX.ui(); IN.pressed = false;
      } else if (!ustTasin) {
        txt(T('zorunlu'), x + pw - 66, ry, '#9a9282', { align: 'r' });
      }
    } else if (g.zorunlu) {
      txt(T('zorunlu'), x + pw - 66, ry, '#9a9282', { align: 'r' });
    }
    txt('-$' + fmtMoney(g.tutar), x + pw - 14, ry, acik ? '#a83a2a' : '#9a9282', { align: 'r' });
    if (ust && IN.pressed) { HS.sec[g.id] = !acik; SFX.ui(); IN.pressed = false; }
    ry += 13;
  }

  ctx.globalAlpha = .45; hl(x + 12, ry, pw - 24, '#8a8370'); ctx.globalAlpha = 1;
  ry += 5;
  /* Kapandiysa donmus rakamlar; degilse anlik projeksiyon. */
  var once = HS.kapandi ? HS.oncekiKasa : (G.fpara || 0);
  var kalan = HS.kapandi ? HS.sonKasa : hesapKalan(HS);
  txt(T('KASA'), x + 14, ry, '#2a2620');
  txt((once < 0 ? '-$' : '$') + fmtMoney(Math.abs(once)) + '  >', x + pw - 76, ry,
      '#7a7360', { align: 'r' });
  txt((kalan < 0 ? '-$' : '$') + fmtMoney(Math.abs(kalan)), x + pw - 14, ry,
      kalan < 0 ? '#c8321e' : '#2f6a3a', { align: 'r' });

  var hy = ry + 14;
  haneCiz(x + 14, hy, t);

  if (!HS.kapandi) {
    if (button(x + pw - 86, hy - 2, 72, 17, T('GÜNÜ KAPAT'), '#8e2318', true)) {
      SFX.ui(); hesapKapat();
    }
  } else {
    var oy = hy + 16;
    for (var o = 0; o < (HS.olay || []).length && o < 3; o++) {
      var ol = HS.olay[o];
      var rnk = ol.tip === 'iyi' ? '#2f6a3a' : (ol.tip === 'kotu' ? '#c8321e' : '#a86a20');
      /* Birlestirilmis metin: her parca AYRI cevrilmeli. */
      txt('- ' + (ol.ad ? T(ol.ad) : '') + T(ol.ek), x + 14, oy, rnk);
      oy += 10;
    }
    var bitti = fermanBitti();
    /* Tahliye olmadan da EVE DONEBILMELI: bu modda dukkan ekranina
       gidilmedigi icin sube paneli hic acilmiyor, cikis yolu kalmiyordu.
       Donunce kasa/hane/gun sayaci korunur, geri gelince kaldigi yerden. */
    if (!bitti && button(x + 14, y + ph - 22, 78, 17, T('EVE DÖN'), '#6a4a2a', true)) {
      SFX.ui(); G.hesap = null;
      G.day++; sehreGit(-1);
      G.scene = 'shop'; G.sceneT = 0; SHOP.bake = null; saveAll();
    }
    if (button(x + pw - 94, y + ph - 22, 80, 17,
               bitti ? T('EVE DÖN') : T('ERTESİ GÜN'),
               bitti ? '#6a4a2a' : '#3f8a4a', true)) {
      SFX.ui();
      G.hesap = null;
      if (bitti) {
        /* tahliye: mod sifirlanir, bastan baslanabilir */
        fermanEkonomiKur(true);
        G.day++; sehreGit(-1);
        G.scene = 'shop'; G.sceneT = 0; SHOP.bake = null; saveAll();
      } else {
        G.day++; rollNight();
        G.scene = G.night ? 'night' : 'intro'; G.sceneT = 0;
        saveAll();
      }
    }
  }
  psDraw(); ftDraw();
  if (G.tutanak) drawTutanak(t);
}

/* ---------------- TASINMA PANELI ----------------
   Kademe kademe yukselmek modun uzun vadeli hedefi. Ust daire pahali kira
   ister ama isinmayi ucuzlatir ve hastalanma riskini dusurur; oyuncu
   'simdi mi tasinayim yoksa biraz daha biriktireyim mi' der. */
var EVP = { open: false };
function drawEvPaneli(t) {
  var pw = 292, satirH = 24;
  var ph = 34 + EVLER.length * satirH + 26;
  var kk = panelKutu(0, ph); ph = kk[1];
  var x = Math.round(W / 2 - pw / 2), y = kk[0];

  ctx.globalAlpha = .70; fr(0, 0, W, H, '#0b0a09'); ctx.globalAlpha = 1;
  ctx.globalAlpha = .45; fr(x + 4, y + 5, pw, ph, '#000'); ctx.globalAlpha = 1;
  fr(x, y, pw, ph, '#b9b096');
  fr(x + 1, y + 1, pw - 2, ph - 2, '#e8e0c6');
  hl(x + 1, y + 1, pw - 2, '#f6efd8');
  fr(x, y, pw, 3, '#3f6fbd');

  txt(T('KONUT DAİRESİ'), x + pw / 2, y + 8, '#2a2620', { align: 'c' });
  txt(T('Kasa: $') + fmtMoney(G.fpara || 0), x + pw - 14, y + 20, '#7a7360', { align: 'r' });
  txt(T('Yükseldikçe yalıtım iyi, hastalık az.'), x + 14, y + 20, '#8a8370');

  for (var i = 0; i < EVLER.length; i++) {
    var e = EVLER[i], ry = y + 32 + i * satirH;
    var simdi = (G.ev || 0) === i, gecmis = i < (G.ev || 0);
    var sonraki = i === (G.ev || 0) + 1;
    var alinir = sonraki && (G.fpara || 0) >= e.pesinat;

    var zemin = simdi ? '#d8e2c8' : (gecmis ? '#ddd6c0' : '#e8e0c6');
    fr(x + 10, ry - 2, pw - 20, satirH - 3, zemin);
    rc(x + 10, ry - 2, pw - 20, satirH - 3, simdi ? '#3f8a4a' : '#c2baa2');
    /* kademe cubugu: kacinci kat */
    for (var b = 0; b <= i; b++) fr(x + 13, ry + 11 - b * 2, 3, 1, simdi ? '#3f8a4a' : '#8a8370');

    txt(T(e.ad), x + 22, ry, simdi ? '#25301f' : (gecmis ? '#9a9282' : '#3a3630'));
    txt(T('kira $') + fmtMoney(e.kira), x + 22, ry + 10, '#7a7360');

    if (simdi) {
      txt(T('OTURUYORSUN'), x + pw - 18, ry + 4, '#2f6a3a', { align: 'r' });
    } else if (gecmis) {
      txt(T('geride kaldı'), x + pw - 18, ry + 4, '#9a9282', { align: 'r' });
    } else if (sonraki) {
      txt(T('peşinat $') + fmtMoney(e.pesinat), x + pw - 74, ry + 4, alinir ? '#3a3630' : '#a83a2a', { align: 'r' });
      if (button(x + pw - 66, ry + 1, 52, 15, T('TAŞIN'), alinir ? '#3f8a4a' : '#6a6455', alinir)) {
        if (eveTasin(i)) {
          ftext(T('YENİ EV: ') + T(e.ad), W / 2, 96, P.au0, { life: 2, sc: 1 });
          flash(.22, '#ffe9a0');
          EVP.open = false;
          if (G.hesap && !G.hesap.kapandi) G.hesap = hesapKur();   /* kira guncellensin */
        }
      }
    } else {
      txt(T('sırası gelmedi'), x + pw - 18, ry + 4, '#b0a894', { align: 'r' });
    }
  }

  if (button(x + pw / 2 - 34, y + ph - 20, 68, 16, T('KAPAT'), '#8a4a4a', true)) {
    EVP.open = false; SFX.uiBack();
  }
}

/* Hane halki: her uye kucuk bir yuz. Ac = cokuk yanak, hasta = soluk ten +
   ter, el konulmus = bos cerceve. Yazi yok; durum yuzden okunur. */
function haneCiz(x, y, t) {
  var h = G.hane || [];
  for (var i = 0; i < h.length; i++) {
    var u = h[i], ux = x + i * 13;
    if (u.gitti) {
      ctx.globalAlpha = .35;
      rc(ux, y, 10, 10, '#8a8370');
      fr(ux + 2, y + 4, 6, 1, '#8a8370');
      ctx.globalAlpha = 1;
      continue;
    }
    var ten = u.hasta > 0 ? '#c8bfa8' : (u.ac > 0 ? '#d6b48a' : '#e0b98c');
    fr(ux, y, 10, 10, ten);
    fr(ux, y, 10, 1, shadeCol(ten, 1.12));
    var gy = y + 4;
    if (u.hasta > 0) { fr(ux + 2, gy, 2, 1, '#6a5a4a'); fr(ux + 6, gy, 2, 1, '#6a5a4a'); }
    else { px(ux + 2, gy, '#3a2e24'); px(ux + 7, gy, '#3a2e24'); }
    if (u.hasta > 0) fr(ux + 3, y + 7, 4, 1, '#8a4a3a');
    else if (u.ac > 0) {
      fr(ux + 3, y + 8, 4, 1, '#8a6a4a');
      px(ux + 2, y + 7, '#8a6a4a'); px(ux + 7, y + 7, '#8a6a4a');
    } else {
      fr(ux + 3, y + 7, 4, 1, '#8a6a4a');
      px(ux + 2, y + 6, '#8a6a4a'); px(ux + 7, y + 6, '#8a6a4a');
    }
    if (u.hasta > 0) { ctx.globalAlpha = .7; px(ux + 4, y + 1, '#8fc4e0'); ctx.globalAlpha = 1; }
    if (u.ac > 0) {
      ctx.globalAlpha = .35;
      fr(ux + 1, y + 5, 1, 2, '#8a6a4a'); fr(ux + 8, y + 5, 1, 2, '#8a6a4a');
      ctx.globalAlpha = 1;
    }
  }
}

/* ---------------- DEMIRKENT: gun sonu ihlal tutanagi ----------------
   Ihlaller TEK TEK dokulur (her biri ~0.55 sn arayla, damga sesiyle).
   Ozet ekraninin ustunde durur; kapatilmadan ozete gecilemez. */
function drawTutanak(t) {
  var TU = G.tutanak;
  TU.t += 1 / 60;
  var n = TU.kayit.length;
  var gorunen = clamp(Math.floor((TU.t - .55) / .55), 0, n);
  if (gorunen > (TU.sayilan || 0)) {
    TU.sayilan = gorunen;
    SFX.bad(); shake(.12, 1);
  }
  var a = clamp(TU.t * 2.4, 0, 1);
  ctx.globalAlpha = .74 * a; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;

  /* kagit: satir sayisina gore uzar, en fazla 10 satir */
  var satirH = 11;
  var pw = 292, ph = 40 + n * satirH + 34;
  var kk2 = panelKutu(0, ph); ph = kk2[1];
  var px2 = Math.round(W / 2 - pw / 2);
  var py2 = Math.round(lerp(-ph, kk2[0], easeOutBack(a)));

  ctx.globalAlpha = .45; fr(px2 + 4, py2 + 5, pw, ph, '#000'); ctx.globalAlpha = 1;
  fr(px2, py2, pw, ph, '#c0b89e');
  fr(px2 + 1, py2 + 1, pw - 2, ph - 2, '#ece5cf');
  hl(px2 + 1, py2 + 1, pw - 2, '#f8f2dd');
  fr(px2, py2, pw, 3, '#8e1c14');                 /* rejim seridi */

  txt(T('İHLAL TUTANAĞI'), px2 + pw / 2, py2 + 8, '#8e1c14', { align: 'c' });
  ctx.globalAlpha = .45; hl(px2 + 12, py2 + 20, pw - 24, '#8a8370'); ctx.globalAlpha = 1;

  for (var i = 0; i < gorunen; i++) {
    var k = TU.kayit[i], ry = py2 + 26 + i * satirH;
    /* satir kendi icinde kayarak gelir */
    var ka = clamp((TU.t - .55 - i * .55) * 5, 0, 1);
    ctx.globalAlpha = ka;
    var rx = px2 + 14 + Math.round((1 - ka) * 10);
    fr(rx - 4, ry + 1, 2, 7, '#b83228');
    /* Nerede yakalandigi YAZIYLA yazilinca ferman metniyle cakisiyordu.
       Kucuk bir ikon: cam kanadi = camdan goruldu, sokak lambasi = sokakta. */
    tutanakIkon(rx + 1, ry, k.nerede);
    txt(T(k.metin), rx + 12, ry, '#3a3630');
    txt('-$' + fmtMoney(k.para), px2 + pw - 14, ry, '#a83a2a', { align: 'r' });
    ctx.globalAlpha = 1;
  }

  var ay2 = py2 + ph - 26;
  if (gorunen >= n) {
    ctx.globalAlpha = .45; hl(px2 + 12, ay2 - 6, pw - 24, '#8a8370'); ctx.globalAlpha = 1;
    txt(T('Toplam ceza: $') + fmtMoney(n * FERMAN_CEZA_PARA), px2 + 14, ay2 - 2, '#a83a2a');
    if (button(px2 + pw - 84, ay2 - 4, 70, 16, T('İMZALA'), '#8e2318', true)) {
      SFX.ui(); G.tutanak = null;
    }
  }
}
/* Tutanak satirindaki yakalanma yeri ikonu (8x8). */
function tutanakIkon(x, y, nerede) {
  if (nerede === 'telefon') {
    /* ahize: cevapsiz cagri */
    fr(x, y + 1, 8, 2, '#6a6455');
    fr(x, y + 3, 2, 2, '#6a6455');
    fr(x + 6, y + 3, 2, 2, '#6a6455');
    fr(x + 1, y + 6, 6, 1, '#8a8370');
    return;
  }
  if (nerede === 'sokak') {
    /* sokak lambasi: direk + basi */
    fr(x + 3, y + 2, 1, 6, '#6a6455');
    fr(x + 1, y, 5, 3, '#8a8370');
    fr(x + 2, y + 1, 3, 1, '#d8c88a');
  } else {
    /* cam kanadi: cerceve + hac bolme */
    rc(x, y, 8, 8, '#6a6455');
    fr(x + 1, y + 1, 6, 6, '#b8cdd8');
    fr(x + 3, y + 1, 1, 6, '#6a6455');
    fr(x + 1, y + 3, 6, 1, '#6a6455');
  }
}

/* ---------------- BORÇ BİTTİ kutlaması ---------------- */
function drawDebtFree(t) {
  var C = G.celeb;
  C.t += 1 / 60;
  if (C.t < .05) { SFX.fanfare(); flash(.5, '#ffe9a0'); shake(4); }
  ctx.globalAlpha = .72; fr(0, 0, W, H, '#140a06'); ctx.globalAlpha = 1;

  /* konfeti */
  if (C.t < 4.5 && chance(.75)) {
    part({
      x: rnd(0, W), y: -4, vx: rnd(-26, 26), vy: rnd(24, 70),
      life: 3.4, col: pick([P.au0, P.au1, '#e2483a', '#3f8a4a', '#3f6fbd', '#ffffff']),
      g: 26, sz: 2, drag: .3
    });
  }

  var k = clamp(C.t * 1.6, 0, 1);
  var yy = lerp(-70, 54, easeOutBack(k));
  var bw = 300, bx = W / 2 - bw / 2;
  ctx.globalAlpha = .4; rrect(bx + 3, yy + 4, bw, 116, 5, '#000'); ctx.globalAlpha = 1;
  rrect(bx, yy, bw, 116, 5, '#8e1c14');
  rrect(bx + 2, yy + 2, bw - 4, 112, 4, P.ui0);
  rrectOut(bx, yy, bw, 116, 5, P.au2);
  /* parlayan çerçeve */
  ctx.globalAlpha = .35 + .3 * Math.sin(t * 5);
  rrectOut(bx - 2, yy - 2, bw + 4, 120, 6, P.au0);
  ctx.globalAlpha = 1;

  txt('BORÇ BİTTİ!', W / 2, yy + 12, P.red1, { align: 'c', sc: 2, shadow: 1 });
  if (C.t > .5) txt('Babanın borcunu son kuruşuna kadar ödedin.', W / 2, yy + 40, P.ink, { align: 'c' });
  if (C.t > .9) txt('Dükkân artık tamamen senin.', W / 2, yy + 52, P.ink, { align: 'c' });
  if (C.t > 1.3) {
    txt('$' + fmtMoney(DEBT_START), W / 2, yy + 66, P.ok, { align: 'c', sc: 1 });
    txt('ödendi', W / 2, yy + 80, P.ui3, { align: 'c' });
  }
  /* babanın çerçeveli fotoğrafı */
  if (C.t > 1.7) {
    var px2 = W / 2 - 128, py2 = yy + 34;
    rrect(px2, py2, 34, 40, 2, '#6d4a22');
    rrect(px2 + 2, py2 + 2, 30, 36, 2, '#c9a06a');
    rrect(px2 + 3, py2 + 3, 28, 28, 1, '#8aa8b8');
    var fx2 = px2 + 17, fy2 = py2 + 20;
    ell(fx2, fy2, 7, 8, '#f0bd8a');
    fr(fx2 - 8, fy2 + 6, 16, 8, '#c33c2c');
    fr(fx2 - 6, fy2 - 9, 13, 6, P.red2);
    fr(fx2 - 5, fy2 - 9, 11, 5, P.red1);
    fr(fx2 - 5, fy2 + 2, 11, 2, '#efefe9');
    fr(fx2 - 4, fy2 - 2, 3, 2, '#2b2018'); fr(fx2 + 2, fy2 - 2, 3, 2, '#2b2018');
    txt('BABA', px2 + 17, py2 + 32, '#5a3a1e', { align: 'c' });
    /* ışıltı */
    if (chance(.10)) part({ x: px2 + rnd(0, 34), y: py2 + rnd(0, 40), vx: rnd(-8, 8), vy: rnd(-18, -6), life: .8, col: P.au0, g: -6, sz: 1, type: 'star' });
  }
  if (C.t > 2.4 && button(W / 2 - 52, yy + 92, 104, 18, 'DEVAM ET', '#3f8a4a', true)) {
    G.celeb = null; SFX.ui();
  }
  psDraw(); ftDraw();
}

/* ---------------- dükkân (geliştirme) ---------------- */
/* sec: dukkan ekraninda secili upgrade id'si (detay karti onu gosterir) */
var SHOP = { bake: null, sel: null, buyT: 0, sec: null };
function drawShopStatic(t, mono) {
  if (bgBayat()) bakeBG(UV(G, 'paint'));
  ctx.drawImage(BG, 0, 0);
  drawWallDecor(t);
  /* Dayı yalnız upgrade alındıysa dükkânda; başlık ekranında ise
     her zaman (orada dükkânın tanıtım görüntüsü var). Taş duvarın
     yeri de aynı koşula bağlı, ikisi birlikte hareket eder. */
  if (dayiVar()) drawChef(LAY.chef.x, LAY.chef.y, { mode: 'idle', armT: 0 }, t);
  drawCounter();
  drawCounterProps(t);
  drawSpit({ rot: t, roast: .85, mass: 1, sliceT: 0, cutDepth: 0 }, t);
  drawMeatTray(ST.meat.x, ST.meat.y, ST.meat.w, ST.meat.h, 3, t);
  drawPickleTray(ST.pickle.x, ST.pickle.y, ST.pickle.w, ST.pickle.h, 12, 16, t);
  drawYogurtTray(ST.yogurt.x, ST.yogurt.y, ST.yogurt.w, ST.yogurt.h, 12, 16, t);
  drawFriesTray(ST.friesT.x, ST.friesT.y, ST.friesT.w, ST.friesT.h, 4, 16, t);
  if (TUN.garnishOn(G)) drawGarnishTray(ST.garnish.x, ST.garnish.y, ST.garnish.w, ST.garnish.h, TUN.garnishMax(G), TUN.garnishMax(G), TUN.garnishMax(G), t, 0);
  else lockedStation(ST.garnish, 'GARNİTÜR', t);
  if (TUN.drinkOn(G)) drawDrinkMachine(ST.drinkM.x, ST.drinkM.y, ST.drinkM.w, 32, { pour: -1 }, t);
  else lockedStation(ST.drinkM, 'İÇECEK', t);
  drawFryer(ST.fryer.x, ST.fryer.y, ST.fryer.w, ST.fryer.h, { state: 'idle', t: 0, dur: 0, load: 0, basketY: -5 }, t);
  drawPotatoBin(ST.potato.x, ST.potato.y, ST.potato.w, ST.potato.h, t);
  drawCrate(ST.crate.x, ST.crate.y, ST.crate.w, ST.crate.h, false, t);
  if (TUN.iskOn(G)) {
    drawPideStack(ST.bread.x, ST.bread.y, ST.bread.w);
    ctx.save(); ctx.translate(0, 12);
    drawBreadStack(ST.bread.x, ST.bread.y, ST.bread.w, ST.bread.h, '');
    ctx.restore();
  } else drawBreadStack(ST.bread.x, ST.bread.y, ST.bread.w, ST.bread.h);
  rrect(ST.board.x + 2, ST.board.y + 8, ST.board.w - 4, 34, 3, '#7a5230');
  rrect(ST.board.x + 2, ST.board.y + 7, ST.board.w - 4, 34, 3, '#c49a68');
  rrect(ST.board.x + 4, ST.board.y + 9, ST.board.w - 8, 30, 2, '#dcb480');
  drawPaperStation(ST.paper.x, ST.paper.y, ST.paper.w, ST.paper.h, UV(G, 'paper'), 0, t);
  if (TUN.grillOn(G)) drawGrill(ST.grill.x, ST.grill.y, ST.grill.w, ST.grill.h, { slots: [] }, t, TUN.grillCap(G));
  else lockedStation(ST.grill, 'IZGARA', t);
  drawCutBoard(ST.cut.x, ST.cut.y, ST.cut.w, ST.cut.h, { potato: false, prog: 0, raw: 2, cutting: false }, t);
  if (TUN.fboxOn(G)) drawFboxStation(ST.fbox.x, ST.fbox.y, ST.fbox.w, ST.fbox.h, 1, t);
  else lockedStation(ST.fbox, 'KUTU', t);
  if (TUN.ayranOn(G)) drawAyranTank(ST.ayran.x, ST.ayran.y, ST.ayran.w, ST.ayran.h, TUN.ayranMax(G), TUN.ayranMax(G), { pour: false }, t);
  else lockedStation(ST.ayran, 'AYRAN', t);
  if (TUN.sweetOn(G)) drawSweetTray(ST.sweet.x, ST.sweet.y, ST.sweet.w, ST.sweet.h, TUN.sweetMax(G), TUN.sweetMax(G), t, 0);
  else lockedStation(ST.sweet, 'TATLI', t);
  if (TUN.sauceOn(G) || TUN.iskOn(G)) drawSauceStation(ST.sauce.x, ST.sauce.y, ST.sauce.w, ST.sauce.h, TUN.sauceOn(G), TUN.iskOn(G), null, t);
  else lockedStation(ST.sauce, 'SOS', t);
  if (TUN.secLevel(G) >= 3) drawWallCam(t, false);
  drawTrash(ST.trash.x, ST.trash.y, ST.trash.w, ST.trash.h, t, 0);
}
function bakeShop() {
  var c = document.createElement('canvas'); c.width = W; c.height = H;
  var g = c.getContext('2d'); g.imageSmoothingEnabled = false;
  var old = ctx; ctx = g;
  g.fillStyle = '#000'; g.fillRect(0, 0, W, H);
  drawShopStatic(0, true);
  ctx = old;
  var img = g.getImageData(0, 0, W, H), p = img.data;
  for (var i = 0; i < p.length; i += 4) {
    var v = (p[i] * .32 + p[i + 1] * .55 + p[i + 2] * .13);
    v = v * .80 + 44;
    p[i] = v; p[i + 1] = v; p[i + 2] = v * 1.02;
  }
  g.putImageData(img, 0, 0);
  SHOP.bake = c;
}
function upgLevel(id) { return G.up[id] || 0; }
function upgPrice(u) { var l = upgLevel(u.id); return l >= u.lv.length ? null : Math.round(u.lv[l].p); }
/* --- DUKKAN KARTI METIN RENKLERI ---
   Kart zemini KOYU (#2b2119). Buradaki renkler o zemine gore secildi;
   acik panellerin P.ui4 gibi koyu metin renkleri burada okunmuyor
   (olculen kontrast 1.39). Regresyon bu degerleri kilitliyor. */
var KART_ZEMIN = '#2b2119';
var KART_YAZI = '#c9b48c';   /* kontrast 7.79 */
var KART_TAM = '#8fb88f';    /* kontrast 7.06 */
var KART_KILIT = '#d9977a';  /* kontrast 6.60 */
var KART_PAHALI = '#e0a0a0'; /* kontrast 7.31 */

function drawShop(t) {
  if (!SHOP.bake) bakeShop();
  ctx.drawImage(SHOP.bake, 0, 0);
  /* 1. gun bitti, dukkan ilk kez aciliyor: kisa tanitim + hediye DEPO. */
  if (!G.dersGorulmus && !G.ders && G.day <= 2 && !CUSTOM.open && !STATS.open && !BSP.open &&
      !SESP.open && !BRP.open && !PAYP.open) {
    G.ders = { adim: 0, t: 0, verildi: false };
  }
  if (CUSTOM.open) { drawCustomPanel(t); return; }
  if (BSP.open) { drawBasarimPanel(t); return; }
  if (STATS.open) { drawStatsPanel(t); return; }
  if (SESP.open) { drawSesPanel(t); return; }
  if (BRP.open) { drawBranchPanel(t); return; }
  if (PAYP.open) { drawPayPanel(t); return; }
  ctx.globalAlpha = .12; fr(0, 0, W, H, '#3a4a6a'); ctx.globalAlpha = 1;
  /* Ders acikken etiketler cizilir ama TIKLANMAZ: oyuncu once anlatimi bitirir. */
  var dersAcik = !!G.ders;
  /* Test surumu DEV dugmesi: dukkan ekraninda da calissin. */
  if (IN.pressed && typeof devDugmeTik === 'function' && devDugmeTik(IN.x, IN.y)) {
    IN.pressed = false;
  }

  /* --- ROZETLER ---
     Her upgrade kendi istasyonunun kosesinde kucuk bir rozet. Ok ve fiyat
     etiketi yok; ayrinti tek bir kartta gosteriliyor. */
  var barAltR = VIEW.top > 0;
  var ubR = barAltR ? (H - VIEW.bot - 25) : VIEW.top;
  var guvenliUst = barAltR ? (VIEW.top + 9) : (ubR + 25 + 9);
  var guvenliAlt = barAltR ? (ubR - 9) : (H - VIEW.bot - 9);

  var rozetler = [];
  for (var i = 0; i < UPG.length; i++) {
    var yer = upgRozetYeri(UPG[i]);
    rozetler.push({ u: UPG[i], x: yer[0], y: yer[1] });
  }

  var hoverU = null, hazir = 0;
  for (var r = 0; r < rozetler.length; r++) {
    var R = rozetler[r], uu = R.u;
    var lvl0 = upgLevel(uu.id), fiyat = upgPrice(uu);
    var tam = fiyat === null;
    var kilit = !!(uu.gerek && (G.up[uu.gerek] || 0) === 0);
    var alinir = !tam && !kilit && G.money >= fiyat;
    if (alinir) hazir++;
    var ust0 = inRect(IN.x, IN.y, R.x - 9, R.y - 9, 18, 18);
    if (ust0) hoverU = uu;
    var secili = SHOP.sec === uu.id;
    rozetCiz(R.x, R.y, { tam: tam, kilit: kilit, alinir: alinir,
                         vurgu: ust0 || secili, t: t });
    if (ust0 && IN.pressed && !dersAcik) {
      SHOP.sec = (SHOP.sec === uu.id) ? null : uu.id;
      SFX.ui(); IN.pressed = false;
    }
  }

  /* --- DETAY KARTI: ustune gelinen ya da secilen tek upgrade --- */
  var kartU = hoverU || (SHOP.sec ? upgById(SHOP.sec) : null);
  var kart = null;
  if (kartU && !dersAcik) {
    var kl = upgLevel(kartU.id), kf = upgPrice(kartU);
    var kTam = kf === null;
    var kKilit = !!(kartU.gerek && (G.up[kartU.gerek] || 0) === 0);
    var kAlinir = !kTam && !kKilit && G.money >= kf;
    var kw = 240, kh = 54;
    var kx = Math.round(W / 2 - kw / 2);
    var ky = barAltR ? (ubR - kh - 6) : (H - VIEW.bot - kh - 8);
    kart = { x: kx, y: ky, w: kw, h: kh, u: kartU, lvl: kl, fiyat: kf,
             tam: kTam, kilit: kKilit, alinir: kAlinir };

    ctx.globalAlpha = .42; rrect(kx + 2, ky + 3, kw, kh, 4, '#000'); ctx.globalAlpha = 1;
    rrect(kx, ky, kw, kh, 4, '#1d1611');
    rrect(kx, ky, kw, kh - 2, 4, '#2b2119');
    hl(kx + 4, ky + 1, kw - 8, '#4a3a2c');
    rrectOut(kx, ky, kw, kh, 4, kAlinir ? P.au2 : '#4a3f36');
    /* sol seritte istasyon ikonu yerine renk kodu */
    fr(kx, ky + 4, 3, kh - 8, kTam ? '#3f8a4a' : (kKilit ? '#6a5a4a' : (kAlinir ? P.au0 : '#7a4a4a')));

    txt(T(kartU.name), kx + 10, ky + 7, P.au0);
    /* seviye noktalari */
    var pn = kartU.lv.length;
    for (var q = 0; q < pn; q++) {
      var px0 = kx + kw - 10 - (pn - 1 - q) * 7;
      if (q < kl) { rrect(px0 - 3, ky + 7, 5, 6, 1, P.ok); }
      else { rrect(px0 - 3, ky + 7, 5, 6, 1, '#463a30'); }
    }
    /* Kart zemini KOYU (#2b2119). P.ui4 acik panellerin metin rengi;
       burada kontrasti 1.39 idi, yazi hic okunmuyordu. */
    txt(T(kartU.desc), kx + 10, ky + 19, KART_YAZI);

    /* sonraki seviyenin adi */
    if (!kTam && kartU.lvName && kartU.lvName[kl]) {
      /* Onek isareti yok: U+203A fontta olmadigi icin '?' ciziyordu. */
      txt(T(kartU.lvName[kl]), kx + 10, ky + 31, KART_YAZI);
    } else if (kTam) {
      txt(T('En üst seviye'), kx + 10, ky + 31, KART_TAM);
    }

    /* fiyat + dugme */
    if (kKilit) {
      txt(T(upgById(kartU.gerek).name) + T(' gerekli'), kx + 10, ky + 42, KART_KILIT);
    } else if (!kTam) {
      txt('$' + fmtMoney(kf), kx + 10, ky + 42, kAlinir ? P.au0 : KART_PAHALI, { sc: 1 });
      if (button(kx + kw - 74, ky + kh - 19, 66, 15, T('SATIN AL'),
                 kAlinir ? '#3f8a4a' : '#5a4038', kAlinir)) {
        G.money -= kf; G.up[kartU.id] = kl + 1;
        SFX.cash(); SHOP.buyT = 1; SHOP.bake = null;
        var alinanRozet = null;
        for (var z = 0; z < rozetler.length; z++)
          if (rozetler[z].u.id === kartU.id) alinanRozet = rozetler[z];
        if (alinanRozet) {
          burst(alinanRozet.x, alinanRozet.y, 16, [P.au0, P.au1, '#fff'],
                { spMax: 80, type: 'star', sz: 2 });
          ftext(T(kartU.name) + ' ' + (kl + 1), alinanRozet.x, alinanRozet.y - 14,
                P.au0, { life: 1.4 });
        }
        flash(.2, '#ffe9a0');
        G.best = Math.max(G.best, G.day); saveAll();
      }
    }
  }

  /* Bar konumu: gorunum kirpilmissa (mobil) EKRANIN ALTINA gecer.
     Ust bant kirpilinca bar dunya kordinatinda 34..58'e oturuyor ve
     y=40..62 arasindaki upgrade etiketlerini tamamen ortuyordu. Dukkan
     ekraninin alt bandinda etiket yok (en alttaki 152), cakisma biter.
     Cizim ve tiklama kutulari AYNI ofseti kullanmali. */
  var barAlt = VIEW.top > 0;
  var ub = barAlt ? (H - VIEW.bot - 25) : VIEW.top;
  var Wr2 = W - VIEW.right;
  ctx.globalAlpha = .8; fr(0, ub, Wr2, 25, '#1a120e'); ctx.globalAlpha = 1;
  hl(0, barAlt ? ub : ub + 25, Wr2, P.ui4);
  /* para: en önemli sayı, sol başta */
  var ms = '$' + (G.money >= 1000000 ? fmtShort(G.money) : fmtMoney(G.money));
  icon('coin', 14, ub + 12, t);
  txt(ms, 24, ub + 8, P.au0, { sc: 1 });
  if (G.debt > 0 && button(104, ub + 4, 56, 17, 'BORÇ ÖDE', '#a83a2a', G.money >= 100)) { PAYP.open = true; SFX.ui(); }
  var subeVar = (G.branch || 0) < BRANCH.length && !branchLocked(G.branch || 0, G) && G.money >= BRANCH[G.branch || 0].p;
  if (button(164, ub + 4, 54, 17, 'ŞUBELER', '#b0862a', subeVar)) { BRP.open = true; SFX.ui(); }
  if (subeVar) {
    /* alınabilir şube var: dikkat çeken rozet */
    var pz = .5 + .5 * Math.sin(t * 6);
    ctx.globalAlpha = .45 + .35 * pz; disc(216, ub + 5, 4 + pz, '#ffd75e'); ctx.globalAlpha = 1;
    disc(216, ub + 5, 3, '#c8321e');
    txt('!', 216, ub + 2, '#ffffff', { align: 'c' });
  }
  if (button(222, ub + 4, 84, 17, 'KİŞİSELLEŞTİR', '#7a5aa0')) { CUSTOM.open = true; SFX.ui(); }
  if (button(310, ub + 4, 60, 17, 'REKORLAR', '#3f6fbd')) { STATS.open = true; SFX.ui(); }
  /* Kac gelistirme su an alinabilir: oyuncu rozetleri taramak zorunda
     kalmasin. Sifirsa hic cizilmez. */
  if (hazir > 0) {
    var hx = Wr2 - 84, hy2 = ub + 7;
    var hpz = .5 + .5 * Math.sin(t * 4);
    ctx.globalAlpha = .20 + .18 * hpz; disc(hx + 5, hy2 + 4, 8, P.au0); ctx.globalAlpha = 1;
    rrect(hx, hy2 - 1, 10, 11, 2, '#4a3812');
    rrectOut(hx, hy2 - 1, 10, 11, 2, P.au0);
    fr(hx + 2, hy2 + 3, 6, 2, '#ffe9a0'); fr(hx + 4, hy2 + 1, 2, 6, '#ffe9a0');
    txt(String(hazir), hx + 14, hy2 + 1, P.au0);
  }
  if (button(Wr2 - 58, ub + 4, 54, 17, T('GÜN ') + (G.day + 1), '#3f8a4a', true)) {
    SFX.bell(); G.day++;
    rollNight();
    G.scene = G.night ? 'night' : 'intro'; G.sceneT = 0;
    G.best = Math.max(G.best, G.day); saveAll();
  }

  /* Eski imlec ipucu paneli kaldirildi: bilgiyi artik alttaki tek detay
     karti veriyor, iki kutu ayni anda ekranda durmasin. */
  if (dersAcik) drawDers(t);
  psDraw(); ftDraw();
}

/* ---------------- 1. gun sonu: dukkan tanitimi ----------------
   Uc adim. Son adimda DEPO hediye edilir: oyuncu ilk gunun sonunda
   eli bos kalmasin, gelisme hattini hemen gorsun. */
var DERS_ADIM = [
  { hedef: null, bas: 'BURASI DÜKKÂN',
    sat: ['Gün bitince buraya gelirsin.',
          'Kazandığın parayla dükkânı büyütürsün.'] },
  { hedef: 'tongs', bas: 'GELİŞTİRME ETİKETLERİ',
    sat: ['Her etiket bir istasyona ok atar.',
          'Üstündeki fiyat, altındaki noktalar seviyedir.'] },
  { hedef: 'store', bas: 'İLK GELİŞTİRME BİZDEN',
    sat: ['DEPO: turşu ve yoğurt stokun büyür.',
          'Hediyemiz olsun — hadi devam.'] }
];
function dersHedefEtiket(id) {
  for (var i = 0; i < UPG.length; i++) if (UPG[i].id === id) return UPG[i];
  return null;
}
function drawDers(t) {
  var D = G.ders;
  D.t += 1 / 60;
  var A = DERS_ADIM[D.adim];
  var hedef = A.hedef ? dersHedefEtiket(A.hedef) : null;

  /* --- karartma: hedef etiketin etrafi acik kalir --- */
  ctx.globalAlpha = .62; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  if (hedef) {
    var yerH = upgRozetYeri(hedef), hx = yerH[0], hy = yerH[1];
    /* isik halkasi: karartmayi delmek yerine uzerine parlak halka */
    var pz = .5 + .5 * Math.sin(t * 5);
    ctx.globalAlpha = .20 + .16 * pz; disc(hx, hy, 22 + pz * 3, '#ffe9a0'); ctx.globalAlpha = 1;
    ctx.globalAlpha = .55 + .35 * pz;
    ring(hx, hy, 15, '#ffd75e'); ring(hx, hy, 16, '#ffd75e');
    ctx.globalAlpha = 1;
    /* etiketi karartmanin ustunde tekrar ciz ki okunsun */
    var lv0 = upgLevel(hedef.id), pr0 = upgPrice(hedef);
    var lb0 = pr0 === null ? 'TAM' : '$' + fmtShort(pr0);
    var lw0 = textW(lb0) + 12;
    rrect(hx - lw0 / 2, hy - 6, lw0, 13, 3, '#1a4a8a');
    rrect(hx - lw0 / 2, hy - 6, lw0, 11, 3, '#2f6fbd');
    rrectOut(hx - lw0 / 2, hy - 6, lw0, 13, 3, P.au0);
    txt(lb0, hx, hy - 3, P.au0, { align: 'c', shadow: 1 });
    for (var l0 = 0; l0 < hedef.lv.length; l0++)
      disc(hx - (hedef.lv.length - 1) * 2 + l0 * 4, hy + 9, 1, l0 < lv0 ? P.ok : 'rgba(0,0,0,.4)');
  }

  /* --- anlatim panosu: hedefin ters tarafinda dursun --- */
  var pw = 200, ph = 58;
  var pxx = Math.round(W / 2 - pw / 2);
  var alta = !hedef || upgRozetYeri(hedef)[1] < H / 2;
  var pyy = alta ? H - ph - 26 : 30;
  pyy = clamp(pyy, VIEW.top + 6, H - VIEW.bot - ph - 24);
  ctx.globalAlpha = .40; rrect(pxx + 2, pyy + 3, pw, ph, 4, '#000'); ctx.globalAlpha = 1;
  rrect(pxx, pyy, pw, ph, 4, P.ui0);
  rrectOut(pxx, pyy, pw, ph, 4, P.au2);
  fr(pxx + 4, pyy + 4, pw - 8, 1, P.au2);
  txt(T(A.bas), pxx + pw / 2, pyy + 8, P.red1, { align: 'c' });
  for (var i = 0; i < A.sat.length; i++)
    txt(T(A.sat[i]), pxx + pw / 2, pyy + 22 + i * 10, P.ui4, { align: 'c' });

  /* adim noktalari */
  for (var s0 = 0; s0 < DERS_ADIM.length; s0++)
    disc(pxx + pw / 2 - (DERS_ADIM.length - 1) * 4 + s0 * 8, pyy + ph - 10, 2,
         s0 === D.adim ? P.au0 : 'rgba(0,0,0,.35)');

  var son = D.adim === DERS_ADIM.length - 1;
  if (D.t > .35 && button(pxx + pw - 62, pyy + ph - 17, 56, 15,
                          son ? T('AL') : T('DEVAM'), son ? '#3f8a4a' : '#3f6fbd', true)) {
    SFX.ui();
    if (son) {
      /* DEPO hediye: parasiz, dogrudan seviye 1 */
      if (upgLevel('store') < 1) {
        G.up.store = 1; SHOP.bake = null;
        SFX.cash(); SFX.levelup(); flash(.25, '#ffe9a0');
        var yerS = upgRozetYeri(dersHedefEtiket('store'));
        var sx0 = yerS[0], sy0 = yerS[1];
        burst(sx0, sy0, 22, [P.au0, P.au1, '#fff'], { spMax: 90, type: 'star', sz: 2 });
        ftext(T('DEPO HEDİYE!'), sx0, sy0 - 18, P.au0, { life: 2, sc: 1 });
      }
      G.ders = null; G.dersGorulmus = true; saveAll();
    } else { D.adim++; D.t = 0; }
  }
}
/* ---------------- TEST SURUMU: ekranda DEV dugmesi ----------------
   Uzaktaki test kullanicisi mobilden oynuyor; klavye yok, 'T' kisayolu
   calismiyor. Yalnizca test derlemesinde (window.__DEV_BUILD) cizilir. */
function devDugmeKutu() {
  /* Panel acikken dugme HUD kosesinde kalirsa ust kisayol satirinin
     son dugmesiyle (GUN BIT) ust uste biniyor. Panel acikken panelin
     BOS alt kosesine gecer; dokunmatikte paneli kapatmanin tek yolu o
     oldugu icin gizlemek dogru degil. */
  if (G.test) return [TESTP.x + TESTP.w - 24, TESTP.y + TESTP.h - 17, 18, 13];
  return [hudSagKenar() - 22, VIEW.top + 24, 18, 13];
}
function drawDevDugme(t) {
  if (!window.__DEV_BUILD) return;
  if (G.scene !== 'play' && G.scene !== 'shop' && G.scene !== 'pause') return;
  var k = devDugmeKutu();
  var ust = inRect(IN.x, IN.y, k[0] - 2, k[1] - 2, k[2] + 4, k[3] + 4);
  ctx.globalAlpha = G.test ? .95 : .58;
  rrect(k[0], k[1], k[2], k[3], 2, G.test ? '#2f6a3a' : '#3a3f46');
  rrect(k[0], k[1], k[2], k[3] - 2, 2, G.test ? '#3f8a4a' : (ust ? '#5a6068' : '#4a5058'));
  ctx.globalAlpha = 1;
  rrectOut(k[0], k[1], k[2], k[3], 2, G.test ? P.au0 : '#6a7078');
  txt('DEV', k[0] + k[2] / 2, k[1] + 3, G.test ? '#ffffff' : '#c8ccd0', { align: 'c' });
}
function devDugmeTik(mx, my) {
  if (!window.__DEV_BUILD) return false;
  if (G.scene !== 'play' && G.scene !== 'shop' && G.scene !== 'pause') return false;
  var k = devDugmeKutu();
  if (!inRect(mx, my, k[0] - 2, k[1] - 2, k[2] + 4, k[3] + 4)) return false;
  G.test = !G.test; SFX.ui();
  return true;
}
/* Bir upgrade'in rozet konumu. drawShop ve drawDers AYNI hesabi
   kullanmali, yoksa ders yanlis yeri isaret eder. */
/* Ic ice gecmis istasyonlar: ayran kutusu drinkM'in ICINDE oldugu icin
   iki rozet ayni noktaya dusuyordu. Ofsetle ayrilirlar. */
var ROZET_OFSET = { ayran: [-24, 4] };
function upgRozetYeri(u) {
  var barAlt = VIEW.top > 0;
  var ub = barAlt ? (H - VIEW.bot - 25) : VIEW.top;
  var ustS = barAlt ? (VIEW.top + 9) : (ub + 25 + 9);
  var altS = barAlt ? (ub - 9) : (H - VIEW.bot - 9);
  var sira = 0;
  for (var i = 0; i < UPG.length; i++) {
    if (UPG[i].id === u.id) break;
    if (UPG[i].st === u.st) sira++;
  }
  var st0 = ST[u.st], rx, ry;
  if (st0) { rx = st0.x + st0.w - 8 - sira * 13; ry = st0.y + 8; }
  else { rx = u.tag[0] + sira * 13; ry = u.tag[1]; }
  var ofs = ROZET_OFSET[u.st];
  if (ofs) { rx += ofs[0]; ry += ofs[1]; }
  return [Math.round(clamp(rx, 9, W - VIEW.right - 9)),
          Math.round(clamp(ry, ustS, altS))];
}

/* Upgrade rozeti: 11px. Durum RENKTEN ve tek simgeden okunur; fiyat yok.
   alinir = altin ve nefes alir, para yetmiyor = kursuni,
   kilit  = asma kilit, tam = yesil tik. */
function rozetCiz(x, y, o) {
  var d = 11, yx = x - 5, yy = y - 5;
  var pz = .5 + .5 * Math.sin(o.t * 4);
  var zemin, kenar, mur;
  if (o.tam)        { zemin = '#26382a'; kenar = '#3f8a4a'; mur = '#6ac07a'; }
  else if (o.kilit) { zemin = '#2e2822'; kenar = '#5a4e42'; mur = '#8a7a68'; }
  else if (o.alinir){ zemin = '#4a3812'; kenar = P.au0;     mur = '#ffe9a0'; }
  else              { zemin = '#2a2b30'; kenar = '#5a5f68'; mur = '#8a9098'; }

  /* Yalnizca ustune gelinen / secili rozet parlar. Alinabilir olanlarin
     HEPSI birden nefes alinca (19 rozet) ekran gereksiz hareketli
     kaliyordu; durum zaten renkten okunuyor. */
  if (o.vurgu) {
    ctx.globalAlpha = .18 + .18 * pz;
    disc(x, y, 9 + pz * 2, o.alinir ? P.au0 : '#c8ccd0');
    ctx.globalAlpha = 1;
  }
  ctx.globalAlpha = .40; rrect(yx + 1, yy + 2, d, d, 3, '#000'); ctx.globalAlpha = 1;
  rrect(yx, yy, d, d, 3, zemin);
  rrectOut(yx, yy, d, d, 3, o.vurgu ? '#ffffff' : kenar);

  if (o.tam) {                       /* tik */
    fr(x - 2, y + 1, 1, 2, mur); fr(x - 1, y + 2, 1, 1, mur);
    fr(x, y, 1, 2, mur); fr(x + 1, y - 2, 1, 3, mur);
  } else if (o.kilit) {              /* asma kilit */
    fr(x - 2, y - 3, 4, 1, mur); px(x - 3, y - 2, mur); px(x + 2, y - 2, mur);
    fr(x - 3, y - 1, 7, 5, mur);
    px(x, y + 1, zemin);
  } else {                           /* arti */
    fr(x - 3, y - 1, 7, 2, mur);
    fr(x - 1, y - 3, 2, 7, mur);
  }
}

function arrowTo(x0, y0, x1, y1, col) {
  var dx = x1 - x0, dy = y1 - y0;
  var len = Math.sqrt(dx * dx + dy * dy);
  if (len < 6) return;
  var steps = Math.floor(len / 2);
  var nx = -dy / len, ny = dx / len;
  var bend = Math.min(16, len * .24);
  var last = null, ax = 0, ay = 0;
  for (var i = 0; i <= steps * .82; i++) {
    var sp = i / steps;
    var b = Math.sin(sp * Math.PI) * bend;
    var x = Math.round(x0 + dx * sp + nx * b), y = Math.round(y0 + dy * sp + ny * b);
    if (last && (last[0] !== x || last[1] !== y)) {
      px(x, y, col); px(x + 1, y, col); px(x, y + 1, '#7a1a14');
    }
    last = [x, y]; ax = x; ay = y;
  }
  /* ok başı */
  var a2 = Math.atan2(y1 - ay, x1 - ax);
  for (var k = 0; k < 6; k++) {
    var hx = ax + Math.cos(a2) * k, hy = ay + Math.sin(a2) * k;
    px(hx, hy, col); px(hx + 1, hy, col);
    px(ax + Math.cos(a2 - 2.4) * k, ay + Math.sin(a2 - 2.4) * k, col);
    px(ax + Math.cos(a2 + 2.4) * k, ay + Math.sin(a2 + 2.4) * k, col);
    px(ax + Math.cos(a2 - 2.4) * k + 1, ay + Math.sin(a2 - 2.4) * k, col);
    px(ax + Math.cos(a2 + 2.4) * k + 1, ay + Math.sin(a2 + 2.4) * k, col);
  }
}

/* ---------------- duraklat ---------------- */
function drawPause(t) {
  drawPlay(t);
  if (BSP.open) { drawBasarimPanel(t); return; }
  if (STATS.open) { drawStatsPanel(t); return; }
  if (SESP.open) { drawSesPanel(t); return; }
  ctx.globalAlpha = .62; fr(0, 0, W, H, '#140a06'); ctx.globalAlpha = 1;
  panel(W / 2 - 70, 58, 140, 140, 'MOLA');
  if (button(W / 2 - 50, 76, 100, 20, 'DEVAM ET', '#3f8a4a', true)) { SFX.ui(); G.scene = 'play'; }
  if (button(W / 2 - 50, 100, 100, 20, 'SES AYARLARI', '#3f6fbd')) { SFX.ui(); SESP.open = true; }
  if (!TOUCH && button(W / 2 - 50, 124, 100, 20, fsOn() ? 'TAM EKRAN: AÇIK' : 'TAM EKRAN', '#7a5aa0')) { SFX.ui(); fsToggle(); }
  if (button(W / 2 - 50, 148, 48, 20, 'REKOR', '#3f6fbd')) { SFX.ui(); STATS.open = true; }
  if (button(W / 2 + 2, 148, 48, 20, 'BAŞARIM', '#b0862a')) { SFX.ui(); BSP.open = true; }
  if (button(W / 2 - 50, 172, 100, 20, 'ANA MENÜ', '#8a4a4a')) { SFX.uiBack(); G.scene = 'title'; }
}

/* ---------------- TEST PANELİ (T tuşu) ---------------- */
var TESTP = { x: 8, y: 8, w: 464, h: 256, page: 0 };
function testPanelOpen() { return !!G.test; }
function testHit(mx, my) { return testPanelOpen() && inRect(mx, my, TESTP.x, TESTP.y, TESTP.w, TESTP.h); }
function tinyBtn(x, y, w, h, label, col) {
  var over = inRect(IN.x, IN.y, x, y, w, h);
  var c1 = shadeCol(col, over ? 1.3 : 1), c2 = shadeCol(col, .6);
  rrect(x, y, w, h, 2, c2);
  rrect(x, y, w, h - 1, 2, c1);
  rrectOut(x, y, w, h, 2, P.ui5);
  txt(label, x + w / 2, y + (h - 8) / 2, P.ui0, { align: 'c' });
  return over && IN.pressed;
}
function setUp(id, lvl) {
  var u = upgById(id);
  if (!u) return;
  G.up[id] = clamp(lvl, 0, u.lv.length);
  if (G.up[id] === 0) delete G.up[id];
  /* anında etkilenenler */
  if (id === 'paint') { BG = null; }
  if (id === 'expand' && G.cfg) G.cfg.slots = TUN.slots(G);
  if (id === 'uncle' && G.uncle) G.uncle.left = TUN.uncleUses(G);
  if (id === 'store') {
    var m = TUN.stockMax(G);
    G.stock.pickle = Math.min(G.stock.pickle, m);
    G.stock.yogurt = Math.min(G.stock.yogurt, m);
  }
  if (id === 'phone' && !TUN.phoneOn(G)) phoneReset();
  if (id === 'board') {
    /* fazla tezgâhtaki dürümleri düşür */
    for (var i = TUN.boards(G); i < 3; i++) G.boards[i] = null;
    G.sel = Math.min(G.sel, TUN.boards(G) - 1);
  }
  saveAll();
}
function drawTestPanel(t) {
  var P0 = TESTP;
  ctx.globalAlpha = .82; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  rrect(P0.x, P0.y, P0.w, P0.h, 4, P.ui5);
  rrect(P0.x + 1, P0.y + 1, P0.w - 2, P0.h - 2, 4, '#241c16');
  rrectOut(P0.x, P0.y, P0.w, P0.h, 4, P.au2);
  txt('TEST PANELİ', P0.x + 8, P0.y + 5, P.au0);
  txt('T = kapat', P0.x + P0.w - 8, P0.y + 5, P.ui2, { align: 'r' });

  /* --- üst kısayollar --- */
  var by = P0.y + 16, bx = P0.x + 6;
  if (tinyBtn(bx, by, 62, 14, 'HEPSİ MAX', '#3f8a4a')) {
    for (var i = 0; i < UPG.length; i++) setUp(UPG[i].id, UPG[i].lv.length);
    SFX.levelup();
  }
  if (tinyBtn(bx + 66, by, 56, 14, 'SIFIRLA', '#8a4a4a')) {
    for (var j = 0; j < UPG.length; j++) setUp(UPG[j].id, 0);
    SFX.uiBack();
  }
  /* Hizli kontrol icin 5.000 cok azdi: son subeler milyonlarca tutuyor. */
  if (tinyBtn(bx + 126, by, 44, 14, '+$5M', '#b0862a')) { G.money += 5000000; SFX.cash(); }
  if (tinyBtn(bx + 174, by, 48, 14, 'STOK', '#3f6fbd')) {
    G.stock.pickle = stMax(); G.stock.yogurt = stMax();
    G.stockAnim.pickle = stMax(); G.stockAnim.yogurt = stMax();
    G.meat = TUN.meatCap(); G.friesTray = TUN.friesCap(); G.cut.raw = 10;
    SFX.pop();
  }
  if (tinyBtn(bx + 226, by, 60, 14, 'TELEFON', '#8a5aa0')) {
    if (!TUN.phoneOn(G)) setUp('phone', 1);
    G.phone.state = 'ring'; G.phone.ringT = 0; G.phone.beep = 0;
  }
  if (tinyBtn(bx + 290, by, 54, 14, 'MÜŞTERİ', '#3f8a8a')) { spawnCustomer(); }
  if (tinyBtn(bx + 348, by, 42, 14, 'GÜN +1', '#b0602a')) {
    G.day++; startDay(); G.test = true; SFX.bell();
  }
  if (tinyBtn(bx + 394, by, 56, 14, 'GÜN BİT', '#8a3a3a')) { G.timeLeft = .01; G.test = false; }
  /* borç satırı */
  var dby = by + 16;
  txt(T('BORÇ: $') + fmtShort(G.debt), bx + 2, dby + 3, '#ff9a8a');
  if (tinyBtn(bx + 84, dby, 40, 12, '-500K', '#3f7a4a')) { G.debt = Math.max(0, G.debt - 500000); saveAll(); }
  if (tinyBtn(bx + 128, dby, 40, 12, '+500K', '#7a4040')) { G.debt += 500000; saveAll(); }
  if (tinyBtn(bx + 172, dby, 44, 12, 'SIFIR', '#b0862a')) { G.debt = 0; G.debtCleared = true; saveAll(); }

  /* --- upgrade listesi: 2 sütun, SAYFALI ---
     24 upgrade / 2 sütun = 12 satır x 20px = 240px; panelin içi 208px.
     Son iki satır panelin DIŞINA taşıyordu, yani listenin en sonundaki
     yeni upgrade'ler (Malzeme Seçimi, Jeneratör) hiç görünmüyordu.
     Sayfa başına 6 satır; artan yer aşağıdaki etkinlik kısayollarına. */
  var rowH = 20, colW = 226, top = P0.y + 48;
  var SATIR = 6, SAYFADA = SATIR * 2;
  var sayfaAdet = Math.ceil(UPG.length / SAYFADA);
  if (P0.page >= sayfaAdet) P0.page = 0;
  if (sayfaAdet > 1 &&
      tinyBtn(P0.x + P0.w - 122, P0.y + 4, 58, 11,
              T('SAYFA ') + (P0.page + 1) + '/' + sayfaAdet, '#4a5a7a')) {
    P0.page = (P0.page + 1) % sayfaAdet; SFX.ui();
  }
  var bas = P0.page * SAYFADA;
  for (var k = bas; k < Math.min(bas + SAYFADA, UPG.length); k++) {
    var u = UPG[k], yer = k - bas;
    var col = yer % 2, row = (yer / 2) | 0;
    var rx = P0.x + 5 + col * colW, ry = top + row * rowH;
    var lvl = G.up[u.id] || 0, max = u.lv.length;
    /* satır zemini */
    rrect(rx, ry, colW - 6, rowH - 3, 2, lvl > 0 ? '#33291f' : '#2b241c');
    if (lvl >= max) rrectOut(rx, ry, colW - 6, rowH - 3, 2, '#4a7a3a');
    /* isim */
    txt(u.name, rx + 4, ry + 2, lvl > 0 ? P.au0 : P.ui1);
    /* seviye adı / etki */
    var sub = lvl > 0 ? (u.lvName ? u.lvName[Math.min(lvl, u.lvName.length) - 1] : ('sv ' + lvl)) : 'kapalı';
    txt(sub, rx + 4, ry + 11, lvl > 0 ? P.ui1 : P.ui3);
    /* seviye noktaları */
    for (var d = 0; d < max; d++) {
      var dx = rx + colW - 66 + d * 6;
      disc(dx, ry + 6, 2, d < lvl ? P.ok : 'rgba(255,255,255,.18)');
    }
    txt(lvl + '/' + max, rx + colW - 66, ry + 11, P.ui2);
    /* - / + */
    if (tinyBtn(rx + colW - 40, ry + 2, 14, 14, '-', '#7a4040')) { setUp(u.id, lvl - 1); SFX.uiBack(); }
    if (tinyBtn(rx + colW - 23, ry + 2, 14, 14, '+', '#3f7a4a')) {
      if (lvl < max) { setUp(u.id, lvl + 1); SFX.ui(); } else SFX.bad();
    }
  }

  /* --- YENİ ETKİNLİKLER: hepsi elle tetiklenebilsin ---
     Kedi %30, kesinti %16, rakip birkaç günde bir geliyor; şansa
     bırakınca test etmek için gün gün beklemek gerekiyordu. */
  var ey = top + SATIR * rowH + 6, ebx = P0.x + 6;
  txt('YENİ ETKİNLİKLER', ebx, ey, P.au1);
  var eby = ey + 11;
  if (tinyBtn(ebx, eby, 44, 14, 'KEDİ', '#7a6a3a')) {
    var M0 = stM();
    G.kedi = { faz: 'gelis', t: 0, girisT: 0, x: M0.gx + M0.gw + 20,
               doydu: false, miyav: 0 };
    G.meat = Math.max(G.meat, 4);          /* verecek et olsun */
    G.test = false; SFX.ui();
  }
  if (tinyBtn(ebx + 48, eby, 58, 14, 'ELEKTRİK', '#3f5a8a')) {
    /* 'bekle' fazından girilir: önce ışık kırpışması, sonra kesinti —
       gerçek yol test edilsin diye durum elle 'kesik' yapılmıyor. */
    var gecen = G.cfg ? 1 - clamp(G.timeLeft / G.cfg.len, 0, 1) : 0;
    G.kesinti = { faz: 'bekle', t: 0, basla: gecen + .01,
                  sure: TUN.kesintiSure(G), uyari: 0 };
    G.test = false; SFX.ui();
  }
  if (tinyBtn(ebx + 110, eby, 48, 14, 'RAKİP', '#8a4a3a')) {
    G.rakipKapandi = false; G.rakipHedef = G.day;
    var eskiGun = G.day; if (G.day < RAKIP_GUN) G.day = RAKIP_GUN;
    rakipGunBasi();
    G.day = eskiGun;
    if (G.rakip) { G.rakip.girisT = 0; G.rakip.t = 0; }
    G.test = false; SFX.ui();
  }
  if (tinyBtn(ebx + 162, eby, 46, 14, 'MAÇ', '#3f8a5a')) {
    G.macGun = true;
    if (G.cfg) G.timeLeft = G.cfg.len * (1 - (MAC_BAS + MAC_BIT) / 2);
    G.test = false; SFX.ui();
  }
  var HAVALAR = ['sun', 'rain', 'kar', 'sicak'];
  if (tinyBtn(ebx + 212, eby, 96, 14, T('HAVA: ') + G.weather, '#5a5a7a')) {
    var hi = HAVALAR.indexOf(G.weather);
    G.weather = HAVALAR[(hi + 1) % HAVALAR.length];
    invalidateLayers(); if (typeof bgBayat === 'function') bgBayat();
    SFX.ui();
  }
  if (tinyBtn(ebx + 312, eby, 66, 14, 'SEÇİM+MÜŞ', '#3f8a8a')) {
    /* Malzeme Seçimi'ni aç, malzemeyi doldur ve MUTLAKA istekli bir
       müşteri getir: siparişi rastgele üretilirse "turşusuz" çıkmayabilir
       ve özellik test edilemez. */
    setUp('secim', 2);
    G.stock.pickle = stMax(); G.stock.yogurt = stMax();
    G.stockAnim.pickle = stMax(); G.stockAnim.yogurt = stMax();
    G.meat = TUN.meatCap(); G.friesTray = TUN.friesCap();
    spawnCustomer();
    var son = G.customers[G.customers.length - 1];
    if (son && son.items) for (var q = 0; q < son.items.length; q++) {
      if (son.items[q].kind === 'wrap' && !son.items[q].yok) son.items[q].yok = ['pickle'];
    }
    G.test = false; SFX.ui();
  }
  if (tinyBtn(ebx + 382, eby, 62, 14, 'BAHİS ÇÖZ', '#8a6a3a')) {
    if (G.bahis) { bahisCoz(); SFX.ui(); } else SFX.bad();
  }
  txt('SEÇİM+MÜŞ: müşteri "turşusuz" ister — turşu koyarsan kızar',
      ebx, eby + 18, P.ui2);
  txt('Kısayollar oyunu görebilmek için paneli kapatır (T ile geri aç)',
      ebx, eby + 28, P.ui3);
}

/* ---------------- KİŞİSELLEŞTİRME PANELİ ---------------- */
var CUSTOM = { open: false, edit: false };
function drawCustomPanel(t) {
  var x = 60, y = 34, w = 360, h = 200;
  ctx.globalAlpha = .8; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  panel(x, y, w, h, 'DÜKKÂNI KİŞİSELLEŞTİR');
  /* --- tabela adı --- */
  txt('Tabela adı', x + 14, y + 16, P.ui4);
  var fx = x + 14, fy = y + 26, fw = 118;
  rrect(fx, fy, fw, 16, 3, CUSTOM.edit ? '#fffdf0' : P.ui1);
  rrectOut(fx, fy, fw, 16, 3, CUSTOM.edit ? P.au2 : P.ui3);
  var nm = CUSTOM.edit ? TEXTIN.value : G.custom.sign;
  txt(nm, fx + 5, fy + 4, P.ink);
  if (CUSTOM.edit && Math.sin(t * 8) > 0) fr(fx + 6 + textW(nm), fy + 3, 1, 10, P.ink);
  if (!CUSTOM.edit && button(fx + fw + 6, fy, 52, 16, 'DEĞİŞTİR', '#3f6fbd')) {
    CUSTOM.edit = true; textStart(G.custom.sign, 14); SFX.ui();
  }
  if (CUSTOM.edit) {
    txt('Enter=kaydet', fx + fw + 8, fy + 1, P.ui3);
    txt('Esc=vazgeç', fx + fw + 8, fy + 10, P.ui3);
    if (TEXTIN.done) { G.custom.sign = TEXTIN.value.trim() || 'USTA DÖNER'; CUSTOM.edit = false; textStop(); SFX.ding(); saveAll(); }
    if (TEXTIN.cancel) { CUSTOM.edit = false; textStop(); SFX.uiBack(); }
  }
  /* --- alt yazı --- */
  txt('Alt yazı', x + 14, y + 48, P.ui4);
  var subs = ['EFSANE LEZZET', 'BABADAN OĞULA', '1985 TEN BERİ', 'TAM DÖNER', ''];
  var si = subs.indexOf(G.custom.sub); if (si < 0) si = 0;
  if (button(x + 14, y + 58, 16, 16, '<', '#7a6040')) { G.custom.sub = subs[(si + subs.length - 1) % subs.length]; SFX.ui(); saveAll(); }
  if (button(x + 164, y + 58, 16, 16, '>', '#7a6040')) { G.custom.sub = subs[(si + 1) % subs.length]; SFX.ui(); saveAll(); }
  rrect(x + 32, y + 58, 130, 16, 3, P.ui1);
  txt(G.custom.sub || '(yok)', x + 97, y + 62, P.ink, { align: 'c' });

  /* --- poster --- */
  txt('Duvar süsü', x + 14, y + 82, P.ui4);
  if (button(x + 14, y + 92, 16, 16, '<', '#7a6040')) { G.custom.poster = (G.custom.poster + POSTERS.length - 1) % POSTERS.length; SFX.ui(); saveAll(); }
  if (button(x + 164, y + 92, 16, 16, '>', '#7a6040')) { G.custom.poster = (G.custom.poster + 1) % POSTERS.length; SFX.ui(); saveAll(); }
  rrect(x + 32, y + 92, 130, 16, 3, P.ui1);
  txt(POSTERS[G.custom.poster], x + 97, y + 96, P.ink, { align: 'c' });

  /* --- tezgâh rengi --- */
  txt('Tezgâh rengi', x + 14, y + 116, P.ui4);
  if (button(x + 14, y + 126, 16, 16, '<', '#7a6040')) { G.custom.counter = (G.custom.counter + COUNTER_STYLES.length - 1) % COUNTER_STYLES.length; CLAYER = null; SFX.ui(); saveAll(); }
  if (button(x + 164, y + 126, 16, 16, '>', '#7a6040')) { G.custom.counter = (G.custom.counter + 1) % COUNTER_STYLES.length; CLAYER = null; SFX.ui(); saveAll(); }
  rrect(x + 32, y + 126, 130, 16, 3, P.ui1);
  txt(COUNTER_STYLES[G.custom.counter], x + 97, y + 130, P.ink, { align: 'c' });

  /* --- önizleme: her sey cerceve ICINDE ve olculu --- */
  var pvx = x + 200, pvy = y + 20, pvw = 146, pvh = 120;
  rrect(pvx, pvy, pvw, pvh, 3, '#2b241c');
  rrectOut(pvx, pvy, pvw, pvh, 3, P.ui3);
  ctx.save();
  ctx.beginPath(); ctx.rect(pvx + 2, pvy + 2, pvw - 4, pvh - 4); ctx.clip();

  /* 1) sehrin duvar dokusu */
  var TM = sehirTema(), DP = duvarPaleti(TM, UV(G, 'paint'));
  fr(pvx + 2, pvy + 2, pvw - 4, pvh - 4, DP[3]);
  for (var ty2 = pvy + 2; ty2 < pvy + pvh - 2; ty2 += 12) {
    for (var tx2 = pvx + 2; tx2 < pvx + pvw - 2; tx2 += 12) {
      var hs = hash1(tx2 * .37 + ty2 * 1.13);
      fr(tx2 + 1, ty2 + 1, 11, 11, hs < .18 ? DP[0] : (hs < .62 ? DP[1] : DP[2]));
      hl(tx2 + 1, ty2 + 1, 11, DP[0]);
    }
  }
  ctx.globalAlpha = .18; fr(pvx + 2, pvy + 2, pvw - 4, pvh - 4, '#000'); ctx.globalAlpha = 1;

  /* 2) TABELA — ortali, cercevenin icine sigacak sekilde */
  if (UV(G, 'sign') > 0) {
    var sgw = tabelaGen();
    var sgx = Math.round(pvx + pvw / 2 - sgw / 2);
    ctx.save();
    if (sgw > pvw - 10) {            /* uzun ad: cerceveye sigsin diye kirp */
      ctx.beginPath(); ctx.rect(pvx + 4, pvy + 4, pvw - 8, 34); ctx.clip();
    }
    drawTabela(sgx, pvy + 8, t);
    ctx.restore();
  } else {
    txt(T('Tabela kapalı'), pvx + pvw / 2, pvy + 16, P.ui3, { align: 'c' });
  }

  /* 3) DUVAR SUSU — tabelanin altinda, ortali */
  var sus = (G.custom && G.custom.poster) || 0;
  if (sus > 0) drawPoster(sus, t, Math.round(pvx + pvw / 2 - 21), pvy + 44);
  else txt(T('Süs yok'), pvx + pvw / 2, pvy + 56, P.ui3, { align: 'c' });

  ctx.restore();
  /* 4) tezgâh önizleme şeridi */
  var CP = COUNTER_PAL[G.custom.counter % COUNTER_PAL.length];
  fr(pvx + 8, pvy + pvh - 34, pvw - 16, 18, CP.base);
  hl(pvx + 8, pvy + pvh - 34, pvw - 16, CP.edge);
  fr(pvx + 8, pvy + pvh - 16, pvw - 16, 6, CP.lip);
  txt('önizleme', pvx + pvw / 2, pvy + pvh - 9, P.ui3, { align: 'c' });

  if (!CUSTOM.edit && button(x + w / 2 - 40, y + h - 22, 80, 18, 'KAPAT', '#3f8a4a', true)) {
    CUSTOM.open = false; SFX.uiBack(); saveAll();
  }
}

/* ---------------- İSTATİSTİK EKRANI ---------------- */
var STATS = { open: false };


/* nota: muzik seviyesi icin */
function simgeNota(x, y, sesli) {
  x = Math.round(x); y = Math.round(y);
  var c = sesli ? '#8fc4e8' : '#6a6a6a';
  var c2 = sesli ? '#d8ecf8' : '#8a8a8a';
  /* sap */
  fr(x + 2, y - 6, 2, 9, c);
  hl(x + 2, y - 6, 2, c2);
  /* bayrak */
  fr(x + 4, y - 6, 3, 2, c);
  fr(x + 5, y - 4, 2, 2, c);
  /* govde */
  ell(x, y + 3, 3, 2, c);
  ell(x - 1, y + 2, 2, 1, c2);
}

/* hoparlor + dalga: efekt seviyesi icin */
function simgeHoparlor(x, y, seviye) {
  x = Math.round(x); y = Math.round(y);
  var c = seviye > 0 ? '#e8c07a' : '#6a6a6a';
  var c2 = seviye > 0 ? '#fff0c8' : '#8a8a8a';
  /* govde */
  fr(x - 5, y - 2, 3, 5, c);
  /* koni */
  for (var i = 0; i < 4; i++) fr(x - 2 + i, y - 3 - i, 1, 7 + i * 2, c);
  hl(x - 5, y - 2, 3, c2);
  /* dalgalar: seviyeye gore artar */
  if (seviye > 20) { fr(x + 3, y - 2, 1, 5, c2); }
  if (seviye > 55) { fr(x + 5, y - 4, 1, 9, c2); }
  if (seviye > 85) { fr(x + 7, y - 6, 1, 13, c2); }
  if (seviye === 0) {
    /* susturulmus: capraz */
    ln(x + 3, y - 3, x + 8, y + 3, '#c0392b');
    ln(x + 3, y + 3, x + 8, y - 3, '#c0392b');
  }
}

/* ================= SES AYARLARI ================= */
var SESP = { open: false, tutulan: null };

/* 0-100 kaydirici. Basili tutup surukleyerek de ayarlanir. */
function volSlider(x, y, w, deger, tur, renk, t) {
  var h = 9;
  var uzeri = inRect(IN.x, IN.y, x - 4, y - 5, w + 8, h + 10);

  /* oluk */
  rrect(x, y, w, h, 3, '#241c16');
  rrect(x + 1, y + 1, w - 2, h - 2, 2, '#3a3028');
  /* dolu kisim */
  var dw = Math.round((w - 2) * clamp(deger, 0, 100) / 100);
  if (dw > 0) {
    rrect(x + 1, y + 1, dw, h - 2, 2, shadeCol(renk, .68));
    rrect(x + 1, y + 1, dw, h - 3, 2, renk);
    hl(x + 2, y + 1, Math.max(0, dw - 2), shadeCol(renk, 1.45));
  }
  /* tutamak */
  var hx = x + 1 + dw;
  ctx.globalAlpha = .35; rrect(hx - 3, y - 2, 7, h + 4, 2, '#000'); ctx.globalAlpha = 1;
  rrect(hx - 3, y - 3, 7, h + 4, 2, uzeri ? '#fff4d8' : '#e8e2d0');
  rrect(hx - 2, y - 2, 5, h + 2, 2, uzeri ? '#ffffff' : '#f6f2e6');
  vl(hx, y - 1, h + 1, shadeCol(renk, .8));

  /* Sürükleme.
     HATA: tutulan hiç sıfırlanmıyordu; parmağı kaldırdıktan sonra
     ekranda başka bir yere basınca kaydırıcı imlecin x'ine atlıyor,
     100'e çektiğin ses eski değerine geri düşüyordu. */
  if (!IN.down) { if (SESP.tutulan === tur) SESP.tutulan = null; return uzeri; }
  if (SESP.tutulan !== tur) {
    /* yeni tutuş yalnız kaydırıcının üstünde ve basma anında başlar */
    if (!(uzeri && IN.pressed && SESP.tutulan === null)) return uzeri;
    SESP.tutulan = tur;
  }
  var yeni = Math.round((IN.x - x - 1) / (w - 2) * 100);
  if (yeni !== VOL[tur]) {
    volAyarla(tur, yeni);
    /* efekt kaydırıcısında anlık örnek ses: ne kadar yüksek duyuluyor */
    if (tur === 'sfx' && chance(.35)) SFX.pop();
  }
  return uzeri;
}

function drawSesPanel(t) {
  var x = 128, y = 52, w = 224, h = 152;
  ctx.globalAlpha = .84; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  panel(x, y, w, h, 'SES');

  /* --- müzik --- */
  simgeNota(x + 20, y + 26, VOL.mus > 0 && !MUTED);
  txt('MÜZİK', x + 32, y + 22, P.ink);
  txt('' + VOL.mus, x + w - 18, y + 22, VOL.mus > 0 ? '#2f6a9a' : '#9a9288', { align: 'r' });
  volSlider(x + 18, y + 34, w - 36, VOL.mus, 'mus', '#3f8ac0', t);

  /* --- efektler --- */
  simgeHoparlor(x + 22, y + 74, MUTED ? 0 : VOL.sfx);
  txt('SES EFEKTLERİ', x + 32, y + 70, P.ink);
  txt('' + VOL.sfx, x + w - 18, y + 70, VOL.sfx > 0 ? '#8a6210' : '#9a9288', { align: 'r' });
  volSlider(x + 18, y + 82, w - 36, VOL.sfx, 'sfx', '#c08a2a', t);

  /* --- hepsini sustur --- */
  if (button(x + 18, y + 104, w - 36, 20, MUTED ? 'SESİ AÇ' : 'HEPSİNİ SUSTUR',
             MUTED ? '#3f8a4a' : '#8a4a4a')) {
    sesKis(MUTED);
    if (!MUTED) SFX.ui();
  }

  /* tutuş, parmak kalkınca serbest kalır */
  if (!IN.down) SESP.tutulan = null;
  if (button(x + w / 2 - 40, y + h - 24, 80, 18, 'KAPAT', P.red1, true)) {
    SESP.open = false; SESP.tutulan = null; SFX.uiBack();
  }
}


/* ================= BORÇ ÖDEME ================= */
var PAYP = { open: false, amt: 0 };

function payDebt(amount) {
  amount = Math.min(Math.floor(amount), G.money, G.debt);
  if (amount <= 0) { SFX.bad(); return false; }
  G.money -= amount;
  G.debt -= amount;
  G.stats.debtPaid = (G.stats.debtPaid || 0) + amount;
  SFX.cash();
  burst(W / 2, 130, 22, [P.au0, P.au1, '#fff'], { spMax: 90, type: 'star', sz: 2 });
  ftext('-$' + fmtMoney(amount), W / 2, 108, P.ok, { life: 1.6, sc: 1 });
  if (G.debt <= 0) {
    G.debt = 0;
    if (!G.debtCleared) { G.debtCleared = true; G.celeb = { t: 0 }; SFX.levelup(); }
  }
  saveAll();
  return true;
}

function drawPayPanel(t) {
  var x = 96, y = 46, w = 288, h = 176;
  ctx.globalAlpha = .84; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  panel(x, y, w, h, 'BORÇ ÖDE');

  txt('Kasandaki para', x + 16, y + 18, P.ui4);
  icon('coin', x + w - 92, y + 22, t);
  txt('$' + fmtMoney(G.money), x + w - 16, y + 15, '#8a6a10', { align: 'r', sc: 1 });

  txt('Kalan borç', x + 16, y + 40, P.ui4);
  txt('$' + fmtMoney(G.debt), x + w - 16, y + 37, '#a83a2a', { align: 'r', sc: 1 });

  var pr = 1 - clamp(G.debt / DEBT_START, 0, 1);
  bar(x + 16, y + 58, w - 32, 9, pr, P.ok);
  txt('%' + (pr * 100).toFixed(pr > 0 && pr < .01 ? 2 : 1), x + w / 2, y + 59, '#ffffff', { align: 'c', shadow: 1 });

  ctx.globalAlpha = .3; hl(x + 14, y + 76, w - 28, P.ui2); ctx.globalAlpha = 1;
  /* Birlestirilmis cumle: HER IKI parca da ayri ayri cevrilmeli, yoksa
     Ingilizcede "At day end 25'i zaten gider." gibi karisik dilli cikiyor. */
  txt(T('Gün sonunda kazancının %') + Math.round(DEBT_CUT * 100) + T("'i zaten gider."),
      x + w / 2, y + 82, P.ui4, { align: 'c' });
  txt('Buradan istediğin kadarını hemen kapatabilirsin.', x + w / 2, y + 92, P.ui4, { align: 'c' });

  /* miktar butonları */
  var amts = [
    ['%25', Math.floor(G.money * .25)],
    ['%50', Math.floor(G.money * .50)],
    ['TÜMÜ', G.money]
  ];
  for (var i = 0; i < amts.length; i++) {
    var bw = 76, bx = x + 20 + i * (bw + 12);
    var v = Math.min(amts[i][1], G.debt);
    var can = v > 0;
    if (button(bx, y + 106, bw, 20, amts[i][0], can ? '#3f8a4a' : '#4a4038', can)) {
      if (can) payDebt(amts[i][1]); else SFX.bad();
    }
    txt(can ? '$' + fmtShort(v) : '—', bx + bw / 2, y + 129, can ? P.au2 : P.ui3, { align: 'c' });
  }

  if (button(x + w / 2 - 40, y + h - 22, 80, 18, 'KAPAT', P.red1, true)) { PAYP.open = false; SFX.uiBack(); }
}


/* ================= ŞUBELER ================= */
var BRP = { open: false, t: 0 };

/* küçük şube rozeti: sahip olunan / kilitli */
function branchIcon(x, y, owned, k) {
  var wall = owned ? '#c8a25a' : '#4a423a';
  var roof = owned ? '#a8342a' : '#3a3230';
  fr(x - 8, y - 4, 17, 12, shadeCol(wall, .55));
  fr(x - 8, y - 4, 16, 11, wall);
  hl(x - 7, y - 4, 14, shadeCol(wall, 1.3));
  /* tente */
  for (var i = 0; i < 4; i++) fr(x - 8 + i * 4, y - 8, 4, 4, i % 2 ? roof : shadeCol(roof, 1.35));
  fr(x - 8, y - 9, 16, 2, shadeCol(roof, .6));
  /* vitrin */
  fr(x - 6, y - 1, 6, 6, owned ? '#2a1c14' : '#241f1c');
  if (owned) {
    fr(x - 5, y, 4, 4, '#ffcf6a');
    /* dönen şiş */
    fr(x + 3, y - 2, 3, 7, '#7a4a1e');
    fr(x + 3, y - 2 + (k % 2), 3, 3, '#c8752a');
    px(x + 4, y - 3, '#e8e2d0');
  } else {
    /* kilit */
    fr(x - 1, y + 1, 5, 4, '#6a6058');
    fr(x, y - 1, 3, 3, '#6a6058');
    px(x + 1, y + 2, '#2a2622');
  }
}

/* Sehir degistir. Gun ortasinda tasinmak kafa karistirir:
   yalnizca gun disinda (dukkan/menu ekranlarinda) izin verilir. */
function sehreGit(i) {
  if (!sehirAcik(i)) { SFX.bad(); say(T('Önce o şubeyi aç')); return; }
  if (G.city === i) return;
  G.city = i;
  /* Demirkent ayri bir ekonomi: ilk giriste kasa, hane ve gun sayaci kurulur.
     Daha once girilmisse kaldigi yerden devam eder. */
  if (fermanSehri(G)) fermanEkonomiKur(false);
  invalidateLayers();
  saveAll();
  SFX.levelup();
  ftext(sehirAdi(i), W / 2, 110, P.au0, { life: 2, sc: 1 });
  flash(.20, '#ffe9a0');
}
function drawBranchPanel(t) {
  var kk = panelKutu(10, 262), y = kk[0], h = kk[1];
  var x = 44, w = 392;
  ctx.globalAlpha = .84; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  panel(x, y, w, h, 'ŞUBELER');

  var owned = G.branch || 0;
  var base = branchBase(G);
  var seviye = upgTotalLv(G);
  var k = Math.floor(t * 4);
  /* Demirkent listede DEGIL: ayri bir mod olarak altta kendi bandinda.
     Listeye eklenince satirlar sikisip altyaziyi eziyordu. Ust ozetteki
     sayimda da kullanildigi icin burada, listeden ONCE tanimlanir. */
  var nList = BRANCH.length - (BRANCH[BRANCH.length - 1].ferman ? 1 : 0);
  var modBandi = BRANCH[BRANCH.length - 1].ferman ? 22 : 0;

  /* üst özet */
  /* Demirkent ayri bir mod: sube sayimina girmez, yoksa '8/9' yaziyordu. */
  txt(T('Açık şube: ') + Math.min(owned, nList) + '/' + nList +
      T('    Dükkân seviyesi: ') + seviye, x + 14, y + 16, P.ui4);
  txt(T('Günlük şube geliri: $') + fmtMoney(base), x + w - 14, y + 16, base > 0 ? P.au2 : P.ui3, { align: 'r' });
  ctx.globalAlpha = .3; hl(x + 12, y + 26, w - 24, P.ui2); ctx.globalAlpha = 1;

  /* --- NEREDESİN: üst özetin altına, listeden önce --- */
  /* P.au0 acik altin, krem panelde okunmuyordu; etiket koyu,
     sehir adi vurgulu. */
  var etk = T('Buradasın: ');
  txt(etk, x + 14, y + 28, P.ui4);
  txt(sehirAdi(), x + 14 + textW(etk), y + 28, G.city >= 0 ? '#2f6a8a' : '#a8621f');

  /* liste */
  /* Satir yuksekligi VE altyazi ayni butceden turetilir; yoksa dar
     ekranda liste altyazinin uzerine biner. */
  var darP = h < 240;
  /* Alt alan = ayrac + altyazi + KAPAT dugmesi. Dugmeyi butceye katmazsan
     altyazi dugmenin uzerine biner. */
  /* Dar ekranda satirlar TEK SATIR (aciklama dusulur) ve altyazi gizlenir;
     yoksa 8 sube + mod bandi + KAPAT sigmiyor. Genis ekranda altyazi tek
     satir, boylece satir yuksekligi 19'a cikar ve satirlar cakismaz. */
  var altAlan = (darP ? 26 : 40) + modBandi;
  var ly = y + 42;
  var rowH = clamp(Math.floor((h - 42 - altAlan) / nList), darP ? 14 : 17, 25);
  for (var i = 0; i < nList; i++) {
    var b = BRANCH[i];
    var have = i < owned;
    var isNext = i === owned;
    var ry = ly + i * rowH;
    var kilitli = isNext && branchLocked(i, G);
    var afford = isNext && !kilitli && G.money >= b.p;

    if (have) { ctx.globalAlpha = .18; rrect(x + 12, ry - 2, w - 24, rowH - 3, 3, P.ok); ctx.globalAlpha = 1; }
    else if (isNext) { ctx.globalAlpha = .16; rrect(x + 12, ry - 2, w - 24, rowH - 3, 3, afford ? P.au0 : '#7a4a4a'); ctx.globalAlpha = 1; }

    branchIcon(x + 30, ry + 10, have, k + i);
    txt(b.name, x + 48, ry + (darP ? 4 : 2), have ? P.ink : (isNext ? P.ink : '#6a6058'));
    if (!darP) txt(have || isNext ? b.desc : '???', x + 48, ry + 12, have ? P.ui4 : '#5a5450');
    txt('+$' + fmtShort(b.inc) + T('/gün'), x + 250, ry + 6, have ? P.au2 : '#6a6058', { align: 'r' });

    if (have) {
      if (G.city === i) {
        txt(T('BURADASIN'), x + w - 20, ry + 6, P.au0, { align: 'r', outline: true });
      } else if (button(x + w - 76, ry + 1, 56, 16, T('GİT'), '#3a6a8a', true)) {
        sehreGit(i);
      }
    } else if (isNext && kilitli) {
      txt('DÜKKÂN SEVİYESİ', x + w - 20, ry + 1, '#a8763a', { align: 'r' });
      txt(seviye + '/' + b.req, x + w - 20, ry + 11, '#d8a84a', { align: 'r' });
    } else if (isNext) {
      if (button(x + w - 96, ry + 1, 76, 16, '$' + fmtShort(b.p), afford ? '#3f8a4a' : '#6a3a3a', afford)) {
        if (G.money >= b.p) {
          G.money -= b.p; G.branch = owned + 1;
          SFX.cash(); SFX.levelup();
          burst(x + 30, ry + 10, 26, [P.au0, P.au1, '#fff'], { spMax: 100, type: 'star', sz: 2 });
          ftext(b.name + T(' ŞUBESİ AÇILDI!'), W / 2, 120, P.au0, { life: 2, sc: 1 });
          flash(.25, '#ffe9a0'); shake(.3, 2);
          saveAll();
        } else { SFX.bad(); ftext('Para yetmiyor!', x + w - 58, ry - 4, P.bad); }
      }
    } else {
      txt('KİLİTLİ', x + w - 20, ry + 6, '#5a5450', { align: 'r' });
    }
  }

  /* --- DEMIRKENT BANDI: butun subeler acilinca beliren ayri mod --- */
  if (modBandi) {
    var mi = BRANCH.length - 1, mb = BRANCH[mi];
    var mby = ly + nList * rowH + 4, mbw = w - 24;
    var acik = owned > mi, sirada = owned === mi;
    var mKilit = sirada && branchLocked(mi, G);
    var alinabilir = sirada && !mKilit && G.money >= mb.p;
    if (owned < mi) {
      /* henuz butun subeler acilmadi: kapali band */
      ctx.globalAlpha = .30; rrect(x + 12, mby, mbw, 20, 3, '#2a2e34'); ctx.globalAlpha = 1;
      rrectOut(x + 12, mby, mbw, 20, 3, '#4a4e54');
      txt(T('TÜM ŞUBELER AÇILINCA'), x + w / 2, mby + 6, '#7a7f86', { align: 'c' });
    } else {
      rrect(x + 12, mby, mbw, 20, 3, acik ? '#2f4a34' : '#3a2422');
      rrectOut(x + 12, mby, mbw, 20, 3, acik ? P.ok : '#8e2318');
      fr(x + 12, mby, 4, 20, '#b83228');
      txt(T(mb.name), x + 30, mby + 2, acik ? P.ok : '#e2604f');
      txt(T('FERMAN MODU'), x + 30, mby + 11, '#9a8f80');
      if (acik) {
        if (G.city === mi) txt(T('BURADASIN'), x + w - 20, mby + 6, P.au0, { align: 'r', outline: true });
        else if (button(x + w - 76, mby + 2, 56, 16, T('GİT'), '#8e2318', true)) sehreGit(mi);
      } else if (mKilit) {
        txt(seviye + '/' + mb.req, x + w - 20, mby + 6, '#d8a84a', { align: 'r' });
      } else if (button(x + w - 96, mby + 2, 76, 16, '$' + fmtShort(mb.p),
                        alinabilir ? '#3f8a4a' : '#6a3a3a', alinabilir)) {
        if (G.money >= mb.p) {
          G.money -= mb.p; G.branch = mi + 1;
          SFX.cash(); SFX.levelup();
          ftext(T(mb.name) + T(' AÇILDI!'), W / 2, 120, P.au0, { life: 2, sc: 1 });
          flash(.25, '#ffe9a0'); shake(.3, 2); saveAll();
        } else { SFX.bad(); }
      }
    }
  }
  /* açıklama — yalnizca genis ekranda yer var. Dar ekranda 8 sube +
     mod bandi + KAPAT zaten paneli dolduruyor. */
  if (!darP) {
    var fy = Math.max(ly + nList * rowH + 6 + modBandi, y + h - 40);
    ctx.globalAlpha = .3; hl(x + 12, fy - 6, w - 24, P.ui2); ctx.globalAlpha = 1;
    txt(G.city >= 0 ? T('Şube geliri o günkü satışına göre artar.')
                    : T('Yeni şube açmak için önce dükkânı geliştir.'),
        x + w / 2, fy, P.ui4, { align: 'c' });
  }

  if (G.city >= 0) {
    if (button(x + w / 2 - 132, y + h - 20, 124, 17, T('BABANIN DÜKKÂNI'), '#6a4a2a', true)) sehreGit(-1);
    if (button(x + w / 2 + 12, y + h - 20, 80, 17, 'KAPAT', P.red1, true)) { BRP.open = false; SFX.uiBack(); }
  } else if (button(x + w / 2 - 40, y + h - 20, 80, 17, 'KAPAT', P.red1, true)) { BRP.open = false; SFX.uiBack(); }
}

function drawStatsPanel(t) {
  var S = G.stats || {};
  var kk2 = panelKutu(18, 242), y = kk2[0], h = kk2[1];
  var x = 78, w = 324;
  var dar = h < 238;                     /* kirpilmis ekranda sikisik dizilim */
  var rowSp = dar ? 18 : 20, satSp = dar ? 14 : 16;
  ctx.globalAlpha = .82; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  panel(x, y, w, h, 'REKORLAR');
  var rows = [
    ['wrap', 'Toplam dürüm', S.wraps || 0],
    ['iskender', 'İskender', S.isk || 0],
    ['cola', 'Toplam içecek', S.drinks || 0],
    ['fbox', 'Patates porsiyon', S.boxes || 0],
    ['sweet', 'Tatlı', S.sweets || 0],
    [null, 'Oynanan gün', S.days || 0],
    [null, 'Kaçan müşteri', S.lost || 0],
    [null, 'Kaçan müşteri (gün ort.)', S.days ? Math.round((S.lost || 0) / S.days) : 0]
  ];
  for (var i = 0; i < rows.length; i++) {
    var col = i % 2, row = (i / 2) | 0;
    var rx = x + 14 + col * 152, ry = y + 16 + row * rowSp;
    if (rows[i][0]) icon(rows[i][0], rx + 6, ry + 5, t);
    txt(rows[i][1], rx + 16, ry + 2, P.ui4);
    txt('' + rows[i][2], rx + 140, ry + 2, P.ink, { align: 'r' });
    ctx.globalAlpha = .25; hl(rx, ry + 12, 140, P.ui2); ctx.globalAlpha = 1;
  }
  var by = y + 22 + Math.ceil(rows.length / 2) * rowSp;
  txt('En iyi gün', x + 20, by, P.ui4);
  txt('$' + fmtMoney(S.best || 0), x + w - 20, by, P.au2, { align: 'r' });
  txt('Toplam kazanç', x + 20, by + satSp, P.ui4);
  txt('$' + fmtMoney(S.earned || 0), x + w - 20, by + satSp, P.red1, { align: 'r', sc: 1 });
  txt('Ödenen borç', x + 20, by + satSp * 2, P.ui4);
  txt('$' + fmtMoney(S.debtPaid || 0), x + w - 20, by + satSp * 2, P.ok, { align: 'r' });
  txt('Kalan borç', x + 20, by + satSp * 3, P.ui4);
  txt('$' + fmtMoney(G.debt), x + w - 20, by + satSp * 3, G.debt > 0 ? '#a83a2a' : P.ok, { align: 'r' });
  txt('Hijyen cezası', x + 20, by + satSp * 4, P.ui4);
  txt('$' + fmtMoney(S.fines || 0), x + w - 20, by + satSp * 4, '#a83a2a', { align: 'r' });
  txt('Hırsıza kaptırılan', x + 20, by + satSp * 5, P.ui4);
  txt('$' + fmtMoney(S.stolen || 0), x + w - 20, by + satSp * 5, '#a83a2a', { align: 'r' });
  /* borç ilerleme çubuğu */
  var pr = 1 - clamp(G.debt / DEBT_START, 0, 1);
  bar(x + 20, by + satSp * 6, w - 40, 8, pr, P.ok);
  txt(T('borç ödeme: %') + Math.round(pr * 100), x + w / 2, by + satSp * 6 + 1, P.ui5, { align: 'c' });
  if (button(x + w / 2 - 40, y + h - 22, 80, 18, 'KAPAT', P.red1, true)) { STATS.open = false; SFX.uiBack(); }
}

/* ---------------- GECE: hırsız kesiti ---------------- */
function drawThief(x, y, t, phase, running) {
  /* müşteri gövde ölçüleriyle, tamamen koyu kapüşonlu figür */
  var sway = (phase === 0 || running) ? Math.sin(t * 11) * 1.2 : 0;
  var bob = Math.sin(t * 2.2) * .8;
  x = Math.round(x + sway); y = Math.round(y + bob);
  var by = y - 30, bw = 26, hy = y - 42, hw = 12;

  var C0 = '#171b22', C1 = '#262d39', C2 = '#333c4b', C3 = '#454f61';

  ctx.globalAlpha = .38; ell(x, y + 1, 14, 3, '#000'); ctx.globalAlpha = 1;

  /* ---- gövde: uzun kapüşonlu ---- */
  ell(x, by + 5, bw / 2, 7, C0);
  fr(x - bw / 2, by + 5, bw, 26, C0);
  ell(x, by + 4, bw / 2 - 1, 6, C1);
  fr(x - bw / 2 + 1, by + 4, bw - 2, 26, C1);
  fr(x - bw / 2 + 1, by + 5, 7, 25, C2);
  ctx.globalAlpha = .28; fr(x + 3, by + 4, bw / 2 - 3, 27, '#000'); ctx.globalAlpha = 1;
  /* fermuar + cepler */
  vl(x, by + 6, 24, '#12161c');
  fr(x - 9, by + 20, 6, 4, C0);
  fr(x + 4, by + 20, 6, 4, C0);

  /* ---- kollar ---- */
  var ao = running ? Math.round(Math.sin(t * 15) * 2) : 0;
  fr(x - bw / 2 - 3, by + 8 + ao, 5, 22, C0);
  fr(x - bw / 2 - 3, by + 8 + ao, 4, 21, C1);
  fr(x + bw / 2 - 2, by + 8 - ao, 5, 22, '#12161c');
  /* eldivenli eller */
  ell(x - bw / 2 - 1, by + 29 + ao, 3, 3, '#0f1218');
  ell(x + bw / 2, by + 29 - ao, 3, 3, '#0f1218');

  /* ---- kapüşon ---- */
  ell(x, hy + 1, hw + 1, 12, C0);
  ell(x - 1, hy, hw, 11, C1);
  ell(x - 2, hy - 2, hw - 3, 8, C2);
  hl(x - 7, hy - 10, 13, C3);
  /* kapüşon boyun kısmı */
  fr(x - 8, hy + 9, 17, 6, C0);
  fr(x - 7, hy + 9, 15, 5, C1);

  /* ---- yüz gölgesi + gözler ---- */
  ell(x, hy + 2, hw - 4, 7, '#080a0e');
  ctx.globalAlpha = .9;
  fr(x - 6, hy, 4, 2, '#cfd8e2');
  fr(x + 3, hy, 4, 2, '#cfd8e2');
  ctx.globalAlpha = 1;
  px(x - 5, hy, '#ffffff'); px(x + 4, hy, '#ffffff');
  /* kapüşon ipleri */
  px(x - 5, hy + 12, '#5a6474'); px(x + 5, hy + 12, '#5a6474');
  px(x - 5, hy + 14, '#5a6474'); px(x + 5, hy + 14, '#5a6474');

  /* ---- para çuvalı ---- */
  var sx = x + 20, sy = by + 8 - ao + Math.round(Math.sin(t * 6) * 1.2);
  ctx.globalAlpha = .3; ell(sx, sy + 15, 8, 2, '#000'); ctx.globalAlpha = 1;
  ell(sx, sy + 11, 9, 8, '#5c4d31');
  ell(sx, sy + 9, 9, 8, '#8a7448');
  ell(sx - 2, sy + 7, 6, 5, '#a68d58');
  fr(sx - 4, sy - 1, 9, 5, '#4e4128');
  fr(sx - 3, sy, 7, 3, '#6b5a3a');
  txt('$', sx, sy + 6, '#f0d78a', { align: 'c', sc: 1 });
  /* çuvalı tutan kol */
  fr(x + bw / 2 - 2, sy + 2, 9, 5, '#12161c');
}

/* güvenlik kamerası — sağ üst köşe, tezgâha bakar */
function drawSecCam(t, alert) {
  var cx0 = 424, cy0 = 30;
  /* duvar ayağı */
  fr(cx0 + 10, cy0 - 2, 5, 8, '#3a4149');
  hl(cx0 + 10, cy0 - 2, 5, '#5f6a75');
  /* gövde: sola-aşağı bakıyor */
  fr(cx0, cy0 + 3, 15, 8, '#2b3037');
  fr(cx0 + 1, cy0 + 4, 13, 6, '#4a545f');
  hl(cx0 + 1, cy0 + 4, 13, '#6d7a86');
  /* lens */
  fr(cx0 - 4, cy0 + 5, 5, 5, '#1b1f26');
  disc(cx0 - 2, cy0 + 7, 2, '#0d1015');
  px(cx0 - 3, cy0 + 6, '#8fb4d8');
  /* LED */
  var on = Math.sin(t * 6) > 0;
  disc(cx0 + 12, cy0 + 6, 1, on ? '#ff4a3a' : '#5a2a26');
  if (on) { ctx.globalAlpha = .16; disc(cx0 + 12, cy0 + 6, 5, '#ff4a3a'); ctx.globalAlpha = 1; }
  /* görüş konisi */
  if (alert) {
    ctx.globalAlpha = .05 + .03 * Math.sin(t * 4);
    for (var i = 0; i < 46; i++) fr(cx0 - 4 - i, cy0 + 6 + Math.round(i * .55), 2, 2 + (i >> 2), '#cfe6f2');
    ctx.globalAlpha = 1;
  }
}

function drawNight(t) {
  var N = G.night;
  if (!N) { G.scene = 'intro'; G.sceneT = 0; return; }
  N.t += 1 / 60;

  /* --- dükkân, gece: usta evde, dükkân boş --- */
  NOCHEF = true;
  drawShopStatic(t, false);
  NOCHEF = false;
  ctx.globalAlpha = .62; fr(0, 0, W, LAY.floorY + 12, '#0a1030'); ctx.globalAlpha = 1;
  ctx.globalAlpha = .16; fr(0, 0, W, H, '#000018'); ctx.globalAlpha = 1;
  /* kepenk kapalı */
  drawShutter(1);
  /* ay ışığı huzmesi */
  ctx.globalAlpha = .07;
  for (var mI = 0; mI < 60; mI++) fr(120 + mI, 30 + mI, 34, 1, '#9fc8ff');
  ctx.globalAlpha = 1;

  var sec = N.sec;
  /* güvenlik donanımı */
  if (sec >= 3) drawWallCam(t, N.phase >= 1);
  if (sec >= 2 && N.phase >= 1) {
    /* alarm lambası — sol duvarda */
    var al = Math.sin(t * 14) > 0;
    var ax = 108, ay = 38;
    fr(ax, ay, 12, 7, '#2f3740');
    fr(ax + 1, ay + 1, 10, 5, '#454b52');
    ell(ax + 6, ay, 6, 4, al ? '#ff3a2a' : '#6a2018');
    if (al) {
      ctx.globalAlpha = .18; disc(ax + 6, ay, 20, '#ff3a2a'); ctx.globalAlpha = 1;
      ctx.globalAlpha = .07; fr(0, 0, W, LAY.floorY, '#ff2a1a'); ctx.globalAlpha = 1;
    }
  }
  if (sec >= 1) {
    /* kepenk kilidi */
    var lx = W / 2, ly = 112;
    fr(lx - 4, ly, 9, 7, '#8a929b'); fr(lx - 3, ly + 1, 7, 5, '#c7ced5');
    rc(lx - 3, ly - 4, 7, 5, '#8a929b');
    px(lx, ly + 3, '#5a636b');
  }

  /* --- fazlar --- */
  var ph = N.phase;
  if (ph === 0 && N.t > 1.7) { N.phase = 1; SFX.uiBack(); if (sec >= 2) { SFX.bell(); shake(2); } }
  if (ph === 1 && N.t > 3.4) {
    N.phase = 2;
    if (N.stole && !N.paid) {
      N.paid = true;
      G.money = Math.max(0, G.money - N.amount);
      G.stats.stolen = (G.stats.stolen || 0) + N.amount;
      SFX.fail(); shake(4); flash(.2, '#ff4a3a');
      saveAll();
    } else if (!N.stole) {
      SFX.levelup();
    }
  }

  /* hırsız hareketi */
  var TY = LAY.custSlots[0].y;
  var tx;
  if (N.phase === 0) tx = lerp(-34, 236, clamp(N.t / 1.7, 0, 1));
  else if (N.phase === 1) tx = 236 + Math.sin(N.t * 3) * 3;
  else {
    var k2 = clamp((N.t - 3.4) / 1.5, 0, 1);
    tx = N.stole ? lerp(236, W + 46, k2) : lerp(236, -46, k2);
  }
  /* el feneri hüzmesi */
  if (N.phase < 2) {
    ctx.globalAlpha = .10 + .04 * Math.sin(t * 9);
    for (var fb = 0; fb < 30; fb++) {
      fr(tx + 8 + fb, TY - 22 + Math.round(fb * .5), 3 + fb, 1, '#ffe9a0');
    }
    ctx.globalAlpha = 1;
    px(tx + 8, TY - 20, '#fff6c8');
  }
  drawThief(tx, TY, t, N.phase, N.phase === 2);

  /* çalınan para uçuşu */
  if (N.phase === 2 && N.stole && chance(.35)) {
    part({ x: tx, y: TY - 20, vx: rnd(-24, 24), vy: rnd(-44, -14), life: .9, col: P.au0, g: 90, sz: 2 });
  }

  psDraw();

  /* --- panel --- */
  ctx.globalAlpha = .55; fr(0, 0, W, 34, '#0a0a12'); ctx.globalAlpha = 1;
  txt(T('GECE — GÜN ') + (G.day - 1) + T(' BİTTİ'), W / 2, 6, P.ui1, { align: 'c' });
  if (N.phase >= 1) {
    txt(N.stole ? 'DÜKKÂNA GİREN VAR!' : 'GÜVENLİK İŞ BAŞINDA', W / 2, 18,
      N.stole ? P.bad : P.ok, { align: 'c', sc: 1 });
  }

  if (N.phase === 2 && N.t > 4.2) {
    var by2 = 176, bw2 = 250, bx2 = W / 2 - bw2 / 2;
    ctx.globalAlpha = .35; rrect(bx2 + 2, by2 + 3, bw2, 62, 4, '#000'); ctx.globalAlpha = 1;
    rrect(bx2, by2, bw2, 62, 4, N.stole ? '#5a1a14' : '#1a4a24');
    rrect(bx2 + 2, by2 + 2, bw2 - 4, 58, 3, P.ui0);
    rrectOut(bx2, by2, bw2, 62, 4, P.ui5);
    txt(N.line, W / 2, by2 + 8, P.ink, { align: 'c' });
    if (N.stole) {
      txt('-$' + fmtMoney(N.amount), W / 2, by2 + 20, P.bad, { align: 'c', sc: 1 });
      txt(N.sec === 0 ? T('Dükkânda hiç güvenlik yok.') : (T(TUN.secName(G)) + T(' yetmedi.')),
        W / 2, by2 + 34, P.ui3, { align: 'c' });
    } else {
      txt(N.sec === 0 ? T('Şansın varmış!') : T(TUN.secName(G)) + T(' işe yaradı.'),
        W / 2, by2 + 22, P.ok, { align: 'c' });
      txt('Kasada tek kuruş eksilmedi.', W / 2, by2 + 34, P.ui3, { align: 'c' });
    }
    if (button(W / 2 - 46, by2 + 42, 92, 16, T('GÜN ') + G.day, '#3f8a4a', true)) {
      SFX.ui(); G.night = null; G.scene = 'intro'; G.sceneT = 0;
    }
  }
  ftDraw();
}

/* ============================================================
   BAŞARIM EKRANI ve BİLDİRİM
   Rozetler gruplara ayrilir; alt seritte secili/uzerine gelinen
   basarimin adi, aciklamasi ve ilerlemesi durur. Kilitli olanlarin
   ikonu soluk, GIZLI olanlar acilana kadar soru isareti.
   ============================================================ */
var BSP = { open: false, sec: null, kay: 0 };

var BS_GRUP = [
  ['servis',    'SERVİS'],
  ['para',      'PARA'],
  ['borc',      'BORÇ'],
  ['dukkan',    'DÜKKÂN'],
  ['sehir',     'ŞEHİR'],
  ['usta',      'USTALIK'],
  ['demirkent', 'DEMİRKENT'],
  ['gizli',     'GİZLİ']
];
var BS_KADEME = ['#b0763a', '#b8c0c8', '#e8c05a'];   /* bronz / gumus / altin */

/* 16x16 rozet. acik: kazanildi. sec: uzerinde/secili. */
function bsRozet(x, y, b, acik, sec, t) {
  var hlk = BS_KADEME[(b.kademe || 1) - 1] || BS_KADEME[0];
  if (acik) {
    rrect(x, y, 16, 16, 3, shadeCol(hlk, .45));
    rrect(x + 1, y + 1, 14, 14, 3, '#3a3026');
    rrectOut(x, y, 16, 16, 3, hlk);
    icon(b.ikon, x + 8, y + 8, t);
  } else {
    rrect(x, y, 16, 16, 3, '#171310');
    rrect(x + 1, y + 1, 14, 14, 3, '#231d17');
    rrectOut(x, y, 16, 16, 3, '#4a4038');
    if (b.gizli) {
      txt('?', x + 8, y + 5, '#8a7a64', { align: 'c' });
    } else {
      /* icon() kendi icinde globalAlpha'yi 1'e cekiyor; disaridan
         saydamlik vermek ise yaramiyordu. Ikonu ciz, ustune perde ger. */
      icon(b.ikon, x + 8, y + 8, t);
      ctx.globalAlpha = .82; fr(x + 1, y + 1, 14, 14, '#231d17'); ctx.globalAlpha = 1;
      /* asma kilit: kilitli oldugu bir bakista okunmali */
      rc(x + 7, y + 5, 3, 4, '#7a6c58');            /* kilit kulpu */
      fr(x + 6, y + 8, 5, 4, '#6a5c48');            /* govde */
      fr(x + 6, y + 8, 5, 3, '#a8946e');
      px(x + 8, y + 10, '#463c2c');                 /* anahtar deligi */
    }
    /* ilerleme: rozetin altina ince cizgi */
    var o = basarimOran(b);
    if (o > 0) fr(x + 2, y + 14, Math.max(1, Math.round(12 * o)), 1, shadeCol(hlk, .9));
  }
  if (sec) {
    ctx.globalAlpha = .55 + .45 * Math.sin(t * 6);
    rrectOut(x - 1, y - 1, 18, 18, 4, P.au0);
    ctx.globalAlpha = 1;
  }
}

function drawBasarimPanel(t) {
  var kk = panelKutu(14, 234), y = kk[0], h = kk[1];
  var x = 26, w = W - 52;
  var seritH = 32;
  /* 8 grup + alt serit dar ekrana da sigmali: satir yuksekligi kalan
     yerden hesaplanir, sabit degerle son grup seridin altinda kaliyordu. */
  var basY = y + 14, kalan = (y + h - 6 - seritH) - basY;
  var rowH = clamp(Math.floor(kalan / BS_GRUP.length), 17, 24);
  ctx.globalAlpha = .84; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
  panel(x, y, w, h, 'BAŞARIMLAR');

  var acikN = basarimSayisi();
  /* sayac X dugmesinin SOLUNDA durur, ustune binmemeli */
  txt(acikN + ' / ' + BASARIM.length, x + w - 32, y + 4,
      acikN >= BASARIM.length ? P.au3 : P.ui3, { align: 'r' });
  bar(x + 12, y + 4, 88, 6, acikN / BASARIM.length, P.au1);

  var hoverB = null;
  var ry = basY;
  for (var g = 0; g < BS_GRUP.length; g++) {
    var gid = BS_GRUP[g][0];
    txt(BS_GRUP[g][1], x + 10, ry + (rowH - 8) / 2 - 1, P.ui3);
    var bx = x + 78, n = 0;
    for (var i = 0; i < BASARIM.length; i++) {
      var b = BASARIM[i];
      if (b.grup !== gid) continue;
      var px0 = bx + n * 19, py0 = ry + (rowH - 16) / 2;
      var uz = inRect(IN.x, IN.y, px0, py0, 17, 17);
      if (uz) hoverB = b;
      bsRozet(px0, py0, b, basarimAcik(b.id), uz || BSP.sec === b.id, t);
      if (uz && IN.pressed) { BSP.sec = b.id; SFX.ui(); }
      n++;
    }
    ctx.globalAlpha = .18; hl(x + 10, ry + rowH - 2, w - 20, P.ui2); ctx.globalAlpha = 1;
    ry += rowH;
  }

  /* ---- alt serit: secili basarimin ayrintisi ---- */
  var sy = y + h - seritH - 3;
  var det = hoverB || basarimById(BSP.sec);
  if (!det) {                                   /* hicbiri secili degil: ilk kilitliyi goster */
    for (var k = 0; k < BASARIM.length && !det; k++)
      if (!basarimAcik(BASARIM[k].id) && !BASARIM[k].gizli) det = BASARIM[k];
    if (!det) det = BASARIM[0];
  }
  rrect(x + 6, sy, w - 12, seritH, 3, '#211a14');
  rrectOut(x + 6, sy, w - 12, seritH, 3, P.ui4);
  var dAcik = basarimAcik(det.id), gizliKilit = det.gizli && !dAcik;
  bsRozet(x + 12, sy + (seritH - 16) / 2, det, dAcik, false, t);
  /* serit KOYU: yazilar acik renk olmali, P.ink zeminle ayni tondaydi */
  txt(gizliKilit ? T('GİZLİ BAŞARIM') : bsAd(det), x + 34, sy + 5, dAcik ? P.au0 : P.ui0);
  txt(gizliKilit ? T('Bulunca açılır') : bsAc(det), x + 34, sy + 16, P.ui1);
  if (dAcik) {
    txt(T('Gün ') + G.bs[det.id], x + w - 16, sy + 5, P.ok, { align: 'r' });
  } else if (!gizliKilit) {
    var v = 0;
    try { v = Math.floor(det.oku(G.stats || {}, G) || 0); } catch (e) { v = 0; }
    txt(Math.min(v, det.hedef) + ' / ' + det.hedef, x + w - 16, sy + 5, P.ui1, { align: 'r' });
    bar(x + w - 96, sy + 17, 80, 6, basarimOran(det), P.au1);
  }
  if (button(x + w - 24, y + 2, 18, 12, 'X', P.red1)) { BSP.open = false; BSP.sec = null; SFX.uiBack(); }
}

/* Acilis bildirimi: alt ortada, kayarak girer. Kuyruk sirayla akar. */
function drawBasarimToast(t, dt) {
  if (!BSQ.kuyruk.length) return;
  /* Panel acikken cizme: alt serit ayni yerde, ustuste biniyorlardi.
     Kuyrukta bekler, panel kapaninca akar. */
  if (BSP.open || STATS.open || SESP.open) return;
  var it = BSQ.kuyruk[0];
  it.t += dt;
  var sure = 3.4;
  if (it.t > sure) { BSQ.kuyruk.shift(); return; }
  var gir = clamp(it.t / .28, 0, 1);
  var cik = clamp((sure - it.t) / .3, 0, 1);
  var k = Math.min(gir, cik);
  var w = 176, h = 30;
  var bx = Math.round(W / 2 - w / 2);
  var by = Math.round(H - VIEW.bot - 12 - h * k);
  ctx.globalAlpha = k;
  ctx.globalAlpha = k * .40; rrect(bx + 2, by + 3, w, h, 4, '#000'); ctx.globalAlpha = k;
  rrect(bx, by, w, h, 4, '#4a3a1e');
  rrect(bx + 1, by + 1, w - 2, h - 2, 4, '#2b2118');
  rrectOut(bx, by, w, h, 4, P.au0);
  bsRozet(bx + 7, by + 7, it.b, true, false, t);
  txt(T('BAŞARIM AÇILDI'), bx + 29, by + 6, P.au2);
  /* balon KOYU zeminli: P.ink (#241a20) neredeyse gorunmuyordu */
  txt(bsAd(it.b), bx + 29, by + 17, P.ui0);
  /* kucuk parlama */
  ctx.globalAlpha = k * (.25 + .25 * Math.sin(t * 7));
  rrectOut(bx - 1, by - 1, w + 2, h + 2, 5, P.au1);
  ctx.globalAlpha = 1;
}

/* ---------------- RAKIP BAHIS PANELI ----------------
   Oyun DURMAZ: panel acikken musteriler gelmeye devam eder, sure
   isler. Kabul etmek zorunlu degil; reddetmenin cezasi yok. */
function drawBahisPanel(t) {
  var R = G.rakip;
  if (!R || R.faz !== 'teklif') return;
  var pw = 230, ph = 96;
  var px0 = Math.round(W / 2 - pw / 2), py0 = 22;
  panel(px0, py0, pw, ph);

  /* KIM konusuyor: kucuk portre + isim. Eskiden yalniz bir baslik
     vardi, konusan belli degildi. */
  rakipYuz(px0 + 15, py0 + 16);
  txt(T('KARŞIDAKİ DÖNERCİ'), px0 + 30, py0 + 8, P.red1);

  /* 1) laf atar  2) iddiayi soyler  3) parayi masaya koyar
     RENK: iddia ve para KREM panelin uzerine P.ui1 (#e5cfa4) ve
     P.au0 (#fff2a8) ile yaziliyordu — kontrast 1.38 ve 1.03, yani
     pratikte gorunmuyorlardi. Iki satir da kendi TABAN serisine
     tasindi; yazi koyu, zemin acik. */
  txt(T(R.selam), px0 + 30, py0 + 19, P.ui3);
  var sy0 = py0 + 30, sh0 = 26;
  rrect(px0 + 8, sy0, pw - 16, sh0, 3, P.ui2);
  rrect(px0 + 9, sy0 + 1, pw - 18, sh0 - 2, 3, P.ui1);
  hl(px0 + 11, sy0 + 1, pw - 22, '#f2e3c2');
  txt(bahisMetni(R), px0 + 13, sy0 + 4, P.ui5);          /* kontrast 10.5 */
  txt(T('Kaybeden ötekine $') + fmtMoney(R.para) + T(' verir.'),
      px0 + 13, sy0 + 15, P.red3);                        /* kontrast 7.6 */

  /* kalan sure: sabirsizlaniyor */
  var kalanO = clamp(1 - R.t / 20, 0, 1);
  fr(px0 + 10, py0 + 62, pw - 20, 2, 'rgba(0,0,0,.45)');
  fr(px0 + 10, py0 + 62, Math.round((pw - 20) * kalanO), 2, kalanO < .3 ? P.bad : P.ui3);
  if (kalanO < .35) txt(T('...cevap bekliyor'), W / 2, py0 + 66, P.ui4, { align: 'c' });

  /* Cevaplar CUMLE: 'VAR'/'YOK' ne dedigini anlatmiyordu. */
  if (button(px0 + 10, py0 + 74, 100, 16, T('Girdim bahse'), '#3f8a4a', true)) rakipCevap(true);
  if (button(px0 + pw - 110, py0 + 74, 100, 16, T('Bugün olmaz'), '#6b4a3a', true)) rakipCevap(false);
}

/* Panelde konusani gosteren kucuk portre. */
function rakipYuz(x, y) {
  fr(x - 7, y - 7, 14, 14, '#b98b6a');
  fr(x - 7, y - 7, 14, 3, '#a87a54');
  fr(x - 8, y - 9, 16, 4, '#2a2018');            /* sac */
  fr(x - 8, y - 7, 2, 5, '#2a2018'); fr(x + 6, y - 7, 2, 5, '#2a2018');
  fr(x - 8, y - 11, 16, 3, '#2f6a8a');           /* kep */
  px(x - 3, y - 1, '#1a1410'); px(x + 2, y - 1, '#1a1410');
  fr(x - 4, y - 3, 3, 1, '#2a2018'); fr(x + 1, y - 3, 3, 1, '#2a2018');
  fr(x - 2, y + 3, 5, 2, '#2a2018');             /* biyik */
}

/* Gun sonu ekraninda bahis sonucu. */
function bahisSonucSatiri(y) {
  var S = G.bahisSonuc;
  if (!S) return y;
  var ms = S.kazandi
    ? T('Bahsi kazandın! +$') + fmtMoney(S.para)
    : T('Bahsi kaybettin. -$') + fmtMoney(S.para);
  txt(ms, W / 2, y, S.kazandi ? P.ok : P.bad, { align: 'c' });
  y += 11;
  /* 'kacan' bahsinde olculen deger NEGATIF tutuluyor (0 kacan kazandirir);
     ekranda gercek sayiyi gostermek icin isareti cevriliyor. */
  var gost = S.tip === 'kacan' ? -S.deger : S.deger;
  txt(T('hedef ') + S.hedef + T('  •  senin: ') + gost, W / 2, y, P.ui3, { align: 'c' });
  y += 12;
  if (S.kapandi) {
    txt(T('RAKİP DÜKKÂNI KAPATTI'), W / 2, y, P.au0, { align: 'c' });
    y += 12;
  }
  return y;
}

/* Siparis balonunda "bunu istemiyorum" rozeti: kucuk malzeme
   simgesi + uzerinde kirmizi capraz. Yazi sigmiyor (balon 22 px),
   simge + capraz tek bakista okunuyor. */
/* SARILMIŞ DÜRÜMÜN ETİKETİ — tezgâhta hangisi hangisi?
   Üç dürüm yan yana sarılınca ayırt edilemiyordu. Artık her sarılmış
   dürümün altında küçük bir fiş var: eksik malzemeler yasak çipi
   olarak, sos kendi renginde. Sipariş balonundaki DİLİN aynısı —
   oyuncu balonda gördüğü işareti tezgâhta arıyor, okumuyor bile.
   Yuva genişliği 3 tezgâhta ~28 piksel: çip aralığı ona göre. */
function yokCip(x, y, m) {
  var renk = m === 'pickle' ? '#5a9a2c' : (m === 'yogurt' ? '#f4f8fb' : '#f0c04a');
  disc(x, y, 4, '#c0281c');                 /* yasak halkası */
  disc(x, y, 3, renk);                      /* malzemenin RENGİ: kimliği o taşıyor */
  if (m === 'pickle') { px(x - 1, y - 1, '#bfe07a'); px(x + 1, y, '#bfe07a'); }
  else if (m === 'yogurt') { px(x - 1, y + 1, '#cdd8e2'); }
  else { px(x - 1, y - 1, '#ffe6a0'); px(x + 1, y + 1, '#d99a2e'); }
  ln(x - 3, y - 3, x + 3, y + 3, '#c0281c');
  px(x - 3, y - 3, '#e2483a'); px(x + 3, y + 3, '#e2483a');
}
function sosCip(x, y, tip) {
  var renk = tip === 'hot' ? '#d8352c' : (tip === 'garlic' ? '#efe7d2' : '#f0b83c');
  disc(x, y, 4, '#2a2018');
  disc(x, y, 3, renk);
  px(x - 1, y - 1, tip === 'hot' ? '#ff8a70' : '#ffffff');
  px(x + 1, y + 1, tip === 'hot' ? '#8e1c14' : '#c9bfa4');
}
function wrapEtiket(cx, y, w, dar) {
  var d = (typeof wrapKimlik === 'function') ? wrapKimlik(w) : null;
  if (!d || !d.length) return;
  var ad = dar ? 9 : 11;                    /* çip aralığı */
  var tw = d.length * ad + 3;
  var x0 = Math.round(cx - tw / 2);
  rrect(x0, y, tw, 11, 3, 'rgba(18,12,9,.88)');
  rrectOut(x0, y, tw, 11, 3, 'rgba(255,220,140,.30)');
  for (var i = 0; i < d.length; i++) {
    var cxi = x0 + 2 + i * ad + (ad - 1) / 2;
    if (d[i].tip === 'sos') sosCip(cxi, y + 5, d[i].m);
    else yokCip(cxi, y + 5, d[i].m);
  }
}

/* YASAK İŞARETİ — 13 piksel, trafik levhası mantığı.
   Eskisi 10 pikseldi ve malzemenin üstüne İKİ çapraz çiziyordu:
   turşu / yoğurt / patates o boyutta zaten zor ayrılıyordu, çaprazlar
   da kalanı kapatıyordu — oyuncu neyi istemediğini okuyamıyordu.
   Şimdi: krem tabak + BÜYÜK malzeme + kırmızı halka + TEK eğik çubuk.
   Halka "yasak"ı taşıyor, malzeme açıkta kalıyor. */
function yokRozet(x, y, m) {
  disc(x, y, 6, '#c0281c');            /* halka */
  disc(x, y, 4, '#f7efdc');            /* tabak */
  if (m === 'pickle') {
    ell(x, y, 4, 3, '#4a7a22');        /* turşu dilimi: yeşil, çekirdekli */
    ell(x, y, 3, 2, '#6aa032');
    px(x - 1, y - 1, '#bfe07a'); px(x + 1, y, '#bfe07a'); px(x, y + 1, '#bfe07a');
  } else if (m === 'yogurt') {
    ell(x, y + 1, 4, 2, '#e8eef4');    /* yoğurt topağı: beyaz kaşık dolusu */
    ell(x, y - 1, 3, 2, '#ffffff');
    px(x - 2, y + 1, '#cdd8e2'); px(x + 2, y + 1, '#cdd8e2');
  } else {
    fr(x - 3, y - 2, 2, 5, '#d99a2e'); /* patates: üç kalın çubuk */
    fr(x, y - 3, 2, 6, '#f4cc60');
    fr(x + 2, y - 1, 2, 4, '#e8b64a');
    px(x, y - 3, '#ffe6a0');
  }
  /* tek eğik çubuk: 2 piksel kalın, ikonu kapatmaz */
  ln(x - 4, y - 4, x + 4, y + 4, '#c0281c');
  ln(x - 3, y - 4, x + 4, y + 3, '#e2483a');
  ring(x, y, 6, '#8e1c14');            /* dış kenar: kremin üstünde belli olsun */
}
