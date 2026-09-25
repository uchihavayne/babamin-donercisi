# Session system. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# game.js:33
func f_hitST(p_k: Variant = null) -> Variant:
	var v_s: Variant = null
	var v_k: Variant = p_k
	v_s = J.getv(game.j_ST, v_k)
	return game.math_utils.f_inRect(J.getv(game.j_IN, "x"), J.getv(game.j_IN, "y"), J.getv(v_s, "x"), J.getv(v_s, "y"), J.getv(v_s, "w"), J.getv(v_s, "h"))
	return null

# BIRLESIK (6. tur, analiz madde 20): alttaki ipucu satiri surekli doluydu.
# Ogretici / onay mesajlari (hata ve olay degil) oyun basina ilk 3 kez
# gosterilir; hatalar ("Yer yok!", "Once ...") ve olaylar her zaman.
const OGRETICI := ["Yeni lavaş — malzemeler buna gidiyor", "Tabağa geçti — şimdi döner koy",
	"Kızarıyor…", "Daha doluyor…", "Daha pişiyor…", "Kutu açık — tıklayarak doldur",
	"Kutu kendi dolduruyor", "Çöpe atıldı", "Yanmış dürüm çöpe atıldı", "Çöp boşaltıldı — tertemiz!",
	"Tereyağı sosu döküldü", "Sarmak için yukarı doğru sürükle", "Kağıdı tutup dürümün üstüne sürükle",
	"Kutuyu patates tepsisine sürükle", "Pideyi doğra — tahtaya tıkla", "Ürünleri Dayıya ver"]
const OGRETICI_EN_COK := 3
var _ogretici_sayac: Dictionary = {}

# game.js:34
func f_say(p_s: Variant = null) -> Variant:
	var v_s: Variant = p_s
	if v_s in OGRETICI:
		var n: int = _ogretici_sayac.get(v_s, 0)
		if n >= OGRETICI_EN_COK: return null
		_ogretici_sayac[v_s] = n + 1
	J.setv(game.j_G, "hint", game.localization.f_T(v_s))
	J.setv(game.j_G, "hintT", 1.8)
	return null

# game.js:35
func f_stMax() -> Variant:
	return J.method(game.j_TUN, "stockMax", [game.j_G])
	return null

