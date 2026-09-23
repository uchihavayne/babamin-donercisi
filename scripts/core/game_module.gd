# Shared context for systems and renderers. The scene owns state and overrides.
extends RefCounted
const J = preload("res://scripts/js_compat.gd")
const Canvas = preload("res://scripts/pixel_canvas.gd")
var game: Variant

func _init(owner_game: Node) -> void:
	game = owner_game
