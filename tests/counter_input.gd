extends SceneTree
var game: Node
var checks:=0
var failures: Array[String]=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok: failures.append(label); push_error(label)
func step(count:=1) -> void:
	for i in count: game.advance(1.0/60)
func click(point: Vector2) -> void:
	for down in [true,false]:
		var event:=InputEventMouseButton.new()
		event.button_index=MOUSE_BUTTON_LEFT; event.position=point; event.pressed=down
		game._input(event); step()
func fresh(up: Dictionary) -> void:
	game.j_G.up=up; game.f_startDay()
	game.j_G.tut=99; game.j_G.shutT=0; game.j_G.spawnT=1000
func run() -> void:
	game=load("res://scripts/platform_game.gd").new()
	game.storage.path="res://artifacts/counter-design/input-save.json"; game.storage.values={}
	root.add_child(game); game.set_process(false); game.j_MUTED=true
	for index in 2:
		fresh({"sauce":1.0}); game.f_newWrap()
		var s: Dictionary=game.j_ST.sauce
		click(Vector2(s.x+(index+.5)*s.w/3,s.y+s.h/2))
		check(game.j_G.boards[0].sauce==["hot","garlic"][index],"mouse uses the visible sauce bottle "+str(index))
	for upgrades in [{"ayran":1.0},{"drink":1.0},{"drink":1.0,"ayran":1.0}]:
		fresh(upgrades); game.j_G.stock.ayran=8
		var taps: Array=game.drink_system.f_icecekMusluklari()
		var d: Dictionary=game.j_ST.drinkM
		for i in taps.size():
			click(Vector2(d.x+(i+.5)*d.w/taps.size(),d.y+16))
			check(game.j_G.cups.get(taps[i]) is Dictionary,"mouse starts the correct cup with "+str(taps.size())+" taps: "+taps[i])
		step(240)
		for type in taps:
			var p: Array=game.drink_system.f_cupPos(type)
			click(Vector2(p[0],p[1]))
			check(game.j_G.hand is Dictionary and game.j_G.hand.get("type")==type,"mouse picks the visible filled cup: "+type)
			game.j_G.hand=null
	fresh({"iskender":1.0,"garnish":1.0})
	game.recipe_system.f_newPide(false,0)
	game.stations.select("board:0")
	for i in int(game.j_PIDE_NEED): game.stations.execute("pide_chop",game.stations.target())
	game.j_G.stock.tomato=8; game.j_G.stock.pepper=8
	var garnish: Dictionary=game.j_ST.garnish
	for i in 2:
		click(Vector2(garnish.x+(i+.5)*garnish.w/2,garnish.y+garnish.h/2))
		check(game.j_G.stock[["tomato","pepper"][i]]==7,"mouse selects the correct garnish half: "+str(i))
	var sauce: Dictionary=game.j_ST.sauce
	click(Vector2(sauce.x+sauce.w*2.5/3,sauce.y+sauce.h/2))
	check(game.j_G.boards[0].butter,"mouse applies butter from the third bottle")
	var report:={"checks":checks,"failures":failures,"input":"native mouse events on macOS"}
	var file:=FileAccess.open("res://validation/counter-design/input-results.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	print("COUNTER INPUT ",JSON.stringify(report))
	game.free(); quit(0 if failures.is_empty() else 1)
