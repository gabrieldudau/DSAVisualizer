extends Node

@onready var camera: Camera2D = $"Camera2D"
@onready var label: Label = $Control/Label


enum modes {ZOOM_MODE , MOVE_CAMERA_MODE}
var current_mode := modes.MOVE_CAMERA_MODE
var left_pressed:bool = false

func _ready() -> void:	
	camera.zoom = Vector2(.4,.4)
	camera.position = Vector2(0,800)


func _input(event: InputEvent) -> void:
	print(camera.zoom," - ",camera.position)
	if event is InputEventMouseButton:
		if event.is_action_pressed("rightMB"):
			current_mode = modes.ZOOM_MODE if current_mode == modes.MOVE_CAMERA_MODE else modes.MOVE_CAMERA_MODE
			label.text = "MOVE" if current_mode == modes.MOVE_CAMERA_MODE else "ZOOM"
		if event.is_action_pressed("leftMB"):
			left_pressed = true
		if event.is_action_released("leftMB"):
			left_pressed = false
	elif event is InputEventMouseMotion:
		if left_pressed:
			match current_mode:
				modes.MOVE_CAMERA_MODE:
					move_camera(event.relative)
				modes.ZOOM_MODE:
					zoom(event.relative)


func zoom(delta_move:Vector2):
	delta_move = Vector2(1,1) * delta_move.length()/100 * ((delta_move.y / abs(delta_move.y)) if delta_move.y != 0 else 0)
	camera.zoom += delta_move if (camera.zoom + delta_move > Vector2(0.2,0.2)) else Vector2(0,0)

func move_camera(amount:Vector2):
	camera.position -= amount / camera.zoom
