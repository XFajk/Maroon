extends Node3D

@export_range(0, 100) var flickering_frequency: float
@export var off_value: float = 0.2
var on_value: float

@onready var LightBar = $Cylinder
@onready var Light = $Light

func _ready() -> void:
	on_value = Light.light_energy

func _physics_process(delta: float) -> void:
	if flickering_frequency > randi_range(0, 100):
		Light.light_energy = off_value
	else:
		Light.light_energy = on_value
