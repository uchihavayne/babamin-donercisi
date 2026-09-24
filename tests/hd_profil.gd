# CIZIM PROFILI (gelistirme araci): dolu bir oyun ani kurar, cizim ve
# guncelleme fonksiyonlarini tek tek N kez cagirip ortalama ms yazar.
#   godot --path . --resolution 960x540 --script tests/hd_profil.gd -- --test --gpu-test [--eski]
extends SceneTree
const J = preload("res://scripts/js_compat.gd")

const N := 20
var shell: Control
var g: Node

func _initialize() -> void:
	create_timer(170.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("calis")

func olc(ad: String, fn: Callable) -> void:
	var c = g.screen_canvas
	var t0 := Time.get_ticks_usec()
	for i in N:
		c.begin_frame()
		fn.call()
		c.end_frame()
	print("%-28s %7.2f ms" % [ad, (Time.get_ticks_usec() - t0) / 1000.0 / N])

func calis() -> void:
	root.size = Vector2i(960, 540)
	shell = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	g = shell.game
	g.j_MUTED = true
	g.localization.f_setLang("tr")
	if "--eski" in OS.get_cmdline_user_args(): g.hd_acik = false
	olc("title", func() -> void: g.title_draw.f_drawTitle(1.0))
	olc("  shopStatic", func() -> void: g.interface_draw.f_drawShopStatic(1.0, false))
	olc("  logoCiz", func() -> void: g.logo_draw.f_logoCiz(1.0, 240.0, g.title_draw.f_baslikLogoUst()))
	olc("  titleMenu", func() -> void: g.title_draw.f_drawTitleMenu(1.0))
	olc("  vinyet", func() -> void:
		for i in 12: g.f_rrectOut(-i, -i, 480 + i * 2, 270 + i * 2, 8.0, "#000"))
	g.j_G.up = {}
	for u in g.j_UPG: g.j_G.up[u.id] = float(u.lv.size())
	g.f_startDay()
	g.j_G.tut = 99; g.j_G.shutT = 0; g.j_G.spawnT = 1000; g.j_G.hintT = 0
	g.f_newWrap()
	g.customer_system.f_spawnCustomer()
	for i in 10:
		g.advance(1.0 / 60.0)
		await process_frame
	var t := 3.0
	olc("f_drawPlay (tum)", func() -> void: g.f_drawPlay(t))
	olc("updatePlay", func() -> void: g.game_loop.f_updatePlay(1.0 / 60.0))
	olc("bg drawImage", func() -> void: g.j_ctx.drawImage(g.j_BG, 0.0, 0.0))
	olc("wallDecor", func() -> void: g.decor_draw.f_drawWallDecor(t))
	olc("  street", func() -> void: g.street_draw.f_drawStreet(t, 0.0, false, null))
	olc("    streetProps", func() -> void: g.street_draw.f_drawStreetProps(t, false))
	olc("    nearProps", func() -> void: g.street_draw.f_drawNearProps(t))
	var M: Dictionary = g.street_background.f_stM()
	olc("    yaya (tek)", func() -> void: g.pedestrian_draw.f_drawPed(300.0, M.walkY, 3.0, 1.0, t, 1.0, false))
	print("    yaya: %d  trafik: %d  karsiya: %d" % [g.j_WALKERS.size(), g.j_TRAF.size(), g.j_CROSSERS.size()])
	olc("  tabela", func() -> void: g.decor_draw.f_drawTabela(168.0, 2.0, t))
	olc("  poster", func() -> void: g.f_drawPoster(1.0, t))
	olc("customers", func() -> void:
		for c in g.j_G.customers: g.f_drawCustomer(c, t))
	olc("stoneFG", func() -> void: g.shop_background.f_drawStoneFG())
	olc("counter", func() -> void: g.f_drawCounter())
	olc("counterProps(+dayi)", func() -> void: g.f_drawCounterProps(t))
	olc("spit", func() -> void: g.f_drawSpit(g.j_G.spit, t))
	olc("phone", func() -> void: g.phone_draw.f_drawPhone(t))
	var S: Dictionary = g.j_ST
	olc("meatTray", func() -> void: g.ingredient_draw.f_drawMeatTray(S.meat.x, S.meat.y, S.meat.w, S.meat.h, g.j_G.meat, t, 0.0))
	olc("  trayBase", func() -> void: g.f_trayBase(S.meat.x, S.meat.y, S.meat.w, S.meat.h))
	olc("  trayInnerShade", func() -> void: g.f_trayInnerShade(S.meat.x, S.meat.y, S.meat.w, S.meat.h))
	olc("  drawFill", func() -> void: g.f_drawFill(S.meat.x, S.meat.y, S.meat.w, S.meat.h, 0.5, 1.3, J.ref(g.f_meatStrip, 5)))
	print("  dolum onbellek: ", g._dolum.size())
	olc("pickleTray", func() -> void: g.ingredient_draw.f_drawPickleTray(S.pickle.x, S.pickle.y, S.pickle.w, S.pickle.h, g.j_G.stockAnim.pickle, 20.0, t, 0.0))
	olc("fryer", func() -> void: g.f_drawFryer(S.fryer.x, S.fryer.y, S.fryer.w, S.fryer.h, g.j_G.fryer, t))
	olc("preparation", func() -> void: g.f_drawPreparation(t))
	olc("drinks", func() -> void: g.f_drawIcecekKasasi(S.drinkM.x, S.drinkM.y, S.drinkM.w, 34.0, 3.0, t))
	olc("order bubbles", func() -> void:
		for c in g.j_G.customers: g.f_drawOrderBubble(c, t))
	olc("hud", func() -> void: g.hud_draw.f_drawHUD(t))
	olc("particles", func() -> void: g.effects.f_psDraw())
	print("  parcacik: %d" % g.j_PS.size())
	quit(0)
