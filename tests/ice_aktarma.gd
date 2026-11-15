# ICE AKTARMA (birlesik surum, 12. tur): kullanici "HD niye kapali, nasil aciliyor, olmuyor" dedi.
# Neden: proje klasoru Godot'ta HIC ice aktarilmamisti (taze ZIP); Oyna.cmd oyunu dogrudan acinca
# HD dokulari (res://assets/remake/...) yuklenemiyor, oyun sessizce eski cizime dusuyordu (721 script
# hatasi + "HD kapali"). Temiz klasorde elle dogrulandi: ice aktarma yok -> HD kapali, var -> HD acik.
#  1) Oyna.cmd gorselleri oyundan ONCE ice aktarir (--headless --path . --import) ve CRLF kalir
#  2) dokular yoksa hd_acik tek merkezden false olur (istek ayri tutulur), F2 bunu gecemez
#  3) yuklenemeyen sprite sayfasi script hatasi vermez, null doner (kaynak cizime dusulur)
#   godot --headless --path . --script tests/ice_aktarma.gd --quit-after 3000 -- --test
extends SceneTree
var game: Node
var failures: Array[String] = []

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label); push_error(label)

func run() -> void:
	# 1) baslatici
	var cmd := FileAccess.get_file_as_string("res://Oyna.cmd")
	var i_aktar := cmd.find("--headless --path . --import")
	var i_oyun := cmd.rfind("--path .")
	check(i_aktar >= 0, "Oyna.cmd gorselleri ice aktarir (--headless --path . --import)")
	check(i_aktar >= 0 and i_oyun > i_aktar, "ice aktarma oyunu acan komuttan ONCE")
	var ham := FileAccess.get_file_as_bytes("res://Oyna.cmd")
	check(ham.size() > 10 and ham[ham.find(10) - 1] == 13, "Oyna.cmd CRLF satir sonuyla (Windows)")
	var ga := FileAccess.get_file_as_string("res://.gitattributes")
	check(ga.contains("*.cmd text eol=crlf"), ".gitattributes: *.cmd CRLF")

	game = load("res://scripts/platform_game.gd").new()
	game.storage.path = "res://artifacts/ice-aktarma-save.json"; game.storage.values = {}
	root.add_child(game); game.set_process(false); game.j_MUTED = true
	game.localization.f_setLang("tr")

	# 2) hd_acik = istek VE dokular
	check(game.hd_acik, "dokular yuklu (ice aktarilmis ortam): hd_acik true")
	game.hd_acik = false
	check(not game.hd_acik and game.hd_durum_metni().begins_with("ESKİ ÇİZİM"), "istekle kapatilinca 'ESKİ ÇİZİM' (%s)" % game.hd_durum_metni())
	game.hd_acik = true
	game._dokular_durum = 2                       # "dokular yuklenemedi" durumu
	check(not game.hd_acik and not game.hd_gpu() and game._hd_istek, "dokular yokken hd_acik/hd_gpu false, istek korunur")
	var f2 := InputEventKey.new(); f2.keycode = KEY_F2; f2.pressed = true
	game.hd_tus(f2)                               # F2 (istegi kapatir, dokular yokken yine false)
	game.hd_tus(f2)                               # tekrar (istegi acar)
	check(not game.hd_acik, "F2 eksik dokulari gecemez")
	game._dokular_durum = 1
	check(game.hd_acik, "dokular gelince HD yeniden acik")

	# 3) yuklenemeyen sprite sayfasi
	var SL = load("res://scripts/sprite_library.gd").new()
	SL.manifest["deneme/yok"] = {"sheet": "yok-boyle-bir-sayfa.png", "region": [0, 0, 4, 4]}
	check(SL.get_sprite("deneme/yok") == null, "yuklenemeyen sayfa: null doner, script hatasi yok")
	check(SL.get_sprite("deneme/yok") == null, "ikinci cagri da null (onbellekte)")
	game.free()
	if failures.is_empty():
		print("ICE AKTARMA TAMAM")
		quit(0)
	else:
		print("ICE AKTARMA HATA: ", failures.size())
		for f in failures: print("  - ", f)
		quit(1)
