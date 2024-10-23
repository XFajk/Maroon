extends Node3D

@onready var inside_door = $Doors
@onready var outside_door = $MainDoor

@onready var decomp_timer = $DecompTimer

var is_decompressing: bool = false
@export var decompressing_time = 5 #seconds

func _process(delta: float) -> void:
	pass


func _on_button_pressed(button_name) -> void:
	if button_name == "outside":
		outside_door.is_locked = false
	if button_name == "inside":
		inside_door.is_locked = false
	if button_name == "decomp":
		inside_door.is_locked = true
		outside_door.is_locked = true
		is_decompressing = true
		decomp_timer.start(decompressing_time)
