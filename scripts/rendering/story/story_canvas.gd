# Story canvas. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# prologue.js:55
func f_pbx(p_x: Variant = null) -> Variant:
	var v_x: Variant = p_x
	return J.add(240.0, v_x)
	return null

# prologue.js:56
func f_pby(p_z: Variant = null) -> Variant:
	var v_z: Variant = p_z
	return (133.0 - v_z)
	return null

# prologue.js:57
func f_pb(p_x0: Variant = null, p_z0: Variant = null, p_x1: Variant = null, p_z1: Variant = null, p_c: Variant = null) -> Variant:
	var v_x0: Variant = p_x0
	var v_z0: Variant = p_z0
	var v_x1: Variant = p_x1
	var v_z1: Variant = p_z1
	var v_c: Variant = p_c
	game.f_fr(game.story_canvas.f_pbx(v_x0), game.story_canvas.f_pby(v_z1), (v_x1 - v_x0), (v_z1 - v_z0), v_c)
	return null

# prologue.js:58
func f_pbA(p_x0: Variant = null, p_z0: Variant = null, p_x1: Variant = null, p_z1: Variant = null, p_c: Variant = null, p_a: Variant = null) -> Variant:
	var v_x0: Variant = p_x0
	var v_z0: Variant = p_z0
	var v_x1: Variant = p_x1
	var v_z1: Variant = p_z1
	var v_c: Variant = p_c
	var v_a: Variant = p_a
	J.setv(game.j_ctx, "globalAlpha", v_a)
	game.f_fr(game.story_canvas.f_pbx(v_x0), game.story_canvas.f_pby(v_z1), (v_x1 - v_x0), (v_z1 - v_z0), v_c)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# prologue.js:61
func f_pbE(p_cx: Variant = null, p_cz: Variant = null, p_rx: Variant = null, p_rz: Variant = null, p_c: Variant = null) -> Variant:
	var v_cx: Variant = p_cx
	var v_cz: Variant = p_cz
	var v_rx: Variant = p_rx
	var v_rz: Variant = p_rz
	var v_c: Variant = p_c
	game.f_ell(game.story_canvas.f_pbx(v_cx), game.story_canvas.f_pby(v_cz), v_rx, v_rz, v_c)
	return null

# prologue.js:68
func f_proKat(p_ad: Variant = null, p_ciz: Variant = null) -> Variant:
	var v_c: Variant = null
	var v_eski: Variant = null
	var v_ad: Variant = p_ad
	var v_ciz: Variant = p_ciz
	v_c = J.getv(game.j_PRO_KAT, v_ad)
	if J.truth(v_c):
		return v_c
	v_c = Canvas.new()
	J.setv(v_c, "width", 400.0)
	J.setv(v_c, "height", 150.0)
	v_eski = game.j_ctx
	game.j_ctx = J.method(v_c, "getContext", ["2d"])
	J.setv(game.j_ctx, "imageSmoothingEnabled", false)
	J.method(game.j_ctx, "translate", [(-J.n(40.0)), (-J.n(44.0))])
	J.invoke(v_ciz, [])
	game.j_ctx = v_eski
	J.setv(game.j_PRO_KAT, v_ad, v_c)
	return v_c
	return null

# prologue.js:82
func f_proCiz(p_ad: Variant = null, p_ciz: Variant = null) -> Variant:
	var v_ad: Variant = p_ad
	var v_ciz: Variant = p_ciz
	J.method(game.j_ctx, "drawImage", [game.f_proKat(v_ad, v_ciz), 40.0, 44.0])
	return null

