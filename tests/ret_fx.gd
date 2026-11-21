# REDDEDILEN ISLEM GERI BILDIRIMI (birlesik surum, 12. tur, akicilik cilasi: "oyun bir islemi reddedince yalniz 'bad' sesi ve yazi var").
# rendering/ui/ret_fx.gd: reddedilen islemde islem noktasinin ustunde kirmizi X belirir ve uyari yazisi (toast) "hayir" der gibi sallanir.
# SALT GORSEL: oyun durumu (G), rastgele sayi, girdi ve ses degismez. GPU pikselleri (HD X sprite'i): tests/ret_fx_visual.gd.
# Bu test mantik / durum tarafini GERCEK oyun akisiyla olcer:
#  1) tetik: 'bad' sesi ile f_say ayni karede (iki sirayla da) -> X + toast sallanmasi; X imlecin 11 px ustunde ve ekrana sigar
#  2) tetiklemez: yalniz 'bad' (olay cezasi: ferman, kedi, lider), yalniz f_say (ipucu), farkli karelerdeki ikisi, oyun disi sahneler
#  3) gercek reddedilen akislar tetikler: "Tezgah dolu", "Once lavas al", sarilmis durumda malzeme (YAZISIZ ret: yalniz X)
#  4) olay cezasi (ferman ihlali) tetiklemez
#  5) omur: X, OMUR sonunda; toast sallanmasi TOAST_SURE sonunda biter; dinlenmede f_toastDx() tam 0
#  6) tekrar siniri: TEKRAR icindeki ikinci tetik yok sayilir (basili tutulan ret X'i dondurmaz); sonrasinda yeniden tetiklenir
#  7) saflik: ayni betikli ret oturumu efektli ve efektsiz (kapali_zorla) oynayinca G, rastgele sayi, SES cagrilari AYNI
#  8) kanca: kapali_zorla / HD_KAPALI=ret_fx -> toast sallanmasi 0, hicbir sey cizilmez (sayaclar calisir)
#  9) ses sarmalayicisi: 'bad' sesi AYNEN calisir (donus degeri dahil), baska sesler sarilmaz
# 10) dinlenme: X omru bitince kare hic tetiklenmemis kareyle BIREBIR ayni (CPU tuvali pencere)
#   godot --headless --path . --script tests/ret_fx.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []
var checks := 0
const DT := 1.0 / 60

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(n: int = 1) -> void:
	for i in n: game.advance(DT)

func kur(tam: bool = false) -> void:
	game.random_state = 424242
	game.clock_ms = 0.0; game.j__last = 0.0
	game.session_system.f_resetProgress()
	game.j_G.prologueSeen = true
	if tam:
		for u in game.j_UPG: game.j_G.up[u.id] = float(u.lv.size())
	game.f_startDay()
	var G: Dictionary = game.j_G
	G.t = 0.0; G.sceneT = 0.0; G.bsT = 0.0
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.timeLeft = 100000; G.hintT = 0
	G.customers = []; G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.weather = "sun"
	G.meat = 12; G.friesTray = 12
	for k in G.stock.keys():
		G.stock[k] = 12; G.stockAnim[k] = 12
	G.boards = [null, null, null]
	G.hand = null; G.drag = null
	for p in [game.j_SESP, game.j_STATS, game.j_BSP, game.j_CUSTOM, game.j_PAYP, game.j_BRP, game.j_TARIFP]: p.open = false
	var R = game.ret_fx
	R.kapali_zorla = false
	R._t = -1.0; R._toast_t = -1.0; R._bad_kare = -1; R._say_kare = -1
	step(3)

# hermetik karsilastirma icin: her kosu yepyeni bir oyunla baslar (trafik / sokak sayaclari onceki kosudan artik tasimaz)
func taze_oyun() -> Node:
	var g: Node = load("res://scripts/platform_game.gd").new()
	g.storage.path = "res://artifacts/ret-fx-save.json"; g.storage.values = {}
	root.add_child(g); g.set_process(false); g.j_MUTED = true
	g.localization.f_setLang("tr")
	return g

func imlec(x: float, y: float) -> void:
	game.j_IN.x = x; game.j_IN.y = y

