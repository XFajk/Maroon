extends Control


func _on_resume_pressed() -> void:
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hide()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	Saving.save()
	get_tree().quit()


func _on_save_pressed() -> void:
	Saving.save()
