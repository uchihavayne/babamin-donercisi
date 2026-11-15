# Baba'nin Defteri: kayip tarifler (birlesik surum, 12. tur, kullanici istegi). Bkz. REHBER.md.
# Veri: data/tarif.gd (game.j_TARIF). Durum: G.tarif = {bulunan, yeni, gorulen, servis}.
#  - sayfa bulma: her gunun sonunda (session_system.f_endDay) `gun`ine gelmis sayfalar bulunur
#  - siparis: bulunmus + ekipmani olan tarifler musteriden ADIYLA istenir (f_makeOrder'dan)
#  - odul: dogru + tam kalite teslimde dürüm fiyati x carpan (x usta bonusu); menu tarifleri
#    siparis bitince ek bonus verir; her tarifin servis sayaci 3 usta seviyesi verir
extends "res://scripts/core/game_module.gd"

# Ekipmani olan tarif varsa, her normal siparisin dürümünün tarif olma olasiligi
const SANS := 0.14
# servis sayisi -> usta seviyesi (1, 2, 3); her seviye o tarifin fiyatina +%10
const USTA_ESIK := [5, 15, 40]
const USTA_ARTIS := 0.10

# ---------------------------------------------------------------- durum
func f_durum() -> Dictionary:
	var g: Variant = J.getv(game.j_G, "tarif")
	if not (g is Dictionary):
		g = {}
		J.setv(game.j_G, "tarif", g)
	for k in ["bulunan", "yeni", "gorulen"]:
		if not (g.get(k) is Array): g[k] = []
	if not (g.get("servis") is Dictionary): g["servis"] = {}
	return g

# kayittan yukleme: yalniz bilinen sayfalar, tekrarsiz; yeni / okunmus yalniz bulunmus sayfalardan;
# servis sayaclari negatif olmayan tam sayi. Bozuk ya da eski (alan yok) kayit bos defter olur.
func f_yukle(v: Variant) -> Dictionary:
	var bilinen := {}
	for t in f_liste(): bilinen[str(t.id)] = true
	var d := {"bulunan": [], "yeni": [], "gorulen": [], "servis": {}}
	if v is Dictionary:
		for k in ["bulunan", "yeni", "gorulen"]:
			var a: Variant = v.get(k)
			if not (a is Array): continue
			for e in a:
				if typeof(e) == TYPE_STRING and bilinen.has(e) and not (e in d[k]): d[k].append(e)
		var s: Variant = v.get("servis")
		if s is Dictionary:
			for k in s:
				if bilinen.has(str(k)) and (typeof(s[k]) == TYPE_FLOAT or typeof(s[k]) == TYPE_INT): d.servis[str(k)] = maxi(0, int(s[k]))
	d.yeni = d.yeni.filter(func(e: Variant) -> bool: return e in d.bulunan)
	d.gorulen = d.gorulen.filter(func(e: Variant) -> bool: return e in d.bulunan)
	J.setv(game.j_G, "tarif", d)
	return d

func f_liste() -> Array:
	var l: Variant = game.j_TARIF
	return l if l is Array else []

func f_tarif(id: String) -> Dictionary:
	for t in f_liste():
		if str(t.id) == id: return t
	return {}

func f_bulundu(id: String) -> bool:
	return id in f_durum().bulunan

# ---------------------------------------------------------------- sayfa bulma (gun sonu)
# Gunun sonunda cagrilir; o gune kadar gelmis ve henuz bulunmamis sayfalari bulur.
func f_sayfaBul() -> Array:
	var d := f_durum()
	var yeni: Array = []
	var gun: float = J.n(J.getv(game.j_G, "day"))
	for t in f_liste():
		var id := str(t.id)
		if gun >= float(t.gun) and not (id in d.bulunan):
			d.bulunan.append(id)
			d.yeni.append(id)
			yeni.append(id)
	return yeni

