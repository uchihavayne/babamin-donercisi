/* ============================================================
   DÖNER EFSANESİ — prologue.js
   Oyunun başında bir kez oynanan hikâye kesiti.
   Her sahne kendi çizimini yapar; metin harf harf yazılır.
   ============================================================ */
'use strict';

var PRO = { i: 0, t: 0, ch: 0, done: false };

/* HİKÂYE — tek bir kural etrafında kurulu.
   Eski metin üç yerde anlamsızdı: "bir dürüm bir insanı doyurur" hiçbir
   şey söylemeyen bir doğruydu; "ocak soğumadı" üç ay kapalı kalan
   dükkân için çelişkiydi; 5 milyonluk borç da sebepsiz, "babamın
   sakladığı borç" diye havada kalıyordu.
   Şimdi: babanın KURALI (kimse aç çıkmaz) -> kayıp -> borç o kuralın
   BEDELİ -> oğul hem dükkânı hem kuralı devralır. Oyundaki aç misafir
   mekaniği de artık hikâyenin kendisi. Eski metin:
   yedek/2026-09-11-hikaye-oncesi/prologue.js */
var PRO_SCENES = [
  {
    dur: 13.0,
    lines: ['Babam bu tezgâhta kırk yıl döner kesti.', 'Ocağı sabah beşte yakar,', 'kepengi gece yarısı indirirdi.'],
    draw: function (t, k) { proShopDay(t, k); }
  },
  {
    dur: 12.0,
    lines: ['"Bu kapıdan kimse aç çıkmaz," derdi.', 'Cebinde parası olsun, olmasın.'],
    draw: function (t, k) { proFather(t, k); }
  },
  {
    dur: 11.0,
    lines: ['Geçen kış onu kaybettik.', 'Kepenk üç ay açılmadı.'],
    draw: function (t, k) { proClosed(t, k); }
  },
  {
    dur: 14.0,
    lines: ['Sonra icradan bir yazı geldi.', 'Yıllarca kimseyi aç göndermemenin bedeli:', '$5.000.000'],
    draw: function (t, k) { proDebt(t, k); }
  },
  {
    dur: 13.0,
    lines: ['Satmamı söylediler. Satmadım.', 'Ocağı yaktım, kepengi kaldırdım.', 'Bu kapıdan yine kimse aç çıkmayacak.'],
    draw: function (t, k) { proKey(t, k); }
  }
];

/* ---------------- sahne çizimleri ---------------- */

/* Sahneler blender/models/hikaye.py'de tasarlandı ve buraya birebir
   aynı kadrajla taşındı: Blender x -200..200, z -61..89  ->  çerçeve
   (40,44) 400x150. Aşağıdaki dönüştürücüler sayesinde Python dosyasındaki
   sayılar burada da aynen okunuyor; ikisi yan yana karşılaştırılabilsin.

   Blender'da z YUKARI artar, tuvalde y AŞAĞI artar - pb() bunu çevirir. */
function pbx(x) { return 240 + x; }
function pby(z) { return 133 - z; }
function pb(x0, z0, x1, z1, c) { fr(pbx(x0), pby(z1), x1 - x0, z1 - z0, c); }
function pbA(x0, z0, x1, z1, c, a) {
  ctx.globalAlpha = a; fr(pbx(x0), pby(z1), x1 - x0, z1 - z0, c); ctx.globalAlpha = 1;
}
function pbE(cx, cz, rx, rz, c) { ell(pbx(cx), pby(cz), rx, rz, c); }

/* Durağan katmanlar bir kez çizilip saklanıyor. Bir sahnede ~900
   dikdörtgen var; hepsini her karede yeniden çizmek gereksiz, iki
   drawImage yetiyor. Metin buraya girmiyor: txt() içeride T()
   uyguladığı için önbelleğe alınsa dil değişiminde bayatlardı. */
var PRO_KAT = {};
function proKat(ad, ciz) {
  var c = PRO_KAT[ad];
  if (c) return c;
  c = document.createElement('canvas');
  c.width = 400; c.height = 150;
  var eski = ctx;
  ctx = c.getContext('2d');
  ctx.imageSmoothingEnabled = false;
  ctx.translate(-40, -44);
  ciz();
  ctx = eski;
  PRO_KAT[ad] = c;
  return c;
}
function proCiz(ad, ciz) { ctx.drawImage(proKat(ad, ciz), 40, 44); }

/* uçan kuşlar */
function proBirds(t, gx, gy, gw, n, sp) {
  for (var b = 0; b < n; b++) {
    var u = ((t * sp + b * 0.31) % 1.25) - 0.12;
    if (u < 0 || u > 1) continue;
    var bx = gx - 10 + u * (gw + 20);
    var by = gy + 8 + b * 7 + Math.sin(t * 2 + b) * 3;
    var f = Math.sin(t * 9 + b * 2) > 0 ? 1 : 0;
    ctx.globalAlpha = .55;
    if (f) { ln(bx - 3, by, bx, by - 2, '#3a4a56'); ln(bx, by - 2, bx + 3, by, '#3a4a56'); }
    else { ln(bx - 3, by - 1, bx, by, '#3a4a56'); ln(bx, by, bx + 3, by - 1, '#3a4a56'); }
    ctx.globalAlpha = 1;
  }
}

/* Döner şişi. Blender: hikaye.py -> koni() + mat_nx(ET).
   Ton, oyunun kendi nx mantığıyla veriliyor: yatay konum -> parlaklık,
   ışık kaynağı değil. Böylece dönerken bantlar yerinde kalıyor. */
/* Etin siluet profili: 0 = tepe, 1 = taban. Düz koni bir tahta havuç
   gibi duruyordu; gerçek döner üstte dar başlar, üst üçte birinde
   ŞİŞER, sonra aşağı doğru daralır. */
var PRO_SIS_PROFIL = [.50, .74, .90, .99, 1.00, .97, .91, .83, .73, .61, .47, .31, .16];

function proSis(cx, z0, z1, r0, r1, t) {
  var n = z1 - z0, sx = pbx(cx), sy = pby(z1), m, b;
  var bant = [[-1.00, -0.58, .60], [-0.58, -0.18, .82], [-0.18, .24, 1.08],
              [.24, .62, 1.30], [.62, 1.00, .88]];
  var son = PRO_SIS_PROFIL.length - 1;
  for (m = 0; m < n; m++) {
    var v = m / (n - 1);                         /* 0 tepe, 1 taban */
    var fi = v * son, f0 = Math.min(son, fi | 0);
    var pr = PRO_SIS_PROFIL[f0] +
             (PRO_SIS_PROFIL[Math.min(f0 + 1, son)] - PRO_SIS_PROFIL[f0]) * (fi - f0);
    var rr = (r1 + (r0 - r1) * pr) * (1 + .035 * Math.sin(v * 11 + t * .8));
    var w2 = Math.max(1, Math.round(rr));
    var zz = z1 - m;
    var lay = Math.sin(zz * .62 + Math.sin(zz * .19) * 1.6);
    var dilim = ((zz % 7) + 7) % 7 < 1 ? -.16 : 0;   /* et katmanı çizgisi */
    /* koyu kontur: koni, koyu iç mekânda erimesin */
    fr(sx - w2 - 1, sy + m, w2 * 2 + 2, 1, '#40200a');
    for (b = 0; b < 5; b++) {
      var xa = Math.round(sx + bant[b][0] * w2), xb = Math.round(sx + bant[b][1] * w2);
      if (xb > xa) fr(xa, sy + m, xb - xa, 1, meatCol(.85, bant[b][2] + lay * .10 + dilim));
    }
    /* dış kabuk: sağ kenarda kızarmış ince şerit */
    fr(sx + w2 - 2, sy + m, 2, 1, meatCol(.95, .46 + lay * .06));
  }
  /* dönen dikiş: koninin döndüğünü gösteren tek çizgi */
  var dk = Math.sin(t * 1.4) * .72;
  ctx.globalAlpha = .34;
  for (m = 2; m < n - 2; m++) {
    var v3 = 1 - m / (n - 1);
    var w3 = Math.max(1, Math.round(r1 + (r0 - r1) * v3));
    px(sx + Math.round(dk * w3), sy + m, '#5a3418');
  }
  ctx.globalAlpha = 1;
}

/* Yaya/müşteri: Blender'daki blok figürlerin canlandırılmış hâli.
   faz>0 ise yürüyor (bacaklar makaslıyor), 0 ise duruyor. */
function proKisi(bx, ust, alt, ten, sac, faz, yuru) {
  var bacak = yuru ? Math.round(Math.sin(faz) * 3) : 0;
  var zip = yuru ? (Math.sin(faz * 2) > 0 ? 1 : 0) : 0;
  pbA(bx - 9, -41, bx + 11, -38, '#000000', .35);
  pb(bx - 6 - bacak, -38, bx - 1 - bacak, -24, alt);
  pb(bx + 1 + bacak, -38, bx + 6 + bacak, -24, alt);
  pb(bx - 7, -26 + zip, bx + 7, -22 + zip, alt);
  pb(bx - 7, -22 + zip, bx + 7, -6 + zip, ust);
  pb(bx + 6, -20 + zip, bx + 9, -10 + zip, ust);          /* kol */
  pb(bx - 5, -6 + zip, bx + 5, 2 + zip, ten);
  pb(bx - 6, 1 + zip, bx + 6, 5 + zip, sac);
}


/* ============================================================
   1) ESKİ GÜNLER — dükkân çalışıyor, sokak canlı
   ============================================================ */
