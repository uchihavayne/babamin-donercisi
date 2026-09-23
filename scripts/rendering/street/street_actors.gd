# Street actors. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

func _closure_58(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.vehicle_draw.f_drawVehicle(_captures["219:cx0"][0], J.getv(_captures["218:laneY"][0], J.getv(_captures["219:cr"][0], "lane")), _captures["219:sc"][0], J.getv(_captures["219:cr"][0], "ty"), J.getv(_captures["219:cr"][0], "ci"), J.getv(_captures["219:cr"][0], "dir"), _captures["218:t"][0], _captures["219:duruyor"][0])
	return null

func _closure_57(_args: Array, _captures: Dictionary = {}) -> Variant:
	var _cells: Dictionary = {"cx0": [null], "cr": [null], "sc": [null], "duruyor": [null]}
	_cells["cr"][0] = J.arg(_args, 0)
	_cells["sc"][0] = (1.0 if J.truth(J.getv(_cells["cr"][0], "lane")) else 0.86)
	_cells["cx0"][0] = game.traffic_system.f_trafX(_cells["cr"][0], _captures["218:M"][0])
	_cells["duruyor"][0] = J.lt(J.getv(_cells["cr"][0], "v"), 3.0)
	J.method(_captures["218:actors"][0], "push", [{"y": J.getv(_captures["218:laneY"][0], J.getv(_cells["cr"][0], "lane")), "f": game.street_actors._closure_58.bind({"219:cx0": _cells["cx0"], "218:laneY": _captures["218:laneY"], "219:cr": _cells["cr"], "219:sc": _cells["sc"], "218:t": _captures["218:t"], "219:duruyor": _cells["duruyor"]})}])
	return null

func _closure_60(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_kmerkez: Variant = null
	var v_kok: Variant = null
	var v_kap: Variant = null
	var v_hx2: Variant = null
	var v_wx: Variant = null
	var v_kap2: Variant = null
	v_kmerkez = J.add(_captures["221:kx"][0], 31.0)
	v_kok = game.sprite_draw.f_sprCiz("karavan", _captures["221:kklip"][0], _captures["218:t"][0], v_kmerkez, _captures["221:ky"][0], {"mini": true, "flip": true, "u": _captures["221:ku"][0]})
	if (not J.truth(v_kok)):
		J.method(game.j_ctx, "save", [])
		J.method(game.j_ctx, "translate", [(v_kmerkez * 2.0), 0.0])
		J.method(game.j_ctx, "scale", [(-J.n(1.0)), 1.0])
		game.mount_draw.f_drawKaravan(_captures["221:kx"][0], _captures["221:ky"][0], _captures["218:t"][0], _captures["221:khiz"][0])
		J.method(game.j_ctx, "restore", [])
	if J.ge(_captures["221:kyuru"][0], 0.0):
		v_kap = (game.sprite_draw.f_sprSoket("karavan", "doorFoot", v_kmerkez, _captures["221:ky"][0], true, true) if J.truth(v_kok) else {"x": v_kmerkez, "y": _captures["221:ky"][0]})
		v_hx2 = J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 12.0)
		v_wx = floor(J.add(J.getv(v_kap, "x"), (_captures["221:kyuru"][0] * (v_hx2 - J.getv(v_kap, "x")))) + 0.5)
		game.sprite_draw.f_sprCiz("kimyager", "walk_side", _captures["218:t"][0], v_wx, J.add(_captures["221:ky"][0], 1.0), {"mini": true})
	else:
		if J.truth(_captures["221:kbin"][0]):
			v_kap2 = (game.sprite_draw.f_sprSoket("karavan", "doorFoot", v_kmerkez, _captures["221:ky"][0], true, true) if J.truth(v_kok) else {"x": v_kmerkez, "y": _captures["221:ky"][0]})
			game.sprite_draw.f_sprCiz("kimyager", "idle", _captures["218:t"][0], J.getv(v_kap2, "x"), J.add(_captures["221:ky"][0], 1.0), {"mini": true, "flip": true})
	return null

func _closure_59(_args: Array, _captures: Dictionary = {}) -> Variant:
	var _cells: Dictionary = {"kx": [null], "kklip": [null], "ky": [null], "ku": [null], "khiz": [null], "kyuru": [null], "kbin": [null]}
	var v_pkx: Variant = null
	var v_v: Variant = null
	var v_ge: Variant = null
	_cells["ky"][0] = J.add(J.getv(_captures["218:M"][0], "nearY"), 3.0)
	v_pkx = (J.add(_captures["218:gx"][0], _captures["218:gw"][0]) - 70.0)
	_cells["kx"][0] = v_pkx
	_cells["kklip"][0] = "idle"
	_cells["khiz"][0] = 0.0
	_cells["kyuru"][0] = (-J.n(1.0))
	_cells["kbin"][0] = false
	if J.eq(J.getv(game.j_KAR, "faz"), "gelis"):
		v_v = game.math_utils.f_clamp((float(J.getv(game.j_KAR, "t")) / float(J.getv(game.j_KAR_SURE, "gelis"))), 0.0, 1.0)
		v_ge = (1.0 - (((1.0 - v_v) * (1.0 - v_v)) * (1.0 - v_v)))
		_cells["kx"][0] = floor(J.add(v_pkx, ((J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 90.0) - v_pkx) * (1.0 - v_ge))) + 0.5)
		_cells["kklip"][0] = "drive"
		_cells["khiz"][0] = (1.0 - v_ge)
	else:
		if (J.eq(J.getv(game.j_KAR, "faz"), "kapiAc") or J.eq(J.getv(game.j_KAR, "faz"), "kapiAc2")):
			_cells["kklip"][0] = "door_open"
			_cells["ku"][0] = game.math_utils.f_clamp((float(J.getv(game.j_KAR, "t")) / float(J.getv(game.j_KAR_SURE, J.getv(game.j_KAR, "faz")))), 0.0, 1.0)
		else:
			if (J.eq(J.getv(game.j_KAR, "faz"), "kapiKapa") or J.eq(J.getv(game.j_KAR, "faz"), "kapiKapa2")):
				_cells["kklip"][0] = "door_close"
				_cells["ku"][0] = game.math_utils.f_clamp((float(J.getv(game.j_KAR, "t")) / float(J.getv(game.j_KAR_SURE, J.getv(game.j_KAR, "faz")))), 0.0, 1.0)
			else:
				if J.eq(J.getv(game.j_KAR, "faz"), "iner"):
					_cells["kklip"][0] = "door_open"
					_cells["ku"][0] = 1.0
					v_v = game.math_utils.f_clamp((float(J.getv(game.j_KAR, "t")) / float(J.getv(game.j_KAR_SURE, "iner"))), 0.0, 1.0)
					if J.lt(v_v, 0.8):
						_cells["kyuru"][0] = (float(v_v) / float(0.8))
				else:
					if J.eq(J.getv(game.j_KAR, "faz"), "biner"):
						_cells["kklip"][0] = "door_open"
						_cells["ku"][0] = 1.0
						v_v = game.math_utils.f_clamp((float(J.getv(game.j_KAR, "t")) / float(J.getv(game.j_KAR_SURE, "biner"))), 0.0, 1.0)
						if J.lt(v_v, 0.8):
							_cells["kyuru"][0] = (1.0 - (float(v_v) / float(0.8)))
						else:
							_cells["kbin"][0] = true
					else:
						if J.eq(J.getv(game.j_KAR, "faz"), "gidis"):
							v_v = game.math_utils.f_clamp((float(J.getv(game.j_KAR, "t")) / float(J.getv(game.j_KAR_SURE, "gidis"))), 0.0, 1.0)
							_cells["kx"][0] = floor((v_pkx - ((J.add((v_pkx - _captures["218:gx"][0]), 130.0) * v_v) * v_v)) + 0.5)
							_cells["kklip"][0] = "drive"
							_cells["khiz"][0] = 1.0
	J.method(_captures["218:actors"][0], "push", [{"y": _cells["ky"][0], "f": game.street_actors._closure_60.bind({"221:kx": _cells["kx"], "221:kklip": _cells["kklip"], "218:t": _captures["218:t"], "221:ky": _cells["ky"], "221:ku": _cells["ku"], "221:khiz": _cells["khiz"], "221:kyuru": _cells["kyuru"], "218:gx": _captures["218:gx"], "218:gw": _captures["218:gw"], "221:kbin": _cells["kbin"]})}])
	return null

