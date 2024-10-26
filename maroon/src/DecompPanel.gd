extends StaticBody3D

signal button_pressed

var button_name = "decomp"

@export var button: MeshInstance3D

@export var button_depth = 0.03
@export var button_speed = 1
@export var button_press_direction: Vector3 = Vector3(-1, 0, 0).normalized()

var button_progress = 0
var button_state = 0 # 0 -> innactive, 1 -> going down, 2 -> going back up


@onready var decomp_viewport = $DecompViewport
@onready var panel_mesh: MeshInstance3D = $Panel
var text: String = "ready"
var color: Color = Color(222, 137, 0)

@export var outlines: Array[MeshInstance3D]

func _ready() -> void:
	var screen_material: StandardMaterial3D = StandardMaterial3D.new()
	var viewport_texture: ViewportTexture = decomp_viewport.get_texture()
	screen_material.albedo_texture = viewport_texture
	panel_mesh.set_surface_override_material(1, screen_material)
	
	stop_showing_interaction()


func _process(delta: float) -> void:
	if button_state == 1 and button_progress >= 1:
		button_state = 2
		button_progress = 1
	if button_state == 2 and button_progress <= 0:
		button_state = 0
		button_progress = 0
	
	if button_state == 1:
		button_progress += button_speed * delta * 5
	elif button_state == 2:
		button_progress -= button_speed * delta * 5
	
	button.position = button_press_direction * button_progress * button_depth
	
	
	decomp_viewport.color = color
	decomp_viewport.text = text

func interact(player: CharacterBody3D) -> void:
	button_pressed.emit(button_name)
	button_state = 1
	
func stop_showing_interaction() -> void:
	
	if outlines.size() < 1:
		return
		
	for outline in outlines:
		outline.visible = false
	
func show_interaction() -> void:
	
	if outlines.size() < 1:
		return
		
	for outline in outlines:
		outline.visible = true
		
