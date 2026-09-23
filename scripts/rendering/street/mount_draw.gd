# Mount draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:719
func f_drawSupurge(p_x: Variant = null, p_y: Variant = null, p_p: Variant = null, p_binici: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_sal: Variant = null
	var v_yy: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_u: Variant = null
	var v_boy: Variant = null
	var v_q: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_p: Variant = p_p
	var v_binici: Variant = p_binici
	v_p = (1.0 if J.eq(v_p, null) else game.math_utils.f_clamp(v_p, 0.0, 1.0))
	v_sal = floor((sin(J.add((v_y * 0.07), (v_p * 9.0))) * 1.0) + 0.5)
	v_yy = J.add(((v_y - 8.0) - floor(((1.0 - v_p) * 26.0) + 0.5)), v_sal)
	J.setv(game.j_ctx, "globalAlpha", (0.22 * v_p))
	game.f_ell(J.add(v_x, 2.0), v_y, 9.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_i = 0.0
	while J.lt(v_i, 22.0):
		v_sx = J.add((v_x - 10.0), v_i)
		v_sy = (v_yy - floor((v_i * 0.1) + 0.5))
		game.f_fr(v_sx, v_sy, 1.0, 2.0, "#54402a")
		game.f_px(v_sx, v_sy, "#8a6f4a")
		v_i = J.add(v_i, 1.0)
	game.f_fr(J.add(v_x, 11.0), (v_yy - 3.0), 2.0, 2.0, "#6f5638")
	game.f_px(J.add(v_x, 11.0), (v_yy - 3.0), "#a88a5e")
	v_i = 0.0
	while J.lt(v_i, 7.0):
		v_u = (float((v_i - 3.0)) / float(3.0))
		v_boy = (7.0 - abs((v_i - 3.0)))
		v_q = 0.0
		while J.lt(v_q, v_boy):
			game.f_px(((v_x - 11.0) - v_q), J.add(J.add(v_yy, floor((v_u * 3.0) + 0.5)), floor(((v_q * v_u) * 0.35) + 0.5)), ("#d8b468" if J.eq(fmod(J.n(v_i), J.n(3.0)), 0.0) else ("#b89448" if J.eq(fmod(J.n(v_i), J.n(3.0)), 1.0) else "#8f7230")))
			v_q = J.add(v_q, 1.0)
		v_i = J.add(v_i, 1.0)
	game.f_vl((v_x - 9.0), (v_yy - 2.0), 5.0, "#4a3418")
	game.f_px((v_x - 9.0), (v_yy - 2.0), "#8a662e")
	if J.truth(v_binici):
		game.mount_draw.f_drawCirakMini(J.add(v_x, 1.0), v_yy, game.traffic_system.f_t0Bin(), true)
	return null

# art.js:749
func f_drawCirakMini(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_otur: Variant = null, p_yuru: Variant = null) -> Variant:
	var v_ad: Variant = null
	var v_gy0: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_otur: Variant = p_otur
	var v_yuru: Variant = p_yuru
	v_ad = (fmod(J.n(floor((v_t * 7.0))), J.n(2.0)) if J.truth(v_yuru) else 0.0)
	if (not J.truth(v_otur)):
		J.setv(game.j_ctx, "globalAlpha", 0.28)
		game.f_ell(v_x, v_y, 5.0, 2.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_gy0 = ((v_y - 9.0) if J.truth(v_otur) else (v_y - 11.0))
	game.f_fr((v_x - 4.0), v_gy0, 8.0, (7.0 if J.truth(v_otur) else 11.0), "#161a22")
	game.f_fr((v_x - 4.0), v_gy0, 7.0, (6.0 if J.truth(v_otur) else 10.0), "#20242e")
	game.f_fr((v_x - 3.0), J.add(v_gy0, 1.0), 2.0, 4.0, "#9a2632")
	game.f_fr((v_x - 3.0), J.add(v_gy0, 3.0), 2.0, 2.0, "#d8ac35")
	if J.truth(v_otur):
		game.f_fr((v_x - 1.0), (v_y - 2.0), 6.0, 3.0, "#0b0d12")
		game.f_fr((v_x - 1.0), (v_y - 2.0), 5.0, 2.0, "#2d3340")
		game.f_fr(J.add(v_x, 3.0), (v_y - 1.0), 3.0, 7.0, "#0b0d12")
		game.f_fr(J.add(v_x, 3.0), v_y, 2.0, 5.0, "#20242e")
		game.f_fr(J.add(v_x, 2.0), J.add(v_y, 5.0), 4.0, 2.0, "#2b2018")
		game.f_fr((v_x - 5.0), J.add(v_gy0, 3.0), 3.0, 4.0, "#9a2632")
	else:
		if J.truth(v_yuru):
			game.f_px(J.add((v_x - 2.0), v_ad), (v_y - 1.0), "#2b2018")
			game.f_px((J.add(v_x, 1.0) - v_ad), (v_y - 1.0), "#2b2018")
	game.f_fr((v_x - 3.0), (v_gy0 - 5.0), 6.0, 5.0, "#c9885a")
	game.f_fr((v_x - 2.0), (v_gy0 - 5.0), 4.0, 4.0, "#e0a978")
	game.f_fr((v_x - 3.0), (v_gy0 - 3.0), 2.0, 2.0, "#f0ece2")
	game.f_fr(J.add(v_x, 1.0), (v_gy0 - 3.0), 2.0, 2.0, "#f0ece2")
	game.f_px((v_x - 2.0), (v_gy0 - 3.0), "#2b2018")
	game.f_px(J.add(v_x, 1.0), (v_gy0 - 3.0), "#2b2018")
	game.f_hl((v_x - 1.0), (v_gy0 - 3.0), 2.0, "#2a2a2e")
	game.f_fr((v_x - 4.0), (v_gy0 - 8.0), 8.0, 4.0, "#2a1e14")
	game.f_px((v_x - 4.0), (v_gy0 - 9.0), "#2a1e14")
	game.f_px(J.add(v_x, 2.0), (v_gy0 - 9.0), "#2a1e14")
	return null

# art.js:777
func f_drawKaravan(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_hiz: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_L: Variant = null
	var v_wx: Variant = null
	var v_wa: Variant = null
	var v_wxa: Variant = null
	var v_wya: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_hiz: Variant = p_hiz
	v_L = 62.0
	v_hiz = (v_hiz if J.truth(v_hiz) else 0.0)
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_ell(J.add(v_x, (float(v_L) / float(2.0))), v_y, ((float(v_L) / float(2.0)) - 2.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(v_x, (v_y - 22.0), 54.0, 18.0, "#7a7468")
	game.f_fr(J.add(v_x, 1.0), (v_y - 22.0), 52.0, 17.0, "#bab4a8")
	game.f_hl(J.add(v_x, 1.0), (v_y - 22.0), 52.0, "#efe9dc")
	game.f_fr(J.add(v_x, 1.0), (v_y - 6.0), 52.0, 2.0, "#9a948a")
	game.f_fr(J.add(v_x, 1.0), (v_y - 15.0), 52.0, 3.0, "#9a8340")
	game.f_hl(J.add(v_x, 1.0), (v_y - 15.0), 52.0, "#c9ac58")
	game.f_fr(J.add(v_x, 52.0), (v_y - 16.0), 10.0, 12.0, "#7a7468")
	game.f_fr(J.add(v_x, 52.0), (v_y - 16.0), 9.0, 11.0, "#bab4a8")
	game.f_fr(J.add(v_x, 56.0), (v_y - 14.0), 6.0, 6.0, "#4d7386")
	game.f_hl(J.add(v_x, 56.0), (v_y - 14.0), 6.0, "#7aa3b6")
	game.f_fr(J.add(v_x, 58.0), (v_y - 5.0), 4.0, 2.0, "#4d545c")
	game.f_px(J.add(v_x, 61.0), (v_y - 12.0), "#ffe08a")
	v_i = 0.0
	while J.lt(v_i, 3.0):
		game.f_fr(J.add(J.add(v_x, 4.0), (v_i * 12.0)), (v_y - 20.0), 9.0, 7.0, "#33505f")
		game.f_fr(J.add(J.add(v_x, 4.0), (v_i * 12.0)), (v_y - 20.0), 8.0, 6.0, "#4d7386")
		game.f_hl(J.add(J.add(v_x, 4.0), (v_i * 12.0)), (v_y - 20.0), 8.0, "#7aa3b6")
		v_i = J.add(v_i, 1.0)
	game.f_fr(J.add(v_x, 40.0), (v_y - 20.0), 10.0, 15.0, "#9a948a")
	game.f_rc(J.add(v_x, 40.0), (v_y - 20.0), 10.0, 15.0, "#7a7468")
	game.f_px(J.add(v_x, 48.0), (v_y - 13.0), "#4d545c")
	game.f_fr(J.add(v_x, 41.0), (v_y - 4.0), 8.0, 2.0, "#6f7880")
	v_i = 0.0
	while J.lt(v_i, 2.0):
		v_wx = J.add(J.add(v_x, 9.0), (v_i * 34.0))
		game.f_disc(v_wx, (v_y - 4.0), 5.0, "#14161a")
		game.f_disc(v_wx, (v_y - 4.0), 3.0, "#31363e")
		if J.gt(v_hiz, 0.02):
			v_wa = J.add(((v_t * 14.0) * v_hiz), v_i)
			v_wxa = floor((cos(v_wa) * 2.0) + 0.5)
			v_wya = floor((sin(v_wa) * 2.0) + 0.5)
			game.f_ln((v_wx - v_wxa), ((v_y - 4.0) - v_wya), J.add(v_wx, v_wxa), J.add((v_y - 4.0), v_wya), "#98a2ab")
		else:
			game.f_disc(v_wx, (v_y - 4.0), 1.0, "#98a2ab")
		v_i = J.add(v_i, 1.0)
	if J.gt(v_hiz, 0.02):
		game.f_fr(J.add(v_x, 61.0), (v_y - 13.0), 2.0, 3.0, "#ffe08a")
		game.f_px(J.add(v_x, 62.0), (v_y - 12.0), "#fffbe0")
		game.f_fr((v_x - 1.0), (v_y - 13.0), 2.0, 2.0, "#c02a1e")
	game.f_fr(J.add(v_x, 14.0), (v_y - 25.0), 12.0, 3.0, "#4d545c")
	game.f_hl(J.add(v_x, 14.0), (v_y - 25.0), 12.0, "#98a2ab")
	game.f_vl(J.add(v_x, 36.0), (v_y - 31.0), 9.0, "#6f7880")
	game.f_fr(J.add(v_x, 33.0), (v_y - 32.0), 7.0, 1.0, "#6f7880")
	return null

# art.js:837
func f_drawEjderha(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_inis: Variant = null, p_ucus: Variant = null) -> Variant:
	var _cells: Dictionary = {"P1": [null], "P2": [null]}
	var v_P0: Variant = null
	var v_P3: Variant = null
	var v_KRN: Variant = null
	var v_KRN2: Variant = null
	var v_BOY: Variant = null
	var v_BOY2: Variant = null
	var v_ZAR: Variant = null
	var v_ZARK: Variant = null
	var v_cirp: Variant = null
	var v_nf: Variant = null
	var v_zin: Variant = null
	var v_d0: Variant = null
	var v_da: Variant = null
	var v_bcU: Variant = null
	var v_b0: Variant = null
	var v_bx0: Variant = null
	var v_n0: Variant = null
	var v_k0: Variant = null
	var v_f0: Variant = null
	var v_fx0: Variant = null
	var v_n1: Variant = null
	var v_s0: Variant = null
	var v_kg: Variant = null
	var v_kz: Variant = null
	var v_z0: Variant = null
	var v_kb: Variant = null
	var v_ka: Variant = null
	var v_kl: Variant = null
	var v_sd: Variant = null
	var v_hx0: Variant = null
	var v_hy0: Variant = null
	var v_dt0: Variant = null
	var v_bz0: Variant = null
	var v_bl: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_inis: Variant = p_inis
	var v_ucus: Variant = p_ucus
	v_zin = game.mount_draw._closure_54.bind({"190:P1": _cells["P1"], "190:P2": _cells["P2"]})
	v_inis = (1.0 if J.eq(v_inis, null) else game.math_utils.f_clamp(v_inis, 0.0, 1.0))
	v_P0 = "#0e1711"
	_cells["P1"][0] = "#16241a"
	_cells["P2"][0] = "#1f3324"
	v_P3 = "#2b452f"
	v_KRN = "#5f5228"
	v_KRN2 = "#7d6b36"
	v_BOY = "#7c6c52"
	v_BOY2 = "#9e8c6c"
	v_ZAR = "#131f18"
	v_ZARK = "#4a6b46"
	v_cirp = ((sin((v_t * 7.5)) * 7.0) if J.truth(v_ucus) else (sin((v_t * 0.9)) * 1.0))
	v_nf = floor(sin((v_t * 1.5)) + 0.5)
	if (not J.truth(v_ucus)):
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_ell(J.add(v_x, 2.0), v_y, 28.0, 4.0, "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.invoke(v_zin, [[[J.add(v_x, 15.0), (v_y - 9.0)], [J.add(v_x, 24.0), (v_y - 10.0)], [J.add(v_x, 30.0), (v_y - 13.0)], [J.add(v_x, 34.0), (v_y - 19.0)], [J.add(v_x, 34.0), (v_y - 25.0)]], 4.5, 1.2])
	v_d0 = 0.0
	while J.lt(v_d0, 3.0):
		v_da = J.add((-J.n(0.6)), (v_d0 * 0.7))
		game.f_ln(J.add(v_x, 34.0), (v_y - 25.0), J.add(J.add(v_x, 34.0), floor((cos(v_da) * 5.0) + 0.5)), ((v_y - 25.0) - floor((sin(v_da) * 5.0) + 0.5)), v_BOY)
		v_d0 = J.add(v_d0, 1.0)
	v_bcU = (6.0 if J.truth(v_ucus) else 0.0)
	v_b0 = 0.0
	while J.lt(v_b0, 2.0):
		v_bx0 = J.add(J.add(v_x, 12.0), (v_b0 * 3.0))
		game.f_ell(v_bx0, ((v_y - 7.0) - v_bcU), 4.0, (4.0 if J.truth(v_ucus) else 6.0), (_cells["P1"][0] if J.truth(v_b0) else _cells["P2"][0]))
		game.f_ell((v_bx0 - 1.0), ((v_y - 8.0) - v_bcU), 3.0, (3.0 if J.truth(v_ucus) else 4.0), (_cells["P2"][0] if J.truth(v_b0) else v_P3))
		game.f_ell((v_bx0 - 2.0), ((v_y - 1.0) - (v_bcU * 1.4)), 4.5, 2.0, _cells["P1"][0])
		v_n0 = 0.0
		while J.lt(v_n0, 3.0):
			game.f_px(J.add((v_bx0 - 6.0), v_n0), (v_y - floor((v_bcU * 1.4) + 0.5)), v_BOY)
			v_n0 = J.add(v_n0, 1.0)
		v_b0 = J.add(v_b0, 1.0)
	game.f_ell(J.add(v_x, 4.0), J.add((v_y - 12.0), v_nf), 14.0, 9.0, _cells["P1"][0])
	game.f_ell(J.add(v_x, 3.0), J.add((v_y - 13.0), v_nf), 13.0, 8.0, _cells["P2"][0])
	game.f_ell(J.add(v_x, 2.0), J.add((v_y - 16.0), v_nf), 11.0, 5.0, _cells["P1"][0])
	game.f_ell(J.add(v_x, 3.0), (v_y - 6.0), 10.0, 3.0, v_KRN)
	v_k0 = 0.0
	while J.lt(v_k0, 5.0):
		game.f_fr(J.add((v_x - 5.0), (v_k0 * 4.0)), (v_y - 8.0), 3.0, 1.0, v_KRN2)
		v_k0 = J.add(v_k0, 1.0)
	v_f0 = 0.0
	while J.lt(v_f0, 2.0):
		v_fx0 = J.add((v_x - 12.0), (v_f0 * 3.0))
		game.f_ell(v_fx0, ((v_y - 6.0) - v_bcU), 3.5, (3.5 if J.truth(v_ucus) else 5.0), (_cells["P1"][0] if J.truth(v_f0) else _cells["P2"][0]))
		game.f_ell((v_fx0 - 1.0), ((v_y - 7.0) - v_bcU), 2.5, (2.5 if J.truth(v_ucus) else 3.5), (_cells["P2"][0] if J.truth(v_f0) else v_P3))
		game.f_ell((v_fx0 - 2.0), ((v_y - 1.0) - (v_bcU * 1.4)), 4.0, 2.0, _cells["P1"][0])
		v_n1 = 0.0
		while J.lt(v_n1, 3.0):
			game.f_px(J.add((v_fx0 - 6.0), v_n1), (v_y - floor((v_bcU * 1.4) + 0.5)), v_BOY)
			v_n1 = J.add(v_n1, 1.0)
		v_f0 = J.add(v_f0, 1.0)
	J.invoke(v_zin, [[[(v_x - 3.0), (v_y - 13.0)], [(v_x - 10.0), (v_y - 15.0)], [(v_x - 17.0), (v_y - 16.0)], [(v_x - 23.0), (v_y - 15.0)]], 5.0, 3.2])
	v_s0 = 0.0
	while J.lt(v_s0, 4.0):
		game.f_ln(((v_x - 6.0) - (v_s0 * 5.0)), (v_y - 19.0), ((v_x - 9.0) - (v_s0 * 5.0)), J.add((v_y - 23.0), v_s0), v_BOY)
		v_s0 = J.add(v_s0, 1.0)
	v_kg = (1.85 if J.truth(v_ucus) else 1.0)
	v_kz = [[(v_x - 1.0), (v_y - 18.0)], [J.add(J.add(v_x, 6.0), (4.0 * v_kg)), ((v_y - 15.0) - (2.0 * v_kg))], [J.add(J.add(v_x, 8.0), (11.0 * v_kg)), ((v_y - 18.0) - (5.0 * v_kg))], [J.add(J.add(J.add(v_x, 9.0), (13.0 * v_kg)), floor((v_cirp * 0.3) + 0.5)), (((v_y - 20.0) - (13.0 * v_kg)) - floor(v_cirp + 0.5))], [J.add(J.add(v_x, 6.0), (7.0 * v_kg)), (((v_y - 22.0) - (15.0 * v_kg)) - floor(v_cirp + 0.5))], [J.add(v_x, 1.0), ((v_y - 22.0) - (7.0 * v_kg))]]
	J.setv(game.j_ctx, "fillStyle", v_ZAR)
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "moveTo", [J.getv(J.getv(v_kz, 0.0), 0.0), J.getv(J.getv(v_kz, 0.0), 1.0)])
	v_z0 = 1.0
	while J.lt(v_z0, J.getv(v_kz, "length")):
		J.method(game.j_ctx, "lineTo", [J.getv(J.getv(v_kz, v_z0), 0.0), J.getv(J.getv(v_kz, v_z0), 1.0)])
		v_z0 = J.add(v_z0, 1.0)
	J.method(game.j_ctx, "closePath", [])
	J.method(game.j_ctx, "fill", [])
	game.f_ln(J.getv(J.getv(v_kz, 0.0), 0.0), J.getv(J.getv(v_kz, 0.0), 1.0), J.getv(J.getv(v_kz, 3.0), 0.0), J.getv(J.getv(v_kz, 3.0), 1.0), v_ZARK)
	game.f_ln(J.getv(J.getv(v_kz, 3.0), 0.0), J.getv(J.getv(v_kz, 3.0), 1.0), J.getv(J.getv(v_kz, 4.0), 0.0), J.getv(J.getv(v_kz, 4.0), 1.0), v_ZARK)
	v_kb = 0.0
	while J.lt(v_kb, 4.0):
		v_ka = J.add((-J.n(1.06)), (v_kb * 0.3))
		v_kl = ((17.0 - (v_kb * 3.0)) * v_kg)
		game.f_ln(J.add(J.add(v_x, 1.0), (v_kb * 4.0)), (v_y - 18.0), J.add(J.add(J.add(v_x, 1.0), (v_kb * 4.0)), floor((cos(v_ka) * v_kl) + 0.5)), (J.add((v_y - 18.0), floor((sin(v_ka) * v_kl) + 0.5)) - floor((v_cirp * 0.6) + 0.5)), v_BOY)
		v_kb = J.add(v_kb, 1.0)
	v_sd = 0.0
	while J.lt(v_sd, 4.0):
		game.f_ln(J.add((v_x - 2.0), (v_sd * 6.0)), (v_y - 20.0), J.add((v_x - 3.0), (v_sd * 6.0)), J.add((v_y - 25.0), v_sd), v_BOY)
		v_sd = J.add(v_sd, 1.0)
	v_hx0 = (v_x - 28.0)
	v_hy0 = (v_y - 15.0)
	game.f_ell(v_hx0, v_hy0, 6.0, 5.0, _cells["P1"][0])
	game.f_ell((v_hx0 - 1.0), (v_hy0 - 1.0), 5.0, 4.0, _cells["P2"][0])
	game.f_fr((v_hx0 - 12.0), (v_hy0 - 3.0), 12.0, 5.0, _cells["P1"][0])
	game.f_fr((v_hx0 - 12.0), (v_hy0 - 3.0), 11.0, 4.0, _cells["P2"][0])
	game.f_hl((v_hx0 - 11.0), (v_hy0 - 3.0), 10.0, v_P3)
	game.f_fr((v_hx0 - 11.0), J.add(v_hy0, 3.0), 10.0, 3.0, v_KRN)
	game.f_hl((v_hx0 - 11.0), J.add(v_hy0, 3.0), 9.0, v_KRN2)
	game.f_fr((v_hx0 - 10.0), J.add(v_hy0, 1.0), 9.0, 2.0, "#2a0a10")
	v_dt0 = 0.0
	while J.lt(v_dt0, 5.0):
		game.f_px(J.add((v_hx0 - 10.0), (v_dt0 * 2.0)), J.add(v_hy0, 1.0), "#e8e2d0")
		game.f_px(J.add((v_hx0 - 9.0), (v_dt0 * 2.0)), J.add(v_hy0, 2.0), "#d8d2c0")
		v_dt0 = J.add(v_dt0, 1.0)
	game.f_fr((v_hx0 - 7.0), (v_hy0 - 6.0), 9.0, 3.0, _cells["P1"][0])
	game.f_hl((v_hx0 - 7.0), (v_hy0 - 6.0), 8.0, _cells["P2"][0])
	game.f_px((v_hx0 - 12.0), (v_hy0 - 2.0), "#0b1410")
	game.f_fr((v_hx0 - 5.0), (v_hy0 - 3.0), 3.0, 2.0, "#ff7a1e")
	game.f_px((v_hx0 - 4.0), (v_hy0 - 3.0), "#160604")
	v_bz0 = 0.0
	while J.lt(v_bz0, 3.0):
		v_bl = (9.0 - (v_bz0 * 2.0))
		game.f_ln(J.add(J.add(v_hx0, 1.0), v_bz0), J.add((v_hy0 - 6.0), v_bz0), J.add(J.add(J.add(v_hx0, 1.0), v_bz0), v_bl), (J.add((v_hy0 - 8.0), v_bz0) - (float(v_bl) / float(3.0))), (v_BOY if J.truth(v_bz0) else v_BOY2))
		v_bz0 = J.add(v_bz0, 1.0)
	if (J.gt(v_inis, 0.0) and J.lt(v_inis, 1.0)):
		J.setv(game.j_ctx, "globalAlpha", (0.26 * (1.0 - v_inis)))
		game.f_ell(J.add(v_x, 2.0), J.add(v_y, 3.0), J.add(20.0, ((1.0 - v_inis) * 14.0)), 4.0, "#d8d0c0")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:962
func f_drawKraliceMini(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_yuru: Variant = null, p_otur: Variant = null) -> Variant:
	var v_ad: Variant = null
	var v_gy0: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_yuru: Variant = p_yuru
	var v_otur: Variant = p_otur
	v_ad = (fmod(J.n(floor((v_t * 7.0))), J.n(2.0)) if J.truth(v_yuru) else 0.0)
	if J.truth(v_otur):
		game.f_fr((v_x - 1.0), (v_y - 1.0), 6.0, 3.0, "#1b2f3a")
		game.f_fr((v_x - 1.0), (v_y - 1.0), 5.0, 2.0, "#5f8ea2")
		game.f_fr(J.add(v_x, 3.0), v_y, 3.0, 7.0, "#1b2f3a")
		game.f_fr(J.add(v_x, 3.0), J.add(v_y, 1.0), 2.0, 5.0, "#87b3c4")
		game.f_fr(J.add(v_x, 2.0), J.add(v_y, 6.0), 4.0, 2.0, "#2b2018")
		game.f_fr((v_x - 4.0), (v_y - 8.0), 9.0, 9.0, "#1b2f3a")
		game.f_fr((v_x - 3.0), (v_y - 7.0), 7.0, 7.0, "#2f4c5c")
		game.f_fr((v_x - 3.0), (v_y - 7.0), 6.0, 6.0, "#436a7e")
		game.f_vl((v_x - 2.0), (v_y - 7.0), 6.0, "#5f8ea2")
		game.f_fr((v_x - 2.0), (v_y - 9.0), 5.0, 2.0, "#a8842c")
		game.f_fr((v_x - 3.0), (v_y - 14.0), 7.0, 6.0, "#7a4a2a")
		game.f_fr((v_x - 2.0), (v_y - 13.0), 5.0, 4.0, "#c9885a")
		game.f_fr((v_x - 1.0), (v_y - 13.0), 3.0, 3.0, "#e0a978")
		game.f_px((v_x - 1.0), (v_y - 12.0), "#2b2018")
		game.f_px(J.add(v_x, 1.0), (v_y - 12.0), "#2b2018")
		game.f_fr((v_x - 4.0), (v_y - 17.0), 9.0, 4.0, "#8a7a58")
		game.f_fr((v_x - 3.0), (v_y - 16.0), 7.0, 3.0, "#b8a684")
		game.f_fr((v_x - 3.0), (v_y - 16.0), 6.0, 2.0, "#e8dcc0")
		game.f_fr((v_x - 5.0), (v_y - 13.0), 2.0, 5.0, "#d8c9a8")
		game.f_px((v_x - 6.0), (v_y - 11.0), "#e8dcc0")
		return null
	v_gy0 = (v_y - 11.0)
	J.setv(game.j_ctx, "globalAlpha", 0.28)
	game.f_ell(v_x, v_y, 5.0, 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((v_x - 4.0), v_gy0, 8.0, 11.0, "#2f4c5c")
	game.f_fr((v_x - 4.0), v_gy0, 7.0, 10.0, "#436a7e")
	game.f_vl((v_x - 3.0), v_gy0, 10.0, "#5f8ea2")
	game.f_fr((v_x - 3.0), (v_gy0 - 2.0), 6.0, 3.0, "#a8842c")
	game.f_hl((v_x - 3.0), (v_gy0 - 2.0), 6.0, "#e0bc58")
	game.f_fr((v_x - 3.0), (v_gy0 - 7.0), 6.0, 5.0, "#c9885a")
	game.f_fr((v_x - 2.0), (v_gy0 - 7.0), 4.0, 4.0, "#e0a978")
	game.f_px((v_x - 2.0), (v_gy0 - 5.0), "#2b2018")
	game.f_px(J.add(v_x, 1.0), (v_gy0 - 5.0), "#2b2018")
	game.f_fr((v_x - 4.0), (v_gy0 - 10.0), 8.0, 4.0, "#b8a684")
	game.f_fr((v_x - 4.0), (v_gy0 - 10.0), 7.0, 3.0, "#e8dcc0")
	game.f_fr((v_x - 5.0), (v_gy0 - 7.0), 2.0, 8.0, "#d8c9a8")
	game.f_fr(J.add(v_x, 3.0), (v_gy0 - 7.0), 2.0, 8.0, "#a89474")
	if J.truth(v_yuru):
		game.f_px(J.add((v_x - 2.0), v_ad), (v_y - 1.0), "#2b2018")
		game.f_px((J.add(v_x, 1.0) - v_ad), (v_y - 1.0), "#2b2018")
	return null

func _closure_54(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_i: Variant = null
	var v_a: Variant = null
	var v_b: Variant = null
	var v_q: Variant = null
	var v_u: Variant = null
	var v_rr: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_pts: Variant = null
	var v_r0: Variant = null
	var v_r1: Variant = null
	v_pts = J.arg(_args, 0)
	v_r0 = J.arg(_args, 1)
	v_r1 = J.arg(_args, 2)
	v_i = 0.0
	while J.lt(v_i, (J.getv(v_pts, "length") - 1.0)):
		v_a = J.getv(v_pts, v_i)
		v_b = J.getv(v_pts, J.add(v_i, 1.0))
		v_q = 0.0
		while J.le(v_q, 5.0):
			v_u = (float(J.add(v_i, (float(v_q) / float(5.0)))) / float((J.getv(v_pts, "length") - 1.0)))
			v_rr = J.add(v_r0, ((v_r1 - v_r0) * v_u))
			v_ax = J.add(J.getv(v_a, 0.0), ((J.getv(v_b, 0.0) - J.getv(v_a, 0.0)) * (float(v_q) / float(5.0))))
			v_ay = J.add(J.getv(v_a, 1.0), ((J.getv(v_b, 1.0) - J.getv(v_a, 1.0)) * (float(v_q) / float(5.0))))
			game.f_ell(v_ax, v_ay, v_rr, (v_rr * 0.94), _captures["190:P1"][0])
			game.f_ell((v_ax - 1.0), (v_ay - 1.0), max(1.0, (v_rr - 1.4)), max(1.0, (v_rr * 0.7)), _captures["190:P2"][0])
			v_q = J.add(v_q, 1.0)
		v_i = J.add(v_i, 1.0)
	return null

