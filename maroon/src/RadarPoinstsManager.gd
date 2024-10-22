extends Node2D

var points: Array[Vector2]

var topdown_player_position: Vector2
var topdown_player_angle: float 

@export var zoom: float = 1.0
@export var radar_radius: float = 236

func _draw() -> void:
	
	rotation = topdown_player_angle-deg_to_rad(180)
	for point in points:
		draw_point_on_radar(point)
	points.clear()

func draw_point_on_radar(point: Vector2) -> void:
		var on_radar_position: Vector2 = ((topdown_player_position-point)*zoom)
		if on_radar_position.length() > radar_radius/2:
			on_radar_position = on_radar_position.normalized()*radar_radius/2.0
		draw_circle(on_radar_position, 1.0*zoom, Color(1.0, 1.0, 1.0))
