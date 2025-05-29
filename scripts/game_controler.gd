extends Node

@onready var camera: Camera2D = $"../Camera2D"
@onready var main: Node = $".."

var TREE_NODE = preload("res://scenes/tree_node.tscn")
var insertNodes = true
var count;

func _ready() -> void:
	count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# toggle between placing mode, and not placing 
	if Input.is_action_just_pressed("rightMB"):
		insertNodes = !insertNodes
	
	var mouse_pos = get_viewport().get_mouse_position() - Vector2(get_viewport().size.x/2, get_viewport().size.y/2) + camera.get_screen_center_position()
	
	if insertNodes:
		if Input.is_action_just_pressed("leftMB"):
			var instance = TREE_NODE.instantiate()
			instance.position = mouse_pos
			instance.get_child(1).text = str(count)
			count += 1
			main.add_child(instance)
	else:
		if Input.is_action_just_pressed("leftMB"):
			print("succes")
			for child in main.get_children():
				if child.scene_file_path == "res://scenes/tree_node.tscn":
					if child.touched == true:
						child.queue_free()
				
