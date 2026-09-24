extends Control

const Game = preload("res://scripts/platform_game.gd")
const GAME_SIZE := Vector2(480, 270)
# REMAKE: oyun 2x HD cizilir (960x540 alt gorunum); pencereye keskin-bilinear
# shader ile basilir, kesirli olceklerde de pikseller esit kalir. Girdi
# koordinatlari yine 480x270 mantik biriminde.
const HD_OLCEK := 2
const KESKIN := preload("res://shaders/keskin_olcek.gdshader")
var game: Node
var game_viewport: SubViewport
var surface: TextureRect
var modal: ColorRect
var modal_panel: PanelContainer
var modal_scroll: ScrollContainer
var modal_body: VBoxContainer
var name_entry: LineEdit
var game_rect := Rect2()
var safe_rect := Rect2()
var ui_scale := 1.0
var mobile := OS.has_feature("mobile") or "--touch-preview" in OS.get_cmdline_user_args()
var integer_scale := false
var tv_margin := false
var fps_limit := 60
var settings_path := "user://device_settings.cfg"
var mouse_capture := false
var touch_capture := -1
var modal_kind := ""
var was_processing := false
var last_language := ""
var layout_timer := 0.0
# BIRLESIK (6. tur): ayarlardan acilan kare suresi gostergesi (telefonda olcum)
var show_perf := false
var perf_label: Label
var perf_t := 0.0
var perf_en := 0.0
# --olcum N: tam donanimli bir oyun gunu kurulur, N karenin ortalama
# advance suresi yazilir ve cikilir (release / debug karsilastirmasi)
var olcum_kare := 0
var olcum_say := 0
var olcum_top := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("100c0a")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_viewport = SubViewport.new()
	game_viewport.name = "GameViewport"
	game_viewport.size = Vector2i(GAME_SIZE) * HD_OLCEK
	game_viewport.disable_3d = true
	game_viewport.gui_disable_input = true
	game_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	game_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	add_child(game_viewport)
	game = Game.new()
	game.name = "Game"
	game.external_input = true
	if "--test" in OS.get_cmdline_user_args():
		game.storage.path = "res://artifacts/platform-shell-save.json"
		game.storage.values = {}
		settings_path = "res://artifacts/platform-settings.cfg"
	var oa := OS.get_cmdline_user_args().find("--olcum")
	if oa >= 0:
		olcum_kare = int(OS.get_cmdline_user_args()[oa + 1]) if oa + 1 < OS.get_cmdline_user_args().size() else 600
		game.storage.path = "user://olcum-save.json"   # oyuncunun kaydina dokunmaz
		game.storage.values = {}
	game_viewport.add_child(game)
	surface = TextureRect.new()
	surface.name = "PixelSurface"
	surface.texture = game_viewport.get_texture()
	surface.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var keskin := ShaderMaterial.new()
	keskin.shader = KESKIN
	keskin.set_shader_parameter("kaynak", GAME_SIZE * HD_OLCEK)
	surface.material = keskin
	surface.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(surface)
	build_modal()
	perf_label = Label.new()
	perf_label.position = Vector2(6, 4)
	perf_label.add_theme_font_size_override("font_size", 14)
	perf_label.add_theme_color_override("font_color", Color("ffe9a0"))
	perf_label.add_theme_color_override("font_outline_color", Color.BLACK)
	perf_label.add_theme_constant_override("outline_size", 4)
	perf_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(perf_label)
	load_preferences()
	perf_label.visible = show_perf
	if olcum_kare > 0: olcum_kur.call_deferred()
	game.controls.help_requested.connect(show_help)
	game.settings_requested.connect(show_settings)
	resized.connect(update_layout)
	get_window().size_changed.connect(update_layout)
	if not game.test_mode: get_window().focus_exited.connect(cancel_capture)
	update_labels()
	update_layout()

func text(tr_text: String, en_text: String) -> String:
	if game == null: return en_text
	return game.localization.cift(tr_text, en_text)

func make_button(label: String, callback: Callable, focusable := false) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_ALL if focusable else Control.FOCUS_NONE
	button.custom_minimum_size.y = 48 * ui_scale
	button.pressed.connect(callback)
	return button

