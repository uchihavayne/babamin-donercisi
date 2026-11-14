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
	game.f_saveGame({"day": J.getv(game.j_G, "day"), "money": J.getv(game.j_G, "money"), "up": J.getv(game.j_G, "up"), "best": J.getv(game.j_G, "best"), "totalSold": J.getv(game.j_G, "totalSold"), "debt": J.getv(game.j_G, "debt"), "stats": J.getv(game.j_G, "stats"), "custom": J.getv(game.j_G, "custom"), "moto": J.getv(game.j_G, "moto"), "prologueSeen": J.getv(game.j_G, "prologueSeen"), "luck": J.getv(game.j_G, "luck"), "branch": J.getv(game.j_G, "branch"), "city": J.getv(game.j_G, "city"), "dersGorulmus": J.getv(game.j_G, "dersGorulmus"), "fpara": J.getv(game.j_G, "fpara"), "fgun": J.getv(game.j_G, "fgun"), "hane": J.getv(game.j_G, "hane"), "fbatik": J.getv(game.j_G, "fbatik"), "ev": J.getv(game.j_G, "ev"), "bs": J.getv(game.j_G, "bs"), "ozelHedef": J.getv(game.j_G, "ozelHedef"), "ozelGecmis": J.getv(game.j_G, "ozelGecmis"), "bahisGecmis": J.getv(game.j_G, "bahisGecmis"), "rakipHedef": J.getv(game.j_G, "rakipHedef"), "rakipKapandi": J.getv(game.j_G, "rakipKapandi"), "rakipSeri": J.getv(game.j_G, "rakipSeri"), "macHedef": J.getv(game.j_G, "macHedef")})
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
		var v_bg: Variant = J.getv(v_s, "bahisGecmis")
		J.setv(game.j_G, "bahisGecmis", (v_bg if v_bg is Array else []))
		J.setv(game.j_G, "ozelHedef", (J.getv(v_s, "ozelHedef") if J.truth(J.getv(v_s, "ozelHedef")) else J.add(J.add((J.getv(v_s, "day") if J.truth(J.getv(v_s, "day")) else 1.0), game.j_OZEL_ILK_MIN), floor((game.random_unit() * J.add((game.j_OZEL_ILK_MAK - game.j_OZEL_ILK_MIN), 1.0))))))
		J.setv(game.j_G, "bs", (J.getv(v_s, "bs") if J.truth(J.getv(v_s, "bs")) else null))
	if J.eq(J.kind(J.ref(game.achievement_system.f_basarimBaslat, 1)), "function"):
		game.achievement_system.f_basarimBaslat(true)
	if J.truth(v_s) and game.save_system.gunici_yukle(): return null
	game.session_system.f_goIntro()
	return null

# ---------------------------------------------------------------------------
# GUN ICI KAYIT (BIRLESIK 11. tur, kullanici karari: mobilde uygulama isletim
# sistemince kapatilirsa devam eden gun kaybolmasin).
#
# Devam eden gunun butun oyun durumu (game.j_G) anlik goruntu olarak, ilerleme
# kaydindan AYRI bir anahtarla ("<SAVEKEY>_gunici") saklanir; ilerleme kaydinin
# semasi degismez. Yazilir: uygulama arka plana alinirken / pencere kapanirken
# (platform_game.f_appPause), Mola menusunden Ana Menu'ye cikarken ve oynarken
# her GUNICI_ARALIK saniyede bir. Silinir: gun bitince, yeni oyunda. Devam Et'te
# (f_loadAndGo) ayni gunun anlik goruntusu varsa gun MOLADA, kalinan yerden surer;
# yoksa ya da gecersizse eskisi gibi gunun giris kartina gidilir.
# Ayni nesneye iki yerden baglanti ({"$r": id}) korunur (tahtadaki urunun
# siparis sahibi musteri gibi).
const GUNICI_SURUM := 1
const GUNICI_ARALIK := 12.0
const _ETIKET := "\u0001"
# anlik goruntuye girmeyen (gecici / arayuz) alanlar
const GUNICI_ATLA := ["scene", "sceneT", "hint", "hintT", "drag", "test", "tutanak", "celeb", "hesap", "night"]

func gunici_anahtar() -> String: return str(game.j_SAVEKEY) + "_gunici"

func uygulama_surumu() -> String: return str(ProjectSettings.get_setting("application/config/version", ""))

