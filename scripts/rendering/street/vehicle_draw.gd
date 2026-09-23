# Vehicle draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:1079
func f_parkedKalip() -> Variant:
	var v_v: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	v_v = {}
	if (J.eq(J.kind(game.j_G), "undefined") or (not J.truth(J.getv(game.j_G, "customers")))):
		return v_v
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
		v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
		if ((not J.truth(v_c)) or (not J.truth(J.getv(v_c, "look")))):
			v_i = J.add(v_i, 1.0)
			continue
		if J.truth(J.getv(J.getv(v_c, "look"), "kalip")):
			J.setv(v_v, J.getv(J.getv(v_c, "look"), "kalip"), 1.0)
		v_i = J.add(v_i, 1.0)
	return v_v
	return null

# art.js:1197
func f_wheel(p_x: Variant = null, p_y: Variant = null, p_r: Variant = null, p_t: Variant = null, p_sp: Variant = null) -> Variant:
	var v_a: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_r: Variant = p_r
	var v_t: Variant = p_t
	var v_sp: Variant = p_sp
	game.f_disc(v_x, v_y, v_r, "#1c1f24")
	game.f_disc(v_x, v_y, (v_r - 1.0), "#2b3037")
	game.f_disc(v_x, v_y, max(1.0, (v_r - 2.0)), "#9aa3ab")
	v_a = (v_t * v_sp)
	game.f_px(J.add(v_x, floor((cos(v_a) * (v_r - 2.0)) + 0.5)), J.add(v_y, floor((sin(v_a) * (v_r - 2.0)) + 0.5)), "#5a636b")
	game.f_px((v_x - floor((cos(v_a) * (v_r - 2.0)) + 0.5)), (v_y - floor((sin(v_a) * (v_r - 2.0)) + 0.5)), "#5a636b")
	return null

