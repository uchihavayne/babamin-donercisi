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

# Dayi servis bolmesinde, tezgahin ONUNDE duruyor: donerin otomatik kesim rayi
# (sisin solu) bolmeye denk geliyor. Dayi sistan SONRA cizilir ki ray onun
# arkasinda kalsin (eskiden rayin ustune biniyordu).
var _dayi_sonra := false

func f_drawCounterProps(time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCounterProps(time)
	hd_ciz(_t2(), "servis", 0.0, 0.0)
	_dayi_sonra = shop_background.f_dayiVar() and (j_G.courier == null or j_G.courier.state == "in")
	return null

func f_drawSpit(p_sp: Variant = null, p_t: Variant = null) -> Variant:
	var sonuc: Variant = super.f_drawSpit(p_sp, p_t)
	if _dayi_sonra:
		_dayi_sonra = false
		j_ctx.save()
		j_ctx.translate(4,130)
		j_ctx.scale(0.82,0.82)
		game_sprites_chef(p_t)
		j_ctx.restore()
	return sonuc

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

# Ekmek altligi: yiginlar tabaksiz, altligin USTUNE oturur (tezgah2 ekmek_*).
# Iskender acikken game_draw once pide yiginini (f_drawPideStack), sonra
# lavasi ctx.translate(0, 12) icinde ciziyor: lavas parcasi o kaymayi geri alir.
func f_drawBreadStack(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, label: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawBreadStack(x, y, w, h, label)
	var A := _t2()
	if tun_design("iskOn"):
		hd_ciz(A, "ekmek_lavas_on", x, y - 12.0)
		return null
	hd_ciz(A, "altlik", x, y + 3)
	hd_ciz(A, "ekmek_lavas_tek", x, y)
	return null

func f_drawPideStack(x: Variant = null, y: Variant = null, w: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPideStack(x, y, w)
	var A := _t2()
	hd_ciz(A, "altlik", x, y + 3)
	hd_ciz(A, "ekmek_pide_arka", x, y)
	return null

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
	# Kullanici: onceki (remake) fritoz daha iyi -> ayni model 51x43 yuvada
	# (on camdan gorunen yag, sepet yagin icinde, ekranli panel)
	if f_hdFritoz(x, y, w, h, state, time): return null
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

# PATATES DOGRAMA (kullanici: "dumduz patates doguruyoruz, animasyon/efekt
# ekle"): remake'in kesim asamalari (patates sagdan kisalir, kesik yuzu acik),
# dogranan dilimler yanda birikir, oyunun kendi bicak izleri (C.slash) cizilir,
# satir kesim yuzune inip kalkar; darbe aninda kirintilar (zaman+hash, oyunun
# rastgele ureticisine dokunmaz). Hazir cig cubuklar tahtanin sagina dizilir.
func f_drawCutBoard(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, state: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCutBoard(x, y, w, h, state, time)
	var A := _t2()
	var TZ := atlas("tezgah")
	var T: float = float(time)
	hd_ciz(A, "kesme_tahta", x, y)
	# hazir cig cubuklar: sag tarafta duzgun yigin (en fazla 12)
	if state.raw > 0 and not TZ.is_empty():
		var n := mini(12, int(state.raw) * 2)
		for i in n:
			var sira := int(i / 6)
			hd_ciz(TZ, "cig_cubuk", x + 32.0 + (i % 6) * 2.6 - sira * 1.3, y + 22.0 - sira * 4.0)
	var satir_x: float = x + w - 12
	var satir_y: float = y + h / 2 - 6
	if state.potato and not TZ.is_empty():
		var prog: float = clampf(float(state.prog), 0.0, 1.0)
		var pw := clampi(int(maxf(2.0, floorf(11.0 * (1.0 - prog) + .5))), 2, 11)
		var ax: float = x + 17.0
		var ay: float = y + 19.0
		hd_ciz(TZ, "patates_%d" % pw, ax, ay)
		var kesik: float = ax - 11.0 + 2.0 * pw
		# dogranmis dilimler: kesik yuzun saginda, hafif egik dizilir
		for i in int(floorf(prog * 7.0)):
			hd_ciz(TZ, "patates_dilim", kesik + 3.0 + i * 2.6, ay - 5.0 + (i % 2) * 0.5)
		chopping_draw.f_drawSlash(state)
		if prog > 0: counter_draw.f_bar(x + 5, y + h - 6, w - 10, 3, prog, "#eacf88")
		if state.cutting:
			# dogrudan kesik yuze iner: hizli inis, kisa bekleme, yavas kalkis
			var p := fposmod(T * 5.0, 1.0)
			var yuk := (1.0 - p / 0.22) if p < 0.22 else (0.0 if p < 0.36 else (p - 0.36) / 0.64)
			satir_x = kesik + 0.5
			satir_y = y + 7.0 - yuk * 9.0
			if p >= 0.22 and p < 0.5:
				_dogrma_kirinti(kesik + 1.0, y + 17.0, (p - 0.22) / 0.28, floorf(T * 5.0))
	elif state.potato:
		hd_ciz(A, "patates_butun", x + w / 2, y + h / 2)
	hd_ciz(A, "satir", satir_x, f_hdYarimPx(satir_y))
	return null

# darbe kirintilari: 5 minik nisasta parcasi kesik yuzden disari savrulur
func _dogrma_kirinti(x: float, y: float, k: float, vurus: float) -> void:
	var ctx = draw_context
	ctx.globalAlpha = clampf(1.0 - k, 0.0, 1.0)
	for i in 5:
		var a: float = f_hash1(vurus * 3.7 + i * 1.9) * PI - PI
		var hiz: float = 4.0 + f_hash1(vurus * 5.1 + i) * 5.0
		var px: float = x + cos(a) * hiz * k
		var py: float = y + sin(a) * hiz * k * 0.7 + 6.0 * k * k
		ctx.rect_hd(roundf(px * 2.0), roundf(py * 2.0), 2.0, 1.0 + float(i % 2), Color("#f6ecc6") if i % 2 == 0 else Color("#dcc681"))
	ctx.globalAlpha = 1.0

func f_drawPotatoBin(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, time: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawPotatoBin(x, y, w, h, time)
	hd_ciz(_t2(), "patates_kasa", x, y)
	return null

# Depo cekmecesi: onunde ACIK olan butun stok turlerinin ikonu (kullanici:
# "yalniz iki sey varmis gibi gorunuyor"); cekmece acilirken kayar.
func f_drawCrate(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, opened: Variant = null, time: Variant = null, progress: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawCrate(x, y, w, h, opened, time, progress)
	var A := _t2()
	var shift := J.n(progress) * 4
	var yy: float = f_hdYarimPx(y - shift)
	hd_ciz(A, "stok_bos", x, yy)
	var turler: Array = ["pickle", "yogurt"]
	if tun_design("ayranOn"): turler.append("ayran")
	if tun_design("sweetOn"): turler.append("sweet")
	if tun_design("garnishOn"): turler.append_array(["tomato", "pepper"])
	var adim: float = minf(7.2, (w - 12.0) / maxf(1.0, turler.size() - 1.0))
	var x0: float = x + w / 2.0 - adim * (turler.size() - 1) / 2.0
	for i in turler.size():
		hd_ciz(A, "stok_ikon_%s" % turler[i], f_hdYarimPx(x0 + i * adim), yy + 24.5)
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

# Tatli: bakir baklava tepsisi + kalan sayiya gore 0..6 baklava dilimi
# (kullanici: "tatli tepsisini duzenle, yetersiz")
func f_drawSweetTray(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, n: Variant = null, maximum: Variant = null, time: Variant = null, fx: Variant = null) -> Variant:
	if not t2_hd(): return super.f_drawSweetTray(x, y, w, h, n, maximum, time, fx)
	var A := _t2()
	hd_ciz(A, "tatli_tepsi", x, y)
	var adet: int = ceili(clampf(float(n) / maxf(1, float(maximum)), 0, 1) * 6)
	var bump: float = roundf(sin(clampf(J.n(fx), 0.0, 1.0) * PI) * 2.0)
	for i in adet:
		hd_ciz(A, "baklava_dilim", x + 8 + (i % 3) * 9, y + 8 + int(i / 3) * 8 - bump)
	f_trayFlash(x, y, w, h, J.n(fx))
	return null