# game.js:38
func f_startDay() -> Variant:
	J.setv(game.j_G, "cfg", game.progression_system.f_dayCfg(J.getv(game.j_G, "day"), game.j_G))
	J.setv(game.j_G, "timeLeft", J.getv(J.getv(game.j_G, "cfg"), "len"))
	J.setv(game.j_G, "spit", {"rot": 0.0, "sliceT": 0.0, "cutDepth": 0.0, "roast": 0.85, "mass": 1.0})
	J.setv(game.j_G, "shave", {"travel": 0.0, "lastY": (-J.n(1.0)), "act": 0.0, "auto": 0.0, "cd": 0.0})
	J.setv(game.j_G, "meat", 0.0)
	J.setv(game.j_G, "cut", {"potato": false, "prog": 0.0, "cutting": false, "raw": 0.0, "autoT": 0.0, "hold": 0.0, "slash": [], "yon": 1.0, "sayac": 0.0})
	J.setv(game.j_G, "fryer", {"state": "idle", "t": 0.0, "dur": 0.0, "load": 0.0, "prog": 0.0, "basketY": (-J.n(5.0))})
	J.setv(game.j_G, "friesTray", 0.0)
	J.setv(game.j_G, "boards", [null, null, null])
	J.setv(game.j_G, "act", 0.0)
	J.setv(game.j_G, "paper", {"busy": 0.0, "dur": 1.0, "idx": 0.0})
	J.setv(game.j_G, "grill", {"slots": [], "sz": 0.0})
	J.setv(game.j_G, "drinkM", {"pour": null, "t": 0.0, "pours": {}})
	J.setv(game.j_G, "cups", {"fanta": null, "cola": null, "ayran": null})
	J.setv(game.j_G, "fbox", {"busy": 0.0, "ready": 0.0, "fly": null})
	J.setv(game.j_G, "hand", null)
	J.setv(game.j_G, "coins", [])
	J.setv(game.j_G, "customers", [])
	J.setv(game.j_G, "spawnT", (999.0 if J.eq(J.getv(game.j_G, "day"), 1.0) else game.j_ILK_MUSTERI))
	J.setv(game.j_G, "stat", {"wraps": 0.0, "drinks": 0.0, "boxes": 0.0, "sweets": 0.0, "isk": 0.0, "lost": 0.0, "earned": 0.0, "tips": 0.0, "debtPaid": 0.0, "branch": 0.0, "brPerf": 1.0, "yerYok": 0.0})
	J.setv(game.j_G, "sauceFx", {"hot": 0.0, "garlic": 0.0, "butter": 0.0})
	J.setv(game.j_G, "shutT", 1.0)
	J.setv(game.j_G, "kapanis", null)
	J.setv(game.j_G, "shutSnd", 0.0)
	J.setv(game.j_G, "flyCoins", [])
	if (not J.truth(J.getv(game.j_G, "moto"))):
		J.setv(game.j_G, "moto", {"broken": false, "cost": 0.0})
	if ((((not J.truth(J.getv(J.getv(game.j_G, "moto"), "broken"))) and J.truth(J.method(game.j_TUN, "phoneOn", [game.j_G]))) and J.ge(J.getv(game.j_G, "day"), game.j_MOTO_DAY)) and J.truth(game.f_chance(game.j_MOTO_CHANCE))):
		J.setv(J.getv(game.j_G, "moto"), "broken", true)
		J.setv(J.getv(game.j_G, "moto"), "cost", (floor((float(J.add(260.0, (J.getv(game.j_G, "day") * 22.0))) / float(10.0)) + 0.5) * 10.0))
		J.setv(J.getv(game.j_G, "moto"), "newT", 4.0)
	J.setv(game.j_G, "chef", {"mode": "idle", "armT": 0.0})
	if (not J.truth(J.getv(game.j_G, "macHedef"))):
		J.setv(game.j_G, "macHedef", J.add(game.j_MAC_ILK, floor((game.random_unit() * 4.0))))
	J.setv(game.j_G, "macGun", J.ge(J.getv(game.j_G, "day"), J.getv(game.j_G, "macHedef")))
	if J.truth(J.getv(game.j_G, "macGun")):
		J.setv(game.j_G, "macHedef", J.add(J.add(J.getv(game.j_G, "day"), game.j_MAC_ARA_MIN), floor((game.random_unit() * J.add((game.j_MAC_ARA_MAK - game.j_MAC_ARA_MIN), 1.0)))))
	J.setv(game.j_G, "macDalga", false)
	game.rival_system.f_rakipGunBasi()
	J.setv(game.j_G, "bahisSonuc", null)
	J.setv(game.j_G, "kesinti", null)
	if ((J.ge(J.getv(game.j_G, "day"), game.j_KESINTI_GUN) and J.truth(J.method(game.j_TUN, "kesintiVar", [game.j_G]))) and J.truth(game.f_chance(game.j_KESINTI_SANS))):
		J.setv(game.j_G, "kesinti", {"faz": "bekle", "t": 0.0, "basla": game.math_utils.f_rnd(0.3, 0.7), "sure": J.method(game.j_TUN, "kesintiSure", [game.j_G]), "uyari": 0.0})
	J.setv(game.j_G, "kedi", ({"faz": "yok", "t": 0.0, "girisT": game.math_utils.f_rnd(12.0, 40.0), "x": 0.0, "doydu": false, "miyav": 0.0} if (J.ge(J.getv(game.j_G, "day"), game.j_KEDI_GUN) and J.truth(game.f_chance(game.j_KEDI_SANS))) else null))
	J.setv(game.j_G, "ozelBugun", false)
	if (not J.truth(J.getv(game.j_G, "ozelGecmis"))):
		J.setv(game.j_G, "ozelGecmis", {})
	if (not J.truth(J.getv(game.j_G, "ozelHedef"))):
		J.setv(game.j_G, "ozelHedef", J.add(game.j_OZEL_ILK_MIN, floor((game.random_unit() * J.add((game.j_OZEL_ILK_MAK - game.j_OZEL_ILK_MIN), 1.0)))))
	J.setv(game.j_G, "uncle", {"left": J.method(game.j_TUN, "uncleUses", [game.j_G]), "flashT": 0.0})
	J.setv(game.j_G, "crate", {"open": false, "t": 0.0, "popT": 0.0, "a": 0.0})
	J.setv(game.j_G, "stock", {"pickle": 0.0, "yogurt": 0.0, "ayran": 0.0, "sweet": 0.0, "tomato": 0.0, "pepper": 0.0})
	J.setv(game.j_G, "stockAnim", {"pickle": J.getv(J.getv(game.j_G, "stock"), "pickle"), "yogurt": J.getv(J.getv(game.j_G, "stock"), "yogurt"), "ayran": J.getv(J.getv(game.j_G, "stock"), "ayran"), "sweet": J.getv(J.getv(game.j_G, "stock"), "sweet"), "tomato": J.getv(J.getv(game.j_G, "stock"), "tomato"), "pepper": J.getv(J.getv(game.j_G, "stock"), "pepper")})
	J.setv(game.j_G, "fxTray", {"pickle": 0.0, "yogurt": 0.0, "fries": 0.0, "meat": 0.0, "ayran": 0.0, "sweet": 0.0, "tomato": 0.0, "pepper": 0.0})
	J.setv(game.j_G, "ferman", ({"liste": game.progression_system.f_fermanSec(J.getv(game.j_G, "day")), "ceza": 0.0, "kapandi": false, "kagit": 0.0, "kagitT": 0.0, "kayit": [], "kacan": 0.0} if J.truth(game.progression_system.f_fermanSehri(game.j_G)) else null))
	J.setv(game.j_G, "gozcu", (game.regulation_system.f_gozcuKur() if J.truth(game.progression_system.f_fermanSehri(game.j_G)) else null))
	if J.truth(game.progression_system.f_fermanSehri(game.j_G)):
		game.household_system.f_fermanEkonomiKur(false)
	J.setv(game.j_G, "lider", ({"state": "bekle", "t": game.math_utils.f_rnd(35.0, max(45.0, (J.getv(J.getv(game.j_G, "cfg"), "len") - 55.0))), "x": J.add(game.j_W, 40.0), "y": 152.0, "tx": 250.0, "sabir": 1.0, "istek": null, "sonuc": null} if (J.truth(game.progression_system.f_fermanSehri(game.j_G)) and J.truth(game.progression_system.f_liderGunu(J.getv(game.j_G, "fgun"), J.getv(game.j_G, "day")))) else null))
	J.setv(game.j_G, "tutanak", null)
	J.setv(game.j_G, "act", 0.0)
	J.setv(game.j_G, "flyIng", [])
	J.setv(game.j_G, "flyMeat", [])
	J.setv(game.j_G, "flyP", null)
	game.phone_system.f_phoneReset()
	game.weather_system.f_rollWeather()
	J.setv(game.j_G, "trash", 0.0)
	J.setv(game.j_G, "emptyT", 0.0)
	J.setv(game.j_G, "inspect", null)
	if (J.ge(J.getv(game.j_G, "day"), game.j_INSPECT_DAY) and J.truth(game.f_chance(game.j_INSPECT_CHANCE))):
		J.setv(game.j_G, "inspect", {"state": "wait", "t": game.math_utils.f_rnd(25.0, max(30.0, (J.getv(J.getv(game.j_G, "cfg"), "len") - 40.0))), "x": J.add(game.j_W, 26.0), "y": 152.0, "tx": 250.0, "dirty": false, "fine": 0.0, "line": ""})
	J.setv(game.j_G, "tut", (0.0 if J.eq(J.getv(game.j_G, "day"), 1.0) else 99.0))
	if not J.eq(J.kind(game.j_TUTFX), "undefined"):
		J.setv(game.j_TUTFX, "ilk", true)
		J.setv(game.j_TUTFX, "karart", 0.0)
	J.setv(game.j_G, "scene", "play")
	J.setv(game.j_G, "sceneT", 0.0)
	return null

