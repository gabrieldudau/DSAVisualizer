extends Node2D

@onready var label: Label = $Label

var left: Area2D
var right: Area2D
var parent: Area2D
var key: int

var touched = false


func _on_mouse_entered() -> void:
	touched = true


func _on_mouse_exited() -> void:
	touched = false


func _on_ready() -> void:
	label.text = str(key)
