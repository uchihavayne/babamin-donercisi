# HAZIRLAMA TAHTASI HD (gelistirme araci): 1 / 2 / 3 bolmeli tahtada acik,
# sarili ve kagitli durum, pide ve iskender tabagi; ust uste PNG.
#   godot --path . --resolution 960x540 --script tests/hd_tahta.gd -- --test --gpu-test [--eski]
extends SceneTree

var shell: Control
var g: Node

func _initialize() -> void:
	create_timer(110.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("calis")

func adim(n: int) -> void:
	for i in n:
		g.advance(1.0 / 60.0)
		await process_frame

func kare() -> Image:
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image().get_region(Rect2i(240, 330, 400, 160))

func calis() -> void:
	root.size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	if "--eski" in OS.get_cmdline_user_args(): g.hd_acik = false
	var goruntuler: Array = []
	for tahta in [1, 2, 3]:
		g.j_G.up = {"board": float(tahta - 1), "iskender": 1.0, "sauce": 1.0}
		g.f_startDay()
		g.j_G.tut = 99; g.j_G.shutT = 0; g.j_G.spawnT = 1000; g.j_G.hintT = 0
		g.j_G.meat = 16; g.j_G.friesTray = 16
		g.f_newWrap()
		var w: Dictionary = g.j_G.boards[0]
		w.meat = 4; w.pickleN = 3; w.yogurtN = 2; w.friesN = 4; w.sauce = "hot"
		if tahta >= 2:
			g.f_newWrap(1)
			var w2: Dictionary = g.j_G.boards[1]
			w2.meat = 4; w2.pickleN = 4; w2.yogurtN = 4; w2.friesN = 4
			g.f_finishRoll(1)
		if tahta >= 3:
			g.recipe_system.f_newPide(false, 2)
		await adim(20)
		goruntuler.append(await kare())
	var cikti := Image.create(400, 160 * goruntuler.size(), false, goruntuler[0].get_format())
	for i in goruntuler.size():
		cikti.blit_rect(goruntuler[i], Rect2i(0, 0, 400, 160), Vector2i(0, 160 * i))
	cikti.save_png("res://artifacts/hd_tahta.png")
	print("KAYDEDILDI hd_tahta")
	quit(0)
