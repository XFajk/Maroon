#@tool
extends  Node3D

@export var ground: StaticBody3D
@export var player: CharacterBody3D
@export var objects: Array[Node3D] ## Add multiple Node3Ds each with 3 MultiMesh nodes
@export var coll_script: Script = preload("res://src/enviroment/RangedCollisions.gd")
@onready var coll_update_timer = $CollUpdate

@export var obj_ammount: int = 1000

@export var max_rotation: Vector3 = Vector3(5, 5, 5)
@export var scale_min: float = 0.8
@export var scale_max: float = 1.3
@export var random_offset_max: float = 6
@export var z_offset: float = -0.15
@export var close_correction_range: float = 1.5

@export var lod_0_end: int = 50
@export var lod_1_end: int = 180
@export var lod_2_end: int = 500
@export var collision_generation_range = 15
#@export var collision_update_interval # currently unused

@export var ray_height: float = 150.0
@export var ray_length: float = 200
@onready var ray_cast: RayCast3D

# Preload your black and white texture
@export var placement_map: Image
@export var image_size = 128
@export var scaling: float = 4.57 # 4.57 works best for this project

var white_pixel_positions: Array
var unpacked_groups: Array # SAVED
var used_positions: Array # contains every used pos as a list [group_name, index, Transform3D]
var grouped_data: Dictionary # SAVED
var group_names: Array
var collision_shapes: Dictionary

var generated = false
var data_loaded = false

var all_collisions = true
var failed_objects = 0
signal all_loaded

func _ready() -> void:
	print(self)
	# Squaring all directional ranges because later distance_squared_to() is used for performance
	close_correction_range = close_correction_range * close_correction_range
	lod_0_end = lod_0_end * lod_0_end
	lod_1_end = lod_1_end * lod_1_end
	lod_2_end = lod_2_end * lod_2_end
	collision_generation_range = collision_generation_range * collision_generation_range
	
	unpacked_groups = unpack_groups(objects)
	
	if not generated:
		load_placement_map() # only once
		
		ray_cast = RayCast3D.new() # only once
		add_child(ray_cast) # only once
		
		for group in objects:
			group_names.append(group.get_name())
		
		unpacked_groups = unpack_groups(objects)
		
		for group in unpacked_groups: # only once
			spawn_objects(group)
		
		grouped_data = group_data(used_positions) # only once
		Saving.save()
		
		obj_ammount = obj_ammount / objects.size()
	
	for key in group_names: # set all the orginal collider StaticBodies out of range
		collision_shapes[key].global_position = Vector3(0, -10000, 0)


func _process(delta: float) -> void:
	for group in unpacked_groups:
		calculate_lods(group, grouped_data[group[1]])
	if all_collisions:
		all_loaded.emit()

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
			var has_staticbody = false
			if node is MultiMeshInstance3D:
				mesh_group.append(node)
			elif node is StaticBody3D:
				collision_shapes[group.get_name()] = node
				has_staticbody = true
			else:
				print("ERROR: loading group " + group.get_name)
		unpacked_groups.append([mesh_group, group.get_name()])
	return unpacked_groups


func group_data(used_positions: Array):
	var grouped_data: Dictionary
	for group_name in group_names:
		grouped_data[group_name] = []
	
	for used_position in used_positions: #[group_name, index, Transform3D]
		var pos_group_name: String = used_position[0]
		var index = used_position[1]
		var instance_transform = used_position[2]
		var position_data: Array = [index, instance_transform]
		grouped_data[pos_group_name].append(position_data)
	
	return grouped_data


