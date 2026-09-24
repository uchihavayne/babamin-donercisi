# Godot platform services: display, mouse/touch/keyboard, audio and persistence.
extends "res://scripts/pixel_primitives.gd"
const J = preload("res://scripts/js_compat.gd")
const Canvas = preload("res://scripts/pixel_canvas.gd")
const GPUCanvas = preload("res://scripts/gpu_canvas.gd")
const Store = preload("res://scripts/save_store.gd")
# REMAKE 2x HD piksel: oyun mantigi ve yerlesim 480x270, ekran 960x540.
# Kodla cizilen her sey 2x2 pikselle cizilir; Blender'dan gelen 2x
# gorseller kendi piksel yogunluklarinda (yarim mantik pikseli) oturur.
# CPU tuvali (testler) 480x270 goruntuyu 2x buyuterek basar.
const OLCEK := 2
var screen_canvas = Canvas.new()
var storage = Store.new()
var clock_ms: float = 0.0
var frame_texture: ImageTexture
var game: Variant
var native_timers: Dictionary = {}
var timer_serial: int = 0
var audio_streams: Dictionary = {}
var audio_loops: Dictionary = {}
var synth_cache: Dictionary = {}
var pour_player: AudioStreamPlayer
var suspended: bool = false
var frame_count: int = 0
var test_mode: bool = false
var last_frame_ms: float = 0.0
var gpu_enabled := false

func _ready() -> void:
	game = self
	test_mode = "--test" in OS.get_cmdline_user_args()
	gpu_enabled = (not test_mode or "--gpu-test" in OS.get_cmdline_user_args()) and "--cpu-renderer" not in OS.get_cmdline_user_args()
	if gpu_enabled:
		screen_canvas = GPUCanvas.new()
		screen_canvas.attach(get_canvas_item())
		screen_canvas.olcek_hd = true   # remake: olcekli cizim HD izgarada
	screen_canvas.width = 480
	screen_canvas.height = 270
	screen_canvas.ensure()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not test_mode: random_state = Time.get_ticks_usec() & 0xffffffff
	game.initialize_game()
	game.j_SFX.moto = J.ref(native_moto, 0)
	f_audioInit()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if not test_mode:
		get_window().focus_exited.connect(func() -> void: f_appPause())
		get_window().focus_entered.connect(func() -> void: f_appResume())
	if not gpu_enabled: frame_texture = ImageTexture.create_from_image(screen_canvas.image)
	if test_mode: set_process(false)

func _process(delta: float) -> void:
	if suspended: return
	advance(minf(delta, .06))

func advance(delta: float) -> void:
	var began := Time.get_ticks_usec()
	if gpu_enabled: screen_canvas.begin_frame()
	clock_ms += delta * 1000.0
	if game.j_AC is Dictionary: game.j_AC.currentTime = clock_ms / 1000.0
	for id in native_timers.keys():
		if not native_timers.has(id): continue
		var timer: Dictionary = native_timers[id]
		if clock_ms >= timer.next:
			if timer.repeat: timer.next = clock_ms + timer.delay
			else: native_timers.erase(id)
			J.invoke(timer.callback)
	game.game_loop.f_frame(clock_ms)
	if gpu_enabled: screen_canvas.end_frame()
	update_audio_levels()
	frame_count += 1
	if not gpu_enabled:
		frame_texture.update(screen_canvas.image)
		queue_redraw()
	last_frame_ms = (Time.get_ticks_usec() - began) / 1000.0

func _draw() -> void:
	if frame_texture: draw_texture_rect(frame_texture, Rect2(0, 0, 480 * OLCEK, 270 * OLCEK), false)

