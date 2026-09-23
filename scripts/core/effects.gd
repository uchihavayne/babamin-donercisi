# Effects. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# core.js:253
func f_shadowEll(p_cx: Variant = null, p_cy: Variant = null, p_rx: Variant = null, p_ry: Variant = null) -> Variant:
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_rx: Variant = p_rx
	var v_ry: Variant = p_ry
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(v_cx, v_cy, v_rx, v_ry, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# core.js:517
func f_inEnd() -> Variant:
	J.setv(game.j_IN, "pressed", false)
	J.setv(game.j_IN, "released", false)
	J.setv(game.j_IN, "kp", {})
	return null

# core.js:521
func f_textStart(p_v: Variant = null, p_max: Variant = null) -> Variant:
	var v_v: Variant = p_v
	var v_max: Variant = p_max
	J.setv(game.j_TEXTIN, "active", true)
	J.setv(game.j_TEXTIN, "value", (v_v if J.truth(v_v) else ""))
	J.setv(game.j_TEXTIN, "max", (v_max if J.truth(v_max) else 14.0))
	J.setv(game.j_TEXTIN, "done", false)
	J.setv(game.j_TEXTIN, "cancel", false)
	return null

# core.js:522
func f_textStop() -> Variant:
	J.setv(game.j_TEXTIN, "active", false)
	return null

# core.js:533
func f_keyp(p_c: Variant = null) -> Variant:
	var v_c: Variant = p_c
	return (not (not J.truth(J.getv(J.getv(game.j_IN, "kp"), v_c))))
	return null

# core.js:537
func f_shake(p_a: Variant = null) -> Variant:
	var v_a: Variant = p_a
	J.setv(game.j_CAM, "shake", min(9.0, max(J.getv(game.j_CAM, "shake"), v_a)))
	return null

# core.js:538
func f_flash(p_a: Variant = null, p_c: Variant = null) -> Variant:
	var v_a: Variant = p_a
	var v_c: Variant = p_c
	J.setv(game.j_CAM, "flash", max(J.getv(game.j_CAM, "flash"), v_a))
	J.setv(game.j_CAM, "flashCol", (v_c if J.truth(v_c) else "#fff"))
	return null

# core.js:539
func f_camUpdate(p_dt: Variant = null) -> Variant:
	var v_s: Variant = null
	var v_dt: Variant = p_dt
	J.setv(game.j_CAM, "shake", max(0.0, (J.getv(game.j_CAM, "shake") - (v_dt * 26.0))))
	v_s = J.getv(game.j_CAM, "shake")
	J.setv(game.j_CAM, "sx", (floor(game.math_utils.f_rnd((-J.n(v_s)), v_s) + 0.5) if J.gt(v_s, 0.2) else 0.0))
	J.setv(game.j_CAM, "sy", (floor(game.math_utils.f_rnd((-J.n(v_s)), v_s) + 0.5) if J.gt(v_s, 0.2) else 0.0))
	J.setv(game.j_CAM, "flash", max(0.0, (J.getv(game.j_CAM, "flash") - (v_dt * 2.6))))
	return null

# core.js:549
func f_part(p_o: Variant = null) -> Variant:
	var v_o: Variant = p_o
	if J.gt(J.getv(game.j_PS, "length"), 360.0):
		J.method(game.j_PS, "shift", [])
	J.setv(v_o, "life", (J.getv(v_o, "life") if J.truth(J.getv(v_o, "life")) else 0.6))
	J.setv(v_o, "t", 0.0)
	J.setv(v_o, "vx", (J.getv(v_o, "vx") if J.truth(J.getv(v_o, "vx")) else 0.0))
	J.setv(v_o, "vy", (J.getv(v_o, "vy") if J.truth(J.getv(v_o, "vy")) else 0.0))
	J.setv(v_o, "g", (220.0 if J.eq(J.getv(v_o, "g"), null) else J.getv(v_o, "g")))
	J.setv(v_o, "sz", (J.getv(v_o, "sz") if J.truth(J.getv(v_o, "sz")) else 1.0))
	J.setv(v_o, "type", (J.getv(v_o, "type") if J.truth(J.getv(v_o, "type")) else "px"))
	J.setv(v_o, "drag", (0.06 if J.eq(J.getv(v_o, "drag"), null) else J.getv(v_o, "drag")))
	J.method(game.j_PS, "push", [v_o])
	return v_o
	return null

# core.js:556
func f_burst(p_x: Variant = null, p_y: Variant = null, p_n: Variant = null, p_cols: Variant = null, p_opt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_a: Variant = null
	var v_sp: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_n: Variant = p_n
	var v_cols: Variant = p_cols
	var v_opt: Variant = p_opt
	v_opt = (v_opt if J.truth(v_opt) else {})
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_a = (J.add(J.getv(v_opt, "ang"), game.math_utils.f_rnd((-J.n((J.getv(v_opt, "spread") if J.truth(J.getv(v_opt, "spread")) else 0.6))), (J.getv(v_opt, "spread") if J.truth(J.getv(v_opt, "spread")) else 0.6))) if not J.eq(J.getv(v_opt, "ang"), null) else game.math_utils.f_rnd(0.0, game.j_TAU))
		v_sp = game.math_utils.f_rnd((J.getv(v_opt, "spMin") if J.truth(J.getv(v_opt, "spMin")) else 20.0), (J.getv(v_opt, "spMax") if J.truth(J.getv(v_opt, "spMax")) else 90.0))
		game.effects.f_part({"x": v_x, "y": v_y, "vx": (cos(v_a) * v_sp), "vy": ((sin(v_a) * v_sp) - (J.getv(v_opt, "up") if J.truth(J.getv(v_opt, "up")) else 0.0)), "life": game.math_utils.f_rnd((J.getv(v_opt, "lifeMin") if J.truth(J.getv(v_opt, "lifeMin")) else 0.3), (J.getv(v_opt, "lifeMax") if J.truth(J.getv(v_opt, "lifeMax")) else 0.8)), "col": game.math_utils.f_pick(v_cols), "g": (220.0 if J.eq(J.getv(v_opt, "g"), null) else J.getv(v_opt, "g")), "sz": (J.getv(v_opt, "sz") if J.truth(J.getv(v_opt, "sz")) else 1.0), "type": (J.getv(v_opt, "type") if J.truth(J.getv(v_opt, "type")) else "px"), "floor": J.getv(v_opt, "floor"), "bounce": J.getv(v_opt, "bounce")})
		v_i = J.add(v_i, 1.0)
	return null

# core.js:569
func f_smoke(p_x: Variant = null, p_y: Variant = null, p_n: Variant = null, p_col: Variant = null, p_opt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_n: Variant = p_n
	var v_col: Variant = p_col
	var v_opt: Variant = p_opt
	v_opt = (v_opt if J.truth(v_opt) else {})
	v_i = 0.0
	while J.lt(v_i, v_n):
		game.effects.f_part({"x": J.add(v_x, game.math_utils.f_rnd((-J.n(2.0)), 2.0)), "y": J.add(v_y, game.math_utils.f_rnd((-J.n(1.0)), 1.0)), "vx": game.math_utils.f_rnd((-J.n(6.0)), 6.0), "vy": game.math_utils.f_rnd((-J.n(26.0)), (-J.n(12.0))), "life": game.math_utils.f_rnd(0.6, 1.4), "col": (v_col if J.truth(v_col) else "rgba(255,255,255,.55)"), "g": (-J.n(8.0)), "sz": (J.getv(v_opt, "sz") if J.truth(J.getv(v_opt, "sz")) else 2.0), "type": "smoke", "drag": 0.5})
		v_i = J.add(v_i, 1.0)
	return null

# core.js:576
func f_psUpdate(p_dt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_p: Variant = null
	var v_dt: Variant = p_dt
	v_i = (J.getv(game.j_PS, "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_p = J.getv(game.j_PS, v_i)
		J.setv(v_p, "t", J.add(J.getv(v_p, "t"), v_dt))
		if J.ge(J.getv(v_p, "t"), J.getv(v_p, "life")):
			J.method(game.j_PS, "splice", [v_i, 1.0])
			v_i = (v_i - 1.0)
			continue
		J.setv(v_p, "vy", J.add(J.getv(v_p, "vy"), (J.getv(v_p, "g") * v_dt)))
		J.setv(v_p, "vx", (J.getv(v_p, "vx") - (((J.getv(v_p, "vx") * J.getv(v_p, "drag")) * v_dt) * 10.0)))
		J.setv(v_p, "x", J.add(J.getv(v_p, "x"), (J.getv(v_p, "vx") * v_dt)))
		J.setv(v_p, "y", J.add(J.getv(v_p, "y"), (J.getv(v_p, "vy") * v_dt)))
		if (not J.eq(J.getv(v_p, "floor"), null) and J.gt(J.getv(v_p, "y"), J.getv(v_p, "floor"))):
			J.setv(v_p, "y", J.getv(v_p, "floor"))
			if J.truth(J.getv(v_p, "bounce")):
				J.setv(v_p, "vy", (J.getv(v_p, "vy") * (-J.n(J.getv(v_p, "bounce")))))
				J.setv(v_p, "vx", (J.getv(v_p, "vx") * 0.6))
				if J.lt(abs(J.getv(v_p, "vy")), 12.0):
					J.setv(v_p, "vy", 0.0)
					J.setv(v_p, "g", 0.0)
			else:
				J.setv(v_p, "vy", 0.0)
				J.setv(v_p, "vx", (J.getv(v_p, "vx") * 0.8))
				J.setv(v_p, "g", 0.0)
		v_i = (v_i - 1.0)
	return null

# core.js:590
func f_psDraw() -> Variant:
	var v_i: Variant = null
	var v_p: Variant = null
	var v_k: Variant = null
	var v_r: Variant = null
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_PS, "length")):
		v_p = J.getv(game.j_PS, v_i)
		v_k = (float(J.getv(v_p, "t")) / float(J.getv(v_p, "life")))
		if J.eq(J.getv(v_p, "type"), "smoke"):
			J.setv(game.j_ctx, "globalAlpha", ((1.0 - v_k) * 0.5))
			game.f_disc(J.getv(v_p, "x"), J.getv(v_p, "y"), (J.add(J.getv(v_p, "sz"), (v_k * 3.0)) * 0.5), J.getv(v_p, "col"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		else:
			if J.eq(J.getv(v_p, "type"), "star"):
				J.setv(game.j_ctx, "globalAlpha", (1.0 - (v_k * v_k)))
				v_r = max(1.0, (J.getv(v_p, "sz") * (1.0 - (v_k * 0.4))))
				game.f_fr((J.getv(v_p, "x") - v_r), J.getv(v_p, "y"), J.add((v_r * 2.0), 1.0), 1.0, J.getv(v_p, "col"))
				game.f_fr(J.getv(v_p, "x"), (J.getv(v_p, "y") - v_r), 1.0, J.add((v_r * 2.0), 1.0), J.getv(v_p, "col"))
				J.setv(game.j_ctx, "globalAlpha", 1.0)
			else:
				if J.eq(J.getv(v_p, "type"), "ring"):
					J.setv(game.j_ctx, "globalAlpha", (1.0 - v_k))
					game.f_ring(J.getv(v_p, "x"), J.getv(v_p, "y"), J.add(1.0, (v_k * (J.getv(v_p, "sz") if J.truth(J.getv(v_p, "sz")) else 10.0))), J.getv(v_p, "col"))
					J.setv(game.j_ctx, "globalAlpha", 1.0)
				else:
					if (J.eq(J.getv(v_p, "type"), "et") and J.eq(J.kind(J.ref(game.spit_draw.f_drawEtDilimi, 5)), "function")):
						if J.gt(v_k, 0.82):
							J.setv(game.j_ctx, "globalAlpha", (1.0 - ((v_k - 0.82) * 5.6)))
						game.spit_draw.f_drawEtDilimi(J.getv(v_p, "x"), J.getv(v_p, "y"), J.add(0.35, (v_k * 1.05)), (J.getv(v_p, "k") if J.truth(J.getv(v_p, "k")) else 1.0), (J.getv(v_p, "sc") if J.truth(J.getv(v_p, "sc")) else 1.0))
						J.setv(game.j_ctx, "globalAlpha", 1.0)
					else:
						if J.gt(v_k, 0.75):
							J.setv(game.j_ctx, "globalAlpha", (1.0 - ((v_k - 0.75) * 4.0)))
						game.f_fr((J.getv(v_p, "x") - (int(J.n(J.getv(v_p, "sz"))) >> int(J.n(1.0)))), (J.getv(v_p, "y") - (int(J.n(J.getv(v_p, "sz"))) >> int(J.n(1.0)))), J.getv(v_p, "sz"), J.getv(v_p, "sz"), J.getv(v_p, "col"))
						J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	return null

# core.js:620
func f_ftext(p_s: Variant = null, p_x: Variant = null, p_y: Variant = null, p_col: Variant = null, p_opt: Variant = null) -> Variant:
	var v_s: Variant = p_s
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_col: Variant = p_col
	var v_opt: Variant = p_opt
	v_s = game.localization.f_T(v_s)
	v_opt = (v_opt if J.truth(v_opt) else {})
	J.method(game.j_FT, "push", [{"s": v_s, "x": v_x, "y": v_y, "col": v_col, "t": 0.0, "life": (J.getv(v_opt, "life") if J.truth(J.getv(v_opt, "life")) else 1.1), "vy": ((-J.n(22.0)) if J.eq(J.getv(v_opt, "vy"), null) else J.getv(v_opt, "vy")), "sc": (J.getv(v_opt, "sc") if J.truth(J.getv(v_opt, "sc")) else 1.0), "out": (J.getv(v_opt, "out") if J.truth(J.getv(v_opt, "out")) else J.getv(game.j_P, "ui5"))}])
	if J.gt(J.getv(game.j_FT, "length"), 40.0):
		J.method(game.j_FT, "shift", [])
	return null

# core.js:626
func f_ftUpdate(p_dt: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_f: Variant = null
	var v_dt: Variant = p_dt
	v_i = (J.getv(game.j_FT, "length") - 1.0)
	while J.ge(v_i, 0.0):
		v_f = J.getv(game.j_FT, v_i)
		J.setv(v_f, "t", J.add(J.getv(v_f, "t"), v_dt))
		J.setv(v_f, "y", J.add(J.getv(v_f, "y"), (J.getv(v_f, "vy") * v_dt)))
		J.setv(v_f, "vy", J.add(J.getv(v_f, "vy"), (30.0 * v_dt)))
		if J.ge(J.getv(v_f, "t"), J.getv(v_f, "life")):
			J.method(game.j_FT, "splice", [v_i, 1.0])
		v_i = (v_i - 1.0)
	return null

# core.js:632
func f_ftDraw() -> Variant:
	var v_i: Variant = null
	var v_f: Variant = null
	var v_k: Variant = null
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_FT, "length")):
		v_f = J.getv(game.j_FT, v_i)
		v_k = (float(J.getv(v_f, "t")) / float(J.getv(v_f, "life")))
		J.setv(game.j_ctx, "globalAlpha", ((1.0 - (float((v_k - 0.6)) / float(0.4))) if J.gt(v_k, 0.6) else 1.0))
		game.text_draw.f_txt(J.getv(v_f, "s"), J.getv(v_f, "x"), J.getv(v_f, "y"), J.getv(v_f, "col"), {"align": "c", "sc": J.getv(v_f, "sc"), "outline": J.getv(v_f, "out")})
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	return null

# core.js:664
func f_volKazanc(p_v: Variant = null) -> Variant:
	var v_u: Variant = null
	var v_v: Variant = p_v
	v_u = (float(game.math_utils.f_clamp(v_v, 0.0, 100.0)) / float(100.0))
	return (v_u * v_u)
	return null

# core.js:674
func f_volAyarla(p_tur: Variant = null, p_deger: Variant = null) -> Variant:
	var v_tur: Variant = p_tur
	var v_deger: Variant = p_deger
	J.setv(game.j_VOL, v_tur, game.math_utils.f_clamp(floor(v_deger + 0.5), 0.0, 100.0))
	if (J.truth(game.j_MUTED) and (J.gt(J.getv(game.j_VOL, "mus"), 0.0) or J.gt(J.getv(game.j_VOL, "sfx"), 0.0))):
		game.j_MUTED = false
	game.f_volUygula()
	game.save_system.f_volKaydet()
	return null

# core.js:679
func f_sesKis(p_acik: Variant = null) -> Variant:
	var v_acik: Variant = p_acik
	game.j_MUTED = (not J.truth(v_acik))
	game.f_volUygula()
	game.save_system.f_volKaydet()
	return null
