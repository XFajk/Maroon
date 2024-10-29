extends StaticBody3D

var player: CharacterBody3D
var range_squared
var timer: Timer
var interval

func _ready() -> void:
	interval = 0.1
	timer = Timer.new()
	timer.wait_time = interval
	timer.connect("timeout", _on_Timer_timeout)
	add_child(timer)
	timer.start()

func _on_Timer_timeout():
	queue_free()