func _input(event: InputEvent) -> void:
	if game == null: return
	if event is InputEventMouseMotion:
		pointer(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer(event.position)
		pointer_button(event.pressed)
	elif event is InputEventScreenTouch:
		game.j_TOUCH = true
		pointer(event.position)
		pointer_button(event.pressed)
	elif event is InputEventScreenDrag:
		game.j_TOUCH = true
		pointer(event.position)
	elif event is InputEventKey and not event.echo:
		var code := key_code(event.physical_keycode)
		if event.pressed:
			if not J.truth(game.j_IN.keys.get(code)): game.j_IN.kp[code] = true
			game.j_IN.keys[code] = true
			f_audioInit()
			if game.j_TEXTIN.active: text_key(event)
		else: game.j_IN.keys[code] = false

func pointer(position: Vector2) -> void:
	game.j_IN.x = clampf(position.x, 0, 479)
	game.j_IN.y = clampf(position.y, 0, 269)

func pointer_button(down: bool) -> void:
	game.j_IN.down = down
	if down:
		game.j_IN.downX = game.j_IN.x
		game.j_IN.downY = game.j_IN.y
		game.j_IN.pressed = true
		game.j_IN.downTime = 0.0
		f_audioInit()
	else: game.j_IN.released = true

func key_code(key: Key) -> String:
	match key:
		KEY_ESCAPE: return "Escape"
		KEY_SPACE: return "Space"
		KEY_ENTER: return "Enter"
		KEY_BACKSPACE: return "Backspace"
		KEY_UP: return "ArrowUp"
		KEY_DOWN: return "ArrowDown"
		KEY_LEFT: return "ArrowLeft"
		KEY_RIGHT: return "ArrowRight"
	if key >= KEY_A and key <= KEY_Z: return "Key" + String.chr(key)
	if key >= KEY_0 and key <= KEY_9: return "Digit" + String.chr(key)
	return OS.get_keycode_string(key)

func text_key(event: InputEventKey) -> void:
	match event.keycode:
		KEY_BACKSPACE: game.j_TEXTIN.value = game.j_TEXTIN.value.left(-1)
		KEY_ENTER: game.j_TEXTIN.done = true
		KEY_ESCAPE: game.j_TEXTIN.cancel = true
		_:
			if event.unicode and game.j_TEXTIN.value.length() < game.j_TEXTIN.max:
				var ch := String.chr(event.unicode).replace("i", "İ").replace("ı", "I").to_upper()
				if game.j_FONT.has(ch): game.j_TEXTIN.value += ch

func native_timer(callback: Variant, milliseconds: Variant = 0, repeat: Variant = false) -> Variant:
	timer_serial += 1
	native_timers[timer_serial] = {"callback": callback, "delay": J.n(milliseconds), "next": clock_ms + J.n(milliseconds), "repeat": J.truth(repeat)}
	return timer_serial

func native_cancel_timer(id: Variant) -> Variant:
	native_timers.erase(id)
	return null

func f_fitScreen() -> Variant: return null
func f_ptr(_event: Variant = null) -> Variant: return null
func f_fsOn() -> Variant: return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
func f_fsToggle() -> Variant:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if f_fsOn() else DisplayServer.WINDOW_MODE_FULLSCREEN)
	return null

func f_appPause() -> Variant:
	if game.j_G.scene == "play": game.j_G.scene = "pause"
	suspended = true
	for player in audio_loops.values(): player.stream_paused = true
	f_pourSndStop()
	return null

func f_appResume() -> Variant:
	suspended = false
	for player in audio_loops.values(): player.stream_paused = false
	return null

func f_logoYukle() -> Variant:
	if game.j_LOGO.istek: return null
	var data: Dictionary = game.j_LOGO_VERI
	var images: Dictionary = {"arka": data.arka.src, "sis": data.sis.src}
	for lang in data.on:
		images["on_" + lang] = data.on[lang].src
		images["maske_" + lang] = data.on[lang].maske
	for key in images:
		var canvas = Canvas.new()
		canvas.src = images[key]
		game.j_LOGO.im[key] = canvas
		game.j_LOGO.istek += 1
		game.j_LOGO.tamam += 1
	return null

func f_sprYukle() -> Variant:
	# The supplied HTML disables these external, non-embedded atlases.
	game.j_SPR_BASLADI = true
	if not J.truth(game.j_OZEL_ACIK): return null
	for key in game.j_SPR:
		var atlas: Dictionary = game.j_SPR[key]
		for suffix in ["", "M"]:
			var path: String = "res://assets/" + str(atlas.get("yol" + suffix, ""))
			game.j_SPR_ISTEK += 1
			if FileAccess.file_exists(path):
				var canvas = Canvas.new()
				canvas.src = path
				atlas["im" + suffix] = canvas
			game.j_SPR_TAMAM += 1
	return null

