# The cross-platform entry point. Gameplay/art remain in the inherited scripts.
extends "res://scripts/order_flow.gd"
const DeviceInput = preload("res://scripts/device_input.gd")
const StationActions = preload("res://scripts/station_actions.gd")
signal settings_requested
var controls: RefCounted
var stations: RefCounted
var external_input := false
var overlay_open := false
var cut_marks: Array[Dictionary] = []
var cut_hold_active := false
var cut_hold_elapsed := 0.0
var mouse_cut_point := Vector2.INF
var mouse_cut_contact := false
var mouse_cut_pending := 0.0
var mouse_cut_travel := 0.0
var mouse_in_game := true

func reset_mouse_cut() -> void:
	mouse_cut_point = Vector2.INF
	mouse_cut_contact = false
	mouse_cut_pending = 0.0
	mouse_cut_travel = 0.0

func mouse_cut_rect() -> Rect2:
	var s: Dictionary = j_ST.spit
	return Rect2(s.x,s.y,s.w,s.h)

func mouse_cut_contains(point: Vector2) -> bool:
	var area := mouse_cut_rect()
	if area.has_point(point): return true
	# Keep an established stroke attached at the edge, but never steal a
	# neighboring station. A fresh entry still starts on the spit itself.
	if not mouse_cut_contact or not area.grow_individual(6,9,8,10).has_point(point): return false
	for key in ["uncle","phone","bread","meat"]:
		var s: Dictionary = j_ST[key]
		if Rect2(s.x,s.y,s.w,s.h).has_point(point): return false
	return true

func record_mouse_cut(point: Vector2) -> void:
	mouse_in_game = true
	if not can_manual_cut(): reset_mouse_cut(); return
	var inside := mouse_cut_contains(point)
	if inside and mouse_cut_contact and mouse_cut_point.is_finite():
		# Accumulate the complete event path: an out-and-back stroke between
		# two rendered frames must not cancel itself out.
		mouse_cut_pending += mouse_cut_point.distance_to(point)
	elif not inside:
		mouse_cut_pending = 0.0
		mouse_cut_travel = 0.0
	mouse_cut_contact = inside
	mouse_cut_point = point

func mouse_cut_distance() -> float:
	return maxf(8.0,float(J.method(j_TUN,"shaveDist",[j_G]))*0.12)

func f_hitST(key: Variant = null) -> Variant:
	if key == "spit" and controls != null and controls.mode == "mouse":
		return mouse_in_game and can_manual_cut() and mouse_cut_contains(Vector2(j_IN.x,j_IN.y))
	return super.f_hitST(key)

func can_manual_cut() -> bool:
	if j_G == null or j_G.scene != "play" or suspended or overlay_open: return false
	if J.truth(j_G.get("hand")) or J.truth(j_G.get("drag")) or j_G.crate.open or J.truth(debug_draw.f_testPanelOpen()): return false
	for panel in [j_CUSTOM, j_PAYP, j_BRP, j_SESP, j_STATS, j_BSP]:
		if panel.get("open", false): return false
	return j_G.shave is Dictionary

func f_startDay() -> Variant:
	reset_mouse_cut()
	if stations != null: stations.reset()
	cut_marks.clear()
	cut_hold_active = false
	cut_hold_elapsed = 0
	if controls != null: controls.release_all()
	var result: Variant = super.f_startDay()
	if stations != null: stations.refresh()
	return result

func f_activeWrap(predicate: Variant = null) -> Variant:
	if stations != null and stations.recipe_board >= 0:
		return j_G.boards[stations.recipe_board]
	return super.f_activeWrap(predicate)

func f_updateCut(dt: Variant = null) -> Variant:
	if stations == null or stations.holding.get("id", "") != "chop": return super.f_updateCut(dt)
	var pointer_before := Vector2(j_IN.x,j_IN.y)
	var down_before: bool = j_IN.down
	pointer(Vector2(j_ST.cut.x+20,j_ST.cut.y+20))
	j_IN.down = true
	var result: Variant = super.f_updateCut(dt)
	j_IN.down = down_before
	pointer(pointer_before)
	return result

