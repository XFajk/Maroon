extends Area3D

func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	
	var new_static_body: StaticBody3D = StaticBody3D.new()
	add_child(new_static_body)
	new_static_body.add_child($CollisionShape3D.duplicate())
	
	Saving.disable_saving = false