func _closure_62(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_klip: Variant = null
	var v_u: Variant = null
	var v_ejdOk: Variant = null
	var v_st: Variant = null
	var v_gcx: Variant = null
	var v_ghx: Variant = null
	var v_bx: Variant = null
	v_klip = "idle"
	if J.eq(J.getv(game.j_EJD, "faz"), "ucus"):
		v_klip = "fly"
	else:
		if J.eq(J.getv(game.j_EJD, "faz"), "inis"):
			v_klip = "land"
			v_u = game.math_utils.f_clamp((float(J.getv(game.j_EJD, "t")) / float(J.getv(game.j_EJD_SURE, "inis"))), 0.0, 1.0)
		else:
			if J.eq(J.getv(game.j_EJD, "faz"), "kalkis"):
				v_klip = "takeoff"
				v_u = game.math_utils.f_clamp((float(J.getv(game.j_EJD, "t")) / float(J.getv(game.j_EJD_SURE, "kalkis"))), 0.0, 1.0)
	v_ejdOk = game.sprite_draw.f_sprCiz("ejderha", v_klip, _captures["218:t"][0], _captures["223:ex"][0], _captures["223:ey"][0], {"flip": true, "u": v_u})
	if (not J.truth(v_ejdOk)):
		game.mount_draw.f_drawEjderha(_captures["223:ex"][0], _captures["223:ey"][0], _captures["218:t"][0], _captures["223:inis"][0], _captures["223:ucus"][0])
	if J.eq(_captures["223:bin"][0], 0.0):
		v_st = (game.sprite_draw.f_sprSoket("ejderha", "riderSeat", _captures["223:ex"][0], _captures["223:ey"][0], false, true) if J.truth(v_ejdOk) else v_ejdOk)
		if (not (J.truth(v_st) and J.truth(game.sprite_draw.f_sprCiz("kralice", "ride", _captures["218:t"][0], J.getv(v_st, "x"), J.add(J.getv(v_st, "y"), 10.0), {"mini": true, "flip": true, "kesAlt": J.add(J.getv(v_st, "y"), 2.0)})))):
			game.mount_draw.f_drawKraliceMini((_captures["223:ex"][0] - 4.0), (_captures["223:ey"][0] - 21.0), _captures["218:t"][0], false, true)
	else:
		if J.eq(_captures["223:bin"][0], 1.0):
			v_gcx = J.add(_captures["223:ex"][0], 14.0)
			v_ghx = J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 16.0)
			v_bx = floor(J.add(v_gcx, (_captures["223:byuru"][0] * (v_ghx - v_gcx))) + 0.5)
			if (not J.truth(game.sprite_draw.f_sprCiz("kralice", "walk_side", _captures["218:t"][0], v_bx, J.add(_captures["223:pY"][0], 2.0), {"mini": true}))):
				game.mount_draw.f_drawKraliceMini(v_bx, J.add(_captures["223:pY"][0], 2.0), _captures["218:t"][0], true, false)
	return null

