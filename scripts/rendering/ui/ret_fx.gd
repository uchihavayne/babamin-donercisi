# Reddedilen islem geri bildirimi (akicilik cilasi: "oyun bir islemi reddedince yalniz 'bad' sesi ve yazi var; nerede / neden belli degil").
# Oyuncu bir islem yapar, oyun reddeder (tezgah dolu, lavas yok, et yetmiyor, fritoz kapali ...): ses ve uyari yazisi (toast)
# zaten vardi. Simdi ayrica
#  1) islem noktasinin hemen ustunde kisa bir kirmizi X belirir, hafifce sallanip yukselerek solar;
#  2) ekranin altindaki uyari yazisi iki yana sallanir ("hayir" hareketi).
# SALT GORSEL: oyun durumu (G), rastgele sayi, girdi ve ses degismez; butun durum bu modulun alanlarindadir (kaydedilmez).
# Tetik: 'bad' sesi ile f_say ayni karede (iki sirayla da: islemi reddeden satirlar boyle yazilmis). Ferman cezasi, kedi, lider gibi
# OLAY cezalari f_say cagirmadigi icin tetiklemez (imlecin altinda anlamsiz bir X cikmasin). Yazisiz (sessiz) reddeden birkac satir
# f_ret()'i acikca cagirir. Anchor: islem noktasi (j_IN; kol / klavye kipinde secili istasyonun merkezi, select() imleci oraya tasir).
# Kanca adi "ret_fx": HD_KAPALI=ret_fx (ya da kapali_zorla) cizimi ve sallanmayi kapatir (sayaclar calismaya devam eder).
extends "res://scripts/core/game_module.gd"

const OMUR := 0.55                    # X'in omru (sn)
const SALLAN := 0.30                  # X'in sallanma suresi (sn)
const TEKRAR := 0.25                  # bu kadar sure icinde ayni X tekrar tetiklenmez (sn)
const YUKSELIS := 6.0                 # omru boyunca yukari kayma (mantiksal px)
const YUKARI := 11.0                  # X imlecin bu kadar ustunde belirir (parmak / imlec ortmesin)
const SALLAN_DESEN := [0, -2, 2, -2, 1, -1, 0, 0]   # X'in yatay sallanmasi (px; sabit desen, rastgele yok)
const TOAST_SURE := 0.32              # toast'in sallanma suresi (sn)
const TOAST_DESEN := [-3, 3, -3, 2, -2, 1, -1, 0]   # toast'in yatay sallanmasi (px)

var kapali_zorla := false

var _kare := 0
var _bad_kare := -1       # 'bad' sesinin son calindigi kare
var _say_kare := -1       # f_say'in son cagrildigi kare
var _tetik_kare := -1     # son tetik karesi (izleme / test)
var _t := -1.0            # X'in yasi (sn); < 0: yok
var _x := 0.0
var _y := 0.0
var _toast_t := -1.0      # toast sallanma yasi (sn); < 0: yok

func _gorunur() -> bool:
	return not kapali_zorla and not game._hd_kapali.has("ret_fx")

# j_SFX tablosundaki 'bad' sesini sarar: once buraya haber, sonra eski ses (ses davranisi aynen kalir)
func bagla(tablo: Dictionary) -> void:
	var eski: Variant = tablo.get("bad")
	if not (eski is Callable): return
	var ses: Callable = eski
	tablo["bad"] = func(a: Array = []) -> Variant:
		f_bad()
		return ses.call(a)

func f_bad() -> void:
	_bad_kare = _kare
	if _say_kare == _kare: _tetikle(true)

# session_system.f_say uyari yazisini kurunca cagirir
func f_soz() -> void:
	_say_kare = _kare
	if _bad_kare == _kare: _tetikle(true)

# yazisiz reddeden satirlar acikca cagirir (yalniz X; toast yok)
func f_ret() -> void:
	_tetikle(false)

func _tetikle(toast: bool) -> void:
	if game.j_G == null or str(game.j_G.scene) != "play": return
	# sallanma surerken tekrar tetik yok (basili tutulan / pespese reddedilen islem X'i yerinde dondurmasin)
	if _t >= 0.0 and _t < TEKRAR: return
	_tetik_kare = _kare
	_t = 0.0
	_x = clampf(float(game.j_IN.x), 8.0, float(game.j_W) - 8.0)
	_y = clampf(float(game.j_IN.y) - YUKARI, float(game.j_VIEW.top) + 10.0, float(game.j_H) - 10.0)
	if toast: _toast_t = 0.0

# kare basi (core/game_loop.gd f_frame)
func f_tick(dt: float) -> void:
	_kare += 1
	if _t >= 0.0:
		_t += dt
		if _t >= OMUR: _t = -1.0
	if _toast_t >= 0.0:
		_toast_t += dt
		if _toast_t >= TOAST_SURE: _toast_t = -1.0

# uyari yazisinin (toast) yatay sallanma payi (px; tam sayi); sallanma yoksa 0
func f_toastDx() -> float:
	if _toast_t < 0.0 or not _gorunur(): return 0.0
	var i: int = mini(int(_toast_t / TOAST_SURE * float(TOAST_DESEN.size())), TOAST_DESEN.size() - 1)
	return float(TOAST_DESEN[i])

func _x_konum() -> Vector2:
	var p: float = _t / OMUR
	var dy: float = -roundf(YUKSELIS * float(game.math_utils.f_easeOut(p)))
	var i: int = mini(int(_t / SALLAN * float(SALLAN_DESEN.size())), SALLAN_DESEN.size() - 1) if _t < SALLAN else SALLAN_DESEN.size() - 1
	return Vector2(roundf(_x) + float(SALLAN_DESEN[i]), roundf(_y) + dy)

# oyun sahnesinin en ustunde (game_draw.f_drawPlay sonu)
func f_ciz() -> void:
	if _t < 0.0 or not _gorunur(): return
	var p: float = _t / OMUR
	var a: float = 1.0 if p < 0.55 else clampf((1.0 - p) / 0.45, 0.0, 1.0)
	if a <= 0.0: return
	var k: Vector2 = _x_konum()
	var ctx: Variant = game.j_ctx
	J.setv(ctx, "globalAlpha", a)
	# koyu kontur: karisik arka planda da okunur
	for o in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
		game.icon_draw.f_drawX(k.x + o.x, k.y + o.y, "#1a0d0a")
	game.icon_draw.f_drawX(k.x, k.y, game.j_P.bad)
	J.setv(ctx, "globalAlpha", 1.0)