func f_drawPause(time: Variant = null) -> Variant:
	f_drawPlay(time)
	if j_BSP.open: achievement_draw.f_drawBasarimPanel(time); return null
	if j_STATS.open: achievement_draw.f_drawStatsPanel(time); return null
	if j_SESP.open: settings_draw.f_drawSesPanel(time); return null
	j_ctx.globalAlpha = 0.62
	f_fr(0,0,j_W,j_H,"#140a06")
	j_ctx.globalAlpha = 1.0
	interface_draw.f_panel(170,46,140,166,"MOLA")
	if f_button(190,66,100,20,"DEVAM ET","#3f8a4a",true): j_G.scene = "play"
	if f_button(190,90,100,20,"SES AYARLARI","#3f6fbd"): j_SESP.open = true
	if f_button(190,114,100,20,"KONTROLLER" if j_LANG == "tr" else "CONTROLS","#86633e"):
		controls.help_requested.emit()
	if f_button(190,138,100,20,"EKRAN" if j_LANG == "tr" else "DISPLAY","#7a5aa0"):
		settings_requested.emit()
	if f_button(190,162,48,20,"REKOR","#3f6fbd"): j_STATS.open = true
	if f_button(242,162,48,20,"BAŞARIM","#b0862a"): j_BSP.open = true
	if f_button(190,186,100,20,"ANA MENÜ","#8a4a4a"): j_G.scene = "title"
	return null

func f_drawHoverHint(time: Variant = null) -> Variant:
	if controls != null and controls.station_mode():
		# Reuse original transient messages, but suppress the duplicate mouse tooltip.
		var touch_before: bool = j_TOUCH
		var down_before: bool = j_IN.down
		j_TOUCH = true
		j_IN.down = false
		var result: Variant = super.f_drawHoverHint(time)
		j_TOUCH = touch_before
		j_IN.down = down_before
		return result
	return super.f_drawHoverHint(time)

func f_drawCursor(x: Variant = null, y: Variant = null, mode: Variant = null, held_item: Variant = null, time: Variant = null) -> Variant:
	if controls != null and controls.mode == "mouse" and not mouse_in_game: return null
	if controls != null and controls.station_mode() and not J.truth(held_item): return null
	return super.f_drawCursor(x,y,mode,held_item,time)

func f_drawPlay(time: Variant = null) -> Variant:
	var result: Variant = super.f_drawPlay(time)
	# Draw after the receipt, counter, flying food and other world objects.
	draw_cut_blade(time)
	if controls != null and controls.mode == "touch" and J.truth(j_G.hand):
		# Keep picked-up food visible above the finger until it is served/returned.
		food_draw.f_drawItem(j_G.hand,clampf(float(j_IN.x),20,460),clampf(float(j_IN.y)-20,45,237),time)
	if stations == null or not stations.available() or controls.mode == "mouse" or controls.quick_cut_active: return result
	if controls.mode != "touch" and not controls.station_mode(): return result
	var target: Dictionary = stations.target()
	if target.is_empty() or target.id == "spit": return result
	var r: Rect2 = target.rect.grow(1)
	j_ctx.save()
	# Small pixel brackets leave the object, food and animations unobstructed.
	for corner in [r.position,Vector2(r.end.x,r.position.y),Vector2(r.position.x,r.end.y),r.end]:
		var dx := 1.0 if corner.x == r.position.x else -1.0
		var dy := 1.0 if corner.y == r.position.y else -1.0
		f_fr(minf(corner.x,corner.x+dx*5),corner.y,6,1,"#ffe6a3")
		f_fr(corner.x,minf(corner.y,corner.y+dy*5),1,6,"#ffe6a3")
	if target.group == "ingredient" and int(stations.tun("boards")) > 1:
		var bx: float = wrap_system.f_boardCX(j_G.act)
		text_draw.f_txt(str(int(j_G.act)+1),bx,j_ST.board.y+2,"#ffe6a3",{"align":"c","outline":true})
	var a: Dictionary = stations.primary()
	if not a.is_empty() and controls.mode != "touch" and stations.hint_time > 0:
		var label: String = stations.prompt()
		var width: float = f_textW(label)+21
		var x := clampf(r.get_center().x-width/2,2,478-width)
		var y := maxf(32,r.position.y-15)
		var color := "#ffe6a3" if a.enabled else "#ab9b88"
		f_rrect(x,y,width,12,2,"#241a12")
		f_ring(x+7,y+6,4,color)
		var glyph := "A" if controls.mode == "controller" else "E"
		# A cross glyph is used for PlayStation pads; keyboard uses a return arrow.
		var pad_name := Input.get_joy_name(controls.device).to_lower() if controls.device >= 0 else ""
		if "sony" in pad_name or "playstation" in pad_name or "dualsense" in pad_name or "dualshock" in pad_name: glyph = "X"
		if controls.mode == "keyboard": glyph = ">"
		text_draw.f_txt(glyph,x+7,y+3,color,{"align":"c"})
		text_draw.f_txt(label,x+15,y+3,color)
		if a.hold: f_fr(x+15,y+10,width-18,1,color)
	if not stations.holding.is_empty() and stations.holding.id in ["roll","paper","chop"]:
		var progress: float = j_G.cut.prog if stations.holding.id == "chop" else stations.holding.time / (0.28 if stations.holding.id == "roll" else float(stations.tun("paperTime")))
		counter_draw.f_bar(r.get_center().x-18,r.end.y-5,36,4,clampf(progress,0,1),"#ffe6a3")
	j_ctx.restore()
	return result

