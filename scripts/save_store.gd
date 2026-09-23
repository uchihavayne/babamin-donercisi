extends RefCounted
var path: String = "user://records.json"
var values: Dictionary = {}
var last_error: Error = OK

func _init() -> void:
	eski_kaydi_tasi()
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary: values = parsed
		else: last_error = ERR_FILE_CORRUPT

# BIRLESIK SURUM: kayit klasoru ayri (project.godot custom_user_dir), remake ve
# kebap-shop ayni "My Father's Kebab Shop" klasorunu paylasiyor. Ilk acilista
# oradaki kayit ve cihaz ayarlari SALT OKUNUR kopyalanir; eski klasore yazilmaz.
static func eski_kaydi_tasi() -> void:
	if "--test" in OS.get_cmdline_user_args(): return
	var eski := OS.get_data_dir().path_join("Godot/app_userdata/My Father's Kebab Shop")
	for ad in ["records.json", "device_settings.cfg"]:
		var hedef: String = "user://" + ad
		var kaynak: String = eski.path_join(ad)
		if FileAccess.file_exists(hedef) or not FileAccess.file_exists(kaynak): continue
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://"))
		DirAccess.copy_absolute(kaynak, ProjectSettings.globalize_path(hedef))

func getItem(key: Variant) -> Variant:
	return values.get(str(key))

func setItem(key: Variant, value: Variant) -> Variant:
	values[str(key)] = value
	flush()
	return null

func removeItem(key: Variant) -> Variant:
	values.erase(str(key))
	flush()
	return null

func flush() -> void:
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		last_error = FileAccess.get_open_error()
		return
	file.store_string(JSON.stringify(values))
	file.close()
	last_error = DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path))
