extends StaticBody3D

@export var log_mointor_transiton_speed = 1.0
@export var outlines: Array[MeshInstance3D]

@export var logs: Array[Log] = []

var fingerprint_scene: PackedScene = preload("res://scenes/2D/FingerPrintMinigame.tscn")
@onready var CameraPosition: Node3D = $CameraPosition
@onready var TitleSound: AudioStreamPlayer3D = $TitleSound

@export var voice_line: AudioStreamPlayer = null
@export_multiline var voice_line_line: String = ""

@export var not_acessible_voice_line: AudioStreamPlayer = null
@export_multiline var not_acessible_voice_line_line: String = ""

@export var acessible: bool = false

@export var door_to_open: Node3D = null
var player: CharacterBody3D = null

func _ready() -> void:
	stop_showing_interaction()

func interact(player: CharacterBody3D) -> void:
	if not acessible:
		player.voice_line = not_acessible_voice_line
		player.voice_line_line = not_acessible_voice_line_line
		player.say_voice_line()
		return
	Saving.save()
	
	TitleSound.play()
	
	self.player = player
	player.voice_line = voice_line
	player.voice_line_line = voice_line_line
	
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel()
	
	player.state = player.PlayerState.IN_LOG_MONITOR
	player.PlayerUI.hide()
	player.direction = Vector3.ZERO
	player.velocity = Vector3.ZERO
	
	var player_camera: Camera3D = player.Eyes
	
	var goal_rotation: Vector3 = CameraPosition.global_rotation
	
	# GODOT BULSHIT
	if abs(player_camera.global_rotation.y - goal_rotation.y) > PI:
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
	var fingerprint_instance = fingerprint_scene.instantiate()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	fingerprint_instance.player = player
	fingerprint_instance.door_to_open = door_to_open
	get_tree().root.add_child(fingerprint_instance)
	
func saveout() -> Dictionary:
	return {
		"is_locked": door_to_open.is_locked
	}
	
func loadin(save_data: Dictionary) -> void:
	stop_showing_interaction()
	door_to_open.is_locked = bool(save_data.get("is_locked"))
