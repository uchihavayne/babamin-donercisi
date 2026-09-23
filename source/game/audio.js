/* ============================================================
   DÖNER EFSANESİ — audio.js
   Dosyadan gelen sesler (mp3/m4a). WebAudio üzerinden çalınır,
   böylece MUTED ve ses seviyesi tek yerden yönetilir.
   Dosya yüklenemezse oyun sessizce kendi sentez sesine döner.
   ============================================================ */
'use strict';

/* tur: 'mus' YALNIZ muzik (music.js hicaz dongusu), 'sfx' dunyanin
   her sesi - yagmur, sokak, korna, cam damlasi dahil. Ambiyans
   'muzik' sayilmamali: muzigi kisan oyuncu yagmuru susturuyordu.
   Oyuncu ikisini ayri ayri kisabilsin diye ayri yollara gider. */
var SND = {
  /* fry.mp3 basta sessizden yukseliyor, sonunda fade ile bitiyordu;
     dongu oralara girince kizartma durmus gibi duyuluyordu.
     3.40-4.90 arasi kaydin duz platosu (uc seviyeleri esit), dongu
     orada doner ve calma da oradan baslar: seviye hic dusmez. */
  fry: { url: 'res://assets/audio/asset_00.mp3', vol: 0.55, loop: true, tur: 'sfx', dS: 3.40, dE: 4.90 },
  coin: { url: 'res://assets/audio/asset_01.m4a', vol: 0.60, tur: 'sfx' },
  /* Sokak ugultusu, yagmur ve cam damlalari SES EFEKTI hattinda.
     Eskiden 'mus' idi: muzigi kisan oyuncu yagmuru da susturuyordu.
     Bunlar dunyanin sesi, muzik degil - muzik hattinda yalniz
     music.js'in hicaz dongusu var. */
  street: { url: 'res://assets/audio/asset_02.mp3', vol: 0.30, loop: true, tur: 'sfx' },
  rain: { url: 'res://assets/audio/asset_03.mp3', vol: 0.42, loop: true, tur: 'sfx' },
  /* Trafik sikistikca calan kornalar. Iki ayri kayit donusumlu
     calisiyor, ayni korna arka arkaya duyulmasin. */
  korna1: { url: 'res://assets/audio/asset_04.wav', vol: 0.20, tur: 'sfx' },
  korna2: { url: 'res://assets/audio/asset_05.wav', vol: 0.17, tur: 'sfx' },
  /* Vitrin camina vuran yagmur: disaridaki 'rain' ambiyansinin
     USTUNE biner, ikisi birlikte 'icerideyiz' hissini veriyor. */
  camYagmur: { url: 'res://assets/audio/asset_06.wav', vol: 0.34, loop: true, tur: 'sfx' }
};

/* sesin baglanacagi yol */
function sndBus(d) {
  var m = (d && d.tur === 'mus');
  return (m ? MUSBUS : SFXBUS) || MASTER;
}
/* <audio> geri donusu WebAudio yolundan gecmez: seviyeyi elle uygula */
function sndElVol(d) {
  if (MUTED) return 0;
  var t = (d.tur === 'mus') ? VOL.mus : VOL.sfx;
  return clamp(d.vol * volKazanc(t), 0, 1);
}
/* seviye degisince calan <audio> ogelerini guncelle */
function sndVolGuncelle() {
  for (var k in SND) {
    var d = SND[k];
    if (d.el) { try { d.el.volume = sndElVol(d); } catch (e) { } }
  }
}
var SNDOK = false;