# prologue.js:85
func f_proBirds(p_t: Variant = null, p_gx: Variant = null, p_gy: Variant = null, p_gw: Variant = null, p_n: Variant = null, p_sp: Variant = null) -> Variant:
	var v_b: Variant = null
	var v_u: Variant = null
	var v_bx: Variant = null
	var v_by: Variant = null
	var v_f: Variant = null
	var v_t: Variant = p_t
	var v_gx: Variant = p_gx
	var v_gy: Variant = p_gy
	var v_gw: Variant = p_gw
	var v_n: Variant = p_n
	var v_sp: Variant = p_sp
	v_b = 0.0
	while J.lt(v_b, v_n):
		v_u = (fmod(J.n(J.add((v_t * v_sp), (v_b * 0.31))), J.n(1.25)) - 0.12)
		if (J.lt(v_u, 0.0) or J.gt(v_u, 1.0)):
			v_b = J.add(v_b, 1.0)
			continue
		v_bx = J.add((v_gx - 10.0), (v_u * J.add(v_gw, 20.0)))
		v_by = J.add(J.add(J.add(v_gy, 8.0), (v_b * 7.0)), (sin(J.add((v_t * 2.0), v_b)) * 3.0))
		v_f = (1.0 if J.gt(sin(J.add((v_t * 9.0), (v_b * 2.0))), 0.0) else 0.0)
		J.setv(game.j_ctx, "globalAlpha", 0.55)
		if J.truth(v_f):
			game.f_ln((v_bx - 3.0), v_by, v_bx, (v_by - 2.0), "#3a4a56")
			game.f_ln(v_bx, (v_by - 2.0), J.add(v_bx, 3.0), v_by, "#3a4a56")
		else:
			game.f_ln((v_bx - 3.0), (v_by - 1.0), v_bx, v_by, "#3a4a56")
			game.f_ln(v_bx, v_by, J.add(v_bx, 3.0), (v_by - 1.0), "#3a4a56")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		v_b = J.add(v_b, 1.0)
	return null