function pro1Arka() {
  var i, r, c, x0, x1, h, wx, wz, B;

  /* --- gökyüzü: sabah, ufukta sıcak --- */
  var gok = [[72, 96, '#5e8fbc'], [56, 72, '#72a2c9'], [42, 56, '#8ab7d6'],
             [28, 42, '#a4cbdf'], [14, 28, '#c0dbe4'], [0, 14, '#dbe4d8'],
             [-62, 0, '#f0e0bc']];
  for (i = 0; i < gok.length; i++) pb(-230, gok[i][0], 230, gok[i][1], gok[i][2]);
  pbE(150, 74, 22, 22, '#f6e6bc');
  pbE(150, 74, 15, 15, '#fdf2d2');
  pbE(150, 74, 9, 9, '#fffbe8');
  var bul = [[-150, 70, 44, 7, '#e8f2f6', '#c2d8e6'],
             [-58, 80, 30, 6, '#e8f2f6', '#c2d8e6'],
             [54, 84, 40, 6, '#f0f6f8', '#cadfea']];
  for (i = 0; i < bul.length; i++) {
    B = bul[i];
    pb(B[0] - B[2], B[1], B[0] + B[2], B[1] + B[3], B[4]);
    pb(B[0] - B[2] + 4, B[1], B[0] + B[2] - 8, B[1] + B[3] - 3, B[5]);
  }

  /* --- uzak siluet: puslu, mavimsi (havadan perspektif) --- */
  var U1 = '#9db6c6', U2 = '#8aa7ba', U3 = '#b2c6d2';
  var uzak = [[-238, -186, 30], [-192, -150, 48], [-156, -112, 24],
              [-118, -70, 40], [-76, -30, 20], [-36, 14, 34], [10, 56, 16],
              [52, 104, 38], [98, 148, 26], [142, 196, 44], [188, 238, 22]];
  for (i = 0; i < uzak.length; i++) {
    x0 = uzak[i][0]; x1 = uzak[i][1]; h = uzak[i][2];
    pb(x0, -40, x1, h, U1);
    pb(x0 - 2, h, x1 + 2, h + 3, U3);
    for (r = 0; r < ((h + 34) / 13) | 0; r++)
      for (c = 0; c < Math.max(1, ((x1 - x0) / 12) | 0); c++)
        pb(x0 + 5 + c * 12, -34 + r * 13, x0 + 10 + c * 12, -28 + r * 13, U2);
  }
  /* cami: kubbe + iki minare — şehri yerine oturtan siluet */
  pbE(128, 44, 26, 22, U3);
  pb(98, 36, 158, 46, U1);
  pb(126, 62, 130, 72, U3);
  for (i = 0; i < 2; i++) {
    var mx = i ? 156 : 102;
    pb(mx - 3, 36, mx + 3, 84, U3);
    pb(mx - 5, 76, mx + 5, 80, U1);
    pb(mx - 2, 84, mx + 2, 92, U3);
  }

  /* --- orta sıra binaları --- */
  var O1 = '#7d838a', O2 = '#686e75', O3 = '#949aa0', O4 = '#4a5663';
  var orta = [[-236, -168, 28], [-172, -104, 52], [-108, -50, 20],
              [42, 96, 44], [100, 158, 26], [162, 236, 50]];
  for (i = 0; i < orta.length; i++) {
    x0 = orta[i][0]; x1 = orta[i][1]; h = orta[i][2];
    pb(x0, -40, x1, h, O1);
    pb(x1 - 7, -40, x1, h, O2);                 /* sağ gölge */
    pb(x0, -40, x0 + 4, h, O3);                 /* sol ışık */
    pb(x0 - 3, h, x1 + 3, h + 4, O3);           /* korniş */
    pb(x0 - 3, h - 2, x1 + 3, h, O2);
    for (r = 0; r < ((h + 36) / 15) | 0; r++)
      for (c = 0; c < Math.max(1, ((x1 - x0) / 15) | 0); c++) {
        wx = x0 + 6 + c * 15; wz = -32 + r * 15;
        if (wz + 9 > h - 6) continue;
        pb(wx, wz, wx + 7, wz + 9, O4);
        pb(wx - 1, wz - 2, wx + 8, wz, O3);
      }
  }
  pb(-150, 52, -128, 66, O2);                   /* su deposu */
  pb(-146, 46, -143, 52, O2);
  pb(-135, 46, -132, 52, O2);
  for (i = 0; i < 2; i++) {
    var ax = i ? 198 : 180;
    pb(ax, 50, ax + 2, 64, O2);
    pb(ax - 5, 61, ax + 7, 63, O2);
  }

  /* --- yakın sıra: dükkânın komşuları --- */
  var Y1 = '#6b6152', Y2 = '#544c40', Y3 = '#8a8070', Y4 = '#2c3742', Y5 = '#e8bd72';
  var yak = [[-236, -100, 38], [100, 236, 34]];
  for (i = 0; i < 2; i++) {
    x0 = yak[i][0]; x1 = yak[i][1]; h = yak[i][2];
    pb(x0, -38, x1, h, Y1);
    pb(x0, h, x1, h + 5, Y3);
    pb(x0, h - 3, x1, h, Y2);
    pb(x0, -38, x0 + 3, h, Y3);
    pb(x1 - 6, -38, x1, h, Y2);
    pb(x0, -8, x1, -6, Y2);
    pb(x0, -38, x1, -28, Y2);                   /* zemin kat dükkânı */
    var n = ((x1 - x0) / 30) | 0;
    for (c = 0; c < n; c++)
      for (r = 0; r < 2; r++) {
        wx = x0 + 12 + c * 30; wz = -24 + r * 20;
        pb(wx, wz, wx + 12, wz + 13, (c + r * 3 + i) % 4 === 0 ? Y5 : Y4);
        pb(wx + 5, wz, wx + 7, wz + 13, Y2);
        pb(wx - 2, wz + 13, wx + 14, wz + 15, Y3);
        if (r === 1) {
          for (var b2 = 0; b2 < 5; b2++) pb(wx - 1 + b2 * 3, wz - 7, wx + b2 * 3, wz - 1, Y2);
          pb(wx - 3, wz - 1, wx + 15, wz + 1, Y3);
        }
      }
  }

  /* --- sokak: asfalt / bordür yüzü / kaldırım üstü --- */
  pb(-240, -61, 240, -48, '#3b4046');
  for (i = 0; i < 10; i++) pb(-224 + i * 48, -57, -200 + i * 48, -55, '#c9c093');
  pb(-240, -48, 240, -42, '#6d6d64');           /* bordür yüzü */
  pb(-240, -42, 240, -40, '#adada0');           /* kenar ışığı */
  pb(-240, -40, 240, -38, '#8f8f84');           /* kaldırımın üstü */
  for (i = 0; i < 11; i++) pb(-224 + i * 46, -42, -223 + i * 46, -38, '#7c7c72');
  for (i = 0; i < 4; i++) pb(128 + i * 5, -50, 130 + i * 5, -43, '#4a4a44');

  /* --- dükkânın içi (en arkada) --- */
  pb(-86, -32, 86, 24, '#20130c');
  var kat = [[-32, -18, '#4a2e18'], [-18, -4, '#3a2313'],
             [-4, 10, '#2e1c10'], [10, 24, '#241509']];
  for (i = 0; i < kat.length; i++) pb(-86, kat[i][0], 86, kat[i][1], kat[i][2]);
  pb(-80, 0, -16, 3, '#6b4122');                /* raf */
  for (i = 0; i < 8; i++)
    pb(-76 + i * 7, 3, -72 + i * 7, 11, ['#3f79c0', '#c9302a', '#d8ac35'][i % 3]);
  var lmb = [-56, -6, 46];
  for (i = 0; i < 3; i++) {
    var lx = lmb[i];
    pb(lx - 1, 16, lx + 1, 24, '#2b2018');
    pb(lx - 6, 11, lx + 6, 16, '#4a3a28');
    pb(lx - 5, 11, lx + 5, 13, '#ffe6a8');
    pbA(lx - 15, -2, lx + 15, 13, '#ffcf7a', .22);
    pbA(lx - 9, -14, lx + 9, 12, '#ffb84a', .16);
  }
  pb(-68, -22, -36, -16, '#3a3a40');            /* ocak gövdesi */
}

function pro1Ocak(t) {
  var i;
  /* kor: nefes alır */
  for (i = 0; i < 5; i++) {
    var kor = Math.sin(t * 3 + i * 1.7) > -.2;
    pb(-66 + i * 6, -21, -62 + i * 6, -18, kor ? (i % 2 ? '#ffb04a' : '#ff7a2a') : '#a83a12');
  }
  pbA(-76, -26, -28, 22, '#ff9a3a', .18 + .05 * Math.sin(t * 2.1));
  pbA(-86, -32, 86, -22, '#ffb84a', .10);

  /* baba: tezgâhın arkasında, ara ara göz kırpar */
  var bx = 4, kol = Math.round(Math.sin(t * 1.9) * 2);
  pb(bx - 12, -19, bx + 12, 6, '#a8281c');
  pb(bx - 8, -19, bx + 8, 3, '#e4dcc6');
  pb(bx + 11, -8 + kol, bx + 22, 1 + kol, '#a8281c');
  pb(bx + 20, -10 + kol, bx + 26, -4 + kol, '#e0a978');
  pb(bx - 7, 6, bx + 7, 18, '#e0a978');
  pb(bx - 5, 9, bx + 5, 11, '#ddd6c8');
  if (((t * .7) % 4) > 0.12) {
    pb(bx - 4, 12, bx - 2, 14, '#2b2018');
    pb(bx + 2, 12, bx + 4, 14, '#2b2018');
  } else {
    pb(bx - 4, 12, bx - 2, 13, '#c9885a');
    pb(bx + 2, 12, bx + 4, 13, '#c9885a');
  }
  pb(bx - 8, 18, bx + 8, 24, '#c9302a');
  pb(bx - 9, 17, bx + 9, 18, '#7a1a12');

  /* tezgâh + soğutmalı vitrin */
  pb(-86, -32, 86, -18, '#6b4122');
  pb(-86, -19, 86, -17, '#a8703f');
  pb(-30, -32, 22, -21, '#456a7a');
  for (i = 0; i < 6; i++)
    pb(-27 + i * 8, -30, -22 + i * 8, -26, ['#c9302a', '#3f8a4a', '#d8ac35'][i % 3]);

  /* şiş: koninin ön yüzü tezgâhın önüne düşer */
  pb(-53, -27, -51, 28, '#9aa3ab');
  proSis(-52, -22, 18, 11, 2.8, t);
  if (chance(.30))
    part({ x: pbx(-52) + rnd(-7, 7), y: pby(16), vx: rnd(-5, 5), vy: rnd(-20, -9),
           life: 1.1, col: 'rgba(255,235,205,.35)', g: -14, sz: 1 });
}