func f_updateShave(dt: Variant = null) -> Variant:
	for mark in cut_marks: mark.age += float(dt)
	cut_marks = cut_marks.filter(func(mark: Dictionary) -> bool: return mark.age < 0.38)
	if controls == null: return super.f_updateShave(dt)
	var allowed := can_manual_cut()
	var over: bool = f_hitST("spit")
	var assisted: bool = allowed and (controls.quick_cut_active or (controls.mode in ["touch", "controller", "keyboard"] and j_IN.down and over))
	var was_holding := cut_hold_active
	cut_hold_active = assisted and j_G.meat < J.method(j_TUN, "meatCap", [])
	cut_hold_elapsed = cut_hold_elapsed + float(dt) if cut_hold_active else 0.0
	if assisted:
		# The existing knife cooldown remains the only rate limit. No extra
		# slices or inventory grants occur in the input handler.
		j_G.shave.travel = J.method(j_TUN, "shaveDist", [j_G])
		j_G.shave.lastY = j_IN.y
		j_G.shave.act = 0.3
	elif controls.mode == "mouse":
		var moved := mouse_cut_pending > 0.01
		var need := mouse_cut_distance()
		mouse_cut_travel = minf(need,mouse_cut_travel+mouse_cut_pending)
		mouse_cut_pending = 0.0
		# Suppress legacy vertical-only sampling and queued cuts after stopping.
		j_G.shave.lastY = j_IN.y
		j_G.shave.travel = 0.0
		if allowed and over:
			if j_G.meat >= J.method(j_TUN,"meatCap",[]): mouse_cut_travel = 0.0
			elif moved:
				j_G.shave.act = 0.25
				if mouse_cut_travel >= need: j_G.shave.travel = J.method(j_TUN,"shaveDist",[j_G])
		else: reset_mouse_cut()
	elif was_holding:
		j_G.shave.travel = 0.0
		j_G.shave.lastY = j_IN.y
	var block_hover: bool = not allowed or (controls.mode == "touch" and not j_IN.down)
	var original_x: float = j_IN.x
	if block_hover:
		j_IN.x = -100.0
		j_G.shave.lastY = -1.0
		j_G.shave.travel = 0.0
	var result: Variant = super.f_updateShave(dt)
	j_IN.x = original_x
	return result

func f_doSlice() -> Variant:
	var before: float = j_G.meat
	var flying_before: int = j_G.flyMeat.size()
	var result: Variant = super.f_doSlice()
	if j_G.meat <= before: return result
	mouse_cut_travel = 0.0
	var cut_y := clampf(float(j_IN.y), float(j_LAY.spit.top) + 14, float(j_LAY.spit.bot) - 20)
	cut_marks.append({"age": 0.0, "y": cut_y, "amount": int(j_G.meat - before)})
	if cut_marks.size() > 3: cut_marks.pop_front()
	# Keep every strip readable; the base action owns stock and the single cut sound.
	for i in range(flying_before, j_G.flyMeat.size()):
		j_G.flyMeat[i].sz = maxf(0.95, float(j_G.flyMeat[i].sz) + 0.3)
	return result

