class_name ListItem

extends Node2D

@onready var content: Label = $Label
var content_string:String

@export var color: Color = Color.DARK_ORANGE


func _on_ready() -> void:
	content.text = content_string
	queue_redraw()

func _on_draw() -> void:
	var content_rect = content.get_rect()
	content_rect.size += Vector2(10, 5)
	content_rect.position += Vector2(-5, 0)
	
	print_debug(content_rect.position)
	print_debug(content_rect.size)	
	
	draw_rect(content_rect, color)
	draw_rect(content_rect, Color.BLACK, false, 5)

func _on_label_item_rect_changed() -> void:
	queue_redraw()


func get_current_size() -> Vector2:
	return content.get_rect().size