function pro1On() {
  var i, x0;
  /* --- vitrin camı: hafif tint + tente gölgesi + eğik yansımalar --- */
  pbA(-84, -30, 84, 22, '#8fb8cc', .07);
  pbA(-84, 8, 84, 22, '#12283a', .30);
  proYansima(-76, -4, 4, 74, .15);
  proYansima(-69, -4, 2, 74, .11);
  proYansima(64, -4, 3, 72, .13);
  proYansima(71, -4, 2, 72, .09);

  /* --- cephe DÖRT PARÇA: ortası gerçek boşluk --- */
  var AH1 = '#5a3418', AH2 = '#7a4a24', AH3 = '#9a6634', AH4 = '#3d2210';
  pb(-98, -38, -84, 34, AH2); pb(-98, -38, -95, 34, AH3);
  pb(84, -38, 98, 34, AH2); pb(93, -38, 98, 34, AH1);
  pb(-98, 22, 98, 34, AH2); pb(-98, 32, 98, 34, AH3); pb(-98, 22, 98, 24, AH1);
  pb(-98, -38, 98, -30, AH4);
  for (i = 0; i < 25; i++)                       /* fayans kuşak */
    pb(-96 + i * 8, -37, -90 + i * 8, -31, i % 2 === 0 ? '#2f6b62' : '#3d8078');
  pb(-98, -31, 98, -30, '#8fbdb4');
  pb(26, -30, 32, 22, AH2); pb(26, -30, 28, 22, AH3);     /* ara dikme */
  pb(78, -30, 84, 22, AH3);                               /* kapı çerçevesi */
  pb(70, -6, 76, -3, '#d8ac35');                          /* kol */
  pb(32, -40, 84, -38, '#a2a297');                        /* eşik */

  /* --- tente: kırmızı-krem şeritli, eteği dilimli --- */
  for (i = 0; i < 17; i++) {
    x0 = -102 + i * 12;
    pb(x0, 26, x0 + 12, 37, i % 2 === 0 ? '#c0281c' : '#f2ece0');
  }
  pb(-102, 22, 102, 28, '#8e2018');
  for (i = 0; i < 17; i++) {
    x0 = -102 + i * 12;
    var tc = i % 2 === 0 ? '#c0281c' : '#f2ece0';
    pb(x0, 19, x0 + 12, 22, tc);
    pb(x0 + 3, 16, x0 + 9, 19, tc);
  }

  /* --- tabela --- */
  pb(-92, 38, 92, 61, '#7a1a12');
  pb(-88, 42, 88, 57, '#c0281c');
  pb(-92, 58, 92, 60, '#e2604f');

  /* --- sokak eşyası: çöp kovası + A tipi kaldırım tabelası --- */
  pb(108, -42, 122, -22, '#4a5058');
  pb(106, -22, 124, -19, '#6b737d');
  pb(-128, -42, -108, -20, '#6b4122');
  pb(-126, -40, -110, -22, '#e8dcc0');
  pb(-123, -28, -113, -26, '#8e2018');
  pb(-123, -33, -116, -31, '#8e2018');
}

/* Vitrin yansıması: eğik ince şerit. Büyük dikdörtgen yansıma camı
   sütlü gösteriyordu; gerçek vitrin ince, eğik şeritler hâlinde
   yansıtır (Blender'da plE(), burada satır satır kaydırma). */
function proYansima(cx, cz, gen, boy, a) {
  ctx.globalAlpha = a;
  var z0 = Math.max(-30, cz - boy / 2), z1 = Math.min(22, cz + boy / 2);
  for (var z = z0; z <= z1; z++) {
    var x = cx - 0.487 * (z - cz);
    fr(pbx(x - gen / 2), pby(z), Math.max(1, gen), 1, '#eaf6ff');
  }
  ctx.globalAlpha = 1;
}

function pro1Sokak(t, gx, gy, gw, gh) {
  var i;
  /* tabela yazısı + ampuller (metin önbelleğe girmez: dil değişebilir) */
  txt('USTA DÖNER', pbx(0), pby(55), '#ffd75e', { align: 'c', sc: 1, outline: '#7a1a12' });
  for (i = 0; i < 12; i++)
    pb(-88 + i * 16, 37, -84 + i * 16, 41,
       Math.sin(t * 4 + i * .7) > -.3 ? '#fff0b0' : '#8a7a4a');

  /* kuyruk: dükkânın sağında bekleyen müşteriler */
  var kuy = [[134, '#3f5a72', '#2e3f52', '#e0a978'],
             [160, '#5c4a5e', '#3e3242', '#c9885a'],
             [186, '#4a6b4a', '#33472f', '#f0bd8a']];
  for (i = 0; i < 3; i++)
    proKisi(kuy[i][0] + Math.round(Math.sin(t * 1.3 + i) * 1.2), kuy[i][1],
            kuy[i][2], kuy[i][3], '#2b2018', 0, false);

  /* dürümünü almış, soldan çıkan yaya */
  var mu = (t * .10) % 1.35;
  if (mu < 1) {
    var yx = 60 - mu * 210;
    proKisi(yx, '#6b5a3a', '#4a4030', '#e0a978', '#3a2a1e', t * 7, true);
    pb(yx + 8, -18, yx + 16, -13, '#f0d5a8');
    pb(yx + 8, -18, yx + 15, -14, '#fdfaf0');
  }

  /* sokak lambası: kareyi soldan kesen koyu siluet -> derinlik */
  pb(-176, -42, -170, 66, '#2b2620');
  for (i = 0; i < 9; i++)
    pb(-170 + i * 4, 66 - i * .9, -164 + i * 4, 68 - i * .9, '#2b2620');
  pb(-140, 54, -126, 60, '#3a342c');
  pb(-138, 55, -128, 58, '#ffe6a8');
  pb(-176, -42, -170, -38, '#1e1a16');

  proBirds(t, gx, gy, gw, 3, .09);
  /* güneş ışınları: 40 x 30px yerine 16 x 8px — aynı etki, 1/10 harmanlama */
  ctx.globalAlpha = .07 + .03 * Math.sin(t);
  for (i = 0; i < 16; i++) fr(gx + 24 + i * 22, gy, 8, gh, '#ffe9a0');
  ctx.globalAlpha = 1;
}

function proShopDay(t, k) {
  var gx = 40, gy = 44, gw = 400, gh = 150;
  proCiz('s1a', pro1Arka);
  pro1Ocak(t);
  proCiz('s1b', pro1On);
  pro1Sokak(t, gx, gy, gw, gh);
}


/* ============================================================
   2) BABA PORTRESİ — ocak ışığı soldan-alttan
   ============================================================ */
function pro2Arka() {
  var i, r, c;
  var fon = [[-70, -30, '#241610'], [-30, 4, '#2e1c12'],
             [4, 34, '#382214'], [34, 96, '#432a18']];
  for (i = 0; i < fon.length; i++) pb(-230, fon[i][0], 230, fon[i][1], fon[i][2]);
  /* tuğla derzleri */
  for (r = 0; r < 11; r++) {
    pb(-230, -60 + r * 14, 230, -59 + r * 14, '#4e3020');
    for (c = 0; c < 13; c++) {
      var ox = r % 2 ? 9 : 0;
      pb(-222 + c * 36 + ox, -59 + r * 14, -221 + c * 36 + ox, -46 + r * 14, '#4e3020');
    }
  }
  /* asılı takımlar: siluet */
  var ask = [[-186, 26], [-166, 20], [154, 30], [176, 22]];
  for (i = 0; i < ask.length; i++) {
    pb(ask[i][0] - 1, 96 - ask[i][1], ask[i][0] + 1, 96, '#1c1108');
    pb(ask[i][0] - 7, 90 - ask[i][1], ask[i][0] + 7, 96 - ask[i][1], '#2b2018');
  }
}

