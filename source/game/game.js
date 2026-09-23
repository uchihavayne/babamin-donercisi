/* ============================================================
   DÖNER EFSANESİ — game.js
   Basit başlangıç → upgrade → otomasyon
   ============================================================ */
'use strict';

var G = {
  scene: 'title', t: 0, sceneT: 0,
  day: 1, money: 0, up: {}, best: 0, totalSold: 0, debt: DEBT_START, act: 0, branch: 0,
  /* -1 = babanin dukkani, 0..6 = o siradaki sube. Yalniz gorunusu degistirir. */
  city: -1,
  /* servis durumu */
  timeLeft: 0, cfg: null,
  spit: null, shave: null, meat: 0,
  stock: { pickle: 16, yogurt: 16, ayran: 0, sweet: 0, tomato: 0, pepper: 0 },
  cut: null, fryer: null, friesTray: 0,
  boards: [], sel: 0, paper: null, grill: null,
  drinkM: null, cups: null, fbox: null,
  hand: null, coins: [], customers: [], spawnT: 0,
  stat: null, chef: { mode: 'idle', armT: 0 }, uncle: { left: 0, flashT: 0 },
  crate: { open: false, t: 0, popT: 0 }, phone: null, courier: null,
  sauceFx: null, shutT: 0, shutSnd: 0, flyCoins: [], celeb: null,
  night: null, moto: { broken: false, cost: 0 }, prologueSeen: false, luck: 0, luckMsg: 0, luckAmt: 0,
  weather: 'sun', rainT: 0, trash: 0, emptyT: 0, inspect: null,
  custom: { sign: 'USTA DÖNER', sub: 'EFSANE LEZZET', poster: 1, counter: 0 },
  stats: { wraps: 0, drinks: 0, boxes: 0, sweets: 0, isk: 0, earned: 0, best: 0, days: 0, debtPaid: 0, phone: 0, lost: 0, fines: 0 },
  flyIng: [], flyMeat: [], fxTray: null, stockAnim: null,
  hudPop: 0, hint: '', hintT: 0, tut: 99, autoT: 0, test: false,
  bs: null, bsT: 0                  /* acilan basarimlar / tarama sayaci */
};

/* ---------------- yardımcılar ---------------- */
function hitST(k) { var s = ST[k]; return inRect(IN.x, IN.y, s.x, s.y, s.w, s.h); }
function say(s) { G.hint = T(s); G.hintT = 1.8; }
function stMax() { return TUN.stockMax(G); }

/* ---------------- gün ---------------- */
function startDay() {
  G.cfg = dayCfg(G.day, G);
  G.timeLeft = G.cfg.len;
  G.spit = { rot: 0, sliceT: 0, cutDepth: 0, roast: .85, mass: 1 };
  G.shave = { travel: 0, lastY: -1, act: 0, auto: 0, cd: 0 };
  G.meat = 0;
  G.cut = { potato: false, prog: 0, cutting: false, raw: 0, autoT: 0, hold: 0, slash: [], yon: 1, sayac: 0 };
  G.fryer = { state: 'idle', t: 0, dur: 0, load: 0, prog: 0, basketY: -5 };
  G.friesTray = 0;
  G.boards = [null, null, null]; G.act = 0;
  G.paper = { busy: 0, dur: 1, idx: 0 };
  /* Izgara COK SLOTLU: slots = [{w, t, dur, done, yan}]
     yan = yanma ilerlemesi 0..1 (yalniz sv1-2'de isler). */
  G.grill = { slots: [], sz: 0 };
  G.drinkM = { pour: null, t: 0, pours: {} };   /* pours: her içecek kendi akışını sürdürür */
  G.cups = { fanta: null, cola: null, ayran: null };
  G.fbox = { busy: 0, ready: 0, fly: null };
  G.hand = null; G.coins = []; G.customers = [];
  G.spawnT = G.day === 1 ? 999 : ILK_MUSTERI;   /* 1. gun: musteriyi ogretici cagirir */
  G.stat = { wraps: 0, drinks: 0, boxes: 0, sweets: 0, isk: 0, lost: 0, earned: 0, tips: 0, debtPaid: 0, branch: 0, brPerf: 1 };
  G.sauceFx = { hot: 0, garlic: 0, butter: 0 };
  G.shutT = 1; G.shutSnd = 0; G.flyCoins = [];
  if (!G.moto) G.moto = { broken: false, cost: 0 };
  if (!G.moto.broken && TUN.phoneOn(G) && G.day >= MOTO_DAY && chance(MOTO_CHANCE)) {
    G.moto.broken = true;
    G.moto.cost = Math.round((260 + G.day * 22) / 10) * 10;
    G.moto.newT = 4;
  }
  G.chef = { mode: 'idle', armT: 0 };
  /* --- MAC GUNU --- gun basinda belli olur, panelde yazar. */
  if (!G.macHedef) G.macHedef = MAC_ILK + Math.floor(Math.random() * 4);
  G.macGun = G.day >= G.macHedef;
  if (G.macGun) G.macHedef = G.day + MAC_ARA_MIN +
    Math.floor(Math.random() * (MAC_ARA_MAK - MAC_ARA_MIN + 1));
  G.macDalga = false;
  rakipGunBasi();
  G.bahisSonuc = null;
  /* --- ELEKTRIK KESINTISI --- gunun ortasinda, bir kez */
  G.kesinti = null;
  if (G.day >= KESINTI_GUN && TUN.kesintiVar(G) && chance(KESINTI_SANS)) {
    G.kesinti = { faz: 'bekle', t: 0, basla: rnd(.30, .70), sure: TUN.kesintiSure(G), uyari: 0 };
  }
  /* --- SOKAK KEDISI --- gunde en fazla bir kez, gun ortasinda gelir */
  G.kedi = (G.day >= KEDI_GUN && chance(KEDI_SANS))
    ? { faz: 'yok', t: 0, girisT: rnd(12, 40), x: 0, doydu: false, miyav: 0 }
    : null;
  /* Ozel musteri kotasi gunluk: bir kere gelen o gun bir daha gelmez. */
  G.ozelBugun = false;
  if (!G.ozelGecmis) G.ozelGecmis = {};
  if (!G.ozelHedef) G.ozelHedef = OZEL_ILK_MIN +
    Math.floor(Math.random() * (OZEL_ILK_MAK - OZEL_ILK_MIN + 1));
  G.uncle = { left: TUN.uncleUses(G), flashT: 0 };
  G.crate = { open: false, t: 0, popT: 0, a: 0 };
  /* HEPSİ boş başlar — günü stok doldurarak açarsın. Ayran ve tatlı
     eskiden dolu geliyordu; diğer tepsilerle tutarsızdı ve o iki
     istasyon günün başında hiç dokunulmadan işliyordu. */
  G.stock = {
    pickle: 0, yogurt: 0, ayran: 0, sweet: 0,
    tomato: 0, pepper: 0
  };
  G.stockAnim = {
    pickle: G.stock.pickle, yogurt: G.stock.yogurt, ayran: G.stock.ayran, sweet: G.stock.sweet,
    tomato: G.stock.tomato, pepper: G.stock.pepper
  };
  G.fxTray = { pickle: 0, yogurt: 0, fries: 0, meat: 0, ayran: 0, sweet: 0, tomato: 0, pepper: 0 };
  /* --- DEMIRKENT: gunun fermani --- */
  G.ferman = fermanSehri(G)
    ? { liste: fermanSec(G.day), ceza: 0, kapandi: false, kagit: 0, kagitT: 0,
        kayit: [], kacan: 0 }
    : null;
  G.gozcu = fermanSehri(G) ? gozcuKur() : null;
  /* Ekonomi BURADA kurulur, sehreGit'te degil: sehreGit ayni sehre
     tekrar girilince erken donuyor, kayittan Demirkent'te acilan oyunda
     hic calismiyordu ve G.hane null kaliyordu. */
  if (fermanSehri(G)) fermanEkonomiKur(false);
  /* Lider ziyareti: gun ortasinda gelir, tek sey ister, sabri kisadir. */
  G.lider = (fermanSehri(G) && liderGunu(G.fgun, G.day))
    ? { state: 'bekle', t: rnd(35, Math.max(45, G.cfg.len - 55)),
        x: W + 40, y: 152, tx: 250, sabir: 1, istek: null, sonuc: null }
    : null;
  G.tutanak = null;
  G.act = 0;
  G.flyIng = [];
  G.flyMeat = [];
  G.flyP = null;
  phoneReset();
  rollWeather();
  G.trash = 0; G.emptyT = 0;
  G.inspect = null;
  if (G.day >= INSPECT_DAY && chance(INSPECT_CHANCE)) {
    G.inspect = { state: 'wait', t: rnd(25, Math.max(30, G.cfg.len - 40)), x: W + 26, y: 152, tx: 250, dirty: false, fine: 0, line: '' };
  }
  G.tut = G.day === 1 ? 0 : 99;
  if (typeof TUTFX !== 'undefined') { TUTFX.ilk = true; TUTFX.karart = 0; }
  G.scene = 'play'; G.sceneT = 0;
}
function endDay() {
  while (G.coins.length) collectCoin(0, true);
  G.best = Math.max(G.best, G.day);
  /* Bahis SUBE GELIRINDEN once cozulur: 'para' bahsi gunun kendi
     kazancina bakiyor, sube geliri onu sisirmemeli. */
  bahisCoz();
  /* şube geliri: gün bitince kasaya girer, performansa göre ölçeklenir */
  var served = (G.stat.wraps || 0) + (G.stat.boxes || 0) + (G.stat.isk || 0);
  G.stat.brPerf = branchPerf(served, G.stat.lost || 0, G.day, G);
  G.stat.branch = Math.round(branchBase(G) * G.stat.brPerf);
  if (G.stat.branch > 0) {
    /* Demirkent ayri ekonomi: sube geliri buraya akmaz. */
    if (fermanSehri(G)) G.stat.branch = 0; else G.money += G.stat.branch;
    G.stat.earned += G.stat.branch;
  }
  /* borç taksiti: günün kazancından kesilir */
  var pay = 0;
  if (G.debt > 0 && !fermanSehri(G)) {
    pay = Math.min(G.debt, Math.round(G.stat.earned * DEBT_CUT));
    G.debt -= pay;
    G.money = Math.max(0, G.money - pay);
    G.stat.debtPaid = pay;
    if (G.debt <= 0) { G.debt = 0; if (!G.debtCleared) { G.debtCleared = true; G.celeb = { t: 0 }; } }
  }
  /* toplam istatistikler */
  var S = G.stats;
  S.wraps += G.stat.wraps; S.drinks += G.stat.drinks; S.boxes += G.stat.boxes;
  S.sweets += G.stat.sweets || 0; S.isk = (S.isk || 0) + (G.stat.isk || 0);
  S.earned += G.stat.earned; S.lost += G.stat.lost;
  S.debtPaid += pay; S.fines += (G.stat.fine || 0); S.days++;
  if (G.stat.earned > S.best) S.best = G.stat.earned;
  /* ---- basarim sayaclari (gun sonu) ---- */
  S.bahsis = (S.bahsis || 0) + (G.stat.tips || 0);
  var gunAdet = (G.stat.wraps || 0) + (G.stat.drinks || 0) + (G.stat.boxes || 0) +
                (G.stat.sweets || 0) + (G.stat.isk || 0);
  if (gunAdet > (S.gunEnCok || 0)) S.gunEnCok = gunAdet;
  if ((G.stat.lost || 0) === 0 && gunAdet >= 10) S.mukemmel = (S.mukemmel || 0) + 1;
  S.temizSeri = (G.stat.fine || 0) > 0 ? 0 : (S.temizSeri || 0) + 1;
  if (typeof stMax === 'function' && G.stock &&
      G.stock.pickle >= stMax() && G.stock.yogurt >= stMax()) S.depoTam = (S.depoTam || 0) + 1;
  if (G.money <= 0 && !fermanSehri(G)) S.sifirGun = (S.sifirGun || 0) + 1;
  if (fermanSehri(G)) {
    if ((G.fgun || 0) > (S.fgunEn || 0)) S.fgunEn = G.fgun || 0;
    if ((G.ev || 0) > (S.evEn || 0)) S.evEn = G.ev || 0;
    if (!G.ferman || !G.ferman.kayit || !G.ferman.kayit.length) S.temizGun = (S.temizGun || 0) + 1;
  }
  /* ziyaret edilen sehirler (tekrarsiz) */
  if (!S.sehir) S.sehir = [];
  if (G.city >= 0 && S.sehir.indexOf(G.city) < 0) S.sehir.push(G.city);
  /* Demirkent: ihlal varsa gun sonu ozetinden ONCE resmi tutanak dokulur. */
  G.tutanak = (G.ferman && G.ferman.kayit && G.ferman.kayit.length)
    ? { kayit: G.ferman.kayit.slice(), t: 0 } : null;
  /* Zorunlu telefon gununde gun sonunda acik kalan paket siparis de ihlal. */
  if (fermanTelefonZorunlu() && G.ferman && !G.ferman.kapandi &&
      G.phone && G.phone.state === 'order') {
    var tf2 = null;
    for (var tj = 0; tj < G.ferman.liste.length; tj++)
      if (G.ferman.liste[tj].id === 'telefon') tf2 = G.ferman.liste[tj];
    fermanIhlal(tf2, W / 2, 110, 'telefon');
  }
  /* Demirkent gun sonu ozet DEGIL, gecinme hesabidir. */
  G.hesap = fermanSehri(G) ? hesapKur() : null;
  G.scene = 'dayend'; G.sceneT = 0;
  SFX.shutter();
  SFX.levelup();
  if (typeof basarimTara === 'function') basarimTara();
  saveAll();
}
/* yeni oyun: tüm ilerlemeyi sıfırla (şube, borç, istatistik dahil) */
function resetProgress() {
  G.day = 1; G.money = 0; G.tips = 0; G.up = {}; G.stars = {};
  G.dersGorulmus = false; G.ders = null;
  G.fpara = FP_BASLANGIC; G.fgun = 0; G.hane = null; G.fbatik = 0; G.hesap = null; G.ev = 0;
  G.best = 0; G.totalSold = 0; G.branch = 0; G.city = -1;
  G.debt = DEBT_START; G.debtCleared = false; G.celeb = null;
  G.luck = 0; G.moto = { broken: false, cost: 0 };
  G.stats = { wraps: 0, drinks: 0, boxes: 0, sweets: 0, isk: 0, earned: 0, best: 0, days: 0, debtPaid: 0, phone: 0, lost: 0, fines: 0, stolen: 0,
    /* basarim sayaclari */
    bahsis: 0, enBahsis: 0, gunEnCok: 0, mukemmel: 0, enSeri: 0, temizSeri: 0,
    depoTam: 0, buyukSiparis: 0, fgunEn: 0, evEn: 0, lider: 0, temizGun: 0,
    kacak: 0, muhur: 0, yanik: 0, sifirGun: 0, moto: 0, dayi: 0, fed: 0, sehir: [] };
  G.custom = null;
  G.bs = {};
  /* Rakip ve mac takvimi */
  G.rakipHedef = 0; G.rakipKapandi = false; G.rakipSeri = 0;
  G.rakipAcik = false; G.rakip = null; G.bahis = null; G.bahisSonuc = null;
  G.macHedef = 0; G.macGun = false;
  /* Ozel musteri takvimi: ilk ozel 4-8. gunlerde, sonra 10-15 gunde bir */
  G.ozelBugun = false; G.ozelGecmis = {};
  G.ozelHedef = OZEL_ILK_MIN + Math.floor(Math.random() * (OZEL_ILK_MAK - OZEL_ILK_MIN + 1));
}

/* Kayit YALNIZ kalici ilerlemeyi tutar: gun, para, yukseltmeler,
   sube, borc, istatistik. Gun ORTASI durum (tahtalar, malzemeler,
   musteriler, kalan sure) BILEREK kaydedilmiyor - oyun gun basindan
   devam eder. Yarim gunu geri yuklemek, oyuncunun kapatarak kotu bir
   gunu geri almasina da izin verirdi.
   Kayit basarisiz olursa oyuncu BIR KEZ uyarilir; sessiz kalmak
   ilerlemenin durdugunu fark etmemesine yol aciyordu. */
function saveAll() {
  saveGame({ day: G.day, money: G.money, up: G.up, best: G.best, totalSold: G.totalSold, debt: G.debt, stats: G.stats, custom: G.custom, moto: G.moto, prologueSeen: G.prologueSeen, luck: G.luck, branch: G.branch, city: G.city, dersGorulmus: G.dersGorulmus,
    fpara: G.fpara, fgun: G.fgun, hane: G.hane, fbatik: G.fbatik, ev: G.ev, bs: G.bs,
    /* ozel musteri takvimi: hangi gun kim geldi, siradaki gun ne zaman */
    ozelHedef: G.ozelHedef, ozelGecmis: G.ozelGecmis,
    /* rakip: dukkani kapandiysa bir daha acilmasin, bahis serisi dursun */
    rakipHedef: G.rakipHedef, rakipKapandi: G.rakipKapandi, rakipSeri: G.rakipSeri,
    /* mac ve kedi takvimi */
    macHedef: G.macHedef });
  if (typeof saveUyar === 'function') saveUyar();
}

/* ---------------- döner kesme (fare yukarı-aşağı) ---------------- */
function updateShave(dt) {
  var sh = G.shave, s = G.spit;
  s.rot += dt * 1.15;
  if (s.sliceT > 0) s.sliceT = Math.max(0, s.sliceT - dt * 5);
  if (s.swipe) { s.swipe.t -= dt * 5; if (s.swipe.t <= 0) s.swipe = null; }
  if (s.cutDepth > 0) s.cutDepth = Math.max(0, s.cutDepth - dt * 5);
  if (sh.act > 0) sh.act -= dt;
  if (sh.cd > 0) sh.cd -= dt;

  var over = hitST('spit') && !testPanelOpen();
  if (over) {
    if (sh.lastY >= 0) {
      var d = Math.abs(IN.y - sh.lastY);
      if (d > 0.4) {
        sh.travel += Math.min(d, 55);
        sh.act = .25;
        if (chance(d * .02)) part({
          x: LAY.spit.cx - 14, y: IN.y + rnd(-3, 3), vx: rnd(-20, -6), vy: rnd(-18, 6),
          life: .4, col: '#e0a860', g: 220, sz: 1, floor: ST.meat.y + rnd(4, 12)
        });
      }
    }
    sh.lastY = IN.y;
    /* Hem yeterli mesafe hem bekleme suresi dolmali. Bekleme dolmadiysa
       mesafe birikmeye devam eder, hareket bosa gitmez. */
    var need = TUN.shaveDist(G);
    if (sh.travel >= need && sh.cd <= 0) {
      sh.travel -= need; sh.cd = TUN.shaveCd(G); doSlice();
      if (sh.travel > need * 2) sh.travel = need * 2;   /* birikim tavani */
    }
  } else {
    sh.lastY = -1;
    sh.travel *= Math.pow(.2, dt);
  }
  if (TUN.autoShave(G) && G.meat < TUN.meatCap()) {
    sh.auto += dt;
    if (sh.auto > TUN.autoShaveCd()) { sh.auto = 0; doSlice(); }
  }
}
function doSlice() {
  if (G.meat >= TUN.meatCap()) { G.meat = TUN.meatCap(); return; }
  G.meat++;
  G.spit.sliceT = 1; G.spit.cutDepth = 5;
  G.spit.swipe = { y: clamp(IN.y, LAY.spit.top + 8, LAY.spit.bot - 12), t: 1 };
  G.chef.mode = 'slice'; G.chef.armT = 0;
  SFX.slice();

  var cx = LAY.spit.cx, sy = clamp(IN.y, LAY.spit.top + 12, LAY.spit.bot - 20);

  /* --- kesilen dilim: bıçağın değdiği sol yüzden ayrılıp düşer --- */
  spawnFlyMeat(cx - 18 - rnd(0, 4), sy);

  /* Bicagin izinde ayrilan et. Eskiden dordu de 1 px'lik noktaydi;
     artik ikisi gercek KIVRILMIS dilim ('et' tipi), ikisi ince kiymik
     olarak kaliyor - hepsi dilim olsa tezgah kalabaliklasiyordu. */
  for (var i = 0; i < 2; i++) {
    part({
      x: cx - 12, y: sy + rnd(-3, 3), vx: rnd(-30, -8), vy: rnd(-26, 2),
      life: rnd(.42, .70), type: 'et', k: rnd(1, 900), sc: rnd(.85, 1.15),
      g: 300, floor: ST.meat.y + rnd(4, 14), bounce: .22
    });
  }
  for (var i2 = 0; i2 < 2; i2++) {
    part({
      x: cx - 12, y: sy + rnd(-4, 4), vx: rnd(-34, -10), vy: rnd(-30, 2),
      life: rnd(.30, .55), col: pick(['#c98436', '#eeb464', '#8a4f1e']), g: 320, sz: 1,
      floor: ST.meat.y + rnd(4, 14), bounce: .25
    });
  }
  /* sıcak yağ zerresi */
  if (chance(.5)) {
    part({
      x: cx - 10, y: sy, vx: rnd(-26, -6), vy: rnd(-40, -18),
      life: .4, col: '#ffe6ae', g: 300, sz: 1
    });
  }
}

/* Şişten tepsiye düşen dilim. Tepsideki yığınla aynı çizim
   fonksiyonunu (meatStrip) kullanır: havada ne görüyorsan
   tepsiye o iniyor. */
function spawnFlyMeat(x0, y0) {
  if (G.flyMeat.length > 14) return;
  var hedefX = ST.meat.x + rnd(7, ST.meat.w - 8);
  var doluluk = clamp(G.meat / TUN.meatCap(), 0, 1);
  /* yığın yükseldikçe dilim daha yükseğe iner */
  var hedefY = ST.meat.y + ST.meat.h - 9 - doluluk * (ST.meat.h - 16);
  G.flyMeat.push({
    t: 0,
    x0: x0, y0: y0,
    x1: hedefX, y1: hedefY,
    k: (Math.random() * 1000) | 0,          /* meatStrip biçimi */
    sz: rnd(.35, .95),
    don: rnd(0, 6.28),
    donHiz: rnd(-9, 9),
    sp: rnd(1.15, 1.5),
    yay: rnd(10, 18),                       /* yayın yüksekliği */
    savrul: rnd(9, 16)                      /* koniden dışa savrulma payı */
  });
}

function updateFlyMeat(dt) {
  for (var i = G.flyMeat.length - 1; i >= 0; i--) {
    var f = G.flyMeat[i];
    f.t += dt * f.sp;
    f.don += f.donHiz * dt;
    if (f.t >= 1) {
      G.flyMeat.splice(i, 1);
      G.fxTray.meat = 1;
      SFX.pop();
      /* düşerken sıçrayan yağ */
      burst(f.x1, f.y1, 3, ['#c98436', '#eeb464', '#8a4f1e'], { spMax: 22, up: 10, sz: 1, lifeMax: .3 });
    }
  }
}

function drawFlyMeat(t) {
  for (var i = 0; i < G.flyMeat.length; i++) {
    var f = G.flyMeat[i];
    var k = clamp(f.t, 0, 1);
    /* Dilim önce koniden dışa savrulur, sonra tepsiye iner.
       Düz doğrusal uçuşta şişin içinden geçiyormuş gibi görünüyordu. */
    var fx0 = lerp(f.x0, f.x1, k) - Math.sin(k * Math.PI) * f.savrul;
    var fy0 = lerp(f.y0, f.y1, k) - Math.sin(k * Math.PI) * f.yay;
    /* iniş gölgesi: yaklaştıkça koyulaşır */
    ctx.globalAlpha = .10 + k * .22;
    ell(f.x1, f.y1 + 2, 3 + k * 2, 1, '#2a1808');
    ctx.globalAlpha = 1;
    /* takla: dönüş sinüsüyle boyu kısalıp uzar, düz dilim hissi verir */
    var don = Math.abs(Math.cos(f.don));
    ctx.save();
    ctx.translate(Math.round(fx0), Math.round(fy0));
    ctx.scale(1, Math.max(.30, don));
    meatStrip(0, 0, .92 + don * .1, f.k, f.sz);
    ctx.restore();
  }
}

/* ---------------- dürüm hazırlama ---------------- */
/* ---------------- DEMIRKENT: ayri kasa ----------------
   Moddayken butun para hareketi G.fpara uzerinden gider. Ana oyunun
   kasasi (G.money) burada ne artar ne eksilir. G.fpara EKSIYE dusebilir —
   baski buradan geliyor; G.money'de oyle bir sey yok. */
function fkasaAcik() { return fermanSehri(G); }
function kasaOku() { return fkasaAcik() ? (G.fpara || 0) : G.money; }
function kasaEkle(n) {
  if (fkasaAcik()) G.fpara = (G.fpara || 0) + n;
  else G.money += n;
}
function kasaDus(n) {
  if (fkasaAcik()) G.fpara = (G.fpara || 0) - n;      /* eksiye dusebilir */
  else G.money = Math.max(0, G.money - n);
}
/* Moda ilk giriste ekonomiyi kur. sehreGit'ten cagrilir. */
function fermanEkonomiKur(zorla) {
  /* hane bos dizi de olabilir (eski kayit): onu da yeniden kur. */
  if (!zorla && G.hane && G.hane.length && haneCanli(G.hane) > 0) return;
  G.fpara = FP_BASLANGIC;
  G.fgun = 0;
  G.hane = haneKur();
  G.fbatik = 0;
  G.ev = 0;                      /* en alttan baslanir: bodrum kati */
}
/* Tasinma: pesinati oder, kademeyi yukseltir. YALNIZ bir ust kademeye —
   'kademe kademe' yukselmek modun uzun vadeli hedefi; atlamak yok. */
function eveTasin(i) {
  if (i !== (G.ev || 0) + 1 || i >= EVLER.length) return false;
  var e = EVLER[i];
  if ((G.fpara || 0) < e.pesinat) { SFX.bad(); return false; }
  G.fpara -= e.pesinat;
  G.ev = i;
  SFX.cash(); SFX.levelup();
  saveAll();
  return true;
}

/* Lider ve muhafizlari. Sivilden ayrilsin diye: uzun palto, apolet,
   madalya, taskin kasket. Iki muhafiz iki yanda, tufekleri omuzda. */
function drawLider(t) {
  var L = G.lider;
  if (!L || L.state === 'bekle') return;
  var x = Math.round(L.x), y = L.y;

  /* --- muhafizlar: liderin iki yaninda, bir adim geride --- */
  for (var m = 0; m < 2; m++) {
    var mx = x + (m ? 26 : -26);
    ctx.globalAlpha = .22; ell(mx, y, 5, 2, '#000'); ctx.globalAlpha = 1;
    fr(mx - 4, y - 20, 8, 20, '#3a413a');
    fr(mx - 4, y - 20, 8, 1, '#4c544c');
    fr(mx - 4, y - 8, 8, 1, '#20241f');
    fr(mx - 3, y - 28, 6, 8, '#c99a66');
    fr(mx - 2, y - 25, 1, 1, '#14161a'); fr(mx + 1, y - 25, 1, 1, '#14161a');
    /* migfer */
    fr(mx - 4, y - 31, 8, 3, '#39403a');
    fr(mx - 3, y - 32, 6, 1, '#39403a');
    fr(mx - 4, y - 28, 8, 1, '#20241f');
    /* omuzdaki tufek */
    for (var i = 0; i < 11; i++) px(mx + (m ? 5 : -5), y - 26 + i, '#2a2620');
  }

  /* --- lider --- */
  ctx.globalAlpha = .28; ell(x, y, 6, 2, '#000'); ctx.globalAlpha = 1;
  /* uzun palto */
  fr(x - 6, y - 24, 12, 24, '#22252b');
  fr(x - 6, y - 24, 12, 1, '#333740');
  fr(x - 1, y - 23, 1, 22, '#171a1f');
  fr(x - 6, y - 12, 12, 2, '#0e1013');
  fr(x + 1, y - 12, 3, 2, '#c9a23a');
  /* apolet + madalya */
  fr(x - 6, y - 24, 4, 2, '#c9a23a'); fr(x + 2, y - 24, 4, 2, '#c9a23a');
  fr(x - 4, y - 20, 2, 2, '#c9a23a'); fr(x - 4, y - 17, 2, 2, '#b83228');
  fr(x - 1, y - 20, 2, 2, '#c9a23a');
  /* kollar arkada */
  fr(x - 8, y - 22, 2, 10, '#171a1f');
  fr(x + 6, y - 22, 2, 10, '#171a1f');
  /* kafa */
  fr(x - 4, y - 33, 8, 9, '#d6ab7c');
  fr(x - 4, y - 26, 8, 2, '#c39a6e');
  fr(x - 2, y - 30, 1, 1, '#14161a'); fr(x + 2, y - 30, 1, 1, '#14161a');
  fr(x - 1, y - 27, 3, 1, '#8a5a4a');
  /* biyik */
  fr(x - 2, y - 28, 5, 1, '#3a2e24');
  /* taskin kasket */
  fr(x - 6, y - 37, 12, 4, '#171a1f');
  fr(x - 6, y - 38, 12, 1, '#2a2e35');
  fr(x - 6, y - 33, 12, 1, '#8e1c14');
  fr(x - 7, y - 32, 14, 1, '#0b0d10');
  /* kasket armasi */
  px(x, y - 36, '#e8dcb0');
  fr(x - 1, y - 35, 3, 1, '#c9a23a');

  /* --- istek balonu --- */
  if (L.state === 'bekliyor' && L.istek) {
    var bx = x - 18, by = y - 62;
    ctx.globalAlpha = .35; rrect(bx + 1, by + 2, 36, 20, 3, '#000'); ctx.globalAlpha = 1;
    rrect(bx, by, 36, 20, 3, '#f0e6cc');
    rrectOut(bx, by, 36, 20, 3, '#8e1c14');
    fr(x - 2, by + 20, 4, 3, '#f0e6cc');
    icon(L.istek.kind === 'drink' ? 'cola' : L.istek.kind, bx + 18, by + 10, t);
    /* sabir seridi: rejim kirmizisi */
    var sw = Math.round(32 * clamp(L.sabir, 0, 1));
    fr(bx + 2, by - 5, 32, 3, 'rgba(0,0,0,.35)');
    fr(bx + 2, by - 5, sw, 3, L.sabir > .35 ? '#c9a23a' : '#e2483a');
  }
}

/* ---------------- DEMIRKENT: LIDER ZIYARETI ----------------
   Iki muhafizla gelir, TEK urun ister, bekletilmeye tahammulu yoktur.
   Dogru verirsen odul + bir ihlal silinir; yanlis ya da gec verirsen
   LIDER_CEZA kadar ihlal birden yazilir. */
function liderIstekYap() {
  var secim = [{ kind: 'wrap' }];
  if (TUN.iskOn(G)) secim.push({ kind: 'plate' });
  if (TUN.drinkOn(G)) secim.push({ kind: 'drink', type: 'cola' });
  if (TUN.sweetOn(G)) secim.push({ kind: 'sweet' });
  return pick(secim);
}
function updateLider(dt) {
  var L = G.lider;
  if (!L || !G.ferman || G.ferman.kapandi) return;
  L.t -= dt;
  if (L.state === 'bekle') {
    if (L.t <= 0) {
      L.state = 'geliyor'; L.istek = liderIstekYap();
      /* Halk lideri gorunce cekilir: tezgah bosalir, sahne ona kalir.
         Ayrica musteri balonlariyla cakisma sorunu da boylece bitiyor. */
      for (var ci = 0; ci < G.customers.length; ci++) {
        var cc = G.customers[ci];
        if (cc.state === 'wait' || cc.state === 'walkin') {
          cc.state = 'leave'; cc.leaveDir = cc.x > W / 2 ? 1 : -1; cc.mood = 'wait';
        }
      }
      G.spawnT = 999;                       /* lider gidene kadar musteri yok */
      SFX.bell(); shake(.4, 2);
      ftext(T('LİDER GELİYOR'), W / 2, 96, '#e2483a', { life: 2.2, sc: 1 });
    }
    return;
  }
  if (L.state === 'geliyor') {
    L.x = approach(L.x, L.tx, dt * 70);
    if (Math.abs(L.x - L.tx) < 1) { L.state = 'bekliyor'; L.sabir = 1; }
    return;
  }
  if (L.state === 'bekliyor') {
    /* Sabri kisa: yaklasik 26 saniye. */
    L.sabir -= dt / 26;
    if (L.sabir <= 0) liderSonuc(false, 'bekletildi');
    return;
  }
  if (L.state === 'gidiyor') {
    L.x += dt * 90;
    if (L.x > W + 60) { G.lider = null; G.spawnT = 2.5; }   /* hayat normale doner */
  }
}
/* Lider tezgahta mi (urun verilebilir mi)? */
function liderBekliyor() {
  return !!(G.lider && G.lider.state === 'bekliyor');
}
function liderSonuc(iyi, sebep) {
  var L = G.lider;
  if (!L || L.sonuc) return;
  L.sonuc = iyi ? 'iyi' : 'kotu';
  L.state = 'gidiyor';
  if (iyi) {
    kasaEkle(LIDER_ODUL);
    G.stats.lider = (G.stats.lider || 0) + 1;
    /* takdir: bir ihlal silinir */
    if (G.ferman && G.ferman.ceza > 0) {
      G.ferman.ceza--;
      if (G.ferman.kayit && G.ferman.kayit.length) G.ferman.kayit.pop();
    }
    SFX.cash(); SFX.levelup(); flash(.25, '#ffe9a0');
    burst(L.x, L.y - 30, 22, [P.au0, P.au1, '#fff'], { spMax: 90, type: 'star', sz: 2 });
    ftext('+$' + fmtMoney(LIDER_ODUL), L.x, L.y - 62, P.au0, { life: 2, sc: 1 });
  } else {
    for (var i = 0; i < LIDER_CEZA; i++) {
      var lf = { id: 'lider', metin: sebep === 'bekletildi'
        ? 'Lider bekletildi' : 'Lidere yanlış ürün verildi' };
      fermanIhlal(lf, L.x, L.y - 60 - i * 8, 'lider');
    }
    SFX.bad(); shake(.6, 4); flash(.3, '#e2483a');
  }
}
/* Lidere urun ver. deliver() icinden cagrilir. */
function liderVer(it) {
  var L = G.lider;
  if (!L || L.state !== 'bekliyor' || !it) return false;
  var d = L.istek;
  var uygun = it.kind === d.kind && (d.kind !== 'drink' || it.type === d.type);
  if (it.kind === 'wrap' && it.burnt) uygun = false;
  G.hand = null;
  liderSonuc(uygun, uygun ? 'tamam' : 'yanlis');
  return true;
}

