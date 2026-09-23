# YENI TEZGAHIN HD GORSELLERI (remake). counter_design.gd onayli yerlesimi ve
# durum mantigini (LED rengi, doluluk, kayma, kesim sallanmasi) aynen korur;
# HD acikken govdeler Blender parcalariyla (blender/models/tezgah2_hd.py,
# atlas "tezgah2") cizilir. HD kapaliysa ya da parca yoksa super cagrilir,
# yani onayli prosedurel cizim degismeden calisir.
# Rastgele cagri yok: tasarim zaten oyunun rastgeleligini kullanmiyor.
extends "res://scripts/counter_design.gd"

func _t2() -> Dictionary:
	return atlas("tezgah2")

func t2_hd() -> bool:
	return counter_design_enabled and hd("tezgah2") and not _t2().is_empty()

# tema 0 celigi tasarimda #91999b; diger temalar j_COUNTER_PAL[tema].base.
# Celik parca #91999b tonunda render edildi -> oran modulate olarak basilir.
func _celik_renk() -> Color:
	var tema := counter_theme()
	if tema == 0: return Color.WHITE
	var b := Color(str(j_COUNTER_PAL[tema].base))
	var o := Color("#91999b")
	return Color(b.r / o.r, b.g / o.g, b.b / o.b)

func f_drawCounter() -> Variant:
	if not t2_hd(): return super.f_drawCounter()
	var A := _t2()
	hd_ciz(A, "tezgah_celik", 0.0, 0.0, 1.0, false, _celik_renk())
	hd_ciz(A, "tezgah_ust", 0.0, 0.0)
	hd_ciz(A, "tezgah_alt", 0.0, 0.0)
	return null

