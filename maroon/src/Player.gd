extends CharacterBody3D

enum PlayerState {
	STANDING,
	MOVING,
	JUMPING,
	IN_LOG_MONITOR
}

var state: PlayerState = PlayerState.STANDING

# movement variables
@export var movment_speed = 200
@export var running_speed = 250
@export var acceleration = 15
var direction = Vector3.ZERO

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
@export var RadarSystem: Node3D = null 
@onready var RadarPoinsts: Node2D = $Head/Eyes/PlayerUI/Radar/Points

# pause variables
@onready var PauseMenu: Control = $Head/Eyes/PlayerUI/PauseMenu

@onready var PlayerUI: Control = $Head/Eyes/PlayerUI

# enviroment transition variables
var InEnv = preload("res://InsideEnviroment.tres")
var OutEnv = preload("res://OutsideEnviroment.tres")
var inside: bool = false

func _ready() -> void:
	for obj in get_tree().get_nodes_in_group("InsideObj"):
		obj.hide()
	for obj in get_tree().get_nodes_in_group("OutsideObj"):
		obj.show()
	Saving.load()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	PauseMenu.hide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and state != PlayerState.IN_LOG_MONITOR and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
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
	if RadarSystem == null: 
		return
		
	RadarPoinsts.topdown_player_position = Vector2(global_position.x, global_position.z)
	RadarPoinsts.topdown_player_angle = global_rotation.y
	
	# append points to the radar
	for child in RadarSystem.get_children():
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
			
func standing(delta: float) -> void:
	
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
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		var goal_speed = movment_speed*delta
		if Input.is_action_pressed("sprint") and StaminaBar.value > 0:
			StaminaBar.value -= stamina_depletion_speed*delta
			goal_speed = running_speed*delta
		else:
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
	if Input.is_action_just_pressed("ui_cancel"):
		var tween = get_tree().create_tween()
		tween.set_parallel()
		tween.finished.connect(return_to_standing)
		
		tween.tween_property(Eyes, "global_position", Head.global_position, 0.5)
		tween.tween_property(Eyes, "global_rotation", Head.global_rotation, 0.5)
		PlayerUI.show()
		
	StaminaBar.value += stamina_recharge_speed*delta


func _on_in_warehouse_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		inside = true
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.show()
		tween_camera_env_to(InEnv)
		

func _on_in_warehouse_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		inside = false
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.show()
		tween_camera_env_to(OutEnv)


func _on_decompression_decompresing(entering: bool) -> void:
	if entering:
		inside = true
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.show()
		tween_camera_env_to(InEnv)
	else:
		inside = false
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.show()
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
	
	# set the new planned to change enviroment to the cameras enviroment
	Eyes.environment = Env
	
func return_to_standing() -> void:
	state = PlayerState.STANDING
	
	
func saveout() -> Dictionary:
	return {
		"position": global_position,
		"rotation": global_rotation,
		"state": state,
		"inside": inside,
	}
	
	
func loadin(save_data: Dictionary) -> void:
	global_position = str_to_var("Vector3" + save_data.get("position"))
	global_rotation = str_to_var("Vector3" + save_data.get("rotation"))
	
	state =  int(save_data.get("state"))
	
	inside = bool(save_data.get("inside"))
	if inside:
		Eyes.environment = InEnv.duplicate()
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.show()
	else:
		Eyes.environment = OutEnv.duplicate()
		for obj in get_tree().get_nodes_in_group("InsideObj"):
			obj.hide()
		for obj in get_tree().get_nodes_in_group("OutsideObj"):
			obj.show()
	
