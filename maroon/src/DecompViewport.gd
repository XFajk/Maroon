extends SubViewport

@onready var text_label = $ColorRect/Label
var text: String = "ready"
var color: Color = Color(222, 137, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text_label.label_settings.font_color = color
	text_label.text = text
