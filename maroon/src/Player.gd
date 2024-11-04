extends CharacterBody3D

enum PlayerState {
	STANDING,
	MOVING,
	JUMPING,
	IN_LOG_MONITOR,
	NOTHING,
}

var state: PlayerState = PlayerState.STANDING

# movement variables
@export var movment_speed = 200
@export var running_speed = 400
@export var acceleration = 15
var direction = Vector3.ZERO
var was_running = false

var indoor_walking: Array[AudioStream] = [
	preload("res://assets/Sounds/walk_0.wav"),
	preload("res://assets/Sounds/walk_1.wav"),
	preload("res://assets/Sounds/walk_2.wav")
]

var indoor_running: Array[AudioStream] = [
	preload("res://assets/Sounds/run_0.wav"),
	preload("res://assets/Sounds/run_1.wav"),
	preload("res://assets/Sounds/run_2.wav")
]

var outdoor_walking: Array[AudioStream] = [
	preload("res://assets/Sounds/walk_0_out.wav"),
	preload("res://assets/Sounds/walk_1_out.wav"),
	preload("res://assets/Sounds/walk_2_out.wav")
]

var outdoor_running: Array[AudioStream] = [
	preload("res://assets/Sounds/run_1_out.wav")
]

# stamina variables
@onready var StaminaBar: HSlider = $Head/Eyes/PlayerUI/StaminaBar
@export var stamina_recharge_speed = 10
@export var stamina_depletion_speed = 5

# gravity variables
@export var gravity = -20
@export var jump_height = 450
@export var terminal_velocity = -100
var vertical_speed = 0.0

# interaction variables
@onready var InteractionRay: RayCast3D = $Head/InteractionRay
var interactible_object: Object = null

# mouse motion variables
@onready var Head: Node3D = $Head
@onready var Eyes: Camera3D = $Head/Eyes

# radar system variables
@onready var RadarPoinsts: Node2D = $Head/Eyes/PlayerUI/Radar/Points

# pause variables
@onready var PauseMenu: Control = $Head/Eyes/PlayerUI/PauseMenu
@onready var PlayerUI: Control = $Head/Eyes/PlayerUI

# subtitles and voicelines variables
@onready var SubTitles: Label = $Head/Eyes/PlayerUI/SubTitles

var voice_line: AudioStream = null
var voice_line_line: String = ""
var subtitles_timer: Timer = Timer.new()

# warehouse variables
var cansiters_picked_up = 0

# enviroment transition variables
var InEnv = preload("res://InsideEnviroment.tres")
var OutEnv = preload("res://OutsideEnviroment.tres")
var inside: bool = false

# final cutscene variables
var die_after: bool = false
var Monster: Node3D = null
var end_scene: PackedScene = preload("res://scenes/2D/End.tscn")

func _ready() -> void:
	Eyes.environment = OutEnv
	for obj in get_tree().get_nodes_in_group("InsideObj"):
		obj.hide()
	for obj in get_tree().get_nodes_in_group("OutsideObj"):
		obj.show()	
	#Saving.delete()
	Saving.load()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PauseMenu.hide()
	subtitles_timer.autostart = false
	subtitles_timer.one_shot = true
	subtitles_timer.timeout.connect(delete_after_voice_line_finish)
	add_child(subtitles_timer)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and state != PlayerState.IN_LOG_MONITOR and state != PlayerState.NOTHING and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x*Global.mouse_sens))
		Head.rotate_x(deg_to_rad(-event.relative.y*Global.mouse_sens))
		Head.rotation.x = deg_to_rad(clamp(Head.rotation_degrees.x, -70, 70))
		
func _physics_process(delta: float) -> void:
	match state:
		PlayerState.STANDING:
			standing(delta)
		PlayerState.MOVING:
			moving(delta)
		PlayerState.JUMPING:
			jumping(delta)
		PlayerState.IN_LOG_MONITOR:
			reading_logs(delta)
			
	move_and_slide()
	
func manage_gravity(delta: float) -> void:
	if not is_on_floor() and vertical_speed > terminal_velocity:
		vertical_speed += gravity*delta
	else:
		vertical_speed = 0
	if is_on_ceiling():
		vertical_speed = -2.0
		
	velocity.y = vertical_speed
	
func manage_interaction() -> void:
	if interactible_object != null:
		interactible_object.stop_showing_interaction()
	
	var object: Node = InteractionRay.get_collider()
	
	if object != null:
		if object.is_in_group("Interactable") and Input.is_action_just_pressed("interact"):
			object.interact(self)
			interactible_object = object
		elif object.is_in_group("Interactable"):
			object.show_interaction()
			interactible_object = object
		else:
			interactible_object = null
			
