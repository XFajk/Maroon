extends Node2D

@onready var level_sprites: Array = [$Level1, $Level2, $Level3]
@onready var level_images: Array = [
	preload("res://assets/PCBMinigame/images/level1.png"),
	preload("res://assets/PCBMinigame/images/level2.png"),
	preload("res://assets/PCBMinigame/images/level3.png")
]
var level = 0
@onready var dot = $Dot

var starting_directions: Array = [Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
@onready var starting_positions: Array = [$level_1_start, $level_2_start, $level_3_start]
var direction
@export var speed: float = 35
@export var ground_color: Color = Color(0.0745, 0.1608, 0.0353, 1)


func _ready() -> void:
	pass # Replace with function body.
	direction = starting_directions[level]
	global_position = starting_positions[level].global_position	


func _process(delta: float) -> void:
	dot.global_position += direction * speed * delta
	if get_color_under().r < 0.0749 and get_color_under().r > 0.0742:
		print("pizda")
	else:
		queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward"):
		direction = Vector2.UP
	if event.is_action_pressed("backward"):
		direction = Vector2.DOWN
	if event.is_action_pressed("left"):
		direction = Vector2.LEFT
	if event.is_action_pressed("right"):
		direction = Vector2.RIGHT

func get_color_under() -> Color:
	var local_x = int(dot.global_position.x) % level_images[level].get_width()
	var local_y = int(dot.global_position.y) % level_images[level].get_height()
	var color = level_images[level].get_pixel(local_x, local_y)
	return color
