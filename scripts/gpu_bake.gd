# GPU PISIRME TUVALI (remake)
#
# Oyun buyuk ve duragan katmanlari (arka plan: duvar, sokak, tas kemer, zemin;
# vitrin cercevesi) bir kez "Canvas" nesnesine cizip her karede resim olarak
# basiyor. Aktarimda o tuval CPU'daydi: HD kancalar orada calismiyor (yalniz
# GPU tuvalinde), HD gorseller bu katmanlarda hic gorunmuyordu.
#
# GpuBake ayni Canvas arayuzunu (width/height, getContext, ensure) sunar ama
# cizimleri 2x cozunurluklu ekran disi bir viewport'a GPU komutu olarak gonderir.
# Ilk kez basildiginda (drawImage) viewport bir kez render edilir; sonraki
# karelerde yalniz doku basilir. getContext'in dondurdugu GpuCanvas oldugu icin
# icinde calisan cizim kodundaki HD kancalari da devrede.
extends RefCounted

const GpuCanvas = preload("res://scripts/gpu_canvas.gd")
const OLCEK := 2

var vp: RID
var canvas: RID
var kok: RID
var ctx: GpuCanvas
var bitti := false
var generation: int = 0
var image: Image = null   # uyumluluk: CPU goruntusu yok

var width: Variant = 480:
	set(v):
		width = maxi(1, int(v))
		_boyut()
var height: Variant = 270:
	set(v):
		height = maxi(1, int(v))
		_boyut()

func _init() -> void:
	vp = RenderingServer.viewport_create()
	RenderingServer.viewport_set_transparent_background(vp, true)
	RenderingServer.viewport_set_disable_3d(vp, true)
	RenderingServer.viewport_set_default_canvas_item_texture_filter(vp, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
	canvas = RenderingServer.canvas_create()
	RenderingServer.viewport_attach_canvas(vp, canvas)
	kok = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(kok, canvas)
	RenderingServer.viewport_set_active(vp, true)
	RenderingServer.viewport_set_update_mode(vp, RenderingServer.VIEWPORT_UPDATE_DISABLED)
	ctx = GpuCanvas.new()
	ctx.bake = true
	ctx.setup(kok, OLCEK)
	_boyut()
	ctx.begin_frame()

func _boyut() -> void:
	if not vp.is_valid(): return
	RenderingServer.viewport_set_size(vp, int(width) * OLCEK, int(height) * OLCEK)
	if ctx != null:
		ctx.width = width
		ctx.height = height

func getContext(_kind: Variant = null, _opts: Variant = null) -> Variant:
	return ctx

func ensure() -> void: pass

# ilk basista: biriken komutlari gonder, viewport'u bir kez render et
func bitir() -> void:
	if bitti: return
	bitti = true
	ctx.end_frame()
	RenderingServer.viewport_set_update_mode(vp, RenderingServer.VIEWPORT_UPDATE_ONCE)
	generation += 1

func doku() -> RID:
	return RenderingServer.viewport_get_texture(vp)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if ctx != null: ctx.free_resources()
		if kok.is_valid(): RenderingServer.free_rid(kok)
		if canvas.is_valid(): RenderingServer.free_rid(canvas)
		if vp.is_valid(): RenderingServer.free_rid(vp)
