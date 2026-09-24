# GELISTIRICI PANELI (birlesik surum, 7. tur). Kullanici: "T ile direkt dev
# panelini acabiliyorduk, simdi sadece DEV yazisina tiklayinca oluyor; yaziya
# tiklayinca bazen gun bitiyor". Panel acilirken ayni tiklama sag ustteki
# "GUN BIT" dugmesine de gidiyordu; T tusu kabuk uzerinden oyuna ulasmiyordu.
#   godot --headless --path . --script tests/dev_panel.gd --quit-after 3000 -- --test
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

func tus_t() -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = KEY_T; event.keycode = KEY_T; event.pressed = down
		game._input(event); step(1)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/dev-panel-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.j_window.__DEV_BUILD = true
	game.j_G.day = 3.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 1000
	step(3)
	var k: Array = game.interface_draw.f_devDugmeKutu()
	# DEV'in SOL kenari: panel acilinca "GUN BIT" (x 408-464) tam altina denk gelir
	var dugme := Vector2(float(k[0]) + 2.0, float(k[1]) + float(k[3]) / 2.0)
	for deneme in 3:
		var once := float(game.j_G.timeLeft)
		click(dugme)
		check(game.J.truth(game.j_G.test), "DEV tiklamasi paneli acar (%d)" % deneme)
		step(5)
		check(game.j_G.scene == "play" and float(game.j_G.timeLeft) > once - 1.0, "panel acilirken gun bitmez (%d)" % deneme)
		var k2: Array = game.interface_draw.f_devDugmeKutu()
		click(Vector2(float(k2[0]) + float(k2[2]) / 2.0, float(k2[1]) + float(k2[3]) / 2.0))
		check(not game.J.truth(game.j_G.test), "DEV tiklamasi paneli kapatir (%d)" % deneme)
	tus_t()
	check(game.J.truth(game.j_G.test), "T paneli acar")
	tus_t()
	check(not game.J.truth(game.j_G.test), "T paneli kapatir")
	print("DEV PANEL ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
