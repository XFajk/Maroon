extends Control

@export var Menu: Control = null

func _ready() -> void:
	$Sounds.value = Global.sound_volume*100
	$Music.value = Global.music_volume*100
	$MouseSensitivity.value = Global.mouse_sens*100

func _on_back_to_main_menu_pressed() -> void:
	Menu.show()
	self.hide()

func _on_sounds_value_changed(value: float) -> void:
	Global.sound_volume = value / 100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear_to_db(Global.sound_volume))
	Global.save_global()

func _on_music_value_changed(value: float) -> void:
	Global.music_volume = value / 100
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Global.music_volume))
	Global.save_global()

func _on_mouse_sensitivity_value_changed(value: float) -> void:
	Global.mouse_sens = value / 100
	Global.save_global()
