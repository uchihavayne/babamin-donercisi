# KAPANIS (birlesik surum, 6. tur analiz madde 9): borc bitince kutlama ->
# kapanis hikayesi (5 sahne, PRO.epi) -> gun sonu ekrani; oyun serbest surer.
#   godot --headless --path . --script tests/kapanis.gd --quit-after 3000 -- --test
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

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/kapanis-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.j_G.day = 40.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0
	# son taksit: gunun kazanci borcun kalanini kapatir
	game.j_G.debt = 50.0
	game.j_G.stat.earned = 5000.0
	game.session_system.f_endDay()
	game.j_G.scene = "dayend"; game.j_G.sceneT = 3.0
	check(game.j_G.debt == 0.0 and game.j_G.debtCleared, "last installment clears the debt")
	check(game.j_G.celeb is Dictionary, "debt clear starts the celebration")
	step(170)
	click(Vector2(240, 146 + 9))
	check(game.j_G.celeb == null, "celebration button closes the panel")
	check(game.j_G.scene == "prologue" and game.J.truth(game.j_PRO.get("epi")), "epilogue starts after the celebration")
	check(game.j_EPI_SCENES.size() == 5, "epilogue has five scenes")
	# her sahne hatasiz cizilir
	for i in 5:
		game.j_PRO.i = float(i); game.j_PRO.t = 3.0; game.j_PRO.ch = 0.0
		step(5)
		check(game.j_G.scene == "prologue", "epilogue scene %d draws" % i)
	game.story_draw.f_proFinish()
	check(game.j_G.scene == "dayend" and not game.J.truth(game.j_PRO.get("epi")), "epilogue returns to the day end screen")
	# serbest oyun: yeni gun, borc yok, kutlama tekrar etmez
	game.j_G.day += 1.0
	game.f_startDay()
	game.j_G.stat.earned = 5000.0
	game.session_system.f_endDay()
	check(game.j_G.debt == 0.0 and game.j_G.celeb == null, "free play: no debt cut, no second celebration")
	# acilis hikayesi etkilenmez
	game.story_draw.f_proStart()
	check(not game.J.truth(game.j_PRO.get("epi")) and game.j_PRO_SCENES.size() == 5, "prologue still uses its own scenes")
	var report := {"checks": checks, "failures": failures}
	print("KAPANIS ", JSON.stringify(report))
	game.free(); quit(0 if failures.is_empty() else 1)
