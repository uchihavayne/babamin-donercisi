# Shop background. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:2277
func f_dayiVar() -> Variant:
	if (J.eq(J.kind(game.j_G), "undefined") or (not J.truth(game.j_G))):
		return false
	if J.eq(J.getv(game.j_G, "scene"), "title"):
		return true
	return (not (not ((not J.eq(J.kind(game.j_TUN), "undefined") and J.truth(J.getv(game.j_G, "up"))) and J.gt(J.method(game.j_TUN, "uncleUses", [game.j_G]), 0.0))))
	return null

# art.js:2286
func f_archL(p_y: Variant = null) -> Variant:
	var v_q: Variant = null
	var v_y: Variant = p_y
	v_q = floor((float(v_y) / float(11.0)))
	if J.truth(game.shop_background.f_dayiVar()):
		return J.add(J.add(14.0, floor((game.f_hash1((v_q * 3.7)) * 7.0))), floor((6.0 * sin(J.add((v_y * 0.013), 1.2))) + 0.5))
	return J.add(J.add(40.0, floor((game.f_hash1((v_q * 3.7)) * 4.0))), floor((2.0 * sin(J.add((v_y * 0.013), 1.2))) + 0.5))
	return null

# art.js:2291
func f_archR(p_y: Variant = null) -> Variant:
	var v_q: Variant = null
	var v_y: Variant = p_y
	v_q = floor((float(v_y) / float(11.0)))
	return (game.j_W - J.add(J.add(28.0, floor((game.f_hash1(J.add((v_q * 5.1), 40.0)) * 9.0))), floor((10.0 * sin(J.add((v_y * 0.011), 0.4))) + 0.5)))
	return null

# art.js:2301
func f_bakeStoneFG() -> Variant:
	# REMAKE kancasi: arka plan GPU'da pisirildiyse tas on plan dogrudan dokudan cizilir
	if game.f_hdTasOnPlanPisir(): return null
	var v_c: Variant = null
	var v_g: Variant = null
	var v_y: Variant = null
	var v_eL: Variant = null
	var v_eR: Variant = null
	if (not J.truth(game.j_BG)):
		return null
	v_c = Canvas.new()
	J.setv(v_c, "width", game.j_W)
	J.setv(v_c, "height", game.j_H)
	v_g = J.method(v_c, "getContext", ["2d"])
	v_y = 0.0
	while J.lt(v_y, game.j_H):
		v_eL = game.shop_background.f_archL(v_y)
		if J.gt(v_eL, 0.0):
			J.method(v_g, "drawImage", [game.j_BG, 0.0, v_y, v_eL, 1.0, 0.0, v_y, v_eL, 1.0])
		v_eR = game.shop_background.f_archR(v_y)
		if J.lt(v_eR, game.j_W):
			J.method(v_g, "drawImage", [game.j_BG, v_eR, v_y, (game.j_W - v_eR), 1.0, v_eR, v_y, (game.j_W - v_eR), 1.0])
		v_y = J.add(v_y, 1.0)
	game.j_STONEFG = v_c
	return null

# art.js:2313
func f_drawStoneFG() -> Variant:
	# REMAKE kancasi
	if game.f_hdTasOnPlan(): return null
	if (not J.truth(game.j_STONEFG)):
		game.shop_background.f_bakeStoneFG()
	if J.truth(game.j_STONEFG):
		J.method(game.j_ctx, "drawImage", [game.j_STONEFG, 0.0, 0.0])
	return null