func f_drawCounterProps(time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCounterProps(time)
	hd_ciz(_t2(), "servis", 0.0, 0.0)
	if shop_background.f_dayiVar() and (j_G.courier == null or j_G.courier.state == "in"):
		j_ctx.save()
		j_ctx.translate(4,130)
		j_ctx.scale(0.82,0.82)
		game_sprites_chef(time)
		j_ctx.restore()
	return null

# counter_design.f_drawChef bos doner (Dayi tezgah ONUNDE ciziliyor); asil
# cizim game_sprites -> game.gd zincirinde
func game_sprites_chef(time: Variant) -> void:
	chef_draw.f_drawChef(0, 0, j_G.chef, time)

# LED: tasarimdaki durum rengi, HD'de ic parlama + ust isik
func _led(x: float, y: float, w: float, h: float, renk: String) -> void:
	f_fr(x, y, w, h, renk)
	var c := Color(renk)
	if c.v > 0.45:
		draw_context.rect_hd(x * 2.0 + 1.0, y * 2.0 + 1.0, w * 2.0 - 3.0, 1.0, c.lightened(0.55))
		draw_context.globalAlpha = 0.25
		draw_context.rect_hd(x * 2.0 - 1.0, y * 2.0 - 1.0, w * 2.0 + 2.0, h * 2.0 + 2.0, c)
		draw_context.globalAlpha = 1.0

func f_drawPreparation(time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPreparation(time)
	var st: Dictionary = j_ST.board
	hd_ciz(_t2(), "tahta", st.x, st.y)
	var count: int = tun_design("boards")
	var scale_value := 1.8 if count == 1 else (1.22 if count == 2 else 0.9)
	for i in count:
		var cx: float = wrap_system.f_boardCX(i)
		if count > 1:
			if i == int(j_G.act):
				# secili bolum: ince altin cizgi + yumusak parilti
				draw_context.globalAlpha = 0.35
				f_hl(cx - 17, st.y + st.h - 8, 34, "#f3d896")
				draw_context.globalAlpha = 1.0
				draw_context.rect_hd((cx - 17) * 2.0, (st.y + st.h - 7) * 2.0, 68.0, 1.0, Color("#f3d896"))
			if i > 0:
				# bolme cizgisi: oluk (koyu) + alt kenar isigi
				var bx: float = st.x + i * st.w / count
				draw_context.rect_hd(bx * 2.0, (st.y + 5) * 2.0, 1.0, (st.h - 16) * 2.0, Color("#a27440"))
				draw_context.rect_hd(bx * 2.0 + 1.0, (st.y + 5) * 2.0, 1.0, (st.h - 16) * 2.0, Color("#e3bb82"))
		var item: Variant = j_G.boards[i]
		if item == null: continue
		var cy: float = wrap_system.f_boardCY() - sin(float(item.get("pop", 0)) * PI) * 2
		match item.kind:
			"pide": plate_draw.f_drawPideBoard(cx, cy, item, time, scale_value)
			"plate": plate_draw.f_drawPlate(cx, cy, item, time, scale_value)
			_:
				if item.state == "open": wrap_draw.f_drawWrapOpen(cx, cy, item, time, scale_value)
				else: wrap_draw.f_drawWrapRolled(cx, cy, item, time, scale_value)
	return null

func f_drawBreadStack(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, label: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawBreadStack(x, y, w, h, label)
	if not tun_design("iskOn"):
		hd_ciz(_t2(), "altlik", x, y + 3)
	# counter_design'in super cagrisiyla (game_sprites -> HD lavas) ayni yer
	if f_hdLavas(x + 2, y - 1, w - 4, h, ""): return null
	return super.f_drawBreadStack(x, y, w, h, label)

func f_drawPideStack(x: Variant = null, y: Variant = null, w: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPideStack(x, y, w)
	hd_ciz(_t2(), "altlik", x, y + 3)
	if f_hdPide(x, y, w): return null
	return super.f_drawPideStack(x, y, w)

func f_drawPaperStation(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, level: Variant = null, busy: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPaperStation(x, y, w, h, level, busy, time)
	if float(level) > 0:
		hd_ciz(_t2(), "kagit_makine", x, y)
		_led(x + 3, y + 3, 3, 3, "#e79d38" if float(busy) > 0 else "#8abc65")
		if float(level) > 1: _led(x + w - 7, y + 3, 4, 3, "#1e413d")
		return null
	hd_ciz(_t2(), "kagit_yigin", x, y)
	return null

func f_drawFryer(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, state: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawFryer(x, y, w, h, state, time)
	var A := _t2()
	hd_ciz(A, "fritoz_govde", x, y)
	if state.state != "idle":
		for i in 14:
			var px: float = x + 10 + fmod(i * 7.0, w - 22)
			var py: float = y + 15 + fmod(i * 3.0, maxf(1, h - 31))
			f_fryStick(px, py, 1.0, float(i), 1.0)
	if state.state == "fry":
		# kabarcik: yarim piksel, yukselip sonen parlak nokta
		for i in 5:
			var ky: float = fmod(float(time) * 12 + i * 5, 9)
			draw_context.globalAlpha = 1.0 - ky / 10.0
			draw_context.rect_hd((x + 12 + i * 6) * 2.0, (y + 15 + ky) * 2.0, 2.0, 2.0, Color("#f6dc80"))
			draw_context.rect_hd((x + 12 + i * 6) * 2.0, (y + 15 + ky) * 2.0, 1.0, 1.0, Color("#fff6d6"))
		draw_context.globalAlpha = 1.0
	hd_ciz(A, "fritoz_kol", x, y)
	_led(x + 7, y + h - 8, 5, 4, "#86c966" if state.state == "done" else ("#e66e38" if state.state == "fry" else "#3f5545"))
	return null

func f_drawGrill(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, state: Variant = null, time: Variant = null, capacity: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawGrill(x, y, w, h, state, time, capacity)
	hd_ciz(_t2(), "izgara_govde", x, y)
	_led(x + 6, y + h - 8, 4, 4, "#78b856" if not state.slots.is_empty() else "#42584b")
	return null

func f_drawCutBoard(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, state: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCutBoard(x, y, w, h, state, time)
	var A := _t2()
	hd_ciz(A, "kesme_tahta", x, y)
	if state.potato:
		hd_ciz(A, "patates_butun", x + w / 2, y + h / 2)
		if state.prog > 0: counter_draw.f_bar(x + 5, y + h - 6, w - 10, 3, state.prog, "#eacf88")
	elif state.raw > 0:
		for i in mini(12, int(state.raw) * 2):
			var px: float = x + 10 + fmod(i * 7.0, w - 31)
			var py: float = y + 12 + fmod(i * 5.0, h - 21)
			ingredient_pixels.f_fryBar(px, py, 11.0, 0.25 if i % 2 else -0.25, 0.2, "#fff6d0", "#f2e0a8", "#dcc681", "#e8d59a")
	var cy: float = y + h / 2 + (sin(float(time) * 25) * 3 if state.cutting else 0)
	hd_ciz(A, "satir", x + w - 12, f_hdYarimPx(cy - 6))
	return null

func f_drawPotatoBin(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPotatoBin(x, y, w, h, time)
	hd_ciz(_t2(), "patates_kasa", x, y)
	return null

func f_drawCrate(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, opened: Variant = null, time: Variant = null, progress: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCrate(x, y, w, h, opened, time, progress)
	var shift := J.n(progress) * 4
	hd_ciz(_t2(), "stok", x, f_hdYarimPx(y - shift))
	return null

func f_drawTrash(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, time: Variant = null, emptying: Variant = null, fullness: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawTrash(x, y, w, h, time, emptying, fullness)
	hd_ciz(_t2(), "cop", x, y)
	if J.n(fullness) > 0:
		for i in mini(5, int(fullness)): f_fr(x + 6 + i * 3, y + 3 + (i % 2), 3, 2, "#c9b482")
	if J.n(emptying) > 0: f_hl(x + 7, y + h - 3, w - 14, "#e4d38e")
	return null

func f_drawSauceStation(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, on: Variant = null, isk: Variant = null, fx: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawSauceStation(x, y, w, h, on, isk, fx, time)
	var A := _t2()
	for i in 3:
		if not J.truth(isk if i == 2 else on): continue
		var bottle: Dictionary = j_SAUCE_DEF[i]
		var cx: float = x + (i + .5) * w / 3
		var lift: float = round(sin(clampf(float(fx.get(bottle.id, 0)) if fx is Dictionary else 0.0, 0, 1) * PI) * 2)
		draw_context.globalAlpha = 0.45
		f_ell(cx, y + h - 2, 6, 2, "#4f5a5c")
		draw_context.globalAlpha = 1.0
		hd_ciz(A, "sise_%d" % i, cx, y + h - 2 - lift)
	return null

func f_drawIcecekKasasi(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, divisions: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawIcecekKasasi(x, y, w, h, divisions, time)
	var A := _t2()
	var taps: Array = drink_system.f_icecekMusluklari()
	hd_ciz(A, "icecek_govde", x, y)
	var n := clampi(taps.size(), 1, 3)
	for i in taps.size():
		var type: String = taps[i]
		var cx: float = x + (i + .5) * w / taps.size()
		var segment: float = w / taps.size() - 4
		var tip: String = type if type in ["fanta", "cola", "ayran"] else "ayran"
		hd_ciz(A, "musluk_%d_%s" % [n, tip], f_hdYarimPx(cx - segment / 2), y + 4)
		if j_G.drinkM is Dictionary and j_G.drinkM.pours.get(type) != null:
			var color: String = {"fanta": "#e59a32", "cola": "#a83e2d", "ayran": "#c9dcc6"}.get(type, "#c9dcc6")
			# akis: 1.5 px genis, kenarda parlak dalga (yarim piksel)
			for sy in range(32, 43):
				draw_context.rect_hd((cx - 0.5) * 2.0, (y + sy) * 2.0, 3.0, 2.0, Color(color))
				if sin(float(time) * 20 + sy) > 0:
					draw_context.rect_hd((cx - 0.5) * 2.0, (y + sy) * 2.0, 1.0, 2.0, Color("#f1d5a0" if type != "ayran" else "#fff7e3"))
	return null

func f_drawSweetTray(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, n: Variant = null, maximum: Variant = null, time: Variant = null, fx: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawSweetTray(x, y, w, h, n, maximum, time, fx)
	f_trayBase(x, y, w, h)
	# serbet zemini: kuvetin ici (yarim piksel icerden)
	draw_context.rect_hd((x + 3.5) * 2.0, (y + 4) * 2.0, (w - 7) * 2.0, (h - 7) * 2.0, Color("#80602e"))
	draw_context.rect_hd((x + 3.5) * 2.0, (y + 4) * 2.0, (w - 7) * 2.0, 1.0, Color("#a07a3c"))
	var count: int = ceili(clampf(float(n) / maxf(1, float(maximum)), 0, 1) * 4)
	var B := atlas("istasyon")
	for i in count:
		var bx: float = x + 10 + (i % 2) * 14
		var by: float = y + 9 + int(i / 2) * 9
		if B.is_empty(): garnish_draw.f_drawBaklava(bx, by)
		else: hd_ciz(B, "baklava", bx, by)
	f_trayInnerShade(x, y, w, h)
	f_trayFlash(x, y, w, h, J.n(fx))
	return null
