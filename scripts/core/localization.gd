# Localization. See CODE_MAP.md.
extends "res://scripts/core/game_module.gd"

# i18n.js:4996
func f_dilVar(p_k: Variant = null) -> Variant:
	var v_i: Variant = null
	var v_k: Variant = p_k
	v_i = 0.0
	while J.lt(v_i, J.getv(game.j_DILLER, "length")):
		if J.eq(J.getv(J.getv(game.j_DILLER, v_i), "kod"), v_k):
			return true
		v_i = J.add(v_i, 1.0)
	return false
	return null

# i18n.js:5001
# BIRLESIK (6. tur, madde 17): kodda (tr, en) cifti olarak yazilan metinler
# (istasyon eylemleri, siparis uyarilari, ayarlar penceresi) eskiden de/fr/es/pt'de
# Ingilizce kaliyordu. Artik sozlukte Turkce anahtar varsa o dilin cevirisi.
func cift(tr_text: String, en_text: String) -> String:
	var soz: String = girdi(tr_text)
	if soz != tr_text: return f_T(soz)   # aygita ozel soz: Ingilizcesi de sozlukten
	var dil: Variant = game.j_LANG
	if dil == "tr": return tr_text
	if dil != "en" and game.j_SOZLUK is Dictionary:
		var d: Variant = game.j_SOZLUK.get(dil)
		if d is Dictionary and d.has(tr_text): return d[tr_text]
	return en_text

# BIRLESIK (11. tur): girdi aygitina gore soz. Metinler fare icin yazilmis
# ("tıkla" / "Click"); telefonda (ilk cikis hedefi) ogretici de "Turşuya tıkla"
# diyordu. Anahtar fare metni; degerler [dokunmatik, oyun kolu / klavye].
# Dokunmatikte "dokun", kol ve klavyede aygit adi gecmeyen yalin soz. Dogrudan
# kullanimda (fare disi) patates tahtasi basili tutularak dogranir.
const GIRDI_SOZ := {
	"Et tepsisine tıkla — tek tık bir porsiyon": ["Et tepsisine dokun — her dokunuş bir porsiyon", "Et ekle — her seferinde bir porsiyon"],
	"Turşuya tıkla": ["Turşuya dokun", "Turşu ekle"],
	"Yoğurda tıkla": ["Yoğurda dokun", "Yoğurt ekle"],
	"Tahtaya tıklayarak doğra": ["Tahtayı basılı tutarak doğra", "Tahtayı basılı tutarak doğra"],
	"Patatese tıkla, dürüme gitsin": ["Patatese dokun, dürüme gitsin", "Patatesi dürüme ekle"],
	"Kutu açık — tıklayarak doldur": ["Kutu açık — dokunarak doldur", "Kutu açık — malzemeyi seçip doldur"],
	"Pideyi doğra — tahtaya tıkla": ["Pideyi doğra — tahtaya dokun", "Pideyi tahtada doğra"],
	" (tekrar tıkla)": [" (tekrar dokun)", " (tekrar bas)"],
	"tıkla: +": ["dokun: +", "seç: +"],
	"Tek tıkla 2-3 ürüne birden": ["Tek dokunuşla 2-3 ürüne birden", "Tek seferde 2-3 ürüne birden"],
	"3 MALZEME TEK TIK": ["3 MALZEME TEK DOKUNUŞ", "3 MALZEME TEK SEFERDE"],
}

func girdi(metin: Variant) -> Variant:
	if not (metin is String) or not GIRDI_SOZ.has(metin): return metin
	var kip: String = game.controls.mode if game.get("controls") != null else "mouse"
	if kip == "touch": return GIRDI_SOZ[metin][0]
	if kip == "controller" or kip == "keyboard": return GIRDI_SOZ[metin][1]
	return metin

func f_T(p_s: Variant = null) -> Variant:
	var v_d: Variant = null
	var v_v: Variant = null
	var v_s: Variant = girdi(p_s)
	if ((J.eq(game.j_LANG, "tr") or J.eq(v_s, null)) or J.eq(v_s, null)):
		return v_s
	v_d = J.getv(game.j_SOZLUK, game.j_LANG)
	if (not J.truth(v_d)):
		return v_s
	v_v = J.getv(v_d, v_s)
	return (v_s if J.eq(v_v, null) else v_v)
	return null

# i18n.js:5009
func f_loadLang() -> Variant:
	var v_v: Variant = null
	var v_e: Variant = null
	v_v = J.method(game.j_localStorage, "getItem", [game.j_LANGKEY])
	if (J.truth(v_v) and J.truth(game.localization.f_dilVar(v_v))):
		game.j_LANG = v_v
	return null

# i18n.js:5016
func f_setLang(p_l: Variant = null) -> Variant:
	var v_e: Variant = null
	var v_l: Variant = p_l
	if (not J.truth(game.localization.f_dilVar(v_l))):
		return null
	game.j_LANG = v_l
	J.method(game.j_localStorage, "setItem", [game.j_LANGKEY, v_l])
	if J.eq(J.kind(J.ref(game.game_loop.f_invalidateLayers, 0)), "function"):
		game.game_loop.f_invalidateLayers()
	if not J.eq(J.kind(game.j_SHOP), "undefined"):
		J.setv(game.j_SHOP, "bake", null)
	return null
