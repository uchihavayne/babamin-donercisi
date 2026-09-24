# BAHIS PANELI GIRDISI (birlesik surum). Kullanici: "bahis geldi, ne
# reddedebildim ne kabul". Panelin dugmeleri musteri tiklama alaninin ustune
# dusuyordu; tiklama istasyona (musteriye) gidiyordu. Gercek fare olaylariyla
# kabul / ret dugmeleri ve panel acikken arkadaki musterinin etkilenmemesi.
#   godot --headless --path . --script tests/bahis_input.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(count := 1) -> void:
	for i in count: game.advance(1.0 / 60)

func click(point: Vector2) -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT; event.position = point; event.pressed = down
		game._input(event); step(2)

func teklif_kur() -> void:
	game.j_G.day = 5.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 1000
	for i in 3:
		game.customer_system.f_spawnCustomer()
	for c in game.j_G.customers:
		c.state = "wait"; c.x = c.tx
	var t: Dictionary = game.j_BAHIS[0]
	game.j_G.rakip = {"faz": "teklif", "t": 0.0, "girisT": 0.0, "x": 300.0, "tip": t.id,
		"hedef": game.J.method(t, "hedef", [game.j_G]), "para": 500.0, "selam": "Selam", "ilk": false}
	step(3)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/bahis-input-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	var r: Rect2 = game.rival_system.f_bahisPanelRect()
	# kabul
	teklif_kur()
	var musteriler: Array = game.j_G.customers.map(func(c): return c.state)
	click(Vector2(r.position.x + 10 + 50, r.position.y + 74 + 8))
	check(game.j_G.rakip is Dictionary and game.j_G.rakip.faz == "gidis", "accept button closes the offer")
	check(game.j_G.get("bahis") is Dictionary, "accept button starts the bet")
	check(game.j_G.customers.map(func(c): return c.state) == musteriler, "customers behind the panel are not affected")
	# ret
	teklif_kur()
	click(Vector2(r.position.x + r.size.x - 110 + 50, r.position.y + 74 + 8))
	check(game.j_G.rakip is Dictionary and game.j_G.rakip.faz == "gidis", "reject button closes the offer")
	check(game.j_G.get("bahis") == null, "reject button starts no bet")
	# panel disi tiklama oyuna gider (panel acikken de)
	teklif_kur()
	check(not game.rival_system.f_bahisPanelde(240, 200), "counter is outside the panel")
	var report := {"checks": checks, "failures": failures}
	print("BAHIS INPUT ", JSON.stringify(report))
	game.free(); quit(0 if failures.is_empty() else 1)
