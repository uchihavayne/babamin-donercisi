# Sauce draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:4923
func f_sauceSlotX(p_i: Variant = null) -> Variant:
	var v_i: Variant = p_i
	return J.add(J.add(J.getv(J.getv(game.j_ST, "sauce"), "x"), 5.0), (v_i * 15.0))
	return null

# art.js:4937
func f_drawSauceBottle(p_cx: Variant = null, p_taban: Variant = null, p_S: Variant = null, p_d: Variant = null, p_dolu: Variant = null) -> Variant:
	var v_hw: Variant = null
	var v_gy: Variant = null
	var v_koy: Variant = null
	var v_ac: Variant = null
	var v_dz: Variant = null
	var v_i: Variant = null
	var v_ow: Variant = null
	var v_ny: Variant = null
	var v_ky: Variant = null
	var v_cx: Variant = p_cx
	var v_taban: Variant = p_taban
	var v_S: Variant = p_S
	var v_d: Variant = p_d
	var v_dolu: Variant = p_dolu
	v_hw = (int(J.n(J.getv(v_S, "w"))) >> int(J.n(1.0)))
	v_gy = (v_taban - J.getv(v_S, "gov"))
	v_koy = game.character_draw.f_shadeCol(J.getv(v_d, "c1"), 0.56)
	v_ac = game.character_draw.f_shadeCol(J.getv(v_d, "c1"), 1.2)
	v_dz = max(2.0, floor(((J.getv(v_S, "gov") - 2.0) * game.math_utils.f_clamp(v_dolu, 0.0, 1.0)) + 0.5))
	game.f_fr((v_cx - v_hw), v_gy, J.getv(v_S, "w"), J.getv(v_S, "gov"), J.getv(v_d, "c0"))
	game.f_fr(J.add((v_cx - v_hw), 1.0), J.add(v_gy, 1.0), (J.getv(v_S, "w") - 2.0), (J.getv(v_S, "gov") - 2.0), v_koy)
	game.f_fr(J.add((v_cx - v_hw), 1.0), (v_taban - v_dz), (J.getv(v_S, "w") - 2.0), (v_dz - 1.0), J.getv(v_d, "c1"))
	game.f_hl(J.add((v_cx - v_hw), 1.0), (v_taban - v_dz), (J.getv(v_S, "w") - 2.0), J.getv(v_d, "c2"))
	game.f_vl(J.add((v_cx - v_hw), 1.0), J.add(v_gy, 2.0), (J.getv(v_S, "gov") - 4.0), v_ac)
	game.f_vl((J.add(v_cx, v_hw) - 2.0), J.add(v_gy, 2.0), (J.getv(v_S, "gov") - 4.0), game.character_draw.f_shadeCol(J.getv(v_d, "c0"), 0.84))
	v_i = 0.0
	while J.lt(v_i, J.getv(v_S, "omuz")):
		v_ow = max(3.0, floor((v_hw - (float(((v_hw - 3.0) * J.add(v_i, 1.0))) / float(J.getv(v_S, "omuz")))) + 0.5))
		game.f_fr((v_cx - v_ow), ((v_gy - v_i) - 1.0), (v_ow * 2.0), 1.0, J.getv(v_d, "c0"))
		game.f_fr(J.add((v_cx - v_ow), 1.0), ((v_gy - v_i) - 1.0), ((v_ow * 2.0) - 2.0), 1.0, v_koy)
		game.f_px(J.add((v_cx - v_ow), 1.0), ((v_gy - v_i) - 1.0), v_ac)
		v_i = J.add(v_i, 1.0)
	v_ny = (v_gy - J.getv(v_S, "omuz"))
	game.f_fr((v_cx - 3.0), (v_ny - J.getv(v_S, "boyun")), 6.0, J.getv(v_S, "boyun"), J.getv(v_d, "c0"))
	game.f_fr((v_cx - 2.0), (v_ny - J.getv(v_S, "boyun")), 4.0, J.getv(v_S, "boyun"), v_koy)
	v_ky = (v_ny - J.getv(v_S, "boyun"))
	game.f_fr((v_cx - 4.0), (v_ky - 2.0), 8.0, 2.0, game.character_draw.f_shadeCol(J.getv(v_d, "cap"), 0.72))
	game.f_fr((v_cx - 3.0), (v_ky - 6.0), 6.0, 4.0, J.getv(v_d, "cap"))
	game.f_hl((v_cx - 3.0), (v_ky - 6.0), 6.0, game.character_draw.f_shadeCol(J.getv(v_d, "cap"), 1.55))
	game.f_fr((v_cx - 1.0), (v_ky - 8.0), 2.0, 2.0, game.character_draw.f_shadeCol(J.getv(v_d, "cap"), 1.25))
	return null

