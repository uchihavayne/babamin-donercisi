# Icra arayuzu (birlesik surum, 12. tur): sabah memur karti (dukkan sahnesi), dukkan cubugundaki "icra yaklasiyor" uyarisi,
# oyun ici sayac etiketi ve gun sonu taksit satiri. Mantik: systems/events/icra_system.gd (durum G.icra).
extends "res://scripts/core/game_module.gd"

const KAGIT := "#ece5cf"
const KENAR := "#c0b89e"
const MUREKKEP := "#3a3630"
const KIRMIZI := "#8e1c14"
const YESIL := "#2f6a3a"
const BORC := "#a83a2a"

var _kart_gun := -1.0   # kartin ses / sarsinti ile acildigi gun (her karta bir kez)
var _kart_t := 0.0      # kart acilali gecen sure (sn)

func _para(v: float) -> String:
	return "$" + str(game.math_utils.f_fmtMoney(v))

# ---------------------------------------------------------------- sabah memur karti
func f_drawKart(p_t: Variant = null) -> Variant:
	var I: Dictionary = game.icra_system.f_durum()
	var S: Variant = I.get("sonuc")
	if not (S is Dictionary): return null
	if _kart_gun != J.n(S.gun):
		_kart_gun = J.n(S.gun)
		_kart_t = 0.0
		match str(S.durum):
			"muhur":
				J.method(game.j_SFX, "shutter", [])
				game.effects.f_shake(0.45)
				game.effects.f_flash(0.2, "#ff4a3a")
			"ihtar":
				J.method(game.j_SFX, "bad", [])
				game.effects.f_shake(0.25)
			_:
				J.method(game.j_SFX, "cash", [])
	_kart_t += 1.0 / 60.0
	var durum: String = str(S.durum)
	var w := 304.0
	var h := 196.0
	var x: float = floorf((float(game.j_W) - w) / 2.0)
	var y: float = 18.0   # yukarida: alttaki basarim bildirimi (y ~212+) dugmenin ustune binmesin
	game.modal_fx.f_dim(0.84, "#0d0a08")
	game.modal_fx.f_basla("icra")
	game.interface_draw.f_panel(x, y, w, h, "İCRA MEMURU")
	var cx: float = x + w / 2.0
	game.text_draw.f_txt("HAFTALIK HESAP", cx, y + 19.0, J.getv(game.j_P, "ui4"), {"align": "c"})
	# kagit bildirim
	var px: float = x + 14.0
	var py: float = y + 31.0
	var pw: float = w - 28.0
	var satir := 12.0
	var kalem: Array = [["İstenen taksit", _para(J.n(S.istenen)), MUREKKEP], ["Kasadan alınan", _para(J.n(S.odenen)), YESIL]]
	if J.n(S.eksik) > 0.0 and durum != "tamam":
		kalem.append(["Eksik kalan", _para(J.n(S.eksik)), BORC])
		if J.n(S.zam) > 0.0: kalem.append(["Gecikme zammı", "+" + _para(J.n(S.zam)), BORC])
	kalem.append(["Kalan borç", _para(J.n(J.getv(game.j_G, "debt"))), MUREKKEP])
	var ph: float = 10.0 + float(kalem.size()) * satir
	J.setv(game.j_ctx, "globalAlpha", 0.4)
	game.f_fr(px + 3.0, py + 3.0, pw, ph, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_fr(px, py, pw, ph, KENAR)
	game.f_fr(px + 1.0, py + 1.0, pw - 2.0, ph - 2.0, KAGIT)
	game.f_fr(px, py, pw, 3.0, KIRMIZI)
	var ry: float = py + 7.0
	for k in kalem:
		game.text_draw.f_txt(str(k[0]), px + 8.0, ry, MUREKKEP)
		game.text_draw.f_txt(str(k[1]), px + pw - 8.0, ry, str(k[2]), {"align": "r"})
		J.setv(game.j_ctx, "globalAlpha", 0.3)
		game.f_hl(px + 6.0, ry + 9.0, pw - 12.0, "#8a8370")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		ry += satir
	# durum seridi
	var by: float = py + ph + 7.0
	var bh := 18.0
	var bw: float = pw
	if durum == "muhur":
		game.f_fr(px, by, bw, bh, "#2a2418")
		var sx := 0.0
		var i := 0
		while sx < bw:
			if i % 2 == 0: game.f_fr(px + sx, by, minf(8.0, bw - sx), 3.0, "#e8b420"); game.f_fr(px + sx, by + bh - 3.0, minf(8.0, bw - sx), 3.0, "#e8b420")
			sx += 8.0
			i += 1
		game.f_fr(px + 4.0, by + 3.0, bw - 8.0, bh - 6.0, "#7a1810")
		game.text_draw.f_txt("KEPENK MÜHÜRLENDİ", cx, by + 5.0, "#ffe9a0", {"align": "c", "shadow": 1.0})
	elif durum == "ihtar":
		game.f_fr(px, by, bw, bh, "#7a1810")
		game.f_fr(px + 1.0, by + 1.0, bw - 2.0, bh - 2.0, "#b83228")
		game.text_draw.f_txt("İHTAR!", cx, by + 5.0, "#fff2d8", {"align": "c", "shadow": 1.0})
	else:
		game.f_fr(px, by, bw, bh, "#1f4a2a")
		game.f_fr(px + 1.0, by + 1.0, bw - 2.0, bh - 2.0, "#2f7a3e")
		game.text_draw.f_txt("HESAP TAMAM", cx, by + 5.0, "#e8ffe0", {"align": "c", "shadow": 1.0})
	# memurun sozu
	var soz: String = "Hesap tamam usta. Haftaya yine uğrarım." if (durum == "tamam" and bool(S.get("ilk", false))) else "Hesap tamam. Haftaya görüşürüz."
	var not_: String = ""
	if durum == "ihtar":
		soz = "Kasa yetmedi. Bu bir ihtar."
		not_ = "Haftaya aynısı olursa kepenk mühürlenir."
	elif durum == "muhur":
		soz = "Üst üste iki hafta. Mühür vuruldu."
		not_ = str(game.localization.f_T("Kapalı kalacak gün: ")) + str(int(J.n(S.atla)))
	var sy: float = by + bh + 8.0
	for l in game.tarif_draw.satirlara(str(game.localization.f_T(soz)), pw - 8.0, 2):
		game.text_draw.f_txt(str(l), cx, sy, J.getv(game.j_P, "ink"), {"align": "c"})
		sy += 9.0
	if not_ != "":
		for l in game.tarif_draw.satirlara(str(game.localization.f_T(not_)), pw - 8.0, 2):
			game.text_draw.f_txt(str(l), cx, sy + 2.0, "#e2604f" if durum == "muhur" else J.getv(game.j_P, "ui4"), {"align": "c"})
			sy += 9.0
	if _kart_t > 0.5 and game.f_button(cx - 36.0, y + h - 24.0, 72.0, 18.0, "TAMAM", "#3f8a4a", true):
		J.method(game.j_SFX, "ui", [])
		game.icra_system.f_kartKapat()
		game.shop_draw.f_gunBaslat()   # gun, memur karti kapaninca baslar (kepenk muhru varsa kaybedilen gunler de atlanir)
	game.modal_fx.f_bitir()
	return null

# "icra yarin sabah" / "icra N gun sonra" (dukkan cubugu ve oyun ici etiket ayni metni kullanir)
func f_etiket(k: int) -> String:
	if k <= 1: return str(game.localization.f_T("İCRA YARIN SABAH"))
	return str(game.localization.f_T("İCRA ")) + str(k) + str(game.localization.f_T(" GÜN SONRA"))

# ---------------------------------------------------------------- dukkan cubugu uyarisi
# icra yaklasirken (en cok 2 sabah) dukkanda: "icra yarin sabah: kasada $X kalmali". Kasa yetmiyorsa kirmizi.
# (x, y): sol ust; cubugun hemen altina / ustune cagiran yerlestirir. Dondurur: kullanilan yukseklik (0 = cizilmedi).
func f_dukkanUyari(y: float, t: Variant = null) -> float:
	if not game.icra_system.f_yaklasti(2): return 0.0
	var k: int = game.icra_system.f_kalanGun()
	var gerek: float = game.icra_system.f_birikim()
	var para: float = J.n(J.getv(game.j_G, "money"))
	var yeter: bool = para >= gerek
	var etiket: String = f_etiket(k)
	var sag: String = str(game.localization.f_T("kasada kalmalı: ")) + _para(gerek)
	var w: float = J.n(game.f_textW(etiket)) + J.n(game.f_textW(sag)) + 22.0
	var x: float = floorf((float(game.j_W) - w) / 2.0)
	var puls: float = 0.5 + 0.5 * sin(J.n(t) * 6.0)
	var zemin := "#3a1410" if not yeter else "#2a2418"
	var cerceve := "#e2483a" if not yeter else "#b0862a"
	J.setv(game.j_ctx, "globalAlpha", 0.92)
	game.f_rrect(x, y, w, 13.0, 4.0, zemin)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if not yeter and k <= 1:
		J.setv(game.j_ctx, "globalAlpha", 0.35 + 0.4 * puls)
		game.f_rrectOut(x - 1.0, y - 1.0, w + 2.0, 15.0, 5.0, "#ff6a4a")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrectOut(x, y, w, 13.0, 4.0, cerceve)
	game.text_draw.f_txt(etiket, x + 7.0, y + 3.0, "#ff9a8a" if not yeter else "#ffd75e")
	game.text_draw.f_txt(sag, x + w - 7.0, y + 3.0, "#ffd0c0" if not yeter else "#e8e2d0", {"align": "r"})
	return 14.0

# ---------------------------------------------------------------- oyun ici etiket (HUD)
# borc kutusunun altinda kucuk "ICRA 2g" etiketi; kasa birikimi karsilamiyorsa kirmizi. (x, y) sol ust.
func f_hudEtiket(x: float, y: float, t: Variant = null) -> void:
	if not game.icra_system.f_yaklasti(3): return
	var k: int = game.icra_system.f_kalanGun()
	var yeter: bool = game.icra_system.f_yeterli()
	var metin: String = f_etiket(k)
	var w: float = J.n(game.f_textW(metin)) + 10.0
	var kalin: bool = (not yeter) and k <= 1
	J.setv(game.j_ctx, "globalAlpha", 0.55 + (0.3 * sin(J.n(t) * 6.0) if kalin else 0.2))
	game.f_rrect(x, y, w, 11.0, 3.0, "#3a1410" if not yeter else "#2a2418")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrectOut(x, y, w, 11.0, 3.0, "#e2483a" if not yeter else "#b0862a")
	game.text_draw.f_txt(metin, x + 5.0, y + 2.0, "#ff9a8a" if not yeter else "#ffd75e")
