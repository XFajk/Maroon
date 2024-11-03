extends Button

@export var log: Log = null

@export var Name: Label = null
@export var Date: Label = null
@export var LogContent: RichTextLabel = null

@onready var SelectSound: AudioStreamPlayer = $SelectSound

func _pressed() -> void:
	SelectSound.play()
	Name.text = log.title
	Date.text = log.date
	LogContent.text = log.content_of_log
	
	
