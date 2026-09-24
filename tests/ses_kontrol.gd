# SES KONTROLU (birlesik surum, 6. tur madde 18): her efekt adi ornek sese
# yonlenmis mi, calinca hata veriyor mu, dokme dongusu donguye giriyor mu.
# Test kipi (--test) calmayi atladigi icin normal kipte, sessizce calisir.
#   godot --headless --path . --script tests/ses_kontrol.gd -- --olcum 999999
# (--olcum: kabuk oyuncunun kaydi yerine user://olcum-save.json kullanir)
extends SceneTree
const J = preload("res://scripts/js_compat.gd")

func _initialize() -> void:
	create_timer(60.0).timeout.connect(func() -> void: print("BEKCI"); quit(2))
	call_deferred("calis")

func calis() -> void:
	var shell: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(shell)
	var g: Node = shell.game
	await process_frame
	g.j_MUTED = false
	if g.j_AC == null: g.f_audioInit()
	var hata: Array = []
	var yonlu := 0
	for ad in g.ORNEK_SFX:
		if not g.ornek_akis.has(ad): hata.append("yuklenmedi: " + ad)
	for ad in g.j_SFX:
		var f: Variant = g.j_SFX[ad]
		if f is Callable and (f as Callable).get_method() in ["_ornek_cagri", "_cekmece_cagri", "_araba_cagri"]: yonlu += 1
		J.method(g.j_SFX, ad, [true])
	g.f_pourSndStart("cola")
	var p: AudioStreamPlayer = g.pour_player
	if p == null or (p.stream as AudioStreamWAV).loop_mode != AudioStreamWAV.LOOP_FORWARD: hata.append("dokme dongusu yok")
	g.f_pourSndStop(true)
	var calan := 0
	for c in g.get_children():
		if c is AudioStreamPlayer and c.playing: calan += 1
	print("SES ", JSON.stringify({"ornek": g.ornek_akis.size(), "yonlu": yonlu, "calan": calan, "hata": hata}))
	quit(0 if hata.is_empty() and yonlu >= 40 else 1)