func f_bulunanSayi() -> int:
	return f_durum().bulunan.size()

func f_yeniVar() -> bool:
	return not f_durum().yeni.is_empty()

func f_yeniId() -> String:
	var d := f_durum()
	return str(d.yeni[0]) if not d.yeni.is_empty() else ""

# "TAMAM": siradaki yeni sayfa kartini kapatir
func f_yeniKapat() -> void:
	var d := f_durum()
	if not d.yeni.is_empty():
		var id: Variant = d.yeni.pop_front()
		f_gorulduIsaretle(str(id))

# defterde acilmis (okunmus) sayfa; dukkan dugmesindeki "!" okunmamis sayfa icin
func f_gorulduIsaretle(id: String) -> void:
	var d := f_durum()
	if not (id in d.gorulen): d.gorulen.append(id)

func f_okunmamis() -> int:
	var d := f_durum()
	var n := 0
	for id in d.bulunan:
		if not (id in d.gorulen): n += 1
	return n

# bulunmamis sonraki sayfanin gunu (yoksa -1): "sonraki sayfa N. gunde"
func f_sonrakiGun() -> int:
	var d := f_durum()
	var en := -1
	for t in f_liste():
		if not (str(t.id) in d.bulunan):
			if en < 0 or int(t.gun) < en: en = int(t.gun)
	return en

# ---------------------------------------------------------------- ekipman kosulu
func _tun(ad: String) -> bool:
	return J.truth(J.method(game.j_TUN, ad, [game.j_G]))

func f_ekipmanVar(kimlik: String) -> bool:
	match kimlik:
		"sauce": return _tun("sauceOn")
		"secim": return _tun("secimOn")
		"secim2": return _tun("secimOn") and J.n(J.method(game.j_TUN, "secimEnCok", [game.j_G])) >= 2.0
		"fbox": return _tun("fboxOn")
		"ayran": return _tun("ayranOn")
		"sweet": return _tun("sweetOn")
		"drink": return _tun("drinkOn")
	return true

func f_yapilabilir(id: String) -> bool:
	var t := f_tarif(id)
	if t.is_empty(): return false
	for k in t.get("gerek", []):
		if not f_ekipmanVar(str(k)): return false
	return true

# eksik yukseltmelerin gorunur (cevrilmis) adlari: "Gerekli: ..." satirinda gosterilir
func f_eksikler(id: String) -> Array:
	var out: Array = []
	for k in f_tarif(id).get("gerek", []):
		if f_ekipmanVar(str(k)): continue
		var ad: String = str(game.localization.f_T(_yukseltmeAdi("secim" if str(k) == "secim2" else str(k))))
		if str(k) == "secim2": ad += " 2"   # Malzeme Secimi 2. seviye
		out.append(ad)
	return out

# defterde gosterilen fiyat icin: izgara aciksa dürümler izgaralidir (+izgara primi)
func f_izgaraAcik() -> bool:
	return _tun("grillOn")

func _yukseltmeAdi(id: String) -> String:
	for u in game.j_UPG:
		if str(u.id) == id: return str(u.name)
	return id

# ---------------------------------------------------------------- usta seviyesi ve fiyat
func f_servis(id: String) -> int:
	return int(J.n(f_durum().servis.get(id, 0)))

func f_usta(id: String) -> int:
	var n := f_servis(id)
	var s := 0
	for e in USTA_ESIK:
		if n >= int(e): s += 1
	return s

func f_carpan(id: String) -> float:
	return float(f_tarif(id).get("carpan", 1.0)) * (1.0 + USTA_ARTIS * f_usta(id))

# ---------------------------------------------------------------- siparis
# tarifin dürüm kalemi: mevcut sos / yok kurallari + "tarif" kimligi (eslestirme aynen calisir)
func f_siparisKalemi(id: String) -> Dictionary:
	var t := f_tarif(id)
	var w := {"kind": "wrap", "sauce": t.get("sos"), "tarif": id}
	var yok: Array = t.get("yok", [])
	if not yok.is_empty(): w["yok"] = yok.duplicate()
	return w

