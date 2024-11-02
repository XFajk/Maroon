extends Control

var loading: PackedScene = preload("res://scenes/2D/Loading.tscn")

func _on_yes_pressed() -> void:
	var loading_instance = loading.instantiate()
	get_tree().root.add_child(loading_instance)
	get_parent().get_parent().queue_free()

func _on_no_pressed() -> void:
	Saving.delete()
	var loading_instance = loading.instantiate()
	get_tree().root.add_child(loading_instance)
	get_parent().get_parent().queue_free()
