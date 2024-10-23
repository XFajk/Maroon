extends Node3D

@onready var inside_door = $Doors
@onready var outside_door = $MainDoor

@onready var decomp_timer = $DecompTimer
@onready var unlocked_timer = $UnlockedTimer

var is_decompressing: bool = false
@export var decompressing_time = 5 #seconds
@export var unlocked_time = 7 #seconds

var entering: bool #used to determine which door to open after decompressing


func _on_button_pressed(button_name) -> void:
	if button_name == "outside":
		outside_door.is_locked = false
		entering = true
		unlocked_timer.start(unlocked_time)
	if button_name == "inside":
		inside_door.is_locked = false
		entering = false
		unlocked_timer.start(unlocked_time)
	if button_name == "decomp":
		if not is_decompressing:
			inside_door.is_locked = true
			outside_door.is_locked = true
			is_decompressing = true
			decomp_timer.start(decompressing_time)


func _on_decomp_timer_timeout() -> void:
	is_decompressing = false
	if entering:
		inside_door.is_locked = false
	else:
		outside_door.is_locked = false
	unlocked_timer.start(unlocked_time)
	entering = not entering


func _on_unlocked_timer_timeout() -> void:
	outside_door.is_locked = true
	inside_door.is_locked = true
