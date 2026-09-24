# EKRAN KARTINDA CIZEN TUVAL
#
# pixel_canvas.gd ile AYNI API (HTML Canvas 2D'nin oyunun kullandigi alt
# kumesi: fillStyle, fillRect, globalAlpha, save/restore, translate/scale/
# rotate, rect+clip, moveTo/lineTo+fill, drawImage). Fark: pikselleri
# islemcide bir Image'a boyamak yerine her kareyi RenderingServer komutlarina
# ceviriyor.
#
# Neden: aktarimda ana ekran her kare binlerce fillRect ile GDScript icinde
# piksel piksel boyaniyordu. Ryzen 5 3600X'te baslik ekrani kare basina
# ~123 ms (saniyede 8 kare) tutuyordu; telefonda hic oynanamazdi.
#
# PIKSEL SADAKATI: dikdortgenler ve resimler CPU tuvaliyle BIREBIR ayni
# yuvarlama kuraliyla (bounds) tam sayi piksellere oturtulur ve kirpma
# yazilimda yapilir. Boylece 2x olcekte yari-piksel kaymasi, karisik
# boyutlu pikseller olusmaz. Dolgu yolu (fill) da ayni satir tarama
# algoritmasiyla dikdortgenlere cevrilir.
#
# Toplu cizim: ardisik dikdortgenler tek bir ucgen dizisinde birikir ve
# tek RenderingServer cagrisiyla gider. Bir resim cizimi ya da ozel
# karisim (saturation) araya girince birikinti bosaltilir; sira korunur.
#
# Ekran disi onbellek tuvalleri (arka plan, tezgah, yazi) hala CPU
# tuvali (pixel_canvas.gd); bu tuval onlari drawImage ile doku olarak
# ciziyor ve yalniz degistiklerinde (generation) GPU'ya yukluyor.
extends RefCounted

const Canvas = preload("res://scripts/pixel_canvas.gd")

var width: Variant = 480
var height: Variant = 270
var naturalWidth: Variant = 480
var naturalHeight: Variant = 270
var fillStyle: Variant = "#000":
	set(v):
		if fillStyle == v or "nan" in str(v).to_lower(): return
		fillStyle = v
		color = Canvas.parse_color(str(v))
var globalAlpha: Variant = 1.0
var globalCompositeOperation: Variant = "source-over"
var imageSmoothingEnabled: Variant = false
var color := Color.BLACK
var transform := Transform2D.IDENTITY
var clip_rect := Rect2i(-100000, -100000, 200000, 200000)
var stack: Array = []
var path: PackedVector2Array = []
var generation: int = 0
var image: Image = null          # uyumluluk: ekran tuvalinin CPU goruntusu YOK

# --- RenderingServer durumu ---
var root: RID
var pool: Array[RID] = []
var used: int = 0
var item: RID
var item_mat: RID = RID()     # segmentin malzemesi (bos = duz renk/doku)
var sat_material: RID
var sat_shader: RID
# SIYAH-BEYAZ KIP (remake): dukkan ekraninin arka plani eskiden CPU'da
# pisirilip getImageData ile gri tona cevriliyordu (ui.js bakeShop). HD
# cizim canli GPU'da; ayni ton formulu her ilkele malzemeyle uygulanir.
# Formul afin (v*.8+44): yari saydam karisimda da ayni sonucu verir.
var mono := false
# ekran disi pisirme tuvali mi (gpu_bake.gd): getImageData "dolu" doner
var bake := false
# cizim komutlarinin kullandigi malzeme kaynaklarini canli tut (pisirme
# viewport'u sonradan render ettigi icin ShaderMaterial erken silinmesin)
var tutulan: Array = []
# KAYIT / OYNATMA (remake): girdisi ayni kaldikca ayni cizimi ureten pahali
# fonksiyonlar (tepsi dolgusu...) bir kez kaydedilip sonraki karelerde hazir
# ilkel listesinden basilir. Kayit mutlak ekran koordinatinda tutulur;
# oynatirken kamera sarsintisi gibi otelemeler eklenir.
var _kayitta := false
var _kayit: Array = []
var mono_material: RID
var mono_kar_material: RID
var mono_kar_shader: RID
var mono_k := 1.0
var mono_shader: RID
# pisirme dokulari (gpu_bake) on-carpilmis alfa tasir: saydam zemine yari saydam
# cizim renk*alfa birakir, normal karisimla basilinca ikinci kez alfa ile carpilip
# koyulasiyordu (vitrin cami)
var premul_material: RID
var premul_mono_material: RID
var premul_shader: RID
var premul_mono_shader: RID
var bp := PackedVector2Array()
var bc := PackedColorArray()
var bi := PackedInt32Array()
var textures: Dictionary = {}    # instance_id -> [ImageTexture, generation, Vector2i]
const TOPLU_TAVAN := 60000       # tek ucgen dizisindeki en fazla kose

# istatistik (olcum icin)
var stat_rects: int = 0
var stat_images: int = 0
var stat_batches: int = 0

