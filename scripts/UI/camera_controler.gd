extends Node
class_name SceneMover

## --- Referenzen ---
@onready var camera: Camera2D = $"Camera2D"

## --- Konfiguration ---
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.3
@export var max_zoom: float = 4.0
@export var smoothness: float = 6.0

## --- Interne Variablen ---
var is_panning: bool = false
var target_zoom: Vector2
var moveable = true

func _ready() -> void:
	camera.position = Vector2(0, 150)
	camera.zoom = Vector2(0.8, 0.8)
	target_zoom = camera.zoom

func _process(delta: float) -> void:
	camera.zoom = camera.zoom.lerp(target_zoom, smoothness * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			update_target_zoom(-1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			update_target_zoom(1)

	if event.is_action_pressed("leftMB"):
		is_panning = true
	if event.is_action_released("leftMB"):
		is_panning = false

	if event is InputEventMouseMotion and is_panning and moveable:
		move_camera(event.relative)

func update_target_zoom(direction: int):
	var zoom_amount = target_zoom.x + direction * zoom_speed
	var new_zoom_level = clamp(zoom_amount, min_zoom, max_zoom)
	target_zoom = Vector2(new_zoom_level, new_zoom_level)

func move_camera(amount: Vector2):
	camera.position -= amount / camera.zoom