# art.js:2324
func f_bgBayat() -> Variant:
	return (((((not J.truth(game.j_BG)) if (not J.truth(game.j_BG)) else not J.eq(game.j_BGDECOR, game.equipment_system.f_UV(game.j_G, "paint"))) if ((not J.truth(game.j_BG)) or not J.eq(game.j_BGDECOR, game.equipment_system.f_UV(game.j_G, "paint"))) else not J.eq(game.j_BGDAYI, game.shop_background.f_dayiVar())) if (((not J.truth(game.j_BG)) or not J.eq(game.j_BGDECOR, game.equipment_system.f_UV(game.j_G, "paint"))) or not J.eq(game.j_BGDAYI, game.shop_background.f_dayiVar())) else not J.eq(game.j_BGCITY, J.getv(game.j_G, "city"))) if ((((not J.truth(game.j_BG)) or not J.eq(game.j_BGDECOR, game.equipment_system.f_UV(game.j_G, "paint"))) or not J.eq(game.j_BGDAYI, game.shop_background.f_dayiVar())) or not J.eq(game.j_BGCITY, J.getv(game.j_G, "city"))) else not J.eq(game.j_BGRAKIP, game.rival_building.f_rakipCepheDurum()))
	return null

# art.js:2328
func f_bakeBG(p_decor: Variant = null) -> Variant:
	var _cells: Dictionary = {"TASP": [null]}
	var v_c: Variant = null
	var v_g: Variant = null
	var v_oldctx: Variant = null
	var v_TEMA: Variant = null
	var v_wallCols: Variant = null
	var v_TS: Variant = null
	var v_ty: Variant = null
	var v_tx: Variant = null
	var v_hsh: Variant = null
	var v_base: Variant = null
	var v_bw: Variant = null
	var v_bh: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_y: Variant = null
	var v_a: Variant = null
	var v_y2: Variant = null
	var v_stoneBand: Variant = null
	var v_Z: Variant = null
	var v_zy: Variant = null
	var v_zh: Variant = null
	var v_dx: Variant = null
	var v_dy: Variant = null
	var v_kare: Variant = null
	var v_dl: Variant = null
	var v_mx2: Variant = null
	var v_md: Variant = null
	var v_vx: Variant = null
	var v_bx2: Variant = null
	var v_by2: Variant = null
	var v_bs: Variant = null
	var v_sx2: Variant = null
	var v_sy2: Variant = null
	var v_fx: Variant = null
	var v_sxx: Variant = null
	var v_fy: Variant = null
	var v_decor: Variant = p_decor
	v_stoneBand = game.shop_background._closure_73.bind({"241:TASP": _cells["TASP"]})
	game.j_BGDECOR = (v_decor if J.truth(v_decor) else 0.0)
	game.j_BGDAYI = game.shop_background.f_dayiVar()
	game.j_BGCITY = J.getv(game.j_G, "city")
	game.j_BGRAKIP = game.rival_building.f_rakipCepheDurum()
	# REMAKE: HD'de GPU pisirme tuvali
	v_c = game.f_hdBakeTuval()
	J.setv(v_c, "width", game.j_W)
	J.setv(v_c, "height", game.j_H)
	v_g = J.method(v_c, "getContext", ["2d"])
	v_oldctx = game.j_ctx
	game.j_ctx = v_g
	v_TEMA = game.city_system.f_sehirTema()
	v_wallCols = game.city_system.f_duvarPaleti(v_TEMA, v_decor)
	_cells["TASP"][0] = game.city_system.f_tasPaleti(v_TEMA, v_decor)
	game.f_fr(0.0, 0.0, game.j_W, J.add(J.getv(game.j_LAY, "floorY"), 12.0), J.getv(v_wallCols, 3.0))
	# REMAKE kancasi
	if not game.f_hdDuvar(v_wallCols):
		v_TS = 18.0
		v_ty = (-J.n(8.0))
		while J.lt(v_ty, J.add(J.getv(game.j_LAY, "floorY"), 4.0)):
			v_tx = 0.0
			while J.lt(v_tx, game.j_W):
				v_hsh = game.f_hash1(J.add((v_tx * 0.37), (v_ty * 1.13)))
				v_base = (J.getv(v_wallCols, 0.0) if J.lt(v_hsh, 0.18) else (J.getv(v_wallCols, 1.0) if J.lt(v_hsh, 0.62) else J.getv(v_wallCols, 2.0)))
				game.f_fr(J.add(v_tx, 1.0), J.add(v_ty, 1.0), (v_TS - 1.0), (v_TS - 1.0), v_base)
				game.f_hl(J.add(v_tx, 1.0), J.add(v_ty, 1.0), (v_TS - 1.0), ("#8dc4dc" if J.lt(v_hsh, 0.18) else J.getv(v_wallCols, 0.0)))
				game.f_vl(J.add(v_tx, 1.0), J.add(v_ty, 1.0), (v_TS - 1.0), (J.getv(v_wallCols, 0.0) if J.lt(v_hsh, 0.5) else v_base))
				game.f_hl(J.add(v_tx, 1.0), (J.add(v_ty, v_TS) - 1.0), (v_TS - 1.0), J.getv(v_wallCols, 3.0))
				if J.gt(game.f_hash1(J.add((v_tx * 2.7), (v_ty * 0.91))), 0.955):
					v_bw = J.add(5.0, floor((game.f_hash1(J.add(v_tx, v_ty)) * 6.0)))
					v_bh = J.add(4.0, floor((game.f_hash1(J.add((v_tx * 2.0), v_ty)) * 5.0)))
					v_bx = J.add(J.add(v_tx, 3.0), floor((game.f_hash1(J.add((v_tx * 0.5), v_ty)) * 6.0)))
					v_by = J.add(J.add(v_ty, 3.0), floor((game.f_hash1(J.add((v_ty * 0.5), v_tx)) * 6.0)))
					game.f_fr(v_bx, v_by, v_bw, v_bh, "#3c2a24")
					game.f_fr(J.add(v_bx, 1.0), J.add(v_by, 1.0), (v_bw - 2.0), (v_bh - 2.0), "#2a1c18")
					game.f_hl(v_bx, J.add(v_by, v_bh), v_bw, J.getv(v_wallCols, 0.0))
				v_tx = J.add(v_tx, v_TS)
			v_ty = J.add(v_ty, v_TS)
	v_y = 0.0
	while J.lt(v_y, J.getv(game.j_LAY, "floorY")):
		v_a = max(0.0, (0.2 - (v_y * 0.0016)))
		if J.gt(v_a, 0.004):
			J.setv(game.j_ctx, "globalAlpha", v_a)
			game.f_fr(0.0, v_y, game.j_W, 1.0, "#ffffff")
		v_y = J.add(v_y, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_y2 = 0.0
	while J.lt(v_y2, J.getv(game.j_LAY, "floorY")):
		J.setv(game.j_ctx, "globalAlpha", 0.16)
		game.f_fr(0.0, v_y2, 40.0, 1.0, "#000")
		game.f_fr((game.j_W - 40.0), v_y2, 40.0, 1.0, "#000")
		v_y2 = J.add(v_y2, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.street_background.f_bakeStreet()
	# REMAKE kancasi
	if not game.f_hdTasBant(-1.0, _cells["TASP"][0]):
		J.invoke(v_stoneBand, [(-J.n(1.0))])
	if not game.f_hdTasBant(1.0, _cells["TASP"][0]):
		J.invoke(v_stoneBand, [1.0])
	v_Z = J.getv(v_TEMA, "zemin")
	v_zy = J.getv(game.j_LAY, "floorY")
	v_zh = (game.j_H - J.getv(game.j_LAY, "floorY"))
	# REMAKE kancasi
	if not game.f_hdZemin(v_TEMA):
		game.f_fr(0.0, v_zy, game.j_W, v_zh, J.getv(v_Z, 2.0))
		if J.eq(J.getv(v_TEMA, "zeminTip"), "dama"):
			v_dx = (-J.n(8.0))
			while J.lt(v_dx, game.j_W):
				v_dy = v_zy
				while J.lt(v_dy, game.j_H):
					v_kare = fmod(J.n(J.add((int(J.n((float(v_dx) / float(16.0)))) | int(J.n(0.0))), (int(J.n((float(v_dy) / float(8.0)))) | int(J.n(0.0))))), J.n(2.0))
					game.f_fr(v_dx, v_dy, 16.0, 8.0, (J.getv(v_Z, 0.0) if J.truth(v_kare) else J.getv(v_Z, 2.0)))
					v_dy = J.add(v_dy, 8.0)
				v_dx = J.add(v_dx, 16.0)
			J.setv(game.j_ctx, "globalAlpha", 0.18)
			v_dl = v_zy
			while J.lt(v_dl, game.j_H):
				game.f_hl(0.0, v_dl, game.j_W, J.getv(v_Z, 3.0))
				v_dl = J.add(v_dl, 8.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		else:
			if J.eq(J.getv(v_TEMA, "zeminTip"), "mermer"):
				game.f_fr(0.0, v_zy, game.j_W, v_zh, J.getv(v_Z, 0.0))
				v_mx2 = (-J.n(10.0))
				while J.lt(v_mx2, game.j_W):
					game.f_vl(v_mx2, v_zy, v_zh, J.getv(v_Z, 2.0))
					J.setv(game.j_ctx, "globalAlpha", 0.3)
					v_md = 0.0
					while J.lt(v_md, 3.0):
						v_vx = J.add(J.add(v_mx2, 6.0), (v_md * 11.0))
						game.f_ln(v_vx, J.add(v_zy, 1.0), (J.add(v_vx, 5.0) - (v_md * 3.0)), (game.j_H - 1.0), J.getv(v_Z, 3.0))
						v_md = J.add(v_md, 1.0)
					J.setv(game.j_ctx, "globalAlpha", 1.0)
					v_mx2 = J.add(v_mx2, 38.0)
				game.f_hl(0.0, v_zy, game.j_W, J.getv(v_Z, 1.0))
			else:
				if J.eq(J.getv(v_TEMA, "zeminTip"), "beton"):
					game.f_fr(0.0, v_zy, game.j_W, v_zh, J.getv(v_Z, 1.0))
					v_bx2 = (-J.n(4.0))
					while J.lt(v_bx2, game.j_W):
						game.f_vl(v_bx2, v_zy, v_zh, J.getv(v_Z, 2.0))
						v_bx2 = J.add(v_bx2, 29.0)
					v_by2 = J.add(v_zy, 5.0)
					while J.lt(v_by2, game.j_H):
						J.setv(game.j_ctx, "globalAlpha", 0.22)
						game.f_hl(0.0, v_by2, game.j_W, J.getv(v_Z, 3.0))
						J.setv(game.j_ctx, "globalAlpha", 1.0)
						v_by2 = J.add(v_by2, 7.0)
					v_bs = 0.0
					while J.lt(v_bs, 260.0):
						v_sx2 = floor((game.f_hash1((v_bs * 3.7)) * game.j_W))
						v_sy2 = J.add(v_zy, floor((game.f_hash1((v_bs * 8.1)) * v_zh)))
						game.f_px(v_sx2, v_sy2, (J.getv(v_Z, 0.0) if J.gt(game.f_hash1(v_bs), 0.5) else J.getv(v_Z, 3.0)))
						v_bs = J.add(v_bs, 1.0)
				else:
					v_fx = (-J.n(6.0))
					while J.lt(v_fx, game.j_W):
						v_sxx = J.add(v_fx, floor((game.f_hash1(v_fx) * 4.0)))
						game.f_vl(v_sxx, v_zy, v_zh, J.getv(v_Z, 3.0))
						v_fy = v_zy
						while J.lt(v_fy, game.j_H):
							if J.gt(game.f_hash1(J.add((v_sxx * 1.3), (v_fy * 2.1))), 0.8):
								game.f_px(J.add(J.add(v_sxx, 1.0), floor((game.f_hash1(v_fy) * 12.0))), v_fy, J.getv(v_Z, 1.0))
							v_fy = J.add(v_fy, 1.0)
						v_fx = J.add(v_fx, 17.0)
					game.f_hl(0.0, v_zy, game.j_W, J.getv(v_Z, 1.0))
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_fr(0.0, J.getv(game.j_LAY, "floorY"), game.j_W, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.j_ctx = v_oldctx
	game.j_BG = v_c
	game.shop_background.f_bakeStoneFG()
	return v_c
	return null

func _closure_73(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_y: Variant = null
	var v_edge: Variant = null
	var v_x0: Variant = null
	var v_x1: Variant = null
	var v_x: Variant = null
	var v_row: Variant = null
	var v_off: Variant = null
	var v_col: Variant = null
	var v_seamX: Variant = null
	var v_seamY: Variant = null
	var v_v: Variant = null
	var v_TS: Variant = null
	var v_c: Variant = null
	var v_side: Variant = null
	v_side = J.arg(_args, 0)
	v_y = 0.0
	while J.lt(v_y, J.add(J.getv(game.j_LAY, "floorY"), 12.0)):
		v_edge = (game.shop_background.f_archL(v_y) if J.lt(v_side, 0.0) else game.shop_background.f_archR(v_y))
		v_x0 = (0.0 if J.lt(v_side, 0.0) else v_edge)
		v_x1 = (v_edge if J.lt(v_side, 0.0) else game.j_W)
		v_x = v_x0
		while J.lt(v_x, v_x1):
			v_row = floor((float(v_y) / float(13.0)))
			v_off = (11.0 if J.truth((int(J.n(v_row)) & int(J.n(1.0)))) else 0.0)
			v_col = floor((float(J.add(v_x, v_off)) / float(23.0)))
			v_seamX = J.eq(fmod(J.n(J.add(v_x, v_off)), J.n(23.0)), 0.0)
			v_seamY = J.eq(fmod(J.n(v_y), J.n(13.0)), 0.0)
			v_v = game.f_hash1(J.add((v_row * 7.3), (v_col * 3.1)))
			v_TS = _captures["241:TASP"][0]
			if (J.truth(v_seamX) or J.truth(v_seamY)):
				v_c = J.getv(v_TS, 4.0)
			else:
				if J.lt(fmod(J.n(v_y), J.n(13.0)), 2.0):
					v_c = J.getv(v_TS, 0.0)
				else:
					if J.gt(fmod(J.n(v_y), J.n(13.0)), 10.0):
						v_c = J.getv(v_TS, 3.0)
					else:
						v_c = (J.getv(v_TS, 0.0) if J.lt(v_v, 0.3) else (J.getv(v_TS, 1.0) if J.lt(v_v, 0.72) else J.getv(v_TS, 2.0)))
			if J.gt(game.f_hash1(J.add((v_x * 1.7), (v_y * 2.3))), 0.93):
				v_c = (J.getv(v_TS, 0.0) if J.lt(v_v, 0.5) else J.getv(v_TS, 3.0))
			game.f_px(v_x, v_y, v_c)
			v_x = J.add(v_x, 1.0)
		if J.lt(v_side, 0.0):
			game.f_px((v_edge - 1.0), v_y, J.getv(_captures["241:TASP"][0], 4.0))
			game.f_px((v_edge - 2.0), v_y, J.getv(_captures["241:TASP"][0], 3.0))
			game.f_px(v_edge, v_y, "rgba(0,0,0,.35)")
		else:
			game.f_px(v_edge, v_y, J.getv(_captures["241:TASP"][0], 4.0))
			game.f_px(J.add(v_edge, 1.0), v_y, J.getv(_captures["241:TASP"][0], 3.0))
			game.f_px((v_edge - 1.0), v_y, "rgba(0,0,0,.35)")
		v_y = J.add(v_y, 1.0)
	return null
