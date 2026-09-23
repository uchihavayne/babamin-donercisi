# Editable sprite overrides. Original gameplay and procedural artwork remain in game.gd.
extends "res://scripts/game.gd"
const SpriteLibrary = preload("res://scripts/sprite_library.gd")
var sprite_library := SpriteLibrary.new()
var sprites_enabled := true
var customer_cache: Dictionary = {}
var yogurt_cache: Dictionary = {}
var baking_customer := false
var baking_yogurt := false

func f_trayFlash(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, fx: Variant = null) -> Variant:
	if baking_yogurt: return null
	return super.f_trayFlash(x,y,w,h,fx)

func f_chance(probability: Variant = null) -> Variant:
	# Particle emission is performed once per displayed frame outside the sprite bake.
	if baking_customer: return false
	return super.f_chance(probability)

func f_drawCustomer(customer: Variant = null, time: Variant = null) -> Variant:
	# REMAKE: HD'de onbellek sprite yerine canli (HD kancali) cizim
	if not sprites_enabled or hd_gpu() or J.truth(j_OZEL_ACIK) or float(j_ctx.globalAlpha) != 1.0:
		return super.f_drawCustomer(customer,time)
	var look: Dictionary = customer.look
	appearance_system.f_yuzKimlik(look)
	appearance_system.f_kalipKimlik(look)
	var t: float = time
	var seed_value: float = look.seed
	var angry: bool = customer.mood == "angry"
	var happy: bool = customer.mood == "happy" or customer.mood == "served"
	var walking: bool = customer.state == "walkin" or customer.state == "leave"
	var bob := sin(t*2+seed_value)*(1.7 if angry else .8)
	var jitter := floorf(sin(t*26)+.5) if angry else 0.0
	var jump := -absf(sin(t*8))*2 if happy else 0.0
	var sway := sin(t*11)*1.2 if walking else 0.0
	var x := floorf(float(customer.x)+jitter+sway+.5)
	var y := floorf(float(customer.y)+bob+jump+.5)
	var impatient: bool = customer.get("patience") != null and float(customer.patience)<.35 and not happy
	var blink: bool = f_hash1(floorf(t*1.6)+seed_value)>.92
	var gaze := 1.0 if angry else floorf(sin(t*.8+seed_value)+.5)
	var vein := sin(t*8)>0
	var key := JSON.stringify([look,customer.mood,customer.state=="wait",impatient,blink,gaze,vein])
	var cached: Variant = customer_cache.get(key)
	if cached == null:
		var canvas := Canvas.new(); canvas.width=128; canvas.height=128; canvas.ensure()
		var previous: Variant = j_ctx
		j_ctx=canvas
		var pose: Dictionary = customer.duplicate()
		pose.x=64.0-jitter-sway; pose.y=96.0-bob-jump
		baking_customer=true
		super.f_drawCustomer(pose,time)
		baking_customer=false
		j_ctx=previous
		cached=canvas
		if customer_cache.size()>=256: customer_cache.erase(customer_cache.keys()[0])
		customer_cache[key]=cached
	j_ctx.drawImage(cached,x-64,y-96)
	var tip: String = look.get("tip", "")
	if tip.is_empty():
		var value: float = f_hash1(seed_value*2.3)
		tip="adam" if value<.42 else ("kadin" if value<.8 else "cocuk")
	var hy := y-42+(11 if tip=="cocuk" else 0)
	if angry and f_chance(.05): effects.f_smoke(x+math_utils.f_rnd(-11,11),hy-13,1,"rgba(230,90,60,.55)")
	if customer.mood=="served" and f_chance(.06):
		effects.f_part({"x":x+math_utils.f_rnd(-9,9),"y":hy-10,"vx":math_utils.f_rnd(-6,6),"vy":math_utils.f_rnd(-24,-12),"life":.9,"col":"#e2483a","g":-8,"sz":2.0})
	return null

