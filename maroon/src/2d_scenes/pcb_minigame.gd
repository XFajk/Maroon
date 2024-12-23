extends Node2D

@onready var level_sprites: Array = [$Level1, $Level2, $Level3]
@onready var level_images: Array = [
	preload("res://assets/PCBMinigame/images/level1.png"),
	preload("res://assets/PCBMinigame/images/level2.png"),
	preload("res://assets/PCBMinigame/images/level3.png")
]
var level = 0
@onready var dot = $Dot
@onready var drawn_line = $DrawnLine
@onready var label = $Label
@onready var timer = $Timer
@onready var flicker_timer = $FlickerTimer
@onready var screen = $OpeningScreen
@onready var screen_timer = $ScreenTimer
@onready var tutorial = $Tutorial

var starting_directions: Array = [Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
@onready var starting_positions: Array = [$level_1_start, $level_2_start, $level_3_start]
var direction
@export var speed: float = 50
@export var ground_color: Color = Color(0.0745, 0.1608, 0.0353, 1)

var segments: Array = []
var last_action: String
var stopped = false
var label_flickering = false
var end_animation = false

var player: CharacterBody3D = null
var panel: StaticBody3D = null

func _ready() -> void:
	screen.visible = true
	tutorial.visible = true
	screen_timer.start(3.5)
	label.visible = false
	restart()
	for sprite in level_sprites:
		sprite.visible = false
	level_sprites[level].visible = true

func _process(delta: float) -> void:
	if not stopped:
		game_going(delta)
	if label_flickering and flicker_timer.is_stopped():
		flicker_timer.wait_time = 0.7
		flicker_timer.start()
	elif not label_flickering:
		flicker_timer.stop()

func _input(event: InputEvent) -> void:
	# Skip processing if the same action was already triggered
	if last_action and event.is_action_pressed(last_action):
		return

	# Update direction based on input action
	if event.is_action_pressed("forward"):
		if last_action != "backward":
			direction = Vector2.UP
		last_action = "forward"
	elif event.is_action_pressed("backward"):
		if last_action != "forward":
			direction = Vector2.DOWN
		last_action = "backward"
	elif event.is_action_pressed("left"):
		if last_action != "right":
			direction = Vector2.LEFT
		last_action = "left"
	elif event.is_action_pressed("right"):
		if last_action != "left":
			direction = Vector2.RIGHT
		last_action = "right"

func get_color_under() -> Color:
	var color = level_images[level].get_pixelv(dot.global_position)
	return color

func check_collision_with_trail(start: Vector2, end: Vector2) -> bool:
	# Loop through each segment and check for intersection, ignoring the last added segment
	for i in range(segments.size() - 1):  # Exclude the last segment for self-collision
		var segment_start = segments[i][0]
		var segment_end = segments[i][1]

		if Geometry2D.segment_intersects_segment(start, end, segment_start, segment_end):
			return true  # Collision found

	return false  # No collision

func restart():
	drawn_line.clear_points()
	segments = []
	
	direction = starting_directions[level]
	if starting_directions[level] == Vector2.UP:
		last_action = "forward"
	elif starting_directions[level] == Vector2.DOWN:
		last_action = "backward"
	elif starting_directions[level] == Vector2.RIGHT:
		last_action = "right"
	elif starting_directions[level] == Vector2.LEFT:
		last_action = "left"
	
	dot.global_position = starting_positions[level].global_position
	drawn_line.add_point(dot.global_position)


func _on_end_1_body_entered(body: Node2D) -> void:
	if level == 0:
		level_complete()
		level = 1

func _on_end_2_body_entered(body: Node2D) -> void:
	if level == 1:
		level = 2
		level_complete()

func _on_end_3_body_entered(body: Node2D) -> void:
	if level == 2:
		level_complete()
		end_animation = true

func game_going(delta):
	var previous_pos = dot.global_position
	
	# Move the dot
	dot.global_position += direction * speed * delta
	
	# Check for out-of-bounds
	if dot.global_position.x < 0 or dot.global_position.x > 480 or dot.global_position.y < 0 or dot.global_position.y > 270:
		restart()
		return  # Exit the process if out of bounds
		
	
	# Check if dot is on ground color
	if get_color_under().r < 0.0749 and get_color_under().r > 0.0742:
		if check_collision_with_trail(dot.global_position, previous_pos):
			restart()
	else:
		restart()

	# Add new point only if moved enough
	if drawn_line.points[-1].distance_to(dot.global_position) > 1:  # Reduced threshold
		drawn_line.add_point(dot.global_position)
		# Only append a new segment if there's a previous point
		if drawn_line.points.size() > 1:
			var floored_vector1 = Vector2(floor(drawn_line.points[-2].x), floor(drawn_line.points[-2].y))
			var floored_vector2 = Vector2(floor(drawn_line.points[-1].x), floor(drawn_line.points[-1].y))
			segments.append([floored_vector1, floored_vector2])

func level_complete():
	stopped = true
	timer.start(4.9)
	label_flickering = true


func _on_timer_timeout() -> void:
	level_sprites[level].visible = true
	restart()
	if not end_animation:
		stopped = false
	label_flickering = false
	label.visible = false
	if end_animation:
		screen.visible = true
		screen_timer.start(3.5)


func _on_flicker_timer_timeout() -> void:
	if label_flickering:
		label.visible = not label.visible


func _on_screen_timer_timeout() -> void:
	screen.visible = false
	tutorial.visible = false
	restart()
	if end_animation:
		var tween = get_tree().create_tween()
		tween.set_parallel()
		player.state = player.PlayerState.STANDING
		
		tween.tween_property(player.Eyes, "position", Vector3.ZERO, 0.5)
		tween.tween_property(player.Eyes, "rotation", Vector3.ZERO, 0.5)
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		player.PlayerUI.show()
		player.say_voice_line()
		panel.done = true
			
		Saving.save()
		queue_free()
