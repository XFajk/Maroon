extends StaticBody3D

@export var log_mointor_transiton_speed = 1.0
@export var outlines: Array[MeshInstance3D]

@export var logs: Array[Log] = []

var pcb_scene: PackedScene = preload("res://scenes/2D/PCBMinigame.tscn")
@onready var CameraPosition: Node3D = $ControlPanel/CameraPosition
@onready var TitleSound: AudioStreamPlayer3D = $ControlPanel/TitleSound

@export var voice_line: AudioStreamPlayer = null
@export_multiline var voice_line_line: String = ""

@export var not_acessible_voice_line: AudioStreamPlayer = null
@export_multiline var not_acessible_voice_line_line: String = ""

@export var acessible: bool = false

var player: CharacterBody3D = null
var done: bool = false

@onready var control_panel_screen_material: StandardMaterial3D = $ControlPanel.get_surface_override_material(4)
@onready var screen_light: OmniLight3D = $ControlPanel/ScreenLight

@export var finger_print_panel: StaticBody3D = null

func _ready() -> void:
	stop_showing_interaction()
	
func _process(_delta: float) -> void:
	if done:
		finger_print_panel.acessible = true

func interact(player: CharacterBody3D) -> void:
	if done:
		return
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
	
	player.state = player.PlayerState.NOTHING
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
		outline.hide()
	
func show_interaction() -> void:
	if done:
		return
	if outlines.size() < 1:
		return
		
	for outline in outlines:
		outline.show()
		
func transition() -> void:
	var pcb_instance = pcb_scene.instantiate()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pcb_instance.player = player
	pcb_instance.panel = self
	get_tree().root.add_child(pcb_instance)
	
func saveout() -> Dictionary:
	return {
		"done": done
	}
	
func loadin(save_data: Dictionary) -> void:
	done = bool(save_data.get("done"))
	print(done)
