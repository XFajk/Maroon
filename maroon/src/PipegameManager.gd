extends Node2D

@onready var grid = $GridContainer
@onready var pipe = get_node("res://scenes/pipe.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(400):
		grid.add_child(pipe)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
