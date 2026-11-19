# WEB (HTML5) SURUMU (birlesik surum, 12. tur: "web versiyonunu da yap, html oynanilabilir bir sayfaya gomecegim").
# Tarayici davranisini (WebGL, IndexedDB, dokunmatik, iframe) gercek tarayicida tools/web_dene.js olcer; bu test masaustunde
# calisir ve web surumunun BOZULMAMASI icin degismemesi gereken yapilandirmayi kilitler:
#  1) web yardimcilari (scripts/web_ortam.gd) tarayici disinda hicbir sey yapmaz: web() / dokunmatik() false, dil() bos
#  2) kayitli dil varsa onu kullanir, yoksa Ingilizce kalir (masaustu davranisi degismedi; web'de tarayici dili devreye girer)
#  3) proje WebGL2 ile calisabilir: GL Compatibility cizim (Web yalniz bunu destekler)
#  4) export_presets.cfg: "Web" profili var, tek is parcacikli (SharedArrayBuffer / COOP / COEP gerektirmez, iframe'e gomulebilir),
#     canvas pencereyi doldurur, ozel kabuk web/kabuk.html
#  5) kabuk: Godot'un gerektirdigi yer tutucular var, oyunun TUM dilleri icin yukleme metni var, ?dil= desteklenir
#  6) gomme ornegi (web/embed-ornek.html) ve OKU-BENI.txt var; ornek iframe'i tam ekran / ses / kol izinleriyle gomer
#   godot --headless --path . --script tests/web_ortam.gd --quit-after 3000 -- --test
extends SceneTree
const WebOrtam = preload("res://scripts/web_ortam.gd")
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func oku(yol: String) -> String:
	return FileAccess.get_file_as_string(yol)

func run() -> void:
	# 1) tarayici disinda etkisiz
	check(not OS.has_feature("web"), "bu test masaustunde calisir")
	check(not WebOrtam.web(), "web() masaustunde false")
	check(not WebOrtam.dokunmatik(), "dokunmatik() masaustunde false (JavaScriptBridge'e dokunulmaz)")
	check(WebOrtam.dil() == "", "dil() masaustunde bos")
	# 2) dil: kayitli secim onceliklidir, yoksa Ingilizce (masaustunde tarayici dili kullanilmaz)
	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/web-ortam-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.j_LANG = "en"
	game.localization.f_loadLang()
	check(game.j_LANG == "en", "kayitli dil yokken masaustunde Ingilizce kalir (%s)" % game.j_LANG)
	game.localization.f_setLang("de")
	game.j_LANG = "en"
	game.localization.f_loadLang()
	check(game.j_LANG == "de", "kayitli dil okunur (%s)" % game.j_LANG)
	game.localization.f_setLang("tr")
	# 3) GL Compatibility
	var proje := oku("res://project.godot")
	check(proje.contains('renderer/rendering_method="gl_compatibility"'), "proje GL Compatibility cizim kullanir (Web yalniz bunu destekler)")
	# 4) export profili
	var cfg := ConfigFile.new()
	check(cfg.load("res://export_presets.cfg") == OK, "export_presets.cfg okunur")
	var web_bolum := ""
	for bolum in cfg.get_sections():
		if cfg.has_section_key(bolum, "platform") and str(cfg.get_value(bolum, "platform")) == "Web": web_bolum = bolum
	check(web_bolum != "", "Web export profili var")
	if web_bolum != "":
		var ayar := web_bolum + ".options"
		check(str(cfg.get_value(web_bolum, "name", "")) == "Web", "profil adi 'Web' (tools/web_derle.sh bu adi kullanir)")
		check(str(cfg.get_value(web_bolum, "export_path", "")) == "exports/web/index.html", "cikis yolu exports/web/index.html")
		check(not bool(cfg.get_value(ayar, "variant/thread_support", true)), "tek is parcacikli derleme (iframe'e gomulebilmesi icin COOP/COEP gerekmez)")
		check(not bool(cfg.get_value(ayar, "variant/extensions_support", true)), "GDExtension destegi kapali")
		check(int(cfg.get_value(ayar, "html/canvas_resize_policy", -1)) == 2, "canvas pencereyi / iframe'i doldurur (uyarlanabilir)")
		check(str(cfg.get_value(ayar, "html/custom_html_shell", "")) == "res://web/kabuk.html", "ozel kabuk web/kabuk.html")
		check(not bool(cfg.get_value(ayar, "progressive_web_app/enabled", true)), "PWA / servis calisani kapali (onbellek karisikligi olmasin)")
		check(str(cfg.get_value(web_bolum, "exclude_filter", "")).contains("web/*"), "web/ klasoru oyun paketine girmez")
	# 5) kabuk
	var kabuk := oku("res://web/kabuk.html")
	check(kabuk != "", "web/kabuk.html okunur")
	for yer_tutucu in ["$GODOT_URL", "$GODOT_CONFIG", "$GODOT_THREADS_ENABLED", "$GODOT_HEAD_INCLUDE"]:
		check(kabuk.contains(yer_tutucu), "kabukta Godot yer tutucusu var: " + yer_tutucu)
	check(kabuk.contains("Engine.getMissingFeatures") and kabuk.contains("engine.startGame"), "kabuk eksik ozellikleri bildirir ve oyunu baslatir")
	check(kabuk.contains("URLSearchParams") and kabuk.contains("'dil'"), "kabuk ?dil= parametresini okur")
	for dil in ["tr", "en", "de", "fr", "es", "pt"]:
		check(kabuk.contains("\n\t%s: { ad:" % dil), "kabukta '%s' yukleme metni var" % dil)
	var oyun_dilleri: Array = []
	for d in game.j_DILLER: oyun_dilleri.append(str(d.kod))
	for kod in oyun_dilleri: check(kabuk.contains("\n\t%s: { ad:" % kod), "oyunun dili '%s' kabukta da var (yeni dil eklenirse kabuga da ekle)" % kod)
	# 6) gomme ornegi ve okuBeni
	var ornek := oku("res://web/embed-ornek.html")
	var i0 := ornek.find('<iframe id="oyun"')
	var canli_iframe := ornek.substr(i0, ornek.find(">", i0) - i0) if i0 >= 0 else ""   # kod parcasi degil, sayfadaki GERCEK iframe
	check(canli_iframe.contains('src="index.html'), "gomme ornegi oyunun index.html'ini iframe ile gomer")
	check(canli_iframe.contains('allow="fullscreen; autoplay; gamepad"'), "iframe tam ekran / otomatik ses / kol izinlerini verir")
	check(ornek.contains("&lt;iframe") and ornek.contains("?dil=tr"), "sayfada kopyalanabilir iframe kodu ve ?dil= notu var")
	check(oku("res://web/OKU-BENI.txt").contains("web_sunucu.py") and FileAccess.file_exists("res://tools/web_sunucu.py"), "OKU-BENI + yerel sunucu betigi var")
	check(FileAccess.file_exists("res://tools/web_derle.sh") and FileAccess.file_exists("res://tools/web_sablon_indir.py") and FileAccess.file_exists("res://tools/web_dene.js"), "derleme / sablon / tarayici deneme araclari var")
	game.localization.f_setLang("tr")
	for f in failures: push_error(f)
	print("WEB ORTAM ", JSON.stringify({"failures": failures}))
	game.free(); quit(0 if failures.is_empty() else 1)