/* ---------------- DEMIRKENT: gun sonu gecinme hesabi ----------------
   Papers Please'in gider tablosu gibi: zorunlu kiralar kapatilamaz,
   yemek/isinma/ilac oyuncunun secimi. Kasa eksiye dusebilir; ust uste
   FP_BATIK_SINIR gun eksideysen tahliye edilirsin ve moddan cikarsin. */
function hesapKur() {
  if (!G.hane || !G.hane.length) fermanEkonomiKur(true);
  var kisi = haneCanli(G.hane);
  var hasta = haneHasta(G.hane);
  var kalem = [], sec = {};
  for (var i = 0; i < GIDER.length; i++) {
    var g = GIDER[i];
    if (g.hastaGerek && hasta === 0) continue;
    var tutar = giderTutar(g, G.fgun || 0, g.id === 'yemek' ? kisi : hasta || 1);
    if (g.id === 'ilac') tutar = giderTutar(g, G.fgun || 0) * hasta;
    kalem.push({ id: g.id, ad: g.ad, zorunlu: g.zorunlu, tutar: tutar });
    sec[g.id] = true;                 /* varsayilan: hepsi odenir */
  }
  return { kalem: kalem, sec: sec, t: 0, kisi: kisi, hasta: hasta,
           gelir: G.stat.earned || 0, ceza: G.stat.fine || 0, kapandi: false,
           /* Kapandiktan sonra hesapKalan() dusulmus kasadan tekrar gider
              cikarirdi; ekran icin anlik goruntu tutulur. */
           oncekiKasa: G.fpara || 0, sonKasa: null };
}
function hesapToplam(H) {
  var n = 0;
  for (var i = 0; i < H.kalem.length; i++) if (H.sec[H.kalem[i].id]) n += H.kalem[i].tutar;
  return n;
}
function hesapKalan(H) { return (G.fpara || 0) - hesapToplam(H); }

/* Hesabi uygula: parayi dus, atlanan kalemlerin bedelini hane halkina yaz. */
function hesapKapat() {
  var H = G.hesap;
  if (!H || H.kapandi) return;
  /* Hane hic kurulmamis olabilir (bozuk/eski kayit): dusup oyunu
     dondurmek yerine kendini toparlar. */
  if (!G.hane || !G.hane.length) G.hane = haneKur();
  H.kapandi = true;
  H.oncekiKasa = G.fpara || 0;
  G.fpara = hesapKalan(H);
  H.sonKasa = G.fpara;

  var olay = [];                                   /* gun sonu bildirimleri */
  var canli = G.hane.filter(function (u) { return !u.gitti; });

  /* --- yemek --- */
  if (!H.sec.yemek) {
    for (var i = 0; i < canli.length; i++) canli[i].ac++;
    olay.push({ tip: 'ac', ek: 'Ailen aç yattı' });
  } else {
    for (var j = 0; j < canli.length; j++) canli[j].ac = 0;
  }
  /* --- isinma: soguk gunde atlamak hastalik getirir --- */
  var soguk = G.weather === 'rain' || (G.fgun || 0) % 3 === 1;
  /* Iyi bir dairede yalitim var: ayni gecede hastalanma ihtimali duser. */
  if (!H.sec.isinma && soguk && canli.length && chance(clamp(0.62 * evSimdiki().hasta, 0, 1))) {
    var k = canli[Math.floor(Math.random() * canli.length)];
    k.hasta++;
    olay.push({ tip: 'hasta', ad: k.ad, ek: ' soğuktan hastalandı' });
  }
  /* --- aclik hastaliga doner --- */
  for (var a = 0; a < canli.length; a++) {
    if (canli[a].ac >= 3) { canli[a].ac = 1; canli[a].hasta++;
      olay.push({ tip: 'hasta', ad: canli[a].ad, ek: ' açlıktan hastalandı' }); }
  }
  /* --- ilac --- */
  if (H.sec.ilac) {
    for (var b = 0; b < canli.length; b++) if (canli[b].hasta > 0) canli[b].hasta--;
    olay.push({ tip: 'iyi', ek: 'İlaç alındı' });
  }
  /* --- uzun sure hasta kalan el konur --- */
  for (var c = 0; c < canli.length; c++) {
    if (canli[c].hasta >= 3) {
      canli[c].gitti = true;
      olay.push({ tip: 'kotu', ad: canli[c].ad, ek: ' hastaneye götürüldü' });
    }
  }
  /* --- kasa eksi kaldiysa tahliye sayaci --- */
  if (G.fpara < 0) G.fbatik = (G.fbatik || 0) + 1; else G.fbatik = 0;
  if (G.fbatik >= FP_BATIK_SINIR) olay.push({ tip: 'kotu', ek: 'Kira ödenmedi — tahliye' });
  if (haneCanli(G.hane) === 0) olay.push({ tip: 'kotu', ek: 'Evde kimse kalmadı' });

  H.olay = olay;
  G.fgun = (G.fgun || 0) + 1;
  saveAll();
}
/* Mod bitti mi? (tahliye ya da hane bosaldi) */
function fermanBitti() {
  return (G.fbatik || 0) >= FP_BATIK_SINIR || (G.hane && haneCanli(G.hane) === 0);
}

/* ---------------- DEMIRKENT: ferman kontrolleri ---------------- */
/* Bu musteri bugun yasakli mi? */
function fermanYasakMusteri(c) {
  var F = G.ferman;
  if (!F || F.kapandi) return null;
  for (var i = 0; i < F.liste.length; i++) {
    var f = F.liste[i];
    if (f.tip === 'musteri' && f.test(c)) return f;
  }
  return null;
}
/* Bu urun bugun yasakli mi? */
function fermanYasakUrun(it) {
  var F = G.ferman;
  if (!F || F.kapandi) return null;
  for (var i = 0; i < F.liste.length; i++) {
    var f = F.liste[i];
    if (f.tip === 'urun' && f.test(it)) return f;
  }
  return null;
}
/* ============================================================
   DEMIRKENT — DEVLET GOZCUSU
   Camin disinda, bizim taraftaki kaldirimda devriye gezer. Arada durup
   ICERI BAKAR. Yasak mal vermek TEK BASINA ihlal degil: gozcu o anda
   bakiyorsa yakalanirsin. Bakmiyorken mal musteriyle disari cikar; gozcu
   sokakta onu durdurup sorgularsa ihlal GEC gelir. Hic gormezse kurtulursun.
   ============================================================ */
var GOZ_BAK_SURE = [2.6, 4.4];    /* bir bakis kac saniye surer */
var GOZ_ARA = [5, 11];            /* bakislar arasi bekleme */
var GOZ_SORGU_SANS = 0.55;        /* kacak musteriyi sokakta durdurma sansi */
var GOZ_KAPI = 92;                /* bu kadar kenara yaklasinca 'cikti' sayilir */

function gozcuKur() {
  return {
    x: -24, dir: 1, state: 'yuru', t: 0,
    bekle: rnd(GOZ_ARA[0], GOZ_ARA[1]),
    bakT: 0, sorgu: null, sorguT: 0, kafa: 0
  };
}
/* Gozcu SU AN iceri bakiyor mu? Ihlalin yakalanip yakalanmadigini bu belirler. */
function gozcuBakiyor() {
  var Z = G.gozcu;
  return !!(Z && Z.state === 'bak' && Z.bakT > .35);
}
/* Kaldirimda gezinme sinirlari: camin biraz disina tasar. */
function gozcuSinir() { var M = stM(); return [M.gx - 26, M.gx + M.gw + 26]; }

function updateGozcu(dt) {
  var F = G.ferman, Z = G.gozcu;
  if (!F || F.kapandi) return;
  if (!Z) { G.gozcu = gozcuKur(); return; }
  var sn = gozcuSinir(), M = stM();
  Z.t += dt;

  if (Z.state === 'sorgu') {
    Z.sorguT += dt;
    /* 1.4 sn sorgudan sonra ceza yazilir */
    if (Z.sorguT > 1.4 && Z.sorgu && Z.sorgu.kacak && Z.sorgu.kacak.length) {
      var f0 = Z.sorgu.kacak.shift();
      fermanIhlal(f0, clamp(Z.x, 30, W - 30), M.curb2 - 40, 'sokak');
      if (!Z.sorgu.kacak.length) { Z.sorgu.yakalandi = true; }
      Z.sorguT = 0.2;
    }
    if (Z.sorguT > 1.2 && (!Z.sorgu || !Z.sorgu.kacak || !Z.sorgu.kacak.length)) {
      Z.sorgu = null; Z.state = 'yuru'; Z.bekle = rnd(GOZ_ARA[0], GOZ_ARA[1]);
    }
    return;
  }

  if (Z.state === 'bak') {
    Z.bakT += dt;
    Z.kafa = approach(Z.kafa, 1, dt * 6);
    if (Z.bakT >= Z.bakSure) {
      Z.state = 'yuru'; Z.bakT = 0;
      Z.bekle = rnd(GOZ_ARA[0], GOZ_ARA[1]);
      Z.dir = chance(.5) ? 1 : -1;
    }
    return;
  }

  /* yuruyus */
  Z.kafa = approach(Z.kafa, 0, dt * 6);
  Z.x += Z.dir * 17 * dt;
  if (Z.x < sn[0]) { Z.x = sn[0]; Z.dir = 1; }
  if (Z.x > sn[1]) { Z.x = sn[1]; Z.dir = -1; }
  Z.bekle -= dt;
  /* camin onunde ve bekleme dolduysa durup iceri bak */
  if (Z.bekle <= 0 && Z.x > M.gx + 20 && Z.x < M.gx + M.gw - 20) {
    Z.state = 'bak'; Z.bakT = 0; Z.bakSure = rnd(GOZ_BAK_SURE[0], GOZ_BAK_SURE[1]);
    SFX.ui && SFX.ui();
  }
  /* Kacak malla cikan musteriyi SOKAKTA durdur. Musteri daha tezgahtayken
     durdurmak anlamsiz goruntu veriyordu (gozcu disarida, musteri iceride):
     once kapiya varsin, sonra yakalansin. Gozcu de onun hizasina yurur. */
  if (!Z.sorgu) {
    for (var i = 0; i < G.customers.length; i++) {
      var c = G.customers[i];
      if (c.state !== 'leave' || !c.kacak || !c.kacak.length || c.sorgulandi) continue;
      if (c.x > GOZ_KAPI && c.x < W - GOZ_KAPI) continue;    /* henuz kapiya varmadi */
      c.sorgulandi = true;
      if (!chance(GOZ_SORGU_SANS)) continue;
      Z.sorgu = c; Z.state = 'sorgu'; Z.sorguT = 0;
      Z.x = clamp(c.x, sn[0], sn[1]);          /* gozcu musterinin hizasinda */
      c.state = 'sorgu'; c.sorguT = 0;
      SFX.bad();
      break;
    }
  }
}

/* Yasak mal verildi: gozcu goruyorsa aninda ihlal, gormuyorsa kacak. */
function fermanKacak(f, c, x, y) {
  var F = G.ferman;
  if (!F || F.kapandi) return false;
  if (gozcuBakiyor()) { fermanIhlal(f, x, y, 'pencere'); return true; }
  c.kacak = c.kacak || [];
  c.kacak.push(f);
  G.stats.kacak = (G.stats.kacak || 0) + 1;
  /* sessizce gecti: kucuk gri toz, ses yok */
  burst(x, y + 14, 5, ['#8a8f96', '#b0b4b8'], { spMax: 26, up: 10, sz: 1 });
  return false;
}

/* Ihlal: ceza kes, sayaci artir, sinira gelince dukkani kapat. */
function fermanIhlal(f, x, y, nerede) {
  var F = G.ferman;
  if (!F || F.kapandi) return;
  F.ceza++;
  kasaDus(FERMAN_CEZA_PARA);
  G.stat.fine = (G.stat.fine || 0) + FERMAN_CEZA_PARA;
  /* Gun sonunda tek tek dokulecek kayit: hangi ferman, nerede yakalandi. */
  F.kayit = F.kayit || [];
  F.kayit.push({ id: f && f.id, metin: f ? f.metin : '', nerede: nerede || 'pencere',
                 para: FERMAN_CEZA_PARA });
  SFX.bad(); shake(.35, 3); flash(.20, '#e2483a');
  ftext(T('FERMAN İHLALİ ') + F.ceza + '/' + FERMAN_CEZA_SINIR,
        x === undefined ? W / 2 : x, y === undefined ? 110 : y, P.bad, { sc: 1, life: 1.8 });
  if (F.ceza >= FERMAN_CEZA_SINIR) {
    F.kapandi = true;
    G.stats.muhur = (G.stats.muhur || 0) + 1;
    ftext(T('MÜFETTİŞ GELDİ — DÜKKÂN KAPANDI'), W / 2, 140, P.bad, { sc: 1, life: 2.6 });
    SFX.shutter();
    G.timeLeft = Math.min(G.timeLeft, 1.2);   /* gun burada biter */
  }
}
/* Yasakli musteriyi gonder: ceza yok, sadece satis yok. */
function fermanGonder(c) {
  c.state = 'leave'; c.leaveT = 0; c.mood = 'angry';
  c.line = pick(LINES_WRONG); c.lineT = 1.4;
  SFX.uiBack();
  ftext(T('GÖNDERİLDİ'), c.x, c.y - 58, P.ui1, { life: 1.2 });
}
/* X rozetinin kutusu: musterinin SAG YANINDA, omuz hizasinda.
   Basin ustu siparis balonuna ait, oraya konunca rozet balonun altinda
   kaliyordu. */
function fermanXKutu(c) {
  return [Math.round(c.x + 15), Math.round(c.y - 44), 14, 14];
}
/* Dürüm sarilmaya hazir mi?
   MALZEME SECIMI kapaliyken: hepsi tam olmali (eski kural).
   Acikken: et sart, digerleri ya TAM ya HIC. 'Hic konmamis' artik
   gecerli bir bitmis hal - yoksa turşusuz dürüm hic sarilamazdi. */
function wrapFull(w) {
  if (!w || w.meat < MEAT_NEED) return false;
  if (!TUN.secimOn(G)) {
    return w.pickleN >= PICKLE_NEED && w.yogurtN >= YOGURT_NEED && w.friesN >= FRIES_NEED;
  }
  var tamVeyaBos = function (n, need) { return n === 0 || n >= need; };
  return tamVeyaBos(w.pickleN || 0, PICKLE_NEED) &&
         tamVeyaBos(w.yogurtN || 0, YOGURT_NEED) &&
         tamVeyaBos(w.friesN || 0, FRIES_NEED);
}
/* Dürümde bu malzeme VAR mi (tam konmus mu)? */
function wrapVar(w, m) {
  if (m === 'pickle') return (w.pickleN || 0) >= PICKLE_NEED;
  if (m === 'yogurt') return (w.yogurtN || 0) >= YOGURT_NEED;
  if (m === 'fries') return (w.friesN || 0) >= FRIES_NEED;
  return false;
}
/* Dürüm siparise uyuyor mu: istenmeyen konmamis, istenen konmus. */
function secimUyuyor(w, ord) {
  if (!TUN.secimOn(G) || !ord) return true;
  for (var i = 0; i < SECIM_MALZEME.length; i++) {
    var m = SECIM_MALZEME[i];
    if (siparisIstemez(ord, m) !== !wrapVar(w, m)) return false;
  }
  return true;
}
/* SARILMIS DÜRÜMÜN KİMLİĞİ.
   Dürüm sarılıp kâğıda girince içi görünmez olur; tezgâhta üç tane
   yan yana durunca hangisinin turşusuz, hangisinin acı soslu olduğu
   bilinemiyordu. Kimliği belirleyen iki şey var: EKSİK malzemeler ve
   SOS. Eksik listesi yalnız Malzeme Seçimi açıkken anlamlı — kapalıyken
   zaten hepsi aynı dürüm, boş liste dönüp etiket hiç çizilmiyor. */
function wrapKimlik(w) {
  if (!w || w.kind !== 'wrap') return null;
  var d = [];
  if (TUN.secimOn(G)) {
    for (var i = 0; i < SECIM_MALZEME.length; i++) {
      var m = SECIM_MALZEME[i];
      if (!wrapVar(w, m)) d.push({ tip: 'yok', m: m });
    }
  }
  if (w.sauce) d.push({ tip: 'sos', m: w.sauce });
  return d;
}
function wrapAny(w) { return w && (w.meat > 0 || w.pickleN > 0 || w.yogurtN > 0 || w.friesN > 0); }
function wrapQuality(w) {
  if (!w) return 0;
  /* yanmis dürüm: satilabilir ama neredeyse degersiz */
  if (w.burnt) return 0.15;
  /* MALZEME SECIMI acikken BILEREK konmayan malzeme eksik sayilmaz:
     yoksa "turşusuz" siparisi hazirlayan oyuncu her seferinde
     kalite cezasi yerdi. Kasitli bosluk ile unutulmus malzemeyi
     wrapFull ayirt ediyor (ya tam ya hic). */
  var esnek = TUN.secimOn(G);
  var pay = function (n, need, agirlik) {
    if (esnek && (n || 0) === 0) return agirlik;      /* kasitli bos */
    return (Math.min(n || 0, need) / need) * agirlik;
  };
  var q = (Math.min(w.meat, MEAT_NEED) / MEAT_NEED) * .40;
  q += pay(w.pickleN, PICKLE_NEED, .16);
  q += pay(w.yogurtN, YOGURT_NEED, .16);
  q += pay(w.friesN, FRIES_NEED, .28);
  return clamp(q, 0, 1);
}
function wrapNeedsGrill(w) { return w.kind !== 'plate' && TUN.grillOn(G) && !w.grilled; }
/* ---------------- iskender tabagi ---------------- */
/* Tam iskender: döner + tereyagi + yogurt; garnitur aciksa
   BIBER ve DOMATES de sart. Eksik tabak musteriye gitmesin. */
function plateFull(p) {
  if (!p || p.meat < TUN.iskMeat(G) || !p.butter || !p.yogurt) return false;
  if (TUN.garnishOn(G)) {
    if ((p.tomato || 0) < TOMATO_NEED) return false;
    if ((p.pepper || 0) < PEPPER_NEED) return false;
  }
  return true;
}
function plateAny(p) { return p && (p.meat > 0 || p.butter || p.yogurt); }
function plateQuality(p) {
  if (!p) return 0;
  /* Garnitur aciksa biber ve domates de puana girer; kapaliysa
     eski uc bilesen tek basina %100 yapar. */
  if (!TUN.garnishOn(G)) {
    var q0 = (Math.min(p.meat, TUN.iskMeat(G)) / TUN.iskMeat(G)) * .55;
    if (p.butter) q0 += .25;
    if (p.yogurt) q0 += .20;
    return clamp(q0, 0, 1);
  }
  var q = (Math.min(p.meat, TUN.iskMeat(G)) / TUN.iskMeat(G)) * .40;
  if (p.butter) q += .18;
  if (p.yogurt) q += .17;
  q += (Math.min(p.tomato || 0, TOMATO_NEED) / TOMATO_NEED) * .13;
  q += (Math.min(p.pepper || 0, PEPPER_NEED) / PEPPER_NEED) * .12;
  return clamp(q, 0, 1);
}
function newPide(otomatik) {
  if (!TUN.iskOn(G)) { if (!otomatik) { SFX.bad(); say('İskender kapalı — dükkândan aç'); } return; }
  var n = TUN.boards(G), idx = -1;
  for (var i = 0; i < n; i++) if (!G.boards[i]) { idx = i; break; }
  if (idx < 0) { if (!otomatik) { SFX.bad(); say('Tezgâh dolu!'); } return; }
  G.boards[idx] = { kind: 'pide', n: 0, chop: 0, state: 'open', pop: 1, born: G.t };
  /* Otomatik acilan pide aktif tahtayi CALMAZ: oyuncu dürüm
     dolduruyorsa malzemeleri ona koymaya devam etsin. */
  if (!otomatik) G.act = idx;
  SFX.wrap();
  burst(boardCX(idx), boardCY(), 6, ['#f4ead2', '#ffffff'], { spMax: 34, up: 12, sz: 1 });
  if (!otomatik) say('Pideyi doğra — tahtaya tıkla');
}
function finishPlate(idx) {
  var p = G.boards[idx];
  if (!p || p.kind !== 'plate' || p.state !== 'open' || !plateFull(p)) return;
  p.state = 'ready'; p.pop = 1; p.quality = plateQuality(p);
  SFX.plate();
  burst(boardCX(idx), boardCY(), 10, ['#ffd77a', '#e2621c', '#ffffff'], { spMax: 55, up: 18 });
}
function newWrap() {
  var n = TUN.boards(G), idx = -1;
  for (var i = 0; i < n; i++) if (!G.boards[i]) { idx = i; break; }
  if (idx < 0) { SFX.bad(); say('Tezgâh dolu!'); return; }
  G.boards[idx] = {
    kind: 'wrap', meat: 0, friesN: 0, pickleN: 0, yogurtN: 0,
    grilled: false, paper: false, state: 'open', pop: 1, roll: 0, born: G.t
  };
  G.act = idx;
  SFX.wrap();
  say('Yeni lavaş — malzemeler buna gidiyor');
}
/* Aktif tahtada O MALZEME icin yer yoksa yer olan tahtaya kendiliginden
   gecer: oyuncu dolu duruma tiklayip "yeterli" uyarisi almak yerine
   yanindaki bos duruma doldurabilsin. Hicbirinde yer yoksa eskisi gibi
   acik bir durum doner ki dogru uyari mesaji ciksin. */
function activeWrap(yerVar) {
  var n = TUN.boards(G);
  function acik(b) { return !!b && b.state === 'open'; }
  function uygun(b) { return acik(b) && (!yerVar || yerVar(b)); }
  var w = G.boards[G.act];
  if (uygun(w)) return w;

  /* Etkin tahta dolu -> AYNI TURDEN baska bir tahtaya gec.
     Farkli ture (durum <-> iskender tabagi) kendiliginden atlamak,
     oyuncunun doldurmak istemedigi urune malzeme koyuyordu. */
  var tur = acik(w) ? w.kind : null;
  var best = null, bi = -1;
  for (var i = 0; i < n; i++) {
    var b = G.boards[i];
    if (!uygun(b)) continue;
    if (tur && b.kind !== tur) continue;
    if (!best || b.born > best.born) { best = b; bi = i; }
  }
  if (best) { G.act = bi; return best; }

  /* Etkin tahta yoksa (kapali ya da bos) tur ayrimi yapmaya gerek yok. */
  if (!tur) {
    for (var j = 0; j < n; j++) {
      if (uygun(G.boards[j])) { G.act = j; return G.boards[j]; }
    }
  }
  /* Ayni turden yer kalmadi: etkin tahtayi dondur, cagiran 'yeterli' desin.
     Sessizce baska urune doldurmaktan iyidir. */
  if (acik(w)) return w;
  for (var k = 0; k < n; k++) if (acik(G.boards[k])) { G.act = k; return G.boards[k]; }
  return null;
}
function selWrap(yerVar) { return activeWrap(yerVar); }
/* malzeme bazli "yer var mi" testleri */
function yerEt(b) {
  if (b.kind === 'pide') return false;
  return b.meat < (b.kind === 'plate' ? TUN.iskMeat(G) : MEAT_NEED);
}
function yerIng(k) {
  return function (b) {
    if (b.kind === 'pide') return false;
    if (b.kind === 'plate') return k === 'yogurt' && (b.yogurtN || 0) < PLATE_YOGURT;
    if (k === 'fries') return b.friesN < FRIES_NEED;
    if (k === 'pickle') return b.pickleN < PICKLE_NEED;
    if (k === 'yogurt') return b.yogurtN < YOGURT_NEED;
    return true;
  };
}
function boardCX(i) { var n = TUN.boards(G); return Math.round(ST.board.x + 4 + (ST.board.w - 8) / n * (i + .5)); }
function boardCY() { return ST.board.y + 25; }
function addMeat() {
  var w = selWrap(yerEt);
  if (!w) { SFX.bad(); say(TUN.iskOn(G) ? 'Önce lavaş ya da pide al!' : 'Önce lavaş al!'); return; }
  if (w.state !== 'open') { SFX.bad(); return; }
  if (w.kind === 'pide') { SFX.bad(); say('Önce pideyi doğra'); return; }
  var need = w.kind === 'plate' ? TUN.iskMeat(G) : MEAT_NEED;
  if (w.meat >= need) { SFX.bad(); say('Et yeterli'); return; }
  if (G.meat <= 0) { SFX.bad(); say('Et yok — dönerden kes!'); return; }
  var n = Math.min(TUN.meatPerClick(G), need - w.meat, G.meat);
  G.meat -= n; w.meat += n; w.pop = 1; G.fxTray.meat = 1;
  flyTo(ST.meat.x + ST.meat.w / 2, ST.meat.y + 8, boardCX(G.act), boardCY(), '#c98436', 5);
  SFX.pop();
  checkAuto();
}
function addIng(k) {
  var w = selWrap(yerIng(k));
  if (!w) { SFX.bad(); say(TUN.iskOn(G) ? 'Önce lavaş ya da pide al!' : 'Önce lavaş al!'); return; }
  if (w.state !== 'open') { SFX.bad(); return; }
  if (w.kind === 'pide') { SFX.bad(); say('Önce pideyi doğra'); return; }
  if (w.kind === 'plate') {
    if (k !== 'yogurt') { SFX.bad(); say('İskendere sadece yoğurt gider'); return; }
    if ((w.yogurtN || 0) >= PLATE_YOGURT) { SFX.bad(); say('Yoğurt yeterli'); return; }
    if (G.stock.yogurt <= 0) { SFX.bad(); say('Yoğurt bitti — kutudan doldur!'); return; }
    var pn = Math.min(TUN.meatPerClick(G), PLATE_YOGURT - (w.yogurtN || 0), G.stock.yogurt);
    G.stock.yogurt -= pn; w.yogurtN = (w.yogurtN || 0) + pn;
    w.yogurt = w.yogurtN >= PLATE_YOGURT;
    G.fxTray.yogurt = 1; SFX.scoop();
    flyTo(ST.yogurt.x + 19, ST.yogurt.y + 10, boardCX(G.act), boardCY(), P.s0, 6);
    w.pop = 1; SFX.pop();
    finishPlate(G.act);
    return;
  }
  if (k === 'fries') {
    if (w.friesN >= FRIES_NEED) { SFX.bad(); say('Patates yeterli'); return; }
    if (G.friesTray <= 0) { SFX.bad(); say('Patates yok — doğra ve kızart!'); return; }
    var fn = Math.min(TUN.meatPerClick(G), FRIES_NEED - w.friesN, G.friesTray);
    G.friesTray -= fn; w.friesN += fn; G.fxTray.fries = 1;
    flyTo(ST.friesT.x + 19, ST.friesT.y + 10, boardCX(G.act), boardCY(), P.p1, 6);
    w.pop = 1; SFX.pop(); checkAuto();
    return;
  } else {
    var need = k === 'pickle' ? PICKLE_NEED : YOGURT_NEED;
    var key = k + 'N';
    /* Birlestirilen her parca AYRI AYRI cevrilmeli: birlesmis sonuc sozlukte yok. */
    if ((w[key] || 0) >= need) { SFX.bad(); say(T(k === 'pickle' ? 'Turşu' : 'Yoğurt') + T(' yeterli')); return; }
    if (G.stock[k] <= 0) { SFX.bad(); say(T(k === 'pickle' ? 'Turşu' : 'Yoğurt') + T(' bitti — kutudan doldur!')); return; }
    var an = Math.min(TUN.meatPerClick(G), need - (w[key] || 0), G.stock[k]);
    G.stock[k] -= an; w[key] = (w[key] || 0) + an;
    G.fxTray[k] = 1;
    SFX.scoop();
    var src = k === 'pickle' ? ST.pickle : ST.yogurt;
    flyTo(src.x + 19, src.y + 10, boardCX(G.act), boardCY(), k === 'pickle' ? P.g1 : P.s0, 6);
  }
  w.pop = 1;
  SFX.pop();
  checkAuto();
}
function flyTo(x0, y0, x1, y1, col, n) {
  for (var i = 0; i < n; i++) {
    part({
      x: x0 + rnd(-3, 3), y: y0, vx: (x1 - x0) * rnd(1.5, 2.1), vy: (y1 - y0) * 1.7 - rnd(30, 60),
      life: .4, col: col, g: 200, sz: 2
    });
  }
}

/* ---------------- garnitür: domates & biber ---------------- */
function garnishClick(mx) {
  if (!TUN.garnishOn(G)) { SFX.bad(); say('Garnitür tepsisi kapalı — dükkândan al'); return; }
  var isTom = mx < ST.garnish.x + ST.garnish.w * .52;
  var k = isTom ? 'tomato' : 'pepper';
  /* garnitür isteğe bağlı: tabak hazır olsa bile eklenebilir */
  var w = null, wi = -1;
  var act = G.boards[G.act];
  if (act && act.kind === 'plate') { w = act; wi = G.act; }
  else {
    for (var bi = 0; bi < TUN.boards(G); bi++) {
      var b0 = G.boards[bi];
      if (b0 && b0.kind === 'plate' && (!w || b0.born > w.born)) { w = b0; wi = bi; }
    }
  }
  if (!w) { SFX.bad(); say('Garnitür iskender tabağına gider'); return; }
  G.act = wi;
  var need = isTom ? TOMATO_NEED : PEPPER_NEED;
  if ((w[k] || 0) >= need) { SFX.bad(); say(isTom ? 'Domates yeterli' : 'Biber yeterli'); return; }
  if (G.stock[k] <= 0) { SFX.bad(); say(T(isTom ? 'Domates' : 'Biber') + T(' bitti — kutudan doldur!')); return; }
  var n = Math.min(TUN.meatPerClick(G), need - (w[k] || 0), G.stock[k]);
  G.stock[k] -= n; w[k] = (w[k] || 0) + n;
  G.fxTray[k] = 1; w.pop = 1;
  SFX.scoop(); SFX.pop();
  var sx = ST.garnish.x + (isTom ? 10 : ST.garnish.w - 10);
  flyTo(sx, ST.garnish.y + 12, boardCX(G.act), boardCY(), isTom ? '#e2483a' : '#5d9a24', 6);
  say(isTom ? 'Domates kondu' : 'Biber kondu');
}

/* ---------------- pide dograma ---------------- */
function pideChop(idx, otomatik) {
  var p = G.boards[idx];
  if (!p || p.kind !== 'pide') return false;
  p.n = (p.n || 0) + 1;
  p.chop = 1;
  SFX.potato();
  shake(1.2);
  var bx = boardCX(idx), by = boardCY();
  for (var i = 0; i < 7; i++) {
    part({
      x: bx + rnd(-18, 18), y: by - 2, vx: rnd(-46, 46), vy: rnd(-46, -14),
      life: rnd(.35, .65), col: pick(['#eec78c', '#d9a765', '#8a5f31', '#f4ead2']), g: 280, sz: 1,
      floor: by + 6, bounce: .3
    });
  }
  if (p.n >= PIDE_NEED) {
    /* doğrandı: tabağa geç */
    G.boards[idx] = {
      kind: 'plate', pide: true, meat: 0, butter: false, yogurt: false, yogurtN: 0,
      tomato: 0, pepper: 0, state: 'open', pop: 1, born: G.t
    };
    /* Otomatik dogranan pide aktif tahtayi CALMAZ: oyuncu dürüm
       dolduruyorsa malzemeleri ona koymaya devam etsin. */
    if (!otomatik) G.act = idx;
    SFX.plate();
    burst(bx, by, 14, ['#d9a765', '#eec78c', '#ffffff', '#e9eef2'], { spMax: 62, up: 24, sz: 2 });
    ftext('PİDE HAZIR', bx, by - 26, P.au0, { life: 1.2 });
    if (!otomatik) say('Tabağa geçti — şimdi döner koy');
  }
  return true;
}

/* ---------------- sos standı ---------------- */
var SAUCE_IDX = { hot: 0, garlic: 1, butter: 2 };
function sauceIdxAt(mx) { return clamp(Math.floor((mx - ST.sauce.x - 2) / 15), 0, 2); }
function sauceOpen(i) { return i === 2 ? TUN.iskOn(G) : TUN.sauceOn(G); }
function squirt(id, x, y) {
  var cols = id === 'hot' ? ['#e2382a', '#ff7a62', '#a81f18']
    : (id === 'garlic' ? ['#f6f2e6', '#ffffff', '#d8d2c2'] : ['#f0b53c', '#ffd77a', '#e2621c']);
  var sx = sauceSlotX(SAUCE_IDX[id]) + 3, sy = ST.sauce.y + 22;
  for (var i = 0; i < 11; i++) {
    part({
      x: sx + rnd(-1, 1), y: sy, vx: (x - sx) * rnd(1.4, 2.0), vy: (y - sy) * 1.6 - rnd(24, 56),
      life: .45, col: pick(cols), g: 220, sz: 1
    });
  }
}
function sauceClick(mx) {
  var i = sauceIdxAt(mx), id = SAUCE_DEF[i].id;
  if (!sauceOpen(i)) {
    SFX.bad();
    say(i === 2 ? 'Tereyağı sosu İskender ile gelir' : 'Sos standı kapalı — dükkândan aç');
    return;
  }
  var w = selWrap();
  /* Sos sv2: sarilmis (henuz kagitlanmamis) dürüme de sos surulebilir.
     "Sardim ama sosu unuttum" durumunda dürüm cope gitmesin diye.
     Karar yine oyuncunun; oyun kendi kafasina sos surmez. */
  if (!w && TUN.sauceLate(G)) {
    for (var sb = 0; sb < TUN.boards(G); sb++) {
      var sw = G.boards[sb];
      if (sw && sw.kind === 'wrap' && sw.state === 'rolled' && !sw.sauce) { w = sw; G.act = sb; break; }
    }
  }
  if (!w) { SFX.bad(); say('Önce lavaş ya da pide al!'); return; }
  var sarili = (w.state === 'rolled' && TUN.sauceLate(G) && w.kind === 'wrap');
  if (w.state !== 'open' && !sarili) { SFX.bad(); return; }
  if (w.kind === 'pide') { SFX.bad(); say('Önce pideyi doğra'); return; }
  if (id === 'butter') {
    if (w.kind !== 'plate') { SFX.bad(); say('Tereyağı sosu iskendere gider'); return; }
    if (w.butter) { SFX.bad(); say('Sos zaten döküldü'); return; }
    w.butter = true;
    say('Tereyağı sosu döküldü');
  } else {
    if (w.kind === 'plate') { SFX.bad(); say('Tabağa dürüm sosu sürülmez'); return; }
    if (w.sauce === id) { SFX.bad(); say('Sos zaten sürüldü'); return; }
    w.sauce = id;
    say(id === 'hot' ? 'Acı sos sürüldü' : 'Sarımsak sosu sürüldü');
  }
  w.pop = 1;
  G.sauceFx[id] = 1;
  SFX.squirt();
  squirt(id, boardCX(G.act), boardCY());
  if (w.kind === 'plate') finishPlate(G.act);
  checkAuto();
}
function updateSauce(dt) {
  var k = ['hot', 'garlic', 'butter'];
  for (var i = 0; i < 3; i++) if (G.sauceFx[k[i]] > 0) G.sauceFx[k[i]] = Math.max(0, G.sauceFx[k[i]] - dt * 3.6);
}
/* NOT: wantedSauce kaldirildi. Otomatik sos yok; hangi sosun
   surulecegine oyuncu karar verir. */