function pro2Baba(t) {
  var i, j;
  var BX = 62, BZ = 6;

  /* --- gövde: omuzlar, önlük, yaka, boyun --- */
  pbE(BX, BZ - 62, 56, 46, '#8e2018');
  pbE(BX - 4, BZ - 62, 52, 43, '#c33c2c');
  pbE(BX - 10, BZ - 62, 40, 38, '#e2604f');
  pbE(BX, BZ - 66, 26, 42, '#aba392');
  pbE(BX - 3, BZ - 66, 23, 39, '#e4dcc6');
  pbE(BX - 8, BZ - 66, 15, 32, '#f6f1e2');
  pbE(BX, BZ - 30, 20, 8, '#c33c2c');
  pb(BX - 11, BZ - 26, BX + 11, BZ - 6, '#c9885a');

  /* --- baş: elipsoit, ışık soldan-alttan (ocak) --- */
  pbE(BX, BZ + 4, 25, 29, '#8a5230');
  pbE(BX - 2, BZ + 3, 23, 27, '#a86a3e');
  pbE(BX - 4, BZ + 2, 20, 24, '#c9885a');
  pbE(BX - 6, BZ, 16, 20, '#e0a978');
  pbE(BX - 8, BZ - 2, 10, 13, '#f0bd8a');
  pbE(BX, BZ - 12, 18, 12, '#d79f70');                 /* çene/elmacık */
  pbE(BX - 4, BZ - 13, 14, 9, '#e8b184');
  for (i = 0; i < 2; i++)                              /* kulaklar */
    pbE(BX + (i ? 25 : -25), BZ + 2, 5, 8, i ? '#a86a3e' : '#c9885a');

  /* --- burun --- */
  pbE(BX - 1, BZ + 1, 6, 9, '#c9885a');
  pbE(BX - 3, BZ, 4, 7, '#e0a978');
  pbE(BX - 1, BZ - 5, 8, 4, '#b87b4c');

  /* --- gözler: ara ara kırpar --- */
  var kirp = ((t * .62) % 4.4) < 0.13;
  for (i = 0; i < 2; i++) {
    var sx = i ? 11 : -11;
    if (kirp) { pb(BX + sx - 5, BZ + 11, BX + sx + 5, BZ + 13, '#c9885a'); }
    else {
      pbE(BX + sx, BZ + 13, 7, 6, '#b87b4c');                      /* göz çukuru */
      pbE(BX + sx, BZ + 12, 5, 4, '#cfc7b6');
      pbE(BX + sx - 1, BZ + 12, 4, 3, '#f0ece2');
      pbE(BX + sx + 1, BZ + 12, 2.4, 2.4, '#2b2018');
      px(pbx(BX + sx), pby(BZ + 13), '#ffffff');
    }
    for (j = 0; j < 9; j++) {                          /* kaş: kalın, kırlaşmış */
      var eg = (j - 4) * (i ? .5 : -.5);
      pb(BX + sx - 8 + j * 2, BZ + 18 + eg, BX + sx - 6 + j * 2, BZ + 20 + eg, '#8f8578');
      pb(BX + sx - 8 + j * 2, BZ + 19 + eg, BX + sx - 6 + j * 2, BZ + 20 + eg, '#b8b0a0');
    }
  }

  /* --- fes + püskül --- */
  pb(BX - 22, BZ + 30, BX + 22, BZ + 52, '#8e2018');
  pb(BX - 21, BZ + 30, BX + 20, BZ + 52, '#c33c2c');
  pb(BX - 21, BZ + 30, BX - 12, BZ + 52, '#e2604f');       /* sol ışık */
  pbE(BX, BZ + 52, 22, 6, '#c33c2c');
  pbE(BX - 6, BZ + 53, 14, 4, '#e2604f');
  pb(BX - 23, BZ + 27, BX + 23, BZ + 31, '#7a1a12');       /* kenarlık */
  var sal = Math.round(Math.sin(t * 1.6) * 3);
  pb(BX + 19 + sal, BZ + 38, BX + 21 + sal, BZ + 54, '#2b2018');
  pbE(BX + 20 + sal, BZ + 37, 4, 3, '#2b2018');

  /* --- pala bıyık: ortada kalın, uçları yukarı --- */
  for (j = 0; j < 29; j++) {
    var u = Math.abs(j - 14) / 14, lift = u * u * 6, th = Math.max(2, 6 - u * 3.5);
    pb(BX - 15 + j, BZ - 9 + lift, BX - 14 + j, BZ - 9 + lift + th, '#ddd6c8');
    pb(BX - 15 + j, BZ - 9 + lift + th - 1, BX - 14 + j, BZ - 9 + lift + th, '#f4f0e6');
  }
  for (j = 0; j < 13; j++) {                           /* gülümseme */
    var u2 = Math.abs(j - 6) / 6;
    pb(BX - 6 + j, BZ - 17 + u2 * u2 * 2, BX - 5 + j, BZ - 16 + u2 * u2 * 2, '#8a4a2e');
  }
}

/* Ocagin halesi: 26 kat yari saydam turuncu. Her karede yeniden
   harmanlamak pahaliydi; bir kez saydam katmana cizilip nabiz
   globalAlpha ile veriliyor. */
/* Döner ünitesi: ARKADA dikey brülör paneli, ÖNÜNDE et konisi, altta
   yağ tablası, üstte motor kutusu — hepsi tek makine.

   Önceki hâlde brülör, koninin YANINDA duran ayrı bir turuncu çubuklu
   kutuydu; iki nesne birbiriyle ilgisiz görünüyordu. Gerçek döner
   ocağında brülör etin arkasındadır ve etin iki yanından taşarak
   silueti arkadan aydınlatır — sahnenin ışık kaynağı da o. */
function pro2Doner(t) {
  var i, X = -136;                            /* şişin ekseni */

  /* --- yağ tablası --- */
  pb(X - 38, -58, X + 38, -48, '#2f2f38');
  pb(X - 38, -50, X + 38, -48, '#6f7880');
  pb(X - 38, -58, X - 34, -48, '#4d545c');

  /* --- arka panel: paslanmaz gövde --- */
  pb(X - 32, -48, X + 32, 44, '#22222a');
  pb(X - 32, -48, X - 27, 44, '#3d3d48');     /* sol ışık kenarı */
  pb(X + 27, -48, X + 32, 44, '#14141a');     /* sağ gölge kenarı */
  pb(X - 32, 40, X + 32, 44, '#3d3d48');
  pb(X - 32, -48, X + 32, -45, '#14141a');

  /* --- brülör: yatay seramik çubuk sıraları, sırayla nefes alır --- */
  for (i = 0; i < 12; i++) {
    var bz = -43 + i * 7, yan = Math.sin(t * 2.2 + i * .8) > -.35;
    pb(X - 25, bz, X + 25, bz + 5, yan ? '#c0421a' : '#7a2c0c');
    pb(X - 25, bz + 1, X + 25, bz + 4, yan ? '#ff7a2a' : '#a83a12');
    pb(X - 25, bz + 2, X + 25, bz + 3, yan ? '#ffb04a' : '#c0421a');
    pb(X - 25, bz + 5, X + 25, bz + 6, '#1c1c24');            /* ayraç */
  }
  pb(X - 27, -43, X - 25, 41, '#3d3d48');                     /* çubuk yatakları */
  pb(X + 25, -43, X + 27, 41, '#1c1c24');

  /* --- motor kutusu + şiş çubuğu --- */
  pb(X - 16, 44, X + 16, 54, '#2a2a32');
  pb(X - 16, 52, X + 16, 54, '#4d545c');
  pb(X - 14, 46, X - 4, 50, '#6f7880');
  pb(X - 2, -52, X + 2, 48, '#6f7880');
  pb(X - 2, -52, X, 48, '#c6ced5');

  /* --- et konisi: brülörün önünde --- */
  proSis(X, -40, 30, 20, 5, t);

  /* --- bıçak askısı ve yağ akıntısı: makineyi kullanılmış gösterir */
  pb(X + 12, -48, X + 26, -46, '#8a5f2a');
  ctx.globalAlpha = .35;
  pb(X - 6, -48, X + 4, -44, '#7a3f12');
  ctx.globalAlpha = 1;
}

/* Dürüm ve onu kavrayan el.

   Önceki hâli düz bir elips + üstünde beyaz bir dikdörtgen (kâğıt) +
   onun üstünde dört sosisti (parmaklar). Hiçbiri diğerinin biçimini
   izlemiyordu. Burada gövde, kâğıt ve parmaklar SATIR SATIR çiziliyor;
   uçlar yuvarlanıyor, üstte ışık altta gölge var, kâğıt tüpün kavisine
   oturuyor ve parmaklar onu gerçekten sarıyor. */
/* Babanın kolu ve elindeki dürüm.

   POZ NOTU — burada üç deneme başarısız oldu. Sebep tonlama değildi:
   dürümü öne uzatan bir kol kameraya doğru KISALIR (foreshortening),
   bu ölçekte (el ~30 piksel) hiçbir şekilde okunmuyor. Duruş
   değiştirildi: dürüm DİKEY tutuluyor, ön kol aşağıdan yukarı
   geliyor. Kısalma yok, ön kol yandan ve gerçek uzunlukta görünüyor;
   dikey bir tüpü kavrayan yumrukta da parmaklar önden YATAY bantlar
   olarak görünür — piksel artın bildik ve okunabilir çözümü. */

/* Yatay parmak: kapsül. Uçları yuvarlak, üstte ışık altta gölge. */
function proParmak(x0, x1, cz, kal) {
  var uz = x1 - x0, i;
  for (i = 0; i <= uz; i++) {
    var u = i / uz;
    var h = kal * Math.sqrt(Math.max(.20, 1 - Math.pow(u * 2 - 1, 6)));
    var x = x0 + i;
    pb(x, cz - h, x + 1, cz + h, '#4e2e1a');            /* kontur */
    pb(x, cz - h + 1, x + 1, cz + h - 1, '#96603a');
    pb(x, cz + h - 3, x + 1, cz + h - 1, '#b87b4c');
    pb(x, cz + h - 2, x + 1, cz + h - 1, '#d79f70');    /* üst ışık */
  }
}

/* Ön kol: aşağıdan yukarı, bilekte daralarak. Genişliği yumruğun
   ~0.7'si — önceki hâlinde kol yumruktan kalındı, bu yüzden koni
   gibi duruyordu. */
function pro2Kol() {
  var i, u, ax, az, aw;
  var X0 = 26, Z0 = -59, X1 = -16, Z1 = -39;           /* dirsekten bileğe */
  var n = X0 - X1;
  for (i = 0; i <= n; i++) {
    u = i / n;
    ax = X0 - i; az = Z0 + (Z1 - Z0) * u; aw = 11 - u * 3;
    /* koyu kontur: kol da gövde de aynı kırmızı; ayrılmazsa gömleğe
       karışıyor ve kol yokmuş gibi duruyor */
    pb(ax, az - aw - 1, ax + 1, az + aw + 1, '#4a0f0a');
    pb(ax, az - aw, ax + 1, az + aw, '#8e2018');
    pb(ax, az - aw + 2, ax + 1, az + aw - 2, '#c33c2c');
    pb(ax, az + aw - 4, ax + 1, az + aw - 2, '#e2604f');   /* üst ışık */
  }
  ctx.globalAlpha = .30;                                  /* kumaş kırışığı */
  pb(4, -50, 14, -47, '#6b1610');
  pb(-6, -45, 4, -42, '#6b1610');
  ctx.globalAlpha = 1;
  /* manşet: bileğe DİK, belirgin bant */
  for (i = 0; i <= 9; i++) {
    ax = -12 - i; az = -39 - i * .5; aw = 10 - i * .25;
    pb(ax, az - aw - 1, ax + 1, az + aw + 1, '#8a8272');
    pb(ax, az - aw, ax + 1, az + aw, '#c2b9a2');
    pb(ax, az - aw + 1, ax + 1, az + aw - 1, '#e4dcc6');
    if (i > 6) pb(ax, az - aw + 1, ax + 1, az + aw - 1, '#f6f1e2');
  }
}

