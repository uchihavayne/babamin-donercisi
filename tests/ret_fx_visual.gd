# REDDEDILEN ISLEM GERI BILDIRIMI, GPU PIKSELLERI (birlesik surum, 12. tur). Mantik / "oyunu degistirmez" kilidi: tests/ret_fx.gd.
# Bu test GERCEK GPU tuvalinde pikselleri olcer (oyun donuk: yalniz advance(0) ile cizilir; X ve toast durumu ret_fx alanlarindan
# elle surulur). Hem HD hem eski (LD) cizim:
#  1) dinlenme: hicbir ret yokken kare kanca kapali kareyle AYNI; X omru bitince kare hic tetiklenmemis kareyle BIREBIR ayni (artik yok)
#  2) X cizilir: imlecin ustunde (11 px) belirir, farki yalniz X'in kutusunda; KIRMIZI piksel var; yukselirken yukari, solarken soluklasir
#  3) sallanma: X yatay desenle oynar (kare kareye farkli konum), omrunun sonunda yerine oturur
#  4) toast sallanmasi: uyari yazisi (toast) desen kadar yana kayar (HD'de tam 2 x dx piksel), dinlenmede kayma yok; yalniz toast kutusu degisir
#  5) kanca: kapali_zorla ile X ve toast sallanmasi gorunmez (kare dinlenmeyle ayni)
#  6) ayni durum ayni goruntuyu verir
#   godot --path . --script tests/ret_fx_visual.gd --quit-after 3000 -- --test --gpu-test
extends SceneTree
var shell: Control
var g: Node
var R: Variant
var G: Dictionary
var failures: Array[String] = []
var checks := 0
# Olcum pencereleri (HD piksel). Doner (shaders/sis.gdshader TIME kullanir) ve sokak sahnesi oyun durmusken de kareler arasi
# degisir; ikisi de pencerelerin disinda (bkz. tests/patates_tahtasi_visual.gd).
const IMLEC := Vector2(340, 200)                       # mantiksal px; X (340, 189)'da belirir
const X_PENCERE := Rect2i(640, 340, 80, 80)            # HD: X ve yukselisi / sallanmasi bunun icinde
const TOAST_PENCERE := Rect2i(160, 470, 640, 60)       # HD: ekranin altindaki uyari yazisi
const STATIK := Rect2i(300, 340, 660, 200)             # HD: doner ve sokak disinda, kareler arasi degismeyen alt bolge (tum "disinda degismez" olcumleri)