# prologue.js:107
func f_proSis(p_cx: Variant = null, p_z0: Variant = null, p_z1: Variant = null, p_r0: Variant = null, p_r1: Variant = null, p_t: Variant = null) -> Variant:
	var v_n: Variant = null
	var v_sx: Variant = null
	var v_sy: Variant = null
	var v_m: Variant = null
	var v_b: Variant = null
	var v_bant: Variant = null
	var v_son: Variant = null
	var v_v: Variant = null
	var v_fi: Variant = null
	var v_f0: Variant = null
	var v_pr: Variant = null
	var v_rr: Variant = null
	var v_w2: Variant = null
	var v_zz: Variant = null
	var v_lay: Variant = null
	var v_dilim: Variant = null
	var v_xa: Variant = null
	var v_xb: Variant = null
	var v_dk: Variant = null
	var v_v3: Variant = null
	var v_w3: Variant = null
	var v_cx: Variant = p_cx
	var v_z0: Variant = p_z0
	var v_z1: Variant = p_z1
	var v_r0: Variant = p_r0
	var v_r1: Variant = p_r1
	var v_t: Variant = p_t
	# REMAKE kancasi
	if game.f_hdProSis(p_cx, p_z0, p_z1, p_r0, p_r1, p_t): return null
	v_n = (v_z1 - v_z0)
	v_sx = game.story_canvas.f_pbx(v_cx)
	v_sy = game.story_canvas.f_pby(v_z1)
	v_bant = [[(-J.n(1.0)), (-J.n(0.58)), 0.6], [(-J.n(0.58)), (-J.n(0.18)), 0.82], [(-J.n(0.18)), 0.24, 1.08], [0.24, 0.62, 1.3], [0.62, 1.0, 0.88]]
	v_son = (J.getv(game.j_PRO_SIS_PROFIL, "length") - 1.0)
	v_m = 0.0
	while J.lt(v_m, v_n):
		v_v = (float(v_m) / float((v_n - 1.0)))
		v_fi = (v_v * v_son)
		v_f0 = min(v_son, (int(J.n(v_fi)) | int(J.n(0.0))))
		v_pr = J.add(J.getv(game.j_PRO_SIS_PROFIL, v_f0), ((J.getv(game.j_PRO_SIS_PROFIL, min(J.add(v_f0, 1.0), v_son)) - J.getv(game.j_PRO_SIS_PROFIL, v_f0)) * (v_fi - v_f0)))
		v_rr = (J.add(v_r1, ((v_r0 - v_r1) * v_pr)) * J.add(1.0, (0.035 * sin(J.add((v_v * 11.0), (v_t * 0.8))))))
		v_w2 = max(1.0, floor(v_rr + 0.5))
		v_zz = (v_z1 - v_m)
		v_lay = sin(J.add((v_zz * 0.62), (sin((v_zz * 0.19)) * 1.6)))
		v_dilim = ((-J.n(0.16)) if J.lt(fmod(J.n(J.add(fmod(J.n(v_zz), J.n(7.0)), 7.0)), J.n(7.0)), 1.0) else 0.0)
		game.f_fr(((v_sx - v_w2) - 1.0), J.add(v_sy, v_m), J.add((v_w2 * 2.0), 2.0), 1.0, "#40200a")
		v_b = 0.0
		while J.lt(v_b, 5.0):
			v_xa = floor(J.add(v_sx, (J.getv(J.getv(v_bant, v_b), 0.0) * v_w2)) + 0.5)
			v_xb = floor(J.add(v_sx, (J.getv(J.getv(v_bant, v_b), 1.0) * v_w2)) + 0.5)
			if J.gt(v_xb, v_xa):
				game.f_fr(v_xa, J.add(v_sy, v_m), (v_xb - v_xa), 1.0, game.f_meatCol(0.85, J.add(J.add(J.getv(J.getv(v_bant, v_b), 2.0), (v_lay * 0.1)), v_dilim)))
			v_b = J.add(v_b, 1.0)
		game.f_fr((J.add(v_sx, v_w2) - 2.0), J.add(v_sy, v_m), 2.0, 1.0, game.f_meatCol(0.95, J.add(0.46, (v_lay * 0.06))))
		v_m = J.add(v_m, 1.0)
	v_dk = (sin((v_t * 1.4)) * 0.72)
	J.setv(game.j_ctx, "globalAlpha", 0.34)
	v_m = 2.0
	while J.lt(v_m, (v_n - 2.0)):
		v_v3 = (1.0 - (float(v_m) / float((v_n - 1.0))))
		v_w3 = max(1.0, floor(J.add(v_r1, ((v_r0 - v_r1) * v_v3)) + 0.5))
		game.f_px(J.add(v_sx, floor((v_dk * v_w3) + 0.5)), J.add(v_sy, v_m), "#5a3418")
		v_m = J.add(v_m, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# prologue.js:144
func f_proKisi(p_bx: Variant = null, p_ust: Variant = null, p_alt: Variant = null, p_ten: Variant = null, p_sac: Variant = null, p_faz: Variant = null, p_yuru: Variant = null) -> Variant:
	var v_bacak: Variant = null
	var v_zip: Variant = null
	var v_bx: Variant = p_bx
	var v_ust: Variant = p_ust
	var v_alt: Variant = p_alt
	var v_ten: Variant = p_ten
	var v_sac: Variant = p_sac
	var v_faz: Variant = p_faz
	var v_yuru: Variant = p_yuru
	v_bacak = (floor((sin(v_faz) * 3.0) + 0.5) if J.truth(v_yuru) else 0.0)
	v_zip = ((1.0 if J.gt(sin((v_faz * 2.0)), 0.0) else 0.0) if J.truth(v_yuru) else 0.0)
	game.story_canvas.f_pbA((v_bx - 9.0), (-J.n(41.0)), J.add(v_bx, 11.0), (-J.n(38.0)), "#000000", 0.35)
	game.story_canvas.f_pb(((v_bx - 6.0) - v_bacak), (-J.n(38.0)), ((v_bx - 1.0) - v_bacak), (-J.n(24.0)), v_alt)
	game.story_canvas.f_pb(J.add(J.add(v_bx, 1.0), v_bacak), (-J.n(38.0)), J.add(J.add(v_bx, 6.0), v_bacak), (-J.n(24.0)), v_alt)
	game.story_canvas.f_pb((v_bx - 7.0), J.add((-J.n(26.0)), v_zip), J.add(v_bx, 7.0), J.add((-J.n(22.0)), v_zip), v_alt)
	game.story_canvas.f_pb((v_bx - 7.0), J.add((-J.n(22.0)), v_zip), J.add(v_bx, 7.0), J.add((-J.n(6.0)), v_zip), v_ust)
	game.story_canvas.f_pb(J.add(v_bx, 6.0), J.add((-J.n(20.0)), v_zip), J.add(v_bx, 9.0), J.add((-J.n(10.0)), v_zip), v_ust)
	game.story_canvas.f_pb((v_bx - 5.0), J.add((-J.n(6.0)), v_zip), J.add(v_bx, 5.0), J.add(2.0, v_zip), v_ten)
	game.story_canvas.f_pb((v_bx - 6.0), J.add(1.0, v_zip), J.add(v_bx, 6.0), J.add(5.0, v_zip), v_sac)
	return null

