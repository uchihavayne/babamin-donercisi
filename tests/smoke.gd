extends SceneTree
var game: Variant
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	game = load("res://scripts/game_sprites.gd").new()
	game.storage.path = "res://artifacts/test-save.json"
	game.storage.values = {}
	root.add_child(game)
	game.set_process(false)
	print("BOOT ", game.j_G.scene, " font=", game.j_FONT.size(), " assets=", game.j_LOGO.tamam)
	for i in 3: game.advance(1.0 / 60)
	game.screen_canvas.image.save_png("res://artifacts/godot-title.png")
	print("TITLE ", game.last_frame_ms, "ms")
	game.localization.f_setLang("tr")
	game.story_draw.f_proStart()
	for i in 3: game.advance(1.0 / 60)
	game.screen_canvas.image.save_png("res://artifacts/godot-story.png")
	print("STORY ", game.last_frame_ms, "ms")
	game.f_startDay()
	for i in 10: game.advance(1.0 / 60)
	game.screen_canvas.image.save_png("res://artifacts/godot-play.png")
	print("PLAY ", game.last_frame_ms, "ms; scene=", game.j_G.scene)
	game.free()
	game = null
	await create_timer(.15).timeout
	quit()
