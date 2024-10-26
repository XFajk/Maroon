extends Panel
@export var items = []
@export var icons = []
@onready var list = $ItemList
@onready var logs = [$Log1,$Log2,$Log3,$Log4,$Log5,$Log6]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var x = 0
	for i in items:
		list.add_item(items[x].substr(0,30),icons[x],true)
		logs[x].get_node("Label").text = items[x]
		x += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_list_item_selected(index: int) -> void:
	for i in logs:
		i.visible = false
	logs[index].visible = true
