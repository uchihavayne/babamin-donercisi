# FRITOZE KOY (birlesik surum, 12. tur, akicilik cilasi). Kullanici: "fritoze koy gecisi animasyonsuz / anlik".
# Hamur patates cubuklari tahtadan aninda kayboluyor, fritozde aninda beliriyordu. Simdi cubuklar sepete ucar
# (FRITOZ_UCUS = 0.30 sn), sepette patates inince belirir, yag sicrar ve cizirdar.
# BU TEST OYUN MANTIGININ DEGISMEDIGINI kilitler (kizartma t=0'da baslar, sure ayni) ve gecisin kendisini olcer:
#  1) tikla: durum "fry", t=0, yuk / tahta stogu ANINDA ayarlanir; ucus (flyF) baslar, "basket" bir kez calar
#  2) ucus 0.30 sn; inince flyF biter, "sizzle" bir kez calar, sepette patates 0.14 sn'de belirginlesir (gir 1 -> 0)
#  3) kizartma zamani ucustan etkilenmez: t tikla anindan sayilir, tam dur'da "done"
#  4) eski cizim (CPU): ucus surerken yag penceresinde patates yok, cubuklar yolda cizilir, inince patates gorunur
#  5) ucus ortasinda gun ici goruntu flyF'i tasir; yeni gun ucusu temizler
#   godot --headless --path . --script tests/fritoze_koy.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []
var sesler := {}

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(n: int = 1) -> void:
	for i in n: game.advance(1.0 / 60)

func kur(raw: float = 3.0) -> void:
	game.session_system.f_resetProgress()
	game.j_G.prologueSeen = true
	game.f_startDay()
	var G: Dictionary = game.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.timeLeft = 100000; G.hintT = 0
	G.customers = []
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null
	G.cut.potato = false; G.cut.raw = raw; G.cut.prog = 0.0

# SFX cagrilarini sayar (ses kapali; kanca yerine sayac)
func ses_say() -> void:
	sesler = {}
	for ad in ["basket", "sizzle", "drop", "bell"]:
		var ad_: String = ad
		game.j_SFX[ad] = func(_a = null) -> void: sesler[ad_] = int(sesler.get(ad_, 0)) + 1

