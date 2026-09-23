extends SceneTree
var game: Node
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures.append(label); push_error(label)
func move(point: Vector2) -> void:
	var e:=InputEventMouseMotion.new(); e.position=point; game._input(e)
func step(count:=1, fps:=60) -> void:
	for i in count:
		game.controls.tick(1.0/fps)
		if game.j_G.scene=="play": game.f_updateShave(1.0/fps)
		game.effects.f_inEnd()
func fresh(level:=0) -> void:
	game.controls.release_all(); game.j_G.up={"knife":float(level)}; game.f_startDay()
	game.j_G.tut=99; game.j_G.shutT=0; game.j_G.spawnT=10000; game.j_G.meat=0
	game.controls.set_mode("mouse")
func run() -> void:
	game=load("res://scripts/platform_game.gd").new()
	game.storage.path="res://artifacts/cutting/mouse-slicing-save.json"; game.storage.values={}
	root.add_child(game); game.set_process(false); game.j_MUTED=true
	for stroke in [[Vector2(66,85),Vector2(66,109)], [Vector2(54,110),Vector2(78,110)], [Vector2(54,95),Vector2(72,113)]]:
		fresh(); move(stroke[0]); step(); move(stroke[1]); step()
		check(game.j_G.meat==3,"one short vertical/horizontal/diagonal stroke cuts without a click: "+str(stroke))
		check(not game.j_IN.down,"mouse motion does not need or synthesize a button press")
		step(90); check(game.j_G.meat==3,"stopping never drains buffered strokes into extra slices")
	fresh(); move(Vector2(66,100)); step()
	move(Vector2(66,110)); move(Vector2(66,100)); step()
	check(game.j_G.meat==3,"a fast out-and-back between rendered frames is counted")
	fresh(); move(Vector2(66,100)); step()
	for i in 8: move(Vector2(66,110)+Vector2.from_angle(i*TAU/8)*10)
	step(); check(game.j_G.meat==3,"a circular stroke counts movement in every direction")
	fresh(); move(Vector2(66,100)); step()
	for i in 20: move(Vector2(66+0.1*(i%2),100)); step()
	check(game.j_G.meat==0,"tiny pointer jitter cannot create a slice")
	fresh(); move(Vector2(66,100)); step()
	for i in 20: move(Vector2(66,80 if i%2 else 145))
	step(); step(120)
	check(game.j_G.meat==3,"many queued events cannot cause cuts after the mouse stops")
	fresh(); move(Vector2(48,110)); step(); move(Vector2(43,110)); step()
	check(game.f_hitST("spit"),"small edge overshoot keeps the knife attached")
	move(Vector2(38,110)); step()
	check(not game.f_hitST("spit"),"moving clear of the spit ends the gesture")
	move(Vector2(48,140)); step(); move(Vector2(43,140)); step()
	check(not game.f_hitST("spit"),"edge tolerance does not steal the chef's station")
	fresh(); move(Vector2(66,100)); step(); move(Vector2(200,100)); step(); move(Vector2(66,100)); step()
	check(game.j_G.meat==0,"leaving and re-entering cannot count the gap as cutting")
	game.j_G.meat=16; move(Vector2(66,140)); step(); step(60)
	check(game.j_G.meat==16 and game.cut_marks.is_empty(),"full tray blocks slices and success particles")
	game.j_G.meat=12; step(60)
	check(game.j_G.meat==12,"freeing tray capacity cannot trigger a stored cut")
	move(Vector2(66,110)); step()
	check(game.j_G.meat==15,"fresh movement cuts immediately after freeing tray space")
	var counts: Array[float]=[]
	for fps in [30,60,120]:
		fresh(); move(Vector2(54,110)); step()
		for i in fps*2: move(Vector2(78 if i%2==0 else 54,110)); step(1,fps)
		counts.append(game.j_G.meat)
		check(game.j_G.meat==12,"continuous movement repeats at the original knife cadence at "+str(fps)+" FPS")
	check(counts.max()-counts.min()<=1,"mouse cutting cadence is independent of frame rate")
	fresh(3); move(Vector2(54,110)); step()
	for i in 120: move(Vector2(78 if i%2==0 else 54,110)); step()
	check(game.j_G.meat==16,"knife upgrade still fills the tray faster")
	fresh(); move(Vector2(66,100)); step(); game.overlay_open=true
	move(Vector2(66,140)); step(); game.overlay_open=false; step(60)
	check(game.j_G.meat==0,"modal input cannot queue a cut for later")
	game.j_G.hand={"kind":"wrap","state":"ready"}; move(Vector2(66,100)); step()
	check(game.j_G.meat==0 and not game.f_hitST("spit"),"held food suppresses cutting and preserves the item cursor")
	game.j_G.hand=null; move(Vector2(66,140)); step(); game.controls.pause(); move(Vector2(66,100)); step(60); game.controls.pause(); step()
	check(game.j_G.meat==0,"pause clears the stroke and cannot resume cutting automatically")
	var fill_times: Dictionary = {}
	for fps in [30,60,120]:
		fresh(); move(Vector2(54,110)); step()
		var frames := 0
		while game.j_G.meat < 16 and frames < fps*4:
			move(Vector2(78 if frames%2==0 else 54,110)); step(1,fps); frames += 1
		var seconds: float = float(frames)/fps
		fill_times[str(fps)] = seconds
		check(game.j_G.meat==16 and seconds>=2.5 and seconds<=3.2,"continuous mouse movement fills the tray in about three seconds at "+str(fps)+" FPS")
	var report:={"checks":checks,"failures":failures,"two_second_mouse_counts":counts,"full_tray_seconds":fill_times}
	var f:=FileAccess.open("res://validation/cutting/mouse-slicing-results.json",FileAccess.WRITE); f.store_string(JSON.stringify(report,"\t")); f.close()
	print("MOUSE SLICING ",JSON.stringify(report)); game.free(); quit(0 if failures.is_empty() else 1)
