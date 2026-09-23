extends SceneTree
var shell: Control
var checks := 0
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)
func _initialize() -> void: call_deferred("run")
func settle() -> void:
	for i in 3: await process_frame
func snapshot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/platform/" + name + ".png")
func check_layout(name: String) -> void:
	check(shell.safe_rect.grow(1).encloses(shell.game_rect), name + " fits safe area")
	check(is_equal_approx(shell.game_rect.size.x / shell.game_rect.size.y, 16.0 / 9), name + " keeps art aspect")
	var spare: Vector2 = shell.safe_rect.size - shell.game_rect.size
	check(minf(spare.x,spare.y) <= 16*shell.ui_scale+1, name + " reserves no space for a persistent control bar")
func run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(1440,810)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	await settle()
	shell.game.localization.f_setLang("tr")
	shell.game.advance(1.0 / 60)
	await settle()
	print("SHELL ", shell.size, " ROOT ", root.size, " VISIBLE ", root.get_visible_rect())
	check_layout("desktop")
	await snapshot("desktop-title")
	# Route a real viewport input through the shell into game coordinates.
	var start := Vector2(240,144)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = shell.game_rect.position + start * shell.game_rect.size / Vector2(480,270)
	click.pressed = true
	root.push_input(click, true)
	shell.game.advance(1.0 / 60)
	click.pressed = false
	root.push_input(click, true)
	shell.game.advance(1.0 / 60)
	check(shell.game.j_G.scene == "prologue", "viewport-scaled mouse starts game")
	shell.game.f_startDay(); shell.game.j_G.tut = 99; shell.game.j_G.shutT = 0
	shell.game.controls.set_mode("touch")
	var mouse_entry := InputEventMouseMotion.new()
	mouse_entry.position = shell.game_rect.position + Vector2(shell.game.j_LAY.spit.cx,110) * shell.game_rect.size / Vector2(480,270)
	root.push_input(mouse_entry, true)
	shell.game.advance(1.0 / 60)
	check(shell.game.controls.mode == "mouse" and shell.game.f_hitST("spit"), "scaled absolute mouse entry restores spit hover after touch")
	for i in 10: shell.game.advance(1.0 / 60)
	for spec in [["desktop-play", Vector2i(1440,810), false], ["phone-wide", Vector2i(1170,540), true], ["tablet-4-3", Vector2i(1024,768), true], ["ultrawide", Vector2i(1680,720), false], ["portrait-fallback", Vector2i(540,960), true]]:
		root.size = spec[1]
		shell.mobile = spec[2]
		shell.game.controls.set_mode("touch" if spec[2] else "mouse")
		shell.game.advance(1.0 / 60)
		await settle()
		shell.update_layout()
		check_layout(spec[0])
		await snapshot(spec[0])
	root.size = Vector2i(1170,540)
	shell.mobile = true
	await settle()
	shell.game.controls.pause()
	shell.game.advance(1.0 / 60)
	await settle()
	var finger := InputEventScreenTouch.new()
	finger.index = 0
	finger.position = (shell.game_rect.position + Vector2(240,124) * shell.game_rect.size / Vector2(480,270)) * Vector2(root.size) / root.get_visible_rect().size
	finger.pressed = true
	Input.parse_input_event(finger)
	await process_frame
	shell.game.advance(1.0 / 60)
	await process_frame
	finger.pressed = false; Input.parse_input_event(finger)
	await process_frame
	check(shell.modal_kind == "help", "touch opens controls from the pause menu")
	if shell.modal.visible: shell.close_modal()
	shell.show_help()
	await settle()
	check(shell.safe_rect.grow(1).encloses(Rect2(shell.modal_panel.position, shell.modal_panel.size)), "help stays within phone screen")
	await snapshot("phone-help")
	shell.close_modal()
	shell.show_settings()
	await settle()
	check(shell.safe_rect.grow(1).encloses(Rect2(shell.modal_panel.position, shell.modal_panel.size)), "settings fit phone")
	await snapshot("display-settings")
	shell.close_modal()
	# Verify GUI buttons can be operated by controller, without game click-through.
	shell.game.controls.set_mode("controller")
	shell.game.effects.f_textStart("USTA",14)
	shell.show_name_entry()
	await settle()
	var focused: Control = root.gui_get_focus_owner()
	check(focused is Button and focused.text == "A", "controller name keyboard has initial focus")
	var accept := InputEventJoypadButton.new()
	accept.device = 0; accept.button_index = JOY_BUTTON_A; accept.pressed = true
	Input.parse_input_event(accept)
	await process_frame
	accept.pressed = false; Input.parse_input_event(accept)
	await process_frame
	check(shell.name_entry.text == "USTAA", "controller types through native GUI")
	check(shell.safe_rect.grow(1).encloses(Rect2(shell.modal_panel.position, shell.modal_panel.size)), "controller keyboard fits phone")
	await snapshot("controller-name-keyboard")
	shell.name_entry.text = "izmir döner"
	shell.submit_name()
	check(shell.game.j_TEXTIN.value == "İZMİR DÖNER" and shell.game.j_TEXTIN.done, "native text dialog preserves Turkish characters")
	await process_frame
	check(not shell.modal.visible, "submitted text does not reopen name dialog")
	shell.game.effects.f_textStop()
	shell.show_settings()
	shell._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(not shell.modal.visible, "Android system back closes shell dialog")
	shell.touch_capture = 5
	shell.game.controls.touch_id = 5
	shell.game.pointer_button(true)
	shell._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	check(shell.touch_capture == -1 and not shell.game.j_IN.down, "mobile backgrounding releases shell touch capture")
	var output := {"checks": checks, "failures": failures, "renderer": RenderingServer.get_video_adapter_name(), "host": OS.get_name()}
	var file := FileAccess.open("res://validation/platform/shell-results.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(output,"\t")); file.close()
	print("PLATFORM SHELL ", JSON.stringify(output))
	shell.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