# yag penceresinin (x+8, y+13, w-16, h-26) icinde eski cizimin patates cubugu paleti (j_PT: acik / altin / kizarmis /
# isik) piksel sayisi; ucan ham cubuklar baska (krem) paletle cizilir, o yuzden sayilmaz
func patates_pikseli(img: Image) -> int:
	var f: Dictionary = game.j_ST.fryer
	var palet: Array = []
	for ad in ["acik", "altin", "kizarmis", "isik"]: palet.append(Color(str(game.j_PT[ad])))
	var n := 0
	for y in range(int(f.y) + 13, int(f.y) + int(f.h) - 13):
		for x in range(int(f.x) + 8, int(f.x) + int(f.w) - 8):
			var c: Color = img.get_pixel(x, y)
			for pc in palet:
				if absf(c.r - pc.r) + absf(c.g - pc.g) + absf(c.b - pc.b) < 0.03:
					n += 1
					break
	return n

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/fritoze-koy-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	kur()
	ses_say()
	var G: Dictionary = game.j_G
	var yuk: float = minf(float(game.J.method(game.j_TUN, "fryCap", [G])), 3.0)
	var sure: float = float(game.J.method(game.j_TUN, "fryTime", [G]))
	# 1) tikla: mantik ANINDA, ucus baslar
	game.potato_system.f_fryerClick()
	var F: Dictionary = G.fryer
	check(F.state == "fry" and float(F.t) == 0.0 and float(F.load) == yuk and float(F.dur) == sure, "tikla: kizartma ANINDA baslar (durum %s, t %s, yuk %s, sure %s)" % [F.state, F.t, F.load, F.dur])
	check(float(G.cut.raw) == 3.0 - yuk, "tahta stogu ANINDA azalir (%s)" % G.cut.raw)
	check(G.flyF is Dictionary and float(G.flyF.t) == 0.0 and int(G.flyF.n) == int(yuk), "ucus baslar (flyF %s)" % str(G.flyF))
	var b0: Vector2 = game.potato_system.f_cubukBaslangic()
	var b1: Vector2 = game.potato_system.f_sepetNoktasi()
	check(is_equal_approx(float(G.flyF.x0), b0.x) and is_equal_approx(float(G.flyF.y1), b1.y), "ucus tahtadaki yigindan sepete")
	check(b1.y < b0.y and absf(b1.x - b0.x) < 40.0, "sepet yigindan yukarida (%s -> %s)" % [b0, b1])
	check(int(sesler.get("basket", 0)) == 1 and int(sesler.get("sizzle", 0)) == 0, "tiklayinca 'basket' bir kez, 'sizzle' henuz yok (%s)" % str(sesler))
	# 2) ucus suresi
	var iniste := -1
	for kare in 30:
		step()
		if G.flyF == null and iniste < 0: iniste = kare + 1
	check(iniste >= 17 and iniste <= 19, "ucus 0.30 sn ~ 18 karede biter (%d kare)" % iniste)
	check(int(sesler.get("sizzle", 0)) == 1, "inince 'sizzle' tam bir kez (%s)" % str(sesler))
	check(float(F.gir) == 0.0, "30 kare sonra sepette patates tam belirgin (gir %s)" % F.gir)
	# 3) kizartma zamani ucustan etkilenmez: t tikla anindan sayilir
	check(absf(float(F.t) - 30.0 / 60.0) < 0.0001, "kizartma suresi tikla anindan sayilir (t=%s, beklenen 0.5)" % F.t)
	var kalan := int(ceil((sure - float(F.t)) * 60.0)) + 2
	step(kalan)
	check(F.state == "done" and int(sesler.get("bell", 0)) == 1, "kizartma tam 'sure' sonra biter (%s, bell %s)" % [F.state, sesler.get("bell", 0)])
	# inis aninda gir 1 olur ve 0.14 sn'de 0'a iner
	kur(); ses_say(); G = game.j_G; F = G.fryer
	game.potato_system.f_fryerClick()
	var gir_gorulen := 0.0
	var gir_dustu := true
	var onceki_gir := 1.0
	for kare in 40:
		step()
		if G.flyF == null:
			var g := float(F.gir)
			gir_gorulen = maxf(gir_gorulen, g)
			if g > onceki_gir + 0.0001: gir_dustu = false
			onceki_gir = g
	check(gir_gorulen > 0.8 and gir_dustu and float(F.gir) == 0.0, "gir inista ~1, tek yonlu 0'a iner (en yuksek %.2f)" % gir_gorulen)
	# 4) eski cizim (CPU tuvali): ucus surerken yag penceresinde patates yok; cubuklar cizilir; inince patates gorunur
	kur(); ses_say(); G = game.j_G; F = G.fryer
	check(not game.hd_gpu(), "bu testte GPU yok: eski cizim")
	step(2)
	game.potato_system.f_fryerClick()
	step(6)                                                         # ucus ortasi
	var ucus: Image = game.screen_canvas.image.duplicate()
	check(G.flyF != null, "6. karede ucus suruyor")
	step(3)
	var ucus2: Image = game.screen_canvas.image.duplicate()
	var p_ucus := patates_pikseli(ucus)
	check(p_ucus < 3, "ucus surerken yag penceresinde patates yok (%d px)" % p_ucus)
	var yol_farki := 0
	for py in range(150, 230):
		for px in range(330, 395):
			if ucus.get_pixel(px, py) != ucus2.get_pixel(px, py): yol_farki += 1
	check(yol_farki >= 20, "cubuklar yolda cizilir ve ilerler (kareler arasi %d px)" % yol_farki)
	step(15)                                                        # inis + belirginlesme
	check(G.flyF == null, "20+ kare sonra ucus bitti")
	step(10)
	var inis_sonrasi: Image = game.screen_canvas.image.duplicate()
	var p_sonra := patates_pikseli(inis_sonrasi)
	check(p_sonra >= 40, "inince yag penceresinde patates gorunur (%d px)" % p_sonra)
	# 5) gun ici kayit ucusu tasir; yeni gun temizler
	kur(); ses_say(); G = game.j_G
	game.potato_system.f_fryerClick()
	step(5)
	G.scene = "play"
	check(game.save_system.gunici_kaydet(), "ucus ortasinda gun ici kayit yazilir")
	var anlik: Dictionary = game.save_system.gunici_oku()
	check(anlik.get("flyF") is Dictionary and float(anlik.flyF.t) > 0.0 and float(anlik.flyF.t) < 1.0, "anlik goruntu fritoz ucusunu tasir (%s)" % str(anlik.get("flyF")))
	game.save_system.gunici_sil()
	game.f_startDay()
	check(game.j_G.flyF == null, "yeni gun fritoz ucusunu temizler")
	game.localization.f_setLang("tr")
	for fl in failures: push_error(fl)
	print("FRITOZE KOY ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
