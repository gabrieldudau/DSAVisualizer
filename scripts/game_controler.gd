extends Node

@onready var camera: Camera2D = $"Camera2D"
@onready var tree_nodes: Node = $TreeNodes
@onready var label: Label = $Control/Label


var TREE_NODE = preload("res://scenes/tree_node.tscn")

enum {ZOOM_MODE ,DELETE_MODE , MOVE_CAMERA_MODE}
var current_mode := MOVE_CAMERA_MODE
var mousepos
var left_pressed:bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "MOVE CAMERA" if (current_mode == MOVE_CAMERA_MODE) else "ZOOM_MODE" if (current_mode == ZOOM_MODE) else "DELETE NODE"
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("rightMB"):
			current_mode = ZOOM_MODE if (current_mode == DELETE_MODE) else DELETE_MODE if (current_mode == MOVE_CAMERA_MODE) else MOVE_CAMERA_MODE
		if event.is_action_pressed("leftMB"):
			left_pressed = true
		if event.is_action_released("leftMB"):
			left_pressed = false
	elif event is InputEventMouseMotion:
		if left_pressed:
			match current_mode:
				MOVE_CAMERA_MODE:
					move_camera(event.relative)
				DELETE_MODE:
					pass
				ZOOM_MODE:
					zoom(event.relative)


func zoom(delta_move:Vector2):
	delta_move = Vector2(1,1) * delta_move.length()/100 * ((delta_move.y / abs(delta_move.y)) if delta_move.y != 0 else 0)
	camera.zoom += delta_move if (camera.zoom + delta_move > Vector2(0.2,0.2)) else Vector2(0,0)
		

func move_camera(amount:Vector2):
	camera.position -= amount / camera.zoom



func delete_tree_node():
	if Input.is_action_just_pressed("leftMB"):
		for child in tree_nodes.get_children():
			if child.touched == true:
				child.queue_free()
