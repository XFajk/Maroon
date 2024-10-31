extends Area2D

# Referencia na hlavný skript
var main_script

var myColor

var canClick = false
var connected = false
var changedColor = false

var timer = 5

func _ready():
	main_script = get_parent().get_parent()  # Získa hlavný skript (Node2D)
	myColor = get_parent().modulate

func _process(delta):
	if timer > 0:
		timer -= delta
		canClick = false
	else:
		if changedColor == false:
			var _rand = randi() % 100
				
			if _rand < 50 and changedColor == false:
				get_parent().modulate = Color(0.5, 0.5, 0.5)
			
		canClick = true
		changedColor = true


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and connected == false and canClick == true:
		main_script.on_dot_clicked(get_parent())  # Zavolaj funkciu v hlavnom skripte
