extends Control

@export var Settings: Control = null

func _on_resume_pressed() -> void:
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_parent().hide()


func _on_options_pressed() -> void:
	print("options")
	Settings.show()
	hide()


func _on_quit_pressed() -> void:
	Saving.save()
	get_tree().quit()


func _on_save_pressed() -> void:
	Saving.save()
