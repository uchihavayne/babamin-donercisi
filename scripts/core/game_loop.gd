# Game loop. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:2525
func f_updatePlay(p_dt: Variant = null) -> Variant:
	var v_hedefA: Variant = null
	var v_ogretimde: Variant = null
	var v_was: Variant = null
	var v_wm: Variant = null
	var v_dragged: Variant = null
	var v_i: Variant = null
	var v_bw: Variant = null
	var v_dt: Variant = p_dt
	J.setv(game.j_G, "sceneT", J.add(J.getv(game.j_G, "sceneT"), v_dt))
	game.regulation_system.f_updateFerman(v_dt)
	game.regulation_system.f_updateGozcu(v_dt)
	game.leader_system.f_updateLider(v_dt)
	if J.gt(J.getv(game.j_G, "hintT"), 0.0):
		J.setv(game.j_G, "hintT", (J.getv(game.j_G, "hintT") - v_dt))
	if J.gt(J.getv(J.getv(game.j_G, "uncle"), "flashT"), 0.0):
		J.setv(J.getv(game.j_G, "uncle"), "flashT", (J.getv(J.getv(game.j_G, "uncle"), "flashT") - v_dt))
	if J.gt(J.getv(J.getv(game.j_G, "crate"), "popT"), 0.0):
		J.setv(J.getv(game.j_G, "crate"), "popT", (J.getv(J.getv(game.j_G, "crate"), "popT") - v_dt))
	v_hedefA = (1.0 if J.truth(J.getv(J.getv(game.j_G, "crate"), "open")) else 0.0)
	J.setv(J.getv(game.j_G, "crate"), "a", game.math_utils.f_approach((0.0 if J.eq(J.getv(J.getv(game.j_G, "crate"), "a"), null) else J.getv(J.getv(game.j_G, "crate"), "a")), v_hedefA, (v_dt * 5.5)))
	v_ogretimde = game.gameplay_input.f_tutBusy()
	if ((not J.truth(v_ogretimde)) and J.gt(J.getv(game.j_G, "timeLeft"), 0.0)):
		v_was = J.getv(game.j_G, "timeLeft")
		J.setv(game.j_G, "timeLeft", (J.getv(game.j_G, "timeLeft") - v_dt))
		if (J.le(J.getv(game.j_G, "timeLeft"), 10.0) and not J.eq(ceil(J.getv(game.j_G, "timeLeft")), ceil(v_was))):
			if J.le(J.getv(game.j_G, "timeLeft"), 5.0):
				J.method(game.j_SFX, "warn", [])
			else:
				J.method(game.j_SFX, "tick", [])
		if J.le(J.getv(game.j_G, "timeLeft"), 0.0):
			J.setv(game.j_G, "timeLeft", 0.0)
			game.session_system.f_endDay()
			return null
	game.event_system.f_kesintiGuncelle(v_dt)
	game.rival_system.f_rakipGuncelle(v_dt)
	game.event_system.f_kediGuncelle(v_dt)
	if ((not J.truth(v_ogretimde)) and J.gt(J.getv(game.j_G, "timeLeft"), 2.0)):
		J.setv(game.j_G, "spawnT", (J.getv(game.j_G, "spawnT") - v_dt))
		if J.le(J.getv(game.j_G, "spawnT"), 0.0):
			game.customer_system.f_spawnCustomer()
			v_wm = (1.75 if J.truth(game.weather_system.f_isRain()) else J.method(game.j_TUN, "havaGelis", [game.j_G]))
			if J.truth(game.weather_system.f_macDalgada()):
				v_wm = (v_wm * game.j_MAC_HIZ)
			if J.truth(game.progression_system.f_fermanDunya("sokak")):
				v_wm = (v_wm * 1.9)
			J.setv(game.j_G, "spawnT", (game.math_utils.f_rnd((J.getv(J.getv(game.j_G, "cfg"), "rate") * 0.75), (J.getv(J.getv(game.j_G, "cfg"), "rate") * 1.2)) * v_wm))
	if J.gt(J.getv(game.j_G, "shutT"), 0.0):
		J.setv(game.j_G, "shutT", max(0.0, (J.getv(game.j_G, "shutT") - (float(v_dt) / float(1.5)))))
		J.setv(game.j_G, "shutSnd", (J.getv(game.j_G, "shutSnd") - v_dt))
		if J.le(J.getv(game.j_G, "shutSnd"), 0.0):
			J.setv(game.j_G, "shutSnd", 0.55)
			J.method(game.j_SFX, "shutter", [])
		if J.le(J.getv(game.j_G, "shutT"), 0.0):
			J.method(game.j_SFX, "ding", [])
			game.effects.f_ftext("AÇILDIK!", (float(game.j_W) / float(2.0)), 96.0, J.getv(game.j_P, "au0"), {"sc": 1.0, "life": 1.2})
	game.payment_system.f_updateFlyCoins(v_dt)
	v_dragged = game.drag_system.f_updateDrag(v_dt)
	game.f_updateShave(v_dt)
	game.f_updateCut(v_dt)
	game.potato_system.f_updateFryer(v_dt)
	game.grill_system.f_updateGrill(v_dt)
	game.paper_system.f_updatePaper(v_dt)
	game.drink_system.f_updateDrink(v_dt)
	game.fries_box_system.f_updateFbox(v_dt)
	game.stock_system.f_updateStock(v_dt)
	game.drag_system.f_updateFly(v_dt)
	game.phone_system.f_updatePhone(v_dt)
	game.weather_system.f_updateWeather(v_dt)
	game.event_system.f_maybeInspector(v_dt)
	game.equipment_system.f_updateSauce(v_dt)
	game.helper_system.f_updateMoto(v_dt)
	game.cutting_system.f_updateFlyMeat(v_dt)
	if (not J.truth(game.drink_system.f_pouringAny())):
		game.f_pourSndStop(false)
	if J.truth(J.method(game.j_TUN, "autoIsk", [game.j_G])):
		J.setv(game.j_G, "autoIskT", J.add((J.getv(game.j_G, "autoIskT") if J.truth(J.getv(game.j_G, "autoIskT")) else 0.0), v_dt))
		if J.gt(J.getv(game.j_G, "autoIskT"), 0.8):
			J.setv(game.j_G, "autoIskT", 0.0)
			game.equipment_system.f_checkAuto()
	if J.gt(J.getv(game.j_G, "emptyT"), 0.0):
		J.setv(game.j_G, "emptyT", (J.getv(game.j_G, "emptyT") - v_dt))
	if J.gt(J.getv(game.j_G, "luckMsg"), 0.0):
		J.setv(game.j_G, "luckMsg", (J.getv(game.j_G, "luckMsg") - v_dt))
	game.customer_system.f_surukleServis()
	game.customer_system.f_updateCustomers(v_dt)
	game.payment_system.f_updateCoins(v_dt)
	game.gameplay_input.f_updateTut()
	J.setv(J.getv(game.j_G, "chef"), "armT", J.add(J.getv(J.getv(game.j_G, "chef"), "armT"), v_dt))
	if (J.eq(J.getv(J.getv(game.j_G, "chef"), "mode"), "slice") and J.le(J.getv(J.getv(game.j_G, "spit"), "sliceT"), 0.0)):
		J.setv(J.getv(game.j_G, "chef"), "mode", "idle")
	if (J.eq(J.getv(J.getv(game.j_G, "chef"), "mode"), "happy") and J.le(J.getv(J.getv(game.j_G, "uncle"), "flashT"), 0.0)):
		J.setv(J.getv(game.j_G, "chef"), "mode", "idle")
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "boards"), "length")):
		v_bw = J.getv(J.getv(game.j_G, "boards"), v_i)
		if J.truth(v_bw):
			if J.gt(J.getv(v_bw, "pop"), 0.0):
				J.setv(v_bw, "pop", (J.getv(v_bw, "pop") - (v_dt * 3.0)))
			if J.gt(J.getv(v_bw, "chop"), 0.0):
				J.setv(v_bw, "chop", max(0.0, (J.getv(v_bw, "chop") - (v_dt * 5.0))))
			if J.gt(J.getv(v_bw, "paperT"), 0.0):
				J.setv(v_bw, "paperT", (J.getv(v_bw, "paperT") - (v_dt * 2.0)))
		v_i = J.add(v_i, 1.0)
	if J.truth(J.getv(game.j_G, "flyP")):
		J.setv(J.getv(game.j_G, "flyP"), "t", J.add(J.getv(J.getv(game.j_G, "flyP"), "t"), (float(v_dt) / float(0.38))))
		if J.ge(J.getv(J.getv(game.j_G, "flyP"), "t"), 1.0):
			J.setv(J.getv(game.j_G, "cut"), "potato", true)
			J.setv(J.getv(game.j_G, "cut"), "prog", 0.0)
			J.setv(game.j_G, "flyP", null)
			J.method(game.j_SFX, "drop", [])
	if (not J.truth(v_dragged)):
		game.gameplay_input.f_handleInput()
	return null