const SAT_KOD := "shader_type canvas_item;\nuniform sampler2D ekran : hint_screen_texture, filter_nearest;\nvoid fragment() {\n\tvec4 d = texture(ekran, SCREEN_UV);\n\tfloat l = dot(d.rgb, vec3(0.3, 0.59, 0.11));\n\tCOLOR = vec4(vec3(l), COLOR.a);\n}\n"

const MONO_KOD := "shader_type canvas_item;
void fragment() {
	vec4 c = COLOR;
	float v = dot(c.rgb, vec3(0.32, 0.55, 0.13)) * 0.8 + 44.0 / 255.0;
	COLOR = vec4(v, v, min(1.0, v * 1.02), c.a);
}
"

# BIRLESIK (6. tur, madde 8): kismi gri (k: 0 renkli .. 1 tam gri); dukkanda
# yeni alinan istasyon griden renge gecip yavasca geri doner.
const MONO_KAR_KOD := "shader_type canvas_item;
uniform float k = 1.0;
void fragment() {
	vec4 c = COLOR;
	float v = dot(c.rgb, vec3(0.32, 0.55, 0.13)) * 0.8 + 44.0 / 255.0;
	COLOR = vec4(mix(c.rgb, vec3(v, v, min(1.0, v * 1.02)), k), c.a);
}
"

const PREMUL_KOD := "shader_type canvas_item;
render_mode blend_premul_alpha;
"
const PREMUL_MONO_KOD := "shader_type canvas_item;
render_mode blend_premul_alpha;
void fragment() {
	vec4 c = COLOR;
	float v = dot(c.rgb, vec3(0.32, 0.55, 0.13)) * 0.8 + 44.0 / 255.0 * c.a;
	COLOR = vec4(v, v, min(c.a, v * 1.02), c.a);
}
"

func _premul() -> RID:
	return premul_mono_material if mono else premul_material

func _varsayilan() -> RID:
	if mono and mono_k < 0.999 and mono_kar_material.is_valid(): return mono_kar_material
	return mono_material if mono else RID()

func mono_kar(k: float) -> void:
	mono_k = k
	if mono_kar_material.is_valid(): RenderingServer.material_set_param(mono_kar_material, "k", k)

func setup(parent_item: RID, olcek: float) -> void:
	root = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(root, parent_item)
	RenderingServer.canvas_item_set_transform(root, Transform2D().scaled(Vector2(olcek, olcek)))
	sat_shader = RenderingServer.shader_create()
	RenderingServer.shader_set_code(sat_shader, SAT_KOD)
	sat_material = RenderingServer.material_create()
	RenderingServer.material_set_shader(sat_material, sat_shader)
	mono_shader = RenderingServer.shader_create()
	RenderingServer.shader_set_code(mono_shader, MONO_KOD)
	mono_material = RenderingServer.material_create()
	RenderingServer.material_set_shader(mono_material, mono_shader)
	mono_kar_shader = RenderingServer.shader_create()
	RenderingServer.shader_set_code(mono_kar_shader, MONO_KAR_KOD)
	mono_kar_material = RenderingServer.material_create()
	RenderingServer.material_set_shader(mono_kar_material, mono_kar_shader)
	premul_shader = RenderingServer.shader_create()
	RenderingServer.shader_set_code(premul_shader, PREMUL_KOD)
	premul_material = RenderingServer.material_create()
	RenderingServer.material_set_shader(premul_material, premul_shader)
	premul_mono_shader = RenderingServer.shader_create()
	RenderingServer.shader_set_code(premul_mono_shader, PREMUL_MONO_KOD)
	premul_mono_material = RenderingServer.material_create()
	RenderingServer.material_set_shader(premul_mono_material, premul_mono_shader)

func free_resources() -> void:
	for it in pool: RenderingServer.free_rid(it)
	pool.clear()
	if root.is_valid(): RenderingServer.free_rid(root)
	if sat_material.is_valid(): RenderingServer.free_rid(sat_material)
	if sat_shader.is_valid(): RenderingServer.free_rid(sat_shader)
	if mono_material.is_valid(): RenderingServer.free_rid(mono_material)
	if mono_shader.is_valid(): RenderingServer.free_rid(mono_shader)
	for r in [premul_material, premul_mono_material, premul_shader, premul_mono_shader, mono_kar_material, mono_kar_shader]:
		if r.is_valid(): RenderingServer.free_rid(r)
	textures.clear()

func ensure() -> void: pass

# BIRLESIK SURUM: kebap-shop tabaninin ekran tuvali arayuzu (attach/release,
# texture_uploads/draw_commands sayaclari) ayni sinifta; olcek her zaman 2x.
var texture_uploads := 0
var draw_commands: int:
	get: return stat_rects + stat_images
func attach(parent_item: RID) -> void:
	setup(parent_item, 2.0)
	begin_frame()
func release() -> void:
	free_resources()

func getContext(_kind: Variant = null, _opts: Variant = null) -> Variant:
	return self

