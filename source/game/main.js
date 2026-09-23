/* ============================================================
   DÖNER EFSANESİ — main.js
   Ana döngü ve sahne dağıtımı
   ============================================================ */
'use strict';

(function boot() {
  /* Karakter atlaslarini HEMEN iste: ses kullanici dokunusunu bekler,
     gorsel beklememeli. Yuklenene kadar oyun eski kodla cizilen
     surumu gosterir, gelince kendiliginden sprite'a geciyor. */
  if (typeof sprYukle === 'function') sprYukle();
  if (typeof loadLang === 'function') loadLang();
  if (typeof volYukle === 'function') volYukle();
  var s = loadGame();
  if (s) { G.best = s.best || 1; if (s.moto) G.moto = s.moto; G.prologueSeen = !!s.prologueSeen; G.luck = s.luck || 0; }
})();

var _last = performance.now(), _acc = 0, _fps = 0, _fpsT = 0, _frames = 0;

/* Sekme gizlenince tarayıcı offscreen canvas'ları boşaltabiliyor —
   geri dönünce katmanları yeniden pişir. */
function invalidateLayers() { BG = null; CLAYER = null; WINOVER = null; if (typeof SHOP !== 'undefined') SHOP.bake = null; }
/* Uygulama arka plana alindiginda (telefonda cagri, ana ekrana donus):
   - gun ortasindaysa oyun duraklar, oyuncu gunu kaybetmez
   - butun sesler susar; iOS'ta WKWebView arka planda calmaya devam ederdi
   - AudioContext askiya alinir, pil yemez */
function appPause() {
  if (G.scene === 'play') { G.scene = 'pause'; }
  try {
    if (typeof sndLoop === 'function') { sndLoop('fry', false); sndLoop('street', false); }
    if (typeof pourSndStop === 'function') pourSndStop(false);
    if (typeof ambSet === 'function') ambSet(false);
    if (AC && AC.state === 'running' && AC.suspend) AC.suspend();
  } catch (e) { }
}
function appResume() {
  invalidateLayers();
  _last = performance.now();          /* dt sicramasin */
  try { if (AC && AC.state === 'suspended' && AC.resume) AC.resume(); } catch (e) { }
}
document.addEventListener('visibilitychange', function () {
  if (document.hidden) appPause(); else appResume();
});
window.addEventListener('blur', appPause);
window.addEventListener('focus', appResume);
window.addEventListener('pagehide', appPause);
window.addEventListener('pageshow', appResume);

