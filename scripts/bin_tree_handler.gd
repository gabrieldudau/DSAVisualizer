extends Node2D

@export var horizonal_distance_between_nodes = 150
@export var vertical_distance_between_nodes = 150

var root:TreeNode
const TREE_NODE = preload("res://scenes/tree_node.tscn")

func _on_tree_entered() -> void:
	GlobalSignal.newNode.connect(add_node)
	GlobalSignal.searchNode.connect(search_node)
	
func _on_tree_exiting() -> void:
	GlobalSignal.newNode.disconnect(add_node)
	GlobalSignal.searchNode.disconnect(search_node)


func add_node(tree_node:TreeNode) -> void: 
	var x:TreeNode = root
	var px:TreeNode = null

	var left_subtree = null
	var position_binary:int
	var dist = 1
	var vertical_offset = -200
	
	while x != null:
		px = x
		if (x.key > tree_node.key):
			# actual logic
			x = x.left
			
			# logic for placement of graphical nodes
			if left_subtree == null:
				left_subtree = true
				tree_node.positions_list.append(Vector2(-150, -200))
			elif left_subtree == true:
				tree_node.positions_list.append(convert_bin_to_pos(position_binary, true, vertical_offset))
				position_binary = position_binary << 1
				position_binary += 1
			else:
				tree_node.positions_list.append(convert_bin_to_pos(position_binary, false, vertical_offset))
				position_binary = position_binary << 1
		else:
			# actual logic
			x=x.right
			
			# logic for placement of graphical nodes
			if left_subtree == null:
				left_subtree = false
				tree_node.positions_list.append(Vector2(150, -200))
			elif left_subtree == true:
				tree_node.positions_list.append(convert_bin_to_pos(position_binary, true, vertical_offset))
				position_binary = position_binary << 1
			else:
				tree_node.positions_list.append(convert_bin_to_pos(position_binary, false, vertical_offset))
				position_binary = position_binary << 1
				position_binary += 1
		dist += 0.5
		vertical_offset += vertical_distance_between_nodes * dist
		print("vertical_offset: ", vertical_offset)
		
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
	
	# calculate the offset with a binary number. The created string is the binary number, for the 
	# place that the node will receive in that layer. For example the binary number 0 would mean that
	# the node is horizontaly, on the 1. place, either right or left. 
	
	tree_node.positions_list.append(convert_bin_to_pos(position_binary, left_subtree, vertical_offset))
	add_child(tree_node)
	tree_node.move_to_right_position(500)
	

func convert_bin_to_pos(horizontal_place:int, left:bool, vertical_offset:float) -> Vector2:
	return Vector2(((-1) if left else 1) * (self.horizonal_distance_between_nodes/2 + horizontal_place * self.horizonal_distance_between_nodes), vertical_offset)


func search_node(key:int) -> void:
	print("received")
	var x = root
	while (x != null) and (x.key != key):
		x.light_up_for_search()
		if(x.key > key):
			x=x.left
		else:
			x=x.right;
	if x != null:
		x.light_up_for_search()

# add random nodes, to have a quick visualisation of how a bin_tree works
func _on_button_pressed() -> void:
	var keys:Array = [32, 16, 48, 8, 24, 40, 56, 4, 12, 20, 28, 36, 44, 52, 60, 2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51, 53, 55, 57, 59, 61, 63]
	
	for key in keys:
		var node = TREE_NODE.instantiate()
		node.key = key
		add_node(node)