# BIRLESIK (8. tur): ilk 5 gun borc taksiti kesilmez; baslangic parasi yukseltmeye gider
const TAKSIT_GUN := 6.0

# game.js:134
func f_endDay() -> Variant:
	var v_served: Variant = null
	var v_pay: Variant = null
	var v_S: Variant = null
	var v_gunAdet: Variant = null
	var v_tf2: Variant = null
	var v_tj: Variant = null
	while J.truth(J.getv(J.getv(game.j_G, "coins"), "length")):
		game.payment_system.f_collectCoin(0.0, true)
	J.setv(game.j_G, "best", max(J.getv(game.j_G, "best"), J.getv(game.j_G, "day")))
	game.rival_system.f_bahisCoz()
	v_served = J.add(J.add((J.getv(J.getv(game.j_G, "stat"), "wraps") if J.truth(J.getv(J.getv(game.j_G, "stat"), "wraps")) else 0.0), (J.getv(J.getv(game.j_G, "stat"), "boxes") if J.truth(J.getv(J.getv(game.j_G, "stat"), "boxes")) else 0.0)), (J.getv(J.getv(game.j_G, "stat"), "isk") if J.truth(J.getv(J.getv(game.j_G, "stat"), "isk")) else 0.0))
	J.setv(J.getv(game.j_G, "stat"), "brPerf", game.progression_system.f_branchPerf(v_served, (J.getv(J.getv(game.j_G, "stat"), "lost") if J.truth(J.getv(J.getv(game.j_G, "stat"), "lost")) else 0.0), J.getv(game.j_G, "day"), game.j_G))
	J.setv(J.getv(game.j_G, "stat"), "branch", floor((game.progression_system.f_branchBase(game.j_G) * J.getv(J.getv(game.j_G, "stat"), "brPerf")) + 0.5))
	if J.gt(J.getv(J.getv(game.j_G, "stat"), "branch"), 0.0):
		if J.truth(game.progression_system.f_fermanSehri(game.j_G)):
			J.setv(J.getv(game.j_G, "stat"), "branch", 0.0)
		else:
			J.setv(game.j_G, "money", J.add(J.getv(game.j_G, "money"), J.getv(J.getv(game.j_G, "stat"), "branch")))
		J.setv(J.getv(game.j_G, "stat"), "earned", J.add(J.getv(J.getv(game.j_G, "stat"), "earned"), J.getv(J.getv(game.j_G, "stat"), "branch")))
	v_pay = 0.0
	if (J.gt(J.getv(game.j_G, "debt"), 0.0) and (not J.truth(game.progression_system.f_fermanSehri(game.j_G))) and J.ge(J.getv(game.j_G, "day"), TAKSIT_GUN)):
		v_pay = min(J.getv(game.j_G, "debt"), floor((J.getv(J.getv(game.j_G, "stat"), "earned") * game.j_DEBT_CUT) + 0.5))
		J.setv(game.j_G, "debt", (J.getv(game.j_G, "debt") - v_pay))
		J.setv(game.j_G, "money", max(0.0, (J.getv(game.j_G, "money") - v_pay)))
		J.setv(J.getv(game.j_G, "stat"), "debtPaid", v_pay)
		if J.le(J.getv(game.j_G, "debt"), 0.0):
			J.setv(game.j_G, "debt", 0.0)
			if (not J.truth(J.getv(game.j_G, "debtCleared"))):
				J.setv(game.j_G, "debtCleared", true)
				J.setv(game.j_G, "celeb", {"t": 0.0})
	v_S = J.getv(game.j_G, "stats")
	J.setv(v_S, "wraps", J.add(J.getv(v_S, "wraps"), J.getv(J.getv(game.j_G, "stat"), "wraps")))
	J.setv(v_S, "drinks", J.add(J.getv(v_S, "drinks"), J.getv(J.getv(game.j_G, "stat"), "drinks")))
	J.setv(v_S, "boxes", J.add(J.getv(v_S, "boxes"), J.getv(J.getv(game.j_G, "stat"), "boxes")))
	J.setv(v_S, "sweets", J.add(J.getv(v_S, "sweets"), (J.getv(J.getv(game.j_G, "stat"), "sweets") if J.truth(J.getv(J.getv(game.j_G, "stat"), "sweets")) else 0.0)))
	J.setv(v_S, "isk", J.add((J.getv(v_S, "isk") if J.truth(J.getv(v_S, "isk")) else 0.0), (J.getv(J.getv(game.j_G, "stat"), "isk") if J.truth(J.getv(J.getv(game.j_G, "stat"), "isk")) else 0.0)))
	J.setv(v_S, "earned", J.add(J.getv(v_S, "earned"), J.getv(J.getv(game.j_G, "stat"), "earned")))
	J.setv(v_S, "lost", J.add(J.getv(v_S, "lost"), J.getv(J.getv(game.j_G, "stat"), "lost")))
	J.setv(v_S, "debtPaid", J.add(J.getv(v_S, "debtPaid"), v_pay))
	J.setv(v_S, "fines", J.add(J.getv(v_S, "fines"), (J.getv(J.getv(game.j_G, "stat"), "fine") if J.truth(J.getv(J.getv(game.j_G, "stat"), "fine")) else 0.0)))
	J.setv(v_S, "days", J.add(J.getv(v_S, "days"), 1.0))
	if J.gt(J.getv(J.getv(game.j_G, "stat"), "earned"), J.getv(v_S, "best")):
		J.setv(v_S, "best", J.getv(J.getv(game.j_G, "stat"), "earned"))
	J.setv(v_S, "bahsis", J.add((J.getv(v_S, "bahsis") if J.truth(J.getv(v_S, "bahsis")) else 0.0), (J.getv(J.getv(game.j_G, "stat"), "tips") if J.truth(J.getv(J.getv(game.j_G, "stat"), "tips")) else 0.0)))
	v_gunAdet = J.add(J.add(J.add(J.add((J.getv(J.getv(game.j_G, "stat"), "wraps") if J.truth(J.getv(J.getv(game.j_G, "stat"), "wraps")) else 0.0), (J.getv(J.getv(game.j_G, "stat"), "drinks") if J.truth(J.getv(J.getv(game.j_G, "stat"), "drinks")) else 0.0)), (J.getv(J.getv(game.j_G, "stat"), "boxes") if J.truth(J.getv(J.getv(game.j_G, "stat"), "boxes")) else 0.0)), (J.getv(J.getv(game.j_G, "stat"), "sweets") if J.truth(J.getv(J.getv(game.j_G, "stat"), "sweets")) else 0.0)), (J.getv(J.getv(game.j_G, "stat"), "isk") if J.truth(J.getv(J.getv(game.j_G, "stat"), "isk")) else 0.0))
	if J.gt(v_gunAdet, (J.getv(v_S, "gunEnCok") if J.truth(J.getv(v_S, "gunEnCok")) else 0.0)):
		J.setv(v_S, "gunEnCok", v_gunAdet)
	if (J.eq((J.getv(J.getv(game.j_G, "stat"), "lost") if J.truth(J.getv(J.getv(game.j_G, "stat"), "lost")) else 0.0), 0.0) and J.ge(v_gunAdet, 10.0)):
		J.setv(v_S, "mukemmel", J.add((J.getv(v_S, "mukemmel") if J.truth(J.getv(v_S, "mukemmel")) else 0.0), 1.0))
	J.setv(v_S, "temizSeri", (0.0 if J.gt((J.getv(J.getv(game.j_G, "stat"), "fine") if J.truth(J.getv(J.getv(game.j_G, "stat"), "fine")) else 0.0), 0.0) else J.add((J.getv(v_S, "temizSeri") if J.truth(J.getv(v_S, "temizSeri")) else 0.0), 1.0)))
	if (((J.eq(J.kind(J.ref(game.session_system.f_stMax, 0)), "function") and J.truth(J.getv(game.j_G, "stock"))) and J.ge(J.getv(J.getv(game.j_G, "stock"), "pickle"), game.session_system.f_stMax())) and J.ge(J.getv(J.getv(game.j_G, "stock"), "yogurt"), game.session_system.f_stMax())):
		J.setv(v_S, "depoTam", J.add((J.getv(v_S, "depoTam") if J.truth(J.getv(v_S, "depoTam")) else 0.0), 1.0))
	if (J.le(J.getv(game.j_G, "money"), 0.0) and (not J.truth(game.progression_system.f_fermanSehri(game.j_G)))):
		J.setv(v_S, "sifirGun", J.add((J.getv(v_S, "sifirGun") if J.truth(J.getv(v_S, "sifirGun")) else 0.0), 1.0))
	if J.truth(game.progression_system.f_fermanSehri(game.j_G)):
		if J.gt((J.getv(game.j_G, "fgun") if J.truth(J.getv(game.j_G, "fgun")) else 0.0), (J.getv(v_S, "fgunEn") if J.truth(J.getv(v_S, "fgunEn")) else 0.0)):
			J.setv(v_S, "fgunEn", (J.getv(game.j_G, "fgun") if J.truth(J.getv(game.j_G, "fgun")) else 0.0))
		if J.gt((J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0), (J.getv(v_S, "evEn") if J.truth(J.getv(v_S, "evEn")) else 0.0)):
			J.setv(v_S, "evEn", (J.getv(game.j_G, "ev") if J.truth(J.getv(game.j_G, "ev")) else 0.0))
		if (((not J.truth(J.getv(game.j_G, "ferman"))) or (not J.truth(J.getv(J.getv(game.j_G, "ferman"), "kayit")))) or (not J.truth(J.getv(J.getv(J.getv(game.j_G, "ferman"), "kayit"), "length")))):
			J.setv(v_S, "temizGun", J.add((J.getv(v_S, "temizGun") if J.truth(J.getv(v_S, "temizGun")) else 0.0), 1.0))
	if (not J.truth(J.getv(v_S, "sehir"))):
		J.setv(v_S, "sehir", [])
	if (J.ge(J.getv(game.j_G, "city"), 0.0) and J.lt(J.method(J.getv(v_S, "sehir"), "indexOf", [J.getv(game.j_G, "city")]), 0.0)):
		J.method(J.getv(v_S, "sehir"), "push", [J.getv(game.j_G, "city")])
	J.setv(game.j_G, "tutanak", ({"kayit": J.method(J.getv(J.getv(game.j_G, "ferman"), "kayit"), "slice", []), "t": 0.0} if ((J.truth(J.getv(game.j_G, "ferman")) and J.truth(J.getv(J.getv(game.j_G, "ferman"), "kayit"))) and J.truth(J.getv(J.getv(J.getv(game.j_G, "ferman"), "kayit"), "length"))) else null))
	if ((((J.truth(game.phone_system.f_fermanTelefonZorunlu()) and J.truth(J.getv(game.j_G, "ferman"))) and (not J.truth(J.getv(J.getv(game.j_G, "ferman"), "kapandi")))) and J.truth(J.getv(game.j_G, "phone"))) and J.eq(J.getv(J.getv(game.j_G, "phone"), "state"), "order")):
		v_tf2 = null
		v_tj = 0.0
		while J.lt(v_tj, J.getv(J.getv(J.getv(game.j_G, "ferman"), "liste"), "length")):
			if J.eq(J.getv(J.getv(J.getv(J.getv(game.j_G, "ferman"), "liste"), v_tj), "id"), "telefon"):
				v_tf2 = J.getv(J.getv(J.getv(game.j_G, "ferman"), "liste"), v_tj)
			v_tj = J.add(v_tj, 1.0)
		game.regulation_system.f_fermanIhlal(v_tf2, (float(game.j_W) / float(2.0)), 110.0, "telefon")
	J.setv(game.j_G, "hesap", (game.household_system.f_hesapKur() if J.truth(game.progression_system.f_fermanSehri(game.j_G)) else null))
	J.setv(game.j_G, "scene", "dayend")
	J.setv(game.j_G, "sceneT", 0.0)
	J.method(game.j_SFX, "shutter", [])
	J.method(game.j_SFX, "levelup", [])
	if J.eq(J.kind(J.ref(game.achievement_system.f_basarimTara, 1)), "function"):
		game.achievement_system.f_basarimTara()
	game.save_system.f_saveAll()
	return null