# ---------------------------------------------------------------- kare
func begin_frame() -> void:
	for i in used: RenderingServer.canvas_item_clear(pool[i])
	used = 0
	bp.clear(); bc.clear(); bi.clear()
	transform = Transform2D.IDENTITY
	clip_rect = Rect2i(-100000, -100000, 200000, 200000)
	stack.clear()
	globalAlpha = 1.0
	globalCompositeOperation = "source-over"
	mono = false
	stat_rects = 0; stat_images = 0; stat_batches = 0
	_segment(RID())

func end_frame() -> void:
	_flush()

func _segment(mat: RID) -> void:
	_flush()
	if used >= pool.size():
		var it := RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(it, root)
		RenderingServer.canvas_item_set_draw_index(it, pool.size())
		pool.append(it)
	item = pool[used]
	used += 1
	item_mat = mat
	RenderingServer.canvas_item_set_material(item, mat)

func _flush() -> void:
	if bp.is_empty(): return
	RenderingServer.canvas_item_add_triangle_array(item, bi, bp, bc)
	stat_batches += 1
	bp.clear(); bc.clear(); bi.clear()

func _push(r: Rect2i, c: Color) -> void:
	var istenen: RID = sat_material if globalCompositeOperation == "saturation" else _varsayilan()
	if istenen != item_mat: _segment(istenen)
	var n := bp.size()
	if n >= TOPLU_TAVAN:
		_flush()
		n = 0
	var x0 := float(r.position.x)
	var y0 := float(r.position.y)
	var x1 := float(r.end.x)
	var y1 := float(r.end.y)
	bp.append(Vector2(x0, y0)); bp.append(Vector2(x1, y0)); bp.append(Vector2(x1, y1)); bp.append(Vector2(x0, y1))
	bc.append(c); bc.append(c); bc.append(c); bc.append(c)
	bi.append(n); bi.append(n + 1); bi.append(n + 2); bi.append(n); bi.append(n + 2); bi.append(n + 3)
	stat_rects += 1
	if _kayitta: _kayit.append([0, x0, y0, x1, y1, c, item_mat])

# ---------------------------------------------------------------- durum
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

# pixel_canvas.gd:bounds ile birebir ayni yuvarlama
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

# OLCEKLI HD (birlesik surum): ctx.scale icindeki prosedurel cizim (tahtadaki
# durum 1.8/1.22/0.9, izgara, fis ikonlari) mantik pikseline yuvarlaninca
# 1-2 piksel arasi duzensiz bloklar olusuyordu. Acikken olcekli dikdortgenin
# her kenari AYRI ayri HD izgaraya (yarim piksel) yuvarlanir: bitisik
# dikdortgenler arasinda bosluk/ust uste binme olmaz. Yalniz ekran tuvali
# (remake_gorsel HD acikken); pisirme tuvalleri eski kurali korur.
var olcek_hd := false

func _olcekli_hd(x: float, y: float, w: float, h: float) -> bool:
	var sx := transform.x.x
	var sy := transform.y.y
	var X0 := roundf((x * sx + transform.origin.x) * 2.0)
	var X1 := roundf(((x + w) * sx + transform.origin.x) * 2.0)
	var Y0 := roundf((y * sy + transform.origin.y) * 2.0)
	var Y1 := roundf(((y + h) * sy + transform.origin.y) * 2.0)
	if X1 < X0:
		var t := X0
		X0 = X1
		X1 = t
	if Y1 < Y0:
		var t2 := Y0
		Y0 = Y1
		Y1 = t2
	X0 = maxf(X0, maxf(0.0, clip_rect.position.x * 2.0))
	Y0 = maxf(Y0, maxf(0.0, clip_rect.position.y * 2.0))
	X1 = minf(X1, minf(float(width) * 2.0, clip_rect.end.x * 2.0))
	Y1 = minf(Y1, minf(float(height) * 2.0, clip_rect.end.y * 2.0))
	if X1 <= X0 or Y1 <= Y0: return true
	var c := color
	c.a *= clampf(float(globalAlpha), 0, 1)
	if c.a <= 0: return true
	var istenen: RID = sat_material if globalCompositeOperation == "saturation" else _varsayilan()
	if istenen != item_mat: _segment(istenen)
	var n := bp.size()
	if n >= TOPLU_TAVAN:
		_flush()
		n = 0
	var l := X0 * 0.5
	var tt := Y0 * 0.5
	var r := X1 * 0.5
	var b := Y1 * 0.5
	bp.append(Vector2(l, tt)); bp.append(Vector2(r, tt)); bp.append(Vector2(r, b)); bp.append(Vector2(l, b))
	bc.append(c); bc.append(c); bc.append(c); bc.append(c)
	bi.append(n); bi.append(n + 1); bi.append(n + 2); bi.append(n); bi.append(n + 2); bi.append(n + 3)
	stat_rects += 1
	if _kayitta: _kayit.append([0, l, tt, r, b, c, item_mat])
	return true

