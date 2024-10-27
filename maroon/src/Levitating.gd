@tool
extends StaticBody3D

@export var speed = 0.05
@export var lev_range = 0.1 #meters
var progress = 0
var count = 0
var original_position

func _ready() -> void:
	randomize()
	count = randf()
	original_position = position

func _process(delta: float) -> void:
	count += speed
	progress = cos(count) / 2 + 1
	
	position = original_position + progress * Vector3.DOWN * lev_range