# game.js:203
func f_resetProgress() -> Variant:
	J.setv(game.j_G, "day", 1.0)
	J.setv(game.j_G, "money", 0.0)
	J.setv(game.j_G, "tips", 0.0)
	J.setv(game.j_G, "up", {})
	J.setv(game.j_G, "stars", {})
	J.setv(game.j_G, "dersGorulmus", false)
	J.setv(game.j_G, "ders", null)
	J.setv(game.j_G, "fpara", game.j_FP_BASLANGIC)
	J.setv(game.j_G, "fgun", 0.0)
	J.setv(game.j_G, "hane", null)
	J.setv(game.j_G, "fbatik", 0.0)
	J.setv(game.j_G, "hesap", null)
	J.setv(game.j_G, "ev", 0.0)
	J.setv(game.j_G, "best", 0.0)
	J.setv(game.j_G, "totalSold", 0.0)
	J.setv(game.j_G, "branch", 0.0)
	J.setv(game.j_G, "city", (-J.n(1.0)))
	J.setv(game.j_G, "debt", game.j_DEBT_START)
	J.setv(game.j_G, "debtCleared", false)
	J.setv(game.j_G, "celeb", null)
	J.setv(game.j_G, "luck", 0.0)
	J.setv(game.j_G, "moto", {"broken": false, "cost": 0.0})
	J.setv(game.j_G, "stats", {"wraps": 0.0, "drinks": 0.0, "boxes": 0.0, "sweets": 0.0, "isk": 0.0, "earned": 0.0, "best": 0.0, "days": 0.0, "debtPaid": 0.0, "phone": 0.0, "lost": 0.0, "fines": 0.0, "stolen": 0.0, "bahsis": 0.0, "enBahsis": 0.0, "gunEnCok": 0.0, "mukemmel": 0.0, "enSeri": 0.0, "temizSeri": 0.0, "depoTam": 0.0, "buyukSiparis": 0.0, "fgunEn": 0.0, "evEn": 0.0, "lider": 0.0, "temizGun": 0.0, "kacak": 0.0, "muhur": 0.0, "yanik": 0.0, "sifirGun": 0.0, "moto": 0.0, "dayi": 0.0, "fed": 0.0, "sehir": []})
	J.setv(game.j_G, "custom", null)
	J.setv(game.j_G, "bs", {})
	J.setv(game.j_G, "rakipHedef", 0.0)
	J.setv(game.j_G, "rakipKapandi", false)
	J.setv(game.j_G, "rakipSeri", 0.0)
	J.setv(game.j_G, "rakipAcik", false)
	J.setv(game.j_G, "rakip", null)
	J.setv(game.j_G, "bahis", null)
	J.setv(game.j_G, "bahisSonuc", null)
	J.setv(game.j_G, "macHedef", 0.0)
	J.setv(game.j_G, "macGun", false)
	J.setv(game.j_G, "ozelBugun", false)
	J.setv(game.j_G, "ozelGecmis", {})
	J.setv(game.j_G, "ozelHedef", J.add(game.j_OZEL_ILK_MIN, floor((game.random_unit() * J.add((game.j_OZEL_ILK_MAK - game.j_OZEL_ILK_MIN), 1.0)))))
	return null

