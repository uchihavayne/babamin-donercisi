# UCAN PATATES, GPU PIKSELLERI (birlesik surum, 12. tur, akicilik cilasi). Kullanici: "fritoze patates atiyorsun,
# duz disk, smooth degil". HD'de ucan patates 6x4'luk duz bir elipsti. Bu test GERCEK GPU tuvalinde olcer:
#  1) HD acik ve "ucan_patates" kancasi etkin
#  2) ucus boyunca patates yayin uzerinde, gercek patates boyutunda (HD piksel) cizilir
#  3) donerek ucar: farkli karelerde sekil farkli yonde (eski cizimde hep ayni yassi disk)
#  4) inisten hemen once (k=0.985) tahtadaki patatesle neredeyse ayni (kayipsiz oturur)
#  5) inis ezilmesi: land=1 iken patates tahtada alcak, land=0 iken statik cizimle birebir ayni
#  6) HD kapaliyken eski cizim yedegi de ucus boyunca cizer
#   godot --path . --script tests/ucan_patates_visual.gd --quit-after 3000 -- --test --gpu-test
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

# ucusu k noktasinda tutar (bir kare ilerletir: t = k)
func ucus_kare(k: float) -> Image:
	var st: Dictionary = g.j_ST
	g.j_G.cut.potato = false; g.j_G.cut.land = 0.0
	g.j_G.flyP = {"t": k - 1.0 / 60.0 / 0.38, "x0": st.potato.x + 14.0, "y0": st.potato.y + 8.0, "x1": st.cut.x + st.cut.w / 2.0 - 6.0, "y1": st.cut.y + 19.0}
	await step(1)
	return await goruntu()

# donme ilkeli: oyunun kendi kareden sonra, ayni merkezde verilen acida bir patates cizer
func donuk_kare(aci: float, merkez_: Vector2) -> Image:
	g.j_G.flyP = null; g.j_G.cut.potato = false; g.j_G.cut.land = 0.0
	g.advance(1.0 / 60)
	var TZ: Dictionary = g.atlas("tezgah")
	var p: Array = TZ.parca["patates_11"]
	g.draw_context.texture_hd_donuk(TZ.tex, Rect2(p[0], p[1], p[2], p[3]), merkez_.x, merkez_.y, aci)
	await process_frame
	return await goruntu()

func sabit_kare(land: float) -> Image:
	g.j_G.flyP = null
	g.j_G.cut.potato = true; g.j_G.cut.prog = 0.0; g.j_G.cut.land = land
	g.advance(0.0)
	await process_frame
	return await goruntu()

# baseline'dan farkli pikseller (HD piksel koordinati), pencere icinde; kareler arasi kendiliginden
# degisen (animasyonlu) pikseller (anim) sayilmaz
var anim := {}
func maske(img: Image, bos: Image, pencere: Rect2i, esik: float = 0.1) -> Array:
	var out: Array = []
	var p := pencere.intersection(Rect2i(0, 0, 960, 540))
	for y in range(p.position.y, p.end.y):
		for x in range(p.position.x, p.end.x):
			if anim.has(Vector2i(x, y)): continue
			var a: Color = img.get_pixel(x, y)
			var b: Color = bos.get_pixel(x, y)
			if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) > esik: out.append(Vector2i(x, y))
	return out

# iki maskenin merkezleri hizalanarak kesisim / birlesim orani (ayni sekil oteleme = 1; donmus sekil < 1)
func iou(a: Array, b: Array) -> float:
	var ca := merkez(a)
	var cb := merkez(b)
	var kayma := Vector2i((ca - cb).round())
	var kume := {}
	for p in a: kume[p] = true
	var kes := 0
	var bsay := 0
	for p in b:
		bsay += 1
		if kume.has(p + kayma): kes += 1
	return float(kes) / maxf(1.0, float(a.size() + bsay - kes))

func pencere_merkez(c: Vector2, yw: int = 40, yh: int = 36) -> Rect2i:
	return Rect2i(int(c.x) - yw, int(c.y) - yh, yw * 2, yh * 2)

func merkez(m: Array) -> Vector2:
	var s := Vector2.ZERO
	for p in m: s += Vector2(p)
	return s / maxf(1.0, float(m.size()))

