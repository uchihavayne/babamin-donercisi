extends SceneTree
var games: Array[Node] = []
var checks := 0
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message); push_error(message)

func make_game(index: int) -> Node:
	var game: Node = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/module-services-" + str(index) + ".json"
	game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.f_startDay(); game.j_G.tut = 99; game.j_G.shutT = 0
	games.append(game)
	return game

func run() -> void:
	var first := make_game(1)
	var second := make_game(2)
	for property in ["customer_system","recipe_system","equipment_system","save_system","order_system","order_draw"]:
		check(first.get(property).game == first and second.get(property).game == second and not is_same(first.get(property),second.get(property)), "module context is isolated: " + property)
	first.j_G.up.knife = 2.0
	check(first.J.method(first.j_TUN,"shaveCd",[first.j_G]) == 0.3 and second.J.method(second.j_TUN,"shaveCd",[second.j_G]) == 0.5,"tuning callbacks use the correct game and knife level")
	first.f_doSlice()
	check(first.j_G.meat == 3 and second.j_G.meat == 0,"equipment action cannot mutate another game")
	first.j_PRICE.wrap = 25.0
	check(second.j_PRICE.wrap == 20.0,"recipe price defaults are copied per game")
	first.j_G.day = 7.0; first.j_G.money = 345.0
	first.j_G.custom = {"sign":"TEST","sub":"","poster":0.0,"counter":2.0}
	first.j_G.stats.wraps = 12.0; first.save_system.f_saveAll()
	var saved: Dictionary = first.f_loadGame()
	check(first.storage.last_error == OK and FileAccess.file_exists(first.storage.path),"save module writes through the existing atomic store")
	check(not FileAccess.file_exists(first.storage.path + ".tmp"),"atomic save leaves no temporary record behind")
	# Reload bytes from disk, rather than sharing the first game's in-memory state.
	second.storage.values = JSON.parse_string(FileAccess.get_file_as_string(first.storage.path))
	second.save_system.f_loadAndGo()
	check(second.j_G.day == 7 and second.j_G.money == 345 and second.j_G.stats.wraps == 12,"disk reload preserves progress and sales")
	check(second.j_G.up.knife == 2 and second.j_G.custom.sign == "TEST" and second.j_G.custom.counter == 2,"disk reload preserves equipment and customization")
	check(saved.sema == first.j_SAVE_SEMA,"save schema is unchanged")
	second.storage.values[second.j_SAVEKEY] = "broken json"
	check(second.f_loadGame() == null and second.j_SAVE_DURUM == "bozuk","malformed save remains rejected")
	second.storage.values[second.j_SAVEKEY] = JSON.stringify({"sema":second.j_SAVE_SEMA+1})
	check(second.f_loadGame() == null and second.j_SAVE_DURUM == "bozuk","future schema remains rejected")
	second.storage.values[second.j_SAVEKEY] = JSON.stringify({"day":3.0,"money":15.0})
	check(second.f_loadGame().sema == 1,"legacy save without a schema is still readable")
	second.f_clearSave()
	check(second.f_loadGame() == null and second.j_SAVE_DURUM == "yok","clearing a save uses the same storage key")
	var report := {"checks":checks,"failures":failures,"coverage":"module ownership, independent state, tuning callbacks, disk save/load and schema compatibility"}
	var file := FileAccess.open("res://validation/module-services-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("MODULE SERVICES ",JSON.stringify(report))
	for game in games: game.free()
	games.clear(); await process_frame; quit(0 if failures.is_empty() else 1)
