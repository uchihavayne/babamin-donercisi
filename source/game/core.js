/* ============================================================
   DÖNER EFSANESİ — core.js
   Piksel motoru: tuval, font, girdi, parçacık, ses, matematik
   ============================================================ */
'use strict';

var W = 480, H = 270;
var cv = document.getElementById('cv');
var ctx = cv.getContext('2d', { alpha: false });
ctx.imageSmoothingEnabled = false;

var TOUCH = ('ontouchstart' in window) || navigator.maxTouchPoints > 0;

/* ---------- ekran ölçekleme ----------
   Oyun 16:9, telefon 19.5:9. Olcek YUKSEKLIKLE sinirlandigi icin yanlarda
   genis siyah bant kaliyor ve her sey kucuk duruyordu (iPhone 12 mini'de
   145px bant, olcek 1.39). Cozum: dikeydeki OLU alani kirpip olcegi
   buyutmek. Kirpilabilecek iki bant var:
     ust  -> HUD seridi (HUD asagi kaydirilir, icerik kaybi yok)
     alt  -> zemin tahtasi (tamamen dekoratif)
   Kirpma yalnizca gerektigi kadar yapilir; genis ekranda VIEW sifir kalir. */
var VIEW = { top: 0, bot: 0, right: 0 };
var VIEW_UST_MAX = 34;      /* HUD seridi (mobilde HUD kompaktlasir) */
var VIEW_ALT_MAX = 12;      /* zemin tahtasi */
var VIEW_SAG_MAX = 8;       /* sagdaki olu duvar seridi: stok/tatli 472'de biter */
function fitScreen() {
  /* HATA: viewport olculuyordu ama #wrap'te safe-area dolgusu var.
     Tuval dolgulu kutudan buyuk cikip tasiyor, telefonda ust satir
     (GUN / sure / borc) kesiliyordu. Artik kabin IC kutusu olculuyor. */
  var vw, vh;
  var kab = document.getElementById('wrap');
  if (kab) {
    var r = kab.getBoundingClientRect(), cs = getComputedStyle(kab);
    vw = r.width - (parseFloat(cs.paddingLeft) || 0) - (parseFloat(cs.paddingRight) || 0);
    vh = r.height - (parseFloat(cs.paddingTop) || 0) - (parseFloat(cs.paddingBottom) || 0);
  }
  if (!vw || !vh || vw < 40 || vh < 40) {
    vw = (window.visualViewport ? window.visualViewport.width : window.innerWidth);
    vh = (window.visualViewport ? window.visualViewport.height : window.innerHeight);
  }
  var ust = 0, alt = 0, sag = 0;
  if (TOUCH && vw > vh) {
    /* 1) SAG: yalniz GENISLIK sinirliysa anlamli. Centiksiz tarayicida
       olcek yukseklikle sinirlidir ve sagdan kirpmak sadece icerik goturur;
       o yuzden dikey butce sonuna kadar harcansa BILE genislik sinirli
       kaliyorsa kirpilir. */
    var HminOlasi = H - VIEW_UST_MAX - VIEW_ALT_MAX;
    if (vw / W < vh / HminOlasi) {
      sag = Math.min(VIEW_SAG_MAX, Math.max(0, Math.round(W - vw * HminOlasi / vh)));
    }
    /* 2) YUKSEK: kalan orani kapatacak kadar (fazlasi bosuna icerik goturur) */
    var Wv0 = W - sag;
    var gerek = Math.round(H - vh * Wv0 / vw);
    if (gerek > 0) {
      alt = Math.min(VIEW_ALT_MAX, Math.round(gerek * VIEW_ALT_MAX / (VIEW_UST_MAX + VIEW_ALT_MAX)));
      ust = Math.min(VIEW_UST_MAX, gerek - alt);
    }
  }
  var Hv = H - ust - alt, Wv = W - sag;
  if (VIEW.top !== ust || VIEW.bot !== alt || VIEW.right !== sag ||
      cv.height !== Hv || cv.width !== Wv) {
    VIEW.top = ust; VIEW.bot = alt; VIEW.right = sag;
    /* Tuvalin IC olculeri gorunur banda esitlenir; cizim VIEW.top kadar
       yukari otelenir. Sag kirpma otelemesiz: fazlasi zaten cizilmez. */
    cv.width = Wv; cv.height = Hv;
    ctx.imageSmoothingEnabled = false;   /* boyut degisince sifirlanir */
  }
  var s = Math.min(vw / Wv, vh / Hv);
  /* büyük ekranda tam kat ölçek (net piksel); küçük ekranda ekranı doldur */
  if (s >= 2) { var si = Math.floor(s); if (s - si < 0.34) s = si; }
  if (s <= 0) s = 1;
  cv.style.width = Math.round(Wv * s) + 'px';
  cv.style.height = Math.round(Hv * s) + 'px';
}
window.addEventListener('resize', fitScreen);
window.addEventListener('orientationchange', function () { setTimeout(fitScreen, 120); });
if (window.visualViewport) window.visualViewport.addEventListener('resize', fitScreen);
fitScreen();

/* ---------- tam ekran ---------- */
function fsOn() { return !!(document.fullscreenElement || document.webkitFullscreenElement); }
function fsToggle() {
  try {
    if (fsOn()) {
      (document.exitFullscreen || document.webkitExitFullscreen).call(document);
    } else {
      var el = document.documentElement;
      (el.requestFullscreen || el.webkitRequestFullscreen).call(el);
      if (screen.orientation && screen.orientation.lock) {
        screen.orientation.lock('landscape').catch(function () { });
      }
    }
  } catch (e) { }
  setTimeout(fitScreen, 200);
}

/* ---------- matematik ---------- */
function clamp(v, a, b) { return v < a ? a : (v > b ? b : v); }
function lerp(a, b, t) { return a + (b - a) * t; }
function approach(a, b, d) { return a < b ? Math.min(a + d, b) : Math.max(a - d, b); }
function sat(v) { return v < 0 ? 0 : (v > 1 ? 1 : v); }
function ease(t) { return t * t * (3 - 2 * t); }
function easeOut(t) { return 1 - (1 - t) * (1 - t); }
function easeIn(t) { return t * t; }
function easeOutBack(t) { var c = 1.70158; return 1 + (c + 1) * Math.pow(t - 1, 3) + c * Math.pow(t - 1, 2); }
function easeOutElastic(t) { if (t <= 0) return 0; if (t >= 1) return 1; var p = 0.35; return Math.pow(2, -10 * t) * Math.sin((t - p / 4) * (2 * Math.PI) / p) + 1; }
function easeInOut(t) { return t < .5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2; }
var TAU = Math.PI * 2;
function rnd(a, b) { if (a === undefined) return Math.random(); if (b === undefined) return Math.random() * a; return a + Math.random() * (b - a); }
function rndi(a, b) { return Math.floor(rnd(a, b + 1)); }
function pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; }
function chance(p) { return Math.random() < p; }
function shuffle(a) { for (var i = a.length - 1; i > 0; i--) { var j = Math.floor(Math.random() * (i + 1)); var t = a[i]; a[i] = a[j]; a[j] = t; } return a; }
function hash1(n) { var s = Math.sin(n * 127.1) * 43758.5453; return s - Math.floor(s); }
function dist(x1, y1, x2, y2) { var dx = x2 - x1, dy = y2 - y1; return Math.sqrt(dx * dx + dy * dy); }
function inRect(px, py, x, y, w, h) { return px >= x && px < x + w && py >= y && py < y + h; }
/* büyük paraları okunur yaz: 1.234.567 */
function fmtMoney(n) {
  n = Math.round(n || 0);
  var neg = n < 0; if (neg) n = -n;
  var s = '' + n, out = '';
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 === 0) out += '.';
    out += s[i];
  }
  return (neg ? '-' : '') + out;
}
/* dar alanlar için kısa biçim: 4.85M */
function fmtShort(n) {
  n = Math.round(n || 0);
  if (n >= 1000000) return (n / 1000000).toFixed(n >= 10000000 ? 1 : 2) + 'M';
  if (n >= 10000) return Math.round(n / 1000) + 'K';
  return fmtMoney(n);
}
function fmtTime(sec) {
  sec = Math.max(0, Math.ceil(sec));
  var m = Math.floor(sec / 60), s = sec % 60;
  return m + ':' + (s < 10 ? '0' : '') + s;
}

