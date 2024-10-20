extends Control

@onready var settings = $Settings

func _ready() -> void:
	settings.visible = false

func _on_start_pressed() -> void:
	pass
	
func _on_settings_pressed() -> void:
	settings.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()