# ---------------------------------------------------------------- cizim
func fillRect(x: Variant, y: Variant, w: Variant, h: Variant) -> Variant:
	if absf(transform.x.y) > 0.001 or absf(transform.y.x) > 0.001:
		var old_path := path
		path = PackedVector2Array([transform * Vector2(x, y), transform * Vector2(x + w, y), transform * Vector2(x + w, y + h), transform * Vector2(x, y + h)])
		fill()
		path = old_path
		return null
	if olcek_hd and (absf(absf(transform.x.x) - 1.0) > 0.001 or absf(transform.y.y - 1.0) > 0.001):
		_olcekli_hd(float(x), float(y), float(w), float(h))
		return null
	var r := bounds(Rect2(float(x), float(y), float(w), float(h)))
	if r.size.x <= 0 or r.size.y <= 0: return null
	var c := color
	c.a *= clampf(float(globalAlpha), 0, 1)
	if c.a <= 0: return null
	_push(r, c)
	return null

# HIZLI YOL: pixel_primitives (f_fr, f_px, f_disc ...) tam sayi koordinat
# ve cozulmus Color ile cagirir. fillStyle metnini cozmek, Variant
# donusumleri ve Rect2 kurmak tek dikdortgende ~4.7 mikrosaniye tutuyordu;
# baslik ekrani bir karede on binlerce dikdortgen ciziyor.
# Yalniz oteleme varsa (olcek/donme yok) sonuc bounds() ile birebir ayni.
func rect_fast(x: int, y: int, w: int, h: int, c: Color) -> void:
	if transform.x.x != 1.0 or transform.y.y != 1.0 or transform.x.y != 0.0 or transform.y.x != 0.0:
		var eski: Color = color
		color = c
		fillRect(x, y, w, h)
		color = eski
		return
	var ox := transform.origin.x
	var oy := transform.origin.y
	var left: int = x + int(floor(ox + .5)) if ox != 0.0 else x
	var top: int = y + int(floor(oy + .5)) if oy != 0.0 else y
	var right: int = left + w
	var bottom: int = top + h
	if left < clip_rect.position.x: left = clip_rect.position.x
	if top < clip_rect.position.y: top = clip_rect.position.y
	if left < 0: left = 0
	if top < 0: top = 0
	if right > clip_rect.end.x: right = clip_rect.end.x
	if bottom > clip_rect.end.y: bottom = clip_rect.end.y
	if right > 480: right = 480
	if bottom > 270: bottom = 270
	if right <= left or bottom <= top: return
	var a: float = globalAlpha
	if a < 1.0:
		if a <= 0.0: return
		c.a *= a
	if globalCompositeOperation != "source-over":
		_push(Rect2i(left, top, right - left, bottom - top), c)
		return
	if item_mat != _varsayilan(): _segment(_varsayilan())
	var n := bp.size()
	if n >= TOPLU_TAVAN:
		_flush()
		n = 0
	bp.append(Vector2(left, top)); bp.append(Vector2(right, top)); bp.append(Vector2(right, bottom)); bp.append(Vector2(left, bottom))
	bc.append(c); bc.append(c); bc.append(c); bc.append(c)
	bi.append(n); bi.append(n + 1); bi.append(n + 2); bi.append(n); bi.append(n + 2); bi.append(n + 3)
	stat_rects += 1
	if _kayitta: _kayit.append([0, float(left), float(top), float(right), float(bottom), c, item_mat])

# HD DIKDORTGEN (remake): 2x izgarada (yarim mantik pikseli) dikdortgen;
# koordinatlar HD piksel. Yalniz oteleme + yatay ayna (musteri yuzu).
func rect_hd(x: float, y: float, w: float, h: float, c: Color) -> void:
	var sx := transform.x.x
	var X0 := roundf(transform.origin.x * 2.0 + x * sx)
	var X1 := roundf(transform.origin.x * 2.0 + (x + w) * sx)
	if X1 < X0:
		var tmp := X0
		X0 = X1
		X1 = tmp
	var Y0 := roundf(transform.origin.y * 2.0 + y)
	var Y1 := Y0 + roundf(h)
	X0 = maxf(X0, maxf(0.0, clip_rect.position.x * 2.0))
	Y0 = maxf(Y0, maxf(0.0, clip_rect.position.y * 2.0))
	X1 = minf(X1, minf(960.0, clip_rect.end.x * 2.0))
	Y1 = minf(Y1, minf(540.0, clip_rect.end.y * 2.0))
	if X1 <= X0 or Y1 <= Y0: return
	var a: float = globalAlpha
	if a < 1.0:
		if a <= 0.0: return
		c.a *= a
	if item_mat != _varsayilan(): _segment(_varsayilan())
	var n := bp.size()
	if n >= TOPLU_TAVAN:
		_flush()
		n = 0
	var l := X0 * 0.5
	var t := Y0 * 0.5
	var r := X1 * 0.5
	var b := Y1 * 0.5
	bp.append(Vector2(l, t)); bp.append(Vector2(r, t)); bp.append(Vector2(r, b)); bp.append(Vector2(l, b))
	bc.append(c); bc.append(c); bc.append(c); bc.append(c)
	bi.append(n); bi.append(n + 1); bi.append(n + 2); bi.append(n); bi.append(n + 2); bi.append(n + 3)
	stat_rects += 1
	if _kayitta: _kayit.append([0, l, t, r, b, c, item_mat])