func f_drawYogurtTray(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, n: Variant = null, maximum: Variant = null, time: Variant = null, fx: Variant = null) -> Variant:
	# Time is unused by this original drawing; retain the exact stock and bounce values.
	if not sprites_enabled or hd_gpu() or float(j_ctx.globalAlpha)!=1.0 or float(n)<=0: return super.f_drawYogurtTray(x,y,w,h,n,maximum,time,fx)
	var level := clampf(float(n)/float(maximum),0,1)
	var bump := int(floorf(sin(J.n(fx)*PI)*2+.5))
	var key := str([w,h,level,bump])
	var cached: Variant = yogurt_cache.get(key)
	if cached == null:
		var canvas := Canvas.new(); canvas.width=int(w)+8; canvas.height=int(h)+16; canvas.ensure()
		var previous: Variant = j_ctx; j_ctx=canvas
		# Bake without the short white flash; draw that overlay live below.
		baking_yogurt=true
		super.f_drawYogurtTray(4.0,8.0,w,h,n,maximum,0.0,fx)
		baking_yogurt=false
		j_ctx=previous
		cached=canvas
		if yogurt_cache.size()>=128: yogurt_cache.erase(yogurt_cache.keys()[0])
		yogurt_cache[key]=cached
	j_ctx.drawImage(cached,int(x)-4,int(y)-8)
	f_trayFlash(x,y,w,h,J.n(fx))
	return null

func sprite(key: String, x: float, y: float) -> bool:
	# REMAKE: PNG sprite'lar prosedurel cizimin pisirilmis kopyasi; HD'de kancali
	# prosedurel yol calissin (HD parca yoksa goruntu ayni)
	return sprites_enabled and not hd_gpu() and float(j_ctx.globalAlpha) == 1.0 and sprite_library.draw(j_ctx, key, x, y)

func f_trayBase(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null) -> Variant:
	if sprite("f_trayBase/%dx%d" % [w,h], x,y): return null
	return super.f_trayBase(x,y,w,h)

func f_trayInnerShade(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null) -> Variant:
	if sprite("f_trayInnerShade/%dx%d" % [w,h], x,y): return null
	return super.f_trayInnerShade(x,y,w,h)

func f_drawBreadStack(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, label: Variant = null) -> Variant:
	if not sprite("bread/%d" % w,x,y): return super.f_drawBreadStack(x,y,w,h,label)
	if label != "": text_draw.f_txt(label if J.truth(label) else "LAVAŞ",x+w/2.0,y+30,"rgba(255,255,255,.55)",{"align":"c","outline":"rgba(0,0,0,.4)"})
	return null

func f_drawPideStack(x: Variant = null, y: Variant = null, w: Variant = null) -> Variant:
	if sprite("pide/%d" % w,x,y): return null
	return super.f_drawPideStack(x,y,w)

func f_potBinPaint(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null) -> Variant:
	if sprite("potato/%dx%d" % [w,h],x,y): return null
	return super.f_potBinPaint(x,y,w,h)

func f_drawKesimBicagi(x: Variant = null, y: Variant = null, direction: Variant = null, level: Variant = null) -> Variant:
	if sprite("knife/%d/%d" % [J.n(level),J.n(direction)],x,y): return null
	return super.f_drawKesimBicagi(x,y,direction,level)

func f_drawSpitCutKnife(x: Variant = null, y: Variant = null, level: Variant = null) -> Variant:
	j_ctx.globalAlpha = 0.3
	f_fr(x - 2.0, y - 9.0, 3.0, 16.0, "#dfe6ec")
	j_ctx.globalAlpha = 1.0
	return f_drawKesimBicagi(x, y, -1.0, level)