/* ---------------- ızgara ---------------- */
/* Slot yerlesimi: en fazla 4 dürüm, 2x2. Tek satira sigmazlar. */
function grillSlotX(i) {
  var cap = TUN.grillCap(G);
  var sut = cap <= 2 ? cap : 2;                 /* 1-2 dürüm tek sutun degil, yan yana */
  var k = i % sut;
  var gen = ST.grill.w - 8;
  return Math.round(ST.grill.x + 4 + gen / sut * (k + .5));
}
function grillSlotY(i) {
  var cap = TUN.grillCap(G);
  var satir = cap <= 2 ? 1 : 2;
  var r = satir === 1 ? 0 : Math.floor(i / 2);
  return Math.round(ST.grill.y + (satir === 1 ? 23 : 15 + r * 16));
}
/* Dürüm sanati 40px genis. Tek sirada bol yer var, iki sutunda dar. */
function grillSlotSc() {
  var cap = TUN.grillCap(G);
  return cap === 1 ? .80 : (cap === 2 ? .62 : .58);
}
/* Izgarada bos yer var mi */
function grillDolu() { return G.grill.slots.length >= TUN.grillCap(G); }
/* Alinmaya hazir (pismis) ilk slot; yoksa -1 */
function grillHazirIdx() {
  var sl = G.grill.slots;
  for (var i = 0; i < sl.length; i++) if (sl[i].done) return i;
  return -1;
}
function grillClick() {
  if (!TUN.grillOn(G)) { SFX.bad(); say('Izgara kapalı — dükkândan aç'); return; }
  /* Pismis dürüm varsa once onu al — AMA inecek yer yoksa vazgecme:
     izgarada bos slot ve bekleyen sarili dürüm varsa onu koy.
     Eskiden burada return ediliyordu ve ikinci dürüm hic konamiyordu. */
  var hi = grillHazirIdx();
  if (hi >= 0 && grillBosYer() >= 0) { grillTakeOut(hi); return; }
  /* yer varsa sarili dürüm koy */
  if (!grillDolu()) {
    var wi = -1;
    for (var i = 0; i < TUN.boards(G); i++) {
      var b = G.boards[i];
      if (b && b.kind === 'wrap' && b.state === 'rolled' && !b.grilled) { wi = i; break; }
    }
    if (wi >= 0) { grillPut(wi); return; }
    if (hi >= 0) { grillTakeOut(hi); return; }   /* yer yok mesajini o versin */
    SFX.bad(); say('Önce dürümü sar — ızgaraya sarılmış dürüm girer');
    return;
  }
  if (hi >= 0) { grillTakeOut(hi); return; }
  say('Daha pişiyor…');
}
/* Tezgahta ilk bos tahta; yoksa -1. */
function grillBosYer() {
  for (var i = 0; i < TUN.boards(G); i++) if (!G.boards[i]) return i;
  return -1;
}
/* Izgara TIKALI: PISMIS bir dürüm var ama tezgahta inecek yer yok.
   Slotlarin tamaminin dolu olmasi gerekmez — tek pismis dürüm bile
   inemiyorsa sistem tikanir. */
function grillTikali() {
  return grillHazirIdx() >= 0 && grillBosYer() < 0;
}
function grillPut(idx) {
  var w = G.boards[idx];
  if (kesintiVarMi()) { SFX.bad(); say('Elektrik yok — ızgara soğuk'); return; }
  if (!w || grillDolu()) return;
  G.boards[idx] = null;
  G.grill.slots.push({ w: w, t: 0, dur: TUN.grillTime(G), done: false, yan: 0 });
  SFX.sizzle();
}
function grillTakeOut(si) {
  var sl = G.grill.slots;
  if (si === undefined) si = grillHazirIdx();
  if (si < 0 || si >= sl.length) return;
  var w = sl[si].w;
  var idx = grillBosYer();
  if (idx < 0) {
    /* TAKAS: bos tahta yok ama tahtada izgara bekleyen sarili dürüm
       varsa yer degistir — pisen iner, bekleyen girer. Izgara zorunlu
       oldugu icin kizarmamis dürüm kagitlanamaz; takas olmasa dükkan
       kilitlenirdi. */
    var ti = -1;
    for (var tb = 0; tb < TUN.boards(G); tb++) {
      var tw = G.boards[tb];
      if (tw && tw.kind === 'wrap' && tw.state === 'rolled' && !tw.grilled) { ti = tb; break; }
    }
    if (ti >= 0) {
      var bekleyen = G.boards[ti];
      w.grilled = true; w.kizarma = 1; w.pop = 1;
      G.boards[ti] = w;
      sl[si].w = bekleyen; sl[si].t = 0; sl[si].dur = TUN.grillTime(G);
      sl[si].done = false; sl[si].yan = 0;
      SFX.sizzle(); SFX.pick();
      burst(grillSlotX(si), grillSlotY(si), 8, ['#ffe9c0', '#ffd257', '#ffffff'], { spMax: 50, up: 20 });
      checkAuto();
      return;
    }
    SFX.bad();
    say(TUN.autoPaper(G) ? 'Tezgâh dolu — bir dürümü servis et'
                         : 'Tezgâh dolu — bir dürümü kâğıtlayıp ver');
    return;
  }
  w.grilled = true; w.kizarma = 1; w.pop = 1;
  G.boards[idx] = w;
  sl.splice(si, 1);
  SFX.pick();
  var gx0 = grillSlotX(si), gy0 = grillSlotY(si);
  if (w.burnt) {
    ftext('YANDI!', gx0, gy0 - 16, P.bad, { life: 1.3 });
    SFX.bad();
    burst(gx0, gy0, 8, ['#3a2a1e', '#6b4a2a', '#1a1210'], { spMax: 46, up: 18 });
  } else {
    burst(gx0, gy0, 8, ['#ffe9c0', '#ffd257', '#ffffff'], { spMax: 50, up: 20 });
    for (var s2 = 0; s2 < 5; s2++) {
      part({ x: gx0 + rnd(-10, 10), y: gy0 - 6, vx: rnd(-6, 6), vy: rnd(-24, -12), life: .9, col: 'rgba(240,235,225,.5)', g: -10, sz: 1 });
    }
  }
  checkAuto();
}
function updateGrill(dt) {
  var sl = G.grill.slots;
  if (!sl.length) return;
  /* Elektrik yoksa izgara DURUR: pisirme de yanma da ilerlemez.
     Uzerindeki dürüm kaybolmaz, sadece bekler. */
  if (kesintiVarMi()) return;
  var yanar = TUN.grillYanar(G), yanSure = TUN.grillYanmaSure(G);
  var cizirti = false;
  for (var i = 0; i < sl.length; i++) {
    var s = sl[i];
    s.t += dt;
    /* kizarma ilerlemesi: dürüm izgaradayken YAVAS YAVAS kararir */
    s.w.kizarma = clamp(s.t / Math.max(.001, s.dur), 0, 1);
    if (s.t < s.dur) {
      cizirti = true;
      if (chance(dt * 5)) part({
        x: grillSlotX(i) + rnd(-8, 8), y: grillSlotY(i) - 4,
        vx: rnd(-5, 5), vy: rnd(-22, -10), life: .8, col: 'rgba(240,232,220,.42)', g: -12, sz: 1
      });
    } else {
      if (!s.done) { s.done = true; SFX.ding(); }
      /* YANMA: yalniz sv1-2. Unutursan dürüm kömür olur. */
      if (yanar && yanSure > 0 && !s.w.burnt) {
        s.yan = clamp(s.yan + dt / yanSure, 0, 1);
        if (chance(dt * (2 + s.yan * 10))) part({
          x: grillSlotX(i) + rnd(-7, 7), y: grillSlotY(i) - 4,
          vx: rnd(-4, 4), vy: rnd(-20, -8), life: 1.1,
          col: s.yan > .6 ? 'rgba(60,50,44,.55)' : 'rgba(150,140,130,.45)', g: -14, sz: 1
        });
        if (s.yan >= 1) {
          s.w.burnt = true; s.w.kizarma = 1;
          G.stats.yanik = (G.stats.yanik || 0) + 1;
          SFX.bad(); shake(1.6);
          ftext('YANIYOR!', grillSlotX(i), grillSlotY(i) - 18, P.bad, { life: 1.4 });
        }
      }
    }
  }
  if (cizirti) {
    G.grill.sz = (G.grill.sz || 0) + dt;
    if (G.grill.sz > .9) { G.grill.sz = 0; SFX.sizzle(); }
  }
  /* otomatik alma: yer acilana kadar SESSIZCE bekler */
  if (TUN.autoGrill(G)) {
    var hi = grillHazirIdx();
    if (hi >= 0 && grillBosYer() >= 0) grillTakeOut(hi);
  }
}

/* ---------------- sarma & kağıt (sürükleme) ---------------- */
function boardAt(mx, my) {
  if (!inRect(mx, my, ST.board.x, ST.board.y, ST.board.w, ST.board.h)) return -1;
  var n = TUN.boards(G);
  return clamp(Math.floor((mx - ST.board.x - 4) / ((ST.board.w - 8) / n)), 0, n - 1);
}
/* elindeki ürünü kaynağına geri koy (takas için) */
function returnItem(it) {
  if (!it) return true;
  if (it.kind === 'drink') {
    var v = G.cups[it.type];
    if (!v) { G.cups[it.type] = it; return true; }
    /* Ayni turden iki bardak: eskiden el bosalmiyor, oyuncu bardagi
       yalnizca cope atabiliyordu. Artik DOLU olan yerinde kalir,
       digeri makineye geri doner — ikisi de ayni icecek. */
    if ((it.fill || 0) > (v.fill || 0)) G.cups[it.type] = it;
    return true;
  }
  if (it.kind === 'fbox') {
    if (G.fbox.ready >= 3) return false;
    G.fbox.ready++; return true;
  }
  if (it.kind === 'sweet') {
    if (G.stock.sweet >= TUN.sweetMax(G)) return false;
    G.stock.sweet++; return true;
  }
  if (it.kind === 'wrap' || it.kind === 'plate') {
    for (var i = 0; i < TUN.boards(G); i++) if (!G.boards[i]) { G.boards[i] = it; return true; }
    return false;
  }
  return false;
}
function updateDrag(dt) {
  var d = G.drag;
  /* sürükleme başlat */
  if (IN.pressed && !d) {
    if (testHit(IN.x, IN.y)) return false;
    var bi = boardAt(IN.downX, IN.downY);
    if (bi >= 0) {
      var w = G.boards[bi];
      if (w && w.kind !== 'plate' && w.state === 'open' && wrapAny(w)) {
        G.drag = d = { type: 'roll', idx: bi, x0: IN.downX, y0: IN.downY, moved: 0 };
      }
    }
    /* ET DILIMI -> KEDI. Yalniz kedi beklerken baslar; baska zaman
       et tepsisi normal calisir. Kedinin ustunde birakilmazsa da
       tiklama bosa gitmez, asagida addMeat() devreye giriyor. */
    if (!d && G.kedi && (G.kedi.faz === 'bekle' || G.kedi.faz === 'gelis') &&
        G.meat > 0 && inRect(IN.downX, IN.downY, ST.meat.x, ST.meat.y, ST.meat.w, ST.meat.h)) {
      G.drag = d = { type: 'et', x: IN.x, y: IN.y, moved: 0 };
      SFX.pick();
    }
    if (!d && UV(G, 'paper') === 0 && inRect(IN.downX, IN.downY, ST.paper.x, ST.paper.y, ST.paper.w, ST.paper.h)) {
      G.drag = d = { type: 'paper', x: IN.x, y: IN.y, moved: 0 };
      SFX.pick();
    }
    /* BOS KUTU: patates tepsisine surukleyip doldurulur.
       Oto kutu acikken kutu kendi ucuyor, elle surukleme gerekmez. */
    /* HAZIR kutu varken surukleme BASLAMAZ: surukleme tiklamayi
       yutuyor, oyuncu dolu kutuyu eline alamiyordu. Once alinir,
       tezgah bosalinca yeni kutu suruklenir. */
    if (!d && TUN.fboxOn(G) && !TUN.autoBox(G) && G.fbox.ready === 0 &&
        G.fbox.busy === 0 && !G.fbox.fly &&
        inRect(IN.downX, IN.downY, ST.fbox.x, ST.fbox.y, ST.fbox.w, ST.fbox.h)) {
      G.drag = d = { type: 'fbox', x: IN.x, y: IN.y, moved: 0 };
      SFX.pick();
    }
    if (d && !IN.released) return true;
  }
  if (!d) return false;
  /* sürüklerken */
  if (d.type === 'roll') {
    var w2 = G.boards[d.idx];
    if (!w2 || w2.state !== 'open') { G.drag = null; return false; }
    var dy = d.y0 - IN.y;           /* yukarı sürükleme = pozitif */
    d.moved = Math.max(d.moved, Math.abs(dy));
    w2.roll = clamp(dy / 26, 0, 1);
    if (w2.roll > 0 && chance(dt * 8)) part({ x: boardCX(d.idx) + rnd(-14, 14), y: boardCY() - 4, vx: rnd(-8, 8), vy: rnd(-20, -6), life: .35, col: '#f0d5a8', g: 120, sz: 1 });
    if (w2.roll >= 1) { finishRoll(d.idx); G.drag = null; }
  } else if (d.type === 'paper' || d.type === 'fbox' || d.type === 'et') {
    d.x = IN.x; d.y = IN.y;
    d.moved += 1;
  }
  /* bırakınca */
  if (IN.released) {
    if (d.type === 'et') {
      /* Kedinin uzerinde mi birakildi? */
      if (kediHit(IN.x, IN.y)) kediBesle();
      else if (d.moved < 4) addMeat();      /* surukleme degil, tiklama */
      else { SFX.uiBack(); say('Eti kedinin üstüne bırak'); }
      G.drag = null;
      return true;
    }
    if (d.type === 'paper') {
      var bi2 = boardAt(IN.x, IN.y);
      var w3 = bi2 >= 0 ? G.boards[bi2] : null;
      if (w3 && w3.state === 'rolled' && w3.burnt) {
        SFX.bad(); say('Yanmış dürüm satılmaz — çöpe at');
      } else if (w3 && w3.state === 'rolled' && TUN.grillOn(G) && !w3.grilled && !grillTikali()) {
        SFX.bad(); say('Önce ızgaraya at — kâğıt sonra');
      } else if (w3 && w3.state === 'rolled') applyPaper(bi2);
      else { SFX.uiBack(); say('Kağıdı sarılmış dürümün üstüne bırak'); }
    } else if (d.type === 'fbox') {
      if (inRect(IN.x, IN.y, ST.friesT.x - 4, ST.friesT.y - 6, ST.friesT.w + 8, ST.friesT.h + 12)) {
        fboxDoldur(false);
      } else { SFX.uiBack(); say('Kutuyu patates tepsisine bırak'); }
    } else if (d.type === 'roll') {
      var w4 = G.boards[d.idx];
      if (w4 && w4.state === 'open') {
        w4.roll = 0;
        if (d.moved < 4) SFX.ui();
        else say('Sarmak için yukarı doğru sürükle');
      }
    }
    G.drag = null;
  }
  return true;
}
function finishRoll(idx) {
  var w = G.boards[idx];
  if (!w) return;
  w.state = 'rolled'; w.roll = 1; w.pop = 1;
  w.quality = wrapQuality(w);
  SFX.roll();
  burst(boardCX(idx), boardCY(), 7, ['#f0d5a8', '#f8e6c4'], { spMax: 45, up: 16 });
  checkAuto();
}
function applyPaper(idx) {
  var w = G.boards[idx];
  if (!w || w.state !== 'rolled') return;
  w.paper = true; w.state = 'ready'; w.pop = 1; w.paperT = 1;
  burst(boardCX(idx), boardCY(), 9, ['#fdfaf0', '#ffffff'], { spMax: 50, up: 15 });
  SFX.crinkle();
}
/* Kagit hedefi: ONCE izgaradan gecmis durum. Izgara aciksa kizarmamis
   duruma kagit sarmak onu satilamaz hale getiriyordu (kagitliyken izgaraya
   giremiyor, izgarasiz da servis edilemiyor) -> engellenir. Izgara
   TIKALIYKEN serbest, yoksa kilitlenme olur. */
function paperHedef(sessiz) {
  var n = TUN.boards(G), duz = -1, kizarmis = -1, yanmis = -1;
  for (var i = 0; i < n; i++) {
    var w = G.boards[i];
    if (!w || w.state !== 'rolled') continue;
    if (w.burnt) { if (yanmis < 0) yanmis = i; continue; }
    if (w.grilled) { if (kizarmis < 0) kizarmis = i; }
    else if (duz < 0) duz = i;
  }
  if (kizarmis >= 0) return kizarmis;
  if (duz >= 0) {
    if (TUN.grillOn(G) && !grillTikali()) {
      if (!sessiz) { SFX.bad(); say('Önce ızgaraya at — kâğıt sonra'); }
      return -1;
    }
    return duz;
  }
  if (yanmis >= 0) {
    if (!sessiz) { SFX.bad(); say('Yanmış dürüm satılmaz — çöpe at'); }
    return -1;
  }
  if (!sessiz) { SFX.bad(); say('Önce dürümü sar'); }
  return -1;
}
function paperClick() {
  if (UV(G, 'paper') === 0) { say('Kağıdı tutup dürümün üstüne sürükle'); return; }
  var idx = paperHedef();
  if (idx < 0) return;
  if (G.paper.busy > 0) { SFX.bad(); return; }
  startPaper(idx);
}
function startPaper(idx) {
  G.paper.busy = 1; G.paper.dur = TUN.paperTime(G); G.paper.idx = idx;
  SFX.pick();
}
function updatePaper(dt) {
  var p = G.paper;
  if (p.busy > 0) {
    p.busy -= dt / p.dur;
    if (p.busy <= 0) {
      p.busy = 0;
      applyPaper(p.idx);
    }
  }
}

/* ---------------- patates: doğrama ---------------- */
function potatoTake() {
  if (G.cut.potato || G.flyP) { SFX.bad(); say('Tahtada patates var'); return; }
  G.flyP = { t: 0, x0: ST.potato.x + 14, y0: ST.potato.y + 8, x1: ST.cut.x + ST.cut.w / 2 - 6, y1: ST.cut.y + 19 };
  SFX.sack();
  burst(ST.potato.x + 14, ST.potato.y + 8, 4, ['#b98b46', '#d8ab63'], { spMax: 30, up: 12 });
}
/* Bir bıçak darbesi: ekranda görünen şey slash izidir, bıçağın
   kendisi çizilmez — hızlı hareket zaten görünmezdir. */
function slashAt() {
  var c = G.cut;
  if (!c.slash) c.slash = [];
  /* sinir asagida, iki iz birden eklenebildigi icin sonda kirpiliyor */
  var mx = ST.cut.x + ST.cut.w / 2 - 6;
  /* Her darbe bir öncekinin TERSİ yönde: sağ-sol-sağ çapraz.
     Hep aynı yöne çıkınca tek düze ve cansız görünüyordu. */
  c.yon = (c.yon === 1) ? -1 : 1;
  var taban = c.yon > 0 ? -0.72 : -2.42;       /* ↘ ve ↙ */
  c.slash.push({
    x: mx + rnd(-6, 8),
    y: ST.cut.y + 18 + rnd(-3, 3),
    aci: taban + rnd(-0.26, 0.26),
    boy: rnd(24, 34),
    t: 1
  });
  /* her üçüncü darbede ikinci bir ters iz: çapraz kesişme */
  c.sayac = (c.sayac || 0) + 1;
  if (c.sayac % 3 === 0) {
    c.slash.push({
      x: mx + rnd(-4, 6),
      y: ST.cut.y + 18 + rnd(-2, 2),
      aci: (c.yon > 0 ? -2.42 : -0.72) + rnd(-0.2, 0.2),
      boy: rnd(20, 28),
      t: 0.88
    });
  }
  /* Ekranda en fazla 8 iz: her uctuncu darbede iki iz eklendigi icin
     sinir tek yerde, eklemeler bittikten SONRA uygulanir. */
  while (c.slash.length > 8) c.slash.shift();
  shake(.10, 1);
  SFX.potato();
  /* uçuşan kabuk ve talaş */
  for (var i = 0; i < 4; i++) {
    part({
      x: mx + rnd(-4, 8), y: ST.cut.y + 17,
      vx: rnd(-46, 46), vy: rnd(-58, -20),
      life: rnd(.28, .5), col: pick(['#f2e0a8', '#ffe9a3', '#dba53a', '#b98b46']),
      g: 320, sz: 1, floor: ST.cut.y + 25, bounce: .2
    });
  }
}

function cutClick() {
  var c = G.cut;
  if (!c.potato) { SFX.bad(); say('Önce çuvaldan patates al'); return; }
  c.cutting = true; c.hold = .25;
  slashAt();
}
function updateCut(dt) {
  var c = G.cut;
  if (c.hold > 0) c.hold -= dt; else c.cutting = false;

  /* slash izleri hızla söner */
  if (c.slash) {
    for (var si = c.slash.length - 1; si >= 0; si--) {
      c.slash[si].t -= dt * 6.5;
      if (c.slash[si].t <= 0) c.slash.splice(si, 1);
    }
  }

  if (IN.down && hitST('cut') && c.potato) {
    c.cutting = true; c.hold = .12;
    c.chopT = (c.chopT || 0) - dt;
    if (c.chopT <= 0) { c.chopT = .17; slashAt(); }
  }
  if (c.potato && c.cutting) {
    c.prog += dt / TUN.cutTime(G);
    if (c.prog >= 1) {
      c.prog = 0; c.potato = false; c.cutting = false;
      c.raw += TUN.cutYield(G);
      /* kabuklar çöpe: her patates biraz doldurur */
      addTrash(TRASH_PER_PEEL);
      copaAt(ST.cut.x + ST.cut.w / 2, ST.cut.y + 16, ['#b98b46', '#8a6432', '#d8ab63']);
      SFX.drop();
      burst(ST.cut.x + ST.cut.w - 10, ST.cut.y + 26, 8, ['#f2e0a8', '#ffe9a3'], { spMax: 50, up: 20 });
      checkAuto();
    }
  }
  if (TUN.autoCut(G)) {
    c.autoT += dt;
    if (c.autoT > .35) {
      c.autoT = 0;
      if (!c.potato && c.raw < TUN.fryCap(G) * 2) { c.potato = true; c.prog = 0; SFX.sack(); }
      else if (c.potato) { c.cutting = true; c.hold = .2; slashAt(); }
    }
  }
}

/* ---------------- fritöz ---------------- */
function fryerClick() {
  var f = G.fryer;
  if (kesintiVarMi() && f.state !== 'done') {
    SFX.bad(); say('Elektrik yok — fritöz çalışmıyor'); return;
  }
  if (f.state === 'done') { fryTake(); return; }
  if (f.state === 'fry') { say('Kızarıyor…'); return; }
  if (G.cut.raw <= 0) { SFX.bad(); say('Doğranmış patates yok!'); return; }
  var n = Math.min(TUN.fryCap(G), G.cut.raw);
  G.cut.raw -= n;
  f.state = 'fry'; f.t = 0; f.dur = TUN.fryTime(G); f.load = n; f.prog = 0;
  SFX.basket();
}
function fryTake() {
  var f = G.fryer;
  var n = Math.min(f.load, TUN.friesCap() - G.friesTray);
  G.friesTray += n;
  f.state = 'idle'; f.load = 0; f.t = 0;
  SFX.drop();
  burst(ST.fryer.x + 20, ST.fryer.y + 14, 10, [P.p0, P.p1, '#fff'], { spMax: 60, up: 20 });
  checkAuto();
}
function updateFryer(dt) {
  var f = G.fryer;
  /* Elektrik yoksa fritoz durur; ses de kesilir. */
  if (kesintiVarMi()) { if (typeof sndLoop === 'function') sndLoop('fry', false); return; }
  if (typeof sndLoop === 'function') sndLoop('fry', f.state === 'fry' && G.scene === 'play');
  f.basketY = approach(f.basketY, f.state === 'idle' ? -5 : 7, dt * 26);
  if (f.state === 'idle') {
    if (TUN.autoFry(G) && G.cut.raw > 0 && G.friesTray < TUN.friesCap()) fryerClick();
    return;
  }
  f.t += dt; f.prog = clamp(f.t / f.dur, 0, 1);
  if (f.state === 'fry') {
    if (chance(dt * 14)) part({
      x: ST.fryer.x + 12 + rnd(0, ST.fryer.w - 24), y: ST.fryer.y + 20,
      vx: rnd(-4, 4), vy: rnd(-20, -8), life: .55, col: 'rgba(255,240,200,.45)', g: -14, sz: 1
    });
    /* kızartma sesi: dosya varsa döngü, yoksa aralıklı sentez */
    if (!(typeof sndLoop === 'function' && sndLoop('fry', true))) {
      f.sz = (f.sz || 0) + dt;
      if (f.sz > 1.4) { f.sz = 0; SFX.fry(); }
    }
  }
  if (f.state === 'fry' && f.t >= f.dur) { f.state = 'done'; SFX.bell(); }
  if (f.state === 'done' && TUN.autoFry(G)) fryTake();
}

/* ---------------- içecek: her musluğun kendi bardağı ---------------- */
/* Birlesik makinede ACIK olan icecekler, soldan saga musluk sirasi. */
function icecekMusluklari() {
  var m = [];
  if (TUN.drinkOn(G)) { m.push('fanta'); m.push('cola'); }
  if (TUN.ayranOn(G)) m.push('ayran');
  return m;
}
/* Bardak, kendi muslugunun altinda durur. */
function cupPos(type) {
  var m = icecekMusluklari();
  var i = m.indexOf(type);
  if (i < 0) i = 0;
  var gen = ST.drinkM.w / Math.max(1, m.length);
  return [Math.round(ST.drinkM.x + gen * (i + .5)), ST.drinkM.y + 42];
}
function pourStart(type) {
  if (type === 'ayran') {
    if (!TUN.ayranOn(G)) { SFX.bad(); say('Ayran kazanı yok'); return; }
    if (G.stock.ayran <= 0) { SFX.bad(); say('Ayran bitti — kutudan doldur!'); return; }
  } else if (!TUN.drinkOn(G)) { SFX.bad(); say('İçecek standı kapalı'); return; }
  var d = G.drinkM;
  /* Kola, fanta ve ayran ayrı musluklardır: biri akarken diğerine
     basabilirsin. Sadece aynı içeceği iki kez başlatamazsın. */
  if (d.pours[type] !== undefined) { SFX.bad(); return; }
  if (G.cups[type]) { SFX.bad(); say('Bardak zaten dolu'); return; }
  if (type === 'ayran') { G.stock.ayran--; G.fxTray.ayran = 1; }
  G.cups[type] = { kind: 'drink', type: type, fill: 0 };
  d.pours[type] = 0;
  d.pour = type; d.t = 0;
  pourSndStart(type);
}
function takeCup(type) {
  var c = G.cups[type];
  if (!c) { SFX.bad(); say('Bardak yok'); return; }
  if (c.fill < 1) { SFX.bad(); say('Daha doluyor…'); return; }
  var old = G.hand;
  if (old && !returnItem(old)) { SFX.bad(); say('Yer yok!'); return; }
  G.hand = c; G.cups[type] = null;
  SFX.pick();
}
function updateDrink(dt) {
  var d = G.drinkM;
  var sure = TUN.pourTime(G);
  var akan = 0, enDolu = 0, biten = false;
  for (var ty in d.pours) {
    var c = G.cups[ty];
    if (!c) { delete d.pours[ty]; continue; }
    d.pours[ty] += dt;
    c.fill = clamp(d.pours[ty] / sure, 0, 1);
    if (c.fill >= 1) { delete d.pours[ty]; biten = true; SFX.glass(); continue; }
    akan++;
    if (c.fill > enDolu) enDolu = c.fill;
    if (d.pour === ty) d.t = d.pours[ty];
  }
  /* akan varsa ses onu takip etsin; hepsi bitince sussun */
  if (akan > 0) {
    if (d.pours[d.pour] === undefined) {
      for (var ty2 in d.pours) { d.pour = ty2; d.t = d.pours[ty2]; break; }
    }
    pourSndLevel(enDolu);
    return;
  }
  d.pour = null;
  if (biten) pourSndStop(true);

  /* otomatik dolum: tezgâhtaki müşteriler + AÇIK PAKET SİPARİŞİ.
     Eskiden yalnız G.customers'a bakıyordu; paket kola isteyip
     tezgâhta kola isteyen olmayınca makine hiç doldurmuyordu. */
  if (TUN.autoDrink(G)) {
    var want = null;
    /* önce paket: kurye bekliyor ve o bardak yalnız elle verilebiliyor */
    if (phoneOpen()) {
      var pq = G.phone;
      for (var k = 0; k < pq.order.length && !want; k++) {
        if (pq.done[k] || pq.order[k].kind !== 'drink') continue;
        if (!G.cups[pq.order[k].type]) want = pq.order[k].type;
      }
    }
    for (var i = 0; i < G.customers.length && !want; i++) {
      var c2 = G.customers[i];
      if (c2.state !== 'wait') continue;
      for (var j = 0; j < c2.items.length; j++) {
        if (c2.done[j] || c2.items[j].kind !== 'drink') continue;
        var ty = c2.items[j].type;
        if (!G.cups[ty]) { want = ty; break; }
      }
    }
    /* elde ayni icecek varsa bir tane daha doldurma: bardak cakisir */
    if (G.hand && G.hand.kind === 'drink' && G.hand.type === want) want = null;
    if (want && (want !== 'ayran' || G.stock.ayran > 0)) pourStart(want);
  }
}
/* herhangi bir içecek akıyor mu */
function pouringAny() {
  for (var k in G.drinkM.pours) return true;
  return false;
}

/* ---------------- tatlı ---------------- */
function sweetClick() {
  if (!TUN.sweetOn(G)) { SFX.bad(); say('Tatlı tepsisi yok — dükkândan al'); return; }
  if (G.stock.sweet <= 0) { SFX.bad(); say('Tatlı bitti — kutudan doldur!'); return; }
  var old = G.hand;
  if (old && !returnItem(old)) { SFX.bad(); say('Yer yok!'); return; }
  G.stock.sweet--; G.fxTray.sweet = 1;
  G.hand = { kind: 'sweet' };
  SFX.pick();
}

/* ---------------- patates kutusu ---------------- */
function fboxClick() {
  if (!TUN.fboxOn(G)) { SFX.bad(); say('Porsiyon kutusu kapalı'); return; }
  if (G.fbox.ready > 0) {
    var old3 = G.hand;
    if (old3 && !returnItem(old3)) { SFX.bad(); say('Yer yok!'); return; }
    G.fbox.ready--;
    G.hand = { kind: 'fbox' };
    SFX.pick();
    return;
  }
  if (G.fbox.busy > 0 || G.fbox.fly) return;
  if (TUN.autoBox(G)) { say('Kutu kendi dolduruyor'); return; }
  SFX.ui();
  say('Kutuyu patates tepsisine sürükle');
}
/* Kutuyu doldur. ucarak=true ise oto kutu tepsiye gitti demektir. */
function fboxDoldur(ucarak) {
  if (G.friesTray < 2) { SFX.bad(); say('Yeterli patates yok'); return false; }
  G.friesTray -= 2;
  G.fbox.busy = 1;
  G.fxTray.fries = 1;
  SFX.pick();
  if (!ucarak) burst(ST.friesT.x + ST.friesT.w / 2, ST.friesT.y + 10, 7,
                     ['#f0c24a', '#e0a828', '#fff0c0'], { spMax: 44, up: 16 });
  return true;
}
function updateFbox(dt) {
  var f = G.fbox;
  if (f.busy > 0) {
    f.busy -= dt / TUN.fboxTime(G);
    if (f.busy <= 0) {
      f.busy = 0;
      /* elle dolduysa kutu zaten tezgahta; oto ise geri ucar */
      if (f.fly) { f.fly.faz = 'donus'; f.fly.t = 0; }
      else { f.ready = Math.min(3, f.ready + 1); SFX.pop(); }
    }
  }
  /* --- oto kutu: tepsiye ucar, dolar, yerine doner --- */
  if (f.fly) {
    f.fly.t += dt / 0.42;
    if (f.fly.t >= 1) {
      if (f.fly.faz === 'gidis') {
        f.fly.t = 0; f.fly.faz = 'dolum';
        if (!fboxDoldur(true)) { f.fly = null; }   /* patates yoksa vazgec */
      } else if (f.fly.faz === 'donus') {
        f.fly = null;
        f.ready = Math.min(3, f.ready + 1);
        SFX.pop();
        burst(ST.fbox.x + ST.fbox.w / 2, ST.fbox.y + 14, 6, ['#f7d34a', '#e2382a'], { spMax: 40, up: 14 });
      }
    }
    return;
  }
  if (TUN.autoBox(G) && f.busy === 0 && f.ready < 2 && G.friesTray >= 4) {
    var need = false;
    for (var i = 0; i < G.customers.length; i++) {
      var c = G.customers[i];
      if (c.state !== 'wait') continue;
      for (var j = 0; j < c.items.length; j++) if (!c.done[j] && c.items[j].kind === 'fbox') need = true;
    }
    if (!need && phoneOpen()) {
      for (var k = 0; k < G.phone.order.length; k++)
        if (!G.phone.done[k] && G.phone.order[k].kind === 'fbox') need = true;
    }
    if (need) { f.fly = { t: 0, faz: 'gidis' }; SFX.pick(); }
  }
}
/* Ucan kutunun o anki konumu (cizim icin). */
function fboxUcusPos() {
  var f = G.fbox;
  if (!f.fly) return null;
  var ax = ST.fbox.x + ST.fbox.w / 2, ay = ST.fbox.y + 14;
  var bx = ST.friesT.x + ST.friesT.w / 2, by = ST.friesT.y + ST.friesT.h + 6;
  var k = clamp(f.fly.t, 0, 1);
  if (f.fly.faz === 'dolum') return { x: bx, y: by, dolum: true };
  var u = f.fly.faz === 'gidis' ? easeOut(k) : 1 - easeOut(k);
  return { x: lerp(ax, bx, u), y: lerp(ay, by, u) - Math.sin(u * Math.PI) * 18, dolum: false };
}