func clearRect(x: Variant, y: Variant, w: Variant, h: Variant) -> Variant:
	var r := bounds(Rect2(x, y, w, h))
	if r.position == Vector2i.ZERO and r.size.x >= int(width) and r.size.y >= int(height):
		# tum ekran: o ana kadar cizileni at
		for i in used: RenderingServer.canvas_item_clear(pool[i])
		used = 0
		bp.clear(); bc.clear(); bi.clear()
		_segment(_varsayilan())
	elif r.size.x > 0 and r.size.y > 0:
		_push(r, Color.BLACK)        # ekran tuvali saydamsiz (alpha:false)
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

# pixel_canvas.gd:fill ile ayni satir tarama; satirlar dikdortgen olarak gider
func fill() -> Variant:
	if path.size() < 3: return null
	var c := color
	c.a *= clampf(float(globalAlpha), 0, 1)
	if c.a <= 0: return null
	var box := Rect2(path[0], Vector2.ZERO)
	for point in path: box = box.expand(point)
	var screen := Rect2i(0, 0, int(width), int(height))
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
			var r := Rect2i(left, y, right - left, 1).intersection(clip_rect).intersection(screen)
			if r.size.x > 0: _push(r, c)
	return null

func _texture(source: Variant) -> Texture2D:
	var id: int = source.get_instance_id()
	var img: Image = source.image
	if img == null: return null
	var entry: Variant = textures.get(id)
	var size := img.get_size()
	if entry == null or entry[2] != size:
		var tex := ImageTexture.create_from_image(img)
		textures[id] = [tex, source.generation, size]
		texture_uploads += 1
		return tex
	if entry[1] != source.generation:
		entry[0].update(img)
		entry[1] = source.generation
		texture_uploads += 1
	return entry[0]

func drawImage(source: Variant, a: Variant, b: Variant, c: Variant = null, d: Variant = null, e: Variant = null, f: Variant = null, g: Variant = null, h: Variant = null) -> Variant:
	if source == null: return null
	source.ensure()
	var sr := Rect2(0, 0, float(source.width), float(source.height))
	var dr := Rect2(float(a), float(b), sr.size.x, sr.size.y)
	if e != null:
		sr = Rect2(float(int(a)), float(int(b)), float(int(c)), float(int(d)))
		dr = Rect2(float(e), float(f), float(g), float(h))
	elif c != null: dr.size = Vector2(float(c), float(d))
	if sr.size.x <= 0 or sr.size.y <= 0 or dr.size.x <= 0 or dr.size.y <= 0: return null
	var alpha: float = clampf(float(globalAlpha), 0, 1)
	if alpha <= 0: return null
	var p0 := transform * dr.position
	var p1 := transform * dr.end
	var dest := Vector2i(roundi(minf(p0.x, p1.x)), roundi(minf(p0.y, p1.y)))
	var size := Vector2i(roundi(absf(p1.x - p0.x)), roundi(absf(p1.y - p0.y)))
	if size.x <= 0 or size.y <= 0: return null
	var full := Rect2i(dest, size)
	var cropped := full.intersection(clip_rect).intersection(Rect2i(0, 0, int(width), int(height)))
	if cropped.size.x <= 0 or cropped.size.y <= 0: return null
	var rid: RID
	var tex: Texture2D = null
	var kaynak_olcek := 1.0
	if source.has_method("doku"):
		source.bitir()
		rid = source.doku()
		kaynak_olcek = 2.0
	else:
		# sprite_library: atlas sayfasinin bir bolgesi -> sayfanin dokusu + bolge kaymasi
		var atlas_kaynak: Variant = source.get("atlas_source")
		if atlas_kaynak != null:
			var bolge: Rect2i = source.atlas_region
			sr.position += Vector2(bolge.position)
			tex = _texture(atlas_kaynak)
		else:
			tex = _texture(source)
		if tex == null: return null
		rid = tex.get_rid()
	var flip_x := p1.x < p0.x
	var flip_y := p1.y < p0.y
	# kirpilan kismi kaynak dikdortgenine oranla yansit
	var kx := sr.size.x / size.x
	var ky := sr.size.y / size.y
	var ox := float(cropped.position.x - dest.x)
	var oy := float(cropped.position.y - dest.y)
	if flip_x: ox = float(full.end.x - cropped.end.x)
	if flip_y: oy = float(full.end.y - cropped.end.y)
	var src := Rect2(sr.position.x + ox * kx, sr.position.y + oy * ky, cropped.size.x * kx, cropped.size.y * ky)
	if kaynak_olcek != 1.0:
		src = Rect2(src.position * kaynak_olcek, src.size * kaynak_olcek)
	var dst := Rect2(cropped)
	if flip_x: dst = Rect2(dst.end.x, dst.position.y, -dst.size.x, dst.size.y)
	if flip_y: dst = Rect2(dst.position.x, dst.end.y, dst.size.x, -dst.size.y)
	var dmat := _premul() if kaynak_olcek != 1.0 else _varsayilan()
	if item_mat != dmat: _segment(dmat)
	_flush()
	RenderingServer.canvas_item_add_texture_rect_region(item, dst, rid, src, Color(1, 1, 1, alpha), false, true)
	if _kayitta: _kayit.append([1, rid, dst, src, Color(1, 1, 1, alpha), item_mat, tex if tex != null else source])
	stat_images += 1
	return null

