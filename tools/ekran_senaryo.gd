# EKRAN SENARYOLARI (birlesik surum, 11. tur): belirli oyun durumlarini kurar ve
# ekran goruntusu kaydeder; "bu ekran su dilde / su telefon boyunda nasil gorunuyor?"
# sorusu icin. Test degildir (gercek grafik penceresi ister), oyunu degistirmez.
#
#   godot --path . --resolution 960x540 --script tools/ekran_senaryo.gd -- --test --gpu-test \
#         --senaryo kalabalik --dil de --cikti artifacts/galeri
#
# Secenekler:
#   --senaryo AD     asagidaki adlardan biri (varsayilan: bos = sahne kurmadan baslik)
#   --dil KOD        tr en de fr es pt
#   --boyut GxY      pencere boyutu, orn. 1200x540 (20:9 telefon), 720x540 (4:3 tablet)
#   --touch-preview  dokunmatik kip (telefon gibi)
#   --eski 1         eski (HD kapali) cizim
#   --cikti KLASOR   PNG'lerin yazilacagi klasor (varsayilan res://artifacts)
# Senaryolar: kalabalik mufettis5 mufettis2 lider ferman hesap gunsonu dukkan subeler
#   kisisel rekor borc ses_dukkan basarim ses rekor_baslik mola giris ogretici telefon
#   gece_caldi son_saniye kapanis yardim ayarlar defter yeni_sayfa dukkan_defter tarif_balon
#   patates_ucus fritoze_koy (akicilik: ucan patates / fritoze koyma kareleri; --adim N kare araligi, --say N goruntu)
#   patates_tahta (tezgahtaki patates tahtasi, oyun donuk: --durum bos|patates|kesim|dolu, --seviye N = tum gelistirmeler N. kademe, yoksa hepsi tam)
#   (defter: --sayfa 1-8, --gun N bulunan sayfalarin gunu; yeni_sayfa: --gun N, --sayfa 1-8, --kare N)
# Linux'ta ekransiz sunucuda: xvfb-run -a -s "-screen 0 1280x720x24" godot --rendering-driver opengl3 ...
extends SceneTree

var shell: Control
var g: Node
var G: Dictionary
var klasor := ""
var ad := ""

func arg(a: String, v: String = "") -> String:
	var u := OS.get_cmdline_user_args()
	var i := u.find(a)
	return u[i + 1] if i >= 0 and i + 1 < u.size() else v