func f_saveGame(value: Variant = null) -> Variant:
	return game.save_system.f_saveGame(value)

func f_loadGame() -> Variant:
	return game.save_system.f_loadGame()

func f_clearSave() -> Variant:
	return game.save_system.f_clearSave()

func f_audioInit() -> Variant:
	if game.j_AC != null: return null
	game.j_AC = {"state": "running", "currentTime": clock_ms / 1000.0}
	game.j_MASTER = true
	game.j_MUSBUS = true
	game.j_SFXBUS = true
	f_sndLoad()
	return null

func f_sndLoad() -> Variant:
	if game.j_SNDOK: return null
	game.j_SNDOK = true
	for key in game.j_SND:
		var def: Dictionary = game.j_SND[key]
		var path: String = def.url
		if path.ends_with(".m4a"): path = path.trim_suffix(".m4a") + ".wav"
		if ResourceLoader.exists(path):
			audio_streams[key] = load(path)
			def.buf = true
	return null

func f_sndBus(_def: Variant = null) -> Variant: return true
func f_sndFallback(_def: Variant = null) -> Variant: return null
func f_sndElVol(def: Variant = null) -> Variant:
	return 0.0 if game.j_MUTED else J.n(def.vol) * game.effects.f_volKazanc(game.j_VOL.get(def.get("tur", "sfx"), 100))
func f_sndVolGuncelle() -> Variant:
	update_audio_levels()
	return null
func f_volUygula() -> Variant:
	update_audio_levels()
	return null

func new_player(stream: AudioStream, gain: float, category: String = "sfx") -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.set_meta("gain", gain)
	player.set_meta("category", category)
	add_child(player)
	apply_player_volume(player)
	return player

func apply_player_volume(player: AudioStreamPlayer) -> void:
	var gain: float = player.get_meta("gain", 1.0)
	var category: String = player.get_meta("category", "sfx")
	var level: float = J.n(game.j_VOL.get(category, 100)) / 100.0
	player.volume_linear = 0.0 if game.j_MUTED else gain * level * level * .45

func update_audio_levels() -> void:
	for child in get_children():
		if child is AudioStreamPlayer: apply_player_volume(child)
	if audio_loops.has("fry"):
		var fry: AudioStreamPlayer = audio_loops.fry
		if fry.playing and fry.get_playback_position() >= 4.90: fry.seek(3.40)

func f_sndPlay(key: Variant = null, rate: Variant = null) -> Variant:
	if not audio_streams.has(key) or game.j_MUTED: return false
	var def: Dictionary = game.j_SND[key]
	var player := new_player(audio_streams[key], J.n(def.vol), def.get("tur", "sfx"))
	player.pitch_scale = J.n(rate) if J.truth(rate) else 1.0
	player.finished.connect(player.queue_free)
	if not test_mode: player.play()
	return true

func f_sndLoop(key: Variant = null, on: Variant = false, volume: Variant = null) -> Variant:
	if not audio_streams.has(key): return false
	if not audio_loops.has(key):
		var def: Dictionary = game.j_SND[key]
		var player := new_player(audio_streams[key], 0.0, def.get("tur", "sfx"))
		player.finished.connect(func() -> void:
			if J.n(player.get_meta("gain", 0)) > 0: player.play(J.n(def.get("dS", 0))))
		audio_loops[key] = player
	var player: AudioStreamPlayer = audio_loops[key]
	var level: float = J.n(game.j_SND[key].vol if volume == null else volume) if J.truth(on) else 0.0
	player.set_meta("gain", level)
	apply_player_volume(player)
	if level > 0 and not player.playing and not test_mode: player.play(J.n(game.j_SND[key].get("dS", 0)))
	elif level == 0 and player.playing: player.stop()
	return true

