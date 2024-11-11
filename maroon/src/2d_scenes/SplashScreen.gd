extends Control

var main_menu: PackedScene = preload("res://scenes/2D/MainMenu.tscn")

func _on_video_stream_player_finished() -> void:
	get_tree().root.add_child(main_menu.instantiate())
	queue_free()
	
