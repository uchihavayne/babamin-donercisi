# Save system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# core.js:649
func f_volYukle() -> Variant:
	var v_v: Variant = null
	var v_e: Variant = null
	v_v = JSON.parse_string(J.s((J.method(game.j_localStorage, "getItem", [game.j_VOLKEY]) if J.truth(J.method(game.j_localStorage, "getItem", [game.j_VOLKEY])) else "null")))
	if J.truth(v_v):
		if J.eq(J.kind(J.getv(v_v, "mus")), "number"):
			J.setv(game.j_VOL, "mus", game.math_utils.f_clamp(floor(J.getv(v_v, "mus") + 0.5), 0.0, 100.0))
		if J.eq(J.kind(J.getv(v_v, "sfx")), "number"):
			J.setv(game.j_VOL, "sfx", game.math_utils.f_clamp(floor(J.getv(v_v, "sfx") + 0.5), 0.0, 100.0))
		if J.eq(J.kind(J.getv(v_v, "muted")), "boolean"):
			game.j_MUTED = J.getv(v_v, "muted")
	return null

# core.js:659
func f_volKaydet() -> Variant:
	var v_e: Variant = null
	J.method(game.j_localStorage, "setItem", [game.j_VOLKEY, JSON.stringify({"mus": J.getv(game.j_VOL, "mus"), "sfx": J.getv(game.j_VOL, "sfx"), "muted": game.j_MUTED})])
	return null

# core.js:974
func f_saveUyar() -> Variant:
	if ((J.truth(game.j_SAVE_UYARILDI) or J.eq(game.j_SAVE_DURUM, "ok")) or J.eq(game.j_SAVE_DURUM, "yok")):
		return null
	game.j_SAVE_UYARILDI = true
	if not J.eq(J.kind(J.ref(game.session_system.f_say, 1)), "function"):
		return null
	game.session_system.f_say(("Depolama dolu — ilerleme kaydedilemiyor!" if J.eq(game.j_SAVE_DURUM, "dolu") else ("Kayıt bozuk — yeni oyun başlatıldı" if J.eq(game.j_SAVE_DURUM, "bozuk") else "Kayıt kapalı — ilerleme saklanmıyor!")))
	return null

# game.js:233
func f_saveAll() -> Variant:
	game.f_saveGame({"day": J.getv(game.j_G, "day"), "money": J.getv(game.j_G, "money"), "up": J.getv(game.j_G, "up"), "best": J.getv(game.j_G, "best"), "totalSold": J.getv(game.j_G, "totalSold"), "debt": J.getv(game.j_G, "debt"), "stats": J.getv(game.j_G, "stats"), "custom": J.getv(game.j_G, "custom"), "moto": J.getv(game.j_G, "moto"), "prologueSeen": J.getv(game.j_G, "prologueSeen"), "luck": J.getv(game.j_G, "luck"), "branch": J.getv(game.j_G, "branch"), "city": J.getv(game.j_G, "city"), "dersGorulmus": J.getv(game.j_G, "dersGorulmus"), "fpara": J.getv(game.j_G, "fpara"), "fgun": J.getv(game.j_G, "fgun"), "hane": J.getv(game.j_G, "hane"), "fbatik": J.getv(game.j_G, "fbatik"), "ev": J.getv(game.j_G, "ev"), "bs": J.getv(game.j_G, "bs"), "ozelHedef": J.getv(game.j_G, "ozelHedef"), "ozelGecmis": J.getv(game.j_G, "ozelGecmis"), "rakipHedef": J.getv(game.j_G, "rakipHedef"), "rakipKapandi": J.getv(game.j_G, "rakipKapandi"), "rakipSeri": J.getv(game.j_G, "rakipSeri"), "macHedef": J.getv(game.j_G, "macHedef")})
	if J.eq(J.kind(J.ref(game.save_system.f_saveUyar, 0)), "function"):
		game.save_system.f_saveUyar()
	return null

