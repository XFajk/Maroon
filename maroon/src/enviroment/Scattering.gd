#@tool
extends  Node3D

@export var ground: StaticBody3D
@export var player: CharacterBody3D
@export var objects: Array[Node3D] ## Add multiple Node3Ds each with 3 MultiMesh nodes


@export var obj_ammount: int = 1000

@export var max_rotation: Vector3 = Vector3(5, 5, 5)
@export var scale_min: float = 0.8
@export var scale_max: float = 1.3
@export var random_offset_max: float = 6
@export var close_correction_range: float = 1.5

@export var lod_0_end: int = 50
@export var lod_1_end: int = 180
@export var lod_2_end: int = 500

@export var ray_height: float = 150.0
@export var ray_length: float = 200
@onready var ray_cast: RayCast3D

# Preload your black and white texture
@export var placement_map: Image
@export var image_size = 128
@export var scaling: float = 4.57 # 4.57 works best for this project

var white_pixel_positions: Array
var unpacked_groups: Array
var used_positions: Array # contains every used pos as a list [group_name, index, position]

func _ready() -> void:
	# Squaring all directional ranges because later distance_squared_to() is used for performance
	close_correction_range = close_correction_range * close_correction_range
	lod_0_end = lod_0_end * lod_0_end
	lod_1_end = lod_1_end * lod_1_end
	lod_2_end = lod_2_end * lod_2_end
	
	load_placement_map()
	
	ray_cast = RayCast3D.new()
	add_child(ray_cast)
	
	unpacked_groups = unpack_groups(objects)
	
	for group in unpacked_groups:
		spawn_objects(group)

func _process(delta: float) -> void:
	for group in unpacked_groups:
		calculate_lods(group)


func load_placement_map():
	white_pixel_positions = []
	var image = placement_map

	# Loop through each pixel and record the position of white pixels
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			var color = image.get_pixel(x, y)

			# Check if the pixel is white (or close to white)
			if color.r >= 0.95 and color.g >= 0.95 and color.b >= 0.95:
				white_pixel_positions.append(Vector2(x, y))


func get_random_point() -> Vector2:
	if white_pixel_positions.size() == 0:
		return Vector2.ZERO # Return zero vector if there are no white pixels detected

	# Choose a random white pixel
	var random_index = randi() % white_pixel_positions.size()
	var random_pixel = white_pixel_positions[random_index]

	# Convert the random pixel position to a position in the world
	return random_pixel

func get_placement_point(at_position: Vector2):
	ray_cast.position = Vector3(at_position.x, ray_height, at_position.y)
	ray_cast.target_position = Vector3(0, -ray_length, 0)
	ray_cast.enabled = true
	ray_cast.force_raycast_update()
	
	var hit_position = ray_cast.get_collision_point()
	
	return hit_position

func unpack_groups(objects: Array):
	var unpacked_groups: Array = []
	for group in objects:
		var mesh_group: Array = []
		for node in group.get_children():
			if node is MultiMeshInstance3D:
				mesh_group.append(node)
			else:
				print("WARNING: not all nodes in group " + node.name + " are a Mesh")
		unpacked_groups.append([mesh_group, group.get_name()])
	return unpacked_groups


func spawn_objects(group: Array):
	var mesh_group = group[0]
	var group_name = group[1]
	print(group_name)
	for multi_mesh_instance in mesh_group:
		multi_mesh_instance.multimesh.set_transform_format(MultiMesh.TRANSFORM_3D)
		multi_mesh_instance.multimesh.set_instance_count(obj_ammount)
	
	var failed_objects = 0
	for i in range(obj_ammount):
		randomize()
		var position_horisontal = get_random_point() # random horisontal pos from the map
		position_horisontal = Vector2(position_horisontal.x-image_size/2, position_horisontal.y-image_size/2)
		position_horisontal = Vector2(position_horisontal.x * scaling, position_horisontal.y * scaling)
		
		var checked = false
		var placing_position = get_placement_point(position_horisontal) + Vector3(randf_range(-random_offset_max, random_offset_max), -0.2, randf_range(-random_offset_max, random_offset_max))
		
		for attempt in range(10):
			checked = true  # Assume the position is valid until proven otherwise
			
			for used_position in used_positions:
				if placing_position.distance_squared_to(used_position[2]) < close_correction_range:
					# Generate a new placing position
					placing_position = get_placement_point(position_horisontal) + Vector3(randf_range(-random_offset_max, random_offset_max), 0, randf_range(-random_offset_max, random_offset_max))
					checked = false  # A conflict was found, need to recheck
					break  # Exit the inner loop to check the new position
			
			# If checked is false, we will continue to the next attempt in the outer loop.

		# After the attempts, if we still have checked as false, count it as a failure.
		if not checked:
			failed_objects += 1
		else:
			var placing_rotation = Vector3(deg_to_rad(randf_range(-max_rotation.x, max_rotation.x)), deg_to_rad(randf_range(-max_rotation.y, max_rotation.y)), deg_to_rad(randf_range(-max_rotation.z, max_rotation.z)))
			var scale_multiplier = randf_range(scale_min, scale_max)
			var placing_scale = Vector3(scale_multiplier, scale_multiplier, scale_multiplier)
			
			var placing_basis = Basis()
			placing_basis = placing_basis.rotated(Vector3.UP, placing_rotation.y).rotated(Vector3.RIGHT, placing_rotation.x).rotated(Vector3.FORWARD, placing_rotation.z)

			placing_basis = placing_basis.scaled(placing_scale)
			
			var instance_transform = Transform3D(placing_basis, Vector3(0, -10000, 0)) # unloads all new objects
			
			for multi_mesh_instance in mesh_group:
				multi_mesh_instance.multimesh.set_instance_transform(i, instance_transform)
			
			used_positions.append([group_name, i, placing_position, instance_transform])
	
	if failed_objects > 0:
		print("\nFailed to place " + str(failed_objects) + " instances; no avaliable space
decrease ammount or correction range")

func calculate_lods(group: Array):
	var mesh_group = group[0]
	var group_name = group[1]
	
	var mmi_lod_0: MultiMeshInstance3D = mesh_group[0]
	var mmi_lod_1: MultiMeshInstance3D = mesh_group[1]
	var mmi_lod_2: MultiMeshInstance3D = mesh_group[2]
	
	for i in mmi_lod_0.multimesh.get_instance_count():
		var obj_distance_sqrd = player.global_position.distance_squared_to(Vector3.ZERO)
		
		if obj_distance_sqrd > lod_0_end:
			mmi_lod_0.multimesh.set_instance_transform(i, Transform3D())
