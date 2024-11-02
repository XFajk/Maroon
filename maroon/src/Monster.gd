extends CharacterBody3D

enum MonsterState {
	SCREAMING,
	RUNNING,
	LOOKING, # for a different path to the player
	IDLE
}

var state: MonsterState = MonsterState.SCREAMING

# movement variables
@export var running_speed: float = 5.0

# Animation variables
@onready var AnimationManager: AnimationPlayer = $AnimationManager

# AI variables
@export var Player: CharacterBody3D = null
@export var PlayerRespawnPoint: Node3D = null
@export var Homes: Node3D = null
@export var ChaseStarter: Area3D = null

@onready var Agent: NavigationAgent3D = $Agent
@onready var LookingTimer: Timer = $LookingTimer

var chosen_home: Node3D = null
var go_home: bool = false

func _ready() -> void:
	AnimationManager.animation_finished.connect(change_state_after_animation)
	
func _physics_process(delta: float) -> void:
	match state:
		MonsterState.SCREAMING:
			screaming(delta)
		MonsterState.RUNNING:
			running(delta)
		MonsterState.LOOKING:
			looking(delta)
			
	move_and_slide()
			
func manage_path_finding() -> void:
	if Player == null:
		print("MONSTER SCRIPT: No player assigned")
		return
	
	var direction: Vector3 = Vector3.ZERO
	
	Agent.target_position = Player.global_position
	
	if not Agent.is_target_reachable():
		if not go_home:
			if LookingTimer.is_stopped():
				LookingTimer.start()
		else:
			Agent.target_position = chosen_home.global_position
			if not Agent.is_target_reachable():
				state = MonsterState.SCREAMING 
	else:
		go_home = false
		chosen_home = null
		LookingTimer.stop()
	
	direction = Agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = direction * running_speed
	
	look_at(global_position+Vector3(direction.x, 0, direction.z)*1000)
			
func screaming(delta: float) -> void:
	AnimationManager.play("screaming")
	velocity = Vector3.ZERO
	
func running(delta: float) -> void:
	AnimationManager.play("Run ", -1, 2.0)
	manage_path_finding()
	
	if Agent.is_target_reached() and go_home:
		state = MonsterState.SCREAMING
	
func looking(delta: float) -> void:
	AnimationManager.play("looking", -1, 1.5)
	velocity = Vector3.ZERO
	Agent.target_position = Player.global_position
	
	
func change_state_after_animation(animation_name: StringName) -> void:
	match animation_name:
		"screaming":
			state = MonsterState.RUNNING
		"looking":
			if Agent.is_target_reachable():
				state = MonsterState.RUNNING
			else:
				if Homes == null:
					print("MONSTER SCRIPT: No homes assigned")
					return
				select_closest_home()
				go_home = true
				state = MonsterState.RUNNING

func select_closest_home():
	var closest_target = 10000.0
	for home in Homes.get_children():
		Agent.target_position = home.global_position
		
		var distance_to_target = Agent.distance_to_target()
		
		if distance_to_target < closest_target:
			closest_target = distance_to_target
			chosen_home = home

func _on_looking_timer_timeout() -> void:
	state = MonsterState.LOOKING


func _on_kill_area_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
		
	ChaseStarter.monitoring = true
	Player.global_position = PlayerRespawnPoint.global_position
	Player.global_rotation = PlayerRespawnPoint.global_rotation
	Player.StaminaBar.value = 100
	Saving.disable_saving = false
	queue_free()
	
