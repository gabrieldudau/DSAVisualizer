class_name TreeNode
extends Node2D


const GRAPHICAL_NODE = preload("res://scenes/Universal/universal_node.tscn")

# Variables for the graphic representation of the node

var current_color:Color
var radius: float = 60
var key: int = 15
var fontsize:float = 36
var drawNode:UniversalNode

# Variables for the tree logic

var left:TreeNode
var right:TreeNode
var parent:TreeNode
var connection_line:Line2D
var positions_list_no_line:Array
var positions_list_with_line:Array

var time:Timer = Timer.new()
var moving:bool = false
var target_position:Vector2
var current_depth:int

func _on_ready() -> void:
	drawNode = GRAPHICAL_NODE.instantiate()
	drawNode.key = key
	drawNode.color = Color.WHITE
	drawNode.radius = radius
	drawNode.fontSize = self.fontsize
	add_child(drawNode)
	add_child(time)

func connect_line():
	if(parent == null):
		return
	connection_line = Line2D.new()
	connection_line.add_point(Vector2(0,0))
	connection_line.add_point(parent.position - position)
	connection_line.z_index = -1
	connection_line.default_color = Color.BLACK
	add_child(connection_line)

func move_to_right_position(speed) -> void:
	if positions_list_no_line.is_empty() and positions_list_with_line.is_empty():
		return
	moving = true
	
	if not positions_list_no_line.is_empty():
		position = positions_list_no_line.pop_front()
	
	var switched_list:bool = false
	var current_list:Array = self.positions_list_no_line if not positions_list_no_line.is_empty() else self.positions_list_with_line
	
	while (not current_list.is_empty()):
		if((connection_line == null) and switched_list):
			connect_line()
		
		var position_to_reach:Vector2 = current_list.pop_front()
		
		var vector_to_new_position:Vector2 = position_to_reach - position
		var distance = position.distance_to(position_to_reach)
		while distance > 1:
			var delta_time = get_process_delta_time()
			var movement_this_frame = vector_to_new_position.normalized() * speed * delta_time # Normalize for consistent speed
			position += movement_this_frame
			if connection_line != null:
				connection_line.set_point_position(1, parent.position - position)
			if left != null: 
				if left.connection_line != null:
					left.connection_line.set_point_position(1, left.parent.position - left.position)
			if right != null: 
				if right.connection_line != null:
					right.connection_line.set_point_position(1, right.parent.position - right.position)
			var old_distance = distance
			distance = position.distance_to(position_to_reach) # Update distance
			if (distance > old_distance):
				break
			await get_tree().process_frame
		position = position_to_reach
		if (not switched_list) and (current_list.is_empty()):
			current_list = self.positions_list_with_line
			switched_list = true
		
	if((connection_line == null)):
		connect_line()
	moving = false
	


func light_up_for_search():
	
	drawNode.color = Color.YELLOW
	drawNode.queue_redraw()
	
	if connection_line != null:
		connection_line.default_color = Color.ORANGE_RED
	time.start(3)
	await time.timeout
	
	drawNode.color = Color.WHITE
	drawNode.queue_redraw()
	
	
	if connection_line != null:
		connection_line.default_color = Color.BLACK


func delete_node():
	queue_free()


func _to_string() -> String:
	return rec_tree_String(self, "")


func rec_tree_String(x: TreeNode, tab:String) -> String:
	if( x == null):
		return "" 
	var ownLine:String = tab + ">" + str(x.key) + "\n"
	return rec_tree_String(x.right, tab + "-----") + ownLine + rec_tree_String(x.left, tab + "-----")
