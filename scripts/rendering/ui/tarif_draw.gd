# Baba'nin Defteri arayuzu (birlesik surum, 12. tur): dukkandaki defter paneli, gun sonu
# "yeni sayfa" karti, siparis yildizi ve dukkan cubugundaki defter dugmesi. Mantik: tarif_system.gd.
extends "res://scripts/core/game_module.gd"

const ALTIN := "#ffd24a"
const ALTIN_BOS := "#c9b88f"
const SAYFA := "#f4e6c0"
const SATIR := "#dccb9f"
const KENAR := "#d9776a"
const MUREKKEP := "#3a2a1c"
const NOT_RENGI := "#5b4630"
const SOL := 30.0   # sayfada kirmizi kenar cizgisinin sagindaki yazi basi

# 7x7 piksel altin yildiz (siparis balonu, hazirlik seridi, defter); olcek 2 = 14x14. (x, y) = sol ust.
func f_yildiz(x: float, y: float, renk: String = ALTIN, olcek: float = 1.0) -> void:
	var xi := floorf(x)
	var yi := floorf(y)
	# satir araliklari: (baslangic, uzunluk) ya da iki aralik (baslangic, uzunluk, baslangic, uzunluk)
	var satir := [[3, 1], [2, 3], [0, 7], [1, 5], [2, 3], [1, 2, 4, 2], [1, 1, 5, 1]]
	for gecis in 2:   # once koyu golge (1 px sag-alt), sonra govde
		var kayma := 1.0 if gecis == 0 else 0.0
		var c: String = "#3a2410" if gecis == 0 else renk
		for r in satir.size():
			var s: Array = satir[r]
			game.f_fr(xi + float(s[0]) * olcek + kayma, yi + float(r) * olcek + kayma, float(s[1]) * olcek, olcek, c)
			if s.size() == 4: game.f_fr(xi + float(s[2]) * olcek + kayma, yi + float(r) * olcek + kayma, float(s[3]) * olcek, olcek, c)
	game.f_fr(xi + 3.0 * olcek, yi + 2.0 * olcek, olcek, olcek, "#fff2b0")

# metni en cok `maxw` px genisliginde, en cok `maks` satira boler (fazlasi "…" ile kesilir)
func satirlara(metin: String, maxw: float, maks: int) -> Array:
	var satirlar: Array = []
	var cur := ""
	# imza ("— Baba") yalniz basina satira dusmesin: "—" bir sonraki kelimeyle ayni parca sayilir
	var kelimeler: Array = []
	var parca := metin.split(" ", false)
	var pi := 0
	while pi < parca.size():
		if parca[pi] == "—" and pi + 1 < parca.size():
			kelimeler.append(parca[pi] + " " + parca[pi + 1])
			pi += 2
		else:
			kelimeler.append(parca[pi])
			pi += 1
	for k in kelimeler:
		var dene: String = k if cur == "" else cur + " " + k
		if float(game.f_textW(dene)) <= maxw:
			cur = dene
		else:
			if cur != "": satirlar.append(cur)
			cur = k
	if cur != "": satirlar.append(cur)
	if satirlar.size() > maks:
		satirlar = satirlar.slice(0, maks)
		satirlar[maks - 1] = game.text_draw.kisalt(str(satirlar[maks - 1]) + "…", maxw)
	return satirlar

# tarifin siparis kalemleri (durum + ek urunler) ve istenmeyen malzeme rozetleri; (x, y) = ilk hucre merkezi
func ciz_kalemler(id: String, x: float, y: float, t: float) -> float:
	var T = game.tarif_system
	var kalemler: Array = [T.f_siparisKalemi(id)]
	kalemler.append_array(T.f_ekKalemler(id))
	var hucre := float(game.order_draw.SIP_HUCRE)
	var cx := x
	for k in kalemler:
		game.order_draw.order_icon(k, cx, y, t)
		cx += hucre
	var yok: Array = kalemler[0].get("yok", [])
	var bx: float = x + 26.0 + float(kalemler.size() - 1) * hucre
	for m in yok:
		game.order_draw.order_badge(str(m), bx, y, true)
		bx += 16.0
	return bx

