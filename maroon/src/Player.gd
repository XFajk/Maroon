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

@onready var GroundCheck: RayCast3D = $Feet/GroundCheck
@onready var InteractionRay: RayCast3D = $Head/InteractionRay

@onready var Head = $Head

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*Global.mouse_sens))
		Head.rotate_x(deg_to_rad(-event.relative.y*Global.mouse_sens))
		
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
	velocity.y = vertical_speed
	
func manage_interaction() -> void:
	var object: Node = InteractionRay.get_collider()
	if object != null:
		if object.is_in_group("Interactible"):
			object.interact(self)

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
	
	
func jumping(delta: float) -> void:
	vertical_speed = jump_height*delta
	velocity.y = vertical_speed
	state = PlayerState.STANDING
