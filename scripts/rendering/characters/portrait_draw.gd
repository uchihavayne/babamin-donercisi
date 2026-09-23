# Portrait draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# chars.js:894
func f_drawAcc(p_hx: Variant = null, p_hy: Variant = null, p_hw: Variant = null, p_L: Variant = null, p_sh: Variant = null, p_hc: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdMusteriAks(p_hx, p_hy, p_hw, p_L, p_sh): return null
	var v_cc: Variant = null
	var v_k: Variant = null
	var v_hx: Variant = p_hx
	var v_hy: Variant = p_hy
	var v_hw: Variant = p_hw
	var v_L: Variant = p_L
	var v_sh: Variant = p_sh
	var v_hc: Variant = p_hc
	if J.eq(J.getv(v_L, "acc"), "cap"):
		v_cc = game.character_draw.f_shadeCol(v_sh, 0.8)
		game.f_fr(((v_hx - v_hw) - 1.0), (v_hy - 10.0), J.add((v_hw * 2.0), 2.0), 6.0, game.character_draw.f_shadeCol(v_cc, 0.7))
		game.f_ell(v_hx, (v_hy - 10.0), v_hw, 5.0, v_cc)
		game.f_fr((v_hx - v_hw), (v_hy - 10.0), (v_hw * 2.0), 5.0, v_cc)
		game.f_hl(J.add((v_hx - v_hw), 2.0), (v_hy - 12.0), ((v_hw * 2.0) - 4.0), game.character_draw.f_shadeCol(v_cc, 1.25))
		game.f_fr(((v_hx - v_hw) - 5.0), (v_hy - 6.0), 7.0, 2.0, game.character_draw.f_shadeCol(v_cc, 0.6))
		game.f_hl(((v_hx - v_hw) - 5.0), (v_hy - 6.0), 7.0, game.character_draw.f_shadeCol(v_cc, 0.9))
		game.f_disc(v_hx, (v_hy - 13.0), 1.0, game.character_draw.f_shadeCol(v_cc, 1.3))
	else:
		if J.eq(J.getv(v_L, "acc"), "kufiya"):
			game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 12.0), J.add((v_hw * 2.0), 4.0), 9.0, "#f4f4f0")
			game.f_fr(((v_hx - v_hw) - 3.0), (v_hy - 5.0), 4.0, 14.0, "#f4f4f0")
			game.f_fr((J.add(v_hx, v_hw) - 1.0), (v_hy - 5.0), 4.0, 14.0, "#f4f4f0")
			v_k = 0.0
			while J.lt(v_k, 7.0):
				game.f_px(J.add((v_hx - v_hw), (v_k * 3.0)), J.add((v_hy - 10.0), (fmod(J.n(v_k), J.n(2.0)) * 2.0)), "#d8443a")
				game.f_px(J.add(J.add((v_hx - v_hw), 1.0), (v_k * 3.0)), J.add((v_hy - 8.0), (fmod(J.n(v_k), J.n(2.0)) * 2.0)), "#d8443a")
				game.f_px(J.add(((v_hx - v_hw) - 2.0), fmod(J.n(v_k), J.n(3.0))), J.add((v_hy - 2.0), v_k), "#d8443a")
				v_k = J.add(v_k, 1.0)
			game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 14.0), J.add((v_hw * 2.0), 4.0), 3.0, "#2b2b28")
			game.f_hl(((v_hx - v_hw) - 1.0), (v_hy - 14.0), J.add((v_hw * 2.0), 2.0), "#55554e")
		else:
			if J.eq(J.getv(v_L, "acc"), "band"):
				game.f_fr(((v_hx - v_hw) - 1.0), (v_hy - 8.0), J.add((v_hw * 2.0), 2.0), 4.0, "#3f79c0")
				game.f_hl(((v_hx - v_hw) - 1.0), (v_hy - 8.0), J.add((v_hw * 2.0), 2.0), "#6b9ad8")
				game.f_hl(((v_hx - v_hw) - 1.0), (v_hy - 5.0), J.add((v_hw * 2.0), 2.0), "#2a5990")
				game.f_fr((J.add(v_hx, v_hw) - 1.0), (v_hy - 7.0), 5.0, 8.0, "#3f79c0")
				game.f_px(J.add(J.add(v_hx, v_hw), 3.0), J.add(v_hy, 1.0), "#2a5990")
	return null

