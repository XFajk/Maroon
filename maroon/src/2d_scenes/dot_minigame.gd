extends Node2D

var first_dot = null
var second_dot = null

var dotsConnected = 0
var positionsA: Array = []
var positionsB: Array = []
var colors: Array = []

var should_draw = false

var attempts = 5
var completed = 0

func _ready():
	print("READY")
	
func _process(delta):
	if attempts == 0:
		_retry()
		
	$Attempts.text = "Attempts: " + str(attempts)
	$Completed.text = "Completed: " + str(completed) + "/" + str(3)
	
	if get_child(0).get_child(0).canClick ==  true:
		$GetReady.text = ""
	else:
		$GetReady.text = "GET READY"
		
	if dotsConnected == 5:
		if completed < 2:
			$GetReady.text = "NEXT"
			_next()
		else:
			$GetReady.text = "COMPLETED"
			completed = 3


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
			attempts -= 1

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
			draw_line(positionsA[x], positionsB[x], colors[x], 2)
		should_draw = false
		first_dot = null
		second_dot = null

func _retry():
	print("Retry")
	attempts = 5
	dotsConnected = 0
	var _children = get_children()
	var children = _children.slice(0, _children.size() - 3)
	
	positionsA = []
	positionsB = []
	colors = []
	
	for child in children:
		child.get_child(0).connected = false
		child.get_child(0).timer = 0.5
	
	should_draw = true
	queue_redraw()

func _next():
	completed += 1
	print("Next")
	attempts = 5
	dotsConnected = 0
	var _children = get_children()
	var children = _children.slice(0, _children.size() - 3)
	
	positionsA = []
	positionsB = []
	colors = []
	
	for child in children:
		child.get_child(0).connected = false
		child.modulate = child.get_child(0).myColor
		child.get_child(0).changedColor = false
		child.get_child(0).timer = 5
	
	should_draw = true
	queue_redraw()
