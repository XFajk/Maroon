extends Control

var loading: PackedScene = preload("res://scenes/2D/Loading.tscn")

func _on_video_stream_player_finished() -> void:
	var loading_instance = loading.instantiate()
	get_tree().root.add_child(loading_instance)
	queue_free()