/* ---------------- otomasyon kontrolü ---------------- */
function checkAuto() {
  var n = TUN.boards(G), i;
  for (i = 0; i < n; i++) {
    var w = G.boards[i];
    if (!w || w.state === 'ready') continue;
    if (w.kind === 'pide') continue;
    if (w.kind === 'plate') {
      if (TUN.autoIsk(G) && w.meat >= TUN.iskMeat(G)) {
        if (!w.butter) { w.butter = true; G.sauceFx.butter = 1; }
        else if (!w.yogurt && G.stock.yogurt > 0) {
          var ay = Math.min(PLATE_YOGURT - (w.yogurtN || 0), G.stock.yogurt);
          G.stock.yogurt -= ay; w.yogurtN = (w.yogurtN || 0) + ay;
          w.yogurt = w.yogurtN >= PLATE_YOGURT;
          G.fxTray.yogurt = 1;
        }
        /* garnitur aciksa tabak ancak biber+domatesle tamamlanir */
        else if (TUN.garnishOn(G) && (w.tomato || 0) < TOMATO_NEED && G.stock.tomato > 0) {
          var at = Math.min(TOMATO_NEED - (w.tomato || 0), G.stock.tomato);
          G.stock.tomato -= at; w.tomato = (w.tomato || 0) + at;
          G.fxTray.tomato = 1;
        }
        else if (TUN.garnishOn(G) && (w.pepper || 0) < PEPPER_NEED && G.stock.pepper > 0) {
          var ap = Math.min(PEPPER_NEED - (w.pepper || 0), G.stock.pepper);
          G.stock.pepper -= ap; w.pepper = (w.pepper || 0) + ap;
          G.fxTray.pepper = 1;
        }
      }
      finishPlate(i);
      continue;
    }
    if (w.state === 'rolled') {
      /* sarılı dürüm: önce ızgara (varsa), sonra kağıt.
         Izgara TIKALIYSA sıra beklemek kilitlenme demektir: pişen dürüm
         inecek yer bulamıyor, yer de ancak bir dürüm 'ready' olup
         servis edilince açılıyor. O yüzden tıkalıyken kağıda geçilir —
         ızgara ikramiyesi kaçar ama dükkân çalışmaya devam eder. */
      /* Izgara aciksa kizarmamis dürüm KAGITLANMAZ: satilamaz mal
         olurdu. Tikanmayi grillTakeOut'taki takas cozuyor. */
      if (wrapNeedsGrill(w)) {
        /* Izgara aciksa dürüm ONCE izgaraya girer. Eskiden oto kagit
           ızgarayi atlayip dürümü kagitliyordu: dürüm hic kizarmadan
           hazir oluyor, cirak da öylece veriyordu — her dürümde
           +$6 izgara ikramiyesi sessizce kaybediliyordu.
           Oto izgara yoksa (grill < 4) oyuncu kendi koyar, kagit bekler. */
        if (TUN.autoGrill(G) && !grillDolu()) grillPut(i);
      } else if (TUN.autoPaper(G) && G.paper.busy === 0) startPaper(i);
      continue;
    }
    if (!wrapFull(w)) continue;
    /* OTOMATIK SOS YOK. Oyun kendi kafasina sos surunce, sabri
       tukenmek uzere olan "sade dürüm" musterisine hazir dürüm
       verilemiyordu: sos baska musteri icin konmus oluyordu.
       Sos yalnizca oyuncu sos standina TIKLAYINCA surulur. */
    /* SARMA HER ZAMAN ELLE — otomatik sarılmaz, yoksa sos konmadan gider */
  }
  /* Otomatik tabak: SIPARIS EDILEN KADAR pide acar.
     HATA: eskiden yalnizca kind==='plate' sayiliyordu; yeni acilan
     tabak once kind==='pide' oldugu icin "hic tabak yok" saniliyor ve
     her karede bir tane daha aciliyordu. Tek iskender isteyen musteriye
     3 tabak hazirlanip butun tezgah kilitleniyordu. */
  if (TUN.autoIsk(G)) {
    var istenen = 0, mevcut = 0, bosTahta = 0;
    for (i = 0; i < n; i++) {
      var bb = G.boards[i];
      if (!bb) { bosTahta++; continue; }
      /* pide de tabak da ayni siparisi karsilar */
      if (bb.kind === 'plate' || bb.kind === 'pide') mevcut++;
    }
    for (i = 0; i < G.customers.length; i++) {
      var cc = G.customers[i];
      if (cc.state !== 'wait') continue;
      for (var j = 0; j < cc.items.length; j++) if (!cc.done[j] && cc.items[j].kind === 'plate') istenen++;
    }
    if (phoneOpen()) {
      var pp = G.phone;
      for (i = 0; i < pp.order.length; i++) if (!pp.done[i] && pp.order[i].kind === 'plate') istenen++;
    }
    /* elde tasinan tabak da sayilir */
    if (G.hand && G.hand.kind === 'plate') mevcut++;
    /* Izgarada dürüm varken son bos tahtayi ALMA: pisen dürümün
       inecek yeri kalmazsa dükkan tikaniyor. */
    var gerekliBos = (G.grill.slots && G.grill.slots.length) ? 2 : 1;
    if (istenen > mevcut && bosTahta >= gerekliBos) newPide(true);
    /* otomatik doğrayıcı: tahtadaki pideyi kendi doğrar */
    for (i = 0; i < n; i++) if (G.boards[i] && G.boards[i].kind === 'pide') pideChop(i, true);
  }
}

/* ---------------- stok kutusu ---------------- */
/* ---------------- kutudan tepsiye uçan malzeme ---------------- */
function spawnFlyIng(kind, n) {
  var dst = kind === 'pickle' ? ST.pickle
    : (kind === 'yogurt' ? ST.yogurt
      : (kind === 'ayran' ? ST.ayran
        : ((kind === 'tomato' || kind === 'pepper') ? ST.garnish : ST.sweet)));
  for (var i = 0; i < n && G.flyIng.length < 24; i++) {
    G.flyIng.push({
      kind: kind, t: -i * .09,
      x0: ST.crate.x + 10 + rnd(-5, 5), y0: ST.crate.y + 4,
      x1: dst.x + rnd(7, dst.w - 9), y1: dst.y + rnd(10, 20),
      sp: rnd(.9, 1.15), rot: rnd(0, 6)
    });
  }
}
function updateFly(dt) {
  for (var i = G.flyIng.length - 1; i >= 0; i--) {
    var f = G.flyIng[i];
    f.t += dt * 2.1 * f.sp;
    if (f.t >= 1) {
      G.flyIng.splice(i, 1);
      G.fxTray[f.kind] = 1;
      SFX.pop();
      var bc = f.kind === 'pickle' ? [P.g1, P.g0]
        : (f.kind === 'sweet' ? ['#e89a3c', '#ffd07a']
          : (f.kind === 'tomato' ? ['#e2483a', '#f07a68']
            : (f.kind === 'pepper' ? ['#5d9a24', '#8fc93a'] : [P.s0, '#ffffff'])));
      burst(f.x1, f.y1, 3, bc, { spMax: 26, up: 12, sz: 1, lifeMax: .35 });
    }
  }
  var ks = ['pickle', 'yogurt', 'fries', 'meat', 'ayran', 'sweet', 'tomato', 'pepper'];
  for (var k = 0; k < ks.length; k++) if (G.fxTray[ks[k]] > 0) G.fxTray[ks[k]] = Math.max(0, G.fxTray[ks[k]] - dt * 3.2);
  G.stockAnim.pickle = approach(G.stockAnim.pickle, G.stock.pickle, dt * 22);
  G.stockAnim.yogurt = approach(G.stockAnim.yogurt, G.stock.yogurt, dt * 22);
  G.stockAnim.ayran = approach(G.stockAnim.ayran, G.stock.ayran, dt * 22);
  G.stockAnim.sweet = approach(G.stockAnim.sweet, G.stock.sweet, dt * 22);
  G.stockAnim.tomato = approach(G.stockAnim.tomato, G.stock.tomato, dt * 22);
  G.stockAnim.pepper = approach(G.stockAnim.pepper, G.stock.pepper, dt * 22);
}

function crateItems() {
  var a = [['pickle', 'Turşu'], ['yogurt', 'Yoğurt']];
  if (TUN.ayranOn(G)) a.push(['ayran', 'Ayran']);
  if (TUN.sweetOn(G)) a.push(['sweet', 'Tatlı']);
  if (TUN.garnishOn(G)) { a.push(['tomato', 'Domates']); a.push(['pepper', 'Biber']); }
  return a;
}
function crateMax(k) {
  if (k === 'ayran') return TUN.ayranMax(G);
  if (k === 'sweet') return TUN.sweetMax(G);
  if (k === 'tomato' || k === 'pepper') return TUN.garnishMax(G);
  return stMax();
}
function cratePanelRect() {
  var n = crateItems().length;
  var h = 18 + n * 22 + 12;
  return [ST.crate.x - 88, ST.crate.y - h + 26, 116, h];
}
function crateSlotRect(i) {
  var r = cratePanelRect();
  return [r[0] + 6, r[1] + 14 + i * 22, 104, 20];
}
function crateClick(mx, my) {
  var c = G.crate;
  if (!c.open) { c.open = true; c.t = 0; SFX.drawer(false); say('Kutu açık — tıklayarak doldur'); return; }
  var items = crateItems();
  for (var i = 0; i < items.length; i++) {
    var r = crateSlotRect(i);
    if (inRect(mx, my, r[0], r[1], r[2], r[3])) {
      var k = items[i][0], m = crateMax(k);
      if (G.stock[k] >= m) { SFX.bad(); return; }
      var add = Math.min(TUN.refillPer(G), m - G.stock[k]);
      G.stock[k] += add;
      c.popT = .2;
      SFX.pick();
      spawnFlyIng(k, Math.max(2, add));
      return;
    }
  }
  c.open = false; SFX.drawer(true);
}
function updateStock(dt) {
  /* cirak sv3: kova dolmadan copu bosaltir — denetci ceza yazmasin */
  if (TUN.autoTrash(G) && G.trash > .50 && G.emptyT <= 0) {
    G.emptyT = .9; G.trash = 0;
    SFX.pour();
    burst(ST.trash.x + 11, ST.trash.y + 4, 10, ['#6d6258', '#8a7a6a', '#4a423a'], { spMax: 50, up: 22 });
  }
  if (!TUN.autoStock(G)) return;
  G.autoT += dt;
  if (G.autoT > 1.1) {
    G.autoT = 0;
    var m = stMax();
    if (G.stock.pickle < m * .6) G.stock.pickle = Math.min(m, G.stock.pickle + 4);
    else if (G.stock.yogurt < m * .6) G.stock.yogurt = Math.min(m, G.stock.yogurt + 4);
    else if (TUN.ayranOn(G) && G.stock.ayran < TUN.ayranMax(G) * .6) G.stock.ayran = Math.min(TUN.ayranMax(G), G.stock.ayran + 2);
    else if (TUN.sweetOn(G) && G.stock.sweet < TUN.sweetMax(G) * .6) G.stock.sweet = Math.min(TUN.sweetMax(G), G.stock.sweet + 1);
    else if (TUN.garnishOn(G) && G.stock.tomato < TUN.garnishMax(G) * .6) G.stock.tomato = Math.min(TUN.garnishMax(G), G.stock.tomato + 2);
    else if (TUN.garnishOn(G) && G.stock.pepper < TUN.garnishMax(G) * .6) G.stock.pepper = Math.min(TUN.garnishMax(G), G.stock.pepper + 2);
  }
}

/* ---------------- müşteriler ---------------- */
function spawnCustomer() {
  var used = {};
  for (var i = 0; i < G.customers.length; i++) if (G.customers[i].state !== 'leave') used[G.customers[i].slot] = 1;
  var free = [];
  for (var s = 0; s < G.cfg.slots; s++) if (!used[s]) free.push(s);
  if (!free.length) return;
  var slot = pick(free);
  /* MAC DALGASI bayragi siparis uretiminden ONCE kurulmali: makeOrder
     onu okuyup icecek oranini yukseltiyor. Sonra kurulunca siparis
     bayragi hic gormuyordu. */
  G.macDalga = macDalgada();
  /* evsiz misafir: para vermez ama şans getirir */
  var homeless = G.day >= HOMELESS_DAY && !G.hadHomeless && chance(HOMELESS_CHANCE / 14);
  var items = homeless ? [{ kind: 'wrap' }] : makeOrder(G);
  /* Sokaga cikma kisitlaminda musteri seyrek gelir; bosa gecen gunu
     telafi etmek icin gelenler ikinci bir urun daha ister. */
  if (!homeless && fermanDunya('sokak') && items.length < 3 && chance(.7)) {
    var ek = makeOrder(G);
    if (ek && ek.length) items = items.concat([ek[0]]);
  }
  /* Musteri MAC DALGASINDA mi dogdu: sabri ve bahsisi ona gore. */
  var pat = (52 - Math.min(16, G.day * .9)) * TUN.patience(G) *
            (1 + (items.length - 1) * .45) * TUN.havaSabir(G) * TUN.macSabir(G);
  if (homeless) { pat *= 2.2; G.hadHomeless = true; }
  var look = newCustomerLook(Math.floor(rnd(1, 9999)));
  if (homeless) { look.shirt = 5; look.hair = 2; look.acc = 'cap'; }
  SFX.door();
  var c = {
    slot: slot, homeless: homeless, look: look, mac: !!G.macDalga,
    items: items, done: items.map(function () { return false; }),
    patMax: pat, patience: 1, t: 0, mood: 'wait', state: 'walkin',
    x: W + 24, y: LAY.custSlots[slot].y, tx: LAY.custSlots[slot].x,
    bubble: 0, line: '', lineT: 0, wrongT: 0, earn: 0
  };
  G.customers.push(c);
  if (homeless) {
    c.line = pick(LINES_HOMELESS); c.lineT = 3.2;
    say('Aç bir misafir geldi — dürüm verirsen şansın açılır');
  }
}
function updateCustomers(dt) {
  for (var i = G.customers.length - 1; i >= 0; i--) {
    var c = G.customers[i]; c.t += dt;
    if (c.lineT > 0) c.lineT -= dt;
    if (c.wrongT > 0) c.wrongT -= dt;
    if (c.state === 'walkin') {
      /* Ozel musteri binegiyle geliyor: binek konup binici inene kadar
         dukkana girmez. Once binek ayri, musteri ayri geliyordu. */
      if (typeof binekBekle === 'function' && c.look &&
          binekBekle(c.look.kalip)) {
        c.x = W + 24;
      } else c.x = approach(c.x, c.tx, dt * 120);
      if (Math.abs(c.x - c.tx) < 1) {
        c.state = 'wait';
        /* ozel kalip tezgaha varinca kendi repligini soyler */
        var kr = c.look && KALIP_REPLIK[c.look.kalip];
        if (kr && !c.homeless) { c.line = kr; c.lineT = 3.4; }
        else if (!c.homeless && typeof secimReplik === 'function') {
          /* "Turşusuz, lütfen." — rozet ikinci kanal, cumle birinci.
             Ikisi birden olunca istegi kacirmak zorlasiyor. */
          var sr = secimReplik(c.items && c.items[0]);
          if (sr) { c.line = sr; c.lineT = 3.0; }
        }
      }
    } else if (c.state === 'wait') {
      c.bubble = Math.min(1, c.bubble + dt * 5);
      /* ogretici sirasinda ilk musteri sabirla bekler */
      if (!tutBusy()) c.patience -= dt / c.patMax;
      if (!c.mad) c.mood = c.patience < .3 ? 'angry' : 'wait';
      if (chance(dt * .12) && c.lineT <= 0 && c.patience < .55) { c.line = pick(c.patience < .3 ? LINES_ANGRY : LINES_WAIT); c.lineT = 1.8; }
      if (c.patience <= 0) {
        c.state = 'leave'; c.leaveDir = 1;
        if (c.homeless) { c.mood = 'wait'; c.line = ''; c.lineT = 0; }
        else {
          c.mood = 'angry';
          c.line = pick(LINES_ANGRY); c.lineT = 2.2;
          G.stat.lost++;
          G.stat.seri = 0;                     /* memnun seri koptu */
          SFX.angry(); shake(2.5);
        }
      }
    } else if (c.state === 'served') {
      c.bubble = Math.max(0, c.bubble - dt * 4);
      /* Geldigi kapidan cikar: sag taki tas kemerin arkasina girip
         gozden kaybolur. Sola gidince tezgahin bittigi yerde
         bacaksiz/yarim gorunuyordu. */
      if (c.t - c.servedAt > 1.0) { c.state = 'leave'; c.leaveDir = 1; }
    } else if (c.state === 'sorgu') {
      /* Gozcu sokakta durdurdu: musteri kipirdamaz, ustunde unlem durur. */
      c.sorguT = (c.sorguT || 0) + dt;
      c.bubble = Math.max(0, c.bubble - dt * 5);
      if (c.sorguT > 2.6) { c.state = 'leave'; c.mood = 'angry'; }
    } else if (c.state === 'leave') {
      c.x += (c.leaveDir > 0 ? 1 : -1) * dt * 100;
      c.bubble = Math.max(0, c.bubble - dt * 5);
      if (c.x < -40 || c.x > W + 40) G.customers.splice(i, 1);
    }
  }
  /* Cirak servis yapmaz — musteriye urunu oyuncu verir. */
}
/* --- TALEP: tezgahtaki musteriler + ACIK PAKET SIPARISI ---
   Yardimci sistemler eskiden yalniz G.customers'a bakiyordu. Paket
   siparisi onlara gorunmedigi icin cirak, siparise lazim olan hazir
   durumu tezgahtaki musteriye veriyordu; paket ise yalniz ELLE
   kuryeye verilebildiginden siparis bir daha tamamlanamiyor,
   telefon da o gun bir daha calmiyordu. */
function phoneOpen() {
  var p = G.phone;
  return !!(p && p.state === 'order' && p.order && phoneActive());
}
/* NOT: autoServe kaldirildi. Cirak (helper) artik para toplar,
   stok doldurur ve copu bosaltir; SERVIS yapmaz. Musteriye urun
   vermek oyunun ana isi, otomasyona birakilmiyor. */
/* Dokunmatikte parmak imleci gizliyor ve hassasiyet dusuk:
   hedef kutusu genisletilir. Farede eski olcu korunur. */
function custHit(c) {
  var p = TOUCH ? 10 : 0;
  return inRect(IN.x, IN.y, c.x - 20 - p, c.y - 54 - p, 40 + p * 2, 54 + p * 2);
}
/* Elde urun varken musterinin uzerine SURUKLEYIP BIRAKMAK teslim eder.
   Uzerinden gecerken teslim etmek yanlisti: sirada birden fazla musteri
   varken elin ustunden gectigi ilk uygun kisiye gidiyor, oyuncu hedefi
   secemiyordu. Artik hedefi BIRAKTIGIN yer belirler. */
function surukleServis() {
  if (!G.hand || !IN.released) return false;
  for (var i = 0; i < G.customers.length; i++) {
    var c = G.customers[i];
    if (c.state !== 'wait') continue;
    if (!custHit(c)) continue;
    deliver(c);
    return true;
  }
  return false;
}

function deliver(c) {
  var it = G.hand;
  if (!it || c.state !== 'wait') return;
  /* Lider tezgahta bekliyorsa urun ONCE ona gider: siradaki musteriye
     servis yapmak lideri bekletmek demek. */
  if (liderBekliyor() && liderVer(it)) return;
  /* Kagitsiz dürüm servis edilemez: sarili dürüm ele alinabiliyor
     (yanmisi cope atmak icin) ama musteriye kagitli gider. */
  if (it.kind === 'wrap' && it.state === 'rolled' && !it.paper) {
    SFX.bad(); say('Önce kâğıtla — kağıtsız dürüm verilmez');
    return;
  }
  /* --- DEMIRKENT: bugun yasak olan musteri ya da urun ---
     Satis NORMAL tamamlanir; mal musteriye gecer. Yakalanmak ayri bir sey:
     gozcu o anda cama bakiyorsa aninda ihlal, bakmiyorsa mal kacak olarak
     disari cikar ve sokakta sorgulanabilir. (Eskiden urun elde kaliyor,
     oyuncu ayni seyi tekrar verip ihlal ustune ihlal yiyor, musteri de
     hicbir sey almiyordu.) */
  var yasakM = fermanYasakMusteri(c);
  if (yasakM) fermanKacak(yasakM, c, c.x, c.y - 60);
  var yasakU = fermanYasakUrun(it);
  if (yasakU) fermanKacak(yasakU, c, c.x, c.y - 60);
  /* Yanmis durum satilmaz: yalniz cope gider. */
  if (it.kind === 'wrap' && it.burnt) {
    SFX.bad(); say('Yanmış dürüm satılmaz — çöpe at');
    return;
  }
  /* Izgara aciksa dürüm ızgaradan gecmeden verilmez. */
  if (it.kind === 'wrap' && TUN.grillOn(G) && !it.grilled) {
    SFX.bad(); say('Izgarasız dürüm olmaz — önce ızgaraya at');
    return;
  }
  var idx = -1;
  for (var pass = 0; pass < 2 && idx < 0; pass++) {
    for (var i = 0; i < c.items.length; i++) {
      if (c.done[i]) continue;
      var o = c.items[i];
      if (o.kind !== it.kind) continue;
      if (it.kind === 'drink' && o.type !== it.type) continue;
      if (pass === 0 && it.kind === 'wrap' && (o.sauce || null) !== (it.sauce || null)) continue;
      idx = i; break;
    }
  }
  if (idx < 0) {
    c.line = pick(LINES_WRONG); c.lineT = 1.6; c.wrongT = .6;
    SFX.bad();
    ftext('YANLIŞ!', c.x, c.y - 62, P.bad);
    return;
  }
  c.done[idx] = true;
  var ord = c.items[idx];
  var sauceOk = !ord.sauce || it.sauce === ord.sauce;
  var price = it.kind === 'wrap'
    ? itemPrice({ kind: 'wrap', grilled: it.grilled, sauce: sauceOk ? ord.sauce : null }, G)
    : itemPrice(it, G);
  var q = 1;
  if (it.kind === 'wrap' || it.kind === 'plate') {
    q = it.quality === undefined ? (it.kind === 'plate' ? plateQuality(it) : wrapQuality(it)) : it.quality;
    price = Math.max(2, Math.round(price * q));
    if (q < .99) {
      c.mad = true;
      c.line = pick(LINES_CHEAP); c.lineT = 1.8;
      c.patience = Math.max(.05, c.patience - (1 - q) * .35);
      ftext(T('EKSİK! -%') + Math.round((1 - q) * 100), c.x, c.y - 60, P.bad, { life: 1.3 });
      SFX.bad();
    }
  }
  /* MALZEME SECIMI: istemedigi malzeme konmus ya da istedigi
     konmamis. Sos yanlisiyla ayni agirlikta bir hata. */
  var secimOk = it.kind !== 'wrap' || secimUyuyor(it, ord);
  if (!secimOk) {
    price = Math.max(2, Math.round(price * .60));
    q = Math.min(q, .75);
    c.mad = true; c.madSebep = 'secim';
    c.line = pick(LINES_SECIM); c.lineT = 1.9;
    c.patience = Math.max(.05, c.patience - .18);
    ftext(T('İSTEDİĞİ GİBİ DEĞİL!'), c.x, c.y - 60, P.bad, { life: 1.3 });
    SFX.bad();
  }
  if (!sauceOk) {
    price = Math.max(2, Math.round(price * .65));
    q = Math.min(q, .8);
    c.mad = true; c.madSebep = 'sos';
    c.line = pick(LINES_SAUCE); c.lineT = 1.9;
    c.patience = Math.max(.05, c.patience - .18);
    ftext('SOS YANLIŞ!', c.x, c.y - 60, P.bad, { life: 1.3 });
    SFX.bad();
  }
  if (c.homeless) price = 0;
  c.earn = (c.earn || 0) + price;
  if (it.kind === 'wrap') G.stat.wraps++;
  else if (it.kind === 'plate') G.stat.isk++;
  else if (it.kind === 'drink') G.stat.drinks++;
  else if (it.kind === 'fbox') G.stat.boxes++;
  else if (it.kind === 'sweet') G.stat.sweets++;
  G.totalSold++;
  G.hand = null;
  burst(c.x, c.y - 26, q < .99 ? 5 : 8, q < .99 ? [P.warn, '#fff'] : [P.au0, P.au1, '#fff'], { spMax: 70, up: 25, sz: 2 });
  if (q >= .99) SFX.serve();
  /* Eksik ya da yanlis verilen siparise musteri GULUMSEMEZ. */
  c.mood = q < .99 ? 'angry' : 'happy';
  var all = true;
  for (var d = 0; d < c.done.length; d++) if (!c.done[d]) all = false;
  if (all) payCustomer(c);
}
function payCustomer(c) {
  if (c.homeless) {
    c.state = 'served'; c.servedAt = c.t;
    c.mood = 'happy';
    c.line = pick(LINES_HOMELESS_OK); c.lineT = 2.6;
    G.luck = Math.min(LUCK_MAX, (G.luck || 0) + 1);
    G.stats.fed = (G.stats.fed || 0) + 1;
    SFX.ding(); SFX.levelup();
    burst(c.x, c.y - 30, 18, ['#e2483a', '#ff8a7a', '#ffffff'], { spMax: 70, up: 28, type: 'heart', sz: 2 });
    ftext('ŞANS +1', c.x, c.y - 60, P.ok, { sc: 1, life: 1.8 });
    flash(.10, '#ffd7d0');
    saveAll();
    return;
  }
  var val = c.earn || 0;
  var tip = Math.round(val * .22 * clamp(c.patience, 0, 1) * TUN.havaBahsis(G) *
                       (c.mac ? 1.55 : 1));
  c.state = 'served'; c.servedAt = c.t;
  c.mood = c.mad ? 'angry' : 'served';
  /* Sebebe gore replik: 'doymadim' yalniz EKSIK dürüm icin dogru.
     Yanlis siparis ya da yanlis sos ayri sey soyluyor. */
  c.line = pick(!c.mad ? LINES_HAPPY
    : (c.madSebep === 'secim' ? LINES_SECIM
      : (c.madSebep === 'sos' ? LINES_SAUCE : LINES_CHEAP)));
  c.lineT = 1.8;
  G.stat.earned += val + tip; G.stat.tips += tip;
  /* ---- basarim: memnun musteri serisi ve bahsis rekoru ---- */
  if (!c.mad) {
    G.stat.seri = (G.stat.seri || 0) + 1;
    if (G.stat.seri > (G.stats.enSeri || 0)) G.stats.enSeri = G.stat.seri;
  } else G.stat.seri = 0;
  if (tip > (G.stats.enBahsis || 0)) G.stats.enBahsis = tip;
  if (c.items && c.items.length >= 4) G.stats.buyukSiparis = (G.stats.buyukSiparis || 0) + 1;
  addTrash(TRASH_PER_SALE);
  var n = clamp(Math.round((val + tip) / 10), 1, 6);
  for (var i = 0; i < n; i++) {
    G.coins.push({
      x: c.x + rnd(-14, 14), y: c.y - 30, vy: rnd(-70, -40), vx: rnd(-18, 18),
      v: Math.round((val + tip) / n), t: rnd(0, 3), landed: 0, life: 0, ph: rnd(0, 6)
    });
  }
  SFX.cash();
  ftext('+$' + fmtMoney(val + tip), c.x, c.y - 46, P.au1);
  flash(.08, '#ffe9a0');
}

/* ---------------- Dayı'nın motoru ---------------- */
function motoBroken() { return !!(G.moto && G.moto.broken); }
function motoClick() {
  if (!motoBroken()) return false;
  var c = G.moto.cost;
  if (G.moto.ask > 0) {
    if (G.money < c) { SFX.bad(); say(T('Para yetmiyor — $') + fmtMoney(c) + T(' lazım')); return true; }
    G.money -= c;
    G.moto.broken = false; G.moto.ask = 0; G.moto.fixT = 1.6;
    G.stats.moto = (G.stats.moto || 0) + 1;
    SFX.cash(); SFX.moto();
    burst(ST.uncle.x + 24, 214, 16, ['#9aa3ab', '#ffd75e', '#ffffff'], { spMax: 70, up: 26, sz: 2 });
    ftext('MOTOR TAMİR!', ST.uncle.x + 24, 190, P.ok, { sc: 1, life: 1.6 });
    say('Dayı yine yollarda');
    saveAll();
    return true;
  }
  G.moto.ask = 3;
  SFX.ui();
  say(T('Motor bozuk — tamir $') + fmtMoney(c) + T(' (tekrar tıkla)'));
  return true;
}
function updateMoto(dt) {
  if (!G.moto) return;
  if (G.moto.ask > 0) G.moto.ask -= dt;
  if (G.moto.fixT > 0) G.moto.fixT -= dt;
  if (G.moto.newT > 0) {
    G.moto.newT -= dt;
    if (G.moto.newT <= 0) { SFX.fail(); say(pick(LINES_MOTO)); }
  }
  if (motoBroken() && chance(dt * 1.4)) {
    part({
      x: ST.uncle.x + 18 + rnd(-6, 6), y: 214, vx: rnd(-6, 6), vy: rnd(-20, -8),
      life: .9, col: 'rgba(90,90,96,.5)', g: -10, sz: 1
    });
  }
}
function drawMotoBadge(t) {
  if (!motoBroken()) return;
  var bx = ST.uncle.x + 2, by = 186;
  ctx.globalAlpha = .5 + .3 * Math.sin(t * 5);
  rrect(bx, by, 44, 22, 3, 'rgba(20,14,12,.85)');
  rrectOut(bx, by, 44, 22, 3, P.bad);
  ctx.globalAlpha = 1;
  /* ingiliz anahtari */
  ln(bx + 6, by + 15, bx + 13, by + 8, '#c7ced5');
  fr(bx + 4, by + 13, 4, 4, '#9aa3ab');
  px(bx + 5, by + 14, '#5a636b');
  txt('BOZUK', bx + 24, by + 3, P.bad, { align: 'c' });
  txt('$' + fmtShort(G.moto.cost), bx + 24, by + 12, P.au0, { align: 'c' });
}

/* ---------------- gece: hırsız ---------------- */
function rollNight() {
  G.night = null;
  if (G.day < THIEF_DAY) return;
  if (!chance(TUN.thiefVisit(G))) return;
  var stole = chance(TUN.thiefSteal(G));
  var amount = 0;
  if (stole) {
    amount = Math.round(G.money * rnd(THIEF_MIN, THIEF_MAX));
    amount = Math.min(G.money, Math.max(amount, Math.min(G.money, 40)));
  }
  G.night = {
    t: 0, phase: 0, stole: stole, amount: amount,
    sec: TUN.secLevel(G), line: pick(stole ? LINES_THIEF_WIN : LINES_THIEF_LOSE),
    paid: false
  };
}

/* ---------------- dayı: gün sonu kurtarma ---------------- */
function uncleReady() { return G.uncle.left > 0 && G.timeLeft <= 20 && G.scene === 'play'; }
function uncleUse() {
  if (!uncleReady()) {
    if (TUN.uncleUses(G) === 0) say('Dayı için upgrade al!');
    else if (G.uncle.left <= 0) say('Dayının hakkı kalmadı');
    else say('Dayı son 20 saniyede yardım eder');
    SFX.bad();
    return;
  }
  var target = null;
  for (var i = 0; i < G.customers.length; i++) if (G.customers[i].state === 'wait') { target = G.customers[i]; break; }
  if (!target) { SFX.bad(); say('Bekleyen müşteri yok'); return; }
  G.uncle.left--; G.uncle.flashT = 1;
  G.stats.dayi = (G.stats.dayi || 0) + 1;
  G.chef.mode = 'happy'; G.chef.armT = 0;
  for (var j = 0; j < target.items.length; j++) {
    if (target.done[j]) continue;
    target.done[j] = true;
    var it = target.items[j];
    target.earn = (target.earn || 0) + itemPrice(it.kind === 'wrap' ? { kind: 'wrap', grilled: TUN.grillOn(G) } : it, G);
    if (it.kind === 'wrap') G.stat.wraps++;
    else if (it.kind === 'plate') G.stat.isk++;
    else if (it.kind === 'drink') G.stat.drinks++;
    else if (it.kind === 'sweet') G.stat.sweets++;
    else G.stat.boxes++;
    G.totalSold++;
  }
  burst(target.x, target.y - 30, 20, [P.au0, P.au1, '#fff'], { spMax: 90, up: 30, type: 'star', sz: 2 });
  flash(.25, '#ffe9a0'); shake(3);
  ftext('DAYI KURTARDI!', target.x, target.y - 66, P.au0, { life: 1.6 });
  payCustomer(target);
}

/* ---------------- para ---------------- */
function updateCoins(dt) {
  for (var i = G.coins.length - 1; i >= 0; i--) {
    var c = G.coins[i]; c.t += dt;
    if (!c.landed) {
      c.vy += 260 * dt; c.x += c.vx * dt; c.y += c.vy * dt;
      if (c.y > LAY.ledgeY + 3) { c.y = LAY.ledgeY + 3; c.landed = 1; c.vx = 0; }
    } else {
      c.life += dt;
      if (TUN.autoCoin(G) || c.life > 10) collectCoin(i, true);
    }
  }
}
function collectCoin(i, auto) {
  var c = G.coins[i];
  /* KASA: Demirkent'te para ayri kasaya gider (bkz. kasaEkle) */
  kasaEkle(c.v);
  G.coins.splice(i, 1);
  if (!auto) SFX.coin();
  burst(c.x, c.y, 4, [P.au0, P.au1], { spMax: 40, up: 20, sz: 1 });
  if (G.flyCoins.length < 24) G.flyCoins.push({ x0: c.x, y0: c.y, t: 0, v: c.v, ph: rnd(0, 6) });
}
/* para HUD'daki sayaca uçar */
function updateFlyCoins(dt) {
  for (var i = G.flyCoins.length - 1; i >= 0; i--) {
    var f = G.flyCoins[i];
    f.t += dt * 1.9;
    if (f.t >= 1) {
      G.flyCoins.splice(i, 1);
      G.hudPop = 1;
      var hp = hudCoinPos();
      burst(hp[0], hp[1], 4, [P.au0, '#fff'], { spMax: 34, up: 10, sz: 1 });
    }
  }
  if (G.hudPop > 0) G.hudPop = Math.max(0, G.hudPop - dt * 4);
}
function drawFlyCoins(t) {
  for (var i = 0; i < G.flyCoins.length; i++) {
    var f = G.flyCoins[i], k = clamp(f.t, 0, 1);
    var ke = k * k * (3 - 2 * k);
    var hp2 = hudCoinPos();
    var fx2 = lerp(f.x0, hp2[0], ke);
    var fy2 = lerp(f.y0, hp2[1], ke) - Math.sin(k * Math.PI) * 30;
    ctx.globalAlpha = 1 - k * .25;
    drawCoin(fx2, fy2, f.v, t, f.ph);
    ctx.globalAlpha = 1;
  }
}