# ui.js:623
func f_loadAndGo() -> Variant:
	var v_s: Variant = null
	v_s = game.f_loadGame()
	if J.truth(v_s):
		J.setv(game.j_G, "day", (J.getv(v_s, "day") if J.truth(J.getv(v_s, "day")) else 1.0))
		J.setv(game.j_G, "money", (J.getv(v_s, "money") if J.truth(J.getv(v_s, "money")) else 0.0))
		J.setv(game.j_G, "up", (J.getv(v_s, "up") if J.truth(J.getv(v_s, "up")) else {}))
		J.setv(game.j_G, "best", (J.getv(v_s, "best") if J.truth(J.getv(v_s, "best")) else 1.0))
		J.setv(game.j_G, "totalSold", (J.getv(v_s, "totalSold") if J.truth(J.getv(v_s, "totalSold")) else 0.0))
		J.setv(game.j_G, "debt", (game.j_DEBT_START if J.eq(J.getv(v_s, "debt"), null) else J.getv(v_s, "debt")))
		if J.truth(J.getv(v_s, "stats")):
			J.setv(game.j_G, "stats", J.getv(v_s, "stats"))
		if J.truth(J.getv(v_s, "custom")):
			J.setv(game.j_G, "custom", J.getv(v_s, "custom"))
		J.setv(game.j_G, "dersGorulmus", (not (not J.truth(J.getv(v_s, "dersGorulmus")))))
		J.setv(game.j_G, "fpara", (game.j_FP_BASLANGIC if J.eq(J.getv(v_s, "fpara"), null) else J.getv(v_s, "fpara")))
		J.setv(game.j_G, "fgun", (J.getv(v_s, "fgun") if J.truth(J.getv(v_s, "fgun")) else 0.0))
		J.setv(game.j_G, "hane", (J.getv(v_s, "hane") if J.truth(J.getv(v_s, "hane")) else null))
		J.setv(game.j_G, "fbatik", (J.getv(v_s, "fbatik") if J.truth(J.getv(v_s, "fbatik")) else 0.0))
		J.setv(game.j_G, "ev", (J.getv(v_s, "ev") if J.truth(J.getv(v_s, "ev")) else 0.0))
		J.setv(game.j_G, "branch", (J.getv(v_s, "branch") if J.truth(J.getv(v_s, "branch")) else 0.0))
		J.setv(game.j_G, "city", ((-J.n(1.0)) if J.eq(J.getv(v_s, "city"), null) else J.getv(v_s, "city")))
		J.setv(game.j_G, "rakipHedef", (J.getv(v_s, "rakipHedef") if J.truth(J.getv(v_s, "rakipHedef")) else 0.0))
		J.setv(game.j_G, "rakipKapandi", (not (not J.truth(J.getv(v_s, "rakipKapandi")))))
		J.setv(game.j_G, "rakipSeri", (J.getv(v_s, "rakipSeri") if J.truth(J.getv(v_s, "rakipSeri")) else 0.0))
		J.setv(game.j_G, "macHedef", (J.getv(v_s, "macHedef") if J.truth(J.getv(v_s, "macHedef")) else 0.0))
		J.setv(game.j_G, "ozelGecmis", (J.getv(v_s, "ozelGecmis") if J.truth(J.getv(v_s, "ozelGecmis")) else {}))
		J.setv(game.j_G, "ozelHedef", (J.getv(v_s, "ozelHedef") if J.truth(J.getv(v_s, "ozelHedef")) else J.add(J.add((J.getv(v_s, "day") if J.truth(J.getv(v_s, "day")) else 1.0), game.j_OZEL_ILK_MIN), floor((game.random_unit() * J.add((game.j_OZEL_ILK_MAK - game.j_OZEL_ILK_MIN), 1.0))))))
		J.setv(game.j_G, "bs", (J.getv(v_s, "bs") if J.truth(J.getv(v_s, "bs")) else null))
	if J.eq(J.kind(J.ref(game.achievement_system.f_basarimBaslat, 1)), "function"):
		game.achievement_system.f_basarimBaslat(true)
	game.session_system.f_goIntro()
	return null

func f_saveGame(value: Variant = null) -> Variant:
	value.sema = game.j_SAVE_SEMA
	game.storage.setItem(game.j_SAVEKEY, JSON.stringify(value))
	game.j_SAVE_DURUM = "ok" if game.storage.last_error == OK else "engelli"
	return game.storage.last_error == OK


func f_loadGame() -> Variant:
	var raw: Variant = game.storage.getItem(game.j_SAVEKEY)
	if raw == null:
		game.j_SAVE_DURUM = "yok"
		return null
	var parser := JSON.new()
	var error := parser.parse(str(raw))
	var data: Variant = parser.data if error == OK else null
	if not data is Dictionary or J.n(data.get("sema", 1)) > game.j_SAVE_SEMA:
		game.j_SAVE_DURUM = "bozuk"
		return null
	if not data.has("sema"): data.sema = 1.0
	game.j_SAVE_DURUM = "ok"
	return data


func f_clearSave() -> Variant:
	game.storage.removeItem(game.j_SAVEKEY)
	return null
