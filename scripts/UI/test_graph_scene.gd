extends Node2D

@onready var graph: Node2D = $Graph

func _on_button_pressed() -> void:
	graph.create_new_node(randi() % 1000, randi() % 1500, "")
