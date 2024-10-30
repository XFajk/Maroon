extends Button

@export var log: Log = null

@export var Name: Label = null
@export var Date: Label = null
@export var LogContent: RichTextLabel = null

func _pressed() -> void:
	Name.text = log.title
	Date.text = log.date
	LogContent.text = log.content_of_log
	
	