func _closure_61(_args: Array, _captures: Dictionary = {}) -> Variant:
	var _cells: Dictionary = {"ex": [null], "ey": [null], "inis": [null], "ucus": [null], "bin": [null], "byuru": [null], "pY": [null]}
	var v_pX: Variant = null
	var v_u: Variant = null
	var v_eu: Variant = null
	var v_ku: Variant = null
	v_pX = J.add(_captures["218:gx"][0], floor((_captures["218:gw"][0] * 0.6) + 0.5))
	_cells["pY"][0] = J.add(J.getv(_captures["218:M"][0], "farY"), 2.0)
	_cells["ex"][0] = v_pX
	_cells["ey"][0] = _cells["pY"][0]
	_cells["ucus"][0] = false
	_cells["inis"][0] = 1.0
	_cells["bin"][0] = (-J.n(1.0))
	_cells["byuru"][0] = 0.0
	if J.eq(J.getv(game.j_EJD, "faz"), "ucus"):
		v_u = game.math_utils.f_clamp((float(J.getv(game.j_EJD, "t")) / float(J.getv(game.j_EJD_SURE, "ucus"))), 0.0, 1.0)
		v_eu = (1.0 - ((1.0 - v_u) * (1.0 - v_u)))
		_cells["ex"][0] = floor(J.add(J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 90.0), ((((v_pX - _captures["218:gx"][0]) - _captures["218:gw"][0]) - 90.0) * v_eu)) + 0.5)
		_cells["ey"][0] = floor((_cells["pY"][0] - (84.0 * (1.0 - v_eu))) + 0.5)
		_cells["ucus"][0] = true
		_cells["inis"][0] = v_eu
		_cells["bin"][0] = 0.0
	else:
		if J.eq(J.getv(game.j_EJD, "faz"), "inis"):
			_cells["inis"][0] = (1.0 - (game.math_utils.f_clamp((float(J.getv(game.j_EJD, "t")) / float(J.getv(game.j_EJD_SURE, "inis"))), 0.0, 1.0) * 0.001))
			_cells["bin"][0] = 0.0
		else:
			if J.eq(J.getv(game.j_EJD, "faz"), "iner"):
				v_u = game.math_utils.f_clamp((float(J.getv(game.j_EJD, "t")) / float(J.getv(game.j_EJD_SURE, "iner"))), 0.0, 1.0)
				_cells["bin"][0] = (0.0 if J.lt(v_u, 0.3) else (1.0 if J.lt(v_u, 0.8) else (-J.n(1.0))))
				_cells["byuru"][0] = (0.0 if J.lt(v_u, 0.3) else (float((v_u - 0.3)) / float(0.7)))
			else:
				if J.eq(J.getv(game.j_EJD, "faz"), "biner"):
					v_u = game.math_utils.f_clamp((float(J.getv(game.j_EJD, "t")) / float(J.getv(game.j_EJD_SURE, "biner"))), 0.0, 1.0)
					_cells["bin"][0] = (0.0 if J.gt(v_u, 0.7) else 1.0)
					_cells["byuru"][0] = (0.0 if J.gt(v_u, 0.7) else (1.0 - (float(v_u) / float(0.7))))
				else:
					if J.eq(J.getv(game.j_EJD, "faz"), "kalkis"):
						v_u = game.math_utils.f_clamp((float(J.getv(game.j_EJD, "t")) / float(J.getv(game.j_EJD_SURE, "kalkis"))), 0.0, 1.0)
						v_ku = (v_u * v_u)
						_cells["ex"][0] = floor((v_pX - (J.add((v_pX - _captures["218:gx"][0]), 110.0) * v_ku)) + 0.5)
						_cells["ey"][0] = floor((_cells["pY"][0] - (96.0 * v_ku)) + 0.5)
						_cells["ucus"][0] = true
						_cells["inis"][0] = (1.0 - v_ku)
						_cells["bin"][0] = 0.0
	J.method(_captures["218:actors"][0], "push", [{"y": (_cells["pY"][0] if ((J.eq(J.getv(game.j_EJD, "faz"), "bekle") or J.eq(J.getv(game.j_EJD, "faz"), "iner")) or J.eq(J.getv(game.j_EJD, "faz"), "biner")) else (_cells["pY"][0] - 1.0)), "f": game.street_actors._closure_62.bind({"218:t": _captures["218:t"], "223:ex": _cells["ex"], "223:ey": _cells["ey"], "223:inis": _cells["inis"], "223:ucus": _cells["ucus"], "223:bin": _cells["bin"], "218:gx": _captures["218:gx"], "218:gw": _captures["218:gw"], "223:byuru": _cells["byuru"], "223:pY": _cells["pY"]})}])
	return null

