extends Area3D

@export var Monster: CharacterBody3D = null

var player: CharacterBody3D = null

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if Monster == null:
		return
	
	Monster.show()
	Monster.state = Monster.MonsterState.SCREAMING
	body.state = body.PlayerState.IN_LOG_MONITOR
	var camera_destination: Node3D = Monster.get_node("CameraPosition2")
	
	player = body
	
	player.velocity = Vector3.ZERO
	var player_camera: Camera3D  = player.Eyes
	
	var goal_rotation: Vector3 = camera_destination.global_rotation
	
	# GODOT BULSHIT
	if abs(player_camera.global_rotation.y - goal_rotation.y) > 180:
		if player_camera.global_rotation_degrees.y >= 0 and camera_destination.global_rotation_degrees.y < 0:
			goal_rotation.y += PI*2
		elif player_camera.global_rotation_degrees.y < 0 and camera_destination.global_rotation_degrees.y >= 0:
			goal_rotation.y -= PI*2
	
	var tween = get_tree().create_tween()
	tween.set_parallel()
	
	tween.tween_property(player_camera, "global_position", Monster.get_node("CameraPosition2").global_position, 1.0)
	tween.tween_property(player_camera, "global_rotation", goal_rotation, 1.0)
	
	tween.finished.connect(return_back)

func return_back() -> void:
		var tween = get_tree().create_tween()
		tween.set_parallel()
		tween.finished.connect(player.return_to_standing)
		
		tween.tween_property(player.Eyes, "position", Vector3.ZERO, 0.5).set_delay(2.0)
		tween.tween_property(player.Eyes, "rotation", Vector3.ZERO, 0.5).set_delay(2.0)
