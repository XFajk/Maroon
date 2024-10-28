extends Node

func load() -> void:
	var savables: Array[Node] = get_tree().get_nodes_in_group("Savable")
	
	var data_file: FileAccess = FileAccess.open("user://gamedata.save", FileAccess.READ)
	var save_data: Dictionary = JSON.parse_string(data_file.get_as_text())
	
	for savable in savables:
		if not savable.has_method("loadin"):
			print(savable, "this savable object does not have a loadin function")
			continue
			
		var saved_object_data = save_data.get(str(savable.get_path()))
		
		if  saved_object_data == null:
			print(str(savable.get_path()) + " missing an etry for this object")
			continue;
			
		savable.loadin(saved_object_data)
	
func save() -> void:
	var savables: Array[Node] = get_tree().get_nodes_in_group("Savable")
	
	# get previouse savedata
	var data_file: FileAccess = FileAccess.open("user://gamedata.save", FileAccess.READ)
	var save_data: Dictionary = JSON.parse_string(data_file.get_as_text())
	data_file.close()
	
	var save_file: FileAccess = FileAccess.open("user://gamedata.save", FileAccess.WRITE)
	
	for savable in savables:
		if not savable.has_method("saveout"):
			print(savable, "this savable object does not have a saveout() function")
			continue
		
		var object_save_data: Dictionary = savable.saveout()
		
		save_data[str(savable.get_path())]  = object_save_data
		
	
	var json_string: String = JSON.stringify(save_data)
	print(json_string)
	save_file.store_string(json_string)
