# Hikaye yazilari (birlesik surum, 12. tur): oyun boyunca kosulu ilk saglandiginda gun sonunda bir kez gosterilen kisa kartlar
# (veri: data/hikaye.gd). Durum G.hikaye = {gorulen: [kimlikler], sira: [gosterilecek kimlikler]}; ilerleme kaydinda. Kosullar
# burada (f_kosul); her gun sonu f_tara yeni saglananlari siraya ekler, gun sonu ekrani TAMAM'a kadar "DUKKANA GIT" vermez.
# Kapanis hikayesinin Demirkent'e bagli sahnesi de burada (f_epiDemirkent).
extends "res://scripts/core/game_module.gd"

func f_liste() -> Array:
	var l: Variant = game.j_HIKAYE
	return l if l is Array else []

func f_yazi(id: String) -> Dictionary:
	for h in f_liste():
		if str(h.id) == id: return h
	return {}

func f_durum() -> Dictionary:
	var d: Variant = J.getv(game.j_G, "hikaye")
	if not (d is Dictionary):
		d = {"gorulen": [], "sira": []}
		J.setv(game.j_G, "hikaye", d)
	for k in ["gorulen", "sira"]:
		if not (d.get(k) is Array): d[k] = []
	return d

# ilerleme kaydindan yukleme: yalniz bilinen kimlikler, tekrarsiz; sira yalniz gorulmemislerden. Kayitta alan yoksa (eski kayit) su an
# saglanan her kosul "goruldu" sayilir: eski oyuncuya bir anda yigin kart gosterilmez.
func f_yukle(v: Variant) -> Dictionary:
	var bilinen := {}
	for h in f_liste(): bilinen[str(h.id)] = true
	var d := {"gorulen": [], "sira": []}
	if v is Dictionary:
		for k in ["gorulen", "sira"]:
			var a: Variant = v.get(k)
			if not (a is Array): continue
			for e in a:
				if typeof(e) == TYPE_STRING and bilinen.has(e) and not (e in d[k]): d[k].append(e)
		d.sira = d.sira.filter(func(e: Variant) -> bool: return not (e in d.gorulen))
		J.setv(game.j_G, "hikaye", d)
	else:
		J.setv(game.j_G, "hikaye", d)
		for h in f_liste():
			if f_kosul(str(h.id)): d.gorulen.append(str(h.id))
	return d

func f_kayit() -> Dictionary:
	return f_durum().duplicate(true)

func _n(a: Variant, k: String) -> float:
	return J.n(a.get(k, 0.0)) if a is Dictionary else 0.0

# bir yazinin kosulu (durumdan okunur; yalniz gun sonunda cagrilir)
func f_kosul(id: String) -> bool:
	var G: Dictionary = game.j_G
	var S: Variant = G.get("stats")
	var ferman: bool = J.truth(game.progression_system.f_fermanSehri(G))
	match id:
		"icra_zarf": return J.n(G.day) >= float(game.session_system.TAKSIT_GUN) and J.n(G.debt) > 0.0 and not ferman
		"rakip_tanisma": return J.truth(G.get("rakipTanisti"))
		"ilk_sube": return J.n(G.get("branch")) >= 1.0
		"icra_memur": return _n(G.get("icra"), "ziyaret") >= 3.0
		"rakip_kapandi": return J.truth(G.get("rakipKapandi"))
		"yari_yol": return J.n(G.debt) <= J.n(game.j_DEBT_START) / 2.0 and J.n(G.debt) > 0.0
		"demirkent_mektup": return J.n(G.get("branch")) >= 8.0
		"demirkent_ilk": return _n(S, "fgunEn") >= 1.0
	return false

# gun sonunda: yeni saglanan, gorulmemis, sirada olmayan yazilari siraya ekler
func f_tara() -> void:
	var d := f_durum()
	for h in f_liste():
		var id := str(h.id)
		if id in d.gorulen or id in d.sira: continue
		if f_kosul(id): d.sira.append(id)

func f_kartAcik() -> bool:
	return not f_durum().sira.is_empty()

# su an gosterilecek yazi (sira basi); yoksa bos sozluk
func f_kart() -> Dictionary:
	var d := f_durum()
	return f_yazi(str(d.sira[0])) if not d.sira.is_empty() else {}

func f_kartKapat() -> void:
	var d := f_durum()
	if d.sira.is_empty(): return
	var id := str(d.sira.pop_front())
	if not (id in d.gorulen): d.gorulen.append(id)
	game.save_system.f_saveAll()

# ---------------------------------------------------------------- kapanis hikayesi: Demirkent'e bagli sahne
# Demirkent'e hic gidilmediyse bos (sahne eklenmez). Aksi halde 2-3 satir: tavir (muhur yedi / aclari doyurdu / fermana uydu) + sofra.
func f_epiDemirkent() -> Array:
	var S: Variant = J.getv(game.j_G, "stats")
	if not (S is Dictionary): return []
	var gitti: bool = _n(S, "fgunEn") > 0.0
	var sehir: Variant = S.get("sehir")
	if sehir is Array and (8.0 in sehir or 8 in sehir): gitti = true
	if not gitti: return []
	var K: Dictionary = game.j_EPI_DEMIRKENT if game.j_EPI_DEMIRKENT is Dictionary else {}
	var satirlar: Array
	if _n(S, "muhur") >= 1.0: satirlar = K.get("direnis", []).duplicate()
	elif _n(S, "fed") >= 5.0: satirlar = K.get("sifa", []).duplicate()
	else: satirlar = K.get("uyum", []).duplicate()
	var hane: Variant = J.getv(game.j_G, "hane")
	if hane is Array and not hane.is_empty():
		var canli: float = J.n(game.progression_system.f_haneCanli(hane))
		satirlar.append(str(K.get("sofra_tam", "")) if canli >= float(hane.size()) else str(K.get("sofra_eksik", "")))
	return satirlar
