# Hikaye kartlari arayuzu (birlesik surum, 12. tur): gun sonu ekraninda cikan kisa yazi karti. Mantik / sira: systems/events/hikaye_system.gd,
# metinler data/hikaye.gd. Satirlar sirayla belirir; hepsi gorununce TAMAM (karta basmak satirlari hemen gosterir).
extends "res://scripts/core/game_module.gd"

const TEMA := {
	"resmi": {"kagit": "#dfe3e8", "kenar": "#aab2bd", "serit": "#4a5a70", "murekkep": "#2a3038", "cizgi": "#9aa2ad"},
	"mektup": {"kagit": "#ece5cf", "kenar": "#c0b89e", "serit": "#8e1c14", "murekkep": "#3a3630", "cizgi": "#8a8370"},
	"baba": {"kagit": "#f4e6c0", "kenar": "#d9c690", "serit": "#b0862a", "murekkep": "#3a2a1c", "cizgi": "#c9b88f"},
}
const SATIR_ARA := 0.55   # satirlarin birbiri ardina belirme araligi (sn)

var _kimlik := ""
var _t := 0.0

func _ikon(tur: String, x: float, y: float) -> void:
	match tur:
		"resmi":   # kirmizi muhur
			game.f_rrect(x, y, 15.0, 15.0, 2.0, "#a8281e")
			game.f_rrectOut(x, y, 15.0, 15.0, 2.0, "#6e1710")
			game.f_rrectOut(x + 2.0, y + 2.0, 11.0, 11.0, 1.0, "#e8a898")
			game.f_fr(x + 5.0, y + 5.0, 5.0, 5.0, "#e8a898")
		"mektup":   # zarf
			game.f_fr(x, y + 2.0, 17.0, 12.0, "#a89878")
			game.f_fr(x + 1.0, y + 3.0, 15.0, 10.0, "#f2ead2")
			for i in 7:
				game.f_fr(x + 1.0 + float(i), y + 3.0 + float(i) * 0.7, 1.0, 1.0, "#a89878")
				game.f_fr(x + 15.0 - float(i), y + 3.0 + float(i) * 0.7, 1.0, 1.0, "#a89878")
		_:   # baba: altin yildiz
			game.tarif_draw.f_yildiz(x, y, game.tarif_draw.ALTIN, 2.0)

func f_drawKart(p_t: Variant = null) -> Variant:
	var H: Dictionary = game.hikaye_system.f_kart()
	if H.is_empty(): return null
	var tur: String = str(H.get("tur", "mektup"))
	var M: Dictionary = TEMA.get(tur, TEMA.mektup)
	var satir: Array = H.get("satir", [])
	if str(H.id) != _kimlik:
		_kimlik = str(H.id)
		_t = 0.0
		J.method(game.j_SFX, "stamp" if tur == "resmi" else "ui", [])
	_t += 1.0 / 60.0
	# TAMAM yalniz karenin BASINDA tum satirlar zaten gorunuyorsa tiklanabilir; karta basmak satirlari hemen gosterir (ayni basis
	# TAMAM'i da tiklamaz: okumadan kapanmasin)
	var bitti: bool = _t >= 0.6 + float(satir.size()) * SATIR_ARA
	if not bitti and J.truth(J.getv(game.j_IN, "pressed")) and _t > 0.15:
		_t = 0.6 + float(satir.size()) * SATIR_ARA
	var w := 304.0
	var h: float = 68.0 + float(satir.size()) * 14.0
	var x: float = floorf((float(game.j_W) - w) / 2.0)
	var y: float = floorf((float(game.j_H) - h) / 2.0) - 6.0   # alttaki basarim bildirimi (y ~212+) TAMAM'in ustune binmesin
	game.modal_fx.f_dim(0.84, "#0d0a08")
	game.modal_fx.f_basla("hikaye")
	game.interface_draw.f_panel(x, y, w, h, str(H.baslik))
	var px: float = x + 14.0
	var py: float = y + 18.0
	var pw: float = w - 28.0
	var ph: float = 18.0 + float(satir.size()) * 14.0
	J.setv(game.j_ctx, "globalAlpha", 0.4)
	game.f_fr(px + 3.0, py + 3.0, pw, ph, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(px, py, pw, ph, str(M.kenar))
	game.f_fr(px + 1.0, py + 1.0, pw - 2.0, ph - 2.0, str(M.kagit))
	game.f_fr(px, py, pw, 3.0, str(M.serit))
	_ikon(tur, px + pw - 24.0, py + 8.0)
	for i in satir.size():
		var ry: float = py + 12.0 + float(i) * 14.0
		var a: float = clampf((_t - 0.4 - float(i) * SATIR_ARA) * 3.0, 0.0, 1.0)
		if a <= 0.0: continue
		J.setv(game.j_ctx, "globalAlpha", a)
		var kayma: float = floorf((1.0 - a) * 8.0)
		game.text_draw.f_txt(str(satir[i]), px + 12.0 - kayma, ry, str(M.murekkep), {"maxw": pw - 48.0 if i < 2 else pw - 24.0})
		J.setv(game.j_ctx, "globalAlpha", 0.35 * a)
		game.f_hl(px + 8.0, ry + 10.0, pw - 16.0, str(M.cizgi))
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	if bitti and game.f_button(x + w / 2.0 - 36.0, y + h - 26.0, 72.0, 18.0, "TAMAM", "#3f8a4a", true):
		J.method(game.j_SFX, "ui", [])
		game.hikaye_system.f_kartKapat()
	game.modal_fx.f_bitir()
	return null
