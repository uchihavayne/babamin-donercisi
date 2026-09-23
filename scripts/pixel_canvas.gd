# Native CPU pixel canvas. All drawing stays in Godot's Image resources.
extends RefCounted

var image: Image
var atlas_source: Variant = null
var atlas_region := Rect2i()
var width: Variant = 300:
	set(v):
		width = maxi(1, int(v))
		image = null
var height: Variant = 150:
	set(v):
		height = maxi(1, int(v))
		image = null
var naturalWidth: Variant = 0
var naturalHeight: Variant = 0
var fillStyle: Variant = "#000":
	set(v):
		if fillStyle == v or "nan" in str(v).to_lower(): return
		fillStyle = v
		color = parse_color(str(v))
var globalAlpha: Variant = 1.0
var globalCompositeOperation: Variant = "source-over"
var imageSmoothingEnabled: Variant = false
var src: Variant = "":
	set(v):
		src = v
		var resource: Variant = load(str(v))
		var loaded: Image = resource.get_image() if resource is Texture2D else resource
		if loaded != null:
			loaded.convert(Image.FORMAT_RGBA8)
			width = loaded.get_width()
			height = loaded.get_height()
			naturalWidth = width
			naturalHeight = height
			image = loaded
var color := Color.BLACK
var transform := Transform2D.IDENTITY
var clip_rect := Rect2i(-100000, -100000, 200000, 200000)
var stack: Array = []
var path: PackedVector2Array = []
var generation: int = 0
var image_cache: Dictionary = {}
static var colors: Dictionary = {}
static var swatches: Dictionary = {}

static func parse_color(value: String) -> Color:
	if colors.has(value): return colors[value]
	var c: Color
	if value.begins_with("rgba(") or value.begins_with("rgb("):
		var values := value.substr(value.find("(") + 1).trim_suffix(")").split(",")
		c = Color(float(values[0]) / 255, float(values[1]) / 255, float(values[2]) / 255, float(values[3]) if values.size() > 3 else 1.0)
	else: c = Color.from_string(value, Color.BLACK)
	colors[value] = c
	return c

func ensure() -> void:
	if image == null:
		image = Image.create(int(width), int(height), false, Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)
		generation += 1

func getContext(_kind: Variant = null, _opts: Variant = null) -> Variant:
	ensure()
	return self

func save() -> Variant:
	stack.append([transform, clip_rect, fillStyle, globalAlpha, globalCompositeOperation])
	return null

func restore() -> Variant:
	if not stack.is_empty():
		var state: Array = stack.pop_back()
		transform = state[0]
		clip_rect = state[1]
		fillStyle = state[2]
		globalAlpha = state[3]
		globalCompositeOperation = state[4]
	return null

func translate(x: Variant, y: Variant) -> Variant:
	transform = transform * Transform2D(0, Vector2(float(x), float(y)))
	return null

func scale(x: Variant, y: Variant) -> Variant:
	transform = transform * Transform2D(Vector2(float(x), 0), Vector2(0, float(y)), Vector2.ZERO)
	return null

func rotate(angle: Variant) -> Variant:
	transform = transform * Transform2D(float(angle), Vector2.ZERO)
	return null

func bounds(r: Rect2) -> Rect2i:
	var x0: float = r.position.x * transform.x.x + transform.origin.x
	var y0: float = r.position.y * transform.y.y + transform.origin.y
	var x1: float = (r.position.x + r.size.x) * transform.x.x + transform.origin.x
	var y1: float = (r.position.y + r.size.y) * transform.y.y + transform.origin.y
	var left: int = int(floor(minf(x0, x1) + .5))
	var top: int = int(floor(minf(y0, y1) + .5))
	var right: int = left + int(floor(absf(x1 - x0) + .5))
	var bottom: int = top + int(floor(absf(y1 - y0) + .5))
	left = maxi(left, maxi(0, clip_rect.position.x))
	top = maxi(top, maxi(0, clip_rect.position.y))
	right = mini(right, mini(int(width), clip_rect.end.x))
	bottom = mini(bottom, mini(int(height), clip_rect.end.y))
	return Rect2i(left, top, maxi(0, right - left), maxi(0, bottom - top))

