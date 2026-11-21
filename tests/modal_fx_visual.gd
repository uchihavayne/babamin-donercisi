# PANEL / MOLA GECISLERI, GPU PIKSELLERI (birlesik surum, 12. tur). Mantik / "oyunu degistirmez" kilidi: tests/modal_fx.gd. Bu test
# GERCEK GPU tuvalinde pikselleri olcer (oyun donuk: yalniz advance(0) ile cizilir; gecis durumu modal_fx alanlarindan elle surulur):
#  1) dinlenme: gecis bitince cizim kanca kapaliyken (eski sert kesme) cizilenle BIREBIR ayni - mola, ses, rekor, basarim (mola icinden),
#     baslik, sube, kisisellestirme, borc, defter (dukkandan): karartma + panel (HD parcalar, yazi, dugmeler) pikseli pikseline
#  2) belirme: panel girisinde panel pencere pikselleri dinlenmeden azalan farkla yaklasir (opaklik artar), bitince 0
#  3) kayma: opaklik 1'e vardiktan sonraki asma evresinde (+1 px) panel dinlenme karesinin 2 HD piksel asagi kaymisi ile AYNI
#     (HD parcalar, yazi ve dugmeler tek parca olarak kayar; HD / LD karisimi yok)
#  4) karartma: gorunen opaklik 0'dan hedefe artarken sahne parlakligi tek yonlu azalir; hedefte kanca kapali kareyle AYNI
#  5) artik yok: gecis karesinden sonra dinlenme karesi kanca kapali kareyle BIREBIR ayni (grup opakligi / modulate sonraki
#     karelere sizmaz)
#  6) kanca: kapali_zorla gecis durumundan bagimsiz sert kesme karesini verir
#  7) ayni durum ayni goruntuyu verir
#   godot --path . --script tests/modal_fx_visual.gd --quit-after 3000 -- --test --gpu-test
extends SceneTree
var shell: Control
var g: Node
var M: Variant
var G: Dictionary
var failures: Array[String] = []
var checks := 0

func _initialize() -> void:
	create_timer(220.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label); push_error(label)

func goruntu() -> Image:
	await RenderingServer.frame_post_draw
	return shell.game_viewport.get_texture().get_image()

func adim(n: int) -> void:
	for i in n: g.advance(1.0 / 60.0)

# mevcut durumu donuk olarak cizer ve goruntuyu verir
func ciz() -> Image:
	g.random_state = 777
	g.j_IN.x = 2.0; g.j_IN.y = 2.0
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

# a'nin (x, y) pikseli b'nin (x, y - dy) pikseliyle ayni mi (a, b'nin dy HD piksel asagi kaymisi mi)
func fark_kaymis(a: Image, b: Image, pencere: Rect2i, dy: int, esik: float = 0.02) -> int:
	var n := 0
	var p := pencere.intersection(Rect2i(0, dy, 960, 540 - dy)).intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			var ca: Color = a.get_pixel(x, y)
			var cb: Color = b.get_pixel(x, y - dy)
			if absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b) > esik: n += 1
	return n

func parlaklik(im: Image, pencere: Rect2i) -> float:
	var t := 0.0
	var n := 0
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y, 2):
		for x in range(p.position.x, p.end.x, 2):
			var c: Color = im.get_pixel(x, y)
			t += c.r + c.g + c.b
			n += 1
	return t / maxf(float(n), 1.0) / 3.0

func kur(gun: float, seviye: int) -> void:
	g.random_state = 123456
	g.session_system.f_resetProgress()
	G = g.j_G
	G.prologueSeen = true
	for u in g.j_UPG: G.up[u.id] = float(mini(seviye, u.lv.size()))
	G.day = gun
	g.f_startDay()
	G = g.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 1000; G.hintT = 0
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.weather = "sun"
	G.meat = 12; G.friesTray = 12
	for k in G.stock.keys():
		G.stock[k] = 12; G.stockAnim[k] = 12
	g.j_FT.clear()
	g.j_PS.clear()
	for p in [g.j_SESP, g.j_STATS, g.j_BSP, g.j_CUSTOM, g.j_PAYP, g.j_BRP, g.j_TARIFP]: p.open = false

# senaryo: [kurulum, panel penceresi (mantiksal px), kimlik]
func senaryo(ad: String) -> void:
	kur(19.0, 2)
	match ad:
		"mola": G.scene = "pause"
		"ses": G.scene = "pause"; g.j_SESP.open = true
		"rekor": G.scene = "pause"; g.j_STATS.open = true
		"basarim": G.scene = "pause"; g.j_BSP.open = true
		"baslik": G.scene = "title"; g.j_BSP.open = true
		"sube": G.scene = "shop"; G.sceneT = 0.0; G.money = 3200.0; g.j_BRP.open = true
		"kisisel": G.scene = "shop"; G.sceneT = 0.0; G.money = 3200.0; g.j_CUSTOM.open = true
		"borc": G.scene = "shop"; G.sceneT = 0.0; G.money = 3200.0; g.j_PAYP.open = true
		"defter": G.scene = "shop"; G.sceneT = 0.0; G.money = 3200.0; g.j_TARIFP.open = true
	g.j_IN.x = 2.0; g.j_IN.y = 2.0
	adim(60)   # gecis biter, her sey dinlenmede

