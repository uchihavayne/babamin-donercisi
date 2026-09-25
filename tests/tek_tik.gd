# TEK TIK PORSIYON + MASA (birlesik surum, 8. tur). Oyuncu elestirisi: "en
# basit sey icin 7-8 tur; surekli ayni seye defalarca bastirarak keyif olmaz".
# Gercek ekleme fonksiyonlariyla: bir tik tam porsiyon koyar; masa 1 ikinci,
# masa 2 ucuncu urune de koyar; masa 3'te yan malzeme (tursu/yogurt/patates)
# tek tikla birlikte gider, siparisin istemedigi malzeme konmaz.
#   godot --headless --path . --script tests/tek_tik.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func fresh(up := {}, lavas := 1) -> Array:
	game.session_system.f_resetProgress()
	game.j_G.up = up.duplicate()
	game.j_G.day = 6.0
	game.f_startDay()
	game.j_G.tut = 99; game.j_G.shutT = 0; game.j_G.spawnT = 1000
	game.j_G.customers = []
	game.j_G.meat = 16.0; game.j_G.friesTray = 30.0
	game.j_G.stock.pickle = 24.0; game.j_G.stock.yogurt = 24.0
	for i in lavas:
		game.j_G.t = float(i)
		game.wrap_system.f_newWrap(i)
	game.j_G.act = 0.0
	return game.j_G.boards

func tam(w: Dictionary, alanlar: Array) -> bool:
	for a in alanlar:
		if float(w.get(a, 0)) < 4.0: return false
	return true

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/tek-tik-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	# 1) masasiz: her malzeme tek tikta tam
	var b := fresh()
	game.assembly_system.f_addMeat()
	for k in ["pickle", "yogurt", "fries"]: game.assembly_system.f_addIng(k)
	check(tam(b[0], ["meat", "pickleN", "yogurtN", "friesN"]), "tek tik tam porsiyon: %s" % b[0])
	check(float(game.j_G.meat) == 12.0 and float(game.j_G.stock.pickle) == 20.0, "stoktan porsiyon kadar dustu")
	# 2) masa 1 + iki tahta: bir tik iki lavasa
	b = fresh({"board": 1, "tongs": 1}, 2)
	game.assembly_system.f_addMeat()
	check(float(b[0].meat) == 4.0 and float(b[1].meat) == 4.0, "masa 1: et iki urune birden")
	game.assembly_system.f_addIng("pickle")
	check(float(b[0].pickleN) == 4.0 and float(b[1].pickleN) == 4.0 and float(b[0].yogurtN) == 0.0, "masa 1: set yok, yalniz tursu")
	# 3) masa 3: yan malzeme seti; tursusuz siparise tursu gitmez
	b = fresh({"board": 2, "tongs": 3}, 3)
	b[2]._order_recipe = {"yok": ["pickle"]}
	game.assembly_system.f_addIng("yogurt")
	check(tam(b[0], ["pickleN", "yogurtN", "friesN"]) and tam(b[1], ["pickleN", "yogurtN", "friesN"]), "masa 3: iki urune uc yan malzeme")
	check(float(b[2].pickleN) == 0.0 and tam(b[2], ["yogurtN", "friesN"]), "masa 3: tursusuz istenene tursu konmadi: %s" % b[2])
	check(float(b[0].meat) == 0.0, "yan malzeme seti eti koymaz")
	# 4) stok yetmezse kalan kadar
	b = fresh({"board": 1, "tongs": 1}, 2)
	game.j_G.meat = 6.0
	game.assembly_system.f_addMeat()
	check(float(b[0].meat) == 4.0 and float(b[1].meat) == 2.0 and float(game.j_G.meat) == 0.0, "et yetmezse ikinciye kalan kadar")
	# 5) iskender tabagi: tek tikta tam et
	fresh({"iskender": 1})
	var p := {"kind": "plate", "pide": true, "meat": 0.0, "butter": false, "yogurt": false, "yogurtN": 0.0, "tomato": 0.0, "pepper": 0.0, "state": "open", "pop": 0.0, "born": 0.0}
	game.j_G.boards[0] = p; game.j_G.act = 0.0
	game.assembly_system.f_addMeat()
	check(float(p.meat) == float(game.J.method(game.j_TUN, "iskMeat", [game.j_G])), "iskender eti tek tikta tam")
	print("TEK TIK ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
