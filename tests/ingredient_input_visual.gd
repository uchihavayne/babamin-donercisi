extends SceneTree
var shell: Control
var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(count := 1) -> void:
	for i in count:
		game.advance(1.0/60)
		await process_frame

func center(key: String) -> Vector2:
	var s: Dictionary = game.j_ST[key]
	return Vector2(s.x+s.w/2,s.y+s.h/2)

func screen_point(point: Vector2) -> Vector2:
	return (shell.game_rect.position + point*shell.game_rect.size/Vector2(480,270))*Vector2(root.size)/root.get_visible_rect().size

func press(key: String, down: bool, touch := false) -> void:
	var event: InputEvent
	if touch:
		event = InputEventScreenTouch.new(); event.index = 0
	else:
		event = InputEventMouseButton.new(); event.button_index = MOUSE_BUTTON_LEFT
	event.position = screen_point(center(key)); event.pressed = down
	Input.parse_input_event(event)

func fresh() -> void:
	game.j_G.up = {}; game.f_startDay()
	game.j_G.tut = 99; game.j_G.dersGorulmus = true; game.j_G.ders = null
	game.j_G.shutT = 0; game.j_G.spawnT = 10000; game.j_G.timeLeft = 10000
	game.j_G.meat = 16; game.j_G.stock.pickle = 16; game.j_G.stock.yogurt = 16; game.j_G.friesTray = 16

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://validation/ingredient-input")
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960,540); root.size = Vector2i(1440,810)
	shell = load("res://scenes/main.tscn").instantiate(); root.add_child(shell)
	game = shell.game; game.set_process(false); game.j_MUTED = true
	game.storage.path = "res://artifacts/ingredient-input-visual-save.json"; game.storage.values = {}
	game.localization.f_setLang("tr")
	for mobile in [false,true]:
		root.size = Vector2i(1170,540) if mobile else Vector2i(1440,810)
		shell.mobile = mobile; shell.update_layout(); fresh(); await step(4)
		for key in ["bread","meat","pickle","yogurt","friesT"]:
			press(key,true,mobile); press(key,false,mobile)
		await step(12)
		var w: Variant = game.j_G.boards[0]
		check(w is Dictionary and w.meat == 1 and w.pickleN == 1 and w.yogurtN == 1 and w.friesN == 1,
			"viewport rapid bread + four ingredients: " + ("touch" if mobile else "mouse"))
		check(game.j_G.meat == 15 and game.j_G.stock.pickle == 15 and game.j_G.stock.yogurt == 15 and game.j_G.friesTray == 15,
			"viewport consumes each portion once: " + ("touch" if mobile else "mouse"))
		check(game.stations.holding.is_empty() and not game.j_IN.down and game.j_G.drag == null,
			"viewport releases all input: " + ("touch" if mobile else "mouse"))
		if w is Dictionary:
			press("pickle",true,mobile); await step(45); press("pickle",false,mobile); await step(3)
			check(w.pickleN == 4 and game.j_G.stock.pickle == 12, "viewport hold fills and caps the portion: " + ("touch" if mobile else "mouse"))
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://validation/ingredient-input/"+("touch" if mobile else "mouse")+".png")
		fresh(); game.f_newWrap(); game.j_G.stock.pickle = 0; game.j_G.hint = ""
		press("pickle",true,mobile); press("pickle",false,mobile); await step(3)
		check(game.j_G.hint.contains("bitti") and game.j_G.boards[0].pickleN == 0,
			"viewport empty tray explains the rejected input: " + ("touch" if mobile else "mouse"))
		await step(115)
		check(game.j_G.hintT <= 0, "viewport feedback expires: " + ("touch" if mobile else "mouse"))
		fresh(); await step(3)
		press("board",true,mobile); press("board",false,mobile); await step(3)
		check(game.j_G.customers.is_empty() and game.j_G.boards[0] is Dictionary and game.j_G.boards[0].state == "open",
			"viewport empty board opens bread before any customer: " + ("touch" if mobile else "mouse"))
		var bread: Variant = game.j_G.boards[0]
		game.j_G.hint = ""; press("bread",true,mobile); press("bread",false,mobile); await step(3)
		check(is_same(game.j_G.boards[0],bread) and game.j_G.hint.contains("dolu"),
			"viewport full board preserves bread and explains the limit: " + ("touch" if mobile else "mouse"))
	var report := {"checks":checks,"failures":failures,"renderer":RenderingServer.get_video_adapter_name(),"coverage":"mouse and touch events through platform shell; desktop/mobile layout, rapid clicks, hold, stock and transient feedback"}
	var file := FileAccess.open("res://validation/ingredient-input/visual-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("INGREDIENT INPUT VISUAL ",JSON.stringify(report))
	shell.queue_free(); await process_frame; quit(0 if failures.is_empty() else 1)
