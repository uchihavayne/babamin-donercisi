extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	await process_frame
	shell.game.advance(1.0 / 60)
	print("PLATFORM BOOT ", shell.game.j_G.scene, " viewport=", shell.game_viewport.size, " fit=", shell.game_rect)
	shell.show_help()
	await process_frame
	shell.close_modal()
	shell.show_settings()
	await process_frame
	shell.close_modal()
	shell.game.effects.f_textStart("USTA", 14)
	shell.show_name_entry()
	await process_frame
	shell.name_entry.text = "izmir döner"
	shell.submit_name()
	print("NAME ", shell.game.j_TEXTIN)
	shell.game.effects.f_textStop()
	shell.free()
	await process_frame
	quit()