# ui.js:644
func f_goIntro() -> Variant:
	if ((not J.truth(J.getv(game.j_G, "prologueSeen"))) and J.eq(J.getv(game.j_G, "day"), 1.0)):
		game.story_draw.f_proStart()
		return null
	J.setv(game.j_G, "scene", "intro")
	J.setv(game.j_G, "sceneT", 0.0)
	return null

func _closure_251(_args: Array, _captures: Dictionary = {}) -> Variant:
	return J.ge(J.getv(game.j_G, "meat"), 2.0)
	return null

func _closure_252(_args: Array, _captures: Dictionary = {}) -> Variant:
	return (not (not J.truth(J.getv(J.getv(game.j_G, "boards"), 0.0))))
	return null

func _closure_253(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_w: Variant = null
	v_w = J.getv(J.getv(game.j_G, "boards"), 0.0)
	return (J.ge(J.getv(v_w, "meat"), game.j_MEAT_NEED) if J.truth(v_w) else v_w)
	return null

func _closure_254(_args: Array, _captures: Dictionary = {}) -> Variant:
	return (J.ge(J.getv(J.getv(game.j_G, "stock"), "yogurt"), game.j_YOGURT_NEED) if J.ge(J.getv(J.getv(game.j_G, "stock"), "pickle"), game.j_PICKLE_NEED) else J.ge(J.getv(J.getv(game.j_G, "stock"), "pickle"), game.j_PICKLE_NEED))
	return null

func _closure_255(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_w: Variant = null
	v_w = J.getv(J.getv(game.j_G, "boards"), 0.0)
	return (J.ge(J.getv(v_w, "pickleN"), game.j_PICKLE_NEED) if J.truth(v_w) else v_w)
	return null

func _closure_256(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_w: Variant = null
	v_w = J.getv(J.getv(game.j_G, "boards"), 0.0)
	return (J.ge(J.getv(v_w, "yogurtN"), game.j_YOGURT_NEED) if J.truth(v_w) else v_w)
	return null

func _closure_257(_args: Array, _captures: Dictionary = {}) -> Variant:
	return ((((J.getv(J.getv(game.j_G, "cut"), "potato") if J.truth(J.getv(J.getv(game.j_G, "cut"), "potato")) else (not (not J.truth(J.getv(game.j_G, "flyP"))))) if (J.truth(J.getv(J.getv(game.j_G, "cut"), "potato")) or (not (not J.truth(J.getv(game.j_G, "flyP"))))) else J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0)) if ((J.truth(J.getv(J.getv(game.j_G, "cut"), "potato")) or (not (not J.truth(J.getv(game.j_G, "flyP"))))) or J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0)) else J.gt(J.getv(game.j_G, "friesTray"), 0.0)) if (((J.truth(J.getv(J.getv(game.j_G, "cut"), "potato")) or (not (not J.truth(J.getv(game.j_G, "flyP"))))) or J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0)) or J.gt(J.getv(game.j_G, "friesTray"), 0.0)) else J.gt(J.getv(J.getv(game.j_G, "fryer"), "load"), 0.0))
	return null

