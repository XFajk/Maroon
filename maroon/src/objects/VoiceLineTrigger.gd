extends Area3D

@export var voice_line: AudioStreamPlayer = null
@export_multiline var voice_line_line: String = "no subtitles where assigned"

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return	
		
	body.voice_line = voice_line
	body.voice_line_line = voice_line_line
	body.say_voice_line()
	
	