func _gunici_enc(v: Variant, ctx: Dictionary) -> Variant:
	match typeof(v):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING: return v
		TYPE_FLOAT: return v if is_finite(v) else 0.0
		TYPE_STRING_NAME: return str(v)
		TYPE_ARRAY:
			var a: Array = []
			for e in v: a.append(_gunici_enc(e, ctx))
			return a
		TYPE_DICTIONARY:
			var d: Dictionary = v
			var salt_okunur: bool = d.is_read_only()
			if not salt_okunur and d.has(_ETIKET): return {"$r": d[_ETIKET]}
			var o: Dictionary = {}
			if not salt_okunur:
				ctx.say += 1
				d[_ETIKET] = ctx.say
				ctx.etiketli.append(d)
				o["$d"] = ctx.say
			for k in d:
				# _station_uid: istasyon modulunun gecici kimligi; geri yuklemede cakismasin
				if str(k) == _ETIKET or str(k) == "_station_uid": continue
				o[str(k)] = _gunici_enc(d[k], ctx)
			return o
	ctx.hata = true
	return null

func _gunici_dec(v: Variant, ctx: Dictionary) -> Variant:
	if v is Array:
		var a: Array = []
		for e in v: a.append(_gunici_dec(e, ctx))
		return a
	if v is Dictionary:
		if v.has("$r"): return ctx.nesne.get(int(v["$r"]))
		var o: Dictionary = {}
		if v.has("$d"): ctx.nesne[int(v["$d"])] = o
		for k in v:
			if k == "$d": continue
			o[k] = _gunici_dec(v[k], ctx)
		return o
	return v

# Gunun ortasi mi? Ogretici suruyorsa (1. gun) kaydedilmez.
func gunici_kaydedilebilir() -> bool:
	if game.j_G == null or not str(game.j_G.scene) in ["play", "pause"]: return false
	if J.truth(game.gameplay_input.f_tutBusy()): return false
	return game.j_G.get("cfg") is Dictionary and game.j_G.get("boards") is Array

func gunici_kaydet() -> bool:
	if not gunici_kaydedilebilir(): return false
	var G: Dictionary = game.j_G
	var ctx := {"say": 0, "etiketli": [], "hata": false}
	var kopya: Dictionary = {}
	for k in G:
		if k in GUNICI_ATLA: continue
		kopya[str(k)] = _gunici_enc(G[k], ctx)
	for d in ctx.etiketli: d.erase(_ETIKET)
	if ctx.hata: return false
	var veri := {"surum": GUNICI_SURUM, "uygulama": uygulama_surumu(), "gun": J.n(G.day), "G": kopya}
	game.storage.setItem(gunici_anahtar(), JSON.stringify(veri, "", false, true))   # tam hassasiyet: kesirler aynen donsun
	return game.storage.last_error == OK

func gunici_sil() -> void:
	if game.storage.getItem(gunici_anahtar()) != null: game.storage.removeItem(gunici_anahtar())

# Anlik goruntu ayni gunun mu ve tutarli mi? Tutarliysa cozulmus G sozlugunu dondurur.
func gunici_oku() -> Dictionary:
	var ham: Variant = game.storage.getItem(gunici_anahtar())
	if ham == null: return {}
	var ayrac := JSON.new()
	if ayrac.parse(str(ham)) != OK or not ayrac.data is Dictionary: return {}
	var veri: Dictionary = ayrac.data
	if int(J.n(veri.get("surum", -1))) != GUNICI_SURUM or str(veri.get("uygulama", "")) != uygulama_surumu(): return {}
	if not is_equal_approx(J.n(veri.get("gun", -1)), J.n(game.j_G.day)): return {}
	if not veri.get("G") is Dictionary: return {}
	var ctx := {"nesne": {}}
	var g: Variant = _gunici_dec(veri.G, ctx)
	if not g is Dictionary: return {}
	var boards: Variant = g.get("boards")
	for anahtar in ["cfg", "stat", "stock", "grill", "fryer", "cut", "spit", "phone"]:
		if not g.get(anahtar) is Dictionary: return {}
	if not (boards is Array) or not (g.get("customers") is Array) or not (g.grill.get("slots") is Array): return {}
	if boards.size() < 1: return {}
	if not (g.get("timeLeft") is float) or J.n(g.timeLeft) < 0.0: return {}
	return g

# Devam Et: varsa gunu kalinan yerden, molada surdurur. true = gun geri yuklendi.
func gunici_yukle() -> bool:
	var g: Dictionary = gunici_oku()
	if g.is_empty():
		gunici_sil()
		return false
	game.f_startDay()   # yerlesim / yapilandirma her zamanki gibi kurulur, sonra durum bindirilir
	var G: Dictionary = game.j_G
	if g.boards.size() != G.boards.size():   # tahta sayisi (gelistirme) uymuyorsa guvenle vazgec
		gunici_sil()
		return false
	for k in g:
		if k in GUNICI_ATLA: continue
		G[k] = g[k]
	G.scene = "pause"; G.sceneT = 0.0
	G.hint = ""; G.hintT = 0.0; G.drag = null; G.shutT = 0.0
	G.crate.open = false
	game.game_loop.f_invalidateLayers()
	if game.stations != null: game.stations.reset()
	if game.controls != null: game.controls.cancel_gesture()
	gunici_sil()
	return true

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
	game.save_system.gunici_sil()
	return null
