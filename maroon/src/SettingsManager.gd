extends Panel



func _on_back_to_main_menu_pressed() -> void:
	self.visible = false

func _on_sounds_value_changed(value: float) -> void:
	Global.sound_volume = value / 100

func _on_music_value_changed(value: float) -> void:
	Global.music_volume = value / 100
