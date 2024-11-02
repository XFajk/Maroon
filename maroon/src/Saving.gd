extends Node

var default_file = "user://gamedata.save"

var disable_saving: bool = false

func load(save_file_name: String = "user://gamedata.save") -> void:
	print("loading")
	if not FileAccess.file_exists(save_file_name):
		print("Error save file dosent exist")
		return # Error! We don't have a save to load.

	var data_file: FileAccess = FileAccess.open(save_file_name, FileAccess.READ)
	var saved_data: Dictionary = parse_file(data_file)
	
	#print(saved_data)
	
	for saved_node_path in saved_data.keys():
		var saved_node = get_node(saved_node_path)
		if saved_node == null:
			print(saved_node_path + " is not in scene")
			continue;
		if not saved_node.has_method("loadin"):
			print(saved_node_path, "this savable object does not have a loadin function")
			continue
			
		var saved_object_data = saved_data.get(saved_node_path)
		
		if  saved_object_data == null:
			print(saved_node_path + " missing an etry for this object")
			continue
			
		saved_node.loadin(saved_object_data)
		
		# Special load code for OnRadar Nodes
		var on_radar = saved_object_data.get("on_radar")
		
		if on_radar == null:
			continue
		
		if bool(on_radar):
			saved_node.add_to_group("OnRadar")
			
	
func save(save_file_name: String = "user://gamedata.save") -> void:
	if disable_saving:
		print("SAVING IS DISABLED")
		return
	print("saving")
	var savables: Array[Node] = get_tree().get_nodes_in_group("Savable")
	
	# get previouse savedata
	var data_file: FileAccess = FileAccess.open(save_file_name, FileAccess.READ)
	var save_data: Dictionary = parse_file(data_file)
	
	var save_file: FileAccess = FileAccess.open(save_file_name, FileAccess.WRITE)
	
	for savable in savables:
		if not savable.has_method("saveout"):
			print(savable, "this savable object does not have a saveout() function")
			continue
		
		var object_save_data: Dictionary = savable.saveout()
		
		save_data[str(savable.get_path())]  = object_save_data
		
	# special code for OnRadar Nodes
	var on_radar_nodes = get_tree().get_nodes_in_group("OnRadar")
	
	for node in on_radar_nodes:
		# if this object is already savable give it a one more feild to its save data 
		# that we know it was on radar
		if str(node.get_path()) in save_data:
			print(str(node.get_path()) + " was Savable")
			save_data[str(node.get_path())]["on_radar"] = true
		else:
			save_data[str(node.get_path())] = {"on_radar": true}
	
	var json_string: String = JSON.stringify(save_data)
	save_file.store_string(json_string)
	
func delete(save_file_name: String = "user://gamedata.save") -> void:
	FileAccess.open(save_file_name, FileAccess.WRITE).close()
	
	
func parse_file(file: FileAccess) -> Dictionary:
	if file == null:
		return {}
	
	var json = JSON.new()
	var parse_result: Error = json.parse(file.get_as_text())
	
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", file.get_as_text(), " at line ", json.get_error_line())
		return {}
	else:
		return json.data
