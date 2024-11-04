extends Node3D

@onready var door_1: StaticBody3D = $Door1
@onready var door_2: StaticBody3D = $Door2

@onready var opening_area = $OpeningRange

@export var door_width = 0.6 #meters
@export var door_speed = 2

#@export var opened_by_button = false

var is_opened: bool = false
@export var is_locked: bool = false
var door_progress = 0 #0 -> Closed, 1 -> Fully opened


func _process(delta: float) -> void:
	if is_locked:
		if door_progress > 0:
			door_progress -= door_speed * delta
	elif is_opened and door_progress < 1:
		door_progress += door_speed * delta
	elif not is_opened and door_progress > 0:
		door_progress -= door_speed * delta
	
	door_1.position.z = door_progress * door_width
	door_2.position.z = -door_progress * door_width



func _on_opening_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_opened = true
		if not is_locked:
			$Opening.play()


func _on_opening_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_opened = false
		if not is_locked:
			$Closing.play()
