# Costume draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# chars.js:1217
func f_drawKalipGovde(p_id: Variant = null, p_x: Variant = null, p_by: Variant = null, p_bw: Variant = null, p_sh: Variant = null, p_s: Variant = null, p_L: Variant = null) -> Variant:
	var v_R: Variant = null
	var v_ana: Variant = null
	var v_koy: Variant = null
	var v_ac: Variant = null
	var v_sol: Variant = null
	var v_sag: Variant = null
	var v_alt: Variant = null
	var v_v: Variant = null
	var v_d: Variant = null
	var v_kf: Variant = null
	var v_sr: Variant = null
	var v_kk: Variant = null
	var v_kx0: Variant = null
	var v_kd: Variant = null
	var v_kz: Variant = null
	var v_ky2: Variant = null
	var v_kxx: Variant = null
	var v_ai: Variant = null
	var v_az: Variant = null
	var v_pi: Variant = null
	var v_b2: Variant = null
	var v_pu: Variant = null
	var v_ci: Variant = null
	var v_cx2: Variant = null
	var v_cy2: Variant = null
	var v_ax: Variant = null
	var v_ay: Variant = null
	var v_vi: Variant = null
	var v_id: Variant = p_id
	var v_x: Variant = p_x
	var v_by: Variant = p_by
	var v_bw: Variant = p_bw
	var v_sh: Variant = p_sh
	var v_s: Variant = p_s
	var v_L: Variant = p_L
	if ((not J.truth(v_id)) or J.eq(v_id, "yok")):
		return null
	v_R = J.getv(game.j_KALIP_RENK, v_id)
	if (not J.truth(v_R)):
		return null
	v_ana = game.appearance_system.f_kalipAna(v_id, J.getv(v_L, "seed"))
	v_koy = game.character_draw.f_shadeCol(v_ana, 0.72)
	v_ac = game.character_draw.f_shadeCol(v_ana, 1.22)
	v_sol = floor((v_x - (float(v_bw) / float(2.0))) + 0.5)
	v_sag = floor(J.add(v_x, (float(v_bw) / float(2.0))) + 0.5)
	v_alt = J.add(v_by, 30.0)
	if J.eq(v_id, "isci"):
		game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
		game.f_fr(J.add(v_sol, 1.0), J.add(v_by, 4.0), 8.0, 9.0, game.character_draw.f_shadeCol(v_sh, 0.9))
		game.f_fr((v_sag - 8.0), J.add(v_by, 4.0), 8.0, 9.0, game.character_draw.f_shadeCol(v_sh, 0.74))
		game.f_ell(v_x, J.add(v_by, 4.0), ((float(v_bw) / float(2.0)) - 1.0), 5.0, v_sh)
		game.f_fr((v_sol - 3.0), J.add(v_by, 8.0), 5.0, 9.0, game.character_draw.f_shadeCol(v_sh, 0.8))
		game.f_fr((v_sag - 2.0), J.add(v_by, 8.0), 5.0, 9.0, game.character_draw.f_shadeCol(v_sh, 0.66))
		game.f_fr((v_x - 9.0), J.add(v_by, 12.0), 18.0, ((v_alt - v_by) - 12.0), v_ana)
		game.f_fr((v_x - 9.0), J.add(v_by, 12.0), 18.0, 1.0, v_ac)
		game.f_fr((v_x - 9.0), J.add(v_by, 4.0), 3.0, 9.0, v_ana)
		game.f_fr(J.add(v_x, 6.0), J.add(v_by, 4.0), 3.0, 9.0, v_ana)
		game.f_px((v_x - 9.0), J.add(v_by, 4.0), v_ac)
		game.f_px(J.add(v_x, 6.0), J.add(v_by, 4.0), v_ac)
		game.f_px((v_x - 8.0), J.add(v_by, 12.0), J.getv(game.j_P, "au2"))
		game.f_px(J.add(v_x, 7.0), J.add(v_by, 12.0), J.getv(game.j_P, "au2"))
		game.f_fr((v_x - 8.0), J.add(v_by, 22.0), 7.0, 5.0, v_koy)
		game.f_hl((v_x - 8.0), J.add(v_by, 22.0), 7.0, v_ac)
		J.setv(game.j_ctx, "globalAlpha", 0.92)
		game.f_hl(J.add(v_sol, 1.0), J.add(v_by, 17.0), (v_bw - 2.0), J.getv(v_R, "seri"))
		game.f_hl(J.add(v_sol, 1.0), J.add(v_by, 20.0), (v_bw - 2.0), J.getv(v_R, "seri"))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.appearance_system.f_kalipYaka(v_x, v_by, v_sh, v_s)
	else:
		if J.eq(v_id, "memur"):
			game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
			game.f_fr((v_x - 4.0), J.add(v_by, 6.0), 8.0, ((v_alt - v_by) - 6.0), "#e6e2d6")
			game.f_fr((v_x - 4.0), J.add(v_by, 6.0), 1.0, ((v_alt - v_by) - 6.0), "#c8c2b2")
			v_v = 0.0
			while J.lt(v_v, 8.0):
				game.f_fr(J.add((v_x - 8.0), v_v), J.add(J.add(v_by, 5.0), v_v), 4.0, 1.0, v_koy)
				game.f_fr((J.add(v_x, 5.0) - v_v), J.add(J.add(v_by, 5.0), v_v), 4.0, 1.0, game.character_draw.f_shadeCol(v_ana, 0.6))
				game.f_px(J.add((v_x - 8.0), v_v), J.add(J.add(v_by, 5.0), v_v), v_ac)
				v_v = J.add(v_v, 1.0)
			game.f_fr((v_x - 2.0), J.add(v_by, 7.0), 4.0, 4.0, J.getv(v_R, "seri"))
			game.f_fr((v_x - 1.0), J.add(v_by, 11.0), 3.0, 13.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.9))
			game.f_px(v_x, J.add(v_by, 8.0), game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 1.35))
			v_d = 0.0
			while J.lt(v_d, 3.0):
				game.f_hl((v_x - 1.0), J.add(J.add(v_by, 14.0), (v_d * 4.0)), 3.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.7))
				v_d = J.add(v_d, 1.0)
			game.f_px((v_sag - 4.0), J.add(v_by, 16.0), J.getv(game.j_P, "au2"))
			game.appearance_system.f_kalipYaka(v_x, v_by, v_sh, v_s)
		else:
			if J.eq(v_id, "kuzeyli"):
				game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
				game.f_fr((v_sag - 1.0), (v_by - 10.0), 4.0, 15.0, "#5a6068")
				game.f_vl((v_sag - 1.0), (v_by - 10.0), 15.0, "#98a4b0")
				game.f_fr((v_sag - 5.0), (v_by - 13.0), 13.0, 3.0, "#c4cfd8")
				game.f_hl((v_sag - 5.0), (v_by - 13.0), 13.0, "#e2eaf0")
				game.f_fr((v_sag - 2.0), (v_by - 20.0), 6.0, 7.0, "#503b2a")
				game.f_vl((v_sag - 2.0), (v_by - 20.0), 7.0, "#6a5138")
				game.f_disc(J.add(v_sag, 1.0), (v_by - 22.0), 3.0, "#98a4b0")
				game.f_px(v_sag, (v_by - 23.0), "#e2eaf0")
				v_kf = J.getv(J.getv(v_R, "kurk"), floor((game.f_hash1(((J.getv(v_L, "seed") if J.truth(J.getv(v_L, "seed")) else 1.0) * 3.7)) * J.getv(J.getv(v_R, "kurk"), "length"))))
				v_sr = 0.0
				while J.lt(v_sr, 2.0):
					v_kk = 0.0
					while J.lt(v_kk, 11.0):
						v_kx0 = floor(J.add((v_sol - 6.0), (v_kk * (float(J.add(v_bw, 12.0)) / float(10.0)))) + 0.5)
						v_kd = (J.add(3.0, ((float(abs((v_kk - 5.0))) / float(5.0)) * 2.0)) - v_sr)
						if J.lt(v_kd, 2.0):
							v_kk = J.add(v_kk, 1.0)
							continue
						v_kz = J.add(J.add(J.add(v_by, 2.0), (v_sr * 4.0)), fmod(J.n(v_kk), J.n(2.0)))
						game.f_ell(v_kx0, J.add(v_kz, 1.0), J.add(v_kd, 1.0), v_kd, game.character_draw.f_shadeCol(v_kf, 0.66))
						game.f_ell(v_kx0, v_kz, v_kd, (v_kd - 1.0), (game.character_draw.f_shadeCol(v_kf, 0.86) if J.truth(v_sr) else v_kf))
						game.f_px((v_kx0 - 1.0), (v_kz - 1.0), game.character_draw.f_shadeCol(v_kf, 1.36))
						v_kk = J.add(v_kk, 1.0)
					v_sr = J.add(v_sr, 1.0)
				v_ky2 = 0.0
				while J.lt(v_ky2, 17.0):
					v_kxx = J.add((v_x - 8.0), floor((v_ky2 * 0.78) + 0.5))
					game.f_fr(v_kxx, J.add(J.add(v_by, 9.0), v_ky2), 3.0, 1.0, "#3a2a1e")
					game.f_px(v_kxx, J.add(J.add(v_by, 9.0), v_ky2), "#6a5138")
					v_ky2 = J.add(v_ky2, 1.0)
				game.f_fr(J.add(v_x, 1.0), J.add(v_by, 17.0), 5.0, 4.0, "#8a7328")
				game.f_px(J.add(v_x, 2.0), J.add(v_by, 18.0), "#b89c3c")
			else:
				if J.eq(v_id, "kimyager"):
					game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
					game.f_vl(v_x, J.add(v_by, 4.0), ((v_alt - v_by) - 4.0), game.character_draw.f_shadeCol(v_ana, 0.62))
					game.f_fr((v_x - 8.0), J.add(v_by, 2.0), 16.0, 3.0, v_ac)
					J.setv(game.j_ctx, "globalAlpha", 0.3)
					game.f_hl((v_x - 8.0), J.add(v_by, 5.0), 16.0, "#000")
					J.setv(game.j_ctx, "globalAlpha", 1.0)
					game.f_ell(v_x, J.add(v_by, 6.0), ((float(v_bw) / float(2.0)) - 2.0), 4.0, game.character_draw.f_shadeCol(v_ana, 0.78))
					game.f_fr((v_sol - 4.0), J.add(v_by, 24.0), 6.0, 6.0, "#2f6b3e")
					game.f_fr((v_sol - 4.0), J.add(v_by, 24.0), 5.0, 5.0, "#428f54")
					game.f_fr((v_sag - 2.0), J.add(v_by, 24.0), 6.0, 6.0, "#1e4a2c")
					game.f_fr((v_sag - 2.0), J.add(v_by, 24.0), 5.0, 5.0, "#2f6b3e")
					game.f_fr((v_x - 5.0), J.add(v_by, 8.0), 10.0, 5.0, J.getv(v_R, "seri"))
					game.f_fr((v_x - 4.0), J.add(v_by, 8.0), 8.0, 4.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 1.3))
					game.f_fr((v_x - 1.0), J.add(v_by, 13.0), 3.0, 3.0, J.getv(v_R, "seri"))
					game.appearance_system.f_kalipYaka(v_x, v_by, v_sh, v_s)
				else:
					if J.eq(v_id, "cirak"):
						game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
						game.f_fr((v_sol - 2.0), J.add(v_by, 22.0), J.add(v_bw, 4.0), 8.0, v_ana)
						game.f_fr((v_sol - 1.0), J.add(v_by, 22.0), J.add(v_bw, 2.0), 7.0, v_ac)
						game.f_fr((v_x - 10.0), J.add(v_by, 2.0), 20.0, 5.0, J.getv(v_R, "seri"))
						game.f_fr((v_x - 10.0), J.add(v_by, 2.0), 20.0, 3.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 1.2))
						v_ai = 0.0
						while J.lt(v_ai, 6.0):
							v_az = J.add(J.add(v_by, 7.0), (v_ai * 4.0))
							if J.gt(v_az, (v_alt - 2.0)):
								break
							game.f_fr((v_x - 9.0), v_az, 6.0, 4.0, ("#d8ac35" if J.truth(fmod(J.n(v_ai), J.n(2.0))) else J.getv(v_R, "seri")))
							game.f_px((v_x - 9.0), v_az, game.character_draw.f_shadeCol(("#d8ac35" if J.truth(fmod(J.n(v_ai), J.n(2.0))) else J.getv(v_R, "seri")), 1.3))
							v_ai = J.add(v_ai, 1.0)
						game.f_fr(J.add(v_x, 8.0), J.add(v_by, 7.0), 4.0, 9.0, J.getv(v_R, "seri"))
						game.f_fr(J.add(v_x, 8.0), J.add(v_by, 11.0), 4.0, 4.0, "#d8ac35")
						game.f_fr(J.add(v_sag, 1.0), J.add(v_by, 6.0), 2.0, 20.0, "#6f5638")
						game.f_px(J.add(v_sag, 1.0), J.add(v_by, 6.0), "#8a6f4a")
						game.f_disc(J.add(v_sag, 2.0), J.add(v_by, 4.0), 2.0, "#d8ac35")
					else:
						if J.eq(v_id, "kralice"):
							game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
							v_pi = 0.0
							while J.lt(v_pi, 5.0):
								game.f_vl(J.add((v_x - 10.0), (v_pi * 5.0)), J.add(v_by, 10.0), ((v_alt - v_by) - 10.0), game.character_draw.f_shadeCol(v_ana, 0.78))
								game.f_vl(J.add((v_x - 9.0), (v_pi * 5.0)), J.add(v_by, 10.0), ((v_alt - v_by) - 10.0), game.character_draw.f_shadeCol(v_ana, 1.12))
								v_pi = J.add(v_pi, 1.0)
							game.f_fr((v_x - 8.0), v_by, 16.0, 9.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.68))
							game.f_fr((v_x - 7.0), v_by, 14.0, 8.0, J.getv(v_R, "seri"))
							game.f_hl((v_x - 7.0), v_by, 14.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 1.3))
							game.f_fr((v_x - 3.0), J.add(v_by, 9.0), 6.0, 4.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.82))
							game.f_px((v_x - 1.0), J.add(v_by, 10.0), "#ffd75e")
						else:
							if J.eq(v_id, "bilge"):
								game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
								game.f_fr((v_sol - 2.0), J.add(v_by, 20.0), J.add(v_bw, 4.0), 10.0, v_ana)
								game.f_fr((v_sol - 1.0), J.add(v_by, 20.0), J.add(v_bw, 2.0), 9.0, v_ac)
								game.f_fr((v_x - 11.0), J.add(v_by, 15.0), 22.0, 4.0, J.getv(v_R, "seri"))
								game.f_hl((v_x - 11.0), J.add(v_by, 15.0), 22.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 1.35))
								game.f_px(v_x, J.add(v_by, 16.0), "#b89c3c")
								game.f_fr(J.add(v_sag, 1.0), (v_by - 6.0), 2.0, 34.0, "#6f5638")
								game.f_px(J.add(v_sag, 1.0), (v_by - 6.0), "#8a6f4a")
								game.f_fr((v_sag - 1.0), (v_by - 9.0), 6.0, 3.0, "#54402a")
							else:
								if J.eq(v_id, "ogrenci"):
									game.f_fr((v_sol - 5.0), J.add(v_by, 10.0), 4.0, 14.0, v_koy)
									game.f_fr(J.add(v_sag, 1.0), J.add(v_by, 10.0), 4.0, 14.0, game.character_draw.f_shadeCol(v_ana, 0.6))
									game.f_ell(v_x, J.add(v_by, 7.0), ((float(v_bw) / float(2.0)) - 1.0), 5.0, game.character_draw.f_shadeCol(v_sh, 0.66))
									game.f_ell(v_x, J.add(v_by, 6.0), ((float(v_bw) / float(2.0)) - 2.0), 4.0, game.character_draw.f_shadeCol(v_sh, 0.82))
									game.f_hl((v_x - 7.0), J.add(v_by, 3.0), 14.0, game.character_draw.f_shadeCol(v_sh, 0.58))
									game.f_fr((v_x - 9.0), J.add(v_by, 21.0), 18.0, 1.0, game.character_draw.f_shadeCol(v_sh, 0.6))
									game.f_fr((v_x - 9.0), J.add(v_by, 21.0), 1.0, 6.0, game.character_draw.f_shadeCol(v_sh, 0.6))
									game.f_fr(J.add(v_x, 8.0), J.add(v_by, 21.0), 1.0, 6.0, game.character_draw.f_shadeCol(v_sh, 0.6))
									game.f_fr((v_x - 8.0), J.add(v_by, 6.0), 3.0, 22.0, v_ana)
									game.f_fr(J.add(v_x, 6.0), J.add(v_by, 6.0), 3.0, 22.0, v_ana)
									game.f_vl((v_x - 8.0), J.add(v_by, 6.0), 22.0, v_ac)
									game.f_vl(J.add(v_x, 6.0), J.add(v_by, 6.0), 22.0, v_ac)
									game.f_px((v_x - 7.0), J.add(v_by, 17.0), J.getv(v_R, "seri"))
									game.f_px(J.add(v_x, 7.0), J.add(v_by, 17.0), J.getv(v_R, "seri"))
									game.appearance_system.f_kalipYaka(v_x, v_by, v_sh, v_s)
								else:
									if J.eq(v_id, "yasli"):
										game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
										game.f_fr((v_x - 4.0), J.add(v_by, 8.0), 8.0, ((v_alt - v_by) - 8.0), game.character_draw.f_shadeCol(v_sh, 1.05))
										game.f_fr((v_x - 4.0), J.add(v_by, 8.0), 1.0, ((v_alt - v_by) - 8.0), game.character_draw.f_shadeCol(v_sh, 0.8))
										game.f_fr(J.add(v_x, 3.0), J.add(v_by, 8.0), 1.0, ((v_alt - v_by) - 8.0), game.character_draw.f_shadeCol(v_sh, 0.8))
										v_b2 = 0.0
										while J.lt(v_b2, 4.0):
											game.f_px((v_x - 6.0), J.add(J.add(v_by, 13.0), (v_b2 * 5.0)), J.getv(v_R, "seri"))
											game.f_px((v_x - 6.0), J.add(J.add(v_by, 14.0), (v_b2 * 5.0)), game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.7))
											v_b2 = J.add(v_b2, 1.0)
										game.f_hl(J.add(v_sol, 1.0), J.add(v_by, 4.0), 8.0, v_ac)
										game.f_fr((v_x - 9.0), J.add(v_by, 2.0), 18.0, 6.0, J.getv(v_R, "seri"))
										game.f_fr((v_x - 9.0), J.add(v_by, 2.0), 18.0, 4.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 1.14))
										J.setv(game.j_ctx, "globalAlpha", 0.35)
										game.f_hl((v_x - 8.0), J.add(v_by, 7.0), 16.0, "#000")
										J.setv(game.j_ctx, "globalAlpha", 1.0)
										game.f_fr(J.add(v_x, 4.0), J.add(v_by, 8.0), 5.0, 12.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.94))
										game.f_hl(J.add(v_x, 4.0), J.add(v_by, 8.0), 5.0, J.getv(v_R, "seri"))
										v_pu = 0.0
										while J.lt(v_pu, 5.0):
											game.f_px(J.add(J.add(v_x, 4.0), v_pu), J.add(v_by, 20.0), game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.68))
											v_pu = J.add(v_pu, 1.0)
									else:
										if J.eq(v_id, "turist"):
											game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
											game.f_fr((v_sol - 3.0), J.add(v_by, 8.0), 5.0, 10.0, game.character_draw.f_shadeCol(v_ana, 0.8))
											game.f_fr((v_sag - 2.0), J.add(v_by, 8.0), 5.0, 10.0, game.character_draw.f_shadeCol(v_ana, 0.66))
											game.f_fr((v_sol - 3.0), J.add(v_by, 18.0), 5.0, 12.0, J.getv(v_s, 2.0))
											game.f_fr((v_sol - 3.0), J.add(v_by, 18.0), 4.0, 11.0, J.getv(v_s, 1.0))
											game.f_fr((v_sag - 2.0), J.add(v_by, 18.0), 5.0, 12.0, J.getv(v_s, 2.0))
											v_ci = 0.0
											while J.lt(v_ci, 12.0):
												v_cx2 = J.add(J.add(v_sol, 3.0), fmod(J.n((v_ci * 7.0)), J.n((v_bw - 6.0))))
												v_cy2 = J.add(J.add(v_by, 8.0), fmod(J.n((v_ci * 5.0)), J.n(20.0)))
												game.f_px(v_cx2, v_cy2, J.getv(v_R, "seri"))
												game.f_px(J.add(v_cx2, 1.0), J.add(v_cy2, 1.0), J.getv(v_R, "seri"))
												game.f_px((v_cx2 - 1.0), J.add(v_cy2, 1.0), J.getv(v_R, "seri"))
												game.f_px(v_cx2, J.add(v_cy2, 2.0), game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.8))
												v_ci = J.add(v_ci, 1.0)
											game.f_ln((v_x - 6.0), J.add(v_by, 5.0), (v_x - 2.0), J.add(v_by, 16.0), "#4a3f30")
											game.f_ln(J.add(v_x, 6.0), J.add(v_by, 5.0), J.add(v_x, 2.0), J.add(v_by, 16.0), "#4a3f30")
											game.f_fr((v_x - 5.0), J.add(v_by, 16.0), 10.0, 7.0, "#25252a")
											game.f_fr((v_x - 5.0), J.add(v_by, 16.0), 10.0, 5.0, "#3f3f46")
											game.f_hl((v_x - 4.0), J.add(v_by, 16.0), 8.0, "#5f5f68")
											game.f_disc(v_x, J.add(v_by, 19.0), 2.0, "#14141a")
											game.f_px((v_x - 1.0), J.add(v_by, 18.0), "#7ab0d8")
											game.f_px(J.add(v_x, 4.0), J.add(v_by, 17.0), "#c8c0a8")
											game.appearance_system.f_kalipYaka(v_x, v_by, v_sh, v_s)
										else:
											if J.eq(v_id, "sporcu"):
												game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
												game.f_fr((v_sol - 3.0), J.add(v_by, 10.0), 2.0, 20.0, J.getv(v_R, "seri"))
												game.f_fr(J.add(v_sag, 1.0), J.add(v_by, 10.0), 2.0, 20.0, game.character_draw.f_shadeCol(J.getv(v_R, "seri"), 0.86))
												game.f_fr((v_x - 1.0), J.add(v_by, 8.0), 2.0, ((v_alt - v_by) - 8.0), game.character_draw.f_shadeCol(v_ana, 0.58))
												game.f_vl((v_x - 1.0), J.add(v_by, 8.0), ((v_alt - v_by) - 8.0), game.character_draw.f_shadeCol(v_ana, 1.35))
												game.f_px(v_x, J.add(v_by, 10.0), J.getv(v_R, "seri"))
												game.f_fr((v_x - 7.0), J.add(v_by, 3.0), 14.0, 5.0, v_koy)
												game.f_fr((v_x - 7.0), J.add(v_by, 3.0), 14.0, 3.0, game.character_draw.f_shadeCol(v_ana, 1.08))
												game.f_hl((v_x - 6.0), J.add(v_by, 3.0), 12.0, J.getv(v_R, "seri"))
												game.f_fr((v_x - 8.0), J.add(v_by, 17.0), 5.0, 2.0, J.getv(v_R, "seri"))
												game.f_px((v_x - 7.0), J.add(v_by, 18.0), v_ana)
											else:
												if J.eq(v_id, "kurye"):
													game.f_fr(J.add(v_sol, 1.0), J.add(v_by, 6.0), (v_bw - 2.0), ((v_alt - v_by) - 6.0), v_ana)
													game.f_ell(v_x, J.add(v_by, 5.0), ((float(v_bw) / float(2.0)) - 2.0), 5.0, v_ana)
													game.f_fr(J.add(v_sol, 1.0), J.add(v_by, 6.0), 6.0, ((v_alt - v_by) - 6.0), game.character_draw.f_shadeCol(v_ana, 1.12))
													J.setv(game.j_ctx, "globalAlpha", 0.18)
													game.f_fr(J.add(v_x, 3.0), J.add(v_by, 6.0), ((float(v_bw) / float(2.0)) - 3.0), ((v_alt - v_by) - 6.0), "#000")
													J.setv(game.j_ctx, "globalAlpha", 1.0)
													J.setv(game.j_ctx, "globalAlpha", 0.95)
													game.f_hl(J.add(v_sol, 2.0), J.add(v_by, 16.0), (v_bw - 4.0), J.getv(v_R, "seri"))
													game.f_hl(J.add(v_sol, 2.0), J.add(v_by, 19.0), (v_bw - 4.0), J.getv(v_R, "seri"))
													J.setv(game.j_ctx, "globalAlpha", 1.0)
													game.f_fr((v_x - 1.0), J.add(v_by, 6.0), 2.0, ((v_alt - v_by) - 6.0), game.character_draw.f_shadeCol(v_ana, 0.6))
													v_ai = 0.0
													while J.lt(v_ai, 24.0):
														v_ax = floor(J.add((v_x - 10.0), (v_ai * 0.86)) + 0.5)
														v_ay = J.add(J.add(v_by, 5.0), v_ai)
														if J.gt(v_ay, v_alt):
															break
														game.f_fr(v_ax, v_ay, 3.0, 1.0, "#39312a")
														game.f_px(v_ax, v_ay, "#5c4e40")
														v_ai = J.add(v_ai, 1.0)
													game.appearance_system.f_kalipYaka(v_x, v_by, v_sh, v_s)
												else:
													if J.eq(v_id, "sofor"):
														game.appearance_system.f_kalipZemin(v_x, v_by, v_bw, v_ana)
														v_vi = 0.0
														while J.lt(v_vi, 7.0):
															game.f_fr(J.add((v_x - 5.0), v_vi), J.add(J.add(v_by, 4.0), v_vi), (10.0 - (v_vi * 2.0)), 1.0, "#e0dcd0")
															game.f_px(J.add((v_x - 5.0), v_vi), J.add(J.add(v_by, 4.0), v_vi), game.character_draw.f_shadeCol(v_ana, 0.6))
															game.f_px((J.add(v_x, 4.0) - v_vi), J.add(J.add(v_by, 4.0), v_vi), game.character_draw.f_shadeCol(v_ana, 0.6))
															v_vi = J.add(v_vi, 1.0)
														game.f_fr((v_x - 6.0), J.add(v_by, 3.0), 4.0, 3.0, "#e0dcd0")
														game.f_fr(J.add(v_x, 3.0), J.add(v_by, 3.0), 4.0, 3.0, "#cfcabc")
														game.f_fr((v_x - 1.0), J.add(v_by, 11.0), 2.0, 8.0, J.getv(v_R, "seri"))
														game.f_fr(J.add(v_sol, 2.0), J.add(v_by, 17.0), 6.0, 5.0, v_koy)
														game.f_hl(J.add(v_sol, 2.0), J.add(v_by, 17.0), 6.0, v_ac)
														J.setv(game.j_ctx, "globalAlpha", 0.3)
														game.f_hl(J.add(v_sol, 1.0), J.add(v_by, 29.0), (v_bw - 2.0), "#000")
														J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