# kapali_zorla ile cizilen kareler panel sayacini ilerletmez: sonraki "acik" cizimde panel yeni acilmis sayilmasin diye dinlenmeye al
func dinlen() -> void:
	M._pt = 99.0
	M._p_kare = M._kare

func pencere_hd(ad: String) -> Rect2i:
	var m := {
		"mola": Rect2i(180, 70, 120, 120), "ses": Rect2i(140, 64, 200, 130), "rekor": Rect2i(100, 60, 280, 150),
		"basarim": Rect2i(60, 60, 360, 150), "baslik": Rect2i(60, 60, 360, 150), "sube": Rect2i(40, 60, 400, 150),
		"kisisel": Rect2i(80, 50, 320, 160), "borc": Rect2i(110, 60, 260, 140), "defter": Rect2i(100, 60, 280, 150),
	}
	var r: Rect2i = m[ad]
	return Rect2i(r.position * 2, r.size * 2)

# her senaryoda: dinlenme == kanca kapali; sonra kismi durumlar
func dene(ad: String, tam: bool) -> void:
	senaryo(ad)
	var W: Rect2i = pencere_hd(ad)
	var dinlenme: Image = await ciz()
	M.kapali_zorla = true
	var eski: Image = await ciz()
	M.kapali_zorla = false
	dinlen()
	check(fark(dinlenme, eski, W) == 0, "%s: dinlenme karesi kanca kapaliyla (eski sert kesme) BIREBIR ayni (%d piksel)" % [ad, fark(dinlenme, eski, W)])
	if not tam: return
	var dinlenme2: Image = await ciz()
	check(fark(dinlenme, dinlenme2, W) == 0, "%s: ayni durum ayni goruntuyu verir" % ad)
	# 2) belirme: panel girisi pt = 0 ... PANEL_SURE, opaklik arttikca dinlenmeye yaklasir
	var anahtar: String = M._pk
	var oncekiler: Array = []
	for pt in [0.0, 0.03, 0.06, 0.09, 0.12, 0.16, 0.2]:
		M._pk = anahtar; M._pt = pt; M._p_kare = M._kare
		var im: Image = await ciz()
		oncekiler.append([pt, fark(im, dinlenme, W), im])
	var sira := ""
	var azalan := true
	for i in range(1, oncekiler.size()):
		sira += " %d" % int(oncekiler[i - 1][1])
		if int(oncekiler[i][1]) > int(oncekiler[i - 1][1]) + 40: azalan = false
	check(int(oncekiler[0][1]) > 200, "%s: panel girisinin ilk karesi dinlenmeden belirgin farkli (%d piksel)" % [ad, int(oncekiler[0][1])])
	var b_dinlenme: float = parlaklik(dinlenme, W)
	var b_ilk: float = parlaklik(oncekiler[0][2], W)
	var b_yarim: float = parlaklik(oncekiler[2][2], W)
	check(b_ilk < b_dinlenme * 0.8 and b_ilk < b_yarim and b_yarim < b_dinlenme, "%s: panel gercekten belirir: ilk karede soluk, sonra artar (parlaklik %.3f < %.3f < %.3f)" % [ad, b_ilk, b_yarim, b_dinlenme])
	check(azalan, "%s: panel dinlenmeye yaklasir (farklar azalir:%s %d)" % [ad, sira, int(oncekiler[-2][1])])
	check(int(oncekiler[-1][1]) == 0, "%s: panel girisi bitince dinlenme karesiyle BIREBIR ayni (%d piksel)" % [ad, int(oncekiler[-1][1])])
	# 3) kayma: opaklik 1'e vardiktan sonra asma evresi (+1 px = 2 HD piksel asagi)
	var k_beklenen: float = M._kayma_hesapla(0.14)
	if k_beklenen == 1.0:
		M._pk = anahtar; M._pt = 0.14; M._p_kare = M._kare
		var asma: Image = await ciz()
		var duz: int = fark(asma, dinlenme, W)
		var kaymis: int = fark_kaymis(asma, dinlenme, Rect2i(W.position.x, W.position.y + 8, W.size.x, W.size.y - 16), 2)
		check(duz > 100 and kaymis * 20 < duz, "%s: asma evresinde panel dinlenme karesinin 2 HD piksel asagi kaymisi (duz %d, kaymis %d piksel farkli)" % [ad, duz, kaymis])
	# 5) artik yok: gecis karesinden sonra dinlenme, kanca kapali kareyle ayni
	M._pk = anahtar; M._pt = 0.0; M._p_kare = M._kare
	await ciz()
	M._pt = 99.0; M._p_kare = M._kare
	var sonra: Image = await ciz()
	check(fark(sonra, eski, W) == 0, "%s: gecis karesinden sonra dinlenme kanca kapali kareyle BIREBIR ayni (grup opakligi sizmaz, %d piksel)" % [ad, fark(sonra, eski, W)])
	# 6) kanca: gecis durumu ne olursa olsun kapali_zorla sert kesme karesini verir
	M._pk = anahtar; M._pt = 0.0; M._p_kare = M._kare
	M.kapali_zorla = true
	var kapali_gecis: Image = await ciz()
	M.kapali_zorla = false
	dinlen()
	check(fark(kapali_gecis, eski, W) == 0, "%s: kanca kapaliyken gecis durumu gorunmez (%d piksel)" % [ad, fark(kapali_gecis, eski, W)])
	M._pt = 99.0

