extends Control

@export var settings: Control = null

func _ready() -> void:
	settings.hide()

func _on_start_pressed() -> void:
	pass
	
func _on_settings_pressed() -> void:
	settings.show()
	hide()

func _on_quit_pressed() -> void:
	get_tree().quit()