# chars.js:923
func f_drawHair(p_hx: Variant = null, p_hy: Variant = null, p_hw: Variant = null, p_style: Variant = null, p_hc: Variant = null, p_s: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdMusteriSac(p_hx, p_hy, p_hw, p_style, p_hc): return null
	var v_d: Variant = null
	var v_l: Variant = null
	var v_i: Variant = null
	var v_sx: Variant = null
	var v_j: Variant = null
	var v_q9: Variant = null
	var v_qx: Variant = null
	var v_k: Variant = null
	var v_hx: Variant = p_hx
	var v_hy: Variant = p_hy
	var v_hw: Variant = p_hw
	var v_style: Variant = p_style
	var v_hc: Variant = p_hc
	var v_s: Variant = p_s
	if J.lt(v_style, 0.0):
		return null
	v_d = game.character_draw.f_shadeCol(v_hc, 0.72)
	v_l = game.character_draw.f_shadeCol(v_hc, 1.3)
	match v_style:
		0.0:
			game.f_ell(v_hx, (v_hy - 5.0), v_hw, 6.0, v_hc)
			game.f_fr((v_hx - v_hw), (v_hy - 5.0), (v_hw * 2.0), 3.0, v_hc)
			game.f_ell((v_hx - 3.0), (v_hy - 9.0), 5.0, 2.0, v_l)
			game.f_px((v_hx - v_hw), (v_hy - 1.0), v_d)
			game.f_px((J.add(v_hx, v_hw) - 1.0), (v_hy - 1.0), v_d)
		1.0:
			game.f_ell(v_hx, (v_hy - 5.0), v_hw, 4.0, v_hc)
			v_i = 0.0
			while J.lt(v_i, 6.0):
				v_sx = J.add(J.add((v_hx - v_hw), 1.0), (v_i * 4.0))
				game.f_fr(v_sx, J.add((v_hy - 12.0), fmod(J.n(v_i), J.n(2.0))), 3.0, 7.0, v_hc)
				game.f_px(v_sx, J.add((v_hy - 12.0), fmod(J.n(v_i), J.n(2.0))), v_l)
				v_i = J.add(v_i, 1.0)
		2.0:
			game.f_fr(((v_hx - v_hw) - 1.0), (v_hy - 4.0), 4.0, 7.0, v_hc)
			game.f_fr((J.add(v_hx, v_hw) - 2.0), (v_hy - 4.0), 4.0, 7.0, v_hc)
			game.f_ell((v_hx - 4.0), (v_hy - 8.0), 4.0, 2.0, "#fff2dc")
			J.setv(game.j_ctx, "globalAlpha", 0.25)
			game.f_ell(v_hx, (v_hy - 6.0), (v_hw - 2.0), 3.0, "#ffffff")
			J.setv(game.j_ctx, "globalAlpha", 1.0)
		3.0:
			game.f_ell(v_hx, (v_hy - 4.0), J.add(v_hw, 1.0), 7.0, v_hc)
			game.f_fr(((v_hx - v_hw) - 3.0), (v_hy - 7.0), 4.0, 16.0, v_hc)
			game.f_fr((J.add(v_hx, v_hw) - 1.0), (v_hy - 7.0), 4.0, 16.0, v_hc)
			game.f_ell((v_hx - 3.0), (v_hy - 10.0), 6.0, 2.0, v_l)
		4.0:
			game.f_ell(v_hx, (v_hy - 5.0), v_hw, 5.0, v_hc)
			game.f_disc(J.add(v_hx, 1.0), (v_hy - 12.0), 4.0, v_hc)
			game.f_px((v_hx - 1.0), (v_hy - 14.0), v_l)
		5.0:
			game.f_ell(v_hx, (v_hy - 5.0), v_hw, 5.0, v_hc)
			v_j = 0.0
			while J.lt(v_j, 5.0):
				game.f_ell(J.add(J.add((v_hx - v_hw), 2.0), (v_j * 5.0)), (v_hy - 9.0), 4.0, 3.0, v_hc)
				v_j = J.add(v_j, 1.0)
			game.f_ell((v_hx - 2.0), (v_hy - 11.0), 4.0, 2.0, v_l)
		6.0:
			game.f_ell(v_hx, (v_hy - 8.0), J.add(v_hw, 3.0), 7.0, v_hc)
			game.f_ell(((v_hx - v_hw) - 1.0), (v_hy - 4.0), 4.0, 5.0, v_hc)
			game.f_ell(J.add(J.add(v_hx, v_hw), 1.0), (v_hy - 4.0), 4.0, 5.0, v_hc)
			game.f_ell((v_hx - 3.0), (v_hy - 11.0), 5.0, 2.0, v_l)
		8.0:
			game.f_ell(v_hx, (v_hy - 5.0), J.add(v_hw, 1.0), 6.0, v_hc)
			game.f_fr(((v_hx - v_hw) - 1.0), (v_hy - 5.0), J.add((v_hw * 2.0), 2.0), 4.0, v_hc)
			game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 4.0), 4.0, 21.0, v_hc)
			game.f_fr((J.add(v_hx, v_hw) - 2.0), (v_hy - 4.0), 4.0, 21.0, v_hc)
			game.f_px(((v_hx - v_hw) - 2.0), J.add(v_hy, 16.0), v_d)
			game.f_px(J.add(J.add(v_hx, v_hw), 1.0), J.add(v_hy, 16.0), v_d)
			J.setv(game.j_ctx, "globalAlpha", 0.35)
			game.f_vl(((v_hx - v_hw) - 1.0), (v_hy - 2.0), 16.0, v_l)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_ell((v_hx - 3.0), (v_hy - 9.0), 5.0, 2.0, v_l)
		9.0:
			game.f_ell(v_hx, (v_hy - 5.0), v_hw, 5.0, v_hc)
			game.f_fr((v_hx - v_hw), (v_hy - 5.0), (v_hw * 2.0), 3.0, v_hc)
			game.f_fr((J.add(v_hx, v_hw) - 1.0), (v_hy - 4.0), 3.0, 4.0, game.character_draw.f_shadeCol(v_hc, 0.6))
			v_q9 = 0.0
			while J.lt(v_q9, 15.0):
				v_qx = J.add(J.add(J.add(v_hx, v_hw), 1.0), floor((sin((v_q9 * 0.33)) * 2.0) + 0.5))
				game.f_fr(v_qx, J.add((v_hy - 2.0), v_q9), 3.0, 1.0, (v_l if J.eq(fmod(J.n(v_q9), J.n(4.0)), 0.0) else v_hc))
				v_q9 = J.add(v_q9, 1.0)
			game.f_ell((v_hx - 3.0), (v_hy - 9.0), 5.0, 2.0, v_l)
		10.0:
			game.f_ell(v_hx, (v_hy - 5.0), v_hw, 6.0, v_hc)
			game.f_fr((v_hx - v_hw), (v_hy - 5.0), (v_hw * 2.0), 3.0, v_hc)
			game.f_ell(v_hx, (v_hy - 13.0), 5.0, 4.0, v_hc)
			game.f_ell(v_hx, (v_hy - 14.0), 4.0, 3.0, v_l)
			J.setv(game.j_ctx, "globalAlpha", 0.4)
			game.f_ring(v_hx, (v_hy - 13.0), 4.0, v_d)
			J.setv(game.j_ctx, "globalAlpha", 1.0)
			game.f_px((v_hx - v_hw), (v_hy - 1.0), v_d)
			game.f_px((J.add(v_hx, v_hw) - 1.0), (v_hy - 1.0), v_d)
		_:
			game.f_ell(v_hx, (v_hy - 5.0), v_hw, 5.0, v_hc)
			v_k = 0.0
			while J.lt(v_k, 5.0):
				game.f_ln(J.add((v_hx - 8.0), (v_k * 4.0)), (v_hy - 9.0), J.add((v_hx - 5.0), (v_k * 4.0)), (v_hy - 4.0), v_l)
				v_k = J.add(v_k, 1.0)
	return null