/* Dikey tutulan dürüm ve onu kavrayan yumruk. */
function pro2Durum() {
  var i, q, uu, kis, col;
  var X = -31, R = 10;                        /* dürümün ekseni ve yarıçapı */
  var ZA = -42, ZB = 15;                      /* alt (elde) ve üst (açık) uç */
  var KAG = -10;                              /* kâğıdın bittiği yükseklik */
  var YA = -40, YU = -13;                     /* yumruğun alt/üst sınırı */

  /* --- gövde: dikey tüp, her sütun kendi tonunu alır --- */
  for (i = -R; i <= R; i++) {
    uu = i / R;                               /* -1 sol, +1 sağ */
    kis = Math.round((1 - Math.sqrt(Math.max(0, 1 - uu * uu))) * 3);
    col = uu < -.55 ? '#fdfaf0' : (uu < -.12 ? '#f0d5a8' :
          (uu < .45 ? '#cfa268' : (uu < .8 ? '#a87a41' : '#8a5f2a')));
    pb(X + i, ZA + kis, X + i + 1, ZB - kis, col);
  }
  /* --- üstteki açık uç: gerçek kesit --- */
  pbE(X, ZB - 3, R - 1, 4, '#e8c07a');
  pbE(X, ZB - 4, R - 3, 3, '#8a4a1a');
  pbE(X - 3, ZB - 4, 3.5, 2.2, '#d18c42');
  pbE(X + 3, ZB - 4, 2.6, 1.8, '#3f8a4a');
  pbE(X, ZB - 6, 2, 1.4, '#c9302a');
  /* --- kâğıt: alt yarıyı sarar, aynı kavisi izler --- */
  for (i = -R - 1; i <= R + 1; i++) {
    uu = i / (R + 1);
    kis = Math.round((1 - Math.sqrt(Math.max(0, 1 - uu * uu))) * 3);
    col = uu < -.55 ? '#ffffff' : (uu < -.12 ? '#fdfaf0' :
          (uu < .45 ? '#e4dcc6' : '#b0a894'));
    pb(X + i, ZA + kis, X + i + 1, KAG, col);
  }
  pb(X - R, KAG - 2, X + R, KAG, '#9e9888');            /* kâğıdın kesik ağzı */
  pb(X - R + 1, KAG - 9, X + R - 1, KAG - 7, '#d8352c');
  pb(X - R + 1, KAG - 14, X + R - 1, KAG - 12, '#2f5f9e');

  /* --- avuç kütlesi: parmakların ARKASINDA --- */
  pbE(X, (YA + YU) / 2 + 1, 16, 12.5, '#3d2314');
  pbE(X - 1, (YA + YU) / 2 + 1, 14, 10.5, '#6f4326');

  /* --- parmaklar: dikey tüpü saran DÖRT YATAY bant --- */
  for (i = 0; i < 4; i++) {
    var fz = YU - 3 - i * 6;
    var f0 = X - 15 + (i === 3 ? 2 : 0), f1 = X + 13 - (i === 3 ? 2 : 0);
    proParmak(f0, f1, fz, 3.4);
  }
  /* --- başparmak: sağ yanda, dikey; parmakların üstünden geçer --- */
  for (q = 0; q <= 18; q++) {
    var tu = q / 18, tz = YA + 4 + q, tx = X + 12 - tu * 3;
    var tw = 3.8 * Math.sqrt(Math.max(.22, 1 - Math.pow(tu * 2 - 1, 4)));
    pb(tx - tw, tz, tx + tw, tz + 1, '#3d2314');
    pb(tx - tw + 1, tz, tx + tw - 1, tz + 1, tu > .55 ? '#b87b4c' : '#96603a');
    pb(tx - tw + 1, tz, tx - tw + 2, tz + 1, '#d79f70');
  }
  pbE(X + 9, YU - 2, 3.4, 2.6, '#8a5230');              /* başparmak ucu */
  pbE(X + 9, YU - 2, 2.4, 1.8, '#f0bd8a');
}

function pro2Hale() {
  ctx.globalAlpha = .030;
  for (var r = 0; r < 26; r++)
    pb(-166 - r * 3, -56 - r * 2, -106 + r * 4, 42 + r * 2, '#ff9a3a');
  ctx.globalAlpha = 1;
}

function pro2Atmosfer() {
  pbA(-230, -70, 230, 96, '#ff8a3a', .07);
  pbA(-230, -70, -150, 96, '#000000', .30);
  pbA(150, -70, 230, 96, '#000000', .30);
  pbA(-230, 70, 230, 96, '#000000', .22);
  pbA(-230, -70, 230, -52, '#000000', .22);
}

function proFather(t, k) {
  var i, r;
  proCiz('s2a', pro2Arka);

  pro2Doner(t);
  ctx.globalAlpha = .88 + .26 * Math.sin(t * 1.7);
  ctx.drawImage(proKat('s2hale', pro2Hale), 40, 44);
  ctx.globalAlpha = 1;

  pro2Baba(t);

  /* --- elindeki dürüm: baba onu BİZE uzatıyor --- */
  pro2Kol();
  pro2Durum();
  if (chance(.14))
    part({ x: pbx(-34) + rnd(-16, 16), y: pby(-24), vx: rnd(-5, 5), vy: rnd(-20, -9),
           life: 1.1, col: 'rgba(255,235,205,.4)', g: -12, sz: 1 });

  /* --- atmosfer: sıcak örtü + vinyet (duragan, onbellekten) --- */
  proCiz('s2on', pro2Atmosfer);
}


/* ============================================================
   3) KIŞ GECESİ — kepenk kapalı, üç aydır açılmamış
   ============================================================ */
function pro3Arka() {
  var i, r, c, x0, x1, h;
  var gok = [[64, 96, '#121824'], [44, 64, '#18202f'], [26, 44, '#1f293b'],
             [10, 26, '#273348'], [-62, 10, '#2f3d55']];
  for (i = 0; i < gok.length; i++) pb(-230, gok[i][0], 230, gok[i][1], gok[i][2]);
  var bul = [[-140, 70, 60, 9], [30, 82, 74, 8], [170, 64, 44, 7]];
  for (i = 0; i < bul.length; i++) {
    pb(bul[i][0] - bul[i][2], bul[i][1], bul[i][0] + bul[i][2], bul[i][1] + bul[i][3], '#38455e');
    pb(bul[i][0] - bul[i][2] + 5, bul[i][1], bul[i][0] + bul[i][2] - 9,
       bul[i][1] + bul[i][3] - 3, '#2b3448');
  }
  var uzak = [[-238, -170, 40], [-176, -120, 62], [126, 190, 54], [184, 238, 38]];
  for (i = 0; i < uzak.length; i++) {
    x0 = uzak[i][0]; x1 = uzak[i][1]; h = uzak[i][2];
    pb(x0, -36, x1, h, '#1b2432');
    for (r = 0; r < ((h + 30) / 16) | 0; r++)
      for (c = 0; c < Math.max(1, ((x1 - x0) / 18) | 0); c++)
        pb(x0 + 7 + c * 18, -26 + r * 16, x0 + 14 + c * 18, -17 + r * 16,
           (r * 3 + c * 5 + i) % 7 === 0 ? '#d8a850' : '#232d3d');
  }
  var kom = [[-238, -142], [142, 238]];
  for (i = 0; i < 2; i++) {
    x0 = kom[i][0]; x1 = kom[i][1];
    pb(x0, -36, x1, 54, '#2a3040');
    pb(x0, 54, x1, 59, '#3a4254');
    for (c = 0; c < 3; c++)
      for (r = 0; r < 3; r++)
        pb(x0 + 14 + c * 28, -22 + r * 22, x0 + 26 + c * 28, -8 + r * 22,
           (c + r * 2 + i) % 5 === 0 ? '#e0b060' : '#1c2430');
    pb(x0, 54, x1, 57, '#c8d4e0');              /* çatı karı */
  }

  /* sokak + kar */
  pb(-240, -61, 240, -48, '#191d25');
  pb(-240, -48, 240, -42, '#20262e');
  pb(-240, -42, 240, -38, '#c8d4e0');
  pb(-240, -38, 240, -36, '#9fb0c2');
  for (i = 0; i < 14; i++) pb(-230 + i * 34, -52, -206 + i * 34, -50, '#8fa2b6');

  /* --- dükkân: cephe + kaide --- */
  pb(-150, -38, 150, 40, '#33251a');
  pb(140, -38, 150, 40, '#241a12');
  pb(-150, -38, 150, -30, '#241a12');
  for (i = 0; i < 38; i++)
    pb(-148 + i * 8, -37, -142 + i * 8, -31, i % 2 === 0 ? '#22453f' : '#2b544e');

  /* --- kepenk: yatay oluklar, üç tonlu --- */
  for (r = 0; r < 18; r++) {
    var z = -30 + r * 3;
    pb(-136, z, 136, z + 1, '#2a3138');
    pb(-136, z + 1, 136, z + 2, '#4b555f');
    pb(-136, z + 2, 136, z + 3, '#39424a');
  }
  for (var v = -132; v < 136; v += 26) pb(v, -30, v + 2, 24, '#232a30');
  var pas = [[-96, -12, 14, 8], [34, 6, 10, 6], [88, -22, 18, 5], [-40, 14, 9, 7]];
  for (i = 0; i < pas.length; i++) {
    pb(pas[i][0], pas[i][1], pas[i][0] + pas[i][2], pas[i][1] + pas[i][3], '#6b4526');
    pb(pas[i][0] + 2, pas[i][1] + 1, pas[i][0] + pas[i][2] - 3,
       pas[i][1] + pas[i][3] - 2, '#8a5a30');
  }
  pb(-140, 24, 140, 34, '#3d464f');
  pb(-140, 32, 140, 34, '#5d6772');
  pb(-136, -32, 136, -30, '#5d6772');

  /* --- asma kilit --- */
  pb(-14, -30, -6, -14, '#5d6772'); pb(6, -30, 14, -14, '#5d6772');
  pb(-14, -30, -12, -14, '#2f363c'); pb(12, -30, 14, -14, '#2f363c');
  ring(pbx(0), pby(-14), 8, '#98a2ab');
  ring(pbx(0), pby(-14), 7, '#6f7880');
  pbA(-14, -36, 16, -30, '#000000', .45);
  pbE(0, -24, 12, 10, '#4d545c');
  pbE(-2, -25, 10, 8, '#98a2ab');
  pbE(-4, -26, 6, 5, '#c6ced5');
  pb(-2, -28, 2, -24, '#12161a');
  pb(-1, -31, 1, -27, '#12161a');

  /* --- sönmüş tabela --- */
  pb(-140, 36, 140, 62, '#3a1410');
  pb(-136, 39, 136, 59, '#521a14');
  for (i = 0; i < 12; i++)
    pb(-132 + i * 23, 36, -127 + i * 23, 40, (i === 2 || i === 5 || i === 9) ? '#2b2620' : '#4a4438');
  pb(-140, 62, 140, 65, '#c8d4e0');             /* tabelada kar */

  /* --- sarkık, yırtık tente --- */
  for (i = 0; i < 13; i++) {
    var tx = -80 + i * 12, sk = (i === 5 || i === 6 || i === 7) ? 0 : 1;
    pb(tx, 28 - (sk ? 0 : 8), tx + 12, 35 - (sk ? 0 : 6),
       i % 2 === 0 ? '#6b1a14' : '#8a8478');
  }
  pb(-80, 33, 76, 36, '#c8d4e0');

  /* --- anma: karanfil + vazo --- */
  pb(-168, -38, -156, -26, '#3a3f48');
  var gul = [[-167, -14], [-161, -8], [-155, -16]];
  for (i = 0; i < 3; i++) {
    var fx = gul[i][0], fz = gul[i][1];
    pb(fx, -26, fx + 2, fz, '#2f4a2a');
    pb(fx - 4, fz - 8, fx + 1, fz - 6, '#2f4a2a');
    pb(fx - 5, fz, fx + 7, fz + 8, '#8e2018');
    pb(fx - 3, fz + 2, fx + 5, fz + 7, '#c33c2c');
    pb(fx - 2, fz + 5, fx + 3, fz + 7, '#e2604f');
  }
  pb(-146, -38, -140, -26, '#d8d2c0');
  pb(-141, -38, -140, -26, '#9e9888');

  /* --- ön plan: sokak lambası --- */
  pb(-206, -42, -200, 66, '#12161c');
  for (i = 0; i < 9; i++) pb(-200 + i * 4, 66 - i * .9, -194 + i * 4, 68 - i * .9, '#12161c');
  pb(-170, 54, -156, 60, '#1a1f26');
  pb(-168, 55, -158, 58, '#ffe6a8');
  for (r = 0; r < 16; r++)
    pbA(-178 - r * 2.6, 52 - r * 6, -148 + r * 2.6, 56 - r * 6, '#cfe0ff', .030);
}

