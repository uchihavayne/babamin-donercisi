# Regulation draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:424
func f_drawLider(p_t: Variant = null) -> Variant:
	var v_L: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_m: Variant = null
	var v_mx: Variant = null
	var v_i: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_sw: Variant = null
	var v_t: Variant = p_t
	v_L = J.getv(game.j_G, "lider")
	if ((not J.truth(v_L)) or J.eq(J.getv(v_L, "state"), "bekle")):
		return null
	v_x = floor(J.getv(v_L, "x") + 0.5)
	v_y = J.getv(v_L, "y")
	# REMAKE kancasi: HD lider ve korumalari
	if not J.truth(game.f_hdLider(v_x, v_y)):
		v_m = 0.0
		while J.lt(v_m, 2.0):
			v_mx = J.add(v_x, (26.0 if J.truth(v_m) else (-J.n(26.0))))
			J.setv(game.j_ctx, "globalAlpha", 0.22)
			game.f_ell(v_mx, v_y, 5.0, 2.0, "#000")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_fr((v_mx - 4.0), (v_y - 20.0), 8.0, 20.0, "#3a413a")
			game.f_fr((v_mx - 4.0), (v_y - 20.0), 8.0, 1.0, "#4c544c")
			game.f_fr((v_mx - 4.0), (v_y - 8.0), 8.0, 1.0, "#20241f")
			game.f_fr((v_mx - 3.0), (v_y - 28.0), 6.0, 8.0, "#c99a66")
			game.f_fr((v_mx - 2.0), (v_y - 25.0), 1.0, 1.0, "#14161a")
			game.f_fr(J.add(v_mx, 1.0), (v_y - 25.0), 1.0, 1.0, "#14161a")
			game.f_fr((v_mx - 4.0), (v_y - 31.0), 8.0, 3.0, "#39403a")
			game.f_fr((v_mx - 3.0), (v_y - 32.0), 6.0, 1.0, "#39403a")
			game.f_fr((v_mx - 4.0), (v_y - 28.0), 8.0, 1.0, "#20241f")
			v_i = 0.0
			while J.lt(v_i, 11.0):
				game.f_px(J.add(v_mx, (5.0 if J.truth(v_m) else (-J.n(5.0)))), J.add((v_y - 26.0), v_i), "#2a2620")
				v_i = J.add(v_i, 1.0)
			v_m = J.add(v_m, 1.0)
		J.setv(game.j_ctx, "globalAlpha", 0.28)
		game.f_ell(v_x, v_y, 6.0, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr((v_x - 6.0), (v_y - 24.0), 12.0, 24.0, "#22252b")
		game.f_fr((v_x - 6.0), (v_y - 24.0), 12.0, 1.0, "#333740")
		game.f_fr((v_x - 1.0), (v_y - 23.0), 1.0, 22.0, "#171a1f")
		game.f_fr((v_x - 6.0), (v_y - 12.0), 12.0, 2.0, "#0e1013")
		game.f_fr(J.add(v_x, 1.0), (v_y - 12.0), 3.0, 2.0, "#c9a23a")
		game.f_fr((v_x - 6.0), (v_y - 24.0), 4.0, 2.0, "#c9a23a")
		game.f_fr(J.add(v_x, 2.0), (v_y - 24.0), 4.0, 2.0, "#c9a23a")
		game.f_fr((v_x - 4.0), (v_y - 20.0), 2.0, 2.0, "#c9a23a")
		game.f_fr((v_x - 4.0), (v_y - 17.0), 2.0, 2.0, "#b83228")
		game.f_fr((v_x - 1.0), (v_y - 20.0), 2.0, 2.0, "#c9a23a")
		game.f_fr((v_x - 8.0), (v_y - 22.0), 2.0, 10.0, "#171a1f")
		game.f_fr(J.add(v_x, 6.0), (v_y - 22.0), 2.0, 10.0, "#171a1f")
		game.f_fr((v_x - 4.0), (v_y - 33.0), 8.0, 9.0, "#d6ab7c")
		game.f_fr((v_x - 4.0), (v_y - 26.0), 8.0, 2.0, "#c39a6e")
		game.f_fr((v_x - 2.0), (v_y - 30.0), 1.0, 1.0, "#14161a")
		game.f_fr(J.add(v_x, 2.0), (v_y - 30.0), 1.0, 1.0, "#14161a")
		game.f_fr((v_x - 1.0), (v_y - 27.0), 3.0, 1.0, "#8a5a4a")
		game.f_fr((v_x - 2.0), (v_y - 28.0), 5.0, 1.0, "#3a2e24")
		game.f_fr((v_x - 6.0), (v_y - 37.0), 12.0, 4.0, "#171a1f")
		game.f_fr((v_x - 6.0), (v_y - 38.0), 12.0, 1.0, "#2a2e35")
		game.f_fr((v_x - 6.0), (v_y - 33.0), 12.0, 1.0, "#8e1c14")
		game.f_fr((v_x - 7.0), (v_y - 32.0), 14.0, 1.0, "#0b0d10")
		game.f_px(v_x, (v_y - 36.0), "#e8dcb0")
		game.f_fr((v_x - 1.0), (v_y - 35.0), 3.0, 1.0, "#c9a23a")
	if (J.eq(J.getv(v_L, "state"), "bekliyor") and J.truth(J.getv(v_L, "istek"))):
		v_bx = (v_x - 18.0)
		v_by = (v_y - 62.0)
		J.setv(game.j_ctx, "globalAlpha", 0.35)
		game.f_rrect(J.add(v_bx, 1.0), J.add(v_by, 2.0), 36.0, 20.0, 3.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(v_bx, v_by, 36.0, 20.0, 3.0, "#f0e6cc")
		game.f_rrectOut(v_bx, v_by, 36.0, 20.0, 3.0, "#8e1c14")
		game.f_fr((v_x - 2.0), J.add(v_by, 20.0), 4.0, 3.0, "#f0e6cc")
		game.icon_draw.f_icon(("cola" if J.eq(J.getv(J.getv(v_L, "istek"), "kind"), "drink") else J.getv(J.getv(v_L, "istek"), "kind")), J.add(v_bx, 18.0), J.add(v_by, 10.0), v_t)
		v_sw = floor((32.0 * game.math_utils.f_clamp(J.getv(v_L, "sabir"), 0.0, 1.0)) + 0.5)
		game.f_fr(J.add(v_bx, 2.0), (v_by - 5.0), 32.0, 3.0, "rgba(0,0,0,.35)")
		game.f_fr(J.add(v_bx, 2.0), (v_by - 5.0), v_sw, 3.0, ("#c9a23a" if J.gt(J.getv(v_L, "sabir"), 0.35) else "#e2483a"))
	return null

# game.js:3787
func f_drawPhoneMuhurlu(p_t: Variant = null) -> Variant:
	var v_s: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_r: Variant = null
	var v_c: Variant = null
	var v_hy: Variant = null
	var v_k: Variant = null
	var v_t: Variant = p_t
	# REMAKE kancasi
	if game.f_hdTelefonMuhur(): return null
	v_s = J.getv(game.j_ST, "phone")
	v_x = J.getv(v_s, "x")
	v_y = J.getv(v_s, "y")
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 6.0), 20.0, 22.0, "#24262a")
	game.f_fr(J.add(v_x, 3.0), J.add(v_y, 6.0), 18.0, 21.0, "#3a3d42")
	game.f_hl(J.add(v_x, 3.0), J.add(v_y, 6.0), 18.0, "#4e5258")
	v_r = 0.0
	while J.lt(v_r, 3.0):
		v_c = 0.0
		while J.lt(v_c, 3.0):
			game.f_fr(J.add(J.add(v_x, 6.0), (v_c * 4.0)), J.add(J.add(v_y, 12.0), (v_r * 4.0)), 3.0, 3.0, "#5c6167")
			game.f_px(J.add(J.add(v_x, 6.0), (v_c * 4.0)), J.add(J.add(v_y, 12.0), (v_r * 4.0)), "#787e85")
			v_c = J.add(v_c, 1.0)
		v_r = J.add(v_r, 1.0)
	v_hy = J.add(v_y, 2.0)
	game.f_fr(v_x, v_hy, 24.0, 5.0, "#1b1d21")
	game.f_fr(J.add(v_x, 1.0), v_hy, 22.0, 4.0, "#6a4a46")
	game.f_hl(J.add(v_x, 2.0), v_hy, 20.0, "#825a55")
	game.f_fr(v_x, v_hy, 4.0, 6.0, "#6a4a46")
	game.f_fr(J.add(v_x, 20.0), v_hy, 4.0, 6.0, "#6a4a46")
	v_k = 0.0
	while J.lt(v_k, 6.0):
		game.f_px(J.add(J.add(v_x, 12.0), floor((sin((v_k * 1.2)) * 2.0) + 0.5)), J.add(J.add(v_hy, 6.0), v_k), "#1b1d21")
		v_k = J.add(v_k, 1.0)
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "translate", [J.add(v_x, 12.0), J.add(v_y, 18.0)])
	J.method(game.j_ctx, "rotate", [(-J.n(0.42))])
	game.f_fr((-J.n(17.0)), (-J.n(4.0)), 34.0, 8.0, "#6e1a12")
	game.f_fr((-J.n(17.0)), (-J.n(4.0)), 34.0, 7.0, "#b83228")
	game.f_hl((-J.n(16.0)), (-J.n(4.0)), 32.0, "#d8493a")
	J.method(game.j_ctx, "restore", [])
	game.f_disc(J.add(v_x, 20.0), J.add(v_y, 26.0), 3.0, "#6e1a12")
	game.f_disc(J.add(v_x, 20.0), J.add(v_y, 26.0), 2.0, "#d8493a")
	game.f_px(J.add(v_x, 20.0), J.add(v_y, 25.0), "#ffb0a0")
	return null