func _closure_258(_args: Array, _captures: Dictionary = {}) -> Variant:
	return ((J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0) if J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0) else J.gt(J.getv(J.getv(game.j_G, "fryer"), "load"), 0.0)) if (J.gt(J.getv(J.getv(game.j_G, "cut"), "raw"), 0.0) or J.gt(J.getv(J.getv(game.j_G, "fryer"), "load"), 0.0)) else J.gt(J.getv(game.j_G, "friesTray"), 0.0))
	return null

func _closure_259(_args: Array, _captures: Dictionary = {}) -> Variant:
	return J.gt(J.getv(game.j_G, "friesTray"), 0.0)
	return null

func _closure_260(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_w: Variant = null
	v_w = J.getv(J.getv(game.j_G, "boards"), 0.0)
	return (J.ge(J.getv(v_w, "friesN"), game.j_FRIES_NEED) if J.truth(v_w) else v_w)
	return null

func _closure_261(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_w: Variant = null
	v_w = J.getv(J.getv(game.j_G, "boards"), 0.0)
	return ((J.eq(J.getv(v_w, "state"), "rolled") if J.eq(J.getv(v_w, "state"), "rolled") else J.eq(J.getv(v_w, "state"), "ready")) if J.truth(v_w) else v_w)
	return null

func _closure_262(_args: Array, _captures: Dictionary = {}) -> Variant:
	var v_w: Variant = null
	v_w = J.getv(J.getv(game.j_G, "boards"), 0.0)
	return (J.eq(J.getv(v_w, "state"), "ready") if J.truth(v_w) else v_w)
	return null

func _closure_263(_args: Array, _captures: Dictionary = {}) -> Variant:
	return J.ge(J.getv(J.getv(game.j_G, "stat"), "wraps"), 1.0)
	return null

func _closure_264(_args: Array, _captures: Dictionary = {}) -> Variant:
	return J.gt(J.getv(game.j_G, "money"), 0.0)
	return null