func spawn_objects(group: Array):
	var mesh_group = group[0]
	var group_name = group[1]
	for multi_mesh_instance in mesh_group:
		multi_mesh_instance.multimesh.set_transform_format(MultiMesh.TRANSFORM_3D)
		multi_mesh_instance.multimesh.set_instance_count(obj_ammount)
	
	for i in range(obj_ammount):
		randomize()
		var position_horisontal = get_random_point() # random horisontal pos from the map
		position_horisontal = Vector2(position_horisontal.x-image_size/2, position_horisontal.y-image_size/2)
		position_horisontal = Vector2(position_horisontal.x * scaling, position_horisontal.y * scaling)
		position_horisontal += Vector2(randf_range(-random_offset_max, random_offset_max), randf_range(-random_offset_max, random_offset_max))
		
		var checked = false
		var placing_position = get_placement_point(position_horisontal)
		placing_position += Vector3(0, z_offset, 0)
		
		for attempt in range(10):
			checked = true  # Assume the position is valid until proven otherwise
			
			for used_position in used_positions:
				if placing_position.distance_squared_to(used_position[2].origin) < close_correction_range:
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
			
			instance_transform = Transform3D(placing_basis, placing_position)
			
			used_positions.append([group_name, i, instance_transform])
	
	if failed_objects > 0:
		print("\nFailed to place " + str(failed_objects) + " instances; no avaliable space
decrease ammount or correction range")

func calculate_lods(group: Array, grouped_data: Array): # grouped data -> [[index, [transform]], ...]
	var mesh_group = group[0]
	
	var mmi_lod_0: MultiMeshInstance3D = mesh_group[0]
	var mmi_lod_1: MultiMeshInstance3D = mesh_group[1]
	var mmi_lod_2: MultiMeshInstance3D = mesh_group[2]
	
	if not mmi_lod_0.multimesh.mesh:
		print("Warning: LOD1 is missing a mesh")
	if not mmi_lod_1.multimesh.mesh:
		print("Warning: LOD2 is missing a mesh")
	if not mmi_lod_2.multimesh.mesh:
		print("Warning: LOD3 is missing a mesh")
	
	for mmi: MultiMeshInstance3D in mesh_group:
		if mmi.multimesh.TRANSFORM_3D != MultiMesh.TRANSFORM_3D:
			print("WARNING: " + str(mmi.multimesh) + "has transform format set not to 3D")
			mmi.multimesh.set_transform_format(MultiMesh.TRANSFORM_3D) # tries to correct it but Godot is buggy
	
	for multi_mesh_instance in mesh_group:
		multi_mesh_instance.multimesh.set_transform_format(MultiMesh.TRANSFORM_3D)
		multi_mesh_instance.multimesh.set_instance_count(obj_ammount)
	
	for i in range(mmi_lod_0.multimesh.get_instance_count()):
		var saved_transform: Transform3D = grouped_data[i][1]
		var unload_pos: Vector3 = Vector3(0, -10000, 0) # Simple and effective way to make individual meshinstance not render
		var unload_transform: Transform3D = Transform3D(saved_transform.basis, unload_pos)
		var saved_position: Vector3 = grouped_data[i][1].origin
		
		var obj_distance_sqrd = player.global_position.distance_squared_to(saved_position)
		
		if obj_distance_sqrd < lod_0_end:
			mmi_lod_0.multimesh.set_instance_transform(i, saved_transform)
			mmi_lod_1.multimesh.set_instance_transform(i, unload_transform)
			mmi_lod_2.multimesh.set_instance_transform(i, unload_transform)
		elif obj_distance_sqrd >= lod_0_end and obj_distance_sqrd < lod_1_end:
			mmi_lod_0.multimesh.set_instance_transform(i, unload_transform)
			mmi_lod_1.multimesh.set_instance_transform(i, saved_transform)
			mmi_lod_2.multimesh.set_instance_transform(i, unload_transform)
		elif obj_distance_sqrd >= lod_1_end and obj_distance_sqrd < lod_2_end:
			mmi_lod_0.multimesh.set_instance_transform(i, unload_transform)
			mmi_lod_1.multimesh.set_instance_transform(i, unload_transform)
			mmi_lod_2.multimesh.set_instance_transform(i, saved_transform)
		else:
			mmi_lod_0.multimesh.set_instance_transform(i, unload_transform)
			mmi_lod_1.multimesh.set_instance_transform(i, unload_transform)
			mmi_lod_2.multimesh.set_instance_transform(i, unload_transform)
		
		if obj_distance_sqrd < collision_generation_range and not all_collisions:
			var collision_body: StaticBody3D = collision_shapes[group[1]].duplicate()
			collision_body.transform = saved_transform
			collision_body.set_script(coll_script)
			collision_body.player = player
			collision_body.range_squared = collision_generation_range
			add_child(collision_body)
		elif all_collisions:
			var collision_body: StaticBody3D = collision_shapes[group[1]].duplicate()
			collision_body.transform = saved_transform
			collision_body.set_script(coll_script)
			collision_body.player = player
			collision_body.range_squared = collision_generation_range
			add_child(collision_body)

func saveout() -> Dictionary:
	return {
		"grouped_data" : grouped_data
	}
	
	
func loadin(save_data: Dictionary) -> void:
	generated = true
	grouped_data = save_data.get("grouped_data")
	
	group_names = []
	for group in objects:
		group_names.append(group.get_name())
	
	var new_grouped_data: Dictionary
	
	obj_ammount = obj_ammount / objects.size()
	
	for key in group_names:
		var group_transforms = []
		for i in range(obj_ammount):
			var transform_string = grouped_data[key][i][1]
			var new_transform = string_to_transform3d(transform_string)
			group_transforms.append([i, new_transform])
		new_grouped_data[key] = group_transforms
	
	grouped_data = new_grouped_data
	data_loaded = true

func string_to_transform3d(input_string: String) -> Transform3D:
	# Use a regex pattern to match the vectors in the format: (x, y, z)
	var regex = RegEx.new()
	regex.compile(r"\(([^)]+)\)")
	
	# Find all matches in the input string
	var matches = regex.search_all(input_string)
	if matches.size() != 4:
		print("Error: Expected exactly 4 vectors in the string.")
		return Transform3D() # Return identity transform if parsing fails
	
	# Parse the vectors into Vector3
	var vectors = []
	for match in matches:
		# Extract the matched string inside the parentheses
		var vector_string = match.get_string(0).strip_edges()  # Strip whitespace
		vector_string = vector_string.substr(1, vector_string.length() - 2) # Remove parentheses manually
		
		# Split by commas and convert to float
		var vector_values = vector_string.split(",")
		vectors.append(Vector3(
			float(vector_values[0]),
			float(vector_values[1]),
			float(vector_values[2])
		))
	
	# Create and return the Transform3D object
	return Transform3D(vectors[0], vectors[1], vectors[2], vectors[3])
