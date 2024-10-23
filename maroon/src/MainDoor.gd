extends StaticBody3D

@onready var opening_area = $OpeningRange

@export var door_height = 2.3 #meters
@export var door_speed = 2

var is_opened: bool = false
var is_locked: bool = true
var door_progress = 0 #0 -> Closed, 1 -> Fully opened


func _process(delta: float) -> void:
	if is_locked:
		if door_progress > 0:
			door_progress -= door_speed * delta
	elif is_opened and door_progress < 1:
		door_progress += door_speed * delta
	elif not is_opened and door_progress > 0:
		door_progress -= door_speed * delta
	
	position.y = -door_progress * door_height



func _on_opening_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_opened = true


func _on_opening_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		is_opened = false