# art.js:4967
func f_drawSauceStation(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_on: Variant = null, p_isk: Variant = null, p_fx: Variant = null, p_t: Variant = null) -> Variant:
	var v_v: Variant = null
	var v_i: Variant = null
	var v_d: Variant = null
	var v_open: Variant = null
	var v_S: Variant = null
	var v_cx0: Variant = null
	var v_sq: Variant = null
	var v_lift: Variant = null
	var v_taban: Variant = null
	var v_ez: Variant = null
	var v_eh: Variant = null
	var v_ey0: Variant = null
	var v_hw3: Variant = null
	var v_lcx: Variant = null
	var v_lcy: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_on: Variant = p_on
	var v_isk: Variant = p_isk
	var v_fx: Variant = p_fx
	var v_t: Variant = p_t
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 40.0), (v_w - 4.0), 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_x, J.add(v_y, 34.0), v_w, 7.0, "#5e3f1e")
	game.f_fr(v_x, J.add(v_y, 34.0), v_w, 6.0, "#8a5f2e")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 34.0), (v_w - 2.0), "#b98246")
	v_v = 4.0
	while J.lt(v_v, (v_w - 3.0)):
		game.f_vl(J.add(v_x, v_v), J.add(v_y, 35.0), 5.0, "#7a5228")
		v_v = J.add(v_v, 8.0)
	J.setv(game.j_ctx, "globalAlpha", 0.32)
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 6.0), (v_w - 2.0), 28.0, "#2a2018")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.lt(v_i, 3.0):
		v_d = J.getv(game.j_SAUCE_DEF, v_i)
		v_open = (v_isk if J.eq(v_i, 2.0) else v_on)
		v_S = J.getv(game.j_SISE_BOY, v_i)
		v_cx0 = J.add(game.f_sauceSlotX(v_i), 5.0)
		v_sq = (J.getv(v_fx, J.getv(v_d, "id")) if (J.truth(v_fx) and J.gt(J.getv(v_fx, J.getv(v_d, "id")), 0.0)) else 0.0)
		v_lift = floor((sin((game.math_utils.f_clamp(v_sq, 0.0, 1.0) * J.getv({"PI": PI}, "PI"))) * 5.0) + 0.5)
		v_taban = (J.add(v_y, 34.0) - v_lift)
		if J.gt(v_lift, 0.0):
			J.setv(game.j_ctx, "globalAlpha", 0.2)
			game.f_ell(v_cx0, J.add(v_y, 35.0), 6.0, 2.0, "#000")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		if (not J.truth(v_open)):
			J.setv(game.j_ctx, "globalAlpha", 0.26)
		game.sauce_draw.f_drawSauceBottle(v_cx0, v_taban, v_S, v_d, J.add(0.55, (v_i * 0.15)))
		if J.gt(v_sq, 0.0):
			v_ez = (v_taban - floor((J.getv(v_S, "gov") * 0.55) + 0.5))
			game.f_fr(((v_cx0 - (int(J.n(J.getv(v_S, "w"))) >> int(J.n(1.0)))) - 2.0), v_ez, J.add(J.getv(v_S, "w"), 4.0), 6.0, J.getv(v_d, "c1"))
			game.f_px(((v_cx0 - (int(J.n(J.getv(v_S, "w"))) >> int(J.n(1.0)))) - 2.0), v_ez, J.getv(v_d, "c0"))
			game.f_px(J.add(J.add(v_cx0, (int(J.n(J.getv(v_S, "w"))) >> int(J.n(1.0)))), 1.0), v_ez, J.getv(v_d, "c0"))
		v_eh = (9.0 if J.gt(J.getv(v_S, "gov"), 14.0) else 7.0)
		v_ey0 = J.add((v_taban - J.getv(v_S, "gov")), 3.0)
		v_hw3 = (int(J.n(J.getv(v_S, "w"))) >> int(J.n(1.0)))
		game.f_fr((v_cx0 - v_hw3), v_ey0, J.getv(v_S, "w"), v_eh, "#cfc7b2")
		game.f_fr((v_cx0 - v_hw3), v_ey0, (J.getv(v_S, "w") - 1.0), (v_eh - 1.0), "#f4efe0")
		game.f_hl((v_cx0 - v_hw3), v_ey0, (J.getv(v_S, "w") - 1.0), "#ffffff")
		v_lcx = v_cx0
		v_lcy = J.add(v_ey0, (int(J.n(v_eh)) >> int(J.n(1.0))))
		if J.eq(v_i, 0.0):
			game.f_ell(v_lcx, J.add(v_lcy, 1.0), 3.0, 2.0, "#8e1c14")
			game.f_ell(v_lcx, v_lcy, 3.0, 2.0, "#e2382a")
			game.f_px((v_lcx - 2.0), (v_lcy - 1.0), "#ff7a62")
			game.f_px(J.add(v_lcx, 2.0), (v_lcy - 2.0), "#4a7a20")
			game.f_px(J.add(v_lcx, 3.0), (v_lcy - 3.0), "#5a8a2a")
		else:
			if J.eq(v_i, 1.0):
				game.f_ell(v_lcx, J.add(v_lcy, 1.0), 3.0, 3.0, "#cfc7b2")
				game.f_ell(v_lcx, v_lcy, 3.0, 3.0, "#ffffff")
				game.f_px((v_lcx - 1.0), v_lcy, "#cfc7b2")
				game.f_px(J.add(v_lcx, 1.0), v_lcy, "#cfc7b2")
				game.f_px(v_lcx, (v_lcy - 3.0), "#a89a78")
			else:
				game.f_fr((v_lcx - 3.0), (v_lcy - 2.0), 7.0, 5.0, "#c98a1a")
				game.f_fr((v_lcx - 3.0), (v_lcy - 2.0), 6.0, 4.0, "#f0b53c")
				game.f_hl((v_lcx - 3.0), (v_lcy - 2.0), 6.0, "#ffd77a")
		if (not J.truth(v_open)):
			game.f_fr((v_cx0 - 3.0), (v_taban - 8.0), 6.0, 5.0, "#8a929b")
			game.f_rc((v_cx0 - 2.0), (v_taban - 12.0), 4.0, 5.0, "#8a929b")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_i = J.add(v_i, 1.0)
	game.text_draw.f_txt("SOS", J.add(v_x, (float(v_w) / float(2.0))), J.add(v_y, 41.0), "rgba(255,255,255,.5)", {"align": "c", "outline": "rgba(0,0,0,.5)"})
	return null

