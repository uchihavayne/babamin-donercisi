# COP KUTUSU (birlesik surum, 11. tur, kullanici karari "ayri hedefler"):
#  1) kutuya dokunmak HEP copu bosaltir; elde urun varsa onu atar; tezgahtaki /
#     izgaradaki urune dokunmaz
#  2) kova zaten bosken ve tezgahta urun varken kisa bir ipucu: nasil atilir
#  3) urunu tutup kutuya SURUKLEYIP birakmak urunu atar: fare (acik durum, sarili
#     durum, pide), dokunma, ve kumanda / klavyede "al" tusunu basili tutmak
#  4) 10 px'ten kisa hareket, kutu disinda birakma, erken birakilan bas-tut atmaz
#   godot --headless --path . --script tests/cop_kutusu.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func step(n := 1) -> void:
	for i in n: game.advance(1.0 / 60)

func center(key: String) -> Vector2:
	var s: Dictionary = game.j_ST[key]
	return Vector2(s.x + s.w / 2, s.y + s.h / 2)

func tahta(i: int) -> Vector2:
	return Vector2(float(game.wrap_system.f_boardCX(i)), float(game.wrap_system.f_boardCY()))

func mouse(p: Vector2, down: bool) -> void:
	var e := InputEventMouseButton.new()
	e.position = p; e.pressed = down; e.button_index = MOUSE_BUTTON_LEFT
	game._input(e); step(2)

func motion(p: Vector2) -> void:
	var e := InputEventMouseMotion.new(); e.position = p
	game._input(e); step(1)

func fare_surukle(a: Vector2, b: Vector2, adim := 8) -> void:
	mouse(a, true)
	for i in range(1, adim + 1): motion(a.lerp(b, float(i) / adim))
	mouse(b, false)

