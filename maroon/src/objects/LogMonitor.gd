extends StaticBody3D

@export var log_mointor_transiton_speed = 1.0
@export var outlines: Array[MeshInstance3D]

@onready var CameraPosition: Node3D = $CameraPosition

func _ready() -> void:
	stop_showing_interaction()

func interact(player: CharacterBody3D) -> void:
	Saving.save()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel()
	
	player.state = player.PlayerState.IN_LOG_MONITOR
	player.PlayerUI.hide()
	player.direction = Vector3.ZERO
	player.velocity = Vector3.ZERO
	
	var player_camera: Camera3D = player.Eyes
	
	tween.tween_property(player_camera, "global_position", CameraPosition.global_position, log_mointor_transiton_speed)
	tween.tween_property(player_camera, "global_rotation", CameraPosition.global_rotation, log_mointor_transiton_speed)

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
