# HD GORSEL SAHNE (birlesik surum): oyunu kabukla (main.tscn) acar, istenen
# durumu kurar ve 960x540 ekrani PNG'ye yazar.
#   godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test
#       [--cikti artifacts/hd.png] [--sahne play|title|shop|dayend] [--full]
#       [--eski] (HD kapali) [--ikili] (ust: HD, alt: eski; ayni oyun ani)
#       [--kizart] (fritoz + kesme dolu) [--sehir N] [--gun N] [--kare N] [--olc N] (N kare ortalama sure)
extends SceneTree

var shell: Control
var g: Node

func arg(ad: String, varsayilan: String = "") -> String:
	var a := OS.get_cmdline_user_args()
	var i := a.find(ad)
	return a[i + 1] if i >= 0 and i + 1 < a.size() else varsayilan

func var_mi(ad: String) -> bool:
	return ad in OS.get_cmdline_user_args()

func _initialize() -> void:
	# bekci: betik hata verirse pencere asili kalmasin
	create_timer(110.0).timeout.connect(func() -> void: print("BEKCI: zaman asimi"); quit(2))
	call_deferred("calis")

func adim(n: int = 3) -> void:
	for i in n:
		g.advance(1.0 / 60.0)
		await process_frame

func goruntu() -> Image:
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

