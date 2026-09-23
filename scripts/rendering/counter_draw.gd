# Counter draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:2461
func f_steelWell(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	game.f_fr(v_x, v_y, v_w, v_h, J.getv(game.j_P, "mt4"))
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 2.0), (v_w - 4.0), (v_h - 4.0), "#5a616a")
	game.f_fr(J.add(v_x, 3.0), J.add(v_y, 3.0), (v_w - 6.0), (v_h - 6.0), "#4c535b")
	game.f_hl(v_x, v_y, v_w, J.getv(game.j_P, "mt0"))
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), J.getv(game.j_P, "mt2"))
	game.f_hl(v_x, (J.add(v_y, v_h) - 1.0), v_w, J.getv(game.j_P, "mt1"))
	game.f_hl(v_x, (J.add(v_y, v_h) - 2.0), v_w, J.getv(game.j_P, "mt3"))
	game.f_vl(v_x, v_y, v_h, J.getv(game.j_P, "mt2"))
	game.f_vl((J.add(v_x, v_w) - 1.0), v_y, v_h, J.getv(game.j_P, "mt3"))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(J.add(v_x, 3.0), J.add(v_y, 3.0), (v_w - 6.0), 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:2474
func f_rubberMat(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_j: Variant = null
	var v_i: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	game.f_rrect(v_x, v_y, v_w, v_h, 3.0, "#2f3339")
	game.f_rrect(J.add(v_x, 1.0), v_y, (v_w - 2.0), (v_h - 2.0), 3.0, "#3d424a")
	v_j = 3.0
	while J.lt(v_j, (v_h - 3.0)):
		v_i = 3.0
		while J.lt(v_i, (v_w - 3.0)):
			game.f_px(J.add(J.add(v_x, v_i), (2.0 if J.truth((int(J.n((float(v_j) / float(4.0)))) & int(J.n(1.0)))) else 0.0)), J.add(v_y, v_j), "#333840")
			v_i = J.add(v_i, 4.0)
		v_j = J.add(v_j, 4.0)
	game.f_hl(J.add(v_x, 3.0), v_y, (v_w - 6.0), "#4e545d")
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_hl(J.add(v_x, 3.0), (J.add(v_y, v_h) - 1.0), (v_w - 6.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:2483
func f_shelfUnit(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	game.f_fr(v_x, v_y, v_w, v_h, J.getv(game.j_P, "mt2"))
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 2.0), J.getv(game.j_P, "mt1"))
	game.f_hl(v_x, v_y, v_w, J.getv(game.j_P, "mt0"))
	v_i = 0.0
	while J.lt(v_i, 40.0):
		J.setv(game.j_ctx, "globalAlpha", 0.09)
		game.f_hl(J.add(J.add(v_x, 3.0), (game.f_hash1((v_i * 3.7)) * (v_w - 20.0))), J.add(J.add(v_y, 3.0), (game.f_hash1((v_i * 1.3)) * (v_h - 6.0))), J.add(6.0, (game.f_hash1(v_i) * 12.0)), "#ffffff")
		v_i = J.add(v_i, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_hl(v_x, (J.add(v_y, v_h) - 2.0), v_w, J.getv(game.j_P, "mt3"))
	game.f_hl(v_x, (J.add(v_y, v_h) - 1.0), v_w, J.getv(game.j_P, "mt4"))
	return null

# art.js:2497
func f_bakeCounter() -> Variant:
	var v_c: Variant = null
	var v_g: Variant = null
	var v_old: Variant = null
	v_c = Canvas.new()
	J.setv(v_c, "width", game.j_W)
	J.setv(v_c, "height", game.j_H)
	v_g = J.method(v_c, "getContext", ["2d"])
	v_old = game.j_ctx
	game.j_ctx = v_g
	game.f_drawCounterRaw()
	game.f_drawCounterProps(0.0)
	game.j_ctx = v_old
	game.j_CLAYER = v_c
	return v_c
	return null

# art.js:2507
func f_drawCounter() -> Variant:
	if (not J.truth(game.j_CLAYER)):
		game.counter_draw.f_bakeCounter()
	J.method(game.j_ctx, "drawImage", [game.j_CLAYER, 0.0, 0.0])
	return null

# art.js:2517
func f_drawCounterRaw() -> Variant:
	var v_ly: Variant = null
	var v_lh: Variant = null
	var v_x0: Variant = null
	var v_CP: Variant = null
	var v_i: Variant = null
	var v_hh: Variant = null
	var v_sy: Variant = null
	var v_sh: Variant = null
	var v_y: Variant = null
	var v_tt: Variant = null
	var v_a: Variant = null
	var v_k: Variant = null
	var v_yy: Variant = null
	var v_xx: Variant = null
	var v_ww: Variant = null
	var v_bb: Variant = null
	var v_py: Variant = null
	var v_k2: Variant = null
	var v_R: Variant = null
	var v_i2: Variant = null
	var v_d: Variant = null
	var v_yr: Variant = null
	var v_e: Variant = null
	v_ly = J.getv(game.j_LAY, "ledgeY")
	v_lh = J.getv(game.j_LAY, "ledgeH")
	v_x0 = game.j_CX0
	v_CP = J.getv(game.j_COUNTER_PAL, (fmod(J.n(J.getv(J.getv(game.j_G, "custom"), "counter")), J.n(J.getv(game.j_COUNTER_PAL, "length"))) if (J.truth(J.getv(game.j_G, "custom")) and J.truth(J.getv(J.getv(game.j_G, "custom"), "counter"))) else 0.0))
	game.f_fr(v_x0, v_ly, (game.j_W - v_x0), v_lh, "#cbb68c")
	game.f_hl(v_x0, v_ly, (game.j_W - v_x0), "#f6e8c4")
	game.f_hl(v_x0, J.add(v_ly, 1.0), (game.j_W - v_x0), "#e9d6ab")
	game.f_hl(v_x0, J.add(v_ly, 2.0), (game.j_W - v_x0), "#dcc79c")
	game.f_hl(v_x0, (J.add(v_ly, v_lh) - 3.0), (game.j_W - v_x0), "#b79f74")
	game.f_hl(v_x0, (J.add(v_ly, v_lh) - 2.0), (game.j_W - v_x0), "#96805a")
	game.f_hl(v_x0, (J.add(v_ly, v_lh) - 1.0), (game.j_W - v_x0), "#6d5c40")
	v_i = v_x0
	while J.lt(v_i, game.j_W):
		v_hh = game.f_hash1((v_i * 0.77))
		if J.gt(v_hh, 0.78):
			game.f_px(v_i, J.add(J.add(v_ly, 3.0), floor((v_hh * 4.0))), "#bda579")
		if J.lt(v_hh, 0.1):
			game.f_px(v_i, J.add(J.add(v_ly, 4.0), fmod(J.n(floor((v_hh * 30.0))), J.n(4.0))), "#e6d4ad")
		v_i = J.add(v_i, 2.0)
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_fr(v_x0, J.add(v_ly, v_lh), (game.j_W - v_x0), 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_sy = J.getv(game.j_LAY, "surfY")
	v_sh = (J.getv(game.j_LAY, "lipY") - v_sy)
	game.f_fr(v_x0, v_sy, (game.j_W - v_x0), v_sh, J.getv(v_CP, "base"))
	v_y = 0.0
	while J.lt(v_y, v_sh):
		v_tt = (float(v_y) / float(v_sh))
		v_a = ((0.16 * (1.0 - v_tt)) - (0.1 * v_tt))
		J.setv(game.j_ctx, "globalAlpha", abs(v_a))
		game.f_fr(v_x0, J.add(v_sy, v_y), (game.j_W - v_x0), 1.0, (J.getv(v_CP, "hi") if J.gt(v_a, 0.0) else J.getv(v_CP, "lo")))
		v_y = J.add(v_y, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_k = 0.0
	while J.lt(v_k, 170.0):
		v_yy = J.add(v_sy, floor((game.f_hash1((v_k * 3.3)) * v_sh)))
		v_xx = J.add(v_x0, floor((game.f_hash1((v_k * 7.7)) * (game.j_W - v_x0))))
		v_ww = J.add(5.0, floor((game.f_hash1((v_k * 1.9)) * 30.0)))
		J.setv(game.j_ctx, "globalAlpha", 0.11)
		game.f_hl(v_xx, v_yy, v_ww, ("#ffffff" if J.gt(game.f_hash1(v_k), 0.5) else "#6d747d"))
		v_k = J.add(v_k, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_hl(v_x0, v_sy, (game.j_W - v_x0), J.getv(v_CP, "edge"))
	game.f_hl(v_x0, J.add(v_sy, 1.0), (game.j_W - v_x0), J.getv(v_CP, "lip"))
	game.counter_draw.f_steelWell(52.0, 163.0, 176.0, 38.0)
	game.counter_draw.f_steelWell(224.0, 158.0, 200.0, 40.0)
	game.counter_draw.f_rubberMat(88.0, 197.0, 128.0, 48.0)
	game.counter_draw.f_shelfUnit(214.0, 197.0, 210.0, 48.0)
	game.f_rrect(44.0, 197.0, 44.0, 48.0, 3.0, "#7a5230")
	game.f_rrect(45.0, 197.0, 42.0, 46.0, 3.0, "#a5713f")
	v_bb = 0.0
	while J.lt(v_bb, 6.0):
		game.f_hl(47.0, J.add(201.0, (v_bb * 7.0)), 38.0, "#8f6236")
		v_bb = J.add(v_bb, 1.0)
	game.f_hl(45.0, 197.0, 42.0, "#c08d55")
	v_py = J.getv(game.j_LAY, "lipY")
	game.f_fr(v_x0, v_py, (game.j_W - v_x0), (J.getv(game.j_LAY, "floorY") - v_py), J.getv(v_CP, "lip"))
	game.f_hl(v_x0, v_py, (game.j_W - v_x0), J.getv(v_CP, "edge"))
	game.f_hl(v_x0, J.add(v_py, 1.0), (game.j_W - v_x0), J.getv(game.j_P, "mt1"))
	game.f_hl(v_x0, (J.getv(game.j_LAY, "floorY") - 3.0), (game.j_W - v_x0), J.getv(game.j_P, "mt3"))
	game.f_hl(v_x0, (J.getv(game.j_LAY, "floorY") - 2.0), (game.j_W - v_x0), J.getv(game.j_P, "mt4"))
	game.f_hl(v_x0, (J.getv(game.j_LAY, "floorY") - 1.0), (game.j_W - v_x0), J.getv(game.j_P, "mt5"))
	v_k2 = 0.0
	while J.lt(v_k2, 46.0):
		J.setv(game.j_ctx, "globalAlpha", 0.07)
		game.f_vl(J.add(v_x0, floor((game.f_hash1((v_k2 * 5.1)) * (game.j_W - v_x0)))), J.add(v_py, 2.0), ((J.getv(game.j_LAY, "floorY") - v_py) - 4.0), "#ffffff")
		v_k2 = J.add(v_k2, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_hl(v_x0, J.add(v_py, 4.0), (game.j_W - v_x0), "#9aa2ab")
	v_R = 8.0
	v_i2 = 0.0
	while J.lt(v_i2, v_R):
		v_d = (v_R - floor(sqrt(((v_R * v_R) - (((v_R - v_i2) - 1.0) * ((v_R - v_i2) - 1.0)))) + 0.5))
		if J.gt(v_d, 0.0):
			J.method(game.j_ctx, "clearRect", [v_x0, J.add(v_ly, v_i2), v_d, 1.0])
			J.method(game.j_ctx, "clearRect", [v_x0, ((J.getv(game.j_LAY, "floorY") - 1.0) - v_i2), v_d, 1.0])
		v_i2 = J.add(v_i2, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(v_x0, J.add(v_ly, 4.0), 3.0, ((J.getv(game.j_LAY, "floorY") - v_ly) - 8.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_vl(v_x0, J.add(v_ly, 6.0), ((J.getv(game.j_LAY, "floorY") - v_ly) - 12.0), "#8c949c")
	game.f_vl(J.add(v_x0, 1.0), J.add(v_ly, 6.0), ((J.getv(game.j_LAY, "floorY") - v_ly) - 12.0), "#aeb6be")
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_fr((v_x0 - 5.0), J.getv(game.j_LAY, "floorY"), 10.0, 4.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_yr = (v_ly - 2.0)
	while J.lt(v_yr, J.getv(game.j_LAY, "floorY")):
		v_e = game.shop_background.f_archR(v_yr)
		if J.lt(v_e, game.j_W):
			J.method(game.j_ctx, "clearRect", [v_e, v_yr, (game.j_W - v_e), 1.0])
		game.f_px((v_e - 1.0), v_yr, "rgba(0,0,0,.35)")
		v_yr = J.add(v_yr, 1.0)
	J.method(game.j_ctx, "clearRect", [0.0, J.getv(game.j_LAY, "floorY"), game.j_W, (game.j_H - J.getv(game.j_LAY, "floorY"))])
	return null

# art.js:2604
func f_drawCounterProps(p_t: Variant = null) -> Variant:
	var v_nx: Variant = null
	var v_ny: Variant = null
	var v_i: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_t: Variant = p_t
	v_nx = 398.0
	v_ny = (J.getv(game.j_LAY, "ledgeY") - 9.0)
	game.f_fr(v_nx, v_ny, 14.0, 10.0, "#9aa3ab")
	game.f_fr(J.add(v_nx, 1.0), J.add(v_ny, 1.0), 12.0, 8.0, "#c7ced5")
	game.f_fr(J.add(v_nx, 3.0), (v_ny - 2.0), 8.0, 4.0, "#fdfaf0")
	game.f_hl(J.add(v_nx, 3.0), (v_ny - 2.0), 8.0, "#ffffff")
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_sx = J.add(416.0, (v_i * 9.0))
		v_sy = (J.getv(game.j_LAY, "ledgeY") - 8.0)
		game.f_fr(v_sx, v_sy, 6.0, 9.0, ("#e8e2d4" if J.truth(v_i) else "#d8cfbc"))
		game.f_fr(J.add(v_sx, 1.0), J.add(v_sy, 1.0), 4.0, 7.0, ("#f6f2e6" if J.truth(v_i) else "#3a2a20"))
		game.f_fr(J.add(v_sx, 1.0), (v_sy - 2.0), 4.0, 3.0, "#8a939b")
		game.f_hl(J.add(v_sx, 1.0), (v_sy - 2.0), 4.0, "#c7ced5")
		v_i = J.add(v_i, 1.0)
	game.counter_draw.f_bottleProp(48.0, (J.getv(game.j_LAY, "ledgeY") - 13.0), "#c0281c", "#e2483a")
	game.counter_draw.f_bottleProp(56.0, (J.getv(game.j_LAY, "ledgeY") - 13.0), "#f0e8d2", "#fffaf0")
	return null

# art.js:2623
func f_bottleProp(p_x: Variant = null, p_y: Variant = null, p_c0: Variant = null, p_c1: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_c0: Variant = p_c0
	var v_c1: Variant = p_c1
	game.f_fr(v_x, J.add(v_y, 3.0), 6.0, 10.0, v_c0)
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 3.0), 4.0, 9.0, v_c1)
	game.f_px(J.add(v_x, 1.0), J.add(v_y, 5.0), "rgba(255,255,255,.6)")
	game.f_fr(J.add(v_x, 1.0), v_y, 4.0, 3.0, "#3a3a3a")
	game.f_fr(J.add(v_x, 2.0), (v_y - 2.0), 2.0, 2.0, "#5a5a5a")
	return null

# art.js:5027
func f_copIcerik(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_dolu: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_n: Variant = null
	var v_taban: Variant = null
	var v_tepe: Variant = null
	var v_i: Variant = null
	var v_a: Variant = null
	var v_cx0: Variant = null
	var v_cz0: Variant = null
	var v_bw: Variant = null
	var v_bh: Variant = null
	var v_kn: Variant = null
	var v_gv: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_dolu: Variant = p_dolu
	v_d = game.math_utils.f_clamp((v_dolu if J.truth(v_dolu) else 0.0), 0.0, 1.0)
	if J.lt(v_d, 0.04):
		return null
	v_n = floor(J.add(3.0, (v_d * 8.0)) + 0.5)
	v_taban = (J.add(v_y, v_h) - 5.0)
	v_tepe = (v_taban - floor((v_d * (v_h - 12.0)) + 0.5))
	v_i = 0.0
	while J.lt(v_i, v_n):
		v_a = (v_i * 2.37)
		v_cx0 = floor(J.add(J.add(v_x, (float(v_w) / float(2.0))), (cos(v_a) * ((float(v_w) / float(2.0)) - 6.0))) + 0.5)
		v_cz0 = floor((v_taban - ((float(v_i) / float(max(1.0, (v_n - 1.0)))) * (v_taban - v_tepe))) + 0.5)
		v_bw = J.add(3.0, (fmod(J.n(v_i), J.n(3.0)) * 2.0))
		v_bh = J.add(2.0, fmod(J.n(v_i), J.n(2.0)))
		v_kn = ("#8a8474" if J.truth(fmod(J.n(v_i), J.n(3.0))) else ("#52290a" if J.eq(fmod(J.n(v_i), J.n(5.0)), 0.0) else "#3a3228"))
		v_gv = ("#e8e4d6" if J.truth(fmod(J.n(v_i), J.n(3.0))) else ("#9c5718" if J.eq(fmod(J.n(v_i), J.n(5.0)), 0.0) else "#7a6a52"))
		game.f_fr((v_cx0 - v_bw), v_cz0, (v_bw * 2.0), J.add(v_bh, 1.0), v_kn)
		game.f_fr((v_cx0 - v_bw), v_cz0, ((v_bw * 2.0) - 1.0), v_bh, v_gv)
		game.f_px((v_cx0 - v_bw), v_cz0, ("#f8f4e8" if J.truth(fmod(J.n(v_i), J.n(3.0))) else "#9a8a6c"))
		v_i = J.add(v_i, 1.0)
	return null

# art.js:5046
func f_drawTrash(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_t: Variant = null, p_bosalt: Variant = null, p_dolu: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_i: Variant = null
	var v_sal: Variant = null
	var v_ky: Variant = null
	var v_yh: Variant = null
	var v_ty: Variant = null
	var v_q: Variant = null
	var v_ww: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_t: Variant = p_t
	var v_bosalt: Variant = p_bosalt
	var v_dolu: Variant = p_dolu
	v_d = game.math_utils.f_clamp((v_dolu if J.truth(v_dolu) else 0.0), 0.0, 1.35)
	game.f_fr((v_x - 2.0), (v_y - 2.0), J.add(v_w, 4.0), J.add(v_h, 4.0), "rgba(0,0,0,.30)")
	game.f_fr(v_x, v_y, v_w, v_h, "#2a2622")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), (v_h - 2.0), "#14110f")
	v_i = 0.0
	while J.lt(v_i, (v_h - 2.0)):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.1, ((float(v_i) / float(v_h)) * 0.35)))
		game.f_hl(J.add(v_x, 1.0), J.add(J.add(v_y, 1.0), v_i), (v_w - 2.0), "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	game.f_rc(v_x, v_y, v_w, v_h, "#6e675e")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), "#8a8278")
	game.f_vl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_h - 2.0), "#7a7369")
	v_sal = ((sin((v_bosalt * 26.0)) * 2.0) if J.gt(v_bosalt, 0.0) else 0.0)
	v_ky = J.add(J.add(v_y, 4.0), floor(v_sal + 0.5))
	game.f_fr(J.add(v_x, 3.0), v_ky, (v_w - 6.0), 3.0, "#4a443c")
	game.f_hl(J.add(v_x, 3.0), v_ky, (v_w - 6.0), "#6e675e")
	if J.gt(v_d, 0.02):
		v_yh = floor(((v_h - 10.0) * min(1.0, v_d)) + 0.5)
		v_ty = ((J.add(v_y, v_h) - 3.0) - v_yh)
		v_q = 0.0
		while J.lt(v_q, v_yh):
			v_ww = ((v_w - 6.0) - floor((abs(sin((v_q * 0.7))) * 2.0) + 0.5))
			game.f_fr(J.add(v_x, 3.0), J.add(v_ty, v_q), v_ww, 1.0, ("#6b6258" if J.lt(v_q, 2.0) else "#443e37"))
			v_q = J.add(v_q, 1.0)
		game.counter_draw.f_copIcerik(v_x, v_y, v_w, v_h, min(1.0, v_d))
		if J.gt(v_d, 1.0):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.45, (0.3 * sin((v_t * 6.0)))))
			game.f_rc((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), J.getv(game.j_P, "bad"))
			J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.text_draw.f_txt("ÇÖP", J.add(v_x, (float(v_w) / float(2.0))), min(J.add(J.add(v_y, v_h), 2.0), ((game.j_H - J.getv(game.j_VIEW, "bot")) - 9.0)), "rgba(255,255,255,.42)", {"align": "c", "outline": "rgba(0,0,0,.5)"})
	if (J.gt(v_bosalt, 0.0) and J.truth(game.f_chance(0.5))):
		game.effects.f_part({"x": J.add(v_x, game.math_utils.f_rnd(2.0, (v_w - 2.0))), "y": (J.add(v_y, v_h) - 4.0), "vx": game.math_utils.f_rnd((-J.n(8.0)), 8.0), "vy": game.math_utils.f_rnd((-J.n(18.0)), (-J.n(6.0))), "life": 0.5, "col": "rgba(120,110,100,.5)", "g": 60.0, "sz": 1.0})
	return null

# art.js:5095
func f_heatShimmer(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_t: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_off: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_t: Variant = p_t
	J.setv(game.j_ctx, "globalAlpha", 0.07)
	v_i = 0.0
	while J.lt(v_i, v_h):
		v_off = (sin(J.add((v_t * 3.0), (v_i * 0.5))) * 1.5)
		game.f_hl(J.add(v_x, v_off), J.add(v_y, v_i), v_w, "#ffd0a0")
		v_i = J.add(v_i, 2.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:5103
func f_glowRect(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_col: Variant = null, p_a: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_col: Variant = p_col
	var v_a: Variant = p_a
	J.setv(game.j_ctx, "globalAlpha", v_a)
	game.f_rrectOut((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), 2.0, v_col)
	J.setv(game.j_ctx, "globalAlpha", (v_a * 0.5))
	game.f_rrectOut((v_x - 2.0), (v_y - 2.0), J.add(v_w, 4.0), J.add(v_h, 4.0), 3.0, v_col)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:5110
func f_bar(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_p: Variant = null, p_col: Variant = null, p_bgc: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_p: Variant = p_p
	var v_col: Variant = p_col
	var v_bgc: Variant = p_bgc
	game.f_fr(v_x, v_y, v_w, v_h, (v_bgc if J.truth(v_bgc) else "rgba(0,0,0,.6)"))
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 1.0), max(0.0, floor(((v_w - 2.0) * v_p) + 0.5)), (v_h - 2.0), v_col)
	if J.gt(v_h, 3.0):
		game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), max(0.0, floor(((v_w - 2.0) * v_p) + 0.5)), "rgba(255,255,255,.4)")
	return null

