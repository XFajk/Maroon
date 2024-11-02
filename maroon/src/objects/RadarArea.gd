extends Area3D

@export var downloadeble_positions: Array[Node3D]

var deleted: bool = false

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
		
	for pos in downloadeble_positions:
		if pos == null:
			continue
			
		pos.add_to_group("OnRadar")
	
	deleted = true
	Saving.save()
	queue_free()
	
func saveout() -> Dictionary:
	
	return {
		"deleted": deleted,
	}
	
func loadin(save_data: Dictionary) -> void:
	if bool(save_data.get('deleted')):
		queue_free()
	
