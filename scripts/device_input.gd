# One logical pointer for mouse, one captured finger, keyboard and controller.
# Keep the original game's press/hold/drag/release rules on every device.
extends RefCounted

signal mode_changed(mode: String)
signal help_requested

const DEADZONE := 0.22
var game: Node
var mode := "mouse"
var device := -1
var touch_id := -1
var touch_select_only := false
var mouse_station := false
var pointer_position := Vector2.ZERO
var axes := Vector2.ZERO
var fine_axis := 0.0
var held: Dictionary = {}
var press_sources: Dictionary = {}
var latched := false
var targets: Array[Dictionary] = []
var next_targets: Array[Dictionary] = []
var target_index := -1
var context := ""
var repeat_direction := Vector2.ZERO
var repeat_time := 0.0
var pointer_events: Array[Dictionary] = []
var quick_cut_down := false
var quick_cut_active := false
var cut_needs_release := false
var cut_return_position := Vector2.ZERO

func _init(owner_game: Node) -> void:
	game = owner_game
	if OS.has_feature("mobile") or "--touch-preview" in OS.get_cmdline_user_args():
		set_mode("touch")
	game.pointer(Vector2(240, 142))

func set_mode(value: String) -> void:
	if value != mode:
		cancel_gesture()
		cut_needs_release = false # A different input device starts a new gesture.
		axes = Vector2.ZERO
		fine_axis = 0.0
		held.clear()
		repeat_direction = Vector2.ZERO
		mode = value
		mode_changed.emit(mode)
	game.j_TOUCH = value == "touch"
	if game.j_TUT is Array and not game.j_TUT.is_empty():
		if value in ["touch", "controller", "keyboard"]:
			var hints := {
				"tr": "Dönerin üstünde basılı tut; et kesilsin.",
				"en": "Hold on the spit to slice meat.",
				"de": "Am Spieß gedrückt halten, um Fleisch zu schneiden.",
				"fr": "Maintiens sur la broche pour couper la viande.",
				"es": "Mantén pulsado sobre el asador para cortar carne.",
				"pt": "Mantém premido no espeto para cortar carne."}
			game.j_TUT[0].s = hints.get(game.j_LANG, hints.en)
			if value == "controller": game.j_TUT[0].s = "R2 / RT: " + game.j_TUT[0].s
			elif value == "keyboard": game.j_TUT[0].s = "R: " + game.j_TUT[0].s
		else: game.j_TUT[0].s = "Fareyi dönerin üstünde gezdir; tıklamadan kes." if game.j_LANG == "tr" else "Move the mouse over the spit to slice; no click needed."
		var direct: bool = game.stations != null and game.stations.enabled and value != "mouse"
		game.j_TUT[10].s = ("Dürümü basılı tutarak sar" if game.j_LANG == "tr" else "Hold the wrap to roll") if direct else "Dürümü tutup YUKARI sürükleyerek sar"
		game.j_TUT[11].s = ("Dürümü tekrar basılı tut; kağıtlansın" if game.j_LANG == "tr" else "Hold again to wrap in paper") if direct else "Kağıdı tut, dürümün üstüne bırak"

func queue_pointer(position: Vector2, down: bool, source: String) -> void:
	pointer_events.append({"position": position, "down": down, "source": source})

func set_press(source: String, down: bool) -> void:
	var before: bool = not press_sources.is_empty()
	if down: press_sources[source] = true
	else: press_sources.erase(source)
	var after: bool = not press_sources.is_empty()
	if before != after: game.pointer_button(after)

func route_pointer(position: Vector2, down: bool, source: String) -> void:
	pointer_position = position
	# A direct tray action must not overtake a queued bread click or drag release.
	# Resolve the station only when all preceding input has reached gameplay.
	if not pointer_events.is_empty():
		pointer_events.append({"position":position,"down":down,"source":source,"direct":true})
	else: dispatch_pointer(position,down,source)

func dispatch_pointer(position: Vector2, down: bool, source: String, queued := false) -> void:
	if source == "touch":
		if down and game.stations != null and game.stations.select_at(position):
			touch_select_only = true
			game.stations.accept(true,"world-touch")
			return
		if not down and touch_select_only:
			game.stations.release("world-touch")
			touch_select_only = false
			return
	else:
		if down and game.stations != null: game.stations.select_at(position,false)
		if not down and mouse_station:
			game.stations.release("world-mouse")
			mouse_station = false
			return
		if down and game.stations != null and game.stations.available() and not game.j_G.crate.open:
			var target: Dictionary = game.stations.target()
			var cat: Variant = game.j_G.get("kedi")
			var cat_drag: bool = target.get("id") == "meat" and cat is Dictionary and cat.get("faz") in ["bekle", "gelis"]
			var free: bool = not game.J.truth(game.j_G.hand) and not game.J.truth(game.j_G.drag)
			var preparation: bool = target.get("id") in ["bread","pide","meat","pickle","yogurt","friesT"]
			if target.get("group") == "board" and game.j_G.boards[target.index] == null: preparation = true
			if target.get("rect", Rect2()).has_point(position) and not cat_drag and ((preparation and free) or target.get("group") == "customer"):
				mouse_station = true
				game.stations.accept(true,"world-mouse")
				return
	if queued:
		game.pointer(position)
		set_press(source,down)
	else: queue_pointer(position,down,source)

