extends NavigationRegion3D

@onready var TreesPermanent: Node3D = $TreesPermanent

func _ready() -> void:
	TreesPermanent.all_collisions = true

func _on_trees_permanent_all_loaded() -> void:
	bake_navigation_mesh(true)
	TreesPermanent.all_collisions = false
