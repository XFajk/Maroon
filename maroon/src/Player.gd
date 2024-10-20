extends CharacterBody3D

enum PlayerState {
	STANDING,
	MOVING,
	JUMPING,
}

var state: PlayerState = PlayerState.STANDING

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass
