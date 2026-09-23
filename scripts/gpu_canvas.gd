# Screen-only Canvas adapter. Images stay on the GPU; offscreen asset baking uses PixelCanvas.
extends "res://scripts/pixel_canvas.gd"

var items: Array[RID] = []
var item_index := 0
var parent_item: RID
var textures: Dictionary = {}
var texture_uploads := 0
var draw_commands := 0
var gray_material: ShaderMaterial

func attach(parent: RID) -> void:
	parent_item = parent
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
void fragment() {
 vec4 s = textureLod(screen_texture, SCREEN_UV, 0.0);
 float lum = dot(s.rgb, vec3(0.3, 0.59, 0.11));
 COLOR = vec4(mix(s.rgb, vec3(lum), COLOR.a), 1.0);
}"""
	gray_material = ShaderMaterial.new()
	gray_material.shader = shader
	begin_frame()

func begin_frame() -> void:
	for rid in items:
		RenderingServer.canvas_item_clear(rid)
		RenderingServer.canvas_item_set_material(rid, RID())
		RenderingServer.canvas_item_set_copy_to_backbuffer(rid, false, Rect2())
	item_index = 0
	draw_commands = 0
	texture_uploads = 0
	current_item()
	if textures.size() > 512:
		for id in textures.keys():
			if textures[id].source.get_ref() == null: textures.erase(id)

func current_item() -> RID:
	if item_index == items.size():
		var rid := RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(rid, parent_item)
		RenderingServer.canvas_item_set_draw_index(rid, item_index)
		RenderingServer.canvas_item_set_default_texture_filter(rid, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
		items.append(rid)
	return items[item_index]

func paint(r: Rect2i, c: Color) -> void:
	if not r.has_area(): return
	c.a *= clampf(float(globalAlpha), 0, 1)
	if c.a <= 0: return
	if globalCompositeOperation == "saturation":
		item_index += 1
		var rid := current_item()
		RenderingServer.canvas_item_set_copy_to_backbuffer(rid, true, Rect2(r))
		RenderingServer.canvas_item_set_material(rid, gray_material.get_rid())
		RenderingServer.canvas_item_add_rect(rid, Rect2(r), Color(1, 1, 1, c.a))
		item_index += 1
	else:
		RenderingServer.canvas_item_add_rect(current_item(), Rect2(r), c)
	draw_commands += 1

func texture_for(source: Variant) -> Texture2D:
	var id: int = source.get_instance_id()
	var entry: Dictionary = textures.get(id, {})
	if entry.is_empty() or entry.source.get_ref() != source:
		entry = {"source": weakref(source), "generation": source.generation, "texture": ImageTexture.create_from_image(source.image)}
		textures[id] = entry
		texture_uploads += 1
	elif entry.generation != source.generation:
		if Vector2i(entry.texture.get_size()) == source.image.get_size(): entry.texture.update(source.image)
		else: entry.texture = ImageTexture.create_from_image(source.image)
		entry.generation = source.generation
		texture_uploads += 1
	return entry.texture

func drawImage(source: Variant, a: Variant, b: Variant, c: Variant = null, d: Variant = null, e: Variant = null, f: Variant = null, g: Variant = null, h: Variant = null) -> Variant:
	if source == null: return null
	source.ensure()
	var sr := Rect2(0, 0, int(source.width), int(source.height))
	var dr := Rect2(float(a), float(b), sr.size.x, sr.size.y)
	if e != null:
		sr = Rect2(int(a), int(b), int(c), int(d))
		dr = Rect2(float(e), float(f), float(g), float(h))
	elif c != null: dr.size = Vector2(float(c), float(d))
	if not sr.has_area() or not dr.has_area(): return null
	# Matches the legacy canvas's nearest-neighbour rectangle and flip rules.
	var p0 := transform * dr.position
	var p1 := transform * dr.end
	var dest := Vector2(round(minf(p0.x, p1.x)), round(minf(p0.y, p1.y)))
	var size := Vector2(round(absf(p1.x - p0.x)), round(absf(p1.y - p0.y)))
	if size.x <= 0 or size.y <= 0: return null
	var cropped := Rect2(dest, size).intersection(Rect2(clip_rect)).intersection(Rect2(0, 0, int(width), int(height)))
	if not cropped.has_area(): return null
	var ratio := sr.size / size
	var offset := cropped.position - dest
	var flip_x := p1.x < p0.x
	var flip_y := p1.y < p0.y
	var region := Rect2(sr.position + offset * ratio, cropped.size * ratio)
	if flip_x: region.position.x = sr.end.x - (offset.x + cropped.size.x) * ratio.x
	if flip_y: region.position.y = sr.end.y - (offset.y + cropped.size.y) * ratio.y
	var target := cropped
	if flip_x: target.size.x *= -1
	if flip_y: target.size.y *= -1
	var texture_source: Variant = source
	if source.atlas_source != null:
		texture_source = source.atlas_source
		region.position += Vector2(source.atlas_region.position)
	var tex := texture_for(texture_source)
	RenderingServer.canvas_item_add_texture_rect_region(current_item(), target, tex.get_rid(), region, Color(1, 1, 1, clampf(float(globalAlpha), 0, 1)), false, true)
	draw_commands += 1
	return null

func release() -> void:
	for rid in items: RenderingServer.free_rid(rid)
	items.clear()
	textures.clear()
	gray_material = null
