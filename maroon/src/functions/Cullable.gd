extends Node3D


func _on_decompression_decompresing(entering: bool) -> void:
	if entering:
		visible = true
	else:
		visible = false