# main.js:22
func f_invalidateLayers() -> Variant:
	game.j_BG = null
	game.j_CLAYER = null
	game.j_WINOVER = null
	if not J.eq(J.kind(game.j_SHOP), "undefined"):
		J.setv(game.j_SHOP, "bake", null)
	return null

# main.js:49
func f_frame(p_now: Variant = null) -> Variant:
	var v_dt: Variant = null
	var v_e: Variant = null
	var v_mode: Variant = null
	var v_sisUstunde: Variant = null
	var v_held: Variant = null
	var v_now: Variant = p_now
	v_dt = (float((v_now - game.j__last)) / float(1000.0))
	game.j__last = v_now
	if (not J.gt(v_dt, 0.0)):
		v_dt = 0.0
	if J.gt(v_dt, 0.06):
		v_dt = 0.06
	J.setv(game.j_G, "t", J.add(J.getv(game.j_G, "t"), v_dt))
	game.j__frames = J.add(game.j__frames, 1.0)
	game.j__fpsT = J.add(game.j__fpsT, v_dt)
	if J.gt(game.j__fpsT, 0.5):
		game.j__fps = floor((float(game.j__frames) / float(game.j__fpsT)) + 0.5)
		game.j__frames = 0.0
		game.j__fpsT = 0.0
	if J.truth(game.effects.f_keyp("KeyM")):
		game.j_MUTED = (not J.truth(game.j_MUTED))
	if ((J.truth(J.getv(game.j_window, "__DEV_BUILD")) and J.truth(game.effects.f_keyp("KeyT"))) and ((J.eq(J.getv(game.j_G, "scene"), "play") or J.eq(J.getv(game.j_G, "scene"), "shop")) or J.eq(J.getv(game.j_G, "scene"), "pause"))):
		J.setv(game.j_G, "test", (not J.truth(J.getv(game.j_G, "test"))))
		J.method(game.j_SFX, "ui", [])
	if J.truth(game.effects.f_keyp("Escape")):
		if J.eq(J.getv(game.j_G, "scene"), "play"):
			J.setv(game.j_G, "scene", "pause")
		else:
			if J.eq(J.getv(game.j_G, "scene"), "pause"):
				J.setv(game.j_G, "scene", "play")
	if J.truth(game.j_AC):
		game.f_musInit()
		game.f_musSet(("play" if J.eq(J.getv(game.j_G, "scene"), "play") else "menu"))
		game.f_ambSet(((J.eq(J.getv(game.j_G, "scene"), "play") if J.eq(J.getv(game.j_G, "scene"), "play") else J.eq(J.getv(game.j_G, "scene"), "shop")) if (J.eq(J.getv(game.j_G, "scene"), "play") or J.eq(J.getv(game.j_G, "scene"), "shop")) else J.eq(J.getv(game.j_G, "scene"), "title")))
		if (J.eq(J.kind(J.ref(game.f_sndLoop, 3)), "function") and not J.eq(J.getv(game.j_G, "scene"), "play")):
			game.f_sndLoop("fry", false)
		game.f_ambRain((game.weather_system.f_isRain() if (J.eq(J.getv(game.j_G, "scene"), "play") and J.eq(J.kind(J.ref(game.weather_system.f_isRain, 0)), "function")) else (J.eq(J.kind(J.ref(game.weather_system.f_isRain, 0)), "function") if J.eq(J.getv(game.j_G, "scene"), "play") else J.eq(J.getv(game.j_G, "scene"), "play"))))
	game.effects.f_camUpdate(v_dt)
	if J.eq(J.kind(J.ref(game.traffic_system.f_updateTraffic, 1)), "function"):
		game.traffic_system.f_updateTraffic(v_dt)
		game.traffic_system.f_updateCrossers(v_dt)
	game.effects.f_psUpdate(v_dt)
	game.effects.f_ftUpdate(v_dt)
	if not J.eq(J.getv(game.j_G, "scene"), "play"):
		J.setv(game.j_G, "sceneT", J.add(J.getv(game.j_G, "sceneT"), v_dt))
	J.method(game.j_ctx, "save", [])
	if J.truth(J.getv(game.j_VIEW, "top")):
		J.method(game.j_ctx, "translate", [0.0, (-J.n(J.getv(game.j_VIEW, "top")))])
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "translate", [J.getv(game.j_CAM, "sx"), J.getv(game.j_CAM, "sy")])
	match J.getv(game.j_G, "scene"):
		"title":
			game.title_draw.f_drawTitle(J.getv(game.j_G, "t"))
		"intro":
			game.title_draw.f_drawIntro(J.getv(game.j_G, "t"))
		"play":
			game.game_loop.f_updatePlay(v_dt)
			game.f_drawPlay(J.getv(game.j_G, "t"))
		"dayend":
			game.day_end_draw.f_drawDayEnd(J.getv(game.j_G, "t"))
		"shop":
			game.shop_draw.f_drawShop(J.getv(game.j_G, "t"))
		"night":
			game.night_draw.f_drawNight(J.getv(game.j_G, "t"))
		"prologue":
			game.story_draw.f_drawPrologue(J.getv(game.j_G, "t"))
		"pause":
			game.f_drawPause(J.getv(game.j_G, "t"))
	if J.eq(J.kind(J.ref(game.achievement_system.f_basarimTara, 1)), "function"):
		J.setv(game.j_G, "bsT", J.add((J.getv(game.j_G, "bsT") if J.truth(J.getv(game.j_G, "bsT")) else 0.0), v_dt))
		if J.gt(J.getv(game.j_G, "bsT"), 0.5):
			J.setv(game.j_G, "bsT", 0.0)
			if ((J.eq(J.getv(game.j_G, "scene"), "play") or J.eq(J.getv(game.j_G, "scene"), "shop")) or J.eq(J.getv(game.j_G, "scene"), "dayend")):
				game.achievement_system.f_basarimTara()
	if (J.eq(J.getv(game.j_G, "scene"), "title") and J.eq(J.kind(J.ref(game.title_draw.f_drawTitleBasarim, 1)), "function")):
		game.title_draw.f_drawTitleBasarim(J.getv(game.j_G, "t"))
	if J.eq(J.kind(J.ref(game.achievement_draw.f_drawBasarimToast, 2)), "function"):
		game.achievement_draw.f_drawBasarimToast(J.getv(game.j_G, "t"), v_dt)
	if (J.truth(J.getv(game.j_G, "test")) and ((J.eq(J.getv(game.j_G, "scene"), "play") or J.eq(J.getv(game.j_G, "scene"), "shop")) or J.eq(J.getv(game.j_G, "scene"), "pause"))):
		game.debug_draw.f_drawTestPanel(J.getv(game.j_G, "t"))
	if J.eq(J.kind(J.ref(game.interface_draw.f_drawDevDugme, 1)), "function"):
		game.interface_draw.f_drawDevDugme(J.getv(game.j_G, "t"))
	J.method(game.j_ctx, "restore", [])
	if J.gt(J.getv(game.j_CAM, "flash"), 0.01):
		J.setv(game.j_ctx, "globalAlpha", min(0.85, J.getv(game.j_CAM, "flash")))
		game.f_fr(0.0, 0.0, game.j_W, game.j_H, J.getv(game.j_CAM, "flashCol"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_mode = "point"
	v_sisUstunde = (game.f_hitST("spit") if J.eq(J.getv(game.j_G, "scene"), "play") else J.eq(J.getv(game.j_G, "scene"), "play"))
	if ((J.eq(J.getv(game.j_G, "scene"), "play") and (not J.truth(v_sisUstunde))) and J.truth(game.tutorial_draw.f_hoverStation())):
		v_mode = "grab"
	v_held = (J.getv(game.j_G, "hand") if (J.eq(J.getv(game.j_G, "scene"), "play") or J.eq(J.getv(game.j_G, "scene"), "pause")) else null)
	if ((not J.truth(game.j_TOUCH)) and (not J.truth(v_sisUstunde))):
		game.f_drawCursor(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), ("grab" if J.truth(v_held) else v_mode), v_held, J.getv(game.j_G, "t"))
	J.method(game.j_ctx, "restore", [])
	game.effects.f_inEnd()
	return null

