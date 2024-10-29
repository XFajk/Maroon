extends Area2D

# Referencia na hlavný skript
var main_script

var myColor

var connected = false

func _ready():
	main_script = get_parent().get_parent()  # Získa hlavný skript (Node2D)
	myColor = get_parent().modulate


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and connected == false:
		print("Bodka bola kliknuta!")
		main_script.on_dot_clicked(get_parent())  # Zavolaj funkciu v hlavnom skripte