func hold_blade_visible() -> bool:
	return controls != null and controls.mode != "mouse" and f_hitST("spit") and can_manual_cut() and (controls.mode != "touch" or j_IN.down)

func f_drawSpitCutKnife(x: Variant = null, y: Variant = null, level: Variant = null) -> Variant:
	# The input blade replaces the old animation, so only one knife is visible.
	# Both mouse and assisted input draw their persistent blade last in f_drawPlay.
	if hold_blade_visible() or ((controls == null or controls.mode == "mouse") and f_hitST("spit")): return null
	return super.f_drawSpitCutKnife(x, y, level)

func f_drawShaveHint(time: Variant = null) -> Variant:
	# Only world effects here; the blade is drawn last by f_drawPlay.
	draw_cut_feedback()
	return null

func draw_cut_blade(time: Variant = null) -> void:
	var mouse_blade: bool = controls != null and controls.mode == "mouse" and f_hitST("spit")
	if mouse_blade:
		j_ctx.save()
		j_ctx.globalAlpha = 1.0
		f_drawKesimBicagi(float(j_IN.x)-5,clampf(float(j_IN.y),j_LAY.spit.top+8,j_LAY.spit.bot-12),-1.0,equipment_system.f_UV(j_G,"knife"))
		var progress := mouse_cut_travel / mouse_cut_distance()
		counter_draw.f_bar(j_LAY.spit.cx-19,j_LAY.spit.bot+8,38,4,progress,j_P.au1)
		if j_G.meat >= J.method(j_TUN,"meatCap",[]):
			text_draw.f_txt("TEPSİ DOLU" if j_LANG == "tr" else "TRAY FULL",j_LAY.spit.cx,j_ST.spit.y-13,j_P.warn,{"align":"c","outline":true})
		j_ctx.restore()
	elif hold_blade_visible():
		var cx: float = j_LAY.spit.cx
		var y := clampf(float(j_IN.y), float(j_LAY.spit.top) + 12, float(j_LAY.spit.bot) - 18)
		if cut_hold_active:
			var period: float = J.method(j_TUN, "shaveCd", [j_G])
			y = clampf(y + sin(cut_hold_elapsed / period * TAU) * 18, float(j_LAY.spit.top) + 12, float(j_LAY.spit.bot) - 18)
		# Put a larger blade to the left of the finger, where it stays visible.
		j_ctx.save()
		j_ctx.translate(cx - 8, y)
		j_ctx.scale(1.35, 1.35)
		f_drawKesimBicagi(0.0, 0.0, -1.0, equipment_system.f_UV(j_G, "knife"))
		j_ctx.restore()
		var progress: float = 1.0 - clampf(float(j_G.shave.cd) / float(J.method(j_TUN, "shaveCd", [j_G])), 0, 1)
		counter_draw.f_bar(cx - 19, float(j_LAY.spit.bot) + 8, 38.0, 5.0, progress, j_P.au1)
		if j_G.meat >= J.method(j_TUN, "meatCap", []):
			text_draw.f_txt("TEPSİ DOLU", cx, float(j_LAY.spit.top) - 12, j_P.warn, {"align":"c", "outline":true})
		elif not cut_hold_active:
			var prompts := {"tr":"BASILI TUT", "en":"HOLD TO CUT", "de":"GEDRÜCKT HALTEN", "fr":"MAINTENIR", "es":"MANTÉN PULSADO", "pt":"MANTÉM PREMIDO"}
			text_draw.f_txt(prompts.get(j_LANG, prompts.en), cx, float(j_LAY.spit.top) - 12, j_P.au0, {"align":"c", "outline":true})