func _initialize() -> void:
	create_timer(150.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("calis")

func adim(n: int = 3) -> void:
	for i in n:
		g.advance(1.0 / 60.0)
		await process_frame

func kaydet(ek: String = "") -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(klasor + "/" + ad + ek + ".png")
	print("KAYIT ", ad + ek)

func kur(gun: float, tam: bool, sehir: int = -1, seviye: int = -1) -> void:
	g.session_system.f_resetProgress()
	G = g.j_G
	G.prologueSeen = true
	if tam:
		for u in g.j_UPG: G.up[u.id] = float(u.lv.size())
	elif seviye >= 0:
		for u in g.j_UPG: G.up[u.id] = float(mini(seviye, u.lv.size()))
	G.day = gun
	if sehir >= 0:
		G.branch = float(sehir + 1)
		g.branch_draw.f_sehreGit(float(sehir))
	g.f_startDay()
	G = g.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 1000; G.hintT = 0
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.weather = "sun"
	G.meat = 12; G.friesTray = 12
	for k in G.stock.keys():
		G.stock[k] = 12; G.stockAnim[k] = 12
	g.j_FT.clear()

func doldur(n: int = -1) -> void:
	var adet: int = int(G.cfg.slots) if n < 0 else n
	for i in adet:
		g.customer_system.f_spawnCustomer()
		var c: Dictionary = G.customers.back()
		c.state = "wait"; c.x = c.tx; c.bubble = 1.0; c.patMax = 9999.0

func calis() -> void:
	var boyut := arg("--boyut", "960x540").split("x")
	root.size = Vector2i(int(boyut[0]), int(boyut[1]))
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	g.localization.f_setLang(arg("--dil", "tr"))
	if arg("--eski") == "1": g.hd_acik = false   # eski (HD kapali) cizimi goster
	klasor = arg("--cikti", "res://artifacts")
	ad = arg("--senaryo", "bos")
	G = g.j_G
	match ad:
		"mufettis5", "mufettis2":
			kur(12.0, ad == "mufettis5", -1, int(arg("--seviye", "-1")))
			doldur()
			G.trash = 0.9 if ad == "mufettis2" else 0.1
			G.inspect = {"state": "wait", "t": 0.0, "x": g.j_W + 26.0, "y": 152.0, "tx": g.event_system.mufettis_x(), "dirty": false, "fine": 0.0, "line": ""}
			await adim(230)
			await kaydet("_a")
			await adim(210)
			await kaydet("_b")
		"lider":
			kur(60.0, true, 8)
			doldur()
			if G.get("lider") == null:
				G.lider = {"state": "bekle", "t": 0.0, "x": g.j_W + 40.0, "y": 152.0, "tx": 250.0, "sabir": 1.0, "istek": null, "sonuc": null}
			G.lider.t = 0.0
			await adim(60)
			await kaydet("_a")
			await adim(300)
			await kaydet("_b")
		"ferman":
			kur(60.0, true, 8)
			doldur(3)
			await adim(40)
			await kaydet("_a")
			await adim(400)
			await kaydet("_b")
		"hesap":
			kur(60.0, true, 8)
			G.stat.wraps = 14.0; G.stat.earned = 5200.0; G.stat.tips = 310.0
			g.session_system.f_endDay()
			await adim(60)
			await kaydet("_a")
			await adim(400)
			await kaydet("_b")
		"gunsonu":
			kur(18.0, false, -1, 2)
			G.stat.wraps = 21.0; G.stat.isk = 4.0; G.stat.drinks = 9.0; G.stat.boxes = 6.0; G.stat.sweets = 3.0
			G.stat.lost = 2.0; G.stat.yerYok = 17.0; G.stat.earned = 1840.0; G.stat.tips = 212.0
			G.money = 1840.0
			g.session_system.f_endDay()
			await adim(40)
			await kaydet("_a")
			await adim(500)
			await kaydet("_b")
		"dukkan":
			kur(18.0, false, -1, 2)
			G.money = 3200.0
			G.scene = "shop"; G.sceneT = 0.0
			await adim(60)
			g.pointer(Vector2(float(arg("--x", "60")), float(arg("--y", "110"))))
			await adim(60)
			await kaydet()
		"subeler", "kisisel", "rekor", "borc", "ses_dukkan":
			kur(30.0, true)
			G.money = 61000.0; G.branch = 3.0
			G.stats.wraps = 812.0; G.stats.earned = 96400.0; G.stats.days = 29.0; G.stats.lost = 12.0
			G.scene = "shop"; G.sceneT = 0.0
			await adim(30)
			match ad:
				"subeler": g.j_BRP.open = true
				"kisisel": g.j_CUSTOM.open = true
				"rekor": g.j_STATS.open = true
				"borc": g.j_PAYP.open = true
				"ses_dukkan": g.j_SESP.open = true
			await adim(60)
			await kaydet()
		"basarim", "ses", "rekor_baslik":
			G.scene = "title"
			await adim(30)
			if arg("--acik") == "1":
				# butun basarimlar acik (rozetlerin renkli hali)
				if not (g.j_G.get("bs") is Dictionary): g.j_G.bs = {}
				for b in g.j_BASARIM: g.j_G.bs[b.id] = 1.0
			match ad:
				"basarim": g.j_BSP.open = true
				"ses": g.j_SESP.open = true
				"rekor_baslik": g.j_STATS.open = true
			await adim(60)
			await kaydet()
		"mola":
			kur(12.0, true)
			doldur()
			await adim(30)
			G.scene = "pause"
			await adim(30)
			await kaydet()
		"giris":
			kur(7.0, false, -1, 1)
			g.session_system.f_goIntro()
			G = g.j_G
			if arg("--hava") != "": G.weather = arg("--hava")
			G.macGun = arg("--mac", "1") == "1"
			await adim(50)
			await kaydet()
		"ogretici":
			g.session_system.f_resetProgress()
			G = g.j_G
			G.prologueSeen = true
			g.f_startDay()
			G = g.j_G
			G.shutT = 0
			for i in 6:
				await adim(45)
				await kaydet("_%d" % i)
				if i < 5: G.tut = float(i + 1)
		"telefon":
			kur(20.0, true)
			doldur()
			G.phone.state = "ring"; G.phone.ringT = 0.5
			await adim(30)
			await kaydet("_a")
			g.phone_system.f_phoneClick()
			await adim(40)
			await kaydet("_b")
		"gece_caldi":
			kur(20.0, false, -1, 1)
			G.money = 900.0
			G.night = {"t": 0.0, "phase": 0.0, "stole": true, "amount": 120.0, "sec": 0.0, "line": "Kasadan aldığını götürdü…", "paid": false}
			G.scene = "night"; G.sceneT = 0.0
			await adim(int(arg("--kare", "330")))
			await kaydet()
		"yardim", "ayarlar":
			kur(12.0, true)
			doldur()
			await adim(30)
			if ad == "yardim": shell.show_help()
			else: shell.show_settings()
			await adim(20)
			await kaydet()
		"son_saniye":
			kur(15.0, true)
			doldur()
			G.timeLeft = float(arg("--sure", "7.5"))
			await adim(20)
			await kaydet("_a")
			await adim(60)
			await kaydet("_b")
		"kapanis":
			kur(15.0, true)
			doldur()
			G.timeLeft = 0.2
			await adim(40)
			await kaydet("_a")
			await adim(150)
			await kaydet("_b")
		"defter", "dukkan_defter":
			# Baba'nin Defteri: bulunmus sayfalar, farkli ustalik seviyeleri; --sayfa N secili sekme
			kur(float(arg("--gun", "80")), ad == "defter", -1, 2)
			G.money = 61000.0 if ad == "defter" else 3200.0
			G.scene = "shop"; G.sceneT = 5.0
			var dd: Dictionary = g.tarif_system.f_durum()
			for t in g.j_TARIF:
				if int(t.gun) <= int(G.day): dd.bulunan.append(str(t.id))
			dd.servis = {"acili": 27, "sarimsakli": 6, "tursusuz": 45}
			dd.gorulen = ["acili"] if ad == "defter" else []
			if ad == "defter":
				g.j_TARIFP.open = true
				g.j_TARIFP.sec = int(arg("--sayfa", "1")) - 1
			await adim(40)
			await kaydet()
		"yeni_sayfa":
			# gun sonunda bulunan sayfa karti; --gun N, --sayfa N (gosterilecek sayfa)
			kur(float(arg("--gun", "30")), false, -1, 2)
			G.stat.wraps = 21.0; G.stat.earned = 1840.0; G.stat.tips = 212.0; G.money = 1840.0
			g.session_system.f_endDay()
			var yd: Dictionary = g.tarif_system.f_durum()
			if arg("--sayfa") != "":
				var yid: String = str(g.j_TARIF[int(arg("--sayfa")) - 1].id)
				yd.bulunan = [yid]; yd.yeni = [yid]
			await adim(int(arg("--kare", "60")))
			await kaydet()
		"tarif_balon":
			# siparis balonlarinda altin yildiz + hazirlik seridinde yildiz (secili tarif siparisi)
			kur(60.0, true)
			var tb: Dictionary = g.tarif_system.f_durum()
			for t in g.j_TARIF: tb.bulunan.append(str(t.id))
			doldur(4)
			var idler := ["acili", "tursusuz", "menu", "gece"]
			for i in G.customers.size():
				var c: Dictionary = G.customers[i]
				var kalemler: Array = [g.tarif_system.f_siparisKalemi(idler[i])]
				kalemler.append_array(g.tarif_system.f_ekKalemler(idler[i]))
				c.items = kalemler; c.done = []
				for _k in kalemler: c.done.append(false)
			g.order_system.f_newWrap(0)
			G.act = 0.0
			await adim(int(arg("--kare", "120")))
			g.j_BSQ.kuyruk = []   # basarim bildirimi hazirlik seridini ortmesin
			await adim(3)
			await kaydet()
		"patates_ucus":
			# cuvaldan tahtaya ucan patates: --adim kare araliginda --say goruntu (varsayilan 3 karede bir, 10 goruntu)
			kur(12.0, false, -1, 0)   # gelistirme yok: otomatik patates yok
			G.cut.potato = false; G.cut.raw = 0.0
			g.j_BSQ.kuyruk = []
			await adim(10)
			g.potato_system.f_potatoTake()
			for i in int(arg("--say", "10")):
				await adim(int(arg("--adim", "3")))
				g.j_BSQ.kuyruk = []
				await kaydet("_%02d" % i)
		"fritoze_koy":
			# ham cubuklar tahtadan fritoze: tikla -> --say goruntu, --adim kare araliginda (varsayilan 2 karede bir, 12 goruntu)
			kur(12.0, false, -1, 0)
			G.cut.potato = false; G.cut.raw = 3.0
			g.j_BSQ.kuyruk = []
			await adim(10)
			g.potato_system.f_fryerClick()
			for i in int(arg("--say", "12")):
				await adim(int(arg("--adim", "2")))
				g.j_BSQ.kuyruk = []
				await kaydet("_%02d" % i)
		"patates_tahta":
			# patates tahtasi + komsulari (sos, kagit, fritoz, kutu): oyun donuk, otomatik dograyici / fritoz tahtayi degistirmez
			var sev := arg("--seviye", "")
			kur(12.0, sev == "", -1, int(sev) if sev != "" else -1)
			g.set_process(false)
			var durum := arg("--durum", "dolu")
			G.cut.potato = durum == "patates" or durum == "kesim" or durum == "dolu"
			G.cut.prog = 0.5 if durum == "kesim" else 0.0
			G.cut.raw = 14.0 if durum == "dolu" else (3.0 if durum == "kesim" else 0.0)
			G.cut.land = 0.0; G.cut.cutting = false; G.cut.slash = []
			G.flyP = null; G.flyF = null
			G.fryer.state = "fry"; G.fryer.t = 0.0; G.fryer.dur = 99999.0; G.fryer.load = 3.0
			g.j_BSQ.kuyruk = []
			g.j_IN.x = 2.0; g.j_IN.y = 2.0
			g.advance(0.0)
			await process_frame
			await kaydet("_" + durum + ("" if sev == "" else "_s" + sev))
		"kalabalik":
			# en yogun an: 5 musteri + sira + telefon fisi + kedi + rakip + mufettis
			kur(25.0, true)
			doldur()
			for i in 3: g.customer_system.f_spawnCustomer()
			var M: Dictionary = g.street_background.f_stM()
			G.kedi = {"faz": "bekle", "t": 0.0, "girisT": 0.0, "miyav": 0.0, "x": M.gx + floorf(M.gw * 0.53 + 0.5), "doydu": false}
			G.phone.state = "order"
			G.phone.order = [{"kind": "wrap", "sauce": "garlic", "yok": ["pickle"]}, {"kind": "wrap", "sauce": "hot"}, {"kind": "fbox"}, {"kind": "drink", "type": "cola"}, {"kind": "sweet"}]
			G.phone.done = [false, true, false, false, false]
			for i in G.customers.size():
				var c: Dictionary = G.customers[i]
				if c.state == "wait" and i % 2 == 0:
					c.items = [{"kind": "wrap", "sauce": "garlic", "yok": ["fries"]}, {"kind": "drink", "type": "fanta"}, {"kind": "fbox"}, {"kind": "plate"}]
					c.done = [false, true, false, false]
			await adim(200)
			await kaydet()
	for satir in g.j_FT: print("YAZI ", satir.s)
	print("BITTI ", ad)
	quit(0)
