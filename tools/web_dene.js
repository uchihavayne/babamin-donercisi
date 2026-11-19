// Web sürümünü GERÇEK bir tarayıcıda (Chromium) dener: açılış, WebGL2 / HD çizim, BAŞLA tıklaması, konsolda hata yok.
//
// Kullanım (proje kökünden):
//     node tools/web_dene.js [KLASOR] [--vp 960x540] [--dokunmatik] [--dil tr]
//   KLASOR varsayılan: exports/web   (önce:  GODOT=... sh tools/web_derle.sh)
// Önkoşul: Node + Playwright  (npm i playwright; npx playwright install chromium).
// Betik web_sunucu.py'yi kendisi başlatıp kapatır. Yazılımsal WebGL (SwiftShader) kullanır: GPU'suz sunucuda da çalışır,
// ama hız ölçümü için değil, doğruluk için. Çıkış kodu 0 = geçti. Ekran görüntüleri: exports/web-dene-*.png
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const net = require('net');

let chromium;
try { ({ chromium } = require('playwright')); } catch (e) { console.error('playwright yok: npm i playwright'); process.exit(2); }

const arg = (ad, varsayilan) => { const i = process.argv.indexOf(ad); return i >= 0 ? process.argv[i + 1] : varsayilan; };
const klasor = path.resolve(process.argv[2] && !process.argv[2].startsWith('--') ? process.argv[2] : 'exports/web');
const [vw, vh] = arg('--vp', '960x540').split('x').map(Number);
const dokunmatik = process.argv.includes('--dokunmatik');
const dil = arg('--dil', 'tr');

function bosPort() {
	return new Promise((coz, red) => { const s = net.createServer(); s.listen(0, '127.0.0.1', () => { const p = s.address().port; s.close(() => coz(p)); }); s.on('error', red); });
}

(async () => {
	if (!fs.existsSync(path.join(klasor, 'index.html'))) { console.error('HATA: ' + klasor + ' içinde index.html yok (sh tools/web_derle.sh)'); process.exit(2); }
	const port = await bosPort();
	const py = process.platform === 'win32' ? 'python' : 'python3';
	const sunucu = spawn(py, [path.join(__dirname, 'web_sunucu.py'), klasor, '--port', String(port)], { stdio: 'ignore' });
	await new Promise(r => setTimeout(r, 1500));
	const hatalar = [];
	const kontrol = [];
	const dene = (ok, ad) => { kontrol.push([ok, ad]); if (!ok) hatalar.push(ad); };
	let tarayici;
	try {
		tarayici = await chromium.launch({ args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist', '--no-sandbox', '--autoplay-policy=no-user-gesture-required'] });
		const baglam = await tarayici.newContext({ viewport: { width: vw, height: vh }, hasTouch: dokunmatik, isMobile: dokunmatik, deviceScaleFactor: dokunmatik ? 2 : 1, locale: 'en-US' });
		const sayfa = await baglam.newPage();
		const konsol = [];
		sayfa.on('console', m => konsol.push([m.type(), m.text()]));
		sayfa.on('pageerror', e => konsol.push(['pageerror', e.message]));
		await sayfa.goto('http://127.0.0.1:' + port + '/index.html?dil=' + dil, { waitUntil: 'load' });
		// motor başlayana kadar bekle: açılış katmanı kalkar
		let acildi = false;
		for (let i = 0; i < 90 && !acildi; i++) { acildi = await sayfa.evaluate(() => !document.getElementById('durum')); if (!acildi) await sayfa.waitForTimeout(1000); }
		dene(acildi, 'oyun 90 sn içinde açıldı (açılış katmanı kalktı)');
		await sayfa.waitForTimeout(3000);
		const ilk = path.join(path.dirname(klasor), 'web-dene-baslik.png');
		await sayfa.screenshot({ path: ilk });
		dene(konsol.some(([, t]) => /WebGL 2\.0/.test(t) && /Compatibility/.test(t)), 'WebGL 2 + Compatibility çizim sürücüsü');
		dene(konsol.some(([, t]) => /single-threaded/.test(t)), 'tek iş parçacıklı derleme (COOP/COEP istemez)');
		const kutu = await sayfa.evaluate(() => { const c = document.querySelector('canvas'); return c ? [c.clientWidth, c.clientHeight] : null; });
		dene(kutu && kutu[0] === vw && kutu[1] === vh, 'canvas pencereyi doldurur (' + JSON.stringify(kutu) + ')');
		// BAŞLA: oyun alanı 16:9 ortalı; düğme yaklaşık (0.5, 0.55)
		const oyunW = Math.min(vw, vh * 16 / 9), oyunH = oyunW * 9 / 16;
		const bx = vw / 2, by = (vh - oyunH) / 2 + oyunH * 0.55;
		if (dokunmatik) await sayfa.touchscreen.tap(bx, by); else { await sayfa.mouse.move(bx, by); await sayfa.mouse.down(); await sayfa.waitForTimeout(80); await sayfa.mouse.up(); }
		await sayfa.waitForTimeout(3500);
		await sayfa.screenshot({ path: path.join(path.dirname(klasor), 'web-dene-prolog.png') });
		const resim = fs.statSync(ilk).size;
		dene(resim > 20000, 'ekran görüntüsü boş değil (' + resim + ' bayt)');
		const kotu = konsol.filter(([t, m]) => (t === 'error' || t === 'pageerror') && !/GPU stall|net::ERR_ABORTED/.test(m));
		dene(kotu.length === 0, 'konsolda hata yok' + (kotu.length ? ' → ' + kotu.slice(0, 3).map(x => x[1].slice(0, 120)).join(' | ') : ''));
		const gunluk = konsol.map(([t, m]) => '[' + t + '] ' + m).filter(x => !/GPU stall/.test(x));
		for (const g of gunluk.slice(0, 6)) console.log('  ' + g.slice(0, 160));
	} catch (e) {
		hatalar.push('beklenmeyen: ' + e.message);
	} finally {
		if (tarayici) await tarayici.close();
		sunucu.kill();
	}
	for (const [ok, ad] of kontrol) console.log((ok ? '  tamam  ' : '  KALDI  ') + ad);
	console.log('WEB DENEME ' + JSON.stringify({ kontrol: kontrol.length, hatalar }));
	process.exit(hatalar.length ? 1 : 0);
})();
