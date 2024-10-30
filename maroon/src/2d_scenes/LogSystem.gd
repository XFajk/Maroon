extends Control

@export var logs: Array[Log] = []

@onready var ButtonsVerticalContainer: VBoxContainer = $Buttons/ButtonsVerticalContainer

@onready var Name: Label = $Text/Title/Name
@onready var Date: Label = $Text/Title/Date
@onready var LogContent: RichTextLabel = $Text/LogContent

@onready var TemplateButton: Button = $TemplateButton

func _ready() -> void:
	for log in logs:
		var btn: Button = TemplateButton.duplicate()
		btn.text = log.date
		btn.show()
		btn.Name = Name
		btn.Date = Date
		btn.LogContent = LogContent
		btn.log = log
		ButtonsVerticalContainer.add_child(btn)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		self.queue_free()
	
func show_log_content() -> void:
	print(get_name())