/* ---------------- ana güncelleme ---------------- */
function updatePlay(dt) {
  G.sceneT += dt;
  updateFerman(dt); updateGozcu(dt); updateLider(dt);
  if (G.hintT > 0) G.hintT -= dt;
  if (G.uncle.flashT > 0) G.uncle.flashT -= dt;
  if (G.crate.popT > 0) G.crate.popT -= dt;
  /* cekmece one/geriye yumusak kayar */
  var hedefA = G.crate.open ? 1 : 0;
  G.crate.a = approach(G.crate.a === undefined ? 0 : G.crate.a, hedefA, dt * 5.5);

  /* 1. gun ogreticisi: oyuncu ilk dürümü rahatca yapsin diye
     sayac durur ve hic musteri gelmez. Ilk siparis teslim edilince
     (tutDone) gun normal akisina gecer. */
  var ogretimde = tutBusy();

  if (!ogretimde && G.timeLeft > 0) {
    var was = G.timeLeft;
    G.timeLeft -= dt;
    /* son 10 saniye: geri sayım tik sesi */
    if (G.timeLeft <= 10 && Math.ceil(G.timeLeft) !== Math.ceil(was)) {
      if (G.timeLeft <= 5) SFX.warn(); else SFX.tick();
    }
    if (G.timeLeft <= 0) { G.timeLeft = 0; endDay(); return; }
  }
  kesintiGuncelle(dt);
  rakipGuncelle(dt);
  kediGuncelle(dt);
  if (!ogretimde && G.timeLeft > 2) {
    G.spawnT -= dt;
    if (G.spawnT <= 0) {
      spawnCustomer();
      /* Havaya gore gelis sikligi: yagmurda cok az, karda seyrek,
         sicakta biraz daha yogun. */
      var wm = isRain() ? 1.75 : TUN.havaGelis(G);
      if (macDalgada()) wm *= MAC_HIZ;        /* mac dalgasi: seri gelis */
      /* Sokaga cikma kisitlamasi: sokak bosalir, gelen az ama kalabalik siparis verir. */
      if (fermanDunya('sokak')) wm *= 1.9;
      G.spawnT = rnd(G.cfg.rate * .75, G.cfg.rate * 1.2) * wm;
    }
  }

  /* kepenk açılışı */
  if (G.shutT > 0) {
    G.shutT = Math.max(0, G.shutT - dt / 1.5);
    G.shutSnd -= dt;
    if (G.shutSnd <= 0) { G.shutSnd = .55; SFX.shutter(); }
    if (G.shutT <= 0) { SFX.ding(); ftext('AÇILDIK!', W / 2, 96, P.au0, { sc: 1, life: 1.2 }); }
  }
  updateFlyCoins(dt);

  var dragged = updateDrag(dt);
  updateShave(dt); updateCut(dt); updateFryer(dt); updateGrill(dt);
  updatePaper(dt); updateDrink(dt); updateFbox(dt); updateStock(dt); updateFly(dt); updatePhone(dt);
  updateWeather(dt); maybeInspector(dt); updateSauce(dt); updateMoto(dt); updateFlyMeat(dt);
  if (!pouringAny()) pourSndStop(false);
  /* oto iskender periyodik olarak talebi yeniden olcer (oto sos yok) */
  if (TUN.autoIsk(G)) {
    G.autoIskT = (G.autoIskT || 0) + dt;
    if (G.autoIskT > .8) { G.autoIskT = 0; checkAuto(); }
  }
  if (G.emptyT > 0) G.emptyT -= dt;
  if (G.luckMsg > 0) G.luckMsg -= dt;
  /* elde urunle musteri uzerinden gecince aninda teslim */
  surukleServis();
  updateCustomers(dt); updateCoins(dt);
  updateTut();

  G.chef.armT += dt;
  if (G.chef.mode === 'slice' && G.spit.sliceT <= 0) G.chef.mode = 'idle';
  if (G.chef.mode === 'happy' && G.uncle.flashT <= 0) G.chef.mode = 'idle';

  for (var i = 0; i < G.boards.length; i++) {
    var bw = G.boards[i];
    if (bw) {
      if (bw.pop > 0) bw.pop -= dt * 3;
      if (bw.chop > 0) bw.chop = Math.max(0, bw.chop - dt * 5);
      if (bw.paperT > 0) bw.paperT -= dt * 2.0;
    }
  }
  if (G.flyP) {
    G.flyP.t += dt / .38;
    if (G.flyP.t >= 1) { G.cut.potato = true; G.cut.prog = 0; G.flyP = null; SFX.drop(); }
  }

  if (!dragged) handleInput();
}

/* ---------------- girdi ---------------- */
function handleInput() {
  if (!IN.pressed) return;
  var mx = IN.x, my = IN.y;
  /* Test surumundeki DEV dugmesi her seyden once: panel acikken de kapatabil. */
  if (typeof devDugmeTik === 'function' && devDugmeTik(mx, my)) return;
  if (testHit(mx, my)) return;      /* test paneli tıklamayı alsın */

  /* HUD kirpma kadar asagi VE sola cizildigi icin hedef kutusu da kayar */
  if (inRect(mx, my, hudSagKenar() - 22, 4 + VIEW.top, 18, 16)) { G.scene = 'pause'; SFX.ui(); return; }

  /* Demirkent: ferman kagidi ve yasakli musteri X'i her seyden once */
  if (fermanTik(mx, my)) return;

  if (G.crate.open) {
    var cr = cratePanelRect();
    if (inRect(mx, my, cr[0], cr[1], cr[2], cr[3]) || hitST('crate')) { crateClick(mx, my); return; }
    G.crate.open = false; SFX.uiBack();
  }

  if (G.hand) {
    for (var i = 0; i < G.customers.length; i++) {
      var c = G.customers[i];
      if (c.state === 'wait' && custHit(c)) { deliver(c); return; }
    }
  }
  for (var k = G.coins.length - 1; k >= 0; k--) {
    var co = G.coins[k];
    if (co.landed && inRect(mx, my, co.x - 7, co.y - 8, 14, 14)) { collectCoin(k, false); return; }
  }
  /* Kediye TIKLAMAK beslemez: et tepsisinden bir dilim tutup
     kedinin ustune BIRAKILIR. Tiklayan oyuncuya ne yapacagi soylenir. */
  if (typeof kediHit === 'function' && kediHit(mx, my)) {
    SFX.uiBack();
    say(G.meat > 0 ? 'Et tepsisinden bir dilim sürükle' : 'Et yok — önce dönerden kes');
    return;
  }
  if (hitST('phone') && phoneActive()) { phoneClick(); return; }
  if (hitST('uncle')) { if (motoClick()) return; if (giveToCourier()) return; uncleUse(); return; }
  if (hitST('trash')) { trashClick(); return; }
  /* --- ELINI BOSALT ---
     Elde bir sey varken baska bir istasyona basmak, o seyi ESKI YERINE
     birakir ve tiklama normal isini gorur. Eskiden elde kalan tabak/bardak
     hicbir yere konamiyor, tek cikis copti: cikmaz his veriyordu.
     Cop, kurye ve tahta bunun disinda — onlarin kendi davranisi var. */
  if (G.hand && !hitST('board') && !hitST('uncle')) {
    if (!returnItem(G.hand)) {
      SFX.bad();
      say('Koyacak yer yok — tezgâhta yer aç');
      return;
    }
    G.hand = null;
    SFX.pick();
  }
  if (hitST('crate')) { crateClick(mx, my); return; }
  if (hitST('spit')) { if (G.shave.act <= 0) say(TOUCH ? 'Parmağını yukarı-aşağı sürt!' : 'Fareyi yukarı-aşağı sürt!'); return; }
  if (hitST('meat')) { addMeat(); return; }
  if (hitST('pickle')) { addIng('pickle'); return; }
  if (hitST('yogurt')) { addIng('yogurt'); return; }
  if (hitST('friesT')) { addIng('fries'); return; }
  if (hitST('garnish')) { garnishClick(mx); return; }
  if (hitST('bread')) {
    if (TUN.iskOn(G) && my < ST.bread.y + 16) newPide(); else newWrap();
    return;
  }
  if (hitST('sauce')) { sauceClick(mx); return; }
  if (hitST('board')) {
    var idx = boardAt(mx, my);
    var w = G.boards[idx];
    if (!w) {
      /* boş noktaya tıklandıysa en yakın hazır dürümü al */
      for (var bi2 = 0; bi2 < TUN.boards(G); bi2++) if (G.boards[bi2] && G.boards[bi2].state === 'ready') { idx = bi2; w = G.boards[bi2]; break; }
    }
    if (!w) {
      for (var bi3 = 0; bi3 < TUN.boards(G); bi3++) {
        var pb = G.boards[bi3];
        if (pb && pb.kind === 'plate' && plateAny(pb)) { idx = bi3; w = pb; break; }
      }
    }
    /* tahtada bütün pide varsa: tıklama doğrama yapar */
    if (!w) { for (var pb = 0; pb < TUN.boards(G); pb++) if (G.boards[pb] && G.boards[pb].kind === 'pide') { idx = pb; w = G.boards[pb]; break; } }
    if (w && w.kind === 'pide') { G.act = idx; pideChop(idx); return; }
    /* Acik bir dürüm/tabak varsa tiklamak onu SECER: bundan sonra
       malzemeler oraya gider. Eskiden secim yapilamiyor, malzeme
       "en son acilan"a gidiyordu ve oyuncu nereye koydugunu bilemiyordu. */
    if (w && w.state === 'open' && !G.hand) {
      if (G.act !== idx) { G.act = idx; SFX.pick(); w.pop = 1; }
      return;
    }
    /* Sarili (kagitsiz) dürüm de ele alinir: yanmis olani cope
       goturebilmek icin. Kagitsiz dürüm MUSTERIYE verilemez —
       o kontrol deliver/giveToCourier icinde. */
    if (w && (w.state === 'ready' || w.state === 'rolled' ||
              (w.kind === 'plate' && plateAny(w)))) {
      if (G.hand) {
        /* elindekiyle değiştir */
        var old = G.hand;
        G.hand = w; G.boards[idx] = null;
        if (old.kind === 'wrap' || old.kind === 'plate') { G.boards[idx] = old; SFX.pick(); return; }
        if (!returnItem(old)) { G.boards[idx] = w; G.hand = old; SFX.bad(); say('Yer yok!'); return; }
        SFX.pick(); return;
      }
      G.hand = w; G.boards[idx] = null; SFX.pick();
    }
    return;
  }
  if (hitST('paper')) { paperClick(); return; }
  if (hitST('grill')) { grillClick(); return; }
  if (hitST('potato')) { potatoTake(); return; }
  if (hitST('cut')) { cutClick(); return; }
  if (hitST('fryer')) { fryerClick(); return; }
  if (hitST('fbox')) { fboxClick(); return; }
  if (hitST('sweet')) { sweetClick(); return; }
  if (hitST('drinkM')) {
    /* Birlesik makine: acik olan icecekler soldan saga musluk
       bolgelerine dagilir. Ayran artik ayri istasyon degil. */
    var mus = icecekMusluklari();
    if (!mus.length) { SFX.bad(); say('İçecek standı kapalı'); return; }
    var gen = ST.drinkM.w / mus.length;
    var i2 = clamp(Math.floor((mx - ST.drinkM.x) / gen), 0, mus.length - 1);
    var tip = mus[i2];
    if (my > ST.drinkM.y + 32) takeCup(tip); else pourStart(tip);
    return;
  }
}

/* ---------------- çizim ---------------- */
var _bgCheck = 0;
function drawPlay(t) {
  if (bgBayat()) bakeBG(UV(G, 'paint'));
  /* tarayıcı katmanı boşaltmışsa yakala */
  if (++_bgCheck % 120 === 0) {
    try {
      var pxd = BG.getContext('2d').getImageData(2, 2, 1, 1).data;
      if (pxd[3] === 0) { bakeBG(UV(G, 'paint')); CLAYER = null; STONEFG = null; }
    } catch (e) { }
  }
  ctx.drawImage(BG, 0, 0);
  drawWallDecor(t);

  for (var i = 0; i < G.customers.length; i++) drawCustomer(G.customers[i], t);
  drawInspector(t);
  /* tas duvarlar musterinin onunde: giren/cikan musteri tasin
     arkasindan gecer, tezgahin onunde yarim govdeyle asili kalmaz */
  drawStoneFG();

  /* Dayı ancak upgrade alındıktan sonra dükkânda durur.
     Öncesinde daha işe girmemiştir. Taş duvar da aynı koşulla kayar. */
  if (dayiVar() && (!G.courier || G.courier.state === 'in')) {
    drawChef(LAY.chef.x, LAY.chef.y, G.chef, t);
  }
  if (uncleReady() && (!G.courier || G.courier.state === 'in')) {
    ctx.globalAlpha = .35 + .3 * Math.sin(t * 7);
    rrectOut(ST.uncle.x, ST.uncle.y, ST.uncle.w, ST.uncle.h, 4, P.au0);
    ctx.globalAlpha = 1;
    rrect(ST.uncle.x + 2, ST.uncle.y - 13, 42, 12, 3, P.red1);
    rrectOut(ST.uncle.x + 2, ST.uncle.y - 13, 42, 12, 3, P.ui5);
    txt(T('DAYI x') + G.uncle.left, ST.uncle.x + 23, ST.uncle.y - 11, P.au0, { align: 'c' });
  }

  drawCounter();
  drawCounterProps(t);

  for (var c = 0; c < G.coins.length; c++) {
    var co = G.coins[c];
    drawCoin(co.x, co.y, co.v, t, co.ph);
    if (co.landed && co.life > 8) { ctx.globalAlpha = .5 + .5 * Math.sin(t * 12); ring(co.x, co.y - 1, 7, P.au0); ctx.globalAlpha = 1; }
  }

  drawSpit(G.spit, t);
  drawShaveHint(t);
  /* Telefon ve PAKET fisi donerden SONRA: fis genisleyince (4 kalem)
     sisin arkasinda kaliyor ve siparis okunmuyordu. */
  drawPhone(t);
  drawFerman(t);
  /* Lider EN SONDA: musteri balonlarinin ve tezgahin onunde dursun. */
  drawLider(t);

  drawMeatTray(ST.meat.x, ST.meat.y, ST.meat.w, ST.meat.h, G.meat, t, G.fxTray.meat);
  /* --- GARNITUR TEZGAHI: uc bolme, tek govde --- */
  var tkX = ST.pickle.x, tkW = (ST.friesT.x + ST.friesT.w) - ST.pickle.x;
  drawTepsiKasasi(tkX, ST.pickle.y, tkW, ST.pickle.h, 3);
  drawPickleTray(ST.pickle.x, ST.pickle.y, ST.pickle.w, ST.pickle.h, G.stockAnim.pickle, stMax(), t, G.fxTray.pickle);
  drawYogurtTray(ST.yogurt.x, ST.yogurt.y, ST.yogurt.w, ST.yogurt.h, G.stockAnim.yogurt, stMax(), t, G.fxTray.yogurt);
  drawFriesTray(ST.friesT.x, ST.friesT.y, ST.friesT.w, ST.friesT.h, G.friesTray, TUN.friesCap(), t, G.fxTray.fries);
  drawTepsiCami(tkX, ST.pickle.y, tkW, ST.pickle.h, t);
  if (TUN.garnishOn(G)) {
    drawGarnishTray(ST.garnish.x, ST.garnish.y, ST.garnish.w, ST.garnish.h,
      G.stockAnim.tomato, G.stockAnim.pepper, TUN.garnishMax(G), t,
      Math.max(G.fxTray.tomato, G.fxTray.pepper));
  } else lockedStation(ST.garnish, 'GARNİTÜR', t);

  /* --- BIRLESIK ICECEK UNITESI: kola/fanta + ayran tek kasada --- */
  var musluklar = icecekMusluklari();
  if (musluklar.length) {
    /* ortak kasa */
    drawIcecekKasasi(ST.drinkM.x, ST.drinkM.y, ST.drinkM.w, 34, musluklar.length, t);
    if (TUN.drinkOn(G)) {
      drawDrinkMachine(ST.drinkM.x, ST.drinkM.y, ST.drinkM.w - (TUN.ayranOn(G) ? ST.ayran.w : 0), 32, G.drinkM, t);
    }
    if (TUN.ayranOn(G)) {
      drawAyranTank(ST.ayran.x, ST.ayran.y, ST.ayran.w, ST.ayran.h - 6,
        G.stockAnim.ayran, TUN.ayranMax(G), { pour: G.drinkM.pours.ayran !== undefined }, t);
    }
    /* bardaklar: her musluk kendi altinda */
    musluklar.forEach(function (ty) {
      var cp = cupPos(ty), cu = G.cups[ty];
      if (cu) {
        drawCup(cp[0], cp[1], ty, cu.fill, t);
        if (cu.fill >= 1) { ctx.globalAlpha = .3 + .25 * Math.sin(t * 7); ring(cp[0], cp[1] - 2, 8, P.ok); ctx.globalAlpha = 1; }
      } else {
        ctx.globalAlpha = .25; ell(cp[0], cp[1] + 9, 6, 2, '#000'); ctx.globalAlpha = 1;
      }
    });
  } else lockedStation(ST.drinkM, 'İÇECEK', t);
  drawFryer(ST.fryer.x, ST.fryer.y, ST.fryer.w, ST.fryer.h, G.fryer, t);
  drawPotatoBin(ST.potato.x, ST.potato.y, ST.potato.w, ST.potato.h, t);
  drawCrate(ST.crate.x, ST.crate.y, ST.crate.w, ST.crate.h, G.crate.open, t, G.crate.a);
  if (TUN.iskOn(G)) {
    drawPideStack(ST.bread.x, ST.bread.y, ST.bread.w);
    ctx.save(); ctx.translate(0, 12);
    drawBreadStack(ST.bread.x, ST.bread.y, ST.bread.w, ST.bread.h, '');
    ctx.restore();
    ctx.globalAlpha = .28; hl(ST.bread.x + 5, ST.bread.y + 15, ST.bread.w - 10, '#ffffff'); ctx.globalAlpha = 1;
  } else drawBreadStack(ST.bread.x, ST.bread.y, ST.bread.w, ST.bread.h);

  var nb = TUN.boards(G);
  /* --- TEK büyük hazırlık tezgâhı --- */
  ctx.globalAlpha = .3; rrect(ST.board.x + 3, ST.board.y + 10, ST.board.w - 4, 34, 3, '#000'); ctx.globalAlpha = 1;
  rrect(ST.board.x + 2, ST.board.y + 8, ST.board.w - 4, 34, 3, '#7a5230');
  rrect(ST.board.x + 2, ST.board.y + 7, ST.board.w - 4, 34, 3, '#c49a68');
  rrect(ST.board.x + 4, ST.board.y + 9, ST.board.w - 8, 30, 2, '#dcb480');
  for (var g2 = 0; g2 < 6; g2++) {
    ctx.globalAlpha = .32;
    hl(ST.board.x + 5, ST.board.y + 11 + g2 * 5, ST.board.w - 10, g2 % 2 ? '#c09660' : '#cfa876');
    ctx.globalAlpha = 1;
  }
  rrectOut(ST.board.x + 4, ST.board.y + 9, ST.board.w - 8, 30, 2, '#b08a58');
  hl(ST.board.x + 4, ST.board.y + 8, ST.board.w - 8, '#eccb96');
  /* kesik izleri */
  for (var ci = 0; ci < 7; ci++) {
    ctx.globalAlpha = .18;
    ln(ST.board.x + 8 + ci * 12, ST.board.y + 14 + (ci % 3) * 6, ST.board.x + 13 + ci * 12, ST.board.y + 18 + (ci % 3) * 6, '#8a6a42');
    ctx.globalAlpha = 1;
  }

  var wsc = nb === 1 ? 1 : (nb === 2 ? .74 : .58);
  for (var b = 0; b < nb; b++) {
    var bcx = boardCX(b), bcy = ST.board.y + 24;
    var w = G.boards[b];
    if (!w) continue;
    var pop = Math.max(0, w.pop || 0);
    var yoff = -Math.sin(pop * Math.PI) * 3;
    /* seçili dürüm işareti */
    /* aktif (malzeme gidecek) dürüm: ince alt çizgi */
    if (w.state === 'open' && b === G.act && nb > 1) {
      ctx.globalAlpha = .5 + .3 * Math.sin(t * 5);
      hl(bcx - 14 * wsc, ST.board.y + 38, 28 * wsc, P.au1);
      ctx.globalAlpha = 1;
    }
    if (w.kind === 'pide') {
      drawPideBoard(bcx, bcy + yoff, w, t, wsc);
      var pn2 = Math.min(w.n || 0, PIDE_NEED);
      var lbl2 = T('DOĞRA  ') + pn2 + '/' + PIDE_NEED;
      var lw3 = textW(lbl2) + 8;
      ctx.globalAlpha = .55 + .3 * Math.sin(t * 4);
      rrect(bcx - lw3 / 2, ST.board.y + 34, lw3, 10, 3, 'rgba(20,14,12,.8)');
      txt(lbl2, bcx, ST.board.y + 36, P.au0, { align: 'c' });
      ctx.globalAlpha = 1;
      continue;
    }
    if (w.kind === 'plate') {
      drawPlate(bcx, bcy + yoff, w, t, wsc);
      if (w.state === 'ready') {
        ctx.globalAlpha = .35 + .25 * Math.sin(t * 7);
        rrectOut(bcx - 21 * wsc - 2, ST.board.y + 9, 42 * wsc + 4, 30, 3, P.ok);
        ctx.globalAlpha = 1;
      } else {
        var nx = w.meat < TUN.iskMeat(G) ? 'DÖNER' : (!w.butter ? 'TEREYAĞI' : 'YOĞURT');
        var nw = textW(nx) + 8;
        ctx.globalAlpha = .5 + .3 * Math.sin(t * 4);
        rrect(bcx - nw / 2, ST.board.y - 1, nw, 10, 3, 'rgba(20,14,12,.8)');
        txt(nx, bcx, ST.board.y + 1, P.au0, { align: 'c' });
        ctx.globalAlpha = 1;
      }
      continue;
    }
    if (w.state === 'rolled') {
      drawWrapRolled(bcx, bcy + yoff, w, t, wsc);
      wrapEtiket(bcx, ST.board.y + 30, w, nb > 2);
      var lbl = null, lcol = P.ui0;
      if (wrapNeedsGrill(w) && !grillDolu()) { lbl = 'IZGARAYA AT'; lcol = '#ffb45a'; }
      else if (UV(G, 'paper') === 0 && !(G.drag && G.drag.type === 'paper')) lbl = 'KAĞIT SÜRÜKLE';
      if (lbl) {
        var lw2 = textW(lbl) + 8;
        ctx.globalAlpha = .55 + .3 * Math.sin(t * 4);
        rrect(bcx - lw2 / 2, ST.board.y - 1, lw2, 10, 3, 'rgba(20,14,12,.8)');
        txt(lbl, bcx, ST.board.y + 1, lcol, { align: 'c' });
        ctx.globalAlpha = 1;
      }
    } else if (w.state === 'ready') {
      drawWrapRolled(bcx, bcy + yoff, w, t, wsc);
      ctx.globalAlpha = .35 + .25 * Math.sin(t * 7);
      rrectOut(bcx - 16 * wsc - 2, ST.board.y + 9, 32 * wsc + 4, 30, 3, P.ok);
      ctx.globalAlpha = 1;
      wrapEtiket(bcx, ST.board.y + 30, w, nb > 2);
    } else {
      drawWrapOpen(bcx, bcy + yoff, w, t, wsc);
      /* sarma ipucu: yukarı ok */
      if (wrapAny(w) && !(G.drag && G.drag.type === 'roll' && G.drag.idx === b)) {
        var ao = Math.round(Math.sin(t * 4) * 2);
        ctx.globalAlpha = .5 + .3 * Math.sin(t * 4);
        rrect(bcx - 16, ST.board.y - 1, 32, 10, 3, 'rgba(20,14,12,.8)');
        txt('SAR', bcx - 5, ST.board.y + 1, P.au0, { align: 'c' });
        var axx = bcx + 8;
        for (var aa = 0; aa < 6; aa++) px(axx, ST.board.y + 6 - aa + ao, P.au0);
        px(axx - 1, ST.board.y + 2 + ao, P.au0); px(axx + 1, ST.board.y + 2 + ao, P.au0);
        px(axx - 2, ST.board.y + 3 + ao, P.au0); px(axx + 2, ST.board.y + 3 + ao, P.au0);
        ctx.globalAlpha = 1;
      }
    }
  }

  drawPaperStation(ST.paper.x, ST.paper.y, ST.paper.w, ST.paper.h, UV(G, 'paper'), G.paper.busy, t);
  if (G.paper.busy > 0) bar(ST.paper.x + 4, ST.paper.y - 4, ST.paper.w - 8, 5, 1 - G.paper.busy, P.ok);

  if (TUN.grillOn(G)) {
    drawGrill(ST.grill.x, ST.grill.y, ST.grill.w, ST.grill.h, G.grill, t, TUN.grillCap(G));
    var sl = G.grill.slots, hazirVarmi = false, yanmaVarmi = 0;
    for (var gi = 0; gi < sl.length; gi++) {
      var gs = sl[gi], gsx = grillSlotX(gi), gsy = grillSlotY(gi);
      var gj = gs.done ? 0 : Math.sin(t * 20 + gi) * .5;
      drawWrapRolled(gsx, gsy + gj, gs.w, t, grillSlotSc());
      var gp = clamp(gs.t / Math.max(.001, gs.dur), 0, 1);
      var bw = Math.round((ST.grill.w - 10) / (TUN.grillCap(G) <= 2 ? TUN.grillCap(G) : 2)) - 4;
      if (gs.done && gs.yan > 0) {
        /* yanma sayaci: kirmizi ve azalan */
        bar(gsx - bw / 2, gsy - 11, bw, 4, 1 - gs.yan, gs.yan > .6 ? P.bad : P.warn);
        if (gs.yan > yanmaVarmi) yanmaVarmi = gs.yan;
      } else {
        bar(gsx - bw / 2, gsy - 11, bw, 4, gp, gp >= 1 ? P.ok : P.warn);
      }
      if (gs.done) hazirVarmi = true;
    }
    if (hazirVarmi) {
      txt(yanmaVarmi > .35 ? T('YANIYOR!') : 'AL!', ST.grill.x + ST.grill.w / 2, ST.grill.y - 18,
          yanmaVarmi > .35 ? P.bad : P.ok, { align: 'c', outline: true });
      glowRect(ST.grill.x, ST.grill.y + 8, ST.grill.w, ST.grill.h - 8,
               yanmaVarmi > .35 ? P.bad : P.ok, .4 + .3 * Math.sin(t * (yanmaVarmi > .35 ? 14 : 8)));
    }
    if (!sl.length) {
      /* Izgara BOS ama sarili dürüm bekliyor: oyuncuyu cagir.
         Oto kagit artik izgarayi atlamiyor; oyuncu koymazsa dürüm
         sirada bekler ve bu "takildim" hissi vermemeli. */
      var bekleyen = false;
      for (var gb = 0; gb < TUN.boards(G); gb++) {
        var gw2 = G.boards[gb];
        if (gw2 && gw2.kind === 'wrap' && gw2.state === 'rolled' && !gw2.grilled) { bekleyen = true; break; }
      }
      if (bekleyen && !grillDolu()) {
        txt('KOY!', ST.grill.x + ST.grill.w / 2, ST.grill.y - 18, P.warn, { align: 'c', outline: true });
        glowRect(ST.grill.x, ST.grill.y + 8, ST.grill.w, ST.grill.h - 8, P.warn, .30 + .25 * Math.sin(t * 6));
      }
    }
  } else lockedStation(ST.grill, 'IZGARA', t);

  drawCutBoard(ST.cut.x, ST.cut.y, ST.cut.w, ST.cut.h, G.cut, t);

  if (TUN.sauceOn(G) || TUN.iskOn(G)) {
    drawSauceStation(ST.sauce.x, ST.sauce.y, ST.sauce.w, ST.sauce.h, TUN.sauceOn(G), TUN.iskOn(G), G.sauceFx, t);
  } else lockedStation(ST.sauce, 'SOS', t);

  if (TUN.fboxOn(G)) {
    drawFboxStation(ST.fbox.x, ST.fbox.y, ST.fbox.w, ST.fbox.h, G.fbox.ready, t);
    if (G.fbox.busy > 0 && !G.fbox.fly) bar(ST.fbox.x + 4, ST.fbox.y - 4, ST.fbox.w - 8, 5, 1 - G.fbox.busy, P.p1);
    if (G.fbox.ready > 0) { ctx.globalAlpha = .3 + .25 * Math.sin(t * 7); rrectOut(ST.fbox.x, ST.fbox.y + 6, ST.fbox.w, ST.fbox.h - 8, 3, P.ok); ctx.globalAlpha = 1; }
    /* --- oto kutu ucusta: tepsiye gidip doluyor, sonra donuyor --- */
    var uc = fboxUcusPos();
    if (uc) {
      drawFriesCup(Math.round(uc.x), Math.round(uc.y), G.fbox.busy > 0 ? 'bos' : 'ok', t);
      if (uc.dolum) {
        bar(uc.x - 11, uc.y - 16, 22, 4, 1 - G.fbox.busy, P.p1);
        if (chance(.35)) part({ x: uc.x + rnd(-7, 7), y: uc.y - 8, vx: rnd(-10, 10), vy: rnd(-26, -12),
          life: .5, col: pick(['#f0c24a', '#e0a828', '#fff0c0']), g: 200, sz: 1 });
      }
    }
    /* --- elle surukleme: kutu imlecte --- */
    if (G.drag && G.drag.type === 'fbox') {
      drawFriesCup(Math.round(G.drag.x), Math.round(G.drag.y), 'bos', t);
      var uygun = inRect(IN.x, IN.y, ST.friesT.x - 4, ST.friesT.y - 6, ST.friesT.w + 8, ST.friesT.h + 12);
      ctx.globalAlpha = .35 + .25 * Math.sin(t * 8);
      rrectOut(ST.friesT.x - 2, ST.friesT.y - 3, ST.friesT.w + 4, ST.friesT.h + 6, 3, uygun ? P.ok : P.au0);
      ctx.globalAlpha = 1;
    }
  } else lockedStation(ST.fbox, 'KUTU', t);

  if (TUN.sweetOn(G)) drawSweetTray(ST.sweet.x, ST.sweet.y, ST.sweet.w, ST.sweet.h, G.stockAnim.sweet, TUN.sweetMax(G), t, G.fxTray.sweet);
  else lockedStation(ST.sweet, 'TATLI', t);
  drawTrash(ST.trash.x, ST.trash.y, ST.trash.w, ST.trash.h, t, G.emptyT > 0 ? G.emptyT : 0, G.trash);
  if (TUN.secLevel(G) >= 3) drawWallCam(t, false);

  if (G.fryer.state === 'done') {
    txt('ÇIKAR!', ST.fryer.x + ST.fryer.w / 2, ST.fryer.y - 8, P.ok, { align: 'c', outline: true });
    glowRect(ST.fryer.x, ST.fryer.y + 10, ST.fryer.w, ST.fryer.h - 10, P.ok, .4 + .3 * Math.sin(t * 8));
  }

  /* şişten tepsiye düşen döner dilimleri */
  drawFlyMeat(t);

  /* kutudan tepsiye uçan malzemeler */
  for (var fi2 = 0; fi2 < G.flyIng.length; fi2++) {
    var fg = G.flyIng[fi2];
    if (fg.t < 0) continue;
    var k2 = clamp(fg.t, 0, 1);
    var fgx = lerp(fg.x0, fg.x1, k2), fgy = lerp(fg.y0, fg.y1, k2) - Math.sin(k2 * Math.PI) * 15;
    ctx.globalAlpha = .2; ell(fgx, fg.y1 + 2, 4, 1, '#000'); ctx.globalAlpha = 1;
    var spin = Math.abs(Math.sin(fg.rot + k2 * 7));
    if (fg.kind === 'sweet') {
      /* halka tatlısı */
      ell(fgx, fgy + 1, 4, 3, '#8a4f14');
      ell(fgx, fgy, 4, 3, '#c9772a');
      ell(fgx, fgy, 2, 1, '#8a5a1e');
      px(fgx - 2, fgy - 1, '#ffd07a');
    } else if (fg.kind === 'pickle') {
      /* turşu dilimi */
      ell(fgx, fgy + 1, 3 + spin, 2, '#22350a');
      ell(fgx, fgy, 3 + spin, 2, '#5f8322');
      ell(fgx, fgy, 2 + spin * .6, 1, '#9dbe45');
      px(fgx - 1, fgy, '#e2efa4'); px(fgx + 1, fgy, '#e2efa4');
    } else if (fg.kind === 'tomato') {
      /* domates dilimi */
      drawTomatoSlice(Math.round(fgx), Math.round(fgy), 4);
    } else if (fg.kind === 'pepper') {
      /* yeşil biber */
      drawPepper(Math.round(fgx), Math.round(fgy) + 5, 10, spin > .5 ? 1 : -1);
    } else if (fg.kind === 'ayran') {
      /* ayran bardağı */
      fr(fgx - 2, fgy - 3, 5, 7, '#dfe7ec');
      fr(fgx - 2, fgy - 2, 4, 6, '#f8f6ee');
      fr(fgx - 2, fgy - 4, 5, 2, '#3f79c0');
      px(fgx - 1, fgy - 1, '#ffffff');
    } else {
      /* yoğurt topağı */
      ell(fgx, fgy + 1, 3, 2, '#cfc4a6');
      ell(fgx, fgy, 3, 2, P.s0);
      ell(fgx - 1, fgy - 1, 2, 1, '#ffffff');
      if (chance(.3)) part({ x: fgx, y: fgy + 2, vx: 0, vy: 8, life: .3, col: P.s1, g: 70, sz: 1 });
    }
  }

  /* uçan patates */
  if (G.flyP) {
    var fp = G.flyP, k = fp.t;
    var fx = lerp(fp.x0, fp.x1, k), fy = lerp(fp.y0, fp.y1, k) - Math.sin(k * Math.PI) * 26;
    ctx.globalAlpha = .25; ell(fx, fp.y1 + 4, 6, 2, '#000'); ctx.globalAlpha = 1;
    ell(fx, fy + 1, 6, 4, '#8a6432');
    ell(fx, fy, 6, 4, '#b98b46');
    ell(fx - 1, fy - 1, 4, 2, '#d8ab63');
    px(fx + 2, fy, '#6d4d24');
  }

  drawCourier(t);
  drawMotoBadge(t);
  /* Dayı yolda para buldu */
  if (G.luckMsg > 0) {
    var lw = Math.max(textW('Yolda para buldum!'), 60) + 14;
    var lx = 6, ly = 118;
    ctx.globalAlpha = Math.min(1, G.luckMsg);
    rrect(lx, ly, lw, 24, 3, P.ui0);
    rrectOut(lx, ly, lw, 24, 3, P.au2);
    txt('Yolda para buldum!', lx + 6, ly + 3, P.ink);
    txt('+$' + fmtMoney(G.luckAmt), lx + 6, ly + 14, P.ok);
    ctx.globalAlpha = 1;
  }
  psDraw();

  /* elde taşınan kağıt */
  /* suruklenen et dilimi: imlecin ucunda */
  if (G.drag && G.drag.type === 'et') {
    var ex2 = Math.round(G.drag.x), ey2 = Math.round(G.drag.y);
    /* kedi hedefte mi: halka ile isaretle */
    if (G.kedi && kediHit(IN.x, IN.y)) {
      var ky3 = kediY();
      ctx.globalAlpha = .45 + Math.sin(t * 8) * .2;
      ring(G.kedi.x, ky3 - 8, 13, '#ffd257');
      ctx.globalAlpha = 1;
    }
    ctx.globalAlpha = .3; ell(ex2, ey2 + 6, 6, 2, '#000'); ctx.globalAlpha = 1;
    meatStrip(ex2, ey2, .9, 7, .5);
  }
  if (G.drag && G.drag.type === 'paper') {
    var dx2 = Math.round(G.drag.x), dy2 = Math.round(G.drag.y) + 10;
    ctx.globalAlpha = .25; ell(dx2, dy2 + 8, 12, 3, '#000'); ctx.globalAlpha = 1;
    fr(dx2 - 12, dy2 - 8, 24, 17, '#d8d2c2');
    fr(dx2 - 12, dy2 - 9, 24, 17, '#fdfaf0');
    fr(dx2 - 10, dy2 - 4, 20, 3, '#d8352c');
    fr(dx2 - 10, dy2 + 1, 20, 3, '#2f5f9e');
    hl(dx2 - 12, dy2 - 9, 24, '#ffffff');
    var bi3 = boardAt(IN.x, IN.y);
    if (bi3 >= 0 && G.boards[bi3] && G.boards[bi3].state === 'rolled') {
      var nb3 = TUN.boards(G), bw3 = ST.board.w / nb3;
      glowRect(ST.board.x + bw3 * bi3 + 2, ST.board.y + 7, bw3 - 4, 35, P.ok, .5 + .3 * Math.sin(t * 8));
    }
  }

  for (var j = 0; j < G.customers.length; j++) {
    var cc = G.customers[j];
    if (cc.state === 'wait' && cc.patience < .3) {
      var ey = cc.y - 62 + Math.sin(t * 9) * 2;
      ctx.globalAlpha = .6 + .4 * Math.sin(t * 9);
      fr(cc.x + 20, ey, 3, 7, P.bad);
      fr(cc.x + 20, ey + 9, 3, 3, P.bad);
      hl(cc.x + 20, ey, 3, '#ff9a8a');
      ctx.globalAlpha = 1;
    }
    drawOrderBubble(cc, t);
  }

  drawRakip(t);
  drawWeather(t);
  /* Karartma HUD'dan ONCE: sayaclar ve dugmeler okunur kalsin,
     tezgah kararsin. */
  drawKesinti(t);
  drawFlyCoins(t);
  ftDraw();
  if (G.crate.open) drawCratePanel(t);
  drawHUD(t);
  if (typeof drawBahisPanel === 'function') drawBahisPanel(t);
  drawTut(t);
  drawHoverHint(t);
  drawFermanKagit(t);      /* modal: her seyin ustunde */
}

