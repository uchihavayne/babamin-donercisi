extends SceneTree
var game: Node
var captures: Dictionary = {}
var label := "after"

func _initialize() -> void: call_deferred("run")

func capture(name: String) -> void:
	game.advance(1.0/60)
	var bytes: PackedByteArray = game.screen_canvas.image.get_data()
	var hash_context := HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256); hash_context.update(bytes)
	var state := {"scene":game.j_G.scene,"day":game.j_G.day,"money":game.j_G.money,"up":game.j_G.up,"meat":game.j_G.meat,"stock":game.j_G.stock,"boards":game.j_G.boards,"customers":game.j_G.customers,"phone":game.j_G.phone,"coins":game.j_G.coins,"random_state":game.random_state}
	captures[name] = {"pixels":hash_context.finish().hex_encode(),"state":JSON.stringify(state)}

func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--snapshot="): label = arg.trim_prefix("--snapshot=")
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/module-snapshot-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")
	capture("title")
	game.j_G.prologueSeen = true; game.session_system.f_resetProgress(); game.session_system.f_goIntro()
	capture("new-game-intro")
	game.f_startDay(); game.j_G.tut=99; game.j_G.shutT=0; game.j_G.spawnT=10000
	game.j_G.meat=16; game.j_G.friesTray=16; game.j_G.stock.pickle=16; game.j_G.stock.yogurt=16
	game.f_newWrap()
	for i in 4:
		game.assembly_system.f_addMeat(); game.assembly_system.f_addIng("pickle"); game.assembly_system.f_addIng("yogurt"); game.assembly_system.f_addIng("fries")
	game.customer_system.f_spawnCustomer()
	capture("prepared-order")
	game.f_finishRoll(0); game.wrap_system.f_applyPaper(0)
	capture("packed-wrap")
	for upgrade in game.j_UPG: game.j_G.up[upgrade.id] = float(upgrade.lv.size())
	game.f_startDay(); game.j_G.tut=99; game.j_G.shutT=0; game.j_G.spawnT=10000
	game.j_G.meat=0; game.pointer(Vector2(66,110)); game.f_doSlice()
	game.j_G.custom={"sign":"USTA DÖNER","sub":"EFSANE LEZZET","poster":1,"counter":2}
	game.j_CLAYER=null
	game.potato_system.f_potatoTake(); game.customer_system.f_spawnCustomer()
	capture("upgraded-shop")
	game.save_system.f_saveAll()
	captures["save"] = JSON.stringify(game.f_loadGame())
	var path := "res://artifacts/module-snapshot-" + label + ".json"
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(captures,"\t")); file.close()
	print("MODULE SNAPSHOT ",label," captured ",captures.size()," cases")
	var failures: Array[String] = []
	if label != "before":
		var baseline: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://validation/module-snapshot-baseline.json"))
		for name in baseline:
			if captures.get(name) != baseline[name]: failures.append(name)
		var report := {"cases":baseline.size(),"failures":failures,"comparison":"five exact pixel/state snapshots and one save snapshot from 0.5.4"}
		var result := FileAccess.open("res://validation/module-snapshot-results.json",FileAccess.WRITE)
		result.store_string(JSON.stringify(report,"\t")); result.close()
		print("MODULE EQUIVALENCE ",JSON.stringify(report))
	game.free(); await process_frame; quit(0 if failures.is_empty() else 1)