func manage_radar() -> void:
		
	RadarPoinsts.topdown_player_position = Vector2(global_position.x, global_position.z)
	RadarPoinsts.topdown_player_angle = global_rotation.y
	
	# append points to the radar
	for child in get_tree().get_nodes_in_group("OnRadar"):
		RadarPoinsts.points.append(Vector2(child.global_position.x, child.global_position.z))
	

	RadarPoinsts.queue_redraw()
		
func manage_mouse() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			PauseMenu.show()
			Engine.time_scale = 0.0
		else: 
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Engine.time_scale = 1.0
			PauseMenu.hide()
			
func manage_walking_sound() -> void:
	if not is_on_floor():
		return
	if inside:
		if Input.is_action_pressed("sprint") and StaminaBar.value > 0:
			if not was_running:
				$FeetSounds.stop()
				was_running = true
			if was_running:
				if not $FeetSounds.playing:
					$FeetSounds.stream = indoor_running.pick_random()
					$FeetSounds.play()
		else:
			if was_running:
				$FeetSounds.stop()
				was_running = false
			if not was_running: 
				if not $FeetSounds.playing:
					$FeetSounds.stream = indoor_walking.pick_random()
					$FeetSounds.play()
	else:
		if Input.is_action_pressed("sprint") and StaminaBar.value > 0:
			if not was_running:
				$FeetSounds.stop()
				was_running = true
			if was_running:
				if not $FeetSounds.playing:
					$FeetSounds.stream = outdoor_running.pick_random()
					$FeetSounds.play()
		else:
			if was_running:
				$FeetSounds.stop()
				was_running = false
			if not was_running: 
				if not $FeetSounds.playing:
					$FeetSounds.stream = outdoor_walking.pick_random()
					$FeetSounds.play()
			
func standing(delta: float) -> void:
	
	$FeetSounds.stop()
	state = PlayerState.STANDING
	
	if Input.is_action_pressed("forward"):
		state = PlayerState.MOVING
	if Input.is_action_pressed("backward"):
		state = PlayerState.MOVING
	if Input.is_action_pressed("left"):
		state = PlayerState.MOVING
	if Input.is_action_pressed("right"):
		state = PlayerState.MOVING
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = PlayerState.JUMPING
		
	manage_gravity(delta)
	
	velocity = velocity.move_toward(Vector3.ZERO, acceleration*delta)
	
	StaminaBar.value += stamina_recharge_speed*delta
	
	manage_interaction()
	manage_radar()
	manage_mouse()

func moving(delta: float) -> void:
	
	state = PlayerState.STANDING
	
	if Input.is_action_pressed("forward"):
		state = PlayerState.MOVING
		direction -= transform.basis.z
	if Input.is_action_pressed("backward"):
		state = PlayerState.MOVING
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		state = PlayerState.MOVING
		direction -= transform.basis.x
	if Input.is_action_pressed("right"):
		state = PlayerState.MOVING
		direction += transform.basis.x
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = PlayerState.JUMPING
		
	manage_gravity(delta)
	
	manage_walking_sound()
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		var goal_speed = movment_speed*delta
		if Input.is_action_pressed("sprint") and StaminaBar.value > 0:
			was_running = true
			StaminaBar.value -= stamina_depletion_speed*delta
			goal_speed = running_speed*delta
		elif not Input.is_action_pressed("sprint"):
			was_running = false
			StaminaBar.value += stamina_recharge_speed*delta

		velocity = velocity.move_toward(direction*goal_speed, acceleration*delta)
	
	manage_interaction()
	manage_radar()
	manage_mouse()
	
func jumping(delta: float) -> void:
	vertical_speed = jump_height*delta
	velocity.y = vertical_speed
	state = PlayerState.STANDING
	
	StaminaBar.value += stamina_recharge_speed*delta
	
