extends Node3D

@onready var door_1: StaticBody3D = $Door1
@onready var door_2: StaticBody3D = $Door2

@onready var opening_area = $OpeningRange

@export var door_width = 0.6 #meters
@export var door_speed = 2

var is_opened: bool = false
var door_progress = 0 #0 -> Closed, 1 -> Fully opened

var door_1_initial_pos_z
var door_2_initial_pos_z

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_opened and door_progress < 1:
		door_progress += door_speed * delta
	elif not is_opened and door_progress > 0:
		door_progress -= door_speed * delta
	
	door_1.position.z = door_progress * door_width
	door_2.position.z = -door_progress * door_width



func _on_opening_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_opened = true


func _on_opening_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_opened = false
