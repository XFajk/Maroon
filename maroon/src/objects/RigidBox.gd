extends RigidBody3D

var sound_factor: float  = 3

func _on_body_entered(body: Node) -> void:
	if linear_velocity.length() > sound_factor:
		$CrateSound.play()
		
	print(linear_velocity.length())
