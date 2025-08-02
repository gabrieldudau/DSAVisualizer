extends Node2D

@export var horizonal_distance_between_nodes:float = 150
@export var vertical_distance_between_nodes:float = 200
@export var root_position:Vector2 = Vector2(0, -200)
@export var animation_speed:int = 1000

var root:TreeNode
const TREE_NODE = preload("res://scenes/Datenstrukturen/tree_node.tscn")
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
				tree_node.positions_list_no_line.append(root_position)
		else:
			# actual logic
			x=x.right
			# logic for placement of graphical nodes
			if left_subtree == null:
				left_subtree = false
				tree_node.positions_list_no_line.append(root_position)
		new_depth += 1

	tree_node.parent = px
	if px == null:
		root = tree_node
		# position of root
		tree_node.position = root_position
		add_child(tree_node)
		return
	else:
		if px.key > tree_node.key:
			px.left = tree_node
		else: 
			px.right = tree_node
	
	add_child(tree_node)
	if new_depth > tree_depth:
		tree_depth = new_depth
	update_positions()
	
	
	# Get the current contents of the clipboard
	# var current_clipboard = DisplayServer.clipboard_get()
	# Set the contents of the clipboard
	# DisplayServer.clipboard_set(str(root))
	

func update_positions() -> void:
	if (root == null): return
	root.current_depth = 0
	var leafsLeft:Array = get_leafs_rec(root.left, 1)
	var leafsRight:Array = get_leafs_rec(root.right, 1)
	
	for i in range(leafsLeft.size() - 1, -1, -1):
		var newPos:Vector2 = Vector2((-1) * (self.horizonal_distance_between_nodes/2.0 - (i - leafsLeft.size()+1) * self.horizonal_distance_between_nodes), root_position.y + leafsLeft.get(i).current_depth * self.vertical_distance_between_nodes)
		leafsLeft.get(i).target_position = newPos
		leafsLeft.get(i).positions_list_with_line.append(newPos)
	
	for i in range(leafsRight.size()):
		var newPos:Vector2 = Vector2(self.horizonal_distance_between_nodes/2.0 + i * self.horizonal_distance_between_nodes, root_position.y + leafsRight.get(i).current_depth * self.vertical_distance_between_nodes)
		leafsRight.get(i).target_position = newPos
		leafsRight.get(i).positions_list_with_line.append(newPos)
	
	root.positions_list_no_line.append(root_position)
	root.move_to_right_position(animation_speed)
	if(root.connection_line != null): root.connection_line.queue_free()
	
	update_all_pos(root.left, true)
	update_all_pos(root.right, false)

## Returns all the leafs of a current TreeNode, and also updates the 
## attribute [param current_depth] of TreeNode 
func get_leafs_rec(x:TreeNode, depth:int) -> Array:

	if (x == null):
		return []
	x.current_depth = depth
	if (x.left == null and x.right == null):
		return [x]
	var output:Array = [] 
	if (x.left != null):
		output.append_array(get_leafs_rec(x.left, depth + 1))
	if (x.right != null):
		output.append_array(get_leafs_rec(x.right, depth + 1))
	return output


func update_all_pos(x:TreeNode, left:bool) -> Vector2:
	if(x == null):
		return Vector2(0,0)
	if(x.left == null and x.right == null):
		if(not x.moving):
			x.move_to_right_position(animation_speed)
		return x.target_position
	
	var child_left_horizontal = update_all_pos(x.left, left).x
	var child_right_horizontal = update_all_pos(x.right, left).x
	
	if(x.left != null and x.right != null):
		if (left):
			x.target_position = Vector2(child_right_horizontal + (child_left_horizontal - child_right_horizontal)/2, root_position.y + vertical_distance_between_nodes*x.current_depth)
		else:
			x.target_position = Vector2(child_left_horizontal + (child_right_horizontal - child_left_horizontal)/2, root_position.y + vertical_distance_between_nodes*x.current_depth)
	else:
		x.target_position = Vector2(child_left_horizontal + child_right_horizontal, root_position.y + vertical_distance_between_nodes*x.current_depth)
	x.positions_list_with_line.append(x.target_position)
	
	if(not x.moving):
		x.move_to_right_position(animation_speed)
	return x.target_position


func delete_node(key:int) -> void:
	var z:TreeNode = search_node_return(key)
	if (z == null): return
	# Algorithmus aus AuD
	if (z.left == null):
		transplant(z, z.right)
	else:
		if (z.right == null):
			transplant(z, z.left)
		else:
			var y = z.right
			while(y.left != null):
				y = y.left
			if(y.parent != z):
				transplant(y, y.right)
				y.right = z.right
				y.right.parent = y
			transplant(z, y)
			y.left = z.left
			y.left.parent = y
	update_positions()
	z.queue_free()


func transplant(u:TreeNode, v:TreeNode):
	if(u.parent == null):
		root = v
	elif (u == u.parent.left):
		u.parent.left = v
	else:
		u.parent.right = v
	if(v != null):
		v.parent = u.parent


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
	var keys:Array = [32, 16, 48, 8, 24, 40, 56, 4, 12, 20, 28, 36, 44, 52, 60, 2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62]
	
	for key in keys:
		var node = TREE_NODE.instantiate()
		node.key = key
		add_node(node)
