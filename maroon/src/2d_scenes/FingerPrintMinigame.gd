extends Node2D

# loading assets
var main_figers: Array[CompressedTexture2D] = [
	preload("res://assets/minigame/finger_print_minigame/first_finger_print_0001.png"),
	preload("res://assets/minigame/finger_print_minigame/second_finger_print_0001.png"),
	preload("res://assets/minigame/finger_print_minigame/third_finger_print_0001.png"),
	preload("res://assets/minigame/finger_print_minigame/fourth_finger_print_0001.png")
]

var first_figers_sections: Array[CompressedTexture2D] = [
	preload("res://assets/minigame/finger_print_minigame/first_finger_print_0002.png"),
	preload("res://assets/minigame/finger_print_minigame/first_finger_print_0003.png"),
	preload("res://assets/minigame/finger_print_minigame/first_finger_print_0004.png")
]

var second_figers_sections: Array[CompressedTexture2D] = [
	preload("res://assets/minigame/finger_print_minigame/second_finger_print_0002.png"),
	preload("res://assets/minigame/finger_print_minigame/second_finger_print_0003.png"),
	preload("res://assets/minigame/finger_print_minigame/second_finger_print_0004.png")
]

var third_figers_sections: Array[CompressedTexture2D] = [
	preload("res://assets/minigame/finger_print_minigame/third_finger_print_0002.png"),
	preload("res://assets/minigame/finger_print_minigame/third_finger_print_0003.png"),
	preload("res://assets/minigame/finger_print_minigame/third_finger_print_0004.png")
]

var fourth_figers_sections: Array[CompressedTexture2D] = [
	preload("res://assets/minigame/finger_print_minigame/fourth_finger_print_0002.png"),
	preload("res://assets/minigame/finger_print_minigame/fourth_finger_print_0003.png"),
	preload("res://assets/minigame/finger_print_minigame/fourth_finger_print_0004.png")
]

# finger prints
@onready var FigerPrintSectionSelections: Array[Area2D] = [
	$FigerPrintSectionSelection,
	$FigerPrintSectionSelection2,
	$FigerPrintSectionSelection3,
	$FigerPrintSectionSelection4,
	$FigerPrintSectionSelection5,
	$FigerPrintSectionSelection6
]

@onready var MainFingerPrint: Sprite2D = $MainFigerPrint

var mandatory_images: Array = []
var number_of_games = 0

var player: CharacterBody3D = null
var door_to_open: Node3D = null

func _ready() -> void:
	reroll()
	
func _process(delta: float) -> void:
	var correctly_picked: int = 0
	var picked = 0
	for i in range(6):
		if FigerPrintSectionSelections[i].selected:
			picked += 1
			if FigerPrintSectionSelections[i].get_node("Image").texture == mandatory_images[0]:
				correctly_picked += 1
			elif FigerPrintSectionSelections[i].get_node("Image").texture == mandatory_images[1]:
				correctly_picked += 1
			
	if correctly_picked == 2 and picked == 2:
		number_of_games += 1
		reroll()
	if number_of_games == 4:
		var tween = get_tree().create_tween()
		tween.set_parallel()
		player.state = player.PlayerState.STANDING
		
		tween.tween_property(player.Eyes, "position", Vector3.ZERO, 0.5)
		tween.tween_property(player.Eyes, "rotation", Vector3.ZERO, 0.5)
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		player.PlayerUI.show()
		if not player.voice_line_line.is_empty():
			player.say_voice_line()
			
		door_to_open.is_locked = false
		Saving.save()
		queue_free()
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player.state = player.PlayerState.STANDING
		queue_free()
		
	
func reroll() -> void:
	MainFingerPrint.texture = main_figers.pick_random()
	
	mandatory_images = []
	for i in range(2):
		var main_finger_0 = main_figers[0]
		var main_finger_1 = main_figers[1]
		var main_finger_2 = main_figers[2]
		var main_finger_3 = main_figers[3]
		
		match MainFingerPrint.texture:
			main_finger_0:
				mandatory_images.append(first_figers_sections.pick_random())
			main_finger_1:
				mandatory_images.append(second_figers_sections.pick_random())
			main_finger_2:
				mandatory_images.append(third_figers_sections.pick_random())
			main_finger_3:
				mandatory_images.append(fourth_figers_sections.pick_random())
	
	var all_selectable_images: Array = []
	
	var main_finger_0 = main_figers[0]
	var main_finger_1 = main_figers[1]
	var main_finger_2 = main_figers[2]
	var main_finger_3 = main_figers[3]

	match MainFingerPrint.texture:
		main_finger_0:
			all_selectable_images = mandatory_images.duplicate()
			all_selectable_images.append(second_figers_sections.pick_random())
			all_selectable_images.append(second_figers_sections.pick_random())
			all_selectable_images.append(third_figers_sections.pick_random())
			all_selectable_images.append(fourth_figers_sections.pick_random())
		main_finger_1:
			all_selectable_images = mandatory_images.duplicate()
			all_selectable_images.append(first_figers_sections.pick_random())
			all_selectable_images.append(first_figers_sections.pick_random())
			all_selectable_images.append(third_figers_sections.pick_random())
			all_selectable_images.append(fourth_figers_sections.pick_random())
		main_finger_2:
			all_selectable_images = mandatory_images.duplicate()
			all_selectable_images.append(second_figers_sections.pick_random())
			all_selectable_images.append(first_figers_sections.pick_random())
			all_selectable_images.append(first_figers_sections.pick_random())
			all_selectable_images.append(fourth_figers_sections.pick_random())
		main_finger_3:
			all_selectable_images = mandatory_images.duplicate()
			all_selectable_images.append(second_figers_sections.pick_random())
			all_selectable_images.append(first_figers_sections.pick_random())
			all_selectable_images.append(third_figers_sections.pick_random())
			all_selectable_images.append(second_figers_sections.pick_random())
	
	all_selectable_images.shuffle()
	
	for i in range(6):
		FigerPrintSectionSelections[i].selected = false
		FigerPrintSectionSelections[i].get_node("SelectedRect").hide()
		FigerPrintSectionSelections[i].get_node("Image").texture = all_selectable_images[i]			
			
		
