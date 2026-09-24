extends SceneTree
var shell: Control
var checks:=0
var failures: Array[String]=[]
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok: failures.append(label); push_error(label)
func step(n:=1) -> void:
	for i in n:
		await process_frame
		shell.game.advance(1.0/60)
func move(point: Vector2) -> void:
	var e:=InputEventMouseMotion.new()
	e.position=(shell.game_rect.position+point*shell.game_rect.size/Vector2(480,270))*Vector2(root.size)/root.get_visible_rect().size
	Input.parse_input_event(e)
func snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://validation/cutting/"+name+".png")
func blade_pixels(label: String) -> void:
	await RenderingServer.frame_post_draw
	var g: Node=shell.game
	var actual: Image=shell.game_viewport.get_texture().get_image()
	var blade: Variant=g.sprite_library.get_sprite("knife/0/-1")
	var offset: Array=g.sprite_library.manifest["knife/0/-1"].offset
	var origin:=Vector2i(roundi(g.j_IN.x-5),roundi(clampf(g.j_IN.y,g.j_LAY.spit.top+8,g.j_LAY.spit.bot-12)))+Vector2i(offset[0],offset[1])
	var wrong:=0
	# BIRLESIK: oyun gorunumu 2x HD tuvale cizilir (960x540); mantik pikselini
	# kendi bloğunun ilk pikselinden oku
	var s: int=maxi(1,actual.get_width()/480)
	for y in blade.image.get_height():
		for x in blade.image.get_width():
			var expected: Color=blade.image.get_pixel(x,y)
			if expected.a!=1: continue
			var pixel: Color=actual.get_pixel((origin.x+x)*s,(origin.y+y)*s)
			if maxf(absf(pixel.r-expected.r),maxf(absf(pixel.g-expected.g),absf(pixel.b-expected.b)))>2.0/255: wrong+=1
	check(wrong==0,label+": all opaque knife pixels survive final GPU composition (covered: "+str(wrong)+")")
func run() -> void:
	root.size=Vector2i(1440,810); root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND; root.content_scale_size=Vector2i(960,540)
	shell=load("res://scenes/main.tscn").instantiate(); root.add_child(shell)
	var g: Node=shell.game
	# BIRLESIK: bu test tabanin PIKSEL bicak sprite'inin son GPU birlesiminde
	# ortulmedigini denetler; HD'de bicak baska modelle (f_hdBicak) cizilir ve
	# katmani hd_sahne goruntuleriyle dogrulanir -> burada HD kapali.
	g.hd_acik=false
	g.j_MUTED=true; g.localization.f_setLang("tr"); g.j_G.up={"phone":1.0,"uncle":1.0}; g.f_startDay()
	g.j_G.tut=99; g.j_G.shutT=0; g.j_G.spawnT=10000; g.j_G.timeLeft=80
	g.j_G.phone.state="order"; g.j_G.phone.order=[{"kind":"wrap","yok":["pickle"]},{"kind":"wrap","yok":["fries"]},{"kind":"drink","type":"ayran"},{"kind":"fbox"},{"kind":"sweet"}]; g.j_G.phone.done=[false,false,false,false,false]
	await step(3)
	move(Vector2(66,82)); await step(); move(Vector2(50,103)); await step()
	check(g.j_G.meat==3,"actual window mouse input cuts diagonally without clicking")
	await blade_pixels("blade crossing the phone receipt during a cut"); await snap("mouse-receipt-layer")
	for point in [Vector2(43,110),Vector2(80,152),Vector2(66,180)]:
		move(Vector2(66,110)); await step(); move(point); await step()
		check(g.f_hitST("spit"),"knife stays attached at "+str(point))
		await blade_pixels("edge "+str(point))
	move(Vector2(66,100)); await step(); g.j_G.meat=16; await step()
	await blade_pixels("full tray"); await snap("mouse-tray-full")
	var before: float=g.j_G.meat; await step(40)
	check(g.j_G.meat==before,"stationary hover never continues cutting")
	root.size=Vector2i(1170,540); await step(3); shell.update_layout(); await step()
	g.j_G.meat=0; g.reset_mouse_cut(); g.j_G.shave.cd=0
	move(Vector2(54,110)); await step(); move(Vector2(78,110)); await step()
	check(g.j_G.meat==3,"horizontal movement maps correctly with a letterboxed viewport")
	await blade_pixels("letterboxed viewport"); await snap("mouse-horizontal")
	var outside:=InputEventMouseMotion.new(); outside.position=Vector2(1,1); Input.parse_input_event(outside); await step()
	check(not g.f_hitST("spit"),"leaving the game surface clears the cutting hover")
	move(Vector2(66,110)); await step(); await blade_pixels("mouse re-entry")
	g.j_G.meat=0; g.j_G.shave.cd=0; g.reset_mouse_cut()
	move(Vector2(66,100)); await step()
	move(Vector2(66,110)); move(Vector2(66,100)); await step()
	check(g.j_G.meat==3,"the native input pipeline preserves a fast out-and-back within one frame")
	await step(40)
	check(g.j_G.meat==3,"native input does not queue cuts after movement stops")
	var report:={"checks":checks,"failures":failures,"renderer":RenderingServer.get_video_adapter_name(),"input":"native mouse events through platform_shell, final GPU pixel comparison"}
	var f:=FileAccess.open("res://validation/cutting/mouse-slicing-visual-results.json",FileAccess.WRITE); f.store_string(JSON.stringify(report,"\t")); f.close()
	print("MOUSE SLICING VISUAL ",JSON.stringify(report)); shell.free(); await process_frame; quit(0 if failures.is_empty() else 1)