func f_ambSet(on: Variant = false) -> Variant: return f_sndLoop("street", on)
func f_ambRain(on: Variant = false) -> Variant:
	f_sndLoop("camYagmur", on)
	return f_sndLoop("rain", on)

func synth(kind: String, freq: float, duration: float, wave: String, gain: float, end_freq: float = 0, quality: float = 1) -> AudioStreamWAV:
	var key: String = str([kind, freq, duration, wave, gain, end_freq, quality])
	if synth_cache.has(key): return synth_cache[key]
	var rate := 22050
	var count := int((duration + .02) * rate)
	var samples := PackedByteArray()
	samples.resize(count * 2)
	var phase := 0.0
	var low := 0.0
	var band := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(key)
	for i in count:
		var t := float(i) / rate
		var u := minf(1.0, t / maxf(.001, duration))
		var frequency := freq * pow(maxf(20.0, end_freq) / maxf(20, freq), u) if end_freq > 0 else freq
		phase += frequency / rate
		var sample := 0.0
		if kind == "noise":
			var noise_value := rng.randf_range(-1.0, 1.0)
			var coefficient := minf(.9, 2 * sin(PI * frequency / rate))
			low += coefficient * band
			var high := noise_value - low - band / maxf(.5, quality)
			band += coefficient * high
			sample = band
		else:
			match wave:
				"sine": sample = sin(phase * TAU)
				"triangle": sample = 4 * absf(fmod(phase + .25, 1) - .5) - 1
				"sawtooth": sample = fmod(phase, 1) * 2 - 1
				_: sample = 1.0 if fmod(phase, 1) < .5 else -1.0
		var envelope := gain * pow(.0008 / maxf(.001, gain), u)
		if t < .008: envelope = gain * t / .008
		if t > duration: envelope *= maxf(0, 1 - (t - duration) / .02)
		var value := int(clampf(sample * envelope, -1, 1) * 32767)
		samples.encode_s16(i * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = samples
	if synth_cache.size() > 256: synth_cache.clear()
	synth_cache[key] = stream
	return stream

func play_synth(stream: AudioStream, delay: float = 0, category: String = "sfx", gain: float = 1) -> void:
	if test_mode: return
	var player := new_player(stream, gain, category)
	player.finished.connect(player.queue_free)
	if delay > 0: get_tree().create_timer(delay).timeout.connect(player.play)
	else: player.play()

func f_beep(freq: Variant = null, dur: Variant = null, type: Variant = null, vol: Variant = null, slide_to: Variant = null, delay: Variant = null) -> Variant:
	if game.j_MUTED or not game.j_AC: return null
	play_synth(synth("tone", J.n(freq), J.n(dur), str(type) if type != null else "square", .18 if vol == null else J.n(vol), J.n(slide_to)), J.n(delay))
	return null

func f_noise(dur: Variant = null, vol: Variant = null, f0: Variant = null, f1: Variant = null, q: Variant = null) -> Variant:
	if game.j_MUTED or not game.j_AC: return null
	play_synth(synth("noise", J.n(f0), J.n(dur), "", J.n(vol), J.n(f1), 1.0 if q == null else J.n(q)))
	return null

func f_noiseBuf(_length: Variant = null) -> Variant: return null
func f_swell(dur: Variant = null, vol: Variant = null, f0: Variant = null, fpeak: Variant = null, q: Variant = null) -> Variant:
	return f_noise(dur, vol, f0, fpeak, q)

func native_moto() -> Variant:
	for i in 3: f_beep(70 + i * 8, .26, "sawtooth", .10, 150 + i * 20, i * .18)
	f_noise(.5, .06, 300, 900, .6)
	return null

func f_pourSndStart(type: Variant = null) -> Variant:
	if game.j_MUTED or game.j_AC == null: return null
	f_pourSndStop()
	var stream := synth("noise", 520 if type == "ayran" else 900, 2.2, "", .10 if type == "ayran" else .075, 1200, 3.4).duplicate()
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = stream.data.size() / 2
	pour_player = new_player(stream, 1.0)
	if not test_mode: pour_player.play()
	game.j_POUR = {"type": type}
	return null
func f_pourSndLevel(fill: Variant = null) -> Variant:
	if is_instance_valid(pour_player): pour_player.pitch_scale = 1.0 + clampf(J.n(fill), 0, 1) * .7
	return null
func f_pourSndStop(splash: Variant = null) -> Variant:
	if is_instance_valid(pour_player):
		pour_player.stop()
		pour_player.stream = null
		pour_player.queue_free()
	pour_player = null
	if game != null: game.j_POUR = null
	if J.truth(splash): f_noise(.10, .07, 700, 260, 1.4)
	return null

func f_musNote(freq: Variant = null, dur: Variant = null, type: Variant = null, vol: Variant = null, when: Variant = null) -> Variant:
	play_synth(synth("tone", J.n(freq), J.n(dur), str(type), J.n(vol)), maxf(0, J.n(when) - clock_ms / 1000), "mus", .2)
	return null
func f_musPerc(when: Variant = null, hard: Variant = null) -> Variant:
	play_synth(synth("noise", 3800 if J.truth(hard) else 260, .05 if J.truth(hard) else .12, "", .05 if J.truth(hard) else .12), maxf(0, J.n(when) - clock_ms / 1000), "mus", .2)
	return null
func f_musInit() -> Variant:
	if not J.truth(game.j_MUS.timer): game.j_MUS.timer = native_timer(J.ref(f_musTick, 0), 90, true)
	return null
func f_musSet(mode: Variant = null) -> Variant:
	game.j_MUS.mode = "off" if audio_streams.has("street") else mode
	return null
func f_musTick() -> Variant:
	if not game.j_MUS.on or game.j_MUS.mode == "off" or game.j_MUTED: return null
	var now := clock_ms / 1000.0
	var tempo := .125 if game.j_MUS.mode == "play" else .155
	while game.j_MUS.next < now + .2:
		if game.j_MUS.next < now: game.j_MUS.next = now + .02
		var i := int(game.j_MUS.step) % 16
		var bar := int(floor(game.j_MUS.step / 16)) % 4
		var pattern: Array = game.j_MEL2 if bar == 1 or bar == 3 else game.j_MEL
		var note: Array = pattern[i]
		if note[0] >= 0: f_musNote(game.j_SCALE[int(note[0])], note[1] * tempo * .9, "square", .045, game.j_MUS.next)
		if game.j_BASS[i]: f_musNote(game.j_BASS[i], tempo * 3.4, "triangle", .085, game.j_MUS.next)
		if i % 4 == 0: f_musPerc(game.j_MUS.next, false)
		if i == 4 or i == 12: f_musPerc(game.j_MUS.next, true)
		game.j_MUS.next += tempo
		game.j_MUS.step += 1
	return null

var random_state: int = 123456
func random_unit() -> float:
	random_state = (random_state * 1664525 + 1013904223) & 0xffffffff
	return float(random_state) / 4294967296.0

var string_cache: Dictionary = {}
var meat_cache: Dictionary = {}
var meat_quantized: Dictionary = {}
# BIRLESIK (6. tur performans): genislik harf harf her cagrida hesaplaniyordu
# (~14 us); metin + mono basina onbellek.
var _gen_onbellek: Dictionary = {}
func f_textW(text: Variant = null, scale_value: Variant = null, mono: Variant = null) -> Variant:
	var value: String = J.s(game.localization.f_T(text))
	var scale_factor: float = J.n(scale_value) if J.truth(scale_value) else 1.0
	var m := J.truth(mono)
	var anahtar := value + ("\u0001" if m else "")
	var width: Variant = _gen_onbellek.get(anahtar)
	if width == null:
		var gw := 0
		for ch in value:
			var glyph: Dictionary = game.j_FONT.get(ch, game.j_FONT["?"])
			gw += (maxi(int(glyph.w), 4) if m else int(glyph.w)) + 1
		if _gen_onbellek.size() > 4096: _gen_onbellek.clear()
		_gen_onbellek[anahtar] = gw
		width = gw
	return (int(width) - 1) * scale_factor

func f_drawStr(text: Variant = null, x: Variant = null, y: Variant = null, color: Variant = null, scale_value: Variant = null, mono: Variant = null) -> Variant:
	var value: String = J.s(text)
	var hd := _yazi_hd()
	var key: Array = [value, color, J.truth(mono), hd]
	var cached: Variant = string_cache.get(key)
	if cached == null:
		var width := 0
		for ch in value:
			var glyph: Dictionary = game.j_FONT.get(ch, game.j_FONT["?"])
			width += (maxi(int(glyph.w), 4) if J.truth(mono) else int(glyph.w)) + 1
		cached = Canvas.new()
		cached.width = maxi(1, width)
		cached.height = 8
		cached.ensure()
		_str_yaz(cached, value, Canvas.parse_color(str(color)), J.truth(mono), 0, 0)
		if hd: cached = _epx(cached)
		if string_cache.size() > 1024: string_cache.clear()
		string_cache[key] = cached
	var scale_factor: float = J.n(scale_value) if scale_value != null else 1.0
	draw_context.drawImage(cached, x, y, float(cached.get_meta("lw", cached.width)) * scale_factor, float(cached.get_meta("lh", 8)) * scale_factor)
	return null

# BIRLESIK (6. tur, analiz madde 3): modeller 2x HD iken yazilar 5 px'lik
# yazi tipinin kaba 2x buyutmesiydi. HD'de her yazi Scale2x (EPX) ile 2x
# izgaraya cikarilir: harf genislikleri ve yerlesim ayni, capraz ve kavisler
# yumusar, pikselli karakter korunur. CPU tuvali (testler) eskisi gibi.
func _yazi_hd() -> bool:
	return get("hd_acik") == true and draw_context is GPUCanvas

func _epx(cv: Variant) -> Variant:
	var src: Image = cv.image
	var w := src.get_width()
	var h := src.get_height()
	var bos := Color(0, 0, 0, 0)
	var out := Canvas.new()
	out.width = w * 2
	out.height = h * 2
	out.ensure()
	var d: Image = out.image
	for y in h:
		for x in w:
			var P := src.get_pixel(x, y)
			var A := src.get_pixel(x, y - 1) if y > 0 else bos
			var B := src.get_pixel(x + 1, y) if x < w - 1 else bos
			var C := src.get_pixel(x - 1, y) if x > 0 else bos
			var D := src.get_pixel(x, y + 1) if y < h - 1 else bos
			d.set_pixel(x * 2, y * 2, A if (C == A and C != D and A != B) else P)
			d.set_pixel(x * 2 + 1, y * 2, B if (A == B and A != C and B != D) else P)
			d.set_pixel(x * 2, y * 2 + 1, C if (D == C and D != B and C != A) else P)
			d.set_pixel(x * 2 + 1, y * 2 + 1, D if (B == D and B != A and D != C) else P)
	out.set_meta("lw", w)
	out.set_meta("lh", h)
	return out

# glif piksellerini tuvale yaz (ox, oy kaymasiyla); ust uste yazim son rengi birakir
func _str_yaz(cv: Variant, value: String, c: Color, mono: bool, ox: int, oy: int) -> void:
	var cursor := 0
	for ch in value:
		var glyph: Dictionary = game.j_FONT.get(ch, game.j_FONT["?"])
		var gw: int = maxi(int(glyph.w), 4) if mono else int(glyph.w)
		var offset: int = int(floor((gw - glyph.w) / 2.0)) if mono else 0
		if ch != " ":
			for row_index in glyph.rows.size():
				var row: String = glyph.rows[row_index]
				for column in int(glyph.w):
					var i: int = int(glyph.x0) + column
					if i < row.length() and row[i] == "#": cv.image.set_pixel(ox + cursor + offset + column, oy + row_index, c)
		cursor += gw + 1

# BIRLESIK (6. tur performans): cerceveli yazi 9 ayri cizimdi (~140 us),
# golgeli 2. Cerceve (8 komsu) ya da golge (+1,+1) ve yazi tek tuvalde pisirilir;
# olcek (sc) tuvalin tamamina uygulanir -> eski cizimle ayni pikseller.
# cerceve: true -> 8 komsu, false -> golge
func f_drawStrKenar(text: Variant, x: Variant, y: Variant, color: Variant, kenar: Variant, cerceve: bool, scale_value: Variant, mono: Variant) -> void:
	var value: String = J.s(text)
	var m := J.truth(mono)
	var hd := _yazi_hd()
	var key: Array = [value, color, kenar, cerceve, m, hd]
	var cached: Variant = string_cache.get(key)
	if cached == null:
		var width := 0
		for ch in value:
			var glyph: Dictionary = game.j_FONT.get(ch, game.j_FONT["?"])
			width += (maxi(int(glyph.w), 4) if m else int(glyph.w)) + 1
		cached = Canvas.new()
		cached.width = maxi(1, width) + 2
		cached.height = 10
		cached.ensure()
		var kc: Color = Canvas.parse_color(str(kenar))
		if cerceve:
			for dy in [-1, 0, 1]:
				for dx in [-1, 0, 1]:
					if dx != 0 or dy != 0: _str_yaz(cached, value, kc, m, 1 + dx, 1 + dy)
		else:
			_str_yaz(cached, value, kc, m, 2, 2)
		_str_yaz(cached, value, Canvas.parse_color(str(color)), m, 1, 1)
		if hd: cached = _epx(cached)
		if string_cache.size() > 1024: string_cache.clear()
		string_cache[key] = cached
	var sf: float = J.n(scale_value) if scale_value != null else 1.0
	draw_context.drawImage(cached, J.n(x) - sf, J.n(y) - sf, float(cached.get_meta("lw", cached.width)) * sf, float(cached.get_meta("lh", 10)) * sf)

func f_asinF(value: Variant = null) -> Variant:
	return game.j_ASIN_LUT[clampi(int((value + 1) * 512), 0, 1024)]
func f_coneProfile(ty: Variant = null) -> Variant:
	if ty < .09:
		var u: float = ty / .09
		return .52 + .44 * u * u * (3 - 2 * u)
	if ty < .62: return .96 + .04 * sin((ty - .09) / .53 * PI)
	var k: float = (ty - .62) / .38
	return maxf(.10, 1 - k * k * .90)
func f_hash1(value: Variant = null) -> Variant:
	var result: float = sin(value * 127.1) * 43758.5453
	return result - floor(result)
func f_meatCol(roast: Variant = null, shade: Variant = null) -> Variant:
	var s: float = 1.0 if shade == null else float(shade)
	var key: int = (int(roast * 160) << 10) + int(s * 160)
	if not meat_cache.has(key): meat_cache[key] = f_meatColCalc(roast, s)
	return meat_cache[key]
func f_meatColQ(k: Variant = null) -> Variant:
	var key: int = int(k)
	if not meat_quantized.has(key): meat_quantized[key] = f_meatCol(float(int(key / 40.0)) / 15.0, (key % 40) / 12.0)
	return meat_quantized[key]
func f_meatColCalc(roast: Variant = null, shade: Variant = null) -> Variant:
	var c: Vector3
	if roast < .34: c = Vector3(233, 158, 136).lerp(Vector3(242, 180, 104), roast / .34)
	elif roast < .78: c = Vector3(242, 180, 104).lerp(Vector3(208, 138, 64), (roast - .34) / .44)
	elif roast < 1.0: c = Vector3(208, 138, 64).lerp(Vector3(158, 92, 40), (roast - .78) / .22)
	else: c = Vector3(158, 92, 40).lerp(Vector3(58, 42, 30), minf(1, (roast - 1) / .35))
	c *= 1.0 if shade == null else float(shade)
	return "rgb(%d,%d,%d)" % [int(floor(clampf(c.x, 0, 255) + .5)), int(floor(clampf(c.y, 0, 255) + .5)), int(floor(clampf(c.z, 0, 255) + .5))]

func _exit_tree() -> void:
	if gpu_enabled: screen_canvas.release()
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
			child.stream = null
	audio_loops.clear()
	audio_streams.clear()
	synth_cache.clear()
	string_cache.clear()
	native_timers.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
