extends Node

@export var RadarSystem: Node = null
@export var FallingCube: RigidBody3D = null
@export var Monster: Node3D = null

@export var HorrorTrigrer1: Area3D = null
@export var MonsterPosition1: Node3D = null

@export var HorrorTrigrer3: Area3D = null
@export var MonsterPosition3: Node3D = null

@export var HorrorTrigrer4: Area3D = null

@export var HorrorTrigrer5: Area3D = null



func _on_horro_triger_1_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if Monster == null:
		print("TRIGER MANAGER <WAREHOUSE>: Forgot to assign Monster")
		return
	if MonsterPosition1 == null:
		print("TRIGER MANAGER <WAREHOUSE>: Forgot to assign MonsterPosition")
		return

	Monster.global_position = MonsterPosition1.global_position
	Monster.global_rotation = MonsterPosition1.global_rotation
	
	Monster.get_node("TrigerTimer").wait_time = 3
	Monster.get_node("DisapearTimer").wait_time = 3.04
	
	Monster.get_node("TrigerTimer").start()
	Monster.get_node("DisapearTimer").start()
	
	HorrorTrigrer1.queue_free()
	
	
func _on_horro_triger_3_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if Monster == null:
		print("TRIGER MANAGER <WAREHOUSE>: Forgot to assign Monster")
		return
	if MonsterPosition3 == null:
		print("TRIGER MANAGER <WAREHOUSE>: Forgot to assign MonsterPosition")
		return

	Monster.global_position = MonsterPosition3.global_position
	Monster.global_rotation = MonsterPosition3.global_rotation
	
	Monster.get_node("TrigerTimer").wait_time = 2
	Monster.get_node("DisapearTimer").wait_time = 2.2
	
	Monster.get_node("DisapearTimer").start()
	Monster.get_node("TrigerTimer").start()
	
	HorrorTrigrer3.queue_free()

func _on_horro_triger_4_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if Monster == null:
		print("TRIGER MANAGER <WAREHOUSE>: Forgot to assign Monster")
		return
		
	Monster.rotate_y(deg_to_rad(90))
	Monster.global_position = body.global_position - Vector3(2, 0, 0)
	
	Monster.get_node("DisapearTimer").wait_time = 2
	Monster.get_node("DisapearTimer").start()
	
	HorrorTrigrer4.queue_free()


func _on_horro_triger_5_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if FallingCube == null:
		print("TRIGER MANAGER <WAREHOUSE>: Forgot to assign Cube")
		return
		
	FallingCube.apply_impulse(Vector3(4, 0, 0))
	HorrorTrigrer5.queue_free()

func _on_disapear_timer_timeout() -> void:
	Monster.global_position = Vector3(0, -1000, 0)
	

func _on_triger_3_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		Monster,
		"global_position",
		Monster.global_position+Monster.transform.basis.x*10,
		1
	)