func _closure_64(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_sag: Variant = null
	var v_sklip: Variant = null
	var v_su: Variant = null
	var v_ss: Variant = null
	var v_supOk: Variant = null
	var v_scx: Variant = null
	var v_shx: Variant = null
	var v_cbx: Variant = null
	v_sag = J.eq(J.getv(game.j_SUP, "faz"), "kalkis")
	v_sklip = "idle"
	if (J.eq(J.getv(game.j_SUP, "faz"), "ucus") or J.eq(J.getv(game.j_SUP, "faz"), "kalkis")):
		v_sklip = "fly"
	else:
		if J.eq(J.getv(game.j_SUP, "faz"), "iner"):
			v_sklip = "land"
			v_su = game.math_utils.f_clamp((float(J.getv(game.j_SUP, "t")) / float(J.getv(game.j_SUP_SURE, "iner"))), 0.0, 1.0)
		else:
			if J.eq(J.getv(game.j_SUP, "faz"), "biner"):
				v_sklip = "land"
				v_su = (1.0 - game.math_utils.f_clamp((float(J.getv(game.j_SUP, "t")) / float(J.getv(game.j_SUP_SURE, "biner"))), 0.0, 1.0))
	v_ss = (game.sprite_draw.f_sprSoket("supurge", "riderSeat", _captures["225:sx2"][0], _captures["225:sY"][0], true, (not J.truth(v_sag))) if (J.truth(_captures["225:sbin"][0]) and J.truth(game.sprite_draw.f_sprVar("supurge", true))) else null)
	if J.truth(v_ss):
		game.sprite_draw.f_sprCiz("cirak", "ride", _captures["218:t"][0], J.getv(v_ss, "x"), J.add(J.getv(v_ss, "y"), 12.0), {"mini": true, "flip": (not J.truth(v_sag))})
	v_supOk = game.sprite_draw.f_sprCiz("supurge", v_sklip, _captures["218:t"][0], _captures["225:sx2"][0], _captures["225:sY"][0], {"mini": true, "flip": (not J.truth(v_sag)), "u": v_su})
	if (not J.truth(v_supOk)):
		game.mount_draw.f_drawSupurge(_captures["225:sx2"][0], _captures["225:sY"][0], _captures["225:sp"][0], _captures["225:sbin"][0])
	if J.ge(_captures["225:syuru"][0], 0.0):
		v_scx = J.add(_captures["225:sx2"][0], 10.0)
		v_shx = J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 16.0)
		v_cbx = floor(J.add(v_scx, (_captures["225:syuru"][0] * (v_shx - v_scx))) + 0.5)
		if (not J.truth(game.sprite_draw.f_sprCiz("cirak", "walk_side", _captures["218:t"][0], v_cbx, J.add(_captures["225:sY"][0], 2.0), {"mini": true}))):
			game.mount_draw.f_drawCirakMini(v_cbx, J.add(_captures["225:sY"][0], 2.0), _captures["218:t"][0], false, true)
	return null

