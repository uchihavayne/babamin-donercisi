# FRITOZE KOY, GPU PIKSELLERI (birlesik surum, 12. tur, akicilik cilasi). Kullanici: "fritoze koy gecisi anlik".
# HD'de gercek GPU tuvalinde olcer (mantik: tests/fritoze_koy.gd):
#  1) HD acik, "ucan_patates" kancasi etkin; cubuklar tahtadan yola cikar (yolda cizili, kareler arasi ilerler)
#  2) cubuklar ucarken sepette patates YOK; ayni kare flyF olmadan cizilince sepette patates VAR (fark gercek)
#  3) inince patates sepette belirir ve 0.14 sn'de tam belirginlesir (fade-in: ilk karede daha az piksel)
#  4) HD kapaliyken eski cizim yedegi de ucar
#   godot --path . --script tests/fritoze_koy_visual.gd --quit-after 3000 -- --test --gpu-test
extends SceneTree
var shell: Control
var g: Node
var failures: Array[String] = []
var checks := 0
var olc := {}

func _initialize() -> void:
	create_timer(150.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func step(n: int = 1) -> void:
	for i in n:
		g.advance(1.0 / 60)
		await process_frame

func goruntu() -> Image:
	await RenderingServer.frame_post_draw
	return root.get_texture().get_image()

# ucusu k noktasinda tutar (zaman ilerlemeden, advance(0)): flyF.t = k
func ucus_kare(k: float, ucus_var: bool = true) -> Image:
	var G: Dictionary = g.j_G
	if ucus_var:
		var b0: Vector2 = g.potato_system.f_cubukBaslangic()
		var b1: Vector2 = g.potato_system.f_sepetNoktasi()
		G.flyF = {"t": k, "n": 3.0, "x0": b0.x, "y0": b0.y, "x1": b1.x, "y1": b1.y}
	else:
		G.flyF = null
	g.advance(0.0)
	await process_frame
	return await goruntu()

# sepet penceresi (HD piksel): fritozun yag / sepet bolgesi
func sepet_penceresi() -> Rect2i:
	var f: Dictionary = g.j_ST.fryer
	return Rect2i(int((f.x + 6.0) * 2.0), int((f.y + 12.0) * 2.0), int((f.w - 12.0) * 2.0), int(16.0 * 2.0))

func yol_farki(a: Image, b: Image, kutu: Rect2i, esik: float = 0.1) -> int:
	var n := 0
	for y in range(kutu.position.y, kutu.end.y):
		for x in range(kutu.position.x, kutu.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik: n += 1
	return n

func run() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	g.j_G.up = {}
	g.f_startDay()
	var G: Dictionary = g.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.hintT = 0; G.timeLeft = 100000
	G.customers = []; G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	g.j_BSQ.kuyruk = []
	await step(20)
	check(g.hd_acik and g.hd_gpu() and g.hd("ucan_patates"), "HD acik, GPU tuvali var, ucan yiyecek kancasi etkin")
	# fritoz kizartmada: yuk var (mantik tiklamadan), flyF elle tutulur
	var F: Dictionary = G.fryer
	F.state = "fry"; F.load = 3.0; F.t = 0.5; F.dur = 8.5; F.prog = 0.06; F.basketY = 7.0
	G.cut.potato = false; G.cut.raw = 0.0
	var st: Dictionary = g.j_ST
	# 1) yol: k=0.25 ve 0.40 karelerinde cubuklar yolda; kareler arasi ilerler
	var yolda: Image = await ucus_kare(0.25)
	var b0: Vector2 = g.potato_system.f_cubukBaslangic()
	var b1: Vector2 = g.potato_system.f_sepetNoktasi()
	var yok: Image = await ucus_kare(0.25, false)       # ayni kare, ucus yok (sepette patates var)
	var yolda2: Image = await ucus_kare(0.40)
	var kutu := Rect2i(int(minf(b0.x, b1.x) * 2.0) - 30, int((b1.y + 6.0) * 2.0), 100, int((b0.y - b1.y) * 2.0))
	var n_yol := yol_farki(yolda, yok, Rect2i(kutu.position.x, int((b1.y + 20.0) * 2.0), kutu.size.x, int((b0.y - b1.y - 14.0) * 2.0)))
	var n_ilerle := yol_farki(yolda, yolda2, kutu)
	olc["yol"] = [n_yol, n_ilerle, kutu]
	check(n_yol >= 40, "cubuklar yolda cizili: ucus var / yok farki %d px" % n_yol)
	check(n_ilerle >= 60, "cubuklar kareler arasinda ilerler (%d px)" % n_ilerle)
	# 2) sepette patates: ucarken sepet BOS gibi (yuk=0 ile ayni), flyF olmadan patates var
	var pencere := sepet_penceresi()
	F.load = 0.0
	var bos_sepet: Image = await ucus_kare(0.0, false)       # ayni kare, yuk sifir: bos sepet
	F.load = 3.0
	var f_ucus := yol_farki(yolda, bos_sepet, pencere)
	var f_yok := yol_farki(yok, bos_sepet, pencere)
	olc["sepet"] = [f_ucus, f_yok]
	check(f_yok >= 100, "kontrol: ucus yokken sepette patates var (bos sepetten %d px farkli)" % f_yok)
	check(f_ucus < 12, "cubuklar ucarken sepet bos sepetle ayni (%d px fark)" % f_ucus)
	# 3) inis: gir=1 iken patates silik, gir=0 iken tam
	F.gir = 1.0
	var silik: Image = await ucus_kare(0.0, false)
	F.gir = 0.0
	var tam: Image = await ucus_kare(0.0, false)
	var f_silik := yol_farki(silik, bos_sepet, pencere, 0.3)   # yuksek esik: alfa 0.1'deki hafif iz sayilmaz
	var f_tam := yol_farki(tam, bos_sepet, pencere, 0.3)
	olc["fade"] = [f_silik, f_tam]
	check(f_tam >= 60 and f_silik < f_tam / 3, "inis aninda patates silik, sonra tam belirgin (bos sepetten fark %d -> %d px)" % [f_silik, f_tam])
	# 4) eski cizim yedegi
	g.hd_acik = false
	await step(3)
	check(not g.hd("ucan_patates"), "HD kapaliyken kanca devre disi")
	F.gir = 0.0
	var eski_yok: Image = await ucus_kare(0.3, false)
	var eski: Image = await ucus_kare(0.3)
	var b0e: Vector2 = g.potato_system.f_cubukBaslangic()
	var b1e: Vector2 = g.potato_system.f_sepetNoktasi()
	var kutu_e := Rect2i(int(minf(b0e.x, b1e.x) * 2.0) - 30, int((b1e.y + 6.0) * 2.0), 100, int((b0e.y - b1e.y) * 2.0))
	var n_eski := yol_farki(eski, eski_yok, kutu_e)
	olc["eski"] = n_eski
	check(n_eski >= 30, "HD kapali: eski cizim yedegi cubuklari ucurur (%d px)" % n_eski)
	g.hd_acik = true
	print("OLCUM ", JSON.stringify(olc))
	for f in failures: push_error(f)
	print("FRITOZE KOY GPU ", JSON.stringify({"checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
