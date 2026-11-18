# Haptik geri bildirim (birlesik surum, 12. tur, akicilik cilasi: "haptik geri bildirim henuz oyunda yok").
# Her ses olayi (j_SFX) varsa kendi titresim desenini de tetikler: tek baglanti noktasi (bagla), oyun kodunun
# yuzlerce J.method(game.j_SFX, "ad") cagrisi aynen kalir. Telefonda Input.vibrate_handheld, oyun kolunda
# Input.start_joy_vibration; masaustunde fare / klavyeyle hicbir sey yapmaz. Kullanici ayarindan kapatilabilir
# (platform_shell "Titresim", cihaz ayarlarinda saklanir). Ambiyans sesleri (yagmur, motor, korna, kizartma
# dongusu...) bilincli olarak titresmez.
extends "res://scripts/core/game_module.gd"

# ses adi -> darbeler [[sure_ms, genlik 0..1], ...]; negatif sure = bosluk (ms)
const DESEN := {
	# arayuz
	"ui": [[8, 0.25]], "uiBack": [[8, 0.2]], "tick": [[5, 0.12]],
	# tutma / birakma / hazirlik
	"pick": [[10, 0.3]], "drop": [[14, 0.42]], "plate": [[10, 0.28]], "wrap": [[9, 0.25]], "roll": [[8, 0.2]],
	"scoop": [[9, 0.25]], "squirt": [[9, 0.25]], "sack": [[18, 0.4]], "basket": [[16, 0.4]], "sizzle": [[10, 0.22]],
	"chop": [[7, 0.22]], "slice": [[7, 0.2]], "potato": [[8, 0.25]], "knife": [[8, 0.25]],
	"pop": [[5, 0.12]], "crinkle": [[5, 0.12]], "glass": [[9, 0.28]], "drawer": [[16, 0.38]], "door": [[12, 0.3]],
	"shutter": [[20, 0.5]],
	# kazanc / teslim
	"serve": [[14, 0.42]], "coin": [[5, 0.18]], "ding": [[10, 0.3]], "bell": [[14, 0.4]],
	"cash": [[10, 0.38], [-40, 0], [12, 0.5]],
	"levelup": [[10, 0.35], [-55, 0], [12, 0.5], [-55, 0], [16, 0.7]],
	"fanfare": [[14, 0.45], [-60, 0], [14, 0.55], [-60, 0], [26, 0.85]],
	# olumsuz / uyari
	"bad": [[26, 0.75], [-55, 0], [26, 0.75]], "warn": [[18, 0.55], [-60, 0], [18, 0.55]],
	"fail": [[70, 1.0]], "angry": [[36, 0.85]], "fine": [[55, 0.9]], "slam": [[45, 1.0]], "stamp": [[38, 0.9]],
	"phone": [[40, 0.6], [-80, 0], [40, 0.6]],
}
const MIN_ARALIK := 0.09      # ayni ses adi icin en az saniye (tekrarli olaylarda titresim firtinasi olmasin)
const DARBE_ARASI := 0.025    # arka arkaya iki darbe / desen arasi bosluk (sn)
const KUYRUK_TAVAN := 0.30    # bu kadar saniyeden fazla ilerideki darbe atilir (birikme / gecikmis titresim olmasin)

var acik := true              # kullanici ayari
var backend := Callable()     # testte: func(ms: int, genlik: float) -> void; bos = gercek aygit
var _saat := 0.0              # tick ile ilerleyen oyun zamani (deterministik)
var _bos := 0.0               # son planlanan darbenin bitisi
var _kuyruk: Array = []       # [baslangic_saat, ms, genlik]
var _son: Dictionary = {}     # ses adi -> son tetik saati

# j_SFX tablosundaki her desenli sesi, once titresim sonra eski ses olacak sekilde sarar (ses davranisi aynen kalir)
func bagla(tablo: Dictionary) -> void:
	for ad in DESEN:
		var eski: Variant = tablo.get(ad)
		if not (eski is Callable): continue
		var ad_: String = ad
		var ses: Callable = eski
		tablo[ad] = func(a: Array = []) -> Variant:
			darbe(ad_)
			return ses.call(a)

# titresim cihazi var mi? (kol secili, dokunmatik kip ya da mobil dis aktarim; testte arka uc)
func aygit_var() -> bool:
	if backend.is_valid(): return true
	var c: Variant = game.get("controls")
	if c != null and str(c.mode) == "controller" and int(c.device) >= 0: return true
	return OS.has_feature("mobile") or (c != null and str(c.mode) == "touch")

func darbe(ad: String) -> void:
	if not acik: return
	var d: Variant = DESEN.get(ad)
	if d == null or not aygit_var(): return
	if _saat - float(_son.get(ad, -10.0)) < MIN_ARALIK: return
	var t := maxf(_saat, _bos)
	if t - _saat > KUYRUK_TAVAN: return
	_son[ad] = _saat
	for p in d:
		var ms := int(p[0])
		if ms < 0:
			t += float(-ms) / 1000.0
			continue
		_kuyruk.append([t, ms, float(p[1])])
		t += float(ms) / 1000.0
	_bos = t + DARBE_ARASI
	_isle()

func tick(dt: float) -> void:
	_saat += dt
	_isle()

func _isle() -> void:
	while not _kuyruk.is_empty() and float(_kuyruk[0][0]) <= _saat + 0.0001:
		var p: Array = _kuyruk.pop_front()
		_yolla(int(p[1]), float(p[2]))

func _yolla(ms: int, genlik: float) -> void:
	if backend.is_valid():
		backend.call(ms, genlik)
		return
	var c: Variant = game.get("controls")
	if c != null and str(c.mode) == "controller" and int(c.device) >= 0:
		# kol motorlari: kisa darbe algilanmaz, en az 40 ms; zayif motor daha yumusak
		Input.start_joy_vibration(int(c.device), genlik * 0.5, genlik, maxf(float(ms), 40.0) / 1000.0)
	elif OS.has_feature("mobile") or (c != null and str(c.mode) == "touch"):
		# cok kisa darbeler cihazlarca yutulur: en az 10 ms; genlik 0.05 - 1
		Input.vibrate_handheld(maxi(ms, 10), clampf(genlik, 0.05, 1.0))

# bekleyen darbeleri iptal eder (mola / gun sonu / uygulama arka plana gidince titresim surmesin)
func sustur() -> void:
	_kuyruk.clear()
