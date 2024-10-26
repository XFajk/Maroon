extends Node3D

@export_range(0, 100) var chance_of_flickering: float
@export var off_value: float = 0.2
@export var off_bar_value: float = 0.0
var on_value: float
var on_bar_value: float = 16

@export_range(0, 100) var chance_of_sparks: float

@onready var LightBar = $Plane
var LightBarShader: StandardMaterial3D
@onready var Light = $Light

var Sparks = preload("res://vfx/Sparks.tscn")

func _ready() -> void:
	visible = true
	on_value = Light.light_energy
	LightBarShader = LightBar.get_surface_override_material(1)

func _physics_process(delta: float) -> void:
	if chance_of_flickering > randi_range(0, 100):
		Light.light_energy = off_value
		LightBarShader.emission_energy_multiplier = off_bar_value
		if chance_of_sparks > randi_range(0, 100):
			add_child(Sparks.instantiate())
	else:
		Light.light_energy = on_value
		LightBarShader.emission_energy_multiplier = on_bar_value


func _on_decompression_decompresing(entering: bool) -> void:
	if entering:
		visible = true
	else:
		visible = false
