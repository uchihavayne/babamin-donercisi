# Original pixel algorithms expressed directly in GDScript for hot drawing paths.
#
# REMAKE: hedef ekran tuvaliyse (gpu_canvas.gd) her primitif renk metnini
# BIR KEZ cozer (onbellek) ve tuvalin rect_fast yoluna tam sayi koordinatla
# gider. Hedef bir CPU onbellek tuvaliyse (arka plan/tezgah pisirme) eski
# fillStyle + fillRect yolu AYNEN calisir. Iki yolun uretecegi pikseller
# ayni: koordinatlar zaten tam sayiya cevriliyordu.
extends Node2D
const GpuCanvas = preload("res://scripts/gpu_canvas.gd")
const PixelCanvas = preload("res://scripts/pixel_canvas.gd")
var draw_context: Variant
static var _renkler: Dictionary = {}

# fillStyle ayarlayicisi "nan" iceren metni YOK SAYIYOR (onceki renk kalir);
# hizli yolda da ayni davranis: onceki renk = tuvalin o anki rengi.
func _renk(c: Variant) -> Color:
	var r: Variant = _renkler.get(c)
	if r != null: return r
	var metin := str(c)
	if "nan" in metin.to_lower(): return draw_context.color
	var col := PixelCanvas.parse_color(metin)
	if _renkler.size() > 8192: _renkler.clear()
	_renkler[c] = col
	return col

func f_cls(c: Variant = null) -> Variant:
	if draw_context is GpuCanvas:
		draw_context.rect_fast(0, 0, 480, 270, _renk(c))
		return null
	draw_context.fillStyle = c
	draw_context.fillRect(0, 0, 480, 270)
	return null
func f_fr(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, c: Variant = null) -> Variant:
	if draw_context is GpuCanvas:
		draw_context.rect_fast(int(x), int(y), int(w), int(h), _renk(c))
		return null
	draw_context.fillStyle = c
	draw_context.fillRect(int(x), int(y), int(w), int(h))
	return null
func f_px(x: Variant = null, y: Variant = null, c: Variant = null) -> Variant:
	if draw_context is GpuCanvas:
		draw_context.rect_fast(int(x), int(y), 1, 1, _renk(c))
		return null
	draw_context.fillStyle = c
	draw_context.fillRect(int(x), int(y), 1, 1)
	return null
func f_hl(x: Variant = null, y: Variant = null, w: Variant = null, c: Variant = null) -> Variant:
	return f_fr(x, y, w, 1, c)
func f_vl(x: Variant = null, y: Variant = null, h: Variant = null, c: Variant = null) -> Variant:
	return f_fr(x, y, 1, h, c)
func f_rc(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, c: Variant = null) -> Variant:
	x = int(x); y = int(y); w = int(w); h = int(h)
	f_fr(x, y, w, 1, c); f_fr(x, y + h - 1, w, 1, c)
	f_fr(x, y, 1, h, c); f_fr(x + w - 1, y, 1, h, c)
	return null
func f_ln(x0: Variant = null, y0: Variant = null, x1: Variant = null, y1: Variant = null, c: Variant = null) -> Variant:
	x0 = int(x0); y0 = int(y0); x1 = int(x1); y1 = int(y1)
	var dx: int = absi(x1 - x0)
	var sx: int = 1 if x0 < x1 else -1
	var dy: int = -absi(y1 - y0)
	var sy: int = 1 if y0 < y1 else -1
	var err: int = dx + dy
	var gpu: bool = draw_context is GpuCanvas
	var col: Color = _renk(c) if gpu else Color.BLACK
	if not gpu: draw_context.fillStyle = c
	for i in 999:
		if gpu: draw_context.rect_fast(x0, y0, 1, 1, col)
		else: draw_context.fillRect(x0, y0, 1, 1)
		if x0 == x1 and y0 == y1: break
		var e2: int = 2 * err
		if e2 >= dy: err += dy; x0 += sx
		if e2 <= dx: err += dx; y0 += sy
	return null
