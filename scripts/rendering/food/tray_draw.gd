# Tray draw. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# art.js:2982
func f_trayInnerShade(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	J.setv(game.j_ctx, "globalAlpha", 0.16)
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 2.0), (v_w - 4.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 0.09)
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 4.0), (v_w - 4.0), 2.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 0.1)
	game.f_fr(J.add(v_x, 2.0), J.add(v_y, 2.0), 2.0, (v_h - 9.0), "#000")
	game.f_fr((J.add(v_x, v_w) - 4.0), J.add(v_y, 2.0), 2.0, (v_h - 9.0), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_hl(J.add(v_x, 3.0), (J.add(v_y, v_h) - 7.0), (v_w - 6.0), "#ffffff")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:2993
func f_trayFlash(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_fx: Variant = null) -> Variant:
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_fx: Variant = p_fx
	if J.le(v_fx, 0.0):
		return null
	J.setv(game.j_ctx, "globalAlpha", (sin((v_fx * J.getv({"PI": PI}, "PI"))) * 0.45))
	game.f_rrectOut((v_x - 1.0), (v_y - 1.0), J.add(v_w, 2.0), J.add(v_h, 2.0), 2.0, "#ffffff")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:3004
func f_trayFloor(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_ax: Variant = null
	var v_aw: Variant = null
	var v_ay: Variant = null
	var v_ah: Variant = null
	var v_duvar: Variant = null
	var v_yan: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	v_ax = J.add(v_x, 2.0)
	v_aw = (v_w - 4.0)
	v_ay = J.add(v_y, 2.0)
	v_ah = (v_h - 4.0)
	v_duvar = 4.0
	v_yan = 2.0
	return {"ax": v_ax, "aw": v_aw, "ay": v_ay, "ah": v_ah, "ix": J.add(v_ax, v_yan), "iw": (v_aw - (v_yan * 2.0)), "arka": J.add(v_ay, v_duvar), "zemin": J.add(v_ay, v_duvar), "on": (J.add(v_ay, v_ah) - 1.0), "duvar": v_duvar, "yan": v_yan}
	return null

# art.js:3020
func f_trayBase(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_d: Variant = null
	var v_u: Variant = null
	var v_dh: Variant = null
	var v_r: Variant = null
	var v_v: Variant = null
	var v_gen: Variant = null
	var v_yy: Variant = null
	var v_a: Variant = null
	var v_b: Variant = null
	var v_z: Variant = null
	var v_w2: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	v_F = game.tray_draw.f_trayFloor(v_x, v_y, v_w, v_h)
	game.f_fr(v_x, v_y, v_w, v_h, "#aeb6be")
	game.f_hl(v_x, v_y, v_w, "#f4f8fb")
	game.f_hl(J.add(v_x, 1.0), J.add(v_y, 1.0), (v_w - 2.0), "#d2d9e0")
	game.f_vl(v_x, v_y, v_h, "#dfe5eb")
	game.f_vl((J.add(v_x, v_w) - 1.0), v_y, v_h, "#868e96")
	game.f_hl(v_x, (J.add(v_y, v_h) - 1.0), v_w, "#666e76")
	game.f_hl(J.add(v_x, 1.0), (J.add(v_y, v_h) - 2.0), (v_w - 2.0), "#9aa2aa")
	game.f_px(v_x, v_y, "#c4ccd3")
	game.f_px((J.add(v_x, v_w) - 1.0), v_y, "#9ba3ab")
	game.f_px(v_x, (J.add(v_y, v_h) - 1.0), "#7f878f")
	game.f_px((J.add(v_x, v_w) - 1.0), (J.add(v_y, v_h) - 1.0), "#727a82")
	v_d = 0.0
	while J.lt(v_d, J.getv(v_F, "duvar")):
		v_u = (float(v_d) / float(max(1.0, (J.getv(v_F, "duvar") - 1.0))))
		game.f_fr(J.getv(v_F, "ax"), J.add(J.getv(v_F, "ay"), v_d), J.getv(v_F, "aw"), 1.0, game.street_background.f_mixHex("#79828b", "#a9b2ba", v_u))
		v_d = J.add(v_d, 1.0)
	game.f_hl(J.getv(v_F, "ax"), J.getv(v_F, "ay"), J.getv(v_F, "aw"), "#5e666e")
	J.setv(game.j_ctx, "globalAlpha", 0.35)
	game.f_hl(J.getv(v_F, "ix"), J.getv(v_F, "arka"), J.getv(v_F, "iw"), "#4e565e")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	v_dh = (J.getv(v_F, "on") - J.getv(v_F, "arka"))
	v_r = 0.0
	while J.lt(v_r, v_dh):
		v_v = (float(v_r) / float(max(1.0, (v_dh - 1.0))))
		v_gen = max(1.0, floor((J.getv(v_F, "yan") * (1.0 - (v_v * 0.45))) + 0.5))
		v_yy = J.add(J.getv(v_F, "arka"), v_r)
		v_a = 0.0
		while J.lt(v_a, v_gen):
			game.f_px(J.add(J.getv(v_F, "ax"), v_a), v_yy, game.street_background.f_mixHex("#9aa3ab", "#c3ccd3", (float(v_a) / float(max(1.0, (v_gen - 1.0))))))
			v_a = J.add(v_a, 1.0)
		v_b = 0.0
		while J.lt(v_b, v_gen):
			game.f_px(((J.add(J.getv(v_F, "ax"), J.getv(v_F, "aw")) - 1.0) - v_b), v_yy, game.street_background.f_mixHex("#79828b", "#5e666e", (float(v_b) / float(max(1.0, (v_gen - 1.0))))))
			v_b = J.add(v_b, 1.0)
		v_r = J.add(v_r, 1.0)
	v_z = 0.0
	while J.lt(v_z, v_dh):
		v_w2 = (float(v_z) / float(max(1.0, (v_dh - 1.0))))
		game.f_fr(J.getv(v_F, "ix"), J.add(J.getv(v_F, "arka"), v_z), J.getv(v_F, "iw"), 1.0, game.street_background.f_mixHex("#8b949c", "#a6afb7", v_w2))
		v_z = J.add(v_z, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.24)
	game.f_fr(J.add(J.getv(v_F, "ix"), 2.0), J.add(J.getv(v_F, "arka"), floor((v_dh * 0.42) + 0.5)), (J.getv(v_F, "iw") - 4.0), 2.0, "#e6ecf1")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_fr(J.getv(v_F, "ix"), J.add(J.getv(v_F, "arka"), 1.0), J.getv(v_F, "iw"), 2.0, "#3c434a")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_hl(J.getv(v_F, "ax"), J.getv(v_F, "on"), J.getv(v_F, "aw"), "#cdd5dc")
	J.setv(game.j_ctx, "globalAlpha", 0.5)
	game.f_hl(J.getv(v_F, "ax"), J.add(J.getv(v_F, "on"), 1.0), J.getv(v_F, "aw"), "#8f979f")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	return null

# art.js:3092
func f_drawFill(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_lvl: Variant = null, p_seed: Variant = null, p_item: Variant = null) -> Variant:
	var _v: Dictionary = {"q": null, "key": null, "e": null, "oc": null, "eskiCtx": null, "ty": null, "x": p_x, "y": p_y, "w": p_w, "h": p_h, "lvl": p_lvl, "seed": p_seed, "item": p_item}
	_v["lvl"] = game.math_utils.f_clamp(_v["lvl"], 0.0, 1.0)
	_v["q"] = floor((_v["lvl"] * 40.0) + 0.5)
	_v["key"] = J.add(J.add(J.add(J.add(J.add(J.add(J.add(J.add(_v["w"], ","), _v["h"]), ","), _v["q"]), ","), _v["seed"]), ","), (J.getv(_v["item"], "name") if J.truth(J.getv(_v["item"], "name")) else "?"))
	_v["e"] = J.getv(game.j_FILLCACHE, _v["key"])
	if (not J.truth(_v["e"])):
		if J.gt(game.j_FILLN, 400.0):
			game.j_FILLCACHE = {}
			game.j_FILLN = 0.0
		_v["oc"] = Canvas.new()
		J.setv(_v["oc"], "width", J.add(_v["w"], 4.0))
		J.setv(_v["oc"], "height", J.add(_v["h"], 10.0))
		_v["eskiCtx"] = game.j_ctx
		game.j_ctx = J.method(_v["oc"], "getContext", ["2d"])
		J.setv(game.j_ctx, "imageSmoothingEnabled", false)
		_v["ty"] = game.tray_draw.f_fillPaint(2.0, 6.0, _v["w"], _v["h"], (float(_v["q"]) / float(40.0)), _v["seed"], _v["item"])
		game.j_ctx = _v["eskiCtx"]
		_v["e"] = J.setv(game.j_FILLCACHE, _v["key"], {"c": _v["oc"], "ty": (_v["ty"] - 6.0)})
		game.j_FILLN = J.add(game.j_FILLN, 1.0)
	J.method(game.j_ctx, "drawImage", [J.getv(_v["e"], "c"), ((int(J.n(_v["x"])) | int(J.n(0.0))) - 2.0), ((int(J.n(_v["y"])) | int(J.n(0.0))) - 6.0)])
	return J.add((int(J.n(_v["y"])) | int(J.n(0.0))), J.getv(_v["e"], "ty"))
	return null

# art.js:3113
func f_fillPaint(p_x: Variant = null, p_y: Variant = null, p_w: Variant = null, p_h: Variant = null, p_lvl: Variant = null, p_seed: Variant = null, p_item: Variant = null) -> Variant:
	var v_F: Variant = null
	var v_zh: Variant = null
	var v_kaplama: Variant = null
	var v_arkaSinir: Variant = null
	var v_kabarma: Variant = null
	var v_tepe: Variant = null
	var v_derinlik: Variant = null
	var v_sira: Variant = null
	var v_sutun: Variant = null
	var v_gecisSayi: Variant = null
	var v_seyreklik: Variant = null
	var v_gecis: Variant = null
	var v_r: Variant = null
	var v_v: Variant = null
	var v_ry: Variant = null
	var v_sh: Variant = null
	var v_daralt: Variant = null
	var v_sx0: Variant = null
	var v_sw: Variant = null
	var v_c: Variant = null
	var v_u: Variant = null
	var v_tohum: Variant = null
	var v_kubbe: Variant = null
	var v_jx: Variant = null
	var v_jy: Variant = null
	var v_px0: Variant = null
	var v_py0: Variant = null
	var v_x: Variant = p_x
	var v_y: Variant = p_y
	var v_w: Variant = p_w
	var v_h: Variant = p_h
	var v_lvl: Variant = p_lvl
	var v_seed: Variant = p_seed
	var v_item: Variant = p_item
	v_F = game.tray_draw.f_trayFloor(v_x, v_y, v_w, v_h)
	v_zh = (J.getv(v_F, "on") - J.getv(v_F, "zemin"))
	if J.lt(v_zh, 4.0):
		v_zh = 4.0
	v_kaplama = J.add(0.1, (0.9 * v_lvl))
	v_arkaSinir = (J.getv(v_F, "on") - floor((v_zh * v_kaplama) + 0.5))
	v_kabarma = floor((v_lvl * 7.0) + 0.5)
	v_tepe = max((J.getv(v_F, "arka") - v_kabarma), J.add(v_y, 1.0))
	if J.lt(v_arkaSinir, v_tepe):
		v_arkaSinir = v_tepe
	J.method(game.j_ctx, "save", [])
	J.method(game.j_ctx, "beginPath", [])
	J.method(game.j_ctx, "rect", [(J.getv(v_F, "ix") - 1.0), (v_y - 4.0), J.add(J.getv(v_F, "iw"), 2.0), (J.add(J.getv(v_F, "on"), 2.0) - (v_y - 4.0))])
	J.method(game.j_ctx, "clip", [])
	v_derinlik = (J.getv(v_F, "on") - v_arkaSinir)
	v_sira = max(3.0, floor((float(v_derinlik) / float(1.9)) + 0.5))
	v_sutun = max(4.0, floor((float(J.getv(v_F, "iw")) / float(4.4)) + 0.5))
	v_gecisSayi = (2.0 if J.gt(v_lvl, 0.45) else 1.0)
	v_seyreklik = (J.add(0.35, (v_lvl * 1.4)) if J.lt(v_lvl, 0.45) else 1.0)
	v_gecis = 0.0
	while J.lt(v_gecis, v_gecisSayi):
		v_r = 0.0
		while J.lt(v_r, v_sira):
			v_v = (1.0 if J.eq(v_sira, 1.0) else (float(v_r) / float((v_sira - 1.0))))
			v_ry = floor(J.add(v_arkaSinir, (v_v * v_derinlik)) + 0.5)
			v_sh = J.add(0.9, (0.16 * v_v))
			v_daralt = floor(((1.0 - v_v) * 2.0) + 0.5)
			v_sx0 = J.add(J.getv(v_F, "ix"), v_daralt)
			v_sw = (J.getv(v_F, "iw") - (v_daralt * 2.0))
			v_c = 0.0
			while J.lt(v_c, v_sutun):
				v_u = (float(J.add(v_c, (1.0 if J.truth(v_gecis) else 0.5))) / float(v_sutun))
				if J.gt(v_u, 1.0):
					v_c = J.add(v_c, 1.0)
					continue
				v_tohum = J.add(J.add(J.add((v_c * 3.11), (v_r * 7.73)), v_seed), (v_gecis * 53.7))
				if (J.lt(v_seyreklik, 1.0) and J.gt(game.f_hash1(J.add((v_tohum * 4.7), 9.1)), v_seyreklik)):
					v_c = J.add(v_c, 1.0)
					continue
				v_kubbe = floor((((cos(((v_u - 0.5) * J.getv({"PI": PI}, "PI"))) * v_kabarma) * (1.0 - (v_v * 0.6))) * 0.6) + 0.5)
				v_jx = (((game.f_hash1(v_tohum) - 0.5) * (float(v_sw) / float(v_sutun))) * 1.35)
				v_jy = ((game.f_hash1(J.add((v_tohum * 1.7), 2.3)) - 0.5) * 2.6)
				v_px0 = J.add(J.add(v_sx0, (v_u * v_sw)), v_jx)
				v_py0 = (J.add(v_ry, v_jy) - v_kubbe)
				J.invoke(v_item, [floor(v_px0 + 0.5), floor(v_py0 + 0.5), v_sh, (int(J.n(J.add(J.add(J.add(v_c, (v_r * 41.0)), (v_seed * 13.0)), (v_gecis * 911.0)))) | int(J.n(0.0))), game.f_hash1(J.add((v_tohum * 2.31), 1.1))])
				v_c = J.add(v_c, 1.0)
			v_r = J.add(v_r, 1.0)
		v_gecis = J.add(v_gecis, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.12)
	game.f_fr(J.getv(v_F, "ix"), (v_arkaSinir - 1.0), J.getv(v_F, "iw"), 1.0, "#3a2a18")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.18)
	game.f_fr(J.getv(v_F, "ix"), (J.getv(v_F, "on") - 2.0), J.getv(v_F, "iw"), 2.0, "#ffd9a0")
	J.setv(game.j_ctx, "globalAlpha", 0.22)
	game.f_fr(J.getv(v_F, "ix"), J.getv(v_F, "on"), J.getv(v_F, "iw"), 1.0, "#3a3f45")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.13)
	game.f_vl(J.getv(v_F, "ix"), v_arkaSinir, (J.getv(v_F, "on") - v_arkaSinir), "#000")
	game.f_vl((J.add(J.getv(v_F, "ix"), J.getv(v_F, "iw")) - 1.0), v_arkaSinir, (J.getv(v_F, "on") - v_arkaSinir), "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	J.method(game.j_ctx, "restore", [])
	return v_arkaSinir
	return null