# HD SPRITE (remake): Blender'dan gelen 2x parcayi mantik koordinatina
# (lx, ly) ciz. Kaynak dikdortgeni HD piksel; hedef HD piksel izgarasina
# yuvarlanir (yarim mantik pikseli), boylece 2x piksel art keskin kalir.
# Yalniz oteleme (+ yatay aynalama) destekli; kirpma HD piksel tamsayisinda.
func texture_hd(tex: Texture2D, src: Rect2, lx: float, ly: float, alpha: float = 1.0, ayna: bool = false, renk: Color = Color.WHITE) -> void:
	var a: float = clampf(float(globalAlpha), 0, 1) * alpha
	if a <= 0.0: return
	var sx := transform.x.x
	var X := roundi((transform.origin.x + lx * sx) * 2.0)
	var Y := roundi((transform.origin.y + ly * transform.y.y) * 2.0)
	var w := int(src.size.x)
	var h := int(src.size.y)
	var cevir := ayna != (sx < 0.0)
	if sx < 0.0: X -= w
	var tam := Rect2i(X, Y, w, h)
	var kirp := Rect2i(clip_rect.position * 2, clip_rect.size * 2) if clip_rect.size.x < 100000 else Rect2i(-200000, -200000, 400000, 400000)
	var cr := tam.intersection(kirp).intersection(Rect2i(0, 0, int(width) * 2, int(height) * 2))
	if cr.size.x <= 0 or cr.size.y <= 0: return
	var ox := cr.position.x - tam.position.x
	var oy := cr.position.y - tam.position.y
	if cevir: ox = tam.end.x - cr.end.x
	var s := Rect2(src.position.x + ox, src.position.y + oy, cr.size.x, cr.size.y)
	var d := Rect2(cr.position.x * 0.5, cr.position.y * 0.5, cr.size.x * 0.5, cr.size.y * 0.5)
	# negatif genislikli hedef: Godot konumdan saga dogru ayna basiyor (end.x kullanilinca bir genislik kayiyordu)
	if cevir: d = Rect2(d.position.x, d.position.y, -d.size.x, d.size.y)
	if item_mat != _varsayilan(): _segment(_varsayilan())
	_flush()
	RenderingServer.canvas_item_add_texture_rect_region(item, d, tex.get_rid(), s, Color(renk.r, renk.g, renk.b, a), false, true)
	if _kayitta: _kayit.append([1, tex.get_rid(), d, s, Color(renk.r, renk.g, renk.b, a), item_mat, tex])
	stat_images += 1

# ESNETILMIS HD DOKU (remake 9 dilim): kaynak dikdortgen hedefe gerilir.
# Kenar dilimleri tek yonde tekduze oldugu icin en yakin komsu ornekleme temiz.
func texture_hd_rect(tex: Texture2D, src: Rect2, lx: float, ly: float, lw: float, lh: float, alpha: float = 1.0, renk: Color = Color.WHITE) -> void:
	var a: float = clampf(float(globalAlpha), 0, 1) * alpha
	if a <= 0.0: return
	var sx := transform.x.x
	var X := roundi((transform.origin.x + lx * sx) * 2.0)
	var Y := roundi((transform.origin.y + ly * transform.y.y) * 2.0)
	var W := maxi(1, roundi(lw * absf(sx) * 2.0))
	var H := maxi(1, roundi(lh * transform.y.y * 2.0))
	if sx < 0.0: X -= W
	var tam := Rect2i(X, Y, W, H)
	var kirp := Rect2i(clip_rect.position * 2, clip_rect.size * 2) if clip_rect.size.x < 100000 else Rect2i(-200000, -200000, 400000, 400000)
	var cr := tam.intersection(kirp).intersection(Rect2i(0, 0, int(width) * 2, int(height) * 2))
	if cr.size.x <= 0 or cr.size.y <= 0: return
	var u0 := float(cr.position.x - tam.position.x) / float(W)
	var u1 := float(cr.end.x - tam.position.x) / float(W)
	var v0 := float(cr.position.y - tam.position.y) / float(H)
	var v1 := float(cr.end.y - tam.position.y) / float(H)
	var s := Rect2(src.position.x + u0 * src.size.x, src.position.y + v0 * src.size.y,
		(u1 - u0) * src.size.x, (v1 - v0) * src.size.y)
	var d := Rect2(cr.position.x * 0.5, cr.position.y * 0.5, cr.size.x * 0.5, cr.size.y * 0.5)
	if item_mat != _varsayilan(): _segment(_varsayilan())
	_flush()
	RenderingServer.canvas_item_add_texture_rect_region(item, d, tex.get_rid(), s, Color(renk.r, renk.g, renk.b, a), false, true)
	if _kayitta: _kayit.append([1, tex.get_rid(), d, s, Color(renk.r, renk.g, renk.b, a), item_mat, tex])
	stat_images += 1

