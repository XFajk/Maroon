extends StaticBody3D

signal button_pressed

@export var button: MeshInstance3D

@export var button_name = "" #for decompression the names "outside_button" and "inside_button" are used

@export var button_depth = 0.03
@export var button_speed = 1
@export var button_press_direction: Vector3 = Vector3(1, 0, 0).normalized()

var button_progress = 0
var button_state = 0 # 0 -> innactive, 1 -> going down, 2 -> going back up

func _process(delta: float) -> void:
	if button_state == 1 and button_progress >= 1:
		button_state = 2
		button_progress = 1
	if button_state == 2 and button_progress <= 0:
		button_state = 0
		button_progress = 0
	
	if button_state == 1:
		button_progress += button_speed * delta * 5
	elif button_state == 2:
		button_progress -= button_speed * delta * 5
	
	button.position = button_press_direction * button_progress * button_depth


func interact(player: CharacterBody3D) -> void:
	button_pressed.emit(button_name)
	button_state = 1
