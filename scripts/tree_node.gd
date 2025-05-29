extends Node2D

@onready var label: Label = $Label

var touched = false

func _on_mouse_entered() -> void:
	touched = true
	print(label.text + " touched")


func _on_mouse_exited() -> void:
	touched = false
	print(label.text + " not touched")