# game.js:3838
func f_drawDenetimLambasi(p_t: Variant = null) -> Variant:
	var v_k: Variant = null
	var v_x: Variant = null
	var v_y: Variant = null
	var v_s: Variant = null
	var v_yaniyor: Variant = null
	var v_isiniyor: Variant = null
	var v_pz: Variant = null
	var v_i: Variant = null
	var v_mr: Variant = null
	var v_ic: Variant = null
	var v_t: Variant = p_t
	# REMAKE kancasi
	if game.f_hdDenetimLambasi(p_t): return null
	if (not J.truth(J.getv(game.j_G, "ferman"))):
		return null
	v_k = game.regulation_system.f_denetimLambaKutu()
	v_x = J.getv(v_k, 0.0)
	v_y = J.getv(v_k, 1.0)
	v_s = game.regulation_system.f_denetimSeviye()
	v_yaniyor = J.ge(v_s, 1.0)
	v_isiniyor = (J.lt(v_s, 1.0) if J.gt(v_s, 0.0) else J.gt(v_s, 0.0))
	v_pz = J.add(0.5, (0.5 * sin((v_t * (7.0 if J.truth(v_yaniyor) else 3.0)))))
	game.f_fr(J.add(v_x, 6.0), v_y, 4.0, 4.0, "#3a3e44")
	game.f_fr(J.add(v_x, 6.0), v_y, 3.0, 3.0, "#5a5e64")
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 4.0), 12.0, 3.0, "#2e3238")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 6.0), 14.0, 7.0, "#3a3e44")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 6.0), 13.0, 6.0, "#4a4e54")
	game.f_hl(J.add(v_x, 2.0), J.add(v_y, 6.0), 12.0, "#61666d")
	game.f_fr(J.add(v_x, 1.0), J.add(v_y, 12.0), 14.0, 2.0, "#25282d")
	v_i = 0.0
	while J.lt(v_i, 4.0):
		game.f_vl(J.add(J.add(v_x, 3.0), (v_i * 3.0)), J.add(v_y, 7.0), 5.0, "#2a2d32")
		v_i = J.add(v_i, 1.0)
	v_mr = ("#ff4132" if J.truth(v_yaniyor) else ("#d8922a" if J.truth(v_isiniyor) else "#5a2620"))
	v_ic = ("#ffd0c0" if J.truth(v_yaniyor) else ("#f0d090" if J.truth(v_isiniyor) else "#3e1a16"))
	if J.gt(v_s, 0.0):
		J.setv(game.j_ctx, "globalAlpha", J.add((0.18 if J.truth(v_isiniyor) else 0.3), ((0.22 * v_pz) * v_s)))
		game.f_disc(J.add(v_x, 7.0), J.add(v_y, 9.0), J.add(8.0, ((v_pz * 3.0) if J.truth(v_yaniyor) else 0.0)), ("#ff5a44" if J.truth(v_yaniyor) else "#e0a03a"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(J.add(v_x, 3.0), J.add(v_y, 7.0), 9.0, 5.0, v_mr)
	game.f_fr(J.add(v_x, 4.0), J.add(v_y, 8.0), 7.0, 3.0, v_ic)
	if J.gt(v_s, 0.0):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.5 * v_pz)))
		game.f_fr(J.add(v_x, 5.0), J.add(v_y, 8.0), 4.0, 2.0, "#ffffff")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(v_yaniyor):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.16, (0.1 * v_pz)))
		game.f_fr((v_x - 10.0), J.add(v_y, 2.0), 34.0, 20.0, "#c8321e")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# game.js:3876
