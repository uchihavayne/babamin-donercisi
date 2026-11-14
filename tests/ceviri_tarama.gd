# CEVIRI TARAMASI (birlesik surum, 11. tur): kodda (tr, en) cifti olarak yazilan
# her metnin ("text(" / "cift(" / "order_text(" ve iki dize sabiti) de, fr, es,
# pt sozluklerinde Turkce anahtari var mi? Yoksa o dilde oyuncu Ingilizce
# gorur. Kayitsiz kalan cift listelenir ve test KALIR.
#  - Turkce ile Ingilizcesi ayni olan metinler (marka, kisaltma) taranmaz
#  - "ISTISNA" listesi bilincli olarak cevrilmeyenler icindir (bos olmali)
#   godot --headless --path . --script tests/ceviri_tarama.gd --quit-after 3000 -- --test
#   ... -- --test --liste   (eksikleri sozluk girdisi olarak yazdirir)
extends SceneTree
var game: Node
var failures: Array[String] = []
const DILLER := ["de", "fr", "es", "pt"]
const ISTISNA: Array[String] = []

func _initialize() -> void: call_deferred("run")

func dosyalar(klasor: String) -> Array[String]:
	var out: Array[String] = []
	var d := DirAccess.open(klasor)
	if d == null: return out
	for f in d.get_files():
		if f.ends_with(".gd"): out.append(klasor + "/" + f)
	for alt in d.get_directories():
		out.append_array(dosyalar(klasor + "/" + alt))
	return out

func run() -> void:
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/ceviri-tarama-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	var liste := "--liste" in OS.get_cmdline_user_args()
	var re := RegEx.new()
	var lit := "\"((?:[^\"\\\\\\n]|\\\\.)*)\""
	re.compile("\\b(?:text|cift|order_text)\\(\\s*" + lit + "\\s*,\\s*" + lit + "\\s*\\)")
	var gorulen := {}
	var sayi := 0
	for yol in dosyalar("res://scripts"):
		var kaynak := FileAccess.get_file_as_string(yol)
		for m in re.search_all(kaynak):
			var tr: String = m.get_string(1).c_unescape()
			var en: String = m.get_string(2).c_unescape()
			if tr == en or gorulen.has(tr): continue
			gorulen[tr] = [en, yol]
			sayi += 1
	var eksik := {}
	for tr in gorulen:
		if tr in ISTISNA: continue
		for dil in DILLER:
			var sozluk: Variant = game.j_SOZLUK.get(dil)
			if not (sozluk is Dictionary) or not sozluk.has(tr):
				if not eksik.has(tr): eksik[tr] = []
				eksik[tr].append(dil)
	for tr in eksik:
		failures.append("sozlukte yok [%s]: %s  (%s)" % [",".join(eksik[tr]), tr.substr(0, 70).replace("\n", "⏎"), gorulen[tr][1].get_file()])
		if liste: print("EKSIK|", dil_etiketi(eksik[tr]), "|", tr.c_escape(), "|", String(gorulen[tr][0]).c_escape(), "|", gorulen[tr][1])
	# 2) oyun verisindeki (j_LINES_*, j_UPG, j_BAHIS, j_RAKIP_* ... ) Turkce metinler:
	#    her dil sozlugunde (Ingilizce dahil) karsiligi olmali
	var veri_eksik := {}
	var veri_say := 0
	for p in game.get_property_list():
		var ad: String = p.name
		if not ad.begins_with("j_") or ad in ["j_SOZLUK", "j_FONT", "j_G", "j_DILLER", "j_LANG", "j_EN", "j_LOGO_VERI"]: continue
		var deger: Variant = game.get(ad)
		if deger is Array or deger is Dictionary: veri_tara(ad, deger, 0, veri_eksik)
	veri_say = veri_eksik.get("__say", 0)
	veri_eksik.erase("__say")
	for tr in veri_eksik:
		failures.append("veri sozlukte yok [%s]: %s  (%s)" % [",".join(veri_eksik[tr][1]), String(tr).substr(0, 70), veri_eksik[tr][0]])
		if liste: print("EKSIK|", ",".join(veri_eksik[tr][1]), "|", String(tr).c_escape(), "||", veri_eksik[tr][0])
	for f in failures: push_error(f)
	print("CEVIRI TARAMA ", JSON.stringify({"taranan_cift": sayi, "eksik": eksik.size(), "veri_metni": veri_say, "veri_eksik": veri_eksik.size(), "failures": failures.size()}))
	game.free(); quit(0 if failures.is_empty() else 1)

func dil_etiketi(d: Array) -> String: return ",".join(d)

# veri dizilerinde dolasir; konusma / aciklama gibi metinleri (bosluk, ! ? … iceren,
# 4+ harf) sozluk kapsami icin sayar. Kimlik / tur alanlari atlanir.
func veri_tara(ad: String, v: Variant, derin: int, eksik: Dictionary) -> void:
	if derin > 4: return
	if v is String:
		var s: String = v
		if s.length() < 4 or not (" " in s or "!" in s or "?" in s or "…" in s): return
		eksik["__say"] = int(eksik.get("__say", 0)) + 1
		var yok: Array = []
		for dil in ["en", "de", "fr", "es", "pt"]:
			var d: Variant = game.j_SOZLUK.get(dil)
			if not (d is Dictionary) or not d.has(s): yok.append(dil)
		if not yok.is_empty() and not eksik.has(s): eksik[s] = [ad, yok]
	elif v is Array:
		for e in v: veri_tara(ad, e, derin + 1, eksik)
	elif v is Dictionary:
		for k in v:
			if k in ["id", "st", "kind", "tur", "ikon", "gerek"]: continue
			veri_tara(ad, v[k], derin + 1, eksik)