func reading_logs(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not die_after:
		var tween = get_tree().create_tween()
		tween.set_parallel()
		tween.finished.connect(return_to_standing)
		
		tween.tween_property(Eyes, "position", Vector3.ZERO, 0.5)
		tween.tween_property(Eyes, "rotation", Vector3.ZERO, 0.5)
		PlayerUI.show()
		say_voice_line()
	elif Input.is_action_just_pressed("ui_cancel") and die_after:
		var tween = get_tree().create_tween()
		tween.set_parallel()
		tween.finished.connect(kill)
		
		var CameraPosition: Node3D = Monster.get_node("CameraPosistion1")
		var goal_rotation: Vector3 = CameraPosition.global_rotation
		
		# GODOT BULSHIT
		if abs(Eyes.global_rotation.y - goal_rotation.y) > 180:
			if Eyes.global_rotation_degrees.y >= 0 and CameraPosition.global_rotation_degrees.y < 0:
				goal_rotation.y += PI*2
			elif Eyes.global_rotation_degrees.y < 0 and CameraPosition.global_rotation_degrees.y >= 0:
				goal_rotation.y -= PI*2
		
		tween.tween_property(Eyes, "global_position", CameraPosition.global_position, 2)
		tween.tween_property(Eyes, "global_rotation", goal_rotation, 2)
		
	StaminaBar.value += stamina_recharge_speed*delta


func _on_in_warehouse_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		inside = true
		$MusicPlayer.stop()
		hide_all_outside_objects()
		tween_camera_env_to(InEnv)
		

func _on_in_warehouse_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		inside = false
		$MusicPlayer.autoplay = true
		$MusicPlayer.play()
		hide_all_inside_objects()
		tween_camera_env_to(OutEnv)


func _on_decompression_decompresing(entering: bool) -> void:
	if entering:
		inside = true
		$MusicPlayer.stop()
		hide_all_outside_objects()
		tween_camera_env_to(InEnv)
	else:
		inside = false
		$MusicPlayer.autoplay = true
		$MusicPlayer.play()
		hide_all_inside_objects()
		tween_camera_env_to(OutEnv)
	
func tween_camera_env_to(goal_env: Environment, transition_speed: float = 0.2) -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel()
	
	# get the Camera enviroment
	var Env: Environment = Eyes.environment.duplicate()
	# transition the enviroment to the desired envirioment
	tween.tween_property(Env, "background_color", goal_env.background_color, transition_speed)
	tween.tween_property(Env, "background_energy_multiplier", goal_env.background_energy_multiplier, transition_speed)
	tween.tween_property(Env, "fog_light_color", goal_env.fog_light_color, transition_speed)
	tween.tween_property(Env, "fog_density", goal_env.fog_density, transition_speed)
	tween.tween_property(Env, "fog_light_energy", goal_env.fog_light_energy, transition_speed)
	tween.tween_property(Env, "fog_sun_scatter", goal_env.fog_sun_scatter, transition_speed)
	
	# set the new planned to change enviroment to the cameras enviroment
	Eyes.environment = Env
	
func return_to_standing() -> void:
	state = PlayerState.STANDING
	
func kill() -> void:
	var animation_manager: AnimationPlayer = Monster.get_node("AnimationManager")
	animation_manager.play("Slapp", -1, 2.0)
	animation_manager.animation_finished.connect(transition_to_end)
	
func transition_to_end(am: StringName) -> void:
	get_tree().root.add_child(end_scene.instantiate())
	get_parent().queue_free()
	
func hide_all_inside_objects() -> void:
	for obj in get_tree().get_nodes_in_group("InsideObj"):
		obj.hide()
	for obj in get_tree().get_nodes_in_group("OutsideObj"):
		obj.show()
		
func hide_all_outside_objects() -> void:
	for obj in get_tree().get_nodes_in_group("OutsideObj"):
		obj.hide()
	for obj in get_tree().get_nodes_in_group("InsideObj"):
		obj.show()
	
	
func say_voice_line() -> void:
	print("saying")
	SubTitles.text = voice_line_line
	
	if voice_line == null:
		subtitles_timer.start(voice_line_line.length()*0.1)
		return
	$VoiceLinePlayer.stream = voice_line
	$VoiceLinePlayer.play()
	
func delete_after_voice_line_finish() -> void:
	print("deleting")
	SubTitles.text = ""
	voice_line_line = ""
	if voice_line != null:
		voice_line.queue_free()
	
func saveout() -> Dictionary:
	return {
		"position": global_position,
		"rotation": global_rotation,
		"state": state,
		"inside": inside,
		"cansiters_picked_up": cansiters_picked_up
	}
	
	
func loadin(save_data: Dictionary) -> void:
	# setting the player position and rotation
	global_position = str_to_var("Vector3" + save_data.get("position"))
	global_rotation = str_to_var("Vector3" + save_data.get("rotation"))
	
	state =  int(save_data.get("state"))
	
	inside = bool(save_data.get("inside"))
	if inside:
		$MusicPlayer.stop()
		Eyes.environment = InEnv.duplicate()
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.show()
	else:
		$MusicPlayer.autoplay = true
		$MusicPlayer.play()
		Eyes.environment = OutEnv.duplicate()
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.show()
			
	cansiters_picked_up = int(save_data.get("cansiters_picked_up"))
	


func _on_music_player_finished() -> void:
	$MusicPlayer.play()
