# EKSIK TESLIM + TAHTA TIKLAMASI (birlesik surum, 7. tur). Kullanici:
#  "durumu tahtaya geri birakamiyorum, bazen oluyor bazen olmuyor"
#  "(iskender tabagi) hazir bir siparis degil mi ama musteriye teslim edemiyorum"
#  "eksik malzemeli verirsek verebilelim, ona gore para aliriz"
# Gercek fare olaylariyla: eldeki durum bos tahtaya birakilir; secili tahtadaki
# eksik tabak ikinci tiklamada ele alinir; eksik tabak/durum musteriye verilir,
# ucret kaliteyle dusurulur.
#   godot --headless --path . --script tests/eksik_teslim.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(count := 1) -> void:
	for i in count: game.advance(1.0 / 60)

func click(point: Vector2) -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT; event.position = point; event.pressed = down
		game._input(event); step(2)

func fresh(up := {}) -> void:
	game.session_system.f_resetProgress()
	game.j_G.up = up.duplicate()
	game.j_G.day = 6.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 1000
	game.j_G.customers = []

func musteri(items: Array) -> Dictionary:
	game.customer_system.f_spawnCustomer()
	var c: Dictionary = game.j_G.customers.back()
	c.state = "wait"; c.x = c.tx; c.items = items; c.done = []; c.earn = 0; c.patience = 0.9; c.homeless = false
	for i in items: c.done.append(false)
	return c

func tahta() -> Vector2:
	return Vector2(float(game.wrap_system.f_boardCX(0)), float(game.wrap_system.f_boardCY()))

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/eksik-teslim-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	# 1) eldeki durum bos tahtaya tiklaninca birakilir
	fresh()
	var w := {"kind": "wrap", "meat": 4, "pickleN": 4, "yogurtN": 4, "friesN": 4, "sauce": null, "state": "ready", "paper": true, "grilled": false, "burnt": false}
	game.j_G.hand = w
	for i in game.j_G.boards.size(): game.j_G.boards[i] = null
	click(tahta())
	check(is_same(game.j_G.boards[0], w) and game.j_G.hand == null, "eldeki durum bos tahtaya birakilir")
	click(tahta())
	check(is_same(game.j_G.hand, w), "tahtadaki durum tekrar alinir")
	# 2) eksik iskender: secili tahtada ikinci tiklama ele alir, musteri kabul eder
	fresh({"iskender": 1.0})
	var c := musteri([{"kind": "plate"}])
	var p := {"kind": "plate", "pide": true, "meat": 3.0, "butter": true, "yogurt": false, "yogurtN": 0.0, "tomato": 0.0, "pepper": 0.0, "state": "open", "pop": 0.0, "born": 0.0}
	game.j_G.boards[0] = p; game.j_G.act = 0
	click(tahta())
	check(is_same(game.j_G.hand, p), "secili tahtadaki eksik tabak ele alinir")
	game.f_deliver(c)
	var tam := float(game.recipe_system.f_itemPrice({"kind": "plate"}, game.j_G))
	check(c.done[0] and float(c.earn) > 0.0 and float(c.earn) < tam, "eksik tabak teslim edilir, ucret dusuk (%s < %s)" % [c.earn, tam])
	# 3) eksik durum: yogurtsuz ama istenmis -> kabul, ucret %84
	fresh()
	c = musteri([{"kind": "wrap"}])
	var e := {"kind": "wrap", "meat": 4, "pickleN": 4, "yogurtN": 0, "friesN": 4, "sauce": null, "state": "ready", "paper": true, "grilled": false, "burnt": false}
	game.j_G.hand = e
	game.f_deliver(c)
	check(c.done[0] and absf(float(e.quality) - 0.84) < 0.001, "yogurtsuz durum kabul, kalite 0.84")
	print("EKSIK TESLIM ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
