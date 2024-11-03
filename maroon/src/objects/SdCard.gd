extends StaticBody3D

@export var downloadeble_positions: Array[Node3D]
@export var object_to_delete: Array[Node]
var paths_to_deleted_objects: Array[String]

@export var outlines: Array[MeshInstance3D]

@export var voice_line: AudioStream = null
@export_multiline var voice_line_line: String = ""

var deleted = false

func _ready() -> void:
	stop_showing_interaction()

func interact(player: CharacterBody3D) -> void:
	player.voice_line = voice_line
	player.voice_line_line = voice_line_line
	player.say_voice_line()
	 
	$PickUpSound.play()
	
	for pos in downloadeble_positions:
		if pos == null:
			continue
			
		pos.add_to_group("OnRadar")
	
	for obj in object_to_delete:
		paths_to_deleted_objects.append(str(obj.get_path()))
		obj.queue_free()
		
	deleted = true
	Saving.save()
	hide()
	

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
		
func saveout() -> Dictionary:
	return {
		"deleted": deleted,
		"paths_to_deleted_objects": paths_to_deleted_objects
	}
	
func loadin(save_data: Dictionary) -> void:
	stop_showing_interaction()
	if bool(save_data.get('deleted')):
		queue_free()
		for node_path in save_data.get("paths_to_deleted_objects"):
			get_tree().root.get_node(node_path).queue_free()


func _on_pick_up_sound_finished() -> void:
	queue_free()
