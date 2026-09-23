# Pedestrian draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:1349
func f_pedKimlik(p_k: Variant = null) -> Variant:
	var _cells: Dictionary = {"k": [p_k]}
	var v_h: Variant = null
	var v_GOM: Variant = null
	v_h = game.pedestrian_draw._closure_55.bind({"203:k": _cells["k"]})
	v_GOM = (game.j_PED_SHIRT_BETON if J.truth(game.traffic_system.f_betonSehir()) else game.j_PED_SHIRT)
	return {"shirt": J.getv(v_GOM, fmod(J.n(_cells["k"][0]), J.n(J.getv(v_GOM, "length")))), "pant": J.getv(game.j_PED_PANT, fmod(J.n((_cells["k"][0] * 3.0)), J.n(J.getv(game.j_PED_PANT, "length")))), "skin": J.getv(game.j_PED_SKIN, fmod(J.n((_cells["k"][0] * 5.0)), J.n(J.getv(game.j_PED_SKIN, "length")))), "hair": J.getv(game.j_PED_HAIR, fmod(J.n((_cells["k"][0] * 2.0)), J.n(J.getv(game.j_PED_HAIR, "length")))), "boy": ((-J.n(2.0)) if J.lt(J.invoke(v_h, [1.0]), 0.22) else (1.0 if J.gt(J.invoke(v_h, [1.0]), 0.82) else 0.0)), "genis": (1.0 if J.gt(J.invoke(v_h, [2.0]), 0.74) else 0.0), "sac": floor((J.invoke(v_h, [3.0]) * 4.0)), "esya": floor((J.invoke(v_h, [4.0]) * 5.0)), "sapka": J.gt(J.invoke(v_h, [5.0]), 0.8), "ceket": J.gt(J.invoke(v_h, [6.0]), 0.62), "tempo": J.add(5.6, (J.invoke(v_h, [7.0]) * 2.8))}
	return null

