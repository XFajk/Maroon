extends Node2D

var positions = [Vector2(250,200),Vector2(250,300),Vector2(250,400),Vector2(250,500)]
var positions2 = [Vector2(1030,200),Vector2(1030,300),Vector2(1030,400),Vector2(1030,500)]

var selected = null

@onready var cover: Sprite2D = $Cover
@onready var tween = get_tree().create_tween()

@onready var r1 = $Redcable
@onready var r2 = $Redcable2
@onready var b1 = $Bluecable
@onready var b2 = $Bluecable2
@onready var g1 = $Greencable
@onready var g2 = $Greencable2
@onready var y1 = $Yellowcable
@onready var y2 = $Yellowcable2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tween.tween_property(cover,"global_position",Vector2(640,0),0.5)
	tween.tween_property(cover,"global_position",Vector2(640,3000),1).set_trans(Tween.TRANS_SINE)
	randomize()
	positions.shuffle()
	positions2.shuffle()
	r1.position = positions[0]
	b1.position = positions[1]
	g1.position = positions[2]
	y1.position = positions[3]
	r2.position = positions2[0]
	b2.position = positions2[1]
	g2.position = positions2[2]
	y2.position = positions2[3]
	
	
func cable(start,end):
	print(start)
	print(end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_red_mouse_entered() -> void:
	selected = "r"
	print("r")


func _on_red_2_mouse_entered() -> void:
	if selected == "r":
		selected = null
		cable(r1.global_position,r2.global_position)


func _on_blue_mouse_entered() -> void:
	selected = "b"


func _on_blue_2_mouse_entered() -> void:
	if selected == "b":
		selected = null
		cable(b1.global_position,b2.global_position)


func _on_green_mouse_entered() -> void:
	selected = "g"


func _on_green_2_mouse_entered() -> void:
	if selected == "g":
		selected = null
		cable(g1.global_position,g2.global_position)


func _on_yellow_mouse_entered() -> void:
	selected = "y"


func _on_yellow_2_mouse_entered() -> void:
	if selected == "y":
		selected = null
		cable(y1.global_position,y2.global_position)
