extends Node

@onready var camera: Camera2D = $"Camera2D"
@onready var tree_nodes: Node = $TreeNodes
@onready var lines: Node = $Lines
@onready var label: Label = $Control/Label


var TREE_NODE = preload("res://scenes/tree_node.tscn")

enum {ZOOM_MODE ,DELETE_MODE , MOVE_CAMERA_MODE}
var current_mode := MOVE_CAMERA_MODE
var mousepos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	mousepos = get_viewport().get_mouse_position() - Vector2(get_viewport().size.x/2, get_viewport().size.y/2) + camera.get_screen_center_position()

	label.text = "MOVE CAMERA" if (current_mode == MOVE_CAMERA_MODE) else "ZOOM_MODE" if (current_mode == ZOOM_MODE) else "DELETE NODE"

	# toggle between placing mode, and not placing 
	if Input.is_action_just_pressed("rightMB"):
		current_mode = ZOOM_MODE if (current_mode == DELETE_MODE) else DELETE_MODE if (current_mode == MOVE_CAMERA_MODE) else MOVE_CAMERA_MODE
	
	match current_mode:
		ZOOM_MODE: 
			zoom()
		DELETE_MODE:
			delete_tree_node()
		MOVE_CAMERA_MODE:
			move_camera()

# Diese Variablen sind nur für die Folgende Funktion wichtig:
var moving_camera
var current_mouse_pos

func zoom():
	if Input.is_action_just_pressed("leftMB"):
		current_mouse_pos = get_viewport().get_mouse_position()
	elif Input.is_action_pressed("leftMB"):
		var delta_move:Vector2 = (get_viewport().get_mouse_position() - current_mouse_pos) / 100
		current_mouse_pos = get_viewport().get_mouse_position()
		delta_move = Vector2(1,1) * delta_move.length() * ((delta_move.y / abs(delta_move.y)) if delta_move.y != 0 else 0)
		camera.zoom += delta_move if (camera.zoom + delta_move > Vector2(0,0)) else Vector2(0,0)
		
		print(delta_move.abs())

func move_camera():
	if Input.is_action_just_pressed("leftMB"):
		current_mouse_pos = get_viewport().get_mouse_position()
	elif Input.is_action_pressed("leftMB"):
		var delta_move = get_viewport().get_mouse_position() - current_mouse_pos
		current_mouse_pos = get_viewport().get_mouse_position()
		camera.position -= delta_move/camera.zoom



func delete_tree_node():
	if Input.is_action_just_pressed("leftMB"):
		for child in tree_nodes.get_children():
			if child.touched == true:
				child.queue_free()
			if(tree_nodes.get_children().size() >= 2):
				line_between(tree_nodes.get_child(0).position, tree_nodes.get_child(1).position)


# Creates a line between two given Vector2
func line_between(first:Vector2, second:Vector2):
	var line = Line2D.new()
	var points = PackedVector2Array([first, second])
	line.points = points
	line.default_color = Color.BLACK
	lines.add_child(line)