# chars.js:1473
func f_drawKalipBas(p_id: Variant = null, p_hx: Variant = null, p_hy: Variant = null, p_hw: Variant = null, p_s: Variant = null, p_L: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdKalipBas(p_id, p_hx, p_hy, p_hw, p_s, p_L): return null
	var v_R: Variant = null
	var v_ana: Variant = null
	var v_ac: Variant = null
	var v_bc: Variant = null
	var v_kzc: Variant = null
	var v_t2: Variant = null
	var v_tz: Variant = null
	var v_tk: Variant = null
	var v_skl: Variant = null
	var v_sklK: Variant = null
	var v_sb: Variant = null
	var v_sbw: Variant = null
	var v_sbz: Variant = null
	var v_ccc: Variant = null
	var v_di: Variant = null
	var v_dx2: Variant = null
	var v_gc2: Variant = null
	var v_oi: Variant = null
	var v_oz: Variant = null
	var v_scc: Variant = null
	var v_hi: Variant = null
	var v_kw: Variant = null
	var v_kzz: Variant = null
	var v_bi: Variant = null
	var v_bw3: Variant = null
	var v_bz: Variant = null
	var v_tc: Variant = null
	var v_kk: Variant = null
	var v_kkKoy: Variant = null
	var v_kkAc: Variant = null
	var v_kc: Variant = null
	var v_id: Variant = p_id
	var v_hx: Variant = p_hx
	var v_hy: Variant = p_hy
	var v_hw: Variant = p_hw
	var v_s: Variant = p_s
	var v_L: Variant = p_L
	if ((not J.truth(v_id)) or J.eq(v_id, "yok")):
		return null
	v_R = J.getv(game.j_KALIP_RENK, v_id)
	if (not J.truth(v_R)):
		return null
	v_ana = game.appearance_system.f_kalipAna(v_id, J.getv(v_L, "seed"))
	v_ac = game.character_draw.f_shadeCol(v_ana, 1.25)
	if J.eq(v_id, "isci"):
		v_bc = "#e8b820"
		game.f_ell(v_hx, (v_hy - 7.0), J.add(v_hw, 1.0), 8.0, game.character_draw.f_shadeCol(v_bc, 0.7))
		game.f_ell(v_hx, (v_hy - 8.0), v_hw, 7.0, v_bc)
		game.f_fr(((v_hx - v_hw) - 4.0), (v_hy - 6.0), J.add((v_hw * 2.0), 8.0), 3.0, game.character_draw.f_shadeCol(v_bc, 0.62))
		game.f_fr(((v_hx - v_hw) - 4.0), (v_hy - 6.0), J.add((v_hw * 2.0), 8.0), 2.0, game.character_draw.f_shadeCol(v_bc, 0.88))
		game.f_hl(((v_hx - v_hw) - 3.0), (v_hy - 6.0), J.add((v_hw * 2.0), 6.0), game.character_draw.f_shadeCol(v_bc, 1.15))
		game.f_fr((v_hx - 1.0), (v_hy - 15.0), 2.0, 8.0, game.character_draw.f_shadeCol(v_bc, 0.78))
		game.f_ell((v_hx - 4.0), (v_hy - 12.0), 4.0, 2.0, game.character_draw.f_shadeCol(v_bc, 1.35))
		J.setv(game.j_ctx, "globalAlpha", 0.4)
		game.f_hl(J.add((v_hx - v_hw), 2.0), (v_hy - 4.0), ((v_hw * 2.0) - 4.0), "#000")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	else:
		if J.eq(v_id, "kuzeyli"):
			v_kzc = "#241d16"
			game.f_ell(v_hx, (v_hy - 7.0), J.add(v_hw, 1.0), 6.0, v_kzc)
			game.f_ell((v_hx - 2.0), (v_hy - 9.0), (v_hw - 2.0), 3.0, game.character_draw.f_shadeCol(v_kzc, 1.4))
			v_t2 = 0.0
			while J.lt(v_t2, 13.0):
				v_tz = J.add((v_hy - 6.0), v_t2)
				v_tk = J.add(3.0, (1.0 if J.eq(fmod(J.n(v_t2), J.n(3.0)), 0.0) else 0.0))
				game.f_fr(((v_hx - v_hw) - v_tk), v_tz, v_tk, 1.0, v_kzc)
				game.f_fr(J.add(v_hx, v_hw), v_tz, v_tk, 1.0, game.character_draw.f_shadeCol(v_kzc, 0.84))
				if J.eq(fmod(J.n(v_t2), J.n(4.0)), 1.0):
					game.f_px(((v_hx - v_hw) - v_tk), v_tz, game.character_draw.f_shadeCol(v_kzc, 1.3))
				v_t2 = J.add(v_t2, 1.0)
			v_skl = "#4a3a28"
			v_sklK = "#33271b"
			v_sb = 0.0
			while J.lt(v_sb, 7.0):
				v_sbw = max(2.0, (6.0 - floor((v_sb * 0.8) + 0.5)))
				v_sbz = J.add(J.add(v_hy, 5.0), v_sb)
				game.f_fr((v_hx - v_sbw), v_sbz, (v_sbw * 2.0), 1.0, (v_skl if J.lt(v_sb, 4.0) else v_sklK))
				game.f_px((v_hx - v_sbw), v_sbz, v_sklK)
				game.f_px((J.add(v_hx, v_sbw) - 1.0), v_sbz, v_sklK)
				v_sb = J.add(v_sb, 1.0)
			game.f_fr((v_hx - 5.0), J.add(v_hy, 3.0), 11.0, 1.0, v_skl)
			game.f_px((v_hx - 5.0), J.add(v_hy, 3.0), v_sklK)
			game.f_px(J.add(v_hx, 5.0), J.add(v_hy, 3.0), v_sklK)
			game.f_vl((v_hx - 6.0), J.add(v_hy, 1.0), 5.0, v_sklK)
			game.f_vl(J.add(v_hx, 5.0), J.add(v_hy, 1.0), 5.0, v_sklK)
		else:
			if J.eq(v_id, "kimyager"):
				game.f_ell(v_hx, (v_hy - 6.0), J.add(v_hw, 1.0), 7.0, J.getv(v_s, 1.0))
				game.f_ell((v_hx - 1.0), (v_hy - 7.0), (v_hw - 1.0), 5.0, J.getv(v_s, 2.0))
				game.f_ell((v_hx - 3.0), (v_hy - 9.0), 3.0, 2.0, J.getv(v_s, 3.0))
				game.f_fr(((v_hx - v_hw) - 1.0), (v_hy - 2.0), 2.0, 5.0, "#8f8f9a")
				game.f_fr((J.add(v_hx, v_hw) - 1.0), (v_hy - 2.0), 2.0, 5.0, "#8f8f9a")
				game.f_fr((v_hx - 3.0), J.add(v_hy, 9.0), 6.0, 2.0, "#3a2a1c")
				game.f_px((v_hx - 3.0), J.add(v_hy, 9.0), "#50402c")
				game.f_px(J.add(v_hx, 2.0), J.add(v_hy, 9.0), "#50402c")
			else:
				if J.eq(v_id, "cirak"):
					v_ccc = "#2a1e14"
					game.f_ell(v_hx, (v_hy - 7.0), J.add(v_hw, 2.0), 6.0, v_ccc)
					game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 7.0), J.add((v_hw * 2.0), 4.0), 3.0, v_ccc)
					v_di = 0.0
					while J.lt(v_di, 5.0):
						v_dx2 = J.add((v_hx - v_hw), (v_di * max(2.0, (int(J.n((float((v_hw * 2.0)) / float(4.0)))) | int(J.n(0.0))))))
						game.f_fr(v_dx2, ((v_hy - 10.0) - fmod(J.n(v_di), J.n(2.0))), 3.0, 3.0, v_ccc)
						v_di = J.add(v_di, 1.0)
					game.f_ell((v_hx - 3.0), (v_hy - 9.0), 4.0, 2.0, game.character_draw.f_shadeCol(v_ccc, 1.5))
				else:
					if J.eq(v_id, "kralice"):
						v_gc2 = "#e8dcc0"
						game.f_ell(v_hx, (v_hy - 7.0), J.add(v_hw, 2.0), 6.0, "#b8a684")
						game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 7.0), J.add((v_hw * 2.0), 4.0), 3.0, "#b8a684")
						game.f_ell((v_hx - 1.0), (v_hy - 8.0), J.add(v_hw, 1.0), 5.0, v_gc2)
						game.f_ell((v_hx - 3.0), (v_hy - 10.0), 4.0, 2.0, "#fdf8ec")
						v_oi = 0.0
						while J.lt(v_oi, 5.0):
							v_oz = J.add((v_hy - 2.0), (v_oi * 4.0))
							game.f_ell(((v_hx - v_hw) - 1.0), v_oz, 3.0, 3.0, "#a89474")
							game.f_ell(((v_hx - v_hw) - 1.0), (v_oz - 1.0), 3.0, 2.0, v_gc2)
							game.f_px(((v_hx - v_hw) - 2.0), (v_oz - 1.0), "#fdf8ec")
							game.f_ell(J.add(J.add(v_hx, v_hw), 1.0), v_oz, 3.0, 3.0, "#98846a")
							game.f_ell(J.add(J.add(v_hx, v_hw), 1.0), (v_oz - 1.0), 3.0, 2.0, "#d8c9a8")
							v_oi = J.add(v_oi, 1.0)
					else:
						if J.eq(v_id, "bilge"):
							v_scc = game.character_draw.f_shadeCol(v_ana, 0.92)
							game.f_fr(((v_hx - v_hw) - 5.0), (v_hy - 6.0), J.add((v_hw * 2.0), 10.0), 3.0, game.character_draw.f_shadeCol(v_scc, 0.68))
							game.f_fr(((v_hx - v_hw) - 5.0), (v_hy - 6.0), J.add((v_hw * 2.0), 9.0), 2.0, v_scc)
							game.f_hl(((v_hx - v_hw) - 4.0), (v_hy - 7.0), J.add((v_hw * 2.0), 7.0), game.character_draw.f_shadeCol(v_scc, 1.2))
							v_hi = 0.0
							while J.lt(v_hi, 13.0):
								v_kw = max(1.0, floor(((v_hw - 1.0) * (1.0 - (float(v_hi) / float(13.0)))) + 0.5))
								v_kzz = ((v_hy - 8.0) - v_hi)
								game.f_fr(J.add((v_hx - v_kw), floor((v_hi * 0.25) + 0.5)), v_kzz, (v_kw * 2.0), 1.0, v_scc)
								game.f_px(J.add((v_hx - v_kw), floor((v_hi * 0.25) + 0.5)), v_kzz, game.character_draw.f_shadeCol(v_scc, 1.25))
								v_hi = J.add(v_hi, 1.0)
							game.f_fr(J.add((v_hx - v_hw), 1.0), (v_hy - 9.0), ((v_hw * 2.0) - 2.0), 2.0, game.character_draw.f_shadeCol(v_ana, 0.62))
							v_bi = 0.0
							while J.lt(v_bi, 14.0):
								v_bw3 = max(2.0, (8.0 - floor((v_bi * 0.48) + 0.5)))
								v_bz = J.add(J.add(v_hy, 4.0), v_bi)
								game.f_fr((v_hx - v_bw3), v_bz, (v_bw3 * 2.0), 1.0, ("#d8d8d2" if J.lt(v_bi, 9.0) else "#bcbcb6"))
								game.f_px((v_hx - v_bw3), v_bz, "#9a9a96")
								game.f_px((J.add(v_hx, v_bw3) - 1.0), v_bz, "#9a9a96")
								if J.eq(fmod(J.n(v_bi), J.n(4.0)), 0.0):
									game.f_hl(J.add((v_hx - v_bw3), 1.0), v_bz, v_bw3, "#ffffff")
								v_bi = J.add(v_bi, 1.0)
							game.f_fr((v_hx - 5.0), J.add(v_hy, 3.0), 11.0, 2.0, "#eeeeea")
							game.f_px((v_hx - 5.0), J.add(v_hy, 3.0), "#bcbcb6")
							game.f_px(J.add(v_hx, 5.0), J.add(v_hy, 3.0), "#bcbcb6")
						else:
							if J.eq(v_id, "turist"):
								v_tc = "#ddc98f"
								game.f_ell(v_hx, (v_hy - 6.0), J.add(v_hw, 6.0), 3.0, game.character_draw.f_shadeCol(v_tc, 0.66))
								game.f_ell(v_hx, (v_hy - 7.0), J.add(v_hw, 5.0), 3.0, v_tc)
								game.f_hl(((v_hx - v_hw) - 3.0), (v_hy - 8.0), J.add((v_hw * 2.0), 6.0), game.character_draw.f_shadeCol(v_tc, 1.15))
								game.f_ell(v_hx, (v_hy - 10.0), (v_hw - 1.0), 6.0, game.character_draw.f_shadeCol(v_tc, 0.84))
								game.f_ell(v_hx, (v_hy - 11.0), (v_hw - 2.0), 5.0, v_tc)
								game.f_ell((v_hx - 4.0), (v_hy - 14.0), 4.0, 2.0, game.character_draw.f_shadeCol(v_tc, 1.25))
								J.setv(game.j_ctx, "globalAlpha", 0.95)
								game.f_hl(J.add((v_hx - v_hw), 2.0), (v_hy - 8.0), ((v_hw * 2.0) - 4.0), "#8a5f31")
								J.setv(game.j_ctx, "globalAlpha", 1.0)
								game.f_fr((J.add(v_hx, v_hw) - 6.0), (v_hy - 9.0), 3.0, 2.0, "#b8442e")
							else:
								if J.eq(v_id, "kurye"):
									v_kk = J.getv(J.getv(v_R, "kask"), floor((game.f_hash1(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 1.0) * 7.3)) * J.getv(J.getv(v_R, "kask"), "length"))))
									v_kkKoy = game.character_draw.f_shadeCol(v_kk, 0.58)
									v_kkAc = game.character_draw.f_shadeCol(v_kk, 1.28)
									game.f_ell(v_hx, (v_hy - 9.0), J.add(v_hw, 2.0), 9.0, v_kkKoy)
									game.f_ell(v_hx, (v_hy - 10.0), J.add(v_hw, 1.0), 8.0, v_kk)
									game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 10.0), J.add((v_hw * 2.0), 5.0), 6.0, v_kk)
									game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 10.0), 6.0, 6.0, v_kkAc)
									game.f_ell((v_hx - 4.0), (v_hy - 15.0), 5.0, 2.0, v_kkAc)
									J.setv(game.j_ctx, "globalAlpha", 0.3)
									game.f_fr(J.add(v_hx, 3.0), (v_hy - 12.0), (v_hw - 1.0), 8.0, "#000")
									J.setv(game.j_ctx, "globalAlpha", 1.0)
									game.f_fr(((v_hx - v_hw) - 3.0), (v_hy - 5.0), J.add((v_hw * 2.0), 6.0), 2.0, v_kkKoy)
									game.f_hl(((v_hx - v_hw) - 3.0), (v_hy - 5.0), J.add((v_hw * 2.0), 6.0), game.character_draw.f_shadeCol(v_kk, 0.88))
									game.f_fr(((v_hx - v_hw) - 2.0), (v_hy - 4.0), 3.0, 8.0, v_kkKoy)
									game.f_fr(J.add(v_hx, v_hw), (v_hy - 4.0), 3.0, 8.0, game.character_draw.f_shadeCol(v_kk, 0.48))
									game.f_px(((v_hx - v_hw) - 2.0), (v_hy - 3.0), v_kkAc)
									J.setv(game.j_ctx, "globalAlpha", 0.45)
									game.f_fr(J.add((v_hx - v_hw), 1.0), (v_hy - 13.0), ((v_hw * 2.0) - 2.0), 3.0, "#8ab8d8")
									J.setv(game.j_ctx, "globalAlpha", 1.0)
									game.f_hl(J.add((v_hx - v_hw), 2.0), (v_hy - 13.0), ((v_hw * 2.0) - 4.0), "#cfe4f2")
									game.f_ln((v_hx - v_hw), J.add(v_hy, 4.0), (v_hx - 2.0), J.add(v_hy, 9.0), "#2b261f")
									game.f_ln(J.add(J.add(v_hx, v_hw), 1.0), J.add(v_hy, 4.0), J.add(v_hx, 2.0), J.add(v_hy, 9.0), "#2b261f")
									game.f_fr((v_hx - 3.0), J.add(v_hy, 9.0), 6.0, 2.0, "#3d362e")
									game.f_px(v_hx, J.add(v_hy, 9.0), "#7a6c58")
								else:
									if J.eq(v_id, "sofor"):
										v_kc = J.getv(J.getv(v_R, "kasket"), floor((game.f_hash1(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 1.0) * 11.9)) * J.getv(J.getv(v_R, "kasket"), "length"))))
										game.f_ell(v_hx, (v_hy - 8.0), J.add(v_hw, 1.0), 5.0, game.character_draw.f_shadeCol(v_kc, 0.66))
										game.f_ell(v_hx, (v_hy - 9.0), v_hw, 4.0, v_kc)
										game.f_fr((v_hx - v_hw), (v_hy - 9.0), (v_hw * 2.0), 5.0, v_kc)
										game.f_fr((v_hx - v_hw), (v_hy - 9.0), v_hw, 5.0, game.character_draw.f_shadeCol(v_kc, 1.12))
										game.f_hl(J.add((v_hx - v_hw), 2.0), (v_hy - 11.0), ((v_hw * 2.0) - 4.0), game.character_draw.f_shadeCol(v_kc, 1.32))
										game.f_fr(((v_hx - v_hw) - 5.0), (v_hy - 5.0), 9.0, 2.0, game.character_draw.f_shadeCol(v_kc, 0.52))
										game.f_hl(((v_hx - v_hw) - 5.0), (v_hy - 5.0), 9.0, game.character_draw.f_shadeCol(v_kc, 0.78))
										J.setv(game.j_ctx, "globalAlpha", 0.35)
										game.f_hl(J.add((v_hx - v_hw), 1.0), (v_hy - 4.0), ((v_hw * 2.0) - 2.0), "#000")
										J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

