extends Area3D

@export var downloadeble_positions: Array[Node3D]

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
		
	for pos in downloadeble_positions:
		if pos == null:
			continue
			
		pos.add_to_group("OnRadar")
	
	queue_free()
