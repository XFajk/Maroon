extends Button

@export var log: Log = null

@export var Name: Label = null
@export var Date: Label = null
@export var LogContent: RichTextLabel = null

@onready var SelectSound: AudioStreamPlayer = $SelectSound

func _pressed() -> void:
	SelectSound.volume_db = linear_to_db(Global.sound_volume*db_to_linear(SelectSound.volume_db)) 
	SelectSound
	SelectSound.play()
	Name.text = log.title
	Date.text = log.date
	LogContent.text = log.content_of_log
	
	
