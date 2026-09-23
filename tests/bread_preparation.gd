extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(count := 1) -> void:
	for i in count: game.advance(1.0/60)

func fresh(up := {}) -> void:
	game.controls.release_all(); game.j_G.up = up; game.j_G.day = 1; game.f_startDay()
	# Keep the real first-day tutorial and shutter state. Do not invent customers.
	game.controls.set_mode("mouse")

func point(target: String) -> Vector2:
	game.stations.select(target,false)
	return game.stations.target().rect.get_center()

func mouse(position: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = position; event.pressed = down; event.button_index = MOUSE_BUTTON_LEFT
	game._input(event)

func use_target(target: String, device: String) -> void:
	var position := point(target)
	for down in [true,false]:
		if device == "mouse": mouse(position,down)
		elif device == "touch":
			var event := InputEventScreenTouch.new()
			event.position = position; event.pressed = down; event.index = 0
			game._input(event)
		else:
			var event := InputEventJoypadButton.new()
			event.button_index = JOY_BUTTON_A; event.pressed = down; event.device = 0
			game._input(event)
		step()

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/bread-preparation-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	for device in ["mouse","touch","controller"]:
		for target in ["bread","board:0"]:
			fresh(); use_target(target,device)
			var wrap: Variant = game.j_G.boards[0]
			check(wrap is Dictionary and wrap.kind == "wrap" and wrap.state == "open",
				"first day before any customer: %s on %s opens bread" % [device,target])
			check(game.j_G.customers.is_empty() and (wrap == null or not wrap.has("_order_recipe")),
				"preparation does not require or create a customer: %s on %s" % [device,target])
		fresh({"board":1.0})
		use_target("board:1",device)
		check(game.j_G.boards[1] is Dictionary and game.j_G.boards[0] == null,
			"empty board click respects chosen preparation space: "+device)
		use_target("bread",device)
		var first: Variant = game.j_G.boards[1]
		check(game.j_G.boards[0] is Dictionary, "bread stack uses another empty board: "+device)
		game.j_G.hint = ""; use_target("bread",device)
		check(is_same(game.j_G.boards[1],first) and game.j_G.hint.contains("dolu"),
			"full counter explains rejection without replacing food: "+device)
		fresh({"iskender":1.0,"board":1.0})
		use_target("pide",device); use_target("bread",device)
		check(game.j_G.boards[0] is Dictionary and game.j_G.boards[0].kind == "pide" and game.j_G.boards[1] is Dictionary and game.j_G.boards[1].kind == "wrap" and game.j_G.customers.is_empty(),
			"unlocked pide and flatbread remain separate before any order: "+device)
	fresh(); use_target("bread","mouse")
	var w: Variant = game.j_G.boards[0]
	game.j_G.meat = 4; game.j_G.stock.pickle = 4
	use_target("meat","mouse"); use_target("pickle","mouse")
	check(w is Dictionary and w.meat == 1 and w.pickleN == 1 and game.j_G.customers.is_empty(),
		"ingredients can be prepared before an order exists")
	game.customer_system.f_spawnCustomer()
	var customer: Dictionary = game.j_G.customers.back()
	customer.state = "wait"; customer.items = [{"kind":"wrap","yok":[]}]; customer.done = [false]
	game.order_select(customer)
	check(w is Dictionary and is_same(w.get("_order_owner"),customer) and w.meat == 1 and w.pickleN == 1,
		"later customer selection binds the prepared bread without losing ingredients")
	var report := {"checks":checks,"failures":failures,"input":"first-day mouse, touch and controller events with no customer"}
	var file := FileAccess.open("res://validation/bread-preparation-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("BREAD PREPARATION ",JSON.stringify(report)); game.free(); quit(0 if failures.is_empty() else 1)