func f_drawFerman(p_t: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_i: Variant = null
	var v_c: Variant = null
	var v_k: Variant = null
	var v_ust: Variant = null
	var v_d: Variant = null
	var v_si: Variant = null
	var v_sc: Variant = null
	var v_uy: Variant = null
	var v_kk: Variant = null
	var v_ceteleVar: Variant = null
	var v_l: Variant = null
	var v_sut: Variant = null
	var v_z: Variant = null
	var v_t: Variant = p_t
	v_F = J.getv(game.j_G, "ferman")
	if (not J.truth(v_F)):
		return null
	v_i = 0.0
	while J.lt(v_i, J.getv(J.getv(game.j_G, "customers"), "length")):
		v_c = J.getv(J.getv(game.j_G, "customers"), v_i)
		if not J.eq(J.getv(v_c, "state"), "wait"):
			v_i = J.add(v_i, 1.0)
			continue
		v_k = game.regulation_system.f_fermanXKutu(v_c)
		v_ust = game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), (J.getv(v_k, 0.0) - 3.0), (J.getv(v_k, 1.0) - 3.0), J.add(J.getv(v_k, 2.0), 6.0), J.add(J.getv(v_k, 3.0), 6.0))
		if J.truth(v_ust):
			J.setv(game.j_ctx, "globalAlpha", J.add(0.3, (0.25 * J.add(0.5, (0.5 * sin((v_t * 5.0)))))))
			game.f_disc(J.add(J.getv(v_k, 0.0), 7.0), J.add(J.getv(v_k, 1.0), 7.0), 9.0, "#e2483a")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_rrect(J.getv(v_k, 0.0), J.getv(v_k, 1.0), 14.0, 14.0, 3.0, ("#8e1c14" if J.truth(v_ust) else "#2f3238"))
		game.f_rrect(J.add(J.getv(v_k, 0.0), 1.0), J.add(J.getv(v_k, 1.0), 1.0), 12.0, 12.0, 3.0, ("#e2483a" if J.truth(v_ust) else "#585d66"))
		game.f_hl(J.add(J.getv(v_k, 0.0), 2.0), J.add(J.getv(v_k, 1.0), 1.0), 10.0, ("#ff7a68" if J.truth(v_ust) else "#787e88"))
		v_d = 0.0
		while J.lt(v_d, 8.0):
			game.f_px(J.add(J.add(J.getv(v_k, 0.0), 3.0), v_d), J.add(J.add(J.getv(v_k, 1.0), 3.0), v_d), "#e8e4dc")
			game.f_px((J.add(J.getv(v_k, 0.0), 10.0) - v_d), J.add(J.add(J.getv(v_k, 1.0), 3.0), v_d), "#e8e4dc")
			v_d = J.add(v_d, 1.0)
		v_i = J.add(v_i, 1.0)
	v_si = 0.0
	while J.lt(v_si, J.getv(J.getv(game.j_G, "customers"), "length")):
		v_sc = J.getv(J.getv(game.j_G, "customers"), v_si)
		if not J.eq(J.getv(v_sc, "state"), "sorgu"):
			v_si = J.add(v_si, 1.0)
			continue
		v_uy = J.add((J.getv(v_sc, "y") - 62.0), floor(sin((v_t * 9.0)) + 0.5))
		J.setv(game.j_ctx, "globalAlpha", 0.32)
		game.f_disc(J.getv(v_sc, "x"), J.add(v_uy, 4.0), 8.0, "#e2483a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr((J.getv(v_sc, "x") - 1.0), v_uy, 3.0, 6.0, "#e2483a")
		game.f_fr((J.getv(v_sc, "x") - 1.0), J.add(v_uy, 8.0), 3.0, 3.0, "#e2483a")
		v_si = J.add(v_si, 1.0)
	game.regulation_draw.f_drawDenetimLambasi(v_t)
	v_kk = game.regulation_system.f_fermanKagitKutu()
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_fr(J.add(J.getv(v_kk, 0.0), 1.0), J.add(J.getv(v_kk, 1.0), 2.0), J.getv(v_kk, 2.0), J.getv(v_kk, 3.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(J.getv(v_kk, 0.0), J.getv(v_kk, 1.0), J.getv(v_kk, 2.0), J.getv(v_kk, 3.0), "#cfc7ae")
	game.f_fr(J.getv(v_kk, 0.0), J.getv(v_kk, 1.0), (J.getv(v_kk, 2.0) - 1.0), (J.getv(v_kk, 3.0) - 1.0), "#f2ecd8")
	game.f_hl(J.getv(v_kk, 0.0), J.getv(v_kk, 1.0), (J.getv(v_kk, 2.0) - 1.0), "#fffaea")
	game.f_fr(J.add(J.getv(v_kk, 0.0), 3.0), J.add(J.getv(v_kk, 1.0), 3.0), (J.getv(v_kk, 2.0) - 7.0), 3.0, "#b83228")
	v_ceteleVar = J.gt(J.getv(v_F, "ceza"), 0.0)
	v_l = (2.0 if J.truth(v_ceteleVar) else 0.0)
	while J.lt(v_l, 4.0):
		game.f_hl(J.add(J.getv(v_kk, 0.0), 3.0), J.add(J.add(J.getv(v_kk, 1.0), 9.0), (v_l * 4.0)), (J.getv(v_kk, 2.0) - 8.0), "#9a927e")
		v_l = J.add(v_l, 1.0)
	game.f_disc((J.add(J.getv(v_kk, 0.0), J.getv(v_kk, 2.0)) - 7.0), (J.add(J.getv(v_kk, 1.0), J.getv(v_kk, 3.0)) - 7.0), 3.0, "#b83228")
	game.f_disc((J.add(J.getv(v_kk, 0.0), J.getv(v_kk, 2.0)) - 7.0), (J.add(J.getv(v_kk, 1.0), J.getv(v_kk, 3.0)) - 7.0), 2.0, "#d8493a")
	if J.truth(v_ceteleVar):
		v_sut = ceil((float(game.j_FERMAN_CEZA_SINIR) / float(2.0)))
		v_z = 0.0
		while J.lt(v_z, game.j_FERMAN_CEZA_SINIR):
			game.f_fr(J.add(J.add(J.getv(v_kk, 0.0), 3.0), (fmod(J.n(v_z), J.n(v_sut)) * 4.0)), J.add(J.add(J.getv(v_kk, 1.0), 8.0), (floor((float(v_z) / float(v_sut))) * 4.0)), 3.0, 2.0, ("#e2483a" if J.lt(v_z, J.getv(v_F, "ceza")) else "rgba(0,0,0,.28)"))
			v_z = J.add(v_z, 1.0)
	if J.truth(game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), J.getv(v_kk, 0.0), J.getv(v_kk, 1.0), J.getv(v_kk, 2.0), J.getv(v_kk, 3.0))):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.5, (0.3 * sin((v_t * 6.0)))))
		game.f_rrectOut((J.getv(v_kk, 0.0) - 1.0), (J.getv(v_kk, 1.0) - 1.0), J.add(J.getv(v_kk, 2.0), 2.0), J.add(J.getv(v_kk, 3.0), 2.0), 2.0, J.getv(game.j_P, "au0"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# game.js:3947
func f_drawFermanKagit(p_t: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_a: Variant = null
	var v_pw: Variant = null
	var v_ph: Variant = null
	var v_pxx: Variant = null
	var v_pyy: Variant = null
	var v_m: Variant = null
	var v_my2: Variant = null
	var v_ay2: Variant = null
	var v_t: Variant = p_t
	v_F = J.getv(game.j_G, "ferman")
	if (not J.truth(v_F)):
		return null
	if J.gt(J.getv(v_F, "kagit"), 0.01):
		v_a = game.math_utils.f_easeOut(J.getv(v_F, "kagit"))
		J.setv(game.j_ctx, "globalAlpha", (0.62 * v_a))
		game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_pw = 250.0
		v_ph = J.add(J.add(34.0, (J.getv(J.getv(v_F, "liste"), "length") * 22.0)), 34.0)
		v_pxx = floor(((float(game.j_W) / float(2.0)) - (float(v_pw) / float(2.0))) + 0.5)
		v_pyy = floor(game.math_utils.f_lerp((-J.n(v_ph)), J.add(J.getv(game.j_VIEW, "top"), (float((((game.j_H - J.getv(game.j_VIEW, "top")) - J.getv(game.j_VIEW, "bot")) - v_ph)) / float(2.0))), v_a) + 0.5)
		J.setv(game.j_ctx, "globalAlpha", 0.4)
		game.f_fr(J.add(v_pxx, 3.0), J.add(v_pyy, 4.0), v_pw, v_ph, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_fr(v_pxx, v_pyy, v_pw, v_ph, "#cfc7ae")
		game.f_fr(J.add(v_pxx, 1.0), J.add(v_pyy, 1.0), (v_pw - 2.0), (v_ph - 2.0), "#f4eeda")
		game.f_hl(J.add(v_pxx, 1.0), J.add(v_pyy, 1.0), (v_pw - 2.0), "#fffaea")
		game.f_fr(J.add(v_pxx, 6.0), J.add(v_pyy, 6.0), (v_pw - 12.0), 14.0, "#b83228")
		game.f_hl(J.add(v_pxx, 6.0), J.add(v_pyy, 6.0), (v_pw - 12.0), "#d8493a")
		game.text_draw.f_txt(game.localization.f_T("BUGÜNKÜ FERMAN"), J.add(v_pxx, (float(v_pw) / float(2.0))), J.add(v_pyy, 9.0), "#fff2e0", {"align": "c"})
		v_m = 0.0
		while J.lt(v_m, J.getv(J.getv(v_F, "liste"), "length")):
			v_my2 = J.add(J.add(v_pyy, 28.0), (v_m * 22.0))
			game.f_fr(J.add(v_pxx, 10.0), v_my2, (v_pw - 20.0), 18.0, "#e6dfc6")
			game.f_rc(J.add(v_pxx, 10.0), v_my2, (v_pw - 20.0), 18.0, "#b0a88e")
			game.f_fr(J.add(v_pxx, 13.0), J.add(v_my2, 3.0), 12.0, 12.0, "#b83228")
			game.text_draw.f_txt(J.add("", J.add(v_m, 1.0)), J.add(v_pxx, 19.0), J.add(v_my2, 5.0), "#fff2e0", {"align": "c"})
			game.text_draw.f_txt(game.localization.f_T(J.getv(J.getv(J.getv(v_F, "liste"), v_m), "metin")), J.add(v_pxx, 30.0), J.add(v_my2, 5.0), "#3a3226")
			v_m = J.add(v_m, 1.0)
		v_ay2 = (J.add(v_pyy, v_ph) - 26.0)
		game.text_draw.f_txt(J.add(J.add(J.add(J.add(J.add(game.localization.f_T("İhlal: "), J.getv(v_F, "ceza")), "/"), game.j_FERMAN_CEZA_SINIR), game.localization.f_T("  —  ceza $")), game.j_FERMAN_CEZA_PARA), J.add(v_pxx, (float(v_pw) / float(2.0))), v_ay2, ("#a83a2a" if J.gt(J.getv(v_F, "ceza"), 0.0) else "#5a5445"), {"align": "c"})
		if J.truth(game.f_button((J.add(v_pxx, (float(v_pw) / float(2.0))) - 34.0), J.add(v_ay2, 10.0), 68.0, 14.0, "KAPAT", J.getv(game.j_P, "red1"), true)):
			J.setv(v_F, "kagitT", 0.0)
			J.method(game.j_SFX, "uiBack", [])
	return null

# game.js:4463
func f_drawInspector(p_t: Variant = null) -> Variant:
	var v_I: Variant = null
	var v_fake: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_i: Variant = null
	var v_pen: Variant = null
	var v_lbl: Variant = null
	var v_lw: Variant = null
	var v_lx: Variant = null
	var v_ly: Variant = null
	var v_t: Variant = p_t
	v_I = J.getv(game.j_G, "inspect")
	if ((not J.truth(v_I)) or J.eq(J.getv(v_I, "state"), "wait")):
		return null
	v_fake = {"x": J.getv(v_I, "x"), "y": J.getv(v_I, "y"), "look": J.getv(v_I, "look"), "items": [], "done": [], "patience": 1.0, "mood": ("angry" if J.truth(J.getv(v_I, "dirty")) else "wait"), "state": ("walkin" if J.eq(J.getv(v_I, "state"), "in") else "wait"), "t": v_t, "bubble": 0.0, "lineT": 0.0, "wrongT": 0.0}
	game.f_drawCustomer(v_fake, v_t)
	v_bx = J.add(floor(J.getv(v_I, "x") + 0.5), 14.0)
	v_by = (J.getv(v_I, "y") - 30.0)
	# REMAKE kancasi
	if not game.f_hdPano(v_bx, v_by):
		game.f_fr(v_bx, v_by, 12.0, 15.0, "#8a6a3a")
		game.f_fr(J.add(v_bx, 1.0), J.add(v_by, 1.0), 10.0, 13.0, "#e8e2d0")
		game.f_fr(J.add(v_bx, 3.0), (v_by - 2.0), 6.0, 3.0, "#9aa3ab")
		v_i = 0.0
		while J.lt(v_i, 4.0):
			game.f_hl(J.add(v_bx, 2.0), J.add(J.add(v_by, 4.0), (v_i * 3.0)), 8.0, "#b9b2a0")
			v_i = J.add(v_i, 1.0)
	if J.eq(J.getv(v_I, "state"), "check"):
		v_pen = (sin((v_t * 12.0)) * 2.0)
		game.f_ln(J.add(J.add(v_bx, 8.0), v_pen), J.add(v_by, 4.0), J.add(J.add(v_bx, 11.0), v_pen), J.add(v_by, 9.0), "#2f3740")
	v_lbl = ("DENETİM…" if J.eq(J.getv(v_I, "state"), "check") else (J.getv(v_I, "line") if J.truth(J.getv(v_I, "line")) else ""))
	if J.truth(v_lbl):
		v_lw = J.add(game.f_textW(v_lbl), 8.0)
		v_lx = game.math_utils.f_clamp((J.getv(v_I, "x") - (float(v_lw) / float(2.0))), 2.0, ((game.j_W - v_lw) - 2.0))
		v_ly = (J.getv(v_I, "y") - 66.0)
		game.f_rrect(v_lx, v_ly, v_lw, 12.0, 3.0, (J.getv(game.j_P, "bad") if J.truth(J.getv(v_I, "dirty")) else J.getv(game.j_P, "white")))
		game.f_rrectOut(v_lx, v_ly, v_lw, 12.0, 3.0, J.getv(game.j_P, "ui5"))
		game.text_draw.f_txt(v_lbl, J.add(v_lx, 4.0), J.add(v_ly, 2.0), (J.getv(game.j_P, "white") if J.truth(J.getv(v_I, "dirty")) else J.getv(game.j_P, "ink")))
	if (J.eq(J.getv(v_I, "state"), "check") and J.gt(J.getv(game.j_G, "trash"), 0.55)):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.4, (0.4 * sin((v_t * 8.0)))))
		game.f_rrectOut((J.getv(J.getv(game.j_ST, "trash"), "x") - 2.0), (J.getv(J.getv(game.j_ST, "trash"), "y") - 2.0), J.add(J.getv(J.getv(game.j_ST, "trash"), "w"), 4.0), J.add(J.getv(J.getv(game.j_ST, "trash"), "h"), 4.0), 3.0, J.getv(game.j_P, "bad"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

