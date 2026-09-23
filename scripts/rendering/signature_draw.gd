# Signature draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# sehir.js:269
func f_drawImza(p_id: Variant = null, p_cx: Variant = null, p_taban: Variant = null) -> Variant:
	var _cells: Dictionary = {"taban": [p_taban]}
	var v_k1: Variant = null
	var v_k2: Variant = null
	var v_isik: Variant = null
	var v_y: Variant = null
	var v_i: Variant = null
	var v_kk: Variant = null
	var v_m: Variant = null
	var v_mx: Variant = null
	var v_mk: Variant = null
	var v_t2: Variant = null
	var v_y2: Variant = null
	var v_g2: Variant = null
	var v_s2: Variant = null
	var v_sw: Variant = null
	var v_pg: Variant = null
	var v_pw: Variant = null
	var v_py: Variant = null
	var v_mb: Variant = null
	var v_mn: Variant = null
	var v_mbx: Variant = null
	var v_mw: Variant = null
	var v_pxx: Variant = null
	var v_pl: Variant = null
	var v_pa: Variant = null
	var v_boy: Variant = null
	var v_n2: Variant = null
	var v_bx: Variant = null
	var v_wy2: Variant = null
	var v_kt: Variant = null
	var v_bd: Variant = null
	var v_bxx: Variant = null
	var v_id: Variant = p_id
	var v_cx: Variant = p_cx
	v_y = game.signature_draw._closure_79.bind({"328:taban": _cells["taban"]})
	if (not J.truth(v_id)):
		return null
	v_k1 = "rgba(64,86,104,.62)"
	v_k2 = "rgba(64,86,104,.82)"
	v_isik = "rgba(252,242,196,.6)"
	if J.eq(v_id, "galata"):
		game.f_fr((v_cx - 6.0), J.invoke(v_y, [38.0]), 13.0, 38.0, v_k1)
		v_i = 0.0
		while J.lt(v_i, 3.0):
			game.f_px(J.add((v_cx - 3.0), (v_i * 3.0)), J.invoke(v_y, [30.0]), v_isik)
			v_i = J.add(v_i, 1.0)
		game.f_fr((v_cx - 7.0), J.invoke(v_y, [41.0]), 15.0, 3.0, v_k2)
		v_kk = 0.0
		while J.lt(v_kk, 7.0):
			game.f_fr(J.add((v_cx - 6.0), v_kk), J.invoke(v_y, [J.add(J.add(41.0, v_kk), 1.0)]), (13.0 - (v_kk * 2.0)), 1.0, v_k2)
			v_kk = J.add(v_kk, 1.0)
		game.f_ln(v_cx, J.invoke(v_y, [49.0]), v_cx, J.invoke(v_y, [52.0]), v_k2)
		v_m = 0.0
		while J.lt(v_m, 2.0):
			v_mx = J.add(v_cx, (17.0 if J.truth(v_m) else (-J.n(18.0))))
			game.f_fr((v_mx - 1.0), J.invoke(v_y, [36.0]), 3.0, 36.0, v_k1)
			game.f_fr((v_mx - 3.0), J.invoke(v_y, [37.0]), 7.0, 2.0, v_k2)
			v_mk = 0.0
			while J.lt(v_mk, 3.0):
				game.f_fr(J.add((v_mx - 1.0), v_mk), J.invoke(v_y, [J.add(39.0, v_mk)]), (3.0 - (v_mk * 2.0)), 1.0, v_k2)
				v_mk = J.add(v_mk, 1.0)
			game.f_ln(v_mx, J.invoke(v_y, [42.0]), v_mx, J.invoke(v_y, [46.0]), v_k2)
			v_m = J.add(v_m, 1.0)
	else:
		if J.eq(v_id, "kule"):
			game.f_fr((v_cx - 2.0), J.invoke(v_y, [36.0]), 4.0, 36.0, v_k1)
			game.f_ell(v_cx, J.invoke(v_y, [40.0]), 7.0, 7.0, v_k2)
			game.f_ell(v_cx, J.invoke(v_y, [41.0]), 4.0, 4.0, "rgba(232,242,248,.55)")
			game.f_px((v_cx - 2.0), J.invoke(v_y, [41.0]), v_isik)
			game.f_px(J.add(v_cx, 2.0), J.invoke(v_y, [41.0]), v_isik)
			game.f_fr((v_cx - 1.0), J.invoke(v_y, [48.0]), 3.0, 8.0, v_k2)
			game.f_ln(v_cx, J.invoke(v_y, [50.0]), v_cx, J.invoke(v_y, [54.0]), v_k2)
		else:
			if J.eq(v_id, "saat"):
				game.f_fr((v_cx - 6.0), J.invoke(v_y, [36.0]), 13.0, 36.0, v_k1)
				game.f_fr((v_cx - 7.0), J.invoke(v_y, [39.0]), 15.0, 3.0, v_k2)
				game.f_ell(v_cx, J.invoke(v_y, [35.0]), 4.0, 4.0, "rgba(252,244,206,.85)")
				game.f_px(v_cx, J.invoke(v_y, [36.0]), v_k2)
				game.f_px(J.add(v_cx, 1.0), J.invoke(v_y, [35.0]), v_k2)
				v_t2 = 0.0
				while J.lt(v_t2, 5.0):
					game.f_fr(J.add((v_cx - 6.0), v_t2), J.invoke(v_y, [J.add(42.0, v_t2)]), (13.0 - (v_t2 * 2.0)), 1.0, v_k2)
					v_t2 = J.add(v_t2, 1.0)
				game.f_ln(v_cx, J.invoke(v_y, [47.0]), v_cx, J.invoke(v_y, [51.0]), v_k2)
			else:
				if J.eq(v_id, "kafes"):
					v_y2 = 0.0
					while J.lt(v_y2, 46.0):
						v_g2 = J.add(floor((13.0 * pow((1.0 - (float(v_y2) / float(46.0))), 1.7)) + 0.5), 1.0)
						game.f_px((v_cx - v_g2), J.invoke(v_y, [v_y2]), v_k1)
						game.f_px(J.add(v_cx, v_g2), J.invoke(v_y, [v_y2]), v_k1)
						if J.eq(fmod(J.n(v_y2), J.n(11.0)), 0.0):
							game.f_fr((v_cx - v_g2), J.invoke(v_y, [v_y2]), (v_g2 * 2.0), 1.0, v_k2)
						v_y2 = J.add(v_y2, 1.0)
					game.f_fr((v_cx - 2.0), J.invoke(v_y, [43.0]), 5.0, 3.0, v_k2)
					game.f_ln(v_cx, J.invoke(v_y, [46.0]), v_cx, J.invoke(v_y, [51.0]), v_k2)
				else:
					if J.eq(v_id, "gokdelen"):
						v_s2 = 0.0
						while J.lt(v_s2, 6.0):
							v_sw = (15.0 - (v_s2 * 2.0))
							game.f_fr((v_cx - (int(J.n(v_sw)) >> int(J.n(1.0)))), J.invoke(v_y, [J.add(J.add(8.0, (v_s2 * 7.0)), 9.0)]), v_sw, 10.0, (v_k2 if J.truth(fmod(J.n(v_s2), J.n(2.0))) else v_k1))
							v_s2 = J.add(v_s2, 1.0)
						game.f_ln(v_cx, J.invoke(v_y, [52.0]), v_cx, J.invoke(v_y, [60.0]), v_k2)
						game.f_px(v_cx, J.invoke(v_y, [56.0]), v_isik)
					else:
						if J.eq(v_id, "pagoda"):
							v_pg = 0.0
							while J.lt(v_pg, 5.0):
								v_pw = (24.0 - (v_pg * 4.0))
								v_py = J.invoke(v_y, [J.add(10.0, (v_pg * 8.0))])
								game.f_fr((v_cx - (int(J.n(v_pw)) >> int(J.n(1.0)))), v_py, v_pw, 2.0, v_k2)
								game.f_px(((v_cx - (int(J.n(v_pw)) >> int(J.n(1.0)))) - 1.0), J.add(v_py, 1.0), v_k2)
								game.f_px(J.add(v_cx, (int(J.n(v_pw)) >> int(J.n(1.0)))), J.add(v_py, 1.0), v_k2)
								game.f_fr(J.add((v_cx - (int(J.n(v_pw)) >> int(J.n(1.0)))), 2.0), J.add(v_py, 2.0), (v_pw - 4.0), 6.0, v_k1)
								v_pg = J.add(v_pg, 1.0)
							game.f_ln(v_cx, J.invoke(v_y, [44.0]), v_cx, J.invoke(v_y, [50.0]), v_k2)
						else:
							if J.eq(v_id, "kuleler"):
								v_mb = [34.0, 46.0, 30.0, 40.0]
								v_mn = 0.0
								while J.lt(v_mn, J.getv(v_mb, "length")):
									v_mbx = J.add((v_cx - 18.0), (v_mn * 10.0))
									game.f_fr(v_mbx, J.invoke(v_y, [J.getv(v_mb, v_mn)]), 8.0, J.getv(v_mb, v_mn), (v_k2 if J.truth(fmod(J.n(v_mn), J.n(2.0))) else v_k1))
									v_mw = 4.0
									while J.lt(v_mw, (J.getv(v_mb, v_mn) - 2.0)):
										if J.gt(game.f_hash1(J.add((v_mn * 3.7), v_mw)), 0.5):
											game.f_px(J.add(v_mbx, 3.0), J.invoke(v_y, [(J.getv(v_mb, v_mn) - v_mw)]), v_isik)
										v_mw = J.add(v_mw, 4.0)
									v_mn = J.add(v_mn, 1.0)
								v_pxx = J.add(v_cx, 26.0)
								game.f_fr(v_pxx, J.invoke(v_y, [20.0]), 2.0, 20.0, v_k2)
								v_pl = 0.0
								while J.lt(v_pl, 5.0):
									v_pa = J.add((-J.n(0.5)), (v_pl * 0.5))
									game.f_ln(J.add(v_pxx, 1.0), J.invoke(v_y, [20.0]), J.add(J.add(v_pxx, 1.0), floor((cos(v_pa) * 7.0) + 0.5)), ((J.invoke(v_y, [20.0]) - floor((sin(v_pa) * 5.0) + 0.5)) - 2.0), v_k2)
									v_pl = J.add(v_pl, 1.0)
							else:
								if J.eq(v_id, "manhattan"):
									v_boy = [30.0, 44.0, 34.0, 50.0, 32.0, 40.0]
									v_n2 = 0.0
									while J.lt(v_n2, J.getv(v_boy, "length")):
										v_bx = J.add((v_cx - 26.0), (v_n2 * 10.0))
										game.f_fr(v_bx, J.invoke(v_y, [J.getv(v_boy, v_n2)]), 9.0, J.getv(v_boy, v_n2), (v_k2 if J.truth(fmod(J.n(v_n2), J.n(2.0))) else v_k1))
										v_wy2 = 3.0
										while J.lt(v_wy2, (J.getv(v_boy, v_n2) - 2.0)):
											if J.gt(game.f_hash1(J.add((v_n2 * 3.3), v_wy2)), 0.42):
												game.f_px(J.add(v_bx, 2.0), J.invoke(v_y, [(J.getv(v_boy, v_n2) - v_wy2)]), v_isik)
											if J.gt(game.f_hash1(J.add((v_n2 * 7.1), v_wy2)), 0.52):
												game.f_px(J.add(v_bx, 6.0), J.invoke(v_y, [(J.getv(v_boy, v_n2) - v_wy2)]), "rgba(252,242,196,.45)")
											v_wy2 = J.add(v_wy2, 5.0)
										v_n2 = J.add(v_n2, 1.0)
									game.f_ln(J.add(v_cx, 4.0), J.invoke(v_y, [50.0]), J.add(v_cx, 4.0), J.invoke(v_y, [56.0]), v_k2)
								else:
									if J.eq(v_id, "anit"):
										game.f_fr((v_cx - 5.0), J.invoke(v_y, [46.0]), 11.0, 46.0, v_k2)
										game.f_fr((v_cx - 4.0), J.invoke(v_y, [46.0]), 9.0, 45.0, v_k1)
										game.f_vl((v_cx - 4.0), J.invoke(v_y, [45.0]), 44.0, "#9aa0a6")
										v_kt = 0.0
										while J.lt(v_kt, 5.0):
											game.f_hl((v_cx - 4.0), J.invoke(v_y, [(40.0 - (v_kt * 8.0))]), 9.0, v_k2)
											v_kt = J.add(v_kt, 1.0)
										game.f_fr((v_cx - 1.0), J.invoke(v_y, [52.0]), 3.0, 6.0, "#b83228")
										game.f_fr((v_cx - 4.0), J.invoke(v_y, [50.0]), 9.0, 3.0, "#b83228")
										game.f_px((v_cx - 5.0), J.invoke(v_y, [49.0]), "#8e2318")
										game.f_px(J.add(v_cx, 5.0), J.invoke(v_y, [49.0]), "#8e2318")
										game.f_px(v_cx, J.invoke(v_y, [53.0]), "#e2604f")
										v_bd = (-J.n(1.0))
										while J.le(v_bd, 1.0):
											v_bxx = J.add(v_cx, (v_bd * 12.0))
											game.f_vl(v_bxx, J.invoke(v_y, [34.0]), 34.0, v_k2)
											game.f_fr(((v_bxx - 7.0) if J.lt(v_bd, 0.0) else J.add(v_bxx, 1.0)), J.invoke(v_y, [34.0]), 7.0, 5.0, "#b83228")
											game.f_px(((v_bxx - 7.0) if J.lt(v_bd, 0.0) else J.add(v_bxx, 7.0)), J.invoke(v_y, [32.0]), "#8e2318")
											v_bd = J.add(v_bd, 2.0)
	return null

func _closure_79(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_h: Variant = null
	v_h = J.arg(_args, 0)
	return (_captures["328:taban"][0] - v_h)
	return null

