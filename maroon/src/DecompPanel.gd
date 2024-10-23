extends StaticBody3D

signal button_pressed

var button_name = "decomp"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func interact(player: CharacterBody3D) -> void:
	button_pressed.emit(button_name)
