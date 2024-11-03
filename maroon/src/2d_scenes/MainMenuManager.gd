extends Control

@export var settings: Control = null
@export var continue_pop_up: Control = null

var loading: PackedScene = preload("res://scenes/2D/Loading.tscn")

func _ready() -> void:
	settings.hide()

func _on_start_pressed() -> void:
	if FileAccess.file_exists("user://gamedata.save"):
		continue_pop_up.show()
	else:
		var loading_instance = loading.instantiate()
		get_tree().root.add_child(loading_instance)
		get_parent().get_parent().queue_free()
	hide()
	
func _on_settings_pressed() -> void:
	settings.show()
	hide()

func _on_quit_pressed() -> void:
	get_tree().quit()