func f_ekKalemler(id: String) -> Array:
	var out: Array = []
	for e in f_tarif(id).get("ek", []):
		match str(e):
			"ayran": out.append({"kind": "drink", "type": "ayran"})
			"cola": out.append({"kind": "drink", "type": "cola"})
			"fbox": out.append({"kind": "fbox"})
			"sweet": out.append({"kind": "sweet"})
	return out

# bulunmus + yapilabilir tarifler arasindan rastgele biri; olasilik tutmazsa ya da yoksa ""
# (uygun tarif yokken rastgele sayi TUKETILMEZ: eski akislar ve testler degismez)
func f_sec() -> String:
	var uygun: Array = []
	for t in f_liste():
		if f_bulundu(str(t.id)) and f_yapilabilir(str(t.id)): uygun.append(str(t.id))
	if uygun.is_empty(): return ""
	if not J.truth(game.f_chance(SANS)): return ""
	return str(game.math_utils.f_pick(uygun))

# recipe_system.f_makeOrder'in sonunda: ilk dürüm tarife cevrilebilir
func f_siparisKarisitir(items: Array) -> Array:
	if items.is_empty() or not (items[0] is Dictionary) or str(items[0].get("kind")) != "wrap": return items
	var id := f_sec()
	if id == "": return items
	var ek := f_ekKalemler(id)
	if ek.is_empty():
		items[0] = f_siparisKalemi(id)   # tek dürüm tarifi: rastgele icecek / patates vb. kalir
		return items
	var menu: Array = [f_siparisKalemi(id)]   # menu: rastgele eklemeler yerine tarifin kendi kalemleri
	menu.append_array(ek)
	return menu

# ---------------------------------------------------------------- odul
# customer_system.f_deliver: dogru sos + dogru malzeme + tam kalite teslimde cagrilir.
# Fiyati carpar, servis sayacini artirir, usta seviyesi atlarsa haber verir.
func f_odul(id: String, fiyat: float, musteri: Dictionary) -> float:
	var d := f_durum()
	var carpan := f_carpan(id)
	var onceki := f_usta(id)
	d.servis[id] = f_servis(id) + 1
	var yeni := f_usta(id)
	var x: float = J.n(musteri.get("x", 240.0))
	var y: float = J.n(musteri.get("y", 140.0))
	game.effects.f_ftext(game.localization.f_T("BABA'NIN TARİFİ!"), x, y - 74.0, J.getv(game.j_P, "au0"), {"sc": 1.0, "life": 1.7})
	J.method(game.j_SFX, "levelup", [])
	# altin yildiz yagmuru (usta seviyesi atlayinca daha buyuk + hafif parilti)
	game.effects.f_burst(x, y - 30.0, 18.0 if yeni > onceki else 9.0, [J.getv(game.j_P, "au0"), J.getv(game.j_P, "au1"), "#fff"], {"spMax": 80.0, "up": 28.0, "type": "star", "sz": 2.0})
	if yeni > onceki:
		game.effects.f_ftext(game.localization.f_T("USTA SEVİYESİ!"), x, y - 86.0, J.getv(game.j_P, "ok"), {"sc": 1.0, "life": 2.0})
		game.effects.f_flash(0.1, "#ffe9a0")
	return floorf(fiyat * carpan + 0.5)

# siparis tamamen bitince menu bonusu orani (tarif kalemi yoksa / musteri kizdiysa 0)
func f_menuBonusu(musteri: Dictionary) -> float:
	if J.truth(musteri.get("mad", false)): return 0.0
	for it in musteri.get("items", []):
		if it is Dictionary and it.has("tarif"):
			return float(f_tarif(str(it.tarif)).get("menu", 0.0))
	return 0.0
