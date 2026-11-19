// Babamın Dönercisi, TEK DOSYALIK web sürümü yükleyicisi (tools/web_tek_dosya.py bu betiği HTML'in içine koyar).
//
// Oyun motoru (WebAssembly) ve oyun verisi sayfanın İÇİNE gzip + base64 olarak gömülüdür. Her dosya, data-ad özniteliği
// dosya adını taşıyan ayrı bir script etiketidir (veri bloğu, çalıştırılmaz):
//     type="application/octet-stream"  data-ad="index.wasm"                  içerik: BASE64(GZIP(veri))   (+ index.pck)
//     type="text/plain"                data-ad="index.audio.worklet.js"      içerik: ham metin            (+ position)
// Godot'un yükleyicisi (index.js) dosyaları fetch("index.wasm") ile ister ve ses işleyicilerini
// AudioWorklet.addModule("index.audio.worklet.js") ile yükler. Bu betik o istekleri gömülü verinin AÇILMIŞ haliyle karşılar;
// başka her istek aynen gerçek ağa gider. Ağ isteği, sunucu ayarı ve yan dosya gerekmez (file:// ile bile açılır).
// Bu betik engine betiğinden (index.js) ve kabuk betiğinden ÖNCE çalışmalıdır.
(function () {
	'use strict';

	var TUR = { 'index.wasm': 'application/wasm', 'index.pck': 'application/octet-stream' };   // fetch ile gelen (gzip) dosyalar
	var gercekFetch = window.fetch ? window.fetch.bind(window) : null;

	var bloklar = {};
	Array.prototype.forEach.call(document.querySelectorAll('script[data-ad]'), function (el) {
		bloklar[el.getAttribute('data-ad')] = el;
	});

	// adres ("index.wasm", "./x/index.wasm?v=1", Request, URL...) → dosya adı
	function dosyaAdi(girdi) {
		var url = typeof girdi === 'string' ? girdi : (girdi && girdi.url) || String(girdi);
		return url.split('#')[0].split('?')[0].split('/').pop();
	}

	function base64Bayt(metin) {
		metin = metin.trim();
		if (typeof Uint8Array.fromBase64 === 'function') return Uint8Array.fromBase64(metin);   // yeni tarayıcılar: yerleşik, hızlı
		var ikili = atob(metin);
		var n = ikili.length;
		var bayt = new Uint8Array(n);
		for (var i = 0; i < n; i++) bayt[i] = ikili.charCodeAt(i);
		return bayt;
	}

	function acilmisYanit(dosya) {
		if (typeof DecompressionStream === 'undefined') {
			return Promise.reject(new Error('Tarayıcınız sıkıştırılmış oyun paketini açamıyor (DecompressionStream yok); lütfen tarayıcıyı güncelleyin. / ' +
				'Your browser cannot unpack the bundled game (no DecompressionStream); please update your browser.'));
		}
		try {
			var akis = new Blob([base64Bayt(bloklar[dosya].textContent)]).stream().pipeThrough(new DecompressionStream('gzip'));
			return Promise.resolve(new Response(akis, { status: 200, headers: { 'content-type': TUR[dosya] } }));
		} catch (e) {
			return Promise.reject(e);
		}
	}

	window.fetch = function (girdi, secenek) {
		var dosya = dosyaAdi(girdi);
		if (TUR[dosya] && bloklar[dosya]) return acilmisYanit(dosya);
		return gercekFetch ? gercekFetch(girdi, secenek) : Promise.reject(new TypeError('fetch yok'));
	};

	// ses işleyicileri: AudioWorklet modülü bir ADRES ister. Önce data: adresi denenir (file:// gibi "opak" kökenli sayfalarda blob: adresi
	// yüklenmez, data: her yerde çalışır); data: engelleyen bir içerik güvenlik ilkesi (CSP) varsa blob: adresine düşülür.
	if (typeof AudioWorklet !== 'undefined' && AudioWorklet.prototype && typeof AudioWorklet.prototype.addModule === 'function') {
		var orijinalEkle = AudioWorklet.prototype.addModule;
		var adresler = {};
		var adayAdresler = function (dosya) {
			if (!adresler[dosya]) {
				var kod = bloklar[dosya].textContent;
				var bayt = new TextEncoder().encode(kod);
				var ikili = '';
				for (var i = 0; i < bayt.length; i++) ikili += String.fromCharCode(bayt[i]);
				adresler[dosya] = [
					'data:text/javascript;base64,' + btoa(ikili),
					URL.createObjectURL(new Blob([kod], { type: 'text/javascript' }))
				];
			}
			return adresler[dosya];
		};
		AudioWorklet.prototype.addModule = function (adres, secenek) {
			var dosya = dosyaAdi(adres);
			var bu = this;
			if (!bloklar[dosya] || TUR[dosya]) return orijinalEkle.call(bu, adres, secenek);
			var yollar = adayAdresler(dosya);
			return orijinalEkle.call(bu, yollar[0], secenek).catch(function () {
				return orijinalEkle.call(bu, yollar[1], secenek);
			});
		};
	}

	// Godot açılışta PWA güncelleme denetimi için navigator.serviceWorker.getRegistration() çağırır; file:// sayfalarda bu çağrı
	// reddedilir (işe yarar bir şey değil, yalnızca konsolda "yakalanmamış hata" gürültüsü). Reddi yutup "kayıt yok" deriz.
	if (navigator.serviceWorker && typeof navigator.serviceWorker.getRegistration === 'function') {
		var orijinalKayit = navigator.serviceWorker.getRegistration.bind(navigator.serviceWorker);
		navigator.serviceWorker.getRegistration = function () {
			try {
				return Promise.resolve(orijinalKayit.apply(null, arguments)).catch(function () { return undefined; });
			} catch (e) {
				return Promise.resolve(undefined);
			}
		};
	}
}());