func bad() -> Variant:
	return game.J.method(game.j_SFX, "bad", [])

func say(s: String = "Deneme") -> void:
	game.session_system.f_say(s)

func sifirla() -> void:
	game.ret_fx._t = -1.0; game.ret_fx._toast_t = -1.0
	step(40)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/ret-fx-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	var R = game.ret_fx
	var G: Dictionary
	kur(); G = game.j_G

	# 1) tetik: iki sirayla da (ve tetik / cizim rastgele sayi CEKMEZ)
	imlec(200.0, 150.0)
	var rs0: int = game.random_state
	bad(); say()
	R.f_ciz(); R.f_toastDx(); R.f_ret(); R.f_tick(DT)
	check(game.random_state == rs0, "tetik, X cizimi, toast kaymasi ve tick rastgele sayi cekmez")
	R._t = -1.0; R._toast_t = -1.0
	bad(); say()
	check(R._t == 0.0 and R._toast_t == 0.0, "bad + f_say ayni karede: X ve toast sallanmasi tetiklenir")
	check(R._x == 200.0 and R._y == 150.0 - 11.0, "X imlecin 11 px ustunde (parmak / imlec ortmesin): (%s, %s)" % [str(R._x), str(R._y)])
	sifirla()
	say(); bad()
	check(R._t == 0.0 and R._toast_t == 0.0, "f_say + bad (ters sira, order_system gibi) de tetikler")
	sifirla()
	imlec(0.0, 0.0); bad(); say()
	check(R._x >= 8.0 and R._y >= float(game.j_VIEW.top) + 10.0, "ekranin kosesinde X ekrana sigar (%s, %s)" % [str(R._x), str(R._y)])
	sifirla()
	imlec(479.0, 269.0); bad(); say()
	check(R._x <= float(game.j_W) - 8.0 and R._y <= float(game.j_H) - 10.0, "sag alt kosede X ekrana sigar (%s, %s)" % [str(R._x), str(R._y)])
	sifirla()

	# 2) tetiklemez
	imlec(200.0, 150.0)
	bad()
	check(R._t < 0.0, "yalniz 'bad' (olay cezasi: ferman / kedi / lider) X cikarmaz")
	step(); say()
	check(R._t < 0.0, "farkli karelerdeki bad ve f_say X cikarmaz")
	step(); say("ipucu")
	check(R._t < 0.0 and R._toast_t < 0.0, "yalniz f_say (ipucu) X ya da sallanma cikarmaz")
	G.scene = "pause"
	bad(); say()
	check(R._t < 0.0, "oyun disi sahnede (mola) X cikmaz")
	G.scene = "play"; step(2)
	sifirla()

	# 3) gercek reddedilen akislar
	imlec(240.0, 120.0)
	game.assembly_system.f_addMeat()   # lavas yok: bad + "Once lavas al"
	check(R._t == 0.0 and R._toast_t == 0.0, "gercek akis: lavassiz et eklemek ('Once lavas al') X + sallanma uretir")
	sifirla()
	# yazisiz ret (gercek akis): doluyor olan musluga ikinci kez basmak sessizce reddedilir -> yalniz X, toast sallanmaz
	kur(true); G = game.j_G
	imlec(240.0, 120.0)
	game.drink_system.f_pourStart("cola")
	check(R._t < 0.0, "gercek akis: musluga ilk basis basarili, X yok")
	game.drink_system.f_pourStart("cola")
	check(R._t == 0.0 and R._toast_t < 0.0, "gercek akis: dolmakta olan musluga tekrar basmak YAZISIZ ret: yalniz X, toast sallanmaz")
	kur(); G = game.j_G
	imlec(240.0, 120.0)
	G.boards = [{"kind": "wrap", "state": "open", "meat": 0.0, "friesN": 0.0, "pickleN": 0.0, "yogurtN": 0.0, "grilled": false, "paper": false, "pop": 0.0, "roll": 0.0, "born": 0.0},
		{"kind": "wrap", "state": "open", "meat": 0.0, "friesN": 0.0, "pickleN": 0.0, "yogurtN": 0.0, "grilled": false, "paper": false, "pop": 0.0, "roll": 0.0, "born": 0.0},
		{"kind": "wrap", "state": "open", "meat": 0.0, "friesN": 0.0, "pickleN": 0.0, "yogurtN": 0.0, "grilled": false, "paper": false, "pop": 0.0, "roll": 0.0, "born": 0.0}]
	game.f_newWrap(null)   # tezgah dolu
	check(R._t == 0.0 and R._toast_t == 0.0, "gercek akis: dolu tezgaha lavas almak ('Tezgah dolu') X + sallanma uretir")
	sifirla()
	G.boards = [null, null, null]
	# basarili eylem tetiklemez
	game.f_newWrap(null)
	check(R._t < 0.0, "basarili eylem (lavas almak) X cikarmaz")
	sifirla()

	# 4) olay cezasi: ferman ihlali bad + sarsinti verir, f_say cagirmaz
	game.regulation_system.f_fermanIhlal({"id": "test", "metin": "deneme"}, 200.0, 100.0, "pencere")
	check(R._t < 0.0, "olay cezasi (ferman ihlali) X cikarmaz")
	sifirla()

	# 5) omur
	imlec(200.0, 150.0); bad(); say()
	var dx: Array = []
	var k := 0
	while (R._t >= 0.0 or R._toast_t >= 0.0) and k < 120:
		step(); k += 1
		dx.append(R.f_toastDx())
	var kare_x: int = int(ceil(R.OMUR / DT))
	check(k >= int(R.TOAST_SURE / DT) and k <= kare_x + 2, "X omru ~OMUR (%d kare, beklenen <= %d)" % [k, kare_x + 2])
	check(R._t < 0.0 and R._toast_t < 0.0, "omur bitince sayaclar bosa duser")
	check(R.f_toastDx() == 0.0, "dinlenmede toast kaymasi tam 0")
	var oynadi := false
	var tamsayi := true
	for v in dx:
		if float(v) != 0.0: oynadi = true
		if float(v) != roundf(float(v)): tamsayi = false
	check(oynadi and tamsayi, "toast sallanma sirasinda kayar ve hep tam sayi")
	check(dx.size() >= 4 and dx[-1] == 0.0 and dx[-4] == 0.0, "toast sallanmasi tam 0'da biter")

	# 6) tekrar siniri
	sifirla()
	imlec(200.0, 150.0); bad(); say()
	step(5)
	var t0: float = R._t
	bad(); say()   # sallanma surerken ikinci ret
	check(R._t == t0, "TEKRAR icindeki ikinci ret X'i yeniden baslatmaz (basili tutulan ret donmaz)")
	step(int(ceil(R.TEKRAR / DT)))
	bad(); say()
	check(R._t == 0.0, "TEKRAR'dan sonra yeniden tetiklenir")
	sifirla()

	# 9) ses sarmalayicisi: bad AYNEN calisir; baska sesler sarilmaz
	var sayac := {"n": 0}
	var eski_bad: Callable = game.j_SFX["bad"]
	# yeni bir oyun tablosuna baglayip sar: ic ses cagrilir, donus degeri aynen gelir
	var tablo := {"bad": func(a: Array = []) -> Variant: sayac.n += 1; return 7, "ui": func(a: Array = []) -> Variant: return 3}
	var yeni_r = R.get_script().new(game)
	yeni_r.bagla(tablo)
	var don: Variant = tablo["bad"].call([])
	check(sayac.n == 1 and don == 7, "sarilan 'bad' eski sesi AYNEN calistirir, donus degeri korunur")
	check(tablo["ui"].call([]) == 3, "bad disindaki sesler sarilmaz")
	check(game.j_SFX["bad"] is Callable and eski_bad.is_valid(), "oyun tablosundaki 'bad' baglanmis ve gecerli")

	# 7) saflik: G, rastgele sayi ve ses cagrilari efektli / efektsiz AYNI
	var sonuclar: Array = []
	var ana_oyun: Node = game
	for kapali in [false, true]:
		game = taze_oyun()
		kur(); G = game.j_G
		game.ret_fx.kapali_zorla = kapali
		game.random_state = 99
		var sesler: Array = []
		var tablo_g: Dictionary = game.j_SFX
		var asil: Callable = tablo_g["bad"]
		tablo_g["bad"] = func(a: Array = []) -> Variant:
			sesler.append(1)
			return asil.call(a)
		imlec(220.0, 130.0)
		for dongu in 6:
			game.assembly_system.f_addMeat()
			step(9)
			G.boards = [null, null, null]
			game.f_newWrap(null)
			step(5)
			G.boards = [null, null, null]
			game.assembly_system.f_addMeat()
			step(30)
		tablo_g["bad"] = asil
		sonuclar.append([JSON.stringify(game.j_G), game.random_state, sesler.size()])
		game.queue_free()
	game = ana_oyun
	var gfark := ""
	if sonuclar[0][0] != sonuclar[1][0]:
		var ja: Dictionary = JSON.parse_string(sonuclar[0][0])
		var jb: Dictionary = JSON.parse_string(sonuclar[1][0])
		for kk in ja:
			if JSON.stringify(ja[kk]) != JSON.stringify(jb.get(kk)): gfark += " " + str(kk)
	check(sonuclar[0][0] == sonuclar[1][0], "oyun durumu (G) efektli ve efektsiz AYNI (farkli alanlar:%s)" % gfark)
	check(sonuclar[0][1] == sonuclar[1][1], "rastgele sayi durumu AYNI")
	check(sonuclar[0][2] == sonuclar[1][2] and sonuclar[0][2] > 0, "ses cagrilari AYNI (%d x bad)" % int(sonuclar[0][2]))

	# 8) kanca
	kur(); G = game.j_G
	R.kapali_zorla = true
	imlec(200.0, 150.0); bad(); say()
	check(R._t == 0.0, "kanca kapaliyken sayaclar yine de calisir (mantik ayni)")
	check(R.f_toastDx() == 0.0, "kanca kapaliyken toast sallanmasi 0")
	R.kapali_zorla = false
	var eski_kapali: PackedStringArray = game._hd_kapali
	game._hd_kapali = PackedStringArray(["ret_fx"])
	check(R.f_toastDx() == 0.0 and not R._gorunur(), "HD_KAPALI=ret_fx de ayni etkiyi yapar")
	game._hd_kapali = eski_kapali
	sifirla()

	# 10) CPU tuvalinde cizim ve dinlenme: her mod yepyeni oyunla, ayni toplam kare sayisiyla (dunya ayni zamanda olsun)
	var pencere := Rect2i(214, 170, 52, 32)
	var kareler := {}
	var ana2: Node = game
	for mod in ["yok", "x", "sonra", "kapali"]:
		game = taze_oyun()
		kur(); G = game.j_G
		imlec(240.0, 190.0)
		match mod:
			"x": step(59); bad(); say(); step()
			"sonra": bad(); say(); step(60)
			"kapali": game.ret_fx.kapali_zorla = true; step(59); bad(); say(); step()
			_: step(60)
		game.random_state = 5
		game.advance(0.0)
		game.j_ctx.ensure()
		kareler[mod] = game.j_ctx.image.duplicate()
		game.queue_free()
	game = ana2
	var farklar := {}
	for mod in ["x", "sonra", "kapali"]:
		var n := 0
		for y in range(pencere.position.y, pencere.end.y):
			for x in range(pencere.position.x, pencere.end.x):
				if kareler[mod].get_pixel(x, y) != kareler["yok"].get_pixel(x, y): n += 1
		farklar[mod] = n
	check(int(farklar["x"]) > 10, "X cizilir: imlecin ustundaki pencerede piksel farki var (%d)" % int(farklar["x"]))
	check(int(farklar["sonra"]) == 0, "X omru bitince kare hic tetiklenmemis kareyle BIREBIR ayni (%d farkli piksel)" % int(farklar["sonra"]))
	check(int(farklar["kapali"]) == 0, "kanca kapaliyken X cizilmez (%d farkli piksel)" % int(farklar["kapali"]))

	var ozet := {"checks": checks, "failures": failures}
	print("RET FX ", JSON.stringify(ozet))
	game.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
