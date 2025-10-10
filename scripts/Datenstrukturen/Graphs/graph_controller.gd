extends Node2D

class_name graph_controller

@onready var springs: Node2D = $Springs

const NODE_CLASS = preload("res://scenes/Datenstrukturen/Graphs/graph_node.tscn")
const BODY_GROUP = "celestial_bodies"

@export var center_stiffness: float = 10.0
## How strongly to apply friction/drag to stop oscillation.
@export var damping_factor: float = 8.0


# keeps track of the touched Node
var childTouched:Array[RigidBody2D] = []
# keeps track of the node that is currently moving
var childMoving:RigidBody2D = null


# This is related to Springs

var spring1:RigidBody2D = null
var springs_dict:Dictionary[RigidBody2D, Array] = {}



# NEEDS TO BE CALLED BEFORE add_spring(), WHEN THE MOUSE MIGHT TOUCH A NODE
func click_started():
	if childTouched.is_empty():
		spring1 = null
		return
	spring1 = childTouched[0]


# Sets the position of the current child that is touched to the mouse
# If called again it releases the child
func toggle_child_moving() -> void:
	spring1 = null
	if(childTouched.is_empty()): return
	if childMoving == null:
		childMoving = childTouched[0]
		childMoving.freeze = true
	else:
		childMoving.freeze = false
		childMoving = null


# adds a spring between two nodes
# click_started() needs to be called before for this to work
func add_spring() -> void:
	if spring1 == null or childTouched.is_empty() or spring1 == childTouched[0]:
		return
	if spring1 in springs_dict:
		if springs_dict[spring1].has(childTouched[0]):
			return
		springs_dict[spring1].append(childTouched[0])
	else:
		springs_dict[spring1] = [childTouched[0]]
	
	if not childTouched[0] in springs_dict:
		springs_dict[childTouched[0]] = []
	springs_dict[childTouched[0]].append(spring1)
	
	var newSpring: DampedSpringJoint2D = DampedSpringJoint2D.new()
	newSpring.node_a = spring1.get_path()
	newSpring.node_b = childTouched[0].get_path()
	newSpring.rest_length = 500
	springs.add_child(newSpring)


func create_new_node(posX: int, posY:int, text:String):
	var createNode = NODE_CLASS.instantiate()
	createNode.position = Vector2(posX, posY)
	add_child(createNode)


func _physics_process(delta: float) -> void:
	var bodies = get_tree().get_nodes_in_group(BODY_GROUP)
	var screen_center = get_viewport().get_camera_2d().get_screen_center_position() if get_viewport().get_camera_2d() else get_viewport_rect().size / 2
		
	
	if childMoving != null:
		childMoving.position = get_global_mouse_position()

	for body in bodies:
		if body == childMoving:
			continue
		if body is RigidBody2D:
			var to_center_vector: Vector2 = screen_center - body.global_position
			var distance_to_center: float = to_center_vector.length()

			var attraction_force: Vector2 = to_center_vector * center_stiffness
			body.apply_central_force(attraction_force)

			# --- 2. ACTIVE DAMPING FORCE ---
			# This force acts like friction, slowing the body down to prevent
			# it from oscillating forever. It's always applied.
			var drag_force: Vector2 = -body.linear_velocity * damping_factor
			body.apply_central_force(drag_force)


func _on_child_entered_tree(node: Node) -> void:
	if(node is RigidBody2D):
		node.input_pickable = true
		node.mouse_entered.connect(_mouse_touching_node.bind(node))
		node.mouse_exited.connect(_mouse_not_touching_node.bind(node))

func _mouse_touching_node(node:RigidBody2D):
	childTouched.insert(0,node);
	print(childTouched[0].to_string())

func _mouse_not_touching_node(node:RigidBody2D):
	childTouched.remove_at(childTouched.size() - 1)