function proClosed(t, k) {
  var gx = 40, gy = 44, gw = 400, gh = 150, i;
  proCiz('s3a', pro3Arka);

  /* kepenğe yapıştırılmış ilan: köşesi rüzgârda kalkıyor */
  var kalk = Math.max(0, Math.sin(t * 1.1)) * 3;
  pb(-84, -8, -58, 16, '#cfc7b2');
  pb(-84, -8, -80, 16, '#b0a894');
  pb(-84, 13, -58, 16, '#e8e2d0');
  pb(-80, 10, -62, 13, '#8a2018');
  for (i = 0; i < 4; i++) pb(-80, 4 - i * 4, -66 + (i % 2) * 4, 5 - i * 4, '#6b6558');
  pb(-64 - kalk, -8, -58, -3 + kalk, '#8a8474');
  pb(-87, 13, -79, 17, '#d8d2c0');
  pb(-63, 13, -55, 17, '#d8d2c0');

  /* mum: alev titriyor, hâle nefes alıyor */
  var alev = Math.round(Math.sin(t * 9) * .5 + Math.sin(t * 5.3) * .5);
  pb(-144, -26, -142, -21 + alev, '#ffd75e');
  pb(-144, -24, -143, -22 + alev, '#fff6d8');
  for (i = 0; i < 7; i++)
    pbA(-147 - i * 2, -30 - i * 1.5, -139 + i * 2, -20 + i * 2, '#ffb04a',
        .055 + .012 * Math.sin(t * 6 + i));

  /* kar: sürüklenerek düşüyor */
  for (i = 0; i < 70; i++) {
    var kx = gx + ((hash1(i * 3.1) * gw + Math.sin(t * .5 + i) * 14 + t * 9) % gw);
    var ky = gy + ((hash1(i * 7.7) * gh + t * (16 + hash1(i) * 26)) % gh);
    var b = i % 5 === 0 ? 2 : 1;
    ctx.globalAlpha = .55 + hash1(i * 2.3) * .40;
    fr(kx, ky, b, b, '#eaf2ff');
    ctx.globalAlpha = 1;
  }
  /* kaldırımda biriken kar üstüne düşen ince parıltı */
  ctx.globalAlpha = .10 + .04 * Math.sin(t * .7);
  fr(gx, gy + gh - 22, gw, 4, '#ffffff');
  ctx.globalAlpha = 1;
}


/* ============================================================
   4) BORÇ KÂĞIDI — tek ampul, masa, kâğıt
   ============================================================ */
function pro4Arka() {
  var i;
  var fon = [[-62, -10, '#170f0a'], [-10, 34, '#20160e'],
             [34, 66, '#1a1109'], [66, 96, '#120c07']];
  for (i = 0; i < fon.length; i++) pb(-230, fon[i][0], 230, fon[i][1], fon[i][2]);
  for (i = 0; i < 15; i++) pb(-220 + i * 30, -10, -218 + i * 30, 96, '#2a1c12');

  /* masa: ön yüz + kenar + oblik üst yüzey */
  pb(-240, -61, 240, -16, '#3d2a1c');
  for (i = 0; i < 22; i++) pb(-236 + i * 22, -61, -234 + i * 22, -16, '#33241a');
  pb(-240, -16, 240, -13, '#7a5638');
  pb(-240, -13, 240, -6, '#3d2a1c');
  pbA(-120, -16, 120, -12, '#ffcf7a', .16);

  /* babanın gözlüğü: masada duruyor */
  pbA(-172, -15, -114, -11, '#000000', .40);
  ring(pbx(-158), pby(-2), 11, '#a8811f');
  ring(pbx(-158), pby(-2), 10, '#d8ac35');
  ring(pbx(-128), pby(-2), 11, '#a8811f');
  ring(pbx(-128), pby(-2), 10, '#d8ac35');
  pb(-147, -3, -139, 0, '#a8811f');
  pb(-174, -2, -156, 1, '#a8811f');
  pbA(-167, -11, -149, 7, '#b0c6d2', .22);
  pbA(-137, -11, -119, 7, '#b0c6d2', .22);

  /* çay bardağı: ince belli, tabakta, kaşıkla */
  pbA(122, -14, 186, -9, '#000000', .42);
  pbE(146, -10, 20, 3, '#5f727e');
  pbE(146, -11, 18, 2, '#b0c6d2');
  proBardak(146, -12, 30, 10, 6.4, 11);
  pb(160, 0, 164, 28, '#98a2ab');
  pb(158, 26, 166, 32, '#c6ced5');
  pb(176, -8, 183, -2, '#f4f0e6');
  pb(184, -6, 191, 0, '#f4f0e6');
}

/* Türk çay bardağı: aşağı doğru daralıp yeniden açılan gövde. */
function proBardak(cx, z0, boy, rAlt, rBel, rUst) {
  var i;
  for (i = 0; i < boy; i++) {
    var u = i / (boy - 1);
    var rr = u < .5 ? rAlt + (rBel - rAlt) * (u / .5) : rBel + (rUst - rBel) * ((u - .5) / .5);
    var z = z0 + i;
    pb(cx - rr, z, cx + rr, z + 1, '#5f727e');
    pb(cx - rr + 1, z, cx + rr - 2, z + 1, '#8098a6');
    if (i > 1 && i < boy - 2) {
      var ri = rr - 2;
      pb(cx - ri, z, cx + ri, z + 1, '#8a4410');
      pb(cx - ri + 1, z, cx + ri - 2, z + 1, i > boy * .5 ? '#c06a18' : '#e08a28');
    }
    pb(cx - rr + 1, z, cx - rr + 2, z + 1, '#e0eef6');
  }
}

function pro4Koni() {
  ctx.globalAlpha = .038;
  for (var i = 0; i < 30; i++)
    pb(-12 - i * 6, 68 - i * 4.4, 12 + i * 6, 72 - i * 4.4, '#ffcf7a');
  ctx.globalAlpha = 1;
}

function pro4Vinyet() {
  pbA(-230, -62, -170, 96, '#000000', .44);
  pbA(170, -62, 230, 96, '#000000', .44);
  pbA(-230, 74, 230, 96, '#000000', .30);
  for (var i = 0; i < 12; i++)
    pbA(-230, -61 + i * 3, 230, -58 + i * 3, '#000000', .30 - i * .024);
}

