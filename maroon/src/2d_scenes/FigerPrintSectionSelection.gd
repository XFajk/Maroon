extends Area2D

var selected: bool = false
var mouse_in: bool = false

func _ready() -> void:
	mouse_entered.connect(set_mouse_in_to_true)
	mouse_exited.connect(set_mouse_in_to_false)
	
func _process(_delta: float) -> void:
	if mouse_in and Input.is_action_just_pressed("left_click"):
		if not selected:
			$SelectedRect.show()
		else:
			$SelectedRect.hide()
		selected = not selected
	
func set_mouse_in_to_false() -> void:
	mouse_in = false
	
func set_mouse_in_to_true() -> void:
	mouse_in = true
	