function frame(now) {
  var dt = (now - _last) / 1000; _last = now;
  if (!(dt > 0)) dt = 0;          /* negatif/NaN dt koruması */
  if (dt > 0.06) dt = 0.06;
  G.t += dt;
  _frames++; _fpsT += dt;
  if (_fpsT > .5) { _fps = Math.round(_frames / _fpsT); _frames = 0; _fpsT = 0; }

  /* klavye kısayolları */
  if (keyp('KeyM')) { MUTED = !MUTED; }
  /* Test paneli YALNIZ test derlemesinde. Ekrandaki DEV dugmesi
     __DEV_BUILD ile korunuyordu ama bu klavye yolu korunmuyordu:
     yayinlanan oyunda T'ye basan herkes para/yukseltme panelini
     aciyordu. Iki yol da ayni kapiya bagli artik. */
  if (window.__DEV_BUILD && keyp('KeyT') &&
      (G.scene === 'play' || G.scene === 'shop' || G.scene === 'pause')) {
    G.test = !G.test; SFX.ui();
  }
  if (keyp('Escape')) {
    if (G.scene === 'play') G.scene = 'pause';
    else if (G.scene === 'pause') G.scene = 'play';
  }

  if (AC) {
    musInit(); musSet(G.scene === 'play' ? 'play' : 'menu');
    ambSet(G.scene === 'play' || G.scene === 'shop' || G.scene === 'title');
    if (typeof sndLoop === 'function' && G.scene !== 'play') sndLoop('fry', false);
    ambRain(G.scene === 'play' && typeof isRain === 'function' && isRain());
  }
  camUpdate(dt);
  /* sokak, dukkan disindaki sahnelerde de yasasin */
  if (typeof updateTraffic === 'function') { updateTraffic(dt); updateCrossers(dt); }
  psUpdate(dt);
  ftUpdate(dt);
  if (G.scene !== 'play') G.sceneT += dt;

  /* Kirpilan ust bant kadar yukari otele: tuval yalniz gorunur bandi kapsar.
     Karenin TAMAMI bu donusum altinda cizilir (flas ve imlec dahil). */
  ctx.save();
  if (VIEW.top) ctx.translate(0, -VIEW.top);

  ctx.save();
  ctx.translate(CAM.sx, CAM.sy);

  /* Bir sahne cizimi patlarsa rAF zinciri kopuyor: ekran donuyor, imlec
     kayboluyor, oyun ilerlemiyor (kullanicinin bildirdigi donma). Hata
     yutulmaz — __ERRS'e yazilir, testler gorur — ama dongu yasar. */
  try {
    switch (G.scene) {
      case 'title': drawTitle(G.t); break;
      case 'intro': drawIntro(G.t); break;
      case 'play': updatePlay(dt); drawPlay(G.t); break;
      case 'dayend': drawDayEnd(G.t); break;
      case 'shop': drawShop(G.t); break;
      case 'night': drawNight(G.t); break;
      case 'prologue': drawPrologue(G.t); break;
      case 'pause': drawPause(G.t); break;
    }
  } catch (e) {
    if (!window.__ERRS) window.__ERRS = [];
    window.__ERRS.push('sahne ' + G.scene + ': ' + e.message);
    if (window.console && console.error) console.error(e);
  }

  /* Basarim taramasi: yarim saniyede bir. 64 kucuk kapanis, bedeli yok;
     her karede taramaya gerek de yok. */
  if (typeof basarimTara === 'function') {
    G.bsT = (G.bsT || 0) + dt;
    if (G.bsT > .5) {
      G.bsT = 0;
      if (G.scene === 'play' || G.scene === 'shop' || G.scene === 'dayend') basarimTara();
    }
  }
  if (G.scene === 'title' && typeof drawTitleBasarim === 'function') drawTitleBasarim(G.t);
  if (typeof drawBasarimToast === 'function') drawBasarimToast(G.t, dt);
  if (G.test && (G.scene === 'play' || G.scene === 'shop' || G.scene === 'pause')) drawTestPanel(G.t);
  if (typeof drawDevDugme === 'function') drawDevDugme(G.t);

  ctx.restore();

  /* flaş */
  if (CAM.flash > .01) {
    ctx.globalAlpha = Math.min(.85, CAM.flash);
    fr(0, 0, W, H, CAM.flashCol);
    ctx.globalAlpha = 1;
  }

  /* imleç */
  var mode = 'point';
  /* Sisin uzerinde imlec HIC cizilmez: drawShaveHint zaten oraya gercek
     doner bicagini koyuyor, ikisi birden ekranda iki bicak gibi duruyordu. */
  var sisUstunde = G.scene === 'play' && hitST('spit');
  if (G.scene === 'play' && !sisUstunde && hoverStation()) mode = 'grab';
  var held = (G.scene === 'play' || G.scene === 'pause') ? G.hand : null;
  /* dokunmatikte ok imleci sadece parmak ekrandayken ya da elde ürün varken */
  /* Dokunmatikte cizili imlec HIC cizilmez: parmagin altinda kalan
     imlec oyuncuya "fare var" hissi veriyor ve neyi tuttugunu gizliyor.
     Elde bir sey varsa onu ayrica cizen kod zaten var. */
  if (!TOUCH && !sisUstunde) drawCursor(IN.x, IN.y, held ? 'grab' : mode, held, G.t);

  ctx.restore();          /* VIEW.top otelemesi */

  inEnd();
  requestAnimationFrame(frame);
}
requestAnimationFrame(frame);
