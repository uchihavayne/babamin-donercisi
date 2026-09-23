# GERCEK PENCERE GORUNTUSU (gelistirme araci): test kipi OLMADAN kabugu acar
# (normal saat, gercek HD yolu), 1440x810 pencereyi PNG'ye yazar.
#   godot --path . --script tests/pencere.gd
extends SceneTree

func _initialize() -> void:
	root.size = Vector2i(1440, 810)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	root.add_child(load("res://scenes/main.tscn").instantiate())
	create_timer(3.0).timeout.connect(_kaydet)

func _kaydet() -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://artifacts/pencere.png")
	print("KAYDEDILDI pencere")
	quit(0)
