# Butun betikleri ayristirir (tek Godot acilisi). Kullanim: sh tests/kontrol.sh
extends SceneTree

func _initialize() -> void:
	var hatali: Array = []
	var sayi := 0
	for kok in ["res://scripts", "res://tests", "res://tools", "res://data"]:
		for p in _gd(kok):
			if p == "res://tests/kontrol.gd": continue
			sayi += 1
			var s: Variant = load(p)
			if s == null or not (s is GDScript) or not s.can_instantiate():
				hatali.append(p)
	for p in hatali: print("HATA ", p)
	print("KONTROL %s (%d betik)" % ["TAMAM" if hatali.is_empty() else "HATALI", sayi])
	quit(1 if not hatali.is_empty() else 0)

func _gd(kok: String) -> Array:
	var sonuc: Array = []
	var d := DirAccess.open(kok)
	if d == null: return sonuc
	for f in d.get_files():
		if f.ends_with(".gd"): sonuc.append(kok.path_join(f))
	for alt in d.get_directories():
		sonuc.append_array(_gd(kok.path_join(alt)))
	return sonuc