/* kilitli istasyon */
function lockedStation(s, label, t) {
  ctx.globalAlpha = .38;
  rrect(s.x, s.y + 8, s.w, s.h - 10, 3, '#3a4048');
  ctx.globalAlpha = .55;
  rrectOut(s.x, s.y + 8, s.w, s.h - 10, 3, '#5a626c');
  ctx.globalAlpha = 1;
  var cx = s.x + s.w / 2, cy = s.y + s.h / 2;
  fr(cx - 4, cy - 1, 9, 7, '#8a929b');
  fr(cx - 3, cy, 7, 5, '#b6bec6');
  rc(cx - 3, cy - 5, 7, 5, '#8a929b');
  txt(label, cx, cy + 9, 'rgba(255,255,255,.5)', { align: 'c' });
}
/* Doner bicagi: uzun ince agiz, uca dogru sivrilir, koyu ahsap sapli.
   Sap solda, agiz saga — uc sise deger. */
/* Tiras imlecindeki bicak. Govdesi art.js'teki drawKesimBicagi'dan
   gelir: sisteki kesim animasyonuyla AYNI bicak olsun, iki ayri
   gorunum kalmasin. Eski hali 25x3'luk duz bir gri seritti.
   kx = sapin sol ucu (cagiranlar boyle veriyor), agiz saga bakar. */
function drawDonerBicak(kx, ky) {
  ctx.globalAlpha = .26;
  fr(kx + 1, ky + 3, 24, 1, '#000');
  ctx.globalAlpha = 1;
  /* Yukseltme kademesi elde tutulan bicaga da yansir: oyuncu satin
     aldigi bicagi GORMELI. */
  drawKesimBicagi(kx + 25, ky, -1, UV(G, 'knife'));
}

/* döner kesme ipucu + bıçak */
function drawShaveHint(t) {
  var sh = G.shave;
  /* --- kesme izi: ortasi kalinlasan slash yayi --- */
  if (G.spit.swipe) {
    var sw = G.spit.swipe, a = sw.t;
    ctx.globalAlpha = a * .9;
    var uz = 30;
    for (var i = 0; i < uz; i++) {
      var u = i / (uz - 1);
      var xx = LAY.spit.cx - 24 + Math.round(u * 30);
      var yy = Math.round(sw.y - 9 + u * 18 - Math.sin(u * Math.PI) * 3);
      var kal = 1 + Math.round(Math.sin(u * Math.PI) * 2);
      fr(xx, yy, 1, kal, u < .45 ? '#ffffff' : '#ffe9c0');
      if (kal > 2) px(xx, yy + kal, 'rgba(255,230,170,.45)');
    }
    ctx.globalAlpha = 1;
  }
  if (hitST('spit')) {
    var ky = clamp(IN.y, LAY.spit.top + 8, LAY.spit.bot - 12);
    var kx = LAY.spit.cx - 30;
    drawDonerBicak(kx, ky);
    var p = sh.travel / TUN.shaveDist(G);
    bar(LAY.spit.cx - 16, LAY.spit.bot + 8, 32, 5, p, P.au1);
    if (sh.act <= 0) {
      txt('YUKARI-AŞAĞI', LAY.spit.cx, LAY.spit.top - 26, P.au0, { align: 'c', outline: true });
      var ar = Math.sin(t * 6) * 4;
      fr(LAY.spit.cx - 1, LAY.spit.top - 16 + ar, 3, 8, P.au1);
      fr(LAY.spit.cx - 2, LAY.spit.top - 16 + ar, 5, 2, P.au1);
    }
  }
  if (G.meat >= TUN.meatCap()) txt('TEPSİ DOLU', LAY.spit.cx, LAY.spit.bot + 16, P.warn, { align: 'c', outline: true });
}
/* stok paneli */
function drawCratePanel(t) {
  var r0 = cratePanelRect();
  var px0 = r0[0], py0 = r0[1], pw = r0[2], ph = r0[3];
  ctx.globalAlpha = .35; rrect(px0 + 2, py0 + 3, pw, ph, 4, '#000'); ctx.globalAlpha = 1;
  rrect(px0, py0, pw, ph, 4, P.ui4);
  rrect(px0 + 1, py0 + 1, pw - 2, ph - 2, 3, P.ui0);
  rrectOut(px0, py0, pw, ph, 4, P.ui5);
  txt('DEPO', px0 + pw / 2, py0 + 4, P.ui4, { align: 'c' });
  var items = crateItems();
  for (var i = 0; i < items.length; i++) {
    var k = items[i][0];
    var r = crateSlotRect(i);
    var over = inRect(IN.x, IN.y, r[0], r[1], r[2], r[3]);
    rrect(r[0], r[1], r[2], r[3], 3, over ? '#f2e6c6' : P.ui1);
    rrectOut(r[0], r[1], r[2], r[3], 3, P.ui3);
    /* ikon */
    if (k === 'pickle') { ell(r[0] + 10, r[1] + 11, 5, 3, P.g3); ell(r[0] + 10, r[1] + 10, 5, 3, P.g2); px(r[0] + 8, r[1] + 8, P.g0); }
    else if (k === 'yogurt') { ell(r[0] + 10, r[1] + 11, 5, 3, P.s3); ell(r[0] + 10, r[1] + 10, 5, 3, P.s0); px(r[0] + 8, r[1] + 8, '#ffffff'); }
    else if (k === 'ayran') { fr(r[0] + 7, r[1] + 5, 7, 11, '#dfe7ec'); fr(r[0] + 8, r[1] + 7, 5, 8, '#f8f6ee'); fr(r[0] + 7, r[1] + 4, 7, 2, '#3f79c0'); }
    else if (k === 'tomato') {
      /* domates: kirmizi gövde + yesil sap + parlaklik */
      ell(r[0] + 10, r[1] + 11, 5, 4, '#8e1c14');
      ell(r[0] + 10, r[1] + 10, 5, 4, '#d8352c');
      ell(r[0] + 9, r[1] + 9, 2, 1, '#ff8a72');
      px(r[0] + 10, r[1] + 6, '#3f7a2a'); px(r[0] + 9, r[1] + 6, '#4f8f33'); px(r[0] + 11, r[1] + 6, '#4f8f33');
      px(r[0] + 10, r[1] + 5, '#5aa03a');
    }
    else if (k === 'pepper') {
      /* sivri biber: yesil, ucu asagi kivrik, sapi ustte */
      ell(r[0] + 10, r[1] + 10, 3, 5, '#2f6a24');
      ell(r[0] + 10, r[1] + 9, 3, 5, '#4f9330');
      px(r[0] + 9, r[1] + 8, '#8ec95a');
      px(r[0] + 9, r[1] + 9, '#8ec95a');
      px(r[0] + 11, r[1] + 13, '#2f6a24');
      px(r[0] + 10, r[1] + 14, '#2f6a24');
      px(r[0] + 10, r[1] + 5, '#6b4a1e'); px(r[0] + 10, r[1] + 4, '#8a6428');
    }
    else { ell(r[0] + 10, r[1] + 11, 5, 4, '#8a4f14'); ell(r[0] + 10, r[1] + 10, 5, 4, '#c9772a'); ell(r[0] + 10, r[1] + 10, 2, 1, '#8a5a1e'); }
    txt(items[i][1], r[0] + 20, r[1] + 3, P.ui5);
    var n = G.stock[k], m = crateMax(k);
    txt(n + '/' + m, r[0] + 100, r[1] + 3, n < m * .25 ? P.bad : P.ui4, { align: 'r' });
    var bc = k === 'pickle' ? P.g2 : (k === 'yogurt' ? P.s3 :
             (k === 'ayran' ? '#6b9ad8' : (k === 'tomato' ? '#d8352c' :
             (k === 'pepper' ? '#4f9330' : '#c9772a'))));
    bar(r[0] + 20, r[1] + 13, 80, 5, n / Math.max(1, m), n < m * .25 ? P.bad : bc);
  }
  txt(T('tıkla: +') + TUN.refillPer(G) + T('   çekmece: kapat'), px0 + pw / 2, py0 + ph - 9, P.ui3, { align: 'c' });
}

/* ---------------- tabela ---------------- */
function tabelaAd() { return (G.custom && G.custom.sign) || 'USTA DÖNER'; }
function tabelaAlt() { return (G.custom && G.custom.sub) || ''; }
function tabelaGen() { return Math.max(88, textW(tabelaAd()) + 14, textW(tabelaAlt()) + 14); }
/* Tabelayi verilen noktaya cizer. Onizleme de ayni cizimi kullanir;
   eskiden onizleme drawWallDecor'u kaydirarak cagiriyor ve tabela
   cercevenin disinda kaliyordu. */
function drawTabela(sx, sy, t) {
  var name = tabelaAd(), sub = tabelaAlt(), sw = tabelaGen();
  rrect(sx - 2, sy - 2, sw + 4, 30, 3, '#3a2a1e');
  rrect(sx, sy, sw, 26, 2, '#c0281c');
  rrect(sx + 2, sy + 2, sw - 4, 22, 2, '#e2483a');
  txt(name, sx + sw / 2, sy + 5, P.au0, { align: 'c', outline: '#8e1c14' });
  if (sub) txt(sub, sx + sw / 2, sy + 15, P.white, { align: 'c' });
  for (var i = 0; i < Math.floor(sw / 14); i++) {
    var on = Math.sin(t * 4 + i) > -.3;
    disc(sx + 8 + i * 14, sy + 27, 2, on ? P.au0 : '#8a7a4a');
    if (on) { ctx.globalAlpha = .25; disc(sx + 8 + i * 14, sy + 27, 4, P.au1); ctx.globalAlpha = 1; }
  }
}

/* ---------------- duvar süsleri ---------------- */
function drawPoster(kind, t, x, y) {
  x = x === undefined ? 106 : x; y = y === undefined ? 50 : y;
  if (kind === 1) {
    /* --- KILIM: sacakli uclar, bordur, ortada elmas madalyon.
       Eskiden 5x3 dama tahtasiydi, haliya hic benzemiyordu. --- */
    var kw = 42, kh = 30;
    for (var f = 0; f < kw; f += 2) {          /* sacak */
      px(x + f, y - 2, '#e8dcc0'); px(x + f, y - 1, '#cfc3a6');
      px(x + f, y + kh, '#e8dcc0'); px(x + f, y + kh + 1, '#cfc3a6');
    }
    fr(x, y, kw, kh, '#6b1a14');               /* kenar */
    fr(x + 1, y + 1, kw - 2, kh - 2, '#a8321f');
    hl(x + 1, y + 1, kw - 2, '#c9553a');
    rc(x + 2, y + 2, kw - 4, kh - 4, '#1f4f6a');   /* bordur */
    for (var b = 5; b < kw - 5; b += 4) {          /* bordur kanca motifi */
      px(x + b, y + 3, '#e2a83a'); px(x + b + 1, y + 4, '#e2a83a');
      px(x + b, y + kh - 4, '#e2a83a'); px(x + b + 1, y + kh - 5, '#e2a83a');
    }
    fr(x + 5, y + 6, kw - 10, kh - 12, '#8e2418');  /* ic alan */
    var mcx = Math.round(x + kw / 2), mcy = Math.round(y + kh / 2);
    for (var d1 = -5; d1 <= 5; d1++) {              /* madalyon: elmas */
      var g1 = 9 - Math.abs(d1) * 2;
      if (g1 > 0) fr(mcx - g1, mcy + d1, g1 * 2, 1, '#1f4f6a');
    }
    for (var d2 = -3; d2 <= 3; d2++) {
      var g2 = 6 - Math.abs(d2) * 2;
      if (g2 > 0) fr(mcx - g2, mcy + d2, g2 * 2, 1, '#e2a83a');
    }
    px(mcx, mcy, '#8e2418');
    for (var sd = -1; sd <= 1; sd += 2) {           /* yan motifler */
      var sxx = mcx + sd * 14;
      for (var d4 = -2; d4 <= 2; d4++) {
        var g4 = 3 - Math.abs(d4);
        if (g4 > 0) fr(sxx - g4, mcy + d4, g4 * 2, 1, '#e2a83a');
      }
    }
  } else if (kind === 2) {
    /* döner afişi — metinler afişin İÇİNDE kalır (hepsi ortalı) */
    rrect(x, y, 40, 36, 2, '#2b2018');
    rrect(x + 2, y + 2, 36, 32, 2, '#f2e2b8');
    var pcx = x + 20;
    txt('DÖNER', pcx, y + 4, '#c0281c', { align: 'c' });
    /* mini döner: baslikla alt yazi arasinda */
    var cx2 = pcx;
    vl(cx2, y + 12, 13, '#9aa3ab');
    for (var i = 0; i < 11; i++) {
      var rr = 2 + Math.round(Math.sin(i / 11 * Math.PI) * 4);
      fr(cx2 - rr, y + 13 + i, rr * 2, 1, i < 2 ? '#e2483a' : (i % 4 === 0 ? '#a8621f' : '#c98436'));
    }
    txt('TAZE', pcx, y + 25, '#2f5f9e', { align: 'c' });
  } else if (kind === 3) {
    /* babanın fotoğrafı */
    rrect(x + 4, y, 32, 34, 2, '#6d4a22');
    rrect(x + 6, y + 2, 28, 30, 2, '#c9a06a');
    rrect(x + 7, y + 3, 26, 24, 1, '#8aa8b8');
    /* portre */
    var px2 = x + 20, py2 = y + 18;
    ell(px2, py2, 7, 8, '#f0bd8a');
    fr(px2 - 8, py2 + 6, 16, 9, '#c33c2c');
    fr(px2 - 6, py2 - 9, 13, 6, P.red2);   /* fes */
    fr(px2 - 5, py2 - 9, 11, 5, P.red1);
    fr(px2 - 5, py2 + 2, 11, 2, '#efefe9'); /* bıyık */
    fr(px2 - 4, py2 - 2, 3, 2, '#2b2018'); fr(px2 + 2, py2 - 2, 3, 2, '#2b2018');
    /* siyah kurdele */
    ln(x + 4, y + 8, x + 12, y, '#2b2018');
    ln(x + 5, y + 9, x + 13, y + 1, '#2b2018');
    txt('BABA', x + 20, y + 28, '#5a3a1e', { align: 'c' });
  }
}
function drawWallDecor(t) {
  /* --- vitrin: sokak manzarası --- */
  var dayK = 0;
  if (G.scene === 'play' && G.cfg && G.cfg.len) {
    dayK = clamp(1 - G.timeLeft / G.cfg.len, 0, 1);
    dayK = clamp((dayK - .45) / .55, 0, 1);
  }
  var cinfo = null, cu = G.courier;
  if (cu && cu.state === 'away') {
    var ct = clamp(cu.t / Math.max(.001, TUN.courierTime(G)), 0, 1);
    if (ct < .20) cinfo = { out: ct / .20, dir: -1 };
    else if (ct > .76) cinfo = { out: (ct - .76) / .24, dir: 1 };
  }
  drawStreet(t, dayK, G.scene === 'play' && isRain(), cinfo);
  var shutK = 0;
  if (G.scene === 'play') shutK = G.shutT;
  else if (G.scene === 'dayend') shutK = clamp(G.sceneT / 1.1, 0, 1);   /* gün bitti: kepenk iniyor */
  if (shutK > 0) drawShutter(shutK);

  var sx = 168, sy = 2;
  if (UV(G, 'sign') > 0) {
    var sw0 = tabelaGen();
    sx = Math.round(LAY.win.x + LAY.win.w / 2 - sw0 / 2);
    drawTabela(sx, sy, t);
  }
  if (UV(G, 'paint') > 0) {
    vl(120, 0, 14, '#3a2a1e');
    rrect(112, 14, 17, 7, 2, '#c9a04a');
    rrect(113, 14, 15, 5, 2, '#e8c46a');
    ctx.globalAlpha = .13;
    for (var r = 0; r < 26; r++) fr(120 - 3 - r, 21 + r, 7 + r * 2, 1, '#ffe9a0');
    ctx.globalAlpha = 1;
    disc(120, 21, 2, '#fff6c0');
  }
  drawPoster((G.custom && G.custom.poster) || 0, t);
}

/* ---------------- hover ---------------- */
var STNAME = {
  spit: 'Döner — yukarı/aşağı sürt', meat: 'Et Tepsisi', pickle: 'Turşu', yogurt: 'Yoğurt',
  friesT: 'Patates', drinkM: 'İçecek', fryer: 'Fritöz', potato: 'Patates Çuvalı',
  crate: 'Depo Kutusu', bread: 'Lavaş', board: 'Hazırlık Tezgâhı', paper: 'Kağıt',
  ayran: 'Ayran Kazanı', sweet: 'Tatlı Tepsisi',
  grill: 'Izgara', cut: 'Doğrama Tahtası', fbox: 'Patates Porsiyon', trash: 'Çöp', uncle: 'Dayı',
  sauce: 'Sos Standı — acı / sarımsak / tereyağı',
  garnish: 'Garnitür — domates / biber'
};
function hoverStation() {
  var keys = ['spit', 'meat', 'pickle', 'yogurt', 'friesT', 'drinkM', 'ayran', 'fryer', 'potato', 'crate',
    'bread', 'board', 'paper', 'grill', 'cut', 'sauce', 'garnish', 'fbox', 'sweet', 'trash', 'uncle'];
  for (var i = 0; i < keys.length; i++) if (hitST(keys[i])) return keys[i];
  return null;
}
function drawHoverHint(t) {
  if (G.crate.open || G.drag) return;
  if (TOUCH && !IN.down) { if (G.hintT > 0) { ctx.globalAlpha = Math.min(1, G.hintT * 2); var hw0 = textW(G.hint) + 12; var hy0 = H - VIEW.bot - 20; rrect(W / 2 - hw0 / 2, hy0, hw0, 13, 3, 'rgba(20,14,12,.88)'); txt(G.hint, W / 2, hy0 + 3, P.ui0, { align: 'c' }); ctx.globalAlpha = 1; } return; }
  var h = hoverStation();
  if (h === 'spit') h = null;   /* şişin kendi ipucu var */
  if (h) {
    var s = ST[h];
    ctx.globalAlpha = .45;
    rrectOut(s.x - 1, s.y - 1, s.w + 2, s.h + 2, 2, P.white);
    ctx.globalAlpha = 1;
    var nm = STNAME[h];
    /* Ipucu metinleri birlestirildigi icin parcalar ayri ayri cevrilir;
       yoksa butun cumle sozlukte bulunamaz ve Turkce kalir. */
    nm = T(nm);
    if (h === 'bread' && TUN.iskOn(G)) nm = T(IN.y < ST.bread.y + 16 ? 'Pide — iskender tabağı' : 'Lavaş — dürüm');
    if (h === 'garnish') {
      nm = T(IN.x < ST.garnish.x + ST.garnish.w * .52 ? 'Domates dilimi' : 'Yeşil biber');
      if (!TUN.garnishOn(G)) nm += T(' — kilitli');
    }
    if (h === 'sauce') {
      var si = sauceIdxAt(IN.x);
      nm = T(si === 0 ? 'Acı sos' : (si === 1 ? 'Sarımsak sosu' : 'Tereyağı sosu (iskender)'));
      if (!sauceOpen(si)) nm += T(' — kilitli');
    }
    var w = textW(nm) + 6;
    var tx = clamp(IN.x - w / 2, 2, W - w - 2), ty = s.y - 12;
    if (ty < VIEW.top + 22) ty = s.y + s.h + 3;   /* HUD'un altina girmesin */
    rrect(tx, ty, w, 11, 2, 'rgba(20,14,12,.82)');
    txt(nm, tx + 3, ty + 2, P.ui0);
  }
  if (G.hintT > 0) {
    ctx.globalAlpha = Math.min(1, G.hintT * 2);
    var hw = textW(G.hint) + 12, hy = H - VIEW.bot - 20;
    rrect(W / 2 - hw / 2, hy, hw, 13, 3, 'rgba(20,14,12,.88)');
    txt(G.hint, W / 2, hy + 3, P.ui0, { align: 'c' });
    ctx.globalAlpha = 1;
  }
}

/* ---------------- öğretici ----------------
   Metinler HAM TÜRKÇE durur; çeviri çizim anında txt() içinde olur.
   Bir dönem üç adım `T('Turşu koy — ') + 4 + ' porsiyon'` diye
   kuruluyordu: T() sayfa yüklenirken bir kez çalıştığı için dil
   değişince güncellenmiyor, üstelik ' porsiyon' parçası hiç
   çevrilmiyordu — İngilizcede "Add pickles — 4 porsiyon" çıkıyordu.
   tools/i18ncheck.js bunu yakalar; sözlükte tam cümle anahtarı var. */
var TUT = [
  { s: TOUCH ? 'Parmağını dönerin üstünde yukarı-aşağı sürt' : 'Fareyi dönerin üstünde yukarı-aşağı gezdir', st: 'spit', ok: function () { return G.meat >= 2; } },
  { s: 'Lavaş al', st: 'bread', ok: function () { return !!G.boards[0]; } },
  { s: 'Et tepsisine tıkla — 4 porsiyon gerek', st: 'meat', ok: function () { var w = G.boards[0]; return w && w.meat >= MEAT_NEED; } },
  /* tepsiler boş başlıyor: önce stoğu doldurmayı öğret */
  { s: 'Kutuyu aç, turşu ve yoğurt doldur', st: 'crate', ok: function () { return G.stock.pickle >= PICKLE_NEED && G.stock.yogurt >= YOGURT_NEED; } },
  { s: 'Turşu koy — ' + PICKLE_NEED + ' porsiyon', st: 'pickle', ok: function () { var w = G.boards[0]; return w && w.pickleN >= PICKLE_NEED; } },
  { s: 'Yoğurt koy — ' + YOGURT_NEED + ' porsiyon', st: 'yogurt', ok: function () { var w = G.boards[0]; return w && w.yogurtN >= YOGURT_NEED; } },
  { s: 'Çuvaldan patates al', st: 'potato', ok: function () { return G.cut.potato || !!G.flyP || G.cut.raw > 0 || G.friesTray > 0 || G.fryer.load > 0; } },
  { s: 'Tahtaya tıklayarak doğra', st: 'cut', ok: function () { return G.cut.raw > 0 || G.fryer.load > 0 || G.friesTray > 0; } },
  { s: 'Fritöze at, kızarınca çıkar', st: 'fryer', ok: function () { return G.friesTray > 0; } },
  { s: 'Patatesi dürüme koy — ' + FRIES_NEED + ' porsiyon', st: 'friesT', ok: function () { var w = G.boards[0]; return w && w.friesN >= FRIES_NEED; } },
  { s: 'Dürümü tutup YUKARI sürükleyerek sar', st: 'board', ok: function () { var w = G.boards[0]; return w && (w.state === 'rolled' || w.state === 'ready'); } },
  { s: 'Kağıdı tut, dürümün üstüne bırak', st: 'paper', ok: function () { var w = G.boards[0]; return w && w.state === 'ready'; } },
  { s: 'Dürümü al, müşteriye ver', st: null, ok: function () { return G.stat.wraps >= 1; } },
  { s: 'Paraları topla', st: null, para: true, ok: function () { return G.money > 0; } }
];
/* Ogretici hala oyuncuyu yonlendiriyor mu?
   "Dürümü al, müşteriye ver" adimina gelene kadar sayac ve musteri akisi durur;
   o adimda tek bir musteri elle cagrilir. */
function tutBusy() {
  if (G.day !== 1) return false;
  if (G.tut >= TUT.length) return false;
  /* Servis adimi da dahil: sayac ancak dürüm TESLIM edilince
     (yani son adima gecilince) akmaya baslar. */
  return G.tut < TUT.length - 1;
}

function updateTut() {
  if (G.tut >= TUT.length) return;
  if (TUT[G.tut].ok()) {
    G.tut++;
    SFX.ding();
    /* Servis adimina gecildi: ilk musteri simdi gelsin.
       Dürüm hazir oldugu icin oyuncu onu rahatca karsilar. */
    if (G.day === 1 && G.tut === TUT.length - 2 && !G.customers.length) {
      spawnCustomer();
      G.spawnT = 6;
    }
    if (G.tut >= TUT.length) { ftext('HAZIRSIN USTA!', W / 2, 120, P.au0, { sc: 2, life: 2 }); flash(.18, '#ffe9a0'); }
  }
}
/* Ogreticinin karartma yumusakligi: adim degisince hizlica oturur. */
var TUTFX = { x: 0, y: 0, w: 0, h: 0, ilk: true, karart: 0 };

function tutHedefKutu() {
  if (G.tut < 0 || G.tut >= TUT.length) return null;
  var step = TUT[G.tut];

  /* Depo adimi: kutu acikken tiklanacak yer PANELDIR, istasyon degil.
     Panel kutunun solunda aciliyor; isareti oraya tasi. */
  if (step.st === 'crate' && G.crate.open) {
    var r = cratePanelRect();
    return { x: r[0] - 3, y: r[1] - 3, w: r[2] + 6, h: r[3] + 6,
             ok: [r[0] + r[2] / 2, r[1] - 5], panel: true };
  }
  if (step.st) {
    var s = ST[step.st];
    return { x: s.x - 4, y: s.y - 4, w: s.w + 8, h: s.h + 8, ok: [s.x + s.w / 2, s.y - 6] };
  }

  /* Son adim "Paralari topla": hedef PARADIR, musteri degil.
     Para yuvarlak oldugu icin cerceve de yuvarlak olsun. */
  if (step.para) {
    if (G.coins.length) {
      var co = G.coins[0];
      return { x: co.x - 11, y: co.y - 11, w: 22, h: 22, ok: [co.x, co.y - 12], yuvarlak: true };
    }
    return null;                       /* para yoksa hic karartma yapma */
  }

  /* geri kalan: bekleyen musteri */
  for (var i = 0; i < G.customers.length; i++) {
    var c = G.customers[i];
    if (c.state === 'wait') return { x: c.x - 20, y: c.y - 58, w: 40, h: 62, ok: [c.x, c.y - 60] };
  }
  return null;
}

function drawTut(t) {
  if (G.tut >= TUT.length) { TUTFX.ilk = true; TUTFX.karart = 0; return; }
  var step = TUT[G.tut];
  var kutu = tutHedefKutu();

  /* --- delikli karartma: hedef disinda kalan her sey koyulasir --- */
  if (kutu) {
    /* kutuyu yumusakca takip et; adim atlayinca zipl3amasin */
    if (TUTFX.ilk) {
      TUTFX.x = kutu.x; TUTFX.y = kutu.y; TUTFX.w = kutu.w; TUTFX.h = kutu.h; TUTFX.ilk = false;
    } else {
      var k = 0.22;
      TUTFX.x += (kutu.x - TUTFX.x) * k; TUTFX.y += (kutu.y - TUTFX.y) * k;
      TUTFX.w += (kutu.w - TUTFX.w) * k; TUTFX.h += (kutu.h - TUTFX.h) * k;
    }
    TUTFX.karart = Math.min(1, TUTFX.karart + 0.04);

    var hx = Math.round(TUTFX.x), hy = Math.round(TUTFX.y);
    var hw = Math.round(TUTFX.w), hh = Math.round(TUTFX.h);
    /* nefes alan bir hale: delik hafifce buyuyup kuculur */
    var nefes = Math.round(Math.sin(t * 3) * (kutu.yuvarlak ? 1 : 1.5));
    hx -= nefes; hy -= nefes; hw += nefes * 2; hh += nefes * 2;

    /* Delik disini 4 dikdortgenle karart (kompozit gerektirmez, keskin kalir).
       HUD seridi (ust 24px) disarida: oyuncu sureyi ve parayi gormeye devam etsin. */
    var HUDH = 24;
    var a = 0.62 * TUTFX.karart;
    var ust = Math.max(HUDH, hy);
    ctx.globalAlpha = a;
    if (hy > HUDH) fr(0, HUDH, W, hy - HUDH, '#0a0705');            /* ust */
    fr(0, ust + hh, W, Math.max(0, H - ust - hh), '#0a0705');        /* alt */
    fr(0, ust, Math.max(0, hx), Math.max(0, hh - (ust - hy)), '#0a0705');            /* sol */
    fr(hx + hw, ust, Math.max(0, W - hx - hw), Math.max(0, hh - (ust - hy)), '#0a0705'); /* sag */
    ctx.globalAlpha = 1;

    /* delik kenari */
    ctx.globalAlpha = .55 + .30 * Math.sin(t * 5);
    if (kutu.yuvarlak) {
      /* para yuvarlak: cercevesi de yuvarlak olsun */
      ring(hx + hw / 2, hy + hh / 2, Math.round(hw / 2), P.au0);
      ring(hx + hw / 2, hy + hh / 2, Math.round(hw / 2) + 2, P.au2);
    } else {
      rrectOut(hx, hy, hw, hh, 3, P.au0);
    }
    ctx.globalAlpha = 1;
    if (!kutu.yuvarlak) {
      var kl = 4;
      fr(hx, hy, kl, 1, P.au1); fr(hx, hy, 1, kl, P.au1);
      fr(hx + hw - kl, hy, kl, 1, P.au1); fr(hx + hw - 1, hy, 1, kl, P.au1);
      fr(hx, hy + hh - 1, kl, 1, P.au1); fr(hx, hy + hh - kl, 1, kl, P.au1);
      fr(hx + hw - kl, hy + hh - 1, kl, 1, P.au1); fr(hx + hw - 1, hy + hh - kl, 1, kl, P.au1);
    }

    /* --- ok: hedefin ustunde zipliyor --- */
    var bo = Math.sin(t * 6) * 2;
    var ax = Math.round(kutu.ok[0]), ay = Math.round(kutu.ok[1] - 10 + bo);
    for (var kk = 0; kk < 6; kk++) fr(ax - kk, ay + 6 - kk, kk * 2 + 1, 1, kk < 4 ? P.au1 : P.au0);
    fr(ax - 1, ay - 4, 3, 8, P.au1);
    fr(ax - 1, ay - 4, 3, 2, P.au0);
  }

  /* --- talimat karti ---
     Hedef ustteyse kart asagi, hedef asagidaysa kart yukari gider;
     boylece kart hicbir zaman gosterdigi seyin uzerini kapatmaz. */
  var yazi = T(step.s);
  var w2 = textW(yazi) + 30;
  var cy = 28;
  if (kutu) {
    var hedefOrta = kutu.y + kutu.h / 2;
    cy = hedefOrta < H * 0.52 ? (H - VIEW.bot - 46) : (VIEW.top + 28);
    /* depo paneli genis: kart onunla cakismasin */
    if (kutu.panel) cy = H - VIEW.bot - 46;
  }
  ctx.globalAlpha = .40; rrect(W / 2 - w2 / 2 + 1, cy + 2, w2, 17, 4, '#000'); ctx.globalAlpha = 1;
  rrect(W / 2 - w2 / 2, cy, w2, 17, 4, P.ui5);
  rrect(W / 2 - w2 / 2 + 1, cy + 1, w2 - 2, 15, 3, '#3a2c1e');
  rrectOut(W / 2 - w2 / 2, cy, w2, 17, 4, P.au2);
  /* adim numarasi rozeti */
  disc(W / 2 - w2 / 2 + 10, cy + 8, 6, P.au2);
  disc(W / 2 - w2 / 2 + 10, cy + 8, 5, '#5a4020');
  txt('' + (G.tut + 1), W / 2 - w2 / 2 + 10, cy + 5, P.au0, { align: 'c' });
  txt(yazi, W / 2 + 8, cy + 5, P.ui0, { align: 'c' });
  /* ilerleme noktalari */
  var nokta = Math.min(TUT.length, 14);
  for (var d2 = 0; d2 < nokta; d2++) {
    var dx2 = W / 2 - (nokta - 1) * 3 + d2 * 6;
    disc(dx2, cy + 22, 1, d2 < G.tut ? P.ok : (d2 === G.tut ? P.au0 : 'rgba(255,255,255,.22)'));
  }
}