func f_disc(cx: Variant = null, cy: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	cx = floor(float(cx) + .5); cy = floor(float(cy) + .5)
	var gpu: bool = draw_context is GpuCanvas
	var col: Color = _renk(c) if gpu else Color.BLACK
	if not gpu: draw_context.fillStyle = c
	var rf: float = float(r)
	var y: float = -rf
	while y <= rf:
		var w: int = int(floor(sqrt(maxf(0, rf * rf - y * y)) + .5))
		if w > 0 or rf == 0:
			if gpu: draw_context.rect_fast(int(cx) - w, int(floor(cy + y + .5)), w * 2 + 1, 1, col)
			else: draw_context.fillRect(cx - w, cy + y, w * 2 + 1, 1)
		y += 1
	return null
func f_ring(cx: Variant = null, cy: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	cx = floor(float(cx) + .5); cy = floor(float(cy) + .5)
	var x: float = float(r)
	var y := 0.0
	var e: float = 1.0 - r
	var gpu: bool = draw_context is GpuCanvas
	var col: Color = _renk(c) if gpu else Color.BLACK
	if not gpu: draw_context.fillStyle = c
	while x >= y:
		for p in [Vector2(x,y),Vector2(y,x),Vector2(-x,y),Vector2(-y,x),Vector2(-x,-y),Vector2(-y,-x),Vector2(x,-y),Vector2(y,-x)]:
			if gpu: draw_context.rect_fast(int(floor(cx + p.x + .5)), int(floor(cy + p.y + .5)), 1, 1, col)
			else: draw_context.fillRect(cx + p.x, cy + p.y, 1, 1)
		y += 1
		if e < 0: e += 2 * y + 1
		else: x -= 1; e += 2 * (y - x) + 1
	return null
func f_ell(cx: Variant = null, cy: Variant = null, rx: Variant = null, ry: Variant = null, c: Variant = null) -> Variant:
	cx = floor(float(cx) + .5); cy = floor(float(cy) + .5)
	var gpu: bool = draw_context is GpuCanvas
	var col: Color = _renk(c) if gpu else Color.BLACK
	if not gpu: draw_context.fillStyle = c
	var y: float = -float(ry)
	if ry == 0: return null
	while y <= ry:
		var t: float = 1.0 - (y * y) / float(ry * ry)
		if t >= 0:
			var w: int = int(floor(rx * sqrt(t) + .5))
			if gpu: draw_context.rect_fast(int(cx) - w, int(floor(cy + y + .5)), w * 2 + 1, 1, col)
			else: draw_context.fillRect(cx - w, cy + y, w * 2 + 1, 1)
		y += 1
	return null
func f_ellOut(cx: Variant = null, cy: Variant = null, rx: Variant = null, ry: Variant = null, c: Variant = null) -> Variant:
	cx = floor(float(cx) + .5); cy = floor(float(cy) + .5)
	draw_context.fillStyle = c
	var previous := -1
	var y: float = -float(ry)
	if ry == 0: return null
	while y <= ry:
		var t: float = 1.0 - (y * y) / float(ry * ry)
		if t >= 0:
			var w: int = int(floor(rx * sqrt(t) + .5))
			if y == -ry or y == ry: draw_context.fillRect(cx - w, cy + y, w * 2 + 1, 1)
			else:
				draw_context.fillRect(cx - w, cy + y, 1, 1)
				draw_context.fillRect(cx + w, cy + y, 1, 1)
			if previous >= 0 and absi(w - previous) > 1:
				var lo := mini(w, previous)
				var hi := maxi(w, previous)
				draw_context.fillRect(cx - hi, cy + y, hi - lo, 1)
				draw_context.fillRect(cx + lo, cy + y, hi - lo, 1)
			previous = w
		y += 1
	return null
func f_rrect(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	x = int(x); y = int(y); w = int(w); h = int(h)
	if draw_context is GpuCanvas:
		var col: Color = _renk(c)
		var ri := int(r)
		# r ondalikli gelebilir; CPU yolu gibi float hesaplayip fillRect'in
		# yuvarlamasina birak: tam sayi degilse genel yol
		if float(ri) != float(r):
			draw_context.fillStyle = c
			_rrect_genel(x, y, w, h, r)
			return null
		draw_context.rect_fast(x + ri, y, w - ri * 2, h, col)
		draw_context.rect_fast(x, y + ri, ri, h - ri * 2, col)
		draw_context.rect_fast(x + w - ri, y + ri, ri, h - ri * 2, col)
		for i in range(ri):
			var d: int = int(floor(r - sqrt(r * r - (r - i - 1) * (r - i - 1)) + .5))
			draw_context.rect_fast(x + d, y + i, w - d * 2, 1, col)
			draw_context.rect_fast(x + d, y + h - 1 - i, w - d * 2, 1, col)
		return null
	draw_context.fillStyle = c
	_rrect_genel(x, y, w, h, r)
	return null
func _rrect_genel(x: int, y: int, w: int, h: int, r: Variant) -> void:
	draw_context.fillRect(x + r, y, w - r * 2, h)
	draw_context.fillRect(x, y + r, r, h - r * 2)
	draw_context.fillRect(x + w - r, y + r, r, h - r * 2)
	for i in range(int(ceil(r))):
		var d: float = floor(r - sqrt(r * r - (r - i - 1) * (r - i - 1)) + .5)
		draw_context.fillRect(x + d, y + i, w - d * 2, 1)
		draw_context.fillRect(x + d, y + h - 1 - i, w - d * 2, 1)
func f_rrectOut(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, r: Variant = null, c: Variant = null) -> Variant:
	x = int(x); y = int(y); w = int(w); h = int(h)
	draw_context.fillStyle = c
	draw_context.fillRect(x + r, y, w - r * 2, 1)
	draw_context.fillRect(x + r, y + h - 1, w - r * 2, 1)
	draw_context.fillRect(x, y + r, 1, h - r * 2)
	draw_context.fillRect(x + w - 1, y + r, 1, h - r * 2)
	for i in range(int(ceil(r))):
		var d: float = floor(r - sqrt(r * r - (r - i - 1) * (r - i - 1)) + .5)
		draw_context.fillRect(x + d, y + i, 1, 1)
		draw_context.fillRect(x + w - 1 - d, y + i, 1, 1)
		draw_context.fillRect(x + d, y + h - 1 - i, 1, 1)
		draw_context.fillRect(x + w - 1 - d, y + h - 1 - i, 1, 1)
	return null
func f_dith(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, c: Variant = null, amount: Variant = null) -> Variant:
	x = int(x); y = int(y)
	var gpu: bool = draw_context is GpuCanvas
	var col: Color = _renk(c) if gpu else Color.BLACK
	if not gpu: draw_context.fillStyle = c
	var bayer: Array = [0,8,2,10,12,4,14,6,3,11,1,9,15,7,13,5]
	var threshold: float = float(amount) * 16
	for j in range(int(ceil(h))):
		for i in range(int(ceil(w))):
			if bayer[((j & 3) << 2) | (i & 3)] < threshold:
				if gpu: draw_context.rect_fast(x + i, y + j, 1, 1, col)
				else: draw_context.fillRect(x + i, y + j, 1, 1)
	return null
