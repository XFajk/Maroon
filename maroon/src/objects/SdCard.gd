extends StaticBody3D

@export var downloadeble_positions: Array[Node3D]

@export var outlines: Array[MeshInstance3D]


@export var voice_line: AudioStreamPlayer = null
@export_multiline var voice_line_line: String = ""

var deleted = false

func _ready() -> void:
	stop_showing_interaction()

func interact(player: CharacterBody3D) -> void:
	player.voice_line = voice_line
	player.voice_line_line = voice_line_line
	player.say_voice_line()
	
	for pos in downloadeble_positions:
		if pos == null:
			continue
			
		pos.add_to_group("OnRadar")
		
	deleted = true
	Saving.save()
	queue_free()

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
	}
	
func loadin(save_data: Dictionary) -> void:
	stop_showing_interaction()
	if bool(save_data.get('deleted')):
		queue_free()