/* ---------- palet ---------- */
var P = {
  ink: '#241a20', ink2: '#3a2a30', white: '#fffaf0', bone: '#efe4d2',
  st0: '#e6e6ea', st1: '#c8c9d2', st2: '#a4a5b3', st3: '#7d7e8d', st4: '#5b5c69',
  tl0: '#6ba7c4', tl1: '#4d87a6', tl2: '#3a6c88', tl3: '#2c5369', tl4: '#1e3c4e',
  grout: '#25485c',
  mt0: '#f2f4f6', mt1: '#d3d8de', mt2: '#aeb5be', mt3: '#878e99', mt4: '#5f6672', mt5: '#41474f',
  wd0: '#a8703f', wd1: '#8a5730', wd2: '#6b4122', wd3: '#4e2e17',
  m0: '#ffd9a0', m1: '#f0b269', m2: '#d18c42', m3: '#a5622a', m4: '#78421a', m5: '#4d290f',
  raw: '#e79f8c', raw2: '#c97a68',
  f0: '#fff3b0', f1: '#ffd257', f2: '#ff9c2e', f3: '#ef5f22', f4: '#b8331a',
  g0: '#cfe08a', g1: '#a8c257', g2: '#7fa138', g3: '#5b7726', g4: '#3d5219',
  s0: '#fffdf2', s1: '#efe7d0', s2: '#d6cbae', s3: '#b3a684',
  p0: '#ffe9a3', p1: '#f7cc63', p2: '#dba53a', p3: '#a97724', p4: '#7d5417',
  cola: '#43220f', cola2: '#6b3a1c', or0: '#ffb03c', or1: '#f0821c', ay0: '#f6f4ea',
  au0: '#fff2a8', au1: '#ffd34e', au2: '#e0a41f', au3: '#a97113',
  red0: '#e05a48', red1: '#c33c2c', red2: '#96271c', red3: '#6d1a12',
  skin0: '#ffdcb0', skin1: '#f0bd8a', skin2: '#cf9560', skin3: '#a06f42',
  ok: '#78d06a', warn: '#ffcb3d', bad: '#e8483a', blue: '#57a9e0', blue2: '#3b7fb5',
  pur: '#9a6bcf', pink: '#f090b8',
  ui0: '#fdf3dd', ui1: '#e5cfa4', ui2: '#b99a68', ui3: '#7d603a', ui4: '#4a3722', ui5: '#2b1f14',
  sh: 'rgba(0,0,0,.30)', sh2: 'rgba(0,0,0,.55)'
};

/* ---------- çizim yardımcıları ---------- */
function cls(c) { ctx.fillStyle = c; ctx.fillRect(0, 0, W, H); }
function fr(x, y, w, h, c) { ctx.fillStyle = c; ctx.fillRect(x | 0, y | 0, w | 0, h | 0); }
function px(x, y, c) { ctx.fillStyle = c; ctx.fillRect(x | 0, y | 0, 1, 1); }
function rc(x, y, w, h, c) { ctx.fillStyle = c; x |= 0; y |= 0; w |= 0; h |= 0; ctx.fillRect(x, y, w, 1); ctx.fillRect(x, y + h - 1, w, 1); ctx.fillRect(x, y, 1, h); ctx.fillRect(x + w - 1, y, 1, h); }
function hl(x, y, w, c) { ctx.fillStyle = c; ctx.fillRect(x | 0, y | 0, w | 0, 1); }
function vl(x, y, h, c) { ctx.fillStyle = c; ctx.fillRect(x | 0, y | 0, 1, h | 0); }
function ln(x0, y0, x1, y1, c) {
  x0 |= 0; y0 |= 0; x1 |= 0; y1 |= 0;
  var dx = Math.abs(x1 - x0), sx = x0 < x1 ? 1 : -1;
  var dy = -Math.abs(y1 - y0), sy = y0 < y1 ? 1 : -1, err = dx + dy;
  ctx.fillStyle = c;
  for (var i = 0; i < 999; i++) {
    ctx.fillRect(x0, y0, 1, 1);
    if (x0 === x1 && y0 === y1) break;
    var e2 = 2 * err;
    if (e2 >= dy) { err += dy; x0 += sx; }
    if (e2 <= dx) { err += dx; y0 += sy; }
  }
}
function disc(cx, cy, r, c) {
  ctx.fillStyle = c; cx = Math.round(cx); cy = Math.round(cy);
  for (var y = -r; y <= r; y++) {
    var w = Math.floor(Math.sqrt(r * r - y * y) + .5);
    if (w > 0 || r === 0) ctx.fillRect(cx - w, cy + y, w * 2 + 1, 1);
  }
}
function ring(cx, cy, r, c) {
  ctx.fillStyle = c; cx = Math.round(cx); cy = Math.round(cy);
  var x = r, y = 0, e = 1 - r;
  while (x >= y) {
    var pts = [[x, y], [y, x], [-x, y], [-y, x], [-x, -y], [-y, -x], [x, -y], [y, -x]];
    for (var i = 0; i < 8; i++) ctx.fillRect(cx + pts[i][0], cy + pts[i][1], 1, 1);
    y++; if (e < 0) e += 2 * y + 1; else { x--; e += 2 * (y - x) + 1; }
  }
}
function ell(cx, cy, rx, ry, c) {
  ctx.fillStyle = c; cx = Math.round(cx); cy = Math.round(cy);
  for (var y = -ry; y <= ry; y++) {
    var t = 1 - (y * y) / (ry * ry); if (t < 0) continue;
    var w = Math.floor(rx * Math.sqrt(t) + .5);
    ctx.fillRect(cx - w, cy + y, w * 2 + 1, 1);
  }
}
function ellOut(cx, cy, rx, ry, c) {
  cx = Math.round(cx); cy = Math.round(cy); ctx.fillStyle = c;
  var prev = -1;
  for (var y = -ry; y <= ry; y++) {
    var t = 1 - (y * y) / (ry * ry); if (t < 0) continue;
    var w = Math.floor(rx * Math.sqrt(t) + .5);
    if (y === -ry || y === ry) ctx.fillRect(cx - w, cy + y, w * 2 + 1, 1);
    else { ctx.fillRect(cx - w, cy + y, 1, 1); ctx.fillRect(cx + w, cy + y, 1, 1); }
    if (prev >= 0 && Math.abs(w - prev) > 1) {
      var lo = Math.min(w, prev), hi = Math.max(w, prev);
      ctx.fillRect(cx - hi, cy + y, hi - lo, 1); ctx.fillRect(cx + lo, cy + y, hi - lo, 1);
    }
    prev = w;
  }
}
function rrect(x, y, w, h, r, c) {
  ctx.fillStyle = c; x |= 0; y |= 0; w |= 0; h |= 0;
  ctx.fillRect(x + r, y, w - r * 2, h);
  ctx.fillRect(x, y + r, r, h - r * 2);
  ctx.fillRect(x + w - r, y + r, r, h - r * 2);
  for (var i = 0; i < r; i++) {
    var d = Math.round(r - Math.sqrt(r * r - (r - i - 1) * (r - i - 1)));
    ctx.fillRect(x + d, y + i, w - d * 2, 1);
    ctx.fillRect(x + d, y + h - 1 - i, w - d * 2, 1);
  }
}
function rrectOut(x, y, w, h, r, c) {
  x |= 0; y |= 0; w |= 0; h |= 0; ctx.fillStyle = c;
  ctx.fillRect(x + r, y, w - r * 2, 1); ctx.fillRect(x + r, y + h - 1, w - r * 2, 1);
  ctx.fillRect(x, y + r, 1, h - r * 2); ctx.fillRect(x + w - 1, y + r, 1, h - r * 2);
  for (var i = 0; i < r; i++) {
    var d = Math.round(r - Math.sqrt(r * r - (r - i - 1) * (r - i - 1)));
    ctx.fillRect(x + d, y + i, 1, 1); ctx.fillRect(x + w - 1 - d, y + i, 1, 1);
    ctx.fillRect(x + d, y + h - 1 - i, 1, 1); ctx.fillRect(x + w - 1 - d, y + h - 1 - i, 1, 1);
  }
}
var BAYER = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5];
function dith(x, y, w, h, c, amt) {
  ctx.fillStyle = c; x |= 0; y |= 0;
  var th = amt * 16;
  for (var j = 0; j < h; j++) for (var i = 0; i < w; i++) {
    if (BAYER[((j & 3) << 2) | (i & 3)] < th) ctx.fillRect(x + i, y + j, 1, 1);
  }
}
function shadowEll(cx, cy, rx, ry) { ctx.globalAlpha = .28; ell(cx, cy, rx, ry, '#000'); ctx.globalAlpha = 1; }

