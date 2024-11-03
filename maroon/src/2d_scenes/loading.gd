extends Control

var game: PackedScene = preload("res://scenes/Enviroment.tscn")

func _on_start_loading_timer_timeout() -> void:
	var game_instance = game.instantiate()
	get_tree().root.add_child(game_instance)
	self.queue_free()