func build_modal() -> void:
	modal = ColorRect.new()
	modal.color = Color(0.025, 0.018, 0.012, 0.92)
	modal.visible = false
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_panel = PanelContainer.new()
	modal.add_child(modal_panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("261a14")
	style.border_color = Color("bc8d49")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	modal_panel.add_theme_stylebox_override("panel", style)
	modal_scroll = ScrollContainer.new()
	modal_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	modal_scroll.follow_focus = true
	modal_panel.add_child(modal_scroll)
	modal_body = VBoxContainer.new()
	modal_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_body.add_theme_constant_override("separation", 10)
	modal_scroll.add_child(modal_body)

static func fit_game(area: Rect2, whole_pixels: bool, physical_scale := 1.0) -> Rect2:
	var scale_factor := minf(area.size.x / GAME_SIZE.x, area.size.y / GAME_SIZE.y)
	if whole_pixels and scale_factor * physical_scale >= 1:
		scale_factor = floorf(scale_factor * physical_scale) / physical_scale
	var fitted := GAME_SIZE * maxf(scale_factor, 0.01)
	var origin := area.position + (area.size - fitted) / 2
	origin = (origin * physical_scale).floor() / physical_scale
	return Rect2(origin, fitted)

static func usable_area(window_size: Vector2, physical_size: Vector2, physical_safe: Rect2, overscan: bool) -> Rect2:
	var area := Rect2(Vector2.ZERO, window_size)
	if physical_size.x > 0 and physical_size.y > 0 and physical_safe.has_area():
		var ratio := window_size / physical_size
		area = area.intersection(Rect2(physical_safe.position * ratio, physical_safe.size * ratio))
	if overscan: area = area.grow(-minf(area.size.x, area.size.y) * 0.05)
	return area

func update_layout() -> void:
	if surface == null or size.x <= 0 or size.y <= 0: return
	var physical_size := Vector2(get_window().size)
	var physical_safe := Rect2(Vector2.ZERO, physical_size)
	if OS.has_feature("mobile"):
		physical_safe = Rect2(DisplayServer.get_display_safe_area())
		physical_safe.position -= Vector2(DisplayServer.window_get_position())
	safe_rect = usable_area(size, physical_size, physical_safe, tv_margin)
	var physical_scale := maxf(physical_size.y / size.y, 0.1)
	ui_scale = clampf(DisplayServer.screen_get_dpi() / 160.0 / physical_scale, 1.0, 1.6) if mobile else 1.0
	var pad := 8.0 * ui_scale
	var area := safe_rect.grow(-pad)
	var fitted := fit_game(area, integer_scale, physical_scale)
	if fitted != game_rect and (mouse_capture or touch_capture >= 0): cancel_capture()
	game_rect = fitted
	surface.position = game_rect.position
	surface.size = game_rect.size
	if modal.visible: layout_modal()

func layout_modal() -> void:
	var area := safe_rect.grow(-12)
	var keyboard_height := DisplayServer.virtual_keyboard_get_height() if OS.has_feature("mobile") else 0
	if keyboard_height > 0: area.size.y = maxf(140, area.size.y - keyboard_height * size.y / get_window().size.y)
	var wanted := Vector2(minf(680 * ui_scale, area.size.x), minf(modal_body.get_combined_minimum_size().y + 32, area.size.y))
	modal_panel.size = wanted
	modal_panel.position = area.position + (area.size - wanted) / 2

func update_labels() -> void:
	last_language = game.j_LANG

func olcum_kur() -> void:
	var g := game
	g.j_MUTED = true
	g.j_G.up = {}
	for u in g.j_UPG: g.j_G.up[u.id] = float(u.lv.size())
	g.f_startDay()
	g.j_G.tut = 99; g.j_G.shutT = 0; g.j_G.spawnT = 1000; g.j_G.hintT = 0
	g.j_G.meat = 12; g.j_G.friesTray = 12
	for k in g.j_G.stock.keys(): g.j_G.stock[k] = 12; g.j_G.stockAnim[k] = 12
	g.f_newWrap()
	for i in 3:
		g.customer_system.f_spawnCustomer()
	g.j_G.scene = "play"

var olcum_odak := ""
func olcum_adim() -> void:
	olcum_say += 1
	if olcum_say == 61: olcum_odak = "evet" if get_window().has_focus() else "hayir"
	if olcum_say <= 60: return
	olcum_top += game.last_frame_ms
	if olcum_say < 60 + olcum_kare: return
	var satir := "OLCUM %s ort_ms=%.2f kare=%d fps=%d gpu=%s surucu=%s odak=%s" % ["debug" if OS.is_debug_build() else "release", olcum_top / olcum_kare, olcum_kare,
		Engine.get_frames_per_second(), RenderingServer.get_video_adapter_name(), RenderingServer.get_current_rendering_driver_name(), olcum_odak]
	print(satir)
	var f := FileAccess.open("user://olcum.txt", FileAccess.WRITE)
	if f: f.store_line(satir); f.close()
	get_tree().quit()

func _process(delta: float) -> void:
	if game == null: return
	if olcum_kare > 0: olcum_adim()
	if show_perf:
		perf_t += delta
		perf_en = maxf(perf_en, game.last_frame_ms)
		if perf_t >= 0.5:
			perf_label.text = "%d FPS · %.1f ms" % [Engine.get_frames_per_second(), perf_en]
			perf_t = 0.0; perf_en = 0.0
	if game.j_LANG != last_language: update_labels()
	if game.j_TEXTIN.active and not game.j_TEXTIN.done and not game.j_TEXTIN.cancel and modal_kind != "name": show_name_entry()
	if modal_kind == "name" and not game.j_TEXTIN.active: close_modal()
	layout_timer += delta
	if layout_timer >= 0.5:
		layout_timer = 0
		update_layout()
	var in_game := game_rect.has_point(get_local_mouse_position()) and not modal.visible
	var cursor_hidden: bool = in_game or (game.controls.mode == "controller" and not modal.visible)
	var wanted := Input.MOUSE_MODE_HIDDEN if cursor_hidden else Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode != wanted: Input.mouse_mode = wanted

func local_event(event: InputEvent) -> InputEvent:
	var mapped: InputEvent = event.duplicate()
	mapped.position = (event.position - game_rect.position) * GAME_SIZE / game_rect.size
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		mapped.relative = event.relative * GAME_SIZE / game_rect.size
	return mapped

func cancel_capture() -> void:
	mouse_capture = false
	touch_capture = -1
	game.controls.cancel_gesture()

func _notification(what: int) -> void:
	if game == null or game.controls == null: return
	if what == NOTIFICATION_APPLICATION_PAUSED: cancel_capture()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if modal.visible:
			if modal_kind == "name": game.j_TEXTIN.cancel = true
			close_modal()
		else: game.controls.back()

func _input(event: InputEvent) -> void:
	if game == null: return
	if modal.visible:
		if event.is_action_pressed("game_cancel") or event.is_action_pressed("game_help"):
			if modal_kind == "name": game.j_TEXTIN.cancel = true
			close_modal()
			get_viewport().set_input_as_handled()
		return
	# Captured releases must reach the game even over an outer toolbar button.
	if (mouse_capture and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) or (touch_capture >= 0 and event is InputEventScreenTouch and event.index == touch_capture and not event.pressed):
		if game_rect.has_point(event.position): game._input(local_event(event))
		else: game.controls.cancel_gesture()
		mouse_capture = false
		touch_capture = -1
		get_viewport().set_input_as_handled()
	elif (mouse_capture and event is InputEventMouseMotion) or (touch_capture >= 0 and event is InputEventScreenDrag and event.index == touch_capture):
		game._input(local_event(event))
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if game == null or modal.visible or game.suspended: return
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag:
		if not game_rect.has_point(event.position):
			if event is InputEventMouseMotion:
				game.reset_mouse_cut()
				game.mouse_in_game = false
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			mouse_capture = event.pressed
		elif event is InputEventScreenTouch and event.pressed:
			if touch_capture >= 0: return
			touch_capture = event.index
		game._input(local_event(event))
	else: game._input(event)
	get_viewport().set_input_as_handled()

func start_modal(kind: String, heading: String) -> void:
	if modal.visible: close_modal()
	cancel_capture()
	game.controls.release_all()
	was_processing = game.is_processing()
	game.set_process(false)
	game.overlay_open = true
	modal_kind = kind
	for child in modal_body.get_children():
		modal_body.remove_child(child)
		child.queue_free()
	name_entry = null
	var title := Label.new()
	title.text = heading
	title.add_theme_font_size_override("font_size", int(24 * ui_scale))
	title.add_theme_color_override("font_color", Color("f3ce82"))
	modal_body.add_child(title)
	modal.show()

func close_modal() -> void:
	modal.hide()
	modal_kind = ""
	game.overlay_open = false
	game.set_process(was_processing)
	game.controls.release_all()
	get_viewport().gui_release_focus()
	if OS.has_feature("mobile"): DisplayServer.virtual_keyboard_hide()

func finish_modal() -> void:
	layout_modal()
	call_deferred("layout_modal")

func show_help() -> void:
	start_modal("help", text("TEZGÂH SENİN", "YOUR COUNTER"))
	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", int(17 * ui_scale))
	info.text = text(
		"TEZGÂHTA OYNA\nMalzemeyi kendi tepsisinden seç. Sarma, kağıtlama ve servis doğrudan ürünün üzerinde yapılır.\n\nDOKUNMATİK\nLavaşa ve malzemelere dokun. Dürümü basılı tutarak sar; yeniden basılı tutarak kağıtla. Hazır ürüne, ardından müşteriye dokunarak servis et. Döneri ve doğrama tahtasını basılı tut.\n\nOYUN KOLU\nSol çubuk / yön tuşları: nesne seç\n× / A: seçili nesneyi kullan; sarma / kağıt / doğrama için basılı tut\nL1–R1 / LB–RB: hazırlama tahtası / müşteri / ızgara gözü değiştir\n□ / X: ürünü al / eldeki ürünü geri bırak\n○ / B: iptal / geri / mola\nR2 / RT: döner kes; bırakınca önceki hedefe dön\nL2 / LT basılı: hassas imleç\nOptions / Start: mola · △ / Y: yardım\n\nKLAVYE VE FARE\nFare: özgün tıklama ve sürükleme\nWASD / oklar: nesne seç · Enter / Boşluk: kullan / tut\nQ / Tab: tahta değiştir · E: al / geri bırak\nR: döner kes · Shift: hassas imleç · P: mola\n\nGeliştirmeler açıldığında ızgara, sos, içecek ve diğer ürünler de kendi görsellerinden kullanılır.",
		"PLAY ON THE COUNTER\nUse the actual ingredients, food and machines in the scene.\n\nTOUCH\nTap bread and ingredients. Hold the wrap to roll; hold again to paper. Tap finished food, then its customer to serve. Hold the spit or chopping board to cut.\n\nCONTROLLER\nStick / D-pad: select an object\n× / A: use; hold to roll, paper or chop\nLB / RB: switch preparation board, customer or grill slot\nX: pick up / return held item · B: cancel / back\nRT: slice meat · Hold LT: precision pointer\nStart: pause · Y: help\n\nKEYBOARD AND MOUSE\nMouse: original click and drag\nWASD / arrows: select · Enter / Space: use / hold\nQ / Tab: switch board · E: pick up / return\nR: slice · Shift: precision pointer · P: pause\n\nUnlocked grills, sauces, drinks and other items are also used directly in the scene.")
	modal_body.add_child(info)
	var row := HBoxContainer.new()
	modal_body.add_child(row)
	row.add_child(make_button(text("Ekran ayarları", "Display settings"), show_settings, true))
	var close := make_button(text("Anladım", "Got it"), close_modal, true)
	row.add_child(close)
	close.grab_focus()
	finish_modal()

func show_settings() -> void:
	start_modal("settings", text("EKRAN VE PERFORMANS", "DISPLAY & PERFORMANCE"))
	var station_setting := CheckButton.new()
	station_setting.text = text("Nesnelere doğrudan dokunma ve kol seçimi", "Direct object touch and controller selection")
	station_setting.button_pressed = game.stations.enabled
	station_setting.custom_minimum_size.y = 48*ui_scale
	station_setting.toggled.connect(func(value: bool) -> void:
		game.controls.release_all()
		game.stations.enabled = value
		update_labels()
		save_preferences())
	modal_body.add_child(station_setting)
	var pixel := CheckButton.new()
	pixel.text = text("Tam piksel ölçekleme (kenarlarda daha fazla boşluk)", "Integer pixel scaling (larger borders)")
	pixel.button_pressed = integer_scale
	pixel.custom_minimum_size.y = 48 * ui_scale
	pixel.toggled.connect(func(value: bool) -> void: integer_scale = value; save_preferences(); update_layout())
	modal_body.add_child(pixel)
	var safe := CheckButton.new()
	safe.text = text("TV için kenar payı", "TV safe margin")
	safe.button_pressed = tv_margin
	safe.custom_minimum_size.y = 48 * ui_scale
	safe.toggled.connect(func(value: bool) -> void: tv_margin = value; save_preferences(); update_layout())
	modal_body.add_child(safe)
	var fps := OptionButton.new()
	fps.add_item(text("60 FPS hedefi", "60 FPS target"), 60)
	fps.add_item(text("30 FPS / daha az güç tüketimi", "30 FPS / lower power use"), 30)
	fps.select(0 if fps_limit == 60 else 1)
	fps.custom_minimum_size.y = 48 * ui_scale
	fps.item_selected.connect(func(index: int) -> void: fps_limit = fps.get_item_id(index); Engine.max_fps = fps_limit; save_preferences())
	modal_body.add_child(fps)
	var perf := CheckButton.new()
	perf.text = text("Kare süresini göster", "Show frame time")
	perf.button_pressed = show_perf
	perf.custom_minimum_size.y = 48 * ui_scale
	perf.toggled.connect(func(value: bool) -> void: show_perf = value; perf_label.visible = value; save_preferences())
	modal_body.add_child(perf)
	if not mobile: modal_body.add_child(make_button(text("Tam ekran / pencere", "Fullscreen / window"), func() -> void: game.f_fsToggle(), true))
	var close := make_button(text("Kapat", "Close"), close_modal, true)
	modal_body.add_child(close)
	pixel.grab_focus()
	finish_modal()

func show_name_entry() -> void:
	start_modal("name", text("TABELANI YAZ", "WRITE YOUR SIGN"))
	name_entry = LineEdit.new()
	name_entry.text = game.j_TEXTIN.value
	name_entry.max_length = int(game.j_TEXTIN.max)
	name_entry.custom_minimum_size.y = 48 * ui_scale
	name_entry.add_theme_font_size_override("font_size", int(22 * ui_scale))
	name_entry.virtual_keyboard_enabled = true
	name_entry.text_submitted.connect(func(_value: String) -> void: submit_name())
	modal_body.add_child(name_entry)
	if game.controls.mode == "controller":
		var grid := GridContainer.new()
		grid.columns = 10
		modal_body.add_child(grid)
		var alphabet := "ABCÇDEFGĞHIİJKLMNOÖPQRSŞTUÜVWXYZ0123456789 -"
		for character in alphabet:
			var key := make_button(character if character != " " else "␣", func() -> void:
				if name_entry.text.length() < name_entry.max_length: name_entry.text += character, true)
			key.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(key)
		grid.get_child(0).grab_focus()
	var row := HBoxContainer.new()
	modal_body.add_child(row)
	row.add_child(make_button(text("Sil", "Delete"), func() -> void: name_entry.text = name_entry.text.left(-1), true))
	row.add_child(make_button(text("Vazgeç", "Cancel"), func() -> void: game.j_TEXTIN.cancel = true; close_modal(), true))
	row.add_child(make_button(text("Tamam", "Done"), submit_name, true))
	if game.controls.mode != "controller": name_entry.grab_focus(); name_entry.caret_column = name_entry.text.length()
	finish_modal()

func submit_name() -> void:
	var filtered := ""
	for character in name_entry.text.replace("i", "İ").replace("ı", "I").to_upper():
		if game.j_FONT.has(character) and filtered.length() < int(game.j_TEXTIN.max): filtered += character
	game.j_TEXTIN.value = filtered
	game.j_TEXTIN.done = true
	close_modal()

func load_preferences() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) == OK:
		game.stations.enabled = config.get_value("controls","stations",true)
		integer_scale = config.get_value("display", "integer_scale", false)
		tv_margin = config.get_value("display", "tv_margin", false)
		fps_limit = config.get_value("display", "fps_limit", 30 if mobile else 60)
		show_perf = config.get_value("display", "show_perf", false)
	else: fps_limit = 30 if mobile else 60
	if fps_limit not in [30, 60]: fps_limit = 60
	Engine.max_fps = fps_limit

func save_preferences() -> void:
	var config := ConfigFile.new()
	config.set_value("controls","stations",game.stations.enabled)
	config.set_value("display", "integer_scale", integer_scale)
	config.set_value("display", "tv_margin", tv_margin)
	config.set_value("display", "fps_limit", fps_limit)
	config.set_value("display", "show_perf", show_perf)
	config.save(settings_path)
