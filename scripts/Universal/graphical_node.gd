extends Node2D

@onready var label: Label = $Label

@export var key:String
@export var color:Color
@export var radius:float
@export var fontsize:int
@onready var collision_shape_2d: CollisionShape2D = $"../CollisionShape2D"

func _ready() -> void:
	label.text = key
	label.add_theme_font_size_override("font_size", fontsize)
	var colShape = CircleShape2D.new()
	colShape.radius = radius
	collision_shape_2d.shape = colShape

func _on_draw() -> void:
	draw_circle(Vector2(0,0), radius, Color.BLACK)
	draw_circle(Vector2(0,0), radius-5, color)