func _closure_63(_args: Array, _captures: Dictionary = {}) -> Variant:
	var _cells: Dictionary = {"sbin": [null], "sx2": [null], "sY": [null], "sp": [null], "syuru": [null]}
	var v_sX: Variant = null
	var v_u2: Variant = null
	var v_se: Variant = null
	var v_ku2: Variant = null
	v_sX = J.add(_captures["218:gx"][0], floor((_captures["218:gw"][0] * 0.3) + 0.5))
	_cells["sY"][0] = J.add(J.getv(_captures["218:M"][0], "curb2"), 2.0)
	_cells["sx2"][0] = v_sX
	_cells["sp"][0] = 1.0
	_cells["sbin"][0] = false
	_cells["syuru"][0] = (-J.n(1.0))
	if J.eq(J.getv(game.j_SUP, "faz"), "ucus"):
		v_u2 = game.math_utils.f_clamp((float(J.getv(game.j_SUP, "t")) / float(J.getv(game.j_SUP_SURE, "ucus"))), 0.0, 1.0)
		v_se = (1.0 - ((1.0 - v_u2) * (1.0 - v_u2)))
		_cells["sx2"][0] = floor(J.add(J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 34.0), ((((v_sX - _captures["218:gx"][0]) - _captures["218:gw"][0]) - 34.0) * v_se)) + 0.5)
		_cells["sp"][0] = v_se
		_cells["sbin"][0] = true
	else:
		if J.eq(J.getv(game.j_SUP, "faz"), "iner"):
			v_u2 = game.math_utils.f_clamp((float(J.getv(game.j_SUP, "t")) / float(J.getv(game.j_SUP_SURE, "iner"))), 0.0, 1.0)
			_cells["sbin"][0] = J.lt(v_u2, 0.3)
			if (J.ge(v_u2, 0.3) and J.lt(v_u2, 0.8)):
				_cells["syuru"][0] = (float((v_u2 - 0.3)) / float(0.7))
		else:
			if J.eq(J.getv(game.j_SUP, "faz"), "biner"):
				v_u2 = game.math_utils.f_clamp((float(J.getv(game.j_SUP, "t")) / float(J.getv(game.j_SUP_SURE, "biner"))), 0.0, 1.0)
				_cells["sbin"][0] = J.gt(v_u2, 0.7)
				if J.le(v_u2, 0.7):
					_cells["syuru"][0] = (1.0 - (float(v_u2) / float(0.7)))
			else:
				if J.eq(J.getv(game.j_SUP, "faz"), "kalkis"):
					v_ku2 = game.math_utils.f_clamp((float(J.getv(game.j_SUP, "t")) / float(J.getv(game.j_SUP_SURE, "kalkis"))), 0.0, 1.0)
					_cells["sx2"][0] = floor(J.add(v_sX, ((J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 44.0) - v_sX) * (v_ku2 * v_ku2))) + 0.5)
					_cells["sp"][0] = (1.0 - (v_ku2 * 0.35))
					_cells["sbin"][0] = true
	J.method(_captures["218:actors"][0], "push", [{"y": J.add(J.getv(_captures["218:M"][0], "curb2"), 1.0), "f": game.street_actors._closure_64.bind({"225:sbin": _cells["sbin"], "225:sx2": _cells["sx2"], "225:sY": _cells["sY"], "218:t": _captures["218:t"], "225:sp": _cells["sp"], "225:syuru": _cells["syuru"], "218:gx": _captures["218:gx"], "218:gw": _captures["218:gw"]})}])
	return null

