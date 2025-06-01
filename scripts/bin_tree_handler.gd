extends Node2D

@onready var game_controler: Node2D = $".."

const TREE_NODE = preload("res://scenes/tree_node.tscn")
var root

func _on_tree_entered() -> void:
	GlobalSignal.newNode.connect(add_node)
	
func _on_tree_exiting() -> void:
	GlobalSignal.newNode.disconnect(add_node)


func add_node(tree_node) -> void: 
	var offset_vertical = -200
	var x = root
	var px = null

	var left_subtree = null
	var place_in_horizontal:Array = []
	var dist = 1
	while x != null:
		px = x
		if (x.key > tree_node.key):
			# actual logic
			x = x.left
			
			# logic for placement of graphical nodes
			if left_subtree == null:
				left_subtree = true
			elif left_subtree == true:
				place_in_horizontal.append(1)
			else:
				place_in_horizontal.append(0)
		else:
			# actual logic
			x=x.right
			
			# logic for placement of graphical nodes
			if left_subtree == null:
				left_subtree = false
			elif left_subtree == true:
				place_in_horizontal.append(0)
			else:
				place_in_horizontal.append(1)
		# increasing the layer
		offset_vertical += 150 * dist
		dist += 0.5
	
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
	
	var offset_horizontal = 75 + 150*convert_bin_to_int(place_in_horizontal)
	offset_horizontal *= (-1) if left_subtree else 1 
	tree_node.position = Vector2(offset_horizontal, offset_vertical)
	add_child(tree_node)
	tree_node.connect_line()


func convert_bin_to_int(num:Array):
	var sum = 0
	for i in range (0,num.size()):
		sum += int(num[i]) * pow(2,num.size() - 1 - i)
	return sum
