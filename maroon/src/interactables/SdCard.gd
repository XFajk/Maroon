extends StaticBody3D

@export var downloadeble_positions: Array[Node3D]
@export var RadarSystem: Node3D = null
@export var outlines: Array[MeshInstance3D]

func _ready() -> void:
	stop_showing_interaction()

func interact(player: CharacterBody3D) -> void:
	if RadarSystem == null:
		return
		
	for pos in downloadeble_positions:
		if pos == null:
			continue
		var cached_global_position: Vector3 = pos.global_position
		pos.get_parent().remove_child(pos)
		RadarSystem.add_child(pos)
		pos.global_position = cached_global_position
		
	queue_free()

func stop_showing_interaction() -> void:
	
	if outlines.size() < 1:
		return
		
	for outline in outlines:
		outline.visible = false
	
func show_interaction() -> void:
	
	if outlines.size() < 1:
		return
		
	for outline in outlines:
		outline.visible = true