# defter dugmesi: dukkan cubugunda 20x17 simge dugmesi; okunmamis sayfa varsa kirmizi "!" noktasi
func f_dugme(x: float, y: float, t: float) -> bool:
	var okunmamis: bool = game.tarif_system.f_okunmamis() > 0
	var basildi: bool = J.truth(game.f_button(x, y, 20.0, 17.0, "", "#8a5a2a", okunmamis))
	# kapakli defter: koyu kapak + kagit sayfa + sol cilt + altin yildiz
	game.f_rrect(x + 5.0, y + 3.0, 11.0, 11.0, 1.0, "#3a2210")
	game.f_fr(x + 6.0, y + 4.0, 9.0, 9.0, "#f4e6c0")
	game.f_fr(x + 6.0, y + 4.0, 2.0, 9.0, "#7a4a22")
	f_yildiz(x + 8.0, y + 6.0)
	if okunmamis:
		var pz: float = 0.5 + 0.5 * sin(t * 6.0)
		J.setv(game.j_ctx, "globalAlpha", 0.45 + 0.35 * pz)
		game.f_disc(x + 17.0, y + 3.0, 4.0 + pz, "#ffd75e")
		J.setv(game.j_ctx, "globalAlpha", 1.0)
		game.f_disc(x + 17.0, y + 3.0, 3.0, "#c8321e")
		game.text_draw.f_txt("!", x + 17.0, y + 0.0, "#ffffff", {"align": "c"})
	return basildi

# defter kagidi: golge, kenar, sayfa, kirmizi kenar cizgisi, spiral delikleri
func _sayfa(x: float, y: float, w: float, h: float) -> void:
	J.setv(game.j_ctx, "globalAlpha", 0.3)
	game.f_rrect(x + 1.0, y + 2.0, w, h, 3.0, "#000")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.f_rrect(x, y, w, h, 3.0, J.getv(game.j_P, "ui4"))
	game.f_rrect(x + 1.0, y + 1.0, w - 2.0, h - 2.0, 2.0, SAYFA)
	game.f_fr(x + 22.0, y + 2.0, 1.0, h - 4.0, KENAR)
	var hy := y + 9.0
	while hy < y + h - 6.0:
		game.f_disc(x + 9.0, hy, 2.0, "#7d603a")
		game.f_disc(x + 9.0, hy - 1.0, 1.0, "#2b1f14")
		hy += 20.0

# 3 yildiz + siradaki yildiza ilerleme cubugu (x = sol, w = satir genisligi)
func _ustalik(id: String, x: float, y: float, w: float) -> void:
	var T = game.tarif_system
	var n: int = T.f_servis(id)
	var usta: int = T.f_usta(id)
	for s in 3: f_yildiz(x + float(s) * 9.0, y - 1.0, ALTIN if s < usta else ALTIN_BOS)
	if usta >= 3:
		game.text_draw.f_txt("USTA", x + w, y, "#8a5a1a", {"align": "r"})
		return
	var esikler: Array = T.USTA_ESIK
	var onceki: int = int(esikler[usta - 1]) if usta > 0 else 0
	var sonraki: int = int(esikler[usta])
	var etiket: String = str(n) + " / " + str(sonraki)
	var ew: float = float(game.f_textW(etiket))
	var bx: float = x + 32.0
	var bw: float = maxf(20.0, w - 32.0 - ew - 6.0)
	game.f_rrect(bx, y, bw, 7.0, 2.0, "#7d603a")
	game.f_rrect(bx + 1.0, y + 1.0, bw - 2.0, 5.0, 1.0, "#d9c79d")
	var oran: float = clampf(float(n - onceki) / float(maxi(1, sonraki - onceki)), 0.0, 1.0)
	if oran > 0.0: game.f_rrect(bx + 1.0, y + 1.0, maxf(3.0, floorf((bw - 2.0) * oran)), 5.0, 1.0, ALTIN)
	game.text_draw.f_txt(etiket, x + w, y, NOT_RENGI, {"align": "r"})

# "Gerekli: ..." satirlari (en cok 2); yoksa bos dizi. Cevrilmis metin.
func _gerekli(id: String, w: float) -> Array:
	var eks: Array = game.tarif_system.f_eksikler(id)
	if eks.is_empty(): return []
	return satirlara(str(game.localization.f_T("Gerekli: ")) + ", ".join(eks), w, 2)

# "Hazır" ya da "Gerekli: ..." (en cok 2 satir). Kullanilan yuksekligi dondurur.
func _durum(id: String, x: float, y: float, w: float) -> float:
	var satirlar: Array = _gerekli(id, w)
	if satirlar.is_empty():
		game.text_draw.f_txt("Hazır", x, y, "#2f7a3a")
		return 9.0
	var sy := y
	for l in satirlar:
		game.text_draw.f_txt(str(l), x, sy, "#a83a2a")
		sy += 9.0
	return sy - y

# ---------------------------------------------------------------- defter paneli (dukkan)
func ac() -> void:
	var P: Dictionary = game.j_TARIFP
	P.open = true
	# ilk acilista okunmamis ilk sayfa, yoksa son bulunan sayfa
	var d: Dictionary = game.tarif_system.f_durum()
	var sec := 0
	var liste: Array = game.tarif_system.f_liste()
	for i in liste.size():
		var id := str(liste[i].id)
		if id in d.bulunan:
			sec = i
			if not (id in d.gorulen): break
	P.sec = sec

