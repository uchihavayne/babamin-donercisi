extends SceneTree
var game: Variant
var report: Dictionary = {}
var tag := ""
func _initialize() -> void: call_deferred("run")

func snap(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image() if game.gpu_enabled else game.screen_canvas.image
	img.save_png("res://artifacts/sprite-migration/" + tag + "-" + name + ".png")

func measure(name: String, count: int = 120) -> void:
	var samples: Array[float] = []
	var expected_scene: String = game.j_G.scene
	for i in count:
		game.advance(1.0/60)
		assert(game.j_G.scene==expected_scene, "Benchmark scene must remain unchanged")
		samples.append(game.last_frame_ms)
		if game.gpu_enabled: await process_frame
	samples.sort()
	report[name] = {"scene":expected_scene,"median_ms":samples[int(count*.5)], "p95_ms":samples[int(count*.95)], "frames":count}
	if game.gpu_enabled:
		report[name]["texture_uploads_last_frame"] = game.screen_canvas.texture_uploads
		report[name]["draw_commands"] = game.screen_canvas.draw_commands
	print(name, " ", report[name])

func run() -> void:
	var baseline := "--baseline" in OS.get_cmdline_user_args()
	root.size = Vector2i(480,270)
	root.content_scale_size = Vector2i(480,270)
	game = load("res://scripts/game.gd" if baseline else "res://scripts/game_sprites.gd").new()
	game.storage.path = "res://artifacts/sprite-render-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	tag = "baseline" if baseline else ("gpu" if game.gpu_enabled else "sprites-cpu")
	for i in 3: game.advance(1.0/60)
	await snap("title")
	game.localization.f_setLang("tr"); game.story_draw.f_proStart()
	for i in 3: game.advance(1.0/60)
	await snap("story")
	game.f_startDay()
	for i in 10: game.advance(1.0/60)
	await snap("play")
	game.j_G.tut = 99; game.j_G.shutT = 0.0
	await measure("play")
	game.j_G.day=60.0; game.j_G.money=5000000.0; game.j_G.branch=game.j_BRANCH.size()
	for upgrade in game.j_UPG: game.j_G.up[upgrade.id]=float(upgrade.lv.size())
	for city in range(-1,game.j_SEHIR.size()):
		game.branch_draw.f_sehreGit(city); game.f_startDay(); game.j_G.tut=99; game.j_G.shutT=0.0; game.j_G.weather="rain"
		for i in 3: game.customer_system.f_spawnCustomer()
		for c in game.j_G.customers: c.state="wait"; c.x=c.tx; c.bubble=1.0
		for i in 3: game.advance(1.0/60)
		await snap("city-"+str(city))
	await measure("advanced_rain")
	game.j_G.scene="title"
	await measure("title")
	var file := FileAccess.open("res://artifacts/sprite-migration/"+tag+"-timings.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	game.free(); await process_frame; quit()
