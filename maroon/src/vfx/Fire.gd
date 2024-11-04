extends Node3D

func _on_sound_finished() -> void:
	$Sound.play()