func _closure_66(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.pedestrian_draw.f_drawPed(_captures["227:cx4"][0], _captures["227:cy3"][0], J.getv(_captures["227:cr"][0], "k"), _captures["227:bak"][0], _captures["218:t"][0], 1.0, _captures["218:rainOn"][0])
	return null

func _closure_65(_args: Array, _captures: Dictionary = {}) -> Variant:
	var _cells: Dictionary = {"cx4": [null], "cy3": [null], "cr": [null], "bak": [null]}
	var v_yon: Variant = null
	var v_pp: Variant = null
	_cells["cr"][0] = J.arg(_args, 0)
	if (J.le(J.getv(_cells["cr"][0], "p"), 0.0) and J.le(J.getv(_cells["cr"][0], "git"), 0.0)):
		return null
	v_yon = (J.getv(_cells["cr"][0], "yon") if J.truth(J.getv(_cells["cr"][0], "yon")) else 1.0)
	v_pp = (J.getv(_cells["cr"][0], "p") if J.gt(v_yon, 0.0) else (1.0 - J.getv(_cells["cr"][0], "p")))
	_cells["cy3"][0] = J.add(J.getv(_captures["218:M"][0], "walkY"), (v_pp * (J.getv(_captures["218:M"][0], "curb2") - J.getv(_captures["218:M"][0], "walkY"))))
	_cells["cx4"][0] = J.add(J.add(J.add(_captures["218:gx"][0], 200.0), (fmod(J.n(J.getv(_cells["cr"][0], "k")), J.n(3.0)) * 6.0)), J.getv(_cells["cr"][0], "kay"))
	_cells["bak"][0] = (1.0 if J.gt(J.getv(_cells["cr"][0], "git"), 0.0) else v_yon)
	J.method(_captures["218:actors"][0], "push", [{"y": _cells["cy3"][0], "f": game.street_actors._closure_66.bind({"227:cx4": _cells["cx4"], "227:cy3": _cells["cy3"], "227:cr": _cells["cr"], "227:bak": _cells["bak"], "218:t": _captures["218:t"], "218:rainOn": _captures["218:rainOn"]})}])
	return null

func _closure_68(_args: Array, _captures: Dictionary = {}) -> Variant:
	J.method(game.j_ctx, "save", [])
	if J.lt(J.getv(_captures["218:courier"][0], "dir"), 0.0):
		J.method(game.j_ctx, "translate", [(floor(_captures["229:sx3"][0] + 0.5) * 2.0), 0.0])
		J.method(game.j_ctx, "scale", [(-J.n(1.0)), 1.0])
	game.phone_draw.f_drawScooter(floor(_captures["229:sx3"][0] + 0.5), (_captures["229:cy2"][0] - 8.0), _captures["218:t"][0], 0.8)
	J.method(game.j_ctx, "restore", [])
	return null

func _closure_67(_args: Array, _captures: Dictionary = {}) -> Variant:
	var _cells: Dictionary = {"sx3": [null], "cy2": [null]}
	var v_cu: Variant = null
	v_cu = game.math_utils.f_clamp(J.getv(_captures["218:courier"][0], "out"), 0.0, 1.0)
	_cells["cy2"][0] = J.add(J.getv(_captures["218:M"][0], "farY"), 6.0)
	_cells["sx3"][0] = (J.add((_captures["218:gx"][0] - 34.0), (v_cu * J.add(_captures["218:gw"][0], 68.0))) if J.gt(J.getv(_captures["218:courier"][0], "dir"), 0.0) else (J.add(J.add(_captures["218:gx"][0], _captures["218:gw"][0]), 34.0) - (v_cu * J.add(_captures["218:gw"][0], 68.0))))
	J.method(_captures["218:actors"][0], "push", [{"y": _cells["cy2"][0], "f": game.street_actors._closure_68.bind({"218:courier": _captures["218:courier"], "229:sx3": _cells["sx3"], "229:cy2": _cells["cy2"], "218:t": _captures["218:t"]})}])
	return null

func _closure_69(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.incident_draw.f_drawKedi(_captures["218:t"][0])
	return null

func _closure_71(_args: Array, _captures: Dictionary = {}) -> Variant:
	game.pedestrian_draw.f_drawGozcu(J.getv(_captures["232:Z"][0], "x"), J.getv(_captures["218:M"][0], "curb2"), _captures["218:t"][0], J.eq(J.getv(_captures["232:Z"][0], "state"), "bak"), J.eq(J.getv(_captures["232:Z"][0], "state"), "sorgu"))
	return null

func _closure_70(_args: Array, _captures: Dictionary = {}) -> Variant:
	var _cells: Dictionary = {"Z": [null]}
	_cells["Z"][0] = J.arg(_args, 0)
	J.method(_captures["218:actors"][0], "push", [{"y": J.add(J.getv(_captures["218:M"][0], "curb2"), 1.0), "f": game.street_actors._closure_71.bind({"232:Z": _cells["Z"], "218:M": _captures["218:M"], "218:t": _captures["218:t"]})}])
	return null

func _closure_72(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_a: Variant = null
	var v_b: Variant = null
	v_a = J.arg(_args, 0)
	v_b = J.arg(_args, 1)
	return (J.getv(v_a, "y") - J.getv(v_b, "y"))
	return null