func dokun(p: Vector2, down: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = 0; e.position = p; e.pressed = down
	game._input(e); step(2)

func parmak(p: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = 0; e.position = p
	game._input(e); step(1)

func parmak_surukle(a: Vector2, b: Vector2, adim := 8) -> void:
	dokun(a, true)
	for i in range(1, adim + 1): parmak(a.lerp(b, float(i) / adim))
	dokun(b, false)

# temiz gun: tezgahta bir urun, cop belirli seviyede
func kur(urun := "acik", cop := 0.4) -> void:
	game.session_system.f_resetProgress()
	game.j_G.day = 2.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 10000; game.j_G.timeLeft = 10000
	game.j_G.meat = 8; game.j_G.stock.pickle = 12; game.j_G.stock.yogurt = 12; game.j_G.friesTray = 8
	game.j_G.customers = []
	game.j_G.inspect = null; game.j_G.kedi = null; game.j_G.rakip = null; game.j_G.kesinti = null
	game.j_G.hand = null; game.j_G.drag = null
	game.j_G.trash = cop
	game.f_newWrap()
	var w: Dictionary = game.j_G.boards[0]
	game.assembly_system.f_addMeat(); game.assembly_system.f_addIng("pickle")
	if urun == "sarili":
		for i in 3: game.assembly_system.f_addMeat(); game.assembly_system.f_addIng("pickle"); game.assembly_system.f_addIng("yogurt"); game.assembly_system.f_addIng("fries")
		game.f_finishRoll(0)
	elif urun == "hazir":
		for i in 3: game.assembly_system.f_addMeat(); game.assembly_system.f_addIng("pickle"); game.assembly_system.f_addIng("yogurt"); game.assembly_system.f_addIng("fries")
		game.f_finishRoll(0)
		game.wrap_system.f_applyPaper(0)
		step(120)
	elif urun == "pide":
		game.j_G.up["iskender"] = 1.0   # Iskender acik: pide acilabilir
		game.j_G.boards[0] = null
		game.recipe_system.f_newPide(false, 0)
	step(2)

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/cop-kutusu-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	game.controls.set_mode("mouse")
	var ES = game.event_system
	var bin := center("trash")
	# 1) kural: dokunmak copu bosaltir, tezgahtaki urune dokunmaz
	kur("acik", 0.6)
	game.j_G.grill.slots.append({"w": {"kind": "wrap", "state": "rolled", "burnt": true}, "t": 9.0, "dur": 8.0, "done": true, "yan": 9.0})
	check(ES.cop_eylemi() == "bosalt", "el bos, cop dolu: etiket 'bosalt' (%s)" % ES.cop_eylemi())
	ES.f_trashClick()
	check(is_zero_approx(float(game.j_G.trash)), "kutuya dokunmak copu bosaltir")
	check(game.j_G.boards[0] is Dictionary, "tezgahtaki urun yerinde (kutuya dokunmak onu atmaz)")
	check(game.j_G.grill.slots.size() == 1, "izgaradaki yanmis urun yerinde")
	# 2) kova bos, tezgahta urun var: ipucu; urun yine yerinde
	game.j_G.hintT = 0.0
	ES.f_trashClick()
	check(game.j_G.boards[0] is Dictionary and float(game.j_G.trash) == 0.0, "bos kovaya dokunmak da urunu atmaz")
	check(str(game.j_G.hint) == "Ürünü atmak için çöp kutusuna sürükle" and ES.cop_eylemi() == "bos", "ipucu: nasil atilir (%s)" % game.j_G.hint)
	game.j_G.boards[0] = null; game.j_G.grill.slots.clear()
	ES.f_trashClick()
	check(str(game.j_G.hint) == "Kova zaten boş", "urun de yoksa 'Kova zaten boş' (%s)" % game.j_G.hint)
	# 3) elde urun: kutuya dokunmak onu atar
	kur("acik", 0.3)
	game.j_G.hand = {"kind": "drink", "type": "cola"}
	check(ES.cop_eylemi() == "el", "elde urun: etiket 'el'")
	var onceki := float(game.j_G.trash)
	ES.f_trashClick()
	check(game.j_G.hand == null and float(game.j_G.trash) > onceki and game.j_G.boards[0] is Dictionary, "eldeki atilir, tezgahtaki yerinde, cop artar")
	# istasyon etiketi (dokunma / kumanda)
	game.stations.refresh(); game.stations.select("trash")
	var etiket := ""
	for a in game.stations.actions():
		if a.id == "trash": etiket = a.label
	check(etiket == "Çöpü boşalt", "istasyon etiketi el bosken 'Çöpü boşalt' (%s)" % etiket)
	game.j_G.hand = {"kind": "drink", "type": "cola"}
	for a in game.stations.actions():
		if a.id == "trash": etiket = a.label
	check(etiket == "Eldekini at", "istasyon etiketi elde urun varken 'Eldekini at' (%s)" % etiket)
	game.j_G.hand = null
	# 4) surukle-birak (kural katmani)
	kur("acik", 0.2)
	var t0 := tahta(0)
	check(not ES.f_dropOnTrash(t0, t0 + Vector2(4, 0)), "10 px'ten kisa hareket atmaz")
	check(not ES.f_dropOnTrash(t0, bin + Vector2(-80, 0)), "kutu disinda birakmak atmaz")
	check(game.j_G.boards[0] is Dictionary, "yukaridakiler urunu yerinde birakir")
	check(ES.f_dropOnTrash(t0, bin), "tahta urununu kutuya birakmak atar")
	check(game.j_G.boards[0] == null and float(game.j_G.trash) > 0.2, "urun gitti, cop artti")
	check(not ES.f_dropOnTrash(t0, bin), "ayni birakma ikinci kez bir sey yapmaz")
	# 5) fare: gercek olaylarla suruklemek (acik durum, sarili, hazir, pide)
	for urun in ["acik", "sarili", "hazir", "pide"]:
		kur(urun, 0.1)
		check(game.j_G.boards[0] is Dictionary, "[fare %s] tezgahta urun var" % urun)
		var cop0 := float(game.j_G.trash)
		fare_surukle(tahta(0), bin)
		check(game.j_G.boards[0] == null and game.j_G.hand == null, "[fare %s] kutuya surukleyip birakmak urunu atar (tahta %s, el %s)" % [urun, game.j_G.boards[0], game.j_G.hand])
		check(float(game.j_G.trash) > cop0, "[fare %s] cop artar" % urun)
	# fare: kutuya duz tik urunu atmaz
	kur("sarili", 0.5)
	mouse(bin, true); mouse(bin, false); step(5)
	check(game.j_G.boards[0] is Dictionary and is_zero_approx(float(game.j_G.trash)), "[fare] kutuya tiklamak copu bosaltir, urun yerinde")
	# fare: urunu tezgahta kisa surukleyip birakmak (kutu disi) urunu atmaz
	kur("hazir", 0.1)
	fare_surukle(tahta(0), tahta(0) + Vector2(0, -30), 4)
	check(game.j_G.boards[0] != null or game.j_G.hand != null, "[fare] kutu disina birakmak urunu atmaz")
	# 6) dokunma: urunu parmakla kutuya surukleyip birakmak
	game.controls.set_mode("touch")
	for urun in ["acik", "sarili", "hazir", "pide"]:
		kur(urun, 0.1)
		var cop1 := float(game.j_G.trash)
		parmak_surukle(tahta(0), bin)
		check(game.j_G.boards[0] == null and game.j_G.hand == null, "[dokunma %s] parmakla kutuya surukleyip birakmak urunu atar (tahta %s, el %s)" % [urun, game.j_G.boards[0], game.j_G.hand])
		check(float(game.j_G.trash) > cop1, "[dokunma %s] cop artar" % urun)
		check(game.stations.holding.is_empty(), "[dokunma %s] bas-tut kalmaz" % urun)
	kur("sarili", 0.5)
	dokun(bin, true); dokun(bin, false); step(5)
	check(game.j_G.boards[0] is Dictionary and is_zero_approx(float(game.j_G.trash)), "[dokunma] kutuya dokunmak copu bosaltir, urun yerinde")
	# 7) kumanda / klavye: urunun uzerinde "al" tusunu basili tut -> at; erken birak -> atmaz
	game.controls.set_mode("controller")
	for urun in ["acik", "pide"]:
		kur(urun, 0.1)
		game.stations.select("board:0")
		game.stations.secondary()
		check(not game.stations.holding.is_empty() and game.stations.holding.id == "discard", "[kumanda %s] 'al' tusu bas-tut atmayi baslatir" % urun)
		step(int(60 * game.stations.DISCARD_HOLD * 0.5))
		check(game.j_G.boards[0] != null, "[kumanda %s] yarida birakilmamis bas-tut henuz atmaz" % urun)
		game.stations.release("secondary")
		step(int(60 * game.stations.DISCARD_HOLD))
		check(game.j_G.boards[0] != null and game.stations.holding.is_empty(), "[kumanda %s] tusu erken birakmak atmaz" % urun)
		game.stations.secondary()
		step(int(60 * (game.stations.DISCARD_HOLD + 0.3)))
		check(game.j_G.boards[0] == null, "[kumanda %s] basili tutunca urun atilir" % urun)
	# alinabilen urun: ayni tus once ele alir (eski davranis), atmaz
	kur("hazir", 0.1)
	game.stations.select("board:0")
	game.stations.secondary()
	check(game.j_G.hand != null and game.j_G.boards[0] == null and game.stations.holding.is_empty(), "[kumanda] hazir urun 'al' ile ele alinir")
	# 8) aygita gore ipucu metni
	for kip in ["mouse", "touch", "controller"]:
		game.controls.set_mode("mouse"); game.controls.set_mode(kip)
		kur("acik", 0.0)
		game.j_G.hintT = 0.0
		game.event_system.f_trashClick()
		var m := str(game.j_G.hint)
		check(m != "" and m.contains("çöp") or m.contains("basılı"), "[%s] ipucu cikti: %s" % [kip, m])
	# 9) dort dilde cevirili
	for dil in ["en", "de", "fr", "es", "pt"]:
		var d: Dictionary = game.j_SOZLUK[dil]
		# f_say / f_T ile giden ipuclari her dilde (Ingilizce dahil); text(tr, en) ciftleri
		# Ingilizceyi koddan alir, yalniz de / fr / es / pt sozlukte arar
		for k in ["Ürünü atmak için çöp kutusuna sürükle", "Ürünü atmak için parmağınla çöp kutusuna sürükle", "Ürünü atmak için ürüne gel, al tuşunu basılı tut (□ / X / E)", "Ürünü atmak için basılı tut"]:
			check(d.has(k), "%s sozlugunde '%s' var" % [dil, k])
		if dil != "en":
			for k in ["Tezgâhtakini at · basılı tut", "Eldekini at", "Çöpü boşalt"]:
				check(d.has(k), "%s sozlugunde '%s' var" % [dil, k])
	print("COP KUTUSU ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
