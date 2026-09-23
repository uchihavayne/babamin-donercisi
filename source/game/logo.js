/* ============================================================
   BASLIK LOGOSU — B · SIS (Blender'da uc katman, burada ust uste)
   ============================================================
   Veri js/logo-veri.js'te ve URETILMIS bir dosya:
     blender/models/logo_anim.py  -> render (her katman ayri)
     blender/logo_paketle.py      -> kirp, paletli PNG, data URI
   Gorseli degistirmek icin oradan yeniden uret, bu dosyaya dokunma.

   Katmanlar, derinlik sirasiyla (2B'de ust uste koymak 3B render'in
   verecegi ortusmenin aynisi — Blender'da da bu sirayla duruyorlar):
     arka : isitici. Baslik ekrani her acildiginda once SONUK durur,
            sonra alttan uste satir satir YANAR — prologun son sahnesi
            "Ocagi yaktim, kepengi kaldirdim." Ardindan kareler kendi
            fazlarinda kiprasir (toplam parlaklik sabit).
     sis  : doner konisi, tam tur 64 kare. Hiz oyundaki sisle ayni
            (game.js: s.rot += dt * 1.15 -> ~5.5 sn/tur).
     on   : kurdele + "BABAMIN" levhasi + yazi, SECILI DILDE.
   Kodla ustune: giriste hafif dusus, altin harflerde gezinen parilti
   (dil degisince de bir kez), et konisinden buhar, isiticidan kivilcim.

   Resimler cozulmeden once (ilk kare) ya da veri yoksa logoCiz false
   doner; drawTitle o durumda eski, kodla cizilen tabelaya duser.
   ============================================================ */
var LOGO = { im: {}, istek: 0, tamam: 0, giris: -99, son: -99, dil: null, dilT: -99, pc: null };

var LOGO_DUSUS = 0.5;          /* giris dususu (sn) */
var LOGO_PARILTI = 0.7;        /* parilti bandinin gecis suresi (sn) */
var LOGO_PARILTI_ARA = 6.0;    /* kendiliginden parilti araligi (sn) */

function logoYukle() {
  if (LOGO.istek || typeof LOGO_VERI === 'undefined') return;
  var V = LOGO_VERI;
  function yukle(ad, src) {
    LOGO.istek++;
    var im = new Image();
    im.onload = function () { LOGO.im[ad] = im; LOGO.tamam++; };
    /* hata da sayilir: yoksa "hazir mi" sorusu sonsuza kadar hayir der */
    im.onerror = function () { LOGO.tamam++; };
    im.src = src;
  }
  yukle('arka', V.arka.src);
  yukle('sis', V.sis.src);
  for (var d in V.on) {
    if (!V.on.hasOwnProperty(d)) continue;
    yukle('on_' + d, V.on[d].src);
    yukle('maske_' + d, V.on[d].maske);
  }
}

function logoDil() {
  return (typeof LOGO_VERI !== 'undefined' && LOGO_VERI.on[LANG]) ? LANG : 'en';
}

function logoHazir() {
  var im = LOGO.im;
  return !!(im.arka && im.sis && im['on_' + logoDil()]);
}

/* Baslik ekranina GIRIS ani. drawTitle bunu her karede, paneller
   acikken de (logo cizilmese bile) cagirir: yarim saniyeden uzun ara
   verildiyse (ilk acilis, oyundan ANA MENU'ye donus) yeni bir giristir,
   isitici yeniden yakilir. Panel acip kapamak yeniden yakmaz. */
function logoGiris(t) {
  if (t - LOGO.son > 0.5) LOGO.giris = t;
  LOGO.son = t;
}

/* Logo cercevesinin yuksekligi — baslik yerlesimi hesabi icin. */
function logoYukseklik() {
  return typeof LOGO_VERI === 'undefined' ? 56 : LOGO_VERI.h;
}

/* Isiticinin kacinci karesi: once sonuk, sonra atesleme, sonra dongu. */
function logoIsiticiKare(t) {
  var A = LOGO_VERI.arka, u = t - LOGO.giris - A.yakBas;
  if (u < 0) return 0;
  if (u < A.yakAdim * A.yak) return Math.min(A.yak - 1, Math.floor(u / A.yakAdim));
  return A.yak + (Math.floor(t * A.titFps) % A.tit);
}
function logoYandi(t) {
  var A = LOGO_VERI.arka;
  return t - LOGO.giris - A.yakBas >= A.yakAdim * A.yak;
}

