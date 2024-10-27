extends CharacterBody3D

@onready var animation_player = $AnimationPlayer


func _ready() -> void:
	animation_player.play("Idle")