/* ---------------- telefon & motokurye ---------------- */
function phoneReset() {
  G.phone = { state: 'idle', t: 20, ringT: 0, order: null, done: [], beep: 0, kind: 'order' };
  G.courier = { state: 'in', t: 0, x: 0, pay: 0 };
}
/* Bugun moto kuryelere sokaga cikma yasagi var mi? */
function fermanKuryeYasak() {
  if (typeof fermanDunya === 'function' && fermanDunya('kurye')) return true;
  /* Gazete 'telefon hatlari bakimda' dediyse hat GERCEKTEN kapali olmali;
     yoksa gazete bir sey der, oyun baskasini yapar. */
  if (fermanSehri(G) && typeof haberEtki === 'function' && haberEtki('telefonKapali'))
    return true;
  return false;
}
/* Bugun her cagriya cevap ZORUNLU mu? Kacirilan cagri ihlal sayilir. */
function fermanTelefonZorunlu() {
  return typeof fermanDunya === 'function' && fermanDunya('telefon');
}
function phoneActive() {
  return TUN.phoneOn(G) && !(G.moto && G.moto.broken) && !fermanKuryeYasak();
}
function updatePhone(dt) {
  if (!phoneActive()) return;
  var p = G.phone, c = G.courier;
  /* kurye animasyonu */
  var kYavas = TUN.courierYavas(G);       /* yagmurda motor yavas */
  if (c.state === 'leaving') {
    c.t += dt / (1.1 * kYavas);
    c.x = lerp(24, -60, easeIn(clamp(c.t, 0, 1)));
    if (c.t >= 1) { c.state = 'away'; c.t = 0; }
  } else if (c.state === 'away') {
    c.t += dt;
    if (c.t >= TUN.courierTime(G)) {
      c.state = 'back'; c.t = 0; SFX.moto();
      /* şans: Dayı yolda para buluyor */
      if ((G.luck || 0) > 0 && chance(Math.min(.34, G.luck * .055))) {
        var found = Math.round(rnd(LUCK_FIND_MIN, LUCK_FIND_MAX) / 10) * 10;
        c.pay += found;
        G.luckMsg = 3.0; G.luckAmt = found;
        G.stats.found = (G.stats.found || 0) + found;
        SFX.coin();
      }
      /* para */
      kasaEkle(c.pay);
      G.stat.earned += c.pay;
      ftext('+$' + fmtMoney(c.pay), 40, 150, P.au0, { sc: 2, life: 1.6 });
      SFX.cash(); flash(.12, '#ffe9a0');
      c.pay = 0;
    }
  } else if (c.state === 'back') {
    c.t += dt / (1.1 * kYavas);
    c.x = lerp(-60, 24, easeOut(clamp(c.t, 0, 1)));
    if (c.t >= 1) { c.state = 'in'; c.x = 0; }
  }

  if (p.state === 'idle') {
    if (c.state !== 'in') return;
    p.t -= dt;
    if (p.t <= 0 && G.timeLeft > 25) {
      p.kind = 'order';
      p.state = 'ring'; p.ringT = 0; p.beep = 0;
    }
  } else if (p.state === 'ring') {
    p.ringT += dt;
    p.beep -= dt;
    if (p.beep <= 0) { p.beep = 1.1; SFX.phone(); }
    if (p.ringT > 11) {
      /* 'Her siparise cevap verilecek' fermani varsa cevapsiz cagri ihlal.
         Gozcuye bagli DEGIL: kayit devletin santralinde tutuluyor. */
      if (fermanTelefonZorunlu() && G.ferman && !G.ferman.kapandi) {
        var tf = null;
        for (var ti = 0; ti < G.ferman.liste.length; ti++)
          if (G.ferman.liste[ti].id === 'telefon') tf = G.ferman.liste[ti];
        fermanIhlal(tf, ST.phone.x + 30, ST.phone.y + 10, 'telefon');
      }
      p.state = 'idle'; p.t = TUN.phoneGap(G) * .6;
    }
  }
}
function phoneClick() {
  var p = G.phone;
  if (!phoneActive()) { SFX.bad(); say('Telefon hattı yok — dükkândan al'); return; }
  if (p.state === 'ring') {
    p.state = 'order';
    p.order = makePhoneOrder(G);
    p.done = p.order.map(function () { return false; });
    SFX.ding();
    say('Paket sipariş alındı — Dayıya ver!');
    return;
  }
  if (p.state === 'order') { say('Ürünleri Dayıya ver'); return; }
  say('Telefon sessiz');
}
/* elindeki ürünü kuryeye (Dayıya) ver */
function giveToCourier() {
  /* Yanmis durum satilmaz: kuryeye de verilemez, yalniz cope gider. */
  if (G.hand && G.hand.kind === 'wrap' && G.hand.burnt) {
    SFX.bad(); say('Yanmış dürüm satılmaz — çöpe at'); return;
  }
  var p = G.phone;
  if (p.state !== 'order' || !G.hand) return false;
  if (G.hand.kind === 'wrap' && G.hand.state === 'rolled' && !G.hand.paper) {
    SFX.bad(); say('Önce kâğıtla — kağıtsız dürüm verilmez');
    return false;
  }
  if (G.hand.kind === 'wrap' && TUN.grillOn(G) && !G.hand.grilled) {
    SFX.bad(); say('Izgarasız dürüm olmaz — önce ızgaraya at');
    return false;
  }
  var it = G.hand, idx = -1;
  for (var pass = 0; pass < 2 && idx < 0; pass++) {
    for (var i = 0; i < p.order.length; i++) {
      if (p.done[i]) continue;
      var o = p.order[i];
      if (o.kind !== it.kind) continue;
      if (it.kind === 'drink' && o.type !== it.type) continue;
      if (pass === 0 && it.kind === 'wrap' && (o.sauce || null) !== (it.sauce || null)) continue;
      idx = i; break;
    }
  }
  if (idx < 0) return false;
  /* PAKET SIPARISI EKSIK URUN KABUL ETMEZ.
     Tezgahtaki musteri eksigi indirimli alir ama paket kutulanip yola
     cikiyor: yarim dürüm gonderilirse geri donusu yok. Tamamla, sonra ver. */
  if (G.hand.kind === 'wrap' || G.hand.kind === 'plate') {
    /* "tam" olcusu oyunun kendi tanimi: wrapFull / plateFull.
       (quality alani sarilirken donduruluyor, sonradan degismiyor.) */
    var tam = G.hand.kind === 'plate' ? plateFull(G.hand) : wrapFull(G.hand);
    if (!tam) {
      SFX.bad();
      ftext(T('EKSİK — PAKETE OLMAZ'), ST.uncle.x + 24, 120, P.bad, { life: 1.5 });
      say('Paket siparişi eksik ürün kabul etmez — tamamla');
      return false;
    }
  }
  var ord = p.order[idx];
  var sauceOk = !ord.sauce || it.sauce === ord.sauce;
  var price = it.kind === 'wrap'
    ? itemPrice({ kind: 'wrap', grilled: it.grilled, sauce: sauceOk ? ord.sauce : null }, G)
    : itemPrice(it, G);
  if (it.kind === 'wrap' || it.kind === 'plate') {
    var q = it.quality === undefined ? (it.kind === 'plate' ? plateQuality(it) : wrapQuality(it)) : it.quality;
    price = Math.max(2, Math.round(price * q));
    if (it.kind === 'plate') G.stat.isk++; else G.stat.wraps++;
  } else if (it.kind === 'drink') G.stat.drinks++;
  else if (it.kind === 'sweet') G.stat.sweets++;
  else G.stat.boxes++;
  if (!sauceOk) {
    price = Math.max(2, Math.round(price * .65));
    ftext('SOS YANLIŞ!', ST.uncle.x + 24, 126, P.bad, { life: 1.3 });
    SFX.bad();
  }
  G.totalSold++;
  G.courier.pay += Math.round(price * PHONE_MUL);
  p.done[idx] = true;
  G.hand = null;
  SFX.serve();
  burst(ST.uncle.x + 24, 150, 8, [P.au0, P.au1, '#fff'], { spMax: 60, up: 24, sz: 2 });
  var all = true;
  for (var d = 0; d < p.done.length; d++) if (!p.done[d]) all = false;
  if (all) {
    p.state = 'idle'; p.t = TUN.phoneGap(G) * (isRain() ? .5 : 1);
    G.courier.state = 'leaving'; G.courier.t = 0; G.courier.x = 24;
    G.stats.phone = (G.stats.phone || 0) + 1;
    SFX.bell(); SFX.moto();
    ftext('KURYE YOLDA!', 60, 130, P.au0, { life: 1.6 });
  }
  return true;
}
/* Ferman yuzunden kapatilan telefon: gercek telefonun silueti solgun
   tonda, uzerinde capraz muhur bandi ve damga. Jenerik bir kutu degil —
   oyuncu neyin kapatildigini gorsun. */
function drawPhoneMuhurlu(t) {
  var s = ST.phone, x = s.x, y = s.y;
  /* govde */
  fr(x + 2, y + 6, 20, 22, '#24262a');
  fr(x + 3, y + 6, 18, 21, '#3a3d42');
  hl(x + 3, y + 6, 18, '#4e5258');
  /* tuslar — soluk */
  for (var r = 0; r < 3; r++) for (var c = 0; c < 3; c++) {
    fr(x + 6 + c * 4, y + 12 + r * 4, 3, 3, '#5c6167');
    px(x + 6 + c * 4, y + 12 + r * 4, '#787e85');
  }
  /* ahize — kirmizisi cekilmis */
  var hy = y + 2;
  fr(x, hy, 24, 5, '#1b1d21');
  fr(x + 1, hy, 22, 4, '#6a4a46');
  hl(x + 2, hy, 20, '#825a55');
  fr(x, hy, 4, 6, '#6a4a46'); fr(x + 20, hy, 4, 6, '#6a4a46');
  /* kordon */
  for (var k = 0; k < 6; k++) px(x + 12 + Math.round(Math.sin(k * 1.2) * 2), hy + 6 + k, '#1b1d21');

  /* capraz muhur bandi */
  ctx.save();
  ctx.translate(x + 12, y + 18);
  ctx.rotate(-0.42);
  fr(-17, -4, 34, 8, '#6e1a12');
  fr(-17, -4, 34, 7, '#b83228');
  hl(-16, -4, 32, '#d8493a');
  ctx.restore();
  /* mum damgasi */
  disc(x + 20, y + 26, 3, '#6e1a12');
  disc(x + 20, y + 26, 2, '#d8493a');
  px(x + 20, y + 25, '#ffb0a0');
}

/* ---------------- DEMIRKENT: ferman arayuzu ---------------- */
/* Duvardaki ferman kagidinin yeri (sag ust, vitrinin yaninda) */
function fermanKagitKutu() { return [W - 34, 34, 26, 30]; }
/* Denetim lambasi: vitrin cercevesi ile ferman kagidi arasindaki bos duvar.
   Pencere 150..422, kagit 446..472 -> 426..442 bos. */
function denetimLambaKutu() { return [426, 34, 16, 18]; }

/* Gozcunun bakisinin lambadaki karsiligi:
   0 = sonuk, 0..1 arasi = kehribar (isiniyor), 1 = kirmizi (izleniyor).
   gozcuBakiyor() esigi bakT>.35 oldugu icin kehribar evresi oyuncuya
   tepki verecek yarim saniye birakir — anlik ceza adaletsiz olurdu. */
function denetimSeviye() {
  var Z = G.gozcu;
  if (!Z || Z.state === 'yuru') return 0;
  if (Z.state === 'sorgu') return 1;
  return clamp(Z.bakT / 0.35, 0, 1);
}
function drawDenetimLambasi(t) {
  if (!G.ferman) return;
  var k = denetimLambaKutu(), x = k[0], y = k[1];
  var s = denetimSeviye();
  var yaniyor = s >= 1, isiniyor = s > 0 && s < 1;
  var pz = .5 + .5 * Math.sin(t * (yaniyor ? 7 : 3));

  /* duvara vidali braket */
  fr(x + 6, y, 4, 4, '#3a3e44');
  fr(x + 6, y, 3, 3, '#5a5e64');
  /* govde: konik mahfaza */
  fr(x + 2, y + 4, 12, 3, '#2e3238');
  fr(x + 1, y + 6, 14, 7, '#3a3e44');
  fr(x + 1, y + 6, 13, 6, '#4a4e54');
  hl(x + 2, y + 6, 12, '#61666d');
  /* alt kenar ve tel kafes */
  fr(x + 1, y + 12, 14, 2, '#25282d');
  for (var i = 0; i < 4; i++) vl(x + 3 + i * 3, y + 7, 5, '#2a2d32');

  /* mercek */
  var mr = yaniyor ? '#ff4132' : (isiniyor ? '#d8922a' : '#5a2620');
  var ic = yaniyor ? '#ffd0c0' : (isiniyor ? '#f0d090' : '#3e1a16');
  if (s > 0) {
    ctx.globalAlpha = (isiniyor ? .18 : .30) + .22 * pz * s;
    disc(x + 7, y + 9, 8 + (yaniyor ? pz * 3 : 0), yaniyor ? '#ff5a44' : '#e0a03a');
    ctx.globalAlpha = 1;
  }
  fr(x + 3, y + 7, 9, 5, mr);
  fr(x + 4, y + 8, 7, 3, ic);
  if (s > 0) { ctx.globalAlpha = .5 + .5 * pz; fr(x + 5, y + 8, 4, 2, '#ffffff'); ctx.globalAlpha = 1; }

  /* izleniyorken duvara vuran kirmizi leke */
  if (yaniyor) {
    ctx.globalAlpha = .16 + .10 * pz;
    fr(x - 10, y + 2, 34, 20, '#c8321e');
    ctx.globalAlpha = 1;
  }
}
function drawFerman(t) {
  var F = G.ferman;
  if (!F) return;

  /* --- HER musteride cevirme damgasi ---
     Eskiden X yalniz yasakli musteride cikiyordu: oyuncu kimin yasak
     oldugunu dusunmeden damgaya basiyordu. Artik damga herkeste ayni ve
     NOTR gorunur (kursuni muhur); yasakliyi fermandan sen bulacaksin.
     Uzerine gelince kirmizilasir — basilacagi belli olsun diye. */
  for (var i = 0; i < G.customers.length; i++) {
    var c = G.customers[i];
    if (c.state !== 'wait') continue;
    var k = fermanXKutu(c);
    var ust = inRect(IN.x, IN.y, k[0] - 3, k[1] - 3, k[2] + 6, k[3] + 6);
    if (ust) {
      ctx.globalAlpha = .30 + .25 * (.5 + .5 * Math.sin(t * 5));
      disc(k[0] + 7, k[1] + 7, 9, '#e2483a');
      ctx.globalAlpha = 1;
    }
    rrect(k[0], k[1], 14, 14, 3, ust ? '#8e1c14' : '#2f3238');
    rrect(k[0] + 1, k[1] + 1, 12, 12, 3, ust ? '#e2483a' : '#585d66');
    hl(k[0] + 2, k[1] + 1, 10, ust ? '#ff7a68' : '#787e88');
    for (var d = 0; d < 8; d++) {
      px(k[0] + 3 + d, k[1] + 3 + d, '#e8e4dc');
      px(k[0] + 10 - d, k[1] + 3 + d, '#e8e4dc');
    }
  }

  /* --- sokakta sorgulanan musterinin ustunde unlem --- */
  for (var si = 0; si < G.customers.length; si++) {
    var sc = G.customers[si];
    if (sc.state !== 'sorgu') continue;
    var uy = sc.y - 62 + Math.round(Math.sin(t * 9));
    ctx.globalAlpha = .32; disc(sc.x, uy + 4, 8, '#e2483a'); ctx.globalAlpha = 1;
    fr(sc.x - 1, uy, 3, 6, '#e2483a');
    fr(sc.x - 1, uy + 8, 3, 3, '#e2483a');
  }

  /* --- duvardaki denetim lambasi --- */
  drawDenetimLambasi(t);

  /* --- duvardaki ferman kagidi --- */
  var kk = fermanKagitKutu();
  ctx.globalAlpha = .28; fr(kk[0] + 1, kk[1] + 2, kk[2], kk[3], '#000'); ctx.globalAlpha = 1;
  fr(kk[0], kk[1], kk[2], kk[3], '#cfc7ae');
  fr(kk[0], kk[1], kk[2] - 1, kk[3] - 1, '#f2ecd8');
  hl(kk[0], kk[1], kk[2] - 1, '#fffaea');
  fr(kk[0] + 3, kk[1] + 3, kk[2] - 7, 3, '#b83228');       /* rejim seridi */
  /* Ceza cetelesi yazi satirlarinin yerini alir: sinir 10 olunca tek sira
     51px tutuyordu, kagit 26px. Ustune tasirsa mobilde ust kirpmaya da
     denk geliyordu — cetele artik kagidin ICINDE, 5+5 iki sira. */
  var ceteleVar = F.ceza > 0;
  for (var l = ceteleVar ? 2 : 0; l < 4; l++)
    hl(kk[0] + 3, kk[1] + 9 + l * 4, kk[2] - 8, '#9a927e');
  disc(kk[0] + kk[2] - 7, kk[1] + kk[3] - 7, 3, '#b83228');  /* muhur */
  disc(kk[0] + kk[2] - 7, kk[1] + kk[3] - 7, 2, '#d8493a');
  if (ceteleVar) {
    var sut = Math.ceil(FERMAN_CEZA_SINIR / 2);
    for (var z = 0; z < FERMAN_CEZA_SINIR; z++)
      fr(kk[0] + 3 + (z % sut) * 4, kk[1] + 8 + Math.floor(z / sut) * 4, 3, 2,
         z < F.ceza ? '#e2483a' : 'rgba(0,0,0,.28)');
  }
  if (inRect(IN.x, IN.y, kk[0], kk[1], kk[2], kk[3])) {
    ctx.globalAlpha = .5 + .3 * Math.sin(t * 6);
    rrectOut(kk[0] - 1, kk[1] - 1, kk[2] + 2, kk[3] + 2, 2, P.au0);
    ctx.globalAlpha = 1;
  }

}
/* Buyuk ferman kagidi: MODAL, drawPlay'in en sonunda cizilir ki
   tezgahin ve istasyonlarin uzerinde kalsin. */
function drawFermanKagit(t) {
  var F = G.ferman;
  if (!F) return;
  if (F.kagit > 0.01) {
    var a = easeOut(F.kagit);
    ctx.globalAlpha = .62 * a; fr(0, 0, W, H, '#0d0a08'); ctx.globalAlpha = 1;
    var pw = 250, ph = 34 + F.liste.length * 22 + 34;
    var pxx = Math.round(W / 2 - pw / 2);
    var pyy = Math.round(lerp(-ph, VIEW.top + (H - VIEW.top - VIEW.bot - ph) / 2, a));
    /* kagit govdesi */
    ctx.globalAlpha = .40; fr(pxx + 3, pyy + 4, pw, ph, '#000'); ctx.globalAlpha = 1;
    fr(pxx, pyy, pw, ph, '#cfc7ae');
    fr(pxx + 1, pyy + 1, pw - 2, ph - 2, '#f4eeda');
    hl(pxx + 1, pyy + 1, pw - 2, '#fffaea');
    /* ust serit */
    fr(pxx + 6, pyy + 6, pw - 12, 14, '#b83228');
    hl(pxx + 6, pyy + 6, pw - 12, '#d8493a');
    txt(T('BUGÜNKÜ FERMAN'), pxx + pw / 2, pyy + 9, '#fff2e0', { align: 'c' });
    /* maddeler */
    for (var m = 0; m < F.liste.length; m++) {
      var my2 = pyy + 28 + m * 22;
      fr(pxx + 10, my2, pw - 20, 18, '#e6dfc6');
      rc(pxx + 10, my2, pw - 20, 18, '#b0a88e');
      /* madde numarasi */
      fr(pxx + 13, my2 + 3, 12, 12, '#b83228');
      txt('' + (m + 1), pxx + 19, my2 + 5, '#fff2e0', { align: 'c' });
      txt(T(F.liste[m].metin), pxx + 30, my2 + 5, '#3a3226');
    }
    /* alt: ceza durumu + kapat */
    var ay2 = pyy + ph - 26;
    txt(T('İhlal: ') + F.ceza + '/' + FERMAN_CEZA_SINIR + T('  —  ceza $') + FERMAN_CEZA_PARA,
        pxx + pw / 2, ay2, F.ceza > 0 ? '#a83a2a' : '#5a5445', { align: 'c' });
    if (button(pxx + pw / 2 - 34, ay2 + 10, 68, 14, 'KAPAT', P.red1, true)) {
      F.kagitT = 0; SFX.uiBack();
    }
  }
}
/* Ferman kagidina / X rozetine tiklama. true donerse tiklama yutuldu. */
function fermanTik(mx, my) {
  var F = G.ferman;
  if (!F) return false;
  if (F.kagit > 0.01) {
    /* kagit acikken disina basmak da kapatir */
    if (!inRect(mx, my, W / 2 - 130, 0, 260, H)) { F.kagitT = 0; SFX.uiBack(); }
    return true;
  }
  var kk = fermanKagitKutu();
  if (inRect(mx, my, kk[0], kk[1], kk[2], kk[3])) {
    F.kagitT = 1; SFX.ui(); return true;
  }
  for (var i = 0; i < G.customers.length; i++) {
    var c = G.customers[i];
    if (c.state !== 'wait') continue;
    var k = fermanXKutu(c);
    if (inRect(mx, my, k[0] - 3, k[1] - 3, k[2] + 6, k[3] + 6)) {
      fermanGonder(c); return true;
    }
  }
  return false;
}
function updateFerman(dt) {
  var F = G.ferman;
  if (!F) return;
  F.kagit = approach(F.kagit, F.kagitT, dt * 5.5);
}
/* duvardaki telefon */
function drawPhone(t) {
  /* Ferman yuzunden kapaliysa telefon YOK OLMAZ: duvarda muhurlu durur,
     oyuncu neden calismadigini gorsun. Motor arizasi eski davranisinda. */
  if (!phoneActive()) {
    if (fermanKuryeYasak() && TUN.phoneOn(G)) drawPhoneMuhurlu(t);
    return;
  }
  var s = ST.phone, p = G.phone;
  var sh = p.state === 'ring' ? Math.round(Math.sin(t * 40) * 1.5) : 0;
  var x = s.x + sh, y = s.y;
  /* gövde */
  fr(x + 2, y + 6, 20, 22, '#2b2f36');
  fr(x + 3, y + 6, 18, 21, '#3f454e');
  hl(x + 3, y + 6, 18, '#5c646e');
  /* tuşlar */
  for (var r = 0; r < 3; r++) for (var c = 0; c < 3; c++) {
    fr(x + 6 + c * 4, y + 12 + r * 4, 3, 3, '#8a929b');
    px(x + 6 + c * 4, y + 12 + r * 4, '#c6ccd2');
  }
  /* ahize */
  var hy = y + (p.state === 'ring' ? 1 : 2) + sh;
  fr(x, hy, 24, 5, '#1f2329');
  fr(x + 1, hy, 22, 4, '#c0281c');
  hl(x + 2, hy, 20, '#e2483a');
  fr(x, hy, 4, 6, '#c0281c'); fr(x + 20, hy, 4, 6, '#c0281c');
  hl(x, hy, 4, '#e2483a'); hl(x + 20, hy, 4, '#e2483a');
  /* kordon */
  for (var k = 0; k < 6; k++) px(x + 12 + Math.round(Math.sin(k * 1.2) * 2), hy + 6 + k, '#1f2329');
  if (p.state === 'ring') {
    /* ses dalgaları */
    ctx.globalAlpha = .5 + .4 * Math.sin(t * 14);
    for (var w2 = 0; w2 < 3; w2++) {
      var rr = 6 + w2 * 4 + (t * 14 % 4);
      px(x + 26 + rr, y + 12 - w2 * 2, P.au0);
      px(x + 26 + rr, y + 12 + w2 * 2, P.au0);
      px(x + 25 + rr, y + 12, P.au0);
    }
    ctx.globalAlpha = 1;
    var bo = Math.sin(t * 8) * 2;
    txt('!', x + 28, y - 2 + bo, P.bad, { align: 'c', outline: true, sc: 2 });
    ctx.globalAlpha = .3 + .3 * Math.sin(t * 8);
    rrectOut(s.x - 2, s.y - 2, s.w + 4, s.h + 4, 3, P.au0);
    ctx.globalAlpha = 1;
  }
  /* sipariş fişi */
  if (p.state === 'order') {
    var n = p.order.length;
    var pw = 14 + n * 13, px0 = 4, py0 = s.y + s.h + 2;
    ctx.globalAlpha = .35; rrect(px0 + 1, py0 + 2, pw, 26, 2, '#000'); ctx.globalAlpha = 1;
    rrect(px0, py0, pw, 26, 2, '#efe6c8');
    rrect(px0 + 1, py0 + 1, pw - 2, 24, 2, '#fdf6de');
    rrectOut(px0, py0, pw, 26, 2, '#b09a68');
    /* delikli üst kenar */
    for (var d2 = 0; d2 < pw - 4; d2 += 4) px(px0 + 2 + d2, py0 + 1, '#d8cba8');
    txt('PAKET', px0 + 3, py0 + 3, '#a03a2a');
    for (var i2 = 0; i2 < n; i2++) {
      var ix = px0 + 10 + i2 * 13, iy = py0 + 17;
      if (p.done[i2]) ctx.globalAlpha = .3;
      var oi = p.order[i2];
      var ic = oi.kind === 'wrap' ? 'wrap' : (oi.kind === 'plate' ? 'iskender' : (oi.kind === 'drink' ? oi.type : (oi.kind === 'sweet' ? 'sweet' : 'fbox')));
      icon(ic, ix, iy, t);
      if (oi.kind === 'wrap' && oi.sauce) {
        disc(ix + 6, iy - 6, 4, '#2a2018');
        disc(ix + 6, iy - 6, 3, oi.sauce === 'hot' ? '#c0281c' : '#e6dfc8');
        px(ix + 6, iy - 9, oi.sauce === 'hot' ? '#5a8a2a' : '#a89a78');
      }
      ctx.globalAlpha = 1;
      if (p.done[i2]) drawCheck(ix, iy, P.ok);
    }
    /* dayıya ok */
    if (!G.courier || G.courier.state === 'in') {
      ctx.globalAlpha = .4 + .3 * Math.sin(t * 5);
      var ay = py0 + 30 + Math.sin(t * 5) * 2;
      fr(px0 + 20, ay, 3, 6, P.au0);
      px(px0 + 19, ay + 5, P.au0); px(px0 + 23, ay + 5, P.au0);
      px(px0 + 20, ay + 7, P.au0); px(px0 + 22, ay + 7, P.au0);
      px(px0 + 21, ay + 8, P.au0);
      ctx.globalAlpha = 1;
    }
  }
}
/* motokurye */
function drawCourier(t) {
  var c = G.courier;
  if (!c || c.state === 'in') return;
  if (c.state === 'away') {
    /* yolda göstergesi */
    var bx = 6, by = 150;
    ctx.globalAlpha = .85;
    rrect(bx, by, 56, 16, 3, 'rgba(20,14,12,.8)');
    ctx.globalAlpha = 1;
    rrectOut(bx, by, 56, 16, 3, P.ui4);
    drawScooter(bx + 12, by + 10, t, .6);
    txt('YOLDA', bx + 34, by + 5, P.au0, { align: 'c' });
    var pr = 1 - clamp(c.t / TUN.courierTime(G), 0, 1);
    bar(bx + 2, by + 13, 52, 3, 1 - pr, P.ok);
    return;
  }
  drawScooter(c.x, 236, t, 1);
}
function drawScooter(x, y, t, sc) {
  var wob = Math.round(Math.sin(t * 22) * .6);
  ctx.save();
  if (sc !== 1) { ctx.translate(x, y); ctx.scale(sc, sc); ctx.translate(-x, -y); }
  /* gölge */
  ctx.globalAlpha = .28; ell(x, y + 6, 16, 3, '#000'); ctx.globalAlpha = 1;
  /* tekerler */
  disc(x - 10, y + 2, 4, '#1f2329'); disc(x - 10, y + 2, 2, '#5c646e');
  disc(x + 10, y + 2, 4, '#1f2329'); disc(x + 10, y + 2, 2, '#5c646e');
  /* gövde */
  rrect(x - 12, y - 4, 24, 7, 3, '#8e1c14');
  rrect(x - 12, y - 5, 24, 7, 3, '#c0281c');
  hl(x - 9, y - 5, 18, '#e2483a');
  /* ön panel + far */
  fr(x + 8, y - 12, 5, 9, '#c0281c');
  fr(x + 9, y - 12, 3, 8, '#e2483a');
  fr(x + 12, y - 10, 2, 3, P.au0);
  /* gidon */
  fr(x + 7, y - 14, 8, 2, '#3f454e');
  /* kutu (arka) */
  fr(x - 16, y - 12, 9, 8, '#3f6ba8');
  fr(x - 15, y - 12, 7, 7, '#4f81c4');
  hl(x - 15, y - 12, 7, '#6b9ad8');
  /* dayı */
  var s = SKINS[0];
  fr(x - 5, y - 16, 9, 12, '#f4efe2');
  fr(x - 5, y - 16, 4, 12, P.red1);
  ell(x, y - 20 + wob, 5, 5, s[1]);
  ell(x, y - 21 + wob, 5, 4, s[0]);
  fr(x - 5, y - 25 + wob, 11, 5, P.red2);   /* fes */
  fr(x - 4, y - 25 + wob, 9, 4, P.red1);
  fr(x - 3, y - 19 + wob, 7, 2, '#f4f4f0'); /* bıyık */
  /* egzoz dumanı */
  if (chance(.35)) smoke(x - 16, y + 2, 1, 'rgba(120,110,100,.5)');
  ctx.restore();
}

/* ---------------- HAVA DURUMU ---------------- */
function rollWeather() {
  /* Yagmur olasiligi SEHRE gore: Londra'da sik, Dubai'de yok gibi.
     Sehir profili yoksa genel RAIN_CHANCE. */
  var ihtimal = RAIN_CHANCE;
  if (typeof sehirTema === 'function') {
    var tm = sehirTema();
    if (tm && tm.yagmur !== undefined) ihtimal = tm.yagmur;
  }
  var karO = 0, sicakO = 0;
  if (typeof sehirTema === 'function') {
    var tm2 = sehirTema();
    if (tm2) { karO = tm2.kar || 0; sicakO = tm2.sicak || 0; }
  }
  /* Tek zar: once kar, sonra sicak, sonra yagmur. Ayri zarlar atmak
     iki havanin ayni gune dusmesine yol acardi. */
  G.weather = 'sun';
  if (G.day >= 3) {
    var z = Math.random();
    if (z < karO) G.weather = 'kar';
    else if (z < karO + sicakO) G.weather = 'sicak';
    else if (z < karO + sicakO + ihtimal) G.weather = 'rain';
  }
  G.rainT = 0;
  G.camDamla = [];
  G.kar = [];
}
function isRain() { return G.weather === 'rain'; }
/* Mac dalgasi SU AN suruyor mu: gunun MAC_BAS..MAC_BIT dilimi. */
function macDalgada() {
  if (!G.macGun || !G.cfg) return false;
  var gecen = 1 - clamp(G.timeLeft / G.cfg.len, 0, 1);
  return gecen >= MAC_BAS && gecen <= MAC_BIT;
}
function isKar() { return G.weather === 'kar'; }
function isSicak() { return G.weather === 'sicak'; }
/* Disarisi soguk mu: kar ve yagmur icerideki tonu soguturuyor. */
function isSoguk() { return G.weather === 'kar' || G.weather === 'rain'; }
/* --- kar taneleri: camin ARKASINDA, sokakta duser --- */
function karGuncelle(dt) {
  if (!G.kar) G.kar = [];
  var Gl = LAY.glass, K = G.kar;
  /* 46 tane 264x92 pencerede cok seyrek kaliyordu, 1x olcekte kar
     yagdigi anlasilmiyordu. */
  if (K.length < 78 && chance(dt * 46)) {
    K.push({ x: Gl.x + rnd(0, Gl.w), y: Gl.y - 2,
             v: rnd(7, 16), s: rnd(-5, 5), f: rnd(0, 6.28),
             r: chance(.34) ? 2 : 1 });
  }
  for (var i = K.length - 1; i >= 0; i--) {
    var k = K[i];
    k.f += dt * 2.2;
    k.y += k.v * dt;
    k.x += Math.sin(k.f) * k.s * dt;      /* savrularak duser */
    if (k.y > Gl.y + Gl.h - 1) K.splice(i, 1);
  }
}

