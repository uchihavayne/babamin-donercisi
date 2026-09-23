/* ============================================================
   DÖNER EFSANESİ — music.js
   Basit hicaz makamı döngüsü (WebAudio, örnek dosyası yok)
   ============================================================ */
'use strict';

var MUS = {
  on: true, timer: null, step: 0, next: 0, tempo: 0.135, gain: null, mode: 'menu'
};
var SCALE = [293.66, 311.13, 369.99, 392.00, 440.00, 466.16, 523.25, 587.33]; /* D hicaz */
var MEL = [
  [0, 6], [-1, 0], [2, 5], [-1, 0], [3, 6], [-1, 0], [2, 4], [-1, 0],
  [4, 7], [-1, 0], [3, 5], [-1, 0], [1, 5], [-1, 0], [0, 6], [-1, 0]
];
var MEL2 = [
  [7, 7], [-1, 0], [6, 5], [5, 5], [4, 6], [-1, 0], [3, 5], [2, 4],
  [3, 6], [-1, 0], [2, 5], [-1, 0], [0, 7], [-1, 0], [-1, 0], [-1, 0]
];
var BASS = [73.42, 0, 0, 0, 98.00, 0, 0, 0, 73.42, 0, 0, 0, 110.00, 0, 0, 0];

function musNote(freq, dur, type, vol, when) {
  if (!AC || MUTED || !MUS.gain) return;
  var o = AC.createOscillator(), g = AC.createGain();
  o.type = type; o.frequency.setValueAtTime(freq, when);
  g.gain.setValueAtTime(0, when);
  g.gain.linearRampToValueAtTime(vol, when + .01);
  g.gain.exponentialRampToValueAtTime(.0006, when + dur);
  o.connect(g); g.connect(MUS.gain);
  o.start(when); o.stop(when + dur + .02);
}
function musPerc(when, hard) {
  if (!AC || MUTED || !MUS.gain) return;
  var s = AC.createBufferSource(); s.buffer = noiseBuf(.12);
  var f = AC.createBiquadFilter(); f.type = hard ? 'highpass' : 'lowpass';
  f.frequency.value = hard ? 3800 : 260;
  var g = AC.createGain();
  g.gain.setValueAtTime(hard ? .05 : .12, when);
  g.gain.exponentialRampToValueAtTime(.001, when + (hard ? .05 : .12));
  s.connect(f); f.connect(g); g.connect(MUS.gain);
  s.start(when); s.stop(when + .16);
}
function musTick() {
  if (!AC || !MUS.on) return;
  if (!MUS.gain) {
    MUS.gain = AC.createGain();
    MUS.gain.gain.value = 0.0;
    MUS.gain.connect(MUSBUS || MASTER);
  }
  /* 'off' modu hic ele alinmiyordu: sokak sesi yuklendikten sonra bile
     sentez muzigi menu sesiyle calmaya devam ediyordu. */
  if (MUS.mode === 'off') {
    MUS.gain.gain.setTargetAtTime(0, AC.currentTime, 0.3);
    MUS.next = AC.currentTime + 0.2;      /* birikmis notalari at */
    return;
  }
  var target = MUTED ? 0 : (MUS.mode === 'play' ? 0.34 : 0.20);
  MUS.gain.gain.setTargetAtTime(target, AC.currentTime, 0.4);
  var lookahead = AC.currentTime + 0.2;
  var tempo = MUS.mode === 'play' ? 0.125 : 0.155;
  while (MUS.next < lookahead) {
    if (MUS.next < AC.currentTime) MUS.next = AC.currentTime + 0.02;
    var i = MUS.step % 16;
    var bar = Math.floor(MUS.step / 16) % 4;
    var pat = (bar === 1 || bar === 3) ? MEL2 : MEL;
    var n = pat[i];
    if (n[0] >= 0) {
      musNote(SCALE[n[0]], n[1] * tempo * 0.9, 'square', .045, MUS.next);
      if (MUS.mode === 'play' && bar >= 2) musNote(SCALE[n[0]] * 2, n[1] * tempo * .5, 'triangle', .018, MUS.next + .01);
    }
    if (BASS[i]) musNote(BASS[i], tempo * 3.4, 'triangle', .085, MUS.next);
    if (i % 4 === 0) musPerc(MUS.next, false);
    if (i === 4 || i === 12 || (MUS.mode === 'play' && i === 10)) musPerc(MUS.next, true);
    MUS.next += tempo;
    MUS.step++;
  }
}
function musInit() {
  if (MUS.timer) return;
  MUS.timer = setInterval(musTick, 90);
}
function musSet(mode) {
  /* Sokak sesi dosyasi yuklendiyse sentez muzigi hic calmasin.
     WebAudio (buf) ya da <audio> geri donusu (el) — ikisi de sayilir. */
  if (typeof SND !== 'undefined' && SND.street && (SND.street.buf || SND.street.el)) {
    MUS.mode = 'off';
    return;
  }
  MUS.mode = mode;
}
