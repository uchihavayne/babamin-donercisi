extends SceneTree
var shell: Control
var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(count := 4) -> void:
	for i in count:
		game.advance(1.0/60)
		await process_frame

func button_center(label: String) -> Vector2:
	for target in game.controls.targets:
		if target.label == label: return target.rect.get_center()
	return Vector2.INF

func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/economy/" + name + ".png")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://validation/economy")
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(1440,810)
	shell = load("res://scenes/main.tscn").instantiate(); root.add_child(shell)
	game = shell.game; game.set_process(false); game.j_MUTED = true
	game.storage.path = "res://artifacts/economy-visual-save.json"; game.storage.values = {}
	game.localization.f_setLang("tr"); game.f_startDay()
	game.j_G.scene = "shop"; game.j_G.dersGorulmus = true; game.j_G.ders = null
	# fiyatlar data/upg.gd'den (BIRLESIK: fiyatlar degisti, testte sabit yazmasin)
	var fiyat := func(id: String, lv: int) -> int:
		for u in game.j_UPG:
			if u.id == id: return int(u.lv[lv].p)
		return -1
	var fryer1: int = fiyat.call("fryer", 0)
	var fryer2: int = fiyat.call("fryer", 1)
	var drink1: int = fiyat.call("drink", 0)
	game.j_G.money = fryer1; game.j_G.up = {}; game.j_SHOP.sec = "fryer"
	game.pointer(Vector2(475,265)); await step()
	await snap("first-fryer")
	var point := button_center("SATIN AL")
	check(point.is_finite(), "first purchase button is available in the rendered shop")
	if point.is_finite():
		# A real mouse event passes through the platform shell to the shop card.
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.position = (shell.game_rect.position + point * shell.game_rect.size / Vector2(480,270)) * Vector2(root.size) / root.get_visible_rect().size
		mouse.pressed = true; Input.parse_input_event(mouse); await step(1)
		mouse.pressed = false; Input.parse_input_event(mouse); await step()
	check(game.j_G.up.get("fryer",0) == 1 and game.j_G.money == 0,
		"mouse purchase deducts " + str(fryer1) + " and installs fryer level one")
	game.j_G.money = fryer2; game.pointer(Vector2(475,265)); await step()
	await snap("fryer-next-level")
	point = button_center("GELİŞTİR")
	check(point.is_finite(), "owned equipment shows an upgrade action")
	if point.is_finite():
		game.controls.set_mode("controller"); game.pointer(point)
		var accept := InputEventJoypadButton.new(); accept.button_index = JOY_BUTTON_A; accept.device = 0
		accept.pressed = true; Input.parse_input_event(accept); await step(1)
		accept.pressed = false; Input.parse_input_event(accept); await step()
	check(game.j_G.up.get("fryer",0) == 2 and game.j_G.money == 0,
		"controller upgrade deducts " + str(fryer2) + " and reaches level two exactly once")
	check(game.J.method(game.j_TUN,"fryTime",[game.j_G]) == 4.8,
		"the purchased level uses the displayed 4.8-second frying time")
	root.size = Vector2i(1170,540); shell.mobile = true
	game.j_G.up = {}; game.j_G.money = drink1; game.j_SHOP.sec = "drink"
	game.controls.set_mode("touch"); game.pointer(Vector2(475,265)); shell.update_layout(); await step(8)
	await snap("phone-first-drink")
	point = button_center("SATIN AL")
	check(point.is_finite(), "touch shop offers the affordable first drink stand")
	if point.is_finite():
		var touch := InputEventScreenTouch.new(); touch.index = 0
		touch.position = (shell.game_rect.position + point * shell.game_rect.size / Vector2(480,270)) * Vector2(root.size) / root.get_visible_rect().size
		touch.pressed = true; Input.parse_input_event(touch); await step(1)
		touch.pressed = false; Input.parse_input_event(touch); await step()
	check(game.j_G.up.get("drink",0) == 1 and game.j_G.money == 0,
		"touch purchase unlocks drink stand without duplicate charging")
	check(shell.safe_rect.grow(1).encloses(shell.game_rect), "upgrade card remains inside the mobile game viewport")
	var report := {"checks":checks,"failures":failures,"renderer":RenderingServer.get_video_adapter_name(),"coverage":"real mouse/touch and synthetic controller purchase, level effects, desktop/mobile GPU cards"}
	var file := FileAccess.open("res://validation/economy/visual-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("ECONOMY VISUAL ", JSON.stringify(report))
	shell.queue_free(); await process_frame; quit(0 if failures.is_empty() else 1)