function updateWeather(dt) {
  if (isKar()) { karGuncelle(dt); return; }
  if (G.kar && G.kar.length) G.kar.length = 0;
  if (!isRain()) {
    if (G.camDamla && G.camDamla.length) G.camDamla.length = 0;
    return;
  }
  G.rainT -= dt;
  /* gercek kayit calmiyorsa gok gurultusunu sentezle destekle */
  if (G.rainT <= 0) {
    G.rainT = rnd(7, 14);
    if (!(typeof SND !== 'undefined' && SND.rain && (SND.rain.buf || SND.rain.el))) SFX.rain();
  }
  /* Yagmur yalniz camda: dukkanin icine damla dusmez.
     Damlalar cama carpar, birikir, agirlasinca suzulur. */
  camDamlaGuncelle(dt);
}

/* --- cama carpan ve suzulen damlalar --- */
function camDamlaGuncelle(dt) {
  if (!G.camDamla) G.camDamla = [];
  var Gl = LAY.glass;
  var D = G.camDamla;

  /* yeni damla: cama carpma */
  var kac = 2;
  for (var n = 0; n < kac; n++) {
    if (D.length < 58 && chance(dt * 12)) {
      D.push({
        x: Gl.x + rnd(3, Gl.w - 3),
        y: Gl.y + rnd(2, Gl.h * .55),
        r: rnd(.8, 2.1),          /* yaricap: buyugu once akar */
        v: 0,                     /* dikey hiz */
        bekle: rnd(.15, 1.6),     /* akmaya baslamadan once yapisik durur */
        iz: 0,                    /* arkasinda biraktigi iz uzunlugu */
        carp: 1                   /* carpma halkasi */
      });
    }
  }

  for (var i = D.length - 1; i >= 0; i--) {
    var d = D[i];
    if (d.carp > 0) d.carp = Math.max(0, d.carp - dt * 6);
    if (d.bekle > 0) { d.bekle -= dt * (d.r * .8); continue; }
    /* buyuk damla daha hizli akar, akarken hizlanir */
    d.v += dt * (10 + d.r * 26);
    d.y += d.v * dt;
    d.iz = Math.min(26, d.iz + d.v * dt * 1.5);
    /* akarken kucultur: iz birakiyor */
    d.r = Math.max(.5, d.r - dt * .22);
    if (d.y > Gl.y + Gl.h - 2) D.splice(i, 1);
  }
}
function drawWeather(t) {
  /* Havanin ic mekana etkisi yalniz TON. Damla ve kar taneleri
     burada cizilmez; onlar camin icinde kalir. */
  if (isRain()) {
    ctx.globalAlpha = .10; fr(0, 0, W, LAY.floorY, '#2a4a7a'); ctx.globalAlpha = 1;
  } else if (isKar()) {
    ctx.globalAlpha = .13; fr(0, 0, W, LAY.floorY, '#8fb4dc'); ctx.globalAlpha = 1;
  } else if (isSicak()) {
    ctx.globalAlpha = .09; fr(0, 0, W, LAY.floorY, '#ffb040'); ctx.globalAlpha = 1;
  }
}

/* Camda kar: drawCamDamla ile ayni yerden, cam kirpmasinin icinde. */
function drawKar(t) {
  if (!isKar() || !G.kar) return;
  var K = G.kar;
  for (var i = 0; i < K.length; i++) {
    var k = K[i], x = Math.round(k.x), y = Math.round(k.y);
    if (k.r > 1) {
      fr(x, y, 2, 2, '#ffffff');
    } else {
      ctx.globalAlpha = .88; px(x, y, '#f2f8ff'); ctx.globalAlpha = 1;
    }
  }
  /* cam kenarinda buzlanma: kose kose birikir */
  var Gl = LAY.glass;
  ctx.globalAlpha = .34;
  for (var b = 0; b < Gl.w; b += 2) {
    var h = 3 + Math.round(Math.sin(b * .21) * 2 + Math.sin(b * .07) * 2.5);
    if (h > 0) fr(Gl.x + b, Gl.y, 2, h, '#e8f3ff');
    var h2 = 2 + Math.round(Math.sin(b * .17 + 2) * 1.8);
    if (h2 > 0) fr(Gl.x + b, Gl.y + Gl.h - h2, 2, h2, '#e8f3ff');
  }
  ctx.globalAlpha = 1;
}

/* Cam uzerindeki damlalar. drawStreet icinden, cam kirpmasinin
   ICINDE cagrilir; boylece dukkanin icine tasmaz. */
function drawCamDamla(t) {
  if (!isRain() || !G.camDamla) return;
  var D = G.camDamla;
  for (var i = 0; i < D.length; i++) {
    var d = D[i];
    var x = Math.round(d.x), y = Math.round(d.y);

    /* 1) suzulme izi: damlanin arkasinda kalan ince su yolu */
    if (d.iz > 1) {
      ctx.globalAlpha = .26;
      var iz = Math.round(d.iz);
      fr(x, y - iz, 1, iz, '#cfe4f2');
      ctx.globalAlpha = .16;
      fr(x - 1, y - Math.round(iz * .7), 1, Math.round(iz * .7), '#eaf6ff');
      ctx.globalAlpha = 1;
    }

    /* 2) damlanin govdesi: kucukse tek piksel, buyukse damla bicimi */
    var r = d.r;
    ctx.globalAlpha = .72;
    if (r < 1.1) {
      px(x, y, '#dff0fa');
    } else {
      ell(x, y, Math.round(r), Math.max(1, Math.round(r * 1.25)), '#cfe4f2');
      ctx.globalAlpha = .95;
      px(x, y - Math.round(r * .5), '#ffffff');   /* parlaklik */
      px(x - 1, y, '#eaf6ff');
    }
    ctx.globalAlpha = 1;

    /* 3) carpma halkasi: yeni dusen damlanin sicramasi */
    if (d.carp > 0) {
      ctx.globalAlpha = d.carp * .55;
      ring(x, y, Math.round(1 + (1 - d.carp) * 3), '#eaf6ff');
      ctx.globalAlpha = 1;
    }
  }
}

/* ---------------- ÇÖP & HİJYEN DENETİMİ ---------------- */
function addTrash(v) { G.trash = clamp(G.trash + v, 0, 1.35); }

/* Çöpe atılan şey görünsün: kaynaktan kovaya doğru uçan parçalar.
   "Kabukları oraya atıyoruz" hissi bundan doğuyor. */
function copaAt(x0, y0, renkler) {
  var hx = ST.trash.x + ST.trash.w / 2;
  var hy = ST.trash.y + 10;
  for (var i = 0; i < 5; i++) {
    part({
      x: x0 + rnd(-4, 4), y: y0,
      vx: (hx - x0) * rnd(1.5, 2.0), vy: (hy - y0) * 1.5 - rnd(28, 52),
      life: .45, col: pick(renkler), g: 210, sz: 1
    });
  }
}
function trashClick() {
  if (G.hand) {
    G.hand = null; addTrash(TRASH_PER_ITEM);
    SFX.drop();
    burst(ST.trash.x + 11, ST.trash.y + 6, 8, ['#8a7a6a', '#5e5048'], { spMax: 40, up: 20 });
    say('Çöpe atıldı');
    return;
  }
  /* Izgarada yanmis dürüm varsa once onu at: inecek yer beklemeden
     kurtulmak gerekir, yoksa izgara tikali kalir. */
  for (var gi = 0; gi < G.grill.slots.length; gi++) {
    if (G.grill.slots[gi].w.burnt) {
      G.grill.slots.splice(gi, 1);
      addTrash(TRASH_PER_ITEM); SFX.drop();
      copaAt(grillSlotX(gi), grillSlotY(gi), ['#3a2a1e', '#6b4a2a', '#1a1210']);
      say('Yanmış dürüm çöpe atıldı');
      checkAuto();
      return;
    }
  }
  /* TAHTADAKI URUN: dürüm de iskender tabagi da, HANGI DURUMDA
     olursa olsun atilabilir. Once etkin tahta, sonra digerleri.
     Eskiden yalniz acik dürüm ve sarili/hazir dürüm atilabiliyordu;
     yarim dolu bir tabak tahtada kilitli kaliyordu. */
  var aw = null, ai;
  var etkin = G.boards[G.act];
  if (etkin) aw = etkin;
  else {
    for (ai = 0; ai < TUN.boards(G); ai++) if (G.boards[ai]) { aw = G.boards[ai]; break; }
  }
  if (aw) {
    var tur = aw.kind === 'plate' ? 'tabak' : (aw.kind === 'pide' ? 'pide' : 'durum');
    var kirinti = { tabak: ['#e2eaf0', '#c98436', '#d9a765'],
                    pide: ['#dcae55', '#a8762e', '#f4e6c2'],
                    durum: ['#f0d5a8', '#c98436', '#8a5f31'] };
    for (ai = 0; ai < 3; ai++) {
      if (G.boards[ai] === aw) {
        copaAt(boardCX(ai), ST.board.y + 10, kirinti[tur]);
        G.boards[ai] = null;
      }
    }
    addTrash(TRASH_PER_ITEM); SFX.drop();
    say(tur === 'tabak' ? 'Tabak çöpe atıldı'
        : (tur === 'pide' ? 'Pide çöpe atıldı' : 'Dürüm çöpe atıldı'));
    checkAuto();
    return;
  }
  /* Atilacak bir sey kalmadi: kovayi bosalt. Bu dal ESKIDEN EN USTTEYDI
     ve kovada bir sey varken tahtadakini atmayi imkansiz kiliyordu. */
  if (G.trash > 0.02) {
    G.emptyT = .9;
    G.trash = 0;
    SFX.pour();
    burst(ST.trash.x + 11, ST.trash.y + 4, 14, ['#6d6258', '#8a7a6a', '#4a423a'], { spMax: 60, up: 26 });
    say('Çöp boşaltıldı — tertemiz!');
    return;
  }
  say('Kova zaten boş');
}
function maybeInspector(dt) {
  var I = G.inspect;
  if (!I) return;
  if (I.state === 'wait') {
    I.t -= dt;
    if (I.t <= 0) {
      I.state = 'in'; I.t = 0; I.x = W + 26;
      I.look = newCustomerLook(Math.floor(rnd(1, 9999)));
      /* Denetimci OZEL bir NPC: kalip almamali. Almayinca kurk mantolu
         kuzeyli denetime geliyordu. */
      I.look.kalip = 'yok'; I.look.hair = 0; I.look.glTip = undefined;
      I.look.acc = 'cap'; I.look.shirt = 7;
      SFX.uiBack();
    }
    return;
  }
  if (I.state === 'in') {
    I.x = approach(I.x, I.tx, dt * 110);
    if (Math.abs(I.x - I.tx) < 1) { I.state = 'check'; I.t = 0; }
    return;
  }
  if (I.state === 'check') {
    I.t += dt;
    if (I.t > 4.5) {
      /* karar */
      var dirty = G.trash > .55;
      I.dirty = dirty;
      if (dirty) {
        I.fine = Math.round(rnd(FINE_MIN, FINE_MAX));
        G.debt += I.fine;
        G.stat.fine = (G.stat.fine || 0) + I.fine;
        I.line = pick(LINES_INSPECT_BAD);
        SFX.fine(); shake(3); flash(.2, '#ff6a4a');
        ftext(T('CEZA +$') + I.fine, I.x, I.y - 62, P.bad, { sc: 1, life: 2 });
      } else {
        I.fine = 0;
        I.line = pick(LINES_INSPECT_OK);
        SFX.stamp();
        ftext('TEMİZ!', I.x, I.y - 62, P.ok, { sc: 1, life: 1.6 });
      }
      I.state = 'leave'; I.t = 0;
      saveAll();
    }
    return;
  }
  if (I.state === 'leave') {
    I.t += dt;
    if (I.t > 2.2) { I.x += dt * 110; if (I.x > W + 40) G.inspect = null; }
  }
}
function drawInspector(t) {
  var I = G.inspect;
  if (!I || I.state === 'wait') return;
  /* gövde: müşteri çizimi + pano */
  var fake = {
    x: I.x, y: I.y, look: I.look, items: [], done: [],
    patience: 1, mood: I.dirty ? 'angry' : 'wait', state: I.state === 'in' ? 'walkin' : 'wait',
    t: t, bubble: 0, lineT: 0, wrongT: 0
  };
  drawCustomer(fake, t);
  /* pano */
  var bx = Math.round(I.x) + 14, by = I.y - 30;
  fr(bx, by, 12, 15, '#8a6a3a');
  fr(bx + 1, by + 1, 10, 13, '#e8e2d0');
  fr(bx + 3, by - 2, 6, 3, '#9aa3ab');
  for (var i = 0; i < 4; i++) hl(bx + 2, by + 4 + i * 3, 8, '#b9b2a0');
  if (I.state === 'check') {
    var pen = Math.sin(t * 12) * 2;
    ln(bx + 8 + pen, by + 4, bx + 11 + pen, by + 9, '#2f3740');
  }
  /* konuşma */
  var lbl = I.state === 'check' ? 'DENETİM…' : (I.line || '');
  if (lbl) {
    var lw = textW(lbl) + 8;
    var lx = clamp(I.x - lw / 2, 2, W - lw - 2), ly = I.y - 66;
    rrect(lx, ly, lw, 12, 3, I.dirty ? P.bad : P.white);
    rrectOut(lx, ly, lw, 12, 3, P.ui5);
    txt(lbl, lx + 4, ly + 2, I.dirty ? P.white : P.ink);
  }
  /* kirlilik uyarısı */
  if (I.state === 'check' && G.trash > .55) {
    ctx.globalAlpha = .4 + .4 * Math.sin(t * 8);
    rrectOut(ST.trash.x - 2, ST.trash.y - 2, ST.trash.w + 4, ST.trash.h + 4, 3, P.bad);
    ctx.globalAlpha = 1;
  }
}

/* ============================================================
   SOKAK KEDISI
   ============================================================
   Camin ONUNDE, yakin kaldirimda belirir; oturur ve bekler.
   Tezgahta ET varken uzerine tiklarsan bir dilim atarsin: kedi
   yer, sans +1 ve gider. Dokunmazsan bir sure sonra kendi gider -
   CEZA YOK. Oyunun ceza agirlikli olay listesine sicak bir an.
   ============================================================ */
function kediGuncelle(dt) {
  var K = G.kedi;
  if (!K || G.scene !== 'play') return;
  K.t += dt;
  if (K.miyav > 0) K.miyav -= dt;
  var M = stM();
  /* Bekleme noktasi yakin kaldirimdaki esyalardan UZAK olmali:
     gx+90'da park etmis bisiklet, gx+236'da cop kovasi var ve ikisi de
     drawNearProps icinde AKTORLERDEN SONRA cizildigi icin kediyi
     ortuyorlardi. gw*.53 ~ gx+140: ikisinin de arasi. */
  var hedef = M.gx + Math.round(M.gw * .53);
  if (K.faz === 'yok') {
    if (K.t >= K.girisT) { K.faz = 'gelis'; K.t = 0; K.x = M.gx + M.gw + 20; }
    return;
  }
  if (K.faz === 'gelis') {
    K.x = approach(K.x, hedef, dt * 42);
    if (Math.abs(K.x - hedef) < 1) {
      K.faz = 'bekle'; K.t = 0; K.miyav = 1.6;
      if (typeof say === 'function') say('Kedi geldi — et verirsen şans getirir');
    }
    return;
  }
  if (K.faz === 'bekle') {
    if (chance(dt * .35)) K.miyav = 1.4;
    if (K.t >= KEDI_BEKLE) { K.faz = 'gidis'; K.t = 0; }
    return;
  }
  if (K.faz === 'yiyor') {
    if (K.t > 1.5) { K.faz = 'gidis'; K.t = 0; }
    return;
  }
  if (K.faz === 'gidis') {
    K.x = approach(K.x, M.gx - 30, dt * 34);
    if (K.x <= M.gx - 28) G.kedi = null;
  }
}

/* Kediye tiklandi mi: cam BOLGESINDE, kedinin uzerinde. */
function kediHit(mx, my) {
  var K = G.kedi;
  if (!K || (K.faz !== 'bekle' && K.faz !== 'gelis')) return false;
  var y = kediY();
  return inRect(mx, my, K.x - 10, y - 16, 20, 18);
}
function kediY() { return stM().curb2 + 1; }

/* Et ver: bir dilim gider, sans gelir. Et yoksa uyarir, ceza yok. */
function kediBesle() {
  var K = G.kedi;
  if (!K) return false;
  if (G.meat <= 0) { SFX.bad(); say('Et yok — önce dönerden kes'); return true; }
  G.meat -= 1;
  K.faz = 'yiyor'; K.t = 0; K.doydu = true; K.miyav = 0;
  G.luck = Math.min(LUCK_MAX, (G.luck || 0) + 1);
  G.stats.kedi = (G.stats.kedi || 0) + 1;
  SFX.ding();
  var ky = kediY();
  burst(K.x, ky - 8, 14, ['#e2483a', '#ff8a7a', '#ffffff'], { spMax: 60, up: 24, type: 'heart', sz: 2 });
  ftext('ŞANS +1', K.x, ky - 26, P.ok, { sc: 1, life: 1.6 });
  say('Kedi doydu — şans +1');
  if (typeof basarimTara === 'function') basarimTara();
  return true;
}

/* Sokak katmaninda cizilir: yakin kaldirimda, camin arkasinda. */
function drawKedi(t) {
  var K = G.kedi;
  if (!K || K.faz === 'yok') return;
  var x = Math.round(K.x), y = kediY();
  var govde = '#4a4038', koyu = '#332c26', acik = '#6b5c50';
  /* golge */
  ctx.globalAlpha = .26; ell(x, y, 8, 2, '#000'); ctx.globalAlpha = 1;

  if (K.faz === 'yiyor') {
    /* one egilmis, yiyor */
    fr(x - 6, y - 6, 12, 6, govde);
    fr(x - 6, y - 6, 12, 2, acik);
    fr(x + 4, y - 9, 5, 5, govde);           /* kafa asagida */
    px(x + 5, y - 8, koyu); px(x + 7, y - 8, koyu);
    fr(x - 8, y - 8, 3, 2, govde);           /* kuyruk yukarida */
    return;
  }
  var yuru = K.faz === 'gelis' || K.faz === 'gidis';
  var sek = yuru ? Math.round(Math.sin(t * 9) * 1) : 0;

  /* govde: oturuyorsa dikey, yuruyorsa yatay */
  if (yuru) {
    fr(x - 7, y - 7 + sek, 13, 6, govde);
    fr(x - 7, y - 7 + sek, 13, 2, acik);
    /* bacaklar */
    var b = Math.round(Math.sin(t * 11) * 1.5);
    fr(x - 5, y - 2 + sek, 2, 2, koyu); fr(x + 3, y - 2 - b + sek, 2, 2, koyu);
    /* kafa */
    fr(x + 4, y - 12 + sek, 6, 6, govde);
    px(x + 5, y - 13 + sek, govde); px(x + 8, y - 13 + sek, govde);   /* kulaklar */
    px(x + 6, y - 10 + sek, '#c8e070'); px(x + 8, y - 10 + sek, '#c8e070');
    /* kuyruk */
    var kt = Math.sin(t * 6) * 2;
    fr(x - 10, y - 10 + Math.round(kt) + sek, 3, 2, govde);
  } else {
    /* oturmus: dik govde */
    fr(x - 4, y - 10, 8, 10, govde);
    fr(x - 4, y - 10, 3, 10, acik);
    fr(x - 4, y - 2, 8, 2, koyu);
    /* kafa */
    fr(x - 4, y - 16, 8, 6, govde);
    px(x - 4, y - 17, govde); px(x - 3, y - 18, govde);   /* sol kulak */
    px(x + 3, y - 17, govde); px(x + 2, y - 18, govde);   /* sag kulak */
    px(x - 2, y - 14, '#c8e070'); px(x + 1, y - 14, '#c8e070');
    px(x, y - 12, '#d8a0a0');                              /* burun */
    /* kuyruk: yana kivrik, salinir */
    var ky2 = Math.round(Math.sin(t * 3.2) * 2);
    fr(x + 4, y - 4 + ky2, 5, 2, govde);
    fr(x + 8, y - 7 + ky2, 2, 4, govde);
  }
  /* miyav baloncugu */
  if (K.miyav > 0) {
    ctx.globalAlpha = clamp(K.miyav, 0, 1);
    var mw = textW('miyav') + 6;
    rrect(x - mw / 2, y - 30, mw, 10, 3, 'rgba(20,16,14,.82)');
    txt('miyav', x, y - 28, '#ffe6b0', { align: 'c' });
    ctx.globalAlpha = 1;
  }
}

/* ============================================================
   ELEKTRIK KESINTISI
   ============================================================
   Izgara ve fritoz DURUR, dukkan kararir. Elle yapilan her sey
   (kesme, malzeme, sarma, kagit, servis) calismaya devam eder -
   oyun kilitlenmez, sadece elektrikli kisayollar gider.
   Jenerator yukseltmesi sureyi kisaltir, 3. seviyede engeller.
   ============================================================ */
function kesintiVarMi() {
  return !!(G.kesinti && G.kesinti.faz === 'kesik');
}
function kesintiGuncelle(dt) {
  var K = G.kesinti;
  if (!K || G.scene !== 'play' || !G.cfg) return;
  var gecen = 1 - clamp(G.timeLeft / G.cfg.len, 0, 1);
  if (K.faz === 'bekle') {
    /* kesintiden hemen once isiklar kirpisir: oyuncu hazirlansin */
    if (gecen >= K.basla - .03) K.uyari = 1;
    if (gecen >= K.basla) {
      K.faz = 'kesik'; K.t = 0; K.uyari = 0;
      SFX.bad(); shake(2.2);
      say('Elektrik kesildi — ızgara ve fritöz durdu!');
      ftext('ELEKTRİK KESİNTİSİ', W / 2, 96, P.bad, { sc: 2, life: 2.2 });
    }
    return;
  }
  if (K.faz === 'kesik') {
    K.t += dt;
    if (K.t >= K.sure) {
      K.faz = 'bitti';
      SFX.levelup();
      say('Elektrik geldi!');
      ftext('ELEKTRİK GELDİ', W / 2, 96, P.ok, { sc: 2, life: 1.6 });
      flash(.14, '#ffe9a0');
    }
  }
}

/* Karartma: tezgahin uzerine koyu bir ortu, sisin atesi delik acar. */
function drawKesinti(t) {
  var K = G.kesinti;
  if (!K) return;
  if (K.faz === 'bekle' && K.uyari > 0) {
    /* kirpisma: kisa, sert */
    if (Math.sin(t * 34) > .4) {
      ctx.globalAlpha = .30; fr(0, 0, W, LAY.floorY, '#000010'); ctx.globalAlpha = 1;
    }
    return;
  }
  if (K.faz !== 'kesik') return;
  /* Sondugu an daha koyu, sonra goz aliskanligiyla biraz aciliyor.
     Once .70 idi; dukkan yeterince kararmiyordu. */
  var acilma = clamp(K.t / 2.2, 0, 1);
  ctx.globalAlpha = .84 - acilma * .14;
  fr(0, 0, W, LAY.floorY, '#04060f');
  ctx.globalAlpha = 1;

  /* --- TEK ISIK KAYNAGI: ISITICI PANELI ---
     Elektrik gidince kor hâlindeki rezistanslar yanmaya devam eder.
     Isik SISTEN degil, sisin sagindaki alti turuncu segmentten
     geliyor; o yuzden hale yuvarlak degil DIKEY bir sutun. */
  var cx = LAY.spit.cx, top = LAY.spit.top, H0 = LAY.spit.bot - top;
  var hx = cx + 19, hy = top + 2, hw = 17, hh = H0 - 14;
  var pcx = hx + hw / 2, pcy = hy + hh / 2;
  var titre = .5 + .5 * Math.sin(t * 5.3) * Math.sin(t * 1.7);

  /* 1) genis, yumusak dikey hale: panelin boyunu izler */
  for (var g = 0; g < 9; g++) {
    var yay = 1 + g * .42;
    ctx.globalAlpha = (.075 - g * .0072) * (.82 + titre * .18);
    var gw2 = Math.round(hw * yay * 2.6), gh2 = Math.round(hh * (1 + g * .16));
    fr(Math.round(pcx - gw2 / 2), Math.round(pcy - gh2 / 2), gw2, gh2, '#ff7a1e');
  }
  /* 2) panele yakin sicak cekirdek */
  ctx.globalAlpha = .20 + titre * .07;
  fr(hx - 6, hy - 4, hw + 12, hh + 8, '#ffa03c');
  ctx.globalAlpha = 1;
  /* 3) segmentlerin kendisi: karartmanin USTUNDE kor gibi parlar */
  for (var i = 0; i < 6; i++) {
    var seg = Math.floor((hh - 8) / 6);
    var ey = hy + 4 + i * seg;
    var fl = .55 + .45 * Math.sin(t * 6 + i * 1.9);
    ctx.globalAlpha = .55 + .35 * fl;
    fr(hx + 3, ey, hw - 6, Math.max(1, seg - 4), '#e0500f');
    ctx.globalAlpha = .45 + .40 * fl;
    fr(hx + 4, ey + 1, hw - 8, Math.max(1, seg - 5), '#ff9c2e');
    ctx.globalAlpha = .30 + .35 * fl;
    fr(hx + 5, ey + 1, hw - 10, Math.max(1, seg - 6), '#ffe08a');
    ctx.globalAlpha = 1;
  }
  /* 4) isigin dustugu yer: sise ve tezgaha vuran sicak kenar */
  ctx.globalAlpha = .16 + titre * .05;
  fr(cx - 20, top, 22, H0, '#ff8a2a');          /* sisin sag yuzu */
  ctx.globalAlpha = .10 + titre * .04;
  fr(hx - 40, LAY.surfY - 3, 74, 5, "#ff9c3c");   /* tezgah kenari */
  ctx.globalAlpha = 1;
  /* kalan sure: kucuk bir sayac */
  var kalan = Math.max(0, Math.ceil(K.sure - K.t));
  var ms = T('ELEKTRİK: ') + kalan;
  var mw = textW(ms) + 12;
  rrect(W / 2 - mw / 2, 84, mw, 13, 3, 'rgba(10,10,20,.85)');
  rrectOut(W / 2 - mw / 2, 84, mw, 13, 3, '#ffb23c');
  txt(ms, W / 2, 87, '#ffd257', { align: 'c' });
}

/* ============================================================
   RAKIP DONERCI + BAHIS
   ============================================================
   Karsi kaldirimda dukkan acar. Bes-sekiz gunde bir gelip bahse
   girer: "bugun 10 dürüm satamazsin". KABUL ETMEK ZORUNLU DEGIL -
   reddetmenin hicbir cezasi yok, sadece para kazanma firsati kacar.
   Ust uste kaybederse dukkanini kapatir.
   ============================================================ */
function rakipGunBasi() {
  if (G.day < RAKIP_GUN) { G.rakipAcik = false; G.rakip = null; return; }
  G.rakipAcik = true;
  if (G.rakipKapandi) { G.rakip = null; return; }
  if (!G.rakipHedef) G.rakipHedef = G.day + 1;
  if (G.day < G.rakipHedef) { G.rakip = null; return; }
  /* bugun geliyor: gunun ilk yarisinda, tezgah bosken degil */
  G.rakipHedef = G.day + RAKIP_ARA_MIN +
    Math.floor(Math.random() * (RAKIP_ARA_MAK - RAKIP_ARA_MIN + 1));
  var t = BAHIS[Math.floor(Math.random() * BAHIS.length)];
  var ilk = !G.rakipTanisti;
  G.rakip = {
    faz: 'yok', t: 0, girisT: rnd(14, 34), x: W + 24,
    tip: t.id, hedef: t.hedef(G), para: bahisPara(G),
    selam: pick(ilk ? RAKIP_SELAM_ILK : RAKIP_SELAM), ilk: ilk
  };
  G.rakipTanisti = true;
}

function rakipGuncelle(dt) {
  var R = G.rakip;
  if (!R || G.scene !== 'play') return;
  R.t += dt;
  var hx = LAY.custSlots[0] ? LAY.custSlots[0].x + 34 : W * .62;
  if (R.faz === 'yok') {
    if (R.t >= R.girisT) { R.faz = 'gelis'; R.t = 0; }
    return;
  }
  if (R.faz === 'gelis') {
    R.x = approach(R.x, hx, dt * 110);
    if (Math.abs(R.x - hx) < 1) { R.faz = 'teklif'; R.t = 0; SFX.door(); }
    return;
  }
  if (R.faz === 'teklif') {
    /* Cevap beklerken oyun DURMAZ: panel acik, musteriler gelmeye
       devam eder. 20 saniye cevap gelmezse teklifi geri ceker. */
    if (R.t > 20) { rakipCevap(false, true); }
    return;
  }
  if (R.faz === 'gidis') {
    if (R.sonT > 0) { R.sonT -= dt; return; }   /* son sozunu soyleyip gitsin */
    R.x = approach(R.x, W + 30, dt * 110);
    if (R.x > W + 28) G.rakip = null;
  }
}

/* Bahis cumlesi: ON + sayi + SON. Ikiye bolunmesinin sebebi hem
   font hem TR/EN sozdizimi farki - bkz. BAHIS tablosu. */
function bahisMetni(R) {
  var b = bahisTip(R.tip);
  if (!b) return '';
  if (!b.on) return T(b.son);                        /* sayisiz cumle */
  var sayi = b.para ? '$' + fmtMoney(R.hedef) : String(R.hedef);
  return T(b.on) + ' ' + sayi + ' ' + T(b.son);
}

function rakipCevap(kabul, sessiz) {
  var R = G.rakip;
  if (!R || R.faz !== 'teklif') return;
  R.faz = 'gidis'; R.t = 0;
  /* Rakip son sozunu soyler ve cikarken baloncugu ustunde durur. */
  if (!kabul) {
    R.son = pick(sessiz ? RAKIP_CEKIL : RAKIP_RET);
    R.sonT = 2.6;
    if (!sessiz) SFX.uiBack();
    G.bahis = null;
    return;
  }
  R.son = pick(RAKIP_KABUL); R.sonT = 2.6;
  SFX.levelup();
  G.bahis = { tip: R.tip, hedef: R.hedef, para: R.para, gun: G.day };
  ftext(T('EL SIKIŞTINIZ'), W / 2, 100, P.au0, { sc: 2, life: 1.6 });
}

/* Gun sonunda bahsi coz. dayEnd icinden cagrilir. */
function bahisCoz() {
  var B = G.bahis;
  if (!B || B.gun !== G.day) { G.bahisSonuc = null; return; }
  var b = bahisTip(B.tip);
  if (!b) { G.bahis = null; G.bahisSonuc = null; return; }
  var deger = b.olc(G);
  var kazandi = deger >= B.hedef;
  G.money += kazandi ? B.para : -B.para;
  if (G.money < 0) G.money = 0;
  G.stats.bahisKazan = (G.stats.bahisKazan || 0) + (kazandi ? 1 : 0);
  G.stats.bahisKayip = (G.stats.bahisKayip || 0) + (kazandi ? 0 : 1);
  /* Rakip ust uste kaybederse pes eder ve dukkanini kapatir. */
  G.rakipSeri = kazandi ? (G.rakipSeri || 0) + 1 : 0;
  if (G.rakipSeri >= RAKIP_PES) { G.rakipKapandi = true; G.rakip = null; }
  G.bahisSonuc = {
    kazandi: kazandi, para: B.para, hedef: B.hedef, deger: deger,
    tip: B.tip, kapandi: !!G.rakipKapandi
  };
  G.bahis = null;
}

/* --- rakip cizimi: tezgahta, musteri gibi ama kendi kiligiyla --- */
function drawRakip(t) {
  var R = G.rakip;
  if (!R || R.faz === 'yok') return;
  var x = Math.round(R.x), y = LAY.custSlots[0] ? LAY.custSlots[0].y : 152;
  var sal = Math.sin(t * 2.2) * .8;
  y = Math.round(y + sal);
  /* govde: koyu onluk, kollari kavusmus - meydan okuyan durus */
  fr(x - 13, y - 30, 26, 31, '#2f4450');
  fr(x - 13, y - 30, 26, 2, '#3d5a68');
  fr(x - 12, y - 30, 7, 30, '#3d5a68');
  /* onluk */
  fr(x - 9, y - 16, 18, 17, '#c9d2d8');
  fr(x - 9, y - 16, 18, 2, '#e4ebef');
  /* kavusmus kollar */
  fr(x - 14, y - 18, 28, 5, '#2f4450');
  fr(x - 14, y - 18, 28, 2, '#3d5a68');
  px(x - 4, y - 16, '#b98b6a'); px(x + 3, y - 16, '#b98b6a');
  /* boyun + kafa */
  fr(x - 3, y - 34, 6, 5, '#a87a54');
  fr(x - 8, y - 46, 16, 14, '#b98b6a');
  fr(x - 8, y - 46, 16, 3, '#a87a54');
  /* sac + biyik: kalin, koyu */
  fr(x - 9, y - 48, 18, 5, '#2a2018');
  fr(x - 9, y - 46, 2, 6, '#2a2018'); fr(x + 7, y - 46, 2, 6, '#2a2018');
  fr(x - 3, y - 37, 6, 2, '#2a2018');
  /* gozler: catik */
  px(x - 4, y - 41, '#1a1410'); px(x + 3, y - 41, '#1a1410');
  fr(x - 5, y - 43, 3, 1, '#2a2018'); fr(x + 2, y - 43, 3, 1, '#2a2018');
  /* kendi kepi */
  fr(x - 9, y - 50, 18, 3, '#2f6a8a');
  fr(x - 9, y - 48, 18, 1, '#1f4a62');

  /* cikarken son sozu: konusma baloncugu */
  if (R.sonT > 0 && R.son) {
    var bw = textW(T(R.son)) + 10;
    var bx = clamp(x - bw / 2, 4, W - bw - 4);
    ctx.globalAlpha = clamp(R.sonT, 0, 1);
    rrect(bx, y - 68, bw, 13, 3, 'rgba(24,18,14,.88)');
    rrectOut(bx, y - 68, bw, 13, 3, '#6b5a48');
    fr(x - 2, y - 56, 4, 3, 'rgba(24,18,14,.88)');
    txt(T(R.son), bx + bw / 2, y - 65, '#f0e2c8', { align: 'c' });
    ctx.globalAlpha = 1;
  }
}
