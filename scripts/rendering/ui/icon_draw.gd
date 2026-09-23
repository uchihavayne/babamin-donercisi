# Icon draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# food.js:785
func f_icon(p_id: Variant = null, p_x: Variant = null, p_y: Variant = null, p_t: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdIkon(p_id, p_x, p_y): return null
	# REMAKE kancasi (onbellek)
	if game.f_ikonOnbellek(p_id, p_x, p_y, p_t): return null
	var v_pi: Variant = null
	var v_pj: Variant = null
	var v_ay: Variant = null
	var v_aw: Variant = null
	var v_ay2: Variant = null
	var v_ayy: Variant = null
	var v_aw2: Variant = null
	var v_ay3: Variant = null
	var v_aw3: Variant = null
	var v_fi: Variant = null
	var v_fxx: Variant = null
	var v_fyy: Variant = null
	var v_kr: Variant = null
	var v_ku: Variant = null
	var v_kg: Variant = null
	var v_kx2: Variant = null
	var v_ky2: Variant = null
	var v_kb: Variant = null
	var v_kbg: Variant = null
	var v_swi: Variant = null
	var v_sx2: Variant = null
	var v_ii: Variant = null
	var v_ix: Variant = null
	var v_id: Variant = p_id
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	match v_id:
		"wrap":
			game.f_rrect((v_x - 7.0), (v_y - 3.0), 14.0, 8.0, 3.0, "#a87a41")
			game.f_rrect((v_x - 7.0), (v_y - 4.0), 14.0, 8.0, 3.0, "#f0d5a8")
			game.f_rrect((v_x - 5.0), (v_y - 3.0), 10.0, 3.0, 2.0, "#f8e6c4")
			game.f_fr((v_x - 6.0), (v_y - 4.0), 5.0, 8.0, "#f4f2ea")
			game.f_fr((v_x - 5.0), (v_y - 2.0), 3.0, 1.0, "#d8352c")
			game.f_fr((v_x - 5.0), v_y, 3.0, 1.0, "#2f5f9e")
			game.f_px(J.add(v_x, 5.0), (v_y - 2.0), J.getv(game.j_P, "m2"))
			game.f_px(J.add(v_x, 4.0), J.add(v_y, 1.0), J.getv(game.j_P, "m3"))
			game.f_px(J.add(v_x, 3.0), (v_y - 2.0), J.getv(game.j_P, "g1"))
			game.f_ln((v_x - 1.0), (v_y - 4.0), J.add(v_x, 1.0), J.add(v_y, 4.0), "#c9a06a")
			game.f_ln(J.add(v_x, 2.0), (v_y - 4.0), J.add(v_x, 4.0), J.add(v_y, 4.0), "#c9a06a")
		"pide":
			game.f_ell(v_x, J.add(v_y, 2.0), 8.0, 4.0, "#a87a41")
			game.f_ell(v_x, J.add(v_y, 1.0), 8.0, 4.0, "#d9a765")
			game.f_ell(v_x, v_y, 7.0, 3.0, "#eec78c")
			game.f_fr((v_x - 6.0), (v_y - 2.0), 12.0, 3.0, "#8a5f31")
			v_pi = 0.0
			while J.lt(v_pi, 4.0):
				game.f_px(J.add((v_x - 5.0), (v_pi * 3.0)), (v_y - 2.0), game.f_meatCol(0.85, 1.0))
				v_pi = J.add(v_pi, 1.0)
			v_pj = 0.0
			while J.lt(v_pj, 3.0):
				game.f_px(J.add((v_x - 4.0), (v_pj * 4.0)), (v_y - 1.0), J.getv(game.j_P, "g1"))
				v_pj = J.add(v_pj, 1.0)
			game.f_hl((v_x - 5.0), (v_y - 3.0), 10.0, "#f4dcae")
		"cola":
			game.f_fr((v_x - 4.0), (v_y - 7.0), 9.0, 14.0, "rgba(235,244,250,.55)")
			game.f_fr((v_x - 3.0), (v_y - 3.0), 7.0, 9.0, J.getv(game.j_P, "cola"))
			game.f_fr((v_x - 3.0), (v_y - 3.0), 7.0, 2.0, J.getv(game.j_P, "cola2"))
			game.f_px((v_x - 3.0), (v_y - 1.0), "#7a4620")
			game.f_px(J.add(v_x, 2.0), J.add(v_y, 2.0), "#7a4620")
			game.f_rc((v_x - 4.0), (v_y - 7.0), 9.0, 14.0, "#ffffff")
			game.f_vl((v_x - 3.0), (v_y - 6.0), 12.0, "rgba(255,255,255,.7)")
			game.f_ln(J.add(v_x, 2.0), (v_y - 10.0), J.add(v_x, 3.0), (v_y - 5.0), "#e2382a")
			game.f_ln(J.add(v_x, 3.0), (v_y - 10.0), J.add(v_x, 4.0), (v_y - 5.0), "#ffffff")
		"fanta", "orange":
			game.f_fr((v_x - 4.0), (v_y - 7.0), 9.0, 14.0, "rgba(235,244,250,.55)")
			game.f_fr((v_x - 3.0), (v_y - 4.0), 7.0, 10.0, J.getv(game.j_P, "or1"))
			game.f_fr((v_x - 3.0), (v_y - 4.0), 7.0, 3.0, J.getv(game.j_P, "or0"))
			game.f_px((v_x - 2.0), (v_y - 3.0), "#ffd98a")
			game.f_rc((v_x - 4.0), (v_y - 7.0), 9.0, 14.0, "#ffffff")
			game.f_vl((v_x - 3.0), (v_y - 6.0), 12.0, "rgba(255,255,255,.7)")
			game.f_ln(J.add(v_x, 2.0), (v_y - 10.0), J.add(v_x, 3.0), (v_y - 5.0), "#3f79c0")
			game.f_ln(J.add(v_x, 3.0), (v_y - 10.0), J.add(v_x, 4.0), (v_y - 5.0), "#ffffff")
		"ayran":
			J.setv(game.j_ctx, "globalAlpha", 0.3)
			v_ay = 0.0
			while J.lt(v_ay, 14.0):
				v_aw = J.add(4.0, floor((v_ay * 0.12) + 0.5))
				game.f_fr((v_x - v_aw), J.add((v_y - 6.0), v_ay), (v_aw * 2.0), 1.0, "#dfeaf0")
				v_ay = J.add(v_ay, 1.0)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			v_ay2 = 0.0
			while J.lt(v_ay2, 12.0):
				v_ayy = (J.add(v_y, 7.0) - v_ay2)
				v_aw2 = J.add(4.0, floor(((13.0 - v_ay2) * 0.12) + 0.5))
				game.f_fr(J.add((v_x - v_aw2), 1.0), v_ayy, ((v_aw2 * 2.0) - 2.0), 1.0, ("#ffffff" if J.eq(v_ay2, 11.0) else "#e4e2d8"))
				v_ay2 = J.add(v_ay2, 1.0)
			game.f_hl((v_x - 3.0), (v_y - 4.0), 7.0, "#ffffff")
			v_ay3 = 0.0
			while J.lt(v_ay3, 14.0):
				v_aw3 = J.add(4.0, floor((v_ay3 * 0.12) + 0.5))
				game.f_px((v_x - v_aw3), J.add((v_y - 6.0), v_ay3), "rgba(255,255,255,.75)")
				game.f_px((J.add(v_x, v_aw3) - 1.0), J.add((v_y - 6.0), v_ay3), "rgba(200,220,230,.85)")
				v_ay3 = J.add(v_ay3, 1.0)
			game.f_hl((v_x - 4.0), (v_y - 6.0), 9.0, "#ffffff")
			game.f_ln(J.add(v_x, 1.0), (v_y - 9.0), J.add(v_x, 3.0), (v_y - 3.0), "#3f79c0")
			game.f_ln(J.add(v_x, 2.0), (v_y - 9.0), J.add(v_x, 4.0), (v_y - 3.0), "#ffffff")
		"fbox", "fries":
			v_fi = 0.0
			while J.lt(v_fi, 5.0):
				v_fxx = J.add((v_x - 5.0), (v_fi * 2.4))
				v_fyy = ((v_y - 7.0) - (fmod(J.n(v_fi), J.n(2.0)) * 2.0))
				game.f_fr(v_fxx, v_fyy, 2.0, 7.0, J.getv(game.j_P, "p2"))
				game.f_fr(v_fxx, v_fyy, 2.0, 6.0, J.getv(game.j_P, "p1"))
				game.f_px(v_fxx, v_fyy, J.getv(game.j_P, "p0"))
				v_fi = J.add(v_fi, 1.0)
			v_kr = 0.0
			while J.lt(v_kr, 10.0):
				v_ku = (float(v_kr) / float(9.0))
				v_kg = floor(J.add(15.0, ((8.0 - 15.0) * v_ku)) + 0.5)
				v_kx2 = floor((v_x - (float(v_kg) / float(2.0))) + 0.5)
				v_ky2 = J.add((v_y - 1.0), v_kr)
				game.f_fr(v_kx2, v_ky2, v_kg, 1.0, "#7d1610")
				game.f_fr(J.add(v_kx2, 1.0), v_ky2, (v_kg - 2.0), 1.0, ("#e8483a" if J.lt(v_ku, 0.16) else "#c22a20"))
				game.f_px(J.add(v_kx2, 1.0), v_ky2, "#ff7f6c")
				game.f_px((J.add(v_kx2, v_kg) - 2.0), v_ky2, "#5e120d")
				v_kr = J.add(v_kr, 1.0)
			game.f_fr((v_x - 6.0), (v_y - 1.0), 13.0, 2.0, "#5e120d")
			game.f_hl((v_x - 6.0), (v_y - 1.0), 13.0, "#ff7f6c")
			v_kb = 0.0
			while J.lt(v_kb, 4.0):
				v_kbg = (floor(J.add(15.0, ((8.0 - 15.0) * (float(J.add(v_kb, 3.0)) / float(9.0)))) + 0.5) - 3.0)
				game.f_fr(floor((v_x - (float(v_kbg) / float(2.0))) + 0.5), J.add(J.add(v_y, 2.0), v_kb), v_kbg, 1.0, ("#ffe98e" if J.eq(v_kb, 0.0) else ("#f7d34a" if J.lt(v_kb, 2.0) else "#e0be32")))
				v_kb = J.add(v_kb, 1.0)
		"sweet":
			game.f_ell(v_x, J.add(v_y, 4.0), 9.0, 3.0, "#c9cfd6")
			game.f_ell(v_x, J.add(v_y, 3.0), 9.0, 3.0, "#eef2f5")
			v_swi = 0.0
			while J.lt(v_swi, 2.0):
				v_sx2 = J.add((v_x - 4.0), (v_swi * 8.0))
				game.f_fr((v_sx2 - 3.0), J.add(v_y, 1.0), 7.0, 2.0, "#8a5a1a")
				game.f_hl((v_sx2 - 3.0), J.add(v_y, 1.0), 7.0, "#a8762a")
				game.f_fr((v_sx2 - 1.0), (v_y - 3.0), 3.0, 1.0, "#e8bd62")
				game.f_fr((v_sx2 - 3.0), (v_y - 2.0), 7.0, 1.0, "#e8bd62")
				game.f_fr((v_sx2 - 2.0), (v_y - 1.0), 5.0, 1.0, "#cf9c47")
				game.f_fr((v_sx2 - 1.0), v_y, 3.0, 1.0, "#cf9c47")
				game.f_px(v_sx2, (v_y - 2.0), "#6b9440")
				game.f_px((v_sx2 - 1.0), (v_y - 3.0), "#ffdf9a")
				v_swi = J.add(v_swi, 1.0)
		"pickle":
			game.f_ell((v_x - 2.0), J.add(v_y, 1.0), 3.0, 2.0, J.getv(game.j_P, "g3"))
			game.f_ell((v_x - 2.0), v_y, 3.0, 2.0, J.getv(game.j_P, "g2"))
			game.f_ell(J.add(v_x, 3.0), J.add(v_y, 2.0), 3.0, 2.0, J.getv(game.j_P, "g3"))
			game.f_ell(J.add(v_x, 3.0), J.add(v_y, 1.0), 3.0, 2.0, J.getv(game.j_P, "g2"))
			game.f_px((v_x - 3.0), (v_y - 1.0), J.getv(game.j_P, "g0"))
			game.f_px(J.add(v_x, 2.0), v_y, J.getv(game.j_P, "g0"))
		"iskender":
			game.f_ell(v_x, J.add(v_y, 4.0), 8.0, 3.0, "#b6bec6")
			game.f_ell(v_x, J.add(v_y, 3.0), 8.0, 3.0, "#eef2f5")
			game.f_ell(v_x, J.add(v_y, 3.0), 6.0, 2.0, "#dbe2e8")
			v_ii = 0.0
			while J.lt(v_ii, 4.0):
				v_ix = J.add((v_x - 5.0), (v_ii * 3.0))
				game.f_fr(v_ix, v_y, 3.0, 3.0, "#8a5f31")
				game.f_fr(v_ix, v_y, 3.0, 2.0, "#d9a765")
				v_ii = J.add(v_ii, 1.0)
			game.f_fr((v_x - 5.0), (v_y - 3.0), 4.0, 3.0, "#7a4318")
			game.f_fr((v_x - 5.0), (v_y - 3.0), 4.0, 2.0, "#c98436")
			game.f_fr(J.add(v_x, 1.0), (v_y - 3.0), 4.0, 3.0, "#7a4318")
			game.f_fr(J.add(v_x, 1.0), (v_y - 3.0), 4.0, 2.0, "#c98436")
			game.f_ln((v_x - 5.0), (v_y - 1.0), J.add(v_x, 5.0), (v_y - 1.0), "#e2621c")
			game.f_ell(J.add(v_x, 5.0), J.add(v_y, 2.0), 3.0, 2.0, J.getv(game.j_P, "s0"))
			game.f_px(J.add(v_x, 4.0), J.add(v_y, 1.0), "#ffffff")
		"garlic":
			game.f_ell(v_x, J.add(v_y, 3.0), 5.0, 4.0, "#cfc7b2")
			game.f_ell(v_x, J.add(v_y, 2.0), 5.0, 4.0, "#f6f2e6")
			game.f_ell((v_x - 2.0), J.add(v_y, 2.0), 2.0, 3.0, "#ffffff")
			game.f_ln(v_x, (v_y - 3.0), v_x, (v_y - 1.0), "#b0a88e")
			game.f_px((v_x - 1.0), (v_y - 3.0), "#8a8470")
		"sauce":
			game.f_ell(v_x, J.add(v_y, 2.0), 6.0, 3.0, J.getv(game.j_P, "s2"))
			game.f_ell(v_x, J.add(v_y, 1.0), 6.0, 3.0, J.getv(game.j_P, "s0"))
			game.f_px((v_x - 2.0), v_y, "#ffffff")
			game.f_px(J.add(v_x, 2.0), J.add(v_y, 1.0), "#ffffff")
		"hot":
			game.f_ell(v_x, J.add(v_y, 1.0), 5.0, 3.0, "#a81f18")
			game.f_ell(v_x, v_y, 5.0, 3.0, "#e2352a")
			game.f_px((v_x - 3.0), (v_y - 1.0), "#ff6a55")
			game.f_ln(J.add(v_x, 4.0), (v_y - 3.0), J.add(v_x, 5.0), (v_y - 5.0), J.getv(game.j_P, "g2"))
		"meat":
			game.f_fr((v_x - 5.0), (v_y - 2.0), 5.0, 4.0, game.f_meatCol(0.8, 0.8))
			game.f_fr((v_x - 5.0), (v_y - 2.0), 5.0, 3.0, game.f_meatCol(0.8, 1.05))
			game.f_fr(J.add(v_x, 1.0), (v_y - 1.0), 5.0, 4.0, game.f_meatCol(0.9, 0.8))
			game.f_fr(J.add(v_x, 1.0), (v_y - 1.0), 5.0, 3.0, game.f_meatCol(0.9, 1.05))
		"falafel":
			game.f_ell((v_x - 3.0), J.add(v_y, 1.0), 4.0, 3.0, J.getv(game.j_P, "m4"))
			game.f_ell((v_x - 3.0), v_y, 4.0, 3.0, J.getv(game.j_P, "m3"))
			game.f_ell(J.add(v_x, 3.0), J.add(v_y, 2.0), 4.0, 3.0, J.getv(game.j_P, "m4"))
			game.f_ell(J.add(v_x, 3.0), J.add(v_y, 1.0), 4.0, 3.0, J.getv(game.j_P, "m3"))
		"plate":
			game.f_ell(v_x, J.add(v_y, 4.0), 9.0, 3.0, "#a9b0b8")
			game.f_ell(v_x, J.add(v_y, 3.0), 9.0, 3.0, "#eef2f5")
			game.f_ell(v_x, J.add(v_y, 2.0), 6.0, 2.0, "#d7dde3")
			game.f_ell((v_x - 4.0), v_y, 4.0, 3.0, J.getv(game.j_P, "m4"))
			game.f_ell((v_x - 4.0), (v_y - 1.0), 4.0, 3.0, J.getv(game.j_P, "m3"))
			game.f_px((v_x - 5.0), (v_y - 2.0), J.getv(game.j_P, "m1"))
			game.f_ell(J.add(v_x, 3.0), J.add(v_y, 1.0), 4.0, 3.0, J.getv(game.j_P, "m4"))
			game.f_ell(J.add(v_x, 3.0), v_y, 4.0, 3.0, J.getv(game.j_P, "m3"))
			game.f_px(J.add(v_x, 2.0), (v_y - 1.0), J.getv(game.j_P, "m1"))
			game.f_px((v_x - 1.0), (v_y - 3.0), J.getv(game.j_P, "g1"))
			game.f_px(J.add(v_x, 1.0), (v_y - 3.0), J.getv(game.j_P, "g2"))
			game.f_fr(J.add(v_x, 5.0), (v_y - 4.0), 1.0, 4.0, J.getv(game.j_P, "p1"))
			game.f_fr(J.add(v_x, 7.0), (v_y - 3.0), 1.0, 3.0, J.getv(game.j_P, "p1"))
		"coin":
			game.f_ell(v_x, v_y, 5.0, 5.0, J.getv(game.j_P, "au3"))
			game.f_ell(v_x, (v_y - 1.0), 5.0, 5.0, J.getv(game.j_P, "au1"))
			game.f_ell(v_x, (v_y - 1.0), 3.0, 3.0, J.getv(game.j_P, "au0"))
			game.f_px((v_x - 2.0), (v_y - 3.0), "#ffffff")
		"star":
			game.icon_draw.f_drawStar(v_x, v_y, 5.0, J.getv(game.j_P, "au1"), J.getv(game.j_P, "au3"))
		"heart":
			game.icon_draw.f_drawHeart(v_x, v_y, 1.0, "#e2483a")
	return null

# food.js:957
func f_drawStar(p_cx: Variant = null, p_cy: Variant = null, p_r: Variant = null, p_col: Variant = null, p_col2: Variant = null) -> Variant:
	var v_pat: Variant = null
	var v_s: Variant = null
	var v_ox: Variant = null
	var v_oy: Variant = null
	var v_y: Variant = null
	var v_x: Variant = null
	var v_c: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_r: Variant = p_r
	var v_col: Variant = p_col
	var v_col2: Variant = p_col2
	v_pat = [".....#.....", "....###....", "....###....", "###########", ".#########.", "..#######..", "..#######..", ".###...###.", "##.......##"]
	v_s = max(1.0, floor((float(v_r) / float(5.0)) + 0.5))
	v_ox = (v_cx - floor((5.5 * v_s) + 0.5))
	v_oy = (v_cy - floor((4.0 * v_s) + 0.5))
	v_y = 0.0
	while J.lt(v_y, J.getv(v_pat, "length")):
		v_x = 0.0
		while J.lt(v_x, 11.0):
			if not J.eq(J.getv(J.getv(v_pat, v_y), v_x), "#"):
				v_x = J.add(v_x, 1.0)
				continue
			v_c = (v_col if (J.lt(v_y, 2.0) or ((J.lt(v_y, 5.0) and J.gt(v_x, 2.0)) and J.lt(v_x, 8.0))) else ((v_col2 if J.truth(v_col2) else v_col) if J.gt(v_y, 6.0) else v_col))
			game.f_fr(J.add(v_ox, (v_x * v_s)), J.add(v_oy, (v_y * v_s)), v_s, v_s, v_c)
			v_x = J.add(v_x, 1.0)
		v_y = J.add(v_y, 1.0)
	game.f_fr(J.add(v_ox, (4.0 * v_s)), J.add(v_oy, (1.0 * v_s)), v_s, v_s, "#ffffff")
	game.f_fr(J.add(v_ox, (3.0 * v_s)), J.add(v_oy, (4.0 * v_s)), (v_s * 2.0), v_s, "rgba(255,255,255,.55)")
	return null

# food.js:980
func f_drawHeart(p_cx: Variant = null, p_cy: Variant = null, p_sc: Variant = null, p_col: Variant = null) -> Variant:
	# REMAKE kancasi (hiz)
	if game.f_kalpHizli(p_cx, p_cy, p_sc, p_col): return null
	var v_pat: Variant = null
	var v_y: Variant = null
	var v_x: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_sc: Variant = p_sc
	var v_col: Variant = p_col
	v_pat = [".##.##.", "#######", "#######", ".#####.", "..###..", "...#..."]
	v_y = 0.0
	while J.lt(v_y, J.getv(v_pat, "length")):
		v_x = 0.0
		while J.lt(v_x, J.getv(J.getv(v_pat, v_y), "length")):
			if J.eq(J.getv(J.getv(v_pat, v_y), v_x), "#"):
				game.f_fr(J.add((v_cx - (3.0 * v_sc)), (v_x * v_sc)), J.add((v_cy - (3.0 * v_sc)), (v_y * v_sc)), v_sc, v_sc, v_col)
			v_x = J.add(v_x, 1.0)
		v_y = J.add(v_y, 1.0)
	game.f_px((v_cx - 2.0), (v_cy - 2.0), "rgba(255,255,255,.7)")
	return null

# food.js:993
func f_drawX(p_cx: Variant = null, p_cy: Variant = null, p_col: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_col: Variant = p_col
	# REMAKE kancasi: HD carpi ikonu
	if J.truth(game.f_hdCarpi(v_cx, v_cy, v_col)): return null
	v_i = (-J.n(2.0))
	while J.le(v_i, 2.0):
		game.f_px(J.add(v_cx, v_i), J.add(v_cy, v_i), v_col)
		game.f_px(J.add(v_cx, v_i), (v_cy - v_i), v_col)
		v_i = J.add(v_i, 1.0)
	game.f_px(J.add(v_cx, 3.0), J.add(v_cy, 3.0), v_col)
	game.f_px((v_cx - 3.0), (v_cy - 3.0), v_col)
	game.f_px(J.add(v_cx, 3.0), (v_cy - 3.0), v_col)
	game.f_px((v_cx - 3.0), J.add(v_cy, 3.0), v_col)
	return null

# food.js:997
func f_drawCheck(p_cx: Variant = null, p_cy: Variant = null, p_col: Variant = null) -> Variant:
	var v_cx: Variant = p_cx
	var v_cy: Variant = p_cy
	var v_col: Variant = p_col
	# REMAKE kancasi: HD tik ikonu
	if J.truth(game.f_hdOnay(v_cx, v_cy, v_col)): return null
	game.f_px((v_cx - 3.0), v_cy, v_col)
	game.f_px((v_cx - 2.0), J.add(v_cy, 1.0), v_col)
	game.f_px((v_cx - 1.0), J.add(v_cy, 2.0), v_col)
	game.f_px(v_cx, J.add(v_cy, 1.0), v_col)
	game.f_px(J.add(v_cx, 1.0), v_cy, v_col)
	game.f_px(J.add(v_cx, 2.0), (v_cy - 1.0), v_col)
	game.f_px(J.add(v_cx, 3.0), (v_cy - 2.0), v_col)
	game.f_px((v_cx - 3.0), J.add(v_cy, 1.0), v_col)
	game.f_px(v_cx, J.add(v_cy, 2.0), v_col)
	game.f_px(J.add(v_cx, 3.0), (v_cy - 1.0), v_col)
	return null

# food.js:1004
func f_drawCoin(p_x: Variant = null, p_y: Variant = null, p_v: Variant = null, p_t: Variant = null, p_ph: Variant = null) -> Variant:
	var v_sp: Variant = null
	var v_rx: Variant = null
	var v_big: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_v: Variant = p_v
	var v_t: Variant = p_t
	var v_ph: Variant = p_ph
	# REMAKE kancasi: HD para (donen 3B parca)
	if J.truth(game.f_hdPara(v_x, v_y, v_v, v_t, v_ph)): return null
	v_sp = abs(sin(J.add((v_t * 3.0), (v_ph if J.truth(v_ph) else 0.0))))
	v_rx = max(1.0, floor((5.0 * v_sp) + 0.5))
	v_big = J.ge(v_v, 25.0)
	J.setv(game.j_ctx, "globalAlpha", 0.25)
	game.f_ell(v_x, J.add(v_y, 4.0), 5.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_ell(v_x, v_y, v_rx, 5.0, (J.getv(game.j_P, "au3") if J.truth(v_big) else "#a9a9a9"))
	game.f_ell(v_x, (v_y - 1.0), v_rx, 5.0, (J.getv(game.j_P, "au1") if J.truth(v_big) else "#d8d8d8"))
	if J.gt(v_rx, 2.0):
		game.f_ell(v_x, (v_y - 1.0), (v_rx - 2.0), 3.0, (J.getv(game.j_P, "au0") if J.truth(v_big) else "#f2f2f2"))
		game.f_px((v_x - 1.0), (v_y - 3.0), "#ffffff")
		game.text_draw.f_txt(("5" if J.truth(v_big) else "1"), v_x, (v_y - 4.0), (J.getv(game.j_P, "au3") if J.truth(v_big) else "#8a8a8a"), {"align": "c"})
	return null