/* cx: logonun (Blender eksenindeki) ortasi, y: ust kenari. */
function logoCiz(t, cx, y) {
  if (typeof LOGO_VERI === 'undefined' || !logoHazir()) return false;
  var V = LOGO_VERI, dil = logoDil();
  if (LOGO.dil !== dil) {
    /* ilk karede degil, sonradan secilince: parilti secimi onaylasin */
    if (LOGO.dil !== null) LOGO.dilT = t;
    LOGO.dil = dil;
  }
  var u = t - LOGO.giris;
  var dy = u < LOGO_DUSUS ? -Math.round((1 - easeOutBack(clamp(u / LOGO_DUSUS, 0, 1))) * 26) : 0;
  var x = Math.round(cx - V.cx);
  y = Math.round(y) + dy;
  ctx.imageSmoothingEnabled = false;

  /* 1) isitici */
  var A = V.arka, k = logoIsiticiKare(t);
  ctx.drawImage(LOGO.im.arka, k * A.kw, 0, A.kw, A.kh, x + A.x, y + A.y, A.kw, A.kh);
  /* 2) sis */
  var S = V.sis, f = Math.floor(t * S.n / S.turSn) % S.n;
  ctx.drawImage(LOGO.im.sis, (f % S.sut) * S.kw, Math.floor(f / S.sut) * S.kh, S.kw, S.kh,
                x + S.x, y + S.y, S.kw, S.kh);
  /* 3) kurdele + yazi */
  var O = V.on[dil];
  ctx.drawImage(LOGO.im['on_' + dil], x + O.x, y + O.y);
  /* 4) parilti: ilk yanistan sonra duzenli, dil degisince hemen */
  var p = -1;
  if (t - LOGO.dilT < LOGO_PARILTI) p = (t - LOGO.dilT) / LOGO_PARILTI;
  else if (u > 1.4) {
    var faz = (u - 1.4) % LOGO_PARILTI_ARA;
    if (faz < LOGO_PARILTI) p = faz / LOGO_PARILTI;
  }
  if (p >= 0) logoParilti(O, LOGO.im['maske_' + dil], x + O.x, y + O.y, p);
  /* 5) buhar ve kivilcim — isitici yandiktan sonra */
  if (logoYandi(t) && dy === 0) {
    if (chance(.07)) {
      smoke(x + S.tepe[0] + rnd(-9, 9), y + S.tepe[1] + 7, 1, 'rgba(255,248,236,.55)', { sz: 2 });
    }
    if (chance(.10)) {
      var I = V.isitici, sag = chance(.5);
      part({ x: x + (sag ? rnd(I[2] - 16, I[2] - 4) : rnd(I[0] + 4, I[0] + 16)), y: y + I[1] + rnd(4, 14),
             vx: rnd(-5, 5), vy: rnd(-26, -12), life: rnd(.5, 1), col: pick([P.f1, P.f2, P.f0]),
             g: -10, sz: 1 });
    }
  }
  return true;
}

/* Altin harflerin uzerinden capraz bir isik bandi gecer. Bant yalniz
   maskenin (altin piksellerin) ICINDE gorunur: kucuk bir tuvalde once
   bant cizilir, sonra maske 'destination-in' ile ustune basilir. Tersi
   (once maske, bant 'source-in') CALISMAZ: source-in sinirsiz bir islem,
   ilk fillRect kendi dikdortgeni disindaki maskenin tamamini siliyor,
   bant hic gorunmuyordu. Kenarlar keskin, renkler paletten (au0 + beyaz).
   p: 0..1 ilerleme. */
function logoParilti(O, maske, x, y, p) {
  if (!maske) return;
  var pc = LOGO.pc;
  if (!pc) {
    try { pc = LOGO.pc = document.createElement('canvas'); } catch (e) { return; }
  }
  if (pc.width !== O.w || pc.height !== O.h) { pc.width = O.w; pc.height = O.h; }
  var g = pc.getContext('2d');
  if (!g) return;
  g.imageSmoothingEnabled = false;
  g.globalCompositeOperation = 'source-over';
  g.clearRect(0, 0, O.w, O.h);
  var bx0 = -20 + p * (O.w + 60);
  for (var yy = 0; yy < O.h; yy++) {
    var bx = Math.round(bx0 - (O.h - yy) * .5);
    g.fillStyle = P.au0; g.fillRect(bx - 2, yy, 5, 1);
    g.fillStyle = P.white; g.fillRect(bx - 1, yy, 3, 1);
  }
  g.globalCompositeOperation = 'destination-in';
  g.drawImage(maske, 0, 0);
  g.globalCompositeOperation = 'source-over';
  ctx.drawImage(pc, x, y);
}

logoYukle();
