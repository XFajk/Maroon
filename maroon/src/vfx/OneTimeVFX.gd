extends Node3D

var free_timer: Timer = Timer.new()

@export var free_after: float
@export var free: bool = true

func _ready() -> void:
	add_child(free_timer)
	free_timer.wait_time = free_after
	free_timer.one_shot = true
	free_timer.timeout.connect(_on_free_timer_timeout)
	free_timer.start()

func _on_free_timer_timeout() -> void:
	if free:
		queue_free()
	
	
	