func calis() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	if var_mi("--eski"): g.hd_acik = false
	var sahne := arg("--sahne", "play")
	if sahne != "title":
		g.j_G.up = {}
		if var_mi("--full"):
			for u in g.j_UPG: g.j_G.up[u.id] = float(u.lv.size())
		if arg("--sehir") != "": g.j_G.city = float(arg("--sehir"))
		if arg("--gun") != "": g.j_G.day = float(arg("--gun"))
		g.f_startDay()
		g.j_G.tut = 99; g.j_G.shutT = 0; g.j_G.spawnT = 1000; g.j_G.hintT = 0
		g.j_G.meat = 12; g.j_G.friesTray = 12
		for k in ["pickle", "yogurt", "ayran", "sweet", "tomato", "pepper"]:
			if g.j_G.stock.has(k):
				g.j_G.stock[k] = 12; g.j_G.stockAnim[k] = 12
		g.f_newWrap()
		var w: Dictionary = g.j_G.boards[0]
		w.meat = 4; w.pickleN = 4; w.yogurtN = 4; w.friesN = 4
		# --dolgu E,P,T,Y : acik durumun et / patates / tursu / yogurt miktari
		if arg("--dolgu") != "":
			var d := arg("--dolgu").split(",")
			w.meat = float(d[0]); w.friesN = float(d[1]); w.pickleN = float(d[2]); w.yogurtN = float(d[3])
		if arg("--sos") != "": w.sauce = arg("--sos")
		# --sarili K : tahtadaki durum sarili (K: kizarma 0..1); --kagit: kagitli (hazir)
		if arg("--sarili") != "":
			w.state = "rolled"; w.roll = 1.0; w.kizarma = float(arg("--sarili"))
		if "--kagit" in OS.get_cmdline_user_args():
			w.state = "ready"; w.paper = true; w.roll = 1.0
		g.customer_system.f_spawnCustomer()
		var c: Dictionary = g.j_G.customers[0]
		c.state = "wait"; c.x = c.tx
		if sahne != "play": g.j_G.scene = sahne
		if var_mi("--mac"):
			g.j_G.macGun = true
			g.j_G.timeLeft = g.j_G.cfg.len * (1.0 - (g.j_MAC_BAS + g.j_MAC_BIT) / 2.0)
			g.j_G.macDalga = true
			for cc in g.j_G.customers: cc.mac = true
		if var_mi("--standart"):
			c.items = [{"kind": "wrap"}, {"kind": "drink", "type": "cola"}]
			c.done = [false, false]
			c.bubble = 1.0
		if var_mi("--siparis"):
			c.items = [{"kind": "wrap", "sauce": "hot", "yok": ["pickle"]}, {"kind": "drink", "type": "cola"}]
			c.done = [false, false]
			c.bubble = 1.0
			g.j_G.stock.tomato = 3; g.j_G.stockAnim.tomato = 3; g.j_G.stock.pepper = 1; g.j_G.stockAnim.pepper = 1
		if arg("--kalip") != "" and c.get("look") is Dictionary:
			c.look.kalip = arg("--kalip")
		if arg("--kedi") != "":
			var M: Dictionary = g.street_background.f_stM()
			g.j_G.kedi = {"faz": arg("--kedi"), "t": 0.0, "girisT": 0.0, "miyav": 0.0,
				"x": M.gx + floorf(M.gw * (0.53 if arg("--kedi") in ["bekle", "yiyor"] else 0.75) + 0.5)}
		if arg("--rakip") != "":
			g.j_G.rakip = {"faz": "gidis", "t": 0.0, "girisT": 0.0, "x": float(arg("--rakip")), "tip": "fiyat",
				"hedef": 0.0, "para": 0.0, "selam": "", "ilk": false, "sonT": 0.0, "son": ""}
		# --kurye DURUM : Dayi motorla (leaving: sola cikiyor, back: saga donuyor)
		if arg("--kurye") != "":
			g.j_G.courier = {"state": arg("--kurye"), "t": 0.3, "x": 0.0, "pay": 0.0}
		# --tabak ET,YOG,TEREYAG,DOM,BIB : tahtadaki urun iskender tabagi
		if arg("--tabak") != "":
			var tb := arg("--tabak").split(",")
			g.j_G.boards[0] = {"kind": "plate", "pide": true, "meat": float(tb[0]), "yogurtN": float(tb[1]),
				"yogurt": float(tb[1]) >= g.j_PLATE_YOGURT, "butter": tb[2] == "1", "tomato": float(tb[3]),
				"pepper": float(tb[4]), "state": "open", "pop": 0.0, "born": 0.0}
		# --pide N : tahtada dogranan pide (N dilim)
		if arg("--pide") != "":
			g.j_G.boards[0] = {"kind": "pide", "n": float(arg("--pide")), "state": "open", "pop": 0.0, "born": 0.0}
		# --izgara N : izgarada N sarili durum
		if arg("--izgara") != "":
			for i in int(arg("--izgara")):
				var iw: Dictionary = w.duplicate(true)
				iw.state = "rolled"; iw.roll = 1.0
				g.j_G.grill.slots.append({"w": iw, "t": 2.0 + i, "dur": 8.0, "done": false, "yan": 0.0})
		if var_mi("--yagmur"):
			g.j_G.weather = "rain"; g.j_G.rainT = 30.0
		if var_mi("--kesinti"):
			g.j_G.kesinti = {"faz": "kesik", "t": 3.0, "sure": 20.0, "uyari": 0.0}
		if var_mi("--kizart"):
			g.j_G.fryer.state = "fry"; g.j_G.fryer.dur = 20; g.j_G.fryer.t = 4; g.j_G.fryer.load = 6
			g.j_G.cut.potato = true; g.j_G.cut.prog = 0.4; g.j_G.cut.cutting = true
	await adim(int(arg("--kare", "20")))
	if arg("--olc") != "":
		var top := 0.0
		var n := int(arg("--olc"))
		var en := 0.0
		for i in n:
			await adim(1)
			top += g.last_frame_ms
			en = maxf(en, g.last_frame_ms)
		print("OLCUM ort_ms=%.2f en_ms=%.2f" % [top / n, en])
	var cikti := arg("--cikti", "res://artifacts/hd.png")
	if var_mi("--ikili"):
		var ust := await goruntu()
		g.hd_acik = false
		await adim(1)
		var alt := await goruntu()
		var birlesik := Image.create(ust.get_width(), ust.get_height() * 2, false, ust.get_format())
		birlesik.blit_rect(ust, Rect2i(Vector2i.ZERO, ust.get_size()), Vector2i.ZERO)
		birlesik.blit_rect(alt, Rect2i(Vector2i.ZERO, alt.get_size()), Vector2i(0, ust.get_height()))
		birlesik.save_png(cikti)
	else:
		(await goruntu()).save_png(cikti)
	print("KAYDEDILDI ", cikti, " kare_ms=", g.last_frame_ms)
	quit(0)
