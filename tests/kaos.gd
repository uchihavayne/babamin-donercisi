# KAOS TURU (birlesik surum): oyunu HD acik, tam yukseltmeli, gercek kabukla
# (main.tscn) acar ve her birkac karede istasyon sisteminden RASTGELE gecerli
# bir eylem secer; arada rastgele fare tiklamalari ve zorla olaylar (yagmur,
# kesinti, bahis teklifi, kedi, telefon siparisi, gece hirsizi, gun sonu /
# dukkan gecisi). Amac: calisma zamani hatalarini (SCRIPT ERROR) ve gorsel
# kusurlari yakalamak. Ara ara ekran goruntusu kaydeder.
#   godot --path . --resolution 960x540 --script tests/kaos.gd -- --test --gpu-test [--kare 9000] [--tohum 7] [--cikti klasor]
extends SceneTree

var shell: Control
var g: Node
var rng := RandomNumberGenerator.new()
var sayac := {}

func arg(ad: String, varsayilan: String = "") -> String:
	var a := OS.get_cmdline_user_args()
	var i := a.find(ad)
	return a[i + 1] if i >= 0 and i + 1 < a.size() else varsayilan

func _initialize() -> void:
	create_timer(900.0).timeout.connect(func() -> void: print("BEKCI: zaman asimi"); quit(2))
	call_deferred("calis")

func say(k: String) -> void:
	sayac[k] = int(sayac.get(k, 0)) + 1

func tikla(p: Vector2) -> void:
	for down in [true, false]:
		var e := InputEventMouseButton.new()
		e.button_index = MOUSE_BUTTON_LEFT
		e.position = shell.game_rect.position + p * shell.game_rect.size / Vector2(480, 270)
		e.pressed = down
		Input.parse_input_event(e)
		await process_frame
		g.advance(1.0 / 60.0)

func tam_yukselt() -> void:
	g.j_G.up = {}
	for u in g.j_UPG:
		g.j_G.up[u.id] = float(rng.randi_range(0, u.lv.size()))

func stoklar() -> void:
	g.j_G.meat = maxf(g.j_G.meat, 6.0)
	for k in g.j_G.stock.keys():
		g.j_G.stock[k] = maxf(float(g.j_G.stock[k]), 6.0)

func gun_basla() -> void:
	tam_yukselt()
	g.j_G.day = float(rng.randi_range(2, 14))
	g.f_startDay()
	g.j_G.tut = 99; g.j_G.shutT = 0
	stoklar()
	say("gun")

func olay() -> void:
	match rng.randi_range(0, 9):
		0:
			g.j_G.weather = "rain" if g.j_G.weather != "rain" else "sun"; g.j_G.rainT = 30.0; say("olay_yagmur")
		1:
			g.j_G.kesinti = {"faz": "kesik", "t": 0.0, "sure": 6.0, "uyari": 0.0}; say("olay_kesinti")
		2:
			if g.j_BAHIS.size() > 0:
				var t: Dictionary = g.j_BAHIS[rng.randi_range(0, g.j_BAHIS.size() - 1)]
				g.j_G.rakip = {"faz": "teklif", "t": 0.0, "girisT": 0.0, "x": 300.0, "tip": t.id,
					"hedef": g.J.method(t, "hedef", [g.j_G]), "para": 300.0, "selam": "Selam", "ilk": false}
				say("olay_bahis")
		3:
			var M: Dictionary = g.street_background.f_stM()
			g.j_G.kedi = {"faz": "gelis", "t": 0.0, "girisT": 0.0, "miyav": 0.0, "x": M.gx + M.gw + 10.0}; say("olay_kedi")
		4:
			if g.j_G.phone is Dictionary and g.j_G.phone.get("state") == "idle":
				g.j_G.phone.state = "ring"; g.j_G.phone.t = 0.0; say("olay_telefon")
		5:
			g.j_G.timeLeft = 0.5; say("olay_gun_sonu")
		_:
			pass

func eylem() -> void:
	var st = g.stations
	if st == null: return
	st.refresh()
	if st.targets.is_empty(): return
	var t: Dictionary = st.targets[rng.randi_range(0, st.targets.size() - 1)]
	st.select(t.id)
	var secenek: Array = []
	for a in st.actions():
		if a.enabled: secenek.append(a)
	if secenek.is_empty():
		say("eylem_yok")
		return
	var a: Dictionary = secenek[rng.randi_range(0, secenek.size() - 1)]
	st.press(a.id, "kaos")
	say("eylem_" + str(a.id))
	if not st.holding.is_empty():
		for i in rng.randi_range(5, 40):
			await process_frame
			g.advance(1.0 / 60.0)
		st.release("kaos")

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
	rng.seed = int(arg("--tohum", "7"))
	var kare := int(arg("--kare", "9000"))
	var klasor := arg("--cikti", "res://artifacts/kaos")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(klasor))
	gun_basla()
	var ekran := 0
	for n in kare:
		await process_frame
		g.advance(1.0 / 60.0)
		var sahne: String = str(g.j_G.scene)
		if sahne != "play":
			say("sahne_" + sahne)
			# gun sonu / dukkan / gece / duraklat: birkac kare goster, sonra yeni gun
			if rng.randf() < 0.02:
				if sahne == "dayend" and rng.randf() < 0.5:
					g.j_G.scene = "shop"
				else:
					gun_basla()
			continue
		stoklar()
		if n % 7 == 0: await eylem()
		if n % 53 == 0: await tikla(Vector2(rng.randf_range(4, 476), rng.randf_range(20, 266)))
		if n % 400 == 0: olay()
		if n % 997 == 0 and rng.randf() < 0.3:
			g.j_G.scene = "pause"; say("sahne_pause_zorla")
		if n % 750 == 0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(klasor + "/kaos_%02d.png" % ekran)
			ekran += 1
	print("KAOS ", JSON.stringify(sayac))
	quit(0)
