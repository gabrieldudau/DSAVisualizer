extends Node

@onready var camera: Camera2D = $"Camera2D"
@onready var tree_nodes: Node = $TreeNodes
@onready var lines: Node = $Lines


var TREE_NODE = preload("res://scenes/tree_node.tscn")
@export var insertNodes := true
var count;

func _ready() -> void:
	count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# toggle between placing mode, and not placing 
	if Input.is_action_just_pressed("rightMB"):
		insertNodes = !insertNodes
	
	var mouse_pos = get_viewport().get_mouse_position() - Vector2(get_viewport().size.x/2, get_viewport().size.y/2) + camera.get_screen_center_position()

	if Input.is_action_just_pressed("leftMB"):
		if insertNodes:
			count += 1
			create_tree_node(mouse_pos, str(count))
		else:
			for child in tree_nodes.get_children():
				if child.touched == true:
					child.queue_free()
			if(tree_nodes.get_children().size() >= 2):
				line_between(tree_nodes.get_child(0).position, tree_nodes.get_child(1).position)

# Creates a tree node at the given position with the given text
func create_tree_node(position:Vector2, text:String):
	var tree_node = TREE_NODE.instantiate()
	tree_node.position = position
	tree_node.get_child(1).text = text
	tree_nodes.add_child(tree_node)

# Creates a line between two given Vector2
func line_between(first:Vector2, second:Vector2):
	var line = Line2D.new()
	var points = PackedVector2Array([first, second])
	line.points = points
	line.default_color = Color.BLACK
	lines.add_child(line)
