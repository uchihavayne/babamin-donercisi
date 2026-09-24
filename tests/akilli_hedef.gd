# AKILLI MALZEME HEDEFI (birlesik surum, kullanici karari). Tiklanan malzeme
# secili bolmeye degil, ona gercekten ihtiyaci olan urune gider; secili urun
# tezgahtan ayrilinca secim siradaki bekleyen urune gecer. Gercek fare olaylari.
#   godot --headless --path . --script tests/akilli_hedef.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(count := 1) -> void:
	for i in count:
		game.stations.refresh(); game.stations.tick(1.0/60); game.controls.tick(1.0/60)
		game.game_loop.f_updatePlay(1.0/60)
		game.effects.f_inEnd()

func fresh(up := {}) -> void:
	game.controls.release_all(); game.j_G.up = up; game.f_startDay()
	game.j_G.shutT = 0; game.j_G.tut = 99; game.j_G.spawnT = 10000; game.j_G.timeLeft = 10000
	game.j_G.meat = 16; game.j_G.friesTray = 16
	for k in ["pickle", "yogurt", "tomato", "pepper"]: game.j_G.stock[k] = 16
	game.controls.set_mode("mouse")

func plate(i: int) -> Dictionary:
	var p := {"kind": "plate", "pide": true, "meat": 0.0, "butter": false, "yogurt": false, "yogurtN": 0.0,
		"tomato": 0.0, "pepper": 0.0, "state": "open", "pop": 0.0, "born": game.j_G.t}
	game.j_G.boards[i] = p
	return p

func mouse(point: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point; event.pressed = down; event.button_index = MOUSE_BUTTON_LEFT
	game._input(event)

func tap_at(point: Vector2) -> void:
	mouse(point, true); step(2); mouse(point, false); step(3)

func tap(key: String) -> void:
	var s: Dictionary = game.j_ST[key]
	tap_at(Vector2(s.x + s.w / 2, s.y + s.h / 2))

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/akilli-hedef-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true

	# yogurdu dolu durum secili + iskender tabagi yogurt bekliyor -> yogurt tabaga
	fresh({"board": 1.0, "iskender": 1.0})
	game.f_newWrap(0)
	var w: Dictionary = game.j_G.boards[0]
	w.yogurtN = 4.0
	var p := plate(1)
	game.j_G.act = 0.0; step()
	tap("yogurt")
	check(p.yogurtN > 0.0 and w.yogurtN == 4.0 and int(game.j_G.act) == 1, "yogurt skips the full wrap and goes to the waiting iskender plate")

	# et: tabak secili ve eti tamam, durumun eti eksik -> et duruma
	fresh({"board": 1.0, "iskender": 1.0})
	game.f_newWrap(0)
	w = game.j_G.boards[0]
	p = plate(1)
	p.meat = float(game.j_TUN.iskMeat.call([game.j_G]))
	game.j_G.act = 1.0; step()
	tap("meat")
	check(w.meat > 0.0 and int(game.j_G.act) == 0, "meat skips the finished plate and goes to the wrap")

	# garnitur: durum secili, domates tabaga gider
	fresh({"board": 1.0, "iskender": 1.0, "garnish": 1.0})
	game.f_newWrap(0)
	p = plate(1)
	game.j_G.act = 0.0; step()
	var g: Dictionary = game.j_ST.garnish
	tap_at(Vector2(g.x + g.w * 0.25, g.y + g.h / 2))
	check(p.tomato > 0.0 and int(game.j_G.act) == 1, "tomato goes to the plate even when a wrap is selected")

	# turşusuz siparise bagli durum secili -> tursu diger duruma
	fresh({"board": 1.0})
	game.f_newWrap(0); game.f_newWrap(1)
	var w0: Dictionary = game.j_G.boards[0]
	var w1: Dictionary = game.j_G.boards[1]
	w0._order_recipe = {"kind": "wrap", "yok": ["pickle"]}
	game.j_G.act = 0.0; step()
	tap("pickle")
	check(w0.pickleN == 0.0 and w1.pickleN > 0.0, "pickles skip a wrap whose order does not want them")

	# hicbir urune gerekmiyorsa secili urunde kalir (mesaj)
	fresh({"board": 1.0})
	game.f_newWrap(0)
	game.j_G.boards[0].pickleN = 4.0
	game.j_G.act = 0.0; step()
	tap("pickle")
	check(game.j_G.boards[0].pickleN == 4.0 and int(game.j_G.act) == 0, "an ingredient nobody needs is not added anywhere")

	# secili urun tezgahtan alininca secim bekleyen acik urune gecer
	fresh({"board": 1.0})
	game.f_newWrap(0); game.f_newWrap(1)
	game.j_G.act = 1.0; step(2)
	game.j_G.hand = game.j_G.boards[1]; game.j_G.boards[1] = null
	step(2)
	check(int(game.j_G.act) == 0, "when the selected item leaves the board the next waiting item is selected")
	# oyuncunun sectigi bos bolmeye dokunulmaz
	game.j_G.hand = null
	game.j_G.act = 1.0; step(3)
	check(int(game.j_G.act) == 1, "a player-selected empty board stays selected")

	var report := {"checks": checks, "failures": failures}
	print("AKILLI HEDEF ", JSON.stringify(report))
	game.free(); quit(0 if failures.is_empty() else 1)
