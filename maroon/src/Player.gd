extends CharacterBody3D

enum PlayerState {
	STANDING,
	MOVING,
	JUMPING,
	IN_MENU
}

var state: PlayerState = PlayerState.STANDING

# movement variables
@export var movment_speed = 200
@export var running_speed = 250
@export var acceleration = 15
var direction = Vector3.ZERO

# gravity variables
@export var gravity = -20
@export var jump_height = 450
@export var terminal_velocity = -100
var vertical_speed = 0.0

# interaction variables
@onready var InteractionRay: RayCast3D = $Head/InteractionRay
var interactible_object: Object = null

# mouse motion variables
@onready var Head = $Head

# radar system variables
@export var RadarSystem: Node = null 
@onready var RadarPoinsts: Node2D = $Head/Eyes/PlayerUI/Radar/Points

var InEnv = preload("res://InsideEnviroment.tres")
var OutEnv = preload("res://OutsideEnviroment.tres")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
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
			
	move_and_slide()
	
func manage_gravity(delta: float) -> void:
	if not is_on_floor() and vertical_speed > terminal_velocity:
		vertical_speed += gravity*delta
	else:
		vertical_speed = 0
	if is_on_ceiling():
		vertical_speed = -20
		
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
	
	# only queue a redraw when there is something to draw
	if RadarSystem.get_child_count() > 0:
		RadarPoinsts.queue_redraw()
		
func manage_mouse() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else: 
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
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
		if Input.is_action_pressed("sprint"):
			goal_speed = running_speed*delta
		velocity = velocity.move_toward(direction*goal_speed, acceleration*delta)
	
	manage_interaction()
	manage_radar()
	manage_mouse()
	
	
func jumping(delta: float) -> void:
	vertical_speed = jump_height*delta
	velocity.y = vertical_speed
	state = PlayerState.STANDING


func _on_in_warehouse_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var tween = get_tree().create_tween()
		var Env: Environment = Head.get_node("Eyes").environment.duplicate()
		tween.tween_property(Env, "background_color", InEnv.background_color, 0.1)
		tween.tween_property(Env, "background_energy_multiplier", InEnv.background_energy_multiplier, 0.1)
		tween.tween_property(Env, "fog_light_color", InEnv.fog_light_color, 0.1)
		tween.tween_property(Env, "fog_density", InEnv.fog_density, 0.1)
		Head.get_node("Eyes").environment = Env
		

func _on_in_warehouse_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		var tween = get_tree().create_tween()
		var Env: Environment = Head.get_node("Eyes").environment.duplicate()
		tween.tween_property(Env, "background_color", OutEnv.background_color, 0.1)
		tween.tween_property(Env, "background_energy_multiplier", OutEnv.background_energy_multiplier, 0.1)
		tween.tween_property(Env, "fog_light_color", OutEnv.fog_light_color, 0.1)
		tween.tween_property(Env, "fog_density", OutEnv.fog_density, 0.1)
		Head.get_node("Eyes").environment = Env


func _on_decompression_decompresing(entering: bool) -> void:
	if entering:
		var tween = get_tree().create_tween()
		var Env: Environment = Head.get_node("Eyes").environment.duplicate()
		tween.tween_property(Env, "background_color", InEnv.background_color, 0.1)
		tween.tween_property(Env, "background_energy_multiplier", InEnv.background_energy_multiplier, 0.1)
		tween.tween_property(Env, "fog_light_color", InEnv.fog_light_color, 0.1)
		tween.tween_property(Env, "fog_density", InEnv.fog_density, 0.1)
		Head.get_node("Eyes").environment = Env
	else:
		var tween = get_tree().create_tween()
		var Env: Environment = Head.get_node("Eyes").environment.duplicate()
		tween.tween_property(Env, "background_color", OutEnv.background_color, 0.1)
		tween.tween_property(Env, "background_energy_multiplier", OutEnv.background_energy_multiplier, 0.1)
		tween.tween_property(Env, "fog_light_color", OutEnv.fog_light_color, 0.1)
		tween.tween_property(Env, "fog_density", OutEnv.fog_density, 0.1)
		Head.get_node("Eyes").environment = Env
		