func _initialize() -> void:
	create_timer(170.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func goruntu() -> Image:
	await RenderingServer.frame_post_draw
	return shell.game_viewport.get_texture().get_image()

func hazirla() -> void:
	g.random_state = 123456
	g.session_system.f_resetProgress()
	g.j_G.prologueSeen = true
	g.f_startDay()
	G = g.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.hintT = 0; G.timeLeft = 100000
	G.customers = []; G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.weather = "sun"
	G.meat = 12; G.friesTray = 12
	for k in G.stock.keys():
		G.stock[k] = 12; G.stockAnim[k] = 12
	G.boards = [null, null, null]
	G.hand = null; G.drag = null
	G.bs = null
	g.j_BSQ.kuyruk = []
	R._t = -1.0; R._toast_t = -1.0
	R._bad_kare = -1; R._say_kare = -1
	g.j_PS.clear()
	g.j_FT.clear()

# mevcut durumu (X / toast durumu dahil) donuk olarak cizer ve goruntuyu verir
func ciz() -> Image:
	g.random_state = 777
	g.j_IN.x = IMLEC.x; g.j_IN.y = IMLEC.y
	g.advance(0.0)
	await process_frame
	return await goruntu()

func fark(a: Image, b: Image, pencere: Rect2i, esik: float = 0.02) -> int:
	var n := 0
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik: n += 1
	return n

func fark_kutusu(a: Image, b: Image, pencere: Rect2i, esik: float = 0.02) -> Rect2i:
	var x0 := 100000; var y0 := 100000; var x1 := -1; var y1 := -1
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik:
				x0 = mini(x0, x); y0 = mini(y0, y); x1 = maxi(x1, x); y1 = maxi(y1, y)
	return Rect2i(x0, y0, x1 - x0 + 1, y1 - y0 + 1) if x1 >= 0 else Rect2i()

# pencere icindeki kirmizi (X) piksel sayisi: kirmizi baskin, yesil / mavi dusuk
func kirmizi(im: Image, pencere: Rect2i) -> int:
	var n := 0
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var c: Color = im.get_pixel(x, y)
			if c.r > 0.65 and c.g < 0.40 and c.b < 0.40: n += 1
	return n

# X'i belirli yasa getirir (omur / sallanma bu yasa gore cizilir); toast durumu bos
func x_yasi(t: float) -> void:
	R._t = t
	R._x = IMLEC.x
	R._y = IMLEC.y - 11.0
	R._toast_t = -1.0

func serisini_dene(etiket: String, hd: bool) -> void:
	g.hd_acik = hd
	hazirla()
	var dinlenme: Image = await ciz()
	R.kapali_zorla = true
	x_yasi(0.05)
	var kapali: Image = await ciz()
	R.kapali_zorla = false
	check(fark(dinlenme, kapali, X_PENCERE) == 0, "%s: kanca kapaliyken X cizilmez (%d piksel)" % [etiket, fark(dinlenme, kapali, X_PENCERE)])
	# 2) X cizilir
	hazirla()
	x_yasi(0.05)
	var x_a: Image = await ciz()
	var kutu: Rect2i = fark_kutusu(x_a, dinlenme, STATIK)
	var beklenen_merkez := Vector2(IMLEC.x * 2.0, (IMLEC.y - 11.0) * 2.0)   # X, imlecin 11 mantiksal px ustunde belirir
	check(kutu.size.x > 0 and kutu.size.x <= 24 and kutu.size.y <= 24, "%s: X kucuk bir kutuda (%s)" % [etiket, str(kutu)])
	check(absf(float(kutu.get_center().x) - beklenen_merkez.x) <= 10.0 and absf(float(kutu.get_center().y) - beklenen_merkez.y) <= 12.0, "%s: X imlecin ustunde (%s merkez, beklenen %s)" % [etiket, str(kutu.get_center()), str(beklenen_merkez)])
	check(kirmizi(x_a, X_PENCERE) >= 6, "%s: X kirmizi (%d kirmizi piksel)" % [etiket, kirmizi(x_a, X_PENCERE)])
	check(fark(x_a, dinlenme, X_PENCERE) >= 20, "%s: X pikselleri dinlenmeden farkli (%d)" % [etiket, fark(x_a, dinlenme, X_PENCERE)])
	check(fark(x_a, dinlenme, STATIK) == fark(x_a, dinlenme, X_PENCERE), "%s: X'in disinda hicbir sey degismez (tum fark X penceresinde: %d / %d)" % [etiket, fark(x_a, dinlenme, X_PENCERE), fark(x_a, dinlenme, STATIK)])
	# yukselis: omur ilerledikce X yukari cikar (kutunun alt kenari yukari)
	x_yasi(0.40)
	var x_b: Image = await ciz()
	var kutu_b: Rect2i = fark_kutusu(x_b, dinlenme, STATIK)
	check(kutu_b.size.x > 0 and kutu_b.end.y < kutu.end.y, "%s: X omru boyunca yukari cikar (alt kenar %d -> %d)" % [etiket, kutu.end.y, kutu_b.end.y])
	check(kirmizi(x_b, X_PENCERE) < kirmizi(x_a, X_PENCERE) or fark(x_b, dinlenme, X_PENCERE) < fark(x_a, dinlenme, X_PENCERE), "%s: X omrunun sonuna dogru soluklasir" % etiket)
	# 3) sallanma: desen kare kareye farkli konum verir, omrun sonunda yerine oturur
	var konumlar: Array = []
	for t in [0.0, 0.05, 0.10, 0.15, 0.20, 0.25]:
		x_yasi(t)
		var im: Image = await ciz()
		var kb: Rect2i = fark_kutusu(im, dinlenme, STATIK)
		konumlar.append(kb.get_center().x)
	var xmin: int = konumlar.min()
	var xmax: int = konumlar.max()
	check(xmax - xmin >= 3, "%s: X yatay sallanir (merkez x %d .. %d)" % [etiket, xmin, xmax])
	# 1) X omru bitince artik yok (referans: ayni oturumda X hic tetiklenmeden cizilen kare)
	hazirla()
	var ayni_oturum: Image = await ciz()
	x_yasi(0.2)
	await ciz()
	R._t = -1.0
	var sonra: Image = await ciz()
	check(fark(sonra, ayni_oturum, STATIK) == 0, "%s: X omru bitince kare tetiklenmemis kareyle BIREBIR ayni (%d piksel)" % [etiket, fark(sonra, ayni_oturum, STATIK)])
	# 4) toast sallanmasi: yazi gorunurken desen dx kadar yana kayar
	hazirla()
	G.hint = "Önce lavaş ya da pide al!"
	G.hintT = 1.5
	R._toast_t = -1.0
	var toast_dinlenme: Image = await ciz()
	var yazisiz_a: int = fark(toast_dinlenme, dinlenme, TOAST_PENCERE)
	check(yazisiz_a > 300, "%s: uyari yazisi gorunur (%d piksel)" % [etiket, yazisiz_a])
	var dx_olc: Array = []
	for idx in [0, 1, 3, 5]:
		R._toast_t = (float(idx) + 0.5) / float(R.TOAST_DESEN.size()) * R.TOAST_SURE
		var im: Image = await ciz()
		var kb: Rect2i = fark_kutusu(im, dinlenme, TOAST_PENCERE)
		dx_olc.append([idx, kb.position.x, kb.size.x, R.f_toastDx()])
	var kb0: Rect2i = fark_kutusu(toast_dinlenme, dinlenme, TOAST_PENCERE)
	var dogru := true
	var ozet := ""
	for o in dx_olc:
		var beklenen_kayma: int = int(float(o[3]) * 2.0)
		var olculen: int = int(o[1]) - kb0.position.x
		ozet += " [idx %d dx %d: olculen %d]" % [int(o[0]), int(o[3]), olculen]
		if olculen != beklenen_kayma or int(o[2]) != kb0.size.x: dogru = false
	check(dogru, "%s: toast desen kadar yana kayar (HD'de 2 x dx piksel, boyut ayni):%s" % [etiket, ozet])
	R._toast_t = 0.01
	var kayik: Image = await ciz()
	check(fark(kayik, toast_dinlenme, STATIK) == fark(kayik, toast_dinlenme, TOAST_PENCERE), "%s: toast sallanmasi toast penceresinin disinda hicbir seyi degistirmez (%d / %d)" % [etiket, fark(kayik, toast_dinlenme, TOAST_PENCERE), fark(kayik, toast_dinlenme, STATIK)])
	R._toast_t = -1.0
	var bitmis: Image = await ciz()
	check(fark(bitmis, toast_dinlenme, STATIK) == 0, "%s: sallanma bitince toast tam yerinde (%d piksel)" % [etiket, fark(bitmis, toast_dinlenme, STATIK)])
	# X ve toast birlikte: toast'in kaymasi X'in konumuna SIZMAZ (translate geri alinir)
	x_yasi(0.05)
	R._toast_t = -1.0
	var x_tek: Image = await ciz()                       # toast yazisi var (hintT > 0), kayma yok
	var kutu_tek: Rect2i = fark_kutusu(x_tek, toast_dinlenme, Rect2i(560, 330, 400, 120))
	R._toast_t = 0.01                                    # toast kayiyor (dx = -3)
	var x_cift: Image = await ciz()
	var kutu_cift: Rect2i = fark_kutusu(x_cift, toast_dinlenme, Rect2i(560, 330, 400, 120))
	check(kutu_tek.size.x > 0 and kutu_tek == kutu_cift, "%s: toast kayarken X ayni yerde (kutu %s / %s)" % [etiket, str(kutu_tek), str(kutu_cift)])
	R._t = -1.0
	# 5) kanca: toast sallanmasi da kapanir
	R.kapali_zorla = true
	R._toast_t = 0.01
	var kapali_toast: Image = await ciz()
	R.kapali_zorla = false
	check(fark(kapali_toast, toast_dinlenme, TOAST_PENCERE) == 0, "%s: kanca kapaliyken toast sallanmaz (%d piksel)" % [etiket, fark(kapali_toast, toast_dinlenme, TOAST_PENCERE)])
	# 6) ayni durum ayni goruntu
	R._toast_t = 0.1
	var d1: Image = await ciz()
	var d2: Image = await ciz()
	check(fark(d1, d2, STATIK) == 0, "%s: ayni durum ayni goruntuyu verir" % etiket)

func run() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.set_process(false)                       # oyun kendiliginden ilerlemez; durum elle surulur
	g.set_process_input(false)
	shell.set_process_input(false)
	shell.set_process_unhandled_input(false)
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	R = g.ret_fx
	await process_frame
	check(g.hd_acik and g.hd_gpu(), "HD acik ve GPU tuvali var")
	await serisini_dene("HD", true)
	await serisini_dene("eski", false)
	g.hd_acik = true
	for f in failures: push_error(f)
	print("RET FX GPU ", JSON.stringify({"checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
