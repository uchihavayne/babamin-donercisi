extends SceneTree
var shell: Control
func _initialize() -> void: call_deferred("run")
func step(count: int) -> void:
	for i in count:
		shell.game.advance(1.0 / 30)
		await process_frame
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/cutting/" + name + ".png")
func run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(1170,540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	shell.game.j_MUTED = true
	shell.game.localization.f_setLang("tr")
	shell.mobile = true
	shell.game.f_startDay()
	shell.game.j_G.tut = 99
	shell.game.j_G.shutT = 0
	shell.game.j_G.spawnT = 1000
	shell.game.controls.set_mode("touch")
	await step(3)
	await snap("touch-idle")
	var finger := InputEventScreenTouch.new()
	finger.index = 0; finger.pressed = true; finger.position = Vector2(80,110)
	shell.game._input(finger)
	await step(4)
	await snap("touch-cut")
	await step(14)
	await snap("touch-cut-repeat")
	finger.pressed = false; shell.game._input(finger)
	await step(15)
	await snap("touch-released")
	var stopped: float = shell.game.j_G.meat
	await step(15)
	assert(shell.game.j_G.meat == stopped)
	shell.game.pointer(Vector2(240,220))
	var trigger := InputEventJoypadMotion.new()
	trigger.device = 0; trigger.axis = JOY_AXIS_TRIGGER_RIGHT; trigger.axis_value = 1
	shell.game._input(trigger)
	await step(4)
	await snap("controller-cut")
	trigger.axis_value = 0; shell.game._input(trigger)
	assert(Vector2(shell.game.j_IN.x,shell.game.j_IN.y)==Vector2(240,220))
	print("CUTTING VISUAL: five GPU captures; touch stop and controller return verified; meat=",shell.game.j_G.meat)
	shell.free()
	await process_frame
	quit()