func sinirlar(m: Array) -> Rect2i:
	if m.is_empty(): return Rect2i()
	var r := Rect2i(m[0], Vector2i.ONE)
	for p in m: r = r.expand(p)
	return r

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
	# 1) HD acik
	check(g.hd_acik and g.hd_gpu(), "HD acik ve GPU tuvali var")
	check(g.hd("ucan_patates"), "'ucan_patates' kancasi etkin")
	var st: Dictionary = g.j_ST
	var ip: Vector2 = g.potato_system.f_inisNoktasi()
	var x1: float = ip.x
	var y1: float = ip.y
	check(is_equal_approx(x1, st.cut.x + 17.0) and is_equal_approx(y1, st.cut.y + 19.0), "HD'de inis noktasi tahta patatesinin capasi (%s)" % ip)
	# zemin: patates yok; ikinci bir zemin karesiyle kendiliginden degisen pikseller ayiklanir
	G.flyP = null; G.cut.potato = false; G.cut.land = 0.0
	await step(2)
	var bos: Image = await goruntu()
	await step(7)
	var bos2: Image = await goruntu()
	anim = {}
	for y in 540:
		for x in 960:
			if bos.get_pixel(x, y) != bos2.get_pixel(x, y): anim[Vector2i(x, y)] = true
	var statik_pencere := pencere_merkez(Vector2(x1 * 2.0, y1 * 2.0), 40, 30)
	# statik tahta patatesi
	var statik: Image = await sabit_kare(0.0)
	var m_statik := maske(statik, bos, statik_pencere)
	var b_statik := sinirlar(m_statik)
	var c_statik := merkez(m_statik)
	olc["statik"] = [m_statik.size(), b_statik, c_statik]
	check(m_statik.size() > 400 and b_statik.size.x >= 40 and b_statik.size.y >= 24, "statik tahta patatesi cizili (%d piksel, %s)" % [m_statik.size(), b_statik])
	# 2) ucus kareleri: yay uzerinde, gercek patates boyutunda
	var kmask := {}
	for k in [0.25, 0.35, 0.5, 0.75]:
		var img: Image = await ucus_kare(k)
		var fp: Dictionary = G.flyP
		var kk: float = float(fp.t)
		var fx: float = lerpf(float(fp.x0), ip.x, kk)
		var fy: float = lerpf(float(fp.y0), ip.y, kk) - sin(kk * PI) * 26.0
		var beklenen := Vector2(fx * 2.0, fy * 2.0)
		var m := maske(img, bos, pencere_merkez(beklenen))
		var c := merkez(m)
		kmask[k] = m
		olc["k%.2f" % k] = [m.size(), c, beklenen]
		check(m.size() > 450, "k=%.2f: ucan patates cizili, gercek patates boyutunda (%d piksel)" % [k, m.size()])
		check(c.distance_to(beklenen) < 20.0, "k=%.2f: yay uzerinde (merkez %s, beklenen %s)" % [k, c, beklenen])
	# 3a) donus acisi ve olcek (saf fonksiyonlar): baslangicta belirgin donus, inise dogru yavaslar, inista 0 / 1
	check(absf(g.ucan_aci(0.25)) > 2.0 and absf(g.ucan_aci(0.25)) > absf(g.ucan_aci(0.5)) and absf(g.ucan_aci(0.5)) > absf(g.ucan_aci(0.75)), "donus acisi baslangicta buyuk, inise dogru azalir (%.2f / %.2f / %.2f)" % [g.ucan_aci(0.25), g.ucan_aci(0.5), g.ucan_aci(0.75)])
	check(absf(g.ucan_aci(1.0)) < 0.0001 and is_equal_approx(g.ucan_olcek(1.0), 1.0), "inista aci 0, olcek 1 (statik cizime oturur)")
	check(g.ucan_olcek(0.5) > g.ucan_olcek(0.0) and g.ucan_olcek(0.5) > 1.0, "yayin tepesinde patates daha iri (kameraya yakin): %.2f" % g.ucan_olcek(0.5))
	# 3b) donme ilkeli (texture_hd_donuk): ayni merkezde 0 / 45 / 90 derece -> sinir kutusu orani gercekten doner
	var oran := {}
	for a in [0.0, PI / 4.0, PI / 2.0]:
		var imd: Image = await donuk_kare(a, ip)
		var md := maske(imd, bos, statik_pencere, 0.3)
		var bd := sinirlar(md)
		oran[a] = float(bd.size.x) / maxf(1.0, float(bd.size.y))
	olc["oran"] = [oran[0.0], oran[PI / 4.0], oran[PI / 2.0]]
	check(oran[0.0] > 1.3 and oran[PI / 2.0] < 0.8 and oran[PI / 4.0] > 0.8 and oran[PI / 4.0] < 1.3, "donme ilkesi: 0 derece yatay, 90 derece dikey, 45 derece kareye yakin (%s)" % str(oran))
	# 3c) donerek ucar: ayni kare iki kez = ayni sekil (kontrol); farkli kareler = hizalanip karsilastirilinca bile farkli sekil
	var tekrar: Image = await ucus_kare(0.25)
	var m_tekrar := maske(tekrar, bos, pencere_merkez(merkez(kmask[0.25]), 40, 36))
	var kontrol := iou(kmask[0.25], m_tekrar)
	var donus := iou(kmask[0.25], kmask[0.35])
	olc["iou"] = [kontrol, donus]
	check(kontrol > 0.9, "kontrol: ayni karede sekil ayni (IoU %.2f)" % kontrol)
	check(donus < 0.85, "donerek ucar: k=0.25 ile 0.35 hizalansa bile sekil farkli (IoU %.2f)" % donus)
	# 4) inisten hemen once tahtadaki patatesle neredeyse ayni konum ve boyut
	var son_kare: Image = await ucus_kare(0.985)
	# yuksek esik: silik izler (alfa 0.22 / 0.12) sayilmaz, yalniz opak govde
	var m_son := maske(son_kare, bos, statik_pencere, 0.45)
	var m_statik3 := maske(statik, bos, statik_pencere, 0.45)
	var c_son := merkez(m_son)
	var b_son := sinirlar(m_son)
	var c_statik3 := merkez(m_statik3)
	var b_statik3 := sinirlar(m_statik3)
	olc["son"] = [m_son.size(), c_son, b_son, c_statik3, b_statik3]
	check(c_son.distance_to(c_statik3) < 6.0, "k=0.985: merkez tahtadaki patatesle ayni (%s / %s)" % [c_son, c_statik3])
	check(absi(b_son.size.x - b_statik3.size.x) <= 6 and absi(b_son.size.y - b_statik3.size.y) <= 6, "k=0.985: boyut ayni (%s / %s)" % [b_son.size, b_statik3.size])
	# 5) inis ezilmesi
	var ezik: Image = await sabit_kare(1.0)
	var m_ezik := maske(ezik, bos, statik_pencere)
	var b_ezik := sinirlar(m_ezik)
	olc["ezik"] = [m_ezik.size(), b_ezik]
	check(b_ezik.size.y <= b_statik.size.y - 3, "land=1: patates ezik (yukseklik %d < %d HD piksel)" % [b_ezik.size.y, b_statik.size.y])
	check(absi(b_ezik.end.y - b_statik.end.y) <= 2, "ezilirken alt kenar tahtada sabit kalir (%d / %d)" % [b_ezik.end.y, b_statik.end.y])
	var sonra: Image = await sabit_kare(0.0)
	var ayni := true
	for p in m_statik:
		if sonra.get_pixel(p.x, p.y) != statik.get_pixel(p.x, p.y): ayni = false; break
	check(ayni, "land=0: statik cizimle birebir ayni")
	# 6) eski cizim yedegi (HD kapali)
	g.hd_acik = false
	await step(3)
	check(not g.hd("ucan_patates"), "HD kapaliyken kanca devre disi")
	G.flyP = null; G.cut.potato = false; G.cut.land = 0.0
	await step(2)
	var bos_eski: Image = await goruntu()
	var eski: Image = await ucus_kare(0.5)
	var fp5: Dictionary = G.flyP
	var kk5: float = float(fp5.t)
	var ip5: Vector2 = g.potato_system.f_inisNoktasi()   # HD kapali: elipsin merkezi
	var m_eski := maske(eski, bos_eski, pencere_merkez(Vector2(lerpf(float(fp5.x0), ip5.x, kk5) * 2.0, (lerpf(float(fp5.y0), ip5.y, kk5) - sin(kk5 * PI) * 26.0) * 2.0)))
	olc["eski"] = m_eski.size()
	check(m_eski.size() > 60, "HD kapali: eski cizim yedegi ucan patatesi cizer (%d piksel)" % m_eski.size())
	g.hd_acik = true
	print("OLCUM ", JSON.stringify(olc))
	for f in failures: push_error(f)
	print("UCAN PATATES GPU ", JSON.stringify({"checks": checks, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
