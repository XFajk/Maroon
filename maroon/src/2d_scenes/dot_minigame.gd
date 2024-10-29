extends Node2D

var first_dot = null
var second_dot = null

var dotsConnected = 0
var positionsA: Array = []
var positionsB: Array = []
var colors: Array = []

var should_draw = false

func _ready():
	print("READY")

func on_dot_clicked(dot):
	if first_dot == null:
		first_dot = dot
		print("First Dot")
		# Zmeň farbu alebo stav bodky (napr. zvýrazni ju)
	elif second_dot == null and dot != first_dot:
		second_dot = dot
		print("Second Dot")
		# Zmeň farbu alebo stav druhej bodky
		check_for_connection()

func check_for_connection():
	if first_dot and second_dot:
		if first_dot.get_child(0).myColor == second_dot.get_child(0).myColor:
			connect_dots(first_dot, second_dot)
			should_draw = true
			queue_redraw()
		else:
			first_dot = null
			second_dot = null

func connect_dots(dot1, dot2):
	print("BODKY SPOJENE")
	first_dot.get_child(0).connected = true
	second_dot.get_child(0).connected = true
	positionsA.append(first_dot.position)
	positionsB.append(second_dot.position)
	colors.append(first_dot.get_child(0).myColor)
	dotsConnected += 1

func _draw():
	if should_draw:
		for x in range(dotsConnected):
			print("DRAW")
			draw_line(positionsA[x], positionsB[x], colors[x], 2)
		should_draw = false
		first_dot = null
		second_dot = null