func fillRect(x: Variant, y: Variant, w: Variant, h: Variant) -> Variant:
	if image == null: ensure()
	if absf(transform.x.y) > 0.001 or absf(transform.y.x) > 0.001:
		var old_path := path
		path = PackedVector2Array([transform * Vector2(x, y), transform * Vector2(x + w, y), transform * Vector2(x + w, y + h), transform * Vector2(x, y + h)])
		fill()
		path = old_path
		return null
	paint(bounds(Rect2(float(x), float(y), float(w), float(h))), color)
	return null

func paint(r: Rect2i, c: Color) -> void:
	if r.size.x <= 0 or r.size.y <= 0: return
	c.a *= clampf(float(globalAlpha), 0, 1)
	if c.a <= 0: return
	generation += 1
	if not image_cache.is_empty(): image_cache.clear()
	if r.size.x == 1 and r.size.y == 1 and globalCompositeOperation == "source-over":
		image.set_pixel(r.position.x, r.position.y, c if c.a >= .999 else image.get_pixel(r.position.x, r.position.y).blend(c))
		return
	if globalCompositeOperation == "saturation":
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				var dst := image.get_pixel(x, y)
				var lum := dst.r * .3 + dst.g * .59 + dst.b * .11
				image.set_pixel(x, y, dst.lerp(Color(lum, lum, lum, dst.a), c.a))
	elif c.a >= 0.999: image.fill_rect(r, c)
	else:
		var key := Vector3i(r.size.x, r.size.y, c.to_rgba32())
		if not swatches.has(key):
			if swatches.size() > 512: swatches.clear()
			var patch := Image.create(r.size.x, r.size.y, false, Image.FORMAT_RGBA8)
			patch.fill(c)
			swatches[key] = patch
		image.blend_rect(swatches[key], Rect2i(Vector2i.ZERO, r.size), r.position)

func clearRect(x: Variant, y: Variant, w: Variant, h: Variant) -> Variant:
	ensure()
	image.fill_rect(bounds(Rect2(x, y, w, h)), Color.TRANSPARENT)
	generation += 1
	image_cache.clear()
	return null

func beginPath() -> Variant:
	path.clear()
	return null

func rect(x: Variant, y: Variant, w: Variant, h: Variant) -> Variant:
	path = PackedVector2Array([transform * Vector2(x, y), transform * Vector2(x + w, y), transform * Vector2(x + w, y + h), transform * Vector2(x, y + h)])
	return null

func clip() -> Variant:
	if path.is_empty(): return null
	var box := Rect2(path[0], Vector2.ZERO)
	for point in path: box = box.expand(point)
	clip_rect = clip_rect.intersection(Rect2i(box))
	return null

func moveTo(x: Variant, y: Variant) -> Variant:
	path.append(transform * Vector2(x, y))
	return null

func lineTo(x: Variant, y: Variant) -> Variant:
	path.append(transform * Vector2(x, y))
	return null

func closePath() -> Variant: return null

func fill() -> Variant:
	ensure()
	if path.size() < 3: return null
	var box := Rect2(path[0], Vector2.ZERO)
	for point in path: box = box.expand(point)
	for y in range(maxi(0, int(floor(box.position.y))), mini(int(height), int(ceil(box.end.y)))):
		var intersections: Array[float] = []
		var py := y + 0.5
		for i in path.size():
			var a := path[i]
			var b := path[(i + 1) % path.size()]
			if (a.y <= py and b.y > py) or (b.y <= py and a.y > py):
				intersections.append(a.x + (py - a.y) * (b.x - a.x) / (b.y - a.y))
		intersections.sort()
		for i in range(0, intersections.size() - 1, 2):
			var left := int(ceil(intersections[i] - .5))
			var right := int(ceil(intersections[i + 1] - .5))
			paint(Rect2i(left, y, right - left, 1).intersection(clip_rect).intersection(Rect2i(0, 0, int(width), int(height))), color)
	return null

