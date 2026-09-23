/* ============================================================
   BLENDER KARAKTER ATLASLARI
   ============================================================
   Ozel musteri kaliplari (kralice / kuzeyli / cirak / bilge /
   kimyager) ve binekleri (ejderha / karavan / supurge) artik elle
   kodlanmis cizim degil, Blender'da uretilmis sprite atlaslari.

   Neden dosya? Oyunun geri kalani hala kodla ciziliyor; bu bes kalip
   ve uc binek, kodla erisilemeyen bir ayrinti seviyesi istiyordu
   (platin org, kurk pelerin, yuvarlak gozluk, sivri sapka ve asa,
   sari tulum). Toplam 116 KB + 30 KB mini.

   IKI OLCU:
     tam  (64x80)  dukkan ici - oyunun kendi musterisi 61 piksel,
                   sprite 68; kafalar ayni hizaya gelsin diye ayak
                   c.y+12'ye oturuyor (ayak zaten tezgah arkasinda).
     mini (24x30)  sokak - yayalar 16, eski mini karakterler 24
                   piksel. Cizim sirasinda olcekleme piksel sanatini
                   bulaniklastirdigi icin kucuk atlas ONCEDEN
                   uretiliyor (tools/mini.js), oyun 1:1 ciziyor.

   Yuklenemezse (dosya yok, eski onbellek, file:// kisiti) oyun eski
   kodla cizilen surumune duser - sprYuklendi() bunu bildirir.
   ============================================================ */

var SPR = {
  kralice: {
    yol: 'sprites/kralice.png', yolM: 'sprites/kralice-mini.png',
    kw: 64, kh: 80, sut: 8, ax: 32, ay: 76,
    kwM: 24, khM: 30, axM: 12, ayM: 29,
    klip: {
      idle: { s: 0, n: 4, fps: 6, d: true },
      walk: { s: 1, n: 8, fps: 12, d: true },
      greet: { s: 2, n: 6, fps: 8, d: false },
      ride: { s: 3, n: 4, fps: 8, d: true },
      walk_side: { s: 4, n: 8, fps: 12, d: true }
    }
  },
  kuzeyli: {
    yol: 'sprites/kuzeyli.png', yolM: 'sprites/kuzeyli-mini.png',
    kw: 64, kh: 80, sut: 8, ax: 32, ay: 76,
    kwM: 24, khM: 30, axM: 12, ayM: 29,
    klip: {
      idle: { s: 0, n: 4, fps: 6, d: true },
      walk: { s: 1, n: 8, fps: 12, d: true },
      greet: { s: 2, n: 6, fps: 8, d: false },
      ride: { s: 3, n: 4, fps: 8, d: true },
      walk_side: { s: 4, n: 8, fps: 12, d: true }
    }
  },
  cirak: {
    yol: 'sprites/cirak.png', yolM: 'sprites/cirak-mini.png',
    kw: 64, kh: 80, sut: 8, ax: 32, ay: 76,
    kwM: 24, khM: 30, axM: 12, ayM: 29,
    klip: {
      idle: { s: 0, n: 4, fps: 6, d: true },
      walk: { s: 1, n: 8, fps: 12, d: true },
      greet: { s: 2, n: 6, fps: 8, d: false },
      ride: { s: 3, n: 4, fps: 8, d: true },
      walk_side: { s: 4, n: 8, fps: 12, d: true }
    }
  },
  bilge: {
    yol: 'sprites/bilge.png', yolM: 'sprites/bilge-mini.png',
    kw: 64, kh: 80, sut: 8, ax: 32, ay: 76,
    kwM: 24, khM: 30, axM: 12, ayM: 29,
    klip: {
      idle: { s: 0, n: 4, fps: 6, d: true },
      walk: { s: 1, n: 8, fps: 12, d: true },
      greet: { s: 2, n: 6, fps: 8, d: false },
      ride: { s: 3, n: 4, fps: 8, d: true },
      walk_side: { s: 4, n: 8, fps: 12, d: true }
    }
  },
  kimyager: {
    yol: 'sprites/kimyager.png', yolM: 'sprites/kimyager-mini.png',
    kw: 64, kh: 80, sut: 8, ax: 32, ay: 76,
    kwM: 24, khM: 30, axM: 12, ayM: 29,
    klip: {
      idle: { s: 0, n: 4, fps: 6, d: true },
      walk: { s: 1, n: 8, fps: 12, d: true },
      greet: { s: 2, n: 6, fps: 8, d: false },
      ride: { s: 3, n: 4, fps: 8, d: true },
      walk_side: { s: 4, n: 8, fps: 12, d: true }
    }
  },
  ejderha: {
    yol: 'sprites/ejderha.png', yolM: 'sprites/ejderha-mini.png',
    kw: 128, kh: 96, sut: 8, ax: 64, ay: 92,
    kwM: 64, khM: 48, axM: 32, ayM: 46,
    soket: { riderSeat: [66, 54] },
    soketM: { riderSeat: [33, 27] },
    klip: {
      fly: { s: 0, n: 8, fps: 12, d: true },
      land: { s: 1, n: 6, fps: 10, d: false },
      idle: { s: 2, n: 4, fps: 6, d: true },
      takeoff: { s: 3, n: 6, fps: 10, d: false }
    }
  },
  karavan: {
    yol: 'sprites/karavan.png', yolM: 'sprites/karavan-mini.png',
    kw: 96, kh: 48, sut: 8, ax: 48, ay: 44,
    kwM: 72, khM: 36, axM: 36, ayM: 33,
    soket: { doorFoot: [54, 40] },
    soketM: { doorFoot: [41, 30] },
    klip: {
      drive: { s: 0, n: 4, fps: 10, d: true },
      door_open: { s: 1, n: 6, fps: 8, d: false },
      idle: { s: 2, n: 1, fps: 1, d: true },
      door_close: { s: 3, n: 6, fps: 8, d: false }
    }
  },
  supurge: {
    yol: 'sprites/supurge.png', yolM: 'sprites/supurge-mini.png',
    kw: 80, kh: 32, sut: 8, ax: 40, ay: 19,
    kwM: 40, khM: 16, axM: 20, ayM: 10,
    soket: { riderSeat: [43, 17] },
    soketM: { riderSeat: [22, 9] },
    klip: {
      fly: { s: 0, n: 4, fps: 8, d: true },
      land: { s: 1, n: 4, fps: 8, d: false },
      idle: { s: 2, n: 1, fps: 1, d: true }
    }
  }
};

