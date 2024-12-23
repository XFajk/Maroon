extends StaticBody3D

@export var Player: CharacterBody3D = null
@export var Monster: Node3D = null

@export_category("defaultly assigned")
@export var FallingBox: RigidBody3D = null

@export_subgroup("Start Spots")
@export var MonsterStartSpot1: Node3D = null
@export var MonsterStartSpot2: Node3D = null
@export var MonsterStartSpot3: Node3D = null

@export_subgroup("Finish Spots")
@export var MonsterFinishSpot1: Node3D = null
@export var MonsterFinishSpot2: Node3D = null

@export_group("Triggers")
@export var EventTrigger1: Area3D = null
@export var EventTrigger2: Area3D = null
@export var EventTrigger3: Area3D = null
@export var EventTrigger4: Area3D = null
@export var EventTrigger5: Area3D = null

var track_player: bool = false

func _physics_process(delta: float) -> void:
	if track_player:
		var local_player_pos = to_local(Player.global_position)
		
		EventTrigger5.position.z = local_player_pos.z
		MonsterStartSpot3.position.z = local_player_pos.z
		
		if Player.state == Player.PlayerState.MOVING:
			Monster.get_node("AnimationManager").play("Walk")
		else:
			Monster.get_node("AnimationManager").pause()
		
		Monster.global_position = MonsterStartSpot3.global_position
		Monster.global_rotation = MonsterStartSpot3.global_rotation
	

func _on_event_trigger_1_body_entered(body: Node3D) -> void:

	if not body.is_in_group("Player"):
		return
		
	track_player = true
	
	Monster.global_position = MonsterStartSpot3.global_position
	Monster.global_rotation = MonsterStartSpot3.global_rotation


func _on_event_trigger_1_body_exited(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
		
	tween_finish()
	track_player = false
	if EventTrigger5 != null:
		EventTrigger5.queue_free()
	if EventTrigger1 != null:
		EventTrigger1.queue_free()


func _on_event_triggee_2_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
		
	FallingBox.apply_impulse((-transform.basis.z + transform.basis.x).normalized()*4)
	EventTrigger2.queue_free()


func _on_event_trigger_3_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
		
	var tween: Tween = get_tree().create_tween()
		
	Monster.global_position = MonsterStartSpot2.global_position
	Monster.global_rotation = MonsterStartSpot2.global_rotation
	
	Monster.get_node("AnimationManager").play("Idle")
	
	tween.tween_property(
		Monster,
		"global_position",
		MonsterFinishSpot2.global_position, 1
	).set_delay(2)
	tween.tween_property(
		Monster,
		"global_rotation",
		MonsterFinishSpot2.global_rotation, 0.0
	)
	
	tween.finished.connect(tween_finish)
	
	EventTrigger3.queue_free()
	


func _on_event_trigger_4_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	
	var tween: Tween = get_tree().create_tween()	
		
	Monster.global_position = MonsterStartSpot1.global_position
	Monster.global_rotation = MonsterStartSpot1.global_rotation
	
	Monster.get_node("AnimationManager").play("Idle")
	
	tween.tween_property(
		Monster,
		"global_position",
		MonsterFinishSpot1.global_position, 1
	).set_delay(3)
	tween.tween_property(
		Monster,
		"global_rotation",
		MonsterFinishSpot1.global_rotation, 0.0
	)
	
	tween.finished.connect(tween_finish)
	
	EventTrigger4.queue_free()
	
func _on_event_trigger_5_area_entered(area: Area3D) -> void:
	if not area.is_in_group("Player") and track_player:
		return
	
	if EventTrigger5 != null:
		EventTrigger5.queue_free()
	if EventTrigger1 != null:
		EventTrigger1.queue_free()
	track_player = false
	tween_finish()
	

func tween_finish() -> void:
	Monster.global_position -= Vector3(0, -1000, 0)