# DIKEY OLCEKLI HD DOKU (remake): ctx.scale(1, sy) icinde cizilen parcalar
# (ucan et). Hedef yukseklik sy ile carpilir, kirpma src'ye oranla tasinir.
func texture_hd_y(tex: Texture2D, src: Rect2, lx: float, ly: float, sy: float, alpha: float = 1.0, ayna: bool = false, renk: Color = Color.WHITE) -> void:
	var a: float = clampf(float(globalAlpha), 0, 1) * alpha
	if a <= 0.0: return
	var sx := transform.x.x
	var X := roundi((transform.origin.x + lx * sx) * 2.0)
	var Y := roundi((transform.origin.y + ly * sy) * 2.0)
	var w := int(src.size.x)
	var h := int(src.size.y)
	var dh := maxi(1, roundi(h * sy))
	var cevir := ayna != (sx < 0.0)
	if sx < 0.0: X -= w
	var tam := Rect2i(X, Y, w, dh)
	var kirp := Rect2i(clip_rect.position * 2, clip_rect.size * 2) if clip_rect.size.x < 100000 else Rect2i(-200000, -200000, 400000, 400000)
	var cr := tam.intersection(kirp).intersection(Rect2i(0, 0, int(width) * 2, int(height) * 2))
	if cr.size.x <= 0 or cr.size.y <= 0: return
	var ox := cr.position.x - tam.position.x
	if cevir: ox = tam.end.x - cr.end.x
	var v0 := float(cr.position.y - tam.position.y) / float(dh)
	var v1 := float(cr.end.y - tam.position.y) / float(dh)
	var s := Rect2(src.position.x + ox, src.position.y + v0 * h, cr.size.x, (v1 - v0) * h)
	var d := Rect2(cr.position.x * 0.5, cr.position.y * 0.5, cr.size.x * 0.5, cr.size.y * 0.5)
	if cevir: d = Rect2(d.position.x, d.position.y, -d.size.x, d.size.y)
	if item_mat != _varsayilan(): _segment(_varsayilan())
	_flush()
	RenderingServer.canvas_item_add_texture_rect_region(item, d, tex.get_rid(), s, Color(renk.r, renk.g, renk.b, a), false, true)
	if _kayitta: _kayit.append([1, tex.get_rid(), d, s, Color(renk.r, renk.g, renk.b, a), item_mat, tex])
	stat_images += 1

# MALZEMELI HD DOKU (remake): texture_hd ile ayni yerlesim, cizim bir
# malzemeyle (ton shader'i) yapilir; renk modulate'den shader'a gider.
func texture_hd_mat(tex: Texture2D, src: Rect2, lx: float, ly: float, mat: RID, renk: Color, alpha: float = 1.0, ayna: bool = false) -> void:
	if item_mat != mat: _segment(mat)
	var a: float = clampf(float(globalAlpha), 0, 1) * alpha
	if a <= 0.0: return
	var sx := transform.x.x
	var X := roundi((transform.origin.x + lx * sx) * 2.0)
	var Y := roundi((transform.origin.y + ly * transform.y.y) * 2.0)
	var w := int(src.size.x)
	var h := int(src.size.y)
	var cevir := ayna != (sx < 0.0)
	if sx < 0.0: X -= w
	var tam := Rect2i(X, Y, w, h)
	var kirp := Rect2i(clip_rect.position * 2, clip_rect.size * 2) if clip_rect.size.x < 100000 else Rect2i(-200000, -200000, 400000, 400000)
	var cr := tam.intersection(kirp).intersection(Rect2i(0, 0, int(width) * 2, int(height) * 2))
	if cr.size.x <= 0 or cr.size.y <= 0: return
	var ox := cr.position.x - tam.position.x
	var oy := cr.position.y - tam.position.y
	if cevir: ox = tam.end.x - cr.end.x
	var s := Rect2(src.position.x + ox, src.position.y + oy, cr.size.x, cr.size.y)
	var d := Rect2(cr.position.x * 0.5, cr.position.y * 0.5, cr.size.x * 0.5, cr.size.y * 0.5)
	# negatif genislikli hedef: Godot konumdan saga dogru ayna basiyor (end.x kullanilinca bir genislik kayiyordu)
	if cevir: d = Rect2(d.position.x, d.position.y, -d.size.x, d.size.y)
	_flush()
	RenderingServer.canvas_item_add_texture_rect_region(item, d, tex.get_rid(), s, Color(renk.r, renk.g, renk.b, a), false, true)
	if _kayitta: _kayit.append([1, tex.get_rid(), d, s, Color(renk.r, renk.g, renk.b, a), item_mat, tex])
	stat_images += 1