function proDebt(t, k) {
  var i, Y;
  proCiz('s4a', pro4Arka);

  /* --- ampul: hafifçe salınıyor, ışığı duvara vuruyor --- */
  var sal = Math.sin(t * 1.1) * 2;
  pb(-2 + sal * .3, 84, 2 + sal * .3, 96, '#1a1208');
  pb(-5 + sal, 78, 5 + sal, 84, '#3a2f20');
  pbE(sal, 72, 8, 10, '#ffe9a8');
  pbE(sal - 2, 73, 4, 5, '#fff8d8');
  ctx.drawImage(proKat('s4koni', pro4Koni), 40 + Math.round(sal), 44);

  /* --- kâğıt: hafif sallanıyor --- */
  var sw = Math.round(Math.sin(t * 1.2));
  pbA(-70 + sw, -22, 82 + sw, 58, '#000000', .40);
  pb(-76 + sw, -18, 70 + sw, 60, '#cfc7b2');
  pb(-76 + sw, -18, 68 + sw, 59, '#e8e2d0');
  pb(-74 + sw, -16, 64 + sw, 57, '#f8f4e8');

  Y = sw;
  pb(-66 + Y, 42, -50 + Y, 56, '#8a8474');           /* arma */
  pb(-63 + Y, 45, -53 + Y, 53, '#cfc7b2');
  txt('İCRA VE İFLAS MÜDÜRLÜĞÜ', pbx(2 + Y), pby(55), '#4a4438', { align: 'c' });
  pb(-42 + Y, 40, 14 + Y, 45, '#6b6558');
  pb(-66 + Y, 34, 60 + Y, 36, '#8a8474');
  for (i = 0; i < 4; i++)
    pb(-66 + Y, 24 - i * 7, (58 - (i === 3 ? 30 : 0)) + Y, 26 - i * 7, '#8a8474');

  /* tutar kutusu */
  pb(-54 + Y, -10, 50 + Y, 12, '#a8a090');
  pb(-52 + Y, -8, 48 + Y, 10, '#f2eede');
  txt('TOPLAM BORÇ', pbx(-2 + Y), pby(9), '#7a3428', { align: 'c' });
  txt('$5.000.000', pbx(-2 + Y), pby(2), '#a8201a', { align: 'c', sc: 2 });

  for (i = 0; i < 9; i++)                            /* imza */
    pb(20 + i * 4 + Y, -14 + (i % 3) * 2, 24 + i * 4 + Y, -12 + (i % 3) * 2, '#3a3a4a');

  /* --- kırmızı mühür: bir kez iner, sonra durur --- */
  var stampK = clamp((PRO.t - 2.0) * 3.2, 0, 1);
  if (stampK > 0) {
    var drop = Math.round((1 - stampK) * 30);
    var mz = 22 + drop;
    if (stampK > .95 && stampK < 1) shake(2);
    ctx.globalAlpha = .90 * (0.4 + 0.6 * stampK);
    ring(pbx(44 + Y), pby(mz), 16, '#a8201a');
    ring(pbx(44 + Y), pby(mz), 15, '#a8201a');
    ring(pbx(44 + Y), pby(mz), 11, '#a8201a');
    txt('ÖDENMEDİ', pbx(44 + Y), pby(mz + 3), '#a8201a', { align: 'c' });
    ctx.globalAlpha = 1;
    if (stampK >= 1) pbA(52 + Y, 6, 64 + Y, 12, '#a8201a', .35);
  }

  /* --- eller: kâğıdın alt köşelerinde ---
     Önce ön kollar yatay kahverengi sosisler gibi uzanıyordu. Masanın
     karşı tarafında oturan biri kâğıdı tutarken ön kolları kameraya
     doğru KISALIR: görünen şey el, bilek ve masanın ön kenarının
     arkasında kaybolan kısa bir manşet. Sosisler kaldırıldı. */
  var eller = [[-84, -1], [78, 1]];
  for (i = 0; i < 2; i++) {
    var ex = eller[i][0], yon = eller[i][1];
    pbA(ex - 16, -14, ex + 16, -9, '#000000', .42);              /* masa gölgesi */
    /* manşet + bilek: masanın ön kenarına (z=-13) doğru iner, orada biter */
    for (var w = 0; w < 9; w++) {
      var wz = -13 + w, wx = ex + yon * (7 - w * .5), ww = 9 - w * .35;
      pb(wx - ww, wz, wx + ww, wz + 1, w < 5 ? '#c2b9a2' : '#8a5230');
      pb(wx - ww + 1, wz, wx + ww - 2, wz + 1, w < 5 ? '#e4dcc6' : '#a86a3e');
    }
    /* el sırtı: bilekten parmaklara doğru genişler */
    pbE(ex + yon * 2, -2, 12, 10, '#7a4426');
    pbE(ex + yon * 1, -3, 10, 8, '#a86a3e');
    pbE(ex - yon * 2, -4, 6, 5, '#c9885a');
    /* parmaklar: boyları farklı (işaret uzun, serçe kısa), araları açık */
    var boy = [13, 20, 22, 19];                                  /* serçe -> işaret */
    for (var j = 0; j < 4; j++) {
      var fz2 = -8 + j * 4.8;
      var fbas = ex - yon * 4, fuc = ex - yon * boy[j];
      var f0 = Math.min(fbas, fuc), f1 = Math.max(fbas, fuc);
      pb(f0, fz2 - 2, f1, fz2 + 2, '#5e3820');                   /* kontur */
      pb(f0, fz2 - 1, f1, fz2 + 2, j % 2 ? '#a86a3e' : '#c9885a');
      pb(f0 + 1, fz2 + 1, f1 - 1, fz2 + 2, '#e0a978');           /* üst ışık */
      pbE(fuc + yon * 2, fz2, 2.6, 2, '#8a5230');                /* parmak ucu */
      pbE(fuc + yon * 2, fz2 + 1, 1.8, 1.2, '#f0bd8a');          /* tırnak parıltısı */
      pbE(fbas - yon * 2, fz2, 3, 2.4, '#7a4426');               /* boğum tümseği */
      pbE(fbas - yon * 2, fz2 + 1, 2, 1.4, '#c9885a');
    }
    /* başparmak: dışta ve altta, kâğıdın kenarına bastırıyor */
    pbE(ex + yon * 9, -11, 7, 4, '#5e3820');
    pbE(ex + yon * 8, -11, 5.5, 3, '#c9885a');
    pbE(ex + yon * 4, -11, 2.6, 2, '#e0a978');
  }

  /* --- çaydan buhar --- */
  if (chance(.10))
    part({ x: pbx(146) + rnd(-5, 5), y: pby(18), vx: rnd(-4, 4), vy: rnd(-16, -7),
           life: 1.0, col: 'rgba(255,225,180,.30)', g: -10, sz: 1 });

  /* --- vinyet + dibin karanlığa düşmesi (duragan, onbellekten) --- */
  proCiz('s4on', pro4Vinyet);
}


/* ============================================================
   5) ŞAFAK — kepenk yarım açık, elde anahtar
   ============================================================ */
function pro5Arka() {
  var i, c, r, x0, x1, h;
  var gok = [[72, 96, '#22305c'], [58, 72, '#33406c'], [46, 58, '#4d5478'],
             [36, 46, '#6f6180'], [26, 36, '#9a6f72'], [16, 26, '#c58a5c'],
             [6, 16, '#e0a758'], [-62, 6, '#f2c877']];
  for (i = 0; i < gok.length; i++) pb(-230, gok[i][0], 230, gok[i][1], gok[i][2]);
  pbE(180, 72, 30, 30, '#f6d68a');              /* çatı hizasının üstünde */
  pbE(180, 72, 21, 21, '#fde8b0');
  pbE(180, 72, 13, 13, '#fff6d8');

  var uzak = [[-238, -172, 44], [-178, -126, 60], [128, 192, 52], [186, 238, 40]];
  for (i = 0; i < uzak.length; i++) {
    x0 = uzak[i][0]; x1 = uzak[i][1]; h = uzak[i][2];
    pb(x0, -36, x1, h, '#4a4258');
    pb(x0 - 2, h, x1 + 2, h + 3, '#5e5468');
  }
  var kom = [[-238, -144], [144, 238]];
  for (i = 0; i < 2; i++) {
    x0 = kom[i][0]; x1 = kom[i][1];
    pb(x0, -36, x1, 54, '#5a4c4a');
    pb(x0, 54, x1, 59, '#7a6656');
    pb(x0, -36, x0 + 4, 54, '#7a6656');
    for (c = 0; c < 3; c++)
      for (r = 0; r < 3; r++)
        pb(x0 + 14 + c * 28, -22 + r * 22, x0 + 26 + c * 28, -8 + r * 22, '#3a3442');
  }

  /* sokak */
  pb(-240, -61, 240, -48, '#3a3038');
  pb(-240, -48, 240, -42, '#6a6058');
  pb(-240, -42, 240, -40, '#a8a096');
  pb(-240, -40, 240, -38, '#8a8078');
  for (i = 0; i < 11; i++) pb(-224 + i * 46, -42, -223 + i * 46, -38, '#7a7268');

  /* --- dükkânın içi: kepenk ağzından görünen sıcaklık --- */
  pb(-136, -30, 136, 2, '#3a2312');
  var kat = [[-30, -24, '#a8631f'], [-24, -18, '#7d4116'], [-18, -10, '#552c11'],
             [-10, -4, '#3a1e0c'], [-4, 2, '#291406']];
  for (i = 0; i < kat.length; i++) pb(-136, kat[i][0], 136, kat[i][1], kat[i][2]);
  pb(-128, -8, -92, -5, '#6b4122');
  for (i = 0; i < 5; i++)
    pb(-126 + i * 7, -5, -122 + i * 7, 1, ['#3f79c0', '#c9302a', '#d8ac35'][i % 3]);
  pb(30, -6, 108, -3, '#6b4122');
  for (i = 0; i < 5; i++) {
    pb(38 + i * 15, -12, 40 + i * 15, -6, '#8a929a');
    pb(36 + i * 15, -18, 42 + i * 15, -12, '#a5622a');
    pb(37 + i * 15, -17, 40 + i * 15, -14, '#d18c42');
  }
}