func f_drawFill(x: Variant = null, y: Variant = null, w: Variant = null, h: Variant = null, level: Variant = null, seed_value: Variant = null, item: Variant = null) -> Variant:
	var q := int(floorf(clampf(float(level),0,1)*40+.5))
	var key := "fill/%dx%d/%.1f/%d" % [w,h,seed_value,q]
	# Guard the callback as well, so custom recipe code can still supply a different drawing.
	var expected := {1.3:"f_meatStrip",4.7:"f_pickleSlice",9.2:"f_fryStick"}
	if expected.has(seed_value) and item is Dictionary and item.get("__fn") is Callable and item.__fn.get_method() == expected[seed_value]:
		if sprite(key,int(x),int(y)): return int(y)+sprite_library.manifest[key].top
	return super.f_drawFill(x,y,w,h,level,seed_value,item)

func f_proKat(name: Variant = null, draw_callback: Variant = null) -> Variant:
	if sprites_enabled and not hd_gpu():
		var layer: Variant = sprite_library.get_sprite("story/"+str(name))
		if layer != null: return layer
	return super.f_proKat(name,draw_callback)

const SpitPixels = preload("res://scripts/spit_pixels.gd")
var spit_pixels := SpitPixels.new()

func f_drawSpit(p_sp: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE: HD'de kancali modul surumu (koni shader'i satir dongusunu atlar)
	if hd_gpu(): return spit_draw.f_drawSpit(p_sp, p_t)
	var v_cx: float = 0.0
	var v_top: float = 0.0
	var v_bot: float = 0.0
	var v_H0: float = 0.0
	var v_maxR: float = 0.0
	var v_hx: float = 0.0
	var v_hy: float = 0.0
	var v_hw: float = 0.0
	var v_hh: float = 0.0
	var v_i: float = 0.0
	var v_seg: float = 0.0
	var v_ey: float = 0.0
	var v_fl: float = 0.0
	var v_mass: float = 0.0
	var v_scaleR: float = 0.0
	var v_coneTop: float = 0.0
	var v_coneH: float = 0.0
	var v_y: float = 0.0
	var v_ty: float = 0.0
	var v_rjit: float = 0.0
	var v_r: float = 0.0
	var v_yy: float = 0.0
	var v_cutAmt: float = 0.0
	var v_lay: float = 0.0
	var v_layM: float = 0.0
	var v_runK: float = 0.0
	var v_runX: float = 0.0
	var v_x: float = 0.0
	var v_nx: float = 0.0
	var v_n01: float = 0.0
	var v_shade: float = 0.0
	var v_ang: float = 0.0
	var v_seam: float = 0.0
	var v_lroast: float = 0.0
	var v_k: float = 0.0
	var v_x2: float = 0.0
	var v_gx2: float = 0.0
	var v_bx2: float = 0.0
	var v_yc: float = 0.0
	var v_rr: float = 0.0
	var v_ca: float = 0.0
	var v_topR: float = 0.0
	var v_rx0: float = 0.0
	var v_rv: float = 0.0
	var v_wa: float = 0.0
	var v_ph: float = 0.0
	var v_tri: float = 0.0
	var v_cy2: float = 0.0
	var v_kt: float = 0.0
	var v_ky: float = 0.0
	var v_kx: float = 0.0
	var v_sp: Dictionary = p_sp
	var v_t: float = p_t
	v_cx = j_LAY["spit"]["cx"]
	v_top = j_LAY["spit"]["top"]
	v_bot = j_LAY["spit"]["bot"]
	v_H0 = (v_bot - v_top)
	v_maxR = 19.0
	v_hx = (v_cx + 19.0)
	v_hy = (v_top + 2.0)
	v_hw = 17.0
	v_hh = (v_H0 - 14.0)
	f_fr((v_hx - 1.0), (v_hy - 1.0), (v_hw + 2.0), (v_hh + 2.0), j_P["mt4"])
	f_fr(v_hx, v_hy, v_hw, v_hh, j_P["mt2"])
	f_fr((v_hx + 2.0), (v_hy + 2.0), (v_hw - 4.0), (v_hh - 4.0), "#241610")
	f_hl(v_hx, v_hy, v_hw, j_P["mt0"])
	f_vl(v_hx, v_hy, v_hh, j_P["mt1"])
	f_hl(v_hx, ((v_hy + v_hh) - 1.0), v_hw, j_P["mt5"])
	v_i = 0.0
	while (v_i < 6.0):
		v_seg = floorf((float((v_hh - 8.0)) / float(6.0)))
		v_ey = ((v_hy + 4.0) + (v_i * v_seg))
		v_fl = (0.55 + (0.45 * sin(((v_t * 6.0) + (v_i * 1.9)))))
		f_fr((v_hx + 3.0), v_ey, (v_hw - 6.0), (v_seg - 3.0), "#6d1a08")
		f_fr((v_hx + 3.0), v_ey, (v_hw - 6.0), (v_seg - 4.0), ("#c8380f" if J.truth(fmod(J.n(v_i), J.n(2.0))) else "#e0500f"))
		J.setv(j_ctx, "globalAlpha", (0.3 + (0.4 * v_fl)))
		f_fr((v_hx + 4.0), (v_ey + 1.0), (v_hw - 8.0), max(1.0, (v_seg - 5.0)), "#ff9c2e")
		J.setv(j_ctx, "globalAlpha", (0.25 + (0.3 * v_fl)))
		f_fr((v_hx + 5.0), (v_ey + 1.0), (v_hw - 10.0), max(1.0, (v_seg - 6.0)), "#ffe08a")
		J.setv(j_ctx, "globalAlpha", 1.0)
		if J.truth(f_chance(0.014)):
			effects.f_part({"x": (v_hx + math_utils.f_rnd(3.0, (v_hw - 3.0))), "y": v_ey, "vx": math_utils.f_rnd((-J.n(4.0)), 2.0), "vy": math_utils.f_rnd((-J.n(30.0)), (-J.n(14.0))), "life": math_utils.f_rnd(0.3, 0.8), "col": math_utils.f_pick([j_P["f1"], j_P["f2"], j_P["f0"]]), "g": (-J.n(16.0)), "sz": 1.0})
		v_i = (v_i + 1.0)
	J.setv(j_ctx, "globalAlpha", (0.1 + (0.045 * sin((v_t * 5.0)))))
	f_fr((v_cx - 4.0), v_top, 26.0, v_H0, "#ff8a2a")
	J.setv(j_ctx, "globalAlpha", 1.0)
	counter_draw.f_heatShimmer((v_cx + 8.0), (v_top + 6.0), 18.0, (v_H0 - 12.0), v_t)
	f_vl((v_cx - 1.0), (v_top - 12.0), (v_H0 + 16.0), j_P["mt4"])
	f_vl(v_cx, (v_top - 12.0), (v_H0 + 16.0), j_P["mt1"])
	f_vl((v_cx + 1.0), (v_top - 12.0), (v_H0 + 16.0), j_P["mt3"])
	f_fr((v_cx - 5.0), (v_top - 15.0), 11.0, 4.0, j_P["mt3"])
	f_hl((v_cx - 5.0), (v_top - 15.0), 11.0, j_P["mt0"])
	f_fr((v_cx - 8.0), (v_top - 19.0), 17.0, 4.0, j_P["mt2"])
	f_hl((v_cx - 8.0), (v_top - 19.0), 17.0, j_P["mt0"])
	f_hl((v_cx - 8.0), (v_top - 16.0), 17.0, j_P["mt4"])
	f_vl(v_cx, 0.0, (v_top - 18.0), j_P["mt3"])
	f_vl((v_cx + 1.0), 0.0, (v_top - 18.0), j_P["mt4"])
	v_mass = math_utils.f_clamp(v_sp["mass"], 0.0, 1.0)
	v_scaleR = (0.45 + (0.55 * v_mass))
	v_coneTop = (v_top + floorf(((1.0 - v_mass) * 10.0) + 0.5))
	v_coneH = (v_H0 - floorf(((1.0 - v_mass) * 18.0) + 0.5))
	J.setv(j_ctx, "globalAlpha", 0.3)
	f_ell((v_cx + 2.0), (v_bot + 3.0), 15.0, 4.0, "#000")
	J.setv(j_ctx, "globalAlpha", 1.0)
	spit_pixels.draw_rows(self, v_sp, v_coneH, v_scaleR, v_cx, v_coneTop)
	if (v_sp["cutDepth"] > 0.0):
		v_yc = 10.0
		while (v_yc < (v_coneH * 0.8)):
			v_rr = max(1.0, floorf(((v_maxR * v_scaleR) * f_coneProfile((float(v_yc) / float(v_coneH)))) + 0.5))
			v_ca = floorf((v_sp["cutDepth"] * (1.0 - abs(((float(v_yc) / float(v_coneH)) - 0.45)))) + 0.5)
			if (v_ca > 0.0):
				f_px(((v_cx - v_rr) + v_ca), (v_coneTop + v_yc), f_meatCol((v_sp["roast"] * 0.22), 1.15))
				f_px((((v_cx - v_rr) + v_ca) + 1.0), (v_coneTop + v_yc), f_meatCol((v_sp["roast"] * 0.34), 0.98))
			v_yc = (v_yc + 1.0)
	v_topR = floorf(((v_maxR * v_scaleR) * f_coneProfile(0.02)) + 0.5)
	f_ell(v_cx, (v_coneTop + 1.0), (v_topR - 1.0), 3.0, "#a8302a")
	f_ell(v_cx, v_coneTop, (v_topR - 1.0), 3.0, "#d8443a")
	f_ell((v_cx - 2.0), (v_coneTop - 1.0), max(2.0, (v_topR - 5.0)), 1.0, "#f2887a")
	f_px((v_cx + 3.0), (v_coneTop - 2.0), j_P["g2"])
	f_px((v_cx + 4.0), (v_coneTop - 3.0), j_P["g1"])
	f_fr((v_cx - 9.0), (v_bot - 3.0), 19.0, 3.0, j_P["mt4"])
	f_hl((v_cx - 9.0), (v_bot - 3.0), 19.0, j_P["mt1"])
	f_ell(v_cx, (v_bot + 2.0), 13.0, 4.0, j_P["mt4"])
	f_ell(v_cx, (v_bot + 1.0), 13.0, 4.0, j_P["mt1"])
	f_ell(v_cx, (v_bot + 1.0), 10.0, 2.0, j_P["mt2"])
	f_ell((v_cx + 1.0), (v_bot + 2.0), 7.0, 1.0, "#9a6a1e")
	if J.truth(f_chance(0.02)):
		effects.f_part({"x": (v_cx + math_utils.f_rnd((-J.n(4.0)), 4.0)), "y": (v_bot - 4.0), "vx": 0.0, "vy": 20.0, "life": 0.5, "col": "#c08a2a", "g": 90.0, "sz": 1.0, "floor": (v_bot + 1.0)})
	if (((J.kind(j_TUN) != "undefined") and J.truth(j_G["up"])) and J.truth(J.method(j_TUN, "autoShave", [j_G]))):
		v_rx0 = ((v_cx - floorf((v_maxR * v_scaleR) + 0.5)) - 12.0)
		f_fr(v_rx0, (v_top - 6.0), 4.0, (v_H0 + 14.0), "#3a4048")
		f_fr((v_rx0 + 1.0), (v_top - 6.0), 2.0, (v_H0 + 14.0), "#6b737d")
		v_rv = 0.0
		while (v_rv < (v_H0 + 10.0)):
			f_px((v_rx0 + 1.0), ((v_top - 4.0) + v_rv), "#98a0a9")
			v_rv = (v_rv + 8.0)
		f_fr((v_rx0 - 7.0), (v_top - 16.0), 16.0, 12.0, "#2f3740")
		f_fr((v_rx0 - 6.0), (v_top - 16.0), 14.0, 11.0, "#59636d")
		f_hl((v_rx0 - 6.0), (v_top - 16.0), 14.0, "#8b959e")
		v_wa = (v_t * 9.0)
		f_disc((v_rx0 + 1.0), (v_top - 10.0), 4.0, "#3a4048")
		f_disc((v_rx0 + 1.0), (v_top - 10.0), 3.0, "#98a0a9")
		f_ln((v_rx0 + 1.0), (v_top - 10.0), ((v_rx0 + 1.0) + (cos(v_wa) * 3.0)), ((v_top - 10.0) + (sin(v_wa) * 3.0)), "#2f3740")
		f_px((v_rx0 - 4.0), (v_top - 13.0), ("#7dff7a" if J.truth(f_chance(0.5)) else "#2a6a28"))
		v_ph = ((float((j_G["shave"]["auto"] if J.truth(j_G["shave"]["auto"]) else 0.0)) / float(0.55)) if J.truth(j_G["shave"]) else 0.0)
		v_tri = ((v_ph * 2.0) if (v_ph < 0.5) else ((1.0 - v_ph) * 2.0))
		v_cy2 = floorf(math_utils.f_lerp((v_top + 10.0), (v_bot - 18.0), math_utils.f_clamp(v_tri, 0.0, 1.0)) + 0.5)
		f_fr((v_rx0 - 4.0), (v_cy2 - 5.0), 12.0, 11.0, "#59636d")
		f_fr((v_rx0 - 3.0), (v_cy2 - 5.0), 10.0, 10.0, "#8b959e")
		f_hl((v_rx0 - 3.0), (v_cy2 - 5.0), 10.0, "#c6ccd2")
		f_fr((v_rx0 - 5.0), (v_cy2 - 1.0), 3.0, 3.0, "#2f3740")
		f_fr((v_rx0 + 7.0), (v_cy2 - 1.0), 14.0, 3.0, "#c9d2da")
		f_fr((v_rx0 + 7.0), (v_cy2 - 1.0), 14.0, 2.0, "#eef4f8")
		f_hl((v_rx0 + 7.0), (v_cy2 - 1.0), 14.0, "#ffffff")
		f_px((v_rx0 + 21.0), v_cy2, "#ffffff")
		if J.truth(f_chance(0.25)):
			effects.f_part({"x": (v_rx0 + 20.0), "y": (v_cy2 + math_utils.f_rnd((-J.n(2.0)), 2.0)), "vx": math_utils.f_rnd((-J.n(26.0)), (-J.n(6.0))), "vy": math_utils.f_rnd((-J.n(18.0)), 4.0), "life": 0.35, "col": math_utils.f_pick(["#c98436", "#eeb464"]), "g": 240.0, "sz": 1.0, "floor": (j_ST["meat"]["y"] + math_utils.f_rnd(4.0, 12.0))})
	if (v_sp["sliceT"] > 0.0):
		v_kt = (1.0 - v_sp["sliceT"])
		v_ky = ((v_coneTop + 10.0) + (v_kt * (v_coneH - 26.0)))
		v_kx = ((v_cx - floorf((v_maxR * v_scaleR) + 0.5)) - 3.0)
		f_drawSpitCutKnife((v_kx + 4.0), (v_ky + 1.0), (equipment_system.f_UV(j_G, "knife") if (J.kind(J.ref(equipment_system.f_UV, 2)) == "function") else 0.0))
		if J.truth(f_chance(0.5)):
			effects.f_part({"x": (v_kx + 4.0), "y": (v_ky + math_utils.f_rnd((-J.n(2.0)), 2.0)), "vx": math_utils.f_rnd((-J.n(40.0)), (-J.n(10.0))), "vy": math_utils.f_rnd((-J.n(20.0)), 10.0), "life": 0.3, "col": "#ffffff", "g": 60.0, "sz": 1.0})
	return null