/* Atlasi OLAN kalip adlari. Adlar artik birebir ayni; tablo yine de
   duruyor cunku "hangi kaliplar sprite ile cizilir" sorusunun tek
   cevabi burasi - digerleri oyunun kendi cizimini kullaniyor. */
var SPR_KALIP = {
  kralice: 'kralice', kuzeyli: 'kuzeyli', cirak: 'cirak',
  bilge: 'bilge', kimyager: 'kimyager'
};

var SPR_ISTEK = 0, SPR_TAMAM = 0, SPR_BASLADI = false;

function sprYukle() {
  if (SPR_BASLADI) return;
  /* Ozel karakterler kapaliysa atlaslar derlemeye de girmiyor:
     istek yapmak bos yere 404 uretir. */
  if (typeof OZEL_ACIK !== 'undefined' && !OZEL_ACIK) { SPR_BASLADI = true; return; }
  SPR_BASLADI = true;
  for (var k in SPR) {
    if (!SPR.hasOwnProperty(k)) continue;
    (function (a) {
      ['', 'M'].forEach(function (ek) {
        var yol = ek ? a.yolM : a.yol;
        if (!yol) return;
        SPR_ISTEK++;
        var im = new Image();
        im.onload = function () { a['im' + ek] = im; SPR_TAMAM++; };
        /* Hata da SAYILIR: yoksa yukleme sayaci hic tamamlanmaz ve
           "hazir mi" sorusu sonsuza kadar hayir der. */
        im.onerror = function () { SPR_TAMAM++; };
        im.src = yol;
      });
    })(SPR[k]);
  }
}

/* Bir atlas cizime hazir mi (mini istenirse mini olani). */
function sprVar(id, mini) {
  var a = SPR[id];
  if (!a) return false;
  var im = mini ? a.imM : a.im;
  return !!(im && im.naturalWidth);
}
function sprYuklendi() { return SPR_ISTEK > 0 && SPR_TAMAM >= SPR_ISTEK; }

/* Klipteki kare indeksi.
   u verilirse (0..1) ilerleme DISARIDAN gelir - inis/kalkis gibi
   sureye bagli hareketlerde faz makinesiyle ayni saniyede bitsin. */
function sprKare(id, klip, t, u) {
  var a = SPR[id], c = a && a.klip[klip];
  if (!c) return 0;
  if (u !== undefined && u !== null) {
    return clamp(Math.floor(u * c.n), 0, c.n - 1);
  }
  var i = Math.floor(t * c.fps);
  return c.d ? ((i % c.n) + c.n) % c.n : clamp(i, 0, c.n - 1);
}

/* Atlasi ANKRAJ noktasindan cizer: (x, y) karakterin AYAGI.
   o = { mini, flip, u, kare, alpha, kesAlt }

   kesAlt: bu EKRAN satirinin altinda hicbir sey cizilmez. Binek
   sahnesi icin: paketteki 'ride' pozu aslinda ayakta duran bir poz,
   oldugu gibi konunca binici ejderhanin uzerinde AYAKTA duruyor gibi
   goruluyor. Bacaklar sirt cizgisinden kesilince figur binmis gibi
   okunuyor - 2B'de bacagi hayvanin ote yanina saklamanin standart yolu. */