func draw_cut_feedback() -> void:
	if cut_marks.is_empty(): return
	j_ctx.save()
	var cx: float = j_LAY.spit.cx
	for mark in cut_marks:
		var fade := 1.0 - float(mark.age) / 0.38
		var y: float = mark.y
		j_ctx.globalAlpha = fade * 0.8
		# A short warm slash with a bright edge, bounded to the spit area.
		for i in 22:
			var u := float(i) / 21.0
			var px := cx - 26 + i * 2
			var py := y - 9 + u * 15 - sin(u * PI) * 4
			f_fr(px, py, 2.0, 4.0, "#b86f28")
			f_fr(px, py, 2.0, 2.0, "#fff2c9")
		# A few deterministic crumbs outside the finger's contact patch.
		for i in 3:
			var px := cx - 25 - float(mark.age) * (20 + i * 15)
			var py := y - i * 5 - float(mark.age) * 30 + float(mark.age) * float(mark.age) * 230
			f_fr(px, py, 3.0, 2.0, "#f1bc76" if i % 2 == 0 else "#b67538")
	var newest: Dictionary = cut_marks.back()
	var badge_y := float(newest.y) - 26 - float(newest.age) * 18
	j_ctx.globalAlpha = 1.0 - float(newest.age) / 0.38
	f_rrect(cx - 39, badge_y, 20.0, 12.0, 2.0, "#392416")
	text_draw.f_txt("+" + str(newest.amount), cx - 29, badge_y + 2, "#ffe6a3", {"align":"c"})
	j_ctx.restore()

func _ready() -> void:
	super._ready()
	stations = StationActions.new(self)
	controls = DeviceInput.new(self)
	# Preserve each mouse segment; coalescing an out-and-back motion into one
	# frame otherwise discards the distance used by the slicing gesture.
	Input.use_accumulated_input = false
	Input.joy_connection_changed.connect(_joy_connection_changed)
	if external_input: set_process_input(false)

func _input(event: InputEvent) -> void:
	if controls != null and not suspended: controls.handle(event)

func advance(delta: float) -> void:
	if stations != null:
		stations.refresh()
		stations.tick(delta)
	if controls != null:
		if not overlay_open: controls.tick(delta)
		controls.begin_targets()
	super.advance(delta)
	if stations != null and stations.available() and controls.mode == "mouse":
		var selected_target: Dictionary = stations.target()
		if selected_target.get("group", "") == "board" and selected_target.index != int(j_G.act): stations.select("board:"+str(int(j_G.act)),false)
	if controls != null: controls.end_targets()

func f_button(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, label: Variant = null, col: Variant = null, hot: Variant = null) -> Variant:
	if controls != null: controls.add_target(Rect2(x, y, w, h), str(label))
	return super.f_button(x, y, w, h, label, col, hot)

func f_tinyBtn(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, label: Variant = null, col: Variant = null) -> Variant:
	if controls != null: controls.add_target(Rect2(x, y, w, h), str(label))
	return super.f_tinyBtn(x, y, w, h, label, col)

func f_volSlider(x: Variant = null, y: Variant = null, w: Variant = null, value: Variant = null, id: Variant = null, col: Variant = null, t: Variant = null) -> Variant:
	if controls != null: controls.add_target(Rect2(x, y - 5, w, 18), str(id))
	return super.f_volSlider(x, y, w, value, id, col, t)

func f_langButtons(x: Variant = null, y: Variant = null) -> Variant:
	if controls != null:
		controls.add_target(Rect2(x, y, 15, 34), "language previous")
		controls.add_target(Rect2(x + 157, y, 15, 34), "language next")
	return super.f_langButtons(x, y)

func _joy_connection_changed(id: int, connected: bool) -> void:
	if controls != null and not connected: controls.disconnected(id)

func _notification(what: int) -> void:
	if game == null or game.j_G == null or test_mode: return
	match what:
		NOTIFICATION_APPLICATION_PAUSED: f_appPause()
		NOTIFICATION_APPLICATION_RESUMED: f_appResume()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if controls != null and not external_input: controls.back()
		NOTIFICATION_WM_CLOSE_REQUEST: f_appPause()

func f_appPause() -> Variant:
	if controls != null: controls.release_all()
	# Preserve the original progression save schema; a suspended in-memory day
	# stays paused. A terminated app reloads the last progression checkpoint.
	if j_G != null and j_G.scene in ["play", "pause", "shop", "dayend", "night"]: save_system.f_saveAll()
	return super.f_appPause()
