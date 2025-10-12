extends SceneMover

@onready var graph: GraphController = $Graph
@onready var h_slider: HSlider = $CanvasLayer/VBoxContainer/HSlider
@onready var click_timer: Timer = $ClickTimer
@onready var label: Label = $CanvasLayer/Container/Label

func _ready() -> void:
	super()

func _process(delta: float) -> void:
	super(delta)
	label.text = str(get_tree().get_nodes_in_group("celestial_bodies").size())

func _on_button_pressed() -> void:
	graph.create_new_node(randi() % 1000, randi() % 1500, "")

func _input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("leftMB"):
		graph.click_started()
		click_timer.start()
	if event.is_action_released("leftMB"):
		var click_time = click_timer.time_left
		click_timer.stop()
		if click_time > 0.0:
			graph.toggle_child_moving()
		else:
			graph.add_spring()

func _on_camera_move_pressed() -> void:
	moveable = not moveable

func _on_h_slider_2_value_changed(value: float) -> void:
	graph.repulsion_force = value;


func _on_h_slider_value_changed(value: float) -> void:
	var val = h_slider.value
	graph.center_stiffness= val
	print(val)