# art.js:1209
func f_drawVehicle(p_x: Variant = null, p_y: Variant = null, p_sc: Variant = null, p_type: Variant = null, p_ci: Variant = null, p_dir: Variant = null, p_t: Variant = null, p_duruyor: Variant = null) -> Variant:
	var v_L: Variant = null
	var v_C: Variant = null
	var v_wr: Variant = null
	var v_bodyH: Variant = null
	var v_roofH: Variant = null
	var v_by: Variant = null
	var v_ry: Variant = null
	var v_jr: Variant = null
	var v_jy: Variant = null
	var v_jw: Variant = null
	var v_dh: Variant = null
	var v_dy: Variant = null
	var v_dk: Variant = null
	var v_dwy: Variant = null
	var v_dw: Variant = null
	var v_dwx: Variant = null
	var v_wI: Variant = null
	var v_wx0: Variant = null
	var v_cabX: Variant = null
	var v_cabW: Variant = null
	var v_gw2: Variant = null
	var v_ghh: Variant = null
	var v_stopC: Variant = null
	var v_wy2: Variant = null
	var v_wsp: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_sc: Variant = p_sc
	var v_type: Variant = p_type
	var v_ci: Variant = p_ci
	var v_dir: Variant = p_dir
	var v_t: Variant = p_t
	var v_duruyor: Variant = p_duruyor
	v_L = game.traffic_system.f_vehLen(v_type, v_sc)
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	J.method(game.j_ctx, "save", [])
	if J.lt(v_dir, 0.0):
		J.method(game.j_ctx, "translate", [(J.add(v_x, floor((float(v_L) / float(2.0)) + 0.5)) * 2.0), 0.0])
		J.method(game.j_ctx, "scale", [(-J.n(1.0)), 1.0])
	v_C = J.getv(game.j_CAR_PAL, fmod(J.n(v_ci), J.n(J.getv(game.j_CAR_PAL, "length"))))
	v_wr = max(2.0, floor((3.0 * v_sc) + 0.5))
	v_bodyH = floor((7.0 * v_sc) + 0.5)
	v_roofH = floor(((10.0 if J.eq(v_type, 2.0) else 6.0) * v_sc) + 0.5)
	v_by = ((v_y - v_wr) - v_bodyH)
	v_ry = (v_by - v_roofH)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_ell(J.add(v_x, (float(v_L) / float(2.0))), v_y, ((float(v_L) / float(2.0)) - 1.0), max(1.0, floor((2.0 * v_sc) + 0.5)), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.eq(v_type, 4.0):
		v_jr = floor((9.0 * v_sc) + 0.5)
		v_jy = (v_by - v_jr)
		game.f_fr(v_x, v_by, v_L, v_bodyH, J.getv(v_C, "d"))
		game.f_fr(v_x, v_by, (v_L - 1.0), (v_bodyH - 1.0), J.getv(v_C, "b"))
		game.f_fr(J.add(v_x, floor((3.0 * v_sc) + 0.5)), v_jy, (v_L - floor((9.0 * v_sc) + 0.5)), v_jr, J.getv(v_C, "d"))
		game.f_fr(J.add(v_x, floor((3.0 * v_sc) + 0.5)), v_jy, (v_L - floor((10.0 * v_sc) + 0.5)), (v_jr - 1.0), J.getv(v_C, "b"))
		game.f_hl(J.add(v_x, floor((4.0 * v_sc) + 0.5)), v_jy, (v_L - floor((12.0 * v_sc) + 0.5)), J.getv(v_C, "l"))
		v_jw = 0.0
		while J.lt(v_jw, 5.0):
			game.f_fr(J.add(v_x, floor((J.add(6.0, (v_jw * 8.0)) * v_sc) + 0.5)), J.add(v_jy, floor((2.0 * v_sc) + 0.5)), floor((6.0 * v_sc) + 0.5), floor((5.0 * v_sc) + 0.5), "#20282e")
			v_jw = J.add(v_jw, 1.0)
		game.f_fr(J.add(v_x, 1.0), J.add(v_by, floor((3.0 * v_sc) + 0.5)), (v_L - 3.0), max(1.0, floor((2.0 * v_sc) + 0.5)), J.getv(v_C, "l"))
		game.f_fr((J.add(v_x, v_L) - floor((6.0 * v_sc) + 0.5)), v_by, floor((6.0 * v_sc) + 0.5), (v_bodyH - 1.0), "#d8dee4")
		game.f_hl((J.add(v_x, v_L) - floor((6.0 * v_sc) + 0.5)), v_by, floor((6.0 * v_sc) + 0.5), "#ffffff")
	else:
		if J.eq(v_type, 5.0):
			v_dh = floor((15.0 * v_sc) + 0.5)
			v_dy = (v_by - v_dh)
			game.f_fr(v_x, v_dy, v_L, J.add(v_bodyH, v_dh), J.getv(v_C, "d"))
			game.f_fr(v_x, v_dy, (v_L - 1.0), (J.add(v_bodyH, v_dh) - 1.0), J.getv(v_C, "b"))
			game.f_hl(J.add(v_x, 1.0), v_dy, (v_L - 3.0), J.getv(v_C, "l"))
			v_dk = 0.0
			while J.lt(v_dk, 2.0):
				v_dwy = J.add(v_dy, floor((J.add(2.0, (v_dk * 8.0)) * v_sc) + 0.5))
				v_dw = 0.0
				while J.lt(v_dw, 4.0):
					v_dwx = J.add(v_x, floor((J.add(4.0, (v_dw * 10.0)) * v_sc) + 0.5))
					game.f_fr(v_dwx, v_dwy, floor((8.0 * v_sc) + 0.5), floor((5.0 * v_sc) + 0.5), "#2c3b45")
					game.f_fr(v_dwx, v_dwy, floor((8.0 * v_sc) + 0.5), floor((4.0 * v_sc) + 0.5), "#a9cbdc")
					game.f_hl(v_dwx, v_dwy, floor((8.0 * v_sc) + 0.5), "#dff0fa")
					v_dw = J.add(v_dw, 1.0)
				v_dk = J.add(v_dk, 1.0)
			game.f_fr(J.add(v_x, 1.0), J.add(v_dy, floor((7.0 * v_sc) + 0.5)), (v_L - 3.0), max(1.0, floor((1.0 * v_sc) + 0.5)), J.getv(v_C, "d"))
		else:
			if J.eq(v_type, 2.0):
				game.f_fr(v_x, v_ry, v_L, J.add(v_bodyH, v_roofH), J.getv(v_C, "d"))
				game.f_fr(v_x, v_ry, (v_L - 1.0), (J.add(v_bodyH, v_roofH) - 1.0), J.getv(v_C, "b"))
				game.f_hl(J.add(v_x, 1.0), v_ry, (v_L - 3.0), J.getv(v_C, "l"))
				game.f_fr(J.add(v_x, 1.0), (v_by - floor((2.0 * v_sc) + 0.5)), (v_L - 3.0), max(1.0, floor((2.0 * v_sc) + 0.5)), "#2f6a8a")
				v_wI = 0.0
				while J.lt(v_wI, 3.0):
					v_wx0 = J.add(v_x, floor((J.add(5.0, (v_wI * 11.0)) * v_sc) + 0.5))
					game.f_fr(v_wx0, J.add(v_ry, floor((2.0 * v_sc) + 0.5)), floor((9.0 * v_sc) + 0.5), floor((5.0 * v_sc) + 0.5), "#2c3b45")
					game.f_fr(v_wx0, J.add(v_ry, floor((2.0 * v_sc) + 0.5)), floor((9.0 * v_sc) + 0.5), floor((4.0 * v_sc) + 0.5), "#a9cbdc")
					game.f_hl(v_wx0, J.add(v_ry, floor((2.0 * v_sc) + 0.5)), floor((9.0 * v_sc) + 0.5), "#dff0fa")
					v_wI = J.add(v_wI, 1.0)
				game.f_fr((J.add(v_x, v_L) - floor((8.0 * v_sc) + 0.5)), J.add(v_ry, floor((2.0 * v_sc) + 0.5)), floor((6.0 * v_sc) + 0.5), floor((5.0 * v_sc) + 0.5), "#2c3b45")
				game.f_fr((J.add(v_x, v_L) - floor((8.0 * v_sc) + 0.5)), J.add(v_ry, floor((2.0 * v_sc) + 0.5)), floor((6.0 * v_sc) + 0.5), floor((4.0 * v_sc) + 0.5), "#bcd8e6")
			else:
				v_cabX = J.add(v_x, floor(((8.0 if J.eq(v_type, 3.0) else 10.0) * v_sc) + 0.5))
				v_cabW = floor(((16.0 if J.eq(v_type, 3.0) else 18.0) * v_sc) + 0.5)
				game.f_fr(v_cabX, v_ry, v_cabW, v_roofH, J.getv(v_C, "d"))
				game.f_fr(v_cabX, v_ry, (v_cabW - 1.0), (v_roofH - 1.0), J.getv(v_C, "b"))
				game.f_hl(J.add(v_cabX, 1.0), v_ry, (v_cabW - 3.0), J.getv(v_C, "l"))
				v_gw2 = (floor((float(v_cabW) / float(2.0)) + 0.5) - 1.0)
				v_ghh = max(2.0, (v_roofH - 2.0))
				game.f_fr(J.add(v_cabX, 1.0), J.add(v_ry, 1.0), (v_gw2 - 1.0), v_ghh, "#22303a")
				game.f_fr(J.add(v_cabX, 1.0), J.add(v_ry, 1.0), (v_gw2 - 1.0), (v_ghh - 1.0), "#9cc2d6")
				game.f_fr(J.add(J.add(v_cabX, v_gw2), 1.0), J.add(v_ry, 1.0), (v_gw2 - 1.0), v_ghh, "#22303a")
				game.f_fr(J.add(J.add(v_cabX, v_gw2), 1.0), J.add(v_ry, 1.0), (v_gw2 - 1.0), (v_ghh - 1.0), "#b6d4e4")
				game.f_hl(J.add(v_cabX, 1.0), J.add(v_ry, 1.0), (v_gw2 - 1.0), "#eaf6ff")
				game.f_hl(J.add(J.add(v_cabX, v_gw2), 1.0), J.add(v_ry, 1.0), (v_gw2 - 1.0), "#eaf6ff")
				game.f_fr(v_x, v_by, v_L, v_bodyH, J.getv(v_C, "d"))
				game.f_fr(v_x, v_by, (v_L - 1.0), (v_bodyH - 1.0), J.getv(v_C, "b"))
				game.f_hl(J.add(v_x, 2.0), v_by, (v_L - 5.0), J.getv(v_C, "l"))
				game.f_fr(v_x, v_by, floor((3.0 * v_sc) + 0.5), max(1.0, floor((1.0 * v_sc) + 0.5)), J.getv(v_C, "d"))
				game.f_fr((J.add(v_x, v_L) - floor((3.0 * v_sc) + 0.5)), v_by, floor((3.0 * v_sc) + 0.5), max(1.0, floor((1.0 * v_sc) + 0.5)), J.getv(v_C, "d"))
				game.f_vl(J.add(v_cabX, v_gw2), J.add(v_by, 1.0), (v_bodyH - 2.0), J.getv(v_C, "d"))
				game.f_fr(J.add(v_cabX, 2.0), J.add(v_by, floor((2.0 * v_sc) + 0.5)), floor((3.0 * v_sc) + 0.5), 1.0, J.getv(v_C, "l"))
				game.f_fr(v_x, (J.add(v_by, v_bodyH) - floor((2.0 * v_sc) + 0.5)), (v_L - 1.0), max(1.0, floor((1.0 * v_sc) + 0.5)), "#8f979f")
	if J.eq(v_type, 1.0):
		game.f_fr(J.add(v_x, floor((15.0 * v_sc) + 0.5)), (v_ry - floor((3.0 * v_sc) + 0.5)), floor((9.0 * v_sc) + 0.5), floor((3.0 * v_sc) + 0.5), "#2b2018")
		game.f_fr(J.add(v_x, floor((15.0 * v_sc) + 0.5)), (v_ry - floor((3.0 * v_sc) + 0.5)), floor((8.0 * v_sc) + 0.5), floor((2.0 * v_sc) + 0.5), "#ffe9a0")
	game.f_fr((J.add(v_x, v_L) - floor((2.0 * v_sc) + 0.5)), J.add(v_by, floor((2.0 * v_sc) + 0.5)), floor((2.0 * v_sc) + 0.5), floor((2.0 * v_sc) + 0.5), "#fff2b8")
	v_stopC = ("#ff5a48" if J.truth(v_duruyor) else "#d8352c")
	game.f_fr(v_x, J.add(v_by, floor((2.0 * v_sc) + 0.5)), max(1.0, floor((2.0 * v_sc) + 0.5)), floor((2.0 * v_sc) + 0.5), v_stopC)
	if J.truth(v_duruyor):
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_fr((v_x - 1.0), J.add(v_by, floor((1.0 * v_sc) + 0.5)), floor((3.0 * v_sc) + 0.5), floor((4.0 * v_sc) + 0.5), "#ff5a48")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_wy2 = (v_y - v_wr)
	v_wsp = (0.0 if J.truth(v_duruyor) else (9.0 if J.gt(v_dir, 0.0) else (-J.n(9.0))))
	game.vehicle_draw.f_wheel(J.add(v_x, floor(((9.0 if J.eq(v_type, 2.0) else 8.0) * v_sc) + 0.5)), v_wy2, v_wr, v_t, v_wsp)
	game.vehicle_draw.f_wheel((J.add(v_x, v_L) - floor(((10.0 if J.eq(v_type, 2.0) else 9.0) * v_sc) + 0.5)), v_wy2, v_wr, v_t, v_wsp)
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_fr(J.add(v_x, floor((5.0 * v_sc) + 0.5)), (v_wy2 - v_wr), floor((7.0 * v_sc) + 0.5), 1.0, "#000")
	game.f_fr((J.add(v_x, v_L) - floor((13.0 * v_sc) + 0.5)), (v_wy2 - v_wr), floor((7.0 * v_sc) + 0.5), 1.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.method(game.j_ctx, "restore", [])
	return null

