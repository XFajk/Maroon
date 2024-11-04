extends StaticBody3D

@export var outlines: Array[MeshInstance3D]

@export_subgroup("dosent have gas settings")
@export var dosent_have_gas_voice_line: AudioStreamPlayer = null
@export_multiline var dosent_have_gas_voice_line_line: String = ""

@export_subgroup("has gas settings")
@export var has_gas_voice_line: AudioStreamPlayer = null
@export_multiline var has_gas_voice_line_line: String = ""

@export var RadioTowerLight: MeshInstance3D = null
@export var EngineParticles: GPUParticles3D = null
@export var RadioPanel: StaticBody3D = null

var deleted = false

func _ready() -> void:
	stop_showing_interaction()
	RadioTowerLight.hide()
	EngineParticles.emitting = false

func interact(player: CharacterBody3D) -> void:
	if player.cansiters_picked_up < 3:
		player.voice_line = dosent_have_gas_voice_line
		player.voice_line_line = dosent_have_gas_voice_line_line
		player.say_voice_line()
	else:
		$Sound.play()
		$Sound.autoplay = true
		RadioPanel.acessible = true
		player.voice_line = has_gas_voice_line
		player.voice_line_line = has_gas_voice_line_line
		player.say_voice_line()
		RadioTowerLight.show()
		EngineParticles.emitting = true
		
	

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


func _on_sound_finished() -> void:
	$Sound.play()
