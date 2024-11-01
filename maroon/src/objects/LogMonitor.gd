extends StaticBody3D

@export var log_mointor_transiton_speed = 1.0
@export var outlines: Array[MeshInstance3D]

@export var logs: Array[Log] = []

var LogSystem: PackedScene = preload("res://scenes/2D/LogSystem.tscn")
@onready var CameraPosition: Node3D = $CameraPosition
@onready var TitleSound: AudioStreamPlayer3D = $TitleSound


func _ready() -> void:
	stop_showing_interaction()

func interact(player: CharacterBody3D) -> void:
	Saving.save()
	TitleSound.play()
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel()
	
	player.state = player.PlayerState.IN_LOG_MONITOR
	player.PlayerUI.hide()
	player.direction = Vector3.ZERO
	player.velocity = Vector3.ZERO
	
	var player_camera: Camera3D = player.Eyes
	
	var goal_rotation: Vector3 = CameraPosition.global_rotation
	
	# GODOT BULSHIT
	if abs(player.global_rotation.y - goal_rotation.y) > 180:
		if player_camera.global_rotation_degrees.y >= 0 and CameraPosition.global_rotation_degrees.y < 0:
			goal_rotation.y += PI*2
		elif player_camera.global_rotation_degrees.y < 0 and CameraPosition.global_rotation_degrees.y >= 0:
			goal_rotation.y -= PI*2
	
	tween.tween_property(player_camera, "global_position", CameraPosition.global_position, log_mointor_transiton_speed)
	tween.tween_property(player_camera, "global_rotation", goal_rotation, log_mointor_transiton_speed)
	
	tween.finished.connect(transition)


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
		
func transition() -> void:
	var log_system_instance = LogSystem.instantiate()
	log_system_instance.logs = logs
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().root.add_child(log_system_instance)
