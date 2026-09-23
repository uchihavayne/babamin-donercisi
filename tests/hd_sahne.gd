# HD GORSEL SAHNE (birlesik surum): oyunu kabukla (main.tscn) acar, istenen
# durumu kurar ve 960x540 ekrani PNG'ye yazar.
#   godot --path . --resolution 960x540 --script tests/hd_sahne.gd -- --test --gpu-test
#       [--cikti artifacts/hd.png] [--sahne play|title|shop|dayend] [--full]
#       [--eski] (HD kapali) [--ikili] (ust: HD, alt: eski; ayni oyun ani)
#       [--sehir N] [--gun N] [--kare N]
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
		g.customer_system.f_spawnCustomer()
		var c: Dictionary = g.j_G.customers[0]
		c.state = "wait"; c.x = c.tx
		if sahne != "play": g.j_G.scene = sahne
	await adim(int(arg("--kare", "20")))
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