function sprCiz(id, klip, t, x, y, o) {
  o = o || {};
  var a = SPR[id];
  if (!a) return false;
  var mini = !!o.mini;
  var im = mini ? a.imM : a.im;
  if (!im || !im.naturalWidth) return false;
  var c = a.klip[klip];
  if (!c) return false;
  var kw = mini ? a.kwM : a.kw, kh = mini ? a.khM : a.kh;
  var ax = mini ? a.axM : a.ax, ay = mini ? a.ayM : a.ay;
  var f = o.kare !== undefined ? clamp(o.kare, 0, c.n - 1) : sprKare(id, klip, t, o.u);
  var sx = (f % a.sut) * kw, sy = c.s * kh;
  var dx = Math.round(x) - ax, dy = Math.round(y) - ay;
  var eskiA = ctx.globalAlpha;
  if (o.alpha !== undefined) ctx.globalAlpha = o.alpha;
  ctx.imageSmoothingEnabled = false;
  var kirp = o.kesAlt !== undefined;
  if (kirp) {
    /* kirpma EKRAN uzayinda: aynalama donusumunden ONCE kuruluyor */
    ctx.save();
    ctx.beginPath();
    ctx.rect(dx - 8, dy - 8, kw + 16, (o.kesAlt - dy) + 8);
    ctx.clip();
  }
  if (o.flip) {
    /* Ayak noktasi etrafinda aynala: govde kaymasin.
       translate(2x)+scale(-1) sonrasi yerel X ekranda 2x-X'e dusuyor;
       ankrajin x'e oturmasi icin cizim yeri yine dx (= x - ax). */
    ctx.save();
    ctx.translate(Math.round(x) * 2, 0); ctx.scale(-1, 1);
    ctx.drawImage(im, sx, sy, kw, kh, dx, dy, kw, kh);
    ctx.restore();
  } else {
    ctx.drawImage(im, sx, sy, kw, kh, dx, dy, kw, kh);
  }
  if (kirp) ctx.restore();
  ctx.globalAlpha = eskiA;
  return true;
}

/* Soket (binici oturagi, karavan kapisi) ankraja gore ofset degil,
   MUTLAK ekran noktasi olarak dondurulur. */
function sprSoket(id, ad, x, y, mini, flip) {
  var a = SPR[id];
  if (!a || !a.soket) return null;
  var s = mini ? (a.soketM || a.soket)[ad] : a.soket[ad];
  if (!s) return null;
  var ax = mini ? a.axM : a.ax, ay = mini ? a.ayM : a.ay;
  /* Aynalanmis cizimde soket de aynalanir; yoksa binici ejderhanin
     yanlis tarafinda, havada oturur. */
  var dx = s[0] - ax;
  return { x: Math.round(x) + (flip ? -dx : dx), y: Math.round(y) + (s[1] - ay) };
}

/* ---------------- dukkan ici ozel musteri ----------------
   drawCustomer bunu once cagirir; true donerse oyunun kendi
   govde/kafa/aksesuar cizimi ATLANIR. Iki yuz ust uste binmesin. */
function sprMusteri(c, t, x, y) {
  var L = c.look;
  if (!L || !L.kalip) return false;
  var id = SPR_KALIP[L.kalip];
  if (!id || !sprVar(id, false)) return false;

  var klip = 'idle', flip = false;
  if (c.state === 'leave') {
    /* cikista yon leaveDir'den gelir; hedef yok */
    klip = 'walk_side';
    flip = (c.leaveDir > 0 ? 1 : -1) < 0;
  } else if (c.state === 'walkin') {
    klip = 'walk_side';
    flip = ((c.tx !== undefined ? c.tx : c.x) - c.x) < 0;
  } else if (c.mood === 'happy' || c.mood === 'served') {
    klip = 'greet';
  }
  /* Ayak c.y+12: sprite 68, oyunun musterisi 61 piksel boyunda.
     Ayaklari hizalarsak kafa 7 piksel yukarida kalirdi; ayak zaten
     tezgahin arkasinda gorunmuyor, o yuzden KAFA hizalaniyor. */
  return sprCiz(id, klip, t + (L.seed || 0) * .13, x, y + 12, { flip: flip });
}

/* Duygu efektleri: sprite yolunda da kalsin. drawCustomer'in sonundaki
   blogun ayni isi - ofke damari/dumani ve servis kalpleri oyun geri
   bildirimi, gorselden bagimsiz. */
function sprDuygu(hx, hy, mood, t) {
  var ang = mood === 'angry';
  if (ang && chance(.05)) smoke(hx + rnd(-11, 11), hy - 13, 1, 'rgba(230,90,60,.55)');
  if (ang && Math.sin(t * 8) > 0) {
    var vx = hx + 8, vy = hy - 9;
    px(vx, vy, '#e04a3a'); px(vx + 1, vy - 1, '#e04a3a');
    px(vx + 2, vy, '#e04a3a'); px(vx + 1, vy + 1, '#e04a3a');
  }
  if (mood === 'served' && chance(.06)) {
    part({ x: hx + rnd(-9, 9), y: hy - 10, vx: rnd(-6, 6), vy: rnd(-24, -12),
           life: .9, col: '#e2483a', g: -8, sz: 2 });
  }
}
