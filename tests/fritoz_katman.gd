# FRITOZ KATMANI (birlesik surum, 12. tur): kullanici "fritoze patates atiyorsun, patates her
# seyin layer olarak onunde kaliyor" dedi. Eski (HD kapali) cizimde kizaran / pismis patates
# cubuklari yag penceresinin DISINA tasip fritozun cercevesini, ust kapagini ve govdesini
# ortuyordu.
#  1) kizarirken ve pismisken piksellerin yalniz YAG PENCERESININ ICI (ve durum isigi) degisir;
#     cerceve, kapak ve govde bos fritozla ayni kalir
#  2) pencerenin icinde patates gorunur (cizim gercekten yapiliyor)
#  3) F2 (HD ac/kapa) yalniz gelistirme derlemesinde; HD durum metni neden kapali oldugunu soyler
#   godot --headless --path . --script tests/fritoz_katman.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func cizim(durum: String, t: float, st: Dictionary) -> Image:
	var c: Variant = game.draw_context
	c.fillStyle = "#44525a"
	c.fillRect(0, 0, 480, 270)
	game.f_drawFryer(st.x, st.y, st.w, st.h, {"state": durum, "load": 8.0, "prog": 0.5}, t)
	return game.screen_canvas.image.duplicate()

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/fritoz-katman-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	game.j_G.prologueSeen = true; game.session_system.f_resetProgress(); game.f_startDay()
	check(bool(game.get("counter_design_enabled")), "yeni tezgah tasarimi acik")
	var st: Dictionary = game.j_ST.fryer
	var x := int(st.x); var y := int(st.y); var w := int(st.w); var h := int(st.h)
	var pencere := Rect2i(x + 8, y + 13, w - 16, h - 26)
	var isik := Rect2i(x + 7, y + h - 8, 5, 4)
	var bos := cizim("idle", 1.0, st)
	for durum in ["fry", "done"]:
		var dolu := cizim(durum, 1.0, st)
		var disarida := 0
		var iceride := 0
		for py in range(y - 14, y + h + 4):
			for px in range(x - 4, x + w + 4):
				if bos.get_pixel(px, py) == dolu.get_pixel(px, py): continue
				if pencere.has_point(Vector2i(px, py)): iceride += 1
				elif isik.has_point(Vector2i(px, py)): continue
				else: disarida += 1
		check(disarida == 0, "%s: patates yag penceresinin disina tasmiyor (disarida degisen piksel: %d)" % [durum, disarida])
		check(iceride > 40, "%s: pencerenin icinde patates cizilir (degisen piksel: %d)" % [durum, iceride])
	# F2: yalniz debug derlemesinde. Test derlemesi debug oldugundan tus calisir; yayin kosulu
	# fonksiyonun ilk satirindan dogrulanir.
	var kaynak := FileAccess.get_file_as_string("res://scripts/remake_gorsel.gd")
	check(kaynak.contains("if not OS.is_debug_build(): return false"), "F2 yalniz gelistirme derlemesinde (yayinda tus yok sayilir)")
	game.hd_acik = true
	check(game.hd_durum_metni() != "", "CPU tuvalinde (GPU yok) HD durum metni neden kapali oldugunu soyler: %s" % game.hd_durum_metni())
	game.hd_acik = false
	check(game.hd_durum_metni().begins_with("ESKİ ÇİZİM"), "HD kapaliyken 'ESKİ ÇİZİM' etiketi: %s" % game.hd_durum_metni())
	game.free()
	if failures.is_empty():
		print("FRITOZ KATMANI TAMAM")
		quit(0)
	else:
		print("FRITOZ KATMANI HATA: ", failures.size())
		for f in failures: print("  - ", f)
		quit(1)