func handle(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			set_mode("touch")
			touch_id = event.index
			route_pointer(event.position,true,"touch")
		elif event.index == touch_id and not event.pressed:
			if event.canceled: cancel_gesture()
			else: route_pointer(event.position,false,"touch")
			touch_id = -1
		return
	if event is InputEventScreenDrag:
		if event.index == touch_id:
			pointer_position = event.position
			if touch_select_only:
				var rect: Rect2 = game.stations.target().get("rect",Rect2())
				if not rect.grow(8).has_point(event.position): game.stations.release("world-touch")
			else: game.pointer(event.position)
		return
	if event is InputEventMouseMotion:
		if event.device == InputEvent.DEVICE_ID_EMULATION or touch_id != -1: return
		# A native mouse-enter/reposition event can have an absolute position
		# without a relative delta. It must still restore the mouse's knife.
		set_mode("mouse")
		pointer_position = event.position
		game.record_mouse_cut(event.position)
		game.pointer(event.position)
		if mouse_station:
			var r: Rect2 = game.stations.target().get("rect", Rect2())
			if not r.grow(8).has_point(event.position): game.stations.release("world-mouse")
		return
	if event is InputEventMouseButton:
		if event.device == InputEvent.DEVICE_ID_EMULATION or touch_id != -1: return
		if event.button_index == MOUSE_BUTTON_LEFT:
			set_mode("mouse")
			game.mouse_in_game = true
			route_pointer(event.position,event.pressed,"mouse")
		return
	if event is InputEventJoypadMotion:
		if absf(event.axis_value) > DEADZONE:
			if device != -1 and event.device != device: return
			set_mode("controller")
			device = event.device
		if event.device != device: return
		if event.is_action("game_cut"):
			set_quick_cut(event.is_action_pressed("game_cut"))
			return
		match event.axis:
			JOY_AXIS_LEFT_X: axes.x = event.axis_value
			JOY_AXIS_LEFT_Y: axes.y = event.axis_value
			JOY_AXIS_TRIGGER_LEFT:
				if (fine_axis > 0.4) != (event.axis_value > 0.4): cancel_gesture()
				fine_axis = event.axis_value
		return
	if event is InputEventJoypadButton:
		if device != -1 and event.device != device: return
		if event.pressed:
			set_mode("controller")
			device = event.device
	elif event is InputEventKey:
		if event.echo: return
		if game.j_TEXTIN.active:
			if event.pressed: game.text_key(event)
			return
	else: return
	for action in ["game_cut", "game_accept", "game_cancel", "game_pause", "game_latch", "game_next", "game_previous", "game_left", "game_right", "game_up", "game_down", "game_fine", "game_help", "game_mute", "game_fullscreen"]:
		if not event.is_action(action): continue
		var down: bool = event.is_action_pressed(action)
		if action == "game_accept" and not down and press_sources.has("accept"):
			queue_pointer(Vector2(game.j_IN.x,game.j_IN.y),false,"accept")
			held[action] = false
			return
		if action == "game_accept" and not down and game.stations != null and game.stations.holding.get("source", "") == "accept":
			game.stations.release("accept")
			held[action] = false
			return
		if quick_cut_active and action not in ["game_cut", "game_cancel", "game_pause", "game_help", "game_mute"]: return
		if event is InputEventKey and down and action not in ["game_mute", "game_fullscreen", "game_pause", "game_cancel", "game_help"]:
			set_mode("keyboard")
		held[action] = down
		if action == "game_fine": cancel_gesture(); return
		if station_mode() and not quick_cut_active:
			match action:
				"game_accept": game.stations.accept(down); return
				"game_latch":
					if down: game.stations.secondary()
					return
				"game_next","game_previous":
					if down: game.stations.cycle(1 if action == "game_next" else -1)
					return
				"game_cancel":
					if down: back()
					return
		match action:
			"game_cut": set_quick_cut(down)
			"game_accept": queue_pointer(Vector2(game.j_IN.x, game.j_IN.y), down, "accept")
			"game_latch":
				if down:
					latched = not latched
					queue_pointer(Vector2(game.j_IN.x, game.j_IN.y), latched, "latch")
			"game_cancel":
				if down: back()
			"game_pause":
				if down: pause()
			"game_next":
				if down: cycle(1)
			"game_previous":
				if down: cycle(-1)
			"game_help":
				if down: help_requested.emit()
			"game_mute":
				if down: game.j_MUTED = not game.j_MUTED
			"game_fullscreen":
				if down and not OS.has_feature("mobile"): game.f_fsToggle()
		return

func station_mode() -> bool:
	return game.stations != null and game.stations.available() and mode in ["controller","keyboard"] and fine_axis <= 0.4 and not held.get("game_fine",false)

func tick(delta: float) -> void:
	if quick_cut_active:
		if not game.can_manual_cut(): cancel_gesture()
		else: return # Keep aim on the spit until the shortcut is released.
	# Deliver separate press/release edges on separate simulation frames. Rapid
	# taps must neither vanish nor accidentally release at the next tap's position.
	if not pointer_events.is_empty():
		var event: Dictionary = pointer_events.pop_front()
		if event.get("direct",false): dispatch_pointer(event.position,event.down,event.source,true)
		else:
			game.pointer(event.position)
			set_press(event.source, event.down)
	# Motion may arrive before a deferred press reaches the simulation.
	if mouse_station or touch_select_only:
		if not game.stations.target().get("rect",Rect2()).grow(8).has_point(pointer_position):
			game.stations.release("world-mouse" if mouse_station else "world-touch")
	var direction := Vector2(float(held.get("game_right", false)) - float(held.get("game_left", false)), float(held.get("game_down", false)) - float(held.get("game_up", false)))
	if station_mode():
		if not game.stations.holding.is_empty(): return
		if direction == Vector2.ZERO and mode == "controller" and axes.length() > 0.55:
			direction = Vector2(signf(axes.x),0) if absf(axes.x) > absf(axes.y) else Vector2(0,signf(axes.y))
		if direction != repeat_direction: repeat_direction = direction; repeat_time = 0
		if direction != Vector2.ZERO:
			repeat_time -= delta
			if repeat_time <= 0:
				game.stations.navigate(direction.normalized())
				repeat_time = 0.24
		return
	var velocity := Vector2.ZERO
	if mode == "controller":
		var magnitude := minf(axes.length(), 1.0)
		if magnitude > DEADZONE:
			velocity = axes.normalized() * (magnitude - DEADZONE) / (1.0 - DEADZONE)
		if direction != repeat_direction:
			repeat_direction = direction
			repeat_time = 0
		if direction != Vector2.ZERO:
			repeat_time -= delta
			if repeat_time <= 0:
				focus_direction(direction.normalized())
				repeat_time = 0.24
	elif mode == "keyboard":
		velocity = direction.normalized()
	if velocity != Vector2.ZERO:
		var speed := 48.0 if held.get("game_fine", false) or fine_axis > 0.4 else 180.0
		game.pointer(Vector2(game.j_IN.x, game.j_IN.y) + velocity * speed * delta)
		target_index = -1

func cancel_gesture() -> void:
	game.reset_mouse_cut()
	if game.stations != null: game.stations.cancel()
	mouse_station = false
	if quick_cut_down: cut_needs_release = true
	quick_cut_down = false
	finish_quick_cut()
	touch_id = -1
	touch_select_only = false
	latched = false
	pointer_events.clear()
	press_sources.clear()
	if game.j_IN == null: return
	game.j_IN.down = false
	game.j_IN.pressed = false
	game.j_IN.released = false
	game.j_IN.keys.clear()
	game.j_IN.kp.clear()
	if game.j_G != null:
		game.j_G.drag = null
		if game.j_G.shave is Dictionary:
			game.j_G.shave.lastY = -1.0
			game.j_G.shave.travel = 0.0

func set_quick_cut(down: bool) -> void:
	if not down: cut_needs_release = false
	if cut_needs_release or down == quick_cut_down: return
	quick_cut_down = down
	if not down:
		finish_quick_cut()
		return
	# Never interrupt serving, a held mouse/finger or an open panel.
	if not game.can_manual_cut() or not press_sources.is_empty() or not pointer_events.is_empty(): return
	cut_return_position = Vector2(game.j_IN.x, game.j_IN.y)
	quick_cut_active = true
	game.j_G.shave.lastY = -1.0
	game.j_G.shave.travel = 0.0
	game.pointer(Vector2(game.j_LAY.spit.cx, game.j_LAY.spit.top + 42))

func finish_quick_cut() -> void:
	if not quick_cut_active: return
	quick_cut_active = false
	game.pointer(cut_return_position)
	if game.j_G.shave is Dictionary:
		game.j_G.shave.lastY = -1.0
		game.j_G.shave.travel = 0.0

func release_all() -> void:
	cancel_gesture()
	held.clear()
	axes = Vector2.ZERO
	fine_axis = 0.0
	repeat_direction = Vector2.ZERO
	# No stale hover cutting when returning from another app.
	game.pointer(Vector2(240, 140))

func disconnected(id: int) -> void:
	if id != device: return
	release_all()
	cut_needs_release = false
	device = -1
	if game.j_G.scene == "play": game.j_G.scene = "pause"

func back() -> void:
	if quick_cut_active or game.j_IN.down or not pointer_events.is_empty():
		cancel_gesture()
		return
	if station_mode() and game.stations.back(): return
	if game.j_TEXTIN.active:
		game.j_TEXTIN.cancel = true
		return
	for panel in ["CUSTOM", "PAYP", "BRP", "SESP", "STATS", "BSP"]:
		var state: Dictionary = game.get("j_" + panel)
		if state.get("open", false):
			state.open = false
			if state.has("tutulan"): state.tutulan = null
			return
	if game.j_G.crate.open:
		game.j_G.crate.open = false
		return
	pause()

func pause() -> void:
	release_all()
	if game.j_G.scene == "play": game.j_G.scene = "pause"
	elif game.j_G.scene == "pause":
		# Close an overlaid panel before returning to a running day.
		for panel in ["SESP", "STATS", "BSP"]: game.get("j_" + panel).open = false
		game.j_G.scene = "play"

func begin_targets() -> void:
	next_targets.clear()

func add_target(rect: Rect2, label: String) -> void:
	if rect.size.x <= 0 or rect.size.y <= 0: return
	for item in next_targets:
		if item.rect == rect: return
	next_targets.append({"rect": rect, "label": label})

func end_targets() -> void:
	var new_context: String = game.j_G.scene
	for panel in ["CUSTOM", "PAYP", "BRP", "SESP", "STATS", "BSP"]:
		if game.get("j_" + panel).get("open", false): new_context += panel
	if new_context == "play" and not game.j_G.crate.open:
		add_stations()
	targets = next_targets.duplicate()
	if context != new_context:
		context = new_context
		target_index = -1
		if mode in ["controller", "keyboard"] and game.j_G.scene != "play" and not targets.is_empty():
			focus_target(0)

func add_stations() -> void:
	for key in game.j_ST:
		if key in ["shutter", "board", "drinkM", "ayran", "garnish", "sauce"]: continue
		var st: Dictionary = game.j_ST[key]
		add_target(Rect2(st.x, st.y, st.w, st.h), key)
	for index in int(game.J.method(game.j_TUN, "boards", [game.j_G])):
		add_target(Rect2(float(game.wrap_system.f_boardCX(index)) - 10, float(game.wrap_system.f_boardCY()) - 10, 20, 20), "board")
	for customer in game.j_G.customers:
		if customer.state == "wait": add_target(Rect2(customer.x - 16, customer.y - 48, 32, 36), "customer")
	for coin in game.j_G.coins:
		if coin.landed: add_target(Rect2(coin.x - 5, coin.y - 6, 10, 10), "coin")
	# Split fixtures with multiple independent click regions.
	for key in ["garnish","sauce"]:
		var st: Dictionary=game.j_ST[key]
		var count: int=2 if key=="garnish" else 3
		for i in count:
			add_target(Rect2(st.x+i*st.w/count,st.y,st.w/count,st.h),"ingredient")
	var bread: Dictionary=game.j_ST.bread
	add_target(Rect2(bread.x,bread.y,bread.w,16),"ingredient")
	var taps: Array = game.drink_system.f_icecekMusluklari()
	var drinks: Dictionary=game.j_ST.drinkM
	for i in taps.size():
		var width: float = drinks.w / taps.size()
		add_target(Rect2(drinks.x + i * width, drinks.y, width, 30), str(taps[i]))
		add_target(Rect2(drinks.x + i * width, drinks.y+34, width, 16), str(taps[i]))

func focus_target(index: int) -> void:
	if targets.is_empty(): return
	target_index = posmod(index, targets.size())
	game.pointer(targets[target_index].rect.get_center())

func cycle(step: int) -> void:
	focus_target(target_index + step if target_index >= 0 else (0 if step > 0 else targets.size() - 1))

func focus_direction(direction: Vector2) -> void:
	var origin := Vector2(game.j_IN.x, game.j_IN.y)
	var best := -1
	var score := INF
	for i in targets.size():
		var offset: Vector2 = targets[i].rect.get_center() - origin
		var forward := offset.dot(direction)
		if forward < 2: continue
		var sideways := absf(offset.cross(direction))
		var candidate := forward + sideways * 3.0
		if candidate < score:
			score = candidate
			best = i
	if best >= 0: focus_target(best)