# MALZEMELI DORTGEN (remake): Blender dokusu + shader ile cizilen nesneler
# (doner sisi ...). Parametreler tepe rengiyle gider, UV 0..1 dortgeni kaplar.
# Yalniz oteleme destekli (oyunun kamera sarsintisi ve VIEW kaydirmasi);
# kirpma yazilimda, UV'ler kirpilan paya gore ayarlanir.
func shader_quad(x: float, y: float, w: float, h: float, mat: RID, params: Color) -> void:
	var p0 := transform * Vector2(x, y)
	var dest := Rect2i(roundi(p0.x), roundi(p0.y), roundi(w), roundi(h))
	var cropped := dest.intersection(clip_rect).intersection(Rect2i(0, 0, int(width), int(height)))
	if cropped.size.x <= 0 or cropped.size.y <= 0: return
	var u0 := float(cropped.position.x - dest.position.x) / dest.size.x
	var v0 := float(cropped.position.y - dest.position.y) / dest.size.y
	var u1 := float(cropped.end.x - dest.position.x) / dest.size.x
	var v1 := float(cropped.end.y - dest.position.y) / dest.size.y
	_segment(mat)
	var x0 := float(cropped.position.x)
	var y0 := float(cropped.position.y)
	var x1 := float(cropped.end.x)
	var y1 := float(cropped.end.y)
	RenderingServer.canvas_item_add_triangle_array(item,
		PackedInt32Array([0, 1, 2, 0, 2, 3]),
		PackedVector2Array([Vector2(x0, y0), Vector2(x1, y0), Vector2(x1, y1), Vector2(x0, y1)]),
		PackedColorArray([params, params, params, params]),
		PackedVector2Array([Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v1)]))
	stat_images += 1

func getImageData(_x: Variant, _y: Variant, w: Variant, h: Variant) -> Variant:
	var data: Array = []
	data.resize(int(w) * int(h) * 4)
	# pisirme tuvali: oyunun "tuval kayboldu mu" yoklamasi (alfa 0 ise yeniden
	# pisir) her 120 karede tetiklenmesin
	data.fill(255 if bake else 0)
	return {"width": int(w), "height": int(h), "data": data}

func putImageData(_value: Variant, _x: Variant, _y: Variant) -> Variant:
	return null


# ---------------------------------------------------------------- kayit
func kayit_basla() -> void:
	_kayit = []
	_kayitta = true

func kayit_bitir() -> Array:
	_kayitta = false
	var k := _kayit
	_kayit = []
	return k

func kayit_oynat(liste: Array, dx: float, dy: float) -> void:
	for e in liste:
		var mat: RID = e[6] if e[0] == 0 else e[5]
		if item_mat != mat: _segment(mat)
		if e[0] == 0:
			var n := bp.size()
			if n >= TOPLU_TAVAN:
				_flush()
				n = 0
			var x0: float = e[1] + dx
			var y0: float = e[2] + dy
			var x1: float = e[3] + dx
			var y1: float = e[4] + dy
			var c: Color = e[5]
			bp.append(Vector2(x0, y0)); bp.append(Vector2(x1, y0)); bp.append(Vector2(x1, y1)); bp.append(Vector2(x0, y1))
			bc.append(c); bc.append(c); bc.append(c); bc.append(c)
			bi.append(n); bi.append(n + 1); bi.append(n + 2); bi.append(n); bi.append(n + 2); bi.append(n + 3)
			stat_rects += 1
		else:
			_flush()
			var d: Rect2 = e[2]
			d.position += Vector2(dx, dy)
			RenderingServer.canvas_item_add_texture_rect_region(item, d, e[1], e[3], e[4], false, true)
			stat_images += 1

# dokulu ucgen dizisi (remake: tas on plan). Yalniz oteleme uygulanir.
func dokulu_ucgenler(noktalar: PackedVector2Array, uvler: PackedVector2Array, idx: PackedInt32Array, doku: RID) -> void:
	if noktalar.is_empty(): return
	var ox := floorf(transform.origin.x + .5)
	var oy := floorf(transform.origin.y + .5)
	var p := noktalar
	if ox != 0.0 or oy != 0.0:
		p = PackedVector2Array()
		p.resize(noktalar.size())
		for i in noktalar.size(): p[i] = noktalar[i] + Vector2(ox, oy)
	if item_mat != _premul(): _segment(_premul())
	_flush()
	var renk := PackedColorArray()
	renk.resize(p.size())
	renk.fill(Color(1, 1, 1, clampf(float(globalAlpha), 0, 1)))
	RenderingServer.canvas_item_add_triangle_array(item, idx, p, renk, uvler, PackedInt32Array(), PackedFloat32Array(), doku)
	stat_images += 1