function proKey(t, k) {
  var gx = 40, gy = 44, gw = 400, gh = 150, i, r;
  proCiz('s5a', pro5Arka);

  /* şiş + kor */
  pb(-75, -30, -73, 6, '#9aa3ab');
  proSis(-74, -26, 4, 9, 2.4, t);
  for (i = 0; i < 5; i++)
    pb(-88 + i * 6, -26, -84 + i * 6, -23,
       Math.sin(t * 3 + i) > -.2 ? (i % 2 ? '#ffb04a' : '#ff7a2a') : '#a83a12');
  pb(-136, -30, 136, -18, '#6b4122');
  pb(-136, -19, 136, -17, '#a8703f');
  for (i = 0; i < 9; i++)
    pbA(-136, -30 + i * 4, 136, -26 + i * 4, '#ffb04a', .13 - i * .014);

  /* --- cephe: kepenk ağzı gerçek boşluk --- */
  pb(-150, -38, -136, 40, '#4a3524');
  pb(136, -38, 150, 40, '#4a3524');
  pb(144, -38, 150, 40, '#33251a');
  pb(-150, 34, 150, 40, '#4a3524');
  pb(-150, -38, -136, -30, '#33251a');
  pb(136, -38, 150, -30, '#33251a');
  for (i = 0; i < 2; i++) {                    /* fayans yalnız ayakların üstünde */
    pb(-149 + i * 7, -37, -143 + i * 7, -31, i % 2 === 0 ? '#2f6b62' : '#3d8078');
    pb(137 + i * 7, -37, 143 + i * 7, -31, i % 2 === 0 ? '#2f6b62' : '#3d8078');
  }

  /* --- kepenk: sahnenin başında yukarı sürünür --- */
  var ac = clamp((PRO.t - 0.4) * .55, 0, 1);
  var alt = Math.round(-30 + ac * 32);                 /* -30 kapalı, +2 yarı açık */
  for (r = 0; r * 3 + alt < 24; r++) {
    var z = alt + r * 3;
    pb(-136, z, 136, z + 1, '#3a4148');
    pb(-136, z + 1, 136, z + 2, '#5d6772');
    pb(-136, z + 2, 136, z + 3, '#48515a');
  }
  for (var v = -132; v < 136; v += 26) pb(v, alt, v + 2, 24, '#2f363c');
  pb(-136, alt - 3, 136, alt - 1, '#2a3138');
  pb(-136, alt - 1, 136, alt + 2, '#98a2ab');          /* alt laması */
  pb(-140, 24, 140, 34, '#3d464f');
  pb(-140, 32, 140, 34, '#5d6772');
  pb(-142, -30, -136, 34, '#4a5058');
  pb(136, -30, 142, 34, '#4a5058');

  /* --- ışık kaldırıma vuruyor --- */
  var isik = ac * (0.055 + .010 * Math.sin(t * 1.6));
  for (r = 0; r < 18; r++)
    pbA(-136 - r * 3, -33 - r * .6, 136 + r * 3, -31 - r * .6, '#ffcf7a', isik);
  pbA(-140, alt - 4, 140, alt + 2, '#ffd08a', .30 * ac);

  /* --- tabela: sabah ışığında, henüz yanmıyor --- */
  pb(-140, 36, 140, 62, '#7a1a12');
  pb(-136, 39, 136, 59, '#a8281c');
  for (i = 0; i < 12; i++) pb(-132 + i * 23, 36, -127 + i * 23, 40, '#8a7a4a');
  txt('USTA DÖNER', pbx(0), pby(55), '#e8c070', { align: 'c', outline: '#7a1a12' });

  /* --- kol, el, anahtar --- */
  var kal = Math.round(Math.sin(t * 1.5) * 2);
  pb(150, -34 + kal, 240, -8 + kal, '#8e2018');
  pb(150, -12 + kal, 240, -8 + kal, '#c33c2c');
  pb(142, -36 + kal, 156, -6 + kal, '#e4dcc6');
  pb(142, -36 + kal, 156, -32 + kal, '#c2b9a2');
  pbE(128, -21 + kal, 17, 14, '#6f4326');                  /* kontur */
  pbE(128, -21 + kal, 15, 12, '#a86a3e');
  pbE(126, -22 + kal, 13, 10, '#c9885a');
  pbE(123, -24 + kal, 8, 6, '#e0a978');
  for (i = 0; i < 4; i++) {                                /* boğumlar */
    var fz = -33 + i * 7 + kal;
    pbE(119, fz + 3, 10, 4, '#8a5230');
    pbE(118, fz + 3, 8, 3, i % 2 ? '#c9885a' : '#e0a978');
    pb(112, fz, 128, fz + 1, '#6f4326');                   /* parmak arası */
  }
  pbE(125, -9 + kal, 7, 5, '#8a5230');                     /* başparmak */
  pbE(124, -10 + kal, 5, 4, '#e0a978');
  /* anahtar: pirinç, sap halkası + gövde + diş */
  for (i = 0; i < 7; i++)
    pbA(92 - i * 5, -27 - i * 2 + kal, 100 + i * 5, -15 + i * 2 + kal, '#fff0b0', .10);
  ring(pbx(106), pby(-21 + kal), 14, '#a8811f');
  ring(pbx(106), pby(-21 + kal), 13, '#d8ac35');
  ring(pbx(106), pby(-21 + kal), 11, '#ffd75e');
  ring(pbx(106), pby(-21 + kal), 10, '#a8811f');
  pb(52, -25 + kal, 108, -18 + kal, '#a8811f');
  pb(52, -24 + kal, 108, -20 + kal, '#ffd75e');
  pb(52, -34 + kal, 62, -21 + kal, '#d8ac35');
  pb(66, -32 + kal, 74, -21 + kal, '#d8ac35');
  pb(52, -21 + kal, 58, -14 + kal, '#a8811f');
  /* parıltı */
  var isl = [[88, -6], [118, -34], [74, -30]];
  for (i = 0; i < 3; i++) {
    if (Math.sin(t * 3.2 + i * 2.1) < .4) continue;
    pb(isl[i][0] - 4, isl[i][1] + kal, isl[i][0] + 4, isl[i][1] + 1 + kal, '#fff6d8');
    pb(isl[i][0], isl[i][1] - 4 + kal, isl[i][0] + 1, isl[i][1] + 5 + kal, '#fff6d8');
  }
  if (chance(.16))
    part({ x: pbx(106) + rnd(-14, 14), y: pby(-21) + rnd(-12, 12), vx: rnd(-6, 6),
           vy: rnd(-14, -4), life: .7, col: P.au0, g: -4, sz: 1, type: 'star' });

  proBirds(t, gx, gy, gw, 4, .12);
  ctx.globalAlpha = .030 + .012 * Math.sin(t * 1.5);
  for (i = 0; i < 14; i++) fr(gx + 320 - i * 20, gy, 6, gh, '#ffd75e');
  ctx.globalAlpha = 1;
}

/* ---------------- akış ---------------- */
function proStart() { PRO.i = 0; PRO.t = 0; PRO.ch = 0; G.scene = 'prologue'; G.sceneT = 0; }
function proFinish() {
  G.prologueSeen = true;
  saveAll();
  G.scene = 'intro'; G.sceneT = 0;
}

function drawPrologue(t) {
  var S = PRO_SCENES[PRO.i];
  if (!S) { proFinish(); return; }
  PRO.t += 1 / 60;

  /* zemin */
  fr(0, 0, W, H, '#0b0806');
  var k = clamp(PRO.t * 1.1, 0, 1);

  /* sahne çerçevesi (sinema bandı) */
  ctx.save();
  ctx.beginPath(); ctx.rect(40, 44, 400, 150); ctx.clip();
  S.draw(t, k);
  ctx.restore();
  /* çerçeve kenarı */
  rc(39, 43, 402, 152, '#2b2018');
  rc(38, 42, 404, 154, '#5a4230');
  ctx.globalAlpha = .5; rc(37, 41, 406, 156, '#2b2018'); ctx.globalAlpha = 1;
  /* giriş kararması */
  if (k < 1) { ctx.globalAlpha = 1 - k; fr(40, 44, 400, 150, '#000'); ctx.globalAlpha = 1; }

  /* --- metin: harf harf --- */
  /* ONCE cevir, SONRA dilimle. Tersi olursa Turkce harf harf yazilir
     ve cumle tamamlaninca birden Ingilizceye atlar. */
  var satir = [];
  for (var li = 0; li < S.lines.length; li++) satir.push(T(S.lines[li]));
  var full = satir.join('\n');
  var total = full.replace(/\n/g, '').length;
  PRO.ch = Math.min(total, Math.floor(Math.max(0, PRO.t - .8) * 17));
  var shown = 0, ty = 206;
  for (var i = 0; i < satir.length; i++) {
    var line = satir[i];
    var take = clamp(PRO.ch - shown, 0, line.length);
    shown += line.length;
    if (take <= 0) break;
    var big = /^\$/.test(line);
    txt(line.slice(0, take), W / 2, ty, big ? '#e2483a' : P.ui0, { align: 'c', sc: big ? 2 : 0 });
    ty += big ? 20 : 12;
  }
  /* yazma sesi */
  if (PRO.ch < total && PRO.ch > 0 && chance(.22)) SFX.tick();

  /* --- alt bar: gorunur alt kenara yaslanir (dar telefonda bant kirpilir) --- */
  var barY = H - VIEW.bot - 22;
  ctx.globalAlpha = .8; fr(0, barY, W, 22, '#0b0806'); ctx.globalAlpha = 1;
  hl(0, barY, W, '#3a2a1e');
  /* sahne noktaları */
  for (var d = 0; d < PRO_SCENES.length; d++) {
    disc(W / 2 - (PRO_SCENES.length - 1) * 6 + d * 12, barY + 11, 2, d === PRO.i ? P.au0 : '#4a3f34');
  }
  if (button(6, barY + 4, 88, 14, 'ATLA', '#5a4a3a')) { SFX.uiBack(); proFinish(); return; }
  var last = PRO.i === PRO_SCENES.length - 1;
  if (PRO.ch >= total) {
    if (button(W - 84, barY + 4, 78, 14, last ? 'DÜKKÂNI AÇ' : 'DEVAM', last ? '#3f8a4a' : '#7a5a3a', last)) {
      SFX.ui();
      if (last) { proFinish(); return; }
      PRO.i++; PRO.t = 0; PRO.ch = 0;
      return;
    }
  } else if (IN.pressed && IN.y < barY - 2) {
    /* ekrana dokun: metni hemen tamamla */
    PRO.t = .8 + total / 17 + .01;
  }
  /* otomatik geçiş */
  if (PRO.t > S.dur) {
    if (last) { proFinish(); return; }
    PRO.i++; PRO.t = 0; PRO.ch = 0;
  }

  psDraw(); ftDraw();
}
