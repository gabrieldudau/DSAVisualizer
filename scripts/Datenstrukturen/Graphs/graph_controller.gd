extends Node2D

const NODE_CLASS = preload("res://scenes/Datenstrukturen/Graphs/graph_node.tscn")
const BODY_GROUP = "celestial_bodies"

@export var center_stiffness: float = 10.0

## The radius around the center where the pull force stops.
@export var center_dead_zone_radius: float = 10.0

## How strongly to apply friction/drag to stop oscillation.
@export var damping_factor: float = 8.0

func create_new_node(posX: int, posY:int, text:String):
	var createNode = NODE_CLASS.instantiate()
	createNode.position = Vector2(posX, posY)
	add_child(createNode)

func _physics_process(delta: float) -> void:
	var bodies = get_tree().get_nodes_in_group(BODY_GROUP)
	var screen_center: Vector2 = get_viewport_rect().size / 2.0

	for body in bodies:
		if body is RigidBody2D:
			var to_center_vector: Vector2 = screen_center - body.global_position
			var distance_to_center: float = to_center_vector.length()

			# --- 1. DYNAMIC ATTRACTION FORCE ---
			# The force is now proportional to the distance (like a spring).
			# It only applies when the body is outside the 'dead zone'.
			if distance_to_center > center_dead_zone_radius:
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

func _mouse_touching_node(node:RigidBody2D):
	print(node.to_string())
