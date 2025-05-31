extends Node2D

@onready var label: Label = $Label

var left: Area2D
var right: Area2D
var parent: Area2D
var key: int
var connection_line:Line2D

var touched = false


func _on_mouse_entered() -> void:
	touched = true


func _on_mouse_exited() -> void:
	touched = false


func _on_ready() -> void:
	label.text = str(key)

func connect_line():
	if(parent == null):
		return
	connection_line = Line2D.new()
	print(position)
	connection_line.add_point(Vector2(0,0))
	connection_line.add_point(parent.position - position)
	connection_line.z_index = -1
	connection_line.default_color = Color.BLACK
	add_child(connection_line)
