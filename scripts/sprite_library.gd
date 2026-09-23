# PNG atlases are the editable runtime source of truth. JSON describes their regions.
extends RefCounted
const Canvas = preload("res://scripts/pixel_canvas.gd")
var manifest: Dictionary = {}
var sheets: Dictionary = {}
var sprites: Dictionary = {}

func _init() -> void:
	var path := "res://assets/sprites/manifest.json"
	if FileAccess.file_exists(path): manifest = JSON.parse_string(FileAccess.get_file_as_string(path))

func get_sprite(key: String) -> Variant:
	if sprites.has(key): return sprites[key]
	if not manifest.has(key): return null
	var entry: Dictionary = manifest[key]
	var sheet: String = entry.sheet
	if not sheets.has(sheet):
		var canvas := Canvas.new()
		canvas.src = "res://assets/sprites/" + sheet
		sheets[sheet] = canvas
	var sprite := Canvas.new()
	var r: Array = entry.region
	var rect := Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3]))
	sprite.width = rect.size.x
	sprite.height = rect.size.y
	sprite.image = sheets[sheet].image.get_region(rect)
	sprite.atlas_source = sheets[sheet]
	sprite.atlas_region = rect
	sprites[key] = sprite
	return sprite

func draw(context: Variant, key: String, x: float, y: float) -> bool:
	var sprite: Variant = get_sprite(key)
	if sprite == null: return false
	var offset: Array = manifest[key].get("offset", [0, 0])
	context.drawImage(sprite, x + float(offset[0]), y + float(offset[1]))
	return true
