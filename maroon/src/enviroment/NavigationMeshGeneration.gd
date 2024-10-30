extends NavigationRegion3D

@onready var TreesPermanent: Node3D = $TreesPermanent
@onready var Ground: StaticBody3D = $Ground

		
func create_navigation_mesh() -> void:
	if TreesPermanent.all_collisions: 
		bake_navigation_mesh(true)
	timer.queue_free()