func run() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.set_process(false)                       # oyun kendiliginden ilerlemez; gecis durumu elle surulur
	g.set_process_input(false)
	shell.set_process_input(false)
	shell.set_process_unhandled_input(false)
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	M = g.modal_fx
	await process_frame
	check(g.hd_acik and g.hd_gpu(), "HD acik ve GPU tuvali var")
	check(g.j_ctx.has_method("grup_basla"), "GPU tuvali grup opakligini destekler")
	# tam senaryolar (belirme + kayma + artik + kanca): mola ve buyuk bir panel; digerlerinde yalniz dinlenme == kanca kapali
	await dene("mola", true)
	await dene("rekor", true)
	for ad in ["ses", "basarim", "baslik", "sube", "kisisel", "borc", "defter"]:
		await dene(ad, false)

	# 4) karartma: gorunen opaklik artarken sahne parlakligi tek yonlu azalir; hedefte kanca kapali kareyle ayni
	senaryo("mola")
	var arka := Rect2i(0, 400, 300, 140)     # panelin disinda, sabit (tezgah onu)
	M.kapali_zorla = true
	var hedef_kare: Image = await ciz()
	M.kapali_zorla = false
	var onceki := 99.0
	var tek_yonlu := true
	var ilk := 0.0
	var son := 0.0
	var i := 0
	for oran in [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]:
		M._hedef = 0.62; M._gor = 0.62 * oran; M._t = M._sure
		M._p_kare = M._kare
		var im: Image = await ciz()
		var b: float = parlaklik(im, arka)
		if b > onceki + 0.002: tek_yonlu = false
		onceki = b
		if i == 0: ilk = b
		son = b
		i += 1
	check(tek_yonlu and ilk - son > 0.08, "karartma artarken sahne parlakligi tek yonlu azalir (%.3f -> %.3f)" % [ilk, son])
	M._hedef = 0.62; M._gor = 0.62; M._t = M._sure
	var tam_kare: Image = await ciz()
	check(fark(tam_kare, hedef_kare, arka) == 0, "karartma hedefte kanca kapali kareyle AYNI (%d piksel)" % fark(tam_kare, hedef_kare, arka))

	# 7) GpuCanvas.grup_basla / grup_bitir (panel belirmesinin dayanagi): opaklik grup icine uygulanir, disina degil; sonraki karede AYNI
	#    cizim ogesini kullanan cizim solmaz (begin_frame ogenin modulate'ini sifirlar)
	var c: Variant = g.j_ctx
	c.begin_frame()
	c.fillStyle = "#ff0000"
	c.fillRect(0, 0, 40, 40)           # grup disi: tam kirmizi
	c.grup_basla(0.3)
	c.fillRect(60, 0, 40, 40)          # grup icinde: %30
	c.grup_bitir()
	c.fillRect(120, 0, 40, 40)         # grup sonrasi: tam kirmizi
	c.end_frame()
	await RenderingServer.frame_post_draw
	var im1: Image = shell.game_viewport.get_texture().get_image()
	var r_dis: float = im1.get_pixel(40, 40).r
	var r_grup: float = im1.get_pixel(160, 40).r
	var r_son: float = im1.get_pixel(280, 40).r
	check(r_dis > 0.95 and r_son > 0.95, "grup disindaki cizimler tam opak (%.2f, %.2f)" % [r_dis, r_son])
	check(r_grup > 0.2 and r_grup < 0.4, "grup icindeki cizim %%30 opak (r = %.2f)" % r_grup)
	c.begin_frame()
	c._segment(c.item_mat)              # onceki karenin grup ogesi ayni sirayla yeniden kullanilir
	c.fillStyle = "#ff0000"
	c.fillRect(60, 0, 40, 40)
	c.end_frame()
	await RenderingServer.frame_post_draw
	var im2: Image = shell.game_viewport.get_texture().get_image()
	var r_tekrar: float = im2.get_pixel(160, 40).r
	check(r_tekrar > 0.95, "onceki karenin grup opakligi sonraki karede ayni ogeye sizmaz (r = %.2f)" % r_tekrar)
	c.begin_frame(); c.end_frame()

	for f in failures: push_error(f)
	print("MODAL FX GPU ", JSON.stringify({"checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
