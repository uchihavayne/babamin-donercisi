# Measures CPU time in advance(); it is not a hardware FPS or GPU latency test.
extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game: Node = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/module-performance-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	for upgrade in game.j_UPG: game.j_G.up[upgrade.id] = float(upgrade.lv.size())
	game.f_startDay(); game.j_G.tut=99; game.j_G.shutT=0; game.j_G.spawnT=10000
	for i in 5: game.customer_system.f_spawnCustomer()
	for customer in game.j_G.customers: customer.state="wait"; customer.x=customer.tx
	for i in 15: game.advance(1.0/60)
	var samples: Array[float] = []
	for i in 60:
		game.advance(1.0/60)
		samples.append(game.last_frame_ms)
	samples.sort()
	var report := {"frames":samples.size(),"median_cpu_ms":samples[30],"p95_cpu_ms":samples[57],"gpu_command_mode":game.gpu_enabled,"measurement":"CPU simulation and drawing-command preparation only"}
	var file := FileAccess.open("res://artifacts/module-performance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("MODULE PERFORMANCE ",JSON.stringify(report))
	game.free(); await process_frame; quit()
