extends Node3D

@export var base: int = 0 # 0 -> alpha, 1 -> beta

@onready var DecompWent = $DecompWent
@onready var DecompSmoke = $DecompWent/DecompresionSmoke

@onready var inside_door = $Doors
@onready var outside_doors = [$MainDoor, $MainDoor2]
var outside_door: StaticBody3D

@onready var decomp_panel = $DecompPanel
@export var decomp_text_color: Color
@export var ready_text_color: Color
@export var done_text_color: Color
@export var text_flicker_time = 0.7
@onready var text_update = $TextUpdate
var flicker_count = 0

@onready var decomp_timer = $DecompTimer
@onready var unlocked_timer = $UnlockedTimer

var is_decompressing: bool = false
var is_unlocked: bool = false
@export var decompressing_time: float = 5 #seconds
@export var unlocked_time: float = 7 #seconds

var entering: bool #used to determine which door to open after decompressing

signal decompresing(entering: bool)

func _ready() -> void:
	DecompSmoke.get_node("Smoke").emitting = false
	$DecompWent/AirSound.stop()
	outside_door = outside_doors[base]
	var inverted_base
	if base == 1:
		inverted_base = 0
	else:
		inverted_base = 1
	var false_doors: StaticBody3D = outside_doors[inverted_base]
	false_doors.queue_free()
	outside_door.is_locked = true
	inside_door.is_locked = true

func _process(delta: float) -> void:
	if is_decompressing:
		var dots_string = ""
		for i in range(flicker_count % 3 + 1):
			dots_string += "."
		decomp_panel.text = "decomp" + dots_string
		decomp_panel.color = decomp_text_color
	elif is_unlocked:
		if flicker_count % 2 == 0:
			decomp_panel.text = "DONE"
			decomp_panel.color = done_text_color
		else:
			decomp_panel.text = ""
		
		if flicker_count >= 4:
			text_update.stop()
	else:
		decomp_panel.text = "ready"
		decomp_panel.color = ready_text_color


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
			
			DecompSmoke.get_node("Smoke").emitting = true
			$DecompWent/AirSound.play()
			$DecompWent/AirSound.max_db = 20
			$DecompWent/AirSound.volume_db = 20
	
			decompresing.emit(entering)
			
			inside_door.is_locked = true
			outside_door.is_locked = true
			is_decompressing = true
			decomp_timer.start(decompressing_time)
			text_update.start(text_flicker_time)


func _on_decomp_timer_timeout() -> void:
	DecompSmoke.get_node("Smoke").emitting = false
	$DecompWent/AirSound.stop()
	is_decompressing = false
	is_unlocked = true
	if entering:
		inside_door.is_locked = false
	else:
		outside_door.is_locked = false
	unlocked_timer.start(unlocked_time)
	entering = not entering
	
	text_update.start(text_flicker_time)
	flicker_count = 0


func _on_unlocked_timer_timeout() -> void:
	outside_door.is_locked = true
	inside_door.is_locked = true
	is_unlocked = false


func _on_text_update_timeout() -> void:
	flicker_count += 1