func f_drawDefter(p_t: Variant = null) -> Variant:
	var t: float = J.n(p_t)
	var T = game.tarif_system
	var liste: Array = T.f_liste()
	var P: Dictionary = game.j_TARIFP
	var kk: Variant = game.interface_draw.f_panelKutu(18.0, 242.0)
	var y: float = J.n(J.getv(kk, 0))
	var h: float = J.n(J.getv(kk, 1))
	var w := 324.0
	var x: float = floorf((float(game.j_W) - w) / 2.0)
	var dar: bool = h < 232.0
	J.setv(game.j_ctx, "globalAlpha", 0.82)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	game.interface_draw.f_panel(x, y, w, h, "BABA'NIN DEFTERİ")
	var d: Dictionary = T.f_durum()
	# sekmeler: 2 satir x 4 sutun, yalniz sayfa numarasi (dilden bagimsiz) + usta yildizlari / kilit
	var tw := 66.0
	var gap := 4.0
	var x0: float = x + (w - (4.0 * tw + 3.0 * gap)) / 2.0
	var tsat: float = 16.0 if dar else 17.0
	var ty0: float = y + (11.0 if dar else 14.0)
	for i in liste.size():
		var id := str(liste[i].id)
		var bulundu: bool = id in d.bulunan
		var tx: float = x0 + float(i % 4) * (tw + gap)
		var ty: float = ty0 + float(i / 4) * tsat
		if game.f_button(tx, ty, tw, tsat - 2.0, str(i + 1), "#b0862a" if bulundu else "#5a4c3e", false):
			P.sec = i
			J.method(game.j_SFX, "ui", [])
		if int(P.sec) == i: game.f_rrectOut(tx - 1.0, ty - 1.0, tw + 2.0, tsat, 3.0, ALTIN)
		if bulundu:
			for s in T.f_usta(id): f_yildiz(tx + 4.0 + float(s) * 8.0, ty + 3.0)
			if not (id in d.gorulen) and int(P.sec) != i:
				game.f_disc(tx + tw - 5.0, ty + 3.0, 3.0, "#c8321e")
		else:
			game.f_rrect(tx + 4.0, ty + 5.0, 7.0, 6.0, 1.0, "#2a2018")   # kilit
			game.f_fr(tx + 5.0, ty + 2.0, 1.0, 3.0, "#2a2018")
			game.f_fr(tx + 9.0, ty + 2.0, 1.0, 3.0, "#2a2018")
			game.f_fr(tx + 5.0, ty + 2.0, 5.0, 1.0, "#2a2018")
	# secili sayfa
	var kx := x + 12.0
	var kw := w - 24.0
	var ky: float = ty0 + 2.0 * tsat + 3.0
	var kh: float = (y + h - 26.0) - ky
	_sayfa(kx, ky, kw, kh)
	var ix: float = kx + SOL
	var maxw: float = kw - SOL - 10.0
	if not liste.is_empty():
		var sec: int = clampi(int(P.sec), 0, liste.size() - 1)
		var tf: Dictionary = liste[sec]
		var id := str(tf.id)
		if id in d.bulunan:
			T.f_gorulduIsaretle(id)
			game.text_draw.f_txt(game.text_draw.kisalt(str(game.localization.f_T(str(tf.ad))), maxw), ix, ky + 6.0, MUREKKEP)
			game.f_hl(ix, ky + 16.0, maxw, SATIR)
			ciz_kalemler(id, ix + 10.0, ky + 30.0, t)
			# defter cizgileri: Baba'nin notunun satirlari + sayfanin bos kismi (alt blokun ustune kadar)
			var kb: float = ky + kh - 6.0
			var ry := ky + 53.0
			while ry < maxf(kb - 50.0, ky + 72.0):
				game.f_hl(ix, ry, maxw, SATIR)
				ry += 9.0
			# Baba'nin notu: en cok 3 satir
			var sy := ky + 45.0
			for l in satirlara(str(game.localization.f_T(str(tf.mesaj))), maxw, 3):
				game.text_draw.f_txt(str(l), ix, sy, NOT_RENGI)
				sy += 9.0
			# alt blok (alttan yukari): fiyat / servis, ustalik, durum
			var fiyat: float = floorf(float(game.recipe_system.f_itemPrice({"kind": "wrap", "sauce": tf.get("sos"), "grilled": T.f_izgaraAcik()}, game.j_G)) * T.f_carpan(id) + 0.5)
			game.text_draw.f_txt(str(game.localization.f_T("Fiyat: $")) + str(int(fiyat)), ix, kb - 9.0, MUREKKEP)
			game.text_draw.f_txt(str(game.localization.f_T("Servis: ")) + str(T.f_servis(id)), ix + maxw, kb - 9.0, MUREKKEP, {"align": "r"})
			_ustalik(id, ix, kb - 22.0, maxw)
			var gs: int = maxi(1, _gerekli(id, maxw).size())
			_durum(id, ix, kb - 24.0 - 9.0 * float(gs), maxw)
		else:
			game.text_draw.f_txt("Kilitli sayfa", ix, ky + 6.0, "#8a7358")
			game.f_hl(ix, ky + 16.0, maxw, SATIR)
			for i in 3:   # okunamayan karalamalar
				game.f_fr(ix, ky + 30.0 + float(i) * 9.0, maxw * (0.92 - 0.2 * float(i)), 3.0, "#e3d4ab")
			game.text_draw.f_txt(str(game.localization.f_T("Bulunacağı gün: ")) + str(int(tf.gun)), ix, ky + kh - 15.0, "#a83a2a")
	if game.f_button(x + w / 2.0 - 40.0, y + h - 22.0, 80.0, 18.0, "KAPAT", J.getv(game.j_P, "red1"), true):
		P.open = false
		J.method(game.j_SFX, "uiBack", [])
	return null