func drawImage(source: Variant, a: Variant, b: Variant, c: Variant = null, d: Variant = null, e: Variant = null, f: Variant = null, g: Variant = null, h: Variant = null) -> Variant:
	if source == null: return null
	ensure()
	source.ensure()
	var sr := Rect2i(0, 0, int(source.width), int(source.height))
	var dr := Rect2(float(a), float(b), sr.size.x, sr.size.y)
	if e != null:
		sr = Rect2i(int(a), int(b), int(c), int(d))
		dr = Rect2(float(e), float(f), float(g), float(h))
	elif c != null: dr.size = Vector2(float(c), float(d))
	if sr.size.x <= 0 or sr.size.y <= 0 or dr.size.x <= 0 or dr.size.y <= 0: return null
	var p0 := transform * dr.position
	var p1 := transform * dr.end
	var dest := Vector2i(round(minf(p0.x, p1.x)), round(minf(p0.y, p1.y)))
	var size := Vector2i(round(absf(p1.x - p0.x)), round(absf(p1.y - p0.y)))
	if size.x <= 0 or size.y <= 0: return null
	var cropped := Rect2i(dest, size).intersection(clip_rect).intersection(Rect2i(0, 0, int(width), int(height)))
	if cropped.size.x <= 0 or cropped.size.y <= 0: return null
	var img: Image = source.image
	var flip_x := p1.x < p0.x
	var flip_y := p1.y < p0.y
	var alpha: float = clampf(float(globalAlpha), 0, 1)
	if size != sr.size or flip_x or flip_y or alpha < .999:
		var key := str(sr) + str(size) + str(flip_x) + str(flip_y) + str(int(alpha * 255))
		if source.image_cache.has(key): img = source.image_cache[key]
		else:
			img = img.get_region(sr)
			if size != sr.size: img.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
			if flip_x: img.flip_x()
			if flip_y: img.flip_y()
			if alpha < .999:
				var bytes := img.get_data()
				for i in range(3, bytes.size(), 4): bytes[i] = int(bytes[i] * alpha)
				img.set_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, bytes)
			if source.image_cache.size() > 512: source.image_cache.clear()
			source.image_cache[key] = img
		sr = Rect2i(Vector2i.ZERO, size)
	sr.position += cropped.position - dest
	sr.size = cropped.size
	if globalCompositeOperation == "destination-in":
		for y in int(height):
			for x in int(width):
				var dst := image.get_pixel(x, y)
				if cropped.has_point(Vector2i(x, y)):
					var sample := img.get_pixel(x - cropped.position.x + sr.position.x, y - cropped.position.y + sr.position.y)
					dst.a *= sample.a
				else: dst.a = 0
				image.set_pixel(x, y, dst)
	else: image.blend_rect(img, sr, cropped.position)
	generation += 1
	image_cache.clear()
	return null

func getImageData(x: Variant, y: Variant, w: Variant, h: Variant) -> Variant:
	ensure()
	return {"width": int(w), "height": int(h), "data": Array(image.get_region(Rect2i(int(x), int(y), int(w), int(h))).get_data())}

func putImageData(value: Variant, x: Variant, y: Variant) -> Variant:
	ensure()
	var replacement := Image.create_from_data(int(value.width), int(value.height), false, Image.FORMAT_RGBA8, PackedByteArray(value.data))
	image.blit_rect(replacement, Rect2i(0, 0, int(value.width), int(value.height)), Vector2i(int(x), int(y)))
	generation += 1
	image_cache.clear()
	return null
