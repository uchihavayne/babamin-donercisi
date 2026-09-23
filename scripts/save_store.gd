extends RefCounted
var path: String = "user://records.json"
var values: Dictionary = {}
var last_error: Error = OK

func _init() -> void:
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed is Dictionary: values = parsed
		else: last_error = ERR_FILE_CORRUPT

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