# ---------------------------------------------------------------- gun sonu: yeni sayfa karti
func f_drawYeniSayfa(_p_t: Variant = null) -> Variant:
	var T = game.tarif_system
	var id: String = T.f_yeniId()
	if id == "": return null
	var tf: Dictionary = T.f_tarif(id)
	var P: Dictionary = game.j_TARIFP
	if str(P.get("kart_id", "")) != id:
		P["kart_id"] = id
		P["kart_t"] = 0.0
		J.method(game.j_SFX, "levelup", [])
		game.effects.f_flash(0.12, "#ffe9a0")
	P["kart_t"] = float(P.get("kart_t", 0.0)) + 1.0 / 60.0
	var kt: float = float(P["kart_t"])
	var a: float = clampf(kt * 3.0, 0.0, 1.0)
	J.setv(game.j_ctx, "globalAlpha", 0.78 * a)
	game.f_fr(0.0, 0.0, game.j_W, game.j_H, "#0d0a08")
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	var w := 300.0
	var kk: Variant = game.interface_draw.f_panelKutu((float(game.j_H) - 168.0) / 2.0, 168.0)
	var y: float = J.n(J.getv(kk, 0)) + (1.0 - a) * 10.0
	var h: float = J.n(J.getv(kk, 1))
	var x: float = floorf((float(game.j_W) - w) / 2.0)
	J.setv(game.j_ctx, "globalAlpha", a)
	game.interface_draw.f_panel(x, y, w, h, "BABA'NIN DEFTERİNDEN")
	var kx := x + 12.0
	var ky := y + 14.0
	var kw := w - 24.0
	var kh: float = h - 14.0 - 32.0
	_sayfa(kx, ky, kw, kh)
	var ix: float = kx + SOL
	var maxw: float = kw - SOL - 10.0
	game.f_hl(ix, ky + 16.0, maxw, SATIR)
	# parilti + buyuk yildiz (cizgiden sonra: yildiz cizginin ustunde)
	var pz: float = 0.5 + 0.5 * sin(kt * 5.0)
	J.setv(game.j_ctx, "globalAlpha", a * (0.35 + 0.25 * pz))
	game.f_disc(kx + kw - 22.0, ky + 18.0, 12.0 + 2.0 * pz, "#fff6c8")
	J.setv(game.j_ctx, "globalAlpha", a)
	f_yildiz(kx + kw - 29.0, ky + 11.0, ALTIN, 2.0)
	game.text_draw.f_txt("Yeni sayfa bulundu!", ix, ky + 6.0, "#8a5a1a")
	game.text_draw.f_txt(game.text_draw.kisalt(str(game.localization.f_T(str(tf.ad))), maxw - 24.0), ix, ky + 22.0, MUREKKEP)
	ciz_kalemler(id, ix + 10.0, ky + 44.0, kt)
	var ry := ky + 66.0
	while ry < ky + kh - 26.0:
		game.f_hl(ix, ry, maxw, SATIR)
		ry += 9.0
	var sy := ky + 58.0
	for l in satirlara(str(game.localization.f_T(str(tf.mesaj))), maxw, 3):
		game.text_draw.f_txt(str(l), ix, sy, NOT_RENGI)
		sy += 9.0
	_durum(id, ix, ky + kh - 22.0, maxw)
	J.setv(game.j_ctx, "globalAlpha", 1.0)
	if kt > 0.5 and game.f_button(x + w / 2.0 - 36.0, y + h - 24.0, 72.0, 18.0, "TAMAM", "#3f8a4a", true):
		T.f_yeniKapat()
		J.method(game.j_SFX, "ui", [])
	return null