/* ---------- FONT (5x8 bitmap, Türkçe) ---------- */
var GLYPHS = {
  'A': '...../.###./#...#/#...#/#####/#...#/#...#/.....',
  'B': '...../####./#...#/####./#...#/#...#/####./.....',
  'C': '...../.###./#...#/#..../#..../#...#/.###./.....',
  'D': '...../####./#...#/#...#/#...#/#...#/####./.....',
  'E': '...../#####/#..../####./#..../#..../#####/.....',
  'F': '...../#####/#..../####./#..../#..../#..../.....',
  'G': '...../.###./#..../#..../#.###/#...#/.###./.....',
  'H': '...../#...#/#...#/#####/#...#/#...#/#...#/.....',
  'I': '...../.###./..#../..#../..#../..#../.###./.....',
  'J': '...../..###/...#./...#./...#./#..#./.##../.....',
  'K': '...../#...#/#..#./###../#..#./#..#./#...#/.....',
  'L': '...../#..../#..../#..../#..../#..../#####/.....',
  'M': '...../#...#/##.##/#.#.#/#...#/#...#/#...#/.....',
  'N': '...../#...#/##..#/#.#.#/#..##/#...#/#...#/.....',
  'O': '...../.###./#...#/#...#/#...#/#...#/.###./.....',
  'P': '...../####./#...#/#...#/####./#..../#..../.....',
  'Q': '...../.###./#...#/#...#/#.#.#/#..#./.##.#/.....',
  'R': '...../####./#...#/#...#/####./#..#./#...#/.....',
  'S': '...../.###./#..../.###./....#/#...#/.###./.....',
  'T': '...../#####/..#../..#../..#../..#../..#../.....',
  'U': '...../#...#/#...#/#...#/#...#/#...#/.###./.....',
  'V': '...../#...#/#...#/#...#/#...#/.#.#./..#../.....',
  'W': '...../#...#/#...#/#...#/#.#.#/##.##/#...#/.....',
  'X': '...../#...#/.#.#./..#../..#../.#.#./#...#/.....',
  'Y': '...../#...#/.#.#./..#../..#../..#../..#../.....',
  'Z': '...../#####/....#/...#./..#../.#.../#####/.....',
  'Â': '.###./.###./#...#/#...#/#####/#...#/#...#/.....',
  'â': '.##./..../.##./...#/.###/#..#/.###/....',
  'Î': '.###./.###./..#../..#../..#../..#../.###./.....',
  'î': '.##./..../.#../.#../.#../.#../.#../....',
  'Û': '.###./#...#/#...#/#...#/#...#/#...#/.###./.....',
  'û': '.##./..../#..#/#..#/#..#/#..#/.###/....',
  'Ç': '...../.###./#...#/#..../#..../#...#/.###./..#..',
  'Ğ': '.###./.###./#..../#..../#.###/#...#/.###./.....',
  'İ': '..#../.###./..#../..#../..#../..#../.###./.....',
  'Ö': '.#.#./.###./#...#/#...#/#...#/#...#/.###./.....',
  'Ş': '...../.###./#..../.###./....#/#...#/.###./..#..',
  'Ü': '.#.#./#...#/#...#/#...#/#...#/#...#/.###./.....',
  'a': '..../..../.##./...#/.###/#..#/.###/....',
  'b': '..../#.../#.../###./#..#/#..#/###./....',
  'c': '..../..../.###/#.../#.../#.../.###/....',
  'd': '..../...#/...#/.###/#..#/#..#/.###/....',
  'e': '..../..../.##./#..#/####/#.../.###/....',
  'f': '..../..##/.#../###./.#../.#../.#../....',
  'g': '..../..../.###/#..#/#..#/.###/...#/###.',
  'h': '..../#.../#.../###./#..#/#..#/#..#/....',
  'i': '..../.#../..../.#../.#../.#../.#../....',
  'ı': '..../..../..../.#../.#../.#../.#../....',
  'j': '..../..#./..../..#./..#./..#./..#./##..',
  'k': '..../#.../#.../#.#./##../#.#./#.#./....',
  'l': '..../##../.#../.#../.#../.#../.###/....',
  'm': '...../...../#####/#.#.#/#.#.#/#.#.#/#.#.#/.....',
  'n': '..../..../###./#..#/#..#/#..#/#..#/....',
  'o': '..../..../.##./#..#/#..#/#..#/.##./....',
  'p': '..../..../###./#..#/#..#/###./#.../#...',
  'q': '..../..../.###/#..#/#..#/.###/...#/...#',
  'r': '..../..../#.##/##../#.../#.../#.../....',
  's': '..../..../.###/#.../.##./...#/###./....',
  't': '..../.#../.#../###./.#../.#../..##/....',
  'u': '..../..../#..#/#..#/#..#/#..#/.###/....',
  'v': '...../...../#...#/#...#/#...#/.#.#./..#../.....',
  'w': '...../...../#...#/#...#/#.#.#/#.#.#/.#.#./.....',
  'x': '.../.../#.#/#.#/.#./#.#/#.#/...',
  'y': '..../..../#..#/#..#/#..#/.###/...#/###.',
  'z': '..../..../####/...#/.##./#.../####/....',
  'ç': '..../..../.###/#.../#.../#.../.###/..#.',
  'ğ': '..../.##./..../.###/#..#/#..#/.###/###.',
  'ö': '..../#..#/..../.##./#..#/#..#/.##./....',
  'ş': '..../..../.###/#.../.##./...#/###./..#.',
  'ü': '..../#..#/..../#..#/#..#/#..#/.###/....',
  '0': '..../.##./#..#/#.##/##.#/#..#/.##./....',
  '1': '..../.#../##../.#../.#../.#../###./....',
  '2': '..../.##./#..#/...#/..#./.#../####/....',
  '3': '..../###./...#/.##./...#/#..#/.##./....',
  '4': '..../..#./.##./#.#./####/..#./..#./....',
  '5': '..../####/#.../###./...#/#..#/.##./....',
  '6': '..../.##./#.../###./#..#/#..#/.##./....',
  '7': '..../####/...#/..#./.#../.#../.#../....',
  '8': '..../.##./#..#/.##./#..#/#..#/.##./....',
  '9': '..../.##./#..#/#..#/.###/...#/.##./....',
  ' ': '../../../../../../../..',
  '.': '../../../../../../.#/..',
  ',': '../../../../../.#/.#/#.',
  /* Semsiye: yagmurlu gun rozetinde kullaniliyordu ama fontta yoktu,
     ekranda '?' cikiyordu. */
  '☂': '...../..#../.###./#####/..#../..#.#/...##/.....',
  ':': '../../.#/../.#/../../..',
  ';': '../../.#/../.#/.#/#./..',
  '!': '../#./#./#./#./../#./..',
  '?': '..../.##./#..#/...#/..#./..../..#./....',
  "'": '#/#/./././././.',
  '"': '#.#/#.#/.../.../.../.../.../...',
  '-': '..../..../..../####/..../..../..../....',
  '_': '..../..../..../..../..../..../..../####',
  '+': '.../.../.#./###/.#./.../.../...',
  '=': '.../.../###/.../###/.../.../...',
  '/': '..../...#/..#./..#./.#../.#../#.../....',
  '(': '../.#/#./#./#./#./.#/..',
  ')': '../#./.#/.#/.#/.#/#./..',
  '%': '...../##..#/##.#./..#../.#.../#..##/...##/.....',
  '*': '.../.../#.#/.#./#.#/.../.../...',
  '$': '..#../.####/#.#../.###./..#.#/####./..#../.....',
  '#': '...../.#.#./#####/.#.#./#####/.#.#./...../.....',
  '<': '.../.../..#/.#./#../.#./..#/...',
  '>': '.../.../#../.#./..#/.#./#../...',
  '@': '...../.###./#...#/#.##./#.#../.####/...../.....',
  '~': '...../...../.#../#.#.#/..#../...../...../.....',
  '—': '...../...../...../#####/...../...../...../.....',
  '–': '..../..../..../####/..../..../..../....',
  '…': '...../...../...../...../...../...../#.#.#/.....',
  '•': '.../.../.../.##/.##/.../.../...',
  '→': '...../...../..#../#####/..#../...../...../.....',
  '&': '...../.##../#..../.#.#./#..#./.##.#/...../.....',
  /* --- Latin diller: Almanca, Ispanyolca, Fransizca, Portekizce ---
     Aksanlar fontun kendi yontemiyle: buyukte ust satira,
     kucukte aksan + BOSLUK + sikistirilmis govde (o/ö gibi). */
  'ä': '#..#/..../.##./...#/.###/#..#/.###/....',
  'á': '..#./..../.##./...#/.###/#..#/.###/....',
  'à': '.#../..../.##./...#/.###/#..#/.###/....',
  'ã': '.###/..../.##./...#/.###/#..#/.###/....',
  'é': '..#./..../.##./#..#/####/#.../.###/....',
  'è': '.#../..../.##./#..#/####/#.../.###/....',
  'ê': '.##./..../.##./#..#/####/#.../.###/....',
  'ë': '#..#/..../.##./#..#/####/#.../.###/....',
  'í': '..#./..../..../.#../.#../.#../.#../....',
  'ì': '.#../..../..../.#../.#../.#../.#../....',
  'ï': '#..#/..../..../.#../.#../.#../.#../....',
  'ó': '..#./..../.##./#..#/#..#/#..#/.##./....',
  'ò': '.#../..../.##./#..#/#..#/#..#/.##./....',
  'ô': '.##./..../.##./#..#/#..#/#..#/.##./....',
  'õ': '.###/..../.##./#..#/#..#/#..#/.##./....',
  'ú': '..#./..../#..#/#..#/#..#/#..#/.###/....',
  'ù': '.#../..../#..#/#..#/#..#/#..#/.###/....',
  'ñ': '.###/..../###./#..#/#..#/#..#/#..#/....',
  'Ä': '.#.#./.###./#...#/#...#/#####/#...#/#...#/.....',
  'Á': '...#./.###./#...#/#...#/#####/#...#/#...#/.....',
  'À': '.#.../.###./#...#/#...#/#####/#...#/#...#/.....',
  'Ã': '.###./.###./#...#/#...#/#####/#...#/#...#/.....',
  'É': '...#./#####/#..../####./#..../#..../#####/.....',
  'È': '.#.../#####/#..../####./#..../#..../#####/.....',
  'Ê': '..#../#####/#..../####./#..../#..../#####/.....',
  'Ë': '.#.#./#####/#..../####./#..../#..../#####/.....',
  'Í': '...#./.###./..#../..#../..#../..#../.###./.....',
  'Ì': '.#.../.###./..#../..#../..#../..#../.###./.....',
  'Ï': '.#.#./.###./..#../..#../..#../..#../.###./.....',
  'Ó': '...#./.###./#...#/#...#/#...#/#...#/.###./.....',
  'Ò': '.#.../.###./#...#/#...#/#...#/#...#/.###./.....',
  'Ô': '..#../.###./#...#/#...#/#...#/#...#/.###./.....',
  'Õ': '.###./.###./#...#/#...#/#...#/#...#/.###./.....',
  'Ú': '...#./#...#/#...#/#...#/#...#/#...#/.###./.....',
  'Ù': '.#.../#...#/#...#/#...#/#...#/#...#/.###./.....',
  'Ñ': '.###./#...#/##..#/#.#.#/#..##/#...#/#...#/.....',
  'ß': '..../.##./#..#/##../#..#/#..#/##../....',
  'œ': '...../...../.##.#/#..##/####./#..../.###./.....',
  'Œ': '...../.####/#..../###../#..../#..../.####/.....',
  '¿': '..../..#./..../..#./.#../#.../.##./....',
  '¡': '..#./..../..#./..#./..#./..#./..../....'
};
var FONT = {}, FONT_H = 8;
(function bakeFont() {
  for (var ch in GLYPHS) {
    var rows = GLYPHS[ch].split('/');
    var wch = rows[0].length, minx = 99, maxx = -1;
    for (var y = 0; y < rows.length; y++) for (var x = 0; x < wch; x++)
      if (rows[y][x] === '#') { if (x < minx) minx = x; if (x > maxx) maxx = x; }
    if (maxx < 0) { minx = 0; maxx = 1; }
    FONT[ch] = { rows: rows, x0: minx, w: maxx - minx + 1 };
  }
  FONT[' '].w = 2;
})();
var _atlas = {};
function fontAtlas(col) {
  if (_atlas[col]) return _atlas[col];
  var keys = Object.keys(FONT);
  var c = document.createElement('canvas');
  c.width = keys.length * 6; c.height = FONT_H;
  var g = c.getContext('2d'); g.fillStyle = col;
  var map = {}, ox = 0;
  for (var k = 0; k < keys.length; k++) {
    var ch = keys[k], gl = FONT[ch];
    map[ch] = ox;
    for (var y = 0; y < gl.rows.length; y++) {
      var row = gl.rows[y];
      for (var x = 0; x < gl.w; x++) if (row[gl.x0 + x] === '#') g.fillRect(ox + x, y, 1, 1);
    }
    ox += 6;
  }
  _atlas[col] = { cv: c, map: map };
  return _atlas[col];
}
function textW(s, sc, mono) {
  s = T(s);
  sc = sc || 1; var w = 0; s = '' + s;
  for (var i = 0; i < s.length; i++) {
    var g = FONT[s[i]]; if (!g) g = FONT['?'];
    w += (mono ? Math.max(g.w, 4) : g.w) + 1;
  }
  return (w - 1) * sc;
}
function txt(s, x, y, col, o) {
  s = T(s);
  o = o || {}; var sc = o.sc || 1;
  s = '' + s;
  var mono = o.mono;
  var w = textW(s, 1, mono);
  var ax = x;
  if (o.align === 'c') ax = x - Math.floor(w * sc / 2);
  else if (o.align === 'r') ax = x - w * sc;
  ax = Math.round(ax); y = Math.round(y);
  if (o.outline) {
    var oc = o.outline === true ? P.ui5 : o.outline;
    for (var dy = -1; dy <= 1; dy++) for (var dx = -1; dx <= 1; dx++)
      if (dx || dy) drawStr(s, ax + dx * sc, y + dy * sc, oc, sc, mono);
  } else if (o.shadow) {
    drawStr(s, ax + sc, y + sc, o.shcol || 'rgba(0,0,0,.5)', sc, mono);
  }
  drawStr(s, ax, y, col, sc, mono);
  return w * sc;
}
function drawStr(s, x, y, col, sc, mono) {
  var a = fontAtlas(col), cvA = a.cv;
  for (var i = 0; i < s.length; i++) {
    var ch = s[i], g = FONT[ch];
    if (!g) { ch = '?'; g = FONT['?']; }
    var gw = mono ? Math.max(g.w, 4) : g.w;
    if (ch !== ' ') {
      var off = mono ? Math.floor((gw - g.w) / 2) : 0;
      ctx.drawImage(cvA, a.map[ch], 0, g.w, FONT_H, x + off * sc, y, g.w * sc, FONT_H * sc);
    }
    x += (gw + 1) * sc;
  }
}

