extends Control

@export var settings: Control = null
@export var continue_pop_up: Control = null


func _ready() -> void:
	settings.hide()

func _on_start_pressed() -> void:
	continue_pop_up.show()
	hide()
	
func _on_settings_pressed() -> void:
	settings.show()
	hide()

func _on_quit_pressed() -> void:
	get_tree().quit()