# art.js:1367
func f_drawPed(p_x: Variant = null, p_y: Variant = null, p_k: Variant = null, p_dir: Variant = null, p_t: Variant = null, p_sc: Variant = null, p_umbrella: Variant = null) -> Variant:
	# REMAKE kancasi
	if game.f_hdYaya(p_x, p_y, p_k, p_dir, p_t, p_sc, p_umbrella): return null
	var v_P0: Variant = null
	var v_shirt: Variant = null
	var v_pant: Variant = null
	var v_skin: Variant = null
	var v_hair: Variant = null
	var v_boy: Variant = null
	var v_gw2: Variant = null
	var v_ph: Variant = null
	var v_FR: Variant = null
	var v_fx0: Variant = null
	var v_bx0: Variant = null
	var v_fl: Variant = null
	var v_bl: Variant = null
	var v_by: Variant = null
	var v_arm: Variant = null
	var v_yy: Variant = null
	var v_gx0: Variant = null
	var v_hy: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_k: Variant = p_k
	var v_dir: Variant = p_dir
	var v_t: Variant = p_t
	var v_sc: Variant = p_sc
	var v_umbrella: Variant = p_umbrella
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_P0 = game.pedestrian_draw.f_pedKimlik(v_k)
	v_shirt = J.getv(v_P0, "shirt")
	v_pant = J.getv(v_P0, "pant")
	v_skin = J.getv(v_P0, "skin")
	v_hair = J.getv(v_P0, "hair")
	v_boy = J.getv(v_P0, "boy")
	v_gw2 = J.add(4.0, J.getv(v_P0, "genis"))
	v_ph = floor(fmod(J.n(J.add((v_t * J.getv(v_P0, "tempo")), (v_k * 1.7))), J.n(8.0)))
	v_FR = J.getv([[3.0, (-J.n(3.0)), 4.0, 4.0, 0.0, 2.0], [2.0, (-J.n(2.0)), 4.0, 4.0, (-J.n(1.0)), 1.0], [0.0, 0.0, 5.0, 4.0, (-J.n(1.0)), 0.0], [(-J.n(2.0)), 2.0, 4.0, 4.0, (-J.n(1.0)), (-J.n(1.0))], [(-J.n(3.0)), 3.0, 4.0, 4.0, 0.0, (-J.n(2.0))], [(-J.n(2.0)), 2.0, 4.0, 4.0, (-J.n(1.0)), (-J.n(1.0))], [0.0, 0.0, 4.0, 5.0, (-J.n(1.0)), 0.0], [2.0, (-J.n(2.0)), 4.0, 4.0, (-J.n(1.0)), 1.0]], v_ph)
	v_fx0 = J.getv(v_FR, 0.0)
	v_bx0 = J.getv(v_FR, 1.0)
	v_fl = J.getv(v_FR, 2.0)
	v_bl = J.getv(v_FR, 3.0)
	v_by = J.add(J.getv(v_FR, 4.0), v_boy)
	v_arm = J.getv(v_FR, 5.0)
	v_yy = J.add(v_y, v_by)
	J.setv(game.j_ctx, "globalAlpha", 0.24)
	game.f_ell(v_x, v_y, J.add(3.0, J.getv(v_P0, "genis")), 1.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr((J.add(v_x, v_bx0) - 1.0), (v_yy - 4.0), 2.0, v_bl, game.character_draw.f_shadeCol(v_pant, 0.74))
	game.f_px(J.add((J.add(v_x, v_bx0) - 1.0), ((-J.n(1.0)) if J.lt(v_bx0, 0.0) else 1.0)), J.add((v_yy - 5.0), v_bl), "#241c16")
	game.f_fr((J.add(v_x, v_fx0) - 1.0), (v_yy - 4.0), 2.0, v_fl, v_pant)
	game.f_px(J.add((J.add(v_x, v_fx0) - 1.0), (1.0 if J.gt(v_fx0, 0.0) else (-J.n(1.0)))), J.add((v_yy - 5.0), v_fl), "#1a1410")
	v_gx0 = (v_x - floor((float(v_gw2) / float(2.0))))
	game.f_fr(v_gx0, (v_yy - 8.0), J.add(v_gw2, 1.0), 5.0, game.character_draw.f_shadeCol(v_shirt, 0.76))
	game.f_fr(v_gx0, (v_yy - 8.0), v_gw2, 4.0, v_shirt)
	game.f_hl(v_gx0, (v_yy - 8.0), v_gw2, game.character_draw.f_shadeCol(v_shirt, 1.4))
	if J.truth(J.getv(v_P0, "ceket")):
		game.f_vl(v_gx0, (v_yy - 8.0), 5.0, game.character_draw.f_shadeCol(v_shirt, 0.6))
		game.f_vl((J.add(v_gx0, v_gw2) - 1.0), (v_yy - 8.0), 5.0, game.character_draw.f_shadeCol(v_shirt, 0.6))
		game.f_px(v_x, (v_yy - 7.0), game.character_draw.f_shadeCol(v_shirt, 1.6))
	game.f_fr((v_gx0 - 1.0), ((v_yy - 7.0) - v_arm), 1.0, 4.0, game.character_draw.f_shadeCol(v_shirt, 0.78))
	game.f_px((v_gx0 - 1.0), ((v_yy - 3.0) - v_arm), v_skin)
	game.f_fr(J.add(v_gx0, v_gw2), J.add((v_yy - 7.0), v_arm), 1.0, 4.0, game.character_draw.f_shadeCol(v_shirt, 0.94))
	game.f_px(J.add(v_gx0, v_gw2), J.add((v_yy - 3.0), v_arm), v_skin)
	if J.eq(J.getv(v_P0, "esya"), 1.0):
		game.f_fr(J.add(v_gx0, v_gw2), J.add((v_yy - 2.0), v_arm), 2.0, 3.0, "#7a4a2a")
		game.f_px(J.add(v_gx0, v_gw2), J.add((v_yy - 2.0), v_arm), "#a8703a")
	else:
		if J.eq(J.getv(v_P0, "esya"), 2.0):
			game.f_fr((v_gx0 - (1.0 if J.gt(v_dir, 0.0) else (-J.n(v_gw2)))), (v_yy - 7.0), 2.0, 5.0, "#3f5a7a")
			game.f_px((v_gx0 - (1.0 if J.gt(v_dir, 0.0) else (-J.n(v_gw2)))), (v_yy - 7.0), "#5a7a9a")
		else:
			if J.eq(J.getv(v_P0, "esya"), 3.0):
				game.f_fr(J.add(v_gx0, v_gw2), J.add((v_yy - 2.0), v_arm), 2.0, 3.0, "#dfe6ea")
				game.f_hl(J.add(v_gx0, v_gw2), J.add((v_yy - 2.0), v_arm), 2.0, "#ffffff")
			else:
				if J.eq(J.getv(v_P0, "esya"), 4.0):
					game.f_fr(J.add(v_gx0, v_gw2), J.add((v_yy - 3.0), v_arm), 2.0, 2.0, "#e8e2d0")
					game.f_px(J.add(v_gx0, v_gw2), J.add((v_yy - 4.0), v_arm), "#a83a2a")
	v_hy = (v_yy - 11.0)
	game.f_fr((v_x - 1.0), v_hy, 3.0, 3.0, v_skin)
	game.f_px((v_x - 2.0), J.add(v_hy, 1.0), v_skin)
	game.f_px(J.add(v_x, 2.0), J.add(v_hy, 1.0), v_skin)
	if J.eq(J.getv(v_P0, "sac"), 0.0):
		game.f_fr((v_x - 2.0), (v_hy - 1.0), 5.0, 1.0, v_hair)
		game.f_px((v_x - 2.0), v_hy, v_hair)
		game.f_px(J.add(v_x, 2.0), v_hy, v_hair)
	else:
		if J.eq(J.getv(v_P0, "sac"), 1.0):
			game.f_fr((v_x - 2.0), (v_hy - 1.0), 5.0, 1.0, v_hair)
			game.f_vl((v_x - 2.0), v_hy, 4.0, v_hair)
			game.f_vl(J.add(v_x, 2.0), v_hy, 4.0, v_hair)
		else:
			if J.eq(J.getv(v_P0, "sac"), 2.0):
				game.f_fr((v_x - 2.0), (v_hy - 1.0), 5.0, 1.0, v_hair)
				game.f_px((v_x - 2.0), v_hy, v_hair)
				game.f_px(J.add(v_x, 2.0), v_hy, v_hair)
				game.f_px(J.add(v_x, ((-J.n(3.0)) if J.gt(v_dir, 0.0) else 3.0)), (v_hy - 1.0), v_hair)
				game.f_px(J.add(v_x, ((-J.n(3.0)) if J.gt(v_dir, 0.0) else 3.0)), v_hy, v_hair)
			else:
				game.f_px((v_x - 2.0), v_hy, v_hair)
				game.f_px(J.add(v_x, 2.0), v_hy, v_hair)
	if J.truth(J.getv(v_P0, "sapka")):
		game.f_fr((v_x - 2.0), (v_hy - 2.0), 5.0, 2.0, game.character_draw.f_shadeCol(v_shirt, 0.55))
		game.f_fr(J.add((v_x - 3.0), (2.0 if J.gt(v_dir, 0.0) else 0.0)), (v_hy - 1.0), 3.0, 1.0, game.character_draw.f_shadeCol(v_shirt, 0.45))
	game.f_px(J.add((v_x - 1.0), (1.0 if J.gt(v_dir, 0.0) else 0.0)), J.add(v_hy, 1.0), "#2b2018")
	game.f_px(J.add(J.add(v_x, 1.0), (1.0 if J.gt(v_dir, 0.0) else 0.0)), J.add(v_hy, 1.0), "#2b2018")
	if J.truth(v_umbrella):
		game.f_ell(v_x, J.add((v_yy - 15.0), v_boy), 6.0, 2.0, "#2f4f6a")
		game.f_ell(v_x, J.add((v_yy - 16.0), v_boy), 6.0, 2.0, J.getv(game.j_PED_SHIRT, fmod(J.n((v_k * 4.0)), J.n(J.getv(game.j_PED_SHIRT, "length")))))
		game.f_vl(v_x, J.add((v_yy - 15.0), v_boy), 5.0, "#5a4a32")
		game.f_px((v_x - 5.0), J.add((v_yy - 14.0), v_boy), "#2f4f6a")
		game.f_px(J.add(v_x, 5.0), J.add((v_yy - 14.0), v_boy), "#2f4f6a")
	return null

# art.js:1714
func f_drawGozcu(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_bakiyor: Variant = null, p_sorgu: Variant = null) -> Variant:
	var v_PALTO: Variant = null
	var v_PALTO2: Variant = null
	var v_ISIK: Variant = null
	var v_TEN: Variant = null
	var v_BANT: Variant = null
	var v_ROZET: Variant = null
	var v_cephe: Variant = null
	var v_yon: Variant = null
	var v_ph: Variant = null
	var v_FRG: Variant = null
	var v_gw2: Variant = null
	var v_gx2: Variant = null
	var v_gy: Variant = null
	var v_ka: Variant = null
	var v_hy: Variant = null
	var v_uy: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_bakiyor: Variant = p_bakiyor
	var v_sorgu: Variant = p_sorgu
	# REMAKE kancasi
	if game.f_hdGozcu(p_x, p_y, p_t, p_bakiyor, p_sorgu): return null
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_PALTO = "#23262c"
	v_PALTO2 = "#191c21"
	v_ISIK = "#33373f"
	v_TEN = "#c99a66"
	v_BANT = "#8e1c14"
	v_ROZET = "#c9a23a"
	v_cephe = (v_bakiyor if J.truth(v_bakiyor) else v_sorgu)
	v_yon = ((-J.n(1.0)) if (J.truth(J.getv(game.j_G, "gozcu")) and J.lt(J.getv(J.getv(game.j_G, "gozcu"), "dir"), 0.0)) else 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.26)
	game.f_ell(v_x, v_y, (4.0 if J.truth(v_cephe) else 3.0), 1.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(v_cephe):
		game.f_fr((v_x - 2.0), (v_y - 4.0), 2.0, 4.0, v_PALTO2)
		game.f_fr(J.add(v_x, 1.0), (v_y - 4.0), 2.0, 4.0, v_PALTO2)
		game.f_px((v_x - 3.0), (v_y - 1.0), "#0b0d10")
		game.f_px(J.add(v_x, 3.0), (v_y - 1.0), "#0b0d10")
	else:
		v_ph = floor(fmod(J.n((v_t * 6.0)), J.n(8.0)))
		v_FRG = J.getv([[2.0, (-J.n(2.0))], [1.0, (-J.n(1.0))], [0.0, 0.0], [(-J.n(1.0)), 1.0], [(-J.n(2.0)), 2.0], [(-J.n(1.0)), 1.0], [0.0, 0.0], [1.0, (-J.n(1.0))]], v_ph)
		game.f_fr((J.add(v_x, J.getv(v_FRG, 1.0)) - 1.0), (v_y - 4.0), 2.0, 4.0, v_PALTO2)
		game.f_fr((J.add(v_x, J.getv(v_FRG, 0.0)) - 1.0), (v_y - 4.0), 2.0, 4.0, v_ISIK)
		game.f_px(J.add((J.add(v_x, J.getv(v_FRG, 1.0)) - 1.0), ((-J.n(1.0)) if J.lt(J.getv(v_FRG, 1.0), 0.0) else 1.0)), (v_y - 1.0), "#0b0d10")
		game.f_px(J.add((J.add(v_x, J.getv(v_FRG, 0.0)) - 1.0), (1.0 if J.gt(J.getv(v_FRG, 0.0), 0.0) else (-J.n(1.0)))), (v_y - 1.0), "#0b0d10")
	v_gw2 = (7.0 if J.truth(v_cephe) else 5.0)
	v_gx2 = (v_x - (3.0 if J.truth(v_cephe) else 2.0))
	v_gy = (v_y - 10.0)
	game.f_fr(v_gx2, v_gy, v_gw2, 6.0, v_PALTO)
	game.f_hl(v_gx2, v_gy, v_gw2, v_ISIK)
	game.f_fr(v_gx2, J.add(v_gy, 4.0), v_gw2, 1.0, "#0e1013")
	if J.truth(v_cephe):
		game.f_px(v_x, J.add(v_gy, 1.0), v_PALTO2)
		game.f_px(J.add(v_x, 1.0), J.add(v_gy, 4.0), v_ROZET)
		game.f_px(v_gx2, v_gy, v_ROZET)
		game.f_px((J.add(v_gx2, v_gw2) - 1.0), v_gy, v_ROZET)
	else:
		game.f_px(J.add(v_gx2, ((v_gw2 - 1.0) if J.gt(v_yon, 0.0) else 0.0)), J.add(v_gy, 1.0), v_PALTO2)
	if J.truth(v_bakiyor):
		game.f_px((v_gx2 - 1.0), J.add(v_gy, 2.0), v_PALTO2)
		game.f_px(J.add(v_gx2, v_gw2), J.add(v_gy, 2.0), v_PALTO2)
	else:
		if J.truth(v_sorgu):
			game.f_fr(J.add(v_x, 3.0), J.add(v_gy, 2.0), 3.0, 1.0, v_PALTO2)
			game.f_px(J.add(v_x, 6.0), J.add(v_gy, 2.0), v_TEN)
		else:
			v_ka = floor(sin((v_t * 6.0)) + 0.5)
			game.f_px(J.add(v_x, (2.0 if J.gt(v_yon, 0.0) else (-J.n(3.0)))), J.add(J.add(v_gy, 2.0), v_ka), v_PALTO2)
	v_hy = (v_y - 13.0)
	game.f_fr((v_x - 1.0), v_hy, 3.0, 3.0, v_TEN)
	if J.truth(v_cephe):
		game.f_px((v_x - 1.0), J.add(v_hy, 1.0), "#14161a")
		game.f_px(J.add(v_x, 1.0), J.add(v_hy, 1.0), "#14161a")
	else:
		game.f_px(J.add(v_x, (1.0 if J.gt(v_yon, 0.0) else (-J.n(1.0)))), J.add(v_hy, 1.0), "#14161a")
	game.f_fr((v_x - 2.0), (v_hy - 2.0), 5.0, 2.0, v_PALTO2)
	game.f_hl((v_x - 2.0), (v_hy - 2.0), 5.0, v_ISIK)
	game.f_fr((v_x - 2.0), v_hy, 5.0, 1.0, v_BANT)
	game.f_px(v_x, (v_hy - 1.0), v_ROZET)
	if J.truth(v_cephe):
		game.f_fr((v_x - 3.0), J.add(v_hy, 1.0), 7.0, 1.0, "#0b0d10")
	else:
		game.f_fr((J.add(v_x, 1.0) if J.gt(v_yon, 0.0) else (v_x - 3.0)), J.add(v_hy, 1.0), 3.0, 1.0, "#0b0d10")
	if J.truth(v_sorgu):
		v_uy = J.add((v_y - 22.0), floor(sin((v_t * 9.0)) + 0.5))
		game.f_fr(v_x, v_uy, 1.0, 3.0, "#e2483a")
		game.f_px(v_x, J.add(v_uy, 4.0), "#e2483a")
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_disc(v_x, J.add(v_uy, 2.0), 4.0, "#e2483a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if J.truth(v_bakiyor):
		J.setv(game.j_ctx, "globalAlpha", J.add(0.45, (0.45 * sin((v_t * 7.0)))))
		game.f_px(v_x, (v_hy - 1.0), "#fff3c0")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:1795
func f_drawAsker(p_x: Variant = null, p_y: Variant = null, p_t: Variant = null, p_dir: Variant = null, p_faz: Variant = null) -> Variant:
	var v_UNI: Variant = null
	var v_UNI2: Variant = null
	var v_MIG: Variant = null
	var v_TEN: Variant = null
	var v_yon: Variant = null
	var v_ph: Variant = null
	var v_FR: Variant = null
	var v_gy: Variant = null
	var v_ka: Variant = null
	var v_tx0: Variant = null
	var v_i: Variant = null
	var v_hy: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_t: Variant = p_t
	var v_dir: Variant = p_dir
	var v_faz: Variant = p_faz
	# REMAKE kancasi
	if game.f_hdAsker(p_x, p_y, p_t, p_dir, p_faz): return null
	v_x = floor(v_x + 0.5)
	v_y = floor(v_y + 0.5)
	v_UNI = "#4a5148"
	v_UNI2 = "#39403a"
	v_MIG = "#3a423c"
	v_TEN = "#c99a66"
	v_yon = (1.0 if J.gt(v_dir, 0.0) else (-J.n(1.0)))
	J.setv(game.j_ctx, "globalAlpha", 0.24)
	game.f_ell(v_x, v_y, 3.0, 1.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_ph = floor(fmod(J.n(J.add((v_t * 5.4), v_faz)), J.n(8.0)))
	v_FR = J.getv([[2.0, (-J.n(2.0))], [1.0, (-J.n(1.0))], [0.0, 0.0], [(-J.n(1.0)), 1.0], [(-J.n(2.0)), 2.0], [(-J.n(1.0)), 1.0], [0.0, 0.0], [1.0, (-J.n(1.0))]], v_ph)
	game.f_fr((J.add(v_x, J.getv(v_FR, 1.0)) - 1.0), (v_y - 4.0), 2.0, 4.0, v_UNI2)
	game.f_fr((J.add(v_x, J.getv(v_FR, 0.0)) - 1.0), (v_y - 4.0), 2.0, 4.0, v_UNI)
	game.f_px(J.add((J.add(v_x, J.getv(v_FR, 1.0)) - 1.0), ((-J.n(1.0)) if J.lt(J.getv(v_FR, 1.0), 0.0) else 1.0)), (v_y - 1.0), "#20241f")
	game.f_px(J.add((J.add(v_x, J.getv(v_FR, 0.0)) - 1.0), (1.0 if J.gt(J.getv(v_FR, 0.0), 0.0) else (-J.n(1.0)))), (v_y - 1.0), "#1a1e19")
	v_gy = (v_y - 9.0)
	game.f_fr((v_x - 2.0), v_gy, 5.0, 5.0, v_UNI)
	game.f_hl((v_x - 2.0), v_gy, 5.0, "#5c6459")
	game.f_fr((v_x - 2.0), J.add(v_gy, 3.0), 5.0, 1.0, "#20241f")
	v_ka = floor(sin(J.add((v_t * 5.4), v_faz)) + 0.5)
	game.f_fr(J.add(v_x, (3.0 if J.gt(v_yon, 0.0) else (-J.n(3.0)))), J.add(J.add(v_gy, 1.0), v_ka), 1.0, 3.0, v_UNI2)
	v_tx0 = (v_x - (v_yon * 2.0))
	v_i = 0.0
	while J.lt(v_i, 6.0):
		game.f_px(J.add(v_tx0, (v_yon * floor((v_i * 0.5) + 0.5))), J.add((v_gy - 2.0), v_i), "#2a2620")
		v_i = J.add(v_i, 1.0)
	v_hy = (v_y - 12.0)
	game.f_fr((v_x - 1.0), v_hy, 3.0, 3.0, v_TEN)
	game.f_px((v_x - 2.0), J.add(v_hy, 1.0), v_TEN)
	game.f_px(J.add(v_x, 2.0), J.add(v_hy, 1.0), v_TEN)
	game.f_px(J.add(v_x, (1.0 if J.gt(v_yon, 0.0) else (-J.n(1.0)))), J.add(v_hy, 1.0), "#14161a")
	game.f_fr((v_x - 2.0), (v_hy - 1.0), 5.0, 1.0, v_MIG)
	game.f_fr((v_x - 1.0), (v_hy - 2.0), 3.0, 1.0, v_MIG)
	game.f_px((v_x - (v_yon * 3.0)), v_hy, v_MIG)
	return null

func _closure_55(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_n: Variant = null
	v_n = J.arg(_args, 0)
	return game.f_hash1(J.add((_captures["203:k"][0] * 7.31), (v_n * 2.17)))
	return null

