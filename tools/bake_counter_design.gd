# Explicit authoring command. Replaces only the new counter's generated PNGs.
# Do not run over artwork edited in Pixelorama without keeping a copy first.
extends SceneTree
const Canvas=preload("res://scripts/pixel_canvas.gd")
var game: Node
var manifest: Dictionary

func _initialize() -> void: call_deferred("run")

func paint(method: String,args: Array,size: Vector2i) -> Image:
	var canvas:=Canvas.new()
	canvas.width=size.x; canvas.height=size.y; canvas.ensure()
	game.j_ctx=canvas
	game.callv(method,args)
	return canvas.image

func entry(key: String,sheet: String,region: Array,offset: Array,cell: Array,index: int,extra: Dictionary={}) -> void:
	manifest[key]={"sheet":sheet,"region":region,"offset":offset,"cell":cell,"index":index}
	manifest[key].merge(extra)

func run() -> void:
	manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/manifest.json"))
	game=load("res://scripts/counter_design.gd").new()
	game.storage.path="res://artifacts/counter-design/bake-save.json"; game.storage.values={}
	root.add_child(game); game.set_process(false); game.j_MUTED=true
	game.sprites_enabled=false
	game.j_G.custom.counter=0.0
	paint("f_drawCounterRaw",[],Vector2i(480,270)).save_png("res://assets/sprites/counter_design_base.png")
	entry("counter/design","counter_design_base.png",[0,0,480,270],[0,0],[480,270],0)
	var tray:=Image.create(256,128,false,Image.FORMAT_RGBA8)
	tray.fill(Color.TRANSPARENT)
	for i in 2:
		var method: String=["f_trayBase","f_trayInnerShade"][i]
		tray.blit_rect(paint(method,[32.0,32.0,44.0,32.0],Vector2i(128,128)),Rect2i(0,0,128,128),Vector2i(i*128,0))
		entry(method+"/44x32","counter_design_trays.png",[i*128,0,128,128],[-32,-32],[128,128],i)
	tray.save_png("res://assets/sprites/counter_design_trays.png")
	for spec in [["et",1.3,"f_meatStrip"],["tursu",4.7,"f_pickleSlice"],["patates",9.2,"f_fryStick"]]:
		var name: String="counter_fill_"+spec[0]+".png"
		var atlas:=Image.create(384,252,false,Image.FORMAT_RGBA8)
		atlas.fill(Color.TRANSPARENT)
		for q in 41:
			var canvas:=Canvas.new(); canvas.width=48; canvas.height=42; canvas.ensure()
			game.j_ctx=canvas
			# Call the procedural painter directly; no previously edited atlas is read.
			var top: float=game.tray_draw.f_fillPaint(2.0,6.0,44.0,32.0,q/40.0,spec[1],game.J.ref(Callable(game,spec[2]),5))
			var origin:=Vector2i(q%8,int(q/8))*Vector2i(48,42)
			atlas.blit_rect(canvas.image,Rect2i(0,0,48,42),origin)
			entry("fill/44x32/%.1f/%d"%[spec[1],q],name,[origin.x,origin.y,48,42],[-2,-6],[48,42],q,{"top":top-6})
		atlas.save_png("res://assets/sprites/"+name)
	var file:=FileAccess.open("res://assets/sprites/manifest.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t")); file.close()
	print("COUNTER ART: ",manifest.size()," total sprite regions; original atlases kept")
	game.free(); quit()
