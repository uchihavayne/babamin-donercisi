extends SceneTree
const Canvas = preload("res://scripts/pixel_canvas.gd")
var original: Variant
var sprites: Variant
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: call_deferred("run")
func canvas(game: Variant) -> void:
	var c := Canvas.new(); c.width=480; c.height=270; c.ensure(); c.image.fill(Color("627486")); game.j_ctx=c
	game.random_state=123456
	game.j_PS=[]
func pair(name: String) -> void:
	original.j_ctx.image.save_png("res://artifacts/sprite-migration/equiv-"+name+"-original.png")
	sprites.j_ctx.image.save_png("res://artifacts/sprite-migration/equiv-"+name+"-sprites.png")
	checks+=1
	if original.random_state!=sprites.random_state: failures.append(name+" random sequence")
	if JSON.stringify(original.j_PS)!=JSON.stringify(sprites.j_PS): failures.append(name+" particles")
func run() -> void:
	original=load("res://scripts/game.gd").new()
	sprites=load("res://scripts/game_sprites.gd").new()
	for game in [original,sprites]:
		game.storage.path="res://artifacts/equiv-save.json"; game.storage.values={}; root.add_child(game); game.set_process(false); game.j_MUTED=true; game.f_startDay()
	for seed_index in range(4):
		var look: Dictionary=original.appearance_system.f_newCustomerLook(float(seed_index*7+1))
		for mood in ["neutral","angry","happy","served"]:
			for t in [.2,1.1,3.7]:
				canvas(original); canvas(sprites)
				var customer := {"look":look.duplicate(true),"mood":mood,"state":"wait" if t<2 else "walkin","x":142.25,"y":152.0,"patience":.2 if t>1 else .8}
				original.f_drawCustomer(customer.duplicate(true),t)
				sprites.f_drawCustomer(customer.duplicate(true),t)
				pair("customer-%d-%s-%s" % [seed_index,mood,t])
	for n in [0.0,1.0,3.0,7.25,12.0]:
		for fx in [0.0,.2,.5,.8]:
			canvas(original); canvas(sprites)
			original.f_drawYogurtTray(142.0,168.0,34.0,28.0,n,12.0,3.0,fx)
			sprites.f_drawYogurtTray(142.0,168.0,34.0,28.0,n,12.0,3.0,fx)
			pair("yogurt-%s-%s" % [n,fx])
	for roast in [0.0,.45,.9,1.2]:
		for mass in [.05,.45,1.0]:
			for cut in [0.0,4.0]:
				canvas(original); canvas(sprites)
				var spit := {"rot":1.3,"roast":roast,"mass":mass,"sliceT":0.0,"cutDepth":cut}
				original.f_drawSpit(spit,.42); sprites.f_drawSpit(spit,.42)
				pair("spit-%s-%s-%s" % [roast,mass,cut])
	var file:=FileAccess.open("res://artifacts/sprite-migration/equivalence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures},"\t")); file.close()
	print("SPRITE EQUIVALENCE ",checks," random/particle checks; failures=",failures)
	original.free(); sprites.free(); quit(0 if failures.is_empty() else 1)