/* ---------- girdi ---------- */
var IN = {
  x: 0, y: 0, downX: 0, downY: 0, down: false, pressed: false, released: false,
  keys: {}, kp: {}, downTime: 0, over: null, hot: null
};
function ptr(e) {
  var r = cv.getBoundingClientRect();
  var cx = (e.touches && e.touches[0] ? e.touches[0].clientX : e.clientX);
  var cy = (e.touches && e.touches[0] ? e.touches[0].clientY : e.clientY);
  /* Tuval yalniz gorunur bandi kapsiyor: dikeyde VIEW.top kadar geri eklenir,
     yoksa kirpma varken dokunuslar yukari kayar. */
  IN.x = clamp((cx - r.left) / r.width * (W - VIEW.right), 0, W - 1);
  IN.y = clamp((cy - r.top) / r.height * (H - VIEW.top - VIEW.bot) + VIEW.top, 0, H - 1);
}
cv.addEventListener('mousemove', function (e) { ptr(e); });
cv.addEventListener('mousedown', function (e) { ptr(e); IN.downX = IN.x; IN.downY = IN.y; IN.down = true; IN.pressed = true; IN.downTime = 0; audioInit(); e.preventDefault(); });
window.addEventListener('mouseup', function () { IN.down = false; IN.released = true; });
cv.addEventListener('touchstart', function (e) { ptr(e); IN.downX = IN.x; IN.downY = IN.y; IN.down = true; IN.pressed = true; IN.downTime = 0; audioInit(); e.preventDefault(); }, { passive: false });
cv.addEventListener('touchmove', function (e) { ptr(e); e.preventDefault(); }, { passive: false });
window.addEventListener('touchend', function (e) { IN.down = false; IN.released = true; }, { passive: false });
cv.addEventListener('contextmenu', function (e) { e.preventDefault(); });
window.addEventListener('keydown', function (e) {
  if (!IN.keys[e.code]) IN.kp[e.code] = true;
  IN.keys[e.code] = true; audioInit();
  if (['Space', 'ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].indexOf(e.code) >= 0) e.preventDefault();
});
window.addEventListener('keyup', function (e) { IN.keys[e.code] = false; });
function inEnd() { IN.pressed = false; IN.released = false; IN.kp = {}; }

/* ---------- metin girişi (tabela adı) ---------- */
var TEXTIN = { active: false, value: '', max: 14, done: false, cancel: false };
function textStart(v, max) { TEXTIN.active = true; TEXTIN.value = v || ''; TEXTIN.max = max || 14; TEXTIN.done = false; TEXTIN.cancel = false; }
function textStop() { TEXTIN.active = false; }
window.addEventListener('keydown', function (e) {
  if (!TEXTIN.active) return;
  if (e.key === 'Backspace') { TEXTIN.value = TEXTIN.value.slice(0, -1); e.preventDefault(); return; }
  if (e.key === 'Enter') { TEXTIN.done = true; e.preventDefault(); return; }
  if (e.key === 'Escape') { TEXTIN.cancel = true; e.preventDefault(); return; }
  if (e.key.length === 1 && TEXTIN.value.length < TEXTIN.max) {
    var ch = e.key.toLocaleUpperCase('tr');
    if (FONT[ch] || FONT[e.key]) { TEXTIN.value += (FONT[ch] ? ch : e.key); e.preventDefault(); }
  }
});
function keyp(c) { return !!IN.kp[c]; }

/* ---------- kamera ---------- */
var CAM = { sx: 0, sy: 0, shake: 0, flash: 0, flashCol: '#fff' };
function shake(a) { CAM.shake = Math.min(9, Math.max(CAM.shake, a)); }
function flash(a, c) { CAM.flash = Math.max(CAM.flash, a); CAM.flashCol = c || '#fff'; }
function camUpdate(dt) {
  CAM.shake = Math.max(0, CAM.shake - dt * 26);
  var s = CAM.shake;
  CAM.sx = s > .2 ? Math.round(rnd(-s, s)) : 0;
  CAM.sy = s > .2 ? Math.round(rnd(-s, s)) : 0;
  CAM.flash = Math.max(0, CAM.flash - dt * 2.6);
}

/* ---------- parçacıklar ---------- */
var PS = [];
function part(o) {
  if (PS.length > 360) PS.shift();
  o.life = o.life || .6; o.t = 0;
  o.vx = o.vx || 0; o.vy = o.vy || 0; o.g = o.g === undefined ? 220 : o.g;
  o.sz = o.sz || 1; o.type = o.type || 'px'; o.drag = o.drag === undefined ? .06 : o.drag;
  PS.push(o); return o;
}
function burst(x, y, n, cols, opt) {
  opt = opt || {};
  for (var i = 0; i < n; i++) {
    var a = opt.ang !== undefined ? opt.ang + rnd(-(opt.spread || .6), (opt.spread || .6)) : rnd(0, TAU);
    var sp = rnd(opt.spMin || 20, opt.spMax || 90);
    part({
      x: x, y: y, vx: Math.cos(a) * sp, vy: Math.sin(a) * sp - (opt.up || 0),
      life: rnd(opt.lifeMin || .3, opt.lifeMax || .8), col: pick(cols),
      g: opt.g === undefined ? 220 : opt.g, sz: opt.sz || 1, type: opt.type || 'px',
      floor: opt.floor, bounce: opt.bounce
    });
  }
}
function smoke(x, y, n, col, opt) {
  opt = opt || {};
  for (var i = 0; i < n; i++) part({
    x: x + rnd(-2, 2), y: y + rnd(-1, 1), vx: rnd(-6, 6), vy: rnd(-26, -12),
    life: rnd(.6, 1.4), col: col || 'rgba(255,255,255,.55)', g: -8, sz: opt.sz || 2, type: 'smoke', drag: .5
  });
}
function psUpdate(dt) {
  for (var i = PS.length - 1; i >= 0; i--) {
    var p = PS[i]; p.t += dt;
    if (p.t >= p.life) { PS.splice(i, 1); continue; }
    p.vy += p.g * dt;
    p.vx -= p.vx * p.drag * dt * 10;
    p.x += p.vx * dt; p.y += p.vy * dt;
    if (p.floor !== undefined && p.y > p.floor) {
      p.y = p.floor;
      if (p.bounce) { p.vy *= -p.bounce; p.vx *= .6; if (Math.abs(p.vy) < 12) { p.vy = 0; p.g = 0; } }
      else { p.vy = 0; p.vx *= .8; p.g = 0; }
    }
  }
}
function psDraw() {
  for (var i = 0; i < PS.length; i++) {
    var p = PS[i], k = p.t / p.life;
    if (p.type === 'smoke') {
      ctx.globalAlpha = (1 - k) * .5;
      disc(p.x, p.y, (p.sz + k * 3) * .5, p.col); ctx.globalAlpha = 1;
    } else if (p.type === 'star') {
      ctx.globalAlpha = 1 - k * k;
      var r = Math.max(1, p.sz * (1 - k * .4));
      fr(p.x - r, p.y, r * 2 + 1, 1, p.col); fr(p.x, p.y - r, 1, r * 2 + 1, p.col);
      ctx.globalAlpha = 1;
    } else if (p.type === 'ring') {
      ctx.globalAlpha = 1 - k;
      ring(p.x, p.y, 1 + k * (p.sz || 10), p.col); ctx.globalAlpha = 1;
    } else if (p.type === 'et' && typeof drawEtDilimi === 'function') {
      /* Tiraslanan et: eskiden 1 px'lik noktaydi. Dususe gore kivrim
         acilir, parca donerek duser. */
      if (k > .82) ctx.globalAlpha = 1 - (k - .82) * 5.6;
      drawEtDilimi(p.x, p.y, .35 + k * 1.05, p.k || 1, p.sc || 1);
      ctx.globalAlpha = 1;
    } else {
      if (k > .75) ctx.globalAlpha = 1 - (k - .75) * 4;
      fr(p.x - (p.sz >> 1), p.y - (p.sz >> 1), p.sz, p.sz, p.col);
      ctx.globalAlpha = 1;
    }
  }
}

/* ---------- uçan yazılar ---------- */
var FT = [];
function ftext(s, x, y, col, opt) {
  s = T(s);
  opt = opt || {};
  FT.push({ s: s, x: x, y: y, col: col, t: 0, life: opt.life || 1.1, vy: opt.vy === undefined ? -22 : opt.vy, sc: opt.sc || 1, out: opt.out || P.ui5 });
  if (FT.length > 40) FT.shift();
}
function ftUpdate(dt) {
  for (var i = FT.length - 1; i >= 0; i--) {
    var f = FT[i]; f.t += dt; f.y += f.vy * dt; f.vy += 30 * dt;
    if (f.t >= f.life) FT.splice(i, 1);
  }
}
function ftDraw() {
  for (var i = 0; i < FT.length; i++) {
    var f = FT[i], k = f.t / f.life;
    ctx.globalAlpha = k > .6 ? 1 - (k - .6) / .4 : 1;
    txt(f.s, f.x, f.y, f.col, { align: 'c', sc: f.sc, outline: f.out });
    ctx.globalAlpha = 1;
  }
}

/* ---------- ses ---------- */
var AC = null, MASTER = null, MUTED = false;
/* Iki ayri yol: muzigi kapatip efektleri acik birakabilmek icin.
   Seviyeler 0-100 arasi, oyundan bagimsiz olarak kalici saklanir. */
var MUSBUS = null, SFXBUS = null;
var VOLKEY = 'doner_ses';
var VOL = { mus: 65, sfx: 100 };

function volYukle() {
  try {
    var v = JSON.parse(localStorage.getItem(VOLKEY) || 'null');
    if (v) {
      if (typeof v.mus === 'number') VOL.mus = clamp(Math.round(v.mus), 0, 100);
      if (typeof v.sfx === 'number') VOL.sfx = clamp(Math.round(v.sfx), 0, 100);
      if (typeof v.muted === 'boolean') MUTED = v.muted;
    }
  } catch (e) { }
}
function volKaydet() {
  try { localStorage.setItem(VOLKEY, JSON.stringify({ mus: VOL.mus, sfx: VOL.sfx, muted: MUTED })); } catch (e) { }
}
/* 0-100 -> duyulan yukseklik. Kulak logaritmik duyar: karesi
   dogrusal kaydiricidan cok daha dogal bir azalma verir. */
function volKazanc(v) { var u = clamp(v, 0, 100) / 100; return u * u; }

function volUygula() {
  if (!AC) return;
  var t = AC.currentTime;
  if (MUSBUS) MUSBUS.gain.setTargetAtTime(MUTED ? 0 : volKazanc(VOL.mus), t, .05);
  if (SFXBUS) SFXBUS.gain.setTargetAtTime(MUTED ? 0 : volKazanc(VOL.sfx), t, .05);
  /* dosyadan calan sesler WebAudio disinda olabilir: onlara da haber ver */
  if (typeof sndVolGuncelle === 'function') sndVolGuncelle();
}
function volAyarla(tur, deger) {
  VOL[tur] = clamp(Math.round(deger), 0, 100);
  if (MUTED && (VOL.mus > 0 || VOL.sfx > 0)) MUTED = false;
  volUygula(); volKaydet();
}
function sesKis(acik) { MUTED = !acik; volUygula(); volKaydet(); }

function audioInit() {
  if (AC) { if (AC.state === 'suspended') AC.resume(); return; }
  try {
    AC = new (window.AudioContext || window.webkitAudioContext)();
    MASTER = AC.createGain(); MASTER.gain.value = .45; MASTER.connect(AC.destination);
    MUSBUS = AC.createGain(); MUSBUS.connect(MASTER);
    SFXBUS = AC.createGain(); SFXBUS.connect(MASTER);
    volUygula();
    if (typeof sndLoad === 'function') sndLoad();
  } catch (e) { AC = null; }
}
function noiseBuf(len) {
  var n = Math.floor(AC.sampleRate * len), b = AC.createBuffer(1, n, AC.sampleRate), d = b.getChannelData(0);
  for (var i = 0; i < n; i++) d[i] = Math.random() * 2 - 1;
  return b;
}
function beep(freq, dur, type, vol, slideTo, delay) {
  if (!AC || !MASTER || MUTED) return;
  var t0 = AC.currentTime + (delay || 0);
  var o = AC.createOscillator(), g = AC.createGain();
  o.type = type || 'square'; o.frequency.setValueAtTime(freq, t0);
  if (slideTo) o.frequency.exponentialRampToValueAtTime(Math.max(20, slideTo), t0 + dur);
  g.gain.setValueAtTime(0, t0);
  g.gain.linearRampToValueAtTime(vol === undefined ? .18 : vol, t0 + .008);
  g.gain.exponentialRampToValueAtTime(.0008, t0 + dur);
  o.connect(g); g.connect(SFXBUS); o.start(t0); o.stop(t0 + dur + .02);
}
function noise(dur, vol, f0, f1, q) {
  if (!AC || !MASTER || MUTED) return;
  var t0 = AC.currentTime;
  var s = AC.createBufferSource(); s.buffer = noiseBuf(Math.max(.05, dur));
  var f = AC.createBiquadFilter(); f.type = 'bandpass'; f.Q.value = q || 1;
  f.frequency.setValueAtTime(f0, t0);
  if (f1) f.frequency.exponentialRampToValueAtTime(f1, t0 + dur);
  var g = AC.createGain();
  g.gain.setValueAtTime(vol, t0); g.gain.exponentialRampToValueAtTime(.001, t0 + dur);
  s.connect(f); f.connect(g); g.connect(SFXBUS); s.start(t0); s.stop(t0 + dur + .02);
}
/* yukselip alcalan gecis sesi (araba gecisi gibi) */
function swell(dur, vol, f0, fPeak, q) {
  if (!AC || !MASTER || MUTED) return;
  var t0 = AC.currentTime;
  var sN = AC.createBufferSource(); sN.buffer = noiseBuf(Math.max(.1, dur));
  var f = AC.createBiquadFilter(); f.type = 'bandpass'; f.Q.value = q || .8;
  f.frequency.setValueAtTime(f0, t0);
  f.frequency.linearRampToValueAtTime(fPeak, t0 + dur * .5);
  f.frequency.linearRampToValueAtTime(f0 * .7, t0 + dur);
  var g = AC.createGain();
  g.gain.setValueAtTime(.0001, t0);
  g.gain.linearRampToValueAtTime(vol, t0 + dur * .45);
  g.gain.exponentialRampToValueAtTime(.0005, t0 + dur);
  sN.connect(f); f.connect(g); g.connect(SFXBUS); sN.start(t0); sN.stop(t0 + dur + .05);
}

/* --- icecek doldurma: gercek akis sesi ---
   Suruklu gurultu + dolan bardagin yukselen rezonansi + kabarcik. */
var POUR = null;
function pourSndStart(type) {
  if (!AC || !MASTER || MUTED) return;
  pourSndStop();
  try {
    var src = AC.createBufferSource();
    src.buffer = noiseBuf(2.2); src.loop = true;

    /* dar bant: sivi akisi */
    var bp = AC.createBiquadFilter();
    bp.type = 'bandpass';
    bp.Q.value = type === 'ayran' ? 2.2 : 3.4;
    bp.frequency.value = type === 'ayran' ? 520 : 900;

    /* bardagin rezonansi: doldukca tizlesir */
    var res = AC.createBiquadFilter();
    res.type = 'peaking';
    res.Q.value = 7;
    res.gain.value = 12;
    res.frequency.value = 320;

    var lp = AC.createBiquadFilter();
    lp.type = 'lowpass';
    lp.frequency.value = type === 'ayran' ? 2600 : 5200;

    var g = AC.createGain();
    g.gain.value = 0;
    g.gain.setTargetAtTime(type === 'ayran' ? .10 : .075, AC.currentTime, .05);

    src.connect(bp); bp.connect(res); res.connect(lp); lp.connect(g); g.connect(SFXBUS);
    src.start(0);
    POUR = { s: src, g: g, res: res, bp: bp, type: type, fizz: 0 };
  } catch (e) { POUR = null; }
}
/* fill 0..1 — akis suruyor */
function pourSndLevel(fill) {
  if (!POUR || !AC) return;
  var f = clamp(fill, 0, 1);
  /* bardak doldukca hava sutunu kisalir -> ton yukselir */
  POUR.res.frequency.setTargetAtTime(320 + f * 900, AC.currentTime, .06);
  POUR.bp.frequency.setTargetAtTime((POUR.type === 'ayran' ? 520 : 900) + f * 320, AC.currentTime, .08);
  /* gazli icecek: kabarcik */
  if (POUR.type !== 'ayran') {
    POUR.fizz -= 1;
    if (POUR.fizz <= 0) {
      POUR.fizz = 2 + Math.floor(Math.random() * 4);
      noise(.035, .028, 3200 + Math.random() * 2600, 5200, 6);
    }
  }
}
function pourSndStop(splash) {
  if (!POUR) return;
  var p = POUR; POUR = null;
  try {
    p.g.gain.setTargetAtTime(0, AC.currentTime, .05);
    p.s.stop(AC.currentTime + .3);
  } catch (e) { }
  if (splash) { noise(.10, .07, 700, 260, 1.4); }
}

/* sokak ambiyansi: surekli dusuk ugultu */
var AMB = null;
function ambSet(on) {
  /* sokak sesi dosyadan gelirse sentez ugultusunu kullanma.
     AC olmasa bile <audio> geri donusu calisabilir. */
  if (typeof sndLoop === 'function' && sndLoop('street', on)) {
    if (AC && AMB && AMB.g) AMB.g.gain.setTargetAtTime(0, AC.currentTime, .4);
    return;
  }
  if (!AC || !MASTER) return;
  if (on && !AMB) {
    try {
      var sN = AC.createBufferSource(); sN.buffer = noiseBuf(2.5); sN.loop = true;
      var f = AC.createBiquadFilter(); f.type = 'lowpass'; f.frequency.value = 240; f.Q.value = .5;
      var g = AC.createGain(); g.gain.value = 0;
      /* Sentez sokak ugultusu da SES EFEKTI hattinda: dosya yolu
         'sfx' iken yedek yolun 'mus' olmasi tutarsizdi. */
      sN.connect(f); f.connect(g); g.connect(SFXBUS); sN.start();
      AMB = { s: sN, g: g, f: f };
    } catch (e) { AMB = null; return; }
  }
  if (AMB) AMB.g.gain.setTargetAtTime(on && !MUTED ? .045 : 0, AC.currentTime, .5);
}
function ambRain(on) {
  /* Once gercek yagmur kaydi. Yuklenemezse sokak ugultusunun
     filtresini acarak sentez yagmura duser. */
  /* Vitrin camina vuran damlalar: disaridaki yagmurun USTUNE biner.
     Oyuncu dukkanin ICINDE duruyor, camdan yagmuru duymasi lazim. */
  if (typeof sndLoop === 'function') sndLoop('camYagmur', on);
  if (typeof sndLoop === 'function' && sndLoop('rain', on)) {
    if (AMB && AC) AMB.f.frequency.setTargetAtTime(240, AC.currentTime, .6);
    return;
  }
  if (AMB && AC) AMB.f.frequency.setTargetAtTime(on ? 520 : 240, AC.currentTime, .6);
}

var SFX = {
  chop: function () { noise(.09, .3, 2600, 700, 1.6); beep(340, .05, 'triangle', .06, 180); },
  slice: function () { noise(.16, .22, 4200, 900, 2.2); },
  pick: function () { beep(880, .05, 'square', .10, 1200); },
  drop: function () { beep(320, .07, 'square', .09, 200); },
  /* Telefon hoparloru 150Hz altini ureteemiyor, testere dalga orada
     kirilip 'takilma' gibi duyuluyordu. Iki notali, ucgen dalgali,
     bandin icinde kalan yumusak bir olumsuzluk sesi. */
  bad: function () {
    beep(392, .10, 'triangle', .13, 349);
    beep(294, .16, 'triangle', .11, 262, .07);
    noise(.07, .035, 900, 400, 1.2);
  },
  coin: function () { if (typeof sndPlay === 'function' && sndPlay('coin')) return; beep(1180, .06, 'square', .12); beep(1560, .10, 'square', .11, null, .06); },
  cash: function () { beep(900, .07, 'square', .12); beep(1200, .07, 'square', .12, null, .07); beep(1600, .14, 'square', .12, null, .14); },
  ding: function () { beep(1320, .5, 'sine', .13); beep(1980, .4, 'sine', .05, null, .01); },
  serve: function () { beep(660, .07, 'triangle', .12); beep(990, .12, 'triangle', .1, null, .06); },
  pour: function () { noise(.35, .14, 500, 1500, .8); },
  fry: function () { noise(.5, .10, 1800, 3200, .5); },
  sizzle: function () { noise(.7, .13, 2400, 1200, .4); },
  ui: function () { beep(720, .04, 'square', .09); },
  uiBack: function () { beep(420, .06, 'square', .08, 300); },
  levelup: function () { [523, 659, 784, 1046].forEach(function (f, i) { beep(f, .16, 'square', .12, null, i * .085); }); },
  fail: function () { [400, 330, 260, 200].forEach(function (f, i) { beep(f, .18, 'square', .11, null, i * .1); }); },
  pop: function () { beep(500, .05, 'sine', .1, 900); },
  angry: function () { beep(180, .12, 'sawtooth', .1, 120); },
  bell: function () { beep(1568, .35, 'sine', .12); beep(2093, .3, 'sine', .06, null, .04); },
  knife: function () { noise(.07, .18, 5200, 2000, 3); },
  rain: function () { noise(2.2, .05, 900, 1400, .3); },
  stamp: function () { noise(.08, .22, 500, 200, 2); beep(180, .1, 'square', .1, 90); },
  fine: function () { [330, 262, 208, 165].forEach(function (f, i) { beep(f, .22, 'sawtooth', .11, null, i * .12); }); },
  moto: function () {
    if (!AC || !MASTER || MUTED) return;
    var t0 = AC.currentTime;
    for (var i = 0; i < 3; i++) {
      var o = AC.createOscillator(), g = AC.createGain();
      o.type = 'sawtooth';
      o.frequency.setValueAtTime(70 + i * 8, t0 + i * .18);
      o.frequency.linearRampToValueAtTime(150 + i * 20, t0 + i * .18 + .16);
      o.frequency.linearRampToValueAtTime(85 + i * 10, t0 + i * .18 + .22);
      g.gain.setValueAtTime(0, t0 + i * .18);
      g.gain.linearRampToValueAtTime(.10, t0 + i * .18 + .03);
      g.gain.exponentialRampToValueAtTime(.001, t0 + i * .18 + .26);
      o.connect(g); g.connect(SFXBUS); o.start(t0 + i * .18); o.stop(t0 + i * .18 + .3);
    }
    noise(.5, .06, 300, 900, .6);
  },
  phone: function () { beep(1180, .09, 'square', .10); beep(1480, .09, 'square', .10, null, .11); beep(1180, .09, 'square', .10, null, .22); beep(1480, .12, 'square', .10, null, .33); },
  /* --- yeni --- */
  door: function () { beep(1760, .16, 'sine', .11); beep(2349, .22, 'sine', .09, null, .07); beep(1568, .3, 'sine', .05, null, .14); },
  crinkle: function () { noise(.10, .16, 3800, 2200, 1.2); noise(.13, .11, 5200, 3000, 1.6); beep(760, .04, 'triangle', .04, 520, .05); },
  squirt: function () { noise(.13, .13, 900, 320, 3.4); beep(520, .07, 'sine', .07, 240); },
  plate: function () { beep(2093, .18, 'sine', .10); beep(2794, .12, 'sine', .05, null, .02); noise(.05, .05, 5000, 4000, 3); },
  steam: function () { noise(.45, .07, 1400, 4200, .6); },
  horn: function () { beep(430, .16, 'sawtooth', .045); beep(516, .16, 'sawtooth', .04, null, .01); beep(430, .12, 'sawtooth', .035, null, .2); },
  carPass: function (near) { swell(near ? .9 : 1.3, near ? .055 : .03, 180, near ? 760 : 460, .7); },
  footstep: function () { noise(.05, .05, 300, 160, 1.4); },
  glass: function () { beep(2400, .10, 'sine', .06); beep(3200, .07, 'sine', .03, null, .02); },
  shutter: function () { noise(1.15, .10, 260, 900, 1.1); beep(120, .12, 'square', .05, 80, .05); },
  fanfare: function () {
    [523, 659, 784, 1046, 1318].forEach(function (f, i) { beep(f, .22, 'square', .13, null, i * .11); });
    [262, 330, 392, 523].forEach(function (f, i) { beep(f, .3, 'triangle', .09, null, i * .11 + .04); });
    beep(1568, .8, 'sine', .10, null, .58);
  },
  slam: function () { noise(.14, .26, 220, 90, 1.8); beep(90, .16, 'square', .09, 60, .02); },
  /* --- mutfak sesleri --- */
  potato: function () {          /* patates doğrama: tahtaya vuran bıçak */
    noise(.055, .34, 1900, 520, 2.2);
    beep(260, .04, 'triangle', .07, 150);
    noise(.09, .10, 4200, 2600, 1.4);
  },
  sack: function () { noise(.16, .12, 700, 300, 1.1); beep(180, .08, 'square', .05, 110); },
  basket: function () { noise(.12, .16, 1100, 480, 1.6); beep(300, .05, 'square', .06, 200); },
  scoop: function () { noise(.10, .13, 2400, 900, 1.8); beep(520, .05, 'triangle', .06, 380); },
  /* Lavas tahtaya konuyor: ALCAK bir tok + kagit hisirtisi.
     Eskiden yalniz 2600Hz hisirtiydi, kucuk hoparlorde duyulmuyordu. */
  wrap: function () {
    noise(.07, .20, 380, 170, 1.1);
    noise(.20, .12, 2400, 1200, 1.0);
    beep(300, .06, 'triangle', .08, 210, .01);
  },
  /* Durum sariliyor: kagit/hamur donuyor. Servis sesinden ayri. */
  roll: function () {
    noise(.22, .13, 1800, 700, 1.4);
    beep(240, .10, 'triangle', .09, 420);
    beep(520, .07, 'sine', .05, 700, .09);
  },
  /* Cekmece: tahta uzerinde kayma + hafif carpma */
  drawer: function (kapan) {
    noise(.26, .10, 900, 380, 1.0);
    beep(kapan ? 180 : 260, .08, 'triangle', .07, kapan ? 130 : 200, .18);
  },
  tick: function () { beep(1000, .03, 'square', .05); },
  warn: function () { beep(760, .09, 'square', .09); beep(560, .12, 'square', .08, null, .10); }
};

/* ---------- kayıt ---------- */
var SAVEKEY = 'doner_efsanesi_v1';
var SAVE_SEMA = 2;           /* kayit bicimi surumu */
/* Kayit durumu: 'ok' | 'dolu' | 'engelli' | 'bozuk' | 'yok'.
   Eskiden butun hatalar sessizce yutuluyordu; depolama engelliyse
   oyuncu kaydedildigini saniyor, oyunu kapatinca ilerlemeyi
   kaybediyordu. */
var SAVE_DURUM = 'ok', SAVE_UYARILDI = false;

function saveGame(o) {
  try {
    o.sema = SAVE_SEMA;
    localStorage.setItem(SAVEKEY, JSON.stringify(o));
    SAVE_DURUM = 'ok';
    return true;
  } catch (e) {
    /* QuotaExceededError adi tarayiciya gore degisiyor; kodu da
       kontrol ediliyor (Firefox 1014, digerleri 22). */
    var dolu = e && (e.name === 'QuotaExceededError' ||
                     e.name === 'NS_ERROR_DOM_QUOTA_REACHED' ||
                     e.code === 22 || e.code === 1014);
    SAVE_DURUM = dolu ? 'dolu' : 'engelli';
    return false;
  }
}

function loadGame() {
  var ham;
  try { ham = localStorage.getItem(SAVEKEY); }
  catch (e) { SAVE_DURUM = 'engelli'; return null; }
  if (!ham) { SAVE_DURUM = 'yok'; return null; }
  var o;
  try { o = JSON.parse(ham); }
  catch (e) { SAVE_DURUM = 'bozuk'; return null; }
  if (!o || typeof o !== 'object') { SAVE_DURUM = 'bozuk'; return null; }
  /* Semasiz kayit = surum 1. Alan eklendikce eskiler eksik yukleniyor;
     surum bilgisi ileride goc yazmayi mumkun kiliyor. */
  if (!o.sema) o.sema = 1;
  if (o.sema > SAVE_SEMA) { SAVE_DURUM = 'bozuk'; return null; }  /* daha yeni surum */
  SAVE_DURUM = 'ok';
  return o;
}
function clearSave() { try { localStorage.removeItem(SAVEKEY); } catch (e) { } }
/* Kayit calismiyorsa oyuncuya BIR KEZ soyle. Sessiz kalmak, gun sonunda
   ilerlemenin durdugunu fark etmemesine yol aciyordu. */
function saveUyar() {
  if (SAVE_UYARILDI || SAVE_DURUM === 'ok' || SAVE_DURUM === 'yok') return;
  SAVE_UYARILDI = true;
  if (typeof say !== 'function') return;
  say(SAVE_DURUM === 'dolu' ? 'Depolama dolu — ilerleme kaydedilemiyor!'
      : (SAVE_DURUM === 'bozuk' ? 'Kayıt bozuk — yeni oyun başlatıldı'
                                : 'Kayıt kapalı — ilerleme saklanmıyor!'));
}