function sndLoad() {
  if (SNDOK) return;
  SNDOK = true;
  for (var k in SND) {
    (function (d) {
      /* WebAudio yolu: ses seviyesi ve döngü tam kontrol edilir.
         file:// gibi XHR'in engellendiği ortamlarda <audio> devreye girer. */
      if (!AC) { sndFallback(d); return; }
      var bitti = false;
      var vazgec = function () { if (!bitti) { bitti = true; sndFallback(d); } };
      /* hiçbir olay tetiklenmezse yine de sesli kal */
      setTimeout(function () { if (!d.buf) vazgec(); }, 4000);
      try {
        var x = new XMLHttpRequest();
        x.open('GET', d.url, true);
        x.responseType = 'arraybuffer';
        x.onload = function () {
          if (bitti) return;
          if (!x.response || !x.response.byteLength) { vazgec(); return; }
          try {
            AC.decodeAudioData(x.response,
              function (buf) { if (!bitti) { bitti = true; d.buf = buf; } },
              vazgec);
          } catch (e) { vazgec(); }
        };
        x.onerror = vazgec;
        x.onabort = vazgec;
        x.send();
      } catch (e) { vazgec(); }
    })(SND[k]);
  }
}

/* file:// gibi XHR'in engellendigi ortamlarda <audio> ile cal */
function sndFallback(d) {
  if (d.buf || d.el) return;
  try {
    var el = new Audio(d.url);
    el.preload = 'auto';
    el.volume = d.vol;
    if (d.loop) el.loop = true;
    d.el = el;
  } catch (e) { }
}

/* tek seferlik çal */
function sndPlay(key, rate) {
  var d = SND[key];
  if (!d || MUTED) return false;
  if (!d.buf && d.el) {
    try {
      var c = d.el.cloneNode(); c.volume = sndElVol(d);
      /* play() sozu reddedilebilir (otomatik oynatma engeli, erken durdurma);
         try/catch async reddi yakalamaz, bu yuzden acikca yutuluyor. */
      var sz0 = c.play(); if (sz0 && sz0.catch) sz0.catch(function () { });
      return true;
    } catch (e) { return false; }
  }
  if (!AC || !d.buf) return false;
  var s = AC.createBufferSource();
  s.buffer = d.buf;
  if (rate) s.playbackRate.value = rate;
  var g = AC.createGain();
  g.gain.value = d.vol;
  s.connect(g); g.connect(sndBus(d));
  s.start(0);
  return true;
}

/* sürekli döngü (fritöz, sokak) */
function sndLoop(key, on, vol) {
  var d = SND[key];
  if (!d) return false;
  if (!d.buf && d.el) {
    try {
      d.el.volume = MUTED ? 0 : clamp((vol === undefined ? d.vol : vol) *
        volKazanc(d.tur === 'mus' ? VOL.mus : VOL.sfx), 0, 1);
      if (on && !MUTED) {
        /* Ayni karede pause() gelirse play() sozu AbortError ile reddedilir. */
        if (d.el.paused) { var sz = d.el.play(); if (sz && sz.catch) sz.catch(function () { }); }
      } else d.el.pause();
      return true;
    } catch (e) { return false; }
  }
  if (!AC) return false;
  if (on && !d.buf) return false;
  if (on && !d.node) {
    var s = AC.createBufferSource();
    s.buffer = d.buf; s.loop = true;
    /* dongu araligi verilmisse yalniz o bolge doner */
    if (d.dS !== undefined && d.dE !== undefined && d.dE > d.dS && d.dE <= s.buffer.duration) {
      s.loopStart = d.dS;
      s.loopEnd = d.dE;
    }
    var g = AC.createGain(); g.gain.value = 0;
    s.connect(g); g.connect(sndBus(d));
    /* dongu bolgesi varsa calma da oradan baslasin: kaydin
       sessiz girisi beklenmeden dolu ses duyulur */
    try { s.start(0, (s.loopStart > 0 ? s.loopStart : 0)); } catch (e) { return false; }
    d.node = s; d.gain = g;
  }
  if (d.gain) {
    var target = (on && !MUTED) ? (vol === undefined ? d.vol : vol) : 0;
    d.gain.gain.setTargetAtTime(target, AC.currentTime, 0.25);
  }
  return true;
}
