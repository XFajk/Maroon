extends Node

var sound_volume = 1
var music_volume = 1

var mouse_sens: float = 0.07

func _ready() -> void:
	load_global()
	
func _exit_tree() -> void:
	save_global()

func save_global() -> void:
	var save_file: FileAccess = FileAccess.open("user://global_data.save", FileAccess.WRITE)
	
	var save_data: Dictionary = {
		"sound_volume": sound_volume,
		"music_volume": music_volume,
		"mouse_sens": mouse_sens
	}
	
	save_file.store_string(JSON.stringify(save_data))
	
	save_file.close()
	
	
func load_global() -> void:
	if not FileAccess.file_exists("user://global_data.save"):
		return
	
	var data_file: FileAccess = FileAccess.open("user://global_data.save", FileAccess.READ)
	var data: Dictionary = Saving.parse_file(data_file)
	
	sound_volume = float(data.get("sound_volume"))
	music_volume = float(data.get("music_volume"))
	
	mouse_sens = float(data.get("mouse_sens"))
	
	data_file.close()
	
func delete_global() -> void:
	FileAccess.open("user://global_data.save", FileAccess.WRITE).close()
	
