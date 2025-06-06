extends Node2D

@export var horizonal_distance_between_nodes = 150
@export var vertical_distance_between_nodes = 150

var root:TreeNode
const TREE_NODE = preload("res://scenes/tree_node.tscn")
var tree_depth:int = 0

func _on_tree_entered() -> void:
	GlobalSignal.newNode.connect(add_node)
	GlobalSignal.searchNode.connect(search_node)
	GlobalSignal.deleteNode.connect(delete_node)

func _on_tree_exiting() -> void:
	GlobalSignal.newNode.disconnect(add_node)
	GlobalSignal.searchNode.disconnect(search_node)
	GlobalSignal.deleteNode.disconnect(delete_node)


func add_node(tree_node:TreeNode) -> void: 
	var x:TreeNode = root
	var px:TreeNode = null

	var left_subtree = null
	var new_depth = 0
	
	while x != null:
		px = x
		if (x.key > tree_node.key):
			# actual logic
			x = x.left
			# logic for placement of graphical nodes
			if left_subtree == null:
				left_subtree = true
				tree_node.positions_list_no_line.append(Vector2(-150, -200))
		else:
			# actual logic
			x=x.right
			# logic for placement of graphical nodes
			if left_subtree == null:
				left_subtree = false
				tree_node.positions_list_no_line.append(Vector2(150, -200))
		new_depth += 1

	tree_node.parent = px
	if px == null:
		root = tree_node
		# position of root
		tree_node.position = Vector2(0, -200)
		add_child(tree_node)
		return
	else:
		if px.key > tree_node.key:
			px.left = tree_node
		else: 
			px.right = tree_node
	
	tree_node.current_depth = new_depth
	add_child(tree_node)
	if new_depth > tree_depth:
		tree_depth = new_depth
	update_positions()
	
	
	# Get the current contents of the clipboard
	# var current_clipboard = DisplayServer.clipboard_get()
	# Set the contents of the clipboard
	# DisplayServer.clipboard_set(str(root))
	

func update_positions() -> void:
	var leafsLeft:Array = get_leafs_rec(root.left)
	var leafsRight:Array = get_leafs_rec(root.right)
	
	for i in range(leafsLeft.size() - 1, -1, -1):
		var newPos:Vector2 = Vector2((-1) * (self.horizonal_distance_between_nodes/2.0 - (i - leafsLeft.size()+1) * self.horizonal_distance_between_nodes), -200 + leafsLeft.get(i).current_depth * 150)
		leafsLeft.get(i).target_position = newPos
		leafsLeft.get(i).positions_list_with_line.append(newPos)
	
	for i in range(leafsRight.size()):
		var newPos:Vector2 = Vector2(self.horizonal_distance_between_nodes/2.0 + i * self.horizonal_distance_between_nodes, -200 + leafsRight.get(i).current_depth * 150)
		leafsRight.get(i).target_position = newPos
		leafsRight.get(i).positions_list_with_line.append(newPos)
	
	update_all_pos(root.left, true)
	update_all_pos(root.right, false)

func get_leafs_rec(x:TreeNode) -> Array:
	if (x == null):
		return []
	if (x.left == null and x.right == null):
		return [x]
	var output:Array = [] 
	if (x.left != null):
		output.append_array(get_leafs_rec(x.left))
	if (x.right != null):
		output.append_array(get_leafs_rec(x.right))
	return output


func update_all_pos(x:TreeNode, left:bool) -> Vector2:
	if(x == null):
		return Vector2(0,0)
	if(x.left == null and x.right == null):
		if(not x.moving):
			x.move_to_right_position(1000)
		return x.target_position
	
	var child_left_horizontal = update_all_pos(x.left, left).x
	var child_right_horizontal = update_all_pos(x.right, left).x
	
	if(x.left != null and x.right != null):
		if (left):
			x.target_position = Vector2(child_right_horizontal + (child_left_horizontal - child_right_horizontal)/2, -200 + 150*x.current_depth)
		else:
			x.target_position = Vector2(child_left_horizontal + (child_right_horizontal - child_left_horizontal)/2, -200 + 150*x.current_depth)
	else:
		x.target_position = Vector2(child_left_horizontal + child_right_horizontal, -200 + 150*x.current_depth)
	x.positions_list_with_line.append(x.target_position)
	
	if(not x.moving):
		x.move_to_right_position(1000)
	return x.target_position
	


func delete_node(key:int) -> void:
	search_node_return(key).delete_node()
	print("deleted")
	print(root)

func search_node(key:int) -> void:
	var x = root
	while (x != null) and (x.key != key):
		x.light_up_for_search()
		if(x.key > key):
			x=x.left
		else:
			x=x.right;
	if x != null:
		x.light_up_for_search()

func search_node_return(key:int) -> TreeNode:
	var x = root
	while (x != null) and (x.key != key):
		if(x.key > key):
			x=x.left
		else:
			x=x.right;
	return x

# add random nodes, to have a quick visualisation of how a bin_tree works
func _on_button_pressed() -> void:
	var keys:Array = [32, 16, 48, 8, 24, 40, 56, 4, 12, 20, 28, 36, 44, 52, 60, 2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53, 55, 57, 59, 61, 63]
	
	for key in keys:
		var node = TREE_NODE.instantiate()
		node.key = key
		add_node(node)
