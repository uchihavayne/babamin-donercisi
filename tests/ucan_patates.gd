# UCAN PATATES (birlesik surum, 12. tur, akicilik cilasi). Kullanici: "fritoze patates atiyorsun ... duz disk,
# smooth degil". HD'de cuvaldan tahtaya ucan patates 6x4'luk duz bir elipsti; artik tahtadaki patatesin
# ayni sprite'i donerek ucar (tests/ucan_patates_visual.gd GPU'da pikselleri olcer). Bu test MANTIGI kilitler:
#  1) f_potatoTake ucus baslatir; ucus ya da tahtada patates varken ikinci alim reddedilir
#  2) ucus 0.38 sn surer; inince tahtada patates var, ilerleme 0, "land" (inis ezilmesi) 1'den 0.2 sn'de sonar
#  3) inis tozu cikar ve rastgele sayi akisi bozulmaz (yalniz inis aninda)
#  4) CPU tuvalinde (HD yok) eski cizim yedegi calisir: ucus boyunca patates cizilir, konum yayi izler
#  5) kayit / gun ici goruntu ucus ortasinda da tutarli (flyP serilestirilebilir)
#   godot --headless --path . --script tests/ucan_patates.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(n: int = 1) -> void:
	for i in n: game.advance(1.0 / 60)

func kur() -> void:
	game.session_system.f_resetProgress()
	game.j_G.prologueSeen = true
	game.f_startDay()
	var G: Dictionary = game.j_G
	G.tut = 99; G.shutT = 0; G.spawnT = 100000; G.timeLeft = 100000; G.hintT = 0
	G.customers = []
	G.inspect = null; G.kedi = null; G.rakip = null; G.kesinti = null

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/ucan-patates-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	kur()
	var G: Dictionary = game.j_G
	# 1) ucus baslar
	G.cut.potato = false; G.cut.prog = 0.0; G.cut.land = 0.0
	game.potato_system.f_potatoTake()
	check(G.flyP is Dictionary and float(G.flyP.t) == 0.0, "f_potatoTake ucusu baslatir")
	var x0: float = float(G.flyP.x0); var y0: float = float(G.flyP.y0); var x1: float = float(G.flyP.x1); var y1: float = float(G.flyP.y1)
	check(x0 > x1 and y0 > y1, "ucus cuvaldan (sag-alt) tahtaya (sol-ust): (%d,%d) -> (%d,%d)" % [x0, y0, x1, y1])
	game.potato_system.f_potatoTake()
	check(float(G.flyP.t) == 0.0 and not bool(G.cut.potato), "ucus surerken ikinci alim reddedilir (ucus sifirlanmaz)")
	# 2) ucus suresi ve inis
	var onceki_t := 0.0
	var iniste := -1
	var rnd_oncesi := -1
	for kare in 40:
		if G.flyP == null: break
		onceki_t = float(G.flyP.t)
		rnd_oncesi = game.random_state
		step()
		check(G.flyP == null or float(G.flyP.t) > onceki_t, "ucus ilerler (kare %d)" % kare)
		if G.flyP == null: iniste = kare + 1
	check(iniste >= 22 and iniste <= 24, "ucus 0.38 sn ~ 23 karede biter (%d kare)" % iniste)
	check(G.flyP == null and bool(G.cut.potato) and float(G.cut.prog) == 0.0, "inince tahtada patates var, ilerleme 0")
	check(float(G.cut.land) > 0.9 and float(G.cut.land) <= 1.0, "inis aninda ezilme zamanlayicisi ~1 (%s)" % G.cut.land)
	# 3) land 0.2 sn'de sonar, eksiye dusmez
	var son := float(G.cut.land)
	var azaldi := true
	for kare in 16:
		step()
		if float(G.cut.land) > son + 0.0001: azaldi = false
		son = float(G.cut.land)
		check(son >= 0.0, "land eksiye dusmez")
	check(azaldi and son == 0.0, "land tek yonlu azalir ve 0.2 sn icinde 0 olur (%s)" % son)
	# tahtada patates varken yeni alim reddedilir
	game.potato_system.f_potatoTake()
	check(G.flyP == null, "tahtada patates varken alim reddedilir")
	# 4) eski cizim yedegi (CPU tuvali): ucus boyunca patates konum yayinda cizilir
	kur(); G = game.j_G
	check(not game.hd_gpu(), "bu testte GPU yok: HD kancasi kapali, eski cizim yedegi calisir")
	G.cut.potato = false; G.cut.prog = 0.0
	var bos: Image = zemin_goruntusu()
	game.potato_system.f_potatoTake()
	var cizildi := 0
	for kare in 20:
		step()
		if G.flyP == null: break
		var fp: Dictionary = G.flyP
		var k := float(fp.t)
		var ip: Vector2 = game.potato_system.f_inisNoktasi()
		var fx: float = lerpf(float(fp.x0), ip.x, k)
		var fy: float = lerpf(float(fp.y0), ip.y, k) - sin(k * PI) * 26.0
		var img: Image = game.screen_canvas.image
		var fark := 0
		for py in range(int(fy) - 7, int(fy) + 8):
			for px in range(int(fx) - 8, int(fx) + 9):
				if px < 0 or py < 0 or px >= 480 or py >= 270: continue
				if img.get_pixel(px, py) != bos.get_pixel(px, py): fark += 1
		if fark >= 14: cizildi += 1
	check(cizildi >= 16, "eski cizim: ucan patates her karede yayin uzerinde cizilir (%d / 20 kare)" % cizildi)
	# 5) ucus ortasinda gun ici kayit tutarli
	kur(); G = game.j_G
	G.cut.potato = false
	game.potato_system.f_potatoTake()
	step(6)
	G.scene = "play"
	check(game.save_system.gunici_kaydet(), "ucus ortasinda gun ici kayit yazilir")
	var anlik: Dictionary = game.save_system.gunici_oku()
	check(anlik.get("flyP") is Dictionary and float(anlik.flyP.t) > 0.0 and float(anlik.flyP.t) < 1.0, "anlik goruntu ucan patatesi tasir (%s)" % str(anlik.get("flyP")))
	game.save_system.gunici_sil()
	game.localization.f_setLang("tr")
	for f in failures: push_error(f)
	print("UCAN PATATES ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)

# patatesin cizilmedigi kare (ayni sahne): karsilastirma zemini
func zemin_goruntusu() -> Image:
	var tut: Variant = game.j_G.flyP
	game.j_G.flyP = null
	step()
	var img: Image = game.screen_canvas.image.duplicate()
	game.j_G.flyP = tut
	return img
